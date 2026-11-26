# Money Flow Regime [forexobroker]

- url: https://www.tradingview.com/script/SylrGYV8-Money-Flow-Regime-forexobroker/
- type: indicator
- pine_id: PUB;a247e6850aba4613948afd27b773b133
- version: 1.0

## Description

Money Flow Regime [forexobroker] reads the Chaikin-style accumulation/distribution flow of an instrument, z-normalises it over a rolling window, and sorts that reading into five symmetric regime bands (strong-in, mild-in, neutral, mild-out, strong-out). The active band sets a directional bias and a reclaim-EMA cross times the actual entry, so you act with the dominant money-flow rather than against it. The symmetric banding means the read and the rules are identical long or short.

🔶 ALGORITHM

1. Build a money-flow multiplier per bar: ((close - low) - (high - close)) / (high - low), times volume, accumulated into a running Accumulation/Distribution line.
2. Compute a Chaikin-style oscillator as the spread of a fast EMA minus a slow EMA of the A/D line.
3. Z-normalise that oscillator over the Normalise Window using its rolling mean and standard deviation to get a flow z-score.
4. Sort the z-score into bands: |z| >= Strong Band Z is a strong regime, |z| >= Mild Band Z is a mild regime, otherwise neutral. Sign of z sets the bias (inflow bullish, outflow bearish).
5. Once a tradable band sets the bias, a close-cross of the Entry Reclaim EMA in the bias direction times the entry. ATR is tracked for context.

🔶 SIGNAL LOGIC

- Buy: in-session AND regime is tradable AND flow bias is bullish AND close crosses over the reclaim EMA AND not already long AND cooldown elapsed AND barstate.isconfirmed (position-locked).
- Sell: in-session AND regime is tradable AND flow bias is bearish AND close crosses under the reclaim EMA AND not already short AND cooldown elapsed AND barstate.isconfirmed (position-locked).
Only fires when the flow band is tradable (mild-or-strong, or strong-only if Require Strong Band is on).

🔶 INPUTS

- Money Flow: Chaikin fast/slow EMA lengths, normalise window, and the band z thresholds; key default Chaikin Fast EMA = 3.
- Money Flow: Mild and Strong band z levels separate neutral, mild and strong regimes; default Strong Band Z = 1.0.
- Money Flow: ATR length for volatility context; default ATR Length = 14.
- Signal Logic: Entry Reclaim EMA that times the entry inside the bias; default Entry Reclaim EMA = 9.
- Signal Logic: Require Strong Band restricts trading to the strong regime only; default off.
- Signal Logic: Cooldown bars between signals; default Cooldown Bars = 5.
- Filters: optional session restriction with a session window; default Restrict to Session off.
- Visual: dashboard, 3-layer glow, reclaim-EMA plot, and buy/sell/background colors; dashboard default on.

🔶 ALERTS

MFR Buy, MFR Sell, MFR Any Signal, MFR Strong In, MFR Strong Out, MFR Bias Bull, MFR Bias Bear, MFR EMA Up, MFR EMA Down, MFR Flow Zero, MFR Band Change, MFR Armed, MFR Webhook JSON.

🔶 LIMITATIONS

- Requires a real volume feed; on instruments with synthetic or missing volume the flow reading is unreliable.
- Needs warm-up bars for the A/D EMAs and the normalise window before bands stabilise.
- Z-band defaults are tuned for liquid instruments; thin markets may need wider thresholds.
- The reclaim EMA introduces deliberate entry lag versus the raw band change, by design.
- Regime bands describe flow context, not a forecast; chop can flip bias repeatedly.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Money Flow Regime. A money-flow oscillator (Chaikin-style: an EMA spread of the
// Accumulation/Distribution line, expressed as a percent of price) is sorted into regime bands:
// strong-in, mild-in, neutral, mild-out, strong-out. The band sets a bias and a reclaim-EMA
// cross times entries; raw band-cross events are also alerted. Bands are symmetric so the read
// is the same long or short. Non-repainting: bar-close evaluation, volume-driven, ATR context.
indicator("Money Flow Regime [forexobroker]", shorttitle="MFR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Money Flow"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_fast    = input.int(3,    "Chaikin Fast EMA",      minval=2,  maxval=20, group=g_calc, tooltip="Fast EMA of the A/D line.")
int   i_slow    = input.int(10,   "Chaikin Slow EMA",      minval=5,  maxval=50, group=g_calc, tooltip="Slow EMA of the A/D line.")
int   i_norm    = input.int(50,   "Normalise Window",      minval=10, maxval=200, group=g_calc, tooltip="Window the flow is z-normalised over for regime banding.")
float i_strong  = input.float(1.0,"Strong Band Z",         minval=0.3, maxval=4.0, step=0.1, group=g_calc, tooltip="|z| above this = strong flow regime.")
float i_mild    = input.float(0.3,"Mild Band Z",           minval=0.0, maxval=2.0, step=0.1, group=g_calc, tooltip="|z| above this but below Strong = mild flow.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After the flow band sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_strongOnly=input.bool(false,"Require Strong Band",                        group=g_sig, tooltip="On = only trade in the strong flow regime; Off = mild or strong.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#06d6a0,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ef476f,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#08130f, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float rngBar= high - low
float mfm   = rngBar > 0 ? ((close - low) - (high - close)) / rngBar : 0.0
var float ad = 0.0
ad := ad + mfm * nz(volume, 0.0)
float chaikin = ta.ema(ad, i_fast) - ta.ema(ad, i_slow)
float fMean = ta.sma(chaikin, i_norm)
float fStd  = ta.stdev(chaikin, i_norm)
float fz    = fStd > 0 ? (chaikin - fMean) / fStd : 0.0
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int band = fz >=  i_strong ? 2 : fz >=  i_mild ? 1 : fz <= -i_strong ? -2 : fz <= -i_mild ? -1 : 0
int bias = band >= 1 ? 1 : band <= -1 ? -1 : 0
bool strong = math.abs(band) == 2
bool tradable = i_strongOnly ? strong : math.abs(band) >= 1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and tradable and bias ==  1 and crossUp
bool entryDown = inSession and tradable and bias == -1 and crossDn

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

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=bias == 1 ? color.new(i_buyColor, 30) : bias == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="MFR", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="MFR", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(band == 2 ? color.new(i_buyColor, 88) : band == 1 ? color.new(i_buyColor, 94) : band == -2 ? color.new(i_sellColor, 88) : band == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string bt = band == 2 ? "STRONG IN" : band == 1 ? "MILD IN" : band == -1 ? "MILD OUT" : band == -2 ? "STRONG OUT" : "NEUTRAL"
    color  bc = band >= 1 ? i_buyColor : band <= -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Money Flow Regime",     text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Flow Band",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, bt,                      text_color=bc, text_size=size.small)
    table.cell(dash, 0, 2, "Flow Z",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(fz, "0.00"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Chaikin",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(chaikin, "#"), text_color=chaikin >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Tradable",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, tradable ? "YES" : "NO", text_color=tradable ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "ATR",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(atr, "#.#####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"MFR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MFR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "MFR Buy",            "Money-flow long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "MFR Sell",           "Money-flow short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "MFR Any Signal",     "Any MFR signal on {{ticker}} {{interval}}")
alertcondition(band == 2 and band[1] != 2,         "MFR Strong In",      "Strong inflow regime on {{ticker}} {{interval}}")
alertcondition(band == -2 and band[1] != -2,       "MFR Strong Out",     "Strong outflow regime on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "MFR Bias Bull",      "Flow bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "MFR Bias Bear",      "Flow bias turned bearish on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "MFR EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "MFR EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(chaikin, 0),               "MFR Flow Zero",      "Chaikin flow crossed zero on {{ticker}} {{interval}}")
alertcondition(band != band[1],                    "MFR Band Change",    "Flow band changed on {{ticker}} {{interval}}")
alertcondition(tradable and not tradable[1],       "MFR Armed",          "Flow regime became tradable on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "MFR Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"MFR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
