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
    public class MembershipConfiguration : IEntityTypeConfiguration<Membership>
    {
        public void Configure(EntityTypeBuilder<Membership> builder)
        {
            builder.Property(X => X.CreatedAt)
               .HasColumnName("StartDate")
               .HasDefaultValueSql("GETDATE()");
            //composite primary key
            builder.HasKey(X => new { X.MemberId, X.PlanId });
            builder.Ignore(X => X.Id);
        }
    }
}
