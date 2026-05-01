using GymSystemG03DAL.Entites;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03DAL.Data.DataSeed
{

    public class IdentitydbContextSeeding
    {
        public static bool SeedData(RoleManager<IdentityRole> roleManager, UserManager<ApplicationUser> userManager)
        {
            try
            {
                var HasUsers = userManager.Users.Any();
                var HasRoles = roleManager.Roles.Any();
                if (HasUsers && HasRoles) return false;
                if (!HasRoles)
                {
                    var Roles = new List<IdentityRole>
                    {
                         new (){Name="SuperAdmin"},
                        new (){Name="Admin"},
                    };
                    foreach (var role in Roles)
                    {
                        if (!roleManager.RoleExistsAsync(role.Name!).Result)
                        {
                            roleManager.CreateAsync(role).Wait();
                        }
                    }
                }
                if (!HasUsers)
                {
                    var MainAdmin = new ApplicationUser
                    {
                        FirstName = "Menna",
                        LastName = "Magdy",
                        UserName = "MennaMagdy",
                        Email = "MennaMagdy802@gmail.com",
                        PhoneNumber = "01296455000"
                    };
                    userManager.CreateAsync(MainAdmin, "Menna@123").Wait();
                    userManager.AddToRoleAsync(MainAdmin, "SuperAdmin").Wait();

                    var Admin = new ApplicationUser
                    {
                        FirstName = "Malak",
                        LastName = "Magdy",
                        UserName = "MalakMagdy",
                        Email = "MalakMagdy802@gmail.com",
                        PhoneNumber = "01296455220"
                    };
                    userManager.CreateAsync(Admin, "Malak@123").Wait();
                    userManager.AddToRoleAsync(Admin, "SuperAdmin").Wait();
                }
                return true;
            }
            catch (Exception ex)
            {

                Console.WriteLine($"Seeding Failed : {ex}");
                return false;
            }
        }
    }
}
