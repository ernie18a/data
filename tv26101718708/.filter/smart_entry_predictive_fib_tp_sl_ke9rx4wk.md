# Smart Entry Predictive Fib TP SL

- url: https://www.tradingview.com/script/Ke9Rx4WK-Smart-Entry-Predictive-Fib-TP-SL/
- type: indicator
- pine_id: PUB;3e378f87ca9549b1934a531043361811
- version: 2.0

## Description

Smart Entry — Predictive Fib Zones with TP / SL Levels
This indicator combines Fibonacci retracement, EMA, SMA, RSI and Volume POC (Point of Control) to generate a single clear trading decision — BUY or SELL — with exact entry, take profit and stop loss levels drawn directly on the chart.
How it works:
The script analyses the last 30 candles to auto-detect the swing high and low, then calculates all key Fibonacci levels (0.236, 0.382, 0.5, 0.618, 0.705, 0.786). A directional bias score is computed from RSI position, EMA9/EMA21 alignment, price vs SMA50, and volume pressure. Because BUY% and SELL% are derived from the same inverse bias, they can never both read high at the same time.
What you get on the chart:

ENTRY line — exact price to enter
TP 1, TP 2, TP 3 — three take profit targets with % gain and R:R ratio per level
STOP LOSS line — with % risk clearly labelled
Volume POC — the highest-volume price node over the lookback period, used to refine the entry price
Projected zone boxes to the right showing where price is likely to react before it gets there
Live info table with all levels, RSI, EMA alignment, volume status and bias

Indicators used: Fibonacci · EMA 9/21 · SMA 50 · RSI 14 · Volume POC
For educational purposes. Always manage your own risk.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════
//  Smart Entry - Multi-Structure Confluence Zones
//  Pine Script v6
//
//  Draws Fibonacci zones from 3 lookback periods simultaneously:
//    LB1 = 200 bars  (major structure)
//    LB2 = 100 bars  (intermediate structure)
//    LB3 = 50  bars  (minor structure)
//
//  Where 2+ zones overlap = CONFLUENCE ZONE → stronger signal
//  Where all 3 overlap    = HIGH CONFLUENCE  → strongest signal
//
//  Entry / TP / SL only shown inside confluence zones.
// ══════════════════════════════════════════════════════════════════

//@version=6
indicator("Smart Entry - Multi Structure Confluence", shorttitle="MultiFib", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=30)

// ────────────────────────────────────────────
// 1. INPUTS
// ────────────────────────────────────────────
lb1     = input.int(200,  "LB1 - Weekly structure  (200x15m = 2.5 days)", minval=50,  maxval=500, group="Structure")
lb2     = input.int(96,   "LB2 - Daily structure   (96x15m  = 1 day)",   minval=20,  maxval=300, group="Structure")
lb3     = input.int(32,   "LB3 - Session structure (32x15m  = 8 hours)", minval=10,  maxval=200, group="Structure")
futBars = input.int(50,   "Project lines (bars)",      minval=10,  maxval=200, group="Structure")
pDec    = input.int(2,    "Price decimals",            minval=0,   maxval=8,   group="Structure")
slBuf   = input.float(0.5,"Stop Loss buffer %",        minval=0.1, maxval=5.0, step=0.1, group="Structure")
minRR   = input.float(1.5,"Min R:R ratio",             minval=0.5, maxval=10.0,step=0.1, group="Structure")

emaFast = input.int(9,  "EMA Fast",  minval=2, group="Indicators")
emaSlow = input.int(21, "EMA Slow",  minval=2, group="Indicators")
smaLen  = input.int(50, "SMA Trend", minval=2, group="Indicators")
rsiLen  = input.int(14, "RSI",       minval=2, group="Indicators")
volLen  = input.int(20, "Volume MA", minval=5, group="Indicators")

showEMAs    = input.bool(true,  "Show EMA/SMA",              group="Display")
showIndvFib = input.bool(true,  "Show individual Fib zones",  group="Display")
showFibLvls = input.bool(false, "Show all Fib level lines",   group="Display")

// ────────────────────────────────────────────
// 2. INDICATORS
// ────────────────────────────────────────────
ema9   = ta.ema(close, emaFast)
ema21  = ta.ema(close, emaSlow)
sma50  = ta.sma(close, smaLen)
rsiVal = ta.rsi(close, rsiLen)
volMA  = ta.sma(volume, volLen)

plot(showEMAs ? ema9  : na, "EMA Fast",  color=color.new(color.aqua,   10), linewidth=1)
plot(showEMAs ? ema21 : na, "EMA Slow",  color=color.new(color.orange, 10), linewidth=1)
plot(showEMAs ? sma50 : na, "SMA Trend", color=color.new(color.purple, 10), linewidth=2)

// ────────────────────────────────────────────
// 3. SWING STRUCTURE — 3 lookbacks
// ────────────────────────────────────────────
// Lookback 1 — major
hi1  = ta.highest(high, lb1)
lo1  = ta.lowest(low,  lb1)
rng1 = hi1 - lo1

// Lookback 2 — intermediate
hi2  = ta.highest(high, lb2)
lo2  = ta.lowest(low,  lb2)
rng2 = hi2 - lo2

// Lookback 3 — minor
hi3  = ta.highest(high, lb3)
lo3  = ta.lowest(low,  lb3)
rng3 = hi3 - lo3

// ────────────────────────────────────────────
// 4. BUY ZONES per structure  (0.618 – 0.786)
//    SELL ZONES per structure (0.236 – 0.382)
// ────────────────────────────────────────────
// Structure 1
buyHi1  = hi1 - rng1 * 0.618
buyLo1  = hi1 - rng1 * 0.786
selHi1  = hi1 - rng1 * 0.236
selLo1  = hi1 - rng1 * 0.382

// Structure 2
buyHi2  = hi2 - rng2 * 0.618
buyLo2  = hi2 - rng2 * 0.786
selHi2  = hi2 - rng2 * 0.236
selLo2  = hi2 - rng2 * 0.382

// Structure 3
buyHi3  = hi3 - rng3 * 0.618
buyLo3  = hi3 - rng3 * 0.786
selHi3  = hi3 - rng3 * 0.236
selLo3  = hi3 - rng3 * 0.382

// ────────────────────────────────────────────
// 5. OVERLAP DETECTION
//    Overlap of [aLo,aHi] and [bLo,bHi]:
//      overlapLo = max(aLo, bLo)
//      overlapHi = min(aHi, bHi)
//      valid if overlapLo < overlapHi
// ────────────────────────────────────────────
f_overlap(aLo, aHi, bLo, bHi) =>
    oLo = math.max(aLo, bLo)
    oHi = math.min(aHi, bHi)
    valid = oLo < oHi
    [oLo, oHi, valid]

// BUY overlaps
[bOv12Lo, bOv12Hi, bOv12]  = f_overlap(buyLo1, buyHi1, buyLo2, buyHi2)
[bOv13Lo, bOv13Hi, bOv13]  = f_overlap(buyLo1, buyHi1, buyLo3, buyHi3)
[bOv23Lo, bOv23Hi, bOv23]  = f_overlap(buyLo2, buyHi2, buyLo3, buyHi3)
[bOv123Lo,bOv123Hi,bOv123] = f_overlap(bOv12Lo, bOv12Hi, buyLo3, buyHi3)

// SELL overlaps
[sOv12Lo, sOv12Hi, sOv12]  = f_overlap(selLo1, selHi1, selLo2, selHi2)
[sOv13Lo, sOv13Hi, sOv13]  = f_overlap(selLo1, selHi1, selLo3, selHi3)
[sOv23Lo, sOv23Hi, sOv23]  = f_overlap(selLo2, selHi2, selLo3, selHi3)
[sOv123Lo,sOv123Hi,sOv123] = f_overlap(sOv12Lo, sOv12Hi, selLo3, selHi3)

// Count how many structures align for buy/sell
buyConf  = (bOv12 ? 1 : 0) + (bOv13 ? 1 : 0) + (bOv23 ? 1 : 0)
sellConf = (sOv12 ? 1 : 0) + (sOv13 ? 1 : 0) + (sOv23 ? 1 : 0)

// Best confluence zone boundaries
bestBuyLo  = bOv123 ? bOv123Lo : bOv12 ? bOv12Lo : bOv13 ? bOv13Lo : bOv23 ? bOv23Lo : buyLo1
bestBuyHi  = bOv123 ? bOv123Hi : bOv12 ? bOv12Hi : bOv13 ? bOv13Hi : bOv23 ? bOv23Hi : buyHi1
bestSellLo = sOv123 ? sOv123Lo : sOv12 ? sOv12Lo : sOv13 ? sOv13Lo : sOv23 ? sOv23Lo : selLo1
bestSellHi = sOv123 ? sOv123Hi : sOv12 ? sOv12Hi : sOv13 ? sOv13Hi : sOv23 ? sOv23Hi : selHi1

// ────────────────────────────────────────────
// 6. BIAS SCORE
// ────────────────────────────────────────────
rsiNorm  = (rsiVal - 50.0) / 50.0
rsiBias  = -rsiNorm * 30.0
emaBias  = ema9  > ema21 ?  20.0 : -20.0
smaBias  = close > sma50 ?  15.0 : -15.0
emaMom   = (ema9 - ema9[3]) > 0     ?  5.0 : -5.0
rsiMom   = (rsiVal - rsiVal[3]) > 0 ?  5.0 : -5.0
fibPos1  = rng1 > 0 ? (close - lo1) / rng1 : 0.5
fibBias  = (0.5 - fibPos1) * 20.0
volBull  = volume > volMA and close >= open
volBear  = volume > volMA and close <  open
volBias  = volBull ? 15.0 : volBear ? -15.0 : 0.0

totalBias = math.max(-90.0, math.min(90.0, rsiBias + emaBias + smaBias + emaMom + rsiMom + fibBias + volBias))
buyPct    = math.max(5, math.min(95, math.round(50.0 + totalBias * 0.5)))
sellPct   = math.max(5, math.min(95, math.round(50.0 - totalBias * 0.5)))

// ────────────────────────────────────────────
// 7. ZONE STATUS
// ────────────────────────────────────────────
buyActive  = close >= bestBuyLo  and close <= bestBuyHi
buyWaiting = close >  bestBuyHi
buyExpired = close <  bestBuyLo

sellActive  = close >= bestSellLo and close <= bestSellHi
sellWaiting = close <  bestSellLo
sellExpired = close >  bestSellHi

// ────────────────────────────────────────────
// 8. ENTRY / TP / SL
// ────────────────────────────────────────────
// Volume POC (200 bar)
var float poc = na
if barstate.islast and rng1 > 0
    bkts  = 20
    bktSz = rng1 / bkts
    float maxV = 0.0
    float pocP = (hi1 + lo1) / 2.0
    for b = 0 to bkts - 1
        bLo = lo1 + b * bktSz
        bHi = bLo + bktSz
        bV  = 0.0
        for i = 0 to lb1 - 1
            if high[i] >= bLo and low[i] <= bHi
                bV := bV + volume[i]
        if bV > maxV
            maxV := bV
            pocP := (bLo + bHi) / 2.0
    poc := pocP

pocInBuy  = not na(poc) and poc >= bestBuyLo  and poc <= bestBuyHi
pocInSell = not na(poc) and poc >= bestSellLo and poc <= bestSellHi

buyEntry  = pocInBuy  ? poc : bestBuyLo
sellEntry = pocInSell ? poc : bestSellHi

// BUY targets — move up through fib levels
buyTP1    = bestBuyHi
buyTP2    = hi1 - rng1 * 0.382
buyTP3    = hi1 - rng1 * 0.236
buySL     = buyEntry  * (1.0 - slBuf / 100.0)

// SELL targets — move down through fib levels
sellTP1   = bestSellLo
sellTP2   = hi1 - rng1 * 0.618
sellTP3   = hi1 - rng1 * 0.786
sellSL    = sellEntry * (1.0 + slBuf / 100.0)

f_rr(entry, tgt, sl) =>
    risk   = math.abs(entry - sl)
    reward = math.abs(tgt   - entry)
    risk > 0 ? math.round(reward / risk, 1) : 0.0

f_pct(frm, tgt) =>
    str.tostring(math.round(math.abs(tgt - frm) / frm * 100.0, 2)) + "%"

buyBestRR  = f_rr(buyEntry,  buyTP3,  buySL)
sellBestRR = f_rr(sellEntry, sellTP3, sellSL)
buyValidRR  = buyBestRR  >= minRR
sellValidRR = sellBestRR >= minRR

// ────────────────────────────────────────────
// 9. DRAW
// ────────────────────────────────────────────
if barstate.islast
    right = bar_index + futBars
    left  = bar_index - lb1

    // ── Individual structure zones (faint background) ──
    if showIndvFib
        // Structure 1 — major (most transparent)
        box.new(bar_index, buyHi1, right, buyLo1, bgcolor=color.new(color.lime, 96), border_color=color.new(color.lime, 70), border_width=1)
        box.new(bar_index, selHi1, right, selLo1, bgcolor=color.new(color.red,  96), border_color=color.new(color.red,  70), border_width=1)
        label.new(bar_index + 2, (buyHi1 + buyLo1) / 2, "S1 200", color=color.new(color.lime, 80), textcolor=color.new(color.lime, 40), style=label.style_label_right, size=size.tiny)
        label.new(bar_index + 2, (selHi1 + selLo1) / 2, "S1 200", color=color.new(color.red,  80), textcolor=color.new(color.red,  40), style=label.style_label_right, size=size.tiny)

        // Structure 2 — intermediate
        box.new(bar_index, buyHi2, right, buyLo2, bgcolor=color.new(color.lime, 93), border_color=color.new(color.lime, 60), border_width=1)
        box.new(bar_index, selHi2, right, selLo2, bgcolor=color.new(color.red,  93), border_color=color.new(color.red,  60), border_width=1)
        label.new(bar_index + 2, (buyHi2 + buyLo2) / 2, "S2 100", color=color.new(color.lime, 75), textcolor=color.new(color.lime, 30), style=label.style_label_right, size=size.tiny)
        label.new(bar_index + 2, (selHi2 + selLo2) / 2, "S2 100", color=color.new(color.red,  75), textcolor=color.new(color.red,  30), style=label.style_label_right, size=size.tiny)

        // Structure 3 — minor
        box.new(bar_index, buyHi3, right, buyLo3, bgcolor=color.new(color.lime, 90), border_color=color.new(color.lime, 50), border_width=1)
        box.new(bar_index, selHi3, right, selLo3, bgcolor=color.new(color.red,  90), border_color=color.new(color.red,  50), border_width=1)
        label.new(bar_index + 2, (buyHi3 + buyLo3) / 2, "S3 50",  color=color.new(color.lime, 70), textcolor=color.new(color.lime, 20), style=label.style_label_right, size=size.tiny)
        label.new(bar_index + 2, (selHi3 + selLo3) / 2, "S3 50",  color=color.new(color.red,  70), textcolor=color.new(color.red,  20), style=label.style_label_right, size=size.tiny)

    // ── Confluence BUY zone ──
    buyConfTxt  = bOv123 ? "3/3 STRUCTURES" : buyConf >= 1 ? "2/3 STRUCTURES" : "1/3 STRUCTURE"
    buyStrength = bOv123 ? 55 : buyConf >= 1 ? 72 : 85
    buyBorderA  = bOv123 ? 0  : buyConf >= 1 ? 15 : 35

    buyStatTxt  = buyActive ? "ACTIVE - ENTER NOW" : buyWaiting ? "WAITING - NOT YET" : "EXPIRED - IGNORE"
    buyStatCol  = buyActive ? color.lime : buyWaiting ? color.yellow : color.gray
    buyFade     = buyExpired ? 80 : 0
    buyRRtag    = buyValidRR ? "" : "  LOW R:R - SKIP"
    buyW        = buyActive ? 3 : buyWaiting ? 2 : 1

    box.new(bar_index, bestBuyHi, right, bestBuyLo,
            bgcolor      = color.new(color.lime, buyExpired ? 97 : buyStrength),
            border_color = color.new(buyStatCol, buyExpired ? 80 : buyBorderA),
            border_width = buyW)

    label.new(bar_index + math.round(futBars * 0.3), (bestBuyHi + bestBuyLo) / 2,
              "BUY " + str.tostring(buyPct) + "%  " + buyConfTxt + "\n" + buyStatTxt + buyRRtag,
              color    = color.new(buyStatCol, buyExpired ? 75 : 10),
              textcolor= buyExpired ? color.new(color.gray, 50) : color.black,
              style    = label.style_label_center,
              size     = buyExpired ? size.small : size.large)

    // BUY levels (only if not expired)
    if not buyExpired
        line.new(bar_index, buyEntry, right, buyEntry, color=color.new(color.lime,        buyFade), width=buyW)
        line.new(bar_index, buyTP1,   right, buyTP1,   color=color.new(color.lime,   math.min(buyFade+20,85)), width=buyW)
        line.new(bar_index, buyTP2,   right, buyTP2,   color=color.new(color.lime,   math.min(buyFade+35,88)), width=buyW)
        line.new(bar_index, buyTP3,   right, buyTP3,   color=color.new(color.lime,   math.min(buyFade+50,90)), width=buyW)
        line.new(bar_index, buySL,    right, buySL,    color=color.new(color.red,         buyFade), width=buyW, style=line.style_dotted)

        label.new(right, buyEntry, "BUY ENTRY  " + str.tostring(math.round(buyEntry, pDec)),                                                                                                              color=color.new(color.lime,       buyFade), textcolor=color.black, style=label.style_label_left, size=size.normal)
        label.new(right, buyTP1,   "TP1  "        + str.tostring(math.round(buyTP1,   pDec)) + "  (+" + f_pct(buyEntry, buyTP1) + ")  R:R " + str.tostring(f_rr(buyEntry, buyTP1, buySL)) + ":1", color=color.new(color.lime,  math.min(buyFade+20,85)), textcolor=color.black, style=label.style_label_left, size=size.small)
        label.new(right, buyTP2,   "TP2  "        + str.tostring(math.round(buyTP2,   pDec)) + "  (+" + f_pct(buyEntry, buyTP2) + ")  R:R " + str.tostring(f_rr(buyEntry, buyTP2, buySL)) + ":1", color=color.new(color.lime,  math.min(buyFade+35,88)), textcolor=color.black, style=label.style_label_left, size=size.small)
        label.new(right, buyTP3,   "TP3  "        + str.tostring(math.round(buyTP3,   pDec)) + "  (+" + f_pct(buyEntry, buyTP3) + ")  R:R " + str.tostring(f_rr(buyEntry, buyTP3, buySL)) + ":1", color=color.new(color.lime,  math.min(buyFade+50,90)), textcolor=color.black, style=label.style_label_left, size=size.small)
        label.new(right, buySL,    "BUY SL  "     + str.tostring(math.round(buySL,    pDec)) + "  (-"  + f_pct(buyEntry, buySL)  + ")",                                                               color=color.new(color.red,        buyFade), textcolor=color.white, style=label.style_label_left, size=size.small)

    // ── Confluence SELL zone ──
    sellConfTxt  = sOv123 ? "3/3 STRUCTURES" : sellConf >= 1 ? "2/3 STRUCTURES" : "1/3 STRUCTURE"
    sellStrength = sOv123 ? 55 : sellConf >= 1 ? 72 : 85
    sellBorderA  = sOv123 ? 0  : sellConf >= 1 ? 15 : 35

    sellStatTxt  = sellActive ? "ACTIVE - ENTER NOW" : sellWaiting ? "WAITING - NOT YET" : "EXPIRED - IGNORE"
    sellStatCol  = sellActive ? color.red : sellWaiting ? color.orange : color.gray
    sellFade     = sellExpired ? 80 : 0
    sellRRtag    = sellValidRR ? "" : "  LOW R:R - SKIP"
    sellW        = sellActive ? 3 : sellWaiting ? 2 : 1

    box.new(bar_index, bestSellHi, right, bestSellLo,
            bgcolor      = color.new(color.red, sellExpired ? 97 : sellStrength),
            border_color = color.new(sellStatCol, sellExpired ? 80 : sellBorderA),
            border_width = sellW)

    label.new(bar_index + math.round(futBars * 0.3), (bestSellHi + bestSellLo) / 2,
              "SELL " + str.tostring(sellPct) + "%  " + sellConfTxt + "\n" + sellStatTxt + sellRRtag,
              color    = color.new(sellStatCol, sellExpired ? 75 : 10),
              textcolor= sellExpired ? color.new(color.gray, 50) : color.white,
              style    = label.style_label_center,
              size     = sellExpired ? size.small : size.large)

    // SELL levels (only if not expired)
    if not sellExpired
        line.new(bar_index, sellEntry, right, sellEntry, color=color.new(color.red,         sellFade), width=sellW)
        line.new(bar_index, sellTP1,   right, sellTP1,   color=color.new(color.red,    math.min(sellFade+20,85)), width=sellW)
        line.new(bar_index, sellTP2,   right, sellTP2,   color=color.new(color.red,    math.min(sellFade+35,88)), width=sellW)
        line.new(bar_index, sellTP3,   right, sellTP3,   color=color.new(color.red,    math.min(sellFade+50,90)), width=sellW)
        line.new(bar_index, sellSL,    right, sellSL,    color=color.new(color.maroon,      sellFade), width=sellW, style=line.style_dotted)

        label.new(right, sellEntry, "SELL ENTRY  " + str.tostring(math.round(sellEntry, pDec)),                                                                                                                  color=color.new(color.red,        sellFade), textcolor=color.white, style=label.style_label_left, size=size.normal)
        label.new(right, sellTP1,   "TP1  "         + str.tostring(math.round(sellTP1,   pDec)) + "  (+" + f_pct(sellEntry, sellTP1) + ")  R:R " + str.tostring(f_rr(sellEntry, sellTP1, sellSL)) + ":1", color=color.new(color.red,   math.min(sellFade+20,85)), textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(right, sellTP2,   "TP2  "         + str.tostring(math.round(sellTP2,   pDec)) + "  (+" + f_pct(sellEntry, sellTP2) + ")  R:R " + str.tostring(f_rr(sellEntry, sellTP2, sellSL)) + ":1", color=color.new(color.red,   math.min(sellFade+35,88)), textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(right, sellTP3,   "TP3  "         + str.tostring(math.round(sellTP3,   pDec)) + "  (+" + f_pct(sellEntry, sellTP3) + ")  R:R " + str.tostring(f_rr(sellEntry, sellTP3, sellSL)) + ":1", color=color.new(color.red,   math.min(sellFade+50,90)), textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(right, sellSL,    "SELL SL  "     + str.tostring(math.round(sellSL,    pDec)) + "  (-"  + f_pct(sellEntry, sellSL)  + ")",                                                                   color=color.new(color.maroon,     sellFade), textcolor=color.white, style=label.style_label_left, size=size.small)

    // ── POC line ──
    if not na(poc)
        line.new(left, poc, right, poc, color=color.new(color.fuchsia, 15), width=2, style=line.style_dashed)
        label.new(bar_index, poc, "POC  " + str.tostring(math.round(poc, pDec)),
                  color=color.new(color.fuchsia, 25), textcolor=color.fuchsia,
                  style=label.style_label_right, size=size.small)

// ────────────────────────────────────────────
// 10. CONFIRMED ENTRY ARROWS
// ────────────────────────────────────────────
confirmedBuy  = buyActive  and buyPct  >= 60 and rsiVal <= 50 and ema9 >= ema21 and buyValidRR
confirmedSell = sellActive and sellPct >= 60 and rsiVal >= 50 and ema9 <= ema21 and sellValidRR

plotshape(confirmedBuy,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.large)
plotshape(confirmedSell, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.large)

// ────────────────────────────────────────────
// 11. INFO TABLE
// ────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 16,
     bgcolor=color.new(color.black, 50), border_color=color.new(color.gray, 40),
     border_width=1, frame_width=1, frame_color=color.new(color.gray, 30))

if barstate.islast
    // Indicators
    table.cell(tbl, 0, 0, "Indicator",   text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy, 25))
    table.cell(tbl, 1, 0, "Value",       text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy, 25))

    rsiC = rsiVal <= 40 ? color.lime : rsiVal >= 60 ? color.red : color.silver
    table.cell(tbl, 0, 1, "RSI",         text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(math.round(rsiVal, 1)), text_color=rsiC, text_size=size.small)

    emaC = ema9 > ema21 ? color.lime : color.red
    table.cell(tbl, 0, 2, "EMA Align",   text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 2, ema9 > ema21 ? "Bullish" : "Bearish", text_color=emaC, text_size=size.small)

    smaC = close > sma50 ? color.lime : color.red
    table.cell(tbl, 0, 3, "vs SMA50",    text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 3, close > sma50 ? "Above" : "Below", text_color=smaC, text_size=size.small)

    volC = volume > volMA ? color.lime : color.gray
    table.cell(tbl, 0, 4, "Volume",      text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 4, volume > volMA ? "Above avg" : "Normal", text_color=volC, text_size=size.small)

    table.cell(tbl, 0, 5, "POC",         text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 5, not na(poc) ? str.tostring(math.round(poc, pDec)) : "...", text_color=color.fuchsia, text_size=size.small)

    // BUY section
    bStat = buyActive ? "ACTIVE" : buyWaiting ? "WAITING" : "EXPIRED"
    bSCol = buyActive ? color.lime : buyWaiting ? color.yellow : color.gray
    bConf = bOv123 ? "3/3" : buyConf >= 1 ? "2/3" : "1/3"
    table.cell(tbl, 0, 6,  "BUY " + str.tostring(buyPct) + "%  " + bConf, text_color=bSCol, text_size=size.small, bgcolor=color.new(color.green, 80))
    table.cell(tbl, 1, 6,  bStat, text_color=bSCol, text_size=size.small, bgcolor=color.new(color.green, 80))
    table.cell(tbl, 0, 7,  "Entry",  text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 7,  str.tostring(math.round(buyEntry, pDec)), text_color=color.lime, text_size=size.small)
    table.cell(tbl, 0, 8,  "TP1",    text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 8,  str.tostring(math.round(buyTP1, pDec)) + "  (+" + f_pct(buyEntry, buyTP1) + ")", text_color=color.lime, text_size=size.small)
    table.cell(tbl, 0, 9,  "TP2",    text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 9,  str.tostring(math.round(buyTP2, pDec)) + "  (+" + f_pct(buyEntry, buyTP2) + ")", text_color=color.lime, text_size=size.small)
    table.cell(tbl, 0, 10, "TP3",    text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 10, str.tostring(math.round(buyTP3, pDec)) + "  (+" + f_pct(buyEntry, buyTP3) + ")", text_color=color.lime, text_size=size.small)
    table.cell(tbl, 0, 11, "SL / R:R", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 11, str.tostring(math.round(buySL, pDec)) + "  " + str.tostring(buyBestRR) + ":1", text_color=buyValidRR ? color.lime : color.orange, text_size=size.small)

    // SELL section
    sStat = sellActive ? "ACTIVE" : sellWaiting ? "WAITING" : "EXPIRED"
    sSCol = sellActive ? color.red : sellWaiting ? color.orange : color.gray
    sConf = sOv123 ? "3/3" : sellConf >= 1 ? "2/3" : "1/3"
    table.cell(tbl, 0, 12, "SELL " + str.tostring(sellPct) + "%  " + sConf, text_color=sSCol, text_size=size.small, bgcolor=color.new(color.maroon, 60))
    table.cell(tbl, 1, 12, sStat, text_color=sSCol, text_size=size.small, bgcolor=color.new(color.maroon, 60))
    table.cell(tbl, 0, 13, "Entry",  text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 13, str.tostring(math.round(sellEntry, pDec)), text_color=color.red, text_size=size.small)
    table.cell(tbl, 0, 14, "TP1",    text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 14, str.tostring(math.round(sellTP1, pDec)) + "  (+" + f_pct(sellEntry, sellTP1) + ")", text_color=color.red, text_size=size.small)
    table.cell(tbl, 0, 15, "SL / R:R", text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 15, str.tostring(math.round(sellSL, pDec)) + "  " + str.tostring(sellBestRR) + ":1", text_color=sellValidRR ? color.lime : color.orange, text_size=size.small)

// ────────────────────────────────────────────
// 12. ALERTS
// ────────────────────────────────────────────
alertcondition(confirmedBuy,                  title="BUY Active",  message="BUY ZONE ACTIVE - confluence zone with valid R:R")
alertcondition(confirmedSell,                 title="SELL Active", message="SELL ZONE ACTIVE - confluence zone with valid R:R")
alertcondition(confirmedBuy or confirmedSell, title="Any Active",  message="ZONE ACTIVE - check chart now")
````
