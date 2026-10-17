# Bayesian Trend Posterior [forexobroker]

- url: https://www.tradingview.com/script/mLsXgHQy-Bayesian-Trend-Posterior-forexobroker/
- type: indicator
- pine_id: PUB;37cfee0885184fdbb6363220cb6ef7ec
- version: 1.0

## Description

Bayesian Trend Posterior treats each bar as a Bernoulli observation (up vs not-up) and runs a Beta-Bernoulli sequential update over a sliding window. The posterior probability P(next bar up) = (alpha + u) / (alpha + beta + N), where u is the count of up-bars in the window. Schmitt hysteresis on the posterior locks bull or bear regimes, preventing chatter near 0.5.

🔶 ALGORITHM

1. Count up-bars u in the last N closes (close > close[1]).
2. Posterior mean = (alpha + u) / (alpha + beta + N) using Beta(alpha, beta) prior.
3. Hysteresis: regime locks to +1 when posterior >= upper threshold, locks to -1 when posterior <= lower threshold, holds otherwise.
4. Within a locked regime, an EMA cross provides the entry trigger so the indicator can fire multiple times during sustained trends.

🔶 SIGNAL LOGIC

- Buy: bull regime locked AND close crosses pullback EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: bear regime locked AND close crosses pullback EMA down.
- Position-lock state machine.

🔶 INPUTS

- Posterior Window N (default 30)
- Prior alpha (default 2.0)
- Prior beta (default 2.0)
- Upper Hysteresis (default 0.55)
- Lower Hysteresis (default 0.45)
- Pullback EMA Length (default 8)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

BTP Buy, BTP Sell, BTP Any Signal, BTP Bull Lock, BTP Bear Lock, BTP High Posterior, BTP Low Posterior, BTP Cross 0.5, BTP Webhook JSON.

🔶 LIMITATIONS

- Bernoulli simplification ignores bar size; a tiny up-bar contributes the same as a strong one. Pair with an ATR-aware filter for size-weighted posteriors.
- Window N is the dominant tuning knob: smaller N reacts faster but flips more; larger N is steadier.
- Prior alpha = beta = 2 is uninformative; users with strong directional bias can adjust.
- Hysteresis prevents chatter but slightly delays regime detection vs threshold-only logic.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Beta-Bernoulli Bayesian update on the up-bar probability over a sliding window. Each
// bar is observed as up (close > close[1]) or down. With a Beta(alpha, beta) prior, the posterior
// after seeing u up-bars in window N is Beta(alpha + u, beta + N - u). Posterior mean is
// (alpha + u) / (alpha + beta + N) — this is P(next bar is up). Schmitt hysteresis on the
// posterior locks bull / bear regimes; entry triggers fire on micro-pullback recoveries
// (close cross EMA8) within the locked regime. Distinct from log-likelihood-ratio fusion: this is
// the single sufficient statistic of a binomial process, not an evidence ensemble.
indicator("Bayesian Trend Posterior [forexobroker]", shorttitle="BTP [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc   = "Bayesian"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen    = input.int(30,    "Posterior Window N",         minval=10, maxval=100, group=g_calc)
float i_priorA    = input.float(2.0, "Prior alpha (Beta)",         minval=0.5, maxval=20.0, step=0.5, group=g_calc, tooltip="Beta prior alpha. Higher = more confident in up-bias before seeing data.")
float i_priorB    = input.float(2.0, "Prior beta  (Beta)",         minval=0.5, maxval=20.0, step=0.5, group=g_calc, tooltip="Beta prior beta. Higher = more confident in down-bias before seeing data.")
float i_upperThr  = input.float(0.55, "Upper Hysteresis (lock bull)", minval=0.51, maxval=0.95, step=0.01, group=g_signal)
float i_lowerThr  = input.float(0.45, "Lower Hysteresis (lock bear)", minval=0.05, maxval=0.49, step=0.01, group=g_signal)
int   i_emaLen    = input.int(8,    "Pullback EMA Length",         minval=3,  maxval=50,                  group=g_signal)
int   i_cooldown  = input.int(4,    "Cooldown Bars",               minval=1,  maxval=20,                  group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard",                                                    group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow",                                                 group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA",                                                 group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",                                                     group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color",                                                    group=g_visual)

color c_white = #ffffff

// ─── BAYESIAN POSTERIOR ────────────────────────────────────────────────────────
int upCount = 0
for k = 0 to i_winLen - 1
    if nz(close[k]) > nz(close[k + 1])
        upCount += 1

float posterior = (i_priorA + upCount) / (i_priorA + i_priorB + i_winLen)

// ─── REGIME (HYSTERESIS) + ENTRY ───────────────────────────────────────────────
var int regime = 0
if posterior >= i_upperThr
    regime := 1
else if posterior <= i_lowerThr
    regime := -1

float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)

bool entryUp   = regime ==  1 and crossUp
bool entryDown = regime == -1 and crossDn

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

// ─── VISUAL ───────────────────────────────────────────────────────────────────
color emaCol = regime ==  1 ? i_buyColor : regime == -1 ? i_sellColor : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "Pullback EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.circle, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BTP up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.circle, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BTP dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(regime == 1 ? color.new(i_buyColor, 94) : regime == -1 ? color.new(i_sellColor, 94) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = regime ==  1 ? "BULL LOCKED" : regime == -1 ? "BEAR LOCKED" : "NEUTRAL"
    color  regimeCol = regime ==  1 ? i_buyColor : regime == -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Bayesian Trend Posterior", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                    text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "P(up)",                    text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(posterior, "0.000"),    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Up bars / N",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(upCount) + " / " + str.tostring(i_winLen), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Upper Lock",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_upperThr, "0.00"),    text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Lower Lock",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_lowerThr, "0.00"),    text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                  text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"BTP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"posterior":' + str.tostring(posterior, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"BTP","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"posterior":' + str.tostring(posterior, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "BTP Buy",            "Bayesian bull entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "BTP Sell",           "Bayesian bear entry on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "BTP Any Signal",     "Any BTP signal on {{ticker}} {{interval}}")
alertcondition(regime ==  1 and regime[1] !=  1,           "BTP Bull Lock",      "Bayesian bull regime locked on {{ticker}} {{interval}}")
alertcondition(regime == -1 and regime[1] != -1,           "BTP Bear Lock",      "Bayesian bear regime locked on {{ticker}} {{interval}}")
alertcondition(posterior >= 0.7,                           "BTP High Posterior", "P(up) >= 0.70 on {{ticker}} {{interval}}")
alertcondition(posterior <= 0.3,                           "BTP Low Posterior",  "P(up) <= 0.30 on {{ticker}} {{interval}}")
bool postCross = ta.crossover(posterior, 0.5)
alertcondition(postCross,                                  "BTP Cross 0.5",      "Posterior crossed 0.50 up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "BTP Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"BTP\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
