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
    public class PlanConfiguration : IEntityTypeConfiguration<Plan>
    {
        public void Configure(EntityTypeBuilder<Plan> builder)
        {
            builder.Property(X => X.Name)
               .HasColumnType("varchar")
               .HasMaxLength(200);

            builder.Property(X => X.Description)
                .HasColumnType("varchar")
                .HasMaxLength(200);

            builder.Property(X => X.Price)
                .HasPrecision(10, 2);

            builder.ToTable(Tb => Tb.HasCheckConstraint("PlanDurationCheck", "DurationDays Between 1 and 365"));

        }
    }
}
