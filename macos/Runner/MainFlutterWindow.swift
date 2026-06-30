import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Define tamanho mínimo e inicial da janela
    self.minSize = NSSize(width: 800, height: 620)
    self.setContentSize(NSSize(width: 1024, height: 768))
    self.titlebarAppearsTransparent = false
    self.title = "EarthVision AR"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
