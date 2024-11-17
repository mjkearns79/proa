using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProaServer.Data;

namespace ProaServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WeatherStationsController : ControllerBase
    {
        private readonly WeatherDbContext _context;

        public WeatherStationsController(WeatherDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetWeatherStations()
        {
            var weatherStations = await _context.WeatherStations.Select(ws => new
            {
                ws.Id,
                ws.WsName,
                ws.Site,
                ws.Portfolio,
                ws.State,
                ws.Latitude,
                ws.Longitude,
                Type = GetStationType(ws.Site)
            }).ToListAsync();

            return Ok(weatherStations);
        }

        private static string GetStationType(string site)
        {
            if (site.ToLower().Contains("solar"))
            {
                return "Solar";
            }
            else if (site.ToLower().Contains("wind"))
            {
                return "Wind";
            }
            else if (site.ToLower().Contains("hub"))
            {
                return "Hub";
            }
            else
            {
                return "Other";
            }
        }
    }
}
