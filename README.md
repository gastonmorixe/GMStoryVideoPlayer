# GMStoryVideoPlayer

iOS Instagram/Snapchat Stories Video Player with Queue/Playlist like!  (ObjC) 

Note: This is a WIP, help me improve it!

![Demo GIF](https://raw.githubusercontent.com/gaston23/GMStoryVideoPlayer/master/Example/3o7btNOkaqfBEgXnfq.gif)

Features!
+ Tap to next or prev video in the queue/playlist
+ Loopeable playlist (smart algorithm!)
+ Fast preload of both next and prev videos
+ Thumbnails support
+ Video and Thumbs caching

## How does it work?

It is based on raw AVPlayer. 
GMStoryViewController has 3 video players (GMVideoViewController), it loads the current video and smartly preloads the next and previous video too. 

Note: For now to get best buffering and instant play at tap time, the videos while preloading are also being played looping, just not shown. As soon as the video should be shown we hide the other 2, seek that to time zero and show it. Alternatives welcome.

Warning: You might want to choose to disable playing all the videos while controller not being shown (the reason is to get better buffering)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

xCode and iOS simulator or Device

## Installation

GMStoryVideoPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GMStoryVideoPlayer"
```

## Author

Gaston Morixe, gaston@black.uy

## License

GMStoryVideoPlayer is available under the MIT license. See the LICENSE file for more info.
