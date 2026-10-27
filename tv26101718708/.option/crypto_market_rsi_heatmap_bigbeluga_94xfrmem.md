# Crypto Market RSI Heatmap [BigBeluga]

- url: https://www.tradingview.com/script/94xfRMeM-Crypto-Market-RSI-Heatmap-BigBeluga/
- type: indicator
- pine_id: PUB;b677507e9da04b84b38990bbc03c9abe
- version: 2.0

## Description

[b]🔵 OVERVIEW[/b]

The [b]Crypto Market RSI Heatmap [BigBeluga][/b] is a comprehensive, institutional-grade sector momentum matrix built for TradingView. It consolidates relative strength metrics for up to 20 cross-sectional crypto assets into a single, highly readable multi-group pane. Instead of forcing you to open dozens of browser tabs or flip back and forth between charts, this system runs concurrent structural background queries to map real-time market overbought expansions and oversold depressions using an advanced, color-gradient visual framework.


[b]🔵 FEATURES[/b]

The indicator tracks cross-asset momentum cycles through an isolated data processing engine:

[b]1 — Multi-Asset Matrix Architecture[/b]
[list]
[*] [b]Modular Asset Grouping:[/b] Assets are automatically split into 4 distinct structural sectors (Group A through Group D). Each section handles up to 5 completely customizable tickers, allowing you to organize setups by Layer 1s, DeFi, Memes, or Major pairs.
[image]https://www.tradingview.com/x/AdR7cxd9/[/image]
[*] [b]Independent Timeframe Anchors:[/b] Every group has an isolated execution timeframe filter ([b]Timeframe[/b]). This allows you to monitor short-term scalping momentum in one sector while simultaneously tracking macroscopic daily trend structures in another.
[image]https://www.tradingview.com/x/MsyPtgoS/[/image]
[*] [b]Dynamic Highlight Tracking:[/b] The background matrix scans the active workspace. The exact asset loaded on your current open chart is highlighted with a custom accent marker ([b]Current Chart Asset Highlight[/b]) so you never lose your visual anchor.
[image]https://www.tradingview.com/x/raWuU6Fz/[/image]
[/list]

[b]2 — Momentum Filters & Statistical Computations[/b]
[list]
[*] [b]Flexible Core Oscillators:[/b] The engine isn't limited to standard RSI calculations. Users can instantly toggle between a classic Relative Strength Index, Money Flow Index (MFI) to capture volume distribution, or a fast-response Stochastic RSI.
[image]https://www.tradingview.com/x/zS05vuC3/[/image]
[*] [b]Group Average Horizon Lines:[/b] Dotted real-time horizontal baselines calculate the mean historical mathematical score of each active group, providing an instant look at overall sector health.
[image]https://www.tradingview.com/x/F5FHA217/[/image]
[*] [b]Real-Time Cluster Stats:[/b] A live sub-label maps out the active average, minimum, and maximum value points for every cluster directly across the base of the indicator workspace.
[image]https://www.tradingview.com/x/0Kkvzwgn/[/image]
[/list]

[pine]
// 3-Point Color Gradient Engine & Highlighting Mechanism
color dynamicCoinColor = colorMidYel
if coinRSI >= 50.0
    dynamicCoinColor := color.from_gradient(coinRSI, 50.0, 75.0, colorMidYel, colorMaxRed)
else
    dynamicCoinColor := color.from_gradient(coinRSI, 25.0, 50.0, colorMaxGrn, colorMidYel)

bool isActiveChartAsset = str.contains(str.split(symbol, ":").last(), syminfo.ticker)
if isActiveChartAsset
    dynamicCoinColor := colorActive
[/pine]


[b]🔵 HOW TO USE[/b]

Using the system to gauge sector rotation requires a systematic analysis flow:

[list=1]
[*] [b]Evaluating Sector Divergences:[/b] Monitor the separate group structures to identify relative market leaders and laggards. When Group A’s average baseline pushes deeply into the upper red expansion zone while Group B remains pinned inside the lower green oversold region, money is explicitly rotating out of one pocket and into the other.
[*] [b]Tracking Active Momentum Continuations:[/b] Watch the trailing dashed historical lines to catch velocity expansions. Assets that break heavily out of the neutral 50 level and carry an institutional-grade gradient color shift provide high-probability breakout opportunities.
[*] [b]Isolating Market Anomalies:[/b] Use the bottom statistics panel to hunt down structural outliers. If a major sector average is floating heavily at a overbought 75 reading, but an individual coin within that exact cluster is sitting at a depressed 35 minimum level, you have found an inefficiencies setup.
[/list]


[b]🔵 NOTES[/b]

[b]Why this implementation is unique:[/b]
[list]
[*] It completely replaces standard, bulky multi-pane monitor clusters by arranging up to 20 assets side-by-side using a clean, space-staggered horizontal charting layout.
[*] The dual-layer label framework overlays readable ticker identifiers directly on top of real-time momentum tracking nodes, preserving chart real estate without sacrificing readability.
[*] It bridges standard price-derived momentum structures with user-defined asset lists, creating a bespoke internal crypto index tracking workspace.
[/list]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Crypto Market RSI Heatmap [BigBeluga]", overlay=false, max_labels_count=500, max_lines_count=500, calc_bars_count = 100)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
groupMain  = "Core Settings"
typeOsc = input.string("RSI", "Oscilator", ["RSI", "MFI", "Stochastic"], group=groupMain, inline = "osc")

length  = input.int(14, title="Length", group=groupMain, inline = "osc", tooltip="Calculates the relative strength index momentum speed across this specific bar length period.")
showMain   = input.bool(false, title="Hide Background Asset Oscilator Line", group=groupMain, tooltip="When enabled, completely removes the thin underlying base asset's native RSI plot line from rendering on the indicator backdrop.")

groupTog   = "Visibility Overrides"
showAvgLns = input.bool(true, title="Show Group Average Horizon Lines", group=groupTog, tooltip="Toggles the horizontal bounded dotted tracking lines that mark each active group's mean internal mathematical RSI calculation score.")

// ---------------------------------------------------------------- Theme Customization Inputs
groupTheme = "Theme Styling & Colors"
colorMaxRed = input.color(#ff3636, title="Overbought Color", group=groupTheme, tooltip="Color applied to assets sitting in extreme overbought expansion zones (RSI closer to 70-100).")
colorMidYel = input.color(#948d77, title="Neutral Zone Color", group=groupTheme, tooltip="Color used for the central balanced consolidation zone (RSI around 50).")
colorMaxGrn = input.color(#27ffa9, title="Oversold Color", group=groupTheme, tooltip="Color applied to assets sitting in extreme oversold depression zones (RSI closer to 0-30).")
colorActive = input.color(#34a4ff, title="Current Chart Asset Highlight", group=groupTheme, tooltip="The distinct accent color applied exclusively to the asset matching the current active workspace chart.")

// ---------------------------------------------------------------- Dynamic Symbol Inputs & Toggles
group1    = "Asset Selection - Group A"
toggleA   = input.bool(true, title="Enable Group A Processing", group=group1)
tf1       = input.timeframe("", title="Timeframe", group=group1, tooltip="The execution chart timeframe anchor used to pull remote security data. Leave empty to mirror the current active chart state.") 

s01       = input.symbol("BINANCE:BTCUSDT",  title="Coin 1",  group=group1)
s02       = input.symbol("BINANCE:ETHUSDT",  title="Coin 2",  group=group1)
s03       = input.symbol("BINANCE:SOLUSDT",  title="Coin 3",  group=group1)
s04       = input.symbol("BINANCE:BNBUSDT",  title="Coin 4",  group=group1)
s05       = input.symbol("BINANCE:XRPUSDT",  title="Coin 5",  group=group1)

group2    = "Asset Selection - Group B"
toggleB   = input.bool(true, title="Enable Group B Processing", group=group2)
tf2       = input.timeframe("", title="Timeframe", group=group2, tooltip="The execution chart timeframe anchor used to pull remote security data. Leave empty to mirror the current active chart state.") 

s06       = input.symbol("BINANCE:ADAUSDT",  title="Coin 6",  group=group2)
s07       = input.symbol("BINANCE:AVAXUSDT", title="Coin 7",  group=group2)
s08       = input.symbol("BINANCE:DOGEUSDT", title="Coin 8",  group=group2)
s09       = input.symbol("BINANCE:DOTUSDT",  title="Coin 9",  group=group2)
s10       = input.symbol("BINANCE:LINKUSDT", title="Coin 10", group=group2)

group3    = "Asset Selection - Group C"
toggleC   = input.bool(true, title="Enable Group C Processing", group=group3)
tf3       = input.timeframe("", title="Timeframe", group=group3, tooltip="The execution chart timeframe anchor used to pull remote security data. Leave empty to mirror the current active chart state.") 

s11       = input.symbol("BINANCE:NEARUSDT", title="Coin 11", group=group3)
s12       = input.symbol("BINANCE:UNIUSDT",  title="Coin 12", group=group3)
s13       = input.symbol("BINANCE:LTCUSDT",  title="Coin 13", group=group3)
s14       = input.symbol("BINANCE:APTUSDT",  title="Coin 14", group=group3)
s15       = input.symbol("BINANCE:SUIUSDT",  title="Coin 15", group=group3)

group4    = "Asset Selection - Group D"
toggleD   = input.bool(true, title="Enable Group D Processing", group=group4)
tf4       = input.timeframe("", title="Timeframe", group=group4, tooltip="The execution chart timeframe anchor used to pull remote security data. Leave empty to mirror the current active chart state.") 

s16       = input.symbol("BINANCE:OPUSDT",   title="Coin 16", group=group4)
s17       = input.symbol("BINANCE:ARBUSDT",  title="Coin 17", group=group4)
s18       = input.symbol("BINANCE:PEPEUSDT", title="Coin 18", group=group4)
s19       = input.symbol("BINANCE:WIFUSDT",  title="Coin 19", group=group4)
s20       = input.symbol("BINANCE:BONKUSDT", title="Coin 20", group=group4)

// Initialize tickers list across all 4 groups conditionally based on toggle inputs
string[] tickers = array.new_string()

int totalGroupsActive = 0
if toggleA
    array.push(tickers, s01), array.push(tickers, s02), array.push(tickers, s03), array.push(tickers, s04), array.push(tickers, s05)
    totalGroupsActive += 1
if toggleB
    array.push(tickers, s06), array.push(tickers, s07), array.push(tickers, s08), array.push(tickers, s09), array.push(tickers, s10)
    totalGroupsActive += 1
if toggleC
    array.push(tickers, s11), array.push(tickers, s12), array.push(tickers, s13), array.push(tickers, s14), array.push(tickers, s15)
    totalGroupsActive += 1
if toggleD
    array.push(tickers, s16), array.push(tickers, s17), array.push(tickers, s18), array.push(tickers, s19), array.push(tickers, s20)
    totalGroupsActive += 1

// Persistent arrays to hold cleanup IDs
var label[] activeLabels = array.new_label()
var line[]  activeLines  = array.new_line()
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Calculate locally
stochRsi(lengthRsi) =>
    rsi = ta.rsi(close, lengthRsi)
    k = ta.sma(ta.stoch(rsi, rsi, rsi, 14), 3)
    k

float osc = switch typeOsc
    "RSI" => ta.rsi(close, length)
    "MFI" => ta.mfi(hlc3, length)
    "Stochastic" => stochRsi(length)

rsi = osc

// Helper to format bottom metrics strings cleanly
formatStatsOnly(float[] rsiArray) =>
    if array.size(rsiArray) > 0
        float avgVal = array.avg(rsiArray)
        float minVal = array.min(rsiArray)
        float maxVal = array.max(rsiArray)
        str.format("Avg: {0} | Min: {1} | Max: {2}", str.tostring(avgVal, "#.#"), str.tostring(minVal, "#.#"), str.tostring(maxVal, "#.#"))
    else
        ""

// Helper to clean up raw timeframe strings into readable formats (e.g., 60 -> 1h, 15 -> 15m)
formatTimeframe(string tf) =>
    string target = tf == "" ? timeframe.period : tf
    float num = str.tonumber(target)
    string result = target
    if not na(num)
        int mins = math.round(num)
        if mins < 60
            result := str.tostring(mins) + "m"
        else if mins % 60 == 0
            result := str.tostring(mins / 60) + "h"
        else
            result := str.tostring(mins) + "m"
    else
        if target == "D" or target == "1D"
            result := "1D"
        else if target == "W" or target == "1W"
            result := "1W"
        else if target == "M" or target == "1M"
            result := "1M"
    result

if barstate.islast
    // Clean up elements from previous frame
    if array.size(activeLabels) > 0
        for i = 0 to array.size(activeLabels) - 1
            label.delete(array.get(activeLabels, i))
        array.clear(activeLabels)
        
    if array.size(activeLines) > 0
        for i = 0 to array.size(activeLines) - 1
            line.delete(array.get(activeLines, i))
        array.clear(activeLines)

    int visualIndex = 0
    
    // Variables to track coordinates for drawing group dividers dynamically
    int startXGroupA = na, int endXGroupA = na
    int startXGroupB = na, int endXGroupB = na
    int startXGroupC = na, int endXGroupC = na
    int startXGroupD = na, int endXGroupD = na

    // Arrays to collect RSI values per group for dynamic stats calculation
    float[] rsiA = array.new_float()
    float[] rsiB = array.new_float()
    float[] rsiC = array.new_float()
    float[] rsiD = array.new_float()

    int totalItems = array.size(tickers)

    if totalItems > 0
        // Loop through our configured inputs
        for i = 0 to totalItems - 1
            string symbol = array.get(tickers, i)
            
            if symbol == ""
                continue

            string validSymbol = (symbol == "" or na(symbol)) ? syminfo.tickerid : symbol
            
            // Unify tracking variables
            float coinRSI = na
            float prevRSI = na
            float prevRSI1 = na
            
            // Dynamically fetch the correct timeframe and populate the right array
            if i < (toggleA ? 5 : 0)
                [c, p, p1] = request.security(validSymbol, tf1, [rsi, rsi[1], rsi[2]], ignore_invalid_symbol=true)
                coinRSI := c, prevRSI := p, prevRSI1 := p1
                if not na(coinRSI)
                    array.push(rsiA, coinRSI)

            else if i >= (toggleA ? 5 : 0) and i < ((toggleA ? 5 : 0) + (toggleB ? 5 : 0))
                [c, p, p1] = request.security(validSymbol, tf2, [rsi, rsi[1], rsi[2]], ignore_invalid_symbol=true)
                coinRSI := c, prevRSI := p, prevRSI1 := p1
                if not na(coinRSI)
                    array.push(rsiB, coinRSI)

            else if i >= ((toggleA ? 5 : 0) + (toggleB ? 5 : 0)) and i < ((toggleA ? 5 : 0) + (toggleB ? 5 : 0) + (toggleC ? 5 : 0))
                [c, p, p1] = request.security(validSymbol, tf3, [rsi, rsi[1], rsi[2]], ignore_invalid_symbol=true)
                coinRSI := c, prevRSI := p, prevRSI1 := p1
                if not na(coinRSI)
                    array.push(rsiC, coinRSI)

            else
                [c, p, p1] = request.security(validSymbol, tf4, [rsi, rsi[1], rsi[2]], ignore_invalid_symbol=true)
                coinRSI := c, prevRSI := p, prevRSI1 := p1
                if not na(coinRSI)
                    array.push(rsiD, coinRSI)

            if na(coinRSI) or na(prevRSI)
                continue

            // Process clean text name for visualization
            string cleanName = str.split(symbol, ":").last()
            cleanName := str.replace_all(cleanName, "MEXC:", "")
            cleanName := str.replace_all(cleanName, "BYBIT:", "")
            cleanName := str.replace_all(cleanName, "OKX:", "")
            cleanName := str.replace_all(cleanName, "USDT", "")
            cleanName := str.replace_all(cleanName, "USDC", "")

            // Dynamic 3-point color gradient function mapping for assets using theme inputs
            color dynamicCoinColor = colorMidYel
            if coinRSI >= 50.0
                dynamicCoinColor := color.from_gradient(coinRSI, 50.0, 75.0, colorMidYel, colorMaxRed)
            else
                dynamicCoinColor := color.from_gradient(coinRSI, 25.0, 50.0, colorMaxGrn, colorMidYel)

            // Check if this loop item is the asset currently loaded on the active chart pane
            bool isActiveChartAsset = str.contains(str.split(symbol, ":").last(), syminfo.ticker)
            if isActiveChartAsset
                dynamicCoinColor := colorActive

            // Stagger horizontal spacing utilizing only active counters
            int currentX = bar_index - (visualIndex * 2)
            int prevX    = (bar_index - 1) - (visualIndex * 2)

            // Capture horizontal screen placement bounds dynamically for labeling frameworks
            if toggleA and i < 5
                if na(startXGroupA) 
                    startXGroupA := currentX - 1
                endXGroupA := currentX - 1
            else if (toggleB and i >= (toggleA ? 5 : 0) and i < ((toggleA ? 5 : 0) + 5))
                if na(startXGroupB) 
                    startXGroupB := currentX - 1
                endXGroupB := currentX - 1
            else if (toggleC and i >= ((toggleA ? 5 : 0) + (toggleB ? 5 : 0)) and i < ((toggleA ? 5 : 0) + (toggleB ? 5 : 0) + 5))
                if na(startXGroupC) 
                    startXGroupC := currentX - 1
                endXGroupC := currentX - 1
            else if toggleD
                if na(startXGroupD) 
                    startXGroupD := currentX - 1
                endXGroupD := currentX - 1

            // 1. Create historical tracking dashed trendline
            line trendLine = line.new(
                  x1=prevX, 
                  y1=prevRSI, 
                  x2=currentX-1, 
                  y2=coinRSI, 
                  xloc=xloc.bar_index, 
                  color=color.new(dynamicCoinColor, 0), 
                  width=1, 
                  style=line.style_dashed
                  )

            line trendLine1 = line.new(
                  x1=prevX-1, 
                  y1=prevRSI1, 
                  x2=currentX-1, 
                  y2=prevRSI, 
                  xloc=xloc.bar_index, 
                  color=color.new(dynamicCoinColor, 0), width=1, 
                  style=line.style_dashed
                  )

            // 2. Create stylized dot marker
            label lblDot = label.new(
                  x=currentX-1, 
                  y=coinRSI, 
                  text="●" , 
                  color=color.new(color.black, 100), 
                  textcolor=dynamicCoinColor, 
                  style=label.style_label_center,
                  size=isActiveChartAsset ? size.huge : size.large
                  )
                  
            // 3. Create structural clean overlay text name
            label lblDot1 = label.new(
                  x=currentX-1, 
                  y=coinRSI, 
                  text=cleanName, 
                  color=color.new(color.black, 100), 
                  textcolor=chart.fg_color, 
                  style=label.style_circle,
                  size=size.small
                  )

            // Accumulate element processing IDs
            array.push(activeLabels, lblDot)
            array.push(activeLabels, lblDot1)
            array.push(activeLines, trendLine)
            array.push(activeLines, trendLine1)
            
            // Advance visual formatting spacing anchor points
            visualIndex += 1

    // ---------------------------------------------------------------- Global Seamless Divider Draw
    if totalGroupsActive > 1
        int overallStart = bar_index
        int overallEnd   = bar_index - ((totalItems - 1) * 2) - 2
        float segmentSize = (overallStart - overallEnd) / totalGroupsActive
        
        for idx = 1 to totalGroupsActive - 1
            int divX = math.round(overallStart - (idx * segmentSize))
            line divLine = line.new(x1=divX, y1=0, x2=divX, y2=100, xloc=xloc.bar_index, color=color.new(chart.fg_color, 80), width=1, style=line.style_solid)
            array.push(activeLines, divLine)

    // ---------------------------------------------------------------- Draw Bounded Group Metrics & Options
    // Render Group A
    if toggleA and not na(startXGroupA) and not na(endXGroupA) and array.size(rsiA) > 0
        float avgA = array.avg(rsiA)
        if showAvgLns
            line avgLineA = line.new(x1=startXGroupA, y1=avgA, x2=endXGroupA, y2=avgA, xloc=xloc.bar_index, color=chart.fg_color, width=1, style=line.style_dashed)
            array.push(activeLines, avgLineA)
        
        int midA = math.round((startXGroupA + endXGroupA) / 2)
        // Top Group Heading
        string displayTfA = formatTimeframe(tf1)
        label lblGroupA = label.new(x=midA, y=96, text="GROUP A (" + displayTfA + ")", color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.normal)
        array.push(activeLabels, lblGroupA)
        // Bottom Statistics Info
        string statsA = formatStatsOnly(rsiA)
        label lblStatsA = label.new(x=midA, y=4, text=statsA, color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.small)
        array.push(activeLabels, lblStatsA)

    // Render Group B
    if toggleB and not na(startXGroupB) and not na(endXGroupB) and array.size(rsiB) > 0
        float avgB = array.avg(rsiB)
        if showAvgLns
            line avgLineB = line.new(x1=startXGroupB, y1=avgB, x2=endXGroupB, y2=avgB, xloc=xloc.bar_index, color=chart.fg_color, width=1, style=line.style_dashed)
            array.push(activeLines, avgLineB)


        int midB = math.round((startXGroupB + endXGroupB) / 2)
        // Top Group Heading
        string displayTfB = formatTimeframe(tf2)
        label lblGroupB = label.new(x=midB, y=96, text="GROUP B (" + displayTfB + ")", color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.normal)
        array.push(activeLabels, lblGroupB)
        // Bottom Statistics Info
        string statsB = formatStatsOnly(rsiB)
        label lblStatsB = label.new(x=midB, y=4, text=statsB, color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.small)
        array.push(activeLabels, lblStatsB)

    // Render Group C
    if toggleC and not na(startXGroupC) and not na(endXGroupC) and array.size(rsiC) > 0
        float avgC = array.avg(rsiC)
        if showAvgLns
            line avgLineC = line.new(x1=startXGroupC, y1=avgC, x2=endXGroupC, y2=avgC, xloc=xloc.bar_index, color=chart.fg_color, width=1, style=line.style_dashed)
            array.push(activeLines, avgLineC)


        int midC = math.round((startXGroupC + endXGroupC) / 2)
        // Top Group Heading
        string displayTfC = formatTimeframe(tf3)
        label lblGroupC = label.new(x=midC, y=96, text="GROUP C (" + displayTfC + ")", color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.normal)
        array.push(activeLabels, lblGroupC)
        // Bottom Statistics Info
        string statsC = formatStatsOnly(rsiC)
        label lblStatsC = label.new(x=midC, y=4, text=statsC, color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.small)
        array.push(activeLabels, lblStatsC)

    // Render Group D
    if toggleD and not na(startXGroupD) and not na(endXGroupD) and array.size(rsiD) > 0
        float avgD = array.avg(rsiD)
        if showAvgLns
            line avgLineD = line.new(x1=startXGroupD, y1=avgD, x2=endXGroupD, y2=avgD, xloc=xloc.bar_index, color=chart.fg_color, width=1, style=line.style_dashed)
            array.push(activeLines, avgLineD)

        int midD = math.round((startXGroupD + endXGroupD) / 2)
        // Top Group Heading
        string displayTfD = formatTimeframe(tf4)
        label lblGroupD = label.new(x=midD, y=96, text="GROUP D (" + displayTfD + ")", color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.normal)
        array.push(activeLabels, lblGroupD)
        // Bottom Statistics Info
        string statsD = formatStatsOnly(rsiD)
        label lblStatsD = label.new(x=midD, y=4, text=statsD, color=color.new(color.black, 100), textcolor=chart.fg_color, style=label.style_label_center, size=size.small)
        array.push(activeLabels, lblStatsD)
// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
h100 = plot(100,  "Overbought Line 2", color=color.new(colorMaxRed, 50), display=display.none, show_last = 42)
h70  = plot(70,  "Overbought Line 1", color=color.new(colorMaxRed, 50), linestyle = plot.linestyle_dashed, display=display.none, show_last = 42)
h50  = plot(50,  "Neutral Line",    color=color.new(colorMidYel, 60), linestyle = plot.linestyle_dashed, show_last = 42)
h30  = plot(30,  "Oversold Line 1",   color=color.new(colorMaxGrn, 50), linestyle = plot.linestyle_dashed, display=display.none, show_last = 42)
h0   = plot(0,  "Oversold Line 2",   color=color.new(colorMaxGrn, 50),   display=display.none, show_last = 42)


allow = last_bar_index-bar_index > 40
fill(h100, h70, 100, 50, color.new(colorMaxRed, allow ? 100 : 60), color.new(colorMidYel, 100))
fill(h0, h30, 50, 0, color.new(colorMidYel, 100), color.new(colorMaxGrn, allow ? 100 : 60))

// Main underlying line rendering handler controlled via user showMain dynamic input parameter
plot(rsi, "Oscilator", color = showMain ? color.new(chart.fg_color, 100) : color.new(chart.fg_color, 80), show_last = 42)
// }
````
