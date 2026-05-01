using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.MembershipsViewModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")]
    public class MembershipController(IMembershipService membershipService) : ControllerBase
    {
        #region Get All Membership
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var memberships = membershipService.GetAllMemberships();
            return Ok(memberships);
        }

        [HttpPost("Create")]
        public IActionResult Create([FromBody] CreateMembershipViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = membershipService.CreateMembership(model);
            if (result)
            {
                return Ok(new { message = "Membership created successfully" });
            }

            return BadRequest(new { message = "Membership can not be created" });
        }
        #endregion

        #region Cancel Membership
        [HttpDelete("Cancel/{id}")]
        public IActionResult Cancel(int id)
        {
            var result = membershipService.DeleteMembership(id);

            if (result)
            {
                return Ok(new { message = "Membership deleted successfully" });
            }

            return BadRequest(new { message = "Membership can not be deleted" });
        }
        #endregion


        #region Helper Method

        [HttpGet("Dropdowns")]
        public IActionResult GetDropdowns()
        {
            var members = membershipService.GetMembersForDropDown();
            var plans = membershipService.GetPlansForDropDown();

            return Ok(new { Members = members, Plans = plans });
        }

        #endregion
    }
}
