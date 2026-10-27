# Footprint X-Ray [BOSWaves]

- url: https://www.tradingview.com/script/dZ8yMLo3-Footprint-X-Ray-BOSWaves/
- type: indicator
- pine_id: PUB;be6c7839a41e4addbbbb60b41c4e8252
- version: 1.0

## Description

[b]Footprint X-Ray [BOSWaves] - Intrabar Delta Decomposition with Stacked Imbalance, Absorption, and Unfinished Business Detection[/b]

[b]Overview[/b]

Footprint X-Ray [BOSWaves] is an intrabar order flow decomposition system that reconstructs the buy and sell volume distribution within each bar by pulling lower timeframe data and mapping participation to price rows, where row coloring, POC identification, stacked imbalance detection, and signal generation are driven by actual delta ratios at each price level rather than bar-level approximations or close-position estimates.

[image]https://www.tradingview.com/x/yPUrz6WH/[/image]

Instead of treating each bar as a single undifferentiated unit of buying or selling pressure, the indicator divides each bar's price range into rows sized relative to ATR, assigns lower timeframe bar volume to each row based on price overlap, and derives a per-row delta ratio that reflects whether buying or selling dominated at each specific price level within the bar. This creates a full participation map inside every candle showing not just what direction the bar moved but where within the bar each side was in control.

This creates an order flow framework that reveals the internal structure of price action invisible on a standard candlestick chart. The footprint cells expose per-level delta composition, the POC identifies the price row with the greatest participation, stacked imbalances highlight consecutive rows with dominant one-sided flow indicating aggressive institutional activity, absorption signals detect when extreme rows show opposing flow against the bar direction, and unfinished business zones project forward from bars where one side was entirely absent at the extreme, marking locations where price is statistically likely to return to complete the auction.

Price is therefore evaluated not at the bar level but at the price row level, exposing order flow dynamics that standard indicators cannot access.

[b]Conceptual Framework[/b]

Footprint X-Ray is founded on the principle that the most actionable order flow information lives inside individual bars rather than across them, and that understanding which specific price levels within a bar attracted aggressive buying or selling reveals institutional positioning fingerprints that bar-level indicators systematically obscure.

Standard order flow approaches measure directional commitment at the bar level through delta, volume, or close positioning, but these metrics collapse the internal price distribution into a single reading that loses the structural detail of where within the bar each side dominated. This framework recovers that internal structure by reconstructing per-row participation from lower timeframe data, exposing the distribution of buying and selling pressure across the full price range of every bar.

Three core principles guide the design:
[list=1]
[*]Each price row within a bar should have its own buy and sell volume measurement derived from lower timeframe participation overlap, providing per-level delta ratios rather than bar-level approximations.
[*]Structural patterns within the footprint, specifically stacked consecutive dominant rows and opposing flow at extremes, carry meaningful institutional activity signals that justify dedicated detection and visualization separate from raw row coloring.
[*]Unfinished auction levels where one side was entirely absent at a bar extreme should be projected forward as active reference zones until price returns to complete the participation, as incomplete auctions represent the highest-probability reversion targets within the footprint framework.
[/list]
This shifts order flow analysis from bar-level delta measurement into per-row intrabar participation mapping where structural footprint patterns expose institutional activity with precision unavailable at the candlestick level.

[b]Theoretical Foundation[/b]

The indicator combines lower timeframe OHLCV data retrieval, price overlap-weighted volume allocation to ATR-derived price rows, per-row delta ratio calculation, POC identification by maximum row volume, consecutive dominance run detection for stacked imbalances, extreme row opposing flow detection for absorption, and one-sided extreme row detection for unfinished business zone projection.

Lower timeframe bars are retrieved using security_lower_tf and each lower timeframe bar's volume is allocated to price rows proportionally based on the overlap between the lower timeframe bar's range and each row's boundaries. Bullish lower timeframe bars contribute their allocated volume to buy volume and bearish bars to sell volume, with doji bars split equally. CVD from TradingView's volume delta library provides the bar-level delta for divergence and exhaustion detection. Row size is automatically derived as a fraction of the 200-bar ATR, scaling the footprint granularity to the instrument's typical volatility.

Four internal systems operate in tandem:
[list]
[*][i]Row Construction and Delta Allocation Engine[/i]: Divides each bar's price range into ATR-scaled rows, iterates through all lower timeframe bars within the current chart bar, allocates volume to overlapping rows by price range fraction, and derives per-row buy volume, sell volume, total volume, and delta ratio.
[*][i]Footprint Analysis System[/i]: Identifies the POC as the row with maximum total volume, runs consecutive dominance detection in both bull and bear directions to classify stacked imbalance rows, and evaluates extreme rows for absorption by testing opposing side dominance against the configured threshold.
[*][i]Unfinished Business Zone Engine[/i]: Tests the top and bottom rows of each bar for single-sided extreme dominance, creates forward-projecting zone boxes from qualifying rows, extends those zones rightward on each subsequent bar, and removes them when price midpoint is revisited.
[*][i]Signal Detection System[/i]: Derives bar delta from the CVD series, tests for delta divergence against recent price highs and lows, and identifies exhaustion bars where volume significantly exceeds the SMA baseline but net delta remains near zero, indicating a contested bar where neither side achieved directional resolution.
[/list]
This design provides a complete intrabar participation map with structural pattern detection across every dimension of order flow that is reconstructable from OHLCV data.

[b]How It Works[/b]

Footprint X-Ray evaluates price through a sequence of intrabar decomposition and pattern detection processes:
[list=1]
[*][i]Lower Timeframe Selection[/i]: The indicator automatically selects the most appropriate lower timeframe based on the current chart timeframe, using one-second for seconds charts, one-minute for intraday, five-minute for daily, and sixty-minute for higher timeframes, or the manually configured timeframe when auto selection is disabled.
[*][i]Row Size Calculation[/i]: The ATR over 200 bars multiplied by 0.1 and rounded to the minimum tick produces the row height, scaled automatically to the instrument's volatility. Manual row sizing overrides this when auto sizing is disabled.
[*][i]Lower Timeframe Data Retrieval[/i]: OHLCV arrays for the lower timeframe are retrieved via security_lower_tf and CVD is calculated using TradingView's volume delta library, providing both intrabar participation data and bar-level delta for signal detection.
[*][i]Row Initialization[/i]: The bar's price range is divided into rows of equal height, with the number of rows derived from the range divided by the row size.
[*][i]Volume Allocation per Row[/i]: For each row, all lower timeframe bars are iterated. Each lower timeframe bar contributing to a row has its volume allocated proportionally based on the fraction of its range overlapping the row boundary. Bullish lower timeframe bars contribute to buy volume and bearish bars to sell volume.
[*][i]Delta Ratio Calculation[/i]: Each row's delta ratio is calculated as buy volume minus sell volume divided by total volume, producing a normalized score from negative one to positive one that drives cell coloring.
[*][i]POC Identification[/i]: The row with the maximum total volume is identified as the Point of Control, receiving a distinct highlight color and an optional midpoint line.
[*][i]Stacked Imbalance Detection[/i]: Consecutive bullish dominant rows exceeding the configured threshold ratio are identified as bullish stacked imbalances. The same logic in reverse identifies bearish stacks. Qualifying rows receive highlighted border coloring.
[*][i]Absorption Detection[/i]: The top rows of green bars are tested for sell dominance and the bottom rows of red bars are tested for buy dominance. When opposing flow exceeds the absorption threshold at an extreme, an absorption signal is generated at the bar's high or low.
[*][i]Unfinished Business Zone Creation[/i]: The top row of each bar is tested for buy dominance above the UB threshold and the bottom row for sell dominance above the threshold. Qualifying extreme rows generate forward-projecting zone boxes that extend rightward until price revisits the zone midpoint.
[*][i]Delta Divergence Detection[/i]: Price making a new high within the lookback window while bar delta is negative generates a bearish divergence signal. Price making a new low while bar delta is positive generates a bullish divergence signal.
[*][i]Exhaustion Bar Detection[/i]: Bars with volume exceeding the SMA baseline multiplied by the volume multiplier and with absolute delta-to-volume ratio below the configured maximum qualify as exhaustion bars, indicating high participation without directional resolution.
[*][i]Candle Overlay Rendering[/i]: An optional transparent candle overlay with wicks colored by bar delta direction provides directional context on top of the footprint cell display without obscuring the underlying participation data.
[/list]
Together, these elements form a continuously updating intrabar participation map where cell coloring reveals per-level delta composition, structural pattern detection identifies institutional activity signatures, and forward-projecting zones maintain active auction completion references.

[b]Interpretation[/b]

Footprint X-Ray should be interpreted as an intrabar order flow decomposition system with layered structural pattern detection:
[list]
[*][i]Footprint Cells[/i]: Each colored box represents a price row within the bar. Green shading indicates buy-dominant flow at that level, red shading indicates sell-dominant flow, and color intensity reflects the magnitude of the imbalance. Neutral rows with balanced participation appear at intermediate opacity.
[*][i]Cell Text (Delta %)[/i]: The percentage displayed in each cell represents the net delta ratio for that row, quantifying how one-sided participation was at each specific price level within the bar.
[*][i]Cell Text (Volume)[/i]: When volume mode is selected, each cell displays the net volume (buy minus sell) at that price row, providing absolute rather than relative participation data.
[*][i]Accent Lines[/i]: A bright horizontal line on the dominant edge of each row highlights the side with greater participation, providing a clean visual boundary that reinforces the directional reading of each cell without requiring the text to be read.
[*][i]POC Row[/i]: The row with the highest total volume receives a distinct highlight and optional midpoint line, marking the price level with the greatest participation concentration within the bar and the most significant auction reference point.
[*][i]Stacked Imbalance Borders[/i]: Rows identified as part of a consecutive dominant run receive highlighted border coloring in the imbalance direction, signaling aggressive institutional one-sided flow across multiple consecutive price levels within the bar.
[*][i]Absorption Diamonds[/i]: Diamond markers below bars indicate bullish absorption where buyers dominated the bottom rows of a red bar, suggesting selling pressure was being absorbed by aggressive buyers. Diamonds above bars indicate bearish absorption where sellers dominated the top rows of a green bar.
[*][i]Unfinished Business Zones[/i]: Forward-projecting shaded boxes from extreme rows where one side was entirely absent mark incomplete auctions. Bullish UB zones project from bars where buyers dominated the top row without seller response. Bearish UB zones project from bars where sellers dominated the bottom row without buyer response.
[*][i]Delta Divergence Crosses[/i]: Cross markers below price on bullish divergences and above price on bearish divergences identify structural disagreement between price direction and bar delta, flagging hidden weakness at new highs and hidden strength at new lows.
[*][i]Exhaustion Circles[/i]: Orange circles on bars with extreme volume but near-zero net delta mark contested bars where neither side achieved resolution despite heavy participation, indicating potential inflection points where the prior directional move may be losing conviction.
[*][i]Delta Wicks[/i]: Optional candle overlay wicks colored by bar delta direction provide an immediate visual cue for whether net buying or net selling dominated the bar as a whole, complementing the per-row cell analysis.
[/list]
Per-row delta composition, POC location, stacked imbalance presence, absorption signals, unfinished business zones, and exhaustion bars collectively provide more order flow intelligence than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Footprint X-Ray presents five distinct signal types derived from intrabar participation analysis:
[list=1]
[*][i]Absorption Signal[/i]: Diamond markers generated when extreme rows show opposing flow against the bar direction, identifying institutional absorption of aggressive flow at price extremes.
[*][i]Delta Divergence Signal[/i]: Cross markers generated when price makes new highs or lows within the lookback window but bar delta contradicts the directional move, flagging structurally weak breakouts.
[*][i]Exhaustion Bar Signal[/i]: Orange circles generated on bars with exceptional volume and near-zero net delta, identifying participation battles where neither side achieved dominance despite heavy activity.
[/list]
Unfinished business zones provide continuous passive signal context by projecting forward from incomplete auction extremes until price returns to complete the participation sequence.

Alert generation covers bullish and bearish CVD flips, bullish and bearish absorption events, bullish and bearish delta divergence, and exhaustion bar detection for comprehensive systematic order flow monitoring.

[b]Strategy Integration[/b]

Footprint X-Ray fits within institutional order flow and auction theory-based trading approaches:
[list]
[*][i]POC Reaction Trading[/i]: Use POC rows as high-probability reference levels within each bar. The highest-volume row represents the price level most accepted by both buyers and sellers and frequently acts as intrabar support, resistance, or reversion anchor on subsequent price interaction.
[*][i]Stacked Imbalance Directional Bias[/i]: Use stacked imbalance detection as a directional conviction signal within bars. Consecutive buy-dominant rows from low to high indicate sustained aggressive buying across multiple price levels, suggesting institutional accumulation rather than isolated speculative activity.
[*][i]Absorption Reversal Framing[/i]: Use absorption signals as potential reversal triggers where aggressive flow is meeting organized opposing participation at extremes. Bullish absorption at the low of a red bar suggests buyers are defending price levels despite selling pressure, while bearish absorption at the high of a green bar suggests sellers are resisting upside extension.
[*][i]Unfinished Business Zone Targets[/i]: Use UB zones as reversion targets for subsequent price action, monitoring whether price returns to complete the auction at levels where one side was previously absent. The completion of an unfinished auction typically involves a return to the zone followed by the missing side finally participating.
[*][i]Divergence-Confirmed Entries[/i]: Use delta divergence signals as structural warning indicators rather than standalone entries, weighting them more heavily when they coincide with other confluence factors such as absorption or unfinished business zone proximity.
[*][i]Exhaustion Bar Context[/i]: Treat exhaustion bars as inflection point alerts requiring subsequent bar confirmation rather than immediate entry triggers. High volume with near-zero delta indicates a contested equilibrium that will resolve directionally on the following bars.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Delta Source[/i]: TradingView volume delta library providing CVD series with automatic lower timeframe selection
[*][i]Row Construction[/i]: ATR-fraction row sizing with lower timeframe price overlap-weighted volume allocation per row
[*][i]Analysis Engine[/i]: Maximum volume POC identification, consecutive dominance run detection for stacked imbalances, and extreme row opposing flow testing for absorption
[*][i]UB System[/i]: Array-managed forward-projecting zone boxes with midpoint revisit detection and automatic removal
[*][i]Signal Detection[/i]: CVD-based delta divergence against lookback window highs and lows, volume SMA ratio combined with delta ratio for exhaustion classification
[*][i]Visualization[/i]: Gradient-colored footprint cells with accent lines, POC highlighting, stacked imbalance borders, absorption and divergence markers, exhaustion circles, UB zones, and optional delta wick candle overlay
[*][i]Performance Profile[/i]: Optimized with object count caps and array management for real-time execution across intraday and higher timeframes
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intrabar microstructure analysis for scalping with automatic one-minute lower timeframe providing high-resolution participation data within each chart bar
[*][i]15 - 60 min[/i]: Session-level order flow decomposition for intraday trading with sufficient lower timeframe bar count per chart bar to produce meaningful row distributions
[*][i]4H - Daily[/i]: Swing-level institutional footprint analysis with five-minute lower timeframe providing detailed participation mapping across larger price ranges
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Auto Lower Timeframe[/i]: Enabled
[*][i]Auto Row Size[/i]: Enabled
[*][i]Cell Text[/i]: Delta %
[*][i]Accent Lines[/i]: Enabled
[*][i]Highlight POC Row[/i]: Enabled
[*][i]Show Stacked Imbalances[/i]: Enabled
[*][i]Min Consecutive Rows[/i]: 3
[*][i]Dominance Threshold (SI)[/i]: 0.60
[*][i]Show Absorption[/i]: Enabled
[*][i]Show Unfinished Business[/i]: Enabled
[*][i]Delta Divergence[/i]: Enabled
[*][i]Exhaustion Bars[/i]: Enabled
[*][i]Show Candle Overlay[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volume characteristics, typical bar range, and preferred signal sensitivity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too few rows per bar[/i]: Disable Auto Row Size and manually reduce the row size value to increase row count, producing a more granular footprint with finer price level resolution for the target instrument and timeframe combination.
[*][i]Too many rows cluttering the display[/i]: Increase the manual row size or allow auto sizing to recalibrate. On higher timeframes with large bar ranges the automatic ATR fraction may produce excessive row counts that reduce readability.
[*][i]Stacked imbalance signals too frequent[/i]: Increase the Min Consecutive Rows setting to require longer dominance runs before stacking is classified, or increase the Dominance Threshold toward 0.75 to demand stronger per-row directional conviction.
[*][i]Absorption signals too frequent[/i]: Increase the Absorption Threshold toward 0.80 to require stronger opposing dominance at extremes before an absorption signal fires, filtering for only the most decisive institutional responses.
[*][i]Too many unfinished business zones[/i]: Increase the UB Dominance Threshold toward 0.90 to restrict zone creation to only the most extreme single-sided bar extremes, reducing zone density on the chart.
[*][i]Divergence signals firing too often[/i]: Increase the Divergence Lookback to require price to make a more significant new high or low before the divergence condition tests, reducing signal frequency to only the most structurally significant disagreements.
[*][i]Exhaustion signals too frequent[/i]: Increase the Volume Multiplier to require a larger volume spike above the baseline before exhaustion classification, or decrease the Max Delta Ratio to require closer to zero net delta for a bar to qualify.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Liquid instruments with consistent volume where lower timeframe bar allocation produces meaningful per-row participation distributions and reliable delta measurements
[*]Intraday and session-level timeframes where sufficient lower timeframe bars exist within each chart bar to produce statistically representative row-level volume allocation
[*]Order flow-based trading approaches where intrabar participation patterns provide entry confirmation or invalidation context that bar-level indicators cannot supply
[*]Institutional activity monitoring where stacked imbalances and absorption patterns reveal aggressive positioning that precedes significant directional moves
[/list]
Reduced Effectiveness:
[list]
[*]Low-liquidity instruments where thin lower timeframe volume produces sparse row distributions with many empty cells and unreliable per-level delta ratios
[*]Higher timeframes on instruments without lower timeframe data availability where security_lower_tf returns insufficient bars per chart bar for meaningful decomposition
[*]Instruments without volume data, which the indicator detects and blocks with a runtime error
[*]Extremely fast markets during news events where lower timeframe bars are so large relative to the chart bar range that overlap allocation produces distorted row distributions
[*]Thin or extended-hours sessions where volume is too low to produce statistically meaningful per-row participation differences distinguishable from random distribution
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, trend indicators, or momentum oscillators to validate footprint-derived signals with broader analytical context before acting on intrabar participation patterns
[*][i]POC Context[/i]: Treat POC rows as the most significant intrabar reference levels. Subsequent price returning to a prior bar's POC is returning to its highest-participation level, which frequently acts as support, resistance, or magnetic reversion anchor.
[*][i]Stacked Imbalance Direction[/i]: Use stacked imbalance direction as a short-term institutional bias indicator. Consecutive buy-dominant rows from low to high suggest aggressive accumulation that may continue on subsequent bars. Consecutive sell-dominant rows suggest distribution.
[*][i]Unfinished Business Patience[/i]: Allow UB zones to be approached naturally rather than anticipating reactions immediately after formation. The auction completion process can take multiple bars and the zone should be monitored for participation behavior on arrival rather than treated as an automatic reversal level.
[*][i]Exhaustion Confirmation Requirement[/i]: Never treat exhaustion bars as standalone entry triggers. The exhaustion condition identifies a contested state that requires subsequent directional resolution. Wait for the following bar to confirm which side won the participation battle before acting on the exhaustion signal.
[/list]
[b]Disclaimer[/b]

Footprint X-Ray [BOSWaves] is a professional-grade intrabar order flow decomposition and institutional activity detection tool. It uses lower timeframe volume allocation with per-row delta calculation but does not access true exchange-level bid and ask data. All participation measurements are reconstructed from OHLCV data and represent best-approximation estimates rather than actual order book information. Results depend on instrument liquidity, lower timeframe data availability, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates price structure, trend context, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Foot Print X-Ray [BOSWaves]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

import TradingView/ta/10 as ta

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

const string gTF   = "Timeframe"
const string gFP   = "Footprint"
const string gPOC  = "Point of Control"
const string gSI   = "Stacked Imbalance"
const string gAbs  = "Absorption"
const string gUB   = "Unfinished Business"
const string gSig  = "Signals"
const string gCol  = "Colors"
const string gCndl = "Candle Overlay"

bool   autoTF    = input.bool(true, "Auto Lower Timeframe", group = gTF, tooltip = "Automatically selects the best lower timeframe for delta calculation.")
string ltfInput  = input.timeframe("1", "Manual LTF", group = gTF)

bool   autoSz    = input.bool(true, "Auto Row Size", inline = "sz", group = gFP, tooltip = "Automatically sizes rows based on ATR.")
float  manSz     = input.float(20., "", inline = "sz", group = gFP)
string txtMode   = input.string("Delta %", "Cell Text", options = ["Delta %", "Volume", "None"], group = gFP, tooltip = "What to display in each footprint cell.")
bool   showAcc   = input.bool(true, "Accent Lines", group = gFP, tooltip = "Bright line on the dominant edge of each row.")

bool   showPOC   = input.bool(true, "Highlight POC Row", group = gPOC, tooltip = "The row with the highest total volume gets a distinct highlight.")
color  pocCol    = input.color(#ffffff, "POC Color", group = gPOC)
bool   showPOCln = input.bool(true, "POC Line", group = gPOC, tooltip = "Draws a horizontal line at the POC price level.")

bool   showSI    = input.bool(true, "Show Stacked Imbalances", group = gSI, tooltip = "Highlights consecutive rows with dominant one-sided flow — indicates aggressive institutional activity.")
int    siMinRows = input.int(3, "Min Consecutive Rows", minval = 2, maxval = 10, group = gSI)
float  siThresh  = input.float(0.60, "Dominance Threshold", minval = 0.5, maxval = 0.95, step = 0.05, group = gSI, tooltip = "Minimum ratio for a row to count. 0.60 = 60%+ on one side.")

bool   showAbsorb    = input.bool(true, "Show Absorption", group = gAbs, tooltip = "Detects when aggressive flow is absorbed at extremes — buying absorbed at highs or selling absorbed at lows.")
int    absorbRows    = input.int(2, "Extreme Rows to Check", minval = 1, maxval = 5, group = gAbs)
float  absorbThresh  = input.float(0.65, "Absorption Threshold", minval = 0.5, maxval = 0.95, step = 0.05, group = gAbs, tooltip = "How dominant the opposing side must be in extreme rows.")

bool   showUB     = input.bool(true, "Show Unfinished Business", group = gUB, tooltip = "Extreme rows with one-sided flow — price tends to return to complete the auction.")
float  ubThresh   = input.float(0.85, "Dominance Threshold", minval = 0.6, maxval = 0.98, step = 0.05, group = gUB)

bool   showDiv       = input.bool(true, "Delta Divergence", group = gSig, tooltip = "Price makes a new high/low but delta disagrees — warns of hidden weakness or strength.")
int    divLookback   = input.int(10, "Divergence Lookback", minval = 3, maxval = 50, group = gSig)
bool   showExh       = input.bool(true, "Exhaustion Bars", group = gSig, tooltip = "Extremely high volume but near-zero net delta — neither side won despite heavy participation.")
float  exhVolMult    = input.float(2.0, "Volume Multiplier", minval = 1.5, maxval = 5.0, step = 0.5, group = gSig)
float  exhDeltaPct   = input.float(0.15, "Max Delta Ratio", minval = 0.05, maxval = 0.4, step = 0.05, group = gSig, tooltip = "abs(delta)/volume must be below this to qualify as exhaustion.")

color  buyCol    = input.color(#00ff00, "Buyers", inline = "c", group = gCol)
color  sellCol   = input.color(#ff0000, "Sellers", inline = "c", group = gCol)
bool   colAuto   = input.bool(true, "Color Text by Box", inline = "tx", group = gCol)
color  textCol   = input.color(#ffffff, "Text Color", inline = "tx", group = gCol, tooltip = "Only used if Color Text by Box is OFF.")
color  siBullCol = input.color(#00ff00, "SI Bull", inline = "si", group = gCol)
color  siBearCol = input.color(#ff0000, "SI Bear", inline = "si", group = gCol)
color  ubBullCol = input.color(#00ff00, "UB Bull", inline = "ub", group = gCol)
color  ubBearCol = input.color(#ff0000, "UB Bear", inline = "ub", group = gCol)

bool   showCandle = input.bool(true, "Show Candle Overlay", group = gCndl)

// ┌────────────────────────────── BOSWaves ─ Volume Guard ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var float _vchk = 0.
_vchk += nz(volume)
if barstate.islast and _vchk == 0
    runtime.error("No volume data. Foot Print X-Ray requires volume.")

// ┌────────────────────────────── BOSWaves ─ Delta ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
string lowerTF = autoTF ?
     (timeframe.isseconds ? "1S" :
      timeframe.isintraday ? "1" :
      timeframe.isdaily ? "5" : "60") :
     ltfInput

[ov, hv, lv, cvd] = ta.requestVolumeDelta(lowerTF, timeframe.period)
cvd := nz(cvd)
float barDelta = cvd - nz(cvd[1])

// ┌────────────────────────────── BOSWaves ─ Lower TF Data ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_ohlcv() => [open, high, low, close, volume]
[_o, _h, _l, _c, _v] = request.security_lower_tf(syminfo.tickerid, lowerTF, f_ohlcv())

// ┌────────────────────────────── BOSWaves ─ Helpers ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
fmtVol(float v) =>
    float a = math.abs(v)
    string s = v < 0 ? "-" : ""
    a >= 1e6 ? s + str.tostring(a / 1e6, "#.#") + "M" :
     a >= 1e3 ? s + str.tostring(a / 1e3, "#.#") + "K" :
     s + str.tostring(a, "#")

// ┌────────────────────────────── BOSWaves ─ UB Zone Tracking ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var ubPrices = array.new<float>()
var ubTops   = array.new<float>()
var ubBots   = array.new<float>()
var ubBoxes  = array.new<box>()
var ubSide   = array.new<int>()

if ubBoxes.size() > 0
    for i = ubBoxes.size() - 1 to 0
        float mid = ubPrices.get(i)
        if high >= mid and low <= mid
            ubBoxes.get(i).delete()
            ubBoxes.remove(i)
            ubPrices.remove(i)
            ubTops.remove(i)
            ubBots.remove(i)
            ubSide.remove(i)
            continue
        ubBoxes.get(i).set_right(bar_index)

while ubBoxes.size() > 50
    ubBoxes.shift().delete()
    ubPrices.shift()
    ubTops.shift()
    ubBots.shift()
    ubSide.shift()

// ┌────────────────────────────── BOSWaves ─ Row Data Buffers ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var rowBV   = array.new<float>()
var rowSV   = array.new<float>()
var rowTot  = array.new<float>()
var rowRat  = array.new<float>()
var rowTops = array.new<float>()
var rowBots = array.new<float>()
var siMark  = array.new<int>()

rowBV.clear()
rowSV.clear()
rowTot.clear()
rowRat.clear()
rowTops.clear()
rowBots.clear()
siMark.clear()

// ┌────────────────────────────── BOSWaves ─ Step 1: Compute Rows ───────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float rowSz  = autoSz ? math.round_to_mintick(ta.atr(200) * 0.1) : manSz
int   nRows  = math.max(1, math.round((high - low) / rowSz))
float step   = (high - low) / nRows
int   ltfCnt = _o.size()

float rBot = low
for i = 0 to nRows - 1
    float rTop = rBot + step
    float bv = 0.
    float sv = 0.

    if ltfCnt > 0
        for j = 0 to ltfCnt - 1
            float jh = _h.get(j)
            float jl = _l.get(j)
            if jh >= rBot and jl <= rTop
                float olap = math.min(jh, rTop) - math.max(jl, rBot)
                float rng  = jh - jl
                float frac = rng > 0 ? olap / rng : 1.
                float av   = _v.get(j) * frac
                if _c.get(j) > _o.get(j)
                    bv += av
                else if _c.get(j) < _o.get(j)
                    sv += av
                else
                    bv += av * 0.5
                    sv += av * 0.5

    float tot   = bv + sv
    float ratio = tot > 0 ? (bv - sv) / tot : 0.

    rowBV.push(bv)
    rowSV.push(sv)
    rowTot.push(tot)
    rowRat.push(ratio)
    rowTops.push(rTop)
    rowBots.push(rBot)
    siMark.push(0)

    rBot := rTop

// ┌────────────────────────────── BOSWaves ─ Step 2: Analysis ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// POC — row with highest total volume
int   pocIdx = 0
float pocVol = 0.
for i = 0 to nRows - 1
    if rowTot.get(i) > pocVol
        pocVol := rowTot.get(i)
        pocIdx := i

// Stacked Imbalance — consecutive dominant rows
if showSI and nRows >= siMinRows
    // Bullish stacks
    int bullRun   = 0
    int bullStart = 0
    for i = 0 to nRows - 1
        if rowRat.get(i) >= siThresh
            if bullRun == 0
                bullStart := i
            bullRun += 1
        else
            if bullRun >= siMinRows
                for j = bullStart to i - 1
                    siMark.set(j, 1)
            bullRun := 0
    if bullRun >= siMinRows
        for j = bullStart to nRows - 1
            siMark.set(j, 1)

    // Bearish stacks
    int bearRun   = 0
    int bearStart = 0
    for i = 0 to nRows - 1
        if rowRat.get(i) <= -siThresh
            if bearRun == 0
                bearStart := i
            bearRun += 1
        else
            if bearRun >= siMinRows
                for j = bearStart to i - 1
                    siMark.set(j, -1)
            bearRun := 0
    if bearRun >= siMinRows
        for j = bearStart to nRows - 1
            siMark.set(j, -1)

// Absorption — opposing flow at extremes
bool bullAbsorb = false
bool bearAbsorb = false

if showAbsorb and nRows >= absorbRows
    // Check top rows: sell-dominant on a green candle = bearish absorption
    float topSV  = 0.
    float topTot = 0.
    for i = math.max(0, nRows - absorbRows) to nRows - 1
        topSV  += rowSV.get(i)
        topTot += rowTot.get(i)
    float topSellRat = topTot > 0 ? topSV / topTot : 0.
    bearAbsorb := close > open and topSellRat >= absorbThresh

    // Check bottom rows: buy-dominant on a red candle = bullish absorption
    float botBV  = 0.
    float botTot = 0.
    for i = 0 to math.min(absorbRows - 1, nRows - 1)
        botBV  += rowBV.get(i)
        botTot += rowTot.get(i)
    float botBuyRat = botTot > 0 ? botBV / botTot : 0.
    bullAbsorb := close < open and botBuyRat >= absorbThresh

// ┌────────────────────────────── BOSWaves ─ Step 3: Draw Footprint ─────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
for i = 0 to nRows - 1
    float bv    = rowBV.get(i)
    float sv    = rowSV.get(i)
    float tot   = rowTot.get(i)
    float ratio = rowRat.get(i)
    float rT    = rowTops.get(i)
    float rB    = rowBots.get(i)
    bool  isPOC = i == pocIdx and showPOC
    int   si    = siMark.get(i)

    color rc    = color.from_gradient(ratio, -1, 1, sellCol, buyCol)
    int   alpha = int(math.max(35, 82 - math.abs(ratio) * 47))

    // Override for POC and SI
    color bgC = color.new(rc, alpha)
    color bdC = color.new(chart.fg_color, 93)
    int   bdW = 1

    if isPOC
        bgC := color.new(pocCol, 25)
        bdC := color.new(pocCol, 40)
        bdW := 2
    else if si == 1 and showSI
        bdC := color.new(siBullCol, 10)
        bdW := 2
    else if si == -1 and showSI
        bdC := color.new(siBearCol, 10)
        bdW := 2

    string txt = switch txtMode
        "Delta %"  => tot > 0 ? str.tostring(ratio * 100, "#.0") + "%" : ""
        "Volume"   => tot > 0 ? fmtVol(bv - sv) : ""
        => ""

    color txC = colAuto ? color.new(rc, math.max(0, alpha - 35)) : textCol
    if isPOC
        txC := color.new(pocCol, 0)

    box.new(bar_index, rT, bar_index + 1, rB,
         bgcolor      = bgC,
         border_color = bdC,
         border_width = bdW,
         text         = txt,
         text_color   = txC,
         text_size    = size.auto)

    // Accent line on dominant edge
    if showAcc and tot > 0
        float accY   = (bv - sv) >= 0 ? rT : rB
        int   accAlp = int(math.max(5, alpha - 30))
        line.new(bar_index, accY, bar_index + 1, accY,
             color = color.new(rc, accAlp), width = 2)

// POC line across the bar
if showPOC and showPOCln and nRows > 0
    float pocMid = math.avg(rowTops.get(pocIdx), rowBots.get(pocIdx))
    line.new(bar_index, pocMid, bar_index + 1, pocMid,
         color = color.new(pocCol, 30), width = 1, style = line.style_solid)

// ┌────────────────────────────── BOSWaves ─ Unfinished Business ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showUB and nRows >= 2
    // Top row: buy-dominant = sellers never showed up
    float topBV  = rowBV.get(nRows - 1)
    float topSV  = rowSV.get(nRows - 1)
    float topTot = topBV + topSV
    if topTot > 0 and topBV / topTot >= ubThresh
        float zT = rowTops.get(nRows - 1)
        float zB = rowBots.get(nRows - 1)
        ubPrices.push(math.avg(zT, zB))
        ubTops.push(zT)
        ubBots.push(zB)
        ubSide.push(-1)
        ubBoxes.push(box.new(bar_index + 1, zT, bar_index, zB,
             bgcolor = color.new(ubBearCol, 85),
             border_color = color.new(ubBearCol, 60),
             border_width = 1))

    // Bottom row: sell-dominant = buyers never showed up
    float botBV  = rowBV.get(0)
    float botSV  = rowSV.get(0)
    float botTot = botBV + botSV
    if botTot > 0 and botSV / botTot >= ubThresh
        float zT = rowTops.get(0)
        float zB = rowBots.get(0)
        ubPrices.push(math.avg(zT, zB))
        ubTops.push(zT)
        ubBots.push(zB)
        ubSide.push(1)
        ubBoxes.push(box.new(bar_index + 1, zT, bar_index, zB,
             bgcolor = color.new(ubBullCol, 85),
             border_color = color.new(ubBullCol, 60),
             border_width = 1))

// ┌────────────────────────────── BOSWaves ─ Signal Detection ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// Delta Divergence
bool priceHH     = high > ta.highest(high[1], divLookback)
bool priceLL     = low < ta.lowest(low[1], divLookback)
bool bearDiv     = showDiv and priceHH and barDelta < 0
bool bullDiv     = showDiv and priceLL and barDelta > 0

// Exhaustion
float volSMA     = ta.sma(volume, 20)
bool  isExh      = showExh and volume > volSMA * exhVolMult and (volume > 0 ? math.abs(barDelta) / volume < exhDeltaPct : false)

// ┌────────────────────────────── BOSWaves ─ Signal Plots ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// Absorption
plotshape(showAbsorb and bullAbsorb ? low : na, "Bullish Absorption", shape.diamond, location.belowbar, buyCol, size = size.tiny)
plotshape(showAbsorb and bearAbsorb ? high : na, "Bearish Absorption", shape.diamond, location.abovebar, sellCol, size = size.tiny)

// Delta Divergence
plotshape(bullDiv ? low : na, "Bullish Divergence", shape.cross, location.belowbar, buyCol, size = size.tiny)
plotshape(bearDiv ? high : na, "Bearish Divergence", shape.cross, location.abovebar, sellCol, size = size.tiny)

// Exhaustion
plotshape(isExh ? close : na, "Exhaustion", shape.circle, location.absolute, color.orange, size = size.tiny)

// ┌────────────────────────────── BOSWaves ─ Candle Overlay ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color wickCol = barDelta >= 0 ? buyCol : sellCol

plotcandle(
     showCandle ? open : na,
     showCandle ? math.max(close, open) : na,
     showCandle ? math.min(close, open) : na,
     showCandle ? open : na,
     bordercolor = color.new(color.black, 100),
     color       = color.new(color.black, 100),
     wickcolor   = color.new(wickCol, 20))

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(barDelta > 0 and barDelta[1] <= 0, "Foot Print X-Ray Flip Bullish", "Foot Print X-Ray flipped positive on {{ticker}}")
alertcondition(barDelta < 0 and barDelta[1] >= 0, "Foot Print X-Ray Flip Bearish", "Foot Print X-Ray flipped negative on {{ticker}}")
alertcondition(bullAbsorb, "Bullish Absorption", "Buying absorbed at lows on {{ticker}}")
alertcondition(bearAbsorb, "Bearish Absorption", "Selling absorbed at highs on {{ticker}}")
alertcondition(bullDiv, "Bullish Divergence", "New low with positive delta on {{ticker}}")
alertcondition(bearDiv, "Bearish Divergence", "New high with negative delta on {{ticker}}")
alertcondition(isExh, "Exhaustion Bar", "High volume near-zero delta on {{ticker}}")
````
