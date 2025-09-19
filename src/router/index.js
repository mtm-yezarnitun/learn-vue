import { createRouter, createWebHistory } from 'vue-router'
import store from '../stores/store'
import Counter from '../views/CounterPage.vue'
import TodoList from '../views/TodoListPage.vue'
import Calculator from '../views/CalculatorPage.vue'
import Shop from '../views/ShopPage.vue'
import Rating from '../views/RatingPage.vue'
import Weather from '../views/WeatherPage.vue'
import Dashboard from '../views/Dashboard.vue'
import Blog from '../views/BlogPage.vue'
import Post from '../views/PostDetails.vue'
import Login from '../views/LoginPage.vue'
import Register from '../views/RegisterPage.vue'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/counter', component: Counter },
  { path: '/todos', component: TodoList },
  { path: '/calculator', component: Calculator },
  { path: '/shop', component: Shop },
  { path: '/rating', component: Rating },
  { path: '/weather', component: Weather },
  { path: '/dashboard', component: Dashboard },
  { path: "/blog", component: Blog },
  { path: "/blog/:id", component: Post },
  { path: "/login", component: Login },
  { path: "/register", component: Register }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from,next) => {
  const publicPages = ['/login', '/register']
  const authRequired = !publicPages.includes(to.path)
  const loggedIn = store.getters['auth/isAuthenticated']

  if (authRequired && !loggedIn) {
    return next('/login')
  }

  next()
})

export default router
