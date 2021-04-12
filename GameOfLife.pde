import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20 //
int NUM_ROWS;
int NUM_COLS=20;
float CELL_SIZE;
private Life[][] buttons; //2d array of Life buttons each representing one cell
private boolean[][] buffer; //2d array of booleans to store state of buttons array
private boolean[][] oldBuffer;
private boolean[][] savedBuffer;
private boolean running; //used to start and stop program
public boolean nextFrame = false;
public int framerate = 6;
public int genCount;
public boolean isDead;
public boolean isStable;
public boolean firstRun = true; //so the program knows when to reset the saved buffer
public boolean justModified = false; //so the program knows when to save the buffer



public void setup () {
  size((int)(0.95*window.innerWidth), (int)(0.95*window.innerHeight));
  frameRate(framerate);
  CELL_SIZE=(float)width/NUM_COLS;
  NUM_ROWS=(int)floor(height/CELL_SIZE);
  
  
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
  
  if(firstRun) {
    savedBuffer=new boolean[NUM_ROWS][NUM_COLS];
    copyToBuffer(savedBuffer);
    firstRun = false;
  }
  
  genCount = 0;
  isDead = isStable = running = false;
  oldBuffer=new boolean[NUM_ROWS][NUM_COLS];
  copyToBuffer(oldBuffer);
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
  copyToBuffer(oldBuffer);
  
  
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
    if(isStable) text("fully stable at generation "+genCount+" and onwards.\nModify the grid or press [r] to reset it to continue",floor(width/2),floor(height/2));
    if(isDead) text("dies at generation "+genCount+".\nModify the grid or press [r] to reset it to continue",floor(width/2),floor(height/2));
  }
  
  if (nextFrame) {
    nextFrame = false;
    running = false;
  }
}
public void keyPressed() {
  frameRate(20);                                                                                          //simulation controls
  if (keyCode == 32) {//spacebar to toggle running
    if(!running&&justModified) {
      copyToBuffer(savedBuffer);
    }
    running = !running;
  }
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
    firstRun = true;
    setup();
  } else if (keyCode==40&&NUM_COLS>5&&NUM_ROWS>5&&!running&&!nextFrame) { //down key decreases number of rows and cols (minimum 10x10)
    NUM_COLS--;
    firstRun = true;
    setup();
  }
  
  //framerate change
  else if (keyCode==39) { //rightarrow=+1fps
    framerate++;
  } else if (keyCode==37&&framerate>1) { //downarrow=-1fps
    framerate--;
  }
else if(keyCode>=48&&keyCode<=57&&!running) { //"1-9" keys make shapes
    reset();
    switch(keyCode) {
      case 49:
        makeBlinker(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 50:
        makeToad(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 51:
        makeBeacon(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 52:
        makePulsar(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 53:
        makePentadecathlon(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 54:
        makeP16(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 55:
        makeGlider(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 56:
        makeLightWeightShip(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 57:
        makeGliderMess(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
      case 48:
        makeGosperGun(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
        break;
    }
    copyFromBufferToButtons();
  }
  
  else if(keyCode == 82&&!running) { //if you hit r, reset to last saved
    buffer = savedBuffer;
    reset();
    copyFromBufferToButtons();
  }
  
  if(running&&!nextFrame) frameRate(framerate);
}

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
public void copyToBuffer(boolean copyTo[][]) {
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      copyTo[i][j] = buffer[i][j];
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
public void reset() {
  genCount = 0;
  isDead = isStable = running = false;
  justModified = true;
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
public void makeBlinker(int r,int c) {  if(r-1>=0&&r+1<NUM_ROWS&&c-1>=0&&c+1<NUM_COLS) buffer[r][c]=buffer[r-1][c]=buffer[r+1][c]=true;  }
public void makeToad(int r,int c) {  if(r-2>=0&&r+1<NUM_ROWS&&c-2>=0&&c+1<NUM_COLS) buffer[r][c-1]=buffer[r][c]=buffer[r][c-2]=buffer[r-1][c-1]=buffer[r-1][c]=buffer[r-1][c+1]=true;  }
public void makeBeacon(int r,int c) {  if(r-2>=0&&r+1<NUM_ROWS&&c-2>=0&&c+1<NUM_COLS) buffer[r-1][c-1]=buffer[r-1][c-2]=buffer[r-2][c-1]=buffer[r-2][c-2]=buffer[r][c]=buffer[r][c+1]=buffer[r+1][c]=buffer[r+1][c+1]=true;  }
public void makePulsar(int r,int c) {  if(r-6>=0&&r+6<NUM_ROWS&&c-6>=0&&c+6<NUM_COLS) buffer[r-6][c-4]=buffer[r-6][c-3]=buffer[r-6][c-2]=buffer[r-6][c+2]=buffer[r-6][c+3]=buffer[r-6][c+4]=buffer[r-4][c-6]=buffer[r-4][c-1]=buffer[r-4][c+1]=buffer[r-4][c+6]=buffer[r-3][c-6]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-3][c+6]=buffer[r-2][c-6]=buffer[r-2][c-1]=buffer[r-2][c+1]=buffer[r-2][c+6]=buffer[r-1][c-4]=buffer[r-1][c-3]=buffer[r-1][c-2]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r+1][c-4]=buffer[r+1][c-3]=buffer[r+1][c-2]=buffer[r+1][c+2]=buffer[r+1][c+3]=buffer[r+1][c+4]=buffer[r+2][c-6]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+2][c+6]=buffer[r+3][c-6]=buffer[r+3][c-1]=buffer[r+3][c+1]=buffer[r+3][c+6]=buffer[r+4][c-6]=buffer[r+4][c-1]=buffer[r+4][c+1]=buffer[r+4][c+6]=buffer[r+6][c-4]=buffer[r+6][c-3]=buffer[r+6][c-2]=buffer[r+6][c+2]=buffer[r+6][c+3]=buffer[r+6][c+4]=true;  }
public void makePentadecathlon(int r, int c) {  if(r-8>=0&&r+7<NUM_ROWS&&c-4>=0&&c+4<NUM_COLS) buffer[r-5][c]=buffer[r-4][c]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-2][c]=buffer[r-1][c]=buffer[r][c]=buffer[r+1][c]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+3][c]=buffer[r+4][c]=true;  }
public void makeP16(int r, int c) {  if(r-7>=0&&r+7<NUM_ROWS&&c-7>=0&&c+7<NUM_COLS) buffer[r+-6][c+1]=buffer[r+-6][c+2]=buffer[r+-5][c+1]=buffer[r+-5][c+3]=buffer[r+-4][c+-4]=buffer[r+-4][c+1]=buffer[r+-4][c+3]=buffer[r+-4][c+4]=buffer[r+-3][c+-5]=buffer[r+-3][c+-4]=buffer[r+-3][c+2]=buffer[r+-2][c+-6]=buffer[r+-2][c+-3]=buffer[r+-1][c+-6]=buffer[r+-1][c+-5]=buffer[r+-1][c+-4]=buffer[r+1][c+4]=buffer[r+1][c+5]=buffer[r+1][c+6]=buffer[r+2][c+3]=buffer[r+2][c+6]=buffer[r+3][c+-2]=buffer[r+3][c+4]=buffer[r+3][c+5]=buffer[r+4][c+-4]=buffer[r+4][c+-3]=buffer[r+4][c+-1]=buffer[r+4][c+4]=buffer[r+5][c+-3]=buffer[r+5][c+-1]=buffer[r+6][c+-2]=buffer[r+6][c+-1]=true;  }
//spaceships: ideally star near the upper-left corner for the glider (measured from upper its own upper left corner) or center left (for the others, also measured relatively)
public void makeGlider(int r, int c) {  if(r>=0&&r+2<NUM_ROWS&&c>=0&&c+2<NUM_COLS) buffer[r][c]=buffer[r+1][c+1]=buffer[r+1][c+2]=buffer[r+2][c]=buffer[r+2][c+1]=true;  }
public void makeLightWeightShip(int r, int c) {  if(r-2>=0&&r+2<NUM_ROWS&&c>=0&&c+6<NUM_COLS) buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r][c]=buffer[r][c+4]=buffer[r+1][c+4]=buffer[r+2][c]=buffer[r+2][c+3]=true;  }
//chaos
public void makeGliderMess(int r, int c) {  if(r-3>=0&&r+2<NUM_ROWS&&c-6>=0&&c+5<NUM_COLS) buffer[r+-3][c+-4]=buffer[r+-2][c+-6]=buffer[r+-2][c+-4]=buffer[r+-1][c+-5]=buffer[r+-1][c+-4]=buffer[r+0][c+5]=buffer[r+1][c+3]=buffer[r+1][c+4]=buffer[r+2][c+4]=buffer[r+2][c+5]=true;  }
//gosper gun: make it bigger
public void makeGosperGun(int r, int c) {  if(r-4>=0&&r+4<NUM_ROWS&&c-17>=0&&c+18<NUM_COLS) buffer[r+-4][c+7]=buffer[r+-3][c+5]=buffer[r+-3][c+7]=buffer[r+-2][c+-5]=buffer[r+-2][c+-4]=buffer[r+-2][c+3]=buffer[r+-2][c+4]=buffer[r+-2][c+17]=buffer[r+-2][c+18]=buffer[r+-1][c+-6]=buffer[r+-1][c+-2]=buffer[r+-1][c+3]=buffer[r+-1][c+4]=buffer[r+-1][c+17]=buffer[r+-1][c+18]=buffer[r+0][c+-17]=buffer[r+0][c+-16]=buffer[r+0][c+-7]=buffer[r+0][c+-1]=buffer[r+0][c+3]=buffer[r+0][c+4]=buffer[r+1][c+-17]=buffer[r+1][c+-16]=buffer[r+1][c+-7]=buffer[r+1][c+-3]=buffer[r+1][c+-1]=buffer[r+1][c+0]=buffer[r+1][c+5]=buffer[r+1][c+7]=buffer[r+2][c+-7]=buffer[r+2][c+-1]=buffer[r+2][c+7]=buffer[r+3][c+-6]=buffer[r+3][c+-2]=buffer[r+4][c+-5]=buffer[r+4][c+-4]=true;  }
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
    alive = false;
    Interactive.add( this ); // register it with the manager
  }
  // called by manager
  public void mousePressed () {
    alive = !alive; //turn cell on and off with mouse press
    reset();
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



//NOT USED
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
public void makeMedWeightShip(int r, int c) {  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r-1][c+5]=buffer[r][c]=buffer[r][c+5]=buffer[r+1][c+5]=buffer[r+2][c]=buffer[r+2][c+4]=buffer[r+3][c+2]=true;  }
public void makeHeavyWeightShip(int r, int c) {  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r-1][c+5]=buffer[r-1][c+6]=buffer[r][c]=buffer[r][c+6]=buffer[r+1][c+6]=buffer[r+2][c]=buffer[r+2][c+5]=buffer[r+3][c+2]=buffer[r+3][c+3]=true;  }
**/
