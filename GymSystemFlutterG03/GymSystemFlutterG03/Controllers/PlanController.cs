using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.PlanViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GymSystemFlutterG03.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "SuperAdmin")]
    public class PlanController : ControllerBase
    {
        private readonly IPlanService _planService;

        public PlanController(IPlanService planService)
        {
            _planService = planService;
        }

        #region Get All Plans
        [HttpGet("Index")]
        public IActionResult Index()
        {
            var Plans = _planService.GetAllPlans();
            return Ok(Plans);
        }
        #endregion

        #region Create Plan
        [HttpPost("Create")]
        public ActionResult Create([FromBody] CreatePlanViewModel newPlan)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var Result = _planService.CreatePlan(newPlan);
            if (!Result)
            {
                return BadRequest(new { message = "Failed To Create Plan!" });
            }
            return Ok(new { message = "Plan Created Successfully!" });
        }
        #endregion

        #region Get Plan Details
        [HttpGet("Details/{id}")]
        public ActionResult Details(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Can't Be Zero Or Negative Number" });
            }

            var Plan = _planService.GetPlanById(id);
            if (Plan is null)
            {
                return NotFound(new { message = "Plan Not Found" });
            }
            return Ok(Plan);
        }
        #endregion

        #region Edit Plan
        [HttpGet("Edit/{id}")]
        public ActionResult Edit(int id)
        {
            if (id <= 0)
            {
                return BadRequest(new { message = "ID Can't Be Zero Or Negative Number" });
            }
            var Plan = _planService.GetPlanToUpdate(id);
            if (Plan == null)
            {
                return NotFound(new { message = "Plan Not Found Or Can't Be Updated" });
            }
            return Ok(Plan);
        }

        [HttpPut("Edit/{id}")]
        public ActionResult Edit([FromRoute] int id, [FromBody] UpdatePlanViewModel updatedPlan)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var Result = _planService.UpdatePlan(id, updatedPlan);
            if (!Result)
            {
                return BadRequest(new { message = "Failed To Update Plan!" });
            }
            return Ok(new { message = "Plan Updated Successfully!" });
        }
        #endregion

        #region Soft Delete Action (Toggle Delete)
        [HttpPut("Activate/{id}")]
        public ActionResult Activate(int id)
        {
            var Result = _planService.ToggleStatus(id);
            if (Result)
            {
                return Ok(new { message = "Plan Status Updated Successfully!" });
            }
            else
            {
                return BadRequest(new { message = "Failed To Update Plan Status!" });
            }
        }
        #endregion
    }
}
