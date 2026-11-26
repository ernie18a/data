# Fractal Support & Resistance Zones invincible]

- url: https://www.tradingview.com/script/LehuoKgv-Fractal-Support-Resistance-Zones-invincible/
- type: indicator
- pine_id: PUB;745559a3a70147a6a18c952828a94b00
- version: 1.0

## Description

[b]Fractal Support & Resistance Zones [invincible3][/b]

Fractal Support & Resistance Zones [invincible3] is an advanced market-structure and price-reaction framework designed to identify, evaluate, and dynamically manage support and resistance zones derived from confirmed fractal pivots.

Unlike traditional support and resistance indicators that simply draw horizontal levels at swing highs and lows, this indicator treats every zone as a dynamic market structure object. Each zone develops through its own lifecycle based on price interaction, independent retests, reaction strength, penetration, estimated buying and selling activity, structural confirmation, trend alignment, and eventual support/resistance role reversal.

The objective is not simply to show where price previously turned.

The objective is to evaluate which zones are still technically relevant, which have gained confirmation, which are weakening, and which may provide better structural trade locations.

---------------------------------------------------------------------------------------------

[b]Fractal-Based Zone Detection[/b]

The indicator identifies two independent classes of fractal pivots:

[b]Weak Fractals[/b]

Shorter-length pivots designed to capture local price reactions and minor structural turning points.

[b]Major Fractals[/b]

Higher-strength pivots based on a larger fractal window. These represent more significant swing highs and swing lows and receive greater importance within the zone-quality model.

Fractal support zones are created from confirmed pivot lows, while fractal resistance zones are generated from confirmed pivot highs.

The detection timeframe can be independently selected, allowing zones from a higher timeframe to be displayed on a lower-timeframe chart.

Higher-timeframe fractal data is requested with lookahead disabled to prevent future data from being intentionally introduced into the pivot calculation.

---------------------------------------------------------------------------------------------

[b]Dynamic Support and Resistance Zones[/b]

The indicator creates price zones rather than single horizontal lines.

Markets rarely react from one exact price. Orders, liquidity, and previous positioning are often distributed across a price range. The zone model therefore attempts to represent the broader reaction area surrounding a fractal pivot.

Three zone-width methods are available:

[b]ATR[/b]

Zone width is calculated from Average True Range and automatically adapts to market volatility.

[b]Pivot Candle[/b]

The structure of the original fractal candle is used to determine the zone width.

[b]Hybrid Candle + ATR[/b]

Combines pivot-candle structure with an ATR-based volatility limit.

The hybrid method is designed to prevent unusually large pivot candles from creating excessively wide support or resistance areas.

A minimum tick-based width can also be configured for instruments with very small price movements.

---------------------------------------------------------------------------------------------

[b] Fractal Zone Clustering[/b]

Markets frequently produce several nearby fractal pivots around the same price area.

Drawing every pivot independently can create overlapping boxes and unnecessary chart congestion.

The indicator therefore includes a fractal clustering engine.

Nearby same-side fractals may be merged into a common structural zone when:

* They are within the configured ATR merge distance.
* The resulting merged zone does not exceed the maximum permitted ATR width.
* The maximum cluster count has not been exceeded.
* Fresh major zones are not being merged into previously tested or damaged zones when protection is enabled.

The cluster count becomes one component of the zone-quality model.

A cluster does not automatically mean a zone is strong. It simply indicates that multiple independent fractal structures developed around a similar price area.

---------------------------------------------------------------------------------------------
[b] Independent Retest Detection[/b]

A major feature of the indicator is the distinction between bars inside a zone and independent zone retests.

If price remains inside a support or resistance area for several candles, those candles are not counted as multiple tests.

A new test is counted only after price:

1. Interacts with the zone.
2. Moves sufficiently away from the zone.
3. Travels the configured ATR reset distance.
4. Returns to the zone again.

This creates a more realistic retest model and avoids artificially increasing the test count during sideways congestion.

The label displays the number of independent tests recorded for each selected zone.

---------------------------------------------------------------------------------------------

[b] ATR-Based Reaction Measurement[/b]

After an independent zone retest, the indicator measures how strongly price reacts away from the zone.

Reaction strength is normalized using ATR.

For a support zone, the engine measures upward movement from the reaction anchor.

For a resistance zone, the engine measures downward movement from the reaction anchor.

The strongest reaction generated by the zone is stored as its **Best Reaction ATR**.

Two configurable reaction thresholds are used:

[b]Verified Reaction[/b]

The zone has produced the minimum ATR reaction required for technical validation.

[b]Proven Reaction[/b]

The zone has generated a stronger ATR reaction and has also accumulated sufficient independent testing.

This prevents a zone from receiving a high structural status simply because price briefly touched it.

The market must demonstrate an actual directional response.

---------------------------------------------------------------------------------------------

[b] Dynamic Zone Status System[/b]

Every zone is continuously classified according to its current structural condition.

[b]FRESH[/b]

A newly created major zone that has not yet received an independent retest.

Fresh zones may represent relatively untouched structural areas.

[b]WEAK[/b]

A zone originating from the shorter weak-fractal detection model.

Weak zones can still produce valid reactions but receive a lower fractal-grade contribution in the quality model.

[b]VERIFIED[/b]

A zone that has been tested and remains structurally active.

Reaction behaviour and zone validation contribute dynamically to its score.

[b]PROVEN[/b]

A zone that has accumulated multiple independent tests and generated a reaction exceeding the configured Proven Reaction ATR threshold.

Proven zones represent areas with demonstrated historical reaction behaviour.

[b]DAMAGED[/b]

Price has penetrated a configurable percentage of the zone.

A damaged zone has not necessarily broken, but deeper penetration reduces its quality score.

[b]BROKEN[/b]

Price has invalidated the zone according to the selected break-confirmation method.

Break confirmation can use either:

* Close Beyond Zone
* Full Candle Beyond Zone

Broken zones may optionally remain visible for historical analysis.

[b]FLIPPED SUPPORT / FLIPPED RESISTANCE[/b]

A previously broken zone has confirmed a structural role reversal.

Previous support may become resistance.

Previous resistance may become support.

The indicator does not immediately flip a zone when price crosses it. A separate role-reversal confirmation process is required.

---------------------------------------------------------------------------------------------

[b]Zone Damage and Penetration Tracking[/b]

Zone quality is not binary.

A support or resistance area may gradually weaken before it completely breaks.

The indicator continuously measures the maximum percentage of zone penetration.

For support, penetration is measured downward through the support area.

For resistance, penetration is measured upward through the resistance area.

When penetration exceeds the configured damage threshold, the zone is classified as **[b]DAMAGED[/b]

Damage also applies a progressive penalty to the quality score.

This means a deeply penetrated zone may remain technically valid while receiving a lower structural ranking.

---------------------------------------------------------------------------------------------

[b]Support and Resistance Role Reversal[/b]

The indicator contains a dedicated zone-flip engine.

After a support or resistance zone breaks, the engine monitors whether price moves sufficiently beyond the former zone.

The broken zone must first establish separation from price using a configurable ATR distance.

Price must then return to the previous structural area.

Depending on the selected confirmation mode, the indicator can require:

[b]Zone Reclaim Only[/b]

The opposite-side retest itself is sufficient.

[b]Close Away[/b]

Price must close a configurable ATR distance away from the zone.

[b]Rejection or Engulfing[/b]

The retest can be confirmed through rejection behaviour, an engulfing candle, or a sufficiently strong close away from the zone.

Once confirmed:

* Broken support can become resistance.
* Broken resistance can become support.

The zone is then reset into a new lifecycle as a flipped structural area.

---------------------------------------------------------------------------------------------

[b]Estimated Buy and Sell Activity[/b]

The indicator includes an estimated directional volume model.

Because standard TradingView volume does not directly provide true executed bid and ask volume for every market, buying and selling activity is estimated from candle position within the candle range.

A close nearer the candle high allocates a greater portion of volume to estimated buying activity.

A close nearer the candle low allocates a greater portion of volume to estimated selling activity.

The model can use:

* Pivot volume only.
* Pivot volume plus independent retest activity.

Selected zone labels display estimated activity as:

B 64% | S 36%

This should be interpreted as an estimated directional participation model rather than true exchange-level order-flow delta.

---------------------------------------------------------------------------------------------

[b]Multi-Factor Zone Quality Model[/b]

Every zone receives a dynamic quality score from 0 to 10.

The score is not based on a single condition.

The model combines several structural factors.

[b]Fractal Grade[/b]

Major fractals receive a stronger contribution than weak fractals.

[b]Rejection Wick[/b]

The pivot candle's rejection wick is normalized against ATR.

Larger relative rejection can increase the origin score.

[b]Independent Retests[/b]

The model evaluates how many genuinely independent zone tests have occurred.

Importantly, unlimited retests do not continuously improve quality.

Excessive testing can weaken a zone.

[b]Reaction Strength[/b]

The strongest measured ATR reaction contributes to zone validation.

[b]Estimated Volume Confirmation[/b]

Pivot volume participation and directional estimated activity contribute to the score.

[b]Fractal Cluster[/b]

Multiple nearby fractals can increase structural confidence.

[b]Freshness[/b]

Newer zones receive a greater freshness contribution.

As a zone ages, this component gradually decreases.

The weight of every major quality component can be adjusted by the user.

---------------------------------------------------------------------------------------------

[b]Origin Score and Validation Score[/b]

Internally, the quality engine separates zone evaluation into two conceptual stages.

Origin Quality

Evaluates how the zone was created.

This includes:

* Fractal grade.
* Pivot rejection wick.
* Pivot volume participation.
* Fractal clustering.
* Zone freshness.

[b]Validation Quality[/b]

Evaluates what price did after the zone was created.

This includes:

* Independent retests.
* Reaction strength.
* Directional estimated activity.

Fresh zones are influenced more heavily by origin quality.

As price begins interacting with a zone, validation behaviour receives greater influence.

This allows the quality score to evolve with market behaviour rather than remaining permanently fixed at zone creation.

---------------------------------------------------------------------------------------------

[b]Retest Exhaustion Penalty[/b]

A common assumption is that more support or resistance tests always make a zone stronger.

This indicator does not use that assumption.

Repeated interaction may gradually consume resting liquidity around a price area.

After the configured number of retests, the indicator begins applying an excess retest penalty.

The penalty increases with each additional independent test.

As a result, a heavily tested zone may receive a lower quality score even if it has not formally broken.

---------------------------------------------------------------------------------------------

[b]Congestion Penalty[/b]

Price remaining inside a zone for an extended period may indicate balance, absorption, or structural deterioration.

The indicator tracks consecutive bars interacting with each zone.

After the configured congestion threshold, a progressive quality penalty is applied.

This helps distinguish a clean rejection from prolonged price acceptance inside the area.

---------------------------------------------------------------------------------------------

[b]Trend Regime Alignment[/b]

An optional EMA-based trend regime is included in the quality model.

Support zones located in an unfavourable bearish regime can receive a counter-trend penalty.

Resistance zones located in an unfavourable bullish regime can also receive a penalty.

The trend filter does not automatically delete zones.

Instead, it modifies their relative quality.

This allows historically valid support and resistance areas to remain visible while acknowledging the current directional regime.

---------------------------------------------------------------------------------------------

[b]Market Structure Break Detection[/b]

The indicator includes an independent Market Structure Break, or **MSB**, engine.

Confirmed swing highs and swing lows are detected using a configurable pivot length.

A bullish MSB occurs when price closes above the latest eligible structural high with sufficient momentum confirmation.

A bearish MSB occurs when price closes below the latest eligible structural low with sufficient negative momentum confirmation.

Momentum is normalized using a Z-score calculated from recent price changes.

This reduces the number of minor structural crossings classified as meaningful breaks.

Each structural pivot can generate only one MSB event, preventing repeated labels from appearing after the same swing has already been broken.

---------------------------------------------------------------------------------------------

[b]Zone-to-Structure Confirmation[/b]

Market Structure Breaks can also validate previously tested zones.

When a bullish MSB occurs, the indicator searches for a recently touched support zone.

When a bearish MSB occurs, it searches for a recently touched resistance zone.

The most recent eligible zone can receive structural confirmation.

A configurable quality bonus is then applied.

This creates a basic structural sequence:

Zone interaction → Price reaction → Market Structure Break

The intention is to distinguish zones that merely produced a temporary bounce from zones followed by a measurable structural shift.

---------------------------------------------------------------------------------------------

[b]Premium and Discount Trade Location[/b]

The indicator uses the latest structural swing high and swing low to estimate the current swing midpoint.

The midpoint represents the 50% equilibrium level of the structural range.

When Premium/Discount grading is enabled:

* Support zones are favoured when positioned in the discount portion of the swing.
* Resistance zones are favoured when positioned in the premium portion of the swing.

This condition contributes to the displayed Trade Grade.

It does not remove zones from the chart.

---------------------------------------------------------------------------------------------
[b]Trade Grade System[/b]

Selected zones receive a simplified structural trade grade.

[b]Grade A+[/b]

Reserved for high-quality zones with strong alignment between:

* Zone quality.
* Trend regime.
* Premium/discount location.
* Low structural damage.
* Limited retest exhaustion.

[b]Grade A[/b]

Strong-quality zones with favourable trend alignment and low damage.

[b]Grade B[/b]

Moderate-to-strong structural zones that are not classified as weak fractals.

[b]Grade C[/b]

Lower-quality but still technically visible zones.

[b]Grade D[/b]

Zones with poor overall structural quality.

The Trade Grade is a contextual ranking system.

It is not an automatic buy or sell signal.

---------------------------------------------------------------------------------------------
[b]Star-Based Quality Display[/b]

To make the detailed labels easier to read, the numerical quality model is represented using stars.

★★★★★ = Quality 8.0 or higher

★★★★ = Quality 6.0 to 7.99

★★★ = Quality 4.0 to 5.99

★★ = Quality 2.0 to 3.99

★ = Quality below 2.0

The stars provide a quick visual representation of the underlying 0–10 quality score.

---------------------------------------------------------------------------------------------

[b]Compact Detailed Labels[/b]

Selected zones can display compact one-line labels such as:

VERIFIED SUP | B 64% | S 36% | ★★★★ | Tests: 2 | Grade A

The label contains:

* Current zone status.
* Support or resistance classification.
* Estimated buying activity.
* Estimated selling activity.
* Quality stars.
* Independent retest count.
* Structural Trade Grade.

Because displaying a detailed label on every zone can create significant chart congestion, two label modes are available.

Nearest + Strongest

Prioritizes the nearest support, nearest resistance, and the highest-quality remaining zones.

All Visible Zones

Displays labels for every currently visible zone.

The maximum number of detailed labels can also be controlled.

---------------------------------------------------------------------------------------------

[b]Nearest Zone Highlighting[/b]

The indicator continuously identifies:

* The nearest active support below price.
* The nearest active resistance above price.

These zones can receive stronger border highlighting.

This makes the most immediately relevant structural areas easier to identify without removing historical zones from the chart.

---------------------------------------------------------------------------------------------

[b]Structural Equilibrium Zone[/b]

The latest confirmed structural swing high and swing low are used to calculate a 50% equilibrium area.

The indicator plots:

* Swing origin.
* Swing destination.
* 50% midpoint.
* Configurable equilibrium zone thickness.

Before price interacts with the equilibrium area, the zone is displayed as the current structural midpoint.

After price touches the area, the indicator changes its state to:

[b]Equilibrium touched · wait for structure[/b]

This is intended to remind the trader that equilibrium interaction alone is not necessarily directional confirmation.

Additional market structure may be required.

---------------------------------------------------------------------------------------------

[b]Alert Conditions[/b]

The indicator provides alert conditions for important zone and market-structure events:

* New fractal support zone.
* New fractal resistance zone.
* Independent zone retest.
* Zone verified by ATR reaction.
* Zone reaching Proven status.
* Zone becoming Damaged.
* Zone break.
* Support/resistance role reversal.
* Bullish Market Structure Break.
* Bearish Market Structure Break.

These alerts can be used to monitor structural changes without continuously watching the chart.

---------------------------------------------------------------------------------------------

[b]Suggested Interpretation[/b]

This indicator is designed as a market context and structural analysis tool.

A possible analytical workflow is:

1. Identify the nearest active support and resistance.
2. Review the zone's current status.
3. Check estimated buy/sell activity.
4. Evaluate the quality stars.
5. Review the independent test count.
6. Check whether the zone is fresh, validated, damaged, or exhausted.
7. Evaluate trend alignment.
8. Check premium or discount location.
9. Observe whether price produces a structural break after the zone reaction.
10. Use the Trade Grade as an additional contextual ranking.

No single factor should be interpreted independently.

A five-star zone can still break.

A damaged zone can still generate a reaction.

A weak fractal can still become structurally relevant.

The purpose of the model is to organize multiple price-action variables into a consistent framework.

---------------------------------------------------------------------------------------------

[b] Important Volume Note[/b]

The Buy and Sell percentages displayed by this indicator are estimated directional volume statistics.

They are calculated by allocating candle volume according to the closing position within the candle's high-low range.

They do not represent true bid/ask volume, footprint delta, or exchange-level aggressive buying and selling.

The values should therefore be used as a relative activity estimate only.

---------------------------------------------------------------------------------------------

[b]Non-Repainting Considerations[/b]

Fractal pivots require confirmation bars.

A zone is created only after the corresponding pivot has been confirmed by the selected fractal length.

Higher-timeframe fractal calculations use `lookahead_off`.

Therefore, historical zones should be interpreted from the point at which the fractal became technically confirmed rather than assuming the pivot was known at the exact swing candle in real time.

Market Structure Break conditions are also evaluated using confirmed price and momentum conditions.

---------------------------------------------------------------------------------------------

[b]Final Note[/b]

Fractal Support & Resistance Zones [invincible3] is designed for traders who prefer **dynamic structural zones instead of static support and resistance lines**.

The indicator combines fractal structure, volatility-normalized zone construction, independent retests, reaction measurement, damage analysis, estimated directional activity, structural breaks, trend regime, premium/discount location, and role reversal into a unified zone lifecycle model.

It is intended to help answer three practical questions:

Where is the important price structure?

How has price behaved around that structure?

Is the zone gaining validation, remaining fresh, or gradually losing structural quality?

This indicator is intended for technical analysis and research purposes only. It does not constitute financial advice. Traders should independently evaluate market conditions and apply appropriate risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator("Fractal Support & Resistance Zones invincible]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Constants & Theme-Aware Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645
color EQ_COLOR = #eab308
color DAMAGE_COLOR = #f59e0b
color BROKEN_COLOR = #8b8f99
color FLIP_SUP_COL = #14b8a6
color FLIP_RES_COL = #3b82f6
color NEUTRAL_COLOR = color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Types
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type Zone
    float top
    float bottom
    float originLevel
    int startBar
    int createdBar
    bool isSupport
    bool isWeak
    bool isBroken
    bool isFlipped
    bool wasInside
    bool armedForRetest
    int testCount
    int clusterCount
    float buyVol
    float sellVol
    float maxPenetration
    float reactionATR
    float bestReactionATR
    float quality
    float pivotWickATR
    float pivotVolumeRatio
    float originScore
    float validationScore
    int lastTouchBar
    float reactionAnchor
    int breakBar
    int congestionBars
    bool structureConfirmed
    box boxId
    label labelId

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string G_DET = "① Fractal Detection"
string tfInput = input.timeframe("", "Detection Timeframe", group = G_DET, tooltip = "Leave empty to use the chart timeframe. Higher-timeframe pivots are requested with lookahead OFF.")
int weakLenInput = input.int(2, "Weak Fractal Length", minval = 1, maxval = 50, group = G_DET)
int majorLenInput = input.int(10, "Major Fractal Length", minval = 2, maxval = 100, group = G_DET)
bool showWeakInput = input.bool(true, "Create Weak Fractal Zones", group = G_DET)
bool showMajorInput = input.bool(true, "Create Major Fractal Zones", group = G_DET)

string G_ZONE = "② Zone Construction"
string widthModeInput = input.string("Hybrid Candle + ATR", "Zone Width Method", options = ["ATR", "Pivot Candle", "Hybrid Candle + ATR"], group = G_ZONE)
int atrPeriodInput = input.int(14, "ATR Period", minval = 1, group = G_ZONE)
float atrMultInput = input.float(0.50, "ATR Width Multiplier", minval = 0.05, step = 0.05, group = G_ZONE)
float minZoneTicks = input.float(2.0, "Minimum Width (ticks)", minval = 0.0, step = 1.0, group = G_ZONE)
int maxZonesInput = input.int(30, "Maximum Stored Zones", minval = 2, maxval = 100, group = G_ZONE)
int maxAgeInput = input.int(1000, "Maximum Zone Age (bars)", minval = 20, maxval = 10000, group = G_ZONE)

string G_CLUSTER = "③ Fractal Clustering"
bool mergeZonesInput = input.bool(true, "Merge Nearby Same-Side Fractals", group = G_CLUSTER)
float mergeATRInput = input.float(0.20, "Maximum Merge Gap (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = G_CLUSTER)
int maxClusterInput = input.int(8, "Maximum Cluster Count", minval = 1, maxval = 20, group = G_CLUSTER)
float maxMergedWidthATRInput = input.float(1.25, "Maximum Merged Zone Width (ATR)", minval = 0.10, maxval = 5.0, step = 0.05, group = G_CLUSTER)
bool protectFreshMajorInput = input.bool(true, "Do Not Merge Fresh Major Into Tested/Damaged Zone", group = G_CLUSTER)

string G_TOUCH = "④ Retests & Reactions"
float resetATRInput = input.float(0.50, "Move-Away Distance Before New Retest (ATR)", minval = 0.05, step = 0.05, group = G_TOUCH)
int reactionBarsInput = input.int(20, "Reaction Measurement Window", minval = 1, maxval = 200, group = G_TOUCH)
float verifiedReactionInput = input.float(0.75, "Verified Reaction Threshold (ATR)", minval = 0.1, step = 0.05, group = G_TOUCH)
float provenReactionInput = input.float(1.50, "Proven Reaction Threshold (ATR)", minval = 0.2, step = 0.1, group = G_TOUCH)
int retestPenaltyStartInput = input.int(3, "Retest Penalty Starts At", minval = 2, maxval = 10, group = G_TOUCH)
float excessRetestPenaltyInput = input.float(0.55, "Penalty Per Excess Retest", minval = 0.0, maxval = 2.0, step = 0.05, group = G_TOUCH)
int congestionPenaltyStartInput = input.int(5, "Congestion Penalty Starts After Bars Inside", minval = 1, maxval = 50, group = G_TOUCH)
float congestionPenaltyInput = input.float(0.10, "Congestion Penalty Per Bar", minval = 0.0, maxval = 1.0, step = 0.05, group = G_TOUCH)

string G_DAMAGE = "⑤ Damage & Invalidation"
float damagedPctInput = input.float(60.0, "Damaged Threshold (%)", minval = 5.0, maxval = 100.0, step = 5.0, group = G_DAMAGE)
string breakModeInput = input.string("Close Beyond Zone", "Break Confirmation", options = ["Close Beyond Zone", "Full Candle Beyond Zone"], group = G_DAMAGE)
bool keepBrokenInput = input.bool(false, "Keep Broken Zones Visible", group = G_DAMAGE)
int brokenKeepBarsInput = input.int(150, "Broken Zone Display Bars", minval = 1, maxval = 2000, group = G_DAMAGE)

string G_FLIP = "⑥ Role Reversal"
bool enableFlipsInput = input.bool(true, "Enable Support/Resistance Flips", group = G_FLIP)
float flipLeaveATRInput = input.float(0.30, "Required Move Beyond Broken Zone (ATR)", minval = 0.05, step = 0.05, group = G_FLIP)
int flipMaxBarsInput = input.int(100, "Maximum Bars To Confirm Flip", minval = 5, maxval = 1000, group = G_FLIP)
string flipConfirmInput = input.string("Rejection or Engulfing", "Flip Confirmation", options = ["Zone Reclaim Only", "Close Away", "Rejection or Engulfing"], group = G_FLIP)
float flipCloseAwayATRInput = input.float(0.20, "Flip Close-Away Distance (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = G_FLIP)

string G_VOL = "⑦ Estimated Volume Confirmation"
float minVolumeInput = input.float(0.0, "Minimum Pivot Volume", minval = 0.0, group = G_VOL)
bool showVolumeInput = input.bool(true, "Show Estimated Volume Statistics", group = G_VOL)
string volumeModeInput = input.string("Pivot + Independent Retests", "Estimated Activity Source", options = ["Pivot Only", "Pivot + Independent Retests"], group = G_VOL)
int volumeAvgLenInput = input.int(20, "Volume Average Length", minval = 1, group = G_VOL)

string G_SCORE = "⑧ Zone Quality Model"
float minQualityInput = input.float(0.0, "Hide Zones Below Quality", minval = 0.0, maxval = 10.0, step = 0.5, group = G_SCORE)
float wFractal = input.float(0.22, "Weight · Fractal Grade", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wWick = input.float(0.14, "Weight · Rejection Wick", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wRetest = input.float(0.18, "Weight · Independent Retests", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wReact = input.float(0.20, "Weight · Reaction Strength", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wVolume = input.float(0.12, "Weight · Volume Confirmation", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wCluster = input.float(0.08, "Weight · Fractal Cluster", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float wFresh = input.float(0.06, "Weight · Freshness", minval = 0, maxval = 1, step = 0.01, group = G_SCORE)
float damagePenaltyInput = input.float(2.5, "Maximum Damage Penalty", minval = 0.0, maxval = 10.0, step = 0.25, group = G_SCORE)

string G_MSB = "⑨ Market Structure"
bool showMSBInput = input.bool(true, "Show Market Structure Breaks", group = G_MSB)
int pivotLenInput = input.int(7, "MSB Pivot Length", minval = 1, group = G_MSB)
float msbZScoreInput = input.float(0.5, "Momentum Z-Score Confirmation", minval = 0.0, step = 0.1, group = G_MSB)
float msbZoneBonusInput = input.float(0.8, "Quality Bonus When MSB Confirms Zone", minval = 0.0, maxval = 3.0, step = 0.1, group = G_MSB)
int maxMsbDrawingsInput = input.int(50, "Maximum MSB Drawings", minval = 1, maxval = 500, group = G_MSB)
int msbLinkBarsInput = input.int(30, "Link MSB To Zone Touched Within Bars", minval = 1, maxval = 300, group = G_MSB)

string G_REGIME = "⑩ Trend & Trade Regime"
bool useTrendFilterInput = input.bool(true, "Use Trend Alignment In Quality", group = G_REGIME)
int trendLengthInput = input.int(200, "Trend EMA Length", minval = 5, maxval = 1000, group = G_REGIME)
float counterTrendPenaltyInput = input.float(1.25, "Counter-Trend Quality Penalty", minval = 0.0, maxval = 5.0, step = 0.25, group = G_REGIME)
bool usePremiumDiscountInput = input.bool(true, "Use Swing Premium/Discount In Trade Grade", group = G_REGIME)

string G_EQ = "⑪ Equilibrium"
bool showFibInput = input.bool(true, "Show Equilibrium Zone", group = G_EQ)
float fibZonePerc = input.float(10.0, "Equilibrium Thickness (% of swing)", minval = 1.0, maxval = 30.0, step = 0.5, group = G_EQ)
int fibExtend = input.int(20, "Extend Right (bars)", minval = 0, maxval = 500, group = G_EQ)

string G_VIS = "⑫ Zone Display"
bool showZonesInput = input.bool(true, "Show Zones", group = G_VIS)
bool showSupportZonesInput = input.bool(true, "Show Support Zones", group = G_VIS)
bool showResistanceZonesInput = input.bool(true, "Show Resistance Zones", group = G_VIS)
bool showFreshZonesInput = input.bool(true, "Show Fresh Zones", group = G_VIS)
bool showWeakZonesInput = input.bool(true, "Show Weak Zones", group = G_VIS)
bool showVerifiedZonesInput = input.bool(true, "Show Verified Zones", group = G_VIS)
bool showProvenZonesInput = input.bool(true, "Show Proven Zones", group = G_VIS)
bool showDamagedZonesInput = input.bool(true, "Show Damaged Zones", group = G_VIS)
bool showFlippedZonesInput = input.bool(true, "Show Flipped Zones", group = G_VIS)
bool highlightNearestInput = input.bool(true, "Highlight Nearest Support/Resistance", group = G_VIS)

string G_LABEL = "⑬ Detailed Labels"
bool showLabelsInput = input.bool(true, "Show Detailed Labels", group = G_LABEL)
bool showRetestCountInput = input.bool(true, "Show Independent Retests", group = G_LABEL)
bool showReactionInput = input.bool(true, "Show Reaction Strength", group = G_LABEL)
bool showDamageInput = input.bool(true, "Show Penetration/Damage", group = G_LABEL)
bool showAgeInput = input.bool(true, "Show Zone Age", group = G_LABEL)
bool showClusterInput = input.bool(true, "Show Fractal Cluster", group = G_LABEL)
bool showQualityInput = input.bool(true, "Show Quality Score", group = G_LABEL)
string labelSizeInput = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = G_LABEL)
int labelOffsetInput = input.int(2, "Label Offset (bars)", minval = 0, maxval = 100, group = G_LABEL)
string detailedLabelModeInput = input.string("Nearest + Strongest", "Detailed Label Display", options = ["Nearest + Strongest", "All Visible Zones"], group = G_LABEL, tooltip = "Nearest + Strongest prevents multiline labels from overlapping while keeping every zone box visible.")
int maxDetailedLabelsInput = input.int(6, "Maximum Detailed Labels", minval = 1, maxval = 20, group = G_LABEL)

string G_COL = "⑭ Colors"
color resColor = input.color(color.new(BEAR_COLOR, 85), "Resistance", group = G_COL)
color supColor = input.color(color.new(BULL_COLOR, 85), "Support", group = G_COL)
color weakColor = input.color(color.new(#787b86, 90), "Weak", group = G_COL)
color damagedColor = input.color(color.new(DAMAGE_COLOR, 85), "Damaged", group = G_COL)
color brokenColor = input.color(color.new(BROKEN_COLOR, 92), "Broken", group = G_COL)
color flippedSupportColor = input.color(color.new(FLIP_SUP_COL, 85), "Flipped Support", group = G_COL)
color flippedResistanceColor = input.color(color.new(FLIP_RES_COL, 85), "Flipped Resistance", group = G_COL)
color textColor = chart.fg_color

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(float value, float minimum, float maximum) => math.max(minimum, math.min(maximum, value))

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_formatVol(float value) =>
    float absoluteValue = math.abs(value)
    absoluteValue >= 1e9 ? str.tostring(value / 1e9, "#.##") + "B" :
     absoluteValue >= 1e6 ? str.tostring(value / 1e6, "#.##") + "M" :
     absoluteValue >= 1e3 ? str.tostring(value / 1e3, "#.##") + "K" :
     str.tostring(value, "#")

f_buyVol(float candleHigh, float candleLow, float candleClose, float candleVolume) =>
    float candleRange = candleHigh - candleLow
    candleRange > 0 ? candleVolume * (candleClose - candleLow) / candleRange : candleVolume * 0.5

f_sellVol(float candleHigh, float candleLow, float candleClose, float candleVolume) =>
    float candleRange = candleHigh - candleLow
    candleRange > 0 ? candleVolume * (candleHigh - candleClose) / candleRange : candleVolume * 0.5

f_deltaPct(float buyVolume, float sellVolume) =>
    float totalVolume = nz(buyVolume) + nz(sellVolume)
    totalVolume > 0 ? (buyVolume - sellVolume) / totalVolume * 100.0 : 0.0

f_zoneHeight(Zone zone) => math.max(zone.top - zone.bottom, syminfo.mintick)

f_status(Zone zone) =>
    if zone.isBroken
        "BROKEN"
    else if zone.isFlipped
        zone.isSupport ? "FLIPPED SUPPORT" : "FLIPPED RESISTANCE"
    else if zone.maxPenetration * 100.0 >= damagedPctInput
        "DAMAGED"
    else if zone.isWeak
        "WEAK"
    else if zone.testCount == 0
        "FRESH"
    else if zone.bestReactionATR >= provenReactionInput and zone.testCount >= 2
        "PROVEN"
    else
        "VERIFIED"

f_statusSymbol(string status) =>
    status == "PROVEN" ? "★" :
     status == "VERIFIED" ? "✔" :
     status == "DAMAGED" ? "⚠" :
     status == "BROKEN" ? "✕" :
     str.contains(status, "FLIPPED") ? "↔" :
     status == "FRESH" ? "◆" : "◇"

f_baseColor(Zone zone) =>
    string status = f_status(zone)
    zone.isBroken ? brokenColor :
     zone.isFlipped ? (zone.isSupport ? flippedSupportColor : flippedResistanceColor) :
     status == "DAMAGED" ? damagedColor :
     zone.isWeak ? weakColor :
     zone.isSupport ? supColor : resColor

f_visible(Zone zone) =>
    string status = f_status(zone)
    bool sideAllowed = zone.isSupport ? showSupportZonesInput : showResistanceZonesInput
    bool statusAllowed = status == "FRESH" ? showFreshZonesInput :
         status == "WEAK" ? showWeakZonesInput :
         status == "VERIFIED" ? showVerifiedZonesInput :
         status == "PROVEN" ? showProvenZonesInput :
         status == "DAMAGED" ? showDamagedZonesInput :
         str.contains(status, "FLIPPED") ? showFlippedZonesInput :
         status == "BROKEN" ? keepBrokenInput : false
    showZonesInput and sideAllowed and statusAllowed and zone.quality >= minQualityInput

f_quality(Zone zone, float atrNow, float trendValue) =>
    float fractalFactor = zone.isWeak ? 0.35 : 1.0
    float wickFactor = f_clamp(zone.pivotWickATR / 1.25, 0.0, 1.0)
    float volumeParticipation = f_clamp(zone.pivotVolumeRatio / 2.0, 0.0, 1.0)
    float clusterFactor = f_clamp((zone.clusterCount - 1) / math.max(maxClusterInput - 1.0, 1.0), 0.0, 1.0)
    float ageBars = bar_index - zone.createdBar
    float freshFactor = 1.0 - f_clamp(ageBars / math.max(maxAgeInput, 1.0), 0.0, 1.0)

    float originWeight = math.max(wFractal + wWick + wVolume + wCluster + wFresh, 0.000001)
    float originRaw = fractalFactor * wFractal + wickFactor * wWick + volumeParticipation * wVolume + clusterFactor * wCluster + freshFactor * wFresh
    zone.originScore := f_clamp(originRaw / originWeight * 10.0, 0.0, 10.0)

    float retestFactor = zone.testCount == 0 ? 0.35 : zone.testCount == 1 ? 1.0 : zone.testCount == 2 ? 0.90 : 0.65
    float reactionFactor = f_clamp(zone.bestReactionATR / math.max(provenReactionInput, 0.01), 0.0, 1.0)
    float delta = f_deltaPct(zone.buyVol, zone.sellVol)
    float directionalDelta = zone.isSupport ? delta : -delta
    float activityDirectionFactor = f_clamp((directionalDelta + 20.0) / 70.0, 0.0, 1.0)
    float validationWeight = math.max(wRetest + wReact + wVolume, 0.000001)
    float validationRaw = retestFactor * wRetest + reactionFactor * wReact + activityDirectionFactor * wVolume
    zone.validationScore := f_clamp(validationRaw / validationWeight * 10.0, 0.0, 10.0)

    float validationInfluence = zone.testCount == 0 ? 0.20 : zone.testCount == 1 ? 0.45 : 0.55
    float score = zone.originScore * (1.0 - validationInfluence) + zone.validationScore * validationInfluence

    float damagePenalty = zone.maxPenetration * damagePenaltyInput
    float excessRetests = math.max(zone.testCount - retestPenaltyStartInput + 1, 0)
    float retestPenalty = excessRetests * excessRetestPenaltyInput
    float congestionPenalty = math.max(zone.congestionBars - congestionPenaltyStartInput, 0) * congestionPenaltyInput
    float flipBonus = zone.isFlipped ? 0.35 : 0.0
    float structureBonus = zone.structureConfirmed ? msbZoneBonusInput : 0.0
    float trendPenalty = useTrendFilterInput and not na(trendValue) and ((zone.isSupport and close < trendValue) or (not zone.isSupport and close > trendValue)) ? counterTrendPenaltyInput : 0.0

    f_clamp(score - damagePenalty - retestPenalty - congestionPenalty - trendPenalty + flipBonus + structureBonus, 0.0, 10.0)

f_stars(float score) =>
    score >= 8.0 ? "★★★★★" :
     score >= 6.0 ? "★★★★" :
     score >= 4.0 ? "★★★" :
     score >= 2.0 ? "★★" : "★"

f_tradeGrade(Zone zone, float trendValue, float swingHigh, float swingLow) =>
    bool trendAligned = not useTrendFilterInput or na(trendValue) or (zone.isSupport ? close >= trendValue : close <= trendValue)
    float midpoint = not na(swingHigh) and not na(swingLow) ? math.avg(swingHigh, swingLow) : na
    bool locationAligned = not usePremiumDiscountInput or na(midpoint) or (zone.isSupport ? zone.top <= midpoint : zone.bottom >= midpoint)
    bool lowDamage = zone.maxPenetration < damagedPctInput / 100.0
    bool notExhausted = zone.testCount < retestPenaltyStartInput
    string grade = zone.quality >= 8.0 and trendAligned and locationAligned and lowDamage and notExhausted ? "A+" :
         zone.quality >= 7.0 and trendAligned and lowDamage ? "A" :
         zone.quality >= 5.5 and not zone.isWeak ? "B" :
         zone.quality >= 4.0 ? "C" : "D"
    grade

f_details(Zone zone, float trendValue, float swingHigh, float swingLow) =>
    float totalVolume = zone.buyVol + zone.sellVol
    float bullPct = totalVolume > 0 ? zone.buyVol / totalVolume * 100.0 : 0.0
    float bearPct = totalVolume > 0 ? zone.sellVol / totalVolume * 100.0 : 0.0
    string testWord = zone.testCount == 1 ? "Test" : "Tests"
    string status = f_status(zone)
    string side = zone.isSupport ? "SUP" : "RES"
    string statusSide = str.contains(status, "FLIPPED") ? "FLIPPED " + side : status + " " + side
    string grade = f_tradeGrade(zone, trendValue, swingHigh, swingLow)

    statusSide +
     " | B " + str.tostring(bullPct, "#") + "%" +
     " | S " + str.tostring(bearPct, "#") + "%" +
     " | " + f_stars(zone.quality) +
     " | " + testWord + ": " + str.tostring(zone.testCount) +
     " | Grade " + grade

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Non-repainting timeframe data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_detect() =>
    float atrValueLocal = ta.atr(atrPeriodInput)
    float volumeAverageLocal = ta.sma(volume, volumeAvgLenInput)
    float weakHigh = ta.pivothigh(high, weakLenInput, weakLenInput)
    float weakLow = ta.pivotlow(low, weakLenInput, weakLenInput)
    float majorHigh = ta.pivothigh(high, majorLenInput, majorLenInput)
    float majorLow = ta.pivotlow(low, majorLenInput, majorLenInput)

    float weakHighOpen  = not na(weakHigh) ? open[weakLenInput] : na
    float weakHighClose = not na(weakHigh) ? close[weakLenInput] : na
    float weakHighLow   = not na(weakHigh) ? low[weakLenInput] : na
    float weakHighVol   = not na(weakHigh) ? volume[weakLenInput] : na
    float weakHighVolAvg = not na(weakHigh) ? volumeAverageLocal[weakLenInput] : na
    float weakHighAtr   = not na(weakHigh) ? atrValueLocal[weakLenInput] : na

    float weakLowOpen  = not na(weakLow) ? open[weakLenInput] : na
    float weakLowClose = not na(weakLow) ? close[weakLenInput] : na
    float weakLowHigh  = not na(weakLow) ? high[weakLenInput] : na
    float weakLowVol   = not na(weakLow) ? volume[weakLenInput] : na
    float weakLowVolAvg = not na(weakLow) ? volumeAverageLocal[weakLenInput] : na
    float weakLowAtr   = not na(weakLow) ? atrValueLocal[weakLenInput] : na

    float majorHighOpen  = not na(majorHigh) ? open[majorLenInput] : na
    float majorHighClose = not na(majorHigh) ? close[majorLenInput] : na
    float majorHighLow   = not na(majorHigh) ? low[majorLenInput] : na
    float majorHighVol   = not na(majorHigh) ? volume[majorLenInput] : na
    float majorHighVolAvg = not na(majorHigh) ? volumeAverageLocal[majorLenInput] : na
    float majorHighAtr   = not na(majorHigh) ? atrValueLocal[majorLenInput] : na

    float majorLowOpen  = not na(majorLow) ? open[majorLenInput] : na
    float majorLowClose = not na(majorLow) ? close[majorLenInput] : na
    float majorLowHigh  = not na(majorLow) ? high[majorLenInput] : na
    float majorLowVol   = not na(majorLow) ? volume[majorLenInput] : na
    float majorLowVolAvg = not na(majorLow) ? volumeAverageLocal[majorLenInput] : na
    float majorLowAtr   = not na(majorLow) ? atrValueLocal[majorLenInput] : na

    int weakHighTime = not na(weakHigh) ? time[weakLenInput] : na
    int weakLowTime = not na(weakLow) ? time[weakLenInput] : na
    int majorHighTime = not na(majorHigh) ? time[majorLenInput] : na
    int majorLowTime = not na(majorLow) ? time[majorLenInput] : na

    [weakHigh, weakHighOpen, weakHighClose, weakHighLow, weakHighVol, weakHighVolAvg, weakHighAtr, weakHighTime, weakLow, weakLowOpen, weakLowClose, weakLowHigh, weakLowVol, weakLowVolAvg, weakLowAtr, weakLowTime, majorHigh, majorHighOpen, majorHighClose, majorHighLow, majorHighVol, majorHighVolAvg, majorHighAtr, majorHighTime, majorLow, majorLowOpen, majorLowClose, majorLowHigh, majorLowVol, majorLowVolAvg, majorLowAtr, majorLowTime]

string requestedTf = tfInput == "" ? timeframe.period : tfInput

[wPH, wPHOpen, wPHClose, wPHLow, wPHVol, wPHVolAvg, wPHAtr, wPHTime, wPL, wPLOpen, wPLClose, wPLHigh, wPLVol, wPLVolAvg, wPLAtr, wPLTime, mPH, mPHOpen, mPHClose, mPHLow, mPHVol, mPHVolAvg, mPHAtr, mPHTime, mPL, mPLOpen, mPLClose, mPLHigh, mPLVol, mPLVolAvg, mPLAtr, mPLTime] = request.security(syminfo.tickerid, requestedTf, f_detect(), lookahead = barmerge.lookahead_off)

float atrValue = ta.atr(atrPeriodInput)
float trendValue = ta.ema(close, trendLengthInput)

var int lastWeakHighTime = na
var int lastWeakLowTime = na
var int lastMajorHighTime = na
var int lastMajorLowTime = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Zone management
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var zones = array.new<Zone>()

f_zoneBounds(float pivotPrice, bool isSupport, float pOpen, float pClose, float oppositeWick, float pivotAtr) =>
    float minimumWidth = syminfo.mintick * minZoneTicks
    float atrWidth = math.max(nz(pivotAtr, atrValue) * atrMultInput, minimumWidth)
    float bodyEdge = isSupport ? math.min(pOpen, pClose) : math.max(pOpen, pClose)
    float candleWidth = isSupport ? math.max(bodyEdge - pivotPrice, minimumWidth) : math.max(pivotPrice - bodyEdge, minimumWidth)

    float selectedWidth = widthModeInput == "ATR" ? atrWidth : widthModeInput == "Pivot Candle" ? candleWidth : math.min(math.max(candleWidth, minimumWidth), atrWidth)
    float zoneTop = isSupport ? pivotPrice + selectedWidth : pivotPrice
    float zoneBottom = isSupport ? pivotPrice : pivotPrice - selectedWidth
    [zoneTop, zoneBottom]

f_createZone(float pivotPrice, bool isSupport, bool isWeak, int pivotLength, int pivotTime, float pOpen, float pClose, float oppositeWick, float pVol, float pVolAvg, float pAtr) =>
    if not na(pivotPrice) and nz(pVol) >= minVolumeInput
        [zoneTop, zoneBottom] = f_zoneBounds(pivotPrice, isSupport, pOpen, pClose, oppositeWick, pAtr)

        float pivotBuy = f_buyVol(isSupport ? oppositeWick : pivotPrice, isSupport ? pivotPrice : oppositeWick, pClose, nz(pVol))
        float pivotSell = f_sellVol(isSupport ? oppositeWick : pivotPrice, isSupport ? pivotPrice : oppositeWick, pClose, nz(pVol))

        float wickSize = isSupport ? math.max(math.min(pOpen, pClose) - pivotPrice, 0.0) : math.max(pivotPrice - math.max(pOpen, pClose), 0.0)
        float wickATR = nz(pAtr) > 0 ? wickSize / pAtr : 0.0
        float volumeRatio = nz(pVolAvg) > 0 ? nz(pVol) / pVolAvg : 1.0

        bool merged = false
        if mergeZonesInput and zones.size() > 0
            for i = 0 to zones.size() - 1
                Zone existing = zones.get(i)
                if not existing.isBroken and existing.isSupport == isSupport
                    float gap = zoneBottom > existing.top ? zoneBottom - existing.top : existing.bottom > zoneTop ? existing.bottom - zoneTop : 0.0
                    float proposedTop = math.max(existing.top, zoneTop)
                    float proposedBottom = math.min(existing.bottom, zoneBottom)
                    float proposedWidthATR = (proposedTop - proposedBottom) / math.max(atrValue, syminfo.mintick)
                    bool testedOrDamaged = existing.testCount > 0 or existing.maxPenetration * 100.0 >= damagedPctInput
                    bool protectedMajor = protectFreshMajorInput and not isWeak and testedOrDamaged
                    if gap <= atrValue * mergeATRInput and proposedWidthATR <= maxMergedWidthATRInput and not protectedMajor
                        existing.top := proposedTop
                        existing.bottom := proposedBottom
                        existing.originLevel := (existing.originLevel * existing.clusterCount + pivotPrice) / (existing.clusterCount + 1)
                        existing.clusterCount := math.min(existing.clusterCount + 1, maxClusterInput)
                        existing.isWeak := existing.isWeak and isWeak
                        existing.buyVol += pivotBuy
                        existing.sellVol += pivotSell
                        existing.pivotWickATR := math.max(existing.pivotWickATR, wickATR)
                        existing.pivotVolumeRatio := math.max(existing.pivotVolumeRatio, volumeRatio)
                        existing.quality := f_quality(existing, atrValue, trendValue)
                        merged := true
                        break

        if not merged
            int detectedStartBar = ta.valuewhen(time == pivotTime, bar_index, 0)
            int startBar = na(detectedStartBar) ? math.max(bar_index - pivotLength, 0) : detectedStartBar
            box newBox = box.new(startBar, zoneTop, bar_index, zoneBottom, border_color = na)
            label newLabel = label.new(bar_index + labelOffsetInput, math.avg(zoneTop, zoneBottom), "", style = label.style_none, textcolor = textColor)
            Zone newZone = Zone.new(top = zoneTop, bottom = zoneBottom, originLevel = pivotPrice, startBar = startBar, createdBar = bar_index, isSupport = isSupport, isWeak = isWeak, isBroken = false, isFlipped = false, wasInside = false, armedForRetest = true, testCount = 0, clusterCount = 1, buyVol = pivotBuy, sellVol = pivotSell, maxPenetration = 0.0, reactionATR = 0.0, bestReactionATR = 0.0, quality = 0.0, pivotWickATR = wickATR, pivotVolumeRatio = volumeRatio, originScore = 0.0, validationScore = 0.0, lastTouchBar = na, reactionAnchor = na, breakBar = na, congestionBars = 0, structureConfirmed = false, boxId = newBox, labelId = newLabel)
            newZone.quality := f_quality(newZone, atrValue, trendValue)
            zones.push(newZone)

bool newMajorHigh = showMajorInput and not na(mPH) and not na(mPHTime) and (na(lastMajorHighTime) or mPHTime != lastMajorHighTime)
bool newWeakHigh = showWeakInput and not na(wPH) and not na(wPHTime) and (na(lastWeakHighTime) or wPHTime != lastWeakHighTime)
bool newMajorLow = showMajorInput and not na(mPL) and not na(mPLTime) and (na(lastMajorLowTime) or mPLTime != lastMajorLowTime)
bool newWeakLow = showWeakInput and not na(wPL) and not na(wPLTime) and (na(lastWeakLowTime) or wPLTime != lastWeakLowTime)

if barstate.isconfirmed
    if newMajorHigh
        f_createZone(mPH, false, false, majorLenInput, mPHTime, mPHOpen, mPHClose, mPHLow, mPHVol, mPHVolAvg, mPHAtr)
        lastMajorHighTime := mPHTime
    else if newWeakHigh
        f_createZone(wPH, false, true, weakLenInput, wPHTime, wPHOpen, wPHClose, wPHLow, wPHVol, wPHVolAvg, wPHAtr)
        lastWeakHighTime := wPHTime

    if newMajorLow
        f_createZone(mPL, true, false, majorLenInput, mPLTime, mPLOpen, mPLClose, mPLHigh, mPLVol, mPLVolAvg, mPLAtr)
        lastMajorLowTime := mPLTime
    else if newWeakLow
        f_createZone(wPL, true, true, weakLenInput, wPLTime, wPLOpen, wPLClose, wPLHigh, wPLVol, wPLVolAvg, wPLAtr)
        lastWeakLowTime := wPLTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market structure — one MSB per pivot
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float phMSB = ta.pivothigh(high, pivotLenInput, pivotLenInput)
float plMSB = ta.pivotlow(low, pivotLenInput, pivotLenInput)

var float lastPhMSB = na
var float lastPlMSB = na
var int lastPhIndexMSB = na
var int lastPlIndexMSB = na
var string structureBias = "Neutral"

var int lastBrokenHighPivotIndex = na
var int lastBrokenLowPivotIndex = na

if not na(phMSB)
    lastPhMSB := phMSB
    lastPhIndexMSB := bar_index - pivotLenInput

if not na(plMSB)
    lastPlMSB := plMSB
    lastPlIndexMSB := bar_index - pivotLenInput

float priceChange = ta.change(close)
float avgChange = ta.sma(priceChange, 50)
float stdChange = ta.stdev(priceChange, 50)
float momentumZ = not na(stdChange) and stdChange != 0.0 ? (priceChange - avgChange) / stdChange : 0.0

bool bullMSBRaw =
     not na(lastPhMSB) and
     not na(lastPhIndexMSB) and
     close > lastPhMSB and
     close[1] <= lastPhMSB and
     momentumZ > msbZScoreInput

bool bearMSBRaw =
     not na(lastPlMSB) and
     not na(lastPlIndexMSB) and
     close < lastPlMSB and
     close[1] >= lastPlMSB and
     momentumZ < -msbZScoreInput

bool bullMSB = bullMSBRaw and (na(lastBrokenHighPivotIndex) or lastPhIndexMSB != lastBrokenHighPivotIndex)
bool bearMSB = bearMSBRaw and (na(lastBrokenLowPivotIndex) or lastPlIndexMSB != lastBrokenLowPivotIndex)

var msbLines = array.new<line>()
var msbLabels = array.new<label>()

if bullMSB
    structureBias := "Bullish"
    lastBrokenHighPivotIndex := lastPhIndexMSB

    if showMSBInput
        int midpoint = int(math.round(math.avg(lastPhIndexMSB, bar_index)))
        line bullLine = line.new(
             x1 = lastPhIndexMSB,
             y1 = lastPhMSB,
             x2 = bar_index,
             y2 = lastPhMSB,
             xloc = xloc.bar_index,
             color = BULL_COLOR,
             width = 1
         )
        label bullLabel = label.new(
             x = midpoint,
             y = lastPhMSB,
             text = "MSB",
             xloc = xloc.bar_index,
             style = label.style_none,
             textcolor = BULL_COLOR,
             size = size.small
         )
        msbLines.push(bullLine)
        msbLabels.push(bullLabel)

if bearMSB
    structureBias := "Bearish"
    lastBrokenLowPivotIndex := lastPlIndexMSB

    if showMSBInput
        int midpoint = int(math.round(math.avg(lastPlIndexMSB, bar_index)))
        line bearLine = line.new(
             x1 = lastPlIndexMSB,
             y1 = lastPlMSB,
             x2 = bar_index,
             y2 = lastPlMSB,
             xloc = xloc.bar_index,
             color = BEAR_COLOR,
             width = 1
         )
        label bearLabel = label.new(
             x = midpoint,
             y = lastPlMSB,
             text = "MSB",
             xloc = xloc.bar_index,
             style = label.style_none,
             textcolor = BEAR_COLOR,
             size = size.small
         )
        msbLines.push(bearLine)
        msbLabels.push(bearLabel)

while msbLines.size() > maxMsbDrawingsInput
    line.delete(msbLines.shift())
while msbLabels.size() > maxMsbDrawingsInput
    label.delete(msbLabels.shift())

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dynamic zone lifecycle
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool eventNewSupport = false
bool eventNewResistance = false
bool eventTouch = false
bool eventVerified = false
bool eventProven = false
bool eventDamaged = false
bool eventBroken = false
bool eventFlip = false

eventNewSupport := barstate.isconfirmed and (newMajorLow or (not newMajorLow and newWeakLow))
eventNewResistance := barstate.isconfirmed and (newMajorHigh or (not newMajorHigh and newWeakHigh))

float nearestSupportDistance = 1e20
float nearestResistanceDistance = 1e20
int nearestSupportIndex = -1
int nearestResistanceIndex = -1

if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone zone = zones.get(i)
        float zoneHeight = f_zoneHeight(zone)

        bool ageExpired = bar_index - zone.createdBar > maxAgeInput
        bool brokenExpired = zone.isBroken and not na(zone.breakBar) and bar_index - zone.breakBar > brokenKeepBarsInput

        if ageExpired or (brokenExpired and not enableFlipsInput)
            zone.boxId.delete()
            zone.labelId.delete()
            zones.remove(i)
            continue

        bool inside = high >= zone.bottom and low <= zone.top

        if not zone.isBroken
            float penetration = zone.isSupport ? f_clamp((zone.top - low) / zoneHeight, 0.0, 1.0) : f_clamp((high - zone.bottom) / zoneHeight, 0.0, 1.0)
            float previousPenetration = zone.maxPenetration
            if inside
                zone.maxPenetration := math.max(zone.maxPenetration, penetration)
                zone.congestionBars += 1
            else
                zone.congestionBars := 0

            if previousPenetration * 100.0 < damagedPctInput and zone.maxPenetration * 100.0 >= damagedPctInput
                eventDamaged := true

            bool entered = inside and not zone.wasInside and zone.armedForRetest
            if entered and bar_index > zone.createdBar
                zone.testCount += 1
                zone.lastTouchBar := bar_index
                zone.reactionAnchor := zone.isSupport ? zone.top : zone.bottom
                zone.reactionATR := 0.0
                zone.armedForRetest := false
                eventTouch := true
                if volumeModeInput == "Pivot + Independent Retests"
                    zone.buyVol += f_buyVol(high, low, close, volume)
                    zone.sellVol += f_sellVol(high, low, close, volume)

            if not na(zone.lastTouchBar) and bar_index > zone.lastTouchBar and bar_index - zone.lastTouchBar <= reactionBarsInput
                float currentReaction = zone.isSupport ? math.max(high - zone.reactionAnchor, 0.0) / math.max(atrValue, syminfo.mintick) : math.max(zone.reactionAnchor - low, 0.0) / math.max(atrValue, syminfo.mintick)
                float previousBest = zone.bestReactionATR
                zone.reactionATR := math.max(zone.reactionATR, currentReaction)
                zone.bestReactionATR := math.max(zone.bestReactionATR, currentReaction)
                if previousBest < verifiedReactionInput and zone.bestReactionATR >= verifiedReactionInput
                    eventVerified := true
                if previousBest < provenReactionInput and zone.bestReactionATR >= provenReactionInput and zone.testCount >= 2
                    eventProven := true

            bool movedAway = zone.isSupport ? low > zone.top + atrValue * resetATRInput : high < zone.bottom - atrValue * resetATRInput
            if movedAway
                zone.armedForRetest := true

            zone.wasInside := inside

            bool brokenNow = zone.isSupport ? (breakModeInput == "Close Beyond Zone" ? close < zone.bottom : high < zone.bottom) : (breakModeInput == "Close Beyond Zone" ? close > zone.top : low > zone.top)
            if brokenNow
                zone.isBroken := true
                zone.breakBar := bar_index
                zone.wasInside := false
                zone.armedForRetest := false
                eventBroken := true

        else
            if enableFlipsInput and not zone.isFlipped and not na(zone.breakBar) and bar_index - zone.breakBar <= flipMaxBarsInput
                bool movedBeyond = zone.isSupport ? high < zone.bottom - atrValue * flipLeaveATRInput : low > zone.top + atrValue * flipLeaveATRInput
                bool oppositeRetest = zone.isSupport ? high >= zone.bottom and close <= zone.top : low <= zone.top and close >= zone.bottom
                if movedBeyond
                    zone.armedForRetest := true
                bool bullEngulf = close > open and close >= high[1] and open <= close[1]
                bool bearEngulf = close < open and close <= low[1] and open >= close[1]
                float upperWick = high - math.max(open, close)
                float lowerWick = math.min(open, close) - low
                bool rejection = zone.isSupport ? upperWick > math.abs(close - open) : lowerWick > math.abs(close - open)
                bool engulfing = zone.isSupport ? bearEngulf : bullEngulf
                bool closeAway = zone.isSupport ? close < zone.bottom - atrValue * flipCloseAwayATRInput : close > zone.top + atrValue * flipCloseAwayATRInput
                bool flipConfirmed = flipConfirmInput == "Zone Reclaim Only" ? true : flipConfirmInput == "Close Away" ? closeAway : (rejection or engulfing or closeAway)
                if zone.armedForRetest and oppositeRetest and flipConfirmed
                    zone.isSupport := not zone.isSupport
                    zone.isBroken := false
                    zone.isFlipped := true
                    zone.testCount := 1
                    zone.maxPenetration := 0.0
                    zone.bestReactionATR := 0.0
                    zone.reactionATR := 0.0
                    zone.congestionBars := 0
                    zone.structureConfirmed := false
                    zone.lastTouchBar := bar_index
                    zone.reactionAnchor := zone.isSupport ? zone.top : zone.bottom
                    zone.wasInside := true
                    zone.armedForRetest := false
                    eventFlip := true

        zone.quality := f_quality(zone, atrValue, trendValue)

        if not zone.isBroken
            if zone.isSupport and zone.top <= close
                float distance = close - zone.top
                if distance < nearestSupportDistance
                    nearestSupportDistance := distance
                    nearestSupportIndex := i
            if not zone.isSupport and zone.bottom >= close
                float distance = zone.bottom - close
                if distance < nearestResistanceDistance
                    nearestResistanceDistance := distance
                    nearestResistanceIndex := i

if bullMSB and zones.size() > 0
    int linkedSupport = -1
    int latestSupportTouch = -1
    for i = 0 to zones.size() - 1
        Zone candidate = zones.get(i)
        if candidate.isSupport and not candidate.isBroken and not na(candidate.lastTouchBar) and bar_index - candidate.lastTouchBar <= msbLinkBarsInput and candidate.lastTouchBar > latestSupportTouch
            latestSupportTouch := candidate.lastTouchBar
            linkedSupport := i
    if linkedSupport >= 0
        Zone linked = zones.get(linkedSupport)
        linked.structureConfirmed := true
        linked.quality := f_quality(linked, atrValue, trendValue)

if bearMSB and zones.size() > 0
    int linkedResistance = -1
    int latestResistanceTouch = -1
    for i = 0 to zones.size() - 1
        Zone candidate = zones.get(i)
        if not candidate.isSupport and not candidate.isBroken and not na(candidate.lastTouchBar) and bar_index - candidate.lastTouchBar <= msbLinkBarsInput and candidate.lastTouchBar > latestResistanceTouch
            latestResistanceTouch := candidate.lastTouchBar
            linkedResistance := i
    if linkedResistance >= 0
        Zone linked = zones.get(linkedResistance)
        linked.structureConfirmed := true
        linked.quality := f_quality(linked, atrValue, trendValue)

while zones.size() > maxZonesInput
    Zone oldest = zones.remove(0)
    oldest.boxId.delete()
    oldest.labelId.delete()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Rendering
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var detailedLabelFlags = array.new<bool>()
detailedLabelFlags.clear()
for i = 0 to zones.size()
    detailedLabelFlags.push(false)

if zones.size() > 0 and showLabelsInput
    if detailedLabelModeInput == "All Visible Zones"
        for i = 0 to zones.size() - 1
            if f_visible(zones.get(i))
                detailedLabelFlags.set(i, true)
    else
        int selectedLabels = 0
        if nearestSupportIndex >= 0 and nearestSupportIndex < zones.size()
            Zone nearestSupportZone = zones.get(nearestSupportIndex)
            if f_visible(nearestSupportZone)
                detailedLabelFlags.set(nearestSupportIndex, true)
                selectedLabels += 1

        if nearestResistanceIndex >= 0 and nearestResistanceIndex < zones.size()
            Zone nearestResistanceZone = zones.get(nearestResistanceIndex)
            if f_visible(nearestResistanceZone) and not detailedLabelFlags.get(nearestResistanceIndex)
                detailedLabelFlags.set(nearestResistanceIndex, true)
                selectedLabels += 1

        int selectionGuard = 0
        while selectedLabels < maxDetailedLabelsInput and selectionGuard < 100
            int bestIndex = -1
            float bestQuality = -1.0
            for i = 0 to zones.size() - 1
                Zone candidate = zones.get(i)
                if f_visible(candidate) and not detailedLabelFlags.get(i) and candidate.quality > bestQuality
                    bestQuality := candidate.quality
                    bestIndex := i
            if bestIndex < 0
                break
            detailedLabelFlags.set(bestIndex, true)
            selectedLabels += 1
            selectionGuard += 1

if zones.size() > 0
    for i = 0 to zones.size() - 1
        Zone zone = zones.get(i)
        bool visible = f_visible(zone)
        bool detailedLabelVisible = showLabelsInput and visible and detailedLabelFlags.get(i)
        color base = f_baseColor(zone)
        color hidden = color.new(base, 100)

        bool nearest = highlightNearestInput and (i == nearestSupportIndex or i == nearestResistanceIndex)
        int borderWidth = nearest ? 2 : f_status(zone) == "PROVEN" ? 1 : 1
        
        color dynamicBorder = color.new(base, nearest ? 0 : 40)
        color borderColor = visible ? dynamicBorder : hidden

        zone.boxId.set_left(zone.startBar)
        zone.boxId.set_right(bar_index)
        zone.boxId.set_top(zone.top)
        zone.boxId.set_bottom(zone.bottom)
        zone.boxId.set_bgcolor(visible ? base : hidden)
        zone.boxId.set_border_color(borderColor)
        zone.boxId.set_border_width(borderWidth)

        zone.labelId.set_x(bar_index + labelOffsetInput)
        zone.labelId.set_y(math.avg(zone.top, zone.bottom))
        zone.labelId.set_size(f_size(labelSizeInput))
        zone.labelId.set_textcolor(detailedLabelVisible ? textColor : color.new(textColor, 100))
        zone.labelId.set_color(color.new(chart.bg_color, 100))
        zone.labelId.set_style(label.style_label_left)
        zone.labelId.set_text(detailedLabelVisible ? f_details(zone, trendValue, lastPhMSB, lastPlMSB) : "")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Equilibrium from latest structural swing
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line diagonalLine = na
var line levelZero = na
var line levelHalf = na
var line levelOne = na
var box equilibriumBox = na
var label labelZero = na
var label labelHalf = na
var label labelOne = na
var bool equilibriumTouched = false

if not na(phMSB) or not na(plMSB)
    equilibriumTouched := false

if showFibInput and not na(lastPhMSB) and not na(lastPlMSB)
    bool highFirst = lastPhIndexMSB < lastPlIndexMSB
    float startPrice = highFirst ? lastPhMSB : lastPlMSB
    float endPrice = highFirst ? lastPlMSB : lastPhMSB
    int startIndex = highFirst ? lastPhIndexMSB : lastPlIndexMSB
    int endIndex = highFirst ? lastPlIndexMSB : lastPhIndexMSB

    float swingRange = math.abs(startPrice - endPrice)
    float midpointPrice = math.avg(startPrice, endPrice)
    float offset = swingRange * fibZonePerc / 100.0 / 2.0
    float equilibriumTop = midpointPrice + offset
    float equilibriumBottom = midpointPrice - offset
    int extensionIndex = bar_index + fibExtend

    if low <= equilibriumTop and high >= equilibriumBottom
        equilibriumTouched := true

    color eqStateColor = equilibriumTouched ? EQ_COLOR : NEUTRAL_COLOR
    string eqText = equilibriumTouched ? "Equilibrium touched · wait for structure" : "Equilibrium 0.5"

    if na(diagonalLine)
        diagonalLine := line.new(startIndex, startPrice, endIndex, endPrice, color = color.new(chart.fg_color, 70), style = line.style_dashed)
        levelZero := line.new(endIndex, endPrice, extensionIndex, endPrice, color = color.new(chart.fg_color, 80), style = line.style_dashed)
        levelOne := line.new(startIndex, startPrice, extensionIndex, startPrice, color = color.new(chart.fg_color, 80), style = line.style_dashed)
        levelHalf := line.new(startIndex, midpointPrice, extensionIndex, midpointPrice, color = color.new(eqStateColor, 40), style = line.style_dashed)
        equilibriumBox := box.new(startIndex, equilibriumTop, extensionIndex, equilibriumBottom, border_color = color.new(eqStateColor, 70), bgcolor = color.new(eqStateColor, 92))
        labelZero := label.new(extensionIndex, endPrice, "0 · " + str.tostring(endPrice, format.mintick), style = label.style_none, textcolor = color.new(chart.fg_color, 60))
        labelOne := label.new(extensionIndex, startPrice, "1 · " + str.tostring(startPrice, format.mintick), style = label.style_none, textcolor = color.new(chart.fg_color, 60))
        labelHalf := label.new(extensionIndex, midpointPrice, eqText, style = label.style_none, textcolor = color.new(eqStateColor, 20))
    else
        diagonalLine.set_xy1(startIndex, startPrice)
        diagonalLine.set_xy2(endIndex, endPrice)
        diagonalLine.set_color(color.new(chart.fg_color, 70))
        levelZero.set_xy1(endIndex, endPrice)
        levelZero.set_xy2(extensionIndex, endPrice)
        levelZero.set_color(color.new(chart.fg_color, 80))
        levelOne.set_xy1(startIndex, startPrice)
        levelOne.set_xy2(extensionIndex, startPrice)
        levelOne.set_color(color.new(chart.fg_color, 80))
        levelHalf.set_xy1(startIndex, midpointPrice)
        levelHalf.set_xy2(extensionIndex, midpointPrice)
        levelHalf.set_color(color.new(eqStateColor, 40))
        equilibriumBox.set_lefttop(startIndex, equilibriumTop)
        equilibriumBox.set_rightbottom(extensionIndex, equilibriumBottom)
        equilibriumBox.set_border_color(color.new(eqStateColor, 70))
        equilibriumBox.set_bgcolor(color.new(eqStateColor, 92))
        labelZero.set_xy(extensionIndex, endPrice)
        labelZero.set_text("0 · " + str.tostring(endPrice, format.mintick))
        labelZero.set_textcolor(color.new(chart.fg_color, 60))
        labelOne.set_xy(extensionIndex, startPrice)
        labelOne.set_text("1 · " + str.tostring(startPrice, format.mintick))
        labelOne.set_textcolor(color.new(chart.fg_color, 60))
        labelHalf.set_xy(extensionIndex, midpointPrice)
        labelHalf.set_text(eqText)
        labelHalf.set_textcolor(color.new(eqStateColor, 20))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(eventNewSupport, "New Fractal Support", "New fractal support zone formed on {{ticker}} at {{close}}")
alertcondition(eventNewResistance, "New Fractal Resistance", "New fractal resistance zone formed on {{ticker}} at {{close}}")
alertcondition(eventTouch, "Independent Zone Retest", "Price entered a fractal zone for a new independent retest on {{ticker}}")
alertcondition(eventVerified, "Zone Verified by Reaction", "A fractal zone produced a verified ATR reaction on {{ticker}}")
alertcondition(eventProven, "Zone Became Proven", "A fractal zone reached proven status on {{ticker}}")
alertcondition(eventDamaged, "Zone Damaged", "A fractal zone exceeded the configured penetration threshold on {{ticker}}")
alertcondition(eventBroken, "Zone Broken", "A fractal support/resistance zone was broken on {{ticker}}")
alertcondition(eventFlip, "Zone Role Reversal", "A broken fractal zone confirmed a support/resistance flip on {{ticker}}")
alertcondition(bullMSB, "Bullish Market Structure Break", "Bullish market structure break on {{ticker}} at {{close}}")
alertcondition(bearMSB, "Bearish Market Structure Break", "Bearish market structure break on {{ticker}} at {{close}}")
````
