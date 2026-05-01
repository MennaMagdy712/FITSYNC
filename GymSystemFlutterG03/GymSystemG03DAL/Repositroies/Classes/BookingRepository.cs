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
    public class BookingRepository : GenericRepository<MemberSession>, IBookingRepository
    {

        private readonly GymSystemDbContext _context;

        public BookingRepository(GymSystemDbContext context) : base(context)
        {
            _context = context;
        }

        public IEnumerable<MemberSession> GetSessionById(int sessionId)
        {
            return _context.MemberSessions.Where(ms => ms.SessionId == sessionId)
                                          .Include(ms => ms.Member)
                                          .ToList();

        }
    }
}
