<template>
  <div>
    <nav v-if="$route.path !== '/dashboard'">
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
    </nav>
    <router-view />
  </div>
</template>

<script setup>
import { useToast } from 'vue-toastification'
import { onMounted } from 'vue';

const toast = useToast()

onMounted(() => {
  window.$toast = toast
})
</script>

<style>
h1 {
  color: #43e192;
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
  padding: 20px;
  top: 0;
  right: 0;
  width: 100%;  
}
ul {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 100px;
}
ul li {
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
