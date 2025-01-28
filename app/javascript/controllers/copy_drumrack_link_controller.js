import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-drumrack-link"
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
  }

  copy(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.urlValue)
      .then(() => {
        alert('Link copied!');
      })
      .catch(err => {
        console.error('Failed to copy: ', err);
      });
  }
}
