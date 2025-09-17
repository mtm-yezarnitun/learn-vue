<template>
  <h1>Shop</h1>
  <div class="shop-container">
    <div class="products">
      <ProductList @add-to-cart="cartStore.addToCart" />
    </div>
    <div class="side-cart">
      <ShoppingCart :cart="cartStore.cart" :total="cartStore.total" @remove="cartStore.removeFromCart" @checkout="handleCheckout" />
    </div>
  </div>s
</template>

<script setup>
import { onMounted } from 'vue'
import { useCartStore } from '../stores/cartStore'
import ProductList from '../components/ProductList.vue'
import ShoppingCart from '../components/ShoppingCart.vue'

const cartStore = useCartStore()

onMounted(() => {
  cartStore.loadCart()
})
function handleCheckout(order) {
  console.log("New order:", order)

  window.$toast.success(`🛍️ Thanks ${order.customer.name}, your order total is $${order.total}`, {
    timeout: 5000,
    position: 'top-center'
  })

  cartStore.clearCart()
}
</script>

<style scoped>

.shop-container {
  display: flex;
  flex-direction: row;
  gap: 20px;
}

.products {
    width: 70%;
}
.side-cart {
    width: 30%;
}

</style>
