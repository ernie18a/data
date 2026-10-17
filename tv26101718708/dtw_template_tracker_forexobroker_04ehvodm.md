# DTW Template Tracker [forexobroker]

- url: https://www.tradingview.com/script/04ehVOdM-DTW-Template-Tracker-forexobroker/
- type: indicator
- pine_id: PUB;752be135221a446b8127a71d6b7231d3
- version: 1.0

## Description

DTW Template Tracker uses simplified Dynamic Time Warping with a Sakoe-Chiba band (width 2) to align recent z-scored closes against monotone bull (linear rise) and bear (linear fall) templates. DTW allows time stretching that cosine similarity does not. Lower distance = closer match; signal fires when one template's distance is materially lower than the other and below an absolute threshold.

🔶 ALGORITHM

1. Z-score the recent N closes using rolling mean and stdev.
2. Build templates: bull = linspace(-1, +1) over N points; bear = -bull.
3. DTW with Sakoe-Chiba band W = 2: cost matrix D[i,j] is filled only within |i - j| <= W. D[i,j] = |x[i] - t[j]| + min(D[i-1,j-1], D[i-1,j], D[i,j-1]).
4. Bull and bear distances = D[N-1, N-1] under each template.
5. Match when one distance < other AND <= threshold.

🔶 SIGNAL LOGIC

- Buy: bull match edge AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: bear match edge.
- Position-lock state machine.

🔶 INPUTS

- Template Length (default 15)
- DTW Distance Threshold (default 2.0)
- Cooldown Bars (default 4)
- Visual: dashboard, glow (flag with "match"), template overlay, buy / sell colors

🔶 ALERTS

DTT Buy, DTT Sell, DTT Any Signal, DTT Bull Match, DTT Bear Match, DTT Bull Tight, DTT Bear Tight, DTT Strong, DTT Webhook JSON.

🔶 LIMITATIONS

- DTW cost grows ~ N * W per bar; defaults (N = 15, W = 2) keep compute reasonable. Larger N exceeds Pine compute budget.
- Sakoe-Chiba band W = 2 limits stretch to +/- 2 bars; useful for 1:1 matching with minor jitter.
- Monotone templates only — V-shaped or W-shaped patterns require additional template definitions.
- Z-scoring removes scale; the indicator is invariant to absolute price level.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Simplified Dynamic Time Warping. The recent N closes (z-scored) are aligned against
// a monotone bull template (linear rise) and bear template (linear fall) using the standard DTW
// distance with a Sakoe-Chiba band of width 2 to keep computation tractable. Lower DTW distance =
// closer match. Signals fire when one template's distance is materially lower than the other and
// below an absolute threshold. Distinct from CWM: DTW allows time stretching, cosine similarity does not.
indicator("DTW Template Tracker [forexobroker]", shorttitle="DTT [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "DTW"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(15,   "Template Length",       minval=8, maxval=30, group=g_calc, tooltip="DTW cost grows ~ N^2 (with band). Keep N <= 25 for performance.")
float i_distThr  = input.float(5.0,"DTW Distance Threshold", minval=0.5, maxval=20.0, step=0.5, group=g_sig, tooltip="DTW distances scale with template length; ~4-10 is typical for N=15.")
int   i_cooldown = input.int(4,    "Cooldown Bars",         minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
bool  i_showTpl  = input.bool(true,"Show Template Overlay",                       group=g_vis)
color i_buyColor = input.color(#00e5ff,"Buy Color (Aqua)",                        group=g_vis)
color i_sellColor= input.color(#ff7043,"Sell Color (Salmon)",                     group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#001a1f, 22)

// ─── BUILD Z-SCORED RECENT WINDOW + TEMPLATES ──────────────────────────────────
int N = i_winLen
float meanX = ta.sma(close, N)
float sdX   = ta.stdev(close, N)
var float[] x = array.new_float(0)
array.clear(x)
for k = 0 to N - 1
    array.push(x, sdX > 0 ? (nz(close[N - 1 - k]) - meanX) / sdX : 0.0)

// Templates: bull = linspace(-1, +1); bear = linspace(+1, -1)
var float[] tBull = array.new_float(0)
var float[] tBear = array.new_float(0)
array.clear(tBull)
array.clear(tBear)
for k = 0 to N - 1
    float t = -1.0 + 2.0 * k / (N - 1)
    array.push(tBull, t)
    array.push(tBear, -t)

// Simplified DTW with Sakoe-Chiba band w = 2
f_dtw(float[] a, float[] b, int W) =>
    int n = array.size(a)
    var float[] D = array.new_float(0)
    array.clear(D)
    for ii = 0 to n - 1
        for jj = 0 to n - 1
            array.push(D, 1e10)
    for ii = 0 to n - 1
        int jStart = math.max(0, ii - W)
        int jEnd   = math.min(n - 1, ii + W)
        for jj = jStart to jEnd
            float d = math.abs(array.get(a, ii) - array.get(b, jj))
            float prev = ii > 0 and jj > 0 ? array.get(D, (ii - 1) * n + jj - 1) : 0.0
            float up   = ii > 0 ? array.get(D, (ii - 1) * n + jj)               : 1e10
            float left = jj > 0 ? array.get(D, ii * n + jj - 1)                 : 1e10
            float costMin = math.min(prev, math.min(up, left))
            if ii == 0 and jj == 0
                array.set(D, 0, d)
            else
                array.set(D, ii * n + jj, d + costMin)
    array.get(D, n * n - 1)

float dBull = f_dtw(x, tBull, 2)
float dBear = f_dtw(x, tBear, 2)

bool  bullMatch = dBull < dBear and dBull <= i_distThr
bool  bearMatch = dBear < dBull and dBear <= i_distThr
bool  bullEdge  = bullMatch and not bullMatch[1]
bool  bearEdge  = bearMatch and not bearMatch[1]

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = bullEdge and posState <= 0 and cooldownOk and confirmed
bool sellSignal = bearEdge and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// ─── VISUAL: flag with "match" + warped template overlay ──────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge,   text="match")
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large,  text="match")
plotshape(buySignal,                 "Buy",         shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="DTT B!", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  text="match")
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large, text="match")
plotshape(sellSignal,                "Sell",        shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="DTT S!", textcolor=c_white)

// Template visual: bull = rising bar from -ATR to +ATR centered on EMA20; bear = mirror
float anchor = ta.sma(close, N)
float tplVal = bullMatch ? anchor + nz(ta.atr(14), 0) * 0.5 : bearMatch ? anchor - nz(ta.atr(14), 0) * 0.5 : na
plot(i_showTpl ? tplVal : na, "Template Match", color=color.new(color.yellow, 30), linewidth=2, style=plot.style_circles)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullMatch ? color.new(i_buyColor, 95) : bearMatch ? color.new(i_sellColor, 95) : na)

// ─── DASHBOARD (top-left, aqua/salmon, 8 rows, distinct border style) ──────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 40), border_width=2)
    string regimeTxt = bullMatch ? "BULL TEMPLATE" : bearMatch ? "BEAR TEMPLATE" : "NO MATCH"
    color  regimeCol = bullMatch ? i_buyColor : bearMatch ? i_sellColor : color.silver
    table.cell(dash, 0, 0, "DTW Template Tracker", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Bull Distance",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(dBull, "0.00"),    text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 2, "Bear Distance",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(dBear, "0.00"),    text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Threshold",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_distThr, "0.00"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Template Length",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(N) + " bars",      text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Match",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,              text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"DTT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"d_bull":' + str.tostring(dBull, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"DTT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"d_bear":' + str.tostring(dBear, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "DTT Buy",          "DTW bull match on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "DTT Sell",         "DTW bear match on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "DTT Any Signal",   "Any DTT signal on {{ticker}} {{interval}}")
alertcondition(bullMatch and not bullMatch[1],             "DTT Bull Match",   "DTW bull match started on {{ticker}} {{interval}}")
alertcondition(bearMatch and not bearMatch[1],             "DTT Bear Match",   "DTW bear match started on {{ticker}} {{interval}}")
alertcondition(dBull < 1.0,                                "DTT Bull Tight",   "DTW bull distance < 1.0 on {{ticker}} {{interval}}")
alertcondition(dBear < 1.0,                                "DTT Bear Tight",   "DTW bear distance < 1.0 on {{ticker}} {{interval}}")
alertcondition(math.abs(dBull - dBear) > 1.5,              "DTT Strong",       "Strong template asymmetry on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "DTT Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"DTT\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
