<!-- tradingview-pine-id: PUB;1ff58e182bfa405d964a4982661a42ab -->
<!-- tradingviewscripts-format: 1 -->
# RK Gold Sniper AI PRO

Source: https://www.tradingview.com/script/wTvvjVJi-RK-Gold-Sniper-AI-PRO/

## Description

Hi this indicator will help a lot for the trading community and will give a lot of helping hand for everyone

---

## Source Code

````pine
//@version=6
strategy("RK Gold Sniper AI PRO", shorttitle="RKSniper", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=1.0, commission_type=strategy.commission.percent, commission_value=0.02, max_lines_count=500, max_labels_count=500, max_boxes_count=500, calc_on_every_tick=false)

// =====================================================================================================================
// DEVELOPER WATERMARK & INFORMATION
// Project Name : RK Gold Sniper AI PRO
// Developer    : Developed for RK
// Target Market: XAUUSD (Gold) Intraday Scalping (1M / 5M Timeframes)
// Standard     : Pine Script v6 Non-Repainting Professional Institutional Strategy Engine
// =====================================================================================================================

// =====================================================================================================================
// 1. INPUT CONFIGURATIONS
// =====================================================================================================================

string G_STRAT        = "=== Strategy & Multi-Timeframe Settings ==="
bool   i_useMTF       = input.bool(true, "Enable Higher Timeframe Trend Alignment", group=G_STRAT, tooltip="Filters 1M entries with 5M higher timeframe trend direction")
string i_htfTF        = input.timeframe("5", "Higher Timeframe", group=G_STRAT)

string G_EMA          = "=== Exponential Moving Averages ==="
int    i_ema9Len      = input.int(9, "Fast EMA 1 (9)", group=G_EMA)
int    i_ema21Len     = input.int(21, "Fast EMA 2 (21)", group=G_EMA)
int    i_ema50Len     = input.int(50, "Medium EMA (50)", group=G_EMA)
int    i_ema200Len    = input.int(200, "Macro Trend EMA (200)", group=G_EMA)
float  i_slopeThresh  = input.float(0.05, "Minimum EMA 200 Slope (ATR Normalized)", step=0.01, group=G_EMA, tooltip="Ignores signals when EMA200 is flat. Uses ATR to normalize cross-asset volatility.")

string G_TL           = "=== Automatic Trendline AI Engine ==="
int    i_pivotLen     = input.int(5, "Pivot Left/Right Strength", minval=2, group=G_TL)
float  i_minBodyPct   = input.float(0.50, "Min Breakout Candle Body Ratio", step=0.05, group=G_TL, tooltip="Filters Dojis & Spinning Tops")
float  i_maxWickPct   = input.float(0.35, "Max Wicks Ratio Limit", step=0.05, group=G_TL, tooltip="Rejects breakout candles with long wicks")

string G_RETEST       = "=== Retest Filter Engine ==="
int    i_retestMax    = input.int(10, "Max Bars to Wait for Retest", minval=1, maxval=30, group=G_RETEST)
float  i_retestAtrMult= input.float(0.3, "Retest Zone Tolerance (ATR Multiplier)", step=0.1, group=G_RETEST, tooltip="Uses ATR to dynamically scale retest precision")

string G_FILT         = "=== Indicator & Momentum Filters ==="
int    i_adxLen       = input.int(14, "ADX Period", group=G_FILT)
float  i_adxThresh    = input.float(25.0, "Minimum ADX Trend Strength", group=G_FILT)
string i_volMode      = input.string("Relative Volume", "Volume Filter Mode", options=["Relative Volume", "Simple Volume", "Disabled"], group=G_FILT)
int    i_volMaLen     = input.int(20, "Volume Moving Average Period", group=G_FILT)
float  i_volMult      = input.float(1.1, "Min Breakout Volume Multiplier", step=0.1, group=G_FILT)

string G_SMC          = "=== Smart Money Concepts (SMC) ==="
bool   i_useSMC       = input.bool(true, "Enable SMC Filters", group=G_SMC)
bool   i_useBOS       = input.bool(true, "Require Market Structure Confirmation (BOS)", group=G_SMC)
bool   i_useFVG       = input.bool(true, "Require Unmitigated FVG Alignment", group=G_SMC)

string G_SCORE        = "=== Institutional AI Scoring Engine ==="
int    i_minScore     = input.int(90, "Minimum Confidence Score (0-100)", minval=50, maxval=100, step=5, group=G_SCORE)

string G_RISK         = "=== Execution & Risk Management ==="
float  i_rrRatio      = input.float(3.0, "Target Risk-to-Reward Ratio (1:N)", minval=1.0, step=0.5, group=G_RISK)
int    i_atrLen       = input.int(14, "ATR Period", group=G_RISK)
float  i_atrMultSL    = input.float(1.5, "ATR Stop Loss Multiplier", step=0.1, group=G_RISK)

string G_SESS         = "=== Session Time Filters (UTC) ==="
bool   i_useSession   = input.bool(true, "Restrict Entries to Active Sessions", group=G_SESS)
string i_sessionText  = input.string("0700-2100", "Session Hours (London & NY)", group=G_SESS, tooltip="Format: HHMM-HHMM. Example: 0700-1600 (London), 1300-2100 (NY). 0700-2100 covers both. Asian session ignored.")

string G_VIS          = "=== Dashboard & Visual Options ==="
bool   i_showDash     = input.bool(true, "Display Top-Left Live Dashboard", group=G_VIS)
bool   i_showVisuals  = input.bool(true, "Draw Entry/SL/TP Levels & Trendlines", group=G_VIS)
color  i_c_bull       = input.color(color.rgb(38, 166, 154), "Bullish Color", group=G_VIS)
color  i_c_bear       = input.color(color.rgb(239, 83, 80), "Bearish Color", group=G_VIS)

// =====================================================================================================================
// 2. TYPES & GLOBAL STRUCTURES
// =====================================================================================================================

type TrendlineAI
    line   lineObj
    int    x1
    float  y1
    int    x2
    float  y2
    bool   isBullish
    bool   isActive
    bool   isBroken

type TradeSetup
    bool   isActive
    bool   isBullish
    float  breakLevel
    int    breakBar

// =====================================================================================================================
// 3. CORE TECHNICAL INDICATORS (NON-REPAINTING)
// =====================================================================================================================

// Executed globally to satisfy Pine Script v6 strict calculation rules (No warnings)
float ma9   = ta.ema(close, i_ema9Len)
float ma21  = ta.ema(close, i_ema21Len)
float ma50  = ta.ema(close, i_ema50Len)
float ma200 = ta.ema(close, i_ema200Len)

float atrValue = ta.atr(i_atrLen)
float ma200_5 = ma200[5]

// Normalized EMA Slope Calculation (Safe against 0 ATR)
float ema200Slope = atrValue != 0 ? ((ma200 - ma200_5) / (5.0 * atrValue)) : 0.0
bool  isEma200Flat = math.abs(ema200Slope) < i_slopeThresh

[plusDI, minusDI, adxValue] = ta.dmi(i_adxLen, i_adxLen)

// Volume Analytics
float volMa = ta.sma(volume, i_volMaLen)
bool hasVolumeSpike = i_volMode == "Relative Volume" ? (volume > (volMa * i_volMult)) : (i_volMode == "Simple Volume" ? (volume > volMa) : true)

// Breakout Candle Analytics
float fullRange  = high - low
float bodySize   = math.abs(close - open)
float topWick    = high - math.max(open, close)
float bottomWick = math.min(open, close) - low

float bodyRatio  = fullRange > 0 ? (bodySize / fullRange) : 0.0
float maxWickRat = fullRange > 0 ? (math.max(topWick, bottomWick) / fullRange) : 0.0

// Unified on single lines to prevent line-continuation syntax errors
bool isValidBreakoutBull = (bodyRatio >= i_minBodyPct) and (maxWickRat <= i_maxWickPct) and (close > open)
bool isValidBreakoutBear = (bodyRatio >= i_minBodyPct) and (maxWickRat <= i_maxWickPct) and (close < open)

// Multi-Timeframe Trend (Lookahead off, gap off)
float htfEma200 = request.security(syminfo.tickerid, i_htfTF, ta.ema(close, i_ema200Len), barmerge.gaps_off, barmerge.lookahead_off)
float htfClose  = request.security(syminfo.tickerid, i_htfTF, close, barmerge.gaps_off, barmerge.lookahead_off)
bool htfBullish = not i_useMTF or (htfClose > htfEma200)
bool htfBearish = not i_useMTF or (htfClose < htfEma200)

bool isInSession = not i_useSession or not na(time(timeframe.period, i_sessionText, "UTC"))

// =====================================================================================================================
// 4. MARKET STRUCTURE & SMC ENGINE
// =====================================================================================================================

// Pivot Detection (Uses actual Bar Indexes to prevent float equality bugs)
var float lastPH = na
var int lastPH_idx = na
var float prevPH = na
var int prevPH_idx = na
var float lastPL = na
var int lastPL_idx = na
var float prevPL = na
var int prevPL_idx = na

float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low, i_pivotLen, i_pivotLen)

if not na(ph)
    prevPH := lastPH
    prevPH_idx := lastPH_idx
    lastPH := ph
    lastPH_idx := bar_index - i_pivotLen

if not na(pl)
    prevPL := lastPL
    prevPL_idx := lastPL_idx
    lastPL := pl
    lastPL_idx := bar_index - i_pivotLen

// Market Structure Trend State (BOS Tracking)
bool crossOverLastPH = ta.crossover(close, lastPH)
bool crossUnderLastPL = ta.crossunder(close, lastPL)

var int msState = 0 // 1 = Bullish, -1 = Bearish
if crossOverLastPH
    msState := 1
else if crossUnderLastPL
    msState := -1
bool msBullish = msState == 1
bool msBearish = msState == -1

// Fair Value Gap (ICT Style with Mitigation Tracking - Calculated globally)
float bullFvgBot = high[2]
float bullFvgTop = low[0]
float bearFvgTop = low[2]
float bearFvgBot = high[0]

bool fvgBull_formed = (bullFvgTop > bullFvgBot) and (close[1] > open[1]) and ((bullFvgTop - bullFvgBot) > (atrValue * 0.1))
bool fvgBear_formed = (bearFvgBot < bearFvgTop) and (close[1] < open[1]) and ((bearFvgTop - bearFvgBot) > (atrValue * 0.1))

var float currFVGBullTop = na
var float currFVGBullBot = na
var float currFVGBearTop = na
var float currFVGBearBot = na

if fvgBull_formed
    currFVGBullTop := bullFvgTop
    currFVGBullBot := bullFvgBot
if fvgBear_formed
    currFVGBearTop := bearFvgTop
    currFVGBearBot := bearFvgBot

// FVG Mitigation
if not na(currFVGBullBot) and low < currFVGBullBot
    currFVGBullTop := na // Fully Mitigated
if not na(currFVGBearTop) and high > currFVGBearTop
    currFVGBearTop := na // Fully Mitigated

bool hasRecentFVGBull = not na(currFVGBullTop)
bool hasRecentFVGBear = not na(currFVGBearTop)

// =====================================================================================================================
// 5. AUTOMATIC TRENDLINE AI ENGINE
// =====================================================================================================================

var TrendlineAI tlResist = TrendlineAI.new(na, 0, 0.0, 0, 0.0, false, false, false)
var TrendlineAI tlSupport = TrendlineAI.new(na, 0, 0.0, 0, 0.0, true, false, false)

// Resistance Trendline (Lower Highs)
if not na(ph) and not na(prevPH_idx)
    if prevPH > lastPH
        if not na(tlResist.lineObj)
            line.delete(tlResist.lineObj)
        line lRes = i_showVisuals ? line.new(prevPH_idx, prevPH, lastPH_idx, lastPH, color=i_c_bear, width=2, extend=extend.right) : na
        tlResist := TrendlineAI.new(lRes, prevPH_idx, prevPH, lastPH_idx, lastPH, false, true, false)

// Support Trendline (Higher Lows)
if not na(pl) and not na(prevPL_idx)
    if prevPL < lastPL
        if not na(tlSupport.lineObj)
            line.delete(tlSupport.lineObj)
        line lSup = i_showVisuals ? line.new(prevPL_idx, prevPL, lastPL_idx, lastPL, color=i_c_bull, width=2, extend=extend.right) : na
        tlSupport := TrendlineAI.new(lSup, prevPL_idx, prevPL, lastPL_idx, lastPL, true, true, false)

// Project Trendline Y-Values safely
getTLValue(TrendlineAI tl, int targetBar) =>
    float result = na
    if tl.isActive and tl.x2 != tl.x1
        float slope = (tl.y2 - tl.y1) / float(tl.x2 - tl.x1)
        result := tl.y2 + (slope * float(targetBar - tl.x2))
    result

float currentResistVal = getTLValue(tlResist, bar_index)
float prevResistVal    = getTLValue(tlResist, bar_index - 1)
float currentSupportVal= getTLValue(tlSupport, bar_index)
float prevSupportVal   = getTLValue(tlSupport, bar_index - 1)

// =====================================================================================================================
// 6. BREAKOUT & RETEST FILTER ENGINE
// =====================================================================================================================

// Breakout Detection (Single line logic strictly maintaining validity)
bool isResistBreakout = tlResist.isActive and not tlResist.isBroken and not na(currentResistVal) and not na(prevResistVal) and close > currentResistVal and close[1] <= prevResistVal and isValidBreakoutBull
bool isSupportBreakout = tlSupport.isActive and not tlSupport.isBroken and not na(currentSupportVal) and not na(prevSupportVal) and close < currentSupportVal and close[1] >= prevSupportVal and isValidBreakoutBear

var TradeSetup setup = TradeSetup.new(false, false, 0.0, 0)

if isResistBreakout
    tlResist.isBroken := true
    if i_showVisuals and not na(tlResist.lineObj)
        line.set_style(tlResist.lineObj, line.style_dashed)
    setup.isActive := true
    setup.isBullish := true
    setup.breakLevel := currentResistVal
    setup.breakBar := bar_index

if isSupportBreakout
    tlSupport.isBroken := true
    if i_showVisuals and not na(tlSupport.lineObj)
        line.set_style(tlSupport.lineObj, line.style_dashed)
    setup.isActive := true
    setup.isBullish := false
    setup.breakLevel := currentSupportVal
    setup.breakBar := bar_index

// Retest Validation using ATR Tolerance
bool retestConfirmedBull = false
bool retestConfirmedBear = false
float retestZoneSize = atrValue * i_retestAtrMult

if setup.isActive
    int barsSinceBreak = bar_index - setup.breakBar
    
    if barsSinceBreak > i_retestMax
        setup.isActive := false
    else if barsSinceBreak > 0
        if setup.isBullish
            bool touchedZone = low <= (setup.breakLevel + retestZoneSize)
            bool holdSupport = close >= setup.breakLevel and close > open
            if touchedZone and holdSupport
                retestConfirmedBull := true
                setup.isActive := false // Consume Setup
        else
            bool touchedZone = high >= (setup.breakLevel - retestZoneSize)
            bool holdResist = close <= setup.breakLevel and close < open
            if touchedZone and holdResist
                retestConfirmedBear := true
                setup.isActive := false // Consume Setup

// =====================================================================================================================
// 7. INSTITUTIONAL CONFIDENCE SCORING ENGINE (Max 100 Points)
// =====================================================================================================================

calcScore(bool isBull, float ma200Val, float ma9Val, float ma21Val, float slopeVal, float adxVal, bool volSpike, bool msBull, bool msBear, bool fvgBull, bool fvgBear) =>
    int score = 0
    // 1. Macro Trend & HTF Alignment (20 pts)
    if (isBull and close > ma200Val and htfBullish) or (not isBull and close < ma200Val and htfBearish)
        score += 20
    // 2. Momentum & EMA Cross (15 pts)
    if (isBull and ma9Val > ma21Val and slopeVal > 0) or (not isBull and ma9Val < ma21Val and slopeVal < 0)
        score += 15
    // 3. ADX Trend Strength (15 pts)
    if adxVal >= i_adxThresh
        score += 15
    // 4. Volume Confirmation (10 pts)
    if volSpike
        score += 10
    // 5. Breakout / Retest Quality (20 pts)
    score += 20 // Inherently awarded since execution requires retest completion
    // 6. Market Structure & SMC (20 pts)
    if not i_useSMC
        score += 20 // Pass if disabled
    else
        if (isBull and msBull) or (not isBull and msBear)
            score += 10
        if (isBull and fvgBull) or (not isBull and fvgBear)
            score += 10
    math.min(score, 100)

int bullScore = calcScore(true, ma200, ma9, ma21, ema200Slope, adxValue, hasVolumeSpike, msBullish, msBearish, hasRecentFVGBull, hasRecentFVGBear)
int bearScore = calcScore(false, ma200, ma9, ma21, ema200Slope, adxValue, hasVolumeSpike, msBullish, msBearish, hasRecentFVGBull, hasRecentFVGBear)

// =====================================================================================================================
// 8. EXECUTION & RISK MANAGEMENT
// =====================================================================================================================

// Strict bar confirmation rule applied explicitly to signals
bool isConfirmed = barstate.isconfirmed

bool validBuy  = isConfirmed and retestConfirmedBull and (bullScore >= i_minScore) and isInSession and not isEma200Flat and (close > ma200)
bool validSell = isConfirmed and retestConfirmedBear and (bearScore >= i_minScore) and isInSession and not isEma200Flat and (close < ma200)

bool canEnter = strategy.position_size == 0

if validBuy and canEnter
    float slPrice = close - (atrValue * i_atrMultSL)
    float risk = close - slPrice // Mathematically guaranteed > 0
    float tpPrice = close + (risk * i_rrRatio)
    
    strategy.entry("Sniper Long", strategy.long)
    strategy.exit("Exit Long", "Sniper Long", stop=slPrice, limit=tpPrice)
    
    if i_showVisuals
        line.new(bar_index, close, bar_index + 10, close, color=color.blue, width=2)
        line.new(bar_index, slPrice, bar_index + 10, slPrice, color=color.red, width=2)
        line.new(bar_index, tpPrice, bar_index + 10, tpPrice, color=color.green, width=2)
        label.new(bar_index, low - atrValue, "BUY\n" + str.tostring(bullScore) + "%", color=i_c_bull, textcolor=color.white, style=label.style_label_up, size=size.small)

    string alertMsg = "{\"action\": \"BUY\", \"symbol\": \"" + syminfo.ticker + "\", \"price\": " + str.tostring(close) + ", \"sl\": " + str.tostring(slPrice) + ", \"tp\": " + str.tostring(tpPrice) + ", \"score\": " + str.tostring(bullScore) + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)

if validSell and canEnter
    float slPrice = close + (atrValue * i_atrMultSL)
    float risk = slPrice - close // Mathematically guaranteed > 0
    float tpPrice = close - (risk * i_rrRatio)
    
    strategy.entry("Sniper Short", strategy.short)
    strategy.exit("Exit Short", "Sniper Short", stop=slPrice, limit=tpPrice)
    
    if i_showVisuals
        line.new(bar_index, close, bar_index + 10, close, color=color.blue, width=2)
        line.new(bar_index, slPrice, bar_index + 10, slPrice, color=color.red, width=2)
        line.new(bar_index, tpPrice, bar_index + 10, tpPrice, color=color.green, width=2)
        label.new(bar_index, high + atrValue, "SELL\n" + str.tostring(bearScore) + "%", color=i_c_bear, textcolor=color.white, style=label.style_label_down, size=size.small)

    string alertMsg = "{\"action\": \"SELL\", \"symbol\": \"" + syminfo.ticker + "\", \"price\": " + str.tostring(close) + ", \"sl\": " + str.tostring(slPrice) + ", \"tp\": " + str.tostring(tpPrice) + ", \"score\": " + str.tostring(bearScore) + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)

// =====================================================================================================================
// 9. PROFESSIONAL EXIT DETECTION (Exact Trade Tracking via Pine v6 Built-ins)
// =====================================================================================================================

var int lastClosedTrades = 0
int currentClosedTrades = strategy.closedtrades

if currentClosedTrades > lastClosedTrades
    int lastTradeIdx = currentClosedTrades - 1
    float profit = strategy.closedtrades.profit(lastTradeIdx)
    string extMsg = profit > 0 ? "TP HIT" : (profit < 0 ? "SL HIT" : "BREAK EVEN")
    string alertMsg = "{\"action\": \"" + extMsg + "\", \"symbol\": \"" + syminfo.ticker + "\", \"price\": " + str.tostring(close) + ", \"profit\": " + str.tostring(profit) + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)

lastClosedTrades := currentClosedTrades

// =====================================================================================================================
// 10. CHART PLOTS
// =====================================================================================================================

plot(ma9,   "EMA 9",   color=color.new(color.blue, 0), linewidth=1)
plot(ma21,  "EMA 21",  color=color.new(color.orange, 0), linewidth=1)
plot(ma50,  "EMA 50",  color=color.new(color.purple, 0), linewidth=2)
color c_ma200 = isEma200Flat ? color.gray : (close > ma200 ? i_c_bull : i_c_bear)
plot(ma200, "EMA 200", color=c_ma200, linewidth=3)

// =====================================================================================================================
// 11. REAL-TIME INSTITUTIONAL DASHBOARD
// =====================================================================================================================

var table dash = table.new(position.top_left, 2, 8, bgcolor=color.rgb(15, 23, 42, 90), border_color=color.rgb(51, 65, 85), border_width=1)

if barstate.islast and i_showDash
    table.cell(dash, 0, 0, "RK Sniper AI PRO", text_color=color.rgb(250, 204, 21), text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "Status", text_color=color.white, text_size=size.normal, text_halign=text.align_right)
    
    string trndTxt = isEma200Flat ? "SIDEWAYS" : (close > ma200 ? "BULLISH" : "BEARISH")
    color trndCol  = isEma200Flat ? color.gray : (close > ma200 ? i_c_bull : i_c_bear)
    table.cell(dash, 0, 1, "Macro Trend", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, trndTxt, text_color=trndCol, text_size=size.small, text_halign=text.align_right)
    
    string adxTxt = str.tostring(adxValue, "#.#") + (adxValue >= i_adxThresh ? " (STRONG)" : " (WEAK)")
    color adxCol  = adxValue >= i_adxThresh ? color.lime : color.red
    table.cell(dash, 0, 2, "ADX (14)", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, adxTxt, text_color=adxCol, text_size=size.small, text_halign=text.align_right)
    
    table.cell(dash, 0, 3, "ATR (14)", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(atrValue, "#.##"), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    int currentScore = close > ma200 ? bullScore : bearScore
    color scoreCol = currentScore >= i_minScore ? color.lime : color.orange
    table.cell(dash, 0, 4, "AI Score", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(currentScore) + "/100", text_color=scoreCol, text_size=size.small, text_halign=text.align_right)
    
    table.cell(dash, 0, 5, "Session", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, isInSession ? "ACTIVE" : "INACTIVE", text_color=isInSession ? color.lime : color.gray, text_size=size.small, text_halign=text.align_right)
    
    string posTxt = strategy.position_size > 0 ? "LONG" : (strategy.position_size < 0 ? "SHORT" : "FLAT")
    color posCol  = strategy.position_size > 0 ? i_c_bull : (strategy.position_size < 0 ? i_c_bear : color.gray)
    table.cell(dash, 0, 6, "Trade Status", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posTxt, text_color=posCol, text_size=size.small, text_halign=text.align_right)
    
    table.cell(dash, 0, 7, "Default R:R", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, "1 : " + str.tostring(i_rrRatio, "#.#"), text_color=color.white, text_size=size.small, text_halign=text.align_right)
````
