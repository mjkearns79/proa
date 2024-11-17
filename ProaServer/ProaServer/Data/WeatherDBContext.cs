using Microsoft.EntityFrameworkCore;
using ProaServer.Models;

namespace ProaServer.Data
{
    public class WeatherDbContext : DbContext
    {
        public DbSet<WeatherStation> WeatherStations { get; set; }
        public DbSet<Variable> Variables { get; set; }
        public DbSet<Measurement> Measurements { get; set; }
        
        public WeatherDbContext(DbContextOptions<WeatherDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<WeatherStation>().HasKey(ws => ws.Id);
            modelBuilder.Entity<Variable>().HasKey(v => v.VarId);
            modelBuilder.Entity<Measurement>().HasKey(m => m.Id);

            modelBuilder.Entity<Variable>()
                .HasOne<WeatherStation>()
                .WithMany()
                .HasForeignKey(v => v.WeatherStationId);

            modelBuilder.Entity<Measurement>()
                .HasOne<WeatherStation>()
                .WithMany()
                .HasForeignKey(m => m.WeatherStationId);

            modelBuilder.Entity<Measurement>()
                .HasOne<Variable>()
                .WithMany()
                .HasForeignKey(m => m.VarId);
        }
    }
}
