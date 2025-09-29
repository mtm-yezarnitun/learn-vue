import axios from "axios";

const API_URL = "http://localhost:3000/api/v1";

const blog = {
  namespaced: true,
  state() {
    return {
      user: JSON.parse(localStorage.getItem("user")) || null,
      posts: [],
      loading: false,
      error: null,
      comments: {} 
    };
  },
  mutations: {
    setPosts(state, posts) {
      state.posts = posts;
    },
    addPost(state, post) {
      state.posts.unshift(post);
    },
    removePost(state, id) {
      state.posts = state.posts.filter(p => p.id !== id);
    },
    setLoading(state, val) {
      state.loading = val;
    },
    setError(state, err) {
      state.error = err;
    },
    setComments(state, { postId, comments }) {
      state.comments[postId] = comments;
    },
    addComment(state, { postId, comment }) {
      if (!state.comments[postId]) state.comments[postId] = [];
      state.comments[postId].push(comment);
    },
    removeComment(state, { postId, commentId }) {
      if (!state.comments[postId]) return;
      state.comments[postId] = state.comments[postId].filter(c => c.id !== commentId);
    }
  },
  actions: {
    async fetchPosts({ commit }) {
      commit("setLoading", true);
      try {
        const res = await axios.get(`${API_URL}/posts`);
        commit("setPosts", res.data);
      } catch (err) {
        commit("setError", err.message);
      } finally {
        commit("setLoading", false);
      }
    },
    async createPost({ commit }, post) {
      try {
        const res = await axios.post(`${API_URL}/posts`, { post });
        commit("addPost", res.data.data);
        window.$toast.success("Post Created Successfully!");
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error("Couldn't Create Post!");
      }
    },
    async deletePost({ commit }, id) {
      try {
        await axios.delete(`${API_URL}/posts/${id}`);
        commit("removePost", id);
        window.$toast.success("Post Deleted Successfully!");
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error("Cannot Delete Someone else's Post!!");
      }
    },
    async updatePost({ commit, state }, { id, post }) {
      try {
        const res = await axios.put(`${API_URL}/posts/${id}`, { post });
        const updated = state.posts.map(p => (p.id === id ? res.data : p));
        commit("setPosts", updated);
        window.$toast.success("Post Updated Successfully!");
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error("Cannot Edit Someone else's Post!!");
      }
    },
    async fetchPostById({ commit }, id) {
      commit("setLoading", true);
      try {
        const res = await axios.get(`${API_URL}/posts/${id}`);
        return res.data;
      } catch (err) {
        commit("setError", err.message);
        return null;
      } finally {
        commit("setLoading", false);
      }
    },
    async fetchComments({ commit }, postId) {
      try {
        const res = await axios.get(`${API_URL}/posts/${postId}/comments`);
        commit("setComments", { postId, comments: res.data });
      } catch (err) {
        commit("setError", err.message);
      }
    },
    async createComment({ commit }, { postId, content }) {
      try {
        const res = await axios.post(`${API_URL}/posts/${postId}/comments`, { comment: { content } });
        commit("addComment", { postId, comment: res.data });
        window.$toast.success("Comment added!");
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error("Could not add comment!");
      }
    },
    async deleteComment({ commit, state }, { postId, commentId }) {
      const comment = state.comments[postId]?.find(c => c.id === commentId);
      const user = JSON.parse(localStorage.getItem("user"));
      if (!comment || (comment.user_id !== user.id && user.role !== 'admin')) {
        window.$toast.error("Cannot delete someone else's comment!");
        return;
      }
      try {
        await axios.delete(`${API_URL}/posts/${postId}/comments/${commentId}`);
        commit("removeComment", { postId, commentId });
        window.$toast.success("Comment deleted!");
      } catch (err) {
        commit("setError", err.message);
        window.$toast.error("Failed to delete comment!");
      }
    }
  },
  getters: {
    posts: state => state.posts,
    loading: state => state.loading,
    error: state => state.error,
    postById: state => id => state.posts.find(p => p.id === id),
    myPosts: state => {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user) return [];
      return state.posts.filter(p => p.user_id === user.id);
    },
    commentsByPost: state => postId => state.comments[postId] || []
  }
};

export default blog;
