const defaultTheme = require('tailwindcss/defaultTheme');

const scheme = [
  [45, 43, 44], // black
  [255, 255, 255], // white
  [250, 250, 250], // grey
  [240, 240, 240], // grey 2
  [160, 160, 160], // dark grey

  // Theme colors
  [254, 90, 42], // orange
  [255, 242, 238], // orange light

  [127, 191, 127], // green
  [245, 255, 245], // green light

  [163, 116, 235], // purple
  [246, 240, 255], // purple light

  [51, 85, 239], // blue
  [240, 242, 255], // blue light
];

const colors = {};
for (let i = 0; i < scheme.length; i++) {
  const [r, g, b] = scheme[i];
  colors[`color-${i + 1}`] = `rgba(${r}, ${g}, ${b}, ${100})`;

  for (let opacity = 0; opacity <= 100; opacity += 10) {
    colors[`color-${i + 1}-${opacity}`] = `rgba(${r}, ${g}, ${b}, ${
      opacity / 100
    })`;
  }
}

const spacing = {};
for (let i = 0; i <= 120; i++) {
  spacing[i] = `${i * 0.5}rem`;
}

module.exports = {
  content: ['./index.html', './src/**/*.{gleam,mjs}'],
  theme: {
    extend: {
      colors,
      spacing,
      scrollPadding: spacing,
      borderRadius: spacing,
      fontFamily: {
        sans: ['Inter', 'Arial', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [require('@tailwindcss/container-queries')],
};
