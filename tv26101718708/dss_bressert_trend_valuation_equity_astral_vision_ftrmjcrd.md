# DSS Bressert - Trend, Valuation & Equity | Astral Vision 

- url: https://www.tradingview.com/script/FtRMJcRd/
- type: indicator
- pine_id: PUB;66a526e65d004a9d81f1fa6162d6658e
- version: 1.0

## Description

[b]DSS Bressert - Trend, Valuation & Equity | Astral Vision 🌠💠[/b]

The Double Smoothed Stochastic, developed by William Bressert, applies a double layer of EMA smoothing to a standard stochastic oscillator, producing a signal that is significantly less noisy than raw stochastics while retaining sensitivity to momentum shifts. 
The result oscillates between 0 and 100, with crossovers between the DSS line and its trigger EMA identifying trend changes at the selected resolution.

This indicator extends the standard DSS with three distinct analytical layers:
[list]
[*]Trend mode colors by bull/bear regime established at each DSS/trigger crossover, persisting the signal until the next cross. 
[*]Extremes mode activates only at overbought and oversold zones, filtering the middle ground.
[*]The Equity view simulates a long-only strategy that holds when the DSS is in a bullish regime and exits to cash otherwise, displaying a cumulative equity curve alongside the price chart, translating the signal's historical performance into a directly readable return series.
[/list]

[b]Calculation ⚙️[/b]

`xPreCalc = EMA(Stochastic(close, high, low, period), EMAlen)`

`DSS = EMA(Stochastic(xPreCalc, xPreCalc, xPreCalc, period), EMAlen)`

`Trigger = EMA(DSS, TriggerLen)`

A bull regime is established when DSS crosses above the trigger and persists until the next bearish cross. In No Repaint mode, crossover signals are shifted by one bar to prevent intrabar repainting. The equity curve compounds close-to-close returns only during confirmed bullish regime bars, starting from a user-defined year at a base value of 100.

[b]Plots 📊[/b]
[list]
[*]DSS line and trigger line in the indicator panel, colored by active mode and regime (Indicator view)
[*]Overbought and oversold threshold lines (Indicator view)
[*]Equity curve starting from the configured year (Equity view)
[*]Candle coloring on the price chart by DSS regime in both views
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`View`: Indicator (DSS oscillator) or Equity (cumulative strategy curve)
[*]`Mode`: Trend (regime-persistent coloring) or Extremes (overbought/oversold zones only)
[*]`No Repaint`: shifts crossover signals one bar forward to eliminate intrabar repainting (Trend mode only)
[*]`Equity Start Year`: anchor year for equity curve initialization (default 2019)
[*]`Period`: stochastic lookback for both smoothing stages (default 10)
[*]`EMA Length`: smoothing applied to each stochastic stage (default 9)
[*]`Trigger EMA`: EMA of the DSS line used as crossover signal (default 5)
[*]`Overbought / Oversold`: threshold levels for Extremes mode (defaults 90 / 10)
[*]`Resolution`: timeframe at which DSS is computed (default 60 minutes)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Paradiso. 
In Trend mode, positive color applies during bullish regimes and negative during bearish. In Extremes mode, positive color activates at overbought and negative at oversold, with neutral between thresholds.

[b]Purpose 🎯[/b]

Standard stochastic indicators generate excessive crossover noise, particularly on lower timeframes, making regime identification unreliable without significant manual filtering. 
The double smoothing of the DSS reduces that noise substantially, but most implementations still present only a raw oscillator with no mechanism for translating the signal into a persistent regime read or a measurable performance track record.

This indicator addresses both gaps. 
The Trend mode converts the DSS crossover into a persistent regime signal that remains active until explicitly invalidated, removing ambiguity about the current directional bias. 
The Equity view goes further: rather than asking the trader to visually backtest the signal, it computes and displays the cumulative return of following the DSS regime directly on the chart, making the signal's historical value immediately quantifiable without any external tools. 
The configurable resolution allows the same indicator to serve as both an intraday momentum tool and a macro trend filter depending on the selected timeframe.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("DSS Bressert - Trend, Valuation & Equity | Astral Vision 🌠💠", overlay=false)

string group0  = "View"
string group1  = "DSS Settings"
string group2  = "Astral Colors"

string view       = input.string("Indicator", "View",      options=["Indicator","Equity"], group=group0)
string mode       = input.string("Trend",     "Mode",      options=["Trend","Extremes"],   group=group0)
bool   no_repaint = input.bool(false, "No Repaint (Trend mode only)", group=group0)
int    eq_year    = input.int(2019, "Equity Start Year", minval=2000, group=group0)

int    PDS        = input.int(10, "Period",      minval=1, group=group1)
int    EMAlen     = input.int(9,  "EMA Length",  minval=1, group=group1)
int    TriggerLen = input.int(5,  "Trigger EMA", minval=1, group=group1)
int    Overbought = input.int(90, "Overbought",  minval=1, group=group1)
int    Oversold   = input.int(10, "Oversold",    minval=1, group=group1)
string res        = input.timeframe("60", "Resolution", group=group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

color neu_col = color.black

[c, h, l] = request.security(syminfo.tickerid, res, [close, high, low],
     barmerge.gaps_off, barmerge.lookahead_on)

float xPreCalc = ta.ema(ta.stoch(c, h, l, PDS), EMAlen)
float xDSS     = ta.ema(ta.stoch(xPreCalc, xPreCalc, xPreCalc, PDS), EMAlen)
float xTrigger = ta.ema(xDSS, TriggerLen)

bool bull_cross_live = ta.crossover(xDSS, xTrigger)
bool bear_cross_live = ta.crossunder(xDSS, xTrigger)

bool bull_cross = no_repaint ? bull_cross_live[1] : bull_cross_live
bool bear_cross = no_repaint ? bear_cross_live[1] : bear_cross_live

var bool trend_bull    = true
var bool trend_bull_eq = true

if bull_cross
    trend_bull := true
if bear_cross
    trend_bull := false

if bull_cross_live[1]
    trend_bull_eq := true
if bear_cross_live[1]
    trend_bull_eq := false

bool is_ob = xDSS >= Overbought
bool is_os = xDSS <= Oversold

color trend_col   = trend_bull ? pos_col : neg_col
color extreme_col = is_ob ? pos_col : is_os ? neg_col : neu_col

color dss_col  = mode == "Trend" ? trend_col : extreme_col
color trig_col = mode == "Trend" ? trend_col : color.new(neu_col, 40)

color candle_col = mode == "Trend" ? trend_col :
     is_ob ? pos_col :
     is_os ? neg_col :
     neu_col

color eq_candle_col = trend_bull_eq ? pos_col : neg_col

int   eq_start  = timestamp(eq_year, 1, 1, 0, 0)
bool  in_window = time >= eq_start

var float equity = float(na)

if in_window
    if na(equity)
        equity := 100.0
    else
        equity := trend_bull_eq ? equity * (close / close[1]) : equity

color eq_col = trend_bull_eq ? pos_col : neg_col

bool show_ind = view == "Indicator"
bool show_eq  = view == "Equity"

plot(show_ind ? Overbought : na, "Overbought", color=neg_col)
plot(show_ind ? Oversold   : na, "Oversold",   color=pos_col)
plot(show_ind ? xDSS       : na, "DSS",     color=color.new(dss_col, 20),  linewidth=2)
plot(show_ind ? xTrigger   : na, "Trigger", color=color.new(trig_col, 40), linewidth=1)

plot(show_eq ? equity : na, "Equity", color=eq_col, linewidth=2)

plotcandle(open, high, low, close, "Candles",
     show_eq ? eq_candle_col : candle_col,
     show_eq ? eq_candle_col : candle_col,
     bordercolor=show_eq ? eq_candle_col : candle_col,
     force_overlay=true)
````
