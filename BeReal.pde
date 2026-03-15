import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import algorithms.noise.*;

OpenSimplexNoiseKS generator;

AudioPlayer track;
FFT fft;
Minim minim;

int rez = 18;
int yRez;
float dx;
float radFactor = 0.8;
float minCirc = 0.15;

float sf = 0.01;
float tf = 0.06;
float maxOffset = 0;

int bands = rez;
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float maxAmp = 100;

float[][] circles;
float[][][] circlesHist;

float[][] circleCoords = {
    {270, 270},
    {270 * 3, 270 * 3},
    {270 * 3, 270},
    {270, 270 * 3},
    {270 * 2, 270},
    {270 * 2, 270 * 3},
    {270, 270 * 2},
    {270 * 3, 270 * 2},
};

public void setup() {
    size(1080, 1080, P2D);
    frameRate(60);
    smooth(4);
    fill(255);
    noStroke();
    blendMode(ADD);

    dx = width * 1.0 / rez;
    yRez = floor(height / dx);

    circles = new float[rez][yRez];
    circlesHist = new float[2400][rez][yRez];

    generator = new OpenSimplexNoiseKS(420);

    minim = new Minim(this);
    track = minim.loadFile("BeRealLoop.wav", 1024);
    track.loop();

    fft = new FFT(track.bufferSize(), track.sampleRate());
    
    fft.logAverages(70, 2);
}

void drawCircles() {

    for(int i = 0; i < rez; i++) {
        for (int j = 0; j < yRez; j++) {
            float x = dx / 2.0 + i * dx;
            float y = dx / 2.0 + j * dx;

            if (circles[i][j] > 0.3) {
                for (int col = 0; col < 3; col++) {
                    fill(col == 0 ? 255 : 0, col == 1 ? 255 : 0, col == 2 ? 255 : 0);
                    float xRand = (float)(generator.eval(30 * col + x * sf, y * sf, frameCount * tf));
                    float yRand = (float)(generator.eval(30 * col + x * sf, 30 + y * sf, frameCount * tf));
                    circle(x + xRand * maxOffset, y + yRand * maxOffset, dx * radFactor * circles[i][j]);
                }
            }
            else {
                fill(255);
                circle(x, y, dx * radFactor * circles[i][j]);
            }
            if (circles[i][j] > 0) {
                circles[i][j] = max(0, circles[i][j] * 0.85 - 0.06);
            }
            if (circles[i][j] < minCirc) {
                circles[i][j] = 0;
            }
        }
    }
}


void setCircle(int i, int j) {
    circles[i][j] = 1;
    circlesHist[frameCount - 1][i][j] = 1;
}

void setCircle2(int i, int j) {
    if (circlesHist[frameCount - 1 - 2400][i][j] > 0.1)
        circles[i][j] = circlesHist[frameCount - 1 - 2400][i][j];
}

void drawBigCircle(float x, float y, float r1, float r2) {
    for (int i = 0; i < rez; i++) {
        for (int j = 0; j < yRez; j++) {
            float x2 = dx / 2.0 + i * dx;
            float y2 = dx / 2.0 + j * dx;
            float dis = dist(x, y, x2, y2);
            if (dis >= r1 && dis <= r2) {
                setCircle(i, j);
            }
        }
    }
}

public void draw() {
    background(0);
    if (frameCount == 2400) maxOffset = 0;
    if (frameCount >= 2400 * 2) noLoop();

    if (frameCount > 2400) {
        if (frameCount > 2400 + 1185 && frameCount < 2400 + 1300) {
            float theta = map(frameCount, 2400 + 1185, 2400 + 1385, 0, TWO_PI);
            maxOffset = max(0, 5 * sin(theta));
        } else if (frameCount > 2400 + 1300 && frameCount < 2400 + 1393) {
            float theta = map(frameCount, 2400 + 1300, 2400 + 1393, 0, TWO_PI + PI / 2);
            maxOffset = max(0, 7 * sin(theta));
        }

        for (int i = 0; i < rez; i++) {
            for (int j = 0; j < yRez; j++) {
                setCircle2(i, j);
            }
        }
        drawCircles();
        saveFrame("output/frame-####.png");
    } else {
        fft.forward(track.mix);

        if (frameCount > 1185 && frameCount < 1300) {
            float theta = map(frameCount, 1185, 1385, 0, TWO_PI);
            maxOffset = max(0, 5 * sin(theta));
        } else if (frameCount > 1300 && frameCount < 1393) {
            float theta = map(frameCount, 1300, 1393, 0, TWO_PI + PI / 2);
            maxOffset = max(0, 7 * sin(theta));
        }


        if (frameCount < 245) {
            for (int i = 0; i <= 8; i++) {
                float r1 = min(width * (0.8 - 0.1 * i), (frameCount - 30 * i) * 50.0);
                if (frameCount >= 30 * i) drawBigCircle(width / 2.0, height / 2.0, r1, r1 + 200);
            }
        } else if (frameCount > 1673 && frameCount < 1903) {
            for (int i = 0; i <= 8; i++) {
                float r1 = (frameCount - 1673 - 30 * i) * 50.0;
                if (frameCount - 1673 >= 30 * i) drawBigCircle(width / 2.0, height / 2.0, r1, r1 + 300);
            }
        } else if (frameCount > 2153 && frameCount < 2383) {
            for (int i = 0; i <= 8; i++) {
                float r1 = (frameCount - 2153 - 30 * i) * 50.0;
                if (frameCount - 2153 >= 30 * i) drawBigCircle(circleCoords[i][0], circleCoords[i][1], r1, r1 + 300);
            }
        } else {
            for(int i = 0; i < rez; i+=2) {
                float avg1 = fft.getAvg(i);
                float avg2 = fft.getAvg(i + 1);
                maxAmp = max(maxAmp, avg1);
                maxAmp = max(maxAmp, avg2);
                float avg3 = (avg1 + avg2) / 2;
                int height3 = floor(map(log(avg3), 0, log(maxAmp), 0, yRez));
                int i2 = i / 2;
                for (int j = 0; j < min(height3, yRez); j++) {
                    if (frameCount < 465) {
                        setCircle(rez / 2 + i2, yRez - 1 - j);
                        setCircle(rez / 2 - 1 - i2, yRez - 1 - j);
                    } else if (frameCount > 475 && frameCount < 705) {
                        setCircle(yRez - 1 - j, rez - 1 - (rez / 2 + i2));
                        setCircle(yRez - 1 - j, rez - 1 - (rez / 2 - 1 - i2));
                    } else if (frameCount > 715 && frameCount < 935) {
                        setCircle(rez / 2 + i2, j);
                        setCircle(rez / 2 - 1 - i2, j);
                    } else if (frameCount > 945 && frameCount < 1175) {
                        setCircle(j, rez - 1 - (rez / 2 + i2));
                        setCircle(j, rez - 1 - (rez / 2 - 1 - i2));
                    } else if (frameCount > 1185 && frameCount < 1423) {
                        setCircle(rez / 2 + j / 2, rez - 1 - (rez / 2 + i2));
                        setCircle(rez / 2 + j / 2, rez - 1 - (rez / 2 - 1 - i2));
                        setCircle(rez / 2 - j / 2, rez - 1 - (rez / 2 + i2));
                        setCircle(rez / 2 - j / 2, rez - 1 - (rez / 2 - 1 - i2));
                    } else if (frameCount > 1433 && frameCount < 1663) {
                        setCircle(rez / 2 + i2, yRez - 1 - j);
                        setCircle(rez / 2 - 1 - i2, yRez - 1 - j);
                    } else if (frameCount > 1913 && frameCount < 2143) {
                        setCircle(rez / 2 + i2, j);
                        setCircle(rez / 2 - 1 - i2, j);
                    }
                }
            }
        }

        drawCircles();
    }
}
