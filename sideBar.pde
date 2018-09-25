// Classes
public class CircularLL {
  int size;
  Task start;
  void insertTask(Task t) {
    if (start != null) {
      t.next = start.next;
      start.next = t;
      t.prev = start;
      t.next.prev = t;
    }
    else {
      start = t;
      t.next = t;
      t.prev = t;
    }
    size++;
  }
  int removeTask(int n) { // remove nth task from start
    size--;
    if (start != start.next) {
      Task cur = start;
      for (int i = 0; i < n; i++, cur = cur.prev) {}
      cur.next.prev = cur.prev;
      cur.prev.next = cur.next;
      if (n == 0) start = cur.prev;
      cur = null;
      return 1;
    }
    start = null;
    return 0;
  }
}

public class Task {
  int ID;
  String content;
  Task next;
  Task prev;
  Task() {
    ID = (int)random(10000);
    this.content = "Here is the content for\n" + this.ID;
  }
  Task(int n) {
    ID = n;
    this.content = "Here is the content for\n" + this.ID;
  }
}

// Setups
CircularLL taskList = new CircularLL();
int maxBlocks = 10;
Task[] taskBlocks = new Task[maxBlocks];
int nBlocks = 0;
int zoomInd = -1; // Block index which is zoomed.
int taskInit = 10;
int taskCounter = 0;

// Apperance
float zoomSpan = 0; // Space a zoomed block takes.
int scrollSpeed = 5;
int rBlock = 7; // Round angles
int defaultTextSize = 12;
int addButtonStroke = 4;
int backgroundColor = #000000;
int blockColor = #ffffff;
int labelColor = #f0e7e7;
int addButtonColor = #80d680;
int addButtonHighlight = #c5ecc5;
int deleteButtonColor = #ff3300;
int blockTextColor = #d68080;

// Size ratios:
float reserved = 0.1; // For add button
float B2W = 3/4.0; // Block to Width
float M2W = 1/8.0; // Margin to Width
float F2BH = 1/6.0; // Frame to Block Height
float S2BH = 1-2*F2BH; // Space to Block Height
float F2BHr = 1/12.0; // Frame to Block Height (reduced)
float S2BHi = 1-2*F2BHr; // Space to Block Height (increased)
float D2W = 1/12.0; // Delete Button to Width
///////////////////////////////////////////////////////////////////
void setup() {
  background(backgroundColor);
  size(200,1000);
  textAlign(CENTER,CENTER);
  noStroke();
  for (; taskCounter<taskInit; taskCounter++) {
    Task t = new Task(taskCounter);
    taskList.insertTask(t);
  }
}

void draw() {
  nBlocks = min(maxBlocks, taskList.size);
  zoomSpan = max(1,nBlocks/2.0);
  Task cur = taskList.start;
  if (zoomInd==-1) zoomInd = (mouseX>M2W*width && mouseX<(1-M2W)*width && mouseY>height*reserved)? nBlocks*mouseY/height : -1;
  else zoomInd = (mouseX>M2W*width && mouseX<(1-M2W)*width && mouseY>height*reserved)? findZoomInd() : -1;
  //println(zoomInd);
  for (int i = 0; i < nBlocks; i++) {
    taskBlocks[i] = cur;
    cur = cur.prev;
  }
  drawList();
  //println(nBlocks*mouseY/height,mouseX,zoomInd);
}

void mouseClicked() {
  float incHeight = zoomSpan*height*(1-reserved)/nBlocks;
  float decHeight = (nBlocks>1)? (height*(1-reserved)-incHeight)/(nBlocks-1) : 0;
  if (addButtonHover()) {
    Task t = new Task(taskCounter++);
    taskList.insertTask(t);
    taskList.start = t;
  }
  else if (zoomInd>=0 && mouseX>M2W*width && mouseX<M2W*width+F2BHr*width &&
           mouseY>height*reserved+zoomInd*decHeight+F2BHr*incHeight && 
           mouseY<height*reserved+zoomInd*decHeight+F2BHr*incHeight+F2BHr*width) {
    taskList.removeTask(zoomInd);
  }
}
void mouseDragged() {
  if (pmouseX<M2W*width || pmouseX>(1-M2W)*width) {
    if (mouseY > pmouseY) scrollDown(scrollSpeed*nBlocks*(mouseY - pmouseY)/height);
    else if (mouseY < pmouseY) scrollUp(scrollSpeed*nBlocks*(pmouseY - mouseY)/height);
  }
  else if (pmouseY>height*reserved){//if (pmouseX>=width/8 && pmouseX<=7*width/8 && pmouseY> && pmouseY< ) {
    moveBlock(zoomInd, findZoomInd());
  }
}

int findZoomInd() { // Find which block is zoomed
  float incHeight = zoomSpan*height*(1-reserved)/nBlocks;
  float decHeight = (height*(1-reserved)-incHeight)/(nBlocks-1);
  float lower = height*reserved+zoomInd*decHeight;
  float upper = height*reserved+zoomInd*decHeight+incHeight;
  if (mouseY >= lower && mouseY <= upper) return zoomInd;
  else if (mouseY > upper) return min(nBlocks-1,zoomInd+1);
  else return max(0,zoomInd-1);
}

void drawList() {
  background(backgroundColor);
  if (!addButtonHover()) {
    fill(addButtonColor);
  }
  else {
    fill(addButtonHighlight);
  }
  noStroke();
  rect(M2W*width, height*reserved/6, B2W*width, S2BH*height*reserved,rBlock);
  stroke(blockColor);
  strokeWeight(addButtonStroke);
  line(width/2, height*reserved/5, width/2, 4*height*reserved/5);
  line(width/6, height*reserved/2, 5*width/6, height*reserved/2);
  if (zoomInd < 0) {
    float blockHeight = (1-reserved)*height/nBlocks;
    for (int i = 0; i < nBlocks; i++) { 
      fill(blockColor);
      rect(M2W*width, height*reserved+i*blockHeight+F2BH*blockHeight, B2W*width, S2BH*blockHeight,rBlock);
      textSize(defaultTextSize);
      fill(blockTextColor);
      text("TASK "+taskBlocks[i].ID, M2W*width, height*reserved+i*blockHeight+F2BH*blockHeight, B2W*width, S2BH*blockHeight);
    }
  }
  else {
    float incHeight = zoomSpan*height*(1-reserved)/nBlocks;
    float decHeight = (nBlocks>1)? (height*(1-reserved)-incHeight)/(nBlocks-1) : 0;
    for (int i = 0; i < zoomInd; i++) { 
    // Blocks above the zoomed
      fill(blockColor);
      rect(M2W*width, height*reserved+i*decHeight+F2BH*decHeight, B2W*width, S2BH*decHeight,rBlock);
      textSize(defaultTextSize/2);
      fill(blockTextColor);
      text("TASK "+taskBlocks[i].ID, M2W*width, height*reserved+i*decHeight+F2BH*decHeight, B2W*width, S2BH*decHeight);
    }
    // Zoomed Block
    fill(blockColor);
    rect(M2W*width, height*reserved+zoomInd*decHeight+F2BHr*incHeight, B2W*width, S2BHi*incHeight,rBlock); 
    // Label 
    fill(labelColor);
    noStroke();
    rect(M2W*width, height*reserved+zoomInd*decHeight+F2BHr*incHeight, B2W*width, 2*D2W*width,rBlock); 
    textSize(defaultTextSize);
    fill(blockTextColor);
    text(taskBlocks[zoomInd].ID+"", M2W*width, height*reserved+zoomInd*decHeight+F2BHr*incHeight, B2W*width, 2*D2W*width);
    // Delete Button
    fill(deleteButtonColor);
    rect(M2W*width, height*reserved+zoomInd*decHeight+F2BHr*incHeight, D2W*width, D2W*width,rBlock); 
    // Text Content
    text(taskBlocks[zoomInd].content, M2W*width, height*reserved+zoomInd*decHeight+F2BHr*incHeight, B2W*width, S2BHi*incHeight);
    for (int i = zoomInd+1; i < nBlocks; i++) { 
      // Blocks below the zoomed
      fill(255);
      rect(M2W*width, height*reserved+(i-1)*decHeight+incHeight+F2BH*decHeight, B2W*width, S2BH*decHeight,rBlock);
      textSize(defaultTextSize/2);
      fill(blockTextColor);
      text("TASK "+taskBlocks[i].ID, M2W*width, height*reserved+(i-1)*decHeight+incHeight+F2BH*decHeight, B2W*width, S2BH*decHeight);
    }
  }
}

void scrollDown(int n) {
  while (n > 0) {
    taskList.start = taskList.start.next;
    n--;
  }
}

void scrollUp(int n) {
  while (n > 0) {
    taskList.start = taskList.start.prev;
    n--;
  }
}

void moveBlock(int org, int dest) {
  if (org != dest && org>-1 && dest>-1 && dest<nBlocks) {
    println(org, dest);
    /*if (dest < 0) {
      taskList.start = taskList.start.next;
      org++;
      dest++;
    }
    if (dest >= nBlocks) {
      taskList.start = taskList.start.prev;
      org--;
      dest--;
    }*/
    Task ts = taskBlocks[org], td = taskBlocks[dest];
    println(ts.ID, td.ID);
    ts.prev.next = ts.next;
    ts.next.prev = ts.prev;
    if (org < dest) {
      if (org == 0) taskList.start = ts.prev;
      ts.next = td;
      ts.prev = td.prev;
      td.prev.next = ts;
      td.prev = ts;
    }
    else {
      if (dest == 0) taskList.start = ts;
      ts.next = td.next;
      ts.prev = td;
      td.next.prev = ts;
      td.next = ts;
    }
    //println(ts.next.ID,ts.prev.ID,td.next.ID,td.prev.ID);
    //for (Task t = taskList.start; t.prev != taskList.start; t= t.prev) print(t.ID);
    //println("");
  }
}

boolean addButtonHover() {
  return pmouseX>=M2W*width && pmouseX<=(1-M2W)*width && pmouseY>=F2BH*height*reserved && pmouseY<=(1-F2BH)*height*reserved;
}
