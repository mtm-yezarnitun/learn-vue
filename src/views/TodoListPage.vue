<template>
  <div class="container">
    <h1>Todo Lists</h1>
    <TodoList />
  </div>
</template>


<script setup>
import TodoList from '../components/TodoList.vue'
</script>

<style>
.container {
  text-align: center;
  padding-top: 50px;
}
button {
  margin: 5px;
  padding: 10px 20px;
  font-size: 16px;
}
</style>
