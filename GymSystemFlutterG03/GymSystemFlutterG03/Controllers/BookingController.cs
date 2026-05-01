using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.BookingViewModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")]
    public class BookingController(IBookingService bookingService) : ControllerBase
    {
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var sessions = bookingService.GetAllSessionsWithTrainerAndCategory();
            return Ok(sessions);
        }

        [HttpGet("GetMembersForUpcomingSession/{id}")]
        public IActionResult GetMembersForUpcomingSession(int id)
        {
            var members = bookingService.GetAllMembersForUpcomingSession(id);
            return Ok(members);
        }

        [HttpGet("GetMembersForOngoingSession/{id}")]
        public IActionResult GetMembersForOngoingSession(int id)
        {
            var members = bookingService.GetAllMembersForOngoingSession(id);
            return Ok(members);
        }

        [HttpGet("Create/{id}")]
        public IActionResult Create(int id)
        {
            var members = bookingService.GetMembersForDropdown(id);
            return Ok(members);
        }

        [HttpPost("Create")]
        public IActionResult Create([FromBody] CreateBookingViewModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = bookingService.CreateBooking(model);
            if (result)
            {
                return Ok(new { message = "Booking Created successfully!" });
            }
            return BadRequest(new { message = "Failed to Create Booking." });
        }

        [HttpPost("Attended")]
        public IActionResult Attended([FromBody] MemberAttendOrCancelViewModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = bookingService.MemberAttended(model);

            if (result)
                return Ok(new { message = "Member attended successfully" });

            return BadRequest(new { message = "Member attendance can't be marked" });
        }

        [HttpPost("Cancel")]
        public IActionResult Cancel([FromBody] MemberAttendOrCancelViewModel model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = bookingService.CancelBooking(model);

            if (result)
                return Ok(new { message = "Booking cancelled successfully" });

            return BadRequest(new { message = "Booking can't be cancelled" });
        }

    }
}
