import { Controller } from "@hotwired/stimulus"

// Feedback while a lesson video uploads. A file of a few hundred megabytes
// takes minutes, and without a bar moving the page looks frozen, which is how
// people end up hitting reload halfway through.
export default class extends Controller {
  static targets = ["wrapper", "bar", "status", "submit"]
  static values = { uploadingText: String, doneText: String, errorText: String }

  connect() {
    this.uploads = new Map()
    this.failed = new Set()
  }

  start(event) {
    this.uploads.set(event.detail.id, 0)
    if (this.hasWrapperTarget) this.wrapperTarget.classList.remove("hidden")
    this.setStatus(this.uploadingTextValue)
    this.disableSubmit(true)
  }

  progress(event) {
    // Rails keeps animating 90-99% for a moment after a failed request, which
    // would paint "uploading 90%" over the error and leave the bar looking stuck.
    if (this.failed.has(event.detail.id)) return
    this.uploads.set(event.detail.id, event.detail.progress)
    this.render()
  }

  error(event) {
    // The browser would otherwise report this only in the console.
    event.preventDefault()
    this.failed.add(event.detail.id)
    this.setStatus(`${this.errorTextValue} ${event.detail.error}`)
    this.disableSubmit(false)
  }

  end(event) {
    if (this.failed.has(event.detail.id)) return
    this.setStatus(this.doneTextValue)
    this.disableSubmit(false)
  }

  render() {
    const values = [...this.uploads.values()]
    const average = values.reduce((a, b) => a + b, 0) / values.length

    if (this.hasBarTarget) this.barTarget.style.width = `${average}%`
    this.setStatus(`${this.uploadingTextValue} ${Math.round(average)}%`)
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  disableSubmit(disabled) {
    if (this.hasSubmitTarget) this.submitTarget.disabled = disabled
  }
}
