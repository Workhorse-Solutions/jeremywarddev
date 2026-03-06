// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

Turbo.setConfirmMethod((message, element) => {
  const confirmText = element.dataset.turboConfirmText
  const description = element.dataset.turboConfirmDescription
  const instructions = element.dataset.turboConfirmInstructions

  const dialog = document.getElementById("turbo-confirm")
  const dialogDescription = dialog.querySelector("[data-behavior='description']")
  const dialogInstructions = dialog.querySelector("[data-behavior='instructions']")
  const confirmField = dialog.querySelector("[data-behavior='confirm-text']")
  const commitButton = dialog.querySelector("button[value='confirm']")

  dialog.querySelector("[data-behavior='title']").textContent = message
  dialogDescription.textContent = description
  dialogInstructions.textContent = instructions
  confirmField.value = ""

  dialogDescription.style.display = description ? "" : "none"

  if (instructions && confirmText) {
    commitButton.disabled = true
    dialogInstructions.style.display = ""
    confirmField.style.display = ""

    confirmField.addEventListener("input", (event) => {
      commitButton.disabled = (event.target.value !== confirmText)
    }, { once: true })
  } else {
    commitButton.disabled = false
    dialogInstructions.style.display = "none"
    confirmField.style.display = "none"
  }

  dialog.showModal()

  return new Promise((resolve) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue === "confirm")
    }, { once: true })
  })
})
