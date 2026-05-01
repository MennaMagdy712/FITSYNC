using GymSystemG03DAL.Data.Contexts;
using GymSystemG03DAL.Entites;
using GymSystemG03DAL.Repositroies.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Repositroies.Classes
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly Dictionary<Type, object> _repositiores = new Dictionary<Type, object>();
        private readonly GymSystemDbContext _dbContext;

        public UnitOfWork(GymSystemDbContext dbContext, ISessionRepository sessionRepository,
            IMembershipRepository membershipRepository, IBookingRepository bookingRepository)
        {
            _dbContext = dbContext;
            SessionRepository = sessionRepository;
            MembershipRepository = membershipRepository;
            BookingRepository = bookingRepository;

        }
        public IMembershipRepository MembershipRepository { get; }

        public IBookingRepository BookingRepository { get; }
        public ISessionRepository SessionRepository { get; }

        public IGenericRepository<TEntity> GetRepository<TEntity>() where TEntity : BaseEntity, new()
        {
            var EntityType = typeof(TEntity);
            if (_repositiores.TryGetValue(EntityType, out var Repo))
                return (IGenericRepository<TEntity>)Repo;
            var newRepo = new GenericRepository<TEntity>(_dbContext);
            return newRepo;
        }

        public int SaveChanges()
        {
            return _dbContext.SaveChanges();
        }
    }
}
