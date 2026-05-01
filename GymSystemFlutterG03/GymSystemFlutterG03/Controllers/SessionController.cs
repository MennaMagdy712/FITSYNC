using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.SessionsViewModel;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")]
    public class SessionController : ControllerBase
    {
        private readonly ISessionService _sessionService;

        public SessionController(ISessionService sessionService)
        {
            _sessionService = sessionService;
        }
        #region Get All Sessions
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var sessions = _sessionService.GetAllSessions();
            return Ok(sessions);
        }
        #endregion

        #region Get Session Details
        [HttpGet("Details/{id}")]
        public IActionResult Details(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "Invalid session ID." });
            }
            var session = _sessionService.GetSessionById(id);
            if (session == null)
            {
                return NotFound(new { message = "Session not found." });
            }
            return Ok(session);
        }
        #endregion

        #region Create Session
        [HttpPost("Create")]
        public ActionResult Create([FromBody] CreateSessionViewModel CreatedSession)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var Result = _sessionService.CreateSession(CreatedSession);
            if (!Result)
            {
                return BadRequest(new { message = "Failed To Create Session" });
            }
            else
            {
                return Ok(new { message = "Session Created Successfully" });
            }
        }
        #endregion

        #region Edit Session
        [HttpGet("Edit/{id}")]
        public ActionResult Edit(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "Invalid Session Id" });
            }
            var Sessions = _sessionService.GetSessionToUpdate(id);
            if (Sessions is null)
            {
                return NotFound(new { message = "Session Not Found." });
            }
            return Ok(Sessions);
        }

        [HttpPut("Edit/{id}")]
        public ActionResult Edit([FromRoute] int id, [FromBody] UpdateSessionViewModel updatedSession)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();
                return BadRequest(new { message = "Validation failed", errors = errors });
            }
            
            var Result = _sessionService.UpdateSession(updatedSession, id);
            if (Result)
            {
                return Ok(new { message = "Session Updated Successfully." });
            }
            else
            {
                return BadRequest(new { 
                    message = "Failed to Update session",
                    details = "Session cannot be updated. Possible reasons: Session has already started, session has ended, or session has active bookings."
                });
            }
        }
        #endregion

        #region Delete Session
        //Delete 
        [HttpDelete("Delete/{id}")]
        public ActionResult DeleteConfirmed(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "Invalid Session Id." });
            }
            var sessions = _sessionService.GetSessionById(id);
            if (sessions == null)
            {
                return NotFound(new { message = "Session Not Found." });
            }

            var Result = _sessionService.RemoveSession(id);
            if (Result)
            {
                return Ok(new { message = "Session Deleted successfully." });
            }
            else
            {
                return BadRequest(new { message = "Failed to Delete session" });
            }
        }
        #endregion

        #region Helper Method

        [HttpGet("Dropdowns")]
        public IActionResult GetDropdowns()
        {
            var Trainers = _sessionService.GetTrainerForSession();
            var Categories = _sessionService.GetCategoryForSession();

            return Ok(new { Trainers = Trainers, Categories = Categories });
        }
        #endregion
    }
}
