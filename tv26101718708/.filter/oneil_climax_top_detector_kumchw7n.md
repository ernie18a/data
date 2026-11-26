# O'Neil Climax Top Detector

- url: https://www.tradingview.com/script/KumcHw7n-O-Neil-Climax-Top-Detector/
- type: indicator
- pine_id: PUB;c7f6de2ee2f74b698e4220bb68f54ba5
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

[i]O'Neil Climax Top Detector[/i] plots the percentage distance of a price source from its simple moving average in a separate pane and flags the bars where three conditions associated with a climax top occur together: the price is extended into an upper band, it has run up rapidly over a short window, and the bar carries record volume. The histogram measures extension; the flag identifies where extension, runup, and volume coincide.


█ [b]HISTORY / BACKGROUND[/b]

The components are drawn from William J. O'Neil's discussion of climax (blow-off) tops in [i]How to Make Money in Stocks[/i]. O'Neil described a stock trading 70% to 100% or more above its 200-day moving average line (4th edition, page 264), a rapid price runup over roughly two to three weeks, and heavy volume on the advance as markers of a late-stage move. O'Neil presented these as qualitative, infrequently decisive sell pointers for individual growth leaders on the daily chart, not as a mechanical signal. This script operationalizes that description as a single bar-level test.


█ [b]HOW IT WORKS[/b]

On the chart timeframe the script computes, for each bar:

- The distance from the average: the simple moving average of the source over [i]SMA Length[/i], then percentage distance as (source minus average) divided by average, times 100. This is the histogram.
- The extension condition: the distance is at or above the lower band. In fixed mode the band is the [i]Fixed lower / upper band[/i] inputs (70 and 100). In adaptive mode the band is the symbol's own mean distance plus a number of standard deviations ([i]Adaptive lower / upper[/i]) over [i]Adaptive lookback[/i].
- The runup condition: the source's percentage gain over [i]Runup lookback[/i] bars is at or above [i]Min runup over lookback[/i].
- The volume condition: the bar's volume is a new high over [i]Volume record lookback[/i] bars. When [i]Require record-volume condition[/i] is off, this term is dropped.

A climax bar is the conjunction of all active conditions:

[pine]
climax = extCond and runCond and volTerm
[/pine]

Climax bars are recolored on the histogram and marked with a vertical line spanning the pane. Two alert conditions are exposed: one for the full climax conjunction, one for the distance reaching the lower band.


█ [b]HOW TO USE[/b]

Apply on the daily chart, the resolution on which O'Neil's band and runup window are defined. Read the histogram as the degree of extension above or below the average: bars above zero trade above the average, bars below zero trade below it. The lower and upper band lines bound the extension zone. A recolored bar with a vertical line marks where extension, runup, and volume align on the same bar. Treat a flag as a candidate for review of a late-stage move, not as an instruction.


█ [b]SETTINGS[/b]

- [i]Source[/i]: series used for the average and the distance. Default close.
- [i]SMA Length[/i]: period of the simple moving average. Default 200.
- [i]Extension band mode[/i]: fixed O'Neil 70/100 band, or per-symbol adaptive band. Default fixed.
- [i]Fixed lower / upper band[/i]: the band in fixed mode. Defaults 70 and 100.
- [i]Adaptive lookback[/i]: window for the adaptive band statistics. Default 504.
- [i]Adaptive lower / upper[/i]: standard deviations above the mean distance defining the adaptive band. Defaults 2.0 and 3.0.
- [i]Runup lookback[/i]: bars over which the runup is measured. Default 10.
- [i]Min runup over lookback[/i]: minimum percentage gain to satisfy the runup. Default 25.
- [i]Require record-volume condition[/i]: include the volume term. Default on.
- [i]Volume record lookback[/i]: window over which the bar's volume must be the highest. Default 50.


█ [b]WHAT MAKES IT ORIGINAL[/b]

A plain distance-from-moving-average histogram only shows extension. This script requires extension, a rapid runup, and record volume to coincide on the same bar before it flags, which is the conjunction O'Neil described qualitatively but is not present in a single distance plot. The adaptive band is a further departure: O'Neil's 70 to 100 figure is calibrated to growth leaders and is rarely reached on indices or low-volatility instruments, so the script can replace the fixed band with one derived from the symbol's own distance distribution, extending the concept beyond the instrument class it was written for.


█ [b]NOTES / LIMITATIONS[/b]

- Insufficient history: the average needs [i]SMA Length[/i] bars, the adaptive band needs [i]Adaptive lookback[/i] bars, and the runup needs [i]Runup lookback[/i] bars. Until those windows fill, the corresponding output is na and no flag appears.
- Volume-free symbols: on instruments without volume the record-volume term resolves to na and nothing flags. Turning off [i]Require record-volume condition[/i] runs the extension and runup pair only, a weaker two-condition test.
- Timeframe: the default band and runup window reflect O'Neil's daily-chart definition. On other resolutions the thresholds keep their numeric values but lose their reference meaning.
- Symbol class: the fixed band reflects individual growth-stock behavior. Use adaptive mode for indices, large-cap averages, and low-volatility instruments.
- Real-time bars: conditions confirm on bar close. On the forming bar a flag and its line can appear and disappear as price and volume change until the bar closes. Historical flags do not change.
- No higher-timeframe data: all computation is on the chart timeframe with no request.security and no lookahead.
- Object ceiling: the script retains up to 500 vertical lines. On long histories the oldest markers are dropped as new ones are added.
- The default thresholds are conceptual settings consistent with O'Neil's description, not optimized or validated values.

## Source Code

````pine
//@version=6
indicator("O'Neil Climax Top Detector", "Climax Top", overlay=false, max_lines_count=500)

// ---------- Inputs ----------
src      = input.source(close, "Source", group="General")
len      = input.int(200, "SMA Length", minval=1, group="General")

bandMode = input.string("Fixed (O'Neil 70/100)", "Extension band mode", options=["Fixed (O'Neil 70/100)", "Adaptive (per-symbol)"], group="Extension")
fixLo    = input.float(70.0, "Fixed lower band %", group="Extension")
fixHi    = input.float(100.0, "Fixed upper band %", group="Extension")
adaLen   = input.int(504, "Adaptive lookback (bars)", minval=20, group="Extension")
adaKLo   = input.float(2.0, "Adaptive lower (std devs)", step=0.1, group="Extension")
adaKHi   = input.float(3.0, "Adaptive upper (std devs)", step=0.1, group="Extension")

runLen   = input.int(10, "Runup lookback (bars)", minval=1, group="Runup")
runPct   = input.float(25.0, "Min runup over lookback %", group="Runup")

reqVol   = input.bool(true, "Require record-volume condition", group="Volume")
volLen   = input.int(50, "Volume record lookback (bars)", minval=1, group="Volume")

// ---------- Core distance from SMA ----------
ma  = ta.sma(src, len)
pct = (src - ma) / ma * 100.0

// ---------- Extension band ----------
isFixed   = bandMode == "Fixed (O'Neil 70/100)"
adaMean   = ta.sma(pct, adaLen)
adaSd     = ta.stdev(pct, adaLen)
lowerBand = isFixed ? fixLo : adaMean + adaKLo * adaSd
upperBand = isFixed ? fixHi : adaMean + adaKHi * adaSd
extCond   = pct >= lowerBand

// ---------- Rapid multi-week runup ----------
runup   = (src - src[runLen]) / src[runLen] * 100.0
runCond = runup >= runPct

// ---------- Record volume on the way up ----------
volCond = volume >= ta.highest(volume, volLen)
volTerm = not reqVol or volCond

// ---------- Conjunction ----------
climax = extCond and runCond and volTerm

// ---------- Plots ----------
col = climax ? color.new(color.orange, 0) : (pct >= 0 ? color.new(color.green, 0) : color.new(color.red, 0))
plot(pct, "% From SMA", color=col, style=plot.style_histogram)
plot(lowerBand, "Lower band", color=color.new(color.red, 0), linewidth=1)
plot(upperBand, "Upper band", color=color.new(color.maroon, 0), linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 50))

// ---------- Climax markers (vertical lines across pane) ----------
panTop = ta.highest(pct, 300)
panBot = ta.lowest(pct, 300)
if climax
    line.new(bar_index, panBot, bar_index, panTop, xloc=xloc.bar_index, color=color.new(color.orange, 0), width=1)

// ---------- Alerts ----------
alertcondition(climax,  "O'Neil climax top",   "Climax-top conjunction met: extension, runup and volume all aligned")
alertcondition(extCond, "Extension into band", "Distance from SMA has reached the lower extension band")
````
