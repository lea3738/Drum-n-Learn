import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-drumracks-hp"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus! search drumrack hp controller connected!");
  }

  async search(event) {
    const query = event.target.value;

    await new Promise(resolve => setTimeout(resolve, 500)); // debounce

    const turboFrame = document.getElementById("drumracks_search_results");

    const response = await fetch(`/drumracks/search?query=${query}`, {
      headers: { "Accept": "text/html", "Turbo-Frame": turboFrame.id }
    });

    if (response.ok) {
      turboFrame.innerHTML = await response.text(); // Turbo will handle parsing
    } else {
      console.error("Search failed:", response.status);
    }
  }
}
