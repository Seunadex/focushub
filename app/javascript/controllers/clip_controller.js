import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clip"
export default class extends Controller {
  static targets = ["source"]
  static values = { message: String }
  copy() {
    const source = this.sourceTarget
    console.log(source)
    source.select()
    document.execCommand("copy")
    this.element.querySelector("button").innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-check-icon lucide-check"><path d="M20 6 9 17l-5-5"/></svg>'
    setTimeout(() => {
      this.element.querySelector("button").innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-copy-icon lucide-copy"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>'
    }, 3000)

    this.showFlash(this.messageValue || "Link copied to clipboard.")
  }

  showFlash(message) {
    const frame = document.getElementById("flash")
    if (!frame) return

    const container = document.createElement("div")
    container.setAttribute("data-controller", "flash")

    container.innerHTML = `
      <div class="bg-green-500 text-white px-4 py-2 rounded shadow mb-2 flex items-center animate__animated animate__bounceIn">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
        <span class="ml-2 text-sm"></span>
        <button data-action="click->flash#dismiss" class="ml-5 text-white hover:text-gray-200 cursor-pointer">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>
    `

    container.querySelector("span").textContent = message

    frame.innerHTML = ""
    frame.appendChild(container)
  }
}
