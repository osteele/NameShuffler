// Name: name-shuffler.pde
// Author: Oliver Steele
// Source: https://gist.github.com/osteele/3351fb073ab0ea4e1568b7d7e9310447
// License: MIT
//
// Instructions:
// Edit a list of names into nameStrings, below.
// Run the program. It presents them shuffled.
// Click to shuffle agin.

final int MOUSE_CLICK_SHUFFLE_DURATION = 60;
final int AUTO_SHUFFLE_COUNT = 5;
final int AUTO_SHUFFLE_MAX_DURATION = 40;
final int AUTO_SHUFFLE_MIN_DURATION = 15;

StringList names;
FloatList lineYs;
FloatList yStarts;
FloatList yEnds;
FloatList currentYs;
float textWidth;

int startFrame = 15;
int autoshuffleCount = AUTO_SHUFFLE_COUNT;

// Test data generated by fzaninotto/Faker
String defaultNameStrings[] = {
  "Kristin & Ramona", 
  "Delphia & Sarah", 
  "Letha & Maxime", 
  "Dahlia, Kolby, & Dewitt", 
  "Sierra & Theron", 
};

String nameStrings[];

void setup() {
  //size(500, 500);
  fullScreen();
  colorMode(HSB);

  String[] namesArray = loadStrings("names.txt");
  names = stringListFromArray(namesArray != null ? namesArray : defaultNameStrings);
  autoshuffleCount = names.size();

  for (float textSize = 180; textSize > 12; textSize *= 0.8) {  
    textSize(textSize);
    final float textLineHeight = textAscent() + textDescent();
    final float textLeading = textLineHeight * 1.5;
    final float textHeight = (names.size() - 1) * textLeading + textLineHeight;
    
    textWidth = 0;
    lineYs = new FloatList();
    float y = (height - textHeight + textLeading) / 2;
    for (int i = 0; i < names.size(); i++) {
      textWidth = max(textWidth, textWidth(names.get(i)));
      lineYs.append(floor(y));
      y += textLeading;
    }
    if (textWidth < width && textHeight < height) break;
  }

  currentYs = lineYs.copy();
  yStarts = lineYs.copy();
  yEnds = yStarts;
}

void draw() {
  background(100);

  fill(220);
  final float animationDuration = autoshuffleCount >= 0
    ? map(autoshuffleCount, AUTO_SHUFFLE_COUNT, 0, AUTO_SHUFFLE_MAX_DURATION, AUTO_SHUFFLE_MIN_DURATION)
    : MOUSE_CLICK_SHUFFLE_DURATION;
  final float s0 = clampMap(frameCount - startFrame, 0, animationDuration, 0, 1);
  final float s = easeInOutCubic(s0);
  final float x = (width - textWidth) / 2;
  for (int i = 0; i < names.size(); i++) {
    final String name = names.get(i);
    final float y0 = currentYs.get(i);
    final float y = map(s, 0, 1, yStarts.get(i), yEnds.get(i));
    final int n = ceil(abs(y - y0));
    for (int j = 0; j < n; j++) {
      fill(map(i, 0, names.size(), 0, 255), 200, 250, map(j, 0, n, 10, 250));
      text(name, x, map(j, 0, n, y0, y));
    }
    fill(map(i, 0, names.size(), 0, 255), 120, 250);
    currentYs.set(i, floor(y));
    text(name, x, y);
  }
  if (s >= 1 && --autoshuffleCount >= 0) {
    startShuffle();
  }
}

void mousePressed() {
  autoshuffleCount = 0;
  startShuffle();
}

void keyPressed() {
  if (key == 'q') {
    exit();
  }
}

void startShuffle() {
  startFrame = frameCount;
  yStarts = currentYs;
  yEnds = lineYs.copy();
  yEnds.shuffle();
}

float clamp(float value, float low, float high) {
  return max(low, min(high, value));
}

float clampMap(float value, float start1, float stop1, float start2, float stop2) {
  float unclamped = map(value, start1, stop1, start2, stop2);
  return clamp(unclamped, start2, stop2);
}

float easeInOutCubic(float x) {
  return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
}

StringList stringListFromArray(String[] strings) {
  StringList result = new StringList();
  for (int i = 0; i < strings.length; i++) {
    result.append(strings[i]);
  }
  return result;
}
