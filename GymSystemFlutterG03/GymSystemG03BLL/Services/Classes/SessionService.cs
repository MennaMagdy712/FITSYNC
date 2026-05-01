using AutoMapper;
using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.SessionsViewModel;
using GymSystemG03DAL.Entites;
using GymSystemG03DAL.Repositroies.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Classes
{
    public class SessionService : ISessionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public SessionService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public bool CreateSession(CreateSessionViewModel createSession)
        {
            try
            {
                if (!IsTrainerExis(createSession.TrainerId)) return false;
                if (!IsCatagoryExis(createSession.CategoryId)) return false;
                if (!IsDateTimeValid(createSession.StartDate, createSession.EndDate)) return false;
                if (createSession.Capacity > 25 || createSession.Capacity < 0) return false;

                var SessionEntity = _mapper.Map<Session>(createSession);
                _unitOfWork.GetRepository<Session>().Add(SessionEntity);
                return _unitOfWork.SaveChanges() > 0;
            }
            catch (Exception)
            {

                return false;
            }
        }

        public IEnumerable<SessionViewModel> GetAllSessions()
        {
            // var Sessions=_unitOfWork.GetRepository<Session>().GetAll();
            var Sessions = _unitOfWork.SessionRepository.GetAllSessionsWithTrainerAndCategory();
            if (!Sessions.Any()) return [];

            return Sessions.Select(s => new SessionViewModel
            {
                Id = s.Id,
                Description = s.Description,
                StartDate = s.StartDate,
                EndDate = s.EndDate,
                Capacity = s.Capacity,
                TrainerName = s.SessionTrainer.Name,
                CategoryName = s.SessionCategory.CategoryName,
                AvailableSlot = s.Capacity - _unitOfWork.SessionRepository.GetCountOfBookedSlots(s.Id)
            });
        }

        public SessionViewModel? GetSessionById(int sessionId)
        {
            var Session = _unitOfWork.SessionRepository.GetSessionWithTrainerAndCategory(sessionId);
            if (Session == null) return null;

            //allow automapper
            var MappedSession = _mapper.Map<Session, SessionViewModel>(Session);
            MappedSession.AvailableSlot = MappedSession.Capacity - _unitOfWork.SessionRepository.GetCountOfBookedSlots(MappedSession.Id);
            return MappedSession;

        }
        public bool UpdateSession(UpdateSessionViewModel updatedSession, int SessionId)
        {
            try
            {
                var Session = _unitOfWork.SessionRepository.GetById(SessionId);
                
                if (Session is null)
                {
                    Console.WriteLine($"❌ UpdateSession failed: Session {SessionId} not found");
                    return false;
                }
                
                if (!IsSessionAvaliableForUpdate(Session))
                {
                    Console.WriteLine($"❌ UpdateSession failed: Session {SessionId} is not available for update");
                    Console.WriteLine($"   - Session StartDate: {Session.StartDate}");
                    Console.WriteLine($"   - Session EndDate: {Session.EndDate}");
                    Console.WriteLine($"   - Current DateTime: {DateTime.Now}");
                    Console.WriteLine($"   - Has started: {Session.StartDate <= DateTime.Now}");
                    Console.WriteLine($"   - Has ended: {Session.EndDate < DateTime.Now}");
                    return false;
                }
                
                if (!IsTrainerExis(updatedSession.TrainerId))
                {
                    Console.WriteLine($"❌ UpdateSession failed: Trainer {updatedSession.TrainerId} does not exist");
                    return false;
                }
                
                if (!IsDateTimeValid(updatedSession.StartDate, updatedSession.EndDate))
                {
                    Console.WriteLine($"❌ UpdateSession failed: Invalid dates - StartDate must be before EndDate");
                    Console.WriteLine($"   - StartDate: {updatedSession.StartDate}");
                    Console.WriteLine($"   - EndDate: {updatedSession.EndDate}");
                    return false;
                }

                _mapper.Map(updatedSession, Session);
                Session.UpdatedAt = DateTime.Now;
                _unitOfWork.SessionRepository.Update(Session);
                var result = _unitOfWork.SaveChanges() > 0;
                
                if (result)
                {
                    Console.WriteLine($"✅ UpdateSession success: Session {SessionId} updated");
                }
                
                return result;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ UpdateSession exception: {ex.Message}");
                return false;
            }
        }

        public UpdateSessionViewModel? GetSessionToUpdate(int sessionId)
        {
            var Session = _unitOfWork.SessionRepository.GetById(sessionId);
            if (!IsSessionAvaliableForUpdate(Session!)) return null;

            return _mapper.Map<UpdateSessionViewModel>(Session);
        }

        public bool RemoveSession(int sessionId)
        {
            try
            {
                var Session = _unitOfWork.SessionRepository.GetById(sessionId);
                if (!IsSessionAvaliableForDelete(Session)) return false;

                _unitOfWork.SessionRepository.Delete(Session!);
                return _unitOfWork.SaveChanges() > 0;
            }
            catch (Exception)
            {

                return false;
            }
        }

        public IEnumerable<TrainerSelectViewModel> GetTrainerForSession()
        {
            var trainer = _unitOfWork.GetRepository<Trainer>().GetAll();
            return _mapper.Map<IEnumerable<TrainerSelectViewModel>>(trainer);
        }

        public IEnumerable<CategorySelectViewModel> GetCategoryForSession()
        {
            var category = _unitOfWork.GetRepository<Category>().GetAll();
            return _mapper.Map<IEnumerable<CategorySelectViewModel>>(category);
        }



        #region Helper Methos
        private bool IsTrainerExis(int TrainerId)
        {
            return _unitOfWork.GetRepository<Trainer>().GetById(TrainerId) is not null;
        }
        private bool IsCatagoryExis(int CatagoryId)
        {
            return _unitOfWork.GetRepository<Category>().GetById(CatagoryId) is not null;
        }
        private bool IsDateTimeValid(DateTime StartDate, DateTime EndDate)
        {
            return StartDate < EndDate;
        }

        private bool IsSessionAvaliableForUpdate(Session Session)
        {
            if (Session is null) return false;
            //Session completed => Canot be updated
            if (Session.EndDate < DateTime.Now) return false;
            //Session  started => Canot be updated
            if (Session.StartDate <= DateTime.Now) return false;
            //Session have active booking => Canot be updated
            var ActiveBooking = _unitOfWork.SessionRepository.GetCountOfBookedSlots(Session.Id) > 0;
            if (ActiveBooking) return false;

            return true;
        }



        private bool IsSessionAvaliableForDelete(Session session)
        {
            if (session is null) return false;
            ////Session completed => Can delete
            //if (session.EndDate < DateTime.Now) return false;
            //Session  started => Canot be delete
            if (session.StartDate > DateTime.Now) return false;

            if (session.StartDate <= DateTime.Now && session.EndDate > DateTime.Now) return false;
            //Session have active booking => Canot be delete
            var ActiveBooking = _unitOfWork.SessionRepository.GetCountOfBookedSlots(session.Id) > 0;
            if (ActiveBooking) return false;

            return true;
        }







        #endregion

    }
}
