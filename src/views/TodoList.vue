
<template>
  <div class="container">
    <h1>Vue Todo List</h1>

    <input v-model="newTodo" @keyup.enter="addTodo" placeholder="Enter a new task"/>
    <button @click="addTodo">Add</button>

    <ul>
      <li v-for="(todo, index) in todos" :key="index">
        <template v-if="todo.isEditing">
          <input v-model="todo.text" @keyup.enter="saveEdit(todo)" />
          <button @click="saveEdit(todo)">Save</button>
          <button @click="cancelEdit(todo)">Cancel</button>
        </template>
        
        <template v-else>
          <span :class="{ done: todo.done }" @click="toggleTodo(index)">
            {{ todo.text }}
          </span>
          <button @click="openEditModal(todo)">Edit </button>
          <button @click="removeTodo(index)"> Delete </button>
        </template>
      </li>
    </ul>

    <p v-if="todos.length === 0">No tasks yet. Add something!</p>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal">
        <h2>Edit Todo</h2>
          <input v-model="editText" @keyup.enter="saveEdit" />
          <div class="modal-buttons"></div>
          <button @click="saveEdit">Save</button>
          <button @click="closeModal">Cancel</button>

      </div>
    </div>

  </div>
</template>

<script setup>
import { ref } from 'vue'

const newTodo = ref('')
const todos = ref([])
const showModal = ref(false)
const selectedTodo = ref(null)
const editText = ref('')


function addTodo() {
  const text = newTodo.value.trim()
  if (text !== '') {
    todos.value.push({ text, done: false ,isEditing: false })
    newTodo.value = ''
  }
}
function toggleTodo(index) {
  todos.value[index].done = !todos.value[index].done
}

function removeTodo(index) {
  todos.value.splice(index, 1)
}

function openEditModal(todo) {
  selectedTodo.value = todo
  editText.value = todo.text
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedTodo.value = null
  editText.value = ''
}

function saveEdit() {
  const text = editText.value.trim()
  if (text !== '' && selectedTodo.value) {
    selectedTodo.value.text = text
  }
  closeModal()
}

</script>

<style>
.container {
  max-width: 500px;
  margin: 50px auto;
  text-align: center;
  font-family: Arial, sans-serif;
}

input {
  padding: 10px;
  width: 70%;
  margin-bottom: 10px;
  font-size: 16px;
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

li {
  text-align: left;
  margin: 8px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.done {
  text-decoration: line-through;
  color: gray;
  cursor: pointer;
}
</style>
