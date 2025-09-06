import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["activities", "members", "about"];
  connect() {
    this.tabButtons = this.element.querySelectorAll(".tab-button");
    this.tabContents = this.element.querySelectorAll(".tab-content");
    this.activate(this.tabButtons[0]);
  }

  activate(button) {
    const target = button.dataset.tabTarget;
    this.tabButtons.forEach((btn) => {
      btn.classList.remove("bg-white", "dark:bg-gray-900", "dark:text-gray-300");
      btn.classList.add("text-gray-500", "rounded-sm", "dark:text-gray-400");
    });

    button.classList.add("bg-white", "dark:bg-gray-900", "dark:text-gray-300");
    button.classList.remove("text-gray-500", "dark:text-gray-400");
    this.tabContents.forEach((content) => {
      content.classList.add("hidden")
      if (content.dataset.tabsTarget === target) {
        content.classList.remove("hidden")
      }
    });
  }

  click(event) {
    this.activate(event.currentTarget);
  }
}
