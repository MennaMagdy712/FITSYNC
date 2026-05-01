using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")]
    public class TrainerController : ControllerBase
    {
        private readonly ITrainerService _trainerService;

        //ask ctor to inject the service layer for members
        public TrainerController(ITrainerService trainerService)
        {
            _trainerService = trainerService;
        }//register for service in porgram

        #region Get All Trainer
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var trainer = _trainerService.GetAllTrainers();
            return Ok(trainer);
        }
        #endregion


        #region Get Member Details
        [HttpGet("Details/{id}")]
        public ActionResult TrainerDetails(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }

            var trainerDetails = _trainerService.GetTrainerDetails(id);
            if (trainerDetails == null)
            {
                return NotFound(new { message = "Trainer Not Found" });
            }
            return Ok(trainerDetails);
        }
        #endregion

        #region Create Trainer
        [HttpPost("Create")]
        public ActionResult CreateTrainer([FromBody] CreateTrainerViewModel createdTrainer)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            bool Result = _trainerService.CreateTrainer(createdTrainer);
            if (Result)
            {
                return Ok(new { message = "Trainer Created Successfully." });
            }
            else
            {
                return BadRequest(new { message = "Failed To Create Trainer." });
            }
        }
        #endregion


        #region Edit Trainer
        //add view
        [HttpGet("Edit/{id}")]
        public ActionResult TarinerEdit(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Cannot Be 0 Or Negative Number." });
            }
            var trainerToUpdate = _trainerService.GetTrainerToUpdate(id);
            if (trainerToUpdate == null)
            {
                return NotFound(new { message = "Trainer Not Found" });
            }
            return Ok(trainerToUpdate);
        }

        [HttpPut("Edit/{id}")]
        public ActionResult TarinerEdit([FromRoute] int id, [FromBody] TrainerToUpdateViewModel trainerToUpdate)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var Result = _trainerService.UpdateTrainerDetails(trainerToUpdate, id);
            if (Result)
            {
                return Ok(new { message = "Trainer Updated Successfully." });
            }
            else
            {
                return BadRequest(new { message = "Failed To Update Trainer." });
            }
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

            var Trainer = _trainerService.GetTrainerDetails(id);
            if (Trainer == null)
            {
                return NotFound(new { message = "Trainer Not Found" });
            }

            var Result = _trainerService.RemoveTrainer(id);
            if (Result)
            {
                return Ok(new { message = "Trainer Deleted Successfully." });
            }
            else
            {
                return BadRequest(new { message = "Failed To Delete Trainer." });
            }
        }


        #endregion
    }
}
