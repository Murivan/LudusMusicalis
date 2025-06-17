boolean imageSelected = false; //<>//
boolean boxSelected = false;
boolean drawingBox = false;
boolean enteringBarDuration = false;  // Flag for entering the bar duration
boolean started = false;
boolean showBar = false;
boolean finished = false;

PImage img;
int boxX1, boxY1, boxX2, boxY2;
int countdown = 3;
int lastUpdateTime = 0;
float barX;
float barStartTime;
int barDuration = 5; // Default duration for the green bar animation
String inputText = "";

float timelineThickness = 5; // You can change this to make bars thicker or thinner

void setup() {
  fullScreen();  // Enable fullscreen mode
  textSize(32);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(0);

  if (!imageSelected) {
    fill(0, 255, 0);  // Bright green color for messages
    text("Press any key to select an image...", width / 2, height / 2);
  } else if (!boxSelected) {
    drawImageCentered(img);

    // Show the bounding box while dragging or after drawing
    if (drawingBox || (boxX2 > boxX1 && boxY2 > boxY1)) {
      fill(255, 0, 0, 100);  // Light red transparent fill
      stroke(255, 0, 0);  // Red border
      strokeWeight(2);
      rect(boxX1, boxY1, boxX2 - boxX1, boxY2 - boxY1);
      noStroke();
    }

    fill(0, 255, 0);  // Bright green messages
    text("Click & drag to draw a box. Press ENTER to confirm.", width / 2, height - 50);
  } else if (enteringBarDuration) {
    fill(0, 255, 0);  // Bright green color for messages
    text("Enter the bar animation duration (in seconds):", width / 2, height / 2 - 50);
    text(inputText + "_", width / 2, height / 2);
  } else if (!started) {
    drawImageCentered(img);
    fill(100, 200, 100);
    rect(width / 2 - 75, height / 2 - 35, 150, 70);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("Start", width / 2, height / 2);
  } else if (countdown >= 0) {
    drawImageCentered(img); // Show image during countdown

    fill(0, 255, 0);  // Bright green countdown text
    textSize(width / 5);
    text(countdown, width / 2, height / 2);

    if (millis() - lastUpdateTime >= 1000 && countdown > 0) {
      countdown--;
      lastUpdateTime = millis();
    } else if (countdown == 0) {
      countdown--;
      showBar = true;
      barX = boxX1;
      barStartTime = millis();
    }
  } else if (showBar) {
    drawImageCentered(img);

    float elapsed = (millis() - barStartTime) / 1000.0;
    float progress = constrain(elapsed / barDuration, 0, 1);

    noStroke();

    // GREEN: Left to Right (vertical bar)
    fill(0, 255, 0);
    float greenX = boxX1 + (boxX2 - boxX1 - timelineThickness) * progress;
    rect(greenX, boxY1, timelineThickness, boxY2 - boxY1);

    // RED: Right to Left (vertical bar)
    fill(255, 0, 0);
    float redX = boxX2 - (boxX2 - boxX1 - timelineThickness) * progress - timelineThickness;
    rect(redX, boxY1, timelineThickness, boxY2 - boxY1);

    // BLUE: Top to Bottom (horizontal bar)
    fill(0, 0, 255);
    float blueY = boxY1 + (boxY2 - boxY1 - timelineThickness) * progress;
    rect(boxX1, blueY, boxX2 - boxX1, timelineThickness);

    // GREY: Bottom to Top (horizontal bar)
    fill(128);
    float greyY = boxY2 - (boxY2 - boxY1 - timelineThickness) * progress - timelineThickness;
    rect(boxX1, greyY, boxX2 - boxX1, timelineThickness);

    if (elapsed >= barDuration) {
      showBar = false;
      finished = true;
    }
  }



  // Keep displaying the image even after the bar animation ends
  else if (finished) {
    drawImageCentered(img);
    noStroke();

    // GREEN: Left edge
    fill(0, 255, 0);
    rect(boxX2 - timelineThickness, boxY1, timelineThickness, boxY2 - boxY1);

    // RED: Right edge
    fill(255, 0, 0);
    rect(boxX1, boxY1, timelineThickness, boxY2 - boxY1);

    // BLUE: Bottom edge
    fill(0, 0, 255);
    rect(boxX1, boxY2 - timelineThickness, boxX2 - boxX1, timelineThickness);

    // GREY: Top edge
    fill(128);
    rect(boxX1, boxY1, boxX2 - boxX1, timelineThickness);
  }
}

void mousePressed() {
  if (!imageSelected) {
    return;
  }

  if (!boxSelected) {
    // Start drawing the bounding box (reset previous one)
    boxX1 = mouseX;
    boxY1 = mouseY;
    boxX2 = boxX1;
    boxY2 = boxY1;
    drawingBox = true;
  } else if (mouseOverStartButton()) {
    started = true;
    countdown = 3;  // Fixed countdown duration
    lastUpdateTime = millis();
  }
}

void mouseDragged() {
  if (drawingBox) {
    // Update bounding box while dragging
    boxX2 = mouseX;
    boxY2 = mouseY;
  }
}

void mouseReleased() {
  if (drawingBox) {
    // Stop drawing the bounding box
    drawingBox = false;
  }
}

void keyPressed() {
  if (!imageSelected) {
    selectInput("Select an image:", "fileSelected");
  } else if (!boxSelected && key == ENTER) {
    boxSelected = true; // Confirm bounding box selection

    enteringBarDuration = true; // Move to entering bar animation duration step
  } else if (enteringBarDuration) {
    if (key >= '0' && key <= '9') {
      inputText += key;
    } else if (key == BACKSPACE && inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      if (inputText.length() > 0) {
        barDuration = max(1, int(inputText)); // Set bar animation duration
      }
      enteringBarDuration = false; // End the duration input
    }
  }
}

void drawImageCentered(PImage img) {
  float imgAspect = float(img.width) / float(img.height);
  float screenAspect = float(width) / float(height);

  float imgWidth, imgHeight;

  if (imgAspect > screenAspect) {
    imgWidth = width;
    imgHeight = width / imgAspect;
  } else {
    imgHeight = height;
    imgWidth = height * imgAspect;
  }

  imageMode(CENTER);
  image(img, width / 2, height / 2, imgWidth, imgHeight);
}

boolean mouseOverStartButton() {
  return mouseX > width / 2 - 75 && mouseX < width / 2 + 75 && mouseY > height / 2 - 35 && mouseY < height / 2 + 35;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("No file selected");
  } else {
    img = loadImage(selection.getAbsolutePath());
    imageSelected = true;
  }
}
