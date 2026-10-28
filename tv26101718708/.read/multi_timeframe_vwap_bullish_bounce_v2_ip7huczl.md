# Multi Timeframe VWAP Bullish Bounce V2

- url: https://www.tradingview.com/script/ip7huczl-Multi-Timeframe-VWAP-Bullish-Bounce-V2/
- type: indicator
- pine_id: PUB;51c357a0d4fa4cf8a34c23b34e6561da
- version: 1.0

## Description

an alert to tell me when a stock price that is above VWap touches Vwap intraday on 3minute and 5 minute time frame in trading view ... give me the pine script to load into Tradig view . I have real time . Call it Multi time frame VWap bullish bounce and make one for the opposite and call it Multi time frame VWap bearish bounce

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Multi Timeframe VWAP Bullish Bounce

//@version=5
indicator(title="Multi Timeframe VWAP Bullish Bounce", shorttitle="MTF VWAP Bull Bounce", overlay=true)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
tf1 = input.timeframe("3", title="Timeframe 1 (e.g. 3 = 3-min)")
tf2 = input.timeframe("5", title="Timeframe 2 (e.g. 5 = 5-min)")

showTF1  = input.bool(true,  title="Show 3-min VWAP")
showTF2  = input.bool(true,  title="Show 5-min VWAP")
showBars = input.int(3,      title="Lookback bars for touch detection", minval=1, maxval=10)

alertOnce = input.bool(false, title="Alert Once Per Bar (vs. Every Tick)")

// ─────────────────────────────────────────────
//  VWAP CALCULATION  (session-anchored)
// ─────────────────────────────────────────────
// Pull VWAP values from the two requested timeframes
vwap3 = request.security(syminfo.tickerid, tf1, ta.vwap(hlc3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap5 = request.security(syminfo.tickerid, tf2, ta.vwap(hlc3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  PLOT VWAP LINES
// ─────────────────────────────────────────────
plot(showTF1 ? vwap3 : na, title="VWAP (3-min)", color=color.new(color.aqua,  10), linewidth=1, style=plot.style_line)
plot(showTF2 ? vwap5 : na, title="VWAP (5-min)", color=color.new(color.yellow, 10), linewidth=1, style=plot.style_line)

// ─────────────────────────────────────────────
//  LOGIC — BULLISH BOUNCE
//
//  Condition: price was ABOVE VWAP on recent bars,
//             current bar LOW touches / crosses VWAP,
//             and price closes (or is trading) ABOVE VWAP
//             (i.e., a wick touch, not a breakdown).
// ─────────────────────────────────────────────

// Helper: was the close above VWAP for the last N bars (excl. current)?
wasAbove3 = ta.lowest(close[1], showBars) > vwap3[1]
wasAbove5 = ta.lowest(close[1], showBars) > vwap5[1]

// Current bar LOW dipped to or below VWAP but CLOSE stays above → touch/bounce
touchedVWAP3 = low <= vwap3 and close > vwap3
touchedVWAP5 = low <= vwap5 and close > vwap5

// Combined: both timeframes agree
bullBounce3  = wasAbove3 and touchedVWAP3
bullBounce5  = wasAbove5 and touchedVWAP5
bullBounce   = bullBounce3 and bullBounce5   // BOTH TFs must fire

// ─────────────────────────────────────────────
//  VISUAL SIGNALS
// ─────────────────────────────────────────────
plotshape(bullBounce,
     title    = "Bullish VWAP Bounce",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.new(color.lime, 0),
     size     = size.normal,
     text     = "VWAP\nBounce")

// Optional: highlight the candle
barcolor(bullBounce ? color.new(color.lime, 60) : na)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(bullBounce,
     title   = "MTF VWAP Bullish Bounce",
     message = "⬆️ {{ticker}} — Multi-TF VWAP Bullish Bounce detected on {{interval}} chart!\nPrice touched VWAP on BOTH 3-min & 5-min and bounced higher.\nBar time: {{time}}\nClose: {{close}}")

// Per-TF alerts (optional — create separately in the Alerts panel)
alertcondition(bullBounce3,
     title   = "3-min VWAP Bullish Bounce",
     message = "⬆️ {{ticker}} — 3-min VWAP Bullish Bounce! Close: {{close}} | Time: {{time}}")

alertcondition(bullBounce5,
     title   = "5-min VWAP Bullish Bounce",
     message = "⬆️ {{ticker}} — 5-min VWAP Bullish Bounce! Close: {{close}} | Time: {{time}}")
````
