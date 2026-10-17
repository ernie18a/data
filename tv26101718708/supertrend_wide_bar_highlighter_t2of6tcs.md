# Supertrend Wide Bar Highlighter

- url: https://www.tradingview.com/script/T2Of6tCs-Supertrend-Wide-Bar-Highlighter/
- type: indicator
- pine_id: PUB;337e22dee04146ed9208be28c848ba3f
- version: 1.0

## Description

If Buy signal generates in supertrend then check if the difference between the high and low of that buy signal bar is more than some points (which should be put by the user in indicator setting) then change the colour of that bar to black.

## Source Code

````pine
//@version=5
indicator("Supertrend Wide Bar Highlighter", overlay=true)

// ─── User Inputs ───────────────────────────────────────────────────────────────
atrPeriod    = input.int(10,    title="ATR Period",              minval=1)
atrFactor    = input.float(3.0, title="ATR Factor",              minval=0.1, step=0.1)
minBarRange  = input.float(10.0, title="Min Bar Range (Points)", minval=0.1, step=0.1,
                 tooltip="If the High-Low of a Buy signal bar exceeds this value, the bar is coloured black.")

// ─── Supertrend Calculation ────────────────────────────────────────────────────
[supertrend, direction] = ta.supertrend(atrFactor, atrPeriod)

// direction < 0  →  bullish (Buy)
// direction > 0  →  bearish (Sell)

isBuy  = direction < 0
isSell = direction > 0

// ─── Detect the bar where a new Buy signal fires ──────────────────────────────
newBuySignal = isBuy and direction[1] > 0   // transition: Sell → Buy

// ─── Bar-range check on the Buy-signal bar ────────────────────────────────────
barRange      = high - low
wideBar       = newBuySignal and (barRange > minBarRange)

// ─── Bar colouring ────────────────────────────────────────────────────────────
barcolor(wideBar ? color.black : na, title="Wide Buy-Signal Bar")

// ─── Optional: plot the Supertrend line so you can see the signals ─────────────
plot(supertrend,
     title     = "Supertrend",
     color     = isBuy ? color.new(color.green, 0) : color.new(color.red, 0),
     linewidth = 2)

// ─── Buy / Sell arrow labels ──────────────────────────────────────────────────
plotshape(newBuySignal,
          title     = "Buy Signal",
          style     = shape.labelup,
          location  = location.belowbar,
          color     = color.new(color.green, 0),
          textcolor = color.white,
          text      = "BUY",
          size      = size.small)

plotshape(isSell and direction[1] < 0 ? false : isSell and direction[1] < 0 ? false :
          (isSell and not isSell[1]),          // Sell transition
          title     = "Sell Signal",
          style     = shape.labeldown,
          location  = location.abovebar,
          color     = color.new(color.red, 0),
          textcolor = color.white,
          text      = "SELL",
          size      = size.small)

// ─── Alert conditions ─────────────────────────────────────────────────────────
alertcondition(newBuySignal,  title="Buy Signal",           message="Supertrend: Buy Signal")
alertcondition(wideBar,       title="Wide Buy-Signal Bar",  message="Supertrend: Buy Signal with wide bar (range > threshold)")
````
