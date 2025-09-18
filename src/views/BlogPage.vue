<template>
  <div class="blog">
    <h1>✎ Blog</h1>

    <form @submit.prevent="submitPost" class="post-form">
      <input v-model="title" placeholder="Post title" />
      <textarea v-model="body" placeholder="Write something..." @keyup.enter="submitPost"></textarea>

      <div class="btns">
        <button type="submit">{{ editMode ? "Update" : "Add Post" }}</button>
        <button v-if="editMode" type="button" @click="cancelEdit">Cancel</button>
      </div>

    </form>

    <div class="posts-grid">
      <div v-for="post in posts" :key="post.id" class="post-card">
        <h3>{{ post.title }}</h3>
        <p>{{ post.body }}</p>
        <p>{{ post.user_email }}</p>

        <div class="btns">
          <button @click="editPost(post)" class="edit">Edit</button>
          <button @click="removePost(post.id)">Delete</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useStore } from "vuex";

const store = useStore();

const title = ref("");
const body = ref("");
const editMode = ref(false);
const editId = ref(null);

const posts = computed(() => store.getters["blog/posts"]);

onMounted(() => {
  store.dispatch("blog/fetchPosts");
});

function submitPost() {
  if (!title.value || !body.value) return;

  if (editMode.value) {
    store.dispatch("blog/updatePost", { id: editId.value, post: { title: title.value, body: body.value } });
    editMode.value = false;
    editId.value = null;
  } else {
    store.dispatch("blog/createPost", { title: title.value, body: body.value });
  }

  title.value = "";
  body.value = "";
}

function editPost(post) {
  title.value = post.title;
  body.value = post.body;
  editMode.value = true;
  editId.value = post.id;
}

function cancelEdit() {
  title.value = "";
  body.value = "";
  editMode.value = false;
  editId.value = null;
}

function removePost(id) {
  store.dispatch("blog/deletePost", id);
}
</script>

<style scoped>
.blog {
  width: 600px;
  margin: 40px auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

h1 {
  text-align: center;
  margin-bottom: 20px;
}

.post-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  align-items: center;
}

.post-form input,
.post-form textarea {
  width: 100%;
  padding: 8px;
  border: 1px solid #43e192;
  border-radius: 4px;
  font-size: 14px;
  font-family: monospace;
}

.post-form textarea {
  resize: none;
  min-height: 60px;
}

.post-form button {
  width: 100px;
  padding: 8px;
  background-color: #43e192;
  border: 1px solid black;
  color: white;
  border-radius: 4px;
  cursor: pointer;
}

.post-form button:hover {
  background-color: #1e1e1e;
  border: 1px solid #43e192;
}
.edit {
  background-color: #1e1e1e !important;
  border: 1px solid #43e192 !important;
}

.edit:hover {
  color: #1e1e1e !important;
  background-color: #43e192 !important;
  border: 1px solid #1e1e1e !important;
}

.posts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 15px;
}

.post-card {
  padding: 15px;
  color: #43e192;
  border: 1px solid #43e192;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
}

.post-card h3 {
  margin: 0 0 30px 0;
  font-size: 18px;
}

.post-card p {
  flex-grow: 1;
  margin-bottom:30px;
  white-space: pre-line;
}

.post-card button {
  padding: 5px 10px;
  background-color: #e74c3c;
  color: white;
  border: 1px solid transparent;
  border-radius: 4px;
  cursor: pointer;
}

.post-card button:hover {
  color: #e74c3c;
  background-color: white;
  border: 1px solid #e74c3c;
}
</style>
