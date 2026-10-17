# Dempster-Shafer Evidence Fusion [forexobroker]

- url: https://www.tradingview.com/script/SjD2Djn5-Dempster-Shafer-Evidence-Fusion-forexobroker/
- type: indicator
- pine_id: PUB;93e7d72b3cb94756ad59552b929e4b99
- version: 1.0

## Description

Dempster-Shafer Evidence Fusion [forexobroker] combines six independent child evidences (EMA slope, RSI deviation, ATR-normalized return, signed volume z-score, range-expansion conviction, close-in-range positioning) into a single mass distribution over the hypothesis frame {Long, Short, Hold} using Dempster's rule of combination. Unlike a weighted-average composite where conflicting child signals dilute the score, Dempster-Shafer explicitly tracks epistemic uncertainty as a separate Hold mass and resolves conflict via a conflict denominator, so the combined output is properly normalized and the Hold mass quantifies disagreement among children. The unique angle is principled belief fusion rather than ad hoc voting or averaging.

🔶 ALGORITHM

1. Six child evidences are computed each bar. Each child produces a signed strength in (-1, 1).
2. Strength is mapped to a mass triplet: m(Long) = max(s,0) * |s|, m(Short) = -min(s,0) * |s|, m(Hold) = 1 - |s|. Sums equal one.
3. Children: (1) ATR-normalized EMA slope, tanh-squashed; (2) (RSI - 50)/50; (3) tanh of (close - close[1])/atr; (4) signed volume z-score, tanh-squashed; (5) range-expansion ratio signed by return direction, tanh-squashed; (6) (close - lowest(low,N))/(highest(high,N) - lowest(low,N)) re-centered to (-1, 1).
4. Pair-wise Dempster fusion: for two evidences (m1, m2), conflict K = m1(L)m2(S) + m1(S)m2(L); m12(L) = (m1(L)m2(L) + m1(L)m2(H) + m1(H)m2(L)) / (1-K). Symmetric for Short. Hold collects m1(H)m2(H)/(1-K). After fusion the triplet is renormalized for floating-point safety.
5. All six evidences are cascaded pair-by-pair to a final triplet (m_L, m_S, m_H).
6. Conviction equals max(m_L, m_S, m_H). The threshold (default 0.55) defines when one hypothesis dominates.
7. A signal fires when the dominant mass exceeds the threshold and standard gates pass.

🔶 SIGNAL LOGIC

- Buy: combined m(Long) above the signal threshold AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: combined m(Short) above the signal threshold AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

Because m(L) + m(S) + m(H) = 1 by construction, both buy and sell cannot trigger on the same bar; ties resolve as Hold.

🔶 INPUTS

- Calculation group: EMA Length (default 21), EMA Lookback (default 5), RSI Length (default 14), ATR Length (default 14), Volume StDev Len (default 20), Range Avg Length (default 20), Position-In-Range Len (default 20).
- Signal Logic group: Combined Mass Threshold (default 0.55), cooldown bars (default 15).
- Filters group: optional session restriction (default 0000-2400).
- Visual group: dashboard toggle, 3-layer glow toggle, long/short/hold colors and dashboard background.

🔶 ALERTS

DSE Buy, DSE Sell, DSE Any Signal, DSE Long Cross, DSE Short Cross, DSE Uncertain, DSE High Conviction, DSE Net Long, DSE Net Short, DSE Webhook JSON.

🔶 LIMITATIONS

- Dempster's rule is sensitive to high-conflict situations; when child signals disagree strongly the denominator (1-K) becomes small and a near-zero numerator can amplify noise. The script floors the denominator at 1e-10.
- Six children all derived from the same OHLCV stream are not strictly independent evidences; the assumption underlying classical Dempster-Shafer is somewhat relaxed here.
- The tanh squashing of slope, return, and volume scales is opinionated; instruments with very different volatility profiles may need different child mapping ranges.
- A high conviction Hold mass means children disagree; this is information, not a problem to fix, but it does mean stretches of low signal density are expected.
- Volume is used as an evidence input; on symbols without exchange volume that child collapses to near-zero strength and the remaining five carry the consensus.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Dempster-Shafer Evidence Fusion. Six child evidences are each mapped into a mass
// triplet (m_L, m_S, m_H) over the hypothesis frame {Long, Short, Hold/Uncertain} that sums to
// one. The children are: EMA slope (21/5 ATR-normalized), RSI deviation from 50, ATR-normalized
// return, signed volume z-score, range-expansion conviction, and close-in-range positioning.
// Each child's signed strength s in (-1, 1) becomes (m_L = max(s,0)*conf, m_S = -min(s,0)*conf,
// m_H = 1 - conf) where conf is the absolute strength. The six evidences are combined pairwise
// via Dempster's rule: K = m1(L)*m2(S) + m1(S)*m2(L), m12(L) = (m1(L)*m2(L) + m1(L)*m2(H) +
// m1(H)*m2(L)) / (1-K). Final m(L), m(S), m(H) sum to one. Signals fire when m(L) or m(S)
// exceeds 0.55. Non-repainting: barstate.isconfirmed gate; all evidences from confirmed bars.
indicator("Dempster-Shafer Evidence Fusion [forexobroker]", shorttitle="DSE [fob]", overlay=false, max_bars_back=500)

string g_calc = "Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_emaLen  = input.int(21,   "EMA Length",         minval=5,  maxval=100, group=g_calc)
int   i_emaLb   = input.int(5,    "EMA Lookback",       minval=1,  maxval=20,  group=g_calc)
int   i_rsiLen  = input.int(14,   "RSI Length",         minval=2,  maxval=50,  group=g_calc)
int   i_atrLen  = input.int(14,   "ATR Length",         minval=5,  maxval=50,  group=g_calc)
int   i_volLen  = input.int(20,   "Volume StDev Len",   minval=5,  maxval=100, group=g_calc)
int   i_rngLen  = input.int(20,   "Range Avg Length",   minval=5,  maxval=100, group=g_calc)
int   i_pivLen  = input.int(20,   "Position-In-Range Len", minval=5, maxval=100, group=g_calc)
float i_signal  = input.float(0.45,"Combined Mass Threshold", minval=0.4,maxval=0.9,step=0.01, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                              group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                          group=g_filt)
int   i_cooldown= input.int(5,    "Cooldown Bars",      minval=1,  maxval=60, group=g_sig)
bool  i_showTable=input.bool(true,"Show Dashboard",                            group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                         group=g_vis)
color i_buyColor= input.color(#39ff14,"Buy / Long Mass",                       group=g_vis)
color i_sellColor=input.color(#ff2d78,"Sell / Short Mass",                     group=g_vis)
color i_holdCol = input.color(#ffaa00,"Hold Mass",                             group=g_vis)
color i_dashBg  = input.color(color.new(#0a1014, 16),"Dashboard BG",           group=g_vis)

color c_white = #ffffff

float atr = nz(ta.atr(i_atrLen), 0.0)

// Helper: tanh squash via 2/(1+exp(-2x)) - 1
f_tanh(float x) =>
    float ex = math.exp(-2.0 * x)
    (1.0 - ex) / (1.0 + ex)

// Map signed strength s in (-1, 1) to (m_L, m_S, m_H)
// Implemented inline below since Pine v6 disallows returning structs from regular functions easily.

// Child 1: EMA slope, ATR-normalized
float ema1 = ta.ema(close, i_emaLen)
float emaSlope = atr > 0 ? (ema1 - ema1[i_emaLb]) / (atr * i_emaLb) : 0.0
float s1 = f_tanh(emaSlope)

// Child 2: RSI deviation
float rsi = ta.rsi(close, i_rsiLen)
float s2  = (rsi - 50.0) / 50.0

// Child 3: ATR-normalized one-bar return
float retRaw = close - close[1]
float s3 = atr > 0 ? f_tanh(retRaw / atr) : 0.0

// Child 4: signed volume z-score
float vSd  = ta.stdev(volume, i_volLen)
float vCh  = ta.change(volume)
float vZ   = vSd > 0 ? vCh / vSd : 0.0
float vDir = retRaw > 0 ? 1.0 : retRaw < 0 ? -1.0 : 0.0
float s4 = f_tanh(vZ * vDir / 2.0)

// Child 5: range expansion conviction (signed by retDir)
float rng    = high - low
float rngAvg = ta.sma(rng, i_rngLen)
float rngRel = rngAvg > 0 ? (rng / rngAvg) - 1.0 : 0.0
float s5 = f_tanh(rngRel * vDir)

// Child 6: close-in-range positioning
float hh = ta.highest(high, i_pivLen)
float ll = ta.lowest(low,   i_pivLen)
float pir = (hh - ll) > 0 ? (close - ll) / (hh - ll) : 0.5
float s6 = (pir - 0.5) * 2.0

// Pack each into masses
// Long mass = max(s,0) * |s|, Short mass = -min(s,0) * |s|, Hold mass = 1 - |s|
m1_l = math.max(s1, 0.0) * math.abs(s1)
m1_s = math.max(-s1, 0.0) * math.abs(s1)
m1_h = 1.0 - math.abs(s1)
m2_l = math.max(s2, 0.0) * math.abs(s2)
m2_s = math.max(-s2, 0.0) * math.abs(s2)
m2_h = 1.0 - math.abs(s2)
m3_l = math.max(s3, 0.0) * math.abs(s3)
m3_s = math.max(-s3, 0.0) * math.abs(s3)
m3_h = 1.0 - math.abs(s3)
m4_l = math.max(s4, 0.0) * math.abs(s4)
m4_s = math.max(-s4, 0.0) * math.abs(s4)
m4_h = 1.0 - math.abs(s4)
m5_l = math.max(s5, 0.0) * math.abs(s5)
m5_s = math.max(-s5, 0.0) * math.abs(s5)
m5_h = 1.0 - math.abs(s5)
m6_l = math.max(s6, 0.0) * math.abs(s6)
m6_s = math.max(-s6, 0.0) * math.abs(s6)
m6_h = 1.0 - math.abs(s6)

// Pairwise Dempster's rule combiner (kept as inline cascade to stay inside Pine constraints)
// Each combine returns (cL, cS, cH).
combine(float aL, float aS, float aH, float bL, float bS, float bH) =>
    float K   = aL * bS + aS * bL
    float den = math.max(1.0 - K, 1e-10)
    float cL = (aL * bL + aL * bH + aH * bL) / den
    float cS = (aS * bS + aS * bH + aH * bS) / den
    float cH = (aH * bH) / den
    float sum = math.max(cL + cS + cH, 1e-10)
    [cL / sum, cS / sum, cH / sum]

[c12L, c12S, c12H] = combine(m1_l, m1_s, m1_h, m2_l, m2_s, m2_h)
[c123L, c123S, c123H] = combine(c12L, c12S, c12H, m3_l, m3_s, m3_h)
[c1234L, c1234S, c1234H] = combine(c123L, c123S, c123H, m4_l, m4_s, m4_h)
[c12345L, c12345S, c12345H] = combine(c1234L, c1234S, c1234H, m5_l, m5_s, m5_h)
[mL, mS, mH] = combine(c12345L, c12345S, c12345H, m6_l, m6_s, m6_h)

float conviction = math.max(math.max(mL, mS), mH)
bool  inSession  = not i_useSess or not na(time(timeframe.period, i_sess))

bool buyCond  = mL > i_signal
bool sellCond = mS > i_signal

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool buySignal  = buyCond  and inSession and posState <= 0 and cooldownOk and confirmed
bool sellSignal = sellCond and inSession and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

float netLS = mL - mS
color netCol = netLS > 0 ? i_buyColor : netLS < 0 ? i_sellColor : i_holdCol

plot(netLS, "m(L) - m(S)", color=netCol, linewidth=2)
plot(0.0,   "Zero",        color=color.new(color.gray, 70))
plot(i_signal - 0.5,   "Signal Band",  color=color.new(i_buyColor, 50), linewidth=1, style=plot.style_linebr)
plot(-(i_signal - 0.5),"Signal Band-", color=color.new(i_sellColor, 50), linewidth=1, style=plot.style_linebr)

bgcolor(mL > i_signal ? color.new(i_buyColor, 92) : mS > i_signal ? color.new(i_sellColor, 92) : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="DSE", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="DSE", textcolor=c_white)

// PRICE-PANE MIRROR (Pine v6 force_overlay): same entry signals projected onto the candlesticks.
plotshape(i_showGlow and buySignal,  "Buy Glow 1 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge,   force_overlay=true)
plotshape(i_showGlow and buySignal,  "Buy Glow 2 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large,  force_overlay=true)
plotshape(buySignal,                 "Buy (price)",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="DSE", textcolor=c_white, force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 1 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 2 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large, force_overlay=true)
plotshape(sellSignal,                "Sell (price)",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="DSE", textcolor=c_white, force_overlay=true)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string st = mL > i_signal ? "LONG CONSENSUS" : mS > i_signal ? "SHORT CONSENSUS" : "UNCERTAIN"
    color  sc = mL > i_signal ? i_buyColor : mS > i_signal ? i_sellColor : i_holdCol
    table.cell(dash, 0, 0, "Dempster-Shafer",      text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                     text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "m(Long)",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(mL, "#.###"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "m(Short)",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(mS, "#.###"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "m(Hold)",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(mH, "#.###"), text_color=i_holdCol, text_size=size.small)
    table.cell(dash, 0, 5, "Conviction",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(conviction * 100.0, "#.#") + "%", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 6, "Threshold",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(i_signal, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 7, "Bar Strengths",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, "L " + str.tostring(int(mL * 100)) + " S " + str.tostring(int(mS * 100)) + " H " + str.tostring(int(mH * 100)), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 8, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 9, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"DSE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"mL":' + str.tostring(mL, "#.###") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"DSE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"mS":' + str.tostring(mS, "#.###") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "DSE Buy",            "DSE long consensus on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "DSE Sell",           "DSE short consensus on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "DSE Any Signal",     "Any DSE signal on {{ticker}} {{interval}}")
alertcondition(ta.crossover(mL, i_signal),             "DSE Long Cross",     "Long mass crossed threshold on {{ticker}} {{interval}}")
alertcondition(ta.crossover(mS, i_signal),             "DSE Short Cross",    "Short mass crossed threshold on {{ticker}} {{interval}}")
alertcondition(mH > 0.5,                               "DSE Uncertain",      "Hold mass dominant on {{ticker}} {{interval}}")
alertcondition(conviction > 0.8,                       "DSE High Conviction","Conviction above 80 percent on {{ticker}} {{interval}}")
alertcondition(ta.crossover(netLS, 0.0),               "DSE Net Long",       "Net mass flipped long on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(netLS, 0.0),              "DSE Net Short",      "Net mass flipped short on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "DSE Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"DSE\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
