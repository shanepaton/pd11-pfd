
// UI Color
int skyColor = #0F56D4;
int floorColor = #AA6949;

void setup() {  // setup() runs once
  size(1920, 1080);
  frameRate(60);
  PFont displayFont = loadFont("RobotoMono-Regular-48.vlw");
  textFont(displayFont, 256);

}

// Stolen from: https://discourse.processing.org/t/how-to-create-a-clipping-mask-that-preserves-transparency/16093/2
void alphaSubtract(PGraphics img, PGraphics cm){
  img.loadPixels();
  cm.loadPixels();
  if(img.pixels.length != cm.pixels.length){
    return;
  }
  for(int j = 0; j<img.height; j++){
    for(int i = 0; i<img.width; i++){
      // get argb values
      color argb = img.pixels[(j*img.width) + i];
      int a = argb >> 24 & 0xFF;
      int r = argb >> 16 & 0xFF;
      int g = argb >> 8 & 0xFF;
      int b = argb & 0xFF;
      
      color maskPixel = cm.pixels[(j*img.width) + i];
      int alphaShift = 0xFF - (maskPixel & 0xFF);  //grab blue value from mask pixel
      
      // subtract alphaShift from pixel's alpha value;
      img.pixels[(j*img.width) + i] = color(r,g,b,a-alphaShift);
    }
  }
}

void drawSky(){
  noStroke();
  fill(skyColor);
  rect(0, 0, 1920/2, 1080/2);
}

void drawBottomBackground(){
  scale(1);
  rotate(0); 
  noStroke();
  fill(#11110F);
  rect(0, 1080/2, 1920/2, 1080/2);
}


void drawAtitudeFloor(){
    scale(1); 
    fill(floorColor); 
    rotate(0); 
    rect(0, 1080/4, 1920/2, 1080/2); 
    rotate(0); 
    rotate(-PI-PI/6); 
    rotate(PI+PI/6); 
    rotate(-PI/6);  
 
    rotate(PI/6);
    scale(1.0);

    
}
//unit is cm
// bar is .25cm per

PGraphics ticksToMask, speedBGMask;

void drawSpeed(float speed){
  
  
  ticksToMask = createGraphics(width, height);
  speedBGMask = createGraphics(width, height);
  
  //Draw speed ticks
  ticksToMask.beginDraw();
  ticksToMask.clear();
  ticksToMask.stroke(255); //color white
  ticksToMask.strokeWeight(6);
  ticksToMask.line(128, 450, 128, 0); //trackline
  ticksToMask.strokeWeight(4);
  ticksToMask.strokeCap(PROJECT);
  ticksToMask.textSize(20);
  //loop for drawing speed ticks
  for (int i = 0; i < 201; i = i+1) {
    int x = 0;
    // First and Fifth tick are Larger
    if (i % 5 == 0){
      x = 100;
      ticksToMask.text(str(int(i*4)), 55, 1080/4 - (i*24) -1 + speed * 6 + 18/4 + 3); 
    }
    else if (i == 0){
      x = 100;
      ticksToMask.text(str(int(i*4)), 55, 1080/4 - (i*24) -1 + speed * 6 +3); 
    }
    else {
      x= 110;
    }
    // Witchcraft Magic
    ticksToMask.line(126, 1080/4 - (i*24) -1 + speed * 6, x, 1080/4 - (i*24) -1 + speed * 6 );
  }
  ticksToMask.endDraw();
  
  speedBGMask.beginDraw();
  speedBGMask.noStroke();
  speedBGMask.rotate(0);
  speedBGMask.scale(1);
  speedBGMask.rect(32, 1080/4 - 180, 140, 360);
  speedBGMask.endDraw();
  alphaSubtract(ticksToMask, speedBGMask);
  
  image(ticksToMask, 0, 0);
  
  //Speed Number Background
  stroke(255);
  strokeWeight(2);
  beginShape();
  vertex(32, 1080/4 -20 -1);
  vertex(80, 1080/4 -20 -1);
  vertex(98, 1080/4 -1);
  vertex(80, 1080/4 +20 -1);
  vertex(32, 1080/4 +20 -1);
  endShape(CLOSE);
  
  //Speed text
  fill(255,255,255);
  textSize(24);
  if(testSpeed > 800){
    fill(255, 0, 0);
    text("SPD", 40, 1080/4 +8); 
  } else{
    fill(0, 255, 0);
    text(str(int(testSpeed)), 40, 1080/4 +8); 
  }
}

void drawInfoBackground(){ 
  // IAS Background
  noStroke();
  rotate(0);
  scale(1);
  fill(0, 0, 0, 100);
  rect(32, 1080/4 - 180, 140, 360);
  
  // Altitude Indicator Background
  noStroke();
  rotate(0);
  scale(1);
  fill(0, 0, 0, 100);
  rect(1920/2 - (128 + 48), 1080/4 - 180, 140, 360);
}

float testSpeed = 0;
 
void draw() {  
  testSpeed +=10;
  background(0);
  drawSky();
  drawAtitudeFloor();
  drawInfoBackground();
  drawBottomBackground();
  drawSpeed(testSpeed);
}
