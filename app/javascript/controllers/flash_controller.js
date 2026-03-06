import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  close() {
    this.element.remove()
  }

  pause() {
    this.stopTimer()
  }

  resume() {
    this.startTimer()
  }

  startTimer() {
    if (this.timeoutValue > 0) {
      this.timer = setTimeout(() => this.close(), this.timeoutValue)
    }
  }

  stopTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}
