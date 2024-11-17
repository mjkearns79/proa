namespace ProaServer.Models
{
    public class Variable
    {
        public int VarId { get; set; }
        public int WeatherStationId { get; set; }
        public string Name { get; set; }
        public string Unit { get; set; }
        public string LongName { get; set; }
    }
}
