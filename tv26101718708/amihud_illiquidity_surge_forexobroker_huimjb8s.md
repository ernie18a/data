# Amihud Illiquidity Surge [forexobroker]

- url: https://www.tradingview.com/script/huimJB8S-Amihud-Illiquidity-Surge-forexobroker/
- type: indicator
- pine_id: PUB;fdbe424b1ee3479f8ec653ef14c2b436
- version: 1.0

## Description

Amihud Illiquidity Surge computes the canonical Amihud (2002) illiquidity ratio: |return| / volume. High value = price moves a lot per unit of volume traded = illiquid market = price-impact dominated regime. Z-scored over a rolling window to detect surges. Signals fire on EMA cross during a surge, gold-and-red palette unique to this indicator.

🔶 ALGORITHM

1. AIS = |close - close[1]| / max(volume, 1).
2. AIS-Z = (AIS - sma(AIS, N)) / stdev(AIS, N).
3. Surge regime when AIS-Z >= threshold.
4. EMA cross within surge fires entries in the prevailing direction.

🔶 SIGNAL LOGIC

- Buy: surge AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: surge AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Z-Score Window (default 50)
- Surge Z Threshold (default 1.5)
- Pullback EMA Length (default 8)
- Cooldown Bars (default 4)
- Visual: dashboard (gold-themed double border), glow, dollar-symbol labels, buy / sell colors

🔶 ALERTS

AIS Buy, AIS Sell, AIS Any Signal, AIS Surge Start, AIS Surge End, AIS Extreme, AIS EMA Up, AIS EMA Down, AIS Webhook JSON.

🔶 LIMITATIONS

- Forex tick volume is broker-aggregated and noisy; futures, equities, and crypto produce cleaner illiquidity readings.
- The labels show "AIS$" — the dollar symbol is a visual cue, not a units claim.
- For very-low-volume bars (e.g., overnight or holiday sessions) the ratio inflates artificially; the volume floor of 1 mitigates but does not eliminate this.
- AIS surges precede price moves only loosely; pair with a directional gate.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Amihud (2002) illiquidity ratio: AIS = |return| / volume. High AIS = price moves a
// lot per unit of volume = illiquid market. Z-scored over a rolling window: high z = liquidity
// drain, suggesting price impact dominates. Signals fire on EMA cross during a liquidity-surge
// regime in the prevailing direction. Distinct from any volume oscillator: AIS is the canonical
// academic illiquidity measure.
indicator("Amihud Illiquidity Surge [forexobroker]", shorttitle="AIS [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Amihud"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(50,    "Z-Score Window",      minval=20, maxval=200, group=g_calc)
float i_zThr     = input.float(1.5, "Surge Z Threshold",   minval=0.5, maxval=4.0, step=0.1, group=g_sig)
int   i_emaLen   = input.int(8,     "Pullback EMA Length", minval=3, maxval=50, group=g_sig)
int   i_cooldown = input.int(4,     "Cooldown Bars",       minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true, "Show Dashboard",                            group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                         group=g_vis)
color i_buyColor = input.color(#ffea00,"Buy Color (Gold)",                       group=g_vis)
color i_sellColor= input.color(#ff3d00,"Sell Color (Red-Orange)",                group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#1a1400, 22)

// ─── AMIHUD RATIO + Z ──────────────────────────────────────────────────────────
float r       = math.abs(close - close[1])
float vol     = math.max(volume, 1.0)  // guard div-by-zero on no-volume bars
float ais     = r / vol
float aisMa   = ta.sma(ais, i_winLen)
float aisSd   = ta.stdev(ais, i_winLen)
float aisZ    = aisSd > 0 ? (ais - aisMa) / aisSd : 0.0
bool  surge   = aisZ >= i_zThr

float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)
bool  entryUp   = surge and crossUp
bool  entryDown = surge and crossDn

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

// ─── VISUAL: dollar labels ─────────────────────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.labelup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge, text="$")
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.labelup,   location.belowbar, color.new(i_buyColor, 40), size=size.large, text="$")
plotshape(buySignal,                 "Buy",         shape.labelup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="AIS$", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.labeldown, location.abovebar, color.new(i_sellColor, 70), size=size.huge, text="$")
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.labeldown, location.abovebar, color.new(i_sellColor, 40), size=size.large, text="$")
plotshape(sellSignal,                "Sell",        shape.labeldown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="AIS$", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(surge ? color.new(close > ema ? i_buyColor : i_sellColor, 92) : na)

// ─── DASHBOARD (bottom-right, gold/red-orange, 7 rows, double border) ─────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 50), border_width=2)
    string regimeTxt = surge ? "ILLIQUID SURGE" : "LIQUID"
    color  regimeCol = surge ? (close > ema ? i_buyColor : i_sellColor) : color.silver
    table.cell(dash, 0, 0, "Amihud Illiquidity Surge", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                    text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "AIS Ratio",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(ais, "#.######"),  text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "AIS Z-Score",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(aisZ, "0.00"), text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 3, "Threshold",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_zThr, "0.00"),   text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Regime",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, regimeTxt,                  text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Position",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Last Signal",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"AIS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"aisZ":' + str.tostring(aisZ, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"AIS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"aisZ":' + str.tostring(aisZ, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "AIS Buy",          "Amihud surge bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "AIS Sell",         "Amihud surge bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "AIS Any Signal",   "Any AIS signal on {{ticker}} {{interval}}")
alertcondition(surge and not surge[1],                     "AIS Surge Start",  "Illiquidity surge started on {{ticker}} {{interval}}")
alertcondition(not surge and surge[1],                     "AIS Surge End",    "Illiquidity surge ended on {{ticker}} {{interval}}")
alertcondition(aisZ >= 3.0,                                "AIS Extreme",      "AIS Z >= 3 on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "AIS EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "AIS EMA Down",     "Close crossed EMA down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "AIS Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"AIS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
