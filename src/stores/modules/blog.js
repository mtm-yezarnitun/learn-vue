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
      state.posts.push(post)
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
      const res = await axios.post(`${API_URL}/posts`, { post })
      commit("addPost", res.data)
    },
    async deletePost({ commit }, id) {
      await axios.delete(`${API_URL}/posts/${id}`)
      commit("removePost", id)
    }
  },
  getters: {
    posts: state => state.posts,
    loading: state => state.loading,
    error: state => state.error
  }
}

export default blog
