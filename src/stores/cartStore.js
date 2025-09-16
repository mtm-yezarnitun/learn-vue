import { defineStore } from "pinia";

export const useCartStore = defineStore ( 'cart', {
    state: () => ({
        cart: []
    }),
    getters: {
        total: (state) =>
            state.cart.reduce((sum, item) => sum + item.price * item.quantity, 0)
    },
    actions: {
        loadCart() {
            const saved = localStorage.getItem('cart')
             if (saved) this.cart = JSON.parse(saved)
        },
        
        saveCart() {
            localStorage.setItem('cart', JSON.stringify(this.cart))
        },

        addToCart(product) {
            const item = this.cart.find(p => p.id === product.id)
                if (item) {
                    item.quantity += 1
                } else {
                    this.cart.push({ ...product, quantity: 1 })
                }
            this.saveCart()
        },

        removeFromCart(productId) {
            this.cart = this.cart.filter(item => item.id !== productId)
            this.saveCart()
        },

        clearCart() {
            this.cart = []
            this.saveCart()
        }
    }
})