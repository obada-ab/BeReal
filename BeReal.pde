import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import algorithms.noise.*;

OpenSimplexNoiseKS generator;

AudioInput track;
FFT fft;
Minim minim;

int rez = 32;
int yRez;
float dx;
float radFactor = 0.8;
float minCirc = 0.15;

int bands = rez;
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float maxAmp = 10;

float[][] circles;

public void setup() {
    size(940, 410, P2D);
    frameRate(60);
    smooth(4);
    fill(255);
    stroke(255);
    strokeWeight(5);

    dx = width * 1.0 / rez;
    yRez = height / rez;

    circles = new float[rez][yRez];

    generator = new OpenSimplexNoiseKS();

    minim = new Minim(this);
    track = minim.getLineIn(Minim.STEREO, 2048);

    fft = new FFT(track.bufferSize(), track.sampleRate());
    
    fft.logAverages(11, 4);
}

void drawCircles() {
    for(int i = 0; i < rez; i++) {
        for (int j = 0; j < yRez; j++) {
            circle(dx / 2.0 + i * dx, dx / 2.0 + (j + 2) * dx - 5, dx * radFactor * circles[i][j]);
            if (circles[i][j] > 0) {
                circles[i][j] = max(0, circles[i][j] * 0.85 - 0.07);
            }
            if (circles[i][j] < minCirc) {
                circles[i][j] = 0;
            }
        }
    }
}


void setCircle(int i, int j) {
    circles[i][j] = 1;
}

public void draw() {
    background(0);

    fft.forward(track.mix);

    for(int i = 0; i < rez; i++) {
        //int height = floor(map(fft.getAvg(i), 0, maxAmp, 0, yRez));
        int height = floor(map(log(fft.getAvg(i)), 0, log(maxAmp), 0, yRez));
        maxAmp = max(maxAmp, fft.getAvg(i));
        for (int j = 0; j < min(height, yRez); j++) {
            setCircle(rez - 1 - i, yRez - 1 - j);
        }
    }

    drawCircles();
}
