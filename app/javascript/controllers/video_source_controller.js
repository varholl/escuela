import { Controller } from "@hotwired/stimulus"

// The lesson form asks two different questions depending on where the video
// lives: upload a file, or paste a link. Showing both at once reads as two
// things to fill in, so only the one that applies stays on screen.
export default class extends Controller {
  static targets = ["select", "upload", "reference"]

  connect() {
    this.update()
  }

  update() {
    const provider = this.hasSelectTarget ? this.selectTarget.value : ""

    this.toggle(this.uploadTargets, provider === "active_storage")
    this.toggle(this.referenceTargets, provider === "youtube" || provider === "vimeo")
  }

  toggle(elements, visible) {
    elements.forEach((element) => element.classList.toggle("hidden", !visible))
  }
}
