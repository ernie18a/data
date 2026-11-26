# Liquidity & Volume Profile Framework [invincible3]

- url: https://www.tradingview.com/script/SvJZR2Am-Liquidity-Volume-Profile-Framework-invincible3/
- type: indicator
- pine_id: PUB;02e9931251714140a49f9783988257a6
- version: 1.0

## Description

[b]Liquidity & Volume Profile Framework [invincible3][/b]

The Liquidity & Volume Profile Framework is a price-action and volume-profile framework designed to help traders identify high-probability trading zones using liquidity, value area structure, fair value gaps, and volume confirmation.

This indicator is built around the idea that strong trades usually happen when price reacts around important institutional zones such as POC, VAH, VAL, HVN/LVN areas, and liquidity pools created around equal highs and equal lows.

The tool does not simply give random buy or sell signals. Instead, it maps the market structure so the trader can wait for proper confluence before entering.

[b]Core Concept[/b]

This indicator follows a structured institutional trading workflow:

[b]Step 1 — Read the Market Structure[/b]

The indicator identifies key volume-profile levels:

[b]POC — Point of Control[/b]
The price level with the highest volume concentration inside the selected lookback range.

[b]VAH / VAL — Value Area High and Value Area Low[/b]
The upper and lower boundary of the value area, based on the selected value-area percentage.

[b]HVN / LVN Zones[/b]
High-volume and low-volume areas are displayed as volume-profile bars.
HVN zones can act like magnets, while LVN zones often behave like thin liquidity zones where price can move quickly.

[b]BSL / SSL Liquidity Pools[/b]
The indicator tracks swing highs and swing lows to identify potential buy-side liquidity and sell-side liquidity.

[b]Step 2 — Wait for a Trigger[/b]

The indicator highlights possible institutional reaction triggers:

[b]Liquidity Sweep[/b]
A bullish sweep occurs when price takes out a prior swing low and closes back above it.
A bearish sweep occurs when price takes out a prior swing high and closes back below it.

This helps identify possible stop-hunt behavior around liquidity pools.

[b]Fair Value Gap — FVG[/b]
Bullish and bearish imbalance zones are detected automatically.
These areas can act as retracement zones where price may return before continuation.

[b]VA / POC Touch[/b]
Reactions around VAH, VAL, or POC can provide important confluence when combined with sweep or FVG logic.

[b]Step 3 — Confirm with Volume[/b]

The indicator includes a volume spike condition.

A volume spike is detected when current volume is greater than the selected moving-average volume multiplied by the chosen spike multiplier.

By default, the logic uses:

Volume > 1.5 × Average Volume

This helps highlight moments where institutional participation may be stronger than normal.

[b]Step 4 — Entry Logic[/b]

The strongest setups usually appear when multiple conditions align in the same zone:

Liquidity sweep + FVG fill + VAH / VAL / POC reaction + volume spike

[b]Example bullish setup:[/b]

Price sweeps sell-side liquidity below a prior swing low, closes back above the level, returns into a bullish FVG, reacts near VAL or POC, and shows increased volume.

[b]Example bearish setup:[/b]

Price sweeps buy-side liquidity above a prior swing high, closes back below the level, returns into a bearish FVG, reacts near VAH or POC, and shows increased volume.

[b]Step 5 — Risk Framework[/b]

The indicator is designed to support structured risk planning:

[b]Stop Loss[/b]
Usually placed just beyond the swept liquidity level.

[b]Target 1[/b]
Often the POC or opposite value-area boundary.

[b]Target 2[/b]
The opposing liquidity pool or major high-volume / low-volume area.

[b]Visual Legend[/b]

Orange line — POC
Dotted adaptive lines — VAH / VAL
Gold bars — High-volume areas / HVN
Purple bars — Low-volume areas / LVN
Green dashed sweep line — Sell-side liquidity sweep
Red dashed sweep line — Buy-side liquidity sweep
Green boxes — Bullish Fair Value Gaps
Red boxes — Bearish Fair Value Gaps
Gold circles — Volume spike confirmation

[b]Main Features[/b]
[list]
[*]Automatic fixed-lookback volume profile
[*]POC, VAH, and VAL calculation
[*]High-volume and low-volume profile bars
[*]Bullish and bearish liquidity sweep detection
[*]Buy-side and sell-side liquidity mapping
[*]Automatic bullish and bearish FVG zones
[*]FVG extension until fill or expiry
[*]Volume spike confirmation using volume moving average
[*]Theme-adaptive colors for dark and light charts
[*]Institutional-style visual framework
[*]Clean overlay design for price-action trading
[/list]

[b]Best Timeframes[/b]

This tool works best when used with a top-down approach.

[b]For structure:[/b]

4H / Daily

[b]For entries:[/b]

15m / 1H

[b]Recommended workflow:[/b]

Use higher timeframe to identify POC, VAH, VAL, HVN, LVN, and major liquidity pools.
Then use lower timeframe to wait for liquidity sweep, FVG reaction, rejection candle, and volume confirmation.

[b]Suggested Settings[/b]

[b]For intraday trading:[/b]

VP Lookback: 100–200
VP Rows: 40–60
Value Area: 70%
Pivot Length: 5–10
Volume MA: 20
Volume Spike Multiplier: 1.5

[b]For swing trading:[/b]

VP Lookback: 200–300
VP Rows: 50–80
Value Area: 70%
Pivot Length: 10–20
Volume MA: 20–50
Volume Spike Multiplier: 1.5–2.0

[b]Important Notes[/b]

This indicator is not a standalone buy/sell signal system.
It is a confluence framework.

The highest-quality trades usually occur when liquidity, volume profile, imbalance, candle rejection, and volume confirmation all align in the same area.

Always wait for candle-close confirmation before entering.
Use proper stop loss and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("Liquidity & Volume Profile Framework [invincible3]", "Liq Vol", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Theme-Adaptive & Institutional Colors ---
// Standardized colors that look great on both light and dark themes
color_bull   = #089981 // TV Green
color_bear   = #f23645 // TV Red
color_gold   = #FFB300 // Soft Gold
color_purple = #7E57C2 // Soft Purple
color_poc    = #FF9800 // Vibrant Orange
color_text   = chart.fg_color // Adapts to light/dark mode automatically
color_va_bg  = color.new(chart.fg_color, 96) // Ultra-subtle adaptive background

// --- Inputs ---
grp_vp  = "Volume Profile"
vpLookback = input.int(200, "VP Lookback", group = grp_vp)
vpRows     = input.int(50, "VP Rows", group = grp_vp)
vaPct      = input.float(70, "Value Area %", group = grp_vp)

grp_liq = "Liquidity & Sweeps"
pivotLen   = input.int(10, "Pivot Length", group = grp_liq)

grp_fvg = "Fair Value Gaps"
showFvg    = input.bool(true, "Show FVGs", group = grp_fvg)
fvgMaxLen  = input.int(50, "Max FVG Length (Candles)", minval = 1, tooltip = "Stop drawing FVG if not filled within this many candles", group = grp_fvg)

grp_vol = "Volume Confirmation"
volMaLen   = input.int(20, "Volume MA Length", group = grp_vol)
volMult    = input.float(1.5, "Volume Spike Multiplier", group = grp_vol)

// --- Volume Spike Confirmation ---
volSma = ta.sma(volume, volMaLen)
volSpike = volume > volSma * volMult
volRatio = volume / volSma

// Gradient color: more intense gold as the volume ratio increases
spikeColor = color.from_gradient(volRatio, volMult, volMult * 2, color.new(color_gold, 80), color.new(color_gold, 10))

// Plot volume spike as a subtle bubble on the chart
plotshape(volSpike, title="Volume Spike", style=shape.circle, location=location.belowbar, color=spikeColor, size=size.tiny)

// --- Fair Value Gaps ---
var box[] bullFvgs = array.new_box()
var box[] bearFvgs = array.new_box()

bullFvg = low > high[2] and close[1] > open[1]
bearFvg = high < low[2] and close[1] < open[1]

if bullFvg and showFvg
    // Sleek 85% transparency for a modern UI feel
    b = box.new(bar_index[2], high[2], bar_index, low, border_color = na, bgcolor = color.new(color_bull, 85))
    array.push(bullFvgs, b)

if bearFvg and showFvg
    b = box.new(bar_index[2], low[2], bar_index, high, border_color = na, bgcolor = color.new(color_bear, 85))
    array.push(bearFvgs, b)

// Mitigation logic
if array.size(bullFvgs) > 0
    for i = array.size(bullFvgs) - 1 to 0
        b = array.get(bullFvgs, i)
        bottom = box.get_bottom(b)
        if low < bottom or (bar_index - box.get_left(b)) >= fvgMaxLen
            box.set_right(b, bar_index)
            array.remove(bullFvgs, i)
        else
            box.set_right(b, bar_index)

if array.size(bearFvgs) > 0
    for i = array.size(bearFvgs) - 1 to 0
        b = array.get(bearFvgs, i)
        top = box.get_top(b)
        if high > top or (bar_index - box.get_left(b)) >= fvgMaxLen
            box.set_right(b, bar_index)
            array.remove(bearFvgs, i)
        else
            box.set_right(b, bar_index)

// --- Liquidity Sweeps ---
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPh = na
var float lastPl = na
var int lastPhIdx = na
var int lastPlIdx = na

if not na(ph)
    lastPh := ph
    lastPhIdx := bar_index[pivotLen]
if not na(pl)
    lastPl := pl
    lastPlIdx := bar_index[pivotLen]

// Sweep detection
bullSweep = not na(lastPl) and low < lastPl and close > lastPl
bearSweep = not na(lastPh) and high > lastPh and close < lastPh

if bullSweep
    // Sweeping SSL (Lows) is a bullish event -> Use bullish color
    line.new(lastPlIdx, lastPl, bar_index, lastPl, color = color.new(color_bull, 20), style = line.style_dashed)
    // Tiny label size so it doesn't clutter the chart
    label.new(bar_index, low, "SSL", style = label.style_label_up, color = #00000000, textcolor = color.new(color_text, 30), size = size.small)
    lastPl := na // Reset

if bearSweep
    // Sweeping BSL (Highs) is a bearish event -> Use bearish color
    line.new(lastPhIdx, lastPh, bar_index, lastPh, color = color.new(color_bear, 20), style = line.style_dashed)
    label.new(bar_index, high, "BSL", style = label.style_label_down, color = #00000000, textcolor = color.new(color_text, 30), size = size.small)
    lastPh := na // Reset

// --- Simple Volume Profile Simulation (Fixed Lookback) ---
minP = ta.lowest(low, vpLookback)
maxP = ta.highest(high, vpLookback)

if barstate.islast
    rowSize = (maxP - minP) / vpRows
    
    volArray = array.new_float(vpRows, 0.0)
    
    for i = 0 to vpLookback - 1
        idx = math.floor((close[i] - minP) / rowSize)
        idx := math.max(0, math.min(vpRows - 1, idx))
        array.set(volArray, idx, array.get(volArray, idx) + volume[i])
        
    totalVol = array.sum(volArray)
    pocVol = array.max(volArray)
    pocIdx = array.indexof(volArray, pocVol)
    
    // Calculate Value Area
    vaVolTarget = totalVol * (vaPct / 100)
    currentVaVol = pocVol
    upIdx = pocIdx + 1
    dnIdx = pocIdx - 1
    
    while currentVaVol < vaVolTarget and (upIdx < vpRows or dnIdx >= 0)
        upVol = upIdx < vpRows ? array.get(volArray, upIdx) : 0
        dnVol = dnIdx >= 0 ? array.get(volArray, dnIdx) : 0
        
        if upVol >= dnVol and upIdx < vpRows
            currentVaVol += upVol
            upIdx += 1
        else if dnIdx >= 0
            currentVaVol += dnVol
            dnIdx -= 1
            
    valIdx = dnIdx + 1
    vahIdx = upIdx - 1
    
    pocPrice = minP + (pocIdx * rowSize)
    valPrice = minP + (valIdx * rowSize)
    vahPrice = minP + (vahIdx * rowSize)
    
    // Draw VAH/VAL shaded zone (Adaptive to theme)
    box.new(bar_index - vpLookback, vahPrice, bar_index, valPrice, border_color = na, bgcolor = color_va_bg)
    line.new(bar_index - vpLookback, vahPrice, bar_index, vahPrice, color = color.new(color_text, 60), style = line.style_dotted)
    line.new(bar_index - vpLookback, valPrice, bar_index, valPrice, color = color.new(color_text, 60), style = line.style_dotted)
    line.new(bar_index - vpLookback, pocPrice, bar_index, pocPrice, color = color_poc, style = line.style_solid, width = 2)
    
    // Draw bars
    for i = 0 to vpRows - 1
        v = array.get(volArray, i)
        if v > 0
            price = minP + (i * rowSize)
            len = math.round((v / pocVol) * 50)
            
            c = i == pocIdx ? color_poc : i >= valIdx and i <= vahIdx ? color.new(color_text, 50) : v > (pocVol * 0.7) ? color.new(color_gold, 20) : color.new(color_purple, 40)
            line.new(bar_index + 5, price, bar_index + 5 + len, price, color = c, width = 2)
````
