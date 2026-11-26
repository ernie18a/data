# VWAP Aurora_Suite 

- url: https://www.tradingview.com/script/pKz9DS80-VWAP-Aurora-Suite/
- type: indicator
- pine_id: PUB;98ca6b98e3944594a111ed212dcc0386
- version: 1.0

## Description

[b]Aurora VWAP _SUITE [/b]

[b]Overview[/b]

Aurora VWAP places several volume-weighted price references on one chart: a daily VWAP, London and US/COMEX session VWAPs, a volume-leading session VWAP with deviation bands, two-day extreme anchored VWAPs, and a separate reference VWAP engine. A compact table summarizes the current values, anchor states, and a five-factor sentiment reading. Optional right-edge tags and exchange-open markers help identify lines and session transitions.

The purpose is to compare where volume has traded across different starting points and windows. A session VWAP describes the average price weighted by volume accumulated during that session. An extreme AVWAP follows volume from a confirmed swing near the current or previous day's high or low. The reference engine supplies another view of equilibrium using a rolling, day-reset, or adaptive swing calculation. These are different contexts, so their lines can diverge without one being wrong.

[b]Main features[/b]

Daily and session VWAPs. The Day VWAP accumulates HLC3 × volume from the first bar of each selected calendar day. London uses the 08:00–16:30 London session and US/COMEX uses the 08:20–13:30 New York session by default. The session inputs and timezones can be edited. Accumulators reset when a new day begins in the selected Day Reset Timezone.

Volume leader and deviation bands. Once session volume is available, the indicator compares the accumulated London and US volumes. The larger total becomes the winner. A thick winning VWAP and optional ±1 and ±2 volume-weighted standard-deviation bands follow that session. The defaults are 1.0σ and 2.0σ, and the multipliers are adjustable. A change in leader breaks the plotted winner line at the transition rather than drawing a misleading connector between different session VWAPs. An exact volume tie has no winner.

Two-day extreme AVWAPs. The script tracks the high and low across the current and previous days. A confirmed swing pivot can start a high or low AVWAP only when it lies within the chosen ATR distance of the corresponding two-day extreme. The cumulative price-volume calculation begins at the pivot bar; the line becomes visible only after the configured number of swing confirmation bars. A newer qualifying pivot replaces the older anchor on the same side. Anchors expire when their day is no longer in the current/previous-day window. The table describes a low AVWAP as HOLDS, LOST, or TEST and a high AVWAP as REJECTS, RECLAIM, or TEST using an ATR-based tolerance.

Independent reference engine. Select Rolling, Session, or Smart Swing. Rolling is a volume-weighted moving average over the specified bars. Session accumulates the selected HL2 or HLC3 source from the Day Reset Timezone boundary. Smart Swing resets its decayed, volume-weighted sums when the latest rolling high/low changes direction; its tracking speed can adjust with ATR. These engine modes do not move the London/US session VWAPs or the two-day pivot anchors.

Engine bands. The optional volume/ADX envelope begins with the engine's volume-weighted standard deviation. The multiplier expands above its base when current volume exceeds its 20-bar average and also scales with ADX; the upper and lower levels are smoothed. Optional fixed-multiplier bands use the same engine sigma without the volume/ADX expansion. Fixed refers to their multipliers, not to static prices.

Dashboard, labels, and opens. The table shows the active session, Day VWAP, winning session and its distance in sigma, two-day AVWAP states, normalized sentiment, and reference engine value. Right-edge tags can include the latest price. Dashed markers are available for Tokyo/OSE, Shanghai, London, New York, COMEX, and the Asia/Sydney reopen. Each marker has its own enable switch and color.

[b]How it works[/b]

The core VWAP calculation uses the typical price and volume accumulated within the relevant day or session:

[pine]
dayPV += hlc3 * nz(volume, 0.0)
dayVol += nz(volume, 0.0)
float dayVWAP = dayVol > 0 ? dayPV / dayVol : na
[/pine]

The winning session is determined by accumulated session volume, rather than by which VWAP is higher or closer to price:

[pine]
bool londonLeads = londonVol > 0 and (usVol == 0 or londonVol > usVol)
bool usLeads = usVol > 0 and (londonVol == 0 or usVol > londonVol)
[/pine]

The selectable day boundary is also used for the two-day extreme window and the engine's Session mode. Exchange uses the symbol's exchange timezone; named locations use IANA timezones, so their daylight-saving changes are handled by the timezone rules. The default is Europe/Berlin.

[pine]
string dayTimezone = dayTimezoneChoice == "Exchange" ? syminfo.timezone : dayTimezoneChoice
int dayKey = year(time, dayTimezone) * 10000 + month(time, dayTimezone) * 100 + dayofmonth(time, dayTimezone)
bool newDay = bar_index == 0 or dayKey != dayKey[1]
[/pine]

The sentiment value counts up to five available comparisons: price versus Day VWAP, Day VWAP slope, price versus winning VWAP, price versus low AVWAP, and price versus high AVWAP. Each available comparison casts one bullish or bearish vote, or zero on equality. The sum is divided by the number of available votes, producing a reading from −100% to +100%. The dashboard labels strong readings at ±60% and moderate readings at ±20%. This is a description of agreement between references, not a probability forecast.

[b]How to use[/b]

Read the daily context. Compare price with Day VWAP, then check whether London and US session VWAPs agree with or diverge from it. The selected reset timezone determines which bars belong to each day; choose it before comparing days on an intraday chart.

Watch the session handoff. During the London/US overlap, observe which session has contributed more cumulative volume. When the leader changes, the winning line changes its underlying session. Treat the break in that line as a handoff, not as a sudden price jump.

Evaluate a test of an extreme anchor. A confirmed low or high AVWAP shows the volume-weighted average since a qualifying extreme pivot. Use the table's HOLDS/LOST or REJECTS/RECLAIM state to see whether the close is outside the ATR tolerance. A TEST state means the close is within that tolerance. Pivot confirmation takes time, so the anchor line appears after the pivot and is not an advance signal at the extreme.

Judge distance from equilibrium. Winner deviation bands measure distance in that session's volume-weighted sigma. The reference envelope adds volume and ADX sensitivity. A touch or move beyond a band describes extension; it does not imply that a reversal must occur.

[b]Settings guide[/b]

Chart Lines: Show the Day, London, and US VWAPs and optionally emphasize the session volume leader.

Session Times: Set the Day Reset Timezone and the London and US/COMEX session windows and timezones. The day reset choices include Berlin, Exchange, UTC, London, Zurich, New York, Chicago, Los Angeles, Tokyo, Shanghai, Dubai, and Sydney.

Winning Session: Show the winner line and deviation bands; adjust both sigma multipliers.

Extreme Anchors: Control pivot confirmation, ATR length, qualifying distance, and AVWAP test tolerance. The Day VWAP slope setting affects the sentiment vote.

Reference Engine: Choose Rolling, Session, or Smart Swing and configure its price source and mode-specific parameters.

Engine Bands: Enable the dynamic envelope or fixed-multiplier bands and adjust sigma, volume, ADX, and smoothing parameters.

Exchange Opens / Right Edge Labels: Select visible open markers, label content, and horizontal tag offset.

Dashboard Table: Show or hide the summary and select its own Dark or Light mode.

Line Palette / Custom Colors: Select Dark, Light, or Custom for VWAP lines, bands, anchors, tags, and open markers. In Custom mode, the individual color pickers are used. The table mode does not change line colors, and the line mode does not change the table.

[b]Alerts[/b]

The indicator provides four alert conditions: a newly confirmed two-day low AVWAP, a newly confirmed two-day high AVWAP, London taking the accumulated session-volume lead, and US taking that lead. Create the desired alerts in TradingView after adding the indicator to the chart.

[b]Notes and limitations[/b]

This tool is designed chiefly for intraday charts. Calculations use the chart's available bar prices and volume; symbols with missing or zero volume may have unavailable VWAPs. Session and open-event timing depends on bar resolution: an open marker is drawn on the bar spanning its specified time. The two-day anchors require pivot confirmation and can change when a newer qualifying pivot appears. On a live, unclosed bar, the displayed values and conditions can continue to update.

VWAPs, deviations, sentiment, and anchor states provide context for analysis. They do not place orders or define a complete trading strategy. This description is for educational use and is not financial advice.

## Source Code

````pine
//@version=6
indicator("AVWAP", shorttitle="AVWAP", overlay=true, max_labels_count=200, max_lines_count=500, max_bars_back=5000)

// SETTINGS
string G_SHOW = "01 · Chart Lines"
string G_SESS = "02 · Session Times"
string G_WIN = "03 · Winning Session"
string G_ANCHOR = "04 · Extreme Anchors"
string G_ENGINE = "05 · Reference Engine"
string G_BANDS = "06 · Engine Bands"
string G_OPENS = "07 · Exchange Opens"
string G_LABELS = "08 · Right Edge Labels"
string G_TABLE = "09 · Dashboard Table"
string G_LINE_MODE = "10 · Line Palette"
string G_DAY_COL = "11 · Custom Colors / Sessions"
string G_WIN_COL = "12 · Custom Colors / Winner and Anchors"
string G_ENG_COL = "13 · Custom Colors / Engine and Bands"
string G_OPEN_COL = "14 · Custom Colors / Exchange Opens"

// Chart lines
bool showDayVWAP = input.bool(true, "Day VWAP", group=G_SHOW)
bool showLondonVWAP = input.bool(true, "London VWAP", group=G_SHOW)
bool showUSVWAP = input.bool(true, "US VWAP", group=G_SHOW)
bool emphasizeVolumeLeader = input.bool(true, "Emphasize Volume Leader", group=G_SHOW)

// Sessions
string dayTimezoneChoice = input.string("Europe/Berlin", "Day Reset Timezone", options=["Europe/Berlin", "Exchange", "Etc/UTC", "Europe/London", "Europe/Zurich", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Shanghai", "Asia/Dubai", "Australia/Sydney"], group=G_SESS, tooltip="The VWAP day resets at midnight in this time zone. Exchange uses the symbol's exchange time zone.")
string dayTimezone = dayTimezoneChoice == "Exchange" ? syminfo.timezone : dayTimezoneChoice
string londonSession = input.session("0800-1630", "London Session", group=G_SESS)
string londonTimezone = input.string("Europe/London", "London Timezone", group=G_SESS)
string usSession = input.session("0820-1330", "US / COMEX Session", group=G_SESS)
string usTimezone = input.string("America/New_York", "US Timezone", group=G_SESS)

// Winning session and anchors
bool showWinningVWAP = input.bool(true, "Show Winning VWAP", group=G_WIN)
bool showWinningBands = input.bool(true, "Show Winner Deviation Bands", group=G_WIN)
float deviation1 = input.float(1.0, "Band 1 Sigma", minval=0.25, maxval=3.0, step=0.25, group=G_WIN)
float deviation2 = input.float(2.0, "Band 2 Sigma", minval=0.50, maxval=5.0, step=0.25, group=G_WIN)
bool showAnchorVWAP = input.bool(true, "Show Extreme AVWAPs", group=G_ANCHOR)
int anchorPivotLen = input.int(8, "Swing Confirmation Bars", minval=3, maxval=30, group=G_ANCHOR)
int anchorAtrLen = input.int(14, "ATR Length", minval=5, maxval=100, group=G_ANCHOR)
float nearExtremeATR = input.float(0.50, "Max Distance from 2-Day Extreme × ATR", minval=0.10, maxval=2.0, step=0.05, group=G_ANCHOR)
float anchorTestATR = input.float(0.10, "AVWAP Test Tolerance × ATR", minval=0.0, maxval=1.0, step=0.05, group=G_ANCHOR)
int sentimentSlopeBars = input.int(10, "Day VWAP Slope Bars (Sentiment)", minval=2, maxval=100, group=G_ANCHOR)

// Reference engine
bool showEngine = input.bool(true, "Show Reference VWAP", group=G_ENGINE)
string engineMode = input.string("Rolling", "Reference Mode", options=["Rolling", "Session", "Smart Swing"], group=G_ENGINE)
string engineSource = input.string("HL2", "Engine Price Source", options=["HL2", "HLC3"], group=G_ENGINE)
int engineLength = input.int(200, "Rolling Window Bars", minval=5, maxval=5000, group=G_ENGINE)
int swingPeriod = input.int(50, "Smart Swing Lookback", minval=2, maxval=500, group=G_ENGINE)
float baseAPT = input.float(20.0, "Smart Swing Tracking Speed", minval=5, maxval=300, group=G_ENGINE)
bool useAdapt = input.bool(true, "Adapt Smart Swing Speed with ATR", group=G_ENGINE)
float volBias = input.float(1.5, "Smart Swing ATR Adaptation", minval=0.1, maxval=10, step=0.1, group=G_ENGINE)

// Engine bands
bool showDynamic = input.bool(true, "Show Volume / ADX Envelope", group=G_BANDS)
float baseMult = input.float(2.0, "Envelope Base Sigma", minval=0.1, step=0.1, group=G_BANDS)
float volSens = input.float(0.5, "Volume Expansion Factor", minval=0, step=0.1, group=G_BANDS)
float adxInfluence = input.float(0.8, "ADX Expansion Factor", minval=0, maxval=3, step=0.1, group=G_BANDS)
int adxLength = input.int(14, "ADX DI Length", minval=1, group=G_BANDS)
int adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=G_BANDS)
int bandSmooth = input.int(6, "Envelope Smoothing", minval=1, maxval=30, group=G_BANDS)
bool showClassic = input.bool(false, "Show Fixed Multiplier Bands", group=G_BANDS, tooltip="Reference VWAP ± multiplier × volume-weighted sigma. No ADX or volume expansion.")
float dev1 = input.float(1.28, "Fixed Multiplier 1 × Sigma", minval=0.1, group=G_BANDS)
float dev2 = input.float(2.01, "Fixed Multiplier 2 × Sigma", minval=0.1, group=G_BANDS)
bool showC2 = input.bool(true, "Show Fixed Multiplier 2", group=G_BANDS)

// Exchange opens
bool showTokyoOpen = input.bool(true, "Tokyo", group=G_OPENS)
bool showShanghaiOpen = input.bool(true, "Shanghai", group=G_OPENS)
bool showLondonOpen = input.bool(true, "London", group=G_OPENS)
bool showNewYorkOpen = input.bool(true, "New York", group=G_OPENS)
bool showComexOpen = input.bool(true, "COMEX", group=G_OPENS)
bool showAsiaReopen = input.bool(true, "Asia / Sydney Reopen", group=G_OPENS)
bool showOpenLabels = input.bool(true, "Show Open Labels", group=G_OPENS)

// Right edge labels
bool showRightLabels = input.bool(true, "Show Right Edge Line Labels", group=G_LABELS)
bool showLabelPrice = input.bool(true, "Include Price", group=G_LABELS)
int rightLabelOffset = input.int(4, "Offset in Bars", minval=1, maxval=100, group=G_LABELS)

// Independent dashboard mode
bool showDashboard = input.bool(true, "Show Dashboard", group=G_TABLE)
string tableMode = input.string("Dark", "Table Mode", options=["Dark", "Light"], group=G_TABLE)
bool tableLight = tableMode == "Light"
color T_PANEL = tableLight ? #FAFAFA : #101010
color T_HEADER = tableLight ? #EEEEEE : #202020
color T_BORDER = tableLight ? #CCCCCC : #444444
color T_TEXT = tableLight ? #202020 : #E6E6E6
color T_NEUTRAL = tableLight ? #666666 : #999999
color T_DAY = tableLight ? #161616 : #FFFFFF
color T_LONDON = tableLight ? #383838 : #D0D0D0
color T_US = tableLight ? #606060 : #A0A0A0
color T_LOW = tableLight ? #303030 : #E0E0E0
color T_HIGH = tableLight ? #686868 : #B0B0B0
color T_ENGINE = tableLight ? #202020 : #FFFFFF

// Independent line mode
string lineMode = input.string("Dark", "Line Mode", options=["Dark", "Light", "Custom"], group=G_LINE_MODE)

f_line_color(color darkColor, color lightColor, color customColor) =>
    lineMode == "Custom" ? customColor : lineMode == "Light" ? lightColor : darkColor

// Custom line colors
color CUSTOM_DAY_COLOR = input.color(#FFFFFF, "Day VWAP", group=G_DAY_COL)
color CUSTOM_LONDON_COLOR = input.color(#D0D0D0, "London VWAP", group=G_DAY_COL)
color CUSTOM_US_COLOR = input.color(#A0A0A0, "US VWAP", group=G_DAY_COL)
color CUSTOM_WIN_COLOR = input.color(#FFFFFF, "Winning VWAP", group=G_WIN_COL)
color CUSTOM_WIN_U1 = input.color(#C0C0C0, "Winner Upper 1", group=G_WIN_COL)
color CUSTOM_WIN_L1 = input.color(#C0C0C0, "Winner Lower 1", group=G_WIN_COL)
color CUSTOM_WIN_U2 = input.color(#777777, "Winner Upper 2", group=G_WIN_COL)
color CUSTOM_WIN_L2 = input.color(#777777, "Winner Lower 2", group=G_WIN_COL)
color CUSTOM_LOW_COLOR = input.color(#E0E0E0, "Two-Day Low AVWAP", group=G_WIN_COL)
color CUSTOM_HIGH_COLOR = input.color(#B0B0B0, "Two-Day High AVWAP", group=G_WIN_COL)
color CUSTOM_ENGINE_COLOR = input.color(#FFFFFF, "Reference VWAP", group=G_ENG_COL)
color CUSTOM_ENV_U1 = input.color(#D8D8D8, "Envelope Upper 1", group=G_ENG_COL)
color CUSTOM_ENV_L1 = input.color(#D8D8D8, "Envelope Lower 1", group=G_ENG_COL)
color CUSTOM_FIX_U1 = input.color(#D0D0D0, "Fixed Upper 1", group=G_ENG_COL)
color CUSTOM_FIX_L1 = input.color(#D0D0D0, "Fixed Lower 1", group=G_ENG_COL)
color CUSTOM_FIX_U2 = input.color(#AAAAAA, "Fixed Upper 2", group=G_ENG_COL)
color CUSTOM_FIX_L2 = input.color(#AAAAAA, "Fixed Lower 2", group=G_ENG_COL)
color CUSTOM_TOKYO_OPEN_COLOR = input.color(#DDDDDD, "Tokyo Open", group=G_OPEN_COL)
color CUSTOM_SHANGHAI_OPEN_COLOR = input.color(#BBBBBB, "Shanghai Open", group=G_OPEN_COL)
color CUSTOM_LONDON_OPEN_COLOR = input.color(#999999, "London Open", group=G_OPEN_COL)
color CUSTOM_NY_OPEN_COLOR = input.color(#777777, "New York Open", group=G_OPEN_COL)
color CUSTOM_COMEX_OPEN_COLOR = input.color(#555555, "COMEX Open", group=G_OPEN_COL)
color CUSTOM_ASIA_OPEN_COLOR = input.color(#AAAAAA, "Asia Reopen", group=G_OPEN_COL)

// Colors used by plots, tags, and markers
color DAY_COLOR = f_line_color(#FFFFFF, #161616, CUSTOM_DAY_COLOR)
color LONDON_COLOR = f_line_color(#D0D0D0, #383838, CUSTOM_LONDON_COLOR)
color US_COLOR = f_line_color(#A0A0A0, #606060, CUSTOM_US_COLOR)
color WIN_COLOR = f_line_color(#FFFFFF, #000000, CUSTOM_WIN_COLOR)
color WIN_U1 = f_line_color(#C0C0C0, #555555, CUSTOM_WIN_U1)
color WIN_L1 = f_line_color(#C0C0C0, #555555, CUSTOM_WIN_L1)
color WIN_U2 = f_line_color(#777777, #888888, CUSTOM_WIN_U2)
color WIN_L2 = f_line_color(#777777, #888888, CUSTOM_WIN_L2)
color LOW_COLOR = f_line_color(#E0E0E0, #303030, CUSTOM_LOW_COLOR)
color HIGH_COLOR = f_line_color(#B0B0B0, #686868, CUSTOM_HIGH_COLOR)
color ENGINE_COLOR = f_line_color(#FFFFFF, #202020, CUSTOM_ENGINE_COLOR)
color ENV_U1 = f_line_color(#D8D8D8, #666666, CUSTOM_ENV_U1)
color ENV_L1 = f_line_color(#D8D8D8, #666666, CUSTOM_ENV_L1)
color FIX_U1 = f_line_color(#D0D0D0, #777777, CUSTOM_FIX_U1)
color FIX_L1 = f_line_color(#D0D0D0, #777777, CUSTOM_FIX_L1)
color FIX_U2 = f_line_color(#AAAAAA, #999999, CUSTOM_FIX_U2)
color FIX_L2 = f_line_color(#AAAAAA, #999999, CUSTOM_FIX_L2)
color TOKYO_OPEN_COLOR = f_line_color(#DDDDDD, #333333, CUSTOM_TOKYO_OPEN_COLOR)
color SHANGHAI_OPEN_COLOR = f_line_color(#BBBBBB, #555555, CUSTOM_SHANGHAI_OPEN_COLOR)
color LONDON_OPEN_COLOR = f_line_color(#999999, #777777, CUSTOM_LONDON_OPEN_COLOR)
color NY_OPEN_COLOR = f_line_color(#777777, #999999, CUSTOM_NY_OPEN_COLOR)
color COMEX_OPEN_COLOR = f_line_color(#555555, #BBBBBB, CUSTOM_COMEX_OPEN_COLOR)
color ASIA_OPEN_COLOR = f_line_color(#AAAAAA, #666666, CUSTOM_ASIA_OPEN_COLOR)

// Common values
float src = hlc3
float barVolume = nz(volume, 0.0)
float atr = ta.atr(anchorAtrLen)

// Trading day
int dayKey =
     year(time, dayTimezone) * 10000 +
     month(time, dayTimezone) * 100 +
     dayofmonth(time, dayTimezone)
bool newDay = bar_index == 0 or dayKey != dayKey[1]

var float todayHigh = na
var float todayLow = na
var float previousDayHigh = na
var float previousDayLow = na
var int previousDayKey = na

if barstate.isfirst
    todayHigh := high
    todayLow := low
else if newDay
    previousDayHigh := todayHigh
    previousDayLow := todayLow
    previousDayKey := dayKey[1]
    todayHigh := high
    todayLow := low
else
    todayHigh := math.max(todayHigh, high)
    todayLow := math.min(todayLow, low)

float referenceHigh = na
float referenceLow = na
if not na(previousDayHigh)
    referenceHigh := math.max(todayHigh, previousDayHigh)
else
    referenceHigh := todayHigh
if not na(previousDayLow)
    referenceLow := math.min(todayLow, previousDayLow)
else
    referenceLow := todayLow

// Sessions and VWAP accumulators
bool inLondon = not na(time(timeframe.period, londonSession, londonTimezone))
bool inUS = not na(time(timeframe.period, usSession, usTimezone))

var float dayPV = 0.0
var float dayVol = 0.0
var float londonPV = 0.0
var float londonPV2 = 0.0
var float londonVol = 0.0
var float usPV = 0.0
var float usPV2 = 0.0
var float usVol = 0.0

if newDay
    dayPV := 0.0
    dayVol := 0.0
    londonPV := 0.0
    londonPV2 := 0.0
    londonVol := 0.0
    usPV := 0.0
    usPV2 := 0.0
    usVol := 0.0

dayPV += src * barVolume
dayVol += barVolume
float dayVWAP = dayVol > 0 ? dayPV / dayVol : na

if inLondon
    londonPV += src * barVolume
    londonPV2 += src * src * barVolume
    londonVol += barVolume
float londonVWAP = londonVol > 0 ? londonPV / londonVol : na

if inUS
    usPV += src * barVolume
    usPV2 += src * src * barVolume
    usVol += barVolume
float usVWAP = usVol > 0 ? usPV / usVol : na

float londonVariance = na
float londonSigma = na
if londonVol > 0
    londonVariance := math.max(londonPV2 / londonVol - londonVWAP * londonVWAP, 0.0)
    londonSigma := math.sqrt(londonVariance)

float usVariance = na
float usSigma = na
if usVol > 0
    usVariance := math.max(usPV2 / usVol - usVWAP * usVWAP, 0.0)
    usSigma := math.sqrt(usVariance)

// Winning session
bool londonAvailable = londonVol > 0
bool usAvailable = usVol > 0
bool londonLeads = false
bool usLeads = false

if londonAvailable and not usAvailable
    londonLeads := true
else if usAvailable and not londonAvailable
    usLeads := true
else if londonAvailable and usAvailable
    londonLeads := londonVol > usVol
    usLeads := usVol > londonVol

int winningId = 0
float winningVWAP = na
float winningSigma = na
string winningName = "NONE"
color winningColor = T_NEUTRAL

if londonLeads
    winningId := 1
    winningVWAP := londonVWAP
    winningSigma := londonSigma
    winningName := "LONDON"
    winningColor := T_LONDON
else if usLeads
    winningId := 2
    winningVWAP := usVWAP
    winningSigma := usSigma
    winningName := "US"
    winningColor := T_US

bool winnerChanged = winningId != nz(winningId[1], 0)

float winnerUpper1 = na
float winnerLower1 = na
float winnerUpper2 = na
float winnerLower2 = na
if winningId != 0 and not na(winningSigma)
    winnerUpper1 := winningVWAP + deviation1 * winningSigma
    winnerLower1 := winningVWAP - deviation1 * winningSigma
    winnerUpper2 := winningVWAP + deviation2 * winningSigma
    winnerLower2 := winningVWAP - deviation2 * winningSigma

float winnerZ = na
if not na(winningSigma) and winningSigma > 0
    winnerZ := (close - winningVWAP) / winningSigma

// Confirmed pivots near current or previous trading-day extremes
float pivotHigh = ta.pivothigh(high, anchorPivotLen, anchorPivotLen)
float pivotLow = ta.pivotlow(low, anchorPivotLen, anchorPivotLen)
int actualPivotBar = bar_index - anchorPivotLen
float pivotATR = atr[anchorPivotLen]
int pivotDayKey =
     year(time[anchorPivotLen], dayTimezone) * 10000 +
     month(time[anchorPivotLen], dayTimezone) * 100 +
     dayofmonth(time[anchorPivotLen], dayTimezone)
bool pivotInsideTwoDayWindow = pivotDayKey == dayKey or pivotDayKey == previousDayKey

float highDistanceATR = na
float lowDistanceATR = na
if not na(pivotHigh) and not na(pivotATR) and pivotATR > 0
    highDistanceATR := math.abs(referenceHigh - pivotHigh) / pivotATR
if not na(pivotLow) and not na(pivotATR) and pivotATR > 0
    lowDistanceATR := math.abs(pivotLow - referenceLow) / pivotATR

bool qualifyingHigh =
     not na(pivotHigh) and pivotInsideTwoDayWindow and
     not na(highDistanceATR) and highDistanceATR <= nearExtremeATR
bool qualifyingLow =
     not na(pivotLow) and pivotInsideTwoDayWindow and
     not na(lowDistanceATR) and lowDistanceATR <= nearExtremeATR

var bool lowAnchorActive = false
var int lowAnchorBar = na
var int lowAnchorDayKey = na
var float lowAnchorPrice = na
var float lowAnchorPV = 0.0
var float lowAnchorVol = 0.0
var float lowAnchorDistance = na

var bool highAnchorActive = false
var int highAnchorBar = na
var int highAnchorDayKey = na
var float highAnchorPrice = na
var float highAnchorPV = 0.0
var float highAnchorVol = 0.0
var float highAnchorDistance = na

bool lowAnchorStillValid = lowAnchorDayKey == dayKey or lowAnchorDayKey == previousDayKey
bool highAnchorStillValid = highAnchorDayKey == dayKey or highAnchorDayKey == previousDayKey

if lowAnchorActive and not lowAnchorStillValid
    lowAnchorActive := false
    lowAnchorBar := na
    lowAnchorDayKey := na
    lowAnchorPrice := na
    lowAnchorPV := 0.0
    lowAnchorVol := 0.0
    lowAnchorDistance := na

if highAnchorActive and not highAnchorStillValid
    highAnchorActive := false
    highAnchorBar := na
    highAnchorDayKey := na
    highAnchorPrice := na
    highAnchorPV := 0.0
    highAnchorVol := 0.0
    highAnchorDistance := na

bool newLowAnchor =
     qualifyingLow and
     (not lowAnchorActive or actualPivotBar > lowAnchorBar)

if newLowAnchor
    lowAnchorActive := true
    lowAnchorBar := actualPivotBar
    lowAnchorDayKey := pivotDayKey
    lowAnchorPrice := pivotLow
    lowAnchorDistance := lowDistanceATR
    lowAnchorPV := 0.0
    lowAnchorVol := 0.0
    for i = 0 to anchorPivotLen
        float histVolLow = nz(volume[i], 0.0)
        lowAnchorPV += hlc3[i] * histVolLow
        lowAnchorVol += histVolLow

bool newHighAnchor =
     qualifyingHigh and
     (not highAnchorActive or actualPivotBar > highAnchorBar)

if newHighAnchor
    highAnchorActive := true
    highAnchorBar := actualPivotBar
    highAnchorDayKey := pivotDayKey
    highAnchorPrice := pivotHigh
    highAnchorDistance := highDistanceATR
    highAnchorPV := 0.0
    highAnchorVol := 0.0
    for i = 0 to anchorPivotLen
        float histVolHigh = nz(volume[i], 0.0)
        highAnchorPV += hlc3[i] * histVolHigh
        highAnchorVol += histVolHigh

if lowAnchorActive and not newLowAnchor
    lowAnchorPV += src * barVolume
    lowAnchorVol += barVolume
if highAnchorActive and not newHighAnchor
    highAnchorPV += src * barVolume
    highAnchorVol += barVolume

float lowAVWAP = lowAnchorActive and lowAnchorVol > 0 ? lowAnchorPV / lowAnchorVol : na
float highAVWAP = highAnchorActive and highAnchorVol > 0 ? highAnchorPV / highAnchorVol : na

// Anchor states
float anchorTolerance = atr * anchorTestATR
string lowState = "WAIT"
color lowStateColor = T_NEUTRAL
if not na(lowAVWAP)
    if close > lowAVWAP + anchorTolerance
        lowState := "HOLDS"
        lowStateColor := T_LOW
    else if close < lowAVWAP - anchorTolerance
        lowState := "LOST"
        lowStateColor := T_HIGH
    else
        lowState := "TEST"
        lowStateColor := T_DAY

string highState = "WAIT"
color highStateColor = T_NEUTRAL
if not na(highAVWAP)
    if close < highAVWAP - anchorTolerance
        highState := "REJECTS"
        highStateColor := T_HIGH
    else if close > highAVWAP + anchorTolerance
        highState := "RECLAIM"
        highStateColor := T_LOW
    else
        highState := "TEST"
        highStateColor := T_DAY

// Sentiment
float sentimentScore = 0.0
float sentimentVotes = 0.0

if not na(dayVWAP)
    sentimentVotes += 1.0
    if close > dayVWAP
        sentimentScore += 1.0
    else if close < dayVWAP
        sentimentScore -= 1.0

if not na(dayVWAP[sentimentSlopeBars])
    sentimentVotes += 1.0
    if dayVWAP > dayVWAP[sentimentSlopeBars]
        sentimentScore += 1.0
    else if dayVWAP < dayVWAP[sentimentSlopeBars]
        sentimentScore -= 1.0

if not na(winningVWAP)
    sentimentVotes += 1.0
    if close > winningVWAP
        sentimentScore += 1.0
    else if close < winningVWAP
        sentimentScore -= 1.0

if not na(lowAVWAP)
    sentimentVotes += 1.0
    if close > lowAVWAP
        sentimentScore += 1.0
    else if close < lowAVWAP
        sentimentScore -= 1.0

if not na(highAVWAP)
    sentimentVotes += 1.0
    if close > highAVWAP
        sentimentScore += 1.0
    else if close < highAVWAP
        sentimentScore -= 1.0

float sentimentNormalized = sentimentVotes > 0 ? sentimentScore / sentimentVotes : 0.0
string sentiment = "NEUTRAL"
color sentimentColor = T_NEUTRAL

if sentimentNormalized >= 0.60
    sentiment := "STRONG BULL"
    sentimentColor := T_LOW
else if sentimentNormalized >= 0.20
    sentiment := "BULL"
    sentimentColor := T_TEXT
else if sentimentNormalized <= -0.60
    sentiment := "STRONG BEAR"
    sentimentColor := T_HIGH
else if sentimentNormalized <= -0.20
    sentiment := "BEAR"
    sentimentColor := T_NEUTRAL
else
    sentiment := "NEUTRAL"
    sentimentColor := T_NEUTRAL

string activeSession = "OUTSIDE"
if inLondon and inUS
    activeSession := "LDN + US"
else if inLondon
    activeSession := "LONDON"
else if inUS
    activeSession := "US"

// Reference VWAP engine
float enginePx = engineSource == "HL2" ? hl2 : hlc3
float engineVol = nz(volume, 0.0)
float rollingVWAP = ta.vwma(enginePx, engineLength)
float rollingMoment2 = ta.vwma(enginePx * enginePx, engineLength)

var float enginePV = 0.0
var float engineV = 0.0
var float enginePV2 = 0.0
if newDay
    enginePV := 0.0
    engineV := 0.0
    enginePV2 := 0.0
enginePV += enginePx * engineVol
engineV += engineVol
enginePV2 += enginePx * enginePx * engineVol

float engineSessionVWAP = engineV > 0 ? enginePV / engineV : na
float engineSessionVariance = engineV > 0 ? math.max(enginePV2 / engineV - engineSessionVWAP * engineSessionVWAP, 0.0) : na

int highBars = ta.highestbars(high, swingPeriod)
int lowBars = ta.lowestbars(low, swingPeriod)
var int swingHighBar = na
var int swingLowBar = na
var int swingDirection = 0
var float swingPV = 0.0
var float swingV = 0.0
var float swingPV2 = 0.0

if highBars == 0
    swingHighBar := bar_index
if lowBars == 0
    swingLowBar := bar_index
int nextDirection = na(swingHighBar) or na(swingLowBar) ? 0 : swingHighBar > swingLowBar ? 1 : -1
if nextDirection != 0 and nextDirection != swingDirection
    swingDirection := nextDirection
    swingPV := 0.0
    swingV := 0.0
    swingPV2 := 0.0

float engineATR = ta.atr(50)
float engineATRAvg = ta.rma(engineATR, 50)
float atrRatio = not na(engineATRAvg) and engineATRAvg > 0 ? engineATR / engineATRAvg : 1.0
float aptRaw = useAdapt ? baseAPT / math.pow(atrRatio, volBias) : baseAPT
float apt = math.max(5.0, math.min(300.0, aptRaw))
float alpha = 2.0 / (apt + 1.0)
swingPV := (1.0 - alpha) * swingPV + alpha * enginePx * engineVol
swingV := (1.0 - alpha) * swingV + alpha * engineVol
swingPV2 := (1.0 - alpha) * swingPV2 + alpha * enginePx * enginePx * engineVol

float swingVWAP = swingV > 0 ? swingPV / swingV : na
float swingVariance = swingV > 0 ? math.max(swingPV2 / swingV - swingVWAP * swingVWAP, 0.0) : na
float engineVWAP = engineMode == "Rolling" ? rollingVWAP : engineMode == "Session" ? engineSessionVWAP : swingVWAP
float engineVariance = engineMode == "Rolling" ? (not na(rollingVWAP) ? math.max(rollingMoment2 - rollingVWAP * rollingVWAP, 0.0) : na) : engineMode == "Session" ? engineSessionVariance : swingVariance
float engineSigma = math.sqrt(engineVariance)

[engineDIPlus, engineDIMinus, engineADX] = ta.dmi(adxLength, adxSmooth)
float volumeAverage = ta.sma(engineVol, 20)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0 ? engineVol / volumeAverage : 1.0
float adxMultiplier = 1.0 + nz(engineADX, 0.0) / 100.0 * adxInfluence
float dynamicMultiplier = baseMult * (1.0 + math.max(0.0, volumeRatio - 1.0) * volSens) * adxMultiplier
float upper1 = ta.ema(engineVWAP + dynamicMultiplier * engineSigma, bandSmooth)
float lower1 = ta.ema(engineVWAP - dynamicMultiplier * engineSigma, bandSmooth)

// Plots
plot(showDayVWAP ? dayVWAP : na, title="Day VWAP", color=DAY_COLOR, linewidth=3, display=display.pane)
plot(showLondonVWAP ? londonVWAP : na, title="London VWAP", color=LONDON_COLOR, linewidth=3, display=display.pane)
plot(showUSVWAP ? usVWAP : na, title="US VWAP", color=US_COLOR, linewidth=3, display=display.pane)
plot(showLondonVWAP and emphasizeVolumeLeader and londonLeads ? londonVWAP : na, title="London Winner", color=LONDON_COLOR, linewidth=4, display=display.pane)
plot(showUSVWAP and emphasizeVolumeLeader and usLeads ? usVWAP : na, title="US Winner", color=US_COLOR, linewidth=4, display=display.pane)

float winningPlotVWAP = winnerChanged ? na : winningVWAP
float winningPlotUpper1 = winnerChanged ? na : winnerUpper1
float winningPlotLower1 = winnerChanged ? na : winnerLower1
float winningPlotUpper2 = winnerChanged ? na : winnerUpper2
float winningPlotLower2 = winnerChanged ? na : winnerLower2

pWinner = plot(showWinningVWAP ? winningPlotVWAP : na, title="Winning VWAP", color=WIN_COLOR, linewidth=4, style=plot.style_linebr, display=display.pane)
pWinnerUpper1 = plot(showWinningBands ? winningPlotUpper1 : na, title="Winner +1 Sigma", color=WIN_U1, linewidth=1, style=plot.style_linebr, display=display.pane)
pWinnerLower1 = plot(showWinningBands ? winningPlotLower1 : na, title="Winner -1 Sigma", color=WIN_L1, linewidth=1, style=plot.style_linebr, display=display.pane)
pWinnerUpper2 = plot(showWinningBands ? winningPlotUpper2 : na, title="Winner +2 Sigma", color=WIN_U2, linewidth=1, style=plot.style_linebr, display=display.pane)
pWinnerLower2 = plot(showWinningBands ? winningPlotLower2 : na, title="Winner -2 Sigma", color=WIN_L2, linewidth=1, style=plot.style_linebr, display=display.pane)

float lowPlot = showAnchorVWAP and lowAnchorActive and not newLowAnchor ? lowAVWAP : na
float highPlot = showAnchorVWAP and highAnchorActive and not newHighAnchor ? highAVWAP : na
plot(lowPlot, title="2D Low AVWAP", color=LOW_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)
plot(highPlot, title="2D High AVWAP", color=HIGH_COLOR, linewidth=3, style=plot.style_linebr, display=display.pane)

plot(showEngine ? engineVWAP : na, "Reference VWAP", color=ENGINE_COLOR, linewidth=3, style=plot.style_linebr)
plot(showDynamic ? upper1 : na, "Envelope Upper 1", color=ENV_U1, style=plot.style_linebr)
plot(showDynamic ? lower1 : na, "Envelope Lower 1", color=ENV_L1, style=plot.style_linebr)
plot(showClassic ? engineVWAP + dev1 * engineSigma : na, "Fixed Upper 1", color=FIX_U1, style=plot.style_linebr)
plot(showClassic ? engineVWAP - dev1 * engineSigma : na, "Fixed Lower 1", color=FIX_L1, style=plot.style_linebr)
plot(showClassic and showC2 ? engineVWAP + dev2 * engineSigma : na, "Fixed Upper 2", color=FIX_U2, style=plot.style_linebr)
plot(showClassic and showC2 ? engineVWAP - dev2 * engineSigma : na, "Fixed Lower 2", color=FIX_L2, style=plot.style_linebr)

// Right edge labels
f_right_tag(label previous, bool visible, float value, string title, color lineColor) =>
    label result = previous
    color tagText = color.r(lineColor) * 299 + color.g(lineColor) * 587 + color.b(lineColor) * 114 > 128000 ? color.black : color.white
    if visible and not na(value)
        string caption = showLabelPrice ? title + "  " + str.tostring(value, format.mintick) : title
        if na(result)
            result := label.new(bar_index + rightLabelOffset, value, caption, xloc=xloc.bar_index, style=label.style_label_left, color=lineColor, textcolor=tagText, size=size.tiny)
        else
            label.set_xy(result, bar_index + rightLabelOffset, value)
            label.set_text(result, caption)
            label.set_color(result, lineColor)
            label.set_textcolor(result, tagText)
    else if not na(result)
        label.delete(result)
        result := na
    result

var label tagDay = na
var label tagLondon = na
var label tagUS = na
var label tagWinner = na
var label tagWinnerU1 = na
var label tagWinnerL1 = na
var label tagWinnerU2 = na
var label tagWinnerL2 = na
var label tagLow = na
var label tagHigh = na
var label tagEngine = na
var label tagEnvU = na
var label tagEnvL = na
var label tagFixU1 = na
var label tagFixL1 = na
var label tagFixU2 = na
var label tagFixL2 = na

if barstate.islast and showRightLabels
    tagDay := f_right_tag(tagDay, showDayVWAP, dayVWAP, "DAY", DAY_COLOR)
    tagLondon := f_right_tag(tagLondon, showLondonVWAP and not (showWinningVWAP and londonLeads), londonVWAP, "LONDON", LONDON_COLOR)
    tagUS := f_right_tag(tagUS, showUSVWAP and not (showWinningVWAP and usLeads), usVWAP, "US", US_COLOR)
    tagWinner := f_right_tag(tagWinner, showWinningVWAP, winningPlotVWAP, winningName + "  🟢", WIN_COLOR)
    tagWinnerU1 := f_right_tag(tagWinnerU1, showWinningBands, winningPlotUpper1, "W +1", WIN_U1)
    tagWinnerL1 := f_right_tag(tagWinnerL1, showWinningBands, winningPlotLower1, "W -1", WIN_L1)
    tagWinnerU2 := f_right_tag(tagWinnerU2, showWinningBands, winningPlotUpper2, "W +2", WIN_U2)
    tagWinnerL2 := f_right_tag(tagWinnerL2, showWinningBands, winningPlotLower2, "W -2", WIN_L2)
    tagLow := f_right_tag(tagLow, showAnchorVWAP, lowPlot, "2D LOW", LOW_COLOR)
    tagHigh := f_right_tag(tagHigh, showAnchorVWAP, highPlot, "2D HIGH", HIGH_COLOR)
    tagEngine := f_right_tag(tagEngine, showEngine, engineVWAP, "REF " + engineMode, ENGINE_COLOR)
    tagEnvU := f_right_tag(tagEnvU, showDynamic, upper1, "ENV +", ENV_U1)
    tagEnvL := f_right_tag(tagEnvL, showDynamic, lower1, "ENV -", ENV_L1)
    tagFixU1 := f_right_tag(tagFixU1, showClassic, engineVWAP + dev1 * engineSigma, "FIX +1", FIX_U1)
    tagFixL1 := f_right_tag(tagFixL1, showClassic, engineVWAP - dev1 * engineSigma, "FIX -1", FIX_L1)
    tagFixU2 := f_right_tag(tagFixU2, showClassic and showC2, engineVWAP + dev2 * engineSigma, "FIX +2", FIX_U2)
    tagFixL2 := f_right_tag(tagFixL2, showClassic and showC2, engineVWAP - dev2 * engineSigma, "FIX -2", FIX_L2)

// Dashboard
var table dash = table.new(position.top_right, 2, 7, bgcolor=T_PANEL, frame_color=T_BORDER, frame_width=1, border_color=T_BORDER, border_width=1)

if barstate.islast
    table.clear(dash, 0, 0, 1, 6)
    if showDashboard
        table.cell(dash, 0, 0, "AVWAP", text_color=T_DAY, text_size=size.small, bgcolor=T_HEADER)
        table.cell(dash, 1, 0, activeSession, text_color=T_TEXT, text_size=size.small, bgcolor=T_HEADER)

        table.cell(dash, 0, 1, "DAY", text_color=T_DAY, text_size=size.small)
        table.cell(dash, 1, 1, na(dayVWAP) ? "—" : str.tostring(dayVWAP, format.mintick), text_color=T_DAY, text_size=size.small)

        string winnerDisplay = "—"
        if not na(winningVWAP)
            winnerDisplay := winningName + " " + str.tostring(winningVWAP, format.mintick)
            if not na(winnerZ)
                winnerDisplay += " | " + str.tostring(winnerZ, "#.2") + "σ"
        table.cell(dash, 0, 2, "WINNER", text_color=winningColor, text_size=size.small)
        table.cell(dash, 1, 2, winnerDisplay, text_color=winningColor, text_size=size.small)

        string lowDisplay = "—"
        if not na(lowAVWAP)
            lowDisplay := str.tostring(lowAVWAP, format.mintick) + " | " + lowState
        table.cell(dash, 0, 3, "2D LOW", text_color=T_LOW, text_size=size.small)
        table.cell(dash, 1, 3, lowDisplay, text_color=lowStateColor, text_size=size.small)

        string highDisplay = "—"
        if not na(highAVWAP)
            highDisplay := str.tostring(highAVWAP, format.mintick) + " | " + highState
        table.cell(dash, 0, 4, "2D HIGH", text_color=T_HIGH, text_size=size.small)
        table.cell(dash, 1, 4, highDisplay, text_color=highStateColor, text_size=size.small)

        string sentimentDisplay = sentiment + " | " + str.tostring(sentimentNormalized * 100.0, "#") + "%"
        table.cell(dash, 0, 5, "SENTIMENT", text_color=T_NEUTRAL, text_size=size.small)
        table.cell(dash, 1, 5, sentimentDisplay, text_color=sentimentColor, text_size=size.small)

        table.cell(dash, 0, 6, "ENGINE " + engineMode, text_color=T_ENGINE, text_size=size.small)
        table.cell(dash, 1, 6, na(engineVWAP) ? "—" : str.tostring(engineVWAP, format.mintick), text_color=T_ENGINE, text_size=size.small)

// Alerts
alertcondition(newLowAnchor, "New 2D Low AVWAP", "New near-extreme 2D Low AVWAP confirmed")
alertcondition(newHighAnchor, "New 2D High AVWAP", "New near-extreme 2D High AVWAP confirmed")
alertcondition(winnerChanged and winningId == 1, "London Takes Volume Lead", "London VWAP has taken the session volume lead")
alertcondition(winnerChanged and winningId == 2, "US Takes Volume Lead", "US VWAP has taken the session volume lead")

// Exchange open markers
f_open_event(string tz, int openHour, int openMinute) =>
    int marketYear = year(time, tz)
    int marketMonth = month(time, tz)
    int marketDay = dayofmonth(time, tz)
    int openTime = timestamp(tz, marketYear, marketMonth, marketDay, openHour, openMinute)
    time <= openTime and time_close > openTime

f_draw_open(bool condition, string txt, color col) =>
    if condition and barstate.isnew
        line.new(x1=bar_index, y1=low, x2=bar_index, y2=high, xloc=xloc.bar_index, extend=extend.both, color=color.new(col, 35), style=line.style_dashed, width=1)
        if showOpenLabels
            label.new(x=bar_index, y=high, text="│ " + txt, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_none, textcolor=col, size=size.tiny)

bool tokyoOpen = showTokyoOpen and f_open_event("Asia/Tokyo", 8, 45)
bool shanghaiOpen = showShanghaiOpen and f_open_event("Asia/Shanghai", 9, 0)
bool londonOpenMarker = showLondonOpen and f_open_event("Europe/London", 8, 0)
bool newYorkOpenMarker = showNewYorkOpen and f_open_event("America/New_York", 9, 30)
bool comexOpenMarker = showComexOpen and f_open_event("America/New_York", 8, 20)
bool asiaReopen = showAsiaReopen and f_open_event("Europe/Berlin", 0, 0)

f_draw_open(tokyoOpen, "TOKYO / OSE", TOKYO_OPEN_COLOR)
f_draw_open(shanghaiOpen, "SHANGHAI", SHANGHAI_OPEN_COLOR)
f_draw_open(londonOpenMarker, "LONDON", LONDON_OPEN_COLOR)
f_draw_open(newYorkOpenMarker, "NEW YORK", NY_OPEN_COLOR)
f_draw_open(comexOpenMarker, "COMEX GOLD", COMEX_OPEN_COLOR)
f_draw_open(asiaReopen, "ASIA / SYDNEY REOPEN", ASIA_OPEN_COLOR)
````
