using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.PlanViewModels;
using GymSystemG03DAL.Entites;
using GymSystemG03DAL.Repositroies.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Classes
{
    public class PlanService : IPlanService
    {
        private readonly IUnitOfWork _unitOfWork;

        public PlanService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public IEnumerable<PlanViewModel> GetAllPlans()
        {
            var Plans = _unitOfWork.GetRepository<Plan>().GetAll();
            if (Plans == null || !Plans.Any()) return [];
            return Plans.Select(p => new PlanViewModel
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                DurationDays = p.DurationDays,
                IsActive = p.IsActive
            });
        }

        public bool CreatePlan(CreatePlanViewModel newPlan)
        {
            try
            {
                var plan = new Plan
                {
                    Name = newPlan.Name,
                    Description = newPlan.Description,
                    Price = newPlan.Price,
                    DurationDays = newPlan.DurationDays,
                    IsActive = true, // By default active
                    CreatedAt = DateTime.Now
                };

                _unitOfWork.GetRepository<Plan>().Add(plan);
                return _unitOfWork.SaveChanges() > 0;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public PlanViewModel? GetPlanById(int id)
        {
            var Plan = _unitOfWork.GetRepository<Plan>().GetById(id);
            if (Plan is null) return null;
            return new PlanViewModel
            {
                Id = Plan.Id,
                Name = Plan.Name,
                Description = Plan.Description,
                Price = Plan.Price,
                DurationDays = Plan.DurationDays,
                IsActive = Plan.IsActive
            };
        }

        public UpdatePlanViewModel? GetPlanToUpdate(int PlanId)
        {
            var Plan = _unitOfWork.GetRepository<Plan>().GetById(PlanId);
            if (Plan is null || Plan.IsActive == false || HasActiveMembership(PlanId)) return null;
            return new UpdatePlanViewModel
            {
                PlanName = Plan.Name,
                Description = Plan.Description,
                Price = Plan.Price,
                DurationDays = Plan.DurationDays
            };
        }

        public bool ToggleStatus(int PlanId)
        {

            var Repo = _unitOfWork.GetRepository<Plan>();
            var Plan = Repo.GetById(PlanId);
            if (Plan is null || HasActiveMembership(PlanId)) return false;

            //if else
            Plan.IsActive = Plan.IsActive == true ? false : true;
            //==
            //if (plans.IsActive)
            //    plans.IsActive = false;
            //else
            //    plans.IsActive = true;
            Plan.UpdatedAt = DateTime.Now;
            try
            {
                Repo.Update(Plan);
                return _unitOfWork.SaveChanges() > 0;
            }
            catch (Exception)
            {

                return false;
            }
        }

        public bool UpdatePlan(int PlanId, UpdatePlanViewModel updatedPlan)
        {
            try
            {
                var Plan = _unitOfWork.GetRepository<Plan>().GetById(PlanId);
                if (Plan is null || HasActiveMembership(PlanId)) return false;

                (Plan.Description, Plan.Price, Plan.DurationDays, Plan.UpdatedAt)
                = (updatedPlan.Description, updatedPlan.Price, updatedPlan.DurationDays, DateTime.Now);

                _unitOfWork.GetRepository<Plan>().Update(Plan);
                return _unitOfWork.SaveChanges() > 0;
            }
            catch (Exception)
            {

                return false;
            }
        }


        #region Helper Methods
        private bool HasActiveMembership(int PlanId)
        {
            var ActiveMembership = _unitOfWork.GetRepository<Membership>()
                .GetAll(m => m.PlanId == PlanId && m.Status == "Active");
            return ActiveMembership.Any();
        }
        #endregion
    }
}
