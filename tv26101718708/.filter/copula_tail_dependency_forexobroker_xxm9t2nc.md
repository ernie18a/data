# Copula Tail Dependency [forexobroker]

- url: https://www.tradingview.com/script/xxm9T2Nc-Copula-Tail-Dependency-forexobroker/
- type: indicator
- pine_id: PUB;bd74ce7dc58e43b3a8af93da4c390820
- version: 1.0

## Description

Copula Tail Dependency [forexobroker] estimates the empirical lower- and upper-tail dependence between price returns and volume changes using a rank-based copula. Rather than measuring linear correlation (which collapses to a single number and ignores tail behavior), the indicator measures whether extreme co-occurrences are abnormally frequent. The unique angle is that crossovers of the upper- or lower-tail measure above a threshold mark genuine joint-extreme regimes where return-volume co-movement is strong, while ordinary days leave both measures low.

🔶 ALGORITHM

1. Each bar's one-step log return and volume change are computed.
2. Both series are rank-transformed within the last N (default 50) bars; the rank divided by N produces a uniform marginal U for returns and V for volume changes.
3. The empirical lower-tail dependence is lambda_L = count(U <= u AND V <= u) / count(V <= u) for u equal to the tail fraction (default 0.1).
4. The empirical upper-tail dependence is lambda_U = count(U >= 1-u AND V >= 1-u) / count(V >= 1-u).
5. Both quantities live on [0, 1]; values near 0 indicate independence at the tails, values near 1 indicate strong joint-extreme behavior.
6. A signal threshold (default 0.5) defines the line above which the tail measure is treated as a co-movement regime.
7. Bullish signal: lambda_U crosses above the threshold. Bearish signal: lambda_L crosses above the threshold.

🔶 SIGNAL LOGIC

- Buy: lambda_U crosses above the threshold AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: lambda_L crosses above the threshold AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

The cross-up trigger filters out sustained-tail regimes that have already been priced in; entries fire only when joint-tail strength is freshly established.

🔶 INPUTS

- Calculation group: Window N (default 50), Tail Fraction u (default 0.1), Signal Threshold (default 0.5).
- Signal Logic group: cooldown bars (default 15).
- Filters group: optional session restriction (default 0000-2400).
- Visual group: dashboard toggle, 3-layer glow toggle, upper-tail and lower-tail colors, dashboard background.

🔶 ALERTS

CTD Buy, CTD Sell, CTD Any Signal, CTD Upper Tail Up, CTD Lower Tail Up, CTD Upper Tail Dn, CTD Lower Tail Dn, CTD Symmetric Tails, CTD Webhook JSON.

🔶 LIMITATIONS

- Volume is required, so on symbols without exchange volume the lower/upper tail estimates degrade to noise.
- The rank transform uses a fixed look-back, so the marginal CDF is local rather than global; very long-trend regimes can suppress tail measures.
- With N = 50 and u = 0.1, the upper and lower tails each contain only 5 reference points; small sample noise is expected.
- The indicator measures co-movement direction, not magnitude; it does not size the move.
- A high lambda_U can persist during slow grinding uptrends and then mean-revert, so re-entries from cool to hot are the cleanest signals.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Copula Tail Dependency. The last N bars of returns and volume-changes are rank-
// transformed into uniform marginals U and V (rank divided by N). Lower-tail dependence
// lambda_L is the empirical probability that U is in its lower u-tail given V is in its
// lower u-tail; upper-tail dependence lambda_U is the symmetric upper-tail measure. High
// lambda_U means extreme positive return moves co-occur with extreme positive volume changes
// (bullish co-movement); high lambda_L means extreme negative moves co-occur with extreme
// negative volume changes (bearish co-movement). Non-repainting: ranks computed over a fixed
// rolling window, signals on bar close.
indicator("Copula Tail Dependency [forexobroker]", shorttitle="CTD [fob]", overlay=false, max_bars_back=500)

string g_calc = "Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_win     = input.int(50,   "Window N",          minval=20, maxval=200, group=g_calc, tooltip="Bars used to rank-transform the marginal distributions.")
float i_tail    = input.float(0.1,"Tail Fraction u",   minval=0.05,maxval=0.4,step=0.01, group=g_calc, tooltip="Fraction defining the upper and lower tails (e.g. 0.1 = 10 percent).")
float i_thresh  = input.float(0.3,"Signal Threshold",  minval=0.1,maxval=1.0,step=0.05, group=g_calc, tooltip="Tail dependence above this is treated as co-movement.")
int   i_smooth  = input.int(5,    "Curve Smoothing",   minval=1,  maxval=20, group=g_calc, tooltip="EMA smoothing on the tail-dependence curves. The raw empirical ratio is a coarse staircase (few tail observations); smoothing renders clean lines.")
bool  i_useSess = input.bool(false,"Restrict to Session",                                group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                            group=g_filt)
int   i_cooldown= input.int(5,    "Cooldown Bars",     minval=1,  maxval=60, group=g_sig)
bool  i_showTable=input.bool(true,"Show Dashboard",                            group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                         group=g_vis)
color i_buyColor= input.color(#4ade80,"Buy / Upper Tail",                      group=g_vis)
color i_sellColor=input.color(#f472b6,"Sell / Lower Tail",                     group=g_vis)
color i_dashBg  = input.color(color.new(#0c1018, 16),"Dashboard BG",           group=g_vis)

color c_white = #ffffff

float ret  = ta.change(math.log(close))
float dvol = ta.change(volume)

// Helper: rank of latest value within last N (count of values <= current, divided by N)
f_rank(float src, int n) =>
    float cur = src
    int cnt = 0
    if not na(cur)
        for k = 0 to n - 1
            float v = src[k]
            if not na(v) and v <= cur
                cnt += 1
    cnt / float(n)

// Call f_rank at top-level every bar so its internal state is consistent.
// u and v are the current-bar marginal ranks; u[k] and v[k] supply the historical
// rank values needed inside the loop below (Pine retains past series values
// automatically, so no extra function calls are required there).
float u = f_rank(ret,  i_win)
float v = f_rank(dvol, i_win)

// Empirical tail dependence over the last N pairs
float tailLo = i_tail
float tailHi = 1.0 - i_tail

float cntLow = 0.0
float cntLowV = 0.0
float cntHigh = 0.0
float cntHighV = 0.0

if bar_index >= i_win
    for k = 0 to i_win - 1
        float uk = u[k]
        float vk = v[k]
        if not na(uk) and not na(vk)
            if vk <= tailLo
                cntLowV += 1.0
                if uk <= tailLo
                    cntLow += 1.0
            if vk >= tailHi
                cntHighV += 1.0
                if uk >= tailHi
                    cntHigh += 1.0

float lambdaLraw = cntLowV  > 0 ? cntLow  / cntLowV  : 0.0
float lambdaUraw = cntHighV > 0 ? cntHigh / cntHighV : 0.0
// The raw empirical ratios are a coarse staircase (only a handful of tail observations),
// so smooth them into clean curves for rendering and signal stability.
float lambdaL = ta.ema(lambdaLraw, i_smooth)
float lambdaU = ta.ema(lambdaUraw, i_smooth)

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool upCross  = ta.crossover(lambdaU, i_thresh)
bool dnCross  = ta.crossover(lambdaL, i_thresh)

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool buySignal  = upCross and inSession and posState <= 0 and cooldownOk and confirmed
bool sellSignal = dnCross and inSession and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// Smoothed tail-dependence curves with 3-layer neon glow
plot(lambdaU, "Upper Glow 2",   color=color.new(i_buyColor, 82), linewidth=6)
plot(lambdaU, "Upper Glow 1",   color=color.new(i_buyColor, 60), linewidth=3)
plot(lambdaU, "Upper Tail Dep", color=i_buyColor,  linewidth=2)
plot(lambdaL, "Lower Glow 2",   color=color.new(i_sellColor, 82), linewidth=6)
plot(lambdaL, "Lower Glow 1",   color=color.new(i_sellColor, 60), linewidth=3)
plot(lambdaL, "Lower Tail Dep", color=i_sellColor, linewidth=2)
plot(i_thresh, "Threshold",     color=color.new(#ffaa00, 20), linewidth=1)
hline(0,       "Zero",          color=color.new(color.gray, 75))
hline(1,       "One",           color=color.new(color.gray, 75))

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="CTD", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="CTD", textcolor=c_white)

// PRICE-PANE MIRROR (Pine v6 force_overlay): same entry signals projected onto the candlesticks.
plotshape(i_showGlow and buySignal,  "Buy Glow 1 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge,   force_overlay=true)
plotshape(i_showGlow and buySignal,  "Buy Glow 2 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large,  force_overlay=true)
plotshape(buySignal,                 "Buy (price)",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CTD", textcolor=c_white, force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 1 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 2 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large, force_overlay=true)
plotshape(sellSignal,                "Sell (price)",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CTD", textcolor=c_white, force_overlay=true)

bgcolor(lambdaU > i_thresh and lambdaU > lambdaL ? color.new(i_buyColor, 92) : lambdaL > i_thresh and lambdaL > lambdaU ? color.new(i_sellColor, 92) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 55), border_width=1)
    string regime = lambdaU > i_thresh and lambdaU > lambdaL ? "BULL CO-MOVE" : lambdaL > i_thresh and lambdaL > lambdaU ? "BEAR CO-MOVE" : "INDEPENDENT"
    color  rc = lambdaU > i_thresh and lambdaU > lambdaL ? i_buyColor : lambdaL > i_thresh and lambdaL > lambdaU ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Copula Tail Dep",      text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, regime,                 text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "Upper Tail",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(lambdaU, "#.###"), text_color=i_buyColor, text_size=size.small)
    table.cell(dash, 0, 3, "Lower Tail",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(lambdaL, "#.###"), text_color=i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Threshold",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_thresh, "#.##"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "Window N",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(i_win),    text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 6, "Position",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CTD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"lambdaU":' + str.tostring(lambdaU, "#.###") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CTD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"lambdaL":' + str.tostring(lambdaL, "#.###") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                "CTD Buy",            "Upper-tail co-movement long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                               "CTD Sell",           "Lower-tail co-movement short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                  "CTD Any Signal",     "Any CTD signal on {{ticker}} {{interval}}")
alertcondition(ta.crossover(lambdaU, i_thresh),          "CTD Upper Tail Up",  "Upper tail crossed threshold on {{ticker}} {{interval}}")
alertcondition(ta.crossover(lambdaL, i_thresh),          "CTD Lower Tail Up",  "Lower tail crossed threshold on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(lambdaU, i_thresh),         "CTD Upper Tail Dn",  "Upper tail fell below threshold on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(lambdaL, i_thresh),         "CTD Lower Tail Dn",  "Lower tail fell below threshold on {{ticker}} {{interval}}")
alertcondition(lambdaU > i_thresh and lambdaL > i_thresh,"CTD Symmetric Tails","Both tails elevated on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                  "CTD Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"CTD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
