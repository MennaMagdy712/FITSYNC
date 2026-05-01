using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.ViewModels
{
    public class MemberToUpdateViewModel
    {
        public string Name { get; set; }
        public string? Photo { get; set; }
        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Phone is required")]
        [Phone(ErrorMessage = "Invalid phone number")]
        [DataType(DataType.PhoneNumber)]
        [RegularExpression(@"^(010|011|012|015)\d{8}$", ErrorMessage = "Phone number must be an Egyptian phone number")]
        public string Phone { get; set; }

        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid Email Format!")]
        [DataType(DataType.EmailAddress)]
        [StringLength(100, MinimumLength = 5, ErrorMessage = "Email must be between 5 and  100 characters")]
        public string Email { get; set; }

        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Address is required")]
        [Range(1, 9000, ErrorMessage = "Building  number must be between 1 and 9000")]
        public int BuildingNumber { get; set; }


        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Street is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Street must be between 2 and  100 characters")]
        public string Street { get; set; } = null!;

        //----------------------------------------------------------------------------------------------
        [Required(ErrorMessage = "City is required")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "City must be between 2 and  50 characters")]
        [RegularExpression(@"^[a-zA-Z\s]+$", ErrorMessage = "City can only contain letters and spaces")]

        public string City { get; set; } = null!;

        //-------------------------------------
    }
}
