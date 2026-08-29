<!-- tradingview-pine-id: PUB;484003d5832246398d6f03d8df99e5a5 -->
<!-- tradingviewscripts-format: 1 -->
# Premarket High/Low + Prior Day High/Low + EMA Alerts

Source: https://www.tradingview.com/script/wnlo8FBX-Premarket-High-Low-Prior-Day-High-Low-EMA-Alerts/

## Description

Premarket High/Low + Prior Day High/Low + EMA Alerts   with alert function

---

## Source Code

````pine
//@version=6
indicator(
     title = "Premarket High/Low + Prior Day High/Low + EMA Alerts",
     shorttitle = "PM/PD Levels + EMA",
     overlay = true,
     max_labels_count = 100
)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────

groupSessions = "Session Settings"

premarketSession = input.session(
     "0400-0930",
     "Premarket Session",
     group = groupSessions
)

regularSession = input.session(
     "0930-1600",
     "Regular Market Session",
     group = groupSessions
)

sessionTimeZone = input.string(
     "America/New_York",
     "Session Time Zone",
     options = [
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "Etc/UTC"
     ],
     group = groupSessions
)

groupDisplay = "Display Settings"

showPremarketLevels = input.bool(
     true,
     "Show Premarket High and Low",
     group = groupDisplay
)

showPriorDayLevels = input.bool(
     true,
     "Show Prior-Day High and Low",
     group = groupDisplay
)

showLabels = input.bool(
     true,
     "Show Level Labels",
     group = groupDisplay
)

showEMA = input.bool(
     true,
     "Show 9 EMA",
     group = groupDisplay
)

showPremarketDuringPremarket = input.bool(
     true,
     "Show Developing Premarket Levels",
     group = groupDisplay
)

groupEMA = "EMA Settings"

emaLength = input.int(
     9,
     "EMA Length",
     minval = 1,
     group = groupEMA
)

groupAlerts = "Alert Settings"

enablePriceBreakAlerts = input.bool(
     true,
     "Enable Price Break Alerts",
     group = groupAlerts
)

enableTouchAlerts = input.bool(
     false,
     "Enable Price Touch Alerts",
     group = groupAlerts
)

enableEMACrossAlerts = input.bool(
     true,
     "Enable EMA Cross Alerts",
     group = groupAlerts
)

confirmAlertsOnClose = input.bool(
     true,
     "Confirm Alerts at Candle Close",
     tooltip = "Prevents intrabar alert signals from disappearing before the candle closes.",
     group = groupAlerts
)

emaCrossRegularSessionOnly = input.bool(
     true,
     "EMA Cross Alerts During Regular Session Only",
     tooltip = "Prevents EMA alerts during premarket while the premarket levels are still developing.",
     group = groupAlerts
)

//──────────────────────────────────────────────────────────────────────────────
// SESSION DETECTION
//──────────────────────────────────────────────────────────────────────────────

inPremarket = not na(
     time(
         timeframe.period,
         premarketSession,
         sessionTimeZone
     )
)

inRegularSession = not na(
     time(
         timeframe.period,
         regularSession,
         sessionTimeZone
     )
)

premarketStarted = inPremarket and not inPremarket[1]
premarketEnded = not inPremarket and inPremarket[1]

currentDay = dayofmonth(time, sessionTimeZone)
currentMonth = month(time, sessionTimeZone)
currentYear = year(time, sessionTimeZone)

newDay =
     currentDay != currentDay[1] or
     currentMonth != currentMonth[1] or
     currentYear != currentYear[1]

//──────────────────────────────────────────────────────────────────────────────
// PREMARKET HIGH AND LOW
//──────────────────────────────────────────────────────────────────────────────

var float premarketHigh = na
var float premarketLow = na
var bool premarketComplete = false

if newDay
    premarketHigh := na
    premarketLow := na
    premarketComplete := false

if premarketStarted
    premarketHigh := high
    premarketLow := low
    premarketComplete := false

if inPremarket
    premarketHigh := na(premarketHigh) ?
         high :
         math.max(premarketHigh, high)

    premarketLow := na(premarketLow) ?
         low :
         math.min(premarketLow, low)

if premarketEnded
    premarketComplete := true

premarketReady =
     showPremarketDuringPremarket ?
         not na(premarketHigh) :
         premarketComplete

//──────────────────────────────────────────────────────────────────────────────
// PRIOR-DAY LEVELS
//──────────────────────────────────────────────────────────────────────────────

priorDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

priorDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//──────────────────────────────────────────────────────────────────────────────
// 9 EMA
//──────────────────────────────────────────────────────────────────────────────

emaValue = ta.ema(close, emaLength)

plot(
     showEMA ? emaValue : na,
     title = "EMA",
     color = color.yellow,
     linewidth = 2
)

//──────────────────────────────────────────────────────────────────────────────
// LEVEL PLOTS
//──────────────────────────────────────────────────────────────────────────────

plot(
     showPremarketLevels and premarketReady ?
         premarketHigh :
         na,
     title = "Premarket High",
     color = color.aqua,
     linewidth = 2,
     style = plot.style_stepline
)

plot(
     showPremarketLevels and premarketReady ?
         premarketLow :
         na,
     title = "Premarket Low",
     color = color.aqua,
     linewidth = 2,
     style = plot.style_stepline
)

plot(
     showPriorDayLevels ?
         priorDayHigh :
         na,
     title = "Prior-Day High",
     color = color.orange,
     linewidth = 2,
     style = plot.style_stepline
)

plot(
     showPriorDayLevels ?
         priorDayLow :
         na,
     title = "Prior-Day Low",
     color = color.orange,
     linewidth = 2,
     style = plot.style_stepline
)

//──────────────────────────────────────────────────────────────────────────────
// LABELS
//──────────────────────────────────────────────────────────────────────────────

var label pmhLabel = na
var label pmlLabel = na
var label pdhLabel = na
var label pdlLabel = na

if barstate.islast
    label.delete(pmhLabel)
    label.delete(pmlLabel)
    label.delete(pdhLabel)
    label.delete(pdlLabel)

    if showLabels and showPremarketLevels and premarketReady
        pmhLabel := label.new(
             bar_index + 1,
             premarketHigh,
             "PMH " + str.tostring(premarketHigh, format.mintick),
             style = label.style_label_left,
             textcolor = color.white,
             color = color.new(color.aqua, 25)
        )

        pmlLabel := label.new(
             bar_index + 1,
             premarketLow,
             "PML " + str.tostring(premarketLow, format.mintick),
             style = label.style_label_left,
             textcolor = color.white,
             color = color.new(color.aqua, 25)
        )

    if showLabels and showPriorDayLevels
        pdhLabel := label.new(
             bar_index + 1,
             priorDayHigh,
             "PDH " + str.tostring(priorDayHigh, format.mintick),
             style = label.style_label_left,
             textcolor = color.white,
             color = color.new(color.orange, 20)
        )

        pdlLabel := label.new(
             bar_index + 1,
             priorDayLow,
             "PDL " + str.tostring(priorDayLow, format.mintick),
             style = label.style_label_left,
             textcolor = color.white,
             color = color.new(color.orange, 20)
        )

//──────────────────────────────────────────────────────────────────────────────
// ALERT CONFIRMATION
//──────────────────────────────────────────────────────────────────────────────

alertConfirmed =
     not confirmAlertsOnClose or
     barstate.isconfirmed

emaSessionValid =
     not emaCrossRegularSessionOnly or
     inRegularSession

//──────────────────────────────────────────────────────────────────────────────
// PRICE BREAK CONDITIONS
//──────────────────────────────────────────────────────────────────────────────

priceBreakAbovePMH =
     enablePriceBreakAlerts and
     premarketReady and
     ta.crossover(close, premarketHigh) and
     alertConfirmed

priceBreakBelowPML =
     enablePriceBreakAlerts and
     premarketReady and
     ta.crossunder(close, premarketLow) and
     alertConfirmed

priceBreakAbovePDH =
     enablePriceBreakAlerts and
     ta.crossover(close, priorDayHigh) and
     alertConfirmed

priceBreakBelowPDL =
     enablePriceBreakAlerts and
     ta.crossunder(close, priorDayLow) and
     alertConfirmed

//──────────────────────────────────────────────────────────────────────────────
// PRICE TOUCH CONDITIONS
//──────────────────────────────────────────────────────────────────────────────

priceTouchPMH =
     enableTouchAlerts and
     premarketReady and
     high >= premarketHigh and
     low <= premarketHigh and
     high[1] < premarketHigh and
     alertConfirmed

priceTouchPML =
     enableTouchAlerts and
     premarketReady and
     high >= premarketLow and
     low <= premarketLow and
     low[1] > premarketLow and
     alertConfirmed

priceTouchPDH =
     enableTouchAlerts and
     high >= priorDayHigh and
     low <= priorDayHigh and
     high[1] < priorDayHigh and
     alertConfirmed

priceTouchPDL =
     enableTouchAlerts and
     high >= priorDayLow and
     low <= priorDayLow and
     low[1] > priorDayLow and
     alertConfirmed

//──────────────────────────────────────────────────────────────────────────────
// EMA CROSS CONDITIONS
//──────────────────────────────────────────────────────────────────────────────

emaCrossAbovePMH =
     enableEMACrossAlerts and
     emaSessionValid and
     premarketComplete and
     not na(premarketHigh) and
     ta.crossover(emaValue, premarketHigh) and
     alertConfirmed

emaCrossBelowPMH =
     enableEMACrossAlerts and
     emaSessionValid and
     premarketComplete and
     not na(premarketHigh) and
     ta.crossunder(emaValue, premarketHigh) and
     alertConfirmed

emaCrossAbovePML =
     enableEMACrossAlerts and
     emaSessionValid and
     premarketComplete and
     not na(premarketLow) and
     ta.crossover(emaValue, premarketLow) and
     alertConfirmed

emaCrossBelowPML =
     enableEMACrossAlerts and
     emaSessionValid and
     premarketComplete and
     not na(premarketLow) and
     ta.crossunder(emaValue, premarketLow) and
     alertConfirmed

emaCrossAbovePDH =
     enableEMACrossAlerts and
     emaSessionValid and
     not na(priorDayHigh) and
     ta.crossover(emaValue, priorDayHigh) and
     alertConfirmed

emaCrossBelowPDH =
     enableEMACrossAlerts and
     emaSessionValid and
     not na(priorDayHigh) and
     ta.crossunder(emaValue, priorDayHigh) and
     alertConfirmed

emaCrossAbovePDL =
     enableEMACrossAlerts and
     emaSessionValid and
     not na(priorDayLow) and
     ta.crossover(emaValue, priorDayLow) and
     alertConfirmed

emaCrossBelowPDL =
     enableEMACrossAlerts and
     emaSessionValid and
     not na(priorDayLow) and
     ta.crossunder(emaValue, priorDayLow) and
     alertConfirmed

anyEMACrossAbove =
     emaCrossAbovePMH or
     emaCrossAbovePML or
     emaCrossAbovePDH or
     emaCrossAbovePDL

anyEMACrossBelow =
     emaCrossBelowPMH or
     emaCrossBelowPML or
     emaCrossBelowPDH or
     emaCrossBelowPDL

anyEMACross =
     anyEMACrossAbove or
     anyEMACrossBelow

//──────────────────────────────────────────────────────────────────────────────
// PRICE ALERTS
//──────────────────────────────────────────────────────────────────────────────

alertcondition(
     priceBreakAbovePMH,
     "Price Break Above Premarket High",
     "{{ticker}} price broke above the premarket high at {{close}}."
)

alertcondition(
     priceBreakBelowPML,
     "Price Break Below Premarket Low",
     "{{ticker}} price broke below the premarket low at {{close}}."
)

alertcondition(
     priceBreakAbovePDH,
     "Price Break Above Prior-Day High",
     "{{ticker}} price broke above the prior-day high at {{close}}."
)

alertcondition(
     priceBreakBelowPDL,
     "Price Break Below Prior-Day Low",
     "{{ticker}} price broke below the prior-day low at {{close}}."
)

//──────────────────────────────────────────────────────────────────────────────
// TOUCH ALERTS
//──────────────────────────────────────────────────────────────────────────────

alertcondition(
     priceTouchPMH,
     "Price Touch Premarket High",
     "{{ticker}} touched the premarket high."
)

alertcondition(
     priceTouchPML,
     "Price Touch Premarket Low",
     "{{ticker}} touched the premarket low."
)

alertcondition(
     priceTouchPDH,
     "Price Touch Prior-Day High",
     "{{ticker}} touched the prior-day high."
)

alertcondition(
     priceTouchPDL,
     "Price Touch Prior-Day Low",
     "{{ticker}} touched the prior-day low."
)

//──────────────────────────────────────────────────────────────────────────────
// EMA CROSS ALERTS
//──────────────────────────────────────────────────────────────────────────────

alertcondition(
     emaCrossAbovePMH,
     "9 EMA Cross Above Premarket High",
     "{{ticker}} 9 EMA crossed above the premarket high on {{interval}}."
)

alertcondition(
     emaCrossBelowPMH,
     "9 EMA Cross Below Premarket High",
     "{{ticker}} 9 EMA crossed below the premarket high on {{interval}}."
)

alertcondition(
     emaCrossAbovePML,
     "9 EMA Cross Above Premarket Low",
     "{{ticker}} 9 EMA crossed above the premarket low on {{interval}}."
)

alertcondition(
     emaCrossBelowPML,
     "9 EMA Cross Below Premarket Low",
     "{{ticker}} 9 EMA crossed below the premarket low on {{interval}}."
)

alertcondition(
     emaCrossAbovePDH,
     "9 EMA Cross Above Prior-Day High",
     "{{ticker}} 9 EMA crossed above the prior-day high on {{interval}}."
)

alertcondition(
     emaCrossBelowPDH,
     "9 EMA Cross Below Prior-Day High",
     "{{ticker}} 9 EMA crossed below the prior-day high on {{interval}}."
)

alertcondition(
     emaCrossAbovePDL,
     "9 EMA Cross Above Prior-Day Low",
     "{{ticker}} 9 EMA crossed above the prior-day low on {{interval}}."
)

alertcondition(
     emaCrossBelowPDL,
     "9 EMA Cross Below Prior-Day Low",
     "{{ticker}} 9 EMA crossed below the prior-day low on {{interval}}."
)

// Combined EMA alert options.

alertcondition(
     anyEMACrossAbove,
     "9 EMA Cross Above Any Level",
     "{{ticker}} 9 EMA crossed above a premarket or prior-day level on {{interval}}."
)

alertcondition(
     anyEMACrossBelow,
     "9 EMA Cross Below Any Level",
     "{{ticker}} 9 EMA crossed below a premarket or prior-day level on {{interval}}."
)

alertcondition(
     anyEMACross,
     "9 EMA Cross Any Level",
     "{{ticker}} 9 EMA crossed a premarket or prior-day level on {{interval}}."
)
````
