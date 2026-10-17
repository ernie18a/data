# Ratio Range Bands 20D HH/LL

- url: https://www.tradingview.com/script/gfUWbxPS-Ratio-Range-Bands-20D-HH-LL/
- type: indicator
- pine_id: PUB;a8ada3c575d246d695493c73fb70ffc3
- version: 1.0

## Description

A momentum-based rotation indicator designed for the NIFTYBEES/GOLDBEES 
ratio chart (Daily timeframe). It tracks the 20-day Highest High and 
Lowest Low to generate clean, non-repeating buy/rotate signals.

─── HOW IT WORKS ───────────────────────────────────────────

When the ratio closes ABOVE the 20-day Highest High:
  → BUY NIFTYBEES (equities outperforming gold)

When the ratio closes BELOW the 20-day Lowest Low:
  → SELL NIFTYBEES and BUY GOLDBEES (gold outperforming equities)

─── SIGNAL FILTER (STATE MACHINE) ──────────────────────────

The indicator tracks your current position state:
  ● IN NIFTYBEES  — will only signal next when rotation to Gold triggers
  ● IN GOLDBEES   — will only signal next when rotation to Nifty triggers
  ● NEUTRAL       — fresh start, responds to whichever breaks first

This prevents duplicate signals — once you are in a position, 
the same signal will NOT fire again until the opposite one triggers.

─── VISUAL FEATURES ────────────────────────

## Source Code

````pine
//@version=5
indicator("Ratio Range Bands — 20D HH/LL", overlay=true, shorttitle="HH/LL 20D")

// ── Inputs ──────────────────────────────────────────────────
length    = input.int(20,    title="Lookback Period (days)", minval=1)
showBand  = input.bool(true, title="Show Fill Band")
hhColor   = input.color(color.new(color.green, 0),  title="Highest High Color")
llColor   = input.color(color.new(color.red,   0),  title="Lowest Low Color")
fillAlpha = input.int(88, title="Band Opacity (0=solid, 100=invisible)", minval=0, maxval=100)

// ── Calculations ─────────────────────────────────────────────
hh = ta.highest(high, length)
ll = ta.lowest (low,  length)

prev_hh = ta.highest(high, length)[1]
prev_ll = ta.lowest (low,  length)[1]

// ── State Tracking (0=neutral, 1=in NIFTY, -1=in GOLD) ───────
var int position = 0

breakAboveHH = ta.crossover (close, prev_hh)
breakBelowLL = ta.crossunder(close, prev_ll)

// Only trigger if NOT already in that position
buySignal  = breakAboveHH and position != 1
sellSignal = breakBelowLL and position != -1

// Update state
if buySignal
    position := 1
if sellSignal
    position := -1

// ── Plots ─────────────────────────────────────────────────────
hhPlot = plot(hh, title="Highest High", color=hhColor, linewidth=2)
llPlot = plot(ll, title="Lowest Low",   color=llColor, linewidth=2)

// ── Band fill ─────────────────────────────────────────────────
fill(hhPlot, llPlot,
     color = showBand ? color.new(color.purple, fillAlpha) : color.new(color.purple, 100),
     title = "HH-LL Band")

// ── Background color ──────────────────────────────────────────
bgcolor(buySignal  ? color.new(color.green, 85) : na, title="Buy Signal BG")
bgcolor(sellSignal ? color.new(color.red,   85) : na, title="Sell Signal BG")

// ── Arrows ────────────────────────────────────────────────────
plotshape(buySignal,
          title    = "BUY NIFTYBEES",
          location = location.belowbar,
          style    = shape.triangleup,
          color    = color.new(color.green, 0),
          size     = size.normal,
          text     = "BUY\nNIFTY")

plotshape(sellSignal,
          title    = "BUY GOLDBEES",
          location = location.abovebar,
          style    = shape.triangledown,
          color    = color.new(color.red, 0),
          size     = size.normal,
          text     = "BUY\nGOLD")

// ── Current position label (top right) ───────────────────────
if barstate.islast
    posText  = position == 1  ? "● IN NIFTYBEES" :
               position == -1 ? "● IN GOLDBEES"  : "● NEUTRAL"
    posColor = position == 1  ? color.new(color.green, 10) :
               position == -1 ? color.new(color.red,   10) : color.new(color.gray, 10)
    label.new(bar_index, hh,
              text      = "▲ HH: " + str.tostring(hh, "#.####") + "  |  " + posText,
              color     = posColor,
              textcolor = color.white,
              style     = label.style_label_left,
              size      = size.small)
    label.new(bar_index, ll,
              text      = "▼ LL: " + str.tostring(ll, "#.####"),
              color     = color.new(color.red, 10),
              textcolor = color.white,
              style     = label.style_label_left,
              size      = size.small)

// ── Alerts ────────────────────────────────────────────────────
alertcondition(buySignal,
               title   = "BUY NIFTYBEES 🚀",
               message = "Ratio broke ABOVE 20D HH → BUY NIFTYBEES / Exit GOLDBEES")

alertcondition(sellSignal,
               title   = "BUY GOLDBEES 🥇",
               message = "Ratio broke BELOW 20D LL → SELL NIFTYBEES / BUY GOLDBEES")
````
