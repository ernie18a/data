# MACD Momentum Entry Engine [trade_w_samet]

- url: https://www.tradingview.com/script/PVc2cBqP-MACD-Momentum-Entry-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;51ecc1eba78d4f3d8ec9f5f31c8eec4c
- version: 1.0

## Description

🎯 MACD Momentum Entry Engine [trade_w_samet]

MACD Momentum Entry Engine [trade_w_samet] is a structured momentum-analysis and visual trade-model indicator designed to help traders study confirmed MACD events, momentum quality, directional persistence, market regime, trend alignment, candle confirmation, and multi-target risk references directly from one coordinated workflow.

The script is built around one central idea:

A MACD event should not automatically become an entry signal.

Instead of treating every MACD crossover as equally meaningful, the engine first identifies the type of momentum event, then evaluates its strength, expansion, slope, acceleration, market environment, candle quality, directional persistence, and optional trend alignment before a permanent LONG or SHORT setup is accepted.

The indicator includes:

• Configurable MACD fast, slow, and signal lengths
• EMA, SMA, RMA, and WMA calculation options
• Early Trigger and Momentum Confirmed entry timing
• Reversal, Continuation, Zero-Line Reclaim, and Momentum Expansion setups
• A transparent 0–100 Momentum Quality Score
• Alignment, histogram strength, expansion, slope, and acceleration scoring
• Loose, Balanced, Strict, and Off quality modes
• A separate 0–100 Anti-Chop Market Regime Score
• ADX, price efficiency, EMA separation, and volatility-expansion analysis
• A separate 0–100 Entry Qualification Score
• Candle body, close location, MACD separation, persistence, impulse, and trigger-context analysis
• A final composite setup score
• A+, A, B, and C internal setup grades
• Optional chart EMA, confirmed higher-timeframe EMA, and combined trend bias
• Confirmed higher-timeframe calculations
• Zero-line directional filtering
• ATR-normalized absolute histogram-strength filtering
• Internal signal cooldown and same-bar re-entry protection
• One-active-trade-at-a-time visual management
• ATR-based and XAUUSD fixed-pip risk models
• Three visual take-profit levels
• Stop First and Targets First same-bar assumptions
• Equal-third internal trade-model accounting
• Active Entry, TP1, TP2, TP3, and SL lines
• Active reward and risk boxes on the main chart
• TP3-only historical trade-model preservation
• Separate SL, Closed TP1, Closed TP2, and TP3 result labels
• Adjustable LONG, SHORT, and result-label sizes
• MACD histogram, line, signal line, momentum background, and anti-chop background
• Neon LONG and SHORT dots directly on the MACD line
• A compact main-chart dashboard
• XAUUSD symbol verification and mismatch warning
• Static TradingView alert conditions
• Detailed dynamic alert() messages
• Data Window diagnostics
• Confirmed-close permanent signals

The purpose of this script is to provide a structured way to study when a MACD event is supported by broader momentum and market context.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable trades.
It does not execute broker orders.
It does not replace personal analysis, position sizing, or risk management.

[image]https://www.tradingview.com/x/nLmht8XO/[/image]


━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, MACD Momentum Entry Engine does the following:

• Calculates a configurable MACD using the selected average types.
• Separates the visual histogram scale from the calculation scale.
• Detects confirmed MACD crossovers and zero-line events.
• Identifies Reversal, Continuation, Zero-Line Reclaim, and Expansion setup types.
• Optionally accepts the event immediately through Early Trigger mode.
• Optionally arms the setup and waits for renewed momentum through Momentum Confirmed mode.
• Measures momentum alignment, histogram strength, histogram expansion, MACD slope, and acceleration.
• Produces separate bullish and bearish 0–100 Momentum Quality Scores.
• Measures market regime using ADX, directional efficiency, EMA separation, and volatility expansion.
• Produces a separate 0–100 Market Regime Score.
• Evaluates candle direction, body quality, close location, MACD separation, persistence, and price impulse.
• Produces separate bullish and bearish Entry Qualification Scores.
• Combines momentum, regime, and entry quality into a final composite score.
• Assigns an internal A+, A, B, or C grade.
• Applies optional chart EMA and confirmed higher-timeframe EMA bias.
• Applies zero-line, absolute-strength, cooldown, and trade-slot controls.
• Confirms permanent LONG and SHORT signals only after candle close.
• Opens one visual trade model from the confirmed signal-bar close.
• Calculates Entry, Stop Loss, TP1, TP2, and TP3.
• Tracks targets and stop events from the next candle onward.
• Applies the selected same-bar processing assumption.
• Preserves completed TP3 models when historical display is enabled.
• Removes trade drawings after SL, Closed TP1, or Closed TP2 outcomes.
• Converts the original entry label into the final result for non-TP3 outcomes.
• Adds a separate electric-purple FULL TARGET label for TP3 outcomes.
• Displays Momentum, Trend, Regime, Trade, Last Result, and Protection states in the bottom-right dashboard.
• Provides static and dynamic alert options.
• Exposes diagnostic values through TradingView’s Data Window.

The indicator does not use machine-learning prediction.

Its scores are not probabilities.

Its labels do not promise future direction.

The script is a rule-based educational momentum framework that explains how a raw MACD event becomes an accepted or rejected setup.


━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind MACD Momentum Entry Engine is that a crossover alone contains limited context.

A basic crossover only confirms that one MACD line has moved through another.

It does not automatically explain:

• whether the histogram is expanding
• whether momentum is accelerating
• whether the move is occurring in a directional or choppy market
• whether the signal candle supports the direction
• whether MACD separation is meaningful relative to recent behavior
• whether momentum has persisted
• whether price is aligned with an optional trend filter
• whether a recent signal already occurred
• whether a visual trade model is already active

The engine therefore uses a staged sequence:

MACD event
→ setup classification
→ momentum-quality scoring
→ optional trend-bias validation
→ anti-chop regime scoring
→ entry qualification
→ additional signal filters
→ confirmed signal
→ visual trade model
→ TP / SL lifecycle
→ result handling

For bullish conditions, the script studies upward MACD transitions, positive histogram alignment, renewed expansion, positive slope, positive acceleration, bullish candle behavior, and directional persistence.

For bearish conditions, the same process is mirrored.

The purpose is not to find the largest possible number of signals.

The purpose is to make the acceptance process visible, configurable, and understandable.


━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

MACD Momentum Entry Engine is not designed to be used as a blind buy/sell system.

A raw MACD event must move through multiple stages:

A crossover or momentum event appears
→ the event is classified
→ the momentum-quality layer is evaluated
→ the trend-bias layer is evaluated
→ the anti-chop layer is evaluated
→ the candle and entry-quality layer is evaluated
→ zero-line and absolute-strength filters are checked
→ cooldown and active-trade restrictions are checked
→ the setup must remain valid at candle close
→ a permanent LONG or SHORT setup is printed
→ Entry, SL, TP1, TP2, and TP3 are projected
→ the trade model is monitored from the following candle
→ the model closes at TP3 or Stop
→ the final chart result is preserved or cleaned

Each module serves a different purpose.

The MACD core defines the momentum relationship.

The setup engine identifies what kind of event occurred.

The momentum-quality engine measures the internal strength of that event.

The anti-chop engine measures whether the broader environment is directional enough for the selected mode.

The entry-qualification engine evaluates the signal candle and immediate price response.

The trend-bias engine optionally restricts direction.

The trade engine standardizes the visual risk framework.

The dashboard explains the current engine state.

This makes the script a coordinated momentum-analysis workflow rather than a basic crossover marker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script operates through connected calculation stages.

First, it calculates every supported moving-average type on every candle.

The selected average type is then used for the fast MACD average, slow MACD average, and signal average.

The MACD line is the difference between the selected fast and slow averages.

The histogram is the difference between the MACD line and the signal line.

[pine]
fastAverage = f_selectMa(macdMaType, fastEma, fastSma, fastRma, fastWma)
slowAverage = f_selectMa(macdMaType, slowEma, slowSma, slowRma, slowWma)
macdLine = fastAverage - slowAverage

signalLine = f_selectMa(signalMaType, signalEma, signalSma, signalRma, signalWma)
histogram = macdLine - signalLine
[/pine]


The histogram visual multiplier changes only the displayed column length.

It does not change:

• the MACD line
• the signal line
• the histogram used by calculations
• quality scores
• setup detection
• trade results

After the MACD core is calculated, the engine measures:

• absolute histogram strength
• one-bar histogram expansion
• MACD slope
• momentum acceleration
• adaptive baselines for each measurement

The setup engine then checks the enabled event types.

The quality, trend, regime, qualification, and additional-filter stages determine whether the setup is eligible.

A final permanent signal is accepted only after the candle closes and every enabled condition remains valid.


━━━━━━━━━━━━━━━━━━━━━━
🟢 BULLISH MACD MOMENTUM LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bullish setup begins with one of four enabled event types.

Bullish Reversal

A bullish MACD crossover occurs while the MACD line remains below zero.

This represents a momentum turn from the negative side of the zero line.

Bullish Continuation

A bullish MACD crossover occurs while the MACD line is at or above zero.

This represents renewed bullish alignment on the positive side.

Bullish Zero-Line Reclaim

The MACD line crosses above zero while:

• MACD is above the signal line
• the histogram is positive
• the bar is confirmed

Bullish Momentum Expansion

The histogram resumes positive expansion after a short contraction while:

• MACD remains above the signal line
• MACD slope is positive
• no new crossover is being used on the same bar
• no new zero-line cross is being used on the same bar

The event must then pass the active momentum-quality requirement.

When enabled, it must also pass:

• chart EMA bias
• confirmed higher-timeframe EMA bias
• EMA slope confirmation
• ATR distance from the trend EMA
• anti-chop regime requirement
• entry qualification
• bullish candle direction
• minimum MACD separation
• momentum persistence
• zero-line direction
• absolute histogram strength
• cooldown
• active-trade availability

The final signal uses confirmed-bar logic.

[pine]
bullishSignal =
     barstate.isconfirmed and
     bullishEntryCandidate and
     bullishZeroLinePass and
     absoluteStrengthPass and
     bullishQualityPass and
     bullishTrendPass and
     antiChopPass and
     bullishQualificationPass and
     bullishCandlePass and
     separationPass and
     bullishPersistencePass and
     cooldownPass and
     tradeSlotAvailable
[/pine]


When every active rule passes, the script can display:

• a neon green dot on the MACD line
• a LONG label on the main chart
• setup type, grade, and score information
• a visual Entry, SL, TP1, TP2, and TP3 model

This confirms that the configured bullish momentum conditions were valid at candle close.

It does not mean price must continue upward.


━━━━━━━━━━━━━━━━━━━━━━
🔴 BEARISH MACD MOMENTUM LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bearish setup mirrors the bullish process.

Bearish Reversal

A bearish MACD crossover occurs while the MACD line remains above zero.

This represents a momentum turn from the positive side of the zero line.

Bearish Continuation

A bearish MACD crossover occurs while the MACD line is at or below zero.

This represents renewed bearish alignment on the negative side.

Bearish Zero-Line Reclaim

The MACD line crosses below zero while:

• MACD is below the signal line
• the histogram is negative
• the bar is confirmed

Bearish Momentum Expansion

The histogram resumes negative expansion after a short contraction while:

• MACD remains below the signal line
• MACD slope is negative
• no new bearish crossover is being used on the same bar
• no new bearish zero-line cross is being used on the same bar

The setup must then pass the same quality, trend, regime, candle, separation, persistence, strength, cooldown, and trade-slot controls.

A permanent SHORT signal appears only when all active conditions remain valid at candle close.

The script can then display:

• a neon red dot on the MACD line
• a SHORT label on the main chart
• setup type, grade, and score information
• Entry, SL, TP1, TP2, and TP3 references

This confirms that the configured bearish momentum conditions were valid at candle close.

It does not guarantee continued downside movement.


━━━━━━━━━━━━━━━━━━━━━━
💎 MACD MOMENTUM QUALITY FILTER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes a separate bullish and bearish Momentum Quality Score.

The quality layer evaluates five components.

Alignment — maximum 20 points

Bullish alignment requires:

• MACD above the signal line
• positive histogram

Bearish alignment requires:

• MACD below the signal line
• negative histogram

Histogram Strength — maximum 25 points

The absolute histogram value is compared with an adaptive EMA baseline.

This measures whether current separation is meaningful relative to recent MACD behavior.

Histogram Expansion — maximum 20 points

The engine measures the one-bar change in absolute histogram strength.

Points are awarded only when the histogram is expanding in the setup direction.

MACD Slope — maximum 20 points

Bullish setups require positive slope for this component.

Bearish setups require negative slope.

The slope magnitude is compared with its own adaptive baseline.

Momentum Acceleration — maximum 15 points

Acceleration measures the change in MACD slope.

Positive acceleration supports bullish scoring.

Negative acceleration supports bearish scoring.

[pine]
bullishQualityScore = f_clamp(
     bullishAlignmentScore +
     bullishHistogramStrengthScore +
     bullishExpansionScore +
     bullishSlopeScore +
     bullishAccelerationScore,
     0.0,
     100.0
[/pine]

The available quality modes are:

Off

Removes the minimum Momentum Quality Score restriction.

Loose

Requires a minimum score of 45.

Balanced

Requires a minimum score of 60.

Strict

Requires a minimum score of 75 and is the default.

The score is not a win rate.

It is not a probability.

It measures how closely the current MACD event matches the engine’s momentum-strength framework.


━━━━━━━━━━━━━━━━━━━━━━
📏 VOLATILITY / ATR NORMALIZATION FILTER
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses ATR normalization to compare certain values across changing volatility conditions.

The Absolute Strength Filter calculates:

Absolute Histogram Strength = |Histogram| / ATR × 100.

This value is used as an additional minimum-strength condition.

The default settings are:

• Normalization ATR Length: 14
• Minimum Absolute Strength: 1.0
• Use Absolute Strength Filter: enabled

ATR normalization helps reduce dependence on the raw numerical scale of a market.

For example, a raw MACD histogram value cannot be compared directly across instruments with very different prices and volatility.

Normalization places the histogram in relation to the instrument’s recent ATR.

The same ATR framework is also used by:

• optional price-to-EMA trend buffers
• EMA-separation regime measurement
• price-impulse scoring
• ATR-based trade management

ATR normalization does not make one configuration universal.

Symbols, sessions, exchanges, and data feeds can still behave differently.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ DISPLACEMENT QUALITY FILTER
━━━━━━━━━━━━━━━━━━━━━━

The entry-qualification engine evaluates whether the signal candle shows enough directional response.

The Candle component contributes up to 25 points.

It is divided into:

Directional Body — maximum 12.5 points

For bullish setups, the engine measures the positive candle body relative to the full candle range.

For bearish setups, it measures the negative body.

Close Location — maximum 12.5 points

Bullish setups receive more points when the close is nearer the candle high.

Bearish setups receive more points when the close is nearer the candle low.

Price Impulse contributes up to 15 additional points.

The engine compares the one-bar directional price movement with ATR.

A bullish price impulse measures positive close-to-close displacement.

A bearish price impulse measures negative close-to-close displacement.

This layer does not predict the next candle.

It measures whether the completed signal candle supports the direction of the MACD event.


━━━━━━━━━━━━━━━━━━━━━━
📊 REACTION STRENGTH FILTER
━━━━━━━━━━━━━━━━━━━━━━

The engine includes a separate Entry Qualification Score.

Its components are:

Candle Quality — maximum 25 points

Combines directional body and close location.

MACD Separation — maximum 25 points

Measures current histogram separation relative to its adaptive baseline.

Momentum Persistence — maximum 20 points

Measures how long directional MACD and histogram alignment has remained active.

Price Impulse — maximum 15 points

Measures directional close-to-close movement relative to ATR.

Trigger Context — maximum 15 points

Confirms that an eligible setup event is currently active.

The total is limited to 0–100.

Available modes are:

Off

Removes the minimum Entry Qualification Score restriction.

Loose

Requires a minimum score of 45.

Balanced

Requires a minimum score of 60.

Strict

Requires a minimum score of 75 and is the default.

The final signal also uses internal candle-direction, separation, and persistence requirements.

These internal parameters remain active in the background to keep the public settings menu cleaner.

The Entry Qualification Score is not a verified accuracy figure.

It describes the quality of the completed entry context according to the script’s rules.


━━━━━━━━━━━━━━━━━━━━━━
🧼 CONFIRMED SIGNAL FILTER
━━━━━━━━━━━━━━━━━━━━━━

Permanent LONG and SHORT signals wait for candle close.

The engine uses confirmed-bar checks on:

• MACD crossovers
• zero-line crossings
• expansion triggers
• momentum confirmation
• final LONG and SHORT conditions

The higher-timeframe trend layer also uses previous completed higher-timeframe values.

[pine]
htfConfirmedClose = request.security(
     syminfo.tickerid,
     higherTimeframe,
     close[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

htfConfirmedEma = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, trendLength)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)
[/pine]


This approach prevents an unfinished higher-timeframe candle from becoming the permanent trend reference.

Entry Timing provides two workflows.

Early Trigger

Uses the confirmed setup event directly.

Momentum Confirmed

Arms the setup and waits for a later confirmed candle with:

• continued MACD alignment
• directional histogram
• renewed histogram expansion
• directional MACD slope

The confirmation opportunity is temporary.

If renewed momentum does not appear inside the internal window, the armed setup expires.

The script does not plot final signals into earlier candles.

Historical results can still change when:

• settings change
• symbol data changes
• timeframe changes
• the data provider revises history
• the available chart-history range changes


━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY MODEL
━━━━━━━━━━━━━━━━━━━━━━

When a final LONG or SHORT setup passes every enabled condition, the trade engine can create a visual trade model.

The Entry reference is the close of the confirmed signal candle.

For a LONG model:

• Stop is below Entry
• TP1 is above Entry
• TP2 is above TP1
• TP3 is above TP2

For a SHORT model:

• Stop is above Entry
• TP1 is below Entry
• TP2 is below TP1
• TP3 is below TP2

[pine]
tradeEntryPrice := close
tradeStopPrice := tradeEntryPrice - selectedStopDistance
tradeTp1Price := tradeEntryPrice + selectedTp1Distance
tradeTp2Price := tradeEntryPrice + selectedTp2Distance
tradeTp3Price := tradeEntryPrice + selectedTp3Distance
[/pine]


The model begins checking TP and SL from the following candle.

This prevents the signal candle’s earlier high or low from being treated as though it occurred after the close-based entry.

The engine stores:

• direction
• entry bar
• entry price
• stop price
• TP1 price
• TP2 price
• TP3 price
• initial risk
• target R values
• TP1 and TP2 progress
• setup type
• setup grade
• risk model
• original signal label

The displayed model is an educational chart reference.

It is not a broker order.


━━━━━━━━━━━━━━━━━━━━━━
🛑 ATR STOP-LOSS MODEL
━━━━━━━━━━━━━━━━━━━━━━

The indicator includes two risk models.

ATR Based

Stop distance is calculated as:

ATR × ATR Stop Multiplier.

The default settings are:

• ATR Length: 14
• ATR Stop Multiplier: 1.50
• TP1: 0.50R
• TP2: 1.00R
• TP3: 1.50R

The minimum distance is protected by the symbol’s minimum tick.

XAUUSD Fixed Pips

Stop and target distances use:

Selected Pips × XAUUSD Pip Size.

The default settings are:

• Pip Size: 0.01
• Stop Loss: 1000 pips
• TP1: 500 pips
• TP2: 1000 pips
• TP3: 1500 pips

Under the common 0.01 convention, those values correspond to:

• Stop distance: 10.00 price units
• TP1 distance: 5.00 price units
• TP2 distance: 10.00 price units
• TP3 distance: 15.00 price units

Broker conventions can differ.

Users should verify their symbol specification before relying on fixed-pip distances.

The XAUUSD protection system checks the symbol.

The dashboard shows:

• ✅ XAUUSD VERIFIED when XAUUSD Fixed Pips is used on a recognized XAUUSD symbol
• ⚠️ CHECK SYMBOL when the mode is used on another symbol
• 🛡️ ATR MODE when ATR Based is selected

The warning does not block calculations.

It tells the user to verify pip size and target distances.


━━━━━━━━━━━━━━━━━━━━━━
🎯 TAKE-PROFIT RR MODEL
━━━━━━━━━━━━━━━━━━━━━━

The visual model contains three take-profit levels.

ATR Based mode calculates targets from the initial stop distance:

TP1 Distance = Initial Risk × TP1 RR.

TP2 Distance = Initial Risk × TP2 RR.

TP3 Distance = Initial Risk × TP3 RR.

XAUUSD Fixed Pips mode uses independent fixed target distances.

The script enforces the following order:

TP1 < TP2 < TP3.

If a selected value would violate that order, the next target is moved at least one minimum tick beyond the prior target.

The trade model internally treats the position as three equal portions.

Each target represents one-third of the model.

If Stop is reached after TP1 or TP2, the script calculates an internal net-R result from:

• the portions already modeled as closed at reached targets
• the remaining portion or portions modeled at Stop

This internal calculation supports Data Window counters.

It is not broker-verified performance.

It does not account for:

• spread
• commission
• slippage
• latency
• partial-fill differences
• financing
• order rejection
• execution venue behavior


━━━━━━━━━━━━━━━━━━━━━━
📦 ACTIVE TP / SL BOX SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

When a confirmed trade model opens, the script can draw on the main chart:

• Entry line
• TP1 line
• TP2 line
• TP3 line
• Stop Loss line
• TP1 reward box
• TP2 reward box
• TP3 reward box
• SL risk box
• LONG or SHORT label

The Entry line is white.

The TP lines are green and initially dashed.

The SL line is red and solid.

The SL box uses a solid border.

When a target is reached:

• the corresponding box becomes more visible
• the corresponding target line becomes solid
• the target line becomes thicker
• the dynamic target alert can fire

When TP3 is reached:

• the complete model closes
• the original LONG or SHORT label remains
• a separate electric-purple TP3 FULL TARGET label appears
• the trade model can remain historically visible

When the model closes at Stop before TP3:

• all active boxes are deleted
• all active trade lines are deleted
• the original LONG or SHORT label is converted into the final result
• the final result becomes SL, CLOSED TP1, or CLOSED TP2

Only TP3 outcomes can retain completed historical boxes and lines.

This is a chart-cleanliness decision.

It does not imply that other outcomes did not occur.


━━━━━━━━━━━━━━━━━━━━━━
🚦 ONE ACTIVE TRADE AT A TIME
━━━━━━━━━━━━━━━━━━━━━━

The script uses one-active-trade-at-a-time visual management.

When the trade engine is enabled:

• a new trade model cannot open while another model is active
• a new trade cannot open on the same candle that closed the previous model
• the internal setup engine continues calculating
• permanent signals are restricted by trade-slot availability

This prevents overlapping Entry, TP, and SL structures.

It also keeps the trade lifecycle easier to interpret.

When the trade engine is disabled, qualified signals can still be evaluated without opening a visual trade model.

The one-active-model rule is a visual and analytical design choice.

It does not restrict the user’s personal trading activity.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TP / SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

Trade monitoring begins after the entry candle.

If a later historical candle touches both Stop and one or more targets, standard OHLC data does not reveal the exact intrabar sequence.

The indicator therefore provides two assumptions.

Stop First

If Stop and a target are both touched on the same candle, Stop is processed first.

This is the default and more conservative assumption.

Targets First

Reached targets are processed before Stop.

If TP3 is reached, the model closes at TP3.

Otherwise, remaining portions can close at Stop.

Neither mode reconstructs tick-level execution.

The indicator does not know:

• whether the high occurred before the low
• the bid/ask path
• actual fill sequence
• spread at the time
• slippage
• queue priority
• partial fills

The selected same-bar rule is a modeling assumption required by the limits of OHLC candles.


━━━━━━━━━━━━━━━━━━━━━━
🏷️ MACD MOMENTUM LABELS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses separate entry and result labels.

Entry labels display:

🚀 LONG

or:

🔴 SHORT

Entry Label Content provides:

Direction Only

Displays only LONG or SHORT.

Grade

Displays direction and setup grade.

Score + Grade

Displays direction, grade, and rounded composite score.

The default is Score + Grade.

LONG and SHORT label sizes can be adjusted independently.

Both default to Small.

The label tooltip contains:

• setup direction
• setup type
• setup grade
• composite score
• Momentum Quality Score
• Entry Qualification Score
• Market Regime Score
• trend-bias state

Result labels include:

🛑 SL

⚠️ CLOSED TP1

✅ CLOSED TP2

🏆 TP3 HIT
✅ FULL TARGET

SL, Closed TP1, and Closed TP2 transform the original entry label.

TP3 creates a separate result label and preserves the original entry label.

All chart-label text uses bold and italic formatting.


━━━━━━━━━━━━━━━━━━━━━━
📍 MACD DISPLAY MODES
━━━━━━━━━━━━━━━━━━━━━━

The indicator operates in a separate MACD pane while selected trade visuals, entry labels, and the dashboard are forced onto the main price chart.

The MACD pane can display:

MACD Line

A white line representing the difference between the selected fast and slow averages.

Signal Line

A red line representing the selected signal smoothing.

Histogram

Color changes communicate momentum condition:

• stronger green for bullish expansion
• softer green for bullish contraction
• stronger red for bearish expansion
• softer red for bearish contraction

Histogram Visual Length

The default multiplier is 1.60.

This changes visual column length only.

It does not affect calculations.

Neon Signal Dots

Qualified LONG setups produce a neon green glow and center dot on the MACD line.

Qualified SHORT setups produce a neon red glow and center dot.

Momentum Background

The pane background changes according to strong or weak bullish and bearish momentum states.

Anti-Chop Background

A neutral gray background can identify conditions blocked by the Anti-Chop Engine.

Each major visual element can be shown or hidden independently.


━━━━━━━━━━━━━━━━━━━━━━
🧹 SETUP INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━

Not every raw MACD event remains eligible.

A setup can be rejected or expire because:

• its momentum score is below the selected threshold
• trend bias does not permit the direction
• the market regime is below the active Anti-Chop threshold
• the Entry Qualification Score is insufficient
• candle direction does not support the setup
• MACD separation is insufficient
• directional persistence is insufficient
• the zero-line filter blocks the direction
• normalized histogram strength is too low
• the signal cooldown is active
• another visual trade is active
• a trade closed on the current candle
• Momentum Confirmed mode does not receive renewed expansion in time
• an opposite raw setup replaces the armed direction

The internal cooldown is eight bars.

Momentum Confirmed mode uses a temporary internal confirmation window.

These background controls are intentionally not exposed as advanced public inputs.

They remain part of the engine’s consistency rules.

A rejected event is not displayed as a permanent entry signal.


━━━━━━━━━━━━━━━━━━━━━━
📟 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The indicator includes a compact dashboard in the bottom-right corner of the main price chart.

The dashboard displays:

Momentum

Possible states include:

• STRONG LONG
• LONG
• STRONG SHORT
• SHORT
• NEUTRAL

Trend

Possible states include:

• BULLISH
• BEARISH
• NEUTRAL
• OFF

Regime

Possible states include:

• TRENDING
• DEVELOPING
• CHOP
• OFF

Trade

Possible states include:

• WAITING
• LONG ACTIVE
• LONG TP1 REACHED
• LONG TP2 REACHED
• SHORT ACTIVE
• SHORT TP1 REACHED
• SHORT TP2 REACHED

Last

Displays the most recent closed model result:

• SL
• CLOSED TP1
• CLOSED TP2
• TP3

Protection

Displays:

• ATR MODE
• XAUUSD VERIFIED
• CHECK SYMBOL

The dashboard is not TradingView Strategy Tester.

It does not display audited brokerage results.

Its states are based on the indicator’s own rule-based calculations.


━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

MACD Momentum Entry Engine includes static TradingView alert conditions for:

• MACD Momentum LONG
• MACD Momentum SHORT
• TP1
• TP2
• TP3
• Stop Loss
• XAUUSD Mode Warning

The XAUUSD warning condition is limited to a qualified entry bar when Fixed Pips mode is active on a non-XAUUSD symbol.

The script also includes detailed dynamic alert() messages.

Dynamic Entry messages can include:

• direction
• symbol
• timeframe
• setup type
• setup grade
• composite score
• risk model
• Entry
• Stop Loss
• TP1
• TP2
• TP3
• XAUUSD mismatch warning when relevant

Dynamic target messages can include:

• target name
• direction
• symbol
• timeframe
• reached target price
• Entry
• Stop Loss
• TP1
• TP2
• TP3

Dynamic stop messages can include:

• final result
• direction
• symbol
• timeframe
• Entry
• exit price
• Stop Loss
• whether TP1 or TP2 was reached first

Alerts are monitoring tools.

They do not place or manage broker orders.


━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

For static conditions:

1. Add MACD Momentum Entry Engine [trade_w_samet] to the chart.
2. Open TradingView’s Create Alert window.
3. Select the indicator as the condition.
4. Choose LONG, SHORT, TP1, TP2, TP3, SL, or XAUUSD Mode Warning.
5. Select a frequency appropriate for confirmed-candle monitoring.
6. Test the alert before relying on it.

For detailed dynamic messages:

1. Enable Detailed Dynamic Alerts in the indicator settings.
2. Open TradingView’s Create Alert window.
3. Select MACD Momentum Entry Engine [trade_w_samet].
4. Select Any alert() function call.
5. Configure the delivery method.
6. Test the complete message format.

Alert delivery can depend on:

• TradingView servers
• the selected symbol
• the selected timeframe
• market-data availability
• realtime feed status
• user alert configuration
• webhook or external-service availability

Creating an alert does not guarantee broker execution.


━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add MACD Momentum Entry Engine [trade_w_samet] to a standard candlestick chart.
2. Begin with the default MACD values of 12, 26, and 9.
3. Keep Entry Timing on Early Trigger while learning the setup types.
4. Keep Momentum Quality on Strict for the default selective profile.
5. Keep Anti-Chop on Strict.
6. Keep Entry Qualification on Strict.
7. Observe whether the event is Reversal, Continuation, Zero Reclaim, or Expansion.
8. Review the MACD histogram, line relationship, and neon signal dot.
9. Review the main-chart LONG or SHORT label.
10. Open the label tooltip to inspect the scores and setup type.
11. Review Momentum, Trend, Regime, Trade, Last Result, and Protection in the dashboard.
12. Verify the selected risk model.
13. When using XAUUSD Fixed Pips, confirm XAUUSD VERIFIED.
14. Treat Entry, SL, TP1, TP2, and TP3 as planning references.
15. Use alerts for monitoring rather than blind execution.
16. Compare every setup with personal structure, session, volatility, and risk rules.
17. Test the exact symbol, timeframe, session, and data feed personally used.

The indicator is designed for structured review.

It should not be treated as an automatic decision-maker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚙️ MACD Core

Calculation Source

Selects the price source used by the MACD calculation.

Fast Length

Controls the fast average.

Default: 12.

Slow Length

Controls the slow average.

Default: 26.

Signal Length

Controls signal-line smoothing.

Default: 9.

MACD Average Type

Selects EMA, SMA, RMA, or WMA for the fast and slow averages.

Signal Average Type

Selects EMA, SMA, RMA, or WMA for the signal line.

━━━━━━━━━━━━━━━━━━━━━━

🎯 Entry Engine

Entry Timing

Early Trigger accepts the confirmed setup event directly.

Momentum Confirmed waits for renewed directional histogram expansion and MACD continuation after the setup is armed.

━━━━━━━━━━━━━━━━━━━━━━

🧠 Momentum Quality Engine

Quality Filter

Selects Off, Loose, Balanced, or Strict.

Strict is the default.

The score combines:

• alignment
• histogram strength
• histogram expansion
• MACD slope
• momentum acceleration

━━━━━━━━━━━━━━━━━━━━━━

📈 Trend Bias Engine

Trend Bias Mode

Selects:

• Off
• Chart EMA
• Higher Timeframe EMA
• Combined EMA

Off is the default.

Trend EMA Length

Controls the chart and higher-timeframe EMA.

Default: 200.

Chart EMA Slope Lookback

Controls the chart-bar lookback used to evaluate EMA direction.

Require EMA Slope Confirmation

Requires a rising EMA for LONG and falling EMA for SHORT.

Higher Timeframe

Selects the confirmed higher-timeframe context.

Default: 60 minutes.

Price-to-EMA ATR Buffer

Requires an optional minimum ATR-normalized distance between price and the trend EMA.

Zero disables the distance requirement.

━━━━━━━━━━━━━━━━━━━━━━

🧱 Anti-Chop Engine

Anti-Chop Filter

Selects Off, Loose, Balanced, or Strict.

Strict is the default.

The regime score combines:

• ADX — 35 points
• price efficiency — 30 points
• EMA separation — 20 points
• volatility expansion — 15 points

━━━━━━━━━━━━━━━━━━━━━━

✅ Entry Qualification Engine

Enable Reversal Setups

Allows MACD crossovers on the opposite side of zero.

Enable Continuation Setups

Allows MACD crossovers on the directional side of zero.

Enable Zero-Line Reclaims

Allows confirmed MACD zero-line crossings with aligned histogram and signal-line conditions.

Enable Momentum Expansions

Allows renewed histogram expansion after contraction while MACD alignment remains valid.

Entry Qualification Filter

Selects Off, Loose, Balanced, or Strict.

Strict is the default.

The score combines:

• candle quality
• MACD separation
• persistence
• price impulse
• trigger context

━━━━━━━━━━━━━━━━━━━━━━

💼 Trade Management Engine

Enable Trade Engine

Enables the one-active-trade-at-a-time visual model.

Risk Model

Selects ATR Based or XAUUSD Fixed Pips.

XAUUSD Fixed Pips is the default.

ATR Length

Controls ATR for the adaptive model.

ATR Stop Multiplier

Controls stop distance in ATR mode.

ATR TP1 Risk/Reward

Controls TP1 distance in ATR mode.

ATR TP2 Risk/Reward

Controls TP2 distance in ATR mode.

ATR TP3 Risk/Reward

Controls TP3 distance in ATR mode.

XAUUSD Pip Size

Controls the price-unit value of one selected pip.

XAUUSD Stop-Loss Pips

Controls fixed Stop distance.

XAUUSD TP1 Pips

Controls fixed TP1 distance.

XAUUSD TP2 Pips

Controls fixed TP2 distance.

XAUUSD TP3 Pips

Controls fixed TP3 distance.

Same-Bar Resolution

Selects Stop First or Targets First.

Show Active TP / SL Zones

Shows Entry, targets, Stop, boxes, and lines on the main chart.

Keep Historical TP3 Zones

Preserves completed TP3 models.

Historical TP3 Trade Limit

Limits completed TP3 models retained on the chart.

Trade Result Labels

Enables SL, Closed TP1, Closed TP2, and TP3 result labels.

SL Label Size

Controls SL result size.

Closed TP1 Label Size

Controls Closed TP1 result size.

Closed TP2 Label Size

Controls Closed TP2 result size.

TP3 Label Size

Controls the separate FULL TARGET label size.

━━━━━━━━━━━━━━━━━━━━━━

🛡️ Signal Filters

Zero-Line Filter

Off allows both sides of zero.

Trend Direction requires LONG above zero and SHORT below zero.

Trend Direction is the default.

Use Absolute Strength Filter

Enables ATR-normalized minimum histogram strength.

Normalization ATR Length

Controls normalization.

Minimum Absolute Strength

Controls the required normalized histogram value.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Visual Settings

Show MACD Line

Shows or hides the MACD line.

Show Signal Line

Shows or hides the signal line.

Show Histogram

Shows or hides histogram columns.

Histogram Visual Length

Changes histogram display scale without changing calculations.

Show MACD Neon Signal Dots

Shows qualified LONG and SHORT dots on the MACD line.

Show Momentum Background

Shows directional momentum background states.

Highlight Blocked Chop Conditions

Shows a neutral background when Anti-Chop blocks entries.

Show LONG / SHORT Labels

Shows or hides main-chart entry labels.

Entry Label Content

Selects Direction Only, Grade, or Score + Grade.

LONG Label Size

Controls LONG label size.

SHORT Label Size

Controls SHORT label size.

━━━━━━━━━━━━━━━━━━━━━━

📟 Mini Dashboard

Show Mini Dashboard

Shows or hides the compact bottom-right main-chart dashboard.

━━━━━━━━━━━━━━━━━━━━━━

🔔 Dynamic Alerts

Enable Detailed Dynamic Alerts

Enables runtime alert() messages.

For these messages, create the TradingView alert using:

Any alert() function call.

Input values are hidden from the status line.

MACD plot values are also prevented from creating status-line or price-scale labels, while diagnostic values remain available in the Data Window.


━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

MACD, moving averages, ATR, ADX, and trend filters are familiar technical-analysis concepts.

These concepts are not unique by themselves.

The originality of MACD Momentum Entry Engine lies in the coordinated process applied to a MACD event:

Configurable MACD event
→ setup-type classification
→ adaptive momentum-strength baselines
→ five-component Momentum Quality Score
→ optional confirmed trend-bias layer
→ four-component Anti-Chop Regime Score
→ five-component Entry Qualification Score
→ final composite score and grade
→ zero-line and normalized-strength validation
→ confirmed-close signal
→ one-active multi-target trade lifecycle
→ TP3-only historical preservation
→ non-TP3 visual cleanup
→ dynamic alerts
→ main-chart diagnostic dashboard
→ XAUUSD mode verification

Distinctive implementation features include:

• four separate setup families
• different logic for Reversal and Continuation crossovers
• zero-line reclaim detection
• renewed expansion detection without requiring a fresh crossover
• adaptive baselines for strength, expansion, slope, and acceleration
• separate bullish and bearish scoring
• a Momentum Quality Score independent from Entry Qualification
• an Anti-Chop Score independent from momentum quality
• confirmed previous higher-timeframe EMA values
• a 70/30 final composite structure
• A+, A, B, and C grades
• visual-only histogram scaling
• equal-third multi-target internal accounting
• same-candle processing assumptions
• XAUUSD symbol verification
• separate result behavior for TP3 and non-TP3 outcomes
• detailed Data Window diagnostics

The script is not a simple combination of unrelated indicators.

Every module supports the same objective: determining whether a confirmed MACD event has enough momentum, market, and entry context to become a permanent visual setup.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

Signal frequency depends on:

• fast, slow, and signal lengths
• selected average types
• Entry Timing
• enabled setup families
• Momentum Quality mode
• Trend Bias mode
• EMA length
• higher timeframe
• EMA slope requirement
• price-to-EMA buffer
• Anti-Chop mode
• Entry Qualification mode
• zero-line filter
• absolute-strength threshold
• symbol
• timeframe
• session
• volatility
• available history
• data provider
• active-trade state

Strict modes reduce accepted signals.

They do not guarantee better results.

Trend Bias Off allows the momentum engine to evaluate both directions without EMA permission.

Higher Timeframe EMA and Combined EMA should use a timeframe meaningfully above the chart timeframe.

XAUUSD Fixed Pips is designed around a selectable pip convention.

The default 0.01 value may not match every broker or synthetic symbol.

Momentum Confirmed produces later and potentially fewer signals than Early Trigger.

Histogram Visual Length does not alter logic.

Changing settings recalculates historical signals and trade models.

A setup that looks different after changing the chart range may be affected by available historical data and adaptive baselines.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

It does not guarantee profitable trades.
It does not predict future price movement.
It does not execute orders.
It does not place broker stops or targets.
It does not include spread.
It does not include commission.
It does not include slippage.
It does not include latency.
It does not model partial fills.
It does not model financing or swap.
It uses bar-based OHLC data.
Historical candles do not reveal exact intrabar order.
Stop First and Targets First are assumptions.
The setup score is not a win probability.
A+ is not a guaranteed outcome.
The Anti-Chop Score cannot identify every ranging condition.
Trend filters can delay or block valid reversals.
Trend Bias Off can allow countertrend signals.
ATR normalization does not make settings universal.
Fixed-pip conventions can differ between brokers.
XAUUSD symbol detection cannot verify a broker’s contract specification.
The dashboard is not TradingView Strategy Tester.
Data Window counters are not audited account performance.
The internal R model assumes three equal portions.
The internal model does not represent real position sizing.
One-active-trade logic is a visual-management rule.
Alert delivery depends on TradingView and user configuration.
Changing settings changes historical calculations.
Changing symbol, exchange, session, timeframe, or feed can change signals.
Adaptive baselines depend on available chart history.
Confirmed higher-timeframe values reduce unfinished-HTF changes but introduce delay.
Permanent signals wait for candle close and therefore do not capture the earliest intrabar moment.

For these reasons, the indicator should be used as an educational decision-support tool, not as a standalone automated strategy.


━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• already understand basic MACD behavior
• want more context than a raw crossover
• study momentum expansion and contraction
• distinguish reversal, continuation, zero-line, and expansion events
• want transparent setup scoring
• want an anti-chop layer
• want optional chart and higher-timeframe trend context
• prefer confirmed-close signals
• want Entry, SL, and three target references
• use XAUUSD and want configurable fixed-pip distances
• want symbol-mismatch warnings
• want a compact dashboard
• want detailed alerts
• want diagnostic Data Window values
• prefer one active visual model at a time

It may be less suitable for users who:

• want guaranteed signals
• want a fully automated trading bot
• want every MACD crossover displayed
• expect a score to equal probability
• expect one setting to work on every market
• require exact tick-level execution
• want Strategy Tester results from an indicator
• want the indicator to replace personal judgment
• expect alerts to execute broker orders automatically


━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For the default selective profile:

• use standard candlesticks
• begin with MACD 12 / 26 / 9
• keep Entry Timing on Early Trigger
• keep Momentum Quality on Strict
• keep Anti-Chop on Strict
• keep Entry Qualification on Strict
• keep the Zero-Line Filter on Trend Direction
• keep Absolute Strength enabled
• keep all four setup families enabled while learning
• use the dashboard to identify blocked regime conditions
• verify the selected risk model before reviewing trade levels
• use Stop First for conservative historical same-bar handling
• confirm XAUUSD VERIFIED when using Fixed Pips
• use alerts for monitoring rather than blind execution

For additional frequency:

• change Momentum Quality from Strict to Balanced
• change Anti-Chop from Strict to Balanced
• change Entry Qualification from Strict to Balanced
• disable the Zero-Line Filter
• disable Absolute Strength
• keep Trend Bias Off
• use Early Trigger

For additional directional restriction:

• use Chart EMA, Higher Timeframe EMA, or Combined EMA
• enable EMA slope confirmation
• add a Price-to-EMA ATR Buffer
• use a higher timeframe above the chart timeframe
• use Momentum Confirmed instead of Early Trigger

Always:

• wait for the setup candle to close
• review the setup type
• review the score components
• verify market structure independently
• review session and volatility
• verify the stop distance
• use personal position sizing
• test the exact symbol and timeframe
• understand the same-bar assumption
• treat all projected levels as analytical references


━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

MACD Momentum Entry Engine [trade_w_samet] is published as an educational momentum-analysis and visual trade-model tool.

The purpose of this description is to explain:

• how the configurable MACD core is calculated
• how average types affect the MACD and signal lines
• how setup events are classified
• how Reversal setups work
• how Continuation setups work
• how Zero-Line Reclaim setups work
• how Momentum Expansion setups work
• how Early Trigger and Momentum Confirmed differ
• how the Momentum Quality Score is constructed
• how adaptive momentum baselines work
• how the Anti-Chop Score is constructed
• how the Entry Qualification Score is constructed
• how final composite scores and grades are assigned
• how chart and confirmed higher-timeframe trend filters work
• how zero-line and absolute-strength filters work
• when permanent signals appear
• how the one-active-trade model works
• how Entry and Stop are calculated
• how TP1, TP2, and TP3 are calculated
• how same-candle ambiguity is handled
• how historical TP3 visuals are retained
• how non-TP3 visuals are cleaned
• how result labels behave
• what the dashboard displays
• how XAUUSD protection works
• what static and dynamic alerts contain
• what diagnostic values are available
• what the timing limitations are
• what the model does not simulate
• why familiar MACD concepts are organized into an original workflow

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It should not be used as a blind LONG/SHORT system.

MAIN CHART SCREENSHOT PLAN

Use one clean standard candlestick chart.

Show the indicator with its default settings.

The screenshot should contain:

• complete symbol and timeframe information
• the indicator name
• visible standard price candles
• one clear LONG or SHORT label
• one active or completed Entry / TP / SL model
• the white Entry line
• green TP1, TP2, and TP3 levels
• the red SL area and solid SL line
• the MACD pane
• the white MACD line
• the red signal line
• the green/red histogram
• one neon MACD signal dot
• the bottom-right main-chart dashboard
• the Protection state

Do not include:

• other indicators
• manual drawings
• unrelated labels
• social-media links
• pricing information
• promotional claims
• account-profit screenshots
• win-rate claims
• non-standard candles
• hidden symbol or timeframe information
• excessive zoom
• decorative graphics unrelated to the script

The screenshot should demonstrate normal default behavior and make the relationship between the MACD event, main-chart signal, trade model, and dashboard easy to understand.


━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

MACD Momentum Entry Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, or tax advice.

No indicator can guarantee future results.

Markets are uncertain.

Momentum changes.

Volatility changes.

Liquidity changes.

Historical chart behavior does not ensure future performance.

Every user is responsible for their own:

• analysis
• validation
• risk management
• position sizing
• alert configuration
• trading decisions
• broker execution
• legal obligations
• tax obligations

The MACD line, signal line, histogram, momentum states, setup types, quality scores, regime scores, entry scores, composite scores, grades, trend states, LONG and SHORT labels, Entry references, Stop Loss levels, take-profit levels, boxes, result labels, Data Window values, dashboard states, internal counters, and alerts are visual analysis tools only.

The displayed Entry is not a guaranteed fill.

The displayed Stop Loss is not a broker order.

The displayed TP1, TP2, and TP3 levels are not guaranteed objectives.

The Momentum Quality Score is not a win probability.

The Entry Qualification Score is not a probability.

The Market Regime Score is not a guarantee that a market is trending.

The A+, A, B, and C grades are not promises of performance.

The internal trade model does not include spread, commissions, slippage, latency, order-book conditions, contract specifications, or partial fills.

Use this script as a structured MACD momentum-review and decision-support framework, not as a promise of profitability or a substitute for independent judgment.

## Source Code

````pine
//@version=6
//=============================================================================
// MACD Momentum Entry Engine [trade_w_samet]
// Final Release v1.0
//
// • Confirmed-close, non-repaint signal workflow
// • Confirmed higher-timeframe bias values
// • Adaptive momentum, anti-chop and entry qualification engines
// • ATR / XAUUSD fixed-pip trade management
// • Detailed dynamic alerts and main-chart mini dashboard
//
// Educational analysis tool only. Not financial advice.
//=============================================================================
indicator("MACD Momentum Entry Engine [trade_w_samet]", shorttitle = "MACD Momentum Entry Engine [trade_w_samet]", overlay = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//══════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
//══════════════════════════════════════════════════════════════════════

f_selectMa(string maType, float emaValue, float smaValue, float rmaValue, float wmaValue) =>
    float selectedValue = emaValue

    switch maType
        "EMA" => selectedValue := emaValue
        "SMA" => selectedValue := smaValue
        "RMA" => selectedValue := rmaValue
        "WMA" => selectedValue := wmaValue
        => selectedValue := emaValue

    selectedValue

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_componentScore(float value, float baseline, float targetMultiplier, float maximumPoints) =>
    float safeValue = nz(value, 0.0)
    float safeBaseline = math.max(nz(baseline, 0.0), 0.0000001)
    float safeTarget = math.max(targetMultiplier, 0.01)
    float relativePower = safeValue / (safeBaseline * safeTarget)

    f_clamp(relativePower, 0.0, 1.0) * maximumPoints

f_targetScore(float value, float target, float maximumPoints) =>
    float safeValue = math.max(nz(value, 0.0), 0.0)
    float safeTarget = math.max(target, 0.0000001)

    f_clamp(safeValue / safeTarget, 0.0, 1.0) * maximumPoints

f_qualityGrade(float score) =>
    string grade = "C"

    if score >= 85.0
        grade := "A+"
    else if score >= 70.0
        grade := "A"
    else if score >= 55.0
        grade := "B"

    grade

f_regimeState(float score) =>
    string state = "CHOP"

    if score >= 65.0
        state := "TRENDING"
    else if score >= 50.0
        state := "DEVELOPING"

    state

f_labelSize(string selectedSize) =>
    string result = size.small

    switch selectedSize
        "Tiny" => result := size.tiny
        "Small" => result := size.small
        "Normal" => result := size.normal
        "Large" => result := size.large
        => result := size.small

    result

f_minimumScore(string selectedMode) =>
    float result = 60.0

    switch selectedMode
        "Off" => result := 0.0
        "Loose" => result := 45.0
        "Balanced" => result := 60.0
        "Strict" => result := 75.0
        => result := 60.0

    result

f_minimumRegimeScore(string selectedMode) =>
    float result = 50.0

    switch selectedMode
        "Off" => result := 0.0
        "Loose" => result := 35.0
        "Balanced" => result := 50.0
        "Strict" => result := 65.0
        => result := 50.0

    result

f_minimumQualificationScore(string selectedMode) =>
    float result = 60.0

    switch selectedMode
        "Off" => result := 0.0
        "Loose" => result := 45.0
        "Balanced" => result := 60.0
        "Strict" => result := 75.0
        => result := 60.0

    result

f_priceText(float priceValue) =>
    str.tostring(priceValue, format.mintick)

f_entryAlertMessage(string directionText, string setupType, string setupGrade, float setupScore, string selectedRiskModel, float entryPrice, float stopPrice, float tp1Price, float tp2Price, float tp3Price, bool xauWarning) =>
    string warningText = xauWarning ? "\n⚠️ WARNING: XAUUSD Fixed Pips mode is active on a non-XAUUSD symbol. Verify pip size and distances." : ""

    "⚡ MACD MOMENTUM ENTRY\n" +
     "━━━━━━━━━━━━━━━━━━━━\n" +
     "🧭 Direction: " + directionText + "\n" +
     "📊 Symbol: " + syminfo.tickerid + "\n" +
     "⏱️ Timeframe: " + timeframe.period + "\n" +
     "🎯 Setup: " + setupType + "\n" +
     "🏅 Grade: " + setupGrade + "\n" +
     "⭐ Score: " + str.tostring(setupScore, "#.0") + "\n" +
     "🛡️ Risk Model: " + selectedRiskModel + "\n" +
     "📍 Entry: " + f_priceText(entryPrice) + "\n" +
     "🛑 SL: " + f_priceText(stopPrice) + "\n" +
     "🥉 TP1: " + f_priceText(tp1Price) + "\n" +
     "🥈 TP2: " + f_priceText(tp2Price) + "\n" +
     "🏆 TP3: " + f_priceText(tp3Price) +
     warningText

f_targetAlertMessage(string targetName, string directionText, float targetPrice, float entryPrice, float stopPrice, float tp1Price, float tp2Price, float tp3Price) =>
    "🎯 MACD MOMENTUM TARGET UPDATE\n" +
     "━━━━━━━━━━━━━━━━━━━━\n" +
     "✅ Event: " + targetName + "\n" +
     "🧭 Direction: " + directionText + "\n" +
     "📊 Symbol: " + syminfo.tickerid + "\n" +
     "⏱️ Timeframe: " + timeframe.period + "\n" +
     "💵 Target Price: " + f_priceText(targetPrice) + "\n" +
     "📍 Entry: " + f_priceText(entryPrice) + "\n" +
     "🛑 SL: " + f_priceText(stopPrice) + "\n" +
     "🥉 TP1: " + f_priceText(tp1Price) + "\n" +
     "🥈 TP2: " + f_priceText(tp2Price) + "\n" +
     "🏆 TP3: " + f_priceText(tp3Price)

f_stopAlertMessage(string directionText, string finalResult, float exitPrice, float entryPrice, float stopPrice, bool tp1Reached, bool tp2Reached) =>
    string progressText = tp2Reached ? "TP2 reached before SL" : tp1Reached ? "TP1 reached before SL" : "No target reached"

    "🛑 MACD MOMENTUM TRADE CLOSED\n" +
     "━━━━━━━━━━━━━━━━━━━━\n" +
     "📌 Result: " + finalResult + "\n" +
     "🧭 Direction: " + directionText + "\n" +
     "📊 Symbol: " + syminfo.tickerid + "\n" +
     "⏱️ Timeframe: " + timeframe.period + "\n" +
     "📍 Entry: " + f_priceText(entryPrice) + "\n" +
     "🚪 Exit: " + f_priceText(exitPrice) + "\n" +
     "🛑 SL: " + f_priceText(stopPrice) + "\n" +
     "📈 Progress: " + progressText

//══════════════════════════════════════════════════════════════════════
// INPUT GROUPS
//══════════════════════════════════════════════════════════════════════

string grpMacd = "⚙️ MACD Core"
string grpSignal = "🎯 Entry Engine"
string grpQuality = "🧠 Momentum Quality Engine"
string grpTrend = "📈 Trend Bias Engine"
string grpChop = "🧱 Anti-Chop Engine"
string grpQualification = "✅ Entry Qualification Engine"
string grpTrade = "💼 Trade Management Engine"
string grpFilter = "🛡️ Signal Filters"
string grpVisual = "🎨 Visual Settings"
string grpDashboard = "📟 Mini Dashboard"
string grpAlerts = "🔔 Dynamic Alerts"

//══════════════════════════════════════════════════════════════════════
// MACD CORE INPUTS
//══════════════════════════════════════════════════════════════════════

sourceInput = input.source(close, "Calculation Source", group = grpMacd, tooltip = "Price source used by the MACD calculation.", display = display.none)
fastLength = input.int(12, "Fast Length", minval = 1, group = grpMacd, tooltip = "Length of the fast moving average.", display = display.none)
slowLength = input.int(26, "Slow Length", minval = 2, group = grpMacd, tooltip = "Length of the slow moving average.", display = display.none)
signalLength = input.int(9, "Signal Length", minval = 1, group = grpMacd, tooltip = "Smoothing length of the MACD signal line.", display = display.none)
macdMaType = input.string("EMA", "MACD Average Type", options = ["EMA", "SMA", "RMA", "WMA"], group = grpMacd, tooltip = "Moving average type used by the fast and slow averages.", display = display.none)
signalMaType = input.string("EMA", "Signal Average Type", options = ["EMA", "SMA", "RMA", "WMA"], group = grpMacd, tooltip = "Moving average type used by the signal line.", display = display.none)

//══════════════════════════════════════════════════════════════════════
// ENTRY ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

signalMode = input.string("Early Trigger", "Entry Timing", options = ["Early Trigger", "Momentum Confirmed"], group = grpSignal, tooltip = "Early Trigger generates a signal directly on the confirmed setup event. Momentum Confirmed waits for renewed histogram expansion and continued MACD movement.", display = display.none)
const int confirmationWindow = 3
const int cooldownBars = 8

//══════════════════════════════════════════════════════════════════════
// MOMENTUM QUALITY ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

qualityMode = input.string("Strict", "Quality Filter", options = ["Off", "Loose", "Balanced", "Strict"], group = grpQuality, tooltip = "Off removes the momentum quality restriction. Loose produces more signals. Balanced balances frequency and quality. Strict accepts only stronger setups.", display = display.none)
const int qualityLookback = 50
const float histogramStrengthTarget = 1.25
const float histogramExpansionTarget = 1.20
const float macdSlopeTarget = 1.20
const float momentumAccelerationTarget = 1.20

//══════════════════════════════════════════════════════════════════════
// TREND BIAS ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

trendBiasMode = input.string("Off", "Trend Bias Mode", options = ["Off", "Chart EMA", "Higher Timeframe EMA", "Combined EMA"], group = grpTrend, tooltip = "Chart EMA uses the current chart trend. Higher Timeframe EMA uses only confirmed higher-timeframe values. Combined EMA requires both trend layers to agree.", display = display.none)
trendLength = input.int(200, "Trend EMA Length", minval = 2, maxval = 500, group = grpTrend, tooltip = "EMA length used by the chart and higher-timeframe trend filters.", display = display.none)
trendSlopeLookback = input.int(3, "Chart EMA Slope Lookback", minval = 1, maxval = 20, group = grpTrend, tooltip = "Number of chart bars used to evaluate the direction of the chart EMA.", display = display.none)
requireTrendSlope = input.bool(false, "Require EMA Slope Confirmation", group = grpTrend, tooltip = "🚀 LONG requires a rising trend EMA and 🔴 SHORT requires a falling trend EMA.", display = display.none)
higherTimeframe = input.timeframe("60", "Higher Timeframe", group = grpTrend, tooltip = "Higher timeframe used by the confirmed HTF trend bias. Select a timeframe above the chart timeframe.", display = display.none)
trendBufferAtr = input.float(0.0, "Price-to-EMA ATR Buffer", minval = 0.0, maxval = 3.0, step = 0.05, group = grpTrend, tooltip = "Optional minimum distance between price and the trend EMA, measured in ATR. Zero disables the distance requirement.", display = display.none)

//══════════════════════════════════════════════════════════════════════
// ANTI-CHOP ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

antiChopMode = input.string("Strict", "Anti-Chop Filter", options = ["Off", "Loose", "Balanced", "Strict"], group = grpChop, tooltip = "Combines ADX, price efficiency, EMA separation and volatility expansion into a 0-100 market regime score.", display = display.none)

// Internal anti-chop parameters
const int adxDiLength = 14
const int adxSmoothing = 14
const float adxTarget = 25.0
const int efficiencyLength = 20
const float efficiencyTarget = 0.35
const int regimeFastLength = 21
const int regimeSlowLength = 50
const float separationTargetAtr = 0.30
const int volatilityLookback = 50
const float volatilityTarget = 0.90

//══════════════════════════════════════════════════════════════════════
// ENTRY QUALIFICATION ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

enableReversalSetups = input.bool(true, "Enable Reversal Setups", group = grpQualification, tooltip = "Allows MACD crossovers that occur on the opposite side of the zero line.", display = display.none)
enableContinuationSetups = input.bool(true, "Enable Continuation Setups", group = grpQualification, tooltip = "Allows MACD crossovers that occur on the trend side of the zero line.", display = display.none)
enableZeroLineReclaims = input.bool(true, "Enable Zero-Line Reclaims", group = grpQualification, tooltip = "Allows entries when the MACD line confirms a move through the zero line with aligned momentum.", display = display.none)
enableMomentumExpansions = input.bool(true, "Enable Momentum Expansions", group = grpQualification, tooltip = "Allows the first renewed histogram expansion after a short contraction while MACD alignment remains valid.", display = display.none)

qualificationMode = input.string("Strict", "Entry Qualification Filter", options = ["Off", "Loose", "Balanced", "Strict"], group = grpQualification, tooltip = "Applies an additional 0-100 entry score after the MACD, trend and anti-chop conditions are evaluated.", display = display.none)

// Internal entry qualification parameters

const string candleConfirmationMode = "Directional"
const float minimumBodyRatio = 0.35
const float minimumCloseLocation = 0.65

const bool requireMinimumSeparation = true
const float minimumSeparationMultiplier = 0.65

const bool requireMomentumPersistence = true
const int minimumPersistenceBars = 1
const int persistenceScoreTarget = 3

const float candleBodyScoreTarget = 0.60
const float closeLocationScoreTarget = 0.80
const float entrySeparationScoreTarget = 1.25
const float priceImpulseTargetAtr = 0.35

//══════════════════════════════════════════════════════════════════════
// TRADE MANAGEMENT ENGINE SETTINGS
//══════════════════════════════════════════════════════════════════════

enableTradeEngine = input.bool(true, "Enable Trade Engine", group = grpTrade, tooltip = "Converts qualified signals into a one-active-trade-at-a-time visual trade model.", display = display.none)

riskModel = input.string("XAUUSD Fixed Pips", "Risk Model", options = ["ATR Based", "XAUUSD Fixed Pips"], group = grpTrade, tooltip = "ATR Based keeps the adaptive ATR stop and RR targets. XAUUSD Fixed Pips uses the manually selected pip size and fixed SL / TP distances.", display = display.none)

tradeAtrLength = input.int(14, "ATR Length", minval = 1, maxval = 200, group = grpTrade, tooltip = "ATR length used by the ATR Based risk model.", display = display.none)
stopAtrMultiplier = input.float(1.50, "ATR Stop Multiplier", minval = 0.10, maxval = 10.0, step = 0.10, group = grpTrade, tooltip = "Stop-loss distance measured in ATR when ATR Based mode is selected.", display = display.none)
atrTp1RiskReward = input.float(0.50, "ATR TP1 Risk/Reward", minval = 0.10, maxval = 10.0, step = 0.10, group = grpTrade, tooltip = "TP1 distance as a multiple of the ATR-based initial risk.", display = display.none)
atrTp2RiskReward = input.float(1.00, "ATR TP2 Risk/Reward", minval = 0.10, maxval = 10.0, step = 0.10, group = grpTrade, tooltip = "TP2 distance as a multiple of the ATR-based initial risk.", display = display.none)
atrTp3RiskReward = input.float(1.50, "ATR TP3 Risk/Reward", minval = 0.10, maxval = 10.0, step = 0.10, group = grpTrade, tooltip = "TP3 distance as a multiple of the ATR-based initial risk.", display = display.none)

xauPipSize = input.float(0.01, "XAUUSD Pip Size", minval = 0.00001, step = 0.01, group = grpTrade, tooltip = "For the common XAUUSD convention, 1 pip equals 0.01 price units. Adjust this only if your broker uses a different convention.", display = display.none)
fixedStopPips = input.int(1000, "XAUUSD Stop-Loss Pips", minval = 1, maxval = 100000, group = grpTrade, tooltip = "Fixed XAUUSD stop-loss distance in pips.", display = display.none)
fixedTp1Pips = input.int(500, "XAUUSD TP1 Pips", minval = 1, maxval = 100000, group = grpTrade, tooltip = "Fixed XAUUSD TP1 distance in pips.", display = display.none)
fixedTp2Pips = input.int(1000, "XAUUSD TP2 Pips", minval = 1, maxval = 100000, group = grpTrade, tooltip = "Fixed XAUUSD TP2 distance in pips.", display = display.none)
fixedTp3Pips = input.int(1500, "XAUUSD TP3 Pips", minval = 1, maxval = 100000, group = grpTrade, tooltip = "Fixed XAUUSD TP3 distance in pips.", display = display.none)

sameBarPriority = input.string("Stop First", "Same-Bar Resolution", options = ["Stop First", "Targets First"], group = grpTrade, tooltip = "Historical candles do not reveal the intrabar order when both target and stop levels are touched. Stop First is the conservative assumption. Targets First processes reached targets before the stop.", display = display.none)
showTradeZones = input.bool(true, "Show Active TP / SL Zones", group = grpTrade, tooltip = "Draws entry, three take-profit levels and stop-loss on the main chart.", display = display.none)
showHistoricalTrades = input.bool(true, "Keep Historical TP3 Zones", group = grpTrade, tooltip = "Only trades that reach TP3 retain their completed TP / SL model. SL, Closed TP1 and Closed TP2 trades leave no historical boxes or lines.", display = display.none)
historicalTradeLimit = input.int(60, "Historical TP3 Trade Limit", minval = 1, maxval = 90, group = grpTrade, tooltip = "Maximum number of completed TP3 trade models retained on the chart.", display = display.none)
showTradeResultLabels = input.bool(true, "🏷️ Trade Result Labels", group = grpTrade, tooltip = "For 🏆 TP3 trades, the original 🚀 LONG / 🔴 SHORT entry label stays on the chart and a separate eye-catching TP3 result label is added. For 🛑 SL, ⚠️ CLOSED TP1 and ✅ CLOSED TP2 trades, the original entry label converts into the final result label. Result labels do not display R values.", display = display.none)

slResultLabelSize = input.string("Small", "🛑 SL Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpTrade, tooltip = "Controls the size of the final stop-loss result label.", display = display.none)
tp1ResultLabelSize = input.string("Small", "⚠️ Closed TP1 Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpTrade, tooltip = "Controls the size of the final CLOSED TP1 result label.", display = display.none)
tp2ResultLabelSize = input.string("Small", "✅ Closed TP2 Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpTrade, tooltip = "Controls the size of the final CLOSED TP2 result label.", display = display.none)
tp3ResultLabelSize = input.string("Normal", "🏆 TP3 Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpTrade, tooltip = "Controls the size of the separate TP3 FULL TARGET result label.", display = display.none)

//══════════════════════════════════════════════════════════════════════
// ADDITIONAL SIGNAL FILTERS
//══════════════════════════════════════════════════════════════════════

zeroLineFilter = input.string("Trend Direction", "Zero-Line Filter", options = ["Off", "Trend Direction"], group = grpFilter, tooltip = "Trend Direction allows 🚀 LONG setups only above zero and 🔴 SHORT setups only below zero.", display = display.none)
useAbsoluteStrengthFilter = input.bool(true, "Use Absolute Strength Filter", group = grpFilter, tooltip = "Adds an ATR-normalized minimum histogram strength requirement.", display = display.none)
normalizationAtrLength = input.int(14, "Normalization ATR Length", minval = 1, group = grpFilter, tooltip = "ATR length used to normalize MACD and regime values across markets.", display = display.none)
minimumAbsoluteStrength = input.float(1.0, "Minimum Absolute Strength", minval = 0.0, step = 0.1, group = grpFilter, tooltip = "Minimum ATR-normalized histogram strength required for a signal.", display = display.none)

//══════════════════════════════════════════════════════════════════════
// VISUAL SETTINGS
//══════════════════════════════════════════════════════════════════════

showMacdLine = input.bool(true, "Show MACD Line", group = grpVisual, display = display.none)
showSignalLine = input.bool(true, "Show Signal Line", group = grpVisual, display = display.none)
showHistogram = input.bool(true, "Show Histogram", group = grpVisual, display = display.none)
histogramVisualScale = input.float(1.60, "Histogram Visual Length", minval = 0.50, maxval = 5.00, step = 0.10, group = grpVisual, tooltip = "Visually extends the red and green histogram bars without changing MACD calculations, quality scores or signal logic.", display = display.none)
showMacdSignalMarkers = input.bool(true, "Show MACD Neon Signal Dots", group = grpVisual, tooltip = "Displays a medium neon green dot for LONG setups and a medium neon red dot for SHORT setups directly on the MACD line.", display = display.none)
showMomentumBackground = input.bool(true, "Show Momentum Background", group = grpVisual, display = display.none)
showChopBackground = input.bool(true, "Highlight Blocked Chop Conditions", group = grpVisual, tooltip = "Displays a neutral background when the Anti-Chop Engine blocks new entries.", display = display.none)
showEntryLabels = input.bool(true, "Show LONG / SHORT Labels", group = grpVisual, display = display.none)
entryLabelContent = input.string("Score + Grade", "Entry Label Content", options = ["Direction Only", "Grade", "Score + Grade"], group = grpVisual, tooltip = "Controls how much setup-quality information is displayed inside entry labels.", display = display.none)
longLabelSize = input.string("Small", "🚀 LONG Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual, tooltip = "Controls the size of LONG entry labels.", display = display.none)
shortLabelSize = input.string("Small", "🔴 SHORT Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual, tooltip = "Controls the size of SHORT entry labels.", display = display.none)

showMiniDashboard = input.bool(true, "Show Mini Dashboard", group = grpDashboard, tooltip = "Displays a compact engine-status dashboard in the bottom-right corner of the main price chart.", display = display.none)

enableDynamicAlerts = input.bool(true, "Enable Detailed Dynamic Alerts", group = grpAlerts, tooltip = "Sends detailed alert() messages containing symbol, timeframe, setup, score, entry, SL and TP levels. Create the TradingView alert using 'Any alert() function call'.", display = display.none)

//══════════════════════════════════════════════════════════════════════
// MACD CORE CALCULATION
// Every recursive average is calculated on every bar.
//══════════════════════════════════════════════════════════════════════

fastEma = ta.ema(sourceInput, fastLength)
fastSma = ta.sma(sourceInput, fastLength)
fastRma = ta.rma(sourceInput, fastLength)
fastWma = ta.wma(sourceInput, fastLength)

slowEma = ta.ema(sourceInput, slowLength)
slowSma = ta.sma(sourceInput, slowLength)
slowRma = ta.rma(sourceInput, slowLength)
slowWma = ta.wma(sourceInput, slowLength)

fastAverage = f_selectMa(macdMaType, fastEma, fastSma, fastRma, fastWma)
slowAverage = f_selectMa(macdMaType, slowEma, slowSma, slowRma, slowWma)
macdLine = fastAverage - slowAverage

signalEma = ta.ema(macdLine, signalLength)
signalSma = ta.sma(macdLine, signalLength)
signalRma = ta.rma(macdLine, signalLength)
signalWma = ta.wma(macdLine, signalLength)

signalLine = f_selectMa(signalMaType, signalEma, signalSma, signalRma, signalWma)
histogram = macdLine - signalLine
histogramVisual = histogram * histogramVisualScale

//══════════════════════════════════════════════════════════════════════
// VOLATILITY NORMALIZATION
//══════════════════════════════════════════════════════════════════════

atrValue = ta.atr(normalizationAtrLength)
safeAtr = math.max(nz(atrValue, syminfo.mintick), syminfo.mintick)
normalizedHistogramStrength = math.abs(nz(histogram, 0.0)) / safeAtr * 100.0

//══════════════════════════════════════════════════════════════════════
// MOMENTUM MEASUREMENTS
//══════════════════════════════════════════════════════════════════════

histogramAbsolute = math.abs(nz(histogram, 0.0))
histogramExpansion = math.abs(nz(histogram - histogram[1], 0.0))
macdSlope = nz(macdLine - macdLine[1], 0.0)
macdSlopeAbsolute = math.abs(macdSlope)
momentumAcceleration = nz(macdSlope - macdSlope[1], 0.0)
momentumAccelerationAbsolute = math.abs(momentumAcceleration)

histogramStrengthBaseline = ta.ema(histogramAbsolute, qualityLookback)
histogramExpansionBaseline = ta.ema(histogramExpansion, qualityLookback)
macdSlopeBaseline = ta.ema(macdSlopeAbsolute, qualityLookback)
momentumAccelerationBaseline = ta.ema(momentumAccelerationAbsolute, qualityLookback)

//══════════════════════════════════════════════════════════════════════
// HISTOGRAM AND MOMENTUM STATES
//══════════════════════════════════════════════════════════════════════

bullishExpanding = histogram >= 0.0 and histogram > histogram[1]
bullishContracting = histogram >= 0.0 and histogram <= histogram[1]
bearishExpanding = histogram < 0.0 and histogram < histogram[1]
bearishContracting = histogram < 0.0 and histogram >= histogram[1]

strongBullishMomentum = macdLine > signalLine and histogram > 0.0 and bullishExpanding
weakBullishMomentum = macdLine > signalLine and histogram > 0.0 and bullishContracting
strongBearishMomentum = macdLine < signalLine and histogram < 0.0 and bearishExpanding
weakBearishMomentum = macdLine < signalLine and histogram < 0.0 and bearishContracting

//══════════════════════════════════════════════════════════════════════
// MOMENTUM QUALITY SCORE
// Alignment 20 | Strength 25 | Expansion 20 | Slope 20 | Acceleration 15
//══════════════════════════════════════════════════════════════════════

bullishAlignmentScore = macdLine > signalLine and histogram > 0.0 ? 20.0 : 0.0
bearishAlignmentScore = macdLine < signalLine and histogram < 0.0 ? 20.0 : 0.0

bullishHistogramStrengthScore = histogram > 0.0 ? f_componentScore(histogramAbsolute, histogramStrengthBaseline, histogramStrengthTarget, 25.0) : 0.0
bearishHistogramStrengthScore = histogram < 0.0 ? f_componentScore(histogramAbsolute, histogramStrengthBaseline, histogramStrengthTarget, 25.0) : 0.0

bullishExpansionScore = bullishExpanding ? f_componentScore(histogramExpansion, histogramExpansionBaseline, histogramExpansionTarget, 20.0) : 0.0
bearishExpansionScore = bearishExpanding ? f_componentScore(histogramExpansion, histogramExpansionBaseline, histogramExpansionTarget, 20.0) : 0.0

bullishSlopeScore = macdSlope > 0.0 ? f_componentScore(macdSlopeAbsolute, macdSlopeBaseline, macdSlopeTarget, 20.0) : 0.0
bearishSlopeScore = macdSlope < 0.0 ? f_componentScore(macdSlopeAbsolute, macdSlopeBaseline, macdSlopeTarget, 20.0) : 0.0

bullishAccelerationScore = momentumAcceleration > 0.0 ? f_componentScore(momentumAccelerationAbsolute, momentumAccelerationBaseline, momentumAccelerationTarget, 15.0) : 0.0
bearishAccelerationScore = momentumAcceleration < 0.0 ? f_componentScore(momentumAccelerationAbsolute, momentumAccelerationBaseline, momentumAccelerationTarget, 15.0) : 0.0

bullishQualityScore = f_clamp(bullishAlignmentScore + bullishHistogramStrengthScore + bullishExpansionScore + bullishSlopeScore + bullishAccelerationScore, 0.0, 100.0)
bearishQualityScore = f_clamp(bearishAlignmentScore + bearishHistogramStrengthScore + bearishExpansionScore + bearishSlopeScore + bearishAccelerationScore, 0.0, 100.0)

minimumRequiredScore = f_minimumScore(qualityMode)
bullishQualityPass = qualityMode == "Off" or bullishQualityScore >= minimumRequiredScore
bearishQualityPass = qualityMode == "Off" or bearishQualityScore >= minimumRequiredScore

//══════════════════════════════════════════════════════════════════════
// TREND BIAS ENGINE
// HTF values use the previous completed HTF candle with lookahead_on.
//══════════════════════════════════════════════════════════════════════

chartTrendEma = ta.ema(close, trendLength)
chartTrendSlopeBullish = chartTrendEma > chartTrendEma[trendSlopeLookback]
chartTrendSlopeBearish = chartTrendEma < chartTrendEma[trendSlopeLookback]

chartBullishDistance = close - chartTrendEma
chartBearishDistance = chartTrendEma - close
chartDistanceRequirement = atrValue * trendBufferAtr

chartBullishBias = close > chartTrendEma and chartBullishDistance >= chartDistanceRequirement and (not requireTrendSlope or chartTrendSlopeBullish)
chartBearishBias = close < chartTrendEma and chartBearishDistance >= chartDistanceRequirement and (not requireTrendSlope or chartTrendSlopeBearish)

htfConfirmedClose = request.security(syminfo.tickerid, higherTimeframe, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
htfConfirmedEma = request.security(syminfo.tickerid, higherTimeframe, ta.ema(close, trendLength)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
htfPreviousEma = request.security(syminfo.tickerid, higherTimeframe, ta.ema(close, trendLength)[2], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
htfConfirmedAtr = request.security(syminfo.tickerid, higherTimeframe, ta.atr(normalizationAtrLength)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

safeHtfAtr = math.max(nz(htfConfirmedAtr, syminfo.mintick), syminfo.mintick)
htfDistanceRequirement = safeHtfAtr * trendBufferAtr
htfBullishDistance = htfConfirmedClose - htfConfirmedEma
htfBearishDistance = htfConfirmedEma - htfConfirmedClose
htfTrendSlopeBullish = htfConfirmedEma > htfPreviousEma
htfTrendSlopeBearish = htfConfirmedEma < htfPreviousEma

htfBullishBias = htfConfirmedClose > htfConfirmedEma and htfBullishDistance >= htfDistanceRequirement and (not requireTrendSlope or htfTrendSlopeBullish)
htfBearishBias = htfConfirmedClose < htfConfirmedEma and htfBearishDistance >= htfDistanceRequirement and (not requireTrendSlope or htfTrendSlopeBearish)

bool bullishTrendPass = true
bool bearishTrendPass = true

if trendBiasMode == "Chart EMA"
    bullishTrendPass := chartBullishBias
    bearishTrendPass := chartBearishBias
else if trendBiasMode == "Higher Timeframe EMA"
    bullishTrendPass := htfBullishBias
    bearishTrendPass := htfBearishBias
else if trendBiasMode == "Combined EMA"
    bullishTrendPass := chartBullishBias and htfBullishBias
    bearishTrendPass := chartBearishBias and htfBearishBias

string trendState = "OFF"

if trendBiasMode != "Off"
    if bullishTrendPass
        trendState := "BULLISH"
    else if bearishTrendPass
        trendState := "BEARISH"
    else
        trendState := "NEUTRAL"

//══════════════════════════════════════════════════════════════════════
// ANTI-CHOP ENGINE
// ADX 35 | Price Efficiency 30 | EMA Separation 20 | Volatility 15
//══════════════════════════════════════════════════════════════════════

[plusDi, minusDi, adxValue] = ta.dmi(adxDiLength, adxSmoothing)

barToBarMovement = math.abs(nz(close - close[1], 0.0))
averageBarMovement = ta.sma(barToBarMovement, efficiencyLength)
totalPricePath = nz(averageBarMovement, 0.0) * efficiencyLength
directPriceMovement = math.abs(nz(close - close[efficiencyLength], 0.0))
priceEfficiency = totalPricePath > 0.0 ? directPriceMovement / totalPricePath : 0.0

regimeFastEma = ta.ema(close, regimeFastLength)
regimeSlowEma = ta.ema(close, regimeSlowLength)
emaSeparationAtr = math.abs(regimeFastEma - regimeSlowEma) / safeAtr

atrBaseline = ta.sma(atrValue, volatilityLookback)
safeAtrBaseline = math.max(nz(atrBaseline, safeAtr), syminfo.mintick)
volatilityExpansion = atrValue / safeAtrBaseline

adxRegimeScore = f_targetScore(adxValue, adxTarget, 35.0)
efficiencyRegimeScore = f_targetScore(priceEfficiency, efficiencyTarget, 30.0)
separationRegimeScore = f_targetScore(emaSeparationAtr, separationTargetAtr, 20.0)
volatilityRegimeScore = f_targetScore(volatilityExpansion, volatilityTarget, 15.0)

marketRegimeScore = f_clamp(adxRegimeScore + efficiencyRegimeScore + separationRegimeScore + volatilityRegimeScore, 0.0, 100.0)
minimumRegimeScore = f_minimumRegimeScore(antiChopMode)
antiChopPass = antiChopMode == "Off" or marketRegimeScore >= minimumRegimeScore
marketRegimeState = antiChopMode == "Off" ? "OFF" : f_regimeState(marketRegimeScore)

//══════════════════════════════════════════════════════════════════════
// SETUP TRIGGER CALCULATION
// All crossover functions are evaluated on every bar.
//══════════════════════════════════════════════════════════════════════

rawBullishCrossover = ta.crossover(macdLine, signalLine)
rawBearishCrossover = ta.crossunder(macdLine, signalLine)
rawBullishZeroCross = ta.crossover(macdLine, 0.0)
rawBearishZeroCross = ta.crossunder(macdLine, 0.0)

bullishCrossover = barstate.isconfirmed and rawBullishCrossover
bearishCrossover = barstate.isconfirmed and rawBearishCrossover
bullishZeroCross = barstate.isconfirmed and rawBullishZeroCross
bearishZeroCross = barstate.isconfirmed and rawBearishZeroCross

bullishReversalTrigger = enableReversalSetups and bullishCrossover and macdLine < 0.0
bearishReversalTrigger = enableReversalSetups and bearishCrossover and macdLine > 0.0

bullishContinuationTrigger = enableContinuationSetups and bullishCrossover and macdLine >= 0.0
bearishContinuationTrigger = enableContinuationSetups and bearishCrossover and macdLine <= 0.0

bullishZeroReclaimTrigger = enableZeroLineReclaims and bullishZeroCross and macdLine > signalLine and histogram > 0.0
bearishZeroReclaimTrigger = enableZeroLineReclaims and bearishZeroCross and macdLine < signalLine and histogram < 0.0

bullishExpansionTurn = histogram > 0.0 and histogram > histogram[1] and histogram[1] <= histogram[2]
bearishExpansionTurn = histogram < 0.0 and histogram < histogram[1] and histogram[1] >= histogram[2]

bullishExpansionTrigger = enableMomentumExpansions and barstate.isconfirmed and not bullishCrossover and not bullishZeroCross and macdLine > signalLine and macdSlope > 0.0 and bullishExpansionTurn
bearishExpansionTrigger = enableMomentumExpansions and barstate.isconfirmed and not bearishCrossover and not bearishZeroCross and macdLine < signalLine and macdSlope < 0.0 and bearishExpansionTurn

bool bullishRawSetup = false
bool bearishRawSetup = false
string bullishRawSetupType = "NONE"
string bearishRawSetupType = "NONE"

if bullishZeroReclaimTrigger
    bullishRawSetup := true
    bullishRawSetupType := "ZERO RECLAIM"
else if bullishContinuationTrigger
    bullishRawSetup := true
    bullishRawSetupType := "CONTINUATION"
else if bullishReversalTrigger
    bullishRawSetup := true
    bullishRawSetupType := "REVERSAL"
else if bullishExpansionTrigger
    bullishRawSetup := true
    bullishRawSetupType := "EXPANSION"

if bearishZeroReclaimTrigger
    bearishRawSetup := true
    bearishRawSetupType := "ZERO RECLAIM"
else if bearishContinuationTrigger
    bearishRawSetup := true
    bearishRawSetupType := "CONTINUATION"
else if bearishReversalTrigger
    bearishRawSetup := true
    bearishRawSetupType := "REVERSAL"
else if bearishExpansionTrigger
    bearishRawSetup := true
    bearishRawSetupType := "EXPANSION"

//══════════════════════════════════════════════════════════════════════
// MOMENTUM CONFIRMATION STATE
// Any enabled setup type can arm the confirmation window.
//══════════════════════════════════════════════════════════════════════

var bool bullishSetupArmed = false
var bool bearishSetupArmed = false
var int bullishSetupBar = na
var int bearishSetupBar = na
var string bullishArmedType = "NONE"
var string bearishArmedType = "NONE"

if bullishRawSetup
    bullishSetupArmed := true
    bearishSetupArmed := false
    bullishSetupBar := bar_index
    bearishSetupBar := na
    bullishArmedType := bullishRawSetupType
    bearishArmedType := "NONE"

if bearishRawSetup
    bearishSetupArmed := true
    bullishSetupArmed := false
    bearishSetupBar := bar_index
    bullishSetupBar := na
    bearishArmedType := bearishRawSetupType
    bullishArmedType := "NONE"

if bullishSetupArmed and not na(bullishSetupBar) and bar_index - bullishSetupBar > confirmationWindow
    bullishSetupArmed := false
    bullishSetupBar := na
    bullishArmedType := "NONE"

if bearishSetupArmed and not na(bearishSetupBar) and bar_index - bearishSetupBar > confirmationWindow
    bearishSetupArmed := false
    bearishSetupBar := na
    bearishArmedType := "NONE"

bullishMomentumConfirmation = barstate.isconfirmed and bullishSetupArmed and not na(bullishSetupBar) and bar_index > bullishSetupBar and macdLine > signalLine and histogram > 0.0 and histogram > histogram[1] and macdSlope > 0.0
bearishMomentumConfirmation = barstate.isconfirmed and bearishSetupArmed and not na(bearishSetupBar) and bar_index > bearishSetupBar and macdLine < signalLine and histogram < 0.0 and histogram < histogram[1] and macdSlope < 0.0

bullishEntryCandidate = signalMode == "Early Trigger" ? bullishRawSetup : bullishMomentumConfirmation
bearishEntryCandidate = signalMode == "Early Trigger" ? bearishRawSetup : bearishMomentumConfirmation

string bullishCandidateType = signalMode == "Early Trigger" ? bullishRawSetupType : bullishArmedType
string bearishCandidateType = signalMode == "Early Trigger" ? bearishRawSetupType : bearishArmedType

//══════════════════════════════════════════════════════════════════════
// ENTRY QUALIFICATION ENGINE
// Candle 25 | MACD Separation 25 | Persistence 20 | Price Impulse 15 | Trigger Context 15
//══════════════════════════════════════════════════════════════════════

candleRange = math.max(high - low, syminfo.mintick)
bullishDirectionalBodyRatio = math.max(close - open, 0.0) / candleRange
bearishDirectionalBodyRatio = math.max(open - close, 0.0) / candleRange
bullishCloseLocation = (close - low) / candleRange
bearishCloseLocation = (high - close) / candleRange

bullishBodyScore = f_targetScore(bullishDirectionalBodyRatio, candleBodyScoreTarget, 12.5)
bearishBodyScore = f_targetScore(bearishDirectionalBodyRatio, candleBodyScoreTarget, 12.5)
bullishCloseScore = f_targetScore(bullishCloseLocation, closeLocationScoreTarget, 12.5)
bearishCloseScore = f_targetScore(bearishCloseLocation, closeLocationScoreTarget, 12.5)

bullishCandleScore = bullishBodyScore + bullishCloseScore
bearishCandleScore = bearishBodyScore + bearishCloseScore

bullishAlignmentCondition = macdLine > signalLine and histogram > 0.0
bearishAlignmentCondition = macdLine < signalLine and histogram < 0.0

barsSinceBullishAlignmentBreak = ta.barssince(not bullishAlignmentCondition)
barsSinceBearishAlignmentBreak = ta.barssince(not bearishAlignmentCondition)

bullishPersistenceBars = bullishAlignmentCondition ? nz(barsSinceBullishAlignmentBreak, persistenceScoreTarget) : 0
bearishPersistenceBars = bearishAlignmentCondition ? nz(barsSinceBearishAlignmentBreak, persistenceScoreTarget) : 0

bullishPersistenceScore = f_targetScore(float(bullishPersistenceBars), float(persistenceScoreTarget), 20.0)
bearishPersistenceScore = f_targetScore(float(bearishPersistenceBars), float(persistenceScoreTarget), 20.0)

bullishSeparationScore = histogram > 0.0 ? f_componentScore(histogramAbsolute, histogramStrengthBaseline, entrySeparationScoreTarget, 25.0) : 0.0
bearishSeparationScore = histogram < 0.0 ? f_componentScore(histogramAbsolute, histogramStrengthBaseline, entrySeparationScoreTarget, 25.0) : 0.0

bullishPriceImpulseAtr = math.max(close - close[1], 0.0) / safeAtr
bearishPriceImpulseAtr = math.max(close[1] - close, 0.0) / safeAtr

bullishImpulseScore = f_targetScore(bullishPriceImpulseAtr, priceImpulseTargetAtr, 15.0)
bearishImpulseScore = f_targetScore(bearishPriceImpulseAtr, priceImpulseTargetAtr, 15.0)

bullishTriggerContextScore = bullishEntryCandidate ? 15.0 : 0.0
bearishTriggerContextScore = bearishEntryCandidate ? 15.0 : 0.0

bullishEntryScore = f_clamp(bullishCandleScore + bullishSeparationScore + bullishPersistenceScore + bullishImpulseScore + bullishTriggerContextScore, 0.0, 100.0)
bearishEntryScore = f_clamp(bearishCandleScore + bearishSeparationScore + bearishPersistenceScore + bearishImpulseScore + bearishTriggerContextScore, 0.0, 100.0)

minimumQualificationScore = f_minimumQualificationScore(qualificationMode)
bullishQualificationPass = qualificationMode == "Off" or bullishEntryScore >= minimumQualificationScore
bearishQualificationPass = qualificationMode == "Off" or bearishEntryScore >= minimumQualificationScore

bullishDirectionalCandlePass = close > open
bearishDirectionalCandlePass = close < open

bullishStrongCandlePass = bullishDirectionalCandlePass and bullishDirectionalBodyRatio >= minimumBodyRatio and bullishCloseLocation >= minimumCloseLocation
bearishStrongCandlePass = bearishDirectionalCandlePass and bearishDirectionalBodyRatio >= minimumBodyRatio and bearishCloseLocation >= minimumCloseLocation

bool bullishCandlePass = true
bool bearishCandlePass = true

if candleConfirmationMode == "Directional"
    bullishCandlePass := bullishDirectionalCandlePass
    bearishCandlePass := bearishDirectionalCandlePass
else if candleConfirmationMode == "Strong Close"
    bullishCandlePass := bullishStrongCandlePass
    bearishCandlePass := bearishStrongCandlePass

safeSeparationBaseline = math.max(nz(histogramStrengthBaseline, histogramAbsolute), 0.0000001)
separationRatio = histogramAbsolute / safeSeparationBaseline
separationPass = not requireMinimumSeparation or separationRatio >= minimumSeparationMultiplier

bullishPersistencePass = not requireMomentumPersistence or bullishPersistenceBars >= minimumPersistenceBars
bearishPersistencePass = not requireMomentumPersistence or bearishPersistenceBars >= minimumPersistenceBars

//══════════════════════════════════════════════════════════════════════
// ADDITIONAL FILTERS
//══════════════════════════════════════════════════════════════════════

bullishZeroLinePass = zeroLineFilter == "Off" or macdLine > 0.0
bearishZeroLinePass = zeroLineFilter == "Off" or macdLine < 0.0
absoluteStrengthPass = not useAbsoluteStrengthFilter or normalizedHistogramStrength >= minimumAbsoluteStrength

var int lastSignalBar = na
cooldownPass = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

//══════════════════════════════════════════════════════════════════════
// FINAL COMPOSITE SETUP SCORES
// Stage 3 setup score 70% + Stage 4 entry qualification 30%
//══════════════════════════════════════════════════════════════════════

bullishStageThreeScore = antiChopMode == "Off" ? bullishQualityScore : f_clamp(bullishQualityScore * 0.75 + marketRegimeScore * 0.25, 0.0, 100.0)
bearishStageThreeScore = antiChopMode == "Off" ? bearishQualityScore : f_clamp(bearishQualityScore * 0.75 + marketRegimeScore * 0.25, 0.0, 100.0)

bullishSetupScore = f_clamp(bullishStageThreeScore * 0.70 + bullishEntryScore * 0.30, 0.0, 100.0)
bearishSetupScore = f_clamp(bearishStageThreeScore * 0.70 + bearishEntryScore * 0.30, 0.0, 100.0)

bullishSetupGrade = f_qualityGrade(bullishSetupScore)
bearishSetupGrade = f_qualityGrade(bearishSetupScore)

//══════════════════════════════════════════════════════════════════════
// TRADE MANAGEMENT STATE
// Entry is modeled at the confirmed signal-bar close.
// TP / SL evaluation begins from the following bar.
// The position is modeled as three equal portions.
//══════════════════════════════════════════════════════════════════════

tradeAtrValue = ta.atr(tradeAtrLength)
safeTradeAtr = math.max(nz(tradeAtrValue, syminfo.mintick), syminfo.mintick)

atrStopDistance = math.max(safeTradeAtr * stopAtrMultiplier, syminfo.mintick)
fixedStopDistance = math.max(float(fixedStopPips) * xauPipSize, syminfo.mintick)

selectedStopDistance = riskModel == "ATR Based" ? atrStopDistance : fixedStopDistance

rawTp1Distance = riskModel == "ATR Based" ? selectedStopDistance * atrTp1RiskReward : float(fixedTp1Pips) * xauPipSize
rawTp2Distance = riskModel == "ATR Based" ? selectedStopDistance * atrTp2RiskReward : float(fixedTp2Pips) * xauPipSize
rawTp3Distance = riskModel == "ATR Based" ? selectedStopDistance * atrTp3RiskReward : float(fixedTp3Pips) * xauPipSize

selectedTp1Distance = math.max(rawTp1Distance, syminfo.mintick)
selectedTp2Distance = math.max(rawTp2Distance, selectedTp1Distance + syminfo.mintick)
selectedTp3Distance = math.max(rawTp3Distance, selectedTp2Distance + syminfo.mintick)

selectedTp1R = selectedTp1Distance / selectedStopDistance
selectedTp2R = selectedTp2Distance / selectedStopDistance
selectedTp3R = selectedTp3Distance / selectedStopDistance

isXauUsdSymbol = (syminfo.basecurrency == "XAU" and syminfo.currency == "USD") or str.contains(syminfo.tickerid, "XAUUSD")
xauFixedModeActive = riskModel == "XAUUSD Fixed Pips"
xauModeMismatch = xauFixedModeActive and not isXauUsdSymbol

var bool tradeActive = false
var int tradeDirection = 0
var int tradeEntryBar = na
var float tradeEntryPrice = na
var float tradeStopPrice = na
var float tradeTp1Price = na
var float tradeTp2Price = na
var float tradeTp3Price = na
var float tradeInitialRisk = na
var float tradeTp1R = na
var float tradeTp2R = na
var float tradeTp3R = na
var bool tradeTp1Hit = false
var bool tradeTp2Hit = false
var string activeTradeType = "NONE"
var string activeTradeGrade = "C"
var string activeRiskModel = "NONE"

var box activeTp1Box = na
var box activeTp2Box = na
var box activeTp3Box = na
var box activeStopBox = na
var line activeEntryLine = na
var line activeTp1Line = na
var line activeTp2Line = na
var line activeTp3Line = na
var line activeStopLine = na
var label activeTradeSignalLabel = na

var box[] historicalTradeBoxes = array.new_box()
var line[] historicalTradeLines = array.new_line()
var int[] historicalTradeBoxCounts = array.new_int()
var int[] historicalTradeLineCounts = array.new_int()

var int totalClosedTrades = 0
var int winningTrades = 0
var int losingTrades = 0
var int breakevenTrades = 0
var int currentWinStreak = 0
var int currentLossStreak = 0
var int maximumWinStreak = 0
var int maximumLossStreak = 0
var float netResultR = 0.0
var float grossProfitR = 0.0
var float grossLossR = 0.0
var string lastTradeResult = "NONE"
var float lastTradeResultR = 0.0

bool tp1HitEvent = false
bool tp2HitEvent = false
bool tp3HitEvent = false
bool stopLossHitEvent = false
bool tradeClosedThisBar = false
float tradeExitPrice = na

// Extend active drawings through the current candle.
if tradeActive
    if not na(activeTp1Box)
        box.set_right(activeTp1Box, bar_index + 1)
    if not na(activeTp2Box)
        box.set_right(activeTp2Box, bar_index + 1)
    if not na(activeTp3Box)
        box.set_right(activeTp3Box, bar_index + 1)
    if not na(activeStopBox)
        box.set_right(activeStopBox, bar_index + 1)
    if not na(activeEntryLine)
        line.set_x2(activeEntryLine, bar_index + 1)
    if not na(activeTp1Line)
        line.set_x2(activeTp1Line, bar_index + 1)
    if not na(activeTp2Line)
        line.set_x2(activeTp2Line, bar_index + 1)
    if not na(activeTp3Line)
        line.set_x2(activeTp3Line, bar_index + 1)
    if not na(activeStopLine)
        line.set_x2(activeStopLine, bar_index + 1)

// Multi-target execution model.
// Active trades show all levels. Only completed TP3 trades retain historical drawings.
// Other outcomes delete all trade drawings and transform the original signal label.
if enableTradeEngine and tradeActive and bar_index > tradeEntryBar
    bool stopTouched = tradeDirection == 1 ? low <= tradeStopPrice : high >= tradeStopPrice
    bool tp1Touched = tradeDirection == 1 ? high >= tradeTp1Price : low <= tradeTp1Price
    bool tp2Touched = tradeDirection == 1 ? high >= tradeTp2Price : low <= tradeTp2Price
    bool tp3Touched = tradeDirection == 1 ? high >= tradeTp3Price : low <= tradeTp3Price

    bool closeAtStop = false
    bool closeAtTp3 = false

    if stopTouched and sameBarPriority == "Stop First"
        closeAtStop := true
    else
        if tp1Touched and not tradeTp1Hit
            tradeTp1Hit := true
            tp1HitEvent := true

            if not na(activeTp1Box)
                box.set_bgcolor(activeTp1Box, color.new(color.rgb(0, 185, 120), 78))
                box.set_border_color(activeTp1Box, color.new(color.rgb(0, 210, 140), 0))
            if not na(activeTp1Line)
                line.set_style(activeTp1Line, line.style_solid)
                line.set_width(activeTp1Line, 3)

        if tp2Touched and not tradeTp2Hit
            if not tradeTp1Hit
                tradeTp1Hit := true
                tp1HitEvent := true

                if not na(activeTp1Box)
                    box.set_bgcolor(activeTp1Box, color.new(color.rgb(0, 185, 120), 78))
                    box.set_border_color(activeTp1Box, color.new(color.rgb(0, 210, 140), 0))
                if not na(activeTp1Line)
                    line.set_style(activeTp1Line, line.style_solid)
                    line.set_width(activeTp1Line, 3)

            tradeTp2Hit := true
            tp2HitEvent := true

            if not na(activeTp2Box)
                box.set_bgcolor(activeTp2Box, color.new(color.rgb(0, 185, 120), 78))
                box.set_border_color(activeTp2Box, color.new(color.rgb(0, 210, 140), 0))
            if not na(activeTp2Line)
                line.set_style(activeTp2Line, line.style_solid)
                line.set_width(activeTp2Line, 3)

        if tp3Touched
            if not tradeTp1Hit
                tradeTp1Hit := true
                tp1HitEvent := true
            if not tradeTp2Hit
                tradeTp2Hit := true
                tp2HitEvent := true

            tp3HitEvent := true
            closeAtTp3 := true

            if not na(activeTp1Box)
                box.set_bgcolor(activeTp1Box, color.new(color.rgb(0, 185, 120), 78))
                box.set_border_color(activeTp1Box, color.new(color.rgb(0, 210, 140), 0))
            if not na(activeTp2Box)
                box.set_bgcolor(activeTp2Box, color.new(color.rgb(0, 185, 120), 78))
                box.set_border_color(activeTp2Box, color.new(color.rgb(0, 210, 140), 0))
            if not na(activeTp3Box)
                box.set_bgcolor(activeTp3Box, color.new(color.rgb(0, 185, 120), 70))
                box.set_border_color(activeTp3Box, color.new(color.rgb(0, 235, 150), 0))
            if not na(activeTp1Line)
                line.set_style(activeTp1Line, line.style_solid)
                line.set_width(activeTp1Line, 3)
            if not na(activeTp2Line)
                line.set_style(activeTp2Line, line.style_solid)
                line.set_width(activeTp2Line, 3)
            if not na(activeTp3Line)
                line.set_style(activeTp3Line, line.style_solid)
                line.set_width(activeTp3Line, 3)

        if stopTouched and not closeAtTp3
            closeAtStop := true

    if enableDynamicAlerts
        string activeDirectionText = tradeDirection == 1 ? "🚀 LONG" : "🔴 SHORT"

        if tp1HitEvent
            alert(f_targetAlertMessage("🥉 TP1 HIT", activeDirectionText, tradeTp1Price, tradeEntryPrice, tradeStopPrice, tradeTp1Price, tradeTp2Price, tradeTp3Price), alert.freq_all)

        if tp2HitEvent
            alert(f_targetAlertMessage("🥈 TP2 HIT", activeDirectionText, tradeTp2Price, tradeEntryPrice, tradeStopPrice, tradeTp1Price, tradeTp2Price, tradeTp3Price), alert.freq_all)

        if tp3HitEvent
            alert(f_targetAlertMessage("🏆 TP3 HIT — FULL TARGET", activeDirectionText, tradeTp3Price, tradeEntryPrice, tradeStopPrice, tradeTp1Price, tradeTp2Price, tradeTp3Price), alert.freq_all)

    if closeAtTp3 or closeAtStop
        tradeClosedThisBar := true

        float portion = 1.0 / 3.0
        float realizedResultR = 0.0
        int reachedTargets = 0

        if tradeTp1Hit
            realizedResultR += tradeTp1R * portion
            reachedTargets += 1
        if tradeTp2Hit
            realizedResultR += tradeTp2R * portion
            reachedTargets += 1
        if closeAtTp3
            realizedResultR += tradeTp3R * portion
            reachedTargets += 1
        else
            realizedResultR -= float(3 - reachedTargets) * portion

        tradeExitPrice := closeAtTp3 ? tradeTp3Price : tradeStopPrice
        stopLossHitEvent := closeAtStop
        lastTradeResultR := realizedResultR
        netResultR += realizedResultR
        totalClosedTrades += 1

        if realizedResultR > 0.0001
            winningTrades += 1
            grossProfitR += realizedResultR
            currentWinStreak += 1
            currentLossStreak := 0
            maximumWinStreak := math.max(maximumWinStreak, currentWinStreak)
        else if realizedResultR < -0.0001
            losingTrades += 1
            grossLossR += math.abs(realizedResultR)
            currentLossStreak += 1
            currentWinStreak := 0
            maximumLossStreak := math.max(maximumLossStreak, currentLossStreak)
        else
            breakevenTrades += 1
            currentWinStreak := 0
            currentLossStreak := 0

        string closedResultName = "🛑 SL"
        float closedResultPrice = tradeStopPrice
        color closedResultColor = color.rgb(220, 45, 65)
        string closedResultLabelSize = slResultLabelSize

        if closeAtTp3
            closedResultName := "🏆 TP3"
            closedResultPrice := tradeTp3Price
            closedResultColor := color.rgb(0, 205, 135)
            closedResultLabelSize := tp3ResultLabelSize
        else if tradeTp2Hit
            closedResultName := "✅ CLOSED TP2"
            closedResultPrice := tradeTp2Price
            closedResultColor := color.rgb(0, 185, 125)
            closedResultLabelSize := tp2ResultLabelSize
        else if tradeTp1Hit
            closedResultName := "⚠️ CLOSED TP1"
            closedResultPrice := tradeTp1Price
            closedResultColor := color.rgb(225, 145, 35)
            closedResultLabelSize := tp1ResultLabelSize

        lastTradeResult := closedResultName

        if enableDynamicAlerts and closeAtStop
            string stopDirectionText = tradeDirection == 1 ? "🚀 LONG" : "🔴 SHORT"
            alert(f_stopAlertMessage(stopDirectionText, closedResultName, tradeExitPrice, tradeEntryPrice, tradeStopPrice, tradeTp1Hit, tradeTp2Hit), alert.freq_all)

        if showTradeResultLabels
            string resultText = closedResultName + "\n🏁 TRADE CLOSED"
            string resultTooltip = "🏁 Trade Result: " + closedResultName + "\n🧭 Original Direction: " + (tradeDirection == 1 ? "LONG" : "SHORT") + "\n🎯 Setup Type: " + activeTradeType + "\n🏅 Setup Grade: " + activeTradeGrade + "\n🛡️ Risk Model: " + activeRiskModel + "\n📍 Entry: " + str.tostring(tradeEntryPrice, format.mintick) + "\n🚪 Actual Exit: " + str.tostring(tradeExitPrice, format.mintick) + "\n🎉 Highest Target Reached: " + closedResultName

            if closeAtTp3
                string tp3ResultText = "🏆 TP3 HIT 🏆\n✅ FULL TARGET"
                string tp3ResultTooltip = "🏆 TP3 Victory\n🧭 Direction: " + (tradeDirection == 1 ? "LONG" : "SHORT") + "\n🎯 Setup Type: " + activeTradeType + "\n🏅 Setup Grade: " + activeTradeGrade + "\n🛡️ Risk Model: " + activeRiskModel + "\n📍 Entry: " + str.tostring(tradeEntryPrice, format.mintick) + "\n🎯 TP3 Exit: " + str.tostring(tradeExitPrice, format.mintick) + "\n🚀 Full target sequence completed"
                label.new(x = bar_index, y = closedResultPrice, text = tp3ResultText, xloc = xloc.bar_index, yloc = yloc.price, color = color.rgb(190, 0, 255), style = tradeDirection == 1 ? label.style_label_down : label.style_label_up, textcolor = color.white, size = f_labelSize(tp3ResultLabelSize), tooltip = tp3ResultTooltip, force_overlay = true, text_formatting = text.format_bold + text.format_italic)
            else if not na(activeTradeSignalLabel)
                label.set_text(activeTradeSignalLabel, resultText)
                label.set_color(activeTradeSignalLabel, closedResultColor)
                label.set_textcolor(activeTradeSignalLabel, color.white)
                label.set_size(activeTradeSignalLabel, f_labelSize(closedResultLabelSize))
                label.set_text_formatting(activeTradeSignalLabel, text.format_bold + text.format_italic)
                label.set_tooltip(activeTradeSignalLabel, resultTooltip)

        if showHistoricalTrades and showTradeZones and closeAtTp3
            int retainedBoxCount = 0
            int retainedLineCount = 0

            // Only completed TP3 trades retain the original trade model.
            if not na(activeTp1Box)
                array.push(historicalTradeBoxes, activeTp1Box)
                retainedBoxCount += 1
            if not na(activeTp2Box)
                array.push(historicalTradeBoxes, activeTp2Box)
                retainedBoxCount += 1
            if not na(activeTp3Box)
                array.push(historicalTradeBoxes, activeTp3Box)
                retainedBoxCount += 1
            if not na(activeStopBox)
                array.push(historicalTradeBoxes, activeStopBox)
                retainedBoxCount += 1

            if not na(activeEntryLine)
                array.push(historicalTradeLines, activeEntryLine)
                retainedLineCount += 1
            if not na(activeTp1Line)
                array.push(historicalTradeLines, activeTp1Line)
                retainedLineCount += 1
            if not na(activeTp2Line)
                array.push(historicalTradeLines, activeTp2Line)
                retainedLineCount += 1
            if not na(activeTp3Line)
                array.push(historicalTradeLines, activeTp3Line)
                retainedLineCount += 1
            if not na(activeStopLine)
                array.push(historicalTradeLines, activeStopLine)
                retainedLineCount += 1

            array.push(historicalTradeBoxCounts, retainedBoxCount)
            array.push(historicalTradeLineCounts, retainedLineCount)

            while array.size(historicalTradeBoxCounts) > historicalTradeLimit
                int boxesToDelete = array.shift(historicalTradeBoxCounts)
                int linesToDelete = array.shift(historicalTradeLineCounts)

                int remainingBoxes = boxesToDelete
                while remainingBoxes > 0
                    if array.size(historicalTradeBoxes) > 0
                        box oldBox = array.shift(historicalTradeBoxes)
                        box.delete(oldBox)
                    remainingBoxes -= 1

                int remainingLines = linesToDelete
                while remainingLines > 0
                    if array.size(historicalTradeLines) > 0
                        line oldLine = array.shift(historicalTradeLines)
                        line.delete(oldLine)
                    remainingLines -= 1
        else
            // SL, Closed TP1 and Closed TP2 retain no historical trade drawings.
            if not na(activeTp1Box)
                box.delete(activeTp1Box)
            if not na(activeTp2Box)
                box.delete(activeTp2Box)
            if not na(activeTp3Box)
                box.delete(activeTp3Box)
            if not na(activeStopBox)
                box.delete(activeStopBox)
            if not na(activeEntryLine)
                line.delete(activeEntryLine)
            if not na(activeTp1Line)
                line.delete(activeTp1Line)
            if not na(activeTp2Line)
                line.delete(activeTp2Line)
            if not na(activeTp3Line)
                line.delete(activeTp3Line)
            if not na(activeStopLine)
                line.delete(activeStopLine)

        tradeActive := false
        tradeDirection := 0
        tradeEntryBar := na
        tradeEntryPrice := na
        tradeStopPrice := na
        tradeTp1Price := na
        tradeTp2Price := na
        tradeTp3Price := na
        tradeInitialRisk := na
        tradeTp1R := na
        tradeTp2R := na
        tradeTp3R := na
        tradeTp1Hit := false
        tradeTp2Hit := false
        activeTradeType := "NONE"
        activeTradeGrade := "C"
        activeRiskModel := "NONE"
        activeTp1Box := na
        activeTp2Box := na
        activeTp3Box := na
        activeStopBox := na
        activeEntryLine := na
        activeTp1Line := na
        activeTp2Line := na
        activeTp3Line := na
        activeStopLine := na
        activeTradeSignalLabel := na

//══════════════════════════════════════════════════════════════════════
// FINAL NON-REPAINT SIGNALS
// One active visual trade is allowed when the trade engine is enabled.
//══════════════════════════════════════════════════════════════════════

tradeSlotAvailable = not enableTradeEngine or (not tradeActive and not tradeClosedThisBar)

bullishSignal = barstate.isconfirmed and bullishEntryCandidate and bullishZeroLinePass and absoluteStrengthPass and bullishQualityPass and bullishTrendPass and antiChopPass and bullishQualificationPass and bullishCandlePass and separationPass and bullishPersistencePass and cooldownPass and tradeSlotAvailable
bearishSignal = barstate.isconfirmed and bearishEntryCandidate and bearishZeroLinePass and absoluteStrengthPass and bearishQualityPass and bearishTrendPass and antiChopPass and bearishQualificationPass and bearishCandlePass and separationPass and bearishPersistencePass and cooldownPass and tradeSlotAvailable

string bullishSignalType = bullishCandidateType
string bearishSignalType = bearishCandidateType

if bullishSignal
    lastSignalBar := bar_index
    bullishSetupArmed := false
    bearishSetupArmed := false
    bullishSetupBar := na
    bearishSetupBar := na
    bullishArmedType := "NONE"
    bearishArmedType := "NONE"

if bearishSignal
    lastSignalBar := bar_index
    bullishSetupArmed := false
    bearishSetupArmed := false
    bullishSetupBar := na
    bearishSetupBar := na
    bullishArmedType := "NONE"
    bearishArmedType := "NONE"

// Open the trade model after the signal has been fully confirmed.
if enableTradeEngine and bullishSignal
    tradeActive := true
    tradeDirection := 1
    tradeEntryBar := bar_index
    tradeEntryPrice := close
    tradeInitialRisk := selectedStopDistance
    tradeStopPrice := tradeEntryPrice - selectedStopDistance
    tradeTp1Price := tradeEntryPrice + selectedTp1Distance
    tradeTp2Price := tradeEntryPrice + selectedTp2Distance
    tradeTp3Price := tradeEntryPrice + selectedTp3Distance
    tradeTp1R := selectedTp1R
    tradeTp2R := selectedTp2R
    tradeTp3R := selectedTp3R
    tradeTp1Hit := false
    tradeTp2Hit := false
    activeTradeType := bullishSignalType
    activeTradeGrade := bullishSetupGrade
    activeRiskModel := riskModel

    if enableDynamicAlerts
        alert(f_entryAlertMessage("🚀 LONG", activeTradeType, activeTradeGrade, bullishSetupScore, activeRiskModel, tradeEntryPrice, tradeStopPrice, tradeTp1Price, tradeTp2Price, tradeTp3Price, xauModeMismatch), alert.freq_all)

    if showTradeZones
        activeTp1Box := box.new(left = bar_index, top = tradeTp1Price, right = bar_index + 1, bottom = tradeEntryPrice, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 185, 120), 35), bgcolor = color.new(color.rgb(0, 185, 120), 91), force_overlay = true)
        activeTp2Box := box.new(left = bar_index, top = tradeTp2Price, right = bar_index + 1, bottom = tradeTp1Price, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 195, 130), 35), bgcolor = color.new(color.rgb(0, 195, 130), 89), force_overlay = true)
        activeTp3Box := box.new(left = bar_index, top = tradeTp3Price, right = bar_index + 1, bottom = tradeTp2Price, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 210, 140), 30), bgcolor = color.new(color.rgb(0, 210, 140), 87), force_overlay = true)
        activeStopBox := box.new(left = bar_index, top = tradeEntryPrice, right = bar_index + 1, bottom = tradeStopPrice, xloc = xloc.bar_index, border_color = color.new(color.rgb(220, 45, 65), 10), border_width = 2, border_style = line.style_solid, bgcolor = color.new(color.rgb(220, 45, 65), 88), force_overlay = true)

        activeEntryLine := line.new(x1 = bar_index, y1 = tradeEntryPrice, x2 = bar_index + 1, y2 = tradeEntryPrice, xloc = xloc.bar_index, extend = extend.none, color = color.white, style = line.style_solid, width = 2, force_overlay = true)
        activeTp1Line := line.new(x1 = bar_index, y1 = tradeTp1Price, x2 = bar_index + 1, y2 = tradeTp1Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 175, 125), style = line.style_dashed, width = 2, force_overlay = true)
        activeTp2Line := line.new(x1 = bar_index, y1 = tradeTp2Price, x2 = bar_index + 1, y2 = tradeTp2Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 195, 135), style = line.style_dashed, width = 2, force_overlay = true)
        activeTp3Line := line.new(x1 = bar_index, y1 = tradeTp3Price, x2 = bar_index + 1, y2 = tradeTp3Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 220, 145), style = line.style_dashed, width = 2, force_overlay = true)
        activeStopLine := line.new(x1 = bar_index, y1 = tradeStopPrice, x2 = bar_index + 1, y2 = tradeStopPrice, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(235, 55, 75), style = line.style_solid, width = 2, force_overlay = true)

else if enableTradeEngine and bearishSignal
    tradeActive := true
    tradeDirection := -1
    tradeEntryBar := bar_index
    tradeEntryPrice := close
    tradeInitialRisk := selectedStopDistance
    tradeStopPrice := tradeEntryPrice + selectedStopDistance
    tradeTp1Price := tradeEntryPrice - selectedTp1Distance
    tradeTp2Price := tradeEntryPrice - selectedTp2Distance
    tradeTp3Price := tradeEntryPrice - selectedTp3Distance
    tradeTp1R := selectedTp1R
    tradeTp2R := selectedTp2R
    tradeTp3R := selectedTp3R
    tradeTp1Hit := false
    tradeTp2Hit := false
    activeTradeType := bearishSignalType
    activeTradeGrade := bearishSetupGrade
    activeRiskModel := riskModel

    if enableDynamicAlerts
        alert(f_entryAlertMessage("🔴 SHORT", activeTradeType, activeTradeGrade, bearishSetupScore, activeRiskModel, tradeEntryPrice, tradeStopPrice, tradeTp1Price, tradeTp2Price, tradeTp3Price, xauModeMismatch), alert.freq_all)

    if showTradeZones
        activeTp1Box := box.new(left = bar_index, top = tradeEntryPrice, right = bar_index + 1, bottom = tradeTp1Price, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 185, 120), 35), bgcolor = color.new(color.rgb(0, 185, 120), 91), force_overlay = true)
        activeTp2Box := box.new(left = bar_index, top = tradeTp1Price, right = bar_index + 1, bottom = tradeTp2Price, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 195, 130), 35), bgcolor = color.new(color.rgb(0, 195, 130), 89), force_overlay = true)
        activeTp3Box := box.new(left = bar_index, top = tradeTp2Price, right = bar_index + 1, bottom = tradeTp3Price, xloc = xloc.bar_index, border_color = color.new(color.rgb(0, 210, 140), 30), bgcolor = color.new(color.rgb(0, 210, 140), 87), force_overlay = true)
        activeStopBox := box.new(left = bar_index, top = tradeStopPrice, right = bar_index + 1, bottom = tradeEntryPrice, xloc = xloc.bar_index, border_color = color.new(color.rgb(220, 45, 65), 10), border_width = 2, border_style = line.style_solid, bgcolor = color.new(color.rgb(220, 45, 65), 88), force_overlay = true)

        activeEntryLine := line.new(x1 = bar_index, y1 = tradeEntryPrice, x2 = bar_index + 1, y2 = tradeEntryPrice, xloc = xloc.bar_index, extend = extend.none, color = color.white, style = line.style_solid, width = 2, force_overlay = true)
        activeTp1Line := line.new(x1 = bar_index, y1 = tradeTp1Price, x2 = bar_index + 1, y2 = tradeTp1Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 175, 125), style = line.style_dashed, width = 2, force_overlay = true)
        activeTp2Line := line.new(x1 = bar_index, y1 = tradeTp2Price, x2 = bar_index + 1, y2 = tradeTp2Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 195, 135), style = line.style_dashed, width = 2, force_overlay = true)
        activeTp3Line := line.new(x1 = bar_index, y1 = tradeTp3Price, x2 = bar_index + 1, y2 = tradeTp3Price, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(0, 220, 145), style = line.style_dashed, width = 2, force_overlay = true)
        activeStopLine := line.new(x1 = bar_index, y1 = tradeStopPrice, x2 = bar_index + 1, y2 = tradeStopPrice, xloc = xloc.bar_index, extend = extend.none, color = color.rgb(235, 55, 75), style = line.style_solid, width = 2, force_overlay = true)

//══════════════════════════════════════════════════════════════════════
// ENTRY LABEL TEXT
//══════════════════════════════════════════════════════════════════════

string bullishLabelText = "🚀 LONG"
string bearishLabelText = "🔴 SHORT"

if entryLabelContent == "Grade"
    bullishLabelText := "🚀 LONG " + bullishSetupGrade
    bearishLabelText := "🔴 SHORT " + bearishSetupGrade
else if entryLabelContent == "Score + Grade"
    bullishLabelText := "🚀 LONG " + bullishSetupGrade + "\n⭐ " + str.tostring(math.round(bullishSetupScore))
    bearishLabelText := "🔴 SHORT " + bearishSetupGrade + "\n⭐ " + str.tostring(math.round(bearishSetupScore))

bullishTooltip = "🚀 LONG MACD Momentum Setup\n🎯 Setup Type: " + bullishSignalType + "\n🏅 Setup Grade: " + bullishSetupGrade + "\n⭐ Composite Score: " + str.tostring(bullishSetupScore, "#.0") + "\n⚡ Momentum Score: " + str.tostring(bullishQualityScore, "#.0") + "\n🧪 Entry Score: " + str.tostring(bullishEntryScore, "#.0") + "\n📊 Regime Score: " + str.tostring(marketRegimeScore, "#.0") + "\n📈 Trend Bias: " + trendState
bearishTooltip = "🔴 SHORT MACD Momentum Setup\n🎯 Setup Type: " + bearishSignalType + "\n🏅 Setup Grade: " + bearishSetupGrade + "\n⭐ Composite Score: " + str.tostring(bearishSetupScore, "#.0") + "\n⚡ Momentum Score: " + str.tostring(bearishQualityScore, "#.0") + "\n🧪 Entry Score: " + str.tostring(bearishEntryScore, "#.0") + "\n📊 Regime Score: " + str.tostring(marketRegimeScore, "#.0") + "\n📉 Trend Bias: " + trendState

if showEntryLabels and bullishSignal
    label bullishEntryLabel = label.new(x = bar_index, y = low, text = bullishLabelText, xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.rgb(0, 185, 120), style = label.style_label_up, textcolor = color.white, size = f_labelSize(longLabelSize), tooltip = bullishTooltip, force_overlay = true, text_formatting = text.format_bold + text.format_italic)
    if enableTradeEngine
        activeTradeSignalLabel := bullishEntryLabel

if showEntryLabels and bearishSignal
    label bearishEntryLabel = label.new(x = bar_index, y = high, text = bearishLabelText, xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.rgb(220, 45, 65), style = label.style_label_down, textcolor = color.white, size = f_labelSize(shortLabelSize), tooltip = bearishTooltip, force_overlay = true, text_formatting = text.format_bold + text.format_italic)
    if enableTradeEngine
        activeTradeSignalLabel := bearishEntryLabel

//══════════════════════════════════════════════════════════════════════
// VISUALS
//══════════════════════════════════════════════════════════════════════

color histogramColor = color.rgb(170, 90, 105)

if bullishExpanding
    histogramColor := color.rgb(0, 210, 140)
else if bullishContracting
    histogramColor := color.rgb(90, 165, 135)
else if bearishExpanding
    histogramColor := color.rgb(235, 55, 75)

color momentumBackground = na

if strongBullishMomentum
    momentumBackground := color.new(color.rgb(0, 200, 130), 90)
else if weakBullishMomentum
    momentumBackground := color.new(color.rgb(0, 150, 115), 94)
else if strongBearishMomentum
    momentumBackground := color.new(color.rgb(225, 45, 65), 90)
else if weakBearishMomentum
    momentumBackground := color.new(color.rgb(170, 55, 70), 94)

color finalBackground = showMomentumBackground ? momentumBackground : na

if showChopBackground and antiChopMode != "Off" and not antiChopPass
    finalBackground := color.new(color.gray, 91)

hline(0.0, "Zero Line", color = color.new(color.gray, 55), linestyle = hline.style_dotted)
plot(showHistogram ? histogramVisual : na, title = "MACD Histogram", style = plot.style_columns, color = histogramColor, linewidth = 3, display = display.pane)
plot(showMacdLine ? macdLine : na, title = "MACD Line", color = color.white, linewidth = 2, display = display.pane)
plot(showSignalLine ? signalLine : na, title = "Signal Line", color = color.rgb(230, 60, 75), linewidth = 2, display = display.pane)

bullishMacdMarker = showMacdSignalMarkers and bullishSignal ? macdLine : na
bearishMacdMarker = showMacdSignalMarkers and bearishSignal ? macdLine : na

// Neon glow layer
plotshape(bullishMacdMarker, title = "LONG MACD Neon Glow", style = shape.circle, location = location.absolute, color = color.new(color.rgb(0, 255, 170), 72), size = size.large, display = display.pane)
plotshape(bearishMacdMarker, title = "SHORT MACD Neon Glow", style = shape.circle, location = location.absolute, color = color.new(color.rgb(255, 45, 85), 72), size = size.large, display = display.pane)

// Bright center dot
plotshape(bullishMacdMarker, title = "LONG MACD Neon Dot", style = shape.circle, location = location.absolute, color = color.rgb(0, 255, 170), size = size.normal, display = display.pane)
plotshape(bearishMacdMarker, title = "SHORT MACD Neon Dot", style = shape.circle, location = location.absolute, color = color.rgb(255, 45, 85), size = size.normal, display = display.pane)

bgcolor(finalBackground, title = "Momentum and Regime Background")

//══════════════════════════════════════════════════════════════════════
// MAIN-CHART MINI DASHBOARD
//══════════════════════════════════════════════════════════════════════

string dashboardMomentum = "➖ NEUTRAL"
color dashboardMomentumColor = color.rgb(150, 155, 165)

if strongBullishMomentum
    dashboardMomentum := "⚡ STRONG LONG"
    dashboardMomentumColor := color.rgb(0, 235, 155)
else if weakBullishMomentum
    dashboardMomentum := "🟢 LONG"
    dashboardMomentumColor := color.rgb(70, 205, 155)
else if strongBearishMomentum
    dashboardMomentum := "⚡ STRONG SHORT"
    dashboardMomentumColor := color.rgb(255, 70, 100)
else if weakBearishMomentum
    dashboardMomentum := "🔴 SHORT"
    dashboardMomentumColor := color.rgb(220, 90, 110)

string dashboardTrend = "⚪ OFF"
color dashboardTrendColor = color.rgb(145, 150, 160)

if trendState == "BULLISH"
    dashboardTrend := "📈 BULLISH"
    dashboardTrendColor := color.rgb(0, 220, 145)
else if trendState == "BEARISH"
    dashboardTrend := "📉 BEARISH"
    dashboardTrendColor := color.rgb(240, 65, 90)
else if trendState == "NEUTRAL"
    dashboardTrend := "➖ NEUTRAL"
    dashboardTrendColor := color.rgb(225, 170, 45)

string dashboardRegime = "⚪ OFF"
color dashboardRegimeColor = color.rgb(145, 150, 160)

if marketRegimeState == "TRENDING"
    dashboardRegime := "✅ TRENDING"
    dashboardRegimeColor := color.rgb(0, 220, 145)
else if marketRegimeState == "DEVELOPING"
    dashboardRegime := "🟡 DEVELOPING"
    dashboardRegimeColor := color.rgb(235, 175, 45)
else if marketRegimeState == "CHOP"
    dashboardRegime := "⛔ CHOP"
    dashboardRegimeColor := color.rgb(235, 75, 95)

string dashboardTrade = "⏳ WAITING"
color dashboardTradeColor = color.rgb(150, 155, 165)

if tradeActive
    string tradeProgress = tradeTp2Hit ? "TP2 REACHED" : tradeTp1Hit ? "TP1 REACHED" : "ACTIVE"
    if tradeDirection == 1
        dashboardTrade := "🚀 LONG • " + tradeProgress
        dashboardTradeColor := color.rgb(0, 225, 150)
    else
        dashboardTrade := "🔴 SHORT • " + tradeProgress
        dashboardTradeColor := color.rgb(245, 65, 95)

string dashboardLastResult = lastTradeResult == "NONE" ? "—" : lastTradeResult
color dashboardLastColor = color.rgb(150, 155, 165)

if lastTradeResult == "🏆 TP3"
    dashboardLastColor := color.rgb(190, 0, 255)
else if lastTradeResult == "✅ CLOSED TP2"
    dashboardLastColor := color.rgb(0, 210, 140)
else if lastTradeResult == "⚠️ CLOSED TP1"
    dashboardLastColor := color.rgb(230, 155, 40)
else if lastTradeResult == "🛑 SL"
    dashboardLastColor := color.rgb(235, 60, 85)

string dashboardProtection = "🛡️ ATR MODE"
color dashboardProtectionColor = color.rgb(145, 150, 160)

if xauFixedModeActive
    if xauModeMismatch
        dashboardProtection := "⚠️ CHECK SYMBOL"
        dashboardProtectionColor := color.rgb(255, 155, 35)
    else
        dashboardProtection := "✅ XAUUSD VERIFIED"
        dashboardProtectionColor := color.rgb(0, 220, 145)

var table miniDashboard = table.new(
     position.bottom_right,
     2,
     7,
     bgcolor = color.new(color.rgb(16, 18, 24), 8),
     frame_color = color.new(color.rgb(190, 0, 255), 20),
     frame_width = 1,
     border_color = color.new(color.rgb(85, 90, 105), 55),
     border_width = 1,
     force_overlay = true
)

if barstate.isfirst
    table.merge_cells(miniDashboard, 0, 0, 1, 0)

if barstate.islast
    if showMiniDashboard
        table.cell(miniDashboard, 0, 0, "⚡ MACD ENGINE", bgcolor = color.new(color.rgb(190, 0, 255), 35), text_color = color.white, text_size = size.small, text_halign = text.align_center, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 1, "Momentum", bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 1, dashboardMomentum, bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = dashboardMomentumColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 2, "Trend", bgcolor = color.new(color.rgb(20, 23, 30), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 2, dashboardTrend, bgcolor = color.new(color.rgb(20, 23, 30), 10), text_color = dashboardTrendColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 3, "Regime", bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 3, dashboardRegime, bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = dashboardRegimeColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 4, "Trade", bgcolor = color.new(color.rgb(20, 23, 30), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 4, dashboardTrade, bgcolor = color.new(color.rgb(20, 23, 30), 10), text_color = dashboardTradeColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 5, "Last", bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 5, dashboardLastResult, bgcolor = color.new(color.rgb(25, 28, 36), 10), text_color = dashboardLastColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)

        table.cell(miniDashboard, 0, 6, "Protection", bgcolor = color.new(color.rgb(20, 23, 30), 10), text_color = color.rgb(190, 195, 205), text_size = size.tiny, text_halign = text.align_left, text_formatting = text.format_bold + text.format_italic)
        table.cell(miniDashboard, 1, 6, dashboardProtection, bgcolor = xauModeMismatch ? color.new(color.rgb(255, 120, 20), 78) : color.new(color.rgb(20, 23, 30), 10), text_color = dashboardProtectionColor, text_size = size.tiny, text_halign = text.align_right, text_formatting = text.format_bold + text.format_italic)
    else
        table.clear(miniDashboard, 0, 0, 1, 6)

//══════════════════════════════════════════════════════════════════════
// DATA WINDOW
//══════════════════════════════════════════════════════════════════════

plot(bullishQualityScore, title = "Bullish Momentum Score", color = na, display = display.data_window)
plot(bearishQualityScore, title = "Bearish Momentum Score", color = na, display = display.data_window)
plot(bullishSetupScore, title = "Bullish Composite Score", color = na, display = display.data_window)
plot(bearishSetupScore, title = "Bearish Composite Score", color = na, display = display.data_window)
plot(bullishEntryScore, title = "Bullish Entry Score", color = na, display = display.data_window)
plot(bearishEntryScore, title = "Bearish Entry Score", color = na, display = display.data_window)
plot(separationRatio, title = "MACD Separation Ratio", color = na, display = display.data_window)
plot(bullishPersistenceBars, title = "Bullish Persistence Bars", color = na, display = display.data_window)
plot(bearishPersistenceBars, title = "Bearish Persistence Bars", color = na, display = display.data_window)
plot(marketRegimeScore, title = "Market Regime Score", color = na, display = display.data_window)
plot(adxValue, title = "ADX Value", color = na, display = display.data_window)
plot(priceEfficiency, title = "Price Efficiency", color = na, display = display.data_window)
plot(emaSeparationAtr, title = "EMA Separation ATR", color = na, display = display.data_window)
plot(volatilityExpansion, title = "Volatility Expansion", color = na, display = display.data_window)
plot(normalizedHistogramStrength, title = "Normalized Histogram Strength", color = na, display = display.data_window)
plot(xauModeMismatch ? 1.0 : 0.0, title = "XAUUSD Mode Warning", color = na, display = display.data_window)

plot(tradeActive ? 1.0 : 0.0, title = "Trade Active", color = na, display = display.data_window)
plot(tradeActive ? float(tradeDirection) : 0.0, title = "Trade Direction", color = na, display = display.data_window)
plot(tradeActive ? tradeEntryPrice : na, title = "Active Entry Price", color = na, display = display.data_window)
plot(tradeActive ? tradeStopPrice : na, title = "Active Stop Price", color = na, display = display.data_window)
plot(tradeActive ? tradeTp1Price : na, title = "Active TP1 Price", color = na, display = display.data_window)
plot(tradeActive ? tradeTp2Price : na, title = "Active TP2 Price", color = na, display = display.data_window)
plot(tradeActive ? tradeTp3Price : na, title = "Active TP3 Price", color = na, display = display.data_window)
plot(tradeActive and tradeTp1Hit ? 1.0 : 0.0, title = "TP1 Reached", color = na, display = display.data_window)
plot(tradeActive and tradeTp2Hit ? 1.0 : 0.0, title = "TP2 Reached", color = na, display = display.data_window)
plot(float(totalClosedTrades), title = "Closed Trades", color = na, display = display.data_window)
plot(float(winningTrades), title = "Winning Trades", color = na, display = display.data_window)
plot(float(losingTrades), title = "Losing Trades", color = na, display = display.data_window)
plot(float(breakevenTrades), title = "Breakeven Trades", color = na, display = display.data_window)
plot(netResultR, title = "Net Result R", color = na, display = display.data_window)
plot(grossProfitR, title = "Gross Profit R", color = na, display = display.data_window)
plot(grossLossR, title = "Gross Loss R", color = na, display = display.data_window)
plot(lastTradeResultR, title = "Last Trade Result R", color = na, display = display.data_window)
plot(float(maximumWinStreak), title = "Maximum Win Streak", color = na, display = display.data_window)
plot(float(maximumLossStreak), title = "Maximum Loss Streak", color = na, display = display.data_window)

//══════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════

alertcondition(bullishSignal, title = "🚀 MACD Momentum LONG", message = "🚀 MACD Momentum Entry Engine generated a qualified LONG setup.")
alertcondition(bearishSignal, title = "🔴 MACD Momentum SHORT", message = "🔴 MACD Momentum Entry Engine generated a qualified SHORT setup.")
alertcondition(tp1HitEvent, title = "🥉 MACD Momentum TP1", message = "🥉 MACD Momentum Entry Engine active trade reached TP1.")
alertcondition(tp2HitEvent, title = "🥈 MACD Momentum TP2", message = "🥈 MACD Momentum Entry Engine active trade reached TP2.")
alertcondition(tp3HitEvent, title = "🏆 MACD Momentum TP3", message = "🏆 MACD Momentum Entry Engine active trade reached TP3 and closed.")
alertcondition(stopLossHitEvent, title = "🛑 MACD Momentum SL", message = "🛑 MACD Momentum Entry Engine active trade reached its stop-loss level.")
alertcondition(xauModeMismatch and (bullishSignal or bearishSignal), title = "⚠️ XAUUSD Mode Warning", message = "⚠️ XAUUSD Fixed Pips mode is active on a non-XAUUSD symbol. Verify pip size and target distances.")
````
