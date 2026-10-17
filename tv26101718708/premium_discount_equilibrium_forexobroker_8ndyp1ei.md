# Premium Discount Equilibrium [forexobroker]

- url: https://www.tradingview.com/script/8Ndyp1EI-Premium-Discount-Equilibrium-forexobroker/
- type: indicator
- pine_id: PUB;2679ed8e11f04346b6559b7611acf5d9
- version: 1.0

## Description

Premium Discount Equilibrium [forexobroker] builds a dealing range from the rolling N-bar high and low and marks its 50% midpoint as equilibrium: above it is premium (expensive, favor shorts), below it is discount (cheap, favor longs). The unique angle is executing the ICT premium/discount model on an EMA reclaim so entries are timed rather than merely biased, with an optional Optimal Trade Entry (OTE) band gate for deeper-discount / higher-premium precision.

🔶 ALGORITHM

1. Build the dealing range from the highest high and lowest low over Dealing Range Length bars.
2. Compute equilibrium as the range midpoint (rngHi + rngLo) / 2, with an EQ Buffer expressed as a fraction of range defining a neutral band where no bias applies.
3. Classify price: in premium when close is above EQ + buffer, in discount when below EQ - buffer.
4. Derive the OTE bands: discount OTE = 21% to 38% off the low, premium OTE = 21% to 38% off the high (the classic 62-79% retrace zone), used for an optional confirmation gate.
5. Entry timing: an EMA reclaim (ta.crossover / ta.crossunder of close vs the Reclaim EMA) inside the correct zone times the trade; long entries require discount, short entries require premium.
6. Optional Require OTE Zone filter restricts signals to bars inside the matching OTE band.

🔶 SIGNAL LOGIC

- Buy: price in discount (close below EQ - buffer) and close crosses over the Reclaim EMA, in session, OTE gate satisfied if enabled, position not already long, after the cooldown window, only on barstate.isconfirmed; position-lock flips to LONG.
- Sell: price in premium (close above EQ + buffer) and close crosses under the Reclaim EMA, in session, OTE gate satisfied if enabled, position not already short, cooldown elapsed, on barstate.isconfirmed; position-lock flips to SHORT.
Only fires when price is on the correct side of equilibrium (discount for longs, premium for shorts).

🔶 INPUTS

- Range: dealing range length for the high/low window (default 60) and ATR length.
- Equilibrium band: EQ buffer as a fraction of range defining the neutral no-bias zone (default 0.05).
- Signal Logic: Reclaim EMA length (default 9).
- OTE: show OTE 62-79 band toggle (default on).
- Cooldown: minimum bars between signals (default 5).
- Filters: optional session restriction and a Require OTE Zone gate (default off).
- Visual: zone plots (EQ, range high/low, OTE fills), dashboard, 3-layer glow, buy/sell colors, dashboard background.

🔶 ALERTS

PDE Buy, PDE Sell, PDE Any Signal, PDE Enter Premium, PDE Enter Discount, PDE Discount OTE, PDE Premium OTE, PDE EQ Cross, PDE EMA Up, PDE EMA Down, PDE Range High, PDE Range Low, PDE Webhook JSON.

🔶 LIMITATIONS

- Requires warm-up: the dealing range needs Dealing Range Length bars before it stabilizes.
- The range high/low recompute every bar, so equilibrium and zones shift as the rolling window moves; signals themselves confirm on bar close and do not repaint.
- Defaults are tuned for liquid instruments; range length and EQ buffer may need adjustment per market.
- Require OTE Zone mode is stricter and produces noticeably fewer signals.
- Premium/discount is a contextual bias, not a guaranteed reversal; ranging-to-trending transitions can keep price extended in one zone.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Premium / Discount Equilibrium. A dealing range is built from the rolling N-bar high
// and low; its 50% midpoint is the equilibrium (EQ). Price above EQ = PREMIUM (expensive, favour
// shorts); below EQ = DISCOUNT (cheap, favour longs). The ICT premium/discount model: only buy in
// discount and sell in premium, executed on an EMA reclaim so entries are timed, not just biased.
// Optional Optimal Trade Entry (OTE) 62-79% band highlight. Non-repainting, bar-close signals.
indicator("Premium Discount Equilibrium [forexobroker]", shorttitle="PDE [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Range"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_rngLen  = input.int(60,   "Dealing Range Length", minval=10, maxval=300, group=g_calc, tooltip="Bars used to build the high/low dealing range.")
float i_eqBuf   = input.float(0.05,"EQ Buffer (frac of range)", minval=0.0, maxval=0.3, step=0.01, group=g_calc, tooltip="Neutral band around EQ where no bias applies.")
int   i_emaLen  = input.int(9,    "Reclaim EMA Length",   minval=2,  maxval=50, group=g_calc)
bool  i_useOTE  = input.bool(true,"Show OTE 62-79 Band",                         group=g_calc, tooltip="Optimal Trade Entry zone inside discount/premium.")
int   i_atrLen  = input.int(14,   "ATR Length",           minval=5,  maxval=50, group=g_calc)
int   i_cooldown= input.int(5,    "Cooldown Bars",        minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                        group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                   group=g_filt)
bool  i_oteOnly = input.bool(false,"Require OTE Zone",                           group=g_filt, tooltip="Only fire when price is inside the OTE band.")
bool  i_showZone= input.bool(true,"Show Zones",                                  group=g_vis)
bool  i_showTable=input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
color i_buyColor= input.color(#2dd4bf,"Buy Color",                               group=g_vis)
color i_sellColor=input.color(#fb7185,"Sell Color",                              group=g_vis)
color i_dashBg  = input.color(color.new(#1a0a24, 16),"Dashboard BG",             group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float rngHi = ta.highest(high, i_rngLen)
float rngLo = ta.lowest(low,  i_rngLen)
float rng   = rngHi - rngLo
float eq    = (rngHi + rngLo) / 2.0
float buf   = i_eqBuf * rng

bool  inPremium  = close > eq + buf
bool  inDiscount = close < eq - buf
bool  inSession  = not i_useSess or not na(time(timeframe.period, i_sess))

// OTE band: discount OTE = 0.62-0.79 retrace from top (deep discount); premium OTE mirrored
float oteDlo = rngLo + 0.21 * rng
float oteDhi = rngLo + 0.38 * rng
float otePlo = rngHi - 0.38 * rng
float otePhi = rngHi - 0.21 * rng
bool  inDiscOTE = close >= oteDlo and close <= oteDhi
bool  inPremOTE = close >= otePlo and close <= otePhi

float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)

bool oteOkLong  = not i_oteOnly or inDiscOTE
bool oteOkShort = not i_oteOnly or inPremOTE
bool entryUp   = inDiscount and crossUp and inSession and oteOkLong
bool entryDown = inPremium  and crossDn and inSession and oteOkShort

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

plot(i_showZone ? eq : na,    "Equilibrium", color=color.new(color.gray, 30), linewidth=2)
plot(i_showZone ? rngHi : na, "Range High",  color=color.new(i_sellColor, 50), linewidth=1)
plot(i_showZone ? rngLo : na, "Range Low",   color=color.new(i_buyColor, 50),  linewidth=1)
p_oteDhi = plot(i_showZone and i_useOTE ? oteDhi : na, "OTE D Hi", color=color.new(i_buyColor, 70), linewidth=1)
p_oteDlo = plot(i_showZone and i_useOTE ? oteDlo : na, "OTE D Lo", color=color.new(i_buyColor, 70), linewidth=1)
fill(p_oteDhi, p_oteDlo, color=color.new(i_buyColor, 90))
p_otePhi = plot(i_showZone and i_useOTE ? otePhi : na, "OTE P Hi", color=color.new(i_sellColor, 70), linewidth=1)
p_otePlo = plot(i_showZone and i_useOTE ? otePlo : na, "OTE P Lo", color=color.new(i_sellColor, 70), linewidth=1)
fill(p_otePhi, p_otePlo, color=color.new(i_sellColor, 90))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="PDE", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="PDE", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(inDiscount ? color.new(i_buyColor, 95) : inPremium ? color.new(i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string zt = inPremium ? "PREMIUM" : inDiscount ? "DISCOUNT" : "EQUILIBRIUM"
    color  zc = inPremium ? i_sellColor : inDiscount ? i_buyColor : color.gray
    table.cell(dash, 0, 0, "Premium Discount EQ",  text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Zone",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, zt,                     text_color=zc, text_size=size.small)
    table.cell(dash, 0, 2, "Equilibrium",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(eq, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Range",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(rngLo, "#.##") + "-" + str.tostring(rngHi, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "In OTE",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, inDiscOTE ? "DISC OTE" : inPremOTE ? "PREM OTE" : "NO", text_color=inDiscOTE ? i_buyColor : inPremOTE ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Reclaim EMA",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(ema, "#.##"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"PDE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"PDE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "PDE Buy",           "Discount reclaim long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "PDE Sell",          "Premium reclaim short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "PDE Any Signal",    "Any PDE signal on {{ticker}} {{interval}}")
alertcondition(inPremium and not inPremium[1],         "PDE Enter Premium", "Price entered premium on {{ticker}} {{interval}}")
alertcondition(inDiscount and not inDiscount[1],       "PDE Enter Discount","Price entered discount on {{ticker}} {{interval}}")
alertcondition(inDiscOTE and not inDiscOTE[1],         "PDE Discount OTE",  "Price entered discount OTE on {{ticker}} {{interval}}")
alertcondition(inPremOTE and not inPremOTE[1],         "PDE Premium OTE",   "Price entered premium OTE on {{ticker}} {{interval}}")
alertcondition(ta.cross(close, eq),                    "PDE EQ Cross",      "Price crossed equilibrium on {{ticker}} {{interval}}")
alertcondition(crossUp,                                "PDE EMA Up",        "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                "PDE EMA Down",      "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(close >= rngHi,                         "PDE Range High",    "Price tagged range high on {{ticker}} {{interval}}")
alertcondition(close <= rngLo,                         "PDE Range Low",     "Price tagged range low on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "PDE Webhook JSON",  "{\"action\":\"signal\",\"indicator\":\"PDE\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
