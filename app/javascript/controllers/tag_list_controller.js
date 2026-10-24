import { Controller } from "@hotwired/stimulus"

// Tags she has already used, offered under the field so a new piece reuses
// "ansiedad" rather than inventing "ansiedades". Pressing one adds it to the
// comma-separated list; the field stays plain text, so typing still works.
export default class extends Controller {
  static targets = ["input"]

  add({ params: { name } }) {
    const current = this.inputTarget.value.split(",").map((tag) => tag.trim()).filter(Boolean)
    if (current.some((tag) => tag.toLowerCase() === name.toLowerCase())) return

    this.inputTarget.value = [...current, name].join(", ")
    this.inputTarget.focus()
  }
}
