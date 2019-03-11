import UIKit
import ImageZoomViewPW

class InterfaceBuilderViewController: UIViewController {

    @IBOutlet weak var zoomViewPW: ZoomViewPW!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Generated from interface builder
        zoomViewPW.backgroundColor = .clear
        zoomViewPW.setImage(#imageLiteral(resourceName: "IMG_7419.jpg"))
    }

    @IBAction func rotate(_ sender: Any) {
        zoomViewPW.rotate()
    }
}
