/*
    Splash.pde
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

void drawSplashScreen(){
  image(splash, 0, 0);
}

void drawSpeakerIcon(){
  fill(0, 200, 0);
  rect(625, 367, 15, 15); //right speaker
  image(speaker, 625, 367);  
  fill(200, 0, 0);
  rect(410, 367, 15, 15); //left speaker
  image(speaker, 410, 367);  
}

void drawOutlines() {
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

void drawAbout() {
  image(about, 0, 0);
// add about screen and mouse click;
  }

