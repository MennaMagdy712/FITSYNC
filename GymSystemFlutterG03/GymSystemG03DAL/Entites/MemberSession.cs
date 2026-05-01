using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Collections.Specialized.BitVector32;

namespace GymSystemG03DAL.Entites
{
    public class MemberSession : BaseEntity
    {
        public int MemberId { get; set; }
        public Member Member { get; set; }
        public int SessionId { get; set; }
        public Session Session { get; set; }

        //BookingDate=CreatedAt Column Exsited in BaseEntity
        public bool IsAttend { get; set; }

    }
}
