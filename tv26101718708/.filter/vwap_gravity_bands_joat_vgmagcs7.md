# VWAP Gravity Bands [JOAT]

- url: https://www.tradingview.com/script/VgMagCS7-VWAP-Gravity-Bands-JOAT/
- type: indicator
- pine_id: PUB;8fd40c5ab4324c11a0a3fec598c6638b
- version: 1.0

## Description

VWAP Gravity Bands is an open-source Pine Script v6 overlay that builds an anchored VWAP field with a smoothed T3 basis and ATR ladder bands. It is designed to show how far price has traveled from a session, weekly, or monthly value anchor, then classify that distance as center pull, ladder drift, expansion, or outer-band reaction.

The script is useful when a trader wants the chart to show both location and behavior around VWAP. Instead of a single VWAP line, it creates a full distance map around the anchor, colors candles by their distance from the basis, and highlights confirmed outer reactions without using arrow-style signal clutter.

[image]https://www.tradingview.com/x/CUk3QjtH/[/image]

[b]Core Concepts[/b]

[b]1. Anchored VWAP Selection[/b]

The anchor can reset on the session, week, or month. The script uses timeframe.change() to produce the reset pulse and ta.vwap() to calculate the anchored value.

[pine]
anchorTimeframe = anchorChoice == "Week" ? "1W" : anchorChoice == "Month" ? "1M" : "1D"
anchorPulse = timeframe.change(anchorTimeframe)
rawVwap = ta.vwap(sourceInput, anchorPulse)
[/pine]

[b]2. T3 Basis Smoothing[/b]

Raw anchored VWAP can move sharply at the beginning of an anchor period. VWAP Gravity Bands runs that value through a T3-style smoother to create a cleaner basis while preserving responsiveness.

[pine]
e1 = ta.ema(src, length)
e2 = ta.ema(e1, length)
e3 = ta.ema(e2, length)
basis = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3
[/pine]

[b]3. ATR Ladder Bands[/b]

The band ladder is based on ATR, not fixed percentages. This lets the distance field expand and contract with the market's current movement range.

[pine]
ladderUnit = atr * bandStep
upperOne = basis + ladderUnit
lowerOne = basis - ladderUnit
upperThree = basis + ladderUnit * 3.0
lowerThree = basis - ladderUnit * 3.0
[/pine]

[b]4. Distance State Model[/b]

Distance from VWAP is normalized by the ladder unit. The script classifies large directional continuation as expansion and failed outer-band tests as reactions.

[b]5. Gradient Candle Coloring[/b]

Candles can be colored by their normalized distance from VWAP. This helps identify when price is balanced around the anchor, drifting away from it, or stretched toward an outer band.

[b]Features[/b]

[list]
[*][b]Session, weekly, or monthly anchor:[/b] Select the VWAP reset period from inputs
[*][b]T3-smoothed VWAP basis:[/b] Cleaner centerline for visual trend and location analysis
[*][b]ATR ladder bands:[/b] Three upper and lower bands scale with current volatility
[*][b]Expansion state detection:[/b] Highlights directional movement away from the basis
[*][b]Outer reaction detection:[/b] Marks confirmed failed tests near the outer ladder
[*][b]Distance candle mode:[/b] Optional gradient candles based on normalized VWAP distance
[*][b]Dashboard:[/b] Shows anchor, state, distance, ATR step, and basis slope
[*][b]Alert conditions:[/b] Upper reaction, lower reaction, upper expansion, and lower expansion
[/list]

[b]Input Parameters[/b]

[b]Visual System:[/b]
[list]
[*]Palette Preset: Selects color pair
[*]Distance Candles: Enables candle coloring by VWAP distance
[*]Dashboard: Shows top-right state panel
[*]Raw VWAP: Displays the unsmoothed anchored VWAP
[*]Outer Reaction Marks: Shows compact TP-style outer reaction markers
[/list]

[b]VWAP Gravity:[/b]
[list]
[*]Anchor: Session, Week, or Month
[*]Source: Price source used for VWAP
[*]T3 Basis Length: Smoothing length for the VWAP basis
[*]T3 Factor: Controls T3 smoothness
[*]ATR Length: Volatility length used for ladder distance
[*]ATR Step: Distance between ladder bands
[*]Expansion Step: Threshold for expansion classification
[*]Reaction Step: Threshold for outer reaction classification
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Choose the Anchor[/b]
Use Session for intraday context, Week for swing context, and Month for broader value location.

[b]Step 2: Read Distance From Basis[/b]
The dashboard distance value shows how many ladder units price is away from the smoothed VWAP basis.

[b]Step 3: Separate Expansion From Reaction[/b]
Expansion means price is moving away from VWAP with slope confirmation. Reaction means price tested an outer area and closed back inside.

[b]Step 4: Use the Bands as Context[/b]
The bands are not automatic entry levels. They show location. Combine them with market structure, candle behavior, and risk planning.

[b]Indicator Limitations[/b]

[list]
[*]VWAP is volume-based and may behave differently on symbols with sparse volume
[*]The first bars after a new anchor can be less stable because VWAP is starting a new sample
[*]Reaction markers show a confirmed close back inside a zone, not a future reversal forecast
[*]ATR bands adapt to volatility but can widen quickly after large bars
[/list]

[b]Originality Statement[/b]

VWAP Gravity Bands is original in how it combines anchored VWAP selection, T3 smoothing, ATR ladder geometry, distance-colored candles, and separate expansion/reaction states. It is built from public Pine v6 functions and original logic rather than copied indicator source.

[b]Disclaimer[/b]

This script is provided for educational and informational use only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. VWAP location and band reactions can fail in trending, news-driven, or low-liquidity markets. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("VWAP Gravity Bands [JOAT]", overlay = true, max_labels_count = 100, max_lines_count = 100)

string groupVisual = "Visual System"
string palettePreset = input.string("VWAP Field", "Palette Preset", options = ["Aqua Rose", "Neon Desk", "Mint Pulse", "VWAP Field"], group = groupVisual)
bool showCandles = input.bool(true, "Distance Candles", group = groupVisual)
bool showDashboard = input.bool(true, "Dashboard", group = groupVisual)
bool showRawVwap = input.bool(false, "Raw VWAP", group = groupVisual)
bool showReactions = input.bool(true, "Outer Reaction Marks", group = groupVisual)

string groupVwap = "VWAP Gravity"
string anchorChoice = input.string("Session", "Anchor", options = ["Session", "Week", "Month"], group = groupVwap)
sourceInput = input.source(hlc3, "Source", group = groupVwap)
int t3Length = input.int(8, "T3 Basis Length", minval = 2, maxval = 100, group = groupVwap)
float t3Factor = input.float(0.62, "T3 Factor", minval = 0.10, maxval = 0.95, step = 0.01, group = groupVwap)
int atrLength = input.int(21, "ATR Length", minval = 2, maxval = 200, group = groupVwap)
float bandStep = input.float(0.85, "ATR Step", minval = 0.10, maxval = 5.00, step = 0.05, group = groupVwap)
float expansionStep = input.float(2.0, "Expansion Step", minval = 1.0, maxval = 3.0, step = 0.25, group = groupVwap)
float reactionStep = input.float(2.6, "Reaction Step", minval = 1.5, maxval = 4.0, step = 0.25, group = groupVwap)

f_palette(string preset) =>
    color bull = switch preset
        "Aqua Rose" => color.rgb(0, 200, 255)
        "Neon Desk" => color.rgb(0, 255, 0)
        "Mint Pulse" => color.rgb(0, 255, 213)
        => color.rgb(26, 194, 0)
    color bear = switch preset
        "Aqua Rose" => color.rgb(255, 0, 93)
        "Neon Desk" => color.rgb(255, 0, 0)
        "Mint Pulse" => color.rgb(255, 0, 102)
        => color.rgb(255, 64, 64)
    [bull, bear]

f_clamp(float value, float low, float high) =>
    math.max(low, math.min(high, value))

f_t3(float src, int length, float factor) =>
    float e1 = ta.ema(src, length)
    float e2 = ta.ema(e1, length)
    float e3 = ta.ema(e2, length)
    float e4 = ta.ema(e3, length)
    float e5 = ta.ema(e4, length)
    float e6 = ta.ema(e5, length)
    float v2 = factor * factor
    float v3 = v2 * factor
    float c1 = -v3
    float c2 = 3.0 * v2 + 3.0 * v3
    float c3 = -6.0 * v2 - 3.0 * factor - 3.0 * v3
    float c4 = 1.0 + 3.0 * factor + 3.0 * v2 + v3
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

[bullBase, bearBase] = f_palette(palettePreset)
color quiet = color.rgb(148, 154, 166)

string anchorTimeframe = switch anchorChoice
    "Week" => "1W"
    "Month" => "1M"
    => "1D"

bool anchorPulse = timeframe.change(anchorTimeframe)
float rawVwap = ta.vwap(sourceInput, anchorPulse)
float vwapSeed = nz(rawVwap, sourceInput)
float basis = f_t3(vwapSeed, t3Length, t3Factor)
float atr = math.max(ta.atr(atrLength), syminfo.mintick * 10.0)
float ladderUnit = atr * bandStep

float upperOne = basis + ladderUnit
float lowerOne = basis - ladderUnit
float upperTwo = basis + ladderUnit * 2.0
float lowerTwo = basis - ladderUnit * 2.0
float upperThree = basis + ladderUnit * 3.0
float lowerThree = basis - ladderUnit * 3.0

float distance = (close - basis) / ladderUnit
float distanceCap = f_clamp(distance, -3.0, 3.0)
float distanceAbs = math.abs(distance)
float basisSlope = basis - nz(basis[1], basis)
bool expansionUp = barstate.isconfirmed and close > basis + ladderUnit * expansionStep and basisSlope > 0 and distance > nz(distance[1], distance)
bool expansionDown = barstate.isconfirmed and close < basis - ladderUnit * expansionStep and basisSlope < 0 and distance < nz(distance[1], distance)
bool upperReaction = barstate.isconfirmed and high >= basis + ladderUnit * reactionStep and close < basis + ladderUnit * reactionStep
bool lowerReaction = barstate.isconfirmed and low <= basis - ladderUnit * reactionStep and close > basis - ladderUnit * reactionStep
bool meanRevertHigh = upperReaction or (barstate.isconfirmed and high >= upperTwo and close < upperTwo and basisSlope <= atr * 0.05)
bool meanRevertLow = lowerReaction or (barstate.isconfirmed and low <= lowerTwo and close > lowerTwo and basisSlope >= -atr * 0.05)

string stateText = expansionUp ? "Upper Expansion" : expansionDown ? "Lower Expansion" : meanRevertHigh ? "High Mean-Revert" : meanRevertLow ? "Low Mean-Revert" : distanceAbs <= 0.55 ? "Center Pull" : "Ladder Drift"
color distanceColor = color.from_gradient(distanceCap, -3.0, 3.0, bearBase, bullBase)
color stateColor = expansionUp or meanRevertLow ? bullBase : expansionDown or meanRevertHigh ? bearBase : quiet
float gradientWeight = f_clamp(distanceAbs / 3.0, 0.0, 1.0)
color upperBandColor = color.from_gradient(gradientWeight, 0.0, 1.0, color.new(bullBase, 78), color.new(bullBase, 8))
color lowerBandColor = color.from_gradient(gradientWeight, 0.0, 1.0, color.new(bearBase, 78), color.new(bearBase, 8))

plot(showRawVwap ? rawVwap : na, "Raw Anchored VWAP", color = color.new(quiet, 35), linewidth = 1)
plot(basis, "T3 VWAP Basis", color = color.new(distanceColor, 0), linewidth = 2)
plotUpperOne = plot(upperOne, "Upper Band 1", color = color.new(upperBandColor, 42), linewidth = 1)
plotLowerOne = plot(lowerOne, "Lower Band 1", color = color.new(lowerBandColor, 42), linewidth = 1)
plotUpperTwo = plot(upperTwo, "Upper Band 2", color = color.new(upperBandColor, 28), linewidth = 1)
plotLowerTwo = plot(lowerTwo, "Lower Band 2", color = color.new(lowerBandColor, 28), linewidth = 1)
plotUpperThree = plot(upperThree, "Upper Band 3", color = color.new(upperBandColor, 8), linewidth = 1)
plotLowerThree = plot(lowerThree, "Lower Band 3", color = color.new(lowerBandColor, 8), linewidth = 1)

fill(plotUpperOne, plotUpperTwo, color = color.new(upperBandColor, 91), title = "Upper Ladder Fill 1")
fill(plotUpperTwo, plotUpperThree, color = color.new(upperBandColor, 84), title = "Upper Ladder Fill 2")
fill(plotLowerOne, plotLowerTwo, color = color.new(lowerBandColor, 91), title = "Lower Ladder Fill 1")
fill(plotLowerTwo, plotLowerThree, color = color.new(lowerBandColor, 84), title = "Lower Ladder Fill 2")
fill(plotUpperOne, plotLowerOne, color = color.new(distanceColor, 94), title = "Center Gravity Fill")

plotshape(showReactions and upperReaction ? high + atr * 0.12 : na, "Upper Reaction TP", text = "TP", style = shape.circle, location = location.absolute, color = color.new(bearBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showReactions and lowerReaction ? low - atr * 0.12 : na, "Lower Reaction TP", text = "TP", style = shape.circle, location = location.absolute, color = color.new(bullBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showReactions and expansionUp ? upperThree : na, "Upper Expansion Mark", text = "EX", style = shape.diamond, location = location.absolute, color = color.new(bullBase, 0), textcolor = color.white, size = size.tiny)
plotshape(showReactions and expansionDown ? lowerThree : na, "Lower Expansion Mark", text = "EX", style = shape.diamond, location = location.absolute, color = color.new(bearBase, 0), textcolor = color.white, size = size.tiny)

color candleColor = color.new(distanceColor, distanceAbs < 0.20 ? 32 : 6)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na, "Distance Candle Color", color = candleColor, wickcolor = color.new(distanceColor, 0), bordercolor = color.new(distanceColor, 0))

var table dash = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 88), frame_color = color.new(color.gray, 70), frame_width = 1, border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "VWAP", text_color = color.white, text_size = size.small, bgcolor = color.new(stateColor, 75))
    table.cell(dash, 1, 0, anchorChoice, text_color = color.white, text_size = size.small, bgcolor = color.new(stateColor, 75))
    table.cell(dash, 0, 1, "State", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 1, stateText, text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 2, "Distance", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(distance, "#.##") + "x", text_color = distanceColor, text_size = size.small)
    table.cell(dash, 0, 3, "ATR Step", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 3, str.tostring(ladderUnit, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 4, "Slope", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 4, str.tostring(basisSlope, format.mintick), text_color = stateColor, text_size = size.small)

alertcondition(barstate.isconfirmed and upperReaction, "Upper Reaction [JOAT]", "VWAP Gravity Bands [JOAT]: confirmed upper outer-band reaction.")
alertcondition(barstate.isconfirmed and lowerReaction, "Lower Reaction [JOAT]", "VWAP Gravity Bands [JOAT]: confirmed lower outer-band reaction.")
alertcondition(barstate.isconfirmed and expansionUp, "Upper Expansion [JOAT]", "VWAP Gravity Bands [JOAT]: confirmed upper expansion state.")
alertcondition(barstate.isconfirmed and expansionDown, "Lower Expansion [JOAT]", "VWAP Gravity Bands [JOAT]: confirmed lower expansion state.")
````
