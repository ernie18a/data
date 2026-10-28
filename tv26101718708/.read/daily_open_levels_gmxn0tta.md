# Daily Open Levels 

- url: https://www.tradingview.com/script/gMxN0TtA-Daily-Open-Levels/
- type: indicator
- pine_id: PUB;e689e38d50644b77b7bfd6b70bf115f2
- version: 1.0

## Description

Daily Open Price
Use it as a Support and Resistance Level.

## Source Code

````pine
//@version=6
indicator("Daily Open Levels", overlay=true, shorttitle="DO & PDO")

// ==============================================================================
// ⚙️ SETTINGS & CUSTOMIZATIONS
// ==============================================================================
string grp_do = "Daily Open (DO) Settings"
bool   showDO       = input.bool(true, "Show Daily Open (DO)", group=grp_do)
string textDO       = input.string("DO", "DO Label Text", group=grp_do)
color  colorDO      = input.color(color.blue, "DO Line Color", group=grp_do)
color  textColorDO  = input.color(color.blue, "DO Text Color", group=grp_do)
string styleDO_str  = input.string("Solid", "DO Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_do)

string grp_pdo = "Previous Daily Open (PDO) Settings"
bool   showPDO      = input.bool(true, "Show Previous Daily Open (PDO)", group=grp_pdo)
string textPDO      = input.string("PDO", "PDO Label Text", group=grp_pdo)
color  colorPDO     = input.color(color.orange, "PDO Line Color", group=grp_pdo)
color  textColorPDO = input.color(color.orange, "PDO Text Color", group=grp_pdo)
string stylePDO_str = input.string("Solid", "PDO Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_pdo)

string grp_gen = "General Styling & Behavior"
int    lineWidth    = input.int(2, "Line Thickness", minval=1, maxval=4, group=grp_gen)
string lblSize_str  = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_gen)
string lblPos_str   = input.string("Above Line", "Label Position", options=["Above Line", "Below Line", "On Line"], group=grp_gen)
int    lblOffset    = input.int(3, "Label Offset (Bars right)", minval=0, maxval=50, group=grp_gen, tooltip="ขยับตัวอักษรออกห่างจากแท่งเทียนปัจจุบัน")
bool   autoHide     = input.bool(true, "Auto-Hide on Higher Timeframes (Weekly/Monthly)", group=grp_gen, tooltip="ซ่อนเส้นอัตโนมัติหากเปิดกราฟระดับ Week หรือ Month เพื่อไม่ให้กราฟรก")

// ==============================================================================
// 🛠️ HELPER FUNCTIONS
// ==============================================================================
getLineStyle(string str) =>
    str == "Dashed" ? line.style_dashed : str == "Dotted" ? line.style_dotted : line.style_solid

getLabelSize(string str) =>
    str == "Tiny" ? size.tiny : str == "Small" ? size.small : str == "Large" ? size.large : size.normal

getLabelStyle(string str) =>
    str == "Above Line" ? label.style_label_lower_left : str == "Below Line" ? label.style_label_upper_left : label.style_label_left

// ==============================================================================
// 📈 FETCH DATA (Safe against repainting for 'open' prices)
// ==============================================================================
float dOpen  = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
float pdOpen = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)

// ==============================================================================
// ⏱️ TIME & BAR TRACKING
// ==============================================================================
// ✅ Fix 3: ta.change returns float, must check != 0 for boolean
bool isNewDay = ta.change(time("D")) != 0

// ✅ Fix 1: Use time (timestamp) instead of bar_index to prevent historical offset errors
var int startTimeToday = na
var int startTimeYest  = na

if isNewDay
    startTimeYest  := startTimeToday
    startTimeToday := time

// Check Auto-Hide condition
bool isHigherTF = timeframe.isweekly or timeframe.ismonthly
bool canShow = not (autoHide and isHigherTF)

// ==============================================================================
// 🎨 DRAWING LOGIC (Optimized & Bug-Free)
// ==============================================================================
// ✅ Fix 1: Add xloc=xloc.bar_time to use Unix time instead of bar_index
var line doLine  = line.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right)
var line pdoLine = line.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.right)

var label doLabel  = label.new(na, na, xloc=xloc.bar_time)
var label pdoLabel = label.new(na, na, xloc=xloc.bar_time)

if barstate.islast
    // Calculate a safe x2 coordinate using time (1 bar duration into the future)
    int barDuration = nz(time - time[1], 60000)
    int x2_today = startTimeToday == time ? startTimeToday + barDuration : time
    int x2_yest  = startTimeYest == time ? startTimeYest + barDuration : time
    
    // Label x position based on time offset
    int lbl_x = time + (barDuration * lblOffset)
    string lbl_style = getLabelStyle(lblPos_str)

    // --- Update DO ---
    if showDO and not na(startTimeToday) and canShow
        line.set_xy1(doLine, startTimeToday, dOpen)
        line.set_xy2(doLine, x2_today, dOpen)
        line.set_color(doLine, colorDO)
        line.set_width(doLine, lineWidth)
        line.set_style(doLine, getLineStyle(styleDO_str))
        
        label.set_xy(doLabel, lbl_x, dOpen)
        label.set_text(doLabel, textDO)
        label.set_style(doLabel, lbl_style)
        label.set_color(doLabel, color.new(color.white, 100)) // Invisible background
        label.set_textcolor(doLabel, textColorDO)
        label.set_size(doLabel, getLabelSize(lblSize_str))
    else
        line.set_xy1(doLine, na, na)
        label.set_xy(doLabel, na, na)

    // --- Update PDO ---
    if showPDO and not na(startTimeYest) and canShow
        line.set_xy1(pdoLine, startTimeYest, pdOpen)
        line.set_xy2(pdoLine, x2_yest, pdOpen)
        line.set_color(pdoLine, colorPDO)
        line.set_width(pdoLine, lineWidth)
        line.set_style(pdoLine, getLineStyle(stylePDO_str))
        
        label.set_xy(pdoLabel, lbl_x, pdOpen)
        label.set_text(pdoLabel, textPDO)
        label.set_style(pdoLabel, lbl_style)
        label.set_color(pdoLabel, color.new(color.white, 100)) // Invisible background
        label.set_textcolor(pdoLabel, textColorPDO)
        label.set_size(pdoLabel, getLabelSize(lblSize_str))
    else
        line.set_xy1(pdoLine, na, na)
        label.set_xy(pdoLabel, na, na)
````
