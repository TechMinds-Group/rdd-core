using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Catalogo.Data.Migrations
{
    // ATENÇÃO: migração escrita à mão sem [DbContext] e sem [Migration] —
    // silenciosamente ignorada pela descoberta do EF Core.
    public partial class AddOutboxEvents : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "OutboxEvents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false),
                    Tipo = table.Column<string>(type: "text", nullable: false),
                    Payload = table.Column<string>(type: "jsonb", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OutboxEvents", x => x.Id);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "OutboxEvents");
        }
    }
}
