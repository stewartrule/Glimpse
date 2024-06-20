(function () {
  class LifecycleEventsElement extends HTMLElement {
    constructor() {
      super();
    }

    connectedCallback() {
      const el = this;

      el.id = el.id || `e_${Math.round(Math.random() * 99999999)}`;

      el.observer = new ResizeObserver(([entry]) =>
        el.dispatchEvent(
          new CustomEvent('resize', {
            detail: {
              id: el.id,
              rect: entry.contentRect,
            },
          })
        )
      );

      window.requestAnimationFrame(() => {
        el.dispatchEvent(
          new CustomEvent('mounted', {
            detail: {
              id: el.id,
              rect: el.getBoundingClientRect(),
            },
          })
        );

        el.observer.observe(el);
      });
    }

    disconnectedCallback() {
      this.observer.disconnect();
      this.dispatchEvent(new CustomEvent('unmounted'));
    }
  }

  customElements.define('lifecycle-events', LifecycleEventsElement);
})();
