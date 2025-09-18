import { createStore } from 'vuex';
import todo from './modules/todo'
import weather from './modules/weather'
import blog from './modules/blog'

const store = createStore({
  modules: {
    todo,
    weather,
    blog
    },

});

export default store;
