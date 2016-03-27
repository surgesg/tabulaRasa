void clear_to_bands(){  //set display to zero midscreen sliders to 127
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = 127;
  }
  loadSliders();
  slotStatus[currentSlot] = false;
}

void highlightMem() {  //highlight current memory slot
  for(int i = 0; i < 64; ++i) {
    if(slotStatus[i] == true & currentSlot == i) {
      buttons[i].setColorBackground(color(255,0,0));  //active control background to red
      buttons[i].setColorLabel(color(255,255,255));  //active control label to black
    }
    else if(slotStatus[i] == false) {
      buttons[i].setColorBackground(color(0,55,85));  //active control background to light blue
      buttons[i].setColorLabel(color(255,255,255));  //active control label to black
    }
    else {
      buttons[i].setColorBackground(color(0,160,210));  //active control background to light blue
      buttons[i].setColorLabel(color(0,0,0));  //active control label to black
    }
  }
}

void highlightInterp() {  //highlight current Interp Type
      for(int i = 0; i < 8; ++i) {  //reset all interp controls to default
        interpControls[i].setVisible(true);  //active control background to red
        interpControls[i].setColorBackground(color(0,55,85));  //control background default
        interpControls[i].setColorLabel(color(255,255,255));  //control label to white
    }
    interpControls[interpType].setColorBackground(color(255,0,0));  //active control background to red
    interpControls[interpType].setColorLabel(color(255,255,255));  //active control label to white
    if(interpType == 7){
      for(int i = 0; i < 7; ++i) {  //reset all interp controls to default
        interpControls[i].setVisible(false);  //active control background to red
        interpControls[i].setColorBackground(color(0,55,85));  //control background default
        interpControls[i].setColorLabel(color(255,255,255));  //control label to white
    }
        interpControls[interpType].setColorBackground(color(255,0,0));  //active control background to red
        interpControls[interpType].setColorLabel(color(255,255,255));  //active control label to white
    }
 }

