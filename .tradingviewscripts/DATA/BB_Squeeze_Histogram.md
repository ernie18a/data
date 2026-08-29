<!-- tradingview-pine-id: PUB;499c261db308420a802029cff176e185 -->
<!-- tradingviewscripts-format: 1 -->
# BB Squeeze Histogram

Source: https://www.tradingview.com/script/QHOOls7J-BB-Squeeze-Histogram/

## Description

https://www.tradingview.com/x/Tb8f0l9h/

BB Squeeze Histogram (BBSH) — User Manual
Companion indicator to Bollinger-Bands.Multi_Choice (BBMC). Plots the width of the Bollinger envelope as a MACD-style histogram, signed by which side of the basis MA price is on.

1. What It Shows
Two things are encoded into one histogram:
Above / below the neutral line — whether price is currently above or below the basis moving average. The neutral line is 0 in raw mode, 50 in normalized mode.
Bar length from the neutral line — how wide the Bollinger envelope currently is (the distance between the upper and lower band, at your chosen standard-deviation multiple). Long bars = wide bands = high volatility. Short bars hugging the neutral line = tight bands = low volatility / squeeze.
Put together, a bar answers two questions at once: which side of trend is price on, and how stretched or compressed is the market right now.

2. Reading the Colors
Bars use a 4-color scheme, same idea as a standard MACD histogram:
Color
Meaning
Bright teal
Above neutral, band width expanding vs. the prior bar
Pale teal
Above neutral, band width contracting vs. the prior bar
Bright red
Below neutral, band width expanding vs. the prior bar
Pale red/pink
Below neutral, band width contracting vs. the prior bar
Bright bars mean volatility is actively growing on that side of the trend. Pale bars mean the move is losing steam or the range is tightening — often the first sign a squeeze is building.

3. Extra Plots on the Panel
Neutral line — gray line at 0 (raw mode) or 50 (normalized mode). Crossings mark price crossing the basis MA.
Red line (Avg Positive Column) — the running average width of only the positive (above-neutral) bars, over the "Column average lookback" period. Shows what a "normal" bullish-side expansion looks like recently. Bars poking well above this line are expanding harder than usual.
Green line (Avg Negative Column) — same idea, mirrored for the negative (below-neutral) bars.
Yellow dots on the neutral line — squeeze markers. Appear when the current band width is the tightest reading over the "Squeeze lookback" period — i.e., the bands are as compressed as they've been in a while. These tend to precede expansion moves.

4. Inputs
Input
Default
What it does
Source
ohlc4
Price series used for the basis MA and standard deviation calc
Length
20
Lookback for both the basis MA and the standard deviation
Band SD (± this value)
3.0
The standard-deviation multiple defining the band edges (matches your BBMC R3/S3 by default)
ALMA offset
0.89
Only used if MA Type = ALMA
ALMA sigma
5
Only used if MA Type = ALMA
Normalize to 0-100 scale
off
See Section 5
Normalize rank lookback
200
Bars of width history the 0-100 rank is measured against (normalized mode only)
Squeeze lookback
100
Bars used to detect the "tightest width" for the yellow squeeze dots
Column average lookback
100
Bars used to compute the red/green average-column lines
MA Type
VWMA
Basis moving average type — SMA, EMA, RMA, WMA, VWMA, VWAP, HMA, SWMA, or ALMA

5. Normalize Toggle — Important
Off (default): the histogram plots raw dollar-width — literally (upper band − lower band). Values are in the same units as price, so a reading of "8,000" on BTC/USD means the envelope is $8,000 wide. The neutral line sits at 0.
On: the histogram is rescaled to a bounded 0–100 oscillator with 50 as the neutral level. The current band width is percentile-ranked against its own history over the "Normalize rank lookback" period (default 200 bars), producing a 0–100 rank. That rank is halved to a 0–50 magnitude and then measured out from 50 — upward when price is above the basis MA, downward when below.
Reading the normalized scale:
Reading
Meaning
Near 100
Price above the basis MA, band width at the widest end of its recent history
~75
Price above basis, width around the middle of its historical range
Near 50
Squeeze — width at the tightest end of its history, regardless of side
~25
Price below basis, width around the middle of its historical range
Near 0
Price below the basis MA, band width at the widest end of its recent history
Note that the distance from 50 is the volatility read and the side of 50 is the trend read — they are independent. A reading of 52 and a reading of 48 both describe a tightly squeezed market; they just differ on which side of the MA price closed.
Because the value is a percentile rank, it is self-scaling: readings are directly comparable across assets, timeframes, and price regimes without retuning. The trade-off is that it tells you where width sits relative to its own recent history, not its absolute size — a 95 reading in a quiet chop regime may be a smaller dollar-width than a 60 reading during a volatile stretch. Shortening the rank lookback makes the oscillator more reactive to recent regime; lengthening it gives a more stable long-run reference.
Match your basis MA type/length here to your BBMC settings if you want the neutral-line crossings on this panel to line up exactly with the white basis line's color flips on your main BBMC chart.

6. Suggested Ways to Use It
Trend confirmation: treat neutral-line position the same way you'd treat price vs. the BBMC basis line — histogram above neutral supports a long bias, below neutral supports a short bias.
Squeeze setups: watch for yellow dots (tight width) followed by a color shift from pale to bright — that transition often marks the start of a breakout move out of consolidation.
Exhaustion reads: when bars run well past the red or green average line, the current expansion is unusually large relative to its own recent history — often a point where trend continuation odds start to fade and mean-reversion becomes more likely.
Divergence: if price makes a new high/low but the histogram's peak height is smaller than the prior swing's, the expansion behind the move is weaker than last time — a classic momentum-divergence tell, same logic as reading MACD histogram divergence against price.

7. Notes / Limitations
This is a volatility/width indicator, not a standalone directional signal — it's meant to be read alongside price structure or your BBMC chart, not in isolation.
The squeeze marker and average-column lines both depend on their lookback inputs; shortening them makes the indicator more reactive to recent bars, lengthening them smooths it out but reacts slower to regime changes.
Normalize should generally stay consistent once you've picked it — the raw and normalized histograms are not on comparable scales, and the red/green average lines are computed from whichever mode is active. The squeeze dots are always derived from raw band width, so they mark the same bars in either mode.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Options360
//@version=6
// BB Squeeze Histogram (BBSH) — companion to Bollinger-Bands.Multi_Choice (BBMC)
// Plots the width of the ±N standard-deviation Bollinger envelope as a MACD-style
// histogram: above the neutral line when price is above the basis MA, below it when under.
// Bars grow/shrink in color like the MACD histogram (expansion vs squeeze).
indicator(title = 'BB Squeeze Histogram', shorttitle = 'BBSH', overlay = false)

src    = input(ohlc4, 'Source')
length = input.int(20, 'Length')
mult   = input.float(3.0, 'Band SD (± this value)', minval = .001, maxval = 50)
offset = input.float(0.89, 'ALMA offset')
sigma  = input.int(5, 'ALMA sigma')
normalize = input.bool(false, 'Normalize to 0-100 scale', tooltip = 'On = band width ranked against its own history on a 0-100 scale, 50 = neutral. Above 50 price is over the basis MA, below 50 it is under. Off = raw dollar width, 0 = neutral.')
normLen   = input.int(200, 'Normalize rank lookback', minval = 10, tooltip = 'How many bars of width history the 0-100 rank is measured against. Only used when Normalize is on.')
squeezeLen = input.int(100, 'Squeeze lookback', minval = 10)
avgLen = input.int(100, 'Column average lookback', minval = 10)

string MA01 = 'SMA'
string MA02 = 'EMA'
string MA03 = 'RMA'
string MA04 = 'WMA'
string MA05 = 'VWMA'
string MA06 = 'VWAP'
string MA07 = 'HMA'
string MA08 = 'SWMA'
string MA09 = 'ALMA'

string GRP = 'Settings'
string maType = input.string(MA05, 'MA Type', group = GRP, options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07, MA08, MA09])

ma(series float src, simple int length, simple string type) =>
    float result = switch type
        MA01 => ta.sma(src, length)
        MA02 => ta.ema(src, length)
        MA03 => ta.rma(src, length)
        MA04 => ta.wma(src, length)
        MA05 => ta.vwma(src, length)
        MA06 => ta.vwap(src, bool(length))
        MA07 => ta.hma(src, length)
        MA08 => ta.swma(src)
        MA09 => ta.alma(src, length, offset, sigma)
        => na
    result

basis = ma(src, length, maType)
dev   = ta.stdev(src, length)

// Gap between +mult SD and -mult SD bands (raw, in price units)
width = 2 * mult * dev

// Neutral line: 50 on the normalized scale, 0 on the raw scale
float neutral = normalize ? 50.0 : 0.0

// Magnitude of the bar measured out from the neutral line.
// Normalized: rank current width against its own history (0-100), halved to 0-50
// so the full two-sided plot spans 0-100 with 50 in the middle.
float rank = ta.percentrank(width, normLen)
float mag  = normalize ? rank / 2.0 : width

// Sign it by which side of the basis price is on
bool above = src >= basis
float hist = above ? neutral + mag : neutral - mag

// MACD-histogram style 4-color scheme:
// bright when the raw band gap is expanding, faded when it's squeezing
bool expanding = width >= width[1]
color histColor = above ?
     (expanding ? #26a69a : #b2dfdb) :
     (expanding ? #ff5252 : #ffcdd2)

plot(hist, 'BB Width Histogram', style = plot.style_columns, color = histColor, histbase = normalize ? 50.0 : 0.0)
plot(neutral, 'Neutral', color = color.new(color.gray, 50), linewidth = 1, style = plot.style_linebr)

// Upper / lower rails, only meaningful on the normalized scale
plot(normalize ? 100 : na, 'Top (100)', color = color.new(color.gray, 70))
plot(normalize ? 0 : na, 'Bottom (0)', color = color.new(color.gray, 70))

// Lookback averages of the above-neutral and below-neutral columns
posVal = above ? hist : 0.0
posCnt = above ? 1 : 0
negVal = above ? 0.0 : hist
negCnt = above ? 0 : 1
avgPos = math.sum(posVal, avgLen) / math.max(math.sum(posCnt, avgLen), 1)
avgNeg = math.sum(negVal, avgLen) / math.max(math.sum(negCnt, avgLen), 1)
plot(avgPos, 'Avg Positive Column', color = color.new(#ff0202, 0), linewidth = 1)
plot(avgNeg, 'Avg Negative Column', color = color.new(#3cfe12, 0), linewidth = 1)

// Squeeze marker: raw width at its tightest over the lookback
bool inSqueeze = width == ta.lowest(width, squeezeLen)
plotshape(inSqueeze ? neutral : na, 'Squeeze', style = shape.circle, location = location.absolute, color = color.new(color.yellow, 0), size = size.tiny)
````
