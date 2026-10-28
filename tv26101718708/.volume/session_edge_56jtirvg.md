# Session Edge

- url: https://www.tradingview.com/script/56JtiRvG-Session-Edge/
- type: indicator
- pine_id: PUB;4daf9d052fdc4d7ab00079a41c7900df
- version: 1.0

## Description

Session Edge is a clean, no-clutter 5-minute trading indicator built for futures traders who want clear, actionable signals without a crowded chart. It combines three core elements, EMA-9, VWAP, and session high/low levels, with a volume confirmation filter to identify only the highest-probability trade setups.

When the EMA-9 crosses VWAP with above-average volume, the indicator automatically draws a green profit box and a red risk box directly on the chart, showing your exact entry price, stop loss, TP1, and TP2 — with the dollar value of each level calculated in real time based on your selected tick value ($1.50, $2.50, or $5.00 per tick).

A built-in 30–50 point minimum filter blocks weak, low-range signals so you are only alerted when the market has enough momentum and range to make the trade worth taking. If the setup doesn't meet the minimum, the signal is suppressed automatically — no guesswork needed.

When it's time to get out, a simple orange X appears on the bar — no extra lines, no extra boxes, just a clean exit marker.

What you see on the chart:
EMA-9 (orange) and VWAP (aqua) for trend and fair value
Previous session high and low (two white lines) as key reference levels
A green box for your target zone and a red box for your risk zone on every valid signal
Dollar-based SL and TP levels calculated per trade automatically
Orange X exit signals when the opposing cross fires

Best used on: MES, MNQ, ES, NQ, or any high-volume futures instrument on the 5-minute timeframe during the London or New York session open.

## Source Code

````pine
//@version=5
indicator("Session Edge", overlay=true, max_boxes_count=100, max_labels_count=100)

// ─── INPUTS ────────────────────────────────────────────────
tickValue  = input.float(1.50, "Tick Value ($)", options=[1.50, 2.50, 5.00])
minPoints  = input.float(30.0, "Min Points (30–50)", minval=30, maxval=100)
atrLen     = input.int(14, "ATR Length")

// ─── CORE ──────────────────────────────────────────────────
ema9 = ta.ema(close, 9)
atr  = ta.atr(atrLen)

// VWAP
var float tpv = 0.0
var float vol = 0.0
if ta.change(time("D")) != 0
    tpv := 0.0
    vol := 0.0
tpv += hlc3 * volume
vol += volume
vwap = vol > 0 ? tpv / vol : na

// Volume filter
volMA   = ta.sma(volume, 20)
highVol = volume >= volMA * 1.5

// Session H/L (daily previous)
prevHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// ─── SIGNALS ───────────────────────────────────────────────
crossUp   = ta.crossover(ema9, vwap)
crossDown = ta.crossunder(ema9, vwap)

// Price must be near a key level (within 1 ATR of prev high or low)
nearLevel = math.abs(close - prevHigh) <= atr or math.abs(close - prevLow) <= atr

// Minimum point check — ATR must support 30+ point move
tradeValid = atr >= minPoints

longSig  = crossUp   and highVol and tradeValid
shortSig = crossDown and highVol and tradeValid
longExit = crossDown
shortExit= crossUp

// ─── PLOTS — KEEP IT CLEAN ─────────────────────────────────
plot(ema9,  "EMA 9", color=color.new(color.orange, 0), linewidth=2)
plot(vwap,  "VWAP",  color=color.new(color.aqua,   0), linewidth=2)

// Previous session high/low — just 2 lines
plot(prevHigh, "Prev High", color=color.new(color.white, 50), linewidth=1, style=plot.style_linebr)
plot(prevLow,  "Prev Low",  color=color.new(color.white, 50), linewidth=1, style=plot.style_linebr)

// ─── TRADE BOXES ───────────────────────────────────────────
// How many ticks per point (ES/NQ = 4 ticks per point)
ticksPerPoint = 4.0

if longSig
    sl   = close - atr
    tp1  = close + atr
    tp2  = close + atr * 2.0

    // SL ticks and dollar risk
    slTicks   = math.round((close - sl) * ticksPerPoint)
    tp1Ticks  = math.round((tp1 - close) * ticksPerPoint)
    tp2Ticks  = math.round((tp2 - close) * ticksPerPoint)
    dollarRisk= slTicks  * tickValue
    dollarTP1 = tp1Ticks * tickValue
    dollarTP2 = tp2Ticks * tickValue

    // Entry box
    box.new(bar_index, close, bar_index + 8, sl,
         bgcolor=color.new(color.red, 80),
         border_color=color.new(color.red, 30), border_width=1)
    // TP box
    box.new(bar_index, close, bar_index + 8, tp2,
         bgcolor=color.new(color.green, 80),
         border_color=color.new(color.green, 30), border_width=1)

    label.new(bar_index, sl - atr * 0.2,
         "▲ LONG\n" +
         "Entry: "  + str.tostring(close, "#.##") + "\n" +
         "SL:    "  + str.tostring(sl,    "#.##") + "  -$" + str.tostring(dollarRisk, "#") + "\n" +
         "TP1:   "  + str.tostring(tp1,   "#.##") + "  +$" + str.tostring(dollarTP1,  "#") + "\n" +
         "TP2:   "  + str.tostring(tp2,   "#.##") + "  +$" + str.tostring(dollarTP2,  "#"),
         color=color.new(color.green, 5),
         textcolor=color.white,
         style=label.style_label_up,
         size=size.normal)

if shortSig
    sl   = close + atr
    tp1  = close - atr
    tp2  = close - atr * 2.0

    slTicks   = math.round((sl - close) * ticksPerPoint)
    tp1Ticks  = math.round((close - tp1) * ticksPerPoint)
    tp2Ticks  = math.round((close - tp2) * ticksPerPoint)
    dollarRisk= slTicks  * tickValue
    dollarTP1 = tp1Ticks * tickValue
    dollarTP2 = tp2Ticks * tickValue

    box.new(bar_index, close, bar_index + 8, sl,
         bgcolor=color.new(color.red, 80),
         border_color=color.new(color.red, 30), border_width=1)
    box.new(bar_index, tp2, bar_index + 8, close,
         bgcolor=color.new(color.green, 80),
         border_color=color.new(color.green, 30), border_width=1)

    label.new(bar_index, sl + atr * 0.2,
         "▼ SHORT\n" +
         "Entry: "  + str.tostring(close, "#.##") + "\n" +
         "SL:    "  + str.tostring(sl,    "#.##") + "  -$" + str.tostring(dollarRisk, "#") + "\n" +
         "TP1:   "  + str.tostring(tp1,   "#.##") + "  +$" + str.tostring(dollarTP1,  "#") + "\n" +
         "TP2:   "  + str.tostring(tp2,   "#.##") + "  +$" + str.tostring(dollarTP2,  "#"),
         color=color.new(color.red, 5),
         textcolor=color.white,
         style=label.style_label_down,
         size=size.normal)

// ─── EXIT SIGNALS — SIMPLE SHAPES ONLY ────────────────────
plotshape(longExit,  title="Exit Long",  style=shape.xcross, location=location.abovebar, color=color.orange, size=size.small)
plotshape(shortExit, title="Exit Short", style=shape.xcross, location=location.belowbar, color=color.orange, size=size.small)

// ─── SKIP WARNING — only when cross fires but ATR too low ──
skipSig = (crossUp or crossDown) and highVol and not tradeValid
plotshape(skipSig, title="Skip", style=shape.xcross, location=location.abovebar, color=color.new(color.gray, 40), size=size.tiny)

// ─── ALERTS ────────────────────────────────────────────────
alertcondition(longSig,  title="LONG Entry",  message="Session Edge: LONG — EMA9 crossed above VWAP, 30pt+ move valid")
alertcondition(shortSig, title="SHORT Entry", message="Session Edge: SHORT — EMA9 crossed below VWAP, 30pt+ move valid")
alertcondition(longExit, title="Exit Long",   message="Session Edge: Exit your LONG now")
alertcondition(shortExit,title="Exit Short",  message="Session Edge: Exit your SHORT now")
````
