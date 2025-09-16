import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => this.scrollIfNearBottom())
    this.observer.observe(this.element, { childList: true })
    console.log("Chat scroll controller connected")
  }
  disconnect() { this.observer?.disconnect() }
  nearBottom() {
    const threshold = 120
    const el = this.element
    return el.scrollHeight - el.scrollTop - el.clientHeight < threshold
  }
  scrollIfNearBottom() { if (this.nearBottom()) this.scrollToBottom() }
  scrollToBottom() { this.element.scrollTop = this.element.scrollHeight }
}