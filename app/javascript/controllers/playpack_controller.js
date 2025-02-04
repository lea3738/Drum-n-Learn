import { Controller } from "@hotwired/stimulus"

static values = {  };
static targets = ["pad", "category"];

// Connects to data-controller="playpack"
export default class extends Controller {
  connect() {
    console.log("playpack controller connected");
  }


  playMusic() {
    this.interval = setInterval(() => {

      // Reset all pads to inactive and not played
      this.padTargets.forEach((pad) => {
        pad.dataset.active = "false";
        pad.dataset.played = "false";
        // Fetcheds category targets but I cannot see that they exist
        this.categoryTargets.forEach((category) => {
          category.dataset.played = "false";
        });
      });

      // Selects the pad to be played (starting from 0)
      const pad = document.querySelector(`#pad-${this.lastPadPlayed}`);
      // Set the pad to active
      pad.dataset.active = "true";
      // Gets the samples from the pad
      JSON.parse(pad.dataset.samples).forEach((sample) => {
        const sampleButton = this.categoryTargets.find(
          (category) => category.dataset.category === sample.category
        );

        if (sample.active && sampleButton.dataset.muted !== "true") {
          this.soundsPads[this.lastPadPlayed][sample.category].pause();
          this.soundsPads[this.lastPadPlayed][sample.category].currentTime = 0;
          this.soundsPads[this.lastPadPlayed][sample.category].play();
          pad.dataset.played = "true";
          this.lightUpPlayedSample(sample.category);
        }
      });

      this.lastPadPlayed === 15
        ? (this.lastPadPlayed = 0)
        : this.lastPadPlayed++;
    }, 1000 / (this.bpmValue / 60) / 4);
  }

  play() {
    if (this.interval === null) {
      this.playMusic();
    }
  }

  pause() {
    if (this.interval !== null) {
      this.pauseMusic();
    }
  }

  playShow() {
    this.playMusic();
  }

  pauseShow() {
    this.pauseMusic();
  }

  pauseMusic() {
    clearInterval(this.interval);
    this.interval = null;
  }
}
