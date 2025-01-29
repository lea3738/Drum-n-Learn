import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-drumracks-hp"
export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus! search drumrack hp controller connected!");
  }

  async search(event) {
    const query = event.target.value;

    // Add a 300 millisecond delay
    await new Promise(resolve => setTimeout(resolve, 500));

    const response = await fetch(`/drumracks?query=${query}`, {
      headers: {
        "Accept": "text/html"
      }
    });

    if (response.ok) {
      const turboFrame = document.getElementById("drumracks_search_results");
      const parser = new DOMParser();
      const doc = parser.parseFromString(await response.text(), "text/html");
      const newContent = doc.getElementById("drumracks_search_results").innerHTML;
      turboFrame.innerHTML = newContent;
      console.log(turboFrame.innerHTML)
    } else {
      const errorText = await response.text();
      console.error("Failed to fetch drumracks:", response.status, errorText);
    }
  }
}
