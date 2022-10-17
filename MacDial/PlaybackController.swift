

import Foundation
import AppKit

// https://stackoverflow.com/a/55854051
func HIDPostAuxKey(key: Int32, modifiers: [NSEvent.ModifierFlags], _repeat: Int = 1) {
    func doKey(down: Bool) {
        
        var rawFlags: UInt = (down ? 0xa00 : 0xb00);
        
        for modifier in modifiers {
            rawFlags |= modifier.rawValue
        }
        
        let flags = NSEvent.ModifierFlags(rawValue: rawFlags)
        
        let data1 = Int((key<<16) | (down ? 0xa00 : 0xb00))

        let ev = NSEvent.otherEvent(with: NSEvent.EventType.systemDefined,
                                    location: NSPoint(x:0,y:0),
                                    modifierFlags: flags,
                                    timestamp: 0,
                                    windowNumber: 0,
                                    context: nil,
                                    subtype: 8,
                                    data1: data1,
                                    data2: -1
                                    )
        let cev = ev?.cgEvent
        cev?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    for _ in 0..<_repeat {
        doKey(down: true)
        doKey(down: false)
    }

}

    /*
     #define NX_KEYTYPE_SOUND_UP        0
     #define NX_KEYTYPE_SOUND_DOWN      1
     #define NX_KEYTYPE_BRIGHTNESS_UP   2
     #define NX_KEYTYPE_BRIGHTNESS_DOWN 3
     #define NX_KEYTYPE_CAPS_LOCK       4
     #define NX_KEYTYPE_HELP            5
     #define NX_POWER_KEY               6
     #define NX_KEYTYPE_MUTE            7
     #define NX_UP_ARROW_KEY            8
     #define NX_DOWN_ARROW_KEY          9
     #define NX_KEYTYPE_NUM_LOCK        10

     #define NX_KEYTYPE_CONTRAST_UP     11
     #define NX_KEYTYPE_CONTRAST_DOWN   12
     #define NX_KEYTYPE_LAUNCH_PANEL    13
     #define NX_KEYTYPE_EJECT           14
     #define NX_KEYTYPE_VIDMIRROR       15

     #define NX_KEYTYPE_PLAY            16
     #define NX_KEYTYPE_NEXT            17
     #define NX_KEYTYPE_PREVIOUS        18
     #define NX_KEYTYPE_FAST            19
     #define NX_KEYTYPE_REWIND          20

     #define NX_KEYTYPE_ILLUMINATION_UP    21
     #define NX_KEYTYPE_ILLUMINATION_DOWN    22
     #define NX_KEYTYPE_ILLUMINATION_TOGGLE    23
     */

class PlaybackController : Controller
{
    var last_click = Date().timeIntervalSince1970
    var click_down = Date().timeIntervalSince1970
    var click_pressed = false
    var rotating = false
    
    func onDown()
    {
        click_down = Date().timeIntervalSince1970
        click_pressed = true
        
        // SEND HAPTIC FOR DOWNCLICK?
    }
    
    func onUp()
    {
        if(last_click != click_down)
        {
            var click_delay = Date().timeIntervalSince1970 - click_down
            
            // LONG CLICK:
            if(rotating == false)
            {
                
                if (click_delay > 100.0)
                {
                    // Do nothing.
                } else if (click_delay > 1.0)
                {
                    // Get modes:
                    let mode_list = UserDefaults.standard.string(forKey: "mode_list")!
                    let mode_split = mode_list.components(separatedBy: "|")
                    
                    var sel = 0
                    for i in stride(from: 0, to: mode_split.count, by: 1)
                    {
                        let mode: String = mode_split[i]
                        
                        // MODE FOUND:
                        if(mode=="playback")
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
                    
                    // DOUBLE CLICK: PLAY
                    if (click_delay < 0.5)
                    {
                        // To unmute first click:
                        HIDPostAuxKey(key: NX_KEYTYPE_MUTE, modifiers: [], _repeat: 1)
                        
                        HIDPostAuxKey(key: NX_KEYTYPE_PLAY, modifiers: [], _repeat: 1)
                    } else {
                        // SINGLE CLICK: MUTE
                        HIDPostAuxKey(key: NX_KEYTYPE_MUTE, modifiers: [], _repeat: 1)
                    }
                    
                    // reset state variables:
                    last_click = Date().timeIntervalSince1970
                    click_down = last_click
                }
                click_pressed = false
            }
        }
    }
    
    
    
    func onRotate(_ rotation: Dial.Rotation,_ scrollDirection: Int)
    {
        rotating = true
        
        let modifiers = [NSEvent.ModifierFlags.shift, NSEvent.ModifierFlags.option]
        
        switch (rotation) {
        case .Clockwise(let _repeat):
            if(click_pressed==true)
            {
                HIDPostAuxKey(key: NX_KEYTYPE_BRIGHTNESS_UP, modifiers: modifiers, _repeat: _repeat)
            } else {
                HIDPostAuxKey(key: NX_KEYTYPE_SOUND_UP, modifiers: modifiers, _repeat: _repeat)
            }
            break
        case .CounterClockwise(let _repeat):
            if(click_pressed==true)
            {
                HIDPostAuxKey(key: NX_KEYTYPE_BRIGHTNESS_DOWN, modifiers: modifiers, _repeat: _repeat)
            } else {
                HIDPostAuxKey(key: NX_KEYTYPE_SOUND_DOWN, modifiers: modifiers, _repeat: _repeat)
            }
            break
        }
        
        // Trick onUp to not call Long click when press & turn
        click_down = Date().timeIntervalSince1970-100
        rotating = false
    }
}
