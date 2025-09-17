import { createStore } from 'vuex';

const API_KEY = import.meta.env.VITE_WEATHER_API_KEY;

const store = createStore({
  state() {
    return {
      city: localStorage.getItem('city') || '',
      weather: JSON.parse(localStorage.getItem('weather')) || null,
      forecast: JSON.parse(localStorage.getItem('forecast')) || null,
      country: JSON.parse(localStorage.getItem('country')) || null,
      loading: false,
      error: null
    };
  },

  mutations: {
    setCity(state, city) {
      state.city = city;
      localStorage.setItem('city', city);
    },
    setWeather(state, weather) {
      state.weather = weather;
      localStorage.setItem('weather', JSON.stringify(weather));
    },
    setForecast(state, forecast) {
      state.forecast = forecast;
      localStorage.setItem('forecast', JSON.stringify(forecast));
    },
    setCountry(state, country) {
      state.country = country;
      localStorage.setItem('country', JSON.stringify(country));
    },
    setLoading(state, value) {
      state.loading = value;
    },
    setError(state, error) {
      state.error = error;
    }
  },

  actions: {
    async fetchWeather({ commit, dispatch }, city) {
      if (!city) return;
      commit('setLoading', true);
      commit('setError', null);
      commit('setCountry', null)
      commit('setWeather', null)
      commit('setForecast', null)

      try {
        const res = await fetch(
          `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${API_KEY}&units=metric`
        );
        const data = await res.json();
        if (data.cod !== 200) throw new Error(data.message);

        commit('setCity', city);
        commit('setWeather', data);

        dispatch('fetchCountry', data.sys.country);
      } catch (err) {
        commit('setError', err.message);
      } finally {
        commit('setLoading', false);
      }
    },

    async fetchForecast({ state, commit }) {
      if (!state.city) return;
      commit('setLoading', true);
      commit('setError', null);

      try {
        const res = await fetch(
          `https://api.openweathermap.org/data/2.5/forecast?q=${state.city}&appid=${API_KEY}&units=metric`
        );
        const data = await res.json();
        if (data.cod !== '200') throw new Error(data.message);

        commit('setForecast', data);
      } catch (err) {
        commit('setError', err.message);
      } finally {
        commit('setLoading', false);
      }
    },

    async fetchCountry({ commit }, code) {
      try {
        const res = await fetch(`https://restcountries.com/v3.1/alpha/${code}`);
        const data = await res.json();
        if (!data || data.status === 404) throw new Error('Country not found');

        commit('setCountry', data[0]);
      } catch (err) {
        console.error('Country API error:', err);
      }
    }
  },

  getters: {
    city: (state) => state.city,
    weather: (state) => state.weather,
    forecast: (state) => state.forecast,
    country: (state) => state.country,
    loading: (state) => state.loading,
    error: (state) => state.error
  }
});

export default store;
