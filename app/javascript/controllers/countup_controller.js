import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: Number,
    end: Number,
    duration: { type: Number, default: 500 }
  }

  connect() {
    this.animationFrame = null
    this.element.dataset.countupState = "running"
    this.start = this.normalizeValue(this.startValue)
    this.end = this.normalizeValue(this.endValue)
    this.duration = this.normalizeDuration(this.durationValue)

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.textContent = this.formatMinutes(this.end)
      this.element.dataset.countupState = "done"
      return
    }

    if (this.start === this.end || this.duration === 0) {
      this.element.textContent = this.formatMinutes(this.end)
      this.element.dataset.countupState = "done"
      return
    }

    this.startTime = null
    this.element.textContent = this.formatMinutes(this.start)
    this.animate = this.animate.bind(this)
    this.animationFrame = window.requestAnimationFrame(this.animate)
  }

  animate(timestamp) {
    if (!this.startTime) this.startTime = timestamp
    const elapsed = timestamp - this.startTime
    const progress = Math.min(elapsed / this.duration, 1)
    const value = Math.round(this.start + (this.end - this.start) * progress)

    this.element.textContent = this.formatMinutes(value)

    if (progress < 1) {
      this.animationFrame = window.requestAnimationFrame(this.animate)
    } else {
      this.element.dataset.countupState = "done"
    }
  }

  disconnect() {
    if (this.animationFrame) {
      window.cancelAnimationFrame(this.animationFrame)
      this.animationFrame = null
    }
  }

  formatMinutes(totalMinutes) {
    const minutes = Math.max(0, Math.round(totalMinutes))
    const hours = Math.floor(minutes / 60)
    const remaining = minutes % 60
    return `${hours}h ${remaining}m`
  }

  normalizeValue(value) {
    return Number.isFinite(value) ? value : 0
  }

  normalizeDuration(value) {
    if (Number.isFinite(value) && value > 0) return value
    return 500
  }
}
