import { Controller } from "@hotwired/stimulus"

// Tags she has already used, offered under the field so a new piece reuses
// "ansiedad" rather than inventing "ansiedades".
//
// Only a few are ever on screen, however many exist: the most used first
// (the order they arrive in), or, while she types, the ones containing what is
// after the last comma. Tags already in the field are not offered again.
// Pressing one finishes the word she was typing. The field stays plain text,
// so typing a new tag works as before.
export default class extends Controller {
  static targets = ["input", "option", "more"]
  static values = { limit: { type: Number, default: 10 }, moreText: String }

  connect() {
    // A saved list reads "ansiedad, respiración"; without the trailing comma
    // its last tag would look like a word still being typed.
    const value = this.inputTarget.value.trim()
    if (value && !value.endsWith(",")) this.inputTarget.value = `${value}, `

    this.refresh()
  }

  refresh() {
    const { chosen, typing } = this.read()
    let shown = 0
    let matching = 0

    this.optionTargets.forEach((option) => {
      const name = option.dataset.tagListNameParam
      const fits = !chosen.has(name) && (!typing || name.includes(typing))
      if (fits) matching++

      const show = fits && shown < this.limitValue
      if (show) shown++
      option.hidden = !show
    })

    if (!this.hasMoreTarget) return
    const rest = matching - shown
    this.moreTarget.hidden = rest <= 0
    this.moreTarget.textContent = this.moreTextValue.replace("%{count}", rest)
  }

  add({ params: { name } }) {
    const parts = this.inputTarget.value.split(",").map((part) => part.trim())
    parts.pop() // what she was typing, finished by the choice
    const kept = parts.filter((part) => part && part.toLowerCase() !== name)

    this.inputTarget.value = [...kept, name].join(", ") + ", "
    this.inputTarget.focus()
    this.refresh()
  }

  // Everything before the last comma is chosen; what follows it is the word
  // still being typed. Tags are stored lowercased, so compare that way.
  read() {
    const parts = this.inputTarget.value.split(",")
    const typing = parts.pop().trim().toLowerCase()
    const chosen = new Set(parts.map((part) => part.trim().toLowerCase()).filter(Boolean))
    return { chosen, typing }
  }
}
