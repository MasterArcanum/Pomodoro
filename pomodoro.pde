import processing.sound.*;

int sessionDuration = 25 * 60; // Длительность одной сессии (в секундах)
int breakDuration = 5 * 60; // Длительность перерыва (в секундах)
int currentTime;
int currentMode = 0; // 0 - сессия, 1 - перерыв
int timerStartTime;
boolean isRunning = false;

Button increaseButton;
Button decreaseButton;
Button breakIncreaseButton;
Button breakDecreaseButton;

PImage startImage; // Переменная для хранения изображения "Старт"
PImage stopImage; // Переменная для хранения изображения "Стоп"

SoundFile dingSound; // Звуковой эффект

void setup() {
  size(1300, 500);
  textAlign(CENTER, CENTER);
  textSize(40); // Увеличение размера текста таймера

  float buttonWidth = 180;
  float buttonHeight = 60;
  float buttonSpacing = 20;

  float startX = buttonSpacing; // Горизонтальное положение первой кнопки
  float breakStartX = width - buttonWidth - buttonSpacing; // Горизонтальное положение первой кнопки для изменения времени отдыха

  startImage = loadImage("start.png"); // Загрузка изображения "Старт"
  stopImage = loadImage("stop.png"); // Загрузка изображения "Стоп"

  startImage.resize(80, 80); // Изменение размера изображения "Старт" на 100x100
  stopImage.resize(80, 80); // Изменение размера изображения "Стоп" на 100x100

  // Создание кнопок увеличения и уменьшения таймера
  increaseButton = new Button(startX, 20, buttonWidth, buttonHeight, "\u25B2"); // Символ "▲" для кнопки "Увеличить"
  decreaseButton = new Button(startX + buttonWidth + buttonSpacing, 20, buttonWidth, buttonHeight, "\u25BC"); // Символ "▼" для кнопки "Уменьшить"

  // Создание кнопок увеличения и уменьшения времени отдыха
  breakIncreaseButton = new Button(breakStartX, 20, buttonWidth, buttonHeight, "\u25B2"); // Символ "▲" для кнопки "Увеличить"
  breakDecreaseButton = new Button(breakStartX - buttonWidth - buttonSpacing, 20, buttonWidth, buttonHeight, "\u25BC"); // Символ "▼" для кнопки "Уменьшить"

  if (currentMode == 0) {
    currentTime = sessionDuration;
  } else {
    currentTime = breakDuration;
  }

  dingSound = new SoundFile(this, "ding.wav"); // Загрузка звукового эффекта
}

void draw() {
  setGradientBackground(color(0, 236, 255), color(18, 0, 255)); // Установка градиентного фона

  if (isRunning) {
    int elapsedTime = millis() - timerStartTime;
    if (currentMode == 0) {
      currentTime = sessionDuration - elapsedTime / 1000;
      if (currentTime <= 0) {
        currentMode = 1;
        timerStartTime = millis();
        currentTime = breakDuration;
        dingSound.play(); // Воспроизведение звукового эффекта после завершения сессии
      }
    } else {
      currentTime = breakDuration - elapsedTime / 1000;
      if (currentTime <= 0) {
        currentMode = 0;
        timerStartTime = millis();
        currentTime = sessionDuration;
        dingSound.play(); // Воспроизведение звукового эффекта после завершения перерыва
      }
    }
  }

  int barHeight = 40; // Высота шкалы
  float barWidth = map(currentTime, 0, currentMode == 0 ? sessionDuration : breakDuration, 0, width); // Ширина шкалы

  // Отображение шкалы
  noStroke();
  fill(255, 100); // Прозрачный белый цвет
  rect(0, height / 2 + 60, barWidth, barHeight);

  textSize(100);
  String modeText = currentMode == 0 ? "" : "Перерыв";
  String timerText = String.format("%02d:%02d", currentTime / 60, currentTime % 60);

  fill(255); // Изменение цвета на белый
  text(timerText, width / 2, height / 2 - 40);
  text(modeText, width / 2, height / 2 + 40);

  // Отображение изображий "Старт" и "Стоп"
  image(startImage, width / 2 - startImage.width - 50, height - startImage.height - 20);
  image(stopImage, width / 2 + 50, height - stopImage.height - 20);

  // Отображение текущей длительности перерыва под кнопками настройки таймера перерыва
  textSize(30);
  String breakTimerText = String.format("Текущая длительность перерыва: %02d:%02d", breakDuration / 60, breakDuration % 60);
  fill(255); // Изменение цвета на белый
  text(breakTimerText, width / 2, 70); // Обновленное значение вертикального смещения

  if (!isRunning) {
    increaseButton.display();
    decreaseButton.display();
    breakIncreaseButton.display();
    breakDecreaseButton.display();
  }
}

void mousePressed() {
  if (!isRunning) {
    if (increaseButton.isClicked()) {
      increaseTime();
    } else if (decreaseButton.isClicked()) {
      decreaseTime();
    } else if (breakIncreaseButton.isClicked()) {
      increaseBreakTime();
    } else if (breakDecreaseButton.isClicked()) {
      decreaseBreakTime();
    }
  }

  if (mouseX >= width / 2 - startImage.width - 50 && mouseX <= width / 2 - 50 &&
    mouseY >= height - startImage.height - 20 && mouseY <= height - 20) {
    startTimer();
  } else if (mouseX >= width / 2 + 50 && mouseX <= width / 2 + stopImage.width + 50 &&
    mouseY >= height - stopImage.height - 20 && mouseY <= height - 20) {
    resetTimer();
  }
}

void startTimer() {
  timerStartTime = millis();
  isRunning = true;
}

void resetTimer() {
  currentMode = 0;
  currentTime = sessionDuration;
  isRunning = false;
}

void increaseTime() {
  if (currentMode == 0) {
    sessionDuration += 60;
    currentTime += 60;
  } else {
    breakDuration += 60;
    currentTime += 60;
  }
}

void decreaseTime() {
  if (currentMode == 0 && sessionDuration > 60) {
    sessionDuration -= 60;
    currentTime -= 60;
  } else if (currentMode == 1 && breakDuration > 60) {
    breakDuration -= 60;
    currentTime -= 60;
  }
}

void increaseBreakTime() {
  breakDuration += 60;
  if (currentMode == 1) {
    currentTime = breakDuration; // Обновление currentTime только в режиме отдыха
  }
}

void decreaseBreakTime() {
  if (breakDuration > 60) {
    breakDuration -= 60;
    if (currentMode == 1) {
      currentTime = breakDuration; // Обновление currentTime только в режиме отдыха
    }
  }
}


class Button {
  float x, y;
  float w, h;
  String content;
  boolean isHovered;

  Button(float x, float y, float w, float h, String content) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.content = content;
    this.isHovered = false;
  }

  void display() {
    noStroke();
    fill(200, 0); // Прозрачный фон кнопок
    rect(x, y, w, h);
    fill(255);

    textAlign(CENTER, CENTER);
    text(content, x + w / 2, y + h / 2);
  }

  void displayHovered() {
    noStroke();
    fill(150); // Цвет фона кнопки при наведении курсора
    rect(x, y, w, h);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(40); // Увеличение размера шрифта для кнопок при наведении курсора
    text(content, x + w / 2, y + h / 2);
  }

  boolean isClicked() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void checkHover() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      isHovered = true;
    } else {
      isHovered = false;
    }
  }

  boolean isHovered() {
    return isHovered;
  }
}

void setGradientBackground(color c1, color c2) {
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(0, y, width, y);
  }
}
