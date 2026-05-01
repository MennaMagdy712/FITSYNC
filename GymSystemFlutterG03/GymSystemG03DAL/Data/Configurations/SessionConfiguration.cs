using GymSystemG03DAL.Entites;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Data.Configurations
{
    public class SessionConfiguration : IEntityTypeConfiguration<Session>
    {
        public void Configure(EntityTypeBuilder<Session> builder)
        {

            builder.ToTable(Tb =>
            {
                Tb.HasCheckConstraint("SessionCapacityCheck", "Capacity Between 1 and 25");
                Tb.HasCheckConstraint("SessionEndDateCheck", "EndDate > StartDate");
            });
            #region 1-M RS between Session and Catagory
            builder.HasOne(s => s.SessionCategory)
                .WithMany(c => c.Sessions)
                .HasForeignKey(s => s.CategoryId);

            #endregion
            #region  1-M RS between Session and Trainer
            builder.HasOne(s => s.SessionTrainer)
                .WithMany(t => t.TrainerSessions)
                .HasForeignKey(s => s.TrainerId);
            #endregion
        }
    }
}
