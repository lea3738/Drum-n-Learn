import { Controller } from "@hotwired/stimulus";


export default class extends Controller {
  static values = { bpm: Number, samples: Object, initialSamples: String, bpmValue: Number, drumrackId: Number };
  static targets = ["pad", "category", "bpmLabel", "bpmInput", "togglePlayBtn", "togglePlayBtnShow", "bpmLabelCurrent", "popup"];
  sampleSelected = null;
  soundBoxSamples = null;
  lastPadPlayed = 0;
  interval = null;
  isDrumrackChanged = false;

  soundsPads = [];

  connect() {
    this.padTargets.forEach(pad => {
      this.soundsPads.push({
        bass: new Audio(this.samplesValue["bass"]),
        snare: new Audio(this.samplesValue["snare"]),
        hihat: new Audio(this.samplesValue["hihat"]),
        kick: new Audio(this.samplesValue["kick"]),
        oneshot: new Audio(this.samplesValue["oneshot"])
      });
    })
    this.soundBoxSamples = JSON.parse(this.initialSamplesValue).map(padSamples => {
      return padSamples.map(sample => {
        return JSON.parse(sample);
      });
    });
    this.padTargets.forEach((pad, index) => {
      pad.dataset.samples = JSON.stringify(this.soundBoxSamples[index]);
    });
  }

  playMusic() {
    this.interval = setInterval(() => {
      this.padTargets.forEach((pad) => {
          pad.dataset.active = "false";
          pad.dataset.played = "false";
          this.categoryTargets.forEach(category => {
            category.dataset.played = "false";
          });
        });
        const pad = document.querySelector(`#pad-${this.lastPadPlayed}`);

        pad.dataset.active = "true";
        JSON.parse(pad.dataset.samples).forEach((sample) => {
          if (sample.active) {
            this.soundsPads[this.lastPadPlayed][sample.category].pause();
            this.soundsPads[this.lastPadPlayed][sample.category].currentTime = 0;
            this.soundsPads[this.lastPadPlayed][sample.category].play();
            pad.dataset.played = "true";
            this.lightUpPlayedSample(sample.category)
          }
        });

        this.lastPadPlayed === 15 ? (this.lastPadPlayed = 0) : this.lastPadPlayed++;
      }, (1000 / (this.bpmValue / 60)) / 4);
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

  selectSample(event) {
    this.sampleSelected = event.currentTarget.dataset.category;

    let sounds = {
      bass: new Audio(this.samplesValue["bass"]),
      snare: new Audio(this.samplesValue["snare"]),
      hihat: new Audio(this.samplesValue["hihat"]),
      kick: new Audio(this.samplesValue["kick"]),
      oneshot: new Audio(this.samplesValue["oneshot"])
    };

    sounds[this.sampleSelected].play();

    this.toggleCategorySelected(event);

    this.resetPads();

    this.lightUpSample();
  }

  lightUpSample() {
    this.padTargets.forEach(pad => {
      JSON.parse(pad.dataset.samples).forEach(sample => {
        if (sample.category === this.sampleSelected && sample.active) {
          pad.dataset.category = this.sampleSelected;
          pad.dataset.firstTemp = pad.dataset.index % 4 === 0 && pad.dataset.category === "";
        }
      });
    });
  }


  lightUpPlayedSample(playedCategory) {
    this.categoryTargets.find(category => category.dataset.category === playedCategory).dataset.played = "true";
  }

  resetPads() {
    const categories = ['bass', 'snare', 'hihat', 'kick', 'oneshot'];

    this.padTargets.forEach(pad => {
      categories.forEach(category => {
        pad.dataset.category = "";
        pad.dataset.firstTemp = pad.dataset.index % 4 === 0;
      });
    });
  }

  resetAll() {
    this.padTargets.forEach (async pad => {
      let changedSamples = await JSON.parse(pad.dataset.samples)

      changedSamples = changedSamples.map(sample => {
        sample.active = false;
        return sample;
      });
      pad.dataset.samples = JSON.stringify(changedSamples);
      pad.dataset.category = "";
    });
    this.pauseMusic();
    this.isDrumrackChanged = true;
  }

  toggleCategorySelected(event) {
    const currentPad = event.currentTarget;
    this.categoryTargets.forEach(target => {
      target === currentPad ? target.dataset.active = "true" : target.dataset.active = "false";
    });
  }

  addSampleToPad(event) {
    const currentPad = event.currentTarget;
    const indexOfPad = currentPad.dataset.index;
    const changedSamples = JSON.parse(currentPad.dataset.samples)

    const sampleOnPadToActivate = changedSamples.find(sample => {
      return sample.category === this.sampleSelected
    });
    sampleOnPadToActivate.active = !sampleOnPadToActivate.active;

    changedSamples.forEach(sample => {
      if (sample.category === sampleOnPadToActivate.category) {
        sample.active = sampleOnPadToActivate.active;
      }
    });

    if(sampleOnPadToActivate.active) {
      currentPad.dataset.category = this.sampleSelected;
      currentPad.dataset.firstTemp = currentPad.dataset.index % 4 === 0 && currentPad.dataset.category === "";
    } else {
      currentPad.dataset.category = "";
    }

    this.padTargets[indexOfPad].dataset.samples = JSON.stringify(changedSamples);
    this.isDrumrackChanged = true;
  }

  save() {
    const padsSamples = this.padTargets.map(pad => pad.dataset.samples)
    fetch(`/drumracks/${this.drumrackIdValue}`, {
      method: "PATCH",
      body: JSON.stringify({
        pads: padsSamples
      }),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      }
    });
  }

  decreaseBpm() {
    if (this.bpmValue > 60 && this.bpmValue <= 240) {
      this.bpmValue -= 5;
      this.bpmLabelCurrentTarget.innerHTML = `${this.bpmValue} BPM`;
      this.isDrumrackChanged = true;
      this.pauseMusic();
      this.playMusic();
    }
  }

  increaseBpm() {
    if (this.bpmValue >= 60 && this.bpmValue < 240) {
      this.bpmValue += 5;
      this.bpmLabelCurrentTarget.innerHTML = `${this.bpmValue} BPM`;
      this.isDrumrackChanged = true;
      this.pauseMusic();
      this.playMusic();
    }
  }

  popUpToggle() {
    this.popupTarget.classList.toggle("hidden");
  }

  getActiveSamples(padsSamples) {
    // Defines the list of unique samples that are active in a hash of pad samples
    let uniqueSamples = [];
    padsSamples.forEach(pad => {
      pad.forEach(sample => {
        if(sample.active === true) {
          uniqueSamples.push(sample.category)
        }
      })
    })
    uniqueSamples = [...new Set(uniqueSamples)]

    return uniqueSamples;
  }

  getActivePadsIndexes(padsSamples, activeSamples) {
    const activeAiPadsIndexes = [];
    activeSamples.forEach(activeSamples => {
      const activeIndexes = [];
      padsSamples.forEach((pad, index) => {
        pad.forEach(sample => {
          if(sample.category === activeSamples && sample.active === true) {
            activeIndexes.push(index);
          }
        })
      })
     activeAiPadsIndexes.push(activeIndexes);
    })
    return activeAiPadsIndexes;
  }

  lauchAi() {
    // gets the IA response as a hash
    this.aiPads = [
      [{"active": true, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": true, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": true, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": true, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": true, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": true, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": true, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": true, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": true, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": true, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": true, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}],
      [{"active": false, "category": "bass"}, {"active": false, "category": "kick"}, {"active": false, "category": "snare"}, {"active": false, "category": "hihat"}, {"active": false, "category": "oneshot"}]
    ]

    // reset the drumrack
    this.resetAll();
    this.categoryTargets.forEach(category => {
      category.dataset.active = "false";
      category.dataset.played = "false";
    });


    this.getIaPadsIndexes();
    this.popUpToggle();
    this.launchIaTuto(this.iaSamples);

  }




  getIaPadsIndexes() {
    // Defines the list of unique samples that are active in the IA response
    this.iaSamples = this.getActiveSamples(this.aiPads);
    const orderedSamples = ["bass", "kick", "snare", "hihat", "oneshot"];
    this.iaSamples = this.iaSamples.sort((a, b) => orderedSamples.indexOf(a) - orderedSamples.indexOf(b));

    // Defines an array of arrays of indexes of the active pads samples in the IA response
    this.activeAiPadIndexes = this.getActivePadsIndexes(this.aiPads, this.iaSamples);

  }

  getSelectedPadsIndexes() {
    // Defines an array of indexes of the selected pads
    this.selectedPads = [];
    this.padTargets.forEach((pad, index) => {
    this.selectedPads.push(JSON.parse(pad.dataset.samples));
    });

    // Defines the list of unique samples that are selected in the drumrack
    this.selectedSamples = this.getActiveSamples(this.selectedPads);

    // Defines an array of arrays of indexes of the active pads samples that are selected in the drumrack
    this.selectedPadsIndexes = this.getActivePadsIndexes(this.selectedPads, this.selectedSamples);

  }

  highlightSample(sample) {
    if (sample.dataset.aihighlighted === "true") {
      sample.dataset.aihighlighted = "";
    } else {
      sample.dataset.aihighlighted = "true";
    }
  }

  highlightPads(padIndexes) {
    this.padTargets.forEach((pad, index) => {
      if (padIndexes.includes(index)) {
        pad.dataset.aihighlighted = "true";
      }
    })
  }

  turnOffPadsHighlight() {
    this.padTargets.forEach(pad => {
      pad.dataset.aihighlighted = "";
    })
  }

  launchIaTuto(iaSamples) {
    console.log("open first popup");
    this.popupTarget.innerText = `please select the ${this.iaSamples[0]} sample`;
    this.currentSample = this.categoryTargets.find(category => category.dataset.category === this.iaSamples[0]);
    this.highlightSample(this.currentSample);

  }

 selectIaSample (event) {
    if (!this.iaSamples) {
      return;
    }
    if (event.currentTarget.dataset.category === this.iaSamples[0]) {
      this.highlightPads(this.activeAiPadIndexes[0]);
      this.popupTarget.innerText = `please click on the highlighted pads to add ${this.iaSamples[0]} sample to pads`
    }
 }

  selectIaPad() {
    if (!this.iaSamples) {
      return;
    }
    this.getSelectedPadsIndexes()
    let sampleIndex = this.selectedSamples.findIndex((sample) => sample === this.iaSamples[0]);
    console.log("sampleIndex", sampleIndex);
    const matching = this.selectedPadsIndexes[sampleIndex].every((padIndex, index) => padIndex == this.activeAiPadIndexes[0][index] && this.selectedPadsIndexes[sampleIndex].length == this.activeAiPadIndexes[0].length);
    console.log("matching", matching);
    if (matching) {
      this.highlightSample(this.currentSample)
      this.activeAiPadIndexes.shift();
      this.iaSamples.shift();
      console.log("new ia samples", this.iaSamples);
      console.log("new ia indexes", this.activeAiPadIndexes);
      this.turnOffPadsHighlight();
      if (this.iaSamples.length === 0) {
        this.popupTarget.innerText = "Good job ! Now press play to listen to your drumrack"
      } else {
        this.launchIaTuto (this.iaSamples)
      };
    }
  }

}
