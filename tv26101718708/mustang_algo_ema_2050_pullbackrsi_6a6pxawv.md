# Mustang Algo EMA 20/50 Pullback+RSI 

- url: https://www.tradingview.com/script/6a6pxAwv/
- type: indicator
- pine_id: PUB;ee32a9c7d5c345e382aa62a6da37a2fc
- version: 1.0

## Description

Mustang Algo — EMA 20/50 Pullback + RSI + EMA 200 + Anti-Range Filter
A complete trend-following pullback system that combines four layers of confluence — short-term momentum (EMA 20), mid-term trend (EMA 50), long-term bias (EMA 200), and an anti-range filter — gated by RSI(14). The indicator trades both long and short with fully symmetric logic and provides granular control over signal frequency through multiple anti-spam mechanisms.
Core concept
In a trending market, price doesn't move in straight lines. It pulls back to dynamic support (the EMA 20) before resuming. This indicator detects those exact moments — when momentum is still intact (RSI confirms direction), the mid-term structure is aligned (EMA 20 above/below EMA 50), the long-term bias agrees (price or EMA 50 on the right side of EMA 200), and the market is genuinely trending (not chopping sideways) — and prints a signal only on the candle that confirms the rebound.
The hardest part of any pullback strategy is avoiding range markets, where the same logic that catches clean trend continuations produces a stream of losing trades. This version addresses that head-on with a dedicated anti-range layer.
How it works
LONG signal fires when EMA 20 is above EMA 50, the candle touches EMA 20 (wick or body, configurable), the close is above EMA 20 with a bullish body, RSI is above the long threshold, the EMA 200 filter is satisfied, and the anti-range filter confirms a trending environment.
SHORT signal is the exact mirror: EMA 20 below EMA 50, touch on EMA 20, bearish rejection candle, RSI below the short threshold, EMA 200 filter satisfied for shorts, and anti-range filter active.
Initial signals (INIT L / INIT S) mark the moment of the EMA 20/50 cross when all filters already agree — useful to catch the very first leg of a new trend before any pullback has formed.
Exits trigger on the opposite EMA 20/50 cross or when price closes beyond the EMA 50 (both toggleable independently).
EMA 200 trend filter — three modes

Price vs EMA 200 — standard: longs only above, shorts only below.
EMA 50 vs EMA 200 — structural: requires the mid-term EMA to be aligned with the long-term EMA. Fewer signals, higher conviction.
Both (strict) — requires both conditions simultaneously. Designed for swing setups and conservative profiles.

A tolerance setting (%) allows price to sit slightly on the wrong side of the EMA 200 without invalidating the signal — useful on FX and metals where price oscillates tightly around the long-term mean.
Anti-range filter — four modes
This is what separates a pullback indicator that works in trends from one that survives in real markets.

ADX — Classic Wilder ADX. Below the minimum threshold (default 20), the market is considered ranging and signals are blocked. Reliable on indices and crypto.
EMA distance — Measures the gap between EMA 20 and EMA 50 normalized by ATR. Below a configurable multiple (default 0.5×ATR), the EMAs are too close together, signaling consolidation. More reactive than ADX, ideal for gold and FX.
Choppiness Index — Dedicated chop measure on a 0-100 scale. Above the configurable maximum (default 61.8, the Fibonacci threshold), the market is choppy. Highest precision for pure ranges, best on D1 swing setups.
ADX + EMA distance (strict) — Default mode. Requires both ADX and EMA distance conditions simultaneously. ADX catches absolute weakness in directionality; EMA distance catches geometric compression. Each compensates for the other's blind spot. The two metrics together produce the cleanest signal set.

When the filter blocks the market, an optional yellow background highlights the ranging zones so you can calibrate your thresholds visually.
Signal frequency control
Two independent anti-spam layers let you fine-tune how aggressive the indicator is:

One signal per pullback (default ON) — A pullback is considered "consumed" after a signal fires. The setup must re-arm by moving N×ATR away from EMA 20 (default 0.5) before a new signal is allowed. Eliminates clustered signals during consolidation on the EMA 20.
Only first signal after EMA cross (default OFF) — Only the FIRST pullback signal after each EMA 20/50 cross is fired. Subsequent pullbacks in the same trend leg are ignored until a new cross occurs. Designed for swing traders who only want to enter at the start of a new trend.

Configurable inputs

Direction (LONG / SHORT toggles, independent)
EMA lengths (20 / 50 / 200) and source
EMA 200 filter mode and tolerance
Anti-range filter mode, ADX length and threshold, EMA distance multiplier, Choppiness length and threshold
RSI length and dual thresholds (long / short)
Touch mode (wick or body) and touch tolerance
Re-arm distance in ATR multiples
First-after-cross gating
Exit conditions (EMA cross / close beyond EMA 50)
Visual options (zone fill, EMA 200 background, range background, status table)

Built-in alerts
Seven alert conditions covering pullback BUY, pullback SELL, initial LONG, initial SHORT, LONG exit, SHORT exit, and a generic "any signal" alert. All messages include ticker, timeframe, and price.
Status table
A live readout in the top-right shows MT trend, EMA 200 filter state, range filter state, current ADX value, EMA gap/ATR ratio, the three EMA values, and current RSI — color-coded so the full setup state is readable at a glance.
Recommended settings by context

XAUUSD H1 — ADX min 18, EMA distance 0.4×ATR (gold moves fast, slightly more permissive)
EURUSD H1-H4 — ADX min 22, EMA distance 0.6×ATR (FX ranges often, stricter)
Indices D1 — ADX min 20, EMA distance 0.5×ATR (default values)
Crypto H4 — ADX min 25, EMA distance 0.7×ATR (erratic volatility, strictest)

For ultra-conservative swing entries: enable "Only first signal after EMA cross", set EMA 200 filter to "Both (strict)", and keep anti-range in default "ADX + EMA distance (strict)" mode.
Recommended timeframes
Works on any timeframe but performs best on H1 to D1 for swing setups, and M15 to H1 for intraday. On lower timeframes, increase the ATR re-arm distance and consider switching the touch mode to "Body" for higher quality signals.
Methodology notes
The indicator uses only standard, well-documented building blocks (EMA, RSI, ATR, ADX, Choppiness Index) — no black-box signals, no hidden repaint mechanics, no curve-fit thresholds. Every parameter is exposed and every decision is auditable from the source.
Signals are evaluated on bar close. The anti-range and anti-spam mechanisms are deterministic and use only past data, so backtests reflect real-time behavior.
Disclaimer
This is a technical analysis indicator, not financial advice. Always backtest on your specific instrument, timeframe, and broker spread before committing capital. Trend-following pullback strategies underperform in pure ranging markets — the multi-layer filtering mitigates this but does not eliminate it. Past performance does not guarantee future results.
— Mustang Algo

## Source Code

````pine
//@version=6
// =====================================================================
//  Mustang Algo — EMA 20/50 Pullback + RSI + EMA 200 Filter (Long & Short)
//  LONG  : EMA20>EMA50, price touches EMA20, RSI>50, bullish rebound
//  SHORT : EMA20<EMA50, price touches EMA20, RSI<50, bearish rejection
//  Long-term trend filter: EMA200 (fully configurable)
//  Anti-range filter: ADX / EMA distance / Choppiness / ADX+EMA (strict)
//  LONG exit  : EMA20<EMA50 OR close < EMA50
//  SHORT exit : EMA20>EMA50 OR close > EMA50
//
//  © Mustang Algo
// =====================================================================
indicator("Mustang Algo — EMA 20/50 Pullback + RSI + EMA200", shorttitle="MA PB", overlay=true)

// ============== INPUTS ==============
grpDir   = "Direction"
enableLong  = input.bool(true, "Enable LONG",  group=grpDir)
enableShort = input.bool(true, "Enable SHORT", group=grpDir)

grpEMA   = "Moving Averages"
lenFast  = input.int(20,  "Fast EMA",  minval=1, group=grpEMA)
lenSlow  = input.int(50,  "Slow EMA",  minval=1, group=grpEMA)
lenTrend = input.int(200, "Trend EMA (filter)", minval=1, group=grpEMA)
srcEMA   = input.source(close, "EMA Source", group=grpEMA)

grpFilter = "EMA 200 Filter"
useTrendFilter = input.bool(true, "Enable EMA200 filter", group=grpFilter,
     tooltip="When enabled, only take LONGs above EMA200 and SHORTs below.")
trendFilterMode = input.string("Price vs EMA200", "Filter mode",
     options=["Price vs EMA200", "EMA50 vs EMA200", "Both (strict)"], group=grpFilter,
     tooltip="• Price vs EMA200: close above/below EMA200.\n• EMA50 vs EMA200: MT/LT trend alignment.\n• Both: requires both conditions simultaneously (stricter).")
trendTolPct = input.float(0.0, "Filter tolerance (%)", minval=0, step=0.05, group=grpFilter,
     tooltip="Margin around EMA200. 0 = strict. 0.1 = tolerates 0.1% below for LONGs.")
showEma200 = input.bool(true, "Show EMA200", group=grpFilter)

grpRange = "Anti-Range Filter"
useRangeFilter = input.bool(true, "Enable anti-range filter", group=grpRange,
     tooltip="Blocks signals when the market is ranging instead of trending.")
rangeMode = input.string("ADX + EMA distance (strict)", "Anti-range method",
     options=["ADX", "EMA distance", "Choppiness Index", "ADX + EMA distance (strict)"], group=grpRange,
     tooltip="• ADX: classic trend strength.\n• EMA distance: gap between EMA20 and EMA50 normalized by ATR.\n• Choppiness Index: dedicated chop measure (0-100).\n• Strict: requires both ADX and EMA distance.")
adxLen     = input.int(14, "ADX length",      minval=2, group=grpRange)
adxMin     = input.float(20.0, "ADX minimum", minval=0, maxval=100, step=1, group=grpRange,
     tooltip="Typical values: 18-25. Below this, market is considered ranging.")
emaDistMin = input.float(0.5, "Min EMA20-EMA50 gap (x ATR)", minval=0, step=0.1, group=grpRange,
     tooltip="Minimum gap between EMA20 and EMA50, normalized by ATR. Below this, the EMAs are too close = range.")
chopLen    = input.int(14,   "Choppiness length",   minval=2, group=grpRange)
chopMax    = input.float(61.8, "Choppiness maximum", minval=0, maxval=100, step=1, group=grpRange,
     tooltip="Above this value, market is choppy. Typical thresholds: 50 (loose) to 61.8 (Fibonacci, classic).")
showRangeBg = input.bool(false, "Color background when ranging", group=grpRange)

grpRSI   = "RSI"
lenRSI       = input.int(14,   "RSI Length", minval=2, group=grpRSI)
rsiLvlLong   = input.float(50.0, "RSI Level LONG (>)",  minval=0, maxval=100, step=1, group=grpRSI)
rsiLvlShort  = input.float(50.0, "RSI Level SHORT (<)", minval=0, maxval=100, step=1, group=grpRSI)

grpSig   = "Pullback Detection"
touchMode = input.string("Wick (high/low)", "EMA20 touch mode",
     options=["Wick (high/low)", "Body (close)"], group=grpSig,
     tooltip="Wick = the candle pierces EMA20. Body = the close crosses then rebounds.")
tolPct   = input.float(0.10, "Touch tolerance (%)", minval=0, step=0.05, group=grpSig,
     tooltip="Margin around EMA20 to consider a 'touch'. 0.10 = 0.10%.")
oneSigPerPB = input.bool(true, "One signal per pullback", group=grpSig,
     tooltip="Avoids repeated signals until price has moved clearly away from EMA20.")
reentryAtrMult = input.float(0.5, "Re-arm distance (x ATR)", minval=0, step=0.1, group=grpSig,
     tooltip="Price must move N×ATR away from EMA20 before a new signal is allowed.")
firstAfterCross = input.bool(false, "Only first signal after EMA cross", group=grpSig,
     tooltip="If enabled, only the FIRST pullback signal after each EMA20/EMA50 cross is fired.")

grpExit  = "Exit / Stop"
useEmaCross        = input.bool(true, "Exit on EMA20/EMA50 cross", group=grpExit)
useCloseBeyondSlow = input.bool(true, "Exit on close beyond EMA50", group=grpExit)

grpVis   = "Visuals"
showInitial = input.bool(true, "Show initial signals (cross + RSI)", group=grpVis)
showFill    = input.bool(true, "Fill EMA20/EMA50 zone", group=grpVis)
showTable   = input.bool(true, "Show status table", group=grpVis)
colorBg     = input.bool(false, "Color background per EMA200 filter", group=grpVis)

// ============== CALCULATIONS ==============
emaFast  = ta.ema(srcEMA, lenFast)
emaSlow  = ta.ema(srcEMA, lenSlow)
emaTrend = ta.ema(srcEMA, lenTrend)
rsi      = ta.rsi(close, lenRSI)
atr14    = ta.atr(14)

// ============== ANTI-RANGE FILTER ==============
// --- ADX ---
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxOK = adxVal >= adxMin

// --- EMA20/EMA50 distance normalized by ATR ---
emaGapAtr = math.abs(emaFast - emaSlow) / atr14
emaDistOK = emaGapAtr >= emaDistMin

// --- Choppiness Index ---
chopHigh  = ta.highest(high, chopLen)
chopLow   = ta.lowest(low,  chopLen)
chopRange = chopHigh - chopLow
chopSum   = math.sum(ta.tr(true), chopLen)
chopIdx   = chopRange > 0 ? 100 * math.log10(chopSum / chopRange) / math.log10(chopLen) : 50
chopOK    = chopIdx <= chopMax

// --- Combined filter according to mode ---
trendingOK = (rangeMode == "ADX") ? adxOK : (rangeMode == "EMA distance") ? emaDistOK : (rangeMode == "Choppiness Index") ? chopOK : (adxOK and emaDistOK)
rangeFilterOK = not useRangeFilter or trendingOK

// Mid-term trend
trendUp   = emaFast > emaSlow
trendDown = emaFast < emaSlow

// --- EMA200 filter ---
trendTol = emaTrend * trendTolPct / 100.0
priceAboveTrend = close >= emaTrend - trendTol
priceBelowTrend = close <= emaTrend + trendTol
ema50AboveTrend = emaSlow >= emaTrend - trendTol
ema50BelowTrend = emaSlow <= emaTrend + trendTol

bullFilter = (trendFilterMode == "Price vs EMA200") ? priceAboveTrend : (trendFilterMode == "EMA50 vs EMA200") ? ema50AboveTrend : (priceAboveTrend and ema50AboveTrend)
bearFilter = (trendFilterMode == "Price vs EMA200") ? priceBelowTrend : (trendFilterMode == "EMA50 vs EMA200") ? ema50BelowTrend : (priceBelowTrend and ema50BelowTrend)

longFilterOK  = not useTrendFilter or bullFilter
shortFilterOK = not useTrendFilter or bearFilter

// EMA20 touch
tol = emaFast * tolPct / 100.0
touch = (touchMode == "Wick (high/low)") ? (low <= emaFast + tol and high >= emaFast - tol) : (close <= emaFast + tol and close >= emaFast - tol)

// Candle confirmations
rebound   = close > emaFast and close > open
rejection = close < emaFast and close < open

// Raw conditions
rsiOKLong  = rsi > rsiLvlLong
rsiOKShort = rsi < rsiLvlShort
buyRaw  = enableLong  and trendUp   and touch and rebound   and rsiOKLong  and longFilterOK  and rangeFilterOK
sellRaw = enableShort and trendDown and touch and rejection and rsiOKShort and shortFilterOK and rangeFilterOK

// --- Cross detection ---
crossUp   = ta.crossover(emaFast,  emaSlow)
crossDown = ta.crossunder(emaFast, emaSlow)

// --- "Only first signal after EMA cross" gating ---
var bool longWindowOpen  = false
var bool shortWindowOpen = false
if crossUp
    longWindowOpen  := true
    shortWindowOpen := false
if crossDown
    shortWindowOpen := true
    longWindowOpen  := false

firstAfterCrossLong  = not firstAfterCross or longWindowOpen
firstAfterCrossShort = not firstAfterCross or shortWindowOpen

// --- Anti-spam: one signal per pullback ---
var bool armedLong  = true
var bool armedShort = true
distLongOK  = (close - emaFast) >  (reentryAtrMult * atr14)
distShortOK = (emaFast - close) >  (reentryAtrMult * atr14)
if distLongOK
    armedLong := true
if distShortOK
    armedShort := true

buyPB  = oneSigPerPB ? (buyRaw  and armedLong)  : buyRaw
sellPB = oneSigPerPB ? (sellRaw and armedShort) : sellRaw

// Final signals
buy  = buyPB  and firstAfterCrossLong
sell = sellPB and firstAfterCrossShort

if buy
    armedLong := false
    longWindowOpen := false
if sell
    armedShort := false
    shortWindowOpen := false

// --- Initial signals: EMA cross + RSI + filters ---
initialBuy  = enableLong  and crossUp   and rsiOKLong  and longFilterOK  and rangeFilterOK
initialSell = enableShort and crossDown and rsiOKShort and shortFilterOK and rangeFilterOK

// --- Exits ---
exitLongCross  = useEmaCross         and ta.crossunder(emaFast, emaSlow)
exitLongBelow  = useCloseBeyondSlow  and ta.crossunder(close, emaSlow)
exitLong       = enableLong and (exitLongCross or exitLongBelow)
exitShortCross = useEmaCross         and ta.crossover(emaFast, emaSlow)
exitShortAbove = useCloseBeyondSlow  and ta.crossover(close, emaSlow)
exitShort      = enableShort and (exitShortCross or exitShortAbove)

// ============== PLOT ==============
pFast  = plot(emaFast,  "EMA 20",  color=color.new(#26a69a, 0), linewidth=2)
pSlow  = plot(emaSlow,  "EMA 50",  color=color.new(color.black, 0), linewidth=2)
plot(showEma200 ? emaTrend : na, "EMA 200", color=color.new(#ff9800, 0), linewidth=3)

fillCol = showFill ? (trendUp ? color.new(#26a69a, 85) : trendDown ? color.new(color.red, 88) : na) : na
fill(pFast, pSlow, color=fillCol)

bgCol = colorBg and useTrendFilter ? (bullFilter ? color.new(#26a69a, 95) : bearFilter ? color.new(color.red, 95) : na) : na
bgcolor(bgCol, title="EMA200 filter background")

rangeBgCol = showRangeBg and useRangeFilter and not trendingOK ? color.new(color.yellow, 92) : na
bgcolor(rangeBgCol, title="Range background")

// Main signals
plotshape(buy,  title="BUY pullback",  style=shape.labelup,   location=location.belowbar, color=color.new(#1b5e20, 0), textcolor=color.white, text="BUY",  size=size.small)
plotshape(sell, title="SELL pullback", style=shape.labeldown, location=location.abovebar, color=color.new(#b71c1c, 0), textcolor=color.white, text="SELL", size=size.small)

// Initial signals
plotshape(showInitial and initialBuy,  title="Initial LONG signal",  style=shape.labelup,   location=location.belowbar, color=color.new(#0d47a1, 0), textcolor=color.white, text="INIT L", size=size.tiny)
plotshape(showInitial and initialSell, title="Initial SHORT signal", style=shape.labeldown, location=location.abovebar, color=color.new(#4a148c, 0), textcolor=color.white, text="INIT S", size=size.tiny)

// Exits
plotshape(exitLong,  title="EXIT LONG",  style=shape.xcross, location=location.abovebar, color=color.new(#b71c1c, 0), size=size.tiny)
plotshape(exitShort, title="EXIT SHORT", style=shape.xcross, location=location.belowbar, color=color.new(#1b5e20, 0), size=size.tiny)

// ============== ALERTS ==============
alertcondition(buy,         title="BUY Pullback 20/50 + RSI",  message="Mustang Algo — BUY pullback EMA20 + RSI>level + filters OK on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(sell,        title="SELL Pullback 20/50 + RSI", message="Mustang Algo — SELL pullback EMA20 + RSI<level + filters OK on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(initialBuy,  title="Initial LONG signal",  message="Mustang Algo — EMA20 crosses above EMA50 + RSI>level + filters OK on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(initialSell, title="Initial SHORT signal", message="Mustang Algo — EMA20 crosses below EMA50 + RSI<level + filters OK on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(exitLong,    title="EXIT LONG",  message="Mustang Algo — LONG exit on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(exitShort,   title="EXIT SHORT", message="Mustang Algo — SHORT exit on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(buy or sell, title="Any signal (BUY/SELL)",   message="Mustang Algo — Pullback signal on {{ticker}} ({{interval}}) @ {{close}}")

// ============== STATUS TABLE ==============
var table tbl = table.new(position.top_right, 2, 9, frame_color=color.new(color.gray, 70), frame_width=1)
if barstate.islast and showTable
    trendTxt = trendUp ? "Bullish ▲" : trendDown ? "Bearish ▼" : "Neutral ●"
    trendCol = trendUp ? #1b5e20 : trendDown ? #b71c1c : color.gray
    table.cell(tbl, 0, 0, "MT Trend",   bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 0, trendTxt,     bgcolor=color.new(trendCol, 70),    text_color=color.white)
    filterTxt = not useTrendFilter ? "Disabled" : bullFilter ? "Bull ▲" : bearFilter ? "Bear ▼" : "Neutral ●"
    filterCol = not useTrendFilter ? color.gray : bullFilter ? #1b5e20 : bearFilter ? #b71c1c : color.gray
    table.cell(tbl, 0, 1, "EMA200 Filter", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 1, filterTxt,       bgcolor=color.new(filterCol, 70),   text_color=color.white)
    rangeTxt = not useRangeFilter ? "Disabled" : trendingOK ? "Trending ▲" : "Ranging ●"
    rangeCol = not useRangeFilter ? color.gray : trendingOK ? #1b5e20 : color.orange
    table.cell(tbl, 0, 2, "Range Filter", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 2, rangeTxt,       bgcolor=color.new(rangeCol, 70),    text_color=color.white)
    table.cell(tbl, 0, 3, "ADX(" + str.tostring(adxLen) + ")", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 3, str.tostring(adxVal, "#.##"), bgcolor=color.new(adxOK ? #1b5e20 : color.orange, 70), text_color=color.white)
    table.cell(tbl, 0, 4, "EMA gap/ATR", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 4, str.tostring(emaGapAtr, "#.##"), bgcolor=color.new(emaDistOK ? #1b5e20 : color.orange, 70), text_color=color.white)
    table.cell(tbl, 0, 5, "EMA20",  bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 5, str.tostring(emaFast,  format.mintick), bgcolor=color.new(color.black, 90), text_color=color.white)
    table.cell(tbl, 0, 6, "EMA50",  bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 6, str.tostring(emaSlow,  format.mintick), bgcolor=color.new(color.black, 90), text_color=color.white)
    table.cell(tbl, 0, 7, "EMA200", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 7, str.tostring(emaTrend, format.mintick), bgcolor=color.new(#ff9800, 70),     text_color=color.white)
    rsiCol = rsi > rsiLvlLong ? #1b5e20 : rsi < rsiLvlShort ? #b71c1c : color.gray
    table.cell(tbl, 0, 8, "RSI(" + str.tostring(lenRSI) + ")", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(tbl, 1, 8, str.tostring(rsi, "#.##"), bgcolor=color.new(rsiCol, 70), text_color=color.white)
````
