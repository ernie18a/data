# Aurora VWAP Suite V2

- url: https://www.tradingview.com/script/Qlb7YXsS-Aurora-VWAP-Suite-V2/
- type: indicator
- pine_id: PUB;8004fa2c754e4324a36ba08ecdfb242a
- version: 1.0

## Description

[b]█ Overview[/b]

AVWAP Suite is a multi-session, anchored VWAP framework that brings daily context, market-session references, confirmed extreme anchors, and an adaptive reference engine into one chart workspace.

The indicator tracks Asia, London, New York, and COMEX independently, compares their current relevance, and highlights a confirmed session winner. Around this structure, optional deviation bands, a volume/ADX envelope, VWAP clusters, opening-name badges, and a live dashboard provide additional context.

The result is a connected reference map for reading [b]where price is trading, which session reference is closest to current conditions, and how shorter-term activity relates to broader volume-weighted levels.[/b]

[b]█ What Makes This Suite Different[/b]

The main focus is the relationship between [b]session timing, relative activity, and anchor horizons.[/b]

A session that opened earlier naturally has more time to accumulate volume. Selecting a winner from that total alone can repeatedly favor the longer window. AVWAP Suite therefore offers a relevance model that combines normalized activity with VWAP proximity, together with closed-bar confirmation and a switching margin.

The same framework also keeps the chart organized across daily resets. Old session curves, winner state, opening markers, and inactive labels are cleared, while weekly/monthly VWAPs and longer-horizon anchors retain their intended calculations.

[b]█ How It Works[/b]

[b]⚪ Daily, Weekly & Monthly VWAP[/b]

The daily VWAP starts at the selected reset time in the selected timezone. Defaults are [b]00:00 — Berlin[/b], with alternative timezones, common reset times, and a custom HH:MM option available.

Weekly and monthly references provide broader context. Their boundaries follow the selected VWAP-day start date: local Monday for the week and the local calendar month for the month.

The basic volume-weighted relationship is:

[pine]
vwap = weightedPriceSum / volumeSum
[/pine]

Here, weightedPriceSum is the accumulated price × volume and volumeSum is the accumulated volume over the relevant window.

[b]⚪ Previous-Day AVWAP[/b]

The previous-day reference continues from the start of the previous observed VWAP day and adds incoming volume during the current period.

It is a [b]live anchored calculation[/b], rather than a frozen horizontal line at yesterday’s final VWAP. At the next daily reset, it rolls forward to the new previous period. Its early-period movement can be gradual because the earlier volume still carries substantial weight.

[b]⚪ Independent Market Sessions[/b]

Each enabled market has its own VWAP calculation, active window, and winner eligibility:

• [b]Asia:[/b] 09:00–15:00, Tokyo time.
• [b]London:[/b] 08:00–16:30, London time.
• [b]New York:[/b] 09:30–16:00, New York time.
• [b]COMEX:[/b] 08:20–13:30, New York time.

New York and COMEX are separate references. Market defaults follow each market’s local clock and daylight-saving changes.

Custom session hours can use either market-local time or the timezone selected for the daily reset. Trading-day controls use [b]Weekdays[/b] or [b]Every day[/b].

Before a window opens, its session value and right-edge label are unavailable. At the close, the curve stops and its label disappears. The current-period curve remains until the next daily reset; previous-period session curves are removed.

[b]⚪ Session Winner Engine[/b]

Four selection methods are available:

• [b]Relevance:[/b] combines relative activity and price proximity.
• [b]Relative activity:[/b] compares recent volume with historical expectations.
• [b]Volume rate:[/b] compares current-period volume per observed session bar.
• [b]Accumulated volume:[/b] compares current-period session volume totals.

Only enabled, active sessions with positive volume and sufficient observations can compete.

The default relevance model uses [b]60% activity and 40% proximity[/b]:

[pine]
activityScore = 100.0 * relativeVolume / (1.0 + relativeVolume)
proximityScore = 100.0 * math.exp(-math.abs(close - sessionVWAP) / atrValue / 2.0)
relevanceScore = 0.60 * activityScore + 0.40 * proximityScore
[/pine]

relativeVolume compares recent actual volume with expected volume for the same elapsed-session slots. sessionVWAP is the candidate reference, and atrValue normalizes its distance from price.

Normal relative volume produces 50 activity points; twice normal produces approximately 66.7. Proximity rewards a reference that is closer to current price. It does not measure historical support/resistance effectiveness.

[b]⚪ Historical Activity & Warmup[/b]

The default activity window uses the latest [b]20 active-session bars[/b]. Expected volume is learned from completed windows using a [b]20-session EMA[/b], with at least five prior observations required per slot.

The current session never trains the expectation used to score itself. Initial partial sessions are excluded.

During warmup, all eligible candidates use a common volume-rate fallback. The detailed dashboard identifies the scoring state. Fallback and trained relative-volume scores use different normalization scales, so compare candidates within the current state.

[b]Important:[/b] overlapping windows receive volume from the same chart symbol. The suite selects a VWAP reference; it does not identify which exchange or participant group generated that volume. Fully overlapping activity windows can correctly produce tied readings.

[b]⚪ Confirmed Winner Switching[/b]

Each candidate needs at least five observed bars and a score of 15. Switching response controls how persistent a challenger must be:

• [b]Stable:[/b] lead greater than 12 points for five closed bars.
• [b]Balanced:[/b] lead greater than eight points for three closed bars.
• [b]Fast:[/b] lead greater than four points for two closed bars.

Broken streaks reset. Exact ties retain an eligible incumbent; an initial tie leaves selection empty.

The daily boundary clears winner and pending state immediately. Other selection changes confirm at bar close. Live scores continue updating during the open candle.

[b]⚪ Two-Day Extreme AVWAPs[/b]

Low- and high-anchored VWAPs are created from confirmed pivots near the extremes of the current and previous observed VWAP periods.

Defaults use eight confirmation bars and a maximum distance of 0.5 ATR from the relevant extreme. Replacement options are:

• More extreme only.
• Every qualifying swing.
• Keep until expiry.

The calculation includes the pivot through its confirmation bar, then adds incoming volume. It is not plotted backward as if the anchor had been known earlier. Tooltips distinguish [b]anchor time[/b] from [b]confirmation time[/b].

The dashboard describes current position around each reference using HOLDS / LOST / TEST for the low anchor and REJECTS / RECLAIM / TEST for the high anchor.

[b]⚪ Manual Anchors[/b]

Two independent timestamp anchors are available. Choose an event or candle within loaded chart history.

The containing candle is included. A time in a data gap begins on the next observed bar; an anchor before loaded history remains unavailable. Manual anchors keep their selected horizon through daily resets.

[b]⚪ Reference Engine[/b]

The reference VWAP supports four modes:

• [b]Rolling:[/b] volume-weighted moving average, default 200 bars.
• [b]Session:[/b] cumulative reference for the selected VWAP day.
• [b]Adaptive Swing:[/b] exponentially decayed statistics with ATR-adapted tracking speed.
• [b]Swing AVWAP:[/b] cumulative VWAP from the opposing rolling extreme after a confirmed direction change.

Swing ordering uses a 50-bar rolling high/low lookback. It can also change when an older extreme leaves that window.

The reference engine uses HL2. Daily, market-session, weekly/monthly, and anchor calculations default to HLC3; their source can be adjusted under Advanced tuning.

[b]⚪ Bands & Volume/ADX Envelope[/b]

Winner and selected-reference bands support [b]Sigma, ATR, or Percent[/b] distances. In percentage mode, multiplier 1 represents 1% of the reference price.

The engine envelope expands with volume activity and ADX. It smooths its width and applies that distance symmetrically around the reference:

[pine]
upperEnvelope = referenceVWAP + smoothedWidth
lowerEnvelope = referenceVWAP - smoothedWidth
[/pine]

Fixed engine bands and selected-reference bands share one additional-band family. Winner bands and the dynamic envelope remain independent.

Sigma bands describe weighted price dispersion; they are not guaranteed probability ranges.

[b]⚪ Confluence & VWAP Bias[/b]

Optional confluence highlights a cluster of at least three displayed daily/weekly/monthly, market-session, extreme-anchor, or manual references within a total width of 0.2 ATR.

It uses the full cluster range rather than chaining adjacent nearby levels into an oversized zone. The duplicate winner reference is excluded. Equal-size clusters favor the one nearer price.

VWAP Bias summarizes agreement across available daily, winner, extreme-anchor, and same-period daily-slope readings. These references can be correlated. Bias is a context reading, not a probability.

[b]█ How to Use[/b]

[b]⚪ Establish the Broader Context[/b]
Start with the daily VWAP. Add weekly/monthly or previous-day AVWAP when you want to compare the current session with a longer volume-weighted horizon.

[b]⚪ Compare Session References[/b]
Enable the relevant markets and watch how their VWAPs develop. Use the winner score and pending counter to follow confirmed changes in reference selection.

[b]⚪ Inspect Anchor Tests[/b]
Compare price with the low/high or manual AVWAPs. A test, hold, rejection, or reclaim describes interaction with that reference and should be read alongside price structure.

[b]⚪ Observe Expansion & Clustering[/b]
The envelope shows changing reference width, while confluence identifies nearby VWAP references. Band extension alone does not establish that a reversal must occur.

[b]⚪ Keep the Chart Focused[/b]
Use the layout presets and individual display controls. Compact dashboard shows the main context; Detailed exposes scores, profile status, pending selection, anchors, and engine information.

[b]█ Visuals & Settings[/b]

The default Custom theme uses [b]green #03F10D[/b] and [b]purple #5100DE[/b]. Colors identify reference families rather than automatic buy/sell direction.

All line names and opening names use [b]filled label badges[/b]. Automatic contrast selects readable text, with a custom text color and Tiny/Small/Normal sizes available. Opening badges sit above candles and stack when openings share a bar.

Settings are organized into:

• Daily reset.
• Market sessions.
• Chart display.
• Winner.
• Bands.
• Anchors.
• Labels.
• Dashboard.
• Open markers.
• Alerts.
• Advanced tuning.
• Custom line colors.

Dependent controls are disabled when their feature is off. The separate reopen hour/minute controls are replaced by marker presets: Off, Session opens, Exchange opens, Daily reset, and Session opens + reset.

[b]█ Alerts[/b]

Individual conditions cover new extreme anchors, each market becoming winner, and winner clearing.

For configurable price events, choose [b]Any alert() function call[/b] and enable the desired crosses, support/resistance tests, or band breaks.

• Support tests require the candle low inside the ATR tolerance zone and a close above it.
• Resistance tests require the candle high inside that zone and a close below it.
• Cross alerts identify close crossing the selected reference.
• Band breaks require positive band width on both compared bars.

Bar-close confirmation is the default. Reset jumps, winner changes, and unavailable prior values are excluded from price-cross events. Recreate saved alerts after changing the source or settings.

[b]█ Important Notes[/b]

• Session rendering requires standard intraday time charts of at least one minute.
• Calculations use the chart’s supplied price and volume. Volume type and quality depend on the feed.
• Chart-bar volume cannot be split at a boundary inside a candle. Use aligned timeframes when exact session/reset timing matters.
• Market presets do not load exchange holiday or early-close calendars.
• First loaded periods can be partial. Session-open markers require the opening to be observed within the first timeframe interval.
• Each current-period session/winner trace retains up to six continuous pieces. Frequent switches can remove the earliest pieces without changing current values.
• Current-bar VWAPs, scores, bands, and labels update live. Confirmed pivots and ordinary winner selection wait for bar close; the indicator makes no blanket non-repainting claim.
• The suite is an analytical overlay. It does not place orders or backtest trading profitability.

[b]█ Disclaimer[/b]

This indicator is provided for educational and informational purposes. It does not constitute financial advice or a recommendation to buy or sell any instrument. Trading involves risk, and all trading decisions and risk management remain the user’s responsibility.

## Source Code

````pine
// Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Drizzle_Algo56
//@version=6
indicator("AVWAP Suite V2", shorttitle="AVWAP", overlay=true, max_labels_count=200, max_lines_count=200, max_polylines_count=100, max_bars_back=5000)

string G_RESET = "01 · Daily reset"
string G_SESS = "02 · Market sessions"
string G_SHOW = "03 · Chart display"
string G_ENGINE = G_SHOW
string G_ZONE = G_SHOW
string G_WIN = "04 · Winner"
string G_BANDS = "05 · Bands"
string G_ANCHOR = "06 · Anchors"
string G_MANUAL = G_ANCHOR
string G_LABELS = "07 · Labels"
string G_TABLE = "08 · Dashboard"
string G_OPENS = "09 · Open markers"
string G_SIGNALS = "10 · Alerts"
string G_ADV = "11 · Advanced tuning"
string G_COLORS = "12 · Custom line colors"

string resetChoice = input.string("00:00", "Daily reset time", options=["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "08:20", "09:00", "09:30", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "Custom"], group=G_RESET, tooltip="Starts a new VWAP day in your selected timezone.")
string timezoneChoice = input.string("Berlin", "Timezone", options=["Berlin", "London", "New York", "Chicago", "Los Angeles", "Tokyo", "Shanghai", "Dubai", "Sydney", "UTC", "Exchange"], group=G_RESET)
string customReset = input.string("00:00", "Custom reset (HH:MM)", group=G_RESET, active=resetChoice == "Custom")
string dayTimezone = switch timezoneChoice
    "Berlin" => "Europe/Berlin"
    "London" => "Europe/London"
    "New York" => "America/New_York"
    "Chicago" => "America/Chicago"
    "Los Angeles" => "America/Los_Angeles"
    "Tokyo" => "Asia/Tokyo"
    "Shanghai" => "Asia/Shanghai"
    "Dubai" => "Asia/Dubai"
    "Sydney" => "Australia/Sydney"
    "Exchange" => syminfo.timezone
    => "Etc/UTC"
string resetText = resetChoice == "Custom" ? customReset : resetChoice
bool resetHasFiveCharacters = str.length(resetText) == 5
int resetHour = resetHasFiveCharacters ? int(str.tonumber(str.substring(resetText, 0, 2))) : na
int resetMinute = resetHasFiveCharacters ? int(str.tonumber(str.substring(resetText, 3, 5))) : na
bool validReset = resetHasFiveCharacters and str.substring(resetText, 2, 3) == ":" and not na(resetHour) and not na(resetMinute) and resetHour >= 0 and resetHour <= 23 and resetMinute >= 0 and resetMinute <= 59 and str.tostring(resetHour, "00") + ":" + str.tostring(resetMinute, "00") == resetText
if barstate.isfirst and not validReset
    runtime.error("Enter a reset time as HH:MM between 00:00 and 23:59.")

bool inputAsia = input.bool(false, "Asia", group=G_SESS, inline="markets1")
bool inputLondon = input.bool(true, "London", group=G_SESS, inline="markets1")
bool inputNY = input.bool(true, "New York", group=G_SESS, inline="markets2")
bool inputUS = input.bool(true, "COMEX", group=G_SESS, inline="markets2")
string sessionSchedule = input.string("Market defaults", "Session schedule", options=["Market defaults", "Custom times"], group=G_SESS, tooltip="Defaults use each market's local clock and follow daylight saving time.")
string tradingDays = input.string("Weekdays", "Trading days", options=["Weekdays", "Every day"], group=G_SESS)
string customTimeBasis = input.string("Market local time", "Custom times use", options=["Market local time", "My timezone"], group=G_SESS, active=sessionSchedule == "Custom times")
bool customSessions = sessionSchedule == "Custom times"
string customAsia = input.session("0900-1500", "Asia hours", group=G_SESS, active=customSessions and inputAsia)
string customLondon = input.session("0800-1630", "London hours", group=G_SESS, active=customSessions and inputLondon)
string customNY = input.session("0930-1600", "New York hours", group=G_SESS, active=customSessions and inputNY)
string customUS = input.session("0820-1330", "COMEX hours", group=G_SESS, active=customSessions and inputUS)
string sessionDays = tradingDays == "Every day" ? "1234567" : "23456"
bool localCustomTimes = customSessions and customTimeBasis == "My timezone"
string asiaSession = customSessions ? customAsia : "0900-1500"
string londonSession = customSessions ? customLondon : "0800-1630"
string nySession = customSessions ? customNY : "0930-1600"
string usSession = customSessions ? customUS : "0820-1330"
string asiaTimezone = localCustomTimes ? dayTimezone : "Asia/Tokyo"
string londonTimezone = localCustomTimes ? dayTimezone : "Europe/London"
string nyTimezone = localCustomTimes ? dayTimezone : "America/New_York"
string usTimezone = localCustomTimes ? dayTimezone : "America/New_York"

string displayPreset = input.string("Custom", "Layout", options=["Custom", "Intraday", "Swing", "Minimal"], group=G_SHOW)
bool inputDay = input.bool(true, "Daily VWAP", group=G_SHOW, inline="periods", active=displayPreset == "Custom")
bool inputWeek = input.bool(false, "Weekly", group=G_SHOW, inline="periods", active=displayPreset == "Custom")
bool inputMonth = input.bool(false, "Monthly", group=G_SHOW, inline="periods", active=displayPreset == "Custom")
bool inputPreviousDay = input.bool(false, "Previous-day AVWAP", group=G_SHOW, tooltip="Continues from the previous VWAP day's start and includes incoming volume.")
bool inputEngine = input.bool(true, "Reference VWAP", group=G_SHOW)
string engineMode = input.string("Rolling", "Reference type", options=["Rolling", "Session", "Adaptive Swing", "Swing AVWAP"], group=G_SHOW, active=inputEngine)
bool showConfluence = input.bool(false, "Highlight VWAP clusters", group=G_SHOW)
string lineMode = input.string("Custom", "Chart theme", options=["Custom", "Dark", "Light"], group=G_SHOW)

bool showWinningVWAP = input.bool(true, "Winner VWAP", group=G_WIN)
string winnerMode = input.string("Relevance", "Selection method", options=["Relevance", "Relative activity", "Volume rate", "Accumulated volume"], group=G_WIN, active=showWinningVWAP, tooltip="Relevance combines volume activity with price proximity. All enabled market sessions can compete.")
string winnerResponse = input.string("Balanced", "Switching response", options=["Stable", "Balanced", "Fast"], group=G_WIN, active=showWinningVWAP)
bool emphasizeWinner = input.bool(true, "Emphasize winner", group=G_WIN, active=showWinningVWAP)

bool showWinningBands = input.bool(true, "Winner bands", group=G_BANDS, active=showWinningVWAP)
string winnerBandUnit = input.string("Sigma", "Winner band distance", options=["Sigma", "ATR", "Percent"], group=G_BANDS, active=showWinningVWAP and showWinningBands)
float deviation1 = input.float(1, "Inner", minval=0.01, step=0.25, group=G_BANDS, inline="winnerbands", active=showWinningVWAP and showWinningBands)
float deviation2 = input.float(2, "Outer", minval=0.01, step=0.25, group=G_BANDS, inline="winnerbands", active=showWinningVWAP and showWinningBands)
bool inputDynamic = input.bool(true, "Reference envelope", group=G_BANDS, active=inputEngine)
float baseMult = input.float(2, "Envelope width", minval=0.1, step=0.1, group=G_BANDS, active=inputEngine and inputDynamic)
string extraBandMode = input.string("Off", "Additional bands", options=["Off", "Engine fixed sigma", "Selected reference"], group=G_BANDS)
bool showClassic = extraBandMode == "Engine fixed sigma"
bool showReferenceBands = extraBandMode == "Selected reference"
string bandReference = input.string("Day", "Band reference", options=["Day", "Week", "Month", "Asia", "London", "New York", "COMEX", "Manual A", "Manual B", "2D Low", "2D High"], group=G_BANDS, active=showReferenceBands)
string bandUnit = input.string("Sigma", "Band distance", options=["Sigma", "ATR", "Percent"], group=G_BANDS, active=showReferenceBands)
float refMult1 = input.float(1, "Inner", minval=0.01, group=G_BANDS, inline="refbands", active=showReferenceBands)
float refMult2 = input.float(2, "Outer", minval=0.01, group=G_BANDS, inline="refbands", active=showReferenceBands)
bool showRefBand3 = input.bool(false, "Third band", group=G_BANDS, active=showReferenceBands)

bool inputAnchors = input.bool(true, "Two-day extreme AVWAPs", group=G_ANCHOR)
string anchorReplacement = input.string("More extreme only", "Update anchor", options=["More extreme only", "Every qualifying swing", "Keep until expiry"], group=G_ANCHOR, active=inputAnchors)
bool showManualA = input.bool(false, "Manual anchor A", group=G_MANUAL, inline="manualA")
int manualTimeA = input.time(0, "Time", group=G_MANUAL, inline="manualA", active=showManualA)
bool showManualB = input.bool(false, "Manual anchor B", group=G_MANUAL, inline="manualB")
int manualTimeB = input.time(0, "Time", group=G_MANUAL, inline="manualB", active=showManualB)

bool showRightLabels = input.bool(true, "Line labels", group=G_LABELS)
string labelTextMode = input.string("Auto contrast", "Label text", options=["Auto contrast", "Custom"], group=G_LABELS)
color labelTextColor = input.color(#E6E6E6, "Text color", group=G_LABELS, active=labelTextMode == "Custom")
string labelSizeChoice = input.string("Small", "Text size", options=["Tiny", "Small", "Normal"], group=G_LABELS)
bool showLabelPrice = input.bool(true, "Show price", group=G_LABELS, active=showRightLabels)
int rightLabelOffset = input.int(4, "Right offset (bars)", minval=1, maxval=100, group=G_LABELS, active=showRightLabels)
bool spreadLabels = input.bool(true, "Avoid overlapping labels", group=G_LABELS, active=showRightLabels)
bool labelConnectors = input.bool(false, "Show label connectors", group=G_LABELS, active=showRightLabels and spreadLabels)

bool showDashboard = input.bool(true, "Dashboard", group=G_TABLE)
string dashboardView = input.string("Compact", "Details", options=["Compact", "Detailed"], group=G_TABLE, active=showDashboard)
string tableMode = input.string("Dark", "Dashboard theme", options=["Dark", "Light"], group=G_TABLE, active=showDashboard)
string distanceUnit = input.string("ATR", "Price distance", options=["Price", "Percent", "ATR", "Sigma"], group=G_TABLE, active=showDashboard)

string markerPreset = input.string("Session opens", "Markers", options=["Off", "Session opens", "Exchange opens", "Daily reset", "Session opens + reset"], group=G_OPENS)
bool showOpenLabels = input.bool(true, "Marker labels", group=G_OPENS, active=markerPreset != "Off")
bool showShanghaiOpen = input.bool(false, "Include Shanghai exchange open", group=G_OPENS, active=markerPreset == "Exchange opens")

string signalReference = input.string("Winner", "Alert reference", options=["Day", "Week", "Month", "Winner", "Engine", "Asia", "London", "New York", "COMEX", "Manual A", "Manual B", "2D Low", "2D High"], group=G_SIGNALS)
bool alertsOnClose = input.bool(true, "Confirm at bar close", group=G_SIGNALS)
bool enableCrossAlerts = input.bool(true, "VWAP crosses", group=G_SIGNALS)
bool enableTestAlerts = input.bool(false, "Support / resistance tests", group=G_SIGNALS)
bool enableBandAlerts = input.bool(false, "Band breaks", group=G_SIGNALS)
float alertBandMultiplier = input.float(2, "Alert band width", minval=0.01, group=G_SIGNALS, active=enableBandAlerts)
string alertBandUnit = input.string("Sigma", "Alert band distance", options=["Sigma", "ATR", "Percent"], group=G_SIGNALS, active=enableBandAlerts)

bool advancedControls = input.bool(false, "Enable advanced tuning", group=G_ADV)
string priceSourceInput = input.string("HLC3", "Price source", options=["HLC3", "HL2", "Close", "OHLC4"], group=G_ADV, active=advancedControls)
int engineLengthInput = input.int(200, "Rolling reference bars", minval=5, maxval=5000, group=G_ADV, active=advancedControls)
int pivotLengthInput = input.int(8, "Pivot confirmation bars", minval=3, maxval=30, group=G_ADV, active=advancedControls)
int activityWindowInput = input.int(20, "Volume activity bars", minval=3, maxval=200, group=G_ADV, active=advancedControls)
float activityWeightInput = input.float(60, "Volume weight (%)", minval=0, maxval=100, step=5, group=G_ADV, active=advancedControls)
float refMult3Input = input.float(3, "Third band width", minval=0.01, group=G_ADV, active=advancedControls and showRefBand3)
float labelGapInput = input.float(0.12, "Label spacing (ATR)", minval=0, maxval=2, step=0.02, group=G_ADV, active=advancedControls and spreadLabels)

string priceSource = advancedControls ? priceSourceInput : "HLC3"
int engineLength = advancedControls ? engineLengthInput : 200
int anchorPivotLen = advancedControls ? pivotLengthInput : 8
int activityWindow = advancedControls ? activityWindowInput : 20
float activityWeight = advancedControls ? activityWeightInput : 60
float refMult3 = advancedControls ? refMult3Input : 3
float labelGapATR = advancedControls ? labelGapInput : 0.12
float switchMargin = winnerResponse == "Stable" ? 12 : winnerResponse == "Fast" ? 4 : 8
int switchBars = winnerResponse == "Stable" ? 5 : winnerResponse == "Fast" ? 2 : 3
int minWinnerBars = 5
int profileLength = 20
int minProfileSessions = 5
float minimumScore = 15
float proximityScale = 2
bool includeAsiaWinner = true
bool breakAtResets = true
int anchorAtrLen = 14
float nearExtremeATR = 0.50
float anchorTestATR = 0.10
bool confirmAnchors = true
bool showAnchorDetails = true
string engineSource = "HL2"
int swingPeriod = 50
float baseAPT = 20
bool useAdapt = true
float volBias = 1.5
float volSens = 0.5
float adxInfluence = 0.8
int adxLength = 14
int adxSmooth = 14
int bandSmooth = 6
float dev1 = 1.28
float dev2 = 2.01
bool showC2 = true
bool showRefBand2 = true
int sentimentSlopeBars = 10
bool biasUseDay = true
bool biasUseSlope = true
bool biasUseWinner = true
bool biasUseAnchors = true
bool biasUseWeek = false
float signalToleranceATR = 0.10
int minClusterLevels = 3
float confluenceATR = 0.20
int retainedOpens = 80
bool weekdayOpenMarkers = tradingDays == "Weekdays"
string labelFontSize = labelSizeChoice == "Tiny" ? size.tiny : labelSizeChoice == "Normal" ? size.normal : size.small
bool sessionOpenMarkers = markerPreset == "Session opens" or markerPreset == "Session opens + reset"
bool exchangeOpenMarkers = markerPreset == "Exchange opens"
bool resetMarker = markerPreset == "Daily reset" or markerPreset == "Session opens + reset"
f_line_color(simple color darkColor, simple color lightColor, simple color customColor) =>
    lineMode == "Custom" ? customColor : lineMode == "Light" ? lightColor : darkColor
f_badge_text(color background) =>
    color contrast = color.r(background) * 299 + color.g(background) * 587 + color.b(background) * 114 > 128000 ? color.black : color.white
    labelTextMode == "Custom" ? labelTextColor : contrast
color USER_DAY = input.color(#03F10D, "Daily", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_DAY = USER_DAY
color USER_WEEK = input.color(#5100DE, "Weekly", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_WEEK = USER_WEEK
color USER_MONTH = input.color(#5100DE, "Monthly", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_MONTH = USER_MONTH
color USER_ASIA = input.color(#03F10D, "Asia", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_ASIA = USER_ASIA
color USER_LONDON = input.color(#5100DE, "London", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_LONDON = USER_LONDON
color USER_US = input.color(#5100DE, "COMEX", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_US = USER_US
color USER_WIN = input.color(#03F10D, "Winner", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_WIN = USER_WIN
color USER_BANDS = input.color(#5100DE, "Bands", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_WIN_U1 = USER_BANDS
color CUSTOM_WIN_L1 = USER_BANDS
color CUSTOM_WIN_U2 = USER_BANDS
color CUSTOM_WIN_L2 = USER_BANDS
color USER_ANCHORS = input.color(#03F10D, "Extreme anchors", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_LOW = USER_ANCHORS
color CUSTOM_HIGH = USER_ANCHORS
color USER_ENGINE = input.color(#5100DE, "Reference", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_ENGINE = USER_ENGINE
color CUSTOM_ENV_U = USER_BANDS
color CUSTOM_ENV_L = USER_BANDS
color CUSTOM_FIX_U1 = USER_BANDS
color CUSTOM_FIX_L1 = USER_BANDS
color CUSTOM_FIX_U2 = USER_BANDS
color CUSTOM_FIX_L2 = USER_BANDS
color USER_MANUAL = input.color(#03F10D, "Manual anchors", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_MANUAL_A = USER_MANUAL
color CUSTOM_MANUAL_B = USER_MANUAL
color CUSTOM_REF_BAND = USER_BANDS
color USER_ZONE = input.color(#5100DE, "Clusters", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_ZONE = USER_ZONE
color USER_OPENS = input.color(#5100DE, "Open markers", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_TOKYO_OPEN = USER_OPENS
color CUSTOM_SHANGHAI_OPEN = USER_OPENS
color CUSTOM_LONDON_OPEN = USER_OPENS
color CUSTOM_NY_OPEN = USER_OPENS
color CUSTOM_COMEX_OPEN = USER_OPENS
color CUSTOM_REOPEN = USER_OPENS
color USER_NY = input.color(#03F10D, "New York", group=G_COLORS, active=lineMode == "Custom")
color CUSTOM_NY = USER_NY
color DAY_COLOR = f_line_color(#FFFFFF, #161616, CUSTOM_DAY)
color WEEK_COLOR = f_line_color(#B0B0B0, #404040, CUSTOM_WEEK)
color MONTH_COLOR = f_line_color(#888888, #686868, CUSTOM_MONTH)
color ASIA_COLOR = f_line_color(#E0E0E0, #303030, CUSTOM_ASIA)
color LONDON_COLOR = f_line_color(#D0D0D0, #383838, CUSTOM_LONDON)
color US_COLOR = f_line_color(#A0A0A0, #606060, CUSTOM_US)
color WIN_COLOR = f_line_color(#FFFFFF, #000000, CUSTOM_WIN)
color WIN_U1_COLOR = f_line_color(#C0C0C0, #555555, CUSTOM_WIN_U1)
color WIN_L1_COLOR = f_line_color(#C0C0C0, #555555, CUSTOM_WIN_L1)
color WIN_U2_COLOR = f_line_color(#777777, #888888, CUSTOM_WIN_U2)
color WIN_L2_COLOR = f_line_color(#777777, #888888, CUSTOM_WIN_L2)
color LOW_COLOR = f_line_color(#E0E0E0, #303030, CUSTOM_LOW)
color HIGH_COLOR = f_line_color(#B0B0B0, #686868, CUSTOM_HIGH)
color ENGINE_COLOR = f_line_color(#FFFFFF, #202020, CUSTOM_ENGINE)
color ENV_U_COLOR = f_line_color(#D8D8D8, #666666, CUSTOM_ENV_U)
color ENV_L_COLOR = f_line_color(#D8D8D8, #666666, CUSTOM_ENV_L)
color FIX_U1_COLOR = f_line_color(#D0D0D0, #777777, CUSTOM_FIX_U1)
color FIX_L1_COLOR = f_line_color(#D0D0D0, #777777, CUSTOM_FIX_L1)
color FIX_U2_COLOR = f_line_color(#AAAAAA, #999999, CUSTOM_FIX_U2)
color FIX_L2_COLOR = f_line_color(#AAAAAA, #999999, CUSTOM_FIX_L2)
color MANUAL_A_COLOR = f_line_color(#E0E0E0, #303030, CUSTOM_MANUAL_A)
color MANUAL_B_COLOR = f_line_color(#B0B0B0, #606060, CUSTOM_MANUAL_B)
color REF_BAND_COLOR = f_line_color(#AAAAAA, #888888, CUSTOM_REF_BAND)
color ZONE_COLOR = f_line_color(#999999, #666666, CUSTOM_ZONE)
color TOKYO_OPEN_COLOR = f_line_color(#DDDDDD, #333333, CUSTOM_TOKYO_OPEN)
color SHANGHAI_OPEN_COLOR = f_line_color(#BBBBBB, #555555, CUSTOM_SHANGHAI_OPEN)
color LONDON_OPEN_COLOR = f_line_color(#999999, #777777, CUSTOM_LONDON_OPEN)
color NY_OPEN_COLOR = f_line_color(#777777, #999999, CUSTOM_NY_OPEN)
color COMEX_OPEN_COLOR = f_line_color(#555555, #BBBBBB, CUSTOM_COMEX_OPEN)
color REOPEN_COLOR = f_line_color(#AAAAAA, #666666, CUSTOM_REOPEN)
color NY_COLOR = f_line_color(#C8C8C8, #484848, CUSTOM_NY)

bool lightTable = tableMode == "Light"
color T_PANEL = lightTable ? #FAFAFA : #101010
color T_HEADER = lightTable ? #EEEEEE : lineMode == "Custom" ? #170C2B : #202020
color T_BORDER = lightTable ? #CCCCCC : lineMode == "Custom" ? USER_BANDS : #444444
color T_TEXT = lightTable ? #202020 : #E6E6E6
color T_ACCENT = lineMode == "Custom" ? USER_DAY : T_TEXT
color T_NEUTRAL = lightTable ? #666666 : #999999

bool customPreset = displayPreset == "Custom"
bool intradayPreset = displayPreset == "Intraday"
bool swingPreset = displayPreset == "Swing"
bool showDay = customPreset ? inputDay : true
bool showWeek = customPreset ? inputWeek : swingPreset
bool showMonth = customPreset ? inputMonth : swingPreset
bool showAsia = inputAsia and (customPreset or intradayPreset)
bool showLondon = inputLondon and (customPreset or intradayPreset)
bool showUS = inputUS and (customPreset or intradayPreset)
bool showNY = inputNY and (customPreset or intradayPreset)
bool showPreviousDay = customPreset ? inputPreviousDay : intradayPreset
bool showAnchors = customPreset ? inputAnchors : swingPreset
bool showEngine = customPreset ? inputEngine : swingPreset
bool showDynamic = customPreset ? inputDynamic : false
bool showWinner = displayPreset == "Minimal" or swingPreset ? false : showWinningVWAP
bool showWinnerBands = displayPreset == "Minimal" or swingPreset ? false : showWinningBands and showWinningVWAP

float src = priceSource == "HL2" ? hl2 : priceSource == "Close" ? close : priceSource == "OHLC4" ? ohlc4 : hlc3
float barVolume = math.max(nz(volume, 0), 0)
float atr = ta.atr(anchorAtrLen)
float safeATR = math.max(nz(atr, high - low), syminfo.mintick)
float chartSeconds = timeframe.isticks ? na : timeframe.in_seconds()
bool sessionSupported = timeframe.isintraday and chartSeconds >= 60 and chart.is_standard
int tfMillis = int(nz(chartSeconds, 60) * 1000)
int PROFILE_SLOTS = 2048

// Stable volume-weighted Welford variance; avoids large raw second moments.
type VwapStats
    float weight = 0.0
    float mean = na
    float m2 = 0.0

method reset(VwapStats s) =>
    s.weight := 0.0
    s.mean := na
    s.m2 := 0.0

method add(VwapStats s, float price, float vol) =>
    if vol > 0 and not na(price)
        float nextWeight = s.weight + vol
        float delta = s.weight > 0 ? price - s.mean : 0.0
        float nextMean = s.weight > 0 ? s.mean + delta * vol / nextWeight : price
        s.m2 += vol * delta * (price - nextMean)
        s.mean := nextMean
        s.weight := nextWeight

method sigma(VwapStats s) =>
    s.weight > 0 ? math.sqrt(math.max(s.m2 / s.weight, 0)) : na

f_day_key(int ts, string tz) =>
    year(ts, tz) * 10000 + month(ts, tz) * 100 + dayofmonth(ts, tz)

// Local Monday date identifies the week across December/January.
f_week_key(int ts, string tz) =>
    int weekday = dayofweek(ts, tz)
    int daysBack = (weekday + 5) % 7
    int monday = timestamp(tz, year(ts, tz), month(ts, tz), dayofmonth(ts, tz) - daysBack, 12, 0)
    f_day_key(monday, tz)

f_cycle_start(int ts) =>
    int y = year(ts, dayTimezone)
    int m = month(ts, dayTimezone)
    int d = dayofmonth(ts, dayTimezone)
    int boundary = timestamp(dayTimezone, y, m, d, resetHour, resetMinute)
    ts < boundary ? timestamp(dayTimezone, y, m, d - 1, resetHour, resetMinute) : boundary

int dayStartTime = f_cycle_start(time)
int dayKey = f_day_key(dayStartTime, dayTimezone)
int weekKey = f_week_key(dayStartTime, dayTimezone)
int monthKey = year(dayStartTime, dayTimezone) * 100 + month(dayStartTime, dayTimezone)
bool newDay = barstate.isfirst or dayKey != dayKey[1]
bool newWeek = barstate.isfirst or weekKey != weekKey[1]
bool newMonth = barstate.isfirst or monthKey != monthKey[1]

var VwapStats dayStats = VwapStats.new()
var VwapStats weekStats = VwapStats.new()
var VwapStats monthStats = VwapStats.new()
var VwapStats previousDayStats = VwapStats.new()
var int previousVWAPAnchor = na
if newDay
    // Carry yesterday's full daily statistics, then add today's bars below.
    previousDayStats.weight := dayStats.weight
    previousDayStats.mean := dayStats.mean
    previousDayStats.m2 := dayStats.m2
    previousVWAPAnchor := dayKey[1]
    dayStats.reset()
if newWeek
    weekStats.reset()
if newMonth
    monthStats.reset()
dayStats.add(src, barVolume)
if not na(previousVWAPAnchor)
    previousDayStats.add(src, barVolume)
weekStats.add(src, barVolume)
monthStats.add(src, barVolume)
float dayVWAP = dayStats.mean
float weekVWAP = weekStats.mean
float monthVWAP = monthStats.mean
float previousDayVWAP = not na(previousVWAPAnchor) ? previousDayStats.mean : na

var float todayHigh = na
var float todayLow = na
var float previousDayHigh = na
var float previousDayLow = na
var int previousDayKey = na
if newDay
    previousDayHigh := todayHigh
    previousDayLow := todayLow
    previousDayKey := dayKey[1]
    todayHigh := high
    todayLow := low
else
    todayHigh := math.max(todayHigh, high)
    todayLow := math.min(todayLow, low)
float referenceHigh = math.max(todayHigh, nz(previousDayHigh, todayHigh))
float referenceLow = math.min(todayLow, nz(previousDayLow, todayLow))

// Scheduled start key detects new sessions even if the data has no outside bars.
// Single continuous input.session window per market; supports overnight windows.
f_session_start(string sessionInput, string tz) =>
    int startHour = int(str.tonumber(str.substring(sessionInput, 0, 2)))
    int startMinute = int(str.tonumber(str.substring(sessionInput, 2, 4)))
    int localYear = year(time, tz)
    int localMonth = month(time, tz)
    int localDay = dayofmonth(time, tz)
    int scheduled = timestamp(tz, localYear, localMonth, localDay, startHour, startMinute)
    time < scheduled ? timestamp(tz, localYear, localMonth, localDay - 1, startHour, startMinute) : scheduled

f_session_end(int startTime, string sessionInput, string tz) =>
    int sh = int(str.tonumber(str.substring(sessionInput, 0, 2)))
    int sm = int(str.tonumber(str.substring(sessionInput, 2, 4)))
    int eh = int(str.tonumber(str.substring(sessionInput, 5, 7)))
    int em = int(str.tonumber(str.substring(sessionInput, 7, 9)))
    int extraDay = eh * 60 + em <= sh * 60 + sm ? 1 : 0
    timestamp(tz, year(startTime, tz), month(startTime, tz), dayofmonth(startTime, tz) + extraDay, eh, em)

type SessionState
    VwapStats stats
    array<float> profile
    array<int> observations
    array<float> currentProfile
    array<float> recentVolume
    array<float> recentExpected
    array<bool> recentReady
    int startTime = na
    int endTime = na
    bool running = false
    bool trainable = false
    int bars = 0
    int completed = 0
    int calculationDay = na
    float trainingVolume = 0.0
    float rvol = na
    float rate = na
    bool ready = false

f_new_session() =>
    SessionState.new(VwapStats.new(), array.new<float>(PROFILE_SLOTS, na), array.new<int>(PROFILE_SLOTS, 0), array.new<float>(PROFILE_SLOTS, na), array.new<float>(), array.new<float>(), array.new<bool>())

method reset_day(SessionState s) =>
    s.stats.reset()
    s.calculationDay := dayKey
    s.bars := 0
    s.rvol := na
    s.rate := na
    s.ready := false
    array.clear(s.recentVolume)
    array.clear(s.recentExpected)
    array.clear(s.recentReady)
    // Historical profile and an unfinished overnight training sample survive.

method finish(SessionState s) =>
    // Never train from a session that starts partway through loaded history.
    if s.trainable and s.trainingVolume > 0
        float profileAlpha = 2.0 / (profileLength + 1.0)
        for j = 0 to PROFILE_SLOTS - 1
            float observed = array.get(s.currentProfile, j)
            if not na(observed)
                float prior = array.get(s.profile, j)
                array.set(s.profile, j, na(prior) ? observed : prior + profileAlpha * (observed - prior))
                array.set(s.observations, j, array.get(s.observations, j) + 1)
        s.completed += 1
    s.running := false

method update(SessionState s, bool inside, int scheduledStart, int scheduledEnd) =>
    bool starts = inside and (na(s.startTime) or scheduledStart != s.startTime)
    if s.running and (starts or not inside)
        s.finish()
    if newDay
        s.reset_day()
    if starts
        s.reset_day()
        array.fill(s.currentProfile, na)
        s.startTime := scheduledStart
        s.endTime := scheduledEnd
        s.running := true
        s.trainable := time >= scheduledStart and time - scheduledStart < tfMillis
        s.trainingVolume := 0.0
    if inside
        s.stats.add(src, barVolume)
        s.trainingVolume += barVolume
        s.bars += 1
        int slot = int(math.floor((time - scheduledStart) / tfMillis))
        bool validSlot = slot >= 0 and slot < PROFILE_SLOTS
        float expected = validSlot ? array.get(s.profile, slot) : na
        bool trained = validSlot ? array.get(s.observations, slot) >= minProfileSessions : false
        if validSlot
            array.set(s.currentProfile, slot, nz(array.get(s.currentProfile, slot), 0) + barVolume)
        array.push(s.recentVolume, barVolume)
        array.push(s.recentExpected, expected)
        array.push(s.recentReady, trained and not na(expected) and expected > 0)
        if array.size(s.recentVolume) > activityWindow
            array.shift(s.recentVolume)
            array.shift(s.recentExpected)
            array.shift(s.recentReady)
        float actualTotal = 0.0
        float expectedTotal = 0.0
        bool allTrained = true
        int recentCount = array.size(s.recentVolume)
        for j = 0 to recentCount - 1
            actualTotal += array.get(s.recentVolume, j)
            expectedTotal += nz(array.get(s.recentExpected, j), 0)
            allTrained := allTrained and array.get(s.recentReady, j)
        s.ready := allTrained and recentCount >= math.min(minWinnerBars, activityWindow)
        s.rvol := s.ready and expectedTotal > 0 ? actualTotal / expectedTotal : na
        // Whole-session mean volume/bar is the common warmup fallback.
        s.rate := s.bars > 0 ? s.stats.weight / s.bars : na
    starts

bool inAsia = inputAsia and sessionSupported and not na(time(timeframe.period, asiaSession + ":" + sessionDays, asiaTimezone))
bool inLondon = inputLondon and sessionSupported and not na(time(timeframe.period, londonSession + ":" + sessionDays, londonTimezone))
bool inUS = inputUS and sessionSupported and not na(time(timeframe.period, usSession + ":" + sessionDays, usTimezone))
bool inNY = inputNY and sessionSupported and not na(time(timeframe.period, nySession + ":" + sessionDays, nyTimezone))
int nyStart = f_session_start(nySession, nyTimezone)
int asiaStart = f_session_start(asiaSession, asiaTimezone)
int londonStart = f_session_start(londonSession, londonTimezone)
int usStart = f_session_start(usSession, usTimezone)
var SessionState asia = f_new_session()
var SessionState london = f_new_session()
var SessionState us = f_new_session()
var SessionState ny = f_new_session()
bool newNY = ny.update(inNY, nyStart, f_session_end(nyStart, nySession, nyTimezone))
bool newAsia = asia.update(inAsia, asiaStart, f_session_end(asiaStart, asiaSession, asiaTimezone))
bool newLondon = london.update(inLondon, londonStart, f_session_end(londonStart, londonSession, londonTimezone))
bool newUS = us.update(inUS, usStart, f_session_end(usStart, usSession, usTimezone))

f_session_value(SessionState s, bool inside) =>
    inside and s.calculationDay == dayKey ? s.stats.mean : na
f_session_sigma(SessionState s) =>
    s.stats.sigma()
float asiaVWAP = f_session_value(asia, inAsia)
float londonVWAP = f_session_value(london, inLondon)
float usVWAP = f_session_value(us, inUS)
float nyVWAP = f_session_value(ny, inNY)

// Only active windows with current-day statistics can compete.
f_eligible(SessionState s, bool inside, bool included) =>
    included and inside and s.calculationDay == dayKey and s.bars >= minWinnerBars and s.stats.weight > 0

bool eligibleAsia = f_eligible(asia, inAsia, includeAsiaWinner)
bool eligibleLondon = f_eligible(london, inLondon, true)
bool eligibleUS = f_eligible(us, inUS, true)
bool eligibleNY = f_eligible(ny, inNY, true)
bool anyEligible = eligibleAsia or eligibleLondon or eligibleUS or eligibleNY
// Same units for every competitor; never compare a trained ratio with a raw rate.
bool profilesReady = anyEligible and (not eligibleAsia or asia.ready) and (not eligibleLondon or london.ready) and (not eligibleUS or us.ready) and (not eligibleNY or ny.ready)
float maxRate3 = math.max(eligibleAsia ? nz(asia.rate, 0) : 0, math.max(eligibleLondon ? nz(london.rate, 0) : 0, eligibleUS ? nz(us.rate, 0) : 0))
float maxVolume3 = math.max(eligibleAsia ? asia.stats.weight : 0, math.max(eligibleLondon ? london.stats.weight : 0, eligibleUS ? us.stats.weight : 0))

float maxRate = math.max(maxRate3, eligibleNY ? nz(ny.rate, 0) : 0)
float maxVolume = math.max(maxVolume3, eligibleNY ? ny.stats.weight : 0)

f_score(SessionState s, bool inside, bool eligible) =>
    float score = na
    if eligible
        float rateScore = maxRate > 0 ? 100.0 * s.rate / maxRate : 0.0
        float activityScore = profilesReady ? 100.0 * s.rvol / (1.0 + s.rvol) : rateScore
        float proximityScore = 100.0 * math.exp(-math.abs(close - s.stats.mean) / safeATR / proximityScale)
        float metric = winnerMode == "Relevance" ? activityWeight / 100.0 * activityScore + (1.0 - activityWeight / 100.0) * proximityScore : winnerMode == "Relative activity" ? activityScore : winnerMode == "Volume rate" ? rateScore : maxVolume > 0 ? 100.0 * s.stats.weight / maxVolume : 0.0
        score := metric
    score

float asiaScore = f_score(asia, inAsia, eligibleAsia)
float londonScore = f_score(london, inLondon, eligibleLondon)
float usScore = f_score(us, inUS, eligibleUS)
float nyScore = f_score(ny, inNY, eligibleNY)
var int winningId = 0
var int selectedAnchor = na
var int pendingId = 0
var int pendingAnchor = na
var int pendingBars = 0
var string selectionReason = "WAITING"
bool dailyWinnerCleared = newDay and winningId != 0
// Clear on the opening update of the new day, rather than waiting for bar close.
if newDay
    winningId := 0
    selectedAnchor := na
    pendingId := 0
    pendingAnchor := na
    pendingBars := 0
    selectionReason := "WAITING FOR SESSION"
float incumbentScore = winningId == 1 ? londonScore : winningId == 2 ? usScore : winningId == 3 ? asiaScore : winningId == 4 ? nyScore : na
int incumbentAnchor = winningId == 1 ? london.startTime : winningId == 2 ? us.startTime : winningId == 3 ? asia.startTime : winningId == 4 ? ny.startTime : na
bool incumbentValid = not na(incumbentScore) and incumbentScore >= minimumScore and incumbentAnchor == selectedAnchor
int bestId = incumbentValid ? winningId : 0
float bestScore = bestId != 0 ? incumbentScore : na
// Strict greater-than preserves the incumbent on ties.
if not na(londonScore) and londonScore >= minimumScore and (na(bestScore) or londonScore > bestScore)
    bestId := 1
    bestScore := londonScore
if not na(usScore) and usScore >= minimumScore and (na(bestScore) or usScore > bestScore)
    bestId := 2
    bestScore := usScore
if not na(asiaScore) and asiaScore >= minimumScore and (na(bestScore) or asiaScore > bestScore)
    bestId := 3
    bestScore := asiaScore
if not na(nyScore) and nyScore >= minimumScore and (na(bestScore) or nyScore > bestScore)
    bestId := 4
    bestScore := nyScore
int bestTies = (not na(londonScore) and math.abs(londonScore - bestScore) < 0.000001 ? 1 : 0) + (not na(usScore) and math.abs(usScore - bestScore) < 0.000001 ? 1 : 0) + (not na(asiaScore) and math.abs(asiaScore - bestScore) < 0.000001 ? 1 : 0) + (not na(nyScore) and math.abs(nyScore - bestScore) < 0.000001 ? 1 : 0)
if bestTies > 1 and (not incumbentValid or bestId != winningId)
    bestId := 0
    bestScore := na
int bestAnchor = bestId == 1 ? london.startTime : bestId == 2 ? us.startTime : bestId == 3 ? asia.startTime : bestId == 4 ? ny.startTime : na
bool winnerChanged = dailyWinnerCleared and barstate.isconfirmed
// Selection state only changes at bar close. Scores themselves remain live.
if barstate.isconfirmed
    int before = winningId
    int beforeAnchor = selectedAnchor
    if not incumbentValid
        winningId := 0
        selectedAnchor := na
    bool canChallenge = bestId != 0 and bestId != winningId and (winningId == 0 or bestScore > incumbentScore + switchMargin)
    if canChallenge
        pendingBars := pendingId == bestId and pendingAnchor == bestAnchor ? pendingBars + 1 : 1
        pendingId := bestId
        pendingAnchor := bestAnchor
        if pendingBars >= switchBars
            winningId := bestId
            selectedAnchor := bestAnchor
            pendingId := 0
            pendingAnchor := na
            pendingBars := 0
            selectionReason := before == 0 ? "QUALIFIED" : "CONFIRMED LEAD"
    else
        pendingId := 0
        pendingAnchor := na
        pendingBars := 0
    if winningId == 0
        selectionReason := bestId != 0 ? "CONFIRMING" : bestTies > 1 ? "TIED SCORES" : not (inAsia or inLondon or inUS or inNY) ? "WAITING FOR SESSION" : "NO QUALIFYING SCORE"
    winnerChanged := winnerChanged or winningId != before or (winningId != 0 and not na(beforeAnchor) and selectedAnchor != beforeAnchor)

SessionState winningSession = winningId == 1 ? london : winningId == 2 ? us : winningId == 4 ? ny : asia
float winningScore = winningId == 1 ? londonScore : winningId == 2 ? usScore : winningId == 3 ? asiaScore : winningId == 4 ? nyScore : na
bool winningInside = winningId == 1 ? inLondon : winningId == 2 ? inUS : winningId == 3 ? inAsia : winningId == 4 ? inNY : false
bool winningAvailable = winningId != 0 and winningInside and winningSession.calculationDay == dayKey and winningSession.startTime == selectedAnchor and not na(winningSession.stats.mean)
float winningVWAP = winningAvailable ? winningSession.stats.mean : na
float winningSigma = winningAvailable ? winningSession.stats.sigma() : na
int winningAnchor = winningAvailable ? winningSession.startTime : na
string winningName = winningId == 1 ? "LONDON" : winningId == 2 ? "COMEX" : winningId == 4 ? "NEW YORK" : winningId == 3 ? "ASIA" : "NONE"
bool winnerReset = newDay or winnerChanged or (winningId == 1 and newLondon) or (winningId == 2 and newUS) or (winningId == 3 and newAsia) or (winningId == 4 and newNY)
float winnerZ = not na(winningSigma) and winningSigma > 0 ? (close - winningVWAP) / winningSigma : na

// Confirmed near-extreme anchors. Values include pivot through confirmation bar;
// plots begin at confirmation without retrospectively drawing unavailable values.
float pivotHigh = ta.pivothigh(high, anchorPivotLen, anchorPivotLen)
float pivotLow = ta.pivotlow(low, anchorPivotLen, anchorPivotLen)
int pivotDayKey = f_day_key(f_cycle_start(time[anchorPivotLen]), dayTimezone)
bool pivotInWindow = pivotDayKey == dayKey or pivotDayKey == previousDayKey
float pivotATR = atr[anchorPivotLen]
bool qualifyLow = not na(pivotLow) and pivotInWindow and pivotATR > 0 and math.abs(pivotLow - referenceLow) / pivotATR <= nearExtremeATR
bool qualifyHigh = not na(pivotHigh) and pivotInWindow and pivotATR > 0 and math.abs(referenceHigh - pivotHigh) / pivotATR <= nearExtremeATR
var VwapStats lowStats = VwapStats.new()
var VwapStats highStats = VwapStats.new()
var int lowAnchorDay = na
var int highAnchorDay = na
var int lowAnchorTime = na
var int highAnchorTime = na
var int lowConfirmationTime = na
var int highConfirmationTime = na
var float lowAnchorPrice = na
var float highAnchorPrice = na
bool lowExpired = not na(lowAnchorDay) and lowAnchorDay != dayKey and lowAnchorDay != previousDayKey
bool highExpired = not na(highAnchorDay) and highAnchorDay != dayKey and highAnchorDay != previousDayKey
if lowExpired
    lowStats.reset()
    lowAnchorDay := na
    lowAnchorTime := na
    lowAnchorPrice := na
if highExpired
    highStats.reset()
    highAnchorDay := na
    highAnchorTime := na
    highAnchorPrice := na
bool anchorGate = not confirmAnchors or barstate.isconfirmed
bool newLowAnchor = anchorGate and qualifyLow and (na(lowAnchorDay) or anchorReplacement == "Every qualifying swing" or (anchorReplacement == "More extreme only" and pivotLow < lowAnchorPrice))
bool newHighAnchor = anchorGate and qualifyHigh and (na(highAnchorDay) or anchorReplacement == "Every qualifying swing" or (anchorReplacement == "More extreme only" and pivotHigh > highAnchorPrice))
if newLowAnchor
    lowStats.reset()
    lowAnchorDay := pivotDayKey
    lowAnchorTime := time[anchorPivotLen]
    lowConfirmationTime := time_close
    lowAnchorPrice := pivotLow
    for i = anchorPivotLen to 0
        lowStats.add(src[i], math.max(nz(volume[i], 0), 0))
else if not na(lowAnchorDay)
    lowStats.add(src, barVolume)
if newHighAnchor
    highStats.reset()
    highAnchorDay := pivotDayKey
    highAnchorTime := time[anchorPivotLen]
    highConfirmationTime := time_close
    highAnchorPrice := pivotHigh
    for i = anchorPivotLen to 0
        highStats.add(src[i], math.max(nz(volume[i], 0), 0))
else if not na(highAnchorDay)
    highStats.add(src, barVolume)
float lowAVWAP = lowStats.mean
float highAVWAP = highStats.mean
float anchorTolerance = safeATR * anchorTestATR
string lowState = na(lowAVWAP) ? "WAIT" : close > lowAVWAP + anchorTolerance ? "HOLDS" : close < lowAVWAP - anchorTolerance ? "LOST" : "TEST"
string highState = na(highAVWAP) ? "WAIT" : close < highAVWAP - anchorTolerance ? "REJECTS" : close > highAVWAP + anchorTolerance ? "RECLAIM" : "TEST"

// Manual timestamps before loaded history are explicitly unavailable.
var int firstLoadedTime = time
var VwapStats manualA = VwapStats.new()
var VwapStats manualB = VwapStats.new()
var bool manualActiveA = false
var bool manualActiveB = false
bool crossManualA = manualTimeA >= firstLoadedTime and ((time <= manualTimeA and time_close > manualTimeA) or (time >= manualTimeA and (barstate.isfirst or time[1] < manualTimeA)))
bool crossManualB = manualTimeB >= firstLoadedTime and ((time <= manualTimeB and time_close > manualTimeB) or (time >= manualTimeB and (barstate.isfirst or time[1] < manualTimeB)))
bool newManualA = crossManualA and not manualActiveA
bool newManualB = crossManualB and not manualActiveB
if newManualA
    manualA.reset()
    manualActiveA := true
if newManualB
    manualB.reset()
    manualActiveB := true
if manualActiveA
    manualA.add(src, barVolume)
if manualActiveB
    manualB.add(src, barVolume)

// Reference engines. Adaptive is decayed; Swing AVWAP is cumulative.
float enginePx = engineSource == "HL2" ? hl2 : hlc3
float rollingVWAP = ta.vwma(enginePx, engineLength)
float rollingMoment2 = ta.vwma(enginePx * enginePx, engineLength)
var VwapStats engineSession = VwapStats.new()
if newDay
    engineSession.reset()
engineSession.add(enginePx, barVolume)
int highOffset = ta.highestbars(high, swingPeriod)
int lowOffset = ta.lowestbars(low, swingPeriod)
int nextDirection = highOffset == lowOffset ? 0 : highOffset > lowOffset ? 1 : -1
var int swingDirection = 0
var VwapStats adaptive = VwapStats.new()
var VwapStats swing = VwapStats.new()
var int swingAnchorTime = na
bool swingReset = barstate.isconfirmed and nextDirection != 0 and nextDirection != swingDirection
float engineATR = ta.atr(50)
float engineATRAvg = ta.rma(engineATR, 50)
float atrRatio = not na(engineATRAvg) and engineATRAvg > 0 ? engineATR / engineATRAvg : 1.0
float aptRaw = useAdapt ? baseAPT / math.pow(math.max(atrRatio, 0.0001), volBias) : baseAPT
float apt = math.max(5.0, math.min(300.0, aptRaw))
float alpha = 2.0 / (apt + 1.0)
if swingReset
    swingDirection := nextDirection
    adaptive.reset()
    swing.reset()
    int anchorOffset = nextDirection == 1 ? -lowOffset : -highOffset
    swingAnchorTime := time[anchorOffset]
    for i = anchorOffset to 0
        swing.add(enginePx[i], math.max(nz(volume[i], 0), 0))
else
    swing.add(enginePx, barVolume)
adaptive.weight *= 1.0 - alpha
adaptive.m2 *= 1.0 - alpha
adaptive.add(enginePx, alpha * barVolume)
float engineVWAP = engineMode == "Rolling" ? rollingVWAP : engineMode == "Session" ? engineSession.mean : engineMode == "Adaptive Swing" ? adaptive.mean : swing.mean
float rollingSigma = not na(rollingVWAP) ? math.sqrt(math.max(rollingMoment2 - rollingVWAP * rollingVWAP, 0)) : na
float engineSigma = engineMode == "Rolling" ? rollingSigma : engineMode == "Session" ? engineSession.sigma() : engineMode == "Adaptive Swing" ? adaptive.sigma() : swing.sigma()
bool engineReset = engineMode == "Session" ? newDay : engineMode == "Rolling" ? false : swingReset
[engineDIPlus, engineDIMinus, engineADX] = ta.dmi(adxLength, adxSmooth)
float volumeAverage = ta.sma(barVolume, 20)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0 ? barVolume / volumeAverage : 1.0
float dynamicMultiplier = baseMult * (1.0 + math.max(0, volumeRatio - 1.0) * volSens) * (1.0 + nz(engineADX, 0) / 100.0 * adxInfluence)
float rawWidth = dynamicMultiplier * engineSigma
var float envelopeWidth = na
float widthAlpha = 2.0 / (bandSmooth + 1.0)
envelopeWidth := na(rawWidth) ? na : engineReset or na(envelopeWidth) ? rawWidth : envelopeWidth + widthAlpha * (rawWidth - envelopeWidth)
float upper1 = engineVWAP + envelopeWidth
float lower1 = engineVWAP - envelopeWidth

f_band_width(float value, float sigma, string unit, float multiplier) =>
    multiplier * (unit == "Sigma" ? sigma : unit == "ATR" ? atr : math.abs(value) / 100.0)

// Shared reference routing keeps alert and band selections consistent.
f_reference(string selection) =>
    float value = na
    float sigma = na
    int key = na
    bool resetEvent = false
    switch selection
        "Day" =>
            value := dayVWAP
            sigma := dayStats.sigma()
            key := dayKey
            resetEvent := newDay
        "Week" =>
            value := weekVWAP
            sigma := weekStats.sigma()
            key := weekKey
            resetEvent := newWeek
        "Month" =>
            value := monthVWAP
            sigma := monthStats.sigma()
            key := monthKey
            resetEvent := newMonth
        "Winner" =>
            value := winningVWAP
            sigma := winningSigma
            key := winningAnchor
            resetEvent := winnerReset
        "Engine" =>
            value := engineVWAP
            sigma := engineSigma
            key := engineMode == "Session" ? dayKey : engineMode == "Rolling" ? 0 : swingAnchorTime
            resetEvent := engineReset
        "Asia" =>
            value := asiaVWAP
            sigma := f_session_sigma(asia)
            key := asia.startTime
            resetEvent := newDay or newAsia
        "London" =>
            value := londonVWAP
            sigma := f_session_sigma(london)
            key := london.startTime
            resetEvent := newDay or newLondon
        "COMEX" =>
            value := usVWAP
            sigma := f_session_sigma(us)
            key := us.startTime
            resetEvent := newDay or newUS
        "New York" =>
            value := nyVWAP
            sigma := f_session_sigma(ny)
            key := ny.startTime
            resetEvent := newDay or newNY
        "Manual A" =>
            value := manualA.mean
            sigma := manualA.sigma()
            key := manualTimeA
            resetEvent := newManualA
        "Manual B" =>
            value := manualB.mean
            sigma := manualB.sigma()
            key := manualTimeB
            resetEvent := newManualB
        "2D Low" =>
            value := lowAVWAP
            sigma := lowStats.sigma()
            key := lowAnchorTime
            resetEvent := newLowAnchor or lowExpired
        "2D High" =>
            value := highAVWAP
            sigma := highStats.sigma()
            key := highAnchorTime
            resetEvent := newHighAnchor or highExpired
    [value, sigma, key, resetEvent]

[referenceValue, referenceSigma, referenceKey, referenceReset] = f_reference(bandReference)
float refWidth1 = f_band_width(referenceValue, referenceSigma, bandUnit, refMult1)
float refWidth2 = f_band_width(referenceValue, referenceSigma, bandUnit, refMult2)
float refWidth3 = f_band_width(referenceValue, referenceSigma, bandUnit, refMult3)
float winnerWidth1 = f_band_width(winningVWAP, winningSigma, winnerBandUnit, deviation1)
float winnerWidth2 = f_band_width(winningVWAP, winningSigma, winnerBandUnit, deviation2)
bool showExtraBands = showReferenceBands or showClassic
bool showExtraBand2 = showReferenceBands ? showRefBand2 : showClassic and showC2
bool showExtraBand3 = showReferenceBands and showRefBand3
float extraValue = showReferenceBands ? referenceValue : engineVWAP
float extraWidth1 = showReferenceBands ? refWidth1 : dev1 * engineSigma
float extraWidth2 = showReferenceBands ? refWidth2 : dev2 * engineSigma
float extraWidth3 = refWidth3
bool extraReset = showReferenceBands ? referenceReset : engineReset
color EXTRA_U1_COLOR = showReferenceBands ? REF_BAND_COLOR : FIX_U1_COLOR
color EXTRA_L1_COLOR = showReferenceBands ? REF_BAND_COLOR : FIX_L1_COLOR
color EXTRA_U2_COLOR = showReferenceBands ? REF_BAND_COLOR : FIX_U2_COLOR
color EXTRA_L2_COLOR = showReferenceBands ? REF_BAND_COLOR : FIX_L2_COLOR

// Bias is agreement among selected correlated references, not a probability.
f_vote(float value, bool enabled) =>
    float score = enabled and not na(value) ? close > value ? 1.0 : close < value ? -1.0 : 0.0 : 0.0
    float votes = enabled and not na(value) ? 1.0 : 0.0
    [score, votes]
[dayVote, dayVotes] = f_vote(dayVWAP, biasUseDay)
[winnerVote, winnerVotes] = f_vote(winningVWAP, biasUseWinner)
[lowVote, lowVotes] = f_vote(lowAVWAP, biasUseAnchors)
[highVote, highVotes] = f_vote(highAVWAP, biasUseAnchors)
[weekVote, weekVotes] = f_vote(weekVWAP, biasUseWeek)
bool slopeValid = biasUseSlope and dayKey == dayKey[sentimentSlopeBars] and not na(dayVWAP) and not na(dayVWAP[sentimentSlopeBars])
float slopeVote = slopeValid ? dayVWAP > dayVWAP[sentimentSlopeBars] ? 1 : dayVWAP < dayVWAP[sentimentSlopeBars] ? -1 : 0 : 0
float biasScore = dayVote + winnerVote + lowVote + highVote + weekVote + slopeVote
float biasVotes = dayVotes + winnerVotes + lowVotes + highVotes + weekVotes + (slopeValid ? 1 : 0)
float biasNormalized = biasVotes > 0 ? biasScore / biasVotes : 0
int bullVotes = int((dayVote > 0 ? 1 : 0) + (winnerVote > 0 ? 1 : 0) + (lowVote > 0 ? 1 : 0) + (highVote > 0 ? 1 : 0) + (weekVote > 0 ? 1 : 0) + (slopeVote > 0 ? 1 : 0))
int bearVotes = int((dayVote < 0 ? 1 : 0) + (winnerVote < 0 ? 1 : 0) + (lowVote < 0 ? 1 : 0) + (highVote < 0 ? 1 : 0) + (weekVote < 0 ? 1 : 0) + (slopeVote < 0 ? 1 : 0))
string biasName = biasNormalized >= 0.60 ? "STRONG BULL" : biasNormalized >= 0.20 ? "BULL" : biasNormalized <= -0.60 ? "STRONG BEAR" : biasNormalized <= -0.20 ? "BEAR" : "NEUTRAL"

// Confluence excludes winner (a duplicate session) and previous final levels.
// Only displayed primary references enter; cluster width is total range.
array<float> clusterValues = array.new<float>()
array<string> clusterNames = array.new<string>()
f_cluster_add(array<float> values, array<string> names, bool visible, float value, string title) =>
    if visible and not na(value)
        array.push(values, value)
        array.push(names, title)
f_cluster_add(clusterValues, clusterNames, showDay, dayVWAP, "DAY")
f_cluster_add(clusterValues, clusterNames, showWeek, weekVWAP, "WEEK")
f_cluster_add(clusterValues, clusterNames, showMonth, monthVWAP, "MONTH")
f_cluster_add(clusterValues, clusterNames, showAsia, asiaVWAP, "ASIA")
f_cluster_add(clusterValues, clusterNames, showLondon, londonVWAP, "LDN")
f_cluster_add(clusterValues, clusterNames, showUS, usVWAP, "COMEX")
f_cluster_add(clusterValues, clusterNames, showNY, nyVWAP, "NY")
f_cluster_add(clusterValues, clusterNames, showAnchors, lowAVWAP, "LOW")
f_cluster_add(clusterValues, clusterNames, showAnchors, highAVWAP, "HIGH")
f_cluster_add(clusterValues, clusterNames, showManualA, manualA.mean, "A")
f_cluster_add(clusterValues, clusterNames, showManualB, manualB.mean, "B")
float clusterLow = na
float clusterHigh = na
int clusterCount = 0
string clusterMembers = ""
if showConfluence and array.size(clusterValues) >= minClusterLevels
    array<int> clusterOrder = array.sort_indices(clusterValues, order.ascending)
    int n = array.size(clusterOrder)
    float allowedWidth = safeATR * confluenceATR
    for i = 0 to n - 1
        float bottom = array.get(clusterValues, array.get(clusterOrder, i))
        int endIndex = i
        for j = i to n - 1
            if array.get(clusterValues, array.get(clusterOrder, j)) - bottom <= allowedWidth
                endIndex := j
            else
                break
        int count = endIndex - i + 1
        float top = array.get(clusterValues, array.get(clusterOrder, endIndex))
        bool nearer = count == clusterCount and not na(clusterLow) and math.abs(close - (top + bottom) / 2) < math.abs(close - (clusterHigh + clusterLow) / 2)
        if count >= minClusterLevels and (count > clusterCount or nearer)
            clusterCount := count
            clusterLow := bottom
            clusterHigh := top
            clusterMembers := ""
            for j = i to endIndex
                clusterMembers += (j == i ? "" : " + ") + array.get(clusterNames, array.get(clusterOrder, j))

// Session/winner drawings are deleted at the daily reset. Long-horizon plots keep history.
f_plot_value(bool visible, float value, bool resets) =>
    visible and not (breakAtResets and resets) ? value : na

// Mutable drawings let us erase yesterday's session curves immediately on the
// first realtime daily reset update; historical plot masks cannot erase old outputs.
type TraceSegment
    array<chart.point> points
type DayTrace
    array<TraceSegment> segments
    array<polyline> drawings
    bool continuous = false

f_new_trace() =>
    DayTrace.new(array.new<TraceSegment>(), array.new<polyline>())

method clear(DayTrace t) =>
    for drawing in t.drawings
        polyline.delete(drawing)
    array.clear(t.drawings)
    array.clear(t.segments)
    t.continuous := false

method record(DayTrace t, float value, bool resets) =>
    if newDay
        t.clear()
    if not na(value)
        if resets or not t.continuous or array.size(t.segments) == 0
            // Up to 15 traces × 6 segments = 90, below the 100-polyline cap.
            if array.size(t.segments) >= 6
                array.shift(t.segments)
            array.push(t.segments, TraceSegment.new(array.new<chart.point>()))
        TraceSegment segment = array.get(t.segments, array.size(t.segments) - 1)
        array.push(segment.points, chart.point.from_time(time, value))
        t.continuous := true
    else
        t.continuous := false

method render(DayTrace t, color col, int width) =>
    if barstate.islast
        for drawing in t.drawings
            polyline.delete(drawing)
        array.clear(t.drawings)
        for segment in t.segments
            if array.size(segment.points) >= 2
                array.push(t.drawings, polyline.new(segment.points, curved=false, closed=false, xloc=xloc.bar_time, line_color=col, line_width=width))

bool extraSessionBased = showReferenceBands and (bandReference == "Asia" or bandReference == "London" or bandReference == "COMEX" or bandReference == "New York")
dayPlot = plot(f_plot_value(showDay, dayVWAP, newDay), title="Day VWAP", color=DAY_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
weekPlot = plot(f_plot_value(showWeek, weekVWAP, newWeek), title="Week VWAP", color=WEEK_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
monthPlot = plot(f_plot_value(showMonth, monthVWAP, newMonth), title="Month VWAP", color=MONTH_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
var DayTrace asiaPlotTrace = f_new_trace()
asiaPlotTrace.record(f_plot_value(showAsia, asiaVWAP, newAsia), newAsia)
asiaPlotTrace.render(ASIA_COLOR, 2)
var DayTrace londonPlotTrace = f_new_trace()
londonPlotTrace.record(f_plot_value(showLondon, londonVWAP, newLondon), newLondon)
londonPlotTrace.render(LONDON_COLOR, 2)
var DayTrace usPlotTrace = f_new_trace()
usPlotTrace.record(f_plot_value(showUS, usVWAP, newUS), newUS)
usPlotTrace.render(US_COLOR, 2)
var DayTrace nyPlotTrace = f_new_trace()
nyPlotTrace.record(f_plot_value(showNY, nyVWAP, newNY), newNY)
nyPlotTrace.render(NY_COLOR, 2)
pdPlot = plot(f_plot_value(showPreviousDay, previousDayVWAP, newDay), title="Previous-Day Anchored VWAP", color=DAY_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace winnerPlotTrace = f_new_trace()
winnerPlotTrace.record(f_plot_value(showWinner, winningVWAP, winnerReset), winnerReset)
winnerPlotTrace.render(WIN_COLOR, emphasizeWinner ? 4 : 2)
var DayTrace wu1PlotTrace = f_new_trace()
wu1PlotTrace.record(f_plot_value(showWinnerBands, winningVWAP + winnerWidth1, winnerReset), winnerReset)
wu1PlotTrace.render(WIN_U1_COLOR, 1)
var DayTrace wl1PlotTrace = f_new_trace()
wl1PlotTrace.record(f_plot_value(showWinnerBands, winningVWAP - winnerWidth1, winnerReset), winnerReset)
wl1PlotTrace.render(WIN_L1_COLOR, 1)
var DayTrace wu2PlotTrace = f_new_trace()
wu2PlotTrace.record(f_plot_value(showWinnerBands, winningVWAP + winnerWidth2, winnerReset), winnerReset)
wu2PlotTrace.render(WIN_U2_COLOR, 1)
var DayTrace wl2PlotTrace = f_new_trace()
wl2PlotTrace.record(f_plot_value(showWinnerBands, winningVWAP - winnerWidth2, winnerReset), winnerReset)
wl2PlotTrace.render(WIN_L2_COLOR, 1)
lowPlot = plot(f_plot_value(showAnchors, lowAVWAP, newLowAnchor or lowExpired), title="2D Low AVWAP", color=LOW_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
highPlot = plot(f_plot_value(showAnchors, highAVWAP, newHighAnchor or highExpired), title="2D High AVWAP", color=HIGH_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
maPlot = plot(f_plot_value(showManualA, manualA.mean, newManualA), title="Manual AVWAP A", color=MANUAL_A_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
mbPlot = plot(f_plot_value(showManualB, manualB.mean, newManualB), title="Manual AVWAP B", color=MANUAL_B_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
enginePlot = plot(f_plot_value(showEngine, engineVWAP, engineReset), title="Reference VWAP", color=ENGINE_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
envUPlot = plot(f_plot_value(showDynamic, upper1, engineReset), title="Envelope Upper", color=ENV_U_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
envLPlot = plot(f_plot_value(showDynamic, lower1, engineReset), title="Envelope Lower", color=ENV_L_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
extraU1Plot = plot(f_plot_value((showExtraBands) and not extraSessionBased, extraValue + extraWidth1, extraReset), title="Additional Upper 1", color=EXTRA_U1_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraU1PlotTrace = f_new_trace()
extraU1PlotTrace.record(f_plot_value((showExtraBands) and extraSessionBased, extraValue + extraWidth1, extraReset), extraReset)
extraU1PlotTrace.render(EXTRA_U1_COLOR, 1)
extraL1Plot = plot(f_plot_value((showExtraBands) and not extraSessionBased, extraValue - extraWidth1, extraReset), title="Additional Lower 1", color=EXTRA_L1_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraL1PlotTrace = f_new_trace()
extraL1PlotTrace.record(f_plot_value((showExtraBands) and extraSessionBased, extraValue - extraWidth1, extraReset), extraReset)
extraL1PlotTrace.render(EXTRA_L1_COLOR, 1)
extraU2Plot = plot(f_plot_value((showExtraBand2) and not extraSessionBased, extraValue + extraWidth2, extraReset), title="Additional Upper 2", color=EXTRA_U2_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraU2PlotTrace = f_new_trace()
extraU2PlotTrace.record(f_plot_value((showExtraBand2) and extraSessionBased, extraValue + extraWidth2, extraReset), extraReset)
extraU2PlotTrace.render(EXTRA_U2_COLOR, 1)
extraL2Plot = plot(f_plot_value((showExtraBand2) and not extraSessionBased, extraValue - extraWidth2, extraReset), title="Additional Lower 2", color=EXTRA_L2_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraL2PlotTrace = f_new_trace()
extraL2PlotTrace.record(f_plot_value((showExtraBand2) and extraSessionBased, extraValue - extraWidth2, extraReset), extraReset)
extraL2PlotTrace.render(EXTRA_L2_COLOR, 1)
extraU3Plot = plot(f_plot_value((showExtraBand3) and not extraSessionBased, extraValue + extraWidth3, extraReset), title="Additional Upper 3", color=REF_BAND_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraU3PlotTrace = f_new_trace()
extraU3PlotTrace.record(f_plot_value((showExtraBand3) and extraSessionBased, extraValue + extraWidth3, extraReset), extraReset)
extraU3PlotTrace.render(REF_BAND_COLOR, 1)
extraL3Plot = plot(f_plot_value((showExtraBand3) and not extraSessionBased, extraValue - extraWidth3, extraReset), title="Additional Lower 3", color=REF_BAND_COLOR, linewidth=1, style=plot.style_linebr, display=display.pane)
var DayTrace extraL3PlotTrace = f_new_trace()
extraL3PlotTrace.record(f_plot_value((showExtraBand3) and extraSessionBased, extraValue - extraWidth3, extraReset), extraReset)
extraL3PlotTrace.render(REF_BAND_COLOR, 1)

// Current cluster box follows live values; no misleading historical connections.
var box clusterBox = na
if barstate.islast
    if showConfluence and clusterCount >= minClusterLevels
        if na(clusterBox)
            clusterBox := box.new(bar_index - 1, clusterHigh, bar_index + rightLabelOffset, clusterLow, border_color=ZONE_COLOR, bgcolor=color.new(ZONE_COLOR, 88))
        else
            box.set_lefttop(clusterBox, bar_index - 1, clusterHigh)
            box.set_rightbottom(clusterBox, bar_index + rightLabelOffset, clusterLow)
            box.set_border_color(clusterBox, ZONE_COLOR)
            box.set_bgcolor(clusterBox, color.new(ZONE_COLOR, 88))
    else if not na(clusterBox)
        box.delete(clusterBox)
        clusterBox := na

// Alert resets never masquerade as price crosses. All ta.cross calls run each bar.
[signalValue, signalSigma, signalKey, signalReset] = f_reference(signalReference)
float signalWidth = f_band_width(signalValue, signalSigma, alertBandUnit, alertBandMultiplier)
float signalUpper = signalValue + signalWidth
float signalLower = signalValue - signalWidth
float testTolerance = safeATR * signalToleranceATR
bool crossedUp = ta.crossover(close, signalValue)
bool crossedDown = ta.crossunder(close, signalValue)
bool crossedUpper = ta.crossover(close, signalUpper)
bool crossedLower = ta.crossunder(close, signalLower)
bool signalContinuous = not signalReset and not na(signalValue) and not na(signalValue[1]) and not na(signalKey) and signalKey == signalKey[1]
// Winner keys include identity: two custom sessions can share a start timestamp.
signalContinuous := signalContinuous and (signalReference != "Winner" or winningId == winningId[1])
bool priceAlertGate = (not alertsOnClose or barstate.isconfirmed) and signalContinuous
bool reclaimed = close > signalValue + testTolerance and low <= signalValue + testTolerance and low >= signalValue - testTolerance
bool rejected = close < signalValue - testTolerance and high >= signalValue - testTolerance and high <= signalValue + testTolerance
alertcondition(newLowAnchor, "New 2D Low AVWAP", "New near-extreme 2D Low AVWAP confirmed")
alertcondition(newHighAnchor, "New 2D High AVWAP", "New near-extreme 2D High AVWAP confirmed")
alertcondition(winnerChanged and winningId == 1, "London Becomes Winner", "London is the confirmed VWAP winner")
alertcondition(winnerChanged and winningId == 2, "COMEX Becomes Winner", "COMEX is the confirmed VWAP winner")
alertcondition(winnerChanged and winningId == 3, "Asia Becomes Winner", "Asia is the confirmed VWAP winner")
alertcondition(winnerChanged and winningId == 4, "New York Becomes Winner", "New York is the confirmed VWAP winner")
alertcondition(winnerChanged and winningId == 0, "Winner Cleared", "No confirmed eligible VWAP winner")
bool bandsValid = not na(signalWidth) and signalWidth > 0 and signalWidth[1] > 0
string alertEvents = ""
if priceAlertGate
    if enableCrossAlerts and crossedUp
        alertEvents += "CROSS UP; "
    if enableCrossAlerts and crossedDown
        alertEvents += "CROSS DOWN; "
    if enableTestAlerts and reclaimed
        alertEvents += "SUPPORT TEST; "
    if enableTestAlerts and rejected
        alertEvents += "RESISTANCE TEST; "
    if enableBandAlerts and bandsValid and crossedUpper
        alertEvents += "UPPER BAND BREAK; "
    if enableBandAlerts and bandsValid and crossedLower
        alertEvents += "LOWER BAND BREAK; "
if alertEvents != ""
    string message = syminfo.ticker + " | " + timeframe.period + " | " + signalReference + " | " + alertEvents + "Close " + str.tostring(close, format.mintick) + " | VWAP " + str.tostring(signalValue, format.mintick)
    alert(message, alertsOnClose ? alert.freq_once_per_bar_close : alert.freq_once_per_bar)

// Right labels use raw valid values even on deliberately blank reset plot bars.
// Sort then space labels; connector endpoints always remain at the actual price.
var array<label> rightTags = array.new<label>()
var array<line> rightLinks = array.new<line>()
array<float> tagValues = array.new<float>()
array<string> tagNames = array.new<string>()
array<color> tagColors = array.new<color>()
array<string> tagTips = array.new<string>()
f_tag_add(bool visible, float value, string title, color col, string tip) =>
    if visible and not na(value)
        array.push(tagValues, value)
        array.push(tagNames, title)
        array.push(tagColors, col)
        array.push(tagTips, tip)
f_time_text(int ts) =>
    na(ts) ? "—" : str.format_time(ts, "yyyy-MM-dd HH:mm", dayTimezone)
f_anchor_tip(int anchorTime, int confirmedTime) =>
    showAnchorDetails ? "Anchor: " + f_time_text(anchorTime) + "\nConfirmed: " + f_time_text(confirmedTime) + "\nTimezone: " + dayTimezone : ""

if barstate.islast
    for tag in rightTags
        label.delete(tag)
    for link in rightLinks
        line.delete(link)
    array.clear(rightTags)
    array.clear(rightLinks)
    if showRightLabels
        f_tag_add(showDay, dayVWAP, "DAY", DAY_COLOR, "")
        f_tag_add(showWeek, weekVWAP, "WEEK", WEEK_COLOR, "")
        f_tag_add(showMonth, monthVWAP, "MONTH", MONTH_COLOR, "")
        bool winnerDuplicatesSession = showWinner and winningAvailable
        f_tag_add(showAsia and not (winnerDuplicatesSession and winningId == 3), asiaVWAP, "ASIA", ASIA_COLOR, "")
        f_tag_add(showLondon and not (winnerDuplicatesSession and winningId == 1), londonVWAP, "LONDON", LONDON_COLOR, "")
        f_tag_add(showUS and not (winnerDuplicatesSession and winningId == 2), usVWAP, "COMEX", US_COLOR, "")
        f_tag_add(showNY and not (winnerDuplicatesSession and winningId == 4), nyVWAP, "NEW YORK", NY_COLOR, "")
        f_tag_add(showPreviousDay, previousDayVWAP, "PREV DAY AVWAP", DAY_COLOR, "Includes the previous VWAP day and incoming volume.")
        f_tag_add(showWinner, winningVWAP, winningName + " WIN", WIN_COLOR, "Winner score: " + str.tostring(winningScore, "#.1"))
        f_tag_add(showWinnerBands, winningVWAP + winnerWidth1, "W +1", WIN_U1_COLOR, winnerBandUnit)
        f_tag_add(showWinnerBands, winningVWAP - winnerWidth1, "W -1", WIN_L1_COLOR, winnerBandUnit)
        f_tag_add(showWinnerBands, winningVWAP + winnerWidth2, "W +2", WIN_U2_COLOR, winnerBandUnit)
        f_tag_add(showWinnerBands, winningVWAP - winnerWidth2, "W -2", WIN_L2_COLOR, winnerBandUnit)
        f_tag_add(showAnchors, lowAVWAP, "2D LOW", LOW_COLOR, f_anchor_tip(lowAnchorTime, lowConfirmationTime))
        f_tag_add(showAnchors, highAVWAP, "2D HIGH", HIGH_COLOR, f_anchor_tip(highAnchorTime, highConfirmationTime))
        f_tag_add(showManualA, manualA.mean, "MANUAL A", MANUAL_A_COLOR, f_time_text(manualTimeA))
        f_tag_add(showManualB, manualB.mean, "MANUAL B", MANUAL_B_COLOR, f_time_text(manualTimeB))
        f_tag_add(showEngine, engineVWAP, "REF " + engineMode, ENGINE_COLOR, engineMode == "Swing AVWAP" ? f_time_text(swingAnchorTime) : "")
        f_tag_add(showDynamic, upper1, "ENV +", ENV_U_COLOR, "")
        f_tag_add(showDynamic, lower1, "ENV -", ENV_L_COLOR, "")
        f_tag_add(showClassic, engineVWAP + dev1 * engineSigma, "FIX +1", FIX_U1_COLOR, "")
        f_tag_add(showClassic, engineVWAP - dev1 * engineSigma, "FIX -1", FIX_L1_COLOR, "")
        f_tag_add(showClassic and showC2, engineVWAP + dev2 * engineSigma, "FIX +2", FIX_U2_COLOR, "")
        f_tag_add(showClassic and showC2, engineVWAP - dev2 * engineSigma, "FIX -2", FIX_L2_COLOR, "")
        f_tag_add(showReferenceBands, referenceValue + refWidth1, bandReference + " +1", REF_BAND_COLOR, bandUnit)
        f_tag_add(showReferenceBands, referenceValue - refWidth1, bandReference + " -1", REF_BAND_COLOR, bandUnit)
        f_tag_add(showReferenceBands and showRefBand2, referenceValue + refWidth2, bandReference + " +2", REF_BAND_COLOR, bandUnit)
        f_tag_add(showReferenceBands and showRefBand2, referenceValue - refWidth2, bandReference + " -2", REF_BAND_COLOR, bandUnit)
        f_tag_add(showReferenceBands and showRefBand3, referenceValue + refWidth3, bandReference + " +3", REF_BAND_COLOR, bandUnit)
        f_tag_add(showReferenceBands and showRefBand3, referenceValue - refWidth3, bandReference + " -3", REF_BAND_COLOR, bandUnit)
        if array.size(tagValues) > 0
            array<int> sorted = array.sort_indices(tagValues, order.ascending)
            float priorY = na
            float gap = spreadLabels ? math.max(safeATR * labelGapATR, syminfo.mintick * 2) : 0
            for i = 0 to array.size(sorted) - 1
                int index = array.get(sorted, i)
                float actual = array.get(tagValues, index)
                float y = spreadLabels and not na(priorY) ? math.max(actual, priorY + gap) : actual
                color col = array.get(tagColors, index)
                color textCol = f_badge_text(col)
                string caption = array.get(tagNames, index) + (showLabelPrice ? "  " + str.tostring(actual, format.mintick) : "")
                array.push(rightTags, label.new(bar_index + rightLabelOffset, y, caption, xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=textCol, size=labelFontSize, tooltip=array.get(tagTips, index)))
                if labelConnectors and math.abs(y - actual) > syminfo.mintick
                    array.push(rightLinks, line.new(bar_index, actual, bar_index + rightLabelOffset, y, color=color.new(col, 40), width=1))
                priorY := y

// Compact dashboard with explicit score units and profile warmup state.
f_distance(float value, float sigma) =>
    string result = "—"
    if not na(value)
        float difference = close - value
        if distanceUnit == "Price"
            result := str.tostring(difference, format.mintick)
        else if distanceUnit == "Percent"
            result := value != 0 ? str.tostring(100 * difference / math.abs(value), "#.2") + "%" : "—"
        else if distanceUnit == "ATR"
            result := not na(atr) and atr > 0 ? str.tostring(difference / atr, "#.2") + " ATR" : "—"
        else
            result := not na(sigma) and sigma > 0 ? str.tostring(difference / sigma, "#.2") + "σ" : "—"
    result
f_value_distance(float value, float sigma) =>
    na(value) ? "—" : str.tostring(value, format.mintick) + " | Δ " + f_distance(value, sigma)
f_session_row(SessionState s, bool inside, float score, float value) =>
    string activity = s.ready ? str.tostring(s.rvol, "#.2") + "×" : "WARMUP"
    string points = na(score) ? "—" : str.tostring(score, "#.1")
    not inside ? (s.bars > 0 and s.calculationDay == dayKey ? "CLOSED" : "WAITING FOR OPEN") : na(value) ? "LIVE | WAITING FOR VOLUME" : "LIVE | " + points + " pts | RV " + activity + " | Δ " + f_distance(value, f_session_sigma(s))
string activeSession = (inAsia ? "ASIA " : "") + (inLondon ? "LDN " : "") + (inUS ? "COMEX " : "") + (inNY ? "NY" : "")
activeSession := activeSession == "" ? "OUTSIDE" : activeSession
string scoringState = not anyEligible ? "NO ACTIVE CANDIDATE" : winnerMode == "Relevance" or winnerMode == "Relative activity" ? profilesReady ? "PROFILE READY" : "RATE FALLBACK" : winnerMode
var table dash = table.new(position.top_right, 2, 17, bgcolor=T_PANEL, frame_color=T_BORDER, frame_width=1, border_color=T_BORDER, border_width=1)
f_row(int row, string title, string value) =>
    table.cell(dash, 0, row, title, text_color=T_TEXT, text_size=size.small)
    table.cell(dash, 1, row, value, text_color=T_TEXT, text_size=size.small)
if barstate.islast
    table.clear(dash, 0, 0, 1, 16)
    if showDashboard
        table.cell(dash, 0, 0, "AVWAP", text_color=T_ACCENT, text_size=size.small, bgcolor=T_HEADER)
        table.cell(dash, 1, 0, activeSession, text_color=T_TEXT, text_size=size.small, bgcolor=T_HEADER)
        if dashboardView == "Compact"
            f_row(1, "DAILY", f_value_distance(dayVWAP, dayStats.sigma()))
            string winnerSummary = winningAvailable ? winningName + " " + str.tostring(winningVWAP, format.mintick) : "Waiting for selection"
            if pendingId != 0
                winnerSummary += " | " + str.tostring(pendingBars) + "/" + str.tostring(switchBars)
            f_row(2, "WINNER", winnerSummary)
            int compactRow = 3
            if inputLondon
                f_row(compactRow, "LONDON", not inLondon ? (london.bars > 0 ? "Closed" : "Waiting for open") : f_value_distance(londonVWAP, london.stats.sigma()))
                compactRow += 1
            if inputNY
                f_row(compactRow, "NEW YORK", not inNY ? (ny.bars > 0 ? "Closed" : "Waiting for open") : f_value_distance(nyVWAP, ny.stats.sigma()))
                compactRow += 1
            if inputUS
                f_row(compactRow, "COMEX", not inUS ? (us.bars > 0 ? "Closed" : "Waiting for open") : f_value_distance(usVWAP, us.stats.sigma()))
                compactRow += 1
            if inputAsia
                f_row(compactRow, "ASIA", not inAsia ? (asia.bars > 0 ? "Closed" : "Waiting for open") : f_value_distance(asiaVWAP, asia.stats.sigma()))
                compactRow += 1
            f_row(compactRow, "BIAS", biasName)
        else
            f_row(1, "DAY", f_value_distance(dayVWAP, dayStats.sigma()))
            f_row(2, "WEEK / MONTH", (na(weekVWAP) ? "—" : str.tostring(weekVWAP, format.mintick)) + " / " + (na(monthVWAP) ? "—" : str.tostring(monthVWAP, format.mintick)))
            f_row(3, "WINNER", winningAvailable ? winningName + " " + f_value_distance(winningVWAP, winningSigma) : "—")
            f_row(4, "SELECTION", selectionReason + " | " + scoringState)
            f_row(5, "PENDING", pendingId == 0 ? "—" : (pendingId == 1 ? "LDN" : pendingId == 2 ? "COMEX" : pendingId == 4 ? "NY" : "ASIA") + " " + str.tostring(pendingBars) + "/" + str.tostring(switchBars))
            f_row(6, "LONDON", f_session_row(london, inLondon, londonScore, londonVWAP))
            f_row(7, "NEW YORK", inputNY ? f_session_row(ny, inNY, nyScore, nyVWAP) : "OFF")
            f_row(8, "COMEX", inputUS ? f_session_row(us, inUS, usScore, usVWAP) : "OFF")
            f_row(9, "ASIA", inputAsia ? f_session_row(asia, inAsia, asiaScore, asiaVWAP) : "OFF")
            string lowAge = na(lowAnchorTime) ? "" : " | " + str.tostring((time - lowAnchorTime) / 3600000.0, "#.1") + "h"
            string highAge = na(highAnchorTime) ? "" : " | " + str.tostring((time - highAnchorTime) / 3600000.0, "#.1") + "h"
            f_row(10, "2D LOW", na(lowAVWAP) ? "—" : f_value_distance(lowAVWAP, lowStats.sigma()) + " | " + lowState + lowAge)
            f_row(11, "2D HIGH", na(highAVWAP) ? "—" : f_value_distance(highAVWAP, highStats.sigma()) + " | " + highState + highAge)
            f_row(12, "VWAP BIAS", biasName + " | " + str.tostring(bullVotes) + " bull / " + str.tostring(bearVotes) + " bear")
            f_row(13, "REFERENCE " + engineMode, f_value_distance(engineVWAP, engineSigma))
            f_row(14, "MANUAL A / B", (showManualA ? f_value_distance(manualA.mean, manualA.sigma()) : "OFF") + " / " + (showManualB ? f_value_distance(manualB.mean, manualB.sigma()) : "OFF"))
            f_row(15, "CLUSTER", clusterCount > 0 ? str.tostring(clusterCount) + " | " + clusterMembers : "—")
            string status = not sessionSupported ? "Sessions: standard time charts ≥1m, intraday" : na(volume) ? "NO VOLUME FEED" : barVolume == 0 ? "ZERO VOLUME BAR" : "Reset " + resetText + " " + timezoneChoice + " | " + winnerMode
            if (showManualA and manualTimeA < firstLoadedTime) or (showManualB and manualTimeB < firstLoadedTime)
                status += " | Manual anchor outside history"
            f_row(16, "STATUS", status)

// Recreated on every realtime update; rollback removes the previous uncommitted
// instance. Capped queues protect right tags from the drawing garbage collector.
var array<line> openLines = array.new<line>()
var array<label> openLabels = array.new<label>()
array<int> openLabelPlacement = array.new<int>(1, 0)
if newDay
    for openingLine in openLines
        line.delete(openingLine)
    for openingLabel in openLabels
        label.delete(openingLabel)
    array.clear(openLines)
    array.clear(openLabels)
f_open_event(string tz, int openHour, int openMinute) =>
    int opening = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), openHour, openMinute)
    // A chart candle can contain tomorrow's local midnight/opening.
    if opening < time
        opening := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz) + 1, openHour, openMinute)
    int marketDay = dayofweek(opening, tz)
    bool weekday = marketDay >= dayofweek.monday and marketDay <= dayofweek.friday
    sessionSupported and (not weekdayOpenMarkers or weekday) and time <= opening and time_close > opening
f_draw_open(bool condition, string caption, color col) =>
    if condition
        array.push(openLines, line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color.new(col, 35), style=line.style_dashed, width=1))
        if showOpenLabels
            int markerRow = array.get(openLabelPlacement, 0)
            float markerY = high + safeATR * (0.4 + markerRow * 0.5)
            array.push(openLabels, label.new(bar_index, markerY, caption, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=col, textcolor=f_badge_text(col), size=labelFontSize))
            array.set(openLabelPlacement, 0, markerRow + 1)
        if array.size(openLines) > retainedOpens
            line.delete(array.shift(openLines))
        if array.size(openLabels) > retainedOpens
            label.delete(array.shift(openLabels))
if sessionOpenMarkers
    f_draw_open(newAsia and asia.trainable, "ASIA OPEN", TOKYO_OPEN_COLOR)
    f_draw_open(newLondon and london.trainable, "LONDON OPEN", LONDON_OPEN_COLOR)
    f_draw_open(newNY and ny.trainable, "NEW YORK OPEN", NY_OPEN_COLOR)
    f_draw_open(newUS and us.trainable, "COMEX OPEN", COMEX_OPEN_COLOR)
if exchangeOpenMarkers
    f_draw_open(inputAsia and f_open_event("Asia/Tokyo", 8, 45), "TOKYO / OSE", TOKYO_OPEN_COLOR)
    f_draw_open(showShanghaiOpen and f_open_event("Asia/Shanghai", 9, 0), "SHANGHAI", SHANGHAI_OPEN_COLOR)
    f_draw_open(inputLondon and f_open_event("Europe/London", 8, 0), "LONDON", LONDON_OPEN_COLOR)
    f_draw_open(inputNY and f_open_event("America/New_York", 9, 30), "NEW YORK", NY_OPEN_COLOR)
    f_draw_open(inputUS and f_open_event("America/New_York", 8, 20), "COMEX", COMEX_OPEN_COLOR)
f_draw_open(resetMarker and newDay, "DAY RESET", REOPEN_COLOR)
````
