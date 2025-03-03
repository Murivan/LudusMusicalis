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
    barX = map(elapsed, 0, barDuration, boxX1, boxX2);

    fill(0, 255, 0, 150);  // Green bar
    // Ensure the green bar does not extend beyond the bounding box
    rect(boxX1, 0, min(barX, boxX2) - boxX1, height);

    if (elapsed >= barDuration) {
      showBar = false;
      finished = true;  // Ensure the image remains visible
    }
  } 
  
  // Keep displaying the image even after the bar animation ends
  else if (finished) {
    drawImageCentered(img);
    fill(0, 255, 0, 150);  // Green bar still visible after animation
    // Ensure the green bar stays within the bounding box after completion
    rect(boxX1, 0, min(barX, boxX2) - boxX1, height);
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
