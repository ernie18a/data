# SWIM_LANES_RD

- url: https://www.tradingview.com/script/KSSTeaoY-SWIM-LANES-RD/
- type: indicator
- pine_id: PUB;beeef71a90a44205a64b962aed8fcf1e
- version: 2.0

## Description

[b]SUPPORT_RESISTANCE_RD[/b]
A multi-timeframe support and resistance indicator for TradingView that overlays three pairs of horizontal lines on your chart, marking key price levels from different lookback windows. Each line is anchored to the previous completed daily bar's value, so levels stay stable intraday and only update when a new session closes.

[b]What it draws[/b]
The indicator plots six horizontal lines across the full chart width, organized into three pairs:
Long-term levels (default: 20 days) — the highest high and lowest low over the past 20 completed daily bars. These are your major swing support and resistance zones.
Short-term levels (default: 5 days) — the highest high and lowest low over the past 5 completed daily bars. These represent the recent trading range.
Yesterday levels (1 day) — the prior day's high and low. The classic pivot reference for intraday traders.
Each line extends infinitely in both directions across the chart. Highs are colored orange, lows are colored purple, with transparency varying by timeframe so longer lookbacks recede visually behind shorter, more recent levels.
Day tags
Each line is labeled at the right edge of the visible chart with a tag identifying how many days back it references:

-20d for the long lookback high and low
-5d for the short lookback high and low
-1d for yesterday's high and low

Tags on the highs sit above the line with a small tail pointing down to it. Tags on the lows sit below the line with a tail pointing up. Tag background colors match their corresponding line, so identification is immediate even when several levels stack close together.

[b]How the values are calculated[/b]
All price values come from the daily timeframe via request.security, regardless of what chart timeframe you're viewing. On a daily chart, the script reads the previous bar's values ([1]) so today's in-progress bar doesn't contaminate the levels. On intraday charts, it reads the most recent completed daily values directly. This means the lines remain frozen throughout the trading session and only refresh when a new daily bar closes — exactly the behavior you want for stable reference levels.
Lookahead is disabled (lookahead_off) to prevent any forward-bias on historical bars, so backtests and replays reflect what was actually knowable in real time.

[b]Configurable inputs[/b]
Lookback windows — independent integer inputs for the short and long lookbacks, defaulting to 5 and 20 days.
Per-pair styling — each of the three pairs (long, short, yesterday) has its own color picker for highs and lows, line width (1–10), and line style (solid, dashed, or dotted). Defaults are solid for long, dashed for short, dotted for yesterday — a visual hierarchy that mirrors their significance.
Label controls — a toggle to show or hide all day tags, an offset slider (1–200 bars, default 20) controlling how far right of the current bar the tags float, and a text color picker for the tag text.

[b]Technical notes[/b]
The script uses Pine Script v6. Lines and labels are created once on the first bar (barstate.isfirst) and then updated in place on every subsequent bar rather than redrawn, which keeps object count minimal and rendering performant. All styling properties are re-applied on each update so input changes take effect immediately without requiring a script reload.
The label offset is measured in bars, not pixels — Pine has no direct pixel addressing — so the visual distance of tags from the current bar will scale with your chart zoom level. Adjust the offset input if the tags drift too far from or too close to your price action.
Intended use
This indicator is designed for traders who key off prior-period extremes: range traders watching for breakouts of recent highs and lows, swing traders using multi-week levels as zones of interest, and day traders anchoring intraday decisions to yesterday's range. The three timeframes layered together give a quick read on where price sits within the broader structure without cluttering the chart with manual horizontal lines.

## Source Code

````pine
//@version=6
indicator("SUPPORT_RESISTANCE_RD", overlay=true)

// Lookback inputs
shortLookback = input.int(5,  title="Short Lookback (days)")
longLookback  = input.int(20, title="Long Lookback (days)")

// --- Long line inputs ---
longHighColor  = input.color(color.new(#E85400, 60), title="Long High Color")
longLowColor   = input.color(color.new(#9B30C8, 60), title="Long Low Color")
longWidth      = input.int(2, title="Long Line Width", minval=1, maxval=10)
longStyle      = input.string("Solid",  title="Long Line Style",  options=["Solid", "Dashed", "Dotted"])

// --- Short line inputs ---
shortHighColor = input.color(color.new(#E85400, 30), title="Short High Color")
shortLowColor  = input.color(color.new(#9B30C8, 30), title="Short Low Color")
shortWidth     = input.int(2, title="Short Line Width", minval=1, maxval=10)
shortStyle     = input.string("Dashed", title="Short Line Style", options=["Solid", "Dashed", "Dotted"])

// --- Yesterday line inputs ---
yesterdayHighColor = input.color(color.new(#E85400, 0), title="Yesterday High Color")
yesterdayLowColor  = input.color(color.new(#9B30C8, 0), title="Yesterday Low Color")
yesterdayWidth     = input.int(2, title="Yesterday Line Width", minval=1, maxval=10)
yesterdayStyle     = input.string("Dotted", title="Yesterday Line Style", options=["Solid", "Dashed", "Dotted"])

// --- Label inputs ---
showLabels    = input.bool(true, title="Show Day Tags")
labelOffset   = input.int(20, title="Label Offset (bars)", minval=1, maxval=200)
labelTextCol  = input.color(color.white, title="Label Text Color")

// --- Collision inputs ---
overlapPct    = input.float(0.5, title="Overlap Threshold (% of price)", minval=0.01, step=0.1) / 100
pushBars      = input.int(15, title="Collision Push Distance (bars)", minval=1, maxval=100)

// Helper to convert string -> line style
toLineStyle(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

// Raw daily values
dHigh_raw     = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_off)
dLow_raw      = request.security(syminfo.tickerid, "D", low,  barmerge.gaps_off, barmerge.lookahead_off)
highShort_raw = request.security(syminfo.tickerid, "D", ta.highest(high, shortLookback), barmerge.gaps_off, barmerge.lookahead_off)
lowShort_raw  = request.security(syminfo.tickerid, "D", ta.lowest(low,   shortLookback), barmerge.gaps_off, barmerge.lookahead_off)
highLong_raw  = request.security(syminfo.tickerid, "D", ta.highest(high, longLookback),  barmerge.gaps_off, barmerge.lookahead_off)
lowLong_raw   = request.security(syminfo.tickerid, "D", ta.lowest(low,   longLookback),  barmerge.gaps_off, barmerge.lookahead_off)

isDailyChart = timeframe.isdaily

yHigh        = isDailyChart ? dHigh_raw[1]     : dHigh_raw
yLow         = isDailyChart ? dLow_raw[1]      : dLow_raw
dayHighShort = isDailyChart ? highShort_raw[1] : highShort_raw
dayLowShort  = isDailyChart ? lowShort_raw[1]  : lowShort_raw
dayHighLong  = isDailyChart ? highLong_raw[1]  : highLong_raw
dayLowLong   = isDailyChart ? lowLong_raw[1]   : lowLong_raw

// --- Compute per-tag x-offsets based on price proximity ---
// Priority: -1d stays at base, -5d pushes if near -1d, -20d pushes for each shorter tag it's near
priceThreshold = close * overlapPct

// Highs
topOffset_1d  = labelOffset
topOffset_5d  = labelOffset + (math.abs(yHigh        - dayHighShort) < priceThreshold ? pushBars : 0)
topOffset_20d = labelOffset + (math.abs(yHigh        - dayHighLong)  < priceThreshold ? pushBars : 0) + (math.abs(dayHighShort - dayHighLong)  < priceThreshold ? pushBars : 0)

// Lows
botOffset_1d  = labelOffset
botOffset_5d  = labelOffset + (math.abs(yLow         - dayLowShort)  < priceThreshold ? pushBars : 0)
botOffset_20d = labelOffset + (math.abs(yLow         - dayLowLong)   < priceThreshold ? pushBars : 0) + (math.abs(dayLowShort  - dayLowLong)   < priceThreshold ? pushBars : 0)

// Lines
var line topLineLong  = na
var line botLineLong  = na
var line topLineShort = na
var line botLineShort = na
var line topLineY     = na
var line botLineY     = na

// Labels
var label lblTopLong  = na
var label lblBotLong  = na
var label lblTopShort = na
var label lblBotShort = na
var label lblTopY     = na
var label lblBotY     = na

longTag  = "-" + str.tostring(longLookback)  + "d"
shortTag = "-" + str.tostring(shortLookback) + "d"
yTag     = "-1d"

if barstate.isfirst
    topLineLong  := line.new(bar_index, dayHighLong,  bar_index + 1, dayHighLong,  extend=extend.both, color=longHighColor,      width=longWidth,      style=toLineStyle(longStyle))
    botLineLong  := line.new(bar_index, dayLowLong,   bar_index + 1, dayLowLong,   extend=extend.both, color=longLowColor,       width=longWidth,      style=toLineStyle(longStyle))
    topLineShort := line.new(bar_index, dayHighShort, bar_index + 1, dayHighShort, extend=extend.both, color=shortHighColor,     width=shortWidth,     style=toLineStyle(shortStyle))
    botLineShort := line.new(bar_index, dayLowShort,  bar_index + 1, dayLowShort,  extend=extend.both, color=shortLowColor,      width=shortWidth,     style=toLineStyle(shortStyle))
    topLineY     := line.new(bar_index, yHigh,        bar_index + 1, yHigh,        extend=extend.both, color=yesterdayHighColor, width=yesterdayWidth, style=toLineStyle(yesterdayStyle))
    botLineY     := line.new(bar_index, yLow,         bar_index + 1, yLow,         extend=extend.both, color=yesterdayLowColor,  width=yesterdayWidth, style=toLineStyle(yesterdayStyle))

    // Highs: label sits ABOVE the line with tail pointing DOWN to the line
    lblTopLong  := label.new(bar_index + topOffset_20d, dayHighLong,  text=longTag,  color=longHighColor,      textcolor=labelTextCol, style=label.style_label_down, size=size.small)
    lblTopShort := label.new(bar_index + topOffset_5d,  dayHighShort, text=shortTag, color=shortHighColor,     textcolor=labelTextCol, style=label.style_label_down, size=size.small)
    lblTopY     := label.new(bar_index + topOffset_1d,  yHigh,        text=yTag,     color=yesterdayHighColor, textcolor=labelTextCol, style=label.style_label_down, size=size.small)

    // Lows: label sits BELOW the line with tail pointing UP to the line
    lblBotLong  := label.new(bar_index + botOffset_20d, dayLowLong,   text=longTag,  color=longLowColor,       textcolor=labelTextCol, style=label.style_label_up,   size=size.small)
    lblBotShort := label.new(bar_index + botOffset_5d,  dayLowShort,  text=shortTag, color=shortLowColor,      textcolor=labelTextCol, style=label.style_label_up,   size=size.small)
    lblBotY     := label.new(bar_index + botOffset_1d,  yLow,         text=yTag,     color=yesterdayLowColor,  textcolor=labelTextCol, style=label.style_label_up,   size=size.small)
else
    line.set_xy1(topLineLong,  bar_index, dayHighLong)
    line.set_xy2(topLineLong,  bar_index + 1, dayHighLong)
    line.set_xy1(botLineLong,  bar_index, dayLowLong)
    line.set_xy2(botLineLong,  bar_index + 1, dayLowLong)

    line.set_xy1(topLineShort, bar_index, dayHighShort)
    line.set_xy2(topLineShort, bar_index + 1, dayHighShort)
    line.set_xy1(botLineShort, bar_index, dayLowShort)
    line.set_xy2(botLineShort, bar_index + 1, dayLowShort)

    line.set_xy1(topLineY,     bar_index, yHigh)
    line.set_xy2(topLineY,     bar_index + 1, yHigh)
    line.set_xy1(botLineY,     bar_index, yLow)
    line.set_xy2(botLineY,     bar_index + 1, yLow)

    line.set_color(topLineLong,  longHighColor)
    line.set_color(botLineLong,  longLowColor)
    line.set_color(topLineShort, shortHighColor)
    line.set_color(botLineShort, shortLowColor)
    line.set_color(topLineY,     yesterdayHighColor)
    line.set_color(botLineY,     yesterdayLowColor)

    line.set_width(topLineLong,  longWidth)
    line.set_width(botLineLong,  longWidth)
    line.set_width(topLineShort, shortWidth)
    line.set_width(botLineShort, shortWidth)
    line.set_width(topLineY,     yesterdayWidth)
    line.set_width(botLineY,     yesterdayWidth)

    line.set_style(topLineLong,  toLineStyle(longStyle))
    line.set_style(botLineLong,  toLineStyle(longStyle))
    line.set_style(topLineShort, toLineStyle(shortStyle))
    line.set_style(botLineShort, toLineStyle(shortStyle))
    line.set_style(topLineY,     toLineStyle(yesterdayStyle))
    line.set_style(botLineY,     toLineStyle(yesterdayStyle))

    // Update label positions with collision-aware offsets
    label.set_xy(lblTopLong,  bar_index + topOffset_20d, dayHighLong)
    label.set_xy(lblBotLong,  bar_index + botOffset_20d, dayLowLong)
    label.set_xy(lblTopShort, bar_index + topOffset_5d,  dayHighShort)
    label.set_xy(lblBotShort, bar_index + botOffset_5d,  dayLowShort)
    label.set_xy(lblTopY,     bar_index + topOffset_1d,  yHigh)
    label.set_xy(lblBotY,     bar_index + botOffset_1d,  yLow)

    label.set_color(lblTopLong,  longHighColor)
    label.set_color(lblBotLong,  longLowColor)
    label.set_color(lblTopShort, shortHighColor)
    label.set_color(lblBotShort, shortLowColor)
    label.set_color(lblTopY,     yesterdayHighColor)
    label.set_color(lblBotY,     yesterdayLowColor)

    label.set_textcolor(lblTopLong,  labelTextCol)
    label.set_textcolor(lblBotLong,  labelTextCol)
    label.set_textcolor(lblTopShort, labelTextCol)
    label.set_textcolor(lblBotShort, labelTextCol)
    label.set_textcolor(lblTopY,     labelTextCol)
    label.set_textcolor(lblBotY,     labelTextCol)

    // Toggle visibility
    label.set_text(lblTopLong,  showLabels ? longTag  : "")
    label.set_text(lblBotLong,  showLabels ? longTag  : "")
    label.set_text(lblTopShort, showLabels ? shortTag : "")
    label.set_text(lblBotShort, showLabels ? shortTag : "")
    label.set_text(lblTopY,     showLabels ? yTag     : "")
    label.set_text(lblBotY,     showLabels ? yTag     : "")
````
