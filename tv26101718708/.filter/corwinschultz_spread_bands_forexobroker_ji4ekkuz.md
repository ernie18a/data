# Corwin-Schultz Spread Bands [forexobroker]

- url: https://www.tradingview.com/script/ji4eKKuZ-Corwin-Schultz-Spread-Bands-forexobroker/
- type: indicator
- pine_id: PUB;c820e98f4f194f5bb343d4ec72e71c86
- version: 1.0

## Description

Corwin-Schultz Spread Bands [forexobroker] estimates the effective bid-ask spread directly from daily high-low data using the Corwin-Schultz (2012) two-bar estimator, then turns the rolling spread into a stress regime and a pair of price bands. The unique angle is using a peer-reviewed microstructure spread formula intended for daily data on any timeframe to flag liquidity stress on the chart and time entries when stress fades into a directional trend.

🔶 ALGORITHM

1. For each pair of adjacent bars compute beta = (ln(H_t / L_t))^2 + (ln(H_{t-1} / L_{t-1}))^2 and gamma = (ln(max(H_t, H_{t-1}) / min(L_t, L_{t-1})))^2.
2. Compute alpha = (sqrt(2 x beta) - sqrt(beta)) / (3 - 2 x sqrt(2)) - sqrt(gamma / (3 - 2 x sqrt(2))).
3. Raw spread = 2 x (exp(alpha) - 1) / (1 + exp(alpha)). Clamp to the [0, 1] range.
4. Smooth with EMA (default 5) to produce a stable percentage spread.
5. Rolling regime stats: 100-bar (default) median and stdev of the smoothed spread; threshold = median + k x stdev (default k = 1.0).
6. In-stress = smoothed spread above threshold. Exiting stress = was above on the prior bar and below now.
7. Trend filter: close versus 20-SMA (default).
8. Visual bands: close +/- (spread / 2) x close x mult.

🔶 SIGNAL LOGIC

- Buy: spread regime just exited stress AND close > trend SMA AND session filter passes AND posState was not long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: spread regime just exited stress AND close < trend SMA AND session filter passes AND posState was not short AND cooldown elapsed AND barstate.isconfirmed.

A flip-prevention posState plus cooldown bars (default 15) avoid stacking signals inside a single regime transition.

🔶 INPUTS

- Spread Estimator: smoothing EMA default 5, regime lookback default 100, stdev multiplier default 1.0.
- Signal Logic: trend SMA length default 20, cooldown bars default 15.
- Filters: optional session window default 0000-2400.
- Visual: spread band multiplier default 1.0, glow, fill, bands, stress bgcolor, neon palette, dashboard.

🔶 ALERTS

CSS Buy, CSS Sell, CSS Any Signal, CSS Enter Stress, CSS Exit Stress, CSS Spread Rising, CSS Spread Falling, CSS Trend Up, CSS Trend Down, CSS Extreme Spread, CSS Webhook JSON.

🔶 LIMITATIONS

- The estimator was designed for daily bars; on very low timeframes the high-low range gets dominated by tick noise and the spread value is noisier than the daily case.
- Spread is computed in price-fraction terms; reporting in basis points assumes that interpretation is meaningful for the instrument.
- The regime threshold depends on a 100-bar lookback, so on fresh history the threshold is unstable until the buffer is full.
- Signals require the regime to flip, so during long sideways regimes with no stress event the indicator can sit idle for many bars.
- The 20-SMA trend filter is intentionally simple and will misclassify direction during tight ranges.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Corwin-Schultz (2012) two-day high-low effective spread estimator. For each pair of
// adjacent bars compute beta = (ln(H_t/L_t))^2 + (ln(H_{t-1}/L_{t-1}))^2, gamma = (ln(maxH/minL))^2,
// alpha = (sqrt(2*beta) - sqrt(beta)) / (3 - 2*sqrt(2)) - sqrt(gamma / (3 - 2*sqrt(2))), spread =
// 2*(exp(alpha) - 1) / (1 + exp(alpha)). Spread is clamped to [0,1] and smoothed with EMA(5).
// Stress regime is spread > rolling 100-bar median + 1 stdev. Signals fire when the regime turns
// off (toxicity faded) aligned with a 20-SMA trend filter. Non-repainting: confirmed bars only.
indicator("Corwin-Schultz Spread Bands [forexobroker]", shorttitle="CSS [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_lines_count=500)

string g_calc = "Spread Estimator"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_smooth   = input.int(5,    "Spread EMA Smoothing",  minval=1,   maxval=50, group=g_calc)
int   i_regLen   = input.int(100,  "Regime Lookback",       minval=20,  maxval=500, group=g_calc, tooltip="Bars used for rolling median and stdev that define stress.")
float i_regK     = input.float(0.5, "Regime Stdev Mult",    minval=0.1, maxval=5.0, step=0.1, group=g_calc)
int   i_trendLen = input.int(20,   "Trend SMA Length",      minval=2,   maxval=200, group=g_sig)
int   i_cooldown = input.int(5,    "Cooldown Bars",         minval=1,   maxval=80, group=g_sig)
float i_bandMult = input.float(1.0,"Spread Band Mult",      minval=0.1, maxval=10.0, step=0.1, group=g_vis, tooltip="Visual scaling for the band width = close * spread/2 * mult.")
bool  i_useSess  = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showBands= input.bool(true, "Show Spread Bands",                            group=g_vis)
bool  i_showFill = input.bool(true, "Shade Band Fill",                              group=g_vis)
bool  i_showBg   = input.bool(true, "Highlight Stress Regime",                      group=g_vis)
bool  i_showTable= input.bool(true, "Show Dashboard",                               group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                            group=g_vis)
color i_buyColor = input.color(#22d3ee, "Buy Color",                                group=g_vis)
color i_sellColor= input.color(#f472b6, "Sell Color",                               group=g_vis)
color i_stressCol= input.color(#fb923c, "Stress Regime Color",                      group=g_vis)
color i_dashBg   = input.color(color.new(#0a1620, 18), "Dashboard BG",              group=g_vis)

color c_white = #ffffff

float h0 = high
float l0 = low
float h1 = high[1]
float l1 = low[1]
float lnHL0 = math.log(h0 / l0)
float lnHL1 = math.log(h1 / l1)
float beta  = lnHL0 * lnHL0 + lnHL1 * lnHL1
float maxH  = math.max(h0, h1)
float minL  = math.min(l0, l1)
float lnHLg = math.log(maxH / minL)
float gamma = lnHLg * lnHLg
float den   = 3.0 - 2.0 * math.sqrt(2.0)
float alpha = (math.sqrt(2.0 * beta) - math.sqrt(beta)) / den - math.sqrt(gamma / den)
float spreadRaw = 2.0 * (math.exp(alpha) - 1.0) / (1.0 + math.exp(alpha))
float spread = math.max(0.0, math.min(1.0, nz(spreadRaw, 0.0)))
float spreadEma = ta.ema(spread, i_smooth)

float regMed   = ta.percentile_linear_interpolation(spreadEma, i_regLen, 50)
float regStd   = ta.stdev(spreadEma, i_regLen)
float regThr   = regMed + i_regK * regStd
bool  inStress = spreadEma > regThr
bool  wasStress= inStress[1]
bool  leftStress = wasStress and not inStress

float trendSma = ta.sma(close, i_trendLen)
bool  bullTrend = close > trendSma
bool  bearTrend = close < trendSma
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool buyRaw  = leftStress and bullTrend and inSession
bool sellRaw = leftStress and bearTrend and inSession
bool buySignal  = buyRaw  and posState <= 0 and cooldownOk and confirmed
bool sellSignal = sellRaw and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

float bandHalf = close * spreadEma * 0.5 * i_bandMult
float upBand   = close + bandHalf
float dnBand   = close - bandHalf

plot(i_showBands ? upBand : na, "Upper Band", color=color.new(i_buyColor, 30), linewidth=1)
plot(i_showBands ? dnBand : na, "Lower Band", color=color.new(i_sellColor, 30), linewidth=1)
p_up = plot(i_showBands and i_showFill ? upBand : na, "BandFillUp", color=color.new(i_buyColor, 95), display=display.none)
p_dn = plot(i_showBands and i_showFill ? dnBand : na, "BandFillDn", color=color.new(i_sellColor, 95), display=display.none)
fill(p_up, p_dn, color=i_showFill ? color.new(i_buyColor, 92) : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CSS", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CSS", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(i_showBg and inStress ? color.new(i_stressCol, 90) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string st = inStress ? "STRESS" : leftStress ? "EXITING STRESS" : "CALM"
    color  sc = inStress ? i_stressCol : leftStress ? i_buyColor : color.gray
    table.cell(dash, 0, 0, "Corwin-Schultz Spread", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Spread (smoothed)",     text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(spreadEma * 10000.0, "#.##") + " bp", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Threshold",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(regThr * 10000.0, "#.##") + " bp",    text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Median (lookback)",     text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(regMed * 10000.0, "#.##") + " bp",    text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Trend Bias",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, bullTrend ? "BULL" : bearTrend ? "BEAR" : "FLAT", text_color=bullTrend ? i_buyColor : bearTrend ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Band Width",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(bandHalf * 2.0, "#.#####"),           text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 7, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CSS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"spread_bp":' + str.tostring(spreadEma * 10000.0) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CSS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"spread_bp":' + str.tostring(spreadEma * 10000.0) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                       "CSS Buy",             "Spread regime exit long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                      "CSS Sell",            "Spread regime exit short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,         "CSS Any Signal",      "Any CSS signal on {{ticker}} {{interval}}")
alertcondition(inStress and not inStress[1],    "CSS Enter Stress",    "Spread entered stress regime on {{ticker}} {{interval}}")
alertcondition(leftStress,                      "CSS Exit Stress",     "Spread left stress regime on {{ticker}} {{interval}}")
alertcondition(spreadEma > spreadEma[1] and spreadEma[1] > spreadEma[2], "CSS Spread Rising", "Spread rising 2 bars on {{ticker}} {{interval}}")
alertcondition(spreadEma < spreadEma[1] and spreadEma[1] < spreadEma[2], "CSS Spread Falling","Spread falling 2 bars on {{ticker}} {{interval}}")
alertcondition(ta.crossover(close, trendSma),   "CSS Trend Up",        "Close crossed above trend SMA on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(close, trendSma),  "CSS Trend Down",      "Close crossed below trend SMA on {{ticker}} {{interval}}")
alertcondition(spreadEma > regThr * 2.0,        "CSS Extreme Spread",  "Spread is 2x threshold on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,         "CSS Webhook JSON",    "{\"action\":\"signal\",\"indicator\":\"CSS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
