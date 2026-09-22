<!-- tradingview-pine-id: PUB;95cba583e555467abb178149b00fa157 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Reaction Path [BullByte]

Source: https://www.tradingview.com/script/8JLOZcNH-Reaction-Path-BullByte/

## Description

Reaction Path is a price-action, pressure, volatility, and trade-geometry indicator designed to organize two different market behaviours into one integrated framework:

1. Reaction: price has displaced away from its current Fair Price area and the recent candle behaviour shows conditions consistent with a possible response back toward the opposing side.

2. Continuation: price is positioned beyond the Fair Price area while pressure is migrating in the same direction, recent movement is efficient enough to qualify as directional, and the current bar shows sufficient expansion and participation.

The purpose of Reaction Path is not to predict the future or guarantee a reversal or continuation. It is designed to help traders distinguish between changing pressure, developing movement, established directional travel, exhaustion, and neutral conditions.

[image]https://www.tradingview.com/x/aBoM4WXo/[/image]

The indicator combines several complementary measurements rather than relying on a conventional overbought/oversold oscillator.

The main components are:

[*]A wick-weighted Fair Price calculation.
[*]An adaptive Reaction Band around Fair Price.
[*]A Pressure Centre based on where price closes within its recent ranges.
[*]Pressure Migration to measure how that pressure balance is changing.
[*]Market-state classification including EXHAUSTION, SHIFT, BUILDING, TRAVEL, MOVING UP, MOVING DOWN, and NEUTRAL.
[*]Reaction and Continuation signal qualification.
[*]Trend Efficiency as a directional regime filter for continuation conditions.
[*]Candle-character analysis using body efficiency, wick relationships, range speed, directional dominance, depth, and volume behaviour.
[*]Spike and immediate post-spike filtering.
[*]Adaptive Failure Memory that becomes more selective after setup invalidations.
[*]ATR-based Path Level 1, Path Level 2, and invalidation geometry.
[*]A Projected Path corridor for visualizing the current route from entry toward Path Level 2.
[*]A compact dashboard showing market state, path direction, Fair Price location, and active setup levels.
[*]Historical setup visualization for reviewing completed setups.
[*]Bar-close alert events for new signals, target completion, and invalidation.

Reaction Path is intended as an analytical framework. The signals and plotted levels are references for decision-making and should be evaluated together with the actual market context, instrument behaviour, liquidity, execution conditions, and the trader's own risk process.

---

ORIGINALITY - WHY THIS IS NOT A MASHUP

Reaction Path is built as a single integrated behavioural engine rather than a collection of unrelated indicators placed together.

The individual measurements are not displayed as independent conventional indicators which are combined with arbitrary voting rules.

Instead, the engine builds a connected chain:

[*]Fair Price
[*]Price displacement from Fair Price
[*]Pressure Centre
[*]Pressure Migration
[*]Market state
[*]Candle character
[*]Trend efficiency
[*]Signal qualification
[*]Trade geometry
[*]Setup lifecycle
[*]Failure Memory

Each stage contributes information to the stages that follow it.

Fair Price establishes the current reference area.

Pressure Centre measures where recent closes are occurring within their candle ranges.

Migration measures whether that pressure balance is moving.

Market-state logic classifies the behaviour of that migration.

Reaction and Continuation conditions then use several independent characteristics of price behaviour before a setup is created.

Failure Memory adds another layer by recording the characteristics surrounding an invalidated setup and making subsequent qualification more selective when sufficiently similar conditions reappear.

This structure is what makes the indicator an integrated system rather than a simple mashup of unrelated calculations.

---

PURPOSE OF THE INDICATOR

Markets do not move in only one way.
Sometimes price stretches away from its current area of accepted value and begins to show rejection.
Sometimes price moves away from that area and continues because pressure remains aligned with the direction of travel.
Sometimes a large candle creates apparent momentum but is primarily wick and produces little decisive progress.
Sometimes pressure begins changing before a visible directional move becomes established.

Reaction Path is designed to separate these situations.

The central question is not simply:

"Is price going up or down?"

Instead, the framework asks:

[*]Where is price relative to its current Fair Price area?
[*]Is recent closing pressure migrating?
[*]Is that migration strengthening, weakening, shifting, or reaching an extreme?
[*]Is the recent movement efficient or highly rotational?
[*]Is the current bar expanding relative to recent activity?
[*]Are wicks and candle bodies supporting the intended behaviour?
[*]Is volume informative on the current symbol?
[*]Has a similar setup recently failed?
[*]Has the current setup reached Path Level 1, Path Level 2, or its invalidation reference?

---

WHY THESE SPECIFIC MECHANICS

FAIR PRICE

Fair Price is calculated from a custom typical-price measure:

[pine](high + low + 2 x close) / 4[/pine]

The calculation is weighted according to candle body efficiency.

Candles with a smaller body relative to their total range receive greater weight. This gives more influence to candles that spent more of their range away from their decisive body.
The result is a rolling reference value intended to represent the recent area around which price has been behaving.
An adaptive deviation value is calculated from the same weighted observations.

Together they create:

[*]Fair Price
[*]Fair Price Upper
[*]Fair Price Lower

This gives the indicator a dynamic reference zone rather than relying on a fixed percentage distance.

REACTION BAND

The Reaction Band visualizes the Fair Price area as three nested bands.

The inner and outer areas represent progressively wider deviations around the current Fair Price.

The band therefore provides context for whether price is:

[*]Inside the current fair area.
[*]Moving toward an edge.
[*]Beyond the upper region.
[*]Beyond the lower region.

The band color also reflects the current pressure/state classification.

PRESSURE CENTRE

The Pressure Centre does not ask whether a candle is simply green or red.

Instead, it examines where the close occurred inside the candle's own high-low range.
A close near the high represents stronger upward closing pressure for that candle.
A close near the low represents stronger downward closing pressure.
The measurement is averaged over a rolling window and weighted using the same candle-character concept used by Fair Price.
This produces a smoother representation of recent closing-pressure behaviour.

PRESSURE MIGRATION

Pressure Migration measures how much the Pressure Centre has changed between two points in time.
A positive migration indicates that the recent closing-pressure balance has shifted upward.
A negative migration indicates that it has shifted downward.
The engine then evaluates the magnitude and context of this migration instead of treating every zero crossing as a signal.

This is important because very small changes around an inflection point can alternate direction without representing meaningful behavioural change.

---

MARKET STATES

REACTION PATH classifies the current market into several behavioural states.

EXHAUSTION

Pressure has reached an extreme zone.
This does not automatically mean that price must reverse.
It means the Pressure Centre has reached one of the defined extreme regions used by the engine.

SHIFT

A meaningful migration transition has occurred across the configured stall threshold.
The purpose is to identify a stronger change in pressure rather than reacting to a minor zero-line fluctuation.

BUILDING

Pressure is moving in the upward direction and is approaching or has reached the internal building region.

MOVING UP

Upward pressure migration has become sufficiently strong to qualify as upward movement outside the building state.

MOVING DOWN

Downward pressure migration has become sufficiently strong to qualify as downward movement.

TRAVEL

Directional continuation conditions are active while price is positioned on the corresponding side of Fair Price.

NEUTRAL

None of the above behavioural classifications currently has priority.

---

WHAT MAKES A REACTION SIGNAL

A Reaction signal is not generated simply because price is above or below Fair Price.

For a long Reaction setup, the engine looks for a combination of conditions including:

[*]Price displacement sufficiently below Fair Price.
[*]Recent directional efficiency supporting the intended reaction.
[*]Sufficient directional dominance.
[*]A stronger lower-wick response than the opposing wick.
[*]Adequate recent range speed.
[*]Sufficient volume participation when volume is informative.
[*]Sufficient recent depth below Fair Price.
[*]Absence of a qualifying spike or immediate post-spike retracement condition.

The short Reaction condition is the mirrored structure.
The important concept is that displacement alone is not enough.
The engine looks for displacement together with evidence that recent candle behaviour is producing a meaningful response.

---

WHAT MAKES A CONTINUATION SIGNAL

Continuation setups use a different logic.

A long Continuation setup requires price to be positioned above the Fair Price region together with:

[*]A qualifying expansion bar.
[*]Limited opposing wick behaviour.
[*]Sufficient candle efficiency.
[*]Adequate range speed.
[*]Sufficient volume participation when volume is informative.
[*]Positive trend direction.
[*]Adequate trend efficiency.
[*]A normal bar rather than a qualifying spike condition.

Short Continuation setups use the corresponding bearish structure.

Two consecutive closes outside the Fair Price band are recognized as acceptance by the state engine. A Continuation signal itself does not universally require two consecutive closes; the current bar can qualify when the other continuation conditions are satisfied.

---

EXPANSION LOGIC

A continuation setup requires more than simply producing the largest candle of a recent window.

The current range must satisfy both:

1. It must be at least as large as the previous recent maximum range.
2. It must also exceed an ATR-based expansion floor.

This prevents a relatively large candle inside a very quiet environment from being treated as meaningful expansion solely because it happens to be the largest recent candle.

ATR is therefore used as a volatility scale and also as part of the expansion qualification.ATR is not used as a standalone directional signal.

---

CANDLE CHARACTER AND QUALITY FILTERS

Reaction Path evaluates several aspects of recent candle behaviour.

BODY EFFICIENCY

Measures the body relative to the full candle range.

Higher efficiency means more of the candle's movement occurred through the body rather than through wicks.

WICK BALANCE

Compares upper and lower wick behaviour to determine whether the candle is showing rejection characteristics or cleaner directional movement.

RANGE SPEED

Compares the current range with recent average range behaviour.

VOLUME RATIO

Compares current volume with its recent baseline when the symbol provides meaningful volume information.

On symbols where volume is flat, missing, or otherwise uninformative, the engine avoids pretending that volume provides meaningful confirmation and uses a neutral treatment instead.

DEPTH

Measures how far recent price movement has extended beyond the Fair Price reference.

DIRECTIONAL DOMINANCE

Measures how much of the recent short window has been directionally aligned with the candidate setup.These dimensions are evaluated together rather than allowing one measurement to create a setup by itself.

---

SPIKE FILTER

Large candles are not automatically treated as strong momentum.

Reaction Path identifies oversized, low-efficiency bars where a substantial portion of the range is wick rather than decisive body movement.
Signal generation is withheld during such qualifying spike conditions.
The engine also checks the bar immediately following a qualifying spike. If that next bar is simply retracing inside the previous spike's range, it is also treated as a lower-quality setup environment.
The goal is to avoid treating every unusually large candle as meaningful directional expansion.

---

FAILURE MEMORY

Reaction Path includes an adaptive Failure Memory system.

When an active setup reaches its invalidation boundary before reaching Path Level 2, the engine records characteristics of the failed environment, including elements such as:

[*]Direction.
[*]Signal family.
[*]Displacement.
[*]Pressure Migration.
[*]Directional efficiency.
[*]Speed.
[*]Depth.
[*]Volume behaviour. 
[*]Pressure state.
[*]Range relative to ATR.

The system then uses two related forms of adaptation.

GLOBAL FAILURE TIGHTENING

After consecutive invalidations, the qualification requirements become progressively more selective, with the escalation capped by the internal maximum failure count.

This means repeated failed conditions do not simply produce an unlimited stream of identical setups.

SIMILARITY-BASED MEMORY

The current environment can also be compared with the recorded failed environment.
A sufficiently similar setup can be blocked when it belongs to the same relevant signal family and direction.
A failed Reaction therefore weighs most strongly against a highly similar subsequent Reaction attempt, while the global failure tightening can still affect other qualifying setups.

Failure Memory uses two independent lifecycles. The direction and similarity block can clear when the market behaviour resets or the memory window expires, allowing a genuinely changed market environment to qualify again. The consecutive-failure count follows a separate lifecycle and is cleared when Path Level 2 is reached or when its own time-based expiry occurs. This allows the system to remember a losing sequence without permanently blocking a direction.

This is a behavioural filter, not a guarantee that future similar setups will fail.

---

SETUP SENSITIVITY

The Setup Sensitivity input provides a single control for the overall selectivity of the engine.

Adjusts the overall qualification balance. Lower values tighten distance and expansion requirements while relaxing several quality thresholds; higher values do the opposite. Use this control to adapt overall setup selectivity.
The thresholds are coupled rather than exposing every individual internal gate.

This is intentional.

Changing one isolated component independently could create an internal imbalance between distance, efficiency, speed, depth, volume, expansion, and trend requirements.The sensitivity control therefore moves these requirements together.

---

TRADE GEOMETRY

When a setup is created, Reaction Path establishes four primary reference levels:

ENTRY

The setup's entry reference is the signal-bar closing price.

PATH LEVEL 1

Path Level 1 is calculated from the setup entry using the configured ATR distance.

PATH LEVEL 2

Path Level 2 is the primary larger projected objective used by the setup geometry and is also calculated from the setup entry using ATR.

INVALIDATION

For Reaction setups, the invalidation boundary is derived beyond the relevant reaction extreme using the configured ATR distance.

For Continuation setups, the invalidation reference is the Fair Price value captured when the setup is created.

These are analytical reference levels.

They do not guarantee execution, fill price, stop execution, or trading outcomes.

---

PROJECTED PATH

The Projected Path is a visual corridor extending from the setup entry toward Path Level 2.

It is not a forecast.

It does not use future prices to calculate where the path should go.
Instead, the corridor is shaped using the confirmed setup and the current market-state information available after the setup has been created.

Its curvature responds to pressure migration and displacement.

Its width responds to the current state and field energy, allowing the visual route to become wider when the market environment is more uncertain and narrower when conditions are calmer.

Because the path can respond to subsequent confirmed market conditions, it should be read as a dynamic visual reference rather than a promised route taken by price.

---

PATH LEVEL EXTENSIONS

When a continuation setup remains active and another qualifying continuation condition appears in the same direction, Path Level 2 can be extended.

Extensions are limited by an internal maximum so that one continuously trending environment cannot expand the objective indefinitely.

The extension uses the configured Path Level 1 ATR distance as the incremental extension amount.

WHY THE REACTION FIELD EXISTS

The Reaction Field was created to solve a specific problem:
Price candles show what happened, but they do not always make the change in underlying closing pressure easy to read.
A market can move higher while its internal pressure is weakening.
A market can move lower while selling pressure is beginning to lose control.
A reversal can develop through several candles before the change becomes obvious from price alone.

Likewise, a strong-looking candle does not automatically mean that directional pressure is continuing. The candle may contain a large amount of wick, may occur inside a rotational market, or may simply be an isolated expansion.

Reaction Path therefore separates two ideas:

PRICE LOCATION: Where price is relative to the current Fair Price area.

PRESSURE MIGRATION: How the recent balance of closing pressure is changing.

The Reaction Field is the visual representation of that second component.

For every candle, the engine examines where the close occurred inside the candle's own high-low range.

A close near the high contributes stronger upward closing pressure.

A close near the low contributes stronger downward closing pressure.

Those observations are averaged over a rolling window using the same wick-weighting concept used by the Fair Price calculation.

The engine then compares the current Pressure Centre with an earlier Pressure Centre.

That difference is called Migration.

In simplified form:

Pressure Centre = weighted average of close location within recent candle ranges

Migration = Current Pressure Centre - Prior Pressure Centre

The Reaction Field plots this migration as a behavioural field.

This creates a visual layer that answers a different question from the price chart:

"Is control shifting, and in which direction?"

That is why the oscillator is not intended to behave like RSI, MACD, Stochastic, or a traditional overbought/oversold oscillator.
It is also not intended to be used as a standalone buy/sell trigger.
Its purpose is to provide continuous context around the discrete events identified by the main engine.

For example:

[*]Price can be below Fair Price while pressure begins migrating upward.
[*]Pressure can continue building before a full Reaction setup qualifies.
[*]Migration can reverse direction across the configured stall threshold, creating a SHIFT condition.
[*]Pressure can reach an extreme zone, producing an EXHAUSTION state.
[*]Pressure can remain directionally aligned while price travels beyond Fair Price, supporting continuation context.

The oscillator therefore acts as the behavioural "state layer" between raw candles and the final setup qualification.

The candle chart shows the movement.
The Fair Price Band shows location.
The Reaction Field shows pressure migration.

The signal engine combines these and additional price, volume, speed, depth, efficiency, expansion, and trend conditions before creating a Reaction or Continuation setup.

This separation is intentional.

The Reaction Field is there to help the trader understand the condition that surrounds a signal, rather than simply displaying another indicator that generates an independent signal.

---

REACTION FIELD - HOW TO READ THE PANE

The lower Reaction Field is the indicator's dedicated analytical pane.

It is intentionally not designed as a conventional overbought/oversold oscillator.

The field visualizes the direction and magnitude of Pressure Migration.

REACTION SPINE

The main line represents the scaled migration value.
Positive territory indicates upward pressure migration.
Negative territory indicates downward pressure migration.
The distance from the centre gives additional visual context about migration magnitude.

REACTION FLOW

Reaction Flow is a scaled companion to the Reaction Spine.
It provides a secondary visual representation of the same migration field so smaller movements can be compared more easily.

REACTION CENTRE

The centre line provides the zero reference.

REACTION FIELD

The shaded field surrounds the Reaction Spine.

Its width responds to field energy, which reflects migration magnitude and range-speed behaviour.

REACTION TRANSITION

A small transition marker can appear when the engine identifies a SHIFT or EXHAUSTION condition.

The Reaction Field should therefore be interpreted as a pressure-behaviour visualization, not as an independent buy/sell oscillator.

---

DASHBOARD - WHAT EACH ROW MEANS

The on-chart dashboard summarizes the current state without requiring the trader to interpret every calculation separately.

MARKET STATE

Displays the current behavioural classification such as:

[*]EXHAUSTION
[*]SHIFT
[*]BUILDING
[*]TRAVEL
[*]MOVING UP
[*]MOVING DOWN
[*]NEUTRAL

PATH

Shows whether the current pressure/path condition is:

[*]UP OPEN
[*]DOWN OPEN
[*]WAIT

LOCATION

Shows where the current close sits relative to the Fair Price region:

[*]ABOVE FAIR
[*]BELOW FAIR
[*]AT FAIR

ACTIVE SETUP

When a setup is active, the dashboard provides:

[*]ENTRY
[*]PATH LEVEL 1
[*]PATH LEVEL 2
[*]INVALIDATION

When no setup is active, the dashboard displays that no active setup is currently present.

The dashboard also displays the current symbol and chart timeframe.

---

VISUAL SETTINGS

SHOW HISTORICAL SETUPS

When enabled, completed setups remain visible so historical behaviour can be reviewed.

The number of retained completed setups is capped by the Maximum Historical Setups setting.

The current implementation allows up to 25 retained historical setups.

SHOW REACTION BAND

Displays the three nested Fair Price bands directly on the price chart.

SHOW PROJECTED PATH

Displays the dynamic corridor between the setup entry and Path Level 2.

This can be disabled when a cleaner chart is preferred.

SHOW DASHBOARD

Displays the current market-state and setup summary.

DASHBOARD SIZE

Available sizes:

[*]Small
[*]Medium
[*]Large

DASHBOARD POSITION

Available positions:

[*]Top Left
[*]Top Right
[*]Bottom Left
[*]Bottom Right

---

INPUTS - GROUPED BY SETTINGS PANEL

ENGINE SENSITIVITY

Signal Mode

[*]Reaction Only
[*]Continuation Only
[*]Both

This determines which signal family the engine is allowed to generate.

Setup Sensitivity

Controls overall selectivity.

Lower values allow more setups.

Higher values require stronger market behaviour.

TRADE GEOMETRY

Path Level 1

Defines the distance from the setup entry to Path Level 1 in ATR units.

Path Level 2

Defines the distance from the setup entry to Path Level 2 in ATR units.

Invalidation

Defines the invalidation distance used for Reaction setup geometry.

VISUAL SYSTEM

Show Historical Setups

Keeps completed setups visible for historical review.

Maximum Historical Setups

Controls the maximum number of completed setup drawings retained at once.

Show Reaction Band

Controls visibility of the Fair Price bands.

Show Projected Path

Controls visibility of the dynamic path corridor.

DASHBOARD

Show Dashboard

Controls dashboard visibility.

Dashboard Size

Controls dashboard text size.

Dashboard Position

Controls dashboard placement.

---

HOW TO USE REACTION PATH

A practical workflow is to begin with the market state rather than immediately reacting to an individual signal.

STEP 1 - CHECK LOCATION

Determine whether price is:

[*]ABOVE FAIR
[*]BELOW FAIR
[*]AT FAIR

This establishes the current relationship between price and the Fair Price area.

STEP 2 - CHECK PRESSURE

Read the Reaction Field and Pressure Migration.

Look for whether pressure is:

[*]Building.
[*]Moving.
[*]Shifting.
[*]Reaching exhaustion.
[*]Remaining neutral.

STEP 3 - IDENTIFY THE BEHAVIOUR

A Reaction condition and a Continuation condition represent different market behaviours.

Do not interpret every long condition as interchangeable with every other long condition.

Reaction setups are based on displacement and response characteristics.

Continuation setups are based on directional persistence, expansion, efficiency, and trend alignment.

STEP 4 - CHECK THE SETUP GEOMETRY

When a signal appears, review:

[*]ENTRY
[*]PATH LEVEL 1
[*]PATH LEVEL 2
[*]INVALIDATION

These levels provide the framework for evaluating the setup rather than requiring the trader to estimate distances visually.

STEP 5 - OBSERVE THE PROJECTED PATH

When enabled, use the Projected Path as a visual representation of the current route and uncertainty.

It is not a prediction.

STEP 6 - REVIEW FAILURE MEMORY

When the engine has recently experienced an invalidation, subsequent qualification may become more selective.

This can result in fewer signals during repeated similar conditions.

STEP 7 - APPLY YOUR OWN RISK PROCESS

The indicator provides analytical references.

Position size, leverage, execution, risk per trade, market selection, trading hours, and final trade decisions remain the responsibility of the trader.

---

RECOMMENDED TIMEFRAMES

Reaction Path can be applied to different chart timeframes, but it is particularly suited to intraday analysis where changes in candle behaviour, pressure migration, and directional expansion can be observed clearly.

As a practical starting point, traders may evaluate it on:

[*]1 minute
[*]3 minute
[*]5 minute
[*]15 minute

The appropriate timeframe depends on the instrument, liquidity, trading style, and desired holding period.

The same settings should not automatically be assumed to behave identically across every market or timeframe.

The indicator does not use multi-timeframe security requests, so its calculations are based on the selected chart's own data.

---

REAL-LIFE EXAMPLE - CONSOLIDATED

Consider a market trading below its current Fair Price area.

Price has recently displaced downward, but the recent candles begin showing stronger lower-wick response while upward closing pressure starts migrating.

The engine may classify the environment as BUILDING or SHIFT depending on the measured pressure transition.

If the remaining Reaction requirements are also satisfied, a REACTION LONG setup can be created.

The chart then provides:

[*]ENTRY
[*]PATH LEVEL 1
[*]PATH LEVEL 2
[*]INVALIDATION

The trader can now evaluate the situation using a defined reference structure rather than treating every tick as a new decision.

A different scenario can occur when price is already above Fair Price.

Suppose the market maintains positive pressure migration, the recent trend is efficient rather than highly rotational, the current range expands beyond its recent range window and the ATR expansion floor, opposing wick behaviour remains limited, and the other continuation requirements are satisfied.

The engine can then produce a CONTINUATION LONG setup.

If the market instead produces an oversized low-efficiency spike, the signal can be withheld.

If an existing setup becomes invalidated, Failure Memory records the characteristics of the environment and can make highly similar subsequent attempts more selective.

LIVE CHART EXAMPLE: REACTION LONG ON QQQ (15m)

[image]https://www.tradingview.com/x/Q7NXuZSb/[/image]

Price spent an extended stretch below the lower edge of the wick-weighted Fair Price band, with the Reaction Field spine sitting in negative territory, a sign that recent candles had been closing nearer their lows than their highs, reflecting sustained downward closing pressure.
As price pushed further beneath Fair Price, the depth of that penetration cleared the engine's minimum requirement, and the bars driving it stayed clean of spike behaviour, sufficient range, volume, and body efficiency, without any oversized, low-quality wick bar in the mix.
On the signal candle itself, the lower wick grew clearly longer than the upper wick: a decisive rejection of the downside rather than an indecisive drift. At the same moment, the Pressure Centre had already begun migrating upward, flipping the Reaction Field spine from negative to positive on that identical bar.
It was this convergence, sufficient displacement and depth below Fair Price, a wick-confirmed rejection, and a same-bar pressure flip - that opened the gate for a Reaction Long setup, rather than any single condition acting alone.

LIVE CHART EXAMPLE - CONTINUATION LONG ON BTC/USDT (5m)

[image]https://www.tradingview.com/x/YkHXMBOj/[/image]

Price had already pushed above the fair-price band and, over the signal bar and the one immediately before it, closed above it both times- the engine's threshold for acceptance rather than a single overshoot. Over the same stretch, the broader move up from the earlier local low remained efficient enough to qualify as a genuine trend rather than rotational chop, and the Reaction Field spine was already migrating upward, meaning closing pressure was actively supporting the direction of the setup.
On the signal candle, range expanded beyond the recent local maximum and cleared the ATR-based expansion floor, while the upper wick stayed minimal and the body dominated the bar, a decisive, clean directional bar regardless of its color. It was these conditions holding together on that one bar- acceptance above fair, a qualifying expansion bar, clean wick geometry, and trend efficiency- that opened the gate for a Continuation Long setup, rather than any single measurement acting alone.

These examples describe how the engine behaves conceptually. They are not historical performance claims or guarantees of what price will do next.

---

ALERTS

Reaction Path provides alert events for the setup lifecycle.

NEW SIGNAL

Triggered when a new Reaction or Continuation setup is created.

TARGET REACHED

Triggered when the active setup reaches its Path Level 2 completion condition.

INVALIDATED

Triggered when the active setup reaches its invalidation condition.

Signal, target, and invalidation alerts are generated on confirmed bar events using once-per-bar-close alert frequency.

The alert message includes the chart symbol, timeframe, event type, signal type, and relevant price level.

Use TradingView's alert system to create the desired alert from the indicator.

---

CONFIRMATION, REPAINTING, AND DATA BEHAVIOUR

Current-bar signal decisions are restricted to confirmed bar data.

The indicator does not use request.security().

It does not use lookahead.

The signal lifecycle is therefore based on closed-bar confirmation rather than intrabar creation of a setup followed by later modification of that signal.

Some visual elements, such as live setup labels and dashboard presentation, may update while the current chart bar is forming.

Those visual updates do not create, close, or modify the confirmed signal decision.

The indicator is also intentionally disabled on non-standard chart types such as Heikin Ashi, Renko, Kagi, Point & Figure, and Range charts.

Use a standard chart type when evaluating the indicator.

---

LIMITATIONS

Reaction Path is an analytical indicator, not an automatic trading system.

No indicator can determine with certainty whether a market will reverse, continue, reach a target, or respect an invalidation level.

The calculations are sensitive to the characteristics of the selected instrument and timeframe.

Low-liquidity markets, unusual spreads, sudden news events, market gaps, abnormal volatility, and unreliable volume data can affect the behaviour of any price-based analytical model.

Volume-dependent qualification also depends on the quality of volume supplied by the symbol.

The Projected Path is a visual representation of the current confirmed setup and market state. It is not a future-price forecast.

Path Level 1, Path Level 2, and Invalidation are reference levels derived from the configured geometry and current market information. They do not represent guaranteed execution levels or guaranteed outcomes.

Historical setup drawings are provided for visual review and should not be interpreted as a verified backtest or performance record.

If Path Level 2 and Invalidation are both touched during the same bar, the script cannot determine the true intrabar sequence from OHLC data alone. It resolves this ambiguity conservatively by treating the setup as invalidated when both levels are touched on the same bar.

The indicator does not replace independent analysis, risk management, or execution planning.

---

IMPORTANT NOTES

For consistent interpretation:

[*]Use standard chart types.
[*]Evaluate signals on closed bars.
[*]Understand the difference between Reaction and Continuation signals.
[*]Treat the Fair Price area as a dynamic reference, not an absolute support or resistance level.
[*]Read the Reaction Field as pressure migration rather than a traditional overbought/oversold oscillator.
[*]Consider the dashboard as a summary of the engine state, not an independent signal source.
[*]Treat Failure Memory as an adaptive qualification filter, not as a prediction of future failure.
[*]Review Path Level 1, Path Level 2, and Invalidation together.
[*]Do not assume identical behaviour across different symbols and timeframes.
[*]Use your own risk and execution rules before acting on any setup.

---

DISCLAIMER

This indicator is provided for informational and educational purposes only and does not constitute financial, investment, trading, or other professional advice.

Trading financial markets involves substantial risk, including the possible loss of capital.

The signals, states, levels, visualizations, and alerts generated by Reaction Path are analytical references only. They do not guarantee market direction, execution, profitability, target achievement, or avoidance of losses.

Past market behaviour and historical setup visualization do not guarantee future results.

Users are responsible for their own trading decisions, risk management, position sizing, and execution.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © BullByte

// ============================================================================
// REACTION PATH [BullByte]
// ============================================================================
// An integrated behavioural reaction-and-continuation engine designed from
// price, volume and time. The engine does not depend on RSI, MACD,
// Bollinger Bands, or other conventional oscillator calculations.
//
//   CORE MECHANICS
//   Fair Price      - wick-weighted centre of value with an adaptive
//                     deviation band. High-wick (indecisive) candles
//                     receive higher weight because they represent less
//                     decisive directional displacement.
//   Pressure Centre - rolling close-location average showing relative
//                     closing pressure within each bar. Migration of this
//                     centre over time highlights directional pressure
//                     changes larger than the configured stall threshold.
//   Projected Path  - projected corridor whose width scales with current
//                     market uncertainty, not a fixed percentage band. It
//                     is a visual reference built from the confirmed setup
//                     and current market state, not a price forecast.
//   Failure Memory  - raises qualification requirements after a loss.
//                     Similarity-based blocking is scoped separately per
//                     signal family, while consecutive-loss tightening
//                     applies globally to subsequent setups.
//
// CONSTRAINTS
//   - Current-bar signal decisions use only confirmed data; no future data
//     is used to make the current signal decision.
//   - No request.security() or lookahead of any kind.
//   - Disabled on non-standard chart types (Heikin Ashi, Renko, etc.).
//
// DISCLAIMER
//   For informational and educational purposes only. Not financial advice.
//   Trading carries substantial risk of loss. Past tendencies shown by this
//   script do not guarantee future results. Use at your own risk.
//
// Author  : BullByte
// License : Mozilla Public License 2.0
// ============================================================================

//@version=6
indicator("Reaction Path [BullByte]", overlay = false, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 01 - INPUT REGISTRY
// ═════════════════════════════════════════════════════════════════════════════

var string GRP_PATH = "Trade Geometry"
var string GRP_VIS = "Visual System"
var string GRP_DASH = "Dashboard"
var string GRP_ENGINE = "Engine Sensitivity"

// --- Engine sensitivity: the one dial that scales every gate together -----
// All reaction/continuation thresholds move together off this single input
// because they were tuned as a set. Loosening one without the others would
// break the balance between them, so they are not exposed individually.

string signalModeInput = input.string(
     "Both",
     "Signal Mode",
     options = ["Reaction Only", "Continuation Only", "Both"],
     group = GRP_ENGINE,
     tooltip = "Choose which signal family the engine is allowed to open: Reaction setups (mean-reversion off fair value), Continuation setups (trend persistence), or both."
     )

float sensitivityInput = input.float(
     0.75,
     "Setup Sensitivity",
     minval = 0.50,
     maxval = 1.50,
     step = 0.05,
     group = GRP_ENGINE,
     tooltip = "Adjusts the overall qualification balance. Lower values tighten distance and expansion requirements while relaxing several quality thresholds; higher values do the opposite. Use this control to adapt overall setup selectivity."
     )

// --- Trade geometry: how far targets and invalidation sit from entry -----

float t1AtrInput = input.float(
     1.2,
     "Path Level 1",
     minval = 0.3,
     maxval = 8.0,
     step = 0.1,
     group = GRP_PATH,
     tooltip = "Distance from the setup entry reference to Path Level 1, measured in ATR units."
     )

float t2AtrInput = input.float(
     2.4,
     "Path Level 2",
     minval = 0.5,
     maxval = 12.0,
     step = 0.1,
     group = GRP_PATH,
     tooltip = "Distance from the setup entry reference to Path Level 2, measured in ATR units. This is the primary projected objective used by the indicator's trade geometry."
     )

float invalidationAtrInput = input.float(
     1.2,
     "Invalidation",
     minval = 0.3,
     maxval = 8.0,
     step = 0.1,
     group = GRP_PATH,
     tooltip = "Distance beyond the reaction extreme used to define the setup invalidation boundary. It is a reference level, not a guarantee of execution or outcome."
     )

// --- Visual system: what gets drawn on the chart --------------------------

bool showHistoryInput = input.bool(
     true,
     "Show Historical Setups",
     group = GRP_VIS,
     tooltip = "When enabled, completed setups stay visible on the chart (up to the Maximum Historical Setups limit below) instead of disappearing once they close, so you can review how past setups played out. When disabled, a setup's drawings are removed as soon as it closes."
     )

int maxHistoryInput = input.int(
     20,
     "Maximum Historical Setups",
     minval = 3,
     maxval = 25,
     group = GRP_VIS,
     tooltip = "Caps how many completed setups stay drawn on the chart at once. The oldest setup is automatically removed once this limit is reached. This is kept intentionally bounded to stay comfortably within TradingView's per-script drawing-object limits."
     )

bool showFairBandInput = input.bool(
     true,
     "Show Reaction Band",
     group = GRP_VIS,
     tooltip = "Displays the Fair Price zone as three nested bands on the price chart, showing the current wick-weighted value area and its deviation range. Turn off for a cleaner chart if you only want the pane readout and trade markers."
     )

bool showPathInput = input.bool(
     true,
     "Show Projected Path",
     group = GRP_VIS,
     tooltip = "Displays the Projected Path corridor running from the setup's entry toward Path Level 2. This is a visual route built from current market conditions, not a price forecast or guarantee. Turn off to show only the entry, target and invalidation lines without the corridor."
     )

// --- Dashboard --------------------------------------------------------------

bool showDashboardInput = input.bool(
     true,
     "Show Dashboard",
     group = GRP_DASH,
     tooltip = "Displays the on-chart panel summarising the current market state, path direction, price location relative to fair value, and the active setup's levels (if any)."
     )

string dashboardSizeInput = input.string(
     "Small",
     "Dashboard Size",
     options = ["Small", "Medium", "Large"],
     group = GRP_DASH,
     tooltip = "Controls the text size of the on-chart dashboard panel."
     )

string dashboardPositionInput = input.string(
     "Top Right",
     "Dashboard Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group = GRP_DASH,
     tooltip = "Controls which corner of the chart the dashboard panel is anchored to."
     )

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 02 - INTERNAL PARAMETERS
// ═════════════════════════════════════════════════════════════════════════════
// These are structural constants, not user preferences. They are coupled to
// each other by the math (window sizes match tolerance bands elsewhere in
// the script), so exposing them individually would let a user break that
// coupling without knowing it. They stay fixed by design.

int N = 20              // Lookback window for fair price and volume baseline.
int M = 5               // Short window for recent candle character (wicks, range, direction).
int K = 10              // Window for the pressure-centre calculation.
int J = 5               // Offset used to measure how far pressure has migrated.
int ATR_LENGTH = 14     // Standard ATR length used throughout for normalisation.

float MIN_DISPLACEMENT = 0.8               // Minimum distance from fair price, in half-bands, to qualify a reaction.
float MIN_DIRECTIONAL_EFFICIENCY = 0.55    // Minimum body-to-range quality required of the recent directional bars.
float MIN_SPEED = 0.9                      // Minimum bar range relative to the recent average range.
float MIN_VOLUME = 0.8                     // Minimum volume relative to its recent average.
float MIN_DEPTH = 0.5                      // Minimum penetration beyond fair price required for a reaction.

float SPIKE_MULTIPLIER = 3.0               // A bar this many times the average range is treated as a spike, not normal behaviour.
float SPIKE_EFFICIENCY = 0.2               // Efficiency threshold used to classify outsized bars as low-quality spike behaviour.
float CONTINUATION_MAX_WICK = 0.35         // Maximum wick ratio allowed on a continuation bar before it looks indecisive.

float EXHAUSTION_HIGH = 0.80               // Pressure centre above this is considered exhausted to the upside.
float EXHAUSTION_LOW = 0.20                // Pressure centre below this is considered exhausted to the downside.
float STALL_THRESHOLD = 0.015              // Minimum migration required before it counts as real directional drift, not noise.
float BUILD_THRESHOLD = 0.70               // Pressure centre level that marks the start of a "building" state.
float APPROACH_MINIMUM = 0.02              // How close to BUILD_THRESHOLD price must be to count as approaching it.

float MIGRATION_SCALE = 3.0                // Scales raw migration into the visual reaction-field units.

int TREND_WINDOW = 15                      // Lookback used to measure whether the market is actually trending before allowing a continuation signal.
float MIN_TREND_EFFICIENCY = 0.38          // Minimum net-displacement-to-path-length ratio required to qualify as trend-aligned.

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 02B - SENSITIVITY THRESHOLDS
// ═════════════════════════════════════════════════════════════════════════════
// The single Setup Sensitivity dial scales every gate below. Distance-type
// thresholds are divided by sensitivity (higher sensitivity => tighter
// distance requirement), while quality-type thresholds are multiplied by it
// (higher sensitivity => higher quality bar).

float displacementThreshold = MIN_DISPLACEMENT / sensitivityInput
float directionalEfficiencyThreshold = MIN_DIRECTIONAL_EFFICIENCY * sensitivityInput
float speedThreshold = MIN_SPEED * sensitivityInput
float depthThreshold = MIN_DEPTH / sensitivityInput
float continuationWickThreshold = CONTINUATION_MAX_WICK / sensitivityInput
float volumeThresholdSensitivity = MIN_VOLUME * sensitivityInput
float stallThreshold = STALL_THRESHOLD * sensitivityInput
float expansionAtrFloor = 0.70 / sensitivityInput
float trendEfficiencyThreshold = MIN_TREND_EFFICIENCY * sensitivityInput

bool reactionSignalsEnabled = signalModeInput != "Continuation Only"
bool continuationSignalsEnabled = signalModeInput != "Reaction Only"

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 03 - VISUAL PALETTE
// ═════════════════════════════════════════════════════════════════════════════

color COLOR_UP_REACTION = #38D9C4
color COLOR_UP_TRAVEL = #5B8CFF
color COLOR_DOWN_REACTION = #FF708A
color COLOR_DOWN_TRAVEL = #B56CFF

color COLOR_REACTION = #38D9C4
color COLOR_CONTINUATION = #6F8CFF
color COLOR_SHIFT = #FFC857
color COLOR_BUILDING = #55D8FF
color COLOR_EXHAUSTION = #B974FF
color COLOR_NEUTRAL = #9BA8B5
color COLOR_INVALIDATION = #FFAA4A
color COLOR_PATH_LEVEL_ONE = #4CAF50
color COLOR_PATH_LEVEL_TWO = #D6249F
color COLOR_WHITE = #F4F7FA

color COLOR_PANEL = #11161D
color COLOR_PANEL_BORDER = #2A323C

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 04 - UTILITIES
// ═════════════════════════════════════════════════════════════════════════════
// Small, reusable helper functions. Nothing here contains trading logic -
// only arithmetic and formatting that the rest of the script leans on.

safeDiv(float numerator, float denominator, float fallback) =>
    denominator == 0.0 or na(denominator) ? fallback : numerator / denominator

clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(value, maximum))

// Volume can be flat, missing, or meaningless on some symbols (e.g. certain
// index CFDs). This checks whether the last N bars actually show enough
// spread in volume to be worth using. If not, the engine falls back to a
// neutral volume ratio elsewhere rather than pretending volume matters.
volumeReliable() =>
    float volumeSum = 0.0
    float volumeSquares = 0.0

    for i = 0 to N - 1
        float currentVolume = nz(volume[i], 0.0)
        volumeSum += currentVolume
        volumeSquares += currentVolume * currentVolume

    float meanVolume = safeDiv(volumeSum, N, 0.0)
    float variance = safeDiv(volumeSquares, N, 0.0) - meanVolume * meanVolume
    float coefficient = safeDiv(math.sqrt(math.max(variance, 0.0)), meanVolume, 0.0)

    coefficient > 0.05

dashboardTextSize(string value) =>
     value == "Large"
         ? size.normal
         : value == "Medium"
             ? size.small
             : size.tiny

dashboardPosition(string value) =>
    value == "Top Left" ? position.top_left :
     value == "Bottom Left" ? position.bottom_left :
     value == "Bottom Right" ? position.bottom_right :
     position.top_right

stateColor(string value) =>
    value == "REACTION" ? COLOR_REACTION :
     value == "TRAVEL" ? COLOR_CONTINUATION :
     value == "BUILDING" ? COLOR_BUILDING :
     value == "SHIFT" ? COLOR_SHIFT :
     value == "EXHAUSTION" ? COLOR_EXHAUSTION :
     value == "MOVING UP" ? COLOR_UP_REACTION :
     value == "MOVING DOWN" ? COLOR_DOWN_REACTION :
     COLOR_NEUTRAL

// Builds one consistent alert message format for every event type this
// script fires. Keeping this in one place means every alert a user
// receives - signal, target, or invalidation - reads the same way.
buildAlertMessage(string eventLabel, string signalType, float priceLevel) =>
    syminfo.prefix + ":" + syminfo.ticker + " | " + timeframe.period + " | " + eventLabel + " | " + signalType + " | Price: " + str.tostring(priceLevel, format.mintick)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 05 - ATR / NORMALIZATION
// ═════════════════════════════════════════════════════════════════════════════

float atrValue = ta.atr(ATR_LENGTH)

// The signal engine runs only on standard chart types that use the
// instrument's actual OHLC prices. Synthetic chart types (Heikin Ashi,
// Renko, Kagi, Point & Figure, Range) construct price artificially and
// can produce unrealistic-looking setups, so the engine stays off and a
// visible warning is shown instead.
bool engineReady = chart.is_standard and bar_index > N + J + M + ATR_LENGTH

var label nonStandardWarning = na

if not chart.is_standard and barstate.islast
    label.delete(nonStandardWarning)
    nonStandardWarning := label.new(
         bar_index,
         high,
         "Reaction Path requires a standard chart.\nSignals are disabled on non-standard chart types.",
         color = COLOR_INVALIDATION,
         textcolor = COLOR_WHITE,
         style = label.style_label_left,
         size = size.normal,
         force_overlay = true
         )

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 06 - FAIR PRICE / REACTION BAND
// ═════════════════════════════════════════════════════════════════════════════
// "Fair price" here is a wick-weighted average of a typical price measure
// over the last N bars. Candles with smaller bodies relative to their
// range receive greater weight, while large decisive bodies receive less
// weight, because a large wick means price spent part of the bar away
// from its body and was less decisive. The half-band is the weighted
// average distance of price from that fair value - effectively a measure
// of how far bars have typically strayed from it recently.

fairCalc(int offset) =>
    float weightedBase = 0.0
    float totalWeight = 0.0

    for i = offset to offset + N - 1
        float basePrice = (high[i] + low[i] + 2.0 * close[i]) / 4.0
        float candleRange = high[i] - low[i]
        float candleBody = math.abs(close[i] - open[i])
        float weight = 1.0 - safeDiv(candleBody, candleRange, 1.0)

        weightedBase += basePrice * weight
        totalWeight += weight

    float fallbackFair = (high[offset] + low[offset] + 2.0 * close[offset]) / 4.0
    float fair = safeDiv(weightedBase, totalWeight, fallbackFair)

    float weightedDeviation = 0.0
    float deviationWeight = 0.0

    for i = offset to offset + N - 1
        float basePrice = (high[i] + low[i] + 2.0 * close[i]) / 4.0
        float candleRange = high[i] - low[i]
        float candleBody = math.abs(close[i] - open[i])
        float weight = 1.0 - safeDiv(candleBody, candleRange, 1.0)

        weightedDeviation += math.abs(basePrice - fair) * weight
        deviationWeight += weight

    float fallbackHalf = math.abs(close[offset] - fair) * 0.5

    float halfBand = math.max(
         safeDiv(weightedDeviation, deviationWeight, fallbackHalf),
         syminfo.mintick * 2.0
         )

    [fair, halfBand]

[fairPrice, fairHalf] = fairCalc(0)
[previousFair, previousHalf] = fairCalc(1)

float fairUpper = fairPrice + fairHalf
float fairLower = fairPrice - fairHalf

float previousUpper = previousFair + previousHalf
float previousLower = previousFair - previousHalf

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 07 - FAIR STATE
// ═════════════════════════════════════════════════════════════════════════════
// "Accepting" means price has closed outside the fair band on this bar and
// the previous bar too - a single close outside the band can be noise, two
// in a row is closer to acceptance of a new value area.

bool aboveFair = close > fairUpper
bool belowFair = close < fairLower

bool previousAboveFair = close[1] > previousUpper
bool previousBelowFair = close[1] < previousLower

bool acceptingAbove = aboveFair and previousAboveFair
bool acceptingBelow = belowFair and previousBelowFair

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 08 - PRESSURE CENTRE / MIGRATION
// ═════════════════════════════════════════════════════════════════════════════
// The pressure centre answers a simple question for each bar: where within
// its own high-low range did price end up closing? A close near the high
// indicates stronger upward closing pressure within that bar; a close near
// the low indicates stronger downward closing pressure. Averaging this
// over a window, weighted the same way as fair price, gives a smooth read
// on which side has had the stronger closing pressure recently.
// "Migration" is simply how much that balance has shifted between two
// points in time.

pressureCentreAt(int offset) =>
    float pressureSum = 0.0
    float pressureWeight = 0.0

    for i = offset to offset + K - 1
        float candleRange = high[i] - low[i]
        float candleBody = math.abs(close[i] - open[i])
        float weight = 1.0 - safeDiv(candleBody, candleRange, 1.0)
        float closeLocation = safeDiv(close[i] - low[i], candleRange, 0.5)

        pressureSum += closeLocation * weight
        pressureWeight += weight

    safeDiv(pressureSum, pressureWeight, 0.5)

float pressureNow = pressureCentreAt(0)
float pressurePrior = pressureCentreAt(J)
float pressurePrevious = pressureCentreAt(1)
float pressurePreviousPrior = pressureCentreAt(J + 1)

float migration = pressureNow - pressurePrior
float previousMigration = pressurePrevious - pressurePreviousPrior

bool approachingBuild =
     pressureNow >= BUILD_THRESHOLD - APPROACH_MINIMUM and
     pressureNow < BUILD_THRESHOLD and
     pressureNow > pressurePrior

bool exhaustion =
     pressureNow >= EXHAUSTION_HIGH or
     pressureNow <= EXHAUSTION_LOW

// Reversing requires migration to actually clear the stall band on both
// sides of zero, not merely cross it. A raw zero-crossing comparator would
// chatter on noise near an inflection point; requiring both readings to
// clear ±stallThreshold means only a genuine swing counts as a reversal.
bool reversing =
     not exhaustion and
     (
         (migration >= stallThreshold and previousMigration <= -stallThreshold) or
         (migration <= -stallThreshold and previousMigration >= stallThreshold)
     )

bool building =
     not exhaustion and
     not reversing and
     (approachingBuild or pressureNow >= BUILD_THRESHOLD) and
     migration > 0.0

bool migratingUp =
     not exhaustion and
     not reversing and
     not building and
     migration > stallThreshold

bool migratingDown =
     not exhaustion and
     not reversing and
     not building and
     not migratingUp and
     migration < -stallThreshold

bool pressureUp =
     migration > 0.0 and
     (migratingUp or building or reversing)

bool pressureDown =
     migration < 0.0 and
     (migratingDown or reversing)

bool continuationLong =
     migration > 0.0 and
     (building or migratingUp)

bool continuationShort =
     migration < 0.0 and
     migratingDown

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 08B - TREND EFFICIENCY (REGIME FILTER)
// ═════════════════════════════════════════════════════════════════════════════
// A continuation bet only makes sense if the market is actually trending.
// This measures net displacement over the trend window against the total
// distance travelled to get there. A value near 1 means almost every tick
// contributed to net progress (a clean trend); a value near 0 means the
// market covered a lot of ground but ended up roughly where it started
// (pure chop). Continuation signals require this ratio to clear a minimum
// before they are allowed to fire, so a sideways box can no longer produce
// a continuation setup just because one leg of the chop looked strong.

float trendNetDisplacement = close - close[TREND_WINDOW]

float trendPathLength = 0.0

for i = 0 to TREND_WINDOW - 1
    trendPathLength += math.abs(close[i] - close[i + 1])

float trendEfficiencyRatio = safeDiv(math.abs(trendNetDisplacement), trendPathLength, 0.0)

bool trendAlignedLong = trendNetDisplacement > 0.0 and trendEfficiencyRatio >= trendEfficiencyThreshold
bool trendAlignedShort = trendNetDisplacement < 0.0 and trendEfficiencyRatio >= trendEfficiencyThreshold

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 09 - REACTION CHARACTER ENGINE
// ═════════════════════════════════════════════════════════════════════════════
// This section measures the "quality" of the current bar and the bars
// immediately before it: how decisive it is, how it compares to recent
// range and volume, and which side (long or short) recent bars have been
// favouring.

float barRange = high - low
float barBody = math.abs(close - open)

float efficiency = safeDiv(barBody, barRange, 1.0)

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float upperWickRatio = safeDiv(upperWick, barRange, 0.0)
float lowerWickRatio = safeDiv(lowerWick, barRange, 0.0)

float averageRange = 0.0

for i = 1 to M
    averageRange += high[i] - low[i]

averageRange := safeDiv(averageRange, M, barRange)

float speedRatio = safeDiv(barRange, averageRange, 1.0)

bool reliableVolume = volumeReliable()

float averageVolume = 0.0

for i = 1 to N
    averageVolume += nz(volume[i], 0.0)

averageVolume := safeDiv(averageVolume, N, 0.0)

// If volume isn't meaningful on this symbol, use a neutral ratio so the
// raw volume value itself does not distort the engine. The resulting ratio
// may still be evaluated against the engine's overall volume threshold.
float volumeRatio = reliableVolume ? safeDiv(volume, averageVolume, 1.0) : 1.0

float directionalEfficiencyLong = 0.0
float directionalEfficiencyShort = 0.0

int directionalCountLong = 0
int directionalCountShort = 0

for i = 0 to M - 1
    float historicalRange = high[i] - low[i]
    float historicalBody = math.abs(close[i] - open[i])
    float historicalEfficiency = safeDiv(historicalBody, historicalRange, 1.0)

    // A doji (close == open) is neither a bullish nor a bearish bar and is
    // excluded from both buckets, rather than being counted as bearish by
    // default.
    if close[i] > open[i]
        directionalEfficiencyLong += historicalEfficiency
        directionalCountLong += 1
    else if close[i] < open[i]
        directionalEfficiencyShort += historicalEfficiency
        directionalCountShort += 1

float meanDirectionalEfficiencyLong = safeDiv(directionalEfficiencyLong, directionalCountLong, 0.0)
float meanDirectionalEfficiencyShort = safeDiv(directionalEfficiencyShort, directionalCountShort, 0.0)

float directionalDominanceLong = safeDiv(directionalCountLong, M, 0.0)
float directionalDominanceShort = safeDiv(directionalCountShort, M, 0.0)

float displacement = safeDiv(close - fairPrice, fairHalf, 0.0)

float depthBelowFair = 0.0
float depthAboveFair = 0.0

for i = 1 to M
    depthBelowFair := math.max(depthBelowFair, safeDiv(fairPrice - low[i], fairHalf, 0.0))
    depthAboveFair := math.max(depthAboveFair, safeDiv(high[i] - fairPrice, fairHalf, 0.0))

// A "spike" is an outsized, low-efficiency bar - most of its range is wick,
// not decisive movement. Signals are withheld on spike bars, and also on
// the bar right after a spike if that bar is simply retracing back inside
// the spike's range, since both cases are more likely to be low-quality
// noise than a genuine new setup.
bool currentSpike =
     barRange > SPIKE_MULTIPLIER * averageRange and
     efficiency < SPIKE_EFFICIENCY

bool previousSpikeReversal =
     (high[1] - low[1]) > SPIKE_MULTIPLIER * averageRange and
     safeDiv(
         math.abs(close[1] - open[1]),
         math.max(high[1] - low[1], syminfo.mintick),
         1.0
         ) < SPIKE_EFFICIENCY and
     close >= low[1] and
     close <= high[1]

bool normalBar =
     not currentSpike and
     not previousSpikeReversal

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 10 - EXPANSION / SIGNAL GATES
// ═════════════════════════════════════════════════════════════════════════════
// These are the actual qualification checks a bar must pass to be
// considered a Reaction or Continuation setup. Expansion requires the
// current bar to be both the largest of the recent window AND large enough
// relative to ATR in absolute terms - the ATR floor stops a merely
// "locally biggest" bar during a quiet lull from qualifying as genuine
// expansion.

float previousMaximumRange = 0.0

for i = 1 to M
    previousMaximumRange := math.max(previousMaximumRange, high[i] - low[i])

bool newExpansion =
     barRange >= previousMaximumRange and
     barRange >= atrValue * expansionAtrFloor

bool longReactionGate =
     displacement < -displacementThreshold and
     meanDirectionalEfficiencyLong >= directionalEfficiencyThreshold and
     directionalDominanceLong >= 0.40 and
     lowerWickRatio > upperWickRatio and
     lowerWick > upperWick and
     speedRatio >= speedThreshold and
     volumeRatio >= volumeThresholdSensitivity and
     depthBelowFair >= depthThreshold and
     normalBar

bool shortReactionGate =
     displacement > displacementThreshold and
     meanDirectionalEfficiencyShort >= directionalEfficiencyThreshold and
     directionalDominanceShort >= 0.40 and
     upperWickRatio > lowerWickRatio and
     upperWick > lowerWick and
     speedRatio >= speedThreshold and
     volumeRatio >= volumeThresholdSensitivity and
     depthAboveFair >= depthThreshold and
     normalBar

bool longContinuationGate =
     (aboveFair or acceptingAbove) and
     newExpansion and
     upperWickRatio < continuationWickThreshold and
     efficiency > 0.5 and
     speedRatio >= speedThreshold and
     volumeRatio >= volumeThresholdSensitivity and
     trendAlignedLong and
     normalBar

bool shortContinuationGate =
     (belowFair or acceptingBelow) and
     newExpansion and
     lowerWickRatio < continuationWickThreshold and
     efficiency > 0.5 and
     speedRatio >= speedThreshold and
     volumeRatio >= volumeThresholdSensitivity and
     trendAlignedShort and
     normalBar

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 11 - TRADE STATE + ADAPTIVE FAILURE MEMORY
// ═════════════════════════════════════════════════════════════════════════════
// The active setup stores the entry reference, projected path levels,
// invalidation boundary, drawing objects and lifecycle state used by the
// indicator. Only one setup is ever active at a time; completed setups are
// retained separately in a bounded history array purely for chart display
// when history is enabled.

type Trade
    int sigBar
    int closeBar
    bool isLong
    string signalType
    float entry
    float targetOne
    float targetTwo
    float invalidation
    bool active
    int extensionCount
    line entryLine
    line targetOneLine
    line targetTwoLine
    line invalidationLine
    label signalLabel
    line pathUpperOne
    line pathUpperTwo
    line pathUpperThree
    line pathLowerOne
    line pathLowerTwo
    line pathLowerThree
    line pathCenterOne
    line pathCenterTwo
    line pathCenterThree
    linefill pathFillOne
    linefill pathFillTwo
    linefill pathFillThree

var bool rearmReady = true
var bool rearmPending = false
var bool tradeClosedThisBar = false

var Trade activeTrade = na
var Trade[] historicalTrades = array.new<Trade>()
var bool signalEventLocked = false
var int signalEventDirection = 0
var int signalEventFamily = 0
var label liveTargetOneLabel = na
var label liveTargetTwoLabel = na
var label liveEntryLabel = na
var label liveInvalidationLabel = na

// Adaptive failure memory. failedSignalFamily records whether the failure
// was a Reaction (1) or a Continuation (2), so the similarity block can be
// applied specifically to a repeat from the failed signal family.
var bool failureMemoryActive = false
var int failureMemoryBar = na
var int lastFailureBar = na
var int failureCount = 0
var bool failedDirectionLong = false
var int failedSignalFamily = 0

var float failedDisplacement = na
var float failedMigration = na
var float failedEfficiency = na
var float failedSpeedRatio = na
var float failedDepth = na
var float failedVolumeRatio = na
var float failedPressure = na
var float failedRangeRatio = na

var int FAILURE_MEMORY_LIMIT = 30
var int FAILURE_MAX_COUNT = 3
var int MAX_TARGET_EXTENSIONS = 3

// Generic feature-similarity scorer: returns 1.0 when the two values are
// identical and decays linearly to 0.0 as their gap approaches the given
// tolerance. Used by the Failure Memory similarity check below.
featureSimilarity(float currentValue, float referenceValue, float tolerance) =>
    float similarity = 0.0
    if not na(referenceValue)
        similarity := 1.0 - clamp(math.abs(currentValue - referenceValue) / tolerance, 0.0, 1.0)
    similarity

// Compares the current market conditions with the features recorded at the
// last failed setup. The resulting similarity score is later applied only
// to the failed direction and signal family; losing-streak tightening is
// handled separately and applies globally.
currentFailureSimilarity(bool isLong) =>
    float currentEfficiency = isLong ? meanDirectionalEfficiencyLong : meanDirectionalEfficiencyShort
    float currentDepth = isLong ? depthBelowFair : depthAboveFair
    float similarityDisplacement = featureSimilarity(math.abs(displacement), failedDisplacement, 0.80)
    float similarityMigration = featureSimilarity(migration, failedMigration, 0.12)
    float similarityEfficiency = featureSimilarity(currentEfficiency, failedEfficiency, 0.25)
    float similaritySpeed = featureSimilarity(speedRatio, failedSpeedRatio, 0.80)
    float similarityDepth = featureSimilarity(currentDepth, failedDepth, 1.00)
    float similarityVolume = featureSimilarity(volumeRatio, failedVolumeRatio, 0.75)
    float similarityPressure = featureSimilarity(pressureNow, failedPressure, 0.20)
    float currentRangeRatio = safeDiv(barRange, atrValue, 1.0)
    float similarityRange = featureSimilarity(currentRangeRatio, failedRangeRatio, 0.80)
    float similarityTotal = similarityDisplacement + similarityMigration + similarityEfficiency + similaritySpeed + similarityDepth + similarityVolume + similarityPressure + similarityRange
    similarityTotal / 8.0

failureMemoryExpired() =>
    bool expired = false
    if failureMemoryActive and not na(failureMemoryBar)
        expired := bar_index - failureMemoryBar > FAILURE_MEMORY_LIMIT
    expired

// Answers whether the market has moved on from the conditions that
// produced the last invalidation. This clears the direction/similarity
// block quickly (by design - a market that has genuinely moved should not
// stay permanently banned in one direction). It does not, on its own,
// reset the failureCount escalation - that count only clears on a target
// event or on its own separate time-based expiry, so consecutive
// invalidations still compound.
failureBehaviourReset() =>
    bool resetDetected = false

    if failureMemoryActive
        bool displacementReset = math.abs(displacement) < 0.35
        bool pressureReset = math.abs(migration) < 0.025
        bool directionReset = false

        if failedDirectionLong and migration < -0.025
            directionReset := true

        if not failedDirectionLong and migration > 0.025
            directionReset := true

        float currentRangeRatio = safeDiv(barRange, atrValue, 1.0)
        bool rangeExpansionReset = false

        if not na(failedRangeRatio)
            rangeExpansionReset := currentRangeRatio > failedRangeRatio * 1.25

        resetDetected := displacementReset or pressureReset or directionReset or rangeExpansionReset

    resetDetected

// A locked signal event (one specific direction + family combination) is
// only released once the market behaviour behind it has genuinely changed
// - not merely because the qualifying gate flickered off for a bar.
signalBehaviourReset(int direction, int family) =>

    bool resetDetected = false

    if family == 1
        // Reaction event: needs price to actually recover through the
        // reaction zone, or pressure to genuinely reverse - a small pullback
        // alone should not re-arm the same reaction direction.
        if direction == 1
            resetDetected := displacement > 0.15 and migration <= 0.0
        else
            resetDetected := displacement < -0.15 and migration >= 0.0

    else
        // Continuation event: stays "the same event" while price remains
        // accepted beyond fair value and pressure keeps supporting it. Both
        // acceptance and pressure must break before the next continuation
        // in that direction is permitted.
        if direction == 1
            bool acceptanceBroken = not aboveFair and not acceptingAbove
            bool pressureReversed = migration <= -stallThreshold
            resetDetected := acceptanceBroken and pressureReversed
        else
            bool acceptanceBroken = not belowFair and not acceptingBelow
            bool pressureReversed = migration >= stallThreshold
            resetDetected := acceptanceBroken and pressureReversed

    resetDetected

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 12 - TRADE GEOMETRY
// ═════════════════════════════════════════════════════════════════════════════

computeLevels(bool isLong, bool isReaction, float atr) =>
    float direction = isLong ? 1.0 : -1.0

    float computedTargetOne = close + direction * t1AtrInput * atr
    float computedTargetTwo = close + direction * t2AtrInput * atr

    // Reaction trades invalidate beyond the extreme of the reaction bar,
    // because that extreme marks the level that, if broken, means the
    // rejection failed. Continuation trades invalidate at fair price,
    // because losing acceptance beyond fair value means the continuation
    // thesis itself has failed.
    float computedInvalidation =
         isReaction
             ? (isLong ? low - invalidationAtrInput * atr : high + invalidationAtrInput * atr)
             : fairPrice

    [computedTargetOne, computedTargetTwo, computedInvalidation]

tradeColor(Trade trade) =>
    trade.signalType == "LONG_REACTION" ? COLOR_UP_REACTION :
     trade.signalType == "SHORT_REACTION" ? COLOR_DOWN_REACTION :
     trade.signalType == "LONG_CONT" ? COLOR_UP_TRAVEL :
     COLOR_DOWN_TRAVEL

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 13 - PROJECTED PATH GEOMETRY
// ═════════════════════════════════════════════════════════════════════════════
// The projected path is a corridor from entry to Path Level 2, curved by
// current pressure and displacement rather than drawn as a straight line.
// Its width (the "corridor") widens when the market state is more
// uncertain (exhaustion, reversal) and narrows when conditions are calmer.
// This is a visual route built from the confirmed setup and current
// market state. It is not a forecast, guarantee, or future-data
// calculation.

createPath(Trade trade) =>

    float direction = trade.isLong ? 1.0 : -1.0
    float totalTravel = math.abs(trade.targetTwo - trade.entry)

    float pressureDrive = clamp(math.abs(migration) * 7.0, 0.0, 1.0)
    float directionalDrive = clamp(math.abs(displacement) * 0.12, 0.0, 0.50)

    float stateDrive =
         continuationLong or continuationShort
             ? 0.35
             : building
                 ? 0.22
                 : reversing
                     ? -0.18
                     : 0.0

    float routeDrive = clamp(pressureDrive + directionalDrive + stateDrive, -0.25, 1.0)
    float routeCurve = direction * totalTravel * 0.18 * routeDrive

    float pointOne = trade.entry + direction * totalTravel * 0.30 + routeCurve * 0.45
    float pointTwo = trade.entry + direction * totalTravel * 0.65 + routeCurve

    float uncertainty =
         exhaustion or reversing
             ? 0.34
             : building
                 ? 0.27
                 : pressureUp or pressureDown
                     ? 0.20
                     : 0.24

    float corridor = math.max(atrValue * uncertainty, syminfo.mintick * 12.0)

    float upperEntry = trade.entry + corridor
    float upperOne = pointOne + corridor * 0.82
    float upperTwo = pointTwo + corridor * 0.64
    float upperThree = trade.targetTwo + corridor * 0.38

    float lowerEntry = trade.entry - corridor
    float lowerOne = pointOne - corridor * 0.82
    float lowerTwo = pointTwo - corridor * 0.64
    float lowerThree = trade.targetTwo - corridor * 0.38

    int x0 = trade.sigBar
    int x1 = trade.sigBar + 4
    int x2 = trade.sigBar + 9
    int x3 = trade.sigBar + 16

    color pathColor = tradeColor(trade)

    trade.pathUpperOne := line.new(x0, upperEntry, x1, upperOne, color = color.new(pathColor, 78), width = 1, force_overlay = true)
    trade.pathUpperTwo := line.new(x1, upperOne, x2, upperTwo, color = color.new(pathColor, 78), width = 1, force_overlay = true)
    trade.pathUpperThree := line.new(x2, upperTwo, x3, upperThree, color = color.new(pathColor, 82), width = 1, force_overlay = true)

    trade.pathLowerOne := line.new(x0, lowerEntry, x1, lowerOne, color = color.new(pathColor, 78), width = 1, force_overlay = true)
    trade.pathLowerTwo := line.new(x1, lowerOne, x2, lowerTwo, color = color.new(pathColor, 78), width = 1, force_overlay = true)
    trade.pathLowerThree := line.new(x2, lowerTwo, x3, lowerThree, color = color.new(pathColor, 82), width = 1, force_overlay = true)

    trade.pathCenterOne := line.new(x0, trade.entry, x1, pointOne, color = color.new(pathColor, 22), width = 2, force_overlay = true)
    trade.pathCenterTwo := line.new(x1, pointOne, x2, pointTwo, color = color.new(pathColor, 22), width = 2, force_overlay = true)
    trade.pathCenterThree := line.new(x2, pointTwo, x3, trade.targetTwo, color = color.new(pathColor, 16), width = 2, force_overlay = true)

    trade.pathFillOne := linefill.new(trade.pathUpperOne, trade.pathLowerOne, color.new(pathColor, 94))
    trade.pathFillTwo := linefill.new(trade.pathUpperTwo, trade.pathLowerTwo, color.new(pathColor, 94))
    trade.pathFillThree := linefill.new(trade.pathUpperThree, trade.pathLowerThree, color.new(pathColor, 96))


updatePath(Trade trade) =>

    if not na(trade.pathCenterOne)

        float direction = trade.isLong ? 1.0 : -1.0
        float totalTravel = math.abs(trade.targetTwo - trade.entry)

        float pressureDrive = clamp(math.abs(migration) * 7.0, 0.0, 1.0)
        float directionalDrive = clamp(math.abs(displacement) * 0.12, 0.0, 0.50)

        float stateDrive =
             continuationLong or continuationShort
                 ? 0.35
                 : building
                     ? 0.22
                     : reversing
                         ? -0.18
                         : 0.0

        float routeDrive = clamp(pressureDrive + directionalDrive + stateDrive, -0.25, 1.0)
        float routeCurve = direction * totalTravel * 0.18 * routeDrive

        float pointOne = trade.entry + direction * totalTravel * 0.30 + routeCurve * 0.45
        float pointTwo = trade.entry + direction * totalTravel * 0.65 + routeCurve

        float uncertainty =
             exhaustion or reversing
                 ? 0.34
                 : building
                     ? 0.27
                     : pressureUp or pressureDown
                         ? 0.20
                         : 0.24

        float corridor = math.max(atrValue * uncertainty, syminfo.mintick * 12.0)

        float upperEntry = trade.entry + corridor
        float upperOne = pointOne + corridor * 0.82
        float upperTwo = pointTwo + corridor * 0.64
        float upperThree = trade.targetTwo + corridor * 0.38

        float lowerEntry = trade.entry - corridor
        float lowerOne = pointOne - corridor * 0.82
        float lowerTwo = pointTwo - corridor * 0.64
        float lowerThree = trade.targetTwo - corridor * 0.38

        line.set_xy1(trade.pathUpperOne, trade.sigBar, upperEntry)
        line.set_xy2(trade.pathUpperOne, trade.sigBar + 4, upperOne)
        line.set_xy1(trade.pathUpperTwo, trade.sigBar + 4, upperOne)
        line.set_xy2(trade.pathUpperTwo, trade.sigBar + 9, upperTwo)
        line.set_xy1(trade.pathUpperThree, trade.sigBar + 9, upperTwo)
        line.set_xy2(trade.pathUpperThree, trade.sigBar + 16, upperThree)

        line.set_xy1(trade.pathLowerOne, trade.sigBar, lowerEntry)
        line.set_xy2(trade.pathLowerOne, trade.sigBar + 4, lowerOne)
        line.set_xy1(trade.pathLowerTwo, trade.sigBar + 4, lowerOne)
        line.set_xy2(trade.pathLowerTwo, trade.sigBar + 9, lowerTwo)
        line.set_xy1(trade.pathLowerThree, trade.sigBar + 9, lowerTwo)
        line.set_xy2(trade.pathLowerThree, trade.sigBar + 16, lowerThree)

        line.set_xy1(trade.pathCenterOne, trade.sigBar, trade.entry)
        line.set_xy2(trade.pathCenterOne, trade.sigBar + 4, pointOne)
        line.set_xy1(trade.pathCenterTwo, trade.sigBar + 4, pointOne)
        line.set_xy2(trade.pathCenterTwo, trade.sigBar + 9, pointTwo)
        line.set_xy1(trade.pathCenterThree, trade.sigBar + 9, pointTwo)
        line.set_xy2(trade.pathCenterThree, trade.sigBar + 16, trade.targetTwo)


deletePath(Trade trade) =>

    if not na(trade.pathUpperOne)
        line.delete(trade.pathUpperOne)
        line.delete(trade.pathUpperTwo)
        line.delete(trade.pathUpperThree)
        line.delete(trade.pathLowerOne)
        line.delete(trade.pathLowerTwo)
        line.delete(trade.pathLowerThree)
        line.delete(trade.pathCenterOne)
        line.delete(trade.pathCenterTwo)
        line.delete(trade.pathCenterThree)
        linefill.delete(trade.pathFillOne)
        linefill.delete(trade.pathFillTwo)
        linefill.delete(trade.pathFillThree)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 14 - TRADE DRAWING
// ═════════════════════════════════════════════════════════════════════════════

drawTrade(Trade trade) =>
    color directionColor = tradeColor(trade)

    bool primaryReaction = trade.signalType == "LONG_REACTION" or trade.signalType == "SHORT_REACTION"

    trade.entryLine := line.new(trade.sigBar, trade.entry, trade.sigBar + 1, trade.entry, color = directionColor, width = 3, style = line.style_solid, force_overlay = true)

    trade.targetOneLine := line.new(trade.sigBar, trade.targetOne, trade.sigBar + 1, trade.targetOne, color = COLOR_PATH_LEVEL_ONE, width = 2, style = line.style_solid, force_overlay = true)

    trade.targetTwoLine := line.new(trade.sigBar, trade.targetTwo, trade.sigBar + 1, trade.targetTwo, color = COLOR_PATH_LEVEL_TWO, width = 2, style = line.style_solid, force_overlay = true)

    trade.invalidationLine := line.new(trade.sigBar, trade.invalidation, trade.sigBar + 1, trade.invalidation, color = COLOR_INVALIDATION, width = 3, style = line.style_solid, force_overlay = true)

    string markerText =
     trade.signalType == "LONG_REACTION" ? "REACTION LONG" :
     trade.signalType == "SHORT_REACTION" ? "REACTION SHORT" :
     trade.signalType == "LONG_CONT" ? "CONTINUATION LONG" :
     "CONTINUATION SHORT"

    float markerPrice =
         trade.isLong
             ? trade.invalidation - fairHalf * 0.35
             : trade.invalidation + fairHalf * 0.35

    trade.signalLabel := label.new(
         trade.sigBar,
         markerPrice,
         markerText,
         color = primaryReaction ? directionColor : color.new(directionColor, 28),
         textcolor = COLOR_WHITE,
         style = trade.isLong ? label.style_label_up : label.style_label_down,
         size = primaryReaction ? size.small : size.tiny,
         force_overlay = true
         )

    if showPathInput
        createPath(trade)

    // Fires once when a new trade is created. This uses the same message
    // builder as the target and invalidation alerts defined later, so all
    // three read consistently and a single "Any alert() function call"
    // TradingView alert will catch every event type this script produces.
    alert(buildAlertMessage("NEW SIGNAL", trade.signalType, trade.entry), alert.freq_once_per_bar_close)


// ═════════════════════════════════════════════════════════════════════════════
// SECTION 15 - TRADE LIFECYCLE
// ═════════════════════════════════════════════════════════════════════════════
// Freezing a trade stops its lines from extending further right but keeps
// them visible at their final shape. Deleting visuals removes them
// entirely - used only when the user has chosen not to keep history.

freezeTrade(Trade trade, int closingBar) =>
    trade.closeBar := closingBar
    trade.active := false

    line.set_x2(trade.entryLine, closingBar)
    line.set_x2(trade.targetOneLine, closingBar)
    line.set_x2(trade.targetTwoLine, closingBar)
    line.set_x2(trade.invalidationLine, closingBar)

deleteTradeVisuals(Trade trade) =>
    if not na(trade.entryLine)
        line.delete(trade.entryLine)

    if not na(trade.targetOneLine)
        line.delete(trade.targetOneLine)

    if not na(trade.targetTwoLine)
        line.delete(trade.targetTwoLine)

    if not na(trade.invalidationLine)
        line.delete(trade.invalidationLine)

    if not na(trade.signalLabel)
        label.delete(trade.signalLabel)

    deletePath(trade)

// Keeps the historical trade list bounded to the user's chosen maximum,
// deleting the oldest trade's drawing objects as it falls out of the
// window. This keeps the retained trade objects bounded by the configured
// history limit, well under TradingView's line and label limits.
pruneHistory() =>
    while array.size(historicalTrades) > maxHistoryInput
        Trade oldTrade = array.shift(historicalTrades)

        if not na(oldTrade.entryLine)
            line.delete(oldTrade.entryLine)

        if not na(oldTrade.targetOneLine)
            line.delete(oldTrade.targetOneLine)

        if not na(oldTrade.targetTwoLine)
            line.delete(oldTrade.targetTwoLine)

        if not na(oldTrade.invalidationLine)
            line.delete(oldTrade.invalidationLine)

        if not na(oldTrade.signalLabel)
            label.delete(oldTrade.signalLabel)

        deletePath(oldTrade)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 16 - MAIN ENGINE
// ═════════════════════════════════════════════════════════════════════════════
// Signal creation, trade closure, target/invalidation evaluation and
// failure-memory updates occur only on confirmed bars. No trade is
// opened, closed, or modified on an unfinished candle, and the script
// does not use future data or backshift signals.

if barstate.isconfirmed and engineReady

    tradeClosedThisBar := false

    // ─────────────────────────────────────────────────────────────────────────
    // FAILURE MEMORY
    // ─────────────────────────────────────────────────────────────────────────
    // Two independent clocks run here. failureMemoryActive (the direction/
    // similarity block) clears quickly once behaviour resets - a market
    // that has genuinely moved on should not stay banned. failureCount (the
    // difficulty escalation) only clears on a target event or its own
    // separate time-based expiry, so a string of consecutive invalidations
    // still compounds even while the direction block itself keeps
    // resetting.

    bool memoryExpired = failureMemoryExpired()
    bool behaviourReset = failureBehaviourReset()

    if failureMemoryActive and (memoryExpired or behaviourReset)

        failureMemoryActive := false
        failureMemoryBar := na

        failedDisplacement := na
        failedMigration := na
        failedEfficiency := na
        failedSpeedRatio := na
        failedDepth := na
        failedVolumeRatio := na
        failedPressure := na
        failedRangeRatio := na

        failedSignalFamily := 0

    if failureCount > 0 and not na(lastFailureBar) and (bar_index - lastFailureBar > FAILURE_MEMORY_LIMIT)
        failureCount := 0
        lastFailureBar := na

    // ─────────────────────────────────────────────────────────────────────────
    // SIGNAL EVENT LOCK RESET
    // A signal is not unlocked merely because its gate flickers off for a
    // bar. The underlying market behaviour must actually reset first.
    // ─────────────────────────────────────────────────────────────────────────

    if signalEventLocked

        bool signalReset = signalBehaviourReset(signalEventDirection, signalEventFamily)

        if signalReset
            signalEventLocked := false
            signalEventDirection := 0
            signalEventFamily := 0

    // ─────────────────────────────────────────────────────────────────────────
    // REARM
    // ─────────────────────────────────────────────────────────────────────────

    if rearmPending and behaviourReset
        rearmReady := true
        rearmPending := false

    // ─────────────────────────────────────────────────────────────────────────
    // ACTIVE TRADE
    // ─────────────────────────────────────────────────────────────────────────

    if not na(activeTrade) and activeTrade.active

        bool longTrade = activeTrade.isLong

        bool invalidationHit = false
        bool targetTwoHit = false

        // Hit detection uses the actual high/low of the bar, not just the
        // close. A level that price genuinely touched intrabar counts as
        // touched, consistent with how the entry, target and invalidation
        // lines are presented visually as real price levels.
        if longTrade
            invalidationHit := low <= activeTrade.invalidation
            targetTwoHit := high >= activeTrade.targetTwo
        else
            invalidationHit := high >= activeTrade.invalidation
            targetTwoHit := low <= activeTrade.targetTwo

        if invalidationHit or targetTwoHit

            // If both levels are touched on the same bar, invalidation wins.
            // This is the conservative, deterministic rule for resolving
            // same-bar ambiguity.
            bool tradeSucceeded = targetTwoHit and not invalidationHit

            freezeTrade(activeTrade, bar_index)
            deletePath(activeTrade)

            if showHistoryInput
                array.push(historicalTrades, activeTrade)
                pruneHistory()
            else
                deleteTradeVisuals(activeTrade)

            // ─────────────────────────────────────────────────────────────
            // TARGET REACHED
            // ─────────────────────────────────────────────────────────────

            if tradeSucceeded

                failureMemoryActive := false
                failureMemoryBar := na
                failureCount := 0
                lastFailureBar := na

                failedDisplacement := na
                failedMigration := na
                failedEfficiency := na
                failedSpeedRatio := na
                failedDepth := na
                failedVolumeRatio := na
                failedPressure := na
                failedRangeRatio := na

                failedSignalFamily := 0

                rearmReady := true
                rearmPending := false

                alert(buildAlertMessage("TARGET REACHED", activeTrade.signalType, activeTrade.targetTwo), alert.freq_once_per_bar_close)

            // ─────────────────────────────────────────────────────────────
            // INVALIDATION
            // ─────────────────────────────────────────────────────────────

            else

                failureMemoryActive := true
                failureMemoryBar := bar_index
                lastFailureBar := bar_index

                failureCount := math.min(failureCount + 1, FAILURE_MAX_COUNT)

                failedDirectionLong := activeTrade.isLong

                if activeTrade.signalType == "LONG_REACTION" or activeTrade.signalType == "SHORT_REACTION"
                    failedSignalFamily := 1
                else
                    failedSignalFamily := 2

                failedDisplacement := math.abs(displacement)
                failedMigration := migration

                if activeTrade.isLong
                    failedEfficiency := meanDirectionalEfficiencyLong
                    failedDepth := depthBelowFair
                else
                    failedEfficiency := meanDirectionalEfficiencyShort
                    failedDepth := depthAboveFair

                failedSpeedRatio := speedRatio
                failedVolumeRatio := volumeRatio
                failedPressure := pressureNow
                failedRangeRatio := safeDiv(barRange, atrValue, 1.0)

                rearmReady := false
                rearmPending := true

                alert(buildAlertMessage("INVALIDATED", activeTrade.signalType, activeTrade.invalidation), alert.freq_once_per_bar_close)

            activeTrade := na
            tradeClosedThisBar := true

        else

            // ─────────────────────────────────────────────────────────────
            // TARGET EXTENSION
            // A continuation signal firing while a trade of the same
            // direction is already open extends Path Level 2 further,
            // capped at MAX_TARGET_EXTENSIONS so a single trend cannot
            // stretch the target indefinitely.
            // ─────────────────────────────────────────────────────────────

            bool extensionLong = longContinuationGate and continuationLong and longTrade and continuationSignalsEnabled
            bool extensionShort = shortContinuationGate and continuationShort and not longTrade and continuationSignalsEnabled

            if (extensionLong or extensionShort) and activeTrade.extensionCount < MAX_TARGET_EXTENSIONS

                float direction = longTrade ? 1.0 : -1.0
                float newTargetTwo = activeTrade.targetTwo + direction * t1AtrInput * atrValue

                activeTrade.targetTwo := newTargetTwo
                activeTrade.extensionCount := activeTrade.extensionCount + 1

                line.set_y1(activeTrade.targetTwoLine, newTargetTwo)
                line.set_y2(activeTrade.targetTwoLine, newTargetTwo)

            // ─────────────────────────────────────────────────────────────
            // PROJECTED PATH
            // ─────────────────────────────────────────────────────────────

            if showPathInput
                updatePath(activeTrade)

    // ─────────────────────────────────────────────────────────────────────────
    // NEW SIGNAL SEARCH
    // ─────────────────────────────────────────────────────────────────────────

    if na(activeTrade) and rearmReady and not tradeClosedThisBar

        float adaptiveDisplacementThreshold = displacementThreshold
        float adaptiveEfficiencyThreshold = directionalEfficiencyThreshold
        float adaptiveSpeedThreshold = speedThreshold
        float adaptiveDepthThreshold = depthThreshold
        float adaptiveVolumeThreshold = volumeThresholdSensitivity

        // ─────────────────────────────────────────────────────────────────
        // FAILURE ESCALATION
        // Every threshold tightens together after a loss, scaled by how
        // many consecutive failures have occurred (capped at
        // FAILURE_MAX_COUNT). This applies regardless of which family
        // failed - a losing streak raises the bar for any new setup.
        // ─────────────────────────────────────────────────────────────────

        if failureCount > 0
            adaptiveDisplacementThreshold := displacementThreshold + failureCount * 0.08
            adaptiveEfficiencyThreshold := directionalEfficiencyThreshold + failureCount * 0.03
            adaptiveSpeedThreshold := speedThreshold + failureCount * 0.04
            adaptiveDepthThreshold := depthThreshold + failureCount * 0.05
            adaptiveVolumeThreshold := volumeThresholdSensitivity + failureCount * 0.05

        // ─────────────────────────────────────────────────────────────────
        // FAILURE SIMILARITY
        // Family-aware: a failed Reaction weighs most heavily against a new
        // Reaction attempt in the same direction, and a failed Continuation
        // weighs most heavily against a new Continuation attempt.
        // The other family is not similarity-blocked by the failed family, but it
        // remains affected by the global losing-streak tightening.
        // ─────────────────────────────────────────────────────────────────

        float blockThreshold = 0.74 - failureCount * 0.06

        bool longReactionMemoryBlock = false
        bool longContinuationMemoryBlock = false
        bool shortReactionMemoryBlock = false
        bool shortContinuationMemoryBlock = false

        if failureMemoryActive and failedDirectionLong
            float simLong = currentFailureSimilarity(true)
            if simLong >= blockThreshold
                if failedSignalFamily == 1
                    longReactionMemoryBlock := true
                else
                    longContinuationMemoryBlock := true

        if failureMemoryActive and not failedDirectionLong
            float simShort = currentFailureSimilarity(false)
            if simShort >= blockThreshold
                if failedSignalFamily == 1
                    shortReactionMemoryBlock := true
                else
                    shortContinuationMemoryBlock := true

        // ─────────────────────────────────────────────────────────────────
        // ADAPTIVE GATES
        // ─────────────────────────────────────────────────────────────────

        bool adaptiveLongReactionGate = longReactionGate
        bool adaptiveShortReactionGate = shortReactionGate
        bool adaptiveLongContinuationGate = longContinuationGate
        bool adaptiveShortContinuationGate = shortContinuationGate

        if math.abs(displacement) < adaptiveDisplacementThreshold
            adaptiveLongReactionGate := false
            adaptiveShortReactionGate := false

        if meanDirectionalEfficiencyLong < adaptiveEfficiencyThreshold
            adaptiveLongReactionGate := false

        if meanDirectionalEfficiencyShort < adaptiveEfficiencyThreshold
            adaptiveShortReactionGate := false

        if speedRatio < adaptiveSpeedThreshold
            adaptiveLongReactionGate := false
            adaptiveShortReactionGate := false
            adaptiveLongContinuationGate := false
            adaptiveShortContinuationGate := false

        if volumeRatio < adaptiveVolumeThreshold
            adaptiveLongReactionGate := false
            adaptiveShortReactionGate := false
            adaptiveLongContinuationGate := false
            adaptiveShortContinuationGate := false

        if depthBelowFair < adaptiveDepthThreshold
            adaptiveLongReactionGate := false

        if depthAboveFair < adaptiveDepthThreshold
            adaptiveShortReactionGate := false

        if longReactionMemoryBlock
            adaptiveLongReactionGate := false

        if longContinuationMemoryBlock
            adaptiveLongContinuationGate := false

        if shortReactionMemoryBlock
            adaptiveShortReactionGate := false

        if shortContinuationMemoryBlock
            adaptiveShortContinuationGate := false

        // ─────────────────────────────────────────────────────────────────
        // CANDIDATES
        // ─────────────────────────────────────────────────────────────────

        bool candidateLongReaction = adaptiveLongReactionGate and pressureUp and reactionSignalsEnabled
        bool candidateShortReaction = adaptiveShortReactionGate and pressureDown and reactionSignalsEnabled
        bool candidateLongContinuation = adaptiveLongContinuationGate and continuationLong and continuationSignalsEnabled
        bool candidateShortContinuation = adaptiveShortContinuationGate and continuationShort and continuationSignalsEnabled

        // ─────────────────────────────────────────────────────────────────
        // SIGNAL SELECTION
        // A locked behavioural event cannot fire again until
        // signalBehaviourReset() releases it.
        // ─────────────────────────────────────────────────────────────────

        bool longReactionBlocked = signalEventLocked and signalEventDirection == 1 and signalEventFamily == 1
        bool shortReactionBlocked = signalEventLocked and signalEventDirection == -1 and signalEventFamily == 1
        bool longContinuationBlocked = signalEventLocked and signalEventDirection == 1 and signalEventFamily == 2
        bool shortContinuationBlocked = signalEventLocked and signalEventDirection == -1 and signalEventFamily == 2

        string signalType = ""
        bool signalLong = false

        if candidateLongReaction and not longReactionBlocked
            signalType := "LONG_REACTION"
            signalLong := true

        else if candidateShortReaction and not shortReactionBlocked
            signalType := "SHORT_REACTION"
            signalLong := false

        else if candidateLongContinuation and not longContinuationBlocked
            signalType := "LONG_CONT"
            signalLong := true

        else if candidateShortContinuation and not shortContinuationBlocked
            signalType := "SHORT_CONT"
            signalLong := false

        // ─────────────────────────────────────────────────────────────────
        // CREATE TRADE
        // ─────────────────────────────────────────────────────────────────

        if signalType != ""

            bool reactionSignal = signalType == "LONG_REACTION" or signalType == "SHORT_REACTION"

            [newTargetOne, newTargetTwo, newInvalidation] = computeLevels(signalLong, reactionSignal, atrValue)

            Trade newTrade = Trade.new(
                 bar_index, na, signalLong, signalType, close,
                 newTargetOne, newTargetTwo, newInvalidation, true, 0,
                 na, na, na, na, na,
                 na, na, na, na, na, na,
                 na, na, na, na, na, na
                 )

            drawTrade(newTrade)

            // ─────────────────────────────────────────────────────────────
            // ACTIVATE TRADE
            // ─────────────────────────────────────────────────────────────

            activeTrade := newTrade
            rearmPending := false

            // ─────────────────────────────────────────────────────────────
            // LOCK THIS BEHAVIOURAL EVENT
            // ─────────────────────────────────────────────────────────────

            signalEventLocked := true
            signalEventDirection := signalLong ? 1 : -1
            signalEventFamily := reactionSignal ? 1 : 2

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 17 - LIVE TRADE LABELS
// ═════════════════════════════════════════════════════════════════════════════
// These labels sit just ahead of the current bar and are rebuilt every bar
// so they always point at the current values of an open trade. This
// visual update may occur while the realtime bar is forming; it does not
// create, close, or modify any signal.

if barstate.islast

    label.delete(liveTargetOneLabel)
    label.delete(liveTargetTwoLabel)
    label.delete(liveEntryLabel)
    label.delete(liveInvalidationLabel)

    liveTargetOneLabel := na
    liveTargetTwoLabel := na
    liveEntryLabel := na
    liveInvalidationLabel := na

    if not na(activeTrade) and activeTrade.active

        color directionColor = tradeColor(activeTrade)
        int labelBar = bar_index + 2

        line.set_x2(activeTrade.entryLine, labelBar)
        line.set_x2(activeTrade.targetOneLine, labelBar)
        line.set_x2(activeTrade.targetTwoLine, labelBar)
        line.set_x2(activeTrade.invalidationLine, labelBar)

        liveTargetTwoLabel := label.new(labelBar, activeTrade.targetTwo, "PATH LEVEL 2", color = COLOR_PATH_LEVEL_TWO, textcolor = COLOR_WHITE, style = label.style_label_left, size = size.small, force_overlay = true)

        liveTargetOneLabel := label.new(labelBar, activeTrade.targetOne, "PATH LEVEL 1", color = COLOR_PATH_LEVEL_ONE, textcolor = COLOR_WHITE, style = label.style_label_left, size = size.small, force_overlay = true)

        liveEntryLabel := label.new(labelBar, activeTrade.entry, "ENTRY", color = directionColor, textcolor = COLOR_WHITE, style = label.style_label_left, size = size.small, force_overlay = true)

        liveInvalidationLabel := label.new(labelBar, activeTrade.invalidation, "INVALIDATION", color = COLOR_INVALIDATION, textcolor = COLOR_WHITE, style = label.style_label_left, size = size.small, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 18 - VISUAL STATE ENGINE
// ═════════════════════════════════════════════════════════════════════════════

string marketState =
     exhaustion ? "EXHAUSTION" :
     reversing ? "SHIFT" :
     building ? "BUILDING" :
     continuationLong and aboveFair ? "TRAVEL" :
     continuationShort and belowFair ? "TRAVEL" :
     migratingUp ? "MOVING UP" :
     migratingDown ? "MOVING DOWN" :
     "NEUTRAL"

string pathState =
     pressureUp ? "UP OPEN" :
     pressureDown ? "DOWN OPEN" :
     "WAIT"

string locationState =
     aboveFair ? "ABOVE FAIR" :
     belowFair ? "BELOW FAIR" :
     "AT FAIR"

color currentStateColor = stateColor(marketState)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 19 - REACTION BAND
// ═════════════════════════════════════════════════════════════════════════════
// Drawn on the main price chart via force_overlay even though the script
// itself is a pane script. This is the fair-value band described in
// Section 06, visualised as three nested zones whose color intensity
// reflects current pressure.

color bandAccent =
     exhaustion ? COLOR_EXHAUSTION :
     reversing ? COLOR_SHIFT :
     pressureUp ? COLOR_UP_REACTION :
     pressureDown ? COLOR_DOWN_REACTION :
     COLOR_NEUTRAL

float bandInnerHalf = fairHalf * 0.58
float bandInnerUpper = fairPrice + bandInnerHalf
float bandInnerLower = fairPrice - bandInnerHalf

float bandPressure = clamp(math.abs(migration) * 8.0, 0.0, 1.0)

int outerTransparency = 92 - int(bandPressure * 10.0)
int innerTransparency = 86 - int(bandPressure * 14.0)

plotBandCore = plot(showFairBandInput and chart.is_standard ? fairPrice : na, "Reaction Core", color.new(bandAccent, 8), 2, force_overlay = true, display = display.all - display.price_scale)

plotBandInnerUpper = plot(showFairBandInput and chart.is_standard ? bandInnerUpper : na, "Reaction Inner Upper", color.new(bandAccent, 48), 1, force_overlay = true, display = display.all - display.price_scale)

plotBandInnerLower = plot(showFairBandInput and chart.is_standard ? bandInnerLower : na, "Reaction Inner Lower", color.new(bandAccent, 48), 1, force_overlay = true, display = display.all - display.price_scale)

plotBandOuterUpper = plot(showFairBandInput and chart.is_standard ? fairUpper : na, "Reaction Outer Upper", color.new(bandAccent, 72), 1, force_overlay = true, display = display.all - display.price_scale)

plotBandOuterLower = plot(showFairBandInput and chart.is_standard ? fairLower : na, "Reaction Outer Lower", color.new(bandAccent, 72), 1, force_overlay = true, display = display.all - display.price_scale)

fill(plotBandOuterUpper, plotBandInnerUpper, color.new(bandAccent, outerTransparency))
fill(plotBandInnerUpper, plotBandInnerLower, color.new(bandAccent, innerTransparency))
fill(plotBandInnerLower, plotBandOuterLower, color.new(bandAccent, outerTransparency))

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 20 - REACTION FIELD
// ═════════════════════════════════════════════════════════════════════════════
// This is the script's own pane (overlay = false means this is where the
// script lives by default). It visualises migration as a behavioural
// field - how strongly and in which direction control is shifting - not
// as a conventional overbought/oversold or buy/sell oscillator.

float rawField = migration * MIGRATION_SCALE
float fieldCore = clamp(rawField, -5.5, 5.5)

float fieldEnergy = clamp(math.abs(fieldCore) * 0.75 + math.max(speedRatio - 1.0, 0.0) * 0.55, 0.15, 2.5)
float fieldHalfWidth = clamp(0.32 + fieldEnergy * 0.28, 0.32, 1.45)

float fieldUpper = clamp(fieldCore + fieldHalfWidth, -6.0, 6.0)
float fieldLower = clamp(fieldCore - fieldHalfWidth, -6.0, 6.0)

color reactionFieldColor =
     exhaustion ? COLOR_EXHAUSTION :
     reversing ? COLOR_SHIFT :
     fieldCore > 0.0 ? COLOR_UP_REACTION :
     fieldCore < 0.0 ? COLOR_DOWN_REACTION :
     COLOR_NEUTRAL

plotFieldUpper = plot(chart.is_standard ? fieldUpper : na, "Reaction Field Upper", color.new(reactionFieldColor, 100), 1, display = display.pane)
plotFieldLower = plot(chart.is_standard ? fieldLower : na, "Reaction Field Lower", color.new(reactionFieldColor, 100), 1, display = display.pane)

fill(plotFieldUpper, plotFieldLower, color.new(reactionFieldColor, 89))

plot(chart.is_standard ? fieldCore : na, "Reaction Spine", color.new(reactionFieldColor, 0), linewidth = 2)
plot(chart.is_standard ? fieldCore * 0.48 : na, "Reaction Flow", color.new(reactionFieldColor, 72), linewidth = 1, display = display.pane)

plot(chart.is_standard ? 0.0 : na, "Reaction Centre", color.new(COLOR_NEUTRAL, 68), style = plot.style_line, display = display.pane)

bool transitionPulse = (reversing or exhaustion) and chart.is_standard

plotshape(transitionPulse ? fieldCore : na, title = "Reaction Transition", style = shape.circle, location = location.absolute, color = color.new(reactionFieldColor, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════
// SECTION 21 - CHART DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════

var table dashboard = table.new(
     dashboardPosition(dashboardPositionInput),
     2, 5,
     bgcolor = COLOR_PANEL,
     frame_color = COLOR_PANEL_BORDER,
     frame_width = 1,
     border_color = COLOR_PANEL_BORDER,
     border_width = 1,
     force_overlay = true
     )

if barstate.islast

    if showDashboardInput and chart.is_standard

        bool tradeActive = not na(activeTrade) and activeTrade.active

        string tradeStateText =
             tradeActive
                 ? activeTrade.signalType == "LONG_REACTION" ? "REACTION LONG" :
                   activeTrade.signalType == "SHORT_REACTION" ? "REACTION SHORT" :
                   activeTrade.signalType == "LONG_CONT" ? "CONTINUATION LONG" :
                   "CONTINUATION SHORT"
                 : "WAITING"

        color tradeStateColor = tradeActive ? tradeColor(activeTrade) : COLOR_NEUTRAL

        string levelText =
             tradeActive
                 ? "ENTRY  " + str.tostring(activeTrade.entry, format.mintick) +
                   "\nPATH LEVEL 1  " + str.tostring(activeTrade.targetOne, format.mintick) +
                   "\nPATH LEVEL 2  " + str.tostring(activeTrade.targetTwo, format.mintick) +
                   "\nINVALIDATION  " + str.tostring(activeTrade.invalidation, format.mintick)
                 : "No active setup"

        table.cell(dashboard, 0, 0, "REACTION PATH", bgcolor = COLOR_PANEL, text_color = COLOR_WHITE, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_left)

        table.cell(dashboard, 1, 0, syminfo.prefix + ":" + syminfo.ticker + " | " + timeframe.period, bgcolor = COLOR_PANEL, text_color = COLOR_NEUTRAL, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_right)

        table.cell(dashboard, 0, 1, "STATE", bgcolor = COLOR_PANEL, text_color = COLOR_NEUTRAL, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_left)

        table.cell(dashboard, 1, 1, marketState, bgcolor = COLOR_PANEL, text_color = currentStateColor, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_right)

        table.cell(dashboard, 0, 2, "PATH", bgcolor = COLOR_PANEL, text_color = COLOR_NEUTRAL, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_left)

        table.cell(dashboard, 1, 2, pathState, bgcolor = COLOR_PANEL, text_color = reactionFieldColor, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_right)

        table.cell(dashboard, 0, 3, "LOCATION", bgcolor = COLOR_PANEL, text_color = COLOR_NEUTRAL, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_left)

        table.cell(dashboard, 1, 3, locationState, bgcolor = COLOR_PANEL, text_color = COLOR_WHITE, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_right)

        table.cell(dashboard, 0, 4, tradeActive ? "TRADE" : "STATUS", bgcolor = COLOR_PANEL, text_color = COLOR_NEUTRAL, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_left)

        table.cell(dashboard, 1, 4, tradeActive ? tradeStateText + "\n" + levelText : "WAITING\nNo active setup", bgcolor = COLOR_PANEL, text_color = tradeStateColor, text_size = dashboardTextSize(dashboardSizeInput), text_halign = text.align_right)

    else
        table.clear(dashboard, 0, 0, 1, 4)
````
