/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.res.mjs"],
  theme: {
    fontFamily: {
      'sans': ['DM Sans', 'sans-serif'],
      'mono': ['DM Mono', 'monospace'],
    },
    extend: {
      colors: {
        "color0": "#081619",
        "color1": "#111F22",
        "color2": "#3e4a3c",
        'color3': '#B3B3B3',
        "color10": "#40FB50",
        'color11': '#E6E6E6',
        "color12": "#FFFFFF",
        "eth": "#E9E9E9",
        "usdc": "#2775CA"
      },
      fontFamily: {
        'dm-sans': ['DM Sans', 'sans-serif'],
        'dm-mono': ['DM Mono', 'monospace'],
      },

    },
  },
  plugins: [],
};
