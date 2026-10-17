# Empirical Mode Decomposition Trend Helix [forexobroker]

- url: https://www.tradingview.com/script/yjn4pHMm-Empirical-Mode-Decomposition-Trend-Helix-forexobroker/
- type: indicator
- pine_id: PUB;d4b33325367c4a28b77309c501d1ff19
- version: 1.0

## Description

Empirical Mode Decomposition Trend Helix [forexobroker] applies a simplified EMD sift to separate price into a trend residual and a high-frequency intrinsic mode (IMF1). Rather than relying on a fixed-length moving average, the trend is built from the mean of local upper and lower envelopes, then re-sifted for smoothness. Trade signals fire only when the high-frequency component crosses zero in the direction of the larger trend slope. The unique angle is bringing a Huang-style adaptive decomposition concept into Pine using rolling extrema as a tractable envelope proxy.

🔶 ALGORITHM

1. Take rolling local maxima and minima of close over the extrema window (default 10) using highest/lowest.
2. Smooth each into an upper envelope and a lower envelope by SMA of the envelope smoothing length (default 5).
3. Mean envelope m_t = (upper + lower) / 2 is the trend residual for this iteration.
4. Repeat the sift the configured number of iterations (default 2), using the previous m_t as the input each round.
5. IMF1 (high-frequency component) = close minus the final trend.
6. Slope of the trend over the slope lookback (default 5 bars) defines direction; bullish if slope greater than zero (plus min-slope threshold), bearish if less than minus the threshold.
7. Signals: IMF1 zero-crossings aligned with trend direction.

🔶 SIGNAL LOGIC

- Buy: IMF1 crosses above zero AND trend slope is positive AND position is not already long AND session filter passes AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: IMF1 crosses below zero AND trend slope is negative AND position is not already short AND session filter passes AND cooldown bars elapsed AND barstate.isconfirmed.

Cross-direction confirmation prevents trading mean-reversion bounces against the underlying trend residual.

🔶 INPUTS

- EMD Sift group: extrema window default 10, envelope smooth default 5, sift iterations default 2, slope lookback default 5.
- Signal Logic group: cooldown bars default 15, min slope (price units) default 0.
- Filters group: session restriction default 0000-2400.
- Visual group: show trend helix, dashboard, 3-layer glow, helix gradient colors, buy/sell colors, dashboard background.

🔶 ALERTS

EMD Buy, EMD Sell, EMD Any Signal, EMD IMF1 Up, EMD IMF1 Down, EMD Trend Turn Up, EMD Trend Turn Dn, EMD Big Excursion, EMD Close Over, EMD Close Under, EMD Webhook JSON.

🔶 LIMITATIONS

- This is a simplified EMD: rolling extrema and SMA envelopes are not the cubic-spline envelopes of formal Huang EMD; expect smoother but less curvature-aware decomposition.
- The sift uses fixed iterations rather than a stoppage criterion, so it does not guarantee a true zero-mean IMF.
- Trend slope is a local linear estimate; long pauses or gaps can flip the slope sign transiently.
- The envelope smoothing introduces lag of roughly half the envelope window into the trend output.
- Signals require simultaneous IMF zero-cross and slope alignment, so during sideways markets the indicator will be quiet by design.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Empirical Mode Decomposition Trend Helix. A simplified two-iteration EMD sift extracts
// a smooth trend residual and a high-frequency IMF1 from price. Local maxima/minima envelopes are
// approximated by SMA-smoothing rolling highest/lowest windows; the mean envelope m_t is the trend.
// Sift is iterated twice (next iteration treats m_t as the new signal) for a smoother residual.
// IMF1 = close - trend. Signals fire on IMF1 zero-crossings aligned with the trend slope direction.
// Non-repainting: signals confirm at bar close.
indicator("Empirical Mode Decomposition Trend Helix [forexobroker]", shorttitle="EMD [fob]", overlay=true, max_labels_count=500, max_lines_count=500)

string g_calc = "EMD Sift"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_extLen   = input.int(10,   "Extrema Window",      minval=3,  maxval=50, group=g_calc, tooltip="Rolling window for local highest/lowest.")
int   i_envSmooth= input.int(5,    "Envelope Smooth",     minval=2,  maxval=30, group=g_calc, tooltip="SMA length applied to envelopes.")
int   i_siftIter = input.int(2,    "Sift Iterations",     minval=1,  maxval=4,  group=g_calc, tooltip="Two iterations approximates one full IMF.")
int   i_slopeLen = input.int(5,    "Slope Lookback",      minval=2,  maxval=30, group=g_calc, tooltip="Bars used to measure trend slope.")
int   i_cooldown = input.int(5,    "Cooldown Bars",       minval=1,  maxval=60, group=g_sig)
float i_slopeMin = input.float(0.0,"Min Slope (price)",   minval=0.0,maxval=10.0, step=0.01, group=g_sig, tooltip="Slope magnitude required to qualify a signal.")
bool  i_useSess  = input.bool(false,"Restrict to Session",                       group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                  group=g_filt)
bool  i_showTrend= input.bool(true,"Show Trend Helix",                           group=g_vis)
bool  i_showTable= input.bool(true,"Show Dashboard",                             group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                          group=g_vis)
color i_buyColor = input.color(#00ffd1,"Buy Color",                              group=g_vis)
color i_sellColor= input.color(#ff3df0,"Sell Color",                             group=g_vis)
color i_helix1   = input.color(#7df9ff,"Helix Color 1",                          group=g_vis)
color i_helix2   = input.color(#c084fc,"Helix Color 2",                          group=g_vis)
color i_dashBg   = input.color(color.new(#0a0a1f, 16),"Dashboard BG",            group=g_vis)

color c_white = #ffffff

// One sift iteration: take a series, build local-extrema envelopes, return the mean envelope (trend).
f_sift(float src) =>
    float upper = ta.sma(ta.highest(src, i_extLen), i_envSmooth)
    float lower = ta.sma(ta.lowest(src,  i_extLen), i_envSmooth)
    (upper + lower) / 2.0

float t1 = f_sift(close)
float t2 = i_siftIter >= 2 ? f_sift(t1) : t1
float t3 = i_siftIter >= 3 ? f_sift(t2) : t2
float t4 = i_siftIter >= 4 ? f_sift(t3) : t3
float trend = i_siftIter <= 1 ? t1 : i_siftIter == 2 ? t2 : i_siftIter == 3 ? t3 : t4
float imf1  = close - trend

float slope = (trend - trend[i_slopeLen]) / i_slopeLen
bool  upTrend  = slope > i_slopeMin
bool  dnTrend  = slope < -i_slopeMin

bool zeroUp = ta.crossover(imf1, 0.0)
bool zeroDn = ta.crossunder(imf1, 0.0)
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = zeroUp and upTrend and posState <= 0 and inSession and cooldownOk and confirmed
bool sellSignal = zeroDn and dnTrend and posState >= 0 and inSession and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

color trendCol = slope > 0 ? i_helix1 : i_helix2
plot(i_showTrend ? trend : na,           "Trend (m_t)",   color=color.new(trendCol, 0),  linewidth=3)
plot(i_showTrend ? trend + math.abs(imf1)*0.5 : na, "Helix Upper", color=color.new(i_helix1, 70), linewidth=1)
plot(i_showTrend ? trend - math.abs(imf1)*0.5 : na, "Helix Lower", color=color.new(i_helix2, 70), linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="EMD", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="EMD", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(upTrend ? color.new(i_helix1, 94) : dnTrend ? color.new(i_helix2, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_helix1, 55), border_width=1)
    string trendLabel = upTrend ? "UP" : dnTrend ? "DOWN" : "FLAT"
    color  tc = upTrend ? i_buyColor : dnTrend ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "EMD Trend Helix",     text_color=i_helix1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",               text_color=color.new(i_helix1, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Trend",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendLabel,             text_color=tc, text_size=size.small)
    table.cell(dash, 0, 2, "Slope",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(slope, "0.0000"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "IMF1",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(imf1, "0.0000"), text_color=imf1 > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Trend Value",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(trend, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Sift Iterations",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(i_siftIter), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"EMD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"slope":' + str.tostring(slope, "0.0000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"EMD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"slope":' + str.tostring(slope, "0.0000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                       "EMD Buy",           "EMD aligned buy on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                      "EMD Sell",          "EMD aligned sell on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,         "EMD Any Signal",    "Any EMD signal on {{ticker}} {{interval}}")
alertcondition(zeroUp,                          "EMD IMF1 Up",       "IMF1 crossed above zero on {{ticker}} {{interval}}")
alertcondition(zeroDn,                          "EMD IMF1 Down",     "IMF1 crossed below zero on {{ticker}} {{interval}}")
alertcondition(upTrend and not upTrend[1],      "EMD Trend Turn Up", "Trend slope turned positive on {{ticker}} {{interval}}")
alertcondition(dnTrend and not dnTrend[1],      "EMD Trend Turn Dn", "Trend slope turned negative on {{ticker}} {{interval}}")
alertcondition(math.abs(imf1) > ta.atr(14) * 2, "EMD Big Excursion", "IMF1 large excursion on {{ticker}} {{interval}}")
alertcondition(ta.crossover(close, trend),      "EMD Close Over",    "Close crossed above trend on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(close, trend),     "EMD Close Under",   "Close crossed below trend on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,         "EMD Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"EMD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
