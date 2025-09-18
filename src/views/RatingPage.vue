<template>
  <div class="container">
    <h1>★ Product Ratings</h1>

    <div v-for="product in products" :key="product.id" class="product-card">
      <h3>{{ product.name }}</h3>
      <p>${{ product.price }}</p>

      <RatingStars v-model="product.rating" />

      <p v-if="product.rating">You rated this: {{ product.rating }} / 5</p>
    </div>

    <button @click="submitRatings" class="submit-btn">Save Ratings</button>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import RatingStars from '../components/RatingStars.vue'

const stored = localStorage.getItem('products')
const products = ref(
  stored ? JSON.parse(stored) : [
    { id: 1, name: 'T-shirt', price: 19.99, rating: 0 },
    { id: 2, name: 'Hat', price: 9.99, rating: 0 },
    { id: 3, name: 'Shoes', price: 49.99, rating: 0 }
  ]
)

watch(products, (newVal) => {
  localStorage.setItem('products', JSON.stringify(newVal))
}, { deep: true })

function submitRatings() {
   window.$toast.success(`Ratings Updated Successfully !`, {
    timeout: 5000,
    position: 'top-center'
  })
}

 

</script>

<style scoped>
.product-card {
  margin-bottom: 1.5rem;
  border: 1px solid #ddd;
  padding: 1rem;
  border-radius: 8px;
}
.submit-btn {
  margin-top: 1rem;
  background-color: #43e192;
  color: rgb(6, 6, 6);
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}
</style>
