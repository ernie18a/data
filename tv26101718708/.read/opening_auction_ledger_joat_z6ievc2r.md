# Opening Auction Ledger [JOAT]

- url: https://www.tradingview.com/script/Z6IeVC2R-Opening-Auction-Ledger-JOAT/
- type: indicator
- pine_id: PUB;6fa75bcc1c734bbfb7503548cb647a99
- version: 1.0

## Description

[b]Opening Auction Ledger [JOAT][/b]

[b]Introduction[/b]

Opening Auction Ledger is an open-source session framework built to standardize how the opening range is measured, locked, evaluated, and managed throughout the day.

The indicator is designed around a simple institutional question:

Once the opening auction is complete, is price accepting away from it or failing back into it?

The script answers that by combining:

[list]
[*]session-specific opening range capture
[*]high-low or body-based range construction
[*]breakout qualification
[*]relative volume confirmation
[*]objective extension ladders
[*]session profile rendering
[*]adaptive continuation trail management
[*]historical breakout tracking in a dashboard
[/list]

This makes the opening range usable as more than a static box.

It becomes a complete session ledger.

[image]https://www.tradingview.com/x/xpiX9x4W/[/image]

[b]Core Concepts[/b]

[b]1. Opening Range Capture[/b]

The script builds the opening range only during the specified session window and then locks that range when the session ends.

This preserves a fixed reference for the rest of the day.

[b]2. Source Flexibility[/b]

Users can define the opening range using raw highs and lows or candle bodies.

This changes how strict the opening auction frame is and can make the indicator more stable on noisy instruments.

[b]3. Qualified Breakout Detection[/b]

Breaks are not accepted simply because price crosses a range boundary.

The script can require a minimum displacement beyond the range and, optionally, a relative-volume lift compared with recent activity.

[b]4. Objective Laddering[/b]

Once a breakout is confirmed, the script projects three extension objectives above and below the opening range using multiples of the locked range size.

[b]5. Continuation Management[/b]

An adaptive ATR trail follows the accepted breakout so continuation quality can be monitored after the initial move is underway.

[image]https://www.tradingview.com/x/YQ0aCzax/[/image]

[b]Features[/b]

[list]
[*][b]Configurable opening session:[/b] user-defined session window and timezone
[*][b]Opening range lock:[/b] session range freezes after the auction ends
[*][b]Body or high-low source mode:[/b] choose the structure used to build the range
[*][b]Relative-volume breakout filter:[/b] optional confirmation prevents weaker breaks from being counted
[*][b]Minimum displacement filter:[/b] breakout must exceed a configurable fraction of the locked range
[*][b]Extension ladder:[/b] three upside and three downside objectives
[*][b]Session profile:[/b] profile-style rendering of activity inside the opening auction
[*][b]Continuation trail:[/b] adaptive ATR trail tracks accepted move quality
[*][b]Historical outcome counters:[/b] dashboard tracks breakout counts and objective hit rates
[*][b]Institutional dashboard:[/b] top-right summary of session state, range size, direction, and objective performance
[/list]

[b]Input Parameters[/b]

[b]Opening Auction[/b]
[list]
[*]Opening Range Session
[*]Session Days
[*]Timezone
[*]Range Source
[*]Minimum Break % Of Range
[*]Require Relative Volume Lift
[*]Relative Volume Threshold
[/list]

[b]Extension Ladder[/b]
[list]
[*]Show Extension Ladder
[*]Objective One
[*]Objective Two
[*]Objective Three
[*]Show Price Labels
[/list]

[b]Auction Profile[/b]
[list]
[*]Show Session Profile
[*]Profile Rows
[*]Profile Width Bars
[*]Profile Offset Bars
[/list]

[b]Continuation Management[/b]
[list]
[*]Show Adaptive Continuation Trail
[*]Trail ATR Length
[*]Trail ATR Multiplier
[/list]

[b]Display[/b]
[list]
[*]Range Fill Transparency
[*]Shade Session State
[*]Dashboard Position
[*]Dashboard Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Wait for the Range to Lock[/b]

Do not treat the opening range as final until the configured auction window is complete.

Before that point, the frame is still forming.

[b]Step 2: Measure the Quality of the First Break[/b]

The first breakout matters most when it clears the minimum displacement rule and is supported by the configured relative-volume threshold.

[b]Step 3: Use the Ladder as an Objective Map[/b]

The projected targets are not predictions.

They are structured expansion references derived from the opening range itself.

[b]Step 4: Follow the Trail for Acceptance[/b]

The continuation trail helps determine whether price is still accepting away from the opening auction or beginning to fail back toward it.

[b]Step 5: Review the Dashboard Statistics[/b]

The dashboard can help users understand how often objective ladders are being reached under the current settings and instrument behavior.

[b]Indicator Limitations[/b]

[list]
[*]The usefulness of the opening range depends heavily on the selected session and market traded
[*]Relative-volume logic is chart-volume based and depends on the instrument's available volume series
[*]Very narrow opening ranges can create closely spaced objectives in low-volatility sessions
[*]A qualified breakout can still fail quickly in event-driven or thin-liquidity conditions
[/list]

[b]Originality Statement[/b]

Opening Auction Ledger extends the classic opening-range idea into a broader session framework by combining range locking, breakout qualification, objective ladders, profile context, continuation management, and outcome tracking in a single open-source script.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It is not investment advice and does not guarantee that any breakout or target sequence will succeed.

All calculations are based on historical chart data and should be interpreted with appropriate risk management and independent analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Opening Auction Ledger [JOAT]", shorttitle = "OAL[JOAT]", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 300)

//==================================================================================================
// Opening Auction Ledger [JOAT]
//--------------------------------------------------------------------------------------------------
// Purpose:
// Frame the opening auction, lock the opening range, project objective ladders, track breakout
// quality, and maintain a restrained dashboard that summarizes historical session efficiency.
//==================================================================================================

//==================================================================================================
// Palette
//==================================================================================================
color AUCTION_BULL  = #15B97D
color AUCTION_BEAR  = #F06569
color AUCTION_BLUE  = #77A9FF
color AUCTION_GOLD  = #D8B25B
color AUCTION_TEXT  = #D7DFEA
color AUCTION_MUTE  = #7F8EA6
color AUCTION_BG    = #0F1722
color AUCTION_EDGE  = #233348

//==================================================================================================
// Inputs
//==================================================================================================
string GROUP_SESSION = "Opening Auction"
string sessionInput  = input.session("0930-1000", "Opening Range Session", group = GROUP_SESSION)
string sessionDaysInput = input.string("12345", "Session Days", group = GROUP_SESSION)
string timezoneInput = input.string("America/New_York", "Timezone", options = ["America/New_York", "UTC", "Europe/London", "America/Chicago", "America/Los_Angeles"], group = GROUP_SESSION)
string sourceModeInput = input.string("High/Low", "Range Source", options = ["High/Low", "Body"], group = GROUP_SESSION)
float minimumBreakPercentInput = input.float(0.15, "Minimum Break % Of Range", minval = 0.0, step = 0.05, group = GROUP_SESSION)
bool requireVolumeLiftInput = input.bool(true, "Require Relative Volume Lift", group = GROUP_SESSION)
float relativeVolumeInput = input.float(1.1, "Relative Volume Threshold", minval = 0.5, step = 0.1, group = GROUP_SESSION)

string GROUP_TARGET = "Extension Ladder"
bool showTargetsInput = input.bool(true, "Show Extension Ladder", group = GROUP_TARGET)
float targetOneInput  = input.float(1.0, "Objective One", minval = 0.25, step = 0.25, group = GROUP_TARGET)
float targetTwoInput  = input.float(1.5, "Objective Two", minval = 0.5, step = 0.25, group = GROUP_TARGET)
float targetThreeInput= input.float(2.0, "Objective Three", minval = 0.5, step = 0.25, group = GROUP_TARGET)
bool showRangeLabelsInput = input.bool(true, "Show Price Labels", group = GROUP_TARGET)

string GROUP_PROFILE = "Auction Profile"
bool showProfileInput = input.bool(true, "Show Session Profile", group = GROUP_PROFILE)
int profileRowsInput = input.int(12, "Profile Rows", minval = 5, maxval = 30, group = GROUP_PROFILE)
int profileWidthInput = input.int(14, "Profile Width Bars", minval = 4, maxval = 40, group = GROUP_PROFILE)
int profileOffsetInput = input.int(6, "Profile Offset Bars", minval = 2, maxval = 30, group = GROUP_PROFILE)

string GROUP_TRAIL = "Continuation Management"
bool showTrailInput = input.bool(true, "Show Adaptive Continuation Trail", group = GROUP_TRAIL)
int trailAtrLenInput = input.int(14, "Trail ATR Length", minval = 1, group = GROUP_TRAIL)
float trailMultInput = input.float(1.8, "Trail ATR Multiplier", minval = 0.2, step = 0.1, group = GROUP_TRAIL)

string GROUP_DISPLAY = "Display"
int fillTransparencyInput = input.int(88, "Range Fill Transparency", minval = 0, maxval = 100, group = GROUP_DISPLAY)
bool shadeStateInput = input.bool(true, "Shade Session State", group = GROUP_DISPLAY)
string dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY)
string dashboardSizeInput = input.string("Medium", "Dashboard Size", options = ["Tiny", "Small", "Medium", "Large"], group = GROUP_DISPLAY)

//==================================================================================================
// Helpers
//==================================================================================================
f_panel_position(string pos) =>
    switch pos
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_panel_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Medium" => size.normal
        => size.large

f_profile_clear(box[] boxes) =>
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box.delete(array.get(boxes, i))
    array.clear(boxes)

f_target_prices(float rangeHigh, float rangeLow, float rangeSize) =>
    [rangeHigh + rangeSize * targetOneInput, rangeHigh + rangeSize * targetTwoInput, rangeHigh + rangeSize * targetThreeInput, rangeLow - rangeSize * targetOneInput, rangeLow - rangeSize * targetTwoInput, rangeLow - rangeSize * targetThreeInput]

//==================================================================================================
// Session State
//==================================================================================================
bool inOpeningAuction = not na(time(timeframe.period, sessionInput + ":" + sessionDaysInput, timezoneInput))
bool newDay = ta.change(time("D", "", timezoneInput)) != 0
bool sessionStarted = inOpeningAuction and not inOpeningAuction[1]
bool sessionEnded = not inOpeningAuction and inOpeningAuction[1]

var float openingHigh = na
var float openingLow = na
var float openingMid = na
var bool rangeLocked = false
var int rangeStartBar = na
var float trailValue = na
var int breakoutDirection = 0
var float breakoutEntry = na
var map<float, float> volumeMap = map.new<float, float>()
var box[] profileBoxes = array.new_box()
var label auctionHighLabel = na
var label auctionLowLabel = na
var label bullOneLabel = na
var label bullTwoLabel = na
var label bullThreeLabel = na
var label bearOneLabel = na
var label bearTwoLabel = na
var label bearThreeLabel = na

var int totalSessions = 0
var int targetOneBullHits = 0
var int targetTwoBullHits = 0
var int targetThreeBullHits = 0
var int targetOneBearHits = 0
var int targetTwoBearHits = 0
var int targetThreeBearHits = 0
var int bullBreakCount = 0
var int bearBreakCount = 0

var bool hitBullOne = false
var bool hitBullTwo = false
var bool hitBullThree = false
var bool hitBearOne = false
var bool hitBearTwo = false
var bool hitBearThree = false

if newDay or sessionStarted
    openingHigh := na
    openingLow := na
    openingMid := na
    rangeLocked := false
    rangeStartBar := bar_index
    trailValue := na
    breakoutDirection := 0
    breakoutEntry := na
    hitBullOne := false
    hitBullTwo := false
    hitBullThree := false
    hitBearOne := false
    hitBearTwo := false
    hitBearThree := false
    volumeMap.clear()

if inOpeningAuction
    float srcHigh = sourceModeInput == "High/Low" ? high : math.max(open, close)
    float srcLow = sourceModeInput == "High/Low" ? low : math.min(open, close)
    openingHigh := na(openingHigh) ? srcHigh : math.max(openingHigh, srcHigh)
    openingLow := na(openingLow) ? srcLow : math.min(openingLow, srcLow)
    openingMid := (openingHigh + openingLow) * 0.5

    float rangeSizeLive = math.max(openingHigh - openingLow, syminfo.mintick)
    float step = math.max(rangeSizeLive / profileRowsInput, syminfo.mintick)
    float roundedPrice = math.round(close / step) * step
    volumeMap.put(roundedPrice, (volumeMap.contains(roundedPrice) ? volumeMap.get(roundedPrice) : 0.0) + volume)

if sessionEnded
    rangeLocked := not na(openingHigh) and not na(openingLow)
    if rangeLocked
        totalSessions += 1

//==================================================================================================
// Breakout and Target Logic
//==================================================================================================
float openingRange = rangeLocked ? math.max(openingHigh - openingLow, syminfo.mintick) : na
float u1 = na
float u2 = na
float u3 = na
float d1 = na
float d2 = na
float d3 = na
if rangeLocked
    [u1, u2, u3, d1, d2, d3] = f_target_prices(openingHigh, openingLow, openingRange)

float relativeVolume = volume / math.max(ta.sma(volume, 20), 1.0)
bool bullishCloseBreak = rangeLocked and barstate.isconfirmed and close > openingHigh + openingRange * minimumBreakPercentInput
bool bearishCloseBreak = rangeLocked and barstate.isconfirmed and close < openingLow - openingRange * minimumBreakPercentInput
bool volumeQualified = not requireVolumeLiftInput or relativeVolume >= relativeVolumeInput

bool bullishBreakout = bullishCloseBreak and volumeQualified and breakoutDirection == 0
bool bearishBreakout = bearishCloseBreak and volumeQualified and breakoutDirection == 0

if bullishBreakout
    breakoutDirection := 1
    breakoutEntry := close
    bullBreakCount += 1

if bearishBreakout
    breakoutDirection := -1
    breakoutEntry := close
    bearBreakCount += 1

if breakoutDirection == 1
    if not hitBullOne and high >= u1
        targetOneBullHits += 1
        hitBullOne := true
    if not hitBullTwo and high >= u2
        targetTwoBullHits += 1
        hitBullTwo := true
    if not hitBullThree and high >= u3
        targetThreeBullHits += 1
        hitBullThree := true

if breakoutDirection == -1
    if not hitBearOne and low <= d1
        targetOneBearHits += 1
        hitBearOne := true
    if not hitBearTwo and low <= d2
        targetTwoBearHits += 1
        hitBearTwo := true
    if not hitBearThree and low <= d3
        targetThreeBearHits += 1
        hitBearThree := true

float trailAtr = ta.atr(trailAtrLenInput)
if breakoutDirection == 1
    trailValue := na(trailValue) ? close - trailAtr * trailMultInput : math.max(trailValue, close - trailAtr * trailMultInput)
    if barstate.isconfirmed and close < trailValue
        breakoutDirection := 0
        trailValue := na

if breakoutDirection == -1
    trailValue := na(trailValue) ? close + trailAtr * trailMultInput : math.min(trailValue, close + trailAtr * trailMultInput)
    if barstate.isconfirmed and close > trailValue
        breakoutDirection := 0
        trailValue := na

//==================================================================================================
// Profile Rendering
//==================================================================================================
if barstate.islast
    f_profile_clear(profileBoxes)
    if showProfileInput and rangeLocked and volumeMap.size() > 0
        keys = map.keys(volumeMap)
        float maxVol = 0.0
        for i = 0 to array.size(keys) - 1
            float key = array.get(keys, i)
            maxVol := math.max(maxVol, volumeMap.get(key))

        for i = 0 to array.size(keys) - 1
            float key = array.get(keys, i)
            float rowVol = volumeMap.get(key)
            int widthBars = math.max(1, math.round((rowVol / math.max(maxVol, 1.0)) * profileWidthInput))
            color rowColor = rowVol == maxVol ? color.new(AUCTION_GOLD, 10) : color.new(AUCTION_BLUE, 38)
            box rowBox = box.new(bar_index + profileOffsetInput, key + openingRange / profileRowsInput * 0.5, bar_index + profileOffsetInput + widthBars, key - openingRange / profileRowsInput * 0.5, bgcolor = rowColor, border_color = color.new(rowColor, 45))
            array.push(profileBoxes, rowBox)

//==================================================================================================
// Plot Layer
//==================================================================================================
plotRangeHigh = plot(rangeLocked ? openingHigh : na, "Opening High", color = color.new(AUCTION_BLUE, 10), linewidth = 2, style = plot.style_linebr)
plotRangeLow = plot(rangeLocked ? openingLow : na, "Opening Low", color = color.new(AUCTION_BLUE, 10), linewidth = 2, style = plot.style_linebr)
plotRangeMid = plot(rangeLocked ? openingMid : na, "Opening Mid", color = color.new(AUCTION_GOLD, 25), linewidth = 1, style = plot.style_linebr)
fill(plotRangeHigh, plotRangeLow, color = color.new(AUCTION_BLUE, fillTransparencyInput), title = "Auction Range Fill")

plot(showTargetsInput and breakoutDirection >= 0 ? u1 : na, "Bull Objective One", color = color.new(AUCTION_BULL, 60), linewidth = 1, style = plot.style_linebr)
plot(showTargetsInput and breakoutDirection >= 0 ? u2 : na, "Bull Objective Two", color = color.new(AUCTION_BULL, 45), linewidth = 1, style = plot.style_linebr)
plot(showTargetsInput and breakoutDirection >= 0 ? u3 : na, "Bull Objective Three", color = color.new(AUCTION_BULL, 30), linewidth = 1, style = plot.style_linebr)
plot(showTargetsInput and breakoutDirection <= 0 ? d1 : na, "Bear Objective One", color = color.new(AUCTION_BEAR, 60), linewidth = 1, style = plot.style_linebr)
plot(showTargetsInput and breakoutDirection <= 0 ? d2 : na, "Bear Objective Two", color = color.new(AUCTION_BEAR, 45), linewidth = 1, style = plot.style_linebr)
plot(showTargetsInput and breakoutDirection <= 0 ? d3 : na, "Bear Objective Three", color = color.new(AUCTION_BEAR, 30), linewidth = 1, style = plot.style_linebr)
plot(showTrailInput ? trailValue : na, "Continuation Trail", color = breakoutDirection >= 0 ? AUCTION_BULL : AUCTION_BEAR, linewidth = 2, style = plot.style_linebr)

bgcolor(shadeStateInput ? (inOpeningAuction ? color.new(AUCTION_BLUE, 94) : breakoutDirection == 1 ? color.new(AUCTION_BULL, 94) : breakoutDirection == -1 ? color.new(AUCTION_BEAR, 94) : na) : na)

if barstate.islast and showRangeLabelsInput and rangeLocked
    if na(auctionHighLabel)
        auctionHighLabel := label.new(bar_index + 2, openingHigh, "Auction High", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BLUE, size = size.small)
    else
        auctionHighLabel.set_xy(bar_index + 2, openingHigh)
        auctionHighLabel.set_text("Auction High")

    if na(auctionLowLabel)
        auctionLowLabel := label.new(bar_index + 2, openingLow, "Auction Low", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BLUE, size = size.small)
    else
        auctionLowLabel.set_xy(bar_index + 2, openingLow)
        auctionLowLabel.set_text("Auction Low")

    if showTargetsInput
        if breakoutDirection >= 0
            if na(bullOneLabel)
                bullOneLabel := label.new(bar_index + 2, u1, "Objective One", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BULL, size = size.small)
            else
                bullOneLabel.set_xy(bar_index + 2, u1)
                bullOneLabel.set_text("Objective One")

            if na(bullTwoLabel)
                bullTwoLabel := label.new(bar_index + 2, u2, "Objective Two", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BULL, size = size.small)
            else
                bullTwoLabel.set_xy(bar_index + 2, u2)
                bullTwoLabel.set_text("Objective Two")

            if na(bullThreeLabel)
                bullThreeLabel := label.new(bar_index + 2, u3, "Objective Three", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BULL, size = size.small)
            else
                bullThreeLabel.set_xy(bar_index + 2, u3)
                bullThreeLabel.set_text("Objective Three")
        if breakoutDirection <= 0
            if na(bearOneLabel)
                bearOneLabel := label.new(bar_index + 2, d1, "Objective One", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BEAR, size = size.small)
            else
                bearOneLabel.set_xy(bar_index + 2, d1)
                bearOneLabel.set_text("Objective One")

            if na(bearTwoLabel)
                bearTwoLabel := label.new(bar_index + 2, d2, "Objective Two", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BEAR, size = size.small)
            else
                bearTwoLabel.set_xy(bar_index + 2, d2)
                bearTwoLabel.set_text("Objective Two")

            if na(bearThreeLabel)
                bearThreeLabel := label.new(bar_index + 2, d3, "Objective Three", style = label.style_label_left, color = color.new(AUCTION_BG, 0), textcolor = AUCTION_BEAR, size = size.small)
            else
                bearThreeLabel.set_xy(bar_index + 2, d3)
                bearThreeLabel.set_text("Objective Three")

//==================================================================================================
// Dashboard
//==================================================================================================
var table dash = table.new(f_panel_position(dashboardPositionInput), 2, 9, bgcolor = AUCTION_BG, frame_color = AUCTION_EDGE, frame_width = 1)
var dashSize = f_panel_size(dashboardSizeInput)

f_dash_cell(int c, int r, string txt, color txtColor, color bgColor, alignMode) =>
    table.cell(dash, c, r, txt, text_color = txtColor, bgcolor = bgColor, text_halign = alignMode, text_size = dashSize)

if barstate.islast
    f_dash_cell(0, 0, "Opening Auction Ledger", AUCTION_TEXT, AUCTION_EDGE, text.align_left)
    f_dash_cell(1, 0, "OAL", AUCTION_TEXT, AUCTION_EDGE, text.align_right)

    string stateText = inOpeningAuction ? "Auction Forming" : rangeLocked ? (breakoutDirection == 1 ? "Bullish Release" : breakoutDirection == -1 ? "Bearish Release" : "Range Locked") : "Idle"
    f_dash_cell(0, 1, "State", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 1, stateText, breakoutDirection == 1 ? AUCTION_BULL : breakoutDirection == -1 ? AUCTION_BEAR : AUCTION_TEXT, AUCTION_BG, text.align_right)

    f_dash_cell(0, 2, "Range Width", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 2, rangeLocked ? str.tostring(openingRange, format.mintick) : "N/A", AUCTION_TEXT, AUCTION_BG, text.align_right)

    f_dash_cell(0, 3, "Relative Volume", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 3, str.tostring(relativeVolume, "#.00") + "x", relativeVolume >= relativeVolumeInput ? AUCTION_GOLD : AUCTION_TEXT, AUCTION_BG, text.align_right)

    f_dash_cell(0, 4, "Bull Breaks", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 4, str.tostring(bullBreakCount), AUCTION_BULL, AUCTION_BG, text.align_right)

    f_dash_cell(0, 5, "Bear Breaks", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 5, str.tostring(bearBreakCount), AUCTION_BEAR, AUCTION_BG, text.align_right)

    string bullRate = totalSessions > 0 ? str.tostring(math.round((targetOneBullHits / totalSessions) * 100)) + "% / " + str.tostring(math.round((targetTwoBullHits / totalSessions) * 100)) + "% / " + str.tostring(math.round((targetThreeBullHits / totalSessions) * 100)) + "%" : "N/A"
    string bearRate = totalSessions > 0 ? str.tostring(math.round((targetOneBearHits / totalSessions) * 100)) + "% / " + str.tostring(math.round((targetTwoBearHits / totalSessions) * 100)) + "% / " + str.tostring(math.round((targetThreeBearHits / totalSessions) * 100)) + "%" : "N/A"
    f_dash_cell(0, 6, "Bull Ladder", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 6, bullRate, AUCTION_BULL, AUCTION_BG, text.align_right)
    f_dash_cell(0, 7, "Bear Ladder", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 7, bearRate, AUCTION_BEAR, AUCTION_BG, text.align_right)

    f_dash_cell(0, 8, "Tracked Sessions", AUCTION_MUTE, AUCTION_BG, text.align_left)
    f_dash_cell(1, 8, str.tostring(totalSessions), AUCTION_TEXT, AUCTION_BG, text.align_right)

//==================================================================================================
// Alerts
//==================================================================================================
alertcondition(bullishBreakout, "Bullish Auction Release", "Opening Auction Ledger [JOAT] confirmed a bullish opening auction release.")
alertcondition(bearishBreakout, "Bearish Auction Release", "Opening Auction Ledger [JOAT] confirmed a bearish opening auction release.")
alertcondition(showTrailInput and breakoutDirection == 1 and barstate.isconfirmed and close < trailValue, "Bullish Trail Failure", "Opening Auction Ledger [JOAT] bullish continuation trail failed.")
alertcondition(showTrailInput and breakoutDirection == -1 and barstate.isconfirmed and close > trailValue, "Bearish Trail Failure", "Opening Auction Ledger [JOAT] bearish continuation trail failed.")
````
