<template>
  <div class="admin-announcements">
    <h2>Manage Announcements</h2>

    <form @submit.prevent="submitForm" class="announcement-form">
      <input type="text" v-model="title" placeholder="Announcement Title" required  />
      <textarea v-model="message" placeholder="Announcement message" required></textarea>
      <input type="datetime-local" v-model="startTime" required />
      <input type="datetime-local" v-model="endTime" required />
      <button type="submit" :disabled="loading">Create</button>
    </form>

    <div v-if="loading" class="loading">Loading...</div>
    <div v-if="error" class="error">{{ error }}</div>

    <div class="announcement-list">
      <h3>Existing Announcements</h3>
      <ul>
        <li v-for="a in announcements" :key="a.id">
          <strong>{{ a.title }}</strong>
          <strong>{{ a.message }}</strong>
          <span> ({{ formatDate(a.start_time) }} → {{ formatDate(a.end_time) }})</span>
          <button @click="remove(a.id)">Delete</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const title = ref('')
const message = ref('')
const startTime = ref('')
const endTime = ref('')

const announcements = computed(() => store.getters['announcements/allAnnouncements'])
const loading = computed(() => store.getters['announcements/isLoading'])
const error = computed(() => store.state.announcements.error)

onMounted(() => {
  store.dispatch('announcements/fetchAnnouncements')
})

function formatDate(date) {
  return new Date(date).toLocaleString()
}

async function submitForm() {
  try {
    await store.dispatch('announcements/createAnnouncements', {
      title: title.value,
      message: message.value,
      start_time: startTime.value,
      end_time: endTime.value,
    })
    title.value = ''
    message.value = ''
    startTime.value = ''
    endTime.value = ''
  } catch (e) {
    console.error(e)
  }
}

function remove(id) {
  store.dispatch('announcements/deleteAnnouncements', id)
}
</script>

<style scoped>
.admin-announcements {
  padding: 1rem 2rem;
  max-width: 700px;
  margin: auto;
}

.announcement-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

textarea {
  width: 100%;
  min-height: 60px;
  padding: 0.5rem;
}

button {
  align-self: flex-start;
}

.loading {
  color: #666;
  font-style: italic;
}
.error {
  color: red;
  margin-top: 0.5rem;
}
</style>
