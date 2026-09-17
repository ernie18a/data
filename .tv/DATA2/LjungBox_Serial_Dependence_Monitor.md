<!-- tradingview-pine-id: PUB;a8c195f655d0484d9fd69434ef5c4c77 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Ljung-Box Serial Dependence Monitor

Source: https://www.tradingview.com/script/JFIpM2V4/

## Description

Ljung-Box Serial Dependence Monitor

Explore serial correlation in returns and in the size of price changes.

This indicator calculates a rolling Ljung-Box Q statistic and its approximate chi-square p-value. It combines the joint test with individual autocorrelations and a compact summary table in a separate pane.

THREE TEST SERIES

• Returns: log returns by default, with simple percentage returns available as an alternative.
• Squared returns: applies the calculation to squared returns.
• Absolute returns: applies the calculation to absolute returns.

The latter two modes explore dependence in return magnitude, including patterns consistent with volatility clustering. They do not establish a particular ARCH/GARCH model.

HOW THE TEST WORKS

For each window, the script subtracts the sample mean and estimates autocorrelations at lags 1 through h. It calculates:

Q = n × (n + 2) × sum[r(k)² / (n − k)], for k = 1…h.

The p-value uses an approximate chi-square distribution with h degrees of freedom. No fitted time-series model or residual degrees-of-freedom adjustment is applied.

A p-value below the selected significance level flags evidence against the joint hypothesis of zero autocorrelation at the tested lags. A larger p-value does not prove independence or unpredictability.

READING THE DISPLAY

• Yellow line: rolling p-value, on a 0–1 scale.
• Dashed level: selected significance threshold; 5% is shown as 0.05.
• Colored background: windows flagged as significant.
• Optional ACF lines: autocorrelation at lags 1, 2 and 3, where included in the lag setting.
• Table: sample size, lag count, Q, p-value, first three ACF values, summed ACF and a descriptive verdict.

The optional ACF band is the simple normal-approximation reference ±z/sqrt(n), labeled “Bartlett” in the script. It is not a simultaneous confidence band across all lags.

WHAT THE REGIME LABELS MEAN

The Ljung-Box statistic squares autocorrelations and does not determine the direction of dependence. This implementation adds a separate heuristic based on the sign of the sum of the tested autocorrelations.

For significant return windows, a positive sum produces the “Momentum / persistence” label; a negative sum produces “Mean reversion.” For transformed-return windows, the corresponding labels describe positive or negative dependence in return magnitude.

These labels summarize the sampled ACF pattern. They are not directional price forecasts or validated trading signals. Positive and negative correlations at different lags can offset one another in the sum.

ILLUSTRATIVE EXAMPLE

With 250 observations, 10 lags and a 5% threshold, a hypothetical p-value of 0.02 is below 0.05 and is highlighted. A p-value of 0.20 is not highlighted.

The first result does not mean a 98% probability that a trade will succeed. The sign-based label requires separate inspection of the ACF pattern. These numbers are illustrative, not backtest results.

SETTINGS AND ALERTS

Defaults are 250 observations, 10 lags, log returns and a 5% significance level. A full window must be available, and the implementation requires h < n/4. Choose a lookback strictly greater than four times the lag count; otherwise the script remains in its warm-up state.

Four alert conditions are included: dependence becomes significant, dependence disappears, positive-sum regime begins and negative-sum regime begins. The last two retain the script's “Momentum regime” and “Mean-reversion regime” alert names even in squared/absolute-return modes; in those modes they concern return magnitude, not price direction.

Values and conditions can change during an open bar. For alerts based on completed candles, select Once Per Bar Close when creating the alert in TradingView.

INTERPRETATION AND LIMITATIONS

Rolling windows overlap, and repeated tests are not independent. There is no multiple-testing correction. The chi-square approximation and the simple ACF reference band rely on statistical assumptions; changing volatility and other departures from these assumptions can affect interpretation.

Missing values are skipped by the sample buffer, so gaps may cause the window to represent the latest valid observations rather than consecutive chart bars. A constant window has no defined autocorrelation; absent Q or p-values must not be read as evidence of independence. Extreme tail probabilities can round to zero numerically. Larger lookbacks and lag counts increase computation substantially.

This is a statistical research display. It does not place trades, estimate expected returns or establish a profitable strategy.

METHOD REFERENCE

NIST: Box-Ljung Test — https://www.itl.nist.gov/div898/handbook/pmc/section4/pmc4481.htm

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BotTradeLab

//@version=6
indicator("Ljung-Box Serial Dependence Monitor", shorttitle = "Ljung-Box", overlay = false, format = format.price, precision = 3)

// ───────────────────────── Inputs
const string G_CALC = "Calculation"
const string G_DISP = "Display"

int    lenW    = input.int(250, "Lookback window (bars)", minval = 30, maxval = 3000, group = G_CALC, tooltip = "Number of returns used for the test.")
int    maxLag  = input.int(10, "Max lag (h)", minval = 1, maxval = 50, group = G_CALC, tooltip = "The Q statistic jointly tests lags 1..h. Degrees of freedom = h.")
string series  = input.string("Returns", "Test series", options = ["Returns", "Squared returns", "Absolute returns"], group = G_CALC, tooltip = "Returns: tests for momentum / mean reversion. Squared or absolute returns: tests for volatility clustering (ARCH effects).")
bool   useLog  = input.bool(true, "Use log returns", group = G_CALC)
float  alpha   = input.float(5.0, "Significance level (%)", minval = 0.1, maxval = 20.0, step = 0.5, group = G_CALC)

bool   showAcf = input.bool(false, "Show ACF lags 1-3", group = G_DISP, tooltip = "Autocorrelations share the p-value scale, so they appear close to zero. Off by default.")
bool   showBg  = input.bool(true, "Highlight significant dependence", group = G_DISP)
bool   showTbl = input.bool(true, "Show table", group = G_DISP)
bool   compactTbl = input.bool(true, "Compact table", group = G_DISP, display = display.none, tooltip = "Four compact rows. Disable for individual ACF values and the reference band.")
string tblPos  = input.string("Top Right", "Table position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_DISP, display = display.none)
color  colP    = input.color(#f5c542, "p-value colour", group = G_DISP)
color  colMom  = input.color(#26a69a, "Momentum colour", group = G_DISP)
color  colRev  = input.color(#ef5350, "Mean-reversion colour", group = G_DISP)

// ───────────────────────── Special functions
// Lanczos approximation of ln Γ(x), x > 0
lnGamma(float x) =>
    float g = 7.0
    float[] c = array.from(0.99999999999980993, 676.5203681218851, -1259.1392167224028, 771.32342877765313, -176.61502916214059, 12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7)
    float xx = x - 1.0
    float a  = c.get(0)
    float t  = xx + g + 0.5
    for i = 1 to 8
        a += c.get(i) / (xx + i)
    0.5 * math.log(2.0 * math.pi) + (xx + 0.5) * math.log(t) - t + math.log(a)

// Regularised lower incomplete gamma P(a, x)  (Numerical Recipes: series + Lentz continued fraction)
gammaP(float a, float x) =>
    float res = na
    if x <= 0.0
        res := 0.0
    else if x < a + 1.0
        float ap  = a
        float sum = 1.0 / a
        float del = sum
        for j = 1 to 500
            ap  += 1.0
            del *= x / ap
            sum += del
            if math.abs(del) < math.abs(sum) * 1e-14
                break
        res := sum * math.exp(-x + a * math.log(x) - lnGamma(a))
    else
        float b = x + 1.0 - a
        float c = 1e300
        float d = 1.0 / b
        float h = d
        for i = 1 to 500
            float an = -i * (i - a)
            b += 2.0
            d := an * d + b
            if math.abs(d) < 1e-300
                d := 1e-300
            c := b + an / c
            if math.abs(c) < 1e-300
                c := 1e-300
            d := 1.0 / d
            float del = d * c
            h *= del
            if math.abs(del - 1.0) < 1e-14
                break
        res := 1.0 - math.exp(-x + a * math.log(x) - lnGamma(a)) * h
    math.max(0.0, math.min(1.0, res))

// Upper-tail probability of a chi-square variable with k degrees of freedom
chi2Sf(float q, float k) =>
    1.0 - gammaP(k / 2.0, q / 2.0)

// Two-sided normal quantile for the Bartlett band (Abramowitz & Stegun 26.2.23)
zTwoSided(float alphaFrac) =>
    float p = alphaFrac / 2.0
    float t = math.sqrt(-2.0 * math.log(p))
    t - (2.515517 + 0.802853 * t + 0.010328 * t * t) / (1.0 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t)

posOf(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        => position.bottom_left

fmt(float v, string f) =>
    na(v) ? "–" : str.tostring(v, f)

// ───────────────────────── Series
float r = useLog ? math.log(close / close[1]) : close / close[1] - 1.0
float x = series == "Squared returns" ? r * r : series == "Absolute returns" ? math.abs(r) : r

var float[] buf = array.new_float(0)
if not na(x)
    buf.push(x)
    if buf.size() > lenW
        buf.shift()

int  n     = buf.size()
bool ready = n >= lenW and maxLag < n / 4

// ───────────────────────── Autocorrelations and Ljung-Box Q
float[] acf = array.new_float(maxLag, na)
float   Q   = na
float   sumAcf = na

if ready
    float mu = buf.avg()
    float c0 = 0.0
    for i = 0 to n - 1
        float d = buf.get(i) - mu
        c0 += d * d
    if c0 > 0
        Q := 0.0
        sumAcf := 0.0
        for k = 1 to maxLag
            float ck = 0.0
            for i = k to n - 1
                ck += (buf.get(i) - mu) * (buf.get(i - k) - mu)
            float rk = ck / c0
            acf.set(k - 1, rk)
            Q += rk * rk / (n - k)
            sumAcf += rk
        Q := n * (n + 2) * Q

float pVal   = ready and not na(Q) ? chi2Sf(Q, maxLag) : na
float aFrac  = alpha / 100.0
bool  sig    = not na(pVal) and pVal < aFrac
float band   = ready ? zTwoSided(aFrac) / math.sqrt(n) : na
float r1     = maxLag >= 1 ? acf.get(0) : na
float r2     = maxLag >= 2 ? acf.get(1) : na
float r3     = maxLag >= 3 ? acf.get(2) : na

// Direction of the dependence: sign of the summed autocorrelations
bool retMode  = series == "Returns"
bool momentum = sig and sumAcf > 0
bool reversal = sig and sumAcf < 0

string verdict = not ready ? "Warming up" : not sig ? "No significant dependence" : retMode ? (momentum ? "Momentum / persistence" : "Mean reversion") : (momentum ? "Volatility clustering" : "Negative vol. dependence")
color  vCol    = not sig ? color.gray : momentum ? colMom : colRev

// ───────────────────────── Plots
plot(pVal, "Ljung-Box p-value", colP, 2)
hline(aFrac, "Significance level", color.new(color.gray, 20), hline.style_dashed)
hline(0.0, "Zero", color.new(color.gray, 70), hline.style_dotted)
hline(1.0, "One", color.new(color.gray, 70), hline.style_dotted)

plot(showAcf ? r1 : na, "ACF lag 1", color.new(colMom, 0), 1, plot.style_line)
plot(showAcf ? r2 : na, "ACF lag 2", color.new(colMom, 45), 1, plot.style_line)
plot(showAcf ? r3 : na, "ACF lag 3", color.new(colMom, 70), 1, plot.style_line)
pBu = plot(showAcf ? band : na, "Bartlett upper", display = display.none, editable = false)
pBl = plot(showAcf ? -band : na, "Bartlett lower", display = display.none, editable = false)
fill(pBu, pBl, color.new(color.gray, 90), "Bartlett band")

bgcolor(showBg and sig ? color.new(vCol, 88) : na, title = "Significant dependence")

// ───────────────────────── Alerts
alertcondition(sig and not sig[1], "Dependence becomes significant", "Ljung-Box: serial dependence became significant on {{ticker}}")
alertcondition(not sig and sig[1], "Dependence disappears", "Ljung-Box: serial dependence is no longer significant on {{ticker}}")
alertcondition(momentum and not momentum[1], "Momentum regime", "Ljung-Box: positive serial dependence (momentum) on {{ticker}}")
alertcondition(reversal and not reversal[1], "Mean-reversion regime", "Ljung-Box: negative serial dependence (mean reversion) on {{ticker}}")

// ───────────────────────── Table
var table tbl = table.new(posOf(tblPos), 2, compactTbl ? 4 : 6, bgcolor = color.new(#131722, 15), border_color = color.new(color.gray, 75), border_width = 1)

if showTbl and barstate.islast
    color tc = color.new(color.white, 0)
    if compactTbl
        string modeLabel = retMode ? "Returns" : series == "Squared returns" ? "Squared" : "Absolute"
        string shortState = not ready ? "Warming up" : na(pVal) ? "Unavailable" : not sig ? "Not significant" : momentum ? "Positive ACF sum" : reversal ? "Negative ACF sum" : "Mixed ACF"
        tbl.cell(0, 0, "LJUNG-BOX", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 0, modeLabel + " · " + str.tostring(n) + "/" + str.tostring(maxLag), text_color = color.silver, text_size = size.tiny)
        tbl.cell(0, 1, "p / α", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 1, fmt(pVal, "#.####") + " / " + str.tostring(alpha, "#.#") + "%", text_color = sig ? vCol : tc, text_size = size.tiny)
        tbl.cell(0, 2, "Q / ΣACF", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 2, fmt(Q, "#.##") + " / " + fmt(sumAcf, "#.###"), text_color = tc, text_size = size.tiny)
        tbl.cell(0, 3, "State", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 3, shortState, text_color = vCol, text_size = size.tiny)
    else
        tbl.cell(0, 0, series + " · n=" + str.tostring(n) + " · h=" + str.tostring(maxLag), text_color = color.gray, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 0, "α=" + str.tostring(alpha, "#.#") + "%", text_color = color.gray, text_size = size.tiny)
        tbl.cell(0, 1, "Q statistic", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 1, fmt(Q, "#.##"), text_color = tc, text_size = size.tiny)
        tbl.cell(0, 2, "p-value", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 2, fmt(pVal, "#.####"), text_color = sig ? vCol : tc, text_size = size.tiny)
        tbl.cell(0, 3, "ACF 1 / 2 / 3  (band ±" + fmt(band, "#.###") + ")", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 3, fmt(r1, "#.###") + " / " + fmt(r2, "#.###") + " / " + fmt(r3, "#.###"), text_color = tc, text_size = size.tiny)
        tbl.cell(0, 4, "Sum ACF 1..h", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 4, fmt(sumAcf, "#.###"), text_color = tc, text_size = size.tiny)
        tbl.cell(0, 5, "Verdict", text_color = tc, text_size = size.tiny, text_halign = text.align_left)
        tbl.cell(1, 5, verdict, text_color = vCol, text_size = size.tiny)
````
