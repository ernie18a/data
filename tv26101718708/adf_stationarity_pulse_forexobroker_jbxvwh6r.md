# ADF Stationarity Pulse [forexobroker]

- url: https://www.tradingview.com/script/jBxVwH6R-ADF-Stationarity-Pulse-forexobroker/
- type: indicator
- pine_id: PUB;041c2d625dbd4070995b502258430c63
- version: 1.0

## Description

ADF Stationarity Pulse [forexobroker] runs the Augmented Dickey-Fuller test live on price and gates mean-reversion entries by whether the test currently rejects the unit-root null. The ADF test is the standard econometric tool for asking "is this series mean-reverting or does it have a random-walk component?". When ADF says mean-reverting AND the price z-score says price is stretched away from its rolling mean, the script trades the reversion. Built for crypto pairs, where statistical regimes flip between trending and choppy mean-reversion frequently.

🔶 ALGORITHM

1. Over the ADF window (default N=40 closes), the regression Dp_t = a + g * p_{t-1} + b * Dp_{t-1} + e is fit via closed-form OLS using cross-sum accumulation (single loop, no nested O(N^2)).
2. The variables are centered to absorb the intercept, then a 2x2 system solves for gamma (the unit-root coefficient) and beta (the lag-differenced coefficient).
3. Residual sum of squares is used to compute sigma^2 and the standard error of gamma.
4. ADF statistic = gamma / SE(gamma). Compared to the 5% critical value of -2.86 (approximate, for AR(1)-with-drift).
5. Z-score = (close - SMA(N)) / stdev(N) measures how far price is from its mean.
6. Buy fires when ADF rejects the unit root (mean-reverting) AND z-score is stretched below -threshold. Sell mirrors above +threshold.

🔶 SIGNAL LOGIC

- Buy: ADF stat < critical value AND z-score < -threshold AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: ADF stat < critical value AND z-score > +threshold AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

Both conditions are required — being stretched in a trending regime is not enough, the test has to first confirm mean-reversion.

🔶 INPUTS

- Calculation group: ADF window N (default 40), 5% critical value (default -2.86), warning line (default -1.5).
- Signal Logic group: z-score threshold (default 1.0), cooldown bars (default 15).
- Filters group: session restriction (default 0000-2400).
- Visual group: z-score plot, dashboard, 3-layer glow, colors.

🔶 ALERTS

ADF Buy, ADF Sell, ADF Any Signal, ADF Regime On, ADF Regime Off, ADF Warning Cross, ADF Z Stretched Down, ADF Z Stretched Up, ADF Z Mean Reclaim, ADF Webhook JSON.

🔶 LIMITATIONS

- The 5% critical value is approximate; published tables vary slightly with sample size and specification. -2.86 is the conventional reference for AR(1)-with-drift at N around 50.
- ADF assumes a specific lag structure (one differenced lag); on higher-order autocorrelated series the test may misclassify regimes.
- The regression uses a fixed window of N closes; very early chart history has insufficient data and the test returns near zero.
- Mean-reversion entries can fight strong trends if the ADF window happens to span a flat patch inside the larger trend — use higher timeframes or a longer N to suppress this.
- Crypto pairs with frequent gap behavior (weekend lulls, exchange halts) violate the i.i.d. residual assumption ADF rests on.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: ADF Stationarity Pulse. The Augmented Dickey-Fuller (ADF) test asks whether a series
// is mean-reverting (stationary) or trending (unit root). We fit a closed-form AR(1)-with-drift
// regression Dp_t = a + g * p_{t-1} + b * Dp_{t-1} + e on the last N closes, compute the t-stat of
// g (the ADF statistic), and compare to the 5% critical value (~ -2.86). When ADF says "mean-
// reverting" AND the z-score of price says "stretched", we trade the reversion. Non-repainting:
// regression uses only confirmed bars, signal on bar close.
indicator("ADF Stationarity Pulse [forexobroker]", shorttitle="ADF [fob]", overlay=false, max_bars_back=500)

string g_calc = "Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_N        = input.int(40,    "ADF Window N",            minval=20,  maxval=200, group=g_calc, tooltip="Number of closes used for the AR(1) regression.")
float i_critVal  = input.float(-2.86,"ADF Critical Value (5%)",                       group=g_calc, tooltip="Approximate 5%% critical value for AR(1)-with-drift.")
float i_warnVal  = input.float(-1.5, "ADF Warning Line",                              group=g_calc)
float i_zThresh  = input.float(1.0, "Z-Score Threshold",       minval=0.3, maxval=3.0, step=0.1, group=g_sig, tooltip="Price must be this many SDs away from its mean.")
int   i_cooldown = input.int(15,    "Cooldown Bars",           minval=1,   maxval=60, group=g_sig)
bool  i_useSess  = input.bool(false,"Restrict to Session",                            group=g_filt)
string i_sess    = input.session("0000-2400","Session Window",                       group=g_filt)
bool  i_showZ    = input.bool(true, "Show Z-Score Plot",                              group=g_vis)
bool  i_showTable= input.bool(true, "Show Dashboard",                                 group=g_vis)
bool  i_showGlow = input.bool(true, "Show 3-Layer Glow",                              group=g_vis)
color i_buyColor = input.color(#39ff14, "Buy Color",                                  group=g_vis)
color i_sellColor= input.color(#ff2d78, "Sell Color",                                 group=g_vis)
color i_adfColor = input.color(#00d4ff, "ADF Color",                                  group=g_vis)
color i_dashBg   = input.color(color.new(#0a1118, 16), "Dashboard BG",                group=g_vis)

color c_white = #ffffff
color c_purple= #a855f7
color c_gold  = #ffaa00

// Build the regression: Dp_t = a + g * p_{t-1} + b * Dp_{t-1} + e
// We solve a 3-variable OLS via normal equations. To stay fast we accumulate cross-sums in a
// single loop over the last N bars.
f_adf(int N) =>
    float sumY = 0.0, sumX1 = 0.0, sumX2 = 0.0
    float sumYX1 = 0.0, sumYX2 = 0.0, sumX1X1 = 0.0, sumX2X2 = 0.0, sumX1X2 = 0.0
    float sumYY = 0.0
    int n = 0
    if bar_index >= N + 2
        for i = 0 to N - 1
            float p_t   = close[i]
            float p_tm1 = close[i + 1]
            float p_tm2 = close[i + 2]
            float y     = p_t - p_tm1            // Dp_t
            float x1    = p_tm1                  // p_{t-1}
            float x2    = p_tm1 - p_tm2          // Dp_{t-1}
            sumY    += y
            sumX1   += x1
            sumX2   += x2
            sumYX1  += y * x1
            sumYX2  += y * x2
            sumX1X1 += x1 * x1
            sumX2X2 += x2 * x2
            sumX1X2 += x1 * x2
            sumYY   += y * y
            n += 1
    float nF = n > 0 ? n : 1.0
    // Center each variable (subtract its mean) so the intercept drops out — equivalent to running
    // a regression of (y - mean_y) on (x1 - mean_x1) and (x2 - mean_x2). The slope on x1 is gamma.
    float my = sumY / nF
    float m1 = sumX1 / nF
    float m2 = sumX2 / nF
    float Sx1x1 = sumX1X1 - nF * m1 * m1
    float Sx2x2 = sumX2X2 - nF * m2 * m2
    float Sx1x2 = sumX1X2 - nF * m1 * m2
    float Syx1  = sumYX1  - nF * my * m1
    float Syx2  = sumYX2  - nF * my * m2
    float Syy   = sumYY   - nF * my * my
    float det = Sx1x1 * Sx2x2 - Sx1x2 * Sx1x2
    float gamma = 0.0, beta = 0.0
    if det != 0
        gamma := (Syx1 * Sx2x2 - Syx2 * Sx1x2) / det
        beta  := (Syx2 * Sx1x1 - Syx1 * Sx1x2) / det
    // Residual sum of squares
    float SSE = Syy - gamma * Syx1 - beta * Syx2
    if SSE < 0
        SSE := 0.0
    // Degrees of freedom = n - k where k = 3 (intercept + gamma + beta)
    int dof = n - 3 > 1 ? n - 3 : 1
    float sigma2 = SSE / dof
    // Variance of gamma is sigma2 * (X'X)^-1 element for gamma = sigma2 * Sx2x2 / det
    float varGamma = det > 0 ? sigma2 * Sx2x2 / det : 0.0
    float seGamma = math.sqrt(math.max(varGamma, 0.0))
    float tStat = seGamma > 0 ? gamma / seGamma : 0.0
    [tStat, gamma, seGamma]

[adfStat, gammaCoef, seGamma] = f_adf(i_N)

float pMean = ta.sma(close, i_N)
float pSd   = ta.stdev(close, i_N)
float zScore = pSd > 0 ? (close - pMean) / pSd : 0.0

bool isStationary = adfStat < i_critVal
bool stretchedDown = zScore < -i_zThresh
bool stretchedUp   = zScore >  i_zThresh
bool inSession     = not i_useSess or not na(time(timeframe.period, i_sess))

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = isStationary and stretchedDown and inSession and posState <= 0 and cooldownOk and confirmed
bool sellSignal = isStationary and stretchedUp   and inSession and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

// Plots
plot(adfStat,     "ADF Stat",        color=i_adfColor, linewidth=2)
plot(i_critVal,   "5% Critical",     color=color.new(c_gold, 20), linewidth=1)
plot(i_warnVal,   "Warning Line",    color=color.new(color.gray, 50), linewidth=1)
plot(0,           "Zero",            color=color.new(color.gray, 70), linewidth=1)
plot(i_showZ ? zScore : na, "Z-Score (price)", color=color.new(c_purple, 20), linewidth=1)

// Background: green when stationary regime, red when not
bgcolor(isStationary ? color.new(i_buyColor, 92) : na)

// 3-layer glow on signals
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                  "Buy",         shape.circle, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="ADF", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                 "Sell",        shape.circle, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="ADF", textcolor=c_white)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_adfColor, 55), border_width=1)
    string regime = isStationary ? "MEAN-REVERTING" : adfStat < i_warnVal ? "WEAK MR" : "TRENDING / UNIT ROOT"
    color  rc = isStationary ? i_buyColor : adfStat < i_warnVal ? c_gold : i_sellColor
    table.cell(dash, 0, 0, "ADF Stationarity",              text_color=i_adfColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                          text_color=color.new(i_adfColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, regime,                           text_color=rc, text_size=size.small)
    table.cell(dash, 0, 2, "ADF Statistic",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(adfStat, "#.##"),    text_color=isStationary ? i_buyColor : color.silver, text_size=size.small)
    table.cell(dash, 0, 3, "5% Critical",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_critVal, "#.##"),  text_color=c_gold, text_size=size.small)
    table.cell(dash, 0, 4, "Gamma (slope)",                  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(gammaCoef, "#.######"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 5, "SE(Gamma)",                      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(seGamma, "#.######"), text_color=c_purple, text_size=size.small)
    table.cell(dash, 0, 6, "Z-Score (price)",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(zScore, "#.##"),     text_color=zScore > 0 ? i_sellColor : i_buyColor, text_size=size.small)
    table.cell(dash, 0, 7, "Position",                       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState == 1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState == 1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"ADF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"adf":' + str.tostring(adfStat) + ',"z":' + str.tostring(zScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ADF","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"adf":' + str.tostring(adfStat) + ',"z":' + str.tostring(zScore) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                              "ADF Buy",              "ADF mean-reversion long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                             "ADF Sell",             "ADF mean-reversion short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                "ADF Any Signal",       "Any ADF signal on {{ticker}} {{interval}}")
alertcondition(isStationary and not isStationary[1],   "ADF Regime On",        "ADF entered mean-reverting regime on {{ticker}} {{interval}}")
alertcondition(not isStationary and isStationary[1],   "ADF Regime Off",       "ADF left mean-reverting regime on {{ticker}} {{interval}}")
alertcondition(ta.crossover(adfStat, i_warnVal),       "ADF Warning Cross",    "ADF crossed warning line on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(zScore, -1.5),            "ADF Z Stretched Down", "Z-score stretched down on {{ticker}} {{interval}}")
alertcondition(ta.crossover(zScore, 1.5),              "ADF Z Stretched Up",   "Z-score stretched up on {{ticker}} {{interval}}")
alertcondition(ta.crossover(zScore, 0),                "ADF Z Mean Reclaim",   "Z-score reclaimed mean on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                "ADF Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"ADF\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
