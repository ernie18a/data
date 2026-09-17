<!-- tradingview-pine-id: PUB;f50f214f0ad746db95632facdaf64f4d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CCI Divergence Volume Breakout [josseliani]

Source: https://www.tradingview.com/script/YY0gbu2C-CCI-Divergence-Volume-Breakout-josseliani/

## Description

CCI Divergence Volume Breakout combines confirmed CCI divergence with a relative-volume candle level. It waits for a confirmed close beyond that candle's high or low before displaying a BUY or SELL signal, and it can optionally map Entry, a volume-candle-based stop, 1R, and historical R-reach statistics.

The default settings are tuned for XAUUSD on the 7-minute chart, but the indicator can be adapted to other instruments and timeframes. The statistics dashboard updates for the current symbol, timeframe, loaded chart history, and selected inputs, making it easy to see how different settings affect the sample size and historical R-reach rates.

→ HOW I USE IT

The default settings are the configuration I currently use for XAUUSD on the 7-minute chart.

Seven minutes is the favorite timeframe of my wonderful wave-analysis teacher. I built this version around the way he studies the market: first CCI divergence, then a meaningful volume spike. After that, he moves on to his own wave-analysis methods, including trendlines, wave count, structure, and broader market context. This indicator does not reproduce or replace his complete method. I use it as a supporting tool within my own wave analysis.

With the default settings, the script first searches for a confirmed CCI divergence. It then selects a qualifying volume candle connected to that divergence. The first search covers the divergence span; if necessary, it checks the area around the second pivot and then watches the post-confirmation candidate window. A qualifying candle must have volume of at least 1.5 times its 20-bar average.

For a bullish divergence, the high of the selected volume candle becomes the confirmation level. A BUY signal appears only after a candle closes above that high within the permitted breakout window.

For a bearish divergence, the low of the selected volume candle becomes the confirmation level. A SELL signal appears only after a candle closes below that low within the permitted breakout window.

The optional trade map starts from the open of the candle after the signal. It displays an Entry line, a stop behind the opposite edge of the exact volume candle plus the selected ATR delta, and a 1R reference target.

I use the dashboard to compare configurations rather than to treat one historical percentage as a promise. For example, changing the minimum volume multiple, pivot-matching radius, maximum distance between pivots, candidate-search window, or breakout window changes how often historical observations reached 0.5R, 1R, 2R, and 3R. This helps me see the trade-off between signal selectivity and historical excursion.

→ HOW THE INDICATOR WORKS

→ 1. Automatic CCI pivot scan

The script evaluates confirmed CCI pivots using strengths 3, 5, 7, and 9. The first pivot must be beyond the selected extreme threshold. The second pivot may form closer to the center of the oscillator.

A bullish divergence requires price to form a lower low while CCI forms a higher low. A bearish divergence requires price to form a higher high while CCI forms a lower high.

CCI pivots require bars on the right to become confirmed. For that reason, divergence lines are anchored to their historical pivot candles only after confirmation. They do not represent information that was available on the original pivot candle. BUY and SELL signals are evaluated only on confirmed closes after the divergence has been confirmed.

→ 2. Price-pivot matching

CCI and price do not always turn on exactly the same candle. Price Pivot Match Radius searches on both sides of each CCI endpoint for the corresponding price high or low.

Maximum Price/CCI Span Difference then checks that the two price pivots and the two CCI pivots describe approximately the same market swing. Lower values require tighter alignment; higher values allow more flexibility.

→ 3. Relative-volume candle selection

When a divergence becomes confirmed, the script first searches its pivot-to-pivot span for qualifying volume candles and selects the qualifying candle with the greatest reported volume. If that search finds none, it also checks the area around the second pivot. Search After Divergence then defines how many new bars after confirmation may supply a qualifying candidate. Volume is measured relative to its moving average:

Relative volume = candle volume / average volume

The default requirement is 1.5 times the 20-bar average. Candle direction is not used. For a bullish setup, the selected candle's high becomes the level. For a bearish setup, its low becomes the level.

Maximum Candidates controls how many qualifying volume levels one divergence may create. You can use up to three qualifying volume-candle candidates for each confirmed divergence. The default is one to keep the chart and signal source unambiguous. With this default, an already selected historical candidate fills the single slot; otherwise, the first qualifying post-confirmation candidate can fill it.

→ 4. Breakout confirmation and signal window

The volume level begins as gray. It changes to the bullish or bearish color only when price closes beyond it on a confirmed candle:

Bullish divergence: confirmed close above the selected volume candle's high.

Bearish divergence: confirmed close below the selected volume candle's low.

Breakout Signal Window defines how many bars that exact volume level is permitted to produce a BUY or SELL signal. The count begins when the level is created. Once the window expires, the level cannot trigger a late signal and cannot add a late observation to the statistics.

→ 5. Expired levels

Keep Expired Levels Visible separates signal validity from visual analysis.

When it is enabled, an unbroken level continues as a gray reference after its signal window expires. The expired line is visual only: it cannot produce a BUY or SELL signal and is not reactivated by a new calendar day, exchange day, or session. It remains visible until a newer qualifying volume level replaces it.

When Keep Expired Levels Visible is disabled, the gray line ends when its breakout signal window expires.

This indicator does not carry or re-arm levels according to a calendar boundary or timezone.

→ OPTIONAL TRADE MAP

The trade map is a visual measurement tool, not an automated order-placement system.

Entry: open of the candle following the confirmed BUY or SELL signal.

Stop: opposite edge of the exact volume candle that produced the signal, plus the selected ATR delta.

1R: one initial-risk unit from Entry.

The map helps compare the signal with the user's own execution, market structure, and risk plan. It is not financial advice and does not account for spread, slippage, commissions, or individual position sizing.

→ STATISTICS DASHBOARD

The dashboard reports historical reach rates for the current symbol, timeframe, loaded chart history, and selected inputs. It is designed for configuration comparison.

Completed: observations that reached the stop, reached 3R, or reached the maximum evaluation window.

Reached >=0.5R: completed observations whose maximum favorable excursion reached at least half of the initial risk.

Win Rate >=1R: completed observations that reached at least 1R before the stop.

Reached >=2R / >=3R: completed observations that reached those excursion levels before the stop.

Average MFE: average maximum favorable excursion, expressed in R, across completed observations.

Active / Invalid: observations still being evaluated and observations rejected because a valid positive risk distance could not be constructed.

Only breakouts confirmed while their volume level is inside its active signal window create statistical observations. An expired gray reference does not create a trade in the dashboard.

If the stop and a target fall inside the same historical candle, the script gives the stop priority because OHLC data cannot reveal the intrabar sequence. This is intentionally conservative.

These figures are descriptive historical measurements, not a backtest equity curve, not a profit factor, and not a forecast of future results. They can change with the data provider, symbol, timeframe, available history, and settings.

→ DEFAULT XAUUSD 7-MINUTE PRESET

CCI Length: 20
CCI Source: Typical Price (HLC3)
First Pivot Extreme Level: +/-150
Maximum Bars Between Pivots: 60
Price Pivot Match Radius: 7
Maximum Price/CCI Span Difference: 35%
Volume Average Length: 20
Minimum Volume x Average: 1.5
Search After Divergence: 15 bars
Maximum Candidates per Divergence: 1
Breakout Signal Window: 40 bars
Keep Expired Levels Visible: On
Show Entry / SL / 1R Markup: On

→ ALERTS

Bullish CCI Divergence: fires when a bullish divergence becomes confirmed.

Bearish CCI Divergence: fires when a bearish divergence becomes confirmed.

CCI Volume Long Signal: fires after a confirmed close above an active bullish volume level.

CCI Volume Short Signal: fires after a confirmed close below an active bearish volume level.

→ ORIGINALITY

This script is not a standard CCI divergence plot and not a generic volume-spike marker. Its purpose is to connect four separate stages in one workflow: multi-strength confirmed CCI divergence, price-pivot alignment, relative-volume candle mapping, and close-confirmed breakout authorization.

Candidate search, signal lifetime, visual reference lifetime, trade measurement, and historical R-reach analysis are kept separate. This makes it possible to change one part of the workflow and see how it affects signal frequency and the historical statistics without confusing an expired visual level with an active signal source.

→ LIMITATIONS

CCI, volume, and divergence are analytical tools, not guarantees of reversal or continuation. Pivot confirmation introduces an intentional delay. Historical volume and results can differ between data providers. Signals should be evaluated with market structure, liquidity, volatility, wave context, and personal risk management. The default preset was developed for how I analyze XAUUSD on 7 minutes; other markets and timeframes require independent testing.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © josseliani
//@version=6
indicator("CCI Divergence Volume Breakout [josseliani]", shorttitle="CCI Volume Breakout", overlay=false, max_bars_back=1500, max_lines_count=500, max_labels_count=500, max_boxes_count=500)
// CCI divergence and relative-volume confirmation tool.
// Automatic CCI pivot scan: 3 / 5 / 7 / 9. A confirmed divergence opens a
// finite search for qualifying volume-candle levels. Candle color is ignored.
// A level activates only after a confirmed CLOSE beyond it. The arrow is drawn
// on that same confirmed candle. Optional trade markup starts from the OPEN of
// the following candle. Its stop is placed behind the opposite edge of the exact
// volume candle whose level produced the signal, plus an optional ATR delta.
// Candidate search, breakout authorization, and visual extension are separate.
// An expired level can remain gray as a visual reference, but it cannot create a
// late signal. No calendar-day carry or automatic re-arming is used. The
// dashboard reports historical reach rates; it is not a strategy tester and
// does not predict future performance.
//=============================================================================
// INPUTS
//=============================================================================
grpCci = "CCI Settings"
cciLength = input.int(20, "CCI Length", minval=1, group=grpCci)
cciSource = input.source(hlc3, "CCI Source", group=grpCci)
extremeLevel = input.float(150.0, "First Pivot Extreme Level (±)", minval=1.0, step=5.0, group=grpCci, tooltip="Only the first CCI pivot must be beyond the extreme level. The second pivot may be anywhere.")
grpDiv = "Divergence Settings"
maxDivergenceBars = input.int(60, "Maximum Bars Between Pivots", minval=5, maxval=300, group=grpDiv)
pricePivotRadius = input.int(7, "Price Pivot Match Radius", minval=1, maxval=15, group=grpDiv, tooltip="Searches within this many bars on each side of a CCI pivot for the matching price high or low.")
spanTolerancePct = input.float(35.0, "Maximum Price/CCI Span Difference (%)", minval=10, maxval=75, step=5, group=grpDiv, tooltip="Ensures that the price and CCI pivots represent approximately the same market swing. Lower values require closer alignment.")
showCciLines = input.bool(true, "Draw Divergence on CCI", group=grpDiv)
showPriceLines = input.bool(true, "Draw Divergence on Price", group=grpDiv)
showPivotMarkers = input.bool(true, "Show CCI Pivot Markers", group=grpDiv)
grpVol = "Volume Map"
volumeAverageLength = input.int(20, "Volume Average Length", minval=1, maxval=200, group=grpVol)
minimumVolumeMultiple = input.float(1.5, "Minimum Volume × Average", minval=0.1, maxval=10.0, step=0.1, group=grpVol)
candidateSearchBars = input.int(15, "Search After Divergence (Bars)", minval=1, maxval=50, group=grpVol, tooltip="How many bars after divergence confirmation may supply a qualifying volume candle. This searches for the candle; it does not control how long its level can trigger.")
maximumCandidates = input.int(1, "Maximum Candidates per Divergence", minval=1, maxval=3, group=grpVol)
maximumSetupBars = input.int(40, "Breakout Signal Window (Bars)", minval=5, maxval=300, group=grpVol, tooltip="How many bars a detected volume level may produce a BUY/SELL signal. The count starts when the level is created. After this window, the level is expired and cannot trigger.")
extendExpiredLevels = input.bool(true, "Keep Expired Levels Visible", group=grpVol, tooltip="When enabled, an unbroken level continues as a gray visual reference after its signal window expires. It remains inactive and stops when a newer qualified volume level replaces it. When disabled, the line ends with the signal window.")
showVolumeBoxes = input.bool(true, "Highlight Volume Candles", group=grpVol)
grpDisplay = "Display"
bullColor = input.color(color.rgb(34, 197, 94), "Bullish Color", group=grpDisplay)
bearColor = input.color(color.rgb(239, 68, 68), "Bearish Color", group=grpDisplay)
cciColor = input.color(color.rgb(64, 196, 255), "CCI Color", group=grpDisplay)
volumeBoxBorderColor = input.color(color.new(color.gray, 25), "Volume Candle Border", group=grpDisplay, tooltip="Color and transparency of the outline around a selected volume candle.")
volumeBoxFillColor = input.color(color.new(color.gray, 90), "Volume Candle Fill", group=grpDisplay, tooltip="Color and transparency of the selected volume candle range. The transparency selected here is used directly.")
volumeTextColor = input.color(color.new(color.silver, 10), "Volume Multiple Text", group=grpDisplay)
inactiveColor = input.color(color.new(color.gray, 45), "Inactive Level", group=grpDisplay)
signalBadgeOffsetAtr = input.float(1.25, "BUY/SELL Badge Offset ×ATR", minval=0.20, maxval=3.00, step=0.05, group=grpDisplay)
signalBadgeTransparency = input.int(72, "BUY/SELL Badge Transparency", minval=0, maxval=100, group=grpDisplay)
grpTrade = "Optional Trade Map & Statistics"
showTradeMarkup = input.bool(true, "Show Entry / SL / 1R Markup", group=grpTrade)
tradeStopDeltaAtr = input.float(0.5, "Volume Candle Stop Delta ×ATR", minval=0.0, maxval=3.0, step=0.05, group=grpTrade, tooltip="BUY: stop below the selected volume candle low. SELL: stop above its high. This ATR delta adds breathing room beyond that candle.")
tradeEvaluationBars = input.int(60, "Maximum Evaluation Window (Bars)", minval=5, maxval=500, group=grpTrade)
tradeProjectionBars = input.int(12, "Trade Markup Length (Bars)", minval=2, maxval=50, group=grpTrade)
statisticsSampleMode = input.string("All Signals", "Statistics Sample", options=["All Signals", "First Signal per Divergence"], group=grpTrade, tooltip="All Signals counts every signal without filtering by stop width. First Signal gives one observation per divergence.")
showStatistics = input.bool(true, "Show Statistics Dashboard", group=grpTrade)
statisticsPosition = input.string("Right", "Dashboard Side", options=["Right", "Left"], group=grpTrade)
//=============================================================================
// SERIES
//=============================================================================
cci = ta.cci(cciSource, cciLength)
volumeAverage = ta.sma(volume, volumeAverageLength)
volumeMultiple = not na(volumeAverage) and volumeAverage > 0 ? volume / volumeAverage : 0.0
volumeSpike = not na(volume) and volumeMultiple >= minimumVolumeMultiple
plot(cci, "CCI", color=cciColor, linewidth=2)
hline(extremeLevel, "Upper Extreme", color=color.new(bearColor, 25), linestyle=hline.style_dashed)
hline(0.0, "Zero", color=color.new(color.gray, 65), linestyle=hline.style_dotted)
hline(-extremeLevel, "Lower Extreme", color=color.new(bullColor, 25), linestyle=hline.style_dashed)
atr = ta.atr(14)
cciLow3 = ta.pivotlow(cci, 3, 3)
cciLow5 = ta.pivotlow(cci, 5, 5)
cciLow7 = ta.pivotlow(cci, 7, 7)
cciLow9 = ta.pivotlow(cci, 9, 9)
cciHigh3 = ta.pivothigh(cci, 3, 3)
cciHigh5 = ta.pivothigh(cci, 5, 5)
cciHigh7 = ta.pivothigh(cci, 7, 7)
cciHigh9 = ta.pivothigh(cci, 9, 9)
//=============================================================================
// PRICE-STRUCTURE HELPERS
//=============================================================================
f_price_pivot_low(int offset, int strength) =>
    bool valid = offset >= strength and offset + strength <= bar_index
    if valid
        float candidate = low[offset]
        for k = 1 to strength
            if low[offset - k] <= candidate or low[offset + k] < candidate
                valid := false
                break
    valid

f_price_pivot_high(int offset, int strength) =>
    bool valid = offset >= strength and offset + strength <= bar_index
    if valid
        float candidate = high[offset]
        for k = 1 to strength
            if high[offset - k] >= candidate or high[offset + k] > candidate
                valid := false
                break
    valid

f_any_price_low(int offset) =>
    f_price_pivot_low(offset, 3) or f_price_pivot_low(offset, 5) or f_price_pivot_low(offset, 7) or f_price_pivot_low(offset, 9)

f_any_price_high(int offset) =>
    f_price_pivot_high(offset, 3) or f_price_pivot_high(offset, 5) or f_price_pivot_high(offset, 7) or f_price_pivot_high(offset, 9)

f_bull_price_structure(int firstCciBar, int secondCciBar) =>
    bool found = false
    int bestFirstBar = na
    float bestFirstPrice = na
    int bestFinalBar = na
    float bestFinalPrice = na
    float bestScore = 1000000.0
    int cciSpan = math.max(secondCciBar - firstCciBar, 1)
    int firstCenter = bar_index - firstCciBar
    int finalCenter = bar_index - secondCciBar
    for d1 = -pricePivotRadius to pricePivotRadius
        int o1 = firstCenter + d1
        if f_any_price_low(o1)
            for d2 = -pricePivotRadius to pricePivotRadius
                int o2 = finalCenter + d2
                if f_any_price_low(o2)
                    int b1 = bar_index - o1
                    int b2 = bar_index - o2
                    int priceSpan = b2 - b1
                    float diff = math.abs(priceSpan - cciSpan) / cciSpan * 100.0
                    bool directionOK = b2 > b1 and low[o2] < low[o1]
                    float score = math.abs(d1) + math.abs(d2) + diff * 0.1
                    if directionOK and diff <= spanTolerancePct and score < bestScore
                        bool internalOK = true
                        if b2 - b1 > 1
                            for b = b1 + 1 to b2 - 1
                                int o = bar_index - b
                                if f_any_price_low(o) and low[o] < low[o2]
                                    internalOK := false
                                    break
                        if internalOK
                            found := true
                            bestScore := score
                            bestFirstBar := b1
                            bestFirstPrice := low[o1]
                            bestFinalBar := b2
                            bestFinalPrice := low[o2]
    [found, bestFirstBar, bestFirstPrice, bestFinalBar, bestFinalPrice]

f_bear_price_structure(int firstCciBar, int secondCciBar) =>
    bool found = false
    int bestFirstBar = na
    float bestFirstPrice = na
    int bestFinalBar = na
    float bestFinalPrice = na
    float bestScore = 1000000.0
    int cciSpan = math.max(secondCciBar - firstCciBar, 1)
    int firstCenter = bar_index - firstCciBar
    int finalCenter = bar_index - secondCciBar
    for d1 = -pricePivotRadius to pricePivotRadius
        int o1 = firstCenter + d1
        if f_any_price_high(o1)
            for d2 = -pricePivotRadius to pricePivotRadius
                int o2 = finalCenter + d2
                if f_any_price_high(o2)
                    int b1 = bar_index - o1
                    int b2 = bar_index - o2
                    int priceSpan = b2 - b1
                    float diff = math.abs(priceSpan - cciSpan) / cciSpan * 100.0
                    bool directionOK = b2 > b1 and high[o2] > high[o1]
                    float score = math.abs(d1) + math.abs(d2) + diff * 0.1
                    if directionOK and diff <= spanTolerancePct and score < bestScore
                        bool internalOK = true
                        if b2 - b1 > 1
                            for b = b1 + 1 to b2 - 1
                                int o = bar_index - b
                                if f_any_price_high(o) and high[o] > high[o2]
                                    internalOK := false
                                    break
                        if internalOK
                            found := true
                            bestScore := score
                            bestFirstBar := b1
                            bestFirstPrice := high[o1]
                            bestFinalBar := b2
                            bestFinalPrice := high[o2]
    [found, bestFirstBar, bestFirstPrice, bestFinalBar, bestFinalPrice]
//=============================================================================
// AUTOMATIC INITIAL VOLUME SEARCH
//=============================================================================
f_find_initial_volume(int firstPivotBar, int secondPivotBar) =>
    bool found = false
    int selectedBar = na
    float selectedHigh = na
    float selectedLow = na
    float selectedMultiple = na
    float selectedAtr = na
    float selectedVolume = na
    for pass = 0 to 1
        int searchStart = pass == 0 ? firstPivotBar : secondPivotBar - 9
        int searchEnd = pass == 0 ? secondPivotBar : secondPivotBar + 9
        if not found
            for offset = 0 to maxDivergenceBars + 18
                int absoluteBar = bar_index - offset
                if absoluteBar >= searchStart and absoluteBar <= searchEnd and not na(volume[offset])
                    float avg = volumeAverage[offset]
                    float multiple = not na(avg) and avg > 0 ? volume[offset] / avg : 0.0
                    if multiple >= minimumVolumeMultiple and (not found or volume[offset] > selectedVolume)
                        found := true
                        selectedBar := absoluteBar
                        selectedHigh := high[offset]
                        selectedLow := low[offset]
                        selectedMultiple := multiple
                        selectedAtr := atr[offset]
                        selectedVolume := volume[offset]
    [found, selectedBar, selectedHigh, selectedLow, selectedMultiple, selectedAtr]

//=============================================================================
// LEVEL STORAGE
//=============================================================================
var array<int> levelDir = array.new<int>()
var array<float> levelPrice = array.new<float>()
var array<float> levelCandleHigh = array.new<float>()
var array<float> levelCandleLow = array.new<float>()
var array<int> levelSourceBar = array.new<int>()
var array<int> levelSignalEnd = array.new<int>()
var array<int> levelSetupId = array.new<int>()
var array<int> levelStatus = array.new<int>() // 0 armed, 1 triggered, 2 signal-expired but displayed, 3 display-ended
var array<line> levelLines = array.new<line>()
var array<box> levelBoxes = array.new<box>()
var array<label> levelLabels = array.new<label>()

f_level_exists(int setupId, int sourceBar) =>
    bool exists = false
    if array.size(levelSetupId) > 0
        for i = 0 to array.size(levelSetupId) - 1
            if array.get(levelSetupId, i) == setupId and array.get(levelSourceBar, i) == sourceBar
                exists := true
                break
    exists

f_add_level(int setupId, int dir, int sourceBar, float candleHigh, float candleLow, float multiple, float candleAtr) =>
    bool added = false
    if not f_level_exists(setupId, sourceBar)
        float safeAtr = math.max(nz(candleAtr, atr), syminfo.mintick * 10)
        float price = dir == 1 ? candleHigh : candleLow
        line ln = line.new(sourceBar, price, bar_index + 1, price, xloc=xloc.bar_index, color=inactiveColor, width=2, force_overlay=true)
        box bx = na
        label lb = na
        if showVolumeBoxes
            bx := box.new(sourceBar, candleHigh, sourceBar + 1, candleLow, xloc=xloc.bar_index, border_color=volumeBoxBorderColor, border_width=2, bgcolor=volumeBoxFillColor, force_overlay=true)
            float y = candleHigh + safeAtr * 0.22
            lb := label.new(sourceBar, y, "×" + str.tostring(multiple, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=volumeTextColor, size=size.small, force_overlay=true)
        array.push(levelDir, dir), array.push(levelPrice, price), array.push(levelSourceBar, sourceBar)
        array.push(levelCandleHigh, candleHigh), array.push(levelCandleLow, candleLow)
        array.push(levelSignalEnd, bar_index + maximumSetupBars)
        array.push(levelSetupId, setupId), array.push(levelStatus, 0)
        array.push(levelLines, ln), array.push(levelBoxes, bx), array.push(levelLabels, lb)
        added := true
        if array.size(levelDir) > 120
            line oldLine = array.shift(levelLines)
            box oldBox = array.shift(levelBoxes)
            label oldLabel = array.shift(levelLabels)
            line.delete(oldLine)
            if not na(oldBox)
                box.delete(oldBox)
            if not na(oldLabel)
                label.delete(oldLabel)
            array.shift(levelDir), array.shift(levelPrice), array.shift(levelSourceBar)
            array.shift(levelCandleHigh), array.shift(levelCandleLow)
            array.shift(levelSignalEnd)
            array.shift(levelSetupId), array.shift(levelStatus)
    added

f_retire_setup(int setupId) =>
    if setupId > 0 and array.size(levelStatus) > 0
        for i = 0 to array.size(levelStatus) - 1
            if array.get(levelSetupId, i) == setupId and array.get(levelStatus, i) == 0
                array.set(levelStatus, i, extendExpiredLevels ? 2 : 3)
                line.set_x2(array.get(levelLines, i), bar_index)

f_stop_replaced_references(int newSetupId) =>
    if array.size(levelStatus) > 0
        for i = 0 to array.size(levelStatus) - 1
            if array.get(levelSetupId, i) != newSetupId and array.get(levelStatus, i) == 2
                array.set(levelStatus, i, 3)
                line.set_x2(array.get(levelLines, i), bar_index)

//=============================================================================
// OPTIONAL TRADE STATISTICS STORAGE
//=============================================================================
var int pendingTradeDir = 0
var int pendingSignalBar = na
var int pendingTradeSetupId = na
var float pendingTradeStop = na
var array<int> statTradeDir = array.new<int>()
var array<int> statTradeEntryBar = array.new<int>()
var array<int> statTradeExpiryBar = array.new<int>()
var array<float> statTradeEntry = array.new<float>()
var array<float> statTradeStop = array.new<float>()
var array<float> statTradeRisk = array.new<float>()
var array<float> statTradeMaxR = array.new<float>()
var array<bool> statTradeHitHalf = array.new<bool>()
var array<bool> statTradeHit1 = array.new<bool>()
var array<bool> statTradeHit2 = array.new<bool>()
var array<bool> statTradeHit3 = array.new<bool>()
var array<line> statMarkupLines = array.new<line>()
var array<label> statMarkupLabels = array.new<label>()
var array<int> statSampledSetupIds = array.new<int>()
var int statCompleted = 0
var int statReachedHalfR = 0
var int statReached1R = 0
var int statReached2R = 0
var int statReached3R = 0
var int statInvalid = 0
var float statTotalMfeR = 0.0

f_stat_pct(int count, int total) => total > 0 ? str.tostring(count * 100.0 / total, "#.0") + "%" : "N/A"

f_setup_already_sampled(int setupId) =>
    bool found = false
    if array.size(statSampledSetupIds) > 0
        for i = 0 to array.size(statSampledSetupIds) - 1
            if array.get(statSampledSetupIds, i) == setupId
                found := true
                break
    found

f_mark_setup_sampled(int setupId) =>
    array.push(statSampledSetupIds, setupId)
    if array.size(statSampledSetupIds) > 500
        array.shift(statSampledSetupIds)

f_stats_position(string selected) => selected == "Left" ? position.top_left : position.top_right

//=============================================================================
// AUTO-PIVOT STATE, DEDUPLICATION AND SETUP STATE
//=============================================================================
var array<bool> bullReady = array.new<bool>(4, false)
var array<int> bullBar = array.new<int>(4, na)
var array<float> bullValue = array.new<float>(4, na)
var array<bool> bearReady = array.new<bool>(4, false)
var array<int> bearBar = array.new<int>(4, na)
var array<float> bearValue = array.new<float>(4, na)
var array<int> seenDir = array.new<int>()
var array<int> seenFirst = array.new<int>()
var array<int> seenLast = array.new<int>()

f_duplicate(int dir, int firstBar, int lastBar) =>
    bool duplicate = false
    if array.size(seenDir) > 0
        for i = 0 to array.size(seenDir) - 1
            if array.get(seenDir, i) == dir and math.abs(array.get(seenFirst, i) - firstBar) <= 5 and math.abs(array.get(seenLast, i) - lastBar) <= 5
                duplicate := true
                break
    duplicate

var int setupSerial = 0
var int activeSetupId = 0
var int activeDirection = 0
var int setupStart = na
var int collectionEnd = na
var int candidateCount = 0
bool bullDivergence = false
bool bearDivergence = false
bool bullEntry = false
bool bearEntry = false
int bullEntrySetupId = na
int bearEntrySetupId = na
int bullEntrySourceBar = na
int bearEntrySourceBar = na
float bullEntryVolumeStop = na
float bearEntryVolumeStop = na

array<float> lows = array.from(cciLow3, cciLow5, cciLow7, cciLow9)
array<float> highs = array.from(cciHigh3, cciHigh5, cciHigh7, cciHigh9)
array<int> strengths = array.from(3, 5, 7, 9)
bool newDiv = false
int newDir = 0
int c1Bar = na
int c2Bar = na
int p1Bar = na
int p2Bar = na
float c1 = na
float c2 = na
float p1 = na
float p2 = na

if barstate.isconfirmed
    // A move into the opposite CCI extreme starts a new momentum cycle.
    // Crossing the middle/zero area is allowed; crossing the opposite extreme is not.
    for s = 0 to 3
        if array.get(bullReady, s) and cci >= extremeLevel
            array.set(bullReady, s, false)
            array.set(bullBar, s, na)
            array.set(bullValue, s, na)
        if array.get(bearReady, s) and cci <= -extremeLevel
            array.set(bearReady, s, false)
            array.set(bearBar, s, na)
            array.set(bearValue, s, na)

    for s = 0 to 3
        int strength = array.get(strengths, s)
        float lp = array.get(lows, s)
        if not na(lp)
            int b2 = bar_index - strength
            if not array.get(bullReady, s)
                if lp <= -extremeLevel
                    array.set(bullReady, s, true), array.set(bullBar, s, b2), array.set(bullValue, s, lp)
            else
                int b1 = array.get(bullBar, s)
                float v1 = array.get(bullValue, s)
                int distance = b2 - b1
                [ok, pb1, pv1, pb2, pv2] = f_bull_price_structure(b1, b2)
                if distance > 0 and distance <= maxDivergenceBars and lp > v1 and ok
                    if not newDiv and not f_duplicate(1, pb1, pb2)
                        newDiv := true, newDir := 1, c1Bar := b1, c2Bar := b2, c1 := v1, c2 := lp, p1Bar := pb1, p2Bar := pb2, p1 := pv1, p2 := pv2
                    array.set(bullReady, s, false)
                else if distance > maxDivergenceBars or (lp <= -extremeLevel and lp <= v1)
                    array.set(bullReady, s, lp <= -extremeLevel), array.set(bullBar, s, lp <= -extremeLevel ? b2 : na), array.set(bullValue, s, lp <= -extremeLevel ? lp : na)

        float hp = array.get(highs, s)
        if not na(hp)
            int b2 = bar_index - strength
            if not array.get(bearReady, s)
                if hp >= extremeLevel
                    array.set(bearReady, s, true), array.set(bearBar, s, b2), array.set(bearValue, s, hp)
            else
                int b1 = array.get(bearBar, s)
                float v1 = array.get(bearValue, s)
                int distance = b2 - b1
                [ok, pb1, pv1, pb2, pv2] = f_bear_price_structure(b1, b2)
                if distance > 0 and distance <= maxDivergenceBars and hp < v1 and ok
                    if not newDiv and not f_duplicate(-1, pb1, pb2)
                        newDiv := true, newDir := -1, c1Bar := b1, c2Bar := b2, c1 := v1, c2 := hp, p1Bar := pb1, p2Bar := pb2, p1 := pv1, p2 := pv2
                    array.set(bearReady, s, false)
                else if distance > maxDivergenceBars or (hp >= extremeLevel and hp >= v1)
                    array.set(bearReady, s, hp >= extremeLevel), array.set(bearBar, s, hp >= extremeLevel ? b2 : na), array.set(bearValue, s, hp >= extremeLevel ? hp : na)

if newDiv
    array.push(seenDir, newDir), array.push(seenFirst, p1Bar), array.push(seenLast, p2Bar)
    if array.size(seenDir) > 100
        array.shift(seenDir), array.shift(seenFirst), array.shift(seenLast)
    f_retire_setup(activeSetupId)
    setupSerial += 1
    activeSetupId := setupSerial
    activeDirection := newDir
    setupStart := bar_index
    collectionEnd := bar_index + candidateSearchBars
    candidateCount := 0
    bullDivergence := newDir == 1
    bearDivergence := newDir == -1
    if showCciLines
        line.new(c1Bar, c1, c2Bar, c2, xloc=xloc.bar_index, color=newDir == 1 ? bullColor : bearColor, style=line.style_dashed, width=2)
    if showPriceLines
        line.new(p1Bar, p1, p2Bar, p2, xloc=xloc.bar_index, color=newDir == 1 ? bullColor : bearColor, style=line.style_dashed, width=2, force_overlay=true)
    if showPivotMarkers
        label.new(c2Bar, c2, newDir == 1 ? "▲" : "▼", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=newDir == 1 ? bullColor : bearColor, size=size.large)
    [found, vb, vh, vl, vm, va] = f_find_initial_volume(c1Bar, c2Bar)
    if found
        if f_add_level(activeSetupId, activeDirection, vb, vh, vl, vm, va)
            candidateCount += 1
            f_stop_replaced_references(activeSetupId)

if barstate.isconfirmed and activeSetupId > 0 and bar_index > setupStart and bar_index <= collectionEnd and candidateCount < maximumCandidates and volumeSpike
    if f_add_level(activeSetupId, activeDirection, bar_index, high, low, volumeMultiple, atr)
        candidateCount += 1
        f_stop_replaced_references(activeSetupId)

if activeSetupId > 0 and bar_index > collectionEnd
    activeDirection := 0

if array.size(levelStatus) > 0
    for i = 0 to array.size(levelStatus) - 1
        int status = array.get(levelStatus, i)
        int dir = array.get(levelDir, i)
        float level = array.get(levelPrice, i)
        float candleHigh = array.get(levelCandleHigh, i)
        float candleLow = array.get(levelCandleLow, i)
        int sourceBar = array.get(levelSourceBar, i)
        int signalEnd = array.get(levelSignalEnd, i)
        int sid = array.get(levelSetupId, i)
        line ln = array.get(levelLines, i)

        // The signal window belongs to this exact volume level. Once expired,
        // the gray line may continue only as a visual reference. It is never
        // re-armed by a date or session change.
        if status == 0 and bar_index > signalEnd
            status := extendExpiredLevels ? 2 : 3
            array.set(levelStatus, i, status)
            line.set_x2(ln, signalEnd)

        bool levelVisible = status == 0 or status == 2
        if levelVisible
            line.set_x2(ln, bar_index + 1)

        bool authorized = status == 0 and bar_index <= signalEnd and bar_index > sourceBar and barstate.isconfirmed
        bool breakBull = authorized and dir == 1 and close > level
        bool breakBear = authorized and dir == -1 and close < level
        if breakBull or breakBear
            array.set(levelStatus, i, 1)
            line.set_x2(ln, bar_index)
            line.set_color(ln, dir == 1 ? bullColor : bearColor)
            if dir == 1
                bullEntry := true
                if na(bullEntrySourceBar) or sourceBar > bullEntrySourceBar
                    bullEntrySetupId := sid
                    bullEntrySourceBar := sourceBar
                    bullEntryVolumeStop := candleLow
            else
                bearEntry := true
                if na(bearEntrySourceBar) or sourceBar > bearEntrySourceBar
                    bearEntrySetupId := sid
                    bearEntrySourceBar := sourceBar
                    bearEntryVolumeStop := candleHigh

// Several levels may break on one candle, but only one combined signal badge is drawn.
if bullEntry
    label.new(bar_index, low - atr * signalBadgeOffsetAtr, "▲ BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullColor, signalBadgeTransparency), textcolor=color.new(color.white, 5), size=size.small, force_overlay=true)
if bearEntry
    label.new(bar_index, high + atr * signalBadgeOffsetAtr, "SELL ▼", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearColor, signalBadgeTransparency), textcolor=color.new(color.white, 5), size=size.small, force_overlay=true)

// Open the sampled signal at the OPEN of the following candle. Risk is the
// distance from that entry to the volume-candle stop including its ATR delta.
if pendingTradeDir != 0 and not na(pendingSignalBar) and bar_index > pendingSignalBar
    float tradeEntry = open
    float tradeStop = pendingTradeStop
    float tradeRisk = pendingTradeDir == 1 ? tradeEntry - tradeStop : tradeStop - tradeEntry
    bool validRisk = tradeRisk > syminfo.mintick
    if validRisk
        array.push(statTradeDir, pendingTradeDir)
        array.push(statTradeEntryBar, bar_index)
        array.push(statTradeExpiryBar, bar_index + tradeEvaluationBars)
        array.push(statTradeEntry, tradeEntry)
        array.push(statTradeStop, tradeStop)
        array.push(statTradeRisk, tradeRisk)
        array.push(statTradeMaxR, 0.0)
        array.push(statTradeHitHalf, false)
        array.push(statTradeHit1, false)
        array.push(statTradeHit2, false)
        array.push(statTradeHit3, false)
        if showTradeMarkup
            float tradeTarget1 = pendingTradeDir == 1 ? tradeEntry + tradeRisk : tradeEntry - tradeRisk
            int tradeX2 = bar_index + tradeProjectionBars
            line entryLine = line.new(bar_index, tradeEntry, tradeX2, tradeEntry, xloc=xloc.bar_index, color=color.new(color.gray, 30), style=line.style_dotted, width=1, force_overlay=true)
            line stopLine = line.new(bar_index, tradeStop, tradeX2, tradeStop, xloc=xloc.bar_index, color=color.new(bearColor, 15), width=1, force_overlay=true)
            line targetLine = line.new(bar_index, tradeTarget1, tradeX2, tradeTarget1, xloc=xloc.bar_index, color=color.new(bullColor, 15), width=1, force_overlay=true)
            label entryLabel = label.new(tradeX2, tradeEntry, "Entry", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.new(color.gray, 15), size=size.tiny, force_overlay=true)
            label stopLabel = label.new(tradeX2, tradeStop, "SL · volume", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bearColor, size=size.tiny, force_overlay=true)
            label targetLabel = label.new(tradeX2, tradeTarget1, "1R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bullColor, size=size.tiny, force_overlay=true)
            array.push(statMarkupLines, entryLine), array.push(statMarkupLines, stopLine), array.push(statMarkupLines, targetLine)
            array.push(statMarkupLabels, entryLabel), array.push(statMarkupLabels, stopLabel), array.push(statMarkupLabels, targetLabel)
            while array.size(statMarkupLines) > 150
                line.delete(array.shift(statMarkupLines))
            while array.size(statMarkupLabels) > 150
                label.delete(array.shift(statMarkupLabels))
    else
        statInvalid += 1
    pendingTradeDir := 0
    pendingSignalBar := na
    pendingTradeSetupId := na
    pendingTradeStop := na

// Track cumulative 0.5R / 1R / 2R / 3R reach rates. If SL and a target are
// both inside the same historical candle, SL has priority because order is unknown.
if array.size(statTradeDir) > 0
    for i = array.size(statTradeDir) - 1 to 0
        int tradeDir = array.get(statTradeDir, i)
        int tradeExpiry = array.get(statTradeExpiryBar, i)
        float tradeEntry = array.get(statTradeEntry, i)
        float tradeStop = array.get(statTradeStop, i)
        float tradeRisk = array.get(statTradeRisk, i)
        float tradeMaxR = array.get(statTradeMaxR, i)
        bool tradeHitHalf = array.get(statTradeHitHalf, i)
        bool tradeHit1 = array.get(statTradeHit1, i)
        bool tradeHit2 = array.get(statTradeHit2, i)
        bool tradeHit3 = array.get(statTradeHit3, i)
        float currentR = tradeDir == 1 ? (high - tradeEntry) / tradeRisk : (tradeEntry - low) / tradeRisk
        tradeMaxR := math.max(tradeMaxR, currentR)
        bool stopHit = tradeDir == 1 ? low <= tradeStop : high >= tradeStop
        if not stopHit
            tradeHitHalf := tradeHitHalf or tradeMaxR >= 0.5
            tradeHit1 := tradeHit1 or tradeMaxR >= 1.0
            tradeHit2 := tradeHit2 or tradeMaxR >= 2.0
            tradeHit3 := tradeHit3 or tradeMaxR >= 3.0
        array.set(statTradeMaxR, i, tradeMaxR)
        array.set(statTradeHitHalf, i, tradeHitHalf)
        array.set(statTradeHit1, i, tradeHit1)
        array.set(statTradeHit2, i, tradeHit2)
        array.set(statTradeHit3, i, tradeHit3)
        bool evaluationExpired = bar_index >= tradeExpiry and barstate.isconfirmed
        bool tradeFinished = stopHit or tradeHit3 or evaluationExpired
        if tradeFinished
            statCompleted += 1
            statReachedHalfR += tradeHitHalf ? 1 : 0
            statReached1R += tradeHit1 ? 1 : 0
            statReached2R += tradeHit2 ? 1 : 0
            statReached3R += tradeHit3 ? 1 : 0
            statTotalMfeR += math.max(tradeMaxR, 0.0)
            array.remove(statTradeDir, i)
            array.remove(statTradeEntryBar, i)
            array.remove(statTradeExpiryBar, i)
            array.remove(statTradeEntry, i)
            array.remove(statTradeStop, i)
            array.remove(statTradeRisk, i)
            array.remove(statTradeMaxR, i)
            array.remove(statTradeHitHalf, i)
            array.remove(statTradeHit1, i)
            array.remove(statTradeHit2, i)
            array.remove(statTradeHit3, i)

// The stop belongs to the exact latest volume candle whose level broke.
if bullEntry
    bool sampleAllowed = statisticsSampleMode == "All Signals" or not f_setup_already_sampled(bullEntrySetupId)
    if sampleAllowed
        if statisticsSampleMode == "First Signal per Divergence"
            f_mark_setup_sampled(bullEntrySetupId)
        if not na(bullEntryVolumeStop)
            pendingTradeDir := 1
            pendingSignalBar := bar_index
            pendingTradeSetupId := bullEntrySetupId
            pendingTradeStop := bullEntryVolumeStop - atr * tradeStopDeltaAtr
        else
            statInvalid += 1
if bearEntry
    bool sampleAllowed = statisticsSampleMode == "All Signals" or not f_setup_already_sampled(bearEntrySetupId)
    if sampleAllowed
        if statisticsSampleMode == "First Signal per Divergence"
            f_mark_setup_sampled(bearEntrySetupId)
        if not na(bearEntryVolumeStop)
            pendingTradeDir := -1
            pendingSignalBar := bar_index
            pendingTradeSetupId := bearEntrySetupId
            pendingTradeStop := bearEntryVolumeStop + atr * tradeStopDeltaAtr
        else
            statInvalid += 1

var table statsDashboard = table.new(f_stats_position(statisticsPosition), 2, 9, border_width=1, border_color=color.new(color.gray, 65), frame_width=1, frame_color=color.new(color.gray, 65))
if barstate.islast
    if showStatistics
        float averageMfe = statCompleted > 0 ? statTotalMfeR / statCompleted : na
        string sampleShort = statisticsSampleMode == "First Signal per Divergence" ? "FIRST / DIV" : "ALL SIGNALS"
        table.cell(statsDashboard, 0, 0, "CCI VOLUME STATS", text_color=color.white, bgcolor=color.new(cciColor, 65), text_size=size.small)
        table.cell(statsDashboard, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color=color.white, bgcolor=color.new(cciColor, 65), text_size=size.small)
        table.cell(statsDashboard, 0, 1, "Completed", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 1, str.tostring(statCompleted), text_color=color.white, text_size=size.small)
        table.cell(statsDashboard, 0, 2, "Reached ≥0.5R", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 2, f_stat_pct(statReachedHalfR, statCompleted) + " (" + str.tostring(statReachedHalfR) + ")", text_color=bullColor, text_size=size.small)
        table.cell(statsDashboard, 0, 3, "Win Rate ≥1R", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 3, f_stat_pct(statReached1R, statCompleted) + " (" + str.tostring(statReached1R) + ")", text_color=bullColor, text_size=size.small)
        table.cell(statsDashboard, 0, 4, "Reached ≥2R", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 4, f_stat_pct(statReached2R, statCompleted) + " (" + str.tostring(statReached2R) + ")", text_color=bullColor, text_size=size.small)
        table.cell(statsDashboard, 0, 5, "Reached ≥3R", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 5, f_stat_pct(statReached3R, statCompleted) + " (" + str.tostring(statReached3R) + ")", text_color=bullColor, text_size=size.small)
        table.cell(statsDashboard, 0, 6, "Average MFE", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 6, statCompleted > 0 ? str.tostring(averageMfe, "#.##") + "R" : "N/A", text_color=color.white, text_size=size.small)
        table.cell(statsDashboard, 0, 7, "Active / Invalid", text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(statsDashboard, 1, 7, str.tostring(array.size(statTradeDir)) + " / " + str.tostring(statInvalid), text_color=color.white, text_size=size.small)
        table.cell(statsDashboard, 0, 8, sampleShort, text_color=color.new(color.white, 20), text_size=size.tiny)
        table.cell(statsDashboard, 1, 8, "Volume SL · Δ " + str.tostring(tradeStopDeltaAtr, "#.##") + " ATR", text_color=color.new(color.white, 20), text_size=size.tiny)
    else
        table.clear(statsDashboard, 0, 0, 1, 8)

alertcondition(bullDivergence, "Bullish CCI Divergence", "Bullish CCI divergence confirmed on {{ticker}} {{interval}}")
alertcondition(bearDivergence, "Bearish CCI Divergence", "Bearish CCI divergence confirmed on {{ticker}} {{interval}}")
alertcondition(bullEntry, "CCI Volume Long Signal", "A candle closed above a bullish CCI volume level on {{ticker}} {{interval}}")
alertcondition(bearEntry, "CCI Volume Short Signal", "A candle closed below a bearish CCI volume level on {{ticker}} {{interval}}")
plot(activeDirection, "Active Divergence Direction", display=display.data_window)
plot(candidateCount, "Active Volume Candidates", display=display.data_window)
````
