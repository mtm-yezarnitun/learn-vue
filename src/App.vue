<template>
  <div>
    <nav v-if="$route.path !== '/dashboard' && $route.path !== '/login' && $route.path !== '/register'">
      <ul>
        <li>
          <router-link to="/dashboard">📊</router-link>
        </li>
        <li>
          <router-link to="/blog">Blog</router-link>
        </li>
        <li>
          <router-link to="/todos">Todo List</router-link>
        </li>
        <li>
          <router-link to="/weather">Weather</router-link>
        </li>
        <li>
          <router-link to="/shop">Shop</router-link>
        </li>
        <li>
          <router-link to="/rating">Rating</router-link>
        </li>
        <li>
          <router-link to="/calculator">Calculator</router-link>
        </li>
        <li>
          <router-link to="/counter">Counter</router-link>
        </li>
      </ul>

      <div class="user-info">
        <template v-if="isAuthenticated">
          <span>{{ user.email }}</span>
          <button @click="logout">Logout</button>
        </template>
        <template v-else>
          <span>
            <router-link to="/login">Login/Register</router-link>
          </span>
        </template>
      </div>
    </nav>

    <router-view />
  </div>
</template>

<script setup>
import { useStore } from "vuex";
import { useToast } from 'vue-toastification'
import { computed, onMounted } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const store = useStore();
const toast = useToast();

const user = computed(() => store.getters["auth/user"]);
const isAuthenticated = computed(() => store.getters["auth/isAuthenticated"]);

onMounted(() => {
  window.$toast = toast
})


function logout() {
  store.dispatch("auth/logout", {router});
}

</script>

<style>

h1 {
  color: #43e192;
}

h3 {
  color: #43e192;
  margin-right: 20px;
}
a {
  text-decoration: none;
  color: #555 !important;
  padding: 20px;

}
a:hover {
  color: grey;
}

nav {
  position: absolute;
  background-color: black;
  padding: 10px;
  top: 0;
  right: 0;
  width: 100%;  
  display: flex;
  justify-content: space-between;
  align-items: center;


}
ul {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 30px;
}
ul li {
  font-size: 14px;

  list-style: none;
}
router-link {
  text-decoration: none;
  font-weight: bold;
  color: #ebf1ee;
  border: 1px solid transparent;
}
.router-link-active {
  font-weight: bold;
  color: #43e192 !important;
}

</style>
