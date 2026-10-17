# Fractal ZigZag with Retest & Filters By WiselyWealth

- url: https://www.tradingview.com/script/uDI6nR2T-Fractal-ZigZag-with-Retest-Filters-By-WiselyWealth/
- type: indicator
- pine_id: PUB;037e96b764d441cb9b487b231b0290e2
- version: 1.0

## Description

Indicator ; Fractal ZigZag with Retest & Filters
Introduction
Welcome to the comprehensive guide for the 'Fractal ZigZag with Retest & Filters' indicator. This custom-built Pine Script indicator is an advanced technical analysis tool designed explicitly for the TradingView platform. At its core, the primary objective of this script is to provide traders with high-probability entry signals by systematically filtering out market noise, avoiding false breakouts, and ensuring alignment with the overarching macroeconomic trend.

Many retail traders fall into the trap of entering positions during sudden, volatile price spikes, only to suffer heavy drawdowns when the market naturally pulls back. This script mitigates that risk by enforcing a strict, rules-based approach: identifying structural shifts, confirming the initial breakout, and mathematically demanding a pullback (or "retest") before issuing a final trading signal. Additionally, it features built-in alert conditions, making it perfectly suited for algorithmic traders who wish to automate their strategies via Webhooks, Telegram bots, or MT5 API integrations.

Technical Mechanism

The mechanical operation of this script is multi-layered, relying on a confluence of structural mapping, trend filtering, and volatility-based retest calculations. Here is a detailed, step-by-step technical breakdown of how the script detects and generates its buy and sell signals:

Mapping Market Structure with Williams Fractals:The foundation of the script relies on identifying key swing highs and swing lows using Williams Fractals. By default, the indicator evaluates a 5-bar lookback and look-forward period to pinpoint these structural pivots. Once a valid upward or downward fractal is identified, the script connects them using a dynamic ZigZag line. This creates an unambiguous visual map of the market's underlying structure, cleanly displaying the sequence of higher highs or lower lows.

Initial Breakout Identification: The indicator actively monitors the current closing price in relation to the most recently confirmed fractal levels. A raw bullish breakout is registered the moment a candle closes definitively above the last established fractal high. Conversely, a raw bearish breakout is noted when the closing price drops below the most recent fractal low. To prevent redundant alerts, the script locks the current trend state upon a successful breakout.

The ATR-Based Retest Engine: This is the most sophisticated aspect of the indicator. When "Enable Retest Mode" is activated, the script refuses to issue an immediate entry signal at the exact moment of the breakout. Instead, it uses the Average True Range (ATR) over a 14-period lookback to measure current market volatility. For a bullish setup, it calculates a "Retest Target" by subtracting a user-defined ATR multiplier (default 1.0) from the breakout close price. It then starts a countdown timer, allowing a maximum number of candles (default 3) for the price to drop back down and touch this target. If the pullback is successful within the time limit, the raw buy signal is triggered. If the time expires without a retest, the setup is safely invalidated.

Macro Trend Filtering: Before finalizing any signal, the script consults a 200-period Exponential Moving Average (EMA). If the trend filter is enabled, a buy signal is entirely suppressed unless the closing price is strictly above the EMA200. Sell signals similarly require the price to remain below the EMA200. Users can also force the script into a "Buy Only" or "Sell Only" mode to align with their long-term directional bias.

How to Use and Best Practices

To extract maximum profitability and accuracy from this script, traders must apply the correct settings and deploy it in appropriate market environments.

Recommended Settings and Configuration:

Conservative Swing Trading: Ensure the EMA200 Trend Filter remains enabled to keep you on the side of institutional momentum. You may also want to increase the Fractal Periods from 5 to 7 or 9. This filters out minor price fluctuations and forces the script to base its breakouts on major structural swing points.

Retest Calibration for Volatility:** The default ATR multiplier is 1.0, and the wait limit is 3 candles. If you are trading on lower timeframes (e.g., 5-minute or 15-minute charts), breakouts can take slightly longer to retest. Consider increasing the "Max Candles to wait" to 5 or 6. For highly volatile assets, increasing the ATR Multiplier to 1.5 can help you secure a deeper, more favorable pullback entry.

Directional Lock: If higher timeframe analysis dictates a strong bull market, use the "Trade Direction" setting to restrict signals to "Buy Only," eliminating counter-trend noise during minor market corrections.

Suitable Markets and Timeframes:

Forex and Indices: This indicator performs exceptionally well on major Forex pairs (EUR/USD, GBP/JPY) and Global Indices (US30, NAS100) on the 1-Hour and 4-Hour timeframes. These assets heavily respect market structure, and liquidity grabs (retests) are highly common after structural breakouts.
Cryptocurrency: Bitcoin and Ethereum on the 15-minute to 1-Hour charts are excellent candidates, provided you adjust the ATR multiplier to account for crypto's volatile, whipsaw movements.
Markets to Avoid: Avoid using this script in heavily consolidated, range-bound, or sideways markets. Breakout and trend-continuation logic inherently struggles during prolonged periods of low volatility, where price chops indiscriminately around the 200 EMA without clear directional follow-through.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TaninWiselyWealth


//@version=6
indicator('Fractal ZigZag with Retest & Filters', overlay = true, max_lines_count = 500)

// ==============================================================================
// ⚙️ SECTION 1: SYSTEM & GENERAL SETTINGS / การตั้งค่าระบบทั่วไป
// ==============================================================================
grp_gen = 'General Settings / การตั้งค่าทั่วไป'
trade_direction = input.string('Both', title = 'Trade Direction / ทิศทางการออกออเดอร์', options = ['Both', 'Buy Only', 'Sell Only'], group = grp_gen, tooltip = 'Select allowed trade direction: Both, Buy Only, or Sell Only.')
use_trend_filter = input.bool(true, title = 'Filter Signals with Trend', group = grp_gen, tooltip = 'If enabled, reversal buy signals require bullish trend confirmation and sell signals require bearish trend confirmation.')
use_retest = input.bool(true, 'Enable Retest Mode', group = grp_gen, tooltip = 'Enable to delay entry signal until price retests ATR level.')
retest_mult = input.float(1.0, 'Retest Value (ATR Multiplier)', group = grp_gen, tooltip = 'Required distance (in ATR) price must reverse after breakout.')
max_wait_bars = input.int(3, 'Max Candles to wait for Retest', minval = 1, group = grp_gen, tooltip = 'Maximum candles to wait for retest.')
sim_atr_len = input.int(14, 'ATR Length for Retest/Simulator', minval = 1, group = grp_gen, tooltip = 'Lookback period for ATR calculations.')

// ==============================================================================
// ⚙️ SECTION 2: FRACTAL ZIGZAG SETTINGS
// ==============================================================================
grp_zz = 'ZigZag Settings'
n = input.int(5, title = 'Fractal Periods (Left/Right)', minval = 1, group = grp_zz)
lineColor = input.color(color.new(color.blue, 0), title = 'ZigZag Line Color', group = grp_zz)
lineWidth = input.int(2, title = 'Line Width', minval = 1, group = grp_zz)

// --- ตัวแปรสำหรับ Trend Filter & ATR ---
emaTrend = ta.ema(close, 200) // ใช้ EMA 200 เป็นตัวกรองเทรนด์หลัก
atrValue = ta.atr(sim_atr_len)
atrVal_non_na = nz(atrValue) // ตัวแปรที่ประกาศเพิ่มเติมเพื่อป้องกันค่า NA ในระบบจำลอง

plot(use_trend_filter ? emaTrend : na, color = color.new(color.orange, 50), title = 'Trend Filter (EMA200)', linewidth = 2)

// --- ค้นหา Williams Fractals ---
upFractal = ta.pivothigh(high, n, n)
dnFractal = ta.pivotlow(low, n, n)

plotshape(not na(upFractal), title = 'Up Fractal', style = shape.triangledown, location = location.abovebar, color = color.yellow, offset = -n, size = size.tiny)
plotshape(not na(dnFractal), title = 'Down Fractal', style = shape.triangleup, location = location.belowbar, color = color.blue, offset = -n, size = size.tiny)

// --- ตัวแปรโครงสร้างราคา ---
var int lastPivotType = 0
var float lastPivotPrice = na
var int lastPivotBar = na
var line zzLine = na

var float lastFractalHigh = na
var float lastFractalLow = na
var int currentTrend = 0

// --- อัปเดตโครงสร้างและเส้น ZigZag ---
if not na(upFractal)
    lastFractalHigh := high[n]
    if lastPivotType == -1
        zzLine := line.new(lastPivotBar, lastPivotPrice, bar_index[n], high[n], color = lineColor, width = lineWidth)
        lastPivotType := 1
        lastPivotPrice := high[n]
        lastPivotBar := bar_index[n]
        lastPivotBar
    else if lastPivotType == 1
        if high[n] > lastPivotPrice
            line.set_xy2(zzLine, bar_index[n], high[n])
            lastPivotPrice := high[n]
            lastPivotBar := bar_index[n]
            lastPivotBar
    else if lastPivotType == 0
        lastPivotType := 1
        lastPivotPrice := high[n]
        lastPivotBar := bar_index[n]
        lastPivotBar

if not na(dnFractal)
    lastFractalLow := low[n]
    if lastPivotType == 1
        zzLine := line.new(lastPivotBar, lastPivotPrice, bar_index[n], low[n], color = lineColor, width = lineWidth)
        lastPivotType := -1
        lastPivotPrice := low[n]
        lastPivotBar := bar_index[n]
        lastPivotBar
    else if lastPivotType == -1
        if low[n] < lastPivotPrice
            line.set_xy2(zzLine, bar_index[n], low[n])
            lastPivotPrice := low[n]
            lastPivotBar := bar_index[n]
            lastPivotBar
    else if lastPivotType == 0
        lastPivotType := -1
        lastPivotPrice := low[n]
        lastPivotBar := bar_index[n]
        lastPivotBar

// ==============================================================================
// ⚙️ SECTION 3: BREAKOUT, RETEST & SIGNAL GENERATION
// ==============================================================================
// ตรวจจับการ Breakout ครั้งแรก
breakoutUp = not na(lastFractalHigh) and close > lastFractalHigh and currentTrend != 1
breakoutDn = not na(lastFractalLow) and close < lastFractalLow and currentTrend != -1

// ตัวแปรสำหรับสถานะการรอ Retest
var bool waitingForBuyRetest = false
var float buyRetestTarget = na
var int buyWaitCounter = 0

var bool waitingForSellRetest = false
var float sellRetestTarget = na
var int sellWaitCounter = 0

bool rawBuySignal = false
bool rawSellSignal = false

// 1. ตรวจสอบการเกิด Breakout ขาขึ้น
if breakoutUp
    currentTrend := 1 // ล็อกเทรนด์ไว้เพื่อกันสัญญาณซ้ำ
    if use_retest
        waitingForBuyRetest := true
        buyRetestTarget := close - retest_mult * atrValue // คำนวณจุด Retest ด้วยระยะ ATR
        buyWaitCounter := 0
        buyWaitCounter
    else
        rawBuySignal := true
        rawBuySignal

// 2. ตรวจสอบการเกิด Breakout ขาลง
if breakoutDn
    currentTrend := -1
    if use_retest
        waitingForSellRetest := true
        sellRetestTarget := close + retest_mult * atrValue
        sellWaitCounter := 0
        sellWaitCounter
    else
        rawSellSignal := true
        rawSellSignal

// 3. ประมวลผลการรอ Retest ฝั่ง Buy (ถ้ามีการเปิดใช้งาน)
if waitingForBuyRetest
    buyWaitCounter := buyWaitCounter + 1
    if low <= buyRetestTarget // ถ้าราคาย่อตัวลงมาแตะหรือต่ำกว่าจุด Target
        rawBuySignal := true // ออกสัญญาณ Buy (Retest สำเร็จ)
        waitingForBuyRetest := false // ล้างสถานะ
        waitingForBuyRetest
    else if buyWaitCounter > max_wait_bars
        waitingForBuyRetest := false // หมดเวลาการรอ Retest ให้ยกเลิกสัญญาณ
        waitingForBuyRetest

// 4. ประมวลผลการรอ Retest ฝั่ง Sell (ถ้ามีการเปิดใช้งาน)
if waitingForSellRetest
    sellWaitCounter := sellWaitCounter + 1
    if high >= sellRetestTarget // ถ้าราคาดีดตัวขึ้นไปแตะหรือสูงกว่าจุด Target
        rawSellSignal := true // ออกสัญญาณ Sell (Retest สำเร็จ)
        waitingForSellRetest := false // ล้างสถานะ
        waitingForSellRetest
    else if sellWaitCounter > max_wait_bars
        waitingForSellRetest := false // หมดเวลา
        waitingForSellRetest

// ==============================================================================
// ⚙️ SECTION 4: FILTERING & PLOTTING
// ==============================================================================
bool finalBuy = rawBuySignal
bool finalSell = rawSellSignal

// กรองด้วย Trend Filter (EMA200)
if use_trend_filter
    finalBuy := finalBuy and close > emaTrend
    finalSell := finalSell and close < emaTrend
    finalSell

// กรองด้วย Trade Direction
if trade_direction == 'Buy Only'
    finalSell := false
    finalSell
if trade_direction == 'Sell Only'
    finalBuy := false
    finalBuy


plotshape(finalBuy, 'Buy Signal', shape.triangleup, location.belowbar, color = color.lime, size = size.small, text = 'BUY')
plotshape(finalSell, 'Sell Signal', shape.triangledown, location.abovebar, color = color.red, size = size.small, text = 'SELL')

// ==========================================
// 🔔 ALERT CONDITIONS (WEBHOOK / TELEGRAM / CRYPTO / MT5 API)
// ==========================================
alertcondition(finalBuy, title = 'Buy Order ')
alertcondition(finalSell, title = 'Sell Order ')
````
