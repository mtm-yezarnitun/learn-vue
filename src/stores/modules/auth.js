import axios from "axios";

const API_URL = "http://localhost:3000";

const auth = {
  namespaced: true,
  state() {
    return {
      user: null,
      token: null,
      loading: false,
      error: null,
    };
  },
  mutations: {
    setUser(state, user) {
      state.user = user;
      localStorage.setItem("user", JSON.stringify(user));
    },
    setToken(state, token) {
      state.token = token;
      localStorage.setItem("token", token); 
      axios.defaults.headers.common["Authorization"] = `Bearer ${token}`; 
    },
    setLoading(state, val) {
      state.loading = val;
    },
    setError(state, err) {
      state.error = err;
    },
    logout(state) {
      state.user = null;
      state.token = null;
      localStorage.removeItem("user");
      localStorage.removeItem("token");
      localStorage.removeItem("city");
      localStorage.removeItem("country");
      localStorage.removeItem("forecast");
      localStorage.removeItem("weather");
      delete axios.defaults.headers.common["Authorization"];
    },
  },
  actions: {
    init({ commit }) {
      const user = localStorage.getItem("user");
      const token = localStorage.getItem("token");
      if (user && token) {
        commit("setUser", JSON.parse(user));
        commit("setToken", token);
      }
    },
    async login({ commit }, { email, password ,router}) {
      commit("setLoading", true);
      try {
        const res = await axios.post(`${API_URL}/login`, { user: { email, password } });
        commit("setUser", res.data.user);
        commit("setToken", res.data.token);
        window.$toast.success ('Login Success!')
    
        router.push("/dashboard");
        } catch (err) {
            const errorMsg = err.response?.data?.message || err.response?.data?.error || err.response?.data?.error?.join?.(", ") || err.message || "Something went wrong";;
            commit("setError", errorMsg);
            window.$toast?.error(errorMsg);
        } finally {
            commit("set Loading", false);
        }
    },
    async signup({ commit }, { name ,email, password ,router}) {
      commit("setLoading", true);
      try {
        await axios.post(`${API_URL}/signup`, { user: { name ,email, password} });
        window.$toast.success ('Success Registrations! Please Login using your Account !')
        router.push("/login");

        } catch (err) {
            const errorMsg = err.response?.data?.message || err.response?.data?.errors?.join?.(", ") || err.message;
            commit("setError", errorMsg);
            window.$toast?.error(errorMsg);
        }
        finally {
            commit("setLoading", false);
        }
    },
    async logout({ commit },{router}) {
      try {
        await axios.delete(`${API_URL}/logout`);
      } catch {}
      commit("logout");
      window.$toast.success ('Logged Out Successfully!')
      router.push("/login");
    },
  },
  getters: {
    user: (state) => state.user,
    token: (state) => state.token,
    isAuthenticated: (state) => !!state.token,
    loading: (state) => state.loading,
    error: (state) => state.error,
  },
};

export default auth;
