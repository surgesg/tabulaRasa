/*************************************************
 * tabulaRasa_Arduino_PWM.pde
 * last updated 3.12.2011 - greg surges surgesg@gmail.com
 * 
 * atmega328 (w/ arduino bootloader) mcu code for use in tabulaRasa wavetable oscillator
 * 
 * reads "data.dat" from sd card - produced by tabulaRasa Editor Software
 * 
 * some code borrowed from Adrian Freed
 * 
 * todo: 
 * continued commenting
 * internal pullup / down resistors on analog pins
 *************************************************/

#include <avr/io.h>
#include <avr/interrupt.h>

#include <SD.h>

#define PWM_PIN       3
#define PWM_VALUE_DESTINATION     OCR2B
#define PWM_INTERRUPT TIMER2_OVF_vect

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

/*** variables from Adrian Freed ***/
const unsigned int LUTsize = 1<<8; 
const int timerPrescale=1<<9;
const int fractionalbits = 16; 
uint8_t predivide = 8;
/******************************/

byte waveform[256 * 2]; // allocate RAM to store the currently used waveforms
int8_t waveformSlot = 0; // the current waveform, corresponding to the slots in the Editor App
int8_t previousWaveformSlot = 0;
byte finalWaveform[256]; // the composite waveform, after computing crossfade 

int8_t outputvalue = 0; // the sample written out to PWM
float frequency; // oscillation frequency in Hz.
int8_t counter = 0; // limit the rate at which slot and crossfade input adc is read

float frequencyInputs = 0;
float freqCV = 0;
int slotInputs = 0;
float slotCV = 0;
float fadeInputs = 0;
float fadeCV = 0;
float midpoint = 0;
float range = 0;

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))
void error_P(const char* str) {
  PgmPrint("error: ");
  SerialPrintln_P(str);
  if (card.errorCode()) {
    PgmPrint("SD error: ");
    Serial.print(card.errorCode(), HEX);
    Serial.print(',');
    Serial.println(card.errorData(), HEX);
  }
  while(1);
}

struct oscillator
{
  uint32_t phase;
  int32_t phase_increment;
} 
o1;

/*** following 2 functions from Adrian Freed ***/
unsigned long phaseinc(float frequency_in_Hz)
{
  return LUTsize *(1l<<fractionalbits)* frequency_in_Hz/(F_CPU/timerPrescale);
}

void initializeTimer() {
  TCCR2A = _BV(COM2B1)  | _BV(WGM21) | _BV(WGM20);
  TCCR2B = _BV(CS20);
  TIMSK2 = _BV(TOIE2);
  pinMode(PWM_PIN,OUTPUT);
}
/**********************************************/


void setup()
{
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  digitalWrite(A1, HIGH);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  digitalWrite(A4, HIGH);
  pinMode(A5, INPUT);
  if (!card.init(SPI_FULL_SPEED, 9)) error("card.init failed");
  if (!volume.init(&card)) error("volume.init failed");
  if (!root.openRoot(&volume)) error("openRoot failed"); 
  if (file.open(&root, "data.dat", O_READ)) {
    //  Serial.println("Opened data.dat");
  }
  file.read(waveform, 256 * 2);
  o1.phase = 0;
  o1.phase_increment = 0;
  initializeTimer();
}

void loop() {
  /*****************************************************************************
   * frequency is modulated by both pot and cv input, which are summed - each covering half the potential range
   * necessary to do it this way to maintain v/octave control of pitch.
   *****************************************************************************/
  analogRead(A1); // toss this value for accuracy
  frequencyInputs = analogRead(A1) / 102.3;
  analogRead(A4); // toss this value for accuracy
  frequencyInputs += analogRead(A4) / 102.3;
  
  frequencyInputs = pow(2, frequencyInputs); // v/octave pitch
  frequency = (frequency * 0.8) + (frequencyInputs * 0.2); // compute a moving average, to minimize freq jitter
  o1.phase_increment = phaseinc(frequency);

  // the other controls are only read every 50th cycle through loop() because they are less frequency dependent
  // hopefully this allows for a higher rate of FM

  if(counter >= 50){
    /*****************************************************************************  
     * the midpoint of the waveform select is set by the potentiometer.
     * the potentiometer setting also establishes the range that the cv input is allowed to cover.
     * when the pot is set in the middle, the cv in swings the whole range (0 - 63), otherwise it is limited to a smaller range.
     * this keeps the waveform value value constrained to the range 0 - 63, while still allowing both the pot and the cv input
     * to cover the entire range 
     *****************************************************************************/
    midpoint = analogRead(A2) * 0.0009775; // knob 0 - 1
    if(midpoint <= 0.5) {
      range = midpoint;
    } else {
      range = (1 - midpoint) * -1;		
    }
    slotCV = analogRead(A3) * 0.0009775; // 0 - 1
    slotCV = (slotCV * 2) - 1; // -1 to +1
    waveformSlot = int((midpoint + (slotCV * range)) * 32) * 2;
    if(waveformSlot != previousWaveformSlot){
      file.seekSet(waveformSlot * 256); 
      cli();
      file.read(waveform, 256 * 2);
      sei();
      previousWaveformSlot = waveformSlot;
    }
    /*****************************************************************************  
     * the midpoint of the crossfade is set by the potentiometer.
     * the potentiometer setting also establishes the range that the cv input is allowed to cover.
     * when the pot is set in the middle, the cv in swings the whole range (0 - 1), otherwise it is limited to a smaller range.
     * this keeps the crossfade value constrained to the range 0.0 - 1.0, while still allowing both the pot and the cv input
     * to cover the entire range 
     *****************************************************************************/
    midpoint = analogRead(A0) * 0.0009775; // 0 - 1
    if(midpoint <= 0.5) {
      range = midpoint;
    } else {
      range = (1 - midpoint) * -1;
    }
    fadeCV = analogRead(A5) * 0.0009775; // 0 - 1
    fadeCV = (fadeCV * 2) - 1; // -1 to +1
    fadeInputs = midpoint + (fadeCV * range);
    for(int i = 0; i < 256; ++i){
      finalWaveform[i] =  (waveform[i] * fadeInputs) + (waveform[i + 256] * (1 - fadeInputs)); 
    }
    counter = 0;
  }
  ++counter;
}

SIGNAL(PWM_INTERRUPT)
{
  PWM_VALUE_DESTINATION = outputvalue; 
  outputvalue = (finalWaveform[((o1.phase>>16)%LUTsize)]); 
  o1.phase = o1.phase + o1.phase_increment;
}





