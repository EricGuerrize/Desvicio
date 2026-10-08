import AppKit

let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

NSColor(calibratedRed: 0.98, green: 0.97, blue: 0.91, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()

let ink = NSColor(calibratedRed: 0.17, green: 0.21, blue: 0.18, alpha: 1)
let mint = NSColor(calibratedRed: 0.78, green: 0.88, blue: 0.72, alpha: 1)
let coral = NSColor(calibratedRed: 0.94, green: 0.55, blue: 0.43, alpha: 1)

let body = NSRect(x: 144, y: 136, width: 736, height: 736)
let bodyPath = NSBezierPath(ovalIn: body)
mint.setFill()
bodyPath.fill()
ink.setStroke()
bodyPath.lineWidth = 16
bodyPath.stroke()

ink.setFill()
NSBezierPath(ovalIn: NSRect(x: 360, y: 535, width: 44, height: 88)).fill()
NSBezierPath(ovalIn: NSRect(x: 620, y: 535, width: 44, height: 88)).fill()

let smile = NSBezierPath()
smile.move(to: NSPoint(x: 420, y: 420))
smile.curve(
    to: NSPoint(x: 604, y: 420),
    controlPoint1: NSPoint(x: 462, y: 340),
    controlPoint2: NSPoint(x: 560, y: 340)
)
smile.lineWidth = 16
smile.lineCapStyle = .round
ink.setStroke()
smile.stroke()

let sparkle = NSBezierPath()
sparkle.move(to: NSPoint(x: 805, y: 780))
sparkle.line(to: NSPoint(x: 830, y: 837))
sparkle.line(to: NSPoint(x: 855, y: 780))
sparkle.line(to: NSPoint(x: 910, y: 755))
sparkle.line(to: NSPoint(x: 855, y: 730))
sparkle.line(to: NSPoint(x: 830, y: 673))
sparkle.line(to: NSPoint(x: 805, y: 730))
sparkle.line(to: NSPoint(x: 750, y: 755))
sparkle.close()
coral.setFill()
sparkle.fill()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Não foi possível gerar o ícone.")
}
let destination = URL(fileURLWithPath: "Desvicio/App/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
try png.write(to: destination)
