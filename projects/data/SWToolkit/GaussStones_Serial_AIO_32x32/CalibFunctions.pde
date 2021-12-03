void saveCalibFile(String fileName, float[][] initSensorVal) {
  int[] sensorRaw = new int[totalR*totalC];
  String[] calibFile = new String[sensorRaw.length];
  for(int r = 0 ; r < totalR ; r++){
    for(int c = 0 ; c < totalC ; c++){
      sensorRaw[c+r*totalC] = int(initSensorVal[r][c]);
    }
  }
  for (int i = 0 ; i < calibFile.length ; i++) {
    int v = sensorRaw[i];
    String str = ""+v;
    calibFile[i] = str;
  }
  saveStrings(fileName, calibFile);
  println("Save Calibration Profile");
}

float[][] loadCalibFile(String fileName){
  println("Load Calibration Profile");
  float[][] initSensorVal = new float[totalR][totalC];
  String[] calibFile = loadStrings(fileName);
  for (int i = 0 ; i < calibFile.length ; i++) {
    int r = (int) i / totalC;
    int c = (int) i % totalC;
    initSensorVal[r][c] = float(int(calibFile[i]));
  }
  return initSensorVal;
}
