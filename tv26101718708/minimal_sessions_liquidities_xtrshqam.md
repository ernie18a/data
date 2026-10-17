# Minimal Sessions Liquidities

- url: https://www.tradingview.com/script/xTRshqAM-Minimal-Sessions-Liquidities/
- type: indicator
- pine_id: PUB;e8da79bcfa0b4c7e9c3a850e26efcd4c
- version: 2.0

## Description

Description

The Session Liquidities indicator is an advanced, automated toolkit for traders who rely on time-based liquidity sweeps and daily structural levels. It automatically highlights the high and low price points for the most actively traded sessions in the market and tracks them dynamically.

Instead of manually drawing horizontal rays across your chart every day, this script does the heavy lifting by identifying the highs and lows of six distinct timeframes (all strictly mapped to Eastern Time / New York Time) and carrying them forward until they are interacted with.

🕒 Sessions Tracked
The engine tracks liquidity boundaries for the following key windows:

Asian Session (AS): 20:00 - 00:00 ET
London Session (LN): 02:00 - 05:00 ET
New York AM Session (NY AM): 09:30 - 11:30 ET
New York Lunch Session (NY LN): 12:00 - 13:00 ET
New York PM Session (NY PM): 13:30 - 16:30 ET
Current Day (CD): 18:00 - 16:55 ET

✨ Key Features
Dynamic Liquidity Extensions: Once a session closes, its high and low lines are automatically extended forward into future price action, acting as pristine liquidity magnets.
Stop When Swept: An optional setting allows you to stop drawing the liquidity line exactly on the candle where the price eventually sweeps (crosses) it. This prevents your chart from being cluttered by old, invalidated liquidity levels.
Previous Day (PD) Memory: The script remembers historical session data. When a new day begins, the script automatically re-labels the previous day's untouched levels to "PD" (e.g., PD AS H for Previous Day Asian High), or D-2 for older levels.
Smart Overlap Merging: It's very common for two sessions to share the exact same high or low. To keep your charts incredibly sleek, the engine actively scans for overlapping labels. If two liquidity pools rest at the exact same tick, it merges their labels into a single comma-separated text (e.g., Current Day High, AS L) and removes the redundant visual clutter.
Customizable Lookback: Control exactly how many historical days of liquidity you want to track (up to 40 days) to match your trading style without overwhelming your screen.

⚙️ Settings
Sessions to Show: Toggle any of the 6 individual sessions on or off.
Session Colors: Fully customize the color of the lines and labels for each specific session.
Lookback Limit: Adjust how many historical periods are kept on the chart (1 = Current Only, 2 = Current + Previous Day).
Stop Lines When Swept: Toggle whether the line should extend indefinitely or terminate upon contact with price.
Label Size: Change the typography size (defaults to Tiny for a professional, unobtrusive aesthetic).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Minimal Session Liquidities", shorttitle="SL", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Settings ---
grp_sess = "Sessions to Show"
show_AS    = input.bool(true, "Show Asian Session (AS)", group=grp_sess)
show_LN    = input.bool(true, "Show London Session (LN)", group=grp_sess)
show_NY_AM = input.bool(true, "Show NY AM Session", group=grp_sess)
show_NY_LN = input.bool(true, "Show NY Lunch Session", group=grp_sess)
show_NY_PM = input.bool(true, "Show NY PM Session", group=grp_sess)
show_CD    = input.bool(true, "Show Current Day (CD)", group=grp_sess)

grp_col = "Session Colors"
col_AS     = input.color(color.new(#2196F3, 0), "AS Color", group=grp_col)
col_LN     = input.color(color.new(#FF9800, 0), "LN Color", group=grp_col)
col_NY_AM  = input.color(color.new(#4CAF50, 0), "NY AM Color", group=grp_col)
col_NY_LN  = input.color(color.new(#FFEB3B, 0), "NY LN Color", group=grp_col)
col_NY_PM  = input.color(color.new(#F44336, 0), "NY PM Color", group=grp_col)
col_CD     = input.color(color.new(#9E9E9E, 0), "CD Color", group=grp_col)

grp_opts = "Options"
stop_swept = input.bool(false, "Stop lines when swept (Price crosses level)", group=grp_opts)
label_size_str = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_opts)

string tz = "America/New_York"
string t_AS    = "2000-0000"
string t_LN    = "0200-0500"
string t_NY_AM = "0930-1130"
string t_NY_LN = "1200-1300"
string t_NY_PM = "1330-1630"
string t_CD    = "1800-1655"

// Global Trading Day calculation (starts at 17:00 NY time)
int shiftedTime = time + 7 * 60 * 60 * 1000
int currentDayId = year(shiftedTime, tz) * 10000 + month(shiftedTime, tz) * 100 + dayofmonth(shiftedTime, tz)
var int lastDayId = currentDayId
var int currentTradingDayCount = 0

if currentDayId != lastDayId
    currentTradingDayCount += 1
    lastDayId := currentDayId

// Function to convert string size to Pine size
get_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.tiny

// Helper Types
type SessionLine
    line lineHigh
    line lineLow
    label lblHigh
    label lblLow
    float highLevel
    float lowLevel
    bool highSwept
    bool lowSwept
    int startBar
    string baseTextHigh = ""
    string baseTextLow = ""
    int sessionStartTD = 0
    int lastAge = -1

type SessionData
    SessionLine[] history
    bool inSession

method processSession(SessionData s, string sessionStr, bool show, color col, string nameHigh, string nameLow, bool stopSwept, string lblSizeStr) =>
    if show
        bool inSessionNow = not na(time(timeframe.period, sessionStr, tz))
        bool sessionStart = inSessionNow and not s.inSession
        
        lbl_sz = get_size(lblSizeStr)
        
        if sessionStart
            SessionLine newSess = SessionLine.new(
                 na, na, na, na, 
                 high, low, false, false, bar_index,
                 nameHigh, nameLow, currentTradingDayCount, -1
             )
             
            newSess.lineHigh := line.new(bar_index, high, bar_index, high, color=col, style=line.style_solid)
            newSess.lineLow := line.new(bar_index, low, bar_index, low, color=col, style=line.style_solid)
            
            newSess.lblHigh := label.new(bar_index, high, text=nameHigh, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=lbl_sz)
            newSess.lblLow := label.new(bar_index, low, text=nameLow, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=lbl_sz)
            
            s.history.push(newSess)

        // Process all active session lines
        int histSize = s.history.size()
        if histSize > 0
            for i = histSize - 1 to 0
                SessionLine inst = s.history.get(i)
                bool isCurrent = (i == histSize - 1)
                
                int age = currentTradingDayCount - inst.sessionStartTD
                if isCurrent and inSessionNow
                    age := 0
                    
                if age > 1
                    line.delete(inst.lineHigh)
                    line.delete(inst.lineLow)
                    label.delete(inst.lblHigh)
                    label.delete(inst.lblLow)
                    s.history.remove(i)
                else
                    if age != inst.lastAge
                        string prefix = age == 0 ? "" : "PD "
                        string finalNameHigh = nameHigh
                        string finalNameLow = nameLow
                        
                        if age == 1
                            if nameHigh == "CDH"
                                finalNameHigh := "H"
                            if nameLow == "CDL"
                                finalNameLow := "L"
                                
                        inst.baseTextHigh := prefix + finalNameHigh
                        inst.baseTextLow := prefix + finalNameLow
                        inst.lastAge := age
                    
                    // Reset label texts to their base string before combining logic later
                    label.set_text(inst.lblHigh, inst.baseTextHigh)
                    label.set_text(inst.lblLow, inst.baseTextLow)
                    
                    if isCurrent and inSessionNow
                        // Update current session's high/low
                        inst.highLevel := math.max(inst.highLevel, high)
                        inst.lowLevel := math.min(inst.lowLevel, low)
                        
                        line.set_xy1(inst.lineHigh, inst.startBar, inst.highLevel)
                        line.set_y2(inst.lineHigh, inst.highLevel)
                        line.set_x2(inst.lineHigh, bar_index)
                        
                        line.set_xy1(inst.lineLow, inst.startBar, inst.lowLevel)
                        line.set_y2(inst.lineLow, inst.lowLevel)
                        line.set_x2(inst.lineLow, bar_index)
                        
                        label.set_xy(inst.lblHigh, bar_index, inst.highLevel)
                        label.set_xy(inst.lblLow, bar_index, inst.lowLevel)
                    else
                        // Extend previous sessions or completed current session
                        if stopSwept
                            if not inst.highSwept
                                if high >= inst.highLevel
                                    inst.highSwept := true
                                line.set_x2(inst.lineHigh, bar_index)
                                label.set_x(inst.lblHigh, bar_index)
                            if not inst.lowSwept
                                if low <= inst.lowLevel
                                    inst.lowSwept := true
                                line.set_x2(inst.lineLow, bar_index)
                                label.set_x(inst.lblLow, bar_index)
                        else
                            line.set_x2(inst.lineHigh, bar_index)
                            line.set_x2(inst.lineLow, bar_index)
                            label.set_x(inst.lblHigh, bar_index)
                            label.set_x(inst.lblLow, bar_index)

        s.inSession := inSessionNow

var SessionData s_AS = SessionData.new(array.new<SessionLine>(), false)
var SessionData s_LN = SessionData.new(array.new<SessionLine>(), false)
var SessionData s_NY_AM = SessionData.new(array.new<SessionLine>(), false)
var SessionData s_NY_LN = SessionData.new(array.new<SessionLine>(), false)
var SessionData s_NY_PM = SessionData.new(array.new<SessionLine>(), false)
var SessionData s_CD = SessionData.new(array.new<SessionLine>(), false)

s_AS.processSession(t_AS, show_AS, col_AS, "AS H", "AS L", stop_swept, label_size_str)
s_LN.processSession(t_LN, show_LN, col_LN, "LN H", "LN L", stop_swept, label_size_str)
s_NY_AM.processSession(t_NY_AM, show_NY_AM, col_NY_AM, "NY AM H", "NY AM L", stop_swept, label_size_str)
s_NY_LN.processSession(t_NY_LN, show_NY_LN, col_NY_LN, "NY LN H", "NY LN L", stop_swept, label_size_str)
s_NY_PM.processSession(t_NY_PM, show_NY_PM, col_NY_PM, "NY PM H", "NY PM L", stop_swept, label_size_str)
s_CD.processSession(t_CD, show_CD, col_CD, "CDH", "CDL", stop_swept, label_size_str)

// --- Combine Overlapping Labels ---
type LevelInfo
    label lbl
    string lblText

method collectLabels(SessionData s, LevelInfo[] arr) =>
    if s.history.size() > 0
        for i = 0 to s.history.size() - 1
            SessionLine inst = s.history.get(i)
            // Only combine if the label is at the current tip (either extending or just swept)
            // If it was swept a long time ago, it's deep in the past and won't overlap with current price action anyway,
            // but we can just combine any labels that share exactly the same X and Y coordinate.
            arr.push(LevelInfo.new(inst.lblHigh, inst.baseTextHigh))
            arr.push(LevelInfo.new(inst.lblLow, inst.baseTextLow))

LevelInfo[] activeLabels = array.new<LevelInfo>()
s_AS.collectLabels(activeLabels)
s_LN.collectLabels(activeLabels)
s_NY_AM.collectLabels(activeLabels)
s_NY_LN.collectLabels(activeLabels)
s_NY_PM.collectLabels(activeLabels)
s_CD.collectLabels(activeLabels)

int n = activeLabels.size()
if n > 1
    bool[] processed = array.new_bool(n, false)
    for i = 0 to n - 1
        if not processed.get(i)
            LevelInfo curr = activeLabels.get(i)
            string combinedText = curr.lblText
            int currX = label.get_x(curr.lbl)
            float currY = label.get_y(curr.lbl)
            
            bool matchedAny = false
            if i + 1 <= n - 1
                for j = i + 1 to n - 1
                    if not processed.get(j)
                        LevelInfo other = activeLabels.get(j)
                        int otherX = label.get_x(other.lbl)
                        float otherY = label.get_y(other.lbl)
                        
                        // Same bar and practically same price
                        if currX == otherX and math.abs(currY - otherY) <= syminfo.mintick
                            combinedText += ", " + other.lblText
                            label.set_text(other.lbl, "") // Hide redundant
                            processed.set(j, true)
                            matchedAny := true
            
            if matchedAny
                label.set_text(curr.lbl, combinedText)
            
            processed.set(i, true)
````
