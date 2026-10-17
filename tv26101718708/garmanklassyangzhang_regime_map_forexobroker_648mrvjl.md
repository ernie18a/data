# Garman-Klass-Yang-Zhang Regime Map [forexobroker]

- url: https://www.tradingview.com/script/648mrvJl-Garman-Klass-Yang-Zhang-Regime-Map-forexobroker/
- type: indicator
- pine_id: PUB;f83010e21dee410694767be2b6645b76
- version: 1.0

## Description

Garman-Klass-Yang-Zhang Regime Map [forexobroker] combines three of the most efficient single-bar volatility estimators — the overnight gap return, the open-to-close drift term, and Rogers-Satchell intraday variance — into one GKYZ sigma with a drift-correction constant k. Each bar's GKYZ value is then ranked against its rolling 100-bar percentile and the regime is colored Low (green), Medium (yellow), or High (red) directly on the price chart. The unique angle is using a research-grade variance estimator instead of plain ATR, then trading the transitions — not the levels — of the regime ribbon.

🔶 ALGORITHM

1. Three components per bar: overnight gap log(open/prev close)^2, open-to-close log(close/open)^2, Rogers-Satchell log(H/C) log(H/O) + log(L/C) log(L/O).
2. Drift-correction k = 0.34 / (1.34 + (N+1)/(N-1)) (Yang-Zhang scaling); GKYZ per-bar variance = gap + k oc + (1-k) RS.
3. Rolling GKYZ variance over volatility window (default 20) divided by N, then sqrt; this is sigma_GKYZ.
4. Sigma_GKYZ is ranked across a percentile window (default 100); thresholds default to 33 and 66.
5. Regime classification: Low if below 33rd percentile, Medium if between, High if above 66th.
6. Signals fire on transitions, not on levels: a Low->Medium->High ladder over three confirmed bars is a momentum-direction breakout entry; a High-then-Low contraction (regime hit 2 within the last five bars and is now 0) is a counter-momentum mean-reversion entry.

🔶 SIGNAL LOGIC

- Buy: (Low->Medium->High three-bar ladder AND close > close[momentum lookback]) OR (recent High then current Low AND prior momentum was bearish) AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: (Low->Medium->High three-bar ladder AND close < close[momentum lookback]) OR (recent High then current Low AND prior momentum was bullish) AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

The ladder is a breakout pattern, the spike-back is a mean-reversion pattern, both gated by direction.

🔶 INPUTS

- GKYZ Calculation group: volatility window default 20, percentile window default 100, Low/High percentile defaults 33/66.
- Signal Logic group: momentum lookback default 5, cooldown bars default 15.
- Filters group: session restriction (default 0000-2400).
- Visual group: regime ribbon toggle, dashboard, 3-layer glow, three regime colors, buy and sell colors.

🔶 ALERTS

GKYZ Buy, GKYZ Sell, GKYZ Any Signal, GKYZ Enter High, GKYZ Enter Low, GKYZ Ladder Up, GKYZ Spike Back, GKYZ Regime Change, GKYZ Vol Up, GKYZ Vol Down, GKYZ Webhook JSON.

🔶 LIMITATIONS

- GKYZ assumes log-OHLC are jointly normal; very large gaps or limit moves can produce occasional outliers that dominate the variance term.
- The percentile window classifies the current bar relative to a 100-bar history; on a brand-new regime that lasts longer than the window, the script will eventually re-rank the new baseline and stop firing fresh entries.
- The ladder pattern needs three consecutive confirmed bars to transition Low->Medium->High; sharp single-bar moves that skip Medium will not fire that path.
- Defaults are tuned for NQ and other index futures on intraday timeframes; instruments with persistent overnight gaps inflate the gap term and bias the regime high.
- The spike-back path uses the highest regime over the last five bars, so an isolated High bar followed by a brief retracement can register as a contraction even if the broader regime is still elevated.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Garman-Klass-Yang-Zhang Regime Map. The GKYZ volatility estimator combines the overnight
// gap return, the open-to-close move, and Rogers-Satchell intraday volatility with a drift-correction
// constant k. The result is one of the most efficient single-bar volatility estimators in the
// literature. A rolling 100-bar percentile of sigma_GKYZ classifies the current bar into Low (<33),
// Medium (33-66), or High (>66) regimes. Regime transitions drive signals: a 3-bar ladder up
// (Low->Medium->High) is a breakout entry in the 5-bar momentum direction; a High->Low contraction
// after a spike is a mean-reversion entry. Non-repainting: all components are confirmed-bar OHLC.
indicator("Garman-Klass-Yang-Zhang Regime Map [forexobroker]", shorttitle="GKYZ [fob]", overlay=true, max_bars_back=500, max_boxes_count=500)

string g_calc = "GKYZ Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_len     = input.int(20,   "Volatility Window",     minval=5,   maxval=100, group=g_calc, tooltip="Bars used to compute the GKYZ rolling variance.")
int   i_rankLen = input.int(100,  "Percentile Window",     minval=20,  maxval=500, group=g_calc, tooltip="Window for classifying the current GKYZ into Low/Medium/High.")
int   i_lowPct  = input.int(33,   "Low Percentile",        minval=5,   maxval=49,  group=g_calc)
int   i_highPct = input.int(66,   "High Percentile",       minval=51,  maxval=95,  group=g_calc)
int   i_momLen  = input.int(5,    "Momentum Lookback",     minval=1,   maxval=20,  group=g_sig)
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,   maxval=60,  group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                           group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                      group=g_filt)
bool  i_showRibbon= input.bool(true,"Show Regime Ribbon",                           group=g_vis)
bool  i_showTable = input.bool(true,"Show Dashboard",                               group=g_vis)
bool  i_showGlow  = input.bool(true,"Show 3-Layer Glow",                            group=g_vis)
color i_lowCol    = input.color(#4ade80,"Low Regime",                               group=g_vis)
color i_medCol    = input.color(#ffaa00,"Medium Regime",                            group=g_vis)
color i_highCol   = input.color(#ff2d78,"High Regime",                              group=g_vis)
color i_buyColor  = input.color(#39ff14,"Buy Color",                                group=g_vis)
color i_sellColor = input.color(#f472b6,"Sell Color",                               group=g_vis)
color i_dashBg    = input.color(color.new(#0c1810, 16),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float prevC = nz(close[1], open)
float gON   = math.log(math.max(open, 1e-10) / math.max(prevC, 1e-10))
float varON = gON * gON
float gOC   = math.log(math.max(close, 1e-10) / math.max(open, 1e-10))
float varOC = gOC * gOC
float lhc   = math.log(math.max(high, 1e-10) / math.max(close, 1e-10))
float lho   = math.log(math.max(high, 1e-10) / math.max(open, 1e-10))
float llc   = math.log(math.max(low, 1e-10) / math.max(close, 1e-10))
float llo   = math.log(math.max(low, 1e-10) / math.max(open, 1e-10))
float varRS = lhc * lho + llc * llo

float Nf    = i_len
float k     = 0.34 / (1.34 + (Nf + 1.0) / math.max(Nf - 1.0, 1.0))
float bar2  = varON + k * varOC + (1.0 - k) * varRS

float gkyzVar = math.sum(bar2, i_len) / i_len
float gkyz    = math.sqrt(math.max(gkyzVar, 1e-20))

float lowBand  = ta.percentile_nearest_rank(gkyz, i_rankLen, i_lowPct)
float highBand = ta.percentile_nearest_rank(gkyz, i_rankLen, i_highPct)

int regime = gkyz < lowBand ? 0 : gkyz < highBand ? 1 : 2

// Lift ta.highest out of the conditional expression so it runs every bar.
float highRegime5 = ta.highest(regime, 5)
bool ladderUp = regime == 2 and regime[1] == 1 and regime[2] == 0
bool spikeBack= regime == 0 and highRegime5 == 2

bool momUp   = close > close[i_momLen]
bool momDown = close < close[i_momLen]

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool stepUp   = regime > regime[1]
bool stepDown = regime < regime[1]
bool entryUp   = inSession and (ladderUp and momUp or spikeBack and momDown[1] or stepUp and momUp)
bool entryDown = inSession and (ladderUp and momDown or spikeBack and momUp[1] or stepDown and momDown)

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

color regimeColor = regime == 0 ? i_lowCol : regime == 1 ? i_medCol : i_highCol

// Always-visible continuous baseline so the indicator shows immediately on the main chart.
// 20-bar SMA repainted in the active regime color is the simplest persistent marker.
plot(ta.sma(close, 20), "Regime MA", color=regimeColor, linewidth=2)

// Lift ta.lowest out of the conditional block so it runs every bar.
float refLo = ta.lowest(low, 50)
var box ribbonBox = na
if i_showRibbon and barstate.isconfirmed
    float pad   = (close * 0.0005)
    box.delete(ribbonBox)
    ribbonBox := box.new(bar_index, refLo - pad, bar_index + 1, refLo - 2 * pad, border_color=color.new(regimeColor, 0), bgcolor=color.new(regimeColor, 30))

bgcolor(i_showRibbon ? color.new(regimeColor, 92) : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="GKYZ", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="GKYZ", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string regimeStr = regime == 0 ? "LOW" : regime == 1 ? "MEDIUM" : "HIGH"
    table.cell(dash, 0, 0, "GKYZ Regime Map",     text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",               text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeStr,             text_color=regimeColor, text_size=size.small)
    table.cell(dash, 0, 2, "Sigma GKYZ",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(gkyz, "#.######"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Low Band",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(lowBand, "#.######"), text_color=i_lowCol, text_size=size.small)
    table.cell(dash, 0, 4, "High Band",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(highBand, "#.######"), text_color=i_highCol, text_size=size.small)
    table.cell(dash, 0, 5, "k Constant",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(k, "#.####"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Ladder Up",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, ladderUp ? "YES" : "NO", text_color=ladderUp ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Position",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"GKYZ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"GKYZ","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "GKYZ Buy",            "GKYZ regime long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "GKYZ Sell",           "GKYZ regime short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "GKYZ Any Signal",     "Any GKYZ signal on {{ticker}} {{interval}}")
alertcondition(regime == 2 and regime[1] != 2,    "GKYZ Enter High",     "Regime entered HIGH on {{ticker}} {{interval}}")
alertcondition(regime == 0 and regime[1] != 0,    "GKYZ Enter Low",      "Regime entered LOW on {{ticker}} {{interval}}")
alertcondition(ladderUp,                           "GKYZ Ladder Up",      "Low->Medium->High ladder on {{ticker}} {{interval}}")
alertcondition(spikeBack,                          "GKYZ Spike Back",     "High to Low contraction on {{ticker}} {{interval}}")
alertcondition(regime != regime[1],                "GKYZ Regime Change",  "Regime changed on {{ticker}} {{interval}}")
alertcondition(gkyz > gkyz[1],                     "GKYZ Vol Up",         "GKYZ vol expanding on {{ticker}} {{interval}}")
alertcondition(gkyz < gkyz[1],                     "GKYZ Vol Down",       "GKYZ vol contracting on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "GKYZ Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"GKYZ\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
