# Structural Deviation Compass [JOAT]

- url: https://www.tradingview.com/script/Mq6BUKWr-Structural-Deviation-Compass-JOAT/
- type: indicator
- pine_id: PUB;09505897b4ef420a86d6982fcdc3136a
- version: 1.0

## Description

[b]Structural Deviation Compass [JOAT][/b]

[b]Introduction[/b]

The Structural Deviation Compass is an overlay indicator designed to map where price stands relative to its own statistical history. Rather than drawing fixed-distance envelopes or relying on a single moving average, it constructs a hybrid centerline from two distinct low-lag moving average types, then wraps that centerline in volatility-adaptive bands derived from Z-score normalization. A secondary oscillator layer — applied to RSI — creates a dual-confirmation signal gate that fires only when both price deviation and momentum reach simultaneous extremes. Shadow bands built from the Average True Range provide additional spatial context across three volatility tiers.

The indicator does not predict future price. It identifies statistically unusual deviations from an estimated mean structure and flags conditions where a reversion or continuation setup may be forming, subject to confirmation from the trader's own process.

[image]https://www.tradingview.com/x/8qowXQxH/[/image]

[b]Core Concepts[/b]

[b]The ComboMA Centerline[/b]

The foundation of the indicator is a composite moving average called the ComboMA, formed by averaging two lines:

[list]
[*][b]ALMA (Arnaud Legoux Moving Average):[/b] Uses a Gaussian-weighted kernel positioned asymmetrically along the lookback window. The offset and sigma parameters control how far toward the recent end the weight mass sits and how tightly it is concentrated. This produces a smooth line that tracks price closely while suppressing noise better than a simple EMA of the same length.
[*][b]ZLMA (Zero-Lag Moving Average):[/b] Constructed by doubling a base EMA and subtracting a second EMA of that EMA — a technique that estimates and removes the inherent lag of an exponential average. The result is then smoothed once more to reduce the noise amplification that zero-lag constructions can introduce.
[/list]

Averaging the two produces a centerline that carries reduced lag from the ZLMA side while retaining the smooth, noise-filtered character of the ALMA side. Neither line alone fully satisfies both goals; together they produce a more balanced result.

[b]Z-Score Price Bands[/b]

Rather than plotting bands at a fixed multiple of a standard deviation (as Bollinger Bands do using a rolling standard deviation of price itself), the SDC first computes the deviation of close from the ComboMA, then Z-score normalizes that deviation series over a separate lookback window. The bands are then placed back on the price chart by multiplying the rolling standard deviation of deviations by the chosen Z-score threshold values.

The practical effect is that the band width reflects how unusual the current deviation is relative to the recent distribution of deviations — not simply how wide price has swung in a raw sense. Two threshold levels are provided, creating an inner and outer band pair on each side of the ComboMA.

[b]RSI Z-Score[/b]

RSI is computed in the standard way, then subjected to the same Z-score normalization: the RSI value is compared to its own rolling mean and expressed in standard deviations. This removes the fixed-level bias of RSI (where 30/70 thresholds mean different things in different market regimes) and produces a momentum reading that is self-calibrating to recent RSI behavior.

[b]Dual Z-Score Signal Gate[/b]

A long signal requires all of the following simultaneously:
[list]
[*]Price Z-score below the negative trigger threshold (price is statistically far below the ComboMA)
[*]RSI Z-score below the negative trigger threshold (momentum is statistically depressed)
[*]RSI EMA below 38 (confirming a bearish momentum context rather than a pullback within strength)
[*]The current bar closed above the prior bar's close (a micro-confirmation that selling pressure may be easing)
[*]The bar is confirmed (signal does not repaint on the forming bar)
[/list]

Short signals apply the mirror logic. The requirement for extremes in both dimensions simultaneously is intentionally strict — it filters out the many cases where price is extended but momentum is not, or vice versa.

[b]ATR Shadow Bands[/b]

Three pairs of shadow bands are drawn around the ComboMA at 1x, 2x, and 3x of a rolling ATR. These are not signal bands — they serve as a spatial reference, helping to contextualize how far price has traveled from the estimated mean in volatility-adjusted terms. A move to the 3x ATR shadow in a low-volatility environment carries different significance than the same move in a high-volatility environment.

[b]RGB Smooth Color Transition[/b]

The ComboMA line color transitions smoothly between a bull and bear palette by independently blending the red, green, and blue channels via EMA. Each channel tracks a target value set by the current bull/bear state, and converges toward it gradually. This avoids abrupt color flips and gives a visual sense of momentum continuity.

[b]Gradient Bar Coloring[/b]

Individual bars are colored based on where the close sits within the band range relative to the ComboMA. Bars near the upper bands trend toward the bull color; bars near the lower bands trend toward the bear color. Bars near the ComboMA receive a neutral tone. This is a visual aid only and does not constitute a signal.

[b]Information Table[/b]

A 9-row table displays the current readings for: market regime, price Z-score, RSI Z-score, RSI EMA, band width, signal strength, active signal, and ComboMA value. This gives a snapshot of the indicator's internal state without requiring the trader to hover over each plotted element.

---

[b]Features[/b]

[list]
[*]Hybrid ComboMA centerline combining ALMA and ZLMA
[*]Volatility-adaptive Z-score bands at two threshold levels (inner and outer)
[*]RSI Z-score normalization for regime-independent momentum reading
[*]Dual Z-score signal gate requiring simultaneous extremes in price and momentum
[*]Three-layer ATR shadow bands for spatial volatility context
[*]Smooth RGB channel blending on the ComboMA line color
[*]Gradient bar coloring based on position within band range
[*]Real-time information table with 9 indicator state readings
[*]Non-repainting signals (barstate.isconfirmed)
[*]Fully toggleable visual components
[/list]

---

[b]Input Parameters[/b]

[list]
[*][b]MA Length:[/b] Base length for the ZLMA and ATR calculations
[*][b]ALMA Offset:[/b] Controls asymmetric weight positioning within the ALMA window (0 = old end, 1 = recent end)
[*][b]ALMA Sigma:[/b] Controls weight concentration; lower values spread the weight, higher values tighten it
[*][b]Z-Score Lookback:[/b] Rolling window for computing the mean and standard deviation of price deviations (default: 50)
[*][b]Inner Band Threshold:[/b] Z-score level for the inner band pair (default: 1.5σ)
[*][b]Outer Band Threshold:[/b] Z-score level for the outer band pair (default: 2.5σ)
[*][b]RSI Length:[/b] Period for RSI calculation (default: 14)
[*][b]RSI Z-Score Lookback:[/b] Rolling window for normalizing RSI
[*][b]Signal Trigger:[/b] Z-score threshold required in both dimensions to generate a signal (default: 1.8σ)
[*][b]ATR Multipliers:[/b] Multipliers for the three shadow band tiers (1x, 2x, 3x)
[*][b]Visual Toggles:[/b] Individual on/off controls for bands, shadows, bar coloring, table, and signals
[/list]

---

[b]How to Use[/b]

[b]Reading the centerline:[/b] The ComboMA acts as the estimated mean structure. Price consistently above it with a bull-colored line suggests sustained upward bias; price oscillating around it suggests a ranging environment.

[b]Reading the bands:[/b] The inner bands (±1.5σ by default) represent moderately unusual deviations. The outer bands (±2.5σ by default) represent statistically rare deviations. A touch or breach of the outer band does not by itself mean a reversal is due — it means the move is statistically uncommon and warrants attention.

[b]Reading the shadow bands:[/b] Use the ATR shadows to understand how far, in volatility-adjusted terms, price has moved from the ComboMA. Price at the 3x shadow while also at the outer Z-score band is a more notable condition than either reading alone.

[b]Acting on signals:[/b] The dual Z-score signals flag confluent extremes. They should be used as an alert layer within a broader trading framework — not as standalone entry triggers. Consider the broader trend context, the timeframe, and supporting structure before acting.

[b]Using the table:[/b] Monitor the signal strength reading to understand how close the current state is to triggering a signal. This is useful for watching a developing setup in real time.

[b]Timeframe notes:[/b] The indicator functions on any timeframe. Higher timeframes produce fewer but more structurally significant signals. Lower timeframes will produce more signals, many of which will be noise. Adjust the Z-score lookback and trigger threshold accordingly.

---

[b]Limitations[/b]

[list]
[*]This indicator does not predict future price movement. All readings are descriptive of past and current bar data.
[*]The ComboMA, like all moving averages, will lag price during sharp trend changes. The ZLMA component reduces but does not eliminate this lag.
[*]Z-score bands assume that price deviations are approximately normally distributed. In instruments with fat-tailed distributions or during extreme events, the statistical thresholds will underestimate the probability of outlier moves.
[*]Signals are non-repainting on confirmed bars but will update on the forming bar until it closes. Always wait for bar close before acting on a signal.
[*]A signal firing does not mean price will reverse. Trending markets can sustain extreme Z-score readings for extended periods.
[*]The RSI EMA threshold (38 for longs) is a fixed filter that may not suit all instruments or regimes. It should be adjusted or disabled if it is filtering out valid setups in the instrument being traded.
[*]The ATR shadow bands are informational only and carry no predictive weight.
[*]Past signal performance on a given instrument is not indicative of future performance.
[/list]

---

[b]Originality Statement[/b]

The ALMA and ZLMA are established concepts. The ComboMA is not either of them — it is a blended centerline that takes the asymmetric-weight smoothness of ALMA and the lag-reduction property of ZLMA and produces a composite that neither achieves individually. The Z-score normalization of price deviations is a statistical adaptation that makes the bands self-calibrating to the instrument's deviation distribution rather than fixed. Applying the same normalization independently to RSI produces a momentum reading that is self-referential to recent RSI behavior rather than anchored to universal threshold levels. The signal gate that requires simultaneous Z-score extremes in both price deviation and RSI — not one or the other — creates a logical AND condition that is substantially stricter than conventional oscillator crossovers or single-band-touch triggers. The three ATR shadow tiers, smooth RGB color blending, and gradient bar coloring are supporting visual constructs that serve interpretation rather than adding trading logic. The combination of these elements into a single overlay tool — ComboMA centerline, adaptive Z-score bands, normalized momentum gate, ATR spatial context, and state table — represents an original integration not replicated by any standard built-in indicator.

---

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial professional before making any trading decisions.

[i]-Made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structural Deviation Compass [JOAT]", shorttitle="SDC [JOAT]", overlay=true, max_labels_count=150)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpMA    = "Composite MA Settings"
maLen    = input.int(34, "MA Length", minval=5, maxval=200, group=grpMA)
almaOff  = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.01, group=grpMA)
almaSig  = input.float(6.0, "ALMA Sigma", minval=1.0, maxval=20.0, step=0.5, group=grpMA)

grpZ     = "Z-Score Settings"
zLen     = input.int(50, "Z-Score Lookback", minval=10, maxval=300, group=grpZ)
zThresh1 = input.float(1.5, "Band 1 Threshold (σ)", minval=0.5, maxval=4.0, step=0.1, group=grpZ)
zThresh2 = input.float(2.5, "Band 2 Threshold (σ)", minval=1.0, maxval=6.0, step=0.1, group=grpZ)

grpRSI   = "RSI Z-Score Settings"
rsiLen   = input.int(14, "RSI Length", minval=2, maxval=50, group=grpRSI)
rsiZLen  = input.int(30, "RSI Z-Score Window", minval=10, maxval=100, group=grpRSI)
rsiEmaL  = input.int(5, "RSI EMA Smoothing", minval=1, maxval=20, group=grpRSI)
trigger  = input.float(1.8, "Signal Trigger (σ)", minval=0.5, maxval=4.0, step=0.1, group=grpRSI)

grpATR   = "ATR Shadow"
atrLen   = input.int(14, "ATR Length", minval=1, maxval=50, group=grpATR)
atrMult1 = input.float(1.0, "Shadow Layer 1 Mult", minval=0.1, maxval=5.0, step=0.1, group=grpATR)
atrMult2 = input.float(2.0, "Shadow Layer 2 Mult", minval=0.1, maxval=5.0, step=0.1, group=grpATR)
atrMult3 = input.float(3.0, "Shadow Layer 3 Mult", minval=0.1, maxval=5.0, step=0.1, group=grpATR)

grpVis   = "Visual Settings"
showBars = input.bool(true, "Gradient Bar Coloring", group=grpVis)
showFill = input.bool(true, "Gradient Band Fills", group=grpVis)
showTbl  = input.bool(true, "Show Analysis Table", group=grpVis)
tblPos   = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"], group=grpVis)
emaSmth  = input.int(15, "Color EMA Smoothing", minval=1, maxval=50, group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
bullColor   = color.rgb(92, 240, 215)
bearColor   = color.rgb(179, 42, 195)
neutralCol  = color.rgb(130, 140, 160)
bgDark      = color.rgb(10, 14, 22)
textLight   = color.rgb(220, 225, 235)
textDim     = color.rgb(100, 110, 130)

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSITE MA CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
src       = close
almaLine  = ta.alma(src, maLen, almaOff, almaSig)
zlmaRaw   = 2.0 * ta.ema(src, maLen) - ta.ema(ta.ema(src, maLen), maLen)
zlmaLine  = ta.ema(zlmaRaw, maLen)
comboMA   = (almaLine + zlmaLine) / 2.0

// ─────────────────────────────────────────────────────────────────────────────
// Z-SCORE BANDS
// ─────────────────────────────────────────────────────────────────────────────
deviation  = src - comboMA
devSMA     = ta.sma(deviation, zLen)
devStdev   = ta.stdev(deviation, zLen)
safeStdev  = math.max(devStdev, syminfo.mintick)

zPrice     = (deviation - devSMA) / safeStdev

upperBand1 = comboMA + zThresh1 * safeStdev
lowerBand1 = comboMA - zThresh1 * safeStdev
upperBand2 = comboMA + zThresh2 * safeStdev
lowerBand2 = comboMA - zThresh2 * safeStdev

// ─────────────────────────────────────────────────────────────────────────────
// RSI Z-SCORE
// ─────────────────────────────────────────────────────────────────────────────
rsiVal    = ta.rsi(src, rsiLen)
rsiEMA    = ta.ema(rsiVal, rsiEmaL)
rsiSMA    = ta.sma(rsiVal, rsiZLen)
rsiStdev  = ta.stdev(rsiVal, rsiZLen)
safeRsiSD = math.max(rsiStdev, 0.0001)
zRSI      = (rsiVal - rsiSMA) / safeRsiSD

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL CONDITIONS (non-repainting via barstate.isconfirmed)
// ─────────────────────────────────────────────────────────────────────────────
buyCond  = zPrice < -trigger and zRSI < -trigger and rsiEMA < 38.0 and src > src[1] and barstate.isconfirmed
sellCond = zPrice > trigger  and zRSI > trigger  and rsiEMA > 62.0 and src < src[1] and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// ATR SHADOW BANDS
// ─────────────────────────────────────────────────────────────────────────────
atr14     = ta.atr(atrLen)
shadow1U  = comboMA + atrMult1 * atr14
shadow1L  = comboMA - atrMult1 * atr14
shadow2U  = comboMA + atrMult2 * atr14
shadow2L  = comboMA - atrMult2 * atr14
shadow3U  = comboMA + atrMult3 * atr14
shadow3L  = comboMA - atrMult3 * atr14

// ─────────────────────────────────────────────────────────────────────────────
// SMOOTH RGB COLOR TRANSITION (EMA of channel values)
// ─────────────────────────────────────────────────────────────────────────────
maSlope     = comboMA - comboMA[1]
targetR     = maSlope > 0 ? float(color.r(bullColor)) : float(color.r(bearColor))
targetG     = maSlope > 0 ? float(color.g(bullColor)) : float(color.g(bearColor))
targetB     = maSlope > 0 ? float(color.b(bullColor)) : float(color.b(bearColor))

smoothR     = ta.ema(targetR, emaSmth)
smoothG     = ta.ema(targetG, emaSmth)
smoothB     = ta.ema(targetB, emaSmth)
smoothColor = color.rgb(int(smoothR), int(smoothG), int(smoothB))

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT BAR COLORING
// ─────────────────────────────────────────────────────────────────────────────
bandRange   = math.max(upperBand2 - lowerBand2, syminfo.mintick)
bandRatio   = math.max(0.0, math.min(1.0, (src - lowerBand2) / bandRange))

barR = int(float(color.r(bearColor)) + (float(color.r(bullColor)) - float(color.r(bearColor))) * bandRatio)
barG = int(float(color.g(bearColor)) + (float(color.g(bullColor)) - float(color.g(bearColor))) * bandRatio)
barB = int(float(color.b(bearColor)) + (float(color.b(bullColor)) - float(color.b(bearColor))) * bandRatio)
gradBarColor = color.rgb(barR, barG, barB)

barcolor(showBars ? gradBarColor : na)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL STRENGTH
// ─────────────────────────────────────────────────────────────────────────────
sigStrength = (math.abs(zPrice) + math.abs(zRSI)) / 2.0
sigLabel    = sigStrength > trigger * 1.5 ? "STRONG" : sigStrength > trigger ? "MODERATE" : "WEAK"

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// Shadow fills (ATR layers)
pSh3U = plot(shadow3U, "Shadow 3 Upper", display=display.none)
pSh3L = plot(shadow3L, "Shadow 3 Lower", display=display.none)
pSh2U = plot(shadow2U, "Shadow 2 Upper", display=display.none)
pSh2L = plot(shadow2L, "Shadow 2 Lower", display=display.none)
pSh1U = plot(shadow1U, "Shadow 1 Upper", display=display.none)
pSh1L = plot(shadow1L, "Shadow 1 Lower", display=display.none)

fill(pSh3U, pSh3L, shadow3U, shadow3L, color.new(smoothColor, 93), color.new(smoothColor, 93))
fill(pSh2U, pSh2L, shadow2U, shadow2L, color.new(smoothColor, 87), color.new(smoothColor, 87))
fill(pSh1U, pSh1L, shadow1U, shadow1L, color.new(smoothColor, 75), color.new(smoothColor, 75))

// Band plots
pUB2 = plot(upperBand2, "Upper Band 2", color=color.new(bearColor, 60), linewidth=1)
pUB1 = plot(upperBand1, "Upper Band 1", color=color.new(bearColor, 75), linewidth=1, style=plot.style_linebr)
pMA  = plot(comboMA, "Combo MA", color=smoothColor, linewidth=2)
pLB1 = plot(lowerBand1, "Lower Band 1", color=color.new(bullColor, 75), linewidth=1, style=plot.style_linebr)
pLB2 = plot(lowerBand2, "Lower Band 2", color=color.new(bullColor, 60), linewidth=1)

// Gradient fills between bands
fill(pUB2, pUB1, upperBand2, upperBand1,
     showFill ? color.new(bearColor,   92) : na, showFill ? color.new(bearColor,   85) : na)
fill(pLB1, pLB2, lowerBand1, lowerBand2,
     showFill ? color.new(bullColor,   85) : na, showFill ? color.new(bullColor,   92) : na)
fill(pUB1, pMA,  upperBand1, comboMA,
     showFill ? color.new(bearColor,   96) : na, showFill ? color.new(neutralCol,  98) : na)
fill(pMA,  pLB1, comboMA,    lowerBand1,
     showFill ? color.new(neutralCol,  98) : na, showFill ? color.new(bullColor,   96) : na)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL LABELS
// ─────────────────────────────────────────────────────────────────────────────
if buyCond
    label.new(bar_index, lowerBand2 - atr14 * 0.5,
      text="▲ BUY\nZ: " + str.tostring(zPrice, "#.##"),
      style=label.style_label_up,
      color=color.new(bullColor, 15),
      textcolor=bgDark,
      size=size.small)

if sellCond
    label.new(bar_index, upperBand2 + atr14 * 0.5,
      text="▼ SELL\nZ: " + str.tostring(zPrice, "#.##"),
      style=label.style_label_down,
      color=color.new(bearColor, 15),
      textcolor=color.white,
      size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// REGIME CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────
regimeStr = zPrice > zThresh2 ? "EXTREME HIGH" :
  zPrice > zThresh1 ? "HIGH" :
  zPrice < -zThresh2 ? "EXTREME LOW" :
  zPrice < -zThresh1 ? "LOW" : "NEUTRAL"

regimeCol = zPrice > zThresh1 ? bearColor : zPrice < -zThresh1 ? bullColor : neutralCol

// ─────────────────────────────────────────────────────────────────────────────
// ANALYSIS TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = na
if showTbl
    tblPosition = tblPos == "top_right" ? position.top_right :
      tblPos == "top_left" ? position.top_left :
      tblPos == "bottom_right" ? position.bottom_right : position.bottom_left

    if na(tbl)
        tbl := table.new(tblPosition, 2, 9,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(neutralCol, 70),
          border_width=1,
          frame_color=color.new(neutralCol, 50),
          frame_width=1)

    table.cell(tbl, 0, 0, "SDC [JOAT]", text_color=textLight, bgcolor=color.new(bgDark, 5),
      text_size=size.tiny, text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=bullColor, bgcolor=color.new(bgDark, 5),
      text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)

    table.cell(tbl, 0, 1, "Regime", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 1, regimeStr, text_color=regimeCol, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "Price Z-Score", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    zPriceCol = zPrice > zThresh1 ? bearColor : zPrice < -zThresh1 ? bullColor : textLight
    table.cell(tbl, 1, 2, str.tostring(zPrice, "#.##"), text_color=zPriceCol, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "RSI Z-Score", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    zRSICol = zRSI > 1.5 ? bearColor : zRSI < -1.5 ? bullColor : textLight
    table.cell(tbl, 1, 3, str.tostring(zRSI, "#.##"), text_color=zRSICol, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 4, "RSI (EMA)", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    rsiDispCol = rsiEMA > 60 ? bearColor : rsiEMA < 40 ? bullColor : textLight
    table.cell(tbl, 1, 4, str.tostring(rsiEMA, "#.#"), text_color=rsiDispCol, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 5, "Band Width", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(upperBand2 - lowerBand2, "#.####"), text_color=textLight,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 6, "Sig Strength", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    sigStrCol = sigStrength > trigger * 1.5 ? bullColor : sigStrength > trigger ? color.rgb(255,200,50) : textDim
    table.cell(tbl, 1, 6, sigLabel + " (" + str.tostring(sigStrength, "#.##") + ")", text_color=sigStrCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    lastSig   = buyCond ? "BUY" : sellCond ? "SELL" : "---"
    lastSigC  = buyCond ? bullColor : sellCond ? bearColor : textDim
    table.cell(tbl, 0, 7, "Signal", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 7, lastSig, text_color=lastSigC, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 8, "Combo MA", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(comboMA, "#.####"), text_color=smoothColor, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(buyCond,  title="SDC [JOAT] Buy Signal",  message="SDC [JOAT]: BUY signal on {{ticker}} — Z-Score extreme low with RSI confirmation.")
alertcondition(sellCond, title="SDC [JOAT] Sell Signal", message="SDC [JOAT]: SELL signal on {{ticker}} — Z-Score extreme high with RSI confirmation.")
````
