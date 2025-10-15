<template>
  <div class="admin-announcements">
    <h1>Announcements</h1>

    <form @submit.prevent="submitForm" class="announcement-form">
      <label>Title:</label>
      <input type="text" v-model="title" placeholder="Announcement Title" required />
      <label>Message:</label>
      <textarea v-model="message" placeholder="Announcement message" required></textarea>
      <div class="datetime-group">
        <label>Start Time:</label>
        <input type="datetime-local" v-model="startTime" required />
      </div>
      <div class="datetime-group">
        <label>End Time:</label>
        <input type="datetime-local" v-model="endTime" required />
      </div>
      <button type="submit" :disabled="loading">{{ loading ? "Creating..." : "Create Announcement" }}</button>
    </form>

    <div v-if="loading" class="loading">Loading...</div>

    <div v-if="announcements.length" class="announcement-list">
      <h3>Existing Announcements</h3>
      <ul>
        <li v-for="a in announcements" :key="a.id" class="announcement-card">
          <div class="card-header">
            <strong>{{ a.title }}</strong>
          </div>
          <p class="card-message">{{ a.message }}</p>
          <small class="card-time">{{ formatDate(a.start_time) }} → {{ formatDate(a.end_time) }}</small>
          <div class="card-actions">
              <button @click="openUpdateForm(a)" class="edit-btn">Edit</button>
              <button @click="remove(a.id)" class="delete-btn">Delete</button>
          </div>
        </li>
      </ul>
    </div>
    
    <div v-else>
      <h3>No Announcements at this Moment!</h3>
    </div>

    <div v-if="showUpdateForm" class="event-form-overlay">
        <div class="event-form">
          <h3>Update Announcement</h3>
          <div v-if="error" class="error-message">
            {{ error }}
            <button @click="clearError" class="btn-close">×</button>
          </div>
          <form @submit.prevent="updateAnnouncements">
            <div class="form-group">
              <label>Title:</label>
              <input 
                v-model="updateAnnouncementData.title" 
                type="text" 
                required 
                class="form-input"
              >
            </div>
            <div class="form-group">
              <label>Message:</label>
              <textarea 
                v-model="updateAnnouncementData.message" 
                class="form-textarea"
              ></textarea>
            </div>
            <div class="form-group">
              <label>Start Time:</label>
              <input 
                v-model="updateAnnouncementData.start_time" 
                type="datetime-local" 
                required 
                class="form-input"
              >
            </div>
            <div class="form-group">
              <label>End Time:</label>
              <input 
                v-model="updateAnnouncementData.end_time" 
                type="datetime-local" 
                required 
                class="form-input"
              >
            </div>
            <div class="form-actions">
              <button 
                type="submit" 
                class="btn btn-primary" 
              >
                Update Announcement
              </button>
              <button 
                type="button" 
                @click="cancelUpdate" 
                class="btn btn-secondary"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useStore } from "vuex";

const store = useStore();
const title = ref("");
const message = ref("");
const formatForInput = (d) => d.toISOString().slice(0,16);
const now = new Date();
const startTime = ref(formatForInput(now));
const endTime = ref("");
const showUpdateForm = ref(false);

const announcements = computed(() => store.getters["announcements/allAnnouncements"]);
const loading = computed(() => store.getters["announcements/isLoading"]);
const error = computed(() => store.state.announcements.error);

const updateAnnouncementData = ref({
  id: null,
  title: '',
  message: '',
  start_time: '',
  end_time: '',
});

onMounted(() => {
  store.dispatch("announcements/fetchAnnouncements");
});

function formatDate(date) {
  return new Date(date).toLocaleString();
}

async function submitForm() {
  try {
    await store.dispatch("announcements/createAnnouncements", {
      title: title.value,
      message: message.value,
      start_time: startTime.value,
      end_time: endTime.value,
    });
    title.value = "";
    message.value = "";
    startTime.value = formatForInput(new Date());
    endTime.value = "";
  } catch (e) {
    console.error(e);
  }
}

function openUpdateForm(a) {
  updateAnnouncementData.value = {
    id: a.id,
    title: a.title || '',
    message: a.message || '',
    start_time: a.start_time ? a.start_time.slice(0,16) : '',
    end_time: a.end_time ? a.end_time.slice(0,16) : ''
  };
  showUpdateForm.value = true;
}

async function updateAnnouncements() {
  try {
    await store.dispatch('announcements/updateAnnouncements', {
      id: updateAnnouncementData.value.id,
      ...updateAnnouncementData.value
    });
    cancelUpdate();
  } catch (err) {
    console.error('Failed to update announcement:', err);
  }
}

function remove(id) {
  store.dispatch("announcements/deleteAnnouncements", id);
}

function cancelUpdate() {
  showUpdateForm.value = false;
  updateAnnouncementData.value = {
    id: null,
    title: '',
    message: '',
    start_time: '',
    end_time: '' ,
  };
}
</script>

<style scoped>
.admin-announcements {
  padding: 2rem;
  max-width: 1440px;
  min-width: 800px;
  margin: auto;
  font-family: Arial, sans-serif;
}

.announcement-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding: 1.5rem;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.announcement-form input,
.announcement-form textarea {
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  border: 1px solid #ccc;
  font-size: 1rem;
}

.announcement-form textarea {
  resize: vertical;
  min-height: 80px;
}

.datetime-group {
  display: flex;
  flex-direction: column;
}

.datetime-group label {
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
  color: #555;
}

button[type="submit"] {
  align-self: flex-start;
  padding: 0.5rem 1.2rem;
  border: none;
  background: #43e192;
  color:#333;
  font-weight: bold;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s;
}

button[type="submit"]:disabled {
  background: #a0c4ff;
  cursor: not-allowed;
}

button[type="submit"]:hover:not(:disabled) {
  color: #43e192;
  background-color: #333;
}

.loading {
  color: #666;
  font-style: italic;
  text-align: center;
}

.error {
  color: red;
  margin-top: 0.5rem;
  text-align: center;
}

.announcement-list ul {
  width: 100%;
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  justify-content: space-between;
  gap: 1em;
  flex-wrap: wrap;
}

.announcement-card {
  min-width: 350px;
  max-width: 350px;
  background: #333;
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 1px 6px rgba(0,0,0,0.1);
}

.card-header {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 0.5rem;
  padding: 5px;
}

.card-message {
  margin: 0.25rem 0;
  color: #fff;
  padding: 5px;
}

.card-time {
  font-size: 0.85rem;
  color: #666;
}

.delete-btn {
  background: #dc3545;
  color: #fff;
  border: 1px solid transparent;
  border-radius: 6px;
  padding: 0.25rem 0.6rem;
  cursor: pointer;
  font-size: 0.85rem;
}

.delete-btn:hover {
  background: #43e192;
  border: 1px solid white;
  color: #333;
}

.edit-btn {
  background: #555;
  color: #fff;
  border: 1px solid transparent;
  border-radius: 6px;
  padding: 0.25rem 0.6rem;
  cursor: pointer;
  font-size: 0.85rem;
}

.edit-btn:hover {
  background: #43e192;
  border: 1px solid white;
  color: #333;
}
.event-form-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 99999;
}

.event-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  z-index: 9999;
}

.form-group {
  margin-bottom: 10px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
  color: #333;
}

.form-input,
.form-textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-textarea {
  height: 80px;
  resize: vertical;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

</style>
