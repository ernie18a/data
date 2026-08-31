<!-- tradingview-pine-id: PUB;0f3b4623354e4622b56947572bfacf2f -->
<!-- tradingviewscripts-format: 1 -->
# (CGP) Crypto Diversification Lens

Source: https://www.tradingview.com/script/OA5t5iaA-CGP-Crypto-Diversification-Lens/

## Description

## CGP Crypto Diversification Lens

Owning more cryptocurrencies does not automatically mean you have reduced your risk.

The CGP Crypto Diversification Lens lets you build a hypothetical crypto portfolio and compare its historical risk and upside directly against Bitcoin.

It answers two simple questions:

1. Did adding these coins actually reduce risk?
2. Did the additional risk produce more upside?

### How to use it

1. Open any cryptocurrency on the 1D chart.
2. Add the coins you want to test.
3. Enter the percentage allocated to each coin.
4. Select your historical lookback.
5. Read the Downside Test, Upside Potential and Two-Sided Readout.

The weights are automatically normalized, so they do not need to add up to exactly 100%.

### ① Downside Test

**Volatility vs BTC**

Shows how volatile the portfolio was compared with Bitcoin.

- Below 1.00×: Less volatile than BTC
- Around 1.00×: Similar to BTC
- Above 1.00×: More volatile than BTC

**Maximum Drawdown**

Compares the portfolio’s largest historical decline with Bitcoin’s largest decline over the same period.

A portfolio containing more coins can still experience a larger drawdown than Bitcoin.

**Downside Capture**

Measures how the portfolio performed specifically on days when Bitcoin was falling.

- Below 100%: The portfolio lost less than BTC
- Around 100%: The portfolio behaved similarly to BTC
- Above 100%: The portfolio lost more than BTC

**Down-Day Correlation**

Shows how closely the portfolio moved with Bitcoin during Bitcoin’s negative days.

A high correlation means the assets continued moving together when diversification was supposed to provide protection.

### ② Upside Potential

**Upside Capture**

Measures how the portfolio performed on days when Bitcoin was rising.

- Above 100%: The portfolio captured more upside than BTC
- Around 100%: BTC-like upside
- Below 100%: The portfolio captured less upside than BTC

**BTC Beta**

Shows how sensitive the portfolio was to Bitcoin’s movements.

A beta above 1.00 means the portfolio historically moved more aggressively than Bitcoin. This can create additional upside, but also additional downside.

**Capture Asymmetry**

Compares upside capture with downside capture.

- Above 1.00×: More upside captured relative to downside
- Around 1.00×: Similar upside and downside participation
- Below 1.00×: Downside capture dominated

### ③ Two-Sided Readout

The indicator combines the results into a simple portfolio profile, such as:

- Risk Diversifier
- Lower-Risk Mix
- Better Asymmetry
- Higher-Beta Mix
- Upside Amplifier
- Risk Amplifier
- BTC-Like Mix

The chart underneath the table visualizes both sides:

- The gold line shows the portfolio’s upside edge versus Bitcoin.
- The second line shows downside protection.
- Above zero means the portfolio lost less than BTC.
- Below zero means the portfolio amplified Bitcoin’s downside.

When the portfolio captures more upside while also amplifying downside, the indicator highlights a Higher-Beta state.

### What this indicator helps you understand

Diversification inside crypto can reduce the risk of one individual project failing. However, it does not automatically reduce the market risk shared by cryptocurrencies.

If Bitcoin falls and every asset in the portfolio falls even harder, owning more coins did not necessarily make the portfolio safer.

Use this indicator to test the actual historical effect of each coin before calling a portfolio diversified.

### Methodology and limitations

The indicator creates a hypothetical fixed-weight portfolio using aligned daily returns. It assumes daily rebalancing and uses completed daily price data.

It does not include:

- Trading fees
- Slippage
- Taxes
- Liquidity constraints
- Rebalancing costs
- Token-specific fundamental risks

Results are historical and descriptive, not predictive. A favorable result does not guarantee similar future performance.

For educational and research purposes only. Not financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoGameplan

//@version=6

indicator("(CGP) Crypto Diversification Lens", shorttitle="CGP DivRsk", overlay=false, max_bars_back=5000)

// ─────────────────────────────────────────────────────────────────────────────
//  PURPOSE
//  Test both sides of a hypothetical fixed-weight crypto allocation:
//    1. Did holding more tokens reduce historical downside risk versus BTC?
//    2. Did the same mix capture more of BTC's upside?
//
//  The portfolio return is a fixed-weight daily return. It assumes daily
//  rebalancing and is intended for historical risk education, not execution.
//  Apply the indicator to a 1D crypto chart so every sample is one crypto day.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_BENCHMARK = "Benchmark and Sample"
string GROUP_PORTFOLIO = "Hypothetical Allocation"
string GROUP_DISPLAY   = "Display"

benchmark = input.symbol("BINANCE:BTCUSDT", "BTC Benchmark",
     group=GROUP_BENCHMARK,
     tooltip="Bitcoin market used as the common crypto-risk benchmark.")
lookbackDays = input.int(1095, "Rolling Lookback (days)", minval=90, maxval=1825, step=30,
     group=GROUP_BENCHMARK,
     tooltip="Number of aligned daily returns in each measurement. 1095 is about three years.")

symbol1 = input.symbol("BINANCE:BTCUSDT", "Asset 1", inline="asset1", group=GROUP_PORTFOLIO)
weight1 = input.float(40.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset1", group=GROUP_PORTFOLIO,
     tooltip="Weights are normalized automatically. Set a weight to zero to exclude that asset.")

symbol2 = input.symbol("BINANCE:ETHUSDT", "Asset 2", inline="asset2", group=GROUP_PORTFOLIO)
weight2 = input.float(25.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset2", group=GROUP_PORTFOLIO)

symbol3 = input.symbol("BINANCE:SOLUSDT", "Asset 3", inline="asset3", group=GROUP_PORTFOLIO)
weight3 = input.float(15.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset3", group=GROUP_PORTFOLIO)

symbol4 = input.symbol("BINANCE:XRPUSDT", "Asset 4", inline="asset4", group=GROUP_PORTFOLIO)
weight4 = input.float(10.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset4", group=GROUP_PORTFOLIO)

symbol5 = input.symbol("BINANCE:LINKUSDT", "Asset 5", inline="asset5", group=GROUP_PORTFOLIO)
weight5 = input.float(5.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset5", group=GROUP_PORTFOLIO)

symbol6 = input.symbol("BINANCE:AAVEUSDT", "Asset 6", inline="asset6", group=GROUP_PORTFOLIO)
weight6 = input.float(5.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset6", group=GROUP_PORTFOLIO)

symbol7 = input.symbol("BINANCE:AVAXUSDT", "Asset 7", inline="asset7", group=GROUP_PORTFOLIO)
weight7 = input.float(0.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset7", group=GROUP_PORTFOLIO)

symbol8 = input.symbol("BINANCE:ADAUSDT", "Asset 8", inline="asset8", group=GROUP_PORTFOLIO)
weight8 = input.float(0.0, "Weight %", minval=0.0, maxval=100.0, step=1.0, inline="asset8", group=GROUP_PORTFOLIO)

showEdges = input.bool(true, "Show Two-Sided Edge Lines", group=GROUP_DISPLAY,
     tooltip="Gold above zero means more upside capture than BTC. The second line above zero means downside protection; below zero means downside amplification.")
showSpread = input.bool(true, "Show Edge Spread Fill", group=GROUP_DISPLAY,
     tooltip="Fills the distance between the upside edge and downside-protection lines.")
showStateBackground = input.bool(true, "Highlight Higher-Beta State", group=GROUP_DISPLAY,
     tooltip="Adds a faint gold background when upside capture is above BTC while downside protection is below BTC.")
showTable = input.bool(true, "Show Info Table", group=GROUP_DISPLAY,
     tooltip="Shows the current downside test, upside potential, and two-sided readout.")
tablePositionInput = input.string("Top right", "Table Position",
     options=["Top right", "Top left", "Bottom right", "Bottom left"], group=GROUP_DISPLAY,
     tooltip="Moves the CGP results table within the indicator pane.")
tableSizeInput = input.string("Small", "Table Text Size",
     options=["Tiny", "Small", "Normal"], group=GROUP_DISPLAY,
     tooltip="Changes the text size used in the CGP results table.")

// ─────────────────────────────────────────────────────────────────────────────
//  CGP BRAND PALETTE
// ─────────────────────────────────────────────────────────────────────────────
color C_GOLD   = color.new(#ffc906, 0)
color C_GREEN  = color.new(#47ed0b, 0)
color C_RED    = color.new(#ec0c0c, 0)
color C_BG     = color.new(#011e31, 0)
color C_GRAY   = color.new(#f5f5f5, 0)
color C_NAVY   = color.new(#09002B, 0)
color C_BORDER = color.new(#3F2C6B, 0)
color C_PURPLE = color.new(#9B00E8, 0)

tablePosition = tablePositionInput == "Top left" ? position.top_left : tablePositionInput == "Bottom right" ? position.bottom_right : tablePositionInput == "Bottom left" ? position.bottom_left : position.top_right
tableTextSize = tableSizeInput == "Tiny" ? size.tiny : tableSizeInput == "Normal" ? size.normal : size.small

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_ratio(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.00") + "×"

f_corr(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.00")

f_capture_color(float value, bool lowerIsBetter) =>
    na(value) ? C_GRAY : lowerIsBetter ? value < 95.0 ? C_GREEN : value <= 105.0 ? C_GOLD : C_RED : value > 105.0 ? C_GREEN : value >= 95.0 ? C_GOLD : C_RED

f_ratio_color(float value, bool lowerIsBetter) =>
    na(value) ? C_GRAY : lowerIsBetter ? value < 0.95 ? C_GREEN : value <= 1.05 ? C_GOLD : C_RED : value > 1.05 ? C_GREEN : value >= 0.95 ? C_GOLD : C_RED

f_corr_color(float value) =>
    na(value) ? C_GRAY : value < 0.50 ? C_GREEN : value < 0.75 ? C_GOLD : C_RED

f_header(table target, int row, string headerText, txtSize) =>
    table.cell(target, 0, row, headerText,
         text_color=C_GOLD, text_formatting=text.format_bold, text_size=txtSize,
         text_halign=text.align_left, bgcolor=color.new(#3F2C6B, 15))
    table.cell(target, 1, row, "", bgcolor=color.new(#3F2C6B, 15))

f_row(table target, int row, string rowLabel, string rowValue, color valueColor, txtSize) =>
    table.cell(target, 0, row, rowLabel,
         text_color=color.new(#f5f5f5, 15), text_size=txtSize,
         text_halign=text.align_left, bgcolor=color.new(#011e31, 12))
    table.cell(target, 1, row, rowValue,
         text_color=valueColor, text_formatting=text.format_bold, text_size=txtSize,
         text_halign=text.align_right, bgcolor=color.new(#011e31, 12))

// Returns:
// 0 portfolio volatility %, 1 BTC volatility %, 2 volatility multiple,
// 3 correlation, 4 BTC down-day correlation, 5 upside capture %,
// 6 downside capture %, 7 upside/downside capture ratio,
// 8 portfolio max drawdown %, 9 BTC max drawdown %, 10 BTC beta.
f_metrics(array<float> portfolioReturns, array<float> benchmarkReturns) =>
    array<float> result = array.new_float(11, na)
    int n = array.size(portfolioReturns)
    if n >= 60 and n == array.size(benchmarkReturns)
        float sumP = 0.0
        float sumB = 0.0
        float sumP2 = 0.0
        float sumB2 = 0.0
        float sumPB = 0.0

        float downSumP = 0.0
        float downSumB = 0.0
        float downSumP2 = 0.0
        float downSumB2 = 0.0
        float downSumPB = 0.0
        int downCount = 0

        float upReturnP = 0.0
        float upReturnB = 0.0
        float downReturnP = 0.0
        float downReturnB = 0.0

        float equityP = 1.0
        float equityB = 1.0
        float peakP = 1.0
        float peakB = 1.0
        float maxDrawdownP = 0.0
        float maxDrawdownB = 0.0

        for i = 0 to n - 1
            float p = array.get(portfolioReturns, i)
            float b = array.get(benchmarkReturns, i)

            sumP += p
            sumB += b
            sumP2 += p * p
            sumB2 += b * b
            sumPB += p * b

            if b > 0.0
                upReturnP += p
                upReturnB += b
            else if b < 0.0
                downReturnP += p
                downReturnB += b
                downSumP += p
                downSumB += b
                downSumP2 += p * p
                downSumB2 += b * b
                downSumPB += p * b
                downCount += 1

            equityP *= 1.0 + p
            equityB *= 1.0 + b
            peakP := math.max(peakP, equityP)
            peakB := math.max(peakB, equityB)
            maxDrawdownP := math.min(maxDrawdownP, equityP / peakP - 1.0)
            maxDrawdownB := math.min(maxDrawdownB, equityB / peakB - 1.0)

        float nFloat = n
        float meanP = sumP / nFloat
        float meanB = sumB / nFloat
        float varianceP = math.max((sumP2 - nFloat * meanP * meanP) / (nFloat - 1.0), 0.0)
        float varianceB = math.max((sumB2 - nFloat * meanB * meanB) / (nFloat - 1.0), 0.0)
        float covariancePB = (sumPB - nFloat * meanP * meanB) / (nFloat - 1.0)
        float stdevP = math.sqrt(varianceP)
        float stdevB = math.sqrt(varianceB)

        float volatilityP = stdevP * math.sqrt(365.0) * 100.0
        float volatilityB = stdevB * math.sqrt(365.0) * 100.0
        float volatilityMultiple = volatilityB > 0.0 ? volatilityP / volatilityB : na
        float correlation = stdevP > 0.0 and stdevB > 0.0 ? covariancePB / (stdevP * stdevB) : na
        float beta = varianceB > 0.0 ? covariancePB / varianceB : na

        float downCorrelation = na
        if downCount >= 20
            float downN = downCount
            float downMeanP = downSumP / downN
            float downMeanB = downSumB / downN
            float downVarP = math.max((downSumP2 - downN * downMeanP * downMeanP) / (downN - 1.0), 0.0)
            float downVarB = math.max((downSumB2 - downN * downMeanB * downMeanB) / (downN - 1.0), 0.0)
            float downCovariance = (downSumPB - downN * downMeanP * downMeanB) / (downN - 1.0)
            float downStdevP = math.sqrt(downVarP)
            float downStdevB = math.sqrt(downVarB)
            downCorrelation := downStdevP > 0.0 and downStdevB > 0.0 ? downCovariance / (downStdevP * downStdevB) : na

        float upsideCapture = upReturnB > 0.0 ? upReturnP / upReturnB * 100.0 : na
        float downsideCapture = downReturnB < 0.0 ? downReturnP / downReturnB * 100.0 : na
        float captureAsymmetry = not na(upsideCapture) and not na(downsideCapture) and downsideCapture > 0.0 ? upsideCapture / downsideCapture : na

        array.set(result, 0, volatilityP)
        array.set(result, 1, volatilityB)
        array.set(result, 2, volatilityMultiple)
        array.set(result, 3, correlation)
        array.set(result, 4, downCorrelation)
        array.set(result, 5, upsideCapture)
        array.set(result, 6, downsideCapture)
        array.set(result, 7, captureAsymmetry)
        array.set(result, 8, maxDrawdownP * 100.0)
        array.set(result, 9, maxDrawdownB * 100.0)
        array.set(result, 10, beta)
    result

f_risk_result(float volatilityMultiple, float downsideCapture, float portfolioDrawdown, float benchmarkDrawdown) =>
    int protectionVotes = (not na(volatilityMultiple) and volatilityMultiple < 1.0 ? 1 : 0) + (not na(downsideCapture) and downsideCapture < 100.0 ? 1 : 0) + (not na(portfolioDrawdown) and not na(benchmarkDrawdown) and portfolioDrawdown > benchmarkDrawdown ? 1 : 0)
    protectionVotes >= 2 ? "REDUCED" : protectionVotes == 1 ? "MIXED" : "NOT REDUCED"

f_upside_result(float upsideCapture) =>
    na(upsideCapture) ? "COLLECTING" : upsideCapture > 105.0 ? "AMPLIFIED" : upsideCapture < 95.0 ? "MUTED" : "BTC-LIKE"

f_profile(float volatilityMultiple, float upsideCapture, float downsideCapture, float portfolioDrawdown, float benchmarkDrawdown, float overallCorrelation) =>
    string riskResult = f_risk_result(volatilityMultiple, downsideCapture, portfolioDrawdown, benchmarkDrawdown)
    bool upsideAmplified = not na(upsideCapture) and upsideCapture > 105.0
    bool downsideAmplified = not na(downsideCapture) and downsideCapture > 105.0
    bool lowerCommonFactor = not na(overallCorrelation) and overallCorrelation < 0.75
    upsideAmplified and downsideAmplified ? "HIGHER-BETA MIX" : riskResult == "REDUCED" and lowerCommonFactor ? "RISK DIVERSIFIER" : riskResult == "REDUCED" and upsideAmplified ? "BETTER ASYMMETRY" : riskResult == "REDUCED" ? "LOWER-RISK MIX" : upsideAmplified ? "UPSIDE AMPLIFIER" : downsideAmplified ? "RISK AMPLIFIER" : "BTC-LIKE MIX"

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIRMED DAILY DATA
//  close[1] with lookahead_on returns the last completed daily close and avoids
//  using an unfinished daily bar in the historical sample.
// ─────────────────────────────────────────────────────────────────────────────
btcClose = request.security(benchmark, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close1 = request.security(symbol1, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close2 = request.security(symbol2, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close3 = request.security(symbol3, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close4 = request.security(symbol4, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close5 = request.security(symbol5, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close6 = request.security(symbol6, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close7 = request.security(symbol7, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)
close8 = request.security(symbol8, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true, calc_bars_count=5000)

float weightSum = weight1 + weight2 + weight3 + weight4 + weight5 + weight6 + weight7 + weight8
int activeAssets = (weight1 > 0.0 ? 1 : 0) + (weight2 > 0.0 ? 1 : 0) + (weight3 > 0.0 ? 1 : 0) + (weight4 > 0.0 ? 1 : 0) + (weight5 > 0.0 ? 1 : 0) + (weight6 > 0.0 ? 1 : 0) + (weight7 > 0.0 ? 1 : 0) + (weight8 > 0.0 ? 1 : 0)

bool chartIsDailyCrypto = timeframe.isdaily and timeframe.multiplier == 1 and syminfo.type == "crypto"
bool currentPricesValid = weightSum > 0.0 and not na(btcClose) and (weight1 <= 0.0 or not na(close1)) and (weight2 <= 0.0 or not na(close2)) and (weight3 <= 0.0 or not na(close3)) and (weight4 <= 0.0 or not na(close4)) and (weight5 <= 0.0 or not na(close5)) and (weight6 <= 0.0 or not na(close6)) and (weight7 <= 0.0 or not na(close7)) and (weight8 <= 0.0 or not na(close8))

var float previousBtc = na
var float previous1 = na
var float previous2 = na
var float previous3 = na
var float previous4 = na
var float previous5 = na
var float previous6 = na
var float previous7 = na
var float previous8 = na

var array<float> portfolioReturns = array.new_float()
var array<float> benchmarkReturns = array.new_float()

var float portfolioVolatility = na
var float benchmarkVolatility = na
var float volatilityMultiple = na
var float correlation = na
var float downsideCorrelation = na
var float upsideCapture = na
var float downsideCapture = na
var float captureAsymmetry = na
var float portfolioMaxDrawdown = na
var float benchmarkMaxDrawdown = na
var float btcBeta = na

bool previousPricesValid = not na(previousBtc) and (weight1 <= 0.0 or not na(previous1)) and (weight2 <= 0.0 or not na(previous2)) and (weight3 <= 0.0 or not na(previous3)) and (weight4 <= 0.0 or not na(previous4)) and (weight5 <= 0.0 or not na(previous5)) and (weight6 <= 0.0 or not na(previous6)) and (weight7 <= 0.0 or not na(previous7)) and (weight8 <= 0.0 or not na(previous8))

if chartIsDailyCrypto and currentPricesValid
    if previousPricesValid
        float portfolioReturn = (weight1 > 0.0 ? weight1 / weightSum * (close1 / previous1 - 1.0) : 0.0) + (weight2 > 0.0 ? weight2 / weightSum * (close2 / previous2 - 1.0) : 0.0) + (weight3 > 0.0 ? weight3 / weightSum * (close3 / previous3 - 1.0) : 0.0) + (weight4 > 0.0 ? weight4 / weightSum * (close4 / previous4 - 1.0) : 0.0) + (weight5 > 0.0 ? weight5 / weightSum * (close5 / previous5 - 1.0) : 0.0) + (weight6 > 0.0 ? weight6 / weightSum * (close6 / previous6 - 1.0) : 0.0) + (weight7 > 0.0 ? weight7 / weightSum * (close7 / previous7 - 1.0) : 0.0) + (weight8 > 0.0 ? weight8 / weightSum * (close8 / previous8 - 1.0) : 0.0)
        float benchmarkReturn = btcClose / previousBtc - 1.0

        if not na(portfolioReturn) and not na(benchmarkReturn)
            array.push(portfolioReturns, portfolioReturn)
            array.push(benchmarkReturns, benchmarkReturn)
            if array.size(portfolioReturns) > lookbackDays
                array.shift(portfolioReturns)
                array.shift(benchmarkReturns)

            array<float> metrics = f_metrics(portfolioReturns, benchmarkReturns)
            portfolioVolatility := array.get(metrics, 0)
            benchmarkVolatility := array.get(metrics, 1)
            volatilityMultiple := array.get(metrics, 2)
            correlation := array.get(metrics, 3)
            downsideCorrelation := array.get(metrics, 4)
            upsideCapture := array.get(metrics, 5)
            downsideCapture := array.get(metrics, 6)
            captureAsymmetry := array.get(metrics, 7)
            portfolioMaxDrawdown := array.get(metrics, 8)
            benchmarkMaxDrawdown := array.get(metrics, 9)
            btcBeta := array.get(metrics, 10)

    previousBtc := btcClose
    previous1 := close1
    previous2 := close2
    previous3 := close3
    previous4 := close4
    previous5 := close5
    previous6 := close6
    previous7 := close7
    previous8 := close8

// ─────────────────────────────────────────────────────────────────────────────
//  TWO-SIDED VISUAL
//  Positive upside edge: the portfolio captured more upside than BTC.
//  Positive downside protection: the portfolio lost less on BTC-down days.
// ─────────────────────────────────────────────────────────────────────────────
float upsideEdge = not na(upsideCapture) ? upsideCapture - 100.0 : na
float downsideProtection = not na(downsideCapture) ? 100.0 - downsideCapture : na
color downsideLineColor = na(downsideProtection) ? C_GRAY : downsideProtection >= 0.0 ? color.from_gradient(downsideProtection, 0.0, 50.0, C_GOLD, C_GREEN) : color.from_gradient(downsideProtection, -50.0, 0.0, C_RED, C_GOLD)

hline(0, "BTC Baseline", color=color.new(#f5f5f5, 45), linestyle=hline.style_dashed, linewidth=1)
hline(25, "+25% Edge", color=color.new(#f5f5f5, 82), linestyle=hline.style_dotted, linewidth=1)
hline(-25, "-25% Edge", color=color.new(#f5f5f5, 82), linestyle=hline.style_dotted, linewidth=1)

upsidePlot = plot(showEdges ? upsideEdge : na, "Upside Edge vs BTC", color=C_GOLD, linewidth=2)
downsidePlot = plot(showEdges ? downsideProtection : na, "Downside Protection vs BTC", color=downsideLineColor, linewidth=2)
fill(upsidePlot, downsidePlot, color=showSpread ? color.new(#ffc906, 90) : na, title="Two-Sided Edge Spread")

bool higherBetaState = not na(upsideEdge) and not na(downsideProtection) and upsideEdge > 0.0 and downsideProtection < 0.0
bgcolor(showStateBackground and higherBetaState ? color.new(#ffc906, 93) : na, title="Higher-Beta Mix")

// ─────────────────────────────────────────────────────────────────────────────
//  INFO TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table lens = table.new(tablePosition, 2, 19,
     bgcolor=color.new(#011e31, 12),
     frame_color=C_BORDER, frame_width=1,
     border_color=color.new(#3F2C6B, 25), border_width=1)

if showTable and barstate.islast
    int sampleSize = array.size(portfolioReturns)

    table.cell(lens, 0, 0, "◆  DIVERSIFICATION LENS",
         text_color=C_GOLD, text_formatting=text.format_bold, text_size=tableTextSize,
         text_halign=text.align_left, bgcolor=C_NAVY,
         tooltip="Historical risk and upside comparison by Crypto Gameplan.")
    table.cell(lens, 1, 0, str.tostring(activeAssets) + " assets",
         text_color=color.new(#00F1FF, 0), text_formatting=text.format_bold, text_size=tableTextSize,
         text_halign=text.align_right, bgcolor=C_NAVY)

    table.cell(lens, 0, 1, "Fixed weights, daily rebalance",
         text_color=color.new(#f5f5f5, 35), text_size=size.tiny,
         text_halign=text.align_left, bgcolor=color.new(#011e31, 12))
    table.cell(lens, 1, 1, "n = " + str.tostring(sampleSize),
         text_color=color.new(#f5f5f5, 35), text_size=size.tiny,
         text_halign=text.align_right, bgcolor=color.new(#011e31, 12))

    if not chartIsDailyCrypto
        f_header(lens, 2, "SETUP NEEDED", tableTextSize)
        f_row(lens, 3, "Chart", "USE 1D CRYPTO", C_RED, tableTextSize)
        f_row(lens, 4, "Reason", "Daily cadence", C_GOLD, tableTextSize)
    else if weightSum <= 0.0
        f_header(lens, 2, "SETUP NEEDED", tableTextSize)
        f_row(lens, 3, "Weights", "ADD A WEIGHT", C_RED, tableTextSize)
    else if not currentPricesValid
        f_header(lens, 2, "DATA CHECK", tableTextSize)
        f_row(lens, 3, "Symbols", "CHECK FEEDS", C_RED, tableTextSize)
        f_row(lens, 4, "Tip", "Use valid pairs", C_GOLD, tableTextSize)
    else if sampleSize < 60
        f_header(lens, 2, "COLLECTING DATA", tableTextSize)
        f_row(lens, 3, "Aligned days", str.tostring(sampleSize) + " / 60", C_GOLD, tableTextSize)
        f_row(lens, 4, "Target", str.tostring(lookbackDays) + " days", C_GRAY, tableTextSize)
    else
        string riskResult = f_risk_result(volatilityMultiple, downsideCapture, portfolioMaxDrawdown, benchmarkMaxDrawdown)
        string upsideResult = f_upside_result(upsideCapture)
        string profile = f_profile(volatilityMultiple, upsideCapture, downsideCapture, portfolioMaxDrawdown, benchmarkMaxDrawdown, correlation)
        color riskResultColor = riskResult == "REDUCED" ? C_GREEN : riskResult == "MIXED" ? C_GOLD : C_RED
        color upsideResultColor = upsideResult == "AMPLIFIED" ? C_GREEN : upsideResult == "BTC-LIKE" ? C_GOLD : C_RED
        color profileColor = profile == "HIGHER-BETA MIX" ? C_GOLD : profile == "RISK DIVERSIFIER" or profile == "BETTER ASYMMETRY" or profile == "LOWER-RISK MIX" ? C_GREEN : profile == "RISK AMPLIFIER" ? C_RED : C_GRAY

        f_header(lens, 2, "① DOWNSIDE TEST", tableTextSize)
        f_row(lens, 3, "Ann. volatility", f_pct(portfolioVolatility) + " / " + f_pct(benchmarkVolatility), f_ratio_color(volatilityMultiple, true), tableTextSize)
        f_row(lens, 4, "Volatility vs BTC", f_ratio(volatilityMultiple), f_ratio_color(volatilityMultiple, true), tableTextSize)
        f_row(lens, 5, "Max drawdown", f_pct(portfolioMaxDrawdown) + " / " + f_pct(benchmarkMaxDrawdown), portfolioMaxDrawdown > benchmarkMaxDrawdown ? C_GREEN : C_RED, tableTextSize)
        f_row(lens, 6, "Downside capture", f_pct(downsideCapture), f_capture_color(downsideCapture, true), tableTextSize)
        f_row(lens, 7, "Down-day correlation", f_corr(downsideCorrelation), f_corr_color(downsideCorrelation), tableTextSize)
        f_row(lens, 8, "Risk result", riskResult, riskResultColor, tableTextSize)

        f_header(lens, 9, "② UPSIDE POTENTIAL", tableTextSize)
        f_row(lens, 10, "Upside capture", f_pct(upsideCapture), f_capture_color(upsideCapture, false), tableTextSize)
        f_row(lens, 11, "BTC beta", f_corr(btcBeta), f_ratio_color(btcBeta, false), tableTextSize)
        f_row(lens, 12, "Capture asymmetry", f_ratio(captureAsymmetry), f_ratio_color(captureAsymmetry, false), tableTextSize)
        f_row(lens, 13, "Upside result", upsideResult, upsideResultColor, tableTextSize)

        f_header(lens, 14, "③ TWO-SIDED READOUT", tableTextSize)
        f_row(lens, 15, "Profile", profile, profileColor, tableTextSize)
        f_row(lens, 16, "Overall BTC corr.", f_corr(correlation), f_corr_color(correlation), tableTextSize)
        f_row(lens, 17, "Input weights", str.tostring(weightSum, "#.#") + "% normalized", math.abs(weightSum - 100.0) < 0.01 ? C_GRAY : C_GOLD, tableTextSize)

        table.cell(lens, 0, 18, "CGP",
             text_color=C_PURPLE, text_formatting=text.format_bold, text_size=size.tiny,
             text_halign=text.align_left, bgcolor=C_NAVY)
        table.cell(lens, 1, 18, "Historical, not predictive",
             text_color=color.new(#f5f5f5, 40), text_size=size.tiny,
             text_halign=text.align_right, bgcolor=C_NAVY)
````
