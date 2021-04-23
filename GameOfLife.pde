import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20 //
int NUM_ROWS; //will be decided by the program in setup()
int NUM_COLS=20;
float CELL_SIZE; //will be calculated in setup
private Life[][] buttons; //2d array of Life buttons each representing one cell
private boolean[][] buffer; //2d array of booleans to store state of buttons array
boolean[][] oldBuffer; //used to see if the state is stable
boolean[][] savedBuffer; //used to save the state of the game at last modification
boolean[][] customShape; //user-made shape
  int lowestR;
  int lowestC;
  int highestR;
  int highestC;
boolean running; //used to start and stop program
boolean nextFrame = false; //used to indicate whether we're just going forward 1 frame
int framerate = 7; //variable, not constant
int genCount; //dynamically tracks generations since modification
boolean isDead; //is everything on the board dead?
boolean isStable; //is nothing moving?
boolean justModified; //so the program knows when to save the buffer
boolean debug = false;
boolean override = false;
boolean previousState = false;



public void setup () {
  size((int)(0.9*window.innerWidth), (int)(0.9*window.innerHeight));
  frameRate(20);
  CELL_SIZE=(float)width/NUM_COLS;
  NUM_ROWS=(int)floor(height/CELL_SIZE);
  justModified = false;
  
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

  savedBuffer=new boolean[NUM_ROWS][NUM_COLS];
  copyToBuffer(savedBuffer);
  
  resetCounters();
  oldBuffer=new boolean[NUM_ROWS][NUM_COLS];
  copyToBuffer(oldBuffer);
}


public void draw () {
  background( 0 );
  if(running) {
    //isDead = isStable = true;        //assume it's dead and stable, then if proven it's not change to not dead or not stable
    
    copyFromBufferToButtons();
    genCount++;
    copyToBuffer(oldBuffer);
  }
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      if (running) {
        previousState=!!buttons[i][j].getLife(); //saves the state of the cells (to check for stability)
        buttons[i][j].setLife(countNeighbors(i, j)==3||(countNeighbors(i, j)==2&&buttons[i][j].getLife()));
        if(isDead&&buttons[i][j].getLife()) {isDead=false;}    //if any evidence is found that it's not dead, set isDead to false
        if(isStable&&Boolean.compare(previousState,buttons[i][j].getLife())!=0) {isStable=false;}    //if there's a changed cell, set isStable to false
      }
      buttons[i][j].show();
    }
  }
  copyFromButtonsToBuffer();
  
  /**if(running&&genCount>0&&!override) {
    if(isDead) {
      running = false;
      frameRate(20);
      if(genCount==1&&isStable) genCount--;
    } else if (isStable) {
      running = false;
      genCount--;
      frameRate(20);
    }
  }**/
  if(running&&genCount>0&&!override&&(isDead||isStable)) {
    running = false;
    frameRate(20);
    if(isStable) genCount--;
  }
  
  drawText();
  if (nextFrame) { //if we're just going one frame, stop the loop
    nextFrame = false;
    running = false;
  }
}
public void keyPressed() {
  frameRate(20);
  
  if (keyCode == 68) {
    debug = !debug;
  } //'d' to toggle debug
  else if(keyCode == 80) {//print stuff
    
  }
  
  
  if (keyCode == 32) {//spacebar to toggle running
    if(!running&&justModified) {
      savedBuffer=new boolean[NUM_ROWS][NUM_COLS];
      copyToBuffer(savedBuffer);
      justModified = false;
    }
    if((isDead||isStable)&&!running) {
      override = true;
    }
    running = !running;
  }
  else if ((keyCode == 220||keyCode == 8)&&!running) {//backslash to clear (when not running)- backspace in processing
    resetCounters();
    for (int i = 0; i<NUM_ROWS; i++) {
      for (int j = 0; j<NUM_COLS; j++) {
        buttons[i][j].setLife(false);
      }
    }
  }
  else if (keyCode==192&&!running) {//tilde to randomize (when not running)
    resetCounters();
    for (int i = 0; i<NUM_ROWS; i++) {
      for (int j = 0; j<NUM_COLS; j++) {
        buffer[i][j] = Math.random()<0.5;
      }
    }
    //copyFromBufferToButtons(); //not needed- does this every frame
  }
  else if (key == ENTER&&!running&&!nextFrame) {//forward one frame when you hit enter (when notrunning)
    if(justModified) {
      savedBuffer=new boolean[NUM_ROWS][NUM_COLS];
      copyToBuffer(savedBuffer);
      justModified = false;
    }
    running = nextFrame =true;
  }
  //change dimensions
  else if (keyCode==38&&!running&&!nextFrame) { //up key increases number of rows and cols
    NUM_COLS++;
    setup();
  } else if (keyCode==40&&NUM_COLS>5&&NUM_ROWS>5&&!running&&!nextFrame) { //down key decreases number of rows and cols (minimum 5x5)
    NUM_COLS--;
    setup();
  }
  
  //framerate change
  else if (keyCode==39) { //rightarrow=+1fps
    framerate++;
  } else if (keyCode==37&&framerate>1) { //downarrow=-1fps
    framerate--;
  }
  
  else if(keyCode == 82&&!running) { //if you hit r, reset to last saved
    resetCounters();
    //buffer = savedBuffer;
    for (int i = 0; i<NUM_ROWS; i++) {
      for (int j = 0; j<NUM_COLS; j++) {
        buffer[i][j] = savedBuffer[i][j];
      }
    }
    copyFromBufferToButtons();
  }
  else if(keyCode==67&&!running) {//copy
    copyShape(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
  }
  else if(keyCode==80&&!running) {//paste
    pasteShape(floor(mouseY/CELL_SIZE),floor(mouseX/CELL_SIZE));
    copyFromBufferToButtons();
  }
  else if(keyCode>=48&&keyCode<=57&&!running) { //"1-9" keys make shapes
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
  
  if(running&&!nextFrame) frameRate(framerate); //return to previous framerate
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
public void copyToBuffer(boolean copyTo[][]) { //used for oldbuffer and saved buffer, figured better to use one function than two
  for (int i = 0; i<NUM_ROWS; i++) {
    for (int j = 0; j<NUM_COLS; j++) {
      copyTo[i][j] = buffer[i][j];
    }
  }
}

public void resetCounters() {
  genCount = 0;
  isDead = isStable = running = override = false;
  justModified = true;
  frameRate(20);
}

//used to copy-paste user-generated shape
public void copyShape(int r, int c) {
  highestC=lowestC=c; //set the bounds to be the selected cell
  highestR=lowestR=r;
  for (int i = 0; i<NUM_ROWS; i++) { for (int j = 0; j<NUM_COLS; j++) { //find lowest and highest column and row values
    if(buffer[i][j]){
      if(j<=lowestC) lowestC=j;
      if(i<=lowestR) lowestR=i;
      if(j>=highestC) highestC=j;
      if(i>=highestR) highestR=i;
    }
  }}
  lowestC-=c;    //offset those values by the selected cell's position, making them relative coordinates
  highestC-=c;
  lowestR-=r;
  highestR-=r;

  customShape = new boolean[1+highestR-lowestR][1+highestC-lowestC];    //initialize the custom shape variable
  for (int i = 0; i<=highestR-lowestR; i++) { for (int j = 0; j<=highestC-lowestC; j++) { //cycle through the bounds of the customshape 
    if(buffer[i+r+lowestR][j+c+lowestC]) customShape[i][j] = new Boolean(true);  //if the on the screen is true, then make the position RELATIVE TO THE TOP LEFT of the shape array true as well
    else customShape[i][j] = new Boolean(false); //otherwise, make it false
  }}
}
public void pasteShape(int r, int c) {
  if(r+lowestR>=0&&c+lowestC>=0&&r+highestR<NUM_ROWS&&c+highestC<NUM_COLS) {//check that it's not out of bounds
    resetCounters();//reset counters (doing it here so that it doesnt reset them if it's not out of bouds
    for (int i = 0; i<=highestR-lowestR; i++) { for (int j = 0; j<=highestC-lowestC; j++) { //set buffer positions to true
      if(customShape[i][j]==true) buffer[i+r+lowestR][j+c+lowestC]=true;
      else {}
    }}
  }
}


public int countNeighbors(int row, int col) {
  int neighbors = 0;
  for (int i = -1; i<=1; i++) {
    for (int j = -1; j<=1; j++) {
      if (row+i<NUM_ROWS&&row+i>=0&&col+j<NUM_COLS&&col+j>=0&&buffer[row+i][col+j]) {
        if (i!=0||j!=0) {
          neighbors++;
        }
      }
    }
  }
  return neighbors;
}



public void drawText() {
  fill(255);
  textSize(floor(height/30));
  textAlign(CENTER,BOTTOM);
  text(framerate+(debug? " ("+round(frameRate)+") " : " ")+"fps",floor(width/2),floor(49*height/50));
  textAlign(RIGHT,BOTTOM);
  text(genCount, floor(49*width/50), floor(49*height/50));
  if(!running) {
    textAlign(CENTER,TOP);
    text("paused",floor(width/2),floor(height/50));
    textAlign(LEFT,BOTTOM);
    text(NUM_COLS+"x"+NUM_ROWS,floor(width/50),floor(49*height/50));
  }
  if((isStable||isDead)&&!override) {
    textAlign(CENTER,CENTER);
    text((isDead ? "dies at generation " : "fully stabilizes at generation ") +genCount+".\nTo continue, either press [r] to revert to generation 0, modify the grid, or unpause",floor(width/2),floor(height/2));
  }
}



//shapes:
//osclilators: start in the middle
public void makeBlinker(int r,int c) {  if(r-1>=0&&r+1<NUM_ROWS&&c-1>=0&&c+1<NUM_COLS){resetCounters();  buffer[r][c]=buffer[r-1][c]=buffer[r+1][c]=true;  }}
public void makeToad(int r,int c) {  if(r-2>=0&&r+1<NUM_ROWS&&c-2>=0&&c+1<NUM_COLS){resetCounters();  buffer[r][c-1]=buffer[r][c]=buffer[r][c-2]=buffer[r-1][c-1]=buffer[r-1][c]=buffer[r-1][c+1]=true;  }}
public void makeBeacon(int r,int c) {  if(r-2>=0&&r+1<NUM_ROWS&&c-2>=0&&c+1<NUM_COLS){resetCounters();  buffer[r-1][c-1]=buffer[r-1][c-2]=buffer[r-2][c-1]=buffer[r-2][c-2]=buffer[r][c]=buffer[r][c+1]=buffer[r+1][c]=buffer[r+1][c+1]=true;  }}
public void makePulsar(int r,int c) {  if(r-6>=0&&r+6<NUM_ROWS&&c-6>=0&&c+6<NUM_COLS){resetCounters();  buffer[r-6][c-4]=buffer[r-6][c-3]=buffer[r-6][c-2]=buffer[r-6][c+2]=buffer[r-6][c+3]=buffer[r-6][c+4]=buffer[r-4][c-6]=buffer[r-4][c-1]=buffer[r-4][c+1]=buffer[r-4][c+6]=buffer[r-3][c-6]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-3][c+6]=buffer[r-2][c-6]=buffer[r-2][c-1]=buffer[r-2][c+1]=buffer[r-2][c+6]=buffer[r-1][c-4]=buffer[r-1][c-3]=buffer[r-1][c-2]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r+1][c-4]=buffer[r+1][c-3]=buffer[r+1][c-2]=buffer[r+1][c+2]=buffer[r+1][c+3]=buffer[r+1][c+4]=buffer[r+2][c-6]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+2][c+6]=buffer[r+3][c-6]=buffer[r+3][c-1]=buffer[r+3][c+1]=buffer[r+3][c+6]=buffer[r+4][c-6]=buffer[r+4][c-1]=buffer[r+4][c+1]=buffer[r+4][c+6]=buffer[r+6][c-4]=buffer[r+6][c-3]=buffer[r+6][c-2]=buffer[r+6][c+2]=buffer[r+6][c+3]=buffer[r+6][c+4]=true;  }}
public void makePentadecathlon(int r, int c) {  if(r-8>=0&&r+7<NUM_ROWS&&c-4>=0&&c+4<NUM_COLS){resetCounters();  buffer[r-5][c]=buffer[r-4][c]=buffer[r-3][c-1]=buffer[r-3][c+1]=buffer[r-2][c]=buffer[r-1][c]=buffer[r][c]=buffer[r+1][c]=buffer[r+2][c-1]=buffer[r+2][c+1]=buffer[r+3][c]=buffer[r+4][c]=true;  }}
public void makeP16(int r, int c) {  if(r-7>=0&&r+7<NUM_ROWS&&c-7>=0&&c+7<NUM_COLS){resetCounters();  buffer[r+-6][c+1]=buffer[r+-6][c+2]=buffer[r+-5][c+1]=buffer[r+-5][c+3]=buffer[r+-4][c+-4]=buffer[r+-4][c+1]=buffer[r+-4][c+3]=buffer[r+-4][c+4]=buffer[r+-3][c+-5]=buffer[r+-3][c+-4]=buffer[r+-3][c+2]=buffer[r+-2][c+-6]=buffer[r+-2][c+-3]=buffer[r+-1][c+-6]=buffer[r+-1][c+-5]=buffer[r+-1][c+-4]=buffer[r+1][c+4]=buffer[r+1][c+5]=buffer[r+1][c+6]=buffer[r+2][c+3]=buffer[r+2][c+6]=buffer[r+3][c+-2]=buffer[r+3][c+4]=buffer[r+3][c+5]=buffer[r+4][c+-4]=buffer[r+4][c+-3]=buffer[r+4][c+-1]=buffer[r+4][c+4]=buffer[r+5][c+-3]=buffer[r+5][c+-1]=buffer[r+6][c+-2]=buffer[r+6][c+-1]=true;  }}
//spaceships: ideally star near the upper-left corner for the glider (measured from upper its own upper left corner) or center left (for the others, also measured relatively)
public void makeGlider(int r, int c) {  if(r>=0&&r+2<NUM_ROWS&&c>=0&&c+2<NUM_COLS){resetCounters();  buffer[r][c]=buffer[r+1][c+1]=buffer[r+1][c+2]=buffer[r+2][c]=buffer[r+2][c+1]=true;  }}
public void makeLightWeightShip(int r, int c) {  if(r-2>=0&&r+2<NUM_ROWS&&c>=0&&c+6<NUM_COLS){resetCounters();  buffer[r-1][c+1]=buffer[r-1][c+2]=buffer[r-1][c+3]=buffer[r-1][c+4]=buffer[r][c]=buffer[r][c+4]=buffer[r+1][c+4]=buffer[r+2][c]=buffer[r+2][c+3]=true;  }}
//chaos
public void makeGliderMess(int r, int c) {  if(r-3>=0&&r+2<NUM_ROWS&&c-6>=0&&c+5<NUM_COLS){resetCounters();  buffer[r+-3][c+-4]=buffer[r+-2][c+-6]=buffer[r+-2][c+-4]=buffer[r+-1][c+-5]=buffer[r+-1][c+-4]=buffer[r+0][c+5]=buffer[r+1][c+3]=buffer[r+1][c+4]=buffer[r+2][c+4]=buffer[r+2][c+5]=true;  }}
//gosper gun: make it bigger
public void makeGosperGun(int r, int c) {  if(r-4>=0&&r+4<NUM_ROWS&&c-17>=0&&c+18<NUM_COLS){resetCounters();  buffer[r+-4][c+7]=buffer[r+-3][c+5]=buffer[r+-3][c+7]=buffer[r+-2][c+-5]=buffer[r+-2][c+-4]=buffer[r+-2][c+3]=buffer[r+-2][c+4]=buffer[r+-2][c+17]=buffer[r+-2][c+18]=buffer[r+-1][c+-6]=buffer[r+-1][c+-2]=buffer[r+-1][c+3]=buffer[r+-1][c+4]=buffer[r+-1][c+17]=buffer[r+-1][c+18]=buffer[r+0][c+-17]=buffer[r+0][c+-16]=buffer[r+0][c+-7]=buffer[r+0][c+-1]=buffer[r+0][c+3]=buffer[r+0][c+4]=buffer[r+1][c+-17]=buffer[r+1][c+-16]=buffer[r+1][c+-7]=buffer[r+1][c+-3]=buffer[r+1][c+-1]=buffer[r+1][c+0]=buffer[r+1][c+5]=buffer[r+1][c+7]=buffer[r+2][c+-7]=buffer[r+2][c+-1]=buffer[r+2][c+7]=buffer[r+3][c+-6]=buffer[r+3][c+-2]=buffer[r+4][c+-5]=buffer[r+4][c+-4]=true;  }}
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
    resetCounters();
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
