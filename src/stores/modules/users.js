import axios from "axios";

const API_URL = "http://localhost:3000/admin/users"; 
const users = {
  namespaced: true,
  state: {
    users: [],
    user: null,
    error: null,
  },
  mutations: {
    setUsers(state, users) {
      state.users = users;
    },
    setUser(state, user) {
      state.user = user;
    },
    addUser(state, user) {
      state.users.push(user);
    },
    updateUser(state, updatedUser) {
      const index = state.users.findIndex(u => u.id === updatedUser.id);
      if (index !== -1) state.users.splice(index, 1, updatedUser);
    },
    removeUser(state, userId) {
      state.users = state.users.filter(u => u.id !== userId);
    },
    setError(state, error) {
      state.error = error;
    },
  },
  actions: {
    async fetchUsers({ commit } , router) {
      try {
        const res = await axios.get(`${API_URL}`);
        commit("setUsers", res.data);
      } catch (err) {
          if (err.response && err.response.status === 403) {
            window.$toast.error("No Access to This Page!!")
            router.push('/dashboard')
          commit("setError", err.message);
        }
      }
    },
    
    async fetchUser({ commit }, id) {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get(`${API_URL}/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        commit("setUser", res.data);
      } catch (err) {
        commit("setError", err.response?.data || err.message);
      }
    },

    async createUser({ commit }, userData) {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.post(API_URL, { user: userData }, {
          headers: { Authorization: `Bearer ${token}` },
        });
        window.$toast.success("User Created Successfully!");
        commit("addUser", res.data.user);

      } catch (err) {
        commit("setError", err.response?.data || err.message);
      }
    },
    
    async updateUser({ commit }, { id, userData }) {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.put(`${API_URL}/${id}`,{ user: userData }, {
          headers: { Authorization: `Bearer ${token}` },
        });
        window.$toast.success("User Updated Successfully!");
        commit("updateUser", res.data);
      } catch (err) {
        commit("setError", err.response?.data || err.message);
      }
    },

    async deleteUser({ commit }, id) {
      try {
        const token = localStorage.getItem("token");
        await axios.delete(`${API_URL}/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        window.$toast.success("User Deleted Successfully!");
        commit("removeUser", id);
      } catch (err) {
        commit("setError", err.response?.data || err.message);
      }
    },
  },
  getters: {
    allUsers: (state) => state.users,
    getUser: (state) => state.user,
    getError: (state) => state.error,
  },
};

export default users;
