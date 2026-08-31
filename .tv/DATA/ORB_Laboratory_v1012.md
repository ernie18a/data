<!-- tradingview-pine-id: PUB;787fa9ea7c75421e8bd373ae8e3b04ae -->
<!-- tradingviewscripts-format: 1 -->
# ORB Laboratory v1.0.12

Source: https://www.tradingview.com/script/kYJLrfun-ORB-Laboratory-v1-0-12/

## Description

ORB LABORATORY v1.0.12
Opening Range Breakout Research & Backtesting Framework

ORB Laboratory is a modular Opening Range Breakout strategy designed for systematic research, backtesting, robustness testing, and experimentation across different markets, sessions, symbols, timeframes, execution assumptions, and ORB methodologies.

This is not a single hard-coded ORB strategy.

The purpose of ORB Laboratory is to provide a flexible environment where traders and researchers can isolate individual variables, compare different approaches to opening-range behavior, and test whether an idea remains viable under different conditions rather than relying on one fixed set of rules.

The script includes multiple ORB sessions, seven entry models, configurable breakout buffers, several confirmation methods, market-condition filters, multiple stop-loss and profit-target models, position sizing, trade-frequency controls, execution modeling, breakeven and trailing-stop management, forced exits, and visual/debugging tools.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. MULTI-SESSION ORB ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory supports up to three independent Opening Range windows:

• ORB 1
• ORB 2
• ORB 3

Each ORB can be configured independently with:

• Enable / Disable
• Custom session name
• Starting hour
• Starting minute
• ORB duration in minutes
• Long trades enabled / disabled
• Short trades enabled / disabled

This makes it possible to research multiple market opens or intraday expansion periods within the same strategy.

Examples could include:

• New York open
• London open
• Secondary morning range
• Later-session expansion
• Crypto-specific session windows
• Custom event-based time windows

ORB lengths can range from very short opening ranges to much longer windows.

The strategy continuously tracks the highest high and lowest low while an ORB is forming.

When the ORB finishes, the final:

• ORB High
• ORB Low
• ORB Midpoint

are stored and projected forward on the chart.

The ORB is finalized on the close of the final range-building bar so resting breakout orders can be prepared before the first post-range bar begins.

The implementation also supports one-bar ORBs correctly.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. STRATEGY TIME ZONE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The entire strategy uses a configurable strategy time zone.

This allows ORB sessions, entry cutoffs, forced closes, weekdays, and other time-sensitive logic to remain anchored to the desired market time regardless of the exchange or chart time zone.

Default:

America/New_York

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. DIRECTION CONTROL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Global direction can be set to:

• Both
• Long Only
• Short Only

Each individual ORB also has independent Long and Short permissions.

This means direction can be controlled both globally and per session.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. ENTRY ALLOWANCE / TRADE FREQUENCY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory includes several trade-frequency modes:

ONE TOTAL
Only one entry may be taken from an ORB.

ONCE PER DIRECTION
Allows one long and one short opportunity per ORB.

MAXIMUM NUMBER
Allows a configurable maximum number of entries per ORB.

UNLIMITED
Removes the per-ORB entry restriction while remaining subject to other global limits.

Additional controls include:

• Maximum entries per ORB
• Maximum entries per day
• Stop trading after first winning trade
• Stop trading after first losing trade
• Maximum planned daily risk

These tools make it possible to research whether an ORB performs better as a single-shot setup, one trade per direction, or as a multi-entry strategy.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5. ENTRY MODEL — BREAKOUT (TOUCH)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Breakout (Touch) is designed to model a traditional stop-order breakout.

After the ORB is complete, resting stop entries are prepared at:

Long:
ORB High + Long Breakout Buffer

Short:
ORB Low - Short Breakout Buffer

The entry can therefore occur when price touches the breakout threshold rather than waiting for a candle close.

The strategy uses resting stop orders for this mode.

Long and short breakout orders are placed into an OCA cancellation group.

When one side fills, competing unfilled breakout orders are cancelled.

This allows the strategy to model a two-sided opening-range breakout where both directions may initially be armed but only the triggered side remains active.

Unfilled Breakout (Touch) orders are also cancelled when the configured entry cutoff is reached.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
6. ENTRY MODEL — BREAKOUT (CLOSE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Breakout (Close) requires confirmation from the candle close.

Long:
Candle closes above the ORB High + Long Breakout Buffer.

Short:
Candle closes below the ORB Low - Short Breakout Buffer.

This model is useful for comparing immediate touch-based breakout execution against the additional confirmation of a completed candle outside the range.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
7. ENTRY MODEL — BREAK + RETEST ORB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This model waits for a confirmed breakout and then looks for price to retest the broken ORB boundary.

After a breakout, the retest can be confirmed using one of three methods:

TOUCH ONLY
Price only needs to return to the broken ORB boundary.

CLOSE OUTSIDE
Price must retest the boundary and close back on the breakout side.

REJECTION CANDLE
Price must retest the boundary and produce directional rejection.

For a bullish retest, the candle must interact with the ORB High and confirm back above it.

For a bearish retest, the candle must interact with the ORB Low and confirm back below it.

Additional controls include:

• Retest expiry in bars
• Maximum extension before a retest is considered too late

Once a valid retest is consumed, the retest setup is disarmed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
8. ENTRY MODEL — BREAK + RETEST FVG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory includes directional Fair Value Gap detection following an ORB breakout.

A bullish FVG is detected when a three-candle imbalance exists with the current low above the high from two bars earlier.

A bearish FVG is detected when the current high is below the low from two bars earlier.

The minimum FVG size can be defined as an ATR multiple.

Optional logic can require the FVG to remain outside the ORB.

Three FVG entry depths are available:

NEAR EDGE
Uses the first edge of the FVG encountered on the retracement.

MIDPOINT
Uses the 50% level of the FVG.

FULL FILL
Requires price to reach the opposite edge of the FVG.

Additional controls include:

• Minimum FVG size as ATR ×
• FVG must remain outside ORB
• FVG expiry in bars

If price reaches the selected FVG level while the setup is valid, an entry is submitted in the direction of the original breakout.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
9. ENTRY MODEL — SWEEP REVERSAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sweep Reversal is designed to research failed breaks of the opening range.

A high sweep occurs when price trades above:

ORB High + Long Breakout Buffer

but then closes back below the ORB High.

A low sweep occurs when price trades below:

ORB Low - Short Breakout Buffer

but then closes back above the ORB Low.

Two confirmation modes are available:

CLOSE BACK INSIDE
The breakout only needs to fail and close back inside the ORB.

REJECTION CANDLE
The failed breakout must also produce a directional rejection candle.

A failed high produces a potential short setup.

A failed low produces a potential long setup.

Sweep trades are treated as fade/reversal trades and can use dedicated fade-target logic.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
10. ENTRY MODEL — FADE FIRST BREAKOUT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This model records which side of the ORB breaks first.

The strategy permanently tracks:

• First breakout direction
• First breakout bar
• Maximum extension reached by that breakout

If the first breakout subsequently fails and closes back inside the ORB within the configured failure window, the strategy can fade that failed move.

First high breakout fails:
Potential short.

First low breakout fails:
Potential long.

The model also includes a Maximum Extension Before Retest/Fade setting.

This prevents an extremely extended move from later being treated as a normal failed breakout simply because price eventually returns to the range.

A configurable First-Break Failure Timeout controls how many bars the setup remains eligible.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
11. ENTRY MODEL — FIRST-BREAK DECISION TREE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The First-Break Decision Tree is a hybrid model that evaluates what happens after the first ORB break.

Instead of automatically assuming that the first breakout should either be followed or faded, the script waits to determine whether the move confirms continuation or fails.

The first breakout direction and extreme are recorded.

Continuation can then be defined as:

TOUCH
Price reaches the breakout threshold.

CLOSE OUTSIDE
Price closes outside the ORB in the breakout direction.

RETEST HOLDS
Price retests the broken boundary and closes back on the breakout side.

If continuation confirms, the strategy trades in the direction of the original breakout.

If the first breakout instead fails and closes back inside the ORB during the allowed failure window, the strategy can reverse and trade against the failed breakout.

This allows a single model to test both:

• Breakout continuation
• Failed-break reversal

using the first interaction with the opening range as the decision point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
12. BREAKOUT BUFFER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Long and short breakout buffers are independently configurable.

Buffers can be expressed using:

TICKS
Buffer is based on the symbol's minimum tick size.

ORB %
Buffer is calculated as a percentage of the completed ORB range.

ATR
Buffer is calculated as a multiple of ATR.

This allows breakout confirmation to be normalized in several different ways.

For example, researchers can test whether a fixed one-tick breakout behaves differently from a volatility-adjusted or range-adjusted breakout.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
13. BID / ASK TRIGGER MODEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Breakout (Touch) includes an optional bid/ask trigger-timing model.

Application can be set to:

• Off
• Longs Only
• Shorts Only
• Both

Spread can be entered as:

• Ticks
• Absolute price

The model allows the visible TradingView trigger to be shifted relative to the intended execution level.

For example, on a bid-based chart, a long ask-trigger may occur while the visible bid remains one spread below the intended buy price.

The model therefore allows researchers to approximate the difference between:

• Structural/intended execution level
• Visible chart trigger level

IMPORTANT:

TradingView Strategy Tester still records the chart-trigger price as the actual historical fill.

Because of this limitation, built-in Strategy Tester P&L remains an approximation when bid/ask trigger modeling is enabled.

The feature is intended for execution research and timing approximation, not as a claim of perfect historical bid/ask reconstruction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
14. BID / ASK STOP MODEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory separately includes a spread model for stop-loss triggering.

Application options include:

• Off
• Long Stops Only
• Short Stops Only
• Both

This allows the displayed TradingView stop trigger to be shifted relative to the structural stop by the modeled spread.

The structural stop itself is still retained internally for calculations when desired.

This makes the entry-side spread assumption and stop-side spread assumption independently configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
15. ENTRY CALCULATION PRICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When spread modeling is active, Fixed-R calculations can use either:

CORRECTED ENTRY
Uses the intended execution level.

CHART TRIGGER
Uses the spread-shifted TradingView trigger.

This setting affects Fixed-R target calculations.

It does not independently change the actual submitted quantity or order execution.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
16. STOP CALCULATION PRICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Risk calculations can use either:

CORRECTED STOP
Uses the modeled spread-adjusted stop.

ORIGINAL STOP
Uses the underlying structural stop.

This selection can affect:

• Position sizing
• Original risk calculation
• Fixed-R target calculations

This allows researchers to separate structural price levels from the levels used to approximate executable stop behavior.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
17. EMA FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional EMA directional filter is included.

The EMA length is configurable.

Available rules:

PRICE VS EMA

Long:
Price must be above the EMA.

Short:
Price must be below the EMA.

EMA SLOPE

Long:
EMA must be rising.

Short:
EMA must be falling.

BOTH

Requires both the appropriate price relationship and EMA slope.

When enabled, the EMA is also plotted on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
18. VWAP FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional VWAP directional filter is available.

Rules include:

PRICE VS VWAP

Long:
Price above VWAP.

Short:
Price below VWAP.

VWAP SLOPE

Long:
VWAP rising.

Short:
VWAP falling.

BOTH

Requires both conditions.

When enabled, VWAP is plotted directly on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
19. PREVIOUS CLOSE FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The script retrieves the confirmed previous daily close without lookahead.

Two filtering modes are available:

PRICE VS PREVIOUS CLOSE

Long:
Current price must be above the previous close.

Short:
Current price must be below the previous close.

ORB VS PREVIOUS CLOSE

Long:
The entire ORB must be above the previous close.

Short:
The entire ORB must be below the previous close.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
20. ORB RANGE FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A configurable minimum and maximum ORB range filter is included.

The ORB size can be measured in:

• Ticks
• ATR multiples
• Percentage of price

This allows researchers to reject ranges that are considered:

• Too small
• Too large
• Abnormally compressed
• Abnormally volatile

It also makes range thresholds more portable across different symbols and volatility environments.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
21. RELATIVE VOLUME FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional relative-volume condition compares current volume with a moving average of volume.

Controls include:

• Volume average length
• Minimum relative-volume multiplier

A trade is permitted only when current volume meets or exceeds the selected multiple of average volume.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
22. ADX FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional ADX filter is included.

Controls:

• ADX length
• Minimum ADX value

This can be used to research whether ORB setups behave differently during stronger or weaker directional conditions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
23. MAXIMUM BREAKOUT CANDLE SIZE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The strategy can reject entry conditions when the current candle becomes excessively large relative to ATR.

Maximum breakout candle size is expressed as:

ATR × multiplier

This can be used to study whether chasing unusually extended breakout candles damages expectancy.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
24. STOP LOSS — CANDLE EXTREME
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For long trades:

Stop is placed below the relevant candle low, with an optional tick buffer.

For short trades:

Stop is placed above the relevant candle high, with an optional tick buffer.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
25. STOP LOSS — ATR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Places the stop a configurable ATR distance from the entry/reference price.

Long:
Entry/reference price - ATR × multiplier

Short:
Entry/reference price + ATR × multiplier

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
26. STOP LOSS — ORB MIDPOINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Uses the midpoint between the ORB High and ORB Low as the structural stop.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
27. STOP LOSS — ORB OPPOSITE RANGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Long:
Stop below the ORB Low.

Short:
Stop above the ORB High.

An optional stop buffer in ticks can be applied beyond the opposite boundary.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
28. STOP LOSS — BREAKOUT EXTREME
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Uses the relevant breakout extreme as the stop reference, with the optional stop buffer applied beyond that level.

This is useful for retest, failure, sweep, and other models where the breakout structure itself provides the invalidation point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
29. STOP LOSS — ORB PERCENTAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stop distance is calculated as a configurable percentage of the completed ORB range.

This allows the stop distance to scale directly with the size of the opening range.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
30. STOP LOSS — FVG INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Uses the relevant FVG boundary as the stop reference.

Long:
Below the FVG bottom.

Short:
Above the FVG top.

The configured stop buffer may also be applied.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
31. STOP BUFFER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A configurable stop buffer can be added in ticks.

This allows the structural stop to sit beyond the selected invalidation level rather than directly on it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
32. PROFIT TARGET — FIXED R
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Profit target is calculated as a multiple of the original trade risk.

Long:
Entry + Risk × R Multiple

Short:
Entry - Risk × R Multiple

The R multiple is fully configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
33. PROFIT TARGET — ORB PROJECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Projects a configurable multiple of the complete ORB range beyond the breakout boundary.

Long:
ORB High + ORB Range × multiplier

Short:
ORB Low - ORB Range × multiplier

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
34. PROFIT TARGET — ATR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sets the target a configurable ATR multiple away from entry.

Long:
Entry + ATR × multiplier

Short:
Entry - ATR × multiplier

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
35. PROFIT TARGET — ORB MIDPOINT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Uses the ORB midpoint as the target.

This can be useful when researching reversal or mean-reversion behavior.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
36. PROFIT TARGET — ORB OPPOSITE RANGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Targets the opposite ORB boundary.

This is especially useful for studying moves that rotate from one side of the range toward the other.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
37. DEDICATED FADE TARGETS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Fade/reversal entries can use their own target preference:

• Midpoint
• Opposite Boundary
• Fixed R

This allows continuation trades and fade trades to be researched using different exit logic.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
38. POSITION SIZING — FIXED USD RISK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Position size can be calculated so the planned loss between entry and stop corresponds to a fixed dollar amount.

The script calculates:

• Entry-to-stop distance
• Cash risk per unit
• Required quantity

and then rounds quantity according to the configured quantity step.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
39. POSITION SIZING — RISK % OF EQUITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Position size can dynamically scale with strategy equity.

The selected percentage of current equity is divided by the calculated cash risk per unit to determine quantity.

This allows compounding-based position sizing to be researched.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
40. POSITION SIZING — FIXED QUANTITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A fixed position size can be used instead of risk-based sizing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
41. QUANTITY CONSTRAINTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Position sizing supports:

• Quantity step
• Minimum quantity
• Maximum quantity

Calculated quantity is stepped downward to the permitted increment and then constrained within the configured minimum and maximum.

This makes sizing adaptable to instruments with different contract or quantity requirements.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
42. MAXIMUM DAILY PLANNED RISK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional daily planned-risk ceiling can prevent new entries when another planned trade would push total daily risk above the configured limit.

A value of zero disables this restriction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
43. STOP AFTER FIRST WIN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When enabled, the strategy prevents further entries after the first profitable closed trade of the day.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
44. STOP AFTER FIRST LOSS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When enabled, the strategy prevents further entries after the first losing closed trade of the day.

These two controls can be used independently to study daily stopping rules.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
45. ENTRY CUTOFF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A configurable time prevents new entries after a chosen hour and minute.

For Breakout (Touch), any remaining unfilled resting breakout orders are cancelled when the cutoff is reached.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
46. FORCE CLOSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional forced-close time exits any remaining open position at or after the configured time.

This is useful for strictly intraday strategies that should not carry positions beyond a session boundary.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
47. WEEKDAY FILTERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Every day of the week can be independently enabled or disabled:

• Monday
• Tuesday
• Wednesday
• Thursday
• Friday
• Saturday
• Sunday

This allows weekday effects to be researched without modifying the strategy code.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
48. BREAKEVEN MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional breakeven system can move the active stop after price reaches a configurable R multiple.

Controls:

• Breakeven activation R
• Breakeven offset in ticks

For a long position, the stop can move to entry plus the selected offset.

For a short position, the stop can move to entry minus the selected offset.

The stop is only tightened; the logic does not intentionally loosen an existing stop.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
49. BAR-CLOSE ATR TRAILING STOP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional ATR trailing system activates after the trade reaches a configurable R threshold.

The strategy tracks the best confirmed close reached during the trade.

After activation:

Long:
Trail candidate = Best Close - Entry ATR × Trail Multiplier

Short:
Trail candidate = Best Close + Entry ATR × Trail Multiplier

The stop only ratchets in the favorable direction.

The trailing logic operates on confirmed bars.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
50. TIME-BASED EXIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Positions can optionally be closed after a specified number of bars.

Setting the value to zero disables the time exit.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
51. ONE ACTIVE POSITION / NO PYRAMIDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The strategy is configured with pyramiding disabled.

New setups also require the strategy to be flat before entry.

This keeps the framework focused on one active position at a time rather than stacking multiple simultaneous positions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
52. OCA BREAKOUT ORDER MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Breakout (Touch) orders use One-Cancels-All behavior.

When one resting breakout order fills, competing unfilled touch orders are cancelled.

The strategy then records the filled ORB, direction, stop, target, entry ATR, and original risk for active position management.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
53. ORB VISUALIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Optional ORB boxes display the opening-range construction directly on the chart.

Once complete, the script extends:

• ORB High
• ORB Low
• Optional ORB Midpoint

forward on the chart.

This allows the strategy logic to be inspected visually rather than only through Strategy Tester results.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
54. SIGNAL LABELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Optional labels identify strategy entries and their originating logic.

Examples include:

• Breakout Touch Fill
• Breakout Close
• ORB Retest
• FVG Retest
• High Sweep
• Low Sweep
• Fade First High Break
• Fade First Low Break
• Decision: Continuation
• Decision: Failed High
• Decision: Failed Low

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
55. BLOCKED-REASON DEBUGGING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Optional debugging labels can show why an otherwise evaluated setup was blocked.

Possible reasons include:

• Direction disabled
• Range filter
• Entry / daily limit
• Bias / condition filter
• Other blocked condition

This feature is designed to make strategy research easier by showing not only where entries occurred, but also why expected entries did not occur.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
56. ACTIVE STOP & TARGET PLOTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

While a position is open, the strategy can display:

• Active Stop
• Active Target

directly on the chart.

Stops dynamically reflect breakeven or trailing-stop adjustments when those systems are active.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
57. RESEARCH DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional dashboard displays current strategy information including:

• Selected Entry Model
• Daily Entries vs Maximum
• Planned Daily Risk
• EMA Bias
• VWAP Bias
• Previous Daily Close
• Current Position: Long / Short / Flat
• Entry Cutoff Time

The dashboard provides a compact view of the currently active configuration and state.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
58. PREVIOUS DAILY CLOSE WITHOUT LOOKAHEAD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The previous-close feature retrieves confirmed daily data using lookahead disabled and then references the prior confirmed daily close.

This avoids intentionally using future daily information in the previous-close filter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
59. RESEARCH-FIRST DESIGN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory is intentionally modular.

Many settings are not intended to be enabled simultaneously.

The purpose is to allow individual hypotheses to be isolated.

Examples:

• Does Touch outperform Close confirmation?
• Does requiring a retest improve expectancy?
• Are failed first breaks more useful as fades?
• Does the ORB midpoint outperform an ATR stop?
• Does an EMA or VWAP filter improve results?
• Are very small or very large ORBs less effective?
• Does a breakout buffer improve robustness?
• Does performance survive different stop models?
• Does Fixed-R outperform range projection?
• How sensitive are results to spread assumptions?
• How does limiting entries affect drawdown?
• Do certain weekdays behave differently?
• Does breakeven improve or damage expectancy?

The framework is designed to answer those questions with data rather than intuition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT BACKTESTING NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory is a research and backtesting tool.

Historical results can change significantly based on:

• Symbol
• Exchange / broker data feed
• Timeframe
• ORB session
• ORB length
• Entry model
• Breakout buffer
• Stop model
• Target model
• Position sizing
• Spread assumptions
• Commission
• Slippage
• Filters
• Test period
• Market regime

Different data feeds can produce different highs and lows and therefore different ORB boundaries, triggers, stops, targets, and trade sequences.

Results from one feed should not be assumed to reproduce another feed trade-for-trade.

The optional bid/ask modeling system is an approximation built around TradingView's historical-chart limitations.

TradingView may still report the chart trigger as the historical fill even when the strategy is using a corrected/intended price internally for risk or target calculations.

Users should configure TradingView's Strategy Properties appropriately for the instrument and execution assumptions being researched, including commissions and any additional slippage assumptions.

No backtest guarantees future results.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INTENDED USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ORB Laboratory is intended for:

• Strategy research
• Backtesting
• Robustness testing
• Parameter sensitivity testing
• Comparing ORB entry models
• Comparing stop and target logic
• Studying opening-range behavior
• Execution-model research
• Market and data-feed comparison
• Educational experimentation

It is not intended to provide financial advice, guaranteed signals, or guaranteed profitability.

A profitable historical configuration may fail in future market conditions.

Users should independently validate any configuration before considering live execution.

Build the range.
Define the rules.
Stress the assumptions.
Test the edge.

---

## Source Code

````pine
//@version=6
strategy("ORB Laboratory v1.0.12",overlay = true,pyramiding = 0,calc_on_every_tick = false,calc_on_order_fills = false,process_orders_on_close = true,default_qty_type = strategy.fixed,default_qty_value = 1,commission_type = strategy.commission.cash_per_order,commission_value = 0,slippage = 0,max_boxes_count = 100,max_lines_count = 200,max_labels_count = 500)

// ============================================================================
// ORB LABORATORY v1.0.12
// Modular multi-session ORB research strategy.
// Includes:
// • Breakout touch / close
// • ORB retest
// • FVG retest
// • Sweep reversal
// • Fade first breakout
// • First-break decision tree
// • Multiple stop / target modes
// • Risk USD / risk % / fixed quantity
// • EMA, VWAP, previous-close, range, volume, ADX, weekday filters
// • One total / once per direction / max number / unlimited
// • Entry cutoff, force close, daily limits, breakeven, bar-close trailing
// • Optional bid/ask trigger-timing model for Breakout (Touch) entries
// • Optional bid/ask stop-trigger model for long / short exits
// • Direction-selective breakout buffer: Both / Longs Only / Shorts Only / Off
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// 1. GLOBAL EXECUTION
// ─────────────────────────────────────────────────────────────────────────────
gExec = "01 • Execution"

strategyTz = input.string("America/New_York", "Strategy Time Zone", group = gExec)

entryModel = input.string("Breakout (Close)","Entry Model",options = ["Breakout (Touch)","Breakout (Close)","Break + Retest ORB","Break + Retest FVG","Sweep Reversal","Fade First Breakout","First-Break Decision Tree"],group = gExec)

directionMode = input.string("Both","Direction",options = ["Both", "Long Only", "Short Only"],group = gExec)

entryAllowance = input.string("Once Per Direction","Entry Allowance",options = ["One Total", "Once Per Direction", "Maximum Number", "Unlimited"],group = gExec)

maxEntriesPerOrb = input.int(3, "Maximum Entries Per ORB", minval = 1, maxval = 20, group = gExec)
maxEntriesPerDay = input.int(6, "Maximum Entries Per Day", minval = 1, maxval = 100, group = gExec)

stopAfterFirstWin = input.bool(false, "Stop Trading After First Win", group = gExec)
stopAfterFirstLoss = input.bool(false, "Stop Trading After First Loss", group = gExec)

noEntryHour = input.int(11, "No New Entries After", minval = 0, maxval = 23, group = gExec, inline = "cut")
noEntryMinute = input.int(0, ":", minval = 0, maxval = 59, group = gExec, inline = "cut")

forceCloseEnabled = input.bool(true, "Force Close", group = gExec, inline = "fc")
forceCloseHour = input.int(15, "At", minval = 0, maxval = 23, group = gExec, inline = "fc")
forceCloseMinute = input.int(55, ":", minval = 0, maxval = 59, group = gExec, inline = "fc")

// ─────────────────────────────────────────────────────────────────────────────
// 2. WEEKDAYS
// ─────────────────────────────────────────────────────────────────────────────
gDays = "02 • Days"

tradeMon = input.bool(true, "Monday", group = gDays, inline = "d1")
tradeTue = input.bool(true, "Tuesday", group = gDays, inline = "d1")
tradeWed = input.bool(true, "Wednesday", group = gDays, inline = "d1")
tradeThu = input.bool(true, "Thursday", group = gDays, inline = "d1")
tradeFri = input.bool(true, "Friday", group = gDays, inline = "d1")
tradeSat = input.bool(false, "Saturday", group = gDays, inline = "d2")
tradeSun = input.bool(false, "Sunday", group = gDays, inline = "d2")

// ─────────────────────────────────────────────────────────────────────────────
// 3. ORB WINDOWS
// ─────────────────────────────────────────────────────────────────────────────
gOrb1 = "03 • ORB 1"
orb1Enabled = input.bool(true, "Enable", group = gOrb1)
orb1Name = input.string("New York Open", "Name", group = gOrb1)
orb1Hour = input.int(9, "Start", minval = 0, maxval = 23, group = gOrb1, inline = "o1")
orb1Minute = input.int(30, ":", minval = 0, maxval = 59, group = gOrb1, inline = "o1")
orb1Length = input.int(15, "Length (minutes)", minval = 1, maxval = 240, group = gOrb1)
orb1Long = input.bool(true, "Longs", group = gOrb1, inline = "o1d")
orb1Short = input.bool(true, "Shorts", group = gOrb1, inline = "o1d")

gOrb2 = "04 • ORB 2"
orb2Enabled = input.bool(false, "Enable", group = gOrb2)
orb2Name = input.string("Secondary Open", "Name", group = gOrb2)
orb2Hour = input.int(10, "Start", minval = 0, maxval = 23, group = gOrb2, inline = "o2")
orb2Minute = input.int(0, ":", minval = 0, maxval = 59, group = gOrb2, inline = "o2")
orb2Length = input.int(15, "Length (minutes)", minval = 1, maxval = 240, group = gOrb2)
orb2Long = input.bool(true, "Longs", group = gOrb2, inline = "o2d")
orb2Short = input.bool(true, "Shorts", group = gOrb2, inline = "o2d")

gOrb3 = "05 • ORB 3"
orb3Enabled = input.bool(false, "Enable", group = gOrb3)
orb3Name = input.string("Late Open", "Name", group = gOrb3)
orb3Hour = input.int(10, "Start", minval = 0, maxval = 23, group = gOrb3, inline = "o3")
orb3Minute = input.int(30, ":", minval = 0, maxval = 59, group = gOrb3, inline = "o3")
orb3Length = input.int(15, "Length (minutes)", minval = 1, maxval = 240, group = gOrb3)
orb3Long = input.bool(true, "Longs", group = gOrb3, inline = "o3d")
orb3Short = input.bool(true, "Shorts", group = gOrb3, inline = "o3d")

// ─────────────────────────────────────────────────────────────────────────────
// 4. ENTRY DETAILS
// ─────────────────────────────────────────────────────────────────────────────
gEntry = "06 • Entry Details"

bufferMode = input.string("Ticks", "Breakout Buffer Unit", options = ["Ticks", "ORB %", "ATR"], group = gEntry)
longBreakoutBuffer = input.float(1.0, "Long Breakout Buffer", minval = 0, step = 0.1, group = gEntry, tooltip = "Additional confirmation above the ORB high for long Breakout (Touch) entries.")
shortBreakoutBuffer = input.float(1.0, "Short Breakout Buffer", minval = 0, step = 0.1, group = gEntry, tooltip = "Additional confirmation below the ORB low for short Breakout (Touch) entries.")

// Bid/ask trigger-timing model for resting Breakout (Touch) orders.
// The chart trigger is shifted toward the current chart price, while sizing and
// Calculation-price dropdowns determine whether Fixed-R math uses the intended or spread-shifted prices.
// IMPORTANT: TradingView still records the chart-trigger price as the actual fill,
// so built-in Strategy Tester P&L is an approximation when this model is enabled.
spreadApplication = input.string("Off", "Bid/Ask Trigger Model", options = ["Off", "Longs Only", "Shorts Only", "Both"], group = gEntry)
stopSpreadApplication = input.string("Off", "Bid/Ask Stop Model", options = ["Off", "Long Stops Only", "Short Stops Only", "Both"], group = gEntry)
spreadUnit = input.string("Ticks", "Spread Unit", options = ["Ticks", "Price"], group = gEntry, inline = "spr")
spreadValue = input.float(0.0, "Spread", minval = 0.0, step = 0.1, group = gEntry, inline = "spr")
entryCalculationPrice = input.string(
     "Corrected Entry",
     "Entry Calculation Price",
     options = ["Corrected Entry", "Chart Trigger"],
     group = gEntry,
     tooltip = "Choose the entry price used for Fixed-R target calculations. Corrected Entry uses the intended execution level; Chart Trigger uses the spread-shifted TradingView trigger. This setting does not change order execution or quantity.")
stopCalculationPrice = input.string(
     "Corrected Stop",
     "Stop Calculation Price",
     options = ["Corrected Stop", "Original Stop"],
     group = gEntry,
     tooltip = "Choose the stop price used for position sizing, original risk, and Fixed-R target calculations. Corrected Stop uses the spread-shifted TradingView stop; Original Stop uses the structural stop.")

retestExpiryBars = input.int(10, "ORB Retest Expiry (bars)", minval = 1, maxval = 200, group = gEntry)
retestConfirmation = input.string("Close Outside","ORB Retest Confirmation",options = ["Touch Only", "Close Outside", "Rejection Candle"],group = gEntry)

maxExtensionOrb = input.float(0.75,"Maximum Extension Before Retest/Fade (ORB ×)",minval = 0.05,step = 0.05,group = gEntry)

fvgEntryLevel = input.string("Midpoint","FVG Entry Level",options = ["Near Edge", "Midpoint", "Full Fill"],group = gEntry)

fvgMinAtr = input.float(0.10, "Minimum FVG Size (ATR ×)", minval = 0, step = 0.05, group = gEntry)
fvgMustRemainOutside = input.bool(true, "FVG Must Remain Outside ORB", group = gEntry)
fvgExpiryBars = input.int(12, "FVG Expiry (bars)", minval = 1, maxval = 200, group = gEntry)

sweepConfirmation = input.string("Close Back Inside","Sweep / Fade Confirmation",options = ["Close Back Inside", "Rejection Candle"],group = gEntry)

fadeTargetPreference = input.string("Opposite Boundary","Fade Target",options = ["Midpoint", "Opposite Boundary", "Fixed R"],group = gEntry)

decisionTreeContinuation = input.string("Close Outside","Decision Tree Continuation",options = ["Touch", "Close Outside", "Retest Holds"],group = gEntry)

failureTimeoutBars = input.int(8, "First-Break Failure Timeout (bars)", minval = 1, maxval = 100, group = gEntry)

// ─────────────────────────────────────────────────────────────────────────────
// 5. FILTERS
// ─────────────────────────────────────────────────────────────────────────────
gFilters = "07 • Conditions"

useEmaBias = input.bool(false, "EMA Bias", group = gFilters)
emaLength = input.int(200, "EMA Length", minval = 1, group = gFilters)
emaBiasMode = input.string("Price vs EMA","EMA Rule",options = ["Price vs EMA", "EMA Slope", "Both"],group = gFilters)

useVwapBias = input.bool(false, "VWAP Bias", group = gFilters)
vwapBiasMode = input.string("Price vs VWAP","VWAP Rule",options = ["Price vs VWAP", "VWAP Slope", "Both"],group = gFilters)

usePrevCloseBias = input.bool(false, "Previous Close Bias", group = gFilters)
prevCloseMode = input.string("Price vs Previous Close","Previous Close Rule",options = ["Price vs Previous Close", "ORB vs Previous Close"],group = gFilters)

useRangeFilter = input.bool(true, "Minimum / Maximum ORB Range", group = gFilters)
rangeUnit = input.string("Ticks", "ORB Range Unit", options = ["Ticks", "ATR", "Percent"], group = gFilters)
minOrbRange = input.float(10, "Minimum ORB Range", minval = 0, step = 0.1, group = gFilters)
maxOrbRange = input.float(500, "Maximum ORB Range", minval = 0.1, step = 0.1, group = gFilters)

useVolumeFilter = input.bool(false, "Relative Volume Filter", group = gFilters)
volumeLength = input.int(20, "Volume Average Length", minval = 1, group = gFilters)
volumeMultiplier = input.float(1.2, "Minimum Relative Volume", minval = 0, step = 0.1, group = gFilters)

useAdxFilter = input.bool(false, "ADX Filter", group = gFilters)
adxLength = input.int(14, "ADX Length", minval = 1, group = gFilters)
minAdx = input.float(20, "Minimum ADX", minval = 0, step = 0.5, group = gFilters)

maxBreakoutCandleAtr = input.float(3.0,"Maximum Breakout Candle Size (ATR ×)",minval = 0.1,step = 0.1,group = gFilters)

// ─────────────────────────────────────────────────────────────────────────────
// 6. STOPS, TARGETS, RISK
// ─────────────────────────────────────────────────────────────────────────────
gRisk = "08 • Stops, Targets & Risk"

stopModel = input.string("Candle Extreme","Stop Loss",options = ["Candle Extreme","ATR","ORB Midpoint","ORB Opposite Range","Breakout Extreme","ORB Percentage","FVG Invalidation"],group = gRisk)

stopAtrMult = input.float(1.0, "ATR Stop Multiplier", minval = 0.05, step = 0.05, group = gRisk)
stopOrbPercent = input.float(50, "Stop Distance (% of ORB)", minval = 1, step = 1, group = gRisk)
stopBufferTicks = input.float(1, "Stop Buffer (ticks)", minval = 0, step = 1, group = gRisk)

targetModel = input.string("Fixed R","Profit Target",options = ["Fixed R", "ORB Projection", "ATR", "ORB Midpoint", "ORB Opposite Range"],group = gRisk)

targetR = input.float(1.5, "Target R Multiple", minval = 0.1, step = 0.1, group = gRisk)
targetOrbMult = input.float(1.0, "ORB Projection Multiplier", minval = 0.1, step = 0.1, group = gRisk)
targetAtrMult = input.float(2.0, "ATR Target Multiplier", minval = 0.1, step = 0.1, group = gRisk)

riskMode = input.string("Risk USD","Position Sizing",options = ["Risk USD", "Risk % of Equity", "Fixed Quantity"],group = gRisk)

riskUsd = input.float(500, "Risk Per Trade (USD)", minval = 0.01, step = 1, group = gRisk)
riskPercent = input.float(0.50, "Risk Per Trade (% equity)", minval = 0.01, maxval = 10, step = 0.05, group = gRisk)
fixedQuantity = input.float(1, "Fixed Quantity", minval = 0.000001, step = 1, group = gRisk)

quantityStep = input.float(1, "Quantity Step", minval = 0.000001, group = gRisk)
minimumQuantity = input.float(1, "Minimum Quantity", minval = 0.000001, group = gRisk)
maximumQuantity = input.float(1000000, "Maximum Quantity", minval = 0.000001, group = gRisk)

maxDailyPlannedRiskUsd = input.float(0,"Maximum Planned Risk Per Day (USD, 0 = off)",minval = 0,step = 1,group = gRisk)

useBreakEven = input.bool(false, "Move Stop to Breakeven", group = gRisk)
breakEvenAtR = input.float(1.0, "Breakeven Activation (R)", minval = 0.1, step = 0.1, group = gRisk)
breakEvenOffsetTicks = input.float(0, "Breakeven Offset (ticks)", step = 1, group = gRisk)

useBarCloseTrail = input.bool(false, "Bar-Close ATR Trail", group = gRisk)
trailActivationR = input.float(1.0, "Trail Activation (R)", minval = 0.1, step = 0.1, group = gRisk)
trailAtrMult = input.float(1.0, "Trail Distance (ATR ×)", minval = 0.05, step = 0.05, group = gRisk)

timeExitBars = input.int(0, "Exit After Bars (0 = off)", minval = 0, maxval = 10000, group = gRisk)

// ─────────────────────────────────────────────────────────────────────────────
// 7. VISUALS
// ─────────────────────────────────────────────────────────────────────────────
gVisual = "09 • Visuals & Debug"

showBoxes = input.bool(true, "Show ORB Boxes", group = gVisual)
showMidpoint = input.bool(true, "Show Midpoints", group = gVisual)
showSignals = input.bool(true, "Show Signal Labels", group = gVisual)
showBlockedReasons = input.bool(false, "Show Blocked Reasons", group = gVisual)
showDashboard = input.bool(true, "Show Dashboard", group = gVisual)

// ─────────────────────────────────────────────────────────────────────────────
// 8. CORE SERIES
// ─────────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)
ema = ta.ema(close, emaLength)
vwap = ta.vwap(hlc3)
confirmedDailyClose = request.security(
     syminfo.tickerid,
     "D",
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off)
prevClose = confirmedDailyClose[1]
volumeAvg = ta.sma(volume, volumeLength)
[diPlus, diMinus, adx] = ta.dmi(adxLength, adxLength)

localMinutes = hour(time, strategyTz) * 60 + minute(time, strategyTz)
newLocalDay = dayofmonth(time, strategyTz) != dayofmonth(time[1], strategyTz) or
     month(time, strategyTz) != month(time[1], strategyTz)

dayNum = dayofweek(time, strategyTz)
dayAllowed = (dayNum == dayofweek.monday and tradeMon) or(dayNum == dayofweek.tuesday and tradeTue) or(dayNum == dayofweek.wednesday and tradeWed) or(dayNum == dayofweek.thursday and tradeThu) or(dayNum == dayofweek.friday and tradeFri) or(dayNum == dayofweek.saturday and tradeSat) or(dayNum == dayofweek.sunday and tradeSun)

entryCutoffMinutes = noEntryHour * 60 + noEntryMinute
forceCloseMinutes = forceCloseHour * 60 + forceCloseMinute
beforeEntryCutoff = localMinutes < entryCutoffMinutes

longGloballyAllowed = directionMode != "Short Only"
shortGloballyAllowed = directionMode != "Long Only"

// ─────────────────────────────────────────────────────────────────────────────
// 9. ORB ARRAYS / STATE
// ─────────────────────────────────────────────────────────────────────────────
var enabledA = array.from(orb1Enabled, orb2Enabled, orb3Enabled)
var namesA = array.from(orb1Name, orb2Name, orb3Name)
var startsA = array.from(orb1Hour * 60 + orb1Minute, orb2Hour * 60 + orb2Minute, orb3Hour * 60 + orb3Minute)
var lengthsA = array.from(orb1Length, orb2Length, orb3Length)
var longsA = array.from(orb1Long, orb2Long, orb3Long)
var shortsA = array.from(orb1Short, orb2Short, orb3Short)

var orbHighA = array.new_float(3, na)
var orbLowA = array.new_float(3, na)
var orbMidA = array.new_float(3, na)
var buildingA = array.new_bool(3, false)
var completeA = array.new_bool(3, false)

var totalEntriesA = array.new_int(3, 0)
var longEntriesA = array.new_int(3, 0)
var shortEntriesA = array.new_int(3, 0)

var firstBreakSideA = array.new_int(3, 0)
var firstBreakBarA = array.new_int(3, na)
var firstBreakExtremeA = array.new_float(3, na)
var firstBreakConsumedA = array.new_bool(3, false)

var breakoutSideA = array.new_int(3, 0)
var breakoutBarA = array.new_int(3, na)
var retestArmedA = array.new_bool(3, false)

var fvgTopA = array.new_float(3, na)
var fvgBottomA = array.new_float(3, na)
var fvgSideA = array.new_int(3, 0)
var fvgBarA = array.new_int(3, na)

var boxA = array.new_box(3, na)
var highLineA = array.new_line(3, na)
var lowLineA = array.new_line(3, na)
var midLineA = array.new_line(3, na)

var int[] gDailyEntries = array.new_int(1, 0)
var float[] gDailyPlannedRiskUsd = array.new_float(1, 0.0)
var bool winnerSeen = false
var bool loserSeen = false
var int lastClosedTrades = 0

var float[] gActiveStop = array.new_float(1, na)
var float[] gActiveTarget = array.new_float(1, na)
var float[] gOriginalRisk = array.new_float(1, na)
var float[] gEntryAtr = array.new_float(1, na)
var float[] gBestClose = array.new_float(1, na)
var int[] gActiveEntryBar = array.new_int(1, na)
var int[] gActiveOrbIndex = array.new_int(1, na)
var int[] gActiveDirection = array.new_int(1, 0)
var string[] gActiveEntryId = array.new_string(1, "")

// Pending stop-entry state for true intrabar Breakout (Touch) orders.
var float[] pendingLongStopA = array.new_float(3, na)
var float[] pendingLongTargetA = array.new_float(3, na)
var float[] pendingLongAtrA = array.new_float(3, na)
var float[] pendingLongRiskA = array.new_float(3, na)
var bool[] pendingLongArmedA = array.new_bool(3, false)
var float[] pendingShortStopA = array.new_float(3, na)
var float[] pendingShortTargetA = array.new_float(3, na)
var float[] pendingShortAtrA = array.new_float(3, na)
var float[] pendingShortRiskA = array.new_float(3, na)
var bool[] pendingShortArmedA = array.new_bool(3, false)


// Reset daily state.
if newLocalDay
    array.set(gDailyEntries, 0, 0)
    array.set(gDailyPlannedRiskUsd, 0, 0.0)
    winnerSeen := false
    loserSeen := false

    for i = 0 to 2
        array.set(orbHighA, i, na)
        array.set(orbLowA, i, na)
        array.set(orbMidA, i, na)
        array.set(buildingA, i, false)
        array.set(completeA, i, false)

        array.set(totalEntriesA, i, 0)
        array.set(longEntriesA, i, 0)
        array.set(shortEntriesA, i, 0)

        array.set(firstBreakSideA, i, 0)
        array.set(firstBreakBarA, i, na)
        array.set(firstBreakExtremeA, i, na)
        array.set(firstBreakConsumedA, i, false)

        array.set(breakoutSideA, i, 0)
        array.set(breakoutBarA, i, na)
        array.set(retestArmedA, i, false)

        array.set(fvgTopA, i, na)
        array.set(fvgBottomA, i, na)
        array.set(fvgSideA, i, 0)
        array.set(fvgBarA, i, na)

        // Cancel and clear any unfilled touch-entry orders from the prior day.
        strategy.cancel("ORB" + str.tostring(i + 1) + "-L")
        strategy.cancel("ORB" + str.tostring(i + 1) + "-S")
        array.set(pendingLongArmedA, i, false)
        array.set(pendingShortArmedA, i, false)
        array.set(pendingLongStopA, i, na)
        array.set(pendingLongTargetA, i, na)
        array.set(pendingLongAtrA, i, na)
        array.set(pendingLongRiskA, i, na)
        array.set(pendingShortStopA, i, na)
        array.set(pendingShortTargetA, i, na)
        array.set(pendingShortAtrA, i, na)
        array.set(pendingShortRiskA, i, na)

        bx = array.get(boxA, i)
        if not na(bx)
            box.delete(bx)
        array.set(boxA, i, na)

        hl = array.get(highLineA, i)
        ll = array.get(lowLineA, i)
        ml = array.get(midLineA, i)

        if not na(hl)
            line.delete(hl)
        if not na(ll)
            line.delete(ll)
        if not na(ml)
            line.delete(ml)

        array.set(highLineA, i, na)
        array.set(lowLineA, i, na)
        array.set(midLineA, i, na)

// Closed-trade tracking.
if strategy.closedtrades > lastClosedTrades
    lastPnl = strategy.closedtrades.profit(strategy.closedtrades - 1)
    winnerSeen := winnerSeen or lastPnl > 0
    loserSeen := loserSeen or lastPnl <= 0
    lastClosedTrades := strategy.closedtrades

// ─────────────────────────────────────────────────────────────────────────────
// 10. HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_breakBuffer(int direction, float orbRange) =>
    selectedBuffer = direction == 1 ? longBreakoutBuffer : shortBreakoutBuffer
    bufferMode == "Ticks" ? selectedBuffer * syminfo.mintick :
     bufferMode == "ORB %" ? orbRange * selectedBuffer / 100.0 :
     atr * selectedBuffer

f_spreadPrice() =>
    spreadUnit == "Ticks" ? spreadValue * syminfo.mintick : spreadValue

f_spreadApplies(int direction) =>
    spreadApplication == "Both" or
     direction == 1 and spreadApplication == "Longs Only" or
     direction == -1 and spreadApplication == "Shorts Only"

// On a bid chart, a long ask-trigger can occur while bid is one spread below the
// intended buy price. The short adjustment is the symmetric optional case for an
// ask-based chart or other testing assumptions.
f_chartTrigger(int direction, float intendedFillPrice) =>
    spr = f_spreadApplies(direction) ? f_spreadPrice() : 0.0
    direction == 1 ? intendedFillPrice - spr : intendedFillPrice + spr

f_stopSpreadApplies(int direction) =>
    stopSpreadApplication == "Both" or
     direction == 1 and stopSpreadApplication == "Long Stops Only" or
     direction == -1 and stopSpreadApplication == "Short Stops Only"

// Shift the visible chart stop away from the position by one modeled spread.
// The structural stop remains available as the Original Stop calculation option.
f_chartStop(int direction, float intendedStopPrice) =>
    spr = f_stopSpreadApplies(direction) ? f_spreadPrice() : 0.0
    direction == 1 ? intendedStopPrice - spr : intendedStopPrice + spr

f_rangeMetric(float orbRange) =>
    rangeUnit == "Ticks" ? orbRange / syminfo.mintick :
     rangeUnit == "ATR" ? orbRange / math.max(atr, syminfo.mintick) :
     orbRange / close * 100.0

f_capacityOk(int orbIndex, int direction) =>
    total = array.get(totalEntriesA, orbIndex)
    dirCount = direction == 1 ? array.get(longEntriesA, orbIndex) : array.get(shortEntriesA, orbIndex)

    entryModeOk = entryAllowance == "Unlimited" ? true :
     entryAllowance == "One Total" ? total == 0 :
     entryAllowance == "Once Per Direction" ? dirCount == 0 :
     total < maxEntriesPerOrb

    dailyRiskOk = maxDailyPlannedRiskUsd <= 0 or
     array.get(gDailyPlannedRiskUsd, 0) + riskUsd <= maxDailyPlannedRiskUsd

    entryModeOk and
     array.get(gDailyEntries, 0) < maxEntriesPerDay and
     dailyRiskOk and
     not (stopAfterFirstWin and winnerSeen) and
     not (stopAfterFirstLoss and loserSeen)

f_biasOk(int direction, float orbHigh, float orbLow) =>
    emaPriceOk = direction == 1 ? close > ema : close < ema
    emaSlopeOk = direction == 1 ? ema > ema[1] : ema < ema[1]

    emaOk = not useEmaBias or
     (emaBiasMode == "Price vs EMA" ? emaPriceOk :
      emaBiasMode == "EMA Slope" ? emaSlopeOk :
      emaPriceOk and emaSlopeOk)

    vwapPriceOk = direction == 1 ? close > vwap : close < vwap
    vwapSlopeOk = direction == 1 ? vwap > vwap[1] : vwap < vwap[1]

    vwapOk = not useVwapBias or
     (vwapBiasMode == "Price vs VWAP" ? vwapPriceOk :
      vwapBiasMode == "VWAP Slope" ? vwapSlopeOk :
      vwapPriceOk and vwapSlopeOk)

    prevPriceOk = direction == 1 ? close > prevClose : close < prevClose
    prevOrbOk = direction == 1 ? orbLow > prevClose : orbHigh < prevClose

    prevOk = not usePrevCloseBias or
     (prevCloseMode == "Price vs Previous Close" ? prevPriceOk : prevOrbOk)

    volumeOk = not useVolumeFilter or volume >= volumeAvg * volumeMultiplier
    adxOk = not useAdxFilter or adx >= minAdx
    candleOk = high - low <= atr * maxBreakoutCandleAtr

    emaOk and vwapOk and prevOk and volumeOk and adxOk and candleOk

f_qty(float entryPrice, float stopPrice) =>
    stopDistance = math.abs(entryPrice - stopPrice)
    cashPerUnit = stopDistance * math.max(syminfo.pointvalue, 0.0000001)

    rawQty = riskMode == "Risk USD" ?
     riskUsd / math.max(cashPerUnit, 0.0000001) :
     riskMode == "Risk % of Equity" ?
     (strategy.equity * riskPercent / 100.0) / math.max(cashPerUnit, 0.0000001) :
     fixedQuantity

    steppedQty = math.floor(rawQty / quantityStep) * quantityStep
    math.max(minimumQuantity, math.min(maximumQuantity, steppedQty))

f_stop(int direction, float orbHigh, float orbLow, float breakoutExtreme, float fvgTop, float fvgBottom) =>
    buffer = stopBufferTicks * syminfo.mintick
    midpoint = (orbHigh + orbLow) / 2.0
    orbRange = orbHigh - orbLow

    candleStop = direction == 1 ? low - buffer : high + buffer
    atrStop = direction == 1 ? close - atr * stopAtrMult : close + atr * stopAtrMult
    midpointStop = midpoint
    oppositeStop = direction == 1 ? orbLow - buffer : orbHigh + buffer
    breakoutStop = direction == 1 ? breakoutExtreme - buffer : breakoutExtreme + buffer
    percentStop = direction == 1 ?
     close - orbRange * stopOrbPercent / 100.0 :
     close + orbRange * stopOrbPercent / 100.0
    fvgStop = direction == 1 ? fvgBottom - buffer : fvgTop + buffer

    selected = stopModel == "Candle Extreme" ? candleStop :
     stopModel == "ATR" ? atrStop :
     stopModel == "ORB Midpoint" ? midpointStop :
     stopModel == "ORB Opposite Range" ? oppositeStop :
     stopModel == "Breakout Extreme" ? breakoutStop :
     stopModel == "ORB Percentage" ? percentStop :
     fvgStop

    direction == 1 ?
     math.min(selected, close - syminfo.mintick) :
     math.max(selected, close + syminfo.mintick)

f_target(int direction, float entryPrice, float stopPrice, float orbHigh, float orbLow, bool isFade) =>
    midpoint = (orbHigh + orbLow) / 2.0
    orbRange = orbHigh - orbLow
    risk = math.abs(entryPrice - stopPrice)

    fixedR = direction == 1 ?
     entryPrice + risk * targetR :
     entryPrice - risk * targetR

    projection = direction == 1 ?
     orbHigh + orbRange * targetOrbMult :
     orbLow - orbRange * targetOrbMult

    atrTarget = direction == 1 ?
     entryPrice + atr * targetAtrMult :
     entryPrice - atr * targetAtrMult

    opposite = direction == 1 ? orbHigh : orbLow

    fadeTarget = fadeTargetPreference == "Midpoint" ? midpoint :
     fadeTargetPreference == "Opposite Boundary" ? opposite :
     fixedR

    isFade ? fadeTarget :
     targetModel == "Fixed R" ? fixedR :
     targetModel == "ORB Projection" ? projection :
     targetModel == "ATR" ? atrTarget :
     targetModel == "ORB Midpoint" ? midpoint :
     opposite

f_markEntry(int orbIndex, int direction) =>
    array.set(totalEntriesA, orbIndex, array.get(totalEntriesA, orbIndex) + 1)

    if direction == 1
        array.set(longEntriesA, orbIndex, array.get(longEntriesA, orbIndex) + 1)
    else
        array.set(shortEntriesA, orbIndex, array.get(shortEntriesA, orbIndex) + 1)

    array.set(gDailyEntries, 0, array.get(gDailyEntries, 0) + 1)

    if riskMode == "Risk USD"
        array.set(gDailyPlannedRiskUsd, 0, array.get(gDailyPlannedRiskUsd, 0) + riskUsd)

f_stopAtPrice(int direction, float entryPrice, float orbHigh, float orbLow, float breakoutExtreme, float fvgTop, float fvgBottom) =>
    buffer = stopBufferTicks * syminfo.mintick
    midpoint = (orbHigh + orbLow) / 2.0
    orbRange = orbHigh - orbLow

    candleStop = direction == 1 ? low - buffer : high + buffer
    atrStop = direction == 1 ? entryPrice - atr * stopAtrMult : entryPrice + atr * stopAtrMult
    midpointStop = midpoint
    oppositeStop = direction == 1 ? orbLow - buffer : orbHigh + buffer
    breakoutStop = direction == 1 ? breakoutExtreme - buffer : breakoutExtreme + buffer
    percentStop = direction == 1 ?
     entryPrice - orbRange * stopOrbPercent / 100.0 :
     entryPrice + orbRange * stopOrbPercent / 100.0
    fvgStop = direction == 1 ? fvgBottom - buffer : fvgTop + buffer

    selected = stopModel == "Candle Extreme" ? candleStop :
     stopModel == "ATR" ? atrStop :
     stopModel == "ORB Midpoint" ? midpointStop :
     stopModel == "ORB Opposite Range" ? oppositeStop :
     stopModel == "Breakout Extreme" ? breakoutStop :
     stopModel == "ORB Percentage" ? percentStop :
     fvgStop

    direction == 1 ?
     math.min(selected, entryPrice - syminfo.mintick) :
     math.max(selected, entryPrice + syminfo.mintick)

f_armTouch(int orbIndex, int direction, float triggerPrice, float orbHigh, float orbLow, float breakoutExtreme, float fvgTop, float fvgBottom) =>
    orbDirectionOk = direction == 1 ?
     longGloballyAllowed and array.get(longsA, orbIndex) :
     shortGloballyAllowed and array.get(shortsA, orbIndex)

    rangeMetric = f_rangeMetric(orbHigh - orbLow)
    rangeOk = not useRangeFilter or
     (rangeMetric >= minOrbRange and rangeMetric <= maxOrbRange)
    capacityOk = f_capacityOk(orbIndex, direction)
    biasOk = f_biasOk(direction, orbHigh, orbLow)
    alreadyArmed = direction == 1 ? array.get(pendingLongArmedA, orbIndex) : array.get(pendingShortArmedA, orbIndex)
    generalOk = dayAllowed and beforeEntryCutoff and strategy.position_size == 0 and not alreadyArmed

    if orbDirectionOk and rangeOk and capacityOk and biasOk and generalOk
        intendedFillPrice = triggerPrice
        chartTriggerPrice = f_chartTrigger(direction, intendedFillPrice)
        stopPrice = f_stopAtPrice(direction, intendedFillPrice, orbHigh, orbLow, breakoutExtreme, fvgTop, fvgBottom)
        chartStopPrice = f_chartStop(direction, stopPrice)
        targetEntryPrice = entryCalculationPrice == "Corrected Entry" ? intendedFillPrice : chartTriggerPrice
        riskStopPrice = stopCalculationPrice == "Corrected Stop" ? chartStopPrice : stopPrice
        targetPrice = f_target(direction, targetEntryPrice, riskStopPrice, orbHigh, orbLow, false)
        qty = f_qty(intendedFillPrice, riskStopPrice)
        entryId = "ORB" + str.tostring(orbIndex + 1) + (direction == 1 ? "-L" : "-S")

        // The visible chart trigger can be shifted for bid/ask timing, but risk
        // calculation settings independently select the entry and stop used for risk math.
        strategy.entry(
             entryId,
             direction == 1 ? strategy.long : strategy.short,
             qty = qty,
             stop = chartTriggerPrice,
             oca_name = "ORB-TOUCH-" + str.tostring(year(time, strategyTz)) + "-" +
                  str.tostring(month(time, strategyTz)) + "-" +
                  str.tostring(dayofmonth(time, strategyTz)),
             oca_type = strategy.oca.cancel)
        strategy.exit("X-" + entryId, from_entry = entryId, stop = chartStopPrice, limit = targetPrice)

        if direction == 1
            array.set(pendingLongStopA, orbIndex, stopPrice)
            array.set(pendingLongTargetA, orbIndex, targetPrice)
            array.set(pendingLongAtrA, orbIndex, atr)
            array.set(pendingLongRiskA, orbIndex, math.abs(intendedFillPrice - riskStopPrice))
            array.set(pendingLongArmedA, orbIndex, true)
        else
            array.set(pendingShortStopA, orbIndex, stopPrice)
            array.set(pendingShortTargetA, orbIndex, targetPrice)
            array.set(pendingShortAtrA, orbIndex, atr)
            array.set(pendingShortRiskA, orbIndex, math.abs(intendedFillPrice - riskStopPrice))
            array.set(pendingShortArmedA, orbIndex, true)

f_submit(int orbIndex, int direction, bool isFade, float orbHigh, float orbLow, float breakoutExtreme, float fvgTop, float fvgBottom, string reason) =>
    orbDirectionOk = direction == 1 ?
     longGloballyAllowed and array.get(longsA, orbIndex) :
     shortGloballyAllowed and array.get(shortsA, orbIndex)

    rangeMetric = f_rangeMetric(orbHigh - orbLow)
    rangeOk = not useRangeFilter or
     (rangeMetric >= minOrbRange and rangeMetric <= maxOrbRange)

    capacityOk = f_capacityOk(orbIndex, direction)
    biasOk = f_biasOk(direction, orbHigh, orbLow)
    generalOk = dayAllowed and beforeEntryCutoff and strategy.position_size == 0

    if orbDirectionOk and rangeOk and capacityOk and biasOk and generalOk
        stopPrice = f_stop(direction, orbHigh, orbLow, breakoutExtreme, fvgTop, fvgBottom)
        chartStopPrice = f_chartStop(direction, stopPrice)
        riskStopPrice = stopCalculationPrice == "Corrected Stop" ? chartStopPrice : stopPrice
        targetPrice = f_target(direction, close, riskStopPrice, orbHigh, orbLow, isFade)
        qty = f_qty(close, riskStopPrice)

        entryId = "ORB" + str.tostring(orbIndex + 1) + (direction == 1 ? "-L" : "-S")

        strategy.entry(
             entryId,
             direction == 1 ? strategy.long : strategy.short,
             qty = qty)

        array.set(gActiveStop, 0, stopPrice)
        array.set(gActiveTarget, 0, targetPrice)
        array.set(gOriginalRisk, 0, math.abs(close - riskStopPrice))
        array.set(gEntryAtr, 0, atr)
        array.set(gBestClose, 0, close)
        array.set(gActiveEntryBar, 0, bar_index)
        array.set(gActiveOrbIndex, 0, orbIndex)
        array.set(gActiveDirection, 0, direction)
        array.set(gActiveEntryId, 0, entryId)

        f_markEntry(orbIndex, direction)

        if showSignals
            label.new(
                 bar_index,
                 direction == 1 ? low : high,
                 array.get(namesA, orbIndex) + "\n" + reason,
                 style = direction == 1 ? label.style_label_up : label.style_label_down,
                 color = direction == 1 ? color.new(color.green, 15) : color.new(color.red, 15),
                 textcolor = color.white)

    else if showBlockedReasons and generalOk
        blockedReason = not orbDirectionOk ? "Direction disabled" :
             not rangeOk ? "Range filter" :
             not capacityOk ? "Entry / daily limit" :
             not biasOk ? "Bias / condition filter" :
             "Blocked"

        label.new(
             bar_index,
             high,
             "ORB " + str.tostring(orbIndex + 1) + ": " + blockedReason,
             style = label.style_label_down,
             color = color.new(color.gray, 55),
             textcolor = color.white)

// ─────────────────────────────────────────────────────────────────────────────
// 11. BUILD ORBS AND PROCESS ENTRY MODELS
// ─────────────────────────────────────────────────────────────────────────────
for i = 0 to 2
    enabled = array.get(enabledA, i)
    startMinute = array.get(startsA, i)
    endMinute = startMinute + array.get(lengthsA, i)

    // Finalize on the close of the last ORB bar, so resting breakout
    // orders are submitted before the first post-range bar begins.
    // This also handles a one-bar ORB correctly.
    startHourLocal = int(math.floor(startMinute / 60))
    startMinuteLocal = startMinute % 60
    orbStartTs = timestamp(strategyTz, year(time, strategyTz), month(time, strategyTz), dayofmonth(time, strategyTz), startHourLocal, startMinuteLocal)
    orbEndTs = orbStartTs + array.get(lengthsA, i) * 60 * 1000
    inBuild = enabled and time >= orbStartTs and time < orbEndTs
    finishesThisBar = inBuild and time_close >= orbEndTs
    justStarted = inBuild and not array.get(buildingA, i)

    // Do not depend on `buildingA` already being true here. On a one-bar ORB,
    // the first range bar is also the final range bar, so both events occur
    // during the same calculation.
    justCompleted = finishesThisBar and not array.get(completeA, i)

    if justStarted
        array.set(orbHighA, i, high)
        array.set(orbLowA, i, low)
        array.set(orbMidA, i, (high + low) / 2.0)
        array.set(buildingA, i, true)
        array.set(completeA, i, false)

        if showBoxes
            bx = box.new(
                 left = bar_index,
                 top = high,
                 right = bar_index,
                 bottom = low,
                 bgcolor = color.new(color.blue, 88),
                 border_color = color.new(color.blue, 35))
            array.set(boxA, i, bx)

    if inBuild
        orbHi = math.max(nz(array.get(orbHighA, i), high), high)
        orbLo = math.min(nz(array.get(orbLowA, i), low), low)

        array.set(orbHighA, i, orbHi)
        array.set(orbLowA, i, orbLo)
        array.set(orbMidA, i, (orbHi + orbLo) / 2.0)

        bx = array.get(boxA, i)
        if showBoxes and not na(bx)
            box.set_right(bx, bar_index)
            box.set_top(bx, orbHi)
            box.set_bottom(bx, orbLo)

    if justCompleted
        array.set(buildingA, i, false)
        array.set(completeA, i, true)

        orbHi = array.get(orbHighA, i)
        orbLo = array.get(orbLowA, i)
        orbMid = (orbHi + orbLo) / 2.0

        array.set(orbMidA, i, orbMid)

        highLine = line.new(
             bar_index,
             orbHi,
             bar_index + 1,
             orbHi,
             extend = extend.right,
             color = color.new(color.green, 20))

        lowLine = line.new(
             bar_index,
             orbLo,
             bar_index + 1,
             orbLo,
             extend = extend.right,
             color = color.new(color.red, 20))

        array.set(highLineA, i, highLine)
        array.set(lowLineA, i, lowLine)

        if showMidpoint
            midLine = line.new(
                 bar_index,
                 orbMid,
                 bar_index + 1,
                 orbMid,
                 extend = extend.right,
                 color = color.new(color.gray, 45),
                 style = line.style_dashed)

            array.set(midLineA, i, midLine)

    if enabled and array.get(completeA, i)
        orbHi = array.get(orbHighA, i)
        orbLo = array.get(orbLowA, i)
        orbRange = orbHi - orbLo
        longBuffer = f_breakBuffer(1, orbRange)
        shortBuffer = f_breakBuffer(-1, orbRange)

        longTouch = high >= orbHi + longBuffer
        shortTouch = low <= orbLo - shortBuffer
        longClose = close > orbHi + longBuffer
        shortClose = close < orbLo - shortBuffer

        // Permanent first-break record.
        if array.get(firstBreakSideA, i) == 0
            if longTouch and not shortTouch
                array.set(firstBreakSideA, i, 1)
                array.set(firstBreakBarA, i, bar_index)
                array.set(firstBreakExtremeA, i, high)

            else if shortTouch and not longTouch
                array.set(firstBreakSideA, i, -1)
                array.set(firstBreakBarA, i, bar_index)
                array.set(firstBreakExtremeA, i, low)

        // Keep extending the first-break extreme until consumed/expired.
        firstSide = array.get(firstBreakSideA, i)
        if firstSide == 1 and not array.get(firstBreakConsumedA, i)
            array.set(
                 firstBreakExtremeA,
                 i,
                 math.max(nz(array.get(firstBreakExtremeA, i), high), high))

        if firstSide == -1 and not array.get(firstBreakConsumedA, i)
            array.set(
                 firstBreakExtremeA,
                 i,
                 math.min(nz(array.get(firstBreakExtremeA, i), low), low))

        // Breakout state for retest models.
        if longClose and array.get(breakoutSideA, i) == 0
            array.set(breakoutSideA, i, 1)
            array.set(breakoutBarA, i, bar_index)
            array.set(retestArmedA, i, true)

        if shortClose and array.get(breakoutSideA, i) == 0
            array.set(breakoutSideA, i, -1)
            array.set(breakoutBarA, i, bar_index)
            array.set(retestArmedA, i, true)

        // Directional FVG detection.
        bullFvg = low > high[2] and low - high[2] >= atr * fvgMinAtr
        bearFvg = high < low[2] and low[2] - high >= atr * fvgMinAtr

        if array.get(breakoutSideA, i) == 1 and bullFvg
            validOutside = not fvgMustRemainOutside or high[2] >= orbHi

            if validOutside
                array.set(fvgBottomA, i, high[2])
                array.set(fvgTopA, i, low)
                array.set(fvgSideA, i, 1)
                array.set(fvgBarA, i, bar_index)

        if array.get(breakoutSideA, i) == -1 and bearFvg
            validOutside = not fvgMustRemainOutside or low[2] <= orbLo

            if validOutside
                array.set(fvgBottomA, i, high)
                array.set(fvgTopA, i, low[2])
                array.set(fvgSideA, i, -1)
                array.set(fvgBarA, i, bar_index)

        fvgTop = array.get(fvgTopA, i)
        fvgBottom = array.get(fvgBottomA, i)

        // 1. Breakout touch — arm resting stop orders before the breakout occurs.
        if entryModel == "Breakout (Touch)"
            f_armTouch(i, 1, orbHi + longBuffer, orbHi, orbLo, orbLo, fvgTop, fvgBottom)
            f_armTouch(i, -1, orbLo - shortBuffer, orbHi, orbLo, orbHi, fvgTop, fvgBottom)

        // 2. Breakout close
        if entryModel == "Breakout (Close)"
            if longClose
                f_submit(i, 1, false, orbHi, orbLo, low, fvgTop, fvgBottom, "Breakout Close")
            if shortClose
                f_submit(i, -1, false, orbHi, orbLo, high, fvgTop, fvgBottom, "Breakout Close")

        // 3. ORB retest
        if entryModel == "Break + Retest ORB" and array.get(retestArmedA, i)
            breakSide = array.get(breakoutSideA, i)
            breakBar = array.get(breakoutBarA, i)
            withinExpiry = not na(breakBar) and bar_index - breakBar <= retestExpiryBars

            longNotOverextended = high <= orbHi + orbRange * maxExtensionOrb
            shortNotOverextended = low >= orbLo - orbRange * maxExtensionOrb

            longRejection = low <= orbHi and close > open and close > orbHi
            shortRejection = high >= orbLo and close < open and close < orbLo

            longRetest = low <= orbHi and
                 (retestConfirmation == "Touch Only" or
                  retestConfirmation == "Close Outside" and close > orbHi or
                  retestConfirmation == "Rejection Candle" and longRejection)

            shortRetest = high >= orbLo and
                 (retestConfirmation == "Touch Only" or
                  retestConfirmation == "Close Outside" and close < orbLo or
                  retestConfirmation == "Rejection Candle" and shortRejection)

            if withinExpiry and longNotOverextended and breakSide == 1 and longRetest
                f_submit(i, 1, false, orbHi, orbLo, low, fvgTop, fvgBottom, "ORB Retest")
                array.set(retestArmedA, i, false)

            if withinExpiry and shortNotOverextended and breakSide == -1 and shortRetest
                f_submit(i, -1, false, orbHi, orbLo, high, fvgTop, fvgBottom, "ORB Retest")
                array.set(retestArmedA, i, false)

            if not withinExpiry
                array.set(retestArmedA, i, false)

        // 4. FVG retest
        if entryModel == "Break + Retest FVG"
            fvgSide = array.get(fvgSideA, i)
            fvgBar = array.get(fvgBarA, i)

            fvgValid = fvgSide != 0 and
                 not na(fvgBar) and
                 bar_index - fvgBar <= fvgExpiryBars

            fvgLevel = fvgEntryLevel == "Near Edge" ?
                 (fvgSide == 1 ? fvgTop : fvgBottom) :
                 fvgEntryLevel == "Midpoint" ?
                 (fvgTop + fvgBottom) / 2.0 :
                 (fvgSide == 1 ? fvgBottom : fvgTop)

            fvgTouched = fvgValid and low <= fvgLevel and high >= fvgLevel

            if fvgTouched and fvgSide == 1
                f_submit(i, 1, false, orbHi, orbLo, fvgBottom, fvgTop, fvgBottom, "FVG Retest")
                array.set(fvgSideA, i, 0)

            if fvgTouched and fvgSide == -1
                f_submit(i, -1, false, orbHi, orbLo, fvgTop, fvgTop, fvgBottom, "FVG Retest")
                array.set(fvgSideA, i, 0)

            if fvgSide != 0 and not fvgValid
                array.set(fvgSideA, i, 0)

        // 5. Sweep reversal
        sweepHigh = high > orbHi + longBuffer and close < orbHi
        sweepLow = low < orbLo - shortBuffer and close > orbLo

        highRejection = sweepHigh and close < open
        lowRejection = sweepLow and close > open

        if entryModel == "Sweep Reversal"
            validHighSweep = sweepConfirmation == "Close Back Inside" ? sweepHigh : highRejection
            validLowSweep = sweepConfirmation == "Close Back Inside" ? sweepLow : lowRejection

            if validHighSweep
                f_submit(i, -1, true, orbHi, orbLo, high, fvgTop, fvgBottom, "High Sweep")

            if validLowSweep
                f_submit(i, 1, true, orbHi, orbLo, low, fvgTop, fvgBottom, "Low Sweep")

        // 6. Fade first breakout
        if entryModel == "Fade First Breakout" and not array.get(firstBreakConsumedA, i)
            side = array.get(firstBreakSideA, i)
            firstBar = array.get(firstBreakBarA, i)
            firstExtreme = array.get(firstBreakExtremeA, i)

            withinFailureWindow = not na(firstBar) and bar_index - firstBar <= failureTimeoutBars
            highExtensionOk = side == 1 and firstExtreme <= orbHi + orbRange * maxExtensionOrb
            lowExtensionOk = side == -1 and firstExtreme >= orbLo - orbRange * maxExtensionOrb

            failedHigh = side == 1 and close < orbHi and withinFailureWindow and highExtensionOk
            failedLow = side == -1 and close > orbLo and withinFailureWindow and lowExtensionOk

            if failedHigh
                f_submit(i, -1, true, orbHi, orbLo, firstExtreme, fvgTop, fvgBottom, "Fade First High Break")
                array.set(firstBreakConsumedA, i, true)

            if failedLow
                f_submit(i, 1, true, orbHi, orbLo, firstExtreme, fvgTop, fvgBottom, "Fade First Low Break")
                array.set(firstBreakConsumedA, i, true)

        // 7. First-break decision tree
        if entryModel == "First-Break Decision Tree" and not array.get(firstBreakConsumedA, i)
            side = array.get(firstBreakSideA, i)
            firstBar = array.get(firstBreakBarA, i)
            firstExtreme = array.get(firstBreakExtremeA, i)

            withinFailureWindow = not na(firstBar) and bar_index - firstBar <= failureTimeoutBars

            longContinuation = side == 1 and
                 (decisionTreeContinuation == "Touch" ? longTouch :
                  decisionTreeContinuation == "Close Outside" ? longClose :
                  low <= orbHi and close > orbHi)

            shortContinuation = side == -1 and
                 (decisionTreeContinuation == "Touch" ? shortTouch :
                  decisionTreeContinuation == "Close Outside" ? shortClose :
                  high >= orbLo and close < orbLo)

            failedHigh = side == 1 and close < orbHi and bar_index > firstBar and withinFailureWindow
            failedLow = side == -1 and close > orbLo and bar_index > firstBar and withinFailureWindow

            if longContinuation
                f_submit(i, 1, false, orbHi, orbLo, low, fvgTop, fvgBottom, "Decision: Continuation")
                array.set(firstBreakConsumedA, i, true)

            else if shortContinuation
                f_submit(i, -1, false, orbHi, orbLo, high, fvgTop, fvgBottom, "Decision: Continuation")
                array.set(firstBreakConsumedA, i, true)

            else if failedHigh
                f_submit(i, -1, true, orbHi, orbLo, firstExtreme, fvgTop, fvgBottom, "Decision: Failed High")
                array.set(firstBreakConsumedA, i, true)

            else if failedLow
                f_submit(i, 1, true, orbHi, orbLo, firstExtreme, fvgTop, fvgBottom, "Decision: Failed Low")
                array.set(firstBreakConsumedA, i, true)

// Detect a newly filled resting touch order on the next strategy calculation.
// The OCA group cancels competing touch orders immediately.
newTouchFill = entryModel == "Breakout (Touch)" and strategy.position_size != 0 and strategy.position_size[1] == 0
if newTouchFill
    filledId = strategy.opentrades.entry_id(0)
    filledDirection = strategy.position_size > 0 ? 1 : -1
    filledOrb = str.contains(filledId, "ORB1") ? 0 : str.contains(filledId, "ORB2") ? 1 : 2

    if filledDirection == 1
        array.set(gActiveStop, 0, array.get(pendingLongStopA, filledOrb))
        array.set(gActiveTarget, 0, array.get(pendingLongTargetA, filledOrb))
        array.set(gEntryAtr, 0, array.get(pendingLongAtrA, filledOrb))
        array.set(gOriginalRisk, 0, array.get(pendingLongRiskA, filledOrb))
    else
        array.set(gActiveStop, 0, array.get(pendingShortStopA, filledOrb))
        array.set(gActiveTarget, 0, array.get(pendingShortTargetA, filledOrb))
        array.set(gEntryAtr, 0, array.get(pendingShortAtrA, filledOrb))
        array.set(gOriginalRisk, 0, array.get(pendingShortRiskA, filledOrb))

    array.set(gBestClose, 0, strategy.position_avg_price)
    array.set(gActiveEntryBar, 0, bar_index)
    array.set(gActiveOrbIndex, 0, filledOrb)
    array.set(gActiveDirection, 0, filledDirection)
    array.set(gActiveEntryId, 0, filledId)
    f_markEntry(filledOrb, filledDirection)

    // Once one side fills, cancel every other unfilled touch order.
    for j = 0 to 2
        longId = "ORB" + str.tostring(j + 1) + "-L"
        shortId = "ORB" + str.tostring(j + 1) + "-S"
        if longId != filledId
            strategy.cancel(longId)
        if shortId != filledId
            strategy.cancel(shortId)
        array.set(pendingLongArmedA, j, false)
        array.set(pendingShortArmedA, j, false)

    if showSignals
        label.new(
             bar_index,
             filledDirection == 1 ? low : high,
             array.get(namesA, filledOrb) + "\nBreakout Touch Fill",
             style = filledDirection == 1 ? label.style_label_up : label.style_label_down,
             color = filledDirection == 1 ? color.new(color.green, 15) : color.new(color.red, 15),
             textcolor = color.white)

// Cancel unfilled touch entries at the entry cutoff.
if entryModel == "Breakout (Touch)" and not beforeEntryCutoff and strategy.position_size == 0
    for j = 0 to 2
        strategy.cancel("ORB" + str.tostring(j + 1) + "-L")
        strategy.cancel("ORB" + str.tostring(j + 1) + "-S")
        array.set(pendingLongArmedA, j, false)
        array.set(pendingShortArmedA, j, false)

// ─────────────────────────────────────────────────────────────────────────────
// 12. ACTIVE POSITION MANAGEMENT
// ─────────────────────────────────────────────────────────────────────────────
if strategy.position_size != 0
    isLong = strategy.position_size > 0
    avgEntry = strategy.position_avg_price

    array.set(
         gBestClose,
         0,
         isLong ?
          math.max(nz(array.get(gBestClose, 0), close), close) :
          math.min(nz(array.get(gBestClose, 0), close), close))

    if useBreakEven and array.get(gOriginalRisk, 0) > 0
        breakEvenActivated = isLong ?
             high >= avgEntry + array.get(gOriginalRisk, 0) * breakEvenAtR :
             low <= avgEntry - array.get(gOriginalRisk, 0) * breakEvenAtR

        if breakEvenActivated
            breakEvenStop = isLong ?
                 avgEntry + breakEvenOffsetTicks * syminfo.mintick :
                 avgEntry - breakEvenOffsetTicks * syminfo.mintick

            array.set(
                 gActiveStop,
                 0,
                 isLong ?
                  math.max(array.get(gActiveStop, 0), breakEvenStop) :
                  math.min(array.get(gActiveStop, 0), breakEvenStop))

    if useBarCloseTrail and barstate.isconfirmed and array.get(gOriginalRisk, 0) > 0
        trailActivated = isLong ?
             array.get(gBestClose, 0) >= avgEntry + array.get(gOriginalRisk, 0) * trailActivationR :
             array.get(gBestClose, 0) <= avgEntry - array.get(gOriginalRisk, 0) * trailActivationR

        if trailActivated
            trailCandidate = isLong ?
                 array.get(gBestClose, 0) - array.get(gEntryAtr, 0) * trailAtrMult :
                 array.get(gBestClose, 0) + array.get(gEntryAtr, 0) * trailAtrMult

            array.set(
                 gActiveStop,
                 0,
                 isLong ?
                  math.max(array.get(gActiveStop, 0), trailCandidate) :
                  math.min(array.get(gActiveStop, 0), trailCandidate))

    activeDirection = isLong ? 1 : -1
    modeledActiveStop = f_chartStop(activeDirection, array.get(gActiveStop, 0))

    strategy.exit(
         "X-" + array.get(gActiveEntryId, 0),
         from_entry = array.get(gActiveEntryId, 0),
         stop = modeledActiveStop,
         limit = array.get(gActiveTarget, 0))

    if timeExitBars > 0 and not na(array.get(gActiveEntryBar, 0)) and bar_index - array.get(gActiveEntryBar, 0) >= timeExitBars
        strategy.close(array.get(gActiveEntryId, 0), comment = "Time Exit")

if strategy.position_size == 0 and strategy.position_size[1] != 0
    array.set(gActiveStop, 0, na)
    array.set(gActiveTarget, 0, na)
    array.set(gOriginalRisk, 0, na)
    array.set(gEntryAtr, 0, na)
    array.set(gBestClose, 0, na)
    array.set(gActiveEntryBar, 0, na)
    array.set(gActiveOrbIndex, 0, na)
    array.set(gActiveDirection, 0, 0)
    array.set(gActiveEntryId, 0, "")

// Force close.
if forceCloseEnabled and localMinutes >= forceCloseMinutes and strategy.position_size != 0
    strategy.close_all(comment = "Force Close")

// ─────────────────────────────────────────────────────────────────────────────
// 13. PLOTS / DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
plot(useEmaBias ? ema : na, "EMA Bias", color = color.orange)
plot(useVwapBias ? vwap : na, "VWAP Bias", color = color.purple)

plot(
     strategy.position_size != 0 ? array.get(gActiveStop, 0) : na,
     "Active Stop",
     color = color.red,
     style = plot.style_linebr,
     linewidth = 2)

plot(
     strategy.position_size != 0 ? array.get(gActiveTarget, 0) : na,
     "Active Target",
     color = color.green,
     style = plot.style_linebr,
     linewidth = 2)

var table dashboard = table.new(position.top_right, 2, 9, border_width = 1)

if showDashboard and barstate.islast
    table.cell(dashboard, 0, 0, "ORB Laboratory", bgcolor = color.new(color.blue, 65), text_color = color.white)
    table.cell(dashboard, 1, 0, "v1.0.11", bgcolor = color.new(color.blue, 65), text_color = color.white)

    table.cell(dashboard, 0, 1, "Entry Model")
    table.cell(dashboard, 1, 1, entryModel)

    table.cell(dashboard, 0, 2, "Daily Entries")
    table.cell(dashboard, 1, 2, str.tostring(array.get(gDailyEntries, 0)) + " / " + str.tostring(maxEntriesPerDay))

    table.cell(dashboard, 0, 3, "Planned Risk")
    table.cell(dashboard, 1, 3, "$" + str.tostring(array.get(gDailyPlannedRiskUsd, 0), "#.##"))

    table.cell(dashboard, 0, 4, "EMA Bias")
    table.cell(dashboard, 1, 4, useEmaBias ? (close > ema ? "Bull" : "Bear") : "Off")

    table.cell(dashboard, 0, 5, "VWAP Bias")
    table.cell(dashboard, 1, 5, useVwapBias ? (close > vwap ? "Bull" : "Bear") : "Off")

    table.cell(dashboard, 0, 6, "Previous Close")
    table.cell(dashboard, 1, 6, str.tostring(prevClose, format.mintick))

    table.cell(dashboard, 0, 7, "Position")
    table.cell(
         dashboard,
         1,
         7,
         strategy.position_size > 0 ? "Long" :
          strategy.position_size < 0 ? "Short" :
          "Flat")

    table.cell(dashboard, 0, 8, "Entry Cutoff")
    table.cell(
         dashboard,
         1,
         8,
         str.format("{0,number,00}:{1,number,00}", noEntryHour, noEntryMinute))
````
