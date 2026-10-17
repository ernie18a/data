# Apex Algo Engine [AlgoChief]

- url: https://www.tradingview.com/script/hQ45xL33-Apex-Algo-Engine-AlgoChief/
- type: indicator
- pine_id: PUB;fd7b1720eb1a4d83b9f9721fec462d0b
- version: 1.0

## Description

Institutional Trend Engine, Dual Reversal Cloud, Dynamic Trailing Baseline & Precision Risk HUD

OVERVIEW

Apex Algo Engine [AlgoChief] is an advanced, institutional-grade analytical trading toolkit built for TradingView Pine Script v5. Designed to solve the common pitfalls of lagging indicators and cluttered charts, this engine fuses Ordinary Least Squares (OLS) regression, weighted volatility dispersion, and an adaptive stepping baseline into a single, cohesive visual framework.

Whether you are trading equities, indices, forex, or cryptocurrencies, Apex Algo [AlgoChief] delivers a crystal-clear, clutter-free perspective on market trends, momentum expansions, and high-probability trade setups.

█ MAIN FEATURES & HOW THEY WORK

🌊 Dual Reversal Clouds (Equilibrium & Dispersion Bands) Traditional bands use static moving averages that lag during volatile regime shifts. Apex Algo [AlgoChief] calculates a dynamic equilibrium curve using a smoothed least-squares polynomial fit.
• Upper Cloud (Emerald Ribbon): Represents statistical overextension and potential trend resistance. • Lower Cloud (Crimson Ribbon): Represents oversold deviation and dynamic trend support. • Translucent 3D Volumetric Fill: Enables traders to instantly recognize whether price is trading in fair-value territory or compressing against volatility boundaries.

📈 Trend Tracker (Dynamic Stepping Trailing Baseline) The Trend Tracker acts as a smart trailing baseline that follows market structure dynamically: • Bullish Regime (Electric Green Baseline below price): The baseline dynamically ratchets upward as higher highs are formed. During consolidations or minor pullbacks, it locks horizontally into support shelves to prevent premature exits. • Bearish Regime (Electric Crimson Baseline above price): The baseline ratchets downward with price expansion and forms horizontal resistance shelves. • Zero Diagonal Jumps: Plotted with independent conditional logic so your chart remains pristine with no diagonal flip lines across bars.

🎯 High-Probability "Strong" Signals (Strict Alternating Engine) Unlike typical indicators that spam repeated buy and sell labels across multiple candles, Apex Algo [AlgoChief] incorporates a strict 1-Signal-Per-Trend Alternation Engine: • Strong Buy Signal (Vivid Green Badge): Triggers only when the trend flips bullish with verified volatility expansion and momentum breakout. • Strong Sell Signal (Vivid Red Badge): Triggers only when the trend flips bearish with breakdown momentum. • Zero Sticker Spam: Once a Buy is issued, no further Buy signals can print until an opposite Sell condition occurs. This keeps the chart completely uncluttered.

🎨 100% Full Trend Candle Coloring To maximize visual focus and eliminate chart distraction, candle bodies and wicks adapt to the active trend state: • During Uptrends: ALL candles are painted Green (even intraday red/bearish pullbacks remain green so you stay aligned with the broader move). • During Downtrends: ALL candles are painted Red (even intraday green/bullish bounces remain red). • Visual Clarity: Eliminates the psychological urge to prematurely exit winning trends on minor intraday wicks.

🛡️ Integrated Risk Management HUD & Projection Lines Effective risk management is essential to long-term profitability. Apex Algo [AlgoChief] computes mathematical risk targets immediately upon every confirmed signal: • Dynamic Stop Loss (SL): Placed logically at the Trend Tracker baseline or ATR structure. • Take Profit Targets:

TP1: 1:1.5 Risk-to-Reward ratio
TP2: 1:2.5 Risk-to-Reward ratio
TP3 (Runner): 1:3.5 Risk-to-Reward ratio • On-Chart Dynamic Target Lines: Visual dashed and dotted target levels plotted directly from entry. • Corner HUD Table: Compact real-time summary card detailing Market Trend, Active Position, Entry Price, SL, TP1, TP2, TP3, and ATR Volatility Status.
⚡ Optional Contrarian Sniper & S/R Zones (Customizable) For traders seeking extra flexibility, additional institutional tools can be toggled on inside the settings menu: • Contrarian Sniper Badges: Contrarian mean-reversion entries triggered when price deviates significantly (Z-Score > 2.2) beyond the Reversal Cloud. • Exhaustion Dots: Subtle orange circles marking extreme swing peaks and troughs inside the cloud. • Dynamic S/R Retest Zones: Automated horizontal support and resistance boxes generated from historical overbought and oversold pivot swings with ATR vertical padding.
█ THE MATHEMATICAL FOUNDATION

Ordinary Least Squares (OLS) Dynamic Equilibrium The central equilibrium line solves the linear regression model over lookback length N: Minimizing the sum of squared vertical distances from price to the trendline, providing an objective mathematical description of market equilibrium. The resulting curve is double-smoothed using Weighted Moving Averages (WMA) to produce smooth harmonic waves without introducing lag.

Weighted Volatility & Range Metric Rather than relying on static ATR, the cloud dispersion uses a dual-weighted volatility formula: Adaptive Volatility = 0.65 * WMA(True Range, K) + 0.35 * WMA(|Δ Close|, K) This gives higher priority to recent volatility surges and rapid price impulses, allowing the bands to expand smoothly during breakouts and contract gracefully during consolidation.

Non-Repainting Execution All signal logic, trend baseline shifts, and table updates are calculated strictly on confirmed historical bar closes (closed bar basis), ensuring zero repainting on past candles.

█ STEP-BY-STEP TRADING RULES

🟢 Bullish Trade Execution:

Wait for a "Strong" (Green) badge to print below the candle at the close of the bar.
Confirm the Trend Tracker baseline is Electric Green below price.
Candle colors will switch to 100% Green.
Check the HUD Dashboard for your exact Entry Price, suggested Stop Loss, and Take Profit levels (TP1, TP2, TP3).
Ride the trend as long as candles stay Green and price remains above the green baseline.

🔴 Bearish Trade Execution:

Wait for a "Strong" (Red) badge to print above the candle at the close of the bar.
Confirm the Trend Tracker baseline is Electric Red above price.
Candle colors will switch to 100% Red.
Review suggested SL and TP targets on the HUD Table or on-chart lines.
Trail your stop loss downward along the stepping red resistance baseline.
█ RECOMMENDED TIMEFRAMES & SETTINGS

• Scalping (1m - 5m): Trend Multiplier = 1.8 - 2.0 | Cloud Length = 40 - 45 • Day Trading (15m - 30m): Trend Multiplier = 2.2 (Default) | Cloud Length = 55 (Default) • Swing Trading (1h - Daily): Trend Multiplier = 2.4 - 2.8 | Cloud Length = 55 - 65

█ COMPLIANCE & RISK DISCLAIMER

This indicator is developed solely for educational, research, and informational purposes. It does not constitute financial, investment, legal, or trading advice. Trading foreign exchange, equities, commodities, futures, and cryptocurrencies carries substantial risk of loss and is not suitable for every investor. Never risk capital you cannot afford to lose. Always perform your own due diligence and consult with a licensed financial advisor before making any investment decisions.

## Source Code

````pine
//@version=6
indicator("Apex Algo Engine [AlgoChief]",  overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ============================================================================

// ----------------------------------------------------------------------------
// INPUT SETTINGS
// ----------------------------------------------------------------------------
grp_signals = "═══ SIGNAL CONTROLS (CLEAN & PROFESSIONAL) ═══"
signalMode        = input.string("Strong Signals Only (Ultra Clean)", "Signal Display Mode", 
                                 options=["Strong Signals Only (Ultra Clean)", "All Confirmed Trend Signals", "All Signals (Unfiltered)"], 
                                 group=grp_signals, 
                                 tooltip="Ultra Clean mode displays ONLY single high-probability 'Strong' badges per trend cycle (No clutter)")
filterSignalsByTrend = input.bool(true, "Strict Trend Tracker Alignment", group=grp_signals, tooltip="Buy signals only in Bull trends; Sell signals only in Bear trends")
trendMult         = input.float(2.2, "Trend Sensitivity Multiplier", minval=0.5, step=0.1, group=grp_signals, tooltip="Higher = cleaner, longer-lasting trends; Lower = faster flips")
trendAtrLen       = input.int(14, "Trend ATR Period", minval=1, group=grp_signals)

grp_candles = "═══ FULL TREND CANDLE COLORING ═══"
showBarColors     = input.bool(true, "Enable Full Trend Candle Colors", group=grp_candles, tooltip="Colors ALL candles Green in uptrends (even red candles), and ALL candles Red in downtrends (even green candles)")
solidTrendColors  = input.bool(true, "Pure Solid Trend Color (Clean Flat Look)", group=grp_candles)
showTrendBg       = input.bool(true, "Enable Trend Background Tint", group=grp_candles)

grp_cloud = "═══ REVERSAL CLOUD (EQUILIBRIUM & DISPERSION) ═══"
showCloud         = input.bool(true, "Show Reversal Cloud", group=grp_cloud)
eqLength          = input.int(55, "Equilibrium Regression Length", minval=10, group=grp_cloud)
smoothLength      = input.int(8, "Cloud Smoothing Factor", minval=1, maxval=30, group=grp_cloud)
atrCloudLen       = input.int(21, "Weighted Volatility Length", minval=5, group=grp_cloud)
cloudInnerDev     = input.float(1.8, "Cloud Inner Band Deviation", step=0.1, group=grp_cloud)
cloudOuterDev     = input.float(3.3, "Cloud Outer Band Deviation", step=0.1, group=grp_cloud)

grp_extra = "═══ OPTIONAL CONTRARIAN TOOLS (OFF BY DEFAULT) ═══"
showSniperSignals = input.bool(false, "Show Contrarian Sniper Badges", group=grp_extra, tooltip="Contrarian reversal badges. Keep OFF for a clean chart")
showExhaustionDots= input.bool(false, "Show Exhaustion Peak Dots", group=grp_extra, tooltip="Orange dots at extreme peaks. Keep OFF for a clean chart")
showSRZones       = input.bool(false, "Show S/R Retest Zones", group=grp_extra, tooltip="Displays horizontal support/resistance boxes")
srPivotLen        = input.int(20, "S/R Swing Pivot Length", minval=5, maxval=50, group=grp_extra)
srZoneThicknessAtr= input.float(0.4, "Zone Thickness (ATR Mult)", step=0.05, group=grp_extra)

grp_rm = "═══ RISK MANAGEMENT & DASHBOARD HUD ═══"
showDashboard     = input.bool(true, "Show Risk Management HUD", group=grp_rm)
dashboardPos      = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp_rm)
showTpSlLines     = input.bool(true, "Show Active Trade SL / TP Lines", group=grp_rm)
riskRewardRatio1  = input.float(1.5, "Take Profit 1 (R:R)", minval=0.5, step=0.1, group=grp_rm)
riskRewardRatio2  = input.float(2.5, "Take Profit 2 (R:R)", minval=1.0, step=0.1, group=grp_rm)
riskRewardRatio3  = input.float(3.5, "Take Profit 3 (R:R)", minval=1.5, step=0.1, group=grp_rm)

// ----------------------------------------------------------------------------
// COLOR PALETTE (From Z Algo Screenshots)
// ----------------------------------------------------------------------------
c_bull_bright   = #00E676      // Vivid Lime/Emerald Green (Uptrend)
c_bull_dark     = #00A859      // Rich Forest Green
c_bear_bright   = #FF1744      // Electric Crimson Red (Downtrend)
c_bear_dark     = #B71C1C      // Deep Maroon/Wine Red
c_sniper_buy    = #2962FF      // Electric Blue
c_sniper_sell   = #FFD600      // Amber Gold
c_exhaust_dot   = #FF9100      // Vibrant Orange

// ============================================================================
// 1. REVERSAL CLOUD (LEAST-SQUARES EQUILIBRIUM & WEIGHTED DISPERSION)
// ============================================================================
rawLinReg   = ta.linreg(close, eqLength, 0)
equilibrium = ta.wma(ta.wma(rawLinReg, smoothLength), smoothLength)

weightedTr     = ta.wma(ta.tr(true), atrCloudLen)
priceChangeAbs = ta.wma(math.abs(close - close[1]), atrCloudLen)
adaptiveVol    = (weightedTr * 0.65) + (priceChangeAbs * 0.35)

cloudMidDev     = (cloudInnerDev + cloudOuterDev) * 0.5
cloudUpperInner = equilibrium + (adaptiveVol * cloudInnerDev)
cloudUpperMid   = equilibrium + (adaptiveVol * cloudMidDev)
cloudUpperOuter = equilibrium + (adaptiveVol * cloudOuterDev)

cloudLowerInner = equilibrium - (adaptiveVol * cloudInnerDev)
cloudLowerMid   = equilibrium - (adaptiveVol * cloudMidDev)
cloudLowerOuter = equilibrium - (adaptiveVol * cloudOuterDev)

p_uo = plot(showCloud ? cloudUpperOuter : na, "Cloud Upper Outer", color=color.new(c_bull_bright, 60), linewidth=1)
p_um = plot(showCloud ? cloudUpperMid : na,   "Cloud Upper Mid",   color=color.new(c_bull_bright, 75), linewidth=1)
p_ui = plot(showCloud ? cloudUpperInner : na, "Cloud Upper Inner", color=color.new(c_bull_dark, 70),   linewidth=1)
fill(p_uo, p_um, color=color.new(c_bull_bright, 70), title="Upper Cloud Outer Fill")
fill(p_um, p_ui, color=color.new(c_bull_dark, 76),   title="Upper Cloud Inner Fill")

p_li = plot(showCloud ? cloudLowerInner : na, "Cloud Lower Inner", color=color.new(c_bear_dark, 70),   linewidth=1)
p_lm = plot(showCloud ? cloudLowerMid : na,   "Cloud Lower Mid",   color=color.new(c_bear_bright, 75), linewidth=1)
p_lo = plot(showCloud ? cloudLowerOuter : na, "Cloud Lower Outer", color=color.new(c_bear_bright, 60), linewidth=1)
fill(p_li, p_lm, color=color.new(c_bear_dark, 76),   title="Lower Cloud Inner Fill")
fill(p_lm, p_lo, color=color.new(c_bear_bright, 70), title="Lower Cloud Outer Fill")

// ============================================================================
// 2. TREND TRACKER (DYNAMIC STEPPING TRAILING BASELINE)
// ============================================================================
trendAtr   = ta.wma(ta.tr, trendAtrLen)
upperBound = high + (trendAtr * trendMult)
lowerBound = low - (trendAtr * trendMult)

var float trendTracker   = na
var int   trendDirection = 1

if na(trendTracker)
    trendTracker := lowerBound
    trendDirection := 1
else
    if trendDirection == 1
        trendTracker := math.max(nz(trendTracker[1], lowerBound), lowerBound)
        if close < trendTracker
            trendDirection := -1
            trendTracker := upperBound
    else
        trendTracker := math.min(nz(trendTracker[1], upperBound), upperBound)
        if close > trendTracker
            trendDirection := 1
            trendTracker := lowerBound

plot(trendDirection == 1 ? trendTracker : na, "Trend Tracker (Bullish)", color=c_bull_bright, linewidth=2, style=plot.style_line)
plot(trendDirection == -1 ? trendTracker : na, "Trend Tracker (Bearish)", color=c_bear_bright, linewidth=2, style=plot.style_line)

color bgCol = trendDirection == 1 ? color.new(c_bull_bright, 95) : color.new(c_bear_bright, 95)
bgcolor(showTrendBg ? bgCol : na, title="Trend Background Color")

// ============================================================================
// 3. FULL TREND CANDLE COLORING (100% PURE GREEN & RED)
// ============================================================================
color candleColor = na

if showBarColors
    if trendDirection == 1
        candleColor := solidTrendColors ? c_bull_bright : (close >= open ? c_bull_bright : c_bull_dark)
    else
        candleColor := solidTrendColors ? c_bear_bright : (close <= open ? c_bear_bright : c_bear_dark)

barcolor(showBarColors ? candleColor : na, title="Full Trend Bar Color")

// ============================================================================
// 4. CLEAN HIGH-PROBABILITY SIGNAL ENGINE (STRICT 1 BUY -> 1 SELL ALTERNATION)
// ============================================================================
trendFlippedBull = ta.crossover(close, trendTracker)
trendFlippedBear = ta.crossunder(close, trendTracker)

volMa = ta.sma(adaptiveVol, 20)
isVolatilityExpanding = adaptiveVol > (volMa * 1.05)
priceBreakoutBull     = close > ta.highest(high[1], 5)
priceBreakoutBear     = close < ta.lowest(low[1], 5)

var int activePosition = 0
var int lastSignalBar  = 0

bool rawBullSignal = (trendFlippedBull or (trendDirection == 1 and activePosition != 1 and priceBreakoutBull and isVolatilityExpanding))
bool rawBearSignal = (trendFlippedBear or (trendDirection == -1 and activePosition != -1 and priceBreakoutBear and isVolatilityExpanding))

if filterSignalsByTrend
    rawBullSignal := rawBullSignal and (trendDirection == 1)
    rawBearSignal := rawBearSignal and (trendDirection == -1)

bool triggerBuy  = rawBullSignal and (activePosition != 1)
bool triggerSell = rawBearSignal and (activePosition != -1)

var float tradeEntryPrice = na
var float tradeStopLoss   = na
var float tradeTp1        = na
var float tradeTp2        = na
var float tradeTp3        = na

if triggerBuy
    activePosition  := 1
    lastSignalBar   := bar_index
    tradeEntryPrice := close
    tradeStopLoss   := trendTracker < close ? trendTracker : close - (trendAtr * 1.5)
    float riskDist  = math.max(tradeEntryPrice - tradeStopLoss, syminfo.mintick * 10)
    tradeTp1        := tradeEntryPrice + (riskDist * riskRewardRatio1)
    tradeTp2        := tradeEntryPrice + (riskDist * riskRewardRatio2)
    tradeTp3        := tradeEntryPrice + (riskDist * riskRewardRatio3)

    string lblText = signalMode == "Strong Signals Only (Ultra Clean)" ? "Strong" : "Buy"
    label.new(bar_index, low - (trendAtr * 0.5), text=lblText, color=c_bull_bright, textcolor=color.black, style=label.style_label_up, size=size.small, tooltip="[AlgoChief] Bullish Trend Entry")

if triggerSell
    activePosition  := -1
    lastSignalBar   := bar_index
    tradeEntryPrice := close
    tradeStopLoss   := trendTracker > close ? trendTracker : close + (trendAtr * 1.5)
    float riskDist  = math.max(tradeStopLoss - tradeEntryPrice, syminfo.mintick * 10)
    tradeTp1        := tradeEntryPrice - (riskDist * riskRewardRatio1)
    tradeTp2        := tradeEntryPrice - (riskDist * riskRewardRatio2)
    tradeTp3        := tradeEntryPrice - (riskDist * riskRewardRatio3)

    string lblText = signalMode == "Strong Signals Only (Ultra Clean)" ? "Strong" : "Sell"
    label.new(bar_index, high + (trendAtr * 0.5), text=lblText, color=c_bear_bright, textcolor=color.white, style=label.style_label_down, size=size.small, tooltip="[AlgoChief] Bearish Trend Entry")

// ============================================================================
// 5. OPTIONAL CONTRARIAN SNIPER & EXHAUSTION (OFF BY DEFAULT TO KEEP CHART CLEAN)
// ============================================================================
stdevEquilibrium = ta.stdev(close, eqLength)
zScore = stdevEquilibrium > 0 ? (close - equilibrium) / stdevEquilibrium : 0.0

bool isExhaustionHigh = showExhaustionDots and (high >= cloudUpperInner or zScore >= 2.2) and high == ta.highest(high, 10)
bool isExhaustionLow  = showExhaustionDots and (low <= cloudLowerInner or zScore <= -2.2) and low == ta.lowest(low, 10)

plotshape(isExhaustionHigh, title="Overbought Dot", style=shape.circle, location=location.abovebar, color=c_exhaust_dot, size=size.tiny)
plotshape(isExhaustionLow,  title="Oversold Dot",  style=shape.circle, location=location.belowbar, color=c_exhaust_dot, size=size.tiny)

if showSniperSignals
    var int lastSniperBar = 0
    bool rawSniperBuy  = (low <= cloudLowerInner or zScore <= -2.2) and close > open and close > low[1] and (bar_index - lastSniperBar > 20)
    bool rawSniperSell = (high >= cloudUpperInner or zScore >= 2.2) and close < open and close < high[1] and (bar_index - lastSniperBar > 20)
    if rawSniperBuy
        lastSniperBar := bar_index
        label.new(bar_index, low - (trendAtr * 0.4), text="Buy", color=c_sniper_buy, textcolor=color.white, style=label.style_label_up, size=size.small)
    if rawSniperSell
        lastSniperBar := bar_index
        label.new(bar_index, high + (trendAtr * 0.4), text="Sell", color=c_sniper_sell, textcolor=color.black, style=label.style_label_down, size=size.small)

// ============================================================================
// 6. OPTIONAL S/R RETEST ZONES (OFF BY DEFAULT)
// ============================================================================
var box[] resBoxes = array.new_box()
var box[] supBoxes = array.new_box()

if showSRZones
    pivotHighVal = ta.pivothigh(high, srPivotLen, srPivotLen)
    pivotLowVal  = ta.pivotlow(low, srPivotLen, srPivotLen)

    if not na(pivotHighVal)
        float topLvl   = pivotHighVal
        float botLvl   = pivotHighVal - (adaptiveVol * srZoneThicknessAtr)
        int   startIdx = bar_index - srPivotLen
        box newResBox  = box.new(left=startIdx, top=topLvl, right=bar_index + 20, bottom=botLvl, 
                                 border_color=color.new(c_bear_bright, 35), border_width=1, bgcolor=color.new(c_bear_dark, 75))
        array.push(resBoxes, newResBox)
        if array.size(resBoxes) > 3
            box oldBox = array.shift(resBoxes)
            box.delete(oldBox)

    if not na(pivotLowVal)
        float botLvl   = pivotLowVal
        float topLvl   = pivotLowVal + (adaptiveVol * srZoneThicknessAtr)
        int   startIdx = bar_index - srPivotLen
        box newSupBox  = box.new(left=startIdx, top=topLvl, right=bar_index + 20, bottom=botLvl, 
                                 border_color=color.new(c_bull_bright, 35), border_width=1, bgcolor=color.new(c_bull_dark, 75))
        array.push(supBoxes, newSupBox)
        if array.size(supBoxes) > 3
            box oldBox = array.shift(supBoxes)
            box.delete(oldBox)

    if barstate.islast
        if array.size(resBoxes) > 0
            for i = 0 to array.size(resBoxes) - 1
                box b = array.get(resBoxes, i)
                box.set_right(b, bar_index + 20)

        if array.size(supBoxes) > 0
            for i = 0 to array.size(supBoxes) - 1
                box b = array.get(supBoxes, i)
                box.set_right(b, bar_index + 20)

// ============================================================================
// 7. ACTIVE TRADE TP / SL DYNAMIC PROJECTION LINES
// ============================================================================
var line slLine  = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

if showTpSlLines and not na(tradeEntryPrice) and activePosition != 0
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)

    int lineStart = lastSignalBar
    int lineEnd   = bar_index + 12
    slLine  := line.new(lineStart, tradeStopLoss, lineEnd, tradeStopLoss, color=color.new(c_bear_bright, 20), style=line.style_dashed, width=2)
    tp1Line := line.new(lineStart, tradeTp1, lineEnd, tradeTp1, color=color.new(c_bull_bright, 40), style=line.style_dotted, width=1)
    tp2Line := line.new(lineStart, tradeTp2, lineEnd, tradeTp2, color=color.new(c_bull_bright, 20), style=line.style_dashed, width=1)
    tp3Line := line.new(lineStart, tradeTp3, lineEnd, tradeTp3, color=color.new(c_bull_bright, 0), style=line.style_solid, width=2)

// ============================================================================
// 8. COMPACT RISK MANAGEMENT HUD TABLE
// ============================================================================
var table hud = table.new(position.top_right, 2, 6, bgcolor=color.new(#131722, 10), border_color=color.new(#2A2E39, 50), border_width=1)

f_setTablePosition(string pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

if barstate.islast and showDashboard
    table.set_position(hud, f_setTablePosition(dashboardPos))
    
    table.merge_cells(hud, 0, 0, 1, 0)
    table.cell(hud, 0, 0, "[AlgoChief] Z-ALGO", bgcolor=color.new(#2962FF, 20), text_color=color.white, text_size=size.tiny)
    
    string trendText = trendDirection == 1 ? "BULLISH ▲" : "BEARISH ▼"
    color  trendBg   = trendDirection == 1 ? color.new(c_bull_bright, 80) : color.new(c_bear_bright, 80)
    table.cell(hud, 0, 1, "Trend", text_color=color.silver, text_size=size.tiny)
    table.cell(hud, 1, 1, trendText, bgcolor=trendBg, text_color=color.white, text_size=size.tiny)

    string sigText = activePosition == 1 ? "LONG" : activePosition == -1 ? "SHORT" : "WAITING"
    color  sigBg   = activePosition == 1 ? color.new(c_bull_bright, 65) : activePosition == -1 ? color.new(c_bear_bright, 65) : color.new(color.gray, 65)
    table.cell(hud, 0, 2, "Position", text_color=color.silver, text_size=size.tiny)
    table.cell(hud, 1, 2, sigText + (not na(tradeEntryPrice) ? " @" + str.tostring(tradeEntryPrice, "#.##") : ""), bgcolor=sigBg, text_color=color.white, text_size=size.tiny)

    table.cell(hud, 0, 3, "SL", text_color=color.silver, text_size=size.tiny)
    table.cell(hud, 1, 3, not na(tradeStopLoss) ? str.tostring(tradeStopLoss, "#.##") : "-", bgcolor=color.new(c_bear_dark, 70), text_color=c_bear_bright, text_size=size.tiny)

    table.cell(hud, 0, 4, "TP1 / TP2", text_color=color.silver, text_size=size.tiny)
    table.cell(hud, 1, 4, (not na(tradeTp1) ? str.tostring(tradeTp1, "#.##") : "-") + " | " + (not na(tradeTp2) ? str.tostring(tradeTp2, "#.##") : "-"), bgcolor=color.new(c_bull_dark, 70), text_color=c_bull_bright, text_size=size.tiny)

    table.cell(hud, 0, 5, "TP3 Runner", text_color=color.silver, text_size=size.tiny)
    table.cell(hud, 1, 5, not na(tradeTp3) ? str.tostring(tradeTp3, "#.##") : "-", bgcolor=color.new(c_bull_dark, 50), text_color=c_bull_bright, text_size=size.tiny)

// ============================================================================
// 9. ALERTS
// ============================================================================
alertcondition(triggerBuy,  title="[AlgoChief] Strong Buy Signal", message="Z-Algo [AlgoChief]: STRONG BUY Signal triggered on {{ticker}} at {{close}}")
alertcondition(triggerSell, title="[AlgoChief] Strong Sell Signal", message="Z-Algo [AlgoChief]: STRONG SELL Signal triggered on {{ticker}} at {{close}}")
alertcondition(trendFlippedBull, title="[AlgoChief] Trend Flipped Bullish", message="Z-Algo [AlgoChief]: Market Trend flipped BULLISH on {{ticker}}")
alertcondition(trendFlippedBear, title="[AlgoChief] Trend Flipped Bearish", message="Z-Algo [AlgoChief]: Market Trend flipped BEARISH on {{ticker}}")
````
