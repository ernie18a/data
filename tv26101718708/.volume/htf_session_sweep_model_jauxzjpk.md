# HTF Session Sweep Model

- url: https://www.tradingview.com/script/JaUxzjPK-HTF-Session-Sweep-Model/
- type: indicator
- pine_id: PUB;48572cc0729743f5b095bfe5d4d105ba
- version: 3.0

## Description

HTF Session Sweep Model [NICK789]

The HTF Session Sweep Model is a session-based market structure tool designed to help traders observe how price interacts with the previous confirmed higher-timeframe candle during active trading sessions.

This script was created because session trading can become messy when traders manually mark multiple highs, lows, opens, boxes, sweeps, breakouts, and traps across different timeframes. Instead of adding unrelated indicators together, this model uses one central reference point: the previous confirmed HTF candle. Once an enabled session begins, the script maps that HTF candle’s high, low, midpoint, and optional session open level onto the chart. Price action during that session is then classified around that reference range.

The purpose of the script is not to predict price. The purpose is to provide a clean framework for reading session behaviour around a higher-timeframe range.

Core Concept

The script is built around the idea that the previous higher-timeframe candle can provide useful reference levels for intraday price behaviour. Its high and low can act as areas where liquidity may be taken, where breakouts may develop, or where failed breakouts may occur.

The model does not project the HTF candle before the session opens. It activates when an enabled session opens. At that point, it takes the most recent fully confirmed HTF candle and uses it as the active session reference.

This creates a consistent question for the trader:

How is price reacting around the previous confirmed HTF candle during the current session?

What Makes This Script Original

This script is not designed as a simple combination of unrelated indicators. The components are connected through one session-based model:

1. Session engine
   The script allows users to enable Asia, London, and New York sessions. Each session can use its own time window and timezone setting.

2. HTF reference map
   At the start of an enabled session, the script maps the previous confirmed HTF candle. This includes the HTF high, low, midpoint, optional candle body, and optional session open level.

3. Sweep model
   The script checks whether price sweeps above the HTF high or below the HTF low. Users can choose between a basic wick sweep or a stricter sweep that requires price to close back inside the HTF range.

4. Delivery shift confirmation
   After a sweep occurs, the script can wait for a delivery shift confirmation before marking a sweep entry. A bearish confirmation requires price to break below a recent low range after a high sweep. A bullish confirmation requires price to break above a recent high range after a low sweep.

5. Breakout model
   If price closes and holds outside the HTF range, the script can classify the move as a breakout. Users can set how many bars price must hold beyond the range.

6. Displacement filter
   The breakout model can optionally require stronger candle movement by comparing the candle body against ATR. This helps filter weaker breaks that do not show meaningful displacement.

7. Failed breakout trap model
   If price breaks beyond the HTF high or low and then returns back inside the range, the script can classify that move as a failed breakout trap. A Bull Trap means price broke above the HTF high and failed back inside. A Bear Trap means price broke below the HTF low and failed back inside.

These parts work together because they all answer the same question: did price sweep the HTF range, accept beyond it, or fail after breaking it?

How The Script Calculates The Model

When a new enabled session begins, the script requests the previous confirmed candle from the selected higher timeframe. The selected HTF may be adjusted by the user, such as 1H, 2H, 4H, Daily, or Weekly.

The script then stores the following values:

* Previous HTF open
* Previous HTF high
* Previous HTF low
* Previous HTF close
* Previous HTF midpoint
* Current session open

These values become the session reference map.

During the active session, the script checks price against the HTF high and low.

High Sweep:
A high sweep is detected when price trades above the previous HTF high.

Low Sweep:
A low sweep is detected when price trades below the previous HTF low.

Close Back Inside Sweep Mode:
When this stricter mode is selected, a high sweep requires price to close back below the HTF high. A low sweep requires price to close back above the HTF low.

Sweep Entry:
A sweep entry is not triggered by the sweep alone. After a sweep, the script waits for a delivery shift confirmation using the selected lookback length.

Breakout Long:
A breakout long is detected when price closes above the HTF high and holds above it for the selected number of bars.

Breakout Short:
A breakout short is detected when price closes below the HTF low and holds below it for the selected number of bars.

Bull Trap:
A bull trap is detected when price breaks above the HTF high but later closes back below the HTF high.

Bear Trap:
A bear trap is detected when price breaks below the HTF low but later closes back above the HTF low.

Volume Filter:
The optional volume filter compares current volume against a moving average of volume multiplied by the selected volume multiplier. When enabled, sweep and breakout conditions must also pass the volume filter.

Bar Close Confirmation:
The script includes an option to confirm signals only after the bar closes. This is enabled by default to make signals more stable for alerts and historical review.

How To Use This Script

1. Choose the reference timeframe
   Select the HTF candle you want to use as the session reference. Intraday traders may use 1H, 2H, or 4H. Higher-timeframe traders may prefer Daily or Weekly.

2. Enable the sessions you trade
   The script supports Asia, London, and New York sessions. Users can enable or disable each session and adjust the session window and timezone.

3. Watch the HTF range during the session
   Once the session opens, the script draws the previous confirmed HTF candle range. The high and low are the main reaction levels.

4. Read price behaviour around the range
   If price sweeps a level and returns inside, it may indicate a liquidity sweep.
   If price closes and holds outside the range, it may indicate breakout continuation.
   If price breaks outside and then returns inside, it may indicate a failed breakout trap.

5. Use the labels as classifications, not automatic trade commands
   The labels are designed to classify price behaviour. They are not guaranteed buy or sell signals.

6. Combine with your own confirmation
   Users should combine this model with their own market context, risk management, higher-timeframe bias, and execution plan.

Main Visual Elements

HTF Range Box:
Shows the previous confirmed HTF candle range during the active session.

HTF Candle Display:
Optionally displays the previous HTF candle body and wick on the chart.

High and Low Lines:
Marks the previous HTF high and low.

Midpoint Line:
Marks the midpoint of the HTF range.

Session Open Line:
Marks the price at the open of the active session.

Sweep Marks:
Marks when price sweeps above or below the HTF range.

Sweep Entry Marks:
Marks when a sweep is followed by delivery shift confirmation.

Breakout Marks:
Marks when price closes and holds outside the HTF range.

Trap Marks:
Marks failed breakout conditions as Bull Trap or Bear Trap.

Dashboard:
Optional compact dashboard showing the current session, HTF reference, confirmation mode, state, high, low, and midpoint.

Important Settings

Reference HTF Candle:
Controls which higher timeframe is used for the previous confirmed candle reference.

Sweep Mode:
Choose between Wick Sweep or Wick Sweep + Close Back Inside.

Confirm Signals On Bar Close:
When enabled, signals confirm after candle close. This is recommended for cleaner historical review and alerts.

Delivery Shift Lookback:
Controls how many bars are used to confirm a shift after a sweep.

Breakout Hold Bars:
Controls how many bars price must remain outside the HTF range before a breakout is confirmed.

Displacement Filter:
Requires the candle body to be large enough compared with ATR before confirming a breakout.

Volume Filter:
Optional filter requiring current volume to exceed average volume by the selected multiplier.

Keep Historical Sessions:
When disabled, the chart stays cleaner by only showing the current/latest session map. When enabled, historical session maps can remain visible, with a limit to reduce chart clutter.

Visual Modes:
Clean mode is designed for normal use.
Stealth mode reduces visual intensity.
Debug mode makes internal reference levels easier to inspect.

Alerts

The script includes alert conditions for:

* HTF high swept
* HTF low swept
* Sweep short
* Sweep long
* Breakout long
* Breakout short
* Bull trap
* Bear trap
* Master alert for any model event

The master alert is included so users can create one alert condition instead of setting up many separate alerts.

Recommended Use

This script is best suited for traders who use session timing, higher-timeframe ranges, liquidity sweeps, breakout continuation, and failed breakout concepts.

It may be useful on intraday charts where Asia, London, and New York session behaviour matters. It can also be adjusted for different markets and timeframes by changing the reference HTF and session settings.

Limitations

This script does not predict future price movement. It classifies how price behaves around the previous confirmed HTF candle during active sessions.

A sweep does not guarantee a reversal.
A breakout does not guarantee continuation.
A trap does not guarantee a full trend change.
Volume data may behave differently depending on the market and symbol.
Session behaviour can vary across forex, crypto, futures, indices, and stocks.

This tool should be used as a market structure framework, not as a standalone trading system.

Originality And Usefulness Statement

The originality of this script is in how it combines session timing, previous confirmed HTF candle mapping, sweep classification, breakout confirmation, and failed breakout detection into one connected workflow.

The script is useful because it gives traders a structured way to observe whether price is taking liquidity, accepting outside a higher-timeframe range, or failing after a breakout attempt. Each component supports the same central model rather than acting as an unrelated indicator mashup.

Disclaimer

This indicator is for educational and analytical use only. It is not financial advice and does not guarantee trading results. Users are responsible for their own trading decisions, testing, and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("HTF Session Sweep Model",
     shorttitle="HTF Sweep Model",
     overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string G_SESS  = "═══ Session Engine ═══"
string G_REF   = "═══ HTF Reference ═══"
string G_LOGIC = "═══ Sweep Logic ═══"
string G_BO    = "═══ Breakout + Trap Logic ═══"
string G_AUC   = "═══ HTF Auction Levels ═══"
string G_VIS   = "═══ Visual Style ═══"
string G_VOL   = "═══ Volume Filter ═══"
string G_ALERT = "═══ Alerts ═══"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool useAsia   = input.bool(true, "Enable Asia", group=G_SESS)
bool useLondon = input.bool(true, "Enable London", group=G_SESS)
bool useNY     = input.bool(true, "Enable New York", group=G_SESS)

string asiaSession   = input.session("0000-0800", "Asia Window", group=G_SESS)
string londonSession = input.session("0700-1600", "London Window", group=G_SESS)
string nySession     = input.session("1300-2200", "New York Window", group=G_SESS)

string asiaTZ   = input.string("Etc/UTC", "Asia Timezone", options=["Etc/UTC", "Asia/Tokyo", "Australia/Sydney", "Exchange"], group=G_SESS)
string londonTZ = input.string("Etc/UTC", "London Timezone", options=["Etc/UTC", "Europe/London", "Exchange"], group=G_SESS)
string nyTZ     = input.string("Etc/UTC", "New York Timezone", options=["Etc/UTC", "America/New_York", "Exchange"], group=G_SESS)

int levelBackfillBars = input.int(0, "Draw Levels Before Session Open", minval=0, maxval=100, group=G_SESS)
int extendAfterBars   = input.int(0, "Extend Levels After Session", minval=0, maxval=200, group=G_SESS)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF REFERENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string refTF = input.timeframe("240", "Reference HTF Candle", group=G_REF)

bool keepHistory = input.bool(true, "Keep Historical Sessions", group=G_REF,
     tooltip="On by default so previous session maps remain visible. Turn off for a cleaner chart.")

int maxHistoricalSessions = input.int(25, "Max Historical Session Maps", minval=1, maxval=100, group=G_REF,
     tooltip="Only applies when Keep Historical Sessions is enabled. Helps control object limits.")

bool showHTFCandle   = input.bool(true, "Show Previous HTF Candle", group=G_REF)
bool showRangeBox    = input.bool(true, "Show HTF Range Box", group=G_REF)
bool showSessionOpen = input.bool(true, "Show Session Open Line", group=G_REF)
bool showMidLine     = input.bool(true, "Show HTF Mid Line", group=G_REF)

int htfCandleWidthBars  = input.int(6, "HTF Candle Width Bars", minval=2, maxval=30, group=G_REF)
int htfCandleBodyTransp = input.int(88, "HTF Candle Body Transparency", minval=0, maxval=100, group=G_REF)
int htfCandleLineWidth  = input.int(2, "HTF Candle Line Width", minval=1, maxval=5, group=G_REF)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF AUCTION LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showAuctionLevels = input.bool(true, "Show Precise POC / VAH / VAL", group=G_AUC,
     tooltip="Draws POC, VAH and VAL from the previous confirmed HTF candle using lower-timeframe volume samples.")

string auctionLowerTF = input.timeframe("1", "Lower TF Volume Source", group=G_AUC,
     tooltip="Lower timeframe used to build the HTF auction levels. 1 minute is most precise but can be heavier on very high HTFs.")

int auctionRows = input.int(24, "Auction Rows", minval=8, maxval=100, group=G_AUC)
float auctionValueAreaPct = input.float(70.0, "Value Area %", minval=50.0, maxval=90.0, step=1.0, group=G_AUC)

bool showAuctionLabels = input.bool(true, "Show POC / VAH / VAL Labels", group=G_AUC)

color auctionPOCColor = input.color(color.new(color.yellow, 0), "POC Color", group=G_AUC)
color auctionVAColor  = input.color(color.new(color.purple, 0), "VAH / VAL Color", group=G_AUC)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string sweepMode = input.string("Wick Sweep + Close Back Inside", "Sweep Mode",
     options=["Wick Sweep", "Wick Sweep + Close Back Inside"],
     group=G_LOGIC)

bool confirmOnClose = input.bool(true, "Confirm Signals On Bar Close", group=G_LOGIC,
     tooltip="Signals confirm after the current bar closes. Recommended for cleaner alerts and historical review.")

int shiftLen = input.int(5, "Delivery Shift Lookback", minval=2, maxval=50, group=G_LOGIC)

bool oneEntryPerSide = input.bool(true, "One Sweep Entry Per Side Per Session", group=G_LOGIC)
bool showSweepMarks  = input.bool(true, "Show Sweep Marks", group=G_LOGIC)
bool showEntryMarks  = input.bool(true, "Show Sweep Entry Marks", group=G_LOGIC)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT + TRAP LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool enableBreakoutModel = input.bool(true, "Enable Breakout Model", group=G_BO)

int breakoutHoldBars = input.int(1, "Breakout Hold Bars", minval=1, maxval=5, group=G_BO)

bool useDisplacementFilter = input.bool(true, "Use Displacement Filter", group=G_BO)
int dispAtrLen             = input.int(14, "Displacement ATR Length", minval=1, group=G_BO)
float dispAtrMult          = input.float(0.50, "Displacement ATR Mult", minval=0.1, step=0.1, group=G_BO)

bool enableTrapModel    = input.bool(true, "Enable Failed Breakout Trap Model", group=G_BO)
bool oneBreakoutPerSide = input.bool(true, "One Breakout Per Side Per Session", group=G_BO)
bool showBreakoutMarks  = input.bool(true, "Show Breakout Marks", group=G_BO)
bool showFailedBreakout = input.bool(true, "Show Failed Breakout Trap Marks", group=G_BO)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool useVolumeFilter = input.bool(false, "Use Volume Filter", group=G_VOL,
     tooltip="Optional filter for sweep and breakout entries. Useful on volume-supported markets.")

int volLength = input.int(20, "Volume Average Length", minval=1, group=G_VOL)
float volMult = input.float(1.0, "Volume Multiplier", minval=0.1, step=0.1, group=G_VOL)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string visualMode = input.string("Clean", "Visual Mode", options=["Clean", "Stealth", "Debug"], group=G_VIS)

color bullColor = input.color(#089981, "Bull Color", group=G_VIS)
color bearColor = input.color(#f23645, "Bear Color", group=G_VIS)
color midColor  = input.color(color.gray, "Mid / Open Color", group=G_VIS)
color boColor   = input.color(#5b9cf6, "Breakout Color", group=G_VIS)
color trapColor = input.color(#ffb000, "Trap Color", group=G_VIS)

color asiaColor   = input.color(color.new(color.teal, 0), "Asia Color", group=G_VIS)
color londonColor = input.color(color.new(color.orange, 0), "London Color", group=G_VIS)
color nyColor     = input.color(color.new(color.blue, 0), "New York Color", group=G_VIS)

bool showSessionFlags      = input.bool(true, "Show Session Open Flags", group=G_VIS)
bool showSessionLabel      = input.bool(false, "Show Session Name Label", group=G_VIS)
bool showDashboard         = input.bool(false, "Show Compact Dashboard", group=G_VIS)
bool showFirstCandleLabel  = input.bool(true, "Show Session Open Label", group=G_VIS)
bool showEntryPriceOnLabel = input.bool(false, "Show Entry Price On Signal", group=G_VIS)

string entryMarkerStyle = input.string("Premium Compact", "Entry Marker Style",
     options=["Triangle", "Premium", "Premium Compact"],
     group=G_VIS)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool enableMasterAlert = input.bool(true, "Enable Master Alert Condition", group=G_ALERT)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL MODE ROUTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool modeClean   = visualMode == "Clean"
bool modeStealth = visualMode == "Stealth"
bool modeDebug   = visualMode == "Debug"

int rangeTransp      = modeDebug ? 92 : modeClean ? 96 : 98
int lineTransp       = modeDebug ? 10 : modeClean ? 35 : 55
int midTransp        = modeDebug ? 45 : modeClean ? 65 : 78
int firstLabelTransp = modeDebug ? 0  : modeClean ? 15 : 35

bool useTriangleStyle = entryMarkerStyle == "Triangle"
bool usePremiumStyle  = entryMarkerStyle != "Triangle"

bool signalReady = not confirmOnClose or barstate.isconfirmed

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEZONE RESOLUTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string asiaTZFinal   = asiaTZ == "Exchange" ? syminfo.timezone : asiaTZ
string londonTZFinal = londonTZ == "Exchange" ? syminfo.timezone : londonTZ
string nyTZFinal     = nyTZ == "Exchange" ? syminfo.timezone : nyTZ

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool inAsia   = useAsia and not na(time(timeframe.period, asiaSession, asiaTZFinal))
bool inLondon = useLondon and not na(time(timeframe.period, londonSession, londonTZFinal))
bool inNY     = useNY and not na(time(timeframe.period, nySession, nyTZFinal))

bool newAsia   = inAsia and not inAsia[1]
bool newLondon = inLondon and not inLondon[1]
bool newNY     = inNY and not inNY[1]

bool endAsia   = not inAsia and inAsia[1]
bool endLondon = not inLondon and inLondon[1]
bool endNY     = not inNY and inNY[1]

bool newAnySession = newAsia or newLondon or newNY

var string activeSessionName = "None"
var color activeSessionColor = color.gray

if newAsia
    activeSessionName := "Asia"
    activeSessionColor := asiaColor

if newLondon
    activeSessionName := "London"
    activeSessionColor := londonColor

if newNY
    activeSessionName := "New York"
    activeSessionColor := nyColor

bool inActiveSession =
     activeSessionName == "Asia" ? inAsia :
     activeSessionName == "London" ? inLondon :
     activeSessionName == "New York" ? inNY :
     false

bool endActiveSession =
     activeSessionName == "Asia" ? endAsia :
     activeSessionName == "London" ? endLondon :
     activeSessionName == "New York" ? endNY :
     false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS CONFIRMED HTF CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float htfOpenPrev  = request.security(syminfo.tickerid, refTF, open[1],  barmerge.gaps_off, barmerge.lookahead_off)
float htfHighPrev  = request.security(syminfo.tickerid, refTF, high[1],  barmerge.gaps_off, barmerge.lookahead_off)
float htfLowPrev   = request.security(syminfo.tickerid, refTF, low[1],   barmerge.gaps_off, barmerge.lookahead_off)
float htfClosePrev = request.security(syminfo.tickerid, refTF, close[1], barmerge.gaps_off, barmerge.lookahead_off)

bool validHTF = not na(htfOpenPrev) and not na(htfHighPrev) and not na(htfLowPrev) and not na(htfClosePrev)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF REFERENCE STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float refOpen  = na
var float refHigh  = na
var float refLow   = na
var float refClose = na
var float refMid   = na
var float sessOpen = na

var float refPOC = na
var float refVAH = na
var float refVAL = na

var float auctionPOCPrev = na
var float auctionVAHPrev = na
var float auctionVALPrev = na

var float auctionCurrHigh = na
var float auctionCurrLow  = na

var array<float> auctionHStore = array.new_float()
var array<float> auctionLStore = array.new_float()
var array<float> auctionVStore = array.new_float()

var int sessionBar = na
var int levelLeft  = na

var bool sweptHigh = false
var bool sweptLow  = false

var bool shortFired = false
var bool longFired  = false

var bool boLongFired  = false
var bool boShortFired = false

var bool brokeAboveRef = false
var bool brokeBelowRef = false

var bool bullTrapFired = false
var bool bearTrapFired = false

var int aboveRefCount = 0
var int belowRefCount = 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box rangeBox = na
var box htfBodyBox = na

var line htfUpperWick = na
var line htfLowerWick = na

var line highLine = na
var line lowLine = na
var line midLine = na
var line openLine = na

var line pocLine = na
var line vahLine = na
var line valLine = na

var label sessionFirstCandleLabel = na
var label sessionLabel = na
var label htfTextLabel = na

var label pocLabel = na
var label vahLabel = na
var label valLabel = na

var box[] boxStore = array.new_box()
var line[] lineStore = array.new_line()
var label[] labelStore = array.new_label()
var label[] signalLabelStore = array.new_label()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_delete_current_map() =>
    if not na(rangeBox)
        box.delete(rangeBox)
    if not na(htfBodyBox)
        box.delete(htfBodyBox)
    if not na(htfUpperWick)
        line.delete(htfUpperWick)
    if not na(htfLowerWick)
        line.delete(htfLowerWick)
    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)
    if not na(midLine)
        line.delete(midLine)
    if not na(openLine)
        line.delete(openLine)
    if not na(pocLine)
        line.delete(pocLine)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)
    if not na(sessionFirstCandleLabel)
        label.delete(sessionFirstCandleLabel)
    if not na(sessionLabel)
        label.delete(sessionLabel)
    if not na(htfTextLabel)
        label.delete(htfTextLabel)
    if not na(pocLabel)
        label.delete(pocLabel)
    if not na(vahLabel)
        label.delete(vahLabel)
    if not na(valLabel)
        label.delete(valLabel)

f_store_box(box _b) =>
    if keepHistory and not na(_b)
        array.push(boxStore, _b)
        int maxBoxes = math.max(1, maxHistoricalSessions * 2)
        if array.size(boxStore) > maxBoxes
            box oldBox = array.shift(boxStore)
            if not na(oldBox)
                box.delete(oldBox)

f_store_line(line _l) =>
    if keepHistory and not na(_l)
        array.push(lineStore, _l)
        int maxLines = math.max(1, maxHistoricalSessions * 7)
        if array.size(lineStore) > maxLines
            line oldLine = array.shift(lineStore)
            if not na(oldLine)
                line.delete(oldLine)

f_store_label(label _lb) =>
    if keepHistory and not na(_lb)
        array.push(labelStore, _lb)
        int maxLabels = math.max(1, maxHistoricalSessions * 6)
        if array.size(labelStore) > maxLabels
            label oldLabel = array.shift(labelStore)
            if not na(oldLabel)
                label.delete(oldLabel)

f_store_signal_label(label _lb) =>
    if not na(_lb)
        array.push(signalLabelStore, _lb)
        int maxSignals = 350
        if array.size(signalLabelStore) > maxSignals
            label oldSignal = array.shift(signalLabelStore)
            if not na(oldSignal)
                label.delete(oldSignal)

f_calc_auction_levels(array<float> _hArr, array<float> _lArr, array<float> _vArr, float _hi, float _lo, int _rows, float _vaPct) =>
    float _poc = na
    float _vah = na
    float _val = na

    int sampleCount = array.size(_vArr)

    if sampleCount > 0 and _rows > 1 and not na(_hi) and not na(_lo) and _hi > _lo
        float step = math.max((_hi - _lo) / _rows, syminfo.mintick)
        array<float> bins = array.new_float(_rows, 0.0)

        for i = 0 to sampleCount - 1
            float sampleHigh = array.get(_hArr, i)
            float sampleLow  = array.get(_lArr, i)
            float sampleVol  = nz(array.get(_vArr, i))

            float sampleTop = math.max(sampleHigh, sampleLow)
            float sampleBot = math.min(sampleHigh, sampleLow)

            int upIdx = int(math.floor((sampleTop - _lo) / step))
            int dnIdx = int(math.floor((sampleBot - _lo) / step))

            upIdx := math.max(0, math.min(_rows - 1, upIdx))
            dnIdx := math.max(0, math.min(_rows - 1, dnIdx))

            float sampleRange = math.max(sampleTop - sampleBot, syminfo.mintick)

            for row = dnIdx to upIdx
                float rowLow = _lo + step * row
                float rowHigh = rowLow + step
                float overlapTop = math.min(sampleTop, rowHigh)
                float overlapBot = math.max(sampleBot, rowLow)
                float overlap = math.max(overlapTop - overlapBot, 0.0)
                float addVol = sampleVol * overlap / sampleRange
                array.set(bins, row, array.get(bins, row) + addVol)

        float totalVolume = array.sum(bins)

        if totalVolume > 0
            float maxVolume = array.max(bins)
            int pocIdx = array.indexof(bins, maxVolume)
            pocIdx := math.max(0, math.min(_rows - 1, pocIdx))

            float targetVolume = totalVolume * _vaPct / 100.0
            float valueVolume = array.get(bins, pocIdx)

            int up = pocIdx
            int down = pocIdx

            for stepCount = 0 to _rows - 1
                if valueVolume >= targetVolume
                    break

                float upperVol = up < _rows - 1 ? array.get(bins, up + 1) : 0.0
                float lowerVol = down > 0 ? array.get(bins, down - 1) : 0.0

                if upperVol == 0.0 and lowerVol == 0.0
                    break

                if upperVol >= lowerVol
                    valueVolume += upperVol
                    up += 1
                else
                    valueVolume += lowerVol
                    down -= 1

            _poc := _lo + step * pocIdx + step / 2.0
            _vah := _lo + step * (up + 1)
            _val := _lo + step * down

    [_poc, _vah, _val]

f_draw_premium_signal(bool _isLong, bool _isBreakout, bool _isTrap, float _y, float _entryPrice) =>
    color sigColor = _isTrap ? trapColor : _isBreakout ? boColor : _isLong ? bullColor : bearColor

    string baseTxt =
         _isTrap ? (_isLong ? "BEAR TRAP" : "BULL TRAP") :
         _isBreakout ? (_isLong ? "BO↑" : "BO↓") :
         (_isLong ? "LONG" : "SHORT")

    string compactTxt =
         _isBreakout ? (_isLong ? "BO↑" : "BO↓") :
         (_isLong ? "L" : "S")

    string trapTxt = _isLong ? "BEAR TRAP" : "BULL TRAP"

    string dirTxt =
         _isTrap ? trapTxt :
         entryMarkerStyle == "Premium Compact" ? compactTxt : baseTxt

    string iconTxt = _isLong ? "▲" : "▼"

    string lblTxt =
         showEntryPriceOnLabel ?
         iconTxt + " " + dirTxt + "\n" + str.tostring(_entryPrice, format.mintick) :
         iconTxt + " " + dirTxt

    label sigLabel = label.new(
         bar_index,
         _y,
         lblTxt,
         style=_isLong ? label.style_label_up : label.style_label_down,
         color=color.new(color.black, 100),
         textcolor=sigColor,
         size=size.tiny)

    f_store_signal_label(sigLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRECISE HTF AUCTION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[auctionLtfHigh, auctionLtfLow, auctionLtfVolume] = request.security_lower_tf(
     syminfo.tickerid,
     auctionLowerTF,
     [high, low, volume],
     ignore_invalid_timeframe=true)

bool newAuctionHTF = timeframe.change(refTF)

if showAuctionLevels
    if newAuctionHTF and array.size(auctionVStore) > 0
        [calcPOC, calcVAH, calcVAL] = f_calc_auction_levels(
             auctionHStore,
             auctionLStore,
             auctionVStore,
             auctionCurrHigh,
             auctionCurrLow,
             auctionRows,
             auctionValueAreaPct)

        auctionPOCPrev := calcPOC
        auctionVAHPrev := calcVAH
        auctionVALPrev := calcVAL

        array.clear(auctionHStore)
        array.clear(auctionLStore)
        array.clear(auctionVStore)

        auctionCurrHigh := high
        auctionCurrLow  := low

    else if na(auctionCurrHigh) or na(auctionCurrLow)
        auctionCurrHigh := high
        auctionCurrLow  := low
    else
        auctionCurrHigh := math.max(auctionCurrHigh, high)
        auctionCurrLow  := math.min(auctionCurrLow, low)

    int ltfSampleCount = array.size(auctionLtfVolume)

    if ltfSampleCount > 0
        for i = 0 to ltfSampleCount - 1
            float sampleHigh = array.get(auctionLtfHigh, i)
            float sampleLow  = array.get(auctionLtfLow, i)
            float sampleVol  = array.get(auctionLtfVolume, i)

            array.push(auctionHStore, sampleHigh)
            array.push(auctionLStore, sampleLow)
            array.push(auctionVStore, sampleVol)

            auctionCurrHigh := math.max(auctionCurrHigh, sampleHigh)
            auctionCurrLow  := math.min(auctionCurrLow, sampleLow)
    else
        array.push(auctionHStore, high)
        array.push(auctionLStore, low)
        array.push(auctionVStore, volume)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW SESSION MAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if newAnySession and validHTF
    if not keepHistory
        f_delete_current_map()

    refOpen  := htfOpenPrev
    refHigh  := htfHighPrev
    refLow   := htfLowPrev
    refClose := htfClosePrev
    refMid   := (refHigh + refLow) / 2.0
    sessOpen := open

    refPOC := auctionPOCPrev
    refVAH := auctionVAHPrev
    refVAL := auctionVALPrev

    sessionBar := bar_index
    levelLeft  := math.max(0, bar_index - levelBackfillBars)

    sweptHigh := false
    sweptLow  := false

    shortFired := false
    longFired  := false

    boLongFired  := false
    boShortFired := false

    brokeAboveRef := false
    brokeBelowRef := false

    bullTrapFired := false
    bearTrapFired := false

    aboveRefCount := 0
    belowRefCount := 0

    rangeBox := na
    htfBodyBox := na
    htfUpperWick := na
    htfLowerWick := na
    highLine := na
    lowLine := na
    midLine := na
    openLine := na
    pocLine := na
    vahLine := na
    valLine := na
    sessionFirstCandleLabel := na
    sessionLabel := na
    htfTextLabel := na
    pocLabel := na
    vahLabel := na
    valLabel := na

    bool refBull = refClose >= refOpen
    color refColor = refBull ? bullColor : bearColor

    if showFirstCandleLabel
        sessionFirstCandleLabel := label.new(
             bar_index,
             low - ta.atr(14) * 0.8,
             activeSessionName + " OPEN",
             style=label.style_none,
             textcolor=color.new(activeSessionColor, firstLabelTransp),
             size=modeStealth ? size.tiny : size.small)

    if showRangeBox
        rangeBox := box.new(
             levelLeft,
             refHigh,
             bar_index,
             refLow,
             bgcolor=color.new(activeSessionColor, rangeTransp),
             border_color=color.new(activeSessionColor, 85))

    if showHTFCandle
        int leftBody  = bar_index
        int rightBody = bar_index + htfCandleWidthBars
        int wickX     = int(math.round((leftBody + rightBody) / 2.0))

        float bodyTop = math.max(refOpen, refClose)
        float bodyBot = math.min(refOpen, refClose)

        htfBodyBox := box.new(
             leftBody,
             bodyTop,
             rightBody,
             bodyBot,
             bgcolor=color.new(refColor, htfCandleBodyTransp),
             border_color=refColor,
             border_width=htfCandleLineWidth)

        if refHigh > bodyTop
            htfUpperWick := line.new(
                 wickX,
                 bodyTop,
                 wickX,
                 refHigh,
                 color=refColor,
                 width=htfCandleLineWidth)

        if refLow < bodyBot
            htfLowerWick := line.new(
                 wickX,
                 bodyBot,
                 wickX,
                 refLow,
                 color=refColor,
                 width=htfCandleLineWidth)

        string tfLabel =
             refTF == "60"  ? "1H" :
             refTF == "120" ? "2H" :
             refTF == "240" ? "4H" :
             refTF == "D"   ? "1D" :
             refTF == "W"   ? "1W" :
             refTF

        htfTextLabel := label.new(
             wickX,
             (bodyTop + bodyBot) / 2.0,
             tfLabel,
             style=label.style_none,
             textcolor=refColor,
             size=size.small)

    highLine := line.new(levelLeft, refHigh, bar_index, refHigh, color=color.new(bearColor, lineTransp), width=1)
    lowLine  := line.new(levelLeft, refLow, bar_index, refLow, color=color.new(bullColor, lineTransp), width=1)

    if showMidLine
        midLine := line.new(levelLeft, refMid, bar_index, refMid, color=color.new(midColor, midTransp), width=1, style=line.style_dashed)

    if showSessionOpen
        openLine := line.new(levelLeft, sessOpen, bar_index, sessOpen, color=color.new(midColor, midTransp), width=1, style=line.style_dotted)

    bool validAuctionLevels = showAuctionLevels and not na(refPOC) and not na(refVAH) and not na(refVAL)

    if validAuctionLevels
        pocLine := line.new(levelLeft, refPOC, bar_index, refPOC, color=color.new(auctionPOCColor, lineTransp), width=2)
        vahLine := line.new(levelLeft, refVAH, bar_index, refVAH, color=color.new(auctionVAColor, lineTransp), width=1, style=line.style_dashed)
        valLine := line.new(levelLeft, refVAL, bar_index, refVAL, color=color.new(auctionVAColor, lineTransp), width=1, style=line.style_dashed)

        if showAuctionLabels
            pocLabel := label.new(bar_index, refPOC, "POC", style=label.style_none, textcolor=color.new(auctionPOCColor, firstLabelTransp), size=size.tiny)
            vahLabel := label.new(bar_index, refVAH, "VAH", style=label.style_none, textcolor=color.new(auctionVAColor, firstLabelTransp), size=size.tiny)
            valLabel := label.new(bar_index, refVAL, "VAL", style=label.style_none, textcolor=color.new(auctionVAColor, firstLabelTransp), size=size.tiny)

    if showSessionLabel and modeDebug
        sessionLabel := label.new(
             bar_index,
             refHigh,
             activeSessionName + " HTF " + refTF,
             style=label.style_label_down,
             color=color.new(activeSessionColor, 0),
             textcolor=color.white,
             size=size.tiny)

    f_store_box(rangeBox)
    f_store_box(htfBodyBox)
    f_store_line(htfUpperWick)
    f_store_line(htfLowerWick)
    f_store_line(highLine)
    f_store_line(lowLine)
    f_store_line(midLine)
    f_store_line(openLine)
    f_store_line(pocLine)
    f_store_line(vahLine)
    f_store_line(valLine)
    f_store_label(sessionFirstCandleLabel)
    f_store_label(sessionLabel)
    f_store_label(htfTextLabel)
    f_store_label(pocLabel)
    f_store_label(vahLabel)
    f_store_label(valLabel)

bool validRef = not na(refHigh) and not na(refLow) and refHigh > refLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UPDATE ACTIVE SESSION MAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if inActiveSession and validRef
    if not na(rangeBox)
        box.set_right(rangeBox, bar_index)
        box.set_top(rangeBox, refHigh)
        box.set_bottom(rangeBox, refLow)

    if not na(highLine)
        line.set_x2(highLine, bar_index)
        line.set_y1(highLine, refHigh)
        line.set_y2(highLine, refHigh)

    if not na(lowLine)
        line.set_x2(lowLine, bar_index)
        line.set_y1(lowLine, refLow)
        line.set_y2(lowLine, refLow)

    if not na(midLine)
        line.set_x2(midLine, bar_index)
        line.set_y1(midLine, refMid)
        line.set_y2(midLine, refMid)

    if not na(openLine)
        line.set_x2(openLine, bar_index)
        line.set_y1(openLine, sessOpen)
        line.set_y2(openLine, sessOpen)

    if not na(pocLine)
        line.set_x2(pocLine, bar_index)
        line.set_y1(pocLine, refPOC)
        line.set_y2(pocLine, refPOC)

    if not na(vahLine)
        line.set_x2(vahLine, bar_index)
        line.set_y1(vahLine, refVAH)
        line.set_y2(vahLine, refVAH)

    if not na(valLine)
        line.set_x2(valLine, bar_index)
        line.set_y1(valLine, refVAL)
        line.set_y2(valLine, refVAL)

    if not na(pocLabel)
        label.set_x(pocLabel, bar_index)
        label.set_y(pocLabel, refPOC)

    if not na(vahLabel)
        label.set_x(vahLabel, bar_index)
        label.set_y(vahLabel, refVAH)

    if not na(valLabel)
        label.set_x(valLabel, bar_index)
        label.set_y(valLabel, refVAL)

    if not na(sessionLabel)
        label.set_x(sessionLabel, bar_index)
        label.set_y(sessionLabel, refHigh)

if endActiveSession
    int finalRight = bar_index + extendAfterBars

    if not na(rangeBox)
        box.set_right(rangeBox, finalRight)
    if not na(highLine)
        line.set_x2(highLine, finalRight)
    if not na(lowLine)
        line.set_x2(lowLine, finalRight)
    if not na(midLine)
        line.set_x2(midLine, finalRight)
    if not na(openLine)
        line.set_x2(openLine, finalRight)
    if not na(pocLine)
        line.set_x2(pocLine, finalRight)
    if not na(vahLine)
        line.set_x2(vahLine, finalRight)
    if not na(valLine)
        line.set_x2(valLine, finalRight)
    if not na(pocLabel)
        label.set_x(pocLabel, finalRight)
    if not na(vahLabel)
        label.set_x(vahLabel, finalRight)
    if not na(valLabel)
        label.set_x(valLabel, finalRight)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float volAvg = ta.sma(volume, volLength)
bool volOK = not useVolumeFilter or (not na(volume) and not na(volAvg) and volume > volAvg * volMult)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWEEP LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool wickSweepHigh = validRef and inActiveSession and high > refHigh and volOK
bool wickSweepLow  = validRef and inActiveSession and low < refLow and volOK

bool bearSweep = sweepMode == "Wick Sweep" ? wickSweepHigh : wickSweepHigh and close < refHigh
bool bullSweep = sweepMode == "Wick Sweep" ? wickSweepLow : wickSweepLow and close > refLow

bool newBearSweep = bearSweep and not sweptHigh and signalReady
bool newBullSweep = bullSweep and not sweptLow and signalReady

if newBearSweep
    sweptHigh := true

if newBullSweep
    sweptLow := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELIVERY SHIFT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool deliveryDown = close < ta.lowest(low, shiftLen)[1]
bool deliveryUp   = close > ta.highest(high, shiftLen)[1]

bool shortConfirm = sweptHigh and deliveryDown and signalReady
bool longConfirm  = sweptLow and deliveryUp and signalReady

bool shortSignal = shortConfirm and (not oneEntryPerSide or not shortFired)
bool longSignal  = longConfirm and (not oneEntryPerSide or not longFired)

if shortSignal
    shortFired := true

if longSignal
    longFired := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT + FAILED BREAKOUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool closeAboveRef = validRef and inActiveSession and close > refHigh
bool closeBelowRef = validRef and inActiveSession and close < refLow

aboveRefCount := closeAboveRef ? aboveRefCount + 1 : 0
belowRefCount := closeBelowRef ? belowRefCount + 1 : 0

if closeAboveRef
    brokeAboveRef := true

if closeBelowRef
    brokeBelowRef := true

bool heldAboveRef = closeAboveRef and aboveRefCount >= breakoutHoldBars
bool heldBelowRef = closeBelowRef and belowRefCount >= breakoutHoldBars

float dispATR = ta.atr(dispAtrLen)
bool displacementOK = not useDisplacementFilter or math.abs(close - open) >= dispATR * dispAtrMult

bool boLongSignal =
     enableBreakoutModel and
     heldAboveRef and
     displacementOK and
     volOK and
     signalReady and
     (not oneBreakoutPerSide or not boLongFired)

bool boShortSignal =
     enableBreakoutModel and
     heldBelowRef and
     displacementOK and
     volOK and
     signalReady and
     (not oneBreakoutPerSide or not boShortFired)

if boLongSignal
    boLongFired := true

if boShortSignal
    boShortFired := true

bool rawFailedBullBreak = enableTrapModel and validRef and inActiveSession and brokeAboveRef and close < refHigh
bool rawFailedBearBreak = enableTrapModel and validRef and inActiveSession and brokeBelowRef and close > refLow

bool failedBullBreak = rawFailedBullBreak and not bullTrapFired and signalReady
bool failedBearBreak = rawFailedBearBreak and not bearTrapFired and signalReady

if failedBullBreak
    bullTrapFired := true

if failedBearBreak
    bearTrapFired := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float signalGap = ta.atr(14) * 0.2
float stackGap  = ta.atr(14) * 0.35

int stackAbove = 0
int stackBelow = 0

plotshape(showSessionFlags and newAsia, title="Asia Open", style=shape.flag, location=location.top, color=asiaColor, size=size.tiny, text="A")
plotshape(showSessionFlags and newLondon, title="London Open", style=shape.flag, location=location.top, color=londonColor, size=size.tiny, text="L")
plotshape(showSessionFlags and newNY, title="New York Open", style=shape.flag, location=location.top, color=nyColor, size=size.tiny, text="NY")

plotshape(showSweepMarks and newBearSweep, title="High Sweep", style=shape.xcross, location=location.abovebar, color=color.new(bearColor, modeStealth ? 35 : 0), size=size.tiny)
plotshape(showSweepMarks and newBullSweep, title="Low Sweep", style=shape.xcross, location=location.belowbar, color=color.new(bullColor, modeStealth ? 35 : 0), size=size.tiny)

plotshape(showEntryMarks and useTriangleStyle and shortSignal, title="Sweep Short Triangle", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.normal, text="SHORT", textcolor=bearColor)
plotshape(showEntryMarks and useTriangleStyle and longSignal, title="Sweep Long Triangle", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.normal, text="LONG", textcolor=bullColor)

plotshape(showEntryMarks and usePremiumStyle and shortSignal, title="Sweep Short Anchor", style=shape.circle, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny)
plotshape(showEntryMarks and usePremiumStyle and longSignal, title="Sweep Long Anchor", style=shape.circle, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny)

if showEntryMarks and usePremiumStyle and shortSignal
    stackAbove += 1
    f_draw_premium_signal(false, false, false, high + signalGap + stackGap * (stackAbove - 1), close)

if showEntryMarks and usePremiumStyle and longSignal
    stackBelow += 1
    f_draw_premium_signal(true, false, false, low - signalGap - stackGap * (stackBelow - 1), close)

plotshape(showBreakoutMarks and useTriangleStyle and boLongSignal, title="BO Long Triangle", style=shape.triangleup, location=location.belowbar, color=boColor, size=size.small, text="BO", textcolor=boColor)
plotshape(showBreakoutMarks and useTriangleStyle and boShortSignal, title="BO Short Triangle", style=shape.triangledown, location=location.abovebar, color=boColor, size=size.small, text="BO", textcolor=boColor)

plotshape(showBreakoutMarks and usePremiumStyle and boLongSignal, title="BO Long Anchor", style=shape.diamond, location=location.belowbar, color=color.new(boColor, 0), size=size.tiny)
plotshape(showBreakoutMarks and usePremiumStyle and boShortSignal, title="BO Short Anchor", style=shape.diamond, location=location.abovebar, color=color.new(boColor, 0), size=size.tiny)

if showBreakoutMarks and usePremiumStyle and boLongSignal
    stackBelow += 1
    f_draw_premium_signal(true, true, false, low - signalGap - stackGap * (stackBelow - 1), close)

if showBreakoutMarks and usePremiumStyle and boShortSignal
    stackAbove += 1
    f_draw_premium_signal(false, true, false, high + signalGap + stackGap * (stackAbove - 1), close)

plotshape(showFailedBreakout and useTriangleStyle and failedBullBreak, title="Bull Trap Triangle", style=shape.triangledown, location=location.abovebar, color=trapColor, size=size.small, text="BULL TRAP", textcolor=trapColor)
plotshape(showFailedBreakout and useTriangleStyle and failedBearBreak, title="Bear Trap Triangle", style=shape.triangleup, location=location.belowbar, color=trapColor, size=size.small, text="BEAR TRAP", textcolor=trapColor)

plotshape(showFailedBreakout and usePremiumStyle and failedBullBreak, title="Bull Trap Anchor", style=shape.square, location=location.abovebar, color=color.new(trapColor, 0), size=size.tiny)
plotshape(showFailedBreakout and usePremiumStyle and failedBearBreak, title="Bear Trap Anchor", style=shape.square, location=location.belowbar, color=color.new(trapColor, 0), size=size.tiny)

if showFailedBreakout and usePremiumStyle and failedBullBreak
    stackAbove += 1
    f_draw_premium_signal(false, false, true, high + signalGap + stackGap * (stackAbove - 1), close)

if showFailedBreakout and usePremiumStyle and failedBearBreak
    stackBelow += 1
    f_draw_premium_signal(true, false, true, low - signalGap - stackGap * (stackBelow - 1), close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPACT DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 11, border_width=1)

string confirmText = confirmOnClose ? "Bar Close" : "Live"

string stateText =
     boLongSignal ? "BO Long" :
     boShortSignal ? "BO Short" :
     longSignal ? "Sweep Long" :
     shortSignal ? "Sweep Short" :
     failedBullBreak ? "Bull Trap" :
     failedBearBreak ? "Bear Trap" :
     closeAboveRef ? "Above HTF" :
     closeBelowRef ? "Below HTF" :
     sweptHigh and not shortFired ? "High Swept" :
     sweptLow and not longFired ? "Low Swept" :
     inActiveSession ? "Waiting" :
     "Inactive"

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "HTF Sweep", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "Session", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 1, activeSessionName, text_color=color.white, bgcolor=color.new(activeSessionColor, 50))

    table.cell(dash, 0, 2, "HTF", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 2, refTF, text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 3, "Mode", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 3, confirmText, text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 4, "State", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 4, stateText, text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 5, "High", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 5, str.tostring(refHigh, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 6, "Low", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 6, str.tostring(refLow, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 7, "Mid", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 7, str.tostring(refMid, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 8, "POC", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 8, na(refPOC) ? "n/a" : str.tostring(refPOC, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 9, "VAH", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 9, na(refVAH) ? "n/a" : str.tostring(refVAH, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

    table.cell(dash, 0, 10, "VAL", text_color=color.white, bgcolor=color.new(color.black, 80))
    table.cell(dash, 1, 10, na(refVAL) ? "n/a" : str.tostring(refVAL, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 80))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool anySweepEvent = newBearSweep or newBullSweep
bool anyEntryEvent = shortSignal or longSignal or boLongSignal or boShortSignal or failedBullBreak or failedBearBreak
bool anyModelEvent = anySweepEvent or anyEntryEvent

alertcondition(enableMasterAlert and anyModelEvent, "HTF Sweep Master Alert", "HTF Sweep Model event triggered. Check chart for sweep, breakout, trap, or entry state.")

alertcondition(newBearSweep, "HTF High Swept", "HTF reference high swept.")
alertcondition(newBullSweep, "HTF Low Swept", "HTF reference low swept.")

alertcondition(shortSignal, "HTF Sweep Short", "HTF sweep short after high sweep and delivery shift.")
alertcondition(longSignal, "HTF Sweep Long", "HTF sweep long after low sweep and delivery shift.")

alertcondition(boLongSignal, "HTF Breakout Long", "HTF breakout long.")
alertcondition(boShortSignal, "HTF Breakout Short", "HTF breakout short.")

alertcondition(failedBullBreak, "HTF Bull Trap", "HTF failed bullish breakout trap.")
alertcondition(failedBearBreak, "HTF Bear Trap", "HTF failed bearish breakout trap.")
````
