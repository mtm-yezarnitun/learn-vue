import { createStore } from 'vuex';
import todo from './modules/todo'
import weather from './modules/weather'
import blog from './modules/blog'
import auth from './modules/auth'

const store = createStore({
  modules: {
    todo,
    weather,
    blog,
    auth
    },

});

export default store;
