# Al Brooks H2/L2 MTF Pro Engine

- url: https://www.tradingview.com/script/W75pyN7b-Al-Brooks-H2-L2-MTF-Pro-Engine/
- type: indicator
- pine_id: PUB;9be98e3511b7448a80726763b1bf582d
- version: 1.0

## Description

The Al Brooks H2/L2 MTF Pro Engine is an institutional price-action indicator designed to automate the visual tracking of two-legged trend pullbacks. Instead of cluttering your chart with lagging oscillators, it focuses entirely on raw candlestick geometry, market structure traps, and higher-timeframe trend alignment.
Here is a comprehensive breakdown of how the engine operates underneath the hood and exactly how to integrate it into your daily execution workflow.
Core Functionality: The Engineering
The script acts as a strict mathematical filter, requiring price action to pass through five distinct operational "gates" before printing an execution signal on your chart.
1. The Two-Legged Tracking Loop
The market moves in structural waves. During a pullback against a dominant trend, the first attempt by counter-trend traders to push the market back in the original direction is called a High 1 (H1) or Low 1 (L1). Algorithms and institutional players frequently trap these early entrants.
The script silently logs the H1/L1, waits for a failure or pause, and only triggers a signal when a High 2 (H2) or Low 2 (L2) forms. This indicates that counter-trend traders are covering their positions and the dominant institutional trend is resuming.
2. The Non-Repainting MTF Filter
The script runs an internal dual-engine check. While tracking the microscopic price action on your execution chart (e.g., the 5-minute), it simultaneously watches a designated higher timeframe (the 15-minute by default).
It will completely suppress 5m H2 Buy signals if the 15m candle is trading below its own 20 EMA.
It uses secure, historical index offsets to ensure that historical signals on your chart never shift, vanish, or "repaint" after the bar closes.
3. Structural Reset Logic
To prevent false signals during choppy, directionless consolidation, the counting engine automatically flushes its memory cache back to zero if:
Price cleanly crosses to the wrong side of the 5-minute 20 EMA.
Price prints a brand-new, structural 20-bar macro high or low, signaling that a completely new trend leg has begun.
4. The Al Brooks "Trend Bar" Mandate
Not all breakout bars are created equal. The engine analyzes the internal construction of the trigger candle. For an H2 Buy to be valid, the candle must close in the top 33% of its total high-to-low range. For an L2 Sell, it must close in the bottom 33%. This ensures you only enter when real, intraday momentum is actively defending the moving average.
📊 Reading the Chart Visuals
When the engine identifies a verified setup, it cleans up your visual space by displaying information in three distinct layers:
The Live Dashboard (Top Right): Displays the current internal leg state of the market in real-time ("Reset", "Waiting H2", etc.) alongside a dynamic macro trend status flag.
The Trigger Icon: Plots a sharp, small green or red triangle directly at the bar location, keeping your 5-minute candles completely scannable.
The Risk Projections: Instantly projects three colored lines forward for 5 bars: a dashed blue entry line (1 tick above/below the signal bar), a solid red stop-loss floor (1 tick outside the signal bar's extreme), and a solid green target line mathematically set to a precise 1:2 risk-to-reward ratio.
⚡ How to Make Use of It in Real-Time
To maximize this script alongside your core asset watchlists (SPY, QQQ, and mega-caps), execute your morning preparation using this step-by-step framework:
Step 1: The Morning Filter
Let the opening bell ring at 09:30 AM CDT. Do not look for setups immediately. Let the market algorithms process opening order flows and flatten out early premium implied volatility (IV). Keep your eyes on the dashboard; you want to see a clear macro trend direction establish itself by 09:50 AM CDT.
Step 2: The Proximity Watch
Once a clear macro trend is confirmed by the dashboard, wait for the index to initiate a pullback. You are looking for a gentle drift back toward the teal 20 EMA line. The script will handle the micro counting for you as the candles form.
Step 3: Visual Risk Pre-Sizing
The exact moment a compact H2 or L2 label prints on a closing candle:
Freeze your chart analysis and look at the projected Blue and Red lines.
Measure the physical distance between them. If you are preparing an option contract execution inside ThinkOrSwim, that distance tells you your exact structural dollar risk.
If the distance is wider than normal due to a large signal candle, immediately downsize your contract position sizing to perfectly protect your daily loss threshold.
Step 4: Bracket Order Execution
Do not enter at market price. Place a Buy Stop order on your broker platform exactly at the price level indicated by the blue dashed line.
If the next candle immediately breaks that high, you are automatically swept into the trade with momentum.
If price turns around instead and falls, your entry order is never triggered, completely protecting your capital from an unconfirmed trap.
Once filled, immediately attach your OCO bracket matching the red stop and green target prices projected on your screen.

## Source Code

````pine
//@version=6
indicator("Al Brooks H2/L2 MTF Pro Engine", overlay=true, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. INPUTS & RISK MANAGEMENT PARAMETERS
// ==========================================
emaLen = input.int(20, title="EMA Length", group="Core Trend Setup")
rrRatio = input.float(2.0, title="Risk-to-Reward Ratio", group="Risk Management")
showDashboard = input.bool(true, title="Show Live Counting Dashboard", group="Visuals")

// Multi-Timeframe Inputs
useMtfFilter = input.bool(true, title="Enable Higher Timeframe Filter", group="MTF Trend Filter")
htfResolution = input.timeframe("15", title="Higher Timeframe Resolution", group="MTF Trend Filter")

// Color Themes
colorBull = color.green
colorBear = color.red
colorEma = color.teal

// Lower Timeframe (Current) Indicator
ema20 = ta.ema(close, emaLen)
plot(ema20, color=colorEma, title="5m 20 EMA", linewidth=2)

// ==========================================
// 2. SECURE MULTI-TIMEFRAME DATA FETCH (NON-REPAINTING)
// ==========================================
htfEmaExpression = ta.ema(close, emaLen)

// Fetching historical index [1] with lookahead disabled protects chart integrity
htfClose = request.security(syminfo.tickerid, htfResolution, close[1], barmerge.gaps_off, barmerge.lookahead_off)
htfEma = request.security(syminfo.tickerid, htfResolution, htfEmaExpression[1], barmerge.gaps_off, barmerge.lookahead_off)

htfBullish = htfClose > htfEma
htfBearish = htfClose < htfEma

// ==========================================
// 3. REFINED BULLISH COUNTING (H1/H2)
// ==========================================
isInsideBar = high <= high[1] and low >= low[1]
highestHigh20 = ta.highest(high, 20)
lowestLow20 = ta.lowest(low, 20)

var int hCount = 0
var bool waitingForH2 = false

if close < ema20 or high == highestHigh20
    hCount := 0
    waitingForH2 := false

h2_triggered = false

if close > ema20 and not isInsideBar
    if high > high[1]
        if hCount == 0
            hCount := 1
            waitingForH2 := false
        else if hCount == 1 and waitingForH2
            hCount := 2
            h2_triggered := true
            waitingForH2 := false 
    else if high < high[1] and hCount == 1
        waitingForH2 := true

// ==========================================
// 4. REFINED BEARISH COUNTING (L1/L2)
// ==========================================
var int lCount = 0
var bool waitingForL2 = false

if close > ema20 or low == lowestLow20
    lCount := 0
    waitingForL2 := false

l2_triggered = false

if close < ema20 and not isInsideBar
    if low < low[1]
        if lCount == 0
            lCount := 1
            waitingForL2 := false
        else if lCount == 1 and waitingForL2
            lCount := 2
            l2_triggered := true
            waitingForL2 := false
    else if low > low[1] and lCount == 1
        waitingForL2 := true

// ==========================================
// 5. PRICE ACTION & MTF TREND FILTERS
// ==========================================
barRange = high - low
isStrongBull = barRange > 0 and (close - low) / barRange >= 0.66
isStrongBear = barRange > 0 and (high - close) / barRange >= 0.66

// MTF Conditional Pass Gates
mtfBuyPass = not useMtfFilter or htfBullish
mtfSellPass = not useMtfFilter or htfBearish

validH2 = h2_triggered and isStrongBull and low <= ema20 * 1.003 and mtfBuyPass
validL2 = l2_triggered and isStrongBear and high >= ema20 * 0.997 and mtfSellPass

// ==========================================
// 6. DYNAMIC RISK TARGET PROJECTIONS
// ==========================================
var line tradeEntry = na
var line tradeStop = na
var line tradeTarget = na

if validH2
    line.delete(tradeEntry)
    line.delete(tradeStop)
    line.delete(tradeTarget)
    
    entryPrice = high + syminfo.mintick
    stopPrice = low - syminfo.mintick
    riskDist = entryPrice - stopPrice
    targetPrice = entryPrice + (riskDist * rrRatio)
    
    tradeEntry := line.new(bar_index, entryPrice, bar_index + 5, entryPrice, color=color.blue, width=2, style=line.style_dashed)
    tradeStop := line.new(bar_index, stopPrice, bar_index + 5, stopPrice, color=colorBear, width=2)
    tradeTarget := line.new(bar_index, targetPrice, bar_index + 5, targetPrice, color=colorBull, width=2)

if validL2
    line.delete(tradeEntry)
    line.delete(tradeStop)
    line.delete(tradeTarget)
    
    entryPrice = low - syminfo.mintick
    stopPrice = high + syminfo.mintick
    riskDist = stopPrice - entryPrice
    targetPrice = entryPrice - (riskDist * rrRatio)
    
    tradeEntry := line.new(bar_index, entryPrice, bar_index + 5, entryPrice, color=color.blue, width=2, style=line.style_dashed)
    tradeStop := line.new(bar_index, stopPrice, bar_index + 5, stopPrice, color=colorBear, width=2)
    tradeTarget := line.new(bar_index, targetPrice, bar_index + 5, targetPrice, color=colorBull, width=2)

// Compact Physical Signals
plotshape(validH2, title="H2 Long", style=shape.triangleup, location=location.belowbar, color=colorBull, textcolor=colorBull, size=size.small, text="H2")
plotshape(validL2, title="L2 Short", style=shape.triangledown, location=location.abovebar, color=colorBear, textcolor=colorBear, size=size.small, text="L2")

// ==========================================
// 7. EXPANDED PERFORMANCE DASHBOARD
// ==========================================
var table dash = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)
if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Bull Leg State", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, hCount == 0 ? "Reset" : (waitingForH2 ? "H1 (Wait H2)" : "H2 Actv"), bgcolor=hCount == 1 ? color.orange : (hCount == 2 ? colorBull : color.gray), text_color=color.white, text_size=size.small)
    
    table.cell(dash, 0, 1, "Bear Leg State", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, lCount == 0 ? "Reset" : (waitingForL2 ? "L1 (Wait L2)" : "L2 Actv"), bgcolor=lCount == 1 ? color.orange : (lCount == 2 ? colorBear : color.gray), text_color=color.white, text_size=size.small)
    
    table.cell(dash, 0, 2, "Macro Trend (" + htfResolution + ")", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, useMtfFilter ? (htfBullish ? "BULLISH" : "BEARISH") : "DISABLED", bgcolor=useMtfFilter ? (htfBullish ? colorBull : colorBear) : color.gray, text_color=color.white, text_size=size.small)
````
