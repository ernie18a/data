<!-- tradingview-pine-id: PUB;726f036ff30348409af026956ea5b337 -->
<!-- tradingviewscripts-format: 1 -->
# [SkuldX] Swing Failure Pattern

Source: https://www.tradingview.com/script/eB3dChAT-SkuldX-SFP-Swing-Failure-Pattern/

## Description

SkuldX Swing Failure Pattern — Institutional Liquidity Sweep Detector
by SkuldX Trading Systems

What is it?
SkuldX Swing Failure Pattern automatically detects one of the most powerful reversal setups in Smart Money and ICT trading. The Swing Failure Pattern occurs when price sweeps beyond a key swing level — triggering stop-loss orders clustered there — but then closes back within the previous range. This signals that institutional participants have absorbed the available liquidity and are now positioning in the opposite direction.
Unlike random false breakouts, the SFP has a precise structure: a meaningful wick beyond a swing high or low, a close that returns inside the range, and a visible rejection zone where the liquidity grab occurred. SkuldX SFP identifies all three automatically and displays them directly on the chart.

The mechanics
Every swing high and swing low acts as a magnet for stop-loss orders. Retail traders who are long place their stops just below swing lows. Retail traders who are short place their stops just above swing highs. Institutional participants know exactly where this liquidity sits.
An SFP forms when price is deliberately pushed beyond one of these levels to trigger those orders — collecting the liquidity — and then immediately reverses. The result is a candle with a long wick beyond the level and a close that returns inside the prior range. This is not a random failure. It is a deliberate liquidity grab followed by institutional repositioning in the opposite direction.

Two pattern types
🔴 Bearish SFP — price sweeps above a previous swing high with a wick but closes below it. The failed attempt to break higher signals that sellers have absorbed the bullish liquidity and are now in control. Expect a move downward.
🟢 Bullish SFP — price sweeps below a previous swing low with a wick but closes above it. The failed breakdown signals that buyers have absorbed the bearish liquidity and are now driving price higher.

What you see on the chart
Each detected SFP displays three visual elements simultaneously:
Label — appears above or below the candle with the signal direction and the exact price of the swept level. Instantly identifies the pattern without manual analysis.
Dashed line — marks the swing level that was breached. Extends from the beginning of the lookback window to the right, showing which structural level triggered the sweep. This level often acts as support or resistance in subsequent price action.
Rejection zone (box) — shaded area between the wick extreme and the swept level. This is the liquidity grab zone — the price range where stop orders were triggered and institutional positions were built. The size of this zone reflects how aggressively price was pushed beyond the level before reversing.

Quality filters
Two independent filters prevent low-quality signals from appearing on the chart.
Min Wick Size % of candle — requires the rejection wick to be at least a specified percentage of the total candle range. A small wick relative to the candle body suggests weak rejection. Default 0.5%. Increase to 2–3% on noisy instruments to require a more decisive rejection.
Min Breach Size % of level — requires the wick to extend at least a specified percentage beyond the swing level. A sweep that barely ticks beyond the level carries less significance than one that pushes meaningfully through it. Default 0.05%. Increase to 0.1–0.2% for stricter confirmation.
Both filters can be set to zero to show all detected patterns without filtering.

Settings reference
Swing Lookback (bars) — defines how many bars back to search for the swing high or low that gets swept. Default 10. Lower values find more local patterns, higher values require more significant swing levels. On 15m charts, 10 bars covers approximately 2.5 hours of price history.
Min Wick Size % of candle — minimum upper or lower wick as a percentage of the total candle range
Min Breach Size % of level — minimum distance the wick must extend beyond the swing level
Show Bullish / Bearish SFP — independent toggles for each direction
Show Labels — toggles the signal label above or below the candle
Show Level Line — toggles the dashed line at the swept swing level
Show Rejection Zone — toggles the shaded box between the wick and the level
Zone Extend — how many bars to the right the zone and line extend
Label Size — tiny, small, or normal
Bullish / Bearish Color — independent color control for each direction
Zone Transparency — opacity of the rejection zone fill
Line Width — thickness of the swept level line

Data Window
Hovering over any bar shows binary flags for Bullish SFP and Bearish SFP detection, the current swing high and swing low values used as reference levels, the upper and lower wick percentages, and the breach percentage of the swept level. These values are useful for calibrating the quality filters to your specific instrument and timeframe.

How to use it in practice
Entry timing — the SFP signal fires on the bar where the rejection occurs. The most aggressive entry is at the close of that candle. A more conservative approach is to wait for the next candle to confirm continuation in the reversal direction before entering.
Stop placement — place the stop-loss beyond the wick extreme, outside the rejection zone. The wick tip represents the furthest point of institutional manipulation — price returning beyond it invalidates the pattern.
Take-profit targets — common targets are the opposite swing extreme, a session High or Low from the current day, or the next significant structural level. The swept swing level itself often acts as resistance or support on the retest.
Timeframe selection — SFP signals are most reliable on 15m and above. On very low timeframes the pattern appears frequently but with lower conviction. On 1h and 4h the signals are rarer but carry significantly more institutional weight.
Confluence — the highest-probability SFP setups occur when the swept level coincides with a session boundary. A bearish SFP that sweeps the Asian High during London session is a classic institutional liquidity grab setup. A bullish SFP at Asian Low during the NY Overlap is one of the strongest intraday reversal signals available.
Volume context — a sweep accompanied by above-average volume confirms institutional participation. A low-volume sweep may indicate a thin market move rather than a deliberate liquidity grab.

Common mistakes to avoid
Entering immediately on the wick without waiting for the candle to close. The pattern is only valid after the close confirms the rejection — a candle that is still forming may yet close beyond the level as a genuine breakout.
Trading every SFP signal regardless of context. The pattern is significantly more reliable when it sweeps a level that has been respected multiple times previously, when it occurs during a high-liquidity session window, and when it aligns with the broader directional bias.
Using too small a lookback. A swing high from 3 bars ago carries far less liquidity than one from 10–15 bars ago. Increase the lookback if signals feel too frequent or structurally insignificant.

Built for SkuldX ecosystem
SkuldX Swing Failure Pattern is designed to work alongside the full SkuldX indicator suite. The most reliable SFP setups emerge when multiple layers of context align simultaneously:

[*]A bullish SFP at the Asian Low after the Asian session closes — detected by SkuldX Trading Sessions — suggests institutional accumulation before London or NY drives price higher
[*]A bearish SFP at the Asian High during London session with ADR Used % above 80% — from SkuldX ADR Levels — indicates both a liquidity sweep and statistical range exhaustion at the same level
[*]An SFP confirmed by a Bullish Trend or Bearish Trend reading in SkuldX OI Delta adds institutional conviction — new positions opening in the reversal direction confirm the sweep was not random
[*]An SFP that forms at a level already flagged by SkuldX Level Patterns as a multi-touch support or resistance zone carries significantly more weight than one at a fresh untested level
[*]Each indicator in the suite adds an independent dimension of confirmation. Using them together reduces noise and improves the quality of setups without adding complexity to the decision process.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] Swing Failure Pattern", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

swingLookback   = input.int(10,    "Swing Lookback (bars)",        group = "Detection",  minval = 3,   maxval = 50)
minWickPct      = input.float(0.5, "Min Wick Size % of candle",    group = "Filters",    minval = 0.0, maxval = 10.0, step = 0.1)
minBreachPct    = input.float(0.05,"Min Breach Size % of level",   group = "Filters",    minval = 0.0, maxval = 1.0,  step = 0.01)

showBullish     = input.bool(true,  "Show Bullish SFP",            group = "Signals")
showBearish     = input.bool(true,  "Show Bearish SFP",            group = "Signals")
showLabel       = input.bool(true,  "Show Labels",                 group = "Signals")
showLine        = input.bool(true,  "Show Level Line",             group = "Signals")
showZone        = input.bool(true,  "Show Rejection Zone (box)",   group = "Signals")
zoneExtend      = input.int(8,      "Zone Extend (bars right)",    group = "Signals",    minval = 1, maxval = 50)
labelSize       = input.string("small", "Label Size",              group = "Signals",    options = ["tiny", "small", "normal"])

colorBull       = input.color(color.new(color.green,  0),  "Bullish Color", group = "Colors")
colorBear       = input.color(color.new(color.red,    0),  "Bearish Color", group = "Colors")
zoneAlpha       = input.int(80,     "Zone Transparency",           group = "Colors",     minval = 50, maxval = 99)
lineWidth       = input.int(1,      "Line Width",                  group = "Colors",     minval = 1, maxval = 4)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

szVal() =>
    switch labelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small

// Previous swing high — highest high over last N bars (excluding current)
prevSwingHigh() =>
    ta.highest(high, swingLookback)[1]

// Previous swing low — lowest low over last N bars (excluding current)
prevSwingLow() =>
    ta.lowest(low, swingLookback)[1]

// Wick size as % of total candle range
upperWickPct() =>
    totalRange = high - low
    totalRange > 0 ? (high - math.max(open, close)) / totalRange * 100 : 0.0

lowerWickPct() =>
    totalRange = high - low
    totalRange > 0 ? (math.min(open, close) - low) / totalRange * 100 : 0.0

// Breach size as % of the broken level
breachPctHigh(float level) =>
    level > 0 ? (high - level) / level * 100 : 0.0

breachPctLow(float level) =>
    level > 0 ? (level - low) / level * 100 : 0.0


// ══════════════════════════════════════════════════════
// SFP DETECTION
//
// Bearish SFP:
//   high > prevSwingHigh  → price sweeps above previous high
//   close < prevSwingHigh → candle closes back below the level
//   upper wick large enough → confirms rejection
//   breach large enough    → confirms meaningful sweep
//
// Bullish SFP:
//   low < prevSwingLow    → price sweeps below previous low
//   close > prevSwingLow  → candle closes back above the level
//   lower wick large enough
//   breach large enough
// ══════════════════════════════════════════════════════

float swingHigh = prevSwingHigh()
float swingLow  = prevSwingLow()

bool bearishSFP = showBearish and
     high > swingHigh and
     close < swingHigh and
     upperWickPct() >= minWickPct and
     breachPctHigh(swingHigh) >= minBreachPct

bool bullishSFP = showBullish and
     low < swingLow and
     close > swingLow and
     lowerWickPct() >= minWickPct and
     breachPctLow(swingLow) >= minBreachPct


// ══════════════════════════════════════════════════════
// VISUALIZATION
//
// On each SFP:
// 1. Label above/below candle with signal name
// 2. Horizontal line at the breached swing level
// 3. Box (rejection zone) between the wick extreme and the level
//    — shows the area of liquidity grab
//    — similar to FVG box style
// ══════════════════════════════════════════════════════

if bearishSFP
    // Label
    if showLabel
        label.new(
             x         = bar_index,
             y         = high,
             text      = "SFP ▼\n" + str.tostring(swingHigh, format.mintick),
             style     = label.style_label_down,
             color     = color.new(colorBear, 20),
             textcolor = color.white,
             size      = szVal())

    // Line at breached swing high
    if showLine
        line.new(
             x1    = bar_index - swingLookback,
             y1    = swingHigh,
             x2    = bar_index + zoneExtend,
             y2    = swingHigh,
             color = color.new(colorBear, 30),
             width = lineWidth,
             style = line.style_dashed)

    // Rejection zone: between high (wick tip) and swingHigh (level)
    // Shows the liquidity grab zone — price swept here and was rejected
    if showZone
        box.new(
             left         = bar_index,
             top          = high,
             right        = bar_index + zoneExtend,
             bottom       = swingHigh,
             bgcolor      = color.new(colorBear, zoneAlpha),
             border_color = color.new(colorBear, 40),
             border_width = 1,
             text         = "Rejection",
             text_color   = color.new(colorBear, 20),
             text_size    = size.tiny,
             text_halign  = text.align_right,
             text_valign  = text.align_top)

if bullishSFP
    // Label
    if showLabel
        label.new(
             x         = bar_index,
             y         = low,
             text      = "SFP ▲\n" + str.tostring(swingLow, format.mintick),
             style     = label.style_label_up,
             color     = color.new(colorBull, 20),
             textcolor = color.white,
             size      = szVal())

    // Line at breached swing low
    if showLine
        line.new(
             x1    = bar_index - swingLookback,
             y1    = swingLow,
             x2    = bar_index + zoneExtend,
             y2    = swingLow,
             color = color.new(colorBull, 30),
             width = lineWidth,
             style = line.style_dashed)

    // Rejection zone: between swingLow (level) and low (wick tip)
    if showZone
        box.new(
             left         = bar_index,
             top          = swingLow,
             right        = bar_index + zoneExtend,
             bottom       = low,
             bgcolor      = color.new(colorBull, zoneAlpha),
             border_color = color.new(colorBull, 40),
             border_width = 1,
             text         = "Rejection",
             text_color   = color.new(colorBull, 20),
             text_size    = size.tiny,
             text_halign  = text.align_right,
             text_valign  = text.align_bottom)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(bearishSFP ? 1.0 : 0.0,  "Bearish SFP",   color = color.new(color.red,   100), display = display.data_window)
plot(bullishSFP ? 1.0 : 0.0,  "Bullish SFP",   color = color.new(color.green, 100), display = display.data_window)
plot(swingHigh,                "Swing High",    color = color.new(color.red,   100), display = display.data_window)
plot(swingLow,                 "Swing Low",     color = color.new(color.green, 100), display = display.data_window)
plot(upperWickPct(),           "Upper Wick %",  color = color.new(color.gray,  100), display = display.data_window)
plot(lowerWickPct(),           "Lower Wick %",  color = color.new(color.gray,  100), display = display.data_window)
plot(bearishSFP ? breachPctHigh(swingHigh) : na, "Breach %", color = color.new(color.gray, 100), display = display.data_window)
plot(bullishSFP ? breachPctLow(swingLow)   : na, "Breach %", color = color.new(color.gray, 100), display = display.data_window)
````
