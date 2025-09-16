<template>
  <div class="products">
    <div v-for="product in productStore.products" :key="product.id" class="product-card">
      <h3>{{ product.name }}</h3>
      <p>${{ product.price }}</p>
      <RatingStars :model-value="product.rating" />
      <button @click="$emit('add-to-cart', product)">Add to Cart</button>
    </div>
  </div>
</template>

<script setup>
import { useProductStore } from '../stores/productStore'
import { onMounted } from 'vue'
import RatingStars from './RatingStars.vue'

const productStore = useProductStore()

onMounted(() => {
  productStore.loadProducts()
})
</script>

<style scoped>
.products {
  display: flex;
  gap: 1rem;
  width: 100% !important;
}
.product-card {
  border: 1px solid #ffffff;
  padding: 20px;
  width: 200px !important;
  text-align: center;
}
button {
  margin-top: 0.5rem;
}
</style>
