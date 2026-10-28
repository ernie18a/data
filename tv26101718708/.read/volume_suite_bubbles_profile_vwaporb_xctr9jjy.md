# Volume Suite: Bubbles + Profile + VWAP/ORB

- url: https://www.tradingview.com/script/XcTr9JjY-Volume-Suite-Bubbles-Profile-VWAP-ORB/
- type: indicator
- pine_id: PUB;b927159b55a2423f97346c93e6903128
- version: 1.0

## Description

Here's a full-length description written for futures/NQ traders.

Volume Suite: Bubbles + Profile + VWAP/ORB
An all-in-one volume and market-structure toolkit built for intraday futures traders.
Volume Suite combines three professional-grade volume analysis tools into a single indicator, each with its own master on/off toggle so you can run all three together or isolate exactly the one you need. It was built with index futures like NQ (E-mini Nasdaq-100) and ES in mind, where session timing, volume distribution, and the opening range carry real predictive weight. Instead of cluttering your chart with three separate scripts that each eat into TradingView's indicator limit, this consolidates everything into one efficient package.

Module ① — Volume Bubbles
Volume Bubbles surfaces the bars where real money is moving. Rather than relying on a single fixed volume threshold, it ranks each bar against recent history using percentile analysis across three independent lookback windows (short, medium, and long—20, 50, and 100 bars by default). A bar only gets flagged when it clears your chosen percentile, and you control how strict that confirmation is: require just one window to agree, a majority of two, or all three for the highest-conviction signals.
Detected bars are drawn as circular bubbles whose size reflects the magnitude of the event—Small (top 25%), Medium (top 10%), and Big (top 3%)—so a glance tells you whether you're looking at routine participation or a genuine volume spike. Each bubble is colored by direction: buy, sell, or mixed. You decide how direction is determined, choosing between simple candle direction, volume delta (net buying versus selling pressure pulled from a lower-timeframe scan), or "Both," which only commits to a direction when candle and delta agree, labeling everything else as mixed.
The detection engine itself is flexible. You can trigger on volume only, delta only, both together (strictest), or either one (most inclusive). When delta data isn't available for a symbol, the module automatically falls back to volume-only mode so it never silently breaks. Optional in-bubble text and detailed tooltips display the underlying volume, delta, and volume ratio, along with which lookback windows confirmed the signal—useful when you want to understand why a bar was flagged rather than just that it was. Built-in alert conditions let you get notified on big clusters, medium-or-bigger clusters, or any cluster at all.

Module ② — Volume Profile
The Volume Profile module answers the question that matters most for futures traders: where did the trading actually happen? It distributes traded volume horizontally across price levels over a lookback range you define—either a fixed number of bars or the currently visible range—and uses a smart lower-timeframe engine that dynamically selects the optimal granularity to maximize accuracy within that range.
From this distribution it derives the key reference levels professionals trade around. The Point of Control (POC) marks the single most-traded price, available as a developing line that updates bar by bar or as a static last-value line. The Value Area (68% of volume by default, fully adjustable) is bounded by the Value Area High and Value Area Low, the levels that so often act as intraday support and resistance on NQ. The module also identifies supply and demand zones from low-volume nodes, highlights profile gaps where activity drops sharply between price levels, and overlays a sentiment profile showing the dominant side—bullish or bearish—at each level, classified either by bar polarity or by buying/selling pressure within each bar.
Supporting features round it out: a volume histogram that can sit at the top or bottom of your chart with an optional moving average, volume-weighted bar coloring that tints price bars by how their volume compares to the average (with separate upper and lower thresholds), and a profile stats table summarizing profile high and low, the value area levels, total and average volume, the volume MA, the bar count, and which lower timeframe the data was sourced from. Price-level labels can be aligned directly to the profile rows. The module also fires alerts when price crosses the POC, the Value Area High, or the Value Area Low, when high volume is detected, and when an extreme volume spike suggests possible exhaustion.

Module ③ — NY VWAP + Opening Range
The third module is purpose-built around the New York session, the window where NQ does the bulk of its meaningful work. It plots a session-anchored VWAP that resets at the start of each NY session (9:30–16:00 ET by default, configurable) and can optionally extend its final value past the close so you can see where the session settled. Because it's volume-weighted and session-reset rather than a rolling average, it gives you a clean read on the day's true average traded price—the level institutions and algos lean on.
Alongside the VWAP it tracks the Opening Range (ORB): the high and low established during the first X minutes after the open (15 by default, adjustable up to two hours). Once that window closes, the module draws horizontal lines at the opening range high and low and labels them ORB-H and ORB-L. These lines extend through the rest of the session, giving you a persistent visual frame for one of the most-traded setups in index futures—the opening range breakout and breakdown. The range automatically resets each new trading day, so every session starts clean.

Why use it together
Each module is powerful alone, but they reinforce each other. A Big buy bubble printing right at the Value Area Low, with price reclaiming the opening range high and pushing above session VWAP, is a far stronger signal than any one of those events in isolation. Running all three on one chart gives you volume conviction, structural context, and session timing in a single glance—without burning three indicator slots or forcing you to mentally stitch together separate tools.
Everything is organized under clearly labeled input groups with extensive tooltips, so you can tune the behavior to your symbol, timeframe, and trading style. Toggle off what you don't need, dial in the thresholds that match how NQ trades on your timeframe, and keep your workspace focused.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © navbanga1


// Combined indicator: Volume Bubbles [QuantAlgo] + Volume Profile by DGT + NY VWAP/Opening Range
// Volume Bubbles  : © QuantAlgo  (CC BY-NC-SA 4.0)
// Volume Profile  : © dgtrd
// VWAP + ORB      : original v5 user script (converted to v6)
// Merged into a single fully-customizable indicator with master module toggles.

//@version=6
indicator("Volume Suite: Bubbles + Profile + VWAP/ORB", "VolSuite", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

import TradingView/ta/12 as taLib

//══════════════════════════════════════════════════════════════════════════════
//                            MASTER MODULE TOGGLES
//══════════════════════════════════════════════════════════════════════════════
var string g_master = '═══════════ MASTER MODULE TOGGLES ═══════════'
enableBubbles = input.bool(true, "① Enable Volume Bubbles [QuantAlgo]", group = g_master)
enableProfile = input.bool(true, "② Enable Volume Profile [DGT]",       group = g_master)
enableVWAP    = input.bool(true, "③ Enable NY VWAP + Opening Range",     group = g_master)

//══════════════════════════════════════════════════════════════════════════════
//                                                                              ║
//   MODULE ①  —  VOLUME BUBBLES [QuantAlgo]                                    ║
//                                                                              ║
//══════════════════════════════════════════════════════════════════════════════

var string detection_settings   = '①  ════════ Bubbles: Detection Method ════════'
var string delta_settings       = '①  ════════ Bubbles: Volume Delta Settings ════════'
var string sensitivity_settings = '①  ════════ Bubbles: Cluster Sensitivity ════════'
var string consensus_settings   = '①  ════════ Bubbles: Lookback & Consensus ════════'
var string visual_settings      = '①  ════════ Bubbles: Visualization Settings ════════'

tooltip_detect_method   = 'Determines what data drives cluster detection.\n\nVolume Only: Uses raw bar volume. Simplest and most reliable, works on all symbols. Detects any elevated volume regardless of buy/sell breakdown.\n\nDelta Only: Uses net buy-sell pressure from lower timeframe scan. Triggers only when directional volume (not just total volume) is elevated. Requires LTF data availability.\n\nVolume + Delta: Both volume AND delta must independently exceed their thresholds. Strictest mode, filters out high-volume bars with balanced buy/sell (no clear direction). Best for high-conviction signals.\n\nVolume OR Delta: Either elevated volume OR elevated delta triggers a cluster. Most inclusive mode, catches both pure volume events and strong directional flow even on normal-volume bars.'
tooltip_classify        = 'Determines how each cluster is labeled as Buy, Sell, or Mixed.\n\nCandle Direction: Uses the candle color (green = buy, red = sell). Simple and always available, but does not account for intra-bar volume flow.\n\nDelta Direction: Uses the sign of net volume delta (positive = buy, negative = sell). More accurate reflection of actual buying/selling pressure, but requires LTF data. Falls back to candle direction if delta is unavailable.\n\nBoth: Both candle direction AND delta must point the same way. If they disagree, the cluster is labeled Mixed. Highest confidence classification but produces more Mixed labels.'
tooltip_small_pct       = 'Percentile threshold for identifying Small volume clusters. A value of 75 means a bar must exceed 75% of recent volume history (top 25%) to qualify as a Small cluster.'
tooltip_medium_pct      = 'Percentile threshold for identifying Medium volume clusters. A value of 90 means a bar must exceed 90% of recent volume history (top 10%) to qualify as a Medium cluster.'
tooltip_big_pct         = 'Percentile threshold for identifying Big volume clusters. A value of 97 means a bar must exceed 97% of recent volume history (top 3%) to qualify as a Big cluster.'
tooltip_consensus       = 'Controls how many lookback windows must agree that volume is elevated before a cluster is confirmed.\n\nAny Window: Only one window needs to confirm.\n\nMajority (2 of 3): At least two of the three windows must agree.\n\nAll Windows (strictest): All three windows must confirm.'
tooltip_short_window    = 'Short-term lookback window for percentile calculation. Captures recent volume context and adapts quickly to changing market conditions.'
tooltip_mid_window      = 'Medium-term lookback window for percentile calculation. Provides a balanced perspective between recent activity and broader context.'
tooltip_long_window     = 'Long-term lookback window for percentile calculation. Establishes a broad baseline of typical volume behavior.'
tooltip_custom_tf       = 'Override the automatically detected lower timeframe for delta calculation.'
tooltip_custom_tf_value = 'The specific lower timeframe to use when custom override is enabled. Must be lower than chart timeframe.'
tooltip_show_small      = 'Toggle visibility of Small volume clusters (default: top 25%).'
tooltip_show_medium     = 'Toggle visibility of Medium volume clusters (default: top 10%).'
tooltip_show_big        = 'Toggle visibility of Big volume clusters (default: top 3%).'
tooltip_color_preset    = 'Pre-configured color schemes. Classic, Aqua, Cosmic, Cyber, Neon, or Custom.'
tooltip_buy_color       = 'Color for Buy clusters. Only used when Color Preset is set to Custom.'
tooltip_sell_color      = 'Color for Sell clusters. Only used when Color Preset is set to Custom.'
tooltip_mix_color       = 'Color for Mixed clusters. Only used when Color Preset is set to Custom.'
tooltip_show_labels     = 'Display text inside each volume bubble showing the selected metric.'
tooltip_label_content   = 'Choose what text appears inside each bubble: Volume, Delta, Ratio, Vol + Delta, or Vol + Ratio.'

detectMethod = input.string("Volume OR Delta", "Detection Method", options = ["Volume Only", "Delta Only", "Volume + Delta", "Volume OR Delta"], group = detection_settings, tooltip = tooltip_detect_method)
classifyMode = input.string("Both", "Buy/Sell Classification", options = ["Candle Direction", "Delta Direction", "Both"], group = detection_settings, tooltip = tooltip_classify)

useCustomTF = input.bool(false,    "Use Custom Lower Timeframe", group = delta_settings, tooltip = tooltip_custom_tf)
customTF    = input.timeframe("1", "Custom Timeframe",           group = delta_settings, active = useCustomTF, tooltip = tooltip_custom_tf_value)

smallPct  = input.float(75, "Small Cluster Percentile",  step = 1, group = sensitivity_settings, tooltip = tooltip_small_pct)
mediumPct = input.float(90, "Medium Cluster Percentile", step = 1, group = sensitivity_settings, tooltip = tooltip_medium_pct)
bigPct    = input.float(97, "Big Cluster Percentile",    step = 1, group = sensitivity_settings, tooltip = tooltip_big_pct)

consensusMode = input.string("Majority (2 of 3)", "Consensus Mode", options = ["Any Window", "Majority (2 of 3)", "All Windows (strictest)"], group = consensus_settings, tooltip = tooltip_consensus)
shortLen = input.int(20,  "Short Window",  group = consensus_settings, tooltip = tooltip_short_window)
midLen   = input.int(50,  "Medium Window", group = consensus_settings, tooltip = tooltip_mid_window)
longLen  = input.int(100, "Long Window",   group = consensus_settings, tooltip = tooltip_long_window)

showSmall  = input.bool(true, "Show Small Clusters",  group = visual_settings, tooltip = tooltip_show_small)
showMedium = input.bool(true, "Show Medium Clusters", group = visual_settings, tooltip = tooltip_show_medium)
showBig    = input.bool(true, "Show Big Clusters",    group = visual_settings, tooltip = tooltip_show_big)

colorPreset    = input.string("Custom", "Color Preset", options = ["Classic", "Aqua", "Cosmic", "Cyber", "Neon", "Custom"], group = visual_settings, tooltip = tooltip_color_preset)
buyColorInput  = input.color(color.new(#00ffaa, 40), "Buy Color",   group = visual_settings, tooltip = tooltip_buy_color)
sellColorInput = input.color(color.new(#ff0000, 20), "Sell Color",  group = visual_settings, tooltip = tooltip_sell_color)
mixColorInput  = input.color(color.new(#ffd600, 30), "Mixed Color", group = visual_settings, tooltip = tooltip_mix_color)

[presetBuy, presetSell, presetMix] = switch colorPreset
    "Classic" => [color.new(#00ff00, 40), color.new(#ff0000, 20), color.new(#ffd600, 30)]
    "Aqua"    => [color.new(#00bfff, 40), color.new(#ff8c00, 20), color.new(#9932cc, 30)]
    "Cosmic"  => [color.new(#49ffce, 40), color.new(#9932cc, 20), color.new(#ffd600, 30)]
    "Cyber"   => [color.new(#00cccc, 20), color.new(#ff6600, 40), color.new(#ffd600, 30)]
    "Neon"    => [color.new(#ffff00, 40), color.new(#ff00ff, 20), color.new(#9932cc, 30)]
    "Custom"  => [buyColorInput, sellColorInput, mixColorInput]

color buyColor  = presetBuy
color sellColor = presetSell
color mixColor  = presetMix

showLabels   = input.bool(true, "Show Numbers in Bubbles", group = visual_settings, tooltip = tooltip_show_labels)
labelContent = input.string("Volume", "Bubble Text", options = ["Volume", "Delta", "Ratio", "Vol + Delta", "Vol + Ratio"], group = visual_settings, tooltip = tooltip_label_content)

// ── Volume Delta ──
var string lowerTimeframe = switch
    useCustomTF          => customTF
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

[_, _, _, lastDelta] = taLib.requestVolumeDelta(lowerTimeframe)
bool  deltaAvailable = not na(lastDelta)
float netDelta = nz(lastDelta)
float absDelta = math.abs(netDelta)

// ── Percentile thresholds (only compute when module enabled) ──
float vSmallShort = na, float vSmallMid = na, float vSmallLong = na
float vMedShort   = na, float vMedMid   = na, float vMedLong   = na
float vBigShort   = na, float vBigMid   = na, float vBigLong   = na
float dSmallShort = na, float dSmallMid = na, float dSmallLong = na
float dMedShort   = na, float dMedMid   = na, float dMedLong   = na
float dBigShort   = na, float dBigMid   = na, float dBigLong   = na
float avgVol = na, float volRatio = na

if enableBubbles
    vSmallShort := ta.percentile_linear_interpolation(volume, shortLen, smallPct)
    vSmallMid   := ta.percentile_linear_interpolation(volume, midLen,   smallPct)
    vSmallLong  := ta.percentile_linear_interpolation(volume, longLen,  smallPct)
    vMedShort   := ta.percentile_linear_interpolation(volume, shortLen, mediumPct)
    vMedMid     := ta.percentile_linear_interpolation(volume, midLen,   mediumPct)
    vMedLong    := ta.percentile_linear_interpolation(volume, longLen,  mediumPct)
    vBigShort   := ta.percentile_linear_interpolation(volume, shortLen, bigPct)
    vBigMid     := ta.percentile_linear_interpolation(volume, midLen,   bigPct)
    vBigLong    := ta.percentile_linear_interpolation(volume, longLen,  bigPct)
    dSmallShort := ta.percentile_linear_interpolation(absDelta, shortLen, smallPct)
    dSmallMid   := ta.percentile_linear_interpolation(absDelta, midLen,   smallPct)
    dSmallLong  := ta.percentile_linear_interpolation(absDelta, longLen,  smallPct)
    dMedShort   := ta.percentile_linear_interpolation(absDelta, shortLen, mediumPct)
    dMedMid     := ta.percentile_linear_interpolation(absDelta, midLen,   mediumPct)
    dMedLong    := ta.percentile_linear_interpolation(absDelta, longLen,  mediumPct)
    dBigShort   := ta.percentile_linear_interpolation(absDelta, shortLen, bigPct)
    dBigMid     := ta.percentile_linear_interpolation(absDelta, midLen,   bigPct)
    dBigLong    := ta.percentile_linear_interpolation(absDelta, longLen,  bigPct)
    avgVol      := ta.sma(volume, midLen)
    volRatio    := avgVol > 0 ? volume / avgVol : 0.0

// ── Consensus ──
f_consensus(bool pS, bool pM, bool pL, string mode) =>
    int hits = (pS ? 1 : 0) + (pM ? 1 : 0) + (pL ? 1 : 0)
    switch mode
        "Any Window"              => hits >= 1
        "Majority (2 of 3)"       => hits >= 2
        "All Windows (strictest)" => hits >= 3

bool volBig   = enableBubbles and f_consensus(volume >= vBigShort, volume >= vBigMid, volume >= vBigLong, consensusMode)
bool volMed   = enableBubbles and not volBig and f_consensus(volume >= vMedShort, volume >= vMedMid, volume >= vMedLong, consensusMode)
bool volSmall = enableBubbles and not volBig and not volMed and f_consensus(volume >= vSmallShort, volume >= vSmallMid, volume >= vSmallLong, consensusMode)

bool deltaBig   = enableBubbles and f_consensus(absDelta >= dBigShort, absDelta >= dBigMid, absDelta >= dBigLong, consensusMode)
bool deltaMed   = enableBubbles and not deltaBig and f_consensus(absDelta >= dMedShort, absDelta >= dMedMid, absDelta >= dMedLong, consensusMode)
bool deltaSmall = enableBubbles and not deltaBig and not deltaMed and f_consensus(absDelta >= dSmallShort, absDelta >= dSmallMid, absDelta >= dSmallLong, consensusMode)

// ── Combined detection ──
f_detect(bool vHit, bool dHit, string method) =>
    switch method
        "Volume Only"     => vHit
        "Delta Only"      => dHit
        "Volume + Delta"  => vHit and dHit
        "Volume OR Delta" => vHit or dHit

string effectiveMethod = deltaAvailable ? detectMethod : "Volume Only"

bool isBigCluster   = enableBubbles and f_detect(volBig, deltaBig, effectiveMethod)
bool isMedCluster   = enableBubbles and not isBigCluster and f_detect(volMed or volBig, deltaMed or deltaBig, effectiveMethod)
bool isSmallCluster = enableBubbles and not isBigCluster and not isMedCluster and f_detect(volSmall or volMed or volBig, deltaSmall or deltaMed or deltaBig, effectiveMethod)

// ── Buy/Sell classification ──
bool candleBuy  = close >= open
bool candleSell = close < open

bool isBuy = switch classifyMode
    "Candle Direction" => candleBuy
    "Delta Direction"  => deltaAvailable ? netDelta > 0 : candleBuy
    "Both"             => deltaAvailable ? (candleBuy and netDelta > 0) : candleBuy

bool isSell = switch classifyMode
    "Candle Direction" => candleSell
    "Delta Direction"  => deltaAvailable ? netDelta < 0 : candleSell
    "Both"             => deltaAvailable ? (candleSell and netDelta < 0) : candleSell

// ── Formatting ──
f_formatNum(float v) =>
    float av = math.abs(v)
    string sign = v < 0 ? "-" : ""
    av >= 1000000000 ? sign + str.tostring(av / 1000000000, "#.##") + "B" :
     av >= 1000000   ? sign + str.tostring(av / 1000000, "#.##") + "M" :
     av >= 1000      ? sign + str.tostring(av / 1000, "#.##") + "K" :
     sign + str.tostring(av, "#")

bool isSmallVisible = isSmallCluster and showSmall
bool isMedVisible   = isMedCluster and showMedium
bool isBigVisible   = isBigCluster and showBig
bool isAnyVisible   = isSmallVisible or isMedVisible or isBigVisible

float bubbleY     = isAnyVisible ? (isSell ? high : low) : na
color bubbleColor = isBuy ? buyColor : isSell ? sellColor : mixColor

plotshape(isSmallVisible ? bubbleY : na, "Bubble Small",  shape.circle, location.absolute, bubbleColor, 0, "", na, size = size.normal)
plotshape(isMedVisible   ? bubbleY : na, "Bubble Medium", shape.circle, location.absolute, bubbleColor, 0, "", na, size = size.large)
plotshape(isBigVisible   ? bubbleY : na, "Bubble Big",    shape.circle, location.absolute, bubbleColor, 0, "", na, size = size.huge)

if isAnyVisible and showLabels
    string fv = f_formatNum(volume)
    string fd = f_formatNum(netDelta)
    string rx = str.tostring(volRatio, "#.#") + "x"

    string bubbleText = switch labelContent
        "Volume"      => fv
        "Delta"       => deltaAvailable ? fd : fv
        "Ratio"       => rx
        "Vol + Delta" => deltaAvailable ? fv + "\n" + fd : fv
        "Vol + Ratio" => fv + "\n" + rx

    int cLevel      = isBigVisible ? 3 : isMedVisible ? 2 : 1
    string levelTag = cLevel == 3 ? "BIG" : cLevel == 2 ? "MEDIUM" : "SMALL"
    string sideTag  = isBuy ? "BUY" : isSell ? "SELL" : "MIXED"

    bool vpS = cLevel == 3 ? volume >= vBigShort : cLevel == 2 ? volume >= vMedShort : volume >= vSmallShort
    bool vpM = cLevel == 3 ? volume >= vBigMid   : cLevel == 2 ? volume >= vMedMid   : volume >= vSmallMid
    bool vpL = cLevel == 3 ? volume >= vBigLong  : cLevel == 2 ? volume >= vMedLong  : volume >= vSmallLong
    bool dpS = cLevel == 3 ? absDelta >= dBigShort : cLevel == 2 ? absDelta >= dMedShort : absDelta >= dSmallShort
    bool dpM = cLevel == 3 ? absDelta >= dBigMid   : cLevel == 2 ? absDelta >= dMedMid   : absDelta >= dSmallMid
    bool dpL = cLevel == 3 ? absDelta >= dBigLong  : cLevel == 2 ? absDelta >= dMedLong  : absDelta >= dSmallLong

    string vWin = (vpS ? "S" : "·") + " " + (vpM ? "M" : "·") + " " + (vpL ? "L" : "·")
    string dWin = (dpS ? "S" : "·") + " " + (dpM ? "M" : "·") + " " + (dpL ? "L" : "·")

    string deltaNote = deltaAvailable ? "" : "\nNote: Delta unavailable. Using candle direction and volume only."
    string tip = "── " + levelTag + " " + sideTag + " ──" +
         "\nVolume: " + fv +
         "\nDelta: " + (deltaAvailable ? fd : "n/a") +
         "\nRatio: " + str.tostring(volRatio, "#.##") + "x" +
         "\nMethod: " + detectMethod + (deltaAvailable ? "" : " > Vol Only") +
         "\nVol Windows: [" + vWin + "]" +
         "\nDelta Windows: [" + dWin + "]" +
         "\nClassification: " + classifyMode +
         deltaNote +
         "\n─────────────────────" +
         "\n⚠️ Note: Pine Script limits labels to 500." +
         "\nOlder bubbles still appear but without" +
         "\ntext or tooltip data (plotshape has no cap)."

    label.new(bar_index, bubbleY, bubbleText, style = label.style_label_center, color = color.new(chart.fg_color, 100), textcolor = chart.fg_color, size = size.small, tooltip = tip)

// ── No-volume warning ──
var float cumVol = 0.0
cumVol += nz(volume)
var table warningBox = na
if barstate.islast and cumVol == 0 and enableBubbles
    if na(warningBox)
        warningBox := table.new(position.middle_center, 1, 1, bgcolor = #ff0000)
    table.cell(warningBox, 0, 0, '\n  ⚠️  NO VOLUME DATA  ⚠️  \n\n  This symbol does not provide volume data.  \n\n  Volume Bubbles requires volume to function.  \n\n  Switch to a symbol on an exchange that provides volume data.  \n', text_color = chart.fg_color, text_size = size.large, bgcolor = #ff0000)
else
    if not na(warningBox)
        table.delete(warningBox)
        warningBox := na

alertcondition(isBigVisible,                 "Bubbles: Big Cluster",  "Big volume cluster detected!")
alertcondition(isBigVisible or isMedVisible, "Bubbles: Med+ Cluster", "Medium or Big volume cluster detected!")
alertcondition(isAnyVisible,                 "Bubbles: Any Cluster",  "New volume cluster detected!")

//══════════════════════════════════════════════════════════════════════════════
//                                                                              ║
//   MODULE ②  —  VOLUME PROFILE [DGT]                                          ║
//                                                                              ║
//══════════════════════════════════════════════════════════════════════════════

display_dgt = display.all - display.status_line

vpGR = '②  Volume & Sentiment Profile'

vpSH = input.bool(true, 'Volume Profile', group = vpGR, tooltip = 'Displays total trading activity at each price level within the selected range.')
vpUC = input.color(color.new(#5d606b, 50), '  Up Volume  ', inline = 'VP', group = vpGR)
vpDC = input.color(color.new(#d1d4dc, 50), 'Down Volume ', inline = 'VP', group = vpGR)
vaUC = input.color(color.new(#2962ff, 30), '  Value Area Up', inline = 'VA', group = vpGR)
vaDC = input.color(color.new(#fbc02d, 30), 'Value Area Down', inline = 'VA', group = vpGR)

spSH = input.bool(true, 'Sentiment Profile', group = vpGR, tooltip = 'Displays the dominant trading side at each price level within the selected range.')
spUC = input.color(color.new(#26a69a, 30), '  Bullish', inline = 'BB', group = vpGR)
spDC = input.color(color.new(#ef5350, 30), ' Bearish', inline = 'BB', group = vpGR)

sdSH = input.bool(true, 'Supply & Demand Zones', group = vpGR, tooltip = 'Highlights potential supply and demand areas derived from the volume profile structure.')
sdTH = input.int(15, '  Supply & Demand Threshold %', minval = 0, maxval = 41, group = vpGR, display = display_dgt) / 100
sdSC = input.color(color.new(#ec1313, 80), '  Supply Zones', inline = 'SD', group = vpGR)
sdDC = input.color(color.new(#0094FF, 80), 'Demand Zones', inline = 'SD', group = vpGR)

vgSH = input.bool(true, 'Volume Profile Gaps', inline = 'vnT', group = vpGR, tooltip = 'Detects and highlights Profile Gaps — transition zones within the volume profile where traded activity drops significantly between neighboring nodes.')
vgC  = input.color(color.new(#ff9800, 80), '', inline = 'vnT', group = vpGR)
vgNoN = input.int(7, '  Node Detection %', minval = 0, maxval = 100, display = display_dgt, group = vpGR, tooltip = 'Defines how many surrounding nodes must be compared when detecting a volume profile gap.') / 100

pcSH = input.string('Developing POC', 'Point of Control', options = ['None', 'Developing POC', 'Last (Line)'], inline = 'POC', group = vpGR, display = display_dgt)
pocC = input.color(#f44336, '', inline = 'POC', group = vpGR)
pocW = input.int(2, '', minval = 1, inline = 'POC', group = vpGR, display = display_dgt)

vpVA = input.float(68, 'Value Area (%)', minval = 0, maxval = 100, group = vpGR, display = display_dgt, tooltip = 'Defines the percentage of total traded volume used to calculate the Value Area.') / 100

vahS = input.bool(true, 'Value Area High (VAH)', inline = 'VAH', group = vpGR)
vahC = input.color(#2962ff, '', inline = 'VAH', group = vpGR)
vahW = input.int(1, '', minval = 1, inline = 'VAH', group = vpGR, display = display_dgt)

vlSH = input.bool(true, 'Value Area Low (VAL)', inline = 'VAL', group = vpGR)
valC = input.color(#2962ff, '', inline = 'VAL', group = vpGR)
valW = input.int(1, '', minval = 1, inline = 'VAL', group = vpGR, display = display_dgt)

spP1 = 'Bar Polarity'
spP2 = 'Bar Buying/Selling Pressure'
vpPT = input.string(spP1, 'Profile Polarity Method', options = [spP1, spP2], display = display_dgt, group = vpGR, tooltip = 'Defines how traded volume is classified as buying or selling activity.')
vsPT = vpPT == spP1

vpLR = input.string('Fixed Range', 'Profile Lookback Range', options = ['Fixed Range', 'Visible Range'], display = display_dgt, group = vpGR, tooltip = 'Defines the price range used to build the volume profile.')
vpRL = vpLR == 'Visible Range'

vpLN = input.int(360, '  Fixed Range Length', minval = 10, maxval = 5000, step = 10, display = display_dgt, group = vpGR, tooltip = 'Defines how many historical bars are included when the profile range mode is set to Fixed Range.')
vpLN := last_bar_index < vpLN ? last_bar_index : vpLN - 1

vpST = input.bool(true, 'Profile Stats', inline = 'STT', group = vpGR, tooltip = 'Displays a summary table containing key profile statistics.')
ppLS = input.string('Small', '', options = ['Tiny', 'Small', 'Normal'], inline = 'STT', group = vpGR, display = display_dgt)
lcDB = input.string('Top Right', '', options = ['Top Right', 'Middle Right', 'Bottom Left'], inline = 'STT', group = vpGR, display = display_dgt)

vpLV = input.bool(true, 'Profile Price Levels', inline = 'BBe', group = vpGR, tooltip = 'Displays price labels aligned with the volume profile rows.')
rpLS = input.string('Small', '', options = ['Tiny', 'Small', 'Normal'], inline = 'BBe', group = vpGR, display = display_dgt)

vpPL = input.string('Right', 'Profile Placement', options = ['Right', 'Left'], group = vpGR, display = display_dgt)
vpRT = vpPL == 'Right'
vpNR = input.int(100, 'Profile Number of Rows', minval = 10, maxval = 150, step = 10, group = vpGR, display = display_dgt)
vpWD = input.float(31, 'Profile Width (%)', minval = 0, maxval = 250, group = vpGR, display = display_dgt) / 100
vpHO = input.int(13, 'Profile Horizontal Offset', maxval = 50, group = vpGR, display = display_dgt)

vaBG = input.bool(false, 'Value Area Background  ', inline = 'vBG', group = vpGR)
vBGC = input.color(color.new(#2962ff, 89), '', inline = 'vBG', group = vpGR)
vpBG = input.bool(false, 'Profile Range Background ', inline = 'pBG', group = vpGR)
bgC  = input.color(color.new(#2962ff, 95), '', inline = 'pBG', group = vpGR)

vhGR = '②  Volume Histogram'
vhSH = input.bool(true, 'Volume Histogram', group = vhGR, tooltip = 'Displays the traded volume for each individual price bar.')
vmaS = input.bool(true, 'Volume MA,         Length', inline = 'vol2', group = vhGR)
vmaL = input.int(21, '', minval = 1, inline = 'vol2', group = vhGR, display = display_dgt)
vhUC = input.color(color.new(#26a69a, 30), '  Growing', inline = 'vol1', group = vhGR)
vhDC = input.color(color.new(#ef5350, 30), 'Falling', inline = 'vol1', group = vhGR)
vmaC = input.color(color.new(#2962ff, 0), 'Volume MA', inline = 'vol1', group = vhGR)
vhPL = input.string('Top', '  Placement', options = ['Top', 'Bottom'], group = vhGR, display = display_dgt)
vhLP = vhPL == 'Top'
vhHT = 11 - input.int(8, '  Height', minval = 1, maxval = 10, group = vhGR, display = display_dgt)
vhVO = input.int(1, '  Vertical Offset', minval = 0, maxval = 20, group = vhGR, display = display_dgt) / 20

cbGR = '②  Volume-Weighted Bar Coloring'
vwcb = input.bool(false, 'Volume-Weighted Bar Coloring', group = cbGR, tooltip = 'Colors price bars based on their volume relative to the volume moving average.')
upTH = input.float(1.618, '  Upper Threshold', minval = 1., step = .1, group = cbGR, display = display_dgt)
dnTH = input.float(0.618, '  Lower Threshold', minval = .1, step = .1, group = cbGR, display = display_dgt)

// ── UDTs ──
type bar
	float o = open
	float h = high
	float l = low
	float c = close
	float v = volume
	int i = bar_index

type barData
	array<float> bh
	array<float> bl
	array<float> bv
	array<bool> bp
	array<int> bn

type volData
	array<float> vt
	array<float> vb
	array<float> vd

type tVP
	array<box> vp
	array<chart.point> pPC
	polyline dPC
	int pcL
	int laP
	int lbP
	int sI

type tVH
	array<line> vh
	array<chart.point> pMA
	polyline vMA

// ── Variables ──
var barData bD = barData.new(array.new<float>(na), array.new<float>(na), array.new<float>(na), array.new<bool>(na), array.new<int>(na))
volData vD = volData.new(array.new<float>(vpNR, 0.), array.new<float>(vpNR, 0.), array.new<float>(vpNR, 0.))
var tVP VP = tVP.new(array.new<box>(na), array.new<chart.point>(na), polyline.new(na), na, na, na, na)
var tVH VH = tVH.new(array.new<line>(na), array.new<chart.point>(na), polyline.new(na))
array<bar> ltfBD = array.new<bar>(1, bar.new())
var float pHST = na
var float pLST = na
var string ltf = na

// ── Functions ──
f_drawLineX(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width) =>
    var id = line.new(_x1, _y1, _x2, _y2, _xloc, _extend, _color, _style, _width)
    line.set_xy1(id, _x1, _y1)
    line.set_xy2(id, _x2, _y2)
    line.set_color(id, _color)

f_drawLabelX(_x, _y, _text, _color, _style, _textcolor, _size, _tooltip) =>
    var lb = label.new(_x, _y, _text, xloc.bar_index, yloc.price, _color, _style, _textcolor, _size, text.align_left, _tooltip)
    lb.set_xy(_x, _y)
    lb.set_text(_text)
    lb.set_tooltip(_tooltip)
    lb.set_textcolor(_textcolor)

getData(_ltf) =>
    request.security_lower_tf(syminfo.tickerid, _ltf, bar.new(), ignore_invalid_timeframe = true)

var string[] secTF = array.from('1S','5S','15S','30S')
var string[] minTF = array.from('1','3','5','15','30','60','120','240','1D')

f_gTF(_lookback) =>
    int tfInSec   = timeframe.in_seconds(timeframe.period)
    int totalSec  = tfInSec * _lookback
    int mInSec    = 60
    if timeframe.isseconds
        string result = '1S'
        for tfStr in secTF
            int ltfSec = timeframe.in_seconds(tfStr)
            if totalSec / ltfSec < 5000
                result := tfStr
                break
        result
    else
        int ltfSec = 1 * mInSec
        result = timeframe.period
        for tfStr in minTF
            ltfSec := timeframe.in_seconds(tfStr)
            if totalSec / ltfSec < 5000
                result := tfStr
                break
        result

f_gTS(_t) =>
    switch _t
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        => size.auto

f_crossingLevelX(_price, _level) =>
    _level > _price and _level < _price[1] or _level < _price and _level > _price[1]

alarm(_message) =>
    alert(syminfo.ticker + ' ' + _message + ', price ' + str.tostring(close, format.mintick) + ', timeframe ' + timeframe.period, alert.freq_once_per_bar)

// ── Calculations ──
nzV = nz(volume)
vSMA = ta.sma(nzV, vmaL)

rpS = f_gTS(rpLS)
ppLSsize = f_gTS(ppLS)

tPOS = lcDB == 'Top Right' ? position.top_right : lcDB == 'Middle Right' ? position.middle_right : position.bottom_left

if enableProfile and time == chart.left_visible_bar_time
    VP.sI := bar_index

if enableProfile and vpRL
    vpLN := last_bar_index - VP.sI

if enableProfile and bar_index == last_bar_index - vpLN
    VP.sI := bar_index
    pLST := low
    pHST := high
else if enableProfile and bar_index > last_bar_index - vpLN
    pLST := math.min(low, pLST)
    pHST := math.max(high, pHST)

if enableProfile and (barstate.isfirst or vpRL)
    ltf := f_gTF(vpLN)

if enableProfile
    ltfBD := getData(ltf)

if enableProfile and barstate.ishistory and bar_index >= last_bar_index - vpLN and bar_index < last_bar_index and ltfBD.size() > 0
    if ltfBD.size() > 0 and not na(nz(ltfBD.get(0).v))
        for i = 0 to ltfBD.size() - 1 by 1
            bD.bh.push(ltfBD.get(i).h)
            bD.bl.push(ltfBD.get(i).l)
            bD.bv.push(ltfBD.get(i).v)
            if vsPT
                bD.bp.push(ltfBD.get(i).c > ltfBD.get(i).o)
            else
                bD.bp.push(ltfBD.get(i).c - ltfBD.get(i).l > ltfBD.get(i).h - ltfBD.get(i).c)
        bD.bn.push(ltfBD.size())

pSTP = (pHST - pLST) / vpNR

if enableProfile and barstate.islast and ltfBD.size() > 0

    if VP.vp.size() > 0
        for i = VP.vp.size() - 1 to 0
            box.delete(VP.vp.shift())

    if bD.bn.size() > vpLN
        qt = bD.bn.shift()
        for i = 0 to qt - 1 by 1
            bD.bh.shift()
            bD.bl.shift()
            bD.bv.shift()
            bD.bp.shift()

    if not na(VP.dPC)
        VP.pPC.clear()
        VP.dPC.delete()

    if ltfBD.size() > 0 and not na(nz(ltfBD.get(0).v))
        for i = 0 to ltfBD.size() - 1 by 1
            bD.bh.push(ltfBD.get(i).h)
            bD.bl.push(ltfBD.get(i).l)
            bD.bv.push(ltfBD.get(i).v)
            if vsPT
                bD.bp.push(ltfBD.get(i).c > ltfBD.get(i).o)
            else
                bD.bp.push(ltfBD.get(i).c - ltfBD.get(i).l > ltfBD.get(i).h - ltfBD.get(i).c)
        bD.bn.push(ltfBD.size())

    bI = vpLN
    bSZ = 0
    aSZ = bD.bv.size()

    for aI = 0 to aSZ - 1 by 1
        lH = bD.bh.get(aI)
        lL = bD.bl.get(aI)
        lV = bD.bv.get(aI)
        lR = math.max(lH - lL, syminfo.mintick)

        int sSI = math.max(math.floor((lL - pLST) / pSTP), 0)
        int eSI = math.min(math.floor((lH - pLST) / pSTP), vpNR - 1)

        for pLI = sSI to eSI
            float pL = pLST + pLI * pSTP
            vPOR = switch
                lL >= pL and lH > pL + pSTP   => (pL + pSTP - lL) / lR
                lH <= pL + pSTP and lL < pL   => (lH - pL) / lR
                lL >= pL and lH <= pL + pSTP  => 1
                => pSTP / lR
            vD.vt.set(pLI, vD.vt.get(pLI) + lV * vPOR)
            if bD.bp.get(aI)
                vD.vb.set(pLI, vD.vb.get(pLI) + lV * vPOR)

        if pcSH == 'Developing POC'
            if aI == bD.bn.get(vpLN - bI)
                VP.pPC.push(chart.point.from_index(bar_index[bI], math.avg(high[bI], low[bI])))
                VP.pPC.push(chart.point.from_index(bar_index[bI] + 1, pLST + (vD.vt.indexof(vD.vt.max()) + .5) * pSTP))
                bSZ := bSZ + bD.bn.get(vpLN - bI)
                bI := bI - 1
            else if aI == bSZ + bD.bn.get(vpLN - bI) and bSZ != 0
                VP.pPC.push(chart.point.from_index(bar_index[bI] + 1, pLST + (vD.vt.indexof(vD.vt.max()) + .5) * pSTP))
                bSZ := bSZ + bD.bn.get(vpLN - bI)
                bI := bI - 1
            else if bI == 0
                VP.pPC.push(chart.point.from_index(bar_index[bI] + 1, pLST + (vD.vt.indexof(vD.vt.max()) + .5) * pSTP))
                bSZ := bSZ + bD.bn.get(vpLN - bI)

    VP.dPC := polyline.new(VP.pPC, false, false, xloc.bar_index, pocC, color(na), line.style_solid, pocW)

    for i = 0 to vpNR - 1 by 1
        bbp = 2 * vD.vb.get(i) - vD.vt.get(i)
        vD.vd.set(i, vD.vd.get(i) + bbp * (bbp > 0 ? 1 : -1))

    VP.pcL := vD.vt.indexof(vD.vt.max())
    ttV = math.max(vD.vt.sum(), 1e-10) * vpVA
    va = vD.vt.get(VP.pcL)
    VP.laP := VP.pcL
    VP.lbP := VP.pcL

    var int maxIter = vpNR * 2
    int iterCount = 0
    while va < ttV and iterCount < maxIter
        iterCount += 1
        if VP.lbP == 0 and VP.laP == vpNR - 1
            break
        vaP = 0.
        if VP.laP < vpNR - 1
            vaP := vD.vt.get(VP.laP + 1)
        vbP = 0.
        if VP.lbP > 0
            vbP := vD.vt.get(VP.lbP - 1)
        if vaP >= vbP
            va += vaP
            VP.laP += 1
        else
            va += vbP
            VP.lbP -= 1

    vaH = pLST + (VP.laP + 1.) * pSTP
    poc = pLST + (VP.pcL + .5) * pSTP
    vaL = pLST + (VP.lbP + .0) * pSTP
    pLN = vpLN > 360 ? 360 : vpLN

    if vahS
        f_drawLineX(VP.sI, vaH, vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index : last_bar_index, vaH, xloc.bar_index, extend.none, vahC, line.style_solid, vahW)

    if pcSH == 'Last (Line)'
        f_drawLineX(VP.sI, poc, last_bar_index, poc, xloc.bar_index, extend.none, pocC, line.style_solid, pocW)

    if vlSH
        f_drawLineX(VP.sI, vaL, vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index : last_bar_index, vaL, xloc.bar_index, extend.none, valC, line.style_solid, valW)

    if vaBG
        VP.vp.push(box.new(VP.sI, vaL, last_bar_index, vaH, vBGC, 1, line.style_dotted, bgcolor = vBGC))

    if vpBG
        VP.vp.push(box.new(VP.sI, pLST, last_bar_index, pHST, bgC, 1, line.style_dotted, bgcolor = bgC))

    if vpLV
        f_drawLabelX(vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index : last_bar_index, pHST, str.tostring(pHST, format.mintick), color.new(chart.fg_color, 89), vpRT ? not vpSH and not spSH ? label.style_label_left : label.style_label_down : label.style_label_left, chart.fg_color, rpS, 'Profile High')
        f_drawLabelX(vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index + (spSH ? int(vD.vd.max() / vD.vt.max() * pLN * vpWD) : 0) : last_bar_index, vaH, str.tostring(vaH, format.mintick), color.new(vahC, 89), label.style_label_left, vahC, rpS, 'Value Area High')
        f_drawLabelX(vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index + (spSH ? int(vD.vd.max() / vD.vt.max() * pLN * vpWD) : 0) : last_bar_index, poc, str.tostring(poc, format.mintick), color.new(pocC, 89), label.style_label_left, pocC, rpS, 'Point of Control')
        f_drawLabelX(vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index + (spSH ? int(vD.vd.max() / vD.vt.max() * pLN * vpWD) : 0) : last_bar_index, vaL, str.tostring(vaL, format.mintick), color.new(valC, 89), label.style_label_left, valC, rpS, 'Value Area Low')
        f_drawLabelX(vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : spSH ? vpHO : 0) + last_bar_index : last_bar_index, pLST, str.tostring(pLST, format.mintick), color.new(chart.fg_color, 89), vpRT ? not vpSH and not spSH ? label.style_label_left : label.style_label_up : label.style_label_left, chart.fg_color, rpS, 'Profile Low')

    if vpST
        var table change = table.new(tPOS, 2, 10, border_width = 3)
        tC = chart.fg_color
        table.cell(change, 0, 0, 'Profile High', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'profile high - ' + str.tostring(pHST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pLST * 100, '#.##') + ' higher than the profile low (' + str.tostring(pLST, format.mintick) + ')')
        table.cell(change, 1, 0, str.tostring(pHST, format.mintick), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 1, 'Value Area High', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize)
        table.cell(change, 1, 1, str.tostring(vaH, format.mintick), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 2, 'Point of Control', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize)
        table.cell(change, 1, 2, str.tostring(poc, format.mintick), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 3, 'Value Area Low', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize)
        table.cell(change, 1, 3, str.tostring(vaL, format.mintick), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 4, 'Profile Low', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'profile low - ' + str.tostring(pLST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pHST * 100, '#.##') + ' lower than the profile high (' + str.tostring(pHST, format.mintick) + ')')
        table.cell(change, 1, 4, str.tostring(pLST, format.mintick), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 5, 'Total Volume\nin VP Range', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'total traded volume in vp range')
        table.cell(change, 1, 5, str.tostring(vD.vt.sum(), format.volume), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 6, 'Avg Volume/Bar', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'average traded volume per bar in vp range')
        table.cell(change, 1, 6, str.tostring(vD.vt.sum() / (vpLN + 1), format.volume), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 7, 'Volume MA (' + str.tostring(vmaL) + ')', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'volume moving average')
        table.cell(change, 1, 7, str.tostring(vSMA, format.volume), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 8, 'Number of Bars', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'number of chart bars : ' + str.tostring(vpLN) + ' + 1 (developing bar)')
        table.cell(change, 1, 8, str.tostring(vpLN + 1), text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)
        table.cell(change, 0, 9, 'Data From', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_left, text_size = ppLSsize, tooltip = 'Smart LTF logic: dynamically selects the optimal lower timeframe to maximize volume distribution accuracy within the lookback range.')
        table.cell(change, 1, 9, ltf + ' TF', text_color = tC, bgcolor = color.new(tC, 80), text_halign = text.align_right, text_size = ppLSsize)

    if vgSH
        var bool uNth = false
        var bool lNth = false
        noN = int(vpNR * vgNoN)
        tVT = vD.vt.copy()
        for index = 1 to noN
            tVT.unshift(vD.vt.max())
            tVT.push(vD.vt.max())
        for vn = 0 to vpNR - 1 + 2 * noN
            if vgSH and vn >= 2 * noN
                for cVN = vn - 2 * noN to vn - noN - 1
                    if tVT.get(vn - noN) >= tVT.get(cVN)
                        uNth := false
                        break
                    else
                        uNth := true
                for cVN = vn - noN + 1 to vn
                    if tVT.get(vn - noN) >= tVT.get(cVN)
                        lNth := false
                        break
                    else
                        lNth := true
                if uNth and lNth
                    VP.vp.push(box.new(bar_index[vpLN], pLST + (vn - 2 * noN + .1) * pSTP, vpRT ? int(pLN * vpWD + vpHO) + last_bar_index : bar_index, pLST + (vn - 2 * noN + .9) * pSTP, color(na), bgcolor = vgC, xloc = xloc.bar_index))

    for i = 0 to vpNR - 1 by 1
        maxVol = math.max(vD.vt.max(), 1e-10)
        if vpSH
            sBI = vpRT ? int(pLN * vpWD + vpHO) + int(last_bar_index - vD.vb.get(i) / maxVol * pLN * vpWD) : VP.sI
            eBI = vpRT ? int(pLN * vpWD + vpHO) + last_bar_index : int(sBI + vD.vb.get(i) / maxVol * pLN * vpWD)
            VP.vp.push(box.new(sBI, pLST + (i + .1) * pSTP, eBI, pLST + (i + .9) * pSTP, color(na), bgcolor = i >= VP.lbP and i <= VP.laP ? vaUC : vpUC))
            sBI := vpRT ? sBI : eBI
            eBI := vpRT ? sBI - int((vD.vt.get(i) - vD.vb.get(i)) / maxVol * pLN * vpWD) : sBI + int((vD.vt.get(i) - vD.vb.get(i)) / maxVol * pLN * vpWD)
            VP.vp.push(box.new(sBI, pLST + (i + .1) * pSTP, eBI, pLST + (i + .9) * pSTP, color(na), bgcolor = i >= VP.lbP and i <= VP.laP ? vaDC : vpDC))
        if spSH
            sBI = vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : vpHO) + int(last_bar_index + vD.vd.get(i) / maxVol * pLN * vpWD) : VP.sI
            eBI = vpRT ? (vpSH ? int(pLN * vpWD + vpHO) : vpHO) + last_bar_index : vpRL ? int(sBI + vD.vd.get(i) / maxVol * pLN * vpWD) : int(sBI - vD.vd.get(i) / maxVol * pLN * vpWD)
            bbp = 2 * vD.vb.get(i) - vD.vt.get(i)
            VP.vp.push(box.new(sBI + 1, pLST + (i + .1) * pSTP, eBI + 1, pLST + (i + .9) * pSTP, color(na), bgcolor = bbp > 0 ? spUC : spDC))
        if sdSH and vD.vt.get(i) / maxVol < sdTH
            sdC = pLST + (i + 0.50) * pSTP > pLST + (VP.pcL + .5) * pSTP ? sdSC : sdDC
            VP.vp.push(box.new(bar_index[vpLN], pLST + (i + 1.) * pSTP, bar_index, pLST + (i + .0) * pSTP, color(na), bgcolor = sdC))

// ── Volume Histogram ──
pHSTv = ta.highest(high, vpLN < 497 ? vpLN : 496)
pLSTv = ta.lowest(low, vpLN < 497 ? vpLN : 496)
vHST = ta.highest(nzV, vpLN < 497 ? vpLN : 496)
vMAR = nzV / vSMA

if enableProfile and barstate.islast and not na(nzV) and vhSH and vSMA > 0
    pCHR = (pHSTv - pLSTv) / pHSTv
    if VH.vh.size() > 0
        for i = 0 to VH.vh.size() - 1 by 1
            line.delete(VH.vh.shift())
    VH.pMA.clear()
    VH.vMA.delete()
    for bI = 0 to vpLN by 1
        if VH.vh.size() < 500
            VH.vh.push(line.new(bar_index[bI], vhLP ? pHST + pHSTv * pCHR * vhVO : pLST - pLSTv * pCHR * vhVO, bar_index[bI], (vhLP ? pHST + pHSTv * pCHR * vhVO : pLST - pLSTv * pCHR * vhVO) * (1 + (vhLP ? 1 : -1) * nzV[bI] / vHST * pCHR / vhHT), xloc.bar_index, extend.none, close[bI] > open[bI] ? vhUC : vhDC, line.style_solid, 2))
            if vmaS and not na(vSMA[bI])
                VH.pMA.push(chart.point.from_index(bar_index[bI], (vhLP ? pHST + pHSTv * pCHR * vhVO : pLST - pLSTv * pCHR * vhVO) * (1 + (vhLP ? 1 : -1) * nzV[bI] / vHST * pCHR / vhHT / vMAR[bI])))
    VH.vMA := polyline.new(VH.pMA, false, false, xloc.bar_index, vmaC, color(na), line.style_solid, 1)

// ── Volume-Weighted Colored Bars ──
barcolor(enableProfile and vwcb and not na(nzV) ? nzV > vSMA * upTH ? open < close ? #006400 : #910000 : nzV < vSMA * dnTH ? open < close ? #7FFFD4 : #FF9800 : na : na, title = 'Volume Weighted Colored Bars', editable = false)

// ── Profile alerts ──
if enableProfile and f_crossingLevelX(close[1], pLST + (VP.pcL + .50) * pSTP) and pcSH != 'None'
    alarm('price action ' + (close[1] > pLST + (VP.pcL + .50) * pSTP ? 'crossed above ' : 'crossed below ') + 'the point of control line')
if enableProfile and f_crossingLevelX(close[1], pLST + (VP.laP + 1.00) * pSTP) and vahS
    alarm('price action ' + (close[1] > pLST + (VP.laP + 1.00) * pSTP ? 'crossed above ' : 'crossed below ') + 'the value area high line')
if enableProfile and f_crossingLevelX(close[1], pLST + (VP.lbP + 0.00) * pSTP) and vlSH
    alarm('price action ' + (close[1] > pLST + (VP.lbP + 0.00) * pSTP ? 'crossed above ' : 'crossed below ') + 'the value area low line')
if enableProfile and nzV > vSMA * upTH and (vwcb or vhSH)
    alarm('high volume detected')
if enableProfile and nzV > vSMA * 4.669 and (vwcb or vhSH)
    alarm('watch out volume spike detected, may be a sign of exhaustion')

//══════════════════════════════════════════════════════════════════════════════
//                                                                              ║
//   MODULE ③  —  NY VWAP + OPENING RANGE                                       ║
//                                                                              ║
//══════════════════════════════════════════════════════════════════════════════

var string g_vwap = '③  NY VWAP + Opening Range'
extendVWAP  = input.bool(false, "Extend VWAP After Session", group = g_vwap)
orHighColor = input.color(color.lime, "OR High Color", group = g_vwap)
orLowColor  = input.color(color.red,  "OR Low Color",  group = g_vwap)
lineWidth   = input.int(2, "OR Line Width", minval = 1, maxval = 5, group = g_vwap)
sessionTime = input.session("0930-1600", "Trading Session (NY)", group = g_vwap)
orMinutes   = input.int(15, "Opening Range Minutes", minval = 1, maxval = 120, group = g_vwap)

t = time(timeframe.period, sessionTime, "America/New_York")
inSession  = enableVWAP and not na(t)
newSession = inSession and na(t[1])
endSession = enableVWAP and not inSession and inSession[1]

// ── Session VWAP ──
var float pv = 0.0
var float vol = 0.0
var float lastVWAP = na

if newSession
    pv := 0.0
    vol := 0.0
if inSession
    pv += hlc3 * volume
    vol += volume

vwap = vol > 0 ? pv / vol : na
if endSession
    lastVWAP := vwap[1]

finalVWAP = enableVWAP ? (inSession ? vwap : (extendVWAP ? lastVWAP : na)) : na
plot(finalVWAP, title = "NY VWAP", color = color.orange, linewidth = 2, style = plot.style_linebr)

// ── Opening Range ──
nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

orStartMin = 9 * 60 + 30
orEndMin   = orStartMin + orMinutes
nowMin     = nyHour * 60 + nyMinute

isOR  = enableVWAP and (nowMin >= orStartMin and nowMin < orEndMin)
atOREnd = enableVWAP and (nowMin == orEndMin)

var float orHigh = na
var float orLow  = na

if enableVWAP and ta.change(time("D")) != 0
    orHigh := na
    orLow  := na

if isOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

var line hiLine = na
var line loLine = na

if atOREnd and not na(orHigh)
    hiLine := line.new(bar_index, orHigh, bar_index, orHigh, color = orHighColor, width = lineWidth)
    loLine := line.new(bar_index, orLow,  bar_index, orLow,  color = orLowColor,  width = lineWidth)

inSessionTime = enableVWAP and (nyHour >= 9 and nyHour < 16)

if inSessionTime and not na(hiLine)
    line.set_x2(hiLine, bar_index)
    line.set_x2(loLine, bar_index)

var label hiLabel = na
var label loLabel = na

if atOREnd and not na(orHigh)
    hiLabel := label.new(bar_index, orHigh, "ORB-H", style = label.style_none, textcolor = orHighColor, size = size.small)
    loLabel := label.new(bar_index, orLow,  "ORB-L", style = label.style_none, textcolor = orLowColor,  size = size.small)

if inSessionTime and not na(hiLabel)
    label.set_x(hiLabel, bar_index)
    label.set_x(loLabel, bar_index)
````
