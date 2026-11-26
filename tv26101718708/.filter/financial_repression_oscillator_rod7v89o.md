# Financial Repression Oscillator

- url: https://www.tradingview.com/script/ROd7v89o-Financial-Repression-Oscillator/
- type: indicator
- pine_id: PUB;944f48337789432ca717204bff4772b9
- version: 1.0

## Description

The Financial Repression Oscillator is a macro-regime indicator designed to help visualize whether current conditions are more consistent with a restrictive real-rate environment or a financial-repression-like environment.

It combines several public FRED macroeconomic series into a single bounded oscillator from 0 to 100. The goal is not to generate trade signals, but to provide a compact way to monitor real rates, inflation pressure, debt burden, and Federal Reserve balance-sheet conditions together.

[b]Why this can be useful[/b]

Macro conditions can change the meaning of “safe” assets.

When real rates are positive, cash-like instruments and short-duration fixed income may offer meaningful real returns. When real rates are negative or falling while inflation and debt pressure remain elevated, cash and nominal fixed-income assets may lose purchasing power in real terms.

This indicator is intended to make those regime conditions easier to monitor in one place.

[b]General interpretation[/b]

0-25     Restrictive / not repressive
25-40    Mildly restrictive
40-60    Neutral / mixed
60-75    Repression-like
75-100   Strongly repression-like

These zones are intended as a framework for macro context, not as automatic buy or sell signals.

[b]What the indicator tracks[/b]

The oscillator uses six components:

1. 10-Year Real Yield
Series: FRED:DFII10
This is the 10-year Treasury Inflation-Protected Securities real yield. It is used as a market-based measure of long-term real interest rates.
Higher positive real yields generally suggest a more restrictive real-rate environment. Lower or negative real yields are more consistent with financial-repression-like conditions.

2. 3-Month Real Rate
Series: FRED:DTB3 minus CPI YoY
This compares the 3-month Treasury bill yield to year-over-year CPI inflation.
It helps show whether short-term cash-like instruments are providing a positive or negative real return relative to inflation.

3. Real Fed Funds Rate
Series: FRED:FEDFUNDS minus CPI YoY
This compares the effective federal funds rate to year-over-year CPI inflation.
It provides a simple estimate of whether short-term monetary policy is restrictive or accommodative after inflation.

4. CPI Inflation
Series: FRED:CPIAUCSL
Inflation is included because financial repression is usually most relevant when inflation is elevated relative to interest rates.
The script calculates CPI year-over-year inside the monthly data request so that the calculation remains consistent when the indicator is viewed on daily, weekly, or monthly charts.

5. Federal Debt to GDP
Series: FRED:GFDEGDQ188S
Debt to GDP is included as a structural pressure variable.
High debt levels do not prove that financial repression is occurring, but they may increase the policy incentive to maintain lower real borrowing costs over time.

6. Federal Reserve Total Assets
Series: FRED:WALCL
Federal Reserve total assets are used as a broad proxy for the size of the central bank’s balance sheet.
A larger balance sheet may indicate a greater central-bank footprint in financial markets, though it should not be interpreted by itself as proof of financial repression.

[b]How the scoring works[/b]

The indicator uses a hybrid scoring model.

Each component is scored using two methods:

[b]Absolute threshold scoring[/b]

Absolute thresholds are used so that the oscillator does not label an environment as strongly repressive simply because a value is low relative to recent history.

For example, a positive real rate should not automatically score as maximum financial repression just because it has declined from a recent high.

[b]Percentile pressure scoring[/b]
A smaller percentile component compares each series to its own recent history over a 120-month window.

This helps the oscillator respond when conditions are deteriorating or improving relative to the recent macro regime.

[b]Weighted blend[/b]

The real-rate components receive the largest weights because suppressed real yields are central to the concept of financial repression.

The debt and Federal Reserve asset components are included as structural context, but they are not intended to dominate the reading by themselves.

[b]How to use it[/b]

This indicator is best used as a macro context tool on weekly or monthly charts.
Possible uses include:

[list]
[*]Monitoring whether real-rate conditions are becoming more or less restrictive
[*]Comparing current macro conditions to prior regimes
[*]Adding context to cash, bond, equity, commodity, gold, or Bitcoin allocation decisions
[*]Watching for transitions between cash-friendly and negative-real-rate environments
[*]Supplementing other macro tools such as yield curves, credit spreads, liquidity indicators, valuation metrics, and market breadth
[/list]

[b]Important limitations[/b]

This indicator is not a trading system.

It does not issue buy or sell signals, and it does not attempt to predict short-term market direction. The underlying data comes from FRED and updates at different frequencies. Some components update daily, while others update monthly or quarterly, and macroeconomic data may be revised.

The oscillator should be interpreted as a broad macro-regime estimate, not as a precise timing model.

A high debt score or a large Federal Reserve balance sheet score does not, by itself, mean financial repression is occurring. The most important readings come from the combination of real yields, inflation, short real rates, and structural debt pressure.

[b]Practical reading[/b]

When the oscillator is low, real-rate conditions are generally more restrictive and cash-like assets may be more competitive in real terms.

When the oscillator rises, conditions may be shifting toward a more inflationary or repression-like environment, especially if real yields are falling while inflation and debt pressure remain elevated.

The most meaningful signals are usually changes in regime over time rather than any single daily reading.

## Source Code

````pine
//@version=6
indicator("Financial Repression Oscillator", shorttitle="Financial Repression Oscillator", overlay=false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hardcoded Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tfMacro = "M"

symReal10Y    = "FRED:DFII10"       // 10Y TIPS Real Yield
symTBill3M    = "FRED:DTB3"         // 3M T-Bill Yield
symFedFunds   = "FRED:FEDFUNDS"     // Fed Funds Rate
symCPI        = "FRED:CPIAUCSL"     // CPI Index
symDebtGDP    = "FRED:GFDEGDQ188S"  // Federal Debt / GDP
symFedAssets  = "FRED:WALCL"        // Fed Total Assets

lookbackRank = 120

// Weights.
// Real-rate components dominate because active financial repression requires
// suppressed real yields, not just high debt.
wReal10Y     = 30.0
wShortReal   = 30.0
wFedReal     = 20.0
wInflation   = 5.0
wDebt        = 10.0
wFedAssets   = 5.0

smoothLen    = 3
momentumLen  = 6

showTable    = true
showZones    = true
showMomentum = false

// Hybrid scoring blend.
// Absolute threshold score should dominate.
// Percentile score helps detect regime pressure / deterioration.
absoluteWeight   = 0.75
percentileWeight = 0.25

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

safeDiv(a, b) =>
    b == 0 or na(b) ? na : a / b

clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

rankScore(src, len, inverse) =>
    r = ta.percentrank(src, len)
    inverse ? 100 - r : r

fmtPct(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.00") + "%"

fmtScore(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.0")

fmtSigned(x) =>
    na(x) ? "n/a" : str.tostring(x, "+#.0;-#.0")

fmtTrillions(x) =>
    na(x) ? "n/a" : "$" + str.tostring(x, "#.00") + "T"

// Linear scale helper.
// Maps x between xGood and xBad into 0–100.
// For repression scoring:
// - xGood = restrictive / not repressive
// - xBad  = strongly repressive
scoreLinear(x, xGood, xBad) =>
    na(x) ? na : clamp(100 * (x - xGood) / (xBad - xGood), 0, 100)

// Inverse linear scale helper.
// Higher x = less repressive.
// Lower x = more repressive.
scoreInverseLinear(x, xRestrictive, xRepressive) =>
    na(x) ? na : clamp(100 * (xRestrictive - x) / (xRestrictive - xRepressive), 0, 100)

// Hybrid score combines:
// 1. Absolute threshold score.
// 2. Percentile pressure score.
hybridScore(absScore, pctScore) =>
    na(absScore) and na(pctScore) ? na :
     na(absScore) ? pctScore :
     na(pctScore) ? absScore :
     absoluteWeight * absScore + percentileWeight * pctScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Data Pulls
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Important:
// CPI YoY is calculated INSIDE the monthly security call.
// Fed assets are also converted INSIDE the security call.
// FRED:WALCL is reported in millions of dollars.
// Example: 6,699,950 million = $6.70T.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

real10Y  = request.security(symReal10Y,  tfMacro, close, ignore_invalid_symbol=true)
tbill3M  = request.security(symTBill3M,  tfMacro, close, ignore_invalid_symbol=true)
fedFunds = request.security(symFedFunds, tfMacro, close, ignore_invalid_symbol=true)
debtGDP  = request.security(symDebtGDP,  tfMacro, close, ignore_invalid_symbol=true)

fedAssetsT = request.security(
     symFedAssets,
     tfMacro,
     close / 1000000.0,
     ignore_invalid_symbol=true)

cpiYoY = request.security(
     symCPI,
     tfMacro,
     100 * (close / close[12] - 1),
     ignore_invalid_symbol=true)

// Real short rates.
realTBill3M = tbill3M - cpiYoY
realFedRate = fedFunds - cpiYoY

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Absolute Threshold Scores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Repression-like threshold logic:
//
// 10Y Real Yield:
//   +2.0% or higher = 0 repression
//   0.0%            = moderate/high repression
//   -1.0% or lower  = 100 repression
//
// 3M Real / Fed Real:
//   +1.5% or higher = 0 repression
//   0.0%            = moderate repression
//   -2.0% or lower  = 100 repression
//
// CPI YoY:
//   2.0% or lower   = 0 inflation pressure
//   6.0% or higher  = 100 inflation pressure
//
// Debt/GDP:
//   60% or lower    = 0 structural repression incentive
//   140% or higher  = 100 structural repression incentive
//
// Fed Assets:
//   $3T or lower    = 0 pressure
//   $9T or higher   = 100 pressure
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

absScoreReal10Y    = scoreInverseLinear(real10Y,      2.0, -1.0)
absScoreShortReal  = scoreInverseLinear(realTBill3M,  1.5, -2.0)
absScoreFedReal    = scoreInverseLinear(realFedRate,  1.5, -2.0)
absScoreInflation  = scoreLinear(cpiYoY,              2.0,  6.0)
absScoreDebt       = scoreLinear(debtGDP,            60.0, 140.0)
absScoreFedAssets  = scoreLinear(fedAssetsT,          3.0,  9.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Percentile Pressure Scores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// These help detect regime deterioration relative to the last 120 months.
// They are blended at a smaller weight so they do not dominate absolute reality.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pctScoreReal10Y    = rankScore(real10Y,       lookbackRank, true)
pctScoreShortReal  = rankScore(realTBill3M,   lookbackRank, true)
pctScoreFedReal    = rankScore(realFedRate,   lookbackRank, true)
pctScoreInflation  = rankScore(cpiYoY,        lookbackRank, false)
pctScoreDebt       = rankScore(debtGDP,       lookbackRank, false)
pctScoreFedAssets  = rankScore(fedAssetsT,    lookbackRank, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Final Component Scores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

scoreReal10Y    = hybridScore(absScoreReal10Y,   pctScoreReal10Y)
scoreShortReal  = hybridScore(absScoreShortReal, pctScoreShortReal)
scoreFedReal    = hybridScore(absScoreFedReal,   pctScoreFedReal)
scoreInflation  = hybridScore(absScoreInflation, pctScoreInflation)
scoreDebt       = hybridScore(absScoreDebt,      pctScoreDebt)
scoreFedAssets  = hybridScore(absScoreFedAssets, pctScoreFedAssets)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FRRO Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

totalWeight = wReal10Y + wShortReal + wFedReal + wInflation + wDebt + wFedAssets

rawFRRO = safeDiv(
     scoreReal10Y   * wReal10Y +
     scoreShortReal * wShortReal +
     scoreFedReal   * wFedReal +
     scoreInflation * wInflation +
     scoreDebt      * wDebt +
     scoreFedAssets * wFedAssets,
     totalWeight)

frro = ta.sma(rawFRRO, smoothLen)

// Momentum:
// 6M delta is shown in the table.
// Optional momentum line is centered at 50:
// Above 50 = repression pressure rising.
// Below 50 = repression pressure falling.
frroDelta = frro - frro[momentumLen]
frroMomentum = 50 + frroDelta
frroMomentumClamped = clamp(frroMomentum, 0, 100)
frroMomentum3 = ta.sma(frro - frro[1], 3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Regime Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

strongRepression = frro >= 75
repression       = frro >= 60 and frro < 75
neutral          = frro >= 40 and frro < 60
restrictive      = frro < 40

regimeText =
     strongRepression ? "Strong Repression" :
     repression       ? "Repression-Like" :
     neutral          ? "Neutral / Mixed" :
                         "Restrictive / Not Repressive"

regimeColor =
     strongRepression ? color.rgb(170, 45, 45) :
     repression       ? color.rgb(220, 135, 40) :
     neutral          ? color.rgb(205, 205, 55) :
                         color.rgb(55, 150, 95)

momentumText =
     frroMomentum3 > 0 ? "Pressure Up" :
     frroMomentum3 < 0 ? "Pressure Down" :
                         "Flat"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Main oscillator line.
plot(frro, "FRRO", color=regimeColor, linewidth=3)

// Hidden raw unsmoothed FRRO for Data Window only.
plot(rawFRRO, "Raw FRRO", color=color.new(color.gray, 75), linewidth=1, display=display.none)

// Optional 6M momentum line.
// Hidden by default because it can visually compete with the main oscillator.
plot(
     showMomentum ? frroMomentumClamped : na,
     "6M Momentum",
     color=color.new(color.white, 35),
     linewidth=2)

// Regime guide lines.
hline(75, "Strong Repression", color=color.new(color.red, 20), linestyle=hline.style_dashed)
hline(60, "Repression-Like", color=color.new(color.orange, 20), linestyle=hline.style_dashed)
hline(50, "Neutral", color=color.new(color.white, 75), linestyle=hline.style_dotted)
hline(40, "Neutral Lower Bound", color=color.new(color.gray, 55), linestyle=hline.style_dashed)
hline(25, "Restrictive", color=color.new(color.green, 40), linestyle=hline.style_dashed)

// Background regime zones.
bgcolor(showZones and strongRepression ? color.new(color.red, 85) : na)
bgcolor(showZones and repression       ? color.new(color.orange, 88) : na)
bgcolor(showZones and neutral          ? color.new(color.yellow, 92) : na)
bgcolor(showZones and restrictive      ? color.new(color.green, 90) : na)

// Hidden component plots for Data Window only.
plot(scoreReal10Y,    "Score: 10Y Real Yield", color=color.new(color.purple, 70), display=display.none)
plot(scoreShortReal,  "Score: 3M Real Rate", color=color.new(color.blue, 70), display=display.none)
plot(scoreFedReal,    "Score: Fed Real Rate", color=color.new(color.aqua, 70), display=display.none)
plot(scoreInflation,  "Score: Inflation", color=color.new(color.red, 70), display=display.none)
plot(scoreDebt,       "Score: Debt/GDP", color=color.new(color.orange, 70), display=display.none)
plot(scoreFedAssets,  "Score: Fed Assets", color=color.new(color.gray, 70), display=display.none)

plot(absScoreReal10Y,    "Abs Score: 10Y Real Yield", color=color.new(color.purple, 80), display=display.none)
plot(absScoreShortReal,  "Abs Score: 3M Real Rate", color=color.new(color.blue, 80), display=display.none)
plot(absScoreFedReal,    "Abs Score: Fed Real Rate", color=color.new(color.aqua, 80), display=display.none)
plot(absScoreInflation,  "Abs Score: Inflation", color=color.new(color.red, 80), display=display.none)
plot(absScoreDebt,       "Abs Score: Debt/GDP", color=color.new(color.orange, 80), display=display.none)
plot(absScoreFedAssets,  "Abs Score: Fed Assets", color=color.new(color.gray, 80), display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(ta.crossover(frro, 60), "FRRO crosses into repression-like regime", "FRRO crossed above 60: repression-like regime.")
alertcondition(ta.crossover(frro, 75), "FRRO crosses into strong repression regime", "FRRO crossed above 75: strong financial repression regime.")
alertcondition(ta.crossunder(frro, 40), "FRRO exits repression / turns restrictive", "FRRO crossed below 40: restrictive / not repressive regime.")
alertcondition(ta.crossover(frroMomentumClamped, 50), "FRRO momentum turns positive", "FRRO momentum crossed above 50: repression pressure rising.")
alertcondition(ta.crossunder(frroMomentumClamped, 50), "FRRO momentum turns negative", "FRRO momentum crossed below 50: repression pressure falling.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table t = table.new(position.top_right, 3, 10, border_width=1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "FRRO", text_color=color.white, bgcolor=regimeColor)
    table.cell(t, 1, 0, fmtScore(frro), text_color=color.white, bgcolor=regimeColor)
    table.cell(t, 2, 0, regimeText, text_color=color.white, bgcolor=regimeColor)

    table.cell(t, 0, 1, "10Y Real", text_color=color.white)
    table.cell(t, 1, 1, fmtPct(real10Y), text_color=color.white)
    table.cell(t, 2, 1, fmtScore(scoreReal10Y), text_color=color.white)

    table.cell(t, 0, 2, "3M Real", text_color=color.white)
    table.cell(t, 1, 2, fmtPct(realTBill3M), text_color=color.white)
    table.cell(t, 2, 2, fmtScore(scoreShortReal), text_color=color.white)

    table.cell(t, 0, 3, "Fed Real", text_color=color.white)
    table.cell(t, 1, 3, fmtPct(realFedRate), text_color=color.white)
    table.cell(t, 2, 3, fmtScore(scoreFedReal), text_color=color.white)

    table.cell(t, 0, 4, "CPI YoY", text_color=color.white)
    table.cell(t, 1, 4, fmtPct(cpiYoY), text_color=color.white)
    table.cell(t, 2, 4, fmtScore(scoreInflation), text_color=color.white)

    table.cell(t, 0, 5, "Debt/GDP", text_color=color.white)
    table.cell(t, 1, 5, fmtPct(debtGDP), text_color=color.white)
    table.cell(t, 2, 5, fmtScore(scoreDebt), text_color=color.white)

    table.cell(t, 0, 6, "Fed Assets", text_color=color.white)
    table.cell(t, 1, 6, fmtTrillions(fedAssetsT), text_color=color.white)
    table.cell(t, 2, 6, fmtScore(scoreFedAssets), text_color=color.white)

    table.cell(t, 0, 7, "6M Δ", text_color=color.white)
    table.cell(t, 1, 7, fmtSigned(frroDelta), text_color=color.white)
    table.cell(t, 2, 7, frroDelta > 0 ? "Rising" : frroDelta < 0 ? "Falling" : "Flat", text_color=color.white)

    table.cell(t, 0, 8, "Mode", text_color=color.white)
    table.cell(t, 1, 8, tfMacro, text_color=color.white)
    table.cell(t, 2, 8, str.tostring(lookbackRank) + " mo rank", text_color=color.white)

    table.cell(t, 0, 9, "Signal", text_color=color.white)
    table.cell(t, 1, 9, frro > frro[1] ? "Rising" : frro < frro[1] ? "Falling" : "Flat", text_color=color.white)
    table.cell(t, 2, 9, momentumText, text_color=color.white)
````
