# Colored ALMA

- url: https://www.tradingview.com/script/0F7vr6JP-Colored-ALMA/
- type: indicator
- pine_id: PUB;8a6e88e35f604b8eb5416a5d868a8f47
- version: 1.0

## Description

ALMA is the Arnaud Legoux Moving Average. Instead of weighting every bar in the lookback equally, it lays a bell curve over those bars and weights them by where they fall under that curve. The Offset decides where the peak of the curve sits. At 0.85 the peak sits near the newest bars, so the line hugs price with very little lag. Sigma controls how narrow the bell is, and a higher Sigma like 6 means fewer bars carry real weight, which smooths the line. So 14, 0.85, 6 gives you a fast line that still refuses to chase every tick.

How the color decides itself
In slope mode the script only asks one question each bar: is the ALMA higher or lower than it was on the previous bar. Rising paints green, falling paints red. The direction is stored in a variable that carries forward, so if the line goes perfectly flat for a bar it holds whatever color it had rather than blinking to something neutral. You only get a color change when the line genuinely turns.
That is why slope mode is quieter than price versus ALMA. Price can poke through a moving average a dozen times in a sideways hour, but the average itself has to actually roll over before slope changes.

The markers and the alerts
A small triangle prints under the bar when it turns green and above the bar when it turns red, so you can eyeball the history without hunting for the exact bar where the color switched.
For alerts you have four options in the dialog. Three of them are alertcondition entries: green only, red only, or any change. Those let you set your own trigger frequency in the alert window. The fourth is the built in alert call, which fires on bar close and sends a message with the direction and the price. Use the alertcondition ones if you want control over frequency, use the alert call if you want the message to carry the price with it.

To make slope the default
Change the first argument on the Color Rule input from "Price vs ALMA" to "ALMA Slope". Everything else stays as is.

One thing worth knowing before you lean on it: slope mode is calmer, but in tight chop a fast ALMA can still ripple up and down a few ticks and flip on you. If that shows up on your timeframe, raising Length or lowering Offset a little will kill most of it. This is a tool to give information about a price chart and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("Colored ALMA", overlay = true)

src  = input.source(close, "Source")
len  = input.int(14, "Length", minval = 1)
off  = input.float(0.85, "Offset", minval = 0, maxval = 1, step = 0.01)
sig  = input.float(6, "Sigma", minval = 0.1, step = 0.1)
mode = input.string("Price vs ALMA", "Color Rule", options = ["Price vs ALMA", "ALMA Slope"])
mark = input.bool(true, "Show flip markers")

a  = ta.alma(src, len, off, sig)
up = mode == "Price vs ALMA" ? src > a : a > a[1]
dn = mode == "Price vs ALMA" ? src < a : a < a[1]

var int st = 1
st := up ? 1 : dn ? -1 : st

col  = st == 1 ? color.new(#0B9E6E, 0) : color.new(#D6303A, 0)
flip = st != st[1]

plot(a, "ALMA", color = col, linewidth = 2)

plotshape(mark and flip and st ==  1, "Bull flip", shape.triangleup,   location.belowbar, color.new(#0B9E6E, 0), size = size.tiny)
plotshape(mark and flip and st == -1, "Bear flip", shape.triangledown, location.abovebar, color.new(#D6303A, 0), size = size.tiny)

alertcondition(flip and st ==  1, "ALMA turned green", "ALMA flipped bullish")
alertcondition(flip and st == -1, "ALMA turned red",   "ALMA flipped bearish")
alertcondition(flip,              "ALMA color change", "ALMA color changed")

if flip
    alert("ALMA " + (st == 1 ? "green (bullish)" : "red (bearish)") + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
