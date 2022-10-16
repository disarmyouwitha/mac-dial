
import Foundation
import AppKit

class ScrollController: Controller
{
    var last_click = Date().timeIntervalSince1970
    var click_down = Date().timeIntervalSince1970
    
    enum Direction {
        case up
        case down
    }
    
    /*
    private func sendMouse(button direction: Direction)
    {
        let mousePos = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        
        let translatedMousePos = NSPoint(x: mousePos.x, y: screenHeight - mousePos.y)
        
        let event = CGEvent(mouseEventSource: nil, mouseType: direction == .down ? .leftMouseDown : .leftMouseUp, mouseCursorPosition: translatedMousePos, mouseButton: .left)
        
        event?.post(tap: .cghidEventTap)
    }
    */
    
    func onDown()
    {
        //sendMouse(button: .down)
        
        click_down = Date().timeIntervalSince1970
    }
    
    func onUp()
    {
        //sendMouse(button: .up)
        
        if(last_click != click_down)
        {
            var click_delay = Date().timeIntervalSince1970 - click_down
            
            // LONG CLICK:
            if (click_delay > 1.0)
            {
                // Get modes:
                let mode_list = UserDefaults.standard.string(forKey: "mode_list")!
                let mode_split = mode_list.components(separatedBy: "|")
                
                var sel = 0
                for i in stride(from: 0, to: mode_split.count, by: 1)
                {
                    let mode: String = mode_split[i]
                    
                    // MODE FOUND:
                    if(mode=="scrolling")
                    {
                        if(i+1 < mode_split.count)
                        {
                            sel = i+1
                        }
                    }
                }

                // Sound up when changing to Scrolling Mode
                HIDPostAuxKey(key: NX_KEYTYPE_SOUND_DOWN, modifiers: [], _repeat: 1)
                
                //  Change Mode to Scroll
                UserDefaults.standard.setValue(mode_split[sel], forKey: "mode")
                
                // Set Mode in Status bar App (?) Need to pass StatusBarController into here.
            }
            
            // Working.. uncomment after debug session above:
            
            /*
            click_delay = Date().timeIntervalSince1970 - last_click
            
            // DOUBLE CLICK:
            if (click_delay < 0.25)
            {
                // vol down on double click. (refine timer)
                HIDPostAuxKey(key: NX_KEYTYPE_SOUND_DOWN, modifiers: [], _repeat: 1)
            }
            
            // reset state variables:
            last_click = Date().timeIntervalSince1970
            click_down = last_click
             */
        }
    }
    
    var lastRotate: TimeInterval = Date().timeIntervalSince1970
    
    func onRotate(_ rotation: Dial.Rotation,_ scrollDirection: Int) {
        var steps = 0
        switch rotation {
        case .Clockwise(let d):
            steps = d
        case .CounterClockwise(let d):
            steps = -d
        }
        
        steps *= scrollDirection;
        
        let diff = (Date().timeIntervalSince1970 - lastRotate) * 1000
        let multiplifer = Int(1 + ((150 - min(diff, 150)) / 40))
        
        
        let event = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: Int32(steps * multiplifer), wheel2: 0, wheel3: 0)
        
        event?.post(tap: .cghidEventTap)
        
        lastRotate = Date().timeIntervalSince1970
    }
}
