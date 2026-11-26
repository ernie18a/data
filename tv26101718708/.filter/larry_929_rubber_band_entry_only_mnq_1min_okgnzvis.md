# Larry 9:29 Rubber Band ENTRY ONLY - MNQ [1min]

- url: https://www.tradingview.com/script/OKGnzvIs-Larry-9-29-Rubber-Band-ENTRY-ONLY-MNQ-1min/
- type: indicator
- pine_id: PUB;da1d413966884ff39856b41f444e7902
- version: 1.0

## Description

Name: Larry 9:29 Rubber Band — MNQ Entry Signal
Description:

Captures the 9:29 AM Eastern candle body midpoint as a Fair Price level each morning. When price stretches 75 points away from Fair Price and then shows a reversal candle, the indicator fires a LONG or SHORT signal expecting a mean-reversion snap back toward fair value.
Designed for MNQ (Micro E-Mini Nasdaq-100) on a 1-minute chart. One signal per day maximum. Compatible with TradersPost webhook automation — alerts fire JSON directly to your broker on signal confirmation.
Settings include: stretch band distance, session window, gap day filter, pre-stretched open filter, volume confirmation, RSI filter, snapback filter, and late session contract reduction.
Timeframe: 1-minute

Instrument: MNQ / NQ futures

Session: 9:29 AM – 11:00 AM Eastern

## Source Code

````pine
//@version=6
indicator('Larry 9:29 Rubber Band ENTRY ONLY - MNQ [1min]', overlay = true, max_labels_count = 500)

// ═════════════════════════════════════════════
// GROUP: Position Sizing
// ═════════════════════════════════════════════
contracts = input.int(2, 'MNQ Contracts', minval = 1, maxval = 4, step = 1,
     group = 'Position Sizing',
     tooltip = '1–4 MNQ contracts. Default 2.')

// ═════════════════════════════════════════════
// GROUP: Core Band Settings
// ═════════════════════════════════════════════
stretchPoints = input.float(75.0, 'Stretch Band (pts)', minval = 1.0, step = 5.0,
     group = 'Core Band Settings',
     tooltip = 'Distance from 9:29 fair price before entry fires.')

// ═════════════════════════════════════════════
// GROUP: Risk Management
// ═════════════════════════════════════════════
slPoints         = input.float(75.0, 'Hard Stop Loss (pts)',        minval = 1.0, step = 5.0,  group = 'Risk Management', tooltip = '75pts = $150/contract on MNQ. 2 contracts = $300 max loss.')
trailActivatePts = input.float(75.0, 'Trail Activates After (pts)', minval = 1.0, step = 5.0,  group = 'Risk Management', tooltip = 'Trail does not kick in until price moves this far in your favor.')
trailPoints      = input.float(25.0, 'Trail Distance (pts)',        minval = 1.0, step = 5.0,  group = 'Risk Management', tooltip = 'Once trail activates, stop follows peak by this many points.')

// ═════════════════════════════════════════════
// GROUP: Session Settings
// ═════════════════════════════════════════════
startHour   = input.int(9,  'Start Hour NY',  minval = 0, maxval = 23, group = 'Session Settings')
startMinute = input.int(29, 'Start Min NY',   minval = 0, maxval = 59, group = 'Session Settings')
endHour     = input.int(11, 'End Hour NY',    minval = 0, maxval = 23, group = 'Session Settings')
endMinute   = input.int(0,  'End Min NY',     minval = 0, maxval = 59, group = 'Session Settings')

// ═════════════════════════════════════════════
// GROUP: Filters
// ═════════════════════════════════════════════
useOneTrade     = input.bool(true,  'One Trade Per Day',             group = 'Filters', tooltip = 'First signal only — no re-entries.')
useGapFilter    = input.bool(false, 'Skip Large Gap Days',           group = 'Filters', tooltip = 'Skip days where open gaps more than threshold from prior close.')
gapThreshold    = input.float(75.0, 'Gap Threshold (pts)',           group = 'Filters', minval = 1.0, step = 5.0)
usePreStretched = input.bool(false, 'Skip Pre-Stretched Opens',      group = 'Filters', tooltip = 'Skip day if 9:29 candle already beyond the band.')
useLateCutoff   = input.bool(false, 'Reduce to 1 Contract at 10:00', group = 'Filters', tooltip = 'Cut to 1 contract after 10:00 ET.')
useVolumeFilter = input.bool(false, 'Volume Confirmation',           group = 'Filters', tooltip = 'Reversal bar volume must exceed 20-bar average.')
volLookback     = input.int(20,     'Volume MA Length',              group = 'Filters', minval = 1)
useRsiFilter    = input.bool(false, 'RSI Filter',                    group = 'Filters', tooltip = 'Longs: RSI < 35. Shorts: RSI > 65.')
rsiLen          = input.int(14,     'RSI Length',                    group = 'Filters', minval = 1)
rsiThresh       = input.float(35.0, 'RSI Level',                     group = 'Filters', minval = 1.0, maxval = 49.0, step = 1.0)
useSnapback     = input.bool(false, 'Require Close Back Inside Band', group = 'Filters', tooltip = 'Reversal bar must close back inside the stretch band.')

// ═════════════════════════════════════════════
// NY Time
// ═════════════════════════════════════════════
etHour   = hour(time,   'America/New_York')
etMinute = minute(time, 'America/New_York')
todayKey = year(time, 'America/New_York') * 10000 + month(time, 'America/New_York') * 100 + dayofmonth(time, 'America/New_York')

// ═════════════════════════════════════════════
// 9:29 Fair Price Capture
// ═════════════════════════════════════════════
targetTime = timestamp('America/New_York', year(time, 'America/New_York'), month(time, 'America/New_York'), dayofmonth(time, 'America/New_York'), 9, 29)
is0929     = time <= targetTime and time_close > targetTime

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

var float fairPrice      = na
var float fpHigh         = na
var float fpLow          = na
var int   capturedDay    = 0
var bool  labelDrawn     = false
var bool  preStretchSkip = false

if is0929 and todayKey != capturedDay
    fairPrice      := (bodyHigh + bodyLow) / 2.0
    fpHigh         := high
    fpLow          := low
    capturedDay    := todayKey
    labelDrawn     := false
    preStretchSkip := usePreStretched and (bodyLow < fairPrice - stretchPoints or bodyHigh > fairPrice + stretchPoints)

todayCaptured = capturedDay == todayKey

// ═════════════════════════════════════════════
// Gap Filter
// ═════════════════════════════════════════════
var float prevDayClose  = na
var bool  gapSkip       = false
var int   gapCheckedDay = 0

if todayKey != todayKey[1] and gapCheckedDay != todayKey
    gapSkip       := useGapFilter and not na(prevDayClose) and math.abs(open - prevDayClose) > gapThreshold
    gapCheckedDay := todayKey

if hour(time, 'America/New_York') == 15 and minute(time, 'America/New_York') >= 55
    prevDayClose := close

dayAllowed = not gapSkip and not preStretchSkip

// ═════════════════════════════════════════════
// One Trade Per Day
// ═════════════════════════════════════════════
var bool tradeDoneToday = false
var int  lastSignalDay  = 0

if todayKey != todayKey[1]
    tradeDoneToday := false

// ═════════════════════════════════════════════
// Window
// ═════════════════════════════════════════════
afterTarget = todayCaptured and (etHour > 9 or (etHour == 9 and etMinute >= 29))
afterStart  = etHour > startHour  or (etHour == startHour  and etMinute >= startMinute)
beforeEnd   = etHour < endHour    or (etHour == endHour    and etMinute <= endMinute)
inWindow    = afterTarget and afterStart and beforeEnd and dayAllowed and not tradeDoneToday

// Late cutoff
isLate          = etHour > 10 or (etHour == 10 and etMinute >= 0)
activeContracts = useLateCutoff and isLate ? 1 : contracts

// ═════════════════════════════════════════════
// Indicators
// ═════════════════════════════════════════════
rsiValue = ta.rsi(close, rsiLen)
volAvg   = ta.sma(volume, volLookback)

// ═════════════════════════════════════════════
// Bands & Deviation
// ═════════════════════════════════════════════
deviation = todayCaptured ? close - fairPrice : 0.0
stretched = todayCaptured and math.abs(deviation) >= stretchPoints
upperBand = fairPrice + stretchPoints
lowerBand = fairPrice - stretchPoints

// ═════════════════════════════════════════════
// Entry Signals
// ═════════════════════════════════════════════
reversalUp   = close > open and close[1] < open[1] and close > close[1] and deviation < 0
reversalDown = close < open and close[1] > open[1] and close < close[1] and deviation > 0

snapbackLong  = not useSnapback or close > lowerBand
snapbackShort = not useSnapback or close < upperBand
volOk         = not useVolumeFilter or volume > volAvg
rsiLongOk     = not useRsiFilter or rsiValue < rsiThresh
rsiShortOk    = not useRsiFilter or rsiValue > (100 - rsiThresh)

longSignal  = inWindow and stretched and reversalUp   and snapbackLong  and volOk and rsiLongOk  and barstate.isconfirmed
shortSignal = inWindow and stretched and reversalDown and snapbackShort and volOk and rsiShortOk and barstate.isconfirmed

// Mark trade done for one-trade-per-day
if longSignal or shortSignal
    tradeDoneToday := true

// ═════════════════════════════════════════════
// Plots
// ═════════════════════════════════════════════
plot(afterTarget ? fairPrice : na, '9:29 Fair Price', color = color.white,                linewidth = 2, style = plot.style_stepline)
plot(afterTarget ? fpHigh    : na, '9:29 High',       color = color.aqua,                 linewidth = 2, style = plot.style_stepline)
plot(afterTarget ? fpLow     : na, '9:29 Low',        color = color.orange,               linewidth = 2, style = plot.style_stepline)
plot(afterTarget ? upperBand : na, 'Upper Band',      color = color.new(color.red,   55), linewidth = 1)
plot(afterTarget ? lowerBand : na, 'Lower Band',      color = color.new(color.green, 55), linewidth = 1)

plotshape(longSignal,  title = 'LONG',  location = location.belowbar, style = shape.labelup,   color = color.green, text = 'LONG',  textcolor = color.white, size = size.small)
plotshape(shortSignal, title = 'SHORT', location = location.abovebar, style = shape.labeldown, color = color.red,   text = 'SHORT', textcolor = color.white, size = size.small)

bgcolor(is0929 ? color.new(color.yellow, 75) : na, title = '9:29 Candle')

// ═════════════════════════════════════════════
// Labels
// ═════════════════════════════════════════════
if afterTarget and not afterTarget[1] and not labelDrawn
    label.new(bar_index, fpHigh,    'H '  + str.tostring(fpHigh,    '#.00'), color = color.new(color.aqua,   20), textcolor = color.black, style = label.style_label_right)
    label.new(bar_index, fairPrice, 'FP ' + str.tostring(fairPrice, '#.00'), color = color.new(color.white,  20), textcolor = color.black, style = label.style_label_right)
    label.new(bar_index, fpLow,     'L '  + str.tostring(fpLow,     '#.00'), color = color.new(color.orange, 20), textcolor = color.black, style = label.style_label_right)
    labelDrawn := true

// ═════════════════════════════════════════════
// Alerts — TradersPost JSON format
// Use alertcondition for indicators (not alert())
// In TradingView: right click chart > Add Alert >
//   Condition = this indicator > LONG or SHORT
//   Notifications > Webhook URL = your TradersPost URL
// ═════════════════════════════════════════════
alertcondition(
     longSignal,
     title   = 'LONG ENTRY',
     message = '{"action":"buy","ticker":"{{ticker}}","price":{{close}},"comment":"9:29 Rubber Band LONG {{ticker}} at {{close}}"}'
 )

alertcondition(
     shortSignal,
     title   = 'SHORT ENTRY',
     message = '{"action":"sell","ticker":"{{ticker}}","price":{{close}},"comment":"9:29 Rubber Band SHORT {{ticker}} at {{close}}"}'
 )
````
