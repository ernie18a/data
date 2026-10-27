# Predictive Trend and Level Signal Tracker

- url: https://www.tradingview.com/script/M9pl43uQ-Predictive-Trend-and-Level-Signal-Tracker/
- type: indicator
- pine_id: PUB;b60a730ec1ca4eb7ba67b5bd53b2563e
- version: 3.0

## Description

Title:
Predictive Trend and Level Signal Tracker

Description:
This indicator is a multi-dimensional analysis tool designed to identify high-probability trend entries and level interactions. It combines predictive trend tracking with volatility-based squeeze detection and institutional level interaction.

How it Works:

Predictive Trend Tracking (ZLEMA):
The script uses a Zero-Lag Exponential Moving Average (ZLEMA). Traditional MAs often lag behind price, but the ZLEMA reduces this lag significantly by projecting the current price movement before averaging it. This allows for faster identification of trend shifts.
Volatility Squeeze (BB vs KC):
Consolidation is detected by comparing Bollinger Bands and Keltner Channels. When Bollinger Bands contract inside the Keltner Channels, the market is in a "Squeeze" (consolidation). The script identifies "Squeeze Releases"—instances where volatility expands—which often lead to explosive price moves.
High-Volume Level Interaction:
The script monitors price action around Daily, Weekly, and Monthly Highs and Lows.
Sqz Break (Dark Blue): Occurs when price breaks a key level with high volume while releasing from a squeeze.
Reject (Light Blue): Occurs when price tests a key level but is rejected with high volume and a significant wick, indicating a potential reversal.
Key Features:

Volume Filter: Ensures that signals are only generated when there is significant market participation (configurable multiplier).
Trend Alignment: A built-in filter to ensure signals only appear if they match the direction of the predictive trend tracker.
Clean Interface: Signals are displayed as clear labels, while the main visual is a trend-colored predictive line.
How to Use:

Trend Line: Green indicates a bullish bias; Red indicates a bearish bias.
Dark Blue Labels: Look for these as high-probability breakout opportunities from institutional levels.
Light Blue Labels: Use these to identify potential "fakeouts" or reversals at major historical levels.
Disclaimer: This script is for technical analysis and educational purposes only. Past performance does not guarantee future results.

Tags:
Trend, Breakout, Rejection, Squeeze, Multi-Timeframe, Volume, Predictive

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Predictive Trend and Level Signal Tracker", "Trend & Level Tracker", overlay = true, max_labels_count = 500)

// --- Description of the Logic ---
// This script identifies high-probability trade setups using:
// 1. Predictive Trend Tracking (ZLEMA) for faster trend identification.
// 2. Volatility Squeeze detection to find consolidation zones.
// 3. High-Volume Level interactions at Daily, Weekly, and Monthly Highs/Lows.
// 4. Alignment Dashboard: Displays trend status across Daily, Weekly, and Monthly timeframes.

// --- Groups ---
string G_MA      = "Trend Tracker (Predictive MA)"
string G_LEVELS  = "Key Levels Detection"
string G_VOLUME  = "Volume Filter"
string G_SQUEEZE = "Consolidation (Squeeze) Filter"
string G_DASH    = "Dashboard Settings"
string G_STYLING = "Signal Visibility"

// --- Inputs ---
int maLength       = input.int(20, "Trend MA Length", minval = 1, group = G_MA)
color maColorUp    = input.color(#089981, "MA Trend Up", group = G_MA)
color maColorDn    = input.color(#f23645, "MA Trend Down", group = G_MA)
bool useTrendFilter = input.bool(true, "Align Signals with Trend", group = G_MA)

bool showDaily     = input.bool(true, "Detect Daily Levels", group = G_LEVELS)
bool showWeekly    = input.bool(true, "Detect Weekly Levels", group = G_LEVELS)
bool showMonthly   = input.bool(true, "Detect Monthly Levels", group = G_LEVELS)

float breakSens    = input.float(0.1, "Break Sensitivity (ATR %)", minval = 0, step = 0.05, group = G_VOLUME)
float rejectRatio  = input.float(1.5, "Rejection Wick Ratio", minval = 1.0, step = 0.1, group = G_VOLUME)
float volMult      = input.float(1.2, "Volume Surge Multiplier", minval = 0.5, step = 0.1, group = G_VOLUME)

bool useSqueeze     = input.bool(true, "Require Squeeze Release", group = G_SQUEEZE)
int squeezeLength   = input.int(20, "Squeeze Period", minval = 5, group = G_SQUEEZE)

// Dashboard Inputs
bool showDash      = input.bool(true, "Show Alignment Dashboard", group = G_DASH)
string dashPos     = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_DASH)

// Signal Visibility
bool showBreaks      = input.bool(true, "Show Breakout Signals", group = G_STYLING)
bool showRejections  = input.bool(true, "Show Rejection Signals", group = G_STYLING)
color colorBreakBull = input.color(#00008B, "Bull Break Color", group = G_STYLING)
color colorBreakBear = input.color(#8B0000, "Bear Break Color", group = G_STYLING)
color colorRejection = input.color(#00BFFF, "Rejection Color", group = G_STYLING)

// --- Logic: Predictive Trend (ZLEMA) ---
zlema(src, length) =>
    lag = math.floor((length - 1) / 2)
    data = src + (src - src[lag])
    ta.ema(data, length)

trendMA = zlema(close, maLength)
maTrendUp = trendMA > trendMA[1]

// --- Logic: Volatility Squeeze ---
basis = ta.sma(close, squeezeLength)
dev = 2.0 * ta.stdev(close, squeezeLength)
upperBB = basis + dev
lowerBB = basis - dev
maKC = ta.sma(close, squeezeLength)
rangeKC = ta.sma(ta.tr, squeezeLength)
upperKC = maKC + rangeKC * 1.5
lowerKC = maKC - rangeKC * 1.5

sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
isSqueezeRelease = sqzOff and sqzOn[1]

// --- Logic: Volume Filter ---
avgVol = ta.sma(volume, 20)
isHighVol = volume > (avgVol * volMult)

// --- HTF Data Fetching (No Lookahead) ---
get_levels(tf) =>
    [h, l] = request.security(syminfo.tickerid, tf, [high[1], low[1]], lookahead = barmerge.lookahead_off)
    [h, l]

[dHigh, dLow] = get_levels("D")
[wHigh, wLow] = get_levels("W")
[mHigh, mLow] = get_levels("M")

// HTF Trend Detection for Dashboard
get_htf_trend(tf, length) =>
    [curr, prev] = request.security(syminfo.tickerid, tf, [zlema(close, length), zlema(close, length)[1]], lookahead = barmerge.lookahead_off)
    curr > prev

dTrendUp = get_htf_trend("D", maLength)
wTrendUp = get_htf_trend("W", maLength)
mTrendUp = get_htf_trend("M", maLength)

// --- Logic: Signal Functions ---
atr = ta.atr(14)

check_break(lvl, upTrend, volFilter, sense, atrVal, filterTrend, squeezeRelease) =>
    res = 0 
    sqzOk = not useSqueeze or (squeezeRelease or volFilter) 
    if not na(lvl) and volFilter and sqzOk
        isBull = ta.crossover(close, lvl) and (close - lvl) > (atrVal * sense)
        isBear = ta.crossunder(close, lvl) and (lvl - close) > (atrVal * sense)
        if isBull and (not filterTrend or upTrend)
            res := 1
        else if isBear and (not filterTrend or not upTrend)
            res := 2
    res

check_reject(lvl, isUpper, upTrend, volFilter, ratio, filterTrend) =>
    res = 0 
    if not na(lvl) and volFilter
        bodySize = math.abs(close - open)
        if isUpper and high >= lvl and close < lvl 
            wickSize = high - math.max(open, close)
            if wickSize > (bodySize * ratio) and (not filterTrend or not upTrend)
                res := 2 // Bearish Rejection from High
        else if not isUpper and low <= lvl and close > lvl
            wickSize = math.min(open, close) - low
            if wickSize > (bodySize * ratio) and (not filterTrend or upTrend)
                res := 1 // Bullish Rejection from Low
    res

// Signal Components
bDH = check_break(dHigh, maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)
bDL = check_break(dLow,  maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)
bWH = check_break(wHigh, maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)
bWL = check_break(wLow,  maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)
bMH = check_break(mHigh, maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)
bML = check_break(mLow,  maTrendUp, isHighVol, breakSens, atr, useTrendFilter, isSqueezeRelease)

rDH = check_reject(dHigh, true,  maTrendUp, isHighVol, rejectRatio, useTrendFilter)
rDL = check_reject(dLow,  false, maTrendUp, isHighVol, rejectRatio, useTrendFilter)
rWH = check_reject(wHigh, true,  maTrendUp, isHighVol, rejectRatio, useTrendFilter)
rWL = check_reject(wLow,  false, maTrendUp, isHighVol, rejectRatio, useTrendFilter)
rMH = check_reject(mHigh, true,  maTrendUp, isHighVol, rejectRatio, useTrendFilter)
rML = check_reject(mLow,  false, maTrendUp, isHighVol, rejectRatio, useTrendFilter)

isBullBreak = (showDaily and (bDL == 1 or bDH == 1)) or (showWeekly and (bWL == 1 or bWH == 1)) or (showMonthly and (bML == 1 or bMH == 1))
isBearBreak = (showDaily and (bDH == 2 or bDL == 2)) or (showWeekly and (bWH == 2 or bWL == 2)) or (showMonthly and (bMH == 2 or bML == 2))
isBullReject = (showDaily and rDL == 1) or (showWeekly and rWL == 1) or (showMonthly and rML == 1)
isBearReject = (showDaily and rDH == 2) or (showWeekly and rWH == 2) or (showMonthly and rMH == 2)

// --- Dashboard Implementation ---
var table trendTable = na
if showDash and barstate.islast
    pos = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Top Left" ? position.top_left : position.bottom_left
    trendTable := table.new(pos, 4, 3, border_width = 1, frame_color = chart.fg_color, frame_width = 1)
    table.cell(trendTable, 0, 0, "Timeframe", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 0, "Daily", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 2, 0, "Weekly", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 3, 0, "Monthly", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 0, 1, "Trend", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 1, dTrendUp ? "UP" : "DOWN", bgcolor = dTrendUp ? color.new(maColorUp, 20) : color.new(maColorDn, 20), text_color = color.white, text_size = size.small)
    table.cell(trendTable, 2, 1, wTrendUp ? "UP" : "DOWN", bgcolor = wTrendUp ? color.new(maColorUp, 20) : color.new(maColorDn, 20), text_color = color.white, text_size = size.small)
    table.cell(trendTable, 3, 1, mTrendUp ? "UP" : "DOWN", bgcolor = mTrendUp ? color.new(maColorUp, 20) : color.new(maColorDn, 20), text_color = color.white, text_size = size.small)
    // Squeeze Info
    table.cell(trendTable, 0, 2, "Consol.", bgcolor = chart.bg_color, text_color = chart.fg_color, text_size = size.small)
    table.cell(trendTable, 1, 2, sqzOn ? "SQUEEZE" : "NORMAL", bgcolor = sqzOn ? color.new(color.orange, 20) : color.new(color.gray, 20), text_color = color.white, text_size = size.small)
    table.cell(trendTable, 2, 2, sqzOn ? "SQUEEZE" : "NORMAL", bgcolor = sqzOn ? color.new(color.orange, 20) : color.new(color.gray, 20), text_color = color.white, text_size = size.small)
    table.cell(trendTable, 3, 2, sqzOn ? "SQUEEZE" : "NORMAL", bgcolor = sqzOn ? color.new(color.orange, 20) : color.new(color.gray, 20), text_color = color.white, text_size = size.small)

// --- Visuals ---
plot(trendMA, "Trend Tracker", maTrendUp ? maColorUp : maColorDn, 3)

// Breakout Labels
if showBreaks and isBullBreak
    label.new(bar_index, low, "Bull Break Sqz", color = color.new(colorBreakBull, 0), textcolor = color.white, style = label.style_label_up, size = size.small)
if showBreaks and isBearBreak
    label.new(bar_index, high, "Bear Break Sqz", color = color.new(colorBreakBear, 0), textcolor = color.white, style = label.style_label_down, size = size.small)

// Corrected Rejection Label Placement:
// Bullish Rejection: Price tried to move lower but failed. Placed at BOTTOM (low).
if showRejections and isBullReject
    label.new(bar_index, low, "Reject", color = color.new(colorRejection, 20), textcolor = color.white, style = label.style_label_up, size = size.small)
// Bearish Rejection: Price tried to move higher but failed. Placed at TOP (high).
if showRejections and isBearReject
    label.new(bar_index, high, "Reject", color = color.new(colorRejection, 20), textcolor = color.white, style = label.style_label_down, size = size.small)
````
