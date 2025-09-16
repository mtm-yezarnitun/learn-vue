import { createRouter, createWebHistory } from 'vue-router'
import Counter from '../views/CounterPage.vue'
import TodoList from '../views/TodoListPage.vue'
import Calculator from '../views/CalculatorPage.vue'
import Shop from '../views/ShopPage.vue'
import Rating from '../views/RatingPage.vue'
import Weather from '../views/WeatherPage.vue'
import Dashboard from '../views/Dashboard.vue'

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/counter', component: Counter },
  { path: '/todos', component: TodoList },
  { path: '/calculator', component: Calculator},
  { path: '/shop', component: Shop},
  { path: '/rating', component: Rating},
  { path: '/weather', component: Weather},
  { path: '/dashboard', component: Dashboard},
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
