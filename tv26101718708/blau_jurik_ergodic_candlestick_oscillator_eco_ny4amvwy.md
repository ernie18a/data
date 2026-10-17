# Blau Jurik Ergodic Candlestick Oscillator (ECO)

- url: https://www.tradingview.com/script/Ny4amVWY-Blau-Jurik-Ergodic-Candlestick-Oscillator-ECO/
- type: indicator
- pine_id: PUB;bb97e9ca2c72493282cf0f87a68a93bf
- version: 1.0

## Description

================================================================================
TECHNICAL DESCRIPTION: BLAU JURIK ERGODIC CANDLESTICK OSCILLATOR (ECO)

OVERVIEW

The Blau Jurik Ergodic Candlestick Oscillator (ECO) is a highly responsive
momentum-to-volatility ratio indicator. It is a modernized variation of William
Blau's classic Ergodic Candlestick Oscillator.

While the standard ECO uses simple or exponential moving averages for smoothing,
this implementation replaces those linear filters with a double-pass adaptive
Jurik Filter. This modification significantly reduces lag while minimizing overshoot,
resulting in a cleaner, faster signal that adapts to changing market volatility.

CORE CONSTRUCTS & MATHEMATICAL FORMULATING

The indicator processes two primary streams of candlestick data at each bar:

A. Candlestick Body Displacement (Net Directional Movement)
This measures the net price movement from open to close:
co = Close - Open

B. Candlestick High-Low Range (Total Local Volatility)
This measures the absolute range of price movement, serving as a baseline
for total market energy:
hl = High - Low

Rather than using these raw values directly—which would produce an unstable,
noisy oscillator—both "co" and "hl" are smoothed using two cascaded passes
of an adaptive Jurik Filter.

THE ADAPTIVE JURIK SMOOTHING PROCESS

The Jurik Filter adapts its smoothing speed dynamically based on localized market
volatility. When volatility spikes, the filter automatically reduces its
smoothing length (speeding up) to catch the trend. When volatility drops, it
increases its smoothing length (slowing down) to filter out noise.

The key steps in the adaptive algorithm are:

A. Volatility Calculation:

Calculate changes relative to the current and prior values:
del1 = InputValue - max(InputValue[1], InputValue)
del2 = InputValue - min(InputValue[1], InputValue)
volty = max(abs(del1), abs(del2))

B. Volatility Normalization:

The current volatility is compared to a long-term rolling average (such as
a 65-period Simple Moving Average) to determine whether the market is
experiencing higher or lower volatility than normal:
Relative Volatility = volty / AverageVolatility

C. Dynamic Speed Adjustment:

An adjustment factor (representing the filter's feedback speed) is scaled
by this Relative Volatility.

When Relative Volatility is high, the smoothing coefficient (alpha)
increases, making the filter highly responsive.

When Relative Volatility is low, alpha decreases, smoothing out market noise.

D. Phase-Correction and Double-Pass Smoothing:

The filter runs a multi-stage phase shift correction that offsets the
natural lag of moving averages.

To construct the Ergodic Oscillator, this process is run twice (cascaded):
SmoothedBody = JurikFilter(JurikFilter(co, Length1, Phase), Length2, Phase)
SmoothedRange = JurikFilter(JurikFilter(hl, Length1, Phase), Length2, Phase)

OSCILLATOR & SIGNAL CALCULATIONS

Once the body displacement and high-low range are smoothed, the ECO is calculated
as a percentage ratio of the two:

ECO = 100 * (SmoothedBody / SmoothedRange)

Because "co" can be positive or negative, the ECO oscillates between -100 and +100.

An ECO near +100 indicates that the bodies of the candlesticks are taking up
almost the entire high-low range in a positive direction (strong, clean uptrend).

An ECO near -100 indicates that the bodies are taking up almost the entire
range in a negative direction (strong, clean downtrend).

An ECO near 0 indicates range-bound, choppy, or rotating price action with
little directional progress.

Downstream Signal Lines:
To generate trade signals and identify trend changes, multiple downstream signal
lines are calculated by applying a Jurik Filter directly to the ECO output:
Signal1 = JurikFilter(ECO, SignalLength1, SignalPhase1)
Signal2 = JurikFilter(ECO, SignalLength2, SignalPhase2)
...and so on, up to five distinct signal lines.

INTERPRETATION & USE CASES

The ECO is typically used for three primary types of market analysis:

A. Zero-Line Crossovers:

When the ECO crosses above 0, it indicates that buying momentum is
overcoming the overall price range, establishing a bullish bias.

When the ECO crosses below 0, it indicates that selling momentum is
dominating, establishing a bearish bias.

B. Signal Line Crossovers:

Bullish Signal: The ECO line crosses above its primary Signal Line.

Bearish Signal: The ECO line crosses below its primary Signal Line.

C. Volatility & Compression Regimes:

When all downstream signal lines contract and cluster together, it signals
extreme price compression (a low-volatility environment). This state often
precedes an explosive expansion of volatility.

When the signal lines fan out widely, it indicates a highly directional,
mature trend.
================================================================================

## Source Code

````pine
//@version=6
indicator("Blau Jurik Ergodic Candlestick Oscillator (ECO)", shorttitle="Blau Jurik ECO", overlay=false)

grp_eco = "ECO Core Settings"
len_eco = input.int(32, "ECO Length 1", group=grp_eco)
len_eco2 = input.int(5, "ECO Length 2", group=grp_eco)
phs_eco = input.float(0.0, "ECO Phase", group=grp_eco)

show1 = input.bool(true, "Show Signal 1", inline="1", group="Signal 1 Settings")
len1 = input.int(5, "Length", inline="1", group="Signal 1 Settings")
phs1 = input.float(0, "Phase", inline="1", group="Signal 1 Settings")
col1 = input.color(color.new(color.gray, 0), "Color", inline="1", group="Signal 1 Settings")

show2 = input.bool(false, "Show Signal 2", inline="2", group="Signal 2 Settings")
len2 = input.int(10, "Length", inline="2", group="Signal 2 Settings")
phs2 = input.float(0, "Phase", inline="2", group="Signal 2 Settings")
col2 = input.color(color.new(color.fuchsia, 0), "Color", inline="2", group="Signal 2 Settings")

show3 = input.bool(false, "Show Signal 3", inline="3", group="Signal 3 Settings")
len3 = input.int(20, "Length", inline="3", group="Signal 3 Settings")
phs3 = input.float(0, "Phase", inline="3", group="Signal 3 Settings")
col3 = input.color(color.new(color.purple, 0), "Color", inline="3", group="Signal 3 Settings")

show4 = input.bool(false, "Show Signal 4", inline="4", group="Signal 4 Settings")
len4 = input.int(50, "Length", inline="4", group="Signal 4 Settings")
phs4 = input.float(0, "Phase", inline="4", group="Signal 4 Settings")
col4 = input.color(color.new(color.blue, 0), "Color", inline="4", group="Signal 4 Settings")

show5 = input.bool(false, "Show Signal 5", inline="5", group="Signal 5 Settings")
len5 = input.int(100, "Length", inline="5", group="Signal 5 Settings")
phs5 = input.float(0, "Phase", inline="5", group="Signal 5 Settings")
col5 = input.color(color.new(color.navy, 0), "Color", inline="5", group="Signal 5 Settings")

f_jurik_volty(float src, float len, float phs) =>
    float safe_len = math.max(len, 1)
    float len1_calc = math.max(math.log(math.sqrt(0.5 * (safe_len - 1))) / math.log(2) + 2, 0)
    float pow1 = math.max(len1_calc - 2, 0.5)
    int avglen = 65
    var float bsmax = src, var float bsmin = src
    var float vsum = 0.0, var float avolty = 0.0
    var float Filt0 = src, var float Det0 = 0.0, var float Det1 = 0.0
    var float jurik = src
    float del1 = src - nz(bsmax[1], src)
    float del2 = src - nz(bsmin[1], src)
    float volty = math.max(math.abs(del1), math.abs(del2))
    float div = 1.0 / (10.0 + 10.0 * (math.max(math.min(safe_len - 10, 100), 0)) / 100.0)
    vsum := nz(vsum[1]) + div * (volty - nz(volty[10]))
    float tempavg = ta.sma(vsum, avglen)
    if bar_index + 1 <= avglen + 1
        avolty := nz(avolty[1]) + 2.0 * (vsum - nz(avolty[1])) / (avglen + 1.0)
    else
        avolty := tempavg
    float dvolty = avolty > 0 ? volty / avolty : 0.0
    dvolty := math.min(math.max(dvolty, 1.0), math.pow(len1_calc, 1.0 / pow1))
    float pow2 = math.pow(dvolty, pow1)
    float len2_calc = math.sqrt(0.5 * (safe_len - 1)) * len1_calc
    float kv = math.pow(len2_calc / (len2_calc + 1.0), math.sqrt(pow2))
    bsmax := del1 > 0 ? src : src - kv * del1
    bsmin := del2 < 0 ? src : src - kv * del2
    float phaseratio = phs < -100 ? 0.5 : phs > 100 ? 2.5 : phs / 100.0 + 1.5
    float beta = 0.45 * (safe_len - 1) / (0.45 * (safe_len - 1) + 2)
    float alpha = math.pow(beta, pow2)
    Filt0 := (1 - alpha) * src + alpha * nz(Filt0[1])
    Det0 := (src - Filt0) * (1 - beta) + beta * nz(Det0[1])
    float Filt1 = Filt0 + phaseratio * Det0
    Det1 := (Filt1 - nz(jurik[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(Det1[1])
    jurik := nz(jurik[1]) + Det1
    jurik

float co = close - open
float hl = high - low

float mom_smooth = f_jurik_volty(f_jurik_volty(co, len_eco, phs_eco), len_eco2, phs_eco)
float volty_smooth = f_jurik_volty(f_jurik_volty(hl, len_eco, phs_eco), len_eco2, phs_eco)

float eco = volty_smooth != 0 ? (100.0 * mom_smooth / volty_smooth) : 0.0

float sig1 = f_jurik_volty(eco, len1, phs1)

color hist_col = eco > 0 ? (eco > sig1 ? color.lime : color.green) : (eco < sig1 ? color.red : color.maroon)
plot(eco, "ECO", color=hist_col, style=plot.style_histogram, linewidth=2)
plot(show1 ? sig1 : na, "Signal 1", color=col1, linewidth=2)
plot(show2 ? f_jurik_volty(eco, len2, phs2) : na, "Signal 2", color=col2, linewidth=2)
plot(show3 ? f_jurik_volty(eco, len3, phs3) : na, "Signal 3", color=col3, linewidth=2)
plot(show4 ? f_jurik_volty(eco, len4, phs4) : na, "Signal 4", color=col4, linewidth=2)
plot(show5 ? f_jurik_volty(eco, len5, phs5) : na, "Signal 5", color=col5, linewidth=2)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)
````
