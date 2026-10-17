# Extreme Reversal Channel [JOAT]

- url: https://www.tradingview.com/script/pgdqoA1Y-Extreme-Reversal-Channel-JOAT/
- type: indicator
- pine_id: PUB;edca6d6bd532415f8347f8df3927741d
- version: 1.0

## Description

[b]Extreme Reversal Channel [JOAT][/b]

[b]Introduction[/b]

Extreme Reversal Channel is an open-source adaptive channel that tracks persistent upper and lower extremes, gradually resets stale levels, and marks confirmed reversal conditions when price rejects a fresh extreme through the channel midpoint.

The problem it solves is stale channel context. Fixed lookback channels can jump abruptly as old bars roll out. Extreme Reversal Channel uses persistent state and controlled interpolation, creating smoother structural boundaries while still adapting to current price.

[image]https://www.tradingview.com/x/MYPvcssY/[/image]

[b]Core Concepts[/b]

[b]1. Persistent Extreme Tracking[/b]

The upper channel updates when a new high exceeds the current upper core. The lower channel updates when a new low breaks the current lower core.

[b]2. Counter-Based Reset[/b]

If no new extreme appears after the selected reset length, the stale level interpolates toward current price using the reset alpha setting.

[pine]
upperCore := upperCore * (1.0 - alpha) + high * alpha
lowerCore := lowerCore * (1.0 - alpha) + low  * alpha
[/pine]

[b]3. Midpoint Reversal Confirmation[/b]

A bullish reversal requires a fresh lower extreme and a confirmed close back above the midpoint. A bearish reversal requires a fresh upper extreme and a confirmed close back below the midpoint.

[b]4. Channel vs Trail Mode[/b]

Channel mode shows the upper, lower, and midpoint. Trail mode shows a single adaptive trailing reference derived from the current trend state.

[b]Features[/b]

[list]
[*][b]Adaptive upper/lower extremes:[/b] Persistent channel boundaries that update with new highs/lows
[*][b]Reset interpolation:[/b] Stale levels drift toward current price instead of disappearing abruptly
[*][b]Midpoint reversal logic:[/b] Reversal labels require closed-bar confirmation
[*][b]Gradient channel fills:[/b] Upper and lower channel regions are lightly shaded
[*][b]Optional trail mode:[/b] Converts the channel into a single adaptive stop reference
[*][b]Top-right dashboard:[/b] Trend, mode, width, price position, reset age, and signal state
[*][b]Alerts:[/b] Confirmed bullish and bearish reversal events
[/list]

[b]Input Parameters[/b]

[b]Channel:[/b]
[list]
[*]Reset Length: Bars allowed before an untouched extreme resets
[*]Reset Alpha: Interpolation speed toward current price
[*]Body Filter: Minimum candle body quality for reversal labels
[*]Trailing Mode: Switches from full channel to trail display
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Use the channel boundaries as adaptive structural extremes.
[b]Step 2:[/b] Watch for midpoint rejections after fresh extremes.
[b]Step 3:[/b] Use trail mode when you want a simpler directional reference.
[b]Step 4:[/b] Read price position and channel width in the dashboard before interpreting a reversal.

[b]Indicator Limitations[/b]

[list]
[*]Reversal labels can be early in strong breakout conditions
[*]Very narrow channels require caution because small moves can cross the midpoint easily
[*]The channel is adaptive context, not a complete trade system
[*]Signals are confirmed on closed bars and do not use future references
[/list]

[b]Originality Statement[/b]

Extreme Reversal Channel is original in its combination of persistent extreme tracking, reset interpolation, midpoint rejection logic, optional trail mode, and compact dashboard output. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is provided for educational and informational purposes only. It is not financial advice. Market conditions can invalidate reversal context, and risk management remains essential.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Extreme Reversal Channel [JOAT]", "ERC [JOAT]", overlay = true, max_labels_count = 200)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
color JOAT_BULL   = #089981
color JOAT_BEAR   = #f23645
color JOAT_TEXT   = #DBDBDB
color JOAT_MID    = #787b86
color JOAT_PANEL  = #161616
color JOAT_BORDER = #2E2E2E

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupChannel = "Channel"
resetLenInput = input.int(20, "Reset Length", minval = 1, group = groupChannel)
alphaInput = input.float(50.0, "Reset Alpha", minval = 0.0, maxval = 100.0, step = 1.0, group = groupChannel) / 100.0
bodyFilterInput = input.float(0.25, "Body Filter", minval = 0.0, maxval = 2.0, step = 0.05, group = groupChannel)
trailModeInput = input.bool(false, "Trailing Mode", group = groupChannel)

groupVisual = "Visuals"
showSignalsInput = input.bool(true, "Show Confirmed Reversals", group = groupVisual)
showChannelTintInput = input.bool(true, "Tint Candles By Channel State", group = groupVisual)
showDashInput = input.bool(true, "Show Dashboard", group = groupVisual)
dashPosInput = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = groupVisual)
dashSizeInput = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual)
upperInput = input.color(color.new(JOAT_BULL, 10), "Upper", group = groupVisual)
lowerInput = input.color(color.new(JOAT_BEAR, 10), "Lower", group = groupVisual)
midInput = input.color(color.new(JOAT_MID, 25), "Mid", group = groupVisual)
trailInput = input.color(color.new(#7f8c98, 30), "Trail", group = groupVisual)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
parsePos(string choice) =>
    switch choice
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

parseSize(string choice) =>
    switch choice
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.huge

var parsedDashSize = parseSize(dashSizeInput)

cell(table t, int c, int r, string txt, color txtColor, color bg, align) =>
    t.cell(c, r, txt, text_color = txtColor, bgcolor = bg, text_size = parsedDashSize, text_halign = align)

//------------------------------------------------------------------------------
// Persistent State
//------------------------------------------------------------------------------
var float upperCore = high
var float lowerCore = low
var int upperAge = 0
var int lowerAge = 0
var int trendState = 0

if bar_index == 0
    upperCore := high
    lowerCore := low

//------------------------------------------------------------------------------
// Adaptive Channel Engine
//------------------------------------------------------------------------------
bool newUpperExtreme = high >= upperCore
bool newLowerExtreme = low <= lowerCore

if newUpperExtreme
    upperCore := high
    upperAge := 0
    trendState := 1
else
    upperAge += 1
    if upperAge >= resetLenInput
        upperCore := upperCore * (1.0 - alphaInput) + high * alphaInput
        upperAge := 0

if newLowerExtreme
    lowerCore := low
    lowerAge := 0
    trendState := -1
else
    lowerAge += 1
    if lowerAge >= resetLenInput
        lowerCore := lowerCore * (1.0 - alphaInput) + low * alphaInput
        lowerAge := 0

float midLine = (upperCore + lowerCore) / 2.0
float channelRange = math.max(syminfo.mintick, upperCore - lowerCore)
float pricePos = (close - lowerCore) / channelRange * 100.0
float widthPct = channelRange / math.max(syminfo.mintick, lowerCore) * 100.0
float candleBody = math.abs(close - open) / math.max(syminfo.mintick, high - low)

bool bullishTurn = barstate.isconfirmed and newLowerExtreme and close > midLine and close > open and candleBody >= bodyFilterInput / 10.0
bool bearishTurn = barstate.isconfirmed and newUpperExtreme and close < midLine and close < open and candleBody >= bodyFilterInput / 10.0

if bullishTurn
    trendState := 1
if bearishTurn
    trendState := -1

string trendText = trendState == 1 ? "Bullish" : trendState == -1 ? "Bearish" : "Neutral"
color trendColor = trendState == 1 ? JOAT_BULL : trendState == -1 ? JOAT_BEAR : JOAT_TEXT
string modeText = trailModeInput ? "Trail" : "Channel"

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
plotTrail = trendState == 1 ? lowerCore : trendState == -1 ? upperCore : na

pTrail = plot(trailModeInput ? plotTrail : na, "Trail", color = trailInput, style = plot.style_stepline, linewidth = 2)
pUpper = plot(trailModeInput ? na : upperCore, "Upper", color = upperInput, style = plot.style_stepline, linewidth = 2)
pMid = plot(trailModeInput ? na : midLine, "Mid", color = midInput, style = plot.style_stepline, linewidth = 1)
pLower = plot(trailModeInput ? na : lowerCore, "Lower", color = lowerInput, style = plot.style_stepline, linewidth = 2)

fill(pUpper, pMid, color.new(upperInput, 88), title = "Upper Fill")
fill(pMid, pLower, color.new(lowerInput, 88), title = "Lower Fill")
pClose = plot(close, "Close Anchor", display = display.none)
fill(pTrail, pClose, color.new(trailInput, 90), title = "Trail Fill")
barcolor(showChannelTintInput ? color.new(trendColor, 78) : na, title = "Channel State Candle Tint")

if showSignalsInput and bullishTurn
    label.new(bar_index, low, "REV LONG", color = #00000000, textcolor = JOAT_BULL, style = label.style_label_up, size = size.small)
if showSignalsInput and bearishTurn
    label.new(bar_index, high, "REV SHORT", color = #00000000, textcolor = JOAT_BEAR, style = label.style_label_down, size = size.small)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var parsedDashPos = parsePos(dashPosInput)
var table dash = table.new(parsedDashPos, 2, 7, bgcolor = JOAT_PANEL, border_width = 0, frame_color = JOAT_BORDER, frame_width = 1)

if showDashInput and barstate.islast
    dash.merge_cells(0, 0, 1, 0)
    cell(dash, 0, 0, "Extreme Reversal Channel [JOAT]", JOAT_TEXT, JOAT_PANEL, text.align_center)

    cell(dash, 0, 1, "Trend", JOAT_MID, na, text.align_left)
    cell(dash, 1, 1, trendText, trendColor, na, text.align_right)

    cell(dash, 0, 2, "Mode", JOAT_MID, na, text.align_left)
    cell(dash, 1, 2, modeText, trailModeInput ? JOAT_BULL : JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 3, "Width", JOAT_MID, na, text.align_left)
    cell(dash, 1, 3, str.tostring(widthPct, "#.##") + "%", JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 4, "Price Position", JOAT_MID, na, text.align_left)
    cell(dash, 1, 4, str.tostring(pricePos, "#.##") + "%", pricePos >= 50.0 ? JOAT_BULL : JOAT_BEAR, na, text.align_right)

    cell(dash, 0, 5, "Reset Age", JOAT_MID, na, text.align_left)
    cell(dash, 1, 5, str.tostring(math.max(upperAge, lowerAge)), JOAT_TEXT, na, text.align_right)

    cell(dash, 0, 6, "Signals", JOAT_MID, na, text.align_left)
    cell(dash, 1, 6, bullishTurn ? "Long" : bearishTurn ? "Short" : "Idle", bullishTurn ? JOAT_BULL : bearishTurn ? JOAT_BEAR : JOAT_TEXT, na, text.align_right)

alertcondition(bullishTurn, "ERC Long", "Extreme Reversal Channel bullish reversal on {{ticker}}")
alertcondition(bearishTurn, "ERC Short", "Extreme Reversal Channel bearish reversal on {{ticker}}")
````
