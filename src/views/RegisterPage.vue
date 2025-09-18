<template>
  <h1> 🖎 Registrations</h1>
  <form @submit.prevent="signup" class="signup-form">
    <input v-model="email" placeholder="Email" />
    <input type="password" v-model="password" placeholder="Password" />
    <button type="submit">Sign Up</button>
  </form>

  <router-link to="/login">Login</router-link>
</template>

<script setup>
import { ref } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";

const router = useRouter();
const store = useStore();
const email = ref("");
const password = ref("");

function signup() {
  store.dispatch("auth/signup", { email: email.value, password: password.value , router });
  email.value =""
  password.value =""
}
</script>

<style scoped>
.signup-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  align-items: center;
}

.signup-form input{
  width: 100%;
  padding: 8px;
  border: 1px solid #43e192;
  border-radius: 4px;
  font-size: 14px;
  font-family: monospace;
}


.signup-form button {
  width: 100px;
  padding: 8px;
  background-color: #43e192;
  border: 1px solid black;
  color: white;
  border-radius: 4px;
  cursor: pointer;
}

.signup-form button:hover {
  background-color: #1e1e1e;
  border: 1px solid #43e192;
}

</style>