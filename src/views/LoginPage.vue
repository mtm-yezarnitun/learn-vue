<template>
  <h1>🖔 Login</h1>
  <form @submit.prevent="login" class="login-form">
    <input v-model="email" placeholder="Email" />
    <input type="password" v-model="password" placeholder="Password" />
    <button type="submit">Login</button>
  </form>

  <div id="googleBtn"></div>

  <router-link to="/register">Register</router-link>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";
import axios from "axios";

const router = useRouter();
const store = useStore();
const email = ref("");
const password = ref("");

function login() {
  store.dispatch("auth/login", { email: email.value, password: password.value, router });
  email.value = "";
  password.value = "";
}

function handleGoogleResponse(response) {

  if (!response.credential) {
    console.error("No id_token received");
    return;
  }

  axios.post("http://localhost:3000/api/v1/google_login",
    { id_token: response.credential },
    { headers: { "Content-Type": "application/json" } }
  ).then(res => {
    store.commit("auth/setToken", res.data.token);
    store.commit("auth/setUser", res.data.user);
    window.$toast.success('Google Account Logged in successfully!')
    router.push("/dashboard");
    
  }).catch(err => {
    console.error("Google login failed", err.response?.data || err);
  });
}

onMounted(() => {
  window.google.accounts.id.initialize({
    client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
    callback: handleGoogleResponse
  });

  window.google.accounts.id.renderButton(
    document.getElementById("googleBtn"),
    { theme: "outline", size: "large" }
  );
});



const googleLoginUrl = `https://accounts.google.com/o/oauth2/v2/auth?` +
  new URLSearchParams({
    client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
    redirect_uri: import.meta.env.VITE_GOOGLE_REDIRECT_URI,
    response_type: 'code',
    scope: 'openid email profile',
    access_type: 'offline',
    prompt: 'consent'
  }).toString();

</script>

<style scoped>
.login-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  align-items: center;
}

.login-form input {
  width: 100%;
  padding: 8px;
  border: 1px solid #43e192;
  border-radius: 4px;
  font-size: 14px;
  font-family: monospace;
}

.login-form button {
  width: 100px;
  padding: 8px;
  background-color: #43e192;
  border: 1px solid black;
  color: white;
  border-radius: 4px;
  cursor: pointer;
}

.login-form button:hover {
  background-color: #1e1e1e;
  border: 1px solid #43e192;
}
</style>
