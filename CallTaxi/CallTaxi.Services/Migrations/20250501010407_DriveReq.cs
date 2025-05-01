using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CallTaxi.Services.Migrations
{
    /// <inheritdoc />
    public partial class DriveReq : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DriveRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    VehicleTierId = table.Column<int>(type: "int", nullable: false),
                    StartLocation = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    EndLocation = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    BasePrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    FinalPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AcceptedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriveRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DriveRequests_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_DriveRequests_VehicleTiers_VehicleTierId",
                        column: x => x.VehicleTierId,
                        principalTable: "VehicleTiers",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_DriveRequests_UserId",
                table: "DriveRequests",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_DriveRequests_VehicleTierId",
                table: "DriveRequests",
                column: "VehicleTierId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DriveRequests");
        }
    }
}
