import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.update()
    this.boundUpdate = this.update.bind(this)
    window.addEventListener("scroll", this.boundUpdate, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundUpdate)
  }

  update() {
    this.element.dataset.atTop = window.scrollY === 0
  }
}
