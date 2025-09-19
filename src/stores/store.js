import { createStore } from 'vuex';
import todo from './modules/todo'
import weather from './modules/weather'
import blog from './modules/blog'
import auth from './modules/auth'
import users from './modules/users'
import profile from './modules/profile'

const store = createStore({
  modules: {
    todo,
    weather,
    blog,
    auth,
    users,
    profile
    },

});

export default store;
