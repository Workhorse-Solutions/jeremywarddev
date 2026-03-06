import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "trigger"]

  connect() {
    this.boundSync = this.sync.bind(this)
    this.toggleTarget.addEventListener("change", this.boundSync)
    this.sync()
  }

  disconnect() {
    this.toggleTarget.removeEventListener("change", this.boundSync)
  }

  sync() {
    const open = this.toggleTarget.checked
    this.triggerTarget.setAttribute("aria-expanded", String(open))
  }
}
