
import Foundation
import AppKit

func send_key(_ keyCode: CGKeyCode, useCommandFlag: Bool)
{
    let sourceRef = CGEventSource(stateID: .combinedSessionState)

    if(sourceRef == nil) { return }

    let keyDownEvent = CGEvent(keyboardEventSource: sourceRef, virtualKey: keyCode, keyDown: true)
    
    if(useCommandFlag)
    {
        keyDownEvent?.flags = .maskCommand
    }

    let keyUpEvent = CGEvent(keyboardEventSource: sourceRef, virtualKey: keyCode, keyDown: false)
    keyDownEvent?.post(tap: .cghidEventTap)
    keyUpEvent?.post(tap: .cghidEventTap)
}

class ScrollController: Controller
{
    var last_click = Date().timeIntervalSince1970
    var click_down = Date().timeIntervalSince1970
    
    enum Direction
    {
        case up
        case down
    }
    
    func onDown()
    {
        click_down = Date().timeIntervalSince1970
    }
    
    func onUp()
    {
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
                
                //  Change Mode to Scroll
                UserDefaults.standard.setValue(mode_split[sel], forKey: "mode")
                
                // Set Mode in Status bar App (?) Need to pass StatusBarController into here.
            } else {
                click_delay = Date().timeIntervalSince1970 - last_click
                
                // DOUBLE CLICK:
                if (click_delay < 0.5)
                {
                    //HIDPostAuxKey(key: NX_KEYTYPE_MUTE, modifiers: [], _repeat: 1)
                } else {
                    // Alt+Tab
                    send_key(0x30, useCommandFlag: true)
                    
                    // Mac keycodes:
                    // https://stackoverflow.com/questions/10734349/simulate-keypress-for-system-wide-hotkeys/13004403#13004403
                    // https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
                }
                
                // reset state variables:
                last_click = Date().timeIntervalSince1970
                click_down = last_click
            }
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
