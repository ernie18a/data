# Avg Leg Duration (Single Value + Unit)

- url: https://www.tradingview.com/script/faJsbw9V-Avg-Leg-Duration-Single-Value-Unit/
- type: indicator
- pine_id: PUB;4055330af7ba4147821275ca9ed9e55c
- version: 1.0

## Description

Avg Leg Duration (Bars + Time)

Avg Leg Duration is a market rhythm and trend behavior indicator designed to measure how long directional price movements typically persist before changing direction.

Instead of focusing only on price magnitude, this indicator analyzes the duration of completed directional "legs" and calculates the average length of recent movements. The objective is to provide insight into the natural pacing and behavior of the current market environment.

Understanding how long trends and directional moves typically last can help traders better evaluate trend maturity, timing expectations, and overall market behavior.

Features:

• Measures completed directional price legs
• Calculates average duration across recent legs
• Customizable averaging period
• Optional ATR-based movement threshold filtering
• Optional directional carry-through for flat bars
• Multiple output units:

• Bars
• Seconds
• Minutes
• Hours
• Days
• Weeks

• Multiple rounding methods:

• None
• Round
• Ceiling
• Floor

• Simple on-chart display showing current average leg duration

Potential use cases:

• Estimate how long directional moves typically last
• Identify potentially extended or immature trends
• Compare market rhythm across different instruments
• Study changing market conditions
• Add timing context to existing strategies
• Evaluate whether price movements are becoming more compressed or extended

Interpretation:

Lower Average Duration

Directional moves are changing more frequently and may indicate increased choppiness or shorter-term market behavior.

Higher Average Duration

Directional moves are persisting longer and may indicate stronger directional behavior or longer trend cycles.

Changing Average Duration

Expanding or contracting values can suggest shifts in market participation and behavior.

Unlike traditional momentum indicators that focus primarily on price movement itself, Avg Leg Duration focuses on the time component of market behavior and attempts to provide additional context into how markets naturally move and cycle.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
//@version=5
indicator("Avg Leg Duration (Single Value + Unit)", overlay=false)

// --------------------
// Inputs
// --------------------
useThreshold  = input.bool(false, "Use ATR threshold to define direction?")
atrLen        = input.int(14, "ATR Length", minval=1)
atrFrac       = input.float(0.10, "Threshold = ATR * fraction", step=0.01)
legsToAvg     = input.int(20, "Average last N completed legs", minval=1)

carryZeros    = input.bool(true, "Carry direction through flat bars?")

unitOpt       = input.string("Minutes", "Output Units", options=["Bars","Seconds","Minutes","Hours","Days","Weeks"])
roundMode     = input.string("None", "Rounding (bars before time conversion)", options=["None","Round","Ceil","Floor"])

// --------------------
// Timeframe duration (seconds)
// --------------------
tfSec = timeframe.in_seconds(timeframe.period)

// --------------------
// Direction per bar
// --------------------
atr   = ta.atr(atrLen)
theta = atr * atrFrac
delta = close - close[1]

dir =
     useThreshold ?
         (delta >  theta ?  1 : delta < -theta ? -1 : 0)
     :
         (delta > 0 ? 1 : delta < 0 ? -1 : 0)

// Carry direction through flat bars (optional)
var int dir2 = 0
if carryZeros and dir == 0
    dir2 := nz(dir2[1])
else
    dir2 := dir

// --------------------
// Leg tracking (completed legs only)
// --------------------
var int  curLen = 0
var int  curDir = 0
var int[] legLens = array.new_int()

newLeg = (dir2 != 0) and (dir2 != curDir)

if barstate.isfirst
    curDir := dir2
    curLen := 0

if dir2 != 0
    if newLeg
        // store the leg we just finished
        if curLen > 0
            array.unshift(legLens, curLen)
            if array.size(legLens) > legsToAvg
                array.pop(legLens)
        // reset for new leg
        curDir := dir2
        curLen := 1
    else
        curLen += 1

// --------------------
// Average leg length in bars
// --------------------
float avgBars = na
if array.size(legLens) > 0
    float s = 0.0
    for i = 0 to array.size(legLens) - 1
        s += array.get(legLens, i)
    avgBars := s / array.size(legLens)

// Rounding bars BEFORE converting to time
float avgBarsAdj =
     roundMode == "Round" ? math.round(avgBars) :
     roundMode == "Ceil"  ? math.ceil(avgBars)  :
     roundMode == "Floor" ? math.floor(avgBars) :
     avgBars

// --------------------
// Convert to chosen unit (single output value)
// --------------------
avgSec = avgBarsAdj * tfSec

float outVal = na

if unitOpt == "Bars"
    outVal := avgBarsAdj
else if unitOpt == "Seconds"
    outVal := avgSec
else if unitOpt == "Minutes"
    outVal := avgSec / 60.0
else if unitOpt == "Hours"
    outVal := avgSec / 3600.0
else if unitOpt == "Days"
    outVal := avgSec / 86400.0
else
    outVal := avgSec / 604800.0

plot(outVal, "Avg Leg Duration", linewidth=2)

// --------------------
// Show ONE number in the corner (current value + units)
// --------------------
var table t = table.new(position.top_right, 1, 1)
if barstate.islast
    txt = na(outVal) ? "Avg Leg: n/a" : "Avg Leg: " + str.tostring(outVal, "#.##") + " " + unitOpt
    table.cell(t, 0, 0, txt)
````
