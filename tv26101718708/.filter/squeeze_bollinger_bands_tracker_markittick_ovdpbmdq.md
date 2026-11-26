# Squeeze Bollinger Bands Tracker [MarkitTick]

- url: https://www.tradingview.com/script/ovdpbMDq-Squeeze-Bollinger-Bands-Tracker-MarkitTick/
- type: indicator
- pine_id: PUB;2c9f1efe3778461680be1698f9af1336
- version: 1.0

## Description

💡 This institutional-grade analysis suite provides a sophisticated volatility-tracking environment designed to identify market compression phases and high-conviction breakouts. By integrating Bollinger Band standard deviation logic with Z-Score normalization and a non-linear sigmoid volatility engine, the script transforms raw price action into a multi-dimensional heatmap. This approach allows traders to distinguish between low-volatility "coiling" phases and institutional-driven momentum expansions, providing a clear visual representation of market energy.

[b]● ✨ Originality and Utility[/b]

The Squeeze Bollinger Bands Tracker distinguishes itself through the implementation of a proprietary "Signal Engine" and a non-linear volatility grading system. Unlike standard Bollinger Band indicators that merely plot static lines, this tool actively monitors the rate of change in channel width relative to its own historical standard deviation. 

[b]• Dynamic Volatility Normalization[/b]
Most indicators rely on linear calculations that fail to account for the exponential nature of market expansion. This script utilizes a Z-Score calculation to determine how extreme a volatility move is compared to its history, then maps that value through a sigmoid function. This creates a "Heatmap" effect on the candles that reflects institutional participation levels rather than simple price movement.

[b]• Institutional Breakout Grading[/b]
The utility is further enhanced by an automated grading system (Grades A, B, and C). By cross-referencing price spread (the distance between open and close) with actual volume metrics during a breakout, the script provides an objective measure of signal quality, helping traders filter out "fakeouts" that lack volume support.

[b]● 🔬 Methodology and Concepts[/b]

The logic flow is divided into three core analytical pillars: Compression Detection, Momentum Normalization, and Signal Verification.

[b]• Compression Detection (The Squeeze)[/b]
The script calculates the percentage-based width of the Bollinger Bands. When the current width falls below its SMA-based average, the market is classified as being in a "Squeeze" state. This signifies a period where market energy is being stored, often preceding a significant directional expansion.

[b]• Sigmoid-Mapped Z-Score Volatility[/b]
To provide the neon heatmap coloring, the script calculates the Z-Score of the channel width. This tells us how many standard deviations the current volatility is from the mean. This Z-Score is then processed through a Sigmoid Function: 100 / (1 + exp(-Z-Score)). This mathematical transformation squashes the infinite Z-Score range into a 0–100 scale, creating a smooth gradient for the "True Institutional Heatmap."

[b]• Breakout Validation Engine[/b]
Signals are not generated simply on a price cross. The Signal Engine (a custom User-Defined Type) calculates real-time Entry, Stop Loss (based on the previous basis line), and Take Profit levels. During the moment of crossover, the "calcGrade" method evaluates if the current bar's spread and volume are at least 150% of their historical averages to assign a Grade A "Institutional" breakout.

[b]● 🎨 Visual Guide[/b]

The visual interface is designed with a high-contrast "3D Neon" aesthetic to ensure critical data points are immediately recognizable during fast-moving market conditions.

[b]• The 3D Neon Channels[/b]
[list][*][b]Upper Core & Glow:[/b] The upper Bollinger Band is rendered in Cyan (#00FFFF). It features three layers: a 2-pixel core for precision and two wider "Glow" layers with varying transparency (60% and 85%) to create a neon effect.
[*][b]Lower Core & Glow:[/b] The lower band is rendered in Magenta (#FF00FF), following the same three-layer glow architecture to signify the support boundary.
[*][b]Basis Core:[/b] The central moving average is rendered in Yellow (#FFFF00), acting as the dynamic mean and the primary stop-loss anchor.[/list]

[b]• True Institutional Heatmap Candles[/b]
The candle colors are not fixed; they represent a gradient based on the Sigmoid Volatility score.
[list][*][b]Bullish State:[/b] Transitions from a deep "Cold" Forest Green (#004D40) during low-volatility rises to a "Hot" Neon Green (#00FF00) during high-momentum surges.
[*][b]Bearish State:[/b] Transitions from a deep "Cold" Purple (#4A148C) during low-volatility drops to a "Hot" Neon Red (#FF0000) during aggressive sell-offs.
[*][b]Neutral State:[/b] Gray (#808080) candles appear when no definitive trend state is identified by the Signal Engine.[/list]

[b]• Analytical Dashboard and Labels[/b]
[list][*][b]Buy/Sell Labels:[/b] When a breakout occurs, a Cyan or Magenta label appears. It displays the signal Grade (A, B, or C) and the calculated E (Entry), TP (Take Profit), and SL (Stop Loss) values.
[*][b]Institutional Analytics Dashboard:[/b] Located in the top-right, this table provides real-time data on Trend Maturity (in bars), Volatility State (Squeeze vs. Expanding), and the percentage proximity to the upper and lower breakout levels.[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

The indicator is built upon the foundation of Statistical Process Control and Information Theory. By treating price movement as a signal-to-noise problem, the script uses the following frameworks:

[b]• Standard Deviation and Gaussian Distribution[/b]
The core of the Bollinger Band calculation relies on the assumption that price spends approximately 95% of its time within two standard deviations of the mean. The "Squeeze" logic identifies periods where the distribution is abnormally tight, suggesting an imminent return to the mean or a "Fat Tail" event (a breakout).

[b]• Z-Score Normalization[/b]
In statistics, the Z-Score is used to compare observations from different data sets or time periods. By applying Z-Score logic to the width of the bands, the indicator removes the "unit" of price and focuses purely on the intensity of the volatility, allowing for a standardized comparison across different assets (e.g., Bitcoin vs. Apple).

[b]• Non-Linear Sigmoid Mapping[/b]
The use of the Sigmoid function (common in Neural Network activation) serves to eliminate outliers in volatility data. This ensures that the candle heatmap provides meaningful color variations even during extreme "Black Swan" events, preventing the visual output from becoming saturated or unreadable.

[b]● 📖 How to Use[/b]

Traders should focus on the transition between market states as displayed by the Analytics Dashboard and the Heatmap.

[b]• Step 1: Identify the Squeeze[/b]
Monitor the "Volatility State" in the dashboard. When it displays "⚠️ SQUEEZE" in Neon Orange, the market is coiling. This is the preparation phase where no trades should be taken.

[b]• Step 2: Evaluate the Breakout Grade[/b]
Wait for a "BUY" or "SELL" label to appear. Priority should be given to "Grade A" signals, as these indicate that both price spread and volume have significantly exceeded their 20-period averages, confirming institutional intent.

[b]• Step 3: Execution and Risk Management[/b]
Upon a valid signal, the script provides an automated trade plan. The Stop Loss is set at the Basis (Yellow) line from the previous bar to allow for minor breathing room, while the Take Profit is projected at a 1:1 ratio relative to the width of the band at the time of entry.

[b]● ⚙️ Inputs and Settings[/b]

The script provides granular control over the analytical engine and the visual experience.

[b]• Channel Settings[/b]
[list][*][b]Channel Length:[/b] Controls the SMA window for the Bollinger Bands (Default: 20).
[*][b]Standard Deviation Multiplier:[/b] Adjusts the width of the neon boundaries (Default: 2.0).[/list]

[b]• Analytics Settings[/b]
[list][*][b]Squeeze/Z-Score Length:[/b] Determines the lookback period used to define what constitutes "average" volatility (Default: 50).
[*][b]Quality SMA Length:[/b] Defines the window for the Grade A/B/C volume and spread verification (Default: 20).[/list]

[b]• Color and Heatmap Settings[/b]
Users can fully customize the Neon Upper/Lower colors, the Dashboard background transparency, and the specific "Cold" and "Hot" thresholds for the candle gradient engine to match their preferred dark or light chart theme.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// © MarkitTick
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator("Squeeze Bollinger Bands Tracker [MarkitTick]", overlay=true)

// ============================================================================
// Types & Methods
// ============================================================================
type SignalEngine
    bool  isLong
    bool  isShort
    float entryPrice
    float stopLoss
    float takeProfit
    string grade

method generateJSON(SignalEngine sig) =>
    string actionStr = sig.isLong ? 'BUY' : 'SELL'
    string json = '{"action": "' + actionStr + '", '
    json += '"entry": ' + str.tostring(sig.entryPrice, format.mintick) + ', '
    json += '"tp": ' + str.tostring(sig.takeProfit, format.mintick) + ', '
    json += '"sl": ' + str.tostring(sig.stopLoss, format.mintick) + '}'
    json

method calcGrade(float currentSpread, float avgSpread, float currentVol, float avgVol) =>
    string g = "C"
    if currentSpread > (avgSpread * 1.5) and currentVol > (avgVol * 1.5)
        g := "A"
    else if currentSpread > avgSpread or currentVol > avgVol
        g := "B"
    g

// ============================================================================
// Inputs
// ============================================================================
int   length     = input.int(20, "Channel Length", minval=1, group="Channel Settings")
float mult       = input.float(2.0, "Standard Deviation Multiplier", minval=0.1, step=0.1, group="Channel Settings")
int   sqzLength  = input.int(50, "Squeeze/Z-Score Length", minval=1, group="Analytics Settings")
int   volLength  = input.int(20, "Quality SMA Length", minval=1, group="Analytics Settings")

color c_upper    = input.color(#00FFFF, "Neon Upper (Cyan)", group="Color Settings")
color c_lower    = input.color(#FF00FF, "Neon Lower (Magenta)", group="Color Settings")
color c_basis    = input.color(#FFFF00, "Neon Basis (Yellow)", group="Color Settings")
color c_bg       = input.color(color.new(#00FFFF, 93), "Background Fill", group="Color Settings")
color c_dashBg   = input.color(color.new(#111111, 10), "Dashboard Background", group="Color Settings")
color c_sqzWarn  = input.color(#FF3300, "Squeeze Warning (Neon Orange)", group="Color Settings")

color c_bullCold = input.color(#004D40, "Bullish Low Volatility (Cold)", group="Candle Heatmap Settings")
color c_bullHot  = input.color(#00FF00, "Bullish High Volatility (Hot/Neon)", group="Candle Heatmap Settings")
color c_bearCold = input.color(#4A148C, "Bearish Low Volatility (Cold)", group="Candle Heatmap Settings")
color c_bearHot  = input.color(#FF0000, "Bearish High Volatility (Hot/Neon)", group="Candle Heatmap Settings")
color c_neutral  = input.color(#808080, "Neutral Market Base", group="Candle Heatmap Settings")

// ============================================================================
// Core Logic & Volatility Metrics 
// ============================================================================
float basis = ta.sma(close, length)
float dev   = mult * ta.stdev(close, length)
float upper = basis + dev
float lower = basis - dev

float chWidth    = basis == 0 ? 0 : ((upper - lower) / basis) * 100
float avgChWidth = ta.sma(chWidth, sqzLength)
bool  isSqueeze  = chWidth < avgChWidth

float stdChWidth = ta.stdev(chWidth, sqzLength)
float zScore     = stdChWidth == 0 ? 0 : (chWidth - avgChWidth) / stdChWidth
float sigmoidVol = 100 / (1 + math.exp(-zScore))

float spread    = math.abs(close - open)
float avgSpread = ta.sma(spread, volLength)
float avgVol    = ta.sma(volume, volLength)
string brkGrade = calcGrade(spread, avgSpread, volume, avgVol)

// ============================================================================
// Signal Engine & Trend Tracking
// ============================================================================
bool longCond  = ta.crossover(close, upper[1])
bool shortCond = ta.crossunder(close, lower[1])

var int trendState = 0
var int trendAge   = 0

if longCond or shortCond
    trendState := longCond ? 1 : -1
    trendAge   := 0
else
    trendAge += 1

SignalEngine engine = SignalEngine.new(false, false, 0.0, 0.0, 0.0, "")

if longCond
    engine.isLong     := true
    engine.entryPrice := close
    engine.stopLoss   := basis[1]
    engine.takeProfit := close + (close - lower[1])
    engine.grade      := brkGrade

else if shortCond
    engine.isShort    := true
    engine.entryPrice := close
    engine.stopLoss   := basis[1]
    engine.takeProfit := close - (upper[1] - close)
    engine.grade      := brkGrade

if longCond or shortCond
    alert(engine.generateJSON(), alert.freq_once_per_bar_close)
    
    string lblText = (longCond ? "BUY [Grade " : "SELL [Grade ") + engine.grade + "]\n" + 
                     "E: "  + str.tostring(engine.entryPrice, format.mintick) + "\n" + 
                     "TP: " + str.tostring(engine.takeProfit, format.mintick) + "\n" + 
                     "SL: " + str.tostring(engine.stopLoss, format.mintick)
    
    color  lblColor = longCond ? c_upper : c_lower
    string lblStyle = longCond ? label.style_label_up : label.style_label_down
    float  lblY     = longCond ? low : high
    
    label.new(bar_index, lblY, lblText, color=color.new(lblColor, 85), style=lblStyle, textcolor=lblColor, size=size.small)

// ============================================================================
// True Institutional Heatmap
// ============================================================================
color bullBodyGrad = color.from_gradient(sigmoidVol, 0, 100, c_bullCold, c_bullHot)
color bearBodyGrad = color.from_gradient(sigmoidVol, 0, 100, c_bearCold, c_bearHot)

color bodyColor   = trendState == 1 ? bullBodyGrad : trendState == -1 ? bearBodyGrad : c_neutral
color borderColor = bodyColor

plotcandle(open, high, low, close, title="Heatmap Candles", color=bodyColor, wickcolor=borderColor, bordercolor=borderColor)

// ============================================================================
// 3D Neon Visualization 
// ============================================================================
plot(upper, color=color.new(c_upper, 85), linewidth=6, title="Upper Glow 1", display=display.pane)
plot(upper, color=color.new(c_upper, 60), linewidth=4, title="Upper Glow 2", display=display.pane)
p_upper = plot(upper, color=c_upper, linewidth=2, title="Upper Core")

plot(lower, color=color.new(c_lower, 85), linewidth=6, title="Lower Glow 1", display=display.pane)
plot(lower, color=color.new(c_lower, 60), linewidth=4, title="Lower Glow 2", display=display.pane)
p_lower = plot(lower, color=c_lower, linewidth=2, title="Lower Core")

plot(basis, color=color.new(c_basis, 80), linewidth=4, title="Basis Glow", display=display.pane)
plot(basis, color=c_basis, linewidth=2, title="Basis Core")

fill(p_upper, p_lower, color=c_bg, title="Channel Fill")

// ============================================================================
// Institutional Analytics Dashboard
// ============================================================================
var table dash = table.new(position.top_right, 2, 4, bgcolor=c_dashBg, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    float proxUp = (upper[1] - close) / close * 100
    float proxDn = (close - lower[1]) / close * 100
    
    string stateStr = trendState == 1 ? "BULLISH" : trendState == -1 ? "BEARISH" : "NEUTRAL"
    color  stateCol = trendState == 1 ? c_upper : trendState == -1 ? c_lower : color.gray
    string sqzStr   = isSqueeze ? "⚠️ SQUEEZE" : "EXPANDING"
    color  sqzCol   = isSqueeze ? c_sqzWarn : c_upper

    table.cell(dash, 0, 0, "Trend Maturity", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 0, stateStr + " (" + str.tostring(trendAge) + " Bars)", text_color=stateCol, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 1, "Volatility State", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 1, sqzStr + " (" + str.tostring(chWidth, "#.##") + "%)", text_color=sqzCol, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 2, "Proximity UP", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(proxUp, "#.##") + "% to Break", text_color=c_upper, text_size=size.small, text_halign=text.align_left)

    table.cell(dash, 0, 3, "Proximity DOWN", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(proxDn, "#.##") + "% to Break", text_color=c_lower, text_size=size.small, text_halign=text.align_left)
````
