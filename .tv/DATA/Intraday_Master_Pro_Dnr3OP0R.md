<!-- tradingview-pine-id: PUB;a78cae12f0fd481ab29cc953a55a7de8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Intraday Master Pro

Source: https://www.tradingview.com/script/Dnr3OP0R-Intraday-Master-Pro/

## Description

Here is a comprehensive customer-facing explanation and guide for your Intraday Master Pro indicator, written in clear, professional English, complete with a concise legal disclaimer at the end.

Welcome to Intraday Master Pro
Intraday Master Pro is a high-precision trading script engineered to identify high-probability intraday opportunities by filtering momentum, volume, and multi-timeframe alignment into automated trade setups.

Key Features

Multi-Timeframe Trend Dashboard: Real-time alignment checks across the 1m, 5m, and 15m timeframes.

Dynamic Trend Flow Band: Visual volatility channels indicating overall market bias.

Precision Entry Signals: Volume-filtered entries based on EMA crossovers and RSI constraints.

Automated Risk Management: Dynamic Stop Loss (SL) and 3 Take Profit targets (TP1, TP2, TP3) anchored directly to active signal bars.

Setup Rating Score (1–100): Real-time setup scoring algorithm based on multi-timeframe concordance and volume strength.

How It Works

1. High-Precision Signals & Entry Conditions
The indicator issues BUY or SELL labels only when multiple conditions align:

Trend & Momentum: Fast and Slow EMA crossovers filtered by RSI.

Volume Confirmation: Spikes exceeding 1.25x the 20-period volume average.

Cooldown Guard: Built-in bar cooldown filters to prevent whipsaws during choppy consolidated markets.

2. Multi-Timeframe Dashboard & Setup Rating
Located on the right side of your chart, the dashboard updates live:

1m / 5m / 15m Trend Status: Green (BULL) or Red (BEAR) depending on price position relative to core moving averages.

Setup Rating (1 to 100): A live score grading the quality of the current setup.

80–100 (Green): High-confluence setup across all timeframes and volume.

60–79 (Orange): Moderate setup; proceed with standard risk.

Below 60 (Gray): Low confluence or weak trend.

3. Dynamic Stop Loss & Take Profit Levels
When a valid signal triggers, the indicator projects extended level lines onto your chart:

SL (Orange Line): Calculated dynamically using ATR based on recent market volatility.

TP1 (1.5x R:R): Partial profits / initial target.

TP2 (2.8x R:R): Main target.

TP3 (4.5x R:R): Extended runner target for strong trending days.

How to Use Intraday Master Pro

Wait for a Signal: Look for a clear BUY or SELL label on the chart.

Check Confluence: Glance at the Dashboard. Look for Setup Ratings of 80/100 or higher and alignment across 1m, 5m, and 15m timeframes for maximum statistical edge.

Set Orders: Place your Stop Loss at the SL line and split your position across TP1, TP2, and TP3.

Manage Risk: Once price reaches TP1, consider moving your Stop Loss to entry (Breakeven) to lock in a risk-free trade while riding the position to TP2 and TP3.

Settings & Configuration
Risk Management Inputs: Adjust Core Sensitivity or Volatility Factor to widen or tighten stop-loss distances based on the asset’s volatility.

Visuals: Toggle the Dashboard or Flow Band visibility on/off and customize accent colors to fit dark or light charts.

Disclaimer

The Intraday Master Pro indicator is designed strictly for educational and informational purposes and does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Trading equities, options, forex, and cryptocurrencies involves significant financial risk and can result in the loss of your capital. Always practice proper risk management and consult a licensed financial advisor before executing trades.

---

## Source Code

````pine
//@version=6
indicator("Intraday Master Pro", overlay=true, max_labels_count=500, max_lines_count=500)

// --- INPUTS (Generic & Hidden Configuration) ---
param1        = input.int(9, title="Parameter Alpha", group="Configuration A")
param2        = input.int(21, title="Parameter Beta", group="Configuration A")
param3        = input.int(14, title="Core Sensitivity", group="Risk Management")
param4        = input.float(2.0, title="Volatility Factor", group="Risk Management")

// Visuals
showDashboard = input.bool(true, title="Show Dashboard", group="Visuals")
showCloud     = input.bool(true, title="Show Flow Band", group="Visuals")
buyColor      = input.color(#00FF66, title="Primary Accent Color", group="Visuals")
sellColor     = input.color(#FF0055, title="Secondary Accent Color", group="Visuals")

// --- ENGINE CALCULATIONS ---
f_emaFast = ta.ema(close, param1)
f_emaSlow = ta.ema(close, param2)
f_atr     = ta.atr(param3)
f_rsi     = ta.rsi(close, 14)

// Volume & Momentum filter
volSma     = ta.sma(volume, 20)
highVolume = volume > (volSma * 1.25)

// Multi-Timeframe Data (1m, 5m, 15m)
tf1m_close  = request.security(syminfo.tickerid, "1", close[1], barmerge.gaps_off, barmerge.lookahead_off)
tf1m_ema    = request.security(syminfo.tickerid, "1", ta.ema(close, 9)[1], barmerge.gaps_off, barmerge.lookahead_off)

tf5m_close  = close
tf5m_ema    = f_emaFast

tf15m_close = request.security(syminfo.tickerid, "15", close[1], barmerge.gaps_off, barmerge.lookahead_off)
tf15m_ema   = request.security(syminfo.tickerid, "15", ta.ema(close, 21)[1], barmerge.gaps_off, barmerge.lookahead_off)

// --- DYNAMIC TREND FLOW ---
cloudTop = f_emaFast + (f_atr * 0.5)
cloudBot = f_emaSlow - (f_atr * 0.5)

p1 = plot(showCloud ? cloudTop : na, title="Flow Top", color=color.new(buyColor, 80), linewidth=1)
p2 = plot(showCloud ? cloudBot : na, title="Flow Bottom", color=color.new(sellColor, 80), linewidth=1)
fill(p1, p2, title="Trend Flow Band", color=f_emaFast > f_emaSlow ? color.new(buyColor, 85) : color.new(sellColor, 85))

// --- HIGH-PRECISION ENTRY CONDITIONS ---
bullishBreakout = ta.crossover(f_emaFast, f_emaSlow) and highVolume and f_rsi > 50 and f_rsi < 72
bearishBreakout = ta.crossunder(f_emaFast, f_emaSlow) and highVolume and f_rsi < 50 and f_rsi > 28

var int lastSignalBar = 0
cooldownValid = bar_index - lastSignalBar > 10

bullishCond = bullishBreakout and cooldownValid
bearishCond = bearishBreakout and cooldownValid

if bullishCond or bearishCond
    lastSignalBar := bar_index

// --- REAL-TIME SCORING ALGORITHM (1 TO 100) ---
getCurrentScore() =>
    base = 40
    if tf1m_close > tf1m_ema
        base += 15
    if f_emaFast > f_emaSlow
        base += 25
    if tf15m_close > tf15m_ema
        base += 20
    if highVolume
        base += 5
    math.min(100, math.max(10, base))

var int liveScore = 50
liveScore := getCurrentScore()

var int lastBuyScore  = 50
var int lastSellScore = 50

if bullishCond
    lastBuyScore := liveScore
if bearishCond
    lastSellScore := liveScore

// --- RISK MANAGEMENT: PERSISTENT SL & TP LEVELS ANCHORED TO SIGNAL BAR ---
var float activeSL  = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na
var color activeCol = na
var int   signalBarIndex = na

if bullishCond
    activeSL       := low - (f_atr * param4)
    risk           = close - activeSL
    activeTP1      := close + (risk * 1.5)
    activeTP2      := close + (risk * 2.8)
    activeTP3      := close + (risk * 4.5)
    activeCol      := buyColor
    signalBarIndex := bar_index
else if bearishCond
    activeSL       := high + (f_atr * param4)
    risk           = activeSL - close
    activeTP1      := close - (risk * 1.5)
    activeTP2      := close - (risk * 2.8)
    activeTP3      := close - (risk * 4.5)
    activeCol      := sellColor
    signalBarIndex := bar_index

// --- PLOTTING SIGNALS & PERSISTENT TARGET LINES ANCHORED EXACTLY TO SIGNAL BAR ---
plotshape(bullishCond, title="Signal Buy", style=shape.labelup, location=location.belowbar, color=buyColor, size=size.large, text="BUY", textcolor=color.black)
plotshape(bearishCond, title="Signal Sell", style=shape.labeldown, location=location.abovebar, color=sellColor, size=size.large, text="SELL", textcolor=color.white)

var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label slLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na

if not na(activeSL) and not na(signalBarIndex)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

    slLine  := line.new(signalBarIndex, activeSL,  bar_index, activeSL,  color=color.orange, style=line.style_dashed, width=3, extend=extend.right)
    tp1Line := line.new(signalBarIndex, activeTP1, bar_index, activeTP1, color=activeCol, style=line.style_dotted, width=2, extend=extend.right)
    tp2Line := line.new(signalBarIndex, activeTP2, bar_index, activeTP2, color=activeCol, style=line.style_dotted, width=3, extend=extend.right)
    tp3Line := line.new(signalBarIndex, activeTP3, bar_index, activeTP3, color=activeCol, style=line.style_dotted, width=4, extend=extend.right)

    slLbl   := label.new(bar_index, activeSL,  "SL",  color=color.orange, textcolor=color.black, style=label.style_label_left, size=size.small)
    tp1Lbl  := label.new(bar_index, activeTP1, "TP1", color=activeCol, textcolor=color.white, style=label.style_label_left, size=size.small)
    tp2Lbl  := label.new(bar_index, activeTP2, "TP2", color=activeCol, textcolor=color.white, style=label.style_label_left, size=size.small)
    tp3Lbl  := label.new(bar_index, activeTP3, "TP3", color=activeCol, textcolor=color.white, style=label.style_label_left, size=size.small)

// --- LARGE DASHBOARD (POSITIONED AT MIDDLE RIGHT WITH ENLARGED TEXT SIZE) ---
var table dashboard = table.new(position = position.middle_right, columns = 2, rows = 6, bgcolor = color.new(color.black, 15), border_color = color.new(color.white, 80), border_width = 2)

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "Symbol", text_color=color.white, bgcolor=color.navy, text_size=size.normal)
    table.cell(dashboard, 1, 0, syminfo.ticker, text_color=color.yellow, bgcolor=color.navy, text_size=size.normal)
    
    table.cell(dashboard, 0, 1, "System Core", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.normal)
    table.cell(dashboard, 1, 1, "Status", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.normal)
    
    table.cell(dashboard, 0, 2, "TF 1m Status", text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 2, tf1m_close > tf1m_ema ? "BULL" : "BEAR", text_color=tf1m_close > tf1m_ema ? color.green : color.red, text_size=size.normal)
    
    table.cell(dashboard, 0, 3, "TF 5m Status", text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 3, f_emaFast > f_emaSlow ? "BULL" : "BEAR", text_color=f_emaFast > f_emaSlow ? color.green : color.red, text_size=size.normal)
    
    table.cell(dashboard, 0, 4, "TF 15m Status", text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 4, tf15m_close > tf15m_ema ? "BULL" : "BEAR", text_color=tf15m_close > tf15m_ema ? color.green : color.red, text_size=size.normal)
    
    displayScore = bullishCond ? lastBuyScore : (bearishCond ? lastSellScore : liveScore)
    scoreCol = displayScore >= 80 ? color.green : (displayScore >= 60 ? color.orange : color.gray)
    
    table.cell(dashboard, 0, 5, "Setup Rating", text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 5, str.tostring(displayScore) + "/100", text_color=color.black, bgcolor=scoreCol, text_size=size.normal)
````
