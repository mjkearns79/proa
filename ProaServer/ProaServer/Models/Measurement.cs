namespace ProaServer.Models
{
    public class Measurement
    {
        public int Id { get; set; }
        public int WeatherStationId { get; set; }
        public int VarId { get; set; }
        public double Value { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
