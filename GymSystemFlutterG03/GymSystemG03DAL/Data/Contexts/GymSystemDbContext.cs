using GymSystemG03DAL.Entites;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Data.Contexts
{
    public class GymSystemDbContext : IdentityDbContext<ApplicationUser>

    {

        public GymSystemDbContext(DbContextOptions<GymSystemDbContext> options) : base(options)
        {

        }
        //protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        //{
        //    optionsBuilder.UseSqlServer("Server=DESKTOP-FEEG6OD\\SQLEXPRESS01;Database=GymSystemG02;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True");
        //}
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            //lazem el tarteb 34an byfr2 lazem el awl base configuration w b3dien y3ml configuration el ana 3mltha 
            base.OnModelCreating(modelBuilder);
            modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
            modelBuilder.Entity<ApplicationUser>(AU =>
            {
                AU.Property(X => X.FirstName)
                .HasColumnType("varchar")
                .HasMaxLength(50);

                AU.Property(X => X.LastName)
               .HasColumnType("varchar")
               .HasMaxLength(50);
            });
        }
        #region Tables
        public DbSet<ApplicationUser> Users { get; set; }
        public DbSet<IdentityRole> Roles { get; set; }
        //for relation many to many between users and roles
        public DbSet<IdentityUserRole<string>> UsersRoles { get; set; }
        public DbSet<Member> Members { get; set; }
        public DbSet<HealthRecord> HealthRecords { get; set; }
        public DbSet<Trainer> Trainers { get; set; }
        public DbSet<Plan> Plans { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Session> Sessions { get; set; }
        public DbSet<Membership> Memberships { get; set; }
        public DbSet<MemberSession> MemberSessions { get; set; }

        //startup project=> gymsystempl
        //default project=> gymsystemg02dal(from package manager console)
        #endregion
    }
}
