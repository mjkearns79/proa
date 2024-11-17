namespace ProaServer.Models
{
    public class WeatherStation
    {
        public int Id { get; set; }
        public string WsName { get; set; }
        public string Site { get; set; }
        public string Portfolio { get; set; }
        public string State { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }
}

