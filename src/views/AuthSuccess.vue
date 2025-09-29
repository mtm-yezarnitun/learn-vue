<template>
  <p>Logging you in...</p>
</template>

<script setup>
import { useRouter } from "vue-router";
import { useStore } from "vuex";
import axios from "axios";

const router = useRouter();
const store = useStore();

const params = new URLSearchParams(window.location.search);
const token = params.get("token");

if (token) {
  store.commit("auth/setToken", token);

  axios.get("http://localhost:3000/api/v1/profile")
    .then(res => {
      store.commit("auth/setUser", res.data);
      router.replace("/dashboard");
      window.$toast.success("Logged in Via Google Successfully !")
    })
    .catch(err => {
      console.error("Profile fetch failed:", err);
      router.replace("/login");
    });

} else {
  router.replace("/login");                    
}
</script>
