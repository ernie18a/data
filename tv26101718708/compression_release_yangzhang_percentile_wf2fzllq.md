# Compression / Release - Yang-Zhang percentile

- url: https://www.tradingview.com/script/Wf2FzLLq/
- type: indicator
- pine_id: PUB;876c62d61ab547bc83e4dcdd727a66b3
- version: 1.0

## Description

A volatility-state indicator that shows whether a market is coiled or expanding. It needs no options data and works on any symbol — stocks, futures, FX, crypto.
To be clear about what it is: this measures realized volatility, not implied. It computes Yang-Zhang volatility (which uses the full OHLC bar, so it captures intrabar range and handles overnight gaps and drift — more efficient than a close-only measure) and ranks it against the instrument's own recent history. It describes the present and the past only; it carries no forward-looking or market-expectation information. Some scripts present the same math as a "synthetic IV rank," which is a misleading label — there is no implied volatility here.
What you see:
The yellow line is Compression, a 0–100 percentile. Low means current volatility is narrow relative to its own history (compressed, coiled); high means it is wide (already expanded). It uses ta.percentrank, the IV-percentile flavor that counts every day in the lookback, which is more robust to single-day spikes than range-based IV rank.
The columns are Release, drawn from a zero baseline: the change in the compression percentile over the release window. Green columns up mean volatility is expanding now; red columns down mean it is contracting now. Each bar is single-sided. This measures expansion as it happens — it does not predict it.
The green dot marks a Release start: the bar the compression line climbs back above the compression level, i.e. volatility leaving the squeeze zone.
How to read it together: the line tells you where you are (high or low in the volatility distribution), the columns tell you which way it is moving. The cleanest "loaded" state is the line near 20 with columns flat or turning green; the "already expanded" state is the line pinned near 100.
Inputs: Yang-Zhang window (default 20, ~1 month). Compression percentile lookback (default 252 ≈ 1 year — the standard IV rank/percentile convention; shorter reacts faster to regime shifts but loses the annual frame). Release window (default 10). Compression/expansion levels (20 / 80). Best read on a daily chart.
Limitations, stated plainly: direction is never implied — a release can resolve up or down, so a green column is not a buy signal. It is a measurement of state, not a timing signal; the line can stay near an extreme for a long time during sustained regimes and is not a reversal trigger. Pair it with your own trend tools for direction.

## Source Code

````pine
//@version=6
// =============================================================================
// Compression / Release - Yang-Zhang percentile
//
// Honest framing: this is REALIZED volatility, not implied. No options data
// needed; works on any symbol. It computes Yang-Zhang volatility (full OHLC, so
// it captures intrabar range and handles overnight gaps and drift) and ranks it
// against the instrument's own history. It describes the past only - no forward
// / market-expectation information. (Scripts that call the same math a
// "synthetic IV rank" are mislabeling it.)
//
//   Yellow line  Compression (0..100): the realized-vol percentile.
//     Low = volatility narrow vs its own history (compressed); high = wide.
//     Uses ta.percentrank (the IV-PERCENTILE flavor, counts every day), which is
//     more robust to single-day spikes than range-based IV RANK.
//
//   Columns      Release (zero baseline): change in the percentile over the
//     release window. Green up = expanding now; red down = contracting now.
//     Each bar is single-sided. Measures expansion as it happens; no prediction.
//
//   Green dot    Release start: compression crosses back above the compression
//     level (volatility leaving the squeeze zone).
//
// Read the line for WHERE you are and the columns for WHICH WAY it is moving.
// Direction is never implied - a release can resolve up or down, so a green
// column is not a buy signal. State reading, not a timing or reversal signal;
// the line can sit at an extreme for a long time. Best on a daily chart.
//
// Defaults and provenance:
//   compressionLookback 252  STANDARD - IV rank/percentile convention (~1 year:
//     tastytrade, ThinkorSwim). Pick one and keep it; don't backtest-optimize.
//   yzWindow 20              CONVENTION - usual ~1-month HV window.
//   compression/expansion 20/80  CONVENTION - common "low < 20, high > 80" zoning.
//   releaseWindow 10         JUDGEMENT - no documented standard; short enough to
//     stay a speed read and not overlap the long-lookback compression line.
// =============================================================================

indicator("Compression / Release - Yang-Zhang percentile", shorttitle = "Compress/Release", overlay = false)

// ----------------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------------
yzWindow            = input.int(20,  "Yang-Zhang window (bars). Smaller = faster but noisier; larger = steadier but laggier", minval = 5, group = "Volatility")
annualizationDays   = input.int(252, "Annualization days", minval = 1, group = "Volatility")

compressionLookback = input.int(252, "Percentile lookback (bars). History to rank against; 252 ~ 1y (IV-rank standard). Shorter reacts faster to regime shifts but loses the annual frame", minval = 20, group = "Compression")
compressionLevel    = input.float(20, "Compression level", group = "Compression")
expansionLevel      = input.float(80, "Expansion level",   group = "Compression")

showRelease         = input.bool(true, "Show release columns", group = "Release")
releaseWindow       = input.int(10, "Release change window (bars). Smaller = faster but noisier; larger = steadier but laggier", minval = 1, group = "Release")
markReleaseStart    = input.bool(true, "Mark release start", group = "Release")

showRealizedVol     = input.bool(false, "Show raw annualized vol % (own scale)", group = "Extras")

compressionColor    = input.color(#FFC107, "Compression line (yellow)",         group = "Appearance")
expandUpColor       = input.color(#4CAF50, "Release up = expanding (green)",     group = "Appearance")
contractDownColor   = input.color(#EF5350, "Release down = compressing (red)",   group = "Appearance")
realizedVolColor    = input.color(#FF9800, "Raw vol color",                      group = "Appearance")
markColor           = input.color(#00E676, "Release-start mark color",           group = "Appearance")
gridColor           = input.color(#787B86, "Reference lines",                    group = "Appearance")
lineWidth           = input.int(2, "Line width", minval = 1,                     group = "Appearance")

// ----------------------------------------------------------------------------
// Yang-Zhang realized volatility (annualized, percent points)
//   variance = overnight + yzWeight * open-to-close + (1 - yzWeight) * Rogers-Satchell
// ----------------------------------------------------------------------------
overnightRet      = math.log(open / close[1])
openCloseRet      = math.log(close / open)
rogersSatchell    = math.log(high / close) * math.log(high / open) + math.log(low / close) * math.log(low / open)

meanOvernight     = ta.sma(overnightRet, yzWindow)
meanOpenClose     = ta.sma(openCloseRet, yzWindow)
varOvernight      = ta.sma(math.pow(overnightRet - meanOvernight, 2), yzWindow) * yzWindow / (yzWindow - 1)
varOpenClose      = ta.sma(math.pow(openCloseRet - meanOpenClose, 2), yzWindow) * yzWindow / (yzWindow - 1)
varRogersSatchell = ta.sma(rogersSatchell, yzWindow)

yzWeight    = 0.34 / (1.34 + (yzWindow + 1) / (yzWindow - 1))
yzVariance  = varOvernight + yzWeight * varOpenClose + (1 - yzWeight) * varRogersSatchell
realizedVol = math.sqrt(math.max(yzVariance, 0) * annualizationDays) * 100

// ----------------------------------------------------------------------------
// Compression (percentile) and Release (zero-based change of the percentile)
// ----------------------------------------------------------------------------
compression     = ta.percentrank(realizedVol, compressionLookback)       // low = compressed
release         = compression - compression[releaseWindow]               // >0 expanding, <0 contracting
releaseBarColor = release >= 0 ? expandUpColor : contractDownColor
releaseStart    = ta.crossover(compression, compressionLevel)            // leaving the squeeze zone

// ----------------------------------------------------------------------------
// Reference lines
// ----------------------------------------------------------------------------
hline(expansionLevel,   "Expansion level",   color = color.new(gridColor, 30), linestyle = hline.style_dashed)
hline(compressionLevel, "Compression level", color = color.new(gridColor, 30), linestyle = hline.style_dashed)
hline(0,                "Release baseline",  color = color.new(gridColor, 50), linestyle = hline.style_dotted)

// ----------------------------------------------------------------------------
// Plots
// ----------------------------------------------------------------------------
plot(showRelease ? release : na, "Release", color = releaseBarColor, style = plot.style_columns)
plot(compression, "Compression", color = compressionColor, linewidth = lineWidth)
plot(showRealizedVol ? realizedVol : na, "Annualized vol %", color = color.new(realizedVolColor, 20), linewidth = 1)

plotshape(markReleaseStart and releaseStart ? compression : na, "Release start", shape.circle,
     location.absolute, color = markColor, size = size.tiny)
````
