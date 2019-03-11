import ImageZoomViewPW
import UIKit

class ProgramaticallyViewController: UIViewController {

    var zoomPW: ZoomViewPW!

    override func viewDidLoad() {
        super.viewDidLoad()
        zoomPW = ZoomViewPW(frame: CGRect(origin: CGPoint.zero,
                                          size: CGSize(width: UIScreen.main.bounds.size.width / 2.0,
                                                       height: UIScreen.main.bounds.size.height / 2.0)),
                            image: #imageLiteral(resourceName: "IMG_7419.jpg"))
        zoomPW.center = view.center
        zoomPW.layer.borderColor = UIColor.black.cgColor
        zoomPW.layer.borderWidth = 5.0
        zoomPW.backgroundColor = .clear
        view.addSubview(zoomPW)
    }

    @IBAction func rotate(_ sender: Any) {
        zoomPW.rotate()
    }
}
