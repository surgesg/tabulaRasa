import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import toxi.math.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class tabulaRasa_P5 extends PApplet {

/*  
    tabulaRasa_P5.pde
    Ver 1.02
    Jan 28 2011
    greg surges
    surgesg@gmail.com
    http://www.gregsurges.com/
*/









ControlP5 controlP5;

//sliders
Slider sliders[]= new Slider[16];
int sliderData[] = new int[16 * 32 * 2];  //save for recall
int copyBuffer[] = new int[16]; //used for copy and paste
Slider volSlider;
int sliderValue = 100;
String sliderName;
//buttons
String buttonName;
Button buttons[]= new Button[64];  //Memory slots
Button Clear, Save, Load, About, rspkr, lspkr; //
Button interpControls[] = new Button[8];  //interpolation types
//labels
String labelName;
//interpolation
String interpNames[] = new String[] {"Linear", "Sigmoid", "Cosine", "Circular", "Exponential", "Decimated", "Samples", "Harmonics"};
int interpType = 0;
int slotInterp[] = new int[32 * 2];  //save for recall
int interpBuffer;  //used for copy and paste
//reserve spaces
byte data[] = new byte[256];  //data points for one waveform (slot)
byte dataBuffer[] = new byte[256];  //used in copy paste
byte file[] = new byte[(256 * 32 * 2) + (32 * 2) + (32 * 2) + (16 * 32 * 2)];  //save for Arduino -- (datapoints * #slots * banks) + (slot_interp) + (slotStatus) + (sliderdata--sliders * #slots * banks)
//pointers
int slotInterp_offset = 256 * 32 * 2;
int slotStatus_offset = slotInterp_offset + 64;
int sliderData_offset = slotStatus_offset + 64;
//misc
int currentSlot, previousSlot;
boolean slotStatus[] = new boolean[32 * 2];  //has button been used?
// interpolation 
InterpolateStrategy sigInterp = new SigmoidInterpolation(0.9f);
InterpolateStrategy cosineInterp = new CosineInterpolation();
InterpolateStrategy circularInterp = new CircularInterpolation();
InterpolateStrategy exponentialInterp = new ExponentialInterpolation();
InterpolateStrategy decimatedInterp = new DecimatedInterpolation(4);
// audio playback
Minim minim;
AudioSample sample;
AudioSample currentSound;
AudioOutput out;
TableOsc osc; // extended oscillator class
boolean changedSamples = false; // used to reconvert bytes to floats, only when needed
boolean audioOn = false; // to be used for switching
boolean setAbout = false; //control of 'About' screen
PImage speaker, splash, about;

PFont font;

public void setup() {
  size(650, 420);
  background(0, 20, 50);
  smooth();
//--------------------------------------------------
//initialize font
  font = loadFont("ArialMT-10.vlw");
  textFont(font, 10);
//--------------------------------------------------
//initialize sound
  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 512, 44100, 8); // modified buffer size for less latency, sample rate and bit depth for matching Arduino
  osc = new TableOsc(200, 0.5f, out.sampleRate());
  out.addSignal(osc);
  speaker = loadImage("speaker.png"); // load speaker icon
  speaker.resize(15, 15);
//setup splash
  splash = loadImage("splash.png"); //load splash screen
  about = loadImage("about.png"); //load about screen
//--------------------------------------------------
//initalize arrays
  for(int i = 0; i < (16 * 32 * 2); ++i) {  //offset for sliders
    sliderData[i] = 127;
  }
  for(int i = 0; i < (256 * 32 * 2); ++i) {  //clear memory slots
    file[i] = 0;
  }
  for(int i = 0;i < 32 * 2; ++i) {  //no buttons pushed
    slotStatus[i] = false;
  }
//--------------------------------------------------
//control setup:
//--------------------------------------------------
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
//--------------------------------------------------
//Control Ids:
//memory slots (0-63)
//interpolation (64-71)
//sliders (72-88)
//--------------------------------------------------
//make first bank of memory slot buttons Ids (0-15) zero not used
  for(int num =0;num < 16;num++) {  //make button control array
    buttonName = "WAVE " + Integer.toString(num +1);
    controlP5.addButton(buttonName, num, 410, (num+1)*20+10, 50, 15).setId(num);
    buttons[num] = (Button)controlP5.controller(buttonName);
    buttons[num].setColorActive(color(255,0,0));
  }
//--------------------------------------------------
//make second bank of memory slot buttons Ids (16-31)
  for(int num =16;num < 32;num++) {  //make second bank
    buttonName = "WAVE " + Integer.toString(num +1);
    controlP5.addButton(buttonName, num, 470, num%16 *20+30, 50, 15).setId(num);
    buttons[num] = (Button)controlP5.controller(buttonName);
    buttons[num].setColorActive(color(255,0,0));
  }
//--------------------------------------------------
//make third bank of memory slot buttons Ids (32-47)
  for(int num =32;num < 48;num++) {  //make second bank
    buttonName = "WAVE " + Integer.toString(num +1);
    controlP5.addButton(buttonName, num, 530, num%32 *20+30, 50, 15).setId(num);
    buttons[num] = (Button)controlP5.controller(buttonName);
    buttons[num].setColorActive(color(255,0,0));
  }
//--------------------------------------------------
//make forth bank of memory slot buttons Ids (48-63)
  for(int num =48;num < 64;num++) {  //make second bank
    buttonName = "WAVE " + Integer.toString(num +1);
    controlP5.addButton(buttonName, num, 590, num%48 *20+30, 50, 15).setId(num);
    buttons[num] = (Button)controlP5.controller(buttonName);
    buttons[num].setColorActive(color(255,0,0));
  }
//--------------------------------------------------
//make interpolation buttons Ids (64-71)
  for(int num = 0; num < 8; ++num) {
    buttonName = interpNames[num];
    controlP5.addButton(buttonName, 0, num * 80 +5, 400, 80, 15).setId(num + 64); 
    interpControls[num] = (Button)controlP5.controller(buttonName);
    interpControls[num].setColorActive(color(255,0,0));
  }
//--------------------------------------------------
//make slider controls Ids (72-88)
  for(int num = 0;num < 16; num ++) {  //make slider control array
    sliderName = "Slider_" + Integer.toString(num); 
    controlP5.addSlider(sliderName,0, 255, num*25, 0, 25, 398).setId(num + 72);
    sliders[num] = (Slider)controlP5.controller(sliderName);  //build array
    sliders[num].setSliderMode(Slider.FLEXIBLE);  //set properties
    sliders[num].setLabelVisible(false);
    sliders[num].setValue(127);
    sliders[num].setColorBackground(color(0, 0, 20));
    sliders[num].setColorForeground(color(70, 0, 20));
  }
//--------------------------------------------------
//make read, write, clear , spkr buttons -- 
  Save = controlP5.addButton("Save", 0, 470, 5, 50, 15);
  Load = controlP5.addButton("Load", 0, 530, 5, 50, 15);  
  About = controlP5.addButton("About", 0, 590, 5, 50, 15);  
  controlP5.addButton("Clear", 0, 410, 5, 50, 15);  
  controlP5.addButton("rspkr", 0, 625, 367, 15, 15);
  rspkr = (Button)controlP5.controller("rspkr");
  rspkr.setCaptionLabel(""); 
  controlP5.addButton("lspkr", 0, 410, 367, 15, 15);
  lspkr = (Button)controlP5.controller("lspkr");
  lspkr.setCaptionLabel(""); 
//---------------------------------------------------
//make volume slider
    controlP5.addSlider("Volume",0, 1, 433, 370, 185, 10);
    volSlider = (Slider)controlP5.controller("Volume"); 
    volSlider.setLabelVisible(false);
    volSlider.setValue(.5f);
    volSlider.setColorForeground(color(0, 175, 0));
    volSlider.setColorBackground(color(100, 0, 0));
    volSlider.setColorActive(color(0,175, 0));
//--------------------------------------------------
//set initial conditions
  currentSlot = 0;
  previousSlot = 0;
  slotStatus[currentSlot] = true;
  highlightMem();  //highlight initial slot
}

public void draw() {
  if(setAbout) {
    drawAbout();  //display About screen
  }
  else {
  if(millis() > 8000) { //10 second splash screen
    background(0, 20, 50); // restore default colors
    if(currentSlot != previousSlot) { // load previous values from memory
      loadSliders();
      highlightMem();  //highlight current slot
      drawShape();
    }
    previousSlot = currentSlot;
    drawOutlines();
    controlP5.draw();
    generalInterp();  //interpolate
    highlightInterp();
    drawShape();
    drawSpeakerIcon();
    makeSound(data);
    }
  else {
    drawSplashScreen();  //display splash screen
  }
 }
}

public void drawShape() {
  int yCoord, nextYCoord;
  stroke(255);
  fill(255);
  for(int i = 0; i < 256; ++i) {
    fill(255);
    yCoord = data[i];
    nextYCoord = data[(i + 1) % 256];
    if(yCoord < 0) {
      yCoord += 256;
    }
    if(nextYCoord < 0) {
      nextYCoord += 256;
    }
    yCoord = (int)map(yCoord, 255, 0, 0, 400);
    nextYCoord = (int)map(nextYCoord, 255, 0, 0, 400);
    line(i * (400.0f / 256.0f), yCoord, ((i + 1) * (400.0f / 256.0f)), nextYCoord);
  }
}

public void loadSliders() {
  for(int i = 0; i < 16 ; ++i) {
    sliders[i].setValue(sliderData[i + (16 * (currentSlot))]);
  }
}
public void stop()
{
  out.close();
  minim.stop();
  
  super.stop();
}
class TableOsc extends Oscillator{
  
  float samples[] = new float[256];
  
  public TableOsc(float freq, float amp, float samplerate){
    super(freq, amp, samplerate);  
  }
  
  protected float value(float step){
    return samples[(int)(step * 255)];  
  }
  
  public void changeWaveform(float inputSamps[]){
    samples = inputSamps;  
  }
}

float tempSoundArray[] = new float[256];

public void makeSound(byte samples[]){
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
public void Clear() {
    interpType = 0;  
    clear_to_bands();
}

public void rspkr() {
    volSlider.setValue(1);
}

public void lspkr() {
    volSlider.setValue(0);
}
public void About() {
    setAbout = true;
}

public void keyPressed() {
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
 public void mousePressed() {
   setAbout = false;
 }
public void harmonicMix(){
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
    data[i] = PApplet.parseByte(tempDataArray[i]);
    file[i + (256 * (currentSlot))] = data[i];
  }
  slotStatus[currentSlot] = true;
}

//reset the display for harmonics
public void clear_to_harmonics(){  //set display to zero baseline slider1 to max
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = 0;
  }
  sliderData[16 * (currentSlot)]=255;
  loadSliders();
  slotStatus[currentSlot] = false;
}

public void generalInterp() {
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
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(lerp(currentSample, nextSample, (float)sample / 16)));
        break;
      case 1:
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(sigInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 2:
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(cosineInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 3:
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(circularInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 4:
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(exponentialInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
        break;
      case 5:
        data[sample + (slider * 16)] = PApplet.parseByte(PApplet.parseInt(decimatedInterp.interpolate(currentSample, nextSample, (float)sample / 16)));
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

public void Save() {
  println("Save");  
  for(int i = 0;i < 64;++i) {  //add essential arrays to file
    file[slotInterp_offset +i] = (byte)slotInterp[i];  //add slot_Interp[]
    if(slotStatus[i]) {  //convert boolean to byte
      file[slotStatus_offset + i] = 1;  //add slotStatus[]
    }
    else {
      file[slotStatus_offset + i] = 0;
    }
  }
  for(int i = 0;i < 16 *32  * 2; ++i) {
    file[sliderData_offset + i] = (byte)sliderData[i];  //add sliderData[]
  }
  String fileName;  //composite file (all arrays)
  fileName = "data.dat";  //always save to this file
  fileDelete(fileName);
  saveBytes(fileName, file);  //write all data to file now
}
public void fileDelete(String DEST_FILE) {  //Windows 7 will not rename tmp files
  File dataFile = sketchFile(DEST_FILE);
  if (dataFile.exists()) {
    dataFile.delete(); // Returns false if it cannot do it
  }
}
public void Load() {
  // open a file and read its binary data 
  println("Load");  
  String path = selectInput();  //choose the input file
  file = loadBytes(path); 
  for (int i = 0; i < 64; i++) { 
    slotInterp[i] = file[slotInterp_offset + i] & 0xff;  //populate slotInterp[]
    slotStatus[i] = PApplet.parseBoolean(file[slotStatus_offset + i]);  //populate slotStatus[]
  } 
  for (int i = 0; i < 16 * 32 * 2; i++) { 
    sliderData[i] = file[sliderData_offset + i] & 0xff;  //convert to integer and load sliderData[]
  } 
  interpType = slotInterp[currentSlot];  //get current interpType
  loadSliders();
  highlightMem();
  highlightInterp();
}

public void copyWave() {
  println("Copy");  
  for(int i = 0; i < 16; ++i) {
    copyBuffer[i] = sliderData[i + (16 * (currentSlot))];
  }
  interpBuffer = interpType;
  if(interpType == 6) {
     for(int i = 0; i < 256; ++i) {  //update the data array
          dataBuffer[i] = file[i + (256 * (currentSlot))];
      }
  }
}

public void pasteWave() {
  println("Paste");  
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = copyBuffer[i];
  }
  interpType = interpBuffer;
  if(interpType == 6) {
     for(int i = 0; i < 256; ++i) {  //update the data array
          file[i + (256 * (currentSlot))] = dataBuffer[i];
      }
  }
  loadSliders();
  slotStatus[currentSlot] = true;
}
public void drawSplashScreen(){
  image(splash, 0, 0);
}

public void drawSpeakerIcon(){
  fill(0, 200, 0);
  rect(625, 367, 15, 15); //right speaker
  image(speaker, 625, 367);  
  fill(200, 0, 0);
  rect(410, 367, 15, 15); //left speaker
  image(speaker, 410, 367);  
}

public void drawOutlines() {
    stroke(255);
    noFill();
    rect(402,2,245,20);
    stroke(100);
    for(int v = 0; v < 8; v++) {
      for(int h = 0; h < 4; h++) {
      rect(408+h*60,36 + v * 40,54,20);
      }
    }
    stroke(255);
    rect(402,25,245,325);
    rect(402,353,245,42);
    rect(3,398,644,18);
}

public void drawAbout() {
  image(about, 0, 0);
// add about screen and mouse click;
  }

public void clear_to_bands(){  //set display to zero midscreen sliders to 127
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = 127;
  }
  loadSliders();
  slotStatus[currentSlot] = false;
}

public void highlightMem() {  //highlight current memory slot
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

public void highlightInterp() {  //highlight current Interp Type
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

public void loadSample() {
  String path = selectInput();
  sample = minim.loadSample(path, 32768);
  float sampleArray[] = sample.getChannel(1);
  float step = sampleArray.length / 256.0f;
//  println(step);
  float soundIndex = 0;
  int nonByteData[] = new int[256];
  for(int i = 0; i < 256; ++i) {
    data[i] = PApplet.parseByte(map(sampleArray[round(soundIndex)], -1.0f, 1.0f, 0, 255));
    nonByteData[i] = PApplet.parseInt(map(sampleArray[round(soundIndex)], -1.0f, 1.0f, 0, 255));
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

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "tabulaRasa_P5" });
  }
}
