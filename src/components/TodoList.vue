<template>
  <div class="container">
      <p v-if="successMessage" class="success-message">{{ successMessage }}</p>
      <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

      <input type="date" :min="minDate" v-model="newDate" placeholder="Enter Due Date"  />
      <input v-model="newTitle" placeholder="Enter title" />
      <input v-model="newTask"  @keyup.enter="addTodo" placeholder="Enter a new task"/>
    <br>
    
    <button @click="addTodo">Add</button>

    <table class="todo-table">
      <thead>
        <tr>
          <th>Status</th>
          <th>Title</th>
          <th>Task</th>
          <th>Due Date</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
      <tr v-for="todo in upcomingTodos" :key="todo.title + todo.task + todo.date">
        <td>
          <span :class="{ done: todo.done }" @click="toggleTodo(todo)" style="cursor:pointer">
            {{ todo.done ? 'Done' : 'Pending' }}
          </span>
        </td>
        <td>{{ todo.title }}</td>
        <td>{{ todo.task }}</td>
        <td>{{ todo.date }}</td>
        <td>
          <button @click="openEditModal(todo)">Edit</button>
          <button @click="removeTodo(todo)">Delete</button>
        </td>
      </tr>
      </tbody>
    </table>

    <h2 v-if="pastTodos.length">Past Due Todos</h2>
    <ul v-if="pastTodos.length" id="pastList">
      <li v-for="(todo, index) in pastTodos" :key="'past-' + index">
        ( {{ todo.done ? 'Done' : 'Pending' }} - {{ todo.title }} - {{ todo.task }} Due: {{ todo.date }} )
      </li>
    </ul>

    <p v-if="todos.length === 0">No tasks yet. Add something!</p>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal">
        <h2>Edit Todo</h2>
        <input type="date" v-model="editDate" placeholder="Edit Date" :min="minDate"/>
        <input v-model="editTitle" placeholder="Edit title" />
        <input v-model="editTask" @keyup.enter="saveEdit" placeholder="Edit task" />
        <div class="modal-buttons"></div>
        <button @click="saveEdit">Save</button>
        <button @click="closeModal">Cancel</button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, watch, onMounted , computed } from 'vue'

const newTask = ref('')
const newTitle = ref('')
const newDate = ref('')
const todos = ref([])
const showModal = ref(false)
const selectedTodo = ref(null)
const editTask = ref('')
const editTitle = ref('')
const editDate = ref('')

const successMessage = ref('')
const errorMessage = ref('')

const minDate = new Date().toISOString().split('T')[0]

const upcomingTodos = computed(() => {
  return todos.value.filter(todo =>todo.date >= minDate)
})

const pastTodos = computed(() => {
  return todos.value.filter(todo =>todo.date < minDate)
})


watch(todos, (newTodos) => {
  localStorage.setItem('todos', JSON.stringify(newTodos))
}, { deep: true })

onMounted(() => {
  const saved = localStorage.getItem('todos')
  if (saved) {
    todos.value = JSON.parse(saved)
  }
})

function addTodo() {
  const title = newTitle.value.trim()
  const task = newTask.value.trim()
  const date = newDate.value.trim()
  if (title === '' || task === '' || date === ''){
    errorMessage.value = 'All fields are required.'
    successMessage.value=''

    setTimeout(() => {
      errorMessage.value = ''
    }, 3000)
    return
  }
    todos.value.push({ title, task, date,done: false })

    newTitle.value = ''
    newTask.value = ''
    newDate.value = ''

    successMessage.value = '✅ Todo added successfully!'
    errorMessage.value=''

    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  }

function toggleTodo(todoToToggle) {
   const index = todos.value.findIndex(todo =>
    todo.title === todoToToggle.title &&
    todo.task === todoToToggle.task &&
    todo.date === todoToToggle.date
  )

  if (index !== -1) { 
    todos.value[index].done = !todos.value[index].done
  }
}

function removeTodo(todoToRemove) {
  const index = todos.value.findIndex(todo =>
    todo.title === todoToRemove.title &&
    todo.task === todoToRemove.task &&
    todo.date === todoToRemove.date
  )

  if (index !== -1) {
    todos.value.splice(index, 1)
    successMessage.value = '✅ Todo Removed successfully!'

    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  }
}

function openEditModal(todo) {
  selectedTodo.value = todo
  editTitle.value = todo.title
  editTask.value = todo.task
  editDate.value = todo.date
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedTodo.value = null
  editTitle.value = ''
  editTask.value = ''
}

function saveEdit() {
  const title = editTitle.value.trim()
  const task = editTask.value.trim()
  const date = editDate.value.trim()
  if (title !== '' && task !== '' && date != '' && selectedTodo.value) {
    selectedTodo.value.title = title
    selectedTodo.value.task = task
    selectedTodo.value.date = date

    successMessage.value = '✅ Todo updated successfully!'

    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  }
  closeModal()
}

</script>

<style scoped>
.container {
  max-width: 1120px;
  margin: 20px auto;
  text-align: center;
}

input {
  padding: 10px;
  width: 70%;
  margin-bottom: 10px;
  font-size: 16px;
}
.todo-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.todo-table th,
.todo-table td {
  padding: 10px;
  border: 1px solid #ccc;
  text-align: left;
}

.todo-table th:first-child {
  min-width: 60px;
}

.todo-table th {
  background-color: #000000;
}

.done {
  text-decoration: line-through;
  color: gray;
}

button {
  padding: 10px 15px;
  margin-left: 5px;
  font-size: 14px;
}

ul {
  list-style: none;
  padding: 0;
}
#pastList {
  display: block;
  padding: 20px;
  gap: 20px;
}

li {
  text-align: left;
  margin: 8px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 20px;
}

.done {
  text-decoration: line-through;
  color: gray;
  cursor: pointer;
}
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px); 
}

.modal {
  background: rgb(33, 33, 33);
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.3);
  width: 90%;
  max-width: 400px;
}

.modal input {
  display: block;
  width: 100%;
  padding: 10px;
  margin: 10px 0;
  font-size: 16px;
}

.modal-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.success-message {
  color: green;
  font-weight: bold;
  margin-top: 10px;
}

.error-message {
  color: red;
  font-weight: bold;
  margin-top: 10px;
}

</style>
