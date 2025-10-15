import axios from "axios";

const API_URL = "http://localhost:3000/api/v1";

const announcements = {
  namespaced: true,
  state() {
    return {
      announcements: [],
      loading: false,
      error: null,
    };
  },
  mutations: {
    setAnnouncements(state , announcements) {
        state.announcements = announcements;
    },
    addAnnouncements(state , newAnnouncements) {
        state.announcements.unshift(newAnnouncements);
    },
    editAnnouncements(state, updatedAnnouncement) {
      const index = state.announcements.findIndex(a => a.id === updatedAnnouncement.id);
      if (index !== -1) {
        state.announcements.splice(index, 1, updatedAnnouncement);
      }
    },
    removeAnnouncements(state ,id) {
        state.announcements = state.announcements.filter(a => a.id !== id);
    },
    setLoading(state, val) {
      state.loading = val;
    },
    setError(state, err) {
      state.error = err;
    },


  },
  actions: { 
    async fetchAnnouncements({commit}) {
        commit('setLoading' , true )
        try {
            const res = await axios.get (`${API_URL}/announcements`);
            commit ('setAnnouncements' , res.data)
        } catch(err) {
            commit ('setError', err.response?.data || err.message )
        } finally {
            commit ('setLoading' , false)
        }
    },
    async createAnnouncements({ commit }, announcementData) {
        commit('setLoading', true )
        try {
            const res = await axios.post (`${API_URL}/announcements` , {
                announcement : announcementData,
            });
            commit ('addAnnouncements' , res.data)
            window.$toast.success("Announcement created Successfully!");
        } catch (err) {
            commit ('setError' , err.response?.data || err.message )
            window.$toast.error("Cannot create Announcements!");
        } finally {
            commit ('setLoading' , false)
  
        }
    },
    async updateAnnouncements({ commit }, announcementData ) {
        commit('setLoading', true )
        try {
            const res = await axios.put (`${API_URL}/announcements/${announcementData.id}` , {
                announcement : announcementData,
            });
            commit ('editAnnouncements' , res.data)
            window.$toast.success("Announcement edited Successfully!");
        } catch (err) {
            commit ('setError' , err.response?.data || err.message )
            window.$toast.error("Can't Edit Announcement!");
        } finally {
            commit ('setLoading' , false)
        }
    },
    async deleteAnnouncements({ commit }, id) {
        commit('setLoading', true )
        try {
            await axios.delete (`${API_URL}/announcements/${id}`);
            commit ('removeAnnouncements' , id)
            window.$toast.success("Deleted Announcement Successfully!");
        } catch (err) {
            commit ('setError' , err.response?.data || err.message )
            window.$toast.error("Couldn't delete Announcement!");
        } finally {
            commit ('setLoading' , false)
        }
    },
    async fetchActiveAnnouncements({ commit }) {
        commit('setLoading', true)
        try {
            const res = await axios.get(`${API_URL}/announcements/active`)
            commit('setAnnouncements', res.data)
        } catch (err) {
            commit('setError', err.response?.data || err.message)
        } finally {
            commit('setLoading', false)
        }
    },

  },
  getters: {
    allAnnouncements: (state) => state.announcements,
    active: (state) => {
      const now = new Date();
      return state.announcements.filter(announcements => {
        const annStart = new Date(announcements.start_time || announcements.start?.date_time);
        const annEnd = new Date(announcements.end_time || announcements.end?.date_time);
        return annStart <= now && annEnd >= now;
      });
    },
    isLoading: (state) => state.loading,
   }
};

export default announcements;
