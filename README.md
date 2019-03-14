# ImageZoomViewPW
A customizable ImageView with zooming enabled and zooming region bounded

## Installation

### CocoaPods
Add the following to your Podfile:
```swift
use_frameworks!
pod 'ImageZoomViewPW', :git => 'https://github.com/pierre-wehbe/ImageZoomViewPW.git', :tag => '1.0.3'
```

## Quick Start

### From Interface Builder
```swift
@IBOutlet weak var zoomViewPW: ZoomViewPW!

override func viewDidLoad() {
  super.viewDidLoad()
  zoomViewPW.setImage(#imageLiteral(resourceName: "imageName.jpg"))
}
```

### Programatically
```swift
var zoomPW: ZoomViewPW!

override func viewDidLoad() {
  super.viewDidLoad()
    zoomPW = ZoomViewPW(frame: CGRect(origin: CGPoint.zero,
                                      size: CGSize(width: UIScreen.main.bounds.size.width / 2.0,
                                                   height: UIScreen.main.bounds.size.height / 2.0)),
                        image: #imageLiteral(resourceName: "IMG_7419.jpg"))
    zoomPW.center = view.center
    view.addSubview(zoomPW)
}
```


## Contribute
Contributions are highly appreciated! To submit one:
1. Fork
2. Commit changes to a branch in your fork
3. Push your code and make a pull request

## Created By:
Pierre WEHBE

## License
[MIT](https://github.com/pierre-wehbe/ImageZoomViewPW/blob/master/LICENSE)
