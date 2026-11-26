# Daily Bias | Flux Charts

- url: https://www.tradingview.com/script/vkv6Wjqp-Daily-Bias-Flux-Charts/
- type: indicator
- pine_id: PUB;605e4c61d77d46368d75f55bd8a4f6be
- version: 1.0

## Description

[b]GENERAL OVERVIEW[/b]
Daily Bias is a session-based bias tool built to help traders understand whether the current session is more likely to be bullish, bearish, or neutral.

It tracks the key liquidity levels from the Asia, London, and New York sessions, along with important higher-timeframe levels like the previous 1-hour, 4-hour, and daily highs and lows. It then watches for sweeps of those levels, checks whether price rejects them or keeps moving, reads what the previous session likely did, and uses a simple lower-timeframe structure to confirm direction.

All of that is combined into one clear dashboard, so instead of only showing a bullish or bearish bias, the indicator also shows why that bias is being given.

[SCREENSHOT: Chart showing session zones, HTF liquidity lines, and the Daily Bias dashboard
https://www.tradingview.com/x/hQ5tnva7/ 

[b]WHAT IS THE THEORY BEHIND THIS INDICATOR?[/b]
The main idea behind this indicator is that one session often sets up the next one.

Price will often run above a known high or below a known low to take liquidity first. After that, the important question is whether the price keeps going, or rejects that move and turns back. That reaction gives a clue about the likely direction of the next session.

For example, if the previous session trades above a key high but then falls back below it, that shows rejection from the highs and can suggest bearish pressure for the current session. If the previous session trades below a key low but then climbs back above it, that shows rejection from the lows and can suggest bullish pressure for the current session.

This indicator reads that behavior automatically by looking at what the previous session did around important liquidity levels. It also keeps an eye on major intraday reference points like the previous 1-hour high and low, 4-hour high and low, and previous day high and low, because price often reacts around those areas.

Then it checks whether the market is starting to confirm that idea on lower timeframes. After that, everything is brought together into one final bias: bullish, bearish, or neutral. The dashboard does not just show the bias — it also shows the reasoning behind it, so traders can quickly understand why the indicator is leaning in a certain direction.

SCREENSHOT: Example showing a liquidity sweep followed by a reversal.
https://www.tradingview.com/x/iKlffgEI/

[b]DAILY BIAS FEATURES[/b]
The Daily Bias indicator includes 9 main features:
[list=1]
[*]Sessions Liquidity (Asia, London, NY)
[*]Higher Timeframe Liquidity (1H, 4H, Previous Day)
[*]Liquidity Level Labels
[*]Sweep Markers
[*]Historical Levels
[*]Session Profile Classification
[*]Lower Timeframe Structure Confirmation
[*]Final Bias Engine
[*]Daily Bias Dashboard
[/list]

Each component operates independently while sharing the same underlying liquidity logic. All features feed into a unified dashboard that displays the current state of the bias decision, along with detailed tooltips on every cell.

SESSIONS LIQUIDITY
🔹 What Is a Session?
A session is a fixed time window within the trading day during which a major financial center is most active. The Asia session corresponds to the Tokyo trading window, London corresponds to the European morning, and NY corresponds to the US morning. Each session tends to deliver a characteristic style of price action, and the highs and lows formed inside them often act as draws on liquidity for the next session.

🔹 How the Indicator Tracks Sessions
The Daily Bias indicator tracks three key trading sessions and maps out each one directly on the chart with its own colored range, session high and low, and session label.
By default, the sessions are based on the New York time zone:
[list=1]
[*]Asia: 20:00 – 22:00
[*]London: 02:00 – 04:00
[*]New York: 10:00 – 12:00
[/list]

As soon as a session begins, the indicator starts building that session’s range in real time. It expands the zone as price moves and keeps updating the session high and session low until the session closes. Once the session is complete, the final high, low, open, and close of that session are saved and used later by the bias logic.

This matters because the completed session range becomes an important liquidity reference for the sessions that follow. In other words, the indicator is not just drawing session boxes for visuals, it is using those completed session highs and lows as part of the read on where price may want to trade next.

These session drawings only appear on intraday charts and are automatically hidden on daily and higher timeframes.

SCREENSHOT: Asia, London, and NY session boxes plotted across an intraday chart
https://www.tradingview.com/x/qx06xyBi/ 

🔹 Session Titles and Extension Lines
When enabled, each session displays a title label above its box. Once a session ends, its high and low are extended forward as horizontal lines until replaced by the next instance of that same session. Each session has independent color controls for its high line and low line. Default colors are teal/maroon for Asia, blue/orange for London, and purple/green for NY.
SCREENSHOT: session extension lines with titles active after the session closes
https://www.tradingview.com/x/6goZf95Q/ 

🔹 Customization Options
[list]
[*]Show / Hide toggle per session
[*]Session zone color and opacity per session
[*]High and low line colors per session
[*]Session titles toggle and label size (Tiny, Small, Normal, Large, Huge)
[*]Line style (Solid, Dashed, Dotted) and line width (1-5)
[/list]

[b]HIGHER TIMEFRAME LIQUIDITY[/b]
🔹 What Is Higher Timeframe Liquidity?
A higher-timeframe high or low is the extreme price reached during the most recently completed candle on a higher timeframe. These levels are visible on every higher timeframe chart, which makes them natural locations for stop-loss orders and pending breakout orders to accumulate.

🔹 How the Indicator Tracks HTF Liquidity
The indicator tracks three higher-timeframe liquidity sources: the previous 1-Hour high and low, the previous 4-Hour high and low, and the previous Day high and low. When a new higher-timeframe candle begins, the previous candle's final high and low are archived and drawn as horizontal lines on the chart. These levels remain visible until replaced by the next completed candle and are also used by the bias engine to classify session profiles.

SCREENSHOT: 1H, 4H, and Previous Day high and low extension lines on 5m chart
https://www.tradingview.com/x/9mltkUXg/ 

🔹 Extend Levels
When Extend Levels is enabled, all HTF liquidity lines extend forward by a user-defined number of bars beyond the current bar, making them easier to see as future targets. The extension distance is shared across all three HTF sources.

🔹 Customization Options
[list]
[*]Show / Hide toggle per source (1H, 4H, Previous Day)
[*]High and low line colors per source
[*]Extend Levels toggle and bar count (0-100)
[*]Line style (Solid, Dashed, Dotted) and line width (1-5)
[/list]

[b]LIQUIDITY LEVEL LABELS[/b]
The Daily Bias indicator displays labels next to each tracked liquidity level on the right edge of the chart. When two or more sources fall on the exact same price, the text is automatically merged with an ampersand (for example, "1H & 4H High") so the label shows at a glance how many sources align there.

SCREENSHOT: merged liquidity labels showing combined sources
https://www.tradingview.com/x/xSbFOEN4/ 

🔹 Customization Options
[list]
[*]Show Labels toggle
[*]Label color (global)
[*]Label size (Tiny, Small, Normal, Large, Huge)
[/list]

SWEEP MARKERS
A liquidity sweep occurs when the price trades beyond a previously established high or low, triggering resting stop orders at that level. When Sweep Markers is enabled, a small red diamond appears above any candle that sweeps a high-side liquidity level, and a small green diamond appears below any candle that sweeps a low-side level.

SCREENSHOT: chart with sweep markers active, showing both high and low sweep diamonds
https://www.tradingview.com/x/m0cm1SQQ/ 

The same sweep events also feed the Current Status section of the dashboard and the bias engine, regardless of whether the markers are visually enabled.

🔹 Customization Options
Show / Hide toggle (off by default)

[b]HISTORICAL LEVELS[/b]
By default, the Daily Bias indicator shows only the most recent set of sessions and HTF liquidity lines. When Historical Levels is enabled, older lines from previous sessions and previous higher-timeframe candles remain visible on the chart, anchored at their original times. Up to 60 historical lines per side per source are kept on the chart at once. When the limit is exceeded, the oldest line is automatically deleted.

SCREENSHOT: chart with Historical Levels enabled showing older session and HTF lines
https://www.tradingview.com/x/R8XZunmW/ 

🔹 Customization Options
Show / Hide toggle (off by default)

[b]SESSION PROFILE CLASSIFICATION[/b]
🔹 The Four Profiles
Once a session ends, the indicator examines how the session interacted with all tracked liquidity sources and assigns one of four profiles:
◇ Consolidation: the session did not clearly sweep any tracked liquidity level 
◇ Manipulation (Sweep Only): the session swept one side of liquidity but did not close back through it 
◇ Reversal: the session swept one side of liquidity and closed back through it in the opposite direction 
◇ Complex: the session swept both high-side and low-side liquidity, making direction unreliable

SCREENSHOT: example of a Bullish Reversal session that swept a low and closed back above it
https://www.tradingview.com/x/Z2c1vZNi/ 

SCREENSHOT: example of a Complex session that swept both highs and lows 
https://www.tradingview.com/x/r5gxNgnz/ 

🔹 How the Indicator Classifies Sessions
At the close of each session, the indicator checks whether the session high exceeded any tracked high-side liquidity level and whether the session low exceeded any tracked low-side level. If both sides were swept, the profile is Complex. If neither side was swept, the profile is Consolidation. If only one side was swept, the indicator then checks whether the session close ended back inside the range — if yes, the profile is Reversal; if no, the profile is Manipulation.

🔹 Profile Direction and Color Coding
Each profile carries an associated direction and color in the dashboard:
◇ Consolidation: Neutral (gray) 
◇ Manipulation: Neutral, leaning bullish or bearish (orange) 
◇ Bullish Reversal: Bullish (lime) 
◇ Bearish Reversal: Bearish (red) 
◇ Complex: Neutral (yellow)

[b]LOWER TIMEFRAME STRUCTURE CONFIRMATION[/b]
🔹 What Is Structure Confirmation?
Structure confirmation is a check against the previous 5-minute and 15-minute highs and lows. The current bar's close must trade above one of those previous highs to qualify as bullish-confirmed, or below one of those previous lows to qualify as bearish-confirmed.

🔹 How the Indicator Uses Structure Confirmation
When Use 5m/15m Confirmation is enabled (default on), the bias engine requires the structure check to agree with the expected direction before assigning Bullish or Bearish to the Final Bias. If structure is not yet confirmed, the bias remains Neutral and the dashboard reason explains that the engine is waiting for confirmation. When disabled, the bias engine assigns direction purely from the session profile and current liquidity events.

The dashboard 5m/15m Structure cell displays one of four states: Bullish, Bearish, Not Confirmed, or Off.

[b]FINAL BIAS ENGINE[/b]
🔹 How the Engine Decides Direction
The Final Bias is the indicator's primary output. It combines the previous session's profile, the current session's live liquidity activity, and (optionally) the lower-timeframe structure confirmation into a single directional decision. The decision logic is rule-based and depends on the previous session's profile.

◇ If the previous session was Consolidation: the engine waits for the current session to perform its own manipulation and reversal. If the Current Status shows a remembered Bullish Reversal and structure agrees, the Final Bias becomes Bullish. The bearish case is symmetric.
◇ If the previous session was Manipulation (Sweep Only): the engine waits for the current session to confirm the reversal the previous session left incomplete.
◇ If the previous session was Reversal: the engine expects continuation in the same direction.
◇ If the previous session was Complex: the engine refuses to assign a directional bias. The Final Bias is Neutral.
◇ If no session is currently active: the Final Bias is Neutral with reason "No active session."

🔹 Final Bias Output
The Final Bias is displayed in the dashboard as Bullish (lime), Bearish (red), or Neutral (gray). Every bias decision is paired with a Reason line that explains the exact rule that produced the current value.

SCREENSHOT: dashboard Final Bias showing Bullish with corresponding Reason line
https://www.tradingview.com/x/gDPLikkE/

[b]DAILY BIAS DASHBOARD[/b]
The Daily Bias indicator includes a built-in dashboard that displays the current state of every component used in the bias decision. The dashboard is divided into four sections: a header, Session Context, Bias Engine, and Reason. Every cell that contains a value also includes a tooltip that explains what the value means and why it currently shows what it does.

🔹 Session Context
Current Session: the session price is trading in right now (Asia, London, NY, or None)
Previous Session: the session that immediately preceded the current one
Current Status: the most recent remembered liquidity event from any tracked source, updated every time a sweep or reversal occurs, and remembered until a newer same-source event replaces it

🔹 Bias Engine
[list]
[*]Previous Profile: the classification of the previous session (Consolidation, Manipulation, Reversal, or Complex)
[*]Previous Direction: the directional takeaway from the previous session profile
[*]Expected Now: what the engine expects from the current session based on the previous session's profile
[*]5m/15m Structure: the current structural state from the lower-timeframe confirmation system
[*]Final Bias: the engine's current directional decision
[/list]
🔹 Reason
The bottom row displays the exact reason behind the current Final Bias in plain English. This text changes dynamically as the engine state changes.

🔹 Tooltips
Every cell has its own tooltip that explains both what the field means in general and why the current value is what it is. For example, hovering over Previous Profile when the value is Bullish Reversal reveals: "Previous Profile means the profile of the previous session, which is NY. It is Bullish Reversal because that session swept low-side liquidity at PD Low and then closed back above it." This makes the dashboard fully self-documenting.

🔹 Customization Options
[list]
[*]Show / Hide Dashboard toggle
[*]Text size (Tiny, Small, Normal, Large)
[/list]

[b]IMPORTANT NOTES[/b]
The Daily Bias indicator is designed to run on intraday timeframes. Session tracking is automatically disabled on Daily, Weekly, and Monthly charts. The indicator uses the America/New_York time zone for all session calculations. The 5m/15m structure confirmation reads only closed previous candles and produces no future-looking data. The bias engine is intentionally session-anchored — outside of the three tracked sessions, the Final Bias remains Neutral with reason "No active session."

[b]UNIQUENESS[/b]
The Daily Bias indicator focuses on session-anchored directional bias by combining session profile classification, live liquidity event tracking, and lower-timeframe structure confirmation into a single transparent system. Unlike indicators that only display levels or only show signals, every decision the engine makes is exposed on the dashboard along with a plain-English Reason line and detailed tooltips on every cell. The session profile system classifies each completed session into one of four distinct states by examining how it interacted with three higher-timeframe liquidity sources and two cross-session sources at once. The Current Status system remembers the most recent valid liquidity event across all six tracked sources. The bias engine combines profile, expected behavior, current status, and structure into a single directional decision that is fully traceable from cell to cell.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=6
indicator("Daily Bias | Flux Charts", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//#region CONSTANTS
const string grpLiq = "HIGHER TIMEFRAME LIQUIDITY"
const string grpSes = "SESSIONS LIQUIDITY"
const string grpGc = "GENERAL CONFIGURATION"
const string sesTz = "America/New_York"

const string sesAsia = "2000-2200"
const string sesLondon = "0200-0400"
const string sesNy = "1000-1200"

const string gcSweepTip = "Shows a diamond marker on the exact candle that sweeps a tracked liquidity level."
const string gcHistTip = "Keeps older session and higher timeframe liquidity lines on the chart after new ones appear."
const string gcStructTip = "Uses simple 5m/15m structure confirmation for bias decisions. Bullish means price is above previous 5m or 15m high. Bearish means price is below previous 5m or 15m low."
disp = display.none
//#endregion CONSTANTS

//#region INPUTS
bool sesAsiaOn = input.bool(true, "Asia", inline = "SESA", group = grpSes, display = disp)
color sesAsiaCol = input.color(color.new(color.gray, 85), "", inline = "SESA", group = grpSes, display = disp)
color sesAsiaHiCol = input.color(color.new(color.teal, 0), "High", inline = "SESA", group = grpSes, display = disp)
color sesAsiaLoCol = input.color(color.new(color.maroon, 0), "Low", inline = "SESA", group = grpSes, display = disp)

bool sesLondonOn = input.bool(true, "London", inline = "SESL", group = grpSes, display = disp)
color sesLondonCol = input.color(color.new(color.gray, 85), "", inline = "SESL", group = grpSes, display = disp)
color sesLondonHiCol = input.color(color.new(color.blue, 0), "High", inline = "SESL", group = grpSes, display = disp)
color sesLondonLoCol = input.color(color.new(color.orange, 0), "Low", inline = "SESL", group = grpSes, display = disp)

bool sesNyOn = input.bool(true, "NY", inline = "SESN", group = grpSes, display = disp)
color sesNyCol = input.color(color.new(color.gray, 85), "", inline = "SESN", group = grpSes, display = disp)
color sesNyHiCol = input.color(color.new(color.purple, 0), "High", inline = "SESN", group = grpSes, display = disp)
color sesNyLoCol = input.color(color.new(color.green, 0), "Low", inline = "SESN", group = grpSes, display = disp)

bool sesShowLabels = input.bool(true, "Titles", inline = "SESLB", group = grpSes, display = disp)
string sesLabelSizeStr = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "SESLB", group = grpSes, display = disp)

string sesLineStyleStr = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], inline = "SESST", group = grpSes, display = disp)
int sesLineWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "SESST", group = grpSes, display = disp)

bool l1On = input.bool(true, "1H", inline = "L1", group = grpLiq, display = disp)
color l1HiCol = input.color(color.new(color.lime, 0), "High", inline = "L1", group = grpLiq, display = disp)
color l1LoCol = input.color(color.new(color.red, 0), "Low", inline = "L1", group = grpLiq, display = disp)

bool l2On = input.bool(true, "4H", inline = "L2", group = grpLiq, display = disp)
color l2HiCol = input.color(color.new(color.aqua, 0), "High", inline = "L2", group = grpLiq, display = disp)
color l2LoCol = input.color(color.new(color.orange, 0), "Low", inline = "L2", group = grpLiq, display = disp)

bool l3On = input.bool(true, "Previous Day", inline = "L3", group = grpLiq, display = disp)
color l3HiCol = input.color(color.new(color.fuchsia, 0), "High", inline = "L3", group = grpLiq, display = disp)
color l3LoCol = input.color(color.new(color.yellow, 0), "Low", inline = "L3", group = grpLiq, display = disp)

bool showPoiLabels = input.bool(true, "Labels ", inline = "LBL", group = grpLiq, display = disp)
color poiLabelCol = input.color(color.new(color.white, 0), "", inline = "LBL", group = grpLiq, display = disp)
string poiLabelSizeStr = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "LBL", group = grpLiq, display = disp)

bool poiExtendOn = input.bool(true, "", inline = "EXT", group = grpLiq, display = disp)
int poiExtendBars = input.int(5, "Extend Levels", minval = 0, maxval = 100, inline = "EXT", group = grpLiq, display = disp)

string poiLineStyleStr = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], inline = "ST", group = grpLiq, display = disp)
int poiLineWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "ST", group = grpLiq, display = disp)

bool showSweepMarkers = input.bool(false, "Sweep Markers", group = grpGc, tooltip = gcSweepTip, display = disp)
bool showHistoricalLevels = input.bool(false, "Historical Levels", group = grpGc, tooltip = gcHistTip, display = disp)
bool useLtfStructureConfirm = input.bool(true, "Use 5m/15m Confirmation", group = grpGc, tooltip = gcStructTip, display = disp)
bool showDashboardTable = input.bool(true, "Dashboard", inline = "DSH", group = grpGc, display = disp)
string biasTextSizeStr = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "DSH", group = grpGc, display = disp)
//#endregion INPUTS

//#region UDTs
type SesState
    array<box> boxes
    array<label> labels
    array<line> histHiLines
    array<line> histLoLines
    box curBox
    label curLbl
    bool active
    float hi
    float lo
    int tStart
    int tEnd
    int tCurRight
    float lastHi
    float lastLo
    int hiTime
    int loTime
    int lastHiTime
    int lastLoTime
    line lastHiLine
    line lastLoLine
    float sesOpen
    float sesClose
    float lastOpen
    float lastClose

type LevelState
    array<line> histHiLines
    array<line> histLoLines
    line hiLine
    line loLine
    float curHi
    float curLo
    int curHiTime
    int curLoTime
    float lastHi
    float lastLo
    int lastHiTime
    int lastLoTime
//#endregion UDTs

//#region VARIABLES
int sesMaxKeep = 20
int histMaxKeep = 60

var SesState sesAsiaState = SesState.new(array.new_box(), array.new_label(), array.new_line(), array.new_line(), na, na, false, na, na, na, na, na, na, na, na, na, na, na, na, na, na, na)
var SesState sesLondonState = SesState.new(array.new_box(), array.new_label(), array.new_line(), array.new_line(), na, na, false, na, na, na, na, na, na, na, na, na, na, na, na, na, na, na)
var SesState sesNyState = SesState.new(array.new_box(), array.new_label(), array.new_line(), array.new_line(), na, na, false, na, na, na, na, na, na, na, na, na, na, na, na, na, na, na)

var LevelState h1State = LevelState.new(array.new_line(), array.new_line(), na, na, na, na, na, na, na, na, na, na)
var LevelState h4State = LevelState.new(array.new_line(), array.new_line(), na, na, na, na, na, na, na, na, na, na)
var LevelState pdState = LevelState.new(array.new_line(), array.new_line(), na, na, na, na, na, na, na, na, na, na)

var table dashboardTable = na
var array<label> mergedHighLabels = array.new_label()
var array<label> mergedLowLabels = array.new_label()

var string h1Status = ""
var string h4Status = ""
var string pdStatus = ""
var string asiaStatus = ""
var string londonStatus = ""
var string nyStatus = ""

var int h1StatusDir = 0
var int h4StatusDir = 0
var int pdStatusDir = 0
var int asiaStatusDir = 0
var int londonStatusDir = 0
var int nyStatusDir = 0

var int h1StatusSeq = na
var int h4StatusSeq = na
var int pdStatusSeq = na
var int asiaStatusSeq = na
var int londonStatusSeq = na
var int nyStatusSeq = na
var int statusSeqCounter = 0

var int lastSeenAsiaStamp = na
var int lastSeenLondonStamp = na
var int lastSeenNyStamp = na
//#endregion VARIABLES

//#region FUNCTION DECLARATIONS
labelSizeFromStr(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

lineStyleFromStr(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

tfPretty(string tf) =>
    string t = str.upper(str.trim(tf))
    t == "60" or t == "1H" ? "1H" : t == "240" or t == "4H" ? "4H" : t == "D" or t == "1D" or t == "1440" ? "PD" : t

sweptHigh(float level) =>
    not na(level) and high > level and high[1] <= level

sweptLow(float level) =>
    not na(level) and low < level and low[1] >= level

barHighReversal(float level) =>
    not na(level) and high > level and close < level

barLowReversal(float level) =>
    not na(level) and low < level and close > level

deleteAllBoxes(array<box> boxes) =>
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box bx = array.get(boxes, i)
            if not na(bx)
                box.delete(bx)
        array.clear(boxes)
    0

deleteAllLabels(array<label> labels) =>
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label lb = array.get(labels, i)
            if not na(lb)
                label.delete(lb)
        array.clear(labels)
    0

deleteAllLines(array<line> lines) =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line ln = array.get(lines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(lines)
    0

method trimHist(SesState self, int maxKeep) =>
    while array.size(self.histHiLines) > maxKeep
        line ln = array.shift(self.histHiLines)
        if not na(ln)
            line.delete(ln)
    while array.size(self.histLoLines) > maxKeep
        line ln = array.shift(self.histLoLines)
        if not na(ln)
            line.delete(ln)
    0

method trimHist(LevelState self, int maxKeep) =>
    while array.size(self.histHiLines) > maxKeep
        line ln = array.shift(self.histHiLines)
        if not na(ln)
            line.delete(ln)
    while array.size(self.histLoLines) > maxKeep
        line ln = array.shift(self.histLoLines)
        if not na(ln)
            line.delete(ln)
    0

method clearHistLines(SesState self) =>
    deleteAllLines(self.histHiLines)
    deleteAllLines(self.histLoLines)
    0

clearHistLevelLines(LevelState st) =>
    deleteAllLines(st.histHiLines)
    deleteAllLines(st.histLoLines)
    0

method clearAll(SesState self) =>
    deleteAllBoxes(self.boxes)
    deleteAllLabels(self.labels)
    deleteAllLines(self.histHiLines)
    deleteAllLines(self.histLoLines)
    if not na(self.curBox)
        box.delete(self.curBox)
    if not na(self.curLbl)
        label.delete(self.curLbl)
    if not na(self.lastHiLine)
        line.delete(self.lastHiLine)
    if not na(self.lastLoLine)
        line.delete(self.lastLoLine)
    self.curBox := na
    self.curLbl := na
    self.active := false
    self.hi := na
    self.lo := na
    self.tStart := na
    self.tEnd := na
    self.tCurRight := na
    self.lastHi := na
    self.lastLo := na
    self.hiTime := na
    self.loTime := na
    self.lastHiTime := na
    self.lastLoTime := na
    self.lastHiLine := na
    self.lastLoLine := na
    self.sesOpen := na
    self.sesClose := na
    self.lastOpen := na
    self.lastClose := na
    0

method trim(SesState self, int maxKeep) =>
    while array.size(self.boxes) > maxKeep
        box bx = array.shift(self.boxes)
        if not na(bx)
            box.delete(bx)
    while array.size(self.labels) > maxKeep
        label lb = array.shift(self.labels)
        if not na(lb)
            label.delete(lb)
    0

method updateLastHlLines(SesState self, bool enabled, color hiCol, color loCol, string styleStr, int width) =>
    style = lineStyleFromStr(styleStr)
    if not enabled or not timeframe.isintraday
        if not na(self.lastHiLine)
            line.delete(self.lastHiLine)
            self.lastHiLine := na
        if not na(self.lastLoLine)
            line.delete(self.lastLoLine)
            self.lastLoLine := na
    else
        if not na(self.lastHi) and not na(self.lastHiTime)
            if na(self.lastHiLine)
                self.lastHiLine := line.new(self.lastHiTime, self.lastHi, time, self.lastHi, xloc = xloc.bar_time, extend = extend.none, color = color.new(hiCol, 0), width = width, style = style)
            else
                line.set_x1(self.lastHiLine, self.lastHiTime)
                line.set_y1(self.lastHiLine, self.lastHi)
                line.set_x2(self.lastHiLine, time)
                line.set_y2(self.lastHiLine, self.lastHi)
                line.set_color(self.lastHiLine, color.new(hiCol, 0))
                line.set_width(self.lastHiLine, width)
                line.set_style(self.lastHiLine, style)

        if not na(self.lastLo) and not na(self.lastLoTime)
            if na(self.lastLoLine)
                self.lastLoLine := line.new(self.lastLoTime, self.lastLo, time, self.lastLo, xloc = xloc.bar_time, extend = extend.none, color = color.new(loCol, 0), width = width, style = style)
            else
                line.set_x1(self.lastLoLine, self.lastLoTime)
                line.set_y1(self.lastLoLine, self.lastLo)
                line.set_x2(self.lastLoLine, time)
                line.set_y2(self.lastLoLine, self.lastLo)
                line.set_color(self.lastLoLine, color.new(loCol, 0))
                line.set_width(self.lastLoLine, width)
                line.set_style(self.lastLoLine, style)
    0

method archiveLastLines(SesState self, int newHiTime, int newLoTime, bool showHistory) =>
    if not na(self.lastHiLine)
        if showHistory
            if not na(newHiTime)
                line.set_x2(self.lastHiLine, newHiTime)
            array.push(self.histHiLines, self.lastHiLine)
        else
            line.delete(self.lastHiLine)
        self.lastHiLine := na

    if not na(self.lastLoLine)
        if showHistory
            if not na(newLoTime)
                line.set_x2(self.lastLoLine, newLoTime)
            array.push(self.histLoLines, self.lastLoLine)
        else
            line.delete(self.lastLoLine)
        self.lastLoLine := na

    self.trimHist(histMaxKeep)
    0

method process(SesState self, bool enabled, string name, string sessionStr, int sh, int sm, int eh, int em, color col, bool labelsOn, string lblSizeStr, color hiCol, color loCol, string lineStyleStr, int lineWidth) =>
    if not timeframe.isintraday
        if not enabled
            self.clearAll()
        0
    else
        bool inSes = not na(time(timeframe.period, sessionStr, sesTz))
        bool start = inSes and not inSes[1]
        bool stop = not inSes and inSes[1]

        if not showHistoricalLevels
            self.clearHistLines()

        if not enabled
            if array.size(self.boxes) > 0 or array.size(self.labels) > 0 or self.active or not na(self.lastHiLine) or not na(self.lastLoLine) or array.size(self.histHiLines) > 0 or array.size(self.histLoLines) > 0
                self.clearAll()
        else
            if start
                int y = year(time, sesTz)
                int m = month(time, sesTz)
                int d = dayofmonth(time, sesTz)

                self.tStart := timestamp(sesTz, y, m, d, sh, sm)
                self.tEnd := timestamp(sesTz, y, m, d, eh, em)
                self.tCurRight := time
                self.hi := high
                self.lo := low
                self.hiTime := time
                self.loTime := time
                self.sesOpen := open
                self.sesClose := close
                self.active := true

                self.curBox := box.new(self.tStart, self.hi, self.tCurRight, self.lo, xloc = xloc.bar_time, bgcolor = col, border_color = na)
                array.push(self.boxes, self.curBox)

                if labelsOn
                    int tMid = self.tStart + int(math.round((self.tCurRight - self.tStart) * 0.5))
                    self.curLbl := label.new(tMid, self.hi, name, xloc = xloc.bar_time, style = label.style_label_down, textcolor = color.white, color = color.new(color.black, 100), size = labelSizeFromStr(lblSizeStr))
                    array.push(self.labels, self.curLbl)
                else
                    self.curLbl := na

                self.trim(sesMaxKeep)

            if inSes and self.active and not na(self.curBox)
                if na(self.hi) or high > self.hi
                    self.hi := high
                    self.hiTime := time

                if na(self.lo) or low < self.lo
                    self.lo := low
                    self.loTime := time

                self.sesClose := close
                self.tCurRight := time

                box.set_left(self.curBox, self.tStart)
                box.set_right(self.curBox, self.tCurRight)
                box.set_top(self.curBox, self.hi)
                box.set_bottom(self.curBox, self.lo)

                if labelsOn and not na(self.curLbl)
                    int tMid2 = self.tStart + int(math.round((self.tCurRight - self.tStart) * 0.5))
                    label.set_x(self.curLbl, tMid2)
                    label.set_y(self.curLbl, self.hi)
                    label.set_text(self.curLbl, name)
                    label.set_textcolor(self.curLbl, color.white)

            if stop
                self.archiveLastLines(self.hiTime, self.loTime, showHistoricalLevels)
                self.lastHi := self.hi
                self.lastLo := self.lo
                self.lastHiTime := self.hiTime
                self.lastLoTime := self.loTime
                self.lastOpen := self.sesOpen
                self.lastClose := self.sesClose
                self.active := false
                self.curBox := na
                self.curLbl := na

            self.updateLastHlLines(enabled, hiCol, loCol, lineStyleStr, lineWidth)
        0

clearLevelState(LevelState st) =>
    deleteAllLines(st.histHiLines)
    deleteAllLines(st.histLoLines)
    if not na(st.hiLine)
        line.delete(st.hiLine)
    if not na(st.loLine)
        line.delete(st.loLine)
    st.hiLine := na
    st.loLine := na
    st.curHi := na
    st.curLo := na
    st.curHiTime := na
    st.curLoTime := na
    st.lastHi := na
    st.lastLo := na
    st.lastHiTime := na
    st.lastLoTime := na
    0

archiveCurrentLines(LevelState st, int newXHi, int newXLo, bool showHistory) =>
    if not na(st.hiLine)
        if showHistory
            if not na(newXHi)
                line.set_x2(st.hiLine, newXHi)
            array.push(st.histHiLines, st.hiLine)
        else
            line.delete(st.hiLine)
        st.hiLine := na

    if not na(st.loLine)
        if showHistory
            if not na(newXLo)
                line.set_x2(st.loLine, newXLo)
            array.push(st.histLoLines, st.loLine)
        else
            line.delete(st.loLine)
        st.loLine := na

    st.trimHist(histMaxKeep)
    0

updatePrevHl(LevelState st, bool enabled, string tf, color hiCol, color loCol, bool extendOn, int extendBars, string lineStyleStr, int lineWidth) =>
    bool newTf = timeframe.change(tf)

    if not showHistoricalLevels
        clearHistLevelLines(st)

    if not enabled
        clearLevelState(st)
    else
        if newTf
            archiveCurrentLines(st, st.curHiTime, st.curLoTime, showHistoricalLevels)

            st.lastHi := st.curHi
            st.lastLo := st.curLo
            st.lastHiTime := st.curHiTime
            st.lastLoTime := st.curLoTime

            st.curHi := high
            st.curLo := low
            st.curHiTime := time
            st.curLoTime := time
        else
            if na(st.curHi) or high > st.curHi
                st.curHi := high
                st.curHiTime := time

            if na(st.curLo) or low < st.curLo
                st.curLo := low
                st.curLoTime := time

        int x2Time = time + (time - time[1]) * poiExtendBars

        if not na(st.lastHi) and not na(st.lastHiTime)
            if na(st.hiLine)
                st.hiLine := line.new(st.lastHiTime, st.lastHi, poiExtendOn ? x2Time : time, st.lastHi, xloc = xloc.bar_time, extend = extend.none, color = hiCol, width = lineWidth, style = lineStyleFromStr(lineStyleStr))
            else
                line.set_x1(st.hiLine, st.lastHiTime)
                line.set_y1(st.hiLine, st.lastHi)
                line.set_x2(st.hiLine, poiExtendOn ? x2Time : time)
                line.set_y2(st.hiLine, st.lastHi)
                line.set_color(st.hiLine, hiCol)
                line.set_width(st.hiLine, lineWidth)
                line.set_style(st.hiLine, lineStyleFromStr(lineStyleStr))

        if not na(st.lastLo) and not na(st.lastLoTime)
            if na(st.loLine)
                st.loLine := line.new(st.lastLoTime, st.lastLo, poiExtendOn ? x2Time : time, st.lastLo, xloc = xloc.bar_time, extend = extend.none, color = loCol, width = lineWidth, style = lineStyleFromStr(lineStyleStr))
            else
                line.set_x1(st.loLine, st.lastLoTime)
                line.set_y1(st.loLine, st.lastLo)
                line.set_x2(st.loLine, poiExtendOn ? x2Time : time)
                line.set_y2(st.loLine, st.lastLo)
                line.set_color(st.loLine, loCol)
                line.set_width(st.loLine, lineWidth)
                line.set_style(st.loLine, lineStyleFromStr(lineStyleStr))
    0

highestSweptHigh(float sesHi, float a, float b, float c, float d, float e, float f) =>
    float out = na
    if not na(a) and sesHi > a
        out := a
    if not na(b) and sesHi > b and (na(out) or b > out)
        out := b
    if not na(c) and sesHi > c and (na(out) or c > out)
        out := c
    if not na(d) and sesHi > d and (na(out) or d > out)
        out := d
    if not na(e) and sesHi > e and (na(out) or e > out)
        out := e
    if not na(f) and sesHi > f and (na(out) or f > out)
        out := f
    out

lowestSweptLow(float sesLo, float a, float b, float c, float d, float e, float f) =>
    float out = na
    if not na(a) and sesLo < a
        out := a
    if not na(b) and sesLo < b and (na(out) or b < out)
        out := b
    if not na(c) and sesLo < c and (na(out) or c < out)
        out := c
    if not na(d) and sesLo < d and (na(out) or d < out)
        out := d
    if not na(e) and sesLo < e and (na(out) or e < out)
        out := e
    if not na(f) and sesLo < f and (na(out) or f < out)
        out := f
    out

classifyCompletedSession(float sesHi, float sesLo, float sesClose, float hi1, float hi2, float hi3, float hi4, float hi5, float hi6, float lo1, float lo2, float lo3, float lo4, float lo5, float lo6) =>
    float sweptHiLevel = highestSweptHigh(sesHi, hi1, hi2, hi3, hi4, hi5, hi6)
    float sweptLoLevel = lowestSweptLow(sesLo, lo1, lo2, lo3, lo4, lo5, lo6)

    bool hasHighSweep = not na(sweptHiLevel)
    bool hasLowSweep = not na(sweptLoLevel)

    bool highReversal = hasHighSweep and sesClose < sweptHiLevel
    bool lowReversal = hasLowSweep and sesClose > sweptLoLevel

    int profile = 0
    int dir = 0

    if hasHighSweep and hasLowSweep
        profile := 3
        dir := 0
    else if lowReversal
        profile := 2
        dir := 1
    else if highReversal
        profile := 2
        dir := -1
    else if hasLowSweep
        profile := 1
        dir := 1
    else if hasHighSweep
        profile := 1
        dir := -1
    else
        profile := 0
        dir := 0

    [profile, dir]

profileShortText(int profile, int dir) =>
    profile == 0 ? "≈ Consolidation" :
     profile == 1 ? dir == 1 ? "↑ Low Sweep" : dir == -1 ? "↓ High Sweep" : "◌ Manipulation" :
     profile == 2 ? dir == 1 ? "↗ Bullish Reversal" : dir == -1 ? "↘ Bearish Reversal" : "↔ Reversal" :
     "⇄ Complex"

profileColor(int profile, int dir) =>
    profile == 0 ? color.gray :
     profile == 1 ? color.orange :
     profile == 2 ? dir == 1 ? color.lime : dir == -1 ? color.red : color.white :
     color.yellow

biasText(int dir) =>
    dir == 1 ? "▲ Bullish" : dir == -1 ? "▼ Bearish" : "• Neutral"

biasColor(int dir) =>
    dir == 1 ? color.lime : dir == -1 ? color.red : color.gray

expectedBehaviorText(int prevProfile, int prevDir) =>
    prevProfile == 0 ? "↔ Manipulation + Reversal" :
     prevProfile == 1 ? prevDir == 1 ? "↗ Bullish Reversal" : prevDir == -1 ? "↘ Bearish Reversal" : "↔ Reversal" :
     prevProfile == 2 ? prevDir == 1 ? "▲ Bullish Continuation" : prevDir == -1 ? "▼ Bearish Continuation" : "→ Continuation" :
     "⇄ No Clear Expectation"

appendMergedText(string baseTxt, string addTxt) =>
    baseTxt == "" ? addTxt : baseTxt + " & " + addTxt

addMergedLevel(array<float> prices, array<string> texts, array<color> cols, float price, string txt, color txtCol) =>
    if not na(price)
        bool found = false
        if array.size(prices) > 0
            for i = 0 to array.size(prices) - 1
                if array.get(prices, i) == price
                    array.set(texts, i, appendMergedText(array.get(texts, i), txt))
                    found := true
                    break
        if not found
            array.push(prices, price)
            array.push(texts, txt)
            array.push(cols, txtCol)
    0

renderMergedLabels(array<label> outArr, array<float> prices, array<string> texts, array<color> cols, bool isHigh, string txtSizeStr) =>
    deleteAllLabels(outArr)
    if showPoiLabels and array.size(prices) > 0
        int x = poiExtendOn ? bar_index + poiExtendBars : bar_index
        for i = 0 to array.size(prices) - 1
            float y = array.get(prices, i)
            string txt = array.get(texts, i) + (isHigh ? " High" : " Low")
            color txtCol = array.get(cols, i)
            label lb = label.new(x, y, txt, xloc = xloc.bar_index, style = label.style_label_left, textcolor = txtCol, color = color.new(color.black, 100), size = labelSizeFromStr(txtSizeStr))
            array.push(outArr, lb)
    0

buildEventText(string sourceName, bool isHighSide, bool isReversal) =>
    sourceName + (isHighSide ? " High Sweep" : " Low Sweep") + (isReversal ? " & Reversal" : "")

updateRememberedStatus(string prevText, int prevDir, bool resetState, bool highSweepNow, bool lowSweepNow, bool highRevNow, bool lowRevNow, string sourceName) =>
    string outText = resetState ? "" : prevText
    int outDir = resetState ? 0 : prevDir

    if lowRevNow
        outText := buildEventText(sourceName, false, true)
        outDir := 1
    else if highRevNow
        outText := buildEventText(sourceName, true, true)
        outDir := -1
    else if lowSweepNow
        outText := buildEventText(sourceName, false, false)
        outDir := 0
    else if highSweepNow
        outText := buildEventText(sourceName, true, false)
        outDir := 0

    [outText, outDir]

matchedLevelNames(float target, float p1, string n1, float p2, string n2, float p3, string n3, float p4, string n4, float p5, string n5, float p6, string n6) =>
    string txt = ""
    if not na(target)
        if not na(p1) and p1 == target
            txt := appendMergedText(txt, n1)
        if not na(p2) and p2 == target
            txt := appendMergedText(txt, n2)
        if not na(p3) and p3 == target
            txt := appendMergedText(txt, n3)
        if not na(p4) and p4 == target
            txt := appendMergedText(txt, n4)
        if not na(p5) and p5 == target
            txt := appendMergedText(txt, n5)
        if not na(p6) and p6 == target
            txt := appendMergedText(txt, n6)
    txt

prevProfileTooltipText(string prevSessionName, int prevProfile, int prevDir, string hiDesc, string loDesc) =>
    string baseTxt = "Previous Profile means the profile of the previous session, which is " + prevSessionName + ". "
    string out = ""
    if prevProfile == 0
        out := baseTxt + "It is Consolidation because that session did not clearly sweep any tracked liquidity level."
    else if prevProfile == 1
        out := prevDir == 1 ? baseTxt + "It is Low Sweep because that session swept low-side liquidity at " + loDesc + " but did not close back with a clear reversal yet." :
         prevDir == -1 ? baseTxt + "It is High Sweep because that session swept high-side liquidity at " + hiDesc + " but did not close back with a clear reversal yet." :
         baseTxt + "It is Manipulation because one side of liquidity was swept."
    else if prevProfile == 2
        out := prevDir == 1 ? baseTxt + "It is Bullish Reversal because that session swept low-side liquidity at " + loDesc + " and then closed back above it." :
         prevDir == -1 ? baseTxt + "It is Bearish Reversal because that session swept high-side liquidity at " + hiDesc + " and then closed back below it." :
         baseTxt + "It is Reversal because a liquidity sweep happened and price reversed."
    else
        out := baseTxt + "It is Complex because that session swept both high-side liquidity at " + hiDesc + " and low-side liquidity at " + loDesc + ", so direction became mixed."
    out

prevDirectionTooltipText(string prevSessionName, int prevProfile, int prevDir) =>
    "Previous Direction is the directional result taken from the previous session profile of " + prevSessionName + ". Current value: " + biasText(prevDir) + ". Profile used: " + profileShortText(prevProfile, prevDir) + "."

expectedBehaviorTooltipText(string prevSessionName, string expectedBehavior, int prevProfile, int prevDir) =>
    "Expected Now is what the script expects from the current session based on the previous session, which is " + prevSessionName + ". Because the previous session profile is " + profileShortText(prevProfile, prevDir) + ", the script expects: " + expectedBehavior + "."

currentStatusTooltipText(string currentStatus) =>
    currentStatus == "No Sweep Yet" ? "Current Status shows the most recent remembered liquidity event. Right now no remembered sweep or reversal is active." :
     "Current Status shows the most recent remembered liquidity event that is still valid until a newer same-source event replaces it. Current remembered event: " + currentStatus + "."

structureTooltipText(string structureText) =>
    "5m/15m Structure checks simple lower timeframe confirmation. Bullish means price is above the previous 5m or 15m high. Bearish means price is below the previous 5m or 15m low. Current state: " + structureText + "."

finalBiasTooltipText(int finalBias) =>
    "Final Bias is the script's current directional decision for the active session. Current value: " + biasText(finalBias) + "."

biasReasonTooltipText(string finalReason) =>
    "Bias Reason explains why the current final bias was chosen. Current reason: " + finalReason

sessionDisplayText(string sessionName) =>
    sessionName == "None" ? "○ None" : "◉ " + sessionName

statusDisplayText(string statusText, int statusDir) =>
    statusText == "No Sweep Yet" ? "○ No Sweep Yet" :
     statusDir == 1 ? "↗ " + statusText :
     statusDir == -1 ? "↘ " + statusText :
     "◌ " + statusText

structureDisplayText(string structureText) =>
    structureText == "Bullish" ? "▲ Bullish" :
     structureText == "Bearish" ? "▼ Bearish" :
     structureText == "Off" ? "• Off" :
     "… Not Confirmed"
//#endregion FUNCTION DECLARATIONS

//#region CALCULATIONS
string h1HiTxt = tfPretty("60")
string h1LoTxt = tfPretty("60")
string h4HiTxt = tfPretty("240")
string h4LoTxt = tfPretty("240")
string pdHiTxt = "PD"
string pdLoTxt = "PD"

float h1PrevHi = h1State.lastHi
float h1PrevLo = h1State.lastLo
float h4PrevHi = h4State.lastHi
float h4PrevLo = h4State.lastLo
float pdPrevHi = pdState.lastHi
float pdPrevLo = pdState.lastLo

float m5PrevHi = request.security(syminfo.tickerid, "5", high[1], lookahead = barmerge.lookahead_on)
float m5PrevLo = request.security(syminfo.tickerid, "5", low[1], lookahead = barmerge.lookahead_on)
float m15PrevHi = request.security(syminfo.tickerid, "15", high[1], lookahead = barmerge.lookahead_on)
float m15PrevLo = request.security(syminfo.tickerid, "15", low[1], lookahead = barmerge.lookahead_on)

bool bullStructureConfirm = close > m5PrevHi or close > m15PrevHi
bool bearStructureConfirm = close < m5PrevLo or close < m15PrevLo
string structureText = not useLtfStructureConfirm ? "Off" : bullStructureConfirm ? "Bullish" : bearStructureConfirm ? "Bearish" : "Not Confirmed"
color structureColor = not useLtfStructureConfirm ? color.gray : bullStructureConfirm ? color.lime : bearStructureConfirm ? color.red : color.orange

bool inAsiaNow = not na(time(timeframe.period, sesAsia, sesTz))
bool inLondonNow = not na(time(timeframe.period, sesLondon, sesTz))
bool inNyNow = not na(time(timeframe.period, sesNy, sesTz))

int currentSessionId = inAsiaNow ? 1 : inLondonNow ? 2 : inNyNow ? 3 : 0
string currentSessionName = currentSessionId == 1 ? "Asia" : currentSessionId == 2 ? "London" : currentSessionId == 3 ? "NY" : "None"

[asiaProfile, asiaDir] = classifyCompletedSession(
     sesAsiaState.lastHi, sesAsiaState.lastLo, sesAsiaState.lastClose,
     h1PrevHi, h4PrevHi, pdPrevHi, sesLondonState.lastHi, sesNyState.lastHi, na,
     h1PrevLo, h4PrevLo, pdPrevLo, sesLondonState.lastLo, sesNyState.lastLo, na)

[londonProfile, londonDir] = classifyCompletedSession(
     sesLondonState.lastHi, sesLondonState.lastLo, sesLondonState.lastClose,
     h1PrevHi, h4PrevHi, pdPrevHi, sesAsiaState.lastHi, sesNyState.lastHi, na,
     h1PrevLo, h4PrevLo, pdPrevLo, sesAsiaState.lastLo, sesNyState.lastLo, na)

[nyProfile, nyDir] = classifyCompletedSession(
     sesNyState.lastHi, sesNyState.lastLo, sesNyState.lastClose,
     h1PrevHi, h4PrevHi, pdPrevHi, sesAsiaState.lastHi, sesLondonState.lastHi, na,
     h1PrevLo, h4PrevLo, pdPrevLo, sesAsiaState.lastLo, sesLondonState.lastLo, na)

int prevProfile = currentSessionId == 1 ? nyProfile : currentSessionId == 2 ? asiaProfile : currentSessionId == 3 ? londonProfile : 0
int prevDir = currentSessionId == 1 ? nyDir : currentSessionId == 2 ? asiaDir : currentSessionId == 3 ? londonDir : 0
string prevSessionName = currentSessionId == 1 ? "NY" : currentSessionId == 2 ? "Asia" : currentSessionId == 3 ? "London" : "None"
string expectedBehavior = expectedBehaviorText(prevProfile, prevDir)

float prevSweptHighLevel = currentSessionId == 1 ? highestSweptHigh(sesNyState.lastHi, h1PrevHi, h4PrevHi, pdPrevHi, sesAsiaState.lastHi, sesLondonState.lastHi, na) :
 currentSessionId == 2 ? highestSweptHigh(sesAsiaState.lastHi, h1PrevHi, h4PrevHi, pdPrevHi, sesLondonState.lastHi, sesNyState.lastHi, na) :
 currentSessionId == 3 ? highestSweptHigh(sesLondonState.lastHi, h1PrevHi, h4PrevHi, pdPrevHi, sesAsiaState.lastHi, sesNyState.lastHi, na) : na
float prevSweptLowLevel = currentSessionId == 1 ? lowestSweptLow(sesNyState.lastLo, h1PrevLo, h4PrevLo, pdPrevLo, sesAsiaState.lastLo, sesLondonState.lastLo, na) :
 currentSessionId == 2 ? lowestSweptLow(sesAsiaState.lastLo, h1PrevLo, h4PrevLo, pdPrevLo, sesLondonState.lastLo, sesNyState.lastLo, na) :
 currentSessionId == 3 ? lowestSweptLow(sesLondonState.lastLo, h1PrevLo, h4PrevLo, pdPrevLo, sesAsiaState.lastLo, sesNyState.lastLo, na) : na

string prevHiDesc = currentSessionId == 1 ? matchedLevelNames(prevSweptHighLevel, h1PrevHi, "1H High", h4PrevHi, "4H High", pdPrevHi, "PD High", sesAsiaState.lastHi, "Asia High", sesLondonState.lastHi, "London High", na, "") :
 currentSessionId == 2 ? matchedLevelNames(prevSweptHighLevel, h1PrevHi, "1H High", h4PrevHi, "4H High", pdPrevHi, "PD High", sesLondonState.lastHi, "London High", sesNyState.lastHi, "NY High", na, "") :
 currentSessionId == 3 ? matchedLevelNames(prevSweptHighLevel, h1PrevHi, "1H High", h4PrevHi, "4H High", pdPrevHi, "PD High", sesAsiaState.lastHi, "Asia High", sesNyState.lastHi, "NY High", na, "") : ""

string prevLoDesc = currentSessionId == 1 ? matchedLevelNames(prevSweptLowLevel, h1PrevLo, "1H Low", h4PrevLo, "4H Low", pdPrevLo, "PD Low", sesAsiaState.lastLo, "Asia Low", sesLondonState.lastLo, "London Low", na, "") :
 currentSessionId == 2 ? matchedLevelNames(prevSweptLowLevel, h1PrevLo, "1H Low", h4PrevLo, "4H Low", pdPrevLo, "PD Low", sesLondonState.lastLo, "London Low", sesNyState.lastLo, "NY Low", na, "") :
 currentSessionId == 3 ? matchedLevelNames(prevSweptLowLevel, h1PrevLo, "1H Low", h4PrevLo, "4H Low", pdPrevLo, "PD Low", sesAsiaState.lastLo, "Asia Low", sesNyState.lastLo, "NY Low", na, "") : ""

prevHiDesc := prevHiDesc == "" ? "no tracked high-side liquidity" : prevHiDesc
prevLoDesc := prevLoDesc == "" ? "no tracked low-side liquidity" : prevLoDesc

bool h1HighSweepNow = l1On and sweptHigh(h1PrevHi)
bool h1LowSweepNow = l1On and sweptLow(h1PrevLo)
bool h1HighRevNow = l1On and barHighReversal(h1PrevHi)
bool h1LowRevNow = l1On and barLowReversal(h1PrevLo)

bool h4HighSweepNow = l2On and sweptHigh(h4PrevHi)
bool h4LowSweepNow = l2On and sweptLow(h4PrevLo)
bool h4HighRevNow = l2On and barHighReversal(h4PrevHi)
bool h4LowRevNow = l2On and barLowReversal(h4PrevLo)

bool pdHighSweepNow = l3On and sweptHigh(pdPrevHi)
bool pdLowSweepNow = l3On and sweptLow(pdPrevLo)
bool pdHighRevNow = l3On and barHighReversal(pdPrevHi)
bool pdLowRevNow = l3On and barLowReversal(pdPrevLo)

bool asiaHighSweepNow = sesAsiaOn and sweptHigh(sesAsiaState.lastHi)
bool asiaLowSweepNow = sesAsiaOn and sweptLow(sesAsiaState.lastLo)
bool asiaHighRevNow = sesAsiaOn and barHighReversal(sesAsiaState.lastHi)
bool asiaLowRevNow = sesAsiaOn and barLowReversal(sesAsiaState.lastLo)

bool londonHighSweepNow = sesLondonOn and sweptHigh(sesLondonState.lastHi)
bool londonLowSweepNow = sesLondonOn and sweptLow(sesLondonState.lastLo)
bool londonHighRevNow = sesLondonOn and barHighReversal(sesLondonState.lastHi)
bool londonLowRevNow = sesLondonOn and barLowReversal(sesLondonState.lastLo)

bool nyHighSweepNow = sesNyOn and sweptHigh(sesNyState.lastHi)
bool nyLowSweepNow = sesNyOn and sweptLow(sesNyState.lastLo)
bool nyHighRevNow = sesNyOn and barHighReversal(sesNyState.lastHi)
bool nyLowRevNow = sesNyOn and barLowReversal(sesNyState.lastLo)

bool resetH1 = timeframe.change("60")
bool resetH4 = timeframe.change("240")
bool resetPd = timeframe.change("D")

bool resetAsia = not na(sesAsiaState.lastHiTime) and sesAsiaState.lastHiTime != lastSeenAsiaStamp
bool resetLondon = not na(sesLondonState.lastHiTime) and sesLondonState.lastHiTime != lastSeenLondonStamp
bool resetNy = not na(sesNyState.lastHiTime) and sesNyState.lastHiTime != lastSeenNyStamp

[h1StatusNew, h1StatusDirNew] = updateRememberedStatus(h1Status, h1StatusDir, resetH1, h1HighSweepNow, h1LowSweepNow, h1HighRevNow, h1LowRevNow, "1H")
[h4StatusNew, h4StatusDirNew] = updateRememberedStatus(h4Status, h4StatusDir, resetH4, h4HighSweepNow, h4LowSweepNow, h4HighRevNow, h4LowRevNow, "4H")
[pdStatusNew, pdStatusDirNew] = updateRememberedStatus(pdStatus, pdStatusDir, resetPd, pdHighSweepNow, pdLowSweepNow, pdHighRevNow, pdLowRevNow, "PD")
[asiaStatusNew, asiaStatusDirNew] = updateRememberedStatus(asiaStatus, asiaStatusDir, resetAsia, asiaHighSweepNow, asiaLowSweepNow, asiaHighRevNow, asiaLowRevNow, "Asia")
[londonStatusNew, londonStatusDirNew] = updateRememberedStatus(londonStatus, londonStatusDir, resetLondon, londonHighSweepNow, londonLowSweepNow, londonHighRevNow, londonLowRevNow, "London")
[nyStatusNew, nyStatusDirNew] = updateRememberedStatus(nyStatus, nyStatusDir, resetNy, nyHighSweepNow, nyLowSweepNow, nyHighRevNow, nyLowRevNow, "NY")

if h1StatusNew != h1Status or h1StatusDirNew != h1StatusDir
    h1Status := h1StatusNew
    h1StatusDir := h1StatusDirNew
    if h1Status != ""
        statusSeqCounter += 1
        h1StatusSeq := statusSeqCounter
    else
        h1StatusSeq := na

if h4StatusNew != h4Status or h4StatusDirNew != h4StatusDir
    h4Status := h4StatusNew
    h4StatusDir := h4StatusDirNew
    if h4Status != ""
        statusSeqCounter += 1
        h4StatusSeq := statusSeqCounter
    else
        h4StatusSeq := na

if pdStatusNew != pdStatus or pdStatusDirNew != pdStatusDir
    pdStatus := pdStatusNew
    pdStatusDir := pdStatusDirNew
    if pdStatus != ""
        statusSeqCounter += 1
        pdStatusSeq := statusSeqCounter
    else
        pdStatusSeq := na

if asiaStatusNew != asiaStatus or asiaStatusDirNew != asiaStatusDir
    asiaStatus := asiaStatusNew
    asiaStatusDir := asiaStatusDirNew
    if asiaStatus != ""
        statusSeqCounter += 1
        asiaStatusSeq := statusSeqCounter
    else
        asiaStatusSeq := na

if londonStatusNew != londonStatus or londonStatusDirNew != londonStatusDir
    londonStatus := londonStatusNew
    londonStatusDir := londonStatusDirNew
    if londonStatus != ""
        statusSeqCounter += 1
        londonStatusSeq := statusSeqCounter
    else
        londonStatusSeq := na

if nyStatusNew != nyStatus or nyStatusDirNew != nyStatusDir
    nyStatus := nyStatusNew
    nyStatusDir := nyStatusDirNew
    if nyStatus != ""
        statusSeqCounter += 1
        nyStatusSeq := statusSeqCounter
    else
        nyStatusSeq := na

lastSeenAsiaStamp := sesAsiaState.lastHiTime
lastSeenLondonStamp := sesLondonState.lastHiTime
lastSeenNyStamp := sesNyState.lastHiTime

string currentStatus = "No Sweep Yet"
int currentStatusDir = 0
int latestSeq = na

if not na(h1StatusSeq) and h1Status != ""
    latestSeq := h1StatusSeq
    currentStatus := h1Status
    currentStatusDir := h1StatusDir

if not na(h4StatusSeq) and (na(latestSeq) or h4StatusSeq > latestSeq) and h4Status != ""
    latestSeq := h4StatusSeq
    currentStatus := h4Status
    currentStatusDir := h4StatusDir

if not na(pdStatusSeq) and (na(latestSeq) or pdStatusSeq > latestSeq) and pdStatus != ""
    latestSeq := pdStatusSeq
    currentStatus := pdStatus
    currentStatusDir := pdStatusDir

if not na(asiaStatusSeq) and (na(latestSeq) or asiaStatusSeq > latestSeq) and asiaStatus != ""
    latestSeq := asiaStatusSeq
    currentStatus := asiaStatus
    currentStatusDir := asiaStatusDir

if not na(londonStatusSeq) and (na(latestSeq) or londonStatusSeq > latestSeq) and londonStatus != ""
    latestSeq := londonStatusSeq
    currentStatus := londonStatus
    currentStatusDir := londonStatusDir

if not na(nyStatusSeq) and (na(latestSeq) or nyStatusSeq > latestSeq) and nyStatus != ""
    latestSeq := nyStatusSeq
    currentStatus := nyStatus
    currentStatusDir := nyStatusDir

bool rememberedBullReversal = currentStatusDir == 1
bool rememberedBearReversal = currentStatusDir == -1
bool rememberedSweepOnly = currentStatus != "No Sweep Yet" and currentStatusDir == 0

color currentStatusCol = rememberedBullReversal ? color.lime : rememberedBearReversal ? color.red : rememberedSweepOnly ? color.orange : color.gray

bool currentSweptHigh = h1HighSweepNow or h4HighSweepNow or pdHighSweepNow or asiaHighSweepNow or londonHighSweepNow or nyHighSweepNow
bool currentSweptLow = h1LowSweepNow or h4LowSweepNow or pdLowSweepNow or asiaLowSweepNow or londonLowSweepNow or nyLowSweepNow

int finalBias = 0
string finalReason = "No active session"

if currentSessionId != 0
    bool bullOk = not useLtfStructureConfirm or bullStructureConfirm
    bool bearOk = not useLtfStructureConfirm or bearStructureConfirm

    if prevProfile == 0
        if rememberedBullReversal and bullOk
            finalBias := 1
            finalReason := "Previous session consolidated. Current session swept lows and reversed."
        else if rememberedBearReversal and bearOk
            finalBias := -1
            finalReason := "Previous session consolidated. Current session swept highs and reversed."
        else
            finalBias := 0
            finalReason := "Waiting for current session manipulation + reversal."
    else if prevProfile == 1
        if prevDir == 1 and rememberedBullReversal and bullOk
            finalBias := 1
            finalReason := "Previous session low sweep only. Current session confirmed bullish reversal."
        else if prevDir == -1 and rememberedBearReversal and bearOk
            finalBias := -1
            finalReason := "Previous session high sweep only. Current session confirmed bearish reversal."
        else
            finalBias := 0
            finalReason := "Waiting for reversal confirmation."
    else if prevProfile == 2
        if prevDir == 1 and bullOk
            finalBias := 1
            finalReason := "Previous session bullish reversal. Expect continuation higher."
        else if prevDir == -1 and bearOk
            finalBias := -1
            finalReason := "Previous session bearish reversal. Expect continuation lower."
        else
            finalBias := 0
            finalReason := "Waiting for continuation confirmation."
    else
        finalBias := 0
        finalReason := "Previous session profile is complex."

string currentSessionTip = "Current value: " + currentSessionName + "."
string prevSessionTip = "Current value: " + prevSessionName + "."
string prevProfileTip = prevProfileTooltipText(prevSessionName, prevProfile, prevDir, prevHiDesc, prevLoDesc)
string prevDirectionTip = prevDirectionTooltipText(prevSessionName, prevProfile, prevDir)
string expectedBehaviorTip = expectedBehaviorTooltipText(prevSessionName, expectedBehavior, prevProfile, prevDir)
string currentStatusTip = currentStatusTooltipText(currentStatus)
string structureTip = structureTooltipText(structureText)
string finalBiasTip = finalBiasTooltipText(finalBias)
string finalReasonTip = biasReasonTooltipText(finalReason)

string currentSessionDisplay = sessionDisplayText(currentSessionName)
string prevSessionDisplay = sessionDisplayText(prevSessionName)
string currentStatusDisplay = statusDisplayText(currentStatus, currentStatusDir)
string structureDisplay = structureDisplayText(structureText)
//#endregion CALCULATIONS

//#region VISUALS
sesAsiaState.process(sesAsiaOn, "Asia", sesAsia, 20, 0, 22, 0, sesAsiaCol, sesShowLabels, sesLabelSizeStr, sesAsiaHiCol, sesAsiaLoCol, sesLineStyleStr, sesLineWidth)
sesLondonState.process(sesLondonOn, "London", sesLondon, 2, 0, 4, 0, sesLondonCol, sesShowLabels, sesLabelSizeStr, sesLondonHiCol, sesLondonLoCol, sesLineStyleStr, sesLineWidth)
sesNyState.process(sesNyOn, "NY", sesNy, 10, 0, 12, 0, sesNyCol, sesShowLabels, sesLabelSizeStr, sesNyHiCol, sesNyLoCol, sesLineStyleStr, sesLineWidth)

updatePrevHl(h1State, l1On, "60", l1HiCol, l1LoCol, poiExtendOn, poiExtendBars, poiLineStyleStr, poiLineWidth)
updatePrevHl(h4State, l2On, "240", l2HiCol, l2LoCol, poiExtendOn, poiExtendBars, poiLineStyleStr, poiLineWidth)
updatePrevHl(pdState, l3On, "D", l3HiCol, l3LoCol, poiExtendOn, poiExtendBars, poiLineStyleStr, poiLineWidth)

array<float> mergedHighPrices = array.new_float()
array<string> mergedHighTexts = array.new_string()
array<color> mergedHighCols = array.new_color()
array<float> mergedLowPrices = array.new_float()
array<string> mergedLowTexts = array.new_string()
array<color> mergedLowCols = array.new_color()

if l1On
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, h1PrevHi, "1H", poiLabelCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, h1PrevLo, "1H", poiLabelCol)

if l2On
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, h4PrevHi, "4H", poiLabelCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, h4PrevLo, "4H", poiLabelCol)

if l3On
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, pdPrevHi, "PD", poiLabelCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, pdPrevLo, "PD", poiLabelCol)

if sesAsiaOn
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, sesAsiaState.lastHi, "Asia", sesAsiaHiCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, sesAsiaState.lastLo, "Asia", sesAsiaLoCol)

if sesLondonOn
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, sesLondonState.lastHi, "London", sesLondonHiCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, sesLondonState.lastLo, "London", sesLondonLoCol)

if sesNyOn
    addMergedLevel(mergedHighPrices, mergedHighTexts, mergedHighCols, sesNyState.lastHi, "NY", sesNyHiCol)
    addMergedLevel(mergedLowPrices, mergedLowTexts, mergedLowCols, sesNyState.lastLo, "NY", sesNyLoCol)

renderMergedLabels(mergedHighLabels, mergedHighPrices, mergedHighTexts, mergedHighCols, true, poiLabelSizeStr)
renderMergedLabels(mergedLowLabels, mergedLowPrices, mergedLowTexts, mergedLowCols, false, poiLabelSizeStr)

plotshape(showSweepMarkers and currentSweptHigh, title = "High Sweep", style = shape.diamond, location = location.abovebar, color = color.red, size = size.tiny)
plotshape(showSweepMarkers and currentSweptLow, title = "Low Sweep", style = shape.diamond, location = location.belowbar, color = color.green, size = size.tiny)

// This block draws a dashboard.
if showDashboardTable
    if na(dashboardTable)
        dashboardTable := table.new(position.top_right, 2, 13, border_width = 1)

    dashSize = labelSizeFromStr(biasTextSizeStr)
    color bgMain = color.rgb(18, 18, 24)
    color bgHeader = color.rgb(28, 32, 44)
    color bgSection = color.rgb(32, 36, 50)
    color bgRowA = color.rgb(24, 28, 38)
    color bgRowB = color.rgb(20, 24, 34)
    color txtMain = color.white
    color txtMuted = color.rgb(185, 190, 200)

    table.cell(dashboardTable, 0, 0, "DAILY BIAS DASHBOARD", text_color = txtMain, bgcolor = bgHeader, text_size = size.normal, text_halign = text.align_center)
    table.cell(dashboardTable, 1, 0, "", text_color = txtMain, bgcolor = bgHeader, text_size = size.normal)
    table.merge_cells(dashboardTable, 0, 0, 1, 0)

    table.cell(dashboardTable, 0, 1, "SESSION CONTEXT", text_color = txtMain, bgcolor = bgSection, text_size = dashSize, text_halign = text.align_center)
    table.cell(dashboardTable, 1, 1, "", text_color = txtMain, bgcolor = bgSection, text_size = dashSize)
    table.merge_cells(dashboardTable, 0, 1, 1, 1)

    table.cell(dashboardTable, 0, 2, "Current Session", text_color = txtMuted, bgcolor = bgRowA, text_size = dashSize, tooltip = "Current Session means the session price is trading in right now.")
    table.cell(dashboardTable, 1, 2, currentSessionDisplay, text_color = currentSessionId == 1 ? sesAsiaHiCol : currentSessionId == 2 ? sesLondonHiCol : currentSessionId == 3 ? sesNyLoCol : color.gray, bgcolor = bgRowA, text_size = dashSize, tooltip = currentSessionTip)

    table.cell(dashboardTable, 0, 3, "Previous Session", text_color = txtMuted, bgcolor = bgRowB, text_size = dashSize, tooltip = "Previous Session means the session immediately before the current one.")
    table.cell(dashboardTable, 1, 3, prevSessionDisplay, text_color = color.white, bgcolor = bgRowB, text_size = dashSize, tooltip = prevSessionTip)

    table.cell(dashboardTable, 0, 4, "Current Status", text_color = txtMuted, bgcolor = bgRowA, text_size = dashSize, tooltip = "Current Status remembers the most recent valid liquidity event from the tracked sources.")
    table.cell(dashboardTable, 1, 4, currentStatusDisplay, text_color = currentStatusCol, bgcolor = bgRowA, text_size = dashSize, tooltip = currentStatusTip)

    table.cell(dashboardTable, 0, 5, "BIAS ENGINE", text_color = txtMain, bgcolor = bgSection, text_size = dashSize, text_halign = text.align_center)
    table.cell(dashboardTable, 1, 5, "", text_color = txtMain, bgcolor = bgSection, text_size = dashSize)
    table.merge_cells(dashboardTable, 0, 5, 1, 5)

    table.cell(dashboardTable, 0, 6, "Previous Profile", text_color = txtMuted, bgcolor = bgRowB, text_size = dashSize, tooltip = "Previous Profile classifies what the previous session did with tracked liquidity.")
    table.cell(dashboardTable, 1, 6, profileShortText(prevProfile, prevDir), text_color = profileColor(prevProfile, prevDir), bgcolor = bgRowB, text_size = dashSize, tooltip = prevProfileTip)

    table.cell(dashboardTable, 0, 7, "Previous Direction", text_color = txtMuted, bgcolor = bgRowA, text_size = dashSize, tooltip = "Previous Direction is the directional takeaway from the previous session profile.")
    table.cell(dashboardTable, 1, 7, biasText(prevDir), text_color = biasColor(prevDir), bgcolor = bgRowA, text_size = dashSize, tooltip = prevDirectionTip)

    table.cell(dashboardTable, 0, 8, "Expected Now", text_color = txtMuted, bgcolor = bgRowB, text_size = dashSize, tooltip = "Expected Now shows what the script expects from the current session based on the previous session.")
    table.cell(dashboardTable, 1, 8, expectedBehavior, text_color = profileColor(prevProfile, prevDir), bgcolor = bgRowB, text_size = dashSize, tooltip = expectedBehaviorTip)

    table.cell(dashboardTable, 0, 9, "5m/15m Structure", text_color = txtMuted, bgcolor = bgRowA, text_size = dashSize, tooltip = "This shows whether lower timeframe structure is confirming bullish or bearish direction.")
    table.cell(dashboardTable, 1, 9, structureDisplay, text_color = structureColor, bgcolor = bgRowA, text_size = dashSize, tooltip = structureTip)

    table.cell(dashboardTable, 0, 10, "Final Bias", text_color = txtMuted, bgcolor = bgRowB, text_size = dashSize, tooltip = "Final Bias is the script's current directional decision.")
    table.cell(dashboardTable, 1, 10, biasText(finalBias), text_color = biasColor(finalBias), bgcolor = bgRowB, text_size = dashSize, tooltip = finalBiasTip)

    table.cell(dashboardTable, 0, 11, "REASON", text_color = txtMain, bgcolor = bgSection, text_size = dashSize, text_halign = text.align_center)
    table.cell(dashboardTable, 1, 11, "", text_color = txtMain, bgcolor = bgSection, text_size = dashSize)
    table.merge_cells(dashboardTable, 0, 11, 1, 11)

    table.cell(dashboardTable, 0, 12, "• " + finalReason, text_color = color.white, bgcolor = bgMain, text_size = dashSize, tooltip = finalReasonTip, text_halign = text.align_left)
    table.cell(dashboardTable, 1, 12, "", text_color = color.white, bgcolor = bgMain, text_size = dashSize)
    table.merge_cells(dashboardTable, 0, 12, 1, 12)
else
    if not na(dashboardTable)
        table.delete(dashboardTable)
        dashboardTable := na
//#endregion VISUALS
````
