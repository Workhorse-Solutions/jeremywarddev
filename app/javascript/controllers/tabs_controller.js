import { Controller } from "@hotwired/stimulus"

const ACTIVE_CLASSES = ["tab-active", "font-semibold", "text-primary", "border-b-2", "border-primary"]
const INACTIVE_CLASSES = ["text-base-content/60", "hover:text-base-content"]

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const hash = window.location.hash
    const match = hash.match(/^#tab-(\d+)$/)
    const index = match ? parseInt(match[1], 10) : 0
    this.activateTab(index)
  }

  select({ params: { index } }) {
    this.activateTab(index)
    window.location.hash = `#tab-${index}`
  }

  tabTargetConnected() {
    // Re-apply active state when tab bar is refreshed by Turbo Streams
    const activeIndex = this.panelTargets.findIndex(
      panel => !panel.classList.contains("hidden")
    )
    this.activateTab(activeIndex >= 0 ? activeIndex : 0)
  }

  activateTab(index) {
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === index
      ACTIVE_CLASSES.forEach(cls => tab.classList.toggle(cls, isActive))
      INACTIVE_CLASSES.forEach(cls => tab.classList.toggle(cls, !isActive))
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }
}
