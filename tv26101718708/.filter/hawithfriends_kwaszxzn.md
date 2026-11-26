# HA_with_Friends

- url: https://www.tradingview.com/script/KwAsZxZN/
- type: indicator
- pine_id: PUB;e3f84b9683264d4888acecde9327850d
- version: 2.0

## Description

HA_with_Friends =
HA + Momentum + EMA + WWV Combined Indicator

This indicator combines four powerful technical analysis tools into a single pane, designed primarily for XAUUSD (Gold) trading but applicable to any instrument.

─── COMPONENTS ───────────────────────────────────────

1. Heiken Ashi Candles
   Displays smoothed Heiken Ashi candlesticks to filter out market noise
   and identify trend direction more clearly than standard candles.

2. EMA Cloud (50/100)
   Two Exponential Moving Averages with a dynamic color-filled cloud.
   - Green cloud = Uptrend (EMA 50 above EMA 100)
   - Red cloud   = Downtrend (EMA 50 below EMA 100)

3. HA Momentum Signal
   Detects the first high-momentum Heiken Ashi candle after a color change,
   filtering by Body Ratio, Wick Ratio, and Minimum Body Size.
   - ▲ Black triangle = BUY signal
   - ▼ Orange triangle = SELL signal

4. WWV ATR (Weis Wave Volume — ATR Method)
   Displays cumulative wave volume using ATR-based Renko logic.
   Green dot = Bullish wave | Red dot = Bearish wave

5. WWV LB (Weis Wave Volume — LazyBear Method)
   Displays cumulative wave volume using trend-detection logic.
   Lime dot = Bullish wave | Red dot = Bearish wave

─── SETTINGS ─────────────────────────────────────────

HA Momentum
   • Min Body Ratio (%)     — Minimum candle body as % of total range
   • Max Wick Ratio (%)     — Maximum momentum-side wick as % of total range
   • Min Body Size (Points) — Minimum body size in price points

EMA
   • EMA Fast Length (default: 50)
   • EMA Slow Length (default: 100)

WWV ATR
   • Value           — ATR period for Renko brick size
   • Price Source    — Close / Open-Close / High-Low
   • Use True Range  — Always / Auto / Never

WWV LB
   • Trend Detection Length — Bars used to confirm rising/falling trend

─── ALERTS ───────────────────────────────────────────

   • HA Momentum BUY Signal
   • HA Momentum SELL Signal

─── NOTES ────────────────────────────────────────────

   • All components are displayed in a separate pane (overlay = false)
   • WWV dots are plotted below Heiken Ashi candles using ATR-based offset
   • Optimized for M5 timeframe on XAUUSD
   • Combine with higher timeframe analysis for best results

## Source Code

````pine
//@version=6
indicator('HA_with_Friends', shorttitle='HA_WWV', overlay=false)

// ═══════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════
bodyRatioThreshold = input.float(40.0, "Min Body Ratio (%)",     minval=1, maxval=100, step=1, group="HA Momentum")
wickRatioThreshold = input.float(5.0,  "Max Wick Ratio (%)",     minval=0, maxval=100, step=1, group="HA Momentum")
minBodySize        = input.float(1.0,  "Min Body Size (Points)", minval=0, step=0.1,            group="HA Momentum")
emaFastLen         = input.int(50,  "EMA Fast Length", minval=1, group="EMA")
emaSlowLen         = input.int(100, "EMA Slow Length", minval=1, group="EMA")
atr_methodvalue    = input.float(14.0, "Value",              minval=0,                                      group="WWV ATR")
atr_pricesource    = input.string("Close", "Price Source",   options=["Close","Open / Close","High / Low"], group="WWV ATR")
atr_useTrueRange   = input.string("Auto",  "Use True Range", options=["Always","Auto","Never"],             group="WWV ATR")
lb_trendLen        = input.int(2, "Trend Detection Length", minval=1, group="WWV LB")
macd_fast          = input.int(12, "MACD Fast Length",   minval=1, group="MACD")
macd_slow          = input.int(26, "MACD Slow Length",   minval=1, group="MACD")
macd_signal        = input.int(9,  "MACD Signal Length", minval=1, group="MACD")

// ═══════════════════════════════════════════════════════
// SECTION 1: Heiken Ashi
// ═══════════════════════════════════════════════════════
haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen  := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh   = math.max(high, math.max(haOpen, haClose))
haLow    = math.min(low,  math.min(haOpen, haClose))
haBullish = haClose >= haOpen
haBearish = haClose <  haOpen

plotcandle(haOpen, haHigh, haLow, haClose,
     title       = "Heiken Ashi",
     color       = haBullish ? color.new(color.green, 20) : color.new(color.red, 20),
     wickcolor   = haBullish ? color.new(color.green, 20) : color.new(color.red, 20),
     bordercolor = haBullish ? color.new(color.green, 20) : color.new(color.red, 20))

// ═══════════════════════════════════════════════════════
// SECTION 2: EMA + Cloud
// ═══════════════════════════════════════════════════════
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

isUptrend   = emaFast > emaSlow
isDowntrend = emaFast < emaSlow

emaFastPlot = plot(emaFast, "EMA Fast", color=isUptrend ? color.green : color.red, linewidth=1)
emaSlowPlot = plot(emaSlow, "EMA Slow", color=isUptrend ? color.green : color.red, linewidth=1)

fill(emaFastPlot, emaSlowPlot,
     color = isUptrend   ? color.new(color.green, 80) :
             isDowntrend ? color.new(color.red,   80) :
             color.new(color.gray, 90),
     title = "EMA Cloud")

// ═══════════════════════════════════════════════════════
// SECTION 3: HA Momentum Signal
// ═══════════════════════════════════════════════════════
haBody      = math.abs(haClose - haOpen)
haRange     = haHigh - haLow
haLowerWick = math.min(haOpen, haClose) - haLow
haUpperWick = haHigh - math.max(haOpen, haClose)

bodyRatio      = haRange > 0 ? (haBody      / haRange) * 100 : 0
lowerWickRatio = haRange > 0 ? (haLowerWick / haRange) * 100 : 0
upperWickRatio = haRange > 0 ? (haUpperWick / haRange) * 100 : 0

isMomentumBull = haBullish and bodyRatio >= bodyRatioThreshold and lowerWickRatio <= wickRatioThreshold and haBody >= minBodySize
isMomentumBear = haBearish and bodyRatio >= bodyRatioThreshold and upperWickRatio <= wickRatioThreshold and haBody >= minBodySize

colorChangeToBull = haBullish and haBearish[1]
colorChangeToBear = haBearish and haBullish[1]

var bool waitingForBullMomentum = false
var bool waitingForBearMomentum = false

if colorChangeToBull
    waitingForBullMomentum := true
    waitingForBearMomentum := false
if colorChangeToBear
    waitingForBearMomentum := true
    waitingForBullMomentum := false

signalBuy  = waitingForBullMomentum and isMomentumBull
signalSell = waitingForBearMomentum and isMomentumBear

if signalBuy
    waitingForBullMomentum := false
if signalSell
    waitingForBearMomentum := false

plotshape(signalBuy,  title="Buy Signal",  style=shape.triangleup,
         location=location.belowbar, color=color.black,  size=size.tiny)
plotshape(signalSell, title="Sell Signal", style=shape.triangledown,
         location=location.abovebar, color=color.orange, size=size.tiny)

// ═══════════════════════════════════════════════════════
// SECTION 4: WWV ATR
// ═══════════════════════════════════════════════════════
atr_useClose     = atr_pricesource == "Close"
atr_useOpenClose = atr_pricesource == "Open / Close" or atr_useClose

atr_vol = atr_useTrueRange == "Always" or (atr_useTrueRange == "Auto" and na(volume)) ? ta.tr : volume
atr_op  = atr_useClose ? close : open
atr_hi  = atr_useOpenClose ? close >= atr_op ? close : atr_op : high
atr_lo  = atr_useOpenClose ? close <= atr_op ? close : atr_op : low

atr_mv = ta.atr(math.round(atr_methodvalue))
var float atr_currclose = na
atr_prevclose  = nz(atr_currclose[1])
atr_currclose := atr_hi > atr_prevclose + atr_mv ? atr_hi : atr_lo < atr_prevclose - atr_mv ? atr_lo : atr_prevclose

var int atr_direction = na
atr_direction          := atr_currclose > atr_prevclose ? 1 : atr_currclose < atr_prevclose ? -1 : nz(atr_direction[1])
atr_directionHasChanged = ta.change(atr_direction) != 0
atr_directionIsUp       = atr_direction > 0
atr_vol                := not atr_directionHasChanged ? atr_vol[1] + atr_vol : atr_vol

// ═══════════════════════════════════════════════════════
// SECTION 5: WWV LB
// ═══════════════════════════════════════════════════════
lb_mov = close > close[1] ? 1 : close < close[1] ? -1 : 0
var int lb_trend = na
lb_trend := (lb_mov != 0) and (lb_mov != nz(lb_mov[1])) ? lb_mov : nz(lb_trend[1])

lb_isTrending = ta.rising(close, lb_trendLen) or ta.falling(close, lb_trendLen)

var int lb_wave = na
lb_wave := (lb_trend != nz(lb_wave[1])) and lb_isTrending ? lb_trend : nz(lb_wave[1])

var float lb_vol = na
lb_vol := lb_wave == nz(lb_wave[1]) ? (nz(lb_vol[1]) + volume) : volume
lb_isUp = lb_wave == 1

// ═══════════════════════════════════════════════════════
// SECTION 6: MACD
// ═══════════════════════════════════════════════════════
[macdLine, signalLine, histLine] = ta.macd(close, macd_fast, macd_slow, macd_signal)

macdIsGreen = histLine >= 0
macdColor = histLine >= 0 and histLine >= histLine[1] ? color.new(#1b5e20, 0) :histLine >= 0 and histLine <  histLine[1] ? color.new(#81c784, 0) :histLine <  0 and histLine <= histLine[1] ? color.new(#b71c1c, 0) :color.new(#ef9a9a, 0)

// ═══════════════════════════════════════════════════════
// SECTION 7: WWV Dots ใต้แท่ง HA
// ═══════════════════════════════════════════════════════
price_atr  = ta.atr(14)
dot_atr_y  = haLow - price_atr * 3.0
dot_lb_y   = haLow - price_atr * 4.0
dot_macd_y = haLow - price_atr * 5.0

plot(dot_atr_y,
     title     = "WWV ATR Dot",
     style     = plot.style_steplinebr,
     color     = atr_directionIsUp ? color.new(color.green, 20) : color.new(color.red, 20),
     linewidth = 3)

plot(dot_lb_y,
     title     = "WWV LB Dot",
     style     = plot.style_circles,
     color     = lb_isUp ? color.new(color.lime, 20) : color.new(color.red, 20),
     linewidth = 3)

plot(dot_macd_y,
     title     = "MACD Dot",
     style     = plot.style_steplinebr,
     color     = macdColor,
     linewidth = 3)

// ═══════════════════════════════════════════════════════
// SECTION 8: Confluence Signal (ทั้ง 4 ตัวสีเดียวกัน)
// ═══════════════════════════════════════════════════════

// สถานะปัจจุบันของแต่ละ indicator
haIsGreen   = haBullish
atrIsGreen  = atr_directionIsUp
lbIsGreen   = lb_isUp

// ทุกตัวเขียวพร้อมกัน / ทุกตัวแดงพร้อมกัน
allGreen = haIsGreen and atrIsGreen and lbIsGreen and macdIsGreen
allRed   = not haIsGreen and not atrIsGreen and not lbIsGreen and not macdIsGreen

// แสดงเฉพาะแท่งแรกที่เปลี่ยน (ไม่แสดงซ้ำถ้าสีเดิม)
confluenceBuy  = allGreen and not allGreen[1]
confluenceSell = allRed   and not allRed[1]

plotshape(confluenceBuy,
     title     = "Confluence BUY",
     style     = shape.arrowup,
     location  = location.belowbar,
     color     = color.new(color.green, 0),
     size      = size.small)

plotshape(confluenceSell,
     title     = "Confluence SELL",
     style     = shape.arrowdown,
     location  = location.abovebar,
     color     = color.new(color.red, 0),
     size      = size.small)

// ═══════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════
alertcondition(signalBuy,      title="HA Momentum — Buy Signal",
     message="🟢 HA Momentum BUY | {{ticker}} | {{interval}} | Price: {{close}}")
alertcondition(signalSell,     title="HA Momentum — Sell Signal",
     message="🔴 HA Momentum SELL | {{ticker}} | {{interval}} | Price: {{close}}")
alertcondition(confluenceBuy,  title="Confluence — BUY",
     message="🚀 Confluence BUY (HA+ATR+LB+MACD) | {{ticker}} | {{interval}} | Price: {{close}}")
alertcondition(confluenceSell, title="Confluence — SELL",
     message="🔻 Confluence SELL (HA+ATR+LB+MACD) | {{ticker}} | {{interval}} | Price: {{close}}")
````
