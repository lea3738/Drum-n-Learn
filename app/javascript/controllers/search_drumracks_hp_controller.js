import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-drumracks-hp"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus! search drumrack hp controller connected!");
  }

  async search(event) {
    const query = event.target.value;

    await new Promise(resolve => setTimeout(resolve, 500)); // debounce

    Turbo.visit(`/drumracks/search?query=${query}`, { frame: "drumracks_search_results" });
  }
}
