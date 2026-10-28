# Order Flow System [v6]

- url: https://www.tradingview.com/script/Tks0ic0u-Order-Flow-System-v6/
- type: indicator
- pine_id: PUB;ea0a63b170ca4575959b44962ea05931
- version: 1.0

## Description

What it does overall

It's a separate panel indicator that sits below your price chart and tracks who is in control of the market — buyers or sellers — on every single bar using volume analysis and smart money concepts.

1. Buy/Sell Volume Estimation

Since Pine Script can't see actual tick data, it estimates which side was more aggressive on each bar. If price closed near the high, most volume was likely buying. If it closed near the low, most was selling. The formula splits the bar's total volume proportionally based on where price closed within the high/low range.
2. Bar Delta Histogram

The difference between estimated buy volume and sell volume on each bar. Green bars mean buyers were more aggressive, red bars mean sellers were. The taller the bar, the stronger the imbalance between the two sides.
3. Cumulative Delta (CVD)

It adds up every bar's delta over time into a running total. This line shows you the overall trend of buying vs selling pressure across the session. When CVD is rising, buyers are consistently in control. When it's falling, sellers are. The EMA of CVD acts as a signal line — when CVD crosses above it that's bullish, below is bearish.
4. Volume Imbalance

When buyers dominate more than 60% of a bar's volume the background flashes green. When sellers dominate more than 60% it flashes red. This highlights bars where one side completely overwhelmed the other.
5. Large Print Detection

When a bar's volume is significantly larger than the 20-bar average, it gets labeled. These are institutional-sized prints — someone placed a very large order. The label shows the volume size and whether it was net buying or selling.
6. Absorption Detection

This is one of the more powerful signals. It looks for situations where a large amount of selling is happening but price refuses to go down — or large buying but price won't go up. That means the opposing side is quietly absorbing all those orders, which often precedes a reversal.
7. SMT Divergence

Compares your chart's swing highs and lows against a correlated market like NQ vs ES. If ES makes a new low but NQ doesn't confirm it, smart money likely didn't participate in that move — signaling the low may be fake and a reversal is coming. Same logic in reverse for highs. A dashed line connects the two swing points and a label marks the signal.
8. Dashboard Table

A live readout in the top right corner showing Bar Delta, Cumulative Delta, Buy%, Sell%, Volume, CVD Signal, SMT Signal, and which symbol it's comparing against. All colors are fully customizable in the settings.
9. Alerts

Ten alert conditions covering every major signal — large prints, imbalance, absorption, CVD crossovers, and both SMT directions — so you can get notified without watching the screen.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © OrderFlow System v1.0 — Pine Script v6
// Tick-based Order Flow: Delta, Imbalance, Footprint, Cumulative Delta + SMT Divergence

//@version=6
indicator("Order Flow System [v6]", shorttitle="OFS", overlay=false, max_bars_back=500, max_lines_count=300, max_labels_count=300)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_delta   = "Delta Settings"
grp_imb     = "Imbalance Settings"
grp_display = "Display"
grp_smt     = "SMT Divergence"
grp_colors  = "Colors"

// Delta
deltaLen        = input.int(14,    "Delta Lookback (bars)",        minval=1,   maxval=200, group=grp_delta)
bigPrintThresh  = input.int(50,    "Large Print Alert (size ≥)",   minval=1,   maxval=999, group=grp_delta)
showBigPrints   = input.bool(true, "Show Large Print Labels",                              group=grp_delta)

// Imbalance
imbThresh       = input.float(60.0, "Imbalance Threshold (%)",     minval=50.0, maxval=99.0, step=0.5, group=grp_imb)
showImbalance   = input.bool(true,  "Highlight Imbalance Bars",                              group=grp_imb)

// Display
showCumDelta    = input.bool(true,  "Show Cumulative Delta Line",  group=grp_display)
showDeltaHist   = input.bool(true,  "Show Delta Histogram",        group=grp_display)
showPoC         = input.bool(true,  "Show Volume POC Line",        group=grp_display)
showCVD_MA      = input.bool(true,  "Show CVD Moving Average",     group=grp_display)
cvdMaLen        = input.int(20,     "CVD MA Length",  minval=2,    group=grp_display)
showAbsorption  = input.bool(true,  "Show Absorption Signals",     group=grp_display)

// ─────────────────────────────────────────────
// SMT DIVERGENCE INPUTS
// SMT (Smart Money Technique) detects divergence between two
// correlated instruments — e.g. ES vs NQ, or GC vs SI.
// Bullish SMT: Chart makes a lower low, correlated symbol does NOT → hidden strength
// Bearish SMT: Chart makes a higher high, correlated symbol does NOT → hidden weakness
// ─────────────────────────────────────────────
showSMT         = input.bool(true,       "Show SMT Divergence Signals",           group=grp_smt)
smtSymbol       = input.symbol("NQ1!",   "Correlated Symbol (e.g. NQ1!, ES1!)",   group=grp_smt)
smtLookback     = input.int(10,          "Swing Lookback (bars)",  minval=3, maxval=50, group=grp_smt)
smtShowLabels   = input.bool(true,       "Show SMT Labels",                        group=grp_smt)
smtShowLines    = input.bool(true,       "Show SMT Divergence Lines",              group=grp_smt)
smtBullCol      = input.color(color.new(#00E5FF, 0),  "Bullish SMT Color",        group=grp_smt)
smtBearCol      = input.color(color.new(#FF6B6B, 0),  "Bearish SMT Color",        group=grp_smt)

// Colors
colBuy          = input.color(color.new(#1D9E75, 0),  "Buy / Positive",       group=grp_colors)
colSell         = input.color(color.new(#D85A30, 0),  "Sell / Negative",      group=grp_colors)
colNeutral      = input.color(color.new(#7F77DD, 0),  "Neutral / CVD",        group=grp_colors)
colPOC          = input.color(color.new(#FAC775, 80), "POC Line",             group=grp_colors)
colTableBg      = input.color(color.new(#000000, 80), "Table Background",     group=grp_colors)
colTableHdrBg   = input.color(color.new(#000080, 60), "Table Header Bg",      group=grp_colors)
colTableHdrTxt  = input.color(color.new(#FFFFFF,  0), "Table Header Text",    group=grp_colors)
colTableLbl     = input.color(color.new(#CCCCCC, 20), "Table Label Text",     group=grp_colors)
colTableVal     = input.color(color.new(#FFFFFF,  0), "Table Value Text",     group=grp_colors)
colTableBorder  = input.color(color.new(#888888, 70), "Table Border",         group=grp_colors)

// ─────────────────────────────────────────────
// TICK VOLUME APPROXIMATION
// Pine Script cannot access real tick-by-tick data.
// We approximate buy/sell volume using intrabar price action:
//   - Up-close ticks  → buy volume  ≈ volume * (close - low)  / (high - low)
//   - Down-close ticks → sell volume ≈ volume * (high - close) / (high - low)
// This matches the standard "tick rule" approximation used by most
// retail order flow tools (Bookmap, Sierra Chart free mode, etc.)
// ─────────────────────────────────────────────

// Guard against doji (high == low) to avoid division by zero
hlRange     = high - low
buyVolEst   = hlRange > 0 ? volume * (close - low)  / hlRange : volume * 0.5
sellVolEst  = hlRange > 0 ? volume * (high - close) / hlRange : volume * 0.5

barDelta    = buyVolEst - sellVolEst   // Positive = net buying, Negative = net selling
totalVol    = volume

// ─────────────────────────────────────────────
// CUMULATIVE DELTA (CVD)
// ─────────────────────────────────────────────
var float cvd = 0.0
cvd += barDelta

cvdMA       = ta.ema(cvd, cvdMaLen)
cvdColor    = cvd >= cvd[1] ? colBuy : colSell

// ─────────────────────────────────────────────
// DELTA HISTOGRAM
// ─────────────────────────────────────────────
deltaColor  = barDelta >= 0 ? colBuy : colSell
deltaAlpha  = color.new(deltaColor, 30)

// ─────────────────────────────────────────────
// VOLUME IMBALANCE DETECTION
// Buy% = buyVol / totalVol * 100
// ─────────────────────────────────────────────
buyPct      = totalVol > 0 ? buyVolEst / totalVol * 100 : 50.0
sellPct     = 100.0 - buyPct
isImbalance = showImbalance and (buyPct >= imbThresh or sellPct >= imbThresh)
imbSide     = buyPct >= imbThresh ? 1 : -1   // 1 = buy dom, -1 = sell dom

// ─────────────────────────────────────────────
// VOLUME PROFILE — rolling POC approximation
// ─────────────────────────────────────────────
vwap        = ta.vwap(hlc3)
pocProxy    = ta.highest(volume, deltaLen) == volume ? close : ta.sma(vwap, deltaLen)

// ─────────────────────────────────────────────
// LARGE PRINT DETECTION
// ─────────────────────────────────────────────
avgVol       = ta.sma(volume, 20)
isLargePrint = showBigPrints and (volume >= avgVol * (bigPrintThresh / 10.0))

// ─────────────────────────────────────────────
// ABSORPTION DETECTION
// ─────────────────────────────────────────────
priceFlat       = math.abs(close - close[1]) <= syminfo.mintick * 2
avgBarDelta     = ta.sma(barDelta, 10)
bullAbsorption  = barDelta < -math.abs(avgBarDelta) and close >= close[1]
bearAbsorption  = barDelta >  math.abs(avgBarDelta) and close <= close[1]

// ═════════════════════════════════════════════
// SMT DIVERGENCE ENGINE
// ═════════════════════════════════════════════

// Pull correlated symbol OHLC
smtHigh  = request.security(smtSymbol, timeframe.period, high,  lookahead=barmerge.lookahead_off)
smtLow   = request.security(smtSymbol, timeframe.period, low,   lookahead=barmerge.lookahead_off)
smtClose = request.security(smtSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)

// Swing high/low detection on BOTH instruments using pivot logic
// Pivot high = bar whose high is highest over [lookback] bars each side
swingHigh     = ta.pivothigh(high,    smtLookback, smtLookback)
swingLow      = ta.pivotlow (low,     smtLookback, smtLookback)
smtSwingHigh  = ta.pivothigh(smtHigh, smtLookback, smtLookback)
smtSwingLow   = ta.pivotlow (smtLow,  smtLookback, smtLookback)

// Track last confirmed swing values for comparison
var float lastSwingHigh     = na
var float lastSwingLow      = na
var float lastSmtSwingHigh  = na
var float lastSmtSwingLow   = na
var int   lastSwingHighBar  = na
var int   lastSwingLowBar   = na

// Update last swings when a new pivot is confirmed
if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighBar := bar_index - smtLookback

if not na(swingLow)
    lastSwingLow    := swingLow
    lastSwingLowBar := bar_index - smtLookback

if not na(smtSwingHigh)
    lastSmtSwingHigh := smtSwingHigh

if not na(smtSwingLow)
    lastSmtSwingLow := smtSwingLow

// ─── BEARISH SMT ───────────────────────────────────────────────
// Chart makes a HIGHER high vs its previous swing high
// BUT correlated symbol makes a LOWER high (fails to confirm)
// → Smart money distributed into chart's new high = weakness
bearSMT = showSMT
         and not na(swingHigh)
         and not na(lastSmtSwingHigh)
         and swingHigh    > lastSwingHigh[smtLookback * 2]   // chart: higher high
         and smtSwingHigh < lastSmtSwingHigh                  // corr:  lower high  (divergence)

// ─── BULLISH SMT ───────────────────────────────────────────────
// Chart makes a LOWER low vs its previous swing low
// BUT correlated symbol makes a HIGHER low (refuses to confirm)
// → Smart money accumulated into chart's new low = strength
bullSMT = showSMT
         and not na(swingLow)
         and not na(lastSmtSwingLow)
         and swingLow    < lastSwingLow[smtLookback * 2]     // chart: lower low
         and smtSwingLow > lastSmtSwingLow                    // corr:  higher low  (divergence)

// SMT label offset — placed at pivot confirmation bar
smtLabelOffset = smtLookback

// Draw SMT labels at pivot confirmation point
if bullSMT and smtShowLabels
    label.new(bar_index - smtLabelOffset, low[smtLabelOffset],
              "SMT↑\n" + syminfo.ticker + " LL\n" + smtSymbol + " HL",
              style     = label.style_label_up,
              color     = color.new(smtBullCol, 70),
              textcolor = smtBullCol,
              size      = size.small,
              xloc      = xloc.bar_index,
              yloc      = yloc.price)

if bearSMT and smtShowLabels
    label.new(bar_index - smtLabelOffset, high[smtLabelOffset],
              "SMT↓\n" + syminfo.ticker + " HH\n" + smtSymbol + " LH",
              style     = label.style_label_down,
              color     = color.new(smtBearCol, 70),
              textcolor = smtBearCol,
              size      = size.small,
              xloc      = xloc.bar_index,
              yloc      = yloc.price)

// Draw divergence line connecting the two swing points
var line smtLine = na
if bullSMT and smtShowLines
    smtLine := line.new(bar_index - smtLabelOffset - smtLookback, low[smtLabelOffset + smtLookback],
                        bar_index - smtLabelOffset,               low[smtLabelOffset],
                        color=smtBullCol, width=2, style=line.style_dashed,
                        xloc=xloc.bar_index)

if bearSMT and smtShowLines
    smtLine := line.new(bar_index - smtLabelOffset - smtLookback, high[smtLabelOffset + smtLookback],
                        bar_index - smtLabelOffset,               high[smtLabelOffset],
                        color=smtBearCol, width=2, style=line.style_dashed,
                        xloc=xloc.bar_index)

// ─────────────────────────────────────────────
// PLOTS — Panel 1: Delta Histogram
// ─────────────────────────────────────────────
plot(showDeltaHist ? barDelta : na,
     title     = "Bar Delta",
     style     = plot.style_histogram,
     color     = deltaAlpha,
     linewidth = 3)

plot(showDeltaHist ? barDelta : na,
     title     = "Bar Delta Line",
     style     = plot.style_line,
     color     = deltaColor,
     linewidth = 1)

// Zero line reference
hline(0, "Zero", color=color.new(color.gray, 60), linestyle=hline.style_dashed, linewidth=1)

// ─────────────────────────────────────────────
// PLOTS — Panel 2: Cumulative Delta
// ─────────────────────────────────────────────
plot(showCumDelta ? cvd : na,
     title     = "Cumulative Delta (CVD)",
     color     = colNeutral,
     linewidth  = 2,
     style     = plot.style_line)

plot(showCumDelta and showCVD_MA ? cvdMA : na,
     title     = "CVD MA",
     color     = color.new(colNeutral, 50),
     linewidth  = 1,
     style     = plot.style_line)

// CVD fill between line and MA for visual clarity
p1 = plot(showCumDelta ? cvd   : na, display=display.none)
p2 = plot(showCumDelta ? cvdMA : na, display=display.none)
fill(p1, p2,
     color = cvd > cvdMA
             ? color.new(colBuy,  82)
             : color.new(colSell, 82),
     title = "CVD / MA Fill")

// ─────────────────────────────────────────────
// IMBALANCE BAR BACKGROUND
// ─────────────────────────────────────────────
bgcolor(isImbalance
        ? (imbSide == 1
           ? color.new(colBuy,  88)
           : color.new(colSell, 88))
        : na,
        title = "Imbalance Background")

// ─────────────────────────────────────────────
// LARGE PRINT LABELS
// ─────────────────────────────────────────────
if isLargePrint
    lbl = label.new(
         bar_index,
         barDelta,
         "▲ " + str.tostring(math.round(volume / 1000, 1)) + "K",
         style     = barDelta >= 0 ? label.style_label_up   : label.style_label_down,
         color     = barDelta >= 0 ? color.new(colBuy, 70)  : color.new(colSell, 70),
         textcolor = barDelta >= 0 ? colBuy                  : colSell,
         size      = size.tiny)

// ─────────────────────────────────────────────
// ABSORPTION SIGNALS
// ─────────────────────────────────────────────
plotshape(showAbsorption and bullAbsorption,
          title     = "Bull Absorption",
          style     = shape.triangleup,
          location  = location.bottom,
          color     = colBuy,
          size      = size.small,
          text      = "Abs↑",
          textcolor = colBuy)

plotshape(showAbsorption and bearAbsorption,
          title     = "Bear Absorption",
          style     = shape.triangledown,
          location  = location.top,
          color     = colSell,
          size      = size.small,
          text      = "Abs↓",
          textcolor = colSell)

// ─────────────────────────────────────────────
// SMT BACKGROUND FLASH on signal bar
// ─────────────────────────────────────────────
bgcolor(bullSMT ? color.new(smtBullCol, 90) : na, title="Bullish SMT Background")
bgcolor(bearSMT ? color.new(smtBearCol, 90) : na, title="Bearish SMT Background")

// ─────────────────────────────────────────────
// INFO TABLE — top-right dashboard
// ─────────────────────────────────────────────
var table dash = table.new(
     position.top_right, 2, 9,
     bgcolor       = colTableBg,
     border_color  = colTableBorder,
     border_width  = 1,
     frame_color   = colTableBorder,
     frame_width   = 1)

if barstate.islast
    // Header
    table.cell(dash, 0, 0, "ORDER FLOW",
               text_color=colTableHdrTxt, text_size=size.normal,
               bgcolor=colTableHdrBg, text_halign=text.align_center,
               width=10, height=2)
    table.cell(dash, 1, 0, "VALUE",
               text_color=colTableHdrTxt, text_size=size.normal,
               bgcolor=colTableHdrBg, text_halign=text.align_center,
               width=10, height=2)

    // Bar Delta
    table.cell(dash, 0, 1, "Bar Delta",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 1,
               (barDelta >= 0 ? "+" : "") + str.tostring(math.round(barDelta)),
               text_color = barDelta >= 0 ? colBuy : colSell,
               text_size  = size.small, height=2)

    // Cumulative Delta
    table.cell(dash, 0, 2, "Cum. Delta",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 2,
               (cvd >= 0 ? "+" : "") + str.tostring(math.round(cvd)),
               text_color = cvd >= 0 ? colBuy : colSell,
               text_size  = size.small, height=2)

    // Buy %
    table.cell(dash, 0, 3, "Buy %",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 3,
               str.tostring(math.round(buyPct, 1)) + "%",
               text_color = buyPct >= imbThresh ? colBuy : colTableVal,
               text_size  = size.small, height=2)

    // Sell %
    table.cell(dash, 0, 4, "Sell %",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 4,
               str.tostring(math.round(sellPct, 1)) + "%",
               text_color = sellPct >= imbThresh ? colSell : colTableVal,
               text_size  = size.small, height=2)

    // Volume
    table.cell(dash, 0, 5, "Volume",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 5,
               str.tostring(math.round(volume / 1000, 1)) + "K",
               text_color=colTableVal, text_size=size.small, height=2)

    // CVD vs MA signal
    signal = cvd > cvdMA ? "▲ Bullish" : "▼ Bearish"
    sigCol = cvd > cvdMA ? colBuy : colSell
    table.cell(dash, 0, 6, "CVD Signal",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 6, signal,
               text_color=sigCol, text_size=size.small, height=2)

    // SMT Status
    smtStatus = bullSMT ? "▲ Bull SMT" : bearSMT ? "▼ Bear SMT" : "—"
    smtCol    = bullSMT ? smtBullCol   : bearSMT  ? smtBearCol   : colTableVal
    table.cell(dash, 0, 7, "SMT Signal",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 7, smtStatus,
               text_color=smtCol, text_size=size.small, height=2)

    // SMT Corr Symbol
    table.cell(dash, 0, 8, "SMT vs",
               text_color=colTableLbl, text_size=size.small, height=2)
    table.cell(dash, 1, 8, smtSymbol,
               text_color=colTableVal, text_size=size.small, height=2)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(isLargePrint and barDelta > 0,
     title   = "Large Buy Print",
     message = "⚡ Large BUY print detected on {{ticker}} — Volume: {{volume}}")

alertcondition(isLargePrint and barDelta < 0,
     title   = "Large Sell Print",
     message = "⚡ Large SELL print detected on {{ticker}} — Volume: {{volume}}")

alertcondition(isImbalance and imbSide == 1,
     title   = "Buy Imbalance",
     message = "📈 Buy-side imbalance on {{ticker}} — check Buy% on chart")

alertcondition(isImbalance and imbSide == -1,
     title   = "Sell Imbalance",
     message = "📉 Sell-side imbalance on {{ticker}} — check Sell% on chart")

alertcondition(bullAbsorption,
     title   = "Bullish Absorption",
     message = "🟢 Bullish absorption detected on {{ticker}} — Price held vs sell delta")

alertcondition(bearAbsorption,
     title   = "Bearish Absorption",
     message = "🔴 Bearish absorption detected on {{ticker}} — Price held vs buy delta")

alertcondition(ta.crossover(cvd, cvdMA),
     title   = "CVD Crossed Above MA",
     message = "📊 Cumulative Delta crossed ABOVE its MA on {{ticker}}")

alertcondition(ta.crossunder(cvd, cvdMA),
     title   = "CVD Crossed Below MA",
     message = "📊 Cumulative Delta crossed BELOW its MA on {{ticker}}")

alertcondition(bullSMT,
     title   = "Bullish SMT Divergence",
     message = "🔵 Bullish SMT on {{ticker}} — Lower low not confirmed by correlated symbol")

alertcondition(bearSMT,
     title   = "Bearish SMT Divergence",
     message = "🔴 Bearish SMT on {{ticker}} — Higher high not confirmed by correlated symbol")
````
