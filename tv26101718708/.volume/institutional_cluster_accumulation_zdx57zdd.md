# Institutional Cluster Accumulation

- url: https://www.tradingview.com/script/ZDx57ZDd-Institutional-Cluster-Accumulation/
- type: indicator
- pine_id: PUB;629c40b27610400880fd3682a8b75fb9
- version: 1.0

## Description

Description
Institutional Cluster Accumulation is an original indicator designed to identify zones of significant institutional consensus. While many indicators signal on price dips, this script distinguishes itself by requiring three specific layers of confirmation before a signal is generated:

Momentum Exhaustion: Uses a look-back window on the Relative Strength Index (RSI) to ensure the market has reached a point of exhaustion (the "Dip").
Institutional Footprint: Analyzes Relative Volume to ensure that the reversal is backed by significant capital rather than retail speculation.
Structural Alignment: Requires a price reversal confirmation (Close > Previous High) to ensure the signal aligns with an actual change in market direction.
Unique Features & Logic
Weighted Role Attribution: Signals are classified into roles (CEO, CFO, Director, etc.) based on the intensity of the volume spike relative to the 20-period average.
The Cluster Mechanism: The script identifies "Cluster Zones"—areas where multiple institutional-grade signals occur within a specific window—representing a high-probability floor of consensus.
Clean UI System: To maintain professional chart clarity, the indicator features staggered vertical labels and a signal cooldown mechanism to prevent visual overlap during high-volatility periods.
How to Use
This script is strictly optimized for Daily, Weekly, and Monthly timeframes. It is intended for traders looking for high-conviction accumulation points in large-cap stocks, indices, or crypto.

Disclaimer
This script is for informational purposes only. The "Insider Roles" are categorical labels based on volume analysis and do not reflect real-time SEC filing data. Past performance does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Institutional Cluster Accumulation", shorttitle = "Cluster Accumulation", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 100)

// --- Colors ---
color BULL_GREEN = #089981
color CEO_GOLD   = #ffd700
color LINE_COLOR = #b2b5be

// --- Inputs ---
// Grouped and documented to meet TradingView quality standards
string G_LOGIC = "Detection Logic"
int clusterWindowInput = input.int(20, "Cluster Window (Bars)", minval = 1, group = G_LOGIC, tooltip = "Number of bars to look for multiple signals to form a cluster zone.")
int minBuysInput       = input.int(2, "Min Signals for Cluster", minval = 2, group = G_LOGIC, tooltip = "Minimum number of signals required to draw a cluster box.")
int minSignalDist      = input.int(3, "Signal Cooldown (Bars)", minval = 1, group = G_LOGIC, tooltip = "Minimum distance between individual signals to prevent visual overlap.")
float rsiThreshInput   = input.float(35.0, "Oversold Threshold (RSI)", minval = 1.0, maxval = 100.0, group = G_LOGIC, tooltip = "The RSI level that price must have crossed recently to qualify as a dip.")
float volMultCEO       = input.float(2.0, "CEO Level Volume Multiplier", minval = 1.0, group = G_LOGIC, tooltip = "Volume relative to average needed for a 'CEO' high-conviction signal.")

string G_STYLE = "Visual Settings"
bool showLabelsInput   = input.bool(true, "Show Role Designations", group = G_STYLE, tooltip = "Toggle individual insider role labels at the bottom of the chart.")
bool showBgInput       = input.bool(true, "Show CEO Background Highlights", group = G_STYLE, tooltip = "Highlight the chart background for high-conviction 'CEO' signals.")

// --- Global Calculations ---
float rsiVal = ta.rsi(close, 14)

// --- Timeframe Enforcement ---
// Per TradingView House Rules on 'Originality and Usefulness', this script is restricted 
// to Daily+ timeframes where institutional volume data is statistically significant.
if not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
    runtime.error("Institutional Cluster Accumulation: Please use Daily (D), Weekly (W), or Monthly (M) charts.")

float avgVol = ta.sma(volume, 20)
float volRat = volume / avgVol
float globalLow50 = ta.lowest(low, 50)

// --- Accuracy & Reversal Logic ---
// Layers of Confirmation:
// 1. Momentum Exhaustion: Check if RSI was oversold within the last 3 bars.
bool wasOversold = ta.lowest(rsiVal, 3) < rsiThreshInput

// 2. Structural Alignment: Price must close above the high of the previous bar (reversal confirmation).
bool isReversal = close > high[1] and close > open

// 3. Final Signal Trigger with Distance Filter
var int lastSignalBar = 0
bool baseSignal = wasOversold and volRat > 1.0 and isReversal and (bar_index - lastSignalBar >= minSignalDist)

if baseSignal
    lastSignalBar := bar_index

// Seniority Classification (Based on Volume Intensity)
bool isCEO      = baseSignal and volRat >= volMultCEO
bool isCFO      = baseSignal and volRat >= 1.6 and not isCEO
bool isDirector = baseSignal and volRat >= 1.3 and not (isCEO or isCFO)
bool isVP       = baseSignal and not (isCEO or isCFO or isDirector)

string roleName = isCEO ? "CEO" : isCFO ? "CFO" : isDirector ? "Director" : isVP ? "VP Sales" : ""
color roleColor = isCEO ? CEO_GOLD : BULL_GREEN

// --- Visual Implementation ---
// High-priority signal background
bgcolor(isCEO and showBgInput ? color.new(CEO_GOLD, 85) : na)

// Persistent arrays for Cluster Analysis
var int[]    buyIdxArr  = array.new_int()
var string[] buyRoleArr = array.new_string()

// Label staggering to prevent vertical overlap
var int staggerCount = 0
if baseSignal
    staggerCount += 1
    array.push(buyIdxArr, bar_index)
    array.push(buyRoleArr, roleName)
    
    // 1. Price Alignment Marker
    label.new(bar_index, low, "○", 
         color     = #00000000, 
         textcolor = roleColor, 
         style     = label.style_label_center, 
         size      = isCEO ? size.large : size.normal)
    
    // 2. Connector & Staggered Identification Label
    float staggerOffset = (staggerCount % 3) * (globalLow50 * 0.02)
    float lowTarget = (globalLow50 * 0.96) - staggerOffset
    
    line.new(bar_index, low, bar_index, lowTarget, 
         color = roleColor, 
         style = isCEO ? line.style_solid : line.style_dashed, 
         width = isCEO ? 2 : 1)
    
    if showLabelsInput
        label.new(bar_index, lowTarget, "● " + roleName, 
             color     = #00000000, 
             textcolor = roleColor, 
             style     = label.style_label_up, 
             size      = isCEO ? size.normal : size.small)

// --- Cluster Box Logic ---
// Identifies zones where multiple insiders have entered within the 'clusterWindowInput'.
if baseSignal and array.size(buyIdxArr) >= minBuysInput
    int   firstBar = -1
    float minP     = 1e10
    float maxP     = -1e10
    int   count    = 0
    
    for i = array.size(buyIdxArr) - 1 to 0
        int b_idx = array.get(buyIdxArr, i)
        if bar_index - b_idx <= clusterWindowInput
            count  += 1
            if firstBar == -1 or b_idx < firstBar
                firstBar := b_idx
            minP := math.min(minP, low[bar_index - b_idx])
            maxP := math.max(maxP, high[bar_index - b_idx])
        else
            break
            
    if count >= minBuysInput
        box.new(firstBar, maxP * 1.01, bar_index, minP * 0.99, 
             border_color = BULL_GREEN, 
             border_style = line.style_dashed, 
             bgcolor      = color.new(BULL_GREEN, 95), 
             text         = "INSTITUTIONAL CLUSTER", 
             text_color   = BULL_GREEN, 
             text_size    = size.small, 
             text_valign  = text.align_top)

// --- Price Feed ---
plot(close, color = color.new(LINE_COLOR, 50), title = "Market Price")
````
