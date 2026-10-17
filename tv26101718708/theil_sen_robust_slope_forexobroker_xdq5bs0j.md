# Theil Sen Robust Slope [forexobroker]

- url: https://www.tradingview.com/script/Xdq5BS0J-Theil-Sen-Robust-Slope-forexobroker/
- type: indicator
- pine_id: PUB;e76534853429447887f02d2a4a887444
- version: 1.0

## Description

Theil Sen Robust Slope replaces ordinary least squares with the Theil-Sen estimator: the median of the slopes of all C(N, 2) pairwise lines through the last N closes. Robust to outliers up to a 29 percent breakdown point — a single price spike cannot drag the line. Pairs with a median intercept to give a regression line that ignores wicks and gaps.

🔶 ALGORITHM

1. For each pair (i, j) with i < j in the window, compute slope_ij = (close[i] - close[j]) / (j - i).
2. slope = median(slope_ij) across all C(N, 2) pairs (190 for N = 20).
3. intercept = median(close[i] + i * slope) for i in [0, N-1] -> regression line value at the current bar.
4. Trending regime when |slope| > k * ATR per bar.

🔶 SIGNAL LOGIC

- Buy: trending regime up AND close crosses regression line up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: mirror.
- Position-lock state machine.

🔶 INPUTS

- Window N (default 20 -> 190 pairs)
- Slope Threshold x ATR/bar (default 0.10)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, regression line, buy / sell colors

🔶 ALERTS

TSR Buy, TSR Sell, TSR Any Signal, TSR Trend Up Start, TSR Trend Down Start, TSR Cross Up, TSR Cross Down, TSR Slope Zero, TSR Webhook JSON.

🔶 LIMITATIONS

- Computational cost = N * (N - 1) / 2 slope computations per bar. N = 40 is the practical maximum on most plans (780 pairs).
- Theil-Sen is robust to a few outliers but not to sustained regime change; the line lags during fast directional moves.
- Window N must be >= 10 for a meaningful median; very short windows produce noisy slopes.
- Defaults tuned for liquid majors / indices. For low-volatility assets, lower the slope threshold.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Theil-Sen estimator — for a window of N observations, compute the slope between every
// pair (i,j), then take the median of all N x (N-1) / 2 slopes. Robust to outliers up to a 29%
// breakdown point — a single price spike cannot drag the line. The intercept is the median of
// (close[i] + i x slope), giving the regression value at the current bar. Signals fire on close vs
// regression-line cross within an ATR-normalised trending regime. Outperforms ordinary least
// squares on heavy-tailed price series. Different from any standard linear regression bands.
indicator("Theil Sen Robust Slope [forexobroker]", shorttitle="TSR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc   = "Theil-Sen"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(20,    "Window N (pairs = N x (N-1) / 2)", minval=10, maxval=40, group=g_calc, tooltip="N=20 -> 190 pairwise slopes per bar.")
float i_slopeK   = input.float(0.10, "Slope Threshold x ATR/bar",       minval=0.01, maxval=2.0, step=0.01, group=g_signal, tooltip="|slope| must exceed k x (ATR/bar) for a 'trending' regime.")
int   i_cooldown = input.int(4,      "Cooldown Bars",                   minval=1, maxval=20,                group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard",                  group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow",               group=g_visual)
bool  i_showLine  = input.bool(true, "Show Theil-Sen Line",             group=g_visual)
color i_buyColor  = input.color(#39ff14, "Buy Color (Lime)",            group=g_visual)
color i_sellColor = input.color(#ff2d78, "Sell Color (Pink)",           group=g_visual)

color c_white = #ffffff

// ─── PAIRWISE SLOPES + MEDIAN INTERCEPT ────────────────────────────────────────
int N = i_winLen
int pairs = N * (N - 1) / 2

var float[] slopeArr = array.new_float(0)
var float[] intArr   = array.new_float(0)
array.clear(slopeArr)
array.clear(intArr)

for i = 0 to N - 2
    for j = i + 1 to N - 1
        float dy = nz(close[i]) - nz(close[j])
        float dx = j - i
        if dx > 0
            array.push(slopeArr, dy / dx)

float slope = array.size(slopeArr) > 0 ? array.median(slopeArr) : 0.0

for i = 0 to N - 1
    array.push(intArr, nz(close[i]) + i * slope)

float regLine = array.size(intArr) > 0 ? array.median(intArr) : close

// ─── REGIME + ENTRY ───────────────────────────────────────────────────────────
float atr14    = nz(ta.atr(14), 0.0)
float slopeThr = i_slopeK * atr14
bool  trendUp   = slope >  slopeThr
bool  trendDown = slope < -slopeThr
bool  crossUp   = ta.crossover(close, regLine)
bool  crossDn   = ta.crossunder(close, regLine)
bool  entryUp   = trendUp   and crossUp
bool  entryDown = trendDown and crossDn

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

// ─── VISUAL ───────────────────────────────────────────────────────────────────
color lineCol = trendUp ? i_buyColor : trendDown ? i_sellColor : color.new(color.gray, 40)
plot(i_showLine ? regLine : na, "Theil-Sen", color=lineCol, linewidth=3)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="TSR up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="TSR dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trendUp ? color.new(i_buyColor, 95) : trendDown ? color.new(i_sellColor, 95) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = trendUp ? "TRENDING UP" : trendDown ? "TRENDING DOWN" : "FLAT"
    color  regimeCol = trendUp ? i_buyColor : trendDown ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Theil Sen Robust Slope", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Slope/Bar",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(slope, "0.0000"),    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Threshold",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(slopeThr, "0.0000"), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Pairs Used",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(pairs),      text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "TS Line",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(regLine, "#.##"),    text_color=close > regLine ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"TSR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"slope":' + str.tostring(slope, "0.0000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"TSR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"slope":' + str.tostring(slope, "0.0000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "TSR Buy",              "Theil-Sen bull cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "TSR Sell",             "Theil-Sen bear cross on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "TSR Any Signal",       "Any TSR signal on {{ticker}} {{interval}}")
alertcondition(trendUp     and not trendUp[1],             "TSR Trend Up Start",   "Theil-Sen entered up trend on {{ticker}} {{interval}}")
alertcondition(trendDown   and not trendDown[1],           "TSR Trend Down Start", "Theil-Sen entered down trend on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "TSR Cross Up",         "Close crossed Theil-Sen line up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "TSR Cross Down",       "Close crossed Theil-Sen line down on {{ticker}} {{interval}}")
alertcondition(slope == 0,                                 "TSR Slope Zero",       "Theil-Sen slope is zero on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "TSR Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"TSR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
