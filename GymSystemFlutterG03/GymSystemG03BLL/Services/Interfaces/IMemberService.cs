using GymSystemG03BLL.ViewModels;
using GymSystemG03DAL.Entites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Interfaces
{
    public interface IMemberService
    {
        IEnumerable<MemberViewModel> GetAllMembers();
        bool CreateMembers(CreateMemberViewModel createMember);
        MemberViewModel? GetMemberDetails(int MemberId);

        //get health record
        HealthViewModel? GetMemberHealthRecordDetails(int MemberId);

        //Update Member Data
        bool UpdateMemberDetails(int id, MemberToUpdateViewModel updatedMember);

        //get member to update view model
        MemberToUpdateViewModel? GetMemberToUpdate(int MemberId);

        //Delete Member
        bool RemoveMember(int MemberId);

        // Member Portal (login + self-service)
        Member? GetMemberByEmail(string email);
        MemberHomeViewModel? GetMemberHomeData(int memberId);
        IEnumerable<object> GetMemberSessions(int memberId);
    }
}
