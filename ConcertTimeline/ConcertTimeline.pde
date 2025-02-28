import javax.swing.JFileChooser; // Import for file selection

int countdown = 3;  
int lastUpdateTime;
boolean started = false;
boolean enteringDuration = true;  
boolean imageSelected = false;
String inputText = "";  
int duration = 1;  // Default value (in seconds)
PImage img;  
boolean showBar = false;
float barX = 0;  
int barStartTime; // Track when the bar starts moving

void setup() {
  fullScreen();  
  textAlign(CENTER, CENTER);
  textSize(40);
}

void draw() {
  background(0);
  
  if (!imageSelected) {
    fill(255);
    text("Press any key to select an image...", width / 2, height / 2);
    
  } else if (enteringDuration) {
    fill(255);
    text("Enter a number and press ENTER:", width / 2, height / 2 - 50);
    text(inputText + "_", width / 2, height / 2);
    
  } else if (!started) {
    fill(100, 200, 100);
    rect(width / 2 - 75, height / 2 - 35, 150, 70);
    fill(255);
    textSize(30);
    text("Start", width / 2, height / 2 + 10);
    
  } else if (countdown >= 0) {
    fill(255);
    textSize(width / 5);
    text(countdown, width / 2, height / 2);

    if (millis() - lastUpdateTime >= 1000 && countdown > 0) {
      countdown--;
      lastUpdateTime = millis();
    } else if (countdown == 0) {
      countdown--;  // Ensure it only triggers once
      showBar = true;  
      barX = 0;  
      barStartTime = millis(); // Record when the bar starts moving
    }
  } else if (showBar) {
    image(img, 0, 0, width, height);
    
    // Calculate time elapsed since bar started
    float elapsed = (millis() - barStartTime) / 1000.0;
    barX = map(elapsed, 0, duration, 0, width); // Moves from 0 to width in 'duration' seconds
    
    // Draw moving green bar
    fill(0, 255, 0, 150);  // Semi-transparent for better effect
    rect(0, 0, barX, height);
    
    if (elapsed >= duration) {
      showBar = false;  // Stop bar when it reaches the right side
    }
  }
}

void keyPressed() {
  if (!imageSelected) {
    selectInput("Select an image:", "fileSelected"); // Open file picker
  } else if (enteringDuration) {
    if (key >= '0' && key <= '9') {
      inputText += key;  
    } else if (key == BACKSPACE && inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length() - 1);  
    } else if (key == ENTER || key == RETURN) {
      if (inputText.length() > 0) {
        duration = max(1, int(inputText));  // Ensure at least 1 second
      }
      enteringDuration = false;  
    }
  }
}

void fileSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());  
    imageSelected = true;
  }
}

void mousePressed() {
  if (!started && !enteringDuration && imageSelected &&
      mouseX > width / 2 - 75 && mouseX < width / 2 + 75 &&
      mouseY > height / 2 - 35 && mouseY < height / 2 + 35) {
    started = true;
    countdown = 3;  
    lastUpdateTime = millis();
  }
}
