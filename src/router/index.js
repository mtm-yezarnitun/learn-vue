import { createRouter, createWebHistory } from 'vue-router'
import Counter from '../views/Counter.vue'
import TodoList from '../views/TodoList.vue'

const routes = [
  { path: '/', redirect: '/counter' },
  { path: '/counter', component: Counter },
  { path: '/todos', component: TodoList },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
