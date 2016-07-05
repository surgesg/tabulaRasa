/*
    Harmonic_Mix.pde
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

void harmonicMix(){
  noStroke();
  fill(255);
  for(int num =0;num < 16;num++) {  //display harmonic labels
    labelName = Integer.toString(num+1) + "F";
    text(labelName, num * 25+5,412);
  }
  float maximum = 0;
  float minimum = 0;
    for(int i = 0; i < 256; ++i) {
    data[i] = 0;
  }
  if(sliderData[16 * (currentSlot)] == 127) {
    }
  float tempDataArray[] = new float[256];
  float sineArray[][] = new float[16][256];
  int currentSample = 0;
  int nextSample = 0;
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = (int)sliders[i].value();
  }
//calculate the sine waves and populate the arrays
  for(int harmonic = 0; harmonic < 16; ++harmonic) {
    for(int i = 0; i < 256; ++i) {
      sineArray[harmonic][i] = (((sliderData[harmonic + (16 * (currentSlot))]) * sin((1 + harmonic) * TWO_PI/256 * i)));
      tempDataArray[i] += sineArray[harmonic][i]; //sum harmonics
      if(tempDataArray[i] > maximum){  //look for highest level
        maximum = tempDataArray[i];
      }
      if(tempDataArray[i] < minimum){  //look for lowest level
        minimum = tempDataArray[i];
      }
    }
  }
//normalize the waveform
  for(int i = 0; i < 256; ++i) {
    tempDataArray[i] = map(tempDataArray[i],minimum,maximum,15,240);  //( maximum=peak  15=lower boundary 240=upper boundary)
    data[i] = byte(tempDataArray[i]);
    file[i + (256 * (currentSlot))] = data[i];
  }
  slotStatus[currentSlot] = true;
}

//reset the display for harmonics
void clear_to_harmonics(){  //set display to zero baseline slider1 to max
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = 0;
  }
  sliderData[16 * (currentSlot)]=255;
  loadSliders();
  slotStatus[currentSlot] = false;
}

