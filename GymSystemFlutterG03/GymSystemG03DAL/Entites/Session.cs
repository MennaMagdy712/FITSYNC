using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Entites
{
    public class Session : BaseEntity
    {
        public string Description { get; set; } = null!;
        public int Capacity { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        #region 1-M RS between Session and Catagory
        public int CategoryId { get; set; }
        public Category SessionCategory { get; set; }//one
        #endregion
        #region 1-M RS between session and trainer
        public int TrainerId { get; set; }
        public Trainer SessionTrainer { get; set; }
        #endregion
        #region M:M between member and session
        public ICollection<MemberSession> SessionMembers { get; set; }
        #endregion

    }
}
