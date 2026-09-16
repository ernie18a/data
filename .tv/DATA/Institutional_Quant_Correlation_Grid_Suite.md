<!-- tradingview-pine-id: PUB;0b308fb34b974b429387ace3588143c7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Institutional Quant Correlation Grid Suite

Source: https://www.tradingview.com/script/emqesciG-Institutional-Quant-Correlation-Grid-Suite/

## Description

Slide 1: Title
Institutional Quant Correlation Grid Suite
Pine Script v6 Indicator

Purpose: A professional-grade quantitative analysis tool that evaluates a ticker's relationship to a benchmark (e.g., SPY) across multiple dimensions — correlation, volatility, momentum, and risk-adjusted performance — all presented in an intuitive visual dashboard.

Author: Quant Trading Team
Version: 6.0

Slide 2: Problem Statement & Solution
The Challenge:

Retail traders lack institutional-grade quant tools inside TradingView.

Evaluating a stock's true relationship to the market (or sector ETF) requires looking beyond simple price correlation.

Key metrics (Beta, Alpha, Z-scores, Relative Strength) are scattered across different indicators.

Our Solution:
An all-in-one indicator that computes, visualizes, and alerts on:

Multi-asset correlations (Price, RSI, ATR, Volume, Volume-Weighted)

Risk metrics (Beta, Annualized Alpha)

Mean-reversion signals (Spread Z-Score)

Relative strength momentum (RS Ratio)

Timeframe returns (1D, 1W, 1M)

Automated Buy/Hold/Sell conditions

Slide 3: Core Inputs – Quant Settings
Input	Default	Description
Lookback Window	30 bars	Rolling window for all correlations & statistics. Adjustable 10–500.
Reference Symbol	SPY	Benchmark ETF. Dropdown includes 40+ sector/thematic ETFs (XLF, SMH, ARKG, GDX, JETS, etc.)
Correlation Metric	Close	Which data series to screen against the benchmark (Close, Open, High, Low, Volume, RSI, ATR).
Correlation Threshold	0.70	Minimum absolute correlation to be considered "aligned".
Z-Score Extremes Threshold	2.00	Level at which the spread is considered overextended (mean-reversion signal).
Slide 4: Oscillator & Indicator Parameters
The suite uses standard technical indicators for its multi-dimensional analysis:

Indicator	Parameter	Default
RSI	Length	14
MACD	Fast / Slow / Signal	12 / 26 / 9
Stochastic	Length / Smooth	14 / 3
CCI	Length	20
Williams %R	Length	14
ATR	Length	14
These are used to compute correlations across different market regimes (momentum, volatility, volume) — not just price.

Slide 5: Core Calculations – Correlation Suite
The indicator computes 6 distinct correlation metrics against the reference symbol over the lookback window:

Correlation	Methodology
Price Corr	Standard Pearson correlation of Close prices.
Selected Metric Corr	Correlation of the user-chosen metric (e.g., RSI, Volume) against the benchmark's equivalent.
RSI Corr	Correlation of RSI values.
ATR Corr	Correlation of Average True Range (volatility alignment).
Volume Corr	Correlation of raw volume (detects relative liquidity/interest).
VW-Corr	Volume-Weighted correlation — weights daily returns by volume, giving more importance to high-volume days.
Slide 6: Core Calculations – Risk & Performance
Beta & Alpha (Annualized)

Beta = Covariance(asset, benchmark) / Variance(benchmark)

Alpha = (Mean_Asset_Return - Beta × Mean_Benchmark_Return) × 100 × 252

Interpretation: Beta > 1 = higher volatility than benchmark; Alpha > 0 = outperformance.

Relative Strength (RS) Momentum

RS Ratio = Close_Asset / Close_Benchmark

RS Momentum = (RS_Ratio / SMA(RS_Ratio, length) - 1) × 100

Positive = asset is strengthening relative to benchmark.

Spread Z-Score (Mean-Reversion)

Log Spread = ln(Close_Asset / Close_Benchmark)

Z = (Log_Spread - Mean(Log_Spread)) / StdDev(Log_Spread)

Extreme positive = asset is overextended vs benchmark (sell signal).

Slide 7: Grid 1 – Quant Heatcard (Visual Dashboard)
Position Options: 9 positions (Top/Bottom + Left/Center/Right)
Text Size: Tiny, Small, Normal

Top Row (6 cards):

Card	Display	Color Logic
Beta	Value vs 1.0	Green if ≥ 1.0
Alpha (Ann.)	Annualized %	Green if positive, Red if negative
Price Corr	Correlation	Green if ≥ threshold
VW-Corr	Volume-Weighted Corr	Gold if ≥ threshold
RS Momentum	% vs benchmark	Green if positive, Red if negative
Spread Z-Score	Z value	Gold if ≥ Z-threshold (overextended)
Slide 8: Grid 1 – Quant Heatcard (Continued)
Bottom Row (6 cards):

Card	Display	Color Logic
Return 1D	% change	Green if positive, Red if negative
Return 1W	% change (weekly close)	Green if positive, Red if negative
Return 1M	% change (monthly close)	Green if positive, Red if negative
Quant Signal	"ALPHA PASS" or "NEUTRAL"	PASS if: corrClose ≥ threshold AND RS Momentum > 0 AND Beta > 0.8
Benchmark	Symbol text (e.g., "SPY")	Cyan highlight
Lookback	e.g., "30 bars"	Muted display
Slide 9: Grid 2 – Detailed Breakdown Table
Position Options: 9 positions (separate from Grid 1)
Text Size: Tiny, Small, Normal

Row	Col 0	Col 1	Col 2	Col 3
Row 0: Correlations	Price Corr	RSI Corr	ATR Corr	Volume Corr
Row 1: Structure	Beta	Alpha	Spread Z-Score	RS Momentum
Row 2: Selected Metric	Selected Metric Name	Correlation of Selected Metric	PASS/FAIL (≥ threshold)	Lookback (e.g., "30B")
Color Coding:

Green = Strong/Positive

Red = Weak/Negative

Cyan = Informational

Gold = Extreme/Warning

Slide 10: Plots & Screener Exports
The indicator also plots directly on the chart pane (below price):

Plot	Color	Display
Price Correlation (%)	Blue (linewidth 2)	Main chart pane
VW-Correlation (%)	Yellow (linewidth 1)	Main chart pane
Threshold Upper/Lower	Green/Red dashed lines	±70% bands
Beta	Teal	Data Window + Status Line
Alpha (%)	Green	Data Window + Status Line
RS Momentum (%)	Purple	Data Window + Status Line
Z-Score	Orange	Data Window + Status Line
Return 1D/1W/1M	Purple/Orange/Red	Data Window + Status Line
These enable screeners and multi-ticker comparisons using TradingView's Data Window.

Slide 11: Alert Conditions – Automated Signals
The indicator generates 3 distinct alert conditions for automated trading notifications:

Signal	Condition
BUY / Accumulation	corrClose ≥ threshold AND corrVW ≥ threshold AND RS Momentum > 0 AND Beta > 0.8 AND Z-Score < zThreshold
HOLD / Neutral	corrClose ≥ threshold AND	RS Momentum	≤ 0.5 AND	Z-Score	< zThreshold
SELL / Divergence	RS Momentum < 0 OR corrClose < 0.20 OR Z-Score ≥ zThreshold
Alert Messages include: Ticker name and clear reasoning (e.g., "High correlation, positive RS momentum against benchmark, and stable Z-score.")

Slide 12: Use Cases & Applications
Scenario	How the Indicator Helps
Sector Rotation	Compare a stock to sector ETF (e.g., AAPL vs. XLK). High correlation + positive RS = sector leader.
Pair Trading	Z-Score tells you when spread is overextended — mean-reversion entry/exit points.
Risk Management	Beta tells you if stock is riskier than market; ATR correlation shows volatility alignment.
Factor Screening	The "Quant Signal" (ALPHA PASS) quickly flags stocks with strong fundamentals vs benchmark.
Momentum Investing	RS Momentum identifies stocks gaining relative strength.
Earnings / Event Analysis	1D/1W/1M returns show immediate impact vs benchmark.
Slide 13: Technical Implementation Highlights
Lookahead Handling: Uses barmerge.lookahead_off for reference security to avoid repainting.

Rolling Windows: All statistics use TradingView's ta.correlation, ta.sma, ta.stdev for consistency.

Volume-Weighted Correlation: Custom computation using volume-weighted returns for more robust correlation.

Dynamic Tables: Uses table.new with position constants, allowing users to place grids anywhere on screen.

Alerts: Built-in alertcondition() for automated strategy integration.

Compatibility: Requires Pine Script v6. Works on all timeframes (1min to monthly).

Slide 14: Customization Options Summary
Group	Parameter	Options
Core Quant	Lookback, Reference Symbol, Correlation Metric, Thresholds	10-500, 40+ ETFs, 7 metrics, 0.05 steps
Grid 1 (Heatcard)	Show/Hide, Position, Text Size	9 positions, 3 sizes
Grid 2 (Details)	Show/Hide, Position, Text Size	9 positions, 3 sizes
Oscillators	RSI, MACD, Stochastic, CCI, Williams, ATR lengths	User-adjustable
Result: A fully configurable tool adaptable to any trading style — from day trading to long-term investing.

Slide 15: Demonstration – Example Output
Ticker: AAPL
Benchmark: SPY
Lookback: 30 bars

Metric	Value	Signal
Beta	1.12	High volatility
Alpha	+2.3%	Positive outperformance
Price Corr	0.85	Strong alignment
VW-Corr	0.81	Volume-confirmed correlation
RS Momentum	+1.2%	Gaining relative strength
Z-Score	+0.45	Within normal range
Quant Signal	ALPHA PASS	Bullish
Alert: BUY condition triggered.

Slide 16: Summary & Value Proposition
What this indicator delivers:

✅ Institutional-grade quant dashboard in a single script
✅ Multi-dimensional analysis — not just price, but volatility, volume, momentum, and risk
✅ Visual clarity with two customizable data grids
✅ Actionable alerts for systematic trading
✅ Screener-ready outputs via Data Window
✅ Fully configurable to fit any strategy or timeframe

Ideal for: Swing traders, sector rotators, pair traders, risk managers, and quantitative researchers using TradingView. 

FOR EDUCATIONAL PURPOSES ONLY 
NOT A FINANCIAL ADVICE

---

## Source Code

````pine
//@version=6
indicator("Institutional Quant Correlation Grid Suite", overlay=false, max_bars_back=5000)

// –– USER INPUTS ––
length      = input.int(30, title="Lookback Window (Bars)", minval=10, maxval=500, group="Quant Core Settings")
refSymbol   = input.string("SPY", title="Reference Symbol", options=[
    "SPY", "REX", "COPX", "URA", "BATT", "ARKG", "GDX", "BOAT", "LIT", "SIL",
    "SLX", "XLB", "XLY", "ARKX", "XHB", "XRT", "XLF", "IGV", "JETS", "IYT","BOTZ","HACK","XTL","UNG","XLP","QTUM","SKYY","ROBO","XLI","ITA","SUPL","XLE","XLRE",
    "SMH","XLU","WGMI","MSOS"
], group="Quant Core Settings")

refMetric   = input.string("Close", title="Screener Correlation Metric", options=[
    "Close", "Open", "High", "Low", "Volume", "RSI", "ATR"
], group="Quant Core Settings")

threshold   = input.float(0.70, title="Correlation Threshold", step=0.05, group="Quant Core Settings")
zThreshold  = input.float(2.00, title="Z-Score Extremes Threshold", step=0.1, group="Quant Core Settings")

// –– GRID 1: HEATCARD DISPLAY OPTIONS ––
showHeatGrid = input.bool(true, title="Show Heatcard Grid", group="Grid 1: Quant Heatcards")
heatGridPos  = input.string("Top Right", title="Position", options=[
    "Top Right", "Top Center", "Top Left", 
    "Middle Right", "Middle Center", "Middle Left", 
    "Bottom Right", "Bottom Center", "Bottom Left"
], group="Grid 1: Quant Heatcards")
heatGridSize = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal"], group="Grid 1: Quant Heatcards")

// –– GRID 2: DETAILED METRICS DISPLAY OPTIONS ––
showDetailGrid = input.bool(true, title="Show Detailed Metrics Grid", group="Grid 2: Breakdown Table")
detailGridPos  = input.string("Bottom Right", title="Position", options=[
    "Top Right", "Top Center", "Top Left", 
    "Middle Right", "Middle Center", "Middle Left", 
    "Bottom Right", "Bottom Center", "Bottom Left"
], group="Grid 2: Breakdown Table")
detailGridSize = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal"], group="Grid 2: Breakdown Table")

// –– OSCILLATOR PARAMETERS ––
rsiLen      = input.int(14, title="RSI Length", minval=2, group="Oscillators")
macdFast    = input.int(12, title="MACD Fast", minval=1, group="Oscillators")
macdSlow    = input.int(26, title="MACD Slow", minval=1, group="Oscillators")
macdSignal  = input.int(9,  title="MACD Signal", minval=1, group="Oscillators")
stochLen    = input.int(14, title="Stochastic Length", minval=2, group="Oscillators")
stochSmooth = input.int(3,  title="Stochastic Smooth", minval=1, group="Oscillators")
cciLen      = input.int(20, title="CCI Length", minval=2, group="Oscillators")
willrLen    = input.int(14, title="Williams %R Length", minval=2, group="Oscillators")
atrLen      = input.int(14, title="ATR Length", minval=2, group="Oscillators")

// –– HELPER FUNCTIONS ––
getMetric(string metric, float sClose, float sOpen, float sHigh, float sLow, float sVol, float sRSI, float sATR) =>
    switch metric
        "Close"  => sClose
        "Open"   => sOpen
        "High"   => sHigh
        "Low"    => sLow
        "Volume" => sVol
        "RSI"    => sRSI
        "ATR"    => sATR
        => sClose

getPos(string pos) =>
    switch pos
        "Top Right"      => position.top_right
        "Top Center"     => position.top_center
        "Top Left"       => position.top_left
        "Middle Right"   => position.middle_right
        "Middle Center"  => position.middle_center
        "Middle Left"    => position.middle_left
        "Bottom Right"   => position.bottom_right
        "Bottom Center"  => position.bottom_center
        "Bottom Left"    => position.bottom_left
        => position.top_right

getTextSize(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

// –––––––– DATA CALCULATIONS –––––––––
currentClose  = close
currentOpen   = open
currentHigh   = high
currentLow    = low
currentVolume = volume

currentRSI    = ta.rsi(close, rsiLen)
currentATR    = ta.atr(atrLen)
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
currentStochK = ta.stoch(close, high, low, stochLen)
currentStochD = ta.sma(currentStochK, stochSmooth)
currentCCI    = ta.cci(close, cciLen)
currentWillR  = ta.wpr(willrLen)
currentOBV    = ta.obv

// –– TRADINGVIEW ACCURATE PERIOD RETURNS ––
dClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
wClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
mClose = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)

retD = not na(dClose) ? ((close - dClose) / dClose) * 100 : na
retW = not na(wClose) ? ((close - wClose) / wClose) * 100 : na
retM = not na(mClose) ? ((close - mClose) / mClose) * 100 : na

// Reference Symbol
[refClose, refOpen, refHigh, refLow, refVolume, refRSI, refATR] = request.security(
     refSymbol, 
     timeframe.period, 
     [close, open, high, low, volume, ta.rsi(close, rsiLen), ta.atr(atrLen)], 
     lookahead=barmerge.lookahead_off
 )

currentSeries = getMetric(refMetric, currentClose, currentOpen, currentHigh, currentLow, currentVolume, currentRSI, currentATR)
refSeries     = getMetric(refMetric, refClose, refOpen, refHigh, refLow, refVolume, refRSI, refATR)

hasEnoughBars = bar_index >= length

corrSelected = hasEnoughBars ? ta.correlation(currentSeries, refSeries, length) : na
corrClose    = hasEnoughBars ? ta.correlation(currentClose, refClose, length) : na
corrRSI      = hasEnoughBars ? ta.correlation(currentRSI, refRSI, length) : na
corrATR      = hasEnoughBars ? ta.correlation(currentATR, refATR, length) : na
corrVol      = hasEnoughBars ? ta.correlation(currentVolume, refVolume, length) : na

// Volume-Weighted Correlation
retAsset       = ta.change(close) / close[1]
retRef         = ta.change(refClose) / refClose[1]
volWeightAsset = currentVolume / ta.sma(currentVolume, length)
volWeightRef   = refVolume / ta.sma(refVolume, length)
vwRetAsset     = retAsset * volWeightAsset
vwRetRef       = retRef * volWeightRef

corrVW = hasEnoughBars ? ta.correlation(vwRetAsset, vwRetRef, length) : na

// Beta & Alpha
meanAsset = ta.sma(retAsset, length)
meanRef   = ta.sma(retRef, length)
covarVal  = ta.sma((retAsset - meanAsset) * (retRef - meanRef), length)
varRef    = ta.sma(math.pow(retRef - meanRef, 2), length)

betaVal   = (hasEnoughBars and varRef != 0) ? covarVal / varRef : na
alphaVal  = hasEnoughBars ? (meanAsset - (betaVal * meanRef)) * 100 * 252 : na

// RS & Spread Z-Score
rsRatio    = currentClose / refClose
rsSMA      = ta.sma(rsRatio, length)
rsMomentum = ((rsRatio / rsSMA) - 1) * 100

logRatio   = math.log(currentClose / refClose)
spreadMean = ta.sma(logRatio, length)
spreadStd  = ta.stdev(logRatio, length)
zScore     = (hasEnoughBars and spreadStd != 0) ? (logRatio - spreadMean) / spreadStd : na

// –––––––– GRID 1: QUANT HEATCARD TABLE –––––––––
var table gridHeat = table.new(
     position=getPos(heatGridPos), 
     columns=6, 
     rows=2, 
     bgcolor=color.rgb(0, 0, 0), 
     border_width=2, 
     border_color=color.rgb(0, 0, 0)
 )

setHeatcard(table tbl, int col, int row, string valText, string labelText, color cardBg, color textColor, string tSize) =>
    string cellText = valText + "\n" + labelText
    table.cell(tbl, col, row, cellText, bgcolor=cardBg, text_color=textColor, text_size=tSize, text_halign=text.align_center)

if barstate.islast and showHeatGrid
    tSize          = getTextSize(heatGridSize)
    cDarkBg        = color.rgb(15, 23, 42)
    cCardGreenBg   = color.rgb(18, 53, 36)
    cCardRedBg     = color.rgb(61, 23, 23)
    cCardNeutralBg = color.rgb(30, 41, 59)
    cGreenText     = color.rgb(74, 222, 128)
    cRedText       = color.rgb(248, 113, 113)
    cGoldText      = color.rgb(250, 204, 21)
    cCyanText      = color.rgb(56, 189, 248)
    cMutedText     = color.rgb(148, 163, 184)
    
    // Top Card Row
    setHeatcard(gridHeat, 0, 0, str.tostring(betaVal, "#.##"), "Beta (" + refSymbol + ")", betaVal >= 1.0 ? cCardGreenBg : cCardNeutralBg, betaVal >= 1.0 ? cGreenText : cMutedText, tSize)
    setHeatcard(gridHeat, 1, 0, str.tostring(alphaVal, "+#.##;-#.##"), "Alpha (Ann.)", alphaVal >= 0 ? cCardGreenBg : cCardRedBg, alphaVal >= 0 ? cGreenText : cRedText, tSize)
    setHeatcard(gridHeat, 2, 0, str.tostring(corrClose, "#.##"), "Price Corr", math.abs(corrClose) >= threshold ? cCardGreenBg : cCardNeutralBg, math.abs(corrClose) >= threshold ? cCyanText : cMutedText, tSize)
    setHeatcard(gridHeat, 3, 0, str.tostring(corrVW, "#.##"), "VW-Corr", math.abs(corrVW) >= threshold ? cCardGreenBg : cCardNeutralBg, math.abs(corrVW) >= threshold ? cGoldText : cMutedText, tSize)
    setHeatcard(gridHeat, 4, 0, str.tostring(rsMomentum, "+#.##;-#.##") + "%", "RS vs " + refSymbol, rsMomentum >= 0 ? cCardGreenBg : cCardRedBg, rsMomentum >= 0 ? cGreenText : cRedText, tSize)
    setHeatcard(gridHeat, 5, 0, str.tostring(zScore, "+#.##;-#.##"), "Spread Z-Score", math.abs(zScore) >= zThreshold ? cCardRedBg : cCardNeutralBg, math.abs(zScore) >= zThreshold ? cGoldText : cMutedText, tSize)

    // Bottom Card Row
    setHeatcard(gridHeat, 0, 1, str.tostring(retD, "+#.##;-#.##") + "%", "Return 1D", retD >= 0 ? cCardGreenBg : cCardRedBg, retD >= 0 ? cGreenText : cRedText, tSize)
    setHeatcard(gridHeat, 1, 1, str.tostring(retW, "+#.##;-#.##") + "%", "Return 1W", retW >= 0 ? cCardGreenBg : cCardRedBg, retW >= 0 ? cGreenText : cRedText, tSize)
    setHeatcard(gridHeat, 2, 1, str.tostring(retM, "+#.##;-#.##") + "%", "Return 1M", retM >= 0 ? cCardGreenBg : cCardRedBg, retM >= 0 ? cGreenText : cRedText, tSize)
    
    bool isQuantPass = corrClose >= threshold and rsMomentum > 0 and betaVal > 0.8
    setHeatcard(gridHeat, 3, 1, isQuantPass ? "ALPHA PASS" : "NEUTRAL", "Quant Signal", isQuantPass ? cCardGreenBg : cCardNeutralBg, isQuantPass ? cGreenText : cMutedText, tSize)
    setHeatcard(gridHeat, 4, 1, refSymbol, "Benchmark", cDarkBg, cCyanText, tSize)
    setHeatcard(gridHeat, 5, 1, str.tostring(length) + " bars", "Lookback", cDarkBg, cMutedText, tSize)

// –––––––– GRID 2: SEPARATE DETAILED BREAKDOWN GRID –––––––––
var table gridDetail = table.new(
     position=getPos(detailGridPos), 
     columns=4, 
     rows=3, 
     bgcolor=color.rgb(15, 23, 42), 
     border_width=2, 
     border_color=color.rgb(30, 41, 59)
 )

setDetailCell(table tbl, int col, int row, string topText, string bottomText, color textColor, string tSize) =>
    string content = topText + "\n" + bottomText
    table.cell(tbl, col, row, content, bgcolor=color.rgb(0, 0, 0), text_color=textColor, text_size=tSize, text_halign=text.align_center)

if barstate.islast and showDetailGrid
    tSize      = getTextSize(detailGridSize)
    cTextWhite = color.rgb(243, 244, 246)
    cGreen     = color.rgb(74, 222, 128)
    cRed       = color.rgb(248, 113, 113)
    cCyan      = color.rgb(56, 189, 248)
    cGold      = color.rgb(250, 204, 21)

    // Row 0: Asset Correlations
    setDetailCell(gridDetail, 0, 0, str.tostring(corrClose, "#.##"), "Price Corr", corrClose >= threshold ? cGreen : cTextWhite, tSize)
    setDetailCell(gridDetail, 1, 0, str.tostring(corrRSI, "#.##"), "RSI Corr", corrRSI >= 0 ? cGreen : cRed, tSize)
    setDetailCell(gridDetail, 2, 0, str.tostring(corrATR, "#.##"), "ATR Corr", corrATR >= 0 ? cCyan : cTextWhite, tSize)
    setDetailCell(gridDetail, 3, 0, str.tostring(corrVol, "#.##"), "Vol Corr", corrVol >= 0 ? cGold : cTextWhite, tSize)

    // Row 1: Structural Parameters
    setDetailCell(gridDetail, 0, 1, str.tostring(betaVal, "#.##"), "Beta", betaVal >= 1.0 ? cGreen : cCyan, tSize)
    setDetailCell(gridDetail, 1, 1, str.tostring(alphaVal, "+#.##;-#.##"), "Alpha", alphaVal >= 0 ? cGreen : cRed, tSize)
    setDetailCell(gridDetail, 2, 1, str.tostring(zScore, "+#.##;-#.##"), "Spread Z", math.abs(zScore) >= zThreshold ? cGold : cTextWhite, tSize)
    setDetailCell(gridDetail, 3, 1, str.tostring(rsMomentum, "+#.##;-#.##") + "%", "RS Mom", rsMomentum >= 0 ? cGreen : cRed, tSize)

    // Row 2: Selected Metric Status
    setDetailCell(gridDetail, 0, 2, refMetric, "Selected", cCyan, tSize)
    setDetailCell(gridDetail, 1, 2, str.tostring(corrSelected, "#.##"), refMetric + " Corr", corrSelected >= threshold ? cGreen : cTextWhite, tSize)
    bool passThresh = not na(corrSelected) and corrSelected > threshold
    setDetailCell(gridDetail, 2, 2, passThresh ? "PASS" : "FAIL", "Status", passThresh ? cGreen : cRed, tSize)
    setDetailCell(gridDetail, 3, 2, str.tostring(length) + "B", "Lookback", cTextWhite, tSize)

// –––––––– PANE PLOTS & SCREENER EXPORTS –––––––––
plot(corrSelected * 100, title="Price Correlation (%)", color=color.blue, linewidth=2, display=display.all)
plot(corrVW * 100, title="VW-Correlation (%)", color=color.yellow , linewidth=1, display=display.all)

hline(threshold * 100, "Threshold Upper", color=color.green, linestyle=hline.style_dashed)
hline(-threshold * 100, "Threshold Lower", color=color.red, linestyle=hline.style_dashed)

// Screener Outputs
plot(betaVal, title="Beta", color=color.teal, display=display.data_window + display.status_line)
plot(alphaVal, title="Annualized Alpha (%)", color=color.green, display=display.data_window + display.status_line)
plot(rsMomentum, title="RS Outperformance (%)", color=color.purple, display=display.data_window + display.status_line)
plot(zScore, title="Spread Z-Score", color=color.orange, display=display.data_window + display.status_line)
plot(retD, title="Return D (%)", color=color.purple, display=display.data_window + display.status_line)
plot(retW, title="Return W (%)", color=color.orange, display=display.data_window + display.status_line)
plot(retM, title="Return M (%)", color=color.red,    display=display.data_window + display.status_line)



// –––––––– ALERT CONDITION LOGIC –––––––––
buyCondition  = corrClose >= threshold and corrVW >= threshold and rsMomentum > 0 and betaVal > 0.8 and zScore < zThreshold
holdCondition = corrClose >= threshold and math.abs(rsMomentum) <= 0.5 and math.abs(zScore) < zThreshold
sellCondition = rsMomentum < 0 or corrClose < 0.20 or zScore >= zThreshold

alertcondition(buyCondition,  title="Quant BUY / Accumulation Alert", message="[QUANT ALERT] BUY Signal on {{ticker}}! High correlation, positive RS momentum against benchmark, and stable Z-score.")
alertcondition(holdCondition, title="Quant HOLD / Neutral Alert",        message="[QUANT ALERT] HOLD Signal on {{ticker}}. Benchmark alignment intact with neutral relative strength.")
alertcondition(sellCondition, title="Quant SELL / Divergence Alert",   message="[QUANT ALERT] SELL/AVOID Signal on {{ticker}}! Breakdown in relative strength, correlation drop, or spread overextension.")
````
