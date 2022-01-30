## MPEG Video Hosting

This project provides a set of tools for taking a collection of local MPEG-1 videos and making them
web accessible both locally and via AWS S3 and CloudFront.

[FFmpeg](https://www.ffmpeg.org/) is used to convert MPEG-1 to MP4
with playback using a `<video>` [element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video).

In a prior iteration of this project, the [JSMpeg](https://jsmpeg.com/) library 
provided direct MPEG-1 playback in a web browser.

Great for old music video collections!

![Screenshot](screenshot.png)

## Build

The `<video>` [element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/video)
does not directly support MPEG-1 media. 

[FFmpeg](https://www.ffmpeg.org/) is used to convert MPEG-1 to MP4
prior to web server hosting.

```bash
ffmpeg -y -i input.mpg -c:v libx264 -crf 17 output.mp4
```

In a previous version of this project, MPEG-1 videos were hosting directly.

JSMpeg requires MPEG-1 videos to be in the MPEG-TS format.
Fortunately, converting to that format is trivial with [FFmpeg](https://www.ffmpeg.org/).

```bash
ffmpeg -y -i input.mpg -c copy output.ts
```

The simple hosting provided here includes a thumbnail gallery.
FFmpeg is also used to generate thumbnail frames.

```bash
ffmpeg -y -i input.mpg -ss 00:00:11.000 -vframes 1 output.png
```

The `script.sh` Bash shell script perform these actions over the entire contents of a directory.
It also downloads the JSMpeg library and performs a few other steps.
Fill in the options at the top of that file.

# Run Locally

The host the website locally, use the simple HTTP server from Python.

I recommend the [RangeHTTPServer](https://github.com/danvk/RangeHTTPServer) extension 
that supports HTTP range requests.

```bash
pip install rangehttpserver
```

Run the following in the project root to host the web server:

```bash
python -m RangeHTTPServer
```