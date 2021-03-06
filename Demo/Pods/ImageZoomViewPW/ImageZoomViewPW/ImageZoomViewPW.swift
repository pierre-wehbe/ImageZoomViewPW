//
//  ImageZoomViewPW.swift
//  ImageZoomViewPW
//
//  Created by Pierre WEHBE on 3/10/19.
//  Copyright © 2019 Pierre Wehbe. All rights reserved.
//

import Foundation
import UIKit

//TODO: Write Documentation
//TODO: Check UIGestureRotation Reoginizer
//TODO: When a property is set such as size, I need to refresh the UI (call reset image should do the job)
//TODO: Add timer for preview view to hide

@IBDesignable
public class ZoomViewPW: UIScrollView {

    // MARK: Private Attributes
    static private let DefaultBoxSize: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 5.0

    private var _image: UIImage! {
        get {
            return imageView == nil ? UIImage() : imageView.image ?? UIImage()
        }
        set {
            guard self.bounds.width > 0 && self.bounds.height > 0 else {
                print("ZoomViewPW Error: Make sure to set bounds to your scrollView, width or height cannot be 0")
                return
            }
            guard newValue.size.width > 0 && newValue.size.height > 0 else {
                print("ZoomViewPW Error: Image width and height cannot be 0")
                return
            }
            if imageView != nil {
                imageView.removeFromSuperview()
            }
            imageView = UIImageView()
            imageView.layer.allowsEdgeAntialiasing = true
            imageView.image = newValue
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(origin: CGPoint.zero, size: newValue.size)
            addSubview(imageView)
            initConstraints()
            setupPreviewImage(newValue)
            contentSize = imageView.frame.size
            updateMinZoomScaleForSize(bounds.size)
            updateConstraintsForSize(bounds.size)
            updateConstraintsIfNeeded()
        }
    }

    private var currentScale: CGFloat = 0.0
    private var imageView: UIImageView!
    private var _mode: Mode = .fit
    private var _numberOfTapsForResetZoom: Int = 2
    private var _position: Position = .bottomLeft
    private var previewView: UIImageView!
    private var rotationIncrementInDegree: CGFloat = 90.0

    // MARK: IBInspectable Attributes
    //TODO: Add warning if used to not use in ViewController, use setImageinstead
    @IBInspectable public var image: UIImage? {
        get {
            return _image ?? UIImage()
        }
        set {
            self._image = newValue ?? UIImage()
        }
    }

    @IBInspectable public var boundingBoxColor: UIColor = .red
    @IBInspectable public var boundingBoxBorderWidth: CGFloat = 2.0
    @IBInspectable public var numberOfTapsForResetZoom: Int {
        get {
            return self._numberOfTapsForResetZoom
        }
        set {
            self._numberOfTapsForResetZoom = newValue > 0 ? newValue : 0
            self.setTapGesture()
        }
    }
    @IBInspectable var numberOfZoomInClicksAllowed: CGFloat = 6.0
    @IBInspectable public var previewViewBackgroundColor: UIColor = .clear
    @IBInspectable public var previewBoxSize: CGSize = CGSize(width: DefaultBoxSize, height: DefaultBoxSize)
    @IBInspectable public var xMargin: CGFloat = 10.0
    @IBInspectable public var yMargin: CGFloat = 10.0
    @IBInspectable public var zoomScaleIncrement: CGFloat = 1.0

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'mode' instead.")
    @IBInspectable var mode: String? {
        willSet {
            if let newMode = Mode(rawValue: newValue ?? "") {
                _mode = newMode
            }
        }
    }

    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'position' instead.")
    @IBInspectable var position: String? {
        willSet {
            if let newPosition = Position(rawValue: newValue?.lowercased() ?? "") {
                _position = newPosition
            }
        }
    }

    // MARK: Constraints
    private var imageLeadingConstraint: NSLayoutConstraint!
    private var imageBottomConstraint: NSLayoutConstraint!
    private var imageTopConstraint: NSLayoutConstraint!
    private var imageTrailingConstraint: NSLayoutConstraint!

    // MARK: Enums
    public enum Mode: String {
        case fit = "fit"
        case fill = "fill"
    }

    public enum Position: String {
        case topLeft = "topLeft"
        case bottomLeft = "bottomLeft"
        case topRight = "topRight"
        case bottomRight = "bottomRight"
    }

    // MARK: GestureRecognizers
    var _doubleTap: UITapGestureRecognizer!

    // MARK: Initializers
    public init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        setup()
        self._image = image
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        self._image = image
    }

    private func setup() {
        delegate = self
        bounces = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        clipsToBounds = true
        setTapGesture()
    }

    private func setTapGesture() {
        if _doubleTap != nil {
            removeGestureRecognizer(_doubleTap)
        }
        _doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        _doubleTap.numberOfTapsRequired = _numberOfTapsForResetZoom
        addGestureRecognizer(_doubleTap)
    }

    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        resetImage()
    }

    // MARK: Actions
    public func zoomIn() -> Bool {
        currentScale = self.zoomScale + zoomScaleIncrement
        currentScale = currentScale > self.maximumZoomScale ? self.maximumZoomScale : currentScale
        self.setZoomScale(currentScale, animated: true)
        return currentScale + zoomScaleIncrement <= self.maximumZoomScale
    }

    public func zoomOut() -> Bool {
        currentScale = self.zoomScale - zoomScaleIncrement
        currentScale = currentScale < self.minimumZoomScale ? self.minimumZoomScale : currentScale
        self.setZoomScale(currentScale, animated: true)
        return currentScale - zoomScaleIncrement >= self.minimumZoomScale
    }

    public func resetImage() {
        self._image = imageView == nil ? UIImage() : imageView.image ?? UIImage()
    }

    public func rotate() {
        self._image = imageRotatedByDegrees(oldImage: self._image, deg: rotationIncrementInDegree)
    }

    public func setImage(_ image: UIImage) {
        self._image = image
    }

    // In case some UI issues occure while using the interface builder
    public func refresh() {
        resetImage()
    }
}

// MARK: UIScroll Delegate
extension ZoomViewPW: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePreviewImagePosition(scrollView.contentOffset)
        updateBoundingBox()
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
        scrollView.contentSize = imageView.frame.size
        updateBoundingBox()
    }
}

// MARK: Helper Functions
extension ZoomViewPW {

    private func initConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageLeadingConstraint = NSLayoutConstraint(item: imageView,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: 0)
        imageTopConstraint = NSLayoutConstraint(item: imageView,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0)
        imageBottomConstraint = NSLayoutConstraint(item: imageView,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
        imageTrailingConstraint = NSLayoutConstraint(item: imageView,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .trailing,
                                                     multiplier: 1,
                                                     constant: 0)
        self.addConstraints([imageLeadingConstraint, imageTopConstraint, imageBottomConstraint, imageTrailingConstraint])
    }

    private func getOriginX(previewWidth: CGFloat) -> CGFloat { //TODO: make overwritable (open)
        switch _position {
        case .bottomLeft: fallthrough
        case .topLeft:
            return xMargin
        case .bottomRight: fallthrough
        case .topRight:
            return self.bounds.maxX - xMargin - previewWidth
        }
    }

    private func getOriginY(previewHeight: CGFloat) -> CGFloat { //TODO: make overwritable (open)
        switch _position {
        case .topRight: fallthrough
        case .topLeft:
            return yMargin
        case .bottomRight: fallthrough
        case .bottomLeft:
            return self.bounds.maxY - yMargin - previewHeight
        }
    }

    private func setupPreviewImage(_ image: UIImage) {
        if previewView != nil {
            previewView.removeFromSuperview()
        }

        previewView = UIImageView(frame: CGRect(x: getOriginX(previewWidth: previewBoxSize.width),
                                                y: getOriginY(previewHeight: previewBoxSize.height),
                                                width: previewBoxSize.width,
                                                height: previewBoxSize.height))
        previewView.image = image
        previewView.backgroundColor = previewViewBackgroundColor
        previewView.contentMode = .scaleAspectFit
        self.addSubview(previewView)
        let boundingBox = UIView(frame: CGRect(origin: CGPoint.zero, size: previewBoxSize))
        boundingBox.layer.borderColor = boundingBoxColor.cgColor
        boundingBox.layer.borderWidth = boundingBoxBorderWidth
        previewView.addSubview(boundingBox)
        updateBoundingBox()
        self.scrollViewDidZoom(self)
    }

    private func updateBoundingBox() {
        let boundingRect = previewView.subviews[0]
        guard let _ = previewView.image else {
            return
        }
        let imageDefaultSize = imageView.frame.size
        let previewViewSize = previewView.frame.size
        //TODO: case when actual iamge is smaller than previewSize
        let previewImageHeightScale = previewViewSize.height / imageDefaultSize.height
        let previewImageWidthScale = previewViewSize.width / imageDefaultSize.width
        let previewImageScale = min(previewImageHeightScale, previewImageWidthScale)

        let defaultPreviewImageSize = CGSize(width: imageDefaultSize.width * previewImageScale, height: imageDefaultSize.height * previewImageScale)

        var widthScale = imageDefaultSize.width / self.bounds.width
        var heightScale = imageDefaultSize.height / self.bounds.height
        widthScale = widthScale <= 1.0 ? 1.0 : widthScale
        heightScale = heightScale <= 1.0 ? 1.0 : heightScale

        let newWidth: CGFloat = defaultPreviewImageSize.width / widthScale
        let newHeight: CGFloat = defaultPreviewImageSize.height / heightScale

        let updatedZoomedImageSize = CGSize(width: newWidth, height: newHeight)

        let xInitOffset = (previewViewSize.width - defaultPreviewImageSize.width) / 2.0
        let yInitOffset = (previewViewSize.height - defaultPreviewImageSize.height) / 2.0
        let xOffset = xInitOffset + self.contentOffset.x * defaultPreviewImageSize.width / imageDefaultSize.width
        let yOffset = yInitOffset + self.contentOffset.y * defaultPreviewImageSize.height / imageDefaultSize.height

        boundingRect.frame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: updatedZoomedImageSize)
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {

        let originalImageWidth = imageView.frame.width
        let originalImageHeight = imageView.frame.height

        let widthScale = size.width / originalImageWidth
        let heightScale = size.height / originalImageHeight

        var minScale: CGFloat = 1.0

        if originalImageWidth > size.width && originalImageHeight > size.height {
            minScale = min(widthScale, heightScale)
        } else if originalImageWidth > size.width && originalImageHeight <= size.height {
            minScale = widthScale
        } else if originalImageWidth <= size.width && originalImageHeight > size.height {
            minScale = heightScale
        } else {
            minScale = _mode == .fit ? 1.0 : min(widthScale, heightScale)
        }

        self.minimumZoomScale = minScale
        self.maximumZoomScale = minScale + numberOfZoomInClicksAllowed
        self.setZoomScale(minScale, animated: false) // set initial zoom
    }

    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageTopConstraint.constant = yOffset
        imageBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageLeadingConstraint.constant = xOffset
        imageTrailingConstraint.constant = xOffset
        
        self.layoutIfNeeded()
    }

    private func updatePreviewImagePosition(_ offset: CGPoint) {
        switch _position {
        case .bottomLeft:
            previewView.frame.origin.x = getOriginX(previewWidth: previewView.frame.width) + offset.x
            previewView.frame.origin.y = getOriginY(previewHeight: previewView.frame.height)
            return
        case .topLeft:
            previewView.frame.origin.x = getOriginX(previewWidth: previewView.frame.width) + offset.x
            previewView.frame.origin.y = getOriginY(previewHeight: previewView.frame.height) + offset.y
            return
        case .bottomRight:
            previewView.frame.origin.x = getOriginX(previewWidth: previewView.frame.width)
            previewView.frame.origin.y = getOriginY(previewHeight: previewView.frame.height)
            return
        case .topRight:
            previewView.frame.origin.x = getOriginX(previewWidth: previewView.frame.width)
            previewView.frame.origin.y = getOriginY(previewHeight: previewView.frame.height) + offset.y
            return
        }
    }

    private func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x:0, y:0, width: oldImage.size.width, height: oldImage.size.height))
        let transform: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = transform
        let rotatedSize: CGSize = rotatedViewBox.frame.size

        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        guard let bitmap: CGContext = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))

        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0) //TODO: Check orientation for the image
        bitmap.draw(oldImage.cgImage!, in: CGRect(x:-oldImage.size.width / 2,
                                                  y: -oldImage.size.height / 2,
                                                  width: oldImage.size.width,
                                                  height: oldImage.size.height))
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        UIGraphicsEndImageContext()
        return newImage
    }
}


