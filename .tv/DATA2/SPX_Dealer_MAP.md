<!-- tradingview-pine-id: PUB;d9f62bac4a364dd4af590954985909a4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SPX Dealer MAP

Source: https://www.tradingview.com/script/zVFiQBiQ-INDEX-Dashboard-Round-Number-Magnet/

## Description

This TradingView indicator plots a pre-market dealer map for SPX based on the levels described by @azrael_options.

It draws the daily expected-move envelope from a reference close and the ATM straddle (1σ budget), the halfway shelves, the reference/magnet level, and two user-defined gamma walls (typically the nearest heavy-OI round strikes). A light box highlights the session range so you can see at a glance whether price is trading inside dealer parameters or outside them.

Each morning you update four numbers: previous close (or cash-converted overnight ES reference), ATM straddle points, lower gamma wall, and upper gamma wall. The script then draws the ±1σ walls, ±0.5σ shelves, and gamma levels automatically. A close beyond the outer walls is treated as the session invalidation.

The overlay is meant to replace discretionary chart lines with the same coordinates used in the five-minute open routine: mark the gap, price the straddle as the day’s budget, plot the boundaries, and size to 1R against those fixed levels.

---

## Source Code

````pine
//@version=6
indicator("SPX Dealer MAP", overlay=true, max_lines_count=20, max_labels_count=20)

// ── Inputs (edit these each morning with the 5-min calc) ──
refClose     = input.float(7637.76, "Reference / Prev Close", step=0.01)
emPoints     = input.float(73.8,    "ATM Straddle / 1σ EM (points)", step=0.1)
gammaPut     = input.float(7600,    "Put / Lower Gamma Wall")
gammaCall    = input.float(7700,    "Call / Upper Gamma Wall")
showBox      = input.bool(true,     "Show EM Envelope Box")
showLabels   = input.bool(true,     "Show Labels")

// Derived levels
upperWall = refClose + emPoints
lowerWall = refClose - emPoints
upperShelf = refClose + emPoints * 0.5
lowerShelf = refClose - emPoints * 0.5

// Colors
colUpper   = color.new(#ef5350, 0)
colLower   = color.new(#26a69a, 0)
colGamma   = color.new(#ab47bc, 0)
colRef     = color.new(#42a5f5, 20)
colBox     = color.new(#90caf9, 88)

// Plot lines (extend right)
plot(upperWall, "Upper Wall (+1σ)", color=colUpper, linewidth=2, style=plot.style_line)
plot(lowerWall, "Lower Wall (−1σ)", color=colLower, linewidth=2, style=plot.style_line)
plot(upperShelf, "Upper Shelf (+0.5σ)", color=color.new(colUpper, 40), linewidth=1)
plot(lowerShelf, "Lower Shelf (−0.5σ)", color=color.new(colLower, 40), linewidth=1)
plot(refClose, "Ref / Magnet", color=colRef, linewidth=1, style=plot.style_circles)
plot(gammaCall, "Call Gamma Wall", color=colGamma, linewidth=2)
plot(gammaPut,  "Put Gamma Wall",  color=colGamma, linewidth=2)

// Envelope box (today’s session only)
var box emBox = na
if showBox and barstate.islast
    if not na(emBox)
        box.delete(emBox)
    emBox := box.new(bar_index - 20, upperWall, bar_index + 50, lowerWall,
                     border_color=color.new(#90caf9, 50), bgcolor=colBox,
                     extend=extend.right)

// Labels on last bar
if showLabels and barstate.islast
    label.new(bar_index + 8, upperWall, "Upper Wall " + str.tostring(upperWall, "#.0"),
              style=label.style_label_left, color=colUpper, textcolor=color.white, size=size.small)
    label.new(bar_index + 8, lowerWall, "Lower Wall " + str.tostring(lowerWall, "#.0"),
              style=label.style_label_left, color=colLower, textcolor=color.white, size=size.small)
    label.new(bar_index + 8, gammaCall, "Call Wall " + str.tostring(gammaCall, "#"),
              style=label.style_label_left, color=colGamma, textcolor=color.white, size=size.small)
    label.new(bar_index + 8, gammaPut, "Put Wall " + str.tostring(gammaPut, "#"),
              style=label.style_label_left, color=colGamma, textcolor=color.white, size=size.small)
    label.new(bar_index + 8, refClose, "Ref " + str.tostring(refClose, "#.2"),
              style=label.style_label_left, color=colRef, textcolor=color.white, size=size.tiny)
````
