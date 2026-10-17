# SpxSnipper - EMA 9 / SMA 21 Pullback Reclaim Signals

- url: https://www.tradingview.com/script/geptnf1V-SpxSnipper-EMA-9-SMA-21-Pullback-Reclaim-Signals/
- type: indicator
- pine_id: PUB;e84b8be6f0094339939d52eaa8f1c010
- version: 1.0

## Description

This indicator is designed to identify short-term pullback and reclaim conditions around the EMA 9 and SMA 21 moving average zone.

The script plots:
• EMA 9
• SMA 21
• Optional SMA 50
• Optional SMA 200
• A shaded zone between EMA 9 and SMA 21
• Bullish and bearish reclaim/rejection markers

Bullish logic:
A bullish signal may appear when EMA 9 is above SMA 21, both moving averages have been rising for the selected number of bars, and price either:
• touches or moves below EMA 9 during the candle and closes back above it, or
• closes inside the EMA 9 / SMA 21 zone and then reclaims EMA 9 on the following candle.

Bearish logic:
A bearish signal uses the opposite structure. EMA 9 must be below SMA 21, both moving averages must be falling for the selected number of bars, and price must either reject EMA 9 on the same candle or close back below EMA 9 after being inside the moving average zone.

Main features:
• EMA 9 and SMA 21 pullback/reclaim logic
• Adjustable number of bars required for MA direction confirmation
• Optional SMA 50 / SMA 200 trend filter
• Optional shaded moving average zone
• Optional signal-bar background highlight
• Alerts for bullish and bearish conditions

Suggested use:
This indicator is intended as a visual tool for studying pullbacks, reclaim candles, and short-term trend continuation setups. It can be used together with price action, market structure, volume, support/resistance, or other confirmation tools.

Important note:
Signals are based on moving average and price conditions. They should not be interpreted as standalone trading recommendations. Real-time signals may update before the candle closes, so users may prefer to evaluate signals after bar close.

This script is for educational and analytical purposes only and does not provide financial advice.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - EMA 9 / SMA 21 Pullback Reclaim Signals", overlay=true)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
showEMA9   = input.bool(true, "Show EMA 9")
showSMA21  = input.bool(true, "Show SMA 21")
showSMA50  = input.bool(false, "Show SMA 50")
showSMA200 = input.bool(false, "Show SMA 200")

trendBars = input.int(3, "MA Direction Bars Required", minval=1, maxval=20)

useSMAFilter = input.bool(false, "Use SMA 50/200 Trend Filter In Signals")

ema9Color   = input.color(color.orange, "EMA 9 Color")
sma21Color  = input.color(color.white, "SMA 21 Color")
sma50Color  = input.color(color.lime, "SMA 50 Color")
sma200Color = input.color(color.red, "SMA 200 Color")

showZone      = input.bool(true, "Show EMA 9 / SMA 21 Zone")
bullZoneColor = input.color(color.new(color.lime, 85), "Bull Zone Color")
bearZoneColor = input.color(color.new(color.red, 85), "Bear Zone Color")

showBgSignal = input.bool(false, "Highlight Signal Bar")

// ─────────────────────────────────────────────
// Moving Averages
// ─────────────────────────────────────────────
ema9   = ta.ema(close, 9)
sma21  = ta.sma(close, 21)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// ─────────────────────────────────────────────
// Helper functions: consecutive MA direction
// ─────────────────────────────────────────────
f_risingFor(float src, int bars) =>
    bool ok = true
    for i = 0 to bars - 1
        ok := ok and src[i] > src[i + 1]
    ok

f_fallingFor(float src, int bars) =>
    bool ok = true
    for i = 0 to bars - 1
        ok := ok and src[i] < src[i + 1]
    ok

ema9Rising  = f_risingFor(ema9, trendBars)
sma21Rising = f_risingFor(sma21, trendBars)

ema9Falling  = f_fallingFor(ema9, trendBars)
sma21Falling = f_fallingFor(sma21, trendBars)

// ─────────────────────────────────────────────
// Optional SMA 50 / SMA 200 trend filter
// ─────────────────────────────────────────────
bullTrendFilter = close > sma200 and sma50 > sma200
bearTrendFilter = close < sma200 and sma50 < sma200

bullTrendOk = useSMAFilter ? bullTrendFilter : true
bearTrendOk = useSMAFilter ? bearTrendFilter : true

// ─────────────────────────────────────────────
// MA structure
// ─────────────────────────────────────────────
bullMAStructure = ema9 > sma21 and ema9Rising and sma21Rising
bearMAStructure = ema9 < sma21 and ema9Falling and sma21Falling

// ─────────────────────────────────────────────
// BUY logic
// ─────────────────────────────────────────────

// Case 1:
// Same-candle reclaim.
// Price touches or moves below EMA 9 during the candle,
// but closes back above EMA 9.
bullSameCandleReclaim = low <= ema9 and close > ema9

// Case 2:
// Previous candle closes inside the EMA 9 / SMA 21 zone,
// then current candle closes back above EMA 9.
bullPrevCloseInsideZone = close[1] < ema9[1] and close[1] > sma21[1]
bullNextCandleReclaim   = close > ema9
bullTwoStepReclaim      = bullPrevCloseInsideZone and bullNextCandleReclaim

buySignal = bullTrendOk and bullMAStructure and (bullSameCandleReclaim or bullTwoStepReclaim)

// ─────────────────────────────────────────────
// SELL logic - mirror logic
// ─────────────────────────────────────────────

// Case 1:
// Same-candle rejection.
// Price touches or moves above EMA 9 during the candle,
// but closes back below EMA 9.
bearSameCandleReject = high >= ema9 and close < ema9

// Case 2:
// Previous candle closes inside the EMA 9 / SMA 21 zone,
// then current candle closes back below EMA 9.
bearPrevCloseInsideZone = close[1] > ema9[1] and close[1] < sma21[1]
bearNextCandleReject    = close < ema9
bearTwoStepReject       = bearPrevCloseInsideZone and bearNextCandleReject

sellSignal = bearTrendOk and bearMAStructure and (bearSameCandleReject or bearTwoStepReject)

// ─────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────
pEma9  = plot(showEMA9 ? ema9 : na, "EMA 9", color=showEMA9 ? ema9Color : na, linewidth=2)
pSma21 = plot(showSMA21 ? sma21 : na, "SMA 21", color=showSMA21 ? sma21Color : na, linewidth=2)

plot(showSMA50 ? sma50 : na, "SMA 50", color=showSMA50 ? sma50Color : na, linewidth=2)
plot(showSMA200 ? sma200 : na, "SMA 200", color=showSMA200 ? sma200Color : na, linewidth=2)

// Zone between EMA 9 and SMA 21
zoneColor = ema9 >= sma21 ? bullZoneColor : bearZoneColor
fill(pEma9, pSma21, color=showZone ? zoneColor : na, title="EMA 9 / SMA 21 Zone")

// ─────────────────────────────────────────────
// Signals
// ─────────────────────────────────────────────
plotshape(
     buySignal,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY"
)

plotshape(
     sellSignal,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL"
)

// ─────────────────────────────────────────────
// Optional background
// ─────────────────────────────────────────────
bgcolor(showBgSignal and buySignal ? color.new(color.lime, 85) : na)
bgcolor(showBgSignal and sellSignal ? color.new(color.red, 85) : na)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(
     buySignal,
     title="Buy Signal",
     message="Bullish EMA9/SMA21 pullback reclaim buy signal detected"
)

alertcondition(
     sellSignal,
     title="Sell Signal",
     message="Bearish EMA9/SMA21 pullback rejection sell signal detected"
)
````
