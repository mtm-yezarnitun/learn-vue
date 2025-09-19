<template>
  <div class="profile-page">
    <h1>My Profile</h1>

    <div v-if="loading">Loading...</div>

    <form v-else @submit.prevent="submitProfile">
      <div>
        <label>Name:</label>
        <input v-model="form.name" type="text" required />
      </div>
      <div>
        <label>Email:</label>
        <input v-model="form.email" type="email" required />
      </div>

      <div>
        <label>New Password:</label>
        <input v-model="form.password" type="password" />
      </div>

      <div>
        <label>Confirm Password:</label>
        <input v-model="form.password_confirmation" type="password" />
      </div>

      <button type="submit">Update Profile</button>
    </form>
  </div>
</template>

<script setup>
import { reactive, computed, onMounted } from "vue";
import store from "../stores/store";

const form = reactive({
  name: "",
  email: "",
  password: "",
  password_confirmation: "",
});

const loading = computed(() => store.getters["profile/loading"]);
const currentUser = computed(() => store.getters["profile/currentUser"]);

onMounted(async () => {
  await store.dispatch("profile/fetchProfile");
  if (currentUser.value) {
    form.name = currentUser.value.name;
    form.email = currentUser.value.email;
  }
});

async function submitProfile() {
  const res = await store.dispatch("profile/updateProfile", form);
  if (res.success) {
    window.$toast.success("Profile updated successfully!");
    form.password = "";
    form.password_confirmation = "";
  } else {
    window.$toast.error("Could not update profile!");
  }
};

</script>

<style scoped>
.profile-page {
  width: 500px;
  margin: 50px auto;
  padding: 30px;
  border: 1px solid #43e192;
  border-radius: 12px;
  font-family: Arial, sans-serif;
  color: #43e192;
}

h1 {
  text-align: center;
  margin-bottom: 25px;
  font-size: 32px;
}

form div {
  text-align: left;
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
}

label {
  margin-bottom: 5px;
  font-weight: bold;
}

input {
  padding: 10px;
  border: 1px solid #43e192;
  border-radius: 6px;
  font-size: 14px;
  background-color: #1e1e1e;
  color: #43e192;
}

input::placeholder {
  color: #43e19299;
}

button {
  width: 100%;
  padding: 12px;
  background-color: #43e192;
  border: 1px solid black;
  border-radius: 6px;
  color: #1e1e1e;
  font-weight: bold;
  font-size: 16px;
  cursor: pointer;
  transition: 0.2s all;
}

button:hover {
  background-color: #1e1e1e;
  color: #43e192;
  border: 1px solid #43e192;
}

.loading {
  text-align: center;
  font-size: 16px;
  margin-bottom: 20px;
  color: #43e192;
}
</style>

