import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var bridge: NativeBridge!

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMainMenu()

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.width, .height]

        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            showFatal("No display is available.")
            return
        }

        let visible = screen.visibleFrame
        let width = min(1180.0, visible.width * 0.88)
        let height = min(664.0, visible.height * 0.84)
        let frame = NSRect(
            x: visible.midX - width / 2,
            y: visible.midY - height / 2,
            width: width,
            height: height
        )

        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        window.title = "Wokyintosh"
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor(
            calibratedRed: 0.87,
            green: 0.84,
            blue: 0.77,
            alpha: 1.0
        )
        window.contentView = webView
        window.level = .normal
        window.collectionBehavior = [.moveToActiveSpace]

        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()

        guard
            let resourcesURL = Bundle.main.resourceURL,
            let indexURL = Bundle.main.url(
                forResource: "index",
                withExtension: "html",
                subdirectory: "Resources"
            )
        else {
            showFatal("Wokyintosh resources are missing.")
            return
        }

        webView.loadFileURL(indexURL, allowingReadAccessTo: resourcesURL)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        bridge = NativeBridge(webView: webView)
        bridge.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        bridge?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func showFatal(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Wokyintosh"
            alert.informativeText = message
            alert.alertStyle = .critical
            alert.runModal()
        }
    }

    private func buildMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenu.addItem(
            NSMenuItem(
                title: "Quit Wokyintosh",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
        )
        appMenuItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
    }
}
