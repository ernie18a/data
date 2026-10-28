# Buffett Intrinsic Value

- url: https://www.tradingview.com/script/QZMoZXBR-Buffett-Intrinsic-Value/
- type: indicator
- pine_id: PUB;0aca141f17d04a7ab238345d54ce9bca
- version: 1.0

## Description

The Buffett Intrinsic Value (BIV) indicator evaluates whether a stock is trading at a discount or premium relative to its fundamental valuation. Based on Benjamin Graham and Warren Buffett’s valuation framework, this indicator calculates intrinsic value by combining auto-fetched fundamental financial data (EPS TTM, Sustainable Growth Rate) with live regional 10-Year AAA/Government bond yields.

It features an interactive, real-time dashboard directly on your TradingView chart canvas that outputs fair value, margin of safety, and automated BUY/HOLD/SELL trade bias recommendations.

FeaturesAutomated Fundamental Data Fetching:EPS TTM: Automatically requests trailing twelve-month Earnings Per Share using TradingView's request.financial() engine.Sustainable Growth Rate (SGR): Dynamically calculates growth rate using Return on Equity (ROE) and Dividend Retention Ratio ($\text{SGR} = \text{ROE} \times (1 - \text{Payout Ratio})$).YoY Growth Fallback: Automatically defaults to Year-over-Year EPS growth or manual user inputs if financial metrics are missing.Global Multi-Region Bond Yield Auto-Detection:Automatically detects the stock's country of origin via syminfo.country and pulls the relevant 10-Year Government Bond yield (US10Y, IN10Y, GB10Y, DE10Y, JP10Y, CN10Y, AU10Y, CA10Y).Margin of Safety & Valuation Recommendations:Computes discount/premium percentages relative to market price.Flags status as BUY (Undervalued with Margin of Safety), HOLD (Fairly Valued), or SELL (Overvalued).Fully Customizable Display Dashboard:Multi-layout support: Vertical (2 columns), Horizontal (2 rows), and Compact Horizontal modes.Customizable background colors, transparency, and text sizing.Visual trend plots for Intrinsic Value vs. Market Price directly on chart pane.

## Source Code

````pine
//@version=6
indicator("Buffett Intrinsic Value", shorttitle="BIV", overlay=true)

// ────────────────────────────────────────────────────────────────
// INPUTS
// ────────────────────────────────────────────────────────────────

useAutoEPS    = input.bool(defval=true,  title="Auto-fetch EPS (TTM)?",                  group="Data Sources")
manualEPS     = input.float(defval=5.0,  title="Manual EPS (fallback)",                   group="Data Sources", minval=0.01, step=0.1)

useAutoGrowth = input.bool(defval=true,  title="Auto-calculate Growth Rate (SGR: ROE × Retention)?", group="Data Sources")
manualGrowth  = input.float(defval=10.0, title="Manual Growth Rate % (fallback)",          group="Data Sources", minval=0, maxval=100, step=0.5)

useAutoBond   = input.bool(defval=true,  title="Auto-fetch Bond Yield by Region?",         group="Data Sources")
manualBond    = input.float(defval=4.5,  title="Manual Bond Yield % (fallback)",           group="Data Sources", minval=0.1, maxval=20, step=0.1)

// Buffett's formula baseline — typically kept at 4.4% (historical US AAA corporate bond rate)
referenceBondYield = input.float(defval=4.4, title="Buffett Reference Yield % (default 4.4)", group="Data Sources", minval=0.1, maxval=20, step=0.1)

safetyMargin  = input.float(defval=20.0, title="Safety Margin Threshold (%)",              group="Analysis", minval=5, maxval=50, step=1.0)
useClosePrice = input.bool(defval=true,  title="Use Current Close as Market Price?",       group="Analysis")
manualPrice   = input.float(defval=50.0, title="Market Price (if not using close)",        group="Analysis", minval=0.01, step=0.1)

showTable      = input.bool(defval=true,      title="Show Info Table",     group="Display")
tableTextSize  = input.string(defval="small", title="Table Text Size",     group="Display", options=["tiny", "small", "normal"])
tableTextColor = input.color(defval=color.white, title="Table Text Color", group="Display")
tableLayout    = input.string(defval="Vertical (2 columns)", title="Table Layout", group="Display", options=["Vertical (2 columns)", "Horizontal (2 rows)"])
compactHorizontal = input.bool(defval=false, title="Compact Horizontal Mode", group="Display")
tableBgColor   = input.color(defval=color.gray, title="Table Background Color", group="Display")
tableBgTransp  = input.int(defval=80, title="Table Background Transparency", group="Display", minval=0, maxval=100)

// ────────────────────────────────────────────────────────────────
// CALCULATIONS
// ────────────────────────────────────────────────────────────────

// ────────────────────────────────────────────────────────────────
// AUTO-FETCH: EPS (TTM)
// ────────────────────────────────────────────────────────────────

autoEPS  = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "TTM", ignore_invalid_symbol=true)
eps      = useAutoEPS and not na(autoEPS) and autoEPS > 0 ? autoEPS : manualEPS
epsLabel = useAutoEPS and not na(autoEPS) and autoEPS > 0 ? "EPS TTM (Auto)" : "EPS (Manual)"

// ────────────────────────────────────────────────────────────────
// AUTO-FETCH: GROWTH RATE — Sustainable Growth Rate (SGR)
// SGR = ROE × Retention Ratio  (= ROE × (1 − Payout Ratio))
// Payout Ratio = DPS / EPS_TTM
// Falls back to YoY EPS growth if SGR data unavailable, then to manual.
// Clamped 0–50%. Buffett's formula: g is a whole number (e.g. 10 = 10%).
// ────────────────────────────────────────────────────────────────

roe         = request.financial(syminfo.tickerid, "RETURN_ON_EQUITY",                          "TTM", ignore_invalid_symbol=true)
dps         = request.financial(syminfo.tickerid, "DPS_COMMON_STOCK_PRIM_ISSUE",               "TTM", ignore_invalid_symbol=true)
payoutRatio = not na(eps) and eps > 0 and not na(dps) and dps >= 0 ? dps / eps : float(na)
retentionR  = not na(payoutRatio) ? math.max(0.0, math.min(1.0, 1.0 - payoutRatio)) : float(na)
sgrRaw      = not na(roe) and roe > 0 and not na(retentionR) ? roe * retentionR * 100 : float(na)
sgrClamped  = not na(sgrRaw) ? math.max(0.0, math.min(50.0, sgrRaw)) : float(na)

epsFY        = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "FY", ignore_invalid_symbol=true)
epsFYChanged = not na(epsFY) and not na(epsFY[1]) and epsFY != epsFY[1]
epsFY0       = ta.valuewhen(epsFYChanged, epsFY,    0)
epsFY1       = ta.valuewhen(epsFYChanged, epsFY[1], 0)
yoyRaw       = not na(epsFY0) and not na(epsFY1) and epsFY1 != 0 ? ((epsFY0 - epsFY1) / math.abs(epsFY1)) * 100 : float(na)
yoyClamped  = not na(yoyRaw) ? math.max(0.0, math.min(50.0, yoyRaw)) : float(na)

autoGrowth  = not na(sgrClamped) ? sgrClamped : yoyClamped
growthRate  = useAutoGrowth and not na(autoGrowth) ? autoGrowth : manualGrowth
growthLabel = useAutoGrowth and not na(sgrClamped) ? "SGR: ROE*(1-Payout) Auto" : (useAutoGrowth and not na(yoyClamped) ? "Growth YoY (Fallback)" : "Growth (Manual)")

// ────────────────────────────────────────────────────────────────
// AUTO-FETCH: LIVE BOND YIELD BY REGION
// Uses syminfo.country to pick the relevant 10Y government bond
// ────────────────────────────────────────────────────────────────

yieldUS = request.security("TVC:US10Y", "D", close, ignore_invalid_symbol=true)
yieldIN = request.security("TVC:IN10Y", "D", close, ignore_invalid_symbol=true)
yieldGB = request.security("TVC:GB10Y", "D", close, ignore_invalid_symbol=true)
yieldDE = request.security("TVC:DE10Y", "D", close, ignore_invalid_symbol=true)
yieldJP = request.security("TVC:JP10Y", "D", close, ignore_invalid_symbol=true)
yieldCN = request.security("TVC:CN10Y", "D", close, ignore_invalid_symbol=true)
yieldAU = request.security("TVC:AU10Y", "D", close, ignore_invalid_symbol=true)
yieldCA = request.security("TVC:CA10Y", "D", close, ignore_invalid_symbol=true)

c     = syminfo.country
isEU  = c == "DE" or c == "FR" or c == "IT" or c == "ES" or c == "NL" or c == "BE" or c == "AT" or c == "FI" or c == "PT" or c == "IE"
isCN  = c == "CN" or c == "HK"
isAU  = c == "AU" or c == "NZ"

detectedYield   = c == "US" ? yieldUS : c == "IN" ? yieldIN : c == "GB" ? yieldGB : isEU ? yieldDE : c == "JP" ? yieldJP : isCN ? yieldCN : isAU ? yieldAU : c == "CA" ? yieldCA : yieldUS
bondRegionLabel = c == "US" ? "US 10Y (Auto)" : c == "IN" ? "India 10Y (Auto)" : c == "GB" ? "UK Gilt 10Y (Auto)" : c == "DE" ? "Germany 10Y (Auto)" : isEU ? "EU/DE 10Y (Auto)" : c == "JP" ? "Japan 10Y (Auto)" : isCN ? "China 10Y (Auto)" : isAU ? "Australia 10Y (Auto)" : c == "CA" ? "Canada 10Y (Auto)" : "US 10Y (default)"

bondYieldValid   = not na(detectedYield) and detectedYield > 0
currentBondYield = useAutoBond and bondYieldValid ? detectedYield : manualBond
bondLabel        = useAutoBond and bondYieldValid ? bondRegionLabel : "Bond Yield (Manual)"

// ────────────────────────────────────────────────────────────────
// CALCULATIONS
// Buffett Formula: V = EPS × (8.5 + 2g) × 4.4 / Y
//   g = expected annual growth rate as whole number (e.g. 10 for 10%)
//   Y = current regional 10Y bond yield (%)
// ────────────────────────────────────────────────────────────────

multiplier     = 8.5 + 2.0 * growthRate
intrinsicValue = (eps * multiplier * referenceBondYield) / currentBondYield

currentPrice  = useClosePrice ? close : manualPrice
margin        = ((intrinsicValue - currentPrice) / currentPrice) * 100
actualSafetyM = margin - safetyMargin

recommendation = margin >= safetyMargin ? "BUY"         : margin >= 0 ? "HOLD"  : "SELL"
priceFairness  = margin >= safetyMargin ? "Undervalued" : margin >= 0 ? "Fair"  : "Overvalued"

// ────────────────────────────────────────────────────────────────
// COLOR CODING
// ────────────────────────────────────────────────────────────────

recColor = recommendation == "BUY"  ? color.new(color.green,  0) :
           recommendation == "HOLD" ? color.new(color.orange, 0) :
                                      color.new(color.red,    0)

// ────────────────────────────────────────────────────────────────
// DISPLAY TABLE IN TOP RIGHT
// ────────────────────────────────────────────────────────────────

var table t = na
var string activeLayout = ""

if showTable
    layoutKey = tableLayout + (compactHorizontal ? "|compact" : "|full")
    needsRebuild = na(t) or activeLayout != layoutKey
    if needsRebuild
        if not na(t)
            table.delete(t)
        cols = tableLayout == "Vertical (2 columns)" ? 2 : (compactHorizontal ? 8 : 12)
        rows = tableLayout == "Vertical (2 columns)" ? 12 : 2
        t := table.new(position.top_right, cols, rows, border_color=color.gray, border_width=2)
        activeLayout := layoutKey

    bgNeutral = color.new(tableBgColor, tableBgTransp)
    bgAccent1 = color.new(color.purple, tableBgTransp)
    bgAccent2 = color.new(color.blue, tableBgTransp)
    bgAccent3 = color.new(color.teal, tableBgTransp)
    bgAccent4 = color.new(color.navy, tableBgTransp)
    bgRec     = color.new(recommendation == "BUY" ? color.green : recommendation == "HOLD" ? color.orange : color.red, tableBgTransp)

    symbolValue = syminfo.ticker + " (" + (syminfo.country != "" ? syminfo.country : "?") + ")"
    recValue    = recommendation + " / " + priceFairness

    if tableLayout == "Vertical (2 columns)"
        table.cell(t, 0, 0,  "SYMBOL [?]",         text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor, tooltip="Chart ticker and country code. Source: syminfo.ticker + syminfo.country")
        table.cell(t, 1, 0,  symbolValue,           text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor)

        table.cell(t, 0, 1,  "INTRINSIC VALUE [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor, tooltip="Buffett formula: EPS x (8.5 + 2g) x RefYield / CurrentYield")
        table.cell(t, 1, 1,  str.tostring(intrinsicValue, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor)

        table.cell(t, 0, 2,  "Market Price [?]",   text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Current close if enabled, otherwise manual input")
        table.cell(t, 1, 2,  str.tostring(currentPrice, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 3,  "Margin (%) [?]",     text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="(Intrinsic - Market) / Market x 100")
        table.cell(t, 1, 3,  str.tostring(margin, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 4,  "Safety Margin [?]",  text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Margin minus your safety threshold")
        table.cell(t, 1, 4,  str.tostring(actualSafetyM, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 5,  "EPS [?]",            text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + epsLabel + ". Auto source: request.financial EPS TTM")
        table.cell(t, 1, 5,  str.tostring(eps, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 6,  "Growth Rate [?]",    text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + growthLabel + ". SGR = ROE x (1 - Payout Ratio). Falls back to YoY EPS if SGR data unavailable.")
        table.cell(t, 1, 6,  str.tostring(growthRate, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 7,  "Current P/E [?]",    text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Market Price / EPS")
        table.cell(t, 1, 7,  str.tostring(currentPrice / eps, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)

        table.cell(t, 0, 8,  "Bond Yield [?]",     text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor, tooltip="" + bondLabel + ". Auto source: regional 10Y via request.security")
        table.cell(t, 1, 8,  str.tostring(currentBondYield, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor)

        table.cell(t, 0, 9,  "Ref Yield [?]",      text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor, tooltip="Buffett historical reference yield used for normalization")
        table.cell(t, 1, 9,  str.tostring(referenceBondYield, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor)

        table.cell(t, 0, 10, "Currency [?]",       text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent4, text_color=tableTextColor, tooltip="Instrument quote currency from syminfo.currency")
        table.cell(t, 1, 10, syminfo.currency,       text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent4, text_color=tableTextColor)

        table.cell(t, 0, 11, "Recommendation [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor, tooltip="BUY/HOLD/SELL based on margin vs safety threshold")
        table.cell(t, 1, 11, recValue,               text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor)
    else
        if compactHorizontal
            table.cell(t, 0, 0, "SYMBOL [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor, tooltip="Chart ticker and country code. Source: syminfo.ticker + syminfo.country")
            table.cell(t, 1, 0, "INTRINSIC VALUE [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor, tooltip="Buffett formula: EPS x (8.5 + 2g) x RefYield / CurrentYield")
            table.cell(t, 2, 0, "Market Price [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Current close if enabled, otherwise manual input")
            table.cell(t, 3, 0, "Margin (%) [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="(Intrinsic - Market) / Market x 100")
            table.cell(t, 4, 0, "EPS [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + epsLabel + ". Auto source: request.financial EPS TTM")
            table.cell(t, 5, 0, "Growth Rate [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + growthLabel + ". SGR = ROE x (1 - Payout Ratio). Falls back to YoY EPS if SGR data unavailable.")
            table.cell(t, 6, 0, "Bond Yield [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor, tooltip="" + bondLabel + ". Auto source: regional 10Y via request.security")
            table.cell(t, 7, 0, "Recommendation [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor, tooltip="BUY/HOLD/SELL based on margin vs safety threshold")

            table.cell(t, 0, 1, symbolValue, text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor)
            table.cell(t, 1, 1, str.tostring(intrinsicValue, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor)
            table.cell(t, 2, 1, str.tostring(currentPrice, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 3, 1, str.tostring(margin, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 4, 1, str.tostring(eps, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 5, 1, str.tostring(growthRate, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 6, 1, str.tostring(currentBondYield, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor)
            table.cell(t, 7, 1, recValue, text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor)
        else
            table.cell(t, 0, 0,  "SYMBOL [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor, tooltip="Chart ticker and country code. Source: syminfo.ticker + syminfo.country")
            table.cell(t, 1, 0,  "INTRINSIC VALUE [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor, tooltip="Buffett formula: EPS x (8.5 + 2g) x RefYield / CurrentYield")
            table.cell(t, 2, 0,  "Market Price [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Current close if enabled, otherwise manual input")
            table.cell(t, 3, 0,  "Margin (%) [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="(Intrinsic - Market) / Market x 100")
            table.cell(t, 4, 0,  "Safety Margin [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Margin minus your safety threshold")
            table.cell(t, 5, 0,  "EPS [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + epsLabel + ". Auto source: request.financial EPS TTM")
            table.cell(t, 6, 0,  "Growth Rate [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="" + growthLabel + ". SGR = ROE x (1 - Payout Ratio). Falls back to YoY EPS if SGR data unavailable.")
            table.cell(t, 7, 0,  "Current P/E [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor, tooltip="Market Price / EPS")
            table.cell(t, 8, 0,  "Bond Yield [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor, tooltip="" + bondLabel + ". Auto source: regional 10Y via request.security")
            table.cell(t, 9, 0,  "Ref Yield [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor, tooltip="Buffett historical reference yield used for normalization")
            table.cell(t, 10, 0, "Currency [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent4, text_color=tableTextColor, tooltip="Instrument quote currency from syminfo.currency")
            table.cell(t, 11, 0, "Recommendation [?]", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor, tooltip="BUY/HOLD/SELL based on margin vs safety threshold")

            table.cell(t, 0, 1,  symbolValue, text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent1, text_color=tableTextColor)
            table.cell(t, 1, 1,  str.tostring(intrinsicValue, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent2, text_color=tableTextColor)
            table.cell(t, 2, 1,  str.tostring(currentPrice, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 3, 1,  str.tostring(margin, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 4, 1,  str.tostring(actualSafetyM, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 5, 1,  str.tostring(eps, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 6, 1,  str.tostring(growthRate, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 7, 1,  str.tostring(currentPrice / eps, "#.##"), text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgNeutral, text_color=tableTextColor)
            table.cell(t, 8, 1,  str.tostring(currentBondYield, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor)
            table.cell(t, 9, 1,  str.tostring(referenceBondYield, "#.##") + "%", text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent3, text_color=tableTextColor)
            table.cell(t, 10, 1, syminfo.currency, text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgAccent4, text_color=tableTextColor)
            table.cell(t, 11, 1, recValue, text_halign=text.align_center, text_size=tableTextSize, bgcolor=bgRec, text_color=tableTextColor)
else
    if not na(t)
        table.delete(t)
        t := na
        activeLayout := ""

// ────────────────────────────────────────────────────────────────
// PLOT FOR REFERENCE (optional trend visualization)
// ────────────────────────────────────────────────────────────────

plot(intrinsicValue, title="Intrinsic Value", color=color.blue, linewidth=2)
plot(currentPrice,   title="Market Price",    color=color.gray, linewidth=1)
plot(na)
````
