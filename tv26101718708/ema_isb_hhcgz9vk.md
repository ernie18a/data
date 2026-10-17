# EMA + ISB

- url: https://www.tradingview.com/script/HhcGz9Vk-EMA-ISB/
- type: indicator
- pine_id: PUB;ba758d4f3b844b3891506b9f2ca8d26e
- version: 1.0

## Description

Combines two EMAs with Inside Bar detection, plus a confluence signal and a trading-session filter.

  Components:
  - Dual EMA (default 9 & 34) — customizable length, source, and color.
  - Inside Bar — highlights only inside-bar candles in yellow (body fully contained within the previous candle's
  body); all other candles keep their default color.
  - EMA Cross — ▲ green marker (cross up) / ▼ red marker (cross down).

  Confluence signal (◆ + Alert):
  - Triggers when an EMA cross AND an Inside Bar occur close together, in either order (one before the other),
  within the Cross-IB Window (default 3 bars; set 0 to require the same bar).

  Session filter (Houston / CT time):
  - Modes: US only / Asia only / Asia & US / All day.
  - The allowed window is shaded light blue; the confluence signal fires only within the selected session.

  Alert: EMA Cross + Inside Bar — recommended Once Per Bar Close.

## Source Code

````pine
//@version=6
indicator("EMA 9/34 + Inside Bar", "EMA+IB", overlay=true)

// =============== Inputs ===============
emaFastLen = input.int(9,  "EMA Fast", minval=1, group="EMA")
emaSlowLen = input.int(34, "EMA Slow", minval=1, group="EMA")
emaSrc     = input.source(close, "EMA Source", group="EMA")
emaFastCol = input.color(color.blue,   "EMA Fast Color", group="EMA")
emaSlowCol = input.color(color.orange, "EMA Slow Color", group="EMA")

ibCol = input.color(color.yellow, "Inside Bar Color", group="Inside Bar")

showCross   = input.bool(true, "Show EMA Cross Markers", group="Alerts")
crossWindow = input.int(3, "Cross-IB Window (bars)", minval=0, group="Alerts", tooltip="Số nến tối đa giữa EMA cross và inside bar để tính là cùng tín hiệu. 0 = phải cùng 1 nến.")

// =============== Trading Session filter (Houston / CT) ===============
group_session  = "Trading Sessions (Phiên Giao Dịch)"
session_option = input.string("Chỉ Phiên Mỹ", title="Chọn Phiên", options=["Chỉ Phiên Mỹ", "Chỉ Phiên Á", "Cả Á và Mỹ", "Trade Cả Ngày"], group=group_session)
asia_sess      = input.session("1900-0300", title="Giờ Phiên Á (Houston)", group=group_session)
us_sess        = input.session("0830-1500", title="Giờ Phiên Mỹ (Houston)", group=group_session)

in_asia_time = not na(time(timeframe.period, asia_sess, "America/Chicago"))
in_us_time   = not na(time(timeframe.period, us_sess,   "America/Chicago"))

var bool in_session = false
if session_option == "Trade Cả Ngày"
    in_session := true
else if session_option == "Chỉ Phiên Mỹ"
    in_session := in_us_time
else if session_option == "Chỉ Phiên Á"
    in_session := in_asia_time
else
    in_session := in_asia_time or in_us_time

bgcolor(in_session and session_option != "Trade Cả Ngày" ? color.new(color.blue, 96) : na, title="Khung giờ được phép Trade")

// =============== EMA ===============
emaFast = ta.ema(emaSrc, emaFastLen)
emaSlow = ta.ema(emaSrc, emaSlowLen)

plot(emaFast, "EMA Fast", color=emaFastCol, linewidth=2)
plot(emaSlow, "EMA Slow", color=emaSlowCol, linewidth=2)

// =============== Inside Bar detection ===============
// Body-based inside bar: current candle's body is contained within the previous candle's body.
bullInside = close[1] > open[1] and close < close[1] and close > open[1] and open < close[1] and open > open[1]
bearInside = close[1] < open[1] and close > close[1] and close < open[1] and open > close[1] and open < open[1]
ins = bullInside or bearInside

// Color ONLY inside-bar candles; leave every other candle at its default chart color (na).
barcolor(ins ? ibCol : na)

// =============== EMA cross ===============
crossUp   = ta.crossover(emaFast, emaSlow)   // fast cuts above slow (bullish)
crossDown = ta.crossunder(emaFast, emaSlow)  // fast cuts below slow (bearish)

plotshape(showCross and crossUp,   "EMA Cross Up",   shape.triangleup,   location.belowbar, color.green, size=size.tiny)
plotshape(showCross and crossDown, "EMA Cross Down", shape.triangledown, location.abovebar, color.red,   size=size.tiny)

// =============== Combined signal: EMA cross AND inside bar (either order) ===============
// Fire when both events occur within crossWindow bars of each other, in any order:
//   - inside bar now while an EMA cross happened within the last crossWindow bars, OR
//   - EMA cross now while an inside bar happened within the last crossWindow bars.
cross          = crossUp or crossDown
barsSinceCross = ta.barssince(cross)
barsSinceIns   = ta.barssince(ins)
comboOnIns   = ins   and not na(barsSinceCross) and barsSinceCross <= crossWindow
comboOnCross = cross and not na(barsSinceIns)   and barsSinceIns   <= crossWindow
// Only fire inside the selected trading session.
comboSignal = (comboOnIns or comboOnCross) and in_session

plotshape(comboSignal, "Cross + Inside Bar", shape.diamond, location.belowbar, color.yellow, size=size.small)

alertcondition(comboSignal, "EMA Cross + Inside Bar", "EMA cross & inside bar confluence")
````
