# WiselyWealth ; Tri-Momentum Divergence & Risk Suite

- url: https://www.tradingview.com/script/BYhrSKT3-WiselyWealth-Tri-Momentum-Divergence-Risk-Suite/
- type: indicator
- pine_id: PUB;6ff14b17ab174615a7f144254f8767a5
- version: 1.0

## Description

The "Tri-Momentum Divergence & Risk Suite" (TMDR Suite" is a professional-grade TradingView indicator written in Pine Script version 6 that integrates technical analysis with comprehensive risk management. The primary objective of this script is to eliminate the false signals commonly encountered when relying on a single momentum indicator for reversal points. Its core philosophy relies on synthesizing data from three non-correlated oscillators to confirm price-momentum divergences, thereby increasing accuracy. Additionally, the script is designed to automate position sizing and risk management, ensuring a systematic and safer trading approach.

## Technical Mechanisms
The script operates through four complex technical processes:
* **Pivot Detection:** The system identifies Pivot Highs and Pivot Lows by analyzing 5 left and 5 right candles by default to confirm the swing cycle. Waiting for the right candles to close prevents zero look-ahead bias and ensures the signals are non-repainting. It also filters noise by establishing minimum and maximum lookback distances between pivot points.

* **Tri-Momentum Oscillators:** The script evaluates price strength using three distinct tools:
* Relative Strength Index (RSI - 14): Measures the velocity and internal strength of price movements.
* MACD Histogram (12, 26, 9): Evaluates the overall trend momentum.
* Williams %R (W%R - 14): Assesses extreme price conditions to determine how close the asset is to historical highs or lows.

* **Signal Generation:**
* **Bullish Divergence:** A buy signal triggers when the price forms a Lower Low, but at least N oscillators (defaulting to 2 out of 3) form a Higher Low. This indicates that selling pressure is exhausting and a potential upward reversal is imminent.

* **Bearish Divergence:** A sell signal triggers when the price forms a Higher High, but at least N oscillators print a Lower High. This suggests that buying momentum is fading and a downward reversal or consolidation may occur.

* **Risk Management Engine:** Upon detecting a signal, the script calculates dynamic targets using the Average True Range (ATR). It automatically sets the Stop Loss at 1.5 times the ATR and the Take Profit at 3.0 times the ATR. It then calculates the optimal position size based on the user's account capital and defined risk tolerance percentage (e.g., 1%), ensuring strict risk control for every trade.

## Configuration and Application
The script is highly flexible and can be adapted to various trading styles and conditions:
* **Market Adaptation:** Users can adjust the "Min Oscillator Confirmations" filter. Setting it to 1-2 provides faster signals, while setting it to 3 requires strict confluence across the RSI, MACD, and Williams %R simultaneously. In highly volatile markets, increasing the Pivot Left/Right Bars (e.g., from 5 to 10) filters out minor waves to capture major, significant swings.

* **Capital Management:** Users can input their actual Account Capital and desired Risk Per Trade in the Risk Management settings. For spot trading without leverage, enabling the "Cap Size to 100% Cash Capital" function prevents the system from suggesting position sizes that exceed available cash.

* **Suitable Markets and Timeframes:** Utilizing universal indicators, the script functions effectively across liquid markets including cryptocurrency, forex, stocks, and commodities. Divergence strategies typically perform best on medium to high timeframes, such as 15-minute, 1-hour, 4-hour, and daily charts, as these reduce irrelevant price noise found in lower timeframes.

* **Visuals and Analytics (HUD):** The script draws immediate Projection Lines on the chart for Entry, Take Profit, and Stop Loss levels when a signal occurs. Enabling the HUD Dashboard displays real-time oscillator values and historical backtesting statistics, including win rate, net profit, and maximum drawdown. This allows traders to evaluate the strategy's historical performance on a specific asset before committing real capital.

## Source Code

````pine
//@version=6
indicator("WiselyWealth ; Tri-Momentum Divergence & Risk Suite", 
          shorttitle="TMDR Suite", 
          overlay=true, 
          max_lines_count=500, 
          max_labels_count=500, 
          max_boxes_count=500)

// =============================================================================
// TRI-MOMENTUM DIVERGENCE & RISK SUITE (PINE SCRIPT VERSION 6)
// =============================================================================
// Core Philosophy:
// Traditional single-indicator divergences are prone to false signals and noise.
// This indicator synthesizes three distinct non-correlated momentum oscillators:
//   1. Relative Strength Index (RSI - 14)          -> Velocity & internal strength
//   2. Moving Average Convergence Divergence (MACD Histogram 12, 26, 9) -> Trend momentum
//   3. Williams %R (W%R - 14)                       -> High/Low extreme price positioning
//
// Logic:
// - Detects Pivot Highs and Pivot Lows with a 5-bar leg by default.
// - Bullish Divergence (Buy Signal): Price makes a Lower Low (LL) relative to the prior Pivot Low,
//   while at least N oscillators (configurable confirmation count, default: 2) form a Higher Low (HL).
// - Bearish Divergence (Sell Signal): Price makes a Higher High (HH) relative to the prior Pivot High,
//   while at least N oscillators form a Lower High (LH).
//
// Risk Management & Position Calculator:
// - Dynamic Take Profit (TP = 3.0 * ATR) and Stop Loss (SL = 1.5 * ATR).
// - Computes exact lot/contract position sizing based on account capital and risk percentage.
// - Dynamic visual projection lines for TP, SL, and Entry on chart.
// - Built-in TradingView Alert conditions and real-time alert() calls.
// =============================================================================

// =============================================================================
// 1. INPUT CONFIGURATION & PARAMETERS
// =============================================================================

// --- Pivot Detection Settings ---
var string GRP_PIVOT = "1. Pivot Swing Settings"
int   pivotLeft      = input.int(5, "Pivot Left Bars", minval=1, maxval=50, group=GRP_PIVOT, 
                       tooltip="Number of bars to the left required to detect a swing high or low. Higher values identify major swing points, while lower values detect faster, minor swings.")
int   pivotRight     = input.int(5, "Pivot Right Bars", minval=1, maxval=50, group=GRP_PIVOT, 
                       tooltip="Number of bars to the right required to confirm a pivot. Signals trigger on confirmation bar close. Higher values increase reliability but add confirmation delay.")
int   minPivotBars   = input.int(5, "Min Distance Between Pivots", minval=1, group=GRP_PIVOT, 
                       tooltip="Minimum bar distance between two consecutive pivots. Prevents the indicator from comparing adjacent market noise or tightly clustered swings.")
int   maxPivotBars   = input.int(60, "Max Lookback Between Pivots", minval=10, maxval=300, group=GRP_PIVOT, 
                       tooltip="Maximum allowable bar distance between two pivots to form a divergence. Setups spanning longer than this lookback limit are considered obsolete.")

// --- Oscillator Settings ---
var string GRP_OSC   = "2. Oscillator Parameters"
int   rsiLength      = input.int(14, "RSI Length", minval=1, group=GRP_OSC, 
                       tooltip="Calculation period for the Relative Strength Index (RSI). Measures price velocity and momentum shifts between swing points.")
float rsiSource      = input.source(close, "RSI Source", group=GRP_OSC, 
                       tooltip="Price series used to calculate RSI. Default is close. Can be changed to hl2 or hlc3 for smoothed volatility responsiveness.")

int   macdFast       = input.int(12, "MACD Fast Length", minval=1, group=GRP_OSC, 
                       tooltip="Lookback period for the fast Exponential Moving Average (EMA) in MACD calculation. Default is 12.")
int   macdSlow       = input.int(26, "MACD Slow Length", minval=1, group=GRP_OSC, 
                       tooltip="Lookback period for the slow Exponential Moving Average (EMA) in MACD calculation. Default is 26.")
int   macdSignal     = input.int(9, "MACD Signal Smoothing", minval=1, group=GRP_OSC, 
                       tooltip="Smoothing period for the MACD signal line to generate the momentum histogram. Default is 9.")
float macdSource     = input.source(close, "MACD Source", group=GRP_OSC, 
                       tooltip="Price source used for MACD calculations. Determines which price series feeds both fast and slow moving averages.")

int   wprLength      = input.int(14, "Williams %R Length", minval=1, group=GRP_OSC, 
                       tooltip="Lookback period for Williams %R momentum oscillator. Evaluates where the current close sits relative to the highest high and lowest low.")

// --- Confirmation & Signal Filter ---
var string GRP_CONF  = "3. Divergence Confirmation Filter"
int   minConfirm     = input.int(2, "Min Oscillator Confirmations", minval=1, maxval=3, group=GRP_CONF, 
                       tooltip="Minimum number of oscillators that must simultaneously confirm divergence (1 to 3). Set to 2 for balanced confirmation, or 3 for strict confluence.")
bool  useRsiDiv      = input.bool(true, "Include RSI in Divergence Engine", group=GRP_CONF, 
                       tooltip="Enables Relative Strength Index (RSI) divergence checks. When enabled, RSI must show a higher low (bullish) or lower high (bearish) to qualify.")
bool  useMacdDiv     = input.bool(true, "Include MACD Hist in Divergence Engine", group=GRP_CONF, 
                       tooltip="Enables MACD Histogram divergence checks. When enabled, the histogram must show a higher low (bullish) or lower high (bearish) to qualify.")
bool  useWprDiv      = input.bool(true, "Include Williams %R in Divergence Engine", group=GRP_CONF, 
                       tooltip="Enables Williams %R divergence checks. When enabled, Williams %R must show a higher low (bullish) or lower high (bearish) to qualify.")

// --- Risk Management & Position Calculator ---
var string GRP_RISK  = "4. Risk Management & Position Calculator"
float accountCapital = input.float(10000.0, "Account Capital ($)", minval=1.0, group=GRP_RISK, 
                       tooltip="Total account equity used by the position sizing calculator to determine risk amount and recommended position sizes.")
float riskPercent    = input.float(1.0, "Risk Per Trade (% of Capital)", minval=0.1, maxval=10.0, step=0.1, group=GRP_RISK, 
                       tooltip="Percentage of account capital risked per trade. Used alongside Stop Loss distance to automatically calculate exact position sizing.")
int   atrLength      = input.int(14, "ATR Length", minval=1, group=GRP_RISK, 
                       tooltip="Lookback period for Average True Range (ATR). Measures current market volatility to dynamically scale Stop Loss and Take Profit distances.")
float atrSlMult      = input.float(1.5, "Stop Loss ATR Multiplier", minval=0.5, step=0.1, group=GRP_RISK, 
                       tooltip="Multiplier applied to ATR to determine Stop Loss distance from entry price. Stop Loss = Entry +/- (ATR * Multiplier).")
float atrTpMult      = input.float(3.0, "Take Profit ATR Multiplier", minval=0.5, step=0.1, group=GRP_RISK, 
                       tooltip="Multiplier applied to ATR to determine Take Profit distance from entry price. Take Profit = Entry -/+ (ATR * Multiplier).")
bool  capAtCapital   = input.bool(false, "Cap Size to 100% Cash Capital (No Leverage)", group=GRP_RISK, 
                       tooltip="Restricts recommended position size so total position value does not exceed account capital, avoiding leveraged exposure on spot accounts.")

// --- Performance Window & Statistics ---
var string GRP_PERF  = "5. Performance Window & Statistics"
bool  useDateFilter  = input.bool(true, "Enable Date Filter for Statistics", group=GRP_PERF, 
                       tooltip="Enables date filtering for performance statistics. When active, Win Rate, Drawdown, and PnL only account for trades within specified dates.")
int   startDate      = input.time(timestamp("2023-01-01 00:00"), "Statistics Start Date", group=GRP_PERF, 
                       tooltip="Starting timestamp for the performance statistics simulator. Trades occurring before this date are excluded from HUD dashboard metrics.")
int   endDate        = input.time(timestamp("2099-12-31 23:59"), "Statistics End Date", group=GRP_PERF, 
                       tooltip="Ending timestamp for the performance statistics simulator. Trades occurring after this date are excluded from HUD dashboard metrics.")

// --- Visual Appearance ---
var string GRP_VIS   = "6. Chart Visuals & Target Levels"
bool  showDivLines   = input.bool(true, "Draw Divergence Trendlines", group=GRP_VIS, 
                       tooltip="Draws visual trendlines directly on the price chart connecting the two pivot points that triggered the divergence setup.")
bool  showDetailLabels= input.bool(true, "Show Detailed Signal Labels", group=GRP_VIS, 
                       tooltip="Displays actionable chart labels on trigger bars showing trade direction, confirming oscillators, entry price, SL, TP, and calculated unit sizing.")
bool  showTargetRays = input.bool(true, "Project Active TP / SL Rays", group=GRP_VIS, 
                       tooltip="Projects dynamic horizontal lines across the chart representing active Entry price, Take Profit target, and Stop Loss level for current trades.")
bool  showDashboard  = input.bool(true, "Show Indicator HUD Dashboard", group=GRP_VIS, 
                       tooltip="Toggles the on-chart HUD dashboard displaying live oscillator values, confirmation counts, win rate, net profit, and max drawdown.")
color colBull        = input.color(#00E676, "Bullish Divergence Color", group=GRP_VIS, 
                       tooltip="Color used for bullish divergence visual elements, including trigger labels, trendlines, and positive dashboard indicators.")
color colBear        = input.color(#FF5252, "Bearish Divergence Color", group=GRP_VIS, 
                       tooltip="Color used for bearish divergence visual elements, including trigger labels, trendlines, and negative dashboard indicators.")

// =============================================================================
// 2. INDICATOR & OSCILLATOR COMPUTATIONS
// =============================================================================

// Volatility (ATR)
float atrValue = ta.atr(atrLength)

// Oscillator 1: Relative Strength Index (RSI)
float rsiValue = ta.rsi(rsiSource, rsiLength)

// Oscillator 2: MACD Histogram
[macdLine, signalLine, histLine] = ta.macd(macdSource, macdFast, macdSlow, macdSignal)

// Oscillator 3: Williams %R
float wprValue = ta.wpr(wprLength)

// =============================================================================
// 3. PIVOT DETECTION & DIVERGENCE ENGINE
// =============================================================================
// Pivot detection confirms `pivotRight` bars AFTER the swing formed.
// This guarantees zero look-ahead bias and non-repainting signals.

float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

// State tracking for previous confirmed pivots
var float prevHighPrice  = na
var int   prevHighBar    = na
var float prevHighRsi    = na
var float prevHighMacd   = na
var float prevHighWpr    = na

var float prevLowPrice   = na
var int   prevLowBar     = na
var float prevLowRsi     = na
var float prevLowMacd    = na
var float prevLowWpr     = na

// Signal variables for the current bar
bool  bullishDivergence  = false
bool  bearishDivergence  = false
int   bullConfCount      = 0
int   bearConfCount      = 0
string bullConfDetails   = ""
string bearConfDetails   = ""

// Coordinates for drawing divergence lines
var int   divStartBar    = na
var float divStartPrice  = na
var int   divEndBar      = na
var float divEndPrice    = na

// -----------------------------------------------------------------------------
// Bullish Divergence Detection (Pivot Lows)
// -----------------------------------------------------------------------------
if not na(pl)
    int   currLowBar   = bar_index - pivotRight
    float currLowPrice = pl
    float currLowRsi   = rsiValue[pivotRight]
    float currLowMacd  = histLine[pivotRight]
    float currLowWpr   = wprValue[pivotRight]

    if not na(prevLowPrice)
        int barsSincePrior = currLowBar - prevLowBar
        if barsSincePrior >= minPivotBars and barsSincePrior <= maxPivotBars
            // Price must form a Lower Low
            bool priceLowerLow = currLowPrice < prevLowPrice

            // Check oscillators for Higher Lows
            bool rsiHigherLow  = useRsiDiv and (currLowRsi > prevLowRsi)
            bool macdHigherLow = useMacdDiv and (currLowMacd > prevLowMacd)
            bool wprHigherLow  = useWprDiv and (currLowWpr > prevLowWpr)

            // Count confirmations
            int count = (rsiHigherLow ? 1 : 0) + (macdHigherLow ? 1 : 0) + (wprHigherLow ? 1 : 0)

            if priceLowerLow and count >= minConfirm
                bullishDivergence := true
                bullConfCount     := count
                
                string details = ""
                if rsiHigherLow
                    details += "RSI "
                if macdHigherLow
                    details += "MACD "
                if wprHigherLow
                    details += "W%R "
                bullConfDetails := str.trim(details)

                divStartBar   := prevLowBar
                divStartPrice := prevLowPrice
                divEndBar     := currLowBar
                divEndPrice   := currLowPrice

    // Update historical pivot low state
    prevLowPrice := currLowPrice
    prevLowBar   := currLowBar
    prevLowRsi   := currLowRsi
    prevLowMacd  := currLowMacd
    prevLowWpr   := currLowWpr

// -----------------------------------------------------------------------------
// Bearish Divergence Detection (Pivot Highs)
// -----------------------------------------------------------------------------
if not na(ph)
    int   currHighBar   = bar_index - pivotRight
    float currHighPrice = ph
    float currHighRsi   = rsiValue[pivotRight]
    float currHighMacd  = histLine[pivotRight]
    float currHighWpr   = wprValue[pivotRight]

    if not na(prevHighPrice)
        int barsSincePrior = currHighBar - prevHighBar
        if barsSincePrior >= minPivotBars and barsSincePrior <= maxPivotBars
            // Price must form a Higher High
            bool priceHigherHigh = currHighPrice > prevHighPrice

            // Check oscillators for Lower Highs
            bool rsiLowerHigh    = useRsiDiv and (currHighRsi < prevHighRsi)
            bool macdLowerHigh   = useMacdDiv and (currHighMacd < prevHighMacd)
            bool wprLowerHigh    = useWprDiv and (currHighWpr < prevHighWpr)

            // Count confirmations
            int count = (rsiLowerHigh ? 1 : 0) + (macdLowerHigh ? 1 : 0) + (wprLowerHigh ? 1 : 0)

            if priceHigherHigh and count >= minConfirm
                bearishDivergence := true
                bearConfCount     := count

                string details = ""
                if rsiLowerHigh
                    details += "RSI "
                if macdLowerHigh
                    details += "MACD "
                if wprLowerHigh
                    details += "W%R "
                bearConfDetails := str.trim(details)

                divStartBar   := prevHighBar
                divStartPrice := prevHighPrice
                divEndBar     := currHighBar
                divEndPrice   := currHighPrice

    // Update historical pivot high state
    prevHighPrice := currHighPrice
    prevHighBar   := currHighBar
    prevHighRsi   := currHighRsi
    prevHighMacd  := currHighMacd
    prevHighWpr   := currHighWpr

// =============================================================================
// 4. RISK MANAGEMENT & POSITION SIZE CALCULATOR
// =============================================================================
float pointValue = syminfo.pointvalue > 0 ? syminfo.pointvalue : 1.0
float riskAmount = accountCapital * (riskPercent / 100.0)

calcLotSize(float slDistance) =>
    float calculatedQty = 0.0
    if slDistance > 0 and pointValue > 0
        float rawUnits = riskAmount / (slDistance * pointValue)
        if capAtCapital and close > 0
            float maxCashUnits = accountCapital / close
            rawUnits := math.min(rawUnits, maxCashUnits)
        calculatedQty := math.max(rawUnits, syminfo.mintick)
    calculatedQty

// Active Trade Tracking
var string activeDirection = "NONE"
var float  activeEntry     = na
var float  activeSL        = na
var float  activeTP        = na
var float  activeLots      = na
var string activeOscs      = ""

if bullishDivergence
    float slDist = atrValue * atrSlMult
    float tpDist = atrValue * atrTpMult
    activeDirection := "LONG"
    activeEntry     := close
    activeSL        := close - slDist
    activeTP        := close + tpDist
    activeLots      := calcLotSize(slDist)
    activeOscs      := bullConfDetails

if bearishDivergence
    float slDist = atrValue * atrSlMult
    float tpDist = atrValue * atrTpMult
    activeDirection := "SHORT"
    activeEntry     := close
    activeSL        := close + slDist
    activeTP        := close - tpDist
    activeLots      := calcLotSize(slDist)
    activeOscs      := bearConfDetails

// Track whether target or stop was hit on subsequent bars after signal
if not bullishDivergence and not bearishDivergence
    if activeDirection == "LONG"
        if high >= activeTP or low <= activeSL
            activeDirection := "RESOLVED"
    else if activeDirection == "SHORT"
        if low <= activeTP or high >= activeSL
            activeDirection := "RESOLVED"

// =============================================================================
// 5. VISUAL PLOTS, LINES, LABELS & RAYS
// =============================================================================

// Plot Pivot Swings
plotshape(not na(ph), title="Pivot High Marker", style=shape.triangledown, location=location.abovebar, 
          offset=-pivotRight, color=color.new(color.orange, 40), size=size.tiny)
plotshape(not na(pl), title="Pivot Low Marker", style=shape.triangleup, location=location.belowbar, 
          offset=-pivotRight, color=color.new(color.teal, 40), size=size.tiny)

// Detailed Signal Labels
if showDetailLabels
    if bullishDivergence
        float slDist = atrValue * atrSlMult
        float tpDist = atrValue * atrTpMult
        float lots   = calcLotSize(slDist)
        string txt   = "▲ BUY SIGNAL (BULL DIV)" +
                       "\nOscillators (" + str.tostring(bullConfCount) + "/3): " + bullConfDetails +
                       "\nEntry: " + str.tostring(close, "#.##") +
                       "\nSL: " + str.tostring(close - slDist, "#.##") + " (-" + str.tostring(slDist, "#.##") + ")" +
                       "\nTP: " + str.tostring(close + tpDist, "#.##") + " (+" + str.tostring(tpDist, "#.##") + ")" +
                       "\nRec. Size: " + str.tostring(lots, "#.##") + " units"
        label.new(x=bar_index, y=low, text=txt, yloc=yloc.belowbar, color=colBull, 
                  textcolor=color.black, style=label.style_label_up, size=size.normal)

    if bearishDivergence
        float slDist = atrValue * atrSlMult
        float tpDist = atrValue * atrTpMult
        float lots   = calcLotSize(slDist)
        string txt   = "▼ SELL SIGNAL (BEAR DIV)" +
                       "\nOscillators (" + str.tostring(bearConfCount) + "/3): " + bearConfDetails +
                       "\nEntry: " + str.tostring(close, "#.##") +
                       "\nSL: " + str.tostring(close + slDist, "#.##") + " (+" + str.tostring(slDist, "#.##") + ")" +
                       "\nTP: " + str.tostring(close - tpDist, "#.##") + " (-" + str.tostring(tpDist, "#.##") + ")" +
                       "\nRec. Size: " + str.tostring(lots, "#.##") + " units"
        label.new(x=bar_index, y=high, text=txt, yloc=yloc.abovebar, color=colBear, 
                  textcolor=color.white, style=label.style_label_down, size=size.normal)

// Draw Divergence Trendlines between confirmed pivots
if showDivLines
    if bullishDivergence and not na(divStartBar) and not na(divEndBar)
        line.new(x1=divStartBar, y1=divStartPrice, x2=divEndBar, y2=divEndPrice, xloc=xloc.bar_index, 
                 color=colBull, width=2, style=line.style_solid)
    if bearishDivergence and not na(divStartBar) and not na(divEndBar)
        line.new(x1=divStartBar, y1=divStartPrice, x2=divEndBar, y2=divEndPrice, xloc=xloc.bar_index, 
                 color=colBear, width=2, style=line.style_solid)

// Active TP / SL / Entry Dynamic Lines
bool isTradeActive = (activeDirection == "LONG" or activeDirection == "SHORT")
plot(showTargetRays and isTradeActive ? activeTP : na, title="Active Take Profit", color=color.green, style=plot.style_linebr, linewidth=2)
plot(showTargetRays and isTradeActive ? activeEntry : na, title="Active Entry Price", color=color.gray, style=plot.style_linebr, linewidth=1)
plot(showTargetRays and isTradeActive ? activeSL : na, title="Active Stop Loss", color=color.red, style=plot.style_linebr, linewidth=2)

// =============================================================================
// 6. HISTORICAL PERFORMANCE SIMULATOR (WINDOW-BASED)
// =============================================================================
// Evaluates simulated trade outcomes within the specified date filter
// to calculate Win Rate, Max Drawdown, and Peak/Max Profit for the HUD.

var int   statTotalTrades  = 0
var int   statWins         = 0
var int   statLosses       = 0
var float statNetProfit    = 0.0
var float statPeakProfit   = 0.0
var float statPeakEquity   = accountCapital
var float statMaxDrawdown  = 0.0

var string simDir     = "NONE"
var float  simEntryPx = na
var float  simSLPx    = na
var float  simTPPx    = na
var float  simSize    = na

bool inPerfWindow = not useDateFilter or (time >= startDate and time <= endDate)

// Evaluate open simulated position
if simDir == "LONG"
    bool hitTP = high >= simTPPx
    bool hitSL = low <= simSLPx
    if hitTP or hitSL
        bool isWin = hitTP and not hitSL
        float exitPx = isWin ? simTPPx : simSLPx
        float pnl = (exitPx - simEntryPx) * simSize * pointValue
        statTotalTrades += 1
        if isWin
            statWins += 1
        else
            statLosses += 1
        statNetProfit += pnl
        statPeakProfit := math.max(statPeakProfit, statNetProfit)
        float curEq = accountCapital + statNetProfit
        statPeakEquity := math.max(statPeakEquity, curEq)
        statMaxDrawdown := math.max(statMaxDrawdown, statPeakEquity - curEq)
        simDir := "NONE"

else if simDir == "SHORT"
    bool hitTP = low <= simTPPx
    bool hitSL = high >= simSLPx
    if hitTP or hitSL
        bool isWin = hitTP and not hitSL
        float exitPx = isWin ? simTPPx : simSLPx
        float pnl = (simEntryPx - exitPx) * simSize * pointValue
        statTotalTrades += 1
        if isWin
            statWins += 1
        else
            statLosses += 1
        statNetProfit += pnl
        statPeakProfit := math.max(statPeakProfit, statNetProfit)
        float curEq = accountCapital + statNetProfit
        statPeakEquity := math.max(statPeakEquity, curEq)
        statMaxDrawdown := math.max(statMaxDrawdown, statPeakEquity - curEq)
        simDir := "NONE"

// Check new entries inside the date window
if inPerfWindow
    if bullishDivergence
        float slDist = atrValue * atrSlMult
        float tpDist = atrValue * atrTpMult
        float units  = calcLotSize(slDist)
        if simDir == "SHORT"
            float pnl = (simEntryPx - close) * simSize * pointValue
            statTotalTrades += 1
            if pnl > 0
                statWins += 1
            else
                statLosses += 1
            statNetProfit += pnl
            statPeakProfit := math.max(statPeakProfit, statNetProfit)
            float curEq = accountCapital + statNetProfit
            statPeakEquity := math.max(statPeakEquity, curEq)
            statMaxDrawdown := math.max(statMaxDrawdown, statPeakEquity - curEq)
            
        simDir     := "LONG"
        simEntryPx := close
        simSLPx    := close - slDist
        simTPPx    := close + tpDist
        simSize    := units

    else if bearishDivergence
        float slDist = atrValue * atrSlMult
        float tpDist = atrValue * atrTpMult
        float units  = calcLotSize(slDist)
        if simDir == "LONG"
            float pnl = (close - simEntryPx) * simSize * pointValue
            statTotalTrades += 1
            if pnl > 0
                statWins += 1
            else
                statLosses += 1
            statNetProfit += pnl
            statPeakProfit := math.max(statPeakProfit, statNetProfit)
            float curEq = accountCapital + statNetProfit
            statPeakEquity := math.max(statPeakEquity, curEq)
            statMaxDrawdown := math.max(statMaxDrawdown, statPeakEquity - curEq)
            
        simDir     := "SHORT"
        simEntryPx := close
        simSLPx    := close + slDist
        simTPPx    := close - tpDist
        simSize    := units

// =============================================================================
// 7. REAL-TIME HUD DASHBOARD
// =============================================================================
var table hudTable = table.new(position.top_right, 2, 13, 
                               bgcolor=color.new(color.black, 15), 
                               border_color=color.new(color.gray, 60), 
                               border_width=1)

if showDashboard and barstate.islast
    // Header
    table.cell(hudTable, 0, 0, "TRI-MOMENTUM SUITE", bgcolor=color.new(color.blue, 40), text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 0, "LIVE HUD METRIC", bgcolor=color.new(color.blue, 40), text_color=color.white, text_size=size.small)

    // Current Oscillator Values
    color rsiCol = rsiValue > 70 ? color.red : (rsiValue < 30 ? color.green : color.silver)
    table.cell(hudTable, 0, 1, "RSI (14)", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 1, str.tostring(rsiValue, "#.##"), text_color=rsiCol, text_size=size.small)

    color macdCol = histLine > 0 ? color.green : color.red
    table.cell(hudTable, 0, 2, "MACD Hist", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 2, str.tostring(histLine, "#.####"), text_color=macdCol, text_size=size.small)

    color wprCol = wprValue > -20 ? color.red : (wprValue < -80 ? color.green : color.silver)
    table.cell(hudTable, 0, 3, "Williams %R", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 3, str.tostring(wprValue, "#.##"), text_color=wprCol, text_size=size.small)

    // Confirmation Setting
    table.cell(hudTable, 0, 4, "Min Confirm Count", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 4, str.tostring(minConfirm) + " / 3 Oscillators", text_color=color.yellow, text_size=size.small)

    // ATR
    table.cell(hudTable, 0, 5, "ATR (" + str.tostring(atrLength) + ")", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 5, str.tostring(atrValue, "#.##"), text_color=color.aqua, text_size=size.small)

    // --- Performance Statistics in Selected Date Window ---
    float winRate = statTotalTrades > 0 ? (statWins / statTotalTrades) * 100.0 : 0.0
    float ddPct   = statPeakEquity > 0 ? (statMaxDrawdown / statPeakEquity) * 100.0 : 0.0
    float netPct  = (statNetProfit / accountCapital) * 100.0
    float peakPct = (statPeakProfit / accountCapital) * 100.0

    table.cell(hudTable, 0, 6, "Total Trades", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 6, str.tostring(statTotalTrades) + " (" + str.tostring(statWins) + "W / " + str.tostring(statLosses) + "L)", text_color=color.white, text_size=size.small)

    color wrCol = winRate >= 50.0 ? color.green : color.orange
    table.cell(hudTable, 0, 7, "Win Rate", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 7, str.tostring(winRate, "#.#") + "%", text_color=wrCol, text_size=size.small)

    color netCol = statNetProfit >= 0 ? color.green : color.red
    table.cell(hudTable, 0, 8, "Net Profit", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 8, "$" + str.tostring(statNetProfit, "#.##") + " (" + (statNetProfit >= 0 ? "+" : "") + str.tostring(netPct, "#.#") + "%)", text_color=netCol, text_size=size.small)

    table.cell(hudTable, 0, 9, "Max Profit (Peak)", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 9, "$" + str.tostring(statPeakProfit, "#.##") + " (+" + str.tostring(peakPct, "#.#") + "%)", text_color=color.green, text_size=size.small)

    table.cell(hudTable, 0, 10, "Max Drawdown", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 10, "-$" + str.tostring(statMaxDrawdown, "#.##") + " (-" + str.tostring(ddPct, "#.#") + "%)", text_color=color.red, text_size=size.small)

    // Last Signal State
    string statusText = activeDirection == "LONG" ? "ACTIVE LONG" : (activeDirection == "SHORT" ? "ACTIVE SHORT" : "NO ACTIVE SIGNAL")
    color  statusCol  = activeDirection == "LONG" ? color.green : (activeDirection == "SHORT" ? color.red : color.gray)
    table.cell(hudTable, 0, 11, "Signal Status", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 11, statusText, text_color=statusCol, text_size=size.small)

    string winText = useDateFilter ? "Custom Range" : "All Available"
    table.cell(hudTable, 0, 12, "Stats Window", text_color=color.gray, text_size=size.tiny)
    table.cell(hudTable, 1, 12, winText, text_color=color.gray, text_size=size.tiny)

// =============================================================================
// 7. ALERTS & NOTIFICATIONS
// =============================================================================

// Dedicated alertcondition for TradingView Alert Creation Menu
alertcondition(bullishDivergence, title="Bullish Divergence (Buy Signal)", 
               message="Bullish Divergence Confirmed! Symbol: {{ticker}}, Price: {{close}}, Check chart for dynamic TP/SL levels.")

alertcondition(bearishDivergence, title="Bearish Divergence (Sell Signal)", 
               message="Bearish Divergence Confirmed! Symbol: {{ticker}}, Price: {{close}}, Check chart for dynamic TP/SL levels.")

// Real-time alert() trigger with dynamic parameter payload
if bullishDivergence
    float slDist = atrValue * atrSlMult
    float tpDist = atrValue * atrTpMult
    float lots   = calcLotSize(slDist)
    alert("BULLISH DIVERGENCE (BUY) on " + syminfo.ticker + 
          "\nPrice: " + str.tostring(close) + 
          "\nConfirmations: " + str.tostring(bullConfCount) + " (" + bullConfDetails + ")" + 
          "\nStop Loss: " + str.tostring(close - slDist, "#.##") + 
          "\nTake Profit: " + str.tostring(close + tpDist, "#.##") + 
          "\nRec. Lots: " + str.tostring(lots, "#.##"), alert.freq_once_per_bar_close)

if bearishDivergence
    float slDist = atrValue * atrSlMult
    float tpDist = atrValue * atrTpMult
    float lots   = calcLotSize(slDist)
    alert("BEARISH DIVERGENCE (SELL) on " + syminfo.ticker + 
          "\nPrice: " + str.tostring(close) + 
          "\nConfirmations: " + str.tostring(bearConfCount) + " (" + bearConfDetails + ")" + 
          "\nStop Loss: " + str.tostring(close + slDist, "#.##") + 
          "\nTake Profit: " + str.tostring(close - tpDist, "#.##") + 
          "\nRec. Lots: " + str.tostring(lots, "#.##"), alert.freq_once_per_bar_close)

// =============================================================================
// END OF INDICATOR SCRIPT
// =============================================================================
````
