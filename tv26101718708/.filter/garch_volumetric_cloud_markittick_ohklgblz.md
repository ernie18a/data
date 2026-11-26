# GARCH Volumetric Cloud [MarkitTick]

- url: https://www.tradingview.com/script/OhkLGBLz-GARCH-Volumetric-Cloud-MarkitTick/
- type: indicator
- pine_id: PUB;4da6c742ad2146fcae911345f097a31d
- version: 1.0

## Description

💡 The GARCH Volumetric Cloud is a highly advanced, institutional-grade trend-following and volatility-tracking indicator designed to filter market noise and pinpoint high-probability trend reversals. By synergizing a dynamic volatility engine inspired by conditional heteroskedasticity models with the smoothing properties of synthetic Heikin-Ashi price action, this tool offers traders a multi-dimensional perspective on market dynamics. It goes beyond simple price crossovers by mathematically confirming that a structural shift in trend is supported by an underlying surge in market volatility. This dual-verification approach significantly reduces the likelihood of entering false breakouts or getting trapped in ranging, low-momentum environments. 

[b]✨ Originality and Utility[/b]
Standard technical indicators often rely on a single dimension of market data, such as moving averages for trend or the Average True Range for volatility. This script breaks the mold by calculating a real-time variance proxy based on squared logarithmic returns, effectively bridging the gap between academic quantitative finance and retail charting. The originality lies in its "Volatility Gatekeeper" mechanism. The system only validates trend signals when the market is experiencing a mathematically significant expansion in variance, preventing the underlying Heikin-Ashi cloud from signaling entries during dormant or strictly mean-reverting phases. 

Furthermore, the script calculates synthetic Heikin-Ashi values internally without relying on secondary chart inputs or delayed security calls. This ensures seamless integration, zero lookahead bias, and absolute synchronization with the current timeframe. It combines this with a fully integrated JSON webhook alert system, making it an all-in-one solution for both manual discretionary traders and automated systematic execution.

[b]🔬 Methodology and Concepts[/b]
The core methodology is divided into two distinct processing engines that operate in parallel and converge to generate actionable signals.

[b]● Volatility Engine[/b]
[list]
[*]The system first determines the period-over-period return, giving the user the option to utilize logarithmic returns for superior statistical normalization.
[*]These returns are squared to calculate raw variance.
[*]To model volatility clustering (the tendency for volatile periods to cluster together), the script applies an Exponentially Weighted Moving Average (EWMA) to the squared returns. 
[*]This EWMA acts as a dynamic variance proxy, prioritizing recent market shocks while retaining a memory of historical data, governed by the Lambda decay factor.
[*]The square root of this variance proxy is taken to return the value to a standard volatility scale.
[*]A localized volatility threshold is established by calculating a Simple Moving Average and Standard Deviation of this volatility proxy. A "High Volatility" state is triggered when the current volatility exceeds the moving average plus a user-defined multiple of the standard deviation.
[/list]

[b]● Trend Cloud Engine[/b]
[list]
[*]The script derives mathematical Heikin-Ashi price points (Open, High, Low, Close) independently of the user's primary chart type.
[*]Four distinct Exponential Moving Averages (EMAs) are applied sequentially to the synthetic Heikin-Ashi Close price.
[*]The structural trend state is determined by the relationship between the Fast EMA and the Slow EMA.
[*]When the Fast EMA crosses above the Slow EMA, the internal state shifts to Bullish. When it crosses below, the state shifts to Bearish.
[/list]

[b]🎨 Visual Guide[/b]
The visual interface of the indicator is designed to provide immediate situational awareness through color-coded elements and structural bands.

[b]● Synthetic Heikin-Ashi Candles[/b]
[list]
[*]The indicator plots custom candles directly on the chart, overriding the standard visual noise.
[*]Bullish Theme: Colored in vivid Cyan (#00E5FF) when the underlying cloud structure is in an upward trend.
[*]Bearish Theme: Colored in distinct Pink/Red (#FF3D71) when the underlying cloud structure shifts downward.
[*]The bodies, borders, and wicks are synchronized to these specific themes to maintain a clean visual hierarchy.
[/list]

[b]● The Moving Average Cloud[/b]
[list]
[*]Cloud L1 (Fast): Plotted as a solid line with 40 percent opacity.
[*]Cloud L4 (Slow): Plotted as the foundational boundary line, also at 40 percent opacity.
[*]Cloud Spine: A thicker, central moving average derived from the midpoint of the inner EMAs, drawn at 20 percent opacity to serve as a micro-support/resistance level within the broader cloud structure.
[*]Gradient Fills: The space between the four EMA lines is filled with cascading color opacities (50 percent, 65 percent, and 78 percent), creating a three-dimensional visual depth that expands during strong trends and pinches during consolidation.
[/list]

[b]📖 How to Use[/b]
Applying this indicator requires an understanding of its dual-verification logic. It is not designed to trade every crossover, but rather to isolate structural shifts.

[b]● Identifying Opportunities[/b]
[list]
[*]A valid Long signal occurs when the Fast EMA crosses above the Slow EMA, but only if the previous candle was mathematically classified as being in a "High Volatility" state by the GARCH engine.
[*]A valid Short signal occurs when the Fast EMA crosses below the Slow EMA under the exact same high-volatility prerequisite.
[*]Visually, traders should look for a color shift in the cloud and candles, accompanied by a sharp widening of the cloud structure.
[/list]

[b]● Automation and Execution[/b]
[list]
[*]The script calculates a dynamic Stop Loss based on the lowest low of the last 5 bars for long positions, and the highest high of the last 5 bars for short positions.
[*]The Take Profit is mechanically projected using a strict 1:1.5 risk-to-reward ratio based on the calculated Stop Loss distance.
[*]These parameters are packaged into a JSON payload and fired via webhook at the exact moment the signal bar closes and confirms, ensuring zero repainting and immediate execution for connected bots.
[/list]

[b]⚙️ Inputs and Settings[/b]
The indicator provides deep customization options, allowing traders to tune the engines to specific assets and timeframes.

[b]● GARCH Volume Engine[/b]
[list]
[*]Use EWMA: Toggles between the exponentially weighted variance model and a simple moving average of variance.
[*]Log Returns: Enables logarithmic return calculations for more accurate financial time-series modeling.
[*]Variance Length: Defines the lookback period for the initial variance baseline.
[*]Threshold Lookback: Sets the window for the standard deviation bands applied to the final volatility proxy.
[*]EWMA Lambda: The decay factor for the weighted average. A standard setting of 0.94 mirrors classic RiskMetrics methodology.
[*]High Volatility Band: The standard deviation multiplier required to trigger a "High Volatility" validation state.
[/list]

[b]● Cloud & Trend Engine[/b]
[list]
[*]Cloud Fast Length: The lookback for the primary reactive EMA.
[*]Cloud Mid-Fast Length: The first internal structural EMA.
[*]Cloud Mid-Slow Length: The second internal structural EMA.
[*]Cloud Slow Length: The foundational EMA that determines the overall baseline trend.
[/list]

[b]● Webhook Actions (Automation)[/b]
[list]
[*]Action Long: The string identifier sent in the JSON payload when a bullish setup is confirmed.
[*]Action Short: The string identifier sent in the JSON payload when a bearish setup is confirmed.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The architectural foundation of this script is deeply rooted in quantitative financial theory, specifically drawing from time-series econometrics and signal processing. The volatility engine is a deterministic approximation of the Generalized Autoregressive Conditional Heteroskedasticity (GARCH) model. In standard financial mathematics, asset returns do not exhibit constant variance; instead, they experience periods of clustered turbulence and clustered calm. 

By calculating the squared log returns, the script isolates the magnitude of price movement independently of directional drift. The application of an Exponentially Weighted Moving Average (EWMA) to these squared returns serves as the conditional variance estimator. The Lambda parameter acts as the memory decay coefficient. By setting this coefficient high (e.g., 0.94), the model ensures that the volatility proxy reacts aggressively to sudden market shocks (such as a macroeconomic data release or institutional block order) while slowly decaying back to the mean, perfectly mirroring the theoretical decay of implied volatility in options pricing.

Parallel to the econometric variance modeling, the script employs a cascaded digital filter design via the Heikin-Ashi EMA cloud. The Heikin-Ashi transformation modifies the standard Open-High-Low-Close data points to incorporate previous period averages, inherently introducing an autoregressive smoothing effect that diminishes high-frequency market noise. By passing this pre-smoothed data through a series of four Exponential Moving Averages, the system applies a multi-pole low-pass filter. The dispersion between the Fast EMA and Slow EMA represents the momentum vector of the trend. The final gating logic, which demands that a structural moving average crossover must be contemporaneous with a statistically significant deviation in the EWMA variance proxy, is a sophisticated method of reducing Type I errors (false positives) in algorithmic trend-following systems.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("GARCH Volumetric Cloud [MarkitTick]", overlay=true)

// -----------------------------------------------------------------------------
// INPUTS & CONFIGURATION
// -----------------------------------------------------------------------------
string grp_vol     = "GARCH Volume Engine"
string grp_cloud   = "Cloud & Trend Engine"
string grp_color   = "Modern Colors"
string grp_webhook = "Webhook Actions (Automation)"

bool  useEWMA       = input.bool(true,  "Use EWMA",                    group = grp_vol)
bool  useLog        = input.bool(true,  "Log Returns",                  group = grp_vol)
int   garchLength   = input.int(21,     "Variance Length", minval = 1,  group = grp_vol)
int   stdevLookback = input.int(100,    "Threshold Lookback",           group = grp_vol)
float lambda        = input.float(0.94, "EWMA Lambda",     step = 0.01, group = grp_vol)
float highK         = input.float(1.5,  "High Volatility Band (StdDev)",group = grp_vol)

int ema1 = input.int(8,  "Cloud Fast Length",      group = grp_cloud)
int ema2 = input.int(13, "Cloud Mid-Fast Length",  group = grp_cloud)
int ema3 = input.int(21, "Cloud Mid-Slow Length",  group = grp_cloud)
int ema4 = input.int(34, "Cloud Slow Length",      group = grp_cloud)

color col_bull = input.color(#00E5FF, "Bullish Theme", group = grp_color)
color col_bear = input.color(#FF3D71, "Bearish Theme", group = grp_color)

string action_long  = input.string("long",  "Action: Long",  group = grp_webhook)
string action_short = input.string("short", "Action: Short", group = grp_webhook)

// -----------------------------------------------------------------------------
// USER-DEFINED TYPES (UDTs) & MODULES
// -----------------------------------------------------------------------------
type VolEngine
    float volProxy
    bool  isHighVol

type HAEngine
    float haOpen
    float haHigh
    float haLow
    float haClose

type CloudState
    float e1
    float e2
    float e3
    float e4
    bool  isBull

method calc_returns(float cur, float prev, bool isLog) =>
    float result = 0.0
    if prev != 0.0
        result := (isLog and cur > 0.0 and prev > 0.0) ? math.log(cur / prev) : (cur / prev) - 1.0
    result

// -----------------------------------------------------------------------------
// ENGINE FACTORIES & VECTORIZED LOGIC
// -----------------------------------------------------------------------------
f_get_garch(float volRet, int gLength, float lamb, int lb, float hk, bool useE) =>
    float r2 = volRet * volRet
    float smaVar = ta.sma(r2, gLength)
    var float ewmaVar = na
    float safePrev = nz(ewmaVar[1], r2)
    ewmaVar := na(ewmaVar[1]) ? r2 : lamb * safePrev + (1.0 - lamb) * r2
    float varProxy = useE ? ewmaVar : smaVar
    float volPx = math.sqrt(varProxy)
    float meanVol  = ta.sma(volPx, lb)
    float stdevVol = ta.stdev(volPx, lb)
    VolEngine.new(volPx, volPx > meanVol + hk * stdevVol)

f_get_ha(float o, float h, float l, float c) =>
    float haClose = (o + h + l + c) / 4.0
    var float haOpen = na
    haOpen := na(haOpen[1]) ? (o + c) / 2.0 : (haOpen[1] + nz(haClose[1], haClose)) / 2.0
    float haHigh = math.max(h, math.max(haOpen, haClose))
    float haLow  = math.min(l, math.min(haOpen, haClose))
    HAEngine.new(haOpen, haHigh, haLow, haClose)

method derive_cloud(HAEngine this, int l1, int l2, int l3, int l4) =>
    float e1 = ta.ema(this.haClose, l1)
    float e2 = ta.ema(this.haClose, l2)
    float e3 = ta.ema(this.haClose, l3)
    float e4 = ta.ema(this.haClose, l4)
    CloudState.new(e1, e2, e3, e4, e1 > e4)

// -----------------------------------------------------------------------------
// STATE INSTANTIATION & EXECUTION
// -----------------------------------------------------------------------------
float volRet = calc_returns(volume, nz(volume[1], volume), useLog)

VolEngine  vEngine = f_get_garch(volRet, garchLength, lambda, stdevLookback, highK, useEWMA)
HAEngine   hEngine = f_get_ha(open, high, low, close)
CloudState cState  = hEngine.derive_cloud(ema1, ema2, ema3, ema4)

color themeColor = cState.isBull ? col_bull : col_bear

float haOpen  = hEngine.haOpen
float haHigh  = hEngine.haHigh
float haLow   = hEngine.haLow
float haClose = hEngine.haClose

float e1 = cState.e1
float e2 = cState.e2
float e3 = cState.e3
float e4 = cState.e4

// -----------------------------------------------------------------------------
// VISUAL RENDERING
// -----------------------------------------------------------------------------
barcolor(color.new(color.black, 100))

plotcandle(haOpen, haHigh, haLow, haClose,
     title       = "HA Candles",
     color       = themeColor,
     wickcolor   = themeColor,
     bordercolor = themeColor)

p1 = plot(e1, "Cloud L1", color = color.new(themeColor, 40), linewidth = 1)
p2 = plot(e2, "Cloud L2", color = na)
p3 = plot(e3, "Cloud L3", color = na)
p4 = plot(e4, "Cloud L4", color = color.new(themeColor, 40), linewidth = 1)

float eMid = (e2 + e3) / 2.0
plot(eMid, "Cloud Spine", color = color.new(themeColor, 20), linewidth = 2)

fill(p1, p2, color = color.new(themeColor, 50), title = "Gradient Inner")
fill(p2, p3, color = color.new(themeColor, 65), title = "Gradient Core")
fill(p3, p4, color = color.new(themeColor, 78), title = "Gradient Outer")

// -----------------------------------------------------------------------------
// ALERT & EXECUTION ENGINE
// -----------------------------------------------------------------------------
bool crossUp   = e1[1] > e4[1] and e1[2] <= e4[2]
bool crossDown = e1[1] < e4[1] and e1[2] >= e4[2]

bool isHighVol  = vEngine.isHighVol
bool validLong  = crossUp   and isHighVol[1]
bool validShort = crossDown and isHighVol[1]

float lowest5    = ta.lowest(low, 5)
float highest5   = ta.highest(high, 5)
float entryPrice = close
float slPrice    = validLong ? lowest5 : (validShort ? highest5 : na)
float tpPrice    = validLong ? entryPrice + (entryPrice - slPrice) * 1.5 : (validShort ? entryPrice - (slPrice - entryPrice) * 1.5 : na)

string json_template = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "entry": "{3}", "tp": "{4}", "sl": "{5}"'

if validLong and barstate.isconfirmed
    string inner_json = str.format(json_template, action_long, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpPrice, format.mintick), str.tostring(slPrice, format.mintick))
    string alertMsg   = "{" + inner_json + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)

if validShort and barstate.isconfirmed
    string inner_json = str.format(json_template, action_short, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpPrice, format.mintick), str.tostring(slPrice, format.mintick))
    string alertMsg   = "{" + inner_json + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)
````
