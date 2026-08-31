<!-- tradingview-pine-id: PUB;2e0f67c6cda940dbb7549f5f68c00804 -->
<!-- tradingviewscripts-format: 1 -->
# CB ITH / ITL Weis Wave Volume Histogram

Source: https://www.tradingview.com/script/laOyn6aj-CB-ITH-ITL-Weis-Wave-Volume-Histogram/

## Description

Companion to the ITL/ITH wave finder. Shows volume in a histogram for each wave.

---

## Source Code

````pine
//@version=6
indicator("CB ITH / ITL Weis Wave Volume Histogram", overlay = false, format = format.volume, max_boxes_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fixed internal limits
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int BAR_BUFFER_SIZE = 50000
const int MAX_STORED_STRUCTURAL_PIVOTS = 1200

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Histogram input group
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const string GROUP_VOLUME = "ITH / ITL Weis Wave Volume Histogram"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Histogram inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showDevelopingWaveHistogram = input.bool(
     true,
     "Include Developing Wave",
     group = GROUP_VOLUME
)

waveVolumeDivisor = input.float(
     1.0,
     "Wave Volume Divisor",
     minval = 0.000001,
     step = 1.0,
     group = GROUP_VOLUME
)

upWaveHistogramColor = input.color(
     color.red,
     "Up Wave Histogram Color (ITL to ITH)",
     group = GROUP_VOLUME
)

downWaveHistogramColor = input.color(
     color.lime,
     "Down Wave Histogram Color (ITH to ITL)",
     group = GROUP_VOLUME
)

confirmedHistogramTransparency = input.int(
     72,
     "Confirmed Bar Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_VOLUME
)

developingHistogramTransparency = input.int(
     62,
     "Developing Bar Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_VOLUME
)

maxHistogramBars = input.int(
     500,
     "Maximum Bars to Display",
     minval = 50,
     maxval = 500,
     group = GROUP_VOLUME
)

showHistogramBaseline = input.bool(
     false,
     "Show Zero Baseline",
     group = GROUP_VOLUME
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Histogram colors and cumulative volume
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color confirmedUpHistogramColor =
     color.new(
          upWaveHistogramColor,
          confirmedHistogramTransparency
     )

color confirmedDownHistogramColor =
     color.new(
          downWaveHistogramColor,
          confirmedHistogramTransparency
     )

color developingUpHistogramColor =
     color.new(
          upWaveHistogramColor,
          developingHistogramTransparency
     )

color developingDownHistogramColor =
     color.new(
          downWaveHistogramColor,
          developingHistogramTransparency
     )

float cumulativeVolume =
     ta.cum(
          nz(volume, 0.0)
     )

plot(
     showHistogramBaseline ? 0.0 : na,
     title = "Wave Volume Zero Baseline",
     color = color.new(color.gray, 75),
     linewidth = 1
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Circular bar-data buffer
//
// Stores actual bar data so inferred bridge pivots can
// be reconstructed from historical highs and lows.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

varip bufferedBars =
     array.new_int(BAR_BUFFER_SIZE)

varip bufferedTimes =
     array.new_int(BAR_BUFFER_SIZE)

varip bufferedHighs =
     array.new_float(BAR_BUFFER_SIZE)

varip bufferedLows =
     array.new_float(BAR_BUFFER_SIZE)

varip bufferedCumVolumes =
     array.new_float(BAR_BUFFER_SIZE)

int currentBufferSlot =
     bar_index % BAR_BUFFER_SIZE

array.set(
     bufferedBars,
     currentBufferSlot,
     bar_index
)

array.set(
     bufferedTimes,
     currentBufferSlot,
     time
)

array.set(
     bufferedHighs,
     currentBufferSlot,
     high
)

array.set(
     bufferedLows,
     currentBufferSlot,
     low
)

array.set(
     bufferedCumVolumes,
     currentBufferSlot,
     cumulativeVolume
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Buffered-bar access helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_barIsBuffered(int targetBar) =>
    bool valid = false

    if targetBar >= 0 and
       targetBar <= bar_index and
       bar_index - targetBar < BAR_BUFFER_SIZE

        int slot =
             targetBar % BAR_BUFFER_SIZE

        valid :=
             array.get(
                  bufferedBars,
                  slot
             ) == targetBar

    valid

f_getBufferedTime(int targetBar) =>
    int result = na

    if f_barIsBuffered(targetBar)
        result :=
             array.get(
                  bufferedTimes,
                  targetBar % BAR_BUFFER_SIZE
             )

    result

f_getBufferedHigh(int targetBar) =>
    float result = na

    if f_barIsBuffered(targetBar)
        result :=
             array.get(
                  bufferedHighs,
                  targetBar % BAR_BUFFER_SIZE
             )

    result

f_getBufferedLow(int targetBar) =>
    float result = na

    if f_barIsBuffered(targetBar)
        result :=
             array.get(
                  bufferedLows,
                  targetBar % BAR_BUFFER_SIZE
             )

    result

f_getBufferedCumVolume(int targetBar) =>
    float result = na

    if f_barIsBuffered(targetBar)
        result :=
             array.get(
                  bufferedCumVolumes,
                  targetBar % BAR_BUFFER_SIZE
             )

    result

f_isBufferedFractalHigh(int targetBar) =>
    bool result = false

    if f_barIsBuffered(targetBar - 1) and
       f_barIsBuffered(targetBar) and
       f_barIsBuffered(targetBar + 1)

        float previousHigh =
             f_getBufferedHigh(
                  targetBar - 1
             )

        float candidateHigh =
             f_getBufferedHigh(
                  targetBar
             )

        float nextHigh =
             f_getBufferedHigh(
                  targetBar + 1
             )

        result :=
             candidateHigh > previousHigh and
             candidateHigh > nextHigh

    result

f_isBufferedFractalLow(int targetBar) =>
    bool result = false

    if f_barIsBuffered(targetBar - 1) and
       f_barIsBuffered(targetBar) and
       f_barIsBuffered(targetBar + 1)

        float previousLow =
             f_getBufferedLow(
                  targetBar - 1
             )

        float candidateLow =
             f_getBufferedLow(
                  targetBar
             )

        float nextLow =
             f_getBufferedLow(
                  targetBar + 1
             )

        result :=
             candidateLow < previousLow and
             candidateLow < nextLow

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Find one opposite bridge between same-type pivots
//
// ITH → ITH:
//     Find the lowest low that is below both ITHs.
//
// ITL → ITL:
//     Find the highest high that is above both ITLs.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_findSingleBridge(
     int leftBar,
     float leftPrice,
     int rightBar,
     float rightPrice,
     int sameType
) =>
    int foundBar = na
    int foundTime = na
    float foundPrice = na
    float foundCumVolume = na

    int firstSearchBar =
         leftBar + 1

    int lastSearchBar =
         rightBar - 1

    bool rangeAvailable =
         firstSearchBar <= lastSearchBar and
         f_barIsBuffered(firstSearchBar) and
         f_barIsBuffered(lastSearchBar)

    if rangeAvailable
        for candidateBar = firstSearchBar to lastSearchBar
            float candidatePrice =
                 sameType == 1 ?
                 f_getBufferedLow(candidateBar) :
                 f_getBufferedHigh(candidateBar)

            bool better = false

            if not na(candidatePrice)
                if sameType == 1
                    better :=
                         candidatePrice <
                         math.min(
                              leftPrice,
                              rightPrice
                         ) and
                         (
                              na(foundPrice) or
                              candidatePrice <= foundPrice
                         )

                else
                    better :=
                         candidatePrice >
                         math.max(
                              leftPrice,
                              rightPrice
                         ) and
                         (
                              na(foundPrice) or
                              candidatePrice >= foundPrice
                         )

            if better
                foundBar := candidateBar

                foundTime :=
                     f_getBufferedTime(
                          candidateBar
                     )

                foundPrice :=
                     candidatePrice

                foundCumVolume :=
                     f_getBufferedCumVolume(
                          candidateBar
                     )

    bool found =
         not na(foundBar)

    [foundBar, foundTime, foundPrice, foundCumVolume, found]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Find two bridges for:
//
//     ITH → higher ITL
//
// Required sequence:
//
//     ITH → low → high → ITL
//
// Candidate quality:
//
//     3 = low and high are both normal fractals
//     2 = exactly one is a normal fractal
//     1 = both are raw bar extremes
//
// Within the highest quality, use the largest internal
// low-to-high swing.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_findLowThenHigh(
     int leftBar,
     float leftPrice,
     int rightBar,
     float rightPrice
) =>
    int rawLowBar = na
    int rawLowTime = na
    float rawLowPrice = na
    float rawLowCumVolume = na

    int fractalLowBar = na
    int fractalLowTime = na
    float fractalLowPrice = na
    float fractalLowCumVolume = na

    int bestLowBar = na
    int bestLowTime = na
    float bestLowPrice = na
    float bestLowCumVolume = na

    int bestHighBar = na
    int bestHighTime = na
    float bestHighPrice = na
    float bestHighCumVolume = na

    int bestQuality = 0
    float bestSwing = na

    int firstSearchBar =
         leftBar + 1

    int lastSearchBar =
         rightBar - 1

    bool rangeAvailable =
         firstSearchBar < lastSearchBar and
         f_barIsBuffered(firstSearchBar) and
         f_barIsBuffered(lastSearchBar)

    if rangeAvailable
        for candidateBar = firstSearchBar to lastSearchBar
            // Evaluate the current bar as the high before
            // allowing it to become the running low. This
            // guarantees that the low occurs before the high.
            float candidateHigh =
                 f_getBufferedHigh(
                      candidateBar
                 )

            bool candidateIsFractalHigh =
                 f_isBufferedFractalHigh(
                      candidateBar
                 )

            if not na(candidateHigh) and
               candidateHigh > rightPrice

                // Fractal low → fractal high.
                if candidateIsFractalHigh and
                   not na(fractalLowBar)

                    float candidateSwing =
                         candidateHigh -
                         fractalLowPrice

                    bool betterPair =
                         bestQuality < 3 or
                         (
                              bestQuality == 3 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 3
                        bestSwing := candidateSwing

                        bestLowBar :=
                             fractalLowBar

                        bestLowTime :=
                             fractalLowTime

                        bestLowPrice :=
                             fractalLowPrice

                        bestLowCumVolume :=
                             fractalLowCumVolume

                        bestHighBar :=
                             candidateBar

                        bestHighTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestHighPrice :=
                             candidateHigh

                        bestHighCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Raw low → fractal high.
                if candidateIsFractalHigh and
                   not na(rawLowBar)

                    float candidateSwing =
                         candidateHigh -
                         rawLowPrice

                    bool betterPair =
                         bestQuality < 2 or
                         (
                              bestQuality == 2 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 2
                        bestSwing := candidateSwing

                        bestLowBar :=
                             rawLowBar

                        bestLowTime :=
                             rawLowTime

                        bestLowPrice :=
                             rawLowPrice

                        bestLowCumVolume :=
                             rawLowCumVolume

                        bestHighBar :=
                             candidateBar

                        bestHighTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestHighPrice :=
                             candidateHigh

                        bestHighCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Fractal low → raw high.
                if not na(fractalLowBar)
                    float candidateSwing =
                         candidateHigh -
                         fractalLowPrice

                    bool betterPair =
                         bestQuality < 2 or
                         (
                              bestQuality == 2 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 2
                        bestSwing := candidateSwing

                        bestLowBar :=
                             fractalLowBar

                        bestLowTime :=
                             fractalLowTime

                        bestLowPrice :=
                             fractalLowPrice

                        bestLowCumVolume :=
                             fractalLowCumVolume

                        bestHighBar :=
                             candidateBar

                        bestHighTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestHighPrice :=
                             candidateHigh

                        bestHighCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Raw low → raw high.
                if not na(rawLowBar)
                    float candidateSwing =
                         candidateHigh -
                         rawLowPrice

                    bool betterPair =
                         bestQuality < 1 or
                         (
                              bestQuality == 1 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 1
                        bestSwing := candidateSwing

                        bestLowBar :=
                             rawLowBar

                        bestLowTime :=
                             rawLowTime

                        bestLowPrice :=
                             rawLowPrice

                        bestLowCumVolume :=
                             rawLowCumVolume

                        bestHighBar :=
                             candidateBar

                        bestHighTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestHighPrice :=
                             candidateHigh

                        bestHighCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

            // Update running low candidates after evaluating
            // the current bar as a possible high.
            float candidateLow =
                 f_getBufferedLow(
                      candidateBar
                 )

            bool candidateIsFractalLow =
                 f_isBufferedFractalLow(
                      candidateBar
                 )

            if not na(candidateLow) and
               candidateLow < leftPrice

                if na(rawLowPrice) or
                   candidateLow <= rawLowPrice

                    rawLowBar := candidateBar

                    rawLowTime :=
                         f_getBufferedTime(
                              candidateBar
                         )

                    rawLowPrice :=
                         candidateLow

                    rawLowCumVolume :=
                         f_getBufferedCumVolume(
                              candidateBar
                         )

                if candidateIsFractalLow and
                   (
                        na(fractalLowPrice) or
                        candidateLow <= fractalLowPrice
                   )

                    fractalLowBar :=
                         candidateBar

                    fractalLowTime :=
                         f_getBufferedTime(
                              candidateBar
                         )

                    fractalLowPrice :=
                         candidateLow

                    fractalLowCumVolume :=
                         f_getBufferedCumVolume(
                              candidateBar
                         )

    bool found =
         not na(bestLowBar) and
         not na(bestHighBar)

    [bestLowBar, bestLowTime, bestLowPrice, bestLowCumVolume, bestHighBar, bestHighTime, bestHighPrice, bestHighCumVolume, found]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Find two bridges for:
//
//     ITL → lower ITH
//
// Required sequence:
//
//     ITL → high → low → ITH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_findHighThenLow(
     int leftBar,
     float leftPrice,
     int rightBar,
     float rightPrice
) =>
    int rawHighBar = na
    int rawHighTime = na
    float rawHighPrice = na
    float rawHighCumVolume = na

    int fractalHighBar = na
    int fractalHighTime = na
    float fractalHighPrice = na
    float fractalHighCumVolume = na

    int bestHighBar = na
    int bestHighTime = na
    float bestHighPrice = na
    float bestHighCumVolume = na

    int bestLowBar = na
    int bestLowTime = na
    float bestLowPrice = na
    float bestLowCumVolume = na

    int bestQuality = 0
    float bestSwing = na

    int firstSearchBar =
         leftBar + 1

    int lastSearchBar =
         rightBar - 1

    bool rangeAvailable =
         firstSearchBar < lastSearchBar and
         f_barIsBuffered(firstSearchBar) and
         f_barIsBuffered(lastSearchBar)

    if rangeAvailable
        for candidateBar = firstSearchBar to lastSearchBar
            // Evaluate the current bar as the low before
            // allowing it to become the running high. This
            // guarantees that the high occurs before the low.
            float candidateLow =
                 f_getBufferedLow(
                      candidateBar
                 )

            bool candidateIsFractalLow =
                 f_isBufferedFractalLow(
                      candidateBar
                 )

            if not na(candidateLow) and
               candidateLow < rightPrice

                // Fractal high → fractal low.
                if candidateIsFractalLow and
                   not na(fractalHighBar)

                    float candidateSwing =
                         fractalHighPrice -
                         candidateLow

                    bool betterPair =
                         bestQuality < 3 or
                         (
                              bestQuality == 3 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 3
                        bestSwing := candidateSwing

                        bestHighBar :=
                             fractalHighBar

                        bestHighTime :=
                             fractalHighTime

                        bestHighPrice :=
                             fractalHighPrice

                        bestHighCumVolume :=
                             fractalHighCumVolume

                        bestLowBar :=
                             candidateBar

                        bestLowTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestLowPrice :=
                             candidateLow

                        bestLowCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Raw high → fractal low.
                if candidateIsFractalLow and
                   not na(rawHighBar)

                    float candidateSwing =
                         rawHighPrice -
                         candidateLow

                    bool betterPair =
                         bestQuality < 2 or
                         (
                              bestQuality == 2 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 2
                        bestSwing := candidateSwing

                        bestHighBar :=
                             rawHighBar

                        bestHighTime :=
                             rawHighTime

                        bestHighPrice :=
                             rawHighPrice

                        bestHighCumVolume :=
                             rawHighCumVolume

                        bestLowBar :=
                             candidateBar

                        bestLowTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestLowPrice :=
                             candidateLow

                        bestLowCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Fractal high → raw low.
                if not na(fractalHighBar)
                    float candidateSwing =
                         fractalHighPrice -
                         candidateLow

                    bool betterPair =
                         bestQuality < 2 or
                         (
                              bestQuality == 2 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 2
                        bestSwing := candidateSwing

                        bestHighBar :=
                             fractalHighBar

                        bestHighTime :=
                             fractalHighTime

                        bestHighPrice :=
                             fractalHighPrice

                        bestHighCumVolume :=
                             fractalHighCumVolume

                        bestLowBar :=
                             candidateBar

                        bestLowTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestLowPrice :=
                             candidateLow

                        bestLowCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

                // Raw high → raw low.
                if not na(rawHighBar)
                    float candidateSwing =
                         rawHighPrice -
                         candidateLow

                    bool betterPair =
                         bestQuality < 1 or
                         (
                              bestQuality == 1 and
                              (
                                   na(bestSwing) or
                                   candidateSwing > bestSwing
                              )
                         )

                    if betterPair
                        bestQuality := 1
                        bestSwing := candidateSwing

                        bestHighBar :=
                             rawHighBar

                        bestHighTime :=
                             rawHighTime

                        bestHighPrice :=
                             rawHighPrice

                        bestHighCumVolume :=
                             rawHighCumVolume

                        bestLowBar :=
                             candidateBar

                        bestLowTime :=
                             f_getBufferedTime(
                                  candidateBar
                             )

                        bestLowPrice :=
                             candidateLow

                        bestLowCumVolume :=
                             f_getBufferedCumVolume(
                                  candidateBar
                             )

            // Update running high candidates after evaluating
            // the current bar as a possible low.
            float candidateHigh =
                 f_getBufferedHigh(
                      candidateBar
                 )

            bool candidateIsFractalHigh =
                 f_isBufferedFractalHigh(
                      candidateBar
                 )

            if not na(candidateHigh) and
               candidateHigh > leftPrice

                if na(rawHighPrice) or
                   candidateHigh >= rawHighPrice

                    rawHighBar :=
                         candidateBar

                    rawHighTime :=
                         f_getBufferedTime(
                              candidateBar
                         )

                    rawHighPrice :=
                         candidateHigh

                    rawHighCumVolume :=
                         f_getBufferedCumVolume(
                              candidateBar
                         )

                if candidateIsFractalHigh and
                   (
                        na(fractalHighPrice) or
                        candidateHigh >= fractalHighPrice
                   )

                    fractalHighBar :=
                         candidateBar

                    fractalHighTime :=
                         f_getBufferedTime(
                              candidateBar
                         )

                    fractalHighPrice :=
                         candidateHigh

                    fractalHighCumVolume :=
                         f_getBufferedCumVolume(
                              candidateBar
                         )

    bool found =
         not na(bestHighBar) and
         not na(bestLowBar)

    [bestHighBar, bestHighTime, bestHighPrice, bestHighCumVolume, bestLowBar, bestLowTime, bestLowPrice, bestLowCumVolume, found]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Recent confirmed high-fractal storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var highBars =
     array.new_int()

var highTimes =
     array.new_int()

var highPrices =
     array.new_float()

var highCumVolumes =
     array.new_float()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Recent confirmed low-fractal storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var lowBars =
     array.new_int()

var lowTimes =
     array.new_int()

var lowPrices =
     array.new_float()

var lowCumVolumes =
     array.new_float()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confirmed structural pivot storage
//
// Type:
//
//      1 = ITH
//     -1 = ITL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var pivotBars =
     array.new_int()

var pivotTimes =
     array.new_int()

var pivotPrices =
     array.new_float()

var pivotTypes =
     array.new_int()

var pivotCumVolumes =
     array.new_float()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Geometrically valid alternating wave sequence
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var cleanBars =
     array.new_int()

var cleanTimes =
     array.new_int()

var cleanPrices =
     array.new_float()

var cleanTypes =
     array.new_int()

var cleanCumVolumes =
     array.new_float()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Histogram-object storage and structure state
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var waveHistogramBoxes =
     array.new_box()

var box currentWaveHistogramBox = na
var int histogramLastDrawnBar = na
var bool structureDirty = true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Drawing and array helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_appendCleanPivot(
     int pivotBar,
     int pivotTime,
     float pivotPrice,
     int pivotType,
     float pivotCumVolume
) =>
    array.push(
         cleanBars,
         pivotBar
    )

    array.push(
         cleanTimes,
         pivotTime
    )

    array.push(
         cleanPrices,
         pivotPrice
    )

    array.push(
         cleanTypes,
         pivotType
    )

    array.push(
         cleanCumVolumes,
         pivotCumVolume
    )

f_replaceLastCleanPivot(
     int pivotBar,
     int pivotTime,
     float pivotPrice,
     int pivotType,
     float pivotCumVolume
) =>
    int lastIndex =
         array.size(cleanBars) - 1

    array.set(
         cleanBars,
         lastIndex,
         pivotBar
    )

    array.set(
         cleanTimes,
         lastIndex,
         pivotTime
    )

    array.set(
         cleanPrices,
         lastIndex,
         pivotPrice
    )

    array.set(
         cleanTypes,
         lastIndex,
         pivotType
    )

    array.set(
         cleanCumVolumes,
         lastIndex,
         pivotCumVolume
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Insert a confirmed structural pivot chronologically
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_insertPivotSorted(
     int pivotBar,
     int pivotTime,
     float pivotPrice,
     int pivotType,
     float pivotCumVolume
) =>
    int count =
         array.size(pivotBars)

    int insertAt =
         count

    bool duplicate =
         false

    if count > 0
        for i = 0 to count - 1
            int existingBar =
                 array.get(
                      pivotBars,
                      i
                 )

            int existingType =
                 array.get(
                      pivotTypes,
                      i
                 )

            if existingBar == pivotBar and
               existingType == pivotType

                duplicate := true
                break

            if pivotBar < existingBar
                insertAt := i
                break

    if not duplicate
        array.insert(
             pivotBars,
             insertAt,
             pivotBar
        )

        array.insert(
             pivotTimes,
             insertAt,
             pivotTime
        )

        array.insert(
             pivotPrices,
             insertAt,
             pivotPrice
        )

        array.insert(
             pivotTypes,
             insertAt,
             pivotType
        )

        array.insert(
             pivotCumVolumes,
             insertAt,
             pivotCumVolume
        )

        while array.size(pivotBars) >
              MAX_STORED_STRUCTURAL_PIVOTS

            array.shift(pivotBars)
            array.shift(pivotTimes)
            array.shift(pivotPrices)
            array.shift(pivotTypes)
            array.shift(pivotCumVolumes)

    not duplicate

f_deleteWaveHistogram() =>
    while array.size(waveHistogramBoxes) > 0
        box.delete(
             array.pop(waveHistogramBoxes)
        )

f_trimWaveHistogram() =>
    while array.size(waveHistogramBoxes) > maxHistogramBars
        box.delete(
             array.shift(waveHistogramBoxes)
        )

f_waveHistogramColor(
     int waveEndType,
     bool developing
) =>
    color result =
         waveEndType == 1 ?
         (
              developing ?
              developingUpHistogramColor :
              confirmedUpHistogramColor
         ) :
         (
              developing ?
              developingDownHistogramColor :
              confirmedDownHistogramColor
         )

    result

f_drawWaveHistogramBar(
     int targetBar,
     float rawCumulativeWaveVolume,
     int waveEndType,
     bool developing
) =>
    float scaledWaveVolume =
         math.max(
              rawCumulativeWaveVolume /
              waveVolumeDivisor,
              0.0
         )

    color fillColor =
         f_waveHistogramColor(
              waveEndType,
              developing
         )

    box histogramBar =
         box.new(
              left = targetBar,
              top = scaledWaveVolume,
              right = targetBar + 1,
              bottom = 0.0,
              xloc = xloc.bar_index,
              border_color = color.new(fillColor, 100),
              border_width = 1,
              bgcolor = fillColor
         )

    array.push(
         waveHistogramBoxes,
         histogramBar
    )

    histogramBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Build the alternating, directionally valid sequence
//
// Case 1:
//     Opposite types with correct geometry connect directly.
//
// Case 2:
//     Same structural types insert one opposite bridge.
//
// Case 3:
//     ITH followed by higher ITL inserts low then high.
//
// Case 4:
//     ITL followed by lower ITH inserts high then low.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_buildCleanPivotSequence() =>
    array.clear(cleanBars)
    array.clear(cleanTimes)
    array.clear(cleanPrices)
    array.clear(cleanTypes)
    array.clear(cleanCumVolumes)

    int count =
         array.size(pivotBars)

    if count > 0
        for i = 0 to count - 1
            int candidateBar =
                 array.get(
                      pivotBars,
                      i
                 )

            int candidateTime =
                 array.get(
                      pivotTimes,
                      i
                 )

            float candidatePrice =
                 array.get(
                      pivotPrices,
                      i
                 )

            int candidateType =
                 array.get(
                      pivotTypes,
                      i
                 )

            float candidateCumVolume =
                 array.get(
                      pivotCumVolumes,
                      i
                 )

            int cleanCount =
                 array.size(cleanBars)

            if cleanCount == 0
                f_appendCleanPivot(
                     candidateBar,
                     candidateTime,
                     candidatePrice,
                     candidateType,
                     candidateCumVolume
                )

            else
                int lastIndex =
                     cleanCount - 1

                int lastBar =
                     array.get(
                          cleanBars,
                          lastIndex
                     )

                float lastPrice =
                     array.get(
                          cleanPrices,
                          lastIndex
                     )

                int lastType =
                     array.get(
                          cleanTypes,
                          lastIndex
                     )

                // Two pivots on one bar cannot form a normal
                // chronological Zig Zag segment.
                if candidateBar == lastBar
                    if candidateType == lastType
                        bool candidateMoreExtreme =
                             candidateType == 1 ?
                             candidatePrice > lastPrice :
                             candidatePrice < lastPrice

                        if candidateMoreExtreme
                            f_replaceLastCleanPivot(
                                 candidateBar,
                                 candidateTime,
                                 candidatePrice,
                                 candidateType,
                                 candidateCumVolume
                            )

                else if candidateBar > lastBar
                    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // Same structural type
                    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                    if candidateType == lastType
                        [bridgeBar, bridgeTime, bridgePrice, bridgeCumVolume, bridgeFound] = f_findSingleBridge(lastBar, lastPrice, candidateBar, candidatePrice, candidateType)

                        if bridgeFound
                            f_appendCleanPivot(
                                 bridgeBar,
                                 bridgeTime,
                                 bridgePrice,
                                 -candidateType,
                                 bridgeCumVolume
                            )

                            f_appendCleanPivot(
                                 candidateBar,
                                 candidateTime,
                                 candidatePrice,
                                 candidateType,
                                 candidateCumVolume
                            )

                        else
                            // An actual directional reversal cannot
                            // be formed. Retain only the more extreme
                            // same-type wave endpoint.
                            bool candidateMoreExtreme =
                                 candidateType == 1 ?
                                 candidatePrice > lastPrice :
                                 candidatePrice < lastPrice

                            if candidateMoreExtreme
                                f_replaceLastCleanPivot(
                                     candidateBar,
                                     candidateTime,
                                     candidatePrice,
                                     candidateType,
                                     candidateCumVolume
                                )

                    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // Opposite structural types
                    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                    else
                        bool directGeometryValid =
                             lastType == 1 ?
                             candidatePrice < lastPrice :
                             candidatePrice > lastPrice

                        // Normal ITH → lower ITL or
                        // normal ITL → higher ITH.
                        if directGeometryValid
                            f_appendCleanPivot(
                                 candidateBar,
                                 candidateTime,
                                 candidatePrice,
                                 candidateType,
                                 candidateCumVolume
                            )

                        // ITH → higher ITL.
                        //
                        // Repair:
                        //
                        // ITH → low → high → ITL.
                        else if lastType == 1
                            [bridgeLowBar, bridgeLowTime, bridgeLowPrice, bridgeLowCumVolume, bridgeHighBar, bridgeHighTime, bridgeHighPrice, bridgeHighCumVolume, bridgePairFound] = f_findLowThenHigh(lastBar, lastPrice, candidateBar, candidatePrice)

                            if bridgePairFound
                                f_appendCleanPivot(
                                     bridgeLowBar,
                                     bridgeLowTime,
                                     bridgeLowPrice,
                                     -1,
                                     bridgeLowCumVolume
                                )

                                f_appendCleanPivot(
                                     bridgeHighBar,
                                     bridgeHighTime,
                                     bridgeHighPrice,
                                     1,
                                     bridgeHighCumVolume
                                )

                                f_appendCleanPivot(
                                     candidateBar,
                                     candidateTime,
                                     candidatePrice,
                                     candidateType,
                                     candidateCumVolume
                                )

                        // ITL → lower ITH.
                        //
                        // Repair:
                        //
                        // ITL → high → low → ITH.
                        else
                            [mirrorHighBar, mirrorHighTime, mirrorHighPrice, mirrorHighCumVolume, mirrorLowBar, mirrorLowTime, mirrorLowPrice, mirrorLowCumVolume, mirrorPairFound] = f_findHighThenLow(lastBar, lastPrice, candidateBar, candidatePrice)

                            if mirrorPairFound
                                f_appendCleanPivot(
                                     mirrorHighBar,
                                     mirrorHighTime,
                                     mirrorHighPrice,
                                     1,
                                     mirrorHighCumVolume
                                )

                                f_appendCleanPivot(
                                     mirrorLowBar,
                                     mirrorLowTime,
                                     mirrorLowPrice,
                                     -1,
                                     mirrorLowCumVolume
                                )

                                f_appendCleanPivot(
                                     candidateBar,
                                     candidateTime,
                                     candidatePrice,
                                     candidateType,
                                     candidateCumVolume
                                )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Rebuild the internal alternating ITH / ITL structure
//
// No price-chart objects are drawn. The cleaned pivot
// sequence exists only to define histogram wave boundaries.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_rebuildStructure() =>
    f_buildCleanPivotSequence()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Rebuild the ITH / ITL Weis-wave histogram
//
// Each histogram column is cumulative volume from the
// wave's starting pivot through that bar.
//
// Starting pivot bar: excluded.
// Ending pivot bar:   included.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_rebuildWaveHistogram() =>
    f_deleteWaveHistogram()

    int cleanCount =
         array.size(cleanBars)

    int firstVisibleBar =
         math.max(
              0,
              bar_index - maxHistogramBars + 1
         )

    if cleanCount >= 2
        for endIndex = 1 to cleanCount - 1
            int startIndex =
                 endIndex - 1

            int startBar =
                 array.get(
                      cleanBars,
                      startIndex
                 )

            float startPrice =
                 array.get(
                      cleanPrices,
                      startIndex
                 )

            int startType =
                 array.get(
                      cleanTypes,
                      startIndex
                 )

            float startCumVolume =
                 array.get(
                      cleanCumVolumes,
                      startIndex
                 )

            int endBar =
                 array.get(
                      cleanBars,
                      endIndex
                 )

            float endPrice =
                 array.get(
                      cleanPrices,
                      endIndex
                 )

            int endType =
                 array.get(
                      cleanTypes,
                      endIndex
                 )

            bool typesAlternate =
                 startType != endType

            bool directionValid =
                 startType == 1 ?
                 endPrice < startPrice :
                 endPrice > startPrice

            bool legValid =
                 typesAlternate and
                 directionValid

            int firstWaveBar =
                 math.max(
                      startBar + 1,
                      firstVisibleBar
                 )

            int lastWaveBar =
                 math.min(
                      endBar,
                      bar_index
                 )

            if legValid and firstWaveBar <= lastWaveBar
                for targetBar = firstWaveBar to lastWaveBar
                    float targetCumVolume =
                         f_getBufferedCumVolume(
                              targetBar
                         )

                    if not na(targetCumVolume)
                        float rawCumulativeWaveVolume =
                             math.max(
                                  targetCumVolume -
                                  startCumVolume,
                                  0.0
                             )

                        f_drawWaveHistogramBar(
                             targetBar,
                             rawCumulativeWaveVolume,
                             endType,
                             false
                        )

    if showDevelopingWaveHistogram and
       cleanCount > 0

        int lastIndex =
             cleanCount - 1

        int lastPivotBar =
             array.get(
                  cleanBars,
                  lastIndex
             )

        int lastPivotType =
             array.get(
                  cleanTypes,
                  lastIndex
             )

        float lastPivotCumVolume =
             array.get(
                  cleanCumVolumes,
                  lastIndex
             )

        int firstDevelopingBar =
             math.max(
                  lastPivotBar + 1,
                  firstVisibleBar
             )

        if firstDevelopingBar <= bar_index
            for targetBar = firstDevelopingBar to bar_index
                float targetCumVolume =
                     f_getBufferedCumVolume(
                          targetBar
                     )

                if not na(targetCumVolume)
                    float rawCumulativeWaveVolume =
                         math.max(
                              targetCumVolume -
                              lastPivotCumVolume,
                              0.0
                         )

                    f_drawWaveHistogramBar(
                         targetBar,
                         rawCumulativeWaveVolume,
                         -lastPivotType,
                         true
                    )

    f_trimWaveHistogram()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Standard three-bar fractal detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool isFractalHigh =
     bar_index >= 2 and
     high[1] > high[2] and
     high[1] > high

bool isFractalLow =
     bar_index >= 2 and
     low[1] < low[2] and
     low[1] < low

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// High-fractal processing and ITH detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed and isFractalHigh
    int fractalBar =
         bar_index - 1

    int fractalTime =
         time[1]

    float fractalPrice =
         high[1]

    float fractalCumVolume =
         cumulativeVolume[1]

    array.push(
         highBars,
         fractalBar
    )

    array.push(
         highTimes,
         fractalTime
    )

    array.push(
         highPrices,
         fractalPrice
    )

    array.push(
         highCumVolumes,
         fractalCumVolume
    )

    if array.size(highBars) > 3
        array.shift(highBars)
        array.shift(highTimes)
        array.shift(highPrices)
        array.shift(highCumVolumes)

    if array.size(highPrices) == 3
        int midBar =
             array.get(
                  highBars,
                  1
             )


        int midTime =
             array.get(
                  highTimes,
                  1
             )


        float leftHigh =
             array.get(
                  highPrices,
                  0
             )

        float midHigh =
             array.get(
                  highPrices,
                  1
             )

        float rightHigh =
             array.get(
                  highPrices,
                  2
             )

        float midCumVolume =
             array.get(
                  highCumVolumes,
                  1
             )

        bool isITH =
             midHigh > leftHigh and
             midHigh > rightHigh

        if isITH
            bool inserted =
                 f_insertPivotSorted(
                      midBar,
                      midTime,
                      midHigh,
                      1,
                      midCumVolume
                 )

            if inserted
                structureDirty := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Low-fractal processing and ITL detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed and isFractalLow
    int fractalBar =
         bar_index - 1

    int fractalTime =
         time[1]

    float fractalPrice =
         low[1]

    float fractalCumVolume =
         cumulativeVolume[1]

    array.push(
         lowBars,
         fractalBar
    )

    array.push(
         lowTimes,
         fractalTime
    )

    array.push(
         lowPrices,
         fractalPrice
    )

    array.push(
         lowCumVolumes,
         fractalCumVolume
    )

    if array.size(lowBars) > 3
        array.shift(lowBars)
        array.shift(lowTimes)
        array.shift(lowPrices)
        array.shift(lowCumVolumes)

    if array.size(lowPrices) == 3
        int midBar =
             array.get(
                  lowBars,
                  1
             )


        int midTime =
             array.get(
                  lowTimes,
                  1
             )


        float leftLow =
             array.get(
                  lowPrices,
                  0
             )

        float midLow =
             array.get(
                  lowPrices,
                  1
             )

        float rightLow =
             array.get(
                  lowPrices,
                  2
             )

        float midCumVolume =
             array.get(
                  lowCumVolumes,
                  1
             )

        bool isITL =
             midLow < leftLow and
             midLow < rightLow

        if isITL
            bool inserted =
                 f_insertPivotSorted(
                      midBar,
                      midTime,
                      midLow,
                      -1,
                      midCumVolume
                 )

            if inserted
                structureDirty := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confirmed structure rebuild and real-time histogram
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    bool structureWasDirty =
         structureDirty

    if structureDirty
        f_rebuildStructure()
        structureDirty := false

    int cleanCount =
         array.size(cleanBars)

    // A structural rebuild can retroactively move wave
    // boundaries or insert bridge pivots. Rebuild all recent
    // histogram columns in that case. Otherwise, append one
    // column on a new bar and only update the live column on
    // realtime ticks.
    bool needFullHistogramRebuild =
         structureWasDirty or
         na(histogramLastDrawnBar)

    if needFullHistogramRebuild
        f_rebuildWaveHistogram()

        currentWaveHistogramBox := na

        if array.size(waveHistogramBoxes) > 0
            box possibleCurrentBox =
                 array.get(
                      waveHistogramBoxes,
                      array.size(waveHistogramBoxes) - 1
                 )

            if box.get_left(possibleCurrentBox) == bar_index
                currentWaveHistogramBox :=
                     possibleCurrentBox

        histogramLastDrawnBar :=
             bar_index

    else if cleanCount > 0
        int lastIndex =
             cleanCount - 1

        int lastPivotBar =
             array.get(
                  cleanBars,
                  lastIndex
             )

        int lastPivotType =
             array.get(
                  cleanTypes,
                  lastIndex
             )

        float lastPivotCumVolume =
             array.get(
                  cleanCumVolumes,
                  lastIndex
             )

        bool currentBarBelongsToDevelopingWave =
             showDevelopingWaveHistogram and
             bar_index > lastPivotBar

        if currentBarBelongsToDevelopingWave
            float rawCurrentWaveVolume =
                 math.max(
                      cumulativeVolume -
                      lastPivotCumVolume,
                      0.0
                 )

            float scaledCurrentWaveVolume =
                 math.max(
                      rawCurrentWaveVolume /
                      waveVolumeDivisor,
                      0.0
                 )

            color currentHistogramColor =
                 f_waveHistogramColor(
                      -lastPivotType,
                      true
                 )

            if histogramLastDrawnBar != bar_index
                currentWaveHistogramBox :=
                     f_drawWaveHistogramBar(
                          bar_index,
                          rawCurrentWaveVolume,
                          -lastPivotType,
                          true
                     )

                f_trimWaveHistogram()

                histogramLastDrawnBar :=
                     bar_index

            else if not na(currentWaveHistogramBox)
                box.set_top(
                     currentWaveHistogramBox,
                     scaledCurrentWaveVolume
                )

                box.set_bottom(
                     currentWaveHistogramBox,
                     0.0
                )

                box.set_bgcolor(
                     currentWaveHistogramBox,
                     currentHistogramColor
                )

                box.set_border_color(
                     currentWaveHistogramBox,
                     color.new(currentHistogramColor, 100)
                )

        else if histogramLastDrawnBar != bar_index
            currentWaveHistogramBox := na
            histogramLastDrawnBar := bar_index
````
