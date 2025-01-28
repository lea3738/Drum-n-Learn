import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-drumracks-hp"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus! search drumrack hp controller connected!");
  }

  search(event) {
    const query = event.target.value;
    // submit the form with the search query
    // this.element is the form element
    setTimeout(() => this.element.submit(), 300);
  }
}
