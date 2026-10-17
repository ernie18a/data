# MACD RSI Signal [XWiseTrade]

- url: https://www.tradingview.com/script/UE8s4s3K-MACD-RSI-Signal-XWiseTrade/
- type: indicator
- pine_id: PUB;192564df6e6243c59b218eb4880c7700
- version: 1.0

## Description

[b]MACD RSI Signal[/b]
The classic MACD settings — 12, 26, 9 — were chosen decades ago for daily stock charts, where they roughly meant "half a month, one month, and a week." Almost everyone then copies those exact numbers onto 5-minute, 15-minute and hourly charts, where they no longer correspond to anything meaningful. This indicator rebuilds the MACD/RSI combination for intraday trading, with periods anchored to how the global trading day is actually structured, and with RSI graded in zones rather than a single overbought/oversold line.

[b]Why simple moving averages, not exponential[/b]
Most MACD implementations use exponential moving averages, which deliberately weight recent bars more heavily than older ones. That weighting is a built-in assumption — that the latest price matters more. This indicator uses simple moving averages instead: every bar in the window counts equally. The result is a less manipulated, more faithful read of raw price action, with no human assumption about which bars "should" matter more. For intraday decisions, that neutrality lets the price structure speak for itself rather than through a weighting curve.

[b]Why the periods are 12 / 24 / 8[/b]
Read on the 1-hour scale these map to real session structure: 12 ≈ the split between the Euro/US half of the day and the rest; 24 ≈ a full intraday higher-timeframe day; 8 ≈ the length of a single major session (London, New York, Asia). The point isn't that these numbers are magic — it's that the original 12/26/9 only ever made sense as "days," and on intraday charts that meaning is lost. Anchoring to sessions restores a reason for the numbers. You can apply it to higher or lower timeframes, but the 1-hour scale is its reference point.

[b]How the signal is graded[/b]
A signal is not a single MACD cross. It requires momentum to be persisting: the MACD histogram must be positive and expanding for a bull case (negative and expanding for a bear case) — momentum actually accelerating, not a one-bar cross that fades.
RSI then grades that momentum, using zones based on familiar ratios (0.214 / 0.382 / 0.618 / 0.786) instead of plain 30/70 — finer resolution for intraday work:
[list]
[*]Pass (solid Bull/Bear) — RSI between 0.382 and 0.618 (38.2–61.8): healthy core, room to run.
[*]Warning (small marker) — RSI outside that core but not extreme: momentum persists, but the move is stretched — lower quality.
[*]Veto (no signal) — RSI beyond 0.786 or below 0.214: too extreme, the signal is rejected rather than shown.
[/list]

[b]How to use it[/b]
Add it to a chart — built for intraday, with the 1-hour scale as the reference. Solid Bull/Bear labels are momentum that passed the RSI grade. Faint bull? / bear? markers are persisting momentum that RSI flagged as stretched — treat with caution. No label means the setup was either too weak or vetoed as overextended. The MACD here is built on simple (unweighted) moving averages rather than the usual exponential ones — every period is given equal weight, a more neutral read — and every zone bound is adjustable.

[b]What makes it different[/b]
Standard MACD+RSI scripts copy daily-era settings onto every timeframe and use RSI as a single yes/no filter. This one re-anchors the periods to real session structure for intraday use, defines a signal as persisting, expanding momentum rather than a momentary cross, lets RSI grade and veto that momentum across zones instead of a binary line, and uses unweighted moving averages so no single bar is given outsized influence.

Inputs: MACD fast/slow/signal,RSI length, Fibonacci-style zone bounds, cooldown.

These are descriptive signals for discretionary use, not buy/sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

//@version=6
indicator("MACD RSI Signal [XWiseTrade]", overlay=true, max_labels_count=500)

// ===== MACD inputs — session-anchored periods, SMA-based (calibrated on the 1H scale) =====
group_macd = "MACD (session-anchored, SMA)"
fastLen = input.int(12, "MACD fast", group=group_macd, tooltip="12 ~ the Euro/US vs non-Euro/US half of the global day, on the 1H scale")
slowLen = input.int(24, "MACD slow", group=group_macd, tooltip="24 ~ a full intraday higher-timeframe day")
sigLen  = input.int(8,  "MACD signal", group=group_macd, tooltip="8 ~ a major trading session (London/NY/Asia)")

// ===== RSI inputs — Fibonacci-style zoning instead of 30/70 =====
group_rsi = "RSI (Fibonacci zoning)"
rsiLen = input.int(24, "RSI length", group=group_rsi, tooltip="24 ~ aligned to the intraday HTF scale")
passLo = input.float(38.2, "Pass zone lower (0.382)", group=group_rsi)
passHi = input.float(61.8, "Pass zone upper (0.618)", group=group_rsi)
vetoLo = input.float(21.4, "Veto below (0.214)", group=group_rsi)
vetoHi = input.float(78.6, "Veto above (0.786)", group=group_rsi)

// ===== MACD (SMA-based, unweighted) =====
macdLine   = ta.sma(close, fastLen) - ta.sma(close, slowLen)
signalLine = ta.sma(macdLine, sigLen)
hist = macdLine - signalLine

// ===== "Persistence" = histogram positive AND expanding (momentum still accelerating) =====
bullPersist = hist > 0 and hist > hist[1]
bearPersist = hist < 0 and hist < hist[1]

// Only the first bar a persistence run begins (so we don't tag every bar of a trend)
bullStart = bullPersist and not bullPersist[1]
bearStart = bearPersist and not bearPersist[1]

// ===== RSI Fibonacci zones =====
rsi = ta.rsi(close, rsiLen)
rsiPass = rsi >= passLo and rsi <= passHi
rsiVeto = rsi >  vetoHi or  rsi <  vetoLo
rsiWarn = not rsiPass and not rsiVeto

// ===== Combine: MACD persistence graded by RSI zone =====
bullHigh = bullStart and rsiPass and not rsiVeto
bullWarn = bullStart and rsiWarn
bearHigh = bearStart and rsiPass and not rsiVeto
bearWarn = bearStart and rsiWarn

// ===== Labels =====
if bullHigh
    label.new(bar_index, low, "Bull", yloc=yloc.belowbar,
         color=color.new(color.teal,0), textcolor=color.white,
         style=label.style_label_up, size=size.small)
if bearHigh
    label.new(bar_index, high, "Bear", yloc=yloc.abovebar,
         color=color.new(color.red,0), textcolor=color.white,
         style=label.style_label_down, size=size.small)

if bullWarn
    label.new(bar_index, low, "bull?", yloc=yloc.belowbar,
         color=color.new(color.teal,55), textcolor=color.white,
         style=label.style_label_up, size=size.tiny,
         tooltip="Bull momentum persisting, but RSI outside the 0.382-0.618 pass zone - lower quality")
if bearWarn
    label.new(bar_index, high, "bear?", yloc=yloc.abovebar,
         color=color.new(color.red,55), textcolor=color.white,
         style=label.style_label_down, size=size.tiny,
         tooltip="Bear momentum persisting, but RSI outside the 0.382-0.618 pass zone - lower quality")

// ===== Alerts (high-quality only) =====
alertcondition(bullHigh, "High-quality Bull", "MACD bull momentum persisting with RSI in the 0.382-0.618 pass zone")
alertcondition(bearHigh, "High-quality Bear", "MACD bear momentum persisting with RSI in the 0.382-0.618 pass zone")
````
