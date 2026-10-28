# Institutional FVG + Market Structure Shift

- url: https://www.tradingview.com/script/YtH4ptx9-Institutional-FVG-Market-Structure-Shift/
- type: indicator
- pine_id: PUB;22931830c3224f9cb102dab6cc09691b
- version: 1.0

## Description

fvg this shit out for anyone else. im just typing because its making me add detials to the indicator i created. i aint got time for that shit

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Institutional FVG + Market Structure Shift", overlay = true, max_boxes_count = 100)

// --- Groups ---
string G_PROB = "High Probability Setup"
string G_VIS  = "Visuals"

// --- Inputs ---
int   mssLookback = input.int(10, "Market Structure Lookback", minval = 2, group = G_PROB, tooltip = "Lookback for recent Swing Highs/Lows. The FVG must break this structure to be valid.")
float dispMult    = input.float(1.5, "Min Displacement (ATR)", minval = 0.0, step = 0.1, group = G_PROB, tooltip = "Middle candle body must be explosive.")
float gapMin      = input.float(0.3, "Min Gap Size (ATR)", minval = 0.0, step = 0.1, group = G_PROB)
bool  volFilter   = input.bool(true, "Relative Volume Filter", group = G_PROB)
int   maxGaps     = input.int(2, "Max Active Gaps (Ultra Clean)", minval = 1, maxval = 10, group = G_VIS)

color bullColor  = input.color(color.new(#089981, 90), "Bullish FVG", group = G_VIS)
color bearColor  = input.color(color.new(#f23645, 90), "Bearish FVG", group = G_VIS)
color bullBorder = input.color(color.new(#089981, 60), "Bullish Border", group = G_VIS)
color bearBorder = input.color(color.new(#f23645, 60), "Bearish Border", group = G_VIS)

// --- Types ---
type FvgBox
    box   b
    float top
    float bottom
    bool  isBull

// --- Arrays ---
var bullGaps = array.new<FvgBox>()
var bearGaps = array.new<FvgBox>()

// --- Core Logic ---
atr = ta.atr(14)
avgVol = ta.sma(volume, 20)

// 1. Market Structure Shift (MSS)
// We look for the displacement candle (bar[1]) to break the highest/lowest of the previous 'n' bars.
recentHigh = ta.highest(high, mssLookback)[2]
recentLow  = ta.lowest(low, mssLookback)[2]

mssBull = close[1] > recentHigh
mssBear = close[1] < recentLow

// 2. Displacement & Volume
middleBody = math.abs(close[1] - open[1])
isDisplaced = middleBody > (atr * dispMult)
isHighVol = not volFilter or volume[1] > avgVol

// 3. Gap Size
bullGapSize = low - high[2]
bearGapSize = low[2] - high

// Combined High-Probability Detection
// Setup must have: MSS + Displacement + Volume + Minimum Gap Size
isSetupBull = mssBull and isDisplaced and isHighVol and bullGapSize > (atr * gapMin) and close[1] > open[1]
isSetupBear = mssBear and isDisplaced and isHighVol and bearGapSize > (atr * gapMin) and close[1] < open[1]

// Function to handle mitigation and cleanup
processGaps(array<FvgBox> gapArray) =>
    if array.size(gapArray) > 0
        for i = array.size(gapArray) - 1 to 0
            FvgBox g = array.get(gapArray, i)
            mitigated = g.isBull ? low < g.bottom : high > g.top
            
            if mitigated
                box.delete(g.b)
                array.remove(gapArray, i)
            else
                box.set_right(g.b, bar_index + 3)
    true

// Function to check for overlap
isOverlapping(float top, float bottom, array<FvgBox> gapArray) =>
    overlap = false
    if array.size(gapArray) > 0
        for i = 0 to array.size(gapArray) - 1
            FvgBox g = array.get(gapArray, i)
            if not (top < g.bottom or bottom > g.top)
                overlap := true
                break
    overlap

// Cleanup
processGaps(bullGaps)
processGaps(bearGaps)

// New Setup Execution
if isSetupBull and not isOverlapping(low, high[2], bullGaps)
    if array.size(bullGaps) >= maxGaps
        FvgBox oldest = array.shift(bullGaps)
        box.delete(oldest.b)
    
    FvgBox newG = FvgBox.new(
         box.new(bar_index - 2, low, bar_index + 3, high[2], border_color = bullBorder, bgcolor = bullColor, border_style = line.style_dotted),
         low,
         high[2],
         true
         )
    array.push(bullGaps, newG)
    label.new(bar_index - 1, low, "MSS + FVG", color = #00000000, textcolor = bullBorder, style = label.style_label_up, size = size.small)

if isSetupBear and not isOverlapping(low[2], high, bearGaps)
    if array.size(bearGaps) >= maxGaps
        FvgBox oldest = array.shift(bearGaps)
        box.delete(oldest.b)

    FvgBox newG = FvgBox.new(
         box.new(bar_index - 2, low[2], bar_index + 3, high, border_color = bearBorder, bgcolor = bearColor, border_style = line.style_dotted),
         low[2],
         high,
         false
         )
    array.push(bearGaps, newG)
    label.new(bar_index - 1, high, "MSS + FVG", color = #00000000, textcolor = bearBorder, style = label.style_label_down, size = size.small)
````
