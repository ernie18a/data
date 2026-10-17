# fIB L

- url: https://www.tradingview.com/script/AEABN378-fIB-L/
- type: indicator
- pine_id: PUB;0551a3dd4dee4dceb86f815861b96f09
- version: 1.0

## Description

Fib levels from the asia session marking key levels to trade into during Ny Session

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Sydney-Tokyo & NY Candle Fibonacci", overlay = true, max_lines_count = 100, max_labels_count = 100)

// --- Constants ---
const string G1 = "Sydney -> Tokyo Fibonacci"
const string G2 = "9:00–10:00 AM Candle Fibonacci"
const string GS = "Styling & Extensions"

// --- Inputs: Sydney -> Tokyo ---
showSydTok     = input.bool(true, "Enable Sydney-Tokyo Fib", group = G1)
sydSession     = input.session("1700-0000", "Sydney Session", group = G1)
tokSession     = input.session("0000-0600", "Tokyo Session", group = G1)
sydTokTz       = input.string("UTC+10", "Timezone", group = G1, tooltip = "Sydney/Tokyo Timezone (e.g., UTC+10 for Sydney)")
flipSydTok     = input.bool(false, "Flip Direction (Bottom Sydney -> Top Tokyo)", group = G1)

// --- Inputs: NY Candle ---
showNY         = input.bool(true, "Enable NY Candle Fib", group = G2)
nySession      = input.session("0900-1000", "NY Candle Session", group = G2)
nyTz           = input.string("America/New_York", "Timezone", group = G2)
flipNY         = input.bool(false, "Flip Direction (Low -> High)", group = G2)

// --- Inputs: Fibonacci Levels ---
f0_val = 0.0,    f0_en = input.bool(true, "0", inline = "f0", group = GS), f0_col = input.color(color.gray, "", inline = "f0", group = GS)
f1_val = 1.0,    f1_en = input.bool(true, "1", inline = "f1", group = GS), f1_col = input.color(color.gray, "", inline = "f1", group = GS)
f236_val = 0.236, f236_en = input.bool(true, "0.236", inline = "f2", group = GS), f236_col = input.color(#089981, "", inline = "f2", group = GS)
f786_val = 0.786, f786_en = input.bool(true, "0.786", inline = "f3", group = GS), f786_col = input.color(#089981, "", inline = "f3", group = GS)
fn236_val = -0.236, fn236_en = input.bool(true, "-0.236", inline = "f4", group = GS), fn236_col = input.color(#f23645, "", inline = "f4", group = GS)
fn786_val = -0.786, fn786_en = input.bool(true, "-0.786", inline = "f5", group = GS), fn786_col = input.color(#f23645, "", inline = "f5", group = GS)
fn1_val = -1.0,   fn1_en = input.bool(true, "-1", inline = "f6", group = GS), fn1_col = input.color(color.gray, "", inline = "f6", group = GS)

// --- Inputs: Styling & Extension ---
lineStyleInput = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = GS)
lineWidth      = input.int(1, "Line Width", minval = 1, group = GS)
extMode        = input.string("Right only", "Extension", options = ["None", "Right only", "Left only", "Both"], group = GS)
extLimit       = input.string("Bar Count", "Extension Limit", options = ["Bar Count", "End of Day"], group = GS, tooltip = "Choose whether to extend lines by a fixed bar count or until the end of the trading day.")
extLeftBars    = input.int(50, "Bars Left", minval = 0, group = GS)
extRightBars   = input.int(200, "Bars Right", minval = 0, group = GS)
showLabels     = input.bool(true, "Show Labels", group = GS)
showFill       = input.bool(false, "Background Fill (Between 0 and 1)", group = GS)

lineStyle = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// --- Types ---
type LevelInfo
    float val
    bool  en
    color col

type FibDrawing
    line[] lines
    label[] labels
    box fillBox
    float p1
    float p2

// --- Functions ---
method delete(FibDrawing this) =>
    if not na(this)
        for ln in this.lines
            line.delete(ln)
        for lb in this.labels
            label.delete(lb)
        box.delete(this.fillBox)
        this.lines.clear()
        this.labels.clear()

drawFibs(float startPrice, float endPrice, int startBar, int endBar, bool show) =>
    FibDrawing fd = FibDrawing.new(array.new_line(), array.new_label(), na, startPrice, endPrice)
    if show
        LevelInfo[] levels = array.from(
             LevelInfo.new(f0_val, f0_en, f0_col), LevelInfo.new(f1_val, f1_en, f1_col),
             LevelInfo.new(f236_val, f236_en, f236_col), LevelInfo.new(f786_val, f786_en, f786_col),
             LevelInfo.new(fn236_val, fn236_en, fn236_col), LevelInfo.new(fn786_val, fn786_en, fn786_col),
             LevelInfo.new(fn1_val, fn1_en, fn1_col)
         )

        float diff = endPrice - startPrice
        int x1 = endBar
        int x2 = endBar
        
        if extLimit == "Bar Count"
            x1 := extMode == "Left only" or extMode == "Both" ? endBar - extLeftBars : endBar
            x2 := extMode == "Right only" or extMode == "Both" ? endBar + extRightBars : endBar
        else
            x1 := extMode == "Left only" or extMode == "Both" ? 0 : endBar 
            x2 := bar_index 

        for li in levels
            if li.en
                float p = startPrice + diff * li.val
                line ln = line.new(x1, p, x2, p, xloc.bar_index, style = lineStyle, color = li.col, width = lineWidth)
                fd.lines.push(ln)
                if showLabels
                    label lb = label.new(x2, p, str.tostring(li.val), xloc.bar_index, color = #00000000, textcolor = li.col, style = label.style_label_left, size = size.small)
                    fd.labels.push(lb)
        
        if showFill
            fd.fillBox := box.new(x1, endPrice, x2, startPrice, border_color = color.new(color.gray, 100), bgcolor = color.new(color.gray, 85))
    fd

// --- Sydney -> Tokyo Logic ---
var float sydHigh = na
var float sydLow  = na
var float tokHigh = na
var float tokLow  = na
var bool inSyd = false
var bool inTok = false
var FibDrawing sydTokDrawings = na

tSyd = time(timeframe.period, sydSession, sydTokTz)
tTok = time(timeframe.period, tokSession, sydTokTz)

if not na(tSyd)
    if na(tSyd[1])
        sydHigh := high
        sydLow  := low
    else
        sydHigh := math.max(sydHigh, high)
        sydLow  := math.min(sydLow, low)
    inSyd := true
else
    inSyd := false

if not na(tTok)
    if na(tTok[1])
        tokHigh := high
        tokLow  := low
    else
        tokHigh := math.max(tokHigh, high)
        tokLow  := math.min(tokLow, low)
    inTok := true
else
    inTok := false

if not inTok and inTok[1] and showSydTok
    sydTokDrawings.delete()
    float p1 = flipSydTok ? sydLow : sydHigh
    float p2 = flipSydTok ? tokHigh : tokLow
    sydTokDrawings := drawFibs(p1, p2, bar_index[1], bar_index, true)

if not na(sydTokDrawings)
    int new_x2 = bar_index
    if extLimit == "Bar Count"
        new_x2 := line.get_x1(sydTokDrawings.lines.get(0)) + (extMode == "Right only" or extMode == "Both" ? extRightBars : 0)
    else
        new_x2 := bar_index
    
    if barstate.islast or extLimit == "End of Day"
        for ln in sydTokDrawings.lines
            line.set_x2(ln, new_x2)
        for lb in sydTokDrawings.labels
            label.set_x(lb, new_x2)
        if not na(sydTokDrawings.fillBox)
            box.set_right(sydTokDrawings.fillBox, new_x2)

// --- NY Candle Logic ---
var float nyHigh = na
var float nyLow  = na
var bool inNY = false
var FibDrawing nyDrawings = na

tNY = time(timeframe.period, nySession, nyTz)

if not na(tNY)
    if na(tNY[1])
        nyHigh := high
        nyLow  := low
    else
        nyHigh := math.max(nyHigh, high)
        nyLow  := math.min(nyLow, low)
    inNY := true
else
    inNY := false

if not inNY and inNY[1] and showNY
    nyDrawings.delete()
    float p1 = flipNY ? nyLow : nyHigh
    float p2 = flipNY ? nyHigh : nyLow
    nyDrawings := drawFibs(p1, p2, bar_index[1], bar_index, true)

if not na(nyDrawings)
    int new_x2 = bar_index
    if extLimit == "Bar Count"
        new_x2 := line.get_x1(nyDrawings.lines.get(0)) + (extMode == "Right only" or extMode == "Both" ? extRightBars : 0)
    else
        new_x2 := bar_index
        
    if barstate.islast or extLimit == "End of Day"
        for ln in nyDrawings.lines
            line.set_x2(ln, new_x2)
        for lb in nyDrawings.labels
            label.set_x(lb, new_x2)
        if not na(nyDrawings.fillBox)
            box.set_right(nyDrawings.fillBox, new_x2)

// --- Alerts (Non-Repainting Logic) ---
alertTouch = false
alertBreak = false

// Monitor Syd-Tok Levels
if not na(sydTokDrawings)
    diff = sydTokDrawings.p2 - sydTokDrawings.p1
    p_1 = sydTokDrawings.p1 + diff * 1.0
    p_n1 = sydTokDrawings.p1 + diff * -1.0
    
    for ln in sydTokDrawings.lines
        p = line.get_y1(ln)
        if (high >= p and low <= p)
            alertTouch := true
    
    if (ta.crossover(close, p_1) or ta.crossunder(close, p_n1))
        alertBreak := true

// Monitor NY Levels
if not na(nyDrawings)
    diff = nyDrawings.p2 - nyDrawings.p1
    p_1 = nyDrawings.p1 + diff * 1.0
    p_n1 = nyDrawings.p1 + diff * -1.0
    
    for ln in nyDrawings.lines
        p = line.get_y1(ln)
        if (high >= p and low <= p)
            alertTouch := true
    
    if (ta.crossover(close, p_1) or ta.crossunder(close, p_n1))
        alertBreak := true

alertcondition(alertTouch, "Price Touches Fib Level", "Price has touched a Fibonacci level.")
alertcondition(alertBreak, "Price Breaks Fib Level (1 or -1)", "Price has broken above level 1 or below -1.")
````
