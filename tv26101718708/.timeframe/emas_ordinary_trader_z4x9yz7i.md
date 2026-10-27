# EMA's [Ordinary Trader]

- url: https://www.tradingview.com/script/z4X9yz7I-EMA-s-Ordinary-Trader/
- type: indicator
- pine_id: PUB;b0aa0e9b432b439095db66f6b5aff0e3
- version: 1.0

## Description

EMAs by [Ordinary Trader]Plots two parallel stacks of three EMAs — one anchored to a Higher Timeframe of your choice, one following the chart's current timeframe. Built around the Ordinary Trader methodology, where the 15-minute 50 / 100 / 300 EMA stack acts as a higher-timeframe directional filter while trading on lower timeframes.

**WHAT YOU SEE ON THE CHART**

Six EMAs total, split into two groups:

- **HTF EMAs** — three EMAs locked to a higher timeframe of your choice (default 15-minute). They stay anchored to 15-minute data even when you drop the chart to 1m, 3m, or 5m. Drawn as **thick** lines.
- **LTF EMAs** — three EMAs that follow the chart's current timeframe (or any specific lower timeframe you pin them to). Drawn as **thin** lines.

Same colour for the same EMA length across both groups: 50 = sage green, 100 = terracotta orange, 300 = purple-grey. Thickness tells you which timeframe you're looking at; colour tells you which EMA length.

**HOW TO USE IT**

The default setup is the Ordinary Trader 15-minute filter: HTF set to 15-minute, LTF following the chart. Pull up a 1m, 3m, or 5m chart and you'll see both groups at once — the thick lines are your 15-minute anchor, the thin lines are your chart-timeframe stack for entries.

By default the 50 and 100 EMAs are on in both groups; the 300 EMA is off but available. Flip it on in the Settings panel if you want the full stack.

**AUTO-HIDE FOR THE LTF GROUP**

When your chart timeframe is equal to or higher than the HTF timeframe, the LTF group hides automatically. So on a 15-minute chart (with HTF still at 15-minute) only the HTF group shows — no point drawing the LTF stack on top of an identical HTF stack. Same on the 1-hour, daily, or higher.

**VISUAL SMOOTHING**

When a higher-timeframe EMA is plotted on a lower-timeframe chart, it naturally looks stepped — each new HTF bar updates the EMA in one chunk, so the line moves in jumps rather than smoothly. The Visual Smoothing option (on by default) applies a light smoothing pass so the line reads cleanly on lower-timeframe charts. It trades a tiny amount of lag for a cleaner look — turn it off if you'd rather see the raw, stepped HTF values.

**SETTINGS**

- **General** — LTF Timeframe, HTF Timeframe, Plot Style (Line / Stepline), Visual Smoothing on/off + length
- **HTF EMAs** — toggle, length, and price source for each of the three HTF EMAs
- **LTF EMAs** — toggle, length, and price source for each of the three LTF EMAs

**NOTES**
- Pairs naturally with the other Ordinary Trader-family indicators (STRATEGY, ZONES, KEY LEVELS, FVGs).

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// EMA's [Ordinary Trader] v2.0.0
// See CHANGELOG.md for full version history.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("EMA's [Ordinary Trader] v2.0.0",
     shorttitle = "EMA's [Ordinary Trader]",
     overlay    = true)

// ─── INPUTS — GENERAL ─────────────────────────────────────────────────────────

var string GRP0 = "General"

ltfTf = input.timeframe(
     "",
     "LTF Timeframe",
     group=GRP0,
     display=display.data_window,
     tooltip="Lower timeframe for the LTF EMA group. Leave blank to follow the current chart timeframe. The LTF group is automatically hidden when the chart timeframe is equal to or higher than the HTF timeframe."
)

htfTf = input.timeframe(
     "15",
     "HTF Timeframe",
     group=GRP0,
     display=display.data_window,
     tooltip="Higher timeframe for the HTF EMA group. The HTF EMAs follow this timeframe regardless of the chart timeframe — e.g. set to 15 to see the 15-minute EMAs on a 1-minute chart."
)

plotStyle = input.string(
     "Line",
     "Plot Style",
     options=["Line", "Stepline"],
     group=GRP0,
     display=display.data_window,
     tooltip="Line gives a smoother look. Stepline shows the higher timeframe levels in a more stepped way."
)

smoothOn = input.bool(
     true,
     "Visual Smoothing",
     group=GRP0,
     tooltip="Turns on extra smoothing to make the EMA lines look cleaner on lower timeframes. This is mainly for appearance and adds a small amount of lag."
)

smoothLen = input.int(
     20,
     "Smoothing Length",
     group=GRP0,
     minval=1,
     display=display.data_window,
     tooltip="Higher numbers make the lines look cleaner and less jagged. Lower numbers keep them closer to the original EMA shape."
)

// ─── INPUTS — HTF EMAs ────────────────────────────────────────────────────────

var string GRP_HTF = "HTF EMAs"

htfEma1On  = input.bool(true,   "Show HTF EMA 1",   group=GRP_HTF, display=display.data_window, tooltip="Turn the HTF EMA 1 line on or off.")
htfEma1Len = input.int(50,      "HTF EMA 1 Length", group=GRP_HTF, minval=1, display=display.data_window, tooltip="Length of HTF EMA 1. Default is 50.")
htfEma1Src = input.source(close, "HTF EMA 1 Source", group=GRP_HTF, display=display.data_window, tooltip="Price source for HTF EMA 1. Close is the most common choice.")

htfEma2On  = input.bool(true,   "Show HTF EMA 2",   group=GRP_HTF, display=display.data_window, tooltip="Turn the HTF EMA 2 line on or off.")
htfEma2Len = input.int(100,     "HTF EMA 2 Length", group=GRP_HTF, minval=1, display=display.data_window, tooltip="Length of HTF EMA 2. Default is 100.")
htfEma2Src = input.source(close, "HTF EMA 2 Source", group=GRP_HTF, display=display.data_window, tooltip="Price source for HTF EMA 2. Close is the most common choice.")

htfEma3On  = input.bool(false,  "Show HTF EMA 3",   group=GRP_HTF, display=display.data_window, tooltip="Turn the HTF EMA 3 line on or off. Off by default.")
htfEma3Len = input.int(300,     "HTF EMA 3 Length", group=GRP_HTF, minval=1, display=display.data_window, tooltip="Length of HTF EMA 3. Default is 300.")
htfEma3Src = input.source(close, "HTF EMA 3 Source", group=GRP_HTF, display=display.data_window, tooltip="Price source for HTF EMA 3. Close is the most common choice.")

// ─── INPUTS — LTF EMAs ────────────────────────────────────────────────────────

var string GRP_LTF = "LTF EMAs"

ltfEma1On  = input.bool(true,   "Show LTF EMA 1",   group=GRP_LTF, display=display.data_window, tooltip="Turn the LTF EMA 1 line on or off.")
ltfEma1Len = input.int(50,      "LTF EMA 1 Length", group=GRP_LTF, minval=1, display=display.data_window, tooltip="Length of LTF EMA 1. Default is 50.")
ltfEma1Src = input.source(close, "LTF EMA 1 Source", group=GRP_LTF, display=display.data_window, tooltip="Price source for LTF EMA 1. Close is the most common choice.")

ltfEma2On  = input.bool(true,   "Show LTF EMA 2",   group=GRP_LTF, display=display.data_window, tooltip="Turn the LTF EMA 2 line on or off.")
ltfEma2Len = input.int(100,     "LTF EMA 2 Length", group=GRP_LTF, minval=1, display=display.data_window, tooltip="Length of LTF EMA 2. Default is 100.")
ltfEma2Src = input.source(close, "LTF EMA 2 Source", group=GRP_LTF, display=display.data_window, tooltip="Price source for LTF EMA 2. Close is the most common choice.")

ltfEma3On  = input.bool(false,  "Show LTF EMA 3",   group=GRP_LTF, display=display.data_window, tooltip="Turn the LTF EMA 3 line on or off. Off by default.")
ltfEma3Len = input.int(300,     "LTF EMA 3 Length", group=GRP_LTF, minval=1, display=display.data_window, tooltip="Length of LTF EMA 3. Default is 300.")
ltfEma3Src = input.source(close, "LTF EMA 3 Source", group=GRP_LTF, display=display.data_window, tooltip="Price source for LTF EMA 3. Close is the most common choice.")

// ─── TIMEFRAME RESOLUTION ─────────────────────────────────────────────────────

string ltfToUse = ltfTf == "" ? timeframe.period : ltfTf
string htfToUse = htfTf == "" ? timeframe.period : htfTf

// ─── AUTO-HIDE LTF GROUP ──────────────────────────────────────────────────────
// LTF group hides when the chart timeframe is equal to or higher than the HTF
// timeframe, to avoid duplicate stacks (chart=HTF) or inverted stacks (chart>HTF).

bool showLtf = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(htfToUse)

// ─── RAW MTF EMA VALUES ───────────────────────────────────────────────────────

htfEma1Raw = request.security(syminfo.tickerid, htfToUse, ta.ema(htfEma1Src, htfEma1Len))
htfEma2Raw = request.security(syminfo.tickerid, htfToUse, ta.ema(htfEma2Src, htfEma2Len))
htfEma3Raw = request.security(syminfo.tickerid, htfToUse, ta.ema(htfEma3Src, htfEma3Len))

ltfEma1Raw = request.security(syminfo.tickerid, ltfToUse, ta.ema(ltfEma1Src, ltfEma1Len))
ltfEma2Raw = request.security(syminfo.tickerid, ltfToUse, ta.ema(ltfEma2Src, ltfEma2Len))
ltfEma3Raw = request.security(syminfo.tickerid, ltfToUse, ta.ema(ltfEma3Src, ltfEma3Len))

// ─── OPTIONAL VISUAL SMOOTHING ────────────────────────────────────────────────

htfEma1Val = smoothOn ? ta.ema(htfEma1Raw, smoothLen) : htfEma1Raw
htfEma2Val = smoothOn ? ta.ema(htfEma2Raw, smoothLen) : htfEma2Raw
htfEma3Val = smoothOn ? ta.ema(htfEma3Raw, smoothLen) : htfEma3Raw

ltfEma1Val = smoothOn ? ta.ema(ltfEma1Raw, smoothLen) : ltfEma1Raw
ltfEma2Val = smoothOn ? ta.ema(ltfEma2Raw, smoothLen) : ltfEma2Raw
ltfEma3Val = smoothOn ? ta.ema(ltfEma3Raw, smoothLen) : ltfEma3Raw

// ─── PLOT STYLE ───────────────────────────────────────────────────────────────

plotStyleValue = plotStyle == "Stepline" ? plot.style_stepline : plot.style_line

// ─── PLOTS ────────────────────────────────────────────────────────────────────
// Shared colour per length: 50 = sage, 100 = terracotta, 300 = purple-grey.
// HTF lines linewidth 3 (anchor); LTF lines linewidth 1 (entry view).

plot(htfEma1On ? htfEma1Val : na, title="HTF EMA 1", color=color.new(#81b29a, 0), linewidth=3, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)
plot(htfEma2On ? htfEma2Val : na, title="HTF EMA 2", color=color.new(#e07a5f, 0), linewidth=3, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)
plot(htfEma3On ? htfEma3Val : na, title="HTF EMA 3", color=color.new(#6d6875, 0), linewidth=3, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)

plot(showLtf and ltfEma1On ? ltfEma1Val : na, title="LTF EMA 1", color=color.new(#81b29a, 0), linewidth=1, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)
plot(showLtf and ltfEma2On ? ltfEma2Val : na, title="LTF EMA 2", color=color.new(#e07a5f, 0), linewidth=1, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)
plot(showLtf and ltfEma3On ? ltfEma3Val : na, title="LTF EMA 3", color=color.new(#6d6875, 0), linewidth=1, style=plotStyleValue, display=display.all - display.price_scale - display.status_line)

// ─── WATERMARK ────────────────────────────────────────────────────────────────

if barstate.islast
    var table _wm = table.new(position.bottom_right, 1, 1)
    table.cell(_wm, 0, 0, "[ Ordinary Trader ]",
         text_color  = color.new(#2d3436, 0),
         text_size   = size.tiny,
         bgcolor     = color.new(color.white, 70),
         text_halign = text.align_right)
````
