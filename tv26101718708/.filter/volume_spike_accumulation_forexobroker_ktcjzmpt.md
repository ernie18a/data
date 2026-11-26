# Volume Spike Accumulation [forexobroker]

- url: https://www.tradingview.com/script/kTcjZMPT-Volume-Spike-Accumulation-forexobroker/
- type: indicator
- pine_id: PUB;91609d8eaff3440381612a71684c5889
- version: 1.0

## Description

Volume Spike Accumulation [forexobroker] reads volume spikes through where the bar closed in its own range. A spike that closes in the upper part of the range is demand absorbing supply (accumulation); a spike closing in the lower part is supply (distribution). Accumulation arms a long bias and distribution a short bias, and entries time off an EMA reclaim in the bias direction so signals are frequent rather than one-per-spike.

🔶 ALGORITHM

1. Compute ATR and an SMA of volume over the volume-MA length as the baseline.
2. Flag a volume spike when volume >= k x its moving average.
3. Close-position classification: clsPos = (close - low) / (high - low). A spike with clsPos >= the close-position threshold is accumulation; clsPos <= 1 - threshold is distribution.
4. Relative volume = volume / volume-MA for the dashboard.
5. Accumulation arms a persistent long bias and distribution a persistent short bias, holding until the opposite classified spike fires.
6. Entry timing: an EMA reclaim (close crossing the entry-reclaim EMA in the bias direction), or strictly the classified spike bar in Spike-Only Mode.

🔶 SIGNAL LOGIC

- Buy: bias == long (last classified spike was accumulation) AND close crosses over the reclaim EMA (or an accumulation spike bar in Spike-Only Mode), in session, with no active long, cooldown elapsed, and barstate.isconfirmed; position locks long.
- Sell: bias == short (last classified spike was distribution) AND close crosses under the reclaim EMA (or a distribution spike bar in Spike-Only Mode), in session, with no active short, cooldown elapsed, and barstate.isconfirmed; position locks short.
Only fires while the persistent spike bias agrees with the entry direction.

🔶 INPUTS

- Volume group: volume MA length for the spike baseline (default 20).
- Volume group: spike multiple of the volume MA (default 1.8).
- Volume group: close-position threshold for accumulation vs distribution (default 0.66).
- Volume group: ATR length (default 14).
- Signal Logic group: entry reclaim EMA length (default 9).
- Signal Logic group: Spike-Only Mode toggle (default off) and cooldown bars (default 5).
- Filters group: restrict-to-session toggle and session window (default 0000-2400).
- Visual group: show dashboard, 3-layer glow, and reclaim EMA (all default on).
- Visual group: buy color, sell color, and dashboard background.

🔶 ALERTS

VSA Buy, VSA Sell, VSA Any Signal, VSA Accumulation, VSA Distribution, VSA Volume Spike, VSA Classified, VSA EMA Up, VSA EMA Down, VSA Bias Bull, VSA Bias Bear, VSA Spike Tick, VSA Webhook JSON.

🔶 LIMITATIONS

- Volume-based: needs a real volume feed; forex volume is tick-volume, which only approximates traded size.
- Needs warm-up bars for the volume MA and ATR before spikes are valid.
- The spike multiple default is tuned for liquid instruments; quiet or thin symbols may need it retuned.
- The persistent bias holds until an opposite classified spike fires, so it can stay stale through quiet periods.
- Signals confirm on bar close; close-position and bias can change intrabar before the bar finishes.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Volume Spike Accumulation. A volume spike (volume > k x its moving average) is read
// through where the bar CLOSED in its own range: a spike that closes in the upper third = demand
// absorbing supply (accumulation); a spike closing in the lower third = supply (distribution).
// Accumulation arms a long bias, distribution a short bias; entries time off an EMA reclaim in
// that direction. Non-repainting: spike and close-position evaluated on the closed bar.
indicator("Volume Spike Accumulation [forexobroker]", shorttitle="VSA [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Volume"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_volMa   = input.int(20,   "Volume MA Length",      minval=5,  maxval=100, group=g_calc, tooltip="Baseline the spike is measured against.")
float i_spikeK  = input.float(1.8,"Spike x Volume-MA",     minval=1.0, maxval=6.0, step=0.1, group=g_calc, tooltip="Volume must exceed k x its MA to count as a spike.")
float i_clsPos  = input.float(0.66,"Close Position Thresh", minval=0.5, maxval=0.95, step=0.01, group=g_calc, tooltip="Spike close in top (1-x) of range = accumulation; bottom = distribution.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After a spike sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_spkOnly = input.bool(false,"Spike-Only Mode",                              group=g_sig, tooltip="On = fire strictly on the classified spike bar. Off = EMA reclaim inside the active spike bias (more signals).")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                          group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                 group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                              group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                               group=g_vis)
color i_buyColor= input.color(#34e89e,"Buy Color",                                  group=g_vis)
color i_sellColor=input.color(#ff5f7e,"Sell Color",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#04140f, 14),"Dashboard BG",               group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float vMa   = ta.sma(volume, i_volMa)
bool  spike = vMa > 0 and volume >= i_spikeK * vMa
float rngBar= high - low
float clsPos= rngBar > 0 ? (close - low) / rngBar : 0.5
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool accum   = spike and clsPos >= i_clsPos
bool distrib = spike and clsPos <= (1.0 - i_clsPos)

float relVol = vMa > 0 ? volume / vMa : 0.0

// Accumulation arms a long bias, distribution a short bias, until the opposite spike fires.
var int bias = 0
if accum
    bias := 1
if distrib
    bias := -1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and (i_spkOnly ? accum   : (bias ==  1 and crossUp))
bool entryDown = inSession and (i_spkOnly ? distrib : (bias == -1 and crossDn))

var int posState      = 0
var int lastSignalBar = 0
var int spikeCount    = 0
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
if spike
    spikeCount += 1

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=bias == 1 ? color.new(i_buyColor, 30) : bias == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.labelup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.labelup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.labelup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="VSA", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.labeldown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.labeldown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.labeldown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="VSA", textcolor=c_white)

barcolor(accum ? i_buyColor : distrib ? i_sellColor : na)
bgcolor(bias == 1 ? color.new(i_buyColor, 94) : bias == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string st = accum ? "ACCUMULATION" : distrib ? "DISTRIBUTION" : spike ? "NEUTRAL SPIKE" : "QUIET"
    color  sc = accum ? i_buyColor : distrib ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Volume Spike Accum",    text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "Rel Volume",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(relVol, "0.00") + "x", text_color=relVol >= i_spikeK ? i_buyColor : color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Close Pos",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(clsPos * 100, "#") + "%", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Bias",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, bias == 1 ? "LONG" : bias == -1 ? "SHORT" : "FLAT", text_color=bias == 1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Spikes",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(spikeCount), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"VSA","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"VSA","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "VSA Buy",            "Accumulation entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "VSA Sell",           "Distribution entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "VSA Any Signal",     "Any VSA signal on {{ticker}} {{interval}}")
alertcondition(accum,                              "VSA Accumulation",   "Accumulation spike on {{ticker}} {{interval}}")
alertcondition(distrib,                            "VSA Distribution",   "Distribution spike on {{ticker}} {{interval}}")
alertcondition(spike,                              "VSA Volume Spike",   "Volume spike on {{ticker}} {{interval}}")
alertcondition(accum or distrib,                   "VSA Classified",     "Classified volume spike on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "VSA EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "VSA EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "VSA Bias Bull",      "Spike bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "VSA Bias Bear",      "Spike bias turned bearish on {{ticker}} {{interval}}")
alertcondition(spike and not spike[1],             "VSA Spike Tick",     "New volume spike on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "VSA Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"VSA\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
