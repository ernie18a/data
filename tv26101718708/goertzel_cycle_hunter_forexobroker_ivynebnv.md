# Goertzel Cycle Hunter [forexobroker]

- url: https://www.tradingview.com/script/IVyNeBNV-Goertzel-Cycle-Hunter-forexobroker/
- type: indicator
- pine_id: PUB;aa616bad5259419d87affd558c33070b
- version: 1.0

## Description

Goertzel Cycle Hunter scans seven Fibonacci-spaced cycle periods (5, 8, 13, 21, 34, 55, 89) using the Goertzel filter — a tuned single-frequency DFT that runs in O(N) per period. The dominant cycle's reconstructed cosine drives the trigger, gated by a power-ratio regime that confirms the cycle is real and not noise.

🔶 ALGORITHM

1. Detrend source = (high + low) / 2 minus its N-bar SMA, isolating the oscillatory component.
2. For each period N in [5, 8, 13, 21, 34, 55, 89], run the Goertzel recursion: s[n] = x[n] + 2 cos(2 pi / N) * s[n-1] - s[n-2].
3. Power = s1^2 + s2^2 - 2 cos(omega) * s1 * s2; reconstructed cosine = s1 - s2 * cos(omega).
4. Dominant period = argmax(power); power ratio = max_power / sum_power.
5. Rhythm regime active when power ratio >= threshold AND ATR > k * 50-bar SMA.

🔶 SIGNAL LOGIC

- Buy: rhythm active AND reconstructed cosine crosses zero up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: mirror with crossunder.
- Position-lock state machine.

🔶 INPUTS

- Goertzel Window (default 120)
- Min Power Ratio (default 0.20)
- ATR Activity Floor (default 0.20)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, trend mid line, buy / sell colors

🔶 ALERTS

GCH Buy, GCH Sell, GCH Any Signal, GCH Rhythm Start, GCH Rhythm End, GCH Phase Up, GCH Phase Down, GCH Strong Cycle, GCH Webhook JSON.

🔶 LIMITATIONS

- Cycle hunting is meaningful only when the market actually has a dominant rhythm; in trending or trapped regimes the power ratio stays low and signals mute correctly.
- Computational cost = 7 Goertzel runs of N samples per bar. Defaults (N = 120) balance fidelity vs load.
- The seven Fibonacci periods are a coarse grid; true dominant cycle may fall between (e.g., 16, 27 bars). User can re-tune the window length to bias toward shorter or longer cycles.
- Detrend is SMA-based; structural breaks within the window can bias the cosine reconstruction for a few bars.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Goertzel filter — a tuned single-frequency DFT — runs across 7 Fibonacci-spaced cycle
// periods (5, 8, 13, 21, 34, 55, 89). Each Goertzel returns spectral power and a reconstructed
// cosine value at that period. The period with the highest power is the dominant cycle. Signals
// fire when (a) the dominant cycle's power exceeds a fraction of total spectral energy (the cycle
// is real, not noise) and (b) the reconstructed cosine crosses zero in the regime direction.
// Goertzel is O(N) per period — far cheaper than full FFT for narrow-band cycle hunting.
indicator("Goertzel Cycle Hunter [forexobroker]", shorttitle="GCH [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc   = "Goertzel"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(120, "Goertzel Window",         minval=60, maxval=300, group=g_calc,   tooltip="Bars per Goertzel evaluation. Must be >= 2x longest cycle period to be tested.")
float i_powThr   = input.float(0.20, "Min Power Ratio",      minval=0.05, maxval=0.80, step=0.05, group=g_signal, tooltip="Dominant cycle power must be >= this fraction of total power for a 'rhythmic' regime.")
float i_atrK     = input.float(0.20, "ATR Activity Floor",   minval=0.05, maxval=2.00, step=0.05, group=g_signal, tooltip="ATR must exceed k x its 50-bar SMA. Filters dead/holiday markets.")
int   i_cooldown = input.int(4,    "Cooldown Bars",          minval=1,  maxval=20,                  group=g_signal)
bool  i_showTable = input.bool(true,  "Show Dashboard",                                            group=g_visual)
bool  i_showGlow  = input.bool(true,  "Show 3-Layer Glow",                                         group=g_visual)
bool  i_showTrend = input.bool(true,  "Show Trend Mid",                                            group=g_visual)
color i_buyColor  = input.color(#1de9b6, "Buy Color (Mint)",                                       group=g_visual)
color i_sellColor = input.color(#ff5252, "Sell Color (Coral)",                                     group=g_visual)

color c_white = #ffffff

// ─── DETRENDED SOURCE ─────────────────────────────────────────────────────────
float src   = (high + low) / 2.0
float trend = ta.sma(src, i_winLen)
float det   = src - trend

// ─── GOERTZEL FUNCTION (O(N) per period) ──────────────────────────────────────
f_goertzel(int N) =>
    float omega = 2.0 * 3.14159265358979 / N
    float coeff = 2.0 * math.cos(omega)
    float s1 = 0.0
    float s2 = 0.0
    for n = 0 to i_winLen - 1
        float x = nz(det[i_winLen - 1 - n])
        float s = x + coeff * s1 - s2
        s2 := s1
        s1 := s
    float power = s1 * s1 + s2 * s2 - coeff * s1 * s2
    float recon = s1 - s2 * math.cos(omega)
    [power, recon]

[pow5,  rec5]  = f_goertzel(5)
[pow8,  rec8]  = f_goertzel(8)
[pow13, rec13] = f_goertzel(13)
[pow21, rec21] = f_goertzel(21)
[pow34, rec34] = f_goertzel(34)
[pow55, rec55] = f_goertzel(55)
[pow89, rec89] = f_goertzel(89)

float totalPow = pow5 + pow8 + pow13 + pow21 + pow34 + pow55 + pow89
float maxPow   = math.max(math.max(math.max(pow5, pow8), math.max(pow13, pow21)), math.max(math.max(pow34, pow55), pow89))
int   bestN    = pow5 == maxPow ? 5 : pow8 == maxPow ? 8 : pow13 == maxPow ? 13 : pow21 == maxPow ? 21 : pow34 == maxPow ? 34 : pow55 == maxPow ? 55 : 89
float bestRec  = pow5 == maxPow ? rec5 : pow8 == maxPow ? rec8 : pow13 == maxPow ? rec13 : pow21 == maxPow ? rec21 : pow34 == maxPow ? rec34 : pow55 == maxPow ? rec55 : rec89
float powRatio = totalPow > 0 ? maxPow / totalPow : 0.0

// ─── REGIME + ENTRY ────────────────────────────────────────────────────────────
float atr14  = ta.atr(14)
float atrSma = ta.sma(atr14, 50)
bool  atrOk  = atr14 > atrSma * i_atrK
bool  rhythm = powRatio >= i_powThr and atrOk

bool  cycleUp   = ta.crossover(bestRec, 0)
bool  cycleDn   = ta.crossunder(bestRec, 0)
bool  entryUp   = rhythm and cycleUp
bool  entryDown = rhythm and cycleDn
// (ta.crossover values pulled into globals for consistent bar-by-bar evaluation)

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
plot(i_showTrend ? trend : na, "Trend Mid", color=color.new(color.gray, 60), linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="GCH up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="GCH dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(rhythm ? color.new(bestRec > 0 ? i_buyColor : i_sellColor, 92) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = rhythm ? "RHYTHMIC" : "NOISE"
    color  regimeCol = rhythm ? (bestRec > 0 ? i_buyColor : i_sellColor) : color.gray
    table.cell(dash, 0, 0, "Goertzel Cycle Hunter", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Dominant Period",       text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(bestN) + " bars",      text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "Power Ratio",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(powRatio, "0.00"),     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 3, "Threshold",             text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_powThr, "0.00"),     text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Cycle Phase",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, bestRec > 0 ? "ABOVE" : "BELOW",    text_color=bestRec > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,               text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"GCH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"period":' + str.tostring(bestN) + ',"power":' + str.tostring(powRatio, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"GCH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"period":' + str.tostring(bestN) + ',"power":' + str.tostring(powRatio, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                       "GCH Buy",          "Goertzel cycle bull pulse on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                      "GCH Sell",         "Goertzel cycle bear pulse on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,         "GCH Any Signal",   "Any GCH signal on {{ticker}} {{interval}}")
alertcondition(rhythm and not rhythm[1],        "GCH Rhythm Start", "Rhythmic cycle regime entered on {{ticker}} {{interval}}")
alertcondition(not rhythm and rhythm[1],        "GCH Rhythm End",   "Rhythmic regime ended on {{ticker}} {{interval}}")
alertcondition(cycleUp,                         "GCH Phase Up",     "Cycle phase crossed up on {{ticker}} {{interval}}")
alertcondition(cycleDn,                         "GCH Phase Down",   "Cycle phase crossed down on {{ticker}} {{interval}}")
alertcondition(powRatio >= 0.5,                 "GCH Strong Cycle", "Cycle power ratio above 0.50 on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,         "GCH Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"GCH\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
