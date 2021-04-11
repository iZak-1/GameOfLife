import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20 //
int NUM_ROWS;
int NUM_COLS=20;
float CELL_SIZE;
private Life[][] buttons; //2d array of Life buttons each representing one cell
private boolean[][] buffer; //2d array of booleans to store state of buttons array
private boolean[][] oldBuffer;
private boolean running; //used to start and stop program
public boolean nextFrame = false;
public int framerate = 6;
public int genCount;
public boolean isDead;
public boolean isStable;



public void setup () {
  size((int)(0.95*window.innerWidth), (int)(0.95*window.innerHeight));
  frameRate(framerate);
  CELL_SIZE=(float)width/NUM_COLS;
  NUM_ROWS=(int)floor(height/CELL_SIZE);
  
  genCount = 0;
  isDead = isStable = running = false;
  
  Interactive.make( this );
  
  buttons = new Life[NUM_ROWS][NUM_COLS];
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      buttons[i][j] = new Life(i, j);
    }
  }
  
  buffer = new boolean[NUM_ROWS][NUM_COLS];
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      buffer[i][j] = new Boolean(buttons[i][j].getLife());
    }
  }
  
  oldBuffer=new boolean[NUM_ROWS][NUM_COLS];
  copyToOldBuffer();
}



public void draw () {
  background( 0 );
  if(running) {
    copyFromBufferToButtons();
    genCount++;
  }
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if (running) {
        buttons[i][j].setLife(countNeighbors(i, j)==3||(countNeighbors(i, j)==2&&buttons[i][j].getLife()));
      }
      buttons[i][j].show();
    }
  }
  copyFromButtonsToBuffer();
  
  if(checkIfDead()&&genCount>0) {
    running = false;
    isDead = true;
  }
  
  if(running&&checkIfSame()) {
    running = false;
    isStable = true;
    genCount--;
  }
  copyToOldBuffer();
  
  
  fill(255);
  textSize(floor(height/30));
  textAlign(CENTER,BOTTOM);
  text(framerate+" fps",floor(width/2),floor(49*height/50));
  textAlign(RIGHT,BOTTOM);
  text(genCount, floor(49*width/50), floor(49*height/50));
  if(!running) {
    textAlign(CENTER,TOP);
    text("paused",floor(width/2),floor(height/50));
    textAlign(LEFT,BOTTOM);
    text(NUM_COLS+"x"+NUM_ROWS,floor(width/50),floor(49*height/50));
  }
  if(isStable||isDead) {
    textAlign(CENTER,CENTER);
    if(isStable) text("fully stable after "+genCount+" generations and onwards.\nReset or modify the grid to continue",floor(width/2),floor(height/2));
    if(isDead) text("dies at generation "+genCount+".\nReset or modify the grid to continue",floor(width/2),floor(height/2));
  }
  
  if (nextFrame) {
    nextFrame = false;
    running = false;
  }
}
public void keyPressed() {
  frameRate(20);                                                                                          //simulation controls
  if (keyCode == 32) //spacebar to toggle running
    running = !running;
  else if ((keyCode == 220||keyCode == 8)&&!running) //backslash to clear (when not running)
    setup();
  else if (keyCode==192&&!running) {//tilde to randomize (when not running)
    for (int i = 0; i<NUM_ROWS; i++) {
      for (int j = 0; j<NUM_COLS; j++) {
        buffer[i][j] = Math.random()<0.5;
      }
    }
    copyFromBufferToButtons();
  }
  else if (key == ENTER&&!running&&!nextFrame) //forward one frame when you hit enter (when notrunning)
    running = nextFrame =true;
  //change dimensions
  else if (keyCode==38&&!running&&!nextFrame) { //up key increases number of rows and cols
    NUM_COLS++;
    setup();
  } else if (keyCode==40&&NUM_COLS>5&&NUM_ROWS>1&&!running&&!nextFrame) { //down key decreases number of rows and cols (minimum 10x10)
    NUM_COLS--;
    setup();
  }
  
  //framerate change
  else if (keyCode==39) { //rightarrow=+1fps
    framerate++;
  } else if (keyCode==37&&framerate>1) { //downarrow=-1fps
    framerate--;
  }
else if(keyCode>=48&&keyCode<=57) { //"1-9" keys make shapes
    setup();
    switch(keyCode) {
      case 49:
        makeBlinker(floor(NUM_ROWS/2),floor(NUM_COLS/2));
        break;
      case 50:
        makeToad(floor(NUM_ROWS/2),floor(NUM_COLS/2));
        break;
      case 51:
        makeBeacon(floor(NUM_ROWS/2),floor(NUM_COLS/2));
        break;
      case 52:
        makePulsar(floor(NUM_ROWS/2),floor(NUM_COLS/2));
        break;
      case 53:
        makePentadecathlon(floor(NUM_ROWS/2),floor(NUM_COLS/2));
        break;
      case 54:
        makeGlider(1,1);
        break;
      case 55:
        makeLightWeightShip(floor(NUM_ROWS/2),1);
        break;
      case 56:
        makeMedWeightShip(floor(NUM_ROWS/2),1);
        break;
      case 57:
        makeHeavyWeightShip(floor(NUM_ROWS/2),1);
        break;
      case 48:
        makeGosperGun(1,1);
    }
    copyFromBufferToButtons();
  }
  //else if(keyCode == 80) printBuffer(1,1);
  if(running&&!nextFrame) frameRate(framerate);
}

/**
public void printBuffer(int r, int c) { //for finding what cells need to be true to make a shape. Not needed in the final program, but I'm keeping it here nonetheless.
  copyFromButtonsToBuffer();
  println("\n\n\n\n");
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if(buffer[i][j]) {
        print("buffer[r+"+(i-r)+"][c+"+(j-c)+"]=");
      }
    }
  }
}
**/
//data helper functions
public void copyFromBufferToButtons() {
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      buttons[i][j].setLife(buffer[i][j]);
    }
  }
}
public void copyFromButtonsToBuffer() {
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      buffer[i][j] = buttons[i][j].getLife();
    }
  }
}
public void copyToOldBuffer() {
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      oldBuffer[i][j] = buffer[i][j];
    }
  }
}

//Functions to check for stability
public boolean checkIfSame() {
  boolean output = true;
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if(oldBuffer[i][j] != buffer[i][j]){
        output = false;
        break;
      }
    }
  }
  return output;
}
public boolean checkIfDead() {
  boolean output = true;
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if(buffer[i][j]){
        output = false;
        break;
      }
    }
  }
  return output;
}

//helper functions
public boolean isValid(int r, int c) {
  boolean output = false;
  if (r<NUM_ROWS&&r>=0&&c<NUM_COLS&&c>=0) {
    output = true;
  }
  return output;
}
public int countNeighbors(int row, int col) {
  int neighbors = 0;
  for (int i = -1; i<=1; i++) {
    for (int j = -1; j<=1; j++) {
      if (isValid(row+i, col+j)&&buffer[row+i][col+j]) {
        if (i!=0||j!=0) {
          neighbors++;
        }
      }
    }
  }
  return neighbors;
}


//shapes:
//osclilators: start in the middle
public void makeBlinker(int r,int c) {  buffer[r][c]=buffer[r-1][c]=buffer[r+1][c]=true;  }
public void makeToad(int r,int c) {  buffer[r][c-1]=buffer[r][c]=buffer[r][c-2]=buffer[r-1][c-1]=buffer[r-1][c]=buffer[r-1][c+1]=true;  }
public void makeBeacon(int r,int c) {  buffer[r-1][c-1]=buffer[r-1][c-2]=buffer[r-2][c-1]=buffer[r-2][c-2]=buffer[r][c]=buffer[r][c+1]=buffer[r+1][c]=buffer[r+1][c+1]=true;  }
public void makePulsar(int r,int c) {  buffer[r-6][c-4]=buffer[r-6][c-3]=buffer[r-6][c-2]=buffer[r-6][c+2]=buffer[r-6][c+3]=buffer[r-6][c+4]=buffer[r-4][c-6]=buffer[r-4][c-1]=buffer[r-4][c+1]=buffer[r-4][c+6]=buffer[r-3][c-6]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-3][c+6]=buffer[r-2][c-6]=buffer[r-2][c-1]=buffer[r-2][c+1]=buffer[r-2][c+6]=buffer[r-1][c-4]=buffer[r-1][c-3]=buffer[r-1][c-2]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r+1][c-4]=buffer[r+1][c-3]=buffer[r+1][c-2]=buffer[r+1][c+2]=buffer[r+1][c+3]=buffer[r+1][c+4]=buffer[r+2][c-6]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+2][c+6]=buffer[r+3][c-6]=buffer[r+3][c-1]=buffer[r+3][c+1]=buffer[r+3][c+6]=buffer[r+4][c-6]=buffer[r+4][c-1]=buffer[r+4][c+1]=buffer[r+4][c+6]=buffer[r+6][c-4]=buffer[r+6][c-3]=buffer[r+6][c-2]=buffer[r+6][c+2]=buffer[r+6][c+3]=buffer[r+6][c+4]=true;  }
public void makePentadecathlon(int r, int c) {  buffer[r-5][c]=buffer[r-4][c]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-2][c]=buffer[r-1][c]=buffer[r][c]=buffer[r+1][c]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+3][c]=buffer[r+4][c]=true;  }
//spaceships: ideally star near the upper-left corner for the glider (measured from upper its own upper left corner) or center left (for the others, also measured relatively)
public void makeGlider(int r, int c) {  buffer[r][c]=buffer[r+1][c+1]=buffer[r+1][c+2]=buffer[r+2][c]=buffer[r+2][c+1]=true;  }
public void makeLightWeightShip(int r, int c) {  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r][c]=buffer[r][c+4]=buffer[r+1][c+4]=buffer[r+2][c]=buffer[r+2][c+3]=true;  }
public void makeMedWeightShip(int r, int c) {  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r-1][c+5]=buffer[r][c]=buffer[r][c+5]=buffer[r+1][c+5]=buffer[r+2][c]=buffer[r+2][c+4]=buffer[r+3][c+2]=true;  }
public void makeHeavyWeightShip(int r, int c) {  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r-1][c+5]=buffer[r-1][c+6]=buffer[r][c]=buffer[r][c+6]=buffer[r+1][c+6]=buffer[r+2][c]=buffer[r+2][c+5]=buffer[r+3][c+2]=buffer[r+3][c+3]=true;  }
public void makeGosperGun(int r, int c) {  buffer[r+0][c+24]=buffer[r+1][c+22]=buffer[r+1][c+24]=buffer[r+2][c+12]=buffer[r+2][c+13]=buffer[r+2][c+20]=buffer[r+2][c+21]=buffer[r+2][c+34]=buffer[r+2][c+35]=buffer[r+3][c+11]=buffer[r+3][c+15]=buffer[r+3][c+20]=buffer[r+3][c+21]=buffer[r+3][c+34]=buffer[r+3][c+35]=buffer[r+4][c+0]=buffer[r+4][c+1]=buffer[r+4][c+10]=buffer[r+4][c+16]=buffer[r+4][c+20]=buffer[r+4][c+21]=buffer[r+5][c+0]=buffer[r+5][c+1]=buffer[r+5][c+10]=buffer[r+5][c+14]=buffer[r+5][c+16]=buffer[r+5][c+17]=buffer[r+5][c+22]=buffer[r+5][c+24]=buffer[r+6][c+10]=buffer[r+6][c+16]=buffer[r+6][c+24]=buffer[r+7][c+11]=buffer[r+7][c+15]=buffer[r+8][c+12]=buffer[r+8][c+13]=true;  }
//see https://playgameoflife.com/lexicon for more possibilities


//Object class
public class Life {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean alive;
  public Life (int row, int col) {
    width = CELL_SIZE;
    height = CELL_SIZE;
    myRow = row;
    myCol = col;
    x = myCol*width;
    y = myRow*height;
    alive = false; //Math.random() < .5; // 50/50 chance cell will be alive
    Interactive.add( this ); // register it with the manager
  }
  // called by manager
  public void mousePressed () {
    alive = !alive; //turn cell on and off with mouse press
    isStable = isDead = false;
    genCount = 0;
  }
  public void show () {
    fill(alive ? 200 : 100);
    rect(x, y, width, height);
  }
  public boolean getLife() {
    return alive;
  }
  public void setLife(boolean living) {
    alive = living;
  }
}
