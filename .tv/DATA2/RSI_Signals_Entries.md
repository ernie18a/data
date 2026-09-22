<!-- tradingview-pine-id: PUB;8cfebc3bf30e4aacbcd660357f036453 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Signals Entries

Source: https://www.tradingview.com/script/MXaEHFCb-RSI-Signals-Entries/

## Description

RSI Signals Entries — Publish Description
What This Indicator Is
RSI Signals Entries is a four-level Relative Strength Index (RSI) tool built to turn the classic overbought/oversold RSI reading into a clear, actionable signal system. Instead of a plain single-line RSI, it plots a colour-coded RSI with four defined levels — Over Buy, Resistance, Support, and Over Sold — and automatically marks potential Sell and Buy opportunities both on the RSI pane itself and directly on the price candles, together with a fixed confidence "Strength %" label for every signal.
Why It Was Built
Reading raw RSI values and deciding when a reading is "extreme enough" to act on is subjective and inconsistent from one trader to another. This script removes that guesswork by defining four fixed levels up front and applying two distinct, repeatable rules on top of them: a pure RSI-extreme rule for the strongest, highest-confidence reversals, and a level-plus-candle-confirmation rule for slightly less extreme readings that still show real rejection at a key zone. Every signal is labelled with the same fixed strength value every time it appears, so the trader always knows which of the two rules produced it.
How It Works
The four RSI levels
Over Buy: 79.90
Resistance: 67.90
Support: 34.90
Over Sold: 19.90
The RSI line itself changes colour depending on which zone it is currently in (Over Buy, Resistance, neutral, Support, or Over Sold), so the current market condition is visible at a glance without reading the exact number.
The strong-candle filter
A candle only counts as "strong" when its body (the distance between open and close, not counting wicks) is at least a chosen multiple of the average candle body size over a recent lookback period. This stops the indicator from reacting to small, indecisive candles.
The two signal rules
Extreme rule (Over Buy / Over Sold): whenever RSI reaches the Over Buy or Over Sold level, a signal fires immediately with a fixed Strength of 80%. No candle confirmation is required, because the RSI reading itself is already at its most extreme.
Zone-confirmation rule (Resistance / Support): whenever RSI is sitting inside the Resistance zone (between Resistance and Over Buy) or the Support zone (between Over Sold and Support) and a strong candle closes in the reversal direction, a signal fires with a fixed Strength of 70%. This rule needs the extra candle confirmation because the RSI reading on its own is not yet at a true extreme.
Every signal is plotted twice: once on the RSI pane at the exact RSI value where it fired, and once on the price chart directly above or below the triggering candle, so the same event can be read from either view. Each chart-side signal also draws an Entry line, a Stop-Loss line, and a Take-Profit line at a configurable pip distance, so the trade plan is visible the moment the signal appears.
Step-by-Step: How to Take Each Entry
1. Over Buy entry (Sell, 80% strength)
Watch the RSI line rise into the Over Buy zone (79.90 and above).
The moment RSI reaches this level, a red downward triangle appears both on the RSI pane and above the corresponding candle on the price chart, labelled "80% Sell".
Enter a Sell position at or near the close of that candle.
Use the auto-plotted Entry / Stop-Loss / Take-Profit lines as your reference levels, or set your own stop just above the recent swing high and your target using your own risk-reward preference.

2. Resistance entry (Sell, 70% strength)
Watch the RSI line move up into the Resistance zone (between 67.90 and 79.90), without yet reaching Over Buy.
Wait for a strong bearish candle to close while RSI is still inside this zone — this is the rejection confirmation the rule requires.
Once that candle closes, a red downward triangle appears on both the RSI pane and the price chart, labelled "70% Sell".
Enter a Sell position at or near the close of that confirming candle, using the plotted Entry / Stop-Loss / Take-Profit lines as your reference.

3. Over Sold entry (Buy, 80% strength)
Watch the RSI line fall into the Over Sold zone (19.90 and below).
The moment RSI reaches this level, a green upward triangle appears both on the RSI pane and below the corresponding candle on the price chart, labelled "80% Buy".
Enter a Buy position at or near the close of that candle, using the plotted Entry / Stop-Loss / Take-Profit lines as your reference.

4. Support entry (Buy, 70% strength)
Watch the RSI line move down into the Support zone (between 19.90 and 34.90), without yet reaching Over Sold.
Wait for a strong bullish candle to close while RSI is still inside this zone — this is the rejection confirmation the rule requires.
Once that candle closes, a green upward triangle appears on both the RSI pane and the price chart, labelled "70% Buy".
Enter a Buy position at or near the close of that confirming candle, using the plotted Entry / Stop-Loss / Take-Profit lines as your reference.
Settings Worth Knowing Before Use
All four RSI levels, the RSI length and source, the strong-candle lookback and multiplier, the two fixed strength percentages, the pip size, and the Stop-Loss/Take-Profit pip distances are all adjustable from the indicator's settings panel to suit different instruments and trading styles.
The indicator calculates on any timeframe, but the default settings are tuned for fast, short-term signals on 1-minute and 5-minute charts. On higher timeframes, the pip-based Stop-Loss/Take-Profit distances should be widened accordingly.
"Wait for Candle Close" is enabled by default so that every signal shown is fully confirmed and will not repaint; disabling it produces faster but less reliable real-time signals.

Disclaimer
This indicator is a technical analysis tool and does not constitute financial advice. The Strength % values are fixed confidence labels describing which internal rule produced a given signal, not a statistical win-rate or a guarantee of outcome. All trading involves risk, and past performance of any signal or pattern does not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.
Original Script Declaration
Script Name: RSI Signals Entries
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: © Michael_Fx_Trader. All rights reserved.
Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The 4-level colored RSI zone engine, the zone-entry armed/fired signal state machine, the fixed-confidence Strength % labeling system, the dual chart + RSI-pane signal display, and the pip-based Entry / Stop-Loss / Take-Profit level drawing engine were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed-up, or reused in any part of this script.
Author Verification / Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. The Relative Strength Index (RSI) itself is a well-known, generic public-domain technical indicator (J. Welles Wilder) and is not owned by any individual author; only the zone/signal/labeling logic built around it here is original to this script.

---

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : RSI Signals Entries
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader. The 4-level colored RSI zone engine, the zone-entry
//   armed/fired signal state machine (used instead of a simple crossover so
//   that signals cannot be missed on fast intrabar moves), the fixed-confidence
//   Strength % labeling system, the dual chart + RSI-pane signal display, and
//   the pip-based Entry / Stop-Loss / Take-Profit level drawing engine were all
//   independently conceived and implemented for this publication. No
//   proprietary source code, private scripts, or copyrighted material
//   belonging to any other author has been copied, mashed-up, or reused in
//   any part of this script.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. The Relative Strength Index (RSI) itself is a
//   well-known, generic public-domain technical indicator (J. Welles Wilder)
//   and is not owned by any individual author; only the zone/signal/labeling
//   logic built around it here is original to this script.
// =============================================================================

indicator("RSI Signals Entries", shorttitle = "RSI SE", overlay = false, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
// NOTE ON TIMEFRAME
// =============================================================================
// This indicator calculates and fires signals on ANY chart timeframe, but the
// zone logic, strong-candle filter defaults, and pip-based Entry/SL/TP
// distances have been tuned primarily for fast, short-term signals on the
// 1-minute and 5-minute charts.

// =============================================================================
// INPUTS
// =============================================================================

grpRsi = "RSI Settings"
rsiLength      = input.int(14, "RSI Length", minval = 1, group = grpRsi)
rsiSource      = input.source(close, "RSI Source", group = grpRsi)
confirmOnClose = input.bool(true, "Wait for Candle Close (Confirmed Signals Only)", group = grpRsi,
     tooltip = "When enabled, signals only confirm once the current candle has fully closed. Disable for faster, but less reliable, real-time signals. Recommended ON for 1-min/5-min charts.")

grpLevels = "RSI Levels"
overBuyLevel    = input.float(79.90, "Over Buy Level",   minval = 50.0, maxval = 100.0, step = 0.10, group = grpLevels)
resistanceLevel = input.float(67.90, "Resistance Level", minval = 50.0, maxval = 100.0, step = 0.10, group = grpLevels)
supportLevel    = input.float(34.90, "Support Level",    minval = 0.0,  maxval = 50.0,  step = 0.10, group = grpLevels)
overSoldLevel   = input.float(19.90, "Over Sold Level",  minval = 0.0,  maxval = 50.0,  step = 0.10, group = grpLevels)

grpStrength = "Signal Strength (Fixed Confidence Levels)"
extremeStrength = input.float(80.0, "Strength % - Over Buy / Over Sold Signals", minval = 0.0, maxval = 100.0, step = 1.0, group = grpStrength,
     tooltip = "Displayed confidence label whenever RSI itself reaches the Over Buy or Over Sold line.")
zoneStrength    = input.float(70.0, "Strength % - Resistance / Support + Strong Candle Signals", minval = 0.0, maxval = 100.0, step = 1.0, group = grpStrength,
     tooltip = "Displayed confidence label whenever RSI is sitting in the Resistance or Support zone AND a strong candle confirms it.")

grpCandle = "Strong Candle Filter"
strongLookback   = input.int(20, "Average Body Lookback (bars)", minval = 5, maxval = 200, group = grpCandle)
strongMultiplier = input.float(1.2, "Strong Candle Multiplier (x average body)", minval = 1.0, step = 0.1, group = grpCandle,
     tooltip = "A candle is considered 'strong' when its body size is at least this many times the average body size over the lookback period. Lowered slightly by default so it fires reliably on smaller 5-minute candles.")

grpTrade = "Entry / Stop Loss / Take Profit (Pips)"
showTradeLevels  = input.bool(true, "Show Entry / SL / TP Lines on Chart", group = grpTrade)
pipSize          = input.float(0.0001, "Pip Size (e.g. 0.0001 for most FX pairs, 0.01 for JPY pairs)", minval = 0.00000001, group = grpTrade)
slPips           = input.int(70, "Stop Loss (pips)", minval = 1, group = grpTrade)
tpPips           = input.int(80, "Take Profit (pips)", minval = 1, group = grpTrade)
levelLengthBars  = input.int(15, "Entry/SL/TP Line Length (bars)", minval = 3, maxval = 100, group = grpTrade)

grpColors = "Colors"
colOverbought = input.color(color.new(color.red, 0),     "Over Buy Zone Color",   group = grpColors)
colResistance = input.color(color.new(color.orange, 0),  "Resistance Zone Color", group = grpColors)
colNeutral    = input.color(color.new(color.gray, 0),    "Neutral Zone Color",    group = grpColors)
colSupport    = input.color(color.new(color.blue, 0),    "Support Zone Color",    group = grpColors)
colOversold   = input.color(color.new(color.teal, 0),    "Over Sold Zone Color",  group = grpColors)
sellColor     = input.color(color.new(color.red, 0),     "Sell Signal Color",     group = grpColors)
buyColor      = input.color(color.new(color.lime, 0),    "Buy Signal Color",      group = grpColors)

// =============================================================================
// CONFIRMATION GATE
// =============================================================================

barReady = confirmOnClose ? barstate.isconfirmed : true

// =============================================================================
// RSI CALCULATION + COLORFUL MULTI-ZONE LINE
// =============================================================================

rsiValue = ta.rsi(rsiSource, rsiLength)

rsiColor = rsiValue >= overBuyLevel ? colOverbought :
     rsiValue >= resistanceLevel ? colResistance :
     rsiValue <= overSoldLevel ? colOversold :
     rsiValue <= supportLevel ? colSupport :
     colNeutral

plot(rsiValue, "RSI", color = rsiColor, linewidth = 2)

hline(overBuyLevel, "Over Buy", color = colOverbought, linestyle = hline.style_solid,  linewidth = 1)
hline(resistanceLevel, "Resistance", color = colResistance, linestyle = hline.style_dashed, linewidth = 1)
hline(50, "Midline", color = color.new(color.gray, 50), linestyle = hline.style_dotted, linewidth = 1)
hline(supportLevel, "Support", color = colSupport, linestyle = hline.style_dashed, linewidth = 1)
hline(overSoldLevel, "Over Sold", color = colOversold, linestyle = hline.style_solid, linewidth = 1)

fill(hline(overBuyLevel), hline(100), color = color.new(colOverbought, 90), title = "Over Buy Fill")
fill(hline(overSoldLevel), hline(0),  color = color.new(colOversold, 90),  title = "Over Sold Fill")

// =============================================================================
// STRONG CANDLE FILTER
// =============================================================================

bodySize = math.abs(close - open)
avgBody  = ta.sma(bodySize, strongLookback)

strongBearish = (close < open) and (bodySize >= avgBody * strongMultiplier)
strongBullish = (close > open) and (bodySize >= avgBody * strongMultiplier)

// =============================================================================
// SIGNAL LOGIC - ZONE-ENTRY STATE MACHINE
// =============================================================================
// Instead of relying on an exact crossover (which can be skipped on a fast
// 5-minute candle that gaps straight through a level), each zone tracks
// whether it is CURRENTLY occupied by RSI, and whether a signal has already
// FIRED for this particular visit to the zone. A signal can fire on ANY bar
// while RSI remains inside its zone (not just the very first bar it enters),
// which is what lets the Resistance/Support signals wait for their strong
// candle even if it forms a bar or two after RSI first reaches the zone. Once
// RSI leaves a zone, that zone "resets" and is ready to fire again on its
// next visit.
//
//   SELL signals only ever come from: Over Buy zone (pure touch) or
//                                      Resistance zone (+ strong bearish candle)
//   BUY  signals only ever come from: Over Sold zone (pure touch) or
//                                      Support zone (+ strong bullish candle)

inOverboughtZone = rsiValue >= overBuyLevel
inResistanceZone = (rsiValue >= resistanceLevel) and (rsiValue < overBuyLevel)
inSupportZone    = (rsiValue <= supportLevel) and (rsiValue > overSoldLevel)
inOversoldZone   = rsiValue <= overSoldLevel

var bool overboughtFired  = false
var bool resistanceFired  = false
var bool supportFired     = false
var bool oversoldFired    = false

// Reset each zone's "fired" flag as soon as RSI leaves that zone.
if not inOverboughtZone
    overboughtFired := false
if not inResistanceZone
    resistanceFired := false
if not inSupportZone
    supportFired := false
if not inOversoldZone
    oversoldFired := false

// ---- SELL conditions ---------------------------------------------------
sellSignalExtreme = barReady and inOverboughtZone and not overboughtFired
sellSignalZone    = barReady and inResistanceZone and strongBearish and not resistanceFired

// ---- BUY conditions ------------------------------------------------------
buySignalExtreme = barReady and inOversoldZone and not oversoldFired
buySignalZone    = barReady and inSupportZone and strongBullish and not supportFired

// Mark each zone as fired so it does not repeat every bar of the same visit.
if sellSignalExtreme
    overboughtFired := true
if sellSignalZone
    resistanceFired := true
if buySignalExtreme
    oversoldFired := true
if buySignalZone
    supportFired := true

finalSellSignal = sellSignalExtreme or sellSignalZone
finalBuySignal  = buySignalExtreme or buySignalZone

sellStrength = sellSignalExtreme ? extremeStrength : zoneStrength
buyStrength  = buySignalExtreme ? extremeStrength : zoneStrength

// =============================================================================
// SIGNAL MARKERS - SHOWN ON THE RSI PANE (at the RSI value itself)
// =============================================================================

plotshape(finalSellSignal ? rsiValue : na, title = "Sell Marker (RSI Pane)", style = shape.triangledown,
     location = location.absolute, color = sellColor, size = size.tiny)
plotshape(finalBuySignal ? rsiValue : na, title = "Buy Marker (RSI Pane)", style = shape.triangleup,
     location = location.absolute, color = buyColor, size = size.tiny)

// =============================================================================
// SIGNAL MARKERS - FORCED ONTO THE PRICE CHART (candles) + STRENGTH LABELS
// =============================================================================

plotshape(finalSellSignal, title = "Sell Signal (Chart)", style = shape.triangledown, location = location.abovebar,
     color = sellColor, size = size.small, force_overlay = true)
plotshape(finalBuySignal, title = "Buy Signal (Chart)", style = shape.triangleup, location = location.belowbar,
     color = buyColor, size = size.small, force_overlay = true)

atrForLabels = ta.atr(14)

if finalSellSignal
    label.new(bar_index, high + atrForLabels * 0.5, str.tostring(sellStrength, "#") + "% Sell",
         style = label.style_label_down, color = color.new(sellColor, 0), textcolor = color.white,
         size = size.small, force_overlay = true)

if finalBuySignal
    label.new(bar_index, low - atrForLabels * 0.5, str.tostring(buyStrength, "#") + "% Buy",
         style = label.style_label_up, color = color.new(buyColor, 0), textcolor = color.white,
         size = size.small, force_overlay = true)

// =============================================================================
// ENTRY / STOP-LOSS / TAKE-PROFIT LEVELS (PIP-BASED)
// =============================================================================

if showTradeLevels and finalSellSignal
    entryPrice = close
    slPrice    = entryPrice + slPips * pipSize
    tpPrice    = entryPrice - tpPips * pipSize
    line.new(bar_index, entryPrice, bar_index + levelLengthBars, entryPrice, color = color.new(color.white, 0), style = line.style_solid,  width = 1, force_overlay = true)
    line.new(bar_index, slPrice,    bar_index + levelLengthBars, slPrice,    color = color.new(color.red, 0),   style = line.style_dashed, width = 1, force_overlay = true)
    line.new(bar_index, tpPrice,    bar_index + levelLengthBars, tpPrice,    color = color.new(color.lime, 0),  style = line.style_dashed, width = 1, force_overlay = true)
    label.new(bar_index + levelLengthBars, entryPrice, "Entry", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.white, size = size.tiny, force_overlay = true)
    label.new(bar_index + levelLengthBars, slPrice,    "SL",    style = label.style_label_left, color = color.new(color.red, 100),   textcolor = color.red,   size = size.tiny, force_overlay = true)
    label.new(bar_index + levelLengthBars, tpPrice,    "TP",    style = label.style_label_left, color = color.new(color.lime, 100),  textcolor = color.lime,  size = size.tiny, force_overlay = true)

if showTradeLevels and finalBuySignal
    entryPrice = close
    slPrice    = entryPrice - slPips * pipSize
    tpPrice    = entryPrice + tpPips * pipSize
    line.new(bar_index, entryPrice, bar_index + levelLengthBars, entryPrice, color = color.new(color.white, 0), style = line.style_solid,  width = 1, force_overlay = true)
    line.new(bar_index, slPrice,    bar_index + levelLengthBars, slPrice,    color = color.new(color.red, 0),   style = line.style_dashed, width = 1, force_overlay = true)
    line.new(bar_index, tpPrice,    bar_index + levelLengthBars, tpPrice,    color = color.new(color.lime, 0),  style = line.style_dashed, width = 1, force_overlay = true)
    label.new(bar_index + levelLengthBars, entryPrice, "Entry", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.white, size = size.tiny, force_overlay = true)
    label.new(bar_index + levelLengthBars, slPrice,    "SL",    style = label.style_label_left, color = color.new(color.red, 100),   textcolor = color.red,   size = size.tiny, force_overlay = true)
    label.new(bar_index + levelLengthBars, tpPrice,    "TP",    style = label.style_label_left, color = color.new(color.lime, 100),  textcolor = color.lime,  size = size.tiny, force_overlay = true)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(finalSellSignal, title = "Sell Signal", message = "RSI Signals Entries: SELL signal fired.")
alertcondition(finalBuySignal,  title = "Buy Signal",  message = "RSI Signals Entries: BUY signal fired.")
alertcondition(sellSignalExtreme, title = "Over Buy Sell Signal", message = "RSI Signals Entries: RSI reached Over Buy - SELL signal (extreme strength).")
alertcondition(buySignalExtreme,  title = "Over Sold Buy Signal", message = "RSI Signals Entries: RSI reached Over Sold - BUY signal (extreme strength).")
alertcondition(sellSignalZone, title = "Resistance Sell Signal", message = "RSI Signals Entries: RSI in Resistance zone with a strong bearish candle - SELL signal.")
alertcondition(buySignalZone,  title = "Support Buy Signal",    message = "RSI Signals Entries: RSI in Support zone with a strong bullish candle - BUY signal.")
````
