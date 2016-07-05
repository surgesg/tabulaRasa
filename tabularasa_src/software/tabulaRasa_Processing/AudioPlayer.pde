/*
    AudioPlayer.pde
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

class TableOsc extends Oscillator{
  
  float samples[] = new float[256];
  
  public TableOsc(float freq, float amp, float samplerate){
    super(freq, amp, samplerate);  
  }
  
  protected float value(float step){
    return samples[(int)(step * 255)];  
  }
  
  void changeWaveform(float inputSamps[]){
    samples = inputSamps;  
  }
}

float tempSoundArray[] = new float[256];

void makeSound(byte samples[]){
      osc.setAmp(volSlider.value());
  if(changedSamples){
    for(int i = 0; i < 256; ++i){
      if((int)samples[i] < 0){
        tempSoundArray[i] = samples[i] + 256;  
      } else {
        tempSoundArray[i] = samples[i];
      }
    tempSoundArray[i] = (tempSoundArray[i] - 127) / 127;
    }   
    osc.changeWaveform(tempSoundArray);
    changedSamples = false;
    }
}

