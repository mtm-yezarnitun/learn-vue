import axios from "axios";

const API_URL = "http://localhost:3000";

const calendar = {
  namespaced: true,
  state() {
    return {
      events: [],
      loading: false,
      creatingEvent: false,
      deletingEvent: false,
      editingEvent: false,
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
    setEditingEvent(state, editing) {
      state.editingEvent = editing;
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
        const token = rootGetters['auth/token'] || localStorage.getItem('token');

        if (!token) {
          throw new Error('No authentication token found');
        }

        const response = await axios.get(`${API_URL}/api/v1/calendar/cached_events` , {
          headers: {
            'Authorization' : ` Bearer ${token}`,
            'Content-type' : 'application/json'
          }
        });
        const events = response.data.events || [];
        commit('setEvents', events || []);
      } catch (error) {
        if (error.response?.status === 401) {
          const errorMsg = error.response?.data?.error || error.response?.data?.message || 'Google Calendar not connected . Logout and Login again to regain Access!';
          commit('setError', errorMsg);
          
          if (error.response?.data?.reconnect_required) {
            commit('setReconnectRequired', true);
          }
        } else {
          const errorMsg = error.response?.data?.error || "Failed to fetch calendar events";
          window.$toast.error('Fail to fetch calendar events! Logout and Login again to refresh tokens');
          commit('setError', errorMsg);
        }
        console.error('Calendar fetch error:', error);
        throw error;
      } finally {
        commit('setLoading', false);
      }
    },

    async refreshEvents({ commit, rootGetters }) {
      if (!rootGetters['auth/isAuthenticated']) return commit('setError', 'Please login');

      commit('setLoading', true);
      commit('clearError');
      try {
        const token = rootGetters['auth/token'] || localStorage.getItem('token');
        const response = await axios.get(`${API_URL}/api/v1/calendar/events`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        commit('setEvents', response.data.events || []);
      } catch (error) {
        commit('setError', 'Failed to refresh events');
        console.error(error);
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
        const token = rootGetters['auth/token'] || localStorage.getItem('token');
        
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
        window.$toast.error('Couldn`t Create Event!');
        throw error;
      } finally {
        commit('setCreatingEvent', false);
      }
    },

    async updateEvent({commit , rootGetters},{ eventId ,eventData } ){
      if (!rootGetters['auth/isAuthenticated']) {
        commit('setError', 'Please login to edit events');
        return;
      }

      commit('setEditingEvent', true);
      commit('clearError');

      try {
        const token = rootGetters['auth/token'] || localStorage.getItem('token');
        if (!token) {
          throw new Error('No authentication token found');
        }
        const response = await axios.patch(`${API_URL}/api/v1/calendar/events/${eventId}`, eventData, {
          headers: {
            'Authorization': `Bearer ${token}` , 
            'Content-Type': 'application/json'
          }

        });

        commit('updateEvent', response.data.event);
        return response.data.event;

      } catch (error) {
          const errorMsg = error.response?.data?.error || "Failed to update event";
          commit('setError', errorMsg);
          console.error('Calendar update error:', error);
          window.$toast.error('Couldn`t Update Event!');
          throw error;
        } finally {
          commit('setEditingEvent', false);
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
        const token = rootGetters['auth/token'] || localStorage.getItem('token');
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
        const eventDate = new Date(event.start_time || event.start?.date_time);
        return eventDate >= now;
      });
    },
    ongoingEvents: (state) => {
      const now = new Date();
      return state.events.filter(event => {
        const start = new Date(event.start_time || event.start?.date_time);
        const end = new Date(event.end_time || event.end?.date_time);
        return start <= now && end >= now;
      });
    },
    pastEvents: (state) => {
      const now = new Date();
      return state.events.filter(event => {
        const end = new Date(event.end_time || event.end?.date_time);
        return end < now;
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