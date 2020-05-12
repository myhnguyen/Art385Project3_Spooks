/*
Spooks
by My Nguyen
 */
// Importing the serial library to communicate with the Arduino 
import processing.serial.*;

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;


//*****************************************sound file
import processing.sound.*;
SoundFile sound;
SoundFile pop;
SoundFile twist;
SoundFile spray;

Timer ghostTimer;


// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
// data[2] = 0-4095, e.g. "1023"        -- LDR value
String[] data;
AnimatedPNG[] ghostArray;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;
int numGhosts = 6;
//flying ghost timer positions
int GhostX = 0;
int GhostY = 40;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 2;


// an animated figure
int redTintGhostNum = 2;

// Three possible projectiles
AnimatedPNG button;
AnimatedPNG pot;
AnimatedPNG ldr;
AnimatedPNG ghostspray;
AnimatedPNG flyingGhost;

int frameNum; // we use this for determining when to release a projectile
int frameTimeMS = 300;
int x;
int counter = 0;

void setup() {
  size(1000, 650);
  // List all the available serial ports

  ghostArray = new AnimatedPNG[numGhosts];
  ghostArray[0] = new AnimatedPNG();
  ghostArray[0].load("ghost", frameTimeMS);
  ghostArray[1] = new AnimatedPNG();
  ghostArray[1].load("secghost", frameTimeMS);
  ghostArray[2] = new AnimatedPNG();
  ghostArray[2].load("thirdghost", frameTimeMS);
  ghostArray[3] = new AnimatedPNG();
  ghostArray[3].load("fourthghost", frameTimeMS);
  ghostArray[4] = new AnimatedPNG();
  ghostArray[4].load("fifthghost", frameTimeMS);
  ghostArray[5] = new AnimatedPNG();
  ghostArray[5].load("sixthghost", frameTimeMS);

  printArray(Serial.list());

  // Set the com port and the baud rate according to the Arduino IDE
  //-- use your port name
  myPort = new Serial(this, "/dev/cu.SLAB_USBtoUART", 115200);

  imageMode(CENTER);
  button = new AnimatedPNG(); // "hearts1.png", "hearts2.png", etc.
  button.load("button", frameTimeMS);

  pot = new AnimatedPNG(); // "bananas1.png", "bananas1.png", etc.
  pot.load("pot", 150);

  ldr = new AnimatedPNG(); // "lightning1.png", "lightning2.png", etc.
  ldr.load("ldr", frameTimeMS);

  ghostspray = new AnimatedPNG(); // "lightning1.png", "lightning2.png", etc.
  ghostspray.load("ghostspray", frameTimeMS);

  flyingGhost = new AnimatedPNG();
  randomizeGhost();
  flyingGhost.load("flying", frameTimeMS);

  ghostTimer = new Timer(5000);
  ghostTimer.start();


  //************************************ Load a soundfile 

  sound = new SoundFile(this, "music.mp3");
  sound.play();


}

//-- Draw animated figures
void draw() {
  background(0);
  checkSerial();
  if (potValue > 0) {
    drawRedGhosts();
  } else
    drawGhosts();
  drawSwitches();
  convertGhost();
  drawTimer();


}





////////////////////////////////////////?????????////???/////////////////
void randomizeGhost() {
  redTintGhostNum = int(random(0, numGhosts));

}
////////////////////////////////////////?????????////???/////////////////

//this will draw the ghost spray on top!
void convertGhost() {
  x = int(random(80, 700));

  if (switchValue == 1) {
    fill(255);
    textSize(30);
    text("NO GHOST", 80, 200);
    noTint();
    ghostspray.draw(x, height - 250);

  }

}


void drawGhosts() {
  int w = 200;
  int h = 250;
  int w2 = 200;
  int h2 = 250;

  if (ldrValue <= 700) {
    for (int i = 3; i < numGhosts; i++) {
      ghostArray[i].draw(w2, h2);
      w2 += 300;
      h2 += 100;
    }
  }

  if (ldrValue > 700) {
    // draw animation
    for (int i = 0; i < numGhosts; i++) {
      ghostArray[i].draw(w, h);
      w += 300;
      h += 100;
    }
  }

}

//this will draw the one evil ghost and good ghosts on top
void drawRedGhosts() {

  int w = 200;
  int h = 250;
  int w2 = 200;
  int h2 = 250;
  int ghostsTintOpacity = int(map(potValue, 0, 4095, 0, 255));


  if (ldrValue < 700) {
    for (int i = 3; i < numGhosts; i++) {
      if (i == redTintGhostNum) {
        tint(255, 0, 0, ghostsTintOpacity);
      } else
        tint(0, 255, 0, ghostsTintOpacity);
      ghostArray[i].draw(w2, h2);
      w2 += 300;
      h2 += 100;
    }
  }

  if (ldrValue >= 700) {
    // draw animation
    for (int i = 0; i < 3; i++) {
      if (i == redTintGhostNum) {
        tint(255, 0, 0, ghostsTintOpacity);
      } else
        tint(0, 255, 0, ghostsTintOpacity);
      ghostArray[i].draw(w, h);
      w += 300;
      h += 100;
    }
  }
}


//Timer that draws ghosts flying on top!
void drawTimer() {
  if (ghostTimer.expired()) {

    flyingGhost.draw(GhostX, GhostY);
    GhostX++;

    if (GhostX == 1100) {
      GhostX = -50;
    }
  }
}




void drawSwitches() {
  // show all the animations
  noTint();
  button.draw(80, height - 50);
  pot.draw(180, height - 50);
  ldr.draw(280, height - 50);
}


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();

    print(inBuffer);

    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));

    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');

    // we have THREE items — ERROR-CHECK HERE
    if (data.length >= 3) {
      switchValue = int(data[0]); // first index = switch value 
      potValue = int(data[1]); // second index = pot value
      ldrValue = int(data[2]); // third index = LDR value
    }
  }
}
