import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkOrientation();
    this.interval = setInterval(() => this.checkOrientation(), 1);
  }

  disconnect() {
    clearInterval(this.interval);
  }

  checkOrientation() {
    if (window.innerWidth > window.innerHeight) {
      this.element.dataset.isLandscape = "true";
    } else {
      this.element.dataset.isLandscape = "false";
    }
  }
}
