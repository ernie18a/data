# MTF Candle Trend Table

- url: https://www.tradingview.com/script/Svy2HJob-MTF-Candle-Trend-Table/
- type: indicator
- pine_id: PUB;05d1feb23186402f9e416c0d03398a45
- version: 1.0

## Description

This indicator puts a simple table in the corner of your chart showing you what's happening across 8 different timeframes all at once — no need to keep switching between charts.

For each timeframe from the Weekly down to the 1 minute, you get a green or red block telling you if that candle is bullish or bearish, a small triangle showing whether buyers or sellers were actually in control during that candle, and a live countdown showing how much time is left before it closes.

It's handy for making sure everything lines up before you take a trade — if the higher timeframes are all green and the lower ones are just catching up, that's a much stronger signal than if they're all pointing in different directions. The countdown is useful too so you're not jumping in right as a candle is about to close.

Trend alignment — if all rows are green, momentum is bullish across all timeframes
Divergence spotting — higher TFs red but lower TFs green may signal a pullback retracement
Entry timing — use the countdown to avoid entering right as a candle closes
Delta confirmation — a green candle with a ▼ warns that sellers were active despite the bullish close

## Source Code

````pine
//@version=6
indicator("MTF Candle Trend Table", overlay=true)

// === INPUTS ===
textColor = input.color(color.white, "Couleur texte & cadre")
bullColor = input.color(color.green, "Couleur Bullish")
bearColor = input.color(color.red, "Couleur Bearish")

// === Single request.security call per timeframe (returns color, delta, countdown) ===
f_tf_all(tf) =>
    [o, c, h, l, v, tc] = request.security(syminfo.tickerid, tf, [open, close, high, low, volume, time_close])

    // Trend color
    tfColor = c >= o ? bullColor : bearColor

    // Delta symbol
    hl_range = h - l
    delta = hl_range > 0 ? v * (2 * c - h - l) / hl_range : 0.0
    deltaSymbol = delta >= 0 ? "▲" : "▼"

    // Countdown
    remaining_ms = math.max(tc - timenow, 0)
    remaining_s  = int(remaining_ms / 1000)
    days  = int(remaining_s / 86400)
    hours = int(remaining_s % 86400 / 3600)
    mins  = int(remaining_s % 3600  / 60)
    secs  = remaining_s % 60
    countdown = days > 0
         ? str.format("{0}d {1}:{2}", days, str.tostring(hours, "00"), str.tostring(mins, "00"))
         : str.format("{0}:{1}:{2}", str.tostring(hours, "00"), str.tostring(mins, "00"), str.tostring(secs, "00"))

    [tfColor, deltaSymbol, countdown]

// === Fetch all timeframes (8 calls total instead of 56) ===
[colorW,  deltaW,  cdW]  = f_tf_all("W")
[colorD,  deltaD,  cdD]  = f_tf_all("D")
[color4H, delta4H, cd4H] = f_tf_all("240")
[color1H, delta1H, cd1H] = f_tf_all("60")
[color30, delta30, cd30] = f_tf_all("30")
[color15, delta15, cd15] = f_tf_all("15")
[color5,  delta5,  cd5]  = f_tf_all("5")
[color1,  delta1,  cd1]  = f_tf_all("1")

// === Table (8 rows) ===
var table trendTable = table.new(
     position.bottom_left,
     3,
     8,
     border_width = 1,
     border_color = textColor,
     frame_width  = 2,
     frame_color  = textColor)

if barstate.islast

    table.cell(trendTable, 0, 0, "WEEK", text_color=textColor)
    table.cell(trendTable, 1, 0, deltaW,  bgcolor=colorW,  width=4, text_color=color.white)
    table.cell(trendTable, 2, 0, cdW,  text_color=textColor)

    table.cell(trendTable, 0, 1, "DAY",  text_color=textColor)
    table.cell(trendTable, 1, 1, deltaD,  bgcolor=colorD,  width=4, text_color=color.white)
    table.cell(trendTable, 2, 1, cdD,  text_color=textColor)

    table.cell(trendTable, 0, 2, "4H",   text_color=textColor)
    table.cell(trendTable, 1, 2, delta4H, bgcolor=color4H, width=4, text_color=color.white)
    table.cell(trendTable, 2, 2, cd4H, text_color=textColor)

    table.cell(trendTable, 0, 3, "1H",   text_color=textColor)
    table.cell(trendTable, 1, 3, delta1H, bgcolor=color1H, width=4, text_color=color.white)
    table.cell(trendTable, 2, 3, cd1H, text_color=textColor)

    table.cell(trendTable, 0, 4, "30",   text_color=textColor)
    table.cell(trendTable, 1, 4, delta30, bgcolor=color30, width=4, text_color=color.white)
    table.cell(trendTable, 2, 4, cd30, text_color=textColor)

    table.cell(trendTable, 0, 5, "15",   text_color=textColor)
    table.cell(trendTable, 1, 5, delta15, bgcolor=color15, width=4, text_color=color.white)
    table.cell(trendTable, 2, 5, cd15, text_color=textColor)

    table.cell(trendTable, 0, 6, "5",    text_color=textColor)
    table.cell(trendTable, 1, 6, delta5,  bgcolor=color5,  width=4, text_color=color.white)
    table.cell(trendTable, 2, 6, cd5,  text_color=textColor)

    table.cell(trendTable, 0, 7, "1",    text_color=textColor)
    table.cell(trendTable, 1, 7, delta1,  bgcolor=color1,  width=4, text_color=color.white)
    table.cell(trendTable, 2, 7, cd1,  text_color=textColor)
````
