public void controlEvent(ControlEvent theEvent) {  //button events
//--------------------------------------------------
//Control Ids:
//memory slots (0-63)
//interpolation (64-71)
//sliders (72-88)
//--------------------------------------------------
  int Id = theEvent.controller().id();
  if(Id >=0 & Id < 64) {  //buttons 0-63 Memory slots
    currentSlot = Id;
    interpType = slotInterp[currentSlot];  //get current interpType
    slotStatus[currentSlot] = true;
  } 
  else if(Id >= 64 & Id < 70) {  //buttons 64-71 interpolations
    interpType = Id - 64;
  }
  else if (Id == 70) {  //Button 62 Samples
    interpType = Id - 64;
    loadSample();
    }  
   else if(Id == 71) {  //Harmonics
      if(interpType < 7){
        clear_to_harmonics();
//        println(Id);
    }
    interpType = Id - 64;
  }
  else if(Id >= 72 & Id < 89) {  //buttons 72-88 slider controls -- nothing to do
  }
  slotInterp[currentSlot] = interpType;  //keep interp with slot values
  changedSamples = true;
}
void Clear() {
    interpType = 0;  
    clear_to_bands();
}

void rspkr() {
    volSlider.setValue(1);
}

void lspkr() {
    volSlider.setValue(0);
}
void About() {
    setAbout = true;
}

void keyPressed() {
  if(key == 'c') {
    copyWave();
  }
  else if(key == 'v') {
    pasteWave();
  }
  else if(key == 's') {
    Save();
  }
  else if(key == 'l') {
    Load();
  }
  else if(key == 'a') {
    if(volSlider.value() > 0) {
        volSlider.setValue(0);
    }
    else {
        volSlider.setValue(1);
    }
   }
  }
 void mousePressed() {
   setAbout = false;
 }
