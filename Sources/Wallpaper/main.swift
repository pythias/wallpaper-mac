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

    @Key("-i", "--id", description: "Screen Id.")
    var id: Int?
    
    @Key("-p", "--path", description: "Wallpaper file location.")
    var path: String?
    
    func execute() throws {
        for screen in NSScreen.screens {
            let workspace = NSWorkspace.shared
            guard let options = workspace.desktopImageOptions(for: screen) else {
                return
            }
            
            let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int
            if number == id {
                try workspace.setDesktopImageURL(URL.init(fileURLWithPath: path ?? ""), for: screen, options: options)
                let json = JSON(["id": id ?? 0, "path" : path ?? ""])
                stdout <<< "\(json.rawString()!)"
                return;
            }
        }
        
        let json = JSON(["error": "Screen \(String(describing: id)) is not exists."])
        stdout <<< "\(json.rawString()!)"
    }
}

let wallpaper = CLI(name: "wallpaper")
wallpaper.commands = [
    GetCommand(),
    SetCommand(),
]
wallpaper.goAndExit()
