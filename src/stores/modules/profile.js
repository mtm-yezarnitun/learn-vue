import axios from "axios";

const API_URL = "http://localhost:3000/api/v1";

const profile = {
  namespaced: true,
  state() {
    return {
      user: JSON.parse(localStorage.getItem("user")) || null,
      loading: false,
      error: null,
    };
  },
  mutations: {
    set_user(state, user) {
      state.user = user;
      localStorage.setItem("user", JSON.stringify(state.user));
    },
    update_user(state, user) {
      state.user = user
      localStorage.setItem("user", JSON.stringify(state.user));
    },
    set_loading(state, status) {
      state.loading = status;
    },
    set_error(state, error) {
      state.error = error;
    },
  },
  actions: {
    async fetchProfile({ commit }) {
      commit("set_loading", true);
      try {
        const res = await axios.get(`${API_URL}/profile`);
        commit("set_user", res.data);
      } catch (err) {
        commit("set_error", err.response?.data || "Failed to fetch profile");
      } finally {
        commit("set_loading", false);
      }
    },

    async updateProfile({ commit }, payload) {
      commit("set_loading", true);
      try {
        const res = await axios.patch(`${API_URL}/profile`, { user: payload });
        commit("update_user", res.data.user);
        return { success: true };
      } catch (err) {
        commit("set_error", err.response?.data || { base: ["Something went wrong"] });
        return { success: false, errors: err.response?.data || { base: ["Something went wrong"] } };
      } finally {
        commit("set_loading", false);
      }
    },
  },
  getters: {
    currentUser: (state) => state.user,
    isLoggedIn: (state) => !!state.user,
    userRole: (state) => state.user?.role,
    loading: (state) => state.loading,
    error: (state) => state.error,
  },
};

export default profile;
