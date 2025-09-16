import { defineStore } from 'pinia'

export const useTodoStore = defineStore('todo', {
  state: () => ({
    todos: []
  }),
  actions: {
    loadFromLocalStorage() {
      const saved = localStorage.getItem('todos')
      if (saved) {
        this.todos = JSON.parse(saved)
      }
    },

    saveToLocalStorage() {
      localStorage.setItem('todos', JSON.stringify(this.todos))
    },

    addTodo(todo) {
      this.todos.push(todo)
      this.saveToLocalStorage()
    },

    removeTodo(todoToRemove) {
      this.todos = this.todos.filter(todo =>
        todo.title !== todoToRemove.title ||
        todo.task !== todoToRemove.task ||
        todo.date !== todoToRemove.date
      )
      this.saveToLocalStorage()
    },

    toggleTodo(todoToToggle) {
      const index = this.todos.findIndex(todo =>
        todo.title === todoToToggle.title &&
        todo.task === todoToToggle.task &&
        todo.date === todoToToggle.date
      )
      if (index !== -1) {
        this.todos[index].done = !this.todos[index].done
        this.saveToLocalStorage()
      }
    },
    
    updateTodo(updatedTodo) {
      const index = this.todos.findIndex(todo =>
        todo.title === updatedTodo.original.title &&
        todo.task === updatedTodo.original.task &&
        todo.date === updatedTodo.original.date
      )
      if (index !== -1) {
        this.todos[index] = updatedTodo.new
        this.saveToLocalStorage()
      }
    }
  }
})
