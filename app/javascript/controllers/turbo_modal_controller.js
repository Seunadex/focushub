import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="turbo-modal"
export default class extends Controller {
  static targets = ["modal"];
  connect() {
    this.modalTarget.classList.remove("hidden");
    this.modalTarget.classList.add(
      "fixed",
      "inset-0",
      "z-50",
      "flex",
      "items-center",
      "justify-center",
      "bg-black",
      "bg-opacity-50"
    );
    this.modalTarget.setAttribute("role", "dialog");
    this.modalTarget.setAttribute("aria-modal", "true");
    this.modalTarget.removeAttribute("aria-hidden");
  }

  close() {
    this.modalTarget.remove();
  }

  closeWithEscape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  closeWithClickOutside(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }
}
