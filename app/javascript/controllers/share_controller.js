import { Controller } from "@hotwired/stimulus"

// Passing a note on.
//
// The WhatsApp link beside these is a plain href and needs nothing from here.
// What this adds is the two affordances that only exist behind an API, so both
// start hidden and are revealed only where the browser actually has them:
// copying to the clipboard, and the phone's own share sheet, which on a desktop
// browser does not exist at all.
export default class extends Controller {
  static targets = ["native", "copy", "copyIdle", "copyDone"]
  static values = { url: String, title: String }

  static CONFIRMATION_MS = 2200

  connect() {
    if (this.hasCopyTarget && navigator.clipboard) this.copyTarget.hidden = false
    if (this.hasNativeTarget && navigator.share) this.nativeTarget.hidden = false
  }

  disconnect() {
    clearTimeout(this.confirmationTimer)
  }

  async native(event) {
    event.preventDefault()

    try {
      await navigator.share({ title: this.titleValue, url: this.urlValue })
    } catch (error) {
      // Closing the share sheet rejects the promise. That is someone changing
      // their mind, not a failure, and it should say nothing.
      if (error.name !== "AbortError") console.error(error)
    }
  }

  async copy(event) {
    event.preventDefault()

    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.confirm()
    } catch (error) {
      console.error(error)
    }
  }

  // Say so on the button itself: a copy that gives no sign of having happened
  // gets pressed again.
  confirm() {
    this.copyIdleTarget.hidden = true
    this.copyDoneTarget.hidden = false

    clearTimeout(this.confirmationTimer)
    this.confirmationTimer = setTimeout(() => {
      this.copyDoneTarget.hidden = true
      this.copyIdleTarget.hidden = false
    }, this.constructor.CONFIRMATION_MS)
  }
}
