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
    public class GymUserConfigurations<T> : IEntityTypeConfiguration<T> where T : GymUser
    {
        public void Configure(EntityTypeBuilder<T> builder)
        {
            builder.Property(X => X.Name)
                 .HasColumnType("varchar")
                 .HasMaxLength(50);

            builder.Property(X => X.Email)
               .HasColumnType("varchar")
               .HasMaxLength(100);

            builder.Property(X => X.Phone)
                .HasColumnType("varchar")
                .HasMaxLength(100);

            builder.ToTable(Tb =>
            {
                //Menna@gmail.com
                Tb.HasCheckConstraint("GymUserVaildEmailCheck", "Email LIKE '_%@_%._%'");
                Tb.HasCheckConstraint("GymUserVaildPhoneCheck", "Phone LIKE '01%' AND Phone NOT LIKE '%[^0-9]%'");
            });
            builder.HasIndex(X => X.Email).IsUnique();
            builder.HasIndex(X => X.Phone).IsUnique();

            builder.OwnsOne(X => X.Address, address =>
            {

                address.Property(a => a.Street)
                .HasColumnName("Street")
                .HasColumnType("varchar")
                .HasMaxLength(30);
                address.Property(a => a.City)
               .HasColumnName("City")
                .HasColumnType("varchar")
                .HasMaxLength(30);
            });

        }
    }
}
