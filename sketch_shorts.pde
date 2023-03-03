import processing.video.Movie;
import java.util.ArrayList;
import java.io.*;
import javax.sound.sampled.*;
import java.util.Locale;

Movie shortMovie;
PImage logoImage;
int currentRowIndex = 0;
int frame = 0;
TableRow currentRow;
boolean displaySecondText = false;
boolean displayImage = false;
boolean finish = false;
long startTime = 0;
Table data;
ArrayList<PImage> frames = new ArrayList<PImage>();

void setup() {
  size(720, 1280);
  frameRate(30);

  // Load the first video and image, and the CSV data
  data = loadTable("data.tsv", "tsv");
  
  createMovieForCurrentRow();
}

void createMovieForCurrentRow() {
  println("Creating video " + (currentRowIndex+1));
  currentRow = data.getRow(currentRowIndex);

  frame = 0;
  displaySecondText = false;
  displayImage = false;
  finish = false;

  //Logo
  logoImage = loadImage(currentRow.getString(4));

  //Background
  shortMovie = new Movie(this, "D:\\Processing\\sketch_shorts\\"+currentRow.getString(3));
  shortMovie.loop();
  startTime = millis();
}

void draw() {
  background(0);
  imageMode(CORNERS);
  image(shortMovie, 0, 0, width, height);
  fill(0);
  rect(0, 0, 720, 60);
  // If the first text has been displayed for at least 4 seconds, start displaying the second text
  long duration = millis() - startTime;
  //println(duration);
  displaySecondText = duration >= 3000;//frame > (3 * 30);
  displayImage = duration >= 6000;
  finish = duration >= 8000;
  // Display the image at the end of the video
  if (displayImage) {
    //println("Logo");
        
    fill(0, 127);
    noStroke();
    rect(20, height/4, 680, 800, 12, 12, 12, 12);
    
    fill(255);
    text("BookQuotesEveryday", 120, 350, 485, 245);
    imageMode(CENTER);
    image(logoImage, width/2, height/2, 100, 100);
    textAlign(CENTER, CENTER);
    text("Subscribe\nLike\nComment a book quote\nand be featured in the future\n:)", 20, 40+(height/2), 680, height/4);
    
  } else {
    fill(0, 127);
    noStroke();
    rect(20, 100, 680, 400, 12, 12, 12, 12);

    // Display the quote text
    String quoteText = "\""+currentRow.getString(1)+"\"";
    textSize(48);
    fill(255);
    //tint(255, 127);  // Display at half opacity
    textAlign(CENTER,CENTER);
    text(quoteText, 20, 100, 680, 400);
    
    if (displaySecondText) {
      //println("Second");
      String referenceText = currentRow.getString(2);
  
      fill(0, 127);
      noStroke();
      rect(20, 560, 680, 160, 12, 12, 12, 12);
  
      textSize(32);
      fill(255);
      textAlign(CENTER, CENTER);
      text(referenceText, 20, 560, 680, 160);
    }
  }


  // If the video has ended and the second text and image have been displayed, save the resulting video and move on to the next one
  String item = currentRow.getString(0);

  frame++;
  PImage iFrame = get();
  frames.add(iFrame);
  
  if (finish) {
    deleteFiles("D:\\Processing\\sketch_shorts\\output");
        
    println("Saving frames ... ");
    for (int i = 0; i < frames.size(); i++) {
      PImage img = frames.get(i); 
      img.save("output\\" + item + "_" + i + "_output.png");      
    }
    println("Frames saved");
    frames = new ArrayList<PImage>();
    String outputName = item + "_output.mp4";
    deleteFile("D:\\Processing\\sketch_shorts\\output\\"+outputName);
    println("Saving video "+outputName);
    saveVideo(outputName, item + "_%d_output.png");
    println("Video saved");
    println("Garbage collection running ...");
    System.gc();
    println("Garbage collection ended");
    currentRowIndex++;

    // If there are no more videos to process, exit the application
    if (currentRowIndex == data.getRowCount()) {
      exit();
    }else{      
      // Load the next video and image, and reset the display variables
      createMovieForCurrentRow();
    }

  }
}

void deleteFiles(String path){
  File dir = new File(path);
  if(dir.exists()){
    for(File file: dir.listFiles()) {
      if (!file.isDirectory()) {
        file.delete();
      }
    }
  }
}
void deleteFile(String path){
  File file = new File(path);
  if(file.exists()){
    file.delete();
  }
}

void printProcess(Process process){
  try {
    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
    String line;
    while ((line = reader.readLine()) != null) {
      println(line);
    }
  }catch (Exception e) {
    e.printStackTrace();
  }
}

void saveVideo(String filename, String png) {
  String[] commands = {"ffmpeg", "-y", "-f", "image2", "-framerate", "30", "-i", png, "-vcodec", "libx264", "-crf", "25", "-pix_fmt", "yuv420p", "D:\\Processing\\sketch_shorts\\output\\video\\"+filename};
  try {
    ProcessBuilder pb = new ProcessBuilder(commands);
    pb.directory(new File("D:\\Processing\\sketch_shorts\\output"));
    Process process = pb.start();
    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
    String line;
    while ((line = reader.readLine()) != null) {
      println(line);
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void movieEvent(Movie m) {
  m.read();
}
