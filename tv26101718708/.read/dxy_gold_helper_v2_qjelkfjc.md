# DXY Gold Helper v2

- url: https://www.tradingview.com/script/qjeLkFJC-DXY-Gold-Helper-v2/
- type: indicator
- pine_id: PUB;d174d48f51a54bcba08dd97bd343d728
- version: 2.0

## Description

DXY Gold Helper — Smart Correlation Assistant for XAUUSD

The DXY Gold Helper is designed to help traders better understand the real-time relationship between the US Dollar Index (DXY) and Gold (XAUUSD).

Gold and DXY often move inversely, but many traders struggle to identify:

whether DXY strength is supporting gold weakness,
whether gold is diverging from DXY,
or whether current moves are temporary liquidity sweeps.

This indicator simplifies that process by providing a clean visual framework for correlation-based decision making.

Main Features
Real-time DXY directional bias
Gold vs DXY correlation analysis
Bullish/Bearish pressure detection
Divergence and conflict recognition
Momentum assistance for XAUUSD traders
Scalping and intraday friendly
Lightweight and clean chart display
How It Helps

The indicator is not designed to replace price action or structure analysis. Instead, it acts as a confirmation and context tool.

Examples:

DXY bullish + Gold weak → bearish pressure on gold
DXY bearish + Gold strong → bullish pressure on gold
DXY and Gold moving together → possible liquidity sweep, transition, or temporary correlation breakdown
Best Use Case

This tool works best when combined with:

market structure,
premium/discount analysis,
support/resistance,
HTF zones,
and proper risk management.
Recommended Timeframes
M1 / M5 for scalping
M15 / H1 for intraday context
Important Note

Correlation is not permanent. During news events, liquidity grabs, or strong institutional flows, Gold and DXY may temporarily move together before restoring inverse behavior.

Always use proper confirmation before entering trades.

Ideal For
XAUUSD scalpers
intraday traders
ICT/SMC traders
liquidity-based traders
traders seeking additional market context

DISCLAIMER:
This indicator is for educational and analytical purposes only. It does not provide financial advice or guaranteed trading signals.

## Source Code

````pine
//@version=6
indicator("DXY Gold Helper v2.1", overlay=true, max_labels_count=50)

//=========================================================
// Inputs
//=========================================================
dxySymbol      = input.symbol("TVC:DXY", "DXY Symbol")
trendLen       = input.int(20, "DXY Trend EMA Length", minval=2)

signalProfile  = input.string("Balanced", "Divergence Profile", options=["Responsive", "Balanced", "Conservative", "Custom"])

customPivotLen       = input.int(4,  "Custom Pivot Length", minval=2)
customMinSigGap      = input.int(10, "Custom Min Bars Between Signals", minval=1)
customPushLookback   = input.int(10, "Custom DXY Push Lookback", minval=4)
customUseTrendFilter = input.bool(true, "Custom: Use DXY Trend Filter")
customUsePushFilter  = input.bool(true, "Custom: Use DXY Push Filter")

maxPivotSepMin = input.int(20, "Max DXY-Gold Pivot Separation (Minutes)", minval=1)
divHoldBars    = input.int(6, "Confirmed Divergence Hold Bars", minval=1)
leadLookback   = input.int(8, "Lead/Lag Lookback", minval=3)

showTable      = input.bool(true,  "Show Table")
showSignals    = input.bool(false, "Show Signal Labels")
useChartTF     = input.bool(true,  "Use Chart Timeframe for DXY")
customTF       = input.timeframe("5", "Custom DXY Timeframe")

leadAtrLen     = input.int(14, "DXY Impulse ATR Length", minval=3)
leadAtrMult    = input.float(0.8, "Min DXY Impulse ATR Mult", step=0.1)

//=========================================================
// Profile Engine
//=========================================================
pivotLen =
     signalProfile == "Responsive"   ? 3 :
     signalProfile == "Balanced"     ? 4 :
     signalProfile == "Conservative" ? 5 :
                                       customPivotLen

minSigGap =
     signalProfile == "Responsive"   ? 8 :
     signalProfile == "Balanced"     ? 10 :
     signalProfile == "Conservative" ? 12 :
                                       customMinSigGap

pushLookback =
     signalProfile == "Responsive"   ? 8 :
     signalProfile == "Balanced"     ? 10 :
     signalProfile == "Conservative" ? 12 :
                                       customPushLookback

useTrendFilter =
     signalProfile == "Responsive"   ? true :
     signalProfile == "Balanced"     ? true :
     signalProfile == "Conservative" ? true :
                                       customUseTrendFilter

usePushFilter =
     signalProfile == "Responsive"   ? false :
     signalProfile == "Balanced"     ? true :
     signalProfile == "Conservative" ? true :
                                       customUsePushFilter

tfToUse = useChartTF ? timeframe.period : customTF

//=========================================================
// Pull DXY Data
//=========================================================
dxyClose = request.security(dxySymbol, tfToUse, close)
dxyHigh  = request.security(dxySymbol, tfToUse, high)
dxyLow   = request.security(dxySymbol, tfToUse, low)
dxyOpen  = request.security(dxySymbol, tfToUse, open)

//=========================================================
// DXY Trend Engine
//=========================================================
dxyEma = ta.ema(dxyClose, trendLen)

dxyBull = dxyClose > dxyEma
dxyBear = dxyClose < dxyEma

dxyTrendTxt =
     dxyBull ? "Bull" :
     dxyBear ? "Bear" :
               "Neutral"

dxyTrendCol =
     dxyBull ? color.new(color.lime, 0) :
     dxyBear ? color.new(color.red, 0)  :
               color.new(color.gray, 0)

//=========================================================
// Confirmed Pivot-Based DXY-Gold Divergence Engine
// Bull Div on Gold: DXY HH + Gold HL
// Bear Div on Gold: DXY LL + Gold LH
// v2.1: fresh-pivot event gating + time alignment
//=========================================================
dxyPivotHigh = request.security(dxySymbol, tfToUse, ta.pivothigh(high, pivotLen, pivotLen))
dxyPivotLow  = request.security(dxySymbol, tfToUse, ta.pivotlow(low,  pivotLen, pivotLen))

dxyPivotHighTime = request.security(dxySymbol, tfToUse, not na(ta.pivothigh(high, pivotLen, pivotLen)) ? time[pivotLen] : na)
dxyPivotLowTime  = request.security(dxySymbol, tfToUse, not na(ta.pivotlow(low, pivotLen, pivotLen)) ? time[pivotLen] : na)

goldPivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
goldPivotLow  = ta.pivotlow(low,  pivotLen, pivotLen)

goldPivotHighTime = not na(goldPivotHigh) ? time[pivotLen] : na
goldPivotLowTime  = not na(goldPivotLow)  ? time[pivotLen] : na

var float dxyPH1 = na
var float dxyPH2 = na
var float dxyPL1 = na
var float dxyPL2 = na
var int dxyPH1Time = na
var int dxyPH2Time = na
var int dxyPL1Time = na
var int dxyPL2Time = na

newDxyPH = not na(dxyPivotHigh)
newDxyPL = not na(dxyPivotLow)

if newDxyPH
    dxyPH2 := dxyPH1
    dxyPH2Time := dxyPH1Time
    dxyPH1 := dxyPivotHigh
    dxyPH1Time := dxyPivotHighTime

if newDxyPL
    dxyPL2 := dxyPL1
    dxyPL2Time := dxyPL1Time
    dxyPL1 := dxyPivotLow
    dxyPL1Time := dxyPivotLowTime

var float goldPH1 = na
var float goldPH2 = na
var float goldPL1 = na
var float goldPL2 = na
var int goldPH1Time = na
var int goldPH2Time = na
var int goldPL1Time = na
var int goldPL2Time = na

newGoldPH = not na(goldPivotHigh)
newGoldPL = not na(goldPivotLow)

if newGoldPH
    goldPH2 := goldPH1
    goldPH2Time := goldPH1Time
    goldPH1 := goldPivotHigh
    goldPH1Time := goldPivotHighTime

if newGoldPL
    goldPL2 := goldPL1
    goldPL2Time := goldPL1Time
    goldPL1 := goldPivotLow
    goldPL1Time := goldPivotLowTime

dxyHigherHigh = not na(dxyPH1) and not na(dxyPH2) and dxyPH1 > dxyPH2
dxyLowerLow   = not na(dxyPL1) and not na(dxyPL2) and dxyPL1 < dxyPL2

goldHigherLow = not na(goldPL1) and not na(goldPL2) and goldPL1 > goldPL2
goldLowerHigh = not na(goldPH1) and not na(goldPH2) and goldPH1 < goldPH2

maxPivotSepMs = maxPivotSepMin * 60 * 1000

bullPivotsAligned = not na(dxyPH1Time) and not na(goldPL1Time) and math.abs(dxyPH1Time - goldPL1Time) <= maxPivotSepMs
bearPivotsAligned = not na(dxyPL1Time) and not na(goldPH1Time) and math.abs(dxyPL1Time - goldPH1Time) <= maxPivotSepMs

bullPivotEvent = newDxyPH or newGoldPL
bearPivotEvent = newDxyPL or newGoldPH

dxyStrongUpPush   = dxyClose > ta.highest(dxyHigh[1], pushLookback)
dxyStrongDownPush = dxyClose < ta.lowest(dxyLow[1],  pushLookback)

bullDivRaw = bullPivotEvent and bullPivotsAligned and dxyHigherHigh and goldHigherLow
bearDivRaw = bearPivotEvent and bearPivotsAligned and dxyLowerLow and goldLowerHigh

bullDivFiltered = bullDivRaw and (not useTrendFilter or dxyBull) and (not usePushFilter or dxyStrongUpPush)
bearDivFiltered = bearDivRaw and (not useTrendFilter or dxyBear) and (not usePushFilter or dxyStrongDownPush)

var int lastBullDivBar = na
var int lastBearDivBar = na

bullDivEvent = bullDivFiltered and (na(lastBullDivBar) or (bar_index - lastBullDivBar > minSigGap))
bearDivEvent = bearDivFiltered and (na(lastBearDivBar) or (bar_index - lastBearDivBar > minSigGap))

if bullDivEvent
    lastBullDivBar := bar_index

if bearDivEvent
    lastBearDivBar := bar_index

bullDivActive = not na(lastBullDivBar) and (bar_index - lastBullDivBar <= divHoldBars)
bearDivActive = not na(lastBearDivBar) and (bar_index - lastBearDivBar <= divHoldBars)

divTxt =
     bullDivActive and not bearDivActive ? "Bull Div" :
     bearDivActive and not bullDivActive ? "Bear Div" :
     bullDivActive and bearDivActive     ? "Mixed" :
                                           "None"

divCol =
     bullDivActive and not bearDivActive ? color.new(color.lime, 0) :
     bearDivActive and not bullDivActive ? color.new(color.red, 0)  :
     bullDivActive and bearDivActive     ? color.new(color.orange, 0) :
                                           color.new(color.gray, 0)

//=========================================================
// Stronger DXY Lead / Lag Engine
//=========================================================
dxyRange = dxyHigh - dxyLow
dxyAvgRange = ta.ema(dxyRange, leadAtrLen)
dxyImpulseOK = dxyRange > (dxyAvgRange * leadAtrMult)

dxyBreakDown = dxyClose < ta.lowest(dxyLow[1], leadLookback)
dxyBreakUp   = dxyClose > ta.highest(dxyHigh[1], leadLookback)

goldStillHoldingLow  = close > ta.lowest(low[1], leadLookback)
goldStillHoldingHigh = close < ta.highest(high[1], leadLookback)

leadBull = dxyBreakDown and dxyImpulseOK and goldStillHoldingLow
leadBear = dxyBreakUp and dxyImpulseOK and goldStillHoldingHigh

leadTxt =
     leadBull and not leadBear ? "Bull Lead" :
     leadBear and not leadBull ? "Bear Lead" :
                                 "None"

leadCol =
     leadBull and not leadBear ? color.new(color.teal, 0) :
     leadBear and not leadBull ? color.new(color.maroon, 0) :
                                 color.new(color.gray, 0)

//=========================================================
// Composite Gold Bias
//=========================================================
goldBullScore = 0
goldBearScore = 0

goldBullScore += dxyTrendTxt == "Bear" ? 1 : 0
goldBullScore += bullDivActive ? 1 : 0
goldBullScore += leadBull ? 1 : 0

goldBearScore += dxyTrendTxt == "Bull" ? 1 : 0
goldBearScore += bearDivActive ? 1 : 0
goldBearScore += leadBear ? 1 : 0

biasTxt =
     goldBullScore >= 2 and goldBearScore == 0 ? "Strong Bull" :
     goldBullScore > goldBearScore             ? "Bull" :
     goldBearScore >= 2 and goldBullScore == 0 ? "Strong Bear" :
     goldBearScore > goldBullScore             ? "Bear" :
                                                 "Mixed"

biasCol =biasTxt == "Strong Bull" ? color.new(color.lime, 0) :biasTxt == "Bull"? color.new(color.green, 0) :biasTxt == "Strong Bear" ? color.new(color.red, 0) :biasTxt == "Bear"? color.new(color.maroon, 0) :color.new(color.orange, 0)

//=========================================================
// Table
//=========================================================
var table t = table.new(position.bottom_right, 2, 5, border_width=1)

if barstate.islast
    if showTable
        table.cell(t, 0, 0, "DXY Trend", text_color=color.white, bgcolor=color.black)
        table.cell(t, 1, 0, dxyTrendTxt, text_color=color.white, bgcolor=dxyTrendCol)

        table.cell(t, 0, 1, "DXY Div", text_color=color.white, bgcolor=color.black)
        table.cell(t, 1, 1, divTxt, text_color=color.white, bgcolor=divCol)

        table.cell(t, 0, 2, "Lead/Lag", text_color=color.white, bgcolor=color.black)
        table.cell(t, 1, 2, leadTxt, text_color=color.white, bgcolor=leadCol)

        table.cell(t, 0, 3, "Gold Bias", text_color=color.white, bgcolor=color.black)
        table.cell(t, 1, 3, biasTxt, text_color=color.white, bgcolor=biasCol)

        table.cell(t, 0, 4, "Div Profile", text_color=color.white, bgcolor=color.black)
        table.cell(t, 1, 4, signalProfile, text_color=color.white, bgcolor=color.new(color.blue, 65))
    else
        table.clear(t, 0, 0, 1, 4)

//=========================================================
// Signal Display: confirmed event only
//=========================================================
plotshape(showSignals and bullDivEvent, title="Bull Div", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), text="Bull Div", textcolor=color.black, size=size.tiny)
plotshape(showSignals and bearDivEvent, title="Bear Div", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="Bear Div", textcolor=color.white, size=size.tiny)

newLeadBull = leadBull and not leadBull[1]
newLeadBear = leadBear and not leadBear[1]

plotshape(showSignals and newLeadBull, title="Bull Lead", style=shape.circle, location=location.belowbar, color=color.new(color.teal, 0), size=size.tiny)
plotshape(showSignals and newLeadBear, title="Bear Lead", style=shape.circle, location=location.abovebar, color=color.new(color.maroon, 0), size=size.tiny)

//=========================================================
// Alerts: confirmed event only
//=========================================================
alertcondition(bullDivEvent, "Bullish DXY-Gold Divergence", "Confirmed bullish DXY-Gold divergence detected")
alertcondition(bearDivEvent, "Bearish DXY-Gold Divergence", "Confirmed bearish DXY-Gold divergence detected")
alertcondition(newLeadBull, "Bullish DXY Lead", "DXY is leading a possible bullish gold move")
alertcondition(newLeadBear, "Bearish DXY Lead", "DXY is leading a possible bearish gold move")
````
