# Auto-ATR Volatility Spike & Trend Tracker [BigBeluga]

- url: https://www.tradingview.com/script/KTsZMbtk-Auto-ATR-Volatility-Spike-Trend-Tracker-BigBeluga/
- type: indicator
- pine_id: PUB;72ef1165d581401ba6adee4a1a8ccdb8
- version: 1.0

## Description

[b]Auto-ATR Volatility Spike & Trend Tracker [BigBeluga][/b] is an institutional-grade algorithmic trend-following terminal engineered for TradingView. It is specifically built to isolate high-momentum breakout anomalies (spikes) from ordinary noise and anchor a dynamic, risk-managed trailing stop-loss directly to the underlying structural expansion.

By merging volumetric price momentum with an adaptive Average True Range (ATR) detection framework, this indicator completely redefines how breakout traders enter and manage trends. Instead of reacting blindly to standard moving average crosses, the system utilizes an execution state machine that locks onto systemic market expansion, tracks trend health via dynamic midpoint lines, and protects capital with a trailing protection line.

[b]🔵 CHANNELS & ARCHITECTURAL CORE ENGINE FEATURES[/b]

[b]1. Dual-Mode Spike Detection System[/b]
[list]
[*] [b]Auto ATR Volatility Engine:[/b] Automatically adapts to varying market conditions. By cross-referencing incoming candle structures against an [b]ATR Length[/b] multiplier baseline, the indicator filters out flat consolidation periods and flags abnormal, high-liquidity volume expansions that signify true institutional participant footprints.
[*] [b]Fixed Percentage Breakout Mode:[/b] For traders operating in highly structured assets with predictable daily limits, this module locks onto absolute price change thresholds ([b]Fixed Spike Threshold %[/b]), isolating momentum moves that pierce predefined parameters.
[image]https://www.tradingview.com/x/RMVNHTc7/[/image]
[*] [b]Wick-to-Body Range Toggle:[/b] Allows you to switch calculations to run from either the raw candle body (Open to Close) or the full extreme range ([b]Calculate From Wicks (High/Low)[/b]). This isolates clean structural closes while adjusting to high-volatility liquidity sweeps.
[/list]

[b]2. Predictive Mid-Level Benchmarks & Spacing Visuals[/b]
[list]
[*] [b]Dynamic Mid Level Dash Lines:[/b] When a valid trend spike is verified, the engine immediately draws a horizontal midpoint line extending from the center of the candle ([b]Display Mid Level Dash Line[/b]). This centerline serves as an immediate structural macro floor or ceiling; as long as price retains this boundary, the primary breakout impulse remains historically intact.
[image]https://www.tradingview.com/x/u4f8cCpj/[/image]
[*] [b]Measurement Arrow Guides & Measurement Labels:[/b] Automatically draws measurement arrow guides along with real-time text percentage indicators directly over the breakout candle ([b]Display Size % Labels & Arrow Lines[/b]). This gives you instant clarity on the volatility profile without needing to use manual drawing tools.
[image]https://www.tradingview.com/x/pbUqZ01t/[/image]
[/list]

[b]3. Algorithmic State Machine & Trailing Protection[/b]
[list]
[*] [b]Volatility-Adjusted Trailing Stops:[/b] Once a breakout trend is established, the indicator deploys a step-calculated trailing line based on your [b]Trailing ATR Multiplier[/b]. This line is engineered to trail tightly beneath bullish expansions or above bearish flushes, keeping you safely in the macro trend while mitigating downside variance.
[image]https://www.tradingview.com/x/EOUs49eO/[/image]
[*] [b]Trend Interlock Protection:[/b] The underlying state machine features built-in trigger restrictions that lock execution while a trend is dominant. This prevents counter-trend false entries or premature reversals, keeping your focus strictly on the dominant structural path.
[*] [b]Theme Overwrite Candlesticks:[/b] Completely recolors the active layout chart workspace bars using vivid, customized hex-theme presets ([b]Bullish/Bearish Theme Colors[/b]) the exact moment an abnormal spike is validated.
[image]https://www.tradingview.com/x/BjR4kUwa/[/image]
[/list]

[b]4. Persistent Macro Statistics Dashboard Matrix[/b]
[list]
[*] [b]Top-Right Analytics HUD Table:[/b] Instantly maps out a high-performance database grid showing critical data points from the most recent historical market expansions.
[image]https://www.tradingview.com/x/M99Xx9P4/[/image]
[*] [b]Real-Time Metrics Monitoring:[/b] Explicitly stores and displays the precise directional [b]Spike Type[/b], [b]Size (%)[/b], and exact entry execution [b]Price[/b] for both bullish and bearish cycles, providing a reliable quantitative snapshot of the asset's structural strength.
[/list]

[b]🔵 SYSTEMATIC EXECUTION STRATEGIES & RISK INTERPRETATION[/b]

[list]
[*] [b]Midpoint Re-test Accumulation Plays:[/b] When a powerful up-spike forces a market breakout, do not chase the initial overextended move. Instead, wait for a constructive pullback toward the extended dynamic dashed midline. If price builds a base and prints a clean rejection candle at this level, it signals a premium, low-risk continuation entry aligned with institutional order flow.
[*] [b]Trailing ATR Invalidation Exits:[/b] The trailing stop-loss line acts as your absolute trend line invalidation boundary. In a powerful bullish expansion, the indicator will continuously trail and lock in accrued profit beneath the recent low points. A clean daily close crossing beneath this line confirms an official trend termination, signaling an immediate exit to protect your capital.
[*] [b]Breakout Sizing Divergences:[/b] Cross-reference the live metrics dashboard data to spot exhausting trends. If an asset is pressing higher but newly generated bullish spikes show smaller percentage sizes compared to the historical records on your HUD table, it exposes fading momentum—frequently warning of an impending reversal or structural distribution phase.
[/list]

[b]🔵 INTERFACE CONFIGURATION AND PARAMETERS[/b]

[list]
[*] [b]Detection Mode Controls:[/b] Choose between [b]Auto ATR[/b] or [b]Fixed %[/b] settings and specify lookback periods to customize the indicator to match any asset class, volatility cycle, or execution chart timeframe.
[*] [b]Visibility Filters Overrides:[/b] Independently toggle midlines, trailing stops, background cloud color fills, or measurement labels to maintain a clean, distraction-free charting interface.
[*] [b]Theme Personalization Modifiers:[/b] Fully adjust color properties for upward spikes, downward spikes, buy/sell arrows, and trailing lines to blend seamlessly into your dark or light workspace layout themes.
[/list]

Transform your charting workspace from speculative guessing into an automated, volatility-tracked breakout environment with the [b]Auto-ATR Volatility Spike & Trend Tracker[/b] terminal.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Auto-ATR Volatility Spike & Trend Tracker [BigBeluga]", overlay=true, max_lines_count = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

modeInput       = input.string("Auto ATR", title="Detection Mode", options=["Fixed %", "Auto ATR"], inline = "1", tooltip="Choose how spikes are calculated. 'Fixed %' uses a hard percentage move. 'Auto ATR' dynamically calculates spikes based on recent market volatility.")
useWicksInput   = input.bool(false, title="Calculate From Wicks (High/Low)", tooltip="If enabled, spike detection and percentage changes are calculated using the full candle range (High to Low). If disabled, only the candle body (Open to Close) is used.")
thresholdInput  = input.float(1.0, title="Fixed Spike Threshold (%)", minval=0.1, step=0.01, active = modeInput == "Fixed %", tooltip="The minimum percentage price change required to trigger a spike when using 'Fixed %' mode.") 
atrMultInput    = input.float(2.0, title="ATR Multiplier", minval=0.1, step=0.1, active = modeInput == "Auto ATR", tooltip="Multiplier applied to the ATR to determine if a candle's total range qualifies as an abnormal spike.")

atrLengthInput  = input.int(14, title="ATR Length (for Auto-Detection & Trailing)", minval=1, tooltip="The lookback period used to calculate the Average True Range (ATR) for volatility detection and trailing stop distances.")
atrMultInput1   = input.float(3.0, title="Trailing ATR Multiplier", minval=0.5, step=0.1, tooltip="Determines how many ATRs away from the price your trailing stop-loss line will sit.")

// Visibility Toggles
showMidLine     = input.bool(true, title="Display Mid Level Dash Line", group="Visibility Settings", tooltip="Toggle to show or hide the horizontal dashed midline extending from the spike center.")
showTrail       = input.bool(true, title="Display Trailing Stop & Fill", group="Visibility Settings", tooltip="Toggle to show or hide the trailing stop line and its background area color fill.")
showSize        = input.bool(true, title="Display Size % Labels & Arrow Lines", group="Visibility Settings", tooltip="Toggle to show or hide the percentage text labels along with their surrounding indicator arrow lines.")

// Color Customization
bullColorInput  = input.color(color.rgb(245, 171, 12), title="Bullish Theme Color", tooltip="Color used for upward spikes, buy arrows, positive percentage text, and uptrend tracking elements.")
bearColorInput  = input.color(color.rgb(20, 166, 250), title="Bearish Theme Color", tooltip="Color used for downward spikes, sell arrows, negative percentage text, and downtrend tracking elements.")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Math tracking properties depending on wick toggle selection
priceChange = useWicksInput ? (((high - low) / low) * 100) : (((close - open) / open) * 100)
atr         = ta.atr(atrLengthInput)
candleRange = useWicksInput ? (high - low) : (math.max(close, open) - math.min(close, open))

// State persistence variables 
var int trendState = 0 
var float trailStop = na

// Spike determination profiles
isBigCandleUp   = modeInput == "Fixed %" ? (priceChange >= thresholdInput and close > open) : (candleRange > (atr * atrMultInput) and close > open)
isBigCandleDown = modeInput == "Fixed %" ? (useWicksInput ? (priceChange >= thresholdInput and close < open) : (priceChange <= -thresholdInput)) : (candleRange > (atr * atrMultInput) and close < open)

// Trigger restrictions (Locks execution while a trend state is currently dominant)
upSpike   = isBigCandleUp and trendState != 1
downSpike = isBigCandleDown and trendState != -1

// Dashboard history variable persistence
var int lastBullBar = na
var float lastBullSize = na
var float lastBullPrice = na

var int lastBearBar = na
var float lastBearSize = na
var float lastBearPrice = na

if upSpike
    lastBullBar   := bar_index
    lastBullSize  := priceChange
    lastBullPrice := close

if downSpike
    lastBearBar   := bar_index
    lastBearSize  := useWicksInput ? -priceChange : priceChange
    lastBearPrice := close

// Execution & System Tracking State Machine
if upSpike and trendState <= 0
    trendState := 1
    trailStop  := low - atr * atrMultInput1

if downSpike and trendState >= 0
    trendState := -1
    trailStop  := high + atr * atrMultInput1

if trendState == 1
    trailStop := math.max(trailStop, low - atr * atrMultInput1)
    if close < trailStop
        trendState := 0
        trailStop  := na

else if trendState == -1
    trailStop := math.min(trailStop, high + atr * atrMultInput1)
    if close > trailStop
        trendState := 0
        trailStop  := na

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Coordinate tracking variables for anchoring structural box extensions
y_top    = useWicksInput ? high : math.max(open, close)
y_bottom = useWicksInput ? low  : math.min(open, close)

var line Level = na

// Graphical Engine Pass: Upward Spikes
if upSpike 
    if showMidLine
        Level := line.new(bar_index, math.avg(close, open), bar_index, math.avg(close, open), style = line.style_dashed, color = bullColorInput)
    
    if showSize
        line.new(bar_index-1, y_top, bar_index-1, y_bottom, color=chart.fg_color, style = line.style_arrow_both)
        line.new(bar_index-1, y_top, bar_index, y_top, color=chart.fg_color, style = line.style_dashed)
        line.new(bar_index-1, y_bottom, bar_index, y_bottom, color=chart.fg_color, style = line.style_dashed)
        label.new(bar_index-1, hl2, text=str.tostring(priceChange, "+#.##") + "%", color=color.new(bullColorInput, 100), textcolor=chart.fg_color, style=label.style_label_right)
    
    txt = "▲\n△"
    label.new(bar_index, low - atr, text=txt, color=color.new(bullColorInput, 100), textcolor=bullColorInput, style=label.style_label_center, size=size.normal)

// Graphical Engine Pass: Downward Spikes
if downSpike
    if showMidLine
        Level := line.new(bar_index, math.avg(close, open), bar_index, math.avg(close, open), style = line.style_dashed, color = bearColorInput)

    if showSize
        line.new(bar_index-1, y_top, bar_index-1, y_bottom, color=chart.fg_color, style = line.style_arrow_both)    
        line.new(bar_index-1, y_top, bar_index, y_top, color=chart.fg_color, style = line.style_dashed)
        line.new(bar_index-1, y_bottom, bar_index, y_bottom, color=chart.fg_color, style = line.style_dashed)
        label.new(bar_index-1, hl2, text=str.tostring(useWicksInput ? -priceChange : priceChange, "#.##") + "%", color=color.new(bearColorInput, 100), textcolor=chart.fg_color, style=label.style_label_right)
    
    txt = "▽\n▼"
    label.new(bar_index, high+atr, text=txt, color=color.new(bearColorInput, 100), textcolor=bearColorInput, style=label.style_label_center, size=size.normal)

// Dynamic lengthening calculation for midline
if trendState != 0 and showMidLine
    Level.set_x2(bar_index)

// Trailing Protection Lines & Dynamic Colored Fills
p_trail = plot(showTrail and trendState == trendState[1] ? trailStop : float(na), title="Trailing Stop", color=trendState == 1 ? bullColorInput : trendState == -1 ? bearColorInput : color.new(color.white, 100), style=plot.style_linebr, linewidth=2)
p_price = plot(showTrail and trendState != 0 ? close : na, title="Price Reference for Fill", color=color.new(color.white, 100))

fillColor = showTrail and trendState == 1 ? color.new(bullColorInput, 80) : showTrail and trendState == -1 ? color.new(bearColorInput, 80) : color.new(color.white, 100)
fill(p_trail, p_price, close, trailStop, color(na), fillColor)

// Primary Custom Candle Color Overwrites
candleCol = isBigCandleUp ? bullColorInput : isBigCandleDown ? bearColorInput : color(na)
plotcandle(open, high, low, close, title='Theme Overwrite Candles', color = candleCol, wickcolor=candleCol, bordercolor = candleCol)
barcolor(candleCol)

// Metrics Display Table Element Generation
var table debugTable = table.new(position.top_right, 4, 3, bgcolor=color.new(color.black, 30), border_color=chart.bg_color, border_width=3)

if barstate.islast
    bullShift = bar_index - lastBullBar
    bearShift = bar_index - lastBearBar

    table.cell(debugTable, 0, 0, "Spike Type", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.gray, 50))
    table.cell(debugTable, 2, 0, "Size (%)",   text_color=color.white, text_size=size.normal, bgcolor=color.new(color.gray, 50))
    table.cell(debugTable, 3, 0, "Price",      text_color=color.white, text_size=size.normal, bgcolor=color.new(color.gray, 50))

    table.cell(debugTable, 0, 1, "Last Bullish", text_color=bullColorInput, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(debugTable, 2, 1, na(lastBullSize) ? "-" : str.tostring(lastBullSize, "+#.##") + "%", text_color=bullColorInput, text_size=size.normal)
    table.cell(debugTable, 3, 1, na(lastBullPrice) ? "-" : str.tostring(lastBullPrice, "#.##"), text_color=color.white, text_size=size.normal)

    table.cell(debugTable, 0, 2, "Last Bearish", text_color=bearColorInput, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(debugTable, 2, 2, na(lastBearSize) ? "-" : str.tostring(lastBearSize, "#.##") + "%", text_color=bearColorInput, text_size=size.normal)
    table.cell(debugTable, 3, 2, na(lastBearPrice) ? "-" : str.tostring(lastBearPrice, "#.##"), text_color=color.white, text_size=size.normal)

// }
````
