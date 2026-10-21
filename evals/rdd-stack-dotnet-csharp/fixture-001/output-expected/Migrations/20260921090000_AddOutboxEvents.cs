using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Catalogo.Data.Migrations
{
    // Corrigida conforme convenção do playbook: atributos [DbContext] e [Migration]
    // obrigatórios para a descoberta do EF Core enxergar a migração.
    [DbContext(typeof(CatalogoDbContext))]
    [Migration("20260921090000_AddOutboxEvents")]
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
