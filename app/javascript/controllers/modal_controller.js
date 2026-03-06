import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
    this.focusFirstField()
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  close(event) {
    event?.preventDefault()

    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.innerHTML = ""
      return
    }

    this.element.remove()
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }

  focusFirstField() {
    const focusable = this.element.querySelector("[autofocus], input, select, textarea, button")
    focusable?.focus()
  }
}
