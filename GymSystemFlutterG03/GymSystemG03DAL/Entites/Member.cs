using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Entites
{
    public class Member : GymUser
    {
        //createdat at baseEntity class= JoinDate For Member=>by Configuraion
        public string Photo { get; set; }
        #region 1:1 RS Between member and health record 
        public HealthRecord HealthRecord { get; set; }
        #endregion
        #region M:M Between MemberPlan
        public ICollection<Membership> Memberships { get; set; }

        #endregion
        #region M:M between member and session
        public ICollection<MemberSession> MemberSessions { get; set; }
        #endregion
    }
}
