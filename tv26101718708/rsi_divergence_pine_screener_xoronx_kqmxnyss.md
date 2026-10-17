# RSI Divergence Pine Screener [XoRonX]

- url: https://www.tradingview.com/script/KqmxnYSS-RSI-Divergence-Pine-Screener-XoRonX/
- type: indicator
- pine_id: PUB;94f84096cb474df0b251b1e05588d7fe
- version: 1.0

## Description

RSI Divergence Pine Screener is designed to help scan watchlists using TradingView’s Pine Screener. The script detects RSI-based regular and hidden divergences by comparing price pivots with RSI pivots, then outputs clean numeric plots that can be used as screener columns or filters.

The indicator also displays the RSI line on the chart with overbought, oversold, and midline levels for visual confirmation.

Signal Code:

[list]
[*]2= Regular Bullish Divergence
[*]1 = Hidden Bullish Divergence
[*]-1 = Hidden Bearish Divergence
[*]-2 = Regular Bearish Divergence
[*]0 = No active signal
[/list]

Main Features:

[list]
[*]Pine Screener-compatible outputs
[*]Regular bullish and bearish divergence detection
[*]Hidden bullish and bearish divergence detection
[*]Optional RSI overbought/oversold signal filter
[*]Signal hold period for easier screening
[*]RSI chart display for manual confirmation
[*]Alert conditions for active bullish, bearish, and specific divergence events
[/list]

Suggested Pine Screener Filters:

[list]
[*][pine]Any Signal = 1[/pine] to find all active signals
[*][pine]Bullish Signal = 1[/pine] to find bullish setups
[*][pine]Bearish Signal = 1[/pine] to find bearish setups
[*][pine]Signal Code > 0[/pine] for bullish signals
[*][pine]Signal Code < 0 [/pine]for bearish signals
[/list]
This tool is intended for technical analysis and screening support only. It does not provide financial advice. Always confirm signals with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("RSI Divergence Pine Screener [XoRonX]", shorttitle="RSI Div Screener", overlay=false)

// Signal Code:
//   2  = regular bullish divergence
//   1  = hidden bullish divergence
//  -1  = hidden bearish divergence
//  -2  = regular bearish divergence
//   0  = no active signal

grpRsi   = "RSI"
grpPivot = "Pivot"
grpScan  = "Pine Screener"

rsiLength = input.int(14, "RSI Length", minval=1, group=grpRsi)
rsiSource = input.source(close, "RSI Source", group=grpRsi)
rsiOB     = input.int(70, "Overbought Level", minval=50, group=grpRsi)
rsiOS     = input.int(30, "Oversold Level", maxval=50, group=grpRsi)

pivotLeft   = input.int(5, "Pivot Lookback Left", minval=1, maxval=20, group=grpPivot)
pivotRight  = input.int(5, "Pivot Lookback Right", minval=0, maxval=20, group=grpPivot)
maxLookback = input.int(60, "Max Candle Distance", minval=10, maxval=200, group=grpPivot)

scanRegularBullish = input.bool(true, "Scan Regular Bullish", group=grpScan)
scanRegularBearish = input.bool(true, "Scan Regular Bearish", group=grpScan)
scanHiddenBullish  = input.bool(true, "Scan Hidden Bullish", group=grpScan)
scanHiddenBearish  = input.bool(true, "Scan Hidden Bearish", group=grpScan)
requireOBOS        = input.bool(true, "Require RSI OB/OS For Signal Code", group=grpScan)
signalHoldBars     = input.int(3, "Keep Signal Active For N Bars", minval=0, maxval=50, group=grpScan)

rsiValue = ta.rsi(rsiSource, rsiLength)

var float[] rsiHist    = array.new_float()
var int[]   rsiHistBar = array.new_int()

var float[] phPriceVal = array.new_float()
var int[]   phPriceBar = array.new_int()
var float[] phRsiVal   = array.new_float()
var int[]   phRsiBar   = array.new_int()

var float[] plPriceVal = array.new_float()
var int[]   plPriceBar = array.new_int()
var float[] plRsiVal   = array.new_float()
var int[]   plRsiBar   = array.new_int()

const int MAX_PIVOT = 50

trimFloat(array<float> values) =>
    if array.size(values) > MAX_PIVOT
        array.shift(values)

trimInt(array<int> values) =>
    if array.size(values) > MAX_PIVOT
        array.shift(values)

isLineClear(int x1, float y1, int x2, float y2, string divType) =>
    bool clear = true
    int span = x2 - x1

    if span > 1
        int len = array.size(rsiHistBar)
        if len > 0
            for j = 0 to len - 1
                int b = array.get(rsiHistBar, j)
                if b > x1 and b < x2
                    float rsiAtBar = array.get(rsiHist, j)
                    float t = (b - x1) / span
                    float lineValue = y1 + t * (y2 - y1)

                    if divType == "bear" and rsiAtBar > lineValue
                        clear := false
                        break

                    if divType == "bull" and rsiAtBar < lineValue
                        clear := false
                        break
    clear

findMatchingRSI(array<int> rsiBarArr, array<float> rsiValArr, int targetBar) =>
    float matchVal = na
    int matchBar = na
    int minDist = 999

    if array.size(rsiBarArr) >= 2
        for i = array.size(rsiBarArr) - 1 to 0
            int b = array.get(rsiBarArr, i)
            float v = array.get(rsiValArr, i)
            int d = math.abs(b - targetBar)
            if d <= pivotRight * 2 and d < minDist
                minDist := d
                matchVal := v
                matchBar := b
    [matchBar, matchVal]

var bool regularBearEvent = false
var bool regularBullEvent = false
var bool hiddenBearEvent  = false
var bool hiddenBullEvent  = false

regularBearEvent := false
regularBullEvent := false
hiddenBearEvent  := false
hiddenBullEvent  := false

float pivotHighPrice = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLowPrice  = ta.pivotlow(low, pivotLeft, pivotRight)
float pivotHighRSI   = ta.pivothigh(rsiValue, pivotLeft, pivotRight)
float pivotLowRSI    = ta.pivotlow(rsiValue, pivotLeft, pivotRight)

if barstate.isconfirmed
    array.push(rsiHist, rsiValue)
    array.push(rsiHistBar, bar_index)

    int maxHist = maxLookback + 50
    if array.size(rsiHist) > maxHist
        array.shift(rsiHist)
        array.shift(rsiHistBar)

    if not na(pivotHighPrice)
        array.push(phPriceVal, pivotHighPrice)
        array.push(phPriceBar, bar_index - pivotRight)
        trimFloat(phPriceVal)
        trimInt(phPriceBar)

    if not na(pivotHighRSI)
        array.push(phRsiVal, pivotHighRSI)
        array.push(phRsiBar, bar_index - pivotRight)
        trimFloat(phRsiVal)
        trimInt(phRsiBar)

    if not na(pivotLowPrice)
        array.push(plPriceVal, pivotLowPrice)
        array.push(plPriceBar, bar_index - pivotRight)
        trimFloat(plPriceVal)
        trimInt(plPriceBar)

    if not na(pivotLowRSI)
        array.push(plRsiVal, pivotLowRSI)
        array.push(plRsiBar, bar_index - pivotRight)
        trimFloat(plRsiVal)
        trimInt(plRsiBar)

    if scanRegularBearish and not na(pivotHighPrice) and array.size(phPriceBar) >= 2
        int curPBar = array.get(phPriceBar, array.size(phPriceBar) - 1)
        float curPVal = array.get(phPriceVal, array.size(phPriceVal) - 1)

        for i = array.size(phPriceBar) - 2 to 0
            int prevPBar = array.get(phPriceBar, i)
            float prevPVal = array.get(phPriceVal, i)
            int dist = curPBar - prevPBar

            if dist > 0 and dist <= maxLookback and curPVal > prevPVal
                [curRBar, curRVal] = findMatchingRSI(phRsiBar, phRsiVal, curPBar)
                [prevRBar, prevRVal] = findMatchingRSI(phRsiBar, phRsiVal, prevPBar)

                if not na(curRVal) and not na(prevRVal) and curRVal < prevRVal and isLineClear(prevRBar, prevRVal, curRBar, curRVal, "bear")
                    regularBearEvent := true
                    break

    if scanRegularBullish and not na(pivotLowPrice) and array.size(plPriceBar) >= 2
        int curPBar = array.get(plPriceBar, array.size(plPriceBar) - 1)
        float curPVal = array.get(plPriceVal, array.size(plPriceVal) - 1)

        for i = array.size(plPriceBar) - 2 to 0
            int prevPBar = array.get(plPriceBar, i)
            float prevPVal = array.get(plPriceVal, i)
            int dist = curPBar - prevPBar

            if dist > 0 and dist <= maxLookback and curPVal < prevPVal
                [curRBar, curRVal] = findMatchingRSI(plRsiBar, plRsiVal, curPBar)
                [prevRBar, prevRVal] = findMatchingRSI(plRsiBar, plRsiVal, prevPBar)

                if not na(curRVal) and not na(prevRVal) and curRVal > prevRVal and isLineClear(prevRBar, prevRVal, curRBar, curRVal, "bull")
                    regularBullEvent := true
                    break

    if scanHiddenBearish and not na(pivotHighPrice) and array.size(phPriceBar) >= 2
        int curPBar = array.get(phPriceBar, array.size(phPriceBar) - 1)
        float curPVal = array.get(phPriceVal, array.size(phPriceVal) - 1)

        for i = array.size(phPriceBar) - 2 to 0
            int prevPBar = array.get(phPriceBar, i)
            float prevPVal = array.get(phPriceVal, i)
            int dist = curPBar - prevPBar

            if dist > 0 and dist <= maxLookback and curPVal < prevPVal
                [curRBar, curRVal] = findMatchingRSI(phRsiBar, phRsiVal, curPBar)
                [prevRBar, prevRVal] = findMatchingRSI(phRsiBar, phRsiVal, prevPBar)

                if not na(curRVal) and not na(prevRVal) and curRVal > prevRVal and isLineClear(prevRBar, prevRVal, curRBar, curRVal, "bear")
                    hiddenBearEvent := true
                    break

    if scanHiddenBullish and not na(pivotLowPrice) and array.size(plPriceBar) >= 2
        int curPBar = array.get(plPriceBar, array.size(plPriceBar) - 1)
        float curPVal = array.get(plPriceVal, array.size(plPriceVal) - 1)

        for i = array.size(plPriceBar) - 2 to 0
            int prevPBar = array.get(plPriceBar, i)
            float prevPVal = array.get(plPriceVal, i)
            int dist = curPBar - prevPBar

            if dist > 0 and dist <= maxLookback and curPVal > prevPVal
                [curRBar, curRVal] = findMatchingRSI(plRsiBar, plRsiVal, curPBar)
                [prevRBar, prevRVal] = findMatchingRSI(plRsiBar, plRsiVal, prevPBar)

                if not na(curRVal) and not na(prevRVal) and curRVal < prevRVal and isLineClear(prevRBar, prevRVal, curRBar, curRVal, "bull")
                    hiddenBullEvent := true
                    break

bool isOB = rsiValue >= rsiOB
bool isOS = rsiValue <= rsiOS

bool filteredRegularBear = regularBearEvent and (not requireOBOS or isOB)
bool filteredRegularBull = regularBullEvent and (not requireOBOS or isOS)
bool filteredHiddenBear  = hiddenBearEvent and (not requireOBOS or isOB)
bool filteredHiddenBull  = hiddenBullEvent and (not requireOBOS or isOS)

int currentSignalCode = filteredRegularBear ? -2 :
     filteredRegularBull ? 2 :
     filteredHiddenBear ? -1 :
     filteredHiddenBull ? 1 : 0

var int lastSignalCode = 0
var int lastSignalBar = na

if currentSignalCode != 0
    lastSignalCode := currentSignalCode
    lastSignalBar := bar_index

int barsSinceSignal = not na(lastSignalBar) ? bar_index - lastSignalBar : na
bool activeSignal = not na(barsSinceSignal) and barsSinceSignal <= signalHoldBars
int signalCode = activeSignal ? lastSignalCode : 0

bool activeBullish = activeSignal and signalCode > 0
bool activeBearish = activeSignal and signalCode < 0

color signalColor = signalCode > 0 ? color.new(color.lime, 0) :
     signalCode < 0 ? color.new(color.red, 0) : color.new(color.gray, 100)

plot(signalCode, "Signal Code", display=display.data_window)
plot(activeSignal ? 1 : 0, "Any Signal", display=display.data_window)
plot(activeBullish ? 1 : 0, "Bullish Signal", display=display.data_window)
plot(activeBearish ? 1 : 0, "Bearish Signal", display=display.data_window)
plot(regularBullEvent ? 1 : 0, "Reg Bull Event", display=display.data_window)
plot(regularBearEvent ? 1 : 0, "Reg Bear Event", display=display.data_window)
plot(hiddenBullEvent ? 1 : 0, "Hidden Bull Event", display=display.data_window)
plot(hiddenBearEvent ? 1 : 0, "Hidden Bear Event", display=display.data_window)
plot(rsiValue, "RSI", color=color.new(color.purple, 0), linewidth=2)
plot(barsSinceSignal, "Bars Since Signal", display=display.data_window)
plot(activeSignal ? rsiValue : na, "Signal Marker", color=signalColor, style=plot.style_circles, linewidth=5)

hline(rsiOB, "Overbought", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(rsiOS, "Oversold", color=color.new(color.lime, 50), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

alertcondition(activeSignal, "PS Any Active Signal", "RSI divergence screener signal is active.")
alertcondition(activeBullish, "PS Bullish Active", "RSI divergence bullish signal is active.")
alertcondition(activeBearish, "PS Bearish Active", "RSI divergence bearish signal is active.")
alertcondition(filteredRegularBull, "PS Regular Bullish Event", "Regular bullish RSI divergence detected.")
alertcondition(filteredRegularBear, "PS Regular Bearish Event", "Regular bearish RSI divergence detected.")
alertcondition(filteredHiddenBull, "PS Hidden Bullish Event", "Hidden bullish RSI divergence detected.")
alertcondition(filteredHiddenBear, "PS Hidden Bearish Event", "Hidden bearish RSI divergence detected.")
````
