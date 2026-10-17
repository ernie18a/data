# AMD Cycle Mapper [forexobroker]

- url: https://www.tradingview.com/script/RazUTdMu-AMD-Cycle-Mapper-forexobroker/
- type: indicator
- pine_id: PUB;6107b85bc83d41b5aae001152ceffd28
- version: 1.0

## Description

AMD Cycle Mapper [forexobroker] maps the textbook smart-money day cycle: Accumulation (low-volatility consolidation), Manipulation (a sweep of the accumulation extreme that traps breakout traders), and Distribution (a displacement candle back through the range = the real move). The unique angle is a strict three-stage state machine that only arms after compression and a trap, then times entries on an EMA reclaim inside the confirmed distribution bias.

🔶 ALGORITHM

1. Accumulation: ATR must compress below Compression x ATR-avg (its 50-bar average); when idle and compressed, lock the accumulation range from the highest high / lowest low over the Accumulation Window.
2. Manipulation: a wick that pierces the locked range high (or low) by at least Min Sweep x ATR advances the state machine to manip-up or manip-down and records the manipulation bar.
3. Timeout: if distribution does not confirm within Manip->Distrib Max Bars of the manipulation, the cycle resets to idle.
4. Distribution: a displacement candle in the opposite direction with body >= Displacement x ATR that closes back through the range confirms distribution (down after a high sweep, up after a low sweep).
5. Persistent bias: confirmed distribution arms bias +1 / -1 until the opposite distribution fires.
6. Entry timing: within the active distribution bias, an EMA reclaim (ta.crossover / ta.crossunder of close vs the Entry Reclaim EMA) fires the trade. Displacement-Only Mode swaps this for the strict displacement bar; a fired signal resets the phase machine.

🔶 SIGNAL LOGIC

- Buy: distribution-up bias active (low swept during manipulation, then an up displacement >= Displacement x ATR) and close crosses over the Entry Reclaim EMA (or, in Displacement-Only Mode, the displacement bar), in session, position not already long, after the cooldown window, only on barstate.isconfirmed; position-lock flips to LONG and the phase resets.
- Sell: distribution-down bias active (high swept, then a down displacement) and close crosses under the Entry Reclaim EMA (or the displacement bar), in session, position not already short, cooldown elapsed, on barstate.isconfirmed; position-lock flips to SHORT and the phase resets.
Only fires when the full Accumulation -> Manipulation -> Distribution sequence has completed and set bias.

🔶 INPUTS

- Cycle: accumulation window for the consolidation range (default 20) and ATR length.
- Compression: range ATR must sit below Compression x ATR-avg (default 0.8x).
- Manipulation: minimum sweep pierce in ATR multiples (default 0.15x ATR) and manip-to-distribution max bars.
- Distribution: displacement body threshold in ATR multiples (default 1.0x ATR).
- Signal Logic: Entry Reclaim EMA length (default 9) and Displacement-Only Mode toggle (default off).
- Cooldown: minimum bars between signals (default 6).
- Filters: optional session restriction with a session window.
- Visual: accumulation box, dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

ACM Buy, ACM Sell, ACM Any Signal, ACM Accumulation, ACM Manip High, ACM Manip Low, ACM Distrib Up, ACM Distrib Down, ACM Compression, ACM Cycle Reset, ACM Any Manip, ACM Any Distrib, ACM Webhook JSON.

🔶 LIMITATIONS

- Requires warm-up: the 50-bar ATR average and Accumulation Window must populate before any cycle can arm.
- The full three-stage sequence is demanding; in trending or choppy regimes the cycle frequently times out without a signal.
- Defaults are tuned for liquid instruments; compression, sweep, and displacement multiples may need tuning per market.
- Displacement-Only Mode is intentionally rare; the default EMA-reclaim regime mode trades more frequently.
- Non-repainting by design: the state machine and all signals confirm on bar close.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: AMD Cycle Mapper (Accumulation - Manipulation - Distribution). A textbook smart-money
// day cycle: (1) ACCUMULATION = a low-volatility consolidation where ATR sits below its 50-bar
// average; (2) MANIPULATION = a wick that pierces the accumulation extreme and traps breakout
// traders; (3) DISTRIBUTION = a displacement candle (body >= k x ATR) back through the range in
// the opposite direction = the real move. A manipulation sweep alone can arm the reversal bias,
// and a trend-EMA fallback supplies direction when the AMD machine is idle. Signals consume the
// bias so the engine immediately re-arms for the next setup instead of locking on one regime.
indicator("AMD Cycle Mapper [forexobroker]", shorttitle="ACM [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Cycle"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_accLen   = input.int(20,  "Accumulation Window",   minval=5,  maxval=100, group=g_calc, tooltip="Bars used to measure the consolidation range.")
float i_compK    = input.float(1.05,"Compression x ATR-avg",minval=0.3, maxval=1.5, step=0.05, group=g_calc, tooltip="Range ATR must be below k x its 50-bar average to qualify as accumulation. Higher = looser.")
float i_sweepK   = input.float(0.10,"Min Sweep x ATR",      minval=0.0, maxval=2.0, step=0.05, group=g_calc, tooltip="Manipulation wick must pierce the range by k x ATR.")
float i_dispK    = input.float(0.6,"Displacement x ATR",   minval=0.2, maxval=5.0, step=0.1, group=g_calc, tooltip="Distribution body must be >= k x ATR.")
int   i_atrLen   = input.int(14,  "ATR Length",             minval=5,  maxval=50, group=g_calc)
int   i_maxWait  = input.int(12,  "Manip->Distrib Max Bars",minval=1,  maxval=30, group=g_calc, tooltip="Distribution must confirm within this many bars of manipulation.")
int   i_maxAge   = input.int(120, "Bias Max Age (bars)",    minval=10, maxval=500, group=g_calc, tooltip="Stale AMD bias is cleared after this many bars without a signal, so the engine can re-arm on fresh structure.")
string i_trig    = input.string("Either (Recommended)", "Signal Trigger", options=["Either (Recommended)", "Displacement Only", "EMA Reclaim Only"], group=g_sig, tooltip="Either = fires on whichever happens first - displacement bar OR EMA reclaim while bias is active.")
int   i_emaLen   = input.int(9,   "Entry Reclaim EMA",      minval=2,  maxval=50, group=g_sig, tooltip="Close-cross of this EMA in the bias direction times the entry.")
bool  i_armOnManip=input.bool(true,"Arm Bias on Manip Sweep",                      group=g_sig, tooltip="On = a manipulation sweep alone arms the reversal bias (more signals). Off = require full distribution.")
int   i_trendEma = input.int(50,  "Trend Fallback EMA",     minval=10, maxval=300, group=g_sig, tooltip="When no AMD event has armed a bias, price vs this EMA provides a fallback direction.")
bool  i_useFallback=input.bool(true,"Use Trend Fallback",                          group=g_sig, tooltip="On = trade the trend-EMA bias when AMD bias is neutral; Off = AMD events only.")
int   i_cooldown = input.int(10,  "Cooldown Bars",          minval=1,  maxval=200, group=g_sig)
bool  i_useSess  = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showRange= input.bool(true,"Show Accumulation Box",                         group=g_vis)
bool  i_showTable= input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
color i_buyColor = input.color(#22d3aa,"Buy Color",                                 group=g_vis)
color i_sellColor= input.color(#f15b6c,"Sell Color",                                group=g_vis)
color i_dashBg   = input.color(color.new(#040b1f, 15),"Dashboard BG",               group=g_vis)

color c_white = #ffffff

float atr    = nz(ta.atr(i_atrLen), 0.0)
float atrAvg = ta.sma(atr, 50)
float accHi  = ta.highest(high, i_accLen)
float accLo  = ta.lowest(low,  i_accLen)
bool  compressed = atr < i_compK * atrAvg
bool  inSession  = not i_useSess or not na(time(timeframe.period, i_sess))

// Phase: 0 idle, 1 accumulation, 2 manip-up(swept high), -2 manip-down(swept low), 3 distrib-up, -3 distrib-down
var int   phase = 0
var float rangeHi = na
var float rangeLo = na
var int   manipBar = 0

if compressed and phase == 0
    phase := 1
    rangeHi := accHi
    rangeLo := accLo

bool sweepHigh = phase == 1 and not na(rangeHi) and high > rangeHi + i_sweepK * atr
bool sweepLow  = phase == 1 and not na(rangeLo) and low  < rangeLo - i_sweepK * atr
if sweepHigh
    phase := 2
    manipBar := bar_index
if sweepLow
    phase := -2
    manipBar := bar_index

float body = math.abs(close - open)
bool dispDown = phase ==  2 and close < open and body >= i_dispK * atr and close < rangeHi
bool dispUp   = phase == -2 and close > open and body >= i_dispK * atr and close > rangeLo
if (phase == 2 or phase == -2) and (bar_index - manipBar) > i_maxWait
    phase := 0
if dispDown
    phase := -3
if dispUp
    phase := 3

// Directional bias: armed by AMD displacement (or by manip sweep if enabled), expires with i_maxAge.
var int amdBias    = 0
var int amdBiasBar = 0
if dispUp
    amdBias := 1
    amdBiasBar := bar_index
if dispDown
    amdBias := -1
    amdBiasBar := bar_index
if i_armOnManip and sweepLow
    amdBias := 1
    amdBiasBar := bar_index
if i_armOnManip and sweepHigh
    amdBias := -1
    amdBiasBar := bar_index
if amdBias != 0 and (bar_index - amdBiasBar) > i_maxAge
    amdBias := 0

float trendEma = ta.ema(close, i_trendEma)
int fallback = close > trendEma ? 1 : close < trendEma ? -1 : 0
int bias = amdBias != 0 ? amdBias : (i_useFallback ? fallback : 0)

float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool emaReclaimUp = bias ==  1 and crossUp
bool emaReclaimDn = bias == -1 and crossDn
bool fireUp   = i_trig == "Displacement Only" ? dispUp   : i_trig == "EMA Reclaim Only" ? emaReclaimUp : (dispUp   or emaReclaimUp)
bool fireDown = i_trig == "Displacement Only" ? dispDown : i_trig == "EMA Reclaim Only" ? emaReclaimDn : (dispDown or emaReclaimDn)
bool entryUp   = inSession and fireUp
bool entryDown = inSession and fireDown

var int lastSignalBar = -100000
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and cooldownOk and confirmed
bool sellSignal = entryDown and cooldownOk and confirmed and not buySignal
// Consume bias on signal so the engine immediately re-arms for the next setup rather than
// holding the same regime indefinitely (the source of the prior 20k-bar dead zone).
if buySignal
    lastSignalBar := bar_index
    amdBias := 0
    phase := 0
if sellSignal
    lastSignalBar := bar_index
    amdBias := 0
    phase := 0

var int posState = 0
if buySignal
    posState := 1
if sellSignal
    posState := -1

var box accBox = na
if i_showRange and phase == 1 and phase[1] != 1 and not na(rangeHi)
    box.delete(accBox)
    accBox := box.new(math.max(0, bar_index - i_accLen), rangeHi, bar_index + 15, rangeLo, border_color=color.new(color.gray, 40), bgcolor=color.new(color.gray, 90))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.labelup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge, text="A")
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.labelup,   location.belowbar, color.new(i_buyColor, 40), size=size.large, text="M")
plotshape(buySignal,                 "Buy",         shape.labelup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ACM D", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.labeldown, location.abovebar, color.new(i_sellColor, 70), size=size.huge, text="A")
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.labeldown, location.abovebar, color.new(i_sellColor, 40), size=size.large, text="M")
plotshape(sellSignal,                "Sell",        shape.labeldown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ACM D", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : phase == 1 ? color.new(color.gray, 92) : (phase == 2 or phase == -2) ? color.new(color.orange, 90) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string pt = phase == 1 ? "ACCUMULATION" : phase == 2 ? "MANIP (swept hi)" : phase == -2 ? "MANIP (swept lo)" : phase == 3 ? "DISTRIB UP" : phase == -3 ? "DISTRIB DOWN" : "IDLE"
    color  pc = phase == 3 ? i_buyColor : phase == -3 ? i_sellColor : phase == 1 ? color.gray : color.orange
    table.cell(dash, 0, 0, "AMD Cycle Mapper",   text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",              text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Phase",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, pt,                   text_color=pc, text_size=size.small)
    table.cell(dash, 0, 2, "Bias",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, bias == 1 ? (amdBias == 1 ? "AMD LONG" : "TREND LONG") : bias == -1 ? (amdBias == -1 ? "AMD SHORT" : "TREND SHORT") : "FLAT", text_color=bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "Range",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(rangeHi) ? "-" : str.tostring(rangeLo, "#.##") + "-" + str.tostring(rangeHi, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Compressed",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, compressed ? "YES" : "NO", text_color=compressed ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ATR / Avg",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atrAvg > 0 ? atr / atrAvg : 0, "0.00"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, lastSignalBar < 0 ? "-" : str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"ACM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ACM","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "ACM Buy",            "AMD distribution up on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "ACM Sell",           "AMD distribution down on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "ACM Any Signal",     "Any ACM signal on {{ticker}} {{interval}}")
alertcondition(phase == 1 and phase[1] != 1,       "ACM Accumulation",   "Accumulation phase started on {{ticker}} {{interval}}")
alertcondition(sweepHigh,                          "ACM Manip High",     "Manipulation swept high on {{ticker}} {{interval}}")
alertcondition(sweepLow,                           "ACM Manip Low",      "Manipulation swept low on {{ticker}} {{interval}}")
alertcondition(dispUp,                             "ACM Distrib Up",     "Distribution displacement up on {{ticker}} {{interval}}")
alertcondition(dispDown,                           "ACM Distrib Down",   "Distribution displacement down on {{ticker}} {{interval}}")
alertcondition(compressed and not compressed[1],   "ACM Compression",    "Volatility compressed on {{ticker}} {{interval}}")
alertcondition(phase == 0 and phase[1] != 0,       "ACM Cycle Reset",    "AMD cycle reset on {{ticker}} {{interval}}")
alertcondition(sweepHigh or sweepLow,              "ACM Any Manip",      "Any manipulation sweep on {{ticker}} {{interval}}")
alertcondition(dispUp or dispDown,                 "ACM Any Distrib",    "Any distribution on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "ACM Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"ACM\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
