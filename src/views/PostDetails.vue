<template>
  <span class="back-btn">
    <router-link :to="`/blog`">Back</router-link>
  </span>
  <div v-if="post">
    <h1>{{ post.title }}</h1>
    <p>{{ post.body }}</p>

    <div class="comments">
      <h3>Comments</h3>

      <div v-for="comment in comments" :key="comment.id" class="comment-card">
        <p>{{ comment.content }}</p>
        <small>{{ comment.user?.email }}</small>
        <button 
          v-if="comment.user_id === userData.id" 
          @click="handleDeleteComment(comment.id)"
        >
          Delete
        </button>
      </div>

      <form @submit.prevent="submitComment">
        <input v-model="newComment" placeholder="Add a comment..." />
        <button type="submit">Add</button>
      </form>
    </div>
  </div>
  <p v-else>Loading...</p>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useStore } from "vuex";
import { useRoute } from "vue-router";

const store = useStore();
const route = useRoute();

const post = ref(null);
const newComment = ref("");
const userData = ref(JSON.parse(localStorage.getItem("user")) || {});
const postId = route.params.id;

async function fetchPost() {
  post.value = await store.dispatch("blog/fetchPostById", postId);
}

async function fetchComments() {
  await store.dispatch("blog/fetchComments", postId);
}
const comments = computed(() => store.getters["blog/commentsByPost"](postId));

function submitComment() {
  if (!newComment.value) {
    window.$toast.error("Comment cannot be empty!");
    return;
  }
  store.dispatch("blog/createComment", { postId, content: newComment.value });
  newComment.value = "";
}

function handleDeleteComment(commentId) {
  store.dispatch("blog/deleteComment", { postId, commentId });
}

onMounted(async () => {
  await fetchPost();
  await fetchComments();
});
</script>

<style scoped>
.comments {
  margin-top: 20px;
}
.comment-card {
  border: 1px solid #43e192;
  border-radius: 6px;
  padding: 10px;
  margin-bottom: 10px;
}
.comment-card button {
  margin-top: 5px;
  background-color: red;
  color: white;
  border: none;
  padding: 3px 6px;
  cursor: pointer;
  border-radius: 3px;
}
.back-btn {
  position: absolute;
  top: 20%;
  left: 30px;
}
</style>
