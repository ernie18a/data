# Sinc Blackman Spectral Oscillator | Astral Vision 

- url: https://www.tradingview.com/script/hQ8p4OMp/
- type: indicator
- pine_id: PUB;8f4589512c1d4f5b92ecdc067e74192d
- version: 1.0

## Description

[b]Sinc Blackman Spectral Oscillator | Astral Vision 🌠💠[/b]

This indicator applies a Sinc filter windowed with a Blackman function to extract a spectrally clean momentum signal from price, isolating cyclical components while suppressing high-frequency noise with a mathematically defined frequency boundary rather than the gradual roll-off of conventional moving averages. The oscillator measures the deviation of price from this filtered baseline, then applies a secondary moving average to the deviation itself to generate a signal line whose crossover drives both the visual output and the equity simulation.

The Blackman window is one of the most effective functions in digital signal processing: it reduces spectral leakage to near zero by tapering the filter kernel smoothly to zero at both ends, preventing frequencies outside the cutoff from bleeding into the filtered output. Applied to a Sinc filter, it produces a near-ideal low-pass filter that separates trend from noise with a precision unachievable by any EMA, WMA, or SMA-based approach.

The indicator operates in two visualization modes: 
[list]
[*]Oscillator mode displays the momentum and its signal MA directly.
[*]Equity Line mode simulates a long-only strategy that holds Bitcoin when momentum is positive and exits to cash when negative, with a full risk-adjusted performance dashboard.
[/list]

This is a [b]momentum and trend following[/b] indicator suited for [b]swing trading and position trading on daily timeframes[/b]. The spectral filtering makes it particularly effective at identifying sustained directional moves while ignoring the short-term price oscillations that generate false signals in standard momentum tools.

[b]How it differs from standard momentum indicators[/b]

Standard momentum oscillators such as MACD, RSI, or standard moving average crossovers use filters with poorly defined frequency responses. A simple moving average does not have a clean cutoff frequency: it attenuates some frequencies gradually while letting others through unpredictably, a property known as spectral leakage. The Sinc-Blackman filter defines an explicit cutoff frequency and suppresses everything above it with near-ideal precision. This means the momentum baseline extracted by this indicator is genuinely separated from noise at the mathematical level, not merely smoothed. The configurable smoothing frequency parameter directly controls the spectral cutoff point, giving the user precise control over which price cycles are considered trend and which are considered noise, something no standard TradingView built-in provides.

[b]Plots 📊[/b]
[list]
[*]Momentum line with glow effect, colored by position relative to its signal MA (Oscillator mode)
[*]Signal MA with glow effect (Oscillator mode)
[*]Fill between momentum and signal MA highlighting bullish and bearish zones
[*]Zero baseline
[*]Equity curve with glow effect, colored by previous bar's signal direction (Equity Line mode)
[*]Candle coloring on the price chart reflecting the previous confirmed signal in both modes
[*]Performance table in Equity Line mode: Strategy Return, Buy and Hold, vs Buy and Hold, Max Drawdown Total, Max Drawdown per Trade, Sharpe Ratio, Sortino Ratio, Omega Ratio
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Source: price input for the filter
[*]Momentum Length: base length controlling the Sinc filter kernel size
[*]Momentum Smoothing: cutoff frequency parameter controlling the spectral boundary
[*]Post Smoothing: length of the smoothing applied to the filtered deviation
[*]Post Smoothing Style: EMA, DEMA, TEMA, WMA, or SMA
[*]MA Length: length of the signal MA applied to the smoothed momentum
[*]MA Style: EMA, DEMA, TEMA, WMA, or SMA
[*]View: switch between Oscillator and Equity Line
[*]Equity Start Date: starting date for the equity simulation and performance metrics
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Sinc Blackman Spectral Oscillator | Astral Vision 🌠💠", overlay=false, explicit_plot_zorder=true)

string group1 = "Settings"
string group2 = "Visualization"
string group3 = "Astral Colors"
string group4 = "Equity Line"

float  source        = input.source(close, "Source",               group=group1)
int    mom_length    = input.int(91,   "Momentum Length",          group=group1, minval=1)
float  mom_smoothing = input.float(111, "Momentum Smoothing",       group=group1, minval=1)
int    post_smooth   = input.int(9,    "Post Smoothing",           group=group1, minval=1)
string post_style    = input.string("TEMA", "Post Smoothing Style", group=group1, options=["EMA","DEMA","TEMA","WMA","SMA"])
int    ma_length     = input.int(52,   "MA Length",                group=group1, minval=2)
string ma_style      = input.string("WMA", "MA Style",             group=group1, options=["EMA","DEMA","TEMA","WMA","SMA"])

string vismode       = input.string("Oscillator", "View", group=group2, options=["Oscillator","Equity Line"])
int    eq_start      = input.time(timestamp("2019-01-01"), "Equity Start Date", group=group4)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.white, "Custom Positive", group=group3)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group3)

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

method is_even(simple int n) => n % 2 == 0

sinc_f(float x) => x == 0 ? 1 : math.sin(math.pi * x) / (math.pi * x)

blackman(float n, int length) =>
    0.42 - 0.5 * math.cos((2 * math.pi * n) / (length - 1)) + 0.08 * math.cos((4 * math.pi * n) / (length - 1))

mid_point(int x) => (x - 1) / 2

offset_f(simple int length) => (length - 1) / 2

get_data(float src, simple int length) =>
    var float[] data = array.new<float>()
    if data.size() < length
        data.unshift(src)
        data
    else
        data.unshift(src)
        data.pop()
        data

sinc_coefficients(simple int length, float fc) =>
    float[] coefficients = array.new<float>()
    int mid = mid_point(length)
    float cutoff = 1 / fc
    for i = 0 to length - 1
        int n = i - mid
        int k = i
        int M = length
        if length.is_even()
            float coefficient = sinc_f(2 * cutoff * n) * blackman(k + 0.5, M)
            coefficients.push(coefficient)
        else
            float coefficient = sinc_f(2 * cutoff * n) * blackman(k, M)
            coefficients.push(coefficient)
    coefficients

toeplitz_matrix_valid(float[] coefficients, int M) =>
    int N = coefficients.size()
    int rows = M - N + 1
    matrix<float> toeplitz = matrix.new<float>(rows, M, 0)
    for r = 0 to rows - 1
        for c = 0 to N - 1
            if (c + r) < M
                toeplitz.set(r, c + r, coefficients.get(c))
            else
                break
    toeplitz

convolution(float[] data, float[] coefficients) =>
    var float normalize = coefficients.sum()
    var matrix<float> toeplitz_matrix = toeplitz_matrix_valid(coefficients, data.size())
    float convolved = matrix.mult(toeplitz_matrix, data).first()
    convolved / normalize

lti_sinc(series float src, simple int length, simple float fc = 100) =>
    float[] data = get_data(src, length)
    var float[] coefficients = sinc_coefficients(length, fc)
    if bar_index > length
        convolution(data, coefficients)
    else
        float(na)

f_ema(series float src, simple float length) =>
    float alpha = 2.0 / (length + 1)
    var float smoothed = na
    smoothed := alpha * src + (1.0 - alpha) * nz(smoothed[1], src)

f_dema(series float src, simple float length) =>
    float e1 = f_ema(src, length)
    float e2 = f_ema(e1, length)
    2.0 * e1 - e2

f_tema(series float src, simple float length) =>
    float e1 = f_ema(src, length)
    float e2 = f_ema(e1, length)
    float e3 = f_ema(e2, length)
    (e1 - e2) * 3.0 + e3

f_wma(series float src, simple int length) =>
    var float weight_sum = length * 0.5 * (length + 1)
    float sum = 0.0
    for i = 0 to length - 1
        sum += src[i] * (length - i)
    sum / weight_sum

f_sma(series float src, simple int length) =>
    float s = ta.cum(src)
    bar_index < length - 1 ? s / (bar_index + 1) : (s - s[length]) / length

f_filter(series float src, simple int length, simple string style) =>
    if length > 1
        switch style
            "EMA"  => f_ema(src, length)
            "DEMA" => f_dema(src, length)
            "TEMA" => f_tema(src, length)
            "WMA"  => f_wma(src, length)
            =>        f_sma(src, length)
    else
        src

int   length_correction = mom_length * 2
float sinc_val          = lti_sinc(source, length_correction, mom_smoothing)
int   off               = offset_f(length_correction)
float delta             = f_filter((source - sinc_val) / off, post_smooth, post_style)
float ma                = f_filter(f_filter(delta, 2, ma_style), ma_length, ma_style)
float momo              = delta - ma

bool in_window = time >= eq_start

var float equity       = 1.0
var float eq_start_val = float(na)
var float eq_peak      = 1.0
var float max_dd_total = 0.0
var float trade_peak   = 1.0
var float max_dd_trade = 0.0
var bool  in_trade     = false
var float daily_ret    = float(na)

var array<float> returns     = array.new<float>()
var array<float> neg_returns = array.new<float>()

if in_window
    if na(eq_start_val)
        eq_start_val := close

    bool long_signal = not na(momo[1]) and momo[1] > 0
    bool was_in_trade = in_trade

    if not na(close) and not na(close[1]) and close[1] != 0
        if long_signal
            float r = close / close[1] - 1.0
            equity  := equity[1] * (1.0 + r)
            daily_ret := r
            if not was_in_trade
                in_trade   := true
                trade_peak := equity
            trade_peak := math.max(trade_peak, equity)
            float dd_t = (equity - trade_peak) / trade_peak
            max_dd_trade := math.min(max_dd_trade, dd_t)
        else
            daily_ret := 0.0
            if was_in_trade
                in_trade := false
            equity := equity[1]

        array.push(returns, daily_ret)
        if daily_ret < 0
            array.push(neg_returns, daily_ret)

        eq_peak      := math.max(eq_peak, equity)
        float dd     = (equity - eq_peak) / eq_peak
        max_dd_total := math.min(max_dd_total, dd)

bool is_osc    = vismode == "Oscillator"
bool is_equity = vismode == "Equity Line"

color trend_col = delta >= ma ? pos_col : neg_col
color eq_col = momo[1] >= 0 ? pos_col : neg_col

p_delta = plot(is_osc ? delta : na, "Momentum",      color=color.new(trend_col, 0),  linewidth=2)
p_ma    = plot(is_osc ? ma    : na, "MA",             color=color.new(neg_col,   0),  linewidth=2)
plot(is_osc ? delta : na, "Momentum Glow", color=color.new(trend_col, 75), linewidth=6)
plot(is_osc ? ma    : na, "MA Glow",       color=color.new(neg_col,   75), linewidth=6)
fill(p_delta, p_ma, delta > ma ? color.new(pos_col, 85) : color.new(neg_col, 85), "Momentum Fill")
hline(0, color=color.new(color.rgb(73,73,73), 0), display=is_osc ? display.all : display.none)

float eq_plot = is_equity and in_window ? equity : na
plot(eq_plot, "Equity Line",      color=color.new(eq_col, 0),  linewidth=2)
plot(eq_plot, "Equity Line Glow", color=color.new(eq_col, 75), linewidth=4)

plotcandle(open, high, low, close, "Candles",
     eq_col, eq_col,
     bordercolor=eq_col,
     force_overlay=true)

if barstate.islast and is_equity
    float total_ret = (equity - 1.0) * 100
    float bh_ret    = not na(eq_start_val) and eq_start_val != 0 ? (close / eq_start_val - 1.0) * 100 : na
    float vs_bh     = total_ret - nz(bh_ret)

    float sharpe  = float(na)
    float sortino = float(na)
    float omega   = float(na)

    int n = array.size(returns)
    if n > 1
        float mean_r = array.avg(returns)
        float std_r  = array.stdev(returns)
        sharpe := std_r != 0 ? (mean_r / std_r) * math.sqrt(252) : na

        float sum_neg_sq = 0.0
        for r in neg_returns
            sum_neg_sq += r * r
        float downside_dev = math.sqrt(sum_neg_sq / n)
        sortino := downside_dev != 0 ? (mean_r / downside_dev) * math.sqrt(252) : na

        float sum_pos = 0.0
        float sum_neg = 0.0
        for r in returns
            if r > 0
                sum_pos += r
            else
                sum_neg += math.abs(r)
        omega := sum_neg != 0 ? sum_pos / sum_neg : na

    color ret_col   = total_ret      >= 0    ? pos_col : neg_col
    color bh_col    = nz(bh_ret)     >= 0    ? pos_col : neg_col
    color vs_col    = vs_bh          >= 0    ? pos_col : neg_col
    color ddt_col   = max_dd_total   >= -0.1 ? pos_col : neg_col
    color ddtr_col  = max_dd_trade   >= -0.1 ? pos_col : neg_col
    color sh_col    = nz(sharpe)     >= 1    ? pos_col : neg_col
    color so_col    = nz(sortino)    >= 1    ? pos_col : neg_col
    color om_col    = nz(omega)      >= 1    ? pos_col : neg_col

    color hdr_bg  = pos_col
    color row_bg  = color.rgb(12,12,12)
    color dd_bg   = color.rgb(18,10,10)

    var table t = table.new(position.top_right, 2, 9,
         bgcolor=row_bg,
         border_color=color.rgb(40,40,40),
         border_width=1,
         frame_color=color.rgb(40,40,40),
         frame_width=1)

    table.cell(t, 0, 0, "METRIC",            text_color=color.black, bgcolor=hdr_bg, text_halign=text.align_center, text_size=size.normal, text_formatting=text.format_bold)
    table.cell(t, 1, 0, "VALUE",             text_color=color.black, bgcolor=hdr_bg, text_halign=text.align_center, text_size=size.normal, text_formatting=text.format_bold)

    table.cell(t, 0, 1, "Strategy Return",   text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 1, str.tostring(total_ret, "#.##") + "%", text_color=ret_col,  bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 2, "Buy & Hold",        text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 2, na(bh_ret) ? "n/a" : str.tostring(bh_ret, "#.##") + "%", text_color=bh_col, bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 3, "vs Buy & Hold",     text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 3, str.tostring(vs_bh, "#.##") + "%", text_color=vs_col,       bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 4, "Max DD (Total)",    text_color=color.white, bgcolor=dd_bg,  text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 4, str.tostring(max_dd_total * 100, "#.##") + "%", text_color=ddt_col, bgcolor=dd_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 5, "Max DD (Trade)",    text_color=color.white, bgcolor=dd_bg,  text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 5, str.tostring(max_dd_trade * 100, "#.##") + "%", text_color=ddtr_col, bgcolor=dd_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 6, "Sharpe Ratio",      text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 6, na(sharpe)  ? "n/a" : str.tostring(sharpe,  "#.##"), text_color=sh_col, bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 7, "Sortino Ratio",     text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 7, na(sortino) ? "n/a" : str.tostring(sortino, "#.##"), text_color=so_col, bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)

    table.cell(t, 0, 8, "Omega Ratio",       text_color=color.white, bgcolor=row_bg, text_halign=text.align_left, text_size=size.normal, text_font_family=font.family_monospace)
    table.cell(t, 1, 8, na(omega)   ? "n/a" : str.tostring(omega,   "#.##"), text_color=om_col, bgcolor=row_bg, text_halign=text.align_center, text_size=size.normal, text_font_family=font.family_monospace)
````
