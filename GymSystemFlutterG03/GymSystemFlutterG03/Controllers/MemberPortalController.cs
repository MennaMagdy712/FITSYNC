using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Member")]
    public class MemberPortalController : ControllerBase
    {
        private readonly IMemberService _memberService;

        public MemberPortalController(IMemberService memberService)
        {
            _memberService = memberService;
        }

        // Helper: extract memberId from JWT token
        private int? GetMemberIdFromToken()
        {
            var claim = User.FindFirst("memberId")?.Value;
            if (int.TryParse(claim, out int id)) return id;
            return null;
        }

        #region Home Page
        [HttpGet("Home")]
        public IActionResult Home()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var homeData = _memberService.GetMemberHomeData(memberId.Value);
            if (homeData == null) return NotFound(new { message = "Member not found." });

            return Ok(homeData);
        }
        #endregion

        #region Details
        [HttpGet("Details")]
        public IActionResult Details()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var details = _memberService.GetMemberDetails(memberId.Value);
            if (details == null) return NotFound(new { message = "Member not found." });

            return Ok(details);
        }
        #endregion

        #region Edit (GET + PUT)
        [HttpGet("Edit")]
        public IActionResult Edit()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var memberToEdit = _memberService.GetMemberToUpdate(memberId.Value);
            if (memberToEdit == null) return NotFound(new { message = "Member not found." });

            return Ok(memberToEdit);
        }

        [HttpPut("Edit")]
        public IActionResult Edit([FromBody] MemberToUpdateViewModel updatedMember)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var result = _memberService.UpdateMemberDetails(memberId.Value, updatedMember);
            if (result)
                return Ok(new { message = "Profile updated successfully." });

            return BadRequest(new { message = "Failed to update profile. Email or phone may already be in use." });
        }
        #endregion

        #region Health Record
        [HttpGet("HealthRecord")]
        public IActionResult HealthRecord()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var healthRecord = _memberService.GetMemberHealthRecordDetails(memberId.Value);
            if (healthRecord == null) return NotFound(new { message = "Health record not found." });

            return Ok(healthRecord);
        }
        #endregion

        #region Plan
        [HttpGet("Plan")]
        public IActionResult Plan()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var details = _memberService.GetMemberDetails(memberId.Value);
            if (details == null) return NotFound(new { message = "Member not found." });

            return Ok(new
            {
                PlanName = details.PlanName,
                MemberShipStartDate = details.MemberShipStartDate,
                MemberShipEndDate = details.MemberShipEndDate
            });
        }
        #endregion

        #region Sessions
        [HttpGet("Sessions")]
        public IActionResult Sessions()
        {
            var memberId = GetMemberIdFromToken();
            if (memberId == null) return Unauthorized();

            var sessions = _memberService.GetMemberSessions(memberId.Value);
            return Ok(sessions);
        }
        #endregion
    }
}
