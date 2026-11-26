# +Session High/Low with Dynamic Bounce Notes

- url: https://www.tradingview.com/script/1hpawhp2-Session-High-Low-with-Dynamic-Bounce-Notes/
- type: indicator
- pine_id: PUB;12ac735e25ed49b9b31d9822a4eeffd7
- version: 1.0

## Description

+ Simple and easy to understand Asia, London, and New York Highs and Lows. These are also identified as the support and resistance levels. 
Great for new traders trying to understand the reasoning. 
These are specifically for the previous days according session (does not include the new day's session in its entirety, as it is a previous data backed driven system). 

Only useful for testing resistance and support levels and to take trades based off of that. 

Easibility to understand 10/10
Complicated 0/10
Usable 10/10. 
+

## Source Code

````pine
//@version=6
indicator("Session High/Low with Dynamic Bounce Notes", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// CONFIGURATION & INPUTS
// ==========================================
var string G_SESS  = "Session Times"
asiaSess   = input.session("1900-0300", "Asia Session", group=G_SESS)
londonSess = input.session("0300-1100", "London Session", group=G_SESS)
nySess     = input.session("0900-1700", "New York Session", group=G_SESS)

var string G_COL   = "Line Colors"
c_asia     = input.color(color.blue, "Asia Color", group=G_COL)
c_london   = input.color(color.orange, "London Color", group=G_COL)
c_ny       = input.color(color.red, "New York Color", group=G_COL)

var string G_NOTE  = "Bounce Tracker Configuration"
tickBuffer = input.int(4, "Bounce Buffer Zone (In Ticks)", minval=0, group=G_NOTE, tooltip="How close price needs to get to the level to qualify a test.")

// Convert ticks to absolute price distance
float bufferDist = syminfo.mintick * tickBuffer

// ==========================================
// GLOBAL STRING FORMATTING FUNCTION
// ==========================================
getNoteText(string baseName, int bounceCount) =>
    string result = baseName
    if bounceCount > 0
        result := baseName + " [Bounces Tracked: " + str.tostring(bounceCount) + "]"
    result

// ==========================================
// MANDATORY GLOBAL VARIABLES (Fixes CW10002 & CE10101)
// ==========================================
// Force executions on every single bar to maintain airtight historical registers
bool dayChanged   = not na(ta.change(time("D")))
bool highChanged  = not na(ta.change(high))
bool lowChanged   = not na(ta.change(low))

// ==========================================
// INDEPENDENT SESSION CAPTURE (WICKS)
// ==========================================
inSession(sessTime) => not na(time(timeframe.period, sessTime))

asiaActive = inSession(asiaSess)
lonActive  = inSession(londonSess)
nyActive   = inSession(nySess)

asiaNew = asiaActive and not asiaActive[1]
lonNew  = lonActive and not lonActive[1]
nyNew   = nyActive and not nyActive[1]

var float hAsia = na, var float lAsia = na
var float hLon  = na, var float lLon  = na
var float hNy   = na, var float lNy   = na

if asiaActive
    hAsia := asiaNew ? high : math.max(high, nz(hAsia, high))
    lAsia := asiaNew ? low  : math.min(low, nz(lAsia, low))

if lonActive
    hLon := lonNew ? high : math.max(high, nz(hLon, high))
    lLon := lonNew ? low  : math.min(low, nz(lLon, low))

if nyActive
    hNy := nyNew ? high : math.max(high, nz(hNy, high))
    lNy := nyNew ? low  : math.min(low, nz(lNy, low))

// ==========================================
// FROZEN HISTORICAL SNAPSHOTS (YESTERDAY)
// ==========================================
var float stableAsiaH = na, var float stableAsiaL = na
var float stableLonH  = na, var float stableLonL  = na
var float stableNyH   = na, var float stableNyL   = na

if asiaNew
    stableAsiaH := hAsia[1], stableAsiaL := lAsia[1]
if lonNew
    stableLonH := hLon[1], stableLonL := lLon[1]
if nyNew
    stableNyH := hNy[1], stableNyL := lNy[1]

// ==========================================
// LIVE BOUNCE REJECTION LOGIC
// ==========================================
var int bounceAsiaH = 0, var int bounceAsiaL = 0
var int bounceLonH  = 0, var int bounceLonL  = 0
var int bounceNyH   = 0, var int bounceNyL   = 0

// Reset bounce tracking registers when a brand new trading day begins
if dayChanged
    bounceAsiaH := 0, bounceAsiaL := 0
    bounceLonH  := 0, bounceLonL := 0
    bounceNyH   := 0, bounceNyL   := 0

// Track rejections using global execution flags and strict boolean assessments
if not na(stableAsiaH) and high >= (stableAsiaH - bufferDist) and high <= stableAsiaH and close < (stableAsiaH - bufferDist) and highChanged
    bounceAsiaH := bounceAsiaH + 1
if not na(stableAsiaL) and low <= (stableAsiaL + bufferDist) and low >= stableAsiaL and close > (stableAsiaL + bufferDist) and lowChanged
    bounceAsiaL := bounceAsiaL + 1

if not na(stableLonH) and high >= (stableLonH - bufferDist) and high <= stableLonH and close < (stableLonH - bufferDist) and highChanged
    bounceLonH := bounceLonH + 1
if not na(stableLonL) and low <= (stableLonL + bufferDist) and low >= stableLonL and close > (stableLonL + bufferDist) and lowChanged
    bounceLonL := bounceLonL + 1

if not na(stableNyH) and high >= (stableNyH - bufferDist) and high <= stableNyH and close < (stableNyH - bufferDist) and highChanged
    bounceNyH := bounceNyH + 1
if not na(stableNyL) and low <= (stableNyL + bufferDist) and low >= stableNyL and close > (stableNyL + bufferDist) and lowChanged
    bounceNyL := bounceNyL + 1

// ==========================================
// UNIVERSAL DRAWING ENGINE (DYNAMIC NOTES)
// ==========================================
var line l_ah = na, var line l_al = na
var line l_lh = na, var line l_ll = na
var line l_nh = na, var line l_nl = na

var label lb_ah = na, var label lb_al = na
var label lb_lh = na, var label lb_ll = na
var label lb_nh = na, var label lb_nl = na
var label lb_ah_p = na, var label lb_al_p = na
var label lb_lh_p = na, var label lb_ll_p = na
var label lb_nh_p = na, var label lb_nl_p = na

if barstate.islast
    line.delete(l_ah), label.delete(lb_ah), label.delete(lb_ah_p)
    line.delete(l_al), label.delete(lb_al), label.delete(lb_al_p)
    line.delete(l_lh), label.delete(lb_lh), label.delete(lb_lh_p)
    line.delete(l_ll), label.delete(lb_ll), label.delete(lb_ll_p)
    line.delete(l_nh), label.delete(lb_nh), label.delete(lb_nh_p)
    line.delete(l_nl), label.delete(lb_nl), label.delete(lb_nl_p)

    int startX  = bar_index + 2
    int spacing = 32  

    int colAsiaH = 0, int colAsiaL = 0
    int colLonH = (stableLonH == stableAsiaH or stableLonH == stableAsiaL) ? 1 : 0
    int colLonL = (stableLonL == stableAsiaH or stableLonL == stableAsiaL) ? 1 : 0
    
    int colNyH = 0
    if stableNyH == stableAsiaH or stableNyH == stableAsiaL or stableNyH == stableLonH or stableNyH == stableLonL
        colNyH := colNyH + 1
    int colNyL = 0
    if stableNyL == stableAsiaH or stableNyL == stableAsiaL or stableNyL == stableLonH or stableNyL == stableLonL
        colNyL := colNyL + 1

    // --- Render Elements ---
    if not na(stableAsiaH)
        int txtPos  = startX + (colAsiaH * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_ah   := label.new(txtPos, stableAsiaH, getNoteText("Asia High", bounceAsiaH), textcolor=c_asia, style=label.style_label_lower_left, size=size.small, color=color.new(color.black, 100))
        l_ah    := line.new(txtPos, stableAsiaH, lineEnd, stableAsiaH, color=c_asia, width=2)
        lb_ah_p := label.new(lineEnd, stableAsiaH, "(" + str.tostring(stableAsiaH, "#.##") + ")", textcolor=c_asia, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))
        
    if not na(stableAsiaL)
        int txtPos  = startX + (colAsiaL * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_al   := label.new(txtPos, stableAsiaL, getNoteText("Asia Low", bounceAsiaL), textcolor=c_asia, style=label.style_label_upper_left, size=size.small, color=color.new(color.black, 100))
        l_al    := line.new(txtPos, stableAsiaL, lineEnd, stableAsiaL, color=c_asia, width=2)
        lb_al_p := label.new(lineEnd, stableAsiaL, "(" + str.tostring(stableAsiaL, "#.##") + ")", textcolor=c_asia, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))

    if not na(stableLonH)
        int txtPos  = startX + (colLonH * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_lh   := label.new(txtPos, stableLonH, getNoteText("London High", bounceLonH), textcolor=c_london, style=label.style_label_lower_left, size=size.small, color=color.new(color.black, 100))
        l_lh    := line.new(txtPos, stableLonH, lineEnd, stableLonH, color=c_london, width=2)
        lb_lh_p := label.new(lineEnd, stableLonH, "(" + str.tostring(stableLonH, "#.##") + ")", textcolor=c_london, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))
        
    if not na(stableLonL)
        int txtPos  = startX + (colLonL * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_ll   := label.new(txtPos, stableLonL, getNoteText("London Low", bounceLonL), textcolor=c_london, style=label.style_label_upper_left, size=size.small, color=color.new(color.black, 100))
        l_ll    := line.new(txtPos, stableLonL, lineEnd, stableLonL, color=c_london, width=2)
        lb_ll_p := label.new(lineEnd, stableLonL, "(" + str.tostring(stableLonL, "#.##") + ")", textcolor=c_london, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))

    if not na(stableNyH)
        int txtPos  = startX + (colNyH * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_nh   := label.new(txtPos, stableNyH, getNoteText("NY High", bounceNyH), textcolor=c_ny, style=label.style_label_lower_left, size=size.small, color=color.new(color.black, 100))
        l_nh    := line.new(txtPos, stableNyH, lineEnd, stableNyH, color=c_ny, width=2)
        lb_nh_p := label.new(lineEnd, stableNyH, "(" + str.tostring(stableNyH, "#.##") + ")", textcolor=c_ny, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))
        
    if not na(stableNyL)
        int txtPos  = startX + (colNyL * spacing)
        int lineEnd = txtPos + spacing - 4
        lb_nl   := label.new(txtPos, stableNyL, getNoteText("NY Low", bounceNyL), textcolor=c_ny, style=label.style_label_upper_left, size=size.small, color=color.new(color.black, 100))
        l_nl    := line.new(txtPos, stableNyL, lineEnd, stableNyL, color=c_ny, width=2)
        lb_nl_p := label.new(lineEnd, stableNyL, "(" + str.tostring(stableNyL, "#.##") + ")", textcolor=c_ny, style=label.style_label_left, size=size.small, color=color.new(color.black, 100))
````
