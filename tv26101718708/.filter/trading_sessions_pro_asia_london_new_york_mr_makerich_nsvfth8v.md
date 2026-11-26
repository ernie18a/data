# Trading Sessions Pro - Asia, London, New York [MR. MAKERICH]

- url: https://www.tradingview.com/script/NSVfth8v/
- type: indicator
- pine_id: PUB;7f1116e26ffb44a1bbf968a3f437d0be
- version: 2.0

## Description

Trading Sessions Pro - Asia, London, New York [MR. MAKERICH]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ WHAT IT IS

Trading Sessions Pro is an intraday indicator that combines session ranges, session highs and lows, daily and weekly reference levels, a level-status dashboard, optional sweep markers, and volume-based candle coloring.

The modules provide a connected view of session activity: where ranges develop, which reference prices remain relevant, and how subsequent price action interacts with earlier levels.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ SESSION WINDOWS AND RANGE BOXES

Five session windows are configurable. The default times use the Europe/Berlin timezone:

  • Asia ................... 00:00 - 08:00
  • London Pre-Open ........ 08:00 - 10:00
  • London ................. 10:00 - 13:30
  • New York Pre-Open ...... 13:30 - 14:00
  • New York ............... 14:00 - 23:00

Each enabled highlight draws a box between the highest and lowest price of its own window. The box updates as the session develops and stops updating after the window ends.

Session highlights are disabled by default and can be enabled individually. Colors and transparency are adjustable.

These are user-defined clock windows rather than automatically detected exchange sessions. Configure the times and timezone for the instrument being analyzed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ SESSION HIGH AND LOW LEVELS

Separate lines track Asia, London, and New York highs and lows.

The tracked London levels include both London Pre-Open and London. The individual highlight boxes measure their own windows, so the London box and the combined London levels can have different boundaries.

Session levels are enabled by default and can be switched on or off independently. Colors, line widths, labels, and optional glow are configurable.

Label spacing controls help separate annotations when several levels are close together.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ DAILY AND WEEKLY REFERENCE LEVELS

The higher-timeframe module provides:

  • Current-day high and low
  • Previous-day high and low (PDH / PDL)
  • Current-week high and low (CWH / CWL)
  • Previous-week high and low (PWH / PWL)

These references use the instrument's daily and weekly data. Their boundaries can differ from the configured intraday session windows.

Display controls allow users to include prices in labels, combine nearby labels within a specified tick distance, adjust label placement and short-line length, and show higher-timeframe levels only when they are sufficiently close to the current price.

Current-day and current-week values develop as new data arrive.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ SESSION LEVEL DASHBOARD

The dashboard is enabled by default and initially appears at the top right. Its position and row offset are adjustable.

It displays:

  • LEVEL — the tracked session high or low
  • PRICE — the level's price
  • DIST — the level price minus the current closing price
  • TAKEN — the takeout status and recorded time for tracked Asia and London levels

A positive distance places the level above the current close. A negative distance places it below. Recorded takeout times use the selected timezone.

New York levels display an active status when available. This status is not a session countdown.

The dashboard records level breaches separately from the rejection conditions used by the sweep module. A taken level therefore does not necessarily produce a sweep marker.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ OPTIONAL SWEEP MARKERS

Sweep markers are disabled by default. Pre-session, London, and New York conditions can be enabled separately.

  • Bearish: price trades above a tracked high and closes below it.
  • Bullish: price trades below a tracked low and closes above it.
  • Reclaim (optional): a return across the level after the preceding candle traded and closed beyond it.

Session relationships:

  • London Pre-Open → Asia levels
  • London → Asia levels
  • New York Pre-Open → London levels
  • New York → London and Asia levels

Marker colors are configurable. An optional marker-priority setting reduces overlapping signals.

These conditions describe price interaction with reference levels. They do not confirm that stops were executed or that a reversal will follow.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ SWEEP ALERTS

Corresponding sweep alert conditions are available through TradingView's Create Alert dialog. Alerts must be created by the user and depend on the relevant sweep category being enabled.

Auto Clean and marker-priority settings control the visual markers. They do not independently disable the underlying alert conditions.

For alerts intended to evaluate completed candles, select Once Per Bar Close when creating the alert.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ VOLUME VECTOR CANDLES

Candle coloring follows the widely known PVSRA volume concept.

The module is enabled by default. It classifies candles using relative volume and volume multiplied by candle range. With the default settings, reference volume is the average volume of the preceding 10 bars.

Climax activity occurs when either:

  • the current volume reaches at least 2x that average, or
  • the current volume multiplied by candle range reaches or exceeds its highest corresponding value over the preceding 10 bars.

Rising-volume activity occurs when volume reaches at least 1.5x the reference average and the climax condition is not met.

Default colors:

  • Green — bullish climax activity
  • Red — bearish climax activity
  • Blue — bullish rising-volume activity
  • Violet — bearish rising-volume activity
  • Gray shades — regular candles

A candle is classified as bullish when its close is at or above its open. Otherwise, it is classified as bearish.

The lookback, volume multipliers, and colors are adjustable. The calculation uses the volume data supplied for the instrument; it does not identify institutional participation or individual traders.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ AUTO CLEAN VIEW

Auto Clean reduces selected visual elements when the chart timeframe reaches or exceeds a configurable threshold. It is enabled by default, starting at 30 minutes.

Separate controls can hide:

  • Vertical session lines
  • Session labels
  • High/low labels
  • Sweep markers
  • Session-level glow

Session range boxes, level lines, candle coloring, and the dashboard remain governed by their individual display settings.

Returning to a lower timeframe restores the elements enabled in the regular settings. Auto Clean responds to a change in chart timeframe, not to visual zooming or scrolling.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ VISIBILITY AND APPEARANCE

  • A Monday-Friday session filter is enabled by default.
  • An optional current-day-only setting limits the display to the latest chart day.
  • Visible markings are limited to three calendar days by default. The number of visible days can be changed, or the limit can be disabled. Drawing-object limits still apply when displaying longer periods.
  • Dashed vertical session-start and session-end lines can be switched off using Show Dashed Session Vertical Lines.
  • Session colors, box transparency, line widths, label sizes, label spacing, and glow settings are configurable.
  • The optional indicator-name label is disabled by default.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ HOW TO USE IT

  1. Start with a standard intraday candlestick chart and configure the timezone and session windows.
  2. Enable the range boxes and reference levels relevant to your analysis.
  3. Use the dashboard to follow tracked prices and takeout status.
  4. Add sweep markers when you want to identify the defined rejection conditions.
  5. Use Volume Vector Candles to view relative activity alongside session structure.
  6. Configure Auto Clean to reduce visual detail when switching to higher timeframes.

Choose a chart timeframe whose bars align with the session boundaries. A five-minute chart fits the default windows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ PURPOSE AND USEFULNESS

The indicator connects session timing, realized ranges, reference prices, level status, and relative volume activity in one configurable layout.

Session boxes show how each range develops. High/low lines provide reference points for later price action. The dashboard summarizes tracked prices and takeout times, while optional sweep markers and candle coloring add information about rejection conditions and volume activity.

The combined view supports session-based analysis without requiring those elements to be tracked separately.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ NOTES AND LIMITATIONS

  • Calculations depend on available chart history, the instrument's trading hours, its data feed, and the selected settings.
  • Session ranges use chart-bar highs and lows. A candle crossing a session boundary can include activity outside the intended window. Partially loaded sessions can produce incomplete ranges.
  • Developing ranges, current daily and weekly references, volume colors, and sweep conditions can change while a candle is open. An intrabar sweep marker may disappear before the candle closes. Developing higher-timeframe values can also differ after recalculation. The indicator should not be treated as exclusively confirmed-bar or non-repainting.
  • A level breach does not establish stop execution or predict subsequent price direction.
  • Volume coloring depends on the volume feed available for the instrument.
  • Trading Sessions Pro provides analytical context. It does not execute trades, determine position size, or calculate protective stops and profit targets.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Developed by MR_MAKERICH.

## Source Code

````pine
//@version=6
indicator("Trading Sessions Pro - Asia, London, New York [MR. MAKERICH]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================================================
// INPUTS
//==================================================
grpGen = "General"
timezoneChoice = input.string("Europe/Berlin", "Display Timezone", options=["UTC", "UTC-12", "UTC-11", "UTC-10", "UTC-9:30", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3:30", "UTC-3", "UTC-2", "UTC-1", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+3:30", "UTC+4", "UTC+4:30", "UTC+5", "UTC+5:30", "UTC+5:45", "UTC+6", "UTC+6:30", "UTC+7", "UTC+8", "UTC+8:45", "UTC+9", "UTC+9:30", "UTC+10", "UTC+10:30", "UTC+11", "UTC+12", "UTC+12:45", "UTC+13", "UTC+13:45", "UTC+14", "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich", "Europe/Vienna", "Europe/Athens", "Europe/Moscow", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Toronto", "America/Sao_Paulo", "Africa/Johannesburg", "Asia/Dubai", "Asia/Kolkata", "Asia/Bangkok", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Tokyo", "Australia/Perth", "Australia/Sydney", "Pacific/Auckland"], tooltip="Timezone for YES timestamps and the optional My Timezone schedule. UTC offsets are fixed year-round (e.g. UTC+7). City timezones automatically follow local daylight saving time. Set the chart timezone separately in TradingView.", group=grpGen)
displayTz = timezoneChoice
showOnlyWeekdays = input.bool(true, "Show Only Monday-Friday", group=grpGen)
showOnlyToday    = input.bool(false, "Show Only Current Session Cycle", tooltip="A cycle starts at the configured Asia opening time in its selected input timezone. This avoids resets at midnight during Asia.", group=grpGen)

grpHist = "History / Visibility"
limitVisibleDays = input.bool(true, "Limit Visible Markings", group=grpHist)
visibleDays = input.int(3, "Visible Days", minval=1, group=grpHist)

// Two independent editable schedules. Switching selects a saved set, not a conversion.
// Local defaults match the original Berlin schedule during European summer time.
grpLocalSessions = "Session Times / Local Markets (Recommended)"
asiaLocalSess = input.session("0700-1500", "Asia (Tokyo)", group=grpLocalSessions)
londonPreOpenLocalSess = input.session("0700-0900", "London Pre-Open (London)", group=grpLocalSessions)
londonLocalSess = input.session("0900-1230", "London (London)", group=grpLocalSessions)
nyPreOpenLocalSess = input.session("0730-0800", "NY Pre-Open (New York)", group=grpLocalSessions)
nyLocalSess = input.session("0800-1700", "New York (New York)", group=grpLocalSessions)
// A separate blank-heading group adds spacing before the warning.
grpTimezoneWarning = " "
useOwnSessionTimezone = input.bool(false, "WARNING: Use my timezone (local market times recommended)", tooltip="OFF: Use local market times (strongly recommended). They follow each market's summer/winter time changes. ON: Use your separate custom schedule; market DST shifts may require manual adjustments.", group=grpTimezoneWarning)
grpOwnSessions = "Session Times / My Timezone"
asiaOwnSess = input.session("0000-0800", "Asia", group=grpOwnSessions)
londonPreOpenOwnSess = input.session("0800-1000", "London Pre-Open", group=grpOwnSessions)
londonOwnSess = input.session("1000-1330", "London", group=grpOwnSessions)
nyPreOpenOwnSess = input.session("1330-1400", "NY Pre-Open", group=grpOwnSessions)
nyOwnSess = input.session("1400-2300", "New York", group=grpOwnSessions)
asiaTz = useOwnSessionTimezone ? displayTz : "Asia/Tokyo"
londonTz = useOwnSessionTimezone ? displayTz : "Europe/London"
nyTz = useOwnSessionTimezone ? displayTz : "America/New_York"
asiaSess = useOwnSessionTimezone ? asiaOwnSess : asiaLocalSess
londonPreOpenSess = useOwnSessionTimezone ? londonPreOpenOwnSess : londonPreOpenLocalSess
londonSess = useOwnSessionTimezone ? londonOwnSess : londonLocalSess
nyPreOpenSess = useOwnSessionTimezone ? nyPreOpenOwnSess : nyPreOpenLocalSess
nySess = useOwnSessionTimezone ? nyOwnSess : nyLocalSess

grpWin = "Display - Windows"
showAsiaWindow      = input.bool(false, "Highlight Asia", group=grpWin)
showLondonPreWindow = input.bool(false, "Highlight London Pre-Open", group=grpWin)
showLondonWindow    = input.bool(false, "Highlight London", group=grpWin)
showNYPreWindow     = input.bool(false, "Highlight NY Pre-Open", group=grpWin)
showNYWindow        = input.bool(false, "Highlight New York", group=grpWin)

grpHL = "Display - Levels"
showAsiaHL   = input.bool(true, "Show Asia High/Low", group=grpHL)
showLondonHL = input.bool(true, "Show London High/Low", group=grpHL)
showNYHL     = input.bool(true, "Show New York High/Low", group=grpHL)
showLevelGlow = input.bool(true, "Glow Session High/Low", group=grpHL)

grpHtf = "HTF Levels"
showDailyHighLow = input.bool(true, "Show Daily High / Low", group=grpHtf)
showPdhPdl = input.bool(true, "Show PDH / PDL", group=grpHtf)
showCwhCwl = input.bool(true, "Show CWH / CWL", group=grpHtf)
showPwhPwl = input.bool(true, "Show PWH / PWL", group=grpHtf)
showHtfLevelPrices = input.bool(false, "Show Prices in Labels", group=grpHtf)
htfLevelRightBars = input.int(25, "Label Offset to the Right (Bars)", minval=1, maxval=100, group=grpHtf)
htfNamedLookbackBars = input.int(70, "Short HTF Line Length to the Left (Bars)", minval=10, maxval=500, group=grpHtf)
htfLabelMergeTicks = input.int(10, "Merge Labels Within (Ticks)", minval=0, maxval=200, group=grpHtf)
showHtfOnlyNearPrice = input.bool(false, "Show HTF Levels Only Near Price", group=grpHtf)
htfNearPriceDistance = input.float(80.0, "HTF Near-Price Distance", minval=0.0, step=1.0, group=grpHtf)

grpLogic = "Logic"
showReclaimSweeps = input.bool(true, "Use reclaim sweeps (2-candle rejection)", group=grpLogic)

grpSessionDash = "Session Level Dashboard"
showCurrentSession = input.bool(true, "Show Current Session Centered Below Dashboard", tooltip="Uses the latest chart bar, including in replay. Updates when the indicator receives a chart update.", group=grpSessionDash)
showSessionStatusTable = input.bool(true, "Show Session High/Low Status", group=grpSessionDash)
sessionStatusPosition = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpSessionDash)
sessionStatusOffsetRows = input.int(0, "Dashboard Offset (Rows)", minval=0, maxval=6, group=grpSessionDash)


grpVector = "Volume Vector Candles"
showVectorCandles = input.bool(true, "Show Volume Vector Candle Colors", group=grpVector)
vectorLookback = input.int(10, "Volume Lookback", minval=1, group=grpVector)
vectorClimaxMult = input.float(2.0, "Climax Volume Multiplier", minval=0.1, step=0.1, group=grpVector)
vectorRisingMult = input.float(1.5, "Rising Volume Multiplier", minval=0.1, step=0.1, group=grpVector)
redVectorColor = input.color(color.red, "Bearish Climax Color", group=grpVector)
greenVectorColor = input.color(color.lime, "Bullish Climax Color", group=grpVector)
violetVectorColor = input.color(color.fuchsia, "Bearish Rising Volume Color", group=grpVector)
blueVectorColor = input.color(color.blue, "Bullish Rising Volume Color", group=grpVector)
regularCandleUpColor = input.color(#999999, "Regular Bull Candle", group=grpVector)
regularCandleDownColor = input.color(#4d4d4d, "Regular Bear Candle", group=grpVector)

grpSweep = "Display - Sweeps"
showPreSweeps      = input.bool(false, "Show Pre-Session Sweeps", group=grpSweep)
showLondonSweeps   = input.bool(false, "Show London Sweeps", group=grpSweep)
showNYSweeps       = input.bool(false, "Show New York Sweeps", group=grpSweep)
oneMarkerPerBar    = input.bool(true, "Prefer One Sweep Marker Per Bar", group=grpSweep)

grpMisc = "Display - Misc"
showSessionLabels = input.bool(true, "Show Session Start Labels", group=grpMisc)
showHLLabels      = input.bool(true, "Show Level Labels", group=grpMisc)
showVerticals     = input.bool(true, "Show Dashed Session Vertical Lines", group=grpMisc)
showBrandLabel    = input.bool(false, "Show Indicator Name on Chart", group=grpMisc)
brandColor = input.color(#FF00FF, "Brand Color", group=grpMisc)

grpClean = "Auto Clean View"
autoCleanHigherTf = input.bool(true, "Auto Clean on Higher Timeframes", group=grpClean)
cleanFromTf = input.timeframe("30", "Clean From Timeframe", group=grpClean)
cleanHideVerticals = input.bool(true, "Clean: Hide Vertical Lines", group=grpClean)
cleanHideSessionLabels = input.bool(true, "Clean: Hide Session Labels", group=grpClean)
cleanHideHLLabels = input.bool(true, "Clean: Hide High/Low Labels", group=grpClean)
cleanHideSweeps = input.bool(true, "Clean: Hide Sweep Markers", group=grpClean)
cleanHideGlow = input.bool(true, "Clean: Hide Glow", group=grpClean)

grpBg = "Style - Background"
asiaBgCol      = input.color(color.new(color.purple, 85), "Asia BG", group=grpBg)
londonPreBgCol = input.color(color.new(color.fuchsia, 88), "London Pre-Open BG", group=grpBg)
londonBgCol    = input.color(color.new(color.yellow, 84), "London BG", group=grpBg)
nyPreBgCol     = input.color(color.new(color.teal, 88), "NY Pre-Open BG", group=grpBg)
nyBgCol        = input.color(color.new(color.green, 85), "New York BG", group=grpBg)

grpLine = "Style - Levels"
asiaLineCol   = input.color(color.new(color.aqua, 0), "Asia Level Color", group=grpLine)
londonLineCol = input.color(color.new(color.orange, 0), "London Level Color", group=grpLine)
nyLineCol     = input.color(color.new(color.red, 0), "New York Level Color", group=grpLine)

grpVert = "Style - Vertical Lines"
vertAsiaCol      = input.color(color.new(color.purple, 0), "Asia Vertical", group=grpVert)
vertLondonPreCol = input.color(color.new(color.fuchsia, 0), "London Pre-Open Vertical", group=grpVert)
vertLondonCol    = input.color(color.new(color.yellow, 0), "London Vertical", group=grpVert)
vertNYPreCol     = input.color(color.new(color.teal, 0), "NY Pre-Open Vertical", group=grpVert)
vertNYCol        = input.color(color.new(color.green, 0), "New York Vertical", group=grpVert)

grpSweepStyle = "Style - Sweeps"
preSweepBearCol = input.color(color.new(color.gray, 0), "Pre-Sweep Bear Color", group=grpSweepStyle)
preSweepBullCol = input.color(color.new(color.silver, 0), "Pre-Sweep Bull Color", group=grpSweepStyle)
lonAsiaBearCol  = input.color(color.new(color.orange, 0), "London sweeps Asia High", group=grpSweepStyle)
lonAsiaBullCol  = input.color(color.new(color.orange, 0), "London sweeps Asia Low", group=grpSweepStyle)
nyLondonBearCol = input.color(color.new(color.red, 0), "NY sweeps London High", group=grpSweepStyle)
nyLondonBullCol = input.color(color.new(color.red, 0), "NY sweeps London Low", group=grpSweepStyle)
nyAsiaBearCol   = input.color(color.new(color.maroon, 0), "NY sweeps Asia High", group=grpSweepStyle)
nyAsiaBullCol   = input.color(color.new(color.maroon, 0), "NY sweeps Asia Low", group=grpSweepStyle)

grpSizes = "Style - Sizes"
hlLineWidth      = input.int(2, "Level Line Width", minval=1, maxval=5, group=grpSizes)
vertLineWidth    = input.int(1, "Vertical Line Width", minval=1, maxval=4, group=grpSizes)
sessionLabelSizeIn = input.string("Tiny", "Session Label Size", options=["Tiny", "Small", "Normal"], group=grpSizes)
glowLineWidth = input.int(6, "Glow Line Width", minval=2, maxval=12, group=grpSizes)
glowTransparency = input.int(78, "Glow Transparency", minval=0, maxval=100, group=grpSizes)
sessionLabelBaseAtr = input.float(0.42, "Session Label Base ATR Offset", minval=0.01, step=0.01, group=grpSizes)
sessionLabelStackAtr = input.float(0.16, "Session Label Stack ATR Offset", minval=0.01, step=0.01, group=grpSizes)

sessionLabelSize = sessionLabelSizeIn == "Tiny" ? size.tiny : sessionLabelSizeIn == "Small" ? size.small : size.normal
chartTfSec = timeframe.in_seconds(timeframe.period)
cleanTfSec = timeframe.in_seconds(cleanFromTf)
cleanViewActive = autoCleanHigherTf and chartTfSec >= cleanTfSec
effectiveShowVerticals = showVerticals and not (cleanViewActive and cleanHideVerticals)
effectiveShowSessionLabels = showSessionLabels and not (cleanViewActive and cleanHideSessionLabels)
effectiveShowHLLabels = showHLLabels and not (cleanViewActive and cleanHideHLLabels)
effectiveShowSweeps = not (cleanViewActive and cleanHideSweeps)
effectiveShowLevelGlow = showLevelGlow and not (cleanViewActive and cleanHideGlow)

var line[] trackedLines = array.new_line()
var label[] trackedLabels = array.new_label()
var box[] trackedSessionBoxes = array.new_box()

//==================================================
// VOLUME VECTOR CANDLES
// Candle coloring follows the widely known PVSRA volume concept
//==================================================
vectorAvgVolume = ta.sma(volume[1], vectorLookback)
vectorSpread = high - low
vectorVolumeSpread = volume * vectorSpread
vectorHighestVolumeSpread = ta.highest(vectorVolumeSpread[1], vectorLookback)
vectorIsBull = close >= open
vectorIsClimax = not na(vectorAvgVolume) and not na(vectorHighestVolumeSpread) and (volume >= vectorAvgVolume * vectorClimaxMult or vectorVolumeSpread >= vectorHighestVolumeSpread)
vectorIsRising = not vectorIsClimax and not na(vectorAvgVolume) and volume >= vectorAvgVolume * vectorRisingMult
vectorColor =
     vectorIsClimax ? (vectorIsBull ? greenVectorColor : redVectorColor) :
     vectorIsRising ? (vectorIsBull ? blueVectorColor : violetVectorColor) :
     vectorIsBull ? regularCandleUpColor : regularCandleDownColor

barcolor(showVectorCandles ? vectorColor : na)

//==================================================
// HELPERS
//==================================================
f_sessionAnchor(int _t, string _sess, string _zone) =>
    _h = int(str.tonumber(str.substring(_sess, 0, 2)))
    _m = int(str.tonumber(str.substring(_sess, 2, 4)))
    _before = hour(_t, _zone) * 60 + minute(_t, _zone) < _h * 60 + _m
    timestamp(_zone, year(_t, _zone), month(_t, _zone), dayofmonth(_t, _zone) - (_before ? 1 : 0), _h, _m)

f_inSession(_sess, _zone) =>
    // Weekdays belong to the local session's start date, also across midnight.
    _anchor = f_sessionAnchor(time, _sess, _zone)
    _weekday = dayofweek(_anchor, _zone)
    _allow = not showOnlyWeekdays or (_weekday >= dayofweek.monday and _weekday <= dayofweek.friday)
    _allow and not na(time(timeframe.period, _sess, _zone))

f_sessionStart(_in) =>
    _in and not _in[1]

f_sessionEnd(_in) =>
    not _in and _in[1]

f_timeHhMm(_t) =>
    na(_t) ? "-" : str.format("{0,number,00}:{1,number,00}", hour(_t, displayTz), minute(_t, displayTz))

f_points(_value) =>
    na(_value) ? "-" : str.tostring(_value, "#.##")

f_fmt(_v) =>
    str.tostring(_v, format.mintick)

f_sessionStatusPosition() =>
    sessionStatusPosition == "Top Left" ? position.top_left :
     sessionStatusPosition == "Top Center" ? position.top_center :
     sessionStatusPosition == "Bottom Left" ? position.bottom_left :
     sessionStatusPosition == "Bottom Center" ? position.bottom_center :
     sessionStatusPosition == "Bottom Right" ? position.bottom_right :
     position.top_right

f_labelTextColor(_col) =>
    _brightness = color.r(_col) * 0.299 + color.g(_col) * 0.587 + color.b(_col) * 0.114
    _brightness > 160 ? color.black : color.white

f_newVLine(_t, _col) =>
    _ln = line.new(
         x1=_t, y1=high,
         x2=_t, y2=low,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=_col,
         width=vertLineWidth,
         style=line.style_dashed)
    array.push(trackedLines, _ln)
    _ln

f_newTopSessionLabel(_t, _txt, _col) =>
    _lb = label.new(
         x=_t,
         y=high,
         xloc=xloc.bar_time,
         text=" " + _txt + " ",
         style=label.style_label_down,
         textcolor=f_labelTextColor(_col),
         color=color.new(_col, 0),
         size=sessionLabelSize,
         textalign=text.align_center)
    array.push(trackedLabels, _lb)
    _lb

f_newBottomSessionLabel(_t, _txt, _col) =>
    _lb = label.new(
         x=_t,
         y=low,
         xloc=xloc.bar_time,
         text=" " + _txt + " ",
         style=label.style_label_up,
         textcolor=f_labelTextColor(_col),
         color=color.new(_col, 0),
         size=sessionLabelSize,
         textalign=text.align_center)
    array.push(trackedLabels, _lb)
    _lb

f_newHLLine(_x1, _price, _col) =>
    _ln = line.new(
         x1=_x1, y1=_price,
         x2=time, y2=_price,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=_col,
         width=hlLineWidth,
         style=line.style_solid)
    array.push(trackedLines, _ln)
    _ln

f_newHLGlowLine(_x1, _price, _col) =>
    _ln = line.new(
         x1=_x1, y1=_price,
         x2=time, y2=_price,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=color.new(_col, glowTransparency),
         width=glowLineWidth,
         style=line.style_solid)
    array.push(trackedLines, _ln)
    _ln

f_newHLLabel(_x, _price, _txt, _col) =>
    _isHigh = str.contains(_txt, "HIGH")
    _lb = label.new(
         x=_x,
         y=_price,
         xloc=xloc.bar_time,
         text=" " + _txt + " ",
         style=_isHigh ? label.style_label_lower_left : label.style_label_upper_left,
         textcolor=f_labelTextColor(_col),
         color=color.new(_col, 20),
         size=size.tiny)
    array.push(trackedLabels, _lb)
    _lb

f_drawNamedHtfLevel(line _ln, label _lb, bool _show, float _price, string _txt, color _col, int _xLeft, int _xRight, int _opacity) =>
    line _nextLine = _ln
    label _nextLabel = _lb
    _labelText = showHtfLevelPrices ? _txt + " " + f_fmt(_price) : _txt
    if _show and not na(_price)
        if na(_nextLine)
            _nextLine := line.new(_xLeft, _price, _xRight, _price, color=color.new(_col, _opacity), width=1, style=line.style_dashed)
            _nextLabel := label.new(_xRight, _price, _labelText, style=label.style_none, color=color.new(_col, 100), textcolor=color.new(_col, math.max(0, _opacity - 15)), size=size.small)
        line.set_xy1(_nextLine, _xLeft, _price)
        line.set_xy2(_nextLine, _xRight, _price)
        line.set_color(_nextLine, color.new(_col, _opacity))
        line.set_width(_nextLine, 1)
        line.set_style(_nextLine, line.style_dashed)
        label.set_xy(_nextLabel, _xRight, _price)
        label.set_text(_nextLabel, _labelText)
        label.set_textcolor(_nextLabel, color.new(_col, math.max(0, _opacity - 15)))
        label.set_color(_nextLabel, color.new(_col, 100))
        label.set_size(_nextLabel, size.small)
    else
        if not na(_nextLine)
            line.set_color(_nextLine, color.new(_col, 100))
        if not na(_nextLabel)
            label.set_text(_nextLabel, "")
    [_nextLine, _nextLabel]

f_priceNear(float _a, float _b, float _tol) =>
    not na(_a) and not na(_b) and math.abs(_a - _b) <= _tol

f_htfPriceVisible(float _price) =>
    not showHtfOnlyNearPrice or (not na(_price) and math.abs(close - _price) <= htfNearPriceDistance)

f_joinLabelText(string _base, bool _add, string _txt) =>
    _add ? _base + " / " + _txt : _base

f_drawFullHtfLevel(line _ln, label _lb, bool _show, float _price, string _txt, color _col, int _xRight, int _opacity) =>
    line _nextLine = _ln
    label _nextLabel = _lb
    _labelText = showHtfLevelPrices ? _txt + " " + f_fmt(_price) : _txt
    if _show and not na(_price)
        if na(_nextLine)
            _nextLine := line.new(bar_index, _price, bar_index + 1, _price, color=color.new(_col, _opacity), width=2, style=line.style_dashed, extend=extend.both)
            _nextLabel := label.new(_xRight, _price, _labelText, style=label.style_label_left, color=color.new(_col, 8), textcolor=color.white, size=size.small)
        line.set_xy1(_nextLine, bar_index, _price)
        line.set_xy2(_nextLine, bar_index + 1, _price)
        line.set_color(_nextLine, color.new(_col, _opacity))
        line.set_width(_nextLine, 2)
        line.set_style(_nextLine, line.style_dashed)
        line.set_extend(_nextLine, extend.both)
        label.set_xy(_nextLabel, _xRight, _price)
        label.set_text(_nextLabel, _labelText)
        label.set_color(_nextLabel, color.new(_col, 8))
        label.set_textcolor(_nextLabel, color.white)
    else
        if not na(_nextLine)
            line.set_color(_nextLine, color.new(_col, 100))
        if not na(_nextLabel)
            label.set_text(_nextLabel, "")
    [_nextLine, _nextLabel]

f_deleteLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

f_deleteLabel(_lb) =>
    if not na(_lb)
        label.delete(_lb)

f_pruneArtifacts(_cutoffTs) =>
    if array.size(trackedLines) > 0
        for i = array.size(trackedLines) - 1 to 0
            _ln = array.get(trackedLines, i)
            if na(_ln) or line.get_x1(_ln) < _cutoffTs
                if not na(_ln)
                    line.delete(_ln)
                array.remove(trackedLines, i)
    if array.size(trackedLabels) > 0
        for i = array.size(trackedLabels) - 1 to 0
            _lb = array.get(trackedLabels, i)
            if na(_lb) or label.get_x(_lb) < _cutoffTs
                if not na(_lb)
                    label.delete(_lb)
                array.remove(trackedLabels, i)

f_updateHL(_ln, _glowLn, _lb, _price, _txt) =>
    if not na(_ln)
        line.set_x2(_ln, time)
        line.set_y1(_ln, _price)
        line.set_y2(_ln, _price)
    if not na(_glowLn)
        line.set_x2(_glowLn, time)
        line.set_y1(_glowLn, _price)
        line.set_y2(_glowLn, _price)
    if not na(_lb)
        label.set_x(_lb, time)
        label.set_text(_lb, " " + _txt + " ")

f_higherCount(_price, float _a, float _b, float _c) =>
    int _count = 0
    if not na(_a) and _a > _price
        _count += 1
    if not na(_b) and _b > _price
        _count += 1
    if not na(_c) and _c > _price
        _count += 1
    _count

f_lowerCount(_price, float _a, float _b, float _c) =>
    int _count = 0
    if not na(_a) and _a < _price
        _count += 1
    if not na(_b) and _b < _price
        _count += 1
    if not na(_c) and _c < _price
        _count += 1
    _count

f_topSessionY(_price, float _a, float _b, float _c) =>
    _price + ta.atr(14) * (sessionLabelBaseAtr + f_higherCount(_price, _a, _b, _c) * sessionLabelStackAtr)

f_bottomSessionY(_price, float _a, float _b, float _c) =>
    _price - ta.atr(14) * (sessionLabelBaseAtr + f_lowerCount(_price, _a, _b, _c) * sessionLabelStackAtr)

f_strictBearSweep(_level) =>
    not na(_level) and high > _level and close < _level

f_strictBullSweep(_level) =>
    not na(_level) and low < _level and close > _level

f_reclaimBearSweep(_level) =>
    showReclaimSweeps and not na(_level) and close < _level and high[1] > _level and close[1] > _level

f_reclaimBullSweep(_level) =>
    showReclaimSweeps and not na(_level) and close > _level and low[1] < _level and close[1] < _level

//==================================================
// DAY DETECTION
//==================================================
// A trading cycle starts at Asia open, not at Berlin midnight.
f_dayStart(_t) =>
    f_sessionAnchor(_t, asiaSess, asiaTz)

lastDayStartTs = f_dayStart(last_bar_time)
barDayStartTs = f_dayStart(time)
newDay = bar_index > 0 and barDayStartTs != barDayStartTs[1]
visibleStartTs = timestamp(asiaTz, year(lastDayStartTs, asiaTz), month(lastDayStartTs, asiaTz), dayofmonth(lastDayStartTs, asiaTz) - (visibleDays - 1), hour(lastDayStartTs, asiaTz), minute(lastDayStartTs, asiaTz))

showCurrentDayOnly = showOnlyToday
isVisibleBar = showCurrentDayOnly ? barDayStartTs == lastDayStartTs : (not limitVisibleDays or barDayStartTs >= visibleStartTs)

[currDayHighHtf, currDayLowHtf] = request.security(syminfo.tickerid, "D", [high, low], lookahead=barmerge.lookahead_off)
[prevDayHighHtf, prevDayLowHtf] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[currWeekHighHtf, currWeekLowHtf] = request.security(syminfo.tickerid, "W", [high, low], lookahead=barmerge.lookahead_off)
[prevWeekHighHtf, prevWeekLowHtf] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

artifactCutoffTs = showCurrentDayOnly ? lastDayStartTs : (limitVisibleDays ? visibleStartTs : na)
if barstate.islast and not na(artifactCutoffTs)
    f_pruneArtifacts(artifactCutoffTs)

//==================================================
// SESSION STATES
//==================================================
inAsia      = f_inSession(asiaSess, asiaTz)
inLonPre    = f_inSession(londonPreOpenSess, londonTz)
inLondon    = f_inSession(londonSess, londonTz)
inNYPre     = f_inSession(nyPreOpenSess, nyTz)
inNY        = f_inSession(nySess, nyTz)

asiaSessionKey = f_sessionAnchor(time, asiaSess, asiaTz)
asiaStart = inAsia and (not inAsia[1] or asiaSessionKey != asiaSessionKey[1])
asiaEnd     = f_sessionEnd(inAsia)
lonPreSessionKey = f_sessionAnchor(time, londonPreOpenSess, londonTz)
lonPreStart = inLonPre and (not inLonPre[1] or lonPreSessionKey != lonPreSessionKey[1])
lonPreEnd   = f_sessionEnd(inLonPre)
londonSessionKey = f_sessionAnchor(time, londonSess, londonTz)
londonStart = inLondon and (not inLondon[1] or londonSessionKey != londonSessionKey[1])
londonEnd   = f_sessionEnd(inLondon)
nyPreSessionKey = f_sessionAnchor(time, nyPreOpenSess, nyTz)
nyPreStart = inNYPre and (not inNYPre[1] or nyPreSessionKey != nyPreSessionKey[1])
nyPreEnd    = f_sessionEnd(inNYPre)
nySessionKey = f_sessionAnchor(time, nySess, nyTz)
nyStart = inNY and (not inNY[1] or nySessionKey != nySessionKey[1])
nyEnd       = f_sessionEnd(inNY)

//==================================================
// STORAGE
//==================================================
var float asiaHigh = na
var float asiaLow  = na
var float londonHigh = na
var float londonLow  = na
var float nyHigh = na
var float nyLow  = na

var bool asiaHighTaken = false
var bool asiaLowTaken = false
var bool londonHighTaken = false
var bool londonLowTaken = false
var bool nyHighTaken = false
var bool nyLowTaken = false
var int asiaHighTakenTime = na
var int asiaLowTakenTime = na
var int londonHighTakenTime = na
var int londonLowTakenTime = na
var int nyHighTakenTime = na
var int nyLowTakenTime = na

//==================================================
// HOLDERS
//==================================================
var float lonPreHigh = na
var float lonPreLow = na
var float nyPreHigh = na
var float nyPreLow = na

var int asiaStartTime = na
var int lonPreStartTime = na
var int londonLevelStartTime = na
var int londonStartTime = na
var int nyPreStartTime = na
var int nyStartTime = na

var label asiaTopSessionLabel = na
var label asiaBottomSessionLabel = na
var label lonPreTopSessionLabel = na
var label lonPreBottomSessionLabel = na
var label londonTopSessionLabel = na
var label londonBottomSessionLabel = na
var label nyPreTopSessionLabel = na
var label nyPreBottomSessionLabel = na
var label nyTopSessionLabel = na
var label nyBottomSessionLabel = na

var line asiaHighLine = na
var line asiaLowLine  = na
var line asiaHighGlowLine = na
var line asiaLowGlowLine  = na
var label asiaHighLabel = na
var label asiaLowLabel  = na

var line londonHighLine = na
var line londonLowLine  = na
var line londonHighGlowLine = na
var line londonLowGlowLine  = na
var label londonHighLabel = na
var label londonLowLabel  = na

var line nyHighLine = na
var line nyLowLine  = na
var line nyHighGlowLine = na
var line nyLowGlowLine  = na
var label nyHighLabel = na
var label nyLowLabel  = na

var line dailyHighHtfLine = na
var line dailyLowHtfLine = na
var line pdhHtfLine = na
var line pdlHtfLine = na
var line cwhHtfLine = na
var line cwlHtfLine = na
var line pwhHtfLine = na
var line pwlHtfLine = na
var label dailyHighHtfLabel = na
var label dailyLowHtfLabel = na
var label pdhHtfLabel = na
var label pdlHtfLabel = na
var label cwhHtfLabel = na
var label cwlHtfLabel = na
var label pwhHtfLabel = na
var label pwlHtfLabel = na



//==================================================
// RESET ON NEW DAY
//==================================================
if showOnlyToday and newDay
    f_deleteLabel(asiaTopSessionLabel)
    f_deleteLabel(asiaBottomSessionLabel)
    f_deleteLabel(lonPreTopSessionLabel)
    f_deleteLabel(lonPreBottomSessionLabel)
    f_deleteLabel(londonTopSessionLabel)
    f_deleteLabel(londonBottomSessionLabel)
    f_deleteLabel(nyPreTopSessionLabel)
    f_deleteLabel(nyPreBottomSessionLabel)
    f_deleteLabel(nyTopSessionLabel)
    f_deleteLabel(nyBottomSessionLabel)

    f_deleteLine(asiaHighLine)
    f_deleteLine(asiaLowLine)
    f_deleteLine(asiaHighGlowLine)
    f_deleteLine(asiaLowGlowLine)
    f_deleteLabel(asiaHighLabel)
    f_deleteLabel(asiaLowLabel)

    f_deleteLine(londonHighLine)
    f_deleteLine(londonLowLine)
    f_deleteLine(londonHighGlowLine)
    f_deleteLine(londonLowGlowLine)
    f_deleteLabel(londonHighLabel)
    f_deleteLabel(londonLowLabel)

    f_deleteLine(nyHighLine)
    f_deleteLine(nyLowLine)
    f_deleteLine(nyHighGlowLine)
    f_deleteLine(nyLowGlowLine)
    f_deleteLabel(nyHighLabel)
    f_deleteLabel(nyLowLabel)

    asiaTopSessionLabel := na
    asiaBottomSessionLabel := na
    lonPreTopSessionLabel := na
    lonPreBottomSessionLabel := na
    londonTopSessionLabel := na
    londonBottomSessionLabel := na
    nyPreTopSessionLabel := na
    nyPreBottomSessionLabel := na
    nyTopSessionLabel := na
    nyBottomSessionLabel := na

    asiaHighLine := na
    asiaLowLine := na
    asiaHighGlowLine := na
    asiaLowGlowLine := na
    asiaHighLabel := na
    asiaLowLabel := na

    londonHighLine := na
    londonLowLine := na
    londonHighGlowLine := na
    londonLowGlowLine := na
    londonHighLabel := na
    londonLowLabel := na

    nyHighLine := na
    nyLowLine := na
    nyHighGlowLine := na
    nyLowGlowLine := na
    nyHighLabel := na
    nyLowLabel := na

    asiaHigh := na
    asiaLow := na
    lonPreHigh := na
    lonPreLow := na
    londonHigh := na
    londonLow := na
    nyPreHigh := na
    nyPreLow := na
    nyHigh := na
    nyLow := na

// Reset cycle-scoped references at the next Asia opening boundary.
// This keeps old drawings visible when Visible Days > 1, but stops the
// current-session logic from reusing yesterday's start times/labels on higher timeframes.
if newDay
    asiaStartTime := na
    lonPreStartTime := na
    londonLevelStartTime := na
    londonStartTime := na
    nyPreStartTime := na
    nyStartTime := na

    asiaTopSessionLabel := na
    asiaBottomSessionLabel := na
    lonPreTopSessionLabel := na
    lonPreBottomSessionLabel := na
    londonTopSessionLabel := na
    londonBottomSessionLabel := na
    nyPreTopSessionLabel := na
    nyPreBottomSessionLabel := na
    nyTopSessionLabel := na
    nyBottomSessionLabel := na

    asiaHighLine := na
    asiaLowLine := na
    asiaHighGlowLine := na
    asiaLowGlowLine := na
    asiaHighLabel := na
    asiaLowLabel := na

    londonHighLine := na
    londonLowLine := na
    londonHighGlowLine := na
    londonLowGlowLine := na
    londonHighLabel := na
    londonLowLabel := na

    nyHighLine := na
    nyLowLine := na
    nyHighGlowLine := na
    nyLowGlowLine := na
    nyHighLabel := na
    nyLowLabel := na

    asiaHigh := na
    asiaLow := na
    lonPreHigh := na
    lonPreLow := na
    londonHigh := na
    londonLow := na
    nyPreHigh := na
    nyPreLow := na
    nyHigh := na
    nyLow := na
    asiaHighTaken := false
    asiaLowTaken := false
    londonHighTaken := false
    londonLowTaken := false
    nyHighTaken := false
    nyLowTaken := false
    asiaHighTakenTime := na
    asiaLowTakenTime := na
    londonHighTakenTime := na
    londonLowTakenTime := na
    nyHighTakenTime := na
    nyLowTakenTime := na

//==================================================
// WINDOWS
//==================================================
// Each call keeps its own range, independent of the High/Low line toggles.
// Ranges use chart-bar highs/lows; align chart bars with session boundaries.
f_sessionRangeBox(_enabled, _inSession, _sess, _zone, _fill) =>
    var box _activeBox = na
    var int _activeSession = na
    var float _rangeHigh = na
    var float _rangeLow = na
    _startHour = int(str.tonumber(str.substring(_sess, 0, 2)))
    _startMinute = int(str.tonumber(str.substring(_sess, 2, 4)))
    _beforeStart = hour(time, _zone) * 60 + minute(time, _zone) < _startHour * 60 + _startMinute
    _sessionKey = timestamp(_zone, year(time, _zone), month(time, _zone), dayofmonth(time, _zone) - (_beforeStart ? 1 : 0), _startHour, _startMinute)
    _barEnd = nz(time_close(timeframe.period, _sess, _zone), time)
    if _enabled and _inSession
        if na(_activeSession) or _sessionKey != _activeSession
            _activeSession := _sessionKey
            _activeBox := na
            _rangeHigh := high
            _rangeLow := low
        else
            _rangeHigh := math.max(_rangeHigh, high)
            _rangeLow := math.min(_rangeLow, low)
        if isVisibleBar
            if na(_activeBox)
                if array.size(trackedSessionBoxes) >= 500
                    box.delete(array.shift(trackedSessionBoxes))
                _activeBox := box.new(left=math.max(_sessionKey, showCurrentDayOnly ? lastDayStartTs : _sessionKey), top=_rangeHigh, right=_barEnd, bottom=_rangeLow, xloc=xloc.bar_time, border_color=na, bgcolor=_fill)
                array.push(trackedSessionBoxes, _activeBox)
            else
                box.set_top(_activeBox, _rangeHigh)
                box.set_bottom(_activeBox, _rangeLow)
                box.set_right(_activeBox, _barEnd)
    _activeBox

f_sessionRangeBox(showAsiaWindow, inAsia, asiaSess, asiaTz, asiaBgCol)
f_sessionRangeBox(showLondonPreWindow, inLonPre, londonPreOpenSess, londonTz, londonPreBgCol)
f_sessionRangeBox(showLondonWindow, inLondon, londonSess, londonTz, londonBgCol)
f_sessionRangeBox(showNYPreWindow, inNYPre, nyPreOpenSess, nyTz, nyPreBgCol)
f_sessionRangeBox(showNYWindow, inNY, nySess, nyTz, nyBgCol)

// Apply the existing history visibility limit to completed range boxes too.
if barstate.islast and not na(artifactCutoffTs) and array.size(trackedSessionBoxes) > 0
    for i = array.size(trackedSessionBoxes) - 1 to 0
        _oldBox = array.get(trackedSessionBoxes, i)
        if box.get_right(_oldBox) <= artifactCutoffTs
            box.delete(_oldBox)
            array.remove(trackedSessionBoxes, i)
        else if box.get_left(_oldBox) < artifactCutoffTs
            box.set_left(_oldBox, artifactCutoffTs)

//==================================================
// VERTICALS
//==================================================
if effectiveShowVerticals and asiaStart
    f_newVLine(time, vertAsiaCol)
if effectiveShowVerticals and asiaEnd
    f_newVLine(time, vertAsiaCol)

if effectiveShowVerticals and lonPreStart
    f_newVLine(time, vertLondonPreCol)
if effectiveShowVerticals and lonPreEnd
    f_newVLine(time, vertLondonPreCol)

if effectiveShowVerticals and londonStart
    f_newVLine(time, vertLondonCol)
if effectiveShowVerticals and londonEnd
    f_newVLine(time, vertLondonCol)

if effectiveShowVerticals and nyPreStart
    f_newVLine(time, vertNYPreCol)
if effectiveShowVerticals and nyPreEnd
    f_newVLine(time, vertNYPreCol)

if effectiveShowVerticals and nyStart
    f_newVLine(time, vertNYCol)
if effectiveShowVerticals and nyEnd
    f_newVLine(time, vertNYCol)


//==================================================
// BUILD LEVELS
//==================================================
if showAsiaHL
    if asiaStart
        asiaStartTime := time
        asiaHigh := high
        asiaLow  := low

        f_deleteLine(asiaHighLine)
        f_deleteLine(asiaLowLine)
        f_deleteLine(asiaHighGlowLine)
        f_deleteLine(asiaLowGlowLine)
        f_deleteLabel(asiaHighLabel)
        f_deleteLabel(asiaLowLabel)

        asiaHighLine := isVisibleBar ? f_newHLLine(time, asiaHigh, asiaLineCol) : na
        asiaLowLine  := isVisibleBar ? f_newHLLine(time, asiaLow, asiaLineCol) : na
        asiaHighGlowLine := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, asiaHigh, asiaLineCol) : na
        asiaLowGlowLine  := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, asiaLow, asiaLineCol) : na

        if isVisibleBar and effectiveShowHLLabels
            asiaHighLabel := f_newHLLabel(time, asiaHigh, "Asia HIGH", asiaLineCol)
            asiaLowLabel  := f_newHLLabel(time, asiaLow, "Asia LOW", asiaLineCol)
    else if inAsia
        asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
        asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow, low)

if lonPreStart
    lonPreStartTime := time
    lonPreHigh := high
    lonPreLow := low
else if inLonPre
    lonPreHigh := na(lonPreHigh) ? high : math.max(lonPreHigh, high)
    lonPreLow := na(lonPreLow) ? low : math.min(lonPreLow, low)

if showLondonHL
    if lonPreStart
        londonLevelStartTime := time
        londonHigh := high
        londonLow  := low

        f_deleteLine(londonHighLine)
        f_deleteLine(londonLowLine)
        f_deleteLine(londonHighGlowLine)
        f_deleteLine(londonLowGlowLine)
        f_deleteLabel(londonHighLabel)
        f_deleteLabel(londonLowLabel)

        londonHighLine := isVisibleBar ? f_newHLLine(time, londonHigh, londonLineCol) : na
        londonLowLine  := isVisibleBar ? f_newHLLine(time, londonLow, londonLineCol) : na
        londonHighGlowLine := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, londonHigh, londonLineCol) : na
        londonLowGlowLine  := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, londonLow, londonLineCol) : na

        if isVisibleBar and effectiveShowHLLabels
            londonHighLabel := f_newHLLabel(time, londonHigh, "London HIGH", londonLineCol)
            londonLowLabel  := f_newHLLabel(time, londonLow, "London LOW", londonLineCol)
    else if inLonPre
        londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
        if na(londonLow) or low < londonLow
            londonLow := low
    else if londonStart
        londonLevelStartTime := na(londonLevelStartTime) ? time : londonLevelStartTime
        londonStartTime := time
        londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
        if na(londonLow) or low < londonLow
            londonLow := low

        if na(londonHighLine)
            londonHighLine := isVisibleBar ? f_newHLLine(londonLevelStartTime, londonHigh, londonLineCol) : na
        if na(londonLowLine)
            londonLowLine := isVisibleBar ? f_newHLLine(londonLevelStartTime, londonLow, londonLineCol) : na
        if na(londonHighGlowLine)
            londonHighGlowLine := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(londonLevelStartTime, londonHigh, londonLineCol) : na
        if na(londonLowGlowLine)
            londonLowGlowLine := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(londonLevelStartTime, londonLow, londonLineCol) : na

        if isVisibleBar and effectiveShowHLLabels
            if na(londonHighLabel)
                londonHighLabel := f_newHLLabel(londonLevelStartTime, londonHigh, "London HIGH", londonLineCol)
            if na(londonLowLabel)
                londonLowLabel := f_newHLLabel(londonLevelStartTime, londonLow, "London LOW", londonLineCol)
    else if inLondon
        londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
        if na(londonLow) or low < londonLow
            londonLow := low

if nyPreStart
    nyPreStartTime := time
    nyPreHigh := high
    nyPreLow := low
else if inNYPre
    nyPreHigh := na(nyPreHigh) ? high : math.max(nyPreHigh, high)
    nyPreLow := na(nyPreLow) ? low : math.min(nyPreLow, low)

if showNYHL
    if nyStart
        nyStartTime := time
        nyHigh := high
        nyLow  := low

        f_deleteLine(nyHighLine)
        f_deleteLine(nyLowLine)
        f_deleteLine(nyHighGlowLine)
        f_deleteLine(nyLowGlowLine)
        f_deleteLabel(nyHighLabel)
        f_deleteLabel(nyLowLabel)

        nyHighLine := isVisibleBar ? f_newHLLine(time, nyHigh, nyLineCol) : na
        nyLowLine  := isVisibleBar ? f_newHLLine(time, nyLow, nyLineCol) : na
        nyHighGlowLine := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, nyHigh, nyLineCol) : na
        nyLowGlowLine  := isVisibleBar and effectiveShowLevelGlow ? f_newHLGlowLine(time, nyLow, nyLineCol) : na

        if isVisibleBar and effectiveShowHLLabels
            nyHighLabel := f_newHLLabel(time, nyHigh, "New York HIGH", nyLineCol)
            nyLowLabel  := f_newHLLabel(time, nyLow, "New York LOW", nyLineCol)
    else if inNY
        nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
        nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)

//==================================================
// UPDATE LEVELS - ALWAYS KEEP UNTIL DAY END
//==================================================
if showAsiaHL
    if not na(asiaHigh)
        f_updateHL(asiaHighLine, asiaHighGlowLine, asiaHighLabel, asiaHigh, "Asia HIGH")
    if not na(asiaLow)
        f_updateHL(asiaLowLine, asiaLowGlowLine, asiaLowLabel, asiaLow, "Asia LOW")

if showLondonHL
    if not na(londonHigh)
        f_updateHL(londonHighLine, londonHighGlowLine, londonHighLabel, londonHigh, "London HIGH")
    if not na(londonLow)
        f_updateHL(londonLowLine, londonLowGlowLine, londonLowLabel, londonLow, "London LOW")

if showNYHL
    if not na(nyHigh)
        f_updateHL(nyHighLine, nyHighGlowLine, nyHighLabel, nyHigh, "New York HIGH")
    if not na(nyLow)
        f_updateHL(nyLowLine, nyLowGlowLine, nyLowLabel, nyLow, "New York LOW")

// Session status table: mark a level as "taken" only after its own session is no longer building it.
asiaLevelClosed = not inAsia
londonLevelClosed = not inLonPre and not inLondon
nyLevelClosed = not inNY
if asiaLevelClosed and not asiaHighTaken and not na(asiaHigh) and high >= asiaHigh
    asiaHighTaken := true
    asiaHighTakenTime := time
if asiaLevelClosed and not asiaLowTaken and not na(asiaLow) and low <= asiaLow
    asiaLowTaken := true
    asiaLowTakenTime := time
if londonLevelClosed and not londonHighTaken and not na(londonHigh) and high >= londonHigh
    londonHighTaken := true
    londonHighTakenTime := time
if londonLevelClosed and not londonLowTaken and not na(londonLow) and low <= londonLow
    londonLowTaken := true
    londonLowTakenTime := time
if nyLevelClosed and not nyHighTaken and not na(nyHigh) and high >= nyHigh
    nyHighTaken := true
    nyHighTakenTime := time
if nyLevelClosed and not nyLowTaken and not na(nyLow) and low <= nyLow
    nyLowTaken := true
    nyLowTakenTime := time

// London labels self-heal if they were not created on the
// exact start bar because of visibility/pruning timing.
if showLondonHL and effectiveShowHLLabels and not na(londonLevelStartTime)
    if na(londonHighLabel) and not na(londonHigh)
        londonHighLabel := f_newHLLabel(londonLevelStartTime, londonHigh, "London HIGH", londonLineCol)
    if na(londonLowLabel) and not na(londonLow)
        londonLowLabel := f_newHLLabel(londonLevelStartTime, londonLow, "London LOW", londonLineCol)

if effectiveShowSessionLabels and not na(londonStartTime)
    if na(londonTopSessionLabel) and not na(londonHigh)
        londonTopSessionLabel := f_newTopSessionLabel(londonStartTime, "London", vertLondonCol)
    if na(londonBottomSessionLabel) and not na(londonLow)
        londonBottomSessionLabel := f_newBottomSessionLabel(londonStartTime, "London", vertLondonCol)

if effectiveShowSessionLabels and not na(lonPreStartTime)
    if na(lonPreTopSessionLabel) and not na(asiaHigh)
        lonPreTopSessionLabel := f_newTopSessionLabel(lonPreStartTime, "London Pre-Open", vertLondonPreCol)
    if na(lonPreBottomSessionLabel) and not na(asiaLow)
        lonPreBottomSessionLabel := f_newBottomSessionLabel(lonPreStartTime, "London Pre-Open", vertLondonPreCol)

if showNYHL and effectiveShowHLLabels and not na(nyStartTime)
    if na(nyHighLabel) and not na(nyHigh)
        nyHighLabel := f_newHLLabel(nyStartTime, nyHigh, "New York HIGH", nyLineCol)
    if na(nyLowLabel) and not na(nyLow)
        nyLowLabel := f_newHLLabel(nyStartTime, nyLow, "New York LOW", nyLineCol)

if effectiveShowSessionLabels and not na(nyStartTime)
    if na(nyTopSessionLabel) and not na(nyHigh)
        nyTopSessionLabel := f_newTopSessionLabel(nyStartTime, "New York", vertNYCol)
    if na(nyBottomSessionLabel) and not na(nyLow)
        nyBottomSessionLabel := f_newBottomSessionLabel(nyStartTime, "New York", vertNYCol)

if effectiveShowSessionLabels
    if asiaStart
        f_deleteLabel(asiaTopSessionLabel)
        f_deleteLabel(asiaBottomSessionLabel)
        asiaTopSessionLabel := isVisibleBar ? f_newTopSessionLabel(time, "Asia", vertAsiaCol) : na
        asiaBottomSessionLabel := isVisibleBar ? f_newBottomSessionLabel(time, "Asia", vertAsiaCol) : na

    if lonPreStart
        f_deleteLabel(lonPreTopSessionLabel)
        f_deleteLabel(lonPreBottomSessionLabel)
        lonPreTopSessionLabel := isVisibleBar ? f_newTopSessionLabel(time, "London Pre-Open", vertLondonPreCol) : na
        lonPreBottomSessionLabel := isVisibleBar ? f_newBottomSessionLabel(time, "London Pre-Open", vertLondonPreCol) : na

    if londonStart
        f_deleteLabel(londonTopSessionLabel)
        f_deleteLabel(londonBottomSessionLabel)
        londonTopSessionLabel := isVisibleBar ? f_newTopSessionLabel(time, "London", vertLondonCol) : na
        londonBottomSessionLabel := isVisibleBar ? f_newBottomSessionLabel(time, "London", vertLondonCol) : na

    if nyPreStart
        f_deleteLabel(nyPreTopSessionLabel)
        f_deleteLabel(nyPreBottomSessionLabel)
        nyPreTopSessionLabel := isVisibleBar ? f_newTopSessionLabel(time, "NY Pre-Open", vertNYPreCol) : na
        nyPreBottomSessionLabel := isVisibleBar ? f_newBottomSessionLabel(time, "NY Pre-Open", vertNYPreCol) : na

    if nyStart
        f_deleteLabel(nyTopSessionLabel)
        f_deleteLabel(nyBottomSessionLabel)
        nyTopSessionLabel := isVisibleBar ? f_newTopSessionLabel(time, "New York", vertNYCol) : na
        nyBottomSessionLabel := isVisibleBar ? f_newBottomSessionLabel(time, "New York", vertNYCol) : na

if effectiveShowHLLabels
    if not na(asiaHighLabel) and not na(asiaHigh)
        label.set_x(asiaHighLabel, time)
        label.set_y(asiaHighLabel, asiaHigh)
    if not na(londonHighLabel) and not na(londonHigh)
        label.set_x(londonHighLabel, time)
        label.set_y(londonHighLabel, londonHigh)
        label.set_textcolor(londonHighLabel, color.white)
    if not na(nyHighLabel) and not na(nyHigh)
        label.set_x(nyHighLabel, time)
        label.set_y(nyHighLabel, nyHigh)
        label.set_textcolor(nyHighLabel, color.white)

    if not na(asiaLowLabel) and not na(asiaLow)
        label.set_x(asiaLowLabel, time)
        label.set_y(asiaLowLabel, asiaLow)
    if not na(londonLowLabel) and not na(londonLow)
        label.set_x(londonLowLabel, time)
        label.set_y(londonLowLabel, londonLow)
        label.set_textcolor(londonLowLabel, color.white)
    if not na(nyLowLabel) and not na(nyLow)
        label.set_x(nyLowLabel, time)
        label.set_y(nyLowLabel, nyLow)
        label.set_textcolor(nyLowLabel, color.white)

if effectiveShowSessionLabels
    if not na(asiaTopSessionLabel) and not na(asiaHigh)
        label.set_x(asiaTopSessionLabel, asiaStartTime)
        label.set_y(asiaTopSessionLabel, f_topSessionY(asiaHigh, londonHigh, nyHigh, na))
    if not na(lonPreTopSessionLabel) and not na(asiaHigh)
        label.set_x(lonPreTopSessionLabel, lonPreStartTime)
        label.set_y(lonPreTopSessionLabel, f_topSessionY(asiaHigh, londonHigh, nyHigh, na))
    if not na(londonTopSessionLabel) and not na(londonHigh)
        label.set_x(londonTopSessionLabel, londonStartTime)
        label.set_y(londonTopSessionLabel, londonHigh + ta.atr(14) * 0.70)
    if not na(nyPreTopSessionLabel) and not na(londonHigh)
        label.set_x(nyPreTopSessionLabel, nyPreStartTime)
        label.set_y(nyPreTopSessionLabel, f_topSessionY(londonHigh, asiaHigh, nyHigh, na))
    if not na(nyTopSessionLabel) and not na(nyHigh)
        label.set_x(nyTopSessionLabel, nyStartTime)
        label.set_y(nyTopSessionLabel, f_topSessionY(nyHigh, asiaHigh, londonHigh, na))

    if not na(asiaBottomSessionLabel) and not na(asiaLow)
        label.set_x(asiaBottomSessionLabel, asiaStartTime)
        label.set_y(asiaBottomSessionLabel, f_bottomSessionY(asiaLow, londonLow, nyLow, na))
    if not na(lonPreBottomSessionLabel) and not na(asiaLow)
        label.set_x(lonPreBottomSessionLabel, lonPreStartTime)
        label.set_y(lonPreBottomSessionLabel, f_bottomSessionY(asiaLow, londonLow, nyLow, na))
    if not na(londonBottomSessionLabel) and not na(londonLow)
        label.set_x(londonBottomSessionLabel, londonStartTime)
        label.set_y(londonBottomSessionLabel, londonLow - ta.atr(14) * 0.70)
    if not na(nyPreBottomSessionLabel) and not na(londonLow)
        label.set_x(nyPreBottomSessionLabel, nyPreStartTime)
        label.set_y(nyPreBottomSessionLabel, f_bottomSessionY(londonLow, asiaLow, nyLow, na))
    if not na(nyBottomSessionLabel) and not na(nyLow)
        label.set_x(nyBottomSessionLabel, nyStartTime)
        label.set_y(nyBottomSessionLabel, f_bottomSessionY(nyLow, asiaLow, londonLow, na))

//==================================================
// SWEEP DETECTION
//==================================================
// Pre-London sweeps Asia only
preLonBear = showPreSweeps and inLonPre and (f_strictBearSweep(asiaHigh) or f_reclaimBearSweep(asiaHigh))
preLonBull = showPreSweeps and inLonPre and (f_strictBullSweep(asiaLow)  or f_reclaimBullSweep(asiaLow))

// London sweeps Asia only
lonAsiaBear = showLondonSweeps and inLondon and (f_strictBearSweep(asiaHigh) or f_reclaimBearSweep(asiaHigh))
lonAsiaBull = showLondonSweeps and inLondon and (f_strictBullSweep(asiaLow)  or f_reclaimBullSweep(asiaLow))

// NY Pre-Open sweeps London only
preNYBear = showPreSweeps and inNYPre and (f_strictBearSweep(londonHigh) or f_reclaimBearSweep(londonHigh))
preNYBull = showPreSweeps and inNYPre and (f_strictBullSweep(londonLow)  or f_reclaimBullSweep(londonLow))

// NY sweeps London and Asia separately
nyLondonBear = showNYSweeps and inNY and (f_strictBearSweep(londonHigh) or f_reclaimBearSweep(londonHigh))
nyLondonBull = showNYSweeps and inNY and (f_strictBullSweep(londonLow)  or f_reclaimBullSweep(londonLow))

nyAsiaBear = showNYSweeps and inNY and (f_strictBearSweep(asiaHigh) or f_reclaimBearSweep(asiaHigh))
nyAsiaBull = showNYSweeps and inNY and (f_strictBullSweep(asiaLow)  or f_reclaimBullSweep(asiaLow))

//==================================================
// OPTIONAL CLUTTER REDUCTION
//==================================================
plotPreLonBear = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? preLonBear and not (preLonBull or preNYBear or preNYBull or lonAsiaBear or lonAsiaBull or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : preLonBear)
plotPreLonBull = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? preLonBull and not (preLonBear or preNYBear or preNYBull or lonAsiaBear or lonAsiaBull or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : preLonBull)
plotPreNYBear  = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? preNYBear and not (preLonBear or preLonBull or preNYBull or lonAsiaBear or lonAsiaBull or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : preNYBear)
plotPreNYBull  = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? preNYBull and not (preLonBear or preLonBull or preNYBear or lonAsiaBear or lonAsiaBull or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : preNYBull)

plotLonAsiaBear = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? lonAsiaBear and not (lonAsiaBull or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : lonAsiaBear)
plotLonAsiaBull = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? lonAsiaBull and not (lonAsiaBear or nyLondonBear or nyLondonBull or nyAsiaBear or nyAsiaBull) : lonAsiaBull)

plotNYLondonBear = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? nyLondonBear and not (nyLondonBull or nyAsiaBear or nyAsiaBull) : nyLondonBear)
plotNYLondonBull = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? nyLondonBull and not (nyLondonBear or nyAsiaBear or nyAsiaBull) : nyLondonBull)
plotNYAsiaBear   = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? nyAsiaBear and not (nyLondonBear or nyLondonBull or nyAsiaBull) : nyAsiaBear)
plotNYAsiaBull   = isVisibleBar and effectiveShowSweeps and (oneMarkerPerBar ? nyAsiaBull and not (nyLondonBear or nyLondonBull or nyAsiaBear) : nyAsiaBull)

// Share the top-right table so branding and session status cannot overlap.
brandInDashboard = sessionStatusPosition == "Top Right"
var table brandTable = na
var table sessionStatusTable = table.new(f_sessionStatusPosition(), 4, 15, border_width=0)
if barstate.isfirst
    if showBrandLabel and brandInDashboard
        table.merge_cells(sessionStatusTable, 0, 0, 3, 0)
    if showBrandLabel and not brandInDashboard
        brandTable := table.new(position.top_right, 1, 1, border_width=0)

if barstate.islast
    table.clear(sessionStatusTable, 0, 0, 3, 14)
    if showBrandLabel
        if brandInDashboard
            table.cell(sessionStatusTable, 0, 0, "Trading Sessions Pro [MR. MAKERICH]", text_color=brandColor, bgcolor=color.new(color.black, 100), text_size=size.tiny, text_halign=text.align_right)
        else
            table.cell(brandTable, 0, 0, "Trading Sessions Pro [MR. MAKERICH]", text_color=brandColor, bgcolor=color.new(color.black, 100), text_size=size.tiny, text_halign=text.align_right)
    if showSessionStatusTable
        statusRow = sessionStatusOffsetRows + (showBrandLabel and brandInDashboard ? 1 : 0)
        headerBg = color.new(color.rgb(9, 14, 25), 0)
        rowBg = color.new(color.black, 14)
        asiaHighStatusCol = asiaHighTaken ? color.rgb(33, 209, 138) : color.rgb(245, 184, 31)
        asiaLowStatusCol = asiaLowTaken ? color.rgb(33, 209, 138) : color.rgb(245, 184, 31)
        londonHighStatusCol = londonHighTaken ? color.rgb(33, 209, 138) : color.rgb(245, 184, 31)
        londonLowStatusCol = londonLowTaken ? color.rgb(33, 209, 138) : color.rgb(245, 184, 31)
        nyFinalCol = color.rgb(142, 150, 163)
        nyHighStatusCol = na(nyHigh) ? nyFinalCol : color.rgb(245, 184, 31)
        nyLowStatusCol = na(nyLow) ? nyFinalCol : color.rgb(245, 184, 31)
        asiaHighStatusText = na(asiaHigh) ? "-" : inAsia ? "ACTIVE" : asiaHighTaken ? "YES " + f_timeHhMm(asiaHighTakenTime) : "OPEN"
        asiaLowStatusText = na(asiaLow) ? "-" : inAsia ? "ACTIVE" : asiaLowTaken ? "YES " + f_timeHhMm(asiaLowTakenTime) : "OPEN"
        londonHighStatusText = na(londonHigh) ? "-" : (inLonPre or inLondon) ? "ACTIVE" : londonHighTaken ? "YES " + f_timeHhMm(londonHighTakenTime) : "OPEN"
        londonLowStatusText = na(londonLow) ? "-" : (inLonPre or inLondon) ? "ACTIVE" : londonLowTaken ? "YES " + f_timeHhMm(londonLowTakenTime) : "OPEN"
        nyHighStatusText = na(nyHigh) ? "-" : "ACTIVE"
        nyLowStatusText = na(nyLow) ? "-" : "ACTIVE"
        table.cell(sessionStatusTable, 0, statusRow, "LEVEL", text_color=color.white, bgcolor=headerBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow, "PRICE", text_color=color.white, bgcolor=headerBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow, "DIST", text_color=color.white, bgcolor=headerBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow, "TAKEN", text_color=color.white, bgcolor=headerBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 1, "Asia High", text_color=asiaLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 1, na(asiaHigh) ? "-" : f_fmt(asiaHigh), text_color=asiaLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 1, na(asiaHigh) ? "-" : f_points(asiaHigh - close), text_color=na(asiaHigh) ? color.white : asiaHigh - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 1, asiaHighStatusText, text_color=asiaHighStatusCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 2, "Asia Low", text_color=asiaLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 2, na(asiaLow) ? "-" : f_fmt(asiaLow), text_color=asiaLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 2, na(asiaLow) ? "-" : f_points(asiaLow - close), text_color=na(asiaLow) ? color.white : asiaLow - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 2, asiaLowStatusText, text_color=asiaLowStatusCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 3, "London High", text_color=londonLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 3, na(londonHigh) ? "-" : f_fmt(londonHigh), text_color=londonLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 3, na(londonHigh) ? "-" : f_points(londonHigh - close), text_color=na(londonHigh) ? color.white : londonHigh - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 3, londonHighStatusText, text_color=londonHighStatusCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 4, "London Low", text_color=londonLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 4, na(londonLow) ? "-" : f_fmt(londonLow), text_color=londonLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 4, na(londonLow) ? "-" : f_points(londonLow - close), text_color=na(londonLow) ? color.white : londonLow - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 4, londonLowStatusText, text_color=londonLowStatusCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 5, "New York High", text_color=nyLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 5, na(nyHigh) ? "-" : f_fmt(nyHigh), text_color=nyLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 5, na(nyHigh) ? "-" : f_points(nyHigh - close), text_color=na(nyHigh) ? color.white : nyHigh - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 5, nyHighStatusText, text_color=nyHighStatusCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 0, statusRow + 6, "New York Low", text_color=nyLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 1, statusRow + 6, na(nyLow) ? "-" : f_fmt(nyLow), text_color=nyLineCol, bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 2, statusRow + 6, na(nyLow) ? "-" : f_points(nyLow - close), text_color=na(nyLow) ? color.white : nyLow - close >= 0 ? color.rgb(33, 209, 138) : color.rgb(244, 87, 95), bgcolor=rowBg, text_size=size.small)
        table.cell(sessionStatusTable, 3, statusRow + 6, nyLowStatusText, text_color=nyLowStatusCol, bgcolor=rowBg, text_size=size.small)
        if showCurrentSession
            string currentSessionText = ""
            currentSessionText := inAsia ? "Asia" : currentSessionText
            currentSessionText := inLonPre ? currentSessionText + (currentSessionText == "" ? "" : " / ") + "London Pre-Open" : currentSessionText
            currentSessionText := inLondon ? currentSessionText + (currentSessionText == "" ? "" : " / ") + "London" : currentSessionText
            currentSessionText := inNYPre ? currentSessionText + (currentSessionText == "" ? "" : " / ") + "NY Pre-Open" : currentSessionText
            currentSessionText := inNY ? currentSessionText + (currentSessionText == "" ? "" : " / ") + "New York" : currentSessionText
            currentSessionText := currentSessionText == "" ? "No active session" : currentSessionText
            table.cell(sessionStatusTable, 0, statusRow + 7, "Session: " + currentSessionText, text_color=color.white, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
            // Reapply the full-width footer after clearing and rebuilding the table.
            table.merge_cells(sessionStatusTable, 0, statusRow + 7, 3, statusRow + 7)
            table.cell_set_text_halign(sessionStatusTable, 0, statusRow + 7, text.align_center)




if barstate.islast
    htfHighCol = color.rgb(245, 184, 31)
    htfLowCol = color.rgb(244, 87, 95)
    htfXRight = bar_index + htfLevelRightBars
    htfXLeft = bar_index - htfNamedLookbackBars
    showDailyHigh = showDailyHighLow and not na(currDayHighHtf) and f_htfPriceVisible(currDayHighHtf)
    showDailyLow = showDailyHighLow and not na(currDayLowHtf) and f_htfPriceVisible(currDayLowHtf)
    showPdh = showPdhPdl and not na(prevDayHighHtf) and f_htfPriceVisible(prevDayHighHtf)
    showPdl = showPdhPdl and not na(prevDayLowHtf) and f_htfPriceVisible(prevDayLowHtf)
    showCwh = showCwhCwl and not na(currWeekHighHtf) and f_htfPriceVisible(currWeekHighHtf)
    showCwl = showCwhCwl and not na(currWeekLowHtf) and f_htfPriceVisible(currWeekLowHtf)
    showPwh = showPwhPwl and not na(prevWeekHighHtf) and f_htfPriceVisible(prevWeekHighHtf) and (na(currWeekHighHtf) or math.abs(prevWeekHighHtf - currWeekHighHtf) >= syminfo.mintick)
    showPwl = showPwhPwl and not na(prevWeekLowHtf) and f_htfPriceVisible(prevWeekLowHtf) and (na(currWeekLowHtf) or math.abs(prevWeekLowHtf - currWeekLowHtf) >= syminfo.mintick)

    htfMergeTol = syminfo.mintick * htfLabelMergeTicks

    mergeDailyCwhHigh = htfLabelMergeTicks > 0 and showDailyHigh and showCwh and f_priceNear(currDayHighHtf, currWeekHighHtf, htfMergeTol)
    mergeDailyPwhHigh = htfLabelMergeTicks > 0 and showDailyHigh and showPwh and f_priceNear(currDayHighHtf, prevWeekHighHtf, htfMergeTol)
    mergeDailyPdhHigh = htfLabelMergeTicks > 0 and showDailyHigh and showPdh and f_priceNear(currDayHighHtf, prevDayHighHtf, htfMergeTol)
    mergeCwhPwhHigh = htfLabelMergeTicks > 0 and not mergeDailyCwhHigh and not mergeDailyPwhHigh and showCwh and showPwh and f_priceNear(currWeekHighHtf, prevWeekHighHtf, htfMergeTol)
    mergeCwhPdhHigh = htfLabelMergeTicks > 0 and not mergeDailyCwhHigh and not mergeDailyPdhHigh and showCwh and showPdh and f_priceNear(currWeekHighHtf, prevDayHighHtf, htfMergeTol)
    mergePdhPwhHigh = htfLabelMergeTicks > 0 and not mergeDailyPdhHigh and not mergeDailyPwhHigh and not mergeCwhPdhHigh and not mergeCwhPwhHigh and showPdh and showPwh and f_priceNear(prevDayHighHtf, prevWeekHighHtf, htfMergeTol)

    mergeDailyCwlLow = htfLabelMergeTicks > 0 and showDailyLow and showCwl and f_priceNear(currDayLowHtf, currWeekLowHtf, htfMergeTol)
    mergeDailyPwlLow = htfLabelMergeTicks > 0 and showDailyLow and showPwl and f_priceNear(currDayLowHtf, prevWeekLowHtf, htfMergeTol)
    mergeDailyPdlLow = htfLabelMergeTicks > 0 and showDailyLow and showPdl and f_priceNear(currDayLowHtf, prevDayLowHtf, htfMergeTol)
    mergeCwlPwlLow = htfLabelMergeTicks > 0 and not mergeDailyCwlLow and not mergeDailyPwlLow and showCwl and showPwl and f_priceNear(currWeekLowHtf, prevWeekLowHtf, htfMergeTol)
    mergeCwlPdlLow = htfLabelMergeTicks > 0 and not mergeDailyCwlLow and not mergeDailyPdlLow and showCwl and showPdl and f_priceNear(currWeekLowHtf, prevDayLowHtf, htfMergeTol)
    mergePdlPwlLow = htfLabelMergeTicks > 0 and not mergeDailyPdlLow and not mergeDailyPwlLow and not mergeCwlPdlLow and not mergeCwlPwlLow and showPdl and showPwl and f_priceNear(prevDayLowHtf, prevWeekLowHtf, htfMergeTol)

    dailyHighText = f_joinLabelText(f_joinLabelText(f_joinLabelText("Daily HIGH", mergeDailyCwhHigh, "CWH"), mergeDailyPwhHigh, "PWH"), mergeDailyPdhHigh, "PDH")
    dailyLowText = f_joinLabelText(f_joinLabelText(f_joinLabelText("Daily LOW", mergeDailyCwlLow, "CWL"), mergeDailyPwlLow, "PWL"), mergeDailyPdlLow, "PDL")
    cwhText = f_joinLabelText(f_joinLabelText("CWH", mergeCwhPwhHigh, "PWH"), mergeCwhPdhHigh, "PDH")
    cwlText = f_joinLabelText(f_joinLabelText("CWL", mergeCwlPwlLow, "PWL"), mergeCwlPdlLow, "PDL")
    pdhText = f_joinLabelText("PDH", mergePdhPwhHigh, "PWH")
    pdlText = f_joinLabelText("PDL", mergePdlPwlLow, "PWL")

    drawCwh = showCwh and not mergeDailyCwhHigh
    drawCwl = showCwl and not mergeDailyCwlLow
    drawPdh = showPdh and not mergeDailyPdhHigh and not mergeCwhPdhHigh
    drawPdl = showPdl and not mergeDailyPdlLow and not mergeCwlPdlLow
    drawPwh = showPwh and not mergeDailyPwhHigh and not mergeCwhPwhHigh and not mergePdhPwhHigh
    drawPwl = showPwl and not mergeDailyPwlLow and not mergeCwlPwlLow and not mergePdlPwlLow

    [dailyHighHtfLineNext, dailyHighHtfLabelNext] = f_drawNamedHtfLevel(dailyHighHtfLine, dailyHighHtfLabel, showDailyHigh, currDayHighHtf, dailyHighText, htfHighCol, htfXLeft, htfXRight, 18)
    dailyHighHtfLine := dailyHighHtfLineNext
    dailyHighHtfLabel := dailyHighHtfLabelNext
    [dailyLowHtfLineNext, dailyLowHtfLabelNext] = f_drawNamedHtfLevel(dailyLowHtfLine, dailyLowHtfLabel, showDailyLow, currDayLowHtf, dailyLowText, htfLowCol, htfXLeft, htfXRight, 18)
    dailyLowHtfLine := dailyLowHtfLineNext
    dailyLowHtfLabel := dailyLowHtfLabelNext
    [pdhHtfLineNext, pdhHtfLabelNext] = f_drawFullHtfLevel(pdhHtfLine, pdhHtfLabel, drawPdh, prevDayHighHtf, pdhText, htfHighCol, htfXRight, 0)
    pdhHtfLine := pdhHtfLineNext
    pdhHtfLabel := pdhHtfLabelNext
    [pdlHtfLineNext, pdlHtfLabelNext] = f_drawFullHtfLevel(pdlHtfLine, pdlHtfLabel, drawPdl, prevDayLowHtf, pdlText, htfLowCol, htfXRight, 0)
    pdlHtfLine := pdlHtfLineNext
    pdlHtfLabel := pdlHtfLabelNext
    [cwhHtfLineNext, cwhHtfLabelNext] = f_drawNamedHtfLevel(cwhHtfLine, cwhHtfLabel, drawCwh, currWeekHighHtf, cwhText, htfHighCol, htfXLeft, htfXRight, 18)
    cwhHtfLine := cwhHtfLineNext
    cwhHtfLabel := cwhHtfLabelNext
    [cwlHtfLineNext, cwlHtfLabelNext] = f_drawNamedHtfLevel(cwlHtfLine, cwlHtfLabel, drawCwl, currWeekLowHtf, cwlText, htfLowCol, htfXLeft, htfXRight, 18)
    cwlHtfLine := cwlHtfLineNext
    cwlHtfLabel := cwlHtfLabelNext
    [pwhHtfLineNext, pwhHtfLabelNext] = f_drawFullHtfLevel(pwhHtfLine, pwhHtfLabel, drawPwh, prevWeekHighHtf, "PWH", htfHighCol, htfXRight, 18)
    pwhHtfLine := pwhHtfLineNext
    pwhHtfLabel := pwhHtfLabelNext
    [pwlHtfLineNext, pwlHtfLabelNext] = f_drawFullHtfLevel(pwlHtfLine, pwlHtfLabel, drawPwl, prevWeekLowHtf, "PWL", htfLowCol, htfXRight, 18)
    pwlHtfLine := pwlHtfLineNext
    pwlHtfLabel := pwlHtfLabelNext

//==================================================
// PLOTS
//==================================================

plotshape(plotPreLonBear, title="Pre-London sweeps Asia High", style=shape.triangledown, location=location.abovebar, color=preSweepBearCol, size=size.tiny, text="pre")
plotshape(plotPreLonBull, title="Pre-London sweeps Asia Low",  style=shape.triangleup,   location=location.belowbar, color=preSweepBullCol, size=size.tiny, text="pre")

plotshape(plotPreNYBear, title="NY Pre-Open sweeps London High", style=shape.triangledown, location=location.abovebar, color=preSweepBearCol, size=size.tiny, text="pre")
plotshape(plotPreNYBull, title="NY Pre-Open sweeps London Low",  style=shape.triangleup,   location=location.belowbar, color=preSweepBullCol, size=size.tiny, text="pre")

plotshape(plotLonAsiaBear, title="London sweeps Asia High", style=shape.triangledown, location=location.abovebar, color=lonAsiaBearCol, size=size.tiny, text="L/A")
plotshape(plotLonAsiaBull, title="London sweeps Asia Low",  style=shape.triangleup,   location=location.belowbar, color=lonAsiaBullCol, size=size.tiny, text="L/A")

plotshape(plotNYLondonBear, title="NY sweeps London High", style=shape.triangledown, location=location.abovebar, color=nyLondonBearCol, size=size.tiny, text="NY/L")
plotshape(plotNYLondonBull, title="NY sweeps London Low",  style=shape.triangleup,   location=location.belowbar, color=nyLondonBullCol, size=size.tiny, text="NY/L")

plotshape(plotNYAsiaBear, title="NY sweeps Asia High", style=shape.triangledown, location=location.abovebar, color=nyAsiaBearCol, size=size.tiny, text="NY/A")
plotshape(plotNYAsiaBull, title="NY sweeps Asia Low",  style=shape.triangleup,   location=location.belowbar, color=nyAsiaBullCol, size=size.tiny, text="NY/A")

//==================================================
// ALERTS
//==================================================
alertcondition(preLonBear, title="Pre-London Sweeps Asia High", message="Pre-London swept Asia High")
alertcondition(preLonBull, title="Pre-London Sweeps Asia Low",  message="Pre-London swept Asia Low")

alertcondition(lonAsiaBear, title="London Sweeps Asia High", message="London swept Asia High")
alertcondition(lonAsiaBull, title="London Sweeps Asia Low",  message="London swept Asia Low")

alertcondition(preNYBear, title="NY Pre-Open Sweeps London High", message="NY Pre-Open swept London High")
alertcondition(preNYBull, title="NY Pre-Open Sweeps London Low",  message="NY Pre-Open swept London Low")

alertcondition(nyLondonBear, title="New York Sweeps London High", message="New York swept London High")
alertcondition(nyLondonBull, title="New York Sweeps London Low",  message="New York swept London Low")

alertcondition(nyAsiaBear, title="New York Sweeps Asia High", message="New York swept Asia High")
alertcondition(nyAsiaBull, title="New York Sweeps Asia Low",  message="New York swept Asia Low")
````
