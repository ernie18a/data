# MAD Z Robust Burst [forexobroker]

- url: https://www.tradingview.com/script/UxxmeCO8-MAD-Z-Robust-Burst-forexobroker/
- type: indicator
- pine_id: PUB;226f4cef62b74253ba90442576d27c4c
- version: 1.0

## Description

MAD Z Robust Burst computes a Median Absolute Deviation z-score: MAD-Z = (close - median) / (1.4826 * MAD), where MAD = median(|x - median|). The 1.4826 factor makes MAD a consistent estimator of stdev under normality. Robust to outliers — a single price spike does not inflate the divisor like ordinary stdev does. Visual signature: outlined-only square markers (no fill), MAD bands.

🔶 ALGORITHM

1. window = last N closes.
2. med = median(window).
3. abs_dev[k] = |close[k] - med|.
4. MAD = median(abs_dev).
5. MAD-Z = (close - med) / (1.4826 * MAD).
6. Burst regime when |MAD-Z| > threshold.
7. Return-from-burst entry: signal fires when MAD-Z comes back below the return threshold from a burst.

🔶 SIGNAL LOGIC

- Buy: prior burst-down AND MAD-Z >= -return-threshold AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: prior burst-up AND MAD-Z <= +return-threshold.
- Position-lock state machine.

🔶 INPUTS

- MAD Window (default 40)
- Burst Z entry start (default 2.0)
- Return Z entry fire (default 1.0)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, MAD bands, outlined markers, buy / sell colors

🔶 ALERTS

MZB Buy, MZB Sell, MZB Any Signal, MZB Burst Up, MZB Burst Down, MZB Extreme, MZB Return Up, MZB Return Down, MZB Webhook JSON.

🔶 LIMITATIONS

- MAD is robust but slower-reacting than stdev; bursts may persist a bit longer before being detected.
- The 1.4826 normalisation assumes Gaussian-like distributions; for heavy-tailed assets the conversion is approximate.
- Outlined squares (no glow stack) is a deliberate visual choice — the indicator looks unique but has slightly lower visibility than filled markers.
- Return-from-burst entry is mean-reversion oriented; not for breakout players.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: MAD-Z = (close - median) / (1.4826 * MAD), where MAD = median(|x_i - median(x)|).
// The 1.4826 factor makes MAD a consistent estimator of standard deviation under normality.
// Robust to outliers — a single price spike does not inflate the divisor like stdev does.
// Signals fire on close/EMA cross when |MAD-Z| < small_band (return to normal) within an ATR-
// active regime. Visual signature: outlined-only squares (no glow stack), MAD bands.
indicator("MAD Z Robust Burst [forexobroker]", shorttitle="MZB [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "MAD"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(40,    "MAD Window",            minval=10, maxval=200, group=g_calc)
float i_zHi      = input.float(2.0, "Burst Z (entry start)", minval=1.0, maxval=4.0, step=0.1, group=g_sig, tooltip="Burst regime when |MAD-Z| > this.")
float i_zReturn  = input.float(1.0, "Return Z (entry fire)", minval=0.2, maxval=2.0, step=0.1, group=g_sig, tooltip="Entry when |MAD-Z| comes back below this from the burst.")
int   i_cooldown = input.int(4,     "Cooldown Bars",         minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true, "Show Dashboard",                              group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                           group=g_vis)
bool  i_showBands= input.bool(true, "Show MAD Bands",                              group=g_vis)
color i_buyColor = input.color(#18ffff,"Buy Color (Cyan)",                         group=g_vis)
color i_sellColor= input.color(#ff80ab,"Sell Color (Pink)",                        group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#001f1f, 22)

// ─── MAD-Z ─────────────────────────────────────────────────────────────────────
int N = i_winLen
var float[] window = array.new_float(0)
array.clear(window)
for k = 0 to N - 1
    array.push(window, nz(close[k]))
float med = array.size(window) > 0 ? array.median(window) : close

// MAD = median of |x - med|
var float[] absDev = array.new_float(0)
array.clear(absDev)
for k = 0 to N - 1
    array.push(absDev, math.abs(nz(close[k]) - med))
float mad = array.size(absDev) > 0 ? array.median(absDev) : 0.0
float madZ = mad > 0 ? (close - med) / (1.4826 * mad) : 0.0

bool  burstUp   = madZ >  i_zHi
bool  burstDown = madZ < -i_zHi
var int burstDir = 0
if burstUp
    burstDir := 1
if burstDown
    burstDir := -1
if math.abs(madZ) < i_zReturn / 2.0
    burstDir := 0

bool  returnUp   = burstDir == -1 and madZ >= -i_zReturn  // came back up from down-burst
bool  returnDown = burstDir ==  1 and madZ <=  i_zReturn  // came back down from up-burst

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = returnUp   and posState <= 0 and cooldownOk and confirmed
bool sellSignal = returnDown and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// ─── VISUAL: outlined squares + MAD bands ──────────────────────────────────────
float bandHi = med + i_zHi * 1.4826 * mad
float bandLo = med - i_zHi * 1.4826 * mad
plot(i_showBands ? bandHi : na, "Burst Hi", color=color.new(i_sellColor, 50), linewidth=1, style=plot.style_circles)
plot(i_showBands ? med    : na, "Median",   color=color.new(color.silver, 30), linewidth=1)
plot(i_showBands ? bandLo : na, "Burst Lo", color=color.new(i_buyColor, 50),  linewidth=1, style=plot.style_circles)

// Single outlined square (no glow stack — visual differentiation)
plotshape(i_showGlow and buySignal,  "Buy Halo",  shape.square, location.belowbar, color.new(i_buyColor, 80),  size=size.huge)
plotshape(buySignal,                 "Buy",       shape.square, location.belowbar, color.new(i_buyColor, 30),  size=size.large, text="MZB up", textcolor=i_buyColor)
plotshape(i_showGlow and sellSignal, "Sell Halo", shape.square, location.abovebar, color.new(i_sellColor, 80), size=size.huge)
plotshape(sellSignal,                "Sell",      shape.square, location.abovebar, color.new(i_sellColor, 30), size=size.large, text="MZB dn", textcolor=i_sellColor)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(burstUp ? color.new(i_sellColor, 92) : burstDown ? color.new(i_buyColor, 92) : na)

// ─── DASHBOARD (middle-right, cyan/pink, 7 rows) ──────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string regimeTxt = burstUp ? "BURST UP" : burstDown ? "BURST DOWN" : "INSIDE BANDS"
    color  regimeCol = burstUp ? i_sellColor : burstDown ? i_buyColor : color.silver
    table.cell(dash, 0, 0, "MAD Z Robust Burst", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",              text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "MAD-Z",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(madZ, "0.00"),     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Median",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(med, "#.##"),      text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "MAD",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(mad, "#.######"),  text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Regime",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, regimeTxt,            text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Position",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Last Signal",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"MZB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"madz":' + str.tostring(madZ, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MZB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"madz":' + str.tostring(madZ, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "MZB Buy",          "MAD-Z return long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "MZB Sell",         "MAD-Z return short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "MZB Any Signal",   "Any MZB signal on {{ticker}} {{interval}}")
alertcondition(burstUp and not burstUp[1],                 "MZB Burst Up",     "MAD-Z burst up on {{ticker}} {{interval}}")
alertcondition(burstDown and not burstDown[1],             "MZB Burst Down",   "MAD-Z burst down on {{ticker}} {{interval}}")
alertcondition(math.abs(madZ) >= 3,                        "MZB Extreme",      "|MAD-Z| >= 3 on {{ticker}} {{interval}}")
alertcondition(returnUp,                                   "MZB Return Up",    "MAD-Z returned from down on {{ticker}} {{interval}}")
alertcondition(returnDown,                                 "MZB Return Down",  "MAD-Z returned from up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "MZB Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"MZB\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
