# 21 EMA Bounce + VRVP + RSI

- url: https://www.tradingview.com/script/zjyoJq8X-21-EMA-Bounce-VRVP-RSI/
- type: indicator
- pine_id: PUB;4b226794969b4ae780e206bab2a11a87
- version: 1.0

## Description

Summary of what's in the code:
Daily 21 EMA: The main signal line for bounces.
Daily 55 EMA: Used to ensure you only trade in the direction of the long-term trend.
RSI Filter: Filters out signals when momentum is weak or over-extended.
Volume Profile (VRVP): Automatically draws a profile of the last 200 bars with a Red POC (Point of Control) line.
Candle Patterns: Detects Pin Bars and Engulfing patterns at the EMA for extra confirmation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("EMA Bounce + VRVP + RSI", overlay = true, shorttitle = "EMA-VP-RSI")

// --- Inputs ---
groupEma = "EMA Settings"
int ema21Length    = input.int(21, "EMA 21 Length (Signal)", minval = 1, group = groupEma)
int ema55Length    = input.int(55, "EMA 55 Length", minval = 1, group = groupEma)
string tfInput     = input.timeframe("D", "EMA Timeframe", tooltip = "The timeframe for the EMAs.")

groupRsi = "RSI Settings"
int rsiLen         = input.int(14, "RSI Length", group = groupRsi)
int rsiUpper       = input.int(70, "RSI Overbought", group = groupRsi)
int rsiLower       = input.int(30, "RSI Oversold", group = groupRsi)

groupSignal = "Signal Settings"
float thresholdPct = input.float(0.1, "Touch Threshold (%)", minval = 0, step = 0.05, group = groupSignal) / 100
bool requirePattern = input.bool(true, "Require Candle Pattern", group = groupSignal)

groupVP = "Volume Profile (Visible Range Approximation)"
int vpLookback     = input.int(200, "VP Lookback Bars", minval = 10, maxval = 500, group = groupVP)
int vpRows         = input.int(30, "VP Rows", minval = 5, maxval = 100, group = groupVP)

// --- Calculations ---
// EMAs (Daily)
[ema21, ema55] = request.security(syminfo.tickerid, tfInput, [ta.ema(close, ema21Length), ta.ema(close, ema55Length)])

// RSI (Current TF)
float rsiValue = ta.rsi(close, rsiLen)

// Pattern Detection
float bodySize = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
bool isBullPin = lowerWick > bodySize * 2 and upperWick < bodySize
bool isBearPin = upperWick > bodySize * 2 and lowerWick < bodySize
bool isBullEng = close[1] < open[1] and close > open[1] and open <= close[1]
bool isBearEng = close[1] > open[1] and close < open[1] and open >= close[1]
bool patternPresentBull = isBullPin or isBullEng
bool patternPresentBear = isBearPin or isBearEng

// Trend Alignment
bool bullTrend = ema21 > ema55
bool bearTrend = ema21 < ema55

// Bounce Logic
bool isBullishTouch = low <= ema21 * (1 + thresholdPct)
bool isBearishTouch = high >= ema21 * (1 - thresholdPct)

// RSI Filter
bool rsiBullOk = rsiValue > 50 and rsiValue < rsiUpper
bool rsiBearOk = rsiValue < 50 and rsiValue > rsiLower

bool bullBounce = bullTrend and rsiBullOk and isBullishTouch and close > ema21 and (not requirePattern or patternPresentBull)
bool bearBounce = bearTrend and rsiBearOk and isBearishTouch and close < ema21 and (not requirePattern or patternPresentBear)

// --- Volume Profile (POC) ---
var box[] vpBoxes = array.new<box>()
var line vpPocLine = line.new(na, na, na, na, xloc.bar_index, extend.right, #f23645, line.style_solid, 2)

float rangeHi = ta.highest(high, vpLookback)
float rangeLo = ta.lowest(low, vpLookback)

if barstate.islast
    if array.size(vpBoxes) > 0
        for i = 0 to array.size(vpBoxes) - 1
            box.delete(array.pop(vpBoxes))

    float hi = rangeHi
    float lo = rangeLo
    float rowSize = (hi - lo) / vpRows
    float[] volumes = array.new_float(vpRows, 0.0)
    
    for i = 0 to vpLookback - 1
        float barClose = close[i]
        float barVol = nz(volume[i])
        int bin = math.min(vpRows - 1, math.floor((barClose - lo) / rowSize))
        if bin >= 0
            array.set(volumes, bin, array.get(volumes, bin) + barVol)
    
    float maxVol = 0.0
    int pocBin = 0
    for k = 0 to vpRows - 1
        float v = array.get(volumes, k)
        if v > maxVol
            maxVol := v
            pocBin := k
            
    float pocPrice = lo + (pocBin * rowSize) + (rowSize / 2)
    line.set_xy1(vpPocLine, bar_index - vpLookback, pocPrice)
    line.set_xy2(vpPocLine, bar_index, pocPrice)
    
    for j = 0 to vpRows - 1
        float v = array.get(volumes, j)
        if v > 0
            int width = int((v / maxVol) * 100)
            float top = lo + (j + 1) * rowSize
            float bottom = lo + j * rowSize
            color boxColor = (j == pocBin) ? color.new(#f23645, 60) : color.new(#5b9cf6, 80)
            array.push(vpBoxes, box.new(bar_index - width, top, bar_index, bottom, border_color = na, bgcolor = boxColor))

// --- Visuals ---
plot(ema21, "Daily 21 EMA", color.new(#5b9cf6, 0), 2)
plot(ema55, "Daily 55 EMA", color.new(#ff9800, 0), 1)

if bullBounce
    label.new(bar_index, low, "Long", yloc = yloc.belowbar, color = #00000000, textcolor = #089981, style = label.style_label_up, size = size.small)

if bearBounce
    label.new(bar_index, high, "Short", yloc = yloc.abovebar, color = #00000000, textcolor = #f23645, style = label.style_label_down, size = size.small)

// --- Alerts ---
alertcondition(bullBounce, "Bullish EMA 21 Bounce", "Bullish bounce off Daily 21 EMA with trend and RSI alignment")
alertcondition(bearBounce, "Bearish EMA 21 Bounce", "Bearish bounce off Daily 21 EMA with trend and RSI alignment")

if bullBounce
    alert("Bullish Bounce on " + syminfo.ticker + " at " + str.tostring(close), alert.freq_once_per_bar_close)
if bearBounce
    alert("Bearish Bounce on " + syminfo.ticker + " at " + str.tostring(close), alert.freq_once_per_bar_close)
````
