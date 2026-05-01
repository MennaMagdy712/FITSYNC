using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Entites
{
    public class Membership : BaseEntity
    {
        public int MemberId { get; set; }
        public Member Member { get; set; }
        public int PlanId { get; set; }
        public Plan Plan { get; set; }
        //StartDate=CreatedAt Column Exsited in BaseEntity
        public DateTime EndDate { get; set; }
        public string Status
        {
            get
            {
                if (DateTime.Now >= EndDate)
                {
                    return "Expired !";
                }
                else
                {
                    return "Active";
                }
            }
        }

    }
}
