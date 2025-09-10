<template>
  <div>
    <nav>
      <router-link to="/counter">Counter</router-link>
      <router-link to="/todos">Todo List</router-link>
    </nav>

    <router-view />
  </div>
</template>

<style>
nav {
  display: flex;
  gap: 15px;
  justify-content: center;
  padding: 20px;
  background: #f5f5f5;
}
router-link {
  text-decoration: none;
  font-weight: bold;
  color: #42b983;
}
</style>
