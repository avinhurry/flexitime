import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customFields", "hours", "minutes"]
  static values = {
    standardMinutes: Number,
    halfMinutes: Number
  }

  connect() {
    this.sync()
  }

  sync() {
    const selectedOption = this.element.querySelector("select[name='amount_preset']")
    const selectedValue = selectedOption?.value
    if (!selectedValue) return

    if (selectedValue === "standard") this.setCreditMinutes(this.standardMinutesValue)
    if (selectedValue === "half") this.setCreditMinutes(this.halfMinutesValue)

    this.customFieldsTarget.classList.toggle("hidden", selectedValue !== "custom")
  }

  setCreditMinutes(totalMinutes) {
    const minutes = Math.max(0, Math.round(totalMinutes))
    this.hoursTarget.value = Math.floor(minutes / 60)
    this.minutesTarget.value = minutes % 60
  }
}
