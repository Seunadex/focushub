import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const flashNode = this.element;

    setTimeout(() => {
      this.animateCSS(flashNode, "fadeOutUp").then(() => {
        flashNode.remove();
      });
    }, 4000);
  }

  dismiss() {
    const flashNode = this.element;
    this.animateCSS(flashNode, "fadeOutUp").then(() => {
      flashNode.remove();
    });
  }

  animateCSS(node, animation) {
    return new Promise((resolve, _reject) => {
      const animationName = `animate__${animation}`;
      node.classList.add("animate__animated", animationName);

      function handleAnimationEnd(event) {
        event.stopPropagation();
        node.classList.remove("animate__animated", animationName);
        node.removeEventListener("animationend", handleAnimationEnd);
        resolve("Animation ended");
      }

      node.addEventListener("animationend", handleAnimationEnd, { once: true });
    });
  }
}
