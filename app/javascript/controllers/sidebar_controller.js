import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="sidebar"
export default class extends Controller {
  static PANEL_OPEN_ICON = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-panel-left-open-icon lucide-panel-left-open"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/><path d="m14 9 3 3-3 3"/></svg>';
  static PANEL_CLOSE_ICON = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-panel-left-close-icon lucide-panel-left-close"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/><path d="m16 15-3-3 3-3"/></svg>';

  toggle() {
    const sidebar = document.querySelector("#sidebar");
    const sidebarTexts = document.querySelectorAll(".sidebar-text");
    const fullLogo = document.querySelector(".full-logo");
    const mobileLogo = document.querySelector(".mobile-logo");

    sidebar.classList.add("transition-all", "duration-300");

    if (sidebar.classList.contains("lg:w-50")) {
      sidebar.classList.remove("lg:w-50");
      sidebar.classList.add("w-15");

      setTimeout(() => {
        fullLogo.style.display = "none";
        mobileLogo.classList.remove("lg:hidden", "inline");
      }, 150);
      this.element.innerHTML = this.constructor.PANEL_OPEN_ICON;

      sidebarTexts.forEach((text) => {
        setTimeout(() => {
          text.classList.add("hidden");
          text.classList.remove("lg:inline");
        }, 100);
      });
    } else {
      sidebar.classList.remove("w-15");
      sidebar.classList.add("lg:w-50");
      this.element.innerHTML = this.constructor.PANEL_CLOSE_ICON;
      setTimeout(() => {
        mobileLogo.classList.add("lg:hidden");
        fullLogo.style.display = "block";
      }, 150);

      sidebarTexts.forEach((text) => {
        setTimeout(() => {
          text.classList.remove("hidden");
          text.classList.add("lg:inline");
        }, 150);
      });
    }
  }
}
