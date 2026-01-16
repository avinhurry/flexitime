import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["elapsed"]
  static values = { start: String }

  connect() {
    if (!this.hasStartValue) return

    this.startTime = new Date(this.startValue)
    if (Number.isNaN(this.startTime.getTime())) return

    this.tick = this.tick.bind(this)
    this.interval = window.setInterval(this.tick, 1000)
    this.tick()
  }

  disconnect() {
    if (this.interval) {
      window.clearInterval(this.interval)
      this.interval = null
    }
  }

  tick() {
    const seconds = Math.max(0, Math.floor((Date.now() - this.startTime.getTime()) / 1000))
    const minutes = Math.floor(seconds / 60)
    const remaining = seconds % 60
    this.elapsedTarget.textContent = `${String(minutes).padStart(2, "0")}:${String(remaining).padStart(2, "0")}`
  }
}
