import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import Toast from 'vue-toastification'
import store from './stores/store'
import 'vue-toastification/dist/index.css'
import './style.css'

store.dispatch("auth/init");

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(store)
app.use(Toast)
app.mount('#app')
