# SMT Sniper Entry Engine [trade_w_samet]

- url: https://www.tradingview.com/script/JsUS8DhM-SMT-Sniper-Entry-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;410d7f994b5243378141d904fe85e258
- version: 2.0

## Description

🎯 SMT Sniper Entry Engine [trade_w_samet]

SMT Sniper Entry Engine [trade_w_samet] is a structured correlated-market divergence and confirmation indicator designed to help traders study liquidity sweeps, SMT divergence, reclaim quality, pair correlation, external-range location, displacement, Fair Value Gap evidence, micro-structure confirmation, and permanent bar-close UP or DOWN signals through one coordinated workflow.

The script is built around one central idea:

An SMT divergence should not automatically become an entry signal.

Instead of treating every difference between two correlated markets as equally meaningful, the engine first identifies a one-market liquidity sweep, then evaluates reclaim behavior, ATR-normalized sweep depth, candle direction, rejection quality, range expansion, pair correlation, external-range location, and divergence separation before the SMT event is accepted.

A qualified SMT event still does not create an immediate final signal.

The accepted SMT event arms a temporary confirmation sequence.

The engine then waits for directional displacement, a confirmed break of the SMT candle, and the additional evidence required by the active Engine Preset before a permanent UP or DOWN label is printed.

The indicator includes:

• Automatic comparison-symbol selection for supported metals, indices, cryptocurrencies, forex majors, and common forex crosses
• Manual comparison-symbol mode
• Same-timeframe comparison-market data
• Closed-bar rolling liquidity references
• Current-bar-close SMT divergence detection
• Either-market sweep acceptance
• Same-bar liquidity reclaim validation
• ATR-normalized sweep-depth measurement
• Chart-candle direction filtering
• Rejection-close filtering
• Minimum range-expansion filtering
• Separate bullish and bearish 0–100 Base Quality Scores
• Log-return pair-correlation analysis
• External-range location filtering
• ATR-normalized divergence-separation analysis
• Separate bullish and bearish 0–100 Sniper Scores
• Standard, Sniper, and Elite Engine Presets
• A temporary eight-bar confirmation window
• Sequential evidence accumulation across separate closed candles
• Directional displacement confirmation
• SMT-candle break confirmation
• Fair Value Gap confirmation
• Micro-structure break confirmation
• ATR-buffered setup invalidation
• Setup expiration
• Directional SMT cooldown
• Final signal cooldown
• One final UP or DOWN signal per completed SMT sequence
• Minimal historical SMT markers
• Dotted historical SMT reference lines
• Blue UP and orange DOWN labels
• Adjustable UP / DOWN label size
• Signal-confirming FVG boxes
• Recent-only chart-object 
• A premium bottom-right dashboard
• Static TradingView alert conditions
• Combined dynamic alert() support
• “Any alert() function call” compatibility
• Data Window diagnostics
• Confirmed-close permanent signals
• No pivot functions
• No future-bar confirmation
• No historical signal backplotting

The purpose of this script is to provide a structured way to study when a correlated-market divergence is supported by sufficient liquidity, correlation, location, reaction, and confirmation evidence.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable trades.
It does not execute broker orders.
It does not calculate position size.
It does not include a built-in TP / SL trade-management engine.
It does not provide verified win-rate or profitability statistics.
It does not replace independent analysis, execution planning, or risk management.

[image]https://www.tradingview.com/x/hdyBRGZp/[/image]

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, SMT Sniper Entry Engine does the following:

• Selects a comparison market automatically or manually.
• Requests the comparison market’s open, high, low, close, and ATR data on the chart timeframe.
• Builds rolling liquidity references from already completed candles.
• Checks whether only one market swept its corresponding liquidity reference.
• Requires the sweeping market to reclaim the reference on the same completed candle.
• Measures sweep depth relative to ATR.
• Evaluates chart-candle direction.
• Evaluates the candle’s closing position.
• Evaluates minimum range expansion relative to ATR.
• Produces separate bullish and bearish 0–100 Base Quality Scores.
• Measures the relationship between chart and comparison-market returns.
• Evaluates whether bullish SMT appears near the lower portion of the external range.
• Evaluates whether bearish SMT appears near the upper portion of the external range.
• Measures how clearly the non-sweeping market held its own liquidity reference.
• Produces separate bullish and bearish 0–100 Sniper Scores.
• Applies Standard, Sniper, or Elite acceptance thresholds.
• Confirms a qualified SMT event only after the current candle closes.
• Arms a temporary sequential confirmation window.
• Accumulates displacement, SMT-candle break, FVG, and structure evidence.
• Invalidates the setup if price closes beyond the SMT extreme by the stored ATR buffer.
• Expires the setup when confirmation does not arrive inside the available window.
• Applies final signal cooldown protection.
• Prints a permanent blue UP or orange DOWN label only after every required condition is confirmed.
• Optionally draws the FVG associated with the final signal.
• Displays current engine state, comparison symbol, correlation, active score, and signal counts in the dashboard.
• Provides separate static alert conditions.
• Provides one combined dynamic final-signal alert workflow.
• Exposes internal diagnostic values through TradingView’s Data Window.

The indicator does not use machine-learning prediction.

Its scores are not probabilities.

Its signal counts are not wins and losses.

Its labels do not promise future direction.

The script is a rule-based educational framework that explains how a raw correlated-market divergence becomes an accepted, rejected, invalidated, expired, or finally confirmed setup.


━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind SMT Sniper Entry Engine is that two markets with a meaningful positive relationship do not always take corresponding liquidity at the same time.

When one market trades beyond a prior liquidity reference while the other market holds its own reference, the difference can create an SMT divergence.

However, the divergence alone contains limited information.

A basic SMT event does not automatically explain:

• whether the sweep was meaningful relative to volatility
• whether the sweeping market reclaimed the reference
• whether the chart candle closed with directional rejection
• whether the candle range expanded enough to matter
• whether the selected markets remain sufficiently correlated
• whether the event occurred near a useful external-range location
• whether the non-sweeping market clearly held its own level
• whether price produced directional displacement afterward
• whether the SMT candle was actually broken
• whether an FVG or micro-structure break confirmed the reaction
• whether the setup remained valid during the confirmation window
• whether another recent final signal is still inside the cooldown period

The engine therefore uses a staged sequence:

comparison-market selection
→ closed-bar liquidity references
→ one-market sweep
→ same-bar reclaim
→ Base Quality Score
→ pair-correlation validation
→ external-range location
→ divergence-separation validation
→ Sniper Score
→ confirmed SMT event
→ temporary setup arming
→ sequential reaction evidence
→ invalidation or expiration control
→ permanent UP or DOWN signal

For bullish conditions, the engine studies prior-low liquidity, bullish rejection, lower external-range location, directional displacement, a close above the SMT candle high, and bullish confirmation evidence.

For bearish conditions, the same process is mirrored around prior highs.

The purpose is not to produce the largest possible number of signals.

The purpose is to make the acceptance process selective, visible, and understandable.


━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

SMT Sniper Entry Engine is not designed to be used as a blind signal generator.

A raw correlated-market divergence must move through multiple stages:

One market sweeps liquidity
→ the comparison market does not make the same sweep
→ the sweeping market reclaims its reference
→ sweep depth is evaluated
→ chart-candle direction is checked
→ rejection-close quality is checked
→ range expansion is checked
→ the Base Quality Score is calculated
→ pair correlation is checked
→ external-range location is checked
→ divergence separation is checked
→ the Sniper Score is calculated
→ the SMT event is accepted
→ the confirmation window opens
→ directional displacement is accumulated
→ the SMT candle must be broken
→ FVG and/or micro-structure evidence is accumulated
→ the setup must avoid invalidation
→ the setup must confirm before expiration
→ the final UP or DOWN label appears

Each module serves a different purpose.

The comparison engine defines the external market used for SMT analysis.

The liquidity engine identifies the one-market sweep.

The reclaim engine checks whether the liquidity event closed back inside the reference.

The Base Quality Score evaluates the completed SMT candle.

The Sniper Context Engine evaluates correlation, location, separation, and sweep quality.

The sequential confirmation engine evaluates what price does after the SMT event.

The invalidation and expiration controls remove setups that no longer satisfy the intended sequence.

The dashboard explains the current engine state.

This makes the script a coordinated SMT-confirmation workflow rather than a simple divergence marker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script operates through connected calculation stages.

First, the engine selects a comparison symbol.

Auto mode uses the built-in symbol matrix.

Manual mode uses the symbol selected by the user.

The comparison market is requested on the same timeframe as the chart.

[pine]
[comparisonOpen, comparisonHigh, comparisonLow, comparisonClose, comparisonAtr] = request.security(
     comparisonSymbol,
     timeframe.period,
     [open, high, low, close, ta.atr(atrLength)],
     gaps                  = barmerge.gaps_off,
     lookahead             = barmerge.lookahead_off,
     ignore_invalid_symbol = true)
[/pine]

The request uses lookahead_off.

The engine then calculates rolling chart and comparison-market liquidity references while excluding the current candle.

[pine]
float chartPriorLow = ta.lowest(low[1], referenceLookback)
float chartPriorHigh = ta.highest(high[1], referenceLookback)
float comparisonPriorLow = ta.lowest(comparisonLow[1], referenceLookback)
float comparisonPriorHigh = ta.highest(comparisonHigh[1], referenceLookback)
[/pine]

The default reference lookback is 12 bars.

A bullish divergence is possible when one market sweeps a prior low and the other market does not.

A bearish divergence is possible when one market sweeps a prior high and the other market does not.

The sweeping market must reclaim the level on the same completed candle.

The candidate is then evaluated through:

• ATR-normalized sweep depth
• chart-candle direction
• close location
• range expansion
• Base Quality Score
• pair correlation
• external-range location
• divergence separation
• Sniper Score
• directional cooldown

When the SMT event is accepted, the engine stores:

• setup direction
• SMT bar
• SMT extreme
• SMT reaction trigger
• current ATR
• Base Quality Score
• Sniper Score
• sequential evidence states
• first confirmed FVG coordinates

The engine then monitors the next closed candles.

A final signal is accepted only when the active preset’s required evidence is present and the setup has not invalidated or expired.


━━━━━━━━━━━━━━━━━━━━━━
🟢 BULLISH SMT LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bullish SMT candidate begins at prior lows.

The engine checks the chart symbol and comparison market together.

A bullish sweep divergence exists when either:

• the chart symbol trades below its prior low while the comparison market does not trade below its corresponding prior low
• the comparison market trades below its prior low while the chart symbol does not trade below its corresponding prior low

The engine accepts a sweep from either market.

The sweeping market must reclaim the prior-low reference when reclaim validation is active.

The completed chart candle must also satisfy the active quality requirements.

The default Sniper profile evaluates:

• sufficient ATR-normalized sweep depth
• bullish chart-candle direction
• a close in the stronger portion of the candle
• minimum candle-range expansion
• minimum Base Quality Score
• minimum positive pair correlation
• location near the lower portion of the external range
• minimum divergence separation
• minimum Sniper Score
• directional SMT cooldown availability

[pine]
bool bullishSmtEvent =
     bullishRawSmtCandidate and
     bullishSniperPass and
     bullishCooldownPass
[/pine]

When the bullish SMT event is confirmed, the engine stores:

• the SMT low as the bullish invalidation extreme
• the SMT high as the bullish reaction-break trigger
• the current ATR
• the current Base Quality Score
• the current Sniper Score

The confirmation sequence then waits for:

• bullish displacement
• a close above the SMT candle high
• FVG and/or micro-structure evidence according to the active preset

The bullish SMT marker is context.

The final blue UP label is the completed signal.


━━━━━━━━━━━━━━━━━━━━━━
🔴 BEARISH SMT LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bearish SMT candidate begins at prior highs.

A bearish sweep divergence exists when either:

• the chart symbol trades above its prior high while the comparison market does not trade above its corresponding prior high
• the comparison market trades above its prior high while the chart symbol does not trade above its corresponding prior high

The sweeping market must reclaim the prior-high reference when reclaim validation is active.

The completed chart candle must also satisfy the active quality requirements.

The default Sniper profile evaluates:

• sufficient ATR-normalized sweep depth
• bearish chart-candle direction
• a close in the weaker portion of the candle
• minimum candle-range expansion
• minimum Base Quality Score
• minimum positive pair correlation
• location near the upper portion of the external range
• minimum divergence separation
• minimum Sniper Score
• directional SMT cooldown availability

When the bearish SMT event is confirmed, the engine stores:

• the SMT high as the bearish invalidation extreme
• the SMT low as the bearish reaction-break trigger
• the current ATR
• the current Base Quality Score
• the current Sniper Score

The confirmation sequence then waits for:

• bearish displacement
• a close below the SMT candle low
• FVG and/or micro-structure evidence according to the active preset

The bearish SMT marker is context.

The final orange DOWN label is the completed signal.


━━━━━━━━━━━━━━━━━━━━━━
💎 SMT QUALITY FILTER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script calculates separate bullish and bearish Base Quality Scores.

The score evaluates the completed SMT candle and its underlying liquidity event.

Each score is limited to 0–100.

The components are:

Sweep Role — maximum 25 points

The event must contain a valid one-market liquidity sweep.

Only one market should take the corresponding prior high or prior low.

Reclaim — maximum 20 points

The sweeping market must close back inside its prior liquidity reference.

Sweep Depth — maximum 20 points

The distance beyond the reference is measured relative to the corresponding market’s ATR.

Chart Candle Direction — maximum 15 points

Bullish SMT prefers a bullish chart candle.

Bearish SMT prefers a bearish chart candle.

Rejection Close — maximum 10 points

Bullish SMT prefers the chart close toward the high of the candle.

Bearish SMT prefers the chart close toward the low.

Range Expansion — maximum 10 points

The chart candle’s total range is compared with chart ATR.

The total score structure is:

25 + 20 + 20 + 15 + 10 + 10 = 100 points.

Preset-dependent minimum Base Quality Scores are:

• Standard: 60
• Sniper: 75
• Elite: 85

The Base Quality Score is not a win rate.

It is not a probability.

It measures how closely the completed SMT event matches the engine’s liquidity and candle-quality framework.


━━━━━━━━━━━━━━━━━━━━━━
📏 VOLATILITY / ATR NORMALIZATION FILTER
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses ATR normalization to compare distances across changing volatility conditions.

ATR normalization is applied to:

• chart-side sweep depth
• comparison-side sweep depth
• divergence separation
• displacement body size
• setup invalidation buffer
• chart-candle range expansion

Sweep depth is calculated in relation to the ATR of the market that performed the sweep.

For example:

Chart Sweep Depth = distance beyond chart reference / chart ATR.

Comparison Sweep Depth = distance beyond comparison reference / comparison ATR.

Preset-dependent minimum sweep depth is:

• Standard: 0.04 ATR
• Sniper: 0.10 ATR
• Elite: 0.18 ATR

The chart candle must also meet a minimum range-to-ATR requirement:

• Standard: 0.40 ATR
• Sniper: 0.60 ATR
• Elite: 0.85 ATR

The setup invalidation buffer is based on the ATR stored when the SMT event occurs.

The default buffer is 0.10 ATR beyond the SMT extreme.

ATR normalization helps reduce dependence on raw price units.

It does not make one configuration universal.

Different symbols, sessions, data feeds, and market conditions can still produce different behavior.


━━━━━━━━━━━━━━━━━━━━━━
🕯️ DISPLACEMENT QUALITY FILTER
━━━━━━━━━━━━━━━━━━━━━━

After an SMT event is accepted, the engine requires directional displacement before a final signal can appear.

A bullish displacement candle requires:

• a confirmed closed candle
• close above open
• body size of at least 0.45 ATR
• body-to-range ratio of at least 0.55
• upper wick no greater than 0.35 of the full candle range

A bearish displacement candle requires:

• a confirmed closed candle
• close below open
• body size of at least 0.45 ATR
• body-to-range ratio of at least 0.55
• lower wick no greater than 0.35 of the full candle range

[pine]
bool bullishDisplacement =
     barstate.isconfirmed and
     close > open and
     signalCandleBody >= chartAtr * displacementBodyAtr and
     signalBodyRatio >= displacementBodyPercent and
     bullishOppositeWickRatio <= maximumOppositeWickPercent and
     bullishPreviousBreakPass
[/pine]

The bearish process is mirrored.

The previous-bar break option is disabled in the locked default engine.

The more important directional reaction requirement is the SMT-candle break.

Displacement confirms that the market produced a completed directional response after the SMT event.

It does not guarantee continuation.


━━━━━━━━━━━━━━━━━━━━━━
📊 REACTION STRENGTH FILTER
━━━━━━━━━━━━━━━━━━━━━━

The engine does not require every confirmation component to appear on the same candle.

Instead, reaction evidence can accumulate across separate closed candles inside the temporary confirmation window.

The engine tracks:

• displacement
• SMT-candle break
• Fair Value Gap
• micro-structure break

Bullish SMT-candle break:

• price must close above the stored SMT candle high

Bearish SMT-candle break:

• price must close below the stored SMT candle low

Bullish FVG:

• current low is above the high from two bars earlier

Bearish FVG:

• current high is below the low from two bars earlier

Bullish micro-structure break:

• current close exceeds the highest high from the previous five closed bars

Bearish micro-structure break:

• current close falls below the lowest low from the previous five closed bars

Evidence is persistent while the setup remains active.

For example:

SMT event
→ displacement appears
→ FVG appears later
→ structure break appears on another candle
→ final signal confirms

The active Engine Preset determines which accumulated evidence is required.


━━━━━━━━━━━━━━━━━━━━━━
🧼 CONFIRMED SIGNAL FILTER
━━━━━━━━━━━━━━━━━━━━━━

Permanent SMT events and final UP / DOWN labels wait for candle close.

The engine uses confirmed-bar checks for:

• raw SMT candidates
• final SMT acceptance
• displacement
• FVG detection
• micro-structure breaks
• setup invalidation
• final UP signals
• final DOWN signals

The comparison-market request uses lookahead_off.

Rolling liquidity references exclude the current candle.

No future candle is used to decide whether the current candle contains an SMT event.

No final signal is plotted back onto the original SMT candle after later evidence becomes available.

The confirmation opportunity is temporary.

The default window is eight bars.

The minimum delay is one bar after the SMT event.

If the active evidence does not complete in time, the setup expires.

Historical output can still change when:

• Engine Preset changes
• comparison symbol changes
• Auto or Manual mode changes
• chart symbol changes
• timeframe changes
• exchange or broker feed changes
• historical data is revised
• the loaded history range changes

Confirmed-close logic prevents unfinished-candle conditions from becoming permanent chart signals.

It does not mean all brokers or data feeds will produce identical historical output.


━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY MODEL
━━━━━━━━━━━━━━━━━━━━━━

SMT Sniper Entry Engine uses a confirmed-signal entry model rather than a built-in broker-order model.

A final directional setup is created only when:

• a qualified SMT event exists
• the confirmation window is open
• the setup has not invalidated
• all preset-required evidence has been accumulated
• final signal cooldown is available
• the current candle is confirmed

The final signal reference is the close of the candle where the UP or DOWN label is printed.

For an UP setup:

• the label appears below the confirmed signal candle
• the signal represents completed bullish SMT confirmation

For a DOWN setup:

• the label appears above the confirmed signal candle
• the signal represents completed bearish SMT confirmation

The script does not automatically calculate:

• an entry line
• a stop-loss level
• take-profit targets
• position size
• account risk
• broker quantity
• trade outcome

The final signal-bar close can be used as an analytical reference.

It is not a guaranteed fill.

Users must define their own execution, invalidation, stop, target, and risk model.


━━━━━━━━━━━━━━━━━━━━━━
🔗 COMPARISON MARKET MODEL
━━━━━━━━━━━━━━━━━━━━━━

The indicator supports Auto and Manual comparison-symbol modes.

Auto mode recognizes common ticker text and assigns a predefined positively related market.

Built-in mappings include:

Metals

• XAU or GOLD → OANDA:XAGUSD
• XAG or SILVER → OANDA:XAUUSD

Indices

• NAS, US100, USTEC, NDX, or NQ → OANDA:SPX500USD
• SPX, US500, SP500, or ES → OANDA:NAS100USD
• US30, DJI, DOW, or YM → OANDA:SPX500USD

Cryptocurrencies

• BTC → BINANCE:ETHUSDT
• ETH → BINANCE:BTCUSDT

Forex majors

• EURUSD ↔ GBPUSD
• AUDUSD ↔ NZDUSD
• USDCAD ↔ USDCHF
• USDJPY → CADJPY

JPY crosses

• EURJPY ↔ GBPJPY
• AUDJPY ↔ NZDJPY
• CADJPY → USDJPY
• CHFJPY → EURJPY

EUR and GBP crosses

• EURAUD ↔ GBPAUD
• EURNZD ↔ GBPNZD
• EURCAD ↔ GBPCAD
• EURCHF ↔ GBPCHF
• EURGBP → GBPUSD

AUD and NZD crosses

• AUDCAD ↔ NZDCAD
• AUDCHF ↔ NZDCHF
• AUDNZD → NZDUSD

Auto mode is based on ticker-name recognition.

Broker symbols can include prefixes, suffixes, futures contract codes, or synthetic names that are not recognized by the built-in matrix.

When the chart symbol is not recognized, the engine can fall back to the Manual Comparison Symbol value.

The dashboard should therefore be checked before relying on Auto mode.

Manual mode allows the user to select the comparison market directly.

The current engine is designed for positively correlated relationships.

Selecting an inversely related market can make the correlation and SMT logic unsuitable.


━━━━━━━━━━━━━━━━━━━━━━
🎯 SNIPER SCORE MODEL
━━━━━━━━━━━━━━━━━━━━━━

The engine produces separate bullish and bearish Sniper Scores.

The Sniper Score evaluates broader context around the SMT event.

The maximum score is 100.

The structure is:

Base SMT Quality — maximum 35 points

The 0–100 Base Quality Score contributes 35% of its value.

Pair Correlation — maximum 25 points

Positive effective correlation contributes proportionally.

External-Range Location — maximum 20 points

Bullish SMT receives this component when it occurs below the active maximum bullish range position.

Bearish SMT receives this component when it occurs above the active minimum bearish range position.

Divergence Separation — maximum 10 points

The event receives this component when the non-sweeping market holds its reference by at least the required ATR-normalized distance.

Sweep Depth — maximum 10 points

A valid minimum sweep receives five points.

A sweep at least 1.5 times the minimum depth receives ten points.

Minimum accepted Sniper Scores are:

• Standard: 60
• Sniper: 78
• Elite: 88

Minimum positive pair correlation is:

• Standard: 0.35
• Sniper: 0.55
• Elite: 0.70

External-range requirements are:

Bullish maximum position

• Standard: 0.45
• Sniper: 0.33
• Elite: 0.25

Bearish minimum position

• Standard: 0.55
• Sniper: 0.67
• Elite: 0.75

Minimum divergence separation is:

• Standard: 0.00 ATR
• Sniper: 0.03 ATR
• Elite: 0.08 ATR

The Sniper Score is not a probability.

A score of 88 does not mean an 88% probability of success.

It measures rule-based confluence according to this script’s internal framework.


━━━━━━━━━━━━━━━━━━━━━━
📦 ACTIVE SMT / FVG VISUAL SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script separates SMT context from final signal confirmation.

Historical SMT visuals can include:

• a dotted line from the prior chart-side liquidity reference to the SMT candle
• a minimal bullish or bearish marker near the SMT event

The default historical visual system keeps recent objects only.

The default limits are:

• eight bullish SMT lines
• eight bullish SMT markers
• eight bearish SMT lines
• eight bearish SMT markers
• ten final signal labels
• six signal FVG boxes

Older visual objects can be removed when the corresponding recent-only limit is exceeded.

This is chart-object management.

It does not move a signal to another candle.

Final signal visuals include:

UP

• blue label
• white bold-italic text
• printed below the confirmed signal candle

DOWN

• orange label
• white bold-italic text
• printed above the confirmed signal candle

Signal FVG Box

• appears only when stored FVG evidence exists
• uses the FVG that participated in the active confirmation sequence
• extends 12 bars to the right
• uses a lightly shaded bullish or bearish fill

The FVG box is an analytical confirmation visual.

It is not a guaranteed support, resistance, entry, stop, or target zone.


━━━━━━━━━━━━━━━━━━━━━━
🚦 ONE ACTIVE SMT SETUP AT A TIME
━━━━━━━━━━━━━━━━━━━━━━

The script maintains one active pending SMT confirmation sequence at a time.

When a qualified bullish SMT event appears:

• the active setup direction becomes bullish
• the bullish SMT extreme and trigger are stored
• the evidence state is reset

When a qualified bearish SMT event appears:

• the active setup direction becomes bearish
• the bearish SMT extreme and trigger are stored
• the evidence state is reset

A newly accepted SMT event can therefore replace the currently stored pending setup state.

The active setup remains in memory until:

• the final UP signal confirms
• the final DOWN signal confirms
• the setup invalidates
• the setup expires
• another accepted SMT event overwrites the pending state

This design prevents multiple overlapping confirmation sequences from creating an unclear chart state.

It does not prevent the user from performing independent analysis on other markets or timeframes.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ SEQUENTIAL CONFIRMATION WINDOW HANDLING
━━━━━━━━━━━━━━━━━━━━━━

The default confirmation window is eight bars.

The final signal cannot appear on the original SMT candle because the minimum bars after SMT is one.

The engine monitors each completed candle inside the window.

Evidence can be accumulated in different orders.

For example:

SMT
→ displacement
→ SMT-candle break
→ FVG
→ final signal

or:

SMT
→ FVG
→ displacement
→ SMT-candle break
→ structure break
→ final signal

Preset behavior:

Standard

Uses Reactive confirmation.

Requires:

• displacement
• SMT-candle break

Sniper

Uses Confirmed confirmation.

Requires:

• displacement
• SMT-candle break
• FVG or micro-structure break

Elite

Uses Elite confirmation.

Requires:

• displacement
• SMT-candle break
• FVG
• micro-structure break

The engine does not use the historical high-low sequence inside a candle to simulate order execution.

It evaluates whether each closed candle satisfied a defined piece of evidence.

If the setup does not complete inside the window, it expires.


━━━━━━━━━━━━━━━━━━━━━━
🏷️ SMT SNIPER LABELS
━━━━━━━━━━━━━━━━━━━━━━

The indicator uses separate context and final-signal labels.

SMT Context Markers

The default SMT marker layout is Minimal.

Bullish SMT uses an upward marker.

Bearish SMT uses a downward marker.

The marker appears on the actual SMT confirmation candle.

Its tooltip can include:

• bullish or bearish SMT direction
• Sniper Score
• Base Quality Score
• effective pair correlation
• active comparison symbol

Final Signal Labels

The final labels display:

𝙐𝙋

or:

𝘿𝙊𝙒𝙉

UP uses a blue background.

DOWN uses an orange background.

The text is white.

Available final-label sizes are:

• Tiny
• Small
• Normal
• Large
• Huge

Normal is the default.

The UP tooltip can include:

• bullish SMT confirmation mode
• final stored Sniper Score
• final stored Base Quality Score

The DOWN tooltip contains the mirrored information.

The SMT marker and final signal label serve different purposes.

The SMT marker identifies the qualified correlated-market divergence.

The UP or DOWN label identifies the completed sequential confirmation.


━━━━━━━━━━━━━━━━━━━━━━
📍 SMT DISPLAY MODES
━━━━━━━━━━━━━━━━━━━━━━

The indicator operates directly on the main price chart.

The public Display settings provide control over:

Show SMT

Shows or hides historical SMT markers and reference lines.

Show UP / DOWN

Shows or hides final signal labels.

UP / DOWN Label Size

Controls the size of final UP and DOWN labels.

Show Signal FVG

Shows or hides the stored FVG box associated with a final signal.

Show Dashboard

Shows or hides the premium bottom-right dashboard.

The internal visual profile uses:

• Clean layout
• Recent Only historical display
• dotted SMT reference lines
• minimal SMT markers
• normal SMT marker size
• limited historical object counts
• no separate displacement circles by default

Input values are hidden from TradingView’s status line.

Diagnostic plots remain available in the Data Window without adding visible price-scale clutter.


━━━━━━━━━━━━━━━━━━━━━━
🧹 SETUP INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━

Not every accepted SMT event remains eligible.

A bullish setup invalidates when a completed candle closes below:

SMT low − stored SMT ATR × 0.10.

A bearish setup invalidates when a completed candle closes above:

SMT high + stored SMT ATR × 0.10.

The ATR value is stored when the SMT event appears.

This keeps the invalidation buffer linked to the volatility present when the setup was created.

A setup can also fail to produce a final signal because:

• the confirmation window expires
• displacement never appears
• the SMT candle is not broken
• required FVG evidence does not appear
• required structure evidence does not appear
• the final signal cooldown is active
• a newly accepted SMT event replaces the pending state

The directional SMT cooldown is 15 bars.

The final signal cooldown is eight bars.

A rejected, invalidated, or expired pending sequence does not print a final UP or DOWN label.


━━━━━━━━━━━━━━━━━━━━━━
📟 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The indicator includes a premium dashboard in the bottom-right corner of the chart.

The header displays:

trade_w_samet • SMT SNIPER

Current State

Possible states include:

• SCANNING MARKET
• BULLISH SMT DETECTED
• BEARISH SMT DETECTED
• BULLISH SETUP BUILDING
• BEARISH SETUP BUILDING
• UP SIGNAL CONFIRMED
• DOWN SIGNAL CONFIRMED

Comparison

Displays the active comparison symbol.

Correlation

Displays the current effective pair correlation.

Engine

Displays:

• STANDARD
• SNIPER
• ELITE

Pair Mode

Displays:

• AUTO
• MANUAL

Signal Score

When a relevant setup is active, the dashboard displays:

current Sniper Score / required Sniper Score.

When no setup is active, it displays:

NO ACTIVE SETUP.

UP / DOWN Counts

Displays the number of final confirmed UP and DOWN signals calculated on the loaded chart history.

Footer

Displays:

• BAR-CLOSE
• NON-REPAINT
• LIVE

The dashboard is not TradingView Strategy Tester.

It does not display:

• win rate
• profit factor
• expectancy
• drawdown
• net profit
• broker-verified results

UP and DOWN counts are signal counts only.

“LIVE” means the dashboard updates with the latest available script state.

It does not mean the script predicts unfinished intrabar outcomes.


━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

SMT Sniper Entry Engine includes static TradingView alert conditions for:

• Bullish SMT
• Bearish SMT
• UP
• DOWN
• Any Signal
• Any SMT

Bullish SMT

Triggers when a bullish SMT event passes the complete Base Quality and Sniper acceptance process.

Bearish SMT

Triggers when a bearish SMT event passes the mirrored acceptance process.

UP

Triggers when the bullish sequential confirmation process is complete.

DOWN

Triggers when the bearish sequential confirmation process is complete.

Any Signal

Combines final UP and DOWN conditions.

Any SMT

Combines bullish and bearish SMT conditions.

The script also includes dynamic alert() messages for final UP and DOWN signals.

Dynamic messages can include:

• product name
• direction
• chart ticker
• chart timeframe
• confirmed close price
• active comparison symbol

[pine]
if enableAlerts
    if buySignal
        alert(
             "SMT Sniper | UP | " +
             syminfo.ticker +
             " | " +
             timeframe.period +
             " | Close: " +
             str.tostring(close, format.mintick) +
             " | Comparison: " +
             comparisonSymbol,
             alert.freq_once_per_bar_close)
[/pine]

The DOWN dynamic message uses the mirrored format.

Dynamic final-signal alerts use once-per-bar-close frequency.

Alerts are monitoring tools.

They do not place, modify, or close broker orders.


━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

For separate static conditions:

1. Add SMT Sniper Entry Engine [trade_w_samet] to the chart.
2. Open TradingView’s Create Alert window.
3. Select SMT Sniper as the condition.
4. Choose Bullish SMT, Bearish SMT, UP, DOWN, Any Signal, or Any SMT.
5. Select the desired notification method.
6. Use a confirmed-bar frequency where appropriate.
7. Test the alert before relying on it.

For one combined dynamic final-signal alert:

1. Enable Alerts in the indicator settings.
2. Open TradingView’s Create Alert window.
3. Select SMT Sniper.
4. Select Any alert() function call.
5. Configure the delivery method.
6. Test the UP and DOWN message format.

The combined dynamic alert sends final UP and DOWN events through one TradingView alert.

Static Any Signal also combines UP and DOWN conditions, but uses the static alertcondition() message.

When indicator settings, code, symbol, or timeframe are materially changed, an already-created TradingView alert can continue using the script snapshot stored when that alert was created.

Recreate alerts after important configuration changes.

Alert delivery can depend on:

• TradingView servers
• selected symbol
• selected timeframe
• market-data availability
• realtime feed status
• symbol session
• user alert configuration
• webhook or external-service availability

Creating an alert does not guarantee broker execution.


━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add SMT Sniper Entry Engine [trade_w_samet] to a standard candlestick chart.
2. Begin with Engine Preset set to Sniper.
3. Keep Comparison Symbol Mode on Auto for supported symbols.
4. Review the Comparison field in the dashboard.
5. If the automatic market is not appropriate, switch to Manual.
6. Select a positively related comparison market.
7. Keep Show SMT enabled while learning the setup sequence.
8. Observe the historical liquidity reference line.
9. Observe the minimal SMT marker.
10. Treat the SMT marker as context, not as the final signal.
11. Watch the dashboard state.
12. Wait for a blue UP or orange DOWN label.
13. Review the active Sniper Score and required threshold.
14. Review the correlation value.
15. Review the signal FVG box when one is available.
16. Use alerts for monitoring rather than blind execution.
17. Evaluate broader market structure independently.
18. Review session conditions, volatility, spread, and news risk.
19. Define personal entry, invalidation, stop, target, and position-size rules.
20. Test the exact symbol, timeframe, exchange, broker feed, and comparison pair personally used.

The indicator is designed for structured review.

It should not be treated as an automatic decision-maker.


━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

The public settings menu is intentionally simplified.

Advanced thresholds remain locked inside the engine to reduce configuration clutter and preserve consistent preset behavior.

⚙️ Engine

Engine Preset

Selects:

• Standard
• Sniper
• Elite

Standard

Produces more accepted setups.

Uses Balanced Base Quality, Standard Sniper thresholds, and Reactive confirmation.

Sniper

The default profile.

Uses Strict Base Quality, Sniper context thresholds, and Confirmed evidence requirements.

Elite

The most selective profile.

Uses Elite Base Quality, Elite context thresholds, and the strictest sequential evidence requirement.

A stricter preset does not guarantee better trading results.

━━━━━━━━━━━━━━━━━━━━━━

🔗 Comparison Market

Comparison Symbol Mode

Auto

Uses the internal ticker-recognition matrix.

Manual

Uses the selected Manual Comparison Symbol.

Manual Comparison Symbol

Selects the external market used by the SMT engine.

This field is active only when Comparison Symbol Mode is Manual.

Use a positively related comparison market.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Display

Show SMT

Shows or hides historical SMT reference lines and markers.

Show UP / DOWN

Shows or hides final signal labels.

UP / DOWN Label Size

Selects:

• Tiny
• Small
• Normal
• Large
• Huge

Normal is the default.

Show Signal FVG

Shows or hides the stored FVG box associated with a final signal.

Show Dashboard

Shows or hides the bottom-right premium dashboard.

━━━━━━━━━━━━━━━━━━━━━━

🔔 Alerts

Enable Alerts

Enables the script’s static alert conditions and dynamic alert() calls.

For one combined runtime UP / DOWN alert, create the TradingView alert using:

Any alert() function call.

All public input values use hidden status-line display.

Diagnostic values remain available through TradingView’s Data Window.


━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

SMT divergence, liquidity sweeps, correlation, ATR, Fair Value Gaps, and structure breaks are familiar technical-analysis concepts.

These concepts are not unique by themselves.

The originality of SMT Sniper Entry Engine lies in the coordinated process applied to them:

automatic comparison-market selection
→ closed-bar rolling liquidity references
→ one-market liquidity sweep
→ same-bar reclaim
→ ATR-normalized Base Quality Score
→ log-return pair correlation
→ external-range location
→ ATR-normalized divergence separation
→ 0–100 Sniper Score
→ preset-driven SMT acceptance
→ temporary sequential confirmation
→ displacement evidence
→ SMT-candle break
→ FVG and micro-structure evidence
→ ATR-buffered invalidation
→ setup expiration
→ permanent UP or DOWN signal
→ recent-only visual management
→ static and dynamic alerts
→ premium diagnostic dashboard

Distinctive implementation features include:

• accepting a valid sweep from either market
• using rolling closed-bar references instead of pivot confirmation
• separating the SMT event from the final signal
• calculating separate Base Quality and Sniper Scores
• requiring positive pair correlation according to preset
• using preset-specific external-range thresholds
• measuring divergence separation relative to ATR
• accumulating confirmation evidence across separate candles
• storing the SMT candle as the reaction trigger
• storing ATR at the moment the setup is armed
• using different confirmation strictness for Standard, Sniper, and Elite
• limiting historical objects without relocating signals
• providing automatic comparison-market assistance with manual override
• supporting both static and combined dynamic alerts
• exposing detailed diagnostics through the Data Window

The script is not a simple combination of unrelated indicators.

Every module supports the same objective: determining whether a closed-bar SMT divergence has enough liquidity, correlation, location, reaction, and confirmation evidence to become a permanent final signal.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

Signal frequency depends on:

• Engine Preset
• chart symbol
• comparison symbol
• ticker naming
• timeframe
• session
• volatility
• pair correlation
• liquidity-reference structure
• sweep depth
• chart-candle quality
• external-range location
• divergence separation
• directional cooldown
• post-SMT displacement
• SMT-candle break
• FVG evidence
• micro-structure evidence
• final signal cooldown
• available history
• data provider

Standard can produce more setups.

Elite can produce substantially fewer setups.

Fewer signals do not guarantee better results.

The built-in Auto matrix uses predefined OANDA and BINANCE symbols.

The chart symbol can come from another broker or exchange.

Different feeds can produce:

• different highs and lows
• different candle closes
• different ATR values
• different liquidity sweeps
• different correlation readings
• different final signals

Manual mode can be used when comparison-feed consistency is important.

The current engine expects a positive relationship.

An inversely related comparison market should not be selected.

The dashboard’s UP and DOWN values are signal counts.

They are not wins and losses.

The Signal Score is a confluence score.

It is not historical accuracy.

The SMT marker is not the final signal.

The final UP or DOWN label appears after post-SMT confirmation.

Changing settings recalculates historical conditions.

Changing the comparison market can materially change the script’s output.


━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

It does not guarantee profitable trades.
It does not predict future price movement.
It does not execute orders.
It does not place broker stops.
It does not place take-profit orders.
It does not calculate position size.
It does not include spread.
It does not include commission.
It does not include slippage.
It does not include latency.
It does not model partial fills.
It does not model financing or swap.
It does not evaluate order-book conditions.
It does not evaluate news risk.
It uses bar-based OHLC data.
It does not reconstruct exact intrabar price sequence.
It assumes a positive comparison relationship.
Its automatic matrix cannot recognize every broker symbol.
Unsupported Auto symbols can use the Manual Comparison fallback.
Correlation can change over time.
A historically correlated pair can temporarily decouple.
A confirmed SMT divergence can fail.
A displacement candle can be followed by reversal.
An FVG can be filled immediately.
A micro-structure break can become a false break.
A high Base Quality Score can still fail.
A high Sniper Score can still fail.
The Signal Score is not a win probability.
The dashboard is not TradingView Strategy Tester.
Signal counts are not audited account performance.
The script does not provide verified profitability statistics.
The script does not provide broker-verified trade outcomes.
Alert delivery depends on TradingView and user configuration.
Changing settings changes historical calculations.
Changing symbol, exchange, session, timeframe, or feed can change signals.
Available history can affect rolling calculations.
Permanent final signals wait for candle close.
The final label can therefore appear later than a discretionary intrabar entry.

For these reasons, the indicator should be used as an educational decision-support tool, not as a standalone automated strategy.


━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• understand basic SMT divergence
• compare positively related markets
• study liquidity sweeps and reclaims
• want more context than a raw SMT marker
• prefer confirmed-close signals
• want selective preset modes
• use displacement as confirmation
• use Fair Value Gap concepts
• use micro-structure breaks
• want automatic comparison-market assistance
• want a manual comparison override
• want transparent quality scoring
• want a compact public settings menu
• want a premium dashboard
• want separate SMT and final-signal alerts
• want one combined UP / DOWN dynamic alert
• want Data Window diagnostics

It may be less suitable for users who:

• want guaranteed signals
• want every raw SMT divergence displayed
• want a fully automated trading bot
• want built-in TP and SL management
• want verified Strategy Tester performance
• want inverse-correlation SMT analysis
• expect one comparison pair to work on every feed
• require tick-level execution modeling
• want signals before candle close
• expect a score to equal probability
• want the indicator to replace personal judgment
• expect alerts to execute broker orders automatically


━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For the default selective profile:

• use standard candlesticks
• begin with Sniper preset
• keep Auto mode only when the dashboard comparison is appropriate
• use Manual mode for broker-specific comparison control
• select positively related markets
• keep Show SMT enabled while learning
• distinguish the SMT marker from the final signal
• wait for the final UP or DOWN label
• review the correlation value
• review the active Signal Score
• review external market structure independently
• consider session liquidity and volatility
• use personal stop placement
• use personal target planning
• use personal position sizing
• test alerts before depending on them
• test the exact symbol and timeframe personally used

For additional frequency:

• use Standard preset

Standard reduces:

• Base Quality requirements
• correlation requirements
• range-location restrictions
• divergence-separation requirements
• Sniper Score threshold
• final confirmation evidence

For additional selectivity:

• use Elite preset

Elite increases:

• minimum sweep depth
• rejection-close requirement
• minimum range expansion
• Base Quality threshold
• correlation threshold
• external-range restriction
• divergence-separation threshold
• Sniper Score threshold
• final evidence requirement

Always:

• wait for the candle to close
• verify the active comparison symbol
• use the SMT marker as context
• use the final signal as confirmation
• review broader structure independently
• review personal risk before any trade
• treat alerts as monitoring tools
• remember that every confirmed setup can fail


━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

SMT Sniper Entry Engine [trade_w_samet] is published as an educational correlated-market divergence and confirmation tool.

The purpose of this description is to explain:

• how the comparison market is selected
• how Auto and Manual modes differ
• which markets are included in the automatic comparison matrix
• how closed-bar liquidity references are calculated
• how a one-market sweep is identified
• how reclaim validation works
• how sweep depth is normalized by ATR
• how chart-candle direction and rejection quality are evaluated
• how the Base Quality Score is constructed
• how pair correlation is calculated and filtered
• how external-range location is evaluated
• how divergence separation is measured
• how the Sniper Score is constructed
• how Standard, Sniper, and Elite differ
• how a qualified SMT event arms the confirmation engine
• how the temporary confirmation window works
• how evidence is accumulated across separate closed candles
• how displacement is detected
• how the SMT-candle break is used
• how Fair Value Gap evidence is detected
• how micro-structure evidence is detected
• how setup invalidation works
• how setup expiration works
• when final UP and DOWN labels appear
• what the SMT markers and dotted reference lines represent
• what the signal FVG box represents
• what the dashboard displays
• what the static alerts contain
• how “Any alert() function call” works
• what diagnostic values are available in the Data Window
• how confirmed-close timing works
• what the engine does not simulate
• why familiar SMT concepts are organized into an original workflow

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It does not calculate position size.

It does not provide a built-in TP / SL trade-management model.

It should not be used as a blind UP / DOWN system.

Repainting and Timing Disclosure

SMT Sniper Entry Engine is designed around confirmed-bar calculations.

Permanent SMT events and final UP / DOWN labels use barstate.isconfirmed.

The comparison-market request uses:

• barmerge.gaps_off
• barmerge.lookahead_off

Liquidity references use previous closed candles.

The current candle is excluded from the prior-reference calculation.

The script does not use:

• pivot-high functions
• pivot-low functions
• future-bar confirmation
• negative plot offsets
• historical signal backplotting
• later relocation of final signal labels

A final UP or DOWN signal appears on the candle where the complete confirmation sequence becomes valid.

It is not moved backward to the original SMT candle.

Historical drawing cleanup can delete older lines, markers, labels, or boxes when the recent-object limit is exceeded.

Deleting an old drawing is not repainting.

The original signal bar is not changed.

Historical results can still differ when:

• settings are changed
• comparison symbols are changed
• Auto or Manual mode is changed
• chart symbols are changed
• timeframes are changed
• broker or exchange feeds are changed
• historical data is revised
• available chart history is changed

Realtime behavior also depends on when TradingView receives the final data for the closing candle.

Confirmed-close design reduces unfinished-candle changes.

It does not eliminate market risk, data-feed differences, or alert-delivery limitations.


━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

SMT Sniper Entry Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, or tax advice.

No indicator can guarantee future results.

Markets are uncertain.

Correlation changes.

Liquidity changes.

Volatility changes.

Market structure changes.

Historical chart behavior does not ensure future performance.

Every user is responsible for their own:

• analysis
• validation
• comparison-market selection
• execution planning
• stop placement
• target planning
• position sizing
• risk management
• alert configuration
• trading decisions
• broker execution
• legal obligations
• tax obligations

The liquidity references, SMT markers, dotted lines, Base Quality Scores, Sniper Scores, correlation values, external-range filters, divergence-separation values, displacement conditions, Fair Value Gap boxes, micro-structure conditions, UP labels, DOWN labels, dashboard states, Data Window values, signal counts, and alerts are visual analysis tools only.

The SMT marker is not a guaranteed reversal.

The UP label is not a guaranteed profitable long trade.

The DOWN label is not a guaranteed profitable short trade.

The Signal Score is not a win probability.

The Base Quality Score is not a probability.

The correlation reading is not a guarantee that two markets will continue moving together.

The automatic comparison symbol is not guaranteed to be suitable for every broker feed.

The FVG box is not a guaranteed support or resistance zone.

The micro-structure break is not a guarantee of continuation.

The final signal-bar close is not a guaranteed fill.

The script does not include spread, commission, slippage, latency, financing, contract specifications, order rejection, partial fills, or broker-specific execution behavior.

Use this script as a structured SMT divergence-review and confirmation framework, not as a promise of profitability or a substitute for independent judgment.

## Source Code

````pine
//@version=6
indicator(
     title            = "SMT Sniper Entry Engine [trade_w_samet]",
     shorttitle       = "SMT Sniper Entry Engine [trade_w_samet]",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMT SNIPER ENTRY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// • True bar-close SMT confirmation
// • No pivot functions
// • No future-bar confirmation delay
// • No historical backplotting
// • No deletion or relocation after confirmation
// • Rolling liquidity references from already closed bars
// • ATR-normalized quality filters
// • SMT-armed displacement, FVG, and micro-structure confirmations
// • One confirmed UP / DOWN per SMT setup
// • ATR-based stop-loss boxes with a fixed 2R take-profit target
// • One active trade box at a time with conservative same-bar handling
// • Educational use only. Not financial advice.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. SIMPLE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string GROUP_ENGINE  = "⚙️ Engine"
string GROUP_MARKET  = "🔗 Comparison Market"
string GROUP_DISPLAY = "🎨 Display"
string GROUP_TRADE   = "🎯 Trade Management"
string GROUP_ALERTS  = "🔔 Alerts"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. USER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string enginePreset = input.string(
     defval  = "Sniper",
     title   = "Engine Preset",
     options = ["Standard", "Sniper", "Elite"],
     group   = GROUP_ENGINE,
     tooltip = "Standard produces more setups. Sniper is the recommended balanced mode. Elite is the most selective.",
     display = display.none)

string comparisonMode = input.string(
     defval  = "Auto",
     title   = "Comparison Symbol Mode",
     options = ["Auto", "Manual"],
     group   = GROUP_MARKET,
     display = display.none)

string manualComparison = input.symbol(
     defval  = "OANDA:XAGUSD",
     title   = "Manual Comparison Symbol",
     group   = GROUP_MARKET,
     active  = comparisonMode == "Manual",
     display = display.none)

bool showHistoricalSmt = input.bool(
     defval  = true,
     title   = "Show SMT",
     group   = GROUP_DISPLAY,
     display = display.none)

bool showSignalLabels = input.bool(
     defval  = true,
     title   = "Show UP / DOWN",
     group   = GROUP_DISPLAY,
     display = display.none)

string signalLabelSize = input.string(
     defval  = "Normal",
     title   = "UP / DOWN Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = GROUP_DISPLAY,
     active  = showSignalLabels,
     display = display.none)

bool showSignalFvg = input.bool(
     defval  = true,
     title   = "Show Signal FVG",
     group   = GROUP_DISPLAY,
     display = display.none)

bool showDashboard = input.bool(
     defval  = true,
     title   = "Show Dashboard",
     group   = GROUP_DISPLAY,
     display = display.none)

bool showTradeBoxes = input.bool(
     defval  = true,
     title   = "📦 Show UP / DOWN TP-SL Boxes",
     group   = GROUP_TRADE,
     tooltip = "Creates an ATR-based stop-loss box and a fixed 2R take-profit box for each confirmed UP or DOWN signal.",
     display = display.none)

int tradeAtrLength = input.int(
     defval  = 14,
     title   = "📏 ATR Length",
     minval  = 1,
     maxval  = 200,
     group   = GROUP_TRADE,
     tooltip = "ATR period used only for the TP/SL trade boxes. Default: 14.",
     display = display.none)

float tradeSlAtrMultiplier = input.float(
     defval  = 2.00,
     title   = "🛡️ Stop Loss ATR Multiplier",
     minval  = 0.10,
     maxval  = 10.00,
     step    = 0.05,
     group   = GROUP_TRADE,
     tooltip = "Stop-loss distance from the signal close. Example: 1.00 means one ATR.",
     display = display.none)

bool showTradeResultLabels = input.bool(
     defval  = true,
     title   = "✅ Show TP / SL Results",
     group   = GROUP_TRADE,
     tooltip = "Shows a result label when the fixed 2R target or ATR stop loss is reached.",
     display = display.none)

bool enableAlerts = input.bool(
     defval  = true,
     title   = "Enable Alerts",
     group   = GROUP_ALERTS,
     display = display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. LOCKED ENGINE DEFAULTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Core SMT
int referenceLookback = 12
string acceptedSweepRole = "Either Market"
int directionalCooldownBars = 15
bool requireReferenceReclaim = true

// Preset-driven engine behavior
string qualityPreset = "Strict"
string sniperFilterMode = "Sniper"
string confirmationMode = "Confirmed"

if enginePreset == "Standard"
    qualityPreset := "Balanced"
    sniperFilterMode := "Standard"
    confirmationMode := "Reactive"
else if enginePreset == "Elite"
    qualityPreset := "Elite"
    sniperFilterMode := "Elite"
    confirmationMode := "Elite"

// Quality
int atrLength = 14
bool requireChartDirection = true
bool requireChartRejection = true
bool requireRangeExpansion = true

// Sniper context
string correlationType = "Positive"
int correlationLength = 50
int contextRangeLookback = 60
bool requireStrongCorrelation = true
bool requireExternalRangeLocation = true
bool requireDivergenceSeparation = true
bool showSniperScoreInSmtText = false

// Signal confirmation
int confirmationWindowBars = 8
int minimumBarsAfterSmt = 1
float displacementBodyAtr = 0.45
float displacementBodyPercent = 0.55
float maximumOppositeWickPercent = 0.35
bool requirePreviousBarBreak = false
bool requireSmtCandleBreak = true
string confirmedEvidenceMode = "FVG or Structure Break"
float invalidationAtrBuffer = 0.10
int microStructureLookback = 5
int signalCooldownBars = 8

// Minimal visual system
string visualLayoutMode = "Clean"
string historicalDisplayMode = "Recent Only"
int maxBullishSmtVisible = 8
int maxBearishSmtVisible = 8
bool showSmtMarker = true
bool showQualityScore = false
bool showReferenceLines = true
string lineStyleInput = "Dotted"
int smtLineWidth = 1
string smtTextSize = "Normal"
string smtMarkerLayout = "Minimal"
float smtTextOffsetAtr = 0.10

// Signal visuals
int maxSignalLabelsVisible = 10
int maxSignalFvgVisible = 6
bool showDisplacementMarker = false
int signalFvgExtensionBars = 12

// Locked brand colors
color bullishColor = color.rgb(0, 190, 120)
color bearishColor = color.rgb(230, 55, 70)
color neutralColor = color.rgb(130, 138, 150)
color upSignalColor = color.rgb(35, 120, 255)
color downSignalColor = color.rgb(255, 140, 35)
color tradeTpBoxColor = color.rgb(0, 156, 138)
color tradeTpBorderColor = color.rgb(72, 224, 204)
color tradeSlBoxColor = color.rgb(154, 42, 53)
color tradeSlBorderColor = color.rgb(239, 92, 104)
float tradeTakeProfitR = 2.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. UTILITIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_autoPair(string _tickerId, string _fallback) =>
    string _symbol = str.upper(_tickerId)
    string _result = _fallback

    // Metals / Indices / Crypto
    if str.contains(_symbol, "XAU") or str.contains(_symbol, "GOLD")
        _result := "OANDA:XAGUSD"
    else if str.contains(_symbol, "XAG") or str.contains(_symbol, "SILVER")
        _result := "OANDA:XAUUSD"
    else if str.contains(_symbol, "NAS") or str.contains(_symbol, "US100") or str.contains(_symbol, "USTEC") or str.contains(_symbol, "NDX") or str.contains(_symbol, "NQ")
        _result := "OANDA:SPX500USD"
    else if str.contains(_symbol, "SPX") or str.contains(_symbol, "US500") or str.contains(_symbol, "SP500") or str.contains(_symbol, "ES1")
        _result := "OANDA:NAS100USD"
    else if str.contains(_symbol, "US30") or str.contains(_symbol, "DJI") or str.contains(_symbol, "DOW") or str.contains(_symbol, "YM1")
        _result := "OANDA:SPX500USD"
    else if str.contains(_symbol, "BTC")
        _result := "BINANCE:ETHUSDT"
    else if str.contains(_symbol, "ETH")
        _result := "BINANCE:BTCUSDT"

    // Forex auto SMT matrix - broad support for majors and common crosses
    else if str.contains(_symbol, "EURUSD")
        _result := "OANDA:GBPUSD"
    else if str.contains(_symbol, "GBPUSD")
        _result := "OANDA:EURUSD"
    else if str.contains(_symbol, "AUDUSD")
        _result := "OANDA:NZDUSD"
    else if str.contains(_symbol, "NZDUSD")
        _result := "OANDA:AUDUSD"
    else if str.contains(_symbol, "USDCAD")
        _result := "OANDA:USDCHF"
    else if str.contains(_symbol, "USDCHF")
        _result := "OANDA:USDCAD"
    else if str.contains(_symbol, "USDJPY")
        _result := "OANDA:CADJPY"

    else if str.contains(_symbol, "EURJPY")
        _result := "OANDA:GBPJPY"
    else if str.contains(_symbol, "GBPJPY")
        _result := "OANDA:EURJPY"
    else if str.contains(_symbol, "AUDJPY")
        _result := "OANDA:NZDJPY"
    else if str.contains(_symbol, "NZDJPY")
        _result := "OANDA:AUDJPY"
    else if str.contains(_symbol, "CADJPY")
        _result := "OANDA:USDJPY"
    else if str.contains(_symbol, "CHFJPY")
        _result := "OANDA:EURJPY"

    else if str.contains(_symbol, "EURGBP")
        _result := "OANDA:GBPUSD"
    else if str.contains(_symbol, "EURAUD")
        _result := "OANDA:GBPAUD"
    else if str.contains(_symbol, "EURNZD")
        _result := "OANDA:GBPNZD"
    else if str.contains(_symbol, "EURCAD")
        _result := "OANDA:GBPCAD"
    else if str.contains(_symbol, "EURCHF")
        _result := "OANDA:GBPCHF"

    else if str.contains(_symbol, "GBPAUD")
        _result := "OANDA:EURAUD"
    else if str.contains(_symbol, "GBPNZD")
        _result := "OANDA:EURNZD"
    else if str.contains(_symbol, "GBPCAD")
        _result := "OANDA:EURCAD"
    else if str.contains(_symbol, "GBPCHF")
        _result := "OANDA:EURCHF"

    else if str.contains(_symbol, "AUDCAD")
        _result := "OANDA:NZDCAD"
    else if str.contains(_symbol, "NZDCAD")
        _result := "OANDA:AUDCAD"
    else if str.contains(_symbol, "AUDCHF")
        _result := "OANDA:NZDCHF"
    else if str.contains(_symbol, "NZDCHF")
        _result := "OANDA:AUDCHF"
    else if str.contains(_symbol, "AUDNZD")
        _result := "OANDA:NZDUSD"

    _result

f_lineStyle(string _style) =>
    _style == "Solid" ? line.style_solid : _style == "Dotted" ? line.style_dotted : line.style_dashed

f_textSize(string _size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_smtMarkerText(string _layout, bool _bullish) =>
    string _text = _bullish ? "SMT+\nBULL" : "SMT-\nBEAR"
    if _layout == "Stacked"
        _text := _bullish ? "BULL\nSMT" : "BEAR\nSMT"
    else if _layout == "Compact"
        _text := _bullish ? "SMT+" : "SMT-"
    else if _layout == "Minimal"
        _text := _bullish ? "▲" : "▼"
    _text

f_bullSmtLabelStyle(string _visualMode, string _layout) =>
    _style = label.style_label_lower_left
    if _layout == "Stacked"
        _style := label.style_label_up
    else if _layout == "Compact" or _layout == "Minimal"
        _style := _visualMode == "Clean" ? label.style_label_up : label.style_label_lower_left
    _style

f_bearSmtLabelStyle(string _visualMode, string _layout) =>
    _style = label.style_label_upper_left
    if _layout == "Stacked"
        _style := label.style_label_down
    else if _layout == "Compact" or _layout == "Minimal"
        _style := _visualMode == "Clean" ? label.style_label_down : label.style_label_upper_left
    _style

f_minSweepAtr(string _preset) =>
    _preset == "Elite" ? 0.18 : _preset == "Strict" ? 0.10 : 0.04

f_minClosePosition(string _preset) =>
    _preset == "Elite" ? 0.72 : _preset == "Strict" ? 0.64 : 0.56

f_minRangeAtr(string _preset) =>
    _preset == "Elite" ? 0.85 : _preset == "Strict" ? 0.60 : 0.40

f_minQualityScore(string _preset) =>
    _preset == "Elite" ? 85.0 : _preset == "Strict" ? 75.0 : 60.0

f_sniperMinCorrelation(string _mode) =>
    _mode == "Elite" ? 0.70 : _mode == "Sniper" ? 0.55 : 0.35

f_sniperBullMaxRangePosition(string _mode) =>
    _mode == "Elite" ? 0.25 : _mode == "Sniper" ? 0.33 : 0.45

f_sniperBearMinRangePosition(string _mode) =>
    _mode == "Elite" ? 0.75 : _mode == "Sniper" ? 0.67 : 0.55

f_sniperMinDivergenceGapAtr(string _mode) =>
    _mode == "Elite" ? 0.08 : _mode == "Sniper" ? 0.03 : 0.00

f_sniperMinScore(string _mode) =>
    _mode == "Elite" ? 88.0 : _mode == "Sniper" ? 78.0 : 60.0

string autoComparison = f_autoPair(syminfo.ticker, manualComparison)
string comparisonSymbol = comparisonMode == "Manual" ? manualComparison : autoComparison

[comparisonOpen, comparisonHigh, comparisonLow, comparisonClose, comparisonAtr] = request.security(
     comparisonSymbol,
     timeframe.period,
     [open, high, low, close, ta.atr(atrLength)],
     gaps                  = barmerge.gaps_off,
     lookahead             = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

bool comparisonReady = not na(comparisonClose)
historicalStyle = f_lineStyle(lineStyleInput)
smtLabelSize = f_textSize(smtTextSize)
signalMarkerSize = f_textSize(signalLabelSize)

int smtLineTransparency = visualLayoutMode == "Clean" ? 68 : visualLayoutMode == "Balanced" ? 50 : 35
int smtMarkerTransparency = 0
string bullSmtMarkerText = f_smtMarkerText(smtMarkerLayout, true)
string bearSmtMarkerText = f_smtMarkerText(smtMarkerLayout, false)

var array<line> bullSmtLineObjects = array.new_line()
var array<label> bullSmtLabelObjects = array.new_label()
var array<line> bearSmtLineObjects = array.new_line()
var array<label> bearSmtLabelObjects = array.new_label()
var array<label> signalLabelObjects = array.new_label()
var array<box> signalBoxObjects = array.new_box()

float chartAtr = ta.atr(atrLength)
float tradeAtr = ta.atr(tradeAtrLength)
float minimumSweepAtr = f_minSweepAtr(qualityPreset)
float minimumClosePosition = f_minClosePosition(qualityPreset)
float minimumRangeAtr = f_minRangeAtr(qualityPreset)
float minimumQualityScore = f_minQualityScore(qualityPreset)

float sniperMinimumCorrelation = f_sniperMinCorrelation(sniperFilterMode)
float sniperBullMaximumRangePosition = f_sniperBullMaxRangePosition(sniperFilterMode)
float sniperBearMinimumRangePosition = f_sniperBearMinRangePosition(sniperFilterMode)
float sniperMinimumDivergenceGapAtr = f_sniperMinDivergenceGapAtr(sniperFilterMode)
float sniperMinimumScore = f_sniperMinScore(sniperFilterMode)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. CLOSED-BAR LIQUIDITY REFERENCES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Every reference below excludes the current forming/closing bar.
// No future bars or pivot confirmation are used.

float chartPriorLow = ta.lowest(low[1], referenceLookback)
float chartPriorHigh = ta.highest(high[1], referenceLookback)
float comparisonPriorLow = ta.lowest(comparisonLow[1], referenceLookback)
float comparisonPriorHigh = ta.highest(comparisonHigh[1], referenceLookback)

int chartPriorLowOffset = ta.lowestbars(low[1], referenceLookback) + 1
int chartPriorHighOffset = ta.highestbars(high[1], referenceLookback) + 1

int chartPriorLowBar = bar_index - chartPriorLowOffset
int chartPriorHighBar = bar_index - chartPriorHighOffset

bool referencesReady =
     comparisonReady and
     not na(chartPriorLow) and
     not na(chartPriorHigh) and
     not na(comparisonPriorLow) and
     not na(comparisonPriorHigh) and
     not na(chartAtr) and
     not na(comparisonAtr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. REAL-TIME BAR-CLOSE SMT DIVERGENCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool chartSweptLow = referencesReady and low < chartPriorLow
bool comparisonSweptLow = referencesReady and comparisonLow < comparisonPriorLow
bool chartSweptHigh = referencesReady and high > chartPriorHigh
bool comparisonSweptHigh = referencesReady and comparisonHigh > comparisonPriorHigh

bool bullishChartSweepDivergence = chartSweptLow and not comparisonSweptLow
bool bullishComparisonSweepDivergence = comparisonSweptLow and not chartSweptLow
bool bearishChartSweepDivergence = chartSweptHigh and not comparisonSweptHigh
bool bearishComparisonSweepDivergence = comparisonSweptHigh and not chartSweptHigh

bool bullishRolePass = bullishComparisonSweepDivergence
if acceptedSweepRole == "Either Market"
    bullishRolePass := bullishChartSweepDivergence or bullishComparisonSweepDivergence
else if acceptedSweepRole == "Chart Symbol"
    bullishRolePass := bullishChartSweepDivergence

bool bearishRolePass = bearishComparisonSweepDivergence
if acceptedSweepRole == "Either Market"
    bearishRolePass := bearishChartSweepDivergence or bearishComparisonSweepDivergence
else if acceptedSweepRole == "Chart Symbol"
    bearishRolePass := bearishChartSweepDivergence

bool bullishReclaimPass =
     not requireReferenceReclaim or
     bullishChartSweepDivergence and close > chartPriorLow or
     bullishComparisonSweepDivergence and comparisonClose > comparisonPriorLow

bool bearishReclaimPass =
     not requireReferenceReclaim or
     bearishChartSweepDivergence and close < chartPriorHigh or
     bearishComparisonSweepDivergence and comparisonClose < comparisonPriorHigh

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12. BAR-CLOSE QUALITY FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float chartRange = math.max(high - low, syminfo.mintick)
float chartClosePosition = (close - low) / chartRange
float chartRangeAtr = chartAtr > 0 ? chartRange / chartAtr : 0.0

float chartBullSweepAtr = chartAtr > 0 ? math.max(chartPriorLow - low, 0.0) / chartAtr : 0.0
float comparisonBullSweepAtr = comparisonAtr > 0 ? math.max(comparisonPriorLow - comparisonLow, 0.0) / comparisonAtr : 0.0
float chartBearSweepAtr = chartAtr > 0 ? math.max(high - chartPriorHigh, 0.0) / chartAtr : 0.0
float comparisonBearSweepAtr = comparisonAtr > 0 ? math.max(comparisonHigh - comparisonPriorHigh, 0.0) / comparisonAtr : 0.0

float bullishSweepAtr = 0.0
if bullishChartSweepDivergence
    bullishSweepAtr := chartBullSweepAtr
else if bullishComparisonSweepDivergence
    bullishSweepAtr := comparisonBullSweepAtr

float bearishSweepAtr = 0.0
if bearishChartSweepDivergence
    bearishSweepAtr := chartBearSweepAtr
else if bearishComparisonSweepDivergence
    bearishSweepAtr := comparisonBearSweepAtr

bool bullishSweepDepthPass = bullishSweepAtr >= minimumSweepAtr
bool bearishSweepDepthPass = bearishSweepAtr >= minimumSweepAtr

bool bullishDirectionPass = not requireChartDirection or close > open
bool bearishDirectionPass = not requireChartDirection or close < open

bool bullishRejectionPass = not requireChartRejection or chartClosePosition >= minimumClosePosition
bool bearishRejectionPass = not requireChartRejection or chartClosePosition <= 1.0 - minimumClosePosition

bool rangeExpansionPass = not requireRangeExpansion or chartRangeAtr >= minimumRangeAtr

float bullishQualityScore = 0.0
bullishQualityScore += bullishRolePass ? 25.0 : 0.0
bullishQualityScore += bullishReclaimPass ? 20.0 : 0.0
bullishQualityScore += bullishSweepDepthPass ? 20.0 : 0.0
bullishQualityScore += bullishDirectionPass ? 15.0 : 0.0
bullishQualityScore += bullishRejectionPass ? 10.0 : 0.0
bullishQualityScore += rangeExpansionPass ? 10.0 : 0.0

float bearishQualityScore = 0.0
bearishQualityScore += bearishRolePass ? 25.0 : 0.0
bearishQualityScore += bearishReclaimPass ? 20.0 : 0.0
bearishQualityScore += bearishSweepDepthPass ? 20.0 : 0.0
bearishQualityScore += bearishDirectionPass ? 15.0 : 0.0
bearishQualityScore += bearishRejectionPass ? 10.0 : 0.0
bearishQualityScore += rangeExpansionPass ? 10.0 : 0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13. SNIPER SMT CONTEXT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Correlation uses closed-bar returns only.
float chartReturn = close[1] > 0 ? math.log(close / close[1]) : na
float comparisonReturn = comparisonClose[1] > 0 ? math.log(comparisonClose / comparisonClose[1]) : na
float rawPairCorrelation = ta.correlation(chartReturn, comparisonReturn, correlationLength)
float effectivePairCorrelation = correlationType == "Inverse" ? -rawPairCorrelation : rawPairCorrelation

bool correlationPass =
     not requireStrongCorrelation or
     not na(effectivePairCorrelation) and effectivePairCorrelation >= sniperMinimumCorrelation

// External range location is known on the current closed bar and uses no future bars.
float externalRangeLow = ta.lowest(low[1], contextRangeLookback)
float externalRangeHigh = ta.highest(high[1], contextRangeLookback)
float externalRangeSize = math.max(externalRangeHigh - externalRangeLow, syminfo.mintick)

float bullishRangePosition = (low - externalRangeLow) / externalRangeSize
float bearishRangePosition = (high - externalRangeLow) / externalRangeSize

bool bullishLocationPass =
     not requireExternalRangeLocation or
     bullishRangePosition <= sniperBullMaximumRangePosition

bool bearishLocationPass =
     not requireExternalRangeLocation or
     bearishRangePosition >= sniperBearMinimumRangePosition

// Measures how clearly the non-sweeping market held its own liquidity level.
float bullishDivergenceGapAtr = 0.0
if bullishChartSweepDivergence and comparisonAtr > 0
    bullishDivergenceGapAtr := math.max(comparisonLow - comparisonPriorLow, 0.0) / comparisonAtr
else if bullishComparisonSweepDivergence and chartAtr > 0
    bullishDivergenceGapAtr := math.max(low - chartPriorLow, 0.0) / chartAtr

float bearishDivergenceGapAtr = 0.0
if bearishChartSweepDivergence and comparisonAtr > 0
    bearishDivergenceGapAtr := math.max(comparisonPriorHigh - comparisonHigh, 0.0) / comparisonAtr
else if bearishComparisonSweepDivergence and chartAtr > 0
    bearishDivergenceGapAtr := math.max(chartPriorHigh - high, 0.0) / chartAtr

bool bullishDivergenceGapPass =
     not requireDivergenceSeparation or
     bullishDivergenceGapAtr >= sniperMinimumDivergenceGapAtr

bool bearishDivergenceGapPass =
     not requireDivergenceSeparation or
     bearishDivergenceGapAtr >= sniperMinimumDivergenceGapAtr

float correlationComponent = 0.0
if not na(effectivePairCorrelation)
    correlationComponent := math.max(math.min(effectivePairCorrelation, 1.0), 0.0) * 25.0

float bullishLocationComponent =
     bullishRangePosition <= sniperBullMaximumRangePosition ? 20.0 : 0.0

float bearishLocationComponent =
     bearishRangePosition >= sniperBearMinimumRangePosition ? 20.0 : 0.0

float bullishGapComponent =
     bullishDivergenceGapAtr >= sniperMinimumDivergenceGapAtr ? 10.0 : 0.0

float bearishGapComponent =
     bearishDivergenceGapAtr >= sniperMinimumDivergenceGapAtr ? 10.0 : 0.0

float bullishSweepComponent = 0.0
if bullishSweepAtr >= minimumSweepAtr * 1.50
    bullishSweepComponent := 10.0
else if bullishSweepDepthPass
    bullishSweepComponent := 5.0

float bearishSweepComponent = 0.0
if bearishSweepAtr >= minimumSweepAtr * 1.50
    bearishSweepComponent := 10.0
else if bearishSweepDepthPass
    bearishSweepComponent := 5.0

float bullishSniperScore =
     math.min(bullishQualityScore, 100.0) * 0.35 +
     correlationComponent +
     bullishLocationComponent +
     bullishGapComponent +
     bullishSweepComponent

float bearishSniperScore =
     math.min(bearishQualityScore, 100.0) * 0.35 +
     correlationComponent +
     bearishLocationComponent +
     bearishGapComponent +
     bearishSweepComponent

bool bullishSniperPass =
     correlationPass and
     bullishLocationPass and
     bullishDivergenceGapPass and
     bullishSniperScore >= sniperMinimumScore

bool bearishSniperPass =
     correlationPass and
     bearishLocationPass and
     bearishDivergenceGapPass and
     bearishSniperScore >= sniperMinimumScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 14. FINAL BAR-CLOSE SMT CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastBullishSmtBar = na
var int lastBearishSmtBar = na
var int bullishSmtCount = 0
var int bearishSmtCount = 0

bool bullishCooldownPass = na(lastBullishSmtBar) or bar_index - lastBullishSmtBar > directionalCooldownBars
bool bearishCooldownPass = na(lastBearishSmtBar) or bar_index - lastBearishSmtBar > directionalCooldownBars

bool bullishRawSmtCandidate =
     barstate.isconfirmed and
     referencesReady and
     bullishRolePass and
     bullishReclaimPass and
     bullishSweepDepthPass and
     bullishDirectionPass and
     bullishRejectionPass and
     rangeExpansionPass and
     bullishQualityScore >= minimumQualityScore

bool bullishSmtEvent =
     bullishRawSmtCandidate and
     bullishSniperPass and
     bullishCooldownPass

bool bearishRawSmtCandidate =
     barstate.isconfirmed and
     referencesReady and
     bearishRolePass and
     bearishReclaimPass and
     bearishSweepDepthPass and
     bearishDirectionPass and
     bearishRejectionPass and
     rangeExpansionPass and
     bearishQualityScore >= minimumQualityScore

bool bearishSmtEvent =
     bearishRawSmtCandidate and
     bearishSniperPass and
     bearishCooldownPass

if bullishSmtEvent
    lastBullishSmtBar := bar_index
    bullishSmtCount += 1

if bearishSmtEvent
    lastBearishSmtBar := bar_index
    bearishSmtCount += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 15. SEQUENTIAL SMT CONFIRMATION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float signalCandleRange = math.max(high - low, syminfo.mintick)
float signalCandleBody = math.abs(close - open)
float signalBodyRatio = signalCandleBody / signalCandleRange
float bullishOppositeWickRatio = (high - math.max(open, close)) / signalCandleRange
float bearishOppositeWickRatio = (math.min(open, close) - low) / signalCandleRange

bool bullishPreviousBreakPass = not requirePreviousBarBreak or close > high[1]
bool bearishPreviousBreakPass = not requirePreviousBarBreak or close < low[1]

bool bullishDisplacement =
     barstate.isconfirmed and
     close > open and
     signalCandleBody >= chartAtr * displacementBodyAtr and
     signalBodyRatio >= displacementBodyPercent and
     bullishOppositeWickRatio <= maximumOppositeWickPercent and
     bullishPreviousBreakPass

bool bearishDisplacement =
     barstate.isconfirmed and
     close < open and
     signalCandleBody >= chartAtr * displacementBodyAtr and
     signalBodyRatio >= displacementBodyPercent and
     bearishOppositeWickRatio <= maximumOppositeWickPercent and
     bearishPreviousBreakPass

bool bullishFvg = barstate.isconfirmed and bar_index >= 2 and low > high[2]
bool bearishFvg = barstate.isconfirmed and bar_index >= 2 and high < low[2]

float priorMicroHigh = ta.highest(high[1], microStructureLookback)
float priorMicroLow = ta.lowest(low[1], microStructureLookback)

bool bullishMicroStructureBreak = barstate.isconfirmed and close > priorMicroHigh
bool bearishMicroStructureBreak = barstate.isconfirmed and close < priorMicroLow

var int pendingSetupDirection = 0
var int pendingSetupBar = na
var float pendingSetupQuality = na
var float pendingSniperScore = na
var float pendingSmtExtreme = na
var float pendingSmtTrigger = na
var float pendingSmtAtr = na

var bool pendingDisplacementSeen = false
var bool pendingFvgSeen = false
var bool pendingStructureBreakSeen = false
var bool pendingReactionBreakSeen = false

var int pendingFvgLeft = na
var float pendingFvgTop = na
var float pendingFvgBottom = na

var int lastFinalSignalBar = na
var int buySignalCount = 0
var int sellSignalCount = 0
var int invalidatedSetupCount = 0
var int expiredSetupCount = 0

var float lastBuySignalQuality = na
var float lastSellSignalQuality = na
var float lastBuySniperScore = na
var float lastSellSniperScore = na
var int lastSignalFvgLeft = na
var float lastSignalFvgTop = na
var float lastSignalFvgBottom = na
var bool lastSignalHadFvg = false

if bullishSmtEvent
    pendingSetupDirection := 1
    pendingSetupBar := bar_index
    pendingSetupQuality := bullishQualityScore
    pendingSniperScore := bullishSniperScore
    pendingSmtExtreme := low
    pendingSmtTrigger := high
    pendingSmtAtr := chartAtr
    pendingDisplacementSeen := false
    pendingFvgSeen := false
    pendingStructureBreakSeen := false
    pendingReactionBreakSeen := false
    pendingFvgLeft := na
    pendingFvgTop := na
    pendingFvgBottom := na

if bearishSmtEvent
    pendingSetupDirection := -1
    pendingSetupBar := bar_index
    pendingSetupQuality := bearishQualityScore
    pendingSniperScore := bearishSniperScore
    pendingSmtExtreme := high
    pendingSmtTrigger := low
    pendingSmtAtr := chartAtr
    pendingDisplacementSeen := false
    pendingFvgSeen := false
    pendingStructureBreakSeen := false
    pendingReactionBreakSeen := false
    pendingFvgLeft := na
    pendingFvgTop := na
    pendingFvgBottom := na

int pendingSetupAge = -1
if pendingSetupDirection != 0 and not na(pendingSetupBar)
    pendingSetupAge := bar_index - pendingSetupBar

bool pendingWindowOpen =
     pendingSetupDirection != 0 and
     pendingSetupAge >= minimumBarsAfterSmt and
     pendingSetupAge <= confirmationWindowBars

// Evidence is accumulated across separate closed bars.
if pendingWindowOpen and pendingSetupDirection == 1
    pendingDisplacementSeen := pendingDisplacementSeen or bullishDisplacement
    pendingStructureBreakSeen := pendingStructureBreakSeen or bullishMicroStructureBreak
    pendingReactionBreakSeen := pendingReactionBreakSeen or not requireSmtCandleBreak or close > pendingSmtTrigger

    if bullishFvg
        pendingFvgSeen := true
        if na(pendingFvgLeft)
            pendingFvgLeft := bar_index - 2
            pendingFvgTop := low
            pendingFvgBottom := high[2]

if pendingWindowOpen and pendingSetupDirection == -1
    pendingDisplacementSeen := pendingDisplacementSeen or bearishDisplacement
    pendingStructureBreakSeen := pendingStructureBreakSeen or bearishMicroStructureBreak
    pendingReactionBreakSeen := pendingReactionBreakSeen or not requireSmtCandleBreak or close < pendingSmtTrigger

    if bearishFvg
        pendingFvgSeen := true
        if na(pendingFvgLeft)
            pendingFvgLeft := bar_index - 2
            pendingFvgTop := low[2]
            pendingFvgBottom := high

bool bullishSetupInvalidated =
     pendingSetupDirection == 1 and
     not na(pendingSmtExtreme) and
     not na(pendingSmtAtr) and
     close < pendingSmtExtreme - pendingSmtAtr * invalidationAtrBuffer

bool bearishSetupInvalidated =
     pendingSetupDirection == -1 and
     not na(pendingSmtExtreme) and
     not na(pendingSmtAtr) and
     close > pendingSmtExtreme + pendingSmtAtr * invalidationAtrBuffer

bool pendingSetupInvalidated = barstate.isconfirmed and (bullishSetupInvalidated or bearishSetupInvalidated)

bool confirmedEvidencePass = pendingFvgSeen or pendingStructureBreakSeen
if confirmedEvidenceMode == "FVG Required"
    confirmedEvidencePass := pendingFvgSeen

bool sequentialModePass = pendingDisplacementSeen and pendingReactionBreakSeen and pendingFvgSeen and pendingStructureBreakSeen
if confirmationMode == "Reactive"
    sequentialModePass := pendingDisplacementSeen and pendingReactionBreakSeen
else if confirmationMode == "Confirmed"
    sequentialModePass := pendingDisplacementSeen and pendingReactionBreakSeen and confirmedEvidencePass

bool finalSignalCooldownPass =
     na(lastFinalSignalBar) or
     bar_index - lastFinalSignalBar > signalCooldownBars

bool buySignal =
     barstate.isconfirmed and
     pendingSetupDirection == 1 and
     pendingWindowOpen and
     not pendingSetupInvalidated and
     sequentialModePass and
     finalSignalCooldownPass

bool sellSignal =
     barstate.isconfirmed and
     pendingSetupDirection == -1 and
     pendingWindowOpen and
     not pendingSetupInvalidated and
     sequentialModePass and
     finalSignalCooldownPass

if buySignal
    lastFinalSignalBar := bar_index
    buySignalCount += 1
    lastBuySignalQuality := pendingSetupQuality
    lastBuySniperScore := pendingSniperScore
    lastSignalHadFvg := pendingFvgSeen
    lastSignalFvgLeft := pendingFvgLeft
    lastSignalFvgTop := pendingFvgTop
    lastSignalFvgBottom := pendingFvgBottom

if sellSignal
    lastFinalSignalBar := bar_index
    sellSignalCount += 1
    lastSellSignalQuality := pendingSetupQuality
    lastSellSniperScore := pendingSniperScore
    lastSignalHadFvg := pendingFvgSeen
    lastSignalFvgLeft := pendingFvgLeft
    lastSignalFvgTop := pendingFvgTop
    lastSignalFvgBottom := pendingFvgBottom

bool pendingSetupExpired =
     pendingSetupDirection != 0 and
     not na(pendingSetupBar) and
     bar_index - pendingSetupBar > confirmationWindowBars

if pendingSetupInvalidated and not buySignal and not sellSignal
    invalidatedSetupCount += 1

if pendingSetupExpired and not buySignal and not sellSignal
    expiredSetupCount += 1

bool clearPendingSetup =
     buySignal or
     sellSignal or
     pendingSetupInvalidated or
     pendingSetupExpired

if clearPendingSetup
    pendingSetupDirection := 0
    pendingSetupBar := na
    pendingSetupQuality := na
    pendingSniperScore := na
    pendingSmtExtreme := na
    pendingSmtTrigger := na
    pendingSmtAtr := na
    pendingDisplacementSeen := false
    pendingFvgSeen := false
    pendingStructureBreakSeen := false
    pendingReactionBreakSeen := false
    pendingFvgLeft := na
    pendingFvgTop := na
    pendingFvgBottom := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 16. IMMUTABLE HISTORICAL DRAWINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Labels are created on the actual confirmation bar.
// They are never moved, deleted, or backplotted.


if bullishSmtEvent and showHistoricalSmt
    string labelText = bullSmtMarkerText
    if showSniperScoreInSmtText
        labelText := bullSmtMarkerText + " " + str.tostring(bullishSniperScore, "#")
    else if showQualityScore
        labelText := bullSmtMarkerText + " " + str.tostring(bullishQualityScore, "#")
    float markerOffset = chartAtr * (smtTextOffsetAtr + (bullishSmtCount % 3) * 0.10)

    if showReferenceLines and not na(chartPriorLowBar) and not na(chartPriorLow)
        line bullLine = line.new(
             x1    = chartPriorLowBar,
             y1    = chartPriorLow,
             x2    = bar_index,
             y2    = low,
             color = color.new(bullishColor, smtLineTransparency),
             style = historicalStyle,
             width = smtLineWidth)
        array.push(bullSmtLineObjects, bullLine)
        if historicalDisplayMode == "Recent Only"
            while array.size(bullSmtLineObjects) > maxBullishSmtVisible
                line oldLine = array.shift(bullSmtLineObjects)
                line.delete(oldLine)

    if showSmtMarker
        label bullLabel = label.new(
             x         = bar_index,
             y         = low - markerOffset,
             text      = labelText,
             style     = f_bullSmtLabelStyle(visualLayoutMode, smtMarkerLayout),
             color     = color.new(bullishColor, 10),
             textcolor = color.white,
             size      = smtLabelSize,
             tooltip   = "Bullish SMT | Sniper: " + str.tostring(bullishSniperScore, "#") + " | Base Quality: " + str.tostring(bullishQualityScore, "#") + " | Correlation: " + str.tostring(effectivePairCorrelation, "#.##") + " | Comparison: " + comparisonSymbol)
        array.push(bullSmtLabelObjects, bullLabel)
        if historicalDisplayMode == "Recent Only"
            while array.size(bullSmtLabelObjects) > maxBullishSmtVisible
                label oldLabel = array.shift(bullSmtLabelObjects)
                label.delete(oldLabel)

if bearishSmtEvent and showHistoricalSmt
    string labelText = bearSmtMarkerText
    if showSniperScoreInSmtText
        labelText := bearSmtMarkerText + " " + str.tostring(bearishSniperScore, "#")
    else if showQualityScore
        labelText := bearSmtMarkerText + " " + str.tostring(bearishQualityScore, "#")
    float markerOffset = chartAtr * (smtTextOffsetAtr + (bearishSmtCount % 3) * 0.10)

    if showReferenceLines and not na(chartPriorHighBar) and not na(chartPriorHigh)
        line bearLine = line.new(
             x1    = chartPriorHighBar,
             y1    = chartPriorHigh,
             x2    = bar_index,
             y2    = high,
             color = color.new(bearishColor, smtLineTransparency),
             style = historicalStyle,
             width = smtLineWidth)
        array.push(bearSmtLineObjects, bearLine)
        if historicalDisplayMode == "Recent Only"
            while array.size(bearSmtLineObjects) > maxBearishSmtVisible
                line oldLine = array.shift(bearSmtLineObjects)
                line.delete(oldLine)

    if showSmtMarker
        label bearLabel = label.new(
             x         = bar_index,
             y         = high + markerOffset,
             text      = labelText,
             style     = f_bearSmtLabelStyle(visualLayoutMode, smtMarkerLayout),
             color     = color.new(bearishColor, 10),
             textcolor = color.white,
             size      = smtLabelSize,
             tooltip   = "Bearish SMT | Sniper: " + str.tostring(bearishSniperScore, "#") + " | Base Quality: " + str.tostring(bearishQualityScore, "#") + " | Correlation: " + str.tostring(effectivePairCorrelation, "#.##") + " | Comparison: " + comparisonSymbol)
        array.push(bearSmtLabelObjects, bearLabel)
        if historicalDisplayMode == "Recent Only"
            while array.size(bearSmtLabelObjects) > maxBearishSmtVisible
                label oldLabel = array.shift(bearSmtLabelObjects)
                label.delete(oldLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 17. FINAL SIGNAL VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showDisplacementMarker and bullishDisplacement,
     title     = "Bullish Displacement",
     style     = shape.circle,
     location  = location.belowbar,
     color     = color.new(bullishColor, 15),
     size      = size.tiny)

plotshape(
     showDisplacementMarker and bearishDisplacement,
     title     = "Bearish Displacement",
     style     = shape.circle,
     location  = location.abovebar,
     color     = color.new(bearishColor, 15),
     size      = size.tiny)

if buySignal and showSignalFvg and lastSignalHadFvg and not na(lastSignalFvgLeft)
    box bullBox = box.new(
         left         = lastSignalFvgLeft,
         top          = lastSignalFvgTop,
         right        = bar_index + signalFvgExtensionBars,
         bottom       = lastSignalFvgBottom,
         border_color = color.new(bullishColor, 35),
         border_width = 1,
         bgcolor      = color.new(bullishColor, 90))
    array.push(signalBoxObjects, bullBox)
    if historicalDisplayMode == "Recent Only"
        while array.size(signalBoxObjects) > maxSignalFvgVisible
            box oldBox = array.shift(signalBoxObjects)
            box.delete(oldBox)

if sellSignal and showSignalFvg and lastSignalHadFvg and not na(lastSignalFvgLeft)
    box bearBox = box.new(
         left         = lastSignalFvgLeft,
         top          = lastSignalFvgTop,
         right        = bar_index + signalFvgExtensionBars,
         bottom       = lastSignalFvgBottom,
         border_color = color.new(bearishColor, 35),
         border_width = 1,
         bgcolor      = color.new(bearishColor, 90))
    array.push(signalBoxObjects, bearBox)
    if historicalDisplayMode == "Recent Only"
        while array.size(signalBoxObjects) > maxSignalFvgVisible
            box oldBox = array.shift(signalBoxObjects)
            box.delete(oldBox)

if buySignal and showSignalLabels
    label buyLabel = label.new(
         x         = bar_index,
         y         = low - chartAtr * 0.22,
         text      = "𝙐𝙋",
         style     = label.style_label_up,
         color     = upSignalColor,
         textcolor = color.white,
         size      = signalMarkerSize,
         tooltip   = "Bullish SMT + " + confirmationMode + " | Sniper: " + str.tostring(lastBuySniperScore, "#") + " | Base Quality: " + str.tostring(lastBuySignalQuality, "#"))
    array.push(signalLabelObjects, buyLabel)
    if historicalDisplayMode == "Recent Only"
        while array.size(signalLabelObjects) > maxSignalLabelsVisible
            label oldSignalLabel = array.shift(signalLabelObjects)
            label.delete(oldSignalLabel)

if sellSignal and showSignalLabels
    label sellLabel = label.new(
         x         = bar_index,
         y         = high + chartAtr * 0.22,
         text      = "𝘿𝙊𝙒𝙉",
         style     = label.style_label_down,
         color     = downSignalColor,
         textcolor = color.white,
         size      = signalMarkerSize,
         tooltip   = "Bearish SMT + " + confirmationMode + " | Sniper: " + str.tostring(lastSellSniperScore, "#") + " | Base Quality: " + str.tostring(lastSellSignalQuality, "#"))
    array.push(signalLabelObjects, sellLabel)
    if historicalDisplayMode == "Recent Only"
        while array.size(signalLabelObjects) > maxSignalLabelsVisible
            label oldSignalLabel = array.shift(signalLabelObjects)
            label.delete(oldSignalLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 18. ATR TP / SL TRADE BOX ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// One confirmed trade box can be active at a time.
// Entry uses the final UP / DOWN signal candle close.
// Stop loss uses the selected ATR period and multiplier.
// Take profit is fixed at 2R.

var bool tradeBoxActive = false
var int tradeBoxDirection = 0
var int tradeBoxEntryBar = na
var float tradeBoxEntry = na
var float tradeBoxStop = na
var float tradeBoxTarget = na
var box activeTradeTpBox = na
var box activeTradeSlBox = na
var line activeTradeEntryLine = na
var line activeTradeTpLine = na
var line activeTradeSlLine = na
var label activeTradeTpLabel = na
var label activeTradeSlLabel = na

bool tradeTpEvent = false
bool tradeSlEvent = false

if barstate.isconfirmed
    if tradeBoxActive
        if showTradeBoxes
            int tradeRightX = bar_index
            int tradeLabelX = bar_index + 2

            if not na(activeTradeTpBox)
                box.set_right(activeTradeTpBox, tradeRightX)
            if not na(activeTradeSlBox)
                box.set_right(activeTradeSlBox, tradeRightX)
            if not na(activeTradeEntryLine)
                line.set_x2(activeTradeEntryLine, tradeRightX)
            if not na(activeTradeTpLine)
                line.set_x2(activeTradeTpLine, tradeRightX)
            if not na(activeTradeSlLine)
                line.set_x2(activeTradeSlLine, tradeRightX)
            if not na(activeTradeTpLabel)
                label.set_x(activeTradeTpLabel, tradeLabelX)
                label.set_y(activeTradeTpLabel, tradeBoxTarget)
                label.set_text(activeTradeTpLabel, "TP 2R  " + str.tostring(tradeBoxTarget, format.mintick))
            if not na(activeTradeSlLabel)
                label.set_x(activeTradeSlLabel, tradeLabelX)
                label.set_y(activeTradeSlLabel, tradeBoxStop)
                label.set_text(activeTradeSlLabel, "SL  " + str.tostring(tradeBoxStop, format.mintick))

        bool canEvaluateTrade = bar_index > tradeBoxEntryBar
        bool tradeStopHit = canEvaluateTrade and (tradeBoxDirection == 1 ? low <= tradeBoxStop : high >= tradeBoxStop)
        bool tradeTargetHit = canEvaluateTrade and (tradeBoxDirection == 1 ? high >= tradeBoxTarget : low <= tradeBoxTarget)

        // Conservative same-bar handling: SL has priority when both levels are touched.
        if tradeStopHit
            tradeBoxActive := false
            tradeSlEvent := true

            if showTradeResultLabels
                label.new(
                     x         = bar_index,
                     y         = tradeBoxStop,
                     text      = "SL HIT\n-1R",
                     style     = tradeBoxDirection == 1 ? label.style_label_down : label.style_label_up,
                     color     = tradeSlBorderColor,
                     textcolor = color.white,
                     size      = size.small,
                     tooltip   = "ATR stop loss reached.")
        else if tradeTargetHit
            tradeBoxActive := false
            tradeTpEvent := true

            if showTradeResultLabels
                label.new(
                     x         = bar_index,
                     y         = tradeBoxTarget,
                     text      = "TP HIT\n+2R",
                     style     = tradeBoxDirection == 1 ? label.style_label_down : label.style_label_up,
                     color     = tradeTpBorderColor,
                     textcolor = color.black,
                     size      = size.small,
                     tooltip   = "Fixed 2R take-profit target reached.")

    if not tradeBoxActive and (buySignal or sellSignal) and not na(tradeAtr)
        tradeBoxDirection := buySignal ? 1 : -1
        tradeBoxEntryBar := bar_index
        tradeBoxEntry := close

        float tradeRiskDistance = tradeAtr * tradeSlAtrMultiplier
        tradeBoxStop := tradeBoxDirection == 1 ? tradeBoxEntry - tradeRiskDistance : tradeBoxEntry + tradeRiskDistance
        tradeBoxTarget := tradeBoxDirection == 1 ? tradeBoxEntry + tradeRiskDistance * tradeTakeProfitR : tradeBoxEntry - tradeRiskDistance * tradeTakeProfitR
        tradeBoxActive := true

        if showTradeBoxes
            float tpTop = tradeBoxDirection == 1 ? tradeBoxTarget : tradeBoxEntry
            float tpBottom = tradeBoxDirection == 1 ? tradeBoxEntry : tradeBoxTarget
            float slTop = tradeBoxDirection == 1 ? tradeBoxEntry : tradeBoxStop
            float slBottom = tradeBoxDirection == 1 ? tradeBoxStop : tradeBoxEntry
            int initialRightX = bar_index + 1
            int initialLabelX = bar_index + 2

            activeTradeTpBox := box.new(
                 left         = bar_index,
                 top          = tpTop,
                 right        = initialRightX,
                 bottom       = tpBottom,
                 border_color = color.new(tradeTpBorderColor, 35),
                 border_width = 1,
                 bgcolor      = color.new(tradeTpBoxColor, 82))

            activeTradeSlBox := box.new(
                 left         = bar_index,
                 top          = slTop,
                 right        = initialRightX,
                 bottom       = slBottom,
                 border_color = color.new(tradeSlBorderColor, 35),
                 border_width = 1,
                 bgcolor      = color.new(tradeSlBoxColor, 80))

            activeTradeEntryLine := line.new(
                 x1    = bar_index,
                 y1    = tradeBoxEntry,
                 x2    = initialRightX,
                 y2    = tradeBoxEntry,
                 color = color.new(color.white, 20),
                 width = 1,
                 style = line.style_solid)

            activeTradeTpLine := line.new(
                 x1    = bar_index,
                 y1    = tradeBoxTarget,
                 x2    = initialRightX,
                 y2    = tradeBoxTarget,
                 color = tradeTpBorderColor,
                 width = 1,
                 style = line.style_solid)

            activeTradeSlLine := line.new(
                 x1    = bar_index,
                 y1    = tradeBoxStop,
                 x2    = initialRightX,
                 y2    = tradeBoxStop,
                 color = tradeSlBorderColor,
                 width = 1,
                 style = line.style_solid)

            activeTradeTpLabel := label.new(
                 x         = initialLabelX,
                 y         = tradeBoxTarget,
                 text      = "TP 2R  " + str.tostring(tradeBoxTarget, format.mintick),
                 style     = label.style_label_left,
                 color     = tradeTpBorderColor,
                 textcolor = color.black,
                 size      = size.small,
                 tooltip   = "Fixed take-profit target: 2R.")

            activeTradeSlLabel := label.new(
                 x         = initialLabelX,
                 y         = tradeBoxStop,
                 text      = "SL  " + str.tostring(tradeBoxStop, format.mintick),
                 style     = label.style_label_left,
                 color     = tradeSlBorderColor,
                 textcolor = color.white,
                 size      = size.small,
                 tooltip   = "ATR(" + str.tostring(tradeAtrLength) + ") × " + str.tostring(tradeSlAtrMultiplier, "#.##") + " stop loss.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 19. PREMIUM BRAND DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color dashboardShell = color.rgb(10, 12, 16)
color dashboardCard = color.rgb(20, 23, 29)
color dashboardCardAlt = color.rgb(25, 29, 36)
color dashboardHeader = color.rgb(7, 8, 11)
color dashboardBorder = color.new(color.white, 88)
color dashboardLabel = color.rgb(145, 153, 168)
color dashboardValue = color.rgb(245, 247, 250)
color dashboardAccent = color.rgb(215, 38, 56)

var table dashboard = table.new(
     position.bottom_right,
     4,
     7,
     bgcolor      = color.new(dashboardShell, 0),
     frame_color  = dashboardBorder,
     frame_width  = 1,
     border_color = color.new(color.white, 100),
     border_width = 0)

if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 3, 0)
    table.merge_cells(dashboard, 0, 1, 3, 1)
    table.merge_cells(dashboard, 0, 4, 3, 4)

if barstate.islast
    if showDashboard
        string currentState = "SCANNING MARKET"
        if buySignal
            currentState := "UP SIGNAL CONFIRMED"
        else if sellSignal
            currentState := "DOWN SIGNAL CONFIRMED"
        else if pendingSetupDirection == 1
            currentState := "BULLISH SETUP BUILDING"
        else if pendingSetupDirection == -1
            currentState := "BEARISH SETUP BUILDING"
        else if bullishSmtEvent
            currentState := "BULLISH SMT DETECTED"
        else if bearishSmtEvent
            currentState := "BEARISH SMT DETECTED"

        color stateBg = color.new(neutralColor, 30)
        if buySignal or pendingSetupDirection == 1 or bullishSmtEvent
            stateBg := color.new(upSignalColor, 10)
        else if sellSignal or pendingSetupDirection == -1 or bearishSmtEvent
            stateBg := color.new(downSignalColor, 10)

        float activeScore = na
        if buySignal
            activeScore := lastBuySniperScore
        else if sellSignal
            activeScore := lastSellSniperScore
        else if pendingSetupDirection != 0
            activeScore := pendingSniperScore
        else if bullishSmtEvent
            activeScore := bullishSniperScore
        else if bearishSmtEvent
            activeScore := bearishSniperScore

        string scoreText = "NO ACTIVE SETUP"
        if not na(activeScore)
            scoreText := str.tostring(activeScore, "#") + "  /  " + str.tostring(sniperMinimumScore, "#")

        string correlationText = "—"
        if not na(effectivePairCorrelation)
            correlationText := str.tostring(effectivePairCorrelation, "#.##")

        string pairModeText = "AUTO"
        if comparisonMode == "Manual"
            pairModeText := "MANUAL"

        table.cell(
             dashboard,
             0,
             0,
             "trade_w_samet  •  SMT SNIPER",
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = dashboardHeader)

        table.cell(
             dashboard,
             0,
             1,
             currentState,
             text_color  = color.white,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = stateBg)

        table.cell(
             dashboard,
             0,
             2,
             "COMPARISON",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_left,
             bgcolor     = dashboardCard)

        table.cell(
             dashboard,
             1,
             2,
             comparisonSymbol,
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_right,
             bgcolor     = dashboardCard)

        table.cell(
             dashboard,
             2,
             2,
             "CORRELATION",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_left,
             bgcolor     = dashboardCardAlt)

        table.cell(
             dashboard,
             3,
             2,
             correlationText,
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_right,
             bgcolor     = dashboardCardAlt)

        table.cell(
             dashboard,
             0,
             3,
             "ENGINE",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_left,
             bgcolor     = dashboardCardAlt)

        table.cell(
             dashboard,
             1,
             3,
             str.upper(enginePreset),
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_right,
             bgcolor     = dashboardCardAlt)

        table.cell(
             dashboard,
             2,
             3,
             "PAIR MODE",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_left,
             bgcolor     = dashboardCard)

        table.cell(
             dashboard,
             3,
             3,
             pairModeText,
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_right,
             bgcolor     = dashboardCard)

        table.cell(
             dashboard,
             0,
             4,
             "SIGNAL SCORE   •   " + scoreText,
             text_color  = dashboardValue,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = dashboardShell)

        table.cell(
             dashboard,
             0,
             5,
             "UP",
             text_color  = color.white,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = color.new(upSignalColor, 8))

        table.cell(
             dashboard,
             1,
             5,
             str.tostring(buySignalCount),
             text_color  = color.white,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = color.new(upSignalColor, 8))

        table.cell(
             dashboard,
             2,
             5,
             "DOWN",
             text_color  = color.white,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = color.new(downSignalColor, 8))

        table.cell(
             dashboard,
             3,
             5,
             str.tostring(sellSignalCount),
             text_color  = color.white,
             text_size   = size.normal,
             text_halign = text.align_center,
             bgcolor     = color.new(downSignalColor, 8))

        table.cell(
             dashboard,
             0,
             6,
             "●",
             text_color  = dashboardAccent,
             text_size   = size.small,
             text_halign = text.align_center,
             bgcolor     = dashboardHeader)

        table.cell(
             dashboard,
             1,
             6,
             "BAR-CLOSE",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_center,
             bgcolor     = dashboardHeader)

        table.cell(
             dashboard,
             2,
             6,
             "NON-REPAINT",
             text_color  = dashboardLabel,
             text_size   = size.small,
             text_halign = text.align_center,
             bgcolor     = dashboardHeader)

        table.cell(
             dashboard,
             3,
             6,
             "LIVE",
             text_color  = dashboardAccent,
             text_size   = size.small,
             text_halign = text.align_center,
             bgcolor     = dashboardHeader)
    else
        table.clear(dashboard, 0, 0, 3, 6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20. ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and bullishSmtEvent,
     title   = "SMT Sniper | Bullish SMT",
     message = "Bullish SMT confirmed on the current closed bar | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and bearishSmtEvent,
     title   = "SMT Sniper | Bearish SMT",
     message = "Bearish SMT confirmed on the current closed bar | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and buySignal,
     title   = "SMT Sniper | UP",
     message = "UP signal confirmed by the SMT displacement engine | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and sellSignal,
     title   = "SMT Sniper | DOWN",
     message = "DOWN signal confirmed by the SMT displacement engine | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and (buySignal or sellSignal),
     title   = "SMT Sniper | Any Signal",
     message = "SMT Sniper final signal | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and (bullishSmtEvent or bearishSmtEvent),
     title   = "SMT Sniper | Any SMT",
     message = "SMT confirmed on the current closed bar | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(
     enableAlerts and tradeTpEvent,
     title   = "SMT Sniper | TP HIT",
     message = "SMT Sniper fixed 2R take-profit target reached | {{ticker}} | {{interval}}")

alertcondition(
     enableAlerts and tradeSlEvent,
     title   = "SMT Sniper | SL HIT",
     message = "SMT Sniper ATR stop loss reached | {{ticker}} | {{interval}}")

// Select “Any alert() function call” in TradingView to receive
// UP, DOWN, TP HIT, and SL HIT events through one alert.
if enableAlerts
    if buySignal
        alert(
             "SMT Sniper | UP | " +
             syminfo.ticker +
             " | " +
             timeframe.period +
             " | Close: " +
             str.tostring(close, format.mintick) +
             " | Comparison: " +
             comparisonSymbol,
             alert.freq_once_per_bar_close)
    else if sellSignal
        alert(
             "SMT Sniper | DOWN | " +
             syminfo.ticker +
             " | " +
             timeframe.period +
             " | Close: " +
             str.tostring(close, format.mintick) +
             " | Comparison: " +
             comparisonSymbol,
             alert.freq_once_per_bar_close)
    else if tradeTpEvent
        alert(
             "SMT Sniper | TP HIT | " +
             syminfo.ticker +
             " | " +
             timeframe.period +
             " | Result: +2R",
             alert.freq_once_per_bar_close)
    else if tradeSlEvent
        alert(
             "SMT Sniper | SL HIT | " +
             syminfo.ticker +
             " | " +
             timeframe.period +
             " | Result: -1R",
             alert.freq_once_per_bar_close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 21. DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     comparisonClose,
     title   = "Comparison Close",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     chartPriorLow,
     title   = "Chart Prior Low Reference",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     chartPriorHigh,
     title   = "Chart Prior High Reference",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishSmtEvent ? 1 : bearishSmtEvent ? -1 : 0,
     title   = "Bar-Close SMT: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishQualityScore,
     title   = "Bullish SMT Quality Score",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bearishQualityScore,
     title   = "Bearish SMT Quality Score",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     pendingSetupDirection,
     title   = "Pending SMT Setup: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishDisplacement ? 1 : bearishDisplacement ? -1 : 0,
     title   = "Displacement: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishFvg ? 1 : bearishFvg ? -1 : 0,
     title   = "FVG: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishMicroStructureBreak ? 1 : bearishMicroStructureBreak ? -1 : 0,
     title   = "Micro Structure Break: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     buySignal ? 1 : sellSignal ? -1 : 0,
     title   = "Final Signal: 1 UP / -1 DOWN / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     pendingDisplacementSeen ? 1 : 0,
     title   = "Pending Evidence - Displacement",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     pendingReactionBreakSeen ? 1 : 0,
     title   = "Pending Evidence - SMT Candle Break",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     pendingFvgSeen ? 1 : 0,
     title   = "Pending Evidence - FVG",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     pendingStructureBreakSeen ? 1 : 0,
     title   = "Pending Evidence - Structure Break",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     effectivePairCorrelation,
     title   = "Effective Pair Correlation",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishSniperScore,
     title   = "Bullish Sniper Score",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bearishSniperScore,
     title   = "Bearish Sniper Score",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishDivergenceGapAtr,
     title   = "Bullish Divergence Separation ATR",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bearishDivergenceGapAtr,
     title   = "Bearish Divergence Separation ATR",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     bullishRawSmtCandidate and not bullishSniperPass ? 1 : bearishRawSmtCandidate and not bearishSniperPass ? -1 : 0,
     title   = "Rejected SMT Candidate: 1 Bull / -1 Bear / 0 None",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     tradeBoxActive ? tradeBoxEntry : na,
     title   = "Active Trade Entry",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     tradeBoxActive ? tradeBoxStop : na,
     title   = "Active ATR Stop Loss",
     color   = color.new(color.white, 100),
     display = display.data_window)

plot(
     tradeBoxActive ? tradeBoxTarget : na,
     title   = "Active 2R Take Profit",
     color   = color.new(color.white, 100),
     display = display.data_window)
````
