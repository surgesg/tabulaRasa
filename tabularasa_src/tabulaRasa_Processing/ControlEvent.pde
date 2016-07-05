/*
    ControlEvent.pde
    Ver 1.02
    Jan 28 2011
    greg surges
    surgesg@gmail.com
    http://www.gregsurges.com/
     
    This file is part of tabulaRasa.

    tabulaRasa is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    tabulaRasa is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with tabulaRasa.  If not, see <http://www.gnu.org/licenses/>.
*/

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
