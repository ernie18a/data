# Voss Predictor Multi-Symbol Ranking

- url: https://www.tradingview.com/script/IgJR6DVV-Voss-Predictor-Multi-Symbol-Ranking/
- type: indicator
- pine_id: PUB;b789f3cd420c42bfb02c2be509ab9352
- version: 1.0

## Description

Voss Predictor Multi-Symbol Ranking (VPSR) is a multi-market dashboard that scans up to 40 assets and ranks them based on momentum, trend strength, and underlying market structure.
Instead of analysing one chart at a time, this tool compares all selected symbols side-by-side and highlights which markets are currently showing the strongest or weakest conditions in real time.
It classifies each asset as:

Bullish (strength building)
Bearish (weakening or declining)
Neutral (no clear direction)

What it helps you do

Quickly identify the strongest trending markets
Spot weakening or reversing assets earlier
Compare stocks, forex, and crypto in one view
Focus only on the highest-quality opportunities
Reduce time spent switching between charts

Key Features

Live ranking of up to 40 symbols
Simple bullish / bearish / neutral signals
Composite strength score for each asset
Built-in trend and momentum comparison
Context-based tooltips for deeper interpretation
Adaptive settings based on market type and trading style

Theoretical Background (Ehlers-Based Approach)
This indicator is inspired by the work of John Ehlers, a pioneer in applying digital signal processing to financial markets.
Ehlers' core idea is that price action is not purely random, but instead contains hidden cyclical structures that can be revealed using filtering techniques similar to those used in engineering and physics.
Rather than relying on traditional lagging indicators, this approach focuses on:

Cycle extraction: isolating the dominant "wave" within market noise
Bandpass filtering: removing both long-term trend distortion and short-term randomness
Adaptive market cycles: recognising that cycle length and volatility constantly change
Phase and momentum behaviour: identifying where price sits within its cycle (expansion, contraction, or transition)

This indicator applies these principles using:

An Ehlers-style bandpass filter to isolate market structure
A leading filter (Ehlers' Voss) to estimate short-term directional bias
A correlation-based component to measure structural alignment and consistency across price movement

The result is a system that focuses on cycle behaviour and momentum flow, rather than lagging averages or reactive signals.
Signal Logic Overview

Bullish: Leading momentum aligns with upward structural movement
Bearish: Downward momentum dominates or structure weakens
Neutral: Mixed or unclear directional conditions
Divergence states highlight potential exhaustion or early reversal conditions

Intended Use
This indicator is designed as a multi-asset scanning and ranking tool, helping traders quickly identify where momentum and structure are strongest or weakest across markets.
It is best used for:

Relative strength analysis
Opportunity scanning across multiple assets
Early detection of momentum shifts
Filtering out weak or low-quality setups

It is not a standalone buy/sell system, but a decision-support layer for market selection and timing context.

## Source Code

````pine
//@version=6
indicator("Voss Predictor Multi-Symbol Ranking", "Voss PMSR", false, format.price, 3)

// =====================================================================
// 1. CORE FUNCTIONS
// =====================================================================

// Whitening Function
whiten(series, lookback) =>
    0.5 * (series - nz(series[lookback], nz(series[1], series)))

// Ehler Bandpass Filter
bpf(series, period, bandwidth, lookback) =>
    var float PIx2 = 4.0 * math.asin(1.0)

    alpha = PIx2 / period
    gamma = math.cos(alpha * bandwidth)

    delta =
         1.0 / gamma -
         math.sqrt(1.0 / math.pow(gamma, 2.0) - 1.0)

    float bandPass = na

    bandPass :=
         (1.0 - delta) * whiten(series, lookback) +
         math.cos(alpha) * (1.0 + delta) * nz(bandPass[1]) -
         delta * nz(bandPass[2])

    bandPass

// Voss Predictive Filter
vpf(series, barsPrediction, horizMode) =>

    maxBars =
         horizMode == "Long"  ? 20.0 :
         horizMode == "Short" ? 2.0 :
         5.0

    order = 3.0 * math.min(maxBars, barsPrediction)

    float voss = na
    E = 0.0

    for i = 0 to int(order - 1)
        E := nz(voss[order - i]) * (1 + i) / order + E

    voss := 0.5 * (3.0 + order) * series - E

    voss

// =====================================================================
// 2. SETTINGS ENGINE
// =====================================================================

get_settings(tMethod, aType, horiz) =>

    var int periodBandpass = 35
    var float bandWidth = 0.35
    var float barsPrediction = 2.5
    var int periodCorrelation = 35
    var int lookback = 2

    if tMethod == "Swing Trading"

        if aType == "Stocks"

            periodBandpass := horiz == "Long" ? 70 : horiz == "Short" ? 15 : 35
            bandWidth := horiz == "Long" ? 0.45 : horiz == "Short" ? 0.25 : 0.35
            barsPrediction := horiz == "Long" ? 6.0 : horiz == "Short" ? 1.0 : 2.5
            periodCorrelation := horiz == "Long" ? 70 : horiz == "Short" ? 15 : 35
            lookback := horiz == "Short" ? 1 : 2

        else if aType == "Forex"

            periodBandpass := horiz == "Long" ? 60 : horiz == "Short" ? 10 : 30
            bandWidth := horiz == "Long" ? 0.4 : horiz == "Short" ? 0.2 : 0.3
            barsPrediction := horiz == "Long" ? 5.0 : horiz == "Short" ? 0.5 : 2.0
            periodCorrelation := horiz == "Long" ? 60 : horiz == "Short" ? 10 : 30
            lookback := horiz == "Short" ? 1 : 2

        else

            periodBandpass := horiz == "Long" ? 80 : horiz == "Short" ? 20 : 50
            bandWidth := horiz == "Long" ? 0.5 : horiz == "Short" ? 0.3 : 0.4
            barsPrediction := horiz == "Long" ? 7.0 : horiz == "Short" ? 1.5 : 3.0
            periodCorrelation := horiz == "Long" ? 80 : horiz == "Short" ? 20 : 50
            lookback := horiz == "Short" ? 1 : 2

    else if tMethod == "Position Trading"

        if aType == "Stocks"

            periodBandpass := horiz == "Long" ? 100 : horiz == "Short" ? 20 : 50
            bandWidth := horiz == "Long" ? 0.5 : horiz == "Short" ? 0.3 : 0.4
            barsPrediction := horiz == "Long" ? 10.0 : horiz == "Short" ? 1.0 : 4.0
            periodCorrelation := horiz == "Long" ? 100 : horiz == "Short" ? 20 : 50
            lookback := horiz == "Short" ? 1 : 2

        else if aType == "Forex"

            periodBandpass := horiz == "Long" ? 80 : horiz == "Short" ? 15 : 40
            bandWidth := horiz == "Long" ? 0.45 : horiz == "Short" ? 0.25 : 0.35
            barsPrediction := horiz == "Long" ? 8.0 : horiz == "Short" ? 0.75 : 3.0
            periodCorrelation := horiz == "Long" ? 80 : horiz == "Short" ? 15 : 40
            lookback := horiz == "Short" ? 1 : 2

        else

            periodBandpass := horiz == "Long" ? 120 : horiz == "Short" ? 25 : 60
            bandWidth := horiz == "Long" ? 0.6 : horiz == "Short" ? 0.35 : 0.5
            barsPrediction := horiz == "Long" ? 12.0 : horiz == "Short" ? 1.5 : 5.0
            periodCorrelation := horiz == "Long" ? 120 : horiz == "Short" ? 25 : 60
            lookback := horiz == "Short" ? 1 : 2

    else

        if aType == "Stocks"

            periodBandpass := horiz == "Long" ? 30 : horiz == "Short" ? 7 : 15
            bandWidth := horiz == "Long" ? 0.35 : horiz == "Short" ? 0.2 : 0.3
            barsPrediction := horiz == "Long" ? 2.5 : horiz == "Short" ? 0.5 : 1.0
            periodCorrelation := horiz == "Long" ? 30 : horiz == "Short" ? 7 : 15
            lookback := horiz == "Short" ? 1 : 2

        else if aType == "Forex"

            periodBandpass := horiz == "Long" ? 20 : horiz == "Short" ? 5 : 10
            bandWidth := horiz == "Long" ? 0.3 : horiz == "Short" ? 0.15 : 0.25
            barsPrediction := horiz == "Long" ? 2.0 : horiz == "Short" ? 0.25 : 0.5
            periodCorrelation := horiz == "Long" ? 20 : horiz == "Short" ? 5 : 10
            lookback := horiz == "Short" ? 1 : 2

        else

            periodBandpass := horiz == "Long" ? 40 : horiz == "Short" ? 10 : 20
            bandWidth := horiz == "Long" ? 0.4 : horiz == "Short" ? 0.25 : 0.35
            barsPrediction := horiz == "Long" ? 3.0 : horiz == "Short" ? 0.75 : 1.5
            periodCorrelation := horiz == "Long" ? 40 : horiz == "Short" ? 10 : 20
            lookback := horiz == "Short" ? 1 : 2

    [periodBandpass, bandWidth, barsPrediction, periodCorrelation, lookback]

// =====================================================================
// 3. SYMBOL CALCULATION
// =====================================================================

calc_symbol_metrics(pBP, bw, bPred, pCorr, lb, horizMode) =>

    _bpf  = bpf(close, pBP, bw, lb)
    _vpf  = vpf(_bpf, bPred, horizMode)
    _corr = ta.correlation(close, bar_index, pCorr)

    _vpfSum  = math.sum(_vpf, pCorr)
    _corrSum = math.sum(_corr, pCorr)

    [_vpfSum, _corrSum, _bpf, _vpf]

// =====================================================================
// 4. INPUTS
// =====================================================================

g_setup = "1. Asset List"
g_algo  = "2. Algorithm Parameters"

symbolListInput = input.text_area(
     "SNDK,KLIC,INTC,WDC,MU,LRCX,ASML,AXTI,AMAT,NVTS,WOLF,LCFS,MXL,GFS,HPE,MRAM,VRT,KEYS,FIX,AEHR,AAOI,MCHP,AMD,TSEM,ON,POET,CIEN,ADI,TXN,DELL,PWR,SOI,LASR,AAPL,MSFT,GOOGL,AMZN,NVDA,META,TSLA",
     "40 Stock Symbols",
     group=g_setup,
     tooltip="Enter symbols separated by commas. Example: AAPL, TSLA, AMD. Maximum limit is 40 symbols.")

tradingMethod = input.string(
     "Swing Trading",
     "Trading Horizon Style",
     options = ["Interday Trading", "Swing Trading", "Position Trading"],
     group = g_algo,
     tooltip="Changes filter math based on speed:\n• Interday: Fast / scalping.\n• Swing: Medium / multi-day hold.\n• Position: Slow / multi-week trend.")

assetType = input.string(
     "Stocks",
     "Market Asset Type",
     options = ["Forex", "Stocks", "Crypto"],
     group = g_algo,
     tooltip="Optimizes filter frequency tuning for specific market volatility dynamics.")

predHorizon = input.string(
     "Medium",
     "Prediction Lookahead",
     options = ["Short", "Medium", "Long"],
     group = g_algo,
     tooltip="Controls predictive lookahead strength:\n• Short: Reacts fast, high noise.\n• Medium: Standard balance.\n• Long: Smooth trend projection.")

textSizeSelection = input.string(
     "Small",
     "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = g_algo
)

uiTextSize =
     textSizeSelection == "Tiny"  ? size.tiny  :
     textSizeSelection == "Small" ? size.small :
     textSizeSelection == "Large" ? size.large :
     textSizeSelection == "Huge"  ? size.huge  :
     size.normal

// =====================================================================
// 5. SYMBOL PARSING
// =====================================================================

var string[] symbols = array.new_string()

if barstate.isfirst

    rawSymbols = str.split(symbolListInput, ",")

    for i = 0 to array.size(rawSymbols) - 1

        sym = str.trim(array.get(rawSymbols, i))

        if sym != ""
            array.push(symbols, sym)

if array.size(symbols) > 40
    runtime.error("Maximum 40 symbols allowed.")

// =====================================================================
// 6. ARRAYS
// =====================================================================

var float[] vpfSums      = array.new_float()
var float[] corrSums     = array.new_float()
var float[] scores       = array.new_float()
var string[] predSignals = array.new_string()
var int[] validIndices   = array.new_int()

// =====================================================================
// 7. MAIN CALCULATIONS
// =====================================================================

if barstate.isnew

    array.clear(vpfSums)
    array.clear(corrSums)
    array.clear(scores)
    array.clear(predSignals)
    array.clear(validIndices)

[pBP, bw, bPred, pCorr, lb] =
     get_settings(tradingMethod, assetType, predHorizon)

for i = 0 to array.size(symbols) - 1

    sym = array.get(symbols, i)

    [sumV, sumC, valBPF, valVPF] =
         request.security(
              sym,
              timeframe.period,
              calc_symbol_metrics(
                   pBP,
                   bw,
                   bPred,
                   pCorr,
                   lb,
                   predHorizon))

    if not na(sumV) and not na(sumC)

        sig =
             valVPF > valBPF and valVPF > 0 ? "Bullish" :
             valVPF < valBPF and valVPF < 0 ? "Bearish" :
             "Neutral"

        score = (0.6 * sumV) + (0.4 * sumC)

        array.push(vpfSums, sumV)
        array.push(corrSums, sumC)
        array.push(scores, score)
        array.push(predSignals, sig)
        array.push(validIndices, i)

// =====================================================================
// 8. SORTING
// =====================================================================

sortIndicesByScores(indices, values) =>

    sorted = array.copy(indices)

    n = array.size(sorted)

    if n > 1

        for i = 0 to n - 2

            for j = 0 to n - i - 2

                idxJ = array.get(sorted, j)
                idxN = array.get(sorted, j + 1)

                if array.get(values, idxJ) < array.get(values, idxN)

                    array.set(sorted, j, idxN)
                    array.set(sorted, j + 1, idxJ)

    sorted

// =====================================================================
// 9. TABLE
// =====================================================================

var table rankingTable = table.new(
     position.middle_center,
     41,
     8,
     border_width = 1,
     border_color = color.rgb(47, 48, 53),
     bgcolor = #000105CC)

if barstate.islastconfirmedhistory and array.size(validIndices) > 0

    sortedIndices = sortIndicesByScores(validIndices, scores)

    headerColor = color.rgb(19, 21, 26)
    textColor   = color.white

    // ================================================================
    // DASHBOARD HEADER
    // ================================================================

    headerTitle =
         "Voss Predictor Multi-Symbol Ranking"

    headerSettings =
         "Mode: " + tradingMethod +
         "  |  Asset: " + assetType +
         "  |  Horizon: " + predHorizon +
         "  |  TF: " + timeframe.period +
         "  |  Symbols: " + str.tostring(array.size(validIndices))

    table.cell(
         rankingTable,
         0,
         0,
         headerTitle,
         bgcolor = color.rgb(9, 11, 16),
         text_color = color.rgb(0, 255, 140),
         text_size = size.large,
         text_halign = text.align_center,
         tooltip =
              "Adaptive Voss Predictive Filter Ranking Dashboard\n\n" +
              "• Predictive Wave Analytics\n" +
              "• Correlation Ranking\n" +
              "• Dynamic Momentum State Engine\n" +
              "• Horizontal Multi-Asset Scanner")

    table.merge_cells(rankingTable, 0, 0, 40, 0)

    table.cell(
         rankingTable,
         0,
         1,
         headerSettings,
         bgcolor = color.rgb(15, 17, 22),
         text_color = #c57212,
         text_size = size.normal,
         text_halign = text.align_center,
         tooltip =
              "Current Dashboard Configuration\n\n" +
              "Trading Style: " + tradingMethod + "\n" +
              "Asset Type: " + assetType + "\n" +
              "Prediction Horizon: " + predHorizon + "\n" +
              "Chart Timeframe: " + timeframe.period)

    table.merge_cells(rankingTable, 0, 1, 40, 1)

    // ================================================================
    // LEFT LABELS
    // ================================================================

    table.cell(rankingTable, 0, 2, "Symbol",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    table.cell(rankingTable, 0, 3, "Rank",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    table.cell(rankingTable, 0, 4, "VPF",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    table.cell(rankingTable, 0, 5, "Corr",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    table.cell(rankingTable, 0, 6, "Signal",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    table.cell(rankingTable, 0, 7, "Score",
         bgcolor=headerColor,
         text_color=textColor,
         text_size=uiTextSize)

    // ================================================================
    // HORIZONTAL SYMBOL DISPLAY
    // ================================================================

    for k = 0 to array.size(validIndices) - 1

        idx = array.get(sortedIndices, k)

        sym  = array.get(symbols, idx)
        vSum = array.get(vpfSums, idx)
        cSum = array.get(corrSums, idx)
        sig  = array.get(predSignals, idx)
        sc   = array.get(scores, idx)

        // ------------------------------------------------------------
        // CONTEXT ENGINE
        // ------------------------------------------------------------

        performanceStatus =
             sc > 5.0  ? "Strong momentum continuity detected." :
             sc > 0.0  ? "Moderate positive structural bias." :
             sc < -5.0 ? "Aggressive downward trend validation." :
             "Weak or choppy market conditions."

        cyclicalStatus =
             vSum > 0 ?
             "Predictive wave expansion detected." :
             "Predictive wave contraction detected."

        correlationStatus =
             cSum > 0 ?
             "Positive directional trend synchronization." :
             "Negative or diverging trend structure."

        // ------------------------------------------------------------
        // ADVANCED SIGNAL MATRIX
        // ------------------------------------------------------------

        sigDivergence = ""

        if sc >= 0 and sig == "Bearish"

            sigDivergence :=
                 "[!] EXHAUSTION / PULLBACK\n\n" +
                 "Strong higher-level structure remains intact, " +
                 "but short-term predictive momentum is weakening."

        else if sc >= 0 and sig == "Bullish"

            sigDivergence :=
                 "[+] FULL ALIGNMENT\n\n" +
                 "Trend structure and predictive momentum are aligned bullish."

        else if sc < 0 and sig == "Bullish"

            sigDivergence :=
                 "[!] REVERSAL / BOTTOMING\n\n" +
                 "Weak structural rank but improving predictive momentum."

        else if sc < 0 and sig == "Bearish"

            sigDivergence :=
                 "[-] FULL ALIGNMENT\n\n" +
                 "Both structure and predictive momentum remain bearish."

        else

            sigDivergence :=
                 "[~] NEUTRAL / TRANSITION\n\n" +
                 "Directional advantage currently unclear."

        // ------------------------------------------------------------
        // TOOLTIPS
        // ------------------------------------------------------------

        ttSymbol =
             "Ticker: " + sym +
             "\nAsset Type: " + assetType +
             "\nTrading Style: " + tradingMethod +
             "\nPrediction Horizon: " + predHorizon

        ttRank =
             "Rank #" + str.tostring(k + 1) +
             " out of " + str.tostring(array.size(validIndices)) +
             " assets."

        ttVPF =
             sym + " VPF Score: " +
             str.tostring(vSum, "#.##") +
             "\n\n" + cyclicalStatus

        ttCorr =
             sym + " Correlation Score: " +
             str.tostring(cSum, "#.##") +
             "\n\n" + correlationStatus

        ttSignal =
             "Signal State: " + sig +
             "\n\n" + sigDivergence

        ttScore =
             "Composite Score: " +
             str.tostring(sc, "#.##") +
             "\n\n" + performanceStatus

        // ------------------------------------------------------------
        // SYMBOL HEADER
        // ------------------------------------------------------------

        table.cell(
             rankingTable,
             k + 1,
             2,
             sym,
             bgcolor = headerColor,
             text_color = color.white,
             text_size = uiTextSize,
             tooltip = ttSymbol)

        // RANK

        table.cell(
             rankingTable,
             k + 1,
             3,
             str.tostring(k + 1),
             text_color = color.rgb(29, 97, 185),
             text_size = uiTextSize,
             tooltip = ttRank)

        // VPF

        table.cell(
             rankingTable,
             k + 1,
             4,
             str.tostring(vSum, "#.##"),
             text_color = vSum > 0 ? #00ff08 : #ff0404,
             text_size = uiTextSize,
             tooltip = ttVPF)

        // CORR

        table.cell(
             rankingTable,
             k + 1,
             5,
             str.tostring(cSum, "#.##"),
             text_color = cSum > 0 ? #00ff08 : #ff0404,
             text_size = uiTextSize,
             tooltip = ttCorr)

        // SIGNAL

        table.cell(
             rankingTable,
             k + 1,
             6,
             sig,
             text_color =
                  sig == "Bullish" ? #00ff08 :
                  sig == "Bearish" ? #ff0404 :
                  color.gray,
             text_size = uiTextSize,
             tooltip = ttSignal)

        // SCORE

        table.cell(
             rankingTable,
             k + 1,
             7,
             str.tostring(sc, "#.##"),
             text_color = sc > 0 ? #00ff08 : #ff0404,
             text_size = uiTextSize,
             tooltip = ttScore)

else if barstate.islastconfirmedhistory

    label.new(
         bar_index,
         high,
         "No valid data found",
         color = color.red,
         style = label.style_label_down)
````
