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
    public class MemberSessionConfiguration : IEntityTypeConfiguration<MemberSession>
    {
        public void Configure(EntityTypeBuilder<MemberSession> builder)
        {
            builder.HasKey(ms => new { ms.MemberId, ms.SessionId });
            builder.Ignore(ms => ms.Id);
            builder.Property(X => X.CreatedAt)
                .HasDefaultValueSql("GETDATE()")
                .HasColumnName("BookingDate");
        }
    }
}
