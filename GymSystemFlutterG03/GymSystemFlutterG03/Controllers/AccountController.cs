using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.AccountViewModels;
using GymSystemG03DAL.Entites;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly IAccountService _accountService;
        private readonly IMemberService _memberService;
        private readonly IConfiguration _configuration;

        public AccountController(IAccountService accountService, IMemberService memberService, IConfiguration configuration)
        {
            _accountService = accountService;
            _memberService = memberService;
            _configuration = configuration;
        }

        [HttpPost("Login")]
        public ActionResult Login([FromBody] LoginViewModel model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var user = _accountService.ValidateUser(model);
            if (user == null)
            {
                return Unauthorized(new { message = "Invalid Email Or Password" });
            }

            var token = GenerateAdminJwtToken(user);
            return Ok(new { token = token, expiration = DateTime.Now.AddDays(1) });
        }

        [HttpPost("LoginAsMember")]
        public ActionResult LoginAsMember([FromBody] MemberLoginViewModel model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var member = _memberService.GetMemberByEmail(model.Email);
            if (member == null || string.IsNullOrEmpty(member.PasswordHash))
                return Unauthorized(new { message = "Invalid Email Or Password" });

            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(model.Password, member.PasswordHash);
            if (!isPasswordValid)
                return Unauthorized(new { message = "Invalid Email Or Password" });

            var token = GenerateMemberJwtToken(member);
            return Ok(new { token = token, expiration = DateTime.Now.AddDays(1) });
        }

        private string GenerateAdminJwtToken(ApplicationUser user)
        {
            var authClaims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.UserName ?? string.Empty),
                new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
                new Claim(ClaimTypes.Role, "SuperAdmin"),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            return BuildToken(authClaims);
        }

        private string GenerateMemberJwtToken(GymSystemG03DAL.Entites.Member member)
        {
            var authClaims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, member.Name),
                new Claim(ClaimTypes.Email, member.Email),
                new Claim(ClaimTypes.Role, "Member"),
                new Claim("memberId", member.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            return BuildToken(authClaims);
        }

        private string BuildToken(List<Claim> authClaims)
        {
            var secret = _configuration["JWT:Secret"];
            if (string.IsNullOrEmpty(secret))
                throw new InvalidOperationException("JWT Secret is not configured.");

            var authSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));

            var token = new JwtSecurityToken(
                issuer: _configuration["JWT:ValidIssuer"],
                audience: _configuration["JWT:ValidAudience"],
                expires: DateTime.Now.AddDays(1),
                claims: authClaims,
                signingCredentials: new SigningCredentials(authSigningKey, SecurityAlgorithms.HmacSha256)
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
