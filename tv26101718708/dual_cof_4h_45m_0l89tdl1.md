# Dual COF (4H + 45m)

- url: https://www.tradingview.com/script/0l89Tdl1-Dual-COF-4H-45m/
- type: indicator
- pine_id: PUB;422fcbbd86ea4787b07326578ad87b36
- version: 2.0

## Description

This indicator identifies and displays the active Candle of Focus (COF) levels from two timeframes: a higher timeframe, set by default to 4H, and a lower timeframe, set by default to 45 minutes. Instead of drawing rectangular boxes, the indicator draws horizontal rays from the high, low, and optional midpoint of the current active COF candle.
•	The 4H COF rays are thicker by default so they stand out as higher-timeframe context.
•	The 45m COF rays are thinner by default so they can be used as execution or entry-context levels.
•	Only the current active COF for each selected timeframe is displayed. When price closes beyond the active COF high or low, the old rays are deleted and new rays are created from the next COF candle.

## Source Code

````pine
//@version=6
indicator("Dual COF (4H + 45m) - Smart Alerts v2.4 Original COF Engine", overlay=true, max_lines_count=50, max_labels_count=20)

// =====================================================
// TIMEFRAME INPUTS
// =====================================================
tfHTF = input.timeframe("240", "Higher TF COF (4H)", group="Timeframes")
tfLTF = input.timeframe("45", "Lower TF COF (45m)", group="Timeframes")
tfConfirm = input.timeframe("15", "Entry Confirmation TF", group="Timeframes")

// =====================================================
// DISPLAY INPUTS
// =====================================================
showHTF = input.bool(true, "Show 4H COF Rays", group="Display")
showLTF = input.bool(true, "Show 45m COF Rays", group="Display")
showHighLow = input.bool(true, "Show COF High/Low Rays", group="Display")
showMid = input.bool(true, "Show COF 50% Ray", group="Display")

// =====================================================
// LINE WIDTH INPUTS
// =====================================================
htfRayWidth = input.int(3, "4H Ray Width", minval=1, maxval=5, group="Line Widths")
ltfRayWidth = input.int(1, "45m Ray Width", minval=1, maxval=5, group="Line Widths")
midRayWidth = input.int(1, "Midline Width", minval=1, maxval=5, group="Line Widths")

// =====================================================
// COLOUR INPUTS
// =====================================================
htfBullColor = input.color(color.rgb(4, 161, 6), "4H Bullish COF Colour", group="Colours")
htfBearColor = input.color(color.rgb(218, 4, 4), "4H Bearish COF Colour", group="Colours")
ltfBullColor = input.color(color.rgb(4, 168, 10), "45m Bullish COF Colour", group="Colours")
ltfBearColor = input.color(color.rgb(249, 155, 155), "45m Bearish COF Colour", group="Colours")

// =====================================================
// MASTER ALERT CONTROLS
// =====================================================
enableAlerts = input.bool(true, "Enable Alerts", group="Alerts")
alertNewCOF = input.bool(true, "1. New COF Alert", group="Alerts")
alertEntryZones = input.bool(true, "2. Entry Zone Alert", group="Alerts")
alertTradeEntries = input.bool(true, "3. BUY / SELL Trade Entry Alert", group="Alerts")

// =====================================================
// INDIVIDUAL ALERT CONTROLS
// =====================================================
alertHTFNewCOF = input.bool(true, "4H - New COF", group="Individual Alerts")
alertLTFNewCOF = input.bool(true, "45m - New COF", group="Individual Alerts")
alertHTFEntryZone = input.bool(true, "4H - Entry Zone", group="Individual Alerts")
alertLTFEntryZone = input.bool(true, "45m - Entry Zone", group="Individual Alerts")
alertHTFTradeEntry = input.bool(true, "4H - Trade Entry", group="Individual Alerts")
alertLTFTradeEntry = input.bool(true, "45m - Trade Entry", group="Individual Alerts")

// =====================================================
// ENTRY ZONES
// =====================================================
bearEntryPercent = input.float(70.0, "Bearish Entry Level % (Premium)", minval=50.0, maxval=100.0, step=0.5, group="Entry Zones")
bullEntryPercent = input.float(30.0, "Bullish Entry Level % (Discount)", minval=0.0, maxval=50.0, step=0.5, group="Entry Zones")

requireReturnToZone = input.bool(
     true,
     "Require Move Away Before Entry-Zone Return",
     group="Entry Zones",
     tooltip="Bearish: price first moves below the premium level and then returns to it. Bullish: price first moves above the discount level and then returns to it."
)

// =====================================================
// ENTRY CONFIRMATION
// =====================================================
enableHTFTradeSignals = input.bool(true, "Enable 4H Trade Entry Signals", group="Entry Confirmation")
enableLTFTradeSignals = input.bool(true, "Enable 45m Trade Entry Signals", group="Entry Confirmation")

momentumMode = input.string(
     "Price units",
     "Momentum Distance Mode",
     options=["Price units", "Ticks"],
     group="Entry Confirmation"
)

momentumValue = input.float(
     1.0,
     "Momentum Distance",
     minval=0.0,
     step=0.1,
     group="Entry Confirmation",
     tooltip="On XAUUSD in Price units, 1.0 means a $1.00 move."
)

labelLifeSeconds = input.int(
     30,
     "BUY/SELL Label Lifetime (seconds)",
     minval=1,
     maxval=300,
     group="Entry Confirmation"
)

momentumDistance = momentumMode == "Ticks" ? momentumValue * syminfo.mintick : momentumValue

// ============================================================================
// ORIGINAL COF HANDLING
// The following 4H/45m data, new-bar, initialization, break, and drawing logic
// follows the structure of your ORIGINAL indicator.
// ============================================================================

// ================= TIME =================
barMS = timeframe.in_seconds() * 1000

// ================= TIMEFRAME CHECK =================
isLTFChart = timeframe.period == tfLTF
isHTFChart = timeframe.period == tfHTF

// ================= HTF DATA =================
htfOpen = isHTFChart ? open[1] : request.security(syminfo.tickerid, tfHTF, open[1])
htfHigh = isHTFChart ? high[1] : request.security(syminfo.tickerid, tfHTF, high[1])
htfLow = isHTFChart ? low[1] : request.security(syminfo.tickerid, tfHTF, low[1])
htfClose = isHTFChart ? close[1] : request.security(syminfo.tickerid, tfHTF, close[1])
htfTime = isHTFChart ? time[1] : request.security(syminfo.tickerid, tfHTF, time[1])

// ================= LTF DATA =================
ltfOpen = isLTFChart ? open[1] : request.security(syminfo.tickerid, tfLTF, open[1])
ltfHigh = isLTFChart ? high[1] : request.security(syminfo.tickerid, tfLTF, high[1])
ltfLow = isLTFChart ? low[1] : request.security(syminfo.tickerid, tfLTF, low[1])
ltfClose = isLTFChart ? close[1] : request.security(syminfo.tickerid, tfLTF, close[1])
ltfTime = isLTFChart ? time[1] : request.security(syminfo.tickerid, tfLTF, time[1])

// ================= NEW BAR CHECK =================
htfNew = ta.change(htfTime) != 0
ltfNew = ta.change(ltfTime) != 0

// ================= ACTIVE COF COLOURS =================
htfColor = htfClose >= htfOpen ? htfBullColor : htfBearColor
ltfColor = ltfClose >= ltfOpen ? ltfBullColor : ltfBearColor

// ================= MIDPOINTS =================
htfMid = (htfHigh + htfLow) / 2
ltfMid = (ltfHigh + ltfLow) / 2

// ================= LINE STORAGE =================
var line htfHighRay = na
var line htfLowRay = na
var line htfMidRay = na
var line ltfHighRay = na
var line ltfLowRay = na
var line ltfMidRay = na

// ================= COF STORAGE =================
var float htfCofHigh = na
var float htfCofLow = na
var float ltfCofHigh = na
var float ltfCofLow = na

// Added only so the newer alert system knows the ACTIVE COF direction/time.
// These variables do not change the original COF selection logic.
var int htfCofDirection = 0
var int ltfCofDirection = 0
var int htfCofTime = na
var int ltfCofTime = na

// ================= COF CHANGE STATE =================
bool htfChanged = false
bool ltfChanged = false

// ================= HTF INITIALIZATION =================
if na(htfCofHigh) and not na(htfHigh) and not na(htfLow)
    htfCofHigh := htfHigh
    htfCofLow := htfLow
    htfCofDirection := htfClose >= htfOpen ? 1 : -1
    htfCofTime := htfTime

    if showHTF and showHighLow
        htfHighRay := line.new(
             htfTime,
             htfCofHigh,
             htfTime + barMS,
             htfCofHigh,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             width=htfRayWidth
        )

        htfLowRay := line.new(
             htfTime,
             htfCofLow,
             htfTime + barMS,
             htfCofLow,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             width=htfRayWidth
        )

    if showHTF and showMid
        htfMidRay := line.new(
             htfTime,
             htfMid,
             htfTime + barMS,
             htfMid,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=htfColor,
             style=line.style_dashed,
             width=midRayWidth
        )

// ================= HTF COF BREAK =================
if htfNew and not na(htfCofHigh)
    bool htfBreakUp = htfClose > htfCofHigh
    bool htfBreakDown = htfClose < htfCofLow

    if htfBreakUp or htfBreakDown
        if not na(htfHighRay)
            line.delete(htfHighRay)
        if not na(htfLowRay)
            line.delete(htfLowRay)
        if not na(htfMidRay)
            line.delete(htfMidRay)

        htfHighRay := na
        htfLowRay := na
        htfMidRay := na

        htfCofHigh := htfHigh
        htfCofLow := htfLow
        htfCofDirection := htfClose >= htfOpen ? 1 : -1
        htfCofTime := htfTime
        htfChanged := true

        if showHTF and showHighLow
            htfHighRay := line.new(
                 htfTime,
                 htfCofHigh,
                 htfTime + barMS,
                 htfCofHigh,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 width=htfRayWidth
            )

            htfLowRay := line.new(
                 htfTime,
                 htfCofLow,
                 htfTime + barMS,
                 htfCofLow,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 width=htfRayWidth
            )

        if showHTF and showMid
            htfMidRay := line.new(
                 htfTime,
                 htfMid,
                 htfTime + barMS,
                 htfMid,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=htfColor,
                 style=line.style_dashed,
                 width=midRayWidth
            )

// ================= LTF INITIALIZATION =================
if na(ltfCofHigh) and not na(ltfHigh) and not na(ltfLow)
    ltfCofHigh := ltfHigh
    ltfCofLow := ltfLow
    ltfCofDirection := ltfClose >= ltfOpen ? 1 : -1
    ltfCofTime := ltfTime

    if showLTF and showHighLow
        ltfHighRay := line.new(
             ltfTime,
             ltfCofHigh,
             ltfTime + barMS,
             ltfCofHigh,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             width=ltfRayWidth
        )

        ltfLowRay := line.new(
             ltfTime,
             ltfCofLow,
             ltfTime + barMS,
             ltfCofLow,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             width=ltfRayWidth
        )

    if showLTF and showMid
        ltfMidRay := line.new(
             ltfTime,
             ltfMid,
             ltfTime + barMS,
             ltfMid,
             xloc=xloc.bar_time,
             extend=extend.right,
             color=ltfColor,
             style=line.style_dashed,
             width=midRayWidth
        )

// ================= LTF COF BREAK =================
if ltfNew and not na(ltfCofHigh)
    bool ltfBreakUp = ltfClose > ltfCofHigh
    bool ltfBreakDown = ltfClose < ltfCofLow

    if ltfBreakUp or ltfBreakDown
        if not na(ltfHighRay)
            line.delete(ltfHighRay)
        if not na(ltfLowRay)
            line.delete(ltfLowRay)
        if not na(ltfMidRay)
            line.delete(ltfMidRay)

        ltfHighRay := na
        ltfLowRay := na
        ltfMidRay := na

        ltfCofHigh := ltfHigh
        ltfCofLow := ltfLow
        ltfCofDirection := ltfClose >= ltfOpen ? 1 : -1
        ltfCofTime := ltfTime
        ltfChanged := true

        if showLTF and showHighLow
            ltfHighRay := line.new(
                 ltfTime,
                 ltfCofHigh,
                 ltfTime + barMS,
                 ltfCofHigh,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 width=ltfRayWidth
            )

            ltfLowRay := line.new(
                 ltfTime,
                 ltfCofLow,
                 ltfTime + barMS,
                 ltfCofLow,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 width=ltfRayWidth
            )

        if showLTF and showMid
            ltfMidRay := line.new(
                 ltfTime,
                 ltfMid,
                 ltfTime + barMS,
                 ltfMid,
                 xloc=xloc.bar_time,
                 extend=extend.right,
                 color=ltfColor,
                 style=line.style_dashed,
                 width=midRayWidth
            )

// ============================================================================
// NEWER ALERT / ENTRY SYSTEM BEGINS HERE
// ============================================================================

// =====================================================
// CONFIRMATION TIMEFRAME DATA
// =====================================================
isConfirmChart = timeframe.period == tfConfirm

confClose = isConfirmChart ? close[1] : request.security(syminfo.tickerid, tfConfirm, close[1])
confTime = isConfirmChart ? time[1] : request.security(syminfo.tickerid, tfConfirm, time[1])

confNew = ta.change(confTime) != 0

// =====================================================
// ENTRY STATE
// =====================================================
varip bool htfZoneArmed = false
varip bool htfEntryZoneHit = false
varip bool htfConfirmationPending = false
varip float htfConfirmationClose = na
varip bool htfTradeTriggered = false

varip bool ltfZoneArmed = false
varip bool ltfEntryZoneHit = false
varip bool ltfConfirmationPending = false
varip float ltfConfirmationClose = na
varip bool ltfTradeTriggered = false

// =====================================================
// TEMPORARY LABEL STORAGE
// =====================================================
var label htfTradeLabel = na
var int htfTradeLabelTime = na
var label ltfTradeLabel = na
var int ltfTradeLabelTime = na

// =====================================================
// RESET ENTRY STATE ON GENUINE NEW COF
// =====================================================
if htfChanged
    htfZoneArmed := false
    htfEntryZoneHit := false
    htfConfirmationPending := false
    htfConfirmationClose := na
    htfTradeTriggered := false

if ltfChanged
    ltfZoneArmed := false
    ltfEntryZoneHit := false
    ltfConfirmationPending := false
    ltfConfirmationClose := na
    ltfTradeTriggered := false

// =====================================================
// ACTIVE COF ENTRY LEVELS
// =====================================================
htfRange = htfCofHigh - htfCofLow
ltfRange = ltfCofHigh - ltfCofLow

htfBearEntryLevel = not na(htfCofHigh) and not na(htfCofLow) ? htfCofLow + htfRange * (bearEntryPercent / 100.0) : na
htfBullEntryLevel = not na(htfCofHigh) and not na(htfCofLow) ? htfCofLow + htfRange * (bullEntryPercent / 100.0) : na

ltfBearEntryLevel = not na(ltfCofHigh) and not na(ltfCofLow) ? ltfCofLow + ltfRange * (bearEntryPercent / 100.0) : na
ltfBullEntryLevel = not na(ltfCofHigh) and not na(ltfCofLow) ? ltfCofLow + ltfRange * (bullEntryPercent / 100.0) : na

// =====================================================
// STAGE 1: NEW COF EVENTS
// =====================================================
htfNewBullishCOF = htfChanged and htfCofDirection == 1
htfNewBearishCOF = htfChanged and htfCofDirection == -1

ltfNewBullishCOF = ltfChanged and ltfCofDirection == 1
ltfNewBearishCOF = ltfChanged and ltfCofDirection == -1

// =====================================================
// STAGE 2A: ARM ENTRY-ZONE RETURN
// =====================================================
if not htfChanged and not htfEntryZoneHit and not htfZoneArmed
    if not requireReturnToZone
        htfZoneArmed := true
    else if htfCofDirection == -1 and not na(htfBearEntryLevel) and low < htfBearEntryLevel
        htfZoneArmed := true
    else if htfCofDirection == 1 and not na(htfBullEntryLevel) and high > htfBullEntryLevel
        htfZoneArmed := true

if not ltfChanged and not ltfEntryZoneHit and not ltfZoneArmed
    if not requireReturnToZone
        ltfZoneArmed := true
    else if ltfCofDirection == -1 and not na(ltfBearEntryLevel) and low < ltfBearEntryLevel
        ltfZoneArmed := true
    else if ltfCofDirection == 1 and not na(ltfBullEntryLevel) and high > ltfBullEntryLevel
        ltfZoneArmed := true

// =====================================================
// STAGE 2B: DIRECTIONAL ENTRY-ZONE RETURN
// =====================================================
htfBearEntryZoneNow = not htfChanged and htfZoneArmed and not htfEntryZoneHit and htfCofDirection == -1 and not na(htfBearEntryLevel) and high >= htfBearEntryLevel
htfBullEntryZoneNow = not htfChanged and htfZoneArmed and not htfEntryZoneHit and htfCofDirection == 1 and not na(htfBullEntryLevel) and low <= htfBullEntryLevel

ltfBearEntryZoneNow = not ltfChanged and ltfZoneArmed and not ltfEntryZoneHit and ltfCofDirection == -1 and not na(ltfBearEntryLevel) and high >= ltfBearEntryLevel
ltfBullEntryZoneNow = not ltfChanged and ltfZoneArmed and not ltfEntryZoneHit and ltfCofDirection == 1 and not na(ltfBullEntryLevel) and low <= ltfBullEntryLevel

if htfBearEntryZoneNow or htfBullEntryZoneNow
    htfEntryZoneHit := true
    htfConfirmationPending := false
    htfConfirmationClose := na

if ltfBearEntryZoneNow or ltfBullEntryZoneNow
    ltfEntryZoneHit := true
    ltfConfirmationPending := false
    ltfConfirmationClose := na

// =====================================================
// STAGE 3A: CONFIRMATION CANDLE
// =====================================================
if confNew
    if enableHTFTradeSignals and htfEntryZoneHit and not htfTradeTriggered
        htfCloseInside = not na(confClose) and confClose <= htfCofHigh and confClose >= htfCofLow

        if htfCloseInside
            htfConfirmationClose := confClose
            htfConfirmationPending := true
        else
            htfConfirmationClose := na
            htfConfirmationPending := false

    if enableLTFTradeSignals and ltfEntryZoneHit and not ltfTradeTriggered
        ltfCloseInside = not na(confClose) and confClose <= ltfCofHigh and confClose >= ltfCofLow

        if ltfCloseInside
            ltfConfirmationClose := confClose
            ltfConfirmationPending := true
        else
            ltfConfirmationClose := na
            ltfConfirmationPending := false

// =====================================================
// STAGE 3B: MOMENTUM / FINAL TRADE ENTRY
// =====================================================
htfBuySignal = enableHTFTradeSignals and htfCofDirection == 1 and htfEntryZoneHit and htfConfirmationPending and not htfTradeTriggered and not na(htfConfirmationClose) and close >= htfConfirmationClose + momentumDistance
htfSellSignal = enableHTFTradeSignals and htfCofDirection == -1 and htfEntryZoneHit and htfConfirmationPending and not htfTradeTriggered and not na(htfConfirmationClose) and close <= htfConfirmationClose - momentumDistance

ltfBuySignal = enableLTFTradeSignals and ltfCofDirection == 1 and ltfEntryZoneHit and ltfConfirmationPending and not ltfTradeTriggered and not na(ltfConfirmationClose) and close >= ltfConfirmationClose + momentumDistance
ltfSellSignal = enableLTFTradeSignals and ltfCofDirection == -1 and ltfEntryZoneHit and ltfConfirmationPending and not ltfTradeTriggered and not na(ltfConfirmationClose) and close <= ltfConfirmationClose - momentumDistance

if htfBuySignal or htfSellSignal
    htfTradeTriggered := true
    htfConfirmationPending := false

if ltfBuySignal or ltfSellSignal
    ltfTradeTriggered := true
    ltfConfirmationPending := false

// =====================================================
// ALERTCONDITIONS - NEW COF
// =====================================================
alertcondition(enableAlerts and alertNewCOF and alertHTFNewCOF and htfNewBullishCOF, title="New Bullish 4H COF", message="New BULLISH 4H COF formed on {{ticker}}")
alertcondition(enableAlerts and alertNewCOF and alertHTFNewCOF and htfNewBearishCOF, title="New Bearish 4H COF", message="New BEARISH 4H COF formed on {{ticker}}")
alertcondition(enableAlerts and alertNewCOF and alertLTFNewCOF and ltfNewBullishCOF, title="New Bullish 45m COF", message="New BULLISH 45m COF formed on {{ticker}}")
alertcondition(enableAlerts and alertNewCOF and alertLTFNewCOF and ltfNewBearishCOF, title="New Bearish 45m COF", message="New BEARISH 45m COF formed on {{ticker}}")

// =====================================================
// ALERTCONDITIONS - ENTRY ZONES
// =====================================================
alertcondition(enableAlerts and alertEntryZones and alertHTFEntryZone and htfBearEntryZoneNow, title="4H Bearish Entry Zone Reached", message="4H bearish COF premium entry zone reached on {{ticker}}")
alertcondition(enableAlerts and alertEntryZones and alertHTFEntryZone and htfBullEntryZoneNow, title="4H Bullish Entry Zone Reached", message="4H bullish COF discount entry zone reached on {{ticker}}")
alertcondition(enableAlerts and alertEntryZones and alertLTFEntryZone and ltfBearEntryZoneNow, title="45m Bearish Entry Zone Reached", message="45m bearish COF premium entry zone reached on {{ticker}}")
alertcondition(enableAlerts and alertEntryZones and alertLTFEntryZone and ltfBullEntryZoneNow, title="45m Bullish Entry Zone Reached", message="45m bullish COF discount entry zone reached on {{ticker}}")

// =====================================================
// ALERTCONDITIONS - FINAL TRADE ENTRY
// =====================================================
alertcondition(enableAlerts and alertTradeEntries and alertHTFTradeEntry and htfBuySignal, title="4H BUY Entry Confirmed", message="BUY entry confirmed from bullish 4H COF on {{ticker}}")
alertcondition(enableAlerts and alertTradeEntries and alertHTFTradeEntry and htfSellSignal, title="4H SELL Entry Confirmed", message="SELL entry confirmed from bearish 4H COF on {{ticker}}")
alertcondition(enableAlerts and alertTradeEntries and alertLTFTradeEntry and ltfBuySignal, title="45m BUY Entry Confirmed", message="BUY entry confirmed from bullish 45m COF on {{ticker}}")
alertcondition(enableAlerts and alertTradeEntries and alertLTFTradeEntry and ltfSellSignal, title="45m SELL Entry Confirmed", message="SELL entry confirmed from bearish 45m COF on {{ticker}}")

// =====================================================
// DYNAMIC ALERTS - NEW COF
// =====================================================
if enableAlerts and alertNewCOF and alertHTFNewCOF and htfNewBullishCOF
    alert("NEW BULLISH 4H COF | " + syminfo.ticker + " | High: " + str.tostring(htfCofHigh, format.mintick) + " | Low: " + str.tostring(htfCofLow, format.mintick) + " | Watch " + str.tostring(bullEntryPercent) + "% discount @ " + str.tostring(htfBullEntryLevel, format.mintick), alert.freq_once_per_bar_close)

if enableAlerts and alertNewCOF and alertHTFNewCOF and htfNewBearishCOF
    alert("NEW BEARISH 4H COF | " + syminfo.ticker + " | High: " + str.tostring(htfCofHigh, format.mintick) + " | Low: " + str.tostring(htfCofLow, format.mintick) + " | Watch " + str.tostring(bearEntryPercent) + "% premium @ " + str.tostring(htfBearEntryLevel, format.mintick), alert.freq_once_per_bar_close)

if enableAlerts and alertNewCOF and alertLTFNewCOF and ltfNewBullishCOF
    alert("NEW BULLISH 45m COF | " + syminfo.ticker + " | High: " + str.tostring(ltfCofHigh, format.mintick) + " | Low: " + str.tostring(ltfCofLow, format.mintick) + " | Watch " + str.tostring(bullEntryPercent) + "% discount @ " + str.tostring(ltfBullEntryLevel, format.mintick), alert.freq_once_per_bar_close)

if enableAlerts and alertNewCOF and alertLTFNewCOF and ltfNewBearishCOF
    alert("NEW BEARISH 45m COF | " + syminfo.ticker + " | High: " + str.tostring(ltfCofHigh, format.mintick) + " | Low: " + str.tostring(ltfCofLow, format.mintick) + " | Watch " + str.tostring(bearEntryPercent) + "% premium @ " + str.tostring(ltfBearEntryLevel, format.mintick), alert.freq_once_per_bar_close)

// =====================================================
// DYNAMIC ALERTS - ENTRY ZONE
// =====================================================
if enableAlerts and alertEntryZones and alertHTFEntryZone and htfBearEntryZoneNow
    alert("4H BEARISH ENTRY ZONE REACHED | " + syminfo.ticker + " | " + str.tostring(bearEntryPercent) + "% premium @ " + str.tostring(htfBearEntryLevel, format.mintick) + " | Monitor for confirmation.", alert.freq_once_per_bar)

if enableAlerts and alertEntryZones and alertHTFEntryZone and htfBullEntryZoneNow
    alert("4H BULLISH ENTRY ZONE REACHED | " + syminfo.ticker + " | " + str.tostring(bullEntryPercent) + "% discount @ " + str.tostring(htfBullEntryLevel, format.mintick) + " | Monitor for confirmation.", alert.freq_once_per_bar)

if enableAlerts and alertEntryZones and alertLTFEntryZone and ltfBearEntryZoneNow
    alert("45m BEARISH ENTRY ZONE REACHED | " + syminfo.ticker + " | " + str.tostring(bearEntryPercent) + "% premium @ " + str.tostring(ltfBearEntryLevel, format.mintick) + " | Monitor for confirmation.", alert.freq_once_per_bar)

if enableAlerts and alertEntryZones and alertLTFEntryZone and ltfBullEntryZoneNow
    alert("45m BULLISH ENTRY ZONE REACHED | " + syminfo.ticker + " | " + str.tostring(bullEntryPercent) + "% discount @ " + str.tostring(ltfBullEntryLevel, format.mintick) + " | Monitor for confirmation.", alert.freq_once_per_bar)

// =====================================================
// DYNAMIC ALERTS - FINAL TRADE ENTRY
// =====================================================
if enableAlerts and alertTradeEntries and alertHTFTradeEntry and htfBuySignal
    alert("BUY CONFIRMED | 4H bullish COF | " + syminfo.ticker + " | Confirmation close: " + str.tostring(htfConfirmationClose, format.mintick) + " | Momentum: " + str.tostring(momentumDistance, format.mintick), alert.freq_once_per_bar)

if enableAlerts and alertTradeEntries and alertHTFTradeEntry and htfSellSignal
    alert("SELL CONFIRMED | 4H bearish COF | " + syminfo.ticker + " | Confirmation close: " + str.tostring(htfConfirmationClose, format.mintick) + " | Momentum: " + str.tostring(momentumDistance, format.mintick), alert.freq_once_per_bar)

if enableAlerts and alertTradeEntries and alertLTFTradeEntry and ltfBuySignal
    alert("BUY CONFIRMED | 45m bullish COF | " + syminfo.ticker + " | Confirmation close: " + str.tostring(ltfConfirmationClose, format.mintick) + " | Momentum: " + str.tostring(momentumDistance, format.mintick), alert.freq_once_per_bar)

if enableAlerts and alertTradeEntries and alertLTFTradeEntry and ltfSellSignal
    alert("SELL CONFIRMED | 45m bearish COF | " + syminfo.ticker + " | Confirmation close: " + str.tostring(ltfConfirmationClose, format.mintick) + " | Momentum: " + str.tostring(momentumDistance, format.mintick), alert.freq_once_per_bar)

// =====================================================
// TEMPORARY BUY / SELL LABELS
// =====================================================
if barstate.isrealtime and htfBuySignal
    if not na(htfTradeLabel)
        label.delete(htfTradeLabel)

    htfTradeLabel := label.new(
         bar_index,
         low,
         "BUY\n4H COF",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.large
    )

    htfTradeLabelTime := timenow

if barstate.isrealtime and htfSellSignal
    if not na(htfTradeLabel)
        label.delete(htfTradeLabel)

    htfTradeLabel := label.new(
         bar_index,
         high,
         "SELL\n4H COF",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.large
    )

    htfTradeLabelTime := timenow

if barstate.isrealtime and ltfBuySignal
    if not na(ltfTradeLabel)
        label.delete(ltfTradeLabel)

    ltfTradeLabel := label.new(
         bar_index,
         low,
         "BUY\n45m COF",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.large
    )

    ltfTradeLabelTime := timenow

if barstate.isrealtime and ltfSellSignal
    if not na(ltfTradeLabel)
        label.delete(ltfTradeLabel)

    ltfTradeLabel := label.new(
         bar_index,
         high,
         "SELL\n45m COF",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.large
    )

    ltfTradeLabelTime := timenow

if barstate.isrealtime and not na(htfTradeLabel) and not na(htfTradeLabelTime)
    if timenow - htfTradeLabelTime >= labelLifeSeconds * 1000
        label.delete(htfTradeLabel)
        htfTradeLabel := na
        htfTradeLabelTime := na

if barstate.isrealtime and not na(ltfTradeLabel) and not na(ltfTradeLabelTime)
    if timenow - ltfTradeLabelTime >= labelLifeSeconds * 1000
        label.delete(ltfTradeLabel)
        ltfTradeLabel := na
        ltfTradeLabelTime := na
````
