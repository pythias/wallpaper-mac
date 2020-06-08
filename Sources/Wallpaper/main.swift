import AppKit
import SwiftCLI
import SwiftyJSON

final class GetCommand: Command {
    let name = "get"

    func execute() throws {
        var screens: Array<Any> = []
        for screen in NSScreen.screens {
            let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
            let url = NSWorkspace.shared.desktopImageURL(for: screen)
            screens.append(["id": number, "path" : url?.absoluteString as Any])
        }
        let json = JSON(screens)
        stdout <<< "\(json.rawString()!)"
    }
}

final class SetCommand: Command {
    let name = "set"

    @Param var id: Int
    @Param var path: String

    func execute() throws {
        let options = [NSWorkspace.DesktopImageOptionKey: Any]()
        for screen in NSScreen.screens {
            let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
            if number == id {
                try NSWorkspace.shared.setDesktopImageURL(URL.init(fileURLWithPath: path), for: screen, options: options)
                let json = JSON(["id": id, "path" : path])
                stdout <<< "\(json.rawString()!)"
                return;
            }
        }
        
        stderr <<< "Error: screen \(id) is not exists."
    }
}

let wallpaper = CLI(name: "wallpaper")
wallpaper.commands = [
    GetCommand(),
    SetCommand(),
]
wallpaper.goAndExit()
