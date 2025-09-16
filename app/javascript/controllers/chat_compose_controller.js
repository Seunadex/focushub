import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  handleKey(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      this.element.requestSubmit()
    }
  }
  reset() { this.inputTarget.value = "" }
}