# Quantile Drift Engine [forexobroker]

- url: https://www.tradingview.com/script/z5rYLUtu-Quantile-Drift-Engine-forexobroker/
- type: indicator
- pine_id: PUB;e062cc3534e94c0cb5eaf03db8553bfa
- version: 1.0

## Description

Quantile Drift Engine uses the rolling 25th and 75th percentiles of close as a robust analogue to mean and variance. The midpoint between Q25 and Q75 is the "interquartile median," which drifts directionally and is far less sensitive to spikes than a moving average. The drift, normalised by ATR, provides the regime gate; close cross of the midpoint provides the entry.

🔶 ALGORITHM

1. q25 = ta.percentile_linear_interpolation(close, N, 25); q75 = same at 75.
2. mid = (q25 + q75) / 2; drift = mid - mid[lag].
3. Trending regime when |drift| > k * ATR.
4. Buy entry: trending up AND close crosses mid up.
5. Sell entry: trending down AND close crosses mid down.

🔶 SIGNAL LOGIC

- Buy: trending up AND close crosses mid up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: trending down AND close crosses mid down.
- Position-lock state machine.

🔶 INPUTS

- Quantile Window (default 40)
- Drift Lag (default 5 bars)
- Drift Threshold x ATR (default 0.10)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, quantile bands, buy / sell colors

🔶 ALERTS

QDE Buy, QDE Sell, QDE Any Signal, QDE Drift Up, QDE Drift Down, QDE Mid Cross Up, QDE Mid Cross Dn, QDE Outside IQR, QDE Webhook JSON.

🔶 LIMITATIONS

- Percentile estimators need >= ~10 samples to be meaningful; short windows produce step-like quantiles.
- Linear interpolation between samples introduces minor smoothing; raw ranking would be slightly more responsive.
- Drift lag of 5 bars dampens noise but causes slight delay during sharp directional moves.
- IQR midpoint is robust but ignores tail behaviour; for tail-driven instruments pair with a separate volatility filter.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Rolling 25th and 75th percentile of close. The midpoint between them ("interquartile
// midpoint") drifts directionally and is far more robust to spikes than a mean. Drift = midpoint
// minus its lagged value, normalised to ATR. Signals fire when the drift sign agrees with a
// close-cross of the midpoint, gated by a regime where drift magnitude exceeds k * ATR.
// Distinct from any moving-average system: order statistics ignore extremes by construction.
indicator("Quantile Drift Engine [forexobroker]", shorttitle="QDE [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Quantile"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(40, "Quantile Window", minval=10, maxval=200, group=g_calc)
int   i_lagLen   = input.int(5,  "Drift Lag (bars)", minval=1, maxval=20, group=g_calc)
float i_driftK   = input.float(0.10,"Drift Threshold x ATR", minval=0.01, maxval=2.0, step=0.01, group=g_signal)
int   i_cooldown = input.int(4, "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showBands = input.bool(true, "Show Quantile Bands", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

float q25 = ta.percentile_linear_interpolation(close, i_winLen, 25)
float q75 = ta.percentile_linear_interpolation(close, i_winLen, 75)
float mid = (q25 + q75) / 2.0
float drift = mid - mid[i_lagLen]

float atr14 = nz(ta.atr(14), 0.0)
float driftThr = i_driftK * atr14
bool  trendUp = drift >  driftThr
bool  trendDn = drift < -driftThr
bool  crossUp = ta.crossover(close, mid)
bool  crossDn = ta.crossunder(close, mid)
bool  entryUp   = trendUp and crossUp
bool  entryDown = trendDn and crossDn

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and posState <= 0 and cooldownOk and confirmed
bool sellSignal = entryDown and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

color midCol = trendUp ? i_buyColor : trendDn ? i_sellColor : color.new(color.gray, 50)
plot(i_showBands ? q75 : na, "Q75", color=color.new(i_buyColor, 50), linewidth=1)
plot(i_showBands ? mid : na, "Mid", color=midCol, linewidth=2)
plot(i_showBands ? q25 : na, "Q25", color=color.new(i_sellColor, 50), linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="QDE up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="QDE dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trendUp ? color.new(i_buyColor, 95) : trendDn ? color.new(i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = trendUp ? "DRIFT UP" : trendDn ? "DRIFT DOWN" : "FLAT"
    color  regimeCol = trendUp ? i_buyColor : trendDn ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Quantile Drift Engine", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Q75",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(q75, "#.##"),     text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 2, "Mid",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(mid, "#.##"),     text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Q25",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(q25, "#.##"),     text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Drift",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(drift, "#.######"), text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,               text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"QDE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"drift":' + str.tostring(drift, "#.######") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"QDE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"drift":' + str.tostring(drift, "#.######") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "QDE Buy",          "Quantile drift bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "QDE Sell",         "Quantile drift bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "QDE Any Signal",   "Any QDE signal on {{ticker}} {{interval}}")
alertcondition(trendUp and not trendUp[1],                 "QDE Drift Up",     "Drift turned up on {{ticker}} {{interval}}")
alertcondition(trendDn and not trendDn[1],                 "QDE Drift Down",   "Drift turned down on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "QDE Mid Cross Up", "Close crossed mid up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "QDE Mid Cross Dn", "Close crossed mid down on {{ticker}} {{interval}}")
alertcondition(close > q75 or close < q25,                 "QDE Outside IQR",  "Close outside interquartile range on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "QDE Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"QDE\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
