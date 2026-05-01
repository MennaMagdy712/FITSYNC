using GymSystemG03BLL.ViewModels.SessionsViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Interfaces
{
    public interface ISessionService
    {
        // Get all sessions
        IEnumerable<SessionViewModel> GetAllSessions();

        SessionViewModel? GetSessionById(int sessionId);

        //Create Session
        bool CreateSession(CreateSessionViewModel createSession);
        //Update Session
        bool UpdateSession(UpdateSessionViewModel updatedSession, int SessionId);

        UpdateSessionViewModel? GetSessionToUpdate(int sessionId);
        //Delete Session
        bool RemoveSession(int sessionId);

        IEnumerable<TrainerSelectViewModel> GetTrainerForSession();

        IEnumerable<CategorySelectViewModel> GetCategoryForSession();

    }
}
