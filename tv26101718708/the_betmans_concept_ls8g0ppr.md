# The Betmans Concept

- url: https://www.tradingview.com/script/Ls8g0pPr-The-Betmans-Concept/
- type: indicator
- pine_id: PUB;3436e03269f44ce68c2a4a8bbdcd0834
- version: 1.0

## Description

Overview
The Betmans Concept is a clean, precise, and systematic Smart Money Concepts (SMC) & ICT trading tool designed to automatically identify structural breaks and high-probability Order Blocks (OB). 

This script focuses strictly on **Body-to-Body Order Blocks** aligned with market structure shifts (MSS), break of structure (BOS), and Fair Value Gaps (FVG) / Imbalances to eliminate market noise and highlight high-precision interest zones.

---

Key Features

1. ICT Body-to-Body Order Blocks
Clean Representation:** Draws Order Blocks using body-to-body price boundaries (ignoring upper/lower wicks for precise zone mapping).
Border-Free Visuals:** Clean green and red filled boxes with zero border clutter.
Bullish OB:** Marked with a clear Green box.
Bearish OB:** Marked with a clear Red box.

 2. Smart Structure Breaks (BOS vs. MSS)
Market Structure Shift (MSS):** Automatically detects trend reversals and marks them clearly when price shifts character.
Break of Structure (BOS) Identifies trend continuation breaks.
Dotted Structure Lines: Draws horizontal dotted projection lines directly at swing highs/lows with inline text labeling.

 3. Imbalance / FVG Validation Filter
* Order blocks are dynamically validated only when backed by an active **Fair Value Gap (Imbalance)** to filter out fakeouts and low-quality levels.

---

## How to Use
1. **Identify Trend Direction:** Look at the latest MSS or BOS line to determine current market flow.
2. **Locate Key Zones:** Wait for price to trace back into the highlighted Green (Bullish) or Red (Bearish) Order Block boxes.
3. **Execution:** Look for entry confirmations when price reacts off the body-to-body Order Block boundary.

---

 Settings & Customization
* **Swing Length:** Adjust pivot detection sensitivity for structure breaks.
* **Show Structure Lines:** Toggle BOS/MSS dotted lines on or off.
* **Color Controls:** Fully customizable colors for order block fills and structure lines.

## Source Code

````pine
//@version=6
indicator("The Betmans Concept", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ==========================================
// INPUTS & SETTINGS
// ==========================================
swingLength = input.int(5, title="Swing Length (Structure Detection)", minval=1)
showLines   = input.bool(true, title="Show Structure Lines (BOS/MSS)")
bullColor   = input.color(color.new(#00E676, 70), title="Bullish Order Block Color")
bearColor   = input.color(color.new(#FF5252, 70), title="Bearish Order Block Color")
bullLineCol = input.color(color.green, title="Bullish Structure Line Color")
bearLineCol = input.color(color.red, title="Bearish Structure Line Color")

// ==========================================
// SWING HIGHS & LOWS DETECTION
// ==========================================
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow  = ta.pivotlow(low, swingLength, swingLength)

var float lastSwingHigh = na
var int   lastSwingHighIdx = na
var float lastSwingLow  = na
var int   lastSwingLowIdx  = na

if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighIdx := bar_index[swingLength]

if not na(swingLow)
    lastSwingLow    := swingLow
    lastSwingLowIdx := bar_index[swingLength]

// Market State Tracking (1 = Bullish Trend, -1 = Bearish Trend)
var int marketState = 0 

// ==========================================
// IMBALANCE (FAIR VALUE GAP) DETECTION
// ==========================================
bullishFVG = low > high[2]
bearishFVG = high < low[2]

// ==========================================
// STRUCTURE BREAKS (BOS vs MSS)
// ==========================================
bullishBreak = not na(lastSwingHigh) and ta.crossover(close, lastSwingHigh)
bearishBreak = not na(lastSwingLow) and ta.crossunder(close, lastSwingLow)

// Order Block Validation with FVG Filter
validBullishOB = bullishBreak and (bullishFVG or bullishFVG[1] or bullishFVG[2])
validBearishOB = bearishBreak and (bearishFVG or bearishFVG[1] or bearishFVG[2])

// ==========================================
// DRAW STRUCTURE LINES (BOS / MSS)
// ==========================================
if bullishBreak
    string structText = (marketState == -1 or marketState == 0) ? "MSS" : "BOS"
    marketState := 1 // Set trend to Bullish

    if showLines and not na(lastSwingHighIdx)
        // Fixed Pine v6 Syntax: x1, y1, x2, y2
        line.new(x1=lastSwingHighIdx, y1=lastSwingHigh, 
                 x2=bar_index, y2=lastSwingHigh, 
                 xloc=xloc.bar_index, style=line.style_dotted, 
                 color=bullLineCol, width=1)
        
        // Midpoint label on the line
        int midBar = math.round((lastSwingHighIdx + bar_index) / 2)
        label.new(x=midBar, y=lastSwingHigh, text=structText, 
                  color=color.new(color.white, 100), 
                  textcolor=bullLineCol, 
                  style=label.style_label_down, 
                  size=size.small)
        
    lastSwingHigh := na // Reset after break

if bearishBreak
    string structText = (marketState == 1 or marketState == 0) ? "MSS" : "BOS"
    marketState := -1 // Set trend to Bearish

    if showLines and not na(lastSwingLowIdx)
        // Fixed Pine v6 Syntax: x1, y1, x2, y2
        line.new(x1=lastSwingLowIdx, y1=lastSwingLow, 
                 x2=bar_index, y2=lastSwingLow, 
                 xloc=xloc.bar_index, style=line.style_dotted, 
                 color=bearLineCol, width=1)
        
        // Midpoint label on the line
        int midBar = math.round((lastSwingLowIdx + bar_index) / 2)
        label.new(x=midBar, y=lastSwingLow, text=structText, 
                  color=color.new(color.white, 100), 
                  textcolor=bearLineCol, 
                  style=label.style_label_up, 
                  size=size.small)
        
    lastSwingLow := na // Reset after break

// ==========================================
// DRAW ORDER BLOCKS (BODY TO BODY)
// ==========================================
// Bullish OB
if validBullishOB
    int obOffset = 1
    for i = 1 to 5
        if close[i] < open[i]
            obOffset := i
            break

    float obTop    = math.max(open[obOffset], close[obOffset])
    float obBottom = math.min(open[obOffset], close[obOffset])
    
    box.new(left=bar_index - obOffset, top=obTop, right=bar_index + 12, bottom=obBottom, 
            bgcolor=bullColor, border_color=color.new(color.green, 100))

// Bearish OB
if validBearishOB
    int obOffset = 1
    for i = 1 to 5
        if close[i] > open[i]
            obOffset := i
            break

    float obTop    = math.max(open[obOffset], close[obOffset])
    float obBottom = math.min(open[obOffset], close[obOffset])

    box.new(left=bar_index - obOffset, top=obTop, right=bar_index + 12, bottom=obBottom, 
            bgcolor=bearColor, border_color=color.new(color.red, 100))
````
