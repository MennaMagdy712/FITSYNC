using GymSystemG03BLL.Services.Interfaces;
using GymSystemG03BLL.ViewModels.AccountViewModels;
using GymSystemG03DAL.Entites;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.Classes
{
    public class AccountService : IAccountService
    {
        private readonly UserManager<ApplicationUser> _userManager;

        public AccountService(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }
        public ApplicationUser? ValidateUser(LoginViewModel loginVM)
        {
            var User = _userManager.FindByEmailAsync(loginVM.Email).Result;
            if (User is null) return null;

            var isPassValid = _userManager.CheckPasswordAsync(User, loginVM.Password).Result;
            return isPassValid ? User : null;
        }
    }
}
