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

