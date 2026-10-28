# Margin Debt to M2 Ratio

- url: https://www.tradingview.com/script/C0fpi9Q3-Margin-Debt-to-M2-Ratio/
- type: indicator
- pine_id: PUB;80d078ab9291412ba3b26b2c09287b2c
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

Plots customer margin debt divided by the M2 money stock, expressed as a percent, in a separate pane, with a standard deviation band around its mean. Normalizing margin debt by the broad money supply removes the secular growth the raw series accrues through inflation and monetary expansion, so leverage readings are comparable across decades rather than trending upward by construction.


█ [b]HISTORY / BACKGROUND[/b]

Aggregate customer margin debt has long been followed as a gauge of speculative leverage and risk appetite. The statistic is published monthly by FINRA, and previously by the NYSE for member firms. Reading the raw dollar figure across long spans is misleading because it rises with the size of the economy and the money supply regardless of relative leverage. Dividing margin debt by M2 is a normalization that expresses borrowing against the monetary base, isolating changes in leverage intensity from growth in the quantity of money. The approach is a normalization technique rather than a named proprietary system. Its conceptual basis is that relative leverage, not the nominal dollar level, carries the sentiment information.


█ [b]HOW IT WORKS[/b]

The script requests two series at monthly resolution, forms their ratio, and derives a mean and a standard deviation band from the monthly history.

1. Margin debt is requested with [b]request.security[/b] at the 1M timeframe using the closing value of the symbol set in the first input. M2 is requested the same way from the second input.

2. The ratio is computed as margin debt divided by the quantity (M2 multiplied by 1000), then multiplied by 100. The factor of 1000 reconciles units, because the default margin debt series is reported in millions of dollars and M2 in billions. The factor of 100 expresses the result as a percent. When either series is na, or when M2 is zero, the ratio is na.

3. One ratio observation is appended to a persistent array on each new calendar month, detected with a change in the monthly time value. Computing the statistics from this array rather than from chart bars keeps them correct on any chart resolution, because forward filled monthly values on a lower timeframe do not inflate the sample.

4. On each new month the band statistics are recomputed. The window is the entire array in full sample mode, or the trailing number of months given by the lookback input in rolling mode. The mean is the arithmetic average over the window. The standard deviation is the sample deviation, computed as the square root of the summed squared deviations from the mean divided by the window length minus one, and is na until at least two observations exist.

5. The upper and lower band lines are the mean plus and minus the sigma multiplier times the standard deviation.


█ [b]HOW TO USE[/b]

The script is built for the monthly timeframe. The underlying data is monthly for M2 and quarterly for the margin debt proxy, and the statistics are accumulated per calendar month, so 1M is the resolution at which the display matches the data cadence. On an intraday chart the script draws a warning label and the band should not be read at that resolution.

Visual elements:

​• The blue line is the margin debt to M2 ratio in percent.
​• The shaded band spans the mean plus and minus the chosen sigma multiple.
​• The gray midline is the mean, when enabled.
​• The label at the last bar prints the current ratio to two decimals.

Readings above the upper band indicate leverage that is high relative to the money supply. Readings below the lower band indicate depressed leverage, typically following a deleveraging episode. This is a slow moving macro context series, not a timing trigger. An alert condition fires when the ratio reaches or exceeds the upper band.


█ [b]SETTINGS[/b]

​• [b]Margin debt series[/b]: the symbol used as the numerator. Default FRED:BOGZ1FL663067003Q.
​• [b]M2 money stock[/b]: the symbol used as the denominator. Default FRED:M2SL.
​• [b]Band mode[/b]: selects Rolling (point-in-time), which uses a trailing window, or Full sample (lookahead), which uses the entire history. Default Rolling (point-in-time).
​• [b]Rolling lookback (months)[/b]: the trailing window length used in rolling mode. Default 180, minimum 12.
​• [b]Sigma multiplier[/b]: the number of standard deviations for the band width. Default 1.0, minimum 0.25, step 0.25.
​• [b]Show mean midline[/b]: toggles the mean line. Default on.
​• [b]Show current value label[/b]: toggles the last bar value label. Default on.


█ [b]WHAT MAKES IT ORIGINAL[/b]

The script normalizes margin debt by M2 and presents the result in a dedicated pane with an explicit standard deviation band, rather than overlaying a rate of change or a z score of the raw series on price. Two design choices distinguish the implementation. First, the band can be computed either as a trailing point-in-time window or as a fixed full sample band, and the full sample option is labeled as containing lookahead, so the distinction is explicit rather than hidden in the output. Second, the band statistics are accumulated from one observation per calendar month held in an array, which makes the mean and standard deviation independent of the chart timeframe and avoids the understated deviation that results when forward filled monthly values are sampled on a lower timeframe.


█ [b]NOTES / LIMITATIONS[/b]

​• [b]Symbol resolution[/b]: both inputs ignore invalid symbols. If a symbol does not resolve or returns na, or if M2 is zero, the ratio is na and neither the line nor the band renders. No runtime error is raised.
​• [b]Unit assumption[/b]: the ratio applies a fixed factor of 1000 to reconcile a numerator in millions against a denominator in billions. Replacing the default symbols with series in other units breaks the percent scaling.
​• [b]Data cadence[/b]: the default margin debt proxy is quarterly and M2 is monthly, so the ratio holds the most recent quarterly margin debt value across the intervening months.
​• [b]Provenance[/b]: TradingView does not carry the FINRA monthly margin debt statistic as a native symbol. The default numerator is the Federal Reserve Z.1 series for margin accounts at brokers and dealers, a close substitute that differs in level and cadence from the FINRA figure.
​• [b]Lookahead[/b]: only the Full sample band mode uses future observations in its statistics and is therefore not point-in-time. Rolling mode does not. The request.security calls use the default non lookahead behavior.
​• [b]Timeframe[/b]: the logic is intended for 1M. On intraday charts a warning label is drawn and the band should not be read.
​• [b]History dependence[/b]: the band requires accumulated monthly observations to populate. Early in available history, or on symbols with short history, the standard deviation is na until at least two monthly observations exist and stabilizes only after the lookback window fills.


█ [b]THANKS[/b]

Chart concept surfaced by the Stacked Insights YouTube channel. Margin debt data originates with FINRA and the Federal Reserve. M2 originates with the Board of Governors of the Federal Reserve System.

## Source Code

````pine
//@version=6
indicator("Margin Debt to M2 Ratio", shorttitle="MD-M2", overlay=false, precision=2)

// =============================================================================
// Margin Debt to M2 Ratio
// Customer margin debt normalized by the M2 money stock, expressed as a percent,
// with a standard deviation band. Detrends raw margin debt against the monetary
// base so leverage is comparable across decades.
// =============================================================================

// --- Inputs: data ------------------------------------------------------------
grpData = "Data"
mdSym = input.symbol("FRED:BOGZ1FL663067003Q", "Margin debt series", group = grpData, tooltip = "FRED Z.1 'Margin Accounts at Brokers and Dealers, Asset Level' (quarterly, millions USD). FINRA monthly margin debt is not natively available on TradingView; this is the closest substitute and differs slightly in level and cadence.")
m2Sym = input.symbol("FRED:M2SL", "M2 money stock", group = grpData, tooltip = "FRED M2SL (monthly, seasonally adjusted, billions USD).")
m2Scale = input.float(1.0, "M2 unit multiplier", minval = 0.001, group = grpData, tooltip = "Multiplier applied to the M2 series to match the margin debt series' units. TradingView delivers both FRED series in consistent units, so 1.0 is correct. Set to 1000 only if the ratio plots three orders of magnitude too high.")

// --- Inputs: band ------------------------------------------------------------
grpBand = "Standard deviation band"
bandMode = input.string("Rolling (point-in-time)", "Band mode", options = ["Rolling (point-in-time)", "Full sample (lookahead)"], group = grpBand, tooltip = "Rolling computes mean and sigma over a trailing window and is valid as a live signal. Full sample uses the entire history including future observations, reproducing a GuruFocus-style fixed band, and is therefore not point-in-time.")
lookback = input.int(180, "Rolling lookback (months)", minval = 12, group = grpBand)
kSigma = input.float(1.0, "Sigma multiplier", minval = 0.25, step = 0.25, group = grpBand)
showMid = input.bool(true, "Show mean midline", group = grpBand)

// --- Inputs: display ---------------------------------------------------------
grpViz = "Display"
showLbl = input.bool(true, "Show current value label", group = grpViz)

// --- Data at monthly resolution ----------------------------------------------
md = request.security(mdSym, "1M", close, ignore_invalid_symbol = true)
m2 = request.security(m2Sym, "1M", close, ignore_invalid_symbol = true)

// Ratio in percent. Both FRED series arrive in consistent units on TradingView,
// so no unit conversion is applied by default (m2Scale = 1.0).
ratio = (na(md) or na(m2) or m2 == 0) ? na : md / (m2 * m2Scale) * 100.0

// --- Collect one ratio observation per calendar month ------------------------
// Stats are computed over true monthly observations so they are correct on any
// chart timeframe (daily, weekly, or monthly).
var array<float> hist = array.new<float>()
newMonth = ta.change(time("1M")) != 0

if not na(ratio) and (newMonth or barstate.isfirst)
    array.push(hist, ratio)

isFull = bandMode == "Full sample (lookahead)"

// --- Band statistics (recompute only when a new month is added) --------------
var float mean = na
var float sd = na

if (newMonth or barstate.islast) and array.size(hist) > 0
    int n = array.size(hist)
    int win = isFull ? n : math.min(n, lookback)
    int startIdx = n - win
    float s = 0.0
    for i = startIdx to n - 1
        s += array.get(hist, i)
    mean := s / win
    if win > 1
        float ss = 0.0
        for i = startIdx to n - 1
            float d = array.get(hist, i) - mean
            ss += d * d
        sd := math.sqrt(ss / (win - 1))
    else
        sd := na

upper = na(mean) or na(sd) ? na : mean + kSigma * sd
lower = na(mean) or na(sd) ? na : mean - kSigma * sd

// --- Plots -------------------------------------------------------------------
pUpper = plot(upper, "Upper sigma", color = color.new(#787B86, 40))
pLower = plot(lower, "Lower sigma", color = color.new(#787B86, 40))
fill(pUpper, pLower, color = color.new(#2962FF, 90), title = "Sigma band")
plot(showMid ? mean : na, "Mean", color = color.new(#787B86, 0))
plot(ratio, "Margin Debt / M2 percent", color = color.new(#2962FF, 0), linewidth = 2)

// --- Current value label -----------------------------------------------------
if showLbl and barstate.islast and not na(ratio)
    label.new(bar_index, ratio, str.tostring(ratio, "0.00") + "%", style = label.style_label_left, color = color.new(#2962FF, 0), textcolor = color.white, size = size.normal)

// --- Timeframe note ----------------------------------------------------------
if barstate.islast and timeframe.isintraday
    label.new(bar_index, lower, "Intraday timeframe: source data is monthly/quarterly. Use 1M for intended display.", yloc = yloc.price, style = label.style_label_up, color = color.new(#F23645, 0), textcolor = color.white, size = size.small)

// --- Alert -------------------------------------------------------------------
alertcondition(not na(ratio) and not na(upper) and ratio >= upper, "Ratio at or above upper band", "Margin Debt to M2 ratio is at or above the upper sigma band")
````
