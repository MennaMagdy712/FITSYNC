using BCrypt.Net;
using GymSystemG03BLL.Services.AttachmentService;
using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels;
using GymSystemG03DAL.Entites;
using GymSystemG03DAL.Repositroies.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Classes
{
    public class MemberService : IMemberService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAttachmentService attachmentService;

        public MemberService(IUnitOfWork unitOfWork, IAttachmentService attachmentService)
        {
            _unitOfWork = unitOfWork;
            this.attachmentService = attachmentService;
        }


        //bool method to create member and return true if created successfully and false if not created
        public bool CreateMembers(CreateMemberViewModel createdMember)
        {
            //check if phone and email are unique 
            try
            {
                if (IsEmailExist(createdMember.Email) || IsPhoneExist(createdMember.Phone)) return false;

                var PhotoName = attachmentService.Upload("members", createdMember.PhotoFile);

                if (string.IsNullOrEmpty(PhotoName)) return false;

                var member = new Member()
                {
                    Name = createdMember.Name,
                    Phone = createdMember.Phone,
                    Email = createdMember.Email,
                    Gender = createdMember.Gender,
                    DateOfBirth = createdMember.DateOfBirth,
                    Address = new Address()
                    {
                        BuildingNumber = createdMember.BuildingNumber,
                        Street = createdMember.Street,
                        City = createdMember.City
                    },
                    HealthRecord = new HealthRecord()
                    {
                        Height = createdMember.HealthViewModel.Height,
                        Weight = createdMember.HealthViewModel.Weight,
                        BloodType = createdMember.HealthViewModel.BloodType,
                        Note = createdMember.HealthViewModel.Note
                    }
                };
                member.Photo = PhotoName;
                // Hash the password set by Admin
                if (!string.IsNullOrEmpty(createdMember.Password))
                {
                    member.PasswordHash = BCrypt.Net.BCrypt.HashPassword(createdMember.Password);
                }
                _unitOfWork.GetRepository<Member>().Add(member);

                var IsCreated = _unitOfWork.SaveChanges() > 0;
                if (!IsCreated)
                {
                    //delete the uploaded photo if member not created
                    attachmentService.Delete(PhotoName, "members");
                    return false;
                }
                else
                {
                    return true;
                }

            }
            catch (Exception)
            {

                return false;
            }
        }

        public IEnumerable<MemberViewModel> GetAllMembers()
        {
            var Members = _unitOfWork.GetRepository<Member>().GetAll() ?? [];
            var MemberViewModels = Members.Select(m => new MemberViewModel
            {
                Id = m.Id,
                Photo = m.Photo,
                Name = m.Name,
                Phone = m.Phone,
                Email = m.Email,
                Gender = m.Gender.ToString(),
                DateOfBirth = m.DateOfBirth.ToShortDateString(),
                Address = $"{m.Address.BuildingNumber} {m.Address.Street}, {m.Address.City}"
            });
            return MemberViewModels;
        }

        public MemberViewModel? GetMemberDetails(int MemberId)
        {
            var Member = _unitOfWork.GetRepository<Member>().GetById(MemberId);
            if (Member == null) return null;
            var ViewModel = new MemberViewModel
            {

                Name = Member.Name,
                Phone = Member.Phone,
                Email = Member.Email,
                Photo = Member.Photo,
                Gender = Member.Gender.ToString(),
                DateOfBirth = Member.DateOfBirth.ToShortDateString(),
                Address = $"{Member.Address.BuildingNumber}-{Member.Address.Street}-{Member.Address.City}",

            };
            var ActiveMembership = _unitOfWork.GetRepository<Membership>().GetAll(m => m.MemberId == MemberId && m.Status == "Active").FirstOrDefault();
            if (ActiveMembership != null)
            {
                //if there is active membership get the plan name and start and end date of the membership
                ViewModel.MemberShipStartDate = ActiveMembership.CreatedAt.ToShortDateString();
                ViewModel.MemberShipEndDate = ActiveMembership.EndDate.ToShortDateString();
                //get the plan name
                var Plan = _unitOfWork.GetRepository<Plan>().GetById(ActiveMembership.PlanId);
                ViewModel.PlanName = Plan?.Name;
            }
            return ViewModel;
        }


        public HealthViewModel? GetMemberHealthRecordDetails(int MemberId)
        {
            var MemberHealthRecord = _unitOfWork.GetRepository<HealthRecord>().GetById(MemberId);
            if (MemberHealthRecord == null) return null;
            return new HealthViewModel
            {
                Height = MemberHealthRecord.Height,
                Weight = MemberHealthRecord.Weight,
                BloodType = MemberHealthRecord.BloodType,
                Note = MemberHealthRecord.Note
            };
        }

        public MemberToUpdateViewModel? GetMemberToUpdate(int MemberId)
        {
            //form for user
            var Member = _unitOfWork.GetRepository<Member>().GetById(MemberId);
            if (Member is null) return null;
            return new MemberToUpdateViewModel()
            {
                Email = Member.Email,
                Phone = Member.Phone,
                Photo = Member.Photo,
                Name = Member.Name,
                BuildingNumber = Member.Address.BuildingNumber,
                Street = Member.Address.Street,
                City = Member.Address.City

            };
        }

        public bool RemoveMember(int MemberId)
        {
            var MemberRepo = _unitOfWork.GetRepository<Member>();
            var MemberSessionRepo = _unitOfWork.GetRepository<MemberSession>();
            var MemberShipRepo = _unitOfWork.GetRepository<Membership>();

            var Member = MemberRepo.GetById(MemberId);
            if (Member is null) return false;
            //check is member has active session or not
            //if have book session not delete it 
            //var HasActiveMemberSessions=
            //  MemberSessionRepo.GetAll(X=>X.MemberId==MemberId&& X.Session.StartDate>DateTime.Now).Any();

            //bring all session id of member to delete it after delete member because of foreign key constraint
            var SessionIDs = _unitOfWork.GetRepository<MemberSession>()
                .GetAll(X => X.MemberId == MemberId).Select(X => X.SessionId).ToList();

            var HasActiveSession = _unitOfWork.GetRepository<Session>()
                .GetAll(X => SessionIDs.Contains(X.Id) && X.StartDate > DateTime.Now).Any();
            if (HasActiveSession) return false;

            var Membership = MemberShipRepo.GetAll(X => X.MemberId == MemberId);
            try
            {
                if (Membership.Any())
                {
                    foreach (var member in Membership)
                    {
                        MemberShipRepo.Delete(member);
                    }
                }
                MemberRepo.Delete(Member);
                var IsDeleted = _unitOfWork.SaveChanges() > 0;
                if (IsDeleted)
                {
                    //delete the photo of the member after delete the member
                    attachmentService.Delete(Member.Photo, "members");
                }
                return IsDeleted;
            }
            catch (Exception)
            {

                return false;
            }

        }

        //for actual update
        public bool UpdateMemberDetails(int id, MemberToUpdateViewModel updatedMember)
        {
            try
            {
                var MemberRepo = _unitOfWork.GetRepository<Member>();

                //if (IsEmailExist(updatedMember.Email) || IsPhoneExist(updatedMember.Phone)) return false;

                //if email of user is not updated and exist in database return true
                //because there is no change in email but if email is updated and exist in database return false because email must be unique
                var emailExist = _unitOfWork.GetRepository<Member>()
                    .GetAll(m => m.Email == updatedMember.Email && m.Id != id).Any();

                var phoneExist = _unitOfWork.GetRepository<Member>()
               .GetAll(m => m.Phone == updatedMember.Phone && m.Id != id).Any();

                if (emailExist || phoneExist) return false;
                var Member = MemberRepo.GetById(id);
                if (Member is null) return false;

                Member.Email = updatedMember.Email;
                Member.Phone = updatedMember.Phone;
                Member.Address.BuildingNumber = updatedMember.BuildingNumber;
                Member.Address.City = updatedMember.City;
                Member.Address.Street = updatedMember.Street;
                Member.UpdatedAt = DateTime.Now;
                MemberRepo.Update(Member);
                return _unitOfWork.SaveChanges() > 0;

            }
            catch (Exception)
            {

                return false;
            }
        }
        #region Helper Methods
        private bool IsEmailExist(string email)
        {
            return _unitOfWork.GetRepository<Member>().GetAll(m => m.Email == email).Any();
        }
        private bool IsPhoneExist(string phone)
        {
            return _unitOfWork.GetRepository<Member>().GetAll(m => m.Phone == phone).Any();
        }
        #endregion

        #region Member Portal Methods

        public Member? GetMemberByEmail(string email)
        {
            return _unitOfWork.GetRepository<Member>().GetAll(m => m.Email == email).FirstOrDefault();
        }

        public MemberHomeViewModel? GetMemberHomeData(int memberId)
        {
            var member = _unitOfWork.GetRepository<Member>().GetById(memberId);
            if (member == null) return null;

            var homeVM = new MemberHomeViewModel
            {
                Id = member.Id,
                Name = member.Name,
                Photo = member.Photo
            };

            // Get active membership and plan
            var activeMembership = _unitOfWork.GetRepository<Membership>()
                .GetAll(m => m.MemberId == memberId && m.Status == "Active")
                .FirstOrDefault();

            if (activeMembership != null)
            {
                homeVM.MemberShipEndDate = activeMembership.EndDate.ToShortDateString();
                var plan = _unitOfWork.GetRepository<Plan>().GetById(activeMembership.PlanId);
                homeVM.PlanName = plan?.Name;
            }

            // Count upcoming sessions
            var sessionIds = _unitOfWork.GetRepository<MemberSession>()
                .GetAll(ms => ms.MemberId == memberId)
                .Select(ms => ms.SessionId)
                .ToList();

            homeVM.UpcomingSessionsCount = _unitOfWork.GetRepository<Session>()
                .GetAll(s => sessionIds.Contains(s.Id) && s.StartDate > DateTime.Now)
                .Count();

            return homeVM;
        }

        public IEnumerable<object> GetMemberSessions(int memberId)
        {
            var sessionIds = _unitOfWork.GetRepository<MemberSession>()
                .GetAll(ms => ms.MemberId == memberId)
                .Select(ms => ms.SessionId)
                .ToList();

            var sessions = _unitOfWork.GetRepository<Session>()
                .GetAll(s => sessionIds.Contains(s.Id))
                .Select(s => new
                {
                    s.Id,
                    s.Description,
                    StartDate = s.StartDate.ToString("yyyy-MM-dd HH:mm"),
                    EndDate = s.EndDate.ToString("yyyy-MM-dd HH:mm"),
                    s.Capacity
                })
                .ToList<object>();

            return sessions;
        }

        #endregion
    }
}
