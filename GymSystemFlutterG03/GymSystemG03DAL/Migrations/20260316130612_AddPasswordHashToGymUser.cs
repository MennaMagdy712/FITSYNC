using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GymSystemG03DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddPasswordHashToGymUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PasswordHash",
                table: "Trainers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PasswordHash",
                table: "Members",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PasswordHash",
                table: "Trainers");

            migrationBuilder.DropColumn(
                name: "PasswordHash",
                table: "Members");
        }
    }
}
