# MTF Candle Trend Table AFX 

- url: https://www.tradingview.com/script/sLfLdEg4-MTF-Candle-Trend-Table-AFX/
- type: indicator
- pine_id: PUB;375bed74046c4e5d9b5ee27d6883a8b1
- version: 1.0

## Description

What it does:
It shows the trend direction of 6 timeframes simultaneously in a compact table at the bottom-left of the chart:

Label	Timeframe
WEEK	Weekly
DAY	Daily
4H	4 Hours
1H	1 Hour
30	30 Minutes
15	15 Minutes
How it works:
For each timeframe, it compares the open vs close of the current candle:

Green → close ≥ open (bullish candle)
Red → close < open (bearish candle)
What you see:
A two-column table — timeframe name on the left, a colored block on the right — giving you an instant top-down view of market bias across all timeframes without switching charts.

Customizable:

Text & border color
Bullish color (default green)
Bearish color (default red)
Typical use case: Quickly spot timeframe alignment — e.g. if all 6 are green, the trend is bullish across the board. If higher timeframes are red but lower ones are green, it may signal a retracement within a downtrend.

## Source Code

````pine
//@version=6
indicator("MTF Candle Trend Table", overlay=true)

// === INPUTS ===
textColor = input.color(color.white, "Couleur texte & cadre")
bullColor = input.color(color.green, "Couleur Bullish")
bearColor = input.color(color.red, "Couleur Bearish")

// === Fonction couleur bougie timeframe ===
f_tf_color(tf) =>
    tfOpen  = request.security(syminfo.tickerid, tf, open)
    tfClose = request.security(syminfo.tickerid, tf, close)
    tfClose >= tfOpen ? bullColor : bearColor

// === Couleurs dynamiques ===
colorW   = f_tf_color("W")
colorD   = f_tf_color("D")
color4H  = f_tf_color("240")
color1H  = f_tf_color("60")
color30  = f_tf_color("30")
color15  = f_tf_color("15")

// === Création tableau ===
var table trendTable = table.new(
     position.bottom_left,
     2,
     6,
     border_width = 1,
     border_color = textColor,
     frame_width  = 2,
     frame_color  = textColor)

// === Mise à jour uniquement sur dernière barre ===
if barstate.islast

    table.cell(trendTable, 0, 0, "WEEK", text_color=textColor)
    table.cell(trendTable, 1, 0, "", bgcolor=colorW,  width=4)

    table.cell(trendTable, 0, 1, "DAY",  text_color=textColor)
    table.cell(trendTable, 1, 1, "", bgcolor=colorD,  width=4)

    table.cell(trendTable, 0, 2, "4H",   text_color=textColor)
    table.cell(trendTable, 1, 2, "", bgcolor=color4H, width=4)

    table.cell(trendTable, 0, 3, "1H",   text_color=textColor)
    table.cell(trendTable, 1, 3, "", bgcolor=color1H, width=4)

    table.cell(trendTable, 0, 4, "30",   text_color=textColor)
    table.cell(trendTable, 1, 4, "", bgcolor=color30, width=4)

    table.cell(trendTable, 0, 5, "15",   text_color=textColor)
    table.cell(trendTable, 1, 5, "", bgcolor=color15, width=4)
````
