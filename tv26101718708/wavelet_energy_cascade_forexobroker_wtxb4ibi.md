# Wavelet Energy Cascade [forexobroker]

- url: https://www.tradingview.com/script/WTXB4Ibi-Wavelet-Energy-Cascade-forexobroker/
- type: indicator
- pine_id: PUB;3bde0aa1b2a8418a977dcaec3173054e
- version: 1.0

## Description

Wavelet Energy Cascade decomposes close into 4 dyadic Haar wavelet scales (lengths 1, 2, 4, 8) and tracks their energies. Coarse-scale dominance over fine-scale signals trending; fine-scale dominance signals noise. The coarse Haar smoothed line provides the entry trigger. Distinct from any moving average: wavelets are a multi-resolution decomposition with explicit energy bookkeeping per scale.

🔶 ALGORITHM

1. Haar coefficient at scale s = (avg of s most recent - avg of s prior) / sqrt(2).
2. Compute coefficients h1, h2, h4, h8.
3. Energy_s = math.sum(h_s^2, lookback) — squared coefficients summed over a rolling window.
4. fine = e1 + e2; coarse = e4 + e8.
5. Trending regime when coarse > k * fine.
6. Coarse Haar smoother (sma(close, 8)) provides the entry-trigger reference.

🔶 SIGNAL LOGIC

- Buy: trending AND close crosses coarse line up AND h8 > 0 AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: trending AND close crosses coarse line down AND h8 < 0.
- Position-lock state machine.

🔶 INPUTS

- Energy Lookback (default 40)
- Coarse / Fine Dominance k (default 1.5)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, coarse line, buy / sell colors

🔶 ALERTS

WEC Buy, WEC Sell, WEC Any Signal, WEC Trend Start, WEC Trend End, WEC Strong Trend, WEC Cross Up, WEC Cross Down, WEC Webhook JSON.

🔶 LIMITATIONS

- Haar is the simplest wavelet (orthogonal, but with sharp edges); for smoother decomposition, Daubechies-like wavelets would help — at higher Pine cost.
- Only 4 scales; missing very-low or very-high frequencies if they matter for the asset.
- Energy lookback dominates the smoothing trade-off; smaller = more responsive, noisier.
- The h8 sign gate ensures direction agrees with the coarse-scale wavelet; rare divergences are filtered.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Haar wavelet decomposition over 4 dyadic scales (lengths 2, 4, 8, 16). At each scale,
// the wavelet coefficient is the difference of average price between the two halves of the
// scale-window; energy = squared coefficient summed over a lookback. Coarse-scale dominance
// indicates trending; fine-scale dominance indicates noise. Signals fire when the coarse-scale
// Haar smoothed line is crossed by close in the active direction.
indicator("Wavelet Energy Cascade [forexobroker]", shorttitle="WEC [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Wavelet"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_lookback = input.int(40,   "Energy Lookback",   minval=10, maxval=200, group=g_calc)
float i_dominK   = input.float(1.5,"Coarse / Fine Dominance", minval=1.0, maxval=5.0, step=0.1, group=g_sig, tooltip="Coarse-scale energy must exceed fine by this factor for trending regime.")
int   i_cooldown = input.int(4,    "Cooldown Bars",     minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true,"Show Dashboard",                         group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                      group=g_vis)
bool  i_showLine = input.bool(true,"Show Coarse Wavelet Line",               group=g_vis)
color i_buyColor = input.color(#aeea00,"Buy Color (Yellow-Green)",           group=g_vis)
color i_sellColor= input.color(#ff3d00,"Sell Color (Orange-Red)",            group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#1a1a00, 22)

// ─── HAAR WAVELET COEFFICIENTS ─────────────────────────────────────────────────
// Scale s: coefficient = (avg of s most recent) - (avg of s prior) / sqrt(2)
f_haar(int s) =>
    float a = 0.0
    float b = 0.0
    for k = 0 to s - 1
        a += nz(close[k])
        b += nz(close[k + s])
    (a / s - b / s) / math.sqrt(2)

float h1 = f_haar(1)
float h2 = f_haar(2)
float h4 = f_haar(4)
float h8 = f_haar(8)

// Energy = squared coefficient summed over lookback (using running sum)
float e1 = math.sum(h1 * h1, i_lookback)
float e2 = math.sum(h2 * h2, i_lookback)
float e4 = math.sum(h4 * h4, i_lookback)
float e8 = math.sum(h8 * h8, i_lookback)
float fine   = e1 + e2
float coarse = e4 + e8
bool  trending = coarse > i_dominK * fine

// Coarse Haar smoother = sma(close, 8)
float coarseLine = ta.sma(close, 8)
bool  crossUp = ta.crossover(close, coarseLine)
bool  crossDn = ta.crossunder(close, coarseLine)
bool  entryUp   = trending and crossUp and h8 > 0
bool  entryDown = trending and crossDn and h8 < 0

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
color lineCol = trending ? (h8 > 0 ? i_buyColor : i_sellColor) : color.new(color.gray, 40)
plot(i_showLine ? coarseLine : na, "Coarse Wavelet (s=8)", color=lineCol, linewidth=3)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="WEC up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="WEC dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(trending ? color.new(h8 > 0 ? i_buyColor : i_sellColor, 95) : na)

// ─── DASHBOARD (top-center, yellow-green theme, 9 rows showing all 4 energies) ─
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 60), border_width=1)
    string regimeTxt = trending ? (h8 > 0 ? "TRENDING UP" : "TRENDING DOWN") : "MIXED"
    color  regimeCol = trending ? (h8 > 0 ? i_buyColor : i_sellColor) : color.silver
    table.cell(dash, 0, 0, "Wavelet Energy Cascade", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "E(s=1)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(e1, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 2, "E(s=2)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(e2, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "E(s=4)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(e4, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "E(s=8)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(e8, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Coarse / Fine",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(fine > 0 ? coarse / fine : 0, "0.00") + "x", text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Regime",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, regimeTxt,                text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 7, "Position",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"WEC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"coarse_fine":' + str.tostring(fine > 0 ? coarse / fine : 0, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"WEC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"coarse_fine":' + str.tostring(fine > 0 ? coarse / fine : 0, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "WEC Buy",          "Wavelet trending bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "WEC Sell",         "Wavelet trending bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "WEC Any Signal",   "Any WEC signal on {{ticker}} {{interval}}")
alertcondition(trending and not trending[1],               "WEC Trend Start",  "Trending wavelet regime on {{ticker}} {{interval}}")
alertcondition(not trending and trending[1],               "WEC Trend End",    "Trending wavelet regime ended on {{ticker}} {{interval}}")
alertcondition(coarse > 3.0 * fine,                        "WEC Strong Trend", "Coarse / fine > 3x on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "WEC Cross Up",     "Close crossed coarse Haar up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "WEC Cross Down",   "Close crossed coarse Haar down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "WEC Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"WEC\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
