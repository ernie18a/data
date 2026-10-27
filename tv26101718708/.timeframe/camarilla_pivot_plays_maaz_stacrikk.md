# Camarilla Pivot Plays - Maaz

- url: https://www.tradingview.com/script/STaCrIKK-Camarilla-Pivot-Plays-Maaz/
- type: indicator
- pine_id: PUB;03fcd2a198d14f819c3741fb49f5550b
- version: 5.0

## Description

= Camarilla Pivot Plays - Maaz (Advanced Framework Engine) =

Camarilla Pivot Plays - Maaz is an institutional-grade quantitative workspace engine engineered for professional intraday equity, index, and futures traders. Designed to strip out raw market noise and address the mathematical flaws of standard retail pivot scripts, this system delivers a highly precise view of daily support, resistance, and expansion structures based on classic institutional order-flow frameworks.

== 🚀 1. Core Innovations & Multi-Session Engine ==

Standard pivot indicators calculate historical lines purely off daily bars, blindly mixing Regular Trading Hours (RTH) and Extended Trading Hours (ETH) data. This creates misaligned lines that do not match professional order-flow layouts.

This indicator resolves that issue by deploying a customized Multi-Session Snapshot Engine. By calculating historical session boundaries and tracking extended-hours shifts, the indicator plots clean, un-cluttered stepline levels that anchor to the exact structural bars seen on standalone institutional platforms:

CP (Central Pivot): The dynamic directional anchor boundary for the trading day.

R3 / S3: The dynamic range boundaries defining institutional value and traversal mean-reversion loops.

R4 / S4: The critical breakout launchpads where institutional short squeezes or liquidations accelerate.

R6 / S6: Ultimate daily mathematical expansion target projections.

== 📊 2. The Integrated Workspace HUD Panel ==

To bypass standard table clipping errors, this script embeds a stacked, comprehensive workspace dashboard in the top-right corner of your workspace screen. This HUD continuously reads live price metadata to evaluate and display:

Strategic Profile Matrix: Tracks your active framework mode (Alpha Momentum, Tactical Delta, Direct Market DME, or Legacy Frame).

Volatility Coiling Status: Classifies the current pivot width as Wide or Narrow to instantly dictate whether you should fade the range or play a trend breakout.

Suggested Play Actions: Prints dynamic tactical suggestions or shifts to bright yellow execution flags when levels are actively breached.

Pre-Calculated Target Prices: Explicitly projects your Planned Entry, Planned Stop Loss, and Planned Target Exit levels inside the table before a trade even triggers.

== 🔬 3. Granular Metric Guide ==

=== A. Relative Volume (RVOL) — The Breakout Validation Filter ===
RVOL mathematically divides the current session's volume at the exact live bar index by a rolling 20-period simple moving average of volume.

0.00x – 0.79x (Illiquid / Sub-Normal): STRICT HOLD. Institutional desks are absent. Breakouts crossing R4 or S4 inside this range are highly prone to immediate failure.

0.80x – 1.49x (Standard Consolidation): Healthy volume for mean-reversion traversals fading R3 and S3.

1.50x – 2.99x (Institutional Spark / True Breakout): CONFIRMED EXECUTION WINDOW. Volume is at least 150% higher than historical normal averages at this specific time. Big blocks are aggressively absorbing supply and pushing price out of consolidation.

3.00x+ (Climax Volatility): Hyper-extended volume spikes. Highly favorable for rapid target completions, but entering right at the print risks buying the absolute peak of a volume exhaustion spike.

=== B. Institutional Net Flow Index — The Order Flow Sentiment Tape ===
Tracks the volume-weighted locations of candle closes relative to their total intraday high/low ranges to monitor net structural capital flows in real time.

+70.0% to +100.0% (Aggressive Buying / Short Squeeze): Extreme institutional demand. Do not attempt to short or fade resistance levels under any circumstances.

+15.1% to +69.9% (Steady Capital Accumulation): Supportive environment for buying pullbacks or taking upward R4 breakout trades.

-15.0% to +15.0% (Equilibrium / Chop Zone): Total structural balance. Order flow is clean on both sides. Ideal for Wide Pivot Traversal Plays.

-15.1% to -69.9% (Steady Capital Distribution): Institutions are steadily unloading size. Rallies are being met with heavy selling overhead.

-70.0% to -100.0% (Aggressive Distribution / Capitulation): Intense liquidation pressure. Do not attempt to catch a falling knife or buy support.

== 🛠️ 4. User Inputs & Variable Profiles ==

Platform Profile Presets: Select an innovative model profile to automatically override calculation parameters and match specific platform emulations (Alpha Momentum, Tactical Delta, Direct Market DME, Legacy Frame).

Risk-to-Reward Ratio (R:R): Allows complete control over your risk multiples. The HUD automatically updates stop loss and take-profit pricing fields based on the selected parameter ratio.

Execution Filters: Toggle requirements for high-volume breakouts, filter out sub-threshold volatility noise, and configure custom ATR target verification lengths.

== 💻 5. Technical Source Code Blueprint & Implementation ==

The architecture of Camarilla Pivot Plays - Maaz is engineered utilizing Pine Script v6. Below is a highly annotated structural blueprint explaining the execution loops, session snapshot tracking systems, and calculations used in the code matrix:

Pine Script
// --- Lookback Range Capture Functions ---
getHighestSince(bool sinceCondition, int offset) =>  
    ta.highest(high, nz(ta.barssince(sinceCondition)) + 1)[offset]
    
getLowestSince(bool sinceCondition, int offset) =>         
    ta.lowest(low, nz(ta.barssince(sinceCondition)) + 1)[offset]

// --- Custom Volatility Capture Math ---
float yS3           = snapshotVal(s3, preStartBar)
float yR3           = snapshotVal(r3, preStartBar)
float currentRange3 = r3 - s3
float yRange3       = yR3 - yS3

// --- Dynamic Width Engine Matrix Assignment ---
string pivotWidthClass = "Similar pivots"
if currentRange3 > yRange3 * (1 + widthThreshold / 100)
    pivotWidthClass := "Wide pivots"
else if currentRange3 < yRange3 * (1 - widthThreshold / 100)
    pivotWidthClass := "Narrow pivots"

// --- Asymmetric Risk Mitigation Calculations ---
getStopLoss(float pivotLevel, float target, float rrRatio) =>
    (pivotLevel * (rrRatio + 1.0) + target * (0.5 - 1.0)) / (rrRatio + 0.5)
== 📜 6. Disclaimer & Terms of Use ==

This script is published for educational and analytical purposes only. Past performance does not guarantee future market results. Backtest parameters thoroughly and manage your risk according to your own personalized capital rules before deploying live market execution.

## Source Code

````pine
//@version=6
indicator("Camarilla pivot play (Maaz)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- 1. Structure Settings, Risk Inputs, & Innovative Presets ---
groupDisplay          = "Display Settings"
showHUD               = input.bool(true, title="Show Quantitative HUD?", group=groupDisplay)
extendLines           = input.bool(false, title="Extend Lines Right?", group=groupDisplay)

// Exact Premium Color Palette Sync
r6Color               = input.color(color.rgb(151, 50, 50), title="R6 Color", group=groupDisplay)
r4Color               = input.color(color.rgb(151, 50, 50), title="R4 Color", group=groupDisplay)
r3Color               = input.color(color.rgb(248, 130, 130), title="R3 Color", group=groupDisplay)
cpColor               = input.color(color.rgb(20, 75, 121), title="CP Color", group=groupDisplay)
s3Color               = input.color(color.rgb(108, 175, 147), title="S3 Color", group=groupDisplay)
s4Color               = input.color(color.rgb(43, 100, 45), title="S4 Color", group=groupDisplay)
s6Color               = input.color(color.rgb(43, 100, 45), title="S6 Color", group=groupDisplay)

groupRisk             = "Risk Management & Framework Presets"
presetSelection       = input.string("Custom Engine", title="Strategic Profile Matrix", options=["Custom Engine", "Alpha Momentum", "Tactical Delta", "Direct Market (DME)", "Legacy Frame"], group=groupRisk)
manualRR              = input.float(4.0, title="Custom Target Risk-to-Reward (R:R)", minval=1.0, maxval=10.0, step=0.1, group=groupRisk)

groupFilters          = "Execution & Context Filters"
useVolFilter          = input.bool(true, title="Require High Vol Breakout (RVOL)?", group=groupFilters)
rvolThreshold         = input.float(1.5, title="RVOL Multiplier Threshold", minval=1.0, maxval=5.0, step=0.1, group=groupFilters)
atrLen                = input.int(14, title="ATR Target Verification Length", group=groupFilters)

// --- 2. Innovative Preset Translation Matrix ---
string activePresetName = presetSelection
float appliedRR         = manualRR
float widthThreshold    = 0.0
string calcModeOverride = "Auto"

if presetSelection == "Alpha Momentum"
    appliedRR         := 4.0
    widthThreshold    := 0.0
    calcModeOverride  := "Force RTH"
else if presetSelection == "Tactical Delta"
    appliedRR         := 3.0
    widthThreshold    := 10.0
    calcModeOverride  := "Auto"
else if presetSelection == "Direct Market (DME)"
    appliedRR         := 4.0
    widthThreshold    := 5.0
    calcModeOverride  := "Force ETH"
else if presetSelection == "Legacy Frame"
    appliedRR         := 4.0
    widthThreshold    := 0.0
    calcModeOverride  := "Force ETH"

// --- 3. Robust Multi-Session Engine Helpers & Core Calculations ---
getHighestSince(bool sinceCondition, int offset) =>  
    ta.highest(high, nz(ta.barssince(sinceCondition)) + 1)[offset]
    
getLowestSince(bool sinceCondition, int offset) =>         
    ta.lowest(low, nz(ta.barssince(sinceCondition)) + 1)[offset]

// FIXED: Moved up from bottom to guarantee structural declaration sequence is verified before conditional loops execute
getStopLoss(float pivotLevel, float target, float rrRatio) =>
    (pivotLevel * (rrRatio + 1.0) + target * (0.5 - 1.0)) / (rrRatio + 0.5)

f_pastData(bool HLCondition, bool updateCondition, bool shiftBackCondition) =>
    var float close0 = na, var float close1 = na, var float close2 = na
    var float high0 = na, var float low0 = na, var float high1 = na, var float low1 = na
    lastHigh = getHighestSince(HLCondition, 1)
    lastLow = getLowestSince(HLCondition, 1)
    if updateCondition
        close2 := close1
        close1 := close0
        close0 := close[1]
        high1 := high0        
        high0 := lastHigh        
        low1 := low0
        low0 := lastLow
    
    if shiftBackCondition
        [close1, close2, high1, low1]
    else
        [close0, close1, high0, low0]

f_currentData(bool HLCondition, bool updateCondition) =>
    var float preHigh = na, var float preLow = na
    lastHigh = getHighestSince(HLCondition, 0)
    lastLow = getLowestSince(HLCondition, 0)    
    if updateCondition        
        preHigh := lastHigh
        preLow := lastLow    
    [preHigh, preLow]

f_HLData(bool HLCondition, bool updateCondition) =>    
    var float remHigh = na, var float remLow = na
    lastHigh = getHighestSince(HLCondition, 1)
    lastLow = getLowestSince(HLCondition, 1)
    if updateCondition        
        remHigh := lastHigh
        remLow := lastLow
    [remHigh, remLow]

snapshotVal(float value, bool updatePredicate) =>
    var float snapshotValue = na    
    if updatePredicate
        snapshotValue := value[1]
    snapshotValue

regStartBar  = session.isfirstbar_regular or bar_index == 0
preStartBar  = (session.ispremarket and session.isfirstbar) or (session.isfirstbar and session.isfirstbar_regular) or bar_index == 0
postStartBar = (session.ispostmarket and session.ismarket[1]) or (session.isfirstbar and session.ismarket[1]) or bar_index == 0
isPostmarket = session.ispostmarket

simple string ethTicker = ticker.modify(syminfo.main_tickerid, session.extended, adjustment.splits)
int resMultiplier = math.min(timeframe.multiplier, 30)
string resStr = str.tostring(resMultiplier)

[yRthClose, yyRthClose, yRthHigh, yRthLow] = request.security(ethTicker, resStr, f_pastData(regStartBar, postStartBar, isPostmarket))
[yEthClose, yyEthClose, yEthHigh, yEthLow] = request.security(ethTicker, resStr, f_pastData(preStartBar, preStartBar, false))
[preHigh, preLow]                           = request.security(ethTicker, resStr, f_currentData(preStartBar, session.ispremarket))
[yPostHigh, yPostLow]                       = request.security(ethTicker, resStr, f_HLData(postStartBar, preStartBar))
dayAtr                                      = request.security(syminfo.main_tickerid, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

bool useEthForCams = false
if calcModeOverride == "Force ETH"
    useEthForCams := true
else if calcModeOverride == "Force RTH"
    useEthForCams := false
else
    useEthForCams := (math.max(yRthHigh, yPostHigh, preHigh) - yRthHigh > dayAtr * 1.0 / 100) or (yRthLow - math.min(yRthLow, yPostLow, preLow) > dayAtr * 1.0 / 100)

float CP  = useEthForCams ? yEthClose : yRthClose
float tH  = useEthForCams ? yEthHigh  : yRthHigh
float tL  = useEthForCams ? useEthForCams[1] ? yEthLow : yRthLow : yRthLow

float range_hl = tH - tL
float r3       = CP + (range_hl * 1.1 / 4.0)
float r4       = CP + (range_hl * 1.1 / 2.0)
float r6       = tL != 0 ? (tH / tL) * CP : na
float s3       = CP - (range_hl * 1.1 / 4.0)
float s4       = CP - (range_hl * 1.1 / 2.0)
float s6       = CP - (r6 - CP)

isHigherRange = CP > (useEthForCams ? yyEthClose : yyRthClose)
isLowerRange  = CP < (useEthForCams ? yyEthClose : yyRthClose)
string marketContext = isHigherRange ? "Higher Range" : isLowerRange ? "Lower Range" : "Neutral"

float yS3           = snapshotVal(s3, preStartBar)
float yR3           = snapshotVal(r3, preStartBar)
float currentRange3 = r3 - s3
float yRange3       = yR3 - yS3

string pivotWidthClass = "Similar pivots"
if currentRange3 > yRange3 * (1 + widthThreshold / 100)
    pivotWidthClass := "Wide pivots"
else if currentRange3 < yRange3 * (1 - widthThreshold / 100)
    pivotWidthClass := "Narrow pivots"

// --- 4. Native Multi-Day Stepline Plotting ---
plot(r6, title="R6", color=r6Color, linewidth=1, style=plot.style_stepline)
plot(r4, title="R4", color=r4Color, linewidth=2, style=plot.style_stepline)
plot(r3, title="R3", color=r3Color, linewidth=2, style=plot.style_stepline)
plot(CP, title="CP", color=cpColor, linewidth=1, style=plot.style_stepline)
plot(s3, title="S3", color=s3Color, linewidth=2, style=plot.style_stepline)
plot(s4, title="S4", color=s4Color, linewidth=2, style=plot.style_stepline)
plot(s6, title="S6", color=s6Color, linewidth=1, style=plot.style_stepline)

// --- 5. Labels Engine for Real-Time Bar ---
var label lblR6 = na, var label lblR4 = na, var label lblR3 = na, var label lblCP = na
var label lblS3 = na, var label lblS4 = na, var label lblS6 = na

if barstate.islast
    label.delete(lblR6), label.delete(lblR4), label.delete(lblR3), label.delete(lblCP)
    label.delete(lblS3), label.delete(lblS4), label.delete(lblS6)
    int offsetCell = extendLines ? bar_index + 10 : bar_index + 2
    lblR6 := label.new(x=offsetCell, y=r6, text="R6", color=color.new(color.black, 100), textcolor=r6Color, style=label.style_label_left, size=size.small)
    lblR4 := label.new(x=offsetCell, y=r4, text="R4", color=color.new(color.black, 100), textcolor=r4Color, style=label.style_label_left, size=size.small)
    lblR3 := label.new(x=offsetCell, y=r3, text="R3", color=color.new(color.black, 100), textcolor=r3Color, style=label.style_label_left, size=size.small)
    lblCP := label.new(x=offsetCell, y=CP, text="CP", color=color.new(color.black, 100), textcolor=cpColor, style=label.style_label_left, size=size.small)
    lblS3 := label.new(x=offsetCell, y=s3, text="S3", color=color.new(color.black, 100), textcolor=s3Color, style=label.style_label_left, size=size.small)
    lblS4 := label.new(x=offsetCell, y=s4, text="S4", color=color.new(color.black, 100), textcolor=s4Color, style=label.style_label_left, size=size.small)
    lblS6 := label.new(x=offsetCell, y=s6, text="S6", color=color.new(color.black, 100), textcolor=s6Color, style=label.style_label_left, size=size.small)

// --- 6. Advanced Local Multi-Timeframe Analytical Engine ---
f_calculateMetrics() =>
    vMA = ta.sma(volume, 20)
    rawRVOL = vMA > 0 ? volume / vMA : 1.0
    cRange = high - low
    cLoc = cRange > 0 ? (close - low) / cRange : 0.5
    rawFlow = (cLoc - 0.5) * 200.0
    adjFlow = rawRVOL >= 1.5 ? rawFlow : rawFlow * (rawRVOL / 1.5)
    clippedFlow = math.max(-100.0, math.min(100.0, adjFlow))
    [rawRVOL, clippedFlow]

[localRVOL, localFlow] = f_calculateMetrics()
isHighVolume = (localRVOL >= rvolThreshold)

[mtf15_RVOL, mtf15_Flow] = request.security(syminfo.main_tickerid, "15", f_calculateMetrics(), lookahead = barmerge.lookahead_off)
[mtf60_RVOL, mtf60_Flow] = request.security(syminfo.main_tickerid, "60", f_calculateMetrics(), lookahead = barmerge.lookahead_off)

proxToR4 = close > 0 ? ((r4 - close) / close) * 100 : 0.0
proxToS4 = close > 0 ? ((close - s4) / close) * 100 : 0.0

// --- 7. Trade Triggers & Invalidation Logic ---
play_s3_reversal = ta.crossunder(low, s3) and close > s3
play_r3_reversal = ta.crossover(high, r3) and close < r3
play_r4_breakout = ta.crossover(close, r4) and (not useVolFilter or isHighVolume) and close > open
play_s4_breakout = ta.crossunder(close, s4) and (not useVolFilter or isHighVolume) and close < open

string playSuggestion = "Scan Mode (No Active Structure)"
string biasDirection   = "NEUTRAL"
float targetEntryPrice = na
float targetExitPrice  = na
float targetStopPrice  = na

if isHigherRange
    if pivotWidthClass == "Wide pivots"
        biasDirection   := "LONG"
        playSuggestion  := "Watch S3 Level for Mean-Reversion Traversal Long"
        targetEntryPrice := s3
        targetExitPrice  := r3
        targetStopPrice  := getStopLoss(s3, r3, appliedRR)
    else
        biasDirection   := "LONG"
        playSuggestion  := "Watch R4 Launchpad for Institutional Vol Breakout"
        targetEntryPrice := r4
        targetExitPrice  := r6
        targetStopPrice  := getStopLoss(r4, r6, appliedRR)
else if isLowerRange
    if pivotWidthClass == "Wide pivots"
        biasDirection   := "SHORT"
        playSuggestion  := "Watch R3 Level for Mean-Reversion Traversal Short"
        targetEntryPrice := r3
        targetExitPrice  := s3
        targetStopPrice  := getStopLoss(r3, s3, appliedRR)
    else
        biasDirection   := "SHORT"
        playSuggestion  := "Watch S4 Launchpad for Institutional Liquidation Down"
        targetEntryPrice := s4
        targetExitPrice  := s6
        targetStopPrice  := getStopLoss(s4, s6, appliedRR)

if play_s3_reversal
    playSuggestion := "TRIGGER CONFIRMED: Long Reversal Filled!"
if play_r3_reversal
    playSuggestion := "TRIGGER CONFIRMED: Short Reversal Filled!"
if play_r4_breakout
    playSuggestion := "TRIGGER CONFIRMED: Expansion Breakout Long Filled!"
if play_s4_breakout
    playSuggestion := "TRIGGER CONFIRMED: Liquidation Breakdown Short Filled!"

// Custom dynamic color assignment layer
color premiumSlate = color.rgb(40, 40, 40)

// --- 8. Workspace HUD Matrix Panel Layout ---
var table hudTable = table.new(position = position.top_right, columns = 2, rows = 13, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.gray)

if showHUD and barstate.islast
    table.cell(hudTable, 0, 0, "Camarilla pivot play (Maaz) HUD", text_color=color.white, text_size=size.small, bgcolor=color.new(color.rgb(20, 75, 121), 20))
    table.cell(hudTable, 1, 0, marketContext + " | " + pivotWidthClass + " (" + activePresetName + ")", text_color=color.white, text_size=size.small, bgcolor=color.new(color.rgb(20, 75, 121), 20))
    
    table.cell(hudTable, 0, 1, "Suggested Play Action", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 40))
    table.cell(hudTable, 1, 1, playSuggestion, text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 40))
    
    table.cell(hudTable, 0, 2, "Planned Entry Pivot Level", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 2, not na(targetEntryPrice) ? str.tostring(targetEntryPrice, "#.##") : "Scanning...", text_color=color.orange, text_size=size.small)
    
    table.cell(hudTable, 0, 3, "Planned Stop Loss Level", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 3, not na(targetStopPrice) ? str.tostring(targetStopPrice, "#.##") : "Scanning...", text_color=color.red, text_size=size.small)
    
    table.cell(hudTable, 0, 4, "Planned Target Exit Level", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 4, not na(targetExitPrice) ? str.tostring(targetExitPrice, "#.##") : "Scanning...", text_color=color.green, text_size=size.small)
    
    table.cell(hudTable, 0, 5, "Active Risk Profile Target (R:R)", text_color=color.white, text_size=size.small, bgcolor=color.new(premiumSlate, 50))
    table.cell(hudTable, 1, 5, str.tostring(appliedRR, "#.#") + " : 1 Target Bias", text_color=color.fuchsia, text_size=size.small, bgcolor=color.new(premiumSlate, 50))
    
    table.cell(hudTable, 0, 6, "Daily ATR Value", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 6, str.tostring(dayAtr, "#.##"), text_color=color.yellow, text_size=size.small)
    
    table.cell(hudTable, 0, 7, "Chart Relative Vol (" + timeframe.period + ")", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 7, str.tostring(localRVOL, "#.##") + "x", text_color=(isHighVolume ? color.orange : color.white), text_size=size.small)
    
    table.cell(hudTable, 0, 8, "Chart Net Flow Index (" + timeframe.period + ")", text_color=color.white, text_size=size.small)
    table.cell(hudTable, 1, 8, str.tostring(localFlow, "#.#") + "%", text_color=(localFlow > 20.0 ? color.green : localFlow < -20.0 ? color.red : color.white), text_size=size.small)
    
    table.cell(hudTable, 0, 9, "Institutional RVOL (15-Min)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(hudTable, 1, 9, str.tostring(mtf15_RVOL, "#.##") + "x", text_color=(mtf15_RVOL >= 1.5 ? color.orange : color.white), text_size=size.small, bgcolor=color.new(color.black, 40))
    
    table.cell(hudTable, 0, 10, "Institutional Flow (15-Min)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(hudTable, 1, 10, str.tostring(mtf15_Flow, "#.#") + "%", text_color=(mtf15_Flow > 20.0 ? color.green : mtf15_Flow < -20.0 ? color.red : color.white), text_size=size.small, bgcolor=color.new(color.black, 40))
    
    table.cell(hudTable, 0, 11, "Macro Whale RVOL (1-Hour)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 70))
    table.cell(hudTable, 1, 11, str.tostring(mtf60_RVOL, "#.##") + "x", text_color=(mtf60_RVOL >= 1.5 ? color.orange : color.white), text_size=size.small, bgcolor=color.new(color.navy, 70))
    
    table.cell(hudTable, 0, 12, "Macro Whale Flow (1-Hour)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 70))
    table.cell(hudTable, 1, 12, str.tostring(mtf60_Flow, "#.#") + "%", text_color=(mtf60_Flow > 30.0 ? color.green : mtf60_Flow < -30.0 ? color.red : color.white), text_size=size.small, bgcolor=color.new(color.navy, 70))

// --- 9. Alert Engine Channels ---
var int currentSessionStart = na
if timeframe.change("D")
    currentSessionStart := bar_index

string basicStats = " [RVOL: " + str.tostring(localRVOL, "#.##") + "x] [Flow: " + str.tostring(localFlow, "#.#") + "%]"
if play_s3_reversal and not na(currentSessionStart) and (bar_index >= currentSessionStart)
    alert("Pivot Plays LONG [S3 Reversal] " + syminfo.ticker + basicStats, alert.freq_once_per_bar)
if play_r3_reversal and not na(currentSessionStart) and (bar_index >= currentSessionStart)
    alert("Pivot Plays SHORT [R3 Reversal] " + syminfo.ticker + basicStats, alert.freq_once_per_bar)
if play_r4_breakout and not na(currentSessionStart) and (bar_index >= currentSessionStart)
    alert("Pivot Plays BREAKOUT LONG [R4 Confirmed] " + syminfo.ticker + basicStats, alert.freq_once_per_bar)
if play_s4_breakout and not na(currentSessionStart) and (bar_index >= currentSessionStart)
    alert("Pivot Plays BREAKOUT SHORT [S4 Confirmed] " + syminfo.ticker + basicStats, alert.freq_once_per_bar)

plotshape(play_s3_reversal and not na(currentSessionStart) and (bar_index >= currentSessionStart), title="S3 Reversal Trigger", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(play_r3_reversal and not na(currentSessionStart) and (bar_index >= currentSessionStart), title="R3 Reversal Trigger", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(play_r4_breakout and not na(currentSessionStart) and (bar_index >= currentSessionStart), title="R4 Confirmed Breakout", style=shape.arrowup, location=location.belowbar, color=color.maroon, size=size.small)
plotshape(play_s4_breakout and not na(currentSessionStart) and (bar_index >= currentSessionStart), title="S4 Confirmed Breakout", style=shape.arrowdown, location=location.abovebar, color=color.navy, size=size.small)
````
