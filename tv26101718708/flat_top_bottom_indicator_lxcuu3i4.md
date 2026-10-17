# Flat Top & Bottom Indicator

- url: https://www.tradingview.com/script/LxCUU3i4-Flat-Top-Bottom-Indicator/
- type: indicator
- pine_id: PUB;19002f23fbaa48fcba2b11325faed99a
- version: 2.0

## Description

Flat Top & Bottom Indicator

Flat Top & Bottom Indicator is an open-source market-structure tool for identifying repeated structural highs and lows on a chart.

The script is designed to help traders see price areas where the market has previously formed a flat high or flat low and later returned to the same level. These areas may be useful as visual reference points for studying resistance, support, range behavior, breakouts, retests, or failed continuation.

This indicator does not predict future price movement and does not generate automatic buy or sell recommendations. It is intended as a charting and educational tool for traders who want to study repeated price structures more clearly.

How it works

The script searches back over a user-defined lookback period to find cases where the current high or low matches a previous structural high or structural low.

For a potential flat top, the script checks whether:

the current bar is forming a local high based on the selected pivot strength,
the current high matches a previous high within the lookback period,
the previous high was also a local structural high,
price did not create a higher or equal high between the two points,
and the current candle closes below its open.

For a potential flat bottom, the script checks whether:

the current bar is forming a local low based on the selected pivot strength,
the current low matches a previous low within the lookback period,
the previous low was also a local structural low,
price did not create a lower or equal low between the two points,
and the current candle closes above its open.

When these conditions are met, the indicator draws a horizontal line between the earlier structural point and the current bar. The label “SF Top” marks a structural flat top, and “SF Bottom” marks a structural flat bottom.

Inputs

Lookback Period controls how many historical bars the script searches for a matching structural high or low.

Pivot Strength controls how selective the script is when identifying local highs and lows. Higher values generally filter for more significant structures, while lower values may detect more frequent levels.

Flat Top Line Color and Flat Bottom Line Color allow users to customize the chart display.

Early Bird Mode controls whether the script can mark a structure during the current realtime bar or only after the bar is confirmed.

When Early Bird Mode is disabled, the script waits for the bar to close before plotting confirmed structures. When Early Bird Mode is enabled, the script can plot during the realtime bar as soon as the conditions are met. Realtime markings may update before the bar closes.

Alerts and data-window outputs

The script includes alert conditions for structural flat tops and structural flat bottoms.

It also plots hidden numeric signal outputs in the data window:

SF Top Signal: 1 when a structural flat top is detected, otherwise 0.
SF Bottom Signal: 1 when a structural flat bottom is detected, otherwise 0.

These outputs may be useful for alerts, review, or manual export.

How to use it

This indicator is best used as a visual market-structure aid. Traders can use the marked levels to observe how price behaves when it returns to a previously established high or low.

For example, traders may watch whether price rejects the level, breaks through it, retests it, or moves back into the prior range. The marked levels should be interpreted as context, not as standalone trade signals.

Users should combine this tool with their own market analysis, risk management, timeframe selection, and confirmation process.

Limitations

The indicator identifies historical structural relationships. A marked flat top or flat bottom does not guarantee that price will reverse, break out, or react in a predictable way.

Because the script requires repeated price structures, some signals may appear only after price has already interacted with a level. In fast-moving trends, low-liquidity markets, or highly volatile conditions, some levels may be less useful.

When Early Bird Mode is enabled, realtime markings can appear before the bar closes and may change as the bar develops. Users who prefer confirmed signals should keep Early Bird Mode disabled.

This script is open-source so users can inspect the logic, learn from it, and adapt it for their own educational use.

## Source Code

````pine
//@version=6
// Flat Top & Bottom Indicator v3 TREESinvest
indicator("Flat Top & Bottom Indicator v3 TREESinvest", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs & Settings ---
lookbackPeriod   = input.int(60, "Lookback Period", minval=10, maxval=500, tooltip="Number of historical bars to search for a matching price")
pivotWindow      = input.int(5, "Regular Pivot Strength", minval=1, maxval=20, tooltip="Higher values filter for more significant peaks/troughs for TOP/BTM")
lineColorTop     = input.color(color.red, "Flat Top Line Color")
lineColorBottom  = input.color(color.green, "Flat Bottom Line Color")

// --- Tilt Mode Feature Settings ---
enableTilt       = input.bool(false, "Enable Tilt Mode", tooltip="TRUE: 开启倾斜模式（独立Pivot控制，严格互斥不重叠）")
pivotWindowTilt  = input.int(5, "Tilt Pivot Strength", minval=1, maxval=20, tooltip="倾斜模式专用的轴点强度参数")

// --- Early Bird Mode Feature ---
enableEarlyBird  = input.bool(false, "Early Bird Mode", tooltip="TRUE: Plots shapes/lines mid-bar as soon as conditions are met (Stable Realtime).\nFALSE: Only plots after the bar officially closes (Confirmed).")

// --- Logical Processing ---

// --- 基础模式的全局 Series 计算 ---
highestLevelSeries = ta.highest(high, pivotWindow)
lowestLevelSeries  = ta.lowest(low, pivotWindow)
isStageHigh        = high == highestLevelSeries
isStageLow         = low == lowestLevelSeries

// --- Tilt 模式的全局 Series 计算 ---
highestLevelSeriesTilt = ta.highest(high, pivotWindowTilt)
lowestLevelSeriesTilt  = ta.lowest(low, pivotWindowTilt)
isStageHighTilt        = high == highestLevelSeriesTilt
isStageLowTilt         = low == lowestLevelSeriesTilt

// Initialize signal variables for Alerts and CSV Export (0 = No Signal, 1 = Signal Triggered)
int sfTopSignal    = 0
int sfBottomSignal = 0

// Persistent tracking variables to manage the drawing references on the CURRENT bar
var line  currentBarLineTop     = na
var label currentBarLabelTop    = na
var line  currentBarLineBottom  = na
var label currentBarLabelBottom = na

// Tracking the bar index of the last drawn signal to safely detect drawing on the same bar
var int lastSignalBarTop    = na
var int lastSignalBarBottom = na

// --- Core Execution Gate ---
if enableEarlyBird or barstate.isconfirmed

    // --- Top Search Logic (TOP & Tilt Top) ---
    if close < open
        float currentLevel = high
        for i = 1 to lookbackPeriod
            // 1. 标准平顶条件：当前等于历史，且历史符合标准 Pivot
            bool isRegularTop = isStageHigh and (currentLevel == high[i]) and (high[i] == highestLevelSeries[i])
            
            // 2. Tilt 顶条件：开启 Tilt、当前严格小于历史且差距<=0.25、当前与历史均符合 Tilt Pivot
            bool isTiltTop    = enableTilt and isStageHighTilt and (currentLevel >= high[i] - 0.25 and currentLevel < high[i]) and (high[i] == highestLevelSeriesTilt[i])
            
            if isRegularTop or isTiltTop
                // 路径检测：确保中间没有高点阻挡
                bool isPathClear = true
                if i > 1
                    for k = 1 to i - 1
                        if high[k] >= currentLevel 
                            isPathClear := false
                            break
                
                if isPathClear
                    // 动态清理实时未收线棒上的旧图形
                    if barstate.isrealtime and lastSignalBarTop == bar_index
                        line.delete(currentBarLineTop)
                        label.delete(currentBarLabelTop)
                    
                    // 确定线段颜色与标签文本
                    color currentLineColor = isTiltTop ? lineColorTop : lineColorTop
                    string labelTxt        = isTiltTop ? (barstate.isrealtime ? "Tilt (EB)*" : "Tilt") : (barstate.isrealtime ? "TOP (EB)*" : "TOP")
                    color currentTxtColor  = isTiltTop ? color.white : lineColorTop
                    
                    // 绘图
                    line  _l   = line.new(x1=bar_index[i], y1=high[i], x2=bar_index, y2=high, color=currentLineColor, width=2)
                    label _lbl = label.new(bar_index, high, labelTxt, style=label.style_none, textcolor=currentTxtColor, yloc=yloc.abovebar)
                    
                    // 更新持久追踪变量
                    currentBarLineTop  := _l
                    currentBarLabelTop := _lbl
                    lastSignalBarTop   := bar_index
                    
                    sfTopSignal := 1
                    break // 锁定最近的有效信号，直接跳出循环避免多重绘制

    // --- Bottom Search Logic (BTM & Tilt Bottom) ---
    if close > open
        float currentLevel = low
        for j = 1 to lookbackPeriod
            // 1. 标准平底条件：当前等于历史，且历史符合标准 Pivot
            bool isRegularBtm = isStageLow and (currentLevel == low[j]) and (low[j] == lowestLevelSeries[j])
            
            // 2. Tilt 底条件：开启 Tilt、当前严格大于历史且差距<=0.25、当前与历史均符合 Tilt Pivot
            bool isTiltBtm    = enableTilt and isStageLowTilt and (currentLevel > low[j] and currentLevel <= low[j] + 0.25) and (low[j] == lowestLevelSeriesTilt[j])
            
            if isRegularBtm or isTiltBtm
                // 路径检测：确保中间没有低点阻挡
                bool isPathClear = true
                if j > 1
                    for k = 1 to j - 1
                        if low[k] <= currentLevel 
                            isPathClear := false
                            break
                
                if isPathClear
                    // 动态清理实时未收线棒上的旧图形
                    if barstate.isrealtime and lastSignalBarBottom == bar_index
                        line.delete(currentBarLineBottom)
                        label.delete(currentBarLabelBottom)
                    
                    // 确定线段颜色与标签文本
                    color currentLineColor = isTiltBtm ? lineColorBottom : lineColorBottom
                    string labelTxt        = isTiltBtm ? (barstate.isrealtime ? "Tilt (EB)*" : "Tilt") : (barstate.isrealtime ? "BTM (EB)*" : "BTM")
                    color currentTxtColor  = isTiltBtm ? color.white : lineColorBottom
                    
                    // 绘图
                    line  _l   = line.new(x1=bar_index[j], y1=low[j], x2=bar_index, y2=low, color=currentLineColor, width=2)
                    label _lbl = label.new(bar_index, low, labelTxt, style=label.style_none, textcolor=currentTxtColor, yloc=yloc.belowbar)
                    
                    // 更新持久追踪变量
                    currentBarLineBottom  := _l
                    currentBarLabelBottom := _lbl
                    lastSignalBarBottom   := bar_index
                    
                    sfBottomSignal := 1
                    break // 锁定最近的有效信号，直接跳出循环避免多重绘制

// --- CSV Export Outputs ---
plot(sfTopSignal, title="TOP Signal", color=color.new(color.red, 100), display=display.data_window)
plot(sfBottomSignal, title="BTM Signal", color=color.new(color.green, 100), display=display.data_window)

// --- Alert Conditions ---
alertcondition(sfTopSignal == 1, title="TOP Alert", message="Structural TOP/Tilt detected at {{close}}")
alertcondition(sfBottomSignal == 1, title="BTM Alert", message="Structural BTM/Tilt detected at {{close}}")
````
