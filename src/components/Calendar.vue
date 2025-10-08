<template>
  <div class="calendar-container">

    <div class="calendar-header">
      <div class="calendar-actions">
        <button 
          @click="fetchEvents" 
          class="btn btn-primary" 
          :disabled="loading"
        >
          {{ loading ? 'Loading...' : 'Refresh Events' }}
        </button>
        <button @click="showEventForm = true" class="btn btn-success">
          + New Event
        </button>

        <button 
          v-if="totalEventsCount > 0"
          @click="deleteAllEvents" 
          class="btn btn-danger"
          :disabled="deletingAllEvents || loading"
          title="Delete all events from your calendar"
        >
          🗑️ Delete All Events
        </button>

      </div>
      
      <div class="search-container">
        <div class="search-input-wrapper">
          <input 
            v-model="searchQuery"
            type="text"
            placeholder="Search events by title, description, or location..."
            class="search-input"
          >
          <button 
            v-if="searchQuery" 
            @click="clearSearch" 
            class="search-clear-btn"
            title="Clear search"
          >
            ×
          </button>
        </div>
      </div>
    </div>

    <div v-if="showEventForm" class="event-form-overlay">
      <div class="event-form">
        <h3>Create New Event</h3>
        <div v-if="error" class="error-message">
          {{ error }}
          <button @click="clearError" class="btn-close">×</button>
        </div>
        <form @submit.prevent="createEvent">
          <div class="form-group">
            <label>Title:</label>
            <input 
              v-model="newEvent.title" 
              type="text" 
              required 
              class="form-input"
              placeholder="Meeting with team"
            >
          </div>
          <div class="form-group">
            <label>Description:</label>
            <textarea 
              v-model="newEvent.description" 
              class="form-textarea"
              placeholder="Add details about your event..."
            ></textarea>
          </div>
          <div class="form-group">
            <label>Location:</label>
            <input 
              v-model="newEvent.location" 
              type="text" 
              class="form-input"
              placeholder="Office, Zoom, Restaurant..."
            >
          </div>
          <div class="form-group">
            <label>Attendees (emails, comma-separated):</label>
            <input 
              v-model="newEvent.attendees" 
              type="text" 
              class="form-input"
              placeholder="alice@example.com, bob@example.com"
            >
          </div>
          <div class="form-group">
            <label>Event Color:</label>
            <div class="color-picker">
              <div 
                v-for="color in eventColors" 
                :key="color.id"
                class="color-option"
                :class="{ active: newEvent.colorId === color.id }"
                :style="{ backgroundColor: color.hex }"
                @click="newEvent.colorId = color.id"
                :title="color.name"
              >
                <span v-if="newEvent.colorId === color.id">✓</span>
              </div>
            </div>
          </div>
          <div class="form-group">
            <label>Recurrence:</label>
            <select v-model="newEvent.recurrence">
              <option value="null">None</option>
              <option value="RRULE:FREQ=DAILY;COUNT=7">Daily</option>
              <option value="RRULE:FREQ=WEEKLY;COUNT=4">Weekly</option>
              <option value="RRULE:FREQ=MONTHLY;COUNT=3">Monthly</option>
            </select>
          </div>
          <div class="form-group">  
            <label>Start Time:</label>
            <input 
              v-model="newEvent.start_time" 
              type="datetime-local" 
              required 
              class="form-input"
            >
          </div>
          <div class="form-group">
            <label>End Time:</label>
            <input 
              v-model="newEvent.end_time" 
              type="datetime-local" 
              required 
              class="form-input"
            >
          </div>
          <div class="form-actions">
            <button 
              type="submit" 
              class="btn btn-primary" 
              :disabled="creatingEvent"
            >
              {{ creatingEvent ? 'Creating...' : 'Create Event' }}
            </button>
            <button 
              type="button" 
              @click="cancelCreate" 
              class="btn btn-secondary"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="!isSearching">
      <!-- ongoingEvents -->
      <div class="events-section" >
        <h3>Ongoing Events ({{ ongoingEvents.length }})</h3>
        
        <div v-if="loading && ongoingEvents.length === 0" class="loading-state">
          <div class="spinner"></div>
          <p>Loading your past calendar events...</p>
        </div>
        
        <div v-else-if="ongoingEvents.length === 0" class="no-events">
          <p>No past events found.</p>
          <p v-if="!loading">Try creating your first event!</p>
        </div>
        
        <div v-else class="events-grid">
          <div 
            v-for="oEvent in ongoingEvents" 
            :key="oEvent.id" 
            class="event-card"
            :class="{ 'deleting': deletingEvents.includes(oEvent.id) }"
            :style="{
              borderLeft: `5px solid ${getEventColor(oEvent)}`,
              borderRight: `5px solid ${getEventColor(oEvent)}`
            }"
          >
            <div class="event-header">
              <h4 class="event-title">{{ oEvent.summary || oEvent.title }}</h4>
            </div>
            
            <p v-if="oEvent.description" class="event-description">
              {{ oEvent.description }}
            </p>
            <div class="event-location" v-if="oEvent.location">
              <strong>Location:</strong> {{ oEvent.location }}
            </div>
            <div v-if="oEvent.attendees && oEvent.attendees.length > 0" class="event-location">
              <strong>Attendees:</strong> {{ oEvent.attendees.join(', ') }}
            </div>
            <div class="event-times">
              <div class="event-time">
                <strong>Start:</strong> {{ formatDateTime(oEvent.start?.date_time || oEvent.start_time) }}
              </div>
              <div class="event-time">
                <strong>End:</strong> {{ formatDateTime(oEvent.end?.date_time || oEvent.end_time ) }}
              </div>
            </div>
            <a 
              v-if="oEvent.html_link" 
              :href="oEvent.html_link" 
              target="_blank" 
              class="event-link"
            >
              View in Google Calendar
            </a>
            <div class="event-actions">
              <button 
                @click="openUpdateForm(oEvent)" 
                class="btn-edit"> Edit
              </button>
              <button 
                @click="deleteEvent(oEvent.id)" 
                class="btn-delete"
                :disabled="deletingEvent || deletingEvents.includes(oEvent.id)"
                :title="'Delete ' + (oEvent.title || 'event')"
                >
                <span v-if="deletingEvents.includes(oEvent.id)" class="delete-spinner"></span>
                <span v-else>🗑️</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- upcomingEvents -->
      <div class="events-section">
        <h3>Upcoming Events ({{ events.length }})</h3>
        
        <div v-if="loading && events.length === 0" class="loading-state">
          <div class="spinner"></div>
          <p>Loading your calendar events...</p>
        </div>
        
        <div v-else-if="events.length === 0" class="no-events">
          <p>No upcoming events found.</p>
          <p v-if="!loading">Try creating your first event!</p>
        </div>
        
        <div v-else class="events-grid">
          <div 
            v-for="event in events" 
            :key="event.id" 
            class="event-card"
            :class="{ 'deleting': deletingEvents.includes(event.id) }"
            :style="{
              borderLeft: `5px solid ${getEventColor(event)}`,
              borderRight: `5px solid ${getEventColor(event)}`
            }"
          >
            <div class="event-header">
              <h4 class="event-title">{{ event.summary || event.title }}</h4>
            </div>
            
            <p v-if="event.description" class="event-description">
              {{ event.description }}
            </p>
            <div class="event-location" v-if="event.location">
              <strong>Location:</strong> {{ event.location }}
            </div>
          <div v-if="event.attendees && event.attendees.length > 0" class="event-location">
              <strong>Attendees:</strong> {{ event.attendees.join(', ') }}
          </div>
            <div class="event-times">
              <div class="event-time">
                <strong>Start:</strong> {{ formatDateTime(event.start?.date_time || event.start_time) }}
              </div>
              <div class="event-time">
                <strong>End:</strong> {{ formatDateTime(event.end?.date_time || event.end_time ) }}
              </div>
            </div>
            <a 
              v-if="event.html_link" 
              :href="event.html_link" 
              target="_blank" 
              class="event-link"
            >
              View in Google Calendar
            </a>
            <div class="event-actions">
                <button 
                  @click="openUpdateForm(event)" 
                  class="btn-edit"> Edit
                </button>
                <button 
                  @click="deleteEvent(event.id)" 
                  class="btn-delete"
                  :disabled="deletingEvent || deletingEvents.includes(event.id)"
                  :title="'Delete ' + (event.title || 'event')"
                >
                  <span v-if="deletingEvents.includes(event.id)" class="delete-spinner"></span>
                  <span v-else>🗑️</span>
                </button>
            </div>
          </div>
        </div>
      </div>

      <!-- pastEvents -->
      <div class="events-section">
        <h3>Past Events ({{ pastEvents.length }})</h3>
        
        <div v-if="loading && pastEvents.length === 0" class="loading-state">
          <div class="spinner"></div>
          <p>Loading your past calendar events...</p>
        </div>
        
        <div v-else-if="pastEvents.length === 0" class="no-events">
          <p>No past events found.</p>
          <p v-if="!loading">Try creating your first event!</p>
        </div>
        
        <div v-else class="events-grid">
          <div 
            v-for="pEvent in pastEvents" 
            :key="pEvent.id" 
            class="event-card"
            :class="{ 'deleting': deletingEvents.includes(pEvent.id) }"
            :style="{
              borderLeft: `5px solid ${getEventColor(pEvent)}`,
              borderRight: `5px solid ${getEventColor(pEvent)}`
            }"
          >
            <div class="event-header">
              <h4 class="event-title">{{ pEvent.summary || pEvent.title }}</h4>
            </div>
            
            <p v-if="pEvent.description" class="event-description">
              {{ pEvent.description }}
            </p>
            <div class="event-location" v-if="pEvent.location">
              <strong>Location:</strong> {{ pEvent.location }}
            </div>
            <div v-if="pEvent.attendees && pEvent.attendees.length > 0" class="event-location">
              <strong>Attendees:</strong> {{ pEvent.attendees.join(', ') }}
            </div>
            <div class="event-times">
              <div class="event-time">
                <strong>Start:</strong> {{ formatDateTime(pEvent.start?.date_time || pEvent.start_time) }}
              </div>
              <div class="event-time">
                <strong>End:</strong> {{ formatDateTime(pEvent.end?.date_time || pEvent.end_time ) }}
              </div>
            </div>
            <a 
              v-if="pEvent.html_link" 
              :href="pEvent.html_link" 
              target="_blank" 
              class="event-link"
            >
              View in Google Calendar
            </a>
            <div class="event-actions">
              <button 
                @click="openUpdateForm(pEvent)" 
                class="btn-edit"> Edit
              </button>
              <button 
                @click="deleteEvent(pEvent.id)" 
                class="btn-delete"
                :disabled="deletingEvent || deletingEvents.includes(pEvent.id)"
                :title="'Delete ' + (pEvent.title || 'event')"
              >
              <span v-if="deletingEvents.includes(pEvent.id)" class="delete-spinner"></span>
              <span v-else>🗑️</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="search-results">
      <!-- ongoingEvents searching-->
      <div v-if="searchedEventsByType.ongoing.length > 0" class="events-section">
        <h3 class="search-category">
          <span class="category-badge ongoing">Ongoing</span>
          Events ({{ searchedEventsByType.ongoing.length }})
        </h3>
        <div class="events-grid">
          <div 
            v-for="oEvent in searchedEventsByType.ongoing" 
            :key="oEvent.id" 
            class="event-card"
            :class="{ 'deleting': deletingEvents.includes(oEvent.id) }"
            :style="{
              borderLeft: `5px solid ${getEventColor(oEvent)}`,
              borderRight: `5px solid ${getEventColor(oEvent)}`
            }"
          >
            <div class="event-header">
              <h4 class="event-title">{{ oEvent.summary || oEvent.title }}</h4>
            </div>
            <p v-if="oEvent.description" class="event-description">
              {{ oEvent.description }}
            </p>
            <div class="event-location" v-if="oEvent.location">
              <strong>Location:</strong> {{ oEvent.location }}
            </div>
            <div v-if="oEvent.attendees && oEvent.attendees.length > 0" class="event-location">
              <strong>Attendees:</strong> {{ oEvent.attendees.join(', ') }}
            </div>
            <div class="event-times">
              <div class="event-time">
                <strong>Start:</strong> {{ formatDateTime(oEvent.start?.date_time || oEvent.start_time) }}
              </div>
              <div class="event-time">
                <strong>End:</strong> {{ formatDateTime(oEvent.end?.date_time || oEvent.end_time ) }}
              </div>
            </div>
            <a 
              v-if="oEvent.html_link" 
              :href="oEvent.html_link" 
              target="_blank" 
              class="event-link"
            >
              View in Google Calendar
            </a>
            <div class="event-actions">
              <button @click="openUpdateForm(oEvent)" class="btn-edit">Edit</button>
              <button 
                @click="deleteEvent(oEvent.id)" 
                class="btn-delete"
                :disabled="deletingEvent || deletingEvents.includes(oEvent.id)"
              >
                <span v-if="deletingEvents.includes(oEvent.id)" class="delete-spinner"></span>
                <span v-else>🗑️</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- upcomingEvents -->
      <div v-if="searchedEventsByType.upcoming.length > 0" class="events-section">
        <h3 class="search-category">
          <span class="category-badge upcoming">Upcoming</span>
          Events ({{ searchedEventsByType.upcoming.length }})
        </h3>
        <div class="events-grid">
          <div 
            v-for="event in searchedEventsByType.upcoming" 
            :key="event.id" 
            class="event-card"
            :class="{ 'deleting': deletingEvents.includes(event.id) }"
            :style="{
              borderLeft: `5px solid ${getEventColor(event)}`,
              borderRight: `5px solid ${getEventColor(event)}`
            }"
          >
            <div class="event-header">
              <h4 class="event-title">{{ event.summary || event.title }}</h4>
            </div>
            <p v-if="event.description" class="event-description">
              {{ event.description }}
            </p>
            <div class="event-location" v-if="event.location">
              <strong>Location:</strong> {{ event.location }}
            </div>
            <div v-if="event.attendees && event.attendees.length > 0" class="event-location">
              <strong>Attendees:</strong> {{ event.attendees.join(', ') }}
            </div>
            <div class="event-times">
              <div class="event-time">
                <strong>Start:</strong> {{ formatDateTime(event.start?.date_time || event.start_time) }}
              </div>
              <div class="event-time">
                <strong>End:</strong> {{ formatDateTime(event.end?.date_time || event.end_time ) }}
              </div>
            </div>
            <a 
              v-if="event.html_link" 
              :href="event.html_link" 
              target="_blank" 
              class="event-link"
            >
              View in Google Calendar
            </a>
            <div class="event-actions">
              <button @click="openUpdateForm(event)" class="btn-edit">Edit</button>
              <button 
                @click="deleteEvent(event.id)" 
                class="btn-delete"
                :disabled="deletingEvent || deletingEvents.includes(event.id)"
              >
                <span v-if="deletingEvents.includes(event.id)" class="delete-spinner"></span>
                <span v-else>🗑️</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- pastEvents -->
      <div v-if="searchedEventsByType.past.length > 0" class="events-section">
          <h3 class="search-category">
            <span class="category-badge past">Past</span>
            Events ({{ searchedEventsByType.past.length }})
          </h3>
          <div class="events-grid">
            <div 
              v-for="pEvent in searchedEventsByType.past" 
              :key="pEvent.id" 
              class="event-card"
              :class="{ 'deleting': deletingEvents.includes(pEvent.id) }"
              :style="{
                borderLeft: `5px solid ${getEventColor(pEvent)}`,
                borderRight: `5px solid ${getEventColor(pEvent)}`
              }"
            >
              <!-- Your existing event card content -->
              <div class="event-header">
                <h4 class="event-title">{{ pEvent.summary || pEvent.title }}</h4>
              </div>
              <p v-if="pEvent.description" class="event-description">
                {{ pEvent.description }}
              </p>
              <div class="event-location" v-if="pEvent.location">
                <strong>Location:</strong> {{ pEvent.location }}
              </div>
              <div v-if="pEvent.attendees && pEvent.attendees.length > 0" class="event-location">
                <strong>Attendees:</strong> {{ pEvent.attendees.join(', ') }}
              </div>
              <div class="event-times">
                <div class="event-time">
                  <strong>Start:</strong> {{ formatDateTime(pEvent.start?.date_time || pEvent.start_time) }}
                </div>
                <div class="event-time">
                  <strong>End:</strong> {{ formatDateTime(pEvent.end?.date_time || pEvent.end_time ) }}
                </div>
              </div>
              <a 
                v-if="pEvent.html_link" 
                :href="pEvent.html_link" 
                target="_blank" 
                class="event-link"
              >
                View in Google Calendar
              </a>
              <div class="event-actions">
                <button @click="openUpdateForm(pEvent)" class="btn-edit">Edit</button>
                <button 
                  @click="deleteEvent(pEvent.id)" 
                  class="btn-delete"
                  :disabled="deletingEvent || deletingEvents.includes(pEvent.id)"
                >
                  <span v-if="deletingEvents.includes(pEvent.id)" class="delete-spinner"></span>
                  <span v-else>🗑️</span>
                </button>
              </div>
            </div>
          </div>
      </div>
      
      <div v-if="searchedEvents.length === 0" class="no-search-results">
        <div class="no-events">
          <h3>No events found</h3>
          <p>No events match "{{ searchQuery }}"</p>
          <p>Try searching with different keywords or <button @click="clearSearch" class="btn-link">clear your search</button></p>
        </div>
      </div>

    </div>

    <div v-if="showUpdateForm" class="event-form-overlay">
      <div class="event-form">
        <h3>Update Event</h3>
        <div v-if="error" class="error-message">
          {{ error }}
          <button @click="clearError" class="btn-close">×</button>
        </div>
        <form @submit.prevent="updateEvent">
          <div class="form-group">
            <label>Title:</label>
            <input 
              v-model="updateEventData.title" 
              type="text" 
              required 
              class="form-input"
              placeholder="Meeting with team"
            >
          </div>
          <div class="form-group">
            <label>Description:</label>
            <textarea 
              v-model="updateEventData.description" 
              class="form-textarea"
              placeholder="Add details about your event..."
            ></textarea>
          </div>
          <div class="form-group">
            <label>Location:</label>
            <input 
              v-model="updateEventData.location" 
              type="text" 
              class="form-input"
              placeholder="Office, Zoom, Restaurant..."
            >
          </div>
          <div class="form-group">
            <label>Attendees (emails, comma-separated):</label>
            <input 
              v-model="updateEventData.attendees" 
              type="text" 
              class="form-input"
              placeholder="alice@example.com, bob@example.com"
            >
          </div>
          <div class="form-group">
            <label>Event Color:</label>
            <div class="color-picker">
              <div 
                v-for="color in eventColors" 
                :key="color.id"
                class="color-option"
                :class="{ active: updateEventData.colorId === color.id }"
                :style="{ backgroundColor: color.hex }"
                @click="updateEventData.colorId = color.id"
                :title="color.name"
              >
                <span v-if="updateEventData.colorId === color.id">✓</span>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label>Start Time:</label>
            <input 
              v-model="updateEventData.start_time" 
              type="datetime-local" 
              required 
              class="form-input"
            >
          </div>
          <div class="form-group">
            <label>End Time:</label>
            <input 
              v-model="updateEventData.end_time" 
              type="datetime-local" 
              required 
              class="form-input"
            >
          </div>
          <div class="form-actions">
            <button 
              type="submit" 
              class="btn btn-primary" 
              :disabled="updatingEvent"
            >
              {{ updatingEvent ? 'Updating...' : 'Update Event' }}
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

    <div v-if="showDeleteConfirm" class="modal-overlay">
      <div class="modal">
        <h3>Delete Event</h3>
        <p>Are you sure you want to delete "<strong>{{ eventToDelete?.title || eventToDelete?.summary }}</strong>"?</p>
        <div class="modal-actions">
          <button 
            @click="confirmDelete" 
            class="btn btn-danger"
            :disabled="deletingEvent"
          >
            {{ deletingEvent ? 'Deleting...' : 'Yes, Delete' }}
          </button>
          <button 
            @click="cancelDelete" 
            class="btn btn-secondary"
            :disabled="deletingEvent"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>

    <div v-if="showDeleteAllConfirm" class="modal-overlay">
      <div class="modal">
        <h3>Delete All Events</h3>
        <p>⚠️ Are you sure you want to delete <strong>all {{ totalEventsCount }} events</strong> from your calendar?</p>
        <p class="text-muted">This will remove all ongoing, upcoming, and past events.</p>
        <div class="modal-actions">
          <button 
            @click="confirmDeleteAll" 
            class="btn btn-danger"
            :disabled="deletingAllEvents"
          >
            {{ deletingAllEvents ? 'Deleting...' : `Yes, Delete All ${totalEventsCount} Events` }}
          </button>
          <button 
            @click="cancelDeleteAll" 
            class="btn btn-secondary"
            :disabled="deletingAllEvents"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';

const store = useStore();
const router = useRouter();

const showEventForm = ref(false);
const showUpdateForm = ref(false);
const showDeleteConfirm = ref(false);
const showDeleteAllConfirm = ref(false);
const eventToDelete = ref(null);
const deletingAllEvents = ref(false); 
const deletingEvents = ref([]); 
const searchQuery = ref('');

const eventColors = ref([
  { id: '1', name: 'Lavender', hex: '#7986cb' },
  { id: '2', name: 'Sage', hex: '#33b679' },
  { id: '3', name: 'Grape', hex: '#8e24aa' },
  { id: '4', name: 'Flamingo', hex: '#e67c73' },
  { id: '5', name: 'Banana', hex: '#f6c026' },
  { id: '6', name: 'Tangerine', hex: '#f5511d' },
  { id: '7', name: 'Peacock', hex: '#039be5' },
  { id: '8', name: 'Graphite', hex: '#616161' },
  { id: '9', name: 'Blueberry', hex: '#3f51b5' },
  { id: '10', name: 'Basil', hex: '#0b8043' },
  { id: '11', name: 'Tomato', hex: '#d60000' }
]);

const newEvent = ref({
  title: '',
  description: '',
  start_time: '',
  end_time: '',
  location: '',
  colorId: '1',
  recurrence:''
});

const updateEventData = ref({
  id: null,
  title: '',
  description: '',
  location: '',
  attendees: '',
  start_time: '',
  end_time: '',
  colorId: ''
});

const allEvents = computed (()=> [
  ...ongoingEvents.value,
  ...events.value,
  ...pastEvents.value
]);


const searchedEvents = computed(() => {
  if (!searchQuery.value) return allEvents.value;
  
  const query = searchQuery.value.toLowerCase();
  return allEvents.value.filter(event => 
    (event.title?.toLowerCase().includes(query) ||
     event.summary?.toLowerCase().includes(query) ||
     event.description?.toLowerCase().includes(query) ||
     event.location?.toLowerCase().includes(query))
  );
});

const searchedEventsByType = computed(() => {
  const now = new Date();
  const ongoing = [];
  const upcoming = [];
  const past = [];
  
  searchedEvents.value.forEach(event => {
    const start = new Date(event.start_time || event.start?.date_time);
    const end = new Date(event.end_time || event.end?.date_time);
    
    if (start <= now && end >= now) {
      ongoing.push(event);
    } else if (start > now) {
      upcoming.push(event);
    } else {
      past.push(event);
    }
  });
  
  return { ongoing, upcoming, past };
});

const isSearching = computed(() => searchQuery.value.length > 0);

const events = computed(() => store.getters['calendar/upcomingEvents']);
const pastEvents = computed(() => store.getters['calendar/pastEvents']);
const ongoingEvents = computed(() => store.getters['calendar/ongoingEvents']);
const loading = computed(() => store.getters['calendar/loading']);
const creatingEvent = computed(() => store.getters['calendar/creatingEvent']);
const updatingEvent = computed(() => store.getters['calendar/editingEvent']);
const deletingEvent = computed(() => store.getters['calendar/deletingEvent']);
const error = computed(() => store.getters['calendar/error']);
const isAuthenticated = computed(() => store.getters['auth/isAuthenticated']);
const totalEventsCount = computed(() => ongoingEvents.value.length + events.value.length + pastEvents.value.length );

onMounted(() => {
  if (!isAuthenticated.value) {
    router.push('/login');
    return;
  }
  fetchEvents();
});

async function fetchEvents() {
  if (!isAuthenticated.value) {
    router.push('/login');
    return;
  }
  await store.dispatch('calendar/fetchEvents');
}
  
async function createEvent() {
    if (!isAuthenticated.value) {
      router.push('/login');
      return;
    }
    try {
      const isRecurring = newEvent.value.recurrence && newEvent.value.recurrence !== 'null';
    
      await store.dispatch('calendar/createEvent', newEvent.value);
      cancelCreate();
    
      if (isRecurring) {
          window.$toast.success('Recurring event created! Refreshing events...');
          await fetchEvents();
      } else {
          window.$toast.success('Event created successfully!');
      }
    } catch (error) {
      console.error('Failed to create event:', error);
    }
}

async function updateEvent() {
  if (!isAuthenticated.value) return;
  
  try {
    await store.dispatch('calendar/updateEvent', {
      eventId: updateEventData.value.id,
      eventData: {
        title: updateEventData.value.title,
        description: updateEventData.value.description,
        location: updateEventData.value.location,
        attendees: updateEventData.value.attendees,
        colorId: updateEventData.value.colorId,
        start_time: updateEventData.value.start_time,
        end_time: updateEventData.value.end_time
        
      }
    });
    window.$toast.success('Event updated successfully!');
    cancelUpdate();
  } catch (error) {
    console.error('Failed to update event:', error);
  }
}

function deleteEvent(eventId) {
  const event = events.value.find(e => e.id === eventId)
             || pastEvents.value.find(e => e.id === eventId) 
             || ongoingEvents.value.find( e => e.id === eventId);
  eventToDelete.value = event;
  showDeleteConfirm.value = true;
}

async function deleteAllEvents() {
  if (totalEventsCount.value === 0) {
    window.$toast.warning('No events to delete');
    return;
  }

  showDeleteAllConfirm.value = true;
}

async function confirmDeleteAll() {
  if (totalEventsCount.value === 0) return;
  
  deletingAllEvents.value = true;
  
  try {
    const allEventIds = allEvents.value.map(event => event.id);
    
      for (const eventId of allEventIds) {
        try {
          await store.dispatch('calendar/deleteEvent', eventId);
        } catch (error) {
          console.error(`Failed to delete event ${eventId}:`, error);
        }
      }
    
    window.$toast.success(`All ${allEventIds.length} events deleted successfully!`);
    cancelDeleteAll();
    
    await fetchEvents();
    
  } catch (error) {
    console.error('Failed to delete all events:', error);
    window.$toast.error('Failed to delete all events. Please try again.');
  } finally {
    deletingAllEvents.value = false;
  }
}

function cancelDeleteAll() {
  showDeleteAllConfirm.value = false;
}

function openUpdateForm(event) {
  updateEventData.value = {
    id: event.id,
    title: event.summary || event.title || '',
    description: event.description || '',
    location: event.location || '',
    attendees: event.attendees.join(', ') || '',
    colorId: event.colorId || event.color_id || '1',
    start_time: formatDateTimeForInput(event.start?.date_time || event.start_time),
    end_time: formatDateTimeForInput(event.end?.date_time || event.end_time)
  };
  showUpdateForm.value = true;
}

async function confirmDelete() {
  if (!eventToDelete.value) return;
  
  const eventId = eventToDelete.value.id;
  deletingEvents.value.push(eventId);
  
  try {
    await store.dispatch('calendar/deleteEvent', eventId);
    window.$toast.success('Event deleted successfully!');
  } catch (error) {
    console.error('Failed to delete event:', error);
  } finally {
    const index = deletingEvents.value.indexOf(eventId);
    if (index > -1) {
      deletingEvents.value.splice(index, 1);
    }
    cancelDelete();
  }
}

function cancelUpdate() {
  showUpdateForm.value = false;
  updateEventData.value = {
    id: null,
    title: '',
    description: '',
    start_time: '',
    end_time: '' ,
    location: '',
    attendees: '',
    colorId: '1',
  };
}

function cancelDelete() {
  showDeleteConfirm.value = false;
  eventToDelete.value = null;
}

function cancelCreate() {
  showEventForm.value = false;
  newEvent.value = {
    title: '',
    description: '',
    location: '',
    attendees: '',
    start_time: '',
    end_time: '',
    colorId: '1',
    recurrence: '',
  };
}

function clearError() {
  store.dispatch('calendar/clearError');
}

function formatDateTime(dateTimeString) {
  if (!dateTimeString) return 'N/A';
  return new Date(dateTimeString).toLocaleString();
}

function formatDateTimeForInput(dateTimeString) {
  if (!dateTimeString) return 'N/A';
  return dateTimeString.replace(/\..*$/, '').slice(0, 16);
}

function getEventColor(event) {
  const colorId = event.colorId || event.color_id || '1';
  const color = eventColors.value.find(c => c.id === colorId);
  return color ? color.hex : '#7986cb'; 
}  

function clearSearch() {
  searchQuery.value = '';
}
</script>

<style scoped>
.calendar-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #e0e0e0;
}

.calendar-actions {
  display: flex;
  gap: 10px;
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
  z-index: 1000;
}

.event-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
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

.events-section {
  min-width: 700px;
  margin-top: 20px;
}

.events-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.event-card {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
  position: relative;
}

.event-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.event-card.deleting {
  opacity: 0.6;
  pointer-events: none;
}

.event-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 10px;
}

.event-title {
  margin: 0;
  color: #333;
  font-size: 18px;
  font-weight: 600;
  flex: 1;
  margin-right: 10px;
}

.event-actions {
  flex-shrink: 0;
}

.btn-delete {
  background: none;
  border: none;
  cursor: pointer;
  padding: 5px;
  border-radius: 4px;
  transition: background-color 0.2s;
  font-size: 16px;
}

.btn-delete:hover:not(:disabled) {
  background-color: #ffeaea;
}

.btn-delete:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.delete-spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #d63031;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.event-description {
  color: #666;
  margin-bottom: 15px;
  line-height: 1.4;
}

.event-times {
  margin-bottom: 15px;
}

.event-time {
  color: #666;
  font-size: 14px;
  margin-bottom: 5px;
}

.event-link {
  color: #4285f4;
  text-decoration: none;
  font-size: 14px;
  display: inline-block;
  margin-top: 10px;
}

.event-link:hover {
  text-decoration: underline;
}

.no-events {
  text-align: center;
  padding: 40px;
  color: #666;
  background: #f9f9f9;
  border-radius: 8px;
}

.event-location {
  color: #666 !important;
  margin-bottom: 10px;
} 

.loading-state {
  text-align: center;
  padding: 40px;
  color: #666;
}

.spinner {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #43e192;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  background: #ffeaea;
  color: #d63031;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-close {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #d63031;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 90%;
  max-width: 400px;
  text-align: center;
}

.modal h3 {
  margin: 0 0 15px 0;
  color: #333;
}

.modal p {
  margin-bottom: 25px;
  color: #666;
  line-height: 1.5;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.btn-edit {
  background: none !important;
  color: #333;
}

.btn-danger {
  background: #d63031;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #c02929;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
  min-width: 100px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #4285f4;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #3367d6;
}

.btn-success {
  background: #34a853;
  color: white;
}

.btn-success:hover:not(:disabled) {
  background: #2e8b47;
}

.btn-secondary {
  background: #666;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background: #555;
}

.color-picker {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin: 0 auto;
}

.color-option {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid transparent;
  transition: all 0.2s ease;
  color: white;
  font-weight: bold;
  font-size: 14px;
}

.color-option:hover {
  transform: scale(1.1);
}

.color-option.active {
  border: 2px solid #333;
  transform: scale(1.1);
}

.search-input {
  padding: 10px;
  border-radius: 5px;
}
.search-input-wrapper {
  display: flex;
  align-items: center;
}
.no-search-results {
  min-width: 700px;
}
</style>