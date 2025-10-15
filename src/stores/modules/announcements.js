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
        } catch (err) {
            commit ('setError' , err.response?.data || err.message )
        } finally {
            commit ('setLoading' , false)
            window.$toast.success("Announcement Created Successfully!");
        }
    },
    async deleteAnnouncements({ commit }, id) {
        commit('setLoading', true )
        try {
            await axios.delete (`${API_URL}/announcements/${id}`);
            commit ('removeAnnouncements' , id)
        } catch (err) {
            commit ('setError' , err.response?.data || err.message )
        } finally {
            commit ('setLoading' , false)
            window.$toast.success("Deleted Announcement Successfully!");
        }
    },
  },
  getters: {
    allAnnouncements: (state) => state.announcements,
    isLoading: (state) => state.loading,
   }
};

export default announcements;
