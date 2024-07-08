/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.res.mjs"],
  theme: {
    extend: {
      colors: {
        "color0": "#081619",
        "color1": "#111F22",
        "color2": "#3e4a3c",
        "color10": "#40FB50",
        "color12": "#FFFFFF",
      }
    },
  },
  plugins: [],
};
