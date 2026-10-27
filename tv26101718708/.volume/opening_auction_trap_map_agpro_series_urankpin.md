# Opening Auction Trap Map [AGPro Series]

- url: https://www.tradingview.com/script/URankpin-Opening-Auction-Trap-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;6b24895a209a40a4a3ec490095d34267
- version: 4.0

## Description

Opening Auction Trap Map [AGPro Series]

🧠 Core Idea

Did the opening auction accept value, reject an early extreme, or trap breakout participants?


📌 Overview / What it does

Opening Auction Trap Map is an intraday session-open analysis tool built to study the first auction window of the trading session.

The script builds an opening auction box, tracks the auction high and low, draws an acceptance rail, maps upper and lower failed-auction trap zones, and classifies whether price is accepting outside the auction or rejecting back into the range.

It does not predict price direction, automate trades, or claim that every opening trap will create a reversal. It is a structured visualization and decision-support tool for intraday auction context.


🎯 Purpose & Design Philosophy

Many opening-range tools focus only on breakout direction.

This script was built to answer a more precise auction question:

Was the opening move accepted, or did it trap traders who chased the first extreme?

The design goal is to help intraday traders read the opening range as an auction behavior map instead of treating it as a simple breakout box.


⚡ Why This Script Is Different

Most ORB tools mark the opening high and low, then wait for a breakout.

This script does NOT treat every opening breakout as valid.

Instead, it checks whether the move accepts beyond the auction edge, fails back inside the auction range, or retests a failed edge. The focus is auction behavior, trap risk, range control, and acceptance quality.


⚙️ Methodology

1. Opening Auction Window

The script tracks high, low, and midpoint during the selected opening auction window.

2. Auction Box and Rails

After the auction completes, the script projects the auction box, upper and lower trap zones, and the midpoint acceptance rail.

3. Failed-Auction Detection

If price breaks above the auction high and closes back inside the range with enough upper-wick rejection, the script can mark an upper auction trap.

If price breaks below the auction low and closes back inside the range with enough lower-wick rejection, the script can mark a lower auction trap.

4. Acceptance Evaluation

If price holds beyond the auction edge for the required number of closes, the script can mark accepted movement above or below the auction.

5. Visual Output

The chart displays the auction box, trap zones, acceptance rail, event labels, right-side tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Opening Auction Box = the high-low range created during the selected opening window.

Acceptance Rail = the midpoint of the opening auction range.

Upper Trap Zone = the area around the auction high where failed upside breakouts may be evaluated.

Lower Trap Zone = the area around the auction low where failed downside breakouts may be evaluated.

UPPER AUCTION TRAP = price failed above the auction high and closed back inside the range.

LOWER AUCTION TRAP = price failed below the auction low and closed back inside the range.

ACCEPT UP = price accepted above the auction high.

ACCEPT DOWN = price accepted below the auction low.

Panel = summarizes auction state, quality score, auction high/low, range control, trap risk, next context, session window, and timeframe scope.

TF Scope = shows whether the current chart timeframe is inside the supported auction-building range.


🚦 Signals & States

• UPPER TRAP → upside auction breakout failed back inside the range.

• LOWER TRAP → downside auction breakout failed back inside the range.

• ACCEPT UP → price accepted above the auction high.

• ACCEPT DOWN → price accepted below the auction low.

• RANGE CONTROL → price is trading inside the auction range.

• ABOVE AUCTION → price is above the auction high but not yet classified as accepted.

• BELOW AUCTION → price is below the auction low but not yet classified as accepted.

• BUILDING → the opening auction window is still forming.


🔔 Alerts Logic

Alerts trigger when a new major auction behavior state appears.

• Upper Opening Auction Trap → price failed above the auction high and closed back inside the range.

• Lower Opening Auction Trap → price failed below the auction low and closed back inside the range.

• Accepted Above Opening Auction → price accepted above the opening auction high.

• Accepted Below Opening Auction → price accepted below the opening auction low.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• The auction range is clearly formed
• Price probes an auction edge
• The close rejects back inside the range
• Wick quality is strong
• Relative volume confirms participation
• The panel state agrees with the event label

If these elements do not align, the script avoids forcing a trap interpretation.


📊 When to Use

• Intraday session-open analysis
• Opening range review
• ORB validation and failed-breakout detection
• Equity index, stock, futures, forex, and crypto session studies
• 1m, 3m, 5m, 15m, 30m, and 1H charts
• Markets where the selected opening session has meaning


⚠️ When NOT to Use

• Daily, weekly, or monthly charts
• Symbols without a meaningful session open
• Very low-liquidity assets
• Extremely noisy markets where wick behavior is unreliable
• Charts where the selected auction window does not match the actual market session
• Situations where a single opening range should not be over-interpreted


🎛️ Key Inputs

• Opening Auction Window → defines the session segment used to build the auction range.

• Active Session Window → defines the session where post-auction behavior is evaluated.

• Max Chart TF Minutes → defines the largest chart timeframe that should build the auction map. With the default 09:30-10:00 auction window, 30m and lower charts are the intended use.

• Acceptance Close Count → sets how many closes are required before a breakout is treated as accepted.

• Trap Evaluation Window → limits how long after the auction trap logic remains active.

• Trap Wick Quality Threshold → controls how strong the rejection wick must be before a trap label appears.

• Use Volume Confirmation → adds relative volume to quality scoring.

• Trap Zone Width ATR → controls the thickness of the upper and lower trap zones.

• Event Label Mode → Premium focuses on traps and accepted moves. Detailed also allows lower-priority retest labels.

• Projection Bars → controls how far the auction structure projects to the right.


🖥️ Interface & Visual Design

The visual hierarchy is built around the auction range:

The box defines the opening auction.

Trap zones frame the dangerous edges.

The midpoint rail shows range control.

Event labels mark important acceptance or failure behavior.

The AG Pro panel summarizes the current auction state without requiring the user to decode every element manually.


🧪 Practical Usage Workflow

1. Select the opening auction window that matches the market.

2. Wait until the auction box completes.

3. Watch how price behaves around the auction high and low.

4. Check whether price accepts beyond the edge or fails back inside the range.

5. Use the panel to confirm auction state, quality score, range control, and trap risk.

6. Interpret the output inside broader market context.


🔍 Interpretation Guidelines

An upper trap does not guarantee a selloff. It means the auction high was probed and rejected back inside the range.

A lower trap does not guarantee a rally. It means the auction low was probed and rejected back inside the range.

Accepted movement does not guarantee continuation. It means price has held beyond the auction edge according to the script’s rule set.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a standard ORB breakout strategy.


⚠️ Limitations & Transparency

Session settings matter. A poorly selected auction window can produce weak context.

Higher chart timeframes may not capture the opening auction precisely.

Low-liquidity markets may generate misleading wicks.

Gap-heavy markets may require wider interpretation.

The script is designed for intraday auction reading, not long-term chart analysis.


🧠 Market Context Notes

The opening auction is often useful because it reveals early participation, imbalance, and willingness to accept price outside the first range.

Failed extremes can matter because they show where early breakout attempts were rejected.

Acceptance can matter because it shows where the market was willing to continue trading beyond the auction edge.


🧾 Use Case Examples

If price breaks above the auction high but closes back inside the range with a strong upper wick, the script may mark UPPER AUCTION TRAP.

If price breaks below the auction low but closes back inside the range with a strong lower wick, the script may mark LOWER AUCTION TRAP.

If price closes above the auction high for the required number of bars, the script may mark ACCEPT UP.

If price closes below the auction low for the required number of bars, the script may mark ACCEPT DOWN.


🧱 System Philosophy

This script follows a behavior-first approach:

Auction first.
Edge reaction second.
Acceptance third.
Trap risk fourth.

The goal is to reduce blind breakout thinking and encourage structured opening-session interpretation.


🔐 Non-Promise Statement

No script can guarantee outcomes.

No auction edge, trap label, acceptance state, or quality score should be treated as certainty.

The output should always be interpreted with broader structure, liquidity, volatility, and personal risk rules.


📉 Risk Disclosure

Trading involves risk.

Markets can move against any interpretation.

This script is for educational and analytical purposes only.

Users are fully responsible for their own decisions.


📚 Educational Note

Use this script to study how the market behaves around the opening auction and whether early extremes are accepted or rejected.

## Source Code

````pine
// --------------------------------------------------
// Opening Auction Trap Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Opening Auction Trap Map studies whether the first session auction accepts
// value, rejects an early extreme, or traps breakout participants. It builds
// an opening auction box, acceptance rails, failed-auction trap zones, curated
// labels, alerts, a 0-100 quality score, and independent outcome-proof samples.
// Version 1.4 separates map badges and compacts event labels to prevent overlap.
// --------------------------------------------------

//@version=6
indicator("Opening Auction Trap Map [AGPro Series]",
     shorttitle = "AG Pro OAT",
     overlay = true,
     max_labels_count = 100,
     max_lines_count = 12,
     max_boxes_count = 8)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_SESSION = "Auction Sessions"
string G_ENGINE  = "Auction Trap Engine"
string G_PROOF   = "Confirm-Rate Proof"
string G_VISUAL  = "Visuals"
string G_PANEL   = "Panel"
string G_ALERTS  = "Alerts"

string auctionSession = input.session("0930-1000", "Opening Auction Window", group = G_SESSION,
     tooltip = "Session window used to build the opening auction high, low, and midpoint. Uses the exchange timezone of the chart symbol.")
string activeSession = input.session("0930-1600", "Active Session Window", group = G_SESSION,
     tooltip = "Main session where post-auction acceptance and trap behavior are evaluated.")
int maxChartTfMinutes = input.int(30, "Max Chart TF Minutes", minval = 1, maxval = 240, group = G_SESSION,
     tooltip = "Maximum chart timeframe that should build the opening auction map. The default 30-minute auction window is best read on 30m and lower charts.")
bool showIntradayOnlyNotice = input.bool(true, "Show Intraday Notice", group = G_SESSION,
     tooltip = "Shows an intraday-only state in the panel on daily or higher chart timeframes.")

int acceptBars = input.int(2, "Acceptance Close Count", minval = 1, maxval = 10, group = G_ENGINE,
     tooltip = "Number of consecutive closes beyond the auction edge required before the move is classified as accepted.")
int trapLookbackBars = input.int(36, "Trap Evaluation Window", minval = 3, maxval = 300, group = G_ENGINE,
     tooltip = "Number of bars after the auction where failed breakouts are treated as opening-auction trap candidates.")
int wickQualityThreshold = input.int(45, "Trap Wick Quality Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum wick rejection quality needed before a failed auction extreme receives a trap label.")
bool volumeConfirm = input.bool(true, "Use Volume Confirmation", group = G_ENGINE,
     tooltip = "Adds relative volume to trap and acceptance quality scoring when volume data is available.")
int volumeLen = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume with recent activity.")
int zoneAtrLen = input.int(14, "Zone ATR Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ATR length used to size trap zones and label offsets.")
float trapZoneAtr = input.float(0.18, "Trap Zone Width ATR", minval = 0.03, maxval = 2.0, step = 0.01, group = G_ENGINE,
     tooltip = "Thickness of failed-auction trap zones around the auction high and low.")

int proofWindow = input.int(16, "Proof Window Bars", minval = 4, maxval = 200, group = G_PROOF,
     tooltip = "Bars used to resolve each outcome-proof sample after a trap or acceptance signal.")
float proofTargetAtr = input.float(0.6, "Proof Target ATR", minval = 0.10, maxval = 4.0, step = 0.05, group = G_PROOF,
     tooltip = "Symmetric distance, in ATR, used by Outcome Proof. A win is recorded when price travels this far in the signal direction from the trigger close before closing the same distance against it.")

bool showAuctionBox = input.bool(true, "Show Auction Box", group = G_VISUAL,
     tooltip = "Displays the opening auction range as a projected box.")
bool showTrapZones = input.bool(true, "Show Trap Zones", group = G_VISUAL,
     tooltip = "Displays soft upper and lower trap zones around the auction extremes.")
bool showAcceptanceRail = input.bool(true, "Show Acceptance Rail", group = G_VISUAL,
     tooltip = "Draws the midpoint rail used to read range control after the auction completes.")
bool showOutcomeBridge = input.bool(true, "Show Auction Outcome Bridge", group = G_VISUAL,
     tooltip = "Draws a clean bridge from the opening auction reference toward the current outcome so the post-auction story is easier to read.")
bool showEventLabels = input.bool(true, "Show Auction Event Labels", group = G_VISUAL,
     tooltip = "Prints curated labels for upper traps, lower traps, acceptance moves, and failed-auction retests.")
string eventLabelMode = input.string("Premium", "Event Label Mode", options = ["Premium", "Detailed"], group = G_VISUAL,
     tooltip = "Premium mode focuses on traps and accepted moves. Detailed mode also prints lower-priority retest labels.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for auction high, low, and active auction state.")
bool showAuctionMarkers = input.bool(false, "Show Auction Build Markers", group = G_VISUAL,
     tooltip = "Shows small markers while the opening auction window is building. Disabled by default for cleaner publication screenshots.")
int projectionBars = input.int(28, "Projection Bars", minval = 6, maxval = 180, group = G_VISUAL,
     tooltip = "How far the auction box, trap zones, and right-side tags project to the right. Lower values keep intraday auction tags closer to the active candles.")
int labelCooldownBars = input.int(18, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable.")
int maxVisibleLabels = input.int(12, "Maximum Event Labels", minval = 4, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum number of historical auction labels retained on the chart.")
float eventLabelOffsetAtr = input.float(1.25, "Event Label Offset ATR", minval = 0.20, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles and auction zones to reduce overlap.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Text size used by event labels, zone labels, and right-side tags.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro opening auction panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a high-contrast dark AGPro surface and a clean light surface.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Text size used inside the panel.")

bool alertUpperTrap = input.bool(true, "Alert: Upper Auction Trap", group = G_ALERTS,
     tooltip = "Enables alerts when price fails above the opening auction high and closes back inside the auction range.")
bool alertLowerTrap = input.bool(true, "Alert: Lower Auction Trap", group = G_ALERTS,
     tooltip = "Enables alerts when price fails below the opening auction low and closes back inside the auction range.")
bool alertAcceptUp = input.bool(true, "Alert: Accepted Above Auction", group = G_ALERTS,
     tooltip = "Enables alerts when price accepts above the opening auction high.")
bool alertAcceptDown = input.bool(true, "Alert: Accepted Below Auction", group = G_ALERTS,
     tooltip = "Enables alerts when price accepts below the opening auction low.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_score_text(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? color.rgb(15, 23, 42) : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeName) =>
    themeName == "Light" ? color.rgb(148, 163, 184) : color.rgb(86, 103, 130)

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : color.rgb(190, 202, 220)

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_panel_color(color sourceColor, string themeName) =>
    if themeName == "Light"
        sourceColor == bullColor ? color.rgb(5, 105, 88) : sourceColor == bearColor ? color.rgb(190, 24, 93) : sourceColor == neutralColor ? color.rgb(146, 92, 10) : sourceColor == accentColor ? color.rgb(67, 56, 202) : color.rgb(15, 23, 42)
    else
        sourceColor == panelValueCol ? color.rgb(245, 247, 250) : sourceColor

f_set_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeName) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = f_panel_color(rightColor, themeName), bgcolor = rowBg, text_size = f_size(sizeName), text_halign = text.align_right)

f_keep_label(array<label> labelArray, label newLabel, int limit) =>
    array.push(labelArray, newLabel)
    if array.size(labelArray) > limit
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// --------------------------------------------------
// Auction State Engine
// --------------------------------------------------
bool isIntraday = timeframe.isintraday
int chartTfSec = timeframe.in_seconds(timeframe.period)
bool isChartTfSupported = isIntraday and chartTfSec <= maxChartTfMinutes * 60
string tfScopeText = not isIntraday ? "Intraday required" : isChartTfSupported ? "<= " + str.tostring(maxChartTfMinutes) + "m active" : "<= " + str.tostring(maxChartTfMinutes) + "m required"
bool inAuction = isChartTfSupported and not na(time(timeframe.period, auctionSession))
bool inActiveSession = isChartTfSupported and not na(time(timeframe.period, activeSession))
bool auctionStart = inAuction and not inAuction[1]
bool auctionEnd = not inAuction and inAuction[1]
bool activeSessionStart = inActiveSession and not inActiveSession[1]

labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)
float atr = ta.atr(zoneAtrLen)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float volBase = ta.sma(nz(volume, 0.0), volumeLen)
float relVol = not na(volBase) and volBase > 0.0 ? volume / volBase : 1.0
float volBoost = volumeConfirm ? f_clamp(relVol, 0.5, 2.0) : 1.0

var float auctionHigh = na
var float auctionLow = na
var float auctionOpen = na
var int auctionStartBar = na
var int auctionEndBar = na
var int barsAfterAuction = na
var bool auctionReady = false
var bool acceptedUpMemory = false
var bool acceptedDownMemory = false

if activeSessionStart and not inAuction
    acceptedUpMemory := false
    acceptedDownMemory := false

if auctionStart
    auctionHigh := high
    auctionLow := low
    auctionOpen := open
    auctionStartBar := bar_index
    auctionEndBar := na
    barsAfterAuction := na
    auctionReady := false
    acceptedUpMemory := false
    acceptedDownMemory := false

if inAuction
    auctionHigh := na(auctionHigh) ? high : math.max(auctionHigh, high)
    auctionLow := na(auctionLow) ? low : math.min(auctionLow, low)

if auctionEnd
    auctionEndBar := bar_index - 1
    barsAfterAuction := 0
    auctionReady := not na(auctionHigh) and not na(auctionLow) and auctionHigh > auctionLow

if auctionReady and not inAuction
    barsAfterAuction := na(barsAfterAuction) ? 1 : barsAfterAuction + 1

float auctionRange = auctionReady ? math.max(auctionHigh - auctionLow, syminfo.mintick) : na
float auctionMid = auctionReady ? (auctionHigh + auctionLow) * 0.5 : na
float trapZoneWidth = auctionReady ? math.max(syminfo.mintick, math.min(safeAtr * trapZoneAtr, auctionRange * 0.22)) : na
float upperTrapTop = auctionReady ? auctionHigh + trapZoneWidth : na
float upperTrapBottom = auctionReady ? auctionHigh - trapZoneWidth : na
float lowerTrapTop = auctionReady ? auctionLow + trapZoneWidth : na
float lowerTrapBottom = auctionReady ? auctionLow - trapZoneWidth : na
bool withinTrapWindow = auctionReady and inActiveSession and not na(barsAfterAuction) and barsAfterAuction <= trapLookbackBars

float barRange = math.max(high - low, syminfo.mintick)
float upperWickQuality = f_clamp((high - math.max(open, close)) / barRange * 100.0, 0.0, 100.0)
float lowerWickQuality = f_clamp((math.min(open, close) - low) / barRange * 100.0, 0.0, 100.0)
float closeLocation = auctionReady ? f_clamp((close - auctionLow) / auctionRange * 100.0, 0.0, 100.0) : 50.0

bool aboveAuction = auctionReady and close > auctionHigh
bool belowAuction = auctionReady and close < auctionLow
bool insideAuction = auctionReady and close <= auctionHigh and close >= auctionLow
int barsAbove = auctionReady ? nz(ta.barssince(not aboveAuction), 10000) : 0
int barsBelow = auctionReady ? nz(ta.barssince(not belowAuction), 10000) : 0

bool upperTrap = withinTrapWindow and high > auctionHigh and close < auctionHigh and upperWickQuality >= wickQualityThreshold
bool lowerTrap = withinTrapWindow and low < auctionLow and close > auctionLow and lowerWickQuality >= wickQualityThreshold
bool acceptedUp = withinTrapWindow and barsAbove >= acceptBars and close > auctionHigh
bool acceptedDown = withinTrapWindow and barsBelow >= acceptBars and close < auctionLow
bool failedRetest = eventLabelMode == "Detailed" and withinTrapWindow and insideAuction and (high >= auctionHigh or low <= auctionLow) and not upperTrap and not lowerTrap

float upperTrapQ = f_clamp(upperWickQuality * 0.60 + (100.0 - closeLocation) * 0.20 + volBoost * 10.0, 0.0, 100.0)
float lowerTrapQ = f_clamp(lowerWickQuality * 0.60 + closeLocation * 0.20 + volBoost * 10.0, 0.0, 100.0)
float acceptUpQ = f_clamp((closeLocation - 50.0) * 1.2 + barsAbove * 10.0 + volBoost * 12.0, 0.0, 100.0)
float acceptDownQ = f_clamp((50.0 - closeLocation) * 1.2 + barsBelow * 10.0 + volBoost * 12.0, 0.0, 100.0)
float activeQ = upperTrap ? upperTrapQ : lowerTrap ? lowerTrapQ : acceptedUp ? acceptUpQ : acceptedDown ? acceptDownQ : auctionReady ? f_clamp(math.abs(closeLocation - 50.0) * 1.4 + 35.0, 0.0, 100.0) : na

bool newAcceptedUp = acceptedUp and not acceptedUpMemory
bool newAcceptedDown = acceptedDown and not acceptedDownMemory
if newAcceptedUp
    acceptedUpMemory := true
if newAcceptedDown
    acceptedDownMemory := true

// --------------------------------------------------
// Outcome Proof
// On a new trap or acceptance signal, a win is recorded when price travels the
// proof target distance in the signal direction before closing an equal
// distance against it (a symmetric continuation-versus-reversal test).
// --------------------------------------------------
bool newUpperTrap = upperTrap and not upperTrap[1]
bool newLowerTrap = lowerTrap and not lowerTrap[1]

int signalDir = newUpperTrap ? -1 : newLowerTrap ? 1 : newAcceptedUp ? 1 : newAcceptedDown ? -1 : 0
bool signalEvent = barstate.isconfirmed and signalDir != 0

var int proofTotal = 0
var int proofWin = 0
var array<int> proofDirs = array.new<int>()
var array<float> proofAnchors = array.new<float>()
var array<float> proofMargins = array.new<float>()
var array<int> proofStartBars = array.new<int>()

if barstate.isconfirmed
    proofCountAtOpen = array.size(proofDirs)
    if proofCountAtOpen > 0
        for step = 0 to proofCountAtOpen - 1
            i = proofCountAtOpen - 1 - step
            proofDir = array.get(proofDirs, i)
            proofAnchor = array.get(proofAnchors, i)
            proofMargin = array.get(proofMargins, i)
            proofStart = array.get(proofStartBars, i)
            if bar_index > proofStart
                proofFav = proofAnchor + proofDir * proofMargin
                proofFail = proofAnchor - proofDir * proofMargin
                proofHitFav = proofDir == 1 ? high >= proofFav : low <= proofFav
                proofHitFail = proofDir == 1 ? close <= proofFail : close >= proofFail
                proofExpired = bar_index - proofStart >= proofWindow
                if proofHitFav or proofHitFail or proofExpired
                    proofTotal += 1
                    if proofHitFav and not proofHitFail
                        proofWin += 1
                    array.remove(proofDirs, i)
                    array.remove(proofAnchors, i)
                    array.remove(proofMargins, i)
                    array.remove(proofStartBars, i)
    if signalEvent
        array.push(proofDirs, signalDir)
        array.push(proofAnchors, close)
        array.push(proofMargins, proofTargetAtr * safeAtr)
        array.push(proofStartBars, bar_index)

float followRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

int state = not isIntraday ? 9 : not isChartTfSupported ? 8 : not auctionReady ? 0 : upperTrap ? -2 : lowerTrap ? 2 : acceptedUp ? 1 : acceptedDown ? -1 : insideAuction ? 3 : aboveAuction ? 4 : belowAuction ? -4 : 0
string stateText = state == 9 ? "Intraday Only" : state == 8 ? "TF Too High" : state == -2 ? "Upper Trap" : state == 2 ? "Lower Trap" : state == 1 ? "Accept Up" : state == -1 ? "Accept Down" : state == 3 ? "Range Control" : state == 4 ? "Above Auction" : state == -4 ? "Below Auction" : inAuction ? "Building" : "Wait Auction"
color stateColor = state == -2 ? bearColor : state == 2 ? bullColor : state == 1 ? bullColor : state == -1 ? bearColor : state == 3 ? neutralColor : state == 4 ? color.rgb(96, 165, 250) : state == -4 ? color.rgb(251, 113, 133) : accentColor
string nextContext = state == 9 ? "Use intraday chart" : state == 8 ? "Use <= " + str.tostring(maxChartTfMinutes) + "m chart" : state == -2 ? "Fade failed high" : state == 2 ? "Fade failed low" : state == 1 ? "Accepted higher" : state == -1 ? "Accepted lower" : state == 3 ? "Watch range edge" : state == 4 ? "Hold above high" : state == -4 ? "Hold below low" : inAuction ? "Build auction" : "Wait for open"
string rangeControlText = not auctionReady ? "Not ready" : close > auctionHigh ? "Above range" : close < auctionLow ? "Below range" : close > auctionMid ? "Upper half" : close < auctionMid ? "Lower half" : "Midpoint"
string trapRiskText = upperTrap ? "Upper trap active" : lowerTrap ? "Lower trap active" : withinTrapWindow ? "Trap window open" : auctionReady ? "Trap window closed" : "Not ready"
string followRateText = na(followRate) ? "Building" : str.tostring(math.round(followRate)) + "% (" + str.tostring(proofTotal) + ")"
color followRateColor = na(followRate) ? panelValueCol : followRate >= 55.0 ? bullColor : followRate >= 40.0 ? neutralColor : bearColor

// --------------------------------------------------
// Visual Structure
// --------------------------------------------------
var box auctionBox = na
var box upperTrapBox = na
var box lowerTrapBox = na
var line midLine = na
var line outcomeBridge = na
var label auctionLabel = na
var label upperTrapLabel = na
var label lowerTrapLabel = na
var label outcomeLabel = na
var label upperTag = na
var label lowerTag = na
var label midTag = na
var label stateTag = na
var array<label> eventLabels = array.new<label>()

int visualLeft = na(auctionStartBar) ? math.max(bar_index - 80, 0) : auctionStartBar
int visualRight = bar_index + projectionBars
int labelMidX = int(math.round((visualLeft + visualRight) * 0.5))
int auctionBadgeX = visualLeft + int(math.round((visualRight - visualLeft) * 0.28))

if barstate.islast and auctionReady and showAuctionBox
    if na(auctionBox)
        auctionBox := box.new(visualLeft, auctionHigh, visualRight, auctionLow, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 28), border_width = 1)
    else
        box.set_lefttop(auctionBox, visualLeft, auctionHigh)
        box.set_rightbottom(auctionBox, visualRight, auctionLow)
        box.set_bgcolor(auctionBox, color.new(accentColor, 90))
        box.set_border_color(auctionBox, color.new(accentColor, 28))
    string auctionLabelText = "AUCTION | Q " + f_score_text(activeQ)
    if na(auctionLabel)
        auctionLabel := label.new(auctionBadgeX, auctionMid, auctionLabelText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(accentColor), color = color.new(accentColor, 0), size = labelSize, textalign = text.align_center)
    else
        label.set_xy(auctionLabel, auctionBadgeX, auctionMid)
        label.set_text(auctionLabel, auctionLabelText)
        label.set_color(auctionLabel, color.new(accentColor, 0))
        label.set_textcolor(auctionLabel, f_text_on(accentColor))
        label.set_size(auctionLabel, labelSize)

if barstate.islast and (not showAuctionBox or not auctionReady)
    if not na(auctionBox)
        box.delete(auctionBox)
        auctionBox := na
    if not na(auctionLabel)
        label.delete(auctionLabel)
        auctionLabel := na

if barstate.islast and auctionReady and showTrapZones
    if na(upperTrapBox)
        upperTrapBox := box.new(visualLeft, upperTrapTop, visualRight, upperTrapBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 88), border_color = color.new(bearColor, 35), border_width = 1)
    else
        box.set_lefttop(upperTrapBox, visualLeft, upperTrapTop)
        box.set_rightbottom(upperTrapBox, visualRight, upperTrapBottom)
        box.set_bgcolor(upperTrapBox, color.new(bearColor, 88))
        box.set_border_color(upperTrapBox, color.new(bearColor, 35))
    if na(lowerTrapBox)
        lowerTrapBox := box.new(visualLeft, lowerTrapTop, visualRight, lowerTrapBottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 88), border_color = color.new(bullColor, 35), border_width = 1)
    else
        box.set_lefttop(lowerTrapBox, visualLeft, lowerTrapTop)
        box.set_rightbottom(lowerTrapBox, visualRight, lowerTrapBottom)
        box.set_bgcolor(lowerTrapBox, color.new(bullColor, 88))
        box.set_border_color(lowerTrapBox, color.new(bullColor, 35))
    if na(upperTrapLabel)
        upperTrapLabel := label.new(labelMidX, (upperTrapTop + upperTrapBottom) * 0.5, "UPPER TRAP ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = labelSize)
    label.set_xy(upperTrapLabel, labelMidX, (upperTrapTop + upperTrapBottom) * 0.5)
    label.set_size(upperTrapLabel, labelSize)
    if na(lowerTrapLabel)
        lowerTrapLabel := label.new(labelMidX, (lowerTrapTop + lowerTrapBottom) * 0.5, "LOWER TRAP ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(bullColor), color = color.new(bullColor, 0), size = labelSize)
    label.set_xy(lowerTrapLabel, labelMidX, (lowerTrapTop + lowerTrapBottom) * 0.5)
    label.set_size(lowerTrapLabel, labelSize)

if barstate.islast and (not showTrapZones or not auctionReady)
    if not na(upperTrapBox)
        box.delete(upperTrapBox)
        upperTrapBox := na
    if not na(lowerTrapBox)
        box.delete(lowerTrapBox)
        lowerTrapBox := na
    if not na(upperTrapLabel)
        label.delete(upperTrapLabel)
        upperTrapLabel := na
    if not na(lowerTrapLabel)
        label.delete(lowerTrapLabel)
        lowerTrapLabel := na

if barstate.islast and auctionReady and showAcceptanceRail
    if na(midLine)
        midLine := line.new(visualLeft, auctionMid, visualRight, auctionMid, xloc = xloc.bar_index, color = color.new(neutralColor, 15), width = 2, style = line.style_dotted)
    else
        line.set_xy1(midLine, visualLeft, auctionMid)
        line.set_xy2(midLine, visualRight, auctionMid)
        line.set_color(midLine, color.new(neutralColor, 15))
        line.set_width(midLine, 2)
        line.set_style(midLine, line.style_dotted)
    int midTagX = visualRight + 5
    if na(midTag)
        midTag := label.new(midTagX, auctionMid, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(neutralColor), color = color.new(neutralColor, 0), size = labelSize)
    label.set_xy(midTag, midTagX, auctionMid)
    label.set_text(midTag, "Auction Mid " + f_fmt(auctionMid))
    label.set_size(midTag, labelSize)

if barstate.islast and (not showAcceptanceRail or not auctionReady)
    if not na(midLine)
        line.delete(midLine)
        midLine := na
    if not na(midTag)
        label.delete(midTag)
        midTag := na

bool bridgeState = state == 1 or state == -1 or state == 2 or state == -2 or state == 3 or state == 4 or state == -4
float bridgeAnchor = state == 1 or state == 4 or state == -2 ? auctionHigh : state == -1 or state == -4 or state == 2 ? auctionLow : auctionMid
int rawBridgeStartX = na(auctionEndBar) ? visualLeft : auctionEndBar
int bridgeStartX = math.max(rawBridgeStartX, bar_index - math.max(8, int(math.round(projectionBars * 0.65))))
int bridgeMidX = int(math.round((bridgeStartX + bar_index) * 0.5))
float bridgeMidY = not na(bridgeAnchor) ? (bridgeAnchor + close) * 0.5 : na
string bridgeText = state == 1 or state == 4 ? "Accepted Higher" : state == -1 or state == -4 ? "Accepted Lower" : state == 2 ? "Lower Trap" : state == -2 ? "Upper Trap" : "Range Control"

if barstate.islast and auctionReady and showOutcomeBridge and bridgeState and not inAuction
    if na(outcomeBridge)
        outcomeBridge := line.new(bridgeStartX, bridgeAnchor, bar_index, close, xloc = xloc.bar_index, extend = extend.none, color = color.new(stateColor, 28), style = line.style_dotted, width = 2)
    else
        line.set_xy1(outcomeBridge, bridgeStartX, bridgeAnchor)
        line.set_xy2(outcomeBridge, bar_index, close)
        line.set_color(outcomeBridge, color.new(stateColor, 28))
        line.set_style(outcomeBridge, line.style_dotted)
        line.set_width(outcomeBridge, 2)
    if na(outcomeLabel)
        outcomeLabel := label.new(bridgeMidX, bridgeMidY, bridgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(stateColor), color = color.new(stateColor, 0), size = labelSize)
    else
        label.set_xy(outcomeLabel, bridgeMidX, bridgeMidY)
        label.set_text(outcomeLabel, bridgeText)
        label.set_color(outcomeLabel, color.new(stateColor, 0))
        label.set_textcolor(outcomeLabel, f_text_on(stateColor))
        label.set_size(outcomeLabel, labelSize)

if barstate.islast and (not showOutcomeBridge or not auctionReady or not bridgeState or inAuction)
    if not na(outcomeBridge)
        line.delete(outcomeBridge)
        outcomeBridge := na
    if not na(outcomeLabel)
        label.delete(outcomeLabel)
        outcomeLabel := na

plotshape(showAuctionMarkers and isIntraday and inAuction, title = "Auction Building", style = shape.circle, location = location.top, color = color.new(accentColor, 0), size = size.tiny)

// --------------------------------------------------
// Labels and Right Tags
// --------------------------------------------------
bool eventCandidate = barstate.isconfirmed and (upperTrap or lowerTrap or newAcceptedUp or newAcceptedDown or failedRetest)
var int lastEventBar = na
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
float eventY = upperTrap or newAcceptedDown ? high + safeAtr * eventLabelOffsetAtr : lowerTrap or newAcceptedUp ? low - safeAtr * eventLabelOffsetAtr : close
eventStyle = upperTrap or newAcceptedDown ? label.style_label_down : lowerTrap or newAcceptedUp ? label.style_label_up : label.style_label_center
string eventText = upperTrap ? "UPPER TRAP | Q " + f_score_text(upperTrapQ) : lowerTrap ? "LOWER TRAP | Q " + f_score_text(lowerTrapQ) : newAcceptedUp ? "ACCEPT UP | Q " + f_score_text(acceptUpQ) : newAcceptedDown ? "ACCEPT DOWN | Q " + f_score_text(acceptDownQ) : "FAILED RETEST | Q " + f_score_text(activeQ)
color eventCol = upperTrap or newAcceptedDown ? bearColor : lowerTrap or newAcceptedUp ? bullColor : neutralColor

if showEventLabels and eventCandidate and canPrintEvent
    label newLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, textcolor = f_text_on(eventCol), color = color.new(eventCol, 4), size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, newLabel, maxVisibleLabels)
    lastEventBar := bar_index

if barstate.islast and auctionReady and showRightTags
    int tagX = bar_index + projectionBars
    int stateTagX = tagX + 9
    if na(upperTag)
        upperTag := label.new(tagX, auctionHigh, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = labelSize)
    label.set_xy(upperTag, tagX, auctionHigh)
    label.set_text(upperTag, "Auction High " + f_fmt(auctionHigh))
    label.set_size(upperTag, labelSize)
    if na(lowerTag)
        lowerTag := label.new(tagX, auctionLow, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bullColor), color = color.new(bullColor, 0), size = labelSize)
    label.set_xy(lowerTag, tagX, auctionLow)
    label.set_text(lowerTag, "Auction Low " + f_fmt(auctionLow))
    label.set_size(lowerTag, labelSize)
    if na(stateTag)
        stateTag := label.new(stateTagX, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(stateColor), color = color.new(stateColor, 0), size = labelSize)
    label.set_xy(stateTag, stateTagX, close)
    label.set_text(stateTag, str.upper(stateText) + " | Q " + f_score_text(activeQ))
    label.set_color(stateTag, color.new(stateColor, 0))
    label.set_textcolor(stateTag, f_text_on(stateColor))
    label.set_size(stateTag, labelSize)

if barstate.islast and (not showRightTags or not auctionReady)
    if not na(upperTag)
        label.delete(upperTag)
        upperTag := na
    if not na(lowerTag)
        label.delete(lowerTag)
        lowerTag := na
    if not na(stateTag)
        label.delete(stateTag)
        stateTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = f_panel_bg(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, border_color = f_panel_border(panelTheme), border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelTheme

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 0, 1, 8)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Opening Auction Trap Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_set_row(panel, 1, "Auction State", stateText, stateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 2, "Quality Score", f_score_text(activeQ) + " / 100", stateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 3, "Auction High / Low", f_fmt(auctionHigh) + " / " + f_fmt(auctionLow), panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 4, "Range Control", rangeControlText, panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 5, "Trap Risk", trapRiskText, upperTrap or lowerTrap ? stateColor : panelValueCol, panelTheme, panelFontSizeInput)
    f_set_row(panel, 6, "Outcome Proof", followRateText, followRateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 7, "Action", nextContext, stateColor, panelTheme, panelFontSizeInput)
    f_set_row(panel, 8, "TF Scope", showIntradayOnlyNotice and not isIntraday ? "Intraday required" : tfScopeText, isChartTfSupported ? panelValueCol : neutralColor, panelTheme, panelFontSizeInput)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
bool upperTrapEvent = barstate.isconfirmed and upperTrap and not upperTrap[1]
bool lowerTrapEvent = barstate.isconfirmed and lowerTrap and not lowerTrap[1]
bool acceptUpEvent = barstate.isconfirmed and newAcceptedUp
bool acceptDownEvent = barstate.isconfirmed and newAcceptedDown

alertcondition(alertUpperTrap and upperTrapEvent, "Upper Opening Auction Trap", "Opening Auction Trap Map: price failed above the opening auction high and closed back inside the auction range.")
alertcondition(alertLowerTrap and lowerTrapEvent, "Lower Opening Auction Trap", "Opening Auction Trap Map: price failed below the opening auction low and closed back inside the auction range.")
alertcondition(alertAcceptUp and acceptUpEvent, "Accepted Above Opening Auction", "Opening Auction Trap Map: price accepted above the opening auction high.")
alertcondition(alertAcceptDown and acceptDownEvent, "Accepted Below Opening Auction", "Opening Auction Trap Map: price accepted below the opening auction low.")
````
