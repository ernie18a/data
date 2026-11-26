# Best Position Size Calculator

- url: https://www.tradingview.com/script/tOyZyxVD-Best-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;8635ad5db68b41998ec0d3923c515750
- version: 4.0

## Description

BEST POSITION SIZE CALCULATOR (PINE SCRIPT V6)

OVERVIEW:

Most traders fail not because of poor entries, but due to terrible risk management. Standard position size calculators are static, rigid, and tedious to use. The Best Position Size Calculator is a dynamic, institutional-grade risk management dashboard built directly into your chart.

Instead of just multiplying a percentage by your account balance, this script dynamically optimizes your share size based on live market volatility, broad market conditions, liquidity depth, and execution environments. It serves as an ultimate Go/No-Go gauge for entering trades safely.


WHAT THE SCRIPT DOES:

The indicator calculates the exact number of shares or contracts to purchase based on your personalized account settings. It visually displays this data in a clean, customizable on-screen dashboard.

Beyond simple calculations, the script acts as an automated defensive filter. If market conditions are highly dangerous (parabolic extensions, extreme overbought levels, dry liquidity, or a broken macro trend), the calculator will dynamically lock execution and flag a warning directly on your table, preventing you from taking high-risk setups.


HOW IT DOES IT (THE CORE ENGINE):

This script features a multi-layered calculation engine across several parameters:

Flexible Risk Architectures: You can determine your risk per share using six distinct methodologies:

1. LOD (Low of Day): Dynamically calculates risk based on the current session's low.

2. % of Account: A fixed percentage layout.

3. Volatility Matrix: Uses four specialized volatility tools across multi-timeframe structures (ATR, ADR, qADR, or StDev).

Progressive Risk Scaling: It pulls data from a major reference index (like NASDAQ:QQQ) and tracks its Z-score. When the broader market is healthy, it securely scales your risk up (up to 4x base risk); when the broad market is hostile, it dials your risk back down.

Smart Rounding Logic: Instead of suggesting fractional shares for large accounts (like buying 4,532.12 shares), the script uses an advanced tiered system to floor shares logically based on block size (rounding to the nearest 10, 50, 100, or 1000 shares dynamically).

Defensive Filtering Matrix: The script checks five separate conditions before displaying a size:

1. Liquidity Filter: Assesses average daily dollar volume to protect you from illiquid slippage.

2. Volume Cap Filter: Limits total share size to a maximum percentage of the daily average volume so your order doesn't disrupt the book.

3. Parabolic Filter: Flags when daily and weekly RSIs are simultaneously overextended (above or equal to 80).

4. Z' Trend and Overbought Filters: Maps out the asset's current Z-Score profile (Hostile, Weak, Neutral, Strong, or Overbought).

5. Long-Term Trend Filter: Utilizes a Weekly Rate of Change (ROC 50) filter to verify macro market direction.


HOW TO USE IT:

1. Input Your Metrics: Open the settings panel and enter your total Account Size, Base Risk %, and Max Position Size boundaries.

2. Select Your Sizing Method: Choose how you plan to manage stops (such as placing stops under the Low of Day or wrapping it around an ATR multiple).

3. Read the Dashboard:

- Blue text indicates a healthy environment with your optimal share size calculated.

- Orange text indicates that your size was safely capped to protect you from illiquidity or excessive capital concentration.

- Red or Gray text warnings (like Overbought, Low Liquidity, or wROC less than 0) warn you that a filter has triggered, notifying you to skip the trade or exercise extreme caution.


WHY THIS SCRIPT IS TRULY ORIGINAL:

Traditional position sizing scripts are blind. They treat a trade the exact same way during a roaring bull market as they do in a choppy bear market, or on a highly liquid stock versus an illiquid micro-cap.

This script is unique because it introduces dynamic adaptability and defensive restrictions. It combines cross-asset index tracking (Progressive Risk) with localized volatility indicators, then routes the output through institutional volume-cap guardrails and smart rounding. It is not just a calculator; it is an automated risk manager that scales your position size up when odds are in your favor and freezes entry sizes when market conditions turn toxic.


IMPORTANT NOTICE AND RISK DISCLAIMER:

This tool is designed strictly for informational and educational purposes. Every effort has been made to ensure the mathematical calculations within this Pine Script are correct, robust, and functional. However, software errors, data feed latencies, and market anomalies can occur.

Trading financial markets involves substantial risk of loss. Utilizing this script does not guarantee profitability or protection against loss. If you execute a trade and lose money, it is entirely your responsibility. The author assumes no financial liability for any losses, missed opportunities, or damages incurred from the use of this indicator. Always cross-verify position sizes manually before committing capital. Use at your own discretion.

## Source Code

````pine
//@version=6
indicator("Best Position Size Calculator", shorttitle="Position Calc.", overlay=true, max_labels_count=500, max_bars_back=350)

portfolioSize   = input.float(100000.0, "Account Size ($)", minval=100, step=1000, group="Portfolio Size")

roundingMode    = input.string("Smart Rounding (1 sig fig)", "Rounding Method", 
     options=["Smart Rounding (1 sig fig)", "Smart Rounding (2 sig figs)", "Whole Shares", "Exact/None"], group="Rounding")

useFractional   = input.bool(false, "Allow Fractional Shares (Under 10 Shares)", group="Allow Fractional Shares")

calcMethod = input.string("LOD (Low of Day)", "Share Calculation Method", 
     options=["LOD (Low of Day)", "% of Account", "Volatility (ATR)", "Volatility (ADR)", "Volatility (qADR)", "Volatility (StDev)"], 
     group="Calculation Method")

volTimeframe = input.string("Daily", "Volatility Timeframe", options=["Intraday", "Daily", "Weekly"], group="Volatility Settings")
atrLen   = input.int(14,  "ATR Length",  minval=1, group="Volatility Settings")
adrLen   = input.int(20,  "ADR Length",  minval=1, group="Volatility Settings")
qadrLen  = input.int(20,  "qADR Length", minval=1, group="Volatility Settings")
stdevLen = input.int(10,  "StDev Length",minval=1, group="Volatility Settings")

riskPercent     = input.float(0.1, "Base Risk % of Portfolio", minval=0.01, maxval=10, step=0.05, group="Risk Settings")
maxPosPercent   = input.float(10.0, "Max Position Size (% of Portfolio)", minval=1.0, maxval=100.0, step=0.5, group="Risk Settings")
maxVolCapPct    = input.float(5.0, "Max Volume Cap (% of Daily Avg Vol)", minval=0.1, maxval=100.0, step=0.5, group="Risk Settings")

displayMode     = input.string("Full Table", "Display Mode", options=["Full Table", "Position Size Only"], group="Display")

useProgressiveRisk = input.bool(true, "Enable Progressive Risk", group="Progressive Risk (Z-Score Index)")
refTicker          = input.symbol("NASDAQ:QQQ", "Reference Ticker / Index", group="Progressive Risk (Z-Score Index)")
refPeriod          = input.int(50, "Reference MA & StDev Length", minval=5, group="Progressive Risk (Z-Score Index)")
refMAType          = input.string("EMA", "Reference MA Type", options=["SMA", "EMA"], group="Progressive Risk (Z-Score Index)")

useLiquidityFilter = input.bool(true, "Enable Liquidity Filter", group="Liquidity Filter")
liqLookback        = input.int(30, "Liquidity Lookback (bars)", minval=10, maxval=1000, group="Liquidity Filter")
liqMinDollarVolMil = input.float(100.0, "Minimum Avg Daily $ Volume (Millions)", minval=1.0, step=10.0, group="Liquidity Filter")
liqTimeframe       = input.string("Daily", "Liquidity Timeframe", options=["Intraday", "Daily", "Weekly"], group="Liquidity Filter")
liqMAType          = input.string("SMA", "Liquidity MA Type", options=["SMA", "EMA"], group="Liquidity Filter")

useParabolicFilter = input.bool(true, "Enable Parabolic Filter", group="Parabolic Filter")
rsiLength          = input.int(14, "RSI Length", minval=1, group="Parabolic Filter")

useOverboughtFilter = input.bool(true, "Enable Overbought Filter", group="Overbought Filter")
zLength             = input.int(50, "Z-Score Length", minval=5, group="Overbought Filter")
zMaType             = input.string("EMA", "Z-Score MA Type", options=["SMA", "EMA"], group="Overbought Filter")

useZPrimeFilter     = input.bool(true, "Enable Z' Trend Filter (Restrict to 1-3 Strong Zone)", group="Z' Trend Execution Filter")

useTrendFilter      = input.bool(true, "Enable Long-Term Trend Filter", group="Long-Term Trend Filter")

tableX = input.string("right", "Horizontal Position", options=["left", "center", "right"], group="Table Style")
tableY = input.string("bottom", "Vertical Position", options=["top", "middle", "bottom"], group="Table Style")

// --- FUNCTIONS ---
f_getTimeframeLabel(tf) =>
    tf == "Weekly" ? "W" : tf == "Daily" ? "D" : timeframe.period

f_formatCurrency(float amt) =>
    if amt >= 1000000.0
        "$" + str.tostring(amt / 1000000.0, "#.##") + "M"
    else if amt >= 1000.0
        "$" + str.tostring(amt / 1000.0, "#.#") + "K"
    else
        "$" + str.tostring(amt, "#.##")

f_applySmartRounding(float rawShares, bool allowFrac, int sigFigs) =>
    if na(rawShares) or rawShares <= 0
        rawShares
    else if rawShares < 10 and allowFrac
        math.round(rawShares * 100) / 100
    else
        float absShares = math.abs(rawShares)
        int numDigits = sigFigs - (1 + int(math.floor(math.log10(absShares) + 1e-10)))
        float factor = math.pow(10, numDigits)
        math.round(rawShares * factor) / factor

getTablePosition() =>
    if tableY == "top"
        tableX == "left" ? position.top_left : tableX == "center" ? position.top_center : position.top_right
    else if tableY == "middle"
        tableX == "left" ? position.middle_left : tableX == "center" ? position.middle_center : position.middle_right
    else
        tableX == "left" ? position.bottom_left : tableX == "center" ? position.bottom_center : position.bottom_right

f_calculateZScore(simple int len, simple string type) =>
    maVal = type == "EMA" ? ta.ema(close, len) : ta.sma(close, len)
    sdVal = ta.stdev(close, len)
    sdVal > 0 ? (close - maVal) / sdVal : na

rawZScoreRef = request.security(refTicker, "D", f_calculateZScore(refPeriod, refMAType), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
currentZScore = request.security(syminfo.tickerid, "D", f_calculateZScore(zLength, zMaType), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

string zPrimeScore = na
if not na(currentZScore)
    if currentZScore < -1.0
        zPrimeScore := "Hostile"
    else if currentZScore < 0.0
        zPrimeScore := "Weak"
    else if currentZScore < 1.0
        zPrimeScore := "Neutral"
    else if currentZScore < 3.0
        zPrimeScore := "Strong"
    else
        zPrimeScore := "Overbought"

isNewDay = ta.change(time("D")) != 0
var float lowOfDay = na
if isNewDay
    lowOfDay := low
else
    lowOfDay := math.min(low, nz(lowOfDay, low))

f_vol_metrics(simple int aLen, simple int dLen, simple int qLen, simple int sLen) =>
    v_atr   = ta.atr(aLen)
    v_adr   = ta.sma(high - low, dLen)
    v_hlRat = high / low
    v_avgHL = ta.sma(v_hlRat, qLen)
    v_qadr  = (v_avgHL - 1) * close
    v_stdev = ta.stdev(close, sLen)
    [v_atr, v_adr, v_qadr, v_stdev]

[local_atr, local_adr, local_qadr, local_stdev] = f_vol_metrics(atrLen, adrLen, qadrLen, stdevLen)
[d_atr, d_adr, d_qadr, d_stdev] = request.security(syminfo.tickerid, "D", f_vol_metrics(atrLen, adrLen, qadrLen, stdevLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[w_atr, w_adr, w_qadr, w_stdev] = request.security(syminfo.tickerid, "W", f_vol_metrics(atrLen, adrLen, qadrLen, stdevLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

atrVal   = volTimeframe == "Weekly" ? w_atr   : volTimeframe == "Daily" ? d_atr   : local_atr
adrVal   = volTimeframe == "Weekly" ? w_adr   : volTimeframe == "Daily" ? d_adr   : local_adr
qadrVal  = volTimeframe == "Weekly" ? w_qadr  : volTimeframe == "Daily" ? d_qadr  : local_qadr
stdevVal = volTimeframe == "Weekly" ? w_stdev : volTimeframe == "Daily" ? d_stdev : local_stdev

f_liq_metrics(simple int look, simple string mType) =>
    v_avgVol = mType == "EMA" ? ta.ema(volume, look) : ta.sma(volume, look)
    v_dollarVol = v_avgVol * close
    [v_avgVol, v_dollarVol]

[local_avgVol, local_dollarVol] = f_liq_metrics(liqLookback, liqMAType)
[d_avgVol, d_dollarVol] = request.security(syminfo.tickerid, "D", f_liq_metrics(liqLookback, liqMAType), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[w_avgVol, w_dollarVol] = request.security(syminfo.tickerid, "W", f_liq_metrics(liqLookback, liqMAType), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

avgVolume    = liqTimeframe == "Weekly" ? w_avgVol    : liqTimeframe == "Daily" ? d_avgVol    : local_avgVol
avgDollarVol = liqTimeframe == "Weekly" ? w_dollarVol : liqTimeframe == "Daily" ? d_dollarVol : local_dollarVol

dailyRSI    = request.security(syminfo.tickerid, "D", ta.rsi(close, rsiLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
weeklyRSI   = request.security(syminfo.tickerid, "W", ta.rsi(close, rsiLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

isParabolic  = useParabolicFilter and (dailyRSI >= 80 and weeklyRSI >= 80)
isOverbought = useOverboughtFilter and not na(currentZScore) and currentZScore >= 3.0

isZPrimeRestricted = useZPrimeFilter and not na(currentZScore) and (currentZScore < 1.0 or currentZScore >= 3.0)

weeklyROC50 = request.security(syminfo.tickerid, "W", ta.roc(close, 50), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
isTrendRestricted = useTrendFilter and not na(weeklyROC50) and weeklyROC50 <= 0

float riskMultiplier = 1.0
if useProgressiveRisk and not na(rawZScoreRef)
    if rawZScoreRef < -1.0
        riskMultiplier := 1.0
    else if rawZScoreRef < 0.0
        riskMultiplier := 2.0
    else if rawZScoreRef < 1.0
        riskMultiplier := 3.0
    else if rawZScoreRef < 3.0
        riskMultiplier := 4.0
    else
        riskMultiplier := 3.0

effectiveRiskPercent = useProgressiveRisk ? riskPercent * riskMultiplier : riskPercent
riskAmount = portfolioSize * (effectiveRiskPercent / 100)

float riskPerShare = na
if calcMethod == "LOD (Low of Day)"
    riskPerShare := close - lowOfDay
else if calcMethod == "% of Account"
    riskPerShare := close * (effectiveRiskPercent / 100)
else if calcMethod == "Volatility (ATR)"
    riskPerShare := atrVal
else if calcMethod == "Volatility (ADR)"
    riskPerShare := adrVal
else if calcMethod == "Volatility (qADR)"
    riskPerShare := qadrVal
else if calcMethod == "Volatility (StDev)"
    riskPerShare := stdevVal

sharesRisk   = riskPerShare > 0 ? riskAmount / riskPerShare : 0

dailyAvgVol  = request.security(syminfo.tickerid, "D", ta.sma(volume, 30), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
maxVolumeCapShares = dailyAvgVol * (maxVolCapPct / 100)

maxShares    = (portfolioSize * maxPosPercent / 100) / close
finalShares  = math.min(sharesRisk, maxShares)

isVolCapped  = finalShares > maxVolumeCapShares
finalShares := isVolCapped ? maxVolumeCapShares : finalShares

minDollarVol = liqMinDollarVolMil * 1000000
isLowLiq     = useLiquidityFilter and (na(avgDollarVol) or avgDollarVol < minDollarVol)
isInvalid    = riskPerShare <= 0 or na(riskPerShare) or finalShares <= 0 or na(finalShares)

filterTriggered = isLowLiq or isParabolic or isOverbought or isZPrimeRestricted or isTrendRestricted or isInvalid

sharesFinal = filterTriggered ? na : 
              roundingMode == "Smart Rounding (1 sig fig)" ? f_applySmartRounding(finalShares, useFractional, 1) : 
              roundingMode == "Smart Rounding (2 sig figs)" ? f_applySmartRounding(finalShares, useFractional, 2) : 
              roundingMode == "Whole Shares"   ? math.floor(finalShares) : 
              finalShares

isMaxed        = not filterTriggered and (sharesRisk > maxShares)
posPercentUsed = filterTriggered ? na : (sharesFinal * close / portfolioSize) * 100

tfLabel = f_getTimeframeLabel(volTimeframe)
methodDisplay = calcMethod == "LOD (Low of Day)" or calcMethod == "% of Account" ? 
     calcMethod : tfLabel + " Volatility (" + str.replace(str.replace(calcMethod, "Volatility (", ""), ")", "") + ")"

var table posTable = table.new(getTablePosition(), 2, 13, bgcolor=color.new(color.black, 100), border_width=0)

if barstate.islast
    table.clear(posTable, 0, 0, 1, 12)
    int r = 0
    
    string displayShares = ""
    color displayColor = color.gray
    
    if isLowLiq
        displayShares := "Low Liquidity"
    else if isParabolic
        displayShares := "Parabolic"
    else if isOverbought
        displayShares := "Overbought"
    else if isZPrimeRestricted and not na(zPrimeScore)
        displayShares := zPrimeScore
    else if isTrendRestricted
        displayShares := "wROC(50) < 0"
    else if isInvalid
        displayShares := "N/A"
    else if isVolCapped
        displayShares := str.tostring(sharesFinal, "#,###.##") + " Sh. (Vol Cap)"
        displayColor := color.orange
    else
        displayShares := str.tostring(sharesFinal, sharesFinal < 10 and useFractional ? "#,###.##" : "#,###") + " Sh."
        displayColor := color.blue

    if displayMode == "Position Size Only"
        table.cell(posTable, 0, r, "Position Calc: ", text_color=color.gray, text_size=size.normal)
        table.cell(posTable, 1, r, displayShares, text_color=displayColor, text_size=size.large)
    else
        table.cell(posTable, 0, r, "Position Calc: ", text_color=color.gray, text_size=size.normal)
        table.cell(posTable, 1, r, displayShares, text_color=displayColor, text_size=size.normal)
        r += 1
        
        table.cell(posTable, 0, r, "Account Size: ", text_color=color.gray, text_size=size.small)
        table.cell(posTable, 1, r, f_formatCurrency(portfolioSize), text_color=color.gray, text_size=size.small)
        r += 1

        table.cell(posTable, 0, r, "Method: ", text_color=color.gray, text_size=size.small)
        table.cell(posTable, 1, r, methodDisplay, text_color=color.gray, text_size=size.small)
        r += 1

        table.cell(posTable, 0, r, "Risk $: ", text_color=color.gray, text_size=size.small)
        table.cell(posTable, 1, r, f_formatCurrency(riskAmount), text_color=color.gray, text_size=size.small)
        r += 1
        
        table.cell(posTable, 0, r, "Position Size (%): ", text_color=color.gray, text_size=size.small)
        posText = filterTriggered ? "N/A" : (isVolCapped ? str.tostring(posPercentUsed, "#.##") + "% (vol cap)" : isMaxed ? str.tostring(posPercentUsed, "#.##") + "% (max)" : str.tostring(posPercentUsed, "#.##") + "%")
        table.cell(posTable, 1, r, posText, text_color=filterTriggered ? color.gray : isVolCapped ? color.orange : isMaxed ? color.red : color.gray, text_size=size.small)
        r += 1

        if useProgressiveRisk
            table.cell(posTable, 0, r, "Risk Multiplier: ", text_color=color.gray, text_size=size.small)
            table.cell(posTable, 1, r, str.tostring(riskMultiplier, "#") + "x (" + str.tostring(effectiveRiskPercent, "#.##") + "%)", text_color=color.blue, text_size=size.small)
            r += 1

        table.cell(posTable, 0, r, "Z' (Score): ", text_color=color.gray, text_size=size.small)
        zPrimeText = na(zPrimeScore) ? "N/A" : zPrimeScore + " (" + str.tostring(currentZScore, "#.##") + ")"
        zPrimeColor = zPrimeScore == "Overbought" or zPrimeScore == "Hostile" ? color.red : zPrimeScore == "Strong" ? color.green : color.gray
        table.cell(posTable, 1, r, zPrimeText, text_color=zPrimeColor, text_size=size.small)
        r += 1

        table.cell(posTable, 0, r, "Rounding Mode: ", text_color=color.gray, text_size=size.small)
        table.cell(posTable, 1, r, roundingMode, text_color=color.gray, text_size=size.small)
````
