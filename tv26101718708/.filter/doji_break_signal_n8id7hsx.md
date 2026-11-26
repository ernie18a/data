# Doji Break Signal

- url: https://www.tradingview.com/script/N8id7Hsx-Doji-Break-Signal/
- type: indicator
- pine_id: PUB;3ec4b7fbc5694491a68b6145882671b3
- version: 1.0

## Description

// ============================================================
// DOCUMENTATION: Doji Break Signal Indicator
// Version: 6 (Pine Script)
// ============================================================

// OVERVIEW
// --------
// This indicator detects Doji candles and generates Buy/Sell
// signals when price breaks above/below the Doji's high/low.
// It includes EMA filters, ATR distance limits, exit conditions
// with 2-bar confirmation, and a real-time dashboard.

// ============================================================
// INPUTS & SETTINGS
// ============================================================

// --- Core Settings ---
// Doji Body % of Range (default: 10)
//   Defines what qualifies as a Doji. A candle is a Doji if
//   its body size (|close - open|) is <= X% of its total range
//   (high - low). Lower = stricter Doji detection.

// Hard Stop Loss (default: 15 pts)
//   Maximum loss allowed per trade. If price moves against
//   entry by this many points (checked via intrabar low/high),
//   position is closed.

// Exit Offset Points (default: 10 pts)
//   If the current candle's low drops more than X points below
//   the previous candle's close (for longs), exit is triggered.
//   Symmetric for shorts using high vs prev close.

// Max EMA30 ATR Distance - BUY (default: +2.5)
//   Buy signal is blocked if price is more than 2.5x ATR
//   ABOVE EMA30. Prevents buying into overextended upside moves.
//   Formula: (close - EMA30) / ATR14 must be < 2.5

// Max EMA30 ATR Distance - SELL (default: -2.5)
//   Sell signal is blocked if price is more than 2.5x ATR
//   BELOW EMA30. Prevents selling into overextended downside moves.
//   Formula: (close - EMA30) / ATR14 must be > -2.5

// --- Signal Settings ---
// Enable Buy Signals (default: true)
//   Toggle to completely enable/disable all BUY signal generation.

// Enable Sell Signals (default: true)
//   Toggle to completely enable/disable all SELL signal generation.

// --- Label Settings ---
// Show Prices on Labels (default: true)
//   When enabled, BUY/SELL labels show the actual entry price
//   (Doji high for buy, Doji low for sell). When disabled,
//   labels show only "BUY" / "SELL" text.

// Show Buy/Sell Labels (default: true)
//   Toggle visibility of BUY and SELL signal labels on chart.
//   Signal logic still runs internally even when hidden.

// Show Exit Labels (default: true)
//   Toggle visibility of EXIT LONG / EXIT SHORT labels on chart.
//   Exit logic still runs and P&L is tracked even when hidden.

// Show ATR Labels on EMAs (default: true)
//   Toggle visibility of ATR multiple labels at the right edge
//   of each EMA line (EMA5/10/20/30).

// ============================================================
// DOJI DETECTION LOGIC
// ============================================================

// A Doji is detected when:
//   - Candle has a non-zero range (high > low)
//   - Body size (|close - open|) <= dojiBodyPercent% of range
//
// When a new Doji forms:
//   - Its high/low are stored as dHigh/dLow
//   - A shaded box is drawn covering dHigh to dLow
//   - Three Fibonacci levels are drawn:
//       0.44 (red dashed) = dLow + 44% of range
//       0.50 (yellow dashed) = dLow + 50% of range
//       0.618 (green dashed) = dLow + 61.8% of range
//   - All lines/labels extend rightward until next Doji forms
//   - buyUsed and sellUsed flags reset to allow fresh signals
//
// Only current-day Dojis generate signals (buyUsed/sellUsed
// reset at start of each new day).

// ============================================================
// BUY SIGNAL CONDITIONS (all must be true)
// ============================================================

// 1. dojiActive: A Doji exists and current bar is at least
//    2 bars after the Doji (bar_index > dBar + 1)
//    — prevents signal on the immediate Doji break candle

// 2. not buyUsed: Buy signal hasn't fired yet for this Doji
//    — ensures only ONE buy per Doji

// 3. high > dHigh: Current candle's high breaks above Doji high
//    — intrabar breakout detection

// 4. close > close[1]: Current close is above previous close
//    — momentum confirmation, avoids wick-only breakouts

// 5. atrMult30 < ema30AtrLimitBuy:
//    Price is not more than +2.5x ATR above EMA30
//    — prevents buying overextended moves

// Entry price recorded as dHigh (the actual breakout level)

// ============================================================
// SELL SIGNAL CONDITIONS (all must be true)
// ============================================================

// 1. dojiActive: same as buy
// 2. not sellUsed: Sell signal hasn't fired yet for this Doji
// 3. low < dLow: Current candle's low breaks below Doji low
// 4. close < close[1]: Momentum confirmation downward
// 5. atrMult30 > ema30AtrLimitSell:
//    Price is not more than -2.5x ATR below EMA30

// Entry price recorded as dLow (the actual breakdown level)

// ============================================================
// EXIT CONDITIONS (2-bar confirmation required)
// ============================================================

// For LONG positions (checked from bar after entry):
//   Condition 1 - Back In Doji: close < eDHigh
//     Price closes back inside the Doji range
//   Condition 2 - Prev Close Broken: low < close[1] - exitOffset
//     Current low drops X points below previous close
//   Condition 3 - Hard Stop: low <= ePrice - hardStopPoints
//     Price falls X points below entry price

// For SHORT positions:
//   Condition 1 - Back In Doji: close > eDLow
//   Condition 2 - Prev Close Broken: high > close[1] + exitOffset
//   Condition 3 - Hard Stop: high >= ePrice + hardStopPoints

// 2-BAR CONFIRMATION: A pending flag is set when condition
// first triggers. Exit only fires if same condition is true
// on the NEXT bar too. If condition disappears, pending clears.
// This prevents premature exits on temporary price spikes.

// Exit price is recorded as:
//   Back In Doji → current close
//   Prev Close Broken → close[1] ± exitOffset
//   Hard Stop → ePrice ± hardStopPoints

// ============================================================
// EMA LINES & ATR LABELS
// ============================================================

// Four EMAs plotted on chart:
//   EMA5  → Yellow  (fastest, most reactive)
//   EMA10 → Aqua
//   EMA20 → Orange
//   EMA30 → Fuchsia (slowest, used for signal filter)

// ATR Multiple Labels (shown at right edge of chart):
//   Format: "EMAx: N×"
//   N = (close - EMAx) / ATR14
//   Positive = price above EMA, Negative = price below EMA
//   e.g. "EMA30: 1.5×" means price is 1.5 ATRs above EMA30
//   e.g. "EMA30: -2.0×" means price is 2.0 ATRs below EMA30
//   Dashboard ATR row turns RED if beyond buy/sell limits

// ============================================================
// DASHBOARD (top-right)
// ============================================================

// Position     → LONG / SHORT / FLAT (current simulated state)
// Entry Price  → Price at which current position was entered
// Doji Range   → Most recent Doji's low - high levels
// Buy Pts Today→ Cumulative points from closed long trades today
// Sell Pts Today→ Cumulative points from closed short trades today
// Gap 5/10/20/30→ Raw point gap between close and each EMA
// ATR× 5/10/20/30→ Gap expressed as ATR multiples (RED if beyond limit)
// Avg Candle Range→ Average high-low range of all candles today (pts)

// ============================================================
// ALERTS
// ============================================================

// Four alert conditions available in TradingView:
//   "Doji Buy"    → BUY signal fired (high broke above Doji high)
//   "Doji Sell"   → SELL signal fired (low broke below Doji low)
//   "Exit Long"   → Long position exit triggered
//   "Exit Short"  → Short position exit triggered
//
// Recommended alert setting: "Once Per Bar Close"
// to avoid mid-candle repainting on live bars.

// ============================================================
// IMPORTANT NOTES
// ============================================================

// 1. This is an INDICATOR (not a strategy) — it simulates
//    position tracking internally but places no real orders.
//    Use alerts to trigger actual trades via broker/webhook.

// 2. Signals are close-based (except intrabar high/low checks
//    for breakout detection and exit stop conditions).

// 3. One BUY and one SELL allowed per Doji independently.
//    A new Doji resets both flags, allowing fresh signals.

// 4. Daily P&L (Buy Pts / Sell Pts) resets each new day.
//    These are point-based, not currency/lot-size adjusted.

// 5. The indicator works on any timeframe and any symbol,
//    but was designed for intraday NSE (Indian market) use.
//    ATR and EMA values will vary by timeframe/instrument —
//    calibrate ema30AtrLimitBuy/Sell accordingly.

// 6. Doji levels persist until the next Doji forms — signals
//    can fire many bars after the Doji if conditions are met.
//    There is no bar-count expiry window.

## Source Code

````pine
//@version=6

indicator("Doji Break Signal", overlay=true, max_lines_count=50, max_labels_count=200, max_boxes_count=50)

//=====================================================
// INPUTS
//=====================================================

dojiBodyPercent   = input.float(10,   "Doji Body % of Range",                    minval=1, maxval=50)
hardStopPoints    = input.float(15,   "Hard Stop Loss (points)")
exitOffsetPoints  = input.float(10,   "Exit Offset (points)")
ema30AtrLimitBuy  = input.float(2.5,  "Max EMA30 ATR Distance - BUY (+ve limit)")
ema30AtrLimitSell = input.float(-2.5, "Max EMA30 ATR Distance - SELL (-ve limit)")

// Signal enable/disable
enableBuy         = input.bool(true,  "Enable Buy Signals",   group="Signal Settings")
enableSell        = input.bool(true,  "Enable Sell Signals",  group="Signal Settings")

// Label display
showPrices        = input.bool(true,  "Show Prices on Labels",  group="Label Settings")
showSignalLabels  = input.bool(true,  "Show Buy/Sell Labels",   group="Label Settings")
showExitLabels    = input.bool(true,  "Show Exit Labels",        group="Label Settings")
showAtrLabels     = input.bool(true,  "Show ATR Labels on EMAs", group="Label Settings")

//=====================================================
// INDICATORS
//=====================================================

ema5  = ta.ema(close, 5)
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema30 = ta.ema(close, 30)
atr14 = ta.atr(14)

gap5  = close - ema5
gap10 = close - ema10
gap20 = close - ema20
gap30 = close - ema30

atrMult5  = atr14 > 0 ? gap5  / atr14 : 0.0
atrMult10 = atr14 > 0 ? gap10 / atr14 : 0.0
atrMult20 = atr14 > 0 ? gap20 / atr14 : 0.0
atrMult30 = atr14 > 0 ? gap30 / atr14 : 0.0

//=====================================================
// DOJI DETECTION
//=====================================================

candleRange = high - low
bodySize    = math.abs(close - open)
isDoji      = candleRange > 0 and (bodySize / candleRange) * 100 <= dojiBodyPercent

//=====================================================
// DAY TRACKING
//=====================================================

newDay = ta.change(time("D")) != 0

var float dayBuyPoints   = 0.0
var float daySellPoints  = 0.0
var float dayTotalRange  = 0.0
var int   dayCandleCount = 0
var float dayHigh        = na
var float dayLow         = na

if newDay
    dayBuyPoints   := 0.0
    daySellPoints  := 0.0
    dayTotalRange  := 0.0
    dayCandleCount := 0
    dayHigh        := high
    dayLow         := low
else
    dayHigh := math.max(nz(dayHigh, high), high)
    dayLow  := math.min(nz(dayLow,  low),  low)

dayTotalRange  += (high - low)
dayCandleCount += 1
currentDayAvgRange = dayCandleCount > 0 ? dayTotalRange / dayCandleCount : 0.0

//=====================================================
// DOJI STATE
//=====================================================

var float dHigh    = na
var float dLow     = na
var int   dBar     = na
var bool  buyUsed  = false
var bool  sellUsed = false

var line  ln044  = na
var line  ln05   = na
var line  ln618  = na
var label lb044  = na
var label lb05   = na
var label lb618  = na
var box   dBox   = na

if newDay
    buyUsed  := false
    sellUsed := false

if isDoji
    dHigh    := high
    dLow     := low
    dBar     := bar_index
    buyUsed  := false
    sellUsed := false

    fr = dHigh - dLow

    line.delete(ln044)
    line.delete(ln05)
    line.delete(ln618)
    label.delete(lb044)
    label.delete(lb05)
    label.delete(lb618)
    box.delete(dBox)

    ln044 := line.new(bar_index, dLow + fr * 0.44,  bar_index, dLow + fr * 0.44,  color=color.red,    width=1, style=line.style_dashed, extend=extend.right)
    ln05  := line.new(bar_index, dLow + fr * 0.5,   bar_index, dLow + fr * 0.5,   color=color.yellow, width=1, style=line.style_dashed, extend=extend.right)
    ln618 := line.new(bar_index, dLow + fr * 0.618, bar_index, dLow + fr * 0.618, color=color.green,  width=1, style=line.style_dashed, extend=extend.right)

    lb044 := label.new(bar_index, dLow + fr * 0.44,  "0.44", color=color.new(color.red,    80), textcolor=color.red,    style=label.style_label_left, size=size.small)
    lb05  := label.new(bar_index, dLow + fr * 0.5,   "0.5",  color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_left, size=size.small)
    lb618 := label.new(bar_index, dLow + fr * 0.618, "0.618",color=color.new(color.green,  80), textcolor=color.green,  style=label.style_label_left, size=size.small)

    dBox := box.new(bar_index, dHigh, bar_index, dLow, border_color=color.gray, border_width=1, bgcolor=color.new(color.gray, 85))

if not na(ln044)
    line.set_x2(ln044, bar_index)
    line.set_x2(ln05,  bar_index)
    line.set_x2(ln618, bar_index)
    label.set_x(lb044, bar_index)
    label.set_x(lb05,  bar_index)
    label.set_x(lb618, bar_index)

if not na(dBox)
    box.set_right(dBox, bar_index)

//=====================================================
// SIGNAL CONDITIONS
//=====================================================

dojiActive = not na(dBar) and bar_index > dBar + 1

buySignal = enableBuy
     and dojiActive
     and not buyUsed
     and high > dHigh
     and close > close[1]
     and atrMult30 < ema30AtrLimitBuy

sellSignal = enableSell
     and dojiActive
     and not sellUsed
     and low < dLow
     and close < close[1]
     and atrMult30 > ema30AtrLimitSell

if buySignal
    buyUsed := true

if sellSignal
    sellUsed := true

//=====================================================
// POSITION TRACKING
//=====================================================

var int   pos    = 0
var float ePrice = na
var float eDHigh = na
var float eDLow  = na
var int   eBar   = na

if buySignal
    pos    := 1
    ePrice := dHigh
    eDHigh := dHigh
    eDLow  := dLow
    eBar   := bar_index

if sellSignal
    pos    := -1
    ePrice := dLow
    eDHigh := dHigh
    eDLow  := dLow
    eBar   := bar_index

//=====================================================
// EXIT CONDITIONS (2-BAR CONFIRMATION)
//=====================================================

exitLong  = false
exitShort = false

var bool   pendingLong   = false
var bool   pendingShort  = false
var string pendingReason = ""
var string exitReason    = ""
var float  exitPriceLong  = na
var float  exitPriceShort = na

afterEntry = not na(eBar) and bar_index > eBar

if pos == 1 and afterEntry
    cond1     = close < eDHigh
    cond2     = low   < close[1] - exitOffsetPoints
    cond3     = low  <= ePrice   - hardStopPoints
    anyExit   = cond1 or cond2 or cond3
    whichExit = cond1 ? "Back In Doji" : cond2 ? "Prev Close -" + str.tostring(exitOffsetPoints) + "pts" : "Hard Stop"
    exitPrice = cond1 ? close : cond2 ? close[1] - exitOffsetPoints : ePrice - hardStopPoints

    if anyExit and pendingLong
        exitLong      := true
        exitReason    := pendingReason
        exitPriceLong := exitPrice
        pendingLong   := false
        pendingReason := ""
    else if anyExit and not pendingLong
        pendingLong   := true
        pendingReason := whichExit
    else
        pendingLong   := false
        pendingReason := ""

if pos == -1 and afterEntry
    cond1     = close > eDLow
    cond2     = high  > close[1] + exitOffsetPoints
    cond3     = high >= ePrice   + hardStopPoints
    anyExit   = cond1 or cond2 or cond3
    whichExit = cond1 ? "Back In Doji" : cond2 ? "Prev Close +" + str.tostring(exitOffsetPoints) + "pts" : "Hard Stop"
    exitPrice = cond1 ? close : cond2 ? close[1] + exitOffsetPoints : ePrice + hardStopPoints

    if anyExit and pendingShort
        exitShort      := true
        exitReason     := pendingReason
        exitPriceShort := exitPrice
        pendingShort   := false
        pendingReason  := ""
    else if anyExit and not pendingShort
        pendingShort  := true
        pendingReason := whichExit
    else
        pendingShort  := false
        pendingReason := ""

if exitLong
    dayBuyPoints  += exitPriceLong - ePrice
    pos           := 0
    ePrice        := na
    eDHigh        := na
    eDLow         := na
    eBar          := na
    pendingLong   := false

if exitShort
    daySellPoints += ePrice - exitPriceShort
    pos           := 0
    ePrice        := na
    eDHigh        := na
    eDLow         := na
    eBar          := na
    pendingShort  := false

//=====================================================
// EMA PLOTS
//=====================================================

plot(ema5,  title="EMA 5",  color=color.yellow,  linewidth=1)
plot(ema10, title="EMA 10", color=color.aqua,    linewidth=1)
plot(ema20, title="EMA 20", color=color.orange,  linewidth=1)
plot(ema30, title="EMA 30", color=color.fuchsia, linewidth=2)

//=====================================================
// ATR LABELS ON EMAS
//=====================================================

var label aL5  = na
var label aL10 = na
var label aL20 = na
var label aL30 = na

if barstate.islast
    label.delete(aL5)
    label.delete(aL10)
    label.delete(aL20)
    label.delete(aL30)
    if showAtrLabels
        aL5  := label.new(bar_index + 2, ema5,  "EMA5: "  + str.tostring(math.round(nz(atrMult5,  0), 1)) + "×", color=color.new(color.yellow,  80), textcolor=color.yellow,  style=label.style_label_left, size=size.small)
        aL10 := label.new(bar_index + 2, ema10, "EMA10: " + str.tostring(math.round(nz(atrMult10, 0), 1)) + "×", color=color.new(color.aqua,    80), textcolor=color.aqua,    style=label.style_label_left, size=size.small)
        aL20 := label.new(bar_index + 2, ema20, "EMA20: " + str.tostring(math.round(nz(atrMult20, 0), 1)) + "×", color=color.new(color.orange,  80), textcolor=color.orange,  style=label.style_label_left, size=size.small)
        aL30 := label.new(bar_index + 2, ema30, "EMA30: " + str.tostring(math.round(nz(atrMult30, 0), 1)) + "×", color=color.new(color.fuchsia, 80), textcolor=color.fuchsia, style=label.style_label_left, size=size.small)

//=====================================================
// SIGNAL LABELS
//=====================================================

plotshape(isDoji, title="Doji", style=shape.diamond, location=location.abovebar, color=color.gray, text="DOJI", size=size.tiny)

if buySignal
    if showSignalLabels
        label.new(bar_index, low,
             showPrices ? "BUY @ " + str.tostring(dHigh, format.mintick) : "BUY",
             color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)

if sellSignal
    if showSignalLabels
        label.new(bar_index, high,
             showPrices ? "SELL @ " + str.tostring(dLow, format.mintick) : "SELL",
             color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)

if exitLong
    if showExitLabels
        label.new(bar_index, high,
             showPrices ? "EXIT LONG @ " + str.tostring(exitPriceLong, format.mintick) + " (" + exitReason + ")" : "EXIT LONG",
             color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.normal)

if exitShort
    if showExitLabels
        label.new(bar_index, low,
             showPrices ? "EXIT SHORT @ " + str.tostring(exitPriceShort, format.mintick) + " (" + exitReason + ")" : "EXIT SHORT",
             color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.normal)

//=====================================================
// DASHBOARD
//=====================================================

var table dash = table.new(position.top_right, 2, 8, border_width=2, frame_width=2, frame_color=color.white, border_color=color.gray)

if barstate.islast
    table.cell(dash, 0, 0, "Position",        bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 0, pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "FLAT", bgcolor=color.black,
         text_color=pos == 1 ? color.lime : pos == -1 ? color.red : color.gray)

    table.cell(dash, 0, 1, "Entry Price",     bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 1, na(ePrice) ? "-" : str.tostring(ePrice, format.mintick), bgcolor=color.black, text_color=color.aqua)

    table.cell(dash, 0, 2, "Doji Range",      bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 2, na(dHigh) ? "-" : str.tostring(dLow, format.mintick) + " - " + str.tostring(dHigh, format.mintick), bgcolor=color.black, text_color=color.yellow)

    table.cell(dash, 0, 3, "Buy Pts Today",   bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(math.round(dayBuyPoints,  2), "0.00"), bgcolor=color.black, text_color=dayBuyPoints  >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 4, "Sell Pts Today",  bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(math.round(daySellPoints, 2), "0.00"), bgcolor=color.black, text_color=daySellPoints >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 5, "Gap 5/10/20/30",  bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 5,
         str.tostring(math.round(nz(gap5,  0), 1)) + " / " +
         str.tostring(math.round(nz(gap10, 0), 1)) + " / " +
         str.tostring(math.round(nz(gap20, 0), 1)) + " / " +
         str.tostring(math.round(nz(gap30, 0), 1)),
         bgcolor=color.black, text_color=color.aqua)

    table.cell(dash, 0, 6, "ATR× 5/10/20/30", bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 6,
         str.tostring(math.round(nz(atrMult5,  0), 1)) + "× / " +
         str.tostring(math.round(nz(atrMult10, 0), 1)) + "× / " +
         str.tostring(math.round(nz(atrMult20, 0), 1)) + "× / " +
         str.tostring(math.round(nz(atrMult30, 0), 1)) + "×",
         bgcolor=color.black,
         text_color=atrMult30 > ema30AtrLimitBuy or atrMult30 < ema30AtrLimitSell ? color.red : color.yellow)

    table.cell(dash, 0, 7, "Avg Candle Range", bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(math.round(nz(currentDayAvgRange, 0), 1)) + " pts", bgcolor=color.black,
         text_color=currentDayAvgRange > atr14 ? color.lime : color.yellow)

//=====================================================
// ALERTS
//=====================================================

alertcondition(buySignal,  title="Doji Buy",   message="BUY  - High broke above Doji High")
alertcondition(sellSignal, title="Doji Sell",  message="SELL - Low broke below Doji Low")
alertcondition(exitLong,   title="Exit Long",  message="EXIT LONG  - Structural exit")
alertcondition(exitShort,  title="Exit Short", message="EXIT SHORT - Structural exit")
````
