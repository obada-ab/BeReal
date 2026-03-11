import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import algorithms.noise.*;

OpenSimplexNoiseKS generator;
String audioFileName = "BeReal.wav"; 

AudioPlayer track;
FFT fft;
Minim minim;

int rez = 32;
float dx;
float radFactor = 0.8;

int bands = rez;
float[] spectrum = new float[bands];
float[] sum = new float[bands];
float maxAmp = 0;

public void setup() {
    size(1080, 1080, P2D);
    frameRate(60);
    smooth(4);

    dx = width * 1.0 / rez;
    generator = new OpenSimplexNoiseKS();

    minim = new Minim(this);
    track = minim.loadFile(audioFileName, 2048);

    track.loop();
 
    fft = new FFT(track.bufferSize(), track.sampleRate());
    
    fft.logAverages(11, 3);
}

public void draw() {
    background(0);
    fill(255);
    stroke(255);
    strokeWeight(5);

    fft.forward(track.mix);

    for(int i = 0; i < rez; i++) {
        //int height = floor(map(fft.getAvg(i), 0, 510, 0, 32));
        int height = floor(map(log(fft.getAvg(i)) / log(10), 0, 2.8, 0, 32));
        maxAmp = max(maxAmp, fft.getAvg(i));
        for (int j = 0; j < min(height, rez); j++) {
            circle(dx / 2.0 + (rez - 1 - i) * dx, dx / 2.0 + (rez - 1 - j) * dx, dx * radFactor);
        }
    }
}
