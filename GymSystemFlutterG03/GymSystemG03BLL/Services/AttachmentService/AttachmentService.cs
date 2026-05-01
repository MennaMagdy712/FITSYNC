using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL.Services.AttachmentService
{
    public class AttachmentService : IAttachmentService
    {
        //1.Check Extension
        private readonly string[] allowedExtension = { ".jpg", ".jpeg", ".png" };
        //2. Check Size
        private readonly long maxFileSize = 5 * 1024 * 1024; // 5MB

        public bool Delete(string fileName, string folderName)
        {
            try
            {
                //get path of the file 
                if (string.IsNullOrEmpty(fileName) || string.IsNullOrEmpty(folderName)) return false;

                var FullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images", folderName, fileName);

                //check if file exist
                if (File.Exists(FullPath))
                {
                    File.Delete(FullPath);
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed To Upload Photo:{ex}");
                return false;
            }
        }

        public string Upload(string folderName, IFormFile file)
        {
            try
            {
                //check foldername,filename is exist
                if (folderName is null || file is null || file.Length == 0) return null;
                if (file.Length > maxFileSize) return null;

                var ext = Path.GetExtension(file.FileName).ToLower();
                if (!allowedExtension.Contains(ext)) return null;
                //3.get located folder path
                var FolderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images", folderName);
                if (!Directory.Exists(FolderPath))
                {
                    Directory.CreateDirectory(FolderPath);
                }

                //4.Create unique file name
                //guid is a 128-bit integer that can be used to generate unique identifiers. 
                var FileName = Guid.NewGuid().ToString() + ext;

                //5.get file path
                var FilePath = Path.Combine(FolderPath, FileName);

                //6.stream file to the server
                using var FileStream = new FileStream(FilePath, FileMode.Create);

                //7.copy to stream
                file.CopyTo(FileStream);

                //8.return the file name to save in database
                return FileName;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed To Upload Photo:{ex}");
                return null;
            }
        }
    }
}
