# RSI Bitcoin vs Metals and S&P500 | Astral Vision 

- url: https://www.tradingview.com/script/DXo0wWsA/
- type: indicator
- pine_id: PUB;62dceaf0a263409e944c67ed888efb83
- version: 1.0

## Description

[b]RSI Bitcoin vs Metals and S&P500 | Astral Vision 🌠💠[/b]

Bitcoin's relative strength against traditional macro assets (gold, silver, and the S&P 500) reveals where BTC stands in the broader capital rotation cycle. 
When BTC is outperforming these benchmarks on a sustained basis, it signals risk-on momentum and capital flowing into the hardest assets. 
When it underperforms, capital is rotating back toward traditional safe havens or equities, often preceding or confirming broader BTC weakness.

This indicator applies RSI to the BTC/Gold, BTC/Silver, and BTC/SPX ratios, measuring whether Bitcoin is overbought or oversold relative to each benchmark independently or as a blended average. 

Two modes offer different analytical lenses: 
"Extremes" identifies statistical RSI turning points against user-defined thresholds, while "Trend" tracks whether Bitcoin's relative strength is above or below the 50 midline after EMA smoothing.

[b]Calculation ⚙️[/b]

`RSI(BTC/Gold, length)`, `RSI(BTC/Silver, length)`, `RSI(BTC/SPX, length)` — each computed on the price ratio directly, on daily or weekly timeframe.

`Average = mean(RSI_Gold, RSI_Silver, RSI_SPX)`

In Trend mode, an EMA of configurable length is applied to each RSI before plotting and threshold evaluation. The active signal is whichever of the four options (Average, Gold, Silver, SPX) is selected, and drives all coloring, fills, and overlay output.

[b]Plots 📊[/b]
[list]
[*]Active RSI or EMA-smoothed RSI line in the panel, colored by regime
[*]Overbought and oversold threshold lines in Extremes mode
[*]50 midline in Trend mode
[*]Fill between the active signal and the breached threshold in Extremes mode
[*]Fill between the active signal and the 50 midline in Trend mode (positive above, negative below)
[*]Background highlight on the price chart in Extremes mode when a threshold is breached (Background Color visualization)
[*]Candle coloring on the price chart by active regime (Plot Candle visualization, always active in Trend mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Mode` : Extremes (threshold-based signals) or Trend (50-line momentum read)
[*]`Timeframe`: Daily or Weekly resolution for all ratio RSI calculations
[*]`Signal`: selects the active signal: Average, Gold, Silver, or SPX
[*]`Visualization` : Background Color or Plot Candle for price chart overlay
[*]`RSI Length`: period for all RSI calculations (default 20)
[*]`Overbought Level`: upper threshold in Extremes mode (default 75)
[*]`Oversold Level`: lower threshold in Extremes mode (default 32)
[*]`EMA Length (Trend Mode)`: smoothing period applied to RSI in Trend mode (default 10)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Hermes. Positive color activates at oversold extremes and above-50 trend; negative color activates at overbought extremes and below-50 trend.

[b]Purpose 🎯[/b]

Standalone RSI on BTC price measures momentum in absolute terms, blind to how Bitcoin is performing relative to the macro environment surrounding it. 
A BTC rally that lags gold and equities carries very different implications than one that leads them but a standard RSI cannot distinguish the two.

This indicator reframes the question entirely: instead of asking whether BTC is overbought or oversold in isolation, it asks whether BTC is overbought or oversold relative to the assets it competes with for capital. 
The Average signal blends all three benchmarks into a single composite read, reducing the noise of any single ratio. The selectable timeframe and dual-mode structure let traders use the same indicator for both tactical entry timing (Extremes, Daily) and macro trend positioning (Trend, Weekly) without switching tools.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("RSI Bitcoin vs Metals and S&P500 | Astral Vision 🌠💠")

string gset    = "Settings"
string gastral = "Astral Colors"

string vis_mode = input.string("Extremes",         "Mode",          options=["Extremes","Trend"],               group=gset)
string tf_sel   = input.string("Daily",            "Timeframe",     options=["Daily","Weekly"],                 group=gset)
string sig_sel  = input.string("Average",          "Signal",        options=["Average","Gold","Silver","SPX"],  group=gset)
string viztype  = input.string("Background Color", "Visualization", options=["Background Color","Plot Candle"], group=gset)
int    rsi_len  = input.int(20,  "RSI Length",     minval=1,                                                    group=gset)
float  ob_inp   = input.float(75.0, "Overbought Level", step=0.5,                                              group=gset)
float  os_inp   = input.float(32.0, "Oversold Level",   step=0.5,                                              group=gset)
int    ema_len  = input.int(10,  "EMA Length (Trend Mode)", minval=1,                                          group=gset)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=gastral)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=gastral)
color  custom_pos = input.color(color.white, "Custom Positive", group=gastral)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=gastral)

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

bool is_weekly   = tf_sel   == "Weekly"
bool is_avg      = sig_sel  == "Average"
bool is_gold     = sig_sel  == "Gold"
bool is_silver   = sig_sel  == "Silver"
bool is_spx      = sig_sel  == "SPX"
bool is_extremes = vis_mode == "Extremes"
bool is_trend    = vis_mode == "Trend"
bool usedbg      = viztype  == "Background Color" and is_extremes
bool usecndl     = viztype  == "Plot Candle" and is_extremes or is_trend

string tf      = is_weekly ? "W" : "D"
float ob_level = ob_inp
float os_level = os_inp

float rsiGold   = request.security("INDEX:BTCUSD/TVC:GOLD",   tf, ta.rsi(close, rsi_len))
float rsiSpx    = request.security("INDEX:BTCUSD/TVC:SPX",    tf, ta.rsi(close, rsi_len))
float rsiSilver = request.security("INDEX:BTCUSD/TVC:SILVER", tf, ta.rsi(close, rsi_len))
float rsiAvg    = math.avg(rsiGold, rsiSpx, rsiSilver)

float emaGold   = ta.ema(rsiGold,   ema_len)
float emaSilver = ta.ema(rsiSilver, ema_len)
float emaSpx    = ta.ema(rsiSpx,    ema_len)
float emaAvg    = ta.ema(rsiAvg,    ema_len)

float val_gold   = is_trend ? emaGold   : rsiGold
float val_silver = is_trend ? emaSilver : rsiSilver
float val_spx    = is_trend ? emaSpx    : rsiSpx
float val_avg    = is_trend ? emaAvg    : rsiAvg

float active_val = is_avg ? val_avg : is_gold ? val_gold : is_silver ? val_silver : val_spx

color col_ext = active_val > ob_level ? neg_col : active_val < os_level ? pos_col : color.black
color col_trnd = active_val >= 50 ? pos_col : neg_col

color plot_col_ext_gold   = rsiGold   > ob_level ? neg_col : rsiGold   < os_level ? pos_col : color.black
color plot_col_ext_silver = rsiSilver > ob_level ? neg_col : rsiSilver < os_level ? pos_col : color.black
color plot_col_ext_spx    = rsiSpx    > ob_level ? neg_col : rsiSpx    < os_level ? pos_col : color.black
color plot_col_ext_avg    = rsiAvg    > ob_level ? neg_col : rsiAvg    < os_level ? pos_col : color.black

color plot_col_trnd_gold   = emaGold   >= 50 ? pos_col : neg_col
color plot_col_trnd_silver = emaSilver >= 50 ? pos_col : neg_col
color plot_col_trnd_spx    = emaSpx    >= 50 ? pos_col : neg_col
color plot_col_trnd_avg    = emaAvg    >= 50 ? pos_col : neg_col

color active_sig_col = is_extremes ? col_ext : col_trnd

plot(is_gold   ? val_gold   : na, color=is_extremes ? plot_col_ext_gold   : plot_col_trnd_gold,   linewidth=2)
plot(is_silver ? val_silver : na, color=is_extremes ? plot_col_ext_silver : plot_col_trnd_silver, linewidth=2)
plot(is_spx    ? val_spx    : na, color=is_extremes ? plot_col_ext_spx    : plot_col_trnd_spx,    linewidth=2)
plot(is_avg    ? val_avg    : na, color=is_extremes ? plot_col_ext_avg    : plot_col_trnd_avg,     linewidth=2)

p_ob  = plot(is_extremes ? ob_level : na, color=color.new(neg_col, 30), linewidth=1)
p_os  = plot(is_extremes ? os_level : na, color=color.new(pos_col, 30), linewidth=1)
p_50  = plot(is_trend    ? 50.0     : na, color=color.new(color.rgb(120,120,120), 50), linewidth=1)
p_act = plot(active_val, display=display.none)

fill(p_act, p_ob, is_extremes and active_val >= ob_level ? color.new(active_sig_col, 60) : na)
fill(p_act, p_os, is_extremes and active_val <= os_level ? color.new(active_sig_col, 60) : na)
fill(p_act, p_50, is_trend ? (active_val >= 50 ? color.new(pos_col, 50) : color.new(neg_col, 50)) : na)

bgcolor(usedbg ? (active_val > ob_level ? color.new(active_sig_col, 50) : active_val < os_level ? color.new(active_sig_col, 50) : na) : na, force_overlay=true)

plotcandle(open, high, low, close, "Signal Candle",
     active_sig_col, active_sig_col,
     bordercolor   = active_sig_col,
     force_overlay = true,
     display       = usecndl ? display.all : display.none)
````
