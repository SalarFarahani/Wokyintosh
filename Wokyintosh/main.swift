import AppKit

autoreleasepool {
let app = NSApplication.shared
    let delegate = AppDelegate()

    app.setActivationPolicy(.regular)
    app.delegate = delegate
app.run()
}
