# Cumulative Volume Delta Pivot [forexobroker]

- url: https://www.tradingview.com/script/QITrTzTu-Cumulative-Volume-Delta-Pivot-forexobroker/
- type: indicator
- pine_id: PUB;78be1e6e12794c43bd619aea2082a35d
- version: 1.0

## Description

Cumulative Volume Delta Pivot [forexobroker] builds a running cumulative volume delta (CVD) from tick-rule signed volume, then takes confirmed pivots on BOTH price and the CVD line. When a CVD pivot prints in the same direction as a price pivot within a small window, order flow is confirming the swing (pivot confluence, not divergence). The CVD slope sets the bias and a reclaim-EMA cross times entries.

🔶 ALGORITHM

1. Sign each bar: with "Sign by Close Position" on, sgn = 2*(close-low)/range - 1; off uses the pure tick rule (close vs prior close).
2. CVD accumulates sgn * volume bar by bar.
3. CVD slope = CVD minus an EMA of CVD (CVD Slope EMA); slope > 0 = flow up (+1), slope < 0 = flow down (-1).
4. Confirmed pivots are taken on price (high/low) and on the CVD line with Pivot Length bars each side.
5. Confluence: a CVD pivot low aligning with a recent price-low pivot within the Pivot Align Window = bullish confluence; CVD pivot high with a price-high pivot = bearish confluence.
6. A reclaim EMA times the entry: a confirmed close-cross in the flow-regime direction triggers, optionally requiring fresh pivot confluence (Confluence-Only Mode). Cooldown, bar-close confirmation and a position-lock finalise it.

🔶 SIGNAL LOGIC

- Buy: in-session AND flow regime up AND close crosses over the reclaim EMA AND (Confluence-Only off OR bullish pivot confluence) AND position not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: in-session AND flow regime down AND close crosses under the reclaim EMA AND (Confluence-Only off OR bearish pivot confluence) AND position not already short AND cooldown elapsed AND barstate.isconfirmed.
Only fires while the CVD-slope flow regime is non-flat.

🔶 INPUTS

- CVD group: Pivot Length, bars each side to confirm price and CVD pivots (default 5).
- CVD group: Pivot Align Window for pivot confluence (default 6).
- CVD group: CVD Slope EMA defining the order-flow bias (default 21).
- CVD group: Sign by Close Position toggle (close-in-range vs pure tick rule, default on).
- CVD group: ATR Length for the reference table (default 14).
- Signal Logic group: Entry Reclaim EMA whose close-cross times entries (default 9).
- Signal Logic group: Confluence-Only Mode and Cooldown Bars between signals (default 5).
- Filters group: optional session restriction with a configurable window (default off).
- Visual group: dashboard, 3-layer glow, reclaim-EMA plot and buy/sell colors (dashboard default on).

🔶 ALERTS

CVP Buy, CVP Sell, CVP Any Signal, CVP Bull Confluence, CVP Bear Confluence, CVP CVD Pivot Low, CVP CVD Pivot High, CVP EMA Up, CVP EMA Down, CVP Slope Zero, CVP Regime Flip, CVP Any Confluence, CVP Webhook JSON.

🔶 LIMITATIONS

- Pivots confirm only after Pivot Length bars on the right side, so confluence is detected with that inherent lag (not repainting, but delayed).
- Volume-based, so it requires a real volume feed; on forex it falls back to broker tick-volume, which is a proxy only.
- Tick-rule signing is an estimate of order flow, not true bid/ask delta.
- CVD is a running cumulative sum, so absolute values depend on chart history length and warm-up.
- Defaults are tuned for liquid instruments; thin symbols may need a longer slope EMA.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Cumulative Volume Delta Pivot. CVD is a running sum of tick-rule signed volume.
// Confirmed pivots are taken on BOTH price and the CVD line; when a CVD pivot prints in the
// same direction as a price pivot within a small bar window, order flow is CONFIRMING the
// swing (pivot confluence, not divergence). The CVD slope sets the bias; a reclaim-EMA cross
// times entries, optionally gated to bars with fresh pivot confluence. Non-repainting.
indicator("Cumulative Volume Delta Pivot [forexobroker]", shorttitle="CVP [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "CVD"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_piv     = input.int(5,    "Pivot Length",          minval=2,  maxval=30, group=g_calc, tooltip="Bars each side to confirm price and CVD pivots.")
int   i_alignLb = input.int(6,    "Pivot Align Window",    minval=1,  maxval=20, group=g_calc, tooltip="A CVD pivot within this many bars of a price pivot = confluence.")
int   i_cvdEma  = input.int(21,   "CVD Slope EMA",         minval=3,  maxval=100, group=g_calc, tooltip="CVD minus this EMA defines the order-flow bias.")
bool  i_useBody = input.bool(true,"Sign by Close Position",                       group=g_calc, tooltip="On = sign volume by close-in-range; Off = pure tick rule.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After CVD slope sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_confOnly= input.bool(false,"Confluence-Only Mode",                        group=g_sig, tooltip="On = only fire on bars with fresh price/CVD pivot confluence.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#4cc9f0,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#f72585,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#070b1f, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float rngBar= high - low
float sgn   = i_useBody ? (rngBar > 0 ? (2.0 * (close - low) / rngBar - 1.0) : 0.0) : (close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0)
var float cvd = 0.0
cvd := cvd + sgn * nz(volume, 0.0)
float cvdEmaV = ta.ema(cvd, i_cvdEma)
float cvdSlope= cvd - cvdEmaV
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

float pPH = ta.pivothigh(high, i_piv, i_piv)
float pPL = ta.pivotlow(low,   i_piv, i_piv)
float cPH = ta.pivothigh(cvd,  i_piv, i_piv)
float cPL = ta.pivotlow(cvd,   i_piv, i_piv)
var int lastPricePivBar = 0
var int pricePivDir = 0
if not na(pPH)
    lastPricePivBar := bar_index
    pricePivDir := -1
if not na(pPL)
    lastPricePivBar := bar_index
    pricePivDir := 1
bool cvdPivUp = not na(cPL)
bool cvdPivDn = not na(cPH)
bool confBull = cvdPivUp and pricePivDir ==  1 and (bar_index - lastPricePivBar) <= i_alignLb
bool confBear = cvdPivDn and pricePivDir == -1 and (bar_index - lastPricePivBar) <= i_alignLb

int regime = cvdSlope > 0 ? 1 : cvdSlope < 0 ? -1 : 0
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool gateUp = not i_confOnly or confBull
bool gateDn = not i_confOnly or confBear
bool entryUp   = inSession and regime ==  1 and crossUp and gateUp
bool entryDown = inSession and regime == -1 and crossDn and gateDn

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

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=regime == 1 ? color.new(i_buyColor, 30) : regime == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)
plotshape(confBull, "CVD Conf Up", shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.tiny)
plotshape(confBear, "CVD Conf Dn", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.tiny)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CVP", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.flag, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CVP", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string rt = regime == 1 ? "FLOW UP" : regime == -1 ? "FLOW DOWN" : "FLAT"
    color  rc = regime == 1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "CVD Pivot",             text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Flow Regime",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, rt,                      text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "CVD",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(cvd, "#"),  text_color=cvd >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "CVD Slope",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(cvdSlope, "#"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "Confluence",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, confBull ? "BULL" : confBear ? "BEAR" : "-", text_color=confBull ? i_buyColor : confBear ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CVP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CVP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "CVP Buy",            "CVD-confirmed long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "CVP Sell",           "CVD-confirmed short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "CVP Any Signal",     "Any CVP signal on {{ticker}} {{interval}}")
alertcondition(confBull,                           "CVP Bull Confluence","Price/CVD bull pivot confluence on {{ticker}} {{interval}}")
alertcondition(confBear,                           "CVP Bear Confluence","Price/CVD bear pivot confluence on {{ticker}} {{interval}}")
alertcondition(not na(cPL),                        "CVP CVD Pivot Low",  "New CVD pivot low on {{ticker}} {{interval}}")
alertcondition(not na(cPH),                        "CVP CVD Pivot High", "New CVD pivot high on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "CVP EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "CVP EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(cvdSlope, 0),              "CVP Slope Zero",     "CVD slope crossed zero on {{ticker}} {{interval}}")
alertcondition(regime != regime[1],                "CVP Regime Flip",    "Flow regime flipped on {{ticker}} {{interval}}")
alertcondition(confBull or confBear,               "CVP Any Confluence", "Any CVD pivot confluence on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "CVP Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"CVP\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
