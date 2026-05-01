using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Collections.Specialized.BitVector32;

namespace GymSystemG03DAL.Entites
{
    public class Category : BaseEntity
    {
        public string CategoryName { get; set; } = null!;
        #region 1:M Between sessioncategory
        public ICollection<Session> Sessions { get; set; }

        #endregion

    }
}
