# VWAP + Volume Profile Confluence

- url: https://www.tradingview.com/script/lTQE4w2W-VWAP-Volume-Profile-Confluence/
- type: indicator
- pine_id: PUB;7e550bac5b954c8e91bf4f90ca8da699
- version: 1.0

## Description

VWAP + Volume Profile Confluence — trade the zones where anchored VWAP bands and Volume Profile levels intersect.

What It Does
This indicator overlays three analytical layers and highlights the moments they align:

Layer	What You See
Anchored VWAP with ±Nσ bands	The session's fair-value centreline plus dynamic volatility bands. VWAP is colour-coded by slope — teal rising, grey flat, red falling — so you know the session's directional bias at a glance.
Volume Profile (POC + Value Area)	The session's most-traded price (POC) and the 70% Value Area High/Low. These represent zones where the market has done real business — not arbitrary lines.
Confluence signals	Background fill fires when VWAP bands align with VP levels. Green = support confluence. Red = resistance confluence. Three signal types are detected, ordered by conviction:
Signal Hierarchy
Signal	What It Means	Conviction
Reversal	A VWAP band (±Nσ) touches a VP level (POC or VA boundary). Price at the edge of fair value AND at a volume node = high-probability reaction zone.	⬛ Highest
Pullback	Price pulls back near VWAP while trend is sustained (price above VWAP for 10+ bars). Classic "buy the dip / sell the rip" setup.	◧ Medium
Continuation	Price rides above/below VWAP directionally without touching a band. Momentum in flow — trend-follow context.	◻ Lower
Why It Works
VWAP bands are dynamic S/R — price reverts to VWAP ~70% of any session, and ±2σ marks the edge of "fair" auction. Rejection at a band signals exhaustion.
Volume Profile levels are institutional footprints — the POC is where the largest volume pool sits; it's the session's "fair price" and often acts as a magnet or pivot.
When they align, you have two independent frameworks agreeing on a level — that's higher-probability than either alone.
Usage
Timeframe: Best on intraday charts (15m–1H) with Daily anchor. Use Weekly anchor for a multi-day smoothed VWAP.
Entries: Enter on price confirmation at a confluence zone (bullish signal + bullish price action = long; bearish signal + bearish PA = short).
Stops: Opposite side of the confluence zone or the session's prior swing.
Targets: Next VWAP band, VP level, or prior session high/low.
Std Dev Multiplier: 2.0 is standard. Widen to 2.5 for volatile instruments; narrow to 1.5 for slow/stable ones.
Slope Sensitivity: Default 10% works across instruments. Lower = more colour changes.
Inputs
All settings are exposed with tooltip explanations. Key ones:

Anchor Period — Daily or Weekly VWAP/VP reset
Std Dev Multiplier — Band width (default 2.0)
Confluence Threshold % — How tight VWAP→VP alignment must be to signal (lower = stricter)
Slope Lookback / Sensitivity — Controls VWAP colour-coding responsiveness
Notes
VP levels (POC, VA High/Low) are plotted as steplines — they don't drift through historical bars. Each level is anchored to its session.
Works on any instrument: stocks, indices, forex, crypto. Slope normalisation self-adjusts across volatility regimes.
All components (VWAP, bands, POC, VA, confluence fill) can be toggled independently in settings.

## Source Code

````pine
// VWAP + Volume Profile Confluence
// ----------------------------------------------------------------------------
// Anchored VWAP with standard deviation bands, Volume Profile POC and Value
// Area levels, and smart confluence detection between VWAP bands and VP levels.
//
// Author: TradingView user
//
// Key Features:
//   - Anchored VWAP (Daily or Weekly anchor) with ±Nσ standard deviation bands
//   - Volume Profile: Point of Control (POC) and 70% Value Area High/Low
//   - Three signal types: Reversal, Pullback, and Continuation
//   - Slope-aware VWAP colour coding — green rising, grey flat, red falling
//   - Self-normalising slope detection adapts across instruments and timeframes
//
// How to Use:
//   - Use on Daily or Weekly anchor with intraday charts (15min–1H)
//   - Bullish signals (green bg) near VWAP/bands + VP confluence = potential support
//   - Bearish signals (red bg) near VWAP/bands + VP confluence = potential resistance
//   - Combine with price action confirmation for entries
//   - Adjust Std Dev Multiplier to widen/narrow bands for your instrument's volatility
// ----------------------------------------------------------------------------

//@version=6
//@description Anchored VWAP + Standard Deviation bands + Volume Profile (POC / Value Area) confluence detector. Computes an anchored VWAP (Daily or Weekly) with ±Nσ volatility bands and a rolling Volume Profile that tracks the Point of Control (POC) and 70% Value Area (VA High / VA Low). Confluence zones are highlighted when VWAP band levels align with VP levels. Three signal types detected: Reversal (band touches VP level — highest conviction), Pullback (price near VWAP in a sustained trend — medium conviction), and Continuation (price rides VWAP directionally — lower conviction). VWAP is colour-coded by slope: green rising, grey flat, red falling. Slope is normalised by band width so it adapts across instruments and timeframes. Best with Daily or Weekly anchor on intraday charts (15min–1H).
indicator("VWAP + Volume Profile Confluence", shorttitle="VWAP VP Confluence", overlay=true, precision=2)

// ─── Inputs ──────────────────────────────────────────────────────
anchorInput = input.string("Daily", "Anchor Period", options=["Daily", "Weekly"],
                 tooltip="VWAP and Volume Profile recalculate at the start of each new Daily or Weekly session. 'Daily' is best for intraday work; 'Weekly' smooths the VWAP further.")
sdMult      = input.float(2.0, "Std Dev Multiplier", minval=0.5, step=0.1,
                 tooltip="Number of standard deviations above/below VWAP to draw the upper and lower bands. Higher values widen the bands. 1.5–2.5 is typical depending on instrument volatility.")
confPct     = input.float(0.5, "Confluence Threshold %", minval=0.1, step=0.1,
                 tooltip="Tolerance as a % of the session's price range when checking whether a VWAP band level aligns with a VP level (POC, VA High, VA Low). Lower = tighter alignment required.") * 0.01
slopeLookback = input.int(5, "Slope Lookback (bars)", minval=1, maxval=20,
                 tooltip="Number of bars back to compare VWAP for slope direction colour.")
slopeSensitivity = input.float(10.0, "Slope Sensitivity %", minval=1.0, maxval=50.0, step=1.0,
                 tooltip="How much VWAP must move relative to the ±2σ band width to be classed as rising/falling. Lower = more sensitive. 10% is a good starting point.")

showVwap  = input.bool(true, "Show VWAP",
                 tooltip="Toggle the anchored VWAP line on/off.")
showBands = input.bool(true, "Show Std Dev Bands",
                 tooltip="Toggle the ±Nσ standard deviation bands on/off. These represent VWAP-based volatility ranges.")
showPOC   = input.bool(true, "Show POC Line",
                 tooltip="Toggle the Volume Profile Point of Control (most-traded price level) on/off. Plotted as a stepline for clean visual anchoring.")
showVA    = input.bool(true, "Show Value Area",
                 tooltip="Toggle the 70% Value Area High/Low lines (zones containing 70% of session volume) on/off. Plotted as steplines.")
showConf  = input.bool(true, "Show Confluence Background",
                 tooltip="Toggle the green/red background fill on/off. Green = bullish confluence signal (support zone); Red = bearish confluence signal (resistance zone).")

colRising  = input.color(color.new(#26A69A, 0),  "VWAP Rising",  inline="vwap_col",
                 tooltip="VWAP line colour when slope is rising (bullish bias).")
colFlat    = input.color(color.new(#9E9E9E, 0),  "VWAP Flat",    inline="vwap_col",
                 tooltip="VWAP line colour when slope is flat (neutral / ranging bias).")
colFalling = input.color(color.new(#EF5350, 0),  "VWAP Falling", inline="vwap_col",
                 tooltip="VWAP line colour when slope is falling (bearish bias).")

// ─── Session detection ───────────────────────────────────────────
isNewPeriod = switch anchorInput
    "Daily"  => timeframe.change("D")
    "Weekly" => timeframe.change("W")

// Track which bars belong to the current session
// so VP levels are suppressed on historical sessions.
var int sessionBarCount = 0
if isNewPeriod
    sessionBarCount := 0
sessionBarCount += 1
bool inCurrentSession = sessionBarCount >= 1   // always true once inside a session;
                                                // the key is we reset on new period

// ─── Anchored VWAP ───────────────────────────────────────────────
var float cumVP  = 0.0
var float cumVol = 0.0
var float cumVar = 0.0

if isNewPeriod
    cumVP  := 0.0
    cumVol := 0.0
    cumVar := 0.0

float typPrice = hlc3
float vol      = volume

cumVP  += typPrice * vol
cumVol += vol

float vwap = cumVol > 0 ? cumVP / cumVol : na

// Update variance AFTER vwap is computed this bar
if not na(vwap)
    cumVar += vol * math.pow(typPrice - vwap, 2)

float vwapSd    = cumVol > 0 and cumVar >= 0 ? math.sqrt(cumVar / cumVol) : na
float upperBand = not na(vwap) and not na(vwapSd) ? vwap + sdMult * vwapSd : na
float lowerBand = not na(vwap) and not na(vwapSd) ? vwap - sdMult * vwapSd : na

// ─── VWAP slope colour ───────────────────────────────────────────
// Slope is measured as VWAP movement over the lookback, normalised by
// the current band width (2σ range). This self-adjusts across instruments
// and timeframes — a meaningful slope on a slow forex pair and a fast index
// both register correctly without needing to tune the threshold per instrument.
float vwapMove    = not na(vwap) and not na(vwap[slopeLookback]) ? vwap - vwap[slopeLookback] : 0.0
float bandWidth   = not na(upperBand) and not na(lowerBand) ? upperBand - lowerBand : na
float slopeNorm   = not na(bandWidth) and bandWidth > 0 ? vwapMove / bandWidth * 100 : 0.0
float flatThresh  = slopeSensitivity   // % of band width required to register as directional

color vwapColor = slopeNorm > flatThresh ? colRising : slopeNorm < -flatThresh ? colFalling : colFlat

// ─── Volume Profile ──────────────────────────────────────────────
var int     nBuckets      = 50
var float   periodHigh    = na
var float   periodLow     = na
var float[] bucketVolumes = array.new_float(nBuckets, 0.0)
var float   totalVPVol    = 0.0

if isNewPeriod
    // Snapshot opening bar range as the initial bucket grid
    periodHigh := high
    periodLow  := low
    array.fill(bucketVolumes, 0.0, 0, nBuckets)
    totalVPVol := 0.0
else
    // Expand range as session develops
    periodHigh := na(periodHigh) ? high : math.max(periodHigh, high)
    periodLow  := na(periodLow)  ? low  : math.min(periodLow,  low)

float pocPrice = na
float vaHigh   = na
float vaLow    = na

if not na(periodHigh) and not na(periodLow) and periodHigh > periodLow
    // Accumulate volume into the closest price bucket
    float priceRange = periodHigh - periodLow
    int   bidx     = int(math.floor((typPrice - periodLow) / priceRange * nBuckets))
    bidx := math.min(math.max(bidx, 0), nBuckets - 1)
    array.set(bucketVolumes, bidx, array.get(bucketVolumes, bidx) + vol)
    totalVPVol += vol

    if totalVPVol > 0
        // POC ─ bucket with highest volume
        float maxVol = 0.0
        int   pocIdx = 0
        for i = 0 to nBuckets - 1
            float bv = array.get(bucketVolumes, i)
            if bv > maxVol
                maxVol := bv
                pocIdx  := i

        pocPrice := periodLow + priceRange * (pocIdx + 0.5) / nBuckets

        // Value Area ─ expand from POC until 70% of volume covered
        float targetVol = totalVPVol * 0.70
        int   hiIdx     = pocIdx
        int   loIdx     = pocIdx
        float accumVol  = maxVol

        while accumVol < targetVol
            float addUp = hiIdx < nBuckets - 1 ? array.get(bucketVolumes, hiIdx + 1) : 0.0
            float addDn = loIdx > 0             ? array.get(bucketVolumes, loIdx - 1) : 0.0
            if addUp >= addDn and hiIdx < nBuckets - 1
                hiIdx     += 1
                accumVol  += addUp
            else if loIdx > 0
                loIdx     -= 1
                accumVol  += addDn
            else
                break

        vaHigh := periodLow + priceRange * (hiIdx + 0.5) / nBuckets
        vaLow  := periodLow + priceRange * (loIdx + 0.5) / nBuckets

// ─── Confluence detection ────────────────────────────────────────
// Uses % of price for tolerance (scales across instruments).
// A confluence fires when price is near a VP level AND near a VWAP level simultaneously.

float bandRange = not na(upperBand) and not na(lowerBand) ? upperBand - lowerBand : na
float confThresh = not na(pocPrice) and not na(periodHigh)
                   ? (periodHigh - periodLow) * confPct
                   : na

bool atUpperBand = not na(upperBand) and close >= upperBand * (1 - confPct)
bool atLowerBand = not na(lowerBand) and close <= lowerBand * (1 + confPct)

bool upperOnVP = not na(confThresh) and not na(upperBand) and
                 (math.abs(upperBand - pocPrice) < confThresh or
                  (not na(vaHigh) and math.abs(upperBand - vaHigh) < confThresh))

bool lowerOnVP = not na(confThresh) and not na(lowerBand) and
                 (math.abs(lowerBand - pocPrice) < confThresh or
                  (not na(vaLow)  and math.abs(lowerBand - vaLow)  < confThresh))

// Slope-aware bias
bool vwapRising  = slopeNorm >  flatThresh
bool vwapFalling = slopeNorm < -flatThresh

bool priceAboveVwap = not na(vwap) and close > vwap
bool priceBelowVwap = not na(vwap) and close < vwap
bool priceNearVwap  = not na(bandRange) and math.abs(close - vwap) < bandRange * 0.15

bool trendSustained = (priceAboveVwap and close[5] > vwap[5] and close[10] > vwap[10]) or
                      (priceBelowVwap and close[5] < vwap[5] and close[10] < vwap[10])

// Signal priority: reversal (VP + band) > pullback (near VWAP, trend intact) > continuation
bool bullReversal    = showConf and atLowerBand and lowerOnVP
bool bearReversal    = showConf and atUpperBand and upperOnVP
bool bullPullback    = showConf and vwapRising  and priceNearVwap  and trendSustained and not bullReversal
bool bearPullback    = showConf and vwapFalling and priceNearVwap  and trendSustained and not bearReversal
bool bullContinuation = showConf and vwapRising  and priceAboveVwap and not atUpperBand and not bullReversal and not bullPullback
bool bearContinuation = showConf and vwapFalling and priceBelowVwap and not atLowerBand and not bearReversal and not bearPullback

bool bullSignal = bullReversal or bullPullback or bullContinuation
bool bearSignal = bearReversal or bearPullback or bearContinuation

int bullOpacity = bullReversal ? 80 : bullPullback ? 85 : 90
int bearOpacity = bearReversal ? 80 : bearPullback ? 85 : 90

color bullBg = color.new(color.green, bullOpacity)
color bearBg = color.new(color.red,   bearOpacity)

// ─── Plotting ────────────────────────────────────────────────────

// VWAP — colour changes on slope
plot(showVwap ? vwap : na, "VWAP (Anchored)", vwapColor, 2)

// Bands
plot(showBands ? upperBand : na, "+Nσ Upper Band", color.new(color.blue, 50), 1, plot.style_line)
plot(showBands ? lowerBand : na, "−Nσ Lower Band", color.new(color.blue, 50), 1, plot.style_line)

// ── VP levels: plot.style_stepline keeps them anchored to their
//    computed price — they will NOT drift on the Y axis or trail
//    through historical sessions. na-guarding ensures they only
//    paint once a valid profile exists for the current session.
plot(showPOC and not na(pocPrice) ? pocPrice : na,
     "POC (Point of Control)", color.purple, 1, plot.style_stepline)

plot(showVA and not na(vaHigh) ? vaHigh : na,
     "VA High (Value Area)", color.orange, 1, plot.style_stepline)

plot(showVA and not na(vaLow) ? vaLow : na,
     "VA Low (Value Area)", color.orange, 1, plot.style_stepline)

// ── Confluence background fill
// Hidden anchor plots used purely to drive the fill — display.none
//    keeps them out of the legend and scale.
p_upper = plot(upperBand, display=display.none)
p_lower = plot(lowerBand, display=display.none)

fill(p_upper, p_lower,
     bullSignal ? bullBg : bearSignal ? bearBg : na,
     title="Confluence fill")
````
