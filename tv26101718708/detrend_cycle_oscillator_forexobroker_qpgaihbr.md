# Detrend Cycle Oscillator [forexobroker]

- url: https://www.tradingview.com/script/QpgaiHBr-Detrend-Cycle-Oscillator-forexobroker/
- type: indicator
- pine_id: PUB;f2e05ac35e6c479ca07a9e9dfb6b6563
- version: 1.0

## Description

Detrend Cycle Oscillator [forexobroker] estimates the dominant cycle in price by autocorrelation argmax search, then detrends close by an SMA of half that cycle and rescales the residual by ATR into a volatility-normalized oscillator. The unique angle is letting the data choose the SMA length: instead of guessing "21" or "55", the oscillator's lookback adapts to the cycle the market is actually running, bounded to the lag search range.

🔶 ALGORITHM

1. For each lag k in [min lag, max lag] (defaults 5 to 50), compute the rolling Pearson correlation between close and close[k] over the correlation window (default 30).
2. k_dom = argmax over k of that correlation; the strongest auto-similar lag is the dominant cycle.
3. Detrended price = close minus SMA(close, round(k_dom / 2)).
4. Oscillator = detrended / ATR(14) — volatility-scaled and unitless.
5. Smoothed oscillator = EMA of the oscillator over the oscillator EMA length (default 3).
6. Zero-crossings of the raw oscillator gate the signals; the smoothed oscillator must exceed the threshold (default 0.5) in the same direction.

🔶 SIGNAL LOGIC

- Buy: oscillator crosses up through zero AND smoothed oscillator is greater than +threshold AND position is not already long AND session filter passes AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: oscillator crosses down through zero AND smoothed oscillator is less than -threshold AND position is not already short AND session filter passes AND cooldown bars elapsed AND barstate.isconfirmed.

The smoothed threshold acts as a regime filter so a single noisy bar cannot trigger the indicator.

🔶 INPUTS

- Cycle Estimation group: min cycle lag default 5, max cycle lag default 50, correlation window default 30, ATR length default 14, oscillator EMA default 3.
- Signal Logic group: smoothed threshold default 0.5, cooldown bars default 15.
- Filters group: session restriction default 0000-2400.
- Visual group: dashboard, 3-layer glow, oscillator and smoothed colors, dashboard background.

🔶 ALERTS

DCO Buy, DCO Sell, DCO Any Signal, DCO Zero Cross Up, DCO Zero Cross Dn, DCO Overbought, DCO Oversold, DCO Cycle Shift, DCO Strong Lock, DCO Weak Lock, DCO Webhook JSON.

🔶 LIMITATIONS

- Autocorrelation argmax is sensitive to the correlation window; very short windows produce unstable cycle estimates.
- The lag search is bounded to [min lag, max lag]; true cycles outside the range will be misreported as the nearest bound.
- During strong directional moves the dominant cycle estimate degrades because autocorrelation is dominated by the trend rather than periodicity.
- The detrend uses an SMA of half the dominant cycle (rounded), introducing the usual SMA lag.
- The threshold filter reduces but does not eliminate whipsaws in low-volatility regimes.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Detrend Cycle Oscillator. The dominant cycle length is estimated by autocorrelation
// argmax over lags 5..50 (window 30); k_dom = argmax of Pearson corr(close, close[k], 30) computed
// via an explicit summation helper (no ta.* internal state inside the lag-search loop).
// Price is detrended by an SMA of half the dominant cycle, then normalized by ATR(14) into a
// volatility-scaled oscillator. A short EMA smooth confirms direction. Signals fire on oscillator
// zero-crossings when the smoothed oscillator confirms with magnitude beyond +/- the threshold.
// Non-repainting: signals confirm at bar close.
indicator("Detrend Cycle Oscillator [forexobroker]", shorttitle="DCO [fob]", overlay=false, max_labels_count=500, max_lines_count=500)

string g_calc = "Cycle Estimation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_minLag   = input.int(5,    "Min Cycle Lag",      minval=2,  maxval=20, group=g_calc, tooltip="Lower bound for the autocorrelation argmax search.")
int   i_maxLag   = input.int(50,   "Max Cycle Lag",      minval=20, maxval=200, group=g_calc, tooltip="Upper bound for the autocorrelation argmax search.")
int   i_corrWin  = input.int(30,   "Correlation Window", minval=10, maxval=200, group=g_calc, tooltip="Window for Pearson correlation at each lag.")
int   i_atrLen   = input.int(14,   "ATR Length",         minval=5,  maxval=50,  group=g_calc)
int   i_emaSmooth= input.int(3,    "Oscillator EMA",     minval=2,  maxval=20,  group=g_calc)
float i_threshold= input.float(0.25,"Smoothed Threshold", minval=0.1, maxval=3.0, step=0.05, group=g_sig, tooltip="|smoothed osc| must exceed this for a signal.")
int   i_cooldown = input.int(5,    "Cooldown Bars",      minval=1,  maxval=60,  group=g_sig)
bool  i_useSess  = input.bool(false,"Restrict to Session",                      group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                 group=g_filt)
bool  i_showTable= input.bool(true,"Show Dashboard",                            group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                         group=g_vis)
color i_buyColor = input.color(#00ffd1,"Buy Color",                             group=g_vis)
color i_sellColor= input.color(#ff3df0,"Sell Color",                            group=g_vis)
color i_oscRaw   = input.color(#7df9ff,"Oscillator Color",                      group=g_vis)
color i_oscSm    = input.color(#fbbf24,"Smoothed Color",                        group=g_vis)
color i_dashBg   = input.color(color.new(#0a1a14, 16),"Dashboard BG",           group=g_vis)

color c_white = #ffffff

// Manual Pearson correlation of close vs close[k] over a fixed window w.
// Uses explicit summation so the helper has no ta.* internal state — safe to
// call inside the lag-search loop where k varies.
f_corr(int k, int w) =>
    float sx  = 0.0
    float sy  = 0.0
    float sxx = 0.0
    float syy = 0.0
    float sxy = 0.0
    int   n   = 0
    for j = 0 to w - 1
        float x = close[j]
        float y = close[j + k]
        if not na(x) and not na(y)
            sx  += x
            sy  += y
            sxx += x * x
            syy += y * y
            sxy += x * y
            n   += 1
    float result = 0.0
    if n > 1
        float num = n * sxy - sx * sy
        float den = math.sqrt(math.max(n * sxx - sx * sx, 0.0) * math.max(n * syy - sy * sy, 0.0))
        result := den > 0 ? num / den : 0.0
    result

// Autocorrelation argmax in [minLag, maxLag]
var float[] corrArr = array.new_float(0)
var int[]   lagArr  = array.new_int(0)
if barstate.isfirst
    for k = i_minLag to i_maxLag
        array.push(corrArr, 0.0)
        array.push(lagArr,  k)

int span = i_maxLag - i_minLag + 1
if array.size(corrArr) == span
    for j = 0 to span - 1
        int k = i_minLag + j
        float c = nz(f_corr(k, i_corrWin), 0.0)
        array.set(corrArr, j, c)

int kDom = i_minLag
float bestCorr = -1e20
if array.size(corrArr) > 0
    for j = 0 to array.size(corrArr) - 1
        float c = array.get(corrArr, j)
        if c > bestCorr
            bestCorr := c
            kDom := array.get(lagArr, j)

int halfK = math.max(2, math.round(kDom / 2.0))
float atrV = nz(ta.atr(i_atrLen), 1.0)
float detr = close - ta.sma(close, halfK)
float osc  = detr / math.max(atrV, 1e-6)
float oscSmooth = ta.ema(osc, i_emaSmooth)

bool zeroUp = ta.crossover(osc, 0.0)
bool zeroDn = ta.crossunder(osc, 0.0)
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = zeroUp and oscSmooth >  i_threshold and posState <= 0 and inSession and cooldownOk and confirmed
bool sellSignal = zeroDn and oscSmooth < -i_threshold and posState >= 0 and inSession and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

plot(osc,       "Oscillator",       color=color.new(i_oscRaw, 0), linewidth=2)
plot(oscSmooth, "Smoothed",         color=color.new(i_oscSm,  0), linewidth=2)
hline(0.0,            "Zero", color=color.new(color.gray, 40))
hline(i_threshold,    "+T",   color=color.new(i_buyColor,  60))
hline(-i_threshold,   "-T",   color=color.new(i_sellColor, 60))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="DCO", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="DCO", textcolor=c_white)

// PRICE-PANE MIRROR (Pine v6 force_overlay): same entry signals projected onto the candlesticks.
plotshape(i_showGlow and buySignal,  "Buy Glow 1 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge,   force_overlay=true)
plotshape(i_showGlow and buySignal,  "Buy Glow 2 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large,  force_overlay=true)
plotshape(buySignal,                 "Buy (price)",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="DCO", textcolor=c_white, force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 1 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 2 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large, force_overlay=true)
plotshape(sellSignal,                "Sell (price)",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="DCO", textcolor=c_white, force_overlay=true)

bgcolor(buySignal ? color.new(i_buyColor, 88) : sellSignal ? color.new(i_sellColor, 88) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_oscRaw, 55), border_width=1)
    string stateLabel = oscSmooth > i_threshold ? "BULL EXT" : oscSmooth < -i_threshold ? "BEAR EXT" : "NEUTRAL"
    color  sc = oscSmooth > i_threshold ? i_buyColor : oscSmooth < -i_threshold ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Detrend Cycle Oscillator", text_color=i_oscRaw, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_oscRaw, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, stateLabel,               text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Dominant Cycle",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(kDom) + "b", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Best Corr",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(bestCorr, "0.000"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Oscillator",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(osc, "0.00"), text_color=osc > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Smoothed",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(oscSmooth, "0.00"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"DCO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cycle":' + str.tostring(kDom) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"DCO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cycle":' + str.tostring(kDom) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "DCO Buy",             "DCO bullish cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "DCO Sell",            "DCO bearish cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "DCO Any Signal",      "Any DCO signal on {{ticker}} {{interval}}")
alertcondition(zeroUp,                                 "DCO Zero Cross Up",   "Oscillator zero cross up on {{ticker}} {{interval}}")
alertcondition(zeroDn,                                 "DCO Zero Cross Dn",   "Oscillator zero cross down on {{ticker}} {{interval}}")
alertcondition(oscSmooth > 1.0,                        "DCO Overbought",      "Smoothed above 1.0 on {{ticker}} {{interval}}")
alertcondition(oscSmooth < -1.0,                       "DCO Oversold",        "Smoothed below -1.0 on {{ticker}} {{interval}}")
alertcondition(ta.change(kDom) != 0,                   "DCO Cycle Shift",     "Dominant cycle length changed on {{ticker}} {{interval}}")
alertcondition(bestCorr > 0.5,                         "DCO Strong Lock",     "Autocorrelation strong on {{ticker}} {{interval}}")
alertcondition(bestCorr < 0.0,                         "DCO Weak Lock",       "Autocorrelation weak on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "DCO Webhook JSON",    "{\"action\":\"signal\",\"indicator\":\"DCO\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
