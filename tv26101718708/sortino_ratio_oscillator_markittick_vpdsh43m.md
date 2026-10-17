# Sortino Ratio Oscillator [MarkitTick]

- url: https://www.tradingview.com/script/VPdSH43M-Sortino-Ratio-Oscillator-MarkitTick/
- type: indicator
- pine_id: PUB;c706f2474b304d24b3efa90bd8fa69e2
- version: 1.0

## Description

💡 The Sortino Ratio Oscillator introduces a sophisticated, risk-adjusted performance metric typically reserved for portfolio analysis, adapting it into a highly responsive momentum oscillator. By strictly penalizing downside volatility while rewarding upside momentum, it provides a much clearer picture of market strength compared to traditional oscillators that treat all volatility equally.

[b]✨ Originality and Utility[/b]
Standard momentum indicators measure the velocity of price movement based on general variance. However, traditional models penalize both upside and downside volatility. A massive bullish breakout creates "high volatility," which standard indicators often misinterpret as an overextended or risky market condition. 

This script resolves that inherent flaw by migrating the academic Sortino Ratio into a technical trading framework. It isolates "bad" volatility (price drops) from "good" volatility (price gains). The utility here is immense: traders can identify trends where the price action is genuinely supported by positive risk-adjusted returns, filtering out noisy markets where the downside deviation is too high. Furthermore, this tool features an integrated divergence detection engine, dynamic histogram coloring, and built-in webhook alert formatting, making it a comprehensive suite for algorithmic and discretionary traders alike.

[b]🔬 Methodology and Concepts[/b]
The core engine of this indicator relies on continuously assessing the bar-to-bar percentage return of the asset.

[list]
[*]First, it calculates the raw percentage return between the current close and the previous close.
[*]Next, it isolates the downside returns. If a return is positive, it is ignored for the risk calculation (treated as zero). If it is negative, it is squared to emphasize larger drawdowns, following standard variance practices.
[*]The script then computes the Simple Moving Average of these squared negative returns over a user-defined lookback window, calculating the square root to determine the final Downside Deviation.
[*]Simultaneously, the Simple Moving Average of the raw returns is calculated to find the mean return over the same period.
[*]The final Sortino Ratio is produced by dividing the mean return by the downside deviation.
[*]To smooth the output and generate actionable crossovers, a secondary Signal Line is derived by applying an average to the raw Sortino Ratio.
[/list]

To enhance the analytical depth, the script incorporates a robust divergence engine that scans for pivot highs and lows over a customizable lookback window. By comparing price action pivots with the oscillator's momentum peaks and troughs, it systematically maps out both regular and hidden divergences.

[b]🎨 Visual Guide[/b]
The visual presentation is meticulously structured to provide instant clarity on risk-adjusted momentum states.

[b]• The Sortino Histogram[/b]
The core oscillator is plotted as a multi-colored histogram. It utilizes a four-state coloring system to indicate momentum shifts:
[list]
[*]Solid Bull Color: The ratio is above zero and rising, indicating accelerating positive risk-adjusted returns.
[*]Transparent Bull Color: The ratio is above zero but falling, suggesting positive momentum is decelerating.
[*]Solid Bear Color: The ratio is below zero and falling, indicating accelerating downside risk.
[*]Transparent Bear Color: The ratio is below zero but rising, showing that downside risk is waning.
[/list]

[b]• Signal Line and Cloud Fill[/b]
A highlighted Signal Line tracks the moving average of the Sortino Ratio. The space between the Sortino histogram and the Signal Line is filled with a dynamic cloud, helping traders easily spot shifts in immediate trend strength.

[b]• Threshold Lines[/b]
Dashed lines represent the Overbought and Oversold thresholds. A solid gray line marks the Zero Level, acting as the primary baseline for positive versus negative risk-adjusted states.

[b]• Divergence Mapping[/b]
[list]
[*]Regular Bullish (RB): Displayed as a solid line connecting price lows to oscillator lows, complete with a label below the candle.
[*]Hidden Bullish (HB): Displayed as a dashed line, indicating trend continuation.
[*]Regular Bearish (RD): Displayed as a solid line connecting price highs to oscillator highs.
[*]Hidden Bearish (HD): Displayed as a dashed line.
[/list]

[b]• Candle Coloring[/b]
When enabled, the price chart's candles are painted to match the four-state color logic of the Sortino Histogram, linking the oscillator's data directly to the price action on the main chart.

[b]📖 How to Use[/b]
Traders can interpret the Sortino Ratio Oscillator through several distinct frameworks depending on their trading style.

[b]• Zero-Line Crossovers[/b]
A baseline shift occurs when the histogram crosses the zero line. A cross into positive territory confirms that the average returns now outweigh the downside deviation, signaling a structurally sound bullish environment. Conversely, a drop below zero warns that downside volatility is dominating the asset's behavior.

[b]• Signal Line Interactions[/b]
Watch for the histogram to cross the Signal Line. When the Sortino Ratio spikes above its signal line, momentum is expanding. When it crosses below, it often precedes a consolidation or a reversal, as highlighted by the cloud fill changing colors.

[b]• Extremes and Reversals[/b]
The Overbought and Oversold threshold lines act as exhaustion markers. An asset sustaining a Sortino Ratio above the Overbought level is exhibiting unusually high, unpenalized upside movement. While strong, traders should watch for the histogram to peak and cross back below the Signal Line as an early warning of a pullback.

[b]• Trading Divergences[/b]
Divergences are perhaps the most powerful signals generated by this tool. Look for Regular Bullish Divergences when the price makes a lower low, but the Sortino Ratio makes a higher low. This indicates that despite the price drop, the underlying downside volatility is shrinking relative to the mean return, hinting at a bottom. Hidden Divergences are excellent for trading pullbacks in the direction of the macro trend.

[b]⚙️ Inputs and Settings[/b]

[b]• Sortino Settings[/b]
[list]
[*]Lookback Length: Defines the period used to calculate the mean return and downside deviation. A shorter length is highly reactive, while a longer length provides macroscopic trend stability.
[*]Signal Length: Adjusts the smoothness of the Signal Line.
[*]Overbought / Oversold Levels: Customizes the threshold lines for extreme readings.
[/list]

[b]• Candle Coloring[/b]
A simple toggle to enable or disable the dynamic coloring of the main chart price candles based on the oscillator's state.

[b]• Divergence Settings[/b]
[list]
[*]Enable Divergence: Master toggle for the divergence engine.
[*]Show Regular / Hidden: Independent toggles to filter specific divergence types.
[*]Pivot Lookback Left / Right: Determines the strictness of the pivot point detection. Higher values require more significant peaks and troughs to form a valid pivot, filtering out noise.
[/list]

[b]• Webhook Action Names[/b]
Customizable string inputs allowing algorithmic traders to map specific script events directly to JSON payloads for automated execution platforms.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The Sortino Ratio, developed by Dr. Frank A. Sortino, is a vital modification of the Sharpe Ratio. In Modern Portfolio Theory, the Sharpe Ratio evaluates the performance of an investment by adjusting for its risk, defined universally as the standard deviation of its returns. However, standard deviation measures total volatility, treating an unexpected positive gain exactly the same as a negative loss. 

This oscillator resolves that mathematical paradox by isolating downside deviation. The scientific framework dictates that a minimum acceptable return—in this script's case, zero—must be established. Only returns falling strictly below this threshold are aggregated and squared to calculate the downside variance. By exclusively measuring the standard deviation of negative asset returns, the formula effectively removes the penalty for upside volatility. 

In a purely academic sense, a high Sortino Ratio mathematically proves that the asset is generating its returns without suffering significant, erratic drawdowns. Translated into technical analysis, when the indicator rises, it mathematically proves that the ratio of upward momentum relative to downward variance is expanding. This makes it an incredibly robust statistical measure, completely immune to the standard look-around bias of typical mathematical oscillators that collapse under the weight of sudden, positive price shocks.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Sortino Ratio Oscillator [MarkitTick]", overlay=false, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// USER-DEFINED TYPE
// ═══════════════════════════════════════════════════════════════════════════════

type DivState
    float pivot_price   = na
    float pivot_sortino = na
    int   pivot_index   = na
    bool  confirmed     = false

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 0 — COLOR SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_COLOR = "Color Settings"
color C_BULL    = input.color(#0b7788, "Bull",        group=GRP_COLOR, inline="main")
color C_BEAR    = input.color(#9f0808, "Bear",        group=GRP_COLOR, inline="main")
color C_SIG     = input.color(#FF8C00, "Signal Line", group=GRP_COLOR, inline="sig")
color C_BIAS_LO = input.color(#FF1744, "Bias Low",    group=GRP_COLOR, inline="sig")

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 1 — SORTINO SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_SORT = "Sortino Settings"
int   cfg_length  = input.int(20,    "Lookback Length",  minval=2,  group=GRP_SORT)
int   cfg_sig_len = input.int(9,     "Signal Length",    minval=1,  group=GRP_SORT)
float cfg_ob      = input.float(1.5, "Overbought Level", step=0.1,  group=GRP_SORT)
float cfg_os      = input.float(-1.5,"Oversold Level",   step=0.1,  group=GRP_SORT)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 2 — CANDLE COLORING
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_CANDLE = "Candle Coloring"
bool cfg_candle_on = input.bool(true, "Enable Candle Coloring", group=GRP_CANDLE)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 3 — DIVERGENCE SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_DIV = "Divergence Settings"
bool cfg_div_on      = input.bool(true, "Enable Divergence",         group=GRP_DIV)
bool cfg_div_regular = input.bool(true, "Show Regular  (RB / RD)",   group=GRP_DIV)
bool cfg_div_hidden  = input.bool(true, "Show Hidden   (HB / HD)",   group=GRP_DIV)
int  cfg_div_left    = input.int(5,     "Pivot Lookback Left",  minval=1, maxval=50, group=GRP_DIV)
int  cfg_div_right   = input.int(5,     "Pivot Lookback Right", minval=1, maxval=50, group=GRP_DIV)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 4 — WEBHOOK ACTION NAMES
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_WH = "Webhook Action Names"
string cfg_act_cross_above_zero = input.string("sortino_cross_above_zero", "Cross Above Zero",     group=GRP_WH)
string cfg_act_cross_below_zero = input.string("sortino_cross_below_zero", "Cross Below Zero",     group=GRP_WH)
string cfg_act_cross_above_ob   = input.string("sortino_cross_above_ob",   "Cross Above OB Level", group=GRP_WH)
string cfg_act_cross_below_os   = input.string("sortino_cross_below_os",   "Cross Below OS Level", group=GRP_WH)
string cfg_act_reg_bull         = input.string("sortino_reg_bull_div",     "Regular Bull Div",     group=GRP_WH)
string cfg_act_reg_bear         = input.string("sortino_reg_bear_div",     "Regular Bear Div",     group=GRP_WH)
string cfg_act_hid_bull         = input.string("sortino_hid_bull_div",     "Hidden Bull Div",      group=GRP_WH)
string cfg_act_hid_bear         = input.string("sortino_hid_bear_div",     "Hidden Bear Div",      group=GRP_WH)

// ═══════════════════════════════════════════════════════════════════════════════
// CORE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

float ret          = (close - close[1]) / close[1]
float downside_ret = ret < 0.0 ? ret : 0.0
float mean_ret     = ta.sma(ret,                         cfg_length)
float downside_sq  = ta.sma(downside_ret * downside_ret, cfg_length)
float downside_dev = math.sqrt(downside_sq)
float sortino      = downside_dev != 0.0 ? mean_ret / downside_dev : na
float sig          = ta.sma(sortino, cfg_sig_len)

bool valid_hist       = not na(sortino[1]) and not na(sortino[2])
bool cross_above_zero = valid_hist and sortino[1] > 0.0    and sortino[2] <= 0.0
bool cross_below_zero = valid_hist and sortino[1] < 0.0    and sortino[2] >= 0.0
bool cross_above_ob   = valid_hist and sortino[1] > cfg_ob and sortino[2] <= cfg_ob
bool cross_below_os   = valid_hist and sortino[1] < cfg_os and sortino[2] >= cfg_os

// ═══════════════════════════════════════════════════════════════════════════════
// OSCILLATOR VISUALS
// ═══════════════════════════════════════════════════════════════════════════════

bool  valid_sortino = not na(sortino)
bool  is_rising     = valid_sortino and not na(sortino[1]) and sortino > sortino[1]
color hist_color =
     valid_sortino and sortino >= 0.0 and is_rising      ? color.new(C_BULL, 0)  :
     valid_sortino and sortino >= 0.0 and not is_rising  ? color.new(C_BULL, 45) :
     valid_sortino and sortino <  0.0 and not is_rising  ? color.new(C_BEAR, 0)  :
     color.new(C_BEAR, 45)

plot(sortino, "Sortino Histogram", color=hist_color, style=plot.style_histogram, linewidth=4)

p_sortino_fill = plot(sortino, "Sortino (Fill Ref)", color=na, display=display.none)
p_signal       = plot(sig,     "Signal Line",        color=C_SIG, linewidth=2)

color cloud_color = valid_sortino and not na(sig) and sortino > sig ? color.new(C_BULL, 75) : color.new(C_BEAR, 75)
fill(p_sortino_fill, p_signal, color=cloud_color, title="Sortino/Signal Cloud")

hline(0,      "Zero Line",  color=color.new(color.gray, 50), linestyle=hline.style_solid,  linewidth=1)
hline(cfg_ob, "Overbought", color=color.new(#0b7788, 40),    linestyle=hline.style_dashed, linewidth=1)
hline(cfg_os, "Oversold",   color=color.new(#9f0808, 40),    linestyle=hline.style_dashed, linewidth=1)

// ═══════════════════════════════════════════════════════════════════════════════
// PIVOT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

f_pivotHigh(series float src, simple int left, simple int right) =>
    float candidate = src[right]
    bool  isValid   = not na(candidate)
    if isValid
        for i = 1 to right + left
            if i != right and not na(src[i]) and src[i] >= candidate
                isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int left, simple int right) =>
    float candidate = src[right]
    bool  isValid   = not na(candidate)
    if isValid
        for i = 1 to right + left
            if i != right and not na(src[i]) and src[i] <= candidate
                isValid := false
    isValid ? candidate : na

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

var DivState bull_state = DivState.new()
var DivState bear_state = DivState.new()

float ph_price = f_pivotHigh(close, cfg_div_left, cfg_div_right)
float pl_price = f_pivotLow(close,  cfg_div_left, cfg_div_right)

float ph_sortino = sortino[cfg_div_right]
float pl_sortino = sortino[cfg_div_right]

bool new_ph = not na(ph_price) and not na(ph_sortino)
bool new_pl = not na(pl_price) and not na(pl_sortino)

int actual_ph_idx = bar_index - cfg_div_right
int actual_pl_idx = bar_index - cfg_div_right

float snap_bear_price   = bear_state.pivot_price
float snap_bear_sortino = bear_state.pivot_sortino
int   snap_bear_idx     = bear_state.pivot_index

float snap_bull_price   = bull_state.pivot_price
float snap_bull_sortino = bull_state.pivot_sortino
int   snap_bull_idx     = bull_state.pivot_index

bool reg_bear_div = false   
bool hid_bear_div = false   

if cfg_div_on and new_ph
    if not na(snap_bear_price) and not na(snap_bear_sortino)
        if cfg_div_regular and ph_price > snap_bear_price and ph_sortino < snap_bear_sortino
            reg_bear_div := true
        if cfg_div_hidden  and ph_price < snap_bear_price and ph_sortino > snap_bear_sortino
            hid_bear_div := true
    bear_state.pivot_price   := ph_price
    bear_state.pivot_sortino := ph_sortino
    bear_state.pivot_index   := actual_ph_idx
    bear_state.confirmed     := true

bool reg_bull_div = false   
bool hid_bull_div = false   

if cfg_div_on and new_pl
    if not na(snap_bull_price) and not na(snap_bull_sortino)
        if cfg_div_regular and pl_price < snap_bull_price and pl_sortino > snap_bull_sortino
            reg_bull_div := true
        if cfg_div_hidden  and pl_price > snap_bull_price and pl_sortino < snap_bull_sortino
            hid_bull_div := true
    bull_state.pivot_price   := pl_price
    bull_state.pivot_sortino := pl_sortino
    bull_state.pivot_index   := actual_pl_idx
    bull_state.confirmed     := true


if reg_bull_div and not na(snap_bull_idx)
    line.new(snap_bull_idx, snap_bull_price, actual_pl_idx, pl_price,
             color=C_BULL, style=line.style_solid, width=2, force_overlay=true)
    label.new(actual_pl_idx, pl_price, "RB",
              color=color.new(C_BULL, 15), textcolor=color.white,
              style=label.style_label_up, size=size.small, force_overlay=true)

if hid_bull_div and not na(snap_bull_idx)
    line.new(snap_bull_idx, snap_bull_price, actual_pl_idx, pl_price,
             color=color.new(C_BULL, 40), style=line.style_dashed, width=1, force_overlay=true)
    label.new(actual_pl_idx, pl_price, "HB",
              color=color.new(C_BULL, 45), textcolor=color.white,
              style=label.style_label_up, size=size.small, force_overlay=true)

if reg_bear_div and not na(snap_bear_idx)
    line.new(snap_bear_idx, snap_bear_price, actual_ph_idx, ph_price,
             color=C_BEAR, style=line.style_solid, width=2, force_overlay=true)
    label.new(actual_ph_idx, ph_price, "RD",
              color=color.new(C_BEAR, 15), textcolor=color.white,
              style=label.style_label_down, size=size.small, force_overlay=true)

if hid_bear_div and not na(snap_bear_idx)
    line.new(snap_bear_idx, snap_bear_price, actual_ph_idx, ph_price,
             color=color.new(C_BEAR, 40), style=line.style_dashed, width=1, force_overlay=true)
    label.new(actual_ph_idx, ph_price, "HD",
              color=color.new(C_BEAR, 45), textcolor=color.white,
              style=label.style_label_down, size=size.small, force_overlay=true)

// ═══════════════════════════════════════════════════════════════════════════════
// CANDLE COLORING 
// ═══════════════════════════════════════════════════════════════════════════════

plotcandle(cfg_candle_on ? open  : na,
           cfg_candle_on ? high  : na,
           cfg_candle_on ? low   : na,
           cfg_candle_on ? close : na,
           title="Price Candles",
           color=hist_color, wickcolor=hist_color, bordercolor=hist_color,
           force_overlay=true)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERT ENGINE 
// ═══════════════════════════════════════════════════════════════════════════════

var string JSON_TPL = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "entry": "{3}", "tp": "{4}", "sl": "{5}", "sortino": {6}, "signal": {7}'

f_buildAlert(string action_name) =>
    float entryPrice = close
    float tpPrice    = 0.0
    float slPrice    = 0.0
    string inner_json = str.format(
         JSON_TPL,
         action_name,
         syminfo.tickerid,
         timeframe.period,
         str.tostring(entryPrice, format.mintick),
         str.tostring(tpPrice,    format.mintick),
         str.tostring(slPrice,    format.mintick),
         str.tostring(sortino,    format.mintick),
         str.tostring(sig,        format.mintick))
    "{" + inner_json + "}"

if cross_above_zero and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_cross_above_zero), alert.freq_once_per_bar_close)
if cross_below_zero and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_cross_below_zero), alert.freq_once_per_bar_close)
if cross_above_ob and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_cross_above_ob), alert.freq_once_per_bar_close)
if cross_below_os and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_cross_below_os), alert.freq_once_per_bar_close)
if reg_bull_div and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_reg_bull), alert.freq_once_per_bar_close)
if reg_bear_div and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_reg_bear), alert.freq_once_per_bar_close)
if hid_bull_div and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_hid_bull), alert.freq_once_per_bar_close)
if hid_bear_div and barstate.isconfirmed
    alert(f_buildAlert(cfg_act_hid_bear), alert.freq_once_per_bar_close)
````
