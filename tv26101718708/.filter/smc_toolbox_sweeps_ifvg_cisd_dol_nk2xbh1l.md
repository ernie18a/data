# SMC Toolbox: Sweeps, IFVG, CISD & DOL

- url: https://www.tradingview.com/script/nK2XBH1l-SMC-Toolbox-Sweeps-IFVG-CISD-DOL/
- type: indicator
- pine_id: PUB;98569554fcda4aacb8c1230a9557a84b
- version: 1.0

## Description

How it works:
Liquidity Sweeps: Identified when price moves beyond a recent swing high or low but closes back inside that level. These are marked with "Sweep" labels.
HTF Sweeps: The script uses request.security to fetch the previous high and low from a higher timeframe (defaulting to Daily). If the current price sweeps these levels, it is labeled as an HTF Sweep.
Inverse Fair Value Gaps (IFVG): The indicator tracks standard Fair Value Gaps. If a bullish FVG is breached and closed below, it is re-plotted as a bearish IFVG box. Conversely, if a bearish FVG is closed above, it becomes a bullish IFVG box.
Change in State of Delivery (CISD): This marks a shift in trend by identifying when price closes above the high of the last down candle (for bullish CISD) or below the low of the last up candle (for bearish CISD). These are marked with small circles.
Draw on Liquidity (DOL): The script highlights the most significant highs (BuySide Liquidity) and lows (SellSide Liquidity) within a user-defined lookback period, projecting them forward as the most likely price targets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("SMC Toolbox: Sweeps, IFVG, CISD & DOL", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- Settings ---
grp_sweeps = "Liquidity Sweeps"
sweepLen   = input.int(20, "Swing Detection Length", minval = 1, group = grp_sweeps, tooltip = "Lookback period to find swing highs/lows for sweeps.")
showHtf    = input.bool(true, "Show HTF Sweeps", group = grp_sweeps)
htfRes     = input.timeframe("D", "HTF Timeframe", group = grp_sweeps)

grp_ifvg   = "Inverse Fair Value Gaps"
showIfvg   = input.bool(true, "Show IFVG", group = grp_ifvg)
ifvgColorBull = input.color(color.new(#089981, 80), "Bullish IFVG", group = grp_ifvg)
ifvgColorBear = input.color(color.new(#f23645, 80), "Bearish IFVG", group = grp_ifvg)

grp_cisd   = "Change In State of Delivery (CISD)"
showCisd   = input.bool(true, "Show CISD", group = grp_cisd)

grp_dol    = "Draw On Liquidity (DOL)"
showDol    = input.bool(true, "Show DOL Targets", group = grp_dol)
dolLen     = input.int(50, "DOL Lookback Length", minval = 1, group = grp_dol)

// --- Constants ---
COLOR_BULL = #089981
COLOR_BEAR = #f23645

// --- Types ---
type Fvg
    float top
    float bottom
    int   startBar
    bool  isBull
    bool  inverted = false

// --- Core Logic ---

// 1. Liquidity Sweeps (Current TF)
float ph = ta.highest(high[1], sweepLen)
float pl = ta.lowest(low[1], sweepLen)

bool bullSweep = low < pl and close > pl
bool bearSweep = high > ph and close < ph

plotshape(bullSweep, "Bullish Sweep", shape.labelup, location.belowbar, COLOR_BULL, 0, "Sweep", color.white, size = size.tiny)
plotshape(bearSweep, "Bearish Sweep", shape.labeldown, location.abovebar, COLOR_BEAR, 0, "Sweep", color.white, size = size.tiny)

// 2. HTF Sweeps
[htfHigh, htfLow] = request.security(syminfo.tickerid, htfRes, [high[1], low[1]], lookahead = barmerge.lookahead_on)
bool htfBullSweep = low < htfLow and close > htfLow
bool htfBearSweep = high > htfHigh and close < htfHigh

if showHtf
    if htfBullSweep
        label.new(bar_index, low, "HTF Sweep", color = COLOR_BULL, style = label.style_label_up, textcolor = color.white, size = size.tiny)
    if htfBearSweep
        label.new(bar_index, high, "HTF Sweep", color = COLOR_BEAR, style = label.style_label_down, textcolor = color.white, size = size.tiny)

// 3. Fair Value Gaps & IFVG
var fvgArray = array.new<Fvg>()

// Detect New FVG
bool bullFvg = low > high[2]
bool bearFvg = high < low[2]

if bullFvg
    fvgArray.push(Fvg.new(low, high[2], bar_index[1], true))
if bearFvg
    fvgArray.push(Fvg.new(low[2], high, bar_index[1], false))

// Process FVGs
if fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        Fvg f = fvgArray.get(i)
        
        if not f.inverted
            if f.isBull and close < f.bottom
                f.inverted := true
                if showIfvg
                    box.new(f.startBar, f.top, bar_index, f.bottom, bgcolor = ifvgColorBear, border_color = color.new(COLOR_BEAR, 50), text = "IFVG", text_size = size.tiny, text_color = color.white)
            else if not f.isBull and close > f.top
                f.inverted := true
                if showIfvg
                    box.new(f.startBar, f.top, bar_index, f.bottom, bgcolor = ifvgColorBull, border_color = color.new(COLOR_BULL, 50), text = "IFVG", text_size = size.tiny, text_color = color.white)
        
        if bar_index - f.startBar > 500
            fvgArray.remove(i)

// 4. Change In State of Delivery (CISD)
var float lastUpHigh = na
var float lastDownLow = na

if close > open
    lastUpHigh := high
if close < open
    lastDownLow := low

bool cisdBull = close > lastDownLow[1] and close[1] <= lastDownLow[1]
bool cisdBear = close < lastUpHigh[1] and close[1] >= lastUpHigh[1]

// Use conditional series directly
plotshape(showCisd and cisdBull, "CISD Bull", shape.circle, location.belowbar, COLOR_BULL, 0, "CISD", color.white, size = size.tiny)
plotshape(showCisd and cisdBear, "CISD Bear", shape.circle, location.abovebar, COLOR_BEAR, 0, "CISD", color.white, size = size.tiny)

// 5. Draw On Liquidity (DOL)
float dolHigh = ta.highest(high, dolLen)
float dolLow  = ta.lowest(low, dolLen)

var line dolHLine = line.new(na, na, na, na, color = color.new(chart.fg_color, 50), style = line.style_dashed)
var line dolLLine = line.new(na, na, na, na, color = color.new(chart.fg_color, 50), style = line.style_dashed)
var label dolHLabel = label.new(na, na, "", color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)
var label dolLLabel = label.new(na, na, "", color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)

if showDol and barstate.islast
    line.set_xy1(dolHLine, bar_index - dolLen, dolHigh)
    line.set_xy2(dolHLine, bar_index, dolHigh)
    line.set_xy1(dolLLine, bar_index - dolLen, dolLow)
    line.set_xy2(dolLLine, bar_index, dolLow)
    
    label.set_xy(dolHLabel, bar_index, dolHigh)
    label.set_text(dolHLabel, "DOL (BuySide)")
    label.set_xy(dolLLabel, bar_index, dolLow)
    label.set_text(dolLLabel, "DOL (SellSide)")
````
