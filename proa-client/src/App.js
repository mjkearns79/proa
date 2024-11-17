import './app.css';
import React, { useState, useEffect, useRef } from 'react';
import { GoogleMap, LoadScript, Marker, InfoWindow } from '@react-google-maps/api';

function App() {
  const [weatherStations, setWeatherStations] = useState([]);
  const [filteredStations, setFilteredStations] = useState([]);
  const [selectedStation, setSelectedStation] = useState(null);
  const [selectedState, setSelectedState] = useState('');
  const mapRef = useRef(null);

  const [mapCenter, setMapCenter] = useState({
    lat: -25.2744,
    lng: 133.7751,
  });

  useEffect(() => {
    fetch('https://localhost:7100/api/weatherstations')
      .then(response => response.json())
      .then(data => {
        setWeatherStations(data);
        setFilteredStations(data);
      })
      .catch(error => console.error('Error fetching data:', error));
  }, []);

  const handleMarkerClick = (station) => {
    setSelectedStation(station);
    if (mapRef.current) {
      mapRef.current.panTo({ lat: station.latitude, lng: station.longitude });
    }
  };

  const handleStateChange = (event) => {
    const state = event.target.value;
    setSelectedState(state);
    setFilteredStations(state === '' ? weatherStations : weatherStations.filter(station => station.state === state));
  };

  const getIconClass = (type) => {
    switch (type?.toLowerCase()) {
      case 'solar':
        return 'fa-solar-panel';
      case 'wind':
        return 'fa-wind';
      case 'hub':
        return 'fa-cogs';
      default:
        return 'fa-question';
    }
  };

  const states = [...new Set(weatherStations.map(station => station.state))];

  return (
    <div style={{ position: 'relative' }}>
      {/* Filter dropdown positioned on the top-left */}
      <div className="filter-container">
        <label htmlFor="stateFilter"><strong>Filter by State:</strong></label>
        <select
          id="stateFilter"
          value={selectedState}
          onChange={handleStateChange}
          className="select-filter"
        >
          <option value="">All States</option>
          {states.map((state, index) => (
            <option key={index} value={state}>
              {state}
            </option>
          ))}
        </select>
      </div>

      <LoadScript googleMapsApiKey="AIzaSyAGxmjHtb5p5PC48xwV7HFWCFDewqWJMok">
        <GoogleMap
          mapContainerStyle={{ height: '100vh', width: '100%' }}
          zoom={5}
          center={mapCenter}
          onLoad={(map) => (mapRef.current = map)}
        >
          {filteredStations.map(station => (
            <Marker
              key={station.id}
              position={{ lat: station.latitude, lng: station.longitude }}
              onClick={() => handleMarkerClick(station)}
            />
          ))}

          {selectedStation && (
            <InfoWindow
              position={{ lat: selectedStation.latitude, lng: selectedStation.longitude }}
              onCloseClick={() => setSelectedStation(null)}
            >
              <div>
                <div className="flex-row info-panel">
                  <span>{selectedStation.wsName}</span>&nbsp;
                  <i className={`fa ${getIconClass(selectedStation.type)} fa-2x`}></i>
                </div>
                <p><strong>Site:</strong> {selectedStation.site}</p>
                <p><strong>Portfolio:</strong> {selectedStation.portfolio}</p>
                <p><strong>State:</strong> {selectedStation.state}</p>
                {selectedStation.latestMeasurements && selectedStation.latestMeasurements.map((measurement, index) => (
                  <div key={index}>
                    <p>
                      <strong>{measurement.variable.longName}</strong> {measurement.latestMeasurement.value}
                      &nbsp;{measurement.variable.unit}
                      <br />
                      <span className="timestamp">{new Date(measurement.latestMeasurement.timestamp).toLocaleString()}</span>
                    </p>
                  </div>
                ))}
              </div>
            </InfoWindow>
          )}
        </GoogleMap>
      </LoadScript>
    </div>
  );
}

export default App;
