# Roll Spread Estimator [forexobroker]

- url: https://www.tradingview.com/script/V91nOcED-Roll-Spread-Estimator-forexobroker/
- type: indicator
- pine_id: PUB;923461db5f604a6cb941b7532f5d69ea
- version: 1.0

## Description

Roll Spread Estimator implements Roll (1984) — the bid-ask bounce induces negative serial covariance in observed returns. Spread = 2 * sqrt(-cov(r[t], r[t-1])) when cov is negative. Tight spread = liquid market = clean breakouts; wide spread = thin = breakouts to fade. Signals fire on EMA cross during a tight regime. Stacked-flag visual signature distinct from any other hero indicator.

🔶 ALGORITHM

1. r0 = close - close[1]; r1 = close[1] - close[2].
2. cov(r0, r1) = sma(r0 * r1, N) - sma(r0, N) * sma(r1, N).
3. Spread = 2 * sqrt(-cov) when cov < 0; otherwise 0.
4. Quantile q (e.g., 70th percentile) over rolling window.
5. Tight regime when spread <= q.
6. EMA cross within tight fires entries.

🔶 SIGNAL LOGIC

- Buy: tight AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: tight AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Cov Window (default 40)
- Tight Spread Quantile (default 0.7)
- Pullback EMA Length (default 8)
- Cooldown Bars (default 4)
- Visual: dashboard, glow (3 stacked flags), spread channel, buy / sell colors

🔶 ALERTS

RSE Buy, RSE Sell, RSE Any Signal, RSE Tight Start, RSE Tight End, RSE Bounce, RSE EMA Up, RSE EMA Down, RSE Webhook JSON.

🔶 LIMITATIONS

- Roll's estimator assumes the bid-ask bounce is the dominant source of negative covariance; trend-following autocorrelation can produce positive cov, in which case the estimator is undefined and returns 0.
- Forex and equities show clear bid-ask bounces; pure spot-market crypto is less consistent.
- The stacked-flag visual uses 3 overlapping flags for a thicker appearance — visually distinct but slightly heavier draw.
- Quantile-based threshold means tight is *relative* to recent history, not absolute.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Roll (1984) effective spread estimator. The bid-ask bounce induces negative serial
// covariance in observed returns. Roll's estimator: spread = 2 * sqrt(-cov(r[t], r[t-1])) when
// cov is negative; undefined (set to 0) otherwise. Tight spread = liquid market = clean breakouts;
// wide spread = thin market = breakouts to fade. Signals fire on EMA cross during a tight-spread
// regime in the prevailing direction.
indicator("Roll Spread Estimator [forexobroker]", shorttitle="RSE [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Roll Spread"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(40,    "Cov Window",         minval=15, maxval=120, group=g_calc)
float i_tightK   = input.float(0.7, "Tight Spread Quantile", minval=0.20, maxval=0.95, step=0.05, group=g_sig, tooltip="Spread must be below the kth quantile of recent values to be 'tight'.")
int   i_emaLen   = input.int(8,     "Pullback EMA Length", minval=3, maxval=50, group=g_sig)
int   i_cooldown = input.int(4,     "Cooldown Bars",       minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true, "Show Dashboard",                            group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                         group=g_vis)
bool  i_showCh   = input.bool(true, "Show Spread Channel",                       group=g_vis)
color i_buyColor = input.color(#a7ffeb,"Buy Color (Aquamarine)",                 group=g_vis)
color i_sellColor= input.color(#ff8a80,"Sell Color (Light Coral)",               group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#0a1f1a, 22)

// ─── ROLL'S COVARIANCE SPREAD ──────────────────────────────────────────────────
float r0     = nz(close - close[1], 0.0)
float r1     = nz(close[1] - close[2], 0.0)
float covRR  = ta.sma(r0 * r1, i_winLen) - ta.sma(r0, i_winLen) * ta.sma(r1, i_winLen)
float spread = covRR < 0 ? 2.0 * math.sqrt(-covRR) : 0.0

float spreadQ = ta.percentile_linear_interpolation(spread, i_winLen, math.round(i_tightK * 100))
bool  tight   = spread <= spreadQ

float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)
bool  entryUp   = tight and crossUp
bool  entryDown = tight and crossDn

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

// ─── VISUAL: stacked flag pair (different from single flag) ────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.flag, location.belowbar, color.new(i_buyColor, 80), size=size.huge)
plotshape(buySignal,                 "Buy 1",       shape.flag, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy 2",       shape.flag, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="RSE up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.flag, location.abovebar, color.new(i_sellColor, 80), size=size.huge)
plotshape(sellSignal,                "Sell 1",      shape.flag, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell 2",      shape.flag, location.abovebar, color.new(i_sellColor, 0), size=size.normal, text="RSE dn", textcolor=c_white)

// Spread channel: visual representation of spread around the close
float chHi = close + spread / 2
float chLo = close - spread / 2
plot(i_showCh ? chHi : na, "Spread Hi", color=color.new(color.silver, 60), linewidth=1)
plot(i_showCh ? chLo : na, "Spread Lo", color=color.new(color.silver, 60), linewidth=1)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(tight ? color.new(close > ema ? i_buyColor : i_sellColor, 96) : na)

// ─── DASHBOARD (top-right, aquamarine/coral, 7 rows, no border) ───────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 7, bgcolor=c_dashBg, border_color=color.new(color.gray, 90), border_width=1)
    string regimeTxt = tight ? "TIGHT SPREAD" : "WIDE SPREAD"
    color  regimeCol = tight ? i_buyColor : i_sellColor
    table.cell(dash, 0, 0, "Roll Spread Estimator", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Spread",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(spread, "#.######"), text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Quantile Cutoff",       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(spreadQ, "#.######"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Cov(r,r-1)",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(covRR, "#.########"), text_color=covRR < 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Regime",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, regimeTxt,               text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"RSE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"spread":' + str.tostring(spread, "#.######") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"RSE","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"spread":' + str.tostring(spread, "#.######") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "RSE Buy",          "Roll spread tight bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "RSE Sell",         "Roll spread tight bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "RSE Any Signal",   "Any RSE signal on {{ticker}} {{interval}}")
alertcondition(tight and not tight[1],                     "RSE Tight Start",  "Roll spread tightened on {{ticker}} {{interval}}")
alertcondition(not tight and tight[1],                     "RSE Tight End",    "Roll spread widened on {{ticker}} {{interval}}")
alertcondition(covRR < 0,                                  "RSE Bounce",       "Negative serial covariance on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "RSE EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "RSE EMA Down",     "Close crossed EMA down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "RSE Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"RSE\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
