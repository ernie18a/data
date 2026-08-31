<!-- tradingview-pine-id: PUB;093661aea74a4a8594fe5ec39960916b -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Distribution Volume Profile (Zeiierman)

Source: https://www.tradingview.com/script/8owCUqFq-Multi-Distribution-Volume-Profile-Zeiierman/

## Description

█ Overview
Multi-Distribution Volume Profile (Zeiierman) is a flexible, structure-first volume profile tool that lets you reshape how volume is distributed across price, from classic uniform profiles to advanced statistical curves like Gaussian, Lognormal, Student-t, and more.

Instead of forcing every market into a single "one-size-fits-all" profile, this tool lets you model how volume is likely concentrated inside each bar (body vs wicks, midpoint, tails, center bias, right-skew, heavy tails, etc.) and then stacks that behavior across a whole lookback window to build a rich, multi-distribution map of traded activity.
[image]https://www.tradingview.com/x/QPB4gfps/ [/image]
On top of that, it overlays a dynamic Center Band (value area) and a fade/gradient model that can color each price row by volume, hits, recency, volatility, reversals, or even liquidity voids, turning a plain profile into a multi-dimensional context map.
[image]https://www.tradingview.com/x/2J5J8tOE/[/image]
Highlights

[*]Choose from multiple Profile Build Modes, including uniform, body-only, wick-only, midpoint/close/open, center-weighted, and a suite of probability-style distributions (Gaussian, Lognormal, Weibull, Student-t, etc.)
[*]Flexible anchor layout: draw the profile on Right/Left (horizontal) or Bottom/Top (vertical) to fit any chart layout
[*]Value Area / Center Band computed from volume quantiles around the POC.
[*]Gradient-based Fade Metrics: volume, price hits, freshness (time decay), volatility impact, dwell time, reversal density, compression, and liquidity voids
[*]Separate bullish vs bearish volume at each price row for directional structure insights

[image]https://www.tradingview.com/x/KE7x2Ink/[/image]
█ How It Works
⚪ Profile Construction
The script scans a user-defined Bars Included window and finds the full high–low span of that zone. It then divides this range into a user-controlled number of Price Levels (rows).

For each historical bar within the window:

[*]It measures the candle’s price range, body, and wicks.
[*]It assigns volume to rows according to the selected Profile Build Mode, for example:
* Range Uniform – volume spread evenly across the full high–low range.
* Range Body Only / Range Wick Only – concentrate volume inside the body or wicks only.
* Midpoint / Close / Open Only – allocate volume entirely into one price row (pinpoint modeling).
[*]  HL2 / Body Center Weighted – center weights around the middle of the range/body.
[*]  Recent-Weighted Volume – amplify newer bars using exponential time decay.
[*]  Volume Squared (Hard) – aggressively boost bars with large volume.
[*]  Up Bars Only / Down Bars Only – filter volume to only bullish or bearish bars.

For more advanced shapes, the script uses continuous distributions across the bar’s span:

[*]Linear, Triangular, Exponential to High
[*]Cosine Centered, PERT
[*]Gaussian, Lognormal, Cauchy, Laplace
[*]Pareto, Weibull, Logistic, Gumbel
[*]Gamma, Beta, Chi-Square, Student-t, F-Shape

Each distribution produces a weight for each row within the bar’s range, normalized so the total volume remains consistent, but the shape of where that volume lands changes.

⚪ POC & Center Band (Value Area)

Once all rows are accumulated:

[*]The row with the highest total volume becomes the Point of Control (POC)
[*]The script computes cumulative volume and finds the band that wraps a user-defined Center of Profile % (e.g., 68%) around the center of distribution.
[*]This range is displayed as a central band, often treated like a value area where price has spent the most “effort” trading.

⚪ Gradient Fade Engine

Each row also gets a fade metric, chosen in Fade Metric:

[*]Volume – opacity based on relative volume.
[*]Price Hits – how frequently that row was touched.
[*]Blended (Vol+Hits) – average of volume & hits.
[*]Freshness – emphasizes recent activity, controlled by Decay.
[*]Volatility Impact – rows that saw larger ranges contribute more.
[*]Dwell Time – where price “camped” the longest.
[*]Reversal Density – where direction changes cluster.
[*]Compression – tight-range compression zones.
[*]Liquidity Void – inverse of volume (thin liquidity zones).

When Apply Gradient is enabled, the row’s bullish/bearish colors are tinted from faint to strong based on this chosen metric, effectively turning the profile into a heatmap of your chosen structural property.

█ How to Use

⚪ Explore Different Distribution Assumptions

Switch between multiple Profile Build Modes to see how your assumptions about intrabar volume affect structure:

Use Range Uniform for classical profile reading.[image]https://www.tradingview.com/x/2o6fyM4I/[/image]
Deploy Gaussian, Logistic, or Cosine shapes to emphasize central clustering.
[image]https://www.tradingview.com/x/QKoKvHt0/[/image]
Try Pareto, Lognormal, or F-Shape to focus on tail / extremal activity.
[image]https://www.tradingview.com/x/oEbWfIUo/[/image]
Use Recent-Weighted Volume to prioritize the most recent structural behavior.
[image]https://www.tradingview.com/x/o58cNRaP/[/image]
This is especially useful for traders who want to test how different modeling assumptions change perceived value areas and levels of interest.

⚪ Identify Value, Acceptance & Rejection Zones

Use the POC and Center of Profile (%) band to distinguish:

[*]High-acceptance zones – wide central band, thick rows, strong gradient → fair value areas
[*]Rejection zones & tails – thin extremes, low dwell time, high volatility or reversal density

These regions can be used as:

[*]Targets and origin zones for mean reversion
[*]Context for breakout validation (leaving value)
[*]Bias reference for intraday rotations or swing rotations

[image]https://www.tradingview.com/x/UAUp3E8e/[/image]
⚪ Read Directional Structure Within the Profile

Because each row is split into bullish vs bearish contributions, you can visually read:

[*]Where buyers dominated a price region (large bullish slice)
[*]Where sellers absorbed or defended (large bearish slice)

Combining this with Fade Metrics like Reversal Density, Dwell Time, or Freshness turns the profile into a structural order-flow map, without needing raw tick-by-tick volume data.
[image]https://www.tradingview.com/x/x6mIWepV/[/image]
⚪ Use Fade Metrics for Contextual Heatmaps

Each Fade Metric can be used for a different analytical lens:

[*]Volume / Blended – emphasize where volume and activity are concentrated.
[*]Freshness – highlight the most recently active zones that still matter.
[*]Volatility Impact & Compression – spot areas of explosive moves vs coiled ranges.
[*]Reversal Density – locate micro turning points and battle zones.
[*]Liquidity Void – visually pop out thin regions that may act as speedways or magnets.

[image]https://www.tradingview.com/x/vWvBnJZG/[/image]

█ Settings

[*]Profile Build Mode – Selects how each bar’s volume is distributed across its price range (uniform, body/wick, midpoint/close/open, center-weighted, or statistical distribution families).
[*]Bars Included – Number of bars used to build the profile from the current bar backward.
[*]Price Levels – Vertical resolution of the profile: more levels = smoother but heavier.
[*]Anchor Side – Where the profile is drawn on the chart: Right, Left, Bottom, or Top.
[*]Offset (bars) – Horizontal offset from the last bar to the profile when using Right/Left modes.
[*]Apply Gradient – Toggles the fade/heatmap coloring based on the selected metric.
[*]Fade Metric – Chooses the property driving row opacity (Volume, Hits, Freshness, Volatility Impact, Dwell Time, Reversal Density, Compression, Liquidity Void).
[*]Decay – Time-decay factor for Freshness (values close to 1 keep older activity relevant for longer).
[*]Profile Thickness – Relative thickness of the profile along the time axis, as a % of the lookback window.
[*]Center of Profile (%) – Volume percentage used to define the central band (value area) around the POC.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator('Multi-Distribution Volume Profile (Zeiierman)', overlay = true, max_boxes_count = 500, max_bars_back = 5000)
//}
// ~~ Tooltips {
var string t1  = "How each bar's volume is distributed across price levels (uniform, body/wick based, or statistical shapes)."
var string t2  = "Number of historical bars to include when building the volume profile, counted back from the current bar."
var string t3  = "Number of price levels (rows) used in the profile. Higher = smoother but heavier, lower = coarser."
var string t4  = "Side of the chart where the profile is drawn (right/left as horizontal map or top/bottom as vertical map)."
var string t5  = "Horizontal offset in bars from the last bar to where the profile is anchored. Ignored in Top/Bottom modes."
var string t6  = "If enabled, row colors are faded using the selected metric instead of a flat, uniform color."
var string t7  = "Metric that controls the fade/opacity of each row (volume, hits, freshness, volatility, reversals, voids, etc.)."
var string t8  = "Per-bar decay factor for the Freshness metric. Closer to 1.000 keeps older activity visible for longer."
var string t9  = "Relative thickness of the profile on the time axis, as a percentage of the lookback window."
var string t10 = "Percentage of total volume used to define the central band (value area) around the POC (e.g., 68% ≈ 1σ)."
var string t11 = "Fill color used for bullish rows that lie inside the central profile band (value area)."
var string t12 = "Fill color used for bearish rows that lie inside the central profile band (value area)."
var string t13 = "Base body color for bullish volume outside the central band. Gradient is applied on top if enabled."
var string t14 = "Base body color for bearish volume outside the central band. Gradient is applied on top if enabled."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
profileMode = input.string('Gaussian Center', 'Profile Build Mode', options = ['Range Uniform', 
 'Range Body Only', 'Range Wick Only', 'Midpoint Only', 'Close Price Only', 'Open Price Only', 
 'HL2 Center Weighted', 'Body Center Weighted', 'Recent-Weighted Volume', 'Volume Squared (Hard)', 
 'Up Bars Only', 'Down Bars Only', 'Linear', 'Triangular Center', 'Exponential to High', 
 'Cosine Centered', 'PERT', 'Gaussian Center', 'Lognormal (Right-Skew)', 'Cauchy (Heavy Tails)', 
 'Laplace (Sharp Center)', 'Pareto (Tail-heavy)', 'Weibull (Shape Bias)', 'Logistic (S-Curve)', 
 'Gumbel (Extreme Value)', 'Gamma (Right-Skew)', 'Beta (Flexible Shape)', 'Chi-Square (Right-Tail)', 
 'Student-t (Fat Tails)', 'F-Shape (Variance Tail)'], 
 group = "Profile", inline="profile", tooltip=t1)

barsLookbackIn = input.int(240, 'Bars Included', minval = 50, maxval = 4000, step = 20, group = "Profile", inline="profile", tooltip=t1+ "\n\n" +t2)
levelsIn       = input.int(250, 'Price Levels', minval = 8, maxval = 250, step = 8, group = "Profile", inline="", tooltip=t3)

sideChoice     = input.string('Right Side', 'Anchor Side', options = ['Right Side', 'Left Side', 'Bottom', 'Top'], group = "Profile Layout", inline="anchor", tooltip=t4)
edgeOffsetBars = input.int(100, 'Offset (bars)', minval = 0, maxval = 150, group = "Profile Layout", inline="anchor", tooltip=t4+ "\n\n" +t5)

useGradient = input.bool(true, 'Apply Gradient', group = "Style & Colors", inline="gradient", tooltip=t6)
fadeMode    = input.string('Freshness', 'Fade Metric', options = ['Volume', 'Price Hits', 'Blended (Vol+Hits)', 
'Freshness', 'Volatility Impact', 'Dwell Time', 'Reversal Density', 'Compression', 'Liquidity Void'], group = "Style & Colors", inline="gradient", tooltip=t7)
freshDecay  = input.float(0.99, 'Decay', minval = 0.90, maxval = 0.999, step = 0.001, group = "Style & Colors", inline="gradient",active=fadeMode=="Freshness", tooltip=t6+ "\n\n" +t7+ "\n\n" +t8)
thicknessPctIn  = input.float(40.0, 'Profile Thickness', minval = 5, maxval = 250, step = 1, group = "Style & Colors", inline="thickness", tooltip=t9) / 100.0
centerBandPctIn = input.float(68.0, 'Center of Profile (%)', minval = 10, maxval = 95, step = 1, group = "Style & Colors", inline="Central", tooltip=t10)  / 100.0

colBandUp = input.color(color.new(#1e88e5, 25), 'Bullish', group = "Style & Colors", inline="col", tooltip=t11)
colBandDn = input.color(color.new(#ffb300, 25), 'Bearish', group = "Style & Colors", inline="col", tooltip=t11+ "\n\n" +t12)
colBodyUp = input.color(color.new(#616161, 50), 'Bullish', group = "Style & Colors", inline="col1", tooltip=t13)
colBodyDn = input.color(color.new(#cfd8dc, 55), 'Bearish', group = "Style & Colors", inline="col1", tooltip=t13+ "\n\n" +t14)

anchorRight  = sideChoice == 'Right Side'
anchorLeft   = sideChoice == 'Left Side'
anchorBottom = sideChoice == 'Bottom'
anchorTop    = sideChoice == 'Top'
extendRight  = anchorRight
extendLeft   = anchorLeft 

showMap = true
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ State {
var float profLow = na
var float profHigh = na
var int profStartIdx = na

// boxes for drawing
var array<box> boxes = array.new_box()

// per-row data
var array<float> volTotal = array.new_float()
var array<float> volUp = array.new_float()
var array<float> volDn = array.new_float()
var array<int> rowHits = array.new_int()
var array<int> reversalHits = array.new_int()
var array<float> rowVolatility = array.new_float()
var array<float> dwellTime = array.new_float()
var array<float> recencyScore = array.new_float()
var array<float> compressionSc = array.new_float()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helper {
f_reset_arrays(rows) =>
    if volTotal.size() != rows
        volTotal.clear()
        volUp.clear()
        volDn.clear()
        rowHits.clear()
        reversalHits.clear()
        rowVolatility.clear()
        dwellTime.clear()
        recencyScore.clear()
        compressionSc.clear()
        for i = 0 to rows - 1 by 1
            volTotal.push(0.0)
            volUp.push(0.0)
            volDn.push(0.0)
            rowHits.push(0)
            reversalHits.push(0)
            rowVolatility.push(0.0)
            dwellTime.push(0.0)
            recencyScore.push(0.0)
            compressionSc.push(0.0)
    else
        for i = 0 to rows - 1 by 1
            volTotal.set(i, 0.0)
            volUp.set(i, 0.0)
            volDn.set(i, 0.0)
            rowHits.set(i, 0)
            reversalHits.set(i, 0)
            rowVolatility.set(i, 0.0)
            dwellTime.set(i, 0.0)
            recencyScore.set(i, 0.0)
            compressionSc.set(i, 0.0)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Main { 
if barstate.islast and showMap
    // 1. Determine effective lookback & start index {
    lookbackBars = math.min(barsLookbackIn, bar_index + 1)
    profStartIdx := bar_index - lookbackBars + 1
    //} 

    if lookbackBars > 0
        // 2. Find price bounds within window {
        float lo = high
        float hi = low
        for i = 0 to lookbackBars - 1 by 1
            lo := math.min(lo, low[i])
            hi := math.max(hi, high[i])
            hi

        profLow := lo
        profHigh := hi

        priceSpan = profHigh - profLow
        rows = math.max(levelsIn, 1)
        priceStep = priceSpan > 0 ? priceSpan / rows : na
        //}  

        if priceSpan > 0 and not na(priceStep)
            // 3. Reset arrays {
            f_reset_arrays(rows)
            //}  

            // 4. Accumulate per-row stats (depends on profileMode) {
            for iBar = 0 to lookbackBars - 1 by 1
                barLow = low[iBar]
                barHigh = high[iBar]
                barVol = volume[iBar]
                isUp = close[iBar] >= open[iBar]
                barRange = barHigh - barLow
                barVolat = barRange

                dir = close[iBar] > open[iBar] ? 1 : close[iBar] < open[iBar] ? -1 : 0
                prevDir = close[iBar + 1] > open[iBar + 1] ? 1 : close[iBar + 1] < open[iBar + 1] ? -1 : 0
                isReversalBar = dir != 0 and prevDir != 0 and dir != prevDir

                bodyLow = math.min(open[iBar], close[iBar])
                bodyHigh = math.max(open[iBar], close[iBar])

                startRow = math.max(math.floor((barLow - profLow) / priceStep), 0)
                endRow = math.min(math.floor((barHigh - profLow) / priceStep), rows - 1)
                span = endRow - startRow + 1

                bodyStartRow = math.max(math.floor((bodyLow - profLow) / priceStep), 0)
                bodyEndRow = math.min(math.floor((bodyHigh - profLow) / priceStep), rows - 1)
                bodySpan = bodyEndRow >= bodyStartRow ? bodyEndRow - bodyStartRow + 1 : 0

                lowWickSpan = bodyStartRow > startRow ? bodyStartRow - startRow : 0
                highWickSpan = bodyEndRow < endRow ? endRow - bodyEndRow : 0
                wickSpan = lowWickSpan + highWickSpan

                weightRec = math.pow(freshDecay, iBar)

                effVol = barVol
                effIsUp = isUp

                if profileMode == 'Recent-Weighted Volume'
                    effVol := barVol * weightRec
                    effVol
                if profileMode == 'Volume Squared (Hard)'
                    effVol := barVol * barVol
                    effVol
                if profileMode == 'Up Bars Only' and not isUp
                    effVol := 0.0
                    effVol
                if profileMode == 'Down Bars Only' and isUp
                    effVol := 0.0
                    effVol

                if span <= 0 or effVol <= 0
                    continue

                midPrice = (barHigh + barLow) * 0.5
                hl2Row = math.floor((midPrice - profLow) / priceStep)
                closeRow = math.floor((close[iBar] - profLow) / priceStep)
                openRow = math.floor((open[iBar] - profLow) / priceStep)
                midRowClamped = math.min(math.max(hl2Row, 0), rows - 1)
                closeRowClamped = math.min(math.max(closeRow, 0), rows - 1)
                openRowClamped = math.min(math.max(openRow, 0), rows - 1)

                bool customSpanDist = profileMode == 'Linear' or profileMode == 'Triangular Center' or 
                 profileMode == 'Exponential to High' or profileMode == 'Cosine Centered' or 
                 profileMode == 'PERT' or profileMode == 'Gaussian Center' or 
                 profileMode == 'Lognormal (Right-Skew)' or profileMode == 'Cauchy (Heavy Tails)' or 
                 profileMode == 'Laplace (Sharp Center)' or profileMode == 'Pareto (Tail-heavy)' or 
                 profileMode == 'Weibull (Shape Bias)' or profileMode == 'Logistic (S-Curve)' or 
                 profileMode == 'Gumbel (Extreme Value)' or profileMode == 'Gamma (Right-Skew)' or 
                 profileMode == 'Beta (Flexible Shape)' or profileMode == 'Chi-Square (Right-Tail)' or 
                 profileMode == 'Student-t (Fat Tails)' or profileMode == 'F-Shape (Variance Tail)'

                // parameters for distribution modes
                float sumW = 0.0
                float expBase = 1.3
                float pertAlpha = 2.5
                float pertBeta = 2.5
                float gaussMu = 0.5
                float gaussSigma = 0.2
                float lnMu = -0.5
                float lnSigma = 0.4
                float cauchyScale = 0.18
                float laplaceB = 0.18
                float paretoAlpha = 2.0
                float weibullK = 2.0
                float weibullLam = 1.0
                float logisticScale = 0.12
                float gumbelBeta = 0.20
                float gammaK = 2.0
                float gammaTheta = 0.5
                float betaAlpha = 0.5
                float betaBeta = 0.5
                float chiK = 3.0
                float studNu = 3.0
                float studScale = 0.22
                float fD1 = 3.0
                float fD2 = 5.0

                // precompute normalization for distribution modes
                if customSpanDist and span > 0
                    for k = 0 to span - 1 by 1
                        float w = 0.0
                        float t = span == 1 ? 0.5 : k / (span - 1.0)
                        float tSafe = math.min(0.999, math.max(0.001, t))

                        if profileMode == 'Linear'
                            w := tSafe
                            w

                        else if profileMode == 'Triangular Center'
                            center = 0.5
                            w := 1.0 - math.abs(t - center) * 2.0
                            w

                        else if profileMode == 'Exponential to High'
                            w := math.pow(expBase, t * (span - 1))
                            w

                        else if profileMode == 'Cosine Centered'
                            w := 0.5 - 0.5 * math.cos(2.0 * math.pi * t)
                            w

                        else if profileMode == 'PERT'
                            w := math.pow(tSafe, pertAlpha - 1.0) * math.pow(1.0 - tSafe, pertBeta - 1.0)
                            w

                        else if profileMode == 'Gaussian Center'
                            z = (t - gaussMu) / gaussSigma
                            w := math.exp(-0.5 * z * z)
                            w

                        else if profileMode == 'Lognormal (Right-Skew)'
                            lnT = math.log(tSafe)
                            zln = (lnT - lnMu) / lnSigma
                            w := math.exp(-0.5 * zln * zln) / tSafe
                            w

                        else if profileMode == 'Cauchy (Heavy Tails)'
                            x = (t - 0.5) / cauchyScale
                            w := 1.0 / (1.0 + x * x)
                            w

                        else if profileMode == 'Laplace (Sharp Center)'
                            w := math.exp(-math.abs(t - 0.5) / laplaceB)
                            w

                        else if profileMode == 'Pareto (Tail-heavy)'
                            u = 1.0 - tSafe
                            w := 1.0 / math.pow(u + 0.001, paretoAlpha)
                            w

                        else if profileMode == 'Weibull (Shape Bias)'
                            w := weibullK * math.pow(tSafe / weibullLam, weibullK - 1.0) * math.exp(-math.pow(tSafe / weibullLam, weibullK))
                            w

                        else if profileMode == 'Logistic (S-Curve)'
                            w := 1.0 / (1.0 + math.exp(-(t - 0.5) / logisticScale))
                            w

                        else if profileMode == 'Gumbel (Extreme Value)'
                            zG = (t - 0.5) / gumbelBeta
                            w := math.exp(-(zG + math.exp(-zG)))
                            w

                        else if profileMode == 'Gamma (Right-Skew)'
                            w := math.pow(tSafe, gammaK - 1.0) * math.exp(-tSafe / gammaTheta)
                            w

                        else if profileMode == 'Beta (Flexible Shape)'
                            w := math.pow(tSafe, betaAlpha - 1.0) * math.pow(1.0 - tSafe, betaBeta - 1.0)
                            w

                        else if profileMode == 'Chi-Square (Right-Tail)'
                            w := math.pow(tSafe, chiK / 2.0 - 1.0) * math.exp(-tSafe / 2.0)
                            w

                        else if profileMode == 'Student-t (Fat Tails)'
                            xT = (t - 0.5) / studScale
                            w := math.pow(1.0 + xT * xT / studNu, -(studNu + 1.0) / 2.0)
                            w

                        else if profileMode == 'F-Shape (Variance Tail)'
                            xF = tSafe
                            numPow = fD1 / 2.0 - 1.0
                            denPow = (fD1 + fD2) / 2.0
                            w := math.pow(xF, numPow) / math.pow(1.0 + fD1 / fD2 * xF, denPow)
                            w

                        if w > 0
                            sumW := sumW + w
                            sumW

                // loop through rows and apply mode-specific weighting
                for r = startRow to endRow by 1
                    rowActive = false
                    rowWeight = 0.0

                    isBodyRow = r >= bodyStartRow and r <= bodyEndRow and bodySpan > 0
                    isWickRow = wickSpan > 0 and not isBodyRow

                    if profileMode == 'Range Uniform'
                        rowActive := true
                        rowWeight := 1.0 / span
                        rowWeight

                    else if profileMode == 'Range Body Only'
                        if isBodyRow and bodySpan > 0
                            rowActive := true
                            rowWeight := 1.0 / bodySpan
                            rowWeight

                    else if profileMode == 'Range Wick Only'
                        if isWickRow and wickSpan > 0
                            rowActive := true
                            rowWeight := 1.0 / wickSpan
                            rowWeight

                    else if profileMode == 'Midpoint Only'
                        if r == midRowClamped
                            rowActive := true
                            rowWeight := 1.0
                            rowWeight

                    else if profileMode == 'Close Price Only'
                        if r == closeRowClamped
                            rowActive := true
                            rowWeight := 1.0
                            rowWeight

                    else if profileMode == 'Open Price Only'
                        if r == openRowClamped
                            rowActive := true
                            rowWeight := 1.0
                            rowWeight

                    else if profileMode == 'HL2 Center Weighted'
                        distNorm = span > 1 ? math.min(1.0, math.abs(r - midRowClamped) / (span - 1)) : 0.0
                        wHL = 1.0 - distNorm
                        if wHL > 0
                            rowActive := true
                            rowWeight := wHL / span
                            rowWeight

                    else if profileMode == 'Body Center Weighted'
                        if isBodyRow and bodySpan > 0
                            bodyMidRow = (bodyStartRow + bodyEndRow) * 0.5
                            bodySpanNorm = bodySpan > 1 ? bodySpan - 1 : 1
                            distNormBody = math.min(1.0, math.abs(r - bodyMidRow) / bodySpanNorm)
                            wBody = 1.0 - distNormBody
                            if wBody > 0
                                rowActive := true
                                rowWeight := wBody / bodySpan
                                rowWeight

                    else if profileMode == 'Recent-Weighted Volume'
                        rowActive := true
                        rowWeight := 1.0 / span
                        rowWeight

                    else if profileMode == 'Volume Squared (Hard)'
                        rowActive := true
                        rowWeight := 1.0 / span
                        rowWeight

                    else if profileMode == 'Up Bars Only'
                        if effVol > 0
                            rowActive := true
                            rowWeight := 1.0 / span
                            rowWeight

                    else if profileMode == 'Down Bars Only'
                        if effVol > 0
                            rowActive := true
                            rowWeight := 1.0 / span
                            rowWeight

                    else if customSpanDist
                        pos = r - startRow
                        float wRow = 0.0
                        float tRow = span == 1 ? 0.5 : pos / (span - 1.0)
                        float tSafeRow = math.min(0.999, math.max(0.001, tRow))

                        if profileMode == 'Linear'
                            wRow := tSafeRow
                            wRow

                        else if profileMode == 'Triangular Center'
                            center2 = 0.5
                            wRow := 1.0 - math.abs(tRow - center2) * 2.0
                            wRow

                        else if profileMode == 'Exponential to High'
                            wRow := math.pow(expBase, tRow * (span - 1))
                            wRow

                        else if profileMode == 'Cosine Centered'
                            wRow := 0.5 - 0.5 * math.cos(2.0 * math.pi * tRow)
                            wRow

                        else if profileMode == 'PERT'
                            wRow := math.pow(tSafeRow, pertAlpha - 1.0) * math.pow(1.0 - tSafeRow, pertBeta - 1.0)
                            wRow

                        else if profileMode == 'Gaussian Center'
                            zR = (tRow - gaussMu) / gaussSigma
                            wRow := math.exp(-0.5 * zR * zR)
                            wRow

                        else if profileMode == 'Lognormal (Right-Skew)'
                            lnTR = math.log(tSafeRow)
                            zlnR = (lnTR - lnMu) / lnSigma
                            wRow := math.exp(-0.5 * zlnR * zlnR) / tSafeRow
                            wRow

                        else if profileMode == 'Cauchy (Heavy Tails)'
                            xR = (tRow - 0.5) / cauchyScale
                            wRow := 1.0 / (1.0 + xR * xR)
                            wRow

                        else if profileMode == 'Laplace (Sharp Center)'
                            wRow := math.exp(-math.abs(tRow - 0.5) / laplaceB)
                            wRow

                        else if profileMode == 'Pareto (Tail-heavy)'
                            uR = 1.0 - tSafeRow
                            wRow := 1.0 / math.pow(uR + 0.001, paretoAlpha)
                            wRow

                        else if profileMode == 'Weibull (Shape Bias)'
                            wRow := weibullK * math.pow(tSafeRow / weibullLam, weibullK - 1.0) * math.exp(-math.pow(tSafeRow / weibullLam, weibullK))
                            wRow

                        else if profileMode == 'Logistic (S-Curve)'
                            wRow := 1.0 / (1.0 + math.exp(-(tRow - 0.5) / logisticScale))
                            wRow

                        else if profileMode == 'Gumbel (Extreme Value)'
                            zGR = (tRow - 0.5) / gumbelBeta
                            wRow := math.exp(-(zGR + math.exp(-zGR)))
                            wRow

                        else if profileMode == 'Gamma (Right-Skew)'
                            wRow := math.pow(tSafeRow, gammaK - 1.0) * math.exp(-tSafeRow / gammaTheta)
                            wRow

                        else if profileMode == 'Beta (Flexible Shape)'
                            wRow := math.pow(tSafeRow, betaAlpha - 1.0) * math.pow(1.0 - tSafeRow, betaBeta - 1.0)
                            wRow

                        else if profileMode == 'Chi-Square (Right-Tail)'
                            wRow := math.pow(tSafeRow, chiK / 2.0 - 1.0) * math.exp(-tSafeRow / 2.0)
                            wRow

                        else if profileMode == 'Student-t (Fat Tails)'
                            xTR = (tRow - 0.5) / studScale
                            wRow := math.pow(1.0 + xTR * xTR / studNu, -(studNu + 1.0) / 2.0)
                            wRow

                        else if profileMode == 'F-Shape (Variance Tail)'
                            xFR = tSafeRow
                            numPw = fD1 / 2.0 - 1.0
                            denPw = (fD1 + fD2) / 2.0
                            wRow := math.pow(xFR, numPw) / math.pow(1.0 + fD1 / fD2 * xFR, denPw)
                            wRow

                        if wRow > 0 and sumW > 0
                            rowActive := true
                            rowWeight := wRow / sumW
                            rowWeight

                    if not rowActive or rowWeight <= 0
                        continue

                    volContrib = effVol * rowWeight

                    // accumulate profile volume
                    oldTotal = volTotal.get(r)
                    volTotal.set(r, oldTotal + volContrib)

                    if effIsUp
                        oldUp = volUp.get(r)
                        volUp.set(r, oldUp + volContrib)
                    else
                        oldDn = volDn.get(r)
                        volDn.set(r, oldDn + volContrib)

                    // metrics
                    hits = rowHits.get(r)
                    rowHits.set(r, hits + 1)

                    if isReversalBar
                        rv = reversalHits.get(r)
                        reversalHits.set(r, rv + 1)

                    volImp = rowVolatility.get(r)
                    rowVolatility.set(r, volImp + barVolat / span)

                    dwell = dwellTime.get(r)
                    dwellTime.set(r, dwell + 1.0 / span)

                    rec = recencyScore.get(r)
                    recencyScore.set(r, rec + weightRec)

                    comp = compressionSc.get(r)
                    compressionFactor = barRange > 0 ? priceStep / barRange : 0.0
                    compressionSc.set(r, comp + compressionFactor / span)
            //} 

            // 5. Compute POC and central band {
            pocIdx = 0
            maxVol = 0.0
            totalVol = 0.0
            for r = 0 to rows - 1 by 1
                v = volTotal.get(r)
                totalVol := totalVol + v
                if v > maxVol
                    maxVol := v
                    pocIdx := r
                    pocIdx

            if totalVol > 0
                lowerTarget = totalVol * (0.5 - centerBandPctIn * 0.5)
                upperTarget = totalVol * (0.5 + centerBandPctIn * 0.5)

                float cum = 0.0
                int bandLowIdx = 0
                int bandHiIdx = rows - 1
                bool upperFound = false

                for r = 0 to rows - 1 by 1
                    cum := cum + volTotal.get(r)
                    if cum <= lowerTarget
                        bandLowIdx := r
                        bandLowIdx
                    if not upperFound and cum >= upperTarget
                        bandHiIdx := r
                        upperFound := true
                        upperFound

                pocPrice = profLow + (pocIdx + 0.5) * priceStep
                bandLow = profLow + (bandLowIdx + 0.0) * priceStep
                bandHigh = profLow + (bandHiIdx + 1.0) * priceStep
                //} 

                // 6. per-row maxes for fade metrics {
                maxHits = 0
                maxRec = 0.0
                maxVolImpRow = 0.0
                maxDwellRow = 0.0
                maxCompRow = 0.0
                maxRevHits = 0

                for r = 0 to rows - 1 by 1
                    hits = rowHits.get(r)
                    rec = recencyScore.get(r)
                    vImp = rowVolatility.get(r)
                    dw = dwellTime.get(r)
                    comp = compressionSc.get(r)
                    rev = reversalHits.get(r)

                    maxHits := math.max(maxHits, hits)
                    maxRec := math.max(maxRec, rec)
                    maxVolImpRow := math.max(maxVolImpRow, vImp)
                    maxDwellRow := math.max(maxDwellRow, dw)
                    maxCompRow := math.max(maxCompRow, comp)
                    maxRevHits := math.max(maxRevHits, rev)
                    maxRevHits
                //} 

                // 7. Clear existing boxes {
                while boxes.size() > 0
                    box.delete(boxes.pop())
                //} 

                // 8. Horizontal span for drawing (time axis) {
                plotLen = lookbackBars > 360 ? 360 : lookbackBars
                profWidth = plotLen * thicknessPctIn

                bool verticalMode = anchorBottom or anchorTop

                float histHeight = priceSpan * 0.4
                float baseYBottom = profLow - histHeight
                float baseYTop = profHigh + histHeight

                effectiveOffset = verticalMode ? 0 : edgeOffsetBars

                histRight = bar_index + effectiveOffset
                histLeft = histRight - rows 

                rightEdge = bar_index + effectiveOffset
                leftEdge = rightEdge - int(profWidth)

                baseLeft = extendRight ? leftEdge : profStartIdx
                baseRight = extendRight ? rightEdge : profStartIdx + int(profWidth)
                //}  

                // 9. Row-by-row drawing {
                for r = 0 to rows - 1 by 1
                    rowVol = volTotal.get(r)
                    upVol = volUp.get(r)
                    dnVol = volDn.get(r)
                    hits = rowHits.get(r)
                    rev = reversalHits.get(r)
                    vImp = rowVolatility.get(r)
                    dw = dwellTime.get(r)
                    rec = recencyScore.get(r)
                    comp = compressionSc.get(r)

                    volRel = maxVol > 0 ? rowVol / maxVol : 0.0
                    hitRel = maxHits > 0 ? hits / maxHits : 0.0
                    freshRel = maxRec > 0 ? rec / maxRec : 0.0
                    volImpRel = maxVolImpRow > 0 ? vImp / maxVolImpRow : 0.0
                    dwellRel = maxDwellRow > 0 ? dw / maxDwellRow : 0.0
                    compRel = maxCompRow > 0 ? comp / maxCompRow : 0.0
                    revRel = maxRevHits > 0 ? rev / maxRevHits : 0.0

                    voidRel = 1.0 - volRel

                    fadeRel = switch fadeMode
                        'Volume' => volRel
                        'Price Hits' => hitRel
                        'Blended (Vol+Hits)' => (volRel + hitRel) * 0.5
                        'Freshness' => freshRel
                        'Volatility Impact' => volImpRel
                        'Dwell Time' => dwellRel
                        'Reversal Density' => revRel
                        'Compression' => compRel
                        'Liquidity Void' => voidRel
                        => volRel

                    upCol = useGradient ? color.from_gradient(fadeRel, 0.0, 1.0, color.new(colBodyUp, 95), color.new(colBodyUp, 0)) : colBodyUp
                    dnCol = useGradient ? color.from_gradient(fadeRel, 0.0, 1.0, color.new(colBodyDn, 95), color.new(colBodyDn, 0)) : colBodyDn
                    bandUp = useGradient ? color.from_gradient(fadeRel, 0.0, 1.0, color.new(colBandUp, 95), color.new(colBandUp, 0)) : colBandUp
                    bandDn = useGradient ? color.from_gradient(fadeRel, 0.0, 1.0, color.new(colBandDn, 95), color.new(colBandDn, 0)) : colBandDn

                    inBand = r >= bandLowIdx and r <= bandHiIdx

                    upFrac = maxVol > 0 ? upVol / maxVol : 0.0
                    dnFrac = maxVol > 0 ? dnVol / maxVol : 0.0

                    if not verticalMode
                        upBars = upFrac * profWidth
                        dnBars = dnFrac * profWidth

                        rowLo = profLow + (r + 0.05) * priceStep
                        rowHi = profLow + (r + 0.95) * priceStep

                        if upBars > 0
                            bxStart = extendRight ? baseRight - int(upBars) : baseLeft
                            bxEnd = extendRight ? baseRight : baseLeft + int(upBars)
                            cRow = inBand ? bandUp : upCol
                            b = box.new(bxStart, rowLo, bxEnd, rowHi, bgcolor = cRow, border_color = color.new(cRow, 100))
                            boxes.push(b)

                        if dnBars > 0
                            bxStart2 = extendRight ? baseRight - int(upBars) - int(dnBars) : baseLeft + int(upBars)
                            bxEnd2 = extendRight ? baseRight - int(upBars) : baseLeft + int(upBars) + int(dnBars)
                            cRow2 = inBand ? bandDn : dnCol
                            b2 = box.new(bxStart2, rowLo, bxEnd2, rowHi, bgcolor = cRow2, border_color = color.new(cRow2, 100))
                            boxes.push(b2)

                    else
                        xStart = histLeft + r
                        xEnd = xStart + 1

                        heightScale = histHeight

                        if anchorBottom
                            baseY = baseYBottom

                            if upFrac > 0
                                y0u = baseY
                                y1u = baseY + upFrac * heightScale
                                cRowU = inBand ? bandUp : upCol
                                bu = box.new(xStart, y0u, xEnd, y1u, bgcolor = cRowU, border_color = color.new(cRowU, 100))
                                boxes.push(bu)

                            if dnFrac > 0
                                y0d = baseY + upFrac * heightScale
                                y1d = baseY + (upFrac + dnFrac) * heightScale
                                cRowD = inBand ? bandDn : dnCol
                                bd = box.new(xStart, y0d, xEnd, y1d, bgcolor = cRowD, border_color = color.new(cRowD, 100))
                                boxes.push(bd)

                        else if anchorTop
                            baseY = baseYTop

                            if upFrac > 0
                                y0u = baseY
                                y1u = baseY - upFrac * heightScale
                                cRowU = inBand ? bandUp : upCol
                                bu = box.new(xStart, y0u, xEnd, y1u, bgcolor = cRowU, border_color = color.new(cRowU, 100))
                                boxes.push(bu)

                            if dnFrac > 0
                                y0d = baseY - upFrac * heightScale
                                y1d = baseY - (upFrac + dnFrac) * heightScale
                                cRowD = inBand ? bandDn : dnCol
                                bd = box.new(xStart, y0d, xEnd, y1d, bgcolor = cRowD, border_color = color.new(cRowD, 100))
                                boxes.push(bd)
                //} 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
