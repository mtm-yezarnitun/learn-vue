import { createRouter, createWebHistory } from 'vue-router'
import Counter from '../views/CounterPage.vue'
import TodoList from '../views/TodoListPage.vue'
import Calculator from '../views/CalculatorPage.vue'
import Shop from '../views/ShopPage.vue'

const routes = [
  { path: '/', redirect: '/counter' },
  { path: '/counter', component: Counter },
  { path: '/todos', component: TodoList },
  { path: '/calculator', component: Calculator},
  { path: '/shop', component: Shop},
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
