<template>
  <div class="admin-users">
    <h1>Users Management</h1>

    <div v-if="error" class="error">{{ error }}</div>

    <form @submit.prevent="onSubmit">
      <input v-model="form.email" placeholder="Email" required />
      <input v-model="form.password" type="password" placeholder="Password" :required="!form.id"/>
      <select v-model="form.role">
        <option value="user">User</option>
        <option value="admin">Admin</option>
      </select>
      <button type="submit">{{ form.id ? 'Update' : 'Create' }}</button>
      <button type="button" @click="resetForm">Cancel</button>
    </form>

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Email</th>
          <th>Role</th>
          <th>Actions</th>
          <th>Created At</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.id">
          <td>{{ user.id }}</td>
          <td>{{ user.email }}</td>
          <td>{{ user.role }}</td>
          <td>{{ user.created_at}}</td>
          <td>
            <button @click="editUser(user)">Edit</button>
            <button @click="deleteUser(user.id)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useStore } from "vuex";
const store = useStore();

const form = ref({
  id: null,
  email: "",
  password: "",
  role: "user",
});

const users = computed(() => store.getters["users/allUsers"]);
const error = computed(() => store.getters["users/getError"]);

const onSubmit = async () => {
  if (form.value.id) {
    store.dispatch("users/updateUser" ,{ id: form.value.id, userData: form.value });
  } else {
   store.dispatch("users/createUser", form.value);
  }
  resetForm();
};

const editUser = (user) => {
  form.value = { ...user, password: "" };
};

const deleteUser = (id) => {
  if (confirm("Are you sure you want to delete this user?")) {
    store.dispatch("users/deleteUser", id);
  }
};

const resetForm = () => {
  form.value = { id: null, email: "", password: "", role: "user" };
};

onMounted(() => {
 store.dispatch("users/fetchUsers")
});
</script>

<style scoped>
.admin-users {
  padding: 20px;
  max-width: 900px;
  margin: auto;
  font-family: Arial, sans-serif;
  color:#43e192;
}

.admin-users h1 {
  margin-bottom: 20px;
  text-align: center;
  font-size: 40px;
  color: #43e192;
}

.error {
  border: 1px solid #ff4d4d;
  padding: 10px;
  border-radius: 6px;
  color: #b30000;
  margin-bottom: 15px;
  text-align: center;
}

form {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
  margin-bottom: 20px;
  padding: 15px;
  border-radius: 8px;
}

form input,
form select {
  flex: 1 1 200px;
  padding: 8px 10px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 14px;
}

form button {
  padding: 8px 14px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background 0.2s ease;
}

form button[type="submit"] {
  background: #333;
  color: white;
}

form button[type="submit"]:hover {
  background: #43e192;
  color: #333;
}

form button[type="button"] {
  background: #43e192;
  color: #333;
}

form button[type="button"]:hover {
  background: #bbb;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}



th, td {
  padding: 12px;
  text-align: left;
  font-size: 14px;
  border-bottom: 1px solid #ddd;
}

tr:hover {
  background: #43e192;
  color: #333;
}

td button {
  margin-right: 6px;
  padding: 6px 12px;
  font-size: 13px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

td button:first-of-type {
  background: #43e192;
  color: #333;
}

td button:first-of-type:hover {
  background: #333;
  color: #43e192;
}

td button:last-of-type {
  background: #333;
  color: #43e192;
  border: 1px solid #43e192;
}

td button:last-of-type:hover {
  background: #43e192;
  color: #333;
  border: 1px solid #333;
}
</style>

