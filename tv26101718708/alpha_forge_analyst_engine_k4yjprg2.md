# Alpha Forge Analyst Engine

- url: https://www.tradingview.com/script/K4yjPrg2-Alpha-Forge-Analyst-Engine/
- type: indicator
- pine_id: PUB;effe27d4c9e745a099af09fbd1c9ce99
- version: 1.0

## Description

Analyst conviction. Target-price reality. Valuation context. Directly on your chart.

The Analyst Engine is a market intelligence overlay designed to answer one important question:

Do analysts still support this stock at the current chart price?

Most traders see analyst ratings like Buy, Hold, or Strong Buy and stop there. But ratings alone are not enough. A stock can have bullish analyst coverage and still be trading near, or even above, the average analyst target.

Analyst Engine combines analyst recommendations, price targets, current chart price, target upside, median target confirmation, target range risk, and valuation context into one clean dashboard.

This is not a buy/sell signal system. It is a decision-support layer built to help traders understand whether analyst support still makes sense at today’s price.

What It Does

Analyst Engine evaluates:

Analyst recommendation strength
Buy consensus percentage
Total analyst coverage
Current price vs average target
Current price vs median target
High / low target range
Target upside and median upside
Target range quality
Low-target downside risk
Analyst target confidence
Basic valuation context such as P/E, P/S, and EPS when available

The result is a clear readout showing whether the stock is supported, volatile, cautious, over target, or lacking available Pine-accessible analyst data.

Core Question
Do analysts still support this stock at the current chart price?

The indicator does not simply show that analysts are bullish.

It checks whether that bullishness still matters relative to the live chart price.

Example:

A stock may have 90% buy consensus, but if price is already above the average analyst target, the engine can flag it as:

Over Target

Another stock may have strong upside, but if analyst targets are extremely spread out, the engine may classify it as:

Support / Volatile

That is the edge of this tool.

Key Features
Analyst Recommendation Engine

Displays available TradingView Pine-accessible analyst recommendation data, including:

Strong Buy
Buy
Hold
Sell / Strong Sell
Total coverage
Buy consensus %

This helps separate truly strong analyst support from mixed or weak coverage.

Target Price Reality Check

The engine compares the live chart price against:

Average analyst target
Median analyst target
High analyst target
Low analyst target

It then calculates:

Average target upside
Median target upside
Current price zone
Over-target condition
Low-target downside risk

This helps avoid blindly trusting ratings when price has already moved too far.

Median Target Confirmation

v2.0 uses the median target to help determine whether the average target is supported by the broader analyst group or potentially distorted by outliers.

For example:

Median confirms upside
The average and median targets are reasonably aligned.

Split target structure
Average and median targets disagree, or the high/low target range is extremely wide.

This adds an extra layer of quality control to analyst target data.

Target Confidence Layer

Not all analyst targets are equally useful.

The indicator evaluates target structure and classifies confidence as:

High
Medium
Volatile
Split

A stock with huge upside but a massive high/low target spread may not deserve high conviction. Alpha Forge adjusts the interpretation accordingly.

Bias + Decision System

The dashboard separates Bias from Decision.

Bias shows the broad analyst condition.

Decision gives a more practical interpretation after considering target upside, target quality, coverage, and valuation context.

Possible readings include:

Strong Support
Support
Support / Volatile
Strong Ratings
Ratings Only
Watch
Watch / Split
Caution
Over Target
No Pine Data
AF Grade System

The indicator includes two grade layers:

Overall Grade
A broader score that considers analyst conviction, target edge, target quality, momentum, and valuation context.

Analyst Grade
A more focused read on analyst support and target structure.

This helps users understand when analyst sentiment is strong but overall conditions are less clean due to valuation, target risk, or missing target data.

Valuation Context

When available, the engine also displays basic valuation/fundamental data:

EPS TTM
P/E ratio
P/S ratio
Revenue TTM
Basic valuation score

This is not intended to replace full fundamental analysis, but it gives helpful context beside analyst support.

Target Lines

By default, the indicator plots the average analyst target only.

High and low target lines can be enabled, but they are disabled by default because extreme targets can flatten the chart scale.

Available target line modes:

Average only
All targets
None

Available target label modes:

Average only
All labels
None

Dashboard Modes

The dashboard is customizable for desktop, tablet, and mobile use.

Available modes include:

Full
Classic Compact
Compact
Micro

Users can adjust:

Dashboard position
Text size
Label width
Dashboard transparency
Score row visibility
Fundamentals visibility
Target quality row visibility
Floating bias label position
Floating bias label size
Suggested Mobile Settings

For mobile, suggested settings are:

Dashboard Mode: Classic Compact
Dashboard Label Width: Narrow
Text Size: Small or Tiny
Target Line Mode: Avg Only
Target Label Mode: Avg Only
Floating Bias Label Position: Right of Price
Fundamentals: Off
How To Read It
Strong Support

Analysts are strongly bullish, price remains below the average target, and target upside is meaningful.

Support

Analysts still support the stock, but upside or conviction may be more moderate.

Support / Volatile

Analyst support exists and median target may confirm upside, but the target range is wide or uncertain.

Strong Ratings

Ratings are strongly positive, but price target data may not be available through Pine for that symbol.

Ratings Only

Recommendation data is available, but target-price data is unavailable.

Watch

Some support exists, but the edge is not clean enough.

Caution

Upside is weak, ratings are mixed, target structure is poor, or valuation context is stretched.

Over Target

Current price is above the average analyst target.

No Pine Data

TradingView may not expose analyst data to Pine Script for that symbol, even if analyst information appears elsewhere on the platform.

Important Data Note

Analyst data availability depends on what TradingView exposes to Pine Script for each symbol.

Some stocks may provide full analyst recommendation and target-price data. Others may provide ratings only. Some may show analyst data in TradingView’s interface but return no analyst data inside Pine.

The indicator is automatic-only by design. Manual analyst inputs are not included because manually entered data can become stale and may miss upgrades, downgrades, target raises, or target cuts.

Best Used For

Analyst Engine is best used as a confirmation and decision-support tool.

It pairs well with:

Trend-following systems
Momentum indicators
Breakout setups
Reversal tools
Swing trading strategies
Options watchlists
Long-term stock reviews

Use it to help answer:

Is this stock still supported by analysts at today’s price, or has the setup become stretched, uncertain, or over-target?

Disclaimer

This indicator is for educational and informational purposes only. Analyst ratings and target prices are estimates and can change at any time. They are not guarantees of future price movement.

Analyst Engine does not provide financial advice and should not be used as a standalone buy or sell signal. Always combine analyst data with price action, risk management, market conditions, and your own research.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Alpha Forge Analyst Engine [v2.0]", shorttitle="AF Analyst Engine", overlay=true, max_labels_count=100, max_lines_count=100)

//────────────────────────────────────────────────────────────────────
// ALPHA FORGE ANALYST ENGINE v2.0
// Core Question:
// Do analysts still support this stock at the current chart price?
//
// v2.0 focus:
// - Split ratings data from target data
// - Ratings-only mode for symbols with recommendations but no target prices
// - Strong Ratings / Ratings Support decisions
// - More accurate no-data handling
// - Floating bias label can now anchor to the right of live price
//────────────────────────────────────────────────────────────────────

//────────────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────────────
groupDisplay = "Display"

showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
dashboardMode = input.string("Classic Compact", "Dashboard Mode", options=["Full", "Classic Compact", "Micro"], group=groupDisplay)
dashPosInput  = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDisplay)
dashSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)
labelMode     = input.string("Standard", "Dashboard Label Width", options=["Standard", "Narrow"], group=groupDisplay)
headerMode    = input.string("Decision First", "Header Focus", options=["Decision First", "Bias First"], group=groupDisplay)

showTargets      = input.bool(true, "Show Analyst Target Lines", group=groupDisplay)
targetLineMode   = input.string("Avg Only", "Target Line Mode", options=["Avg Only", "All", "None"], group=groupDisplay)
targetLabelMode  = input.string("Avg Only", "Target Label Mode", options=["Avg Only", "All", "None"], group=groupDisplay)
showBiasLabel    = input.bool(false, "Show Floating Bias Label", group=groupDisplay)
floatingLabelPos = input.string("Right of Price", "Floating Bias Label Position", options=["Right of Price", "Above Current Bar", "Right of Avg Target"], group=groupDisplay)
floatingLabelOffset = input.int(8, "Floating Bias Label Right Offset", minval=1, maxval=50, group=groupDisplay)
floatingLabelSizeInput = input.string("Small", "Floating Bias Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)

showScoreRows    = input.bool(true, "Show Score Rows", group=groupDisplay)
showFundamentals = input.bool(false, "Show Fundamentals", group=groupDisplay)
showRangeRows    = input.bool(true, "Show Target Quality Rows", group=groupDisplay)

panelTransp = input.int(12, "Dashboard Background Transparency", minval=0, maxval=90, group=groupDisplay)
cellTransp  = input.int(8, "Cell Background Transparency", minval=0, maxval=90, group=groupDisplay)

// Logic inputs
groupLogic = "Bias / Decision Logic"

strongBuyPctMin   = input.float(70.0, "Strong Support: Min Buy Consensus %", minval=0, maxval=100, step=1, group=groupLogic)
strongUpsideMin   = input.float(10.0, "Strong Support: Min Target Upside %", minval=0, step=0.5, group=groupLogic)
supportBuyPctMin  = input.float(55.0, "Support: Min Buy Consensus %", minval=0, maxval=100, step=1, group=groupLogic)
supportUpsideMin  = input.float(5.0, "Support: Min Target Upside %", minval=0, step=0.5, group=groupLogic)
cautionUpsideMax  = input.float(0.0, "Caution: Target Upside <= %", step=0.5, group=groupLogic)
nearAvgBandPct    = input.float(3.0, "Near Average Target Band %", minval=0.1, step=0.1, group=groupLogic)

moderateSpreadPct = input.float(60.0, "Target Range: Moderate <= %", minval=1, step=1, group=groupLogic)
wideSpreadPct     = input.float(120.0, "Target Range: Wide <= %", minval=1, step=1, group=groupLogic)
splitMedianGapPct = input.float(15.0, "Split Targets: Avg/Median Gap >= %", minval=1, step=1, group=groupLogic)
elevatedLowRiskPct = input.float(-20.0, "Elevated Low Target Risk <= %", maxval=0, step=1, group=groupLogic)

// Style inputs
groupStyle = "Alpha Forge Style"

bullCol     = input.color(color.rgb(41, 211, 255), "Bull / Support Cyan", group=groupStyle)
supportCol  = input.color(color.rgb(80, 220, 120), "Support Green", group=groupStyle)
bearCol     = input.color(color.rgb(255, 80, 90), "Bear / Warning Red", group=groupStyle)
neutralCol  = input.color(color.rgb(192, 192, 192), "Neutral Silver", group=groupStyle)
amberCol    = input.color(color.rgb(255, 190, 60), "Caution Amber", group=groupStyle)
magentaCol  = input.color(color.rgb(255, 0, 255), "High Target Magenta", group=groupStyle)
panelBgIn   = input.color(color.rgb(8, 12, 18), "Panel Background", group=groupStyle)
cellBgIn    = input.color(color.rgb(14, 22, 30), "Cell Background", group=groupStyle)

panelBg = color.new(panelBgIn, panelTransp)
cellBg  = color.new(cellBgIn, cellTransp)

//────────────────────────────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────────────────────────────
f_pos(_p) =>
    switch _p
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_size(_s) =>
    switch _s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_fmtPrice(x) =>
    na(x) ? "NA" : str.tostring(x, format.mintick)

f_fmtPct(x) =>
    na(x) ? "NA" : str.tostring(x, "#.##") + "%"

f_fmtNum(x) =>
    na(x) ? "NA" : str.tostring(x, "#.##")

f_fmtInt(x) =>
    na(x) ? "NA" : str.tostring(x, "#")

f_grade(score) =>
    score >= 90 ? "A+" :
     score >= 82 ? "A" :
     score >= 75 ? "B+" :
     score >= 65 ? "B" :
     score >= 55 ? "C" :
     score >= 45 ? "D" :
     "F"

f_gradeColor(g) =>
    g == "A+" or g == "A" ? bullCol :
     g == "B+" or g == "B" ? supportCol :
     g == "C" ? neutralCol :
     g == "D" ? amberCol :
     bearCol

f_lbl(stdTxt, narrowTxt) =>
    labelMode == "Narrow" ? narrowTxt : stdTxt

//────────────────────────────────────────────────────────────────────
// Analyst Data From TradingView syminfo
//────────────────────────────────────────────────────────────────────
avgTarget       = syminfo.target_price_average
highTarget      = syminfo.target_price_high
lowTarget       = syminfo.target_price_low
medianTarget    = syminfo.target_price_median
targetEstimates = syminfo.target_price_estimates

strongBuy  = syminfo.recommendations_buy_strong
buy        = syminfo.recommendations_buy
hold       = syminfo.recommendations_hold
sell       = syminfo.recommendations_sell
strongSell = syminfo.recommendations_sell_strong

totalBuy      = nz(strongBuy) + nz(buy)
totalSell     = nz(sell) + nz(strongSell)
totalHoldSell = nz(hold) + totalSell
totalRecs     = totalBuy + nz(hold) + totalSell

hasRatingsData = totalRecs > 0
hasTargetData  = not na(avgTarget)
hasAnalystData = hasRatingsData and hasTargetData

buyPct      = totalRecs > 0 ? totalBuy / totalRecs * 100.0 : na
holdSellPct = totalRecs > 0 ? totalHoldSell / totalRecs * 100.0 : na
targetUpside = not na(avgTarget) and close != 0 ? (avgTarget - close) / close * 100.0 : na
medianUpside = not na(medianTarget) and close != 0 ? (medianTarget - close) / close * 100.0 : na
highUpside   = not na(highTarget) and close != 0 ? (highTarget - close) / close * 100.0 : na
lowDownside  = not na(lowTarget) and close != 0 ? (lowTarget - close) / close * 100.0 : na

targetSpreadPct = not na(highTarget) and not na(lowTarget) and close != 0 ? (highTarget - lowTarget) / close * 100.0 : na
avgMedianGapPct = not na(avgTarget) and not na(medianTarget) and avgTarget != 0 ? math.abs(avgTarget - medianTarget) / avgTarget * 100.0 : na

priceOverAvgTarget   = not na(avgTarget) and close > avgTarget
priceAboveHighTarget = not na(highTarget) and close > highTarget
priceBelowLowTarget  = not na(lowTarget) and close < lowTarget
priceNearAvgTarget   = not na(avgTarget) and math.abs(close - avgTarget) / avgTarget * 100.0 <= nearAvgBandPct

//────────────────────────────────────────────────────────────────────
// Fundamental Data
//────────────────────────────────────────────────────────────────────
epsTTM     = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "TTM")
sharesOut  = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
revenueTTM = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "TTM")

marketCap = not na(sharesOut) ? sharesOut * close : na
peRatio   = not na(epsTTM) and epsTTM != 0 ? close / epsTTM : na
psRatio   = not na(revenueTTM) and not na(marketCap) and revenueTTM != 0 ? marketCap / revenueTTM : na

//────────────────────────────────────────────────────────────────────
// Target Quality Logic
//────────────────────────────────────────────────────────────────────
targetRange =
     na(targetSpreadPct) ? "NO DATA" :
     targetSpreadPct <= moderateSpreadPct ? "TIGHT" :
     targetSpreadPct <= wideSpreadPct ? "WIDE" :
     "EXTREME"

targetRangeColor =
     targetRange == "TIGHT" ? supportCol :
     targetRange == "WIDE" ? amberCol :
     targetRange == "EXTREME" ? bearCol :
     neutralCol

medianSupport =
     na(medianUpside) ? "NO DATA" :
     medianUpside >= strongUpsideMin ? "CONFIRMED" :
     medianUpside >= supportUpsideMin ? "LIMITED" :
     "WEAK"

medianSupportColor =
     medianSupport == "CONFIRMED" ? supportCol :
     medianSupport == "LIMITED" ? amberCol :
     medianSupport == "WEAK" ? bearCol :
     neutralCol

lowTargetRisk =
     na(lowDownside) ? "NO DATA" :
     lowDownside <= elevatedLowRiskPct ? "ELEVATED" :
     lowDownside < 0 ? "MEDIUM" :
     "LOW"

lowTargetRiskColor =
     lowTargetRisk == "LOW" ? supportCol :
     lowTargetRisk == "MEDIUM" ? amberCol :
     lowTargetRisk == "ELEVATED" ? bearCol :
     neutralCol

splitTargets = not na(avgMedianGapPct) and avgMedianGapPct >= splitMedianGapPct
volatileTargets = targetRange == "WIDE" or targetRange == "EXTREME"

targetConfidence =
     splitTargets ? "SPLIT" :
     targetRange == "EXTREME" ? "VOLATILE" :
     targetRange == "WIDE" ? "MEDIUM" :
     targetRange == "TIGHT" ? "HIGH" :
     "NO DATA"

targetConfidenceColor =
     targetConfidence == "HIGH" ? supportCol :
     targetConfidence == "MEDIUM" ? amberCol :
     targetConfidence == "VOLATILE" ? amberCol :
     targetConfidence == "SPLIT" ? bearCol :
     neutralCol

//────────────────────────────────────────────────────────────────────
// Bias Logic
//────────────────────────────────────────────────────────────────────
bias =
     not hasRatingsData ? "NO DATA" :
     not hasTargetData and buyPct >= strongBuyPctMin ? "STRONG RATINGS" :
     not hasTargetData and buyPct >= supportBuyPctMin ? "RATINGS SUPPORT" :
     not hasTargetData and holdSellPct >= 50 ? "CAUTION" :
     not hasTargetData ? "RATINGS ONLY" :
     priceOverAvgTarget ? "OVER TARGET" :
     buyPct >= strongBuyPctMin and targetUpside >= strongUpsideMin ? "STRONG SUPPORT" :
     buyPct >= supportBuyPctMin and targetUpside >= supportUpsideMin ? "SUPPORT" :
     targetUpside <= cautionUpsideMax or holdSellPct >= 50 ? "CAUTION" :
     "NEUTRAL"

biasColor =
     bias == "STRONG SUPPORT" or bias == "STRONG RATINGS" ? bullCol :
     bias == "SUPPORT" or bias == "RATINGS SUPPORT" ? supportCol :
     bias == "NEUTRAL" or bias == "RATINGS ONLY" ? neutralCol :
     bias == "CAUTION" ? amberCol :
     bias == "OVER TARGET" ? bearCol :
     neutralCol

statusText =
     bias == "STRONG SUPPORT" ? "Supported at current price" :
     bias == "SUPPORT" ? "Analysts still support setup" :
     bias == "STRONG RATINGS" ? "Strong ratings; no target data" :
     bias == "RATINGS SUPPORT" ? "Ratings support; no target data" :
     bias == "RATINGS ONLY" ? "Ratings available only" :
     bias == "NEUTRAL" ? "Limited or mixed analyst edge" :
     bias == "CAUTION" ? "Weak upside or mixed ratings" :
     bias == "OVER TARGET" ? "Price above average target" :
     "Analyst data unavailable"

priceZone =
     not hasRatingsData ? "NO DATA" :
     not hasTargetData ? "NO TARGET" :
     priceAboveHighTarget ? "ABOVE HIGH" :
     priceBelowLowTarget ? "BELOW LOW" :
     priceOverAvgTarget ? "ABOVE AVG" :
     priceNearAvgTarget ? "NEAR AVG" :
     "BELOW AVG"

priceZoneNote =
     priceZone == "ABOVE HIGH" ? "Above high target" :
     priceZone == "BELOW LOW" ? "Below low target" :
     priceZone == "ABOVE AVG" ? "Above avg target" :
     priceZone == "NEAR AVG" ? "Near +/- " + str.tostring(nearAvgBandPct, "#.##") + "%" :
     priceZone == "BELOW AVG" ? "Room to avg target" :
     priceZone == "NO TARGET" ? "Ratings only" :
     "No analyst data"

priceZoneColor =
     priceZone == "BELOW AVG" ? bullCol :
     priceZone == "NO TARGET" ? neutralCol :
     priceZone == "NEAR AVG" ? amberCol :
     priceZone == "ABOVE AVG" or priceZone == "ABOVE HIGH" ? bearCol :
     priceZone == "BELOW LOW" ? amberCol :
     neutralCol

//────────────────────────────────────────────────────────────────────
// Analyst Momentum
//────────────────────────────────────────────────────────────────────
avgTargetChange = ta.change(avgTarget)
totalBuyChange = ta.change(totalBuy)
holdSellChange = ta.change(totalHoldSell)

targetRaised = not na(avgTargetChange) and avgTargetChange > 0
targetCut    = not na(avgTargetChange) and avgTargetChange < 0
buyImproved  = not na(totalBuyChange) and totalBuyChange > 0
buyWeakened  = not na(totalBuyChange) and totalBuyChange < 0
riskImproved = not na(holdSellChange) and holdSellChange < 0
riskWorse    = not na(holdSellChange) and holdSellChange > 0

momScoreRaw =
     (targetRaised ? 2 : 0) +
     (buyImproved ? 1 : 0) +
     (riskImproved ? 1 : 0) -
     (targetCut ? 2 : 0) -
     (buyWeakened ? 1 : 0) -
     (riskWorse ? 1 : 0)

momentum =
     momScoreRaw >= 2 ? "IMPROVING" :
     momScoreRaw <= -2 ? "WEAKENING" :
     "STABLE"

momentumColor =
     momentum == "IMPROVING" ? bullCol :
     momentum == "WEAKENING" ? bearCol :
     neutralCol

momentumNote = targetRaised ? "Target Raised" : targetCut ? "Target Cut" : "No Change"

//────────────────────────────────────────────────────────────────────
// AF Score
//────────────────────────────────────────────────────────────────────
coverageBoost =
     totalRecs >= 25 ? 1.00 :
     totalRecs >= 10 ? 0.85 :
     totalRecs >= 5 ? 0.70 :
     totalRecs > 0 ? 0.50 :
     0.0

convictionScore = not na(buyPct) ? math.min(40.0, math.max(0.0, buyPct / 100.0 * 40.0 * coverageBoost)) : 0.0

baseTargetScore =
     na(targetUpside) ? 0.0 :
     targetUpside <= 0 ? 0.0 :
     targetUpside >= 20 ? 30.0 :
     targetUpside / 20.0 * 30.0

rangePenalty =
     targetConfidence == "HIGH" ? 1.00 :
     targetConfidence == "MEDIUM" ? 0.90 :
     targetConfidence == "VOLATILE" ? 0.70 :
     targetConfidence == "SPLIT" ? 0.55 :
     0.75

lowRiskPenalty =
     lowTargetRisk == "ELEVATED" ? 0.85 :
     lowTargetRisk == "MEDIUM" ? 0.95 :
     1.00

targetScore = math.min(30.0, math.max(0.0, baseTargetScore * rangePenalty * lowRiskPenalty))

momentumScore =
     momentum == "IMPROVING" ? 15.0 :
     momentum == "WEAKENING" ? 0.0 :
     7.5

valuationScore =
     na(peRatio) ? 7.5 :
     peRatio <= 0 ? 5.0 :
     peRatio <= 20 ? 15.0 :
     peRatio <= 35 ? 11.0 :
     peRatio <= 50 ? 7.0 :
     4.0

analystScoreRaw = convictionScore + targetScore + momentumScore
analystScoreWithTargets = math.min(100.0, math.max(0.0, analystScoreRaw / 85.0 * 100.0))
analystScoreRatingsOnly = math.min(100.0, math.max(0.0, (convictionScore / 40.0 * 85.0) + (momentumScore / 15.0 * 15.0)))
analystScore = math.round(hasTargetData ? analystScoreWithTargets : hasRatingsData ? analystScoreRatingsOnly : 0.0)

afScoreRaw = convictionScore + targetScore + momentumScore + valuationScore
afScore = math.round(math.min(100.0, math.max(0.0, afScoreRaw)))

overallGrade = f_grade(afScore)
analystGrade = f_grade(analystScore)
scoreColor = f_gradeColor(overallGrade)
analystGradeColor = f_gradeColor(analystGrade)

//────────────────────────────────────────────────────────────────────
// Decision Logic
//────────────────────────────────────────────────────────────────────
decision =
     not hasRatingsData ? "NO DATA" :
     not hasTargetData and bias == "STRONG RATINGS" ? "STRONG RATINGS" :
     not hasTargetData and bias == "RATINGS SUPPORT" ? "RATINGS SUPPORT" :
     not hasTargetData ? "RATINGS ONLY" :
     bias == "OVER TARGET" ? "OVER TARGET" :
     bias == "CAUTION" ? "CAUTION" :
     splitTargets ? "WATCH / SPLIT" :
     volatileTargets and medianSupport == "CONFIRMED" and bias == "SUPPORT" ? "SUPPORT / VOLATILE" :
     volatileTargets and bias == "STRONG SUPPORT" ? "SUPPORT / VOLATILE" :
     afScore >= 80 and bias == "STRONG SUPPORT" and targetConfidence == "HIGH" ? "HIGH CONVICTION" :
     bias == "STRONG SUPPORT" ? "STRONG SUPPORT" :
     bias == "SUPPORT" ? "SUPPORTED" :
     "WATCH"

decisionNote =
     decision == "HIGH CONVICTION" ? "Clean analyst edge" :
     decision == "STRONG SUPPORT" ? "Strong analyst support" :
     decision == "SUPPORTED" ? "Analysts support setup" :
     decision == "STRONG RATINGS" ? "Target data unavailable" :
     decision == "RATINGS SUPPORT" ? "Target data unavailable" :
     decision == "RATINGS ONLY" ? "Ratings only mode" :
     decision == "SUPPORT / VOLATILE" ? "Median confirms upside" :
     decision == "WATCH / SPLIT" ? "Avg/median disagreement" :
     decision == "WATCH" ? "Needs cleaner edge" :
     decision == "CAUTION" ? "Weak or mixed edge" :
     decision == "OVER TARGET" ? "Price above avg target" :
     "Data unavailable"

decisionColor =
     decision == "HIGH CONVICTION" ? bullCol :
     decision == "STRONG SUPPORT" or decision == "STRONG RATINGS" ? bullCol :
     decision == "SUPPORTED" or decision == "RATINGS SUPPORT" ? supportCol :
     decision == "SUPPORT / VOLATILE" ? amberCol :
     decision == "WATCH / SPLIT" ? amberCol :
     decision == "WATCH" or decision == "RATINGS ONLY" ? neutralCol :
     decision == "CAUTION" ? amberCol :
     decision == "OVER TARGET" ? bearCol :
     neutralCol

//────────────────────────────────────────────────────────────────────
// Target Lines
//────────────────────────────────────────────────────────────────────
showAvgLine  = showTargets and targetLineMode != "None"
showAllLines = showTargets and targetLineMode == "All"

plot(showAllLines ? highTarget : na, "High Analyst Target", color=magentaCol, linewidth=2, style=plot.style_linebr)
plot(showAvgLine ? avgTarget : na, "Average Analyst Target", color=bullCol, linewidth=2, style=plot.style_linebr)
plot(showAllLines ? lowTarget : na, "Low Analyst Target", color=neutralCol, linewidth=2, style=plot.style_linebr)

//────────────────────────────────────────────────────────────────────
// Floating labels
//────────────────────────────────────────────────────────────────────
var label highLab = na
var label avgLab  = na
var label lowLab  = na
var label biasLab = na

if barstate.islast
    if not na(highLab)
        label.delete(highLab)
    if not na(avgLab)
        label.delete(avgLab)
    if not na(lowLab)
        label.delete(lowLab)
    if not na(biasLab)
        label.delete(biasLab)

    if showTargets and targetLabelMode == "All" and not na(highTarget)
        highLab := label.new(bar_index, highTarget, "HIGH " + f_fmtPrice(highTarget), style=label.style_label_left, textcolor=color.white, color=color.new(magentaCol, 0), size=size.small)

    if showTargets and targetLabelMode != "None" and not na(avgTarget)
        avgLab := label.new(bar_index, avgTarget, "AVG " + f_fmtPrice(avgTarget), style=label.style_label_left, textcolor=color.black, color=color.new(bullCol, 0), size=size.small)

    if showTargets and targetLabelMode == "All" and not na(lowTarget)
        lowLab := label.new(bar_index, lowTarget, "LOW " + f_fmtPrice(lowTarget), style=label.style_label_left, textcolor=color.white, color=color.new(neutralCol, 10), size=size.small)

    if showBiasLabel
        labelText = "AF ANALYST\n" + decision + "\n" + overallGrade + "  " + str.tostring(afScore) + "/100"
        labelSize = f_size(floatingLabelSizeInput)
        labelX = floatingLabelPos == "Above Current Bar" ? bar_index : bar_index + floatingLabelOffset
        labelY = floatingLabelPos == "Right of Avg Target" and not na(avgTarget) ? avgTarget : floatingLabelPos == "Above Current Bar" ? high + ta.atr(14) * 1.5 : close
        labelStyle = floatingLabelPos == "Above Current Bar" ? label.style_label_down : label.style_label_left
        biasLab := label.new(labelX, labelY, labelText, style=labelStyle, textcolor=color.white, color=color.new(decisionColor, 0), size=labelSize)

//────────────────────────────────────────────────────────────────────
// Dashboard
//────────────────────────────────────────────────────────────────────
dashPos = f_pos(dashPosInput)
txtSize = f_size(dashSizeInput)

var table dash = table.new(dashPos, 3, 18, border_width=1, frame_width=1, frame_color=color.new(bullCol, 30), border_color=color.new(bullCol, 45))

f_cell(col, row, txt, txtCol, bgCol) =>
    table.cell(dash, col, row, txt, text_color=txtCol, bgcolor=bgCol, text_size=txtSize)

if barstate.islast and showDashboard
    table.clear(dash, 0, 0, 2, 17)

    if dashboardMode == "Micro"
        f_cell(0, 0, "AF", bullCol, panelBg)
        f_cell(1, 0, decision, decisionColor, panelBg)
        f_cell(2, 0, overallGrade + " " + str.tostring(afScore), scoreColor, panelBg)

        f_cell(0, 1, "UP", color.white, cellBg)
        f_cell(1, 1, f_fmtPct(targetUpside), targetUpside >= 0 ? bullCol : bearCol, cellBg)
        f_cell(2, 1, "BUY " + f_fmtPct(buyPct), supportCol, cellBg)

        f_cell(0, 2, "AVG", color.white, cellBg)
        f_cell(1, 2, f_fmtPrice(avgTarget), bullCol, cellBg)
        f_cell(2, 2, targetConfidence, targetConfidenceColor, cellBg)

    else if dashboardMode == "Classic Compact"
        if headerMode == "Decision First"
            f_cell(0, 0, "ALPHA FORGE", bullCol, panelBg)
            f_cell(1, 0, decision, decisionColor, panelBg)
            f_cell(2, 0, "v2.0", neutralCol, panelBg)
        else
            f_cell(0, 0, "ALPHA FORGE", bullCol, panelBg)
            f_cell(1, 0, "ANALYST ENGINE", color.white, panelBg)
            f_cell(2, 0, "v2.0", neutralCol, panelBg)

        f_cell(0, 1, f_lbl("BIAS", "BIAS"), color.white, cellBg)
        f_cell(1, 1, bias, biasColor, cellBg)
        f_cell(2, 1, statusText, biasColor, cellBg)

        f_cell(0, 2, f_lbl("GRADE", "GRADE"), color.white, cellBg)
        f_cell(1, 2, overallGrade, scoreColor, cellBg)
        f_cell(2, 2, str.tostring(afScore) + " / 100", scoreColor, cellBg)

        f_cell(0, 3, f_lbl("DECISION", "DEC"), color.white, panelBg)
        f_cell(1, 3, decision, decisionColor, panelBg)
        f_cell(2, 3, decisionNote, decisionColor, panelBg)

        f_cell(0, 4, f_lbl("PRICE ZONE", "ZONE"), color.white, cellBg)
        f_cell(1, 4, priceZone, priceZoneColor, cellBg)
        f_cell(2, 4, priceZoneNote, priceZoneColor, cellBg)

        f_cell(0, 5, f_lbl("PRICE", "PX"), color.white, cellBg)
        f_cell(1, 5, f_fmtPrice(close), bullCol, cellBg)
        f_cell(2, 5, syminfo.currency, neutralCol, cellBg)

        f_cell(0, 6, f_lbl("AVG TARGET", "AVG"), color.white, panelBg)
        f_cell(1, 6, f_fmtPrice(avgTarget), bullCol, panelBg)
        f_cell(2, 6, "Up " + f_fmtPct(targetUpside), targetUpside >= 0 ? bullCol : bearCol, panelBg)

        f_cell(0, 7, f_lbl("MEDIAN TARGET", "MED"), color.white, cellBg)
        f_cell(1, 7, f_fmtPrice(medianTarget), neutralCol, cellBg)
        f_cell(2, 7, "Med Up " + f_fmtPct(medianUpside), medianUpside >= 0 ? supportCol : bearCol, cellBg)

        if showRangeRows
            f_cell(0, 8, f_lbl("TARGET CONF", "CONF"), color.white, panelBg)
            f_cell(1, 8, targetConfidence, targetConfidenceColor, panelBg)
            f_cell(2, 8, "Med " + medianSupport, medianSupportColor, panelBg)

            f_cell(0, 9, f_lbl("TARGET RANGE", "RANGE"), color.white, cellBg)
            f_cell(1, 9, targetRange, targetRangeColor, cellBg)
            f_cell(2, 9, "Spread " + f_fmtPct(targetSpreadPct), targetRangeColor, cellBg)
        else
            f_cell(0, 8, f_lbl("HIGH / LOW", "H/L"), color.white, panelBg)
            f_cell(1, 8, f_fmtPrice(highTarget), magentaCol, panelBg)
            f_cell(2, 8, "Low " + f_fmtPrice(lowTarget), neutralCol, panelBg)

        f_cell(0, 10, f_lbl("CONSENSUS", "CONS"), color.white, panelBg)
        f_cell(1, 10, f_fmtPct(buyPct), buyPct >= strongBuyPctMin ? bullCol : buyPct >= supportBuyPctMin ? supportCol : neutralCol, panelBg)
        f_cell(2, 10, "Coverage " + f_fmtInt(totalRecs), neutralCol, panelBg)

        f_cell(0, 11, f_lbl("RATINGS", "RATE"), color.white, cellBg)
        f_cell(1, 11, "SB " + f_fmtInt(strongBuy) + "  B " + f_fmtInt(buy), supportCol, cellBg)
        f_cell(2, 11, "H " + f_fmtInt(hold) + "  S " + f_fmtInt(totalSell), amberCol, cellBg)

        f_cell(0, 12, f_lbl("MOMENTUM", "MOM"), color.white, panelBg)
        f_cell(1, 12, momentum, momentumColor, panelBg)
        f_cell(2, 12, momentumNote, momentumColor, panelBg)

        if showScoreRows
            f_cell(0, 13, f_lbl("ANALYST GRADE", "A-GRD"), color.white, cellBg)
            f_cell(1, 13, analystGrade, analystGradeColor, cellBg)
            f_cell(2, 13, str.tostring(analystScore) + " / 100", analystGradeColor, cellBg)

            f_cell(0, 14, f_lbl("EDGE", "EDGE"), color.white, cellBg)
            f_cell(1, 14, str.tostring(math.round(targetScore)) + " / 30", targetScore >= 20 ? bullCol : targetScore >= 12 ? amberCol : bearCol, cellBg)
            f_cell(2, 14, "Quality Adj", neutralCol, cellBg)

        if showFundamentals
            f_cell(0, 15, "P/E", color.white, panelBg)
            f_cell(1, 15, f_fmtNum(peRatio), neutralCol, panelBg)
            f_cell(2, 15, "EPS " + f_fmtNum(epsTTM), neutralCol, panelBg)

            f_cell(0, 16, "P/S", color.white, cellBg)
            f_cell(1, 16, f_fmtNum(psRatio), neutralCol, cellBg)
            f_cell(2, 16, "Val " + str.tostring(math.round(valuationScore)) + "/15", neutralCol, cellBg)

        f_cell(0, 17, "EDGE", bullCol, cellBg)
        f_cell(1, 17, "Analysts + Price", color.white, cellBg)
        f_cell(2, 17, "Alpha Forge", bullCol, cellBg)

    else
        f_cell(0, 0, "ALPHA FORGE", bullCol, panelBg)
        f_cell(1, 0, "ANALYST ENGINE", color.white, panelBg)
        f_cell(2, 0, "v2.0", neutralCol, panelBg)

        f_cell(0, 1, "BIAS", color.white, cellBg)
        f_cell(1, 1, bias, biasColor, cellBg)
        f_cell(2, 1, statusText, biasColor, cellBg)

        f_cell(0, 2, "GRADE", color.white, cellBg)
        f_cell(1, 2, overallGrade, scoreColor, cellBg)
        f_cell(2, 2, str.tostring(afScore) + " / 100", scoreColor, cellBg)

        f_cell(0, 3, "ANALYST GRADE", color.white, cellBg)
        f_cell(1, 3, analystGrade, analystGradeColor, cellBg)
        f_cell(2, 3, str.tostring(analystScore) + " / 100", analystGradeColor, cellBg)

        f_cell(0, 4, "DECISION", color.white, panelBg)
        f_cell(1, 4, decision, decisionColor, panelBg)
        f_cell(2, 4, decisionNote, decisionColor, panelBg)

        f_cell(0, 5, "MOMENTUM", color.white, cellBg)
        f_cell(1, 5, momentum, momentumColor, cellBg)
        f_cell(2, 5, momentumNote, momentumColor, cellBg)

        f_cell(0, 6, "PRICE ZONE", color.white, cellBg)
        f_cell(1, 6, priceZone, priceZoneColor, cellBg)
        f_cell(2, 6, priceZoneNote, priceZoneColor, cellBg)

        f_cell(0, 7, "PRICE", color.white, panelBg)
        f_cell(1, 7, f_fmtPrice(close), bullCol, panelBg)
        f_cell(2, 7, syminfo.currency, neutralCol, panelBg)

        f_cell(0, 8, "AVG TARGET", color.white, cellBg)
        f_cell(1, 8, f_fmtPrice(avgTarget), bullCol, cellBg)
        f_cell(2, 8, "Upside " + f_fmtPct(targetUpside), targetUpside >= 0 ? bullCol : bearCol, cellBg)

        f_cell(0, 9, "MEDIAN TARGET", color.white, cellBg)
        f_cell(1, 9, f_fmtPrice(medianTarget), neutralCol, cellBg)
        f_cell(2, 9, "Med Up " + f_fmtPct(medianUpside), medianUpside >= 0 ? supportCol : bearCol, cellBg)

        f_cell(0, 10, "HIGH TARGET", color.white, cellBg)
        f_cell(1, 10, f_fmtPrice(highTarget), magentaCol, cellBg)
        f_cell(2, 10, "LOW " + f_fmtPrice(lowTarget), neutralCol, cellBg)

        f_cell(0, 11, "TARGET CONF", color.white, panelBg)
        f_cell(1, 11, targetConfidence, targetConfidenceColor, panelBg)
        f_cell(2, 11, "Med " + medianSupport, medianSupportColor, panelBg)

        f_cell(0, 12, "TARGET RANGE", color.white, cellBg)
        f_cell(1, 12, targetRange, targetRangeColor, cellBg)
        f_cell(2, 12, "Spread " + f_fmtPct(targetSpreadPct), targetRangeColor, cellBg)

        f_cell(0, 13, "LOW TGT RISK", color.white, cellBg)
        f_cell(1, 13, lowTargetRisk, lowTargetRiskColor, cellBg)
        f_cell(2, 13, "Gap " + f_fmtPct(avgMedianGapPct), neutralCol, cellBg)

        f_cell(0, 14, "STRONG BUY", color.white, panelBg)
        f_cell(1, 14, f_fmtInt(strongBuy), supportCol, panelBg)
        f_cell(2, 14, "BUY " + f_fmtInt(buy), supportCol, panelBg)

        f_cell(0, 15, "HOLD", color.white, cellBg)
        f_cell(1, 15, f_fmtInt(hold), amberCol, cellBg)
        f_cell(2, 15, "SELL " + f_fmtInt(totalSell), bearCol, cellBg)

        f_cell(0, 16, "CONSENSUS", color.white, cellBg)
        f_cell(1, 16, f_fmtPct(buyPct), buyPct >= strongBuyPctMin ? bullCol : buyPct >= supportBuyPctMin ? supportCol : neutralCol, cellBg)
        f_cell(2, 16, "Coverage " + f_fmtInt(totalRecs), neutralCol, cellBg)

        f_cell(0, 17, "EDGE", bullCol, cellBg)
        f_cell(1, 17, "Analysts + Price", color.white, cellBg)
        f_cell(2, 17, "Alpha Forge", bullCol, cellBg)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 2, 17)

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
strongSupportSignal = bias == "STRONG SUPPORT" and bias[1] != "STRONG SUPPORT"
supportSignal       = bias == "SUPPORT" and bias[1] != "SUPPORT"
cautionSignal       = bias == "CAUTION" and bias[1] != "CAUTION"
overTargetSignal    = bias == "OVER TARGET" and bias[1] != "OVER TARGET"
strongRatingsSignal = bias == "STRONG RATINGS" and bias[1] != "STRONG RATINGS"
ratingsSupportSignal = bias == "RATINGS SUPPORT" and bias[1] != "RATINGS SUPPORT"

avgTargetCrossUp    = ta.crossover(close, avgTarget)
avgTargetCrossDown  = ta.crossunder(close, avgTarget)
highTargetCrossUp   = ta.crossover(close, highTarget)
lowTargetCrossDown  = ta.crossunder(close, lowTarget)

momentumImprovingSignal = momentum == "IMPROVING" and momentum[1] != "IMPROVING"
momentumWeakeningSignal = momentum == "WEAKENING" and momentum[1] != "WEAKENING"
volatileTargetSignal    = targetConfidence == "VOLATILE" and targetConfidence[1] != "VOLATILE"
splitTargetSignal       = targetConfidence == "SPLIT" and targetConfidence[1] != "SPLIT"
decisionChangeSignal    = decision != decision[1]

alertcondition(strongSupportSignal, "AF Analyst Strong Support", "Alpha Forge Analyst Engine: Strong Support detected.")
alertcondition(supportSignal, "AF Analyst Support", "Alpha Forge Analyst Engine: Support detected.")
alertcondition(cautionSignal, "AF Analyst Caution", "Alpha Forge Analyst Engine: Caution detected.")
alertcondition(overTargetSignal, "AF Analyst Over Target", "Alpha Forge Analyst Engine: Price is above average analyst target.")
alertcondition(strongRatingsSignal, "AF Strong Ratings / No Target", "Alpha Forge Analyst Engine: Strong analyst ratings detected, but target price data is unavailable.")
alertcondition(ratingsSupportSignal, "AF Ratings Support / No Target", "Alpha Forge Analyst Engine: Analyst ratings support detected, but target price data is unavailable.")
alertcondition(avgTargetCrossUp, "Price Crossed Above Avg Target", "Price crossed above the average analyst target.")
alertcondition(avgTargetCrossDown, "Price Crossed Below Avg Target", "Price crossed below the average analyst target.")
alertcondition(highTargetCrossUp, "Price Crossed Above High Target", "Price crossed above the high analyst target.")
alertcondition(lowTargetCrossDown, "Price Crossed Below Low Target", "Price crossed below the low analyst target.")
alertcondition(momentumImprovingSignal, "AF Analyst Momentum Improving", "Alpha Forge Analyst Engine: Analyst momentum improving.")
alertcondition(momentumWeakeningSignal, "AF Analyst Momentum Weakening", "Alpha Forge Analyst Engine: Analyst momentum weakening.")
alertcondition(volatileTargetSignal, "AF Volatile Target Structure", "Alpha Forge Analyst Engine: Target structure is volatile.")
alertcondition(splitTargetSignal, "AF Split Target Structure", "Alpha Forge Analyst Engine: Average and median targets are split.")
alertcondition(decisionChangeSignal, "AF Analyst Decision Changed", "Alpha Forge Analyst Engine: Decision state changed.")
````
