# Delta Pressure

- url: https://www.tradingview.com/script/T9EGynwU-Delta-Pressure/
- type: indicator
- pine_id: PUB;5efc4e0176f54b4e8f5bb7e690210daf
- version: 1.0

## Description

[b]Delta Pressure[/b]

A clean read on whether recent bars were bought or sold, with higher-timeframe context.


[b]What it does[/b]

Each bar produces a pressure value from where it closed relative to where it opened, weighted by that bar's volume. The line is the volume-weighted average of the last N bars, so heavy bars count more than thin ones. The result is bounded between −1 and +1 and oscillates naturally around zero — no cumulation, no drift, no anchor.

Above zero, buyers controlled the recent tape. Below zero, sellers did. The dotted guides at ±0.25 mark where readings become one-sided enough to be worth noting.


[b]Higher timeframe[/b]

An optional shaded layer shows the same calculation from a higher timeframe behind the main line. When both sit on the same side of zero, pressure agrees across timeframes. When they split, your chart timeframe is fighting the larger one. The HTF layer updates only on confirmed bars by default, so it steps rather than repainting — you can switch that off for a smoother look if you prefer live values.


[b]Settings worth knowing[/b]

[b]Method[/b] — Body compares close to open and ignores wicks. Close Position measures where the close sits within the full range.
 
Body tends to read cleaner on futures, since a long rejection wick shouldn't count as participation.

[b]Length[/b] — bars averaged. Shorter reacts faster and noisier.

[b]Timeframe[/b] — on a 5-minute chart, 15 or 30 works well.

[b]Style[/b] — line, histogram, or both.

[b]What it is not[/b]

This is a proxy, not true order-flow delta. Real delta requires tick-by-tick bid/ask data that Pine cannot access. Where a bar closes is a reasonable stand-in for who won it, but it will misread gap bars and very thin bars. Treat it as a pressure estimate.

There are no buy or sell signals here, deliberately. It's a context tool — meant to sit under whatever setup you already trade and tell you whether participation is backing the move.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CraftyPicks

//@version=6
indicator("Delta Pressure", shorttitle="DELTA", overlay=false)

// ═══════════════════════════════════════════════════
//  Per-bar buying/selling pressure, volume-weighted
//  and averaged over N bars. Bounded -1 to +1.
//
//  Above 0 = buyers controlled the recent bars.
//  Optional higher-timeframe line for context.
// ═══════════════════════════════════════════════════

gD      = "━━━━  Delta  ━━━━"
method  = input.string("Body", "Method",
     options=["Close Position","Body"], group=gD,
     tooltip="Close Position: where the close sits between high and low. Body: close vs open.")
len     = input.int(21, "Length", group=gD, minval=2, maxval=200)
smooth  = input.int(3, "Extra Smoothing", group=gD, minval=1, maxval=20)
smType  = input.string("EMA", "Smoothing Type", options=["EMA","SMA","WMA","HMA"], group=gD)

gH      = "━━━━  Higher Timeframe  ━━━━"
useHTF  = input.bool(true, "Show HTF Pressure", group=gH)
htf     = input.timeframe("15", "Timeframe", group=gH,
     tooltip="Blank = match the chart. On a 5m chart try 15 or 30.")
htfLen  = input.int(21, "HTF Length", group=gH, minval=2, maxval=200)
htfSm   = input.int(3, "HTF Smoothing", group=gH, minval=1, maxval=20)
htfConf = input.bool(true, "Use Confirmed HTF Bars Only", group=gH,
     tooltip="On: updates only when the HTF bar closes — no repainting, but it steps. Off: live and smooth, but the current value can change until that bar completes.")
htfFill = input.bool(true, "Shade HTF Instead Of Line", group=gH)

gV       = "━━━━  Display  ━━━━"
style    = input.string("Line", "Style", options=["Line","Histogram","Both"], group=gV)
showBands= input.bool(true, "Show ±0.25 Guides", group=gV)

gC      = "━━━━  Colors  ━━━━"
upCol   = input.color(#089981, "Buying", group=gC)
dnCol   = input.color(#F23645, "Selling", group=gC)
htfUp   = input.color(color.new(#089981, 55), "HTF Buying", group=gC)
htfDn   = input.color(color.new(#F23645, 55), "HTF Selling", group=gC)
zeroCol = input.color(color.new(#787B86, 30), "Zero Line", group=gC)
bandCol = input.color(color.new(#787B86, 70), "Guides", group=gC)

// ─── PRESSURE ───
sm(float s, int l, string t) =>
    float r = l <= 1 ? s :
         t == "SMA" ? ta.sma(s, l) :
         t == "WMA" ? ta.wma(s, l) :
         t == "HMA" ? ta.hma(s, l) : ta.ema(s, l)
    r

pressure(int n, int s) =>
    float rng = high - low
    float pos = rng > 0 ?
         (method == "Body" ? (close - open) / rng : (2 * (close - low) / rng - 1)) : 0.0
    float vS  = math.sum(volume, n)
    float raw = vS > 0 ? math.sum(volume * pos, n) / vS : 0.0
    sm(raw, s, smType)

delta = pressure(len, smooth)

// ─── HTF ───
htfRaw = request.security(syminfo.tickerid, htf, pressure(htfLen, htfSm),
     lookahead = barmerge.lookahead_off)
htfCnf = request.security(syminfo.tickerid, htf, pressure(htfLen, htfSm)[1],
     lookahead = barmerge.lookahead_off)
htfVal = useHTF ? (htfConf ? htfCnf : htfRaw) : na

// ─── PLOT ───
col    = delta  >= 0 ? upCol : dnCol
colHTF = htfVal >= 0 ? htfUp : htfDn

zeroP = plot(0, "", color.new(color.gray, 100), display=display.none)

htfP = plot(useHTF ? htfVal : na, "HTF Pressure",
     htfFill ? color.new(colHTF, 100) : colHTF, 2)
fill(htfP, zeroP, useHTF and htfFill ? color.new(colHTF, 80) : na)

lineP = plot(style != "Histogram" ? delta : na, "Pressure", col, 2)
fill(lineP, zeroP, color.new(col, 88))

plot(style != "Line" ? delta : na, "Histogram", color.new(col, 40),
     style = plot.style_columns)

hline(0, "Zero", zeroCol, hline.style_solid, 1)
hline(showBands ?  0.25 : na, "Upper", bandCol, hline.style_dotted)
hline(showBands ? -0.25 : na, "Lower", bandCol, hline.style_dotted)
````
