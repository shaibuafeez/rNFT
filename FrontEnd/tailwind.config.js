/** @type {import('tailwindcss').Config} */
import Colors from './src/assets/styles';

module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        ...Colors
      },
      fontFamily: {
        verdana: ['Verdana', 'sans-serif'],
        inter: ['Inter', 'sans-serif'],
        cormorant: ['Cormorant Infant', 'sans-serif'],
        courier: ['Courier Prime', 'sans-serif']
      },
    },
  },
  plugins: [],
}

