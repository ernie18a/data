# Dynamic MSS Navigator [MarkitTick]

- url: https://www.tradingview.com/script/rmX3chaV-Dynamic-MSS-Navigator-MarkitTick/
- type: indicator
- pine_id: PUB;edc78fea750142938a6140310ab1574a
- version: 3.0

## Description

💡 An advanced technical analysis tool engineered to automatically identify localized market structure, validate structural shifts, and dynamically generate risk-to-reward parameters. Built for systematic traders, it continuously scans price action to pinpoint candidate highs and lows based on user-defined lookback periods. Rather than relying on subjective charting, this indicator applies stringent mathematical logic—incorporating Average True Range (ATR) buffers, volume participation, and higher timeframe (HTF) alignment—to filter out market noise and present high-probability structural breaks. Once a valid break occurs, the indicator seamlessly transitions into trade management mode, drawing precise entry, stop-loss, and multiple take-profit levels directly onto the chart, accompanied by a comprehensive real-time data dashboard.

[b]✨ Originality and Utility[/b]

[b]● Automated Market Structure Mapping[/b]
The core utility of this indicator lies in its ability to remove human bias from market structure analysis. Traders often struggle with defining which highs and lows are structurally significant. This script mathematically defines them, tracking the absolute highest highs and lowest lows over a rolling window, and only recognizing a structural shift when a mathematically validated threshold is breached.

[b]● Dynamic Risk-to-Reward Modeling[/b]
Unlike standard indicators that only print buy or sell arrows, this tool instantly calculates the exact risk parameter upon signal generation. By anchoring the stop-loss to the structural pivot with a built-in volatility buffer, it sizes the risk logically. It then extrapolates multiple take-profit targets based on fixed risk-to-reward ratios, providing a complete trade framework from inception to completion.

[b]● Multi-Dimensional Filtering Mashup[/b]
This script operates as a highly cohesive mashup of distinct technical methodologies. It combines Donchian-style localized pivot detection for structure, Wilder’s Average True Range for volatility-based breakout validation, Simple Moving Averages of volume for participation measurement, and multi-timeframe security requests for overarching trend alignment. This combination ensures that a signal is only fired when price action, volatility, volume, and higher timeframe momentum are in total agreement.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/iaHcUxPk/[/image]
[b]● Localized Pivot Identification[/b]
The script continuously monitors the highest highs and lowest lows over a defined lookback period. When a new top is formed, it identifies the lowest point of that peak structure as the "Candidate Top Low." Conversely, when a new bottom forms, it marks the highest point of that valley structure as the "Candidate Bottom High." These form the immediate structural floors and ceilings.

[b]● ATR-Buffered Breakout Logic[/b]
To confirm a shift, price must do more than just tick past the candidate line. The indicator requires price to breach the candidate level by an additional margin, calculated as a fraction of the current ATR. This ensures that only shifts with statistically significant momentum trigger a signal, heavily reducing false positives (fake-outs) during low-volatility chop.

[b]● Composite Strength Scoring[/b]
Upon signal generation, the algorithm calculates a proprietary "Strength Score" from 0 to 100. This score is a weighted aggregate of three factors:
[list]
[*]The distance of the closing price beyond the breakout threshold (measuring immediate momentum).
[*]The current volume relative to its moving average (measuring market participation).
[*]The alignment of the localized pivot with the higher timeframe pivot (measuring macro confluence).
[/list]

[b]● Dynamic Bias Tracking[/b]
The indicator tracks the ongoing market bias, classifying it as bullish, bearish, or neutral. A bullish bias is initiated upon a valid bottom break and remains intact until price breaches the newly established stop-loss level, at which point the bias flips or neutralizing protocols take over.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/mgDxmEl1/[/image]
[b]● Chart Elements[/b]

[b]• Candidate Lines[/b]
Dashed Red Lines indicate the support floor of a localized top. Dashed Green Lines indicate the resistance ceiling of a localized bottom. These project forward to show the exact price level that must be broken.

[b]• Signal Markers[/b]
When a structural shift is validated, a solid Red Triangle appears above the bar for a bearish shift (labeled "BEAR"), and a solid Green Triangle appears below the bar for a bullish shift (labeled "BULL"). Small "+" cross icons appear for continuation signals where the trend is reinforced.

[b]• Trade Projection Lines[/b]
A solid Red Line marks the calculated Stop Loss level. A dashed Blue Line marks the exact Entry Price. Dashed Teal Lines of varying opacities mark Take Profit 1 (TP1), Take Profit 2 (TP2), and Take Profit 3 (TP3). 

[b]• Zonal Fills[/b]
A semi-transparent Red Background fill connects the Entry line to the Stop Loss line, visually representing the initial capital risk. A semi-transparent Green Background fill connects the Entry line to the final TP3 line, representing the total projected reward zone.

[b]• Heatmap Candles[/b]
The indicator takes control of the underlying candlestick colors to reflect the current structural bias. Deep Teal candles indicate an active bullish trend, Deep Red candles indicate an active bearish trend, and Gray candles indicate a neutral market state where structural direction is unresolved.

[b]● Dashboard Readouts[/b]
A highly detailed heads-up display is rendered on the chart, featuring a dark background with bright, contrasting text. It provides rows of vital data including:
[list]
[*]Last Signal and Trend State (e.g., HH-HL Up).
[*]Candle Bias and a visual bar chart representing the Strength Score.
[*]Confirmed Signal Count and Bars Since the Last Signal.
[*]Active Position status, Entry Price, and Stop Loss Price.
[*]Dynamic tick boxes for TP1, TP2, and TP3 displaying price levels and completion checkmarks.
[*]Real-time Floating P/L (Profit/Loss) expressed in 'R' multiples.
[*]Current ATR values and Volume vs Average visual bar meters.
[*]Current state of Session and HTF filters.
[/list]
📌 Note : the best way to resolve visual overlap is to navigate to the Object Tree and drag the indicator above the main chart layer, or simply hide the native candles in your chart settings.

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/5lHyUBUm/[/image]
[b]● Signal Execution[/b]
Traders should monitor the formation of the dashed candidate lines. When a breakout occurs, do not act prematurely; wait for the candle to close (if "Confirm by Close" is active) and ensure the primary signal triangle prints. This confirms that all volume and volatility parameters have been met.

[b]● Assessing Trade Quality[/b]
Immediately consult the dashboard's "Strength Score." Higher scores (e.g., above 75%) indicate robust volume participation and excellent higher timeframe alignment, making them higher probability setups. Lower scores may warrant reduced position sizing or skipping the setup entirely.

[b]● Trade Management[/b]
Utilize the dynamically plotted lines to set limit orders and stop losses in your execution platform. As price reaches TP1 and TP2 (indicated by checkmarks on the dashboard), consider trailing the stop loss to breakeven or the next logical structure point. If the candle heatmap shifts to gray (neutral) before reaching targets, it may be a prudent early exit warning.

[b]⚙️ Inputs and Settings[/b]

[b]● Core Settings[/b]
[list]
[*]Lookback: Defines the number of bars used to identify localized tops and bottoms. Higher values find macro structures; lower values find micro structures.
[*]Confirm by Close: Toggles whether the breakout must be confirmed by the candle's closing price or just the wick.
[*]ATR Len & ATR Break Mult: Controls the volatility buffer required to validate a breakout.
[/list]

[b]● Filters[/b]
[list]
[*]Volume Confirm: Requires breakout volume to exceed the moving average multiplied by the "Vol Spike Mult".
[*]HTF Confluence: Restricts signals to those that align with the high/low structure of the user-defined Higher Timeframe.
[*]Session Filter: Restricts signal generation to a specific daily time window (e.g., standard market hours).
[/list]

[b]● Trade Tools[/b]
[list]
[*]TP1, TP2, TP3 R:R: Defines the static Risk-to-Reward multipliers for the take profit targets.
[*]SL ATR Buffer: Adds additional breathing room to the stop loss beyond the absolute structural pivot.
[/list]

[b]● Visuals & Dashboard[/b]
Allows the user to toggle the display of candidate lines, heatmaps, and the main data dashboard, as well as reposition the dashboard to any corner of the screen.

[b]● Alerts[/b]
Customizable string inputs for JSON payload generation, allowing traders to map long, short, close, trail, and target-hit actions directly to automated execution systems.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]● Dow Theory and Structural Extremes[/b]
The foundational logic of this script is rooted in classical Dow Theory, which posits that a trend is defined by a sequence of higher highs and higher lows (bullish) or lower highs and lower lows (bearish). By mathematically indexing `highestbars` and `lowestbars`, the script algorithmically isolates these fractal extremes, stripping away subjective human interpretation of market swings.

[b]● Volatility-Normalized Breakout Thresholds[/b]
Financial markets are noisy, characterized by frequent false breaks (liquidity sweeps). This indicator employs Average True Range (ATR), a metric developed by J. Welles Wilder, to normalize the breakout threshold against current market volatility. By requiring price to exceed a structural level by a factor of the ATR, the algorithm relies on statistical significance—demanding that the breakout possesses enough standard deviations of momentum to be classified as a genuine shift in supply and demand, rather than random market drift.

[b]● Volume Participation Theory[/b]
Drawing on Volume Price Trend (VPT) mechanics, the algorithm recognizes that price movement without volume is highly suspect. The implementation of a volume moving average filter ensures that structural breaks are validated by a true influx of market participation, confirming that the imbalance between buyers and sellers is robust enough to sustain a new directional vector.

[b]● Automated Expected Value (EV) Projection[/b]
By mechanically tying the entry price to a mathematically defined stop-loss, and extrapolating predetermined Risk-to-Reward targets, the script enforces strict expected value mechanics. This removes emotional profit-taking, ensuring that winning trades scale out at mathematically optimal R-multiples (e.g., 1R, 2R, 3R), aligning the trader's execution with positive expectancy mathematical models over a large sample size of trades.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator(
     "Dynamic MSS Navigator [MarkitTick]",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500
)

// ── INPUTS ───────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
lookback = input.int(20, "Lookback", minval = 2, group = GRP_CORE)
confirmByClose = input.bool(true, "Confirm by Close", group = GRP_CORE)
atrLen = input.int(14, "ATR Len", minval = 1, group = GRP_CORE)
atrMult = input.float(0.25, "ATR Break Mult", minval = 0.0, step = 0.05, group = GRP_CORE)

var string GRP_FILT = "🕯️ Filters"
useVolFilter = input.bool(true, "Volume Confirm", group = GRP_FILT)
volLen = input.int(20, "Vol SMA Len", minval = 1, group = GRP_FILT)
volMult = input.float(1.2, "Vol Spike Mult", minval = 0.1, step = 0.1, group = GRP_FILT)
useHTF = input.bool(false, "HTF Confluence", group = GRP_FILT)
htfTF = input.timeframe("240", "HTF", group = GRP_FILT)
useSession = input.bool(false, "Session Filter", group = GRP_FILT)
sessionInput = input.session("0930-1600", "Session", group = GRP_FILT)
minBarsBetween = input.int(3, "Min Bars Between Signals", minval = 0, group = GRP_FILT)

var string GRP_TRADE = "📐 Trade Tools"
useTradeLevels = input.bool(true, "Show Trade Levels", group = GRP_TRADE)
rr1 = input.float(1.0, "TP1 R:R", minval = 0.1, step = 0.1, group = GRP_TRADE)
rr2 = input.float(2.0, "TP2 R:R", minval = 0.1, step = 0.1, group = GRP_TRADE)
rr3 = input.float(3.0, "TP3 R:R", minval = 0.1, step = 0.1, group = GRP_TRADE)
slBuffer = input.float(0.25, "SL ATR Buffer", minval = 0.0, step = 0.05, group = GRP_TRADE)

var string GRP_VIS = "🎨 Visuals"
showCandidateLevels = input.bool(true, "Candidate Levels", group = GRP_VIS)
showConfirmationLabels = input.bool(true, "Confirmation Labels", group = GRP_VIS)
showHeatmap = input.bool(true, "Candle Heatmap", group = GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosition = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

var string GRP_WH = "🔔 Alerts"
i_actionLong = input.string("long", "↑ Long Action", group = GRP_WH)
i_actionShort = input.string("short", "↓ Short Action", group = GRP_WH)
i_actionCloseLong = input.string("closelong", "✕ Close Long Action", group = GRP_WH)
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH)
i_actionTrailUpdate = input.string("trail_update", "⟳ Trail Update Action", group = GRP_WH)
i_actionTP1 = input.string("tp1hit", "◆ TP1 Action", group = GRP_WH)
i_actionTP2 = input.string("tp2hit", "✦ TP2 Action", group = GRP_WH)
i_actionTP3 = input.string("tp3hit", "◆ TP3 Action", group = GRP_WH)

var string GRP_COL = "🌈 Colors"
colTopLine = input.color(color.new(color.red, 30), "Candidate Top Line", group = GRP_COL)
colBottomLine = input.color(color.new(color.green, 30), "Candidate Bottom Line", group = GRP_COL)
colSellMarker = input.color(color.red, "Sell Marker", group = GRP_COL)
colBuyMarker = input.color(color.green, "Buy Marker", group = GRP_COL)
colSellConfirm = input.color(color.new(color.red, 40), "Sell Confirm Label", group = GRP_COL)
colBuyConfirm = input.color(color.new(color.green, 40), "Buy Confirm Label", group = GRP_COL)
colBullCandle = input.color(color.new(#26a69a, 0), "Bull Heatmap Candle", group = GRP_COL)
colBearCandle = input.color(color.new(#ef5350, 0), "Bear Heatmap Candle", group = GRP_COL)
colNeutralCandle = input.color(color.new(#787b86, 0), "Neutral Heatmap Candle", group = GRP_COL)
colSL = input.color(color.red, "SL Line", group = GRP_COL)
colDashBg = input.color(color.new(#0a0f1a, 10), "Dash Background", group = GRP_COL)
colDashHeader = input.color(color.new(#14b5cb, 20), "Dash Header", group = GRP_COL)
colDashHeaderTxt = input.color(color.white, "Dash Header Text", group = GRP_COL)
colDashLabelTxt = input.color(color.new(#ffffff, 30), "Dash Label Text", group = GRP_COL)
colDashLabelBg = input.color(color.new(#0a0f1a, 0), "Dash Label Bg", group = GRP_COL)
colDashValueTxt = input.color(color.new(#ffffff, 0), "Dash Value Text", group = GRP_COL)
colDashValueBg = input.color(color.new(#0d1117, 0), "Dash Value Bg", group = GRP_COL)
colEntryLine = input.color(color.new(#2196f3, 0), "Entry Line", group = GRP_COL)
colTP1Line = input.color(color.new(#26a69a, 40), "TP1 Line", group = GRP_COL)
colTP2Line = input.color(color.new(#26a69a, 20), "TP2 Line", group = GRP_COL)
colTP3Line = input.color(color.new(#26a69a, 0), "TP3 Line", group = GRP_COL)
colRiskFill = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group = GRP_COL)
colRewardFill = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group = GRP_COL)
colLevelLabelTxt = input.color(color.white, "Level Label Text", group = GRP_COL)

// ── UDTs ─────────────────────────────────────────────────────

// ── CORE LOGIC ───────────────────────────────────────────────
var float candidateTopHigh = na
var float candidateTopLow  = na
var int   candidateTopBar  = na
var bool  topActive        = false
var line  topLevelLine     = na

var float candidateBottomHigh = na
var float candidateBottomLow  = na
var int   candidateBottomBar  = na
var bool  bottomActive        = false
var line  bottomLevelLine     = na

float atrVal = ta.atr(atrLen)
float volSma = ta.sma(volume, volLen)
bool _mt741a = not useVolFilter or volume[1] > volSma[1] * volMult
bool sessionOk = not useSession or not na(time(timeframe.period, sessionInput))

var int lastSignalBar = na
var int confirmedCount = 0
var int trendState = 0
var float lastLevelPrice = na
var string lastSignalType = "None"
var float lastStrengthScore = na
var float slLongPrice = na
var float slShortPrice = na
var int candleBias = 0
var float bullSignalLevel = na
var float bearSignalLevel = na

isNewTop = ta.highestbars(high[1], lookback) == 0
isNewBottom = ta.lowestbars(low[1], lookback) == 0

htfTopHigh = request.security(syminfo.tickerid, htfTF, ta.highest(high, lookback)[1], lookahead = barmerge.lookahead_on)
htfBottomLow = request.security(syminfo.tickerid, htfTF, ta.lowest(low, lookback)[1], lookahead = barmerge.lookahead_on)

bool sellSignal = false
bool buySignal  = false

shouldUpdateTop = isNewTop and (not topActive or high[1] > candidateTopHigh)

if shouldUpdateTop
    candidateTopHigh := high[1]
    candidateTopLow  := low[1]
    candidateTopBar  := bar_index - 1
    topActive        := true

    if not na(topLevelLine)
        line.delete(topLevelLine)

    if showCandidateLevels
        topLevelLine := line.new(
             x1 = candidateTopBar,
             y1 = candidateTopLow,
             x2 = bar_index + 50,
             y2 = candidateTopLow,
             color = colTopLine,
             style = line.style_dashed,
             width = 2
        )

topBreak = confirmByClose ? close[1] < candidateTopLow - atrVal * atrMult : low[1] < candidateTopLow - atrVal * atrMult
bool topBarsOk = na(lastSignalBar) or (bar_index - lastSignalBar) >= minBarsBetween
bool topHTFOk = not useHTF or na(htfTopHigh) or candidateTopHigh >= htfTopHigh * 0.995

if topActive and bar_index > candidateTopBar and topBreak and _mt741a and sessionOk and topBarsOk

    sellSignal := true
    lastSignalBar := bar_index
    confirmedCount += 1
    trendState := -1
    candleBias := -1
    lastLevelPrice := candidateTopHigh
    lastSignalType := "Sell"

    float distScore = math.min(math.abs(candidateTopHigh - close) / (atrVal + 1e-10) * 20, 40)
    float volScore = math.min((volume / (volSma + 1e-10)) * 20, 30)
    float htfScore = topHTFOk and useHTF ? 30 : useHTF ? 0 : 15
    lastStrengthScore := math.min(distScore + volScore + htfScore, 100)

    if not na(topLevelLine)
        line.set_x2(topLevelLine, bar_index)
        line.set_extend(topLevelLine, extend.none)

    slShortPrice := candidateTopHigh + atrVal * slBuffer
    bearSignalLevel := slShortPrice

    topActive := false
    candidateTopHigh := na
    candidateTopLow  := na
    candidateTopBar  := na
    topLevelLine     := na

shouldUpdateBottom = isNewBottom and (not bottomActive or low[1] < candidateBottomLow)

if shouldUpdateBottom
    candidateBottomHigh := high[1]
    candidateBottomLow  := low[1]
    candidateBottomBar  := bar_index - 1
    bottomActive        := true

    if not na(bottomLevelLine)
        line.delete(bottomLevelLine)

    if showCandidateLevels
        bottomLevelLine := line.new(
             x1 = candidateBottomBar,
             y1 = candidateBottomHigh,
             x2 = bar_index + 50,
             y2 = candidateBottomHigh,
             color = colBottomLine,
             style = line.style_dashed,
             width = 2
        )

bottomBreak = confirmByClose ? close[1] > candidateBottomHigh + atrVal * atrMult : high[1] > candidateBottomHigh + atrVal * atrMult
bool bottomBarsOk = na(lastSignalBar) or (bar_index - lastSignalBar) >= minBarsBetween
bool bottomHTFOk = not useHTF or na(htfBottomLow) or candidateBottomLow <= htfBottomLow * 1.005

if bottomActive and bar_index > candidateBottomBar and bottomBreak and _mt741a and sessionOk and bottomBarsOk

    buySignal := true
    lastSignalBar := bar_index
    confirmedCount += 1
    trendState := 1
    candleBias := 1
    lastLevelPrice := candidateBottomLow
    lastSignalType := "Buy"

    float distScore = math.min(math.abs(close - candidateBottomLow) / (atrVal + 1e-10) * 20, 40)
    float volScore = math.min((volume / (volSma + 1e-10)) * 20, 30)
    float htfScore = bottomHTFOk and useHTF ? 30 : useHTF ? 0 : 15
    lastStrengthScore := math.min(distScore + volScore + htfScore, 100)

    if not na(bottomLevelLine)
        line.set_x2(bottomLevelLine, bar_index)
        line.set_extend(bottomLevelLine, extend.none)

    slLongPrice := candidateBottomLow - atrVal * slBuffer
    bullSignalLevel := slLongPrice

    bottomActive := false
    candidateBottomHigh := na
    candidateBottomLow  := na
    candidateBottomBar  := na
    bottomLevelLine     := na

bool bullBreakLine = candleBias == 1 and not na(bullSignalLevel) and close[1] < bullSignalLevel
bool bearBreakLine = candleBias == -1 and not na(bearSignalLevel) and close[1] > bearSignalLevel

if bullBreakLine
    candleBias := -1

if bearBreakLine
    candleBias := 1

var line   levelSlLine    = na
var line   levelEntryLine = na
var line   levelTp1Line   = na
var line   levelTp2Line   = na
var line   levelTp3Line   = na
var label  levelSlLbl     = na
var label  levelEntryLbl  = na
var label  levelTp1Lbl    = na
var label  levelTp2Lbl    = na
var label  levelTp3Lbl    = na
var linefill levelRiskFill   = na
var linefill levelRewardFill = na
var float levelEntryPrice = na
var int   levelEntryBar   = na
var float levelSlPrice    = na
var float levelTp1Price   = na
var float levelTp2Price   = na
var float levelTp3Price   = na
var bool  levelIsLong     = bool(na)
var bool  levelTp1Done    = false
var bool  levelTp2Done    = false
var bool  levelTp3Done    = false
var bool  levelSlBreached = false

f_deleteLevels() =>
    line.delete(levelSlLine)
    line.delete(levelEntryLine)
    line.delete(levelTp1Line)
    line.delete(levelTp2Line)
    line.delete(levelTp3Line)
    label.delete(levelSlLbl)
    label.delete(levelEntryLbl)
    label.delete(levelTp1Lbl)
    label.delete(levelTp2Lbl)
    label.delete(levelTp3Lbl)
    linefill.delete(levelRiskFill)
    linefill.delete(levelRewardFill)

f_drawLevels(int x1) =>
    int extX = bar_index + 50

    line slLine    = line.new(x1, levelSlPrice,    extX, levelSlPrice,    color = colSL,        style = line.style_solid,  width = 2)
    line entryLine = line.new(x1, levelEntryPrice, extX, levelEntryPrice, color = colEntryLine, style = line.style_dashed, width = 1)
    line tp1Line   = line.new(x1, levelTp1Price,   extX, levelTp1Price,   color = colTP1Line,   style = line.style_dashed, width = 1)
    line tp2Line   = line.new(x1, levelTp2Price,   extX, levelTp2Price,   color = colTP2Line,   style = line.style_dashed, width = 1)
    line tp3Line   = line.new(x1, levelTp3Price,   extX, levelTp3Price,   color = colTP3Line,   style = line.style_dashed, width = 1)

    label slLbl    = label.new(extX, levelSlPrice,    "✕ SL " + str.tostring(levelSlPrice, format.mintick),    style = label.style_label_left, color = colSL,        textcolor = colLevelLabelTxt, size = size.small)
    label entryLbl = label.new(extX, levelEntryPrice, "▶ Entry " + str.tostring(levelEntryPrice, format.mintick), style = label.style_label_left, color = colEntryLine, textcolor = colLevelLabelTxt, size = size.small)
    label tp1Lbl   = label.new(extX, levelTp1Price,   "◆ TP1 " + str.tostring(levelTp1Price, format.mintick),   style = label.style_label_left, color = colTP1Line,   textcolor = colLevelLabelTxt, size = size.small)
    label tp2Lbl   = label.new(extX, levelTp2Price,   "✦ TP2 " + str.tostring(levelTp2Price, format.mintick),   style = label.style_label_left, color = colTP2Line,   textcolor = colLevelLabelTxt, size = size.small)
    label tp3Lbl   = label.new(extX, levelTp3Price,   "◆ TP3 " + str.tostring(levelTp3Price, format.mintick),   style = label.style_label_left, color = colTP3Line,   textcolor = colLevelLabelTxt, size = size.small)

    linefill riskFill   = linefill.new(slLine, entryLine, colRiskFill)
    linefill rewardFill = linefill.new(entryLine, tp3Line, colRewardFill)

    [slLine, entryLine, tp1Line, tp2Line, tp3Line, slLbl, entryLbl, tp1Lbl, tp2Lbl, tp3Lbl, riskFill, rewardFill]

bool hasOpenLevel = useTradeLevels and not na(levelEntryPrice)

bool slBreachThisBar = hasOpenLevel and (levelIsLong ? (confirmByClose ? close[1] <= levelSlPrice : low[1] <= levelSlPrice) : (confirmByClose ? close[1] >= levelSlPrice : high[1] >= levelSlPrice))
if slBreachThisBar
    levelSlBreached := true

bool isContinuationSignal = hasOpenLevel and not levelSlBreached and ((buySignal and levelIsLong) or (sellSignal and not levelIsLong))
bool newLevelSignal = useTradeLevels and (buySignal or sellSignal) and not isContinuationSignal

if newLevelSignal
    f_deleteLevels()

    levelIsLong     := buySignal
    levelEntryPrice := close[1]
    levelEntryBar   := bar_index
    levelSlPrice    := buySignal ? slLongPrice : slShortPrice
    float risk = math.abs(levelEntryPrice - levelSlPrice)
    levelTp1Price := buySignal ? levelEntryPrice + risk * rr1 : levelEntryPrice - risk * rr1
    levelTp2Price := buySignal ? levelEntryPrice + risk * rr2 : levelEntryPrice - risk * rr2
    levelTp3Price := buySignal ? levelEntryPrice + risk * rr3 : levelEntryPrice - risk * rr3
    levelTp1Done  := false
    levelTp2Done  := false
    levelTp3Done  := false
    levelSlBreached := false

    [newSlLine, newEntryLine, newTp1Line, newTp2Line, newTp3Line, newSlLbl, newEntryLbl, newTp1Lbl, newTp2Lbl, newTp3Lbl, newRiskFill, newRewardFill] = f_drawLevels(levelEntryBar)
    levelSlLine     := newSlLine
    levelEntryLine  := newEntryLine
    levelTp1Line    := newTp1Line
    levelTp2Line    := newTp2Line
    levelTp3Line    := newTp3Line
    levelSlLbl      := newSlLbl
    levelEntryLbl   := newEntryLbl
    levelTp1Lbl     := newTp1Lbl
    levelTp2Lbl     := newTp2Lbl
    levelTp3Lbl     := newTp3Lbl
    levelRiskFill   := newRiskFill
    levelRewardFill := newRewardFill

if isContinuationSignal
    float candSl = levelIsLong ? slLongPrice : slShortPrice

    bool slImproved = levelIsLong ? candSl > levelSlPrice : candSl < levelSlPrice
    if slImproved
        levelSlPrice := candSl

    float origRisk = math.abs(levelEntryPrice - levelSlPrice)
    float newTp2 = levelIsLong ? levelEntryPrice + origRisk * rr2 : levelEntryPrice - origRisk * rr2
    float newTp3 = levelIsLong ? levelEntryPrice + origRisk * rr3 : levelEntryPrice - origRisk * rr3

    if newTp2 != levelTp2Price
        levelTp2Done := false
    levelTp2Price := newTp2

    if newTp3 != levelTp3Price
        levelTp3Done := false
    levelTp3Price := newTp3

    f_deleteLevels()
    [contSlLine, contEntryLine, contTp1Line, contTp2Line, contTp3Line, contSlLbl, contEntryLbl, contTp1Lbl, contTp2Lbl, contTp3Lbl, contRiskFill, contRewardFill] = f_drawLevels(levelEntryBar)
    levelSlLine     := contSlLine
    levelEntryLine  := contEntryLine
    levelTp1Line    := contTp1Line
    levelTp2Line    := contTp2Line
    levelTp3Line    := contTp3Line
    levelSlLbl      := contSlLbl
    levelEntryLbl   := contEntryLbl
    levelTp1Lbl     := contTp1Lbl
    levelTp2Lbl     := contTp2Lbl
    levelTp3Lbl     := contTp3Lbl
    levelRiskFill   := contRiskFill
    levelRewardFill := contRewardFill

if not na(levelSlLine) and not na(lastSignalBar) and bar_index <= lastSignalBar + 50
    int _extX = lastSignalBar + 50
    line.set_x2(levelSlLine,    _extX)
    line.set_x2(levelEntryLine, _extX)
    line.set_x2(levelTp1Line,   _extX)
    line.set_x2(levelTp2Line,   _extX)
    line.set_x2(levelTp3Line,   _extX)
    label.set_x(levelSlLbl,     _extX)
    label.set_x(levelEntryLbl,  _extX)
    label.set_x(levelTp1Lbl,    _extX)
    label.set_x(levelTp2Lbl,    _extX)
    label.set_x(levelTp3Lbl,    _extX)

// ── ALERTS ───────────────────────────────────────────────
bool tp1Hit = not na(levelTp1Price) and not levelTp1Done and (levelIsLong ? high >= levelTp1Price : low <= levelTp1Price)
bool tp2Hit = not na(levelTp2Price) and not levelTp2Done and (levelIsLong ? high >= levelTp2Price : low <= levelTp2Price)
bool tp3Hit = not na(levelTp3Price) and not levelTp3Done and (levelIsLong ? high >= levelTp3Price : low <= levelTp3Price)

if tp1Hit
    levelTp1Done := true
if tp2Hit
    levelTp2Done := true
if tp3Hit
    levelTp3Done := true

string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","trend":"{8}","strength":"{9}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slLongPrice, format.mintick),
     str.tostring(levelTp1Price, format.mintick),
     str.tostring(levelTp2Price, format.mintick),
     str.tostring(levelTp3Price, format.mintick),
     str.tostring(trendState),
     str.tostring(na(lastStrengthScore) ? 0.0 : lastStrengthScore))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","trend":"{8}","strength":"{9}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(close[1], format.mintick),
     str.tostring(slShortPrice, format.mintick),
     str.tostring(levelTp1Price, format.mintick),
     str.tostring(levelTp2Price, format.mintick),
     str.tostring(levelTp3Price, format.mintick),
     str.tostring(trendState),
     str.tostring(na(lastStrengthScore) ? 0.0 : lastStrengthScore))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

string _trailLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","trend":"{8}","strength":"{9}"',
     i_actionTrailUpdate, syminfo.tickerid, timeframe.period,
     str.tostring(levelEntryPrice, format.mintick),
     str.tostring(levelSlPrice, format.mintick),
     str.tostring(levelTp1Price, format.mintick),
     str.tostring(levelTp2Price, format.mintick),
     str.tostring(levelTp3Price, format.mintick),
     str.tostring(trendState),
     str.tostring(na(lastStrengthScore) ? 0.0 : lastStrengthScore))

string _trailShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","trend":"{8}","strength":"{9}"',
     i_actionTrailUpdate, syminfo.tickerid, timeframe.period,
     str.tostring(levelEntryPrice, format.mintick),
     str.tostring(levelSlPrice, format.mintick),
     str.tostring(levelTp1Price, format.mintick),
     str.tostring(levelTp2Price, format.mintick),
     str.tostring(levelTp3Price, format.mintick),
     str.tostring(trendState),
     str.tostring(na(lastStrengthScore) ? 0.0 : lastStrengthScore))

string trailUpdatePayload = levelIsLong ? "{" + _trailLongInner + "}" : "{" + _trailShortInner + "}"

string _tp1Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"',
     i_actionTP1, syminfo.tickerid, timeframe.period, str.tostring(levelTp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"

string _tp2Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"',
     i_actionTP2, syminfo.tickerid, timeframe.period, str.tostring(levelTp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"

string _mt741b = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","price":"{3}"',
     i_actionTP3, syminfo.tickerid, timeframe.period, str.tostring(levelTp3Price, format.mintick))
string tp3Payload = "{" + _mt741b + "}"

if buySignal and not isContinuationSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if sellSignal and not isContinuationSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if sellSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if buySignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if isContinuationSignal and barstate.isconfirmed
    alert(trailUpdatePayload, alert.freq_once_per_bar_close)

if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(buySignal  and not isContinuationSignal and barstate.isconfirmed, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(sellSignal and not isContinuationSignal and barstate.isconfirmed, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(sellSignal and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(buySignal  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
alertcondition(isContinuationSignal and barstate.isconfirmed, "Trail Update", "MarkitTick — SL/TP Trail Update")
alertcondition(tp1Hit, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2Hit, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3Hit, "TP3 Hit", "MarkitTick — TP3 Hit")

// ── VISUALS ──────────────────────────────────────────────────
plotshape(
     sellSignal and not isContinuationSignal,
     title = "Sell Signal",
     style = shape.triangledown,
     location = location.abovebar,
     color = colSellMarker,
     textcolor = colSellMarker,
     size = size.small,
     text = "BEAR"
)

plotshape(
     buySignal and not isContinuationSignal,
     title = "Buy Signal",
     style = shape.triangleup,
     location = location.belowbar,
     color = colBuyMarker,
     textcolor = colBuyMarker,
     size = size.small,
     text = "BULL"
)

plotchar(
     sellSignal and isContinuationSignal,
     title = "Bear Reinforcement",
     char = "✚",
     location = location.abovebar,
     color = colSellMarker,
     size = size.tiny
)

plotchar(
     buySignal and isContinuationSignal,
     title = "Bull Reinforcement",
     char = "✚",
     location = location.belowbar,
     color = colBuyMarker,
     size = size.tiny
)

color bodyColor = candleBias == 1 ? colBullCandle : candleBias == -1 ? colBearCandle : colNeutralCandle
color borderColor = bodyColor

plotcandle(
     showHeatmap ? open : na,
     showHeatmap ? high : na,
     showHeatmap ? low : na,
     showHeatmap ? close : na,
     title = "Heatmap Candles",
     color = bodyColor,
     wickcolor = borderColor,
     bordercolor = borderColor
)

// ── DASHBOARD ────────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

var string tablePos = dashPosition == "Top Right" ? position.top_right : dashPosition == "Top Left" ? position.top_left : dashPosition == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(tablePos, 2, 21, bgcolor = colDashBg, frame_color = colDashBg, frame_width = 1)

if showDashboard
    table.cell(dash, 0, 0, "MarkitTick Dashboard", text_color = colDashHeaderTxt, bgcolor = colDashHeader, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "", text_color = colDashHeaderTxt, bgcolor = colDashHeader, text_size = size.normal)

    table.cell(dash, 0, 1, "Last Signal", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, lastSignalType, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string trendTxt = trendState == 1 ? "HH-HL (Up)" : trendState == -1 ? "LH-LL (Down)" : "Neutral"
    table.cell(dash, 0, 2, "Trend", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, trendTxt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string biasTxt = candleBias == 1 ? "Bull" : candleBias == -1 ? "Bear" : "Neutral"
    color biasClr = candleBias == 1 ? colBullCandle : candleBias == -1 ? colBearCandle : colNeutralCandle
    table.cell(dash, 0, 3, "Candle Bias", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, biasTxt, text_color = biasClr, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    float strengthPct = na(lastStrengthScore) ? 0.0 : lastStrengthScore / 100
    table.cell(dash, 0, 4, "Strength", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, f_bar(na(lastStrengthScore) ? 0.0 : lastStrengthScore, 100), text_color = f_barColor(strengthPct), bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Confirmed Count", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(confirmedCount), text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string barsSinceTxt = na(lastSignalBar) ? "—" : str.tostring(bar_index - lastSignalBar)
    table.cell(dash, 0, 6, "Bars Since Signal", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, barsSinceTxt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    float distFromLevel = na(lastLevelPrice) ? na : close - lastLevelPrice
    table.cell(dash, 0, 7, "Dist From Level", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, na(distFromLevel) ? "—" : str.tostring(distFromLevel, format.mintick), text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string posTxt = hasOpenLevel ? (levelIsLong ? "Long" : "Short") : "None"
    color posClr = hasOpenLevel ? (levelIsLong ? colBuyMarker : colSellMarker) : colDashValueTxt
    table.cell(dash, 0, 8, "Position", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, posTxt, text_color = posClr, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 9, "Entry", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 9, hasOpenLevel ? str.tostring(levelEntryPrice, format.mintick) : "—", text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 10, "Stop Loss", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 10, hasOpenLevel ? str.tostring(levelSlPrice, format.mintick) : "—", text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string tp1Txt = hasOpenLevel ? str.tostring(levelTp1Price, format.mintick) + (levelTp1Done ? " ✓" : "") : "—"
    table.cell(dash, 0, 11, "TP1", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 11, tp1Txt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string tp2Txt = hasOpenLevel ? str.tostring(levelTp2Price, format.mintick) + (levelTp2Done ? " ✓" : "") : "—"
    table.cell(dash, 0, 12, "TP2", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 12, tp2Txt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string tp3Txt = hasOpenLevel ? str.tostring(levelTp3Price, format.mintick) + (levelTp3Done ? " ✓" : "") : "—"
    table.cell(dash, 0, 13, "TP3", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 13, tp3Txt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    float rrPct = math.min(rr3 / 5.0, 1.0)
    table.cell(dash, 0, 14, "R:R (TP3)", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 14, f_bar(rr3, 5.0), text_color = f_barColor(rrPct), bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    float riskAmt = hasOpenLevel ? math.abs(levelEntryPrice - levelSlPrice) : na
    float plR = hasOpenLevel and riskAmt > 0 ? (levelIsLong ? (close - levelEntryPrice) / riskAmt : (levelEntryPrice - close) / riskAmt) : na
    string plTxt = na(plR) ? "—" : (plR >= 0 ? "+" : "") + str.tostring(plR, "#.##") + "R"
    color plClr = na(plR) ? colDashValueTxt : plR >= 0 ? colBullCandle : colBearCandle
    table.cell(dash, 0, 15, "Floating P/L", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 15, plTxt, text_color = plClr, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 16, "SL Breach", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 16, hasOpenLevel ? (levelSlBreached ? "Yes" : "No") : "—", text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 17, "ATR", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 17, str.tostring(atrVal, format.mintick), text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    float volRatioVal = volSma > 0 ? volume / volSma : 0.0
    float volPct = math.min(volRatioVal / 2.0, 1.0)
    table.cell(dash, 0, 18, "Volume vs Avg", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 18, f_bar(volRatioVal, 2.0), text_color = f_barColor(volPct), bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string sessionTxt = not useSession ? "Off" : (sessionOk ? "Active" : "Inactive")
    table.cell(dash, 0, 19, "Session", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 19, sessionTxt, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)

    string _mt741c = useHTF ? "On · " + htfTF : "Off"
    table.cell(dash, 0, 20, "HTF Filter", text_color = colDashLabelTxt, bgcolor = colDashLabelBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 20, _mt741c, text_color = colDashValueTxt, bgcolor = colDashValueBg, text_size = size.small, text_halign = text.align_right)
````
