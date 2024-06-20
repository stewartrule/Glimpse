export function set_scroll_top(selector, offset) {
  document.querySelectorAll(selector).forEach((el) => {
    el.scrollTop = offset;
  });
}

export function set_scroll_left(selector, offset) {
  document.querySelectorAll(selector).forEach((el) => {
    el.scrollLeft = offset;
  });
}

export function scroll_to_top(selector, offset) {
  document.querySelectorAll(selector).forEach((el) => {
    el.scrollTo({
      top: offset,
      left: 0,
      behavior: 'smooth',
    });
  });
}

export function set_translate_x(selector, y) {
  document.querySelectorAll(selector).forEach((el) => {
    el.style.transform = `translateX(${y}px)`;
  });
}
