using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CallTaxi.Services.Migrations
{
    /// <inheritdoc />
    public partial class NewStatuses : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "DriveRequests");

            migrationBuilder.AddColumn<int>(
                name: "StatusId",
                table: "DriveRequests",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "DriveRequestStatuses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriveRequestStatuses", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "DriveRequestStatuses",
                columns: new[] { "Id", "Description", "Name" },
                values: new object[,]
                {
                    { 1, "Request is waiting to be accepted by a driver", "Pending" },
                    { 2, "Request has been accepted by a driver", "Accepted" },
                    { 3, "Drive has been completed", "Completed" },
                    { 4, "Request has been cancelled", "Cancelled" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_DriveRequests_StatusId",
                table: "DriveRequests",
                column: "StatusId");

            migrationBuilder.AddForeignKey(
                name: "FK_DriveRequests_DriveRequestStatuses_StatusId",
                table: "DriveRequests",
                column: "StatusId",
                principalTable: "DriveRequestStatuses",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DriveRequests_DriveRequestStatuses_StatusId",
                table: "DriveRequests");

            migrationBuilder.DropTable(
                name: "DriveRequestStatuses");

            migrationBuilder.DropIndex(
                name: "IX_DriveRequests_StatusId",
                table: "DriveRequests");

            migrationBuilder.DropColumn(
                name: "StatusId",
                table: "DriveRequests");

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "DriveRequests",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
