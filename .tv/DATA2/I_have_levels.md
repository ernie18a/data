<!-- tradingview-pine-id: PUB;c18f1e86789a4dfc95879a9aea8334e6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# I have levels

Source: https://www.tradingview.com/script/rHgWItoM-I-have-levels/

## Description

"I Have Levels" is a 21/55 EMA cross indicator with a twist: every signal it prints is
deliberately the opposite of the classic interpretation. A bullish cross prints a red
SHORT. A bearish cross prints a green LONG. This is intentional, it is the entire point
of the script, and it is stated plainly here so nobody is surprised by it.

On top of the inverted signals, the script draws a continuous mirrored price path — the
"crayon" — that runs upside down relative to actual price for as long as a signal stays
active. When price goes up, the crayon goes down. When price goes down, the crayon goes
up. It is a visual inversion of the market, anchored to the bar where the last cross
occurred.

Treat this as a novelty and contrarian-perspective tool, not as a signal service.

## What it plots

**21 EMA (aqua) and 55 EMA (purple)**
Standard exponential moving averages on close. These are the only conventional
components in the script and can be toggled off.

**Wintuition SHORT**
When the 21 EMA crosses ABOVE the 55 EMA — normally read as bullish — the script prints
a red labeled SHORT above the candle.

**Which Way Did It Joe? LONG**
When the 21 EMA crosses BELOW the 55 EMA — normally read as bearish — the script prints
a green labeled LONG below the candle.

**Full-history opposite crayon**
On each cross the script stores two anchors: the closing price of the signal bar, and a
visual starting point (the bar's high on a SHORT signal, the bar's low on a LONG signal).
From there it plots:

    crayon = visual anchor − (current close − price anchor)

So the crayon inverts every subsequent move around the anchor level. A one-bar gap is
inserted at each new signal so consecutive crayon segments never connect into a single
misleading line. The crayon is drawn as a plot rather than line objects, which means it
persists across all loaded history instead of running into Pine's 500-object drawing
limit.

## Settings

- Fast EMA Length — default 21
- Slow EMA Length — default 55
- Show EMAs — toggle the two moving averages
- Show Opposite Signals — toggle the labels
- Show Full-History Crayon — toggle the mirrored price path
- Crayon Thickness — line width, 1 to 8
- Wintuition SHORT Color — default red
- Which Way Did It Joe? LONG Color — default green

## Alerts

Two alertconditions are included:

- Wintuition SHORT — fires on a 21-above-55 cross
- Which Way Did It Joe? LONG — fires on a 21-below-55 cross

## Repainting

Both signals require `barstate.isconfirmed`, so labels and alerts only fire on closed
bars. Nothing shifts or disappears after the fact. The crayon updates in real time on
the developing bar because it tracks the live close, and settles once the bar closes.

## How people actually use it

Three honest use cases:

1. As a perspective flip. Seeing the mirrored path sometimes makes an obvious-looking
   trend look a lot less obvious.
2. As a fade tool. If you already trade against retail crossover signals, this labels
   them for you in the direction you would actually be taking.
3. As a joke on your own chart. That is a legitimate reason and this script does not
   pretend otherwise.

## Notes and limitations

- Moving average crossovers lag by construction and chop badly in ranges. Inverting them
  does not fix that; it inverts the losses too.
- The crayon is a mirrored price path, not a support/resistance level, not a projection,
  and not a forecast. Do not read it as a target.
- No backtest, no win rate, and no performance claim is made anywhere in this script,
  because none has been established.

## Disclaimer

For education and entertainment. Nothing here is financial advice. Signals are
intentionally inverted from their conventional meaning. Do your own research and manage
your own risk.

---

## Source Code

````pine
//@version=6
indicator(
     "I have levels",
     overlay = true
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastLength = input.int(21, "Fast EMA Length", minval = 1)
slowLength = input.int(55, "Slow EMA Length", minval = 1)

showEMAs    = input.bool(true, "Show EMAs")
showSignals = input.bool(true, "Show Opposite Signals")
showCrayon  = input.bool(true, "Show Full-History Crayon")

crayonWidth = input.int(
     4,
     "Crayon Thickness",
     minval = 1,
     maxval = 8
)

shortColor = input.color(
     color.rgb(255, 20, 20),
     "Wintuition SHORT Color"
)

longColor = input.color(
     color.rgb(0, 230, 100),
     "Which Way Did It Joe? LONG Color"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 21/55 EMA CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)

bullishCross =
     ta.crossover(fastEMA, slowEMA) and
     barstate.isconfirmed

bearishCross =
     ta.crossunder(fastEMA, slowEMA) and
     barstate.isconfirmed

// Intentionally opposite signals:
//
// 21 crosses above 55 = Wintuition SHORT
// 21 crosses below 55 = Which Way Did It Joe? LONG

wintuitionShort = bullishCross
joeLong         = bearishCross

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showEMAs ? fastEMA : na,
     title = "21 EMA",
     color = color.aqua,
     linewidth = 2
)

plot(
     showEMAs ? slowEMA : na,
     title = "55 EMA",
     color = color.purple,
     linewidth = 2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WINTUITION SHORT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish cross intentionally prints
// a red opposite SHORT above the candle.

plotshape(
     showSignals and wintuitionShort,
     title = "Wintuition SHORT",
     style = shape.labeldown,
     location = location.abovebar,
     color = shortColor,
     textcolor = color.white,
     text = "☹️🔻\nWINTUITION\nSHORT",
     size = size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHICH WAY DID IT JOE? LONG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bearish cross intentionally prints
// a green opposite LONG below the candle.

plotshape(
     showSignals and joeLong,
     title = "Which Way Did It Joe? LONG",
     style = shape.labelup,
     location = location.belowbar,
     color = longColor,
     textcolor = color.black,
     text = "😏⬆️⬆️\nWHICH WAY DID IT JOE?\nLONG",
     size = size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FULL-HISTORY OPPOSITE CRAYON
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Mode:
//  1 = Wintuition SHORT
// -1 = Which Way Did It Joe? LONG
//  0 = waiting for first signal

var int activeMode = 0
var float anchorMarketPrice = na
var float anchorCrayonPrice = na

// Wintuition SHORT starts at the candle high.

if wintuitionShort
    activeMode        := 1
    anchorMarketPrice := close
    anchorCrayonPrice := high

// Joe LONG starts at the candle low.

else if joeLong
    activeMode        := -1
    anchorMarketPrice := close
    anchorCrayonPrice := low

// Create an upside-down copy of price movement.
//
// Price rises → crayon falls.
// Price falls → crayon rises.

priceMovement =
     activeMode != 0
     ? close - anchorMarketPrice
     : na

oppositeCrayon =
     activeMode != 0
     ? anchorCrayonPrice - priceMovement
     : na

crayonColor =
     activeMode == 1
     ? shortColor
     : longColor

// Insert a one-bar break at every new signal.
// This prevents separate crayon drawings
// from being connected together.

newSignal = wintuitionShort or joeLong

crayonPlot =
     showCrayon and not newSignal
     ? oppositeCrayon
     : na

// A plot preserves all available loaded history
// and avoids Pine's 500-line-object limit.

plot(
     crayonPlot,
     title = "Opposite Crayon",
     color = crayonColor,
     linewidth = crayonWidth,
     style = plot.style_linebr
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     wintuitionShort,
     title = "Wintuition SHORT",
     message = "Wintuition SHORT: the 21 EMA crossed above the 55 EMA and printed the intentionally opposite red signal."
)

alertcondition(
     joeLong,
     title = "Which Way Did It Joe? LONG",
     message = "Which Way Did It Joe? LONG: the 21 EMA crossed below the 55 EMA and printed the intentionally opposite green signal."
)
````
