# Range-Filtered Momentum [Indicatr]

- url: https://www.tradingview.com/script/9PY9iDfj-Range-Filtered-Momentum-Indicatr/
- type: indicator
- pine_id: PUB;bf9fa52c312b4e0580b7d80d7e12b93d
- version: 1.0

## Description

[b]Range-Filtered Momentum[/b] mutes momentum crossovers during sideways phases and makes price-based momentum comparable across markets by normalising it with ATR. Bullish and bearish crosses are only marked while the market is trending.

[b]WHAT IT DOES[/b]
Momentum indicators such as MACD produce many crossovers in ranges, and their values are not comparable between instruments (a MACD of 50 on BTC means something different than on EURUSD). This script filters out range phases and offers an ATR normalisation.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Momentum source:[/b] MACD, TSI, TRIX, Awesome Oscillator, ROC, Momentum or Elder Ray (Bull + Bear Power). A signal line (EMA) and a histogram are derived from it.
[*][b]ATR normalisation:[/b] price-based sources (MACD, Awesome Oscillator, Momentum, Elder Ray) can be divided by ATR, so values are expressed in ATR units.
[*][b]Range filter:[/b] ADX above a threshold, Choppiness Index below a threshold, or both, classify a bar as trending.
[*][b]Display:[/b] during range phases line and histogram turn grey, the background is shaded and no crosses are marked. During trend phases bullish (green) and bearish (red) crosses are marked.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Read crossovers only when the filter says the market is trending - long and short alike.
[*]Treat grey phases as a reminder that crossovers carry little information in sideways markets.
[*]Alerts: bullish cross in trend, bearish cross in trend, start of a trend phase.
[/list]

[b]THE CHART[/b]
BTCUSD daily with MACD (12/26/9), ATR-normalised, and the ADX filter. Grey shaded areas are range phases in which crosses are suppressed. Triangles mark crosses that occurred while the market was trending.

[b]WHAT IS ORIGINAL[/b]
Standard momentum indicators do not distinguish trend from range and are not normalised. This script adds an optional ATR normalisation, a selectable ADX/Choppiness range filter that mutes signals, and one consistent display for seven interchangeable momentum sources.

[b]CREDITS[/b]
MACD (Gerald Appel), TSI (William Blau), TRIX (Jack Hutson), Awesome Oscillator (Bill Williams), Elder Ray (Alexander Elder), ADX (J. Welles Wilder), Choppiness Index (E. W. Dreiss). Standard formulas, implemented from scratch.

[b]LIMITATIONS[/b]
[list]
[*]Filters reduce the number of signals but cannot remove false signals.
[*]Thresholds (ADX 20, Choppiness 61.8) are defaults, not optimised values.
[*]Values update on the current bar until it closes.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Range-Filtered Momentum [Indicatr]", shorttitle="RFM [Indicatr]", overlay=false, precision=3)

// ===== Inputs =====
grpM = "Momentum source"
mType  = input.string("MACD", "Source", options=["MACD", "TSI", "TRIX", "Awesome Oscillator", "ROC", "Momentum", "Elder Ray"], group=grpM)
fastL  = input.int(12, "Fast length (MACD / TSI short)", minval=1, group=grpM)
slowL  = input.int(26, "Slow length (MACD / TSI long)", minval=2, group=grpM)
sigL   = input.int(9,  "Signal length", minval=1, group=grpM)
baseL  = input.int(14, "Length (TRIX / ROC / Momentum / Elder EMA)", minval=1, group=grpM)
normATR = input.bool(true, "Normalize price-based sources by ATR", group=grpM, tooltip="MACD, Awesome Oscillator, Momentum and Elder Ray are measured in price units. Dividing by ATR makes values comparable across markets and timeframes.")
atrL   = input.int(14, "ATR length", minval=1, group=grpM)

grpF = "Range filter"
fType  = input.string("ADX", "Filter", options=["ADX", "Choppiness Index", "Both"], group=grpF)
adxL   = input.int(14, "ADX length", minval=2, group=grpF)
adxThr = input.float(20, "ADX: trending above", minval=1, group=grpF)
chopL  = input.int(14, "Choppiness length", minval=2, group=grpF)
chopThr = input.float(61.8, "Choppiness: ranging above", minval=1, maxval=100, group=grpF)

grpD = "Display"
colUp   = input.color(#1B5E40, "Bullish", group=grpD, inline="c")
colDn   = input.color(#C0412F, "Bearish", group=grpD, inline="c")
colMute = input.color(#B0B0B0, "Range (muted)", group=grpD, inline="c")
showSig = input.bool(true, "Show crosses (trend phases only)", group=grpD)
showBg  = input.bool(true, "Shade range phases", group=grpD)

// ===== Sources (all computed, then selected) =====
atr = ta.atr(atrL)
nrm(float v) => normATR ? v / math.max(atr, syminfo.mintick) : v

macdL = ta.ema(close, fastL) - ta.ema(close, slowL)

pc   = ta.change(close)
tsiL = 100 * ta.ema(ta.ema(pc, slowL), fastL) / math.max(ta.ema(ta.ema(math.abs(pc), slowL), fastL), syminfo.mintick)

e1 = ta.ema(math.log(close), baseL)
e2 = ta.ema(e1, baseL)
e3 = ta.ema(e2, baseL)
trixL = 10000 * ta.change(e3)

aoL  = ta.sma(hl2, 5) - ta.sma(hl2, 34) // standard Awesome Oscillator settings
rocL = ta.roc(close, baseL)
momL = ta.mom(close, baseL)

emaE  = ta.ema(close, baseL)
elderL = (high - emaE) + (low - emaE)

mLine = switch mType
    "MACD"               => nrm(macdL)
    "TSI"                => tsiL
    "TRIX"               => trixL
    "Awesome Oscillator" => nrm(aoL)
    "ROC"                => rocL
    "Momentum"           => nrm(momL)
    => nrm(elderL)

sigLine = ta.ema(mLine, sigL)
hist = mLine - sigLine

// ===== Range filter =====
[diP, diM, adx] = ta.dmi(adxL, adxL)
chop = 100 * math.log10(math.sum(ta.atr(1), chopL) / math.max(ta.highest(high, chopL) - ta.lowest(low, chopL), syminfo.mintick)) / math.log10(chopL)
trendADX  = adx > adxThr
trendChop = chop < chopThr
trending = switch fType
    "ADX"              => trendADX
    "Choppiness Index" => trendChop
    => trendADX and trendChop

// ===== Signals =====
xBull = ta.crossover(mLine, sigLine)
xBear = ta.crossunder(mLine, sigLine)
bullX = showSig and trending and xBull
bearX = showSig and trending and xBear

histCol = not trending ? color.new(colMute, 40) : hist >= 0 ? (hist > hist[1] ? colUp : color.new(colUp, 50)) : (hist < hist[1] ? colDn : color.new(colDn, 50))
lineCol = trending ? (mLine >= sigLine ? colUp : colDn) : colMute

plot(hist, "Histogram", style=plot.style_columns, color=histCol)
plot(mLine, "Momentum line", color=lineCol, linewidth=2)
plot(sigLine, "Signal line", color=trending ? color.new(color.gray, 0) : color.new(colMute, 50), linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 50))

plotshape(bullX, "Bullish cross (trend)", shape.triangleup,   location.bottom, colUp, size=size.tiny)
plotshape(bearX, "Bearish cross (trend)", shape.triangledown, location.top,    colDn, size=size.tiny)
bgcolor(showBg and not trending ? color.new(colMute, 88) : na, title="Range phase")

alertcondition(bullX, "Bullish cross in trend", "Range-Filtered Momentum: bullish cross while trending")
alertcondition(bearX, "Bearish cross in trend", "Range-Filtered Momentum: bearish cross while trending")
alertcondition(trending and not trending[1], "Trend phase starts", "Range-Filtered Momentum: range filter switched to trending")
````
