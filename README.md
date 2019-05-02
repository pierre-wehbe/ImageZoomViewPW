# ImageZoomViewPW
[![Travis](https://img.shields.io/travis/Ramotion/folding-cell.svg)](https://travis-ci.org/Ramotion/folding-cell)
[![Swift 4.0](https://img.shields.io/badge/Swift-4.2-green.svg?style=flat)](https://developer.apple.com/swift/)

A customizable ImageView with zooming enabled and zooming region bounded

## Requirements
- iOS 12.0+
- Xcode 10.0+

## Installation

### CocoaPods
Add the following to your Podfile:
```swift
use_frameworks!
pod 'ImageZoomViewPW', :git => 'https://github.com/pierre-wehbe/ImageZoomViewPW.git', :tag => '1.0.3'
```

### Build the framwork yourself
1. Open ImageZoomViewPW.xcproject
2. Build
3. You will get "ImageZoomViewPW.framework" under product
4. Go to your project and drag the the framework of **3** anywhere in the project
5. Go to Project -> General -> Linked Frameworks and Binaries, the framework should be present there
6. Select it and click on the "-" sign to remove it
7. Select "+" in the "Embedded Binaries" section and select the framework, it should now be present in both "Embedded Binarie" and "Linked Frameworks and Binaries"
8. You're done :)

**or just drag and drop ImageZoomViewPW.swift file to your project**

## Quick Start
```swift
import ImageZoomViewPW
```
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

## Demo
![ImageZoomViewDemo](https://github.com/pierre-wehbe/ImageZoomViewPW/blob/master/Demo/ImageZoomViewDemo.gif)

## Contribute
Contributions are highly appreciated! To submit one:
1. Fork
2. Commit changes to a branch in your fork
3. Push your code and make a pull request

## Created By:
Pierre WEHBE

## License
[MIT](https://github.com/pierre-wehbe/ImageZoomViewPW/blob/master/LICENSE)
