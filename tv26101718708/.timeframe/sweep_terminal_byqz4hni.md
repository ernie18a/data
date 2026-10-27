# Sweep Terminal

- url: https://www.tradingview.com/script/byQZ4HnI-Sweep-Terminal/
- type: indicator
- pine_id: PUB;4f417da829eb4159ac493e41943c2785
- version: 2.0

## Description

Sweep Terminal [erdensedat]
Description:
Welcome to Sweep Terminal, an elite all-in-one institutional trading indicator designed for maximum precision. Developed by erdensedat, this tool provides unparalleled clarity on price action, liquidity sweeps, market structure shifts, and daily biases—all without cluttering your chart. It seamlessly integrates Multi-Timeframe (MTF) analysis, an advanced Fair Value Gap (FVG) engine, dynamic BOS/CHoCH mapping, and real-time session tracking.

Core Features:
1. Live Market Info Panel
A dynamic, non-intrusive table situated at the top right of your screen providing instant, actionable data:

Directional Biases: Instantly know the Daily, Weekly, and VWAP bias (Bullish/Bearish).
Momentum & Trend: Real-time RSI momentum value and raw DI+ / DI- (Directional Movement) data. The dominant DI force is automatically color-coded for quick visual confirmation.
Active Structure: Displays the most recent character of the market (Bullish/Bearish Structure).
Session Status: Real-time sync with the Europe/Istanbul timezone. Displays exactly which session is active (Asian, London, NY) or which one is upcoming, indicated by active Green/Red LED dots.
2. MTF Sweep Logic & Opening Ranges
Understanding where liquidity lies is crucial. This module automatically detects and highlights major High/Low levels across key timeframes (1 Hour, 4 Hour, 1 Daily).

Sweep & Raid Detection: Highlights potential liquidity sweeps (shadow boxes) in real-time and explicitly marks confirmed "Raids" with directional triangles once the price deviates and closes back within the range.
Discount/Premium Pricing: H/L pivot lines clearly dictate "Premium" (Short) and "Discount" (Long) equilibrium zones.
Session Killzone Pivots (Optional): Tracks session highs and lows. Once a session level is breached, the line freezes at the breakout point, turns dotted, and marks the raid with a clean "X" at the center.
3. Advanced Fair Value Gap (FVG) Engine
Our refined FVG engine ensures you only see the most significant imbalances.

Clean Visualization: Bullish FVG boxes default to a deep teal (#006064) and bearish to a dark crimson (#801922), complete with lightly opaque mid-lines for precise entries.
Smart Filtering: Removes overlapping FVGs, filters by threshold sizes, and offers customizable mitigation triggers (Close, Wick, or Average price).
Breaker Blocks: Seamlessly toggle between standard FVGs or Breaker block tracking.
4. Dynamic BOS & CHoCH Mapping
Stay on the right side of the trend with an automated structure mapping algorithm based on pivot fractals.

Pre-Break Candidates: Anticipate structure shifts with dashed candidate lines marking unmitigated Pivot Highs and Lows.
Confirmed Breaks: Once a level is breached, the line solidifies. Includes smart alert routing for instant notifications on structural shifts.
How to Use:
Liquidity Traps: Use the MTF Sweep Logic to spot when retail stops are triggered above a 4H or Daily high, providing high-probability mean reversion setups.
Confluence Trading: Check the live Panel. If the Daily/Weekly bias is Bullish, look for a Discount zone test, wait for a Bullish CHoCH, and enter on a lower timeframe FVG mid-line.
Customization: The settings menu is highly compartmentalized. Isolate specific logic (e.g., only show 1D sweeps, VWAP, and FVG) allowing this indicator to adapt perfectly to any Smart Money Concept (SMC) or ICT-based strategy.
Dedicated to clean charts and precise execution.

Disclaimer:
The information, scripts, and features provided by this tool are for educational and informational purposes only and do not constitute financial, investment, or trading advice. Trading in financial markets (including cryptocurrencies, forex, and stocks) involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always conduct your own thorough research, backtest thoroughly, and consult with a certified financial advisor before making any trading decisions. The author (erdensedat) assumes no responsibility for any financial losses or damages incurred while using this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Sweep Terminal", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, calc_bars_count = 50000)

// --- Constants ---
const string TZ_STRING = "Europe/Istanbul"
const int SLOT_COUNT = 3
const int MAX_SWEEP_BOXES = 120
const int MAX_FVG_STORED = 100

// --- Inputs: MTF Logic ---
string groupLogic = "MTF Logic Settings"
bool showHtf1 = input.bool(false, "Enable HTF 1", inline = "htf1", group = groupLogic, tooltip = "Enables the first selectable higher-timeframe module.")
string htf1Input = input.timeframe("60", "Timeframe", inline = "htf1", group = groupLogic, tooltip = "Timeframe used for HTF 1.")
string range1Input = input.timeframe("30", "Initial Range", inline = "rng1", group = groupLogic, tooltip = "Initial range duration for HTF 1. Invalid combinations are adjusted automatically.")
bool showHtf2 = input.bool(false, "Enable HTF 2", inline = "htf2", group = groupLogic, tooltip = "Enables the second selectable higher-timeframe module.")
string htf2Input = input.timeframe("240", "Timeframe", inline = "htf2", group = groupLogic, tooltip = "Timeframe used for HTF 2.")
string range2Input = input.timeframe("120", "Initial Range", inline = "rng2", group = groupLogic, tooltip = "Initial range duration for HTF 2. Invalid combinations are adjusted automatically.")
bool showHtf3 = input.bool(true, "Enable HTF 3", inline = "htf3", group = groupLogic, tooltip = "Enables the third selectable higher-timeframe module.")
string htf3Input = input.timeframe("1D", "Timeframe", inline = "htf3", group = groupLogic, tooltip = "Timeframe used for HTF 3.")
string range3Input = input.timeframe("240", "Initial Range", inline = "rng3", group = groupLogic, tooltip = "Initial range duration for HTF 3. Invalid combinations are adjusted automatically.")

// --- Inputs: Theme & Style ---
string groupTheme = "Theme & Colors"
color bullColor = input.color(#089981, "Bullish Color", group = groupTheme, tooltip = "Color for bullish levels and signals.")
color bearColor = input.color(#f23645, "Bearish Color", group = groupTheme, tooltip = "Color for bearish levels and signals.")
color waitingColor = input.color(#ff9800, "Sweep Watching Color", group = groupTheme, tooltip = "Color of an unconfirmed sweep area.")
color openingLineColor = input.color(#5b9cf6, "Opening Line Color", group = groupTheme, tooltip = "Color of HTF opening lines.")
color rangeBoxColor = input.color(color.new(color.gray, 92), "Initial Range Fill", group = groupTheme, tooltip = "Fill color of initial range boxes.")
color rangeBoxBorder = input.color(color.new(color.gray, 60), "Initial Range Border", group = groupTheme, tooltip = "Border color of initial range boxes.")

string groupOpening = "Opening Line Settings"
int showLastNOpening = input.int(1, "Show Last N Opening Lines", minval = 1, maxval = 50, group = groupOpening, tooltip = "Number of opening lines retained per enabled HTF.")
bool showSweepWatching = input.bool(true, "Show Sweep Watching", group = groupOpening, tooltip = "Displays developing sweep areas before confirmation.")

string groupRange = "Initial Range Trend / Info"
bool showRangeTrendInfo = input.bool(true, "Show Range Trend + Info", group = groupRange, tooltip = "Displays the initial range trend, statistics and projected high/low levels.")
int trendLineWidth = input.int(2, "Trend Line Width", minval = 1, maxval = 5, group = groupRange, tooltip = "Width of the range trend line.")
int rangeDotWidth = input.int(1, "HH/LL Dotted Width", minval = 1, maxval = 5, group = groupRange, tooltip = "Width of projected range high/low lines.")
int labelOffsetBars = input.int(2, "Right Label Offset", minval = 1, maxval = 20, group = groupRange, tooltip = "Horizontal offset of previous HTF high/low labels.")
color upTrendColor = input.color(color.gray, "Up Trend Line", group = groupRange, tooltip = "Color of bullish initial-range trend lines.")
color downTrendColor = input.color(color.gray, "Down Trend Line", group = groupRange, tooltip = "Color of bearish initial-range trend lines.")
color infoTextColor = input.color(color.gray, "Range Info Text", group = groupRange, tooltip = "Text color of initial-range statistics.")
color rangeDotColor = input.color(color.gray, "HH/LL Projection", group = groupRange, tooltip = "Color of projected initial-range high/low lines.")

string groupLabels = "All Labels / Text Size"
string labelSizeInput = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal"], group = groupLabels, tooltip = "Text size used by MTF labels.")

// --- Inputs: Fair Value Gaps ---
string groupFvg = "FAIR VALUE GAP"
bool fvgEnable = input.bool(true, "Enable FVG", inline = "fvg1", group = groupFvg, tooltip = "Displays fair value gaps.")
string fvgMode = input.string("FVG", "Type", options = ["FVG", "Breakers"], inline = "fvg1", group = groupFvg, tooltip = "FVG removes mitigated gaps. Breakers keeps the reversed portion until invalidation.")
int fvgCount = input.int(5, "Show Last", minval = 0, maxval = 50, group = groupFvg, tooltip = "Maximum recent gaps displayed.")
color fvgBullColor = input.color(color.new(#006064, 80), "Bull", inline = "fvg2", group = groupFvg, tooltip = "Bullish gap color.")
color fvgBearColor = input.color(color.new(#801922, 80), "Bear", inline = "fvg2", group = groupFvg, tooltip = "Bearish gap color.")
color fvgBullMid = input.color(color.new(#089981, 10), "Bull Midline", inline = "fvg3", group = groupFvg, tooltip = "Bullish gap midpoint color.")
color fvgBearMid = input.color(color.new(#f23645, 10), "Bear Midline", inline = "fvg3", group = groupFvg, tooltip = "Bearish gap midpoint color.")
string fvgSource = input.string("Close", "Mitigation", options = ["Close", "Wick", "Avg"], group = groupFvg, tooltip = "Price source used to determine mitigation.")
float fvgThreshold = input.float(0.0, "ATR Threshold", minval = 0.0, maxval = 2.0, step = 0.1, group = groupFvg, tooltip = "Minimum gap size as a multiple of ATR.")
bool fvgHideOverlap = input.bool(true, "Hide Overlap", group = groupFvg, tooltip = "Removes older overlapping gaps in the same direction.")
bool fvgShowMid = input.bool(true, "Show Mid-Line", group = groupFvg, tooltip = "Displays gap midpoint lines.")
bool fvgExtend = input.bool(false, "Extend FVG", group = groupFvg, tooltip = "Extends active gaps to the right.")
bool fvgShowRaids = input.bool(false, "Display Raids", group = groupFvg, tooltip = "Marks wick raids that close back outside a gap.")

// --- Inputs: BOS / CHoCH ---
string groupBos = "BOS / CHoCH Settings"
bool showBos = input.bool(true, "Enable BOS / CHoCH", group = groupBos, tooltip = "Enables market-structure breaks.")
int bosLengthInput = input.int(10, "Fractal Length", minval = 3, maxval = 51, group = groupBos, tooltip = "Pivot window. Even values are converted to the next odd value.")
int barsToRight = input.int(10, "Bars to Right", minval = 1, maxval = 300, group = groupBos, tooltip = "Candidate line projection in chart bars.")
bool requireBody = input.bool(true, "Break = Close Beyond Level", group = groupBos, tooltip = "Uses close instead of wick for structure confirmation.")
int showLastBroken = input.int(3, "Show Last N Broken (0 = all)", minval = 0, maxval = 200, group = groupBos, tooltip = "Number of historical broken levels retained.")
int calcLastBars = input.int(20000, "Calculate Last N Bars (0 = all)", minval = 0, maxval = 50000, group = groupBos, tooltip = "Limits structure calculations for performance.")
color candidateUpColor = input.color(#089981, "Candidate UP", group = groupBos, tooltip = "Bullish candidate level color.")
color candidateDownColor = input.color(#f23645, "Candidate DN", group = groupBos, tooltip = "Bearish candidate level color.")
color brokenUpColor = input.color(#089981, "Broken UP", group = groupBos, tooltip = "Bullish broken level color.")
color brokenDownColor = input.color(#f23645, "Broken DN", group = groupBos, tooltip = "Bearish broken level color.")
string candidateStyleInput = input.string("Dashed", "Candidate Style", options = ["Solid", "Dashed", "Dotted"], group = groupBos, tooltip = "Line style for candidate levels.")
string brokenStyleInput = input.string("Solid", "Broken Style", options = ["Solid", "Dashed", "Dotted"], group = groupBos, tooltip = "Line style for confirmed levels.")
int candidateWidth = input.int(1, "Candidate Width", minval = 1, maxval = 5, group = groupBos, tooltip = "Candidate line width.")
int brokenWidth = input.int(1, "Broken Width", minval = 1, maxval = 5, group = groupBos, tooltip = "Confirmed line width.")
bool showCandidateText = input.bool(true, "Show Candidate Text", group = groupBos, tooltip = "Displays text on active candidate levels.")
bool showBosLabels = input.bool(true, "Show BOS/CHoCH Labels", group = groupBos, tooltip = "Displays labels on confirmed structure breaks.")
bool showPivotMarks = input.bool(false, "Show Pivot Marks", group = groupBos, tooltip = "Displays confirmed pivot markers.")
string bosLabelSizeInput = input.string("small", "BOS Label Size", options = ["tiny", "small", "normal"], group = groupBos, tooltip = "Size of structure labels.")

// --- Inputs: VWAP and Sessions ---
string groupVwap = "VWAP Settings"
bool showVwap = input.bool(false, "Enable VWAP", group = groupVwap, tooltip = "Displays session VWAP.")
color vwapColor = input.color(#5b9cf6, "VWAP Color", group = groupVwap, tooltip = "VWAP line color.")

string groupSession = "Session Pivots"
bool showSessionPivots = input.bool(false, "Show Session H/L", group = groupSession, tooltip = "Displays completed Asian, London and New York session extremes.")
color sessionPivotColor = input.color(color.orange, "Session Pivot Color", group = groupSession, tooltip = "Color of session high/low levels.")

// --- Helpers ---
f_label_size(string value) =>
    value == "Tiny" or value == "tiny" ? size.tiny : value == "Small" or value == "small" ? size.small : size.normal

f_line_style(string value) =>
    value == "Solid" ? line.style_solid : value == "Dashed" ? line.style_dashed : line.style_dotted

f_tf_label(string tf) =>
    int seconds = timeframe.in_seconds(tf)
    tf == "D" or tf == "1D" ? "1D" : tf == "W" or tf == "1W" ? "1W" : tf == "M" or tf == "1M" ? "1M" : seconds < 60 ? str.tostring(seconds) + "S" : seconds < 3600 or seconds % 3600 != 0 ? str.tostring(int(seconds / 60)) + "m" : seconds < 86400 ? str.tostring(int(seconds / 3600)) + "H" : tf

f_format_time(int timestamp, string tf) =>
    timeframe.in_seconds(tf) >= 86400 ? str.format_time(timestamp, "dd MMM", TZ_STRING) : str.format_time(timestamp, "HH:mm", TZ_STRING)

f_format_volume(float value) =>
    value >= 1e9 ? str.tostring(value / 1e9, "#.##") + "B" : value >= 1e6 ? str.tostring(value / 1e6, "#.##") + "M" : value >= 1e3 ? str.tostring(value / 1e3, "#.##") + "K" : str.tostring(value, "#")

f_percent(float fromValue, float toValue) =>
    fromValue != 0.0 ? (toValue - fromValue) / fromValue * 100.0 : 0.0

f_effective_range_seconds(string htf, string rangeTf) =>
    int chartSeconds = timeframe.in_seconds()
    int htfSeconds = timeframe.in_seconds(htf)
    int requestedSeconds = timeframe.in_seconds(rangeTf)
    math.max(1, math.min(math.max(requestedSeconds, math.min(chartSeconds, htfSeconds)), math.max(chartSeconds, htfSeconds)))

labelSize = f_label_size(labelSizeInput)
bosLabelSize = f_label_size(bosLabelSizeInput)

// --- MTF Data ---
[prevHigh1, prevLow1, prevTime1, currentOpen1, currentTime1] = request.security(syminfo.tickerid, htf1Input, [high[1], low[1], time[1], open, time], lookahead = barmerge.lookahead_on)
[prevHigh2, prevLow2, prevTime2, currentOpen2, currentTime2] = request.security(syminfo.tickerid, htf2Input, [high[1], low[1], time[1], open, time], lookahead = barmerge.lookahead_on)
[prevHigh3, prevLow3, prevTime3, currentOpen3, currentTime3] = request.security(syminfo.tickerid, htf3Input, [high[1], low[1], time[1], open, time], lookahead = barmerge.lookahead_on)

int htfStart1 = time(htf1Input)
int htfStart2 = time(htf2Input)
int htfStart3 = time(htf3Input)
bool newHtf1 = ta.change(htfStart1) != 0
bool newHtf2 = ta.change(htfStart2) != 0
bool newHtf3 = ta.change(htfStart3) != 0

// --- MTF Initial Range Storage ---
var array<box> rangeBoxes = array.new<box>(SLOT_COUNT, na)
var array<line> rangeHighLines = array.new<line>(SLOT_COUNT, na)
var array<line> rangeLowLines = array.new<line>(SLOT_COUNT, na)
var array<label> rangeHighLabels = array.new<label>(SLOT_COUNT, na)
var array<label> rangeLowLabels = array.new<label>(SLOT_COUNT, na)
var array<line> rangeTrendLines = array.new<line>(SLOT_COUNT, na)
var array<label> rangeInfoLabels = array.new<label>(SLOT_COUNT, na)
var array<line> rangeProjectedHighs = array.new<line>(SLOT_COUNT, na)
var array<line> rangeProjectedLows = array.new<line>(SLOT_COUNT, na)
var array<int> rangeStartTimes = array.new_int(SLOT_COUNT, na)
var array<float> rangeOpens = array.new_float(SLOT_COUNT, na)
var array<float> rangeCloses = array.new_float(SLOT_COUNT, na)
var array<float> rangeHighs = array.new_float(SLOT_COUNT, na)
var array<float> rangeLows = array.new_float(SLOT_COUNT, na)
var array<int> rangeHighTimes = array.new_int(SLOT_COUNT, na)
var array<int> rangeLowTimes = array.new_int(SLOT_COUNT, na)
var array<float> rangeVolumes = array.new_float(SLOT_COUNT, 0.0)

f_delete_range_objects(int slot) =>
    box rangeBoxId = array.get(rangeBoxes, slot)
    line highLineId = array.get(rangeHighLines, slot)
    line lowLineId = array.get(rangeLowLines, slot)
    label highLabelId = array.get(rangeHighLabels, slot)
    label lowLabelId = array.get(rangeLowLabels, slot)
    line trendLineId = array.get(rangeTrendLines, slot)
    label infoLabelId = array.get(rangeInfoLabels, slot)
    line projectedHighId = array.get(rangeProjectedHighs, slot)
    line projectedLowId = array.get(rangeProjectedLows, slot)
    if not na(rangeBoxId)
        box.delete(rangeBoxId)
    if not na(highLineId)
        line.delete(highLineId)
    if not na(lowLineId)
        line.delete(lowLineId)
    if not na(highLabelId)
        label.delete(highLabelId)
    if not na(lowLabelId)
        label.delete(lowLabelId)
    if not na(trendLineId)
        line.delete(trendLineId)
    if not na(infoLabelId)
        label.delete(infoLabelId)
    if not na(projectedHighId)
        line.delete(projectedHighId)
    if not na(projectedLowId)
        line.delete(projectedLowId)
    array.set(rangeBoxes, slot, na)
    array.set(rangeHighLines, slot, na)
    array.set(rangeLowLines, slot, na)
    array.set(rangeHighLabels, slot, na)
    array.set(rangeLowLabels, slot, na)
    array.set(rangeTrendLines, slot, na)
    array.set(rangeInfoLabels, slot, na)
    array.set(rangeProjectedHighs, slot, na)
    array.set(rangeProjectedLows, slot, na)

f_update_initial_range(int slot, bool enabled, bool newPeriod, string htf, string rangeTf, int width) =>
    if not enabled
        f_delete_range_objects(slot)
        array.set(rangeStartTimes, slot, na)
    else if newPeriod
        f_delete_range_objects(slot)
        int startTime = time
        string rangeName = f_tf_label(rangeTf)
        box rangeBoxId = box.new(left = time, top = high, right = time, bottom = low, xloc = xloc.bar_time, border_color = rangeBoxBorder, bgcolor = rangeBoxColor)
        line highLineId = line.new(time, high, time, high, xloc = xloc.bar_time, color = bearColor, style = line.style_dashed, width = width)
        line lowLineId = line.new(time, low, time, low, xloc = xloc.bar_time, color = bullColor, style = line.style_dashed, width = width)
        label highLabelId = label.new(time, high, rangeName + " H", xloc = xloc.bar_time, color = #00000000, textcolor = bearColor, style = label.style_label_down, size = labelSize)
        label lowLabelId = label.new(time, low, rangeName + " L", xloc = xloc.bar_time, color = #00000000, textcolor = bullColor, style = label.style_label_up, size = labelSize)
        array.set(rangeBoxes, slot, rangeBoxId)
        array.set(rangeHighLines, slot, highLineId)
        array.set(rangeLowLines, slot, lowLineId)
        array.set(rangeHighLabels, slot, highLabelId)
        array.set(rangeLowLabels, slot, lowLabelId)
        array.set(rangeStartTimes, slot, startTime)
        array.set(rangeOpens, slot, open)
        array.set(rangeCloses, slot, close)
        array.set(rangeHighs, slot, high)
        array.set(rangeLows, slot, low)
        array.set(rangeHighTimes, slot, time)
        array.set(rangeLowTimes, slot, time)
        array.set(rangeVolumes, slot, volume)
    else
        int startTime = array.get(rangeStartTimes, slot)
        box rangeBoxId = array.get(rangeBoxes, slot)
        if not na(startTime) and not na(rangeBoxId)
            int rangeSeconds = f_effective_range_seconds(htf, rangeTf)
            int rangeEnd = startTime + rangeSeconds * 1000
            int fallbackEnd = startTime + timeframe.in_seconds(htf) * 1000
            int periodEnd = nz(time_close(htf), fallbackEnd)
            if time < rangeEnd
                float storedHigh = math.max(array.get(rangeHighs, slot), high)
                float storedLow = math.min(array.get(rangeLows, slot), low)
                array.set(rangeCloses, slot, close)
                array.set(rangeVolumes, slot, array.get(rangeVolumes, slot) + volume)
                if high >= storedHigh
                    array.set(rangeHighTimes, slot, time)
                if low <= storedLow
                    array.set(rangeLowTimes, slot, time)
                array.set(rangeHighs, slot, storedHigh)
                array.set(rangeLows, slot, storedLow)
                box.set_top(rangeBoxId, storedHigh)
                box.set_bottom(rangeBoxId, storedLow)
                box.set_right(rangeBoxId, time)
                line highLineId = array.get(rangeHighLines, slot)
                line lowLineId = array.get(rangeLowLines, slot)
                label highLabelId = array.get(rangeHighLabels, slot)
                label lowLabelId = array.get(rangeLowLabels, slot)
                line.set_xy1(highLineId, startTime, storedHigh)
                line.set_xy2(highLineId, time, storedHigh)
                line.set_xy1(lowLineId, startTime, storedLow)
                line.set_xy2(lowLineId, time, storedLow)
                label.set_xy(highLabelId, time, storedHigh)
                label.set_xy(lowLabelId, time, storedLow)
            else
                float storedHigh = array.get(rangeHighs, slot)
                float storedLow = array.get(rangeLows, slot)
                line highLineId = array.get(rangeHighLines, slot)
                line lowLineId = array.get(rangeLowLines, slot)
                label highLabelId = array.get(rangeHighLabels, slot)
                label lowLabelId = array.get(rangeLowLabels, slot)
                box.set_right(rangeBoxId, rangeEnd)
                line.set_x2(highLineId, rangeEnd)
                line.set_x2(lowLineId, rangeEnd)
                line.set_style(highLineId, line.style_solid)
                line.set_style(lowLineId, line.style_solid)
                label.set_xy(highLabelId, periodEnd, storedHigh)
                label.set_xy(lowLabelId, periodEnd, storedLow)
                if showRangeTrendInfo and na(array.get(rangeTrendLines, slot))
                    float storedOpen = array.get(rangeOpens, slot)
                    float storedClose = array.get(rangeCloses, slot)
                    bool bullishRange = storedClose >= storedOpen
                    int highTime = array.get(rangeHighTimes, slot)
                    int lowTime = array.get(rangeLowTimes, slot)
                    line trendId = bullishRange ? line.new(lowTime, storedLow, highTime, storedHigh, xloc = xloc.bar_time, color = upTrendColor, width = trendLineWidth) : line.new(highTime, storedHigh, lowTime, storedLow, xloc = xloc.bar_time, color = downTrendColor, width = trendLineWidth)
                    float offset = math.max(storedHigh - storedLow, syminfo.mintick) * 0.08
                    string info = f_tf_label(rangeTf) + " Range: " + str.tostring(storedHigh - storedLow, format.mintick) + "\nMove: " + str.tostring(f_percent(storedOpen, storedClose), "#.##") + "%\nVol: " + f_format_volume(array.get(rangeVolumes, slot))
                    label infoId = label.new(int(math.avg(startTime, rangeEnd)), bullishRange ? storedHigh + offset : storedLow - offset, info, xloc = xloc.bar_time, color = #00000000, textcolor = infoTextColor, style = bullishRange ? label.style_label_down : label.style_label_up, size = labelSize)
                    line projectedHighId = line.new(rangeEnd, storedHigh, periodEnd, storedHigh, xloc = xloc.bar_time, color = rangeDotColor, style = line.style_dashed, width = rangeDotWidth)
                    line projectedLowId = line.new(rangeEnd, storedLow, periodEnd, storedLow, xloc = xloc.bar_time, color = rangeDotColor, style = line.style_dashed, width = rangeDotWidth)
                    array.set(rangeTrendLines, slot, trendId)
                    array.set(rangeInfoLabels, slot, infoId)
                    array.set(rangeProjectedHighs, slot, projectedHighId)
                    array.set(rangeProjectedLows, slot, projectedLowId)

f_update_initial_range(0, showHtf1, newHtf1, htf1Input, range1Input, 1)
f_update_initial_range(1, showHtf2, newHtf2, htf2Input, range2Input, 2)
f_update_initial_range(2, showHtf3, newHtf3, htf3Input, range3Input, 3)

// --- Opening Lines ---
var array<line> openingLines1 = array.new_line()
var array<label> openingLabels1 = array.new_label()
var array<line> openingLines2 = array.new_line()
var array<label> openingLabels2 = array.new_label()
var array<line> openingLines3 = array.new_line()
var array<label> openingLabels3 = array.new_label()

f_update_opening(bool enabled, bool newPeriod, string htf, float openValue, int openTime, array<line> lines, array<label> labels) =>
    if enabled and newPeriod and not na(openValue) and not na(openTime)
        int closeTime = nz(time_close(htf), openTime + timeframe.in_seconds(htf) * 1000)
        line lineId = line.new(openTime, openValue, closeTime, openValue, xloc = xloc.bar_time, color = openingLineColor)
        label labelId = label.new(closeTime, openValue, f_format_time(openTime, htf) + " " + f_tf_label(htf) + " Opening Line", xloc = xloc.bar_time, color = #00000000, textcolor = openingLineColor, style = label.style_label_left, size = labelSize)
        array.push(lines, lineId)
        array.push(labels, labelId)
        while array.size(lines) > showLastNOpening
            line.delete(array.shift(lines))
            label.delete(array.shift(labels))

f_update_opening(showHtf1, newHtf1, htf1Input, currentOpen1, currentTime1, openingLines1, openingLabels1)
f_update_opening(showHtf2, newHtf2, htf2Input, currentOpen2, currentTime2, openingLines2, openingLabels2)
f_update_opening(showHtf3, newHtf3, htf3Input, currentOpen3, currentTime3, openingLines3, openingLabels3)

// --- Sweep Logic ---
var array<box> watchHighBoxes = array.new<box>(SLOT_COUNT, na)
var array<box> watchLowBoxes = array.new<box>(SLOT_COUNT, na)
var array<int> watchHighStarts = array.new_int(SLOT_COUNT, na)
var array<int> watchLowStarts = array.new_int(SLOT_COUNT, na)
var array<float> watchHighExtremes = array.new_float(SLOT_COUNT, na)
var array<float> watchLowExtremes = array.new_float(SLOT_COUNT, na)
var array<box> confirmedSweepBoxes = array.new_box()

f_clear_watch(int slot) =>
    box highBoxId = array.get(watchHighBoxes, slot)
    box lowBoxId = array.get(watchLowBoxes, slot)
    if not na(highBoxId)
        box.delete(highBoxId)
    if not na(lowBoxId)
        box.delete(lowBoxId)
    array.set(watchHighBoxes, slot, na)
    array.set(watchLowBoxes, slot, na)
    array.set(watchHighStarts, slot, na)
    array.set(watchLowStarts, slot, na)
    array.set(watchHighExtremes, slot, na)
    array.set(watchLowExtremes, slot, na)

f_store_sweep_box(box id) =>
    array.push(confirmedSweepBoxes, id)
    while array.size(confirmedSweepBoxes) > MAX_SWEEP_BOXES
        box.delete(array.shift(confirmedSweepBoxes))

f_update_sweep(int slot, bool enabled, bool newPeriod, float previousHigh, float previousLow) =>
    bool bearSignal = false
    bool bullSignal = false
    if not enabled or newPeriod
        f_clear_watch(slot)
    if enabled and not na(previousHigh) and not na(previousLow)
        if close > previousHigh
            int start = array.get(watchHighStarts, slot)
            if na(start)
                array.set(watchHighStarts, slot, time)
                array.set(watchHighExtremes, slot, high)
                if showSweepWatching
                    box id = box.new(left = time, top = high, right = time, bottom = previousHigh, xloc = xloc.bar_time, border_color = waitingColor, border_style = line.style_dotted, border_width = 2, bgcolor = #00000000)
                    array.set(watchHighBoxes, slot, id)
            else
                float extreme = math.max(array.get(watchHighExtremes, slot), high)
                array.set(watchHighExtremes, slot, extreme)
                box id = array.get(watchHighBoxes, slot)
                if not na(id)
                    box.set_right(id, time)
                    box.set_top(id, extreme)
        else
            int start = array.get(watchHighStarts, slot)
            float extreme = array.get(watchHighExtremes, slot)
            if not na(start)
                if extreme > previousHigh and close <= previousHigh
                    bearSignal := true
                    box confirmedId = box.new(left = start, top = extreme, right = time, bottom = previousHigh, xloc = xloc.bar_time, border_color = bearColor, bgcolor = color.new(bearColor, 80))
                    f_store_sweep_box(confirmedId)
                box id = array.get(watchHighBoxes, slot)
                if not na(id)
                    box.delete(id)
                array.set(watchHighBoxes, slot, na)
                array.set(watchHighStarts, slot, na)
                array.set(watchHighExtremes, slot, na)
        if close < previousLow
            int start = array.get(watchLowStarts, slot)
            if na(start)
                array.set(watchLowStarts, slot, time)
                array.set(watchLowExtremes, slot, low)
                if showSweepWatching
                    box id = box.new(left = time, top = previousLow, right = time, bottom = low, xloc = xloc.bar_time, border_color = waitingColor, border_style = line.style_dotted, border_width = 2, bgcolor = #00000000)
                    array.set(watchLowBoxes, slot, id)
            else
                float extreme = math.min(array.get(watchLowExtremes, slot), low)
                array.set(watchLowExtremes, slot, extreme)
                box id = array.get(watchLowBoxes, slot)
                if not na(id)
                    box.set_right(id, time)
                    box.set_bottom(id, extreme)
        else
            int start = array.get(watchLowStarts, slot)
            float extreme = array.get(watchLowExtremes, slot)
            if not na(start)
                if extreme < previousLow and close >= previousLow
                    bullSignal := true
                    box confirmedId = box.new(left = start, top = previousLow, right = time, bottom = extreme, xloc = xloc.bar_time, border_color = bullColor, bgcolor = color.new(bullColor, 80))
                    f_store_sweep_box(confirmedId)
                box id = array.get(watchLowBoxes, slot)
                if not na(id)
                    box.delete(id)
                array.set(watchLowBoxes, slot, na)
                array.set(watchLowStarts, slot, na)
                array.set(watchLowExtremes, slot, na)
    [bearSignal, bullSignal]

[bearSweep1, bullSweep1] = f_update_sweep(0, showHtf1, newHtf1, prevHigh1, prevLow1)
[bearSweep2, bullSweep2] = f_update_sweep(1, showHtf2, newHtf2, prevHigh2, prevLow2)
[bearSweep3, bullSweep3] = f_update_sweep(2, showHtf3, newHtf3, prevHigh3, prevLow3)
bool confirmedBearSweep = bearSweep1 or bearSweep2 or bearSweep3
bool confirmedBullSweep = bullSweep1 or bullSweep2 or bullSweep3
plotshape(confirmedBearSweep, title = "Bear Raid", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.small, text = "Raid", textcolor = bearColor)
plotshape(confirmedBullSweep, title = "Bull Raid", style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.small, text = "Raid", textcolor = bullColor)
alertcondition(confirmedBearSweep, "Bearish HTF Raid", "A bearish HTF liquidity raid was confirmed.")
alertcondition(confirmedBullSweep, "Bullish HTF Raid", "A bullish HTF liquidity raid was confirmed.")

// --- Previous HTF Levels ---
var array<line> previousHighLines = array.new<line>(SLOT_COUNT, na)
var array<line> previousLowLines = array.new<line>(SLOT_COUNT, na)
var array<label> previousHighLabels = array.new<label>(SLOT_COUNT, na)
var array<label> previousLowLabels = array.new<label>(SLOT_COUNT, na)
var array<label> premiumLabels = array.new<label>(SLOT_COUNT, na)
var array<label> discountLabels = array.new<label>(SLOT_COUNT, na)

f_render_previous_levels(int slot, bool enabled, string htf, float previousHigh, float previousLow, int previousTime, int width) =>
    line oldHighLine = array.get(previousHighLines, slot)
    line oldLowLine = array.get(previousLowLines, slot)
    label oldHighLabel = array.get(previousHighLabels, slot)
    label oldLowLabel = array.get(previousLowLabels, slot)
    label oldPremiumLabel = array.get(premiumLabels, slot)
    label oldDiscountLabel = array.get(discountLabels, slot)
    if not na(oldHighLine)
        line.delete(oldHighLine)
    if not na(oldLowLine)
        line.delete(oldLowLine)
    if not na(oldHighLabel)
        label.delete(oldHighLabel)
    if not na(oldLowLabel)
        label.delete(oldLowLabel)
    if not na(oldPremiumLabel)
        label.delete(oldPremiumLabel)
    if not na(oldDiscountLabel)
        label.delete(oldDiscountLabel)
    array.set(previousHighLines, slot, na)
    array.set(previousLowLines, slot, na)
    array.set(previousHighLabels, slot, na)
    array.set(previousLowLabels, slot, na)
    array.set(premiumLabels, slot, na)
    array.set(discountLabels, slot, na)
    if enabled and not na(previousHigh) and not na(previousLow) and not na(previousTime)
        string tfName = f_tf_label(htf)
        int offset = labelOffsetBars + slot * 4
        line highId = line.new(previousTime, previousHigh, time, previousHigh, xloc = xloc.bar_time, color = bearColor, width = width)
        line lowId = line.new(previousTime, previousLow, time, previousLow, xloc = xloc.bar_time, color = bullColor, width = width)
        label highLabelId = label.new(bar_index + offset, previousHigh, f_format_time(previousTime, htf) + " H (" + tfName + ")", color = #00000000, textcolor = bearColor, style = label.style_label_down, size = labelSize)
        label lowLabelId = label.new(bar_index + offset, previousLow, f_format_time(previousTime, htf) + " L (" + tfName + ")", color = #00000000, textcolor = bullColor, style = label.style_label_up, size = labelSize)
        label premiumId = label.new(int(math.avg(previousTime, time)), previousHigh, "Premium", xloc = xloc.bar_time, color = #00000000, textcolor = bearColor, style = label.style_label_down, size = labelSize)
        label discountId = label.new(int(math.avg(previousTime, time)), previousLow, "Discount", xloc = xloc.bar_time, color = #00000000, textcolor = bullColor, style = label.style_label_up, size = labelSize)
        array.set(previousHighLines, slot, highId)
        array.set(previousLowLines, slot, lowId)
        array.set(previousHighLabels, slot, highLabelId)
        array.set(previousLowLabels, slot, lowLabelId)
        array.set(premiumLabels, slot, premiumId)
        array.set(discountLabels, slot, discountId)

if barstate.islast
    f_render_previous_levels(0, showHtf1, htf1Input, prevHigh1, prevLow1, prevTime1, 1)
    f_render_previous_levels(1, showHtf2, htf2Input, prevHigh2, prevLow2, prevTime2, 2)
    f_render_previous_levels(2, showHtf3, htf3Input, prevHigh3, prevLow3, prevTime3, 3)

// --- Fair Value Gap Engine ---
type Gap
    float top
    float bottom
    int startTime
    bool bullish
    bool breaker = false
    int breakTime = na
    bool raided = false
    int raidStart = na
    int raidEnd = na
    float raidPrice = na

var array<Gap> gaps = array.new<Gap>()
var array<box> fvgDisplayBoxes = array.new_box()
var array<line> fvgDisplayLines = array.new_line()
var array<label> fvgDisplayLabels = array.new_label()

f_add_gap(Gap newGap) =>
    if fvgHideOverlap and array.size(gaps) > 0
        for i = array.size(gaps) - 1 to 0
            Gap oldGap = array.get(gaps, i)
            bool overlaps = oldGap.bullish == newGap.bullish and oldGap.bottom < newGap.top and oldGap.top > newGap.bottom
            if overlaps
                array.remove(gaps, i)
    array.unshift(gaps, newGap)
    while array.size(gaps) > MAX_FVG_STORED
        array.pop(gaps)

float fvgAtr = ta.atr(200)
if fvgEnable and not na(high[2]) and not na(fvgAtr)
    float bullSize = low - high[2]
    float bearSize = low[2] - high
    if bullSize > 0 and bullSize >= fvgAtr * fvgThreshold
        f_add_gap(Gap.new(top = low, bottom = high[2], startTime = time[2], bullish = true))
    if bearSize > 0 and bearSize >= fvgAtr * fvgThreshold
        f_add_gap(Gap.new(top = low[2], bottom = high, startTime = time[2], bullish = false))

if fvgEnable and array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        Gap gap = array.get(gaps, i)
        float midpoint = math.avg(gap.top, gap.bottom)
        bool mitigated = gap.bullish ? (fvgSource == "Close" ? math.min(open, close) < gap.bottom : fvgSource == "Wick" ? low < gap.bottom : low < midpoint) : (fvgSource == "Close" ? math.max(open, close) > gap.top : fvgSource == "Wick" ? high > gap.top : high > midpoint)
        if fvgShowRaids and not gap.breaker
            bool raidNow = gap.bullish ? low < gap.top and close > gap.top : high > gap.bottom and close < gap.bottom
            if raidNow and not gap.raided
                gap.raided := true
                gap.raidStart := time
                gap.raidEnd := time
                gap.raidPrice := gap.bullish ? low : high
            else if gap.raided
                gap.raidEnd := time
                gap.raidPrice := gap.bullish ? math.min(gap.raidPrice, low) : math.max(gap.raidPrice, high)
        if not gap.breaker and mitigated
            if fvgMode == "FVG"
                array.remove(gaps, i)
            else
                gap.breaker := true
                gap.breakTime := time
        else if gap.breaker
            bool invalidated = gap.bullish ? high > gap.top : low < gap.bottom
            if invalidated
                array.remove(gaps, i)

if barstate.islast
    for id in fvgDisplayBoxes
        box.delete(id)
    for id in fvgDisplayLines
        line.delete(id)
    for id in fvgDisplayLabels
        label.delete(id)
    array.clear(fvgDisplayBoxes)
    array.clear(fvgDisplayLines)
    array.clear(fvgDisplayLabels)
    if fvgEnable and fvgCount > 0 and array.size(gaps) > 0
        int numberToDraw = math.min(fvgCount, array.size(gaps))
        for i = 0 to numberToDraw - 1
            Gap gap = array.get(gaps, i)
            color baseColor = gap.bullish ? fvgBullColor : fvgBearColor
            color oppositeColor = gap.bullish ? fvgBearColor : fvgBullColor
            color midColor = gap.bullish ? fvgBullMid : fvgBearMid
            extension = fvgExtend ? extend.right : extend.none
            if not gap.breaker
                array.push(fvgDisplayBoxes, box.new(left = gap.startTime, top = gap.top, right = time, bottom = gap.bottom, xloc = xloc.bar_time, bgcolor = baseColor, border_color = na, extend = extension))
                if fvgShowMid
                    array.push(fvgDisplayLines, line.new(gap.startTime, math.avg(gap.top, gap.bottom), time, math.avg(gap.top, gap.bottom), xloc = xloc.bar_time, color = midColor, extend = extension))
            else
                array.push(fvgDisplayBoxes, box.new(left = gap.startTime, top = gap.top, right = gap.breakTime, bottom = gap.bottom, xloc = xloc.bar_time, bgcolor = baseColor, border_color = na))
                array.push(fvgDisplayBoxes, box.new(left = gap.breakTime, top = gap.top, right = time, bottom = gap.bottom, xloc = xloc.bar_time, bgcolor = oppositeColor, border_color = oppositeColor, extend = extension))
                if fvgShowMid
                    array.push(fvgDisplayLines, line.new(gap.startTime, math.avg(gap.top, gap.bottom), gap.breakTime, math.avg(gap.top, gap.bottom), xloc = xloc.bar_time, color = midColor))
                    array.push(fvgDisplayLines, line.new(gap.breakTime, math.avg(gap.top, gap.bottom), time, math.avg(gap.top, gap.bottom), xloc = xloc.bar_time, color = gap.bullish ? fvgBearMid : fvgBullMid, style = line.style_dashed, extend = extension))
            if fvgShowRaids and gap.raided
                array.push(fvgDisplayLines, line.new(gap.raidStart, gap.raidPrice, gap.raidEnd, gap.raidPrice, xloc = xloc.bar_time, color = chart.fg_color))
                array.push(fvgDisplayLabels, label.new(int(math.avg(gap.raidStart, gap.raidEnd)), gap.raidPrice, "×", xloc = xloc.bar_time, color = #00000000, textcolor = chart.fg_color, style = label.style_label_center, size = size.small))

// --- VWAP ---
float vwapValue = ta.vwap(hlc3)
plot(showVwap ? vwapValue : na, "VWAP", color = vwapColor, linewidth = 2)

// --- BOS / CHoCH Engine ---
bool inCalcWindow = calcLastBars == 0 or bar_index >= last_bar_index - calcLastBars
int bosLength = bosLengthInput % 2 == 0 ? bosLengthInput + 1 : bosLengthInput
int pivotLeg = int(bosLength / 2)
float pivotHighValue = ta.pivothigh(high, pivotLeg, pivotLeg)
float pivotLowValue = ta.pivotlow(low, pivotLeg, pivotLeg)
bool pivotHighHit = not na(pivotHighValue)
bool pivotLowHit = not na(pivotLowValue)
plotshape(showBos and showPivotMarks and pivotHighHit, "PH", shape.triangledown, location.abovebar, color = bearColor, offset = -pivotLeg, size = size.tiny, text = "PH", textcolor = bearColor)
plotshape(showBos and showPivotMarks and pivotLowHit, "PL", shape.triangleup, location.belowbar, color = bullColor, offset = -pivotLeg, size = size.tiny, text = "PL", textcolor = bullColor)

var float candidateUpLevel = na
var float candidateDownLevel = na
var int candidateUpTime = na
var int candidateDownTime = na
var bool candidateUpBroken = false
var bool candidateDownBroken = false
var line candidateUpLine = na
var line candidateDownLine = na
var label candidateUpLabel = na
var label candidateDownLabel = na
var int structureDirection = 0
var array<line> brokenLines = array.new_line()
var array<label> brokenLabels = array.new_label()

f_trim_broken() =>
    int limit = showLastBroken == 0 ? 200 : showLastBroken
    while array.size(brokenLines) > limit
        line oldLine = array.shift(brokenLines)
        label oldLabel = array.shift(brokenLabels)
        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

int extensionMilliseconds = timeframe.in_seconds() * 1000 * barsToRight
candidateStyle = f_line_style(candidateStyleInput)
brokenStyle = f_line_style(brokenStyleInput)

if showBos and inCalcWindow
    if pivotHighHit
        if not na(candidateUpLine) and not candidateUpBroken
            line.delete(candidateUpLine)
        if not na(candidateUpLabel)
            label.delete(candidateUpLabel)
        candidateUpLevel := pivotHighValue
        candidateUpTime := time[pivotLeg]
        candidateUpBroken := false
        candidateUpLine := line.new(candidateUpTime, candidateUpLevel, time + extensionMilliseconds, candidateUpLevel, xloc = xloc.bar_time, color = candidateUpColor, style = candidateStyle, width = candidateWidth)
        candidateUpLabel := showCandidateText ? label.new(candidateUpTime, candidateUpLevel, "BOS ↑", xloc = xloc.bar_time, color = #00000000, textcolor = candidateUpColor, style = label.style_label_down, size = bosLabelSize) : na
    if pivotLowHit
        if not na(candidateDownLine) and not candidateDownBroken
            line.delete(candidateDownLine)
        if not na(candidateDownLabel)
            label.delete(candidateDownLabel)
        candidateDownLevel := pivotLowValue
        candidateDownTime := time[pivotLeg]
        candidateDownBroken := false
        candidateDownLine := line.new(candidateDownTime, candidateDownLevel, time + extensionMilliseconds, candidateDownLevel, xloc = xloc.bar_time, color = candidateDownColor, style = candidateStyle, width = candidateWidth)
        candidateDownLabel := showCandidateText ? label.new(candidateDownTime, candidateDownLevel, "BOS ↓", xloc = xloc.bar_time, color = #00000000, textcolor = candidateDownColor, style = label.style_label_up, size = bosLabelSize) : na
    if not na(candidateUpLine) and not candidateUpBroken
        line.set_x2(candidateUpLine, time + extensionMilliseconds)
    if not na(candidateDownLine) and not candidateDownBroken
        line.set_x2(candidateDownLine, time + extensionMilliseconds)

bool breakUp = showBos and inCalcWindow and not na(candidateUpLevel) and not candidateUpBroken and (requireBody ? close > candidateUpLevel : high > candidateUpLevel)
bool breakDown = showBos and inCalcWindow and not na(candidateDownLevel) and not candidateDownBroken and (requireBody ? close < candidateDownLevel : low < candidateDownLevel)

if breakUp
    candidateUpBroken := true
    line.set_color(candidateUpLine, brokenUpColor)
    line.set_style(candidateUpLine, brokenStyle)
    line.set_width(candidateUpLine, brokenWidth)
    line.set_x2(candidateUpLine, time)
    if not na(candidateUpLabel)
        label.delete(candidateUpLabel)
        candidateUpLabel := na
    string structureLabelText = structureDirection == -1 ? "CHoCH" : "BOS"
    label breakLabel = showBosLabels ? label.new(int(math.avg(candidateUpTime, time)), candidateUpLevel, structureLabelText, xloc = xloc.bar_time, color = #00000000, textcolor = brokenUpColor, style = label.style_label_down, size = bosLabelSize) : na
    array.push(brokenLines, candidateUpLine)
    array.push(brokenLabels, breakLabel)
    candidateUpLine := na
    structureDirection := 1
    f_trim_broken()

if breakDown
    candidateDownBroken := true
    line.set_color(candidateDownLine, brokenDownColor)
    line.set_style(candidateDownLine, brokenStyle)
    line.set_width(candidateDownLine, brokenWidth)
    line.set_x2(candidateDownLine, time)
    if not na(candidateDownLabel)
        label.delete(candidateDownLabel)
        candidateDownLabel := na
    string structureLabelText = structureDirection == 1 ? "CHoCH" : "BOS"
    label breakLabel = showBosLabels ? label.new(int(math.avg(candidateDownTime, time)), candidateDownLevel, structureLabelText, xloc = xloc.bar_time, color = #00000000, textcolor = brokenDownColor, style = label.style_label_up, size = bosLabelSize) : na
    array.push(brokenLines, candidateDownLine)
    array.push(brokenLabels, breakLabel)
    candidateDownLine := na
    structureDirection := -1
    f_trim_broken()

alertcondition(breakUp, "Bullish BOS / CHoCH", "A bullish market-structure break was confirmed.")
alertcondition(breakDown, "Bearish BOS / CHoCH", "A bearish market-structure break was confirmed.")

// --- Session Pivots ---
bool inAsian = not na(time(timeframe.period, "0000-0700", TZ_STRING))
bool inLondon = not na(time(timeframe.period, "1100-1400", TZ_STRING))
bool inNewYork = not na(time(timeframe.period, "1500-2200", TZ_STRING))
bool newDay = ta.change(time("1D", "0000-0000", TZ_STRING)) != 0
var array<float> sessionHighs = array.new_float(3, na)
var array<float> sessionLows = array.new_float(3, na)
var array<int> sessionHighTimes = array.new_int(3, na)
var array<int> sessionLowTimes = array.new_int(3, na)
var array<line> sessionHighLines = array.new<line>(3, na)
var array<line> sessionLowLines = array.new<line>(3, na)
var array<label> sessionHighLabels = array.new<label>(3, na)
var array<label> sessionLowLabels = array.new<label>(3, na)
var array<bool> sessionHighBroken = array.new_bool(3, false)
var array<bool> sessionLowBroken = array.new_bool(3, false)

f_reset_sessions() =>
    for slot = 0 to 2
        line highLineId = array.get(sessionHighLines, slot)
        line lowLineId = array.get(sessionLowLines, slot)
        label highLabelId = array.get(sessionHighLabels, slot)
        label lowLabelId = array.get(sessionLowLabels, slot)
        if not na(highLineId)
            line.delete(highLineId)
        if not na(lowLineId)
            line.delete(lowLineId)
        if not na(highLabelId)
            label.delete(highLabelId)
        if not na(lowLabelId)
            label.delete(lowLabelId)
        array.set(sessionHighs, slot, na)
        array.set(sessionLows, slot, na)
        array.set(sessionHighTimes, slot, na)
        array.set(sessionLowTimes, slot, na)
        array.set(sessionHighLines, slot, na)
        array.set(sessionLowLines, slot, na)
        array.set(sessionHighLabels, slot, na)
        array.set(sessionLowLabels, slot, na)
        array.set(sessionHighBroken, slot, false)
        array.set(sessionLowBroken, slot, false)

f_update_session(int slot, bool inSession, string name) =>
    if inSession
        float storedHigh = array.get(sessionHighs, slot)
        float storedLow = array.get(sessionLows, slot)
        if na(storedHigh) or high > storedHigh
            array.set(sessionHighs, slot, high)
            array.set(sessionHighTimes, slot, time)
        if na(storedLow) or low < storedLow
            array.set(sessionLows, slot, low)
            array.set(sessionLowTimes, slot, time)
    else if showSessionPivots
        float storedHigh = array.get(sessionHighs, slot)
        float storedLow = array.get(sessionLows, slot)
        int highTime = array.get(sessionHighTimes, slot)
        int lowTime = array.get(sessionLowTimes, slot)
        if not na(storedHigh)
            line highLineId = array.get(sessionHighLines, slot)
            label highLabelId = array.get(sessionHighLabels, slot)
            if na(highLineId)
                highLineId := line.new(highTime, storedHigh, time, storedHigh, xloc = xloc.bar_time, color = sessionPivotColor)
                highLabelId := label.new(time, storedHigh, name + " H", xloc = xloc.bar_time, color = #00000000, textcolor = sessionPivotColor, style = label.style_label_down, size = size.small)
                array.set(sessionHighLines, slot, highLineId)
                array.set(sessionHighLabels, slot, highLabelId)
            if not array.get(sessionHighBroken, slot)
                line.set_x2(highLineId, time)
                label.set_x(highLabelId, time)
                if high > storedHigh
                    array.set(sessionHighBroken, slot, true)
                    line.set_style(highLineId, line.style_dotted)
                    label.set_text(highLabelId, "×")
                    label.set_x(highLabelId, int(math.avg(highTime, time)))
        if not na(storedLow)
            line lowLineId = array.get(sessionLowLines, slot)
            label lowLabelId = array.get(sessionLowLabels, slot)
            if na(lowLineId)
                lowLineId := line.new(lowTime, storedLow, time, storedLow, xloc = xloc.bar_time, color = sessionPivotColor)
                lowLabelId := label.new(time, storedLow, name + " L", xloc = xloc.bar_time, color = #00000000, textcolor = sessionPivotColor, style = label.style_label_up, size = size.small)
                array.set(sessionLowLines, slot, lowLineId)
                array.set(sessionLowLabels, slot, lowLabelId)
            if not array.get(sessionLowBroken, slot)
                line.set_x2(lowLineId, time)
                label.set_x(lowLabelId, time)
                if low < storedLow
                    array.set(sessionLowBroken, slot, true)
                    line.set_style(lowLineId, line.style_dotted)
                    label.set_text(lowLabelId, "×")
                    label.set_x(lowLabelId, int(math.avg(lowTime, time)))

if newDay
    f_reset_sessions()
f_update_session(0, inAsian, "Asian")
f_update_session(1, inLondon, "London")
f_update_session(2, inNewYork, "NY")

// --- Dashboard ---
[dmiPlus, dmiMinus, _] = ta.dmi(14, 14)
float momentum = ta.rsi(close, 14)
float dailyOpen = request.security(syminfo.tickerid, "1D", open, lookahead = barmerge.lookahead_on)
float weeklyOpen = request.security(syminfo.tickerid, "1W", open, lookahead = barmerge.lookahead_on)
var table dashboard = table.new(position.top_right, 3, 7, border_width = 1, border_color = color.new(chart.fg_color, 80), frame_color = color.new(chart.fg_color, 80), frame_width = 1)
var table watermark = table.new(position.bottom_right, 1, 1)

if barstate.isfirst
    table.merge_cells(dashboard, 1, 0, 2, 0)
    table.merge_cells(dashboard, 1, 1, 2, 1)
    table.merge_cells(dashboard, 1, 2, 2, 2)
    table.merge_cells(dashboard, 1, 3, 2, 3)
    table.merge_cells(dashboard, 1, 4, 2, 4)
    table.merge_cells(dashboard, 1, 6, 2, 6)

if barstate.islast
    color background = color.new(chart.bg_color, 10)
    color textColor = chart.fg_color
    bool dailyBull = close >= dailyOpen
    bool weeklyBull = close >= weeklyOpen
    bool vwapBull = close >= vwapValue
    string structureText = structureDirection == 1 ? "Bullish" : structureDirection == -1 ? "Bearish" : "Neutral"
    color structureColor = structureDirection == 1 ? bullColor : structureDirection == -1 ? bearColor : textColor
    bool h0007 = not na(time(timeframe.period, "0000-0700", TZ_STRING))
    bool h0711 = not na(time(timeframe.period, "0700-1100", TZ_STRING))
    bool h1114 = not na(time(timeframe.period, "1100-1400", TZ_STRING))
    bool h1415 = not na(time(timeframe.period, "1400-1500", TZ_STRING))
    bool h1522 = not na(time(timeframe.period, "1500-2200", TZ_STRING))
    string sessionText = h0007 ? "● Asian Open" : h0711 ? "● Waiting for London" : h1114 ? "● London Open" : h1415 ? "● Waiting for New York" : h1522 ? "● New York Open" : "● Waiting for Asian"
    color sessionColor = h0007 or h1114 or h1522 ? bullColor : bearColor
    table.cell(dashboard, 0, 0, "Daily Bias", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 0, dailyBull ? "Bullish" : "Bearish", text_color = dailyBull ? bullColor : bearColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 1, "Weekly Bias", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 1, weeklyBull ? "Bullish" : "Bearish", text_color = weeklyBull ? bullColor : bearColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 2, "VWAP Bias", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 2, vwapBull ? "Bullish" : "Bearish", text_color = vwapBull ? bullColor : bearColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 3, "Structure", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 3, structureText, text_color = structureColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 4, "Momentum (RSI)", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 4, str.tostring(momentum, "#.##"), text_color = momentum >= 50 ? bullColor : bearColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 5, "DI+ / DI-", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 5, str.tostring(dmiPlus, "#.##"), text_color = dmiPlus > dmiMinus ? bullColor : textColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 2, 5, str.tostring(dmiMinus, "#.##"), text_color = dmiMinus > dmiPlus ? bearColor : textColor, text_halign = text.align_right, bgcolor = background)
    table.cell(dashboard, 0, 6, "Session Info", text_color = textColor, text_halign = text.align_left, bgcolor = background)
    table.cell(dashboard, 1, 6, sessionText, text_color = sessionColor, text_halign = text.align_right, bgcolor = background)
    table.cell(watermark, 0, 0, "erdensedat", text_color = color.new(chart.fg_color, 85), text_size = size.large)
````
