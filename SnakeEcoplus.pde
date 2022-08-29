ArrayList<snakePart> allSnake = new ArrayList<snakePart>();
ArrayList<PVector> coordinates = new ArrayList<PVector>();

float rows = 30;
float rowSize;

float timeToMove = 80;
float timeSinceMove;
float actualTime;

int fruitX, fruitY;

int headSpawnRange = 2;
int gameSpaceRangeInit = 2;
int gameSpaceRange;

color red = #EC2525;
color black = #000000;
color BG = #F3F3F3;
color gameBG = #E8E8E8;
float maxL = 80;
float minL = 35;

int score;
boolean gameStarted;
boolean dead = false;
boolean out = false;

boolean dirUpdated = false;

PFont comfortaa;

int difficulty = 1;
int diffBtnSize = 60;
int diffBtnHeight = 700;
color diff1col = #73E739;
color diff1colHover = #8FFA59;
color diff2col = #D4E739;
color diff2colHover = #E8F95B;
color diff3col = #E78539;
color diff3colHover = #FCA765;

int startBtnWidth = 60;
int startBtnHeight = 65;

enum direction{
  left, right, up, down, none
}
direction actualDir;

enum state{
  menu, game
}
state actualState = state.menu;

void setup()
{
  size(800,800);
  colorMode(HSB, 360, 100, 100);
  comfortaa = createFont("Comfortaa",32);
  textFont(comfortaa);
  rowSize = width / rows;
}

void draw()
{
  background(BG);
  switch(actualState)
  {
    case game: 
      displayGameHUD();
      increaseTimer();
      drawSnake();
      drawFruit();
      if(dead) displayGameOver();
      break;
    case menu:
      displayMenuHUD();
      break;
  }
}

void startGame()
{
  gameStarted = false;
  actualState = state.game;
  actualDir = direction.none;
  dead = false;
  score = 1;
  gameSpaceRange = gameSpaceRangeInit + difficulty;
  if(difficulty == 1) timeToMove = 100;
  if(difficulty == 2) timeToMove = 80;
  if(difficulty == 3) timeToMove = 60;
  actualTime = millis();
  allSnake.clear();
  coordinates.clear();
  createHead();
  spawnFruit();
}

void createHead()
{
  int randX = int(random(0 + headSpawnRange + gameSpaceRange, rows - headSpawnRange - gameSpaceRange));
  int randY = int(random(0 + headSpawnRange + gameSpaceRange, rows - headSpawnRange - gameSpaceRange));
  snakePart head = new snakePart(randX, randY, 0);
  PVector headCoord = new PVector(head.x, head.y);
  allSnake.add(head);
  coordinates.add(headCoord);
}

void displayGameHUD()
{
  fill(gameBG);
  rect(gameSpaceRange * rowSize, gameSpaceRange * rowSize, width-gameSpaceRange*rowSize*2, height-gameSpaceRange*rowSize*2);
  textAlign(LEFT, CENTER);
  textSize(40);
  String scoreText = "Score : " + str(score);
  fill(black);
  text(scoreText, gameSpaceRange * rowSize, 40);
  if(!gameStarted)
  {
    textAlign(CENTER, CENTER);
    text("Press an arrow key to start", width/2, height/2); 
  }
}

void displayGameOver()
{
  textAlign(CENTER, CENTER);
  textSize(40);
  fill(black);
  if(out) text("Don't try to Escape like this !", width/2, 3*height/8);
  else text("Did you eat yourself ?", width/2, 3*height/8);
  textSize(30);
  text("Press Enter to restart \n or Press Escape to go back to Menu", width/2, 5*height/8);
}

void increaseTimer()
{
  if(dead) return;
  timeSinceMove += millis();
  if(millis() - actualTime >= timeToMove)
  {
    actualTime = millis();
    prepareCoordinates();
  }
}

void prepareCoordinates()
{
  PVector vec = new PVector(allSnake.get(allSnake.size()-1).x, allSnake.get(allSnake.size()-1).y);
  coordinates.add(vec);
  for(int i = coordinates.size()-1; i>0; i--)
  {
    coordinates.get(i).x = coordinates.get(i-1).x;
    coordinates.get(i).y = coordinates.get(i-1).y;
  }
  computeMovement();
}

void computeMovement()
{
  switch(actualDir)
  {
    case left:
      coordinates.get(0).x -= 1; 
      break;
    case right:
      coordinates.get(0).x += 1; 
      break;
    case up:
      coordinates.get(0).y -= 1; 
      break;
    case down:
      coordinates.get(0).y += 1; 
      break;
    case none:
      break;
  }
  dirUpdated = false;
  for(int i=0; i<allSnake.size(); i++)
  {
    allSnake.get(i).x = int(coordinates.get(i).x);
    allSnake.get(i).y = int(coordinates.get(i).y);
  }
  checkCollisions();
}

void checkCollisions()
{
  PVector head = new PVector(allSnake.get(0).x, allSnake.get(0).y);
  if(head.x < 0 + gameSpaceRange || head.x >= rows - gameSpaceRange || head.y < 0 + gameSpaceRange || head.y >= rows - gameSpaceRange)
  {
    dead = true;
    out = true;
  }
  for(int i=1; i<allSnake.size(); i++)
  {
    if(head.x == allSnake.get(i).x && head.y == allSnake.get(i).y)
    {
      dead = true;
      out = false;
    }
  }
  if(allSnake.get(0).x == fruitX && allSnake.get(0).y == fruitY)
  {
    spawnFruit();
    createNewBody();
    score++;
  }
  else{
    coordinates.remove(coordinates.size()-1);
  }
}

void createNewBody()
{
  snakePart body = new snakePart( allSnake.get(allSnake.size()-1).x , allSnake.get(allSnake.size()-1).y, allSnake.size()-1);
  allSnake.add(body);
}

void drawSnake()
{
  float step;
  if(allSnake.size() != 1) step = (maxL - minL) / float(allSnake.size()-1);
  else step = 0;
  for(int i=0; i<allSnake.size(); i++)
  {
    allSnake.get(i).drawSnakePiece(color(105,95,minL+i*step));
  }
} //<>//

void drawFruit()
{
  fill(red);
  ellipse(rowSize * fruitX, rowSize * fruitY, rowSize, rowSize); 
}

void keyPressed()
{
  if(!dirUpdated)
  {
     switch(keyCode)
    {
      case UP:
        if(actualDir != direction.down) actualDir = direction.up;
        break;
      case DOWN:
        if(actualDir != direction.up) actualDir = direction.down;
        break;
      case LEFT:
        if(actualDir != direction.right) actualDir = direction.left;
        break;
      case RIGHT:
        if(actualDir != direction.left) actualDir = direction.right;
        break;
    }
  }

   if(key == ENTER && dead) startGame();
   if(key == ESC)
   {
     key = 0;
     actualState = state.menu;
   }
  
  dirUpdated = true;
  if(!gameStarted && !dead)
  {
    gameStarted = true;
  }
}

void spawnFruit()
{
  int randX = int(random(0 + gameSpaceRange, rows - gameSpaceRange));
  int randY = int(random(0 + gameSpaceRange, rows - gameSpaceRange));
  boolean onSnake = false;
  for(int i=0; i<allSnake.size(); i++)
  {
    if(randX == allSnake.get(i).x && randY == allSnake.get(i).y)
    {
      onSnake = true;
      break;
    }
  }
  if(onSnake) spawnFruit();
  else
  {
    fruitX = randX;
    fruitY = randY;
  }
}

void displayMenuHUD()
{
  drawButtons();
  textAlign(CENTER, CENTER);
  fill(black);
  textSize(85);
  text("SNEK GAME", width/2, height/7);
  textSize(40);
  text("Select Difficulty", width/2, diffBtnHeight - 100);
  textSize(20);
  text("1", width/2 - diffBtnSize * 2, diffBtnHeight);
  text("2", width/2, diffBtnHeight);
  text("3", width/2 + diffBtnSize * 2, diffBtnHeight);
  textSize(65);
  if(difficulty == 1) text("^", width/2 - diffBtnSize * 2, diffBtnHeight+70);
  if(difficulty == 2) text("^", width/2, diffBtnHeight+70);
  if(difficulty == 3) text("^", width/2 + diffBtnSize * 2, diffBtnHeight+70);
}

void drawButtons()
{
  noStroke();
  if(overCircle(width/2 - diffBtnSize * 2, diffBtnHeight, diffBtnSize)) fill(diff1colHover);
  else fill(diff1col);
  ellipse(width/2 - diffBtnSize * 2, diffBtnHeight, diffBtnSize, diffBtnSize);
  
  if(overCircle(width/2, diffBtnHeight, diffBtnSize)) fill(diff2colHover);
  else fill(diff2col);
  ellipse(width/2, diffBtnHeight, diffBtnSize, diffBtnSize);
  
  if(overCircle(width/2 + diffBtnSize * 2, diffBtnHeight, diffBtnSize)) fill(diff3colHover);
  else fill(diff3col);
  ellipse(width/2 + diffBtnSize * 2, diffBtnHeight, diffBtnSize, diffBtnSize);
  
  fill(BG);
  stroke(0);
  strokeWeight(6);
  ellipseMode(CENTER);
  ellipse(width/2,height/2,100,100);
  noStroke();
  fill(#000000);
  triangle(width/2- startBtnWidth/2 + 12, height/2 - startBtnHeight/2, width/2 - startBtnWidth/2 + 12, height/2 + startBtnHeight/2, width/2 + startBtnWidth/2, height/2);
  
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } 
  else return false;
}

void mousePressed()
{
  if(overCircle(width/2 - diffBtnSize * 2, diffBtnHeight, diffBtnSize)) difficulty = 1;
  if(overCircle(width/2, diffBtnHeight, diffBtnSize)) difficulty = 2;
  if(overCircle(width/2 + diffBtnSize * 2, diffBtnHeight, diffBtnSize)) difficulty = 3;
  if(overCircle(width/2,height/2,100)) startGame();
}

class snakePart{
  int x;
  int y;
  int index;
  
  snakePart(int xC, int yC, int i)
  {
    x = xC;
    y = yC;
    index = i;
  }
  
  void drawSnakePiece(color col)
  {
    noStroke();
    ellipseMode(CORNER);
    fill(col);
    ellipse(rowSize * x, rowSize * y, rowSize, rowSize);
  }
}
