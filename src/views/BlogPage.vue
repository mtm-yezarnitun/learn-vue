<template>
  <div class="blog">
    <h1>📝 Blog</h1>

    <form @submit.prevent="addPost">
      <input v-model="title" placeholder="Post title" />
      <textarea v-model="content" placeholder="Write something..."></textarea>
      <button type="submit">Add Post</button>
    </form>

    <ul>
      <li v-for="post in posts" :key="post.id">
        <h3>{{ post.title }}</h3>
        <p>{{ post.content }}</p>
        <button @click="removePost(post.id)">Delete</button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted , computed } from "vue"
import { useStore } from "vuex"

const store = useStore()

const title = ref("")
const content = ref("")

const posts = computed(() => store.getters["blog/posts"])

onMounted(() => {
  store.dispatch("blog/fetchPosts")
})

function addPost() {
  if (!title.value || !content.value) return
  store.dispatch("blog/createPost", { title: title.value, content: content.value })
  title.value = ""
  content.value = ""
}

function removePost(id) {
  store.dispatch("blog/deletePost", id)
}
</script>
