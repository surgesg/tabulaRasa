/*
TabulaRasa
 wavetable oscillator
 */


/*
  rotary switch connections
 42 ->  43 
 ++
 18 ->  82
 */

#include "FreqPeriod.h"
#include "SPI.h"
#include <avr/interrupt.h>
#include <SdFat.h>
#include <SdFatUtil.h>

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

byte waveform[256 * 2];
int waveformSlot = 0;
int previousWaveformSlot = 0;

int waveformFade = 0;
int previousWaveformFade = 0;

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

const unsigned int tableSize = 256; // must be a power of 2

const unsigned int sampleRate = 15000;

//#include "data.h"
#define SELECT_DAC digitalWrite(10, LOW);
#define DESELECT_DAC digitalWrite(10, HIGH);
#define TIMER_CLOCK_FREQ 2000000.0 //2MHz for /8 prescale from 16MHz

const int timerPrescale = 8;
int resetCounter = 0;
struct oscillator
{
  double phase;
  double phase_increment;
} 
osc;

const int fractionalBits = 16; // 16 bit fractional phase increment

double phaseIncrement(float freq_in_Hz){
  return tableSize * (freq_in_Hz / sampleRate); 
}

const int preDivide = 1;
unsigned long phaseIncrement_Fractional(unsigned long freqTimes256)
{
  return (1l << (fractionalBits - preDivide)
    * ((tableSize * (timerPrescale))
    * freqTimes256) / (sampleRate));
}

double pulseFreq;
long int pulsePeriod;

byte firstByte = 0;
byte secondByte = 0;

unsigned int latency;
unsigned int latencySum;
unsigned int sampleCount;
unsigned char timerLoadValue;

long int previousPeriod;

void setup(){
  pinMode(2, INPUT);
  pinMode(3, INPUT);
  pinMode(4, INPUT);
  pinMode(8, INPUT);
  digitalWrite(2, LOW);
  digitalWrite(3, LOW);
  digitalWrite(4, LOW);
  digitalWrite(8, LOW);
  pinMode(A0, INPUT);
  if (!card.init(SPI_QUARTER_SPEED, 9)) error("card.init failed");
  if (!volume.init(&card)) error("volume.init failed");
  if (!root.openRoot(&volume)) error("openRoot failed"); 
  if (file.open(&root, "data.dat", O_READ)) {
    Serial.println("Opened data.dat");
  }
  int index = 0;
  file.read(waveform, 256 * 2);
  SPI.begin();
  //Serial.begin(9600);
  pinMode(10, OUTPUT);
  FreqPeriod::begin();
  SPI.setClockDivider(SPI_CLOCK_DIV2);

  osc.phase = 0;
  osc.phase_increment = 0;
  timerLoadValue = SetupTimer2(sampleRate);  
}

void loop(){
  pulsePeriod = FreqPeriod::getPeriod();
  if(pulsePeriod){
    if(abs(previousPeriod - pulsePeriod) <= pulsePeriod / 5){
      pulseFreq = 16000400.0 / pulsePeriod;
      osc.phase_increment = phaseIncrement(pulseFreq);
    }
    previousPeriod = pulsePeriod;
  }

  //  ++resetCounter;
  waveformSlot = readSwitch();
  if(waveformSlot != previousWaveformSlot){
    cli();
    file.seekSet(waveformSlot * 256);
    file.read(waveform, 256 * 2);
    sei();
    resetCounter = 0;
    previousWaveformSlot = waveformSlot;
  }
  waveformFade = map(analogRead(A0), 0, 1023, 0, 256);
}

int readSwitch(){
  int value = 0;
  value += (digitalRead(8) * 1); 
  value += (digitalRead(3) * 2); 
  value += (digitalRead(4) * 4); 
  value += (digitalRead(2) * 8);  
  return value * 2;
}

//Setup Timer2.
//Configures the ATMega168 8-Bit Timer2 to generate an interrupt at the specified frequency.
//Returns the time load value which must be loaded into TCNT2 inside your ISR routine.
//See the example usage below.
unsigned char SetupTimer2(float timeoutFrequency){
  unsigned char result; //The value to load into the timer to control the timeout interval.

  //Calculate the timer load valueca
  result=(int)((257.0-(TIMER_CLOCK_FREQ/timeoutFrequency))+0.5); //the 0.5 is for rounding;
  //The 257 really should be 256 but I get better results with 257, dont know why.

  //Timer2 Settings: Timer Prescaler /8, mode 0
  //Timmer clock = 16MHz/8 = 2Mhz or 0.5us
  //The /8 prescale gives us a good range to work with so we just hard code this for now.
  TCCR2A = 0;
  TCCR2B = 0<<CS22 | 1<<CS21 | 0<<CS20; // should this be 0 0 1 (no prescaling?)

  //Timer2 Overflow Interrupt Enable   
  TIMSK2 = 1<<TOIE2;

  //load the timer for its first cycle
  TCNT2=result; 
  return(result);
}

ISR(TIMER2_OVF_vect) {
  SELECT_DAC;
  SPI.transfer(firstByte);
  SPI.transfer(secondByte);
  DESELECT_DAC;
  osc.phase = (osc.phase + osc.phase_increment);
  if(osc.phase >= 255){
    osc.phase = fmod(osc.phase, 256.0);
  }
  secondByte = (waveform[(uint8_t)(osc.phase + 0.5) + waveformFade] & 0xff); // weighted average needed
  firstByte = (waveform[(uint8_t)(osc.phase + 0.5) + waveformFade] >> 8);
  //Capture the current timer value. This is how much error we have
  //due to interrupt latency and the work in this function
  latency=TCNT2;

  //Reload the timer and correct for latency.  //Reload the timer and correct for latency.  //Reload the timer and correct for latency.
  TCNT2=latency+timerLoadValue; 
}

