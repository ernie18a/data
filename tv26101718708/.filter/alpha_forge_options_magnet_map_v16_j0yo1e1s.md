# Alpha Forge Options Magnet Map v1.6

- url: https://www.tradingview.com/script/J0Yo1E1S-Alpha-Forge-Options-Magnet-Map-v1-6/
- type: indicator
- pine_id: PUB;f9ff7ada2af24f87818b4c468717bb7a
- version: 2.0

## Description

Alpha Forge Options Magnet Map is an options-volume visualization tool designed to help traders see where option activity is clustering around the current price.

The indicator maps nearby call and put volume by strike for a selected expiration date and displays the information directly on the chart as a right-side volume profile. The goal is to provide a cleaner view of where options interest is concentrated, without trying to predict price direction or provide trade recommendations.

What it does

The Options Magnet Map builds a strike grid around the current price and checks call and put volume at each nearby strike. It then highlights:

The highest-volume strike, also called the POC
The top call-volume strike
The top put-volume strike
A key options-volume zone
Call interest and put interest zones
Whether the main volume cluster is above, below, or around current price
Daily call/put volume balance
Basic liquidity and chain-quality information

The profile is displayed on the right side of the chart, with call and put volume shown by strike.

Key dashboard readings

Volume Basis
The script uses daily option volume for the selected expiration.

Bias
Shows whether call volume, put volume, or mixed volume is dominant across the selected strikes. This is based only on volume, not trade direction.

Liquidity
Provides a basic read on whether the selected chain appears thin, moderate, or active.

ATM / POC
Shows the current at-the-money strike and the highest total-volume strike.

Key Zone
Shows the strike range where the strongest options volume is concentrated.

Cluster Position
Shows whether the key options-volume zone is above price, below price, or around price.

Call Interest / Put Interest
Shows where call and put volume are concentrated separately.

Top Vol 1–3
Lists the top three total-volume strikes in the selected strike grid.

How to use it

This tool is best used as a context layer.

Traders can use it to see where nearby options activity is clustering and compare those levels with price action, support/resistance, trend, volume, or other indicators.

For example:

If the key zone is below current price, it may represent an area of prior options interest below market.
If the key zone is above current price, traders may want to watch how price reacts as it approaches that area.
If the key zone is around current price, the market may be trading inside a more active options area.
If the chain is marked as thin, the levels should be treated with extra caution.

This indicator does not determine whether option contracts were bought or sold, opened or closed, or part of a spread.

Important notes

Options volume alone does not confirm bullish or bearish intent. High call volume does not always mean bullish activity, and high put volume does not always mean bearish activity.

This tool does not provide financial advice, trade signals, or recommended strikes. It is intended to help visualize options-volume concentration for the selected expiration date.

For best results, use liquid tickers and confirm that the selected expiration date exists for the ticker being viewed.

Suggested settings

For highly liquid ETFs such as SPY or QQQ:

Strike spacing: 1
Round ATM to nearest: 1
Strikes above/below: 5

For larger-priced stocks such as NVDA, TSLA, META, or MSFT:

Strike spacing: 2.5 or 5
Round ATM to nearest: 2.5 or 5

For thinner option chains, reduce the strike range or adjust the expiration date to one with active volume.

Disclaimer

This script is for educational and informational purposes only. It does not provide investment advice, trading recommendations, or guaranteed outcomes. Always use proper risk management and confirm any analysis with your own research.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Forge

//@version=6
indicator("Alpha Forge Options Magnet Map v1.7.5", shorttitle="AF Options Magnet", overlay=true, dynamic_requests=true, max_lines_count=300, max_labels_count=300, max_boxes_count=300, max_bars_back=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALPHA FORGE OPTIONS MAGNET MAP v1.7.5
// Reliability release:
// - Smart expiry discovery with near-term and Friday scan modes
// - Manual calendar date picker
// - Locked ATM request universe for realtime safety
// - Current-session validation to block stale option volume
// - Zero-volume POC/top-strike protection
// - Contiguous high-volume cluster detection
// - Honest activity terminology (volume is not directional order flow)
// - Intraday/daily chart guard and request-budget protection
// - Selectable auto-expiry number with discovered-expiry list
// - Calendar-date session validation and grid-drift warnings
// - Chart-safe visual range to prevent price-scale crushing
// - Compact dashboard positioned away from the Forge Guide by default
// - Smart strike-grid detection so expiry probes use listed strikes instead of arbitrary prices
// - Removes distant magnet text labels and adds an integrated volume-based Forge Guide
// - Adds a scored Forge Confidence model and separate contract Risk Grade
// - Adds a realtime data grace state so delayed option feeds do not flash false red warnings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string OPT_TZ = "America/New_York"
int DAY_MS = 24 * 60 * 60 * 1000
int AUTO_PROBE_COUNT = 6

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpData  = "Symbol & Expiry"
grpGrid  = "Strike Grid"
grpVis   = "Visuals"
grpDash  = "Dashboard"
grpGuide = "Forge Confidence & Risk"
grpDebug = "Debug / Data Status"
grpLiq   = "Liquidity / Chain Quality"
grpColor = "Alpha Forge Colors"

// Symbol / expiry
useCustomBase = input.bool(false, "Use Custom Option Base Symbol", group=grpData)
customBase    = input.string("SPY", "Custom Base Symbol", group=grpData, tooltip="Examples: SPY, QQQ, AAPL, NVDA, TSLA, RKLB. For SPX you may need SPXW.")
symbolPrefix  = input.string("", "Option Symbol Prefix", group=grpData, tooltip='Usually blank. If needed, try "OPRA:".')
symbolFormat  = input.string("TV Decimal", "Option Symbol Format", options=["TV Decimal", "OCC Padded"], group=grpData, tooltip="TV Decimal example: SPY260724C500.0. OCC padded example: OPRA:SPY260724C00500000.")

expiryMode = input.string("Auto Near-Term", "Expiry Selection", options=["Auto Near-Term", "Auto Fridays", "Today / 0DTE", "Next Friday", "Manual Calendar"], group=grpData, tooltip="Auto Near-Term checks the next six weekdays. Auto Fridays checks the next six Friday dates. Auto modes use the locked ATM call contract to validate candidate expiries.")
autoExpiryChoice = input.int(1, "Auto Expiry Number", minval=1, maxval=6, group=grpData, tooltip="Choose the 1st, 2nd, 3rd, etc. valid expiry discovered by an Auto mode. The dashboard lists the dates found by the six probes.")
manualExpiryInput = input.time(timestamp("24 Jul 2026 12:00 -0400"), "Manual Expiry Date", group=grpData, tooltip="Click the date field to open TradingView's calendar picker. Leave the time near midday; only the calendar date is used.")
skipTodayAfterClose = input.bool(true, "Skip Today's Expiry After 4:15 PM ET", group=grpData, tooltip="Prevents an already-expired 0DTE contract from being selected after the regular options session.")

// Strike grid
strikeGridMode  = input.string("Auto", "Strike Grid Mode", options=["Auto", "Manual"], group=grpGrid, tooltip="Auto selects a practical listed-strike interval from the underlying price. This prevents expiry discovery from probing arbitrary strikes such as 516 when the chain is listed at 515/520. Manual uses the spacing and rounding values below.")
strikesAbove    = input.int(5, "Strikes Above ATM", minval=1, maxval=9, group=grpGrid)
strikesBelow    = input.int(5, "Strikes Below ATM", minval=1, maxval=9, group=grpGrid)
strikeSpacing   = input.float(1.0, "Manual Strike Spacing", minval=0.5, step=0.5, group=grpGrid)
roundTo         = input.float(1.0, "Manual ATM Rounding", minval=0.5, step=0.5, group=grpGrid)
useCustomAnchor = input.bool(false, "Use Custom Anchor Price", group=grpGrid)
customAnchor    = input.float(0.0, "Custom Anchor Price", group=grpGrid)

// Visuals
visualMode             = input.string("Chart Safe", "Visual Mode", options=["Chart Safe", "Full Profile"], group=grpVis, tooltip="Chart Safe limits drawings to levels near price and caps future offsets so the indicator does not crush the chart scale. Full Profile draws every active sampled strike and may require TradingView's Scale Price Chart Only setting.")
chartSafeRangePct      = input.float(10.0, "Chart-Safe Range from Price %", minval=2.0, maxval=50.0, step=1.0, group=grpVis, tooltip="Only drawings within this distance of current price are shown in Chart Safe mode. All sampled strikes still remain in the calculations and dashboard.")
showProfile            = input.bool(true, "Show Volume Profile", group=grpVis)
showLines              = input.bool(true, "Show Magnet Lines", group=grpVis)
showCloud              = input.bool(true, "Show Primary High-Volume Cluster", group=grpVis)
showATMLine            = input.bool(true, "Show Locked ATM Line", group=grpVis)
showRowLabels          = input.bool(false, "Show Strike Volume Labels", group=grpVis)
hideZeroVolumeRows     = input.bool(true, "Hide Zero-Volume Rows", group=grpVis)
showRowPercents        = input.bool(false, "Show Call/Put % on Row Labels", group=grpVis)
rowLabelSizeInput      = input.string("tiny", "Row Label Size", options=["tiny", "small", "normal"], group=grpVis)
rowLabelPosition       = input.string("Inside Bars", "Row Label Position", options=["Right of Bars", "Inside Bars", "Left of Bars"], group=grpVis)
rowLabelOffset         = input.int(3, "Row Label Offset", minval=0, maxval=30, group=grpVis)
showTop3Labels         = input.bool(false, "Show Top 3 Strike Labels", group=grpVis)
profileOffset          = input.int(4, "Profile Offset", minval=0, maxval=200, group=grpVis)
profileWidth           = input.int(14, "Max Profile Width", minval=5, maxval=100, group=grpVis)
lineBarsBack           = input.int(60, "Line Start Bars Back", minval=10, maxval=500, group=grpVis)
profileTransparency    = input.int(45, "Profile Transparency", minval=0, maxval=90, group=grpVis)
showRoundedVol         = input.bool(true, "Show Volume in K", group=grpVis)
topLabelExtraOffset    = input.int(2, "Top Label Extra Offset", minval=1, maxval=20, group=grpVis)

// Dashboard
showDash           = input.bool(true, "Show Dashboard", group=grpDash)
showForgeGuide     = input.bool(true, "Show Forge Guide", group=grpDash, tooltip="Scores every active sampled call and put for data quality, contract strength, side alignment, cluster structure, and underlying trend. Forge Confidence is confluence, not probability of profit. Confirm bid/ask spread, open interest, implied volatility, and Greeks with your broker.")
dashDetailInput    = input.string("Compact", "Dashboard Detail", options=["Compact", "Full"], group=grpDash, tooltip="Compact preserves chart space and leaves room for the separate Alpha Forge Guide. Full shows every diagnostic row.")
showZonesInDash    = input.bool(true, "Show Options Zones in Full Dashboard", group=grpDash)
showTop3InDash     = input.bool(true, "Show Top 3 Volume Strikes in Full Dashboard", group=grpDash)
dashPosInput       = input.string("Bottom Left", "Dashboard Position", options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group=grpDash, tooltip="Do not place this table at the same anchor as another indicator table. TradingView tables at the same position cover one another.")

// Forge Confidence / Risk
guideFastLen = input.int(9, "Underlying Fast EMA", minval=2, maxval=50, group=grpGuide)
guideSlowLen = input.int(21, "Underlying Slow EMA", minval=5, maxval=200, group=grpGuide)
guideRsiLen  = input.int(14, "Underlying RSI Length", minval=5, maxval=50, group=grpGuide)

// Liquidity / chain quality
thinVolumeThreshold   = input.int(5000, "Thin Sampled Volume Threshold", minval=100, step=100, group=grpLiq)
activeVolumeThreshold = input.int(50000, "Active Sampled Volume Threshold", minval=1000, step=1000, group=grpLiq)
thinChainFoundPct     = input.float(40.0, "Thin Warning if Current Contracts % Below", minval=5, maxval=100, step=5, group=grpLiq)
thinChainActiveCount  = input.int(4, "Thin Warning if Active Contracts Below", minval=1, maxval=20, group=grpLiq)
capCpRatioDisplay     = input.float(10.0, "Cap Call/Put Ratio Display Above", minval=2.0, maxval=100.0, step=0.5, group=grpLiq)
zoneVolumePct         = input.float(50.0, "Cluster Threshold % of Max Volume", minval=20.0, maxval=90.0, step=5.0, group=grpLiq)

// Debug
showDataStatus       = input.bool(true, "Show Data Status in Dashboard", group=grpDebug)
showDebugSymbols     = input.bool(false, "Show Sample ATM Option Symbols", group=grpDebug)
showNoDataWarning    = input.bool(true, "Show Data / Expiry Warning on Chart", group=grpDebug)
showThinChainWarning = input.bool(true, "Show Thin-Chain Warning on Chart", group=grpDebug)
dataGraceSeconds     = input.int(45, "Realtime Option-Feed Grace Seconds", minval=0, maxval=120, group=grpDebug, tooltip="Suppresses temporary stale/no-volume chart warnings while TradingView initializes the requested option contexts after a load, symbol change, or settings change. The dashboard shows Loading Current Data during the grace period.")
showDelayedFeedWarning = input.bool(false, "Show Delayed / Prior-Session Warning on Chart", group=grpDebug, tooltip="Off by default because some option feeds briefly return prior-session data while loading. The dashboard always reports the data state.")

// Alpha Forge colors
callColor    = input.color(color.rgb(41, 211, 255), "Call Color", group=grpColor)
putColor     = input.color(color.rgb(192, 192, 192), "Put Color", group=grpColor)
neutralColor = input.color(color.rgb(93, 107, 122), "Neutral Color", group=grpColor)
pocColor     = input.color(color.yellow, "POC Color", group=grpColor)
atmColor     = input.color(color.orange, "ATM Color", group=grpColor)
zoneColor    = input.color(color.new(color.rgb(41, 211, 255), 92), "Primary Cluster Cloud", group=grpColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_dashPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_size(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_inZone(float strike, float lo, float hi) =>
    not na(strike) and not na(lo) and not na(hi) and strike >= lo and strike <= hi

f_addReason(string base, string next) =>
    base == "" ? next : base + " | " + next

f_confGrade(float score) =>
    na(score) ? "n/a" : score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "Watch" : "Low"

f_riskGrade(float riskScore) =>
    na(riskScore) ? "n/a" : riskScore <= 25 ? "Low" : riskScore <= 45 ? "Moderate" : riskScore <= 65 ? "Elevated" : "High"

f_roundTo(float v, float nearest) =>
    math.round(v / nearest) * nearest

f_autoStrikeStep(float price) =>
    // Coarser round strikes are generally listed even when the chain also has
    // finer increments. This makes one-request-per-expiry discovery much more
    // reliable on high-priced underlyings without increasing request usage.
    price < 25.0 ? 0.5 :
     price < 100.0 ? 1.0 :
     price < 250.0 ? 2.5 :
     5.0

f_fmtVol(float v) =>
    float absV = math.abs(v)
    string sign = v < 0 ? "-" : ""
    showRoundedVol and absV >= 1000 ? sign + str.tostring(math.round(absV / 1000.0)) + "k" : sign + str.tostring(math.round(absV))

f_fmtDist(float v) =>
    str.tostring(v, "#.00")

f_fmtPct(float v) =>
    str.tostring(v, "#.00") + "%"

f_fmtRatio(float calls, float puts) =>
    calls <= 0 and puts <= 0 ? "n/a" :
     puts <= 0 ? ">" + str.tostring(capCpRatioDisplay, "#.0") :
     calls / puts > capCpRatioDisplay ? ">" + str.tostring(capCpRatioDisplay, "#.0") :
     str.tostring(calls / puts, "#.00")

f_zoneText(float lo, float hi) =>
    na(lo) or na(hi) ? "n/a" : lo == hi ? str.tostring(lo) : str.tostring(lo) + " - " + str.tostring(hi)

f_strikeText(float s) =>
    s == math.floor(s) ? str.tostring(s, "#") + ".0" : str.tostring(s)

f_occStrike(float s) =>
    string raw = str.tostring(math.round(s * 1000.0))
    int pad = math.max(0, 8 - str.length(raw))
    str.repeat("0", pad) + raw

f_two(int n) =>
    str.format("{0,number,00}", n)

f_dateKey(int ts) =>
    na(ts) ? na : year(ts, OPT_TZ) * 10000 + month(ts, OPT_TZ) * 100 + dayofmonth(ts, OPT_TZ)

f_dateText(int ts) =>
    na(ts) ? "n/a" : str.tostring(year(ts, OPT_TZ)) + "-" + f_two(month(ts, OPT_TZ)) + "-" + f_two(dayofmonth(ts, OPT_TZ))

f_shortDateText(int ts) =>
    na(ts) ? "n/a" : f_two(month(ts, OPT_TZ)) + "/" + f_two(dayofmonth(ts, OPT_TZ))

f_normalizeDate(int ts) =>
    timestamp(OPT_TZ, year(ts, OPT_TZ), month(ts, OPT_TZ), dayofmonth(ts, OPT_TZ), 12, 0)

f_optionSymbol(string base, int expiryTs, string side, float strike) =>
    int yyFull = year(expiryTs, OPT_TZ)
    int mm = month(expiryTs, OPT_TZ)
    int dd = dayofmonth(expiryTs, OPT_TZ)
    string yy = f_two(yyFull % 100)
    string mo = f_two(mm)
    string dy = f_two(dd)
    string strikePart = symbolFormat == "OCC Padded" ? f_occStrike(strike) : f_strikeText(strike)
    symbolPrefix + base + yy + mo + dy + side + strikePart

f_optionData(string optionSymbol) =>
    request.security(optionSymbol, "D", [close, volume, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=3)

f_scoreCandidate(string side, float strike, float contractVol, float optionPrice, float sideTotalVol, float sidePct, float sideZoneLow, float sideZoneHigh, float primaryLow, float primaryHigh, float poc, float refPrice, float step, float currentPctValue, bool thinChain, string liquidityState, int dte, float maxContractVol, float avgActiveVol, float emaFastValue, float emaSlowValue, float emaSlowPrev, float rsiValue, float momentumValue) =>
    // 20 points: data quality.
    float dataPts = currentPctValue >= 99.5 ? 20.0 : currentPctValue >= 80.0 ? 16.0 : currentPctValue >= 60.0 ? 10.0 : currentPctValue >= 40.0 ? 5.0 : 0.0
    dataPts := thinChain ? math.max(0.0, dataPts - 3.0) : dataPts

    // 25 points: individual contract strength.
    float maxShare = maxContractVol > 0 ? contractVol / maxContractVol : 0.0
    float avgRatio = avgActiveVol > 0 ? contractVol / avgActiveVol : 0.0
    float sideShare = sideTotalVol > 0 ? contractVol / sideTotalVol : 0.0
    float strengthPts = f_clamp(maxShare, 0.0, 1.0) * 10.0 + f_clamp(avgRatio / 3.0, 0.0, 1.0) * 8.0 + f_clamp(sideShare / 0.35, 0.0, 1.0) * 7.0

    // 20 points: agreement with the sampled call/put activity mix.
    float directionPts = sidePct >= 75.0 ? 20.0 : sidePct >= 65.0 ? 17.0 : sidePct >= 58.0 ? 14.0 : sidePct >= 52.0 ? 10.0 : sidePct >= 48.0 ? 6.0 : sidePct >= 40.0 ? 3.0 : 0.0

    // 20 points: strike / cluster structure.
    bool inSideCluster = f_inZone(strike, sideZoneLow, sideZoneHigh)
    bool inPrimaryCluster = f_inZone(strike, primaryLow, primaryHigh)
    bool nearPoc = not na(poc) and math.abs(strike - poc) <= step * 0.51
    bool nearAtm = math.abs(strike - refPrice) <= step * 0.51
    float structurePts = (inSideCluster ? 8.0 : 0.0) + (inPrimaryCluster ? 5.0 : 0.0) + (nearPoc ? 4.0 : 0.0) + (nearAtm ? 3.0 : 0.0)

    // 15 points: underlying price trend confirmation.
    bool isCall = side == "C"
    float trendPts = 0.0
    trendPts += isCall ? (refPrice > emaSlowValue ? 5.0 : 0.0) : (refPrice < emaSlowValue ? 5.0 : 0.0)
    trendPts += isCall ? (emaFastValue > emaSlowValue ? 4.0 : 0.0) : (emaFastValue < emaSlowValue ? 4.0 : 0.0)
    trendPts += isCall ? (emaSlowValue > emaSlowPrev ? 3.0 : 0.0) : (emaSlowValue < emaSlowPrev ? 3.0 : 0.0)
    trendPts += isCall ? (rsiValue >= 55.0 and momentumValue > 0 ? 3.0 : rsiValue >= 50.0 ? 1.0 : 0.0) : (rsiValue <= 45.0 and momentumValue < 0 ? 3.0 : rsiValue <= 50.0 ? 1.0 : 0.0)

    float confidence = f_clamp(dataPts + strengthPts + directionPts + structurePts + trendPts, 0.0, 100.0)

    // Separate 0-100 risk score. This does not reduce confidence because a
    // contract can have strong confluence while remaining high risk.
    float dteRisk = na(dte) ? 20.0 : dte <= 0 ? 45.0 : dte == 1 ? 32.0 : dte <= 3 ? 24.0 : dte <= 7 ? 15.0 : dte <= 14 ? 8.0 : 4.0
    float distanceSteps = step > 0 ? math.abs(strike - refPrice) / step : 0.0
    float distanceRisk = distanceSteps <= 0.55 ? 4.0 : distanceSteps <= 1.5 ? 9.0 : distanceSteps <= 2.5 ? 16.0 : distanceSteps <= 4.0 ? 23.0 : 30.0
    float liquidityRisk = liquidityState == "Active" ? 2.0 : liquidityState == "Moderate" ? 10.0 : liquidityState == "Thin" ? 20.0 : 25.0
    float dataRisk = currentPctValue >= 90.0 ? 0.0 : currentPctValue >= 75.0 ? 6.0 : currentPctValue >= 60.0 ? 12.0 : 20.0
    float priceRisk = na(optionPrice) ? 8.0 : optionPrice < 0.25 ? 12.0 : optionPrice < 0.50 ? 7.0 : 0.0
    float risk = f_clamp(dteRisk + distanceRisk + liquidityRisk + dataRisk + priceRisk, 0.0, 100.0)

    [confidence, risk, dataPts, strengthPts, directionPts, structurePts, trendPts]

f_clearBoxes(array<box> arr) =>
    while array.size(arr) > 0
        box.delete(array.pop(arr))

f_clearLines(array<line> arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

f_clearLabels(array<label> arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

f_primaryCluster(array<float> strikeArr, array<float> volArr, float threshold, float refPrice) =>
    float bestLow = na
    float bestHigh = na
    float bestSum = -1.0
    float bestDist = na

    bool inRun = false
    float runLow = na
    float runHigh = na
    float runSum = 0.0

    int n = array.size(strikeArr)
    if n > 0 and threshold > 0
        for i = 0 to n - 1
            float s = array.get(strikeArr, i)
            float v = array.get(volArr, i)
            bool qualifies = v >= threshold

            if qualifies
                if not inRun
                    inRun := true
                    runLow := s
                    runHigh := s
                    runSum := v
                else
                    runHigh := s
                    runSum += v

            bool endRun = inRun and (not qualifies or i == n - 1)
            if endRun
                float runMid = (runLow + runHigh) / 2.0
                float runDist = math.abs(refPrice - runMid)
                bool betterRun = runSum > bestSum or (runSum == bestSum and (na(bestDist) or runDist < bestDist))

                if betterRun
                    bestLow := runLow
                    bestHigh := runHigh
                    bestSum := runSum
                    bestDist := runDist

                inRun := false
                runLow := na
                runHigh := na
                runSum := 0.0

    [bestLow, bestHigh]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EFFECTIVE SETTINGS / SAFETY LIMITS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string baseSymbol = useCustomBase ? customBase : syminfo.ticker
bool autoExpiryMode = expiryMode == "Auto Near-Term" or expiryMode == "Auto Fridays"

// Auto expiry scanning reserves six request contexts. Capping each side at eight
// keeps the script at or below Pine's standard 40-unique-request ceiling.
int effectiveAbove = autoExpiryMode ? math.min(strikesAbove, 8) : strikesAbove
int effectiveBelow = autoExpiryMode ? math.min(strikesBelow, 8) : strikesBelow
bool autoGridCapped = autoExpiryMode and (strikesAbove > effectiveAbove or strikesBelow > effectiveBelow)

int requestedContracts = (effectiveAbove + effectiveBelow + 1) * 2
bool chartTfSupported = timeframe.isintraday or timeframe.isdaily

float atr14 = ta.atr(14)
float guideEmaFast = ta.ema(close, guideFastLen)
float guideEmaSlow = ta.ema(close, guideSlowLen)
float guideRsi = ta.rsi(close, guideRsiLen)
float guideMomentum = close - close[3]
rowLabelSize = f_size(rowLabelSizeInput)

bool chartSafeVisuals = visualMode == "Chart Safe"
int effectiveProfileOffset = chartSafeVisuals ? math.min(profileOffset, 4) : profileOffset
int effectiveProfileWidth = chartSafeVisuals ? math.min(profileWidth, 14) : profileWidth
int effectiveLineBarsBack = chartSafeVisuals ? math.min(lineBarsBack, 60) : lineBarsBack
int effectiveTopLabelOffset = chartSafeVisuals ? math.min(topLabelExtraOffset, 2) : topLabelExtraOffset

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS / STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> strikes   = array.new_float()
var array<float> callVols   = array.new_float()
var array<float> putVols    = array.new_float()
var array<float> callPrices = array.new_float()
var array<float> putPrices  = array.new_float()
var array<float> totalVols  = array.new_float()

var array<box> profileBoxes = array.new<box>()
var array<line> magnetLines = array.new<line>()
var array<label> infoLabels = array.new<label>()

var array<int> expiryCandidates = array.new_int()
var array<int> validExpiryCandidates = array.new_int()

var float lockedAtm = na
var float lockedStrikeSpacing = na
var float lockedRoundTo = na
var int lockedExpiryTs = na
var int probedExpiries = 0
var int validExpiryCount = 0
var string validExpiryListText = "n/a"
var string expiryStatusText = "Waiting for historical initialization"

var int foundContracts = 0
var int currentContracts = 0
var int activeVolumeContracts = 0
var int latestOptionBarTime = na
var string sampleCallSymbol = ""
var string samplePutSymbol = ""

// Persists across realtime ticks so a temporary option-feed initialization
// state does not flash a false red warning after loading or changing symbols.
varip int realtimeWarmupStart = na
if barstate.isrealtime and na(realtimeWarmupStart)
    realtimeWarmupStart := timenow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOCK REQUEST UNIVERSE + RESOLVE EXPIRY ON LAST HISTORICAL BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islastconfirmedhistory and chartTfSupported
    if na(lockedAtm)
        float anchorSource = useCustomAnchor and customAnchor > 0 ? customAnchor : close
        float autoStep = f_autoStrikeStep(anchorSource)
        lockedStrikeSpacing := strikeGridMode == "Auto" ? autoStep : strikeSpacing
        lockedRoundTo := strikeGridMode == "Auto" ? autoStep : roundTo
        lockedAtm := f_roundTo(anchorSource, lockedRoundTo)

    int nowYear = year(timenow, OPT_TZ)
    int nowMonth = month(timenow, OPT_TZ)
    int nowDay = dayofmonth(timenow, OPT_TZ)
    int todayNoon = timestamp(OPT_TZ, nowYear, nowMonth, nowDay, 12, 0)

    int nowHour = hour(timenow, OPT_TZ)
    int nowMinute = minute(timenow, OPT_TZ)
    bool afterClose = nowHour > 16 or (nowHour == 16 and nowMinute >= 15)
    bool skipToday = skipTodayAfterClose and afterClose

    array.clear(expiryCandidates)
    array.clear(validExpiryCandidates)
    probedExpiries := 0
    validExpiryCount := 0
    validExpiryListText := "n/a"

    if expiryMode == "Auto Near-Term"
        int startOffset = skipToday ? 1 : 0
        for d = 0 to 13
            if array.size(expiryCandidates) < AUTO_PROBE_COUNT
                int candidateTs = todayNoon + (d + startOffset) * DAY_MS
                int candidateDow = dayofweek(candidateTs, OPT_TZ)
                bool weekday = candidateDow >= dayofweek.monday and candidateDow <= dayofweek.friday
                if weekday
                    array.push(expiryCandidates, candidateTs)

    else if expiryMode == "Auto Fridays"
        int currentDow = dayofweek(todayNoon, OPT_TZ)
        int daysToFriday = (dayofweek.friday - currentDow + 7) % 7
        if daysToFriday == 0 and skipToday
            daysToFriday := 7

        for n = 0 to AUTO_PROBE_COUNT - 1
            array.push(expiryCandidates, todayNoon + (daysToFriday + n * 7) * DAY_MS)

    else if expiryMode == "Today / 0DTE"
        if skipToday
            lockedExpiryTs := na
            expiryStatusText := "Today expired after 4:15 PM ET"
        else
            lockedExpiryTs := todayNoon
            expiryStatusText := "Today / 0DTE preset"

    else if expiryMode == "Next Friday"
        int currentDow = dayofweek(todayNoon, OPT_TZ)
        int daysToFriday = (dayofweek.friday - currentDow + 7) % 7
        daysToFriday := daysToFriday == 0 ? 7 : daysToFriday
        lockedExpiryTs := todayNoon + daysToFriday * DAY_MS
        expiryStatusText := "Next Friday preset"

    else
        lockedExpiryTs := f_normalizeDate(manualExpiryInput)
        expiryStatusText := "Manual calendar"
        validExpiryListText := "Manual: " + f_shortDateText(lockedExpiryTs)

    if not autoExpiryMode and expiryMode != "Manual Calendar"
        validExpiryListText := na(lockedExpiryTs) ? "none" : f_shortDateText(lockedExpiryTs)

    if autoExpiryMode
        lockedExpiryTs := na
        validExpiryListText := ""

        for i = 0 to array.size(expiryCandidates) - 1
            int candidateTs = array.get(expiryCandidates, i)
            string probeSymbol = f_optionSymbol(baseSymbol, candidateTs, "C", lockedAtm)
            [probeClose, probeVolume, probeTime] = f_optionData(probeSymbol)
            probedExpiries += 1

            bool candidateValid = not na(probeClose) or not na(probeTime)
            if candidateValid
                array.push(validExpiryCandidates, candidateTs)
                validExpiryListText := validExpiryListText == "" ? f_shortDateText(candidateTs) : validExpiryListText + ", " + f_shortDateText(candidateTs)

        validExpiryCount := array.size(validExpiryCandidates)
        if validExpiryCount >= autoExpiryChoice
            lockedExpiryTs := array.get(validExpiryCandidates, autoExpiryChoice - 1)
            expiryStatusText := "Auto #" + str.tostring(autoExpiryChoice) + " selected | " + str.tostring(validExpiryCount) + " valid"
        else
            expiryStatusText := validExpiryCount == 0 ? "No valid expiry found" : "Auto #" + str.tostring(autoExpiryChoice) + " unavailable | " + str.tostring(validExpiryCount) + " valid"

        if validExpiryListText == ""
            validExpiryListText := "none"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST OPTION DATA
// Runs on the last confirmed historical bar to initialize contexts, then on
// the current last bar for live updates. The ATM and expiry remain locked.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool requestPass = chartTfSupported and not na(lockedAtm) and not na(lockedStrikeSpacing) and not na(lockedExpiryTs) and (barstate.islastconfirmedhistory or barstate.islast)

if requestPass
    array.clear(strikes)
    array.clear(callVols)
    array.clear(putVols)
    array.clear(callPrices)
    array.clear(putPrices)
    array.clear(totalVols)

    foundContracts := 0
    currentContracts := 0
    activeVolumeContracts := 0
    latestOptionBarTime := na
    sampleCallSymbol := ""
    samplePutSymbol := ""

    int observationDateKey = f_dateKey(timenow)

    for i = -effectiveBelow to effectiveAbove
        float strike = lockedAtm + i * lockedStrikeSpacing
        strike := math.round(strike * 10.0) / 10.0

        string callSym = f_optionSymbol(baseSymbol, lockedExpiryTs, "C", strike)
        string putSym = f_optionSymbol(baseSymbol, lockedExpiryTs, "P", strike)

        if i == 0
            sampleCallSymbol := callSym
            samplePutSymbol := putSym

        [cCloseRaw, cVolRaw, cTimeRaw] = f_optionData(callSym)
        [pCloseRaw, pVolRaw, pTimeRaw] = f_optionData(putSym)

        bool cFound = not na(cCloseRaw) or not na(cTimeRaw)
        bool pFound = not na(pCloseRaw) or not na(pTimeRaw)

        bool cCurrent = cFound and not na(cTimeRaw) and f_dateKey(cTimeRaw) == observationDateKey
        bool pCurrent = pFound and not na(pTimeRaw) and f_dateKey(pTimeRaw) == observationDateKey

        if cFound
            foundContracts += 1
        if pFound
            foundContracts += 1

        if cCurrent
            currentContracts += 1
        if pCurrent
            currentContracts += 1

        float cVol = cCurrent and not na(cVolRaw) ? cVolRaw : 0.0
        float pVol = pCurrent and not na(pVolRaw) ? pVolRaw : 0.0
        float cPrice = cCurrent and not na(cCloseRaw) ? cCloseRaw : na
        float pPrice = pCurrent and not na(pCloseRaw) ? pCloseRaw : na

        if cVol > 0
            activeVolumeContracts += 1
        if pVol > 0
            activeVolumeContracts += 1

        if not na(cTimeRaw) and (na(latestOptionBarTime) or cTimeRaw > latestOptionBarTime)
            latestOptionBarTime := cTimeRaw
        if not na(pTimeRaw) and (na(latestOptionBarTime) or pTimeRaw > latestOptionBarTime)
            latestOptionBarTime := pTimeRaw

        float total = cVol + pVol

        array.push(strikes, strike)
        array.push(callVols, cVol)
        array.push(putVols, pVol)
        array.push(callPrices, cPrice)
        array.push(putPrices, pPrice)
        array.push(totalVols, total)

else if barstate.islast
    array.clear(strikes)
    array.clear(callVols)
    array.clear(putVols)
    array.clear(callPrices)
    array.clear(putPrices)
    array.clear(totalVols)

    foundContracts := 0
    currentContracts := 0
    activeVolumeContracts := 0
    latestOptionBarTime := na
    sampleCallSymbol := ""
    samplePutSymbol := ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float totalCallVol = array.size(callVols) > 0 ? array.sum(callVols) : 0.0
float totalPutVol = array.size(putVols) > 0 ? array.sum(putVols) : 0.0
float totalOptVol = totalCallVol + totalPutVol

float maxTotalVol = array.size(totalVols) > 0 ? array.max(totalVols) : 0.0
float maxCallVol = array.size(callVols) > 0 ? array.max(callVols) : 0.0
float maxPutVol = array.size(putVols) > 0 ? array.max(putVols) : 0.0

float pocStrike = na
float pocVol = -1.0
float topCallStrike = na
float topCallVol = -1.0
float topCallPrice = na
float topPutStrike = na
float topPutVol = -1.0
float topPutPrice = na

float top1Strike = na
float top2Strike = na
float top3Strike = na
float top1Vol = -1.0
float top2Vol = -1.0
float top3Vol = -1.0

if array.size(strikes) > 0
    for i = 0 to array.size(strikes) - 1
        float s = array.get(strikes, i)
        float c = array.get(callVols, i)
        float p = array.get(putVols, i)
        float cPrice = array.get(callPrices, i)
        float pPrice = array.get(putPrices, i)
        float t = array.get(totalVols, i)

        bool betterPoc = t > 0 and (t > pocVol or (t == pocVol and (na(pocStrike) or math.abs(s - close) < math.abs(pocStrike - close))))
        if betterPoc
            pocStrike := s
            pocVol := t

        bool betterCall = c > 0 and (c > topCallVol or (c == topCallVol and (na(topCallStrike) or math.abs(s - close) < math.abs(topCallStrike - close))))
        if betterCall
            topCallStrike := s
            topCallVol := c
            topCallPrice := cPrice

        bool betterPut = p > 0 and (p > topPutVol or (p == topPutVol and (na(topPutStrike) or math.abs(s - close) < math.abs(topPutStrike - close))))
        if betterPut
            topPutStrike := s
            topPutVol := p
            topPutPrice := pPrice

        if t > 0
            if t > top1Vol
                top3Vol := top2Vol
                top3Strike := top2Strike
                top2Vol := top1Vol
                top2Strike := top1Strike
                top1Vol := t
                top1Strike := s
            else if t > top2Vol
                top3Vol := top2Vol
                top3Strike := top2Strike
                top2Vol := t
                top2Strike := s
            else if t > top3Vol
                top3Vol := t
                top3Strike := s

float callPct = totalOptVol > 0 ? totalCallVol / totalOptVol * 100.0 : 0.0
float putPct = totalOptVol > 0 ? totalPutVol / totalOptVol * 100.0 : 0.0
float cpRatio = totalPutVol > 0 ? totalCallVol / totalPutVol : na
string cpRatioText = f_fmtRatio(totalCallVol, totalPutVol)
float callPutDiff = totalCallVol - totalPutVol

float foundPct = requestedContracts > 0 ? float(foundContracts) / float(requestedContracts) * 100.0 : 0.0
float currentPct = requestedContracts > 0 ? float(currentContracts) / float(requestedContracts) * 100.0 : 0.0
int staleContracts = math.max(0, foundContracts - currentContracts)

int currentEtDateKey = f_dateKey(timenow)
int selectedExpiryDateKey = f_dateKey(lockedExpiryTs)
bool expiryPassed = not na(selectedExpiryDateKey) and currentEtDateKey > selectedExpiryDateKey
float gridLow = not na(lockedAtm) and not na(lockedStrikeSpacing) ? lockedAtm - effectiveBelow * lockedStrikeSpacing : na
float gridHigh = not na(lockedAtm) and not na(lockedStrikeSpacing) ? lockedAtm + effectiveAbove * lockedStrikeSpacing : na
bool gridOutOfRange = not na(gridLow) and not na(gridHigh) and (close < gridLow or close > gridHigh)
string gridStatusText = na(lockedAtm) ? "n/a" : gridOutOfRange ? "Price outside — reload" : "Locked / covered"

string dataStatus = not chartTfSupported ? "Unsupported Chart TF" :
     na(lockedExpiryTs) ? "No Valid Expiry" :
     expiryPassed ? "Expiry Passed / Reload" :
     totalOptVol > 0 and currentContracts == requestedContracts ? "Loaded" :
     totalOptVol > 0 ? "Loaded / Partial" :
     currentContracts > 0 ? "Current / No Volume" :
     foundContracts > 0 ? "Stale / Prior Session" :
     "No Contract Data"

color dataStatusColor = dataStatus == "Loaded" ? callColor :
     dataStatus == "Loaded / Partial" ? atmColor :
     dataStatus == "Current / No Volume" ? atmColor :
     putColor

int warmupElapsedMs = barstate.isrealtime and not na(realtimeWarmupStart) ? math.max(0, timenow - realtimeWarmupStart) : dataGraceSeconds * 1000
bool optionFeedWarmup = barstate.isrealtime and dataGraceSeconds > 0 and warmupElapsedMs < dataGraceSeconds * 1000 and chartTfSupported and not na(lockedExpiryTs) and not expiryPassed and totalOptVol <= 0
string displayDataStatus = optionFeedWarmup ? "Loading Current Data" : dataStatus
color displayDataStatusColor = optionFeedWarmup ? atmColor : dataStatusColor

bool isThinChain = totalOptVol > 0 and (currentPct < thinChainFoundPct or activeVolumeContracts < thinChainActiveCount)

string liqStatus = totalOptVol == 0 ? "n/a" :
     totalOptVol < thinVolumeThreshold ? "Thin" :
     totalOptVol >= activeVolumeThreshold ? "Active" :
     "Moderate"

color liqColor = liqStatus == "Active" ? callColor : liqStatus == "Moderate" ? atmColor : liqStatus == "Thin" ? putColor : neutralColor

string activityText = totalOptVol == 0 ? displayDataStatus :
     callPct > 58 ? "Call Activity Dominant" :
     putPct > 58 ? "Put Activity Dominant" :
     "Balanced Activity"

color activityColor = activityText == "Call Activity Dominant" ? callColor :
     activityText == "Put Activity Dominant" ? putColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONTIGUOUS PRIMARY CLUSTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float zoneThresholdTotal = maxTotalVol * (zoneVolumePct / 100.0)
float zoneThresholdCall = maxCallVol * (zoneVolumePct / 100.0)
float zoneThresholdPut = maxPutVol * (zoneVolumePct / 100.0)

[zoneLow, zoneHigh] = f_primaryCluster(strikes, totalVols, zoneThresholdTotal, close)
[callZoneLow, callZoneHigh] = f_primaryCluster(strikes, callVols, zoneThresholdCall, close)
[putZoneLow, putZoneHigh] = f_primaryCluster(strikes, putVols, zoneThresholdPut, close)

string keyZoneText = f_zoneText(zoneLow, zoneHigh)
string callZoneText = f_zoneText(callZoneLow, callZoneHigh)
string putZoneText = f_zoneText(putZoneLow, putZoneHigh)

string clusterPosition = na(zoneLow) or na(zoneHigh) ? "n/a" :
     close < zoneLow ? "Above Price" :
     close > zoneHigh ? "Below Price" :
     "Around Price"

color clusterColor = clusterPosition == "Above Price" ? callColor :
     clusterPosition == "Below Price" ? putColor :
     clusterPosition == "Around Price" ? atmColor :
     neutralColor

// Distances are level minus price: positive means the level is above price.
float distToPoc = not na(pocStrike) ? pocStrike - close : na
float distToTopCall = not na(topCallStrike) ? topCallStrike - close : na
float distToTopPut = not na(topPutStrike) ? topPutStrike - close : na
float distToAtm = not na(lockedAtm) ? lockedAtm - close : na

// Nearest unique magnet among POC, top call, and top put.
float nearestMagnet = na
float nearestDistAbs = na

if not na(pocStrike)
    nearestMagnet := pocStrike
    nearestDistAbs := math.abs(pocStrike - close)

if not na(topCallStrike)
    float d = math.abs(topCallStrike - close)
    if na(nearestDistAbs) or d < nearestDistAbs
        nearestMagnet := topCallStrike
        nearestDistAbs := d

if not na(topPutStrike)
    float d = math.abs(topPutStrike - close)
    if na(nearestDistAbs) or d < nearestDistAbs
        nearestMagnet := topPutStrike
        nearestDistAbs := d

float nearestDist = not na(nearestMagnet) ? nearestMagnet - close : na
float nearestMagnetPct = not na(nearestMagnet) and close != 0 ? (nearestMagnet - close) / close * 100.0 : na

string top1Text = na(top1Strike) ? "n/a" : str.tostring(top1Strike) + " / " + f_fmtVol(top1Vol)
string top2Text = na(top2Strike) ? "n/a" : str.tostring(top2Strike) + " / " + f_fmtVol(top2Vol)
string top3Text = na(top3Strike) ? "n/a" : str.tostring(top3Strike) + " / " + f_fmtVol(top3Vol)

float effectiveGridSpacing = not na(lockedStrikeSpacing) ? lockedStrikeSpacing : strikeSpacing
float chartSafeDistance = math.max(close * chartSafeRangePct / 100.0, effectiveGridSpacing * 0.55)
string gridModeText = strikeGridMode == "Auto" ? "Auto " + str.tostring(effectiveGridSpacing) : "Manual " + str.tostring(effectiveGridSpacing)
string selectedExpiryText = f_dateText(lockedExpiryTs)
string observationDateText = f_dateText(timenow)
string latestOptionDateText = f_dateText(latestOptionBarTime)
string effectiveGridText = str.tostring(effectiveBelow) + " below / " + str.tostring(effectiveAbove) + " above @ " + str.tostring(effectiveGridSpacing) + (autoGridCapped ? " (Auto cap)" : "")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FORGE GUIDE — SCORED CONTRACT CONFLUENCE + SEPARATE RISK
// Confidence is a 0-100 confluence score, not probability of profit.
// The model scores every active sampled call and put, then selects the
// highest-confidence contract. Risk is calculated independently.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float maxIndividualContractVol = math.max(maxCallVol, maxPutVol)
float avgActiveContractVol = activeVolumeContracts > 0 ? totalOptVol / activeVolumeContracts : 0.0
int currentEtNoon = f_normalizeDate(timenow)
int guideDte = na(lockedExpiryTs) ? na : math.max(0, int(math.round(float(lockedExpiryTs - currentEtNoon) / DAY_MS)))

string guideSide = ""
float guideStrike = na
float guideVolume = na
float guideOptionPrice = na
float guideConfidence = na
float guideRiskScore = na
float guideDataPts = na
float guideStrengthPts = na
float guideDirectionPts = na
float guideStructurePts = na
float guideTrendPts = na

if array.size(strikes) > 0 and totalOptVol > 0
    for i = 0 to array.size(strikes) - 1
        float candidateStrike = array.get(strikes, i)
        float candidateCallVol = array.get(callVols, i)
        float candidatePutVol = array.get(putVols, i)
        float candidateCallPrice = array.get(callPrices, i)
        float candidatePutPrice = array.get(putPrices, i)

        if candidateCallVol > 0
            [candidateScore, candidateRisk, candidateData, candidateStrength, candidateDirection, candidateStructure, candidateTrend] = f_scoreCandidate("C", candidateStrike, candidateCallVol, candidateCallPrice, totalCallVol, callPct, callZoneLow, callZoneHigh, zoneLow, zoneHigh, pocStrike, close, effectiveGridSpacing, currentPct, isThinChain, liqStatus, guideDte, maxIndividualContractVol, avgActiveContractVol, guideEmaFast, guideEmaSlow, guideEmaSlow[1], guideRsi, guideMomentum)
            bool betterCallCandidate = na(guideConfidence) or candidateScore > guideConfidence or (candidateScore == guideConfidence and (na(guideRiskScore) or candidateRisk < guideRiskScore)) or (candidateScore == guideConfidence and candidateRisk == guideRiskScore and (na(guideVolume) or candidateCallVol > guideVolume))
            if betterCallCandidate
                guideSide := "C"
                guideStrike := candidateStrike
                guideVolume := candidateCallVol
                guideOptionPrice := candidateCallPrice
                guideConfidence := candidateScore
                guideRiskScore := candidateRisk
                guideDataPts := candidateData
                guideStrengthPts := candidateStrength
                guideDirectionPts := candidateDirection
                guideStructurePts := candidateStructure
                guideTrendPts := candidateTrend

        if candidatePutVol > 0
            [candidateScore, candidateRisk, candidateData, candidateStrength, candidateDirection, candidateStructure, candidateTrend] = f_scoreCandidate("P", candidateStrike, candidatePutVol, candidatePutPrice, totalPutVol, putPct, putZoneLow, putZoneHigh, zoneLow, zoneHigh, pocStrike, close, effectiveGridSpacing, currentPct, isThinChain, liqStatus, guideDte, maxIndividualContractVol, avgActiveContractVol, guideEmaFast, guideEmaSlow, guideEmaSlow[1], guideRsi, guideMomentum)
            bool betterPutCandidate = na(guideConfidence) or candidateScore > guideConfidence or (candidateScore == guideConfidence and (na(guideRiskScore) or candidateRisk < guideRiskScore)) or (candidateScore == guideConfidence and candidateRisk == guideRiskScore and (na(guideVolume) or candidatePutVol > guideVolume))
            if betterPutCandidate
                guideSide := "P"
                guideStrike := candidateStrike
                guideVolume := candidatePutVol
                guideOptionPrice := candidatePutPrice
                guideConfidence := candidateScore
                guideRiskScore := candidateRisk
                guideDataPts := candidateData
                guideStrengthPts := candidateStrength
                guideDirectionPts := candidateDirection
                guideStructurePts := candidateStructure
                guideTrendPts := candidateTrend

string guideMoneyness = "n/a"
if not na(guideStrike)
    bool guideAtm = math.abs(guideStrike - close) <= effectiveGridSpacing * 0.51
    guideMoneyness := guideAtm ? "ATM" : guideSide == "C" ? (guideStrike < close ? "ITM" : "OTM") : (guideStrike > close ? "ITM" : "OTM")

string guideContractText = na(guideStrike) ? "n/a" : baseSymbol + " " + f_shortDateText(lockedExpiryTs) + " " + f_strikeText(guideStrike) + guideSide
string guidePriceText = na(guideOptionPrice) ? "price n/a" : "$" + str.tostring(guideOptionPrice, "#.00")
string guideBasisText = na(guideVolume) ? (optionFeedWarmup ? "Loading active contracts..." : "No active contract in sampled grid") : f_fmtVol(guideVolume) + " volume | " + guidePriceText + " | " + guideMoneyness
string guideConfidenceGrade = f_confGrade(guideConfidence)
string guideRiskGrade = f_riskGrade(guideRiskScore)
string guideConfidenceText = na(guideConfidence) ? "n/a" : str.tostring(math.round(guideConfidence)) + " / " + guideConfidenceGrade + " confluence"
string guideRiskText = na(guideRiskScore) ? "n/a" : guideRiskGrade + " | " + str.tostring(math.round(guideRiskScore)) + "/100 | " + (na(guideDte) ? "DTE n/a" : str.tostring(guideDte) + " DTE")
string guideScoreMixText = na(guideConfidence) ? "n/a" : "D" + str.tostring(math.round(guideDataPts)) + " S" + str.tostring(math.round(guideStrengthPts)) + " A" + str.tostring(math.round(guideDirectionPts)) + " C" + str.tostring(math.round(guideStructurePts)) + " T" + str.tostring(math.round(guideTrendPts))

bool guideSideAligned = guideSide == "C" ? callPct >= 58.0 : guideSide == "P" ? putPct >= 58.0 : false
bool guideSideConflict = guideSide == "C" ? callPct < 45.0 : guideSide == "P" ? putPct < 45.0 : false
bool guideInSideCluster = guideSide == "C" ? f_inZone(guideStrike, callZoneLow, callZoneHigh) : guideSide == "P" ? f_inZone(guideStrike, putZoneLow, putZoneHigh) : false
bool guideInPrimaryCluster = f_inZone(guideStrike, zoneLow, zoneHigh)
bool guideNearPoc = not na(guideStrike) and not na(pocStrike) and math.abs(guideStrike - pocStrike) <= effectiveGridSpacing * 0.51

string guideWhyText = ""
if not na(guideStrike)
    guideWhyText := f_addReason(guideWhyText, guideSideAligned ? "Side aligned" : guideSideConflict ? "Side conflict" : "Mixed activity")
    guideWhyText := f_addReason(guideWhyText, guideInSideCluster ? "In side cluster" : guideInPrimaryCluster ? "In primary cluster" : guideNearPoc ? "Near POC" : "Outside main cluster")
    guideWhyText := f_addReason(guideWhyText, guideTrendPts >= 10.0 ? "Trend aligned" : guideStrengthPts >= 18.0 ? "Strong contract volume" : "Trend mixed")
else
    guideWhyText := optionFeedWarmup ? "Waiting for current option data" : "No scored contract available"

string guideWatchText = na(zoneLow) or na(zoneHigh) ? "No reliable cluster — use map as reference only" :
     clusterPosition == "Around Price" ? "Inside " + keyZoneText + " — watch for a clean break and hold" :
     clusterPosition == "Above Price" ? "Cluster overhead " + keyZoneText + " — watch acceptance above it" :
     "Cluster below " + keyZoneText + " — watch whether it holds as support"

string guideQualityText = displayDataStatus + " | " + liqStatus + (isThinChain ? " / Thin" : "") + " | " + str.tostring(currentPct, "#") + "% current"
color guideContractColor = guideSide == "C" ? callColor : guideSide == "P" ? putColor : neutralColor
color guideConfidenceColor = na(guideConfidence) ? neutralColor : guideConfidence >= 75.0 ? callColor : guideConfidence >= 50.0 ? atmColor : putColor
color guideRiskColor = na(guideRiskScore) ? neutralColor : guideRiskScore <= 25.0 ? callColor : guideRiskScore <= 65.0 ? atmColor : color.red

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW PROFILE + LINES + LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    f_clearBoxes(profileBoxes)
    f_clearLines(magnetLines)
    f_clearLabels(infoLabels)

    int xAnchor = bar_index + effectiveProfileOffset
    int startX = math.max(0, bar_index - effectiveLineBarsBack)
    int topLabelX = xAnchor + effectiveTopLabelOffset

    if showNoDataWarning
        string warningText = ""
        color warningColor = color.red
        bool warningIsHard = true

        if not chartTfSupported
            warningText := "AF Options Map: Use an intraday or daily chart."
        else if na(lockedExpiryTs)
            warningText := expiryMode == "Today / 0DTE" and skipTodayAfterClose ? "AF Options Map: Today's 0DTE expiry has passed. Select another expiry." : "AF Options Map: No valid expiry. Check Expiry Choices, symbol format, or strike grid."
        else if expiryPassed
            warningText := "AF Options Map: The locked expiry has passed. Reload or select a new expiry."
        else if gridOutOfRange
            warningText := "AF Options Map: Price is outside the locked strike grid. Reload to recenter."
        else if optionFeedWarmup
            warningText := ""
        else if dataStatus == "No Contract Data"
            warningText := "AF Options Map: No contracts returned. Check expiry, symbol format, prefix, and market-data access."
        else if showDelayedFeedWarning and dataStatus == "Stale / Prior Session"
            warningText := "AF Options Map: Option feed delayed or outside session; prior-session volume is excluded."
            warningColor := color.orange
            warningIsHard := false
        else if showDelayedFeedWarning and dataStatus == "Current / No Volume"
            warningText := "AF Options Map: Contracts loaded, but the sampled strikes have no volume yet."
            warningColor := color.orange
            warningIsHard := false

        if warningText != ""
            label warn = label.new(bar_index, high, warningText, style=label.style_label_down, color=color.new(warningColor, warningIsHard ? 10 : 20), textcolor=color.white, size=warningIsHard ? size.small : size.tiny)
            array.push(infoLabels, warn)

    if showThinChainWarning and isThinChain
        string thinText = "AF Options Map: Thin sampled chain. Treat levels as reference, not directional confirmation."
        label warn2 = label.new(bar_index, high + atr14, thinText, style=label.style_label_down, color=color.new(color.orange, 15), textcolor=color.white, size=size.small)
        array.push(infoLabels, warn2)

    bool clusterTouchesSafeRange = not na(zoneHigh) and not na(zoneLow) and (not chartSafeVisuals or (zoneHigh >= close - chartSafeDistance and zoneLow <= close + chartSafeDistance))
    if showCloud and clusterTouchesSafeRange
        float clusterTopRaw = zoneHigh == zoneLow ? zoneHigh + effectiveGridSpacing * 0.35 : zoneHigh
        float clusterBottomRaw = zoneHigh == zoneLow ? zoneLow - effectiveGridSpacing * 0.35 : zoneLow
        float clusterTop = chartSafeVisuals ? math.min(clusterTopRaw, close + chartSafeDistance) : clusterTopRaw
        float clusterBottom = chartSafeVisuals ? math.max(clusterBottomRaw, close - chartSafeDistance) : clusterBottomRaw
        if clusterTop > clusterBottom
            box z = box.new(left=startX, top=clusterTop, right=xAnchor, bottom=clusterBottom, bgcolor=zoneColor, border_color=color.new(zoneColor, 100))
            array.push(profileBoxes, z)

    if showLines and totalOptVol > 0
        if showATMLine and not na(lockedAtm) and (not chartSafeVisuals or math.abs(lockedAtm - close) <= chartSafeDistance)
            line lATM = line.new(startX, lockedAtm, xAnchor, lockedAtm, color=atmColor, width=1, style=line.style_dotted)
            array.push(magnetLines, lATM)

        if not na(pocStrike) and (not chartSafeVisuals or math.abs(pocStrike - close) <= chartSafeDistance)
            line lP = line.new(startX, pocStrike, xAnchor, pocStrike, color=pocColor, width=2, style=line.style_dashed)
            array.push(magnetLines, lP)

        if not na(topCallStrike) and (not chartSafeVisuals or math.abs(topCallStrike - close) <= chartSafeDistance)
            line lC = line.new(startX, topCallStrike, xAnchor, topCallStrike, color=callColor, width=2, style=line.style_solid)
            array.push(magnetLines, lC)

        if not na(topPutStrike) and (not chartSafeVisuals or math.abs(topPutStrike - close) <= chartSafeDistance)
            line lPt = line.new(startX, topPutStrike, xAnchor, topPutStrike, color=putColor, width=2, style=line.style_solid)
            array.push(magnetLines, lPt)

    if showProfile and totalOptVol > 0
        float usableMax = maxTotalVol > 0 ? maxTotalVol : 1.0
        float barHeight = effectiveGridSpacing * 0.35

        for i = 0 to array.size(strikes) - 1
            float s = array.get(strikes, i)
            float c = array.get(callVols, i)
            float p = array.get(putVols, i)
            float t = c + p

            bool rowInVisualRange = not chartSafeVisuals or math.abs(s - close) <= chartSafeDistance
            if rowInVisualRange and (not hideZeroVolumeRows or t > 0)
                int totalW = t > 0 ? math.max(1, math.round((t / usableMax) * effectiveProfileWidth)) : 0
                int callW = t > 0 ? math.round((c / t) * totalW) : 0
                int putW = math.max(0, totalW - callW)
                int leftTotal = xAnchor - totalW

                if callW > 0
                    box bCall = box.new(left=leftTotal, top=s + barHeight, right=leftTotal + callW, bottom=s - barHeight, bgcolor=color.new(callColor, profileTransparency), border_color=color.new(callColor, 60))
                    array.push(profileBoxes, bCall)

                if putW > 0
                    box bPut = box.new(left=leftTotal + callW, top=s + barHeight, right=xAnchor, bottom=s - barHeight, bgcolor=color.new(putColor, profileTransparency), border_color=color.new(putColor, 60))
                    array.push(profileBoxes, bPut)

                if showRowLabels
                    float callRowPct = t > 0 ? c / t * 100.0 : 0.0
                    float putRowPct = t > 0 ? p / t * 100.0 : 0.0

                    string rowText = str.tostring(s) + "   C:" + f_fmtVol(c) + "   P:" + f_fmtVol(p)
                    if showRowPercents
                        rowText := str.tostring(s) + "   C:" + f_fmtVol(c) + " (" + str.tostring(callRowPct, "#") + "%)" + "   P:" + f_fmtVol(p) + " (" + str.tostring(putRowPct, "#") + "%)"

                    color rowColor = c > p ? callColor : p > c ? putColor : color.white

                    int rowX = xAnchor + rowLabelOffset
                    if rowLabelPosition == "Inside Bars"
                        rowX := xAnchor - math.max(1, math.round(totalW / 2.0))
                    else if rowLabelPosition == "Left of Bars"
                        rowX := math.max(0, leftTotal - rowLabelOffset)

                    label lbRow = label.new(rowX, s, rowText, style=label.style_none, textcolor=rowColor, size=rowLabelSize)
                    array.push(infoLabels, lbRow)

    if showTop3Labels and totalOptVol > 0
        if not na(top1Strike) and (not chartSafeVisuals or math.abs(top1Strike - close) <= chartSafeDistance)
            label lbT1 = label.new(topLabelX + 4, top1Strike, "Top 1 Vol " + top1Text, style=label.style_label_left, color=color.new(color.black, 80), textcolor=pocColor, size=size.tiny)
            array.push(infoLabels, lbT1)
        if not na(top2Strike) and (not chartSafeVisuals or math.abs(top2Strike - close) <= chartSafeDistance)
            label lbT2 = label.new(topLabelX + 4, top2Strike, "Top 2 Vol " + top2Text, style=label.style_label_left, color=color.new(color.black, 80), textcolor=color.white, size=size.tiny)
            array.push(infoLabels, lbT2)
        if not na(top3Strike) and (not chartSafeVisuals or math.abs(top3Strike - close) <= chartSafeDistance)
            label lbT3 = label.new(topLabelX + 4, top3Strike, "Top 3 Vol " + top3Text, style=label.style_label_left, color=color.new(color.black, 80), textcolor=color.white, size=size.tiny)
            array.push(infoLabels, lbT3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD + INTEGRATED FORGE GUIDE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dash = na

if barstate.islast
    if showDash
        if na(dash)
            dash := table.new(f_dashPos(dashPosInput), 2, 48, border_width=1, frame_width=1)

        table.clear(dash, 0, 0, 1, 47)

        color bg1 = color.new(color.black, 15)
        color bg2 = color.new(color.rgb(20, 25, 35), 10)
        color hdr = color.new(color.rgb(41, 211, 255), 0)
        color guideHdr = color.new(color.rgb(93, 107, 122), 15)
        color ratioColor = totalOptVol == 0 ? color.white : totalCallVol > totalPutVol ? callColor : totalPutVol > totalCallVol ? putColor : neutralColor

        table.cell(dash, 0, 0, "ALPHA FORGE", bgcolor=hdr, text_color=color.black, text_size=size.small)
        table.cell(dash, 1, 0, "OPTIONS MAP v1.7.5", bgcolor=hdr, text_color=color.black, text_size=size.small)

        if dashDetailInput == "Compact"
            string compactGrid = gridModeText + " | " + effectiveGridText + " | " + (gridOutOfRange ? "RELOAD" : "OK")
            string compactActivity = activityText + " | " + liqStatus
            string compactVol = str.tostring(callPct, "#.1") + "% / " + str.tostring(putPct, "#.1") + "% | " + cpRatioText
            string compactAtmPoc = (na(lockedAtm) ? "n/a" : str.tostring(lockedAtm)) + " / " + (na(pocStrike) ? "n/a" : str.tostring(pocStrike))
            string compactMagnet = na(nearestMagnet) ? "n/a" : str.tostring(nearestMagnet) + " | " + f_fmtDist(nearestDist) + " / " + f_fmtPct(nearestMagnetPct)
            string compactTop = top1Text + (na(top2Strike) ? "" : " | " + top2Text)
            string compactCurrent = optionFeedWarmup ? "loading option contexts..." : str.tostring(currentContracts) + "/" + str.tostring(requestedContracts) + " current | " + str.tostring(activeVolumeContracts) + " active"

            table.cell(dash, 0, 1, "Base / Expiry", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, 1, baseSymbol + " " + selectedExpiryText, bgcolor=bg2, text_color=color.white, text_size=size.tiny)

            table.cell(dash, 0, 2, "Expiry Choices", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, 2, validExpiryListText, bgcolor=bg1, text_color=autoExpiryMode ? callColor : color.white, text_size=size.tiny)

            if showForgeGuide
                table.cell(dash, 0, 3, "FORGE GUIDE", bgcolor=guideHdr, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 3, "SCORED CONFLUENCE", bgcolor=guideHdr, text_color=atmColor, text_size=size.tiny)

                table.cell(dash, 0, 4, "Scored Pick", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 4, guideContractText, bgcolor=bg1, text_color=guideContractColor, text_size=size.tiny)

                table.cell(dash, 0, 5, "Confidence", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 5, guideConfidenceText, bgcolor=bg2, text_color=guideConfidenceColor, text_size=size.tiny)

                table.cell(dash, 0, 6, "Risk Grade", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 6, guideRiskText, bgcolor=bg1, text_color=guideRiskColor, text_size=size.tiny)

                table.cell(dash, 0, 7, "Why", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 7, guideWhyText, bgcolor=bg2, text_color=guideConfidenceColor, text_size=size.tiny)

                table.cell(dash, 0, 8, "Pick Details", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 8, guideBasisText, bgcolor=bg1, text_color=guideContractColor, text_size=size.tiny)

                table.cell(dash, 0, 9, "Price Guide", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 9, guideWatchText, bgcolor=bg2, text_color=clusterColor, text_size=size.tiny)

                table.cell(dash, 0, 10, "Confirm", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, 10, "Check spread / OI / IV / Greeks", bgcolor=bg1, text_color=atmColor, text_size=size.tiny)

            int baseRow = showForgeGuide ? 11 : 3

            table.cell(dash, 0, baseRow, "Grid", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactGrid, bgcolor=bg2, text_color=gridOutOfRange ? putColor : callColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Activity", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactActivity, bgcolor=bg1, text_color=activityColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Call / Put", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactVol, bgcolor=bg2, text_color=ratioColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "ATM / POC", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactAtmPoc, bgcolor=bg1, text_color=pocColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Primary Cluster", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, keyZoneText + " | " + clusterPosition, bgcolor=bg2, text_color=clusterColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Nearest Magnet", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactMagnet, bgcolor=bg1, text_color=na(nearestDist) ? color.white : nearestDist >= 0 ? callColor : putColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Top Volume", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactTop, bgcolor=bg2, text_color=pocColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Data Status", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, displayDataStatus, bgcolor=bg1, text_color=displayDataStatusColor, text_size=size.tiny)
            baseRow += 1

            table.cell(dash, 0, baseRow, "Current / Active", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
            table.cell(dash, 1, baseRow, compactCurrent, bgcolor=bg2, text_color=currentContracts > 0 ? callColor : putColor, text_size=size.tiny)

        else
            int row = 1

            table.cell(dash, 0, row, "Base / Expiry", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, baseSymbol + " " + selectedExpiryText, bgcolor=bg2, text_color=color.white, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Expiry Mode", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, expiryMode, bgcolor=bg1, text_color=atmColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Expiry Status", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, expiryStatusText, bgcolor=bg2, text_color=na(lockedExpiryTs) ? putColor : callColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Expiry Choices", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, validExpiryListText, bgcolor=bg1, text_color=autoExpiryMode ? callColor : color.white, text_size=size.small)
            row += 1

            if showForgeGuide
                table.cell(dash, 0, row, "FORGE GUIDE", bgcolor=guideHdr, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, "SCORED CONTRACT CONFLUENCE", bgcolor=guideHdr, text_color=atmColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Scored Pick", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideContractText, bgcolor=bg2, text_color=guideContractColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Forge Confidence", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideConfidenceText, bgcolor=bg1, text_color=guideConfidenceColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Confidence Mix", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideScoreMixText, bgcolor=bg2, text_color=guideConfidenceColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Risk Grade", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideRiskText, bgcolor=bg1, text_color=guideRiskColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Why", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideWhyText, bgcolor=bg2, text_color=guideConfidenceColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Pick Details", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideBasisText, bgcolor=bg1, text_color=guideContractColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Price Guide", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideWatchText, bgcolor=bg2, text_color=clusterColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Guide Quality", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, guideQualityText, bgcolor=bg1, text_color=displayDataStatusColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Confirmation Needed", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, "Verify bid/ask spread, OI, IV and Greeks", bgcolor=bg2, text_color=atmColor, text_size=size.small)
                row += 1

            table.cell(dash, 0, row, "Locked ATM", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(lockedAtm) ? "n/a" : str.tostring(lockedAtm), bgcolor=bg1, text_color=atmColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Grid / Step", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, gridModeText + " | " + effectiveGridText, bgcolor=bg2, text_color=autoGridCapped ? atmColor : color.white, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Grid Status", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, gridStatusText, bgcolor=bg1, text_color=gridOutOfRange ? putColor : callColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Volume Basis", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, "Current ET Developing Daily", bgcolor=bg2, text_color=atmColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Activity Mix", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, activityText, bgcolor=bg1, text_color=activityColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Sampled Liquidity", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, liqStatus + (isThinChain ? " / Thin Chain" : ""), bgcolor=bg2, text_color=liqColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Call / Put Volume", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, str.tostring(callPct, "#.1") + "% / " + str.tostring(putPct, "#.1") + "%", bgcolor=bg1, text_color=color.white, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Call/Put Vol Ratio", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, cpRatioText, bgcolor=bg2, text_color=ratioColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Locked ATM / POC", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, (na(lockedAtm) ? "n/a" : str.tostring(lockedAtm)) + " / " + (na(pocStrike) ? "n/a" : str.tostring(pocStrike)), bgcolor=bg1, text_color=color.white, text_size=size.small)
            row += 1

            if showZonesInDash
                table.cell(dash, 0, row, "Primary Cluster", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, keyZoneText, bgcolor=bg2, text_color=pocColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Cluster Position", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, clusterPosition, bgcolor=bg1, text_color=clusterColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Call Cluster", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, callZoneText, bgcolor=bg2, text_color=callColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Put Cluster", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, putZoneText, bgcolor=bg1, text_color=putColor, text_size=size.small)
                row += 1

            table.cell(dash, 0, row, "Top Call Activity", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(topCallStrike) ? "n/a" : str.tostring(topCallStrike) + " | " + f_fmtVol(topCallVol) + " | " + (na(topCallPrice) ? "price n/a" : "$" + str.tostring(topCallPrice, "#.00")), bgcolor=bg2, text_color=callColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Top Put Activity", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(topPutStrike) ? "n/a" : str.tostring(topPutStrike) + " | " + f_fmtVol(topPutVol) + " | " + (na(topPutPrice) ? "price n/a" : "$" + str.tostring(topPutPrice, "#.00")), bgcolor=bg1, text_color=putColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Nearest Magnet", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(nearestMagnet) ? "n/a" : str.tostring(nearestMagnet), bgcolor=bg2, text_color=color.white, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Magnet - Price", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(nearestDist) ? "n/a" : f_fmtDist(nearestDist) + " / " + f_fmtPct(nearestMagnetPct), bgcolor=bg1, text_color=na(nearestDist) ? color.white : nearestDist >= 0 ? callColor : putColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "POC - Price", bgcolor=bg2, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, na(distToPoc) ? "n/a" : f_fmtDist(distToPoc), bgcolor=bg2, text_color=na(distToPoc) ? color.white : distToPoc >= 0 ? callColor : putColor, text_size=size.small)
            row += 1

            table.cell(dash, 0, row, "Call - Put Volume", bgcolor=bg1, text_color=color.white, text_size=size.small)
            table.cell(dash, 1, row, f_fmtVol(callPutDiff), bgcolor=bg1, text_color=callPutDiff >= 0 ? callColor : putColor, text_size=size.small)
            row += 1

            if showTop3InDash
                table.cell(dash, 0, row, "Top Vol 1", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, top1Text, bgcolor=bg2, text_color=pocColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Top Vol 2", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, top2Text, bgcolor=bg1, text_color=color.white, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Top Vol 3", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, top3Text, bgcolor=bg2, text_color=color.white, text_size=size.small)
                row += 1

            if showDataStatus
                table.cell(dash, 0, row, "Data Status", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, displayDataStatus, bgcolor=bg1, text_color=displayDataStatusColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Current / Found", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, str.tostring(currentContracts) + " / " + str.tostring(foundContracts) + " | " + str.tostring(currentPct, "#") + "% current", bgcolor=bg2, text_color=currentContracts > 0 ? callColor : putColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Active / Stale", bgcolor=bg1, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, str.tostring(activeVolumeContracts) + " / " + str.tostring(staleContracts), bgcolor=bg1, text_color=activeVolumeContracts > 0 ? callColor : putColor, text_size=size.small)
                row += 1

                table.cell(dash, 0, row, "Chart / Option Date", bgcolor=bg2, text_color=color.white, text_size=size.small)
                table.cell(dash, 1, row, observationDateText + " / " + latestOptionDateText, bgcolor=bg2, text_color=observationDateText == latestOptionDateText ? callColor : atmColor, text_size=size.small)
                row += 1

            if showDebugSymbols
                table.cell(dash, 0, row, "ATM Call Sym", bgcolor=bg1, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, row, sampleCallSymbol, bgcolor=bg1, text_color=callColor, text_size=size.tiny)
                row += 1

                table.cell(dash, 0, row, "ATM Put Sym", bgcolor=bg2, text_color=color.white, text_size=size.tiny)
                table.cell(dash, 1, row, samplePutSymbol, bgcolor=bg2, text_color=putColor, text_size=size.tiny)
    else if not na(dash)
        table.delete(dash)
        dash := na
````
