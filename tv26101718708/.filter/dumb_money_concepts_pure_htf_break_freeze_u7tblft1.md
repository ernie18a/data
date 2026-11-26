# Dumb Money Concepts - Pure HTF Break & Freeze

- url: https://www.tradingview.com/script/U7TblfT1-Dumb-Money-Concepts-Pure-HTF-Break-Freeze/
- type: indicator
- pine_id: PUB;ed63d56a30534b479b86b4d7483108d6
- version: 2.0

## Description

DMC Concepts dumb money concepts this will eliminate having to plot key 15 min and 1 hour swing levels

## Source Code

````pine
//@version=6
indicator("Dumb Money Concepts - Pure HTF Break & Freeze", overlay=true, max_lines_count=500)

// ==========================================
// 1. CONFIGURATION INPUTS
// ==========================================
var string G_ST = "Swing Sensitivity"
sLeft  = input.int(3, "Left Side Confirmation Bars", minval=1, group=G_ST)
sRight = input.int(3, "Right Side Confirmation Bars", minval=1, group=G_ST)

var string G_VI = "Level Visibility"
show15M = input.bool(true, "Track 15M Swing Bodies", group=G_VI)
show1H  = input.bool(true, "Track 1H Swing Bodies", group=G_VI)
show4H  = input.bool(true, "Track 4H Swing Bodies", group=G_VI)

// --- Customization Settings Panel (Fixed Colors: 15M Blue, 1H White, 4H Red) ---
var string G_15M = "15-Minute Line Style"
c_15M_act  = input.color(color.blue, "15M Color", group=G_15M)
w_15M_act  = input.int(1, "15M Width", minval=1, maxval=5, group=G_15M)

var string G_1H   = "1-Hour Line Style"
c_1H_act   = input.color(color.white, "1H Color", group=G_1H)
w_1H_act   = input.int(2, "1H Width", minval=1, maxval=5, group=G_1H)

var string G_4H   = "4-Hour Line Style"
c_4H_act   = input.color(color.red, "4H Color", group=G_4H)
w_4H_act   = input.int(2, "4H Width", minval=1, maxval=5, group=G_4H)

// ==========================================
// 2. TIMEFRAME-FILTERED EXTRACTION ENGINE
// ==========================================
bHigh = math.max(open, close)
bLow  = math.min(open, close)

// 15-Minute Structural Data
m15_bHigh = request.security(syminfo.tickerid, "15", bHigh[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
m15_bLow  = request.security(syminfo.tickerid, "15", bLow[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float m15Hi = ta.pivothigh(m15_bHigh, sLeft, sRight)
float m15Lo = ta.pivotlow(m15_bLow, sLeft, sRight)

// 1-Hour Structural Data
h1_bHigh = request.security(syminfo.tickerid, "60", bHigh[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
h1_bLow  = request.security(syminfo.tickerid, "60", bLow[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float h1Hi = ta.pivothigh(h1_bHigh, sLeft, sRight)
float h1Lo = ta.pivotlow(h1_bLow, sLeft, sRight)

// 4-Hour Structural Data
h4_bHigh = request.security(syminfo.tickerid, "240", bHigh[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
h4_bLow  = request.security(syminfo.tickerid, "240", bLow[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float h4Hi = ta.pivothigh(h4_bHigh, sLeft, sRight)
float h4Lo = ta.pivotlow(h4_bLow, sLeft, sRight)

// Prevent rendering duplicate elements on native parent timeframes
if timeframe.period == "15"
    m15Hi := na
    m15Lo := na
if timeframe.period == "60"
    h1Hi := na
    h1Lo := na
if timeframe.period == "240"
    h4Hi := na
    h4Lo := na

// ==========================================
// 3. PERSISTENT ARRAY STORAGE ENGINE
// ==========================================
var line[]  activeLines  = array.new<line>()
var float[] levelPrices  = array.new<float>()
var bool[]  isHighPivots = array.new<bool>()

// --- Instantiation Function ---
registerLine(float price, bool isHigh, color lineColor, int lineWidth, int offset) =>
    newLine = line.new(x1=bar_index - offset, y1=price, x2=bar_index, y2=price, 
                       color=lineColor, width=lineWidth, style=line.style_solid)
    array.push(activeLines,  newLine)
    array.push(levelPrices,  price)
    array.push(isHighPivots, isHigh)

// Deploy fresh structural lines safely
if show15M and not na(m15Hi) 
    registerLine(m15Hi, true, c_15M_act, w_15M_act, sRight)
if show15M and not na(m15Lo) 
    registerLine(m15Lo, false, c_15M_act, w_15M_act, sRight)
if show1H  and not na(h1Hi)  
    registerLine(h1Hi, true, c_1H_act, w_1H_act, sRight)
if show1H  and not na(h1Lo)  
    registerLine(h1Lo, false, c_1H_act, w_1H_act, sRight)
if show4H  and not na(h4Hi)  
    registerLine(h4Hi, true, c_4H_act, w_4H_act, sRight)
if show4H  and not na(h4Lo)  
    registerLine(h4Lo, false, c_4H_act, w_4H_act, sRight)

// ==========================================
// 4. THE LIVE REAL-TIME BREAK ENGINE
// ==========================================
fiveMinBodyHigh = math.max(open, close)
fiveMinBodyLow  = math.min(open, close)

// Step A: Continuously advance live, unbroken levels out to the execution edge
int currentActiveCount = array.size(activeLines)
if currentActiveCount > 0
    for j = 0 to currentActiveCount - 1 by 1
        line.set_x2(array.get(activeLines, j), bar_index)

// Step B: Scan for structural crossings and freeze broken levels permanently
int i = array.size(activeLines) - 1
while i >= 0
    float linePrice = array.get(levelPrices, i)
    bool isHighWall = array.get(isHighPivots, i)
    
    bool isBroken = false
    if isHighWall and fiveMinBodyHigh > linePrice
        isBroken := true
    else if not isHighWall and fiveMinBodyLow < linePrice
        isBroken := true
        
    if isBroken
        line brokenLine = array.get(activeLines, i)
        
        // Hard freeze: Cap the line exactly at the breaking bar
        line.set_x2(brokenLine, bar_index)
        
        // Cleanly remove from active updates tracking loops
        array.remove(activeLines, i)
        array.remove(levelPrices, i)
        array.remove(isHighPivots, i)
    
    i := i - 1

// ==========================================
// 5. COMPILER CONSTANT TRIGGER
// ==========================================
plot(0, title="Compiler Fix Plot", color=color.new(color.black, 100), editable=false)
````
