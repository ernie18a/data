# Blue Sky Breakout Momentum

- url: https://www.tradingview.com/script/TbipPmiE/
- type: indicator
- pine_id: PUB;fcbb382493b04ddb857985df358a0610
- version: 1.0

## Description

A momentum reading in five plain words: Strong up, Up, Flat, Down, Strong down. Next to it a strength figure from -100 % to +100 %, a histogram that tells you whether the move is building or fading, and a small table on the chart. Every colour is a measured past, never a forecast. The script gives no advice: no entries, no exits, no targets.

WHAT IT DOES

The panel answers one question: does this chart have momentum right now, and how much? It measures, it does not predict. The candles take the colour of the current state, so the answer is visible without reading the panel.

HOW IT WORKS

Core: the Price Momentum Oscillator (PMO), a rate of change smoothed twice (35 and 20 bars) with a 10 bar EMA signal line. The PMO is taken from the public TradingView "ta" library. Because it is built on a rate of change it is price relative and reads the same on a 5 dollar stock and a 500 dollar stock.

Strength: the PMO divided by its own largest absolute value of the last 252 bars, shown as a percentage. 100 % means "as strong as it has been in the past year", 10 % means a small move by this symbol's own standards. This is what makes the reading comparable from one symbol to the next.

State: below 20 % strength the chart is Flat, a grey zone around zero. Above that it is Up or Down. From 60 % it is Strong up or Strong down. A new state counts only after it has held for two bars, so one bar flickers do not change the reading.

Histogram: PMO minus its signal line. A deep tone while the gap widens in the direction of the state (building), a light tone while it narrows (fading). This separates "momentum that is still growing" from "momentum that is running out".

Table: Momentum (the state), Strength (the percentage), Histogram (Building or Fading), In state (how many bars the state has held) and PMO vs signal (Above or Below).

HOW TO USE IT

Read the table from top to bottom. Momentum gives the state, Strength the size, Histogram whether it is still building, In state for how long. The coloured background of the panel and the candle colours repeat the state. A label marks the candle where a strong state began, so you can see at a glance how far the current move has already come. Nothing in this script is a signal to buy or sell.

SETTINGS

Momentum: source, the two PMO smoothing lengths, the signal length and the window for the strength scale (252 daily bars is one year).
State: the Flat threshold (default 20 %), the Strong threshold (default 60 %) and how many bars a state must hold before it counts (default 2).
Pane: histogram, signal line, flat zone and coloured background on or off, background strength.
Chart: candle colouring, strong state markers, table on or off and table position.
ALERTS

Five alerts, all on measured changes only: PMO crossed above zero, PMO crossed below zero, momentum turned strong up, momentum turned strong down, strong momentum ended.

WHY IT IS ORIGINAL

The PMO itself is a standard oscillator. What this script adds is the year relative strength scale that makes momentum comparable across symbols, the five state wording with a hold rule, the building or fading tone on the histogram, and the plain table that puts all of it into words. The combination exists so that one look answers "is there momentum, how much, and is it still growing" without interpreting a line chart. The idea of grading momentum against its recent range was inspired by the open-source "Momentum Shift" by BigBeluga, the four tone histogram by the open-source "Momentum Ghost Machine" by ChartPrime. No code from either script is used.

LIMITATIONS

Momentum is measured from closed bars and lags the price by design. Strength is relative to the last year: after a quiet year an ordinary move can read as strong, after a wild year a decent move can read as weak. On symbols with fewer than 252 bars of history the scale uses whatever history exists. The state hold rule delays every state change by the chosen number of bars. This script works on any symbol and any timeframe, but the default lengths were chosen for daily charts of stocks.

Trading stocks can cost you everything you put in. This script is a measurement, not advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6

// Blue Sky Breakout Momentum  |  build 2026-09-25
//
// Shows whether the chart has momentum right now, and how much of it.
// The core is the Price Momentum Oscillator (PMO), a twice smoothed rate
// of change taken from the public TradingView "ta" library. Its strength
// is measured against the oscillator's own largest swing of the last
// twelve months, so 100 % means "as strong as it has been all year".
//
// Every colour is a measured past, never a forecast. This script gives
// no advice: no entries, no exits, no targets. Trading stocks can cost
// you everything you put in.
//
// ── Description draft for the publication (English, self-contained) ──
//
// WHAT IT DOES
// A momentum reading in five plain words: Strong up, Up, Flat, Down,
// Strong down. Plus a strength figure from -100 % to +100 %, a histogram
// that tells you whether the move is building or fading, and a table.
//
// HOW IT WORKS
// 1. PMO = a rate of change smoothed twice (35 and 20 bars), with a
//    10 bar signal line. Taken from the TradingView/ta library.
// 2. Strength = PMO divided by the largest absolute PMO value of the
//    last 252 bars. This makes the reading comparable across symbols.
// 3. State: below 20 % strength the chart is Flat. From 60 % it is
//    Strong. A state counts only after it has held for two bars.
// 4. Histogram = PMO minus its signal line. Deep tone while the gap
//    widens (building), light tone while it narrows (fading).
//
// HOW TO USE IT
// Read the table: Momentum tells the state, Strength the size, Histogram
// whether it is building or fading, In state for how long. The candles
// take the colour of the state. Nothing here is a signal.
//
// WHY IT IS ORIGINAL
// The PMO is a standard oscillator. What is new is the year-relative
// strength scale, the five state wording with a confirmation rule, and
// the building/fading tone on the histogram, all in one small panel.
// Inspired by the strength-gradient idea in "Momentum Shift" by BigBeluga
// and the four tone histogram in "Momentum Ghost Machine" by ChartPrime.
// No code from either script is reused.
//
// LIMITATIONS
// Momentum is measured from closed bars. It lags. Strength is relative to
// the last year, so a quiet year makes ordinary moves look strong. On
// symbols with fewer than 252 bars the scale uses whatever history exists.

indicator("Blue Sky Breakout Momentum", shorttitle = "BSB Momentum", overlay = false,
     max_labels_count = 50)

import TradingView/ta/11 as TVta

// ── Settings ─────────────────────────────────────────────────────────
gCore = "Momentum"
srcInput = input.source(close, "Source", group = gCore)
lenOne = input.int(35, "Smoothing one", minval = 1, group = gCore,
     tooltip = "First smoothing length of the PMO. Higher is slower and calmer.")
lenTwo = input.int(20, "Smoothing two", minval = 1, group = gCore,
     tooltip = "Second smoothing length of the PMO.")
lenSig = input.int(10, "Signal line", minval = 1, group = gCore,
     tooltip = "EMA length of the signal line. The histogram is PMO minus this line.")
rangeLen = input.int(252, "Strength measured against the last N bars", minval = 20, group = gCore,
     tooltip = "252 daily bars is one year. Strength = PMO / largest PMO swing in this window.")

gState = "State"
flatLevel = input.int(20, "Flat below this strength (%)", minval = 0, maxval = 100, group = gState)
strongLevel = input.int(60, "Strong from this strength (%)", minval = 1, maxval = 100, group = gState)
confirmBars = input.int(2, "Bars a state must hold before it counts", minval = 1, group = gState,
     tooltip = "Filters one bar flickers between states.")

gPane = "Pane"
showHist = input.bool(true, "Histogram: PMO minus signal", group = gPane)
showSignal = input.bool(true, "Signal line", group = gPane)
showFlatZone = input.bool(true, "Flat zone around zero", group = gPane)
showArea = input.bool(true, "Coloured background by state", group = gPane)
areaStrength = input.float(0.32, "Background strength", minval = 0.05, maxval = 1.0, step = 0.02, group = gPane,
     tooltip = "How strongly the pane is tinted.")

gChart = "Chart"
colourCandles = input.bool(true, "Colour the candles by state", group = gChart)
markStrong = input.bool(true, "Mark the candle where a strong state begins", group = gChart)
showTable = input.bool(true, "Show the figures table", group = gChart)
tablePos = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gChart)

// Every symbol, no limit.
allowed = true

// ── The oscillator and its strength ──────────────────────────────────
[pmo, sig] = TVta.pmo(srcInput, lenOne, lenTwo, lenSig)
hist = pmo - sig

peak = math.max(math.abs(ta.highest(pmo, rangeLen)), math.abs(ta.lowest(pmo, rangeLen)))
strength = na(pmo) or na(peak) or peak == 0 ? na : pmo / peak * 100
mag = math.abs(strength)

// ── The state: 2 strong up, 1 up, 0 flat, -1 down, -2 strong down ────
rawState = na(strength) ? 0
     : mag < flatLevel ? 0
     : strength > 0 ? (mag >= strongLevel ? 2 : 1)
     : (mag >= strongLevel ? -2 : -1)

rawChanged = nz(ta.change(rawState)) != 0
heldFor = ta.barssince(rawChanged)

var int state = 0
if nz(heldFor, confirmBars) + 1 >= confirmBars
    state := rawState

barsInState = nz(ta.barssince(nz(ta.change(state)) != 0)) + 1

strongStartUp = state == 2 and state[1] != 2
strongStartDn = state == -2 and state[1] != -2
strongEnded = (state[1] == 2 or state[1] == -2) and state != 2 and state != -2

// Building: the histogram widens in the direction of the state.
building = state > 0 ? hist > 0 and hist >= hist[1]
     : state < 0 ? hist < 0 and hist <= hist[1]
     : false

// ── Colours ──────────────────────────────────────────────────────────
tone(v) =>
    m = math.abs(v)
    na(v) ? color.gray
         : v >= 0
             ? (m < flatLevel ? #86efac : m < strongLevel ? #22c55e : #15803d)
             : (m < flatLevel ? #fca5a5 : m < strongLevel ? #ef4444 : #b91c1c)

stateColour = switch state
    2 => #15803d
    1 => #22c55e
    -1 => #ef4444
    -2 => #b91c1c
    => color.gray

histColour = hist >= 0
     ? (hist >= hist[1] ? #22c55e : #86efac)
     : (hist <= hist[1] ? #ef4444 : #fca5a5)

area(s) =>
    grade = (math.min(math.abs(s) / 2.0, 1.0) * 0.64 + 0.06) * areaStrength
    s == 0 ? color.new(color.gray, 100)
         : (s > 0 ? color.rgb(34, 197, 94, math.round((1 - grade) * 100))
                  : color.rgb(239, 68, 68, math.round((1 - grade) * 100)))

plus(v) => v >= 0 ? "+" : "-"
pct(x) => na(x) ? "-" : plus(x) + str.tostring(math.round(math.abs(x))) + " %"

stateText = switch state
    2 => "Strong up"
    1 => "Up"
    -1 => "Down"
    -2 => "Strong down"
    => "Flat"

// ── Pane ─────────────────────────────────────────────────────────────
hline(0, "Zero", color = color.new(color.gray, 40))

flatEdge = showFlatZone and not na(peak) ? peak * flatLevel / 100 : na
pFlatHi = plot(flatEdge, "Flat zone upper", color = color.new(color.gray, 100))
pFlatLo = plot(-flatEdge, "Flat zone lower", color = color.new(color.gray, 100))
fill(pFlatHi, pFlatLo, color = color.new(color.gray, 86), title = "Flat zone")

bgcolor(allowed and showArea ? area(state) : na, title = "State background")

plot(showHist ? hist : na, "Histogram", color = histColour, style = plot.style_columns)
plot(pmo, "PMO", color = stateColour, linewidth = 2)
plot(showSignal ? sig : na, "Signal", color = color.new(color.gray, 20))

// ── Chart ────────────────────────────────────────────────────────────
barcolor(allowed and colourCandles ? stateColour : na, title = "Candles by state")

if allowed and markStrong and strongStartUp
    label.new(bar_index, low, "Strong up", style = label.style_label_up,
         color = color.new(#15803d, 10), textcolor = color.white, size = size.small, force_overlay = true)

if allowed and markStrong and strongStartDn
    label.new(bar_index, high, "Strong down", style = label.style_label_down,
         color = color.new(#b91c1c, 10), textcolor = color.white, size = size.small, force_overlay = true)

// ── Table ────────────────────────────────────────────────────────────
place = switch tablePos
    "Top right" => position.top_right
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left

var table tbl = table.new(place, 2, 6, border_width = 1, border_color = color.new(color.gray, 60), force_overlay = true)
dark = color.new(color.black, 70)
blue = color.new(#2563EB, 0)

if barstate.islast and showTable
    table.cell(tbl, 0, 0, "Blue Sky Breakout", text_color = color.white, bgcolor = blue, text_size = size.normal)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color = color.white, bgcolor = blue, text_size = size.normal)

    table.cell(tbl, 0, 1, "Momentum", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 1, stateText, text_color = color.white, bgcolor = stateColour, text_size = size.small)
    table.cell(tbl, 0, 2, "Strength", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 2, pct(strength), text_color = color.white, bgcolor = tone(strength), text_size = size.small)
    table.cell(tbl, 0, 3, "Histogram", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 3, state == 0 ? "-" : building ? "Building" : "Fading", text_color = color.white,
         bgcolor = state == 0 ? color.gray : building ? stateColour : color.new(stateColour, 50), text_size = size.small)
    table.cell(tbl, 0, 4, "In state", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(barsInState) + " bars", text_color = color.white, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 0, 5, "PMO vs signal", text_color = color.gray, bgcolor = dark, text_size = size.small)
    table.cell(tbl, 1, 5, na(hist) ? "-" : hist >= 0 ? "Above" : "Below", text_color = color.white,
         bgcolor = na(hist) ? color.gray : hist >= 0 ? #22c55e : #ef4444, text_size = size.small)

// ── Alerts on measured changes only ──────────────────────────────────
crossUp = ta.crossover(pmo, 0)
crossDn = ta.crossunder(pmo, 0)

alertcondition(allowed and crossUp, title = "PMO crossed above zero", message = "{{ticker}}: momentum crossed above zero (Blue Sky Breakout).")
alertcondition(allowed and crossDn, title = "PMO crossed below zero", message = "{{ticker}}: momentum crossed below zero (Blue Sky Breakout).")
alertcondition(allowed and strongStartUp, title = "Momentum turned strong up", message = "{{ticker}}: momentum is strong up (Blue Sky Breakout).")
alertcondition(allowed and strongStartDn, title = "Momentum turned strong down", message = "{{ticker}}: momentum is strong down (Blue Sky Breakout).")
alertcondition(allowed and strongEnded, title = "Strong momentum ended", message = "{{ticker}}: strong momentum has ended (Blue Sky Breakout).")
````
