#NoEnv
#SingleInstance, Force
SetTitleMatchMode, 2
#MaxThreadsPerHotkey 2
SetWorkingDir, %A_ScriptDir%

global User := " "
global Server := " "
global startHOTKEY := "F1"
global stopHOTKEY := "F2"
global userserverHOTKEY := "F3"
global Running := false 
global AntiAFKEnabled := true  
global UserServers := {}
global UserServersList := ""
global namesandIDs := {}
global RadarStates := []
global radarKEY := "7"
global MultiAccEnabled := false  
global RadarWait := false 
global notFALSEpositive := false 
global FPcounter := 0
;global DBPixelCol := 0x000000
;global ShadesDiff := 2 

global count_Seconds := 0
global count_Mins := 0
global count_Hours := 0

global display_SessionTime := "00:00:00"
global display_Lifetime := "00:00:00"

global count_Lifetime_hours := 0
global count_Lifetime_mins := 0
global count_Lifetime_seconds := 0



IniRead, count_Lifetime_seconds, data.ini, ProgramSettings, timeS, %count_Lifetime_seconds%
IniRead, count_Lifetime_mins, data.ini, ProgramSettings, timeM, %count_Lifetime_mins%
IniRead, count_Lifetime_hours, data.ini, ProgramSettings, timeH, %count_Lifetime_hours%

IniRead, User, data.ini, usernames, user, %User%
IniRead, Server, data.ini, servers, server, %Server%


IniRead, MultiAccEnabled, data.ini, ProgramSettings, singlestate, %MultiAccEnabled%
IniRead, AntiAFKEnabled, data.ini, ProgramSettings, state, %AntiAFKEnabled%
IniRead, radarKEY, data.ini, UserSettings, rkey, %radarKEY%



IniRead, startHOTKEY, data.ini, UserSettings, startk, %startHOTKEY%
IniRead, stopHOTKEY, data.ini, UserSettings, stopk, %stopHOTKEY%
IniRead, userserverHOTKEY, data.ini, UserSettings, userserverk, %userserverHOTKEY%

Hotkey, %startHOTKEY%, StartMonitoring
Hotkey, %stopHOTKEY%, StopMonitoring
Hotkey, %userserverHOTKEY%, CoordRetriever

Gui, +AlwaysOnTop +Caption +Border +Resize MinSize362x220 +OwnDialogs

Gui, Add, Checkbox, gMultiAccChecker vMultiAccEnabledEdit, % "Multi Acc Setup"

Gui, Add, Text, vSessionTimeText xs+200, % "Session Time: " display_SessionTime
Lifetime_seconds_text := (count_Lifetime_seconds < 10) ? "0" . count_Lifetime_seconds : count_Lifetime_seconds
Lifetime_mins_text := (count_Lifetime_mins < 10) ? "0" . count_Lifetime_mins : count_Lifetime_mins
Lifetime_hours_text := (count_Lifetime_hours < 10) ? "0" . count_Lifetime_hours : count_Lifetime_hours
display_Lifetime := Lifetime_hours_text . ":" . Lifetime_mins_text . ":" . Lifetime_seconds_text
Gui, Add, Text, vLifetimeText xs+200, % "Lifetime: " display_Lifetime

Gui, Add, Text, vUserServerText,% "Usernames + Servers:"                                           ; structured just as the GUI will display so thats nice
Gui, Add, DropDownList, vUserServerEdit gSaveData w150 xs ys+40
Gui, Add, Text, vRadarText, % "Radar Key:"
Gui, Add, Hotkey, vradarKEYEdit gSaveHotkeys w150 xs ys+80, %radarKEY%  
Gui, Add, Checkbox, gSaveData vAntiAFKEnabledEdit xs ys+110, % "Anti AFK-Kick:" 
Gui, Add, Button, vstartB gStartMonitoring w100 h27 xs ys155.5, % "(" . startHOTKEY . ")" "`nStart Monitoring"
Gui, Add, Button, vstopB gStopMonitoring w100 h27 xs100 ys155.5, % "(" . stopHOTKEY . ")" "`nStop Monitoring"
Gui, Add, Button, vhotkeySettingsB gHotkeySettingsGUI w100 h27 xs200 ys155.5, Hotkeys 

Gui, Add, Text, vUserText,% "Username:"
Gui, Add, Edit, vUserEdit gSaveData w150 xs ys+40, %User%

Gui Add, Text, vServerText, % "Server:"
Gui, Add, Edit, vServerEdit gSaveData w150 xs ys+80, %Server%

GuiControl,, AntiAFKEnabledEdit, %AntiAFKEnabled% 
GuiControl,, MultiAccEnabledEdit, %MultiAccEnabled% 

Menu, FormMenu, Add, Delete, MenuDeleteHandler
if MultiAccEnabled {
    GuiControl, Move, UserServerText, % "x" 10 "y" 30 
    GuiControl, Hide, UserText
    GuiControl, Hide, ServerText
    GuiControl, Hide, UserEdit 
    GuiControl, Hide, ServerEdit 
    Gui, Show,w362 h220, % "DB Alerter (NOT monitoring...)"  
} else {
    GuiControl, Hide, UserServerText
    GuiControl, Hide, UserServerEdit
    GuiControl, Hide, RadarText 
    GuiControl, Hide, radarKEYEdit
    GuiControl, Move, UserText, % "x" 10 "y" 30  
    GuiControl, Move, UserEdit, % "x" 10 "y" 45
    GuiControl, Move, ServerText, % "x" 10 "y" 70 
    GuiControl, Move, ServerEdit, % "x" 10 "y" 85 

    ;GuiControl, Move, RadarText, % "x" 10 "y" 105 
    ;GuiControl, Move, radarKEYEdit, % "x" 10 "y" 120 
    
    GuiControl, Move, AntiAFKEnabledEdit, % "x" 10 "y" 115  
    
    GuiControl, Move, startB, % "x" 10 "y" 160.5
    GuiControl, Move, stopB, % "x" 110 "y" 160.5
    GuiControl, Move, hotkeySettingsB, % "x" 210 "y" 160.5
    
    GuiControl, Show, UserText 
    GuiControl, Show, UserEdit  
    GuiControl, Show, ServerText
    GuiControl, Show, ServerEdit 
    Gui, Show,w362 h220, % "DB Alerter  (NOT monitoring...)"    
}


GuiIcon := DllCall("LoadImage", "Ptr", 0, "Str", "DB-seeker-pfp.ico","UInt",1, "Int", 64, "Int", 64, "UInt", 0x10, "Ptr") ; Rewrite these to something simpler in AHK v2 
TaskbarIcon := DllCall("LoadImage", "Ptr", 0, "Str", "DB-seeker-pfp.ico","UInt",1, "Int", 64, "Int", 64, "UInt", 0x10, "Ptr")

SendMessage, 0x80, 0, GuiIcon,, A
SendMessage, 0x80, 1, TaskbarIcon,, A
Menu, Tray, Icon, DB-seeker-pfp.ico

Gui, 2:New, +AlwaysOnTop +Caption +Border +Resize MinSize225x125  ;Hotkey GUI
Gui, 2:Add, Text,, Start Hotkey: 
Gui, 2:Add, Hotkey, vStartHotkey gSaveHotkeys w80, %startHOTKEY%
Gui, 2:Add, Text,, Stop Hotkey: 
Gui, 2:Add, Hotkey, vStopHotkey gSaveHotkeys w80, %stopHOTKEY%
Gui, 2:Add, Text,, Add UserServer Hotkey: 
Gui, 2:Add, Hotkey, vUserServerHotkey gSaveHotkeys w80, %userserverHOTKEY%

global startHOTKEYPrev := startHOTKEY
global stopHOTKEYPrev := stopHOTKEY 
global UserServerHOTKEYPrev := userserverHOTKEY
global radarKEYPrev := radarKEY 

return ;----------------------------------------------------------SET UP ENDS HERE-------------------------------------------------------------------

SessionTracker:
    count_Seconds += 1
    if (count_Seconds = 60) {
        count_Mins += 1
        count_Seconds := 0
        if (count_Mins = 60) {
            count_Hours += 1 
            count_Mins := 0 
        }
    }
    if !Running {
        SetTimer, SessionTracker, Off 
        
        Session_seconds_text := (count_Seconds < 10) ? "0" . count_Seconds : count_Seconds
        Session_mins_text := (count_Mins < 10) ? "0" . count_Mins : count_Mins
        Session_hours_text := (count_Hours < 10) ? "0" . count_Hours : count_Hours
        display_SessionTime := Session_hours_text . ":" . Session_mins_text . ":" Session_seconds_text
        
        count_Lifetime_seconds += count_Seconds
        toAddMins := count_Lifetime_seconds // 60
        leftoverSeconds := Mod(count_Lifetime_seconds, 60)
        count_Lifetime_seconds := leftoverSeconds 
        
        count_Lifetime_mins := count_Lifetime_mins + toAddMins + count_Mins
        toAddHours := count_Lifetime_mins // 60
        leftoverMins := Mod(count_Lifetime_mins, 60)
        count_Lifetime_mins := leftoverMins 
        count_Lifetime_hours := count_Lifetime_hours + toAddHours + count_Hours

        Lifetime_seconds_text := (count_Lifetime_seconds < 10) ? "0" . count_Lifetime_seconds : count_Lifetime_seconds
        Lifetime_mins_text := (count_Lifetime_mins < 10) ? "0" . count_Lifetime_mins : count_Lifetime_mins
        Lifetime_hours_text := (count_Lifetime_hours < 10) ? "0" . count_Lifetime_hours : count_Lifetime_hours
        
        display_Lifetime := Lifetime_hours_text .  ":" . Lifetime_mins_text . ":" . Lifetime_seconds_text

        GuiControl,, SessionTimeText, % "Session Time: " display_SessionTime
        GuiControl,, LifetimeText, % "Lifetime: " display_Lifetime


        IniWrite, %count_Lifetime_seconds%, data.ini, ProgramSettings, timeS 
        IniWrite, %count_Lifetime_mins%, data.ini, ProgramSettings, timeM
        IniWrite, %count_Lifetime_hours%, data.ini, ProgramSettings, timeH  
    }
return 

MultiAccChecker:
    GoSub, SaveData 
    Gui, Hide 
    if MultiAccEnabled {
        GuiControl, Move, UserServerText, % "x" 10 "y" 30 
        GuiControl, Hide, UserText
        GuiControl, Hide, ServerText
        GuiControl, Hide, UserEdit 
        GuiControl, Hide, ServerEdit

        GuiControl, Move, RadarText, % "x" 10 "y" 70 
        GuiControl, Move, radarKEYEdit, % "x" 10 "y" 85 
        
        GuiControl, Move, AntiAFKEnabledEdit, % "x" 10 "y" 115  
        
        GuiControl, Move, startB, % "x" 10 "y" 160.5
        GuiControl, Move, stopB, % "x" 110 "y" 160.5
        GuiControl, Move, hotkeySettingsB, % "x" 210 "y" 160.5

        GuiControl, Show, UserServerText 
        GuiControl, Show, UserServerEdit 
        GuiControl, Show, RadarText 
        GuiControl, Show, radarKEYEdit 
        Gui, Show,w362 h220, % "DB Alerter  (NOT monitoring...)"
        Hotkey, %userserverHOTKEY%, On     
    } else {  
        GuiControl, Hide, UserServerText
        GuiControl, Hide, UserServerEdit
        GuiControl, Hide, RadarText 
        GuiControl, Hide, radarKEYEdit
        GuiControl, Move, UserText, % "x" 10 "y" 30  
        GuiControl, Move, UserEdit, % "x" 10 "y" 45
        GuiControl, Move, ServerText, % "x" 10 "y" 70 
        GuiControl, Move, ServerEdit, % "x" 10 "y" 85 

        ;GuiControl, Move, RadarText, % "x" 10 "y" 105 
        ;GuiControl, Move, radarKEYEdit, % "x" 10 "y" 120 
        
        GuiControl, Move, AntiAFKEnabledEdit, % "x" 10 "y" 115  
        
        GuiControl, Move, startB, % "x" 10 "y" 160.5
        GuiControl, Move, stopB, % "x" 110 "y" 160.5
        GuiControl, Move, hotkeySettingsB, % "x" 210 "y" 160.5
       
        GuiControl, Show, UserText 
        GuiControl, Show, UserEdit  
        GuiControl, Show, ServerText
        GuiControl, Show, ServerEdit 
        Gui, Show,w362 h220, % "DB Alerter  (NOT monitoring...)"    
        Hotkey, %userserverHOTKEY%, Off 
    }
    
return 

HotkeyStates(State){
    Hotkey, %startHOTKEY%, %State% 
    Hotkey, %stopHOTKEY%, %State% 
    Hotkey, %userserverHOTKEY%, %State% 
}

UglyCode: ; Not needed for now, but keeping for the future...
    CoordMode, Mouse, Window 
    MouseGetPos, RnX, RnY  
    RnX -= 10
    RnY -= 35    
    
    OnGuiElement(RnX, RnY, elementEditX, elementEditY, elementEditW, elementEditH) {
        if ((RnX - elementEditX) < (elementEditW +45) && (RnX - elementEditX) > (-45) && (RnY - elementEditY) < (elementEditH + 45) && (RnY - elementEditY) > (-45)){
            ;MsgBox,0x40000,, % "Touching GUI element"
            ;HotkeyStates("Off")
            return true      
 
        } else {
            ;HotkeyStates("On")
            return false 
        }
    }

    if  OnGuiElement(RnX, RnY, UserEditX, UserEditY, UserEditW, UserEditH) || OnGuiElement(RnX, RnY, ServerEditX, ServerEditY, ServerEditW, ServerEditH) {
        ;MsgBox,0x40000,, % "Touching GUI element"
        HotkeyStates("Off")
    } else {
        HotkeyStates("On")
    }         
return 



HotkeySettingsGUI:
     WinSet, AlwaysOnTop, Off, % "DB Alerter  (NOT monitoring...)"
     SetTimer, UglyCode, Off 
     Gui, 2:Show,, Hotkeys
     HotkeyStates("Off") 
return 

2GuiClose:
    Gui, 2:Hide
    HotkeyStates("On") 
    ;SetTimer, UglyCode, On 
    WinSet, AlwaysOnTop, On, % "DB Alerter  (NOT monitoring...)" 
return 

RevertHotkeys:  
    GuiControl, 2:, StartHotkey, %StartHOTKEYPrev%
    startHOTKEY := StartHOTKEYPrev 
    GuiControl, 2:, StopHotkey, %StopHOTKEYPrev%
    stopHOTKEY := StopHOTKEYPrev
    GuiControl, 2:, UserServerHotkey, %UserServerHOTKEYPrev%
    userserverHOTKEY := UserServerHOTKEYPrev
    GuiControl, 1:, radarKEYEdit, %radarKEYPrev%
    radarKEY := radarKEYPrev

return 

SaveHotkeys:        
    Gui, 2:Submit, NoHide
    Gui, 1:Submit, NoHide 
                               
    HotkeySet := [StartHotkey, StopHotkey, UserServerHotkey, radarKEYEdit] 
    for _,hkey in HotkeySet {
        if (hkey = "" or hkey = " ") || (hkey = "!" or hkey = "^" or hkey = "+" or hkey = "^!"){
            Goto, RevertHotkeys 
            ;MsgBox,0x40000, % " "

        }
    }  
    ;no native AlphaNum checker, so gotta do it myself 
    ;MsgBox,0x40000,, % StartHotkey 
    HotkeySetAll := [StartHotkey, StopHotkey, UserServerHotkey, radarKEYEdit]
    i_start := 1   ; works based on a (n(n-1))/ 2 formula of comparisons for checking duplicates rather than doing n^2 (Basically sigma summmation)  
    while (i_start < (HotkeySetAll.Length())){
        i_end := HotkeySetAll.Length()
        while (i_end > i_start) {
            if HotkeySetAll[i_start] = HotkeySetAll[i_end] {
                Gosub, RevertHotkeys
                Gui +Disabled 
                MsgBox,0x40030,% "Duplicate Hotkey", % "Hotkey already in use!", 1.3
                Gui -Disabled 
                return 
            }  
            i_end -= 1
        }
        i_start += 1
    }
    
    startHOTKEY := StartHotkey
    stopHOTKEY := StopHotkey 
    userserverHOTKEY := UserServerHotkey
    radarKEY := radarKEYEdit 
    
    StartHOTKEYPrev := startHOTKEY 
    StopHOTKEYPrev := stopHOTKEY 
    UserServerHOTKEYPrev := userserverHOTKEY
    radarKEYPrev := radarKEY   
    
    IniWrite, %startHOTKEY%, data.ini, UserSettings, startk
    IniWrite, %stopHOTKEY%, data.ini, UserSettings, stopk
    IniWrite, %userserverHOTKEY%, data.ini, UserSettings, userserverk
    IniWrite, %radarKEY%, data.ini, UserSettings, rkey 

    Hotkey, %startHOTKEY%, StartMonitoring, Off 
    Hotkey, %stopHOTKEY%, StopMonitoring, Off 
    Hotkey, %userserverHOTKEY%, CoordRetriever, Off 


    GuiControl, 1:, startB,% "(" . startHOTKEY . ")" "`nStart Monitoring"
    GuiControl, 1:, stopB, % "(" . stopHOTKEY . ")" "`nStop Monitoring"
 
return

~RButton::
    CoordMode, Mouse, % "DB Alerter NOT monitoring...)"
    MouseGetPos, mx, my 
    GuiControlGet, UserServerEdit, Pos
    if ((mx - UserServerEditX) < UserServerEditW && (mx - UserServerEditX) > 0 && (my - UserServerEditY) < UserServerEditH && (my - UserServerEditY) > 0){
        Menu, FormMenu, Show    
    }
    
    ;ToolTip % "MouseX:" mx  "MouseY:" my "`nFormX:" UserServerEditX "FormY:" UserServerEditY    


return

MenuDeleteHandler:   ; Deletes the current form/slot thats selected on the GUI
    Gui, Submit, NoHide
    selected := UserServerEdit
    
    
    if (selected = "")
        return
    ThePID := namesandIDs[selected]
    ;MsgBox,0x40000,, % ThePID " UserServer count: " UserServers.Count()
    namesandIDs.Delete(selected)
    UserServers.Delete(ThePID)
    ;MsgBox,0x40000,, % UserServers.Count()

       ; MsgBox % UserServersList                 ; Because of the variable evaluation quirks of ahkv1, its best NOT to use a function here.  
    if InStr(UserServersList, selected . "||"){  ; Prevents the top item from being blank       
        if InStr(UserServersList, "|" . selected . "||"){  ; the condition to decide who gets PROMOTED
            UserServersList := StrReplace(UserServersList, selected . "||")
            UserServersList := StrReplace(UserServersList, UserServersList, UserServersList . "|")
        } else { ; if the selected item is at the bottom or not at the top of the list
            UserServersList := StrReplace(UserServersList, selected . "||")
            UserServersList := StrReplace(UserServersList, "|", "||",,1)  ; StrReplaces from L -> R , so first occurence is the the one at front 
        }
    } else {
        UserServersList := StrReplace(UserServersList, "||", "|")
        if InStr(UserServersList, "|" . selected . "|"){ ; if its not the top item
            UserServersList := StrReplace(UserServersList, selected . "|", "|")
        } else {
            UserServersList := StrReplace(UserServersList, selected . "|")
            UserServersList := StrReplace(UserServersList, "|","||",,1)
        
        }
    } 

    ;MsgBox % UserServersList
    GuiControl,, UserServerEdit, |%UserServersList%

return

CoordRetriever:
    CoordMode, Mouse, Screen 
    MouseGetPos, windowx, windowy
    MouseClick, left 
    WinGet, roblox_winID, PID, A
    MsgBox,0x40000, SUCCESS, Coords Saved!,1  ; 0x40000 means AlwaysOnTop
    ;LastHotkey := A_ThisHotkey
   ; MsgBox % "You pressed: " LastHotkey 
    ;MsgBox % name_component
    Goto, CoordAssigner
return 

CoordAssigner:    
    WinSet, AlwaysOnTop, Off, % "DB Alerter  (NOT monitoring...)"
    Gui, +Disabled
    SetTimer, UglyCode, Off 
    HotkeyStates("Off")
    if (UserServers[roblox_winID] != ""){
        MsgBox,0x40030,% "DUPLICATE", % "Roblox window already saved! Delete the username associated with it in the list", 2
        Gui, -Disabled
        HotkeyStates("On")
        Gui, Show 
        return
    }
    Sleep, 500
    InputBox, IG_user, Name Confirmation, % "Enter your roblox username for this window",, 200, 125
    Gui, Show
    Sleep, 500 
    InputBox, IG_server, Name Confirmation, % "Enter the server name for this window",, 200, 125
    
    HotkeyStates("On")
    ;SetTimer, UglyCode, On
    Gui, -Disabled
    WinSet, AlwaysOnTop, On, % "DB Alerter  (NOT monitoring...)"
    

    if (ErrorLevel = 1) {
        ; clicked Cancel
        return
    }
    IG_user := StrReplace(IG_User," ","")
    ;IG_server := StrReplace(IG_server," ","")

    if (IG_user = "" or IG_server = "") {
        ; clicked OK but left it blank
        MsgBox,0x40030,, % "Please dont leave any field blank", 1
        Goto, CoordAssigner
        return
    }
    userServerItem := IG_user . "-" .  IG_server

    if (InStr(UserServersList, userServerItem . "|")){
        MsgBox,0x40000, Moron Detected, % "DUPLICATES ARE DISALLOWED FOOL", 1
        Goto, CoordAssigner
        return 
    } 
                        
    UserServers[roblox_winID] := {}
    UserServers[roblox_winID]["coords"] := [windowx, windowy]
   ; MsgBox,0x40000,, % UserServers[roblox_winID]["coords"][1] " and " UserServers[roblox_winID]["coords"][2]
    UserServers[roblox_winID]["userserver"] := [IG_user, IG_server]
    namesandIDs[userServerItem] := roblox_winID 
     
    ;MsgBox % UserServersList
    if InStr(UserServersList, "||"){
        UserServersList := StrReplace(UserServersList, "||", "|")
    }
    UserServersList .= userServerItem . "||"
    ;MsgBox % UserServersList
    GuiControl,, UserServerEdit, |%UserServersList%
    
return 

SaveData:
    Gui Submit, NoHIde 

    User := UserEdit 
    Server := ServerEdit
    AntiAFKEnabled := AntiAFKEnabledEdit 
    MultiAccEnabled := MultiAccEnabledEdit 
    
    IniWrite, %User%, data.ini, usernames, user 
    IniWrite, %Server%, data.ini, servers, server  
    IniWrite, %AntiAFKEnabled%, data.ini, ProgramSettings, state    
    IniWrite, %MultiAccEnabled%, data.ini, ProgramSettings, singlestate  

return 

StartMonitoring:
    ;if !WinExist("Roblox"){
    ;    MsgBox, Please have the roblox window open.
    ;    return
    ;}
    if (UserServersList = "" && MultiAccEnabled){
        MsgBox,0x40030,% "DB Alerter",% "Please add your roblox user + server to the list before starting (Hover your mouse over the roblox window(s) and press F3)"
        return 
    } else if ((User = "" or Server = "") && (MultiAccEnabled = false)){
        MsgBox,0x40030,% "DB Alerter",% "Please type your roblox user + server into the fields before starting"
        return 
    }
    DBPixelCol := MultiAccEnabled ? 0xF3E145 : 0xDBCF39  ;0xDBCF39  ;potential 0xF3E145 ;Peak POTENTIAL? FBE045 ;PEAK gem 0xF6E244 ; FAKE gem 0xE9E25C   ;0xDBCF39 (full screen)
    ShadeDiff := MultiAccEnabled ? 3 : 3
    Running := true 
    RadarWait := false 
    SetTimer, SessionTracker, 1000
    Gui, Hide 
    Gui, Show,, % "DB Alerter  (MONITORING!)"
    Sleep, 500
    Gui, Minimize
    notFALSEpositive := false 
    Sleep, 1000
    RadarWaitON := 0 
    FPcounter := 0
    if !MultiAccEnabled { 
        WinMaximize, Roblox
    }
    GoSub, AccountOnlineStatus
    if (AntiAFKEnabled) {
        SetTimer, AntiAFK, 420000  ; 7 mins
    } 
    SetTimer, DBPixelFinder, 20
return

StopMonitoring:
    Running := false 
    
    Gui, Hide
    Gui, Show,, % "DB Alerter  (NOT monitoring...)"
    SetTimer, AntiAFK, Off
    SetTimer, DBPixelFinder, Off
    GoSub, AccountOnlineStatus
    count_Seconds := 0 
    count_Mins := 0 
    count_Hours := 0 
    ;SetTimer, UglyCode, On             
return 

AntiAFK:
    if (!Running) {
        return 
    }
    if (MultiAccEnabled) {

        UserServerReform := StrReplace(UserServersList, "||", "|")
        UserServerSplit := StrSplit(UserServerReform, "|")
        for US_index in UserServerSplit {
            PID_Ret := namesandIDs[UserServerSplit[US_index]]
            X_coord := UserServers[PID_Ret]["coords"][1]
            Y_coord := UserServers[PID_Ret]["coords"][2]
            CoordMode, Mouse, Screen 
            MouseMove, X_coord, Y_coord
            Sleep, 400
            MouseClick, Left
            Send, {m}
            Sleep, 1000
            Send, {m}
            Sleep, 1500    
        } 
            ;MsgBox,0x40000,,% "Pixel Found"
    }  else {
        CoordMode, Mouse, Screen 
        MouseMove, A_ScreenWidth/6, 50
        Sleep, 250
        MouseClick, Left 
        Send, {m}
        Sleep, 800
        Send, {m} 
    }

return 

AlertTheBoys: 
    try {
        disc_webhook := "nuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uh"
        json := "{""content"":""@everyone DB located in SERVER_NAME by PLAYER""}"
        everyone_ping := "{""content"":""@everyone""}"
        if MultiAccEnabled {
            json := StrReplace(json, "SERVER_NAME by PLAYER", UserServers[DB_PID]["userserver"][2] . " by " . UserServers[DB_PID]["userserver"][1])
        } else {
            json := StrReplace(json, "SERVER_NAME by PLAYER", User . " by " . Server )
        }
        alerter := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        alerter.Open("POST", disc_webhook, false)
        alerter.SetRequestHeader("Content-Type", "application/json")
        alerter.SetTimeouts(7000,7000,7000,7000)
        alerter.Send(json)
        loop 4 {
            alerter.Send(everyone_ping)
        }
    } catch e {
        MsgBox,0x40010,DB-Alerter, % "Could not send DB notifs to discord.`nCheck your internet connection."
    }
return 

AccountOnlineStatus:          
    try { 
        disc_webhook := "nuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uhnuh-uh-nuh-uh"
        json_base := Running ? "{""content"":"":green_circle: PLAYER is ACTIVE in SERVER_NAME""}" : "{""content"":"":red_circle: PLAYER is INACTIVE in SERVER_NAME""}"
        onlineStatus := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        onlineStatus.Open("POST", disc_webhook, false)
        onlineStatus.SetRequestHeader("Content-Type", "application/json")
        onlineStatus.SetTimeouts(7000,7000,7000,7000)
        if MultiAccEnabled {
            for RoID,_ in UserServers {
                if Running {
                    json := StrReplace(json_base, "PLAYER is ACTIVE in SERVER_NAME", UserServers[RoID]["userserver"][1] . " is ACTIVE in " . UserServers[RoID]["userserver"][2])
                } else {    
                    json := StrReplace(json_base, "PLAYER is INACTIVE in SERVER_NAME", UserServers[RoID]["userserver"][1] . " is INACTIVE in " . UserServers[RoID]["userserver"][2])
                }
                onlineStatus.Send(json)

            }
            
        } else {
            if Running {
                json := StrReplace(json_base, "PLAYER is ACTIVE in SERVER_NAME", User . " is ACTIVE in " . Server )
            } else {
                json := StrReplace(json_base, "PLAYER is INACTIVE in SERVER_NAME", User . " is INACTIVE in " . Server )
            }
            onlineStatus.Send(json)
        }
    } catch e { 
        MsgBox,0x40010,DB-Alerter, % "Could not send notifs to discord.`nCheck your internet connection."
    }
return 

distanceBetween(x1, y1, x2, y2){
    return Sqrt(((y2 - y1)**2) + ((x2 - x1)**2))

}

DBPixelFinder:  
    if (!Running) {
        return 
    }
    ;MsgBox,0x40000,, % DBPixelCol  "and" ShadeDiff, 1
    CoordMode, Pixel, Screen 
    CoordMode, Mouse, Screen 
    PixelSearch, px, py
    , 0, 0  
    , A_ScreenWidth , A_ScreenHeight 
    , DBPixelCol  
    , ShadeDiff
    , Fast RGB       
    if (ErrorLevel = 0) {
        MouseGetPos, fm1, fm2 
        MouseMove, px, py
        Sleep, 250  ;reducio perhaps
        MouseClick, Left
        WinGetPos, oX, oY, oW, oH, Roblox
        CoordMode, Mouse, Window       
        MouseGetPos, m1, m2
        if ((m1/oW) > 0.75 && (m1/oW) < 1) && ((m2/oH) < 0.41 && (m2/oH) > 0) { ; it seems we need to expand widths.. (check firstly)
            if ((FPcounter < 1) && !(notFALSEpositive)) {
                Checkm1 := m1 
                Checkm2 := m2 
                TimeOfCoords := A_TickCount
                ;MsgBox, 0x40000,, % TimeOfCoords " and " notFALSEpositive, 1
            }
            if (notFALSEpositive = true) {
                if MultiAccEnabled {
                    WinGet, DB_PID, PID, A
                    RadarWaitON += 1  
                    GoSub, RadarOff
                } else {
                    GoSub, SingleDetectWait 
                }
                Gosub, AlertTheBoys                        
            } else {
                if (FPcounter > 0 && ((A_TickCount - TimeOfCoords) < 10000)) {
                    Threshold := distanceBetween(m1, m2, Checkm1, Checkm2)
                    if (Threshold < 7) {
                        notFALSEpositive := true
                    } else {
                        MsgBox,0x40000,, % "False Pos DETECTED", 1
                        Sleep, 3000
                    }
                    FPcounter := 0 
                } else {
                    FPcounter += 1
                    FPcounter := ((A_TickCount - TimeOfCoords) > 10000) ? 0 : FPcounter
                }
                Sleep, 500
                return 
            }
    
     
            if (RadarWaitON < 2 && MultiAccEnabled){
                SetTimer, RadarOn, 3600000
            }
            ;MsgBox,0x40000,,% "Pixel Found"
        }
    }
return 

SingleDetectWait:
    RadarWait := RadarWait ? false : true 
    if RadarWait{
        SetTimer, DBPixelFinder, Off 
        SetTimer, SingleDetectWait, 3600000
    } else {
        SetTimer, DBPixelFinder, On  
        SetTimer, SingleDetectWait, Off 
    }
return 

RadarOff:
    SetTimer, DBPixelFinder, Off 
    RadarStates.Push(DB_PID)
    Sleep, 250
    Send, %radarKEY%
    Sleep, 250  
    SetTimer, DBPixelFinder, On 
return 

RadarOn:
    for _,rblxIDs in RadarStates {
        Radar_X := UserServers[rblxIDs]["coords"][1] 
        Radar_Y := UserServers[rblxIDs]["coords"][2]
        CoordMode, Mouse, Screen 
        MouseMove, Radar_X, Radar_Y
        Sleep, 250 
        MouseClick, Left
        Sleep, 250 
        Send, %radarKEY% 
        Sleep, 1500
    }
    RadarWaitON := 0 
    RadarStates := []
    SetTimer, RadarOn, Off  
return 

GuiClose:
ExitApp 

