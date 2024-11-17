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
                ws.Longitude
            }).ToListAsync();

            return Ok(weatherStations);
        }
    }
}
