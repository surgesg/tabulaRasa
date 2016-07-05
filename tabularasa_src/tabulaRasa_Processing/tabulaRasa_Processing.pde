/*  
    tabulaRasa_P5.pde
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

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import toxi.math.*;
import controlP5.*;

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
InterpolateStrategy sigInterp = new SigmoidInterpolation(0.9);
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

void setup() {
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
  osc = new TableOsc(200, 0.5, out.sampleRate());
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
    volSlider.setValue(.5);
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

void draw() {
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

void drawShape() {
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
    line(i * (400.0 / 256.0), yCoord, ((i + 1) * (400.0 / 256.0)), nextYCoord);
  }
}

void loadSliders() {
  for(int i = 0; i < 16 ; ++i) {
    sliders[i].setValue(sliderData[i + (16 * (currentSlot))]);
  }
}
void stop()
{
  out.close();
  minim.stop();
  
  super.stop();
}
