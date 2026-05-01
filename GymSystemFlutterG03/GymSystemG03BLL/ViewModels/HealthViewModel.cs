using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.ViewModels
{
    public class HealthViewModel
    {

        [Required(ErrorMessage = "Height is required")]
        [Range(1, 300, ErrorMessage = "Height must be between 1 cm and 300 cm")]
        public decimal Height { get; set; }

        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Weight is required")]
        [Range(10, 500, ErrorMessage = "Weight must be between 10 kg and 500 kg")]
        public decimal Weight { get; set; }

        //----------------------------------------------------------------------------------------------

        [Required(ErrorMessage = "Blood Type is Required")]
        [StringLength(3, MinimumLength = 0, ErrorMessage = "Blood Type must be 3 Chars or Less")]
        [RegularExpression(@"^(A|B|AB|O)[+-]$", ErrorMessage = "Invalid Blood Type. Valid types are A+, A-, B+, B-, AB+, AB-, O+, O-")]
        public String BloodType { get; set; }

        //----------------------------------------------------------------------------------------------

        public string? Note { get; set; }
    }
}
