# NYSE Open 30s Range

- url: https://www.tradingview.com/script/Y01NFTdb/
- type: indicator
- pine_id: PUB;d5eb0f9c2ed3492592a4e2900ff8efac
- version: 2.0

## Description

NYSE Opening Range (First 30s Candle)

This indicator automatically plots the NYSE Opening Range based exclusively on the first 30-second candle after the official market open (09:30:00 → 09:30:30 New York time).

The rectangle is drawn using the actual High and Low of that 30-second candle, remaining anchored to the correct opening timestamp regardless of the chart timeframe.

Features

✓ Automatically captures the first 30-second candle of the NYSE open
✓ Rectangle anchored to the actual opening time (does not shift when changing timeframes)
✓ Custom fill color
✓ Adjustable transparency
✓ Custom border color
✓ Multiple border styles (solid, dashed, dotted)
✓ Adjustable border thickness
✓ Adjustable horizontal extension of the range

How to Use
Wait for the first 30-second opening candle to form.
Use the range as a reference for:
Opening breakout setups
Opening rejection setups
Initial market liquidity
Intraday continuation or reversal scenarios

Notes:
The indicator uses internal 30-second data, allowing it to work even on higher chart timeframes.
Time is fixed to America/New_York to maintain alignment with the official NYSE opening session.

## Source Code

````pine
//@version=6
indicator("NYSE Open 30s Range", overlay=true, max_boxes_count=500)

// ── CONFIG ─────────────────────────────────────────────────────────
fillColor   = input.color(color.blue,  "Fill Color")
transp      = input.int(85,            "Fill Transparency", minval=0, maxval=100)
borderColor = input.color(color.white, "Border Color")
borderWidth = input.int(2,             "Border Width",      minval=1, maxval=5)
styleInput  = input.string("Solid",    "Border Style",      options=["Solid","Dashed","Dotted"])
transpBorda = input.int(0,             "Border Transparency", minval=0, maxval=100)

// ── BORDER STYLE ───────────────────────────────────────────────────
borderStyle =
     styleInput == "Dashed" ? line.style_dashed :
     styleInput == "Dotted" ? line.style_dotted :
     line.style_solid

// ── FETCH 30S CANDLE VIA request.security ─────────────────────────
[s30_high, s30_low, s30_time] = request.security(
     syminfo.tickerid, "30S",
     [high, low, time],
     lookahead = barmerge.lookahead_on)

// Detect exactly the 9:30:00 NY candle
eh_930 = hour(s30_time, "America/New_York")   == 9  and
         minute(s30_time, "America/New_York") == 30 and
         second(s30_time, "America/New_York") == 0

// ── STATE ──────────────────────────────────────────────────────────
var float cap_high = na
var float cap_low  = na
var int   cap_time = na
var box   myBox    = na

// Reset on each new day
if ta.change(time("D")) != 0
    cap_high := na
    cap_low  := na
    cap_time := na
    myBox    := na

// Capture high/low and timestamp once per day
if eh_930 and na(cap_time)
    cap_high := s30_high
    cap_low  := s30_low
    cap_time := int(s30_time)

// ── DRAW WITH xloc.bar_time ────────────────────────────────────────
if not na(cap_time) and not na(cap_high)
    ts_left  = cap_time
    ts_right = cap_time + 7 * 3600 * 1000 + 30 * 60 * 1000

    if na(myBox)
        myBox := box.new(
             xloc         = xloc.bar_time,
             left         = ts_left,
             top          = cap_high,
             right        = ts_right,
             bottom       = cap_low,
             bgcolor      = color.new(fillColor, transp),
             border_color = color.new(borderColor, transpBorda),
             border_width = borderWidth,
             border_style = borderStyle)
    else
        box.set_top(myBox,          cap_high)
        box.set_bottom(myBox,       cap_low)
        box.set_bgcolor(myBox,      color.new(fillColor, transp))
        box.set_border_color(myBox, color.new(borderColor, transpBorda))
        box.set_border_width(myBox, borderWidth)
        box.set_border_style(myBox, borderStyle)
````
