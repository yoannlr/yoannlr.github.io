# Audio on Linux explained: ALSA, Pulse, Jack, Pipewire...

*This article is a small, simplified explanation of audio on Linux. Let's understand audio on Linux!*

* **The Soundcard:** in your computer, the soundcard is responsible of converting digital information, understood by the operating system, to analogic signal, used by devices (a jack headphone or microphone), and vice-versa.
* The operating system, by itself, doesn't know how to read/write bytes to the soundcard. It needs a **driver**.
   * In the early days of audio on Linux, the driver was **OSS** (Open Sound System), but it had some limitations and became proprietary.
   * Now, the commonly used driver is **ALSA** (Advanced Linux Sound Architecture).
* With these drivers, it is possible for an application to use the soundcard: VLC can output directly to ALSA.
* However, these drivers have an important problem: they don't handle multiplexing. This means only one application can use the soundcard (microphone or speakers) at a time.
* This problem is solved by using a **sound server**: it merges all audio streams into one, which it then sends to ALSA.
* The sound server is also responsible of **resampling** the audio. If two streams use a different frenquency, let's say 44.1kHz and 48kHz, the server will "convert" (resample) these streams to the frequency of it's configuration, 44.1kHz for example.
* The commonly used sound server nowadays is **PulseAudio**, which provides an abstraction layer to the applications. From the application point of view, they're just reading/writing to PulseAudio.
* PulseAudio even allows using multiple sound cards at once: the integraded soundcard in your computer, a USB microphone, the HDMI audio output of your graphics card, ... This can be easily configured in `pavucontrol`. See picture below.
* PulseAudio has two main limitations.
   * It hardly handles managing audio as a graph (eg. having an applications streaming to two sound cards).
   * It is not real-time, there's a small latency of 40-80ms.
   * These two drawbacks are irrelevant to the majority of users, but...
* **JACK**, an alternative sound server, solves these problems. It's designed for the audio profesionnals: very low latency, flexible audio connections (with graphs if you install `qjackctl`), even MIDI support for instruments.
   * There are two "versions" of JACK: JACK and JACK2. JACK2 is written in C++, whereas JACK is written in C.
   * Most applications are written for PulseAudio. If you run JACK for a specific app (Ardour, for example), you will notice the other apps trying to emmit sound are like frozen. Indeed, the soundcard is used by JACK, which means PulseAudio cannot read/write to it. This problem can be solved by adding [these commands](https://gist.github.com/yoannlr/e55d8755e8b87ba450719f6bed30a91c) to the adequate events in `qjackctl`. See picture below.
* That's quite a lot of programs for audio on Linux... Now, let's introduce **Pipewire**. Pipewire combines the simplicity of PulseAudio and the advantages of JACK.
   * Pipewire can act as a drop-in replacement for PulseAudio by installing the `pipewire-pulse` addon. This should be transparent to apps, as they "think" they are interacting with PulseAudio.
   * The same applies to JACK by installing `pipewire-jack`. However, you might need to run JACK apps with the `pw_jack` command: eg. `pw_jack ardour6`.
* We've talked about audio... video on Linux is still at the "driver step": a webcam on Linux can only be used by one app at a time. There is no "video server" which handles multiplexing video... Well... there wasn't. Pipewire also introduces video multiplexing and native screen-sharing under the wayland display server.

And... That's it! Hope it helped you get a clearer understanding of audio on Linux.

## pavucontrol
![pavucontrol](/res/pavucontrol.png)

## qjackctl compatiblity
![qjackctl configutation](/res/qjackctl_commands.png)
