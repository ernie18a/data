# DivMacdObFvg

- url: https://www.tradingview.com/script/YY6uJQZW/
- type: indicator
- pine_id: PUB;6234a389e2544c4db40302e0ddb30bb2
- version: 2.0

## Description

DivMacdObFvg — Indicator Description

DivMacdObFvg is a TradingView indicator designed for the 4h chart. The lower pane shows the MACD histogram with a zero line, its highs and lows confirmed by 1h closes, and divergences against price. On the price chart it draws the same divergences, plus Order Blocks and Fair Value Gaps that are still valid. It is not a strategy: it does not open or close orders, it only flags points where momentum and price zones coincide.

How It Works

MACD Histogram (12/26/9)
The color shows momentum and direction:

Aqua: above zero and rising.

Blue: above zero but falling.

Red: below zero and falling.

Maroon: below zero but rising.

Highs and Lows (yellow and fuchsia dots)
A yellow dot marks a histogram high above zero, a fuchsia dot marks a histogram low below zero. The signal is confirmed by the first 1h close of the following 4h candle: if the histogram recalculated with that close has already turned down (or up) from the extreme, the extreme is considered valid. The dot is drawn on the 4h candle that actually made the extreme, so it appears with a delay of about 1-2 hours rather than at candle close.

Divergences (Div↑ / Div↓)
The script finds histogram pivots (5 bars left, 3 bars right) and compares them with the price lows or highs at the same points:

Bullish: price makes a lower low, the histogram makes a higher low (and below zero). Bearish momentum is fading.

Bearish: price makes a higher high, the histogram makes a lower high (and above zero).

Lines are drawn on both the histogram and the price chart. A pivot is confirmed 3 bars later, which is about 12 hours after the extreme.

FVG (lime bullish, orange bearish)
The empty space between the high of the candle two bars back and the low of the current candle (or the reverse), after an impulsive candle and only if larger than 0.3 ATR. The box extends to the right until a close fills the gap, then it is deleted.

Order Blocks (blue bullish, purple bearish)
When price closes above the last pivot high, the bullish OB is the candle with the lowest low between that pivot and the break. The bearish case is the mirror image. The OB disappears when a close crosses the opposite side of the box (mitigated).

Entry and Exit (Operational Outline)

The script does not trade by itself, so what follows is an outline you can apply by reading the signals. It has not been backtested.

Long

Setup: a Div↑ or a fuchsia dot appears. Bearish momentum is fading.

Zone: price is inside or near a blue OB or a lime FVG.

Entry: at the close of the 4h candle where the histogram turns maroon (below zero but rising), or with a limit order at the upper edge of the zone.

Stop: below the bottom of the OB (or below the divergence pivot low), with a margin of about 0.5 ATR. If a candle closes below the bottom of the OB, the script deletes the box: that is the natural invalidation.

Exit: partial at the yellow dot or a Div↓, or at the first bearish zone above (purple OB or orange FVG). The remainder when the histogram turns blue after being aqua, or at a fixed risk/reward ratio (1.5-2).

Short: same outline reversed, with Div↓ or a yellow dot, price in a purple OB or orange FVG, stop above the upper edge of the OB, target at the first bullish zone below.

Limitations

Divergence delay: when Div↑ or Div↓ appears, price has already moved for about 12 hours. Entering at market after the signal can significantly worsen risk/reward, which is why waiting for a return to the zone is preferable.

Strong trends: in a decisive trend, divergences can appear several times before a reversal. They are not enough on their own; the OB/FVG zone acts as a filter.

1h confirmation: the provisional histogram is not the final one, so a dot can appear and the 4h candle can still close higher or lower.

Zones: with obSwingLen = 5 on 4h, OBs are numerous. With 8-10 you get fewer and more significant ones.

Disclaimer

Not financial advice. This indicator and its description are provided for educational and informational purposes only. Nothing here constitutes investment advice, a recommendation, or an offer to buy or sell any financial instrument. The author is not a licensed financial advisor.

## Source Code

````pine
//@version=6
indicator("DMacdObFvg", shorttitle="DMacdObFvg", overlay=false, precision=4, max_lines_count=500, max_boxes_count=500)

// ============================================================
// === INPUTS =================================================
// ============================================================

// --- MACD ---
fastLength     = input.int(12, "Fast Length", minval=1, group="MACD")
slowLength     = input.int(26, "Slow Length", minval=1, group="MACD")
signalLength   = input.int(9, "Signal Length", minval=2, group="MACD")
histFourColors = input.bool(true, "Histogram 4 Colors", group="MACD")
showExtremes   = input.bool(true, "Show Histogram Highs/Lows Signals", group="MACD")

// --- Lower timeframe confirmation ---
lowerTf        = input.timeframe("60", "Confirmation Timeframe (must be below chart TF)", group="Confirmation")

// --- Divergences ---
showDiv      = input.bool(true, "Show Divergences", group="Divergences")
showHidden   = input.bool(false, "Show Hidden Divergences", group="Divergences")
lbL          = input.int(5, "Pivot: Bars Left", minval=1, group="Divergences")
lbR          = input.int(3, "Pivot: Bars Right (confirmation delay)", minval=1, group="Divergences")
rangeMin     = input.int(5, "Min Distance Between Pivots (bars)", minval=1, group="Divergences")
rangeMax     = input.int(60, "Max Distance Between Pivots (bars)", minval=1, group="Divergences")
onlyZeroSide = input.bool(true, "Bullish only if hist<0, Bearish only if hist>0", group="Divergences")

// --- FVG ---
showFVG     = input.bool(true, "Show FVG", group="FVG / OB")
fvgMinAtr   = input.float(0.3, "FVG: Min Size (x ATR14)", minval=0.0, step=0.1, group="FVG / OB")
fvgMax      = input.int(15, "FVG: Max Active", minval=1, maxval=100, group="FVG / OB")
fvgDelete   = input.bool(true, "FVG: Delete When Filled (otherwise stop extending)", group="FVG / OB")
fvgBullCol  = input.color(color.new(color.lime, 80), "FVG Bullish: Fill Color", group="FVG / OB")
fvgBearCol  = input.color(color.new(color.orange, 80), "FVG Bearish: Fill Color", group="FVG / OB")
fvgBorderC  = input.color(color.new(color.lime, 0),  "FVG: Border Color", group="FVG / OB")
fvgBorderW  = input.int(1, "FVG: Border Width (0 = none)", minval=0, maxval=5, group="FVG / OB")

// --- OB ---
showOB      = input.bool(true, "Show Order Blocks", group="FVG / OB")
obSwingLen  = input.int(5, "OB: Swing Length (pivot)", minval=2, group="FVG / OB")
obMax       = input.int(10, "OB: Max Active", minval=1, maxval=100, group="FVG / OB")
obDelete    = input.bool(true, "OB: Delete When Mitigated (otherwise stop extending)", group="FVG / OB")
obBullCol     = input.color(color.new(color.blue, 65),   "OB Bullish: Fill Color", group="FVG / OB")
obBearCol     = input.color(color.new(color.purple, 65), "OB Bearish: Fill Color", group="FVG / OB")
obBullBorderC = input.color(color.blue,   "OB Bullish: Border Color", group="FVG / OB")
obBearBorderC = input.color(color.purple, "OB Bearish: Border Color", group="FVG / OB")
obBorderW     = input.int(1, "OB: Border Width (0 = none)", minval=0, maxval=5, group="FVG / OB")

// ============================================================
// === MACD FUNCTION (riutilizzabile) =========================
// ============================================================
macdHist() =>
    f   = ta.ema(close, fastLength)
    s   = ta.ema(close, slowLength)
    m   = f - s
    sig = ta.sma(m, signalLength)
    m - sig

// ============================================================
// === MACD ON CHART TIMEFRAME ================================
// ============================================================
float hist = macdHist()

// ============================================================
// === LTF CONFIRMATION =======================================
// ============================================================
float histLtf = request.security(syminfo.tickerid, lowerTf, macdHist(), lookahead=barmerge.lookahead_off)

bool ltfDown = histLtf < histLtf[1]
bool ltfUp   = histLtf > histLtf[1]

// ============================================================
// === HISTOGRAM COLORS =======================================
// ============================================================
bool histA_IsUp   = hist > nz(hist[1]) and hist > 0
bool histA_IsDown = hist < nz(hist[1]) and hist > 0
bool histB_IsDown = hist < nz(hist[1]) and hist <= 0
bool histB_IsUp   = hist > nz(hist[1]) and hist <= 0

color hist_color = histFourColors ? (histA_IsUp ? color.aqua : histA_IsDown ? color.blue : histB_IsDown ? color.red : histB_IsUp ? color.maroon : color.yellow) : color.gray

// ============================================================
// === HIGHS / LOWS CONFIRMED BY LOWER TF =====================
// ============================================================
bool isPeak   = hist[1] > hist[2] and hist[1] > 0 and hist < hist[1] and ltfDown
bool isTrough = hist[1] < hist[2] and hist[1] < 0 and hist > hist[1] and ltfUp

// ============================================================
// === PRICE / HISTOGRAM DIVERGENCES ==========================
// ============================================================
float pivLo = ta.pivotlow(hist, lbL, lbR)
float pivHi = ta.pivothigh(hist, lbL, lbR)

var float pLoHist  = na
var float pLoPrice = na
var int   pLoBar   = na
var float pHiHist  = na
var float pHiPrice = na
var int   pHiBar   = na

bool bullReg = false
bool bullHid = false
bool bearReg = false
bool bearHid = false

if not na(pivLo)
    float curPrice = low[lbR]
    int   curBar   = bar_index - lbR
    if not na(pLoBar)
        int  dist = curBar - pLoBar
        bool ok   = dist >= rangeMin and dist <= rangeMax
        bullReg := ok and curPrice < pLoPrice and pivLo > pLoHist and (not onlyZeroSide or pivLo < 0)
        bullHid := ok and curPrice > pLoPrice and pivLo < pLoHist and (not onlyZeroSide or pivLo < 0)
        if showDiv and (bullReg or (showHidden and bullHid))
            color lc = bullReg ? color.lime : color.new(color.lime, 50)
            line.new(pLoBar, pLoHist, curBar, pivLo, color=lc, width=2)
            line.new(pLoBar, pLoPrice, curBar, curPrice, color=lc, width=2, force_overlay=true)
    pLoHist  := pivLo
    pLoPrice := curPrice
    pLoBar   := curBar

if not na(pivHi)
    float curPrice = high[lbR]
    int   curBar   = bar_index - lbR
    if not na(pHiBar)
        int  dist = curBar - pHiBar
        bool ok   = dist >= rangeMin and dist <= rangeMax
        bearReg := ok and curPrice > pHiPrice and pivHi < pHiHist and (not onlyZeroSide or pivHi > 0)
        bearHid := ok and curPrice < pHiPrice and pivHi > pHiHist and (not onlyZeroSide or pivHi > 0)
        if showDiv and (bearReg or (showHidden and bearHid))
            color lc = bearReg ? color.red : color.new(color.red, 50)
            line.new(pHiBar, pHiHist, curBar, pivHi, color=lc, width=2)
            line.new(pHiBar, pHiPrice, curBar, curPrice, color=lc, width=2, force_overlay=true)
    pHiHist  := pivHi
    pHiPrice := curPrice
    pHiBar   := curBar

// ============================================================
// === FVG ON PRICE CHART =====================================
// ============================================================
float atrV = ta.atr(14)

var array<box> fvgBoxes = array.new<box>()
var array<int> fvgDir   = array.new<int>()

// update / close existing ones
if showFVG and array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        box b = array.get(fvgBoxes, i)
        int d = array.get(fvgDir, i)
        bool filled = d == 1 ? close < box.get_bottom(b) : close > box.get_top(b)
        box.set_right(b, bar_index)
        if filled
            if fvgDelete
                box.delete(b)
            array.remove(fvgBoxes, i)
            array.remove(fvgDir, i)

// new FVGs (candle [1] is the impulsive one, gap between high[2] and low)
bool bullFvg = low > high[2] and close[1] > high[2] and (low - high[2]) > atrV * fvgMinAtr
bool bearFvg = high < low[2] and close[1] < low[2] and (low[2] - high) > atrV * fvgMinAtr

if showFVG and bullFvg
    box b = box.new(bar_index - 2, low, bar_index, high[2], border_color=fvgBorderW > 0 ? fvgBorderC : na, border_width=fvgBorderW, bgcolor=fvgBullCol, force_overlay=true)
    array.push(fvgBoxes, b)
    array.push(fvgDir, 1)
if showFVG and bearFvg
    box b = box.new(bar_index - 2, low[2], bar_index, high, border_color=fvgBorderW > 0 ? fvgBorderC : na, border_width=fvgBorderW, bgcolor=fvgBearCol, force_overlay=true)
    array.push(fvgBoxes, b)
    array.push(fvgDir, -1)

if array.size(fvgBoxes) > fvgMax
    box.delete(array.shift(fvgBoxes))
    array.shift(fvgDir)

// ============================================================
// === ORDER BLOCKS ON PRICE CHART ============================
// ============================================================
var array<box> obBoxes = array.new<box>()
var array<int> obDir   = array.new<int>()

float obPH = ta.pivothigh(high, obSwingLen, obSwingLen)
float obPL = ta.pivotlow(low, obSwingLen, obSwingLen)

var float lastPH    = na
var int   lastPHbar = na
var bool  phBroken  = true
var float lastPL    = na
var int   lastPLbar = na
var bool  plBroken  = true

if not na(obPH)
    lastPH    := obPH
    lastPHbar := bar_index - obSwingLen
    phBroken  := false
if not na(obPL)
    lastPL    := obPL
    lastPLbar := bar_index - obSwingLen
    plBroken  := false

// mitigation of existing OBs
if showOB and array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0
        box b = array.get(obBoxes, i)
        int d = array.get(obDir, i)
        bool mit = d == 1 ? close < box.get_bottom(b) : close > box.get_top(b)
        box.set_right(b, bar_index)
        if mit
            if obDelete
                box.delete(b)
            array.remove(obBoxes, i)
            array.remove(obDir, i)

// upside break -> bullish OB
if showOB and not phBroken and not na(lastPH) and close > lastPH
    phBroken := true
    int span = math.min(bar_index - lastPHbar, 400)
    int idx  = 0
    float lowest = low
    for k = 0 to span
        if low[k] < lowest
            lowest := low[k]
            idx    := k
    array.push(obBoxes, box.new(bar_index - idx, high[idx], bar_index, low[idx], border_color=obBorderW > 0 ? obBullBorderC : na, border_width=obBorderW, bgcolor=obBullCol, force_overlay=true))
    array.push(obDir, 1)

// downside break -> bearish OB
if showOB and not plBroken and not na(lastPL) and close < lastPL
    plBroken := true
    int span = math.min(bar_index - lastPLbar, 400)
    int idx  = 0
    float highest = high
    for k = 0 to span
        if high[k] > highest
            highest := high[k]
            idx     := k
    array.push(obBoxes, box.new(bar_index - idx, high[idx], bar_index, low[idx], border_color=obBorderW > 0 ? obBearBorderC : na, border_width=obBorderW, bgcolor=obBearCol, force_overlay=true))
    array.push(obDir, -1)

if array.size(obBoxes) > obMax
    box.delete(array.shift(obBoxes))
    array.shift(obDir)

// ============================================================
// === PLOTS ==================================================
// ============================================================
plot(hist, "Histogram", color=hist_color, style=plot.style_columns)
hline(0, "Zero Line", color=color.white, linestyle=hline.style_solid, linewidth=2)

// Highs / lows (offset=-1: dot on the bar that actually made the extreme)
plot(showExtremes and isPeak   ? hist[1] : na, "Histogram High", color=color.yellow,  style=plot.style_circles, linewidth=4, offset=-1)
plot(showExtremes and isTrough ? hist[1] : na, "Histogram Low",  color=color.fuchsia, style=plot.style_circles, linewidth=4, offset=-1)

// Divergence markers on the histogram
plotshape(showDiv and bullReg ? pivLo : na, "Bullish Div (MACD)", location=location.absolute, style=shape.diamond, color=color.lime, size=size.tiny, offset=-lbR)
plotshape(showDiv and bearReg ? pivHi : na, "Bearish Div (MACD)", location=location.absolute, style=shape.diamond, color=color.red,  size=size.tiny, offset=-lbR)
plotshape(showDiv and showHidden and bullHid ? pivLo : na, "Hidden Bullish Div (MACD)", location=location.absolute, style=shape.diamond, color=color.new(color.lime, 50), size=size.tiny, offset=-lbR)
plotshape(showDiv and showHidden and bearHid ? pivHi : na, "Hidden Bearish Div (MACD)", location=location.absolute, style=shape.diamond, color=color.new(color.red, 50),  size=size.tiny, offset=-lbR)

// Divergence markers on the price chart
plotshape(showDiv and bullReg, "Bullish Div (Price)", location=location.belowbar, style=shape.labelup,   color=color.lime, textcolor=color.black, text="Div↑", size=size.tiny, offset=-lbR, force_overlay=true)
plotshape(showDiv and bearReg, "Bearish Div (Price)", location=location.abovebar, style=shape.labeldown, color=color.red,  textcolor=color.white, text="Div↓", size=size.tiny, offset=-lbR, force_overlay=true)
plotshape(showDiv and showHidden and bullHid, "Hidden Bullish Div (Price)", location=location.belowbar, style=shape.labelup,   color=color.new(color.lime, 50), textcolor=color.black, text="H↑", size=size.tiny, offset=-lbR, force_overlay=true)
plotshape(showDiv and showHidden and bearHid, "Hidden Bearish Div (Price)", location=location.abovebar, style=shape.labeldown, color=color.new(color.red, 50),  textcolor=color.white, text="H↓", size=size.tiny, offset=-lbR, force_overlay=true)

// ============================================================
// === ALERTS =================================================
// ============================================================
alertcondition(isPeak,   "Histogram High",     "MACD hist: high confirmed by LTF")
alertcondition(isTrough, "Histogram Low",      "MACD hist: low confirmed by LTF")
alertcondition(bullReg,  "Bullish Divergence", "Bullish divergence price/MACD hist")
alertcondition(bearReg,  "Bearish Divergence", "Bearish divergence price/MACD hist")
alertcondition(bullFvg,  "Bullish FVG",        "New bullish FVG")
alertcondition(bearFvg,  "Bearish FVG",        "New bearish FVG")
````
