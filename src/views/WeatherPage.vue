<template>
  <div class="container">
    <h1> ❆ Weather Forecast </h1>
    <form @submit.prevent="getWeather">
            <input v-model="city" placeholder="Enter city name" />
            <button type="submit">Get Weather</button>
        </form>
  
        <div v-if="loading">Loading....</div>
        <div v-if="error">! Error ! {{  error }}</div>

       <div v-if="weather">
        <table class="weather-table">
          <thead>
            <tr>
              <th>City / Country</th>
              <th>Temperature (°C)</th>
              <th>Feels Like (°C)</th>
              <th>Condition</th>
              <th>Humidity (%)</th>
              <th>Pressure (hPa)</th>
              <th>Wind</th>
              <th>Cloudiness (%)</th>
              <th>Visibility (m)</th>
              <th>Sunrise</th>
              <th>Sunset</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{{ weather.name }} ({{ weather.sys.country }})</td>
              <td>{{ weather.main.temp }}</td>
              <td>{{ weather.main.feels_like }}</td>
              <td>{{ capitalize(weather.weather[0].description) }}</td>
              <td>{{ weather.main.humidity }}</td>
              <td>{{ weather.main.pressure }}</td>
              <td>{{ weather.wind.speed }} m/s ({{ weather.wind.deg }}°)</td>
              <td>{{ weather.clouds.all }}</td>
              <td>{{ weather.visibility }}</td>
              <td>{{ new Date(weather.sys.sunrise * 1000).toLocaleTimeString() }}</td>
              <td>{{ new Date(weather.sys.sunset * 1000).toLocaleTimeString() }}</td>
            </tr>
          </tbody>
        </table>

        <button type="button" @click="getForecast">Today Forecast</button>
      </div>

        <div v-if="forecast">
            <ul class="forecast-list">
              <li v-for="(item, index) in forecast.list.slice(0, 8)" :key="index">
                <span class="time">{{ formatTime(item.dt_txt) }}</span>
                <span class="temp">{{ item.main.temp }} °C</span>
                <span class="desc">{{ capitalize(item.weather[0].description) }}</span>
              </li>
            </ul>
        </div>
    </div>
        <div v-if="country" class="country-details">
          <h2>About {{ country.name.common }}</h2>
          <img :src="country.flags.svg" :alt="country.name.common + ' flag'" width="100" />
          <p><strong>Official Name:</strong> {{ country.name.official }}</p>
          <p><strong>Region:</strong> {{ country.region }}</p>
          <p><strong>Subregion:</strong> {{ country.subregion }}</p>
          <p><strong>Capital:</strong> {{ country.capital[0] }}</p>
          <p><strong>Population:</strong> {{ country.population.toLocaleString() }}</p>
          <p><strong>Languages:</strong> {{ Object.values(country.languages).join(', ') }}</p>
          <p><strong>Currency:</strong> {{ Object.values(country.currencies)[0].name }} ({{ Object.values(country.currencies)[0].symbol }})</p>
        </div>
        <div class="globe-container">
          <div ref="globeEl" class="globe"></div>
        </div>

</template>

<script setup>
import { useStore } from 'vuex';
import { computed, ref, onMounted, watch } from 'vue';
import Globe from "globe.gl";

const store = useStore();

const city = computed({
  get: () => store.getters['weather/city'],
  set: (val) => store.commit('weather/setCity', val)
});

const weather = computed(() => store.getters['weather/weather']);
const forecast = computed(() => store.getters['weather/forecast']);
const country = computed(() => store.getters['weather/country']);
const loading = computed(() => store.getters['weather/loading']);
const error = computed(() => store.getters['weather/error']);

const globeEl = ref(null);
let globeInstance = null;

const getWeather = () => store.dispatch('weather/fetchWeather', city.value);
const getForecast = () => store.dispatch('weather/fetchForecast');

function formatTime(dtTxt) {
  const date = new Date(dtTxt);
  return date.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true
  });
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

onMounted(() => {
  globeInstance = Globe()(globeEl.value)
    .globeImageUrl("//unpkg.com/three-globe/example/img/earth-blue-marble.jpg")
    .pointAltitude("size")
    .pointColor("color")
    .pointsData([])
    .backgroundColor("#000");

  globeInstance.width(globeEl.value.offsetWidth);
  globeInstance.height(globeEl.value.offsetHeight);
});

watch(weather, (newWeather) => {
  if (newWeather?.coord) {
    const { lat, lon } = newWeather.coord;
    globeInstance.pointOfView({ lat, lng: lon, altitude: 0.3 }, 2000);
    globeInstance.pointsData([
      {
        lat,
        lng: lon,
        size: 0.2,
        color: "white",
        label: `${newWeather.name}, ${newWeather.sys.country}`
      }
    ]);
  }
});
</script>

<style scoped>
.container {
  max-width: 1120px;
  margin: 40px auto;
  padding: 1rem;
  text-align: center;
}

input {
  padding: 0.5rem;
  font-size: 1rem;
  margin-right: 0.5rem;
}

button {
  padding: 0.5rem 1rem;
  font-size: 1rem;
}
.forecast-list {
  width: 100%;
  list-style: none;
  padding: 0;
  margin-top: 1rem;
  gap: 20px;
}

.forecast-list li {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid #ddd;
}

.forecast-list .time {
  font-weight: bold;
  color: #43e192;
  min-width: 80px;
}

.forecast-list .temp {
  color: #43e192;
  font-weight: 600;
}

.forecast-list .desc {
  font-style: italic;
  color: #fff;
}
.weather-table {
  width: 100%;
  margin: 1.5rem 0;
  border-collapse: collapse;
  font-size: 0.9rem;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.weather-table thead {
  background: #2c2c2c;
}

.weather-table th {
  color: #43e192;
  font-weight: 600;
  padding: 12px 10px;
  text-align: center;
  border-bottom: 2px solid #444;
}

.weather-table td {
  padding: 10px;
  text-align: center;
  border-bottom: 1px solid #444;
  color: #f1f1f1;
}

.weather-table tbody tr:nth-child(even) {
  background: #1e1e1e;
}

.weather-table tbody tr:nth-child(odd) {
  background: #252525;
}

.weather-table tbody tr:hover {
  background: #333;
  transition: background 0.3s;
}
.country-details {
  text-align: center;
  background: #1a1a1a;
  padding: 1rem;
  margin-top: 2rem;
  border-radius: 8px;
  color: #eee;
  box-shadow: 0 4px 10px rgba(0, 255, 150, 0.2);
}
.country-details img {
  margin-bottom: 1rem;
  border: 1px solid #43e192;
  border-radius: 4px;
}
.country-details p {
  margin: 6px 0;
}

.globe-container {
  margin-top: 2rem;
  text-align: center;
  color: #eee;
  display: flex;
  justify-content: center;
}
.globe {
  height: 500px;
  margin: 0 auto;
  width: 100% !important;
  max-width: 600px !important;
  border: 1px solid #43e192;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,255,150,0.2);
  overflow: hidden;
}



</style>
