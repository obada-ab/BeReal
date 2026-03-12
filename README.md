# BeReal

A real-time audio visualizer built with [Processing](https://processing.org/) and [Minim](https://code.compartmental.net/minim/). It captures system audio, performs FFT analysis, and renders frequency bands as a grid of circles that rise and decay with the music.

## Running the Sketch

### 1. Install Processing

Download and install Processing from [processing.org/download](https://processing.org/download/).

### 2. Install the Minim Library

Minim is bundled with Processing by default. If it's missing:

1. Open Processing
2. Go to **Sketch → Import Library → Manage Libraries**
3. Search for **Minim** and install it

### 3. Open and Run

1. Clone this repository or download the source files
2. Open `BeReal.pde` in Processing (File → Open, or double-click the file)
3. Make sure system audio capture is set up (see below)
4. Click the **Run** button (▶)

## Capturing System Audio

The sketch listens to the default recording input device using `minim.getLineIn()`. By default this captures your **microphone**. To visualize system audio (music, videos, etc.), you need to route desktop audio to a virtual input device.

### Windows

**Option A — Stereo Mix (no extra software)**

Many sound cards have a built-in loopback device called Stereo Mix:

1. Right-click the speaker icon in the taskbar → **Sound settings**
2. Scroll down and click **More sound settings**
3. Go to the **Recording** tab
4. Right-click → **Show Disabled Devices**
5. Right-click **Stereo Mix** → **Enable** → **Set as Default Device**

If Stereo Mix doesn't appear, your audio driver may not support it — use Option B instead.

**Option B — VB-Audio Virtual Cable**

[VB-CABLE](https://vb-audio.com/Cable/) is a free virtual audio driver that acts as a loopback device:

1. Download and install from [vb-audio.com/Cable](https://vb-audio.com/Cable/)
2. In **Sound settings → Playback**, set **CABLE Input** as the default output device
3. In **Sound settings → Recording**, set **CABLE Output** as the default input device

> **Note:** With this setup audio is routed through the virtual cable and won't play through your speakers. To hear audio *and* capture it, use [VoiceMeeter](https://vb-audio.com/Voicemeeter/) to split the output to both your speakers and the virtual cable.

### Linux

**Option A — PulseAudio (most distros)**

Create a loopback module that copies playback audio to an input:

```bash
pactl load-module module-loopback latency_msec=1
```

Then set the loopback monitor as the default input device in your sound settings. To make this persistent across reboots, add the line to `/etc/pulse/default.pa`.

**Option B — PipeWire (Fedora, Ubuntu 22.10+, etc.)**

If your distro uses PipeWire, you can use `pw-loopback`:

```bash
pw-loopback --capture-props='media.class=Audio/Sink' &
```

Then route your application audio to the new sink using `pavucontrol` or your desktop's sound settings, and set the sink's monitor as the recording source.

### macOS

Use [BlackHole](https://existential.audio/blackhole/) as a virtual audio device, then create a Multi-Output Device in **Audio MIDI Setup** to send audio to both BlackHole and your speakers.
