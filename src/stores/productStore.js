import { defineStore } from 'pinia'

export const useProductStore = defineStore('product', {
  state: () => ({
    products: []
  }),
  actions: {
    loadProducts() {
      const saved = localStorage.getItem('products')
      if (saved) {
        this.products = JSON.parse(saved)
      } else {
        this.products = [
          { id: 1, name: 'T-shirt', price: 19.99, rating: 0 },
          { id: 2, name: 'Hat', price: 9.99, rating: 0 },
          { id: 3, name: 'Shoes', price: 49.99, rating: 0 }
        ]
      }
    }
  }
})
