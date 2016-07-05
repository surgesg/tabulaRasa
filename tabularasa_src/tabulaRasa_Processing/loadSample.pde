/*
    loadSample.pde
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

void loadSample() {
  String path = selectInput();
  sample = minim.loadSample(path, 32768);
  float sampleArray[] = sample.getChannel(1);
  float step = sampleArray.length / 256.0;
//  println(step);
  float soundIndex = 0;
  int nonByteData[] = new int[256];
  for(int i = 0; i < 256; ++i) {
    data[i] = byte(map(sampleArray[round(soundIndex)], -1.0, 1.0, 0, 255));
    nonByteData[i] = int(map(sampleArray[round(soundIndex)], -1.0, 1.0, 0, 255));
    soundIndex += step;
  }
  for(int i = 0; i < 16; ++i) {
    sliderData[i + ((currentSlot) * 16)] = nonByteData[i * 16];
  }
  for(int i = 0; i < 256; ++i) {  //update the file array
    file[i + (256 * (currentSlot))] = data[i];
  }
  loadSliders();
}

