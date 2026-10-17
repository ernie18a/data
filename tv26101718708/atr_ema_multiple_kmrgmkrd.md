# ATR EMA Multiple

- url: https://www.tradingview.com/script/kmrGMKrd-ATR-EMA-Multiple/
- type: indicator
- pine_id: PUB;243c1bf2b59b41d6b0c898ca55728a3a
- version: 1.0

## Description

A TradingView (Pine Script v6) oscillator that measures how far price has stretched from its moving average, expressed in units of ATR (Average True Range).

Instead of asking "how many dollars/points is price away from its average?", this indicator asks "how many typical bars of volatility is price away from its average?" That makes the reading comparable across different symbols, timeframes, and volatility regimes.

[b]WHAT IT PLOTS[/b]

The main line (white) is the oscillator:

    oscillator = (close - EMA(close, maPeriod)) / ATR(atrPeriod)

[list]
[*]A value of +2 means price is currently 2 ATRs above its EMA.
[*]A value of -1.5 means price is 1.5 ATRs below its EMA.
[*]The yellow line at 0 marks price sitting exactly on its EMA.
[/list]

A red line above and a green line below act as reference bands. How those two
bands are placed is controlled by the Line Mode setting (see below).

Typical use: when the oscillator pushes into or beyond the red band, price is
unusually extended to the upside; the green band marks unusual extension to the
downside. How you act on that (mean-reversion, breakout confirmation, etc.) is
up to your strategy.

[b]SETTINGS[/b]

[b]ATR and EMA Settings[/b]
  ATR Period               (default 14)
      Lookback for the ATR used as the volatility unit.

  Moving Average Period    (default 21)
      Lookback for the EMA that price is measured against.

[b]Reference Lines[/b]
  Line Mode                (default Manual)
      Chooses how the red/green bands are positioned:
      "Manual" or "Std Deviations".

[b]Manual mode[/b]
You set the band levels directly, in ATR units.

  Manual: red line ATR level     (default 3)
      Red band drawn at this fixed oscillator value (e.g. +3 ATRs).

  Manual: green line ATR level   (default -3)
      Green band drawn at this fixed oscillator value (e.g. -3 ATRs).

The bands are flat, fixed horizontal lines. Good when you want a constant, opinionated threshold.

[b]Std Deviations mode[/b]

The bands adapt to the symbol's recent behaviour. You specify how many standard deviations from 0 each band should sit, and the script measures the actual standard deviation from the data.

  Std Dev: red line std devs above 0     (default 2)
      Red band at this many standard deviations above 0.

  Std Dev: green line std devs below 0   (default 2)
      Green band at this many standard deviations below 0.

  Std Dev: lookback length (bars)        (default 200)
      How many recent bars are sampled to measure the standard deviation.

The bands move over time as volatility behaviour changes, automatically tightening in calm conditions and widening in stretched ones.

[b]HOW "STD DEVIATIONS" MODE IS CALCULATED[/b]

This is worth understanding before you rely on it, because it is a deliberate, slightly non-standard choice.

The standard deviation is measured separately for the positive and negative sides of the oscillator, and anchored at 0 (not at each side's own average):

    sigma_positive = sqrt( mean( oscillator^2  over bars where oscillator > 0 ) )
    sigma_negative = sqrt( mean( oscillator^2  over bars where oscillator < 0 ) )

    red band   = (+ std devs above) x sigma_positive
    green band = (- std devs below) x sigma_negative

Two consequences of this design:

[list=1]
[*]Anchored at 0, not at the mean. Because the bands are described as "N standard deviations above 0 / below 0", the spread is measured as the root-mean-square of values around 0 -- not the textbook standard deviation around the sample mean. This keeps 0 (price = EMA) as the true center of the scale.
[*]Asymmetric by design. The upside and downside are measured independently, so a market that stretches further on rallies than on sell-offs (or vice versa) will get an asymmetric pair of bands that reflects that.
[/list]

On a freshly loaded chart the bands stay blank until the lookback window contains at least one positive and one negative reading.

[b]READING THE COLOURS[/b]

[list]
[*]Oscillator   White    Price distance from EMA, in ATR units.
[*]Upper band   Red      Upside extension threshold.
[*]Lower band   Green    Downside extension threshold.
[*]Zero line    Yellow   Price equals its EMA.
[/list]

[b]NOTES & LIMITATIONS[/b]

[list]
[*]The indicator is not a standalone trading system -- it's a normalization/context tool. Combine it with your own entry/exit logic and risk management.
[*]Readings are only comparable when the ATR Period and Moving Average Period are held constant.
[*]The red/green reference bands are drawn as dashed lines to distinguish them from the solid white oscillator.
[*]On instruments with periods of zero volatility (ATR = 0), the oscillator value is undefined for those bars.
[/list]

[b]LICENSE[/b]
Open source -- published for the TradingView community. Attribution appreciated.

## Source Code

````pine
//@version=6
indicator("ATR EMA Multiple", overlay=false)

// Line drawing mode
enum LineMode
    manual = "Manual"
    stdDev = "Std Deviations"

i_atrPeriod = input.int(title="ATR Period", defval=14, minval=1, group="ATR and EMA Settings")
i_maPeriod = input.int(title="Moving Average Period", defval=21, minval=1, group="ATR and EMA Settings")

i_lineMode = input.enum(LineMode.manual, "Line Mode", group="Reference Lines")

// Manual mode: user sets the ATR multiples directly
i_redLine = input.float(3, "Manual: red line ATR level", group="Manual")
i_greenLine = input.float(-3, "Manual: green line ATR level", group="Manual")

// Std deviation mode: user sets how many std devs above/below 0
i_stdDevAbove = input.float(2, "Std Dev: red line std devs above 0", group="Std Deviations")
i_stdDevBelow = input.float(2, "Std Dev: green line std devs below 0", group="Std Deviations")
i_stdLookback = input.int(200, "Std Dev: lookback length (bars)", minval=1, group="Std Deviations")

maValue = ta.ema(close, i_maPeriod)
atrValue = ta.atr(i_atrPeriod)
osc = (close - maValue) / atrValue

// Standard deviation of the positive and negative oscillator values,
// measured relative to 0 (RMS), so the bands sit N std devs from 0.
sumSqPos = math.sum(osc > 0 ? osc * osc : 0.0, i_stdLookback)
cntPos = math.sum(osc > 0 ? 1.0 : 0.0, i_stdLookback)
stdevPos = cntPos > 0 ? math.sqrt(sumSqPos / cntPos) : na

sumSqNeg = math.sum(osc < 0 ? osc * osc : 0.0, i_stdLookback)
cntNeg = math.sum(osc < 0 ? 1.0 : 0.0, i_stdLookback)
stdevNeg = cntNeg > 0 ? math.sqrt(sumSqNeg / cntNeg) : na

redLevel = i_lineMode == LineMode.manual ? i_redLine : i_stdDevAbove * stdevPos
greenLevel = i_lineMode == LineMode.manual ? i_greenLine : -i_stdDevBelow * stdevNeg

plot(osc, color=color.new(color.white, 0), style=plot.style_line)
plot(redLevel, color=color.red, style=plot.style_line, linestyle = plot.linestyle_dashed)
plot(greenLevel, color=color.lime, style=plot.style_line, linestyle=plot.linestyle_dashed)
hline(0, color=color.yellow)
````
