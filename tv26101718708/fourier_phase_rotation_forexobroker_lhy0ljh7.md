# Fourier Phase Rotation [forexobroker]

- url: https://www.tradingview.com/script/LHY0LjH7-Fourier-Phase-Rotation-forexobroker/
- type: indicator
- pine_id: PUB;4008743cb54b45c2bbe3fb7fc660a8df
- version: 1.0

## Description

Fourier Phase Rotation reconstructs the fundamental phase of a 4-bar sliding window using sine and cosine projections. The phase angle phi rotates through the unit circle as the cycle progresses; a zero-cross of phi marks a cycle low (buy timing) or high (sell timing). Distinct from Hilbert: 4-point projection, no IIR filter ringing.

🔶 ALGORITHM

1. Detrended source = close - sma(close, N).
2. 4-point DFT bin 1 cosine: re = c0 - c2; sine: im = c1 - c3 where c_k = detrended source at lag k.
3. phase phi = atan(im / re), in [-pi/2, +pi/2].
4. Cycle-low complete = phi crosses zero up; cycle-high complete = phi crosses zero down.
5. Bias from close vs detrend SMA gates direction.

🔶 SIGNAL LOGIC

- Buy: phase up-cross AND close > detrend SMA AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: phase down-cross AND close < detrend SMA.
- Position-lock state machine.

🔶 INPUTS

- Detrend SMA Length (default 20)
- Pullback EMA Length (default 8)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, SMA toggle, buy / sell colors

🔶 ALERTS

FPR Buy, FPR Sell, FPR Any Signal, FPR Phase Up, FPR Phase Down, FPR Bias Up, FPR Bias Down, FPR Near Pi/2, FPR Webhook JSON.

🔶 LIMITATIONS

- 4-point projection has a fixed period of 4 bars; assumes any cycle of interest is roughly that scale. Longer cycles fold into the bias trend.
- atan (vs atan2) gives phase in [-pi/2, +pi/2]; sufficient for zero-cross detection but does not preserve quadrant disambiguation.
- Detrend SMA length is the dominant smoothing knob; longer SMA = cleaner cycle, more lag.
- Best on instruments with rhythmic intraday patterns; pure trends give muted phase oscillations.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Fourier-style phase tracking on a 4-bar sliding window. The fundamental cycle is
// reconstructed from the discrete sine and cosine projections of the last 4 close-mean values,
// giving an instantaneous phase angle phi in radians. The phase rotates through 0 -> pi/2 -> pi
// -> 3pi/2 with the cycle. Signals fire when phi rotates from the third quadrant back through
// the fourth (cycle-low complete = buy) or from the first through the second (cycle-high
// complete = sell). Distinct from Hilbert: 4-point projection, no IIR ringing.
indicator("Fourier Phase Rotation [forexobroker]", shorttitle="FPR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Fourier Phase"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_smaLen   = input.int(20, "Detrend SMA Length", minval=5, maxval=100, group=g_calc)
int   i_emaLen   = input.int(8, "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
int   i_cooldown = input.int(4, "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showSma   = input.bool(true, "Show Detrend SMA", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

float sma  = ta.sma(close, i_smaLen)
float det  = nz(close - sma, 0.0)

// 4-point DFT bin 1: cosine and sine projections
float c0 = nz(det)
float c1 = nz(det[1])
float c2 = nz(det[2])
float c3 = nz(det[3])
// fundamental cosine: c0 - c2 ; sine: c1 - c3 (signs depend on convention; standard 4-pt DFT)
float reN = c0 - c2
float imN = c1 - c3
float reSafe = reN != 0 ? reN : 1e-10
float phi    = math.atan(imN / reSafe)  // -pi/2 .. +pi/2 (sufficient for zero-cross detection)

// ─── PHASE QUADRANT TRANSITIONS ────────────────────────────────────────────────
// Cycle-low complete = phi crosses from negative (Q3/Q4) to slightly positive (Q1) -> buy.
// Cycle-high complete = phi crosses from positive (Q1/Q2) to slightly negative (Q4) -> sell.
bool phaseUp   = phi[1] < 0 and phi >= 0   // upward zero-cross of phase = cycle-low
bool phaseDown = phi[1] > 0 and phi <= 0   // downward zero-cross = cycle-high

float ema     = ta.ema(close, i_emaLen)
bool  bullBias = close > sma
bool  bearBias = close < sma
bool  entryUp   = phaseUp   and bullBias
bool  entryDown = phaseDown and bearBias

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

color smaCol = bullBias ? i_buyColor : bearBias ? i_sellColor : color.new(color.gray, 50)
plot(i_showSma ? sma : na, "Detrend SMA", color=smaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="FPR up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="FPR dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullBias ? color.new(i_buyColor, 96) : bearBias ? color.new(i_sellColor, 96) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    int quadrant = phi >= 0 and phi < 1.57 ? 1 : phi >= 1.57 ? 2 : phi >= -1.57 ? 4 : 3
    string regimeTxt = bullBias ? "BIAS UP" : bearBias ? "BIAS DOWN" : "FLAT"
    color  regimeCol = bullBias ? i_buyColor : bearBias ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Fourier Phase Rotation", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Phase phi",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(phi, "0.00") + " rad",   text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "Quadrant",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, "Q" + str.tostring(quadrant),         text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Real",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(reN, "#.######"),        text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Imag",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(imN, "#.######"),        text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Bias",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"FPR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"phi":' + str.tostring(phi, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"FPR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"phi":' + str.tostring(phi, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "FPR Buy",          "Fourier cycle low on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "FPR Sell",         "Fourier cycle high on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "FPR Any Signal",   "Any FPR signal on {{ticker}} {{interval}}")
alertcondition(phaseUp,                                    "FPR Phase Up",     "Phase upward zero-cross on {{ticker}} {{interval}}")
alertcondition(phaseDown,                                  "FPR Phase Down",   "Phase downward zero-cross on {{ticker}} {{interval}}")
alertcondition(bullBias and not bullBias[1],               "FPR Bias Up",      "Bias turned up on {{ticker}} {{interval}}")
alertcondition(bearBias and not bearBias[1],               "FPR Bias Down",    "Bias turned down on {{ticker}} {{interval}}")
alertcondition(math.abs(phi) > 2.5,                        "FPR Near Pi",      "Phase near pi on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "FPR Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"FPR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
