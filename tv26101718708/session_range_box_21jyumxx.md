# Session Range Box

- url: https://www.tradingview.com/script/21jyUMxX-session-range-box/
- type: indicator
- pine_id: PUB;19cb37147c2645f6ae23250ddf34ae08
- version: 1.0

## Description

[b]Session Range Box[/b]

A universal tool that draws the range of a chosen session as a box. The trader
sets the conditions: the session, the timezone, and the window. The borders are
built from the session highs and lows - an area of potential liquidity, since
resting orders tend to build up above the highs and below the lows.

This is a tool, not a signal system. It gives a clean, non-repainting map of the
range. How to use it is up to the trader's own strategy.

[b]How It Works[/b]

1. Accumulation window. The trader sets the session time in their own timezone.
   The highest high and the lowest low inside this window become the box borders.
2. Freeze. Once the window closes, the borders are locked and never repaint.
   What you see on history is what actually happened at that moment.
3. Extend. The frozen box is stretched to the right until the end of the day, so
   you can watch price test the borders after the session. A new day starts a new box.

[b]What It Pairs With[/b]

Smart Money logic and the accumulation - manipulation - distribution model. The box
shows where potential liquidity sits; the trader applies their own scenario on top.

Applications

- Trading the Asian range
- Trading the European and US range
- First-hour range
- Mean reversion (from the box midline)

[b]Settings[/b]

- Timezone: city entries (which adjust automatically for daylight saving) or fixed
  UTC offsets (to match a broker's server time).
- Accumulation window: any length, from one hour to a full session.
- Extend box to end of day: on/off.
- Style: color, fill, borders, midline, label.

To show several sessions at once (Asia + Europe + US), add the indicator to the
chart more than once with different settings.

[b]Notes
[/b]
- Recommended timeframe: M1 to H1, depending on the strategy. 
- Time is based on the selected timezone; city entries adjust for daylight saving,
  fixed offsets do not.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KRISTRADER1

//@version=6
indicator("Session Range Box", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
// Session Range Box — a visualization tool.
//   1) ACCUMULATION WINDOW — the highest HIGH and the lowest LOW inside this
//      window become the box borders (shelves where liquidity builds up).
//      The window can be anything from one hour to a full session.
//   2) When the window closes the box FREEZES and is never repainted.
//   3) EXTEND — the frozen box is stretched to the right until the end of the
//      day (in the selected timezone), so you can watch price sweep the borders
//      or break out of the range against fixed shelves. Next day = new box.
//   Recommended timeframe M1–H1; lower timeframes give more precise window edges.
//   To show several sessions at once, add the indicator to the chart more than once.
// ============================================================================

// -------------------------------- TIME --------------------------------------
gT = "Time"
tzChoice = input.string("Moscow (UTC+3)", "Timezone", group = gT,
     tooltip = "City entries use that location's local time and adjust automatically for daylight saving (the /+1 in the label marks a DST zone). Plain UTC±X entries are fixed offsets that never shift — handy for matching your broker's server time.",
     options = [
     "London (UTC+0/+1)", "Frankfurt (UTC+1/+2)", "Cyprus (UTC+2/+3)", "Moscow (UTC+3)",
     "Dubai (UTC+4)", "Mumbai (UTC+5:30)", "Hong Kong (UTC+8)", "Tokyo (UTC+9)",
     "Sydney (UTC+10/+11)", "New York (UTC-5/-4)", "Chicago (UTC-6/-5)", "Los Angeles (UTC-8/-7)",
     "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3",
     "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+7", "UTC+8", "UTC+9", "UTC+10"])
tz = switch tzChoice
    "London (UTC+0/+1)"    => "Europe/London"
    "Frankfurt (UTC+1/+2)" => "Europe/Berlin"
    "Cyprus (UTC+2/+3)"    => "Asia/Nicosia"
    "Moscow (UTC+3)"       => "Europe/Moscow"
    "Dubai (UTC+4)"        => "Asia/Dubai"
    "Mumbai (UTC+5:30)"    => "Asia/Kolkata"
    "Hong Kong (UTC+8)"    => "Asia/Hong_Kong"
    "Tokyo (UTC+9)"        => "Asia/Tokyo"
    "Sydney (UTC+10/+11)"  => "Australia/Sydney"
    "New York (UTC-5/-4)"  => "America/New_York"
    "Chicago (UTC-6/-5)"   => "America/Chicago"
    "Los Angeles (UTC-8/-7)" => "America/Los_Angeles"
    => tzChoice   // plain UTC±X entries are valid timezone strings as-is

accSess = input.session("0000-1500", "Accumulation window", group = gT,
     tooltip = "The box borders come from the highest HIGH and lowest LOW inside this window.")
extend  = input.bool(true, "Extend box to end of day", group = gT,
     tooltip = "After the window closes, stretch the frozen box to the right until the end of the day in the selected timezone.")

// -------------------------------- STYLE -------------------------------------
gS = "Style"
fillCol = input.color(color.new(#2962ff, 90), "Fill", group = gS)
brdCol  = input.color(color.new(#2962ff, 0),  "Border", group = gS)
brdW    = input.int(1, "Border width", minval = 1, maxval = 4, group = gS)
brdSty  = input.string("Solid", "Border style", options = ["Solid", "Dashed", "Dotted"], group = gS)
showMid = input.bool(true, "Show midline", group = gS)
midCol  = input.color(color.new(color.gray, 0), "Midline color", group = gS)
showLbl = input.bool(true, "Session label", group = gS)
lblTxt  = input.string("", "Label text (empty = auto)", group = gS)

if timeframe.isdwm
    runtime.error("Session Range Box works on intraday timeframes. Recommended M1–H1 — lower timeframes give more precise window edges. Not available on Daily and above.")

brdStyle = brdSty == "Dashed" ? line.style_dashed : brdSty == "Dotted" ? line.style_dotted : line.style_solid
autoTxt  = lblTxt == "" ? str.replace_all(accSess, ":", "") : lblTxt

// tz-local calendar day id, used to stop the extension at end of day
dayId = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)

// ------------------------------- STATE --------------------------------------
var box   b         = na
var line  ml        = na
var label lb        = na
var int   xL        = na
var int   freezeDay = na
var float hi        = na
var float lo        = na

inAcc    = not na(time(timeframe.period, accSess, tz))
startAcc = inAcc and not inAcc[1]
endAcc   = not inAcc and inAcc[1]

// ------------------------------- BUILD --------------------------------------
if startAcc
    xL := bar_index
    hi := high
    lo := low
    b  := box.new(xL, hi, xL, lo, border_color = brdCol, bgcolor = fillCol, border_width = brdW, border_style = brdStyle)
    ml := showMid ? line.new(xL, (hi + lo) / 2, xL, (hi + lo) / 2, color = midCol, style = line.style_dotted) : na
    lb := showLbl ? label.new(xL, hi, autoTxt, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(brdCol, 80), textcolor = brdCol, size = size.small) : na
else if inAcc and not na(b)
    hi := math.max(hi, high)
    lo := math.min(lo, low)
    box.set_top(b, hi)
    box.set_bottom(b, lo)
    box.set_right(b, bar_index)
    if not na(ml)
        line.set_xy1(ml, xL, (hi + lo) / 2)
        line.set_xy2(ml, bar_index, (hi + lo) / 2)
    if not na(lb)
        label.set_xy(lb, xL, hi)

// remember which day the box was frozen on
if endAcc
    freezeDay := dayId

// extension: frozen box stretched to the right until the day rolls over
if extend and not inAcc and not na(b) and not na(freezeDay) and dayId == freezeDay
    box.set_right(b, bar_index)
    if not na(ml)
        line.set_x2(ml, bar_index)
````
