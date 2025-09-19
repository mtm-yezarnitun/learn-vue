import axios from "axios"

const API_URL = "http://localhost:3000/api/v1"

const blog = {
  namespaced: true,
  state() {
    return {
      posts: [],
      loading: false,
      error: null
    }
  },
  mutations: {
    setPosts(state, posts) {
      state.posts = posts
    },
    addPost(state, post) {
      state.posts.unshift(post)
    },
    removePost(state, id) {
      state.posts = state.posts.filter(p => p.id !== id)
    },
    setLoading(state, val) {
      state.loading = val
    },
    setError(state, err) {
      state.error = err
    }
  },
  actions: {
    async fetchPosts({ commit }) {
      commit("setLoading", true)
      try {
        const res = await axios.get(`${API_URL}/posts`)
        commit("setPosts", res.data)
      } catch (err) {
        commit("setError", err.message)
      } finally {
        commit("setLoading", false)
      }
    },
    async createPost({ commit }, post) {
      try {
        const res = await axios.post(`${API_URL}/posts`, { post });
        commit("addPost", res.data.data);
        window.$toast.success ('Post Created Successfully !')
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error ('Couldn`t Create Post!')
      }
    },
    async deletePost({ commit }, id) {
      try {
        await axios.delete(`${API_URL}/posts/${id}`);
        commit("removePost", id);
        window.$toast.error ('Post Deleted Successfully  !')
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error ('Cannot Delete Someone else`s Post !!')
      }
    },
    async updatePost({ commit, state }, { id, post }) {
      try {
        const res = await axios.put(`${API_URL}/posts/${id}`, { post });
        const updated = state.posts.map(p => (p.id === id ? res.data : p));
        commit("setPosts", updated);
        window.$toast.success ('Post Updated Successfully  !')
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error ('Cannot Edit Someone else`s Post !!')
      }
    }

  },
  getters: {
    posts: state => state.posts,
    loading: state => state.loading,
    error: state => state.error,
    postById: state => id => state.posts.find(p => p.id === id),

    myPosts: (state) => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (!user) return [];
    return state.posts.filter(p => p.user_id === user.id);
  }
  }
}

export default blog;
