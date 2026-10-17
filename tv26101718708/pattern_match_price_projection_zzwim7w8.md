# Pattern Match Price Projection

- url: https://www.tradingview.com/script/zzwiM7w8-Pattern-Match-Price-Projection/
- type: indicator
- pine_id: PUB;d11551ec62644e37b81bd70f55e75dcb
- version: 59.0

## Description

Pattern Match Price Projection is a price forecasting tool built on historical analog analysis. It scans past market data to find segments of price action that closely resemble the most recent pattern, then uses what followed those similar setups to construct a forward projection. Instead of relying on a single historical match, the model aggregates multiple high-quality analogs and produces an averaged path, along with adaptive upper and lower bands that reflect the dispersion of those outcomes.

The projection is derived from return-based pattern matching, with optional normalization to focus on structural similarity rather than magnitude. This allows the model to identify recurring behaviors across different volatility regimes and price levels. The result is a forward estimate that reflects how the market has historically behaved after similar conditions, rather than a purely reactive or lagging indicator.

A visual overlay of the current pattern is included to provide context for what the model is evaluating in real time, making it easier to interpret why a projection is being generated. The forecast itself can be anchored either to the most recent closing price or to a smoothed price reference, depending on preference. Non-repaint mode ensures the projection remains stable during an active candle, while live mode allows it to update dynamically as price evolves.

This tool is best used as a contextual framework for anticipating potential price paths based on historical precedent. It does not attempt to predict exact outcomes, but instead highlights probabilistic structure derived from prior market behavior.

## Source Code

````pine
//@version=6
indicator("Pattern Match Price Projection & Prediction", shorttitle="Price Projection", overlay=true, max_lines_count=500, max_bars_back=5000)

nonRepaint = input.bool(true, "Non-Repaint Mode", tooltip="When enabled, all pattern matching and calculations are anchored to the last closed bar instead of the live forming bar, so the projection does not repaint as the current candle updates. Disable to compute from the live bar, in which case values can shift intrabar until the bar closes.")

grpMain        = "Model"
patternLen     = input.int(10, "Pattern Length", minval=2, maxval=200, group=grpMain, tooltip="Number of bars in the current pattern that the indicator tries to match against history. The same length is applied to every historical candidate window. Shorter patterns find more matches but are less distinctive; longer patterns are more specific but rarer.")
searchBars     = input.int(2000, "Search Depth", minval=500, maxval=4000, group=grpMain, tooltip="How many bars of history the indicator scans when looking for matching patterns. Larger values find more potential analogs but increase load time and compute cost.")
horizon        = input.int(5, "Forecast Horizon", minval=1, maxval=200, group=grpMain, tooltip="Number of bars into the future the projection extends. Each historical match contributes its own forward path of this length, and those paths are combined into the forecast midline and clusters.")
patternMatches = input.int(30, "Pattern Matches", minval=5, maxval=200, group=grpMain, tooltip="Target number of historical analog patterns to use in the projection.\n\nThe indicator auto-finds the similarity threshold that produces this many matches, starting at 100% and loosening until the target is reached or the Similarity Floor is hit.\n\nSuggested settings:\n• Conservative / high quality: 15–25 matches. Fewer analogs, stricter similarity. Best on liquid instruments with deep history.\n• Balanced (default): 25–40 matches. Good stability without diluting quality.\n• Aggressive / smoothed: 40–60 matches. More analogs, lower average similarity. Projection will be smoother but potentially less sharp.\n• Above 60: not recommended. Match quality degrades significantly and the projection converges toward historical average rather than pattern-specific behavior.\n\nNote: Regime Filter, Momentum Filter, the Overlap Filter, and their tolerances directly reduce the candidate pool before this target is attempted.")
simFloor       = input.int(50, "Similarity Floor %", minval=10, maxval=95, group=grpMain, tooltip="The lowest similarity % the auto-search will ever use. If the Pattern Matches target cannot be reached above this floor, the indicator collects however many matches exist at the floor and shows a warning. Prevents projections from being built on essentially unrelated historical patterns.")
projectionMode = input.string("Similarity Weighted", "Projection Mode", options=["Equal Weight", "Similarity Weighted"], group=grpMain, tooltip="Controls how historical pattern matches are combined into the forecast. Equal Weight treats every selected match the same. Similarity Weighted gives more influence to matches that more closely resemble the current pattern.")
useKNNProjection = input.bool(false, "Use KNN Projection", group=grpMain, tooltip="When enabled, the projection uses the top K nearest historical neighbors by similarity instead of every match above the auto-selected threshold. This makes the forecast behave as a true K-nearest-neighbor regression model. When disabled, the script uses the original threshold-based analog projection.")
knnNeighbors = input.int(20, "KNN Neighbors", minval=5, maxval=200, group=grpMain, tooltip="Number of nearest historical neighbors used when Use KNN Projection is enabled. This is separate from Pattern Matches so you can compare the original threshold-based analog model against a fixed-K neighbor model.")
useBayesianProb = input.bool(false, "Use Bayesian Probability", group=grpMain, tooltip="When enabled, bull/bear probabilities are adjusted using a Bayesian-style confidence weighting based on analog direction, average similarity, match count, and whether the similarity floor was hit. When disabled, probabilities use the original weighted bull/bear calculation. Note: this only reshapes probability magnitude — it never flips the bull/bear side — so it does not affect the Accuracy Tracker.")
bayesStrength = input.float(1.0, "Bayesian Strength", minval=0.1, maxval=5.0, step=0.1, group=grpMain, tooltip="Controls how strongly Bayesian Probability can pull the raw analog probability away from or back toward 50/50. Lower values are more conservative. Higher values are more aggressive.")

grpAdvanced = "Advanced Model Inputs"
useLogRet           = input.bool(true,  "Use Log Returns",             group=grpAdvanced, tooltip="Uses logarithmic returns instead of simple percent returns. Log returns handle compounding more cleanly and are usually better for comparing price patterns across different price levels.")
useRegimeFilter     = input.bool(false,  "Use Volatility Filter",           group=grpAdvanced, tooltip="Filters historical matches to only include periods with volatility similar to the current market regime. Volatility is compared as the mean ATR% across the full pattern length for both the current and candidate patterns, giving a more accurate picture of the overall volatility environment rather than a single bar snapshot.\n\nImportant: this filter reduces the candidate pool before the similarity scan runs.")
regimeTolerance     = input.float(0.15, "Volatility % Difference",            group=grpAdvanced, minval=0.01, maxval=1.0, step=0.01, tooltip="Maximum allowed percentage difference between the current pattern's average ATR% and a historical candidate's average ATR%. Volatility is measured as the mean ATR% across the full pattern length, not a single bar. Example: a value of 1.5 means the candidate ATR% must be within 1.5% of the current ATR%. Lower values are stricter. Higher values are more permissive.")
useMomentumFilter   = input.bool(false, "Use Momentum Filter",         group=grpAdvanced, tooltip="Filters historical matches to only include periods with RSI momentum similar to the current pattern's RSI. This helps avoid comparing patterns that look similar but occurred under very different momentum conditions.\n\nDefault is OFF to preserve the original behavior.")
momentumLen         = input.int(14,     "Momentum Length",             group=grpAdvanced, minval=2, maxval=100, tooltip="RSI length used by the Momentum Filter. Only active when Use Momentum Filter is ON.")
momentumTolerance   = input.float(15.0, "Momentum # Difference",          group=grpAdvanced, minval=1.0, maxval=50.0, step=1.0, tooltip="Maximum RSI-point difference allowed between the current pattern's RSI and a historical candidate's RSI. Example: if current RSI is 62 and this is set to 15, candidates with RSI between 47 and 77 are accepted. Lower values are stricter. Higher values are more permissive.")
useZScore           = input.bool(true, "Normalize Pattern",           group=grpAdvanced, tooltip="Standardizes each pattern by subtracting its average and dividing by its volatility. This makes the model compare pattern shape instead of absolute move size.")
useCorrelation      = input.bool(false, "Use Correlation Similarity",  group=grpAdvanced, tooltip="Measures similarity by how closely the current pattern and historical patterns move together. When enabled, direction and shape matter more than raw distance.")
useOutcomeWeighting = input.bool(false, "Use Outcome-Based Weighting", group=grpAdvanced, tooltip="Gives more influence to historical matches that were followed by stronger future moves. This can make projections more responsive, but may also emphasize outlier outcomes. Does not affect match count or the similarity threshold scan.")

grpEnhance = "Model Enhancements"
useOverlapFilter  = input.bool(true, "Filter Overlapping Analogs", group=grpEnhance, tooltip="ADDED. Removes near-duplicate matches. Because the search scans history one bar at a time, adjacent candidate windows are almost the same pattern shifted by a single bar. Without this filter, one historical episode can be counted many times, silently inflating the match count and biasing the bull/bear vote and the confidence bands.\n\nWhen ON, once a match is accepted, any other candidate whose start is within the separation distance below is rejected — so every retained analog represents a distinct historical episode.")
overlapBars       = input.int(1, "Min Separation (bars, 0 = Pattern Length)", minval=0, maxval=500, group=grpEnhance, tooltip="Minimum number of bars that must separate two accepted analogs. 0 means use Pattern Length (non-overlapping windows). Increase for even more independence between episodes.")
pathAwareClassify = input.bool(true, "Path-Aware Bull/Bear Classification", group=grpEnhance, tooltip="ADDED. Changes how each analog is labeled bull/bear/flat. The original method looks ONLY at the price at the final bar of the horizon, so an analog that ran up for most of the window but reverted on the last bar gets tagged bearish. When ON, each analog is classified on the AVERAGE cumulative move across the whole horizon (where price actually spent its time), not just the endpoint. This only affects the bull/bear cluster lines and the probability — the average forecast midline is unchanged. Turn OFF to reproduce the original endpoint-only behavior.")

grpLookback  = "Historical Lookback"
lookbackBars = input.int(0, "Lookback Bars", minval=0, maxval=2000, step=1, group=grpLookback, tooltip="Shifts the entire indicator backward in time by this many bars. Set to 0 for live/current analysis. Increase to replay what the indicator would have projected at a past point in time.")
lockCandle   = input.bool(false, "Lock to Candle", group=grpLookback, tooltip="When enabled, anchors the projection to the candle at the UTC time below.")
daysBack     = input.int(0, "Days Back", minval=0, maxval=30, group=grpLookback, tooltip="Number of sessions to look back from the most recent matching candle. 0 = most recent. 1 = one session further back.")
lockHour     = input.int(13, "Hour (UTC)", minval=0, maxval=23, group=grpLookback, tooltip="The hour of the candle you want to anchor to, in 24-hour UTC time.")
lockMinute   = input.int(30, "Minute (UTC)", minval=0, maxval=59, group=grpLookback, tooltip="The minute of the candle you want to anchor to in UTC.")
autoPrevSession = input.bool(true, "Auto Previous Session", group=grpLookback, tooltip="When ON: if today's target candle has not yet printed, the lock automatically falls back to the most recent previous session match.")

grpBias = "Bias Logic"
biasThreshold = input.float(60.0, "Bias Threshold %", minval=50.0, maxval=90.0, step=1.0, group=grpBias, tooltip="Minimum bull or bear probability required before the indicator can label the pattern Bullish or Bearish.")
analogEdge    = input.float(15.0, "Minimum Bull/Bear Edge %", minval=0.0, maxval=50.0, step=1.0, group=grpBias, tooltip="Minimum percentage-point gap required between bull and bear probabilities.")

grpTrack = "Accuracy Tracker"
trackAccuracy = input.bool(false, "Enable Realized Accuracy Tracker", group=grpTrack, tooltip="ADDED. Measures how often the indicator's Bullish/Bearish label has actually been correct, instead of only estimating how good a setup looks.\n\nFor each of the most recent bars in the tracking window, it reconstructs the directional call the engine WOULD have made using only data available at that time, then checks — with no lookahead — whether price moved that way over the following Forecast Horizon. It reports a rolling hit-rate and sample size in the info box (Medium/Large modes).\n\nDESIGN NOTES (read these):\n• COMPUTE-HEAVY. A full per-bar rerun of the engine over all history would exceed TradingView's limits, so tracking is bounded to the recent window below and is OFF by default. Enable it deliberately.\n• The tracker faithfully reproduces the CORE directional logic: log/percent returns, normalization, correlation-or-distance similarity, the volatility and momentum filters, the overlap filter, path-aware classification, similarity weighting, and the same Bias Threshold + Edge gates.\n• It does NOT apply Outcome-Based Weighting or Bayesian Probability. Bayesian never changes the bull/bear side, so it cannot change the hit-rate; Outcome Weighting is omitted to keep the tracker tractable.\n• Selection inside the tracker is nearest-neighbor-above-floor (not the auto-threshold scan), so on very loose threshold settings the tracker's sample can differ slightly from the live projection's. Treat the hit-rate as a calibration read on the core method, not a bit-identical replay.\n• Only closed bars are scored, and the window is anchored to the most recent bars, so the sample builds as the chart loads and grows in real time.")
trackWindow   = input.int(200, "Tracking Window (bars)", minval=20, maxval=1000, group=grpTrack, tooltip="How many of the most recent bars to evaluate. Larger = bigger sample but heavier compute.")
trackDepth    = input.int(500, "Tracker Search Depth", minval=100, maxval=2000, group=grpTrack, tooltip="How far back each reconstructed prediction is allowed to search for analogs. Kept separate from (and usually smaller than) the main Search Depth to bound compute cost.")

grpDraw          = "Display"
showCurrPattern  = input.bool(true,  "Show Current Pattern",       group=grpDraw, tooltip="Draws the current pattern window — the most recent bars being matched — on the chart using the Current Pattern style.")
showMidline      = input.bool(true,  "Show Forecast Midline",      group=grpDraw, tooltip="Draws the average forecast midline: the weighted average projected path across all selected matches.")
showBullCluster  = input.bool(false, "Show Bull Cluster Midline",  group=grpDraw, tooltip="Draws the average projected path built only from analogs that resolved bullish over the forecast horizon.")
showBearCluster  = input.bool(false, "Show Bear Cluster Midline",  group=grpDraw, tooltip="Draws the average projected path built only from analogs that resolved bearish over the forecast horizon.")
projectionAnchor = input.string("Close", "Projection Start Price", options=["Close", "HLC3"], group=grpDraw, tooltip="Price the projection starts from. Close anchors to the closing price of the anchor bar; HLC3 anchors to the average of that bar's high, low, and close.")

grpInfo           = "Info Box"
showInfoBox       = input.bool(true, "Show Info Box", group=grpInfo, tooltip="Shows the on-chart info box summarizing model settings, probabilities, and diagnostics.")
infoBoxMode       = input.string("Medium", "Mode", options=["Small", "Medium", "Large"], group=grpInfo, tooltip="Controls how much detail the info box shows. Small shows the core metrics; Medium adds diagnostics and the realized hit-rate; Large adds the full model configuration.")
infoBoxPosition   = input.string("Bottom Right", "Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpInfo, tooltip="Screen position of the info box.")
infoTextSizeIn    = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpInfo, tooltip="Text size used inside the info box.")
infoBgColor       = input.color(color.new(color.black, 10), "Background", group=grpInfo, tooltip="Background color of the info box body cells.")
infoBorderColor   = input.color(color.new(color.gray, 20), "Border", group=grpInfo, tooltip="Color of the info box border and outer frame.")
infoHeaderColor   = input.color(color.white, "Header Text", group=grpInfo, tooltip="Text color of the info box header and column-title row.")
infoHeaderBgColor = input.color(color.new(color.blue, 20), "Header Background", group=grpInfo, tooltip="Background color of the info box header and column-title row.")

grpCurrent = "Current Pattern"
currColor  = input.color(color.purple, "Color", group=grpCurrent, tooltip="Line color of the current pattern.")
currWidth  = input.int(3, "Width", minval=1, maxval=5, group=grpCurrent, tooltip="Line width of the current pattern.")
currTypeIn = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpCurrent, tooltip="Line style of the current pattern.")

grpForecast    = "Forecast Midline"
midColor       = input.color(color.aqua, "Color", group=grpForecast, tooltip="Line color of the forecast midline.")
midWidth       = input.int(3, "Width", minval=1, maxval=5, group=grpForecast, tooltip="Line width of the forecast midline.")
midTypeIn      = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpForecast, tooltip="Line style of the forecast midline.")
showMidBands   = input.bool(true, "Show Confidence Bands", group=grpForecast, tooltip="Draws upper and lower confidence bands around the forecast midline, based on the weighted standard deviation of the projected paths.")
midBandMult    = input.float(1, "Band Width Multiplier", minval=0.1, maxval=3.0, step=0.1, group=grpForecast, tooltip="Scales how far the forecast midline confidence bands sit from the midline. Higher values widen the bands.")

grpMidUpper    = "Forecast Midline — Upper Band"
midUpperColor  = input.color(color.new(color.lime, 15), "Color", group=grpMidUpper, tooltip="Line color of the forecast midline upper confidence band.")
midUpperWidth  = input.int(1, "Width", minval=1, maxval=5, group=grpMidUpper, tooltip="Line width of the forecast midline upper confidence band.")
midUpperTypeIn = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpMidUpper, tooltip="Line style of the forecast midline upper confidence band.")

grpMidLower    = "Forecast Midline — Lower Band"
midLowerColor  = input.color(color.new(color.red, 15), "Color", group=grpMidLower, tooltip="Line color of the forecast midline lower confidence band.")
midLowerWidth  = input.int(1, "Width", minval=1, maxval=5, group=grpMidLower, tooltip="Line width of the forecast midline lower confidence band.")
midLowerTypeIn = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpMidLower, tooltip="Line style of the forecast midline lower confidence band.")

grpClusterFilter = "Cluster Outcome Filter"
useClusterFilter = input.bool(true, "Enable ATR Flat Zone Filter", group=grpClusterFilter, tooltip="When enabled, analog outcomes that don't move enough to clear the ATR-based flat zone are excluded from the bull and bear cluster calculations and probability counts. Only affects cluster lines and probabilities — the average midline is unaffected.")
clusterATRMult   = input.float(0, "ATR Multiplier (Flat Zone)", minval=0, maxval=5, step=0.1, group=grpClusterFilter, tooltip="An analog's end-of-horizon move must exceed this multiple of ATR to qualify as a genuine bull or bear outcome.")

grpBull        = "Bull Cluster"
bullColor      = input.color(color.new(color.lime, 0), "Color", group=grpBull, tooltip="Line color of the bull cluster midline.")
bullWidth      = input.int(1, "Width", minval=1, maxval=5, group=grpBull, tooltip="Line width of the bull cluster midline.")
bullTypeIn     = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpBull, tooltip="Line style of the bull cluster midline.")
showBullBands  = input.bool(false, "Show Confidence Bands", group=grpBull, tooltip="Draws upper and lower confidence bands around the bull cluster midline, based on the weighted standard deviation of the bullish analog paths.")
bullBandMult   = input.float(0.5, "Band Width Multiplier", minval=0.1, maxval=3.0, step=0.1, group=grpBull, tooltip="Scales how far the bull cluster confidence bands sit from the bull cluster midline. Higher values widen the bands.")

grpBullBands    = "Bull Cluster — Confidence Bands"
bullBandColor   = input.color(color.new(color.lime, 40), "Color", group=grpBullBands, tooltip="Line color of the bull cluster confidence bands.")
bullBandWidth   = input.int(1, "Width", minval=1, maxval=5, group=grpBullBands, tooltip="Line width of the bull cluster confidence bands.")
bullBandTypeIn  = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpBullBands, tooltip="Line style of the bull cluster confidence bands.")

grpBear        = "Bear Cluster"
bearColor      = input.color(color.new(color.red, 0), "Color", group=grpBear, tooltip="Line color of the bear cluster midline.")
bearWidth      = input.int(1, "Width", minval=1, maxval=5, group=grpBear, tooltip="Line width of the bear cluster midline.")
bearTypeIn     = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpBear, tooltip="Line style of the bear cluster midline.")
showBearBands  = input.bool(false, "Show Confidence Bands", group=grpBear, tooltip="Draws upper and lower confidence bands around the bear cluster midline, based on the weighted standard deviation of the bearish analog paths.")
bearBandMult   = input.float(0.5, "Band Width Multiplier", minval=0.1, maxval=3.0, step=0.1, group=grpBear, tooltip="Scales how far the bear cluster confidence bands sit from the bear cluster midline. Higher values widen the bands.")

grpBearBands    = "Bear Cluster — Confidence Bands"
bearBandColor   = input.color(color.new(color.red, 40), "Color", group=grpBearBands, tooltip="Line color of the bear cluster confidence bands.")
bearBandWidth   = input.int(1, "Width", minval=1, maxval=5, group=grpBearBands, tooltip="Line width of the bear cluster confidence bands.")
bearBandTypeIn  = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpBearBands, tooltip="Line style of the bear cluster confidence bands.")

grpMatched             = "Matched Patterns"
showMatchedPatterns    = input.bool(false, "Show Matched Patterns", group=grpMatched, tooltip="Draws the historical pattern windows that qualified as matches. The script draws the highest-similarity matches first and automatically caps the count so the indicator stays under TradingView's 500-line limit.")
matchedPatternsToShow  = input.int(10, "Visible Matches", minval=1, maxval=20, group=grpMatched, tooltip="How many of the highest-similarity matched patterns to draw. The number actually drawn may be lower if doing so would exceed TradingView's 500-line limit.")
matchedPatternColor    = input.color(color.new(color.yellow, 0), "Color", group=grpMatched, tooltip="Line color of the matched historical patterns.")
matchedPatternWidth    = input.int(4, "Width", minval=1, maxval=5, group=grpMatched, tooltip="Line width of the matched historical patterns.")
matchedPatternTypeIn   = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpMatched, tooltip="Line style of the matched historical patterns.")

// ADDED — effective overlap separation used by the main engine and the tracker
effGap = useOverlapFilter ? (overlapBars <= 0 ? patternLen : overlapBars) : 0

f_line_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_table_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_text_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

midStyle       = f_line_style(midTypeIn)
midUpperStyle  = f_line_style(midUpperTypeIn)
midLowerStyle  = f_line_style(midLowerTypeIn)
bullStyle      = f_line_style(bullTypeIn)
bullBandStyle  = f_line_style(bullBandTypeIn)
bearStyle      = f_line_style(bearTypeIn)
bearBandStyle  = f_line_style(bearBandTypeIn)
currStyle      = f_line_style(currTypeIn)
matchStyle     = f_line_style(matchedPatternTypeIn)

f_ret(int offset, int anchor) =>
    useLogRet ? math.log(close[offset + anchor] / close[offset + anchor + 1]) : close[offset + anchor] / close[offset + anchor + 1] - 1.0

f_price(int offset, int anchor) =>
    close[offset + anchor]

f_base_price(int anchor) =>
    projectionAnchor == "Close" ? close[anchor] : hlc3[anchor]

f_clear_lines(line[] arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

f_array_mean(array<float> arr) =>
    int n = array.size(arr)
    if n == 0
        na
    else
        float s = 0.0
        for i = 0 to n - 1
            s += array.get(arr, i)
        s / n

f_array_std(array<float> arr, float meanVal) =>
    int n = array.size(arr)
    if n <= 1 or na(meanVal)
        0.0
    else
        float s = 0.0
        for i = 0 to n - 1
            float d = array.get(arr, i) - meanVal
            s += d * d
        math.sqrt(s / n)

f_zscore_in_place(array<float> arr) =>
    float mu = f_array_mean(arr)
    float sd = f_array_std(arr, mu)
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            float v = array.get(arr, i)
            array.set(arr, i, sd == 0.0 ? 0.0 : (v - mu) / sd)

weightPower = 1.5

f_pattern_distance(array<float> a, array<float> b) =>
    int n = array.size(a)
    float dist = 0.0
    for i = 0 to n - 1
        dist += math.abs(array.get(a, i) - array.get(b, i))
    dist

f_pattern_corr(array<float> a, array<float> b) =>
    int n = array.size(a)
    float meanA = f_array_mean(a)
    float meanB = f_array_mean(b)
    float num  = 0.0
    float denA = 0.0
    float denB = 0.0
    for i = 0 to n - 1
        float da = array.get(a, i) - meanA
        float db = array.get(b, i) - meanB
        num  += da * db
        denA += da * da
        denB += db * db
    float denom = math.sqrt(denA * denB)
    denom == 0.0 ? 0.0 : num / denom

f_similarity_pct(float dist, float minDist, float maxDist) =>
    float denom = maxDist - minDist
    denom <= 0.0 ? 100.0 : math.max(0.0, math.min(100.0, 100.0 * (1.0 - (dist - minDist) / denom)))

f_weight_from_similarity(float sim) =>
    float w = 1.0
    if projectionMode == "Similarity Weighted"
        float denom      = math.max(1.0, 100.0 - simFloor)
        float normalized = math.max(0.0, math.min(1.0, (sim - simFloor) / denom))
        w := math.pow(normalized, weightPower)
        if w <= 0.0
            w := 0.0001
    w

f_forward_factor(int off, int steps, int anchor) =>
    float factor = 1.0
    for s = 1 to steps
        float r = f_ret(off - s, anchor)
        factor *= useLogRet ? math.exp(r) : (1.0 + r)
    factor

// ADDED — average cumulative factor across the whole horizon (path-aware measure)
f_path_measure(int off, int steps, int anchor) =>
    float fac  = 1.0
    float sumF = 0.0
    for s = 1 to steps
        float r = f_ret(off - s, anchor)
        fac *= useLogRet ? math.exp(r) : (1.0 + r)
        sumF += fac
    steps > 0 ? sumF / steps : 1.0

// ADDED — overlap guard: true if 'off' sits within 'gap' bars of any already-accepted offset
f_too_close(int off, array<int> accepted, int gap) =>
    bool tooClose = false
    int n = array.size(accepted)
    if n > 0
        for i = 0 to n - 1
            if math.abs(off - array.get(accepted, i)) < gap
                tooClose := true
                break
    tooClose

f_weighted_mean(array<float> vals, array<float> weights) =>
    int n = array.size(vals)
    if n == 0 or array.size(weights) != n
        na
    else
        float weightedSum = 0.0
        float weightSum   = 0.0
        for i = 0 to n - 1
            float v = array.get(vals, i)
            float w = array.get(weights, i)
            weightedSum += v * w
            weightSum   += w
        weightSum == 0.0 ? na : weightedSum / weightSum

f_weighted_std(array<float> vals, array<float> weights, float meanVal) =>
    int n = array.size(vals)
    if n <= 1 or na(meanVal) or array.size(weights) != n
        0.0
    else
        float weightedSq = 0.0
        float weightSum  = 0.0
        for i = 0 to n - 1
            float v = array.get(vals, i)
            float w = array.get(weights, i)
            float d = v - meanVal
            weightedSq += w * d * d
            weightSum  += w
        weightSum == 0.0 ? 0.0 : math.sqrt(weightedSq / weightSum)

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_logit(float p) =>
    float pc = f_clamp(p, 0.01, 0.99)
    math.log(pc / (1.0 - pc))

f_logistic(float x) =>
    1.0 / (1.0 + math.exp(-x))

anchor = nonRepaint ? 1 : 0

var int[]  matchedBars       = array.new<int>()
var int[]  matchedTimestamps = array.new<int>()
var int    targetBarIndex    = na

if lockCandle
    if hour(time, "UTC") == lockHour and minute(time, "UTC") == lockMinute
        array.push(matchedBars,       bar_index)
        array.push(matchedTimestamps, time)
else
    array.clear(matchedBars)
    array.clear(matchedTimestamps)
    targetBarIndex := na

int    anchorOffset = 0
string lockStatus   = ""

if lockCandle
    int totalMatches = array.size(matchedBars)
    int pickIndex    = totalMatches - 1 - daysBack
    if pickIndex >= 0
        int candidateBar  = array.get(matchedBars,       pickIndex)
        int candidateTime = array.get(matchedTimestamps, pickIndex)

        bool isToday = year(candidateTime, "UTC") == year(timenow, "UTC") and month(candidateTime, "UTC") == month(timenow, "UTC") and dayofmonth(candidateTime, "UTC") == dayofmonth(timenow, "UTC")

        if not autoPrevSession and not isToday and daysBack == 0
            targetBarIndex := na
            anchorOffset   := lookbackBars
            lockStatus     := "No Anchor Lock"
        else
            targetBarIndex := candidateBar
            anchorOffset   := bar_index - targetBarIndex
            lockStatus     := "Locked"
    else
        targetBarIndex := na
        anchorOffset   := lookbackBars
        lockStatus     := "No Anchor Lock"
else
    anchorOffset := lookbackBars
    lockStatus   := ""

var line[] midLines       = array.new<line>()
var line[] midUpperLines  = array.new<line>()
var line[] midLowerLines  = array.new<line>()
var line[] bullLines      = array.new<line>()
var line[] bullUpperLines = array.new<line>()
var line[] bullLowerLines = array.new<line>()
var line[] bearLines      = array.new<line>()
var line[] bearUpperLines = array.new<line>()
var line[] bearLowerLines = array.new<line>()
var line[] currLines      = array.new<line>()
var line[] matchLines     = array.new<line>()

var bool bullProbabilityAlert        = false
var bool bearProbabilityAlert        = false
var bool directionalProbabilityAlert = false

anchorTotal = anchor + anchorOffset

enoughBars = bar_index > (patternLen + horizon + patternMatches + anchorTotal + 20)

atrPct      = ta.atr(patternLen) / close
momentumRSI = ta.rsi(close, momentumLen)
atr14       = ta.atr(14)

// =====================================================================
// ADDED — Realized Accuracy Tracker
// Reconstructs the labeled directional call the engine would have made
// 'horizon' bars ago (using only data available then) and scores it
// against the realized move to the current bar. No lookahead.
// =====================================================================
f_track_direction(int aOff) =>
    int sign = 0
    int maxOff = math.min(trackDepth, bar_index - horizon - patternLen - aOff - 2)
    if maxOff >= horizon
        refT = array.new<float>()
        for j = 0 to patternLen - 1
            array.push(refT, f_ret(j, aOff))
        if useZScore
            f_zscore_in_place(refT)

        float refATR  = 0.0
        int   refATRc = 0
        for j = 0 to patternLen - 1
            float v = atrPct[j + aOff]
            if not na(v)
                refATR  += v
                refATRc += 1
        refATR := refATRc > 0 ? refATR / refATRc : na
        float refMom = momentumRSI[aOff]

        mArr = array.new<float>()
        oArr = array.new<int>()
        float minM = 1e10
        float maxM = -1.0

        for off = horizon to maxOff
            candT = array.new<float>()
            for j = 0 to patternLen - 1
                array.push(candT, f_ret(off + j, aOff))
            if useZScore
                f_zscore_in_place(candT)

            float metric = useCorrelation ? (1.0 - math.max(0.0, f_pattern_corr(refT, candT))) : f_pattern_distance(refT, candT)

            bool ok = true
            if useRegimeFilter
                float cA  = 0.0
                int   cAc = 0
                for j = 0 to patternLen - 1
                    float v = atrPct[off + j + aOff]
                    if not na(v)
                        cA  += v
                        cAc += 1
                cA := cAc > 0 ? cA / cAc : na
                ok := not na(refATR) and not na(cA) and refATR != 0.0 and math.abs(cA - refATR) / refATR <= regimeTolerance
            if ok and useMomentumFilter
                float cM = momentumRSI[off + aOff]
                ok := not na(refMom) and not na(cM) and math.abs(cM - refMom) <= momentumTolerance

            if ok
                array.push(mArr, metric)
                array.push(oArr, off)
                minM := math.min(minM, metric)
                maxM := math.max(maxM, metric)

        int nC = array.size(mArr)
        if nC > 0
            simT = array.new<float>()
            for i = 0 to nC - 1
                float mm = array.get(mArr, i)
                float ss = useCorrelation ? (1.0 - mm) * 100.0 : f_similarity_pct(mm, minM, maxM)
                array.push(simT, ss)

            int tgt = useKNNProjection ? knnNeighbors : patternMatches
            selOff = array.new<int>()
            selSim = array.new<float>()
            accOff = array.new<int>()
            usedC  = array.new<bool>(nC, false)

            for iter = 0 to nC - 1
                if array.size(selOff) >= tgt
                    break
                int   bIdx = na
                float bSim = -1.0
                for i = 0 to nC - 1
                    if not array.get(usedC, i)
                        float s = array.get(simT, i)
                        if s > bSim
                            bSim := s
                            bIdx := i
                if na(bIdx)
                    break
                if bSim < float(simFloor)
                    break
                array.set(usedC, bIdx, true)
                int offv = array.get(oArr, bIdx)
                if effGap > 0 and f_too_close(offv, accOff, effGap)
                    continue
                array.push(accOff, offv)
                array.push(selOff, offv)
                array.push(selSim, bSim)

            int sc = array.size(selOff)
            if sc > 0
                float bullW = 0.0
                float bearW = 0.0
                for k = 0 to sc - 1
                    int   offv = array.get(selOff, k)
                    float w    = f_weight_from_similarity(array.get(selSim, k))
                    float endF = f_forward_factor(offv, horizon, aOff)
                    float clsF = pathAwareClassify ? f_path_measure(offv, horizon, aOff) : endF
                    float mv   = math.abs(clsF - 1.0)
                    float aAtr = atrPct[offv + aOff]
                    float flatT = useClusterFilter and not na(aAtr) ? aAtr * clusterATRMult : 0.0
                    if mv >= flatT
                        if clsF >= 1.0
                            bullW += w
                        else
                            bearW += w
                float tw = bullW + bearW
                if tw > 0.0
                    float pB = 100.0 * bullW / tw
                    float pR = 100.0 * bearW / tw
                    if pB >= biasThreshold and (pB - pR) >= analogEdge
                        sign := 1
                    else if pR >= biasThreshold and (pR - pB) >= analogEdge
                        sign := -1
    sign

var int trackCorrect = 0
var int trackTotal   = 0

if trackAccuracy and barstate.isconfirmed and (last_bar_index - bar_index) <= trackWindow and bar_index > (trackDepth + horizon + patternLen + 5)
    int predSign = f_track_direction(horizon)
    if predSign != 0
        float pThen = f_base_price(horizon)
        float pNow  = f_base_price(0)
        int   realSign = pNow > pThen ? 1 : pNow < pThen ? -1 : 0
        if realSign != 0
            trackTotal += 1
            if predSign == realSign
                trackCorrect += 1

bullProbabilityAlert        := false
bearProbabilityAlert        := false
directionalProbabilityAlert := false

if barstate.islast and enoughBars
    f_clear_lines(midLines)
    f_clear_lines(midUpperLines)
    f_clear_lines(midLowerLines)
    f_clear_lines(bullLines)
    f_clear_lines(bullUpperLines)
    f_clear_lines(bullLowerLines)
    f_clear_lines(bearLines)
    f_clear_lines(bearUpperLines)
    f_clear_lines(bearLowerLines)
    f_clear_lines(currLines)
    f_clear_lines(matchLines)

    var string _lastInfoPos  = ""
    var string _lastInfoMode = ""
    var table  infoTbl       = na
    if infoBoxPosition != _lastInfoPos or infoBoxMode != _lastInfoMode
        if not na(infoTbl)
            table.delete(infoTbl)
        int infoRows = infoBoxMode == "Small" ? 8 : infoBoxMode == "Medium" ? 15 : 24
        infoTbl       := table.new(f_table_pos(infoBoxPosition), 2, infoRows, border_width=1)
        _lastInfoPos  := infoBoxPosition
        _lastInfoMode := infoBoxMode

    ref = array.new<float>()
    for j = 0 to patternLen - 1
        array.push(ref, f_ret(j, anchorTotal))
    if useZScore
        f_zscore_in_place(ref)

    float refATRPct   = 0.0
    int   refATRCount = 0
    for j = 0 to patternLen - 1
        float v = atrPct[j + anchorTotal]
        if not na(v)
            refATRPct  += v
            refATRCount += 1
    refATRPct := refATRCount > 0 ? refATRPct / refATRCount : na

    float refMomentum = momentumRSI[anchorTotal]
    maxOffset = math.min(searchBars, bar_index - horizon - patternLen - anchorTotal - 2)

    allMetric     = array.new<float>()
    allOff        = array.new<int>()
    allRegimeOK   = array.new<bool>()
    allMomentumOK = array.new<bool>()

    float minMetric            = 1e10
    float maxMetric            = -1.0
    int   regimeRemovedCount   = 0
    int   momentumRemovedCount = 0

    for off = horizon to maxOffset
        cand = array.new<float>()
        for j = 0 to patternLen - 1
            array.push(cand, f_ret(off + j, anchorTotal))
        if useZScore
            f_zscore_in_place(cand)

        float metric = 0.0
        if useCorrelation
            float corr = f_pattern_corr(ref, cand)
            metric := 1.0 - math.max(0.0, corr)
        else
            metric := f_pattern_distance(ref, cand)

        float candATRPct   = 0.0
        int   candATRCount = 0
        for j = 0 to patternLen - 1
            float v = atrPct[off + j + anchorTotal]
            if not na(v)
                candATRPct   += v
                candATRCount += 1
        candATRPct := candATRCount > 0 ? candATRPct / candATRCount : na
        bool regimeOK = true
        if useRegimeFilter
            regimeOK := not na(refATRPct) and not na(candATRPct) and refATRPct != 0.0 and math.abs(candATRPct - refATRPct) / refATRPct <= regimeTolerance
        if not regimeOK
            regimeRemovedCount += 1

        float candMomentum = momentumRSI[off + anchorTotal]
        bool momentumOK = true
        if useMomentumFilter
            momentumOK := not na(refMomentum) and not na(candMomentum) and math.abs(candMomentum - refMomentum) <= momentumTolerance
        if not momentumOK
            momentumRemovedCount += 1

        array.push(allMetric,     metric)
        array.push(allOff,        off)
        array.push(allRegimeOK,   regimeOK)
        array.push(allMomentumOK, momentumOK)

        minMetric := math.min(minMetric, metric)
        maxMetric := math.max(maxMetric, metric)

    int totalCandidates = array.size(allMetric)

    candSimArr = array.new<float>()
    candOffArr = array.new<int>()

    if totalCandidates > 0
        for i = 0 to totalCandidates - 1
            if array.get(allRegimeOK, i) and array.get(allMomentumOK, i)
                float metric = array.get(allMetric, i)
                float sim    = useCorrelation ? (1.0 - metric) * 100.0 : f_similarity_pct(metric, minMetric, maxMetric)
                array.push(candSimArr, sim)
                array.push(candOffArr, array.get(allOff, i))

    int filterPassCount = array.size(candSimArr)

    int  effectiveSimInt = simFloor
    bool floorHit        = false

    selectedOff = array.new<int>()
    selectedSim = array.new<float>()

    if useKNNProjection
        int kTarget = math.min(knnNeighbors, filterPassCount)
        if kTarget > 0
            knnUsed       = array.new<bool>(filterPassCount, false)
            acceptedOffsK = array.new<int>()
            // ADDED — greedy nearest-first selection with overlap spacing
            for iter = 0 to filterPassCount - 1
                if array.size(selectedOff) >= knnNeighbors
                    break
                int   bestIdx = na
                float bestSim = -1.0
                for i = 0 to filterPassCount - 1
                    if not array.get(knnUsed, i)
                        float sim = array.get(candSimArr, i)
                        if sim > bestSim
                            bestSim := sim
                            bestIdx := i
                if na(bestIdx)
                    break
                array.set(knnUsed, bestIdx, true)
                int offK = array.get(candOffArr, bestIdx)
                if effGap > 0 and f_too_close(offK, acceptedOffsK, effGap)
                    continue
                array.push(acceptedOffsK, offK)
                array.push(selectedOff, offK)
                array.push(selectedSim, bestSim)

        int selectedTmp = array.size(selectedSim)
        if selectedTmp > 0
            effectiveSimInt := int(math.round(array.min(selectedSim)))
            floorHit := selectedTmp < knnNeighbors or effectiveSimInt <= simFloor
        else
            floorHit := true
    else
        for testSim = 100 to simFloor
            int cnt = 0
            if filterPassCount > 0
                for i = 0 to filterPassCount - 1
                    if array.get(candSimArr, i) >= testSim
                        cnt += 1
            if cnt >= patternMatches
                effectiveSimInt := testSim
                break
            if testSim == simFloor
                floorHit := true

        float effectiveSimScan = float(effectiveSimInt)
        // ADDED — collect above-threshold candidates, then greedily de-overlap by similarity
        tmpOff2 = array.new<int>()
        tmpSim2 = array.new<float>()
        if filterPassCount > 0
            for i = 0 to filterPassCount - 1
                float sim = array.get(candSimArr, i)
                if sim >= effectiveSimScan
                    array.push(tmpOff2, array.get(candOffArr, i))
                    array.push(tmpSim2, sim)
        int tmpN = array.size(tmpSim2)
        if tmpN > 0
            usedT         = array.new<bool>(tmpN, false)
            acceptedOffsT = array.new<int>()
            for iter = 0 to tmpN - 1
                int   bestIdx = na
                float bestSim = -1.0
                for i = 0 to tmpN - 1
                    if not array.get(usedT, i)
                        float s = array.get(tmpSim2, i)
                        if s > bestSim
                            bestSim := s
                            bestIdx := i
                if na(bestIdx)
                    break
                array.set(usedT, bestIdx, true)
                int offA = array.get(tmpOff2, bestIdx)
                if effGap > 0 and f_too_close(offA, acceptedOffsT, effGap)
                    continue
                array.push(acceptedOffsT, offA)
                array.push(selectedOff, offA)
                array.push(selectedSim, array.get(tmpSim2, bestIdx))

    float effectiveSim = float(effectiveSimInt)

    int selectedCount   = array.size(selectedOff)
    int simRemovedCount = filterPassCount - selectedCount

    selectedWgt      = array.new<float>()
    outcomeStrengths = array.new<float>()
    float maxOutcomeStrength = 0.0

    if selectedCount > 0
        for k = 0 to selectedCount - 1
            int   off           = array.get(selectedOff, k)
            float outcomeFactor = f_forward_factor(off, horizon, anchorTotal)
            float strength      = math.abs(outcomeFactor - 1.0)
            array.push(outcomeStrengths, strength)
            maxOutcomeStrength := math.max(maxOutcomeStrength, strength)

        for k = 0 to selectedCount - 1
            float sim    = array.get(selectedSim, k)
            float baseW  = f_weight_from_similarity(sim)
            float finalW = baseW
            if useOutcomeWeighting
                float strength           = array.get(outcomeStrengths, k)
                float normalizedStrength = maxOutcomeStrength == 0.0 ? 0.0 : strength / maxOutcomeStrength
                finalW := baseW * (1.0 + normalizedStrength)
            array.push(selectedWgt, finalW)

    clusterDir = array.new<int>(selectedCount, 0)
    int   bullCount  = 0
    int   bearCount  = 0
    int   flatCount  = 0
    float bullWeight = 0.0
    float bearWeight = 0.0

    if selectedCount > 0
        for k = 0 to selectedCount - 1
            int   off         = array.get(selectedOff, k)
            float w           = array.get(selectedWgt, k)
            // ADDED — path-aware classification driver (endpoint retained as fallback)
            float endFactor   = f_forward_factor(off, horizon, anchorTotal)
            float clsFactor   = pathAwareClassify ? f_path_measure(off, horizon, anchorTotal) : endFactor
            float movePct     = math.abs(clsFactor - 1.0)

            float analogATRPct  = atrPct[off + anchorTotal]
            float flatThreshold = useClusterFilter and not na(analogATRPct) ? analogATRPct * clusterATRMult : 0.0

            int dir = 0
            if movePct >= flatThreshold
                dir := clsFactor >= 1.0 ? 1 : -1

            array.set(clusterDir, k, dir)
            if dir == 1
                bullCount  += 1
                bullWeight += w
            else if dir == -1
                bearCount  += 1
                bearWeight += w
            else
                flatCount  += 1

    float totalProbWeight = bullWeight + bearWeight
    float rawProbBull = totalProbWeight > 0.0 ? 100.0 * bullWeight / totalProbWeight : 0.0
    float rawProbBear = totalProbWeight > 0.0 ? 100.0 * bearWeight / totalProbWeight : 0.0

    float avgSimScore = selectedCount > 0 ? f_array_mean(selectedSim) : na
    int   targetMatchCount = useKNNProjection ? knnNeighbors : patternMatches
    float countScore  = selectedCount == 0 ? 0.0 : math.min(100.0, 100.0 * selectedCount / math.max(1, targetMatchCount))
    float countFactor = countScore / 100.0
    float fitFactor   = na(avgSimScore) ? 0.0 : f_clamp((avgSimScore - simFloor) / math.max(1.0, 100.0 - simFloor), 0.0, 1.0)
    float floorFactor = floorHit ? 0.50 : 1.00
    float bayesEvidenceStrength = selectedCount == 0 ? 0.0 : f_clamp(bayesStrength * (0.25 + 0.45 * fitFactor + 0.20 * countFactor + 0.10 * floorFactor), 0.10, 3.00)
    float bayesInputProb = rawProbBull / 100.0
    float bayesPosteriorBull = selectedCount == 0 ? 0.0 : 100.0 * f_logistic(f_logit(bayesInputProb) * bayesEvidenceStrength)
    float probBull = useBayesianProb and selectedCount > 0 ? bayesPosteriorBull : rawProbBull
    float probBear = useBayesianProb and selectedCount > 0 ? 100.0 - probBull : rawProbBear

    base = f_base_price(anchorTotal)

    avg     = array.new<float>()
    allUp   = array.new<float>()
    allDn   = array.new<float>()
    allSd   = array.new<float>()
    bullAvg = array.new<float>()
    bearAvg = array.new<float>()
    bullUp  = array.new<float>()
    bullDn  = array.new<float>()
    bearUp  = array.new<float>()
    bearDn  = array.new<float>()

    for step = 1 to horizon
        factorsAll  = array.new<float>()
        weightsAll  = array.new<float>()
        factorsBull = array.new<float>()
        weightsBull = array.new<float>()
        factorsBear = array.new<float>()
        weightsBear = array.new<float>()

        if selectedCount > 0
            for k = 0 to selectedCount - 1
                int   off = array.get(selectedOff, k)
                int   dir = array.get(clusterDir, k)
                float w   = array.get(selectedWgt, k)
                float f   = f_forward_factor(off, step, anchorTotal)
                array.push(factorsAll, f)
                array.push(weightsAll, w)
                if dir == 1
                    array.push(factorsBull, f)
                    array.push(weightsBull, w)
                else if dir == -1
                    array.push(factorsBear, f)
                    array.push(weightsBear, w)

        float mAll   = f_weighted_mean(factorsAll,  weightsAll)
        float sdAll  = f_weighted_std(factorsAll,   weightsAll,  mAll)
        float mBull  = f_weighted_mean(factorsBull, weightsBull)
        float sdBull = f_weighted_std(factorsBull,  weightsBull, mBull)
        float mBear  = f_weighted_mean(factorsBear, weightsBear)
        float sdBear = f_weighted_std(factorsBear,  weightsBear, mBear)

        array.push(avg,     na(mAll)  ? na : base * mAll)
        array.push(allUp,   na(mAll)  ? na : base * (mAll  + sdAll  * midBandMult))
        array.push(allDn,   na(mAll)  ? na : base * (mAll  - sdAll  * midBandMult))
        array.push(allSd,   sdAll)
        array.push(bullAvg, na(mBull) ? na : base * mBull)
        array.push(bearAvg, na(mBear) ? na : base * mBear)
        array.push(bullUp,  na(mBull) ? na : base * (mBull + sdBull * bullBandMult))
        array.push(bullDn,  na(mBull) ? na : base * (mBull - sdBull * bullBandMult))
        array.push(bearUp,  na(mBear) ? na : base * (mBear + sdBear * bearBandMult))
        array.push(bearDn,  na(mBear) ? na : base * (mBear - sdBear * bearBandMult))

    int linesPerStep = 0
    linesPerStep += showMidline ? 1 : 0
    linesPerStep += showBullCluster ? 1 : 0
    linesPerStep += showBearCluster ? 1 : 0
    linesPerStep += showMidBands and showMidline ? 2 : 0
    linesPerStep += showBullBands and showBullCluster ? 2 : 0
    linesPerStep += showBearBands and showBearCluster ? 2 : 0

    int reservedLines    = math.max(patternLen - 1, 0) + 5
    int maxForecastLines = math.max(0, 500 - reservedLines)
    int drawSteps        = linesPerStep > 0 ? math.min(horizon, int(math.floor(maxForecastLines / linesPerStep))) : 0

    if selectedCount > 0 and drawSteps > 0
        for i = 0 to drawSteps - 1
            int x1 = bar_index - anchorTotal + i
            int x2 = x1 + 1

            float prevMid    = i == 0 ? base : array.get(avg, i - 1)
            float prevAllUp  = i == 0 ? base : array.get(allUp, i - 1)
            float prevAllDn  = i == 0 ? base : array.get(allDn, i - 1)
            float prevBull   = i == 0 ? base : array.get(bullAvg, i - 1)
            float prevBear   = i == 0 ? base : array.get(bearAvg, i - 1)
            float prevBullUp = i == 0 ? base : array.get(bullUp, i - 1)
            float prevBullDn = i == 0 ? base : array.get(bullDn, i - 1)
            float prevBearUp = i == 0 ? base : array.get(bearUp, i - 1)
            float prevBearDn = i == 0 ? base : array.get(bearDn, i - 1)

            float thisMid    = array.get(avg, i)
            float thisAllUp  = array.get(allUp, i)
            float thisAllDn  = array.get(allDn, i)
            float thisBull   = array.get(bullAvg, i)
            float thisBear   = array.get(bearAvg, i)
            float thisBullUp = array.get(bullUp, i)
            float thisBullDn = array.get(bullDn, i)
            float thisBearUp = array.get(bearUp, i)
            float thisBearDn = array.get(bearDn, i)

            if showMidline and not na(prevMid) and not na(thisMid)
                array.push(midLines, line.new(x1, prevMid, x2, thisMid, color=midColor, width=midWidth, style=midStyle))
            if showMidBands and showMidline and not na(prevAllUp) and not na(thisAllUp)
                array.push(midUpperLines, line.new(x1, prevAllUp, x2, thisAllUp, color=midUpperColor, width=midUpperWidth, style=midUpperStyle))
            if showMidBands and showMidline and not na(prevAllDn) and not na(thisAllDn)
                array.push(midLowerLines, line.new(x1, prevAllDn, x2, thisAllDn, color=midLowerColor, width=midLowerWidth, style=midLowerStyle))
            if showBullCluster and not na(prevBull) and not na(thisBull)
                array.push(bullLines, line.new(x1, prevBull, x2, thisBull, color=bullColor, width=bullWidth, style=bullStyle))
            if showBullBands and showBullCluster and not na(prevBullUp) and not na(thisBullUp)
                array.push(bullUpperLines, line.new(x1, prevBullUp, x2, thisBullUp, color=bullBandColor, width=bullBandWidth, style=bullBandStyle))
            if showBullBands and showBullCluster and not na(prevBullDn) and not na(thisBullDn)
                array.push(bullLowerLines, line.new(x1, prevBullDn, x2, thisBullDn, color=bullBandColor, width=bullBandWidth, style=bullBandStyle))
            if showBearCluster and not na(prevBear) and not na(thisBear)
                array.push(bearLines, line.new(x1, prevBear, x2, thisBear, color=bearColor, width=bearWidth, style=bearStyle))
            if showBearBands and showBearCluster and not na(prevBearUp) and not na(thisBearUp)
                array.push(bearUpperLines, line.new(x1, prevBearUp, x2, thisBearUp, color=bearBandColor, width=bearBandWidth, style=bearBandStyle))
            if showBearBands and showBearCluster and not na(prevBearDn) and not na(thisBearDn)
                array.push(bearLowerLines, line.new(x1, prevBearDn, x2, thisBearDn, color=bearBandColor, width=bearBandWidth, style=bearBandStyle))

    if showCurrPattern
        for j = 0 to patternLen - 2
            int   x1 = (bar_index - anchorTotal) - patternLen + 1 + j
            int   x2 = x1 + 1
            float y1 = f_price(patternLen - 1 - j, anchorTotal)
            float y2 = f_price(patternLen - 2 - j, anchorTotal)
            array.push(currLines, line.new(x1, y1, x2, y2, color=currColor, width=currWidth, style=currStyle))

    if showMatchedPatterns and selectedCount > 0 and patternLen > 1
        int usedLineCount =
             array.size(midLines) +
             array.size(midUpperLines) +
             array.size(midLowerLines) +
             array.size(bullLines) +
             array.size(bullUpperLines) +
             array.size(bullLowerLines) +
             array.size(bearLines) +
             array.size(bearUpperLines) +
             array.size(bearLowerLines) +
             array.size(currLines)

        int availableMatchLines = math.max(0, 500 - usedLineCount)
        int maxDrawableMatches  = math.min(matchedPatternsToShow, int(math.floor(availableMatchLines / math.max(1, patternLen - 1))))
        maxDrawableMatches      := math.min(maxDrawableMatches, selectedCount)

        if maxDrawableMatches > 0
            selectedUsed = array.new<bool>(selectedCount, false)

            for rank = 0 to maxDrawableMatches - 1
                int   bestIdx = na
                float bestSim = -1.0

                for k = 0 to selectedCount - 1
                    if not array.get(selectedUsed, k)
                        float sim = array.get(selectedSim, k)
                        if sim > bestSim
                            bestSim := sim
                            bestIdx := k

                if not na(bestIdx)
                    array.set(selectedUsed, bestIdx, true)
                    int off = array.get(selectedOff, bestIdx)

                    for j = 0 to patternLen - 2
                        int   x1 = (bar_index - anchorTotal - off) - patternLen + 1 + j
                        int   x2 = x1 + 1
                        float y1 = f_price(off + patternLen - 1 - j, anchorTotal)
                        float y2 = f_price(off + patternLen - 2 - j, anchorTotal)

                        if not na(y1) and not na(y2)
                            array.push(matchLines, line.new(x1, y1, x2, y2, color=matchedPatternColor, width=matchedPatternWidth, style=matchStyle))

    float bullEdge = probBull - probBear
    float bearEdge = probBear - probBull

    string biasText  = "None"
    color  biasColor = color.yellow

    if selectedCount == 0
        biasText  := "No Matches"
        biasColor := color.gray
    else if probBull >= biasThreshold and bullEdge >= analogEdge
        biasText  := "Bullish"
        biasColor := color.lime
    else if probBear >= biasThreshold and bearEdge >= analogEdge
        biasText  := "Bearish"
        biasColor := color.red

    float expectedMovePct   = array.size(avg) > 0 and not na(array.get(avg, horizon - 1)) and base != 0.0 ? (array.get(avg, horizon - 1) / base - 1.0) * 100.0 : na
    string expectedMoveStr  = na(expectedMovePct) ? "n/a" : (expectedMovePct >= 0.0 ? "+" : "") + str.tostring(expectedMovePct, "#.00") + "%"
    color  expectedMoveColor = na(expectedMovePct) ? color.gray : expectedMovePct > 0.0 ? color.lime : expectedMovePct < 0.0 ? color.red : color.yellow

    bullProbabilityAlert        := selectedCount > 0 and probBull >= biasThreshold and bullEdge >= analogEdge
    bearProbabilityAlert        := selectedCount > 0 and probBear >= biasThreshold and bearEdge >= analogEdge
    directionalProbabilityAlert := bullProbabilityAlert or bearProbabilityAlert

    color bullPctColor  = selectedCount == 0 ? color.gray : probBull >= biasThreshold ? color.lime : color.yellow
    color bearPctColor  = selectedCount == 0 ? color.gray : probBear >= biasThreshold ? color.red  : color.yellow
    color simFloorColor = effectiveSim >= 75.0 ? color.lime : effectiveSim >= 60.0 ? color.yellow : color.red
    color avgSimColor   = na(avgSimScore) ? color.gray : avgSimScore >= 85.0 ? color.lime : avgSimScore >= 70.0 ? color.yellow : avgSimScore >= 55.0 ? color.orange : color.red

    float floorScore  = floorHit ? 50.0 : 100.0

    float projFitPct    = na(avgSimScore) ? 0.0 : avgSimScore
    float projEdge      = totalProbWeight > 0.0 ? math.abs(probBull - probBear) : 0.0
    float projEdgeScore = math.min(100.0, projEdge / math.max(1.0, analogEdge) * 100.0)
    float projReliability = selectedCount == 0 ? 0.0 :
         projFitPct    * 0.35 +
         projEdgeScore * 0.35 +
         countScore    * 0.20 +
         floorScore    * 0.10

    string projRelLabel = selectedCount == 0 ? "No Data" : (projReliability >= 80.0 ? "High  ▲" : projReliability >= 60.0 ? "Moderate ●" : projReliability >= 40.0 ? "Weak  ▼" : "Low  ✕")
    color  projRelColor = selectedCount == 0 ? color.gray : (projReliability >= 80.0 ? color.lime : projReliability >= 60.0 ? color.yellow : projReliability >= 40.0 ? color.orange : color.red)

    float currentAtr      = atr14[anchorTotal]
    float projEndSdAll    = array.size(allSd) > 0 ? array.get(allSd, array.size(allSd) - 1) : na
    float projAtrSpread   = not na(projEndSdAll) and not na(currentAtr) and currentAtr > 0.0 ? (projEndSdAll * base * 2.0) / currentAtr : na
    string bandSpreadStr  = na(projAtrSpread) ? "n/a" : str.tostring(projAtrSpread, "#.00") + " ATR"
    color  bandSpreadColor = na(projAtrSpread) ? color.gray : projAtrSpread < 2.0 ? color.lime : projAtrSpread < 4.0 ? color.yellow : projAtrSpread < 8.0 ? color.orange : color.red

    string lockLabel = ""
    string lockValue = ""
    color  lockColor = color.gray

    if lockCandle
        if lockStatus == "Locked"
            lockLabel := "Anchor"
            lockValue := str.tostring(daysBack) + "d back · " + str.tostring(anchorOffset) + " bars"
            lockColor := color.lime
        else
            lockLabel := "Anchor"
            lockValue := "No Anchor Lock"
            lockColor := color.orange
    else
        lockLabel := "Lookback"
        lockValue := str.tostring(anchorOffset) + " bars"
        lockColor := color.gray

    string volFilterStr = (useRegimeFilter ? "ON" : "OFF") + " · " + str.tostring(regimeTolerance, "#.00")
    string momFilterStr = (useMomentumFilter ? "ON" : "OFF") + " · " + str.tostring(momentumTolerance, "#.0")

    // ADDED — realized accuracy strings
    float hitPct   = trackTotal > 0 ? 100.0 * trackCorrect / trackTotal : na
    string hitStr  = not trackAccuracy ? "Off" : (trackTotal > 0 ? str.tostring(hitPct, "#.0") + "% (" + str.tostring(trackTotal) + ")" : "Warming up")
    color  hitColor = not trackAccuracy ? color.gray : (trackTotal < 20 ? color.gray : hitPct >= 55.0 ? color.lime : hitPct >= 50.0 ? color.yellow : color.red)

    if showInfoBox
        // row 0 — Header
        table.cell(infoTbl, 0, 0, "PRICE PROJECTION", text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.merge_cells(infoTbl, 0, 0, 1, 0)

        // row 1 — Column headers
        table.cell(infoTbl, 0, 1, "Metric",     text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 1, "Value",      text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 2 — Pattern Length
        table.cell(infoTbl, 0, 2, "Pattern Length", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 2, str.tostring(patternLen), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 3 — Search Depth
        table.cell(infoTbl, 0, 3, "Search Depth", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 3, str.tostring(searchBars), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 4 — Forecast Horizon
        table.cell(infoTbl, 0, 4, "Forecast Horizon", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 4, str.tostring(horizon), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 5 — Bull Prob %
        table.cell(infoTbl, 0, 5, "Bull Prob %", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 5, str.tostring(probBull, "#.0") + "%", text_color=bullPctColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 6 — Bear Prob %
        table.cell(infoTbl, 0, 6, "Bear Prob %", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 6, str.tostring(probBear, "#.0") + "%", text_color=bearPctColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // row 7 — Direction Bias
        table.cell(infoTbl, 0, 7, "Direction Bias", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 7, biasText, text_color=biasColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // rows 8–13 — Medium and Large only
        if infoBoxMode == "Medium" or infoBoxMode == "Large"
            // row 8 — Expected Move
            table.cell(infoTbl, 0, 8, "Expected Move", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 8, expectedMoveStr, text_color=expectedMoveColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 9 — Match Quality
            table.cell(infoTbl, 0, 9, "Match Quality", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 9, projRelLabel + " (" + str.tostring(projReliability, "#") + ")", text_color=projRelColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 10 — Sim Floor / Fit
            table.cell(infoTbl, 0, 10, "Sim Floor / Fit", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 10, str.tostring(effectiveSim, "#.0") + "%" + (floorHit ? " ⚠" : "") + " / " + (na(avgSimScore) ? "n/a" : str.tostring(avgSimScore, "#.0") + "%"), text_color=simFloorColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 11 — Bull/Bear/Flat
            table.cell(infoTbl, 0, 11, "Bull/Bear/Flat", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 11, str.tostring(bullCount) + "/" + str.tostring(bearCount) + "/" + str.tostring(flatCount) + " · " + str.tostring(selectedCount), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 12 — Projection ATR
            table.cell(infoTbl, 0, 12, "Projection ATR", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 12, bandSpreadStr, text_color=bandSpreadColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 13 — Anchor / Lookback
            table.cell(infoTbl, 0, 13, lockLabel, text_color=lockColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 13, lockValue, text_color=lockColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // ADDED — Realized Hit-Rate row (Medium row 14, Large row 23)
        if infoBoxMode == "Medium" or infoBoxMode == "Large"
            int hitRow = infoBoxMode == "Large" ? 23 : 14
            table.cell(infoTbl, 0, hitRow, "Hit-Rate", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, hitRow, hitStr, text_color=hitColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        // rows 14–22 — Large only
        if infoBoxMode == "Large"
            // row 14 — Log Returns
            color logRetColor = useLogRet ? color.lime : color.gray
            table.cell(infoTbl, 0, 14, "Log Returns", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 14, useLogRet ? "ON" : "OFF", text_color=logRetColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 15 — Volatility Filter
            color volFilterColor = useRegimeFilter ? color.lime : color.gray
            table.cell(infoTbl, 0, 15, "Volatility", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 15, volFilterStr, text_color=volFilterColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 16 — Momentum Filter
            color momFilterColor = useMomentumFilter ? color.lime : color.gray
            table.cell(infoTbl, 0, 16, "Momentum", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 16, momFilterStr, text_color=momFilterColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 17 — Normalize Pattern
            color zScoreColor = useZScore ? color.lime : color.gray
            table.cell(infoTbl, 0, 17, "Normalize Pattern", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 17, useZScore ? "ON" : "OFF", text_color=zScoreColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 18 — Correlation Sim
            color corrColor = useCorrelation ? color.lime : color.gray
            table.cell(infoTbl, 0, 18, "Correlation Sim", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 18, useCorrelation ? "ON" : "OFF", text_color=corrColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 19 — Outcome Weighting
            color outcomeWgtColor = useOutcomeWeighting ? color.lime : color.gray
            table.cell(infoTbl, 0, 19, "Outcome Weight", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 19, useOutcomeWeighting ? "ON" : "OFF", text_color=outcomeWgtColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 20 — Model
            string modelValue = useKNNProjection ? "KNN · K=" + str.tostring(knnNeighbors) : "Analog Threshold"
            color  modelColor = useKNNProjection ? color.aqua : color.gray
            table.cell(infoTbl, 0, 20, "Model", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 20, modelValue, text_color=modelColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 21 — Probability
            string probModelValue = useBayesianProb ? "Bayesian · " + str.tostring(bayesEvidenceStrength, "#.00") + "x" : "Weighted Analog"
            color  probModelColor = useBayesianProb ? color.aqua : color.gray
            table.cell(infoTbl, 0, 21, "Probability", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 21, probModelValue, text_color=probModelColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

            // row 22 — Enhancements + Diagnostics
            string enhStr = "Ovlp " + (useOverlapFilter ? str.tostring(effGap) : "OFF") + " · Path " + (pathAwareClassify ? "ON" : "OFF")
            table.cell(infoTbl, 0, 22, "Enhancements", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
            table.cell(infoTbl, 1, 22, enhStr, text_color=color.aqua, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.set_border_color(infoTbl, infoBorderColor)
        table.set_frame_color(infoTbl, infoBorderColor)
        table.set_frame_width(infoTbl, 1)
    else
        int clearRows = infoBoxMode == "Small" ? 7 : infoBoxMode == "Medium" ? 14 : 23
        table.clear(infoTbl, 0, 0, 1, clearRows)

alertcondition(bullProbabilityAlert, "Bullish Probability Alert", "Bullish probability threshold and minimum bull/bear edge requirement met.")
alertcondition(bearProbabilityAlert, "Bearish Probability Alert", "Bearish probability threshold and minimum bull/bear edge requirement met.")
alertcondition(directionalProbabilityAlert, "Directional Probability Alert", "Bullish or Bearish probability threshold and minimum bull/bear edge requirement met.")
````
