# Multi Timeframe VWAP Bullish Bounce v3

- url: https://www.tradingview.com/script/MQHqSR6y-Multi-Timeframe-VWAP-Bullish-Bounce-v3/
- type: indicator
- pine_id: PUB;94d066cacbee4f6d836489ecc9f66ed6
- version: 1.0

## Description

add to the bullish script that there has to be accompanying volume with the bounce , it has to close 2 candles above and include 10 minute timeframe

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Multi Timeframe VWAP Bullish Bounce — v3
//
// ALL conditions must be true simultaneously:
//   1.  Clear uptrend  — 9 EMA > 20 EMA > 50 EMA on the chart TF
//   2.  Pullback to VWAP on 3-min, 5-min AND 10-min (price was above, wicks to VWAP)
//   3.  Bounce candle is a Hammer OR Bullish Engulfing closing above VWAP
//   4.  Bounce candle volume >= 1.5× average volume
//   5.  RSI on bounce bar dips into 40–45 zone (and is rising or at zone low)
//   6.  Following candle reclaims the 9 EMA (close > 9 EMA)
//   7.  5-min chart is in bullish structure (close > 9 EMA on 5-min, 5-min VWAP upsloping)

//@version=5
indicator(title="Multi Timeframe VWAP Bullish Bounce v3", shorttitle="MTF VWAP Bull v3", overlay=true)

// ═══════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════

// — Timeframes —
tf1  = input.timeframe("3",  title="TF1 VWAP (3-min)")
tf2  = input.timeframe("5",  title="TF2 VWAP (5-min)")
tf3  = input.timeframe("10", title="TF3 VWAP (10-min)")

// — VWAP Display —
showVWAP3  = input.bool(true, title="Show 3-min VWAP",  group="Display")
showVWAP5  = input.bool(true, title="Show 5-min VWAP",  group="Display")
showVWAP10 = input.bool(true, title="Show 10-min VWAP", group="Display")
showEMAs   = input.bool(true, title="Show 9/20/50 EMAs", group="Display")

// — Uptrend & EMA —
ema9Len  = input.int(9,  title="Fast EMA length",   group="Uptrend")
ema20Len = input.int(20, title="Mid  EMA length",   group="Uptrend")
ema50Len = input.int(50, title="Slow EMA length",   group="Uptrend")
lookback = input.int(3,  title="Bars price must be above VWAP before pullback", minval=1, maxval=15, group="Uptrend")

// — Volume —
volMult = input.float(1.5, title="Min volume multiplier vs average (e.g. 1.5 = 150%)", minval=0.5, step=0.1, group="Volume")
volLen  = input.int(20,    title="Volume average length (bars)", minval=5, group="Volume")

// — RSI —
rsiLen      = input.int(14,   title="RSI length", group="RSI")
rsiLow      = input.float(40.0, title="RSI zone low  (default 40)", minval=20, maxval=50, group="RSI")
rsiHigh     = input.float(45.0, title="RSI zone high (default 45)", minval=25, maxval=55, group="RSI")

// ═══════════════════════════════════════════════════════════
//  VWAP  (session-anchored, from each TF)
// ═══════════════════════════════════════════════════════════
vwap3  = request.security(syminfo.tickerid, tf1, ta.vwap(hlc3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap5  = request.security(syminfo.tickerid, tf2, ta.vwap(hlc3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap10 = request.security(syminfo.tickerid, tf3, ta.vwap(hlc3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════
//  EMAs  (chart timeframe)
// ═══════════════════════════════════════════════════════════
ema9  = ta.ema(close, ema9Len)
ema20 = ta.ema(close, ema20Len)
ema50 = ta.ema(close, ema50Len)

// ═══════════════════════════════════════════════════════════
//  5-MIN BULLISH STRUCTURE
//  — 5-min close is above its own 9 EMA
//  — 5-min VWAP is rising (current > previous bar)
// ═══════════════════════════════════════════════════════════
ema9_5m   = request.security(syminfo.tickerid, tf2, ta.ema(close, ema9Len),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
close_5m  = request.security(syminfo.tickerid, tf2, close,                    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap5_cur = request.security(syminfo.tickerid, tf2, ta.vwap(hlc3),            gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
vwap5_prv = request.security(syminfo.tickerid, tf2, ta.vwap(hlc3)[1],         gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bullish5mStructure = close_5m > ema9_5m and vwap5_cur > vwap5_prv

// ═══════════════════════════════════════════════════════════
//  CONDITION 1 — CLEAR UPTREND
//  9 EMA > 20 EMA > 50 EMA on the current chart
// ═══════════════════════════════════════════════════════════
uptrend = ema9 > ema20 and ema20 > ema50

// ═══════════════════════════════════════════════════════════
//  CONDITION 2 — PULLBACK TO VWAP
//  Price was above all 3 VWAPs, then wicks to them
// ═══════════════════════════════════════════════════════════
wasAbove3  = ta.lowest(close[1], lookback) > vwap3[1]
wasAbove5  = ta.lowest(close[1], lookback) > vwap5[1]
wasAbove10 = ta.lowest(close[1], lookback) > vwap10[1]

pulledBack3  = low <= vwap3
pulledBack5  = low <= vwap5
pulledBack10 = low <= vwap10

pullbackToVWAP = wasAbove3 and wasAbove5 and wasAbove10 and
     pulledBack3 and pulledBack5 and pulledBack10

// ═══════════════════════════════════════════════════════════
//  CONDITION 3 — CANDLE PATTERN: HAMMER or BULLISH ENGULFING
//  Both must close ABOVE VWAP (using vwap3 as primary reference)
// ═══════════════════════════════════════════════════════════
bodySize   = math.abs(close - open)
totalRange = high - low
upperWick  = high - math.max(close, open)
lowerWick  = math.min(close, open) - low

// Hammer: small body in upper third, long lower wick (>= 2× body), close > open (bullish)
isHammer = close > open and
     lowerWick >= bodySize * 2.0 and
     upperWick <= bodySize * 0.5 and
     close > vwap3

// Bullish Engulfing: current bull candle fully wraps prior bear candle
isBullEngulf = close > open and            // current is bullish
     open[1] > close[1] and                // prior was bearish
     close > open[1] and                   // current close > prior open
     open  < close[1] and                  // current open  < prior close
     close > vwap3                         // closes above VWAP

candlePattern = isHammer or isBullEngulf

// ═══════════════════════════════════════════════════════════
//  CONDITION 4 — VOLUME >= 1.5× AVERAGE
// ═══════════════════════════════════════════════════════════
avgVol    = ta.sma(volume, volLen)
volumeOK  = volume >= avgVol * volMult

// ═══════════════════════════════════════════════════════════
//  CONDITION 5 — RSI BOUNCES IN 40–45 ZONE
//  RSI dipped into or touched the zone and is now rising
// ═══════════════════════════════════════════════════════════
rsi = ta.rsi(close, rsiLen)

// RSI touched 40-45 on current or previous bar and is now >= zone low
rsiInZone    = rsi >= rsiLow  and rsi <= rsiHigh
rsiTouchedLB = rsi[1] >= rsiLow and rsi[1] <= rsiHigh   // prior bar in zone
rsiRising    = rsi > rsi[1]                              // RSI turning up

rsiOK = (rsiInZone or rsiTouchedLB) and rsiRising

// ═══════════════════════════════════════════════════════════
//  RAW SIGNAL — all conditions on the bounce candle
// ═══════════════════════════════════════════════════════════
rawSignal = uptrend        and
     pullbackToVWAP        and
     candlePattern         and
     volumeOK              and
     rsiOK                 and
     bullish5mStructure

// ═══════════════════════════════════════════════════════════
//  CONDITION 6 — FOLLOWING CANDLE RECLAIMS 9 EMA
//  rawSignal fired 1 bar ago AND current close > 9 EMA
//  AND price is above all 3 VWAPs (2-candle confirmation)
// ═══════════════════════════════════════════════════════════
reclaimed9EMA = close > ema9
confirmedAboveVWAP = close > vwap3 and close > vwap5 and close > vwap10

// FULL CONFIRMED signal
bullBounceV3 = rawSignal[1] and reclaimed9EMA and confirmedAboveVWAP

// ═══════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════
plot(showVWAP3  ? vwap3  : na, title="VWAP 3-min",  color=color.new(color.aqua,   10), linewidth=1)
plot(showVWAP5  ? vwap5  : na, title="VWAP 5-min",  color=color.new(color.yellow, 10), linewidth=1)
plot(showVWAP10 ? vwap10 : na, title="VWAP 10-min", color=color.new(color.orange, 10), linewidth=2)

plot(showEMAs ? ema9  : na, title="9 EMA",  color=color.new(color.lime,  20), linewidth=1)
plot(showEMAs ? ema20 : na, title="20 EMA", color=color.new(color.white, 40), linewidth=1)
plot(showEMAs ? ema50 : na, title="50 EMA", color=color.new(color.red,   30), linewidth=1)

// ─── RSI reference label (draws on price chart, shows RSI value at signal) ───
plotchar(rawSignal, title="RSI at Signal", char="", location=location.belowbar, color=color.new(color.purple, 100))

// ─── Raw signal dot (pending 9 EMA reclaim) ───
plotshape(rawSignal,
     title    = "⏳ Setup Detected",
     style    = shape.circle,
     location = location.belowbar,
     color    = color.new(color.yellow, 20),
     size     = size.small,
     text     = "⏳")

// ─── Confirmed signal — full green arrow ───
plotshape(bullBounceV3,
     title    = "✅ v3 Confirmed Bullish Bounce",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.new(color.lime, 0),
     size     = size.large,
     text     = "v3\n✅ BUY")

// ─── Candle colouring ───
barcolor(bullBounceV3 ? color.new(color.lime,   45) : na)
barcolor(rawSignal    ? color.new(color.yellow, 60) : na)

// ─── Background flash on confirmed signal ───
bgcolor(bullBounceV3 ? color.new(color.lime, 92) : na, title="Confirmed bounce background")

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════

alertcondition(bullBounceV3,
     title   = "✅ v3 MTF VWAP Bullish Bounce — CONFIRMED",
     message = "✅ ⬆️ {{ticker}} — v3 CONFIRMED VWAP Bullish Bounce!\n\n✔ Uptrend: 9 EMA > 20 EMA > 50 EMA\n✔ VWAP touch on 3-min, 5-min & 10-min\n✔ Hammer or Engulfing candle above VWAP\n✔ Volume ≥ 1.5× average\n✔ RSI bounced from 40–45 zone\n✔ Price reclaimed 9 EMA\n✔ 5-min chart bullish structure\n\nBar: {{time}} | Close: {{close}}")

alertcondition(rawSignal,
     title   = "⏳ v3 Setup Bar — Awaiting 9 EMA Reclaim",
     message = "⏳ ⬆️ {{ticker}} — v3 VWAP Bounce Setup!\nHammer/Engulfing + Volume + RSI 40–45 + VWAP touch detected.\nWaiting for next candle to close above 9 EMA.\nBar: {{time}} | Close: {{close}}")

alertcondition(isHammer and rawSignal,
     title   = "🔨 v3 Hammer at VWAP",
     message = "🔨 {{ticker}} — Hammer candle at VWAP with all v3 conditions met.\nBar: {{time}} | Close: {{close}}")

alertcondition(isBullEngulf and rawSignal,
     title   = "🕯 v3 Bullish Engulfing at VWAP",
     message = "🕯 {{ticker}} — Bullish Engulfing at VWAP with all v3 conditions met.\nBar: {{time}} | Close: {{close}}")
````
