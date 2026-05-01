using GymSystemG03DAL.Data.Contexts;
using GymSystemG03DAL.Entites;
using GymSystemG03DAL.Repositroies.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Repositroies.Classes
{
    public class MembershipRepository : GenericRepository<Membership>, IMembershipRepository
    {
        private readonly GymSystemDbContext _context;

        public MembershipRepository(GymSystemDbContext context) : base(context)
        {
            _context = context;
        }

        public IEnumerable<Membership> GetAllMembershipsWithMembersAndPlans(Func<Membership, bool>? filter = null)
        {
            var memberships = _context.Memberships.Include(m => m.Member).Include(m => m.Plan)
                            .Where(filter ?? (_ => true));

            return memberships;

        }

        public Membership? GetFirstOrDefault(Func<Membership, bool>? filter = null)
        {
            var membership = _context.Memberships.Include(m => m.Member).Include(m => m.Plan)
                            .FirstOrDefault(filter ?? (_ => true));
            return membership;
        }
    }
}
