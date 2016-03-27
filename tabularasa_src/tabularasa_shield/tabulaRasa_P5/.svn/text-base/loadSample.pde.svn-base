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

