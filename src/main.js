import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'
import store from './stores/store'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(store)
app.use(Toast)
app.mount('#app')
