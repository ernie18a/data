# Gamma Regime Flag

- url: https://www.tradingview.com/script/DwZEytLZ-Gamma-Regime-Flag/
- type: indicator
- pine_id: PUB;c9493804a4374b43a0bc8faf44b67d60
- version: 1.0

## Description

Gamma Regime Flag

Flags whether price is trading above or below an estimated gamma flip level — the zone where dealer/market-maker hedging flow is thought to shift character (supportive vs. amplifying). This is a simplified, single-purpose read: just the flip line and the regime state, nothing else.

How it works:
The flip level is approximated using VWAP as an anchor, lightly smoothed with an EMA to reduce noise. When price is above the flip, the background shades one color (Positive Gamma); below it, the other (Negative Gamma). A small table in the corner shows the current regime and how many bars price has held on that side, so you can see how "sticky" the current regime has been.

How to use it:
Positive gamma regimes have historically been associated with more mean-reverting, range-bound price action, since dealer hedging tends to dampen moves. Negative gamma regimes have been associated with more trending, volatile action, since hedging flow can amplify moves in the same direction. Use the regime as context alongside your own setup — not as a standalone signal.

Inputs:

Flip Line Smoothing — controls how reactive vs. smooth the flip level is
Show Info Table / Show Flip Label — toggle the on-chart readouts
Background and line colors — fully customizable

Alerts:
Includes an alert condition for when price crosses the gamma flip level.

Notes:
This is an educational tool that approximates gamma positioning using price and volume data — it does not use live options chain data. It is not financial advice. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Gamma Regime Flag", overlay=true, max_lines_count=50, max_labels_count=50)

// ============================================================================
// GAMMA REGIME FLAG
//
// Flags whether price is trading above or below an estimated gamma flip
// level (the zone where dealer hedging flow is thought to shift character),
// using VWAP as a proxy anchor with light smoothing. Background color and a
// simple info table make the regime state readable at a glance.
//
// This is a simplified, single-purpose read -- just the flip and regime,
// nothing else.
//
// Educational tool. Uses price/volume proxies, not live options chain data.
// Not financial advice.
// ============================================================================

// ---------------------------- INPUTS ----------------------------------------
smoothLen   = input.int(5, "Flip Line Smoothing", minval=1, maxval=20, group="Calculation")
showTable   = input.bool(true, "Show Info Table", group="Display")
showLabel   = input.bool(true, "Show Flip Label", group="Display")

posColor    = input.color(color.new(color.green, 90), "Positive Gamma Background", group="Colors")
negColor    = input.color(color.new(color.red, 90),   "Negative Gamma Background", group="Colors")
flipColor   = input.color(color.new(#FFA500, 0),       "Flip Line", group="Colors")

// ---------------------------- CALCULATIONS -----------------------------------
vwapAnchor  = ta.vwap(close)
gammaFlip   = ta.ema(vwapAnchor, smoothLen)

isPositive  = close > gammaFlip
regimeLabel = isPositive ? "Positive Gamma" : "Negative Gamma"
regimeColor = isPositive ? posColor : negColor

distPct     = ((close - gammaFlip) / close) * 100

// bars since the regime last flipped
regimeState = isPositive ? 1 : -1
var int regimeStart = bar_index
if ta.change(regimeState) != 0
    regimeStart := bar_index
barsInRegime = bar_index - regimeStart

// ---------------------------- PLOTTING ----------------------------------------
plot(gammaFlip, "Gamma Flip", flipColor, 2, plot.style_circles)
bgcolor(regimeColor, title="Gamma Regime")

// ---------------------------- LABEL --------------------------------------------
var label flipLabel = na
if barstate.islast and showLabel
    if not na(flipLabel)
        label.delete(flipLabel)
    flipLabel := label.new(
         x=bar_index, y=gammaFlip,
         text="Gamma Flip\n$" + str.tostring(gammaFlip, "#.##") +
              "\n(" + str.tostring(math.abs(distPct), "#.#") + "% away)",
         style=label.style_label_center,
         color=flipColor,
         textcolor=color.white,
         size=size.normal)

// ---------------------------- INFO TABLE -----------------------------------------
var table infoTable = table.new(position.top_right, 2, 3, border_width=1,
     bgcolor=color.new(color.black, 10), frame_color=color.gray, frame_width=1)

if barstate.islast and showTable
    table.cell(infoTable, 0, 0, "Gamma Regime", bgcolor=color.new(#1a1a1a, 0), text_color=color.white)
    table.cell(infoTable, 1, 0, "", bgcolor=color.new(#1a1a1a, 0), text_color=color.white)

    table.cell(infoTable, 0, 1, "Regime:", bgcolor=color.new(#2a2a2a, 0), text_color=color.white)
    table.cell(infoTable, 1, 1, regimeLabel, bgcolor=color.new(#2a2a2a, 0), text_color=isPositive ? color.lime : color.red)

    table.cell(infoTable, 0, 2, "Bars in Regime:", bgcolor=color.new(#2a2a2a, 0), text_color=color.white)
    table.cell(infoTable, 1, 2, str.tostring(barsInRegime), bgcolor=color.new(#2a2a2a, 0), text_color=color.aqua)

// ---------------------------- ALERTS -----------------------------------------------
alertcondition(ta.cross(close, gammaFlip), "Gamma Regime Flip", "Gamma regime flipped: {{ticker}} at {{close}}")
````
