# Sweep Reclaim Entry Engine [trade_w_samet]

- url: https://www.tradingview.com/script/zdkcpFrg-Sweep-Reclaim-Entry-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;a940a15e911c4a128fda72fa2de90ab6
- version: 2.0

## Description

🎯 Sweep Reclaim Entry Engine [trade_w_samet]

Sweep Reclaim Entry Engine [trade_w_samet] is a structured liquidity-sweep and reclaim analysis indicator designed to help traders study confirmed swing levels, controlled liquidity penetrations, reclaim strength, setup quality, directional alignment, and visual risk/reward models directly on the price chart.

This script focuses on one main concept:

Confirmed swing sweep and reclaim-based entry visualization.

It is not designed to mark every wick beyond every nearby high or low.

It is not designed to treat every penetration as a valid liquidity sweep.

It is not designed to create constant buy/sell labels.

Instead, the goal of Sweep Reclaim Entry Engine is to confirm structural swing levels, monitor their lifecycle, detect controlled penetrations beyond those levels, validate directional reclaims, apply configurable quality and market filters, and visualize accepted setups using one Entry level, one protective Stop Loss level, and one configurable risk/reward target.

The indicator includes:

• Confirmed swing-high and swing-low detection
• Reactive, Balanced, Structural, and Custom swing modes
• ATR-normalized level merging and proximity logic
• Fresh, Armed, Swept, Reclaimed, and Consumed level states
• Wick Only, Wick or Body, and Body Required sweep modes
• Minimum and maximum ATR-normalized sweep-depth filters
• First-penetration-only logic
• Multi-level sweep selection
• Dual-side sweep protection
• Same Candle, Fast, Flexible, and Custom reclaim windows
• Loose, Balanced, Strict, and Custom reclaim-strength modes
• Reclaim close-buffer, close-location, body-strength, and wick-rejection checks
• A transparent 0–100 setup-quality score
• A+, A, and B setup grades
• Loose, Balanced, Strict, and Custom quality-filter modes
• Relative-volume quality context
• Highest Quality and Nearest Level candidate-selection modes
• Direction, cooldown, cluster, duplicate-bar, and opposite-conflict controls
• Chart EMA, confirmed higher-timeframe EMA, and Combined EMA bias
• Optional volatility and market-efficiency filtering
• Entry ATR and Sweep Extreme stop-loss models
• A configurable 0.25R to 15R target
• One-active-trade-at-a-time logic
• Stop First and Target First same-bar assumptions
• Active TP / SL boxes and Entry / TP / SL lines
• SL-specific visual cleanup
• Important-only sweep-label filtering
• Full, Clean, Minimal, and Mobile chart profiles
• Full, Compact, Trade Only, and Off dashboard modes
• Adjustable marker, label, result, and dashboard sizes
• Crimson, Ice Blue, Monochrome, and fully custom colors
• Static TradingView alert conditions
• Optional dynamic alert() messages
• Compact bottom-right dashboard
• Confirmed-close permanent signals
• Confirmed higher-timeframe data handling

The purpose of this script is to help users visually study where a confirmed swing-level sweep is followed by a qualified directional reclaim.

It should be treated as a chart-analysis and educational decision-support tool.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable trades.
It does not execute broker orders.
It does not replace personal analysis, risk management, or trade validation.

[image]https://www.tradingview.com/x/bb27zOZb/[/image]


━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, Sweep Reclaim Entry Engine does the following:

• Detects confirmed bullish and bearish swing pivots.
• Stores accepted swing highs and swing lows in separate internal level memories.
• Prevents near-duplicate levels using ATR-based merge tolerance.
• Tracks whether each level is Fresh, Armed, Swept, Reclaimed, or Consumed.
• Arms a level when price moves within the selected ATR distance.
• Detects a new penetration beyond an eligible swing level.
• Measures penetration depth relative to ATR.
• Classifies the sweep as wick-based or body-based.
• Applies minimum depth, maximum depth, first-interaction, multi-level, and dual-side rules.
• Moves the accepted level into the Swept state.
• Waits for price to reclaim the level within the selected reclaim window.
• Checks reclaim close buffer, close location, candle body strength, candle direction, and wick rejection.
• Calculates a 0–100 setup-quality score.
• Assigns an internal A+, A, or B grade.
• Applies the selected minimum-quality requirement.
• Compares multiple eligible reclaim candidates.
• Applies direction, trend-bias, market, cooldown, clustering, duplicate, and conflict rules.
• Confirms final BUY and SELL reclaim signals only after candle close.
• Projects Entry, Stop Loss, and one configurable take-profit target.
• Maintains one active visual trade model at a time.
• Tracks TP and SL events after the entry candle.
• Applies the selected same-candle TP / SL assumption.
• Preserves successful models when historical display is enabled.
• Deletes failed-model boxes, lines, and original signal labels after SL.
• Leaves only a small CLOSED SL HIT label for failed models.
• Displays engine, bias, quality, signal, and trade information in the bottom-right dashboard.
• Provides sweep, signal, grade, trade-open, TP, and SL alerts.

The script is intentionally built as a structured sequence.

It does not include machine-learning prediction.

It does not claim that every sweep will reverse.

It does not treat the quality score as a probability.

It provides a transparent way to study confirmed swing sweeps, directional reclaims, and their visual trade lifecycle.


━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind Sweep Reclaim Entry Engine is based on the difference between a liquidity penetration and a confirmed reclaim.

A sweep occurs when price trades beyond a previously confirmed swing high or swing low.

A reclaim occurs when price returns through that level and closes with enough directional strength to satisfy the active rules.

The engine does not treat the sweep itself as an entry.

Instead, it separates the process into distinct stages:

Confirmed swing
→ managed level
→ level approach
→ valid penetration
→ sweep classification
→ reclaim window
→ reclaim confirmation
→ quality scoring
→ final filtering
→ confirmed entry model

For a bullish setup, the engine studies a penetration below a confirmed swing low and a later close back above that level.

For a bearish setup, the engine studies a penetration above a confirmed swing high and a later close back below that level.

The reclaim can occur on the same candle or within a configurable number of bars.

The final setup can then be evaluated using:

• sweep depth
• reclaim close quality
• wick rejection
• candle-body strength
• level freshness
• relative volume
• displacement
• market condition
• level cleanliness
• chart EMA alignment
• confirmed higher-timeframe EMA alignment
• cooldown and cluster rules
• opposite-signal conflict handling

The goal is not to maximize signal quantity.

The goal is to create an understandable process that explains how a stored swing level becomes a sweep candidate, how that sweep becomes a reclaim candidate, and how the final entry model is accepted or rejected.


━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

Sweep Reclaim Entry Engine is not intended to be used as a blind buy/sell system.

The script is structured as a visual review workflow:

A pivot becomes confirmed
→ the swing level is stored
→ duplicate levels are filtered
→ price approaches the level
→ the level becomes Armed
→ price creates a new penetration
→ penetration type and depth are validated
→ the level becomes Swept
→ the reclaim window opens
→ reclaim strength is evaluated
→ a quality score is calculated
→ the setup receives a grade
→ eligible candidates are compared
→ execution filters are checked
→ the signal must remain valid at candle close
→ Entry, SL, and TP are projected
→ the active model is monitored
→ the model closes at TP or SL
→ the visual result is archived or cleaned

Each stage serves a specific purpose.

The confirmed-pivot engine defines the structural reference.

The level-memory engine prevents the script from treating all historical highs and lows as permanently active.

The Armed state separates a distant level from a level that price is actively approaching.

The sweep engine distinguishes a controlled penetration from a deep breakout.

The reclaim engine defines what qualifies as a directional return through the level.

The quality engine combines several independent setup characteristics.

The execution engine prevents clustered, duplicate, conflicting, or bias-opposed entries.

The trade model standardizes the visual Entry, risk, and reward references.

The dashboard explains the engine state and active model.

This makes the script a structured sweep-reclaim analysis tool, not a guaranteed signal generator.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script operates through several connected systems.

First, it confirms swing highs and swing lows using the selected pivot sensitivity.

Reactive mode uses shorter pivot lengths.

Balanced mode uses medium pivot lengths.

Structural mode uses wider pivot lengths and is the default.

Custom mode allows manual left-side and right-side pivot lengths.

[pine]
float confirmedSwingHigh = ta.pivothigh(high, swingLeft, swingRight)
float confirmedSwingLow  = ta.pivotlow(low, swingLeft, swingRight)

int confirmedHighBar = bar_index - swingRight
int confirmedLowBar  = bar_index - swingRight
[/pine]

After confirmation, accepted swing levels are stored in separate high-side and low-side arrays.

Each level stores contextual information including:

• level price
• original pivot bar
• lifecycle state
• interaction count
• sweep bar
• sweep depth
• sweep extreme
• sweep type
• reclaim bar
• visual line reference

When price approaches a stored level, the level can move from Fresh to Armed.

When price creates a new penetration beyond the level, the engine checks:

• penetration mode
• minimum ATR depth
• maximum ATR depth
• first-attempt permission
• multi-level selection
• dual-side sweep protection

[pine]
f_isValidHighSweep(float levelPrice, int attempts) =>
    float depthATR = (high - levelPrice) / safeATR
    int kind = f_highSweepKind(levelPrice)
    bool depthValid = depthATR >= minSweepDepthATR and depthATR <= effectiveMaxSweepDepthATR
    bool attemptValid = not firstInteractionOnly or attempts == 0
    bool valid = f_isNewHighPenetration(levelPrice) and depthValid and attemptValid and f_modeAcceptsKind(kind)
    valid

f_isValidLowSweep(float levelPrice, int attempts) =>
    float depthATR = (levelPrice - low) / safeATR
    int kind = f_lowSweepKind(levelPrice)
    bool depthValid = depthATR >= minSweepDepthATR and depthATR <= effectiveMaxSweepDepthATR
    bool attemptValid = not firstInteractionOnly or attempts == 0
    bool valid = f_isNewLowPenetration(levelPrice) and depthValid and attemptValid and f_modeAcceptsKind(kind)
    valid
[/pine]

A valid sweep moves the level into the Swept state.

The reclaim engine then waits for price to close back through the level within the selected window.

The reclaim must pass every enabled strength requirement.

The accepted candidate receives a quality score and grade.

If more than one candidate qualifies, the active Candidate Selection mode chooses the final candidate.

The final signal must also pass direction, bias, market, cooldown, cluster, duplicate-bar, and conflict rules.

Only after the bar closes with all conditions still valid can the permanent BUY or SELL reclaim signal and visual trade model appear.


━━━━━━━━━━━━━━━━━━━━━━
🟢 BULLISH SWEEP RECLAIM LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bullish sweep-reclaim setup begins with a confirmed swing low.

The swing low must be stored and remain eligible.

Price can then move close enough to place the level in the Armed state.

A bullish sweep is created when price penetrates below the swing-low level and the penetration satisfies the active sweep rules.

The engine may require:

• a wick-only penetration
• a wick or body penetration
• body participation beyond the level
• a minimum ATR-normalized depth
• a maximum ATR-normalized depth
• the first valid penetration attempt
• selection as the nearest valid level
• no simultaneous high-side sweep

After the low-side sweep, the bullish reclaim must occur inside the selected reclaim window.

The reclaim can require:

• a close above the swept level
• an ATR-based close buffer above the level
• a high close location inside the candle
• minimum body strength relative to ATR
• a bullish candle body when enabled
• minimum lower-wick rejection for same-candle reclaims
• a final score above the active quality threshold
• permission from the selected signal direction
• bullish chart and/or HTF EMA alignment
• permission from the active market-condition filter
• cooldown and cluster permission
• no stronger bearish conflict

[pine]
f_isValidLowReclaim(int index) =>
    bool valid = false
    if index >= 0 and index < array.size(lowPrices) and barstate.isconfirmed
        int state = array.get(lowStates, index)
        int sweepBar = array.get(lowSweepBars, index)
        if state == STATE_SWEPT and sweepBar >= 0
            float levelPrice = array.get(lowPrices, index)
            int barsAfterSweep = bar_index - sweepBar
            bool windowPass = barsAfterSweep >= 0 and barsAfterSweep <= reclaimWindowBars
            bool closePass = close >= levelPrice + safeATR * reclaimCloseBufferATR
            bool locationPass = f_bullCloseLocation() >= reclaimCloseLocationThreshold
            bool bodyPass = f_bodyATR() >= reclaimBodyStrengthATR
            bool directionPass = not requireDirectionalCandle or close > open
            bool sameBar = barsAfterSweep == 0
            bool wickPass = not requireSameCandleWick or not sameBar or f_lowerWickRatio() >= reclaimWickThreshold
            valid := windowPass and closePass and locationPass and bodyPass and directionPass and wickPass
    valid
[/pine]

When every enabled rule passes at candle close, the script displays a BUY RECLAIM label.

If the visual trade model is enabled and no trade is active, the setup creates:

• Entry at the confirmed signal-bar close
• Stop Loss below entry or below the sweep extreme
• TP above entry
• blue/cyan reward box
• red risk box
• thick white Entry line
• blue TP line
• red SL line

This does not mean price must continue upward.

It means the configured bullish sweep-reclaim conditions were confirmed at the close of that candle.


━━━━━━━━━━━━━━━━━━━━━━
🔴 BEARISH SWEEP RECLAIM LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bearish sweep-reclaim setup begins with a confirmed swing high.

The swing high must be stored and remain eligible.

Price can then move close enough to place the level in the Armed state.

A bearish sweep is created when price penetrates above the swing-high level and the penetration satisfies the active sweep rules.

The engine may require:

• a wick-only penetration
• a wick or body penetration
• body participation beyond the level
• a minimum ATR-normalized depth
• a maximum ATR-normalized depth
• the first valid penetration attempt
• selection as the nearest valid level
• no simultaneous low-side sweep

After the high-side sweep, the bearish reclaim must occur inside the selected reclaim window.

The reclaim can require:

• a close below the swept level
• an ATR-based close buffer below the level
• a low close location inside the candle
• minimum body strength relative to ATR
• a bearish candle body when enabled
• minimum upper-wick rejection for same-candle reclaims
• a final score above the active quality threshold
• permission from the selected signal direction
• bearish chart and/or HTF EMA alignment
• permission from the active market-condition filter
• cooldown and cluster permission
• no stronger bullish conflict

When every enabled rule passes at candle close, the script displays a SELL RECLAIM label.

If the visual trade model is enabled and no trade is active, the setup creates:

• Entry at the confirmed signal-bar close
• Stop Loss above entry or above the sweep extreme
• TP below entry
• blue/cyan reward box
• red risk box
• thick white Entry line
• blue TP line
• red SL line

This does not mean price must continue downward.

It means the configured bearish sweep-reclaim conditions were confirmed at the close of that candle.


━━━━━━━━━━━━━━━━━━━━━━
💎 SWEEP RECLAIM QUALITY FILTER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes a multi-component quality system to reduce low-context reclaim signals.

This is important because not every sweep has the same structural meaning and not every reclaim candle has the same directional strength.

The quality engine evaluates eight components:

Sweep Depth — maximum 15 points

Measures where the penetration sits inside the active minimum-to-maximum sweep range.

The score favors a controlled sweep depth rather than automatically rewarding the deepest penetration.

Reclaim Close — maximum 20 points

Measures the directional location of the candle close.

A bullish setup receives more points when the reclaim closes near the top of the candle.

A bearish setup receives more points when the reclaim closes near the bottom.

Wick Rejection — maximum 15 points

Measures the directional rejection wick.

For multi-bar reclaims, the engine can also consider the stored sweep type and current reclaim structure.

Level Freshness — maximum 10 points

Newer levels generally receive more freshness points than levels that have remained active for a long time.

Relative Volume — maximum 10 points

Compares current volume with the selected baseline length.

When useful volume is not available, the engine avoids treating the setup as automatically invalid.

Displacement — maximum 15 points

Combines candle-body strength and the distance reclaimed through the level.

Market Condition — maximum 10 points

Uses candle range and ATR-regime information.

Level Cleanliness — maximum 5 points

Rewards levels with fewer prior interaction attempts.

The total is rounded and limited to 0–100.

[pine]
float qualityScore = math.min(100.0, math.max(0.0, math.round(
     sweepScore + closeScore + wickScore + freshnessScore +
     volumeScore + displacementScore + marketScore + cleanlinessScore
)))
[/pine]

The quality score is not a win probability.

It is not a verified accuracy percentage.

It is an internal measurement of how closely the completed setup matches the selected structural rules.


━━━━━━━━━━━━━━━━━━━━━━
📏 SWEEP / ATR FILTER
━━━━━━━━━━━━━━━━━━━━━━

The sweep-depth filter measures the penetration beyond a swing level relative to ATR.

For a high-side sweep:

Sweep Depth = (High − Swing High) / ATR.

For a low-side sweep:

Sweep Depth = (Swing Low − Low) / ATR.

Minimum Sweep Depth rejects penetrations that may be too small to represent a meaningful liquidity event.

Maximum Sweep Depth rejects penetrations that may be too deep to represent a controlled sweep and may instead behave more like a breakout.

The default values are:

Minimum Sweep Depth = 0.05 ATR.

Maximum Sweep Depth = 0.80 ATR.

ATR normalization allows the threshold to adapt to changing volatility.

A 0.20 ATR sweep represents a relative move rather than a fixed number of points.

This helps the engine operate across different price scales.

However, ATR normalization does not make one configuration universally suitable.

A symbol with session gaps, irregular volume, or unusual volatility can still behave differently from another market.

A deeper sweep is not automatically a better setup.

Sweep depth is only one component of the complete reclaim process.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ DISPLACEMENT QUALITY FILTER
━━━━━━━━━━━━━━━━━━━━━━

The displacement component evaluates whether the reclaim candle moves with enough directional force.

The engine considers:

• candle-body size relative to ATR
• distance closed beyond the reclaimed level
• bullish or bearish directional recovery

For bullish setups, stronger displacement generally means:

• a larger bullish body
• a close further above the reclaimed swing low

For bearish setups, stronger displacement generally means:

• a larger bearish body
• a close further below the reclaimed swing high

Reclaim Strength Mode can also impose a minimum body-size requirement before the setup reaches the quality-scoring stage.

Loose mode allows smaller directional bodies.

Balanced mode uses moderate requirements.

Strict mode requires stronger completed-candle behavior.

Custom mode exposes the manual threshold.

Displacement is not used as a prediction.

It is used to measure whether the completed reclaim candle demonstrates the selected degree of directional response.


━━━━━━━━━━━━━━━━━━━━━━
📊 REACTION STRENGTH FILTER
━━━━━━━━━━━━━━━━━━━━━━

The reaction-strength layer evaluates the candle that confirms the reclaim.

The active rules can include:

• close through the swept level
• ATR-based close buffer
• directional close location
• body strength relative to ATR
• bullish or bearish candle direction
• same-candle rejection wick

Reclaim Strength Mode provides:

Loose

Uses lower close-buffer, close-location, body-strength, and wick-rejection requirements.

Balanced

Uses moderate thresholds.

Strict

Uses the strongest built-in thresholds and is the default.

Custom

Uses the manual values selected by the user.

Strict mode applies:

• 0.05 ATR reclaim close buffer
• 0.70 directional close-location threshold
• 0.15 ATR minimum body strength
• 0.28 same-candle wick-rejection ratio

Require Directional Candle Body can additionally require:

• close above open for bullish reclaims
• close below open for bearish reclaims

Require Same-Candle Wick Rejection applies the wick requirement when the sweep and reclaim occur on the same candle.

The reaction-strength system is designed to distinguish a simple touch from a stronger completed directional response.


━━━━━━━━━━━━━━━━━━━━━━
🧼 CONFIRMED RECLAIM FILTER
━━━━━━━━━━━━━━━━━━━━━━

The reclaim layer requires the setup to remain valid at candle close.

Available reclaim windows include:

Same Candle

The penetration and reclaim must complete on the same candle.

Fast

The reclaim can occur on the sweep candle or the next candle.

Flexible

The reclaim can occur within three bars and is the default.

Custom

The user selects the maximum number of bars.

The engine stores the sweep bar and compares the current bar with the allowed reclaim window.

The sweep state timeout is automatically prevented from becoming shorter than the active reclaim window.

A reclaimed setup can also be blocked by:

• insufficient close buffer
• weak close location
• weak candle body
• missing directional body
• missing same-candle wick rejection
• low quality score
• direction restriction
• chart EMA misalignment
• higher-timeframe EMA misalignment
• market-condition failure
• active-trade restriction
• cooldown
• same-direction clustering
• duplicate-bar protection
• opposite-direction conflict

Final permanent BUY and SELL signals require confirmed-bar logic.

This means an unfinished realtime candle can temporarily trade beyond a level, but it does not become a permanent reclaim signal unless the conditions remain valid when the bar closes.


━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY MODEL
━━━━━━━━━━━━━━━━━━━━━━

When a final BUY or SELL reclaim signal passes every enabled condition, the script can create a visual entry model.

The Entry reference is the close of the confirmed signal candle.

The engine stores:

• trade direction
• entry bar
• entry price
• stop price
• risk distance
• selected RR
• target price
• setup quality
• setup grade

The trade model opens only when:

• Enable Trade Model is active
• no visual trade is already active
• the final reclaim signal is confirmed
• the calculated risk distance is larger than the symbol’s minimum tick
• same-bar reopening is permitted when the previous model closed on the same candle

[pine]
if enableTradeModel and not tradeActive and (allowSignalOnExitBar or not tradeClosedThisBar)
    if buyReclaimSignal
        float sweepExtreme = array.get(lowSweepExtremes, selectedLowReclaimIndex)
        float candidateStop = stopLossMode == "Entry ATR Multiplier" ?
             close - safeATR * stopATRMultiplier :
             sweepExtreme - safeATR * stopBufferATR
        float candidateRisk = close - candidateStop
[/pine]

The entry model is a visual analysis reference.

It is not a broker market order.

It does not include spread, slippage, commission, latency, or partial fills.


━━━━━━━━━━━━━━━━━━━━━━
🛑 ATR STOP-LOSS MODEL
━━━━━━━━━━━━━━━━━━━━━━

The script includes two stop-placement models.

Entry ATR Multiplier

For BUY setups:

Stop = Entry − ATR × multiplier.

For SELL setups:

Stop = Entry + ATR × multiplier.

This is the default mode.

The default Entry ATR Stop Multiplier is 2.00 ATR.

The multiplier can be adjusted from 0.10 to 15.00.

Sweep Extreme + ATR Buffer

For BUY setups:

Stop = stored low-side sweep extreme − ATR buffer.

For SELL setups:

Stop = stored high-side sweep extreme + ATR buffer.

The default Sweep-Extreme Buffer is 0.10 ATR.

[pine]
float candidateStop = stopLossMode == "Entry ATR Multiplier" ?
     close - safeATR * stopATRMultiplier :
     sweepExtreme - safeATR * stopBufferATR
[/pine]

The selected stop determines the visual risk distance.

That risk distance also determines the take-profit distance.

The displayed stop is a planning reference only.

It does not place or manage a broker stop order.


━━━━━━━━━━━━━━━━━━━━━━
🎯 TAKE-PROFIT RR MODEL
━━━━━━━━━━━━━━━━━━━━━━

The script uses one configurable take-profit target.

The target is calculated from the distance between Entry and Stop Loss.

For BUY models:

TP = Entry + Risk × RR.

For SELL models:

TP = Entry − Risk × RR.

The Risk / Reward Target can be adjusted from:

0.25R to 15.00R.

The default is 2.00R.

[pine]
activeTradeRisk := candidateRisk
activeTradeRR := tradeRiskReward
activeTradeTarget := close + candidateRisk * tradeRiskReward
[/pine]

The displayed RR controls the geometric distance of the projected target.

It does not represent a performance claim.

It does not guarantee that price will reach the target.

Changing the stop model or stop multiplier changes the target distance because both levels are based on the same initial risk.


━━━━━━━━━━━━━━━━━━━━━━
📦 ACTIVE TP / SL BOX SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

When a confirmed reclaim model opens, the script can draw:

• blue/cyan TP box
• red SL box
• thick white Entry line
• blue TP line
• red SL line
• BUY RECLAIM or SELL RECLAIM label

The active boxes and lines extend to the right as new candles appear.

The Entry line is intentionally pure white and visually thicker than the TP and SL references.

When TP is reached:

• the trade model closes
• active boxes and lines stop at the closing bar
• the TP result label appears
• completed visuals can remain when Show Historical Trades is enabled
• completed visuals can be faded using Completed Trade Transparency

When SL is reached:

• the TP box is deleted
• the SL box is deleted
• the Entry line is deleted
• the TP line is deleted
• the SL line is deleted
• the original BUY or SELL signal label associated with that trade is deleted
• only a small CLOSED SL HIT label remains

This SL-specific cleanup keeps failed models visually concise.

The active trade model is educational and bar-based.

It does not simulate real broker execution.


━━━━━━━━━━━━━━━━━━━━━━
🚦 ONE ACTIVE TRADE AT A TIME
━━━━━━━━━━━━━━━━━━━━━━

The script includes one-active-trade-at-a-time logic.

If a visual trade model is active, the engine does not open another trade model until the current model closes.

Block Signals During Active Trade can also prevent new final signal labels from being accepted while the active model is open.

Allow New Signal on Exit Bar controls whether a new model can open on the same candle that closes the current model.

The default is disabled.

This design separates:

• market-level calculation
• sweep and reclaim detection
• permission to create a new trade model

The engine can continue updating structural levels and market context while a model is active.

However, the one-active-model rule prevents overlapping TP / SL boxes and conflicting lifecycle states.

This is a visual-management rule.

It is not a restriction on the user’s personal trading activity.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TP / SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

The script begins checking TP and SL after the entry candle.

If both TP and SL are touched on the same later candle, standard OHLC data does not reveal the actual intrabar sequence.

The script therefore provides two selectable assumptions:

Stop First

The stop is processed before the target.

This is the default and more conservative assumption.

Target First

The target is processed before the stop.

This is the more optimistic assumption.

Neither option reproduces exact tick-level broker execution.

The model does not include:

• bid/ask spread
• slippage
• order latency
• partial fills
• queue priority
• execution venue rules
• intrabar tick order

Same-candle handling is a modeling choice required by the limits of standard bar data.


━━━━━━━━━━━━━━━━━━━━━━
🏷️ SWEEP RECLAIM LABELS
━━━━━━━━━━━━━━━━━━━━━━

The script uses separate labels for sweep events, reclaim signals, and trade results.

Sweep labels can display:

SWEEP HIGH

or:

SWEEP LOW

The Sweep Label Filter can show:

Important Only

Only sweeps that meet the active importance threshold receive visible labels.

All Valid

Every accepted sweep can receive a visible label.

The default Minimum Sweep Importance is 65.

BUY and SELL reclaim labels can use three display styles:

Full

Example:

▲ A+ BUY RECLAIM ▲
QUALITY • 87/100

or:

▼ A+ SELL RECLAIM ▼
QUALITY • 84/100

Compact

Displays a shorter direction, grade, and score format.

Icon

Displays a minimal directional icon and optional score.

Show Grade on Signal Labels controls A+, A, or B display.

Show Score on Signal Labels controls the 0–100 score display.

All dynamic label text uses bold and italic formatting.

Independent size controls are available for:

• sweep labels
• BUY / SELL signal labels
• TP / SL result labels
• confirmed pivot triangle markers


━━━━━━━━━━━━━━━━━━━━━━
📍 SWING LEVEL DISPLAY MODES
━━━━━━━━━━━━━━━━━━━━━━

The indicator includes several level-display modes.

All Active

Displays eligible Fresh, Armed, Swept, and Reclaimed swing levels according to the active color and line-style rules.

Armed + Events

Focuses on Armed, Swept, and Reclaimed levels.

Events Only

Shows levels primarily when a sweep or reclaim event has occurred.

Hidden

Keeps the level engine active while removing swing-level lines from the chart.

Level Line Style provides:

Adaptive

Changes the line appearance according to level state.

Solid

Uses solid lines.

Dashed

Uses dashed lines.

Dotted

Uses dotted lines.

Show Swing-High Levels and Show Swing-Low Levels can independently control each side.

Fade Older Levels can reduce the opacity of older stored levels.

Level Width controls line thickness.

The display mode affects chart presentation only.

It does not change the underlying sweep and reclaim calculations.


━━━━━━━━━━━━━━━━━━━━━━
🧹 LEVEL INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━

Stored levels do not remain eligible forever.

A level can be removed or retired because:

• it exceeds Maximum Level Age
• a confirmed breakout exceeds the allowed invalidation distance
• its sweep state exceeds the active timeout
• it completes its reclaimed hold period
• its first penetration is rejected while First Penetration Only is active
• it is consumed after failing a final execution filter
• the maximum active-level capacity removes an older level

Breakout Invalidation uses ATR-normalized distance.

This helps distinguish a controlled sweep from a confirmed close that travels too far beyond an unswept level.

Sweep State Timeout limits how long a Swept level can wait for reclaim.

Reclaimed Level Hold Bars controls how long the line remains highlighted after a successful reclaim.

Consume Filtered Reclaims determines whether a reclaim candidate rejected by direction, bias, market, cooldown, cluster, or conflict rules is permanently retired.

Removing stale or invalid levels helps reduce repeated signals from outdated price references.


━━━━━━━━━━━━━━━━━━━━━━
📟 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The script includes a dashboard positioned in the bottom-right corner.

Dashboard modes include:

Full

Displays the broadest engine diagnostics.

Compact

Shows a reduced selection of important engine and trade information.

Trade Only

Focuses on the active trade lifecycle.

Off

Hides the dashboard.

The Full dashboard can display:

• active swing and reclaim configuration
• quality-filter mode
• Fresh, Armed, Swept, and Reclaimed level counts
• last sweep side
• last sweep type
• sweep depth
• last reclaim signal
• reclaim delay
• close location
• candle-body strength
• setup grade
• setup-quality score
• quality-component information
• selected candidate mode
• signal direction
• cooldown state
• trend-bias state
• market state
• active level
• latest block reason
• trade state
• Entry
• Stop
• Target
• risk distance
• selected RR
• total visual models
• wins and losses
• internal net R
• last model result
• current and best internal streaks

The dashboard is not TradingView Strategy Tester.

Its trade counters are based on the indicator’s own educational bar-based model.

They do not include spread, commission, slippage, latency, or real broker execution.


━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Sweep Reclaim Entry Engine includes static TradingView alert conditions for:

• Swing High Swept
• Swing Low Swept
• Any Swing Sweep
• BUY Reclaim Confirmed
• SELL Reclaim Confirmed
• Any Reclaim Signal
• A+ Sweep Reclaim
• A Sweep Reclaim
• B Sweep Reclaim
• Sweep Reclaim Trade Opened
• Sweep Reclaim TP Hit
• Sweep Reclaim SL Hit

The script also includes optional dynamic alert() messages.

Dynamic messages can include:

• direction
• symbol
• timeframe
• grade
• quality score
• reclaimed level
• signal close
• Entry
• Stop Loss
• TP
• RR
• stop mode
• final model result

Dynamic Signal Alerts: A+ Only can restrict dynamic final-signal alerts to A+ setups.

Alert filtering affects alert delivery only.

It does not change chart calculations.

Alerts are monitoring tools.

They do not execute trades or place broker orders.


━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

A practical alert workflow:

1. Add Sweep Reclaim Entry Engine [trade_w_samet] to the chart.
2. Select the desired swing, sweep, reclaim, quality, bias, and trade-model settings.
3. Open TradingView’s Create Alert window.
4. Select the indicator as the alert condition.
5. Choose the required static condition.
6. Use BUY Reclaim Confirmed or SELL Reclaim Confirmed for direction-specific signals.
7. Use Any Reclaim Signal for either direction.
8. Use A+, A, or B conditions when grade-specific monitoring is needed.
9. Enable Dynamic alert() Messages when detailed runtime messages are preferred.
10. Select Any alert() function call for dynamic messages.
11. Choose an alert frequency suitable for confirmed-candle monitoring.
12. Test the alert before depending on it.
13. Confirm every event with personal analysis and risk management.

Alert delivery can depend on:

• TradingView servers
• the user’s alert settings
• symbol data availability
• chart timeframe
• realtime feed status
• webhook destination availability

The indicator cannot guarantee alert delivery or external execution.


━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add Sweep Reclaim Entry Engine [trade_w_samet] to a standard candlestick chart.
2. Begin with the default Structural swing mode.
3. Keep Reclaim Strength Mode on Strict while learning the engine.
4. Keep Quality Filter Mode on Strict when a selective default is preferred.
5. Confirm that the selected higher timeframe is above the chart timeframe.
6. Observe the stored swing-high and swing-low levels.
7. Watch for a level to move from Fresh to Armed.
8. Review whether the penetration appears controlled rather than excessively deep.
9. Wait for the reclaim candle to close.
10. Review the BUY or SELL label, grade, and quality score.
11. Check the bottom-right dashboard for bias, market state, block reason, and active trade.
12. Treat Entry, SL, and TP as visual references only.
13. Compare the setup with personal structure, liquidity, session, volatility, and risk rules.
14. Use alerts for monitoring rather than blind execution.
15. Test the exact symbol, timeframe, session, and settings personally used.
16. Review historical TP models and concise CLOSED SL HIT labels to understand the visual lifecycle.

The indicator is best used as a structured sweep-reclaim review tool.

It should not be used as an automatic decision-maker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚙️ Core Swing Engine

Swing Mode
Selects Reactive, Balanced, Structural, or Custom.

Custom Left Bars
Controls left-side pivot sensitivity in Custom mode.

Custom Right Bars
Controls right-side pivot confirmation in Custom mode.

ATR Length
Controls ATR normalization throughout the engine.

━━━━━━━━━━━━━━━━━━━━━━

📍 Level Management

Maximum Active Levels Per Side
Limits stored swing highs and lows separately.

Maximum Level Age
Removes old inactive levels.

Level Merge Tolerance — ATR
Prevents near-duplicate swing levels.

Armed Distance — ATR
Controls how close price must move before a Fresh level becomes Armed.

Breakout Invalidation — ATR
Controls the confirmed-close distance that invalidates an unswept level.

━━━━━━━━━━━━━━━━━━━━━━

🌊 Sweep Detection

Sweep Penetration Mode
Selects Wick Only, Wick or Body, or Body Required.

Minimum Sweep Depth — ATR
Rejects insignificant penetrations.

Maximum Sweep Depth — ATR
Rejects excessively deep penetrations.

First Penetration Only
Allows only the first interaction attempt.

Multi-Level Sweep Handling
Selects Nearest Valid Level or All Valid Levels.

Block Dual-Side Sweep Bars
Prevents one candle from registering both a high-side and low-side sweep.

Sweep State Timeout
Controls how long a Swept level can wait for reclaim.

━━━━━━━━━━━━━━━━━━━━━━

✅ Reclaim Confirmation

Reclaim Window
Selects Same Candle, Fast, Flexible, or Custom.

Custom Reclaim Bars
Controls the reclaim window in Custom mode.

Reclaim Strength Mode
Selects Loose, Balanced, Strict, or Custom.

Custom Close Buffer — ATR
Controls reclaim distance beyond the level.

Custom Close Location
Controls directional close quality.

Custom Body Strength — ATR
Controls minimum reclaim-candle body size.

Custom Wick Rejection Ratio
Controls same-candle rejection-wick quality.

Require Directional Candle Body
Requires bullish or bearish candle direction.

Require Same-Candle Wick Rejection
Requires the active wick threshold for immediate reclaims.

Block Dual-Side Reclaim Bars
Prevents both directions from confirming on one candle.

Reclaimed Level Hold Bars
Controls how long a reclaimed level remains highlighted.

━━━━━━━━━━━━━━━━━━━━━━

💎 Quality Engine

Quality Filter Mode
Selects Loose, Balanced, Strict, or Custom.

Custom Minimum Quality
Controls the manual minimum from 50 to 100.

Include Relative Volume
Adds the relative-volume component.

Relative Volume Length
Controls the volume baseline.

Volatility Regime Length
Controls the ATR-regime baseline.

Show Grade on Signal Labels
Displays A+, A, or B.

Show Score on Signal Labels
Displays the 0–100 quality score.

━━━━━━━━━━━━━━━━━━━━━━

🎯 Signal Execution

Signal Direction
Selects Both, Long Only, or Short Only.

Candidate Selection
Selects Highest Quality or Nearest Level.

Cooldown Mode
Selects Off, Any Signal, or Same Direction.

Signal Cooldown Bars
Controls the time-based delay.

Use Same-Direction Cluster Filter
Blocks nearby repeated signals.

Minimum Signal Distance — ATR
Controls the required distance from the previous same-direction signal.

Block Duplicate Signal Bar
Prevents repeated final signals on one candle.

Opposite-Signal Conflict
Selects Block Both, Higher Quality, BUY Priority, or SELL Priority.

Consume Filtered Reclaims
Retires reclaim candidates rejected by final execution filters.

━━━━━━━━━━━━━━━━━━━━━━

🧭 Bias & Market Filters

Trend Bias Mode
Selects Off, Chart EMA, Higher Timeframe EMA, or Combined EMA.

Chart EMA Length
Controls current-timeframe trend bias.

Higher Timeframe
Selects the HTF context.

Higher-Timeframe EMA Length
Controls the confirmed HTF EMA.

Require EMA Slope Agreement
Adds directional EMA slope.

Market Condition Filter
Selects Off, Volatility, Efficiency, or Combined.

Efficiency Length
Controls directional-efficiency calculation.

Minimum Efficiency
Controls the required efficiency ratio.

Minimum ATR Regime Ratio
Sets the lower volatility boundary.

Maximum ATR Regime Ratio
Sets the upper volatility boundary.

The default HTF layer uses previous completed higher-timeframe values.

[pine]
float confirmedHTFClose = request.security(
     syminfo.tickerid,
     higherTimeframe,
     close[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float confirmedHTFEMA = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, higherTimeframeBiasLength)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)
[/pine]

━━━━━━━━━━━━━━━━━━━━━━

📈 Trade Model

Enable Trade Model
Enables Entry, SL, TP, and lifecycle visualization.

Stop-Loss Mode
Selects Entry ATR Multiplier or Sweep Extreme + ATR Buffer.

Sweep-Extreme Buffer — ATR
Controls protective distance beyond the sweep extreme.

Entry ATR Stop Multiplier
Controls ATR stop distance from Entry.

Risk / Reward Target
Controls target distance from 0.25R to 15R.

TP / SL Same-Bar Priority
Selects Stop First or Target First.

Block Signals During Active Trade
Maintains the one-active-model structure.

Allow New Signal on Exit Bar
Controls same-bar reopening.

Show TP / SL Boxes
Shows or hides risk/reward areas.

Show Entry / TP / SL Lines
Shows or hides price-reference lines.

Show Historical Trades
Keeps completed TP models.

Maximum Historical Trades
Limits stored completed visuals.

Show TP / SL Result Labels
Controls TP HIT and CLOSED SL HIT labels.

━━━━━━━━━━━━━━━━━━━━━━

🔔 Alert System

Enable Dynamic alert() Messages
Activates detailed runtime alerts.

Alert Final BUY / SELL Signals
Enables final-signal messages.

Dynamic Signal Alerts: A+ Only
Restricts dynamic signal messages to A+ setups.

Alert Trade Model Open
Sends Entry, SL, TP, RR, grade, and quality.

Alert TP / SL Result
Sends model-result messages.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Settings

Visual Profile
Selects Full, Clean, Minimal, or Mobile.

Level Display
Selects All Active, Armed + Events, Events Only, or Hidden.

Level Line Style
Selects Adaptive, Solid, Dashed, or Dotted.

Signal Label Style
Selects Full, Compact, or Icon.

Dashboard Mode
Selects Full, Compact, Trade Only, or Off.

Active Trade Zone Transparency
Controls TP / SL fill transparency.

Active Trade Border Transparency
Controls TP / SL borders.

Active Trade Line Width
Controls trade-line thickness.

Fade Completed Trades
Fades completed TP models.

Completed Trade Transparency
Controls historical fading.

Theme
Selects Crimson, Ice Blue, or Monochrome.

Show Swing-High Levels
Controls high-side levels.

Show Swing-Low Levels
Controls low-side levels.

Show Important Sweep Labels
Controls sweep-event labels.

Sweep Label Filter
Selects Important Only or All Valid.

Minimum Sweep Importance
Controls visible sweep quality.

Maximum Important Sweep Labels
Limits sweep-label history.

Show BUY / SELL Reclaim Signals
Controls final reclaim labels.

Maximum Reclaim Labels
Limits final signal-label history.

Fade Older Levels
Reduces old-level opacity.

Level Width
Controls swing-level line thickness.

Show Confirmed Pivot Markers
Controls pivot triangles.

Show Dashboard
Enables the dashboard.

━━━━━━━━━━━━━━━━━━━━━━

🛠️ Customization

Sweep Label Size
Controls SWEEP HIGH / SWEEP LOW labels.

Triangle Marker Size
Controls confirmed pivot triangles.

BUY / SELL Signal Label Size
Controls reclaim labels.

TP / SL Result Label Size
Controls result labels.

Dashboard Header Size
Controls dashboard titles.

Dashboard Text Size
Controls dashboard body text.

Color Mode
Selects Theme or Custom.

Custom color inputs control:

• swing-level states
• BUY / SELL backgrounds and text
• sweep-label backgrounds and text
• Entry, TP, and SL lines
• TP / SL fills and borders
• TP / SL result labels
• dashboard background, header, border, main text, and muted text

Input values and plotted marker values are hidden from the status line.


━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Sweep Reclaim Entry Engine uses familiar analytical concepts such as:

• pivot highs and lows
• liquidity sweeps
• price reclaims
• ATR
• relative volume
• EMA bias
• market efficiency
• risk/reward projection

These concepts are not unique by themselves.

The originality of this script lies in how they are organized into one transparent sweep-reclaim workflow:

Confirmed pivot
→ separate high-side and low-side memories
→ ATR-normalized duplicate control
→ Fresh state
→ Armed state
→ penetration classification
→ minimum and maximum depth validation
→ Swept state
→ configurable reclaim window
→ close, location, body, and wick validation
→ eight-component quality score
→ A+ / A / B grade
→ multi-candidate comparison
→ cooldown, cluster, and conflict handling
→ chart and confirmed HTF EMA alignment
→ optional market-regime filtering
→ one-active-trade model
→ TP-specific historical preservation
→ SL-specific visual cleanup
→ static and dynamic alert delivery
→ bottom-right diagnostic dashboard

Distinctive implementation features include:

• separate lifecycle arrays for swing highs and swing lows
• a defined Armed state before sweep detection
• controlled minimum and maximum penetration depth
• wick/body sweep classification
• first-attempt retirement logic
• sweep-importance scoring separate from setup-quality scoring
• same-candle and multi-bar reclaim support
• transparent quality-component weighting
• Highest Quality and Nearest Level candidate selection
• multiple opposite-conflict resolution modes
• confirmed higher-timeframe EMA data
• ATR-normalized signal clustering
• full chart cleanup after SL
• independent sizing for every label and marker class
• status-line value suppression without hiding chart markers
• configurable targets up to 15R

The script is not a basic collection of unrelated filters.

Each module supports the same swing-sweep-reclaim process.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The indicator’s behavior depends heavily on settings and market conditions.

Signal frequency can change based on:

• Swing Mode
• pivot lengths
• maximum level age
• merge tolerance
• armed distance
• sweep penetration mode
• minimum and maximum sweep depth
• first-penetration logic
• multi-level selection
• reclaim window
• reclaim strength
• directional candle requirement
• same-candle wick requirement
• quality filter mode
• volume context
• direction restriction
• cooldown
• signal-cluster distance
• opposite-conflict mode
• chart EMA length
• HTF selection
• HTF EMA length
• market-condition filter
• volatility regime
• efficiency threshold
• active-trade restrictions
• symbol
• timeframe
• session
• data provider
• available chart history

A setting that appears selective on one market may behave differently on another.

Volume behavior can differ across forex, futures, equities, indices, and cryptocurrencies.

The higher-timeframe filter should use a timeframe meaningfully above the chart timeframe.

Structural mode confirms fewer and broader pivots than Reactive mode.

Strict reclaim and quality modes reduce signal frequency but do not guarantee better results.

Reactive or Balanced modes can increase frequency but can also increase chart noise.

Users should test the exact market, timeframe, session, and configuration they personally study.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

It does not guarantee profitable trades.
It does not predict future price movement.
It does not replace risk management.
It does not execute trades.
It does not place broker orders.
It does not include spread.
It does not include commissions.
It does not include slippage.
It does not include execution delay.
It does not include partial fills.
It uses bar-based OHLC data.
Same-candle TP / SL order cannot be known from standard OHLC bars.
Stop First and Target First are modeling assumptions.
Confirmed pivots require right-side bars before becoming available.
The quality score is not a win probability.
A+ is not a guaranteed outcome.
The dashboard is not TradingView Strategy Tester.
Internal model counters are not audited brokerage performance.
Historical boxes and labels do not guarantee future behavior.
Relative-volume quality depends on available volume data.
Higher-timeframe bias depends on the selected timeframe.
Market-efficiency filtering cannot identify every ranging condition.
ATR normalization does not make one configuration universal.
One-active-trade logic is a visual-management rule.
Data-feed differences can change historical pivots and signals.
Alert delivery depends on TradingView and user configuration.
Changing settings changes historical calculations.
Changing symbol, session, exchange, or timeframe changes the engine context.

For these reasons, Sweep Reclaim Entry Engine should be used as an educational decision-support and chart-analysis tool, not as a standalone automated strategy.


━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• study liquidity sweeps
• monitor confirmed swing highs and lows
• distinguish a sweep from a reclaim
• prefer filtered signals instead of every wick event
• want a visible level lifecycle
• want ATR-normalized penetration thresholds
• want same-candle and multi-bar reclaim support
• want a transparent 0–100 quality framework
• want A+, A, and B setup grades
• want chart and confirmed HTF EMA context
• want optional market-regime filtering
• want Entry, SL, and TP visualization
• want one active model at a time
• want clean SL result handling
• want adjustable mobile and desktop presentation
• want alert-based monitoring
• want a structured educational analysis process

It may be less suitable for users who:

• want guaranteed buy/sell signals
• want a fully automated trading bot
• want every wick beyond every high or low
• expect the quality score to represent probability
• expect one configuration to work on every market
• require exact tick-level execution simulation
• expect displayed levels to match broker fills
• want an indicator to replace independent judgment
• expect alerts to execute orders automatically


━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For a cleaner and more selective review:

• begin with Structural swing mode
• keep First Penetration Only enabled
• use Nearest Valid Level or Highest Quality according to preference
• keep Strict reclaim strength
• keep Strict quality filtering
• use Combined EMA bias
• select a valid higher timeframe
• use Same Direction cooldown
• keep the same-direction cluster filter enabled
• use Stop First for conservative same-candle modeling
• use Important Only sweep labels
• use Clean visual profile
• keep the dashboard in Compact or Full mode while learning
• use alerts for monitoring, not blind execution

For more active signal frequency:

• use Balanced or Reactive swing mode
• use Balanced reclaim strength
• use Balanced quality filtering
• reduce cooldown
• reduce minimum signal distance
• use Chart EMA or disable trend bias
• keep the hard market filter Off
• use All Valid sweep labels only when additional chart detail is useful

Always:

• review the structural level before the sweep
• confirm the reclaim candle has closed
• verify the setup fits personal market context
• compare the stop with nearby structure and volatility
• treat TP as a planning reference
• test the exact symbol and timeframe
• apply independent risk management and position sizing


━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

Sweep Reclaim Entry Engine [trade_w_samet] is published as an educational and visual market-analysis tool.

The purpose of this description is to explain:

• what the script does
• how swing points are confirmed
• how levels are stored and managed
• how Fresh, Armed, Swept, Reclaimed, and Consumed states work
• how penetration type is classified
• how minimum and maximum sweep depth work
• how reclaim timing works
• how reclaim strength is evaluated
• how the 0–100 quality score is calculated
• how A+, A, and B grades are assigned
• how candidates are selected
• how cooldown and clustering operate
• how opposite-direction conflicts are handled
• how chart and confirmed HTF bias work
• how market-condition filters operate
• how Entry and Stop Loss are calculated
• how the RR target is projected
• how one-active-trade logic works
• how same-candle ambiguity is handled
• how active and completed visuals behave
• how SL-specific cleanup works
• what the dashboard displays
• what static and dynamic alerts do
• what the timing limitations are
• what the script’s limitations are
• why the implementation is original

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It should not be used as a blind buy/sell system.

MAIN CHART SCREENSHOT PLAN

Use one clean standard candlestick chart.

Show the indicator with its default settings.

The screenshot should contain:

• one clearly visible confirmed swing level
• one visible SWEEP HIGH or SWEEP LOW event
• one BUY RECLAIM or SELL RECLAIM label
• one active Entry / TP / SL model
• the thick white Entry line
• the blue/cyan TP area
• the red SL area
• the bottom-right dashboard
• the symbol and timeframe
• the indicator title in the status line

Do not include:

• other indicators
• manual drawings
• unrelated labels
• social links
• promotional text
• performance claims
• account-profit screenshots
• non-standard candles
• excessive zoom
• hidden price candles

The screenshot should demonstrate the script’s normal default behavior and make the swing, sweep, reclaim, risk model, and dashboard easy to understand.


━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Sweep Reclaim Entry Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, or tax advice.

No indicator can guarantee future results.

Markets are uncertain, liquidity conditions change, volatility changes, and historical chart behavior does not ensure future performance.

Every user is responsible for their own:

• analysis
• validation
• risk management
• position sizing
• alert configuration
• trading decisions
• broker execution
• legal and tax obligations

The confirmed swing levels, lifecycle states, sweep labels, reclaim labels, quality scores, setup grades, bias states, market-condition states, Entry references, stop-loss levels, take-profit targets, TP / SL boxes, result labels, dashboard values, internal model counters, and alerts are visual analysis tools only.

The displayed Entry is not a guaranteed fill.

The displayed Stop Loss is not a broker order.

The displayed target is not a guaranteed objective.

The 0–100 quality score is not a win probability.

The A+, A, and B grades are not promises of performance.

The internal trade model does not include spread, commissions, slippage, latency, order-book conditions, or partial fills.

Use this script as a structured sweep-reclaim review and decision-support framework, not as a promise of profitability or a substitute for independent judgment.

## Source Code

````pine
//@version=6
indicator(
     "Sweep Reclaim Entry Engine [trade_w_samet]",
     shorttitle = "Sweep Reclaim Entry Engine [trade_w_samet]",
     overlay = true,
     format = format.price,
     behind_chart = false,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 200
)

//══════════════════════════════════════════════════════════════════════
// SWEEP RECLAIM ENTRY ENGINE [trade_w_samet]
// DEVELOPMENT STAGE 8
// Complete Sweep Reclaim Engine + Alerts + Final Polish
//══════════════════════════════════════════════════════════════════════

//──────────────────────────────────────────────────────────────────────
// CONSTANTS
//──────────────────────────────────────────────────────────────────────
int STATE_FRESH     = 0
int STATE_ARMED     = 1
int STATE_SWEPT     = 2
int STATE_RECLAIMED = 3
int STATE_CONSUMED  = 4

int SWEEP_NONE = 0
int SWEEP_WICK = 1
int SWEEP_BODY = 2

//──────────────────────────────────────────────────────────────────────
// INPUT GROUPS
//──────────────────────────────────────────────────────────────────────
string GRP_CORE    = "⚙️ Core Swing Engine"
string GRP_LEVELS  = "📍 Level Management"
string GRP_SWEEP   = "🌊 Sweep Detection"
string GRP_RECLAIM = "✅ Reclaim Confirmation"
string GRP_QUALITY = "💎 Quality Engine"
string GRP_SIGNAL  = "🎯 Signal Execution"
string GRP_BIAS    = "🧭 Bias & Market Filters"
string GRP_TRADE   = "📈 Trade Model"
string GRP_ALERTS  = "🔔 Alert System"
string GRP_VISUALS = "🎨 Visual Settings"
string GRP_DEV     = "🧪 Development Tools"
string GRP_CUSTOM  = "🛠️ Customization"

//──────────────────────────────────────────────────────────────────────
// CORE SWING ENGINE
//──────────────────────────────────────────────────────────────────────
string swingMode = input.string(
     "Reactive",
     "Swing Mode",
     options = ["Reactive", "Balanced", "Structural", "Custom"],
     tooltip = "Reactive finds shorter-term pivots. Balanced is designed for general use. Structural focuses on more significant swing points.",
     group = GRP_CORE,
     display = display.none
)

int customLeft = input.int(
     5,
     "Custom Left Bars",
     minval = 1,
     maxval = 50,
     tooltip = "Number of bars required on the left side of a custom pivot.",
     group = GRP_CORE,
     display = display.none
)

int customRight = input.int(
     5,
     "Custom Right Bars",
     minval = 1,
     maxval = 50,
     tooltip = "Number of closed bars required on the right side before a custom pivot is confirmed.",
     group = GRP_CORE,
     display = display.none
)

int swingLeft = switch swingMode
    "Reactive"   => 2
    "Balanced"   => 4
    "Structural" => 8
    => customLeft

int swingRight = switch swingMode
    "Reactive"   => 2
    "Balanced"   => 4
    "Structural" => 8
    => customRight

int atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     maxval = 200,
     tooltip = "ATR normalizes level distance, sweep depth, merging, and breakout invalidation.",
     group = GRP_CORE,
     display = display.none
)

//──────────────────────────────────────────────────────────────────────
// LEVEL MANAGEMENT
//──────────────────────────────────────────────────────────────────────
int maxLevelsPerSide = input.int(
     8,
     "Maximum Active Levels Per Side",
     minval = 1,
     maxval = 30,
     tooltip = "Limits active swing-high and swing-low levels separately to protect chart performance.",
     group = GRP_LEVELS,
     display = display.none
)

int maxLevelAge = input.int(
     500,
     "Maximum Level Age",
     minval = 25,
     maxval = 5000,
     tooltip = "A level is removed after this many bars if it has not already been invalidated or consumed.",
     group = GRP_LEVELS,
     display = display.none
)

float mergeToleranceATR = input.float(
     0.08,
     "Level Merge Tolerance (ATR)",
     minval = 0.00,
     maxval = 2.00,
     step = 0.01,
     tooltip = "New pivots that form too close to an existing level are treated as the same liquidity area.",
     group = GRP_LEVELS,
     display = display.none
)

float armDistanceATR = input.float(
     0.30,
     "Armed Distance (ATR)",
     minval = 0.01,
     maxval = 5.00,
     step = 0.01,
     tooltip = "A fresh level becomes Armed when price trades within this ATR-normalized distance.",
     group = GRP_LEVELS,
     display = display.none
)

float breakoutInvalidationATR = input.float(
     0.35,
     "Breakout Invalidation (ATR)",
     minval = 0.00,
     maxval = 5.00,
     step = 0.05,
     tooltip = "A confirmed close beyond an unswept level by this distance invalidates it as a reclaim candidate.",
     group = GRP_LEVELS,
     display = display.none
)

//──────────────────────────────────────────────────────────────────────
// SWEEP DETECTION
//──────────────────────────────────────────────────────────────────────
string sweepDetectionMode = input.string(
     "Wick or Body",
     "Sweep Penetration Mode",
     options = ["Wick Only", "Wick or Body", "Body Required"],
     tooltip = "Wick Only requires the candle body to remain inside the level. Wick or Body accepts either penetration type. Body Required needs part of the candle body beyond the level.",
     group = GRP_SWEEP,
     display = display.none
)

float minSweepDepthATR = input.float(
     0.05,
     "Minimum Sweep Depth (ATR)",
     minval = 0.00,
     maxval = 5.00,
     step = 0.01,
     tooltip = "Rejects tiny penetrations that may be caused by spread, tick noise, or insignificant wicks.",
     group = GRP_SWEEP,
     display = display.none
)

float maxSweepDepthATR = input.float(
     0.80,
     "Maximum Sweep Depth (ATR)",
     minval = 0.01,
     maxval = 10.00,
     step = 0.05,
     tooltip = "Rejects penetrations that are too deep and more likely to represent a genuine breakout.",
     group = GRP_SWEEP,
     display = display.none
)

bool firstInteractionOnly = input.bool(
     true,
     "First Penetration Only",
     tooltip = "When enabled, only the first confirmed penetration attempt beyond a swing level can qualify. Invalid first attempts retire that level.",
     group = GRP_SWEEP,
     display = display.none
)

string multiLevelSelection = input.string(
     "Nearest Valid Level",
     "Multi-Level Sweep Handling",
     options = ["Nearest Valid Level", "All Valid Levels"],
     tooltip = "When one candle penetrates several valid swing levels, select only the nearest eligible level or mark every valid level.",
     group = GRP_SWEEP,
     display = display.none
)

bool blockDualSideSweeps = input.bool(
     true,
     "Block Dual-Side Sweep Bars",
     tooltip = "Prevents a single wide-range candle from registering both a swing-high sweep and a swing-low sweep.",
     group = GRP_SWEEP,
     display = display.none
)

int sweepStateTimeout = input.int(
     3,
     "Sweep State Timeout",
     minval = 1,
     maxval = 20,
     tooltip = "Number of bars a swept level remains reserved for the upcoming reclaim engine. After timeout it is retired or re-armed depending on First Penetration Only.",
     group = GRP_SWEEP,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// RECLAIM CONFIRMATION
//──────────────────────────────────────────────────────────────────────
string reclaimMode = input.string(
     "Flexible",
     "Reclaim Window",
     options = ["Same Candle", "Fast", "Flexible", "Custom"],
     tooltip = "Same Candle requires an immediate reclaim. Fast allows the sweep bar or the next bar. Flexible allows up to three bars. Custom uses the manual window below.",
     group = GRP_RECLAIM,
     display = display.none
)

int customReclaimBars = input.int(
     3,
     "Custom Reclaim Bars",
     minval = 0,
     maxval = 20,
     tooltip = "Maximum bars allowed after the sweep bar when Reclaim Window is set to Custom. Zero means same-candle only.",
     group = GRP_RECLAIM,
     display = display.none
)

string reclaimStrengthMode = input.string(
     "Strict",
     "Reclaim Strength Mode",
     options = ["Loose", "Balanced", "Strict", "Custom"],
     tooltip = "Controls the close buffer, close location, candle-body strength, and same-candle wick-rejection thresholds.",
     group = GRP_RECLAIM,
     display = display.none
)

float customCloseBufferATR = input.float(
     0.02,
     "Custom Close Buffer (ATR)",
     minval = 0.00,
     maxval = 2.00,
     step = 0.01,
     tooltip = "Bullish reclaims must close above the swept low by this ATR buffer. Bearish reclaims must close below the swept high by the same buffer.",
     group = GRP_RECLAIM,
     display = display.none
)

float customCloseLocation = input.float(
     0.60,
     "Custom Close Location",
     minval = 0.00,
     maxval = 1.00,
     step = 0.05,
     tooltip = "Required directional close position inside the reclaim candle range. For example, 0.60 means the close must finish inside the strongest 40% of the candle in the reclaim direction.",
     group = GRP_RECLAIM,
     display = display.none
)

float customBodyStrengthATR = input.float(
     0.08,
     "Custom Body Strength (ATR)",
     minval = 0.00,
     maxval = 3.00,
     step = 0.01,
     tooltip = "Minimum absolute reclaim-candle body size normalized by ATR.",
     group = GRP_RECLAIM,
     display = display.none
)

float customWickRejection = input.float(
     0.18,
     "Custom Wick Rejection Ratio",
     minval = 0.00,
     maxval = 1.00,
     step = 0.05,
     tooltip = "Minimum directional rejection wick as a fraction of the candle range. Applied to same-candle reclaims when wick confirmation is enabled.",
     group = GRP_RECLAIM,
     display = display.none
)

bool requireDirectionalCandle = input.bool(
     false,
     "Require Directional Candle Body",
     tooltip = "When enabled, bullish reclaims require close above open and bearish reclaims require close below open. Long rejection candles can still qualify when disabled.",
     group = GRP_RECLAIM,
     display = display.none
)

bool requireSameCandleWick = input.bool(
     true,
     "Require Same-Candle Wick Rejection",
     tooltip = "Applies the directional wick-ratio threshold only when sweep and reclaim occur on the same candle. Multi-bar reclaims rely on close and body strength instead.",
     group = GRP_RECLAIM,
     display = display.none
)

bool blockDualSideReclaims = input.bool(
     true,
     "Block Dual-Side Reclaim Bars",
     tooltip = "Blocks BUY and SELL reclaim signals when both directions would confirm on the same candle.",
     group = GRP_RECLAIM,
     display = display.none
)

int reclaimedLevelHoldBars = input.int(
     3,
     "Reclaimed Level Hold Bars",
     minval = 0,
     maxval = 50,
     tooltip = "Number of bars a successfully reclaimed level remains highlighted before it is consumed and removed.",
     group = GRP_RECLAIM,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// QUALITY ENGINE
//──────────────────────────────────────────────────────────────────────
string qualityFilterMode = input.string(
     "Strict",
     "Quality Filter Mode",
     options = ["Loose", "Balanced", "Strict", "Custom"],
     tooltip = "Loose allows B-grade and stronger setups. Balanced requires A-grade or stronger. Strict displays only A+ setups. Custom uses the manual minimum score.",
     group = GRP_QUALITY,
     display = display.none
)

int customMinimumQuality = input.int(
     65,
     "Custom Minimum Quality",
     minval = 50,
     maxval = 100,
     tooltip = "Minimum 0–100 quality score required when Quality Filter Mode is set to Custom.",
     group = GRP_QUALITY,
     display = display.none
)

bool includeVolumeInScore = input.bool(
     true,
     "Include Relative Volume",
     tooltip = "Uses relative volume as a 10-point quality component. Instruments without reliable volume receive a neutral score instead of being rejected.",
     group = GRP_QUALITY,
     display = display.none
)

int qualityVolumeLength = input.int(
     20,
     "Relative Volume Length",
     minval = 2,
     maxval = 200,
     tooltip = "Lookback used to normalize reclaim-candle volume.",
     group = GRP_QUALITY,
     display = display.none
)

int qualityRegimeLength = input.int(
     20,
     "Volatility Regime Length",
     minval = 2,
     maxval = 200,
     tooltip = "Lookback used by the market-condition component to compare current ATR with its baseline.",
     group = GRP_QUALITY,
     display = display.none
)

bool showGradeOnLabels = input.bool(
     true,
     "Show Grade on Signal Labels",
     tooltip = "Adds A+, A, or B classification to BUY/SELL reclaim labels.",
     group = GRP_QUALITY,
     display = display.none
)

bool showScoreOnLabels = input.bool(
     true,
     "Show Score on Signal Labels",
     tooltip = "Adds the rounded 0–100 quality score to reclaim labels.",
     group = GRP_QUALITY,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// SIGNAL EXECUTION
//──────────────────────────────────────────────────────────────────────
string signalDirectionMode = input.string(
     "Both",
     "Signal Direction",
     options = ["Both", "Long Only", "Short Only"],
     tooltip = "Controls which confirmed reclaim directions are allowed to become final signals.",
     group = GRP_SIGNAL,
     display = display.none
)

string signalSelectionMode = input.string(
     "Highest Quality",
     "Candidate Selection",
     options = ["Highest Quality", "Nearest Level"],
     tooltip = "When several qualified reclaim levels exist on the same bar, choose the strongest quality score or the level nearest to price.",
     group = GRP_SIGNAL,
     display = display.none
)

string cooldownMode = input.string(
     "Same Direction",
     "Cooldown Mode",
     options = ["Off", "Any Signal", "Same Direction"],
     tooltip = "Any Signal blocks both directions during cooldown. Same Direction only blocks repeated signals in the same direction.",
     group = GRP_SIGNAL,
     display = display.none
)

int signalCooldownBars = input.int(
     5,
     "Signal Cooldown Bars",
     minval = 0,
     maxval = 500,
     tooltip = "Minimum number of completed bars required between final signals according to the selected cooldown mode.",
     group = GRP_SIGNAL,
     display = display.none
)

bool useSignalClusterFilter = input.bool(
     true,
     "Use Same-Direction Cluster Filter",
     tooltip = "Blocks repeated same-direction signals that occur too close to the previous signal price.",
     group = GRP_SIGNAL,
     display = display.none
)

float minimumSignalDistanceATR = input.float(
     0.50,
     "Minimum Signal Distance (ATR)",
     minval = 0.00,
     maxval = 20.00,
     step = 0.05,
     tooltip = "Minimum ATR-normalized price distance from the previous signal in the same direction.",
     group = GRP_SIGNAL,
     display = display.none
)

bool blockDuplicateSignalBar = input.bool(
     true,
     "Block Duplicate Signal Bar",
     tooltip = "Prevents more than one final signal from being registered on the same chart bar.",
     group = GRP_SIGNAL,
     display = display.none
)

string conflictResolution = input.string(
     "Higher Quality",
     "Opposite-Signal Conflict",
     options = ["Block Both", "Higher Quality", "BUY Priority", "SELL Priority"],
     tooltip = "Defines what happens if both BUY and SELL reclaim candidates qualify on the same candle.",
     group = GRP_SIGNAL,
     display = display.none
)

bool consumeFilteredReclaims = input.bool(
     true,
     "Consume Filtered Reclaims",
     tooltip = "When enabled, a valid reclaim rejected by direction, bias, market, cooldown, or cluster filters is retired instead of being allowed to trigger later.",
     group = GRP_SIGNAL,
     display = display.none
)

//──────────────────────────────────────────────────────────────────────
// BIAS & MARKET FILTERS
//──────────────────────────────────────────────────────────────────────
string trendBiasMode = input.string(
     "Combined EMA",
     "Trend Bias Mode",
     options = ["Off", "Chart EMA", "Higher Timeframe EMA", "Combined EMA"],
     tooltip = "Chart EMA uses the current timeframe. Higher Timeframe EMA uses confirmed higher-timeframe data. Combined EMA requires both to agree.",
     group = GRP_BIAS,
     display = display.none
)

int chartBiasLength = input.int(
     200,
     "Chart EMA Length",
     minval = 2,
     maxval = 1000,
     tooltip = "EMA length used by Chart EMA and Combined EMA bias modes.",
     group = GRP_BIAS,
     display = display.none
)

string higherTimeframe = input.timeframe(
     "60",
     "Higher Timeframe",
     tooltip = "Higher timeframe used by the confirmed EMA bias calculation.",
     group = GRP_BIAS,
     display = display.none
)

int higherTimeframeBiasLength = input.int(
     200,
     "Higher-Timeframe EMA Length",
     minval = 2,
     maxval = 1000,
     tooltip = "EMA length calculated from confirmed higher-timeframe bars.",
     group = GRP_BIAS,
     display = display.none
)

bool requireBiasSlope = input.bool(
     false,
     "Require EMA Slope Agreement",
     tooltip = "Long bias requires the selected EMA to rise. Short bias requires it to fall.",
     group = GRP_BIAS,
     display = display.none
)

string marketFilterMode = input.string(
     "Off",
     "Market Condition Filter",
     options = ["Off", "Volatility", "Efficiency", "Combined"],
     tooltip = "Volatility keeps ATR inside a controlled regime. Efficiency rejects heavily choppy price action. Combined requires both.",
     group = GRP_BIAS,
     display = display.none
)

int efficiencyLength = input.int(
     20,
     "Efficiency Length",
     minval = 2,
     maxval = 200,
     tooltip = "Lookback used to compare directional movement with total path movement.",
     group = GRP_BIAS,
     display = display.none
)

float minimumEfficiency = input.float(
     0.15,
     "Minimum Efficiency",
     minval = 0.00,
     maxval = 1.00,
     step = 0.01,
     tooltip = "Higher values require cleaner directional movement and reject more choppy conditions.",
     group = GRP_BIAS,
     display = display.none
)

float minimumVolatilityRatio = input.float(
     0.70,
     "Minimum ATR Regime Ratio",
     minval = 0.05,
     maxval = 10.00,
     step = 0.05,
     tooltip = "Current ATR divided by its baseline must be at least this value.",
     group = GRP_BIAS,
     display = display.none
)

float maximumVolatilityRatio = input.float(
     2.20,
     "Maximum ATR Regime Ratio",
     minval = 0.10,
     maxval = 20.00,
     step = 0.05,
     tooltip = "Current ATR divided by its baseline must not exceed this value.",
     group = GRP_BIAS,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// TRADE MODEL
//──────────────────────────────────────────────────────────────────────
bool enableTradeModel = input.bool(
     true,
     "Enable Trade Model",
     tooltip = "Creates a one-active-trade educational model from confirmed Sweep Reclaim signals.",
     group = GRP_TRADE,
     display = display.none
)

string stopLossMode = input.string(
     "Entry ATR Multiplier",
     "Stop-Loss Mode",
     options = ["Sweep Extreme + ATR Buffer", "Entry ATR Multiplier"],
     tooltip = "Sweep Extreme places the stop beyond the swept wick and adds an ATR buffer. Entry ATR Multiplier places the stop at a fixed ATR distance from the signal-bar close.",
     group = GRP_TRADE,
     display = display.none
)

float stopBufferATR = input.float(
     0.10,
     "Sweep-Extreme Buffer (ATR)",
     minval = 0.00,
     maxval = 10.00,
     step = 0.05,
     tooltip = "Used only by Sweep Extreme + ATR Buffer. BUY stop is below the swept low; SELL stop is above the swept high.",
     group = GRP_TRADE,
     display = display.none
)

float stopATRMultiplier = input.float(
     2.00,
     "Entry ATR Stop Multiplier",
     minval = 0.10,
     maxval = 15.00,
     step = 0.10,
     tooltip = "Used only by Entry ATR Multiplier. BUY stop = Entry - ATR x Multiplier. SELL stop = Entry + ATR x Multiplier.",
     group = GRP_TRADE,
     display = display.none
)

float tradeRiskReward = input.float(
     2.00,
     "Risk / Reward Target",
     minval = 0.25,
     maxval = 15.00,
     step = 0.25,
     tooltip = "Take-profit distance equals stop distance multiplied by this risk/reward value. Maximum target is 15R.",
     group = GRP_TRADE,
     display = display.none
)

string sameBarExitPriority = input.string(
     "Stop First",
     "TP / SL Same-Bar Priority",
     options = ["Stop First", "Target First"],
     tooltip = "Defines the conservative result when both stop-loss and take-profit are touched on the same candle after entry.",
     group = GRP_TRADE,
     display = display.none
)

bool blockSignalsDuringActiveTrade = input.bool(
     true,
     "Block Signals During Active Trade",
     tooltip = "Maintains the one-active-trade model by rejecting new final signals while a trade is open.",
     group = GRP_TRADE,
     display = display.none
)

bool allowSignalOnExitBar = input.bool(
     false,
     "Allow New Signal on Exit Bar",
     tooltip = "When disabled, a new trade cannot open on the same candle that closes the previous trade.",
     group = GRP_TRADE,
     display = display.none
)

bool showTradeBoxes = input.bool(
     true,
     "Show TP / SL Boxes",
     tooltip = "Displays soft-glass profit and risk zones for the active trade and optionally for historical trades.",
     group = GRP_TRADE,
     display = display.none
)

bool showTradeLines = input.bool(
     true,
     "Show Entry / TP / SL Lines",
     tooltip = "Displays white entry, target, and stop reference lines.",
     group = GRP_TRADE,
     display = display.none
)

bool showHistoricalTrades = input.bool(
     true,
     "Show Historical Trades",
     tooltip = "Keeps completed TP/SL trade structures on the chart.",
     group = GRP_TRADE,
     display = display.none
)

int maxHistoricalTrades = input.int(
     20,
     "Maximum Historical Trades",
     minval = 1,
     maxval = 60,
     tooltip = "Limits stored completed trade boxes, lines, and result labels.",
     group = GRP_TRADE,
     display = display.none
)

bool showTradeResultLabels = input.bool(
     true,
     "Show TP / SL Result Labels",
     tooltip = "Marks completed trades with TP HIT or SL HIT labels.",
     group = GRP_TRADE,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// ALERT SYSTEM
//──────────────────────────────────────────────────────────────────────
bool enableDynamicAlerts = input.bool(
     false,
     "Enable Dynamic alert() Messages",
     tooltip = "Enables detailed runtime alert() payloads. Create a TradingView alert using 'Any alert() function call'.",
     group = GRP_ALERTS,
     display = display.none
)

bool dynamicAlertFinalSignals = input.bool(
     true,
     "Alert Final BUY / SELL Signals",
     tooltip = "Sends a dynamic message when a final filtered Sweep Reclaim signal is confirmed.",
     group = GRP_ALERTS,
     display = display.none
)

bool dynamicAlertStrongOnly = input.bool(
     false,
     "Dynamic Signal Alerts: A+ Only",
     tooltip = "When enabled, dynamic final-signal alerts are limited to A+ setups. Static alertcondition options remain available.",
     group = GRP_ALERTS,
     display = display.none
)

bool dynamicAlertTradeOpen = input.bool(
     true,
     "Alert Trade Model Open",
     tooltip = "Sends Entry, SL, TP, RR, grade, and quality information when the educational trade model opens.",
     group = GRP_ALERTS,
     display = display.none
)

bool dynamicAlertTradeResult = input.bool(
     true,
     "Alert TP / SL Result",
     tooltip = "Sends the completed trade result and updated performance metrics.",
     group = GRP_ALERTS,
     display = display.none
)

//──────────────────────────────────────────────────────────────────────
// VISUAL SETTINGS
//──────────────────────────────────────────────────────────────────────
string visualProfile = input.string(
     "Clean",
     "Visual Profile",
     options = ["Full", "Clean", "Minimal", "Mobile"],
     tooltip = "Full shows every enabled visual. Clean prioritizes active levels and signals. Minimal keeps final signals and the active trade. Mobile uses compact labels, a compact dashboard, and reduced chart density.",
     group = GRP_VISUALS,
     display = display.none
)

string levelDisplayMode = input.string(
     "All Active",
     "Level Display",
     options = ["All Active", "Armed + Events", "Events Only", "Hidden"],
     tooltip = "Controls which swing-level lifecycle states remain visible. Visual Profile may apply a cleaner override.",
     group = GRP_VISUALS,
     display = display.none
)

string levelLineStyleMode = input.string(
     "Adaptive",
     "Level Line Style",
     options = ["Adaptive", "Solid", "Dashed", "Dotted"],
     tooltip = "Adaptive uses dotted fresh levels and solid armed, swept, and reclaimed levels.",
     group = GRP_VISUALS,
     display = display.none
)

string signalLabelStyle = input.string(
     "Full",
     "Signal Label Style",
     options = ["Full", "Compact", "Icon"],
     tooltip = "Full shows BUY/SELL RECLAIM. Compact shortens the label. Icon uses a directional triangle and optional score.",
     group = GRP_VISUALS,
     display = display.none
)

string dashboardMode = input.string(
     "Full",
     "Dashboard Mode",
     options = ["Full", "Compact", "Trade Only", "Off"],
     tooltip = "Full shows every diagnostic. Compact keeps core setup and market information. Trade Only focuses on the active trade and results.",
     group = GRP_VISUALS,
     display = display.none
)

int tradeZoneTransparency = input.int(
     70,
     "Active Trade Zone Transparency",
     minval = 55,
     maxval = 98,
     tooltip = "Higher values make TP and SL zones more transparent.",
     group = GRP_VISUALS,
     display = display.none
)

int tradeBorderTransparency = input.int(
     35,
     "Active Trade Border Transparency",
     minval = 0,
     maxval = 95,
     tooltip = "Controls TP and SL box border transparency.",
     group = GRP_VISUALS,
     display = display.none
)

int activeTradeLineWidth = input.int(
     3,
     "Active Trade Line Width",
     minval = 1,
     maxval = 4,
     tooltip = "Controls Entry, TP, and SL line thickness.",
     group = GRP_VISUALS,
     display = display.none
)

bool fadeCompletedTrades = input.bool(
     true,
     "Fade Completed Trades",
     tooltip = "Fades completed historical trade structures so the active setup remains visually dominant.",
     group = GRP_VISUALS,
     display = display.none
)

int completedTradeTransparency = input.int(
     92,
     "Completed Trade Transparency",
     minval = 70,
     maxval = 98,
     tooltip = "Controls the opacity of completed trade boxes and lines.",
     group = GRP_VISUALS,
     display = display.none
)

string theme = input.string(
     "Crimson",
     "Theme",
     options = ["Crimson", "Ice Blue", "Monochrome"],
     tooltip = "Changes the level palette without affecting calculation logic.",
     group = GRP_VISUALS,
     display = display.none
)

bool showSwingHighs = input.bool(
     true,
     "Show Swing-High Levels",
     tooltip = "Displays confirmed resistance-side liquidity levels.",
     group = GRP_VISUALS,
     display = display.none
)

bool showSwingLows = input.bool(
     true,
     "Show Swing-Low Levels",
     tooltip = "Displays confirmed support-side liquidity levels.",
     group = GRP_VISUALS,
     display = display.none
)

bool showSweepMarkers = input.bool(
     true,
     "Show Important Sweep Labels",
     tooltip = "Displays labels only for sweep levels that pass the importance filter.",
     group = GRP_VISUALS,
     display = display.none
)

string sweepLabelFilter = input.string(
     "Important Only",
     "Sweep Label Filter",
     options = ["Important Only", "All Valid"],
     tooltip = "Important Only scores level age, pivot structure, penetration quality, first interaction, and sweep type before displaying a label.",
     group = GRP_VISUALS,
     display = display.none
)

float minimumSweepImportance = input.float(
     65.0,
     "Minimum Sweep Importance",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     tooltip = "Minimum 0–100 importance score required for a sweep label.",
     group = GRP_VISUALS,
     display = display.none
)

int maxSweepMarkers = input.int(
     30,
     "Maximum Important Sweep Labels",
     minval = 1,
     maxval = 150,
     tooltip = "Limits historical important sweep labels to protect chart performance.",
     group = GRP_VISUALS,
     display = display.none
)


bool showReclaimSignals = input.bool(
     true,
     "Show BUY / SELL Reclaim Signals",
     tooltip = "Displays confirmed BUY RECLAIM and SELL RECLAIM labels after all reclaim conditions pass.",
     group = GRP_VISUALS,
     display = display.none
)

int maxReclaimLabels = input.int(
     100,
     "Maximum Reclaim Labels",
     minval = 10,
     maxval = 250,
     tooltip = "Limits historical BUY and SELL reclaim labels to protect chart performance.",
     group = GRP_VISUALS,
     display = display.none
)

bool fadeOlderLevels = input.bool(
     true,
     "Fade Older Levels",
     tooltip = "Gradually reduces the opacity of levels as they age.",
     group = GRP_VISUALS,
     display = display.none
)

int levelWidth = input.int(
     2,
     "Level Width",
     minval = 1,
     maxval = 4,
     group = GRP_VISUALS,
     display = display.none
)

bool showPivotMarkers = input.bool(
     false,
     "Show Confirmed Pivot Markers",
     tooltip = "Development visual that marks the original confirmed pivot locations.",
     group = GRP_DEV,
     display = display.none
)

bool showCoreDashboard = input.bool(
     true,
     "Show Dashboard",
     tooltip = "Displays the selected full, compact, or trade-focused dashboard.",
     group = GRP_VISUALS,
     display = display.none
)


//──────────────────────────────────────────────────────────────────────
// CUSTOMIZATION — FINAL SETTINGS GROUP
//──────────────────────────────────────────────────────────────────────
string sweepLabelSize = input.string(
     "Small",
     "Sweep Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls SWEEP HIGH and SWEEP LOW label size.",
     group = GRP_CUSTOM,
     display = display.none
)

string triangleMarkerSize = input.string(
     "Tiny",
     "Triangle Marker Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls confirmed swing-high and swing-low triangle marker size.",
     group = GRP_CUSTOM,
     display = display.none
)

string signalLabelSize = input.string(
     "Normal",
     "BUY / SELL Signal Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls BUY RECLAIM and SELL RECLAIM label size.",
     group = GRP_CUSTOM,
     display = display.none
)

string resultLabelSize = input.string(
     "Large",
     "TP / SL Result Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls TP HIT and SL HIT result label size.",
     group = GRP_CUSTOM,
     display = display.none
)

string dashboardHeaderTextSize = input.string(
     "Small",
     "Dashboard Header Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls the title/header text inside dashboards.",
     group = GRP_CUSTOM,
     display = display.none
)

string dashboardBodyTextSize = input.string(
     "Tiny",
     "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip = "Controls all regular text inside dashboards.",
     group = GRP_CUSTOM,
     display = display.none
)

string colorMode = input.string(
     "Custom",
     "Color Mode",
     options = ["Theme", "Custom"],
     tooltip = "Theme uses the selected Crimson, Ice Blue, or Monochrome palette. Custom applies every color below.",
     group = GRP_CUSTOM,
     display = display.none
)

color customHighFreshColor = input.color(color.rgb(235, 64, 72), "Swing High — Fresh", group = GRP_CUSTOM, display = display.none)
color customLowFreshColor = input.color(color.rgb(245, 245, 245), "Swing Low — Fresh", group = GRP_CUSTOM, display = display.none)
color customHighArmedColor = input.color(color.rgb(255, 92, 92), "Swing High — Armed", group = GRP_CUSTOM, display = display.none)
color customLowArmedColor = input.color(color.rgb(255, 255, 255), "Swing Low — Armed", group = GRP_CUSTOM, display = display.none)
color customHighSweptColor = input.color(color.rgb(255, 179, 0), "Swing High — Swept", group = GRP_CUSTOM, display = display.none)
color customLowSweptColor = input.color(color.rgb(0, 220, 150), "Swing Low — Swept", group = GRP_CUSTOM, display = display.none)

color customBuyReclaimColor = input.color(color.rgb(0, 210, 135), "BUY Signal Background", group = GRP_CUSTOM, display = display.none)
color customSellReclaimColor = input.color(color.rgb(239, 52, 73), "SELL Signal Background", group = GRP_CUSTOM, display = display.none)
color customBuySignalTextColor = input.color(color.white, "BUY Signal Text", group = GRP_CUSTOM, display = display.none)
color customSellSignalTextColor = input.color(color.white, "SELL Signal Text", group = GRP_CUSTOM, display = display.none)

color customHighSweepLabelColor = input.color(color.rgb(255, 179, 0), "High Sweep Label Background", group = GRP_CUSTOM, display = display.none)
color customLowSweepLabelColor = input.color(color.rgb(0, 220, 150), "Low Sweep Label Background", group = GRP_CUSTOM, display = display.none)
color customHighSweepTextColor = input.color(color.white, "High Sweep Label Text", group = GRP_CUSTOM, display = display.none)
color customLowSweepTextColor = input.color(color.white, "Low Sweep Label Text", group = GRP_CUSTOM, display = display.none)

color customEntryLineColor = input.color(color.rgb(255, 255, 255), "Entry Line", group = GRP_CUSTOM, display = display.none)
color customTargetLineColor = input.color(color.rgb(92, 129, 239), "TP Line", group = GRP_CUSTOM, display = display.none)
color customStopLineColor = input.color(color.rgb(236, 90, 111), "SL Line", group = GRP_CUSTOM, display = display.none)

color customProfitBoxFillColor = input.color(color.rgb(18, 188, 214), "TP Box Fill", group = GRP_CUSTOM, display = display.none)
color customProfitBoxBorderColor = input.color(color.rgb(92, 129, 239), "TP Box Border", group = GRP_CUSTOM, display = display.none)
color customStopBoxFillColor = input.color(color.rgb(190, 36, 50), "SL Box Fill", group = GRP_CUSTOM, display = display.none)
color customStopBoxBorderColor = input.color(color.rgb(236, 90, 111), "SL Box Border", group = GRP_CUSTOM, display = display.none)

color customTPResultLabelColor = input.color(color.rgb(48, 96, 255), "TP Result Label Background", group = GRP_CUSTOM, display = display.none)
color customSLResultLabelColor = input.color(color.rgb(247, 42, 70), "SL Result Label Background", group = GRP_CUSTOM, display = display.none)
color customTPResultTextColor = input.color(color.rgb(255, 255, 255), "TP Result Label Text", group = GRP_CUSTOM, display = display.none)
color customSLResultTextColor = input.color(color.rgb(255, 255, 255), "SL Result Label Text", group = GRP_CUSTOM, display = display.none)

color customDashboardBackground = input.color(color.rgb(5, 5, 8), "Dashboard Background", group = GRP_CUSTOM, display = display.none)
color customDashboardHeader = input.color(color.rgb(48, 96, 255), "Dashboard Header", group = GRP_CUSTOM, display = display.none)
color customDashboardBorder = input.color(color.rgb(48, 96, 255), "Dashboard Border", group = GRP_CUSTOM, display = display.none)
color customDashboardText = input.color(color.rgb(245, 245, 245), "Dashboard Main Text", group = GRP_CUSTOM, display = display.none)
color customDashboardMutedText = input.color(color.rgb(175, 175, 185), "Dashboard Muted Text", group = GRP_CUSTOM, display = display.none)

int signalLabelTransparency = input.int(
     0,
     "Signal Label Transparency",
     minval = 0,
     maxval = 70,
     tooltip = "Lower values create a stronger and more visible BUY/SELL signal label.",
     group = GRP_CUSTOM,
     display = display.none
)

float signalLabelOffsetATR = input.float(
     0.15,
     "Signal Label Offset (ATR)",
     minval = 0.00,
     maxval = 2.00,
     step = 0.05,
     tooltip = "Moves BUY labels below candles and SELL labels above candles.",
     group = GRP_CUSTOM,
     display = display.none
)

int resultLabelTransparency = input.int(
     0,
     "Result Label Transparency",
     minval = 0,
     maxval = 70,
     tooltip = "Lower values create a stronger TP HIT or SL HIT label.",
     group = GRP_CUSTOM,
     display = display.none
)

float resultLabelOffsetATR = input.float(
     0.20,
     "Result Label Offset (ATR)",
     minval = 0.00,
     maxval = 2.00,
     step = 0.05,
     tooltip = "Moves the result label away from the TP or SL line for better visibility.",
     group = GRP_CUSTOM,
     display = display.none
)

//──────────────────────────────────────────────────────────────────────
// EFFECTIVE VISUAL PROFILE
//──────────────────────────────────────────────────────────────────────
string effectiveLevelDisplayMode = visualProfile == "Clean" ? "Armed + Events" :
     visualProfile == "Minimal" or visualProfile == "Mobile" ? "Hidden" :
     levelDisplayMode

string effectiveSignalLabelStyle = visualProfile == "Clean" ? "Full" :
     visualProfile == "Minimal" or visualProfile == "Mobile" ? "Icon" :
     signalLabelStyle

string effectiveDashboardMode = not showCoreDashboard ? "Off" :
     visualProfile == "Clean" ? "Compact" :
     visualProfile == "Minimal" ? "Trade Only" :
     visualProfile == "Mobile" ? "Compact" :
     dashboardMode

bool effectiveShowSweepMarkers = showSweepMarkers and visualProfile != "Minimal" and visualProfile != "Mobile"
bool effectiveShowReclaimSignals = showReclaimSignals
bool effectiveShowPivotMarkers = showPivotMarkers and visualProfile == "Full"
bool effectiveShowHistoricalTrades = showHistoricalTrades and (visualProfile == "Full" or visualProfile == "Clean")
bool effectiveShowTradeResultLabels = showTradeResultLabels
bool effectiveShowTradeBoxes = showTradeBoxes
bool effectiveShowTradeLines = showTradeLines

int effectiveMaxSweepMarkers = visualProfile == "Full" ? maxSweepMarkers : math.min(maxSweepMarkers, 30)
int effectiveMaxReclaimLabels = visualProfile == "Mobile" ? math.min(maxReclaimLabels, 30) :
     visualProfile == "Minimal" ? math.min(maxReclaimLabels, 50) :
     visualProfile == "Clean" ? math.min(maxReclaimLabels, 75) :
     maxReclaimLabels

int effectiveMaxHistoricalTrades = visualProfile == "Clean" ? math.min(maxHistoricalTrades, 8) :
     visualProfile == "Full" ? maxHistoricalTrades :
     0

int effectiveTradeZoneTransparency = visualProfile == "Mobile" ? math.min(98, tradeZoneTransparency + 4) : tradeZoneTransparency
int effectiveTradeBorderTransparency = visualProfile == "Mobile" ? math.min(98, tradeBorderTransparency + 20) : tradeBorderTransparency
int effectiveTradeLineWidth = visualProfile == "Mobile" ? 1 : activeTradeLineWidth


//──────────────────────────────────────────────────────────────────────
// THEME COLORS
//──────────────────────────────────────────────────────────────────────
bool useCustomColors = colorMode == "Custom"

color themeHighFreshColor = switch theme
    "Ice Blue"   => color.rgb(72, 169, 255)
    "Monochrome" => color.rgb(215, 215, 215)
    => color.rgb(235, 64, 72)

color themeLowFreshColor = switch theme
    "Ice Blue"   => color.rgb(97, 220, 255)
    "Monochrome" => color.rgb(175, 175, 175)
    => color.rgb(245, 245, 245)

color themeHighArmedColor = switch theme
    "Ice Blue"   => color.rgb(255, 180, 55)
    "Monochrome" => color.rgb(255, 255, 255)
    => color.rgb(255, 92, 92)

color themeLowArmedColor = switch theme
    "Ice Blue"   => color.rgb(255, 220, 90)
    "Monochrome" => color.rgb(255, 255, 255)
    => color.rgb(255, 255, 255)

color themeHighSweptColor = switch theme
    "Ice Blue"   => color.rgb(255, 120, 55)
    "Monochrome" => color.rgb(255, 255, 255)
    => color.rgb(255, 179, 0)

color themeLowSweptColor = switch theme
    "Ice Blue"   => color.rgb(0, 235, 205)
    "Monochrome" => color.rgb(255, 255, 255)
    => color.rgb(0, 220, 150)

color themeSellReclaimColor = switch theme
    "Ice Blue"   => color.rgb(255, 92, 120)
    "Monochrome" => color.rgb(235, 235, 235)
    => color.rgb(239, 52, 73)

color themeBuyReclaimColor = switch theme
    "Ice Blue"   => color.rgb(54, 218, 255)
    "Monochrome" => color.rgb(255, 255, 255)
    => color.rgb(0, 210, 135)

color themeEntryLineColor = color.rgb(245, 245, 245)

color themeTargetLineColor = switch theme
    "Ice Blue"   => color.rgb(61, 205, 255)
    "Monochrome" => color.rgb(235, 235, 235)
    => color.rgb(0, 210, 135)

color themeStopLineColor = switch theme
    "Ice Blue"   => color.rgb(255, 105, 135)
    "Monochrome" => color.rgb(180, 180, 180)
    => color.rgb(239, 52, 73)

color highFreshColor = useCustomColors ? customHighFreshColor : themeHighFreshColor
color lowFreshColor = useCustomColors ? customLowFreshColor : themeLowFreshColor
color highArmedColor = useCustomColors ? customHighArmedColor : themeHighArmedColor
color lowArmedColor = useCustomColors ? customLowArmedColor : themeLowArmedColor
color highSweptColor = useCustomColors ? customHighSweptColor : themeHighSweptColor
color lowSweptColor = useCustomColors ? customLowSweptColor : themeLowSweptColor

color sellReclaimColor = useCustomColors ? customSellReclaimColor : themeSellReclaimColor
color buyReclaimColor = useCustomColors ? customBuyReclaimColor : themeBuyReclaimColor
color buySignalTextColor = useCustomColors ? customBuySignalTextColor : color.white
color sellSignalTextColor = useCustomColors ? customSellSignalTextColor : color.white

color highSweepLabelColor = useCustomColors ? customHighSweepLabelColor : themeHighSweptColor
color lowSweepLabelColor = useCustomColors ? customLowSweepLabelColor : themeLowSweptColor
color highSweepTextColor = useCustomColors ? customHighSweepTextColor : color.white
color lowSweepTextColor = useCustomColors ? customLowSweepTextColor : color.white

color entryLineColor = useCustomColors ? customEntryLineColor : themeEntryLineColor
color targetLineColor = useCustomColors ? customTargetLineColor : themeTargetLineColor
color stopLineColor = useCustomColors ? customStopLineColor : themeStopLineColor

color profitBoxFillColor = useCustomColors ? customProfitBoxFillColor : themeTargetLineColor
color profitBoxBorderColor = useCustomColors ? customProfitBoxBorderColor : themeTargetLineColor
color stopBoxFillColor = useCustomColors ? customStopBoxFillColor : themeStopLineColor
color stopBoxBorderColor = useCustomColors ? customStopBoxBorderColor : themeStopLineColor

color tpResultLabelColor = useCustomColors ? customTPResultLabelColor : themeTargetLineColor
color slResultLabelColor = useCustomColors ? customSLResultLabelColor : themeStopLineColor
color tpResultTextColor = useCustomColors ? customTPResultTextColor : color.white
color slResultTextColor = useCustomColors ? customSLResultTextColor : color.white

color dashboardBgBase = useCustomColors ? customDashboardBackground : color.rgb(10, 10, 12)
color dashboardHeaderColor = useCustomColors ? customDashboardHeader : themeHighFreshColor
color dashboardBorderBase = useCustomColors ? customDashboardBorder : color.white
color dashboardText = useCustomColors ? customDashboardText : color.rgb(240, 240, 240)
color mutedText = useCustomColors ? customDashboardMutedText : color.rgb(155, 155, 165)

color dashboardBg = color.new(dashboardBgBase, 12)
color dashboardBorder = color.new(dashboardBorderBase, 75)

//──────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
//──────────────────────────────────────────────────────────────────────
float atr = ta.atr(atrLength)
float safeATR = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
float effectiveMaxSweepDepthATR = math.max(maxSweepDepthATR, minSweepDepthATR)

int reclaimWindowBars = switch reclaimMode
    "Same Candle" => 0
    "Fast"        => 1
    "Flexible"    => 3
    => customReclaimBars

int effectiveSweepTimeout = math.max(sweepStateTimeout, reclaimWindowBars)

float reclaimCloseBufferATR = switch reclaimStrengthMode
    "Loose"    => 0.00
    "Balanced" => 0.02
    "Strict"   => 0.05
    => customCloseBufferATR

float reclaimCloseLocationThreshold = switch reclaimStrengthMode
    "Loose"    => 0.50
    "Balanced" => 0.60
    "Strict"   => 0.70
    => customCloseLocation

float reclaimBodyStrengthATR = switch reclaimStrengthMode
    "Loose"    => 0.03
    "Balanced" => 0.08
    "Strict"   => 0.15
    => customBodyStrengthATR

float reclaimWickThreshold = switch reclaimStrengthMode
    "Loose"    => 0.10
    "Balanced" => 0.18
    "Strict"   => 0.28
    => customWickRejection


float minimumQualityScore = switch qualityFilterMode
    "Loose"    => 50.0
    "Balanced" => 65.0
    "Strict"   => 80.0
    => customMinimumQuality * 1.0

float volumeAverage = ta.sma(volume, qualityVolumeLength)
float atrRegimeAverage = ta.sma(atr, qualityRegimeLength)

float chartBiasEMA = ta.ema(close, chartBiasLength)
float chartBiasSlope = chartBiasEMA - chartBiasEMA[1]

float confirmedHTFClose = request.security(
     syminfo.tickerid,
     higherTimeframe,
     close[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float confirmedHTFEMA = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, higherTimeframeBiasLength)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float confirmedHTFEMAPrevious = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, higherTimeframeBiasLength)[2],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

float confirmedHTFSlope = confirmedHTFEMA - confirmedHTFEMAPrevious
float pathAverage = ta.sma(math.abs(ta.change(close)), efficiencyLength)
float pathDistance = nz(pathAverage, 0.0) * efficiencyLength
float directionalDistance = math.abs(close - nz(close[efficiencyLength], close))
float marketEfficiency = pathDistance > 0.0 ? math.min(1.0, directionalDistance / pathDistance) : 0.0
float volatilityRatio = not na(atrRegimeAverage) and atrRegimeAverage > 0.0 ? atr / atrRegimeAverage : 1.0

float confirmedSwingHigh = ta.pivothigh(high, swingLeft, swingRight)
float confirmedSwingLow  = ta.pivotlow(low, swingLeft, swingRight)

int confirmedHighBar = bar_index - swingRight
int confirmedLowBar  = bar_index - swingRight

//──────────────────────────────────────────────────────────────────────
// LEVEL STORAGE
//──────────────────────────────────────────────────────────────────────
var array<float> highPrices = array.new_float()
var array<int>   highBornBars = array.new_int()
var array<int>   highStates = array.new_int()
var array<int>   highAttempts = array.new_int()
var array<int>   highSweepBars = array.new_int()
var array<float> highSweepDepths = array.new_float()
var array<float> highSweepExtremes = array.new_float()
var array<int>   highSweepKinds = array.new_int()
var array<int>   highReclaimBars = array.new_int()
var array<line>  highLines = array.new_line()

var array<float> lowPrices = array.new_float()
var array<int>   lowBornBars = array.new_int()
var array<int>   lowStates = array.new_int()
var array<int>   lowAttempts = array.new_int()
var array<int>   lowSweepBars = array.new_int()
var array<float> lowSweepDepths = array.new_float()
var array<float> lowSweepExtremes = array.new_float()
var array<int>   lowSweepKinds = array.new_int()
var array<int>   lowReclaimBars = array.new_int()
var array<line>  lowLines = array.new_line()

var array<label> sweepMarkers = array.new_label()
var array<label> reclaimLabels = array.new_label()

//──────────────────────────────────────────────────────────────────────
// DASHBOARD MEMORY
//──────────────────────────────────────────────────────────────────────
var string lastSweepSide = "None"
var string lastSweepType = "None"
var float lastSweepDepth = na
var string lastReclaimSignal = "None"
var int lastReclaimDelay = na
var float lastReclaimCloseLocation = na
var float lastReclaimBodyATR = na
var float lastQualityScore = na
var string lastQualityGrade = "None"
var float lastSweepComponent = na
var float lastCloseComponent = na
var float lastWickComponent = na
var float lastFreshnessComponent = na
var float lastVolumeComponent = na
var float lastDisplacementComponent = na
var float lastMarketComponent = na
var float lastCleanlinessComponent = na
var int lastAnySignalBar = na
var int lastBuySignalBar = na
var int lastSellSignalBar = na
var float lastBuySignalPrice = na
var float lastSellSignalPrice = na
var float lastExecutedSignalLevel = na
var string lastSignalBlockReason = "None"
var string currentBiasState = "Neutral"
var string currentMarketState = "Pass"

var bool tradeActive = false
var int activeTradeDirection = 0
var int activeTradeEntryBar = na
var float activeTradeEntry = na
var float activeTradeStop = na
var float activeTradeTarget = na
var float activeTradeRisk = na
var float activeTradeRR = na
var float activeTradeQuality = na
var string activeTradeGrade = "None"

var box activeProfitBox = na
var box activeStopBox = na
var line activeEntryLine = na
var line activeTargetLine = na
var line activeStopLine = na
var label activeTradeSignalLabel = na

var array<box> historicalProfitBoxes = array.new_box()
var array<box> historicalStopBoxes = array.new_box()
var array<line> historicalEntryLines = array.new_line()
var array<line> historicalTargetLines = array.new_line()
var array<line> historicalStopLines = array.new_line()
var array<label> historicalResultLabels = array.new_label()

var int totalTrades = 0
var int winningTrades = 0
var int losingTrades = 0
var float netR = 0.0
var int currentWinStreak = 0
var int currentLossStreak = 0
var int bestWinStreak = 0
var int bestLossStreak = 0
var string lastTradeResult = "None"
var float lastTradeR = na


var int lastClosedTradeDirection = 0


bool tradeOpenedThisBar = false
bool tradeClosedThisBar = false
bool tradeTPHit = false
bool tradeSLHit = false

//──────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
//──────────────────────────────────────────────────────────────────────
f_levelExists(array<float> prices, float newPrice, float tolerance) =>
    bool exists = false
    int count = array.size(prices)
    if count > 0
        for i = 0 to count - 1
            if math.abs(array.get(prices, i) - newPrice) <= tolerance
                exists := true
                break
    exists

f_removeLevel(
     array<float> prices,
     array<int> bornBars,
     array<int> states,
     array<int> attempts,
     array<int> sweepBars,
     array<float> sweepDepths,
     array<float> sweepExtremes,
     array<int> sweepKinds,
     array<int> reclaimBars,
     array<line> levelLines,
     int index
 ) =>
    line levelLine = array.get(levelLines, index)
    line.delete(levelLine)
    array.remove(prices, index)
    array.remove(bornBars, index)
    array.remove(states, index)
    array.remove(attempts, index)
    array.remove(sweepBars, index)
    array.remove(sweepDepths, index)
    array.remove(sweepExtremes, index)
    array.remove(sweepKinds, index)
    array.remove(reclaimBars, index)
    array.remove(levelLines, index)
    true

f_trimLevels(
     array<float> prices,
     array<int> bornBars,
     array<int> states,
     array<int> attempts,
     array<int> sweepBars,
     array<float> sweepDepths,
     array<float> sweepExtremes,
     array<int> sweepKinds,
     array<int> reclaimBars,
     array<line> levelLines,
     int maximumCount
 ) =>
    bool trimmed = false
    while array.size(prices) > maximumCount
        f_removeLevel(
             prices,
             bornBars,
             states,
             attempts,
             sweepBars,
             sweepDepths,
             sweepExtremes,
             sweepKinds,
             reclaimBars,
             levelLines,
             0
        )
        trimmed := true
    trimmed

f_addLevel(
     array<float> prices,
     array<int> bornBars,
     array<int> states,
     array<int> attempts,
     array<int> sweepBars,
     array<float> sweepDepths,
     array<float> sweepExtremes,
     array<int> sweepKinds,
     array<int> reclaimBars,
     array<line> levelLines,
     float newPrice,
     int newBornBar,
     color initialColor,
     float tolerance
 ) =>
    bool added = false
    if not f_levelExists(prices, newPrice, tolerance)
        line newLine = line.new(
             x1 = newBornBar,
             y1 = newPrice,
             x2 = bar_index,
             y2 = newPrice,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = initialColor,
             style = line.style_dotted,
             width = levelWidth
        )
        array.push(prices, newPrice)
        array.push(bornBars, newBornBar)
        array.push(states, STATE_FRESH)
        array.push(attempts, 0)
        array.push(sweepBars, -1)
        array.push(sweepDepths, na)
        array.push(sweepExtremes, na)
        array.push(sweepKinds, SWEEP_NONE)
        array.push(reclaimBars, -1)
        array.push(levelLines, newLine)
        added := true
    added

f_resetSweepMetadata(
     array<int> sweepBars,
     array<float> sweepDepths,
     array<float> sweepExtremes,
     array<int> sweepKinds,
     array<int> reclaimBars,
     int index
 ) =>
    array.set(sweepBars, index, -1)
    array.set(sweepDepths, index, na)
    array.set(sweepExtremes, index, na)
    array.set(sweepKinds, index, SWEEP_NONE)
    array.set(reclaimBars, index, -1)
    true

f_ageTransparency(int age, int maximumAge) =>
    int transparency = 0
    if fadeOlderLevels and maximumAge > 0
        float ageRatio = math.min(1.0, math.max(0.0, age * 1.0 / maximumAge))
        transparency := int(math.round(ageRatio * 72.0))
    transparency


f_levelStateVisible(int state) =>
    bool visible = switch effectiveLevelDisplayMode
        "All Active"     => state == STATE_FRESH or state == STATE_ARMED or state == STATE_SWEPT or state == STATE_RECLAIMED
        "Armed + Events" => state == STATE_ARMED or state == STATE_SWEPT or state == STATE_RECLAIMED
        "Events Only"    => state == STATE_SWEPT or state == STATE_RECLAIMED
        => false
    visible

f_levelLineStyle(int state) =>
    string result = switch levelLineStyleMode
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => state == STATE_FRESH ? line.style_dotted : line.style_solid
    result

f_textSize(string selectedSize) =>
    string result = switch selectedSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small
    result

f_sweepLabelSize() =>
    f_textSize(sweepLabelSize)

f_signalLabelSize() =>
    f_textSize(signalLabelSize)

f_resultLabelSize() =>
    f_textSize(resultLabelSize)

f_dashboardHeaderSize() =>
    f_textSize(dashboardHeaderTextSize)

f_dashboardBodySize() =>
    f_textSize(dashboardBodyTextSize)

f_highSweepKind(float levelPrice) =>
    float bodyHigh = math.max(open, close)
    int kind = bodyHigh > levelPrice ? SWEEP_BODY : SWEEP_WICK
    kind

f_lowSweepKind(float levelPrice) =>
    float bodyLow = math.min(open, close)
    int kind = bodyLow < levelPrice ? SWEEP_BODY : SWEEP_WICK
    kind

f_modeAcceptsKind(int kind) =>
    bool accepted = switch sweepDetectionMode
        "Wick Only"     => kind == SWEEP_WICK
        "Body Required" => kind == SWEEP_BODY
        => kind == SWEEP_WICK or kind == SWEEP_BODY
    accepted

f_isNewHighPenetration(float levelPrice) =>
    bool crossed = barstate.isconfirmed and high > levelPrice and nz(high[1], levelPrice) <= levelPrice
    crossed

f_isNewLowPenetration(float levelPrice) =>
    bool crossed = barstate.isconfirmed and low < levelPrice and nz(low[1], levelPrice) >= levelPrice
    crossed

f_isValidHighSweep(float levelPrice, int attempts) =>
    float depthATR = (high - levelPrice) / safeATR
    int kind = f_highSweepKind(levelPrice)
    bool depthValid = depthATR >= minSweepDepthATR and depthATR <= effectiveMaxSweepDepthATR
    bool attemptValid = not firstInteractionOnly or attempts == 0
    bool valid = f_isNewHighPenetration(levelPrice) and depthValid and attemptValid and f_modeAcceptsKind(kind)
    valid

f_isValidLowSweep(float levelPrice, int attempts) =>
    float depthATR = (levelPrice - low) / safeATR
    int kind = f_lowSweepKind(levelPrice)
    bool depthValid = depthATR >= minSweepDepthATR and depthATR <= effectiveMaxSweepDepthATR
    bool attemptValid = not firstInteractionOnly or attempts == 0
    bool valid = f_isNewLowPenetration(levelPrice) and depthValid and attemptValid and f_modeAcceptsKind(kind)
    valid

f_findHighSweepIndex() =>
    int selected = -1
    float bestDepth = 1000000.0
    int count = array.size(highPrices)
    if count > 0 and barstate.isconfirmed
        for i = 0 to count - 1
            int state = array.get(highStates, i)
            if state == STATE_FRESH or state == STATE_ARMED
                float levelPrice = array.get(highPrices, i)
                int attempts = array.get(highAttempts, i)
                if f_isValidHighSweep(levelPrice, attempts)
                    float depthATR = (high - levelPrice) / safeATR
                    if selected == -1 or depthATR < bestDepth
                        selected := i
                        bestDepth := depthATR
    selected

f_findLowSweepIndex() =>
    int selected = -1
    float bestDepth = 1000000.0
    int count = array.size(lowPrices)
    if count > 0 and barstate.isconfirmed
        for i = 0 to count - 1
            int state = array.get(lowStates, i)
            if state == STATE_FRESH or state == STATE_ARMED
                float levelPrice = array.get(lowPrices, i)
                int attempts = array.get(lowAttempts, i)
                if f_isValidLowSweep(levelPrice, attempts)
                    float depthATR = (levelPrice - low) / safeATR
                    if selected == -1 or depthATR < bestDepth
                        selected := i
                        bestDepth := depthATR
    selected

f_sweepImportanceScore(int levelAge, int attemptNumber, float depthATR, int kind) =>
    float ageReference = math.max(10.0, (swingLeft + swingRight) * 2.0)
    float ageScore = math.min(30.0, levelAge / ageReference * 30.0)

    float depthRange = math.max(0.01, effectiveMaxSweepDepthATR - minSweepDepthATR)
    float optimalDepth = minSweepDepthATR + depthRange * 0.35
    float depthDistance = math.abs(depthATR - optimalDepth) / depthRange
    float depthScore = math.max(0.0, 30.0 * (1.0 - depthDistance))

    float interactionScore = attemptNumber <= 1 ? 20.0 : 5.0
    float structureScore = swingMode == "Structural" ? 15.0 :
         swingMode == "Balanced" ? 12.0 :
         swingMode == "Reactive" ? 8.0 :
         math.min(15.0, (swingLeft + swingRight) * 1.0)

    float typeScore = kind == SWEEP_WICK ? 5.0 : 3.0
    math.min(100.0, ageScore + depthScore + interactionScore + structureScore + typeScore)

f_deleteLatestSweepMarker() =>
    bool deleted = false
    if array.size(sweepMarkers) > 0
        label latestMarker = array.pop(sweepMarkers)
        label.delete(latestMarker)
        deleted := true
    deleted

f_addSweepMarker(bool isHighSweep, float levelPrice, float extremePrice, int kind, float depthATR, float importanceScore) =>
    bool markerAdded = false
    bool importancePass = sweepLabelFilter == "All Valid" or importanceScore >= minimumSweepImportance
    if effectiveShowSweepMarkers and importancePass
        string sideText = isHighSweep ? "SWEEP HIGH" : "SWEEP LOW"
        string kindText = kind == SWEEP_BODY ? "BODY" : "WICK"
        string markerText = sideText + "\n" + str.tostring(levelPrice, format.mintick)
        label marker = label.new(
             x = bar_index,
             y = levelPrice,
             text = markerText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = isHighSweep ? label.style_label_down : label.style_label_up,
             color = color.new(isHighSweep ? highSweepLabelColor : lowSweepLabelColor, 8),
             textcolor = isHighSweep ? highSweepTextColor : lowSweepTextColor,
             size = f_sweepLabelSize(),
             tooltip = (isHighSweep ? "Important swing-high liquidity sweep" : "Important swing-low liquidity sweep") +
                 "\nLevel: " + str.tostring(levelPrice, format.mintick) +
                 "\nExtreme: " + str.tostring(extremePrice, format.mintick) +
                 "\nDepth: " + str.tostring(depthATR, "#.###") + " ATR" +
                 "\nType: " + kindText +
                 "\nImportance: " + str.tostring(importanceScore, "#") + "/100"
        )
        label.set_text_formatting(marker, text.format_bold + text.format_italic)
        array.push(sweepMarkers, marker)
        while array.size(sweepMarkers) > effectiveMaxSweepMarkers
            label oldestMarker = array.shift(sweepMarkers)
            label.delete(oldestMarker)
        markerAdded := true
    markerAdded


f_candleRange() =>
    math.max(high - low, syminfo.mintick)

f_bullCloseLocation() =>
    (close - low) / f_candleRange()

f_bearCloseLocation() =>
    (high - close) / f_candleRange()

f_bodyATR() =>
    math.abs(close - open) / safeATR

f_lowerWickRatio() =>
    (math.min(open, close) - low) / f_candleRange()

f_upperWickRatio() =>
    (high - math.max(open, close)) / f_candleRange()


f_clamp01(float value) =>
    math.min(1.0, math.max(0.0, value))

f_qualityGrade(float score) =>
    string grade = score >= 80.0 ? "A+" : score >= 65.0 ? "A" : "B"
    grade

f_gradeTransparency(string grade) =>
    int result = grade == "A+" ? 0 : grade == "A" ? 3 : 8
    result

f_sweepDepthComponent(float depthATR) =>
    float rangeATR = math.max(effectiveMaxSweepDepthATR - minSweepDepthATR, 0.01)
    float normalized = f_clamp01((depthATR - minSweepDepthATR) / rangeATR)
    float idealPosition = 0.35
    float distanceFromIdeal = math.abs(normalized - idealPosition)
    float quality = f_clamp01(1.0 - distanceFromIdeal / 0.65)
    quality * 15.0

f_closeComponent(bool isBullish) =>
    float closeLocation = isBullish ? f_bullCloseLocation() : f_bearCloseLocation()
    f_clamp01((closeLocation - 0.45) / 0.55) * 20.0

f_wickComponent(bool isBullish, int sweepKind, int barsAfterSweep) =>
    float currentWickRatio = isBullish ? f_lowerWickRatio() : f_upperWickRatio()
    float directWickQuality = f_clamp01(currentWickRatio / 0.45)
    float historicalBase = sweepKind == SWEEP_WICK ? 0.72 : 0.42
    float combinedQuality = barsAfterSweep == 0 ? directWickQuality : math.max(historicalBase, directWickQuality * 0.65)
    f_clamp01(combinedQuality) * 15.0

f_freshnessComponent(int bornBar) =>
    int levelAge = math.max(0, bar_index - bornBar)
    float ageRatio = f_clamp01(levelAge * 1.0 / math.max(maxLevelAge, 1))
    math.pow(1.0 - ageRatio, 0.65) * 10.0

f_volumeComponent() =>
    float score = 5.0
    bool volumeAvailable = not na(volume) and volume > 0 and not na(volumeAverage) and volumeAverage > 0
    if includeVolumeInScore and volumeAvailable
        float relativeVolume = volume / volumeAverage
        score := f_clamp01((relativeVolume - 0.55) / 1.25) * 10.0
    else if not includeVolumeInScore
        score := 10.0
    score

f_displacementComponent(bool isBullish, float levelPrice) =>
    float bodyQuality = f_clamp01(f_bodyATR() / 0.55)
    float reclaimDistanceATR = math.abs(close - levelPrice) / safeATR
    float distanceQuality = f_clamp01(reclaimDistanceATR / 0.45)
    (bodyQuality * 0.65 + distanceQuality * 0.35) * 15.0

f_marketComponent() =>
    float candleRangeATR = f_candleRange() / safeATR
    float rangeQuality = candleRangeATR <= 1.20 ? f_clamp01(candleRangeATR / 1.20) : f_clamp01(1.0 - (candleRangeATR - 1.20) / 2.80)
    float atrRegime = not na(atrRegimeAverage) and atrRegimeAverage > 0 ? safeATR / atrRegimeAverage : 1.0
    float regimeQuality = f_clamp01((atrRegime - 0.65) / 0.85)
    (rangeQuality * 0.60 + regimeQuality * 0.40) * 10.0

f_cleanlinessComponent(int attempts) =>
    float result = attempts <= 1 ? 5.0 : attempts == 2 ? 3.0 : 1.0
    result

f_highQualityScore(int index) =>
    float score = 0.0
    if index >= 0 and index < array.size(highPrices)
        float levelPrice = array.get(highPrices, index)
        float depthATR = array.get(highSweepDepths, index)
        int sweepKind = array.get(highSweepKinds, index)
        int sweepBar = array.get(highSweepBars, index)
        int bornBar = array.get(highBornBars, index)
        int attempts = array.get(highAttempts, index)
        int barsAfterSweep = math.max(0, bar_index - sweepBar)
        score := f_sweepDepthComponent(depthATR) +
             f_closeComponent(false) +
             f_wickComponent(false, sweepKind, barsAfterSweep) +
             f_freshnessComponent(bornBar) +
             f_volumeComponent() +
             f_displacementComponent(false, levelPrice) +
             f_marketComponent() +
             f_cleanlinessComponent(attempts)
    math.min(100.0, math.max(0.0, math.round(score)))

f_lowQualityScore(int index) =>
    float score = 0.0
    if index >= 0 and index < array.size(lowPrices)
        float levelPrice = array.get(lowPrices, index)
        float depthATR = array.get(lowSweepDepths, index)
        int sweepKind = array.get(lowSweepKinds, index)
        int sweepBar = array.get(lowSweepBars, index)
        int bornBar = array.get(lowBornBars, index)
        int attempts = array.get(lowAttempts, index)
        int barsAfterSweep = math.max(0, bar_index - sweepBar)
        score := f_sweepDepthComponent(depthATR) +
             f_closeComponent(true) +
             f_wickComponent(true, sweepKind, barsAfterSweep) +
             f_freshnessComponent(bornBar) +
             f_volumeComponent() +
             f_displacementComponent(true, levelPrice) +
             f_marketComponent() +
             f_cleanlinessComponent(attempts)
    math.min(100.0, math.max(0.0, math.round(score)))

f_isValidHighReclaim(int index) =>
    bool valid = false
    if index >= 0 and index < array.size(highPrices) and barstate.isconfirmed
        int state = array.get(highStates, index)
        int sweepBar = array.get(highSweepBars, index)
        if state == STATE_SWEPT and sweepBar >= 0
            float levelPrice = array.get(highPrices, index)
            int barsAfterSweep = bar_index - sweepBar
            bool windowPass = barsAfterSweep >= 0 and barsAfterSweep <= reclaimWindowBars
            bool closePass = close <= levelPrice - safeATR * reclaimCloseBufferATR
            bool locationPass = f_bearCloseLocation() >= reclaimCloseLocationThreshold
            bool bodyPass = f_bodyATR() >= reclaimBodyStrengthATR
            bool directionPass = not requireDirectionalCandle or close < open
            bool sameBar = barsAfterSweep == 0
            bool wickPass = not requireSameCandleWick or not sameBar or f_upperWickRatio() >= reclaimWickThreshold
            valid := windowPass and closePass and locationPass and bodyPass and directionPass and wickPass
    valid

f_isValidLowReclaim(int index) =>
    bool valid = false
    if index >= 0 and index < array.size(lowPrices) and barstate.isconfirmed
        int state = array.get(lowStates, index)
        int sweepBar = array.get(lowSweepBars, index)
        if state == STATE_SWEPT and sweepBar >= 0
            float levelPrice = array.get(lowPrices, index)
            int barsAfterSweep = bar_index - sweepBar
            bool windowPass = barsAfterSweep >= 0 and barsAfterSweep <= reclaimWindowBars
            bool closePass = close >= levelPrice + safeATR * reclaimCloseBufferATR
            bool locationPass = f_bullCloseLocation() >= reclaimCloseLocationThreshold
            bool bodyPass = f_bodyATR() >= reclaimBodyStrengthATR
            bool directionPass = not requireDirectionalCandle or close > open
            bool sameBar = barsAfterSweep == 0
            bool wickPass = not requireSameCandleWick or not sameBar or f_lowerWickRatio() >= reclaimWickThreshold
            valid := windowPass and closePass and locationPass and bodyPass and directionPass and wickPass
    valid




f_dynamicSignalMessage(bool isBullish, float qualityScore, float levelPrice) =>
    string directionText = isBullish ? "BUY" : "SELL"
    string result = "SWEEP RECLAIM | " + directionText +
         " | " + syminfo.ticker +
         " | TF " + timeframe.period +
         " | Grade " + f_qualityGrade(qualityScore) +
         " | Quality " + str.tostring(qualityScore, "#") + "/100" +
         " | Level " + str.tostring(levelPrice, format.mintick) +
         " | Close " + str.tostring(close, format.mintick)
    result

f_dynamicTradeOpenMessage() =>
    string directionText = activeTradeDirection == 1 ? "BUY" : activeTradeDirection == -1 ? "SELL" : "None"
    string result = "SWEEP RECLAIM | TRADE OPEN" +
         " | " + syminfo.ticker +
         " | TF " + timeframe.period +
         " | " + directionText +
         " | Entry " + str.tostring(activeTradeEntry, format.mintick) +
         " | SL " + str.tostring(activeTradeStop, format.mintick) +
         " | TP " + str.tostring(activeTradeTarget, format.mintick) +
         " | RR " + str.tostring(activeTradeRR, "#.##") +
         " | SL Mode " + stopLossMode +
         " | Grade " + activeTradeGrade +
         " | Quality " + str.tostring(activeTradeQuality, "#") + "/100"
    result

f_dynamicTradeResultMessage() =>
    string directionText = lastClosedTradeDirection == 1 ? "BUY" : lastClosedTradeDirection == -1 ? "SELL" : "None"
    string result = "SWEEP RECLAIM | " + lastTradeResult +
         " | " + syminfo.ticker +
         " | TF " + timeframe.period +
         " | " + directionText +
         " | Result " + str.tostring(lastTradeR, "#.##") + "R"
    result

f_deleteActiveTradeObjects() =>
    if not na(activeProfitBox)
        box.delete(activeProfitBox)
    if not na(activeStopBox)
        box.delete(activeStopBox)
    if not na(activeEntryLine)
        line.delete(activeEntryLine)
    if not na(activeTargetLine)
        line.delete(activeTargetLine)
    if not na(activeStopLine)
        line.delete(activeStopLine)
    true

f_tradeDirectionText(int direction) =>
    direction == 1 ? "BUY" : direction == -1 ? "SELL" : "None"

f_directionPass(bool isBullish) =>
    bool pass = signalDirectionMode == "Both" or
         (signalDirectionMode == "Long Only" and isBullish) or
         (signalDirectionMode == "Short Only" and not isBullish)
    pass

f_chartBiasPass(bool isBullish) =>
    bool slopePass = not requireBiasSlope or (isBullish ? chartBiasSlope > 0.0 : chartBiasSlope < 0.0)
    bool sidePass = isBullish ? close > chartBiasEMA : close < chartBiasEMA
    sidePass and slopePass

f_htfBiasPass(bool isBullish) =>
    bool slopePass = not requireBiasSlope or (isBullish ? confirmedHTFSlope > 0.0 : confirmedHTFSlope < 0.0)
    bool sidePass = isBullish ? confirmedHTFClose > confirmedHTFEMA : confirmedHTFClose < confirmedHTFEMA
    sidePass and slopePass

f_biasPass(bool isBullish) =>
    bool pass = switch trendBiasMode
        "Chart EMA"             => f_chartBiasPass(isBullish)
        "Higher Timeframe EMA"  => f_htfBiasPass(isBullish)
        "Combined EMA"          => f_chartBiasPass(isBullish) and f_htfBiasPass(isBullish)
        => true
    pass

f_marketPass() =>
    bool volatilityPass = volatilityRatio >= minimumVolatilityRatio and volatilityRatio <= math.max(maximumVolatilityRatio, minimumVolatilityRatio)
    bool efficiencyPass = marketEfficiency >= minimumEfficiency
    bool pass = switch marketFilterMode
        "Volatility" => volatilityPass
        "Efficiency" => efficiencyPass
        "Combined"   => volatilityPass and efficiencyPass
        => true
    pass

f_cooldownPass(bool isBullish) =>
    bool pass = true
    if cooldownMode == "Any Signal"
        pass := na(lastAnySignalBar) or bar_index - lastAnySignalBar > signalCooldownBars
    else if cooldownMode == "Same Direction"
        int directionBar = isBullish ? lastBuySignalBar : lastSellSignalBar
        pass := na(directionBar) or bar_index - directionBar > signalCooldownBars
    pass

f_clusterPass(bool isBullish) =>
    float previousPrice = isBullish ? lastBuySignalPrice : lastSellSignalPrice
    bool pass = not useSignalClusterFilter or na(previousPrice) or math.abs(close - previousPrice) / safeATR >= minimumSignalDistanceATR
    pass

f_duplicateBarPass() =>
    not blockDuplicateSignalBar or na(lastAnySignalBar) or lastAnySignalBar != bar_index

f_signalBlockReason(bool isBullish) =>
    string reason = "Pass"
    if not f_directionPass(isBullish)
        reason := "Direction"
    else if not f_biasPass(isBullish)
        reason := "Trend Bias"
    else if not f_marketPass()
        reason := "Market Condition"
    else if enableTradeModel and blockSignalsDuringActiveTrade and tradeActive
        reason := "Active Trade"
    else if enableTradeModel and not allowSignalOnExitBar and tradeClosedThisBar
        reason := "Exit Bar"
    else if not f_cooldownPass(isBullish)
        reason := "Cooldown"
    else if not f_clusterPass(isBullish)
        reason := "Signal Cluster"
    else if not f_duplicateBarPass()
        reason := "Duplicate Bar"
    reason

f_consumeHighCandidate(int index) =>
    bool consumed = false
    if index >= 0 and index < array.size(highStates)
        array.set(highStates, index, STATE_CONSUMED)
        line candidateLine = array.get(highLines, index)
        line.set_color(candidateLine, color.new(sellReclaimColor, 100))
        consumed := true
    consumed

f_consumeLowCandidate(int index) =>
    bool consumed = false
    if index >= 0 and index < array.size(lowStates)
        array.set(lowStates, index, STATE_CONSUMED)
        line candidateLine = array.get(lowLines, index)
        line.set_color(candidateLine, color.new(buyReclaimColor, 100))
        consumed := true
    consumed

f_isQualifiedHighReclaim(int index) =>
    bool qualified = f_isValidHighReclaim(index)
    if qualified
        qualified := f_highQualityScore(index) >= minimumQualityScore
    qualified

f_isQualifiedLowReclaim(int index) =>
    bool qualified = f_isValidLowReclaim(index)
    if qualified
        qualified := f_lowQualityScore(index) >= minimumQualityScore
    qualified

f_findHighReclaimIndex() =>
    int selected = -1
    float bestQuality = -1.0
    float nearestDistance = 1000000.0
    int count = array.size(highPrices)
    if count > 0
        for i = 0 to count - 1
            if f_isQualifiedHighReclaim(i)
                float qualityScore = f_highQualityScore(i)
                float distanceATR = math.abs(close - array.get(highPrices, i)) / safeATR
                bool choose = signalSelectionMode == "Highest Quality" ?
                     (selected == -1 or qualityScore > bestQuality or (qualityScore == bestQuality and distanceATR < nearestDistance)) :
                     (selected == -1 or distanceATR < nearestDistance)
                if choose
                    selected := i
                    bestQuality := qualityScore
                    nearestDistance := distanceATR
    selected

f_findLowReclaimIndex() =>
    int selected = -1
    float bestQuality = -1.0
    float nearestDistance = 1000000.0
    int count = array.size(lowPrices)
    if count > 0
        for i = 0 to count - 1
            if f_isQualifiedLowReclaim(i)
                float qualityScore = f_lowQualityScore(i)
                float distanceATR = math.abs(close - array.get(lowPrices, i)) / safeATR
                bool choose = signalSelectionMode == "Highest Quality" ?
                     (selected == -1 or qualityScore > bestQuality or (qualityScore == bestQuality and distanceATR < nearestDistance)) :
                     (selected == -1 or distanceATR < nearestDistance)
                if choose
                    selected := i
                    bestQuality := qualityScore
                    nearestDistance := distanceATR
    selected

f_addReclaimLabel(
     bool isBullish,
     float levelPrice,
     float sweepDepthATR,
     int barsAfterSweep,
     float qualityScore,
     float sweepScore,
     float closeScore,
     float wickScore,
     float freshnessScore,
     float volumeScore,
     float displacementScore,
     float marketScore,
     float cleanlinessScore
 ) =>
    bool labelAdded = false
    if effectiveShowReclaimSignals
        float closeLocation = isBullish ? f_bullCloseLocation() : f_bearCloseLocation()
        float wickRatio = isBullish ? f_lowerWickRatio() : f_upperWickRatio()
        string grade = f_qualityGrade(qualityScore)
        string signalText = isBullish ? "BUY RECLAIM" : "SELL RECLAIM"
        string compactSignalText = isBullish ? "BUY" : "SELL"
        string directionIcon = isBullish ? "▲" : "▼"
        string gradeText = showGradeOnLabels ? grade + " " : ""
        string qualityText = showScoreOnLabels ? str.tostring(qualityScore, "#") + "/100" : ""
        string fullScoreText = showScoreOnLabels ? "\nQUALITY • " + qualityText : ""
        string compactScoreText = showScoreOnLabels ? " • " + str.tostring(qualityScore, "#") : ""
        string finalText = switch effectiveSignalLabelStyle
            "Compact" => directionIcon + " " + gradeText + compactSignalText + compactScoreText
            "Icon"    => directionIcon + " " + compactSignalText + (showScoreOnLabels ? "\n" + str.tostring(qualityScore, "#") : "")
            => directionIcon + " " + gradeText + signalText + " " + directionIcon + fullScoreText
        int labelTransparency = math.max(signalLabelTransparency, f_gradeTransparency(grade))
        float signalLabelY = isBullish ? low - safeATR * signalLabelOffsetATR : high + safeATR * signalLabelOffsetATR
        label signalLabel = label.new(
             x = bar_index,
             y = signalLabelY,
             text = finalText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = isBullish ? label.style_label_up : label.style_label_down,
             color = color.new(isBullish ? buyReclaimColor : sellReclaimColor, labelTransparency),
             textcolor = isBullish ? buySignalTextColor : sellSignalTextColor,
             size = f_signalLabelSize(),
             tooltip = (isBullish ? "CONFIRMED BULLISH SWEEP RECLAIM" : "CONFIRMED BEARISH SWEEP RECLAIM") +
                 "\nGrade: " + grade +
                 "\nQuality Score: " + str.tostring(qualityScore, "#") + "/100" +
                 "\nLevel: " + str.tostring(levelPrice, format.mintick) +
                 "\nSweep Depth: " + str.tostring(sweepDepthATR, "#.###") + " ATR" +
                 "\nReclaim Delay: " + str.tostring(barsAfterSweep) + " bar(s)" +
                 "\nClose Location: " + str.tostring(closeLocation * 100.0, "#.0") + "%" +
                 "\nBody Strength: " + str.tostring(f_bodyATR(), "#.###") + " ATR" +
                 "\nWick Rejection: " + str.tostring(wickRatio * 100.0, "#.0") + "%" +
                 "\n──────────────" +
                 "\nSweep Depth: " + str.tostring(sweepScore, "#.0") + "/15" +
                 "\nReclaim Close: " + str.tostring(closeScore, "#.0") + "/20" +
                 "\nWick Rejection: " + str.tostring(wickScore, "#.0") + "/15" +
                 "\nLevel Freshness: " + str.tostring(freshnessScore, "#.0") + "/10" +
                 "\nRelative Volume: " + str.tostring(volumeScore, "#.0") + "/10" +
                 "\nDisplacement: " + str.tostring(displacementScore, "#.0") + "/15" +
                 "\nMarket Condition: " + str.tostring(marketScore, "#.0") + "/10" +
                 "\nLevel Cleanliness: " + str.tostring(cleanlinessScore, "#.0") + "/5"
        )
        label.set_text_formatting(signalLabel, text.format_bold + text.format_italic)
        array.push(reclaimLabels, signalLabel)
        while array.size(reclaimLabels) > effectiveMaxReclaimLabels
            label oldestLabel = array.shift(reclaimLabels)
            label.delete(oldestLabel)
        labelAdded := true
    labelAdded

f_processHighReclaims(int selectedIndex, bool blockSignal) =>
    bool anyProcessed = false
    int count = array.size(highPrices)
    if count > 0 and not blockSignal
        for i = 0 to count - 1
            bool selected = i == selectedIndex
            if selected and f_isQualifiedHighReclaim(i)
                float levelPrice = array.get(highPrices, i)
                float depthATR = array.get(highSweepDepths, i)
                int barsAfterSweep = bar_index - array.get(highSweepBars, i)
                int sweepKind = array.get(highSweepKinds, i)
                int bornBar = array.get(highBornBars, i)
                int attempts = array.get(highAttempts, i)
                float sweepScore = f_sweepDepthComponent(depthATR)
                float closeScore = f_closeComponent(false)
                float wickScore = f_wickComponent(false, sweepKind, barsAfterSweep)
                float freshnessScore = f_freshnessComponent(bornBar)
                float volumeScore = f_volumeComponent()
                float displacementScore = f_displacementComponent(false, levelPrice)
                float marketScore = f_marketComponent()
                float cleanlinessScore = f_cleanlinessComponent(attempts)
                float qualityScore = math.min(100.0, math.max(0.0, math.round(
                     sweepScore + closeScore + wickScore + freshnessScore +
                     volumeScore + displacementScore + marketScore + cleanlinessScore
                )))
                array.set(highStates, i, STATE_RECLAIMED)
                array.set(highReclaimBars, i, bar_index)
                line levelLine = array.get(highLines, i)
                line.set_color(levelLine, sellReclaimColor)
                line.set_width(levelLine, math.min(4, levelWidth + 2))
                line.set_style(levelLine, line.style_solid)
                f_addReclaimLabel(
                     false, levelPrice, depthATR, barsAfterSweep, qualityScore,
                     sweepScore, closeScore, wickScore, freshnessScore,
                     volumeScore, displacementScore, marketScore, cleanlinessScore
                )
                anyProcessed := true
    anyProcessed

f_processLowReclaims(int selectedIndex, bool blockSignal) =>
    bool anyProcessed = false
    int count = array.size(lowPrices)
    if count > 0 and not blockSignal
        for i = 0 to count - 1
            bool selected = i == selectedIndex
            if selected and f_isQualifiedLowReclaim(i)
                float levelPrice = array.get(lowPrices, i)
                float depthATR = array.get(lowSweepDepths, i)
                int barsAfterSweep = bar_index - array.get(lowSweepBars, i)
                int sweepKind = array.get(lowSweepKinds, i)
                int bornBar = array.get(lowBornBars, i)
                int attempts = array.get(lowAttempts, i)
                float sweepScore = f_sweepDepthComponent(depthATR)
                float closeScore = f_closeComponent(true)
                float wickScore = f_wickComponent(true, sweepKind, barsAfterSweep)
                float freshnessScore = f_freshnessComponent(bornBar)
                float volumeScore = f_volumeComponent()
                float displacementScore = f_displacementComponent(true, levelPrice)
                float marketScore = f_marketComponent()
                float cleanlinessScore = f_cleanlinessComponent(attempts)
                float qualityScore = math.min(100.0, math.max(0.0, math.round(
                     sweepScore + closeScore + wickScore + freshnessScore +
                     volumeScore + displacementScore + marketScore + cleanlinessScore
                )))
                array.set(lowStates, i, STATE_RECLAIMED)
                array.set(lowReclaimBars, i, bar_index)
                line levelLine = array.get(lowLines, i)
                line.set_color(levelLine, buyReclaimColor)
                line.set_width(levelLine, math.min(4, levelWidth + 2))
                line.set_style(levelLine, line.style_solid)
                f_addReclaimLabel(
                     true, levelPrice, depthATR, barsAfterSweep, qualityScore,
                     sweepScore, closeScore, wickScore, freshnessScore,
                     volumeScore, displacementScore, marketScore, cleanlinessScore
                )
                anyProcessed := true
    anyProcessed

f_countState(array<int> states, int targetState) =>
    int result = 0
    int count = array.size(states)
    if count > 0
        for i = 0 to count - 1
            if array.get(states, i) == targetState
                result += 1
    result

//──────────────────────────────────────────────────────────────────────
// LEVEL UPDATE FUNCTIONS
//──────────────────────────────────────────────────────────────────────
f_updateHighLevels(int selectedIndex, bool blockSweep) =>
    int i = array.size(highPrices) - 1
    while i >= 0
        float levelPrice = array.get(highPrices, i)
        int bornBar = array.get(highBornBars, i)
        int levelState = array.get(highStates, i)
        int levelAge = bar_index - bornBar
        int attempts = array.get(highAttempts, i)
        int storedSweepBar = array.get(highSweepBars, i)
        int storedReclaimBar = array.get(highReclaimBars, i)
        line levelLine = array.get(highLines, i)

        bool expired = levelAge > maxLevelAge
        bool consumed = levelState == STATE_CONSUMED
        bool sweepTimedOut = levelState == STATE_SWEPT and storedSweepBar >= 0 and bar_index - storedSweepBar > effectiveSweepTimeout
        bool reclaimedExpired = levelState == STATE_RECLAIMED and storedReclaimBar >= 0 and bar_index - storedReclaimBar > reclaimedLevelHoldBars
        bool newPenetration = (levelState == STATE_FRESH or levelState == STATE_ARMED) and f_isNewHighPenetration(levelPrice)
        bool validSweep = f_isValidHighSweep(levelPrice, attempts)
        bool selectedSweep = validSweep and (multiLevelSelection == "All Valid Levels" or i == selectedIndex)
        bool acceptedSweep = selectedSweep and not blockSweep
        bool confirmedBreakout = barstate.isconfirmed and close > levelPrice + safeATR * breakoutInvalidationATR
        bool removeNow = false

        bool lifecycleHandled = false
        if expired or reclaimedExpired or consumed
            removeNow := true
            lifecycleHandled := true
        else
            if sweepTimedOut
                bool timeoutHandled = false
                if firstInteractionOnly
                    removeNow := true
                    timeoutHandled := true
                else
                    levelState := STATE_ARMED
                    array.set(highStates, i, levelState)
                    f_resetSweepMetadata(highSweepBars, highSweepDepths, highSweepExtremes, highSweepKinds, highReclaimBars, i)
                    timeoutHandled := true

            if not removeNow and (levelState == STATE_FRESH or levelState == STATE_ARMED)
                bool enteredArmedZone = high >= levelPrice - safeATR * armDistanceATR
                if levelState == STATE_FRESH and enteredArmedZone
                    levelState := STATE_ARMED
                    array.set(highStates, i, levelState)

                if newPenetration
                    array.set(highAttempts, i, attempts + 1)
                    bool penetrationHandled = false
                    if acceptedSweep
                        float depthATR = (high - levelPrice) / safeATR
                        int kind = f_highSweepKind(levelPrice)
                        levelState := STATE_SWEPT
                        array.set(highStates, i, levelState)
                        array.set(highSweepBars, i, bar_index)
                        array.set(highSweepDepths, i, depthATR)
                        array.set(highSweepExtremes, i, high)
                        array.set(highSweepKinds, i, kind)
                        array.set(highReclaimBars, i, -1)
                        float importanceScore = f_sweepImportanceScore(levelAge, array.get(highAttempts, i), depthATR, kind)
                        f_addSweepMarker(true, levelPrice, high, kind, depthATR, importanceScore)
                        penetrationHandled := true
                    else
                        if firstInteractionOnly
                            removeNow := true
                        penetrationHandled := true

                if not removeNow and levelState != STATE_SWEPT and confirmedBreakout
                    removeNow := true

            lifecycleHandled := true

        bool renderHandled = false
        if removeNow
            f_removeLevel(
                 highPrices,
                 highBornBars,
                 highStates,
                 highAttempts,
                 highSweepBars,
                 highSweepDepths,
                 highSweepExtremes,
                 highSweepKinds,
                 highReclaimBars,
                 highLines,
                 i
            )
            renderHandled := true
        else
            int alpha = f_ageTransparency(levelAge, maxLevelAge)
            color baseColor = switch levelState
                STATE_RECLAIMED => sellReclaimColor
                STATE_SWEPT     => highSweptColor
                STATE_ARMED     => highArmedColor
                => highFreshColor
            int finalAlpha = levelState == STATE_SWEPT or levelState == STATE_RECLAIMED ? 0 : alpha
            color finalColor = showSwingHighs and f_levelStateVisible(levelState) ? color.new(baseColor, finalAlpha) : color.new(baseColor, 100)
            int finalWidth = levelState == STATE_SWEPT or levelState == STATE_RECLAIMED ? math.min(4, levelWidth + 2) : levelState == STATE_ARMED ? math.min(4, levelWidth + 1) : levelWidth

            line.set_x2(levelLine, bar_index)
            line.set_y1(levelLine, levelPrice)
            line.set_y2(levelLine, levelPrice)
            line.set_color(levelLine, finalColor)
            line.set_width(levelLine, finalWidth)
            line.set_style(levelLine, f_levelLineStyle(levelState))
            renderHandled := true

        i -= 1
    true

f_updateLowLevels(int selectedIndex, bool blockSweep) =>
    int i = array.size(lowPrices) - 1
    while i >= 0
        float levelPrice = array.get(lowPrices, i)
        int bornBar = array.get(lowBornBars, i)
        int levelState = array.get(lowStates, i)
        int levelAge = bar_index - bornBar
        int attempts = array.get(lowAttempts, i)
        int storedSweepBar = array.get(lowSweepBars, i)
        int storedReclaimBar = array.get(lowReclaimBars, i)
        line levelLine = array.get(lowLines, i)

        bool expired = levelAge > maxLevelAge
        bool consumed = levelState == STATE_CONSUMED
        bool sweepTimedOut = levelState == STATE_SWEPT and storedSweepBar >= 0 and bar_index - storedSweepBar > effectiveSweepTimeout
        bool reclaimedExpired = levelState == STATE_RECLAIMED and storedReclaimBar >= 0 and bar_index - storedReclaimBar > reclaimedLevelHoldBars
        bool newPenetration = (levelState == STATE_FRESH or levelState == STATE_ARMED) and f_isNewLowPenetration(levelPrice)
        bool validSweep = f_isValidLowSweep(levelPrice, attempts)
        bool selectedSweep = validSweep and (multiLevelSelection == "All Valid Levels" or i == selectedIndex)
        bool acceptedSweep = selectedSweep and not blockSweep
        bool confirmedBreakout = barstate.isconfirmed and close < levelPrice - safeATR * breakoutInvalidationATR
        bool removeNow = false

        bool lifecycleHandled = false
        if expired or reclaimedExpired or consumed
            removeNow := true
            lifecycleHandled := true
        else
            if sweepTimedOut
                bool timeoutHandled = false
                if firstInteractionOnly
                    removeNow := true
                    timeoutHandled := true
                else
                    levelState := STATE_ARMED
                    array.set(lowStates, i, levelState)
                    f_resetSweepMetadata(lowSweepBars, lowSweepDepths, lowSweepExtremes, lowSweepKinds, lowReclaimBars, i)
                    timeoutHandled := true

            if not removeNow and (levelState == STATE_FRESH or levelState == STATE_ARMED)
                bool enteredArmedZone = low <= levelPrice + safeATR * armDistanceATR
                if levelState == STATE_FRESH and enteredArmedZone
                    levelState := STATE_ARMED
                    array.set(lowStates, i, levelState)

                if newPenetration
                    array.set(lowAttempts, i, attempts + 1)
                    bool penetrationHandled = false
                    if acceptedSweep
                        float depthATR = (levelPrice - low) / safeATR
                        int kind = f_lowSweepKind(levelPrice)
                        levelState := STATE_SWEPT
                        array.set(lowStates, i, levelState)
                        array.set(lowSweepBars, i, bar_index)
                        array.set(lowSweepDepths, i, depthATR)
                        array.set(lowSweepExtremes, i, low)
                        array.set(lowSweepKinds, i, kind)
                        array.set(lowReclaimBars, i, -1)
                        float importanceScore = f_sweepImportanceScore(levelAge, array.get(lowAttempts, i), depthATR, kind)
                        f_addSweepMarker(false, levelPrice, low, kind, depthATR, importanceScore)
                        penetrationHandled := true
                    else
                        if firstInteractionOnly
                            removeNow := true
                        penetrationHandled := true

                if not removeNow and levelState != STATE_SWEPT and confirmedBreakout
                    removeNow := true

            lifecycleHandled := true

        bool renderHandled = false
        if removeNow
            f_removeLevel(
                 lowPrices,
                 lowBornBars,
                 lowStates,
                 lowAttempts,
                 lowSweepBars,
                 lowSweepDepths,
                 lowSweepExtremes,
                 lowSweepKinds,
                 lowReclaimBars,
                 lowLines,
                 i
            )
            renderHandled := true
        else
            int alpha = f_ageTransparency(levelAge, maxLevelAge)
            color baseColor = switch levelState
                STATE_RECLAIMED => buyReclaimColor
                STATE_SWEPT     => lowSweptColor
                STATE_ARMED     => lowArmedColor
                => lowFreshColor
            int finalAlpha = levelState == STATE_SWEPT or levelState == STATE_RECLAIMED ? 0 : alpha
            color finalColor = showSwingLows and f_levelStateVisible(levelState) ? color.new(baseColor, finalAlpha) : color.new(baseColor, 100)
            int finalWidth = levelState == STATE_SWEPT or levelState == STATE_RECLAIMED ? math.min(4, levelWidth + 2) : levelState == STATE_ARMED ? math.min(4, levelWidth + 1) : levelWidth

            line.set_x2(levelLine, bar_index)
            line.set_y1(levelLine, levelPrice)
            line.set_y2(levelLine, levelPrice)
            line.set_color(levelLine, finalColor)
            line.set_width(levelLine, finalWidth)
            line.set_style(levelLine, f_levelLineStyle(levelState))
            renderHandled := true

        i -= 1
    true

//──────────────────────────────────────────────────────────────────────
// REGISTER NEW CONFIRMED SWINGS
//──────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    float mergeTolerance = safeATR * mergeToleranceATR

    if not na(confirmedSwingHigh)
        f_addLevel(
             highPrices,
             highBornBars,
             highStates,
             highAttempts,
             highSweepBars,
             highSweepDepths,
             highSweepExtremes,
             highSweepKinds,
             highReclaimBars,
             highLines,
             confirmedSwingHigh,
             confirmedHighBar,
             highFreshColor,
             mergeTolerance
        )
        f_trimLevels(
             highPrices,
             highBornBars,
             highStates,
             highAttempts,
             highSweepBars,
             highSweepDepths,
             highSweepExtremes,
             highSweepKinds,
             highReclaimBars,
             highLines,
             maxLevelsPerSide
        )

    if not na(confirmedSwingLow)
        f_addLevel(
             lowPrices,
             lowBornBars,
             lowStates,
             lowAttempts,
             lowSweepBars,
             lowSweepDepths,
             lowSweepExtremes,
             lowSweepKinds,
             lowReclaimBars,
             lowLines,
             confirmedSwingLow,
             confirmedLowBar,
             lowFreshColor,
             mergeTolerance
        )
        f_trimLevels(
             lowPrices,
             lowBornBars,
             lowStates,
             lowAttempts,
             lowSweepBars,
             lowSweepDepths,
             lowSweepExtremes,
             lowSweepKinds,
             lowReclaimBars,
             lowLines,
             maxLevelsPerSide
        )

//──────────────────────────────────────────────────────────────────────
// PRE-SCAN CURRENT BAR
//──────────────────────────────────────────────────────────────────────
int selectedHighSweepIndex = f_findHighSweepIndex()
int selectedLowSweepIndex = f_findLowSweepIndex()

bool hasHighSweepCandidate = selectedHighSweepIndex >= 0
bool hasLowSweepCandidate = selectedLowSweepIndex >= 0
bool dualSideSweepBar = blockDualSideSweeps and hasHighSweepCandidate and hasLowSweepCandidate

bool highSweepDetected = barstate.isconfirmed and hasHighSweepCandidate and not dualSideSweepBar
bool lowSweepDetected = barstate.isconfirmed and hasLowSweepCandidate and not dualSideSweepBar

float selectedHighSweepDepth = na
float selectedLowSweepDepth = na
int selectedHighSweepKind = SWEEP_NONE
int selectedLowSweepKind = SWEEP_NONE

if hasHighSweepCandidate
    float selectedHighLevel = array.get(highPrices, selectedHighSweepIndex)
    selectedHighSweepDepth := (high - selectedHighLevel) / safeATR
    selectedHighSweepKind := f_highSweepKind(selectedHighLevel)

if hasLowSweepCandidate
    float selectedLowLevel = array.get(lowPrices, selectedLowSweepIndex)
    selectedLowSweepDepth := (selectedLowLevel - low) / safeATR
    selectedLowSweepKind := f_lowSweepKind(selectedLowLevel)

// Update all lifecycle states.
f_updateHighLevels(selectedHighSweepIndex, dualSideSweepBar)
f_updateLowLevels(selectedLowSweepIndex, dualSideSweepBar)


//──────────────────────────────────────────────────────────────────────
// ACTIVE TRADE UPDATE
//──────────────────────────────────────────────────────────────────────
tradeOpenedThisBar := false
tradeClosedThisBar := false
tradeTPHit := false
tradeSLHit := false

if enableTradeModel and tradeActive
    if not na(activeProfitBox)
        box.set_right(activeProfitBox, bar_index)
    if not na(activeStopBox)
        box.set_right(activeStopBox, bar_index)
    if not na(activeEntryLine)
        line.set_x2(activeEntryLine, bar_index)
    if not na(activeTargetLine)
        line.set_x2(activeTargetLine, bar_index)
    if not na(activeStopLine)
        line.set_x2(activeStopLine, bar_index)

    if bar_index > activeTradeEntryBar
        bool stopTouched = activeTradeDirection == 1 ? low <= activeTradeStop : high >= activeTradeStop
        bool targetTouched = activeTradeDirection == 1 ? high >= activeTradeTarget : low <= activeTradeTarget

        if stopTouched and targetTouched
            if sameBarExitPriority == "Stop First"
                tradeSLHit := true
            else
                tradeTPHit := true
        else if stopTouched
            tradeSLHit := true
        else if targetTouched
            tradeTPHit := true

        if tradeTPHit or tradeSLHit
            tradeClosedThisBar := true
            tradeActive := false
            totalTrades += 1

            lastClosedTradeDirection := activeTradeDirection

            if tradeTPHit
                winningTrades += 1
                netR += activeTradeRR
                currentWinStreak += 1
                currentLossStreak := 0
                bestWinStreak := math.max(bestWinStreak, currentWinStreak)
                lastTradeResult := "TP HIT"
                lastTradeR := activeTradeRR
            else
                losingTrades += 1
                netR -= 1.0
                currentLossStreak += 1
                currentWinStreak := 0
                bestLossStreak := math.max(bestLossStreak, currentLossStreak)
                lastTradeResult := "SL HIT"
                lastTradeR := -1.0

            if tradeSLHit
                if not na(activeTradeSignalLabel)
                    label.delete(activeTradeSignalLabel)
                    activeTradeSignalLabel := na

                if not na(activeProfitBox)
                    box.delete(activeProfitBox)
                if not na(activeStopBox)
                    box.delete(activeStopBox)
                if not na(activeEntryLine)
                    line.delete(activeEntryLine)
                if not na(activeTargetLine)
                    line.delete(activeTargetLine)
                if not na(activeStopLine)
                    line.delete(activeStopLine)

                activeProfitBox := na
                activeStopBox := na
                activeEntryLine := na
                activeTargetLine := na
                activeStopLine := na
            else
                if not na(activeProfitBox)
                    box.set_right(activeProfitBox, bar_index)
                if not na(activeStopBox)
                    box.set_right(activeStopBox, bar_index)
                if not na(activeEntryLine)
                    line.set_x2(activeEntryLine, bar_index)
                if not na(activeTargetLine)
                    line.set_x2(activeTargetLine, bar_index)
                if not na(activeStopLine)
                    line.set_x2(activeStopLine, bar_index)

            label resultLabel = na
            if effectiveShowTradeResultLabels
                float baseResultY = tradeTPHit ? activeTradeTarget : activeTradeStop
                float resultY = tradeTPHit ?
                     baseResultY + safeATR * resultLabelOffsetATR :
                     baseResultY - safeATR * resultLabelOffsetATR
                string resultText = tradeTPHit ?
                     "✓ TP HIT ✓\n+" + str.tostring(activeTradeRR, "#.##") + "R PROFIT" :
                     "CLOSED SL HIT"
                resultLabel := label.new(
                     x = bar_index,
                     y = resultY,
                     text = resultText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = activeTradeDirection == 1 ? label.style_label_down : label.style_label_up,
                     color = color.new(tradeTPHit ? tpResultLabelColor : slResultLabelColor, resultLabelTransparency),
                     textcolor = tradeTPHit ? tpResultTextColor : slResultTextColor,
                     size = tradeSLHit ? size.small : f_resultLabelSize(),
                     tooltip = "Direction: " + f_tradeDirectionText(activeTradeDirection) +
                         "\nEntry: " + str.tostring(activeTradeEntry, format.mintick) +
                         "\nStop: " + str.tostring(activeTradeStop, format.mintick) +
                         "\nTarget: " + str.tostring(activeTradeTarget, format.mintick) +
                         "\nResult: " + (tradeTPHit ? "+" + str.tostring(activeTradeRR, "#.##") + "R" : "-1R") +
                         "\nQuality: " + activeTradeGrade + " • " + str.tostring(activeTradeQuality, "#") + "/100"
                )
                label.set_text_formatting(resultLabel, text.format_bold + text.format_italic)

            if tradeTPHit and effectiveShowHistoricalTrades and fadeCompletedTrades
                if not na(activeProfitBox)
                    box.set_bgcolor(activeProfitBox, color.new(profitBoxFillColor, completedTradeTransparency))
                    box.set_border_color(activeProfitBox, color.new(profitBoxBorderColor, math.min(98, completedTradeTransparency + 2)))
                if not na(activeStopBox)
                    box.set_bgcolor(activeStopBox, color.new(stopBoxFillColor, completedTradeTransparency))
                    box.set_border_color(activeStopBox, color.new(stopBoxBorderColor, math.min(98, completedTradeTransparency + 2)))
                if not na(activeEntryLine)
                    line.set_color(activeEntryLine, color.new(entryLineColor, completedTradeTransparency))
                if not na(activeTargetLine)
                    line.set_color(activeTargetLine, color.new(targetLineColor, completedTradeTransparency))
                if not na(activeStopLine)
                    line.set_color(activeStopLine, color.new(stopLineColor, completedTradeTransparency))

            if effectiveShowHistoricalTrades
                array.push(historicalProfitBoxes, activeProfitBox)
                array.push(historicalStopBoxes, activeStopBox)
                array.push(historicalEntryLines, activeEntryLine)
                array.push(historicalTargetLines, activeTargetLine)
                array.push(historicalStopLines, activeStopLine)
                array.push(historicalResultLabels, resultLabel)

                while array.size(historicalProfitBoxes) > effectiveMaxHistoricalTrades
                    box oldProfitBox = array.shift(historicalProfitBoxes)
                    box oldStopBox = array.shift(historicalStopBoxes)
                    line oldEntryLine = array.shift(historicalEntryLines)
                    line oldTargetLine = array.shift(historicalTargetLines)
                    line oldStopLine = array.shift(historicalStopLines)
                    label oldResultLabel = array.shift(historicalResultLabels)

                    if not na(oldProfitBox)
                        box.delete(oldProfitBox)
                    if not na(oldStopBox)
                        box.delete(oldStopBox)
                    if not na(oldEntryLine)
                        line.delete(oldEntryLine)
                    if not na(oldTargetLine)
                        line.delete(oldTargetLine)
                    if not na(oldStopLine)
                        line.delete(oldStopLine)
                    if not na(oldResultLabel)
                        label.delete(oldResultLabel)
            else
                f_deleteActiveTradeObjects()
                if not na(resultLabel)
                    label.delete(resultLabel)

            activeProfitBox := na
            activeStopBox := na
            activeEntryLine := na
            activeTargetLine := na
            activeStopLine := na
            activeTradeSignalLabel := na

//──────────────────────────────────────────────────────────────────────
// RECLAIM PRE-SCAN AND CONFIRMATION
//──────────────────────────────────────────────────────────────────────
int selectedHighReclaimIndex = f_findHighReclaimIndex()
int selectedLowReclaimIndex = f_findLowReclaimIndex()

bool hasSellReclaimCandidate = selectedHighReclaimIndex >= 0
bool hasBuyReclaimCandidate = selectedLowReclaimIndex >= 0

int selectedSellDelay = na
int selectedBuyDelay = na
float selectedSellQuality = na
float selectedBuyQuality = na
float selectedSellSweepScore = na
float selectedBuySweepScore = na
float selectedSellCloseScore = na
float selectedBuyCloseScore = na
float selectedSellWickScore = na
float selectedBuyWickScore = na
float selectedSellFreshnessScore = na
float selectedBuyFreshnessScore = na
float selectedSellVolumeScore = na
float selectedBuyVolumeScore = na
float selectedSellDisplacementScore = na
float selectedBuyDisplacementScore = na
float selectedSellMarketScore = na
float selectedBuyMarketScore = na
float selectedSellCleanlinessScore = na
float selectedBuyCleanlinessScore = na

if hasSellReclaimCandidate
    float selectedSellLevel = array.get(highPrices, selectedHighReclaimIndex)
    float selectedSellDepth = array.get(highSweepDepths, selectedHighReclaimIndex)
    int selectedSellKind = array.get(highSweepKinds, selectedHighReclaimIndex)
    int selectedSellBornBar = array.get(highBornBars, selectedHighReclaimIndex)
    int selectedSellAttempts = array.get(highAttempts, selectedHighReclaimIndex)
    selectedSellDelay := bar_index - array.get(highSweepBars, selectedHighReclaimIndex)
    selectedSellSweepScore := f_sweepDepthComponent(selectedSellDepth)
    selectedSellCloseScore := f_closeComponent(false)
    selectedSellWickScore := f_wickComponent(false, selectedSellKind, selectedSellDelay)
    selectedSellFreshnessScore := f_freshnessComponent(selectedSellBornBar)
    selectedSellVolumeScore := f_volumeComponent()
    selectedSellDisplacementScore := f_displacementComponent(false, selectedSellLevel)
    selectedSellMarketScore := f_marketComponent()
    selectedSellCleanlinessScore := f_cleanlinessComponent(selectedSellAttempts)
    selectedSellQuality := math.min(100.0, math.max(0.0, math.round(
         selectedSellSweepScore + selectedSellCloseScore + selectedSellWickScore +
         selectedSellFreshnessScore + selectedSellVolumeScore +
         selectedSellDisplacementScore + selectedSellMarketScore +
         selectedSellCleanlinessScore
    )))

if hasBuyReclaimCandidate
    float selectedBuyLevel = array.get(lowPrices, selectedLowReclaimIndex)
    float selectedBuyDepth = array.get(lowSweepDepths, selectedLowReclaimIndex)
    int selectedBuyKind = array.get(lowSweepKinds, selectedLowReclaimIndex)
    int selectedBuyBornBar = array.get(lowBornBars, selectedLowReclaimIndex)
    int selectedBuyAttempts = array.get(lowAttempts, selectedLowReclaimIndex)
    selectedBuyDelay := bar_index - array.get(lowSweepBars, selectedLowReclaimIndex)
    selectedBuySweepScore := f_sweepDepthComponent(selectedBuyDepth)
    selectedBuyCloseScore := f_closeComponent(true)
    selectedBuyWickScore := f_wickComponent(true, selectedBuyKind, selectedBuyDelay)
    selectedBuyFreshnessScore := f_freshnessComponent(selectedBuyBornBar)
    selectedBuyVolumeScore := f_volumeComponent()
    selectedBuyDisplacementScore := f_displacementComponent(true, selectedBuyLevel)
    selectedBuyMarketScore := f_marketComponent()
    selectedBuyCleanlinessScore := f_cleanlinessComponent(selectedBuyAttempts)
    selectedBuyQuality := math.min(100.0, math.max(0.0, math.round(
         selectedBuySweepScore + selectedBuyCloseScore + selectedBuyWickScore +
         selectedBuyFreshnessScore + selectedBuyVolumeScore +
         selectedBuyDisplacementScore + selectedBuyMarketScore +
         selectedBuyCleanlinessScore
    )))


bool rawSellReclaimSignal = barstate.isconfirmed and hasSellReclaimCandidate
bool rawBuyReclaimSignal = barstate.isconfirmed and hasBuyReclaimCandidate
bool oppositeSignalConflict = rawSellReclaimSignal and rawBuyReclaimSignal

bool sellConflictPass = not oppositeSignalConflict or
     conflictResolution == "SELL Priority" or
     (conflictResolution == "Higher Quality" and selectedSellQuality > selectedBuyQuality)

bool buyConflictPass = not oppositeSignalConflict or
     conflictResolution == "BUY Priority" or
     (conflictResolution == "Higher Quality" and selectedBuyQuality > selectedSellQuality)

if oppositeSignalConflict and (blockDualSideReclaims or conflictResolution == "Block Both")
    sellConflictPass := false
    buyConflictPass := false

if oppositeSignalConflict and conflictResolution == "Higher Quality" and selectedBuyQuality == selectedSellQuality
    sellConflictPass := false
    buyConflictPass := false

string sellBlockReason = rawSellReclaimSignal ? f_signalBlockReason(false) : "No Candidate"
string buyBlockReason = rawBuyReclaimSignal ? f_signalBlockReason(true) : "No Candidate"

bool sellExecutionFiltersPass = sellBlockReason == "Pass"
bool buyExecutionFiltersPass = buyBlockReason == "Pass"

bool sellReclaimSignal = rawSellReclaimSignal and sellConflictPass and sellExecutionFiltersPass
bool buyReclaimSignal = rawBuyReclaimSignal and buyConflictPass and buyExecutionFiltersPass

if sellReclaimSignal and buyReclaimSignal
    sellReclaimSignal := false
    buyReclaimSignal := false
    sellBlockReason := "Final Conflict"
    buyBlockReason := "Final Conflict"

f_processHighReclaims(selectedHighReclaimIndex, not sellReclaimSignal)
f_processLowReclaims(selectedLowReclaimIndex, not buyReclaimSignal)

if consumeFilteredReclaims
    if rawSellReclaimSignal and not sellReclaimSignal
        f_consumeHighCandidate(selectedHighReclaimIndex)
    if rawBuyReclaimSignal and not buyReclaimSignal
        f_consumeLowCandidate(selectedLowReclaimIndex)

currentBiasState := trendBiasMode == "Off" ? "Off" :
     f_biasPass(true) and not f_biasPass(false) ? "Bullish" :
     f_biasPass(false) and not f_biasPass(true) ? "Bearish" :
     "Neutral"

currentMarketState := f_marketPass() ? "Pass" : "Blocked"

if sellReclaimSignal
    lastAnySignalBar := bar_index
    lastSellSignalBar := bar_index
    lastSellSignalPrice := close
    lastExecutedSignalLevel := array.get(highPrices, selectedHighReclaimIndex)
    lastSignalBlockReason := "None"

if buyReclaimSignal
    lastAnySignalBar := bar_index
    lastBuySignalBar := bar_index
    lastBuySignalPrice := close
    lastExecutedSignalLevel := array.get(lowPrices, selectedLowReclaimIndex)
    lastSignalBlockReason := "None"

if rawSellReclaimSignal and not sellReclaimSignal
    lastSignalBlockReason := sellConflictPass ? sellBlockReason : blockDualSideReclaims and oppositeSignalConflict ? "Dual-Side Block" : "Conflict"

if rawBuyReclaimSignal and not buyReclaimSignal
    lastSignalBlockReason := buyConflictPass ? buyBlockReason : blockDualSideReclaims and oppositeSignalConflict ? "Dual-Side Block" : "Conflict"


//──────────────────────────────────────────────────────────────────────
// TRADE ENTRY
//──────────────────────────────────────────────────────────────────────
if enableTradeModel and not tradeActive and (allowSignalOnExitBar or not tradeClosedThisBar)
    if buyReclaimSignal
        float sweepExtreme = array.get(lowSweepExtremes, selectedLowReclaimIndex)
        float candidateStop = stopLossMode == "Entry ATR Multiplier" ?
             close - safeATR * stopATRMultiplier :
             sweepExtreme - safeATR * stopBufferATR
        float candidateRisk = close - candidateStop

        if candidateRisk > syminfo.mintick
            tradeActive := true
            tradeOpenedThisBar := true
            activeTradeDirection := 1
            activeTradeEntryBar := bar_index
            activeTradeEntry := close
            activeTradeStop := candidateStop
            activeTradeRisk := candidateRisk
            activeTradeRR := tradeRiskReward
            activeTradeTarget := close + candidateRisk * tradeRiskReward
            activeTradeQuality := selectedBuyQuality
            activeTradeGrade := f_qualityGrade(selectedBuyQuality)
        else
            lastSignalBlockReason := "Invalid Trade Risk"

    else if sellReclaimSignal
        float sweepExtreme = array.get(highSweepExtremes, selectedHighReclaimIndex)
        float candidateStop = stopLossMode == "Entry ATR Multiplier" ?
             close + safeATR * stopATRMultiplier :
             sweepExtreme + safeATR * stopBufferATR
        float candidateRisk = candidateStop - close

        if candidateRisk > syminfo.mintick
            tradeActive := true
            tradeOpenedThisBar := true
            activeTradeDirection := -1
            activeTradeEntryBar := bar_index
            activeTradeEntry := close
            activeTradeStop := candidateStop
            activeTradeRisk := candidateRisk
            activeTradeRR := tradeRiskReward
            activeTradeTarget := close - candidateRisk * tradeRiskReward
            activeTradeQuality := selectedSellQuality
            activeTradeGrade := f_qualityGrade(selectedSellQuality)
        else
            lastSignalBlockReason := "Invalid Trade Risk"

if tradeOpenedThisBar
    f_deleteLatestSweepMarker()

    activeTradeSignalLabel := array.size(reclaimLabels) > 0 ? array.get(reclaimLabels, array.size(reclaimLabels) - 1) : na

    if effectiveShowTradeBoxes
        float profitTop = activeTradeDirection == 1 ? activeTradeTarget : activeTradeEntry
        float profitBottom = activeTradeDirection == 1 ? activeTradeEntry : activeTradeTarget
        float stopTop = activeTradeDirection == 1 ? activeTradeEntry : activeTradeStop
        float stopBottom = activeTradeDirection == 1 ? activeTradeStop : activeTradeEntry

        activeProfitBox := box.new(
             left = bar_index,
             top = profitTop,
             right = bar_index + 1,
             bottom = profitBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(profitBoxFillColor, effectiveTradeZoneTransparency),
             border_color = color.new(profitBoxBorderColor, effectiveTradeBorderTransparency),
             border_width = 1
        )

        activeStopBox := box.new(
             left = bar_index,
             top = stopTop,
             right = bar_index + 1,
             bottom = stopBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(stopBoxFillColor, math.min(98, effectiveTradeZoneTransparency + 2)),
             border_color = color.new(stopBoxBorderColor, effectiveTradeBorderTransparency),
             border_width = 1
        )

    if effectiveShowTradeLines
        activeEntryLine := line.new(
             x1 = bar_index,
             y1 = activeTradeEntry,
             x2 = bar_index + 1,
             y2 = activeTradeEntry,
             xloc = xloc.bar_index,
             color = entryLineColor,
             style = line.style_solid,
             width = math.min(4, effectiveTradeLineWidth + 1)
        )

        activeTargetLine := line.new(
             x1 = bar_index,
             y1 = activeTradeTarget,
             x2 = bar_index + 1,
             y2 = activeTradeTarget,
             xloc = xloc.bar_index,
             color = targetLineColor,
             style = line.style_solid,
             width = effectiveTradeLineWidth
        )

        activeStopLine := line.new(
             x1 = bar_index,
             y1 = activeTradeStop,
             x2 = bar_index + 1,
             y2 = activeTradeStop,
             xloc = xloc.bar_index,
             color = stopLineColor,
             style = line.style_solid,
             width = effectiveTradeLineWidth
        )


//──────────────────────────────────────────────────────────────────────
// DYNAMIC ALERT PAYLOADS
//──────────────────────────────────────────────────────────────────────
if enableDynamicAlerts
    bool buyAlertAllowed = buyReclaimSignal and dynamicAlertFinalSignals and (not dynamicAlertStrongOnly or selectedBuyQuality >= 80.0)
    bool sellAlertAllowed = sellReclaimSignal and dynamicAlertFinalSignals and (not dynamicAlertStrongOnly or selectedSellQuality >= 80.0)

    if buyAlertAllowed
        float buyAlertLevel = array.get(lowPrices, selectedLowReclaimIndex)
        alert(f_dynamicSignalMessage(true, selectedBuyQuality, buyAlertLevel), alert.freq_once_per_bar_close)

    if sellAlertAllowed
        float sellAlertLevel = array.get(highPrices, selectedHighReclaimIndex)
        alert(f_dynamicSignalMessage(false, selectedSellQuality, sellAlertLevel), alert.freq_once_per_bar_close)

    if tradeOpenedThisBar and dynamicAlertTradeOpen
        alert(f_dynamicTradeOpenMessage(), alert.freq_once_per_bar_close)

    if tradeClosedThisBar and dynamicAlertTradeResult
        alert(f_dynamicTradeResultMessage(), alert.freq_once_per_bar_close)

//──────────────────────────────────────────────────────────────────────
// SWEEP MEMORY
//──────────────────────────────────────────────────────────────────────
if highSweepDetected
    lastSweepSide := "Swing High"
    lastSweepType := selectedHighSweepKind == SWEEP_BODY ? "Body" : "Wick"
    lastSweepDepth := selectedHighSweepDepth

if lowSweepDetected
    lastSweepSide := "Swing Low"
    lastSweepType := selectedLowSweepKind == SWEEP_BODY ? "Body" : "Wick"
    lastSweepDepth := selectedLowSweepDepth


if sellReclaimSignal
    lastReclaimSignal := "SELL RECLAIM"
    lastReclaimDelay := selectedSellDelay
    lastReclaimCloseLocation := f_bearCloseLocation()
    lastReclaimBodyATR := f_bodyATR()
    lastQualityScore := selectedSellQuality
    lastQualityGrade := f_qualityGrade(selectedSellQuality)
    lastSweepComponent := selectedSellSweepScore
    lastCloseComponent := selectedSellCloseScore
    lastWickComponent := selectedSellWickScore
    lastFreshnessComponent := selectedSellFreshnessScore
    lastVolumeComponent := selectedSellVolumeScore
    lastDisplacementComponent := selectedSellDisplacementScore
    lastMarketComponent := selectedSellMarketScore
    lastCleanlinessComponent := selectedSellCleanlinessScore

if buyReclaimSignal
    lastReclaimSignal := "BUY RECLAIM"
    lastReclaimDelay := selectedBuyDelay
    lastReclaimCloseLocation := f_bullCloseLocation()
    lastReclaimBodyATR := f_bodyATR()
    lastQualityScore := selectedBuyQuality
    lastQualityGrade := f_qualityGrade(selectedBuyQuality)
    lastSweepComponent := selectedBuySweepScore
    lastCloseComponent := selectedBuyCloseScore
    lastWickComponent := selectedBuyWickScore
    lastFreshnessComponent := selectedBuyFreshnessScore
    lastVolumeComponent := selectedBuyVolumeScore
    lastDisplacementComponent := selectedBuyDisplacementScore
    lastMarketComponent := selectedBuyMarketScore
    lastCleanlinessComponent := selectedBuyCleanlinessScore

//──────────────────────────────────────────────────────────────────────
// OPTIONAL CONFIRMED PIVOT MARKERS
//──────────────────────────────────────────────────────────────────────
plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Tiny" and not na(confirmedSwingHigh),
     title = "Confirmed Swing High — Tiny",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -swingRight,
     color = color.new(highFreshColor, 0),
     size = size.tiny
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Small" and not na(confirmedSwingHigh),
     title = "Confirmed Swing High — Small",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -swingRight,
     color = color.new(highFreshColor, 0),
     size = size.small
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Normal" and not na(confirmedSwingHigh),
     title = "Confirmed Swing High — Normal",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -swingRight,
     color = color.new(highFreshColor, 0),
     size = size.normal
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Large" and not na(confirmedSwingHigh),
     title = "Confirmed Swing High — Large",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -swingRight,
     color = color.new(highFreshColor, 0),
     size = size.large
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Huge" and not na(confirmedSwingHigh),
     title = "Confirmed Swing High — Huge",
     style = shape.triangledown,
     location = location.abovebar,
     offset = -swingRight,
     color = color.new(highFreshColor, 0),
     size = size.huge
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Tiny" and not na(confirmedSwingLow),
     title = "Confirmed Swing Low — Tiny",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -swingRight,
     color = color.new(lowFreshColor, 0),
     size = size.tiny
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Small" and not na(confirmedSwingLow),
     title = "Confirmed Swing Low — Small",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -swingRight,
     color = color.new(lowFreshColor, 0),
     size = size.small
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Normal" and not na(confirmedSwingLow),
     title = "Confirmed Swing Low — Normal",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -swingRight,
     color = color.new(lowFreshColor, 0),
     size = size.normal
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Large" and not na(confirmedSwingLow),
     title = "Confirmed Swing Low — Large",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -swingRight,
     color = color.new(lowFreshColor, 0),
     size = size.large
,
display = display.all - display.status_line)

plotshape(
     effectiveShowPivotMarkers and triangleMarkerSize == "Huge" and not na(confirmedSwingLow),
     title = "Confirmed Swing Low — Huge",
     style = shape.triangleup,
     location = location.belowbar,
     offset = -swingRight,
     color = color.new(lowFreshColor, 0),
     size = size.huge
,
display = display.all - display.status_line)

//──────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
//──────────────────────────────────────────────────────────────────────
alertcondition(
     highSweepDetected,
     title = "Swing High Swept",
     message = "A confirmed swing-high sweep was detected on {{ticker}} {{interval}}."
)

alertcondition(
     lowSweepDetected,
     title = "Swing Low Swept",
     message = "A confirmed swing-low sweep was detected on {{ticker}} {{interval}}."
)

alertcondition(
     highSweepDetected or lowSweepDetected,
     title = "Any Swing Sweep",
     message = "A confirmed swing-level sweep was detected on {{ticker}} {{interval}}."
)

alertcondition(
     buyReclaimSignal,
     title = "BUY Reclaim Confirmed",
     message = "Sweep Reclaim BUY confirmed | {{ticker}} | {{interval}} | Close {{close}}."
)

alertcondition(
     sellReclaimSignal,
     title = "SELL Reclaim Confirmed",
     message = "Sweep Reclaim SELL confirmed | {{ticker}} | {{interval}} | Close {{close}}."
)

alertcondition(
     buyReclaimSignal or sellReclaimSignal,
     title = "Any Reclaim Signal",
     message = "A confirmed Sweep Reclaim signal appeared on {{ticker}} {{interval}} at {{close}}."
)


bool buyAPlusSignal = buyReclaimSignal and selectedBuyQuality >= 80.0
bool sellAPlusSignal = sellReclaimSignal and selectedSellQuality >= 80.0
bool buyASignal = buyReclaimSignal and selectedBuyQuality >= 65.0 and selectedBuyQuality < 80.0
bool sellASignal = sellReclaimSignal and selectedSellQuality >= 65.0 and selectedSellQuality < 80.0
bool buyBSignal = buyReclaimSignal and selectedBuyQuality >= 50.0 and selectedBuyQuality < 65.0
bool sellBSignal = sellReclaimSignal and selectedSellQuality >= 50.0 and selectedSellQuality < 65.0

alertcondition(
     buyAPlusSignal or sellAPlusSignal,
     title = "A+ Sweep Reclaim",
     message = "An A+ Sweep Reclaim setup was confirmed on {{ticker}} {{interval}} at {{close}}."
)

alertcondition(
     buyASignal or sellASignal,
     title = "A Sweep Reclaim",
     message = "An A-grade Sweep Reclaim setup was confirmed on {{ticker}} {{interval}} at {{close}}."
)

alertcondition(
     buyBSignal or sellBSignal,
     title = "B Sweep Reclaim",
     message = "A B-grade Sweep Reclaim setup was confirmed on {{ticker}} {{interval}} at {{close}}."
)


alertcondition(
     tradeOpenedThisBar,
     title = "Sweep Reclaim Trade Opened",
     message = "Sweep Reclaim educational trade model opened | {{ticker}} | {{interval}} | Entry {{close}}."
)

alertcondition(
     tradeTPHit,
     title = "Sweep Reclaim TP Hit",
     message = "Sweep Reclaim trade model reached TP | {{ticker}} | {{interval}}."
)

alertcondition(
     tradeSLHit,
     title = "Sweep Reclaim SL Hit",
     message = "Sweep Reclaim trade model reached SL | {{ticker}} | {{interval}}."
)

//──────────────────────────────────────────────────────────────────────
// FINAL ENGINE DASHBOARD
//──────────────────────────────────────────────────────────────────────
var table coreDashboard = table.new(
     position.bottom_right,
     2,
     28,
     bgcolor = dashboardBg,
     frame_color = dashboardBorder,
     frame_width = 1,
     border_color = color.new(color.white, 88),
     border_width = 1
)

if barstate.islast
    if effectiveDashboardMode == "Full"
        int armedHighs = f_countState(highStates, STATE_ARMED)
        int armedLows = f_countState(lowStates, STATE_ARMED)
        int sweptHighs = f_countState(highStates, STATE_SWEPT)
        int sweptLows = f_countState(lowStates, STATE_SWEPT)
        int reclaimedHighs = f_countState(highStates, STATE_RECLAIMED)
        int reclaimedLows = f_countState(lowStates, STATE_RECLAIMED)
        string depthText = na(lastSweepDepth) ? "—" : str.tostring(lastSweepDepth, "#.##") + " ATR"
        string delayText = na(lastReclaimDelay) ? "—" : str.tostring(lastReclaimDelay) + " bar(s)"
        string locationText = na(lastReclaimCloseLocation) ? "—" : str.tostring(lastReclaimCloseLocation * 100.0, "#.0") + "%"
        string bodyText = na(lastReclaimBodyATR) ? "—" : str.tostring(lastReclaimBodyATR, "#.##") + " ATR"
        string qualityText = na(lastQualityScore) ? "—" : lastQualityGrade + " • " + str.tostring(lastQualityScore, "#") + "/100"
        string setupComponents = na(lastSweepComponent) ? "—" :
             "S " + str.tostring(lastSweepComponent, "#.0") +
             " • C " + str.tostring(lastCloseComponent, "#.0") +
             " • W " + str.tostring(lastWickComponent, "#.0")
        string contextComponents = na(lastFreshnessComponent) ? "—" :
             "F " + str.tostring(lastFreshnessComponent, "#.0") +
             " • V " + str.tostring(lastVolumeComponent, "#.0") +
             " • D " + str.tostring(lastDisplacementComponent, "#.0")
        string regimeComponents = na(lastMarketComponent) ? "—" :
             "M " + str.tostring(lastMarketComponent, "#.0") +
             " • L " + str.tostring(lastCleanlinessComponent, "#.0")
        color signalColor = lastReclaimSignal == "BUY RECLAIM" ? buyReclaimColor : lastReclaimSignal == "SELL RECLAIM" ? sellReclaimColor : dashboardText
        color qualityColor = lastQualityGrade == "A+" ? color.rgb(255, 205, 45) : lastQualityGrade == "A" ? buyReclaimColor : dashboardText
        string cooldownText = cooldownMode == "Off" ? "Off" : cooldownMode + " • " + str.tostring(signalCooldownBars)
        string biasText = trendBiasMode + " • " + currentBiasState
        string marketText = marketFilterMode + " • " + currentMarketState
        string efficiencyText = str.tostring(marketEfficiency, "#.##") + " • ATR " + str.tostring(volatilityRatio, "#.##")
        string lastLevelText = na(lastExecutedSignalLevel) ? "—" : str.tostring(lastExecutedSignalLevel, format.mintick)
        float winRate = totalTrades > 0 ? winningTrades * 100.0 / totalTrades : 0.0
        string tradeStateText = tradeActive ? f_tradeDirectionText(activeTradeDirection) + " ACTIVE" : "WAITING"
        string tradeEntryText = tradeActive ? str.tostring(activeTradeEntry, format.mintick) : "—"
        string tradeStopText = tradeActive ? str.tostring(activeTradeStop, format.mintick) : "—"
        string tradeTargetText = tradeActive ? str.tostring(activeTradeTarget, format.mintick) : "—"
        string tradeRiskText = tradeActive ? str.tostring(activeTradeRisk, format.mintick) + " • " + str.tostring(activeTradeRR, "#.##") + "R" : "—"
        string resultsText = str.tostring(winningTrades) + "W / " + str.tostring(losingTrades) + "L • " + str.tostring(winRate, "#.0") + "%"
        string netRText = str.tostring(netR, "#.##") + "R • " + lastTradeResult
        string streakText = "W " + str.tostring(currentWinStreak) + " (" + str.tostring(bestWinStreak) + ")" +
             " • L " + str.tostring(currentLossStreak) + " (" + str.tostring(bestLossStreak) + ")"
        table.cell(coreDashboard, 0, 0, "SWEEP RECLAIM", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(coreDashboard, 0, 0, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 0, "FINAL • SIGNAL LABELS REVERTED", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(coreDashboard, 1, 0, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 1, "Swing / Reclaim", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 1, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 1, swingMode + " • " + reclaimMode, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 1, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 2, "Quality Filter", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 2, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 2, qualityFilterMode + " • " + str.tostring(minimumQualityScore, "#"), text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 2, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 3, "Active H / L", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 3, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 3, str.tostring(array.size(highPrices)) + " / " + str.tostring(array.size(lowPrices)), text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 3, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 4, "Armed H / L", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 4, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 4, str.tostring(armedHighs) + " / " + str.tostring(armedLows), text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 4, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 5, "Swept H / L", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 5, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 5, str.tostring(sweptHighs) + " / " + str.tostring(sweptLows), text_color = highSweptColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 5, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 6, "Reclaimed H / L", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 6, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 6, str.tostring(reclaimedHighs) + " / " + str.tostring(reclaimedLows), text_color = buyReclaimColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 6, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 7, "Last Sweep", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 7, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 7, lastSweepSide + " • " + lastSweepType, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 7, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 8, "Sweep Depth", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 8, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 8, depthText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 8, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 9, "Last Signal", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 9, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 9, lastReclaimSignal, text_color = signalColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 9, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 10, "Quality", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 10, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 10, qualityText, text_color = qualityColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 10, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 11, "Delay / Close", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 11, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 11, delayText + " • " + locationText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 11, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 12, "Body Strength", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 12, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 12, bodyText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 12, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 13, "Setup S / C / W", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 13, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 13, setupComponents, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 13, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 14, "Context F / V / D", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 14, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 14, contextComponents, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 14, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 15, "Regime M / L", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 15, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 15, regimeComponents, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 15, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 16, "Direction / Selection", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 16, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 16, signalDirectionMode + " • " + signalSelectionMode, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 16, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 17, "Cooldown", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 17, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 17, cooldownText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 17, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 18, "Trend Bias", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 18, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 18, biasText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 18, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 19, "Market State", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 19, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 19, marketText + " • " + efficiencyText, text_color = currentMarketState == "Pass" ? buyReclaimColor : sellReclaimColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 19, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 20, "Level / Last Block", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 20, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 20, lastLevelText + " • " + lastSignalBlockReason, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 20, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 21, "Trade State", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 21, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 21, tradeStateText, text_color = tradeActive ? (activeTradeDirection == 1 ? buyReclaimColor : sellReclaimColor) : dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 21, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 22, "Entry", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 22, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 22, tradeEntryText, text_color = entryLineColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 22, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 23, "Stop / Target", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 23, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 23, tradeStopText + " / " + tradeTargetText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 23, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 24, "Risk / RR", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 24, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 24, tradeRiskText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 24, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 25, "Trade Results", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 25, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 25, resultsText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 25, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 26, "Net R / Last", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 26, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 26, netRText, text_color = netR >= 0.0 ? buyReclaimColor : sellReclaimColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 26, text.format_bold + text.format_italic)

        table.cell(coreDashboard, 0, 27, "Current (Best) Streak", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 0, 27, text.format_bold + text.format_italic)
        table.cell(coreDashboard, 1, 27, streakText, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(coreDashboard, 1, 27, text.format_bold + text.format_italic)

    else
        table.clear(coreDashboard, 0, 0, 1, 27)


//──────────────────────────────────────────────────────────────────────
// COMPACT / TRADE-ONLY DASHBOARD
//──────────────────────────────────────────────────────────────────────
var table compactDashboard = table.new(
     position.bottom_right,
     2,
     9,
     bgcolor = dashboardBg,
     frame_color = dashboardBorder,
     frame_width = 1,
     border_color = color.new(color.white, 88),
     border_width = 1
)

if barstate.islast
    if effectiveDashboardMode == "Compact"
        float compactWinRate = totalTrades > 0 ? winningTrades * 100.0 / totalTrades : 0.0
        string compactTradeState = tradeActive ? f_tradeDirectionText(activeTradeDirection) + " ACTIVE" : "WAITING"
        string compactQuality = na(lastQualityScore) ? "—" : lastQualityGrade + " • " + str.tostring(lastQualityScore, "#") + "/100"
        string compactTradeLevels = tradeActive ?
             "E " + str.tostring(activeTradeEntry, format.mintick) +
             " • S " + str.tostring(activeTradeStop, format.mintick) +
             " • T " + str.tostring(activeTradeTarget, format.mintick) :
             "—"
        string compactResults = str.tostring(winningTrades) + "W / " + str.tostring(losingTrades) + "L • " +
             str.tostring(compactWinRate, "#.0") + "% • " + str.tostring(netR, "#.##") + "R"
        color compactSignalColor = lastReclaimSignal == "BUY RECLAIM" ? buyReclaimColor :
             lastReclaimSignal == "SELL RECLAIM" ? sellReclaimColor : dashboardText

        table.cell(compactDashboard, 0, 0, "SWEEP RECLAIM", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(compactDashboard, 0, 0, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 0, "COMPACT", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(compactDashboard, 1, 0, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 1, "Signal", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 1, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 1, lastReclaimSignal, text_color = compactSignalColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 1, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 2, "Quality", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 2, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 2, compactQuality, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 2, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 3, "Bias", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 3, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 3, currentBiasState + " • " + currentMarketState, text_color = currentMarketState == "Pass" ? buyReclaimColor : sellReclaimColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 3, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 4, "Trade", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 4, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 4, compactTradeState, text_color = tradeActive ? (activeTradeDirection == 1 ? buyReclaimColor : sellReclaimColor) : dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 4, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 5, "E / S / T", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 5, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 5, compactTradeLevels, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 5, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 6, "Results", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 6, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 6, compactResults, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 6, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 7, "Last Result", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 7, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 7, lastTradeResult, text_color = lastTradeResult == "TP HIT" ? targetLineColor : lastTradeResult == "SL HIT" ? stopLineColor : dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 7, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 8, "Last Block", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 8, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 8, lastSignalBlockReason, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 8, text.format_bold + text.format_italic)

    else if effectiveDashboardMode == "Trade Only"
        float tradeOnlyWinRate = totalTrades > 0 ? winningTrades * 100.0 / totalTrades : 0.0
        string tradeOnlyState = tradeActive ? f_tradeDirectionText(activeTradeDirection) + " ACTIVE" : "WAITING"
        string tradeOnlyEntry = tradeActive ? str.tostring(activeTradeEntry, format.mintick) : "—"
        string tradeOnlyStopTarget = tradeActive ?
             str.tostring(activeTradeStop, format.mintick) + " / " + str.tostring(activeTradeTarget, format.mintick) :
             "—"
        string tradeOnlyResults = str.tostring(winningTrades) + "W / " + str.tostring(losingTrades) + "L • " +
             str.tostring(tradeOnlyWinRate, "#.0") + "%"
        string tradeOnlyNetR = str.tostring(netR, "#.##") + "R • " + lastTradeResult

        table.cell(compactDashboard, 0, 0, "SWEEP RECLAIM", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(compactDashboard, 0, 0, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 0, "TRADE", text_color = dashboardText, text_size = f_dashboardHeaderSize(), bgcolor = color.new(dashboardHeaderColor, 22))
        table.cell_set_text_formatting(compactDashboard, 1, 0, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 1, "State", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 1, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 1, tradeOnlyState, text_color = tradeActive ? (activeTradeDirection == 1 ? buyReclaimColor : sellReclaimColor) : dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 1, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 2, "Entry", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 2, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 2, tradeOnlyEntry, text_color = entryLineColor, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 2, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 3, "Stop / Target", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 3, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 3, tradeOnlyStopTarget, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 3, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 4, "Risk / RR", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 4, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 4, tradeActive ? str.tostring(activeTradeRisk, format.mintick) + " • " + str.tostring(activeTradeRR, "#.##") + "R" : "—", text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 4, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 5, "Results", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 5, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 5, tradeOnlyResults, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 5, text.format_bold + text.format_italic)

        table.cell(compactDashboard, 0, 6, "Net R", text_color = mutedText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 0, 6, text.format_bold + text.format_italic)
        table.cell(compactDashboard, 1, 6, tradeOnlyNetR, text_color = dashboardText, text_size = f_dashboardBodySize())
        table.cell_set_text_formatting(compactDashboard, 1, 6, text.format_bold + text.format_italic)

        table.clear(compactDashboard, 0, 7, 1, 8)
    else
        table.clear(compactDashboard, 0, 0, 1, 8)


//──────────────────────────────────────────────────────────────────────
// DEVELOPMENT NOTES
// Stage 7 visual system integrated.
// Final code cleanup and alert system integrated.

//──────────────────────────────────────────────────────────────────────
// Stage 1:
// • Confirmed non-repainting swing highs and swing lows
// • Reactive / Balanced / Structural / Custom pivot modes
// • ATR-normalized duplicate-level merging
// • Fresh → Armed lifecycle
//
// Stage 2:
// • Wick/body sweep classification
// • Minimum and maximum ATR-normalized sweep depth
// • First-penetration and dual-side sweep protection
// • Armed → Swept transition and sweep metadata
//
// Stage 3:
// • Same Candle / Fast / Flexible / Custom reclaim windows
// • Loose / Balanced / Strict / Custom reclaim-strength modes
// • ATR close buffer and directional close-location validation
// • Reclaim candle body-strength validation
// • Same-candle directional wick-rejection validation
// • Optional directional candle-body requirement
// • Dual-side reclaim protection
// • Swept → Reclaimed → Consumed lifecycle
// • BUY RECLAIM / SELL RECLAIM labels
// • Reclaim alert conditions and dashboard memory
//
// Stage 4:
// • 0–100 Sweep Reclaim Quality Score
// • A+ / A / B setup classification
// • Loose / Balanced / Strict / Custom quality filters
// • Eight-component score decomposition
// • Grade-aware labels, tooltips, dashboard, and alerts
//
// Stage 5:
// • Long-only / short-only / both direction control
// • Highest-quality or nearest-level candidate selection
// • Any-signal or same-direction cooldown
// • Same-direction ATR cluster filter
// • Duplicate-bar protection
// • Opposite-signal conflict resolution
// • Confirmed chart and higher-timeframe EMA bias
// • Volatility and efficiency hard filters
// • Filtered-reclaim consume/retire behavior
// • Raw candidate → filtered candidate → final signal integration
//
// Stage 6:
// • Signal-close entry
// • Sweep-extreme stop-loss with ATR buffer
// • Configurable risk/reward take-profit
// • One-active-trade state and active-trade signal lock
// • Conservative same-bar TP/SL priority
// • Soft-glass TP/SL boxes and Entry/TP/SL lines
// • Historical trade structures with object cleanup
// • TP HIT / SL HIT labels and alerts
// • Wins, losses, win rate, Net R, and streak tracking
//
// Stage 7:
// • Full / Clean / Minimal / Mobile visual profiles
// • Lifecycle-aware level and label density controls
// • Full / Compact / Trade Only dashboards
// • Mobile-safe chart presentation
//
// Stage 8:
// • Dynamic alert() payloads with setup and trade details
// • Clean dashboard and publication-facing cleanup
//
// The built-in trade model is educational only and is not financial advice.
````
