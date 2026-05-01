using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.AttachmentService
{
    public interface IAttachmentService
    {
        //Upload photo and return the Photo name of the uploaded photo
        string Upload(string folderName, IFormFile file);

        //Delete The photo 
        bool Delete(string fileName, string folderName);
    }
}
