# CONTINO - FVG & iFVG Premium

- url: https://www.tradingview.com/script/QHPYD07Z-CONTINO-FVG-iFVG-Premium/
- type: indicator
- pine_id: PUB;8e2f426af67f4824b4a696b6899e337a
- version: 1.0

## Description

CONTINO – FVG & iFVG Premium (v3.0).
CONTINO – FVG & iFVG Premium is a focused overlay indicator for trading Fair Value Gaps the way they are meant to be traded: only the imbalances that carry real displacement, and with the market's own reaction to a filled gap turned into a fresh opportunity — the Inversion Fair Value Gap (iFVG).
It works on any market and timeframe: indices and futures (MNQ, ES, NQ…), forex, crypto and equities.
1. FVG detection with a real quality filter
Detects three-candle Fair Value Gaps, bullish and bearish, anchored to the first candle of the formation.
Displacement requirement: the middle candle must close in the direction of the move (close[1] > open[1] for bullish gaps, close[1] < open[1] for bearish ones). Gaps with no impulse behind them are skipped.
Volatility threshold: the gap must be at least ATR(14) × threshold in size (default 0.2, set to 0 to disable). This is the single most effective control for keeping the chart readable — raise it to isolate only significant imbalances, lower it to see more.
2. FVG → iFVG inversion
When a gap is mitigated, it does not simply vanish: the script inverts it. The zone flips colour and label to iFVG and becomes a new point of interest in the opposite direction — the classic inversion setup, where failed demand becomes supply and failed supply becomes demand.
Mitigation definition is yours: Filled FVG Type = Wick treats a mere wick touch as a fill; Close (default) requires a candle body to close through the gap — the more conservative, higher-quality option.
Delete Boxes after fill? removes a filled gap immediately instead of inverting it. Note that this option takes priority and only applies while Show iFVG is disabled — if inversions are enabled, the zone always converts rather than being deleted.
3. Consequent Encroachment (centre line)
Each zone carries its 50% midpoint line — the Consequent Encroachment level used by ICT traders as the refined entry point inside a gap.
Optional, with its own colour, width and style (solid / dashed / dotted) for FVG and iFVG separately, so the midpoint reads clearly against the zone fill.
4. Chart control
Max FVGs to Display (15 by default) caps the number of zones on screen: the oldest is removed automatically as new ones form, so historical noise never buries current price action.
Extend Boxes? projects every zone to the current bar, or uses a fixed length (5 candles by default) for a minimal look.
Optional labels with fully customisable text for FVG and iFVG.
Complete styling control: separate background, border and midpoint colours for bullish FVG, bearish FVG, bullish iFVG and bearish iFVG, plus border style and width.
How to use it
Trade FVGs in the direction of structure. Look for price returning to an unmitigated gap that lines up with your market-structure read — that is where the highest-probability continuation entries sit.
Use the centre line for precision. Rather than entering at the edge of a gap, many traders wait for price to reach the Consequent Encroachment (the 50% line), which offers a tighter stop and a better reward-to-risk.
Watch for the inversion. When a gap fails and flips to an iFVG, that zone now acts as a level in the other direction — a failed bullish gap becomes supply, and vice versa. These are among the cleanest reaction points on a chart after a liquidity sweep.
Tune the volatility threshold to your instrument. Higher-volatility instruments and lower timeframes generate more gaps; a slightly higher threshold keeps only the ones worth trading.
Notes
Overlay indicator (Pine v6). Drawing limits: 500 boxes, 500 lines and 500 labels.
FVG detection is evaluated on the current bar's formation and does not repaint on closed bars.
With Delete Boxes after fill? enabled and Show iFVG disabled, filled zones disappear — invert them instead by enabling Show iFVG.
This script plots and manages zones only; it does not include alert conditions.
Educational content, not financial advice. Test the settings on your own market and timeframe before trading.

## Source Code

````pine
//@version=6
indicator("CONTINO - FVG & iFVG Premium", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ==============================================================================
// INPUTS
// ==============================================================================
var G_GENERAL = "General Settings"
showFvg       = input.bool(true, "Show FVG", group = G_GENERAL)
showIfvg      = input.bool(true, "Show iFVG (Inversion FVG)", group = G_GENERAL)
filledType    = input.string("Close", "Filled FVG Type", options = ["Wick", "Close"], group = G_GENERAL)
maxFvgs       = input.int(15, "Max FVGs to Display", minval = 1, maxval = 500, group = G_GENERAL, tooltip = "Limits the number of historical FVGs drawn on the chart to keep it clean.")
volThreshold  = input.float(0.2, "Volatility Threshold", minval = 0.0, step = 0.1, group = G_GENERAL, tooltip = "Filters out FVGs smaller than this value multiplied by the ATR. 0 disables the filter.")

var G_LABELS  = "Label Settings"
showLabels    = input.bool(false, "Show Labels?", group = G_LABELS)
fvgLabelTxt   = input.string("FVG", "FVG Label Text", inline = "l1", group = G_LABELS)
ifvgLabelTxt  = input.string("iFVG", "iFVG Label Text", inline = "l1", group = G_LABELS)

var G_BOXES   = "Box Settings"
deleteFilled  = input.bool(true, "Delete Boxes after fill?", group = G_BOXES, tooltip = "Deletes the FVG immediately when filled. (Only works if Show iFVG is disabled)")
extendBoxes   = input.bool(false, "Extend Boxes?", group = G_BOXES, tooltip = "If true, extends lines/boxes to current price. If false, uses fixed length.")
boxLength     = input.int(5, "Length of Boxes (if not extended)", minval = 1, group = G_BOXES)

var G_COLORS  = "Colors - Background"
bullFvgBg     = input.color(color.new(#089981, 70), "FVG Bullish", inline = "c1", group = G_COLORS)
bearFvgBg     = input.color(color.new(#f23645, 70), "FVG Bearish", inline = "c1", group = G_COLORS)
bullIfvgBg    = input.color(color.new(#2962ff, 70), "iFVG Bullish", inline = "c2", group = G_COLORS)
bearIfvgBg    = input.color(color.new(#ff9800, 70), "iFVG Bearish", inline = "c2", group = G_COLORS)

var G_BORDERS = "Border Settings"
borderStyleIn = input.string("Solid", "Border style", options = ["Solid", "Dashed", "Dotted"], group = G_BORDERS)
borderWidth   = input.int(1, "Border Width", minval = 1, group = G_BORDERS)
bullFvgBdr    = input.color(color.new(#089981, 100), "FVG Border Bullish", inline = "b1", group = G_BORDERS)
bearFvgBdr    = input.color(color.new(#f23645, 100), "FVG Border Bearish", inline = "b1", group = G_BORDERS)
bullIfvgBdr   = input.color(color.new(#2962ff, 100), "iFVG Border Bullish", inline = "b2", group = G_BORDERS)
bearIfvgBdr   = input.color(color.new(#ff9800, 100), "iFVG Border Bearish", inline = "b2", group = G_BORDERS)

var G_MID     = "Center Line (Consequent Encroachment)"
showMid       = input.bool(true, "Show Center Line?", group = G_MID)
midStyleIn    = input.string("Solid", "Center Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_MID)
midWidth      = input.int(1, "Center Line Width", minval = 1, group = G_MID)
bullFvgMid    = input.color(color.new(#089981, 75), "FVG Mid Bullish", inline = "m1", group = G_MID)
bearFvgMid    = input.color(color.new(#f23645, 75), "FVG Mid Bearish", inline = "m1", group = G_MID)
bullIfvgMid   = input.color(color.new(#2962ff, 0), "iFVG Mid Bullish", inline = "m2", group = G_MID)
bearIfvgMid   = input.color(color.new(#ff9800, 0), "iFVG Mid Bearish", inline = "m2", group = G_MID)

// ==============================================================================
// TYPES & ARRAYS
// ==============================================================================
type FVG
    box bx
    line midLine
    label lbl
    float top
    float btm
    float mid
    bool isBullish
    bool isActive
    bool isInv

var fvgArray = array.new<FVG>()

// ==============================================================================
// FUNCTIONS
// ==============================================================================
getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

b_style = getLineStyle(borderStyleIn)
m_style = getLineStyle(midStyleIn)

deleteFvgObjects(FVG f) =>
    box.delete(f.bx)
    line.delete(f.midLine)
    label.delete(f.lbl)

// ==============================================================================
// LOGIC
// ==============================================================================
bool isBullFvg = low > high[2] and close[1] > open[1]
bool isBearFvg = high < low[2] and close[1] < open[1]
float atr14 = ta.atr(14)

if showFvg
    if isBullFvg
        float top = low
        float btm = high[2]
        float mid = (top + btm) / 2
        int rightBar = extendBoxes ? bar_index : bar_index + boxLength
        
        if (top - btm) >= (atr14 * volThreshold)
            b = box.new(bar_index[2], top, rightBar, btm, border_color = bullFvgBdr, border_width = borderWidth, border_style = b_style, bgcolor = bullFvgBg)
            l = showMid ? line.new(bar_index[2], mid, rightBar, mid, color = bullFvgMid, width = midWidth, style = m_style) : na
            lb = showLabels ? label.new(bar_index[2], mid, fvgLabelTxt, color = color.new(color.black, 100), textcolor = bullFvgBdr, style = label.style_label_center, size = size.tiny) : na
            
            fvgArray.push(FVG.new(b, l, lb, top, btm, mid, true, true, false))

    if isBearFvg
        float top = low[2]
        float btm = high
        float mid = (top + btm) / 2
        int rightBar = extendBoxes ? bar_index : bar_index + boxLength
        
        if (top - btm) >= (atr14 * volThreshold)
            b = box.new(bar_index[2], top, rightBar, btm, border_color = bearFvgBdr, border_width = borderWidth, border_style = b_style, bgcolor = bearFvgBg)
            l = showMid ? line.new(bar_index[2], mid, rightBar, mid, color = bearFvgMid, width = midWidth, style = m_style) : na
            lb = showLabels ? label.new(bar_index[2], mid, fvgLabelTxt, color = color.new(color.black, 100), textcolor = bearFvgBdr, style = label.style_label_center, size = size.tiny) : na
            
            fvgArray.push(FVG.new(b, l, lb, top, btm, mid, false, true, false))

// Update existing FVGs
if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        FVG f = fvgArray.get(i)
        
        if f.isActive
            bool isMitigated = false
            
            // Check Mitigation
            if f.isBullish
                if filledType == "Wick"
                    if low <= f.btm
                        isMitigated := true
                else
                    if close <= f.btm
                        isMitigated := true
            else
                if filledType == "Wick"
                    if high >= f.top
                        isMitigated := true
                else
                    if close >= f.top
                        isMitigated := true

            if isMitigated
                if deleteFilled and not showIfvg
                    deleteFvgObjects(f)
                    fvgArray.remove(i)
                else if showIfvg
                    f.isInv := true
                    f.isActive := false
                    f.isBullish := not f.isBullish
                    
                    box.set_right(f.bx, bar_index)
                    box.set_bgcolor(f.bx, f.isBullish ? bullIfvgBg : bearIfvgBg)
                    box.set_border_color(f.bx, f.isBullish ? bullIfvgBdr : bearIfvgBdr)
                    
                    if not na(f.midLine)
                        line.set_x2(f.midLine, bar_index)
                        line.set_color(f.midLine, f.isBullish ? bullIfvgMid : bearIfvgMid)
                        
                    if not na(f.lbl)
                        label.set_text(f.lbl, ifvgLabelTxt)
                        label.set_textcolor(f.lbl, f.isBullish ? bullIfvgBdr : bearIfvgBdr)
                else
                    f.isActive := false
                    box.set_right(f.bx, bar_index)
                    if not na(f.midLine)
                        line.set_x2(f.midLine, bar_index)
            else
                if extendBoxes
                    box.set_right(f.bx, bar_index)
                    if not na(f.midLine)
                        line.set_x2(f.midLine, bar_index)

// Cleanup old FVGs to enforce maxFvgs limit
if array.size(fvgArray) > maxFvgs
    int excess = array.size(fvgArray) - maxFvgs
    for i = 0 to excess - 1
        FVG oldestFvg = fvgArray.shift()
        deleteFvgObjects(oldestFvg)
````
