import processing.serial.*;

Serial serialPort;
String comPort;
int baudRate = 115200;
boolean testingMode = true;

int skyColor = #0F56D4;
int floorColor = #AA6949;

float testSpeed = 100;
float testAltidude = 1200;

float speed;
float altitude;

PFont robotoMono;
PFont pfdFont;

void setup() {
  size(1920, 1080);
  frameRate(60);
  robotoMono = loadFont("RobotoMono-Regular-48.vlw");
  pfdFont = loadFont("MS33558.vlw");
  textFont(robotoMono);
  
  if (!testingMode) {
    serialPort=new Serial(this, Serial.list()[0], baudRate);
    comPort=Serial.list()[0];
    print(Serial.list());
    serialPort.clear();
    serialPort.bufferUntil('\n');
  }
}

// Stolen from: https://discourse.processing.org/t/how-to-create-a-clipping-mask-that-preserves-transparency/16093/2
void alphaSubtract(PGraphics img, PGraphics cm) {
  img.loadPixels();
  cm.loadPixels();
  if (img.pixels.length != cm.pixels.length) return;
  for (int j = 0; j < img.height; j++) {
    for (int i = 0; i < img.width; i++) {
      color argb = img.pixels[(j * img.width) + i];
      int a = argb >> 24 & 0xFF;
      int r = argb >> 16 & 0xFF;
      int g = argb >> 8 & 0xFF;
      int b = argb & 0xFF;
      color maskPixel = cm.pixels[(j * img.width) + i];
      int alphaShift = 0xFF - (maskPixel & 0xFF);
      img.pixels[(j * img.width) + i] = color(r, g, b, a - alphaShift);
    }
  }
}

void serialEvent(Serial port) {
  String input = port.readStringUntil('\n');
  if (input != null) {
    input = trim(input);
    String[] values = split(input, " ");
    if (values.length == 3) {
      float phi = float(values[0]);
      float theta = float(values[1]);
      float psi = float(values[2]);
      print(phi);
      print(theta);
      println(psi);
      //Phi = phi; //yaw -180 ~ 180
      //Theta = theta; //pitch -90 ~ 90
     // Psi = psi; //roll -180 ~ 180
    }
  }
}


void drawSky() {
  noStroke();
  fill(skyColor);
  rect(0, 0, 1920 / 2, 1080 / 2);
}

void drawBottomBackground() {
  noStroke();
  fill(#11110F);
  rect(0, 1080 / 2, 1920 / 2, 1080 / 2);
}

void drawAtitudeFloor() {
  fill(floorColor);
  rect(0, 1080 / 4, 1920 / 2, 1080 / 2);
}


// Tick is 4cm bar is 20cm
PGraphics spdticksToMask, speedBGMask;

void drawSpeed(float speed) {
  spdticksToMask = createGraphics(width, height);
  speedBGMask = createGraphics(width, height);

  // Draw speed ticks mask
  spdticksToMask.beginDraw();

  //Backing Line
  spdticksToMask.stroke(255);  // color white
  spdticksToMask.strokeWeight(6);
  spdticksToMask.line(128, 450, 128, 0);

  // Actual Speed Ticks
  spdticksToMask.strokeWeight(4);
  spdticksToMask.strokeCap(PROJECT);
  spdticksToMask.textSize(20);
  spdticksToMask.textFont(robotoMono, 20);
  spdticksToMask.textAlign(CENTER);
  // Draw speed ticks
  for (int i = 0; i < 301; i = i + 1) {
    int x = 0;
    // First and Fifth tick are Larger
    if (i % 5 == 0 || i == 0) {
      x = 100;
      spdticksToMask.text(str(int(i * 4)), 76, 1080 / 4 - (i * 24) - 1 + speed * 6 + 18 / 4 + 3);
    } else {
      x = 110;
    }
    // Witchcraft Magic
    spdticksToMask.line(126, 1080 / 4 - (i * 24) - 1 + speed * 6, x, 1080 / 4 - (i * 24) - 1 + speed * 6);
  }
  spdticksToMask.endDraw();

  speedBGMask.beginDraw();
  speedBGMask.noStroke();
  speedBGMask.rotate(0);
  speedBGMask.scale(1);
  speedBGMask.rect(32, 1080 / 4 - 180, 140, 360);
  speedBGMask.endDraw();

  alphaSubtract(spdticksToMask, speedBGMask);
  image(spdticksToMask, 0, 0);

  // Speed Number Background
  beginShape();
  stroke(255);
  strokeWeight(2);
  vertex(32, 1080 / 4 - 20 - 1);
  vertex(80, 1080 / 4 - 20 - 1);
  vertex(98, 1080 / 4 - 1);
  vertex(80, 1080 / 4 + 20 - 1);
  vertex(32, 1080 / 4 + 20 - 1);
  endShape(CLOSE);

  // Speed text
  textFont(robotoMono);
  textAlign(CENTER);
  textSize(24);
  fill(testSpeed > 800 ? 255 : 0, testSpeed < 800 ? 255 : 0, 0);
  text(testSpeed > 800 ? "SPD" : str(int(testSpeed)), 60, 1080 / 4 + 8);
}

void drawTintedBackgrounds() {
  fill(0, 0, 0, 100);
  rect(32, 1080 / 4 - 180, 140, 360); // Speed Background
  rect(1920 / 2 - (128 + 48), 1080 / 4 - 180, 140, 360); // Altitude Indicator Background
  rect(1920 / 4 - (160), 0 , 320, 64);
}


void draw() {
  background(0);
  drawSky();
  drawAtitudeFloor();       
  drawTintedBackgrounds();
  drawBottomBackground();
  drawSpeed(testingMode == false ? speed : testSpeed);
  
  if(!testingMode){
    noStroke();
    fill(0, 255, 0);
    textFont(pfdFont);
    textSize(24);
    textAlign(CENTER);
    text(comPort, 486,48 - 3);
  } else{
    noStroke();
    fill(255, 255, 0);
    textFont(pfdFont);
    textSize(24);
    textAlign(CENTER);
    text("TESTING", 486,48 - 3);
  }
}

//TODO: Com port of connected arduino at the top (mimic ILS text on B737). COM13 - green; TEST - Yellow; N/C - Red
