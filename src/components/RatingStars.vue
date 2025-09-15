<script setup>
const props = defineProps({
  modelValue: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

function updateRating(value) {
  emit('update:modelValue', value)
}
</script>

<template>
  <div class="stars">
    <span
      v-for="n in 5"
      :key="n"
      class="star"
      :class="{ active: n <= modelValue }"
      @click="updateRating(n)"
    >
      ★
    </span>
  </div>
</template>

<style scoped>
.stars {
  display: flex;
  gap: 0.3rem;
  font-size: 2rem;
  cursor: pointer;
}
.star {
  color: #ccc; 
}
.star.active {
  color: gold; 
}
</style>
