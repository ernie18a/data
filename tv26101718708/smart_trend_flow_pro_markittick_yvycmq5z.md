# Smart Trend Flow Pro [MarkitTick]

- url: https://www.tradingview.com/script/YvyCmQ5Z-Smart-Trend-Flow-Pro-MarkitTick/
- type: indicator
- pine_id: PUB;2b1ef9b918694df180778f5d402c20c2
- version: 3.0

## Description

💡 Navigating modern market structures requires a robust mechanism capable of filtering out transient noise while capturing the dominant directional vectors. The Smart Trend Flow pro is an advanced analytical framework designed to dynamically track market momentum and volatility, transforming complex price action into a highly readable, visual heatmap. By synthesizing trend identification with continuous volatility scaling, this tool aims to provide clarity in both ranging environments and high-expansion phases, allowing for more structured and disciplined market analysis.

[b]✨ Originality and Utility[/b]

[b]● A Paradigm Shift in Trend Visualization[/b]
Traditional channel-based indicators often suffer from severe lag or become entirely unreadable during periods of intense market contraction. The utility of this script lies in its adaptive ability to map structural boundaries and instantly correlate them with localized market energy. By discarding static thresholds in favor of a dynamic, self-adjusting baseline, the tool presents a unified view of both direction and conviction.

[b]● Beyond Binary Signals[/b]
Standard indicators frequently rely on binary conditions—such as a simple moving average crossover—which ignore the underlying volatility context. This script pioneers a synthesized approach where the strength of a trend is continuously evaluated against its own historical variance. This allows users to visually differentiate between a low-conviction drift and a highly energized breakout, providing a much richer context for potential trade management and risk assessment.

[b]🔬 Methodology and Concepts[/b]

[b]● Dynamic Boundary Engine[/b]
At the core of the script is a reactive boundary detection mechanism. Rather than projecting fixed bands, the engine establishes fluid upper and lower parameters based on recent localized extremes. These boundaries can be structurally smoothed using various adaptive algorithms, effectively tuning the sensitivity of the channel to match the specific rhythm of the asset being analyzed. 

[b]● Volatility Normalization Process[/b]
To accurately gauge market energy, the framework continuously measures the distance between the established boundaries. This raw measurement is then subjected to a rigorous statistical normalization process. By evaluating current fluctuations against a rolling historical baseline, the engine maps the resulting variance onto a bounded curvilinear scale. This abstract transformation isolates the pure kinetic energy of the market, stripping away absolute price dependencies to provide a standardized metric of volatility expansion and contraction.

[b]● Integrated State Tracking[/b]
The logical engine monitors the interaction between the closing prices and the smoothed boundary parameters. A structural shift is recognized only when price definitively breaches and sustains its position relative to these dynamic thresholds. This state-tracking ensures that the primary directional bias is maintained until a statistically significant reversal occurs, minimizing false positives during minor retracements.

[b]🎨 Visual Guide[/b]

[b]● Color-Coded Heatmap Candles[/b]
The primary visual feature is the complete transformation of the standard candlestick chart into a continuous heatmap. The colors directly correspond to the synchronized output of the trend direction and the normalized volatility metric.
[list]
[*] [b]Bullish Gradients:[/b] When the market establishes an upward bias, the candles transition through a cool-to-hot spectrum. Deep, cold colors represent low-volatility accumulation phases, while bright, hot neon colors signify intense, high-volatility bullish expansion.
[*] [b]Bearish Gradients:[/b] Conversely, downward structural shifts are mapped using a separate color spectrum. Dark, muted tones indicate slow, grinding bearish action, whereas vivid, hot colors highlight rapid, high-volatility sell-offs.
[*] [b]Neutral States:[/b] When the price resides within the core boundary parameters, demonstrating no clear directional dominance, the candles default to a flat, neutral gray to reduce visual noise.
[/list]

[b]● Signal Markers[/b]
[list]
[*] [b]Buy Labels:[/b] Distinct markers appear precisely below the price action when the engine confirms a definitive upward structural breach.
[*] [b]Sell Labels:[/b] Clear markers are printed above the price action upon the confirmation of a downward structural breach.
[/list]

[b]📖 How to Use[/b]

[b]● Interpreting the Heatmap[/b]
The most effective way to utilize this tool is to read the candle colors as a topographical map of market energy. A transition from a neutral state into a cold bullish or bearish color suggests the early formation of a trend. As the colors heat up and transition toward their neon extremes, it confirms that the directional move is being supported by expanding volatility, which often characterizes the most robust phase of a trend.

[b]● Managing Trend Exhaustion[/b]
Traders can monitor the intensity of the heatmap to gauge potential momentum decay. If a strong trend has been characterized by hot, neon colors, a gradual cooling off—where the colors revert to darker, colder shades—may indicate that the localized volatility is subsiding, suggesting potential consolidation or a pending structural shift.

[b]● Confirming Breakouts[/b]
The printed Buy and Sell labels serve as structural confirmation points. These markers are best utilized not in isolation, but in confluence with the heatmap. A signal label accompanied by an immediate transition into a high-volatility color spectrum carries significantly more analytical weight than a signal that remains mired in a cold or neutral visual state.

[b]⚙️ Inputs and Settings[/b]

[b]● Channel Settings[/b]
[list]
[*] [b]Channel Length:[/b] Determines the primary lookback window for establishing the core upper and lower boundaries. Increasing this value creates a wider, slower-moving channel, while decreasing it makes the system highly sensitive to recent price action.
[*] [b]Channel MA Type:[/b] Allows the user to apply different smoothing algorithms to the boundaries. Options range from the standard baseline to advanced weighting methods, providing precise control over signal reactivity.
[/list]

[b]● Analytics Settings[/b]
[list]
[*] [b]Squeeze/Z-Score Length:[/b] Defines the historical window used to evaluate the relative volatility. A longer length provides a smoother, more macro-level volatility assessment, while a shorter length makes the heatmap highly reactive to sudden micro-expansions.
[/list]

[b]● Candle Heatmap Settings[/b]
[list]
[*] [b]Bullish/Bearish Color Controls:[/b] Fully customizable inputs allowing the user to define the exact hex values for the cold and hot extremes of both the bullish and bearish spectrums.
[*] [b]Neutral Market Base:[/b] The default color applied when the market is bound within the channel without a confirmed directional state.
[/list]

[b]● Signal Settings[/b]
[list]
[*] [b]Label Colors:[/b] Configurable color selections for the printed Buy and Sell confirmation markers.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]● Topological Price Mapping[/b]
At a fundamental level, the script treats financial time-series data not as discrete data points, but as a continuous topological surface. By evaluating the highest and lowest ranges over a specified temporal window, it effectively creates a rolling bounding box that encapsulates the probable distribution of future price vectors. The application of sophisticated moving average algorithms to these boundaries acts as a low-pass filter, mathematically attenuating high-frequency noise and exposing the true underlying macroeconomic drift.

[b]● Non-Linear Variance Scaling[/b]
The most complex aspect of the engine is its approach to variance. Standard deviation on its own is an unbounded metric, making it difficult to utilize in a standardized visual format. The script solves this by isolating the width of the bounding box and comparing it against its own moving average and standard deviation. This transforms the raw width into a standardized probabilistic metric. 

[b]● The Sigmoidal Activation Function[/b]
To achieve the seamless visual gradient, this standardized variance must be mapped onto a finite plane. The engine employs a logistic function—specifically, a sigmoidal activation curve—to compress the unbounded variance data strictly between a 0 and 100 scale. This non-linear mapping ensures that the visual heatmap remains highly sensitive to subtle shifts around the mean, while gracefully asymptotically compressing extreme, outlier volatility spikes, thereby maintaining absolute visual coherence regardless of the asset's inherent behavior.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Smart Trend Flow Pro [MarkitTick]", overlay=true, max_labels_count=500, max_bars_back=500)

// ============================================================================
// Inputs — Channel Settings
// ============================================================================
int    length   = input.int(20, "Channel Length", minval=1, group="Channel Settings")

enum MaType
    None
    EMA
    DEMA
    TEMA
    HULL

MaType maType = input.enum(MaType.HULL, "Channel MA Type",
     tooltip="None = original Highest/Lowest channel. EMA/DEMA/TEMA/HULL smooth the channel boundaries for earlier, tighter signals.",
     group="Channel Settings")

int sqzLength = input.int(50, "Squeeze/Z-Score Length", minval=1, group="Analytics Settings")

// ============================================================================
// Inputs — Candle Heatmap
// ============================================================================
color c_bullCold = input.color(#004D40, "Bullish Low Volatility (Cold)",      group="Candle Heatmap Settings")
color c_bullHot  = input.color(#00FF00, "Bullish High Volatility (Hot/Neon)", group="Candle Heatmap Settings")
color c_bearCold = input.color(#4A148C, "Bearish Low Volatility (Cold)",      group="Candle Heatmap Settings")
color c_bearHot  = input.color(#FF0000, "Bearish High Volatility (Hot/Neon)", group="Candle Heatmap Settings")
color c_neutral  = input.color(#808080, "Neutral Market Base",                 group="Candle Heatmap Settings")

// ============================================================================
// Inputs — Signal Settings
// ============================================================================
color c_lblBuy  = input.color(#00FF00, "Buy Signal Label",  group="Signal Settings")
color c_lblSell = input.color(#FF0000, "Sell Signal Label", group="Signal Settings")

// ============================================================================
// Inputs — Dashboard Settings
// ============================================================================
string GRP_DASH       = "📊 Dashboard Settings"
color  dash_bg_color  = input.color(color.rgb(10, 10, 18, 5),    "Background Color", group=GRP_DASH)
color  dash_txt_color = input.color(color.rgb(220, 220, 235, 0), "Text Color",       group=GRP_DASH)

// ============================================================================
// Ticker
// ============================================================================
string clean_ticker = syminfo.prefix + ":" + syminfo.ticker

// ============================================================================
// Dashboard Helpers 
// ============================================================================
f_blockBar(float rawVal, float domainMax) =>
    float  pct = math.min(math.max(rawVal / domainMax * 100.0, 0.0), 100.0)
    int    n   = math.round(pct / 10.0)
    string s   = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s + " " + str.tostring(math.round(pct), "##0") + "%"

f_blockColor(float rawVal, float lo, float mid, float hi) =>
    rawVal >= hi  ? color.rgb(0, 255, 120) :
     rawVal >= mid ? color.rgb(80, 255, 0)  :
     rawVal >= lo  ? color.rgb(200, 200, 0) :
                     color.rgb(110, 110, 110)

// ============================================================================
// Seeded Manual EMA  
// ============================================================================
f_ema(series float src, simple int len) =>
    float alpha      = 2.0 / (len + 1)
    var float emaVal = na
    float seed       = ta.sma(src, len)
    emaVal := na(emaVal) ? seed : alpha * src + (1.0 - alpha) * emaVal[1]
    emaVal

// ============================================================================
// MA Smoothing
// ============================================================================
f_ma(series float src, simple int len, simple MaType t) =>
    float e1         = f_ema(src, len)
    float e2         = f_ema(e1,  len)
    float e3         = f_ema(e2,  len)
    simple int hLen  = math.max(1, int(math.round(math.sqrt(float(len)))))
    simple int hHalf = math.max(1, int(len / 2))
    t == MaType.DEMA ? 2.0 * e1 - e2 :
     t == MaType.TEMA ? 3.0 * e1 - 3.0 * e2 + e3 :
     t == MaType.HULL ? ta.wma(2.0 * ta.wma(src, hHalf) - ta.wma(src, len), hLen) :
     e1

// ============================================================================
// Base Channel
// ============================================================================
float baseUpper = ta.highest(high, length)
float baseLower = ta.lowest(low,  length)
float basis     = (baseUpper + baseLower) * 0.5

// ============================================================================
// Volatility Metrics
// ============================================================================
float chWidth    = basis != 0.0 ? ((baseUpper - baseLower) / basis) * 100.0 : 0.0
float avgChWidth = ta.sma(chWidth,   sqzLength)
float stdChWidth = ta.stdev(chWidth, sqzLength)
float zScore     = stdChWidth == 0.0 ? 0.0 : (chWidth - avgChWidth) / stdChWidth
float sigmoidVol = 100.0 / (1.0 + math.exp(-zScore))

// ============================================================================
// Signal Channel
// ============================================================================
bool  useMA    = maType != MaType.None
float sigUpper = useMA ? f_ma(high, length, maType) : baseUpper
float sigLower = useMA ? f_ma(low,  length, maType) : baseLower

// ============================================================================
// Signal Engine
// ============================================================================
bool breakLong  = close > sigUpper and close[1] <= sigUpper[1]
bool breakShort = close < sigLower and close[1] >= sigLower[1]

var int trendState = 0
trendState := breakLong ? 1 : breakShort ? -1 : trendState

bool stateChanged = trendState != trendState[1]
bool isBuySignal  = stateChanged and trendState == 1
bool isSellSignal = stateChanged and trendState == -1

// ============================================================================
// Signal Labels
// ============================================================================
var int _lastLblBar = -1
if barstate.isconfirmed
    if (isBuySignal or isSellSignal) and bar_index != _lastLblBar
        _lastLblBar    := bar_index
        string lblText  = isBuySignal ? "Buy"  : "Sell"
        color  lblColor = isBuySignal ? c_lblBuy : c_lblSell
        float  lblY     = isBuySignal ? low : high
        label.new(bar_index, lblY, lblText,
         color     = color.new(lblColor, 85),
         style     = isBuySignal ? label.style_label_up : label.style_label_down,
         textcolor = lblColor,
         size      = size.small)

// ============================================================================
// Heatmap Candles
// ============================================================================
color bullBodyGrad = color.from_gradient(sigmoidVol, 0, 100, c_bullCold, c_bullHot)
color bearBodyGrad = color.from_gradient(sigmoidVol, 0, 100, c_bearCold, c_bearHot)

int   displayTrend = close > sigUpper ? 1 : close < sigLower ? -1 : 0
color bodyColor    = displayTrend == 1 ? bullBodyGrad : displayTrend == -1 ? bearBodyGrad : c_neutral
color borderColor  = bodyColor

plotcandle(open, high, low, close,
 title       = "Heatmap Candles",
 color       = bodyColor,
 wickcolor   = borderColor,
 bordercolor = borderColor)

// ============================================================================
// DASHBOARD — Metric Extraction & Normalization
// ============================================================================

bool   dashBullish  = trendState == 1
string dashTrendLbl = dashBullish ? "▲ Bull Trend" : "▼ Bear Trend"
color  dashTrendCol = dashBullish ? color.rgb(0, 255, 120) : color.rgb(255, 60, 80)

bool   dashAbove     = close > sigUpper
bool   dashBelow     = close < sigLower
string dashRegimeLbl = dashAbove ? "📈 Above Channel" : dashBelow ? "📉 Below Channel" : "⚖️ Inside Channel"
color  dashRegimeCol = dashAbove ? color.rgb(0, 255, 120) : dashBelow ? color.rgb(255, 60, 80) : color.rgb(180, 180, 60)

string dashVolBar = f_blockBar(sigmoidVol, 100.0)
color  dashVolCol = f_blockColor(sigmoidVol, 15.0, 50.0, 75.0)

float  dashZRaw = zScore + 3.0
string dashZBar = f_blockBar(dashZRaw, 6.0)
color  dashZCol = f_blockColor(dashZRaw, 1.0, 3.0, 5.0)

string dashChWidthStr = str.tostring(chWidth, "#.##") + "%"
color  dashChWidthCol = color.rgb(200, 200, 60)

string dashUpperStr = str.tostring(sigUpper, format.mintick)

string dashLowerStr = str.tostring(sigLower, format.mintick)

string dashBasisStr = str.tostring(basis, format.mintick)
color  dashPriceCol = color.rgb(200, 200, 60)

string dashMAMode = useMA ? "🔁 " + str.tostring(maType) : "○ Raw H/L"
color  dashMACol  = useMA ? color.rgb(0, 200, 255) : color.rgb(160, 160, 160)

var int _barsFromSignal = 0
_barsFromSignal := (isBuySignal or isSellSignal) ? 0 : _barsFromSignal + 1
string dashBarsSigStr = "⏳ " + str.tostring(_barsFromSignal) + " Bars"
color  dashBarsSigCol = color.rgb(140, 180, 255)

// ============================================================================
// DASHBOARD — Table Declaration 
// ============================================================================
var table dash = table.new(position.top_right, 2, 11,
     border_width  = 1,
     border_color  = color.rgb(50, 50, 70, 20),
     frame_width   = 1,
     frame_color   = color.rgb(60, 60, 90, 10))

// ============================================================================
// DASHBOARD — Cell Population
// ============================================================================
color hdrBg = color.rgb(30, 30, 45, 10)
color altBg = color.rgb(20, 20, 25, 10)
color oddBg = dash_bg_color

table.cell(dash, 0, 0, "  Smart Trend Flow",
     bgcolor          = hdrBg,
     text_color       = color.rgb(180, 180, 220),
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 0, clean_ticker + " · " + timeframe.period,
     bgcolor          = hdrBg,
     text_color       = color.rgb(180, 180, 220),
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 1, "  Trend Bias",
     bgcolor          = altBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 1, dashTrendLbl,
     bgcolor          = altBg,
     text_color       = dashTrendCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 2, "  Price Regime",
     bgcolor          = oddBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 2, dashRegimeLbl,
     bgcolor          = oddBg,
     text_color       = dashRegimeCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 3, "  Volatility Heat",
     bgcolor          = altBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 3, dashVolBar,
     bgcolor          = altBg,
     text_color       = dashVolCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 4, "  Z-Score Intensity",
     bgcolor          = oddBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 4, dashZBar,
     bgcolor          = oddBg,
     text_color       = dashZCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 5, "  Channel Width",
     bgcolor          = altBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 5, dashChWidthStr,
     bgcolor          = altBg,
     text_color       = dashChWidthCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 6, "  Channel Upper",
     bgcolor          = oddBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 6, dashUpperStr,
     bgcolor          = oddBg,
     text_color       = dashPriceCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 7, "  Channel Lower",
     bgcolor          = altBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 7, dashLowerStr,
     bgcolor          = altBg,
     text_color       = dashPriceCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 8, "  MA Mode",
     bgcolor          = oddBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 8, dashMAMode,
     bgcolor          = oddBg,
     text_color       = dashMACol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 9, "  Since Signal",
     bgcolor          = altBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 9, dashBarsSigStr,
     bgcolor          = altBg,
     text_color       = dashBarsSigCol,
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)

table.cell(dash, 0, 10, "  Channel Basis",
     bgcolor          = oddBg,
     text_color       = dash_txt_color,
     text_halign      = text.align_left,
     text_font_family = font.family_monospace,
     text_size        = size.small)
table.cell(dash, 1, 10, dashBasisStr,
     bgcolor          = oddBg,
     text_color       = color.rgb(200, 200, 60),
     text_halign      = text.align_right,
     text_font_family = font.family_monospace,
     text_size        = size.small)
````
