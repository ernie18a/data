# PCA Projection Pulse [forexobroker]

- url: https://www.tradingview.com/script/ycA2dzQE-PCA-Projection-Pulse-forexobroker/
- type: indicator
- pine_id: PUB;4b2ea17804304a79b2d99dd333923238
- version: 1.0

## Description

PCA Projection Pulse runs Principal Component Analysis on a 2-D feature space (z-scored close, z-scored volume) over a rolling window. The first principal component is the direction of maximum joint variance; projecting the current point onto PC1 measures how strongly current price-and-volume aligns with that direction. Signals fire on edge crossings of the projection threshold.

🔶 ALGORITHM

1. zC = (close - mean_close) / sd_close; zV = (volume - mean_volume) / sd_volume.
2. 2x2 covariance matrix entries: s11 = var(close), s22 = var(volume), s12 = cov(close, volume).
3. trace = s11 + s22; det = s11 * s22 - s12^2; eigenvalue lambda1 = (trace + sqrt(trace^2 - 4 * det)) / 2.
4. PC1 eigenvector ~ (lambda1 - s22, s12); normalise to unit length (ux, uy).
5. Projection = zC * ux + zV * uy.
6. Pulse regime when |projection| >= threshold.

🔶 SIGNAL LOGIC

- Buy: projection >= +threshold edge AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: projection <= -threshold edge.
- Position-lock state machine.

🔶 INPUTS

- Covariance Window (default 40)
- Projection Threshold (default 0.50)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, xcross with PC text, PC1 direction line, buy / sell colors

🔶 ALERTS

PPP Buy, PPP Sell, PPP Any Signal, PPP Pulse Up, PPP Pulse Down, PPP Strong Pulse, PPP Single Direc, PPP Same Sign, PPP Webhook JSON.

🔶 LIMITATIONS

- 2-D PCA captures only the dominant joint direction; higher-D variants (more features) would extract richer signals but require larger covariance matrices.
- Closed-form eigendecomposition is exact for 2x2 cases; for richer feature spaces an iterative solver is needed.
- Forex tick volume noise can dominate PC1; assets with reliable volume produce cleaner pulses.
- The "PC1 direction line" is anchored at EMA20 and scales projection by ATR — visual cue, not a level.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: 2-D PCA on (z-scored close, z-scored volume). The 2x2 covariance matrix has a
// closed-form first principal component eigenvector via the trace / determinant: lambda1 =
// (trace + sqrt(trace^2 - 4 * det)) / 2; PC1 direction = (lambda1 - sigma_22, sigma_12). The
// projection of the current point onto PC1 is the "pulse"; large positive = strongly aligned with
// joint price-and-volume direction. Distinct from any volume oscillator: PCA finds the direction
// of MAXIMUM joint variance, not a single weighted sum.
indicator("PCA Projection Pulse [forexobroker]", shorttitle="PPP [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "PCA"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(40,   "Covariance Window",     minval=15, maxval=200, group=g_calc)
float i_thr      = input.float(0.50,"Projection Threshold", minval=0.10, maxval=3.0, step=0.05, group=g_sig)
int   i_cooldown = input.int(4,    "Cooldown Bars",         minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true,"Show Dashboard",                              group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                           group=g_vis)
bool  i_showLine = input.bool(true,"Show PC1 Direction",                          group=g_vis)
color i_buyColor = input.color(#aeea00,"Buy Color (Lime)",                        group=g_vis)
color i_sellColor= input.color(#e91e63,"Sell Color (Magenta)",                    group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#0a0a14, 22)

// ─── 2D COVARIANCE + PC1 ───────────────────────────────────────────────────────
int N = i_winLen
float meanC = ta.sma(close, N)
float meanV = ta.sma(volume, N)
float sdC   = ta.stdev(close, N)
float sdV   = ta.stdev(volume, N)
float zC    = sdC > 0 ? (close - meanC) / sdC : 0.0
float zV    = sdV > 0 ? (volume - meanV) / sdV : 0.0

float s11 = ta.variance(close, N)
float s22 = ta.variance(volume, N)
float s12 = ta.sma(close * volume, N) - meanC * meanV

float trace = s11 + s22
float det   = s11 * s22 - s12 * s12
float discr = trace * trace - 4 * det
float lam1  = discr > 0 ? (trace + math.sqrt(discr)) / 2.0 : trace / 2.0

// PC1 eigenvector ~ (lam1 - s22, s12); normalise
float ex = lam1 - s22
float ey = s12
float eMag = math.sqrt(math.max(ex * ex + ey * ey, 1e-10))
float ux = ex / eMag
float uy = ey / eMag

// Project current z-scored point onto PC1
float proj = zC * ux + zV * uy

bool  pulseUp = proj >=  i_thr
bool  pulseDn = proj <= -i_thr
bool  pulseEdgeUp = pulseUp and not pulseUp[1]
bool  pulseEdgeDn = pulseDn and not pulseDn[1]

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = pulseEdgeUp and posState <= 0 and cooldownOk and confirmed
bool sellSignal = pulseEdgeDn and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// ─── VISUAL: xcross with PC text + direction line ──────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.xcross, location.belowbar, color.new(i_buyColor, 70), size=size.huge,   text="PC")
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.xcross, location.belowbar, color.new(i_buyColor, 40), size=size.large,  text="PC")
plotshape(buySignal,                 "Buy",         shape.xcross, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="PPP-PC", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.xcross, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  text="PC")
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.xcross, location.abovebar, color.new(i_sellColor, 40), size=size.large, text="PC")
plotshape(sellSignal,                "Sell",        shape.xcross, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="PPP-PC", textcolor=c_white)

// PC1 direction line: anchored at EMA20, slope proportional to projection
float pcLine = ta.ema(close, 20) + proj * nz(ta.atr(14), 0) * 1.5
plot(i_showLine ? pcLine : na, "PC1 Pulse", color=color.new(proj > 0 ? i_buyColor : i_sellColor, 30), linewidth=2)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(pulseUp ? color.new(i_buyColor, 94) : pulseDn ? color.new(i_sellColor, 94) : na)

// ─── DASHBOARD (bottom-center, lime/magenta, 8 rows) ──────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 50), border_width=1)
    string regimeTxt = pulseUp ? "PULSE UP" : pulseDn ? "PULSE DOWN" : "NEUTRAL"
    color  regimeCol = pulseUp ? i_buyColor : pulseDn ? i_sellColor : color.silver
    table.cell(dash, 0, 0, "PCA Projection Pulse", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "PC1 Projection",       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(proj, "0.00"),   text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Threshold +/-",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(i_thr, "0.00"),  text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Eigenvalue 1",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(lam1, "#.##"),   text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "PC1 (ux, uy)",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, "(" + str.tostring(ux, "0.00") + ", " + str.tostring(uy, "0.00") + ")", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,              text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"PPP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"proj":' + str.tostring(proj, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"PPP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"proj":' + str.tostring(proj, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "PPP Buy",          "PCA pulse up on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "PPP Sell",         "PCA pulse down on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "PPP Any Signal",   "Any PPP signal on {{ticker}} {{interval}}")
alertcondition(pulseUp and not pulseUp[1],                 "PPP Pulse Up",     "PC1 projection crossed up on {{ticker}} {{interval}}")
alertcondition(pulseDn and not pulseDn[1],                 "PPP Pulse Down",   "PC1 projection crossed down on {{ticker}} {{interval}}")
alertcondition(math.abs(proj) >= 1.5,                      "PPP Strong Pulse", "|PC1| >= 1.5 on {{ticker}} {{interval}}")
alertcondition(lam1 / math.max(trace - lam1, 1e-10) > 5,   "PPP Single Direc", "PC1 dominates 5x on {{ticker}} {{interval}}")
alertcondition(zC * zV > 0,                                "PPP Same Sign",    "Close and volume z-scores aligned on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "PPP Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"PPP\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
