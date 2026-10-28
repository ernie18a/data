# Ornstein Uhlenbeck Reverter [forexobroker]

- url: https://www.tradingview.com/script/0soh5Bfu-Ornstein-Uhlenbeck-Reverter-forexobroker/
- type: indicator
- pine_id: PUB;56390ba7f69f413c9e5bb7635ba12d75
- version: 1.0

## Description

Ornstein-Uhlenbeck Reverter fits the continuous-time mean-reverting OU process dX = theta * (mu - X) * dt + sigma * dW to recent closes. Parameters theta (mean-reversion speed) and mu (long-run mean) are estimated by OLS. Half-life of reversion = ln(2) / theta. Signals fade overshoots beyond k * sigma — a statistically grounded mean-reversion entry.

🔶 ALGORITHM

1. Linear regression: r[t] = a + b * close[t-1] + e, where r = close[t-1] - close[t] (the negative one-step return).
2. theta_hat = -b (assuming dt = 1); mu_hat = a / theta_hat.
3. Half-life = ln(2) / theta. Sigma = stdev of OLS residuals.
4. Overshoot = (close - mu) / sigma.
5. Long fade: overshoot was below -k AND now turning back up. Short fade: above +k AND turning down.

🔶 SIGNAL LOGIC

- Buy: long fade trigger AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: short fade trigger.
- Position-lock state machine.

🔶 INPUTS

- Fit Window (default 60)
- Overshoot k x sigma (default 1.5)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, equilibrium hline, buy / sell colors

🔶 ALERTS

OUR Buy, OUR Sell, OUR Any Signal, OUR Underext, OUR Overext, OUR Extreme, OUR Fast Revert, OUR Drift Mode, OUR Webhook JSON.

🔶 LIMITATIONS

- OU assumes constant mu over the fit window; trending markets violate this and produce theta near zero (drift mode).
- OLS is sensitive to outliers; robust alternatives (MAD-based) may help on spike-heavy assets.
- The fit re-runs every bar; transitional periods produce unstable mu estimates.
- Mean-reversion strategies underperform during persistent trends; pair with a regime gate (e.g., Hurst < 0.5).

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Ornstein-Uhlenbeck mean-reversion fit. The continuous-time SDE is dX = theta * (mu - X) * dt + sigma * dW.
// Parameters are estimated by OLS on r[t] = -theta_hat * (X[t-1] - mu_hat) + noise. Half-life of
// reversion = ln(2) / theta. Signals fire when price overshoots equilibrium beyond k * sigma — a
// statistical fade entry. Distinct from any moving-average reversion: theta and mu are explicitly
// fit, not assumed.
indicator("Ornstein Uhlenbeck Reverter [forexobroker]", shorttitle="OUR [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "OU Process"
string g_sig  = "Signal"
string g_vis  = "Visual"

int   i_winLen   = input.int(60,   "Fit Window",          minval=20, maxval=200, group=g_calc, tooltip="Bars used to estimate theta and mu via OLS.")
float i_kSigma   = input.float(1.5,"Overshoot k x sigma", minval=0.5, maxval=4.0, step=0.1, group=g_sig, tooltip="Fade entry when |close - mu| > k * sigma.")
int   i_cooldown = input.int(4,    "Cooldown Bars",       minval=1, maxval=20, group=g_sig)
bool  i_showTable= input.bool(true,"Show Dashboard",                          group=g_vis)
bool  i_showGlow = input.bool(true,"Show 3-Layer Glow",                       group=g_vis)
bool  i_showMu   = input.bool(true,"Show Equilibrium",                        group=g_vis)
color i_buyColor = input.color(#39ff14,"Buy Color (Lime)",                    group=g_vis)
color i_sellColor= input.color(#ff2d78,"Sell Color (Magenta)",                group=g_vis)

color c_white  = #ffffff
color c_dashBg = color.new(#001400, 25)

// ─── OU OLS FIT ────────────────────────────────────────────────────────────────
// r[t] = a + b * X[t-1] + e, where a = theta * mu * dt, b = -theta * dt
// Estimate via simple linear regression
int N = i_winLen
float sumX  = 0.0
float sumY  = 0.0
float sumXY = 0.0
float sumXX = 0.0
for k = 1 to N
    float x = nz(close[k])
    float y = nz(close[k - 1]) - nz(close[k])
    sumX  += x
    sumY  += y
    sumXY += x * y
    sumXX += x * x

float meanX = sumX / N
float meanY = sumY / N
float covXY = sumXY / N - meanX * meanY
float varX  = sumXX / N - meanX * meanX
float bHat  = varX > 0 ? covXY / varX : 0.0
float aHat  = meanY - bHat * meanX

// theta_hat = -b (assuming dt = 1)
float theta = math.max(-bHat, 0.0)
float mu    = theta > 0 ? aHat / theta : meanX
float halfLife = theta > 0 ? math.log(2.0) / theta : 1e6

// Sigma of residuals
float resSumSq = 0.0
for k = 1 to N
    float x = nz(close[k])
    float y = nz(close[k - 1]) - nz(close[k])
    float pred = aHat + bHat * x
    float res  = y - pred
    resSumSq += res * res
float sigma = math.sqrt(resSumSq / N)

// ─── ENTRY: fade overshoots ───────────────────────────────────────────────────
float overshoot = (close - mu) / math.max(sigma, 1e-10)
bool  shortFade = overshoot >  i_kSigma  // price too high, fade short
bool  longFade  = overshoot < -i_kSigma  // price too low, fade long

// Use crossover of overshoot back through threshold for entry
bool  entryUp   = longFade  and overshoot > overshoot[1]  // price rising back from underextension
bool  entryDown = shortFade and overshoot < overshoot[1]  // price falling back from overextension

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
color muCol = math.abs(overshoot) > i_kSigma ? color.yellow : color.silver
plot(i_showMu ? mu : na, "Equilibrium", color=color.new(muCol, 30), linewidth=2, style=plot.style_circles)
plot(i_showMu ? mu + i_kSigma * sigma : na, "Upper Band", color=color.new(i_sellColor, 60), linewidth=1)
plot(i_showMu ? mu - i_kSigma * sigma : na, "Lower Band", color=color.new(i_buyColor, 60),  linewidth=1)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.cross, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.cross, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.cross, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="OUR fade L", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.cross, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.cross, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.cross, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="OUR fade S", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(math.abs(overshoot) > i_kSigma ? color.new(overshoot > 0 ? i_sellColor : i_buyColor, 94) : na)

// ─── DASHBOARD (bottom-right, lime/magenta palette, 8 rows, OU-specific cells) ─
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=c_dashBg, border_color=color.new(i_buyColor, 70), border_width=1)
    string regimeTxt = math.abs(overshoot) > i_kSigma ? (overshoot > 0 ? "OVEREXTENDED UP" : "OVEREXTENDED DOWN") : "NEAR EQUILIBRIUM"
    color  regimeCol = math.abs(overshoot) > i_kSigma ? (overshoot > 0 ? i_sellColor : i_buyColor) : color.silver
    table.cell(dash, 0, 0, "Ornstein-Uhlenbeck", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",              text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Equilibrium mu",     text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(mu, "#.##"),       text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "Theta",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(theta, "0.0000"),  text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "Half-Life",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, halfLife < 9999 ? str.tostring(halfLife, "0.0") + " bars" : "inf",  text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 4, "Overshoot (k)",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(overshoot, "0.00"), text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,            text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"OUR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"overshoot":' + str.tostring(overshoot, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"OUR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"overshoot":' + str.tostring(overshoot, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "OUR Buy",          "OU long fade on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "OUR Sell",         "OU short fade on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "OUR Any Signal",   "Any OUR signal on {{ticker}} {{interval}}")
alertcondition(longFade  and not longFade[1],              "OUR Underext",     "Price entered underextension on {{ticker}} {{interval}}")
alertcondition(shortFade and not shortFade[1],             "OUR Overext",      "Price entered overextension on {{ticker}} {{interval}}")
alertcondition(math.abs(overshoot) > 2.5,                  "OUR Extreme",      "|Overshoot| > 2.5 on {{ticker}} {{interval}}")
alertcondition(theta > 0.05,                               "OUR Fast Revert",  "Half-life under 14 bars on {{ticker}} {{interval}}")
alertcondition(theta < 0.005,                              "OUR Drift Mode",   "Theta near zero on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "OUR Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"OUR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
