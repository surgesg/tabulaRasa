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

