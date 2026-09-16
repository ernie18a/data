<!-- tradingview-pine-id: PUB;de432d0dbb8648da968aaae6697f69ca -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dow Theory + O&#039;Neil Trend Manager

Source: https://www.tradingview.com/script/7a5ltzhf-Dow-Theory-Trend-Manager-PRO/

## Description

Dow Theory Trend Manager PRO
The Dow Theory + O'Neil Trend Manager combines trend-following principles from Dow Theory with William O'Neil's disciplined risk management approach.

The indicator automatically identifies bullish breakout opportunities based on market structure, calculates an 8% O'Neil stop loss, measures reward in R-multiples, and tracks the progress of a trade through predefined profit milestones.

Key Features

[*]Automatic Trend Detection
[*]Identifies Higher Highs (HH) and Higher Lows (HL)
[*]Detects bullish breakouts from confirmed swing structures
[*]Monitors ongoing market structure and trend status
[*]O'Neil Risk Management
[*]Calculates an initial stop loss based on the selected percentage (default 8%)
[*]Defines risk per share from the breakout entry
[*]Tracks trades using R-multiples rather than percentage returns
[*]Profit Milestones

The indicator automatically plots:

[*]2.5R – First profit objective
[*]4R – Strong trend confirmation
[*]6R – Exceptional trend performance

This allows traders and investors to assess how far a move has progressed relative to the original risk.

Trailing Stop Management

[*]Moves from the initial stop to breakeven after the first milestone is achieved
[*]Tracks active stop levels throughout the life of the trade
[*]Helps identify when a trend has likely completed

What is the Dashboard Showing?:

The dashboard provides a complete overview of the current or most recent trade.

Trend

Displays the current market structure:

[*]Bullish = Higher High + Higher Low
[*]Bearish = Lower High + Lower Low
[*]Transition = Consolidation or mixed structure

Trade Status  - Shows the current state of the trade, such as:

[*]Active
[*]2.5R Reached
[*]4R Reached
[*]6R Reached
[*]Trailing Stop Hit

[*]Entry: The breakout price where the trade was initiated.
[*]Initial Stop: The original risk level based on the selected stop-loss percentage.
[*]Active Stop : The current stop level being managed by the system.
[*]Current Price: Latest market price.
[*]Current Return: Percentage gain or loss from the original entry price.
[*]Current R : Current profit or loss expressed in R-multiples Example: A Current R of 4.0R means the trade has generated four times the original risk.
[*]Maximum R: The highest R-multiple achieved during the life of the trade. This helps evaluate the true potential of a trend regardless of where the current price is trading.
[*]2.5R, 4R and 6R Status: Indicates whether each milestone has been reached.
[*]Trail Status: Shows whether the trailing stop management system is active.
[*]Locked R: Displays the amount of profit currently protected by the active stop.

Trade Grade: Grades the trade based on the maximum R achieved:

[*]A+ = 6R or greater
[*]A = 4R to 6R
[*]B = 2.5R to 4R
[*]C = 1R to 2.5R
[*]D = Less than 1R

Intended Use - This indicator is designed for

[*]Trend-following investors
[*]CANSLIM practitioners
[*]O'Neil-style growth stock investors
[*]Position traders
[*]Swing traders focused on risk-adjusted returns

The goal is not simply to identify entries, but to help you to think in terms of risk, reward, and trend quality, using R-multiples as the primary measure of performance. 

Let me know how you want to make any changes to the indicator.

---

## Source Code

````pine
//@version=6
indicator(
     "Dow Theory + O'Neil Trend Manager",
     shorttitle = "Dow + O'Neil Trend Manager",
     overlay = true,
     max_labels_count = 500
)

// ============================================================================
// 1. USER INPUTS
// ============================================================================

pivotLength = input.int(
     5,
     "Swing Pivot Length",
     minval = 1,
     tooltip = "Number of bars used to confirm swing highs and swing lows."
)

stopPercent = input.float(
     8.0,
     "Initial O'Neil Stop %",
     minval = 0.1,
     maxval = 50.0,
     step = 0.1
)

firstMilestoneR = input.float(
     2.5,
     "First Profit Milestone R",
     minval = 0.1,
     step = 0.1
)

secondMilestoneR = input.float(
     4.0,
     "Second Profit Milestone R",
     minval = 0.1,
     step = 0.1
)

thirdMilestoneR = input.float(
     6.0,
     "Third Profit Milestone R",
     minval = 0.1,
     step = 0.1
)

requireBullStructure = input.bool(
     true,
     "Require Bullish Dow Structure",
     tooltip = "Requires a higher confirmed swing high and higher confirmed swing low."
)

useCloseBreakout = input.bool(
     true,
     "Require Close Above Breakout",
     tooltip = "When enabled, the candle must close above the confirmed swing high."
)

activateTrailAtFirstMilestone = input.bool(
     true,
     "Activate Trailing Stop After 2.5R"
)

moveStopToBreakeven = input.bool(
     true,
     "Move Stop to Breakeven After 2.5R",
     tooltip = "After the first milestone, the stop cannot remain below entry."
)

useSwingLowTrail = input.bool(
     true,
     "Trail Under Confirmed Swing Lows"
)

swingTrailBufferPercent = input.float(
     0.0,
     "Swing-Low Trail Buffer %",
     minval = 0.0,
     step = 0.1,
     tooltip = "Example: 1% places the trailing stop 1% below the confirmed swing low."
)

allowNewEntryAfterExit = input.bool(
     true,
     "Allow New Entry After Stop Exit"
)

showSwingLevels = input.bool(
     true,
     "Show Confirmed Swing High and Low"
)

showMilestoneLines = input.bool(
     true,
     "Show 2.5R, 4R and 6R Lines"
)

showEntryLabels = input.bool(
     true,
     "Show Automatic Entry Labels"
)

// ============================================================================
// 2. CONFIRMED SWING DETECTION
// ============================================================================

pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow = ta.pivotlow(low, pivotLength, pivotLength)

var float latestSwingHigh = na
var float previousSwingHigh = na
var float latestSwingLow = na
var float previousSwingLow = na

if not na(pivotHigh)
    previousSwingHigh := latestSwingHigh
    latestSwingHigh := pivotHigh

if not na(pivotLow)
    previousSwingLow := latestSwingLow
    latestSwingLow := pivotLow

// ============================================================================
// 3. DOW-STYLE MARKET STRUCTURE
// ============================================================================

higherHigh =
     not na(latestSwingHigh) and
     not na(previousSwingHigh) and
     latestSwingHigh > previousSwingHigh

higherLow =
     not na(latestSwingLow) and
     not na(previousSwingLow) and
     latestSwingLow > previousSwingLow

lowerHigh =
     not na(latestSwingHigh) and
     not na(previousSwingHigh) and
     latestSwingHigh < previousSwingHigh

lowerLow =
     not na(latestSwingLow) and
     not na(previousSwingLow) and
     latestSwingLow < previousSwingLow

bullishStructure = higherHigh and higherLow
bearishStructure = lowerHigh and lowerLow

string trendStatus =
     bullishStructure ? "BULLISH" :
     bearishStructure ? "BEARISH" :
     "TRANSITION"

color trendColor =
     bullishStructure ? color.green :
     bearishStructure ? color.red :
     color.orange

// ============================================================================
// 4. BREAKOUT DETECTION
// ============================================================================

breakoutPrice = latestSwingHigh

closeBreakout =
     not na(breakoutPrice) and
     ta.crossover(close, breakoutPrice)

highBreakout =
     not na(breakoutPrice) and
     high > breakoutPrice and
     high[1] <= breakoutPrice

rawBreakout = useCloseBreakout ? closeBreakout : highBreakout

structureApproved =
     requireBullStructure ? bullishStructure : true

// ============================================================================
// 5. TRADE STATE
// ============================================================================

var bool tradeActive = false

var float entryPrice = na
var float initialStop = na
var float activeStop = na
var float riskPerShare = na

var float milestone25Price = na
var float milestone4Price = na
var float milestone6Price = na

var bool milestone25Hit = false
var bool milestone4Hit = false
var bool milestone6Hit = false

var int entryBar = na
var int exitBar = na

var float highestPriceSinceEntry = na
var float maximumR = na

var string tradeStatus = "WAITING"
var string exitReason = "NONE"

// New entries are allowed when no trade is active.
entryAllowed =
     not tradeActive and
     (allowNewEntryAfterExit or na(entryPrice))

newEntry =
     rawBreakout and
     structureApproved and
     entryAllowed

// ============================================================================
// 6. CREATE NEW AUTOMATIC ENTRY
// ============================================================================

if newEntry
    entryPrice := close

    initialStop :=
         entryPrice * (1.0 - stopPercent / 100.0)

    activeStop := initialStop

    riskPerShare :=
         entryPrice - initialStop

    milestone25Price :=
         entryPrice + riskPerShare * firstMilestoneR

    milestone4Price :=
         entryPrice + riskPerShare * secondMilestoneR

    milestone6Price :=
         entryPrice + riskPerShare * thirdMilestoneR

    milestone25Hit := false
    milestone4Hit := false
    milestone6Hit := false

    highestPriceSinceEntry := high
    maximumR := 0.0

    entryBar := bar_index
    exitBar := na

    tradeActive := true
    tradeStatus := "ACTIVE"
    exitReason := "NONE"

// ============================================================================
// 7. TRACK HIGHEST PRICE AND MAXIMUM R
// ============================================================================

if tradeActive
    highestPriceSinceEntry :=
         na(highestPriceSinceEntry)
         ? high
         : math.max(highestPriceSinceEntry, high)

    maximumR :=
         riskPerShare > 0
         ? (highestPriceSinceEntry - entryPrice) / riskPerShare
         : na

// ============================================================================
// 8. PROFIT MILESTONE DETECTION
// ============================================================================

new25RHit =
     tradeActive and
     not milestone25Hit and
     high >= milestone25Price

new4RHit =
     tradeActive and
     not milestone4Hit and
     high >= milestone4Price

new6RHit =
     tradeActive and
     not milestone6Hit and
     high >= milestone6Price

if new25RHit
    milestone25Hit := true
    tradeStatus := "2.5R REACHED"

if new4RHit
    milestone4Hit := true
    tradeStatus := "4R REACHED"

if new6RHit
    milestone6Hit := true
    tradeStatus := "6R REACHED"

// ============================================================================
// 9. STRUCTURE-BASED TRAILING STOP
// ============================================================================

// The trail activates only after the first profit milestone.
trailActivated =
     tradeActive and
     milestone25Hit and
     activateTrailAtFirstMilestone

if trailActivated
    float proposedStop = activeStop

    // Optionally protect the entry price after 2.5R.
    if moveStopToBreakeven
        proposedStop := math.max(proposedStop, entryPrice)

    // Move the stop beneath the most recently confirmed swing low.
    if useSwingLowTrail and not na(latestSwingLow)
        bufferedSwingStop =
             latestSwingLow *
             (1.0 - swingTrailBufferPercent / 100.0)

        proposedStop :=
             math.max(proposedStop, bufferedSwingStop)

    // A trailing stop must never move down.
    activeStop :=
         math.max(activeStop, proposedStop)

// ============================================================================
// 10. STOP-EXIT DETECTION
// ============================================================================

// Do not evaluate an exit on the entry candle.
stopTouched =
     tradeActive and
     bar_index > entryBar and
     low <= activeStop

if stopTouched
    tradeActive := false
    exitBar := bar_index

    exitReason :=
         milestone25Hit
         ? "TRAILING STOP HIT"
         : "INITIAL STOP HIT"

    tradeStatus := exitReason

// ============================================================================
// 11. LIVE RISK AND RETURN CALCULATIONS
// ============================================================================

currentReturnPercent =
     not na(entryPrice)
     ? ((close - entryPrice) / entryPrice) * 100.0
     : na

currentR =
     not na(riskPerShare) and riskPerShare > 0
     ? (close - entryPrice) / riskPerShare
     : na

milestoneProgress =
     not na(currentR)
     ? (currentR / firstMilestoneR) * 100.0
     : na

initialRiskAmount =
     not na(entryPrice) and not na(initialStop)
     ? entryPrice - initialStop
     : na

currentStopRiskPercent =
     not na(entryPrice) and not na(activeStop)
     ? ((entryPrice - activeStop) / entryPrice) * 100.0
     : na

lockedR =
     not na(activeStop) and
     not na(entryPrice) and
     not na(riskPerShare) and
     riskPerShare > 0
     ? (activeStop - entryPrice) / riskPerShare
     : na

// ============================================================================
// 12. TRADE GRADE
// ============================================================================

string tradeGrade =
     na(maximumR) ? "N/A" :
     maximumR >= thirdMilestoneR ? "A+" :
     maximumR >= secondMilestoneR ? "A" :
     maximumR >= firstMilestoneR ? "B" :
     maximumR >= 1.0 ? "C" :
     maximumR >= 0.0 ? "D" :
     "N/A"

color gradeColor =
     tradeGrade == "A+" ? color.lime :
     tradeGrade == "A" ? color.green :
     tradeGrade == "B" ? color.aqua :
     tradeGrade == "C" ? color.orange :
     tradeGrade == "D" ? color.yellow :
     color.gray

// ============================================================================
// 13. PLOT SWING STRUCTURE
// ============================================================================

plot(
     showSwingLevels ? latestSwingHigh : na,
     "Latest Confirmed Swing High",
     color = color.new(color.orange, 25),
     linewidth = 1,
     style = plot.style_stepline
)

plot(
     showSwingLevels ? latestSwingLow : na,
     "Latest Confirmed Swing Low",
     color = color.new(color.aqua, 25),
     linewidth = 1,
     style = plot.style_stepline
)

// ============================================================================
// 14. PLOT ENTRY AND STOP
// ============================================================================

plot(
     not na(entryPrice) ? entryPrice : na,
     "Entry",
     color = color.blue,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     not na(initialStop) ? initialStop : na,
     "Initial 8% Stop",
     color = color.new(color.red, 65),
     linewidth = 1,
     style = plot.style_linebr
)

plot(
     not na(activeStop) ? activeStop : na,
     "Active Stop",
     color = milestone25Hit ? color.fuchsia : color.red,
     linewidth = 3,
     style = plot.style_linebr
)

// ============================================================================
// 15. PLOT PROFIT MILESTONES
// ============================================================================

plot(
     showMilestoneLines and not na(milestone25Price)
     ? milestone25Price
     : na,
     "2.5R Milestone",
     color = color.green,
     linewidth = 3,
     style = plot.style_linebr
)

plot(
     showMilestoneLines and not na(milestone4Price)
     ? milestone4Price
     : na,
     "4R Milestone",
     color = color.new(color.green, 35),
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showMilestoneLines and not na(milestone6Price)
     ? milestone6Price
     : na,
     "6R Milestone",
     color = color.new(color.lime, 20),
     linewidth = 2,
     style = plot.style_linebr
)

// ============================================================================
// 16. ENTRY AND MILESTONE MARKERS
// ============================================================================

plotshape(
     newEntry,
     title = "Automatic Entry",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.green,
     size = size.small,
     text = "BUY"
)

plotshape(
     new25RHit,
     title = "2.5R Reached",
     style = shape.circle,
     location = location.abovebar,
     color = color.green,
     size = size.small,
     text = "2.5R"
)

plotshape(
     new4RHit,
     title = "4R Reached",
     style = shape.circle,
     location = location.abovebar,
     color = color.aqua,
     size = size.small,
     text = "4R"
)

plotshape(
     new6RHit,
     title = "6R Reached",
     style = shape.circle,
     location = location.abovebar,
     color = color.lime,
     size = size.small,
     text = "6R"
)

plotshape(
     stopTouched,
     title = "Stop Exit",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.small,
     text = "EXIT"
)

if newEntry and showEntryLabels
    label.new(
         bar_index,
         low,
         "AUTO ENTRY\n" +
         str.tostring(entryPrice, format.mintick) +
         "\nInitial Stop: " +
         str.tostring(initialStop, format.mintick) +
         "\n2.5R: " +
         str.tostring(milestone25Price, format.mintick),
         style = label.style_label_up,
         color = color.green,
         textcolor = color.white,
         size = size.small
    )

// ============================================================================
// 17. ALERT CONDITIONS
// ============================================================================

alertcondition(
     newEntry,
     "New Bullish Breakout",
     "A new bullish Dow-structure breakout has generated an entry."
)

alertcondition(
     new25RHit,
     "2.5R Milestone Reached",
     "The active trade has reached the 2.5R profit milestone."
)

alertcondition(
     new4RHit,
     "4R Milestone Reached",
     "The active trade has reached the 4R profit milestone."
)

alertcondition(
     new6RHit,
     "6R Milestone Reached",
     "The active trade has reached the 6R profit milestone."
)

alertcondition(
     stopTouched,
     "Active Stop Hit",
     "The active trade has touched its current stop level."
)

// ============================================================================
// 18. DASHBOARD
// ============================================================================

var table dashboard = table.new(
     position.top_right,
     2,
     16,
     border_width = 1,
     frame_color = color.gray,
     border_color = color.new(color.gray, 60)
)

if barstate.islast
    headerColor = color.rgb(32, 44, 60)

    table.cell(
         dashboard,
         0,
         0,
         "DOW + O'NEIL",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         1,
         0,
         "TREND MANAGER",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(dashboard, 0, 1, "Trend")
    table.cell(
         dashboard,
         1,
         1,
         trendStatus,
         text_color = trendColor
    )

    table.cell(dashboard, 0, 2, "Trade Status")
    table.cell(
         dashboard,
         1,
         2,
         tradeStatus,
         text_color =
             tradeActive
             ? color.green
             : color.orange
    )

    table.cell(dashboard, 0, 3, "Entry")
    table.cell(
         dashboard,
         1,
         3,
         na(entryPrice)
         ? "Waiting"
         : str.tostring(entryPrice, format.mintick)
    )

    table.cell(dashboard, 0, 4, "Initial Stop")
    table.cell(
         dashboard,
         1,
         4,
         na(initialStop)
         ? "N/A"
         : str.tostring(initialStop, format.mintick)
    )

    table.cell(dashboard, 0, 5, "Active Stop")
    table.cell(
         dashboard,
         1,
         5,
         na(activeStop)
         ? "N/A"
         : str.tostring(activeStop, format.mintick),
         text_color =
             milestone25Hit
             ? color.fuchsia
             : color.red
    )

    table.cell(dashboard, 0, 6, "Current Price")
    table.cell(
         dashboard,
         1,
         6,
         str.tostring(close, format.mintick)
    )

    table.cell(dashboard, 0, 7, "Current Return")
    table.cell(
         dashboard,
         1,
         7,
         na(currentReturnPercent)
         ? "N/A"
         : str.tostring(currentReturnPercent, "#.##") + "%"
    )

    table.cell(dashboard, 0, 8, "Current R")
    table.cell(
         dashboard,
         1,
         8,
         na(currentR)
         ? "N/A"
         : str.tostring(currentR, "#.##") + "R"
    )

    table.cell(dashboard, 0, 9, "Maximum R")
    table.cell(
         dashboard,
         1,
         9,
         na(maximumR)
         ? "N/A"
         : str.tostring(maximumR, "#.##") + "R",
         text_color = gradeColor
    )

    table.cell(dashboard, 0, 10, "2.5R")
    table.cell(
         dashboard,
         1,
         10,
         milestone25Hit ? "REACHED" : "WAITING",
         text_color =
             milestone25Hit
             ? color.green
             : color.gray
    )

    table.cell(dashboard, 0, 11, "4R")
    table.cell(
         dashboard,
         1,
         11,
         milestone4Hit ? "REACHED" : "WAITING",
         text_color =
             milestone4Hit
             ? color.aqua
             : color.gray
    )

    table.cell(dashboard, 0, 12, "6R")
    table.cell(
         dashboard,
         1,
         12,
         milestone6Hit ? "REACHED" : "WAITING",
         text_color =
             milestone6Hit
             ? color.lime
             : color.gray
    )

    table.cell(dashboard, 0, 13, "Trail Status")
    table.cell(
         dashboard,
         1,
         13,
         trailActivated ? "ACTIVE" : "NOT ACTIVE",
         text_color =
             trailActivated
             ? color.fuchsia
             : color.gray
    )

    table.cell(dashboard, 0, 14, "Locked R")
    table.cell(
         dashboard,
         1,
         14,
         na(lockedR)
         ? "N/A"
         : str.tostring(lockedR, "#.##") + "R",
         text_color =
             lockedR > 0
             ? color.green
             : color.orange
    )

    table.cell(dashboard, 0, 15, "Trade Grade")
    table.cell(
         dashboard,
         1,
         15,
         tradeGrade,
         bgcolor = color.new(gradeColor, 75),
         text_color = gradeColor
    )
````
