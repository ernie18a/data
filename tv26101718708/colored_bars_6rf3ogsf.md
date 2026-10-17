# Colored Bars

- url: https://www.tradingview.com/script/6rF3OGSf-Colored-Bars/
- type: indicator
- pine_id: PUB;d223f1a511dd4260b934c2ddc90a56a9
- version: 1.0

## Description

Colored Bars colors each bar by its Gann bar type, comparing its high and low with the previous bar's.

HOW IT WORKS
Up bar (green): a higher high and a higher low.
Down bar (red): a lower high and a lower low.
Inside bar (gray): the high and low are within the previous bar's range.
Outside bar (fuchsia): a higher high and a lower low, or an equal high or low with the range not inside.
Each color is full when the candle closes above its open (below for a down bar), and a darker shade otherwise. A darker green, for example, is an up bar that closed below its open.

HOW TO USE IT
Up and down bars show the direction of the swing. Inside bars show a pause and don't change the swing. Outside bars show indecision and are often handled separately in swing charting. The darker shade shows a bar whose candle disagrees with its bar type.

INPUTS
Show Bar Colors: turns the coloring on or off. The four colors can be changed in the Style tab.

DRAWING AND LIMITATIONS
Only the bar colors change; nothing else is drawn. The live bar's type can change until it closes. Completed bars never change.
The first bar on the chart is classified by its candle only.

CREDITS
Bar types as used in W. D. Gann's swing charting.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bashu9
//@version=6

//#region Header Info
// ——————————————————————————————————————————————————————————————————————————
// Indicator:   Colored Bars
// Author:      bashu9
// Description: Colors bars by Gann bar type: up, down, inside and outside bars.
// ——————————————————————————————————————————————————————————————————————————
//#endregion

indicator("Colored Bars", overlay=true)

// ─── INPUTS ────────────────────────────────────────────────────────────────
bool show = input.bool(true, "Show Bar Colors", tooltip="Gann Turning Points (up, down, inside, outside).")

// ─── BAR CLASSIFICATION ────────────────────────────────────────────────────
// UP: higher high + higher low. DOWN: lower high + lower low.
// INSIDE: high/low both contained within the prior bar's range.
// OUTSIDE: everything else (engulfs the prior bar's range).
const int UP      = 1
const int DOWN    = -1
const int INSIDE  = 0
const int OUTSIDE = 2

int btype = barstate.isfirst ? (close > open ? UP : DOWN) :
     high > high[1] and low > low[1] ? UP :
     high < high[1] and low < low[1] ? DOWN :
     high <= high[1] and low >= low[1] ? INSIDE : OUTSIDE

// ─── HELPER: shade a color darker by pct% ─────────────────────────────────
darken(c, pct) =>
    f = 1.0 - pct / 100.0
    color.rgb(int(math.round(color.r(c) * f)), int(math.round(color.g(c) * f)), int(math.round(color.b(c) * f)))

// ─── COLOR BARS ────────────────────────────────────────────────────────────
// Up/down bars whose candle direction (open vs close) agrees with the
// classified type get the full color; disagreeing candles get a darkened
// shade. Outside bars are always fuchsia, inside bars always gray.
barcolor(title="Up",      color=not show ? na : btype == UP      ? (open < close ? color.green   : darken(color.green,   50)) : na)
barcolor(title="Down",    color=not show ? na : btype == DOWN    ? (open > close ? color.red     : darken(color.red,     50)) : na)
barcolor(title="Outside", color=not show ? na : btype == OUTSIDE ? (open < close ? color.fuchsia : darken(color.fuchsia, 50)) : na)
barcolor(title="Inside",  color=not show ? na : btype == INSIDE  ? (open < close ? color.gray    : darken(color.gray,    50)) : na)
````
