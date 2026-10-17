# RRE Zones 

- url: https://www.tradingview.com/script/k9fcmekG-RRE-Zones/
- type: indicator
- pine_id: PUB;6776a262483b42f08fc07a814ad43f8a
- version: 2.0

## Description

The error is box.style_dashed is not supported in this Pine Script version. Need to remove the border_style parameter from both breaker block box.new() calls.Edited 2 files, read a fileEdited 2 files, read a fileFixed. Both border_style=box.style_dashed lines removed from the Bearish Breaker and Bullish Breaker box.new() calls. The breaker blocks will now use the default solid border — they're still visually distinct from OBs via their different colors (orange BB ↓ / teal BB ↑) and lower fill transparency.

## Source Code

````pine
//@version=6
indicator('RRE Zones v6 1', overlay = true, max_boxes_count = 200, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── Settings ──
autoAdjust = input.bool(true, 'Auto-Adjust to Timeframe', group = 'Settings')
manualSwing = input.int(5, 'Manual Swing Length', group = 'Settings', minval = 2, maxval = 20)
manualImpulse = input.float(1.5, 'Manual Impulse Strength', group = 'Settings', minval = 0.5, maxval = 5.0, step = 0.1)

// ── Trend Filter ── (v6 NEW)
useTrendFilter = input.bool(false, 'Enable EMA Trend Filter', tooltip = 'Bull OBs only form above EMA · Bear OBs only form below EMA', group = 'Trend Filter')
emaLen = input.int(200, 'EMA Period', group = 'Trend Filter', minval = 20, maxval = 500)
showEMA = input.bool(false, 'Plot EMA on Chart', group = 'Trend Filter')

// ── Order Block Style ──
bullColor = input.color(#089981, 'Bullish OB Color', group = 'Order Block Style')
bearColor = input.color(#f23645, 'Bearish OB Color', group = 'Order Block Style')
obTransparency = input.int(85, 'OB Transparency', group = 'Order Block Style', minval = 0, maxval = 100)
borderWidth = input.int(1, 'Border Width', group = 'Order Block Style', minval = 1, maxval = 3)
mitigationType = input.string('Full', 'Mitigation Type', group = 'Order Block Style', options = ['Full', '50%'], tooltip = 'Full → close crosses zone edge  |  50% → close crosses OB midpoint')

// ── Breaker Blocks ── (v6 NEW)
showBreakers = input.bool(true, 'Show Breaker Blocks', tooltip = 'Mitigated OBs flip into a Breaker Block of the opposite polarity', group = 'Breaker Blocks')
bullBreakerColor = input.color(#00BCD4, 'Bullish Breaker', group = 'Breaker Blocks')
bearBreakerColor = input.color(#FF9800, 'Bearish Breaker', group = 'Breaker Blocks')
breakerTransp = input.int(88, 'Breaker Transparency', group = 'Breaker Blocks', minval = 0, maxval = 100)
maxBreakers = input.int(6, 'Max Breaker Zones', group = 'Breaker Blocks', minval = 2, maxval = 20)

// ── Fair Value Gap ──
showFVG = input.bool(true, 'Show Fair Value Gaps', group = 'Fair Value Gap')
bullFVGColor = input.color(#00E676, 'Bullish FVG', group = 'Fair Value Gap')
bearFVGColor = input.color(#FF1744, 'Bearish FVG', group = 'Fair Value Gap')
fvgTransparency = input.int(90, 'FVG Transparency', group = 'Fair Value Gap', minval = 0, maxval = 100)
maxFVGBoxes = input.int(15, 'Max FVG Zones', group = 'Fair Value Gap', minval = 5, maxval = 50)
fvgMinSize = input.float(0.1, 'Min FVG Size (% of ATR)', group = 'Fair Value Gap', minval = 0.05, maxval = 2.0, step = 0.05)

// ── Liquidity ──
showLiquidity = input.bool(true, 'Show Liquidity Levels', group = 'Liquidity')
liqPivotBars = input.int(2, 'Liquidity Confirmation Bars', group = 'Liquidity', minval = 1, maxval = 5, tooltip = 'Bars needed to confirm a swing point before drawing the line. Lower = appears faster (1-2 candles) but less reliable. Higher = slower but more reliable pivot.')
liqLookback = input.int(20, 'Liquidity Lookback', group = 'Liquidity', minval = 10, maxval = 100)
liqBuyColor = input.color(#00BCD4, 'Buy-Side Liquidity', group = 'Liquidity Style')
liqSellColor = input.color(#E91E63, 'Sell-Side Liquidity', group = 'Liquidity Style')
liqLineWidth = input.int(2, 'Liquidity Line Width', group = 'Liquidity Style', minval = 1, maxval = 4)
liqStyle = input.string('Solid', 'Line Style', group = 'Liquidity Style', options = ['Solid', 'Dashed', 'Dotted'])

// ── Display ──
maxBoxes = input.int(10, 'Max OB Zones', group = 'Display', minval = 5, maxval = 30)
maxLiqLines = input.int(5, 'Max Liquidity Lines', group = 'Display', minval = 3, maxval = 15)
extendRight = input.int(40, 'Extend Right Bars', group = 'Display', minval = 10, maxval = 100)
showInfo = input.bool(true, 'Show Info Table', group = 'Display')

// ══════════════════════════════════════════════════════════════════════════════
// AUTO-ADJUST PARAMETERS
// ══════════════════════════════════════════════════════════════════════════════

tfInMinutes = timeframe.in_seconds() / 60

getSwingLength() =>
    if not autoAdjust
        manualSwing
    else
        switch 
            tfInMinutes <= 1 => 2
            tfInMinutes <= 3 => 3
            tfInMinutes <= 5 => 3
            tfInMinutes <= 15 => 4
            tfInMinutes <= 30 => 5
            tfInMinutes <= 60 => 6
            tfInMinutes <= 240 => 7
            tfInMinutes <= 1440 => 9
            => 12

getImpulseStrength() =>
    if not autoAdjust
        manualImpulse
    else
        switch 
            tfInMinutes <= 1 => 3.5
            tfInMinutes <= 3 => 3.0
            tfInMinutes <= 5 => 2.8
            tfInMinutes <= 15 => 2.3
            tfInMinutes <= 30 => 2.0
            tfInMinutes <= 60 => 1.8
            tfInMinutes <= 240 => 1.5
            tfInMinutes <= 1440 => 1.2
            => 1.0

getMinImpulseCandles() =>
    if not autoAdjust
        3
    else
        switch 
            tfInMinutes <= 5 => 2
            tfInMinutes <= 15 => 2
            tfInMinutes <= 240 => 3
            => 4

swingLength = getSwingLength()
impulseFactor = getImpulseStrength()
minImpulseCandles = getMinImpulseCandles()

// ══════════════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════

atr = ta.atr(14)
impulseThreshold = atr * impulseFactor
fvgMinimumSize = atr * fvgMinSize
ema = ta.ema(close, emaLen)
uptrend = close > ema
downtrend = close < ema

// OB / FVG pivot detection — uses the auto-adjusted swingLength (slower, more reliable)
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow = ta.pivotlow(low, swingLength, swingLength)

// Liquidity pivot detection — uses its own short, fixed confirmation window
// so lines can appear after just 1-2 candles instead of waiting on swingLength
liqSwingHigh = ta.pivothigh(high, liqPivotBars, liqPivotBars)
liqSwingLow = ta.pivotlow(low, liqPivotBars, liqPivotBars)

// Optional EMA line
plot(showEMA ? ema : na, title = 'EMA', color = color.new(color.yellow, 20), linewidth = 1)

// ══════════════════════════════════════════════════════════════════════════════
// ARRAYS
// ══════════════════════════════════════════════════════════════════════════════

// Order Blocks + v6 one-shot retouch trackers (kept index-matched to OB arrays)
var array<box> bullishZones = array.new_box()
var array<box> bearishZones = array.new_box()
var array<bool> bullOBRetouched = array.new_bool() // v6: true after first retouch
var array<bool> bearOBRetouched = array.new_bool() // v6

// Breaker Blocks (v6)
var array<box> bullishBreakers = array.new_box() // former bear OBs → support
var array<box> bearishBreakers = array.new_box() // former bull OBs → resistance

// Fair Value Gaps
var array<box> bullishFVGs = array.new_box()
var array<box> bearishFVGs = array.new_box()
var array<line> bullishFVGLines = array.new_line()
var array<line> bearishFVGLines = array.new_line()

// Liquidity
var array<line> buySideLiq = array.new_line()
var array<line> sellSideLiq = array.new_line()

// ══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

getLineStyle() =>
    switch liqStyle
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

// Where price must close to invalidate the OB (v6: supports 50% mode)
bullMitigationLevel(obTop, obBottom) =>
    mitigationType == '50%' ? (obTop + obBottom) / 2.0 : obBottom

bearMitigationLevel(obTop, obBottom) =>
    mitigationType == '50%' ? (obTop + obBottom) / 2.0 : obTop

// ══════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAP DETECTION
// ══════════════════════════════════════════════════════════════════════════════

var bool newBullFVG = false
var bool newBearFVG = false

if showFVG
    // ── Bullish FVG: gap between high[2] and low[0], bullish middle candle ──
    bullishFVG = low > high[2] and close[1] > open[1]
    if bullishFVG and low - high[2] >= fvgMinimumSize
        fvgTop = low
        fvgBottom = high[2]
        fvgMid = (fvgTop + fvgBottom) / 2.0

        fvgBox = box.new(left = bar_index - 2, top = fvgTop, right = bar_index + extendRight, bottom = fvgBottom, bgcolor = color.new(bullFVGColor, fvgTransparency), border_color = color.new(bullFVGColor, 50), border_width = 1, extend = extend.right, text = 'FVG', text_color = color.new(bullFVGColor, 30), text_size = size.tiny)

        fvgLine = line.new(x1 = bar_index - 2, y1 = fvgMid, x2 = bar_index + extendRight, y2 = fvgMid, color = color.new(bullFVGColor, 30), width = 1, style = line.style_dashed, extend = extend.right)

        array.unshift(bullishFVGs, fvgBox)
        array.unshift(bullishFVGLines, fvgLine)
        newBullFVG := true

        if array.size(bullishFVGs) > maxFVGBoxes
            box.delete(array.pop(bullishFVGs))
            line.delete(array.pop(bullishFVGLines))
    else
        newBullFVG := false
        newBullFVG

    // ── Bearish FVG: gap between low[2] and high[0], bearish middle candle ──
    bearishFVG = high < low[2] and close[1] < open[1]
    if bearishFVG and low[2] - high >= fvgMinimumSize
        fvgTop = low[2]
        fvgBottom = high
        fvgMid = (fvgTop + fvgBottom) / 2.0

        fvgBox = box.new(left = bar_index - 2, top = fvgTop, right = bar_index + extendRight, bottom = fvgBottom, bgcolor = color.new(bearFVGColor, fvgTransparency), border_color = color.new(bearFVGColor, 50), border_width = 1, extend = extend.right, text = 'FVG', text_color = color.new(bearFVGColor, 30), text_size = size.tiny)

        fvgLine = line.new(x1 = bar_index - 2, y1 = fvgMid, x2 = bar_index + extendRight, y2 = fvgMid, color = color.new(bearFVGColor, 30), width = 1, style = line.style_dashed, extend = extend.right)

        array.unshift(bearishFVGs, fvgBox)
        array.unshift(bearishFVGLines, fvgLine)
        newBearFVG := true

        if array.size(bearishFVGs) > maxFVGBoxes
            box.delete(array.pop(bearishFVGs))
            line.delete(array.pop(bearishFVGLines))
    else
        newBearFVG := false
        newBearFVG

// ══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY LEVELS  (uses liqPivotBars / liqSwingHigh / liqSwingLow
//                    instead of swingLength — appears after 1-2 candles)
// ══════════════════════════════════════════════════════════════════════════════

var bool newBuyLiq = false
var bool newSellLiq = false

newBuyLiq := false
newSellLiq := false

if showLiquidity
    if not na(liqSwingHigh)
        liqLevel = high[liqPivotBars]
        newLine = line.new(x1 = bar_index - liqPivotBars, y1 = liqLevel, x2 = bar_index + extendRight, y2 = liqLevel, color = liqBuyColor, width = liqLineWidth, style = getLineStyle(), extend = extend.right)
        array.unshift(buySideLiq, newLine)
        if array.size(buySideLiq) > maxLiqLines
            line.delete(array.pop(buySideLiq))

        newBuyLiq := true
        alert('💧 Buy-Side Liquidity | ' + syminfo.ticker + ' ' + timeframe.period + ' | Level: ' + str.tostring(liqLevel, format.mintick), alert.freq_once_per_bar)

    if not na(liqSwingLow)
        liqLevel = low[liqPivotBars]
        newLine = line.new(x1 = bar_index - liqPivotBars, y1 = liqLevel, x2 = bar_index + extendRight, y2 = liqLevel, color = liqSellColor, width = liqLineWidth, style = getLineStyle(), extend = extend.right)
        array.unshift(sellSideLiq, newLine)
        if array.size(sellSideLiq) > maxLiqLines
            line.delete(array.pop(sellSideLiq))

        newSellLiq := true
        alert('💧 Sell-Side Liquidity | ' + syminfo.ticker + ' ' + timeframe.period + ' | Level: ' + str.tostring(liqLevel, format.mintick), alert.freq_once_per_bar)

// ══════════════════════════════════════════════════════════════════════════════
// ORDER BLOCK DETECTION  (v6: EMA Trend Filter gate)
// ══════════════════════════════════════════════════════════════════════════════

var bool newBullOB = false
var bool newBearOB = false

// ── Bullish OB: pivot low confirmed + impulse up ──
// Trend filter: only allow when price is above EMA (or filter is OFF)
if not na(swingLow) and (not useTrendFilter or uptrend)
    upMove = 0.0
    for i = 0 to minImpulseCandles - 1 by 1
        if close[i] > open[i]
            upMove := upMove + close[i] - open[i]
            upMove

    lastCandleStrength = close[0] > open[0] ? (close[0] - open[0]) / atr : 0.0
    bullishImpulse = upMove >= impulseThreshold or lastCandleStrength > 0.5

    if bullishImpulse
        obCandle = swingLength
        for i = swingLength to swingLength + 3 by 1
            if i < bar_index and close[i] < open[i]
                obCandle := i
                break

        obBottom = low[obCandle]
        obTop = high[obCandle]
        obLeft = bar_index - obCandle

        newBox = box.new(left = obLeft, top = obTop, right = obLeft + extendRight, bottom = obBottom, bgcolor = color.new(bullColor, obTransparency), border_color = color.new(bullColor, 0), border_width = borderWidth, extend = extend.right, text = 'OB', text_color = color.new(bullColor, 20), text_size = size.tiny)

        array.unshift(bullishZones, newBox)
        array.unshift(bullOBRetouched, false) // v6: init retouch flag

        newBullOB := true

        if array.size(bullishZones) > maxBoxes
            box.delete(array.pop(bullishZones))
            array.pop(bullOBRetouched) // v6: keep arrays in sync
    else
        newBullOB := false
        newBullOB
else
    newBullOB := false
    newBullOB

// ── Bearish OB: pivot high confirmed + impulse down ──
// Trend filter: only allow when price is below EMA (or filter is OFF)
if not na(swingHigh) and (not useTrendFilter or downtrend)
    downMove = 0.0
    for i = 0 to minImpulseCandles - 1 by 1
        if close[i] < open[i]
            downMove := downMove + open[i] - close[i]
            downMove

    lastCandleStrength = close[0] < open[0] ? (open[0] - close[0]) / atr : 0.0
    bearishImpulse = downMove >= impulseThreshold or lastCandleStrength > 0.5

    if bearishImpulse
        obCandle = swingLength
        for i = swingLength to swingLength + 3 by 1
            if i < bar_index and close[i] > open[i]
                obCandle := i
                break

        obTop = high[obCandle]
        obBottom = low[obCandle]
        obLeft = bar_index - obCandle

        newBox = box.new(left = obLeft, top = obTop, right = obLeft + extendRight, bottom = obBottom, bgcolor = color.new(bearColor, obTransparency), border_color = color.new(bearColor, 0), border_width = borderWidth, extend = extend.right, text = 'OB', text_color = color.new(bearColor, 20), text_size = size.tiny)

        array.unshift(bearishZones, newBox)
        array.unshift(bearOBRetouched, false) // v6

        newBearOB := true

        if array.size(bearishZones) > maxBoxes
            box.delete(array.pop(bearishZones))
            array.pop(bearOBRetouched) // v6: keep arrays in sync
    else
        newBearOB := false
        newBearOB
else
    newBearOB := false
    newBearOB

// ══════════════════════════════════════════════════════════════════════════════
// MITIGATION + BREAKER BLOCK CREATION  (v6 NEW)
// When an OB is invalidated it doesn't just disappear — it flips polarity:
//   Bullish OB mitigated → Bearish Breaker Block (resistance above)
//   Bearish OB mitigated → Bullish Breaker Block  (support below)
// ══════════════════════════════════════════════════════════════════════════════

// ── Bullish OBs ──
if array.size(bullishZones) > 0
    for i = array.size(bullishZones) - 1 to 0 by 1
        b = array.get(bullishZones, i)
        if not na(b)
            obTop = box.get_top(b)
            obBottom = box.get_bottom(b)
            if close < bullMitigationLevel(obTop, obBottom)
                if showBreakers
                    // Former demand zone → now resistance → Bearish Breaker ↓
                    breakerBox = box.new(left = box.get_left(b), top = obTop, right = bar_index + extendRight, bottom = obBottom, bgcolor = color.new(bearBreakerColor, breakerTransp), border_color = color.new(bearBreakerColor, 30), border_width = 1, extend = extend.right, text = 'BB ↓', text_color = color.new(bearBreakerColor, 20), text_size = size.tiny)
                    array.unshift(bearishBreakers, breakerBox)
                    if array.size(bearishBreakers) > maxBreakers
                        box.delete(array.pop(bearishBreakers))
                box.delete(b)
                array.remove(bullishZones, i)
                array.remove(bullOBRetouched, i) // v6: keep in sync

// ── Bearish OBs ──
if array.size(bearishZones) > 0
    for i = array.size(bearishZones) - 1 to 0 by 1
        b = array.get(bearishZones, i)
        if not na(b)
            obTop = box.get_top(b)
            obBottom = box.get_bottom(b)
            if close > bearMitigationLevel(obTop, obBottom)
                if showBreakers
                    // Former supply zone → now support → Bullish Breaker ↑
                    breakerBox = box.new(left = box.get_left(b), top = obTop, right = bar_index + extendRight, bottom = obBottom, bgcolor = color.new(bullBreakerColor, breakerTransp), border_color = color.new(bullBreakerColor, 30), border_width = 1, extend = extend.right, text = 'BB ↑', text_color = color.new(bullBreakerColor, 20), text_size = size.tiny)
                    array.unshift(bullishBreakers, breakerBox)
                    if array.size(bullishBreakers) > maxBreakers
                        box.delete(array.pop(bullishBreakers))
                box.delete(b)
                array.remove(bearishZones, i)
                array.remove(bearOBRetouched, i) // v6: keep in sync

// ── Remove swept Breaker Blocks ──
if array.size(bearishBreakers) > 0
    for i = array.size(bearishBreakers) - 1 to 0 by 1
        b = array.get(bearishBreakers, i)
        if not na(b) and close > box.get_top(b) // price breaks above → swept
            box.delete(b)
            array.remove(bearishBreakers, i)

if array.size(bullishBreakers) > 0
    for i = array.size(bullishBreakers) - 1 to 0 by 1
        b = array.get(bullishBreakers, i)
        if not na(b) and close < box.get_bottom(b) // price breaks below → swept
            box.delete(b)
            array.remove(bullishBreakers, i)

// ── Remove filled Bullish FVGs ──
if array.size(bullishFVGs) > 0
    for i = array.size(bullishFVGs) - 1 to 0 by 1
        b = array.get(bullishFVGs, i)
        if not na(b) and low <= box.get_bottom(b)
            box.delete(b)
            array.remove(bullishFVGs, i)
            if i < array.size(bullishFVGLines)
                line.delete(array.get(bullishFVGLines, i))
                array.remove(bullishFVGLines, i)

// ── Remove filled Bearish FVGs ──
if array.size(bearishFVGs) > 0
    for i = array.size(bearishFVGs) - 1 to 0 by 1
        b = array.get(bearishFVGs, i)
        if not na(b) and high >= box.get_top(b)
            box.delete(b)
            array.remove(bearishFVGs, i)
            if i < array.size(bearishFVGLines)
                line.delete(array.get(bearishFVGLines, i))
                array.remove(bearishFVGLines, i)

// ── Remove swept Liquidity lines ──
if array.size(buySideLiq) > 0
    for i = array.size(buySideLiq) - 1 to 0 by 1
        l = array.get(buySideLiq, i)
        if not na(l) and close > line.get_y1(l)
            line.delete(l)
            array.remove(buySideLiq, i)

if array.size(sellSideLiq) > 0
    for i = array.size(sellSideLiq) - 1 to 0 by 1
        l = array.get(sellSideLiq, i)
        if not na(l) and close < line.get_y1(l)
            line.delete(l)
            array.remove(sellSideLiq, i)

// ══════════════════════════════════════════════════════════════════════════════
// OB RETOUCH DETECTION  (v6: one-shot per OB + visual highlight + dynamic alert)
//
// Runs AFTER mitigation removal so fully-invalidated OBs are already gone.
// Each OB fires the retouch alert only ONCE (tracked in bullOBRetouched /
// bearOBRetouched bool arrays, index-matched to the zone arrays).
// On first retouch the box border is brightened so the zone stands out visually.
// A dynamic alert() call also fires with the exact price level in the message.
// ══════════════════════════════════════════════════════════════════════════════

var bool bullOBRetouch = false
var bool bearOBRetouch = false

bullOBRetouch := false
bearOBRetouch := false

// ── Bullish OB retouch: candle low dips INTO the OB zone from above ──
if array.size(bullishZones) > 0
    for i = 0 to array.size(bullishZones) - 1 by 1
        b = array.get(bullishZones, i)
        alreadyHit = array.get(bullOBRetouched, i)
        if not alreadyHit and not na(b)
            obTop = box.get_top(b)
            obBottom = box.get_bottom(b)
            if low <= obTop and low >= obBottom
                bullOBRetouch := true
                array.set(bullOBRetouched, i, true)

                // Visual: brighten the retouched OB border
                box.set_border_color(b, bullColor)
                box.set_border_width(b, 2)
                box.set_text(b, 'OB ↩')

                // Dynamic alert with exact price zone in message
                alert('🟢 Bull OB Retouch | ' + syminfo.ticker + ' ' + timeframe.period + ' | Zone: ' + str.tostring(obBottom, format.mintick) + ' – ' + str.tostring(obTop, format.mintick), alert.freq_once_per_bar)
                break

// ── Bearish OB retouch: candle high pushes INTO the OB zone from below ──
if array.size(bearishZones) > 0
    for i = 0 to array.size(bearishZones) - 1 by 1
        b = array.get(bearishZones, i)
        alreadyHit = array.get(bearOBRetouched, i)
        if not alreadyHit and not na(b)
            obTop = box.get_top(b)
            obBottom = box.get_bottom(b)
            if high >= obBottom and high <= obTop
                bearOBRetouch := true
                array.set(bearOBRetouched, i, true)

                // Visual: brighten the retouched OB border
                box.set_border_color(b, bearColor)
                box.set_border_width(b, 2)
                box.set_text(b, 'OB ↩')

                // Dynamic alert with exact price zone in message
                alert('🔴 Bear OB Retouch | ' + syminfo.ticker + ' ' + timeframe.period + ' | Zone: ' + str.tostring(obBottom, format.mintick) + ' – ' + str.tostring(obTop, format.mintick), alert.freq_once_per_bar)
                break

// ══════════════════════════════════════════════════════════════════════════════
// INFO TABLE  (v6: 10 rows — adds Breakers + Trend rows)
// ══════════════════════════════════════════════════════════════════════════════

if showInfo and barstate.islast
    var table infoTable = table.new(position.top_right, 2, 10, bgcolor = color.new(#1a1a1a, 10), border_width = 2, border_color = color.new(#404040, 50))

    table.cell(infoTable, 0, 0, '⚙ Timeframe:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 0, timeframe.period, text_color = color.yellow, text_size = size.small)

    table.cell(infoTable, 0, 1, '📊 Swing:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 1, str.tostring(swingLength), text_color = color.aqua, text_size = size.small)

    table.cell(infoTable, 0, 2, '⚡ Impulse:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 2, str.tostring(impulseFactor, '#.#'), text_color = color.aqua, text_size = size.small)

    table.cell(infoTable, 0, 3, '📈 Trend:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 3, useTrendFilter ? uptrend ? '▲ Bull' : '▼ Bear' : 'OFF', text_color = useTrendFilter ? uptrend ? bullColor : bearColor : color.gray, text_size = size.small)

    table.cell(infoTable, 0, 4, '🟢 Bull OB:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 4, str.tostring(array.size(bullishZones)), text_color = bullColor, text_size = size.small)

    table.cell(infoTable, 0, 5, '🔴 Bear OB:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 5, str.tostring(array.size(bearishZones)), text_color = bearColor, text_size = size.small)

    table.cell(infoTable, 0, 6, '🔷 Breakers:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 6, str.tostring(array.size(bullishBreakers) + array.size(bearishBreakers)), text_color = color.new(bullBreakerColor, 10), text_size = size.small)

    table.cell(infoTable, 0, 7, '🟢 Bull FVG:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 7, str.tostring(array.size(bullishFVGs)), text_color = bullFVGColor, text_size = size.small)

    table.cell(infoTable, 0, 8, '🔴 Bear FVG:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 8, str.tostring(array.size(bearishFVGs)), text_color = bearFVGColor, text_size = size.small)

    table.cell(infoTable, 0, 9, '💧 Liquidity:', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 9, str.tostring(array.size(buySideLiq) + array.size(sellSideLiq)), text_color = color.orange, text_size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// alertcondition  → use in the "Create Alert" dialog on TradingView
// alert()         → fires automatically with a dynamic message (price level)
//                   already embedded in the retouch detection block above
// ══════════════════════════════════════════════════════════════════════════════

// ── OB Formation ──
alertcondition(newBullOB, title = 'Bull OB Formed', message = '🟢 Bullish OB formed on {{ticker}} {{interval}}')
alertcondition(newBearOB, title = 'Bear OB Formed', message = '🔴 Bearish OB formed on {{ticker}} {{interval}}')

// ── OB Retouch (one-shot per OB | dynamic alert() fires with price level) ──
alertcondition(bullOBRetouch, title = 'Bull OB Retouch', message = '🟢 Price retouching Bullish OB on {{ticker}} {{interval}} — potential long')
alertcondition(bearOBRetouch, title = 'Bear OB Retouch', message = '🔴 Price retouching Bearish OB on {{ticker}} {{interval}} — potential short')

// ── FVG Formation ──
alertcondition(newBullFVG, title = 'Bull FVG Formed', message = '🟢 Bullish FVG formed on {{ticker}} {{interval}}')
alertcondition(newBearFVG, title = 'Bear FVG Formed', message = '🔴 Bearish FVG formed on {{ticker}} {{interval}}')

// ── Liquidity Formation (fires after liqPivotBars candles, default 2) ──
alertcondition(newBuyLiq, title = 'Buy-Side Liquidity Formed', message = '💧 Buy-Side Liquidity formed on {{ticker}} {{interval}}')
alertcondition(newSellLiq, title = 'Sell-Side Liquidity Formed', message = '💧 Sell-Side Liquidity formed on {{ticker}} {{interval}}')
````
