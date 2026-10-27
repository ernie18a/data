# Failed Breakdown and 10SMA Spring 

- url: https://www.tradingview.com/script/uQ8BpAKJ-Failed-Breakdown-and-10SMA-Spring/
- type: indicator
- pine_id: PUB;fda8c1a376184ba1bb02bce3034b36eb
- version: 1.0

## Description

its a wyckoff sprint setup - you can hunt for pb's to 10 sma

## Source Code

````pine
//@version=5
indicator("Failed Breakdown + 10SMA Spring — Vulture", overlay=true)

// ═══════════════ INPUTS ═══════════════
minAvgVol = input.int(35000, "Min 50-day avg volume (shares)", minval=0, group="Liquidity")
minPrice  = input.float(25.0, "Min price (filter penny stocks)", minval=0, group="Liquidity")

lookback    = input.int(9, "Lookback for prior lows/closes", minval=2, group="Failed Breakdown")
useRangeMid = input.bool(true, "Enable reversal-from-lower-open (Condition B)", group="Failed Breakdown")
showGapDown = input.bool(true, "Show gap-down breakdown triangle (yellow)", group="Failed Breakdown")

enableSpring       = input.bool(true,  "Enable 10SMA Spring", group="10SMA Spring")
smaFast            = input.int(10, "Fast SMA", minval=2, group="10SMA Spring")
smaMid             = input.int(20, "Mid SMA",  minval=5, group="10SMA Spring")
smaSlow            = input.int(50, "Slow SMA", minval=10, group="10SMA Spring")
maxBarsToReclaim   = input.int(2,  "Case 2(a): max bars to reclaim 10SMA after close-below", minval=1, maxval=5, group="10SMA Spring")
wickCooldownBars   = input.int(4,  "Case 2(b): cooldown bars after wick spring fires", minval=0, maxval=10, group="10SMA Spring")
minWickDepthPct    = input.float(0.3, "Case 2(b): min wick depth below 10SMA (%)", minval=0.0, step=0.1, group="10SMA Spring")
maxStretchAbove20  = input.float(10.0, "Suppress spring if close > X% above 20SMA", minval=0.0, step=0.5, group="10SMA Spring")
smaSlopeLookback   = input.int(5, "Bars back to measure 10SMA slope (must be rising)", minval=1, maxval=20, group="10SMA Spring")
closeStrengthMin   = input.float(0.5, "Min close strength on signal day (0=any, 1=close at high)", minval=0.0, maxval=1.0, step=0.1, group="10SMA Spring")

// ═══════════════ LIQUIDITY ═══════════════
avgVol = ta.sma(volume, 50)
liquid = avgVol >= minAvgVol and close >= minPrice

// ═══════════════ FAILED BREAKDOWN LOGIC ═══════════════
priorLowClose = ta.lowest(close, lookback)[2]
priorLowLow   = ta.lowest(low,   lookback)[2]

day0Close = close[1]
day0High  = high[1]
day0Low   = low[1]
day0Mid   = (day0High + day0Low) / 2

closeBreakdown  = day0Close < priorLowClose
undercutRecover = day0Low < priorLowLow and day0Close > priorLowLow
breakdown       = closeBreakdown or undercutRecover

gappedUpHeld = open > day0Close and close > day0Close
reversedBack = useRangeMid and open < day0Close and close >= day0Mid
confirmation = gappedUpHeld or reversedBack

failedBreakdown = breakdown and confirmation and liquid

gapDown = high < day0Low and liquid

// ═══════════════ MOVING AVERAGES ═══════════════
sma10 = ta.sma(close, smaFast)
sma20 = ta.sma(close, smaMid)
sma50 = ta.sma(close, smaSlow)

stackedUptrend  = sma10 > sma20 and sma20 > sma50
sma10Rising     = sma10 > sma10[smaSlopeLookback]
trendOK         = stackedUptrend and sma10Rising

stretchPct      = (close - sma20) / sma20 * 100
notOverextended = stretchPct <= maxStretchAbove20

todayBarRange   = high - low
closeStrengthOK = todayBarRange == 0 ? false : (close - low) / todayBarRange >= closeStrengthMin

// ═══════════════ CASE 2(a): CLOSE-BASED BREAKDOWN ═══════════════
var bool closeBdActive    = false
var int  barsSinceCloseBd = 0

closeBasedBreakdown = stackedUptrend[1] and close[1] >= sma10[1] and close < sma10

if closeBasedBreakdown
    closeBdActive    := true
    barsSinceCloseBd := 1
else if closeBdActive
    barsSinceCloseBd += 1

if barsSinceCloseBd > maxBarsToReclaim
    closeBdActive    := false
    barsSinceCloseBd := 0

reclaim10 = closeBdActive and close[1] < sma10[1] and close > sma10
spring2a  = reclaim10 and trendOK and liquid and notOverextended and closeStrengthOK

if spring2a
    closeBdActive    := false
    barsSinceCloseBd := 0

// ═══════════════ CASE 2(b): INTRADAY WICK BREAKDOWN ═══════════════
var int barsSinceWickFire = 1000

// — Sub-path (i): Strong same-day spring —
todayWickDepthPct = (sma10 - low) / sma10 * 100
todayIsWick       = stackedUptrend and low < sma10 and close >= sma10 and todayWickDepthPct >= minWickDepthPct
strongRecovery    = close > close[1]
spring2b_strong   = todayIsWick and strongRecovery

// — Sub-path (ii): Next-day CLOSE above wick day's high —
// Using close instead of high prevents intraday-wick fakeouts from triggering signal
yestWickDepthPct    = (sma10[1] - low[1]) / sma10[1] * 100
yesterdayWasWick    = stackedUptrend[1] and low[1] < sma10[1] and close[1] >= sma10[1] and yestWickDepthPct >= minWickDepthPct
closesAboveYestHigh = close > day0High   // close-based confirmation, not intraday high
spring2b_standard   = yesterdayWasWick and closesAboveYestHigh

cooldownPassed = barsSinceWickFire > wickCooldownBars
spring2b = (spring2b_strong or spring2b_standard) and trendOK and liquid and cooldownPassed and notOverextended and closeStrengthOK

// Cooldown only resets when an actual signal fires
barsSinceWickFire := spring2b ? 1 : barsSinceWickFire + 1

// ═══════════════ COMBINED SPRING SIGNAL ═══════════════
springSignal = enableSpring and (spring2a or spring2b)

// ═══════════════ SCREENER OUTPUTS ═══════════════
plot(failedBreakdown ? 1 : 0, title="FailedBreakdown", display=display.data_window)
plot(springSignal    ? 1 : 0, title="Spring",          display=display.data_window)
plot(spring2a        ? 1 : 0, title="Spring_2a",       display=display.data_window)
plot(spring2b        ? 1 : 0, title="Spring_2b",       display=display.data_window)
plot(gapDown         ? 1 : 0, title="GapDown",         display=display.data_window)
plot(stretchPct,                title="StretchAbove20", display=display.data_window)

// ═══════════════ CHART VISUALS ═══════════════
plotshape(failedBreakdown, style=shape.triangleup, location=location.belowbar,
          color=color.lime, size=size.tiny, title="Failed Breakdown")
bgcolor(failedBreakdown ? color.new(color.green, 85) : na, title="Failed BD bar tint")

plotshape(springSignal, style=shape.triangledown, location=location.abovebar,
          color=color.new(#00ffcc, 50), size=size.tiny, title="10SMA Spring")
bgcolor(springSignal ? color.new(#00ffcc, 96) : na, title="Spring bar tint")

plotshape(showGapDown and gapDown, style=shape.triangledown, location=location.belowbar,
          color=color.yellow, size=size.tiny, title="Clear Gap-Down")

// ═══════════════ ALERTS ═══════════════
alertcondition(failedBreakdown, title="Failed Breakdown",
     message="{{ticker}} — failed breakdown confirmation on {{timeframe}}")

alertcondition(springSignal, title="10SMA Spring",
     message="{{ticker}} — 10SMA spring on {{timeframe}}")

alertcondition(spring2a, title="Spring 2a — Close Reclaim",
     message="{{ticker}} — 10SMA close-reclaim spring on {{timeframe}}")

alertcondition(spring2b, title="Spring 2b — Wick Spring",
     message="{{ticker}} — 10SMA wick spring on {{timeframe}}")

alertcondition(gapDown, title="Clear Gap-Down",
     message="{{ticker}} — clear gap-down (no overlap) on {{timeframe}}")

anyBullish = failedBreakdown or springSignal
alertcondition(anyBullish, title="Any Bullish Reversal",
     message="{{ticker}} — bullish reversal signal ({{timeframe}})")
````
