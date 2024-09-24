# Audio-via-MIPS
The files used to analyze the audio files
## WAVE File Processing with MIPS Assembly
This repository contains a set of MIPS assembly programs designed to work with WAVE (Waveform Audio File Format) files. These programs demonstrate the ability to interpret WAVE file headers, analyze audio data, generate sound effects, and synthesize sound waves, all in MIPS assembly.

### Files in this Repository:
* question1.asm - This program reads a WAVE file header and extracts key information such as the number of channels, sample rate, byte rate, and bits per sample.

 * question2.asm - This program analyzes the audio data of a WAVE file to find the maximum and minimum amplitude values.

 * question3.asm - This program reverses the audio data in a WAVE file and writes the reversed audio to a new output file.

* question4.asm - This program generates a square wave audio file, with the user specifying the tone frequency, sample frequency, and length of the tone.

### Key Concepts:
#### WAVE File Format: A file format used to store uncompressed audio data, consisting of a 44-byte header followed by audio data.
#### MIPS Assembly: All programs are written in MIPS assembly, demonstrating file handling, data processing, and audio synthesis at a low level.
