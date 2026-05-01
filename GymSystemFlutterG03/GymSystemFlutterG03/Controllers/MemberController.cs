using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")] // Only users with the "Admin" role can access this controller
    public class MemberController : ControllerBase
    {
        private readonly IMemberService _memberService;

        //ask ctor to inject the service layer for members
        public MemberController(IMemberService memberService)
        {
            _memberService = memberService;
        }//register for service in porgram

        #region Get All Members
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var members = _memberService.GetAllMembers();
            return Ok(members);
        }
        #endregion

        #region Get Member Details
        [HttpGet("Details/{id}")]
        public ActionResult MemberDetails(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }

            var memberDetails = _memberService.GetMemberDetails(id);
            if (memberDetails == null)
            {
                return NotFound(new { message = "Member Not Found" });
            }
            return Ok(memberDetails);
        }
        #endregion

        #region Get Health Record Details 
        [HttpGet("HealthRecord/{id}")]
        public ActionResult HealthRecordDetails(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }

            var healthRecord = _memberService.GetMemberHealthRecordDetails(id);
            if (healthRecord == null)
            {
                return NotFound(new { message = "Health Record Not Found" });
            }

            return Ok(healthRecord);
        }
        #endregion

        #region Create Member
        [HttpPost("Create")]
        [Consumes("multipart/form-data")]
        public ActionResult CreateMember([FromForm] CreateMemberViewModel CreatedMember)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            bool Result = _memberService.CreateMembers(CreatedMember);
            if (Result)
            {
                return Ok(new { message = "Member Created Successfully." });
            }
            return BadRequest(new { message = "Failed To Create Member." });
        }
        #endregion

        #region Edit Member
        [HttpGet("Edit/{id}")]
        public ActionResult MemberEdit(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }

            var memberToUpdate = _memberService.GetMemberToUpdate(id);
            if (memberToUpdate == null)
            {
                return NotFound(new { message = "Member Not Found" });
            }
            return Ok(memberToUpdate);
        }

        [HttpPut("Edit/{id}")]
        public ActionResult MemberEdit(int id, [FromBody] MemberToUpdateViewModel memberToUpdate)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var Result = _memberService.UpdateMemberDetails(id, memberToUpdate);
            if (Result)
            {
                return Ok(new { message = "Member Updated Successfully." });
            }
            return BadRequest(new { message = "Failed To Update Member." });
        }
        #endregion

        #region Delete member
        [HttpDelete("Delete/{id}")]
        public IActionResult DeleteConfirmed(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }

            var Member = _memberService.GetMemberDetails(id);
            if (Member == null)
            {
                return NotFound(new { message = "Member Not Found" });
            }

            var Result = _memberService.RemoveMember(id);
            if (Result)
            {
                return Ok(new { message = "Member Deleted Successfully." });
            }
            return BadRequest(new { message = "Failed To Delete Member. Please Make Sure That Member Does Not Have Active Sessions." });
        }


        #endregion
    }
}
