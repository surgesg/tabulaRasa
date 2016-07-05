/*
    Interpolation.pde
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

void generalInterp() {
  int currentSample = 0;
  int nextSample = 0;
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = (int)sliders[i].value();
  }
  for(int slider = 0; slider < 16; ++slider) {
    currentSample = sliderData[slider + (16 * (currentSlot))];
    if(slider == 15) {
      nextSample = sliderData[0 + (16 * (currentSlot))];
    } 
    else {
      nextSample = sliderData[slider + 1 + (16 * (currentSlot))];
    }
    for(int sample = 0; sample < 16; ++sample) {
      switch(interpType) {
      case 0:
        data[sample + (slider * 16)] = byte(int(lerp(currentSample, nextSample, (float)sample / 16)));
        break;
      case 1:
        data[sample + (slider * 16)] = byte(int(sigInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 2:
        data[sample + (slider * 16)] = byte(int(cosineInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 3:
        data[sample + (slider * 16)] = byte(int(circularInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 4:
        data[sample + (slider * 16)] = byte(int(exponentialInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 5:
        data[sample + (slider * 16)] = byte(int(decimatedInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 6:
        for(int i = 0; i < 256; ++i) {  //update the data array
          data[i] = file[i + (256 * (currentSlot))];
        }
        break;
      case 7:
        harmonicMix();
        break;
      }
    }
  }
  for(int i = 0; i < 256; ++i) {  //update the file array
    file[i + (256 * (currentSlot))] = data[i];
  }
}

