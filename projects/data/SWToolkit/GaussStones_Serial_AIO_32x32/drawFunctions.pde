void recordSampleData(boolean isBoundary, int i, int j) {
  float sampleX, sampleY, sampleM;
  int w, h;
  for (int x=0; x<sampleRes; x++) {
    for (int y=0; y<sampleRes; y++) {
      sampleX = (float)x / (float)sampleRes;
      sampleY = (float)y / (float)sampleRes;
      w = i*sampleRes + x;
      h = j*sampleRes + y;
      if (isBoundary) {
        sampleM = blp.getValue(sampleX, sampleY);
      }
      else {
        sampleM = bcp.getValue(sampleX, sampleY);
      }
      sampleMVal[w][h] = sampleM;
    }
  }
}

void upSampling() {
  float[][] pBC = new float[4][4];
  float[][] pBL = new float[2][2];
  //BiLinear Interpolate the left and right edge
  for (int i=0;i<totalR;i+=totalR-2) {
    for (int j=1;j<totalC-2;j++) {
      pBL[0][0] = hallSensorVal[i  ][j];  
      pBL[0][1] = hallSensorVal[i  ][j+1];
      pBL[1][0] = hallSensorVal[i+1][j];  
      pBL[1][1] = hallSensorVal[i+1][j+1];   
      blp.updateCoefficients(pBL);
      recordSampleData(true, i, j); //true: isBoundary
    }
  }
  //BiLinear Interpolate the top and bottom edge
  for (int i=0;i<totalR-1;i++) {
    for (int j=0;j<totalC;j+=totalC-2) {
      pBL[0][0] = hallSensorVal[i  ][j];  
      pBL[0][1] = hallSensorVal[i  ][j+1];   
      pBL[1][0] = hallSensorVal[i+1][j];  
      pBL[1][1] = hallSensorVal[i+1][j+1]; 
      blp.updateCoefficients(pBL);
      recordSampleData(true, i, j); //true: isBoundary
    }
  }
  //Bicubic Interpolate other points
  for (int i=1;i<totalR-2;i++) {
    for (int j=1;j<totalC-2;j++) {
      pBC[0][0] = hallSensorVal[(i-1)][j-1];  
      pBC[0][1] = hallSensorVal[(i-1)][j];  
      pBC[0][2] = hallSensorVal[(i-1)][j+1];  
      pBC[0][3] = hallSensorVal[(i-1)][j+2];
      pBC[1][0] = hallSensorVal[(i)  ][j-1];  
      pBC[1][1] = hallSensorVal[(i)  ][j];  
      pBC[1][2] = hallSensorVal[(i)  ][j+1];  
      pBC[1][3] = hallSensorVal[(i)  ][j+2];
      pBC[2][0] = hallSensorVal[(i+1)][j-1];  
      pBC[2][1] = hallSensorVal[(i+1)][j];  
      pBC[2][2] = hallSensorVal[(i+1)][j+1];  
      pBC[2][3] = hallSensorVal[(i+1)][j+2]; 
      pBC[3][0] = hallSensorVal[(i+2)][j-1];  
      pBC[3][1] = hallSensorVal[(i+2)][j];  
      pBC[3][2] = hallSensorVal[(i+2)][j+1];  
      pBC[3][3] = hallSensorVal[(i+2)][j+2];
      bcp.updateCoefficients(pBC);
      recordSampleData(false, i, j); //false: isBoundary
    }
  }
}

void updateClipping() {
  int w, h;
  float pM;
  maxM = -1;
  minM = 1;
  if (isPortrait) {
    rawMap = null;
    rawMap = createImage((totalC-1)*sampleRes, (totalR-1)*sampleRes, RGB);
    rawMap.loadPixels();
    for (int i = 0; i<SERIES_NUM;i++) {
      MapN[i] = null;
      MapN[i] = createImage((totalC-1)*sampleRes, (totalR-1)*sampleRes, RGB);
      MapN[i].loadPixels();
      MapS[i] = null;
      MapS[i] = createImage((totalC-1)*sampleRes, (totalR-1)*sampleRes, RGB);
      MapN[i].loadPixels();
    }
    for (int i=0;i<totalR-1;i++) {
      for (int j=0;j<totalC-1;j++) {
        for (int x=0; x<sampleRes; x++) {
          for (int y=0; y<sampleRes; y++) {
            w = i*sampleRes + x;
            h = j*sampleRes + y;
            pM = sampleMVal[w][h];
            if (pM>255) {
              pM = 255;
            }
            if (pM<-255) {
              pM = -255;
            }
            if (pM >= 0) {    // N pole
              if (pM > maxM) {
                maxM = pM;
              }
              if (pM >= SERIES_BASE) {
                int tIndex = (int)((pM-SERIES_BASE)/SERIES_SPACE);
                if (tIndex >= SERIES_NUM) tIndex = SERIES_NUM-1;
                MapN[tIndex].pixels[h+w*MapN[tIndex].width] = color(pM,0,0);
              }
              if (showRaw)rawMap.pixels[h+w*rawMap.width] = color(pM, 0, 0);
            } 
            else {         // S pole
              if (pM < minM) {
                minM = pM;
              }
              if (pM <= -SERIES_BASE) {
                int tIndex = (int)((-(pM)-SERIES_BASE)/SERIES_SPACE);
                if (tIndex >= SERIES_NUM) tIndex = SERIES_NUM-1;
                MapS[tIndex].pixels[h+w*MapS[tIndex].width] = color(0,0,-pM);
              }
              if (showRaw)rawMap.pixels[h+w*rawMap.width] = color(0,0,-pM);
            }
          }
        }
      }
    }
  }
  else { // is horizontal
    rawMap = null;
    rawMap = createImage((totalR-1)*sampleRes, (totalC-1)*sampleRes, RGB);
    rawMap.loadPixels();
    for (int i = 0; i<SERIES_NUM;i++) {
      MapN[i] = null;
      MapN[i] = createImage((totalR-1)*sampleRes, (totalC-1)*sampleRes, RGB);
      MapN[i].loadPixels();
      MapS[i] = null;
      MapS[i] = createImage((totalR-1)*sampleRes, (totalC-1)*sampleRes, RGB);
      MapN[i].loadPixels();
    }
    for (int i=0;i<totalR-1;i++) {
      for (int j=0;j<totalC-1;j++) {
        for (int x=0; x<sampleRes; x++) {
          for (int y=0; y<sampleRes; y++) {
            w = i*sampleRes + x;
            h = j*sampleRes + y;
            pM = sampleMVal[w][h];
//            if(inversePolar) pM = -pM;
            if (pM>255) {
              pM = 255;
            }
            if (pM<-255) {
              pM = -255;
            }
            if (pM >= 0) {    // N pole
              if (pM > maxM) {
                maxM = pM;
              }
              if (pM >= SERIES_BASE) {
                int tIndex = (int)((pM-SERIES_BASE)/SERIES_SPACE);
                if (tIndex >= SERIES_NUM) tIndex = SERIES_NUM-1;
                MapN[tIndex].pixels[w+h*MapN[tIndex].width] = color(pM, 0, 0);
              }

              if (showRaw)rawMap.pixels[w+h*rawMap.width] = color(pM, 0, 0);
            } 
            else {         // S pole
              if (pM < minM) {
                minM = pM;
              }
              if (pM <= -SERIES_BASE) {
                int tIndex = (int)((float)(-(pM)-SERIES_BASE)/SERIES_SPACE);
                if (tIndex >= SERIES_NUM) tIndex = SERIES_NUM-1;
                MapS[tIndex].pixels[w+h*MapN[tIndex].width] = color(0, 0, -pM);
              }
              if (showRaw)rawMap.pixels[w+h*rawMap.width] = color(0, 0, -pM);
            }
          }
        }
      }
    }
  }

  rawMap.updatePixels();
  for (int i = 0; i<SERIES_NUM;i++) {
    MapN[i].updatePixels();
    MapS[i].updatePixels();
  }
}

void drawRawData() {
  if (isPortrait)  
    image(rawMap, x_padding, y_padding, imgWidth, imgHeight);
  else
    image(rawMap, x_padding, y_padding, imgHeight, imgWidth);
}

void drawTokens() {
  contoursNList.clear();
  contoursSList.clear();
  //  L1centroids.clear();
  gData.clear();
  for (int i = SERIES_NUM-1; i >= 0; i--) {
    ArrayList<Contour> contoursN = new ArrayList<Contour>();
    ArrayList<Contour> contoursS = new ArrayList<Contour>();
    contoursNList.add(contoursN);
    contoursSList.add(contoursS);
  }
  noFill();
  int contourNum = 0;

  for (int i = 0; i < SERIES_NUM; i++) {
    ArrayList contoursN = contoursNList.get(i);
    ArrayList contoursS = contoursSList.get(i);
    boolean flag = false;

    opencv.loadImage(MapN[i]);
    contoursN = opencv.findContours(false, true);
    opencv.loadImage(MapS[i]);
    contoursS = opencv.findContours(false, true);
    if (i==0) {
      contourNum = contoursN.size()+contoursS.size();
      flag = true;
    }
    if (showRaw) {
      drawContours(contoursN, flag, color(255, 255, 255), 1, i, 0);
      drawContours(contoursS, flag, color(255, 255, 255), 1, i, 1);
    }
    else {
      drawContours(contoursN, flag, color(255, 0, 0), 2, i, 0);
      drawContours(contoursS, flag, color(0, 0, 255), 2, i, 1);
    }
  }

//  if (contourNum > CALIB_THLD) {
//    doCalibration = true;
//    CALIB_THLD = 9999;
//    initCalib = true;
//  }
}

void drawContours(ArrayList<Contour> s, boolean L1, color c, float stkWidth, int i, int polar) {
  for (Contour contour : s) {
    ArrayList<PVector> points;
    int m = (i+1)*SERIES_SPACE;

    if (!approximate)
      points = contour.getPoints();
    else
      points = contour.getPolygonApproximation().getPoints();

    if (!drawDT && points.size() > NOISE_THRESHOLD) {
      strokeWeight(stkWidth);
      stroke(c);
      beginShape();

      PVector centroid = new PVector(0, 0);
      PVector startPoint = null;

      //Determine centroid of the contour
      for (PVector point : points) {
        if (startPoint == null) startPoint = point;
        vertex(point.x*x_interval+x_padding, point.y*y_interval+y_padding);
        centroid.x += point.x;
        centroid.y += point.y;
      }
      centroid.x /= points.size();
      centroid.y /= points.size();
      vertex(startPoint.x*x_interval+x_padding, startPoint.y*y_interval+y_padding);
      endShape();

      //Determine m and area of the contour
      Rectangle bbox = contour.getBoundingBox();
      strokeWeight(1);
      if(drawLayerDetail) rect(bbox.x*x_interval+x_padding, bbox.y*y_interval+y_padding, bbox.width*x_interval, bbox.height*y_interval);

      int bx1 = bbox.x, by1 = bbox.y, bx2 = bbox.x+bbox.width, by2 = bbox.y+bbox.height;
      int area = 0, locArea = 0, pixelM = 0, tempM = 0;
      int failSafe = (totalR-1)*sampleRes*(totalC-1)*sampleRes;
      for (int _x = bx1; _x< bx2; _x++) {
        for (int _y = by1; _y< by2; _y++) {
          locArea = _x+_y*MapN[i].width;
          pixelM = 0;
          if (polar ==0) {
            pixelM = (int)red(MapN[i].pixels[locArea]);
            if (pixelM >= m) { 
              ++area;
              if (pixelM > tempM) tempM = pixelM;
              if(drawLayerDetail){
                int px = int(_x*x_interval+x_padding), py = int(_y*y_interval+y_padding);
                if (i == 0) point(px, py);
              }
            }
          }
          else { 
            pixelM = (int)blue(MapS[i].pixels[locArea]);
            if (pixelM >= m) { 
              ++area;
              if (pixelM > tempM) tempM = pixelM;
              if(drawLayerDetail){
                int px = int(_x*x_interval+x_padding), py = int(_y*y_interval+y_padding);
                if (i == 0) point(px, py);
              }
            }
          }
        }
      }
      if(tempM>m) m = tempM;
      
      //Find the match base contour: dBase and assign value
      if (L1) {
        gData.add(new GData(polar, (int)centroid.x, (int)centroid.y, m, 0, 0, polar, i, area));
        stroke(0, 255, 0);
        fill(0, 255, 0);
        ellipse(centroid.x*x_interval+x_padding, centroid.y*y_interval+y_padding, 3, 3);
        noFill();
      } 
      else {
        float minDis = 10000;
        PVector pairCentroid = new PVector(0, 0);
        GData dBase = new GData();
        for (GData d : gData) {
          if (d.polar == polar) {
            float dis = dist(d.x, d.y, centroid.x, centroid.y);
            if (dis < minDis) {
              minDis = dis;
              dBase = d;
              if (drawPair) pairCentroid = new PVector(d.x, d.y);
            }
          }
        }
        dBase.m = m;
        dBase.setAreaArrayVal(polar, i, area);

        if (drawPair) {
          stroke(0, 255, 0);
          strokeWeight(1);
          line(pairCentroid.x*x_interval+x_padding, pairCentroid.y*y_interval+y_padding, 
          centroid.x*x_interval+x_padding, centroid.y*y_interval+y_padding);
        }
      }
    }
  }
  strokeWeight(1);
}

void drawInfo() {
  float fRate = 1000.f/(millis()-t_end);
  if (fRate>30) 
    fill(0, 255, 0);
  else if (fRate>=15 && fRate<30)
    fill(255, 255, 0);
  else 
    fill(255, 0, 0);
  if (isPortrait) {
    text("FPS: "+(int)fRate, 10, scrImgHeight+info_padding);
  }
  else {
    text("FPS: "+(int)fRate, 10, scrImgWidth+info_padding);
  }
  fill(255);
  if (isPortrait) {
    text("MaxN:"+(int)maxM+"|MaxS:"+(int)minM+"|BASE:" +SERIES_BASE+"|GAP:" +SERIES_SPACE, 80, scrImgHeight+info_padding);
    text("KEY: (R:RAW) (F:FLIP) (C:CALIBRATE) (I/K:BASE UP/DN) (J/L: GAP UP/DN)", 80, scrImgHeight+info_padding*3);
    if (doCalibration) 
      text("Calibrating...", 10, scrImgHeight+info_padding*2);
    else 
      text("Calibrated.", 10, scrImgHeight+info_padding*2);
  }
  else {
    text("MaxN: "+(int)maxM+" | MaxS: "+(int)minM+" | BASE: " +SERIES_BASE+" | GAP: " +SERIES_SPACE, 80, scrImgWidth+info_padding);
    if (doCalibration) 
      text("Calibrating...", 400, scrImgWidth+info_padding);
    else 
      text("Calibrated.", 400, scrImgWidth+info_padding);
    text("KEY: (R:RAW) (F:FLIP) (C:CALIBRATION) (I/K:BASE UP/DN) (J/L: GAP UP/DN)", 10, scrImgWidth+info_padding*2);
  }
}

void dumpTokens() {
  println("==");
  for (GData g: gData) {
    print(g.polar+"|"+g.m+"\t|("+g.x+","+g.y+")\t||");
    for (int i=0; i< g.areaArray.length ; i++) {
      print(g.areaArray[i]+"\t|");
      if (i==SERIES_NUM-1) print("|");
    }
    println();
  }
}
