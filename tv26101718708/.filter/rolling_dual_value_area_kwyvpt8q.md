# Rolling Dual Value Area

- url: https://www.tradingview.com/script/kWyVpt8q/
- type: indicator
- pine_id: PUB;ed5b51968ee14e9487b783c2278255cc
- version: 4.0

## Description

Rolling Dual Value Area (68.2% / 95.4%)

WHAT IT DOES
Builds a rolling volume profile over a trailing window of the last N bars and
draws two nested value areas around the Point of Control (POC):
- Inner area: 68.2% of the window's volume by default
- Outer area: 95.4% of the window's volume by default
The POC is plotted as a single line; the inner and outer Value Area High/Low
boundaries are drawn as two nested bands. Because the profile is recomputed on
every bar, the POC, VAH and VAL appear as continuous trajectories rather than a
single static profile.

WHY 68.2% AND 95.4%
The conventional Market Profile value area uses 70%, which is a rounding of
68.2% - the share of a normal distribution within +/-1 standard deviation.
95.4% is the +/-2 standard deviation share. These two thresholds give a "1
sigma" inner zone and a "2 sigma" outer zone expressed as volume coverage. Both
are inputs, so you can set them back to 70/95 or to any values you prefer.

Important: this is a coverage-threshold band, not a parametric standard-
deviation band. It is centered on the mode (the POC) and expands toward the
heavier side, so it is generally asymmetric and reflects the actual shape of the
distribution. This is a different object from a VWAP standard-deviation band,
which is centered on the volume-weighted mean and is symmetric. The two coincide
only when the distribution is close to normal.

HOW IT IS CALCULATED
1. The high-low range of the last N bars is divided into equal price bins.
2. Each bar's volume is spread evenly across the bins its high-low range covers.
3. The bin with the most volume is the POC.
4. Starting from the POC, the area expands one bin at a time toward the adjacent
   side holding more volume (classic asymmetric, greedy Market Profile
   expansion). A single continuous expansion records the inner boundaries when
   cumulative volume first reaches the inner target, then continues to the outer
   target, so the outer area always contains the inner area and both follow one
   expansion path.
Note: expansion advances one bin per step. The original CBOT method compares
pairs of bins per step; results are nearly identical and may differ by a bin in
edge cases. Because volume is added in discrete bins, the captured coverage
lands at or slightly above the chosen percentage.

HOW TO USE
- The bands mark where trading has concentrated over the lookback. Inner-band
  edges often act as nearer support/resistance; the outer band marks
  statistically extended zones.
- The POC is the heaviest-traded price in the window and tends to act as a
  magnet.
- Watching

## Source Code

````pine
//@version=6
// Rolling Dual Value Area (68.2% / 95.4%)
//
// A rolling volume value area: over the last N bars it builds a volume-by-price
// profile, finds the POC (most-traded price), then expands outward from the POC
// until the band covers the inner % and outer % of total volume (about 1 and 2
// sigma by default). The window counts bars, so it scales with the chart
// timeframe; on a daily chart 20 bars is roughly a month.
//
// This is the value-area drawing on its own. All terrain / SMC overlays
// (FVG, order blocks, liquidity, structure, EQH/EQL, premium-discount, OTE,
// previous-day box, round numbers) have been removed.
//
// Rests on auction-market theory: the value area marks where the market has
// recently accepted price (acceptance, not direction). Not advice.
//
indicator("Rolling Dual Value Area (68.2% / 95.4%)", shorttitle="Rolling VA", overlay=true, max_bars_back=5000)

// ============================== Inputs ==============================
string GRP_VA = "Value Area"

int   lookback      = input.int(20, "Lookback (bars)", minval=1, group=GRP_VA, tooltip="Bars to profile. Counts bars, so it scales with the chart timeframe. On a daily chart 20 is about a month, 50 a quarter, 5 a week.")
int   binCount      = input.int(24, "Price bins", minval=5, maxval=200, group=GRP_VA)
float innerFraction = input.float(68.2, "Inner area %  (about 1 sigma)", minval=1, maxval=99.9, step=0.1, group=GRP_VA) / 100.0
float outerFraction = input.float(95.4, "Outer area %  (about 2 sigma)", minval=1, maxval=99.9, step=0.1, group=GRP_VA) / 100.0
bool  showOuterBand = input.bool(true, "Show outer band", group=GRP_VA)
color pocColor      = input.color(#F0A830, "POC", group=GRP_VA)
color vaColor       = input.color(#57B6D6, "Value area", group=GRP_VA)

// =================== Value-area computation ===================
computeValueArea() =>
    float pocPrice  = na
    float innerHigh = na
    float innerLow  = na
    float outerHigh = na
    float outerLow  = na
    if bar_index >= lookback - 1
        float windowHigh = high
        float windowLow  = low
        for offset = 0 to lookback - 1
            windowHigh := math.max(windowHigh, high[offset])
            windowLow  := math.min(windowLow,  low[offset])
        if windowHigh > windowLow
            float binSize = (windowHigh - windowLow) / binCount
            array<float> binVolumes = array.new_float(binCount, 0.0)
            for offset = 0 to lookback - 1
                int   lowBin       = math.max(0, math.min(binCount - 1, int(math.floor((low[offset]  - windowLow) / binSize))))
                int   highBin      = math.max(0, math.min(binCount - 1, int(math.floor((high[offset] - windowLow) / binSize))))
                float volumePerBin = nz(volume[offset]) / (highBin - lowBin + 1)
                for i = lowBin to highBin
                    array.set(binVolumes, i, array.get(binVolumes, i) + volumePerBin)
            float totalVolume = 0.0
            int   pocBin      = 0
            float pocVolume   = -1.0
            for i = 0 to binCount - 1
                float binVolume = array.get(binVolumes, i)
                totalVolume += binVolume
                if binVolume > pocVolume
                    pocVolume := binVolume
                    pocBin    := i
            if totalVolume > 0
                float innerTarget = totalVolume * math.min(innerFraction, outerFraction)
                float outerTarget = totalVolume * math.max(innerFraction, outerFraction)
                float cumulativeVolume = array.get(binVolumes, pocBin)
                int   upperBin       = pocBin + 1
                int   lowerBin       = pocBin - 1
                int   currentHighBin = pocBin
                int   currentLowBin  = pocBin
                int   innerHighBin   = pocBin
                int   innerLowBin    = pocBin
                bool  innerCaptured  = cumulativeVolume >= innerTarget
                while cumulativeVolume < outerTarget and (upperBin < binCount or lowerBin >= 0)
                    float upperVolume = upperBin < binCount ? array.get(binVolumes, upperBin) : -1.0
                    float lowerVolume = lowerBin >= 0       ? array.get(binVolumes, lowerBin) : -1.0
                    if upperVolume >= lowerVolume
                        cumulativeVolume += array.get(binVolumes, upperBin)
                        currentHighBin   := upperBin
                        upperBin         += 1
                    else
                        cumulativeVolume += array.get(binVolumes, lowerBin)
                        currentLowBin    := lowerBin
                        lowerBin         -= 1
                    if not innerCaptured and cumulativeVolume >= innerTarget
                        innerHighBin  := currentHighBin
                        innerLowBin   := currentLowBin
                        innerCaptured := true
                pocPrice  := windowLow + (pocBin         + 0.5) * binSize
                innerHigh := windowLow + (innerHighBin   + 0.5) * binSize
                innerLow  := windowLow + (innerLowBin    + 0.5) * binSize
                outerHigh := windowLow + (currentHighBin + 0.5) * binSize
                outerLow  := windowLow + (currentLowBin  + 0.5) * binSize
    [pocPrice, innerHigh, innerLow, outerHigh, outerLow]

[poc, innerHigh, innerLow, outerHigh, outerLow] = computeValueArea()

// ----------------- Value-area plotting -----------------
outerHighPlot = plot(showOuterBand ? outerHigh : na, "Outer VAH", color=color.new(vaColor, 30), linewidth=1)
innerHighPlot = plot(innerHigh,                      "Inner VAH", color=vaColor,                linewidth=1)
plot(poc, "POC", color=pocColor, linewidth=2)
innerLowPlot  = plot(innerLow,                       "Inner VAL", color=vaColor,                linewidth=1)
outerLowPlot  = plot(showOuterBand ? outerLow : na,  "Outer VAL", color=color.new(vaColor, 30), linewidth=1)
fill(innerHighPlot, innerLowPlot,  color=color.new(vaColor, 80),                       title="Inner band")
fill(outerHighPlot, innerHighPlot, color=showOuterBand ? color.new(vaColor, 90) : na, title="Upper outer ring")
fill(innerLowPlot,  outerLowPlot,  color=showOuterBand ? color.new(vaColor, 90) : na, title="Lower outer ring")
````
