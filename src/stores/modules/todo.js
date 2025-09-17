const todo = {
  namespaced: true,

  state() {
    return {
      todos: JSON.parse(localStorage.getItem('todos')) || []
    }
  },

  mutations: {
    SET_TODOS(state, todos) {
      state.todos = todos
      localStorage.setItem('todos', JSON.stringify(state.todos))
    },
    ADD_TODO(state, todo) {
      state.todos.push(todo)
      localStorage.setItem('todos', JSON.stringify(state.todos))
    },
    REMOVE_TODO(state, todoToRemove) {
      state.todos = state.todos.filter(todo =>
        todo.title !== todoToRemove.title ||
        todo.task !== todoToRemove.task ||
        todo.date !== todoToRemove.date
      )
      localStorage.setItem('todos', JSON.stringify(state.todos))
    },
    TOGGLE_TODO(state, todoToToggle) {
      const index = state.todos.findIndex(todo =>
        todo.title === todoToToggle.title &&
        todo.task === todoToToggle.task &&
        todo.date === todoToToggle.date
      )
      if (index !== -1) {
        state.todos[index].done = !state.todos[index].done
        localStorage.setItem('todos', JSON.stringify(state.todos))
      }
    },
    UPDATE_TODO(state, updatedTodo) {
      const index = state.todos.findIndex(todo =>
        todo.title === updatedTodo.original.title &&
        todo.task === updatedTodo.original.task &&
        todo.date === updatedTodo.original.date
      )
      if (index !== -1) {
        state.todos[index] = updatedTodo.new
        localStorage.setItem('todos', JSON.stringify(state.todos))
      }
    }
  },

  actions: {
    addTodo({ commit }, todo) {
      commit('ADD_TODO', todo)
    },

    removeTodo({ commit }, todoToRemove) {
      commit('REMOVE_TODO', todoToRemove)
    },

    toggleTodo({ commit }, todoToToggle) {
      commit('TOGGLE_TODO', todoToToggle)
    },

    updateTodo({ commit }, updatedTodo) {
      commit('UPDATE_TODO', updatedTodo)
    }
  },

  getters: {
    todos: (state) => state.todos,
    completedTodos: (state) => state.todos.filter(todo => todo.done),
    todoCount: (state) => state.todos.length
  }
}

export default todo
