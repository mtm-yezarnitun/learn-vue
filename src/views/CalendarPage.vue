<template>
  <div class="container">
    <h1>⌘ Calendar</h1>
    <Calendar />
  </div>
</template>

<script setup>
import Calendar from '../components/Calendar.vue'
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem;
}
</style>
