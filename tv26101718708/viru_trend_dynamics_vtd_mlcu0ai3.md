# Viru Trend Dynamics [VTD]

- url: https://www.tradingview.com/script/MLcU0Ai3-Viru-Trend-Dynamics-VTD/
- type: indicator
- pine_id: PUB;e45552bd27aa45359df1cb64ac4869fa
- version: 1.0

## Description

[b]Viru Trend Dynamics [VTD][/b]
Viru Trend Dynamics is a trend-following indicator that combines confirmed BUY/SELL signals with defined entry, stop-loss, target, and trailing-stop levels. It tracks one virtual position at a time to keep the trade sequence clear and prevent overlapping signals.

[b]Entry logic[/b]
The indicator uses ALMA, deviation bands, and ATR-normalized slope. A BUY requires positive slope strength and a confirmed candle close above the upper band. A SELL requires negative slope strength and a confirmed close below the lower band.

While a position is active, no additional entry or reversal is generated. The trend ribbon can change colour without closing the position. After an exit, the indicator skips the exit candle and allows a new entry from the next confirmed candle when the complete setup is valid. A fresh trend flip is not required.

[b]Stop-loss, targets, and trailing[/b]

The initial stop distance uses prior price structure, bounded by configurable minimum and maximum ATR distances. This distance defines 1R for that trade.

Users can choose a fixed target from 1:1 to 1:6, or select Trail only. There are no partial exits.
Two trailing methods are available:

- ATR: Follows the highest post-entry high for BUY trades or the lowest post-entry low for SELL trades, using an ATR distance.
- ALMA: Follows the confirmed ALMA value with a configurable ATR buffer below it for BUY trades and above it for SELL trades.

Trailing activates after the selected favourable R move. The protective stop can tighten but never loosen. Trail updates occur at candle close and apply prospectively. If the close has already crossed the newly calculated trail, a close-price exit is recorded.
Chart display and alerts

Each trade has separate blue entry, orange stop-loss, and green target lines. Exit markers keep the chart uncluttered:
- Green diamond: Target reached.
- Red cross: Initial stop-loss exit.
- Amber diamond: Trailing exit.

Hover over an exit marker for its details. The dashboard displays the active trade levels, target mode, trailing method, and current status.
Alerts are available for BUY, SELL, target, initial SL, and trailing exits. Select Once Per Bar Close. Optional direction and entry-session filters are also included; the session filter does not force positions to close.
Important limitations

This indicator tracks virtual trades, not broker executions, and does not model commission, slippage, or position sizing. Exit tracking starts after the entry candle. If the existing SL and target are touched in the same candle, the indicator assumes SL first because the intrabar sequence is unknown. Exit alerts confirm at candle close.
Use standard candlestick charts. Performance depends on the instrument, timeframe, and settings. Defaults are starting values, not verified optimal settings, and a selected target ratio does not guarantee that reward on every winning trade.
Attribution

The original ALMA entry logic is adapted from [b]BOSWaves[/b]. This version adds single-position management, confirmed re-entry, selectable risk–reward targets, ATR/ALMA trailing methods, separate trade-level drawings, exit symbols, alerts, and a dashboard.

## Source Code

````pine
// Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/
// Viru Trend Dynamics [VTD]
// Original ALMA entry logic adapted from BOSWaves.
// Added features: position locking, confirmed re-entry,
// selectable risk-reward targets, and ATR/ALMA trailing stops.
//@version=6
indicator("Viru Trend Dynamics [VTD]", overlay=true,
     max_lines_count=500, max_labels_count=500)

// Confirmed-close entries; entry reference = candle close.
// Exit tracking starts on the following candle.
// Existing SL is checked before updating the trailing level.
// If SL and target touch together, stop-first convention applies.
// Indicator tracks virtual positions, not broker executions.

// ─────────────────────────────────────────────────────────────
// TREND SETTINGS
// ─────────────────────────────────────────────────────────────
string g1 = "1 • Trend Settings"

src = input.source(close, "Source", group=g1)
trendLength = input.int(34, "Trend Length", minval=5, group=g1)
trendOffset = input.float(0.85, "Trend Offset",
     minval=0, maxval=1, group=g1)
trendSigma = input.float(6, "Trend Sigma", minval=0.1, group=g1)
devLength = input.int(34, "Deviation Length", minval=5, group=g1)
bandMultiplier = input.float(0.65, "Confirmation Band",
     minval=0, group=g1)
slopeLength = input.int(3, "Slope Lookback", minval=1, group=g1)
minimumSlope = input.float(0.08, "Minimum Slope / ATR",
     minval=0, group=g1)
atrLength = input.int(14, "ATR Length", minval=1, group=g1)

// ─────────────────────────────────────────────────────────────
// INITIAL STOP
// ─────────────────────────────────────────────────────────────
string g2 = "2 • Initial Stop"

stopLookback = input.int(12, "Prior Structure Lookback",
     minval=1, group=g2)
minimumATR = input.float(0.75, "Minimum SL Distance — ATR",
     minval=0.01, group=g2)
maximumATR = input.float(3, "Maximum SL Distance — ATR",
     minval=0.01, group=g2)

// ─────────────────────────────────────────────────────────────
// TARGET AND TRAILING METHOD
// ─────────────────────────────────────────────────────────────
string g3 = "3 • Target and Trailing"

targetChoice = input.string("1:3", "Target Risk : Reward",
     options=["1:1", "1:2", "1:3", "1:4", "1:5", "1:6", "Trail only"],
     group=g3)

enableTrail = input.bool(true, "Enable Trailing SL", group=g3)

trailingMethod = input.string("ATR", "Trailing Method",
     options=["ATR", "ALMA"], group=g3)

activationR = input.float(2, "Trail Activation — R",
     minval=0.1, step=0.25, group=g3,
     tooltip="Activates after the post-entry high/low reaches this favourable R multiple.")

trailMultiplier = input.float(2, "ATR Method: Distance Multiplier",
     minval=0.1, step=0.25, group=g3,
     tooltip="Used only in ATR mode. Long: highest high minus ATR distance. Short: lowest low plus ATR distance.")

almaBufferATR = input.float(0.25, "ALMA Method: Buffer — ATR",
     minval=0, step=0.05, group=g3,
     tooltip="Used only in ALMA mode. Long: ALMA minus buffer × ATR. Short: ALMA plus buffer × ATR. Zero uses ALMA directly.")

float rr = switch targetChoice
    "1:1" => 1.0
    "1:2" => 2.0
    "1:3" => 3.0
    "1:4" => 4.0
    "1:5" => 5.0
    "1:6" => 6.0
    => na

bool fixedTarget = targetChoice != "Trail only"
bool trailingEnabled = enableTrail or not fixedTarget

// ─────────────────────────────────────────────────────────────
// ENTRY FILTERS
// ─────────────────────────────────────────────────────────────
string g4 = "4 • Entry Filters"

directionChoice = input.string("Both", "Direction",
     options=["Both", "Long only", "Short only"], group=g4)

useSession = input.bool(false, "Restrict Entry Session", group=g4)
entrySession = input.session("0915-1530", "Entry Session", group=g4)
timezone = input.string("Asia/Kolkata", "Session Timezone", group=g4)

// Session restricts entries only; it does not force an exit.

// ─────────────────────────────────────────────────────────────
// DISPLAY
// ─────────────────────────────────────────────────────────────
string g5 = "5 • Display"

showBands = input.bool(true, "Show Trend Ribbon", group=g5)
showLevels = input.bool(true, "Show Trade Levels", group=g5)
showExitMarkers = input.bool(true, "Show Exit Symbols", group=g5)
showDashboard = input.bool(true, "Show Dashboard", group=g5)

bullColor = input.color(#00897B, "Bull Colour", group=g5)
bearColor = input.color(#E53935, "Bear Colour", group=g5)
targetColor = input.color(#2E7D32, "Target Exit Colour", group=g5)
stopColor = input.color(#D32F2F, "Initial SL Exit Colour", group=g5)
trailColor = input.color(#F9A825, "Trailing Exit Colour", group=g5)

// ─────────────────────────────────────────────────────────────
// VALIDATION
// ─────────────────────────────────────────────────────────────
if barstate.isfirst
    if minimumATR > maximumATR
        runtime.error("Minimum SL ATR must be <= Maximum SL ATR.")
    if useSession and not timeframe.isintraday
        runtime.error("Session filtering requires an intraday chart.")

// ─────────────────────────────────────────────────────────────
// TREND CALCULATIONS
// ─────────────────────────────────────────────────────────────
float basis = ta.alma(src, trendLength, trendOffset, trendSigma)
float deviation = ta.stdev(src, devLength)
float atr = ta.atr(atrLength)

float upper = basis + deviation * bandMultiplier
float lower = basis - deviation * bandMultiplier

float priorLow = ta.lowest(low, stopLookback)[1]
float priorHigh = ta.highest(high, stopLookback)[1]

float slope = atr > 0 ?
     (basis - basis[slopeLength]) / atr : 0

bool ready = not na(basis[slopeLength]) and
     not na(deviation) and not na(priorLow) and
     not na(priorHigh) and atr > 0

bool bullishSetup = ready and
     slope > minimumSlope and close > upper

bool bearishSetup = ready and
     slope < -minimumSlope and close < lower

bool sessionOK = not useSession or
     not na(time(timeframe.period, entrySession, timezone))

var int visualTrend = 0

// ─────────────────────────────────────────────────────────────
// VIRTUAL TRADE STATE
// ─────────────────────────────────────────────────────────────
var int activeDirection = 0
var int entryBar = na
var int lastExitBar = na

var float entry = na
var float riskDistance = na
var float protectiveStop = na
var float target = na
var float extreme = na

var bool trailActive = false
var bool stopWasTrailed = false
var string status = "WAITING"

var line entryLine = na
var line stopLine = na
var line targetLine = na

bool buySignal = false
bool sellSignal = false
bool stopExit = false
bool targetExit = false
bool trailCloseExit = false
bool trailingStopExit = false
bool initialStopExit = false

f_level(int x1, int x2, float price, color col) =>
    line.new(x1, price, x2, price,
         xloc=xloc.bar_index, color=col, width=2)

// ─────────────────────────────────────────────────────────────
// CONFIRMED-CANDLE PROCESSING
// ─────────────────────────────────────────────────────────────
if barstate.isconfirmed

    // Trend appearance can update during an open trade.
    // It cannot reverse that trade or generate another entry.
    if bullishSetup
        visualTrend := 1
    else if bearishSetup
        visualTrend := -1

    bool exitedThisBar = false

    if activeDirection != 0 and bar_index > entryBar

        if showLevels
            if not na(entryLine)
                line.set_x2(entryLine, bar_index)
            if not na(stopLine)
                line.set_x2(stopLine, bar_index)
            if not na(targetLine)
                line.set_x2(targetLine, bar_index)

        // Check levels that existed BEFORE this candle.
        bool hitStop = activeDirection == 1 ?
             low <= protectiveStop : high >= protectiveStop

        bool hitTarget = fixedTarget and
             (activeDirection == 1 ? high >= target : low <= target)

        float exitReference = na
        string exitReason = ""
        bool trailingExit = false
        bool ambiguousExit = hitStop and hitTarget

        if hitStop
            stopExit := true

            // Distinguish a genuinely tightened stop from initial SL.
            trailingExit := stopWasTrailed
            trailingStopExit := trailingExit
            initialStopExit := not trailingExit

            exitReference := activeDirection == 1 ?
                 math.min(open, protectiveStop) :
                 math.max(open, protectiveStop)

            exitReason := trailingExit ? "TRAIL SL" : "SL"

        else if hitTarget
            targetExit := true
            exitReference := target
            exitReason := "TARGET " + targetChoice

        else
            // Entry candle high/low is excluded.
            extreme := activeDirection == 1 ?
                 math.max(extreme, high) :
                 math.min(extreme, low)

            float favourableR =
                 activeDirection * (extreme - entry) / riskDistance

            if trailingEnabled and favourableR >= activationR
                trailActive := true

            float nextStop = protectiveStop

            if trailActive

                // ATR mode: follow the best post-entry excursion.
                // ALMA mode: follow the confirmed trend basis with buffer.
                float candidate = trailingMethod == "ATR" ?
                     extreme - activeDirection * atr * trailMultiplier :
                     basis - activeDirection * atr * almaBufferATR

                // Round protective price away from the market.
                candidate := activeDirection == 1 ?
                     math.floor(candidate / syminfo.mintick) * syminfo.mintick :
                     math.ceil(candidate / syminfo.mintick) * syminfo.mintick

                // Never loosen the stop.
                nextStop := activeDirection == 1 ?
                     math.max(protectiveStop, candidate) :
                     math.min(protectiveStop, candidate)

            bool crossedNewStop = activeDirection == 1 ?
                 close <= nextStop : close >= nextStop

            if crossedNewStop
                // Newly calculated level did not exist earlier in this bar.
                // Record an exit at confirmed close.
                trailCloseExit := true
                trailingExit := true
                exitReference := close
                exitReason := "TRAIL CLOSE"

            else
                bool tightened = activeDirection == 1 ?
                     nextStop > protectiveStop :
                     nextStop < protectiveStop

                if tightened
                    stopWasTrailed := true

                    if showLevels
                        // Preserve the previous stop segment.
                        // New level applies after this candle closes.
                        stopLine := f_level(
                             bar_index, bar_index + 1,
                             nextStop, color.orange)

                protectiveStop := nextStop

                status := trailActive ?
                     trailingMethod + " TRAIL ACTIVE" :
                     "INITIAL SL ACTIVE"

        if not na(exitReference)

            if showExitMarkers
                color markerColor = targetExit ? targetColor :
                     trailingExit ? trailColor : stopColor

                string markerTooltip = targetExit ?
                     "Target reached" :
                     trailingExit ?
                     trailingMethod + " trailing exit" :
                     "Initial stop exit"

                markerTooltip := markerTooltip +
                     "\nPrice: " +
                     str.tostring(exitReference, format.mintick)

                if trailCloseExit
                    markerTooltip := markerTooltip +
                         "\nExit at confirmed close after crossing the newly calculated trail."

                if ambiguousExit
                    markerTooltip := markerTooltip +
                         "\nSL and target touched in the same candle." +
                         "\nStop-first convention applied."

                label.new(
                     x=bar_index,
                     y=exitReference,
                     text="",
                     xloc=xloc.bar_index,
                     yloc=yloc.price,
                     style=targetExit or trailingExit ?
                         label.style_diamond :
                         label.style_xcross,
                     color=markerColor,
                     size=size.small,
                     tooltip=markerTooltip)

            lastExitBar := bar_index
            exitedThisBar := true
            activeDirection := 0

            status := exitReason + " — WAIT NEXT CANDLE"

            entry := na
            riskDistance := na
            protectiveStop := na
            target := na
            extreme := na

            trailActive := false
            stopWasTrailed := false

            entryLine := na
            stopLine := na
            targetLine := na

    // Full confirmed setup is required, not a fresh trend flip.
    bool flat = activeDirection == 0
    bool afterExit = na(lastExitBar) or bar_index > lastExitBar

    int wantedDirection =
         bullishSetup and directionChoice != "Short only" ? 1 :
         bearishSetup and directionChoice != "Long only" ? -1 : 0

    // Block new entries during an open trade and on its exit candle.
    if flat and not exitedThisBar and afterExit and
         wantedDirection != 0 and sessionOK

        float rawDistance = wantedDirection == 1 ?
             close - priorLow : priorHigh - close

        float r = math.min(
             math.max(rawDistance, minimumATR * atr),
             maximumATR * atr)

        r := math.max(
             syminfo.mintick,
             math.ceil(r / syminfo.mintick) * syminfo.mintick)

        activeDirection := wantedDirection
        entryBar := bar_index
        entry := close
        riskDistance := r

        protectiveStop := entry - activeDirection * r

        target := fixedTarget ?
             entry + activeDirection * r * rr : na

        extreme := entry
        trailActive := false
        stopWasTrailed := false

        if showLevels
            entryLine := f_level(
                 bar_index, bar_index + 1,
                 entry, color.blue)

            stopLine := f_level(
                 bar_index, bar_index + 1,
                 protectiveStop, color.orange)

            if fixedTarget
                targetLine := f_level(
                     bar_index, bar_index + 1,
                     target, color.green)

        buySignal := wantedDirection == 1
        sellSignal := wantedDirection == -1

        status := wantedDirection == 1 ?
             "LONG — INITIAL SL" : "SHORT — INITIAL SL"

// ─────────────────────────────────────────────────────────────
// CHART
// ─────────────────────────────────────────────────────────────
color trendColor = visualTrend == 1 ? bullColor :
     visualTrend == -1 ? bearColor : color.gray

plot(basis, "Trend Basis", color=trendColor, linewidth=2)

pUpper = plot(showBands ? upper : na, "Upper Band",
     color=color.new(trendColor, 70))

pLower = plot(showBands ? lower : na, "Lower Band",
     color=color.new(trendColor, 70))

fill(pUpper, pLower, color=color.new(trendColor, 93))

plotshape(buySignal, title="VTD BUY",
     style=shape.labelup, location=location.belowbar,
     color=bullColor, text="BUY",
     textcolor=color.white, size=size.small)

plotshape(sellSignal, title="VTD SELL",
     style=shape.labeldown, location=location.abovebar,
     color=bearColor, text="SELL",
     textcolor=color.white, size=size.small)

plot(entry, "Active Entry", display=display.data_window)
plot(protectiveStop, "Active SL", display=display.data_window)
plot(target, "Active Target", display=display.data_window)

// ─────────────────────────────────────────────────────────────
// ALERTS — ONCE PER BAR CLOSE
// ─────────────────────────────────────────────────────────────
alertcondition(buySignal, "VTD BUY",
     "Viru Trend Dynamics BUY | {{ticker}} | {{interval}} | Close {{close}}")

alertcondition(sellSignal, "VTD SELL",
     "Viru Trend Dynamics SELL | {{ticker}} | {{interval}} | Close {{close}}")

alertcondition(initialStopExit, "VTD Initial SL Exit",
     "Viru Trend Dynamics INITIAL SL EXIT | {{ticker}} | {{interval}}")

alertcondition(trailingStopExit, "VTD Trailing SL Exit",
     "Viru Trend Dynamics TRAILING SL EXIT | {{ticker}} | {{interval}}")

alertcondition(targetExit, "VTD Target Exit",
     "Viru Trend Dynamics TARGET EXIT | {{ticker}} | {{interval}}")

alertcondition(trailCloseExit, "VTD Trail Close",
     "Viru Trend Dynamics TRAIL CLOSE EXIT | {{ticker}} | {{interval}}")

// ─────────────────────────────────────────────────────────────
// BRANDED DASHBOARD
// ─────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 10,
     bgcolor=color.new(color.black, 15), border_width=1)

f_row(int row, string name, string value) =>
    table.cell(dash, 0, row, name,
         text_color=color.white,
         text_halign=text.align_left,
         text_size=size.small)

    table.cell(dash, 1, row, value,
         text_color=color.white,
         text_halign=text.align_right,
         text_size=size.small)

if barstate.islast and showDashboard
    f_row(0, "VIRU TREND DYNAMICS", "VTD")
    f_row(1, "Status", status)
    f_row(2, "Target Mode", targetChoice)

    f_row(3, "Entry", na(entry) ? "—" :
         str.tostring(entry, format.mintick))

    f_row(4, "Protective SL", na(protectiveStop) ? "—" :
         str.tostring(protectiveStop, format.mintick))

    f_row(5, "Target", na(target) ? "—" :
         str.tostring(target, format.mintick))

    f_row(6, "Trailing Method",
         trailingEnabled ? trailingMethod : "OFF")

    f_row(7, "Trail Activation",
         trailingEnabled ?
         str.tostring(activationR) + "R" : "—")

    f_row(8, "Re-entry", "Confirmed setup after exit")
    f_row(9, "Exit Symbols", "Green ◆ TP | Red × SL | Amber ◆ Trail")
````
