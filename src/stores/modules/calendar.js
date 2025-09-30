import axios from "axios";

const API_URL = "http://localhost:3000";

const calendar = {
  namespaced: true,
  state() {
    return {
      events: [],
      loading: false,
      creatingEvent: false,
      error: null
    };
  },
  mutations: {
    setEvents(state, events) {
      state.events = events;
    },
    addEvent(state, event) {
      state.events.unshift(event);
    },
    updateEvent(state, updatedEvent) {
      const index = state.events.findIndex(event => event.id === updatedEvent.id);
      if (index !== -1) {
        state.events.splice(index, 1, updatedEvent);
      }
    },
    removeEvent(state, eventId) {
      state.events = state.events.filter(event => event.id !== eventId);
    },
    setLoading(state, loading) {
      state.loading = loading;
    },
    setCreatingEvent(state, creating) {
      state.creatingEvent = creating;
    },
    setDeletingEvent(state, deleting) {
      state.deletingEvent = deleting;
    },
    setError(state, error) {
      state.error = error;
    },
    clearError(state) {
      state.error = null;
    }
  },

  actions: {
    async fetchEvents({ commit, rootGetters }) {
      if (!rootGetters['auth/isAuthenticated']) {
        commit('setError', 'Please login to access calendar');
        return;
      }
      commit('setLoading', true);
      commit('clearError');

      try {
        const token = rootGetters['auth/token'] || localStorage.getItem('access_token');

        if (!token) {
          throw new Error('No authentication token found');
        }

        const response = await axios.get(`${API_URL}/api/v1/calendar/events` , {
          headers: {
            'Authorization' : ` Bearer ${token}`,
            'Content-type' : 'application/json'
          }
        });
        commit('setEvents', response.data.events || []);
      } catch (error) {
        if (error.response?.status === 401) {
          const errorMsg = error.response?.data?.error || error.response?.data?.message || 'Google Calendar not connected';
          commit('setError', errorMsg);
          
          if (error.response?.data?.reconnect_required) {
            commit('setReconnectRequired', true);
          }
        } else {
          const errorMsg = error.response?.data?.error || "Failed to fetch calendar events";
          commit('setError', errorMsg);
        }
        console.error('Calendar fetch error:', error);
        throw error;
      } finally {
        commit('setLoading', false);
      }
    },

    async createEvent({ commit, rootGetters }, eventData) {
      if (!rootGetters['auth/isAuthenticated']) {
        commit('setError', 'Please login to create events');
        return;
      }

      commit('setCreatingEvent', true);
      commit('clearError');

      try {
        const token = rootGetters['auth/token'] || localStorage.getItem('access_token');
        
        if (!token) {
          throw new Error('No authentication token found');
        }
        const response = await axios.post(`${API_URL}/api/v1/calendar/events`, eventData, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        commit('addEvent', response.data.event);
        return response.data.event; 
      } catch (error) {
        const errorMsg = error.response?.data?.error || "Failed to create event";
        commit('setError', errorMsg);
        console.error('Calendar create error:', error);
        throw error;
      } finally {
        commit('setCreatingEvent', false);
      }
    },

    async deleteEvent({ commit, rootGetters }, eventId) {
      if (!rootGetters['auth/isAuthenticated']) {
        commit('setError', 'Please login to delete events');
        return;
      }

      commit('setDeletingEvent', true);
      commit('clearError');

      try {
        const token = rootGetters['auth/token'] || localStorage.getItem('access_token');
        if (!token) {
          throw new Error('No authentication token found');
        }
        await axios.delete(`${API_URL}/api/v1/calendar/events/${eventId}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        commit('removeEvent', eventId);
        return true; 
      } catch (error) {
        const errorMsg = error.response?.data?.error || "Failed to delete event";
        commit('setError', errorMsg);
        console.error('Calendar delete error:', error);
        throw error;
      } finally {
        commit('setDeletingEvent', false);
      }
    },
    
    clearError({ commit }) {
      commit('clearError');
    }
  },
  getters: {
    events: (state) => state.events,
    upcomingEvents: (state) => {
      const now = new Date();
      return state.events.filter(event => {
        const eventDate = new Date(event.start_time || event.start?.dateTime);
        return eventDate >= now;
      });
    },
    pastEvents: (state) => {
      const now = new Date();
      return state.events.filter(event => {
        const eventDate = new Date(event.start_time || event.start?.dateTime);
        return eventDate < now;
      });
    },
    loading: (state) => state.loading,
    creatingEvent: (state) => state.creatingEvent,
    error: (state) => state.error,
    hasEvents: (state) => state.events.length > 0,
    eventCount: (state) => state.events.length
  }
};

export default calendar;