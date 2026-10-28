# [ A L P H A X ] PIVOT - Smart Money Structure

- url: https://www.tradingview.com/script/791lwVwb-A-L-P-H-A-X-PIVOT-Smart-Money-Structure/
- type: indicator
- pine_id: PUB;7bea07dbb05340718de2e7e6f9d6d407
- version: 1.0

## Description

[b]AlphaX PIVOT — Smart Money Structure + OTE Pullback Engine: Market Structure Tracking, Optimal Trade Entry Zones, Liquidity Sweep Detection & 7-Layer Confluence Scoring[/b]

AlphaX PIVOT is a professional-grade smart money pullback system built around two of the most powerful concepts in institutional price action: market structure and the Optimal Trade Entry zone. Where breakout-based systems enter at the moment of structural displacement — chasing the move after it has already begun — PIVOT waits for the market to pull back into the precise Fibonacci retracement zone where institutional continuation orders are resting, and fires only when a qualified rejection candle confirms within that zone with multi-layer confluence backing. The result is a system that gives you the same directional conviction as a breakout entry at a structurally superior price — buying the pullback into institutional demand after a bullish BOS or CHoCH, selling the pullback into institutional supply after a bearish structure shift — with a stop anchored to the structural swing low or high rather than an arbitrary ATR distance. Designed for precision-entry traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]The Core Philosophy — Why Pull Back to OTE?[/b]

A Break of Structure or Change of Character tells you that the market has shifted direction at the institutional level. But the bar that breaks structure is rarely the optimal entry — it has already moved aggressively, the risk/reward from entry is reduced, and a pullback is statistically likely before the continuation begins.

The Optimal Trade Entry concept solves this. After a structural displacement move, price almost always retraces into a specific Fibonacci retracement zone — the 61.8% to 78.6% retracement of the displacement leg — before the next move in the structural direction begins. This zone is where institutional orders waiting at discount prices (in a bull structure) or premium prices (in a bear structure) are filled. Entering in the OTE zone means entering where institutions are entering, with the displacement leg already confirmed as the directional signal and the structural swing as the natural stop reference.

PIVOT detects every structural event, computes the OTE zone for the displacement leg in real time, and monitors for qualified rejection entries within that zone — all while running a 7-layer confluence engine that scores every potential entry before it fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏗 [b]Market Structure Engine — Tracking BOS & CHoCH[/b]

The market structure engine runs a real-time fractal pivot detection system that tracks the most recent confirmed swing high and swing low on every bar, identifies every Break of Structure and Change of Character event, and maintains a live structural trend state.

[b]Pivot detection:[/b]
Swing highs and lows are detected using a configurable pivot length (default: 5 bars each side). A pivot is confirmed when the specified number of bars on both the left and right side are lower (for a pivot high) or higher (for a pivot low). This creates confirmation — not just a local high or low, but a genuine fractal swing point.

[b]Break of Structure (BOS):[/b]
When price closes above the most recent confirmed swing high while the structure is already bullish, a bullish BOS is detected — confirming the uptrend is intact and continuing. When price closes below the most recent swing low in a bearish structure, a bearish BOS is confirmed. BOS events are continuation signals — the existing structure is reinforcing itself.

[b]Change of Character (CHoCH):[/b]
When price closes above a swing high while the structure is bearish, a bullish CHoCH is detected — the character of the market has changed from bearish to bullish. A bearish CHoCH is the inverse. CHoCH events are the highest-quality structural signals — they represent genuine institutional trend reversals and form the trigger for PIVOT's highest-conviction setup type.

[b]Structure break mode:[/b]
The Close Only setting (default: on) requires a candle body close beyond the swing level for a BOS or CHoCH to register. When off, any wick touch counts. Body close is the stricter, cleaner mode — it eliminates false structure breaks caused by wick spikes that fail to close through the level, producing fewer but more reliable structural events.

[b]Live swing levels:[/b]
The most recent confirmed swing high (plotted as a red dashed line) and swing low (yellow-green dashed line) are maintained on the chart in real time, extending forward until superseded by a new confirmed pivot. These levels represent the current active liquidity pools — the precise levels where the next sweep event is likely to occur.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 [b]Structure Leg Box & Equilibrium — The Dealing Range[/b]

Every confirmed structure break event spawns a [b]Structure Leg Box[/b] — a semi-transparent purple rectangle anchored to the displacement leg that produced the structural event. This box is the visual equivalent of the ANCHOR trend segment box, providing immediate context for the current structural move's price range.

[b]Box construction:[/b]
For a bullish structure break, the leg box spans from the previous swing low (the origin of the displacement) to the close that broke structure — capturing the full range of the institutional displacement move. For a bearish structure break, it spans from the previous swing high down to the structure break close.

[b]Equilibrium line:[/b]
The midpoint of the structure leg box — the 50% retracement level — is plotted as a purple dotted line extending forward. This is the leg's equilibrium level and the dividing line between discount (below EQ, favorable for longs) and premium (above EQ, favorable for shorts). The Premium/Discount requirement enforces that PIVOT signals can only fire when price is in the institutionally correct zone relative to this level.

[b]Live updating:[/b]
The box expands as the trend develops — if price makes new highs in a bull leg, the box top extends upward. The equilibrium adjusts continuously. This ensures the OTE calculations always reflect the full extent of the current structural leg, not just the initial displacement.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]The OTE Zone — Optimal Trade Entry Band[/b]

The Optimal Trade Entry zone is a Fibonacci retracement band calculated from the structure leg's high and low — the 61.8% to 78.6% retracement zone (configurable). This is the institutional re-entry zone — the price area where sophisticated traders who missed the initial displacement fill their positions on the pullback.

[b]OTE calculation for bull structure:[/b]
[list]
[*]OTE Top = Leg High − (Leg Range × OTE Fib Low). Default: Leg High − (Range × 0.618)
[*]OTE Bottom = Leg High − (Leg Range × OTE Fib High). Default: Leg High − (Range × 0.786)
[/list]

This creates a band in the lower portion of the leg range — price must retrace between 61.8% and 78.6% of the upward displacement before the OTE zone is active.

[b]OTE calculation for bear structure:[/b]
[list]
[*]OTE Bottom = Leg Low + (Leg Range × OTE Fib Low)
[*]OTE Top = Leg Low + (Leg Range × OTE Fib High)
[/list]

This creates a band in the upper portion of the leg range — price must retrace between 61.8% and 78.6% of the downward displacement before the OTE zone is active.

[b]Why the 61.8–78.6% zone:[/b] The 61.8% (golden ratio) and 78.6% (square root of 0.618) retracement levels are the two most consistently respected Fibonacci levels in institutional price delivery. They represent the deepest pullback levels that remain structurally valid — a retracement beyond 78.6% technically invalidates the structure leg's momentum. Entries within this zone maximize reward (entering near the deepest discount in a bull leg) while minimizing risk (the stop is at the structural swing, not far from the OTE bottom).

[b]OTE zone visualization:[/b] A semi-transparent purple box rendered from the leg start bar to two bars beyond the current bar, spanning the OTE top and bottom prices. The zone extends and updates in real time as the leg evolves. The exact OTE band price levels are displayed on the dashboard for immediate reference.

[b]In-OTE detection:[/b] The current bar is considered in the OTE zone when the bar's low (for bull setups) reaches within the OTE band, or the bar's high (for bear setups) reaches within the OTE band. This detects the precise moment price has retraced into the optimal entry area.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💧 [b]Liquidity Sweep Detection[/b]

The sweep detection engine identifies liquidity grab events relative to recent price extremes, adding an important second dimension to PIVOT's entry context. A sweep is detected when price briefly extends beyond the recent high or low reference level by a minimum ATR depth, then reverses and closes back inside — the classic stop-hunt signature.

[b]Bull sweep:[/b] The current bar's low extends below the lowest low of the lookback period (default: 20 bars) by at least the minimum sweep depth (default: 0.1× ATR), and the bar closes above that low and closes bullish (close above open). Sell-side liquidity has been grabbed.

[b]Bear sweep:[/b] The high extends above the highest high of the lookback period by at least the minimum depth, and the bar closes below that high and closes bearish. Buy-side liquidity has been grabbed.

[b]Sweep recency:[/b] PIVOT accepts sweeps from the current bar or either of the two preceding bars — a three-bar recency window. This accommodates the common scenario where the sweep candle precedes the OTE entry bar by one or two bars, allowing the confluence engine to credit the sweep even when entry occurs slightly after the grab.

[b]Setup B — Sweep + CHoCH:[/b] When a sweep occurs within 40 bars of a Change of Character event and price is simultaneously in the OTE zone with a rejection candle, PIVOT's second setup type fires — the Sweep + CHoCH entry. This is the highest-conviction entry type: a CHoCH confirms the structural reversal, the sweep confirms institutional liquidity accumulation, and the OTE entry delivers the optimal price. All three institutional signals converging simultaneously.

[b]Sweep markers (optional):[/b] Small orange circles can be plotted above or below bars where sweeps are detected. Off by default — sweeps count toward confluence scoring regardless of whether markers are displayed — but enabling them provides visual awareness of every liquidity event on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕯 [b]Rejection Candle Confirmation[/b]

Every PIVOT entry requires a qualifying rejection candle within the OTE zone — the candle that demonstrates price has touched the OTE level and been rejected back in the structural direction.

[b]Bull rejection (Bullish Rejection or Engulfing):[/b]
[list]
[*][b]Bullish Rejection[/b] — the bar closes bullish (close above open) and the close-to-low distance represents more than 55% of the bar's total range. The lower wick consumes the majority of the bar's range — buyers overwhelmed sellers that pushed into the OTE zone
[*][b]Bullish Engulfing[/b] — a bullish close that fully engulfs the prior bearish candle — closing above the prior open while the prior candle was bearish. Confirms a clean reversal of the pullback momentum
[/list]

[b]Bear rejection (Bearish Rejection or Engulfing):[/b]
The mirror conditions — a bearish close with the high-to-close distance exceeding 55% of range, or a bearish engulfing of the prior bullish candle.

[b]Why candle confirmation is essential:[/b] The OTE zone being touched is a necessary but not sufficient condition for entry. Price can drift through the OTE zone on low momentum without producing a genuine reversal. The rejection candle requirement ensures that the OTE touch produced a visible institutional response — not just a passive drift through the zone.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 7-Layer Confluence Engine[/b]

Every potential entry is evaluated across seven independent confluence layers. The default minimum is 5 of 7 — a high-quality gate that blocks setups where several dimensions of confirmation are missing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 1 — Market Structure Direction[/b]

Awards 1 point when the current structural trend agrees with the signal direction — bullish structure for longs (structure == 1), bearish for shorts. This is also a hard prerequisite enforced in the setup conditions — no PIVOT signal can fire without the structural trend being established in the signal direction. Structure is simultaneously a confluence layer and a foundational entry requirement.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 2 — OTE Zone Touch[/b]

Awards 1 point when the current bar is within the OTE retracement band for the active leg direction — the 61.8–78.6% retracement zone. Also a hard prerequisite in the setup conditions. Ensures the entry is at the institutionally optimal retracement depth, not at an arbitrary price within the leg range.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 3 — Premium/Discount Zone[/b]

Awards 1 point when price is in the correct zone relative to the leg equilibrium — below EQ (discount) for bull entries, above EQ (premium) for bear entries. The PD Zone layer enforces the institutional entry positioning principle: buy when price is cheap relative to the leg's fair value, sell when expensive. A valid OTE touch in the wrong PD zone (above EQ for a bull entry) carries a fundamental positioning problem — this layer blocks it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 4 — HTF Bias[/b]

Awards 1 point when the higher timeframe EMA structure (default: 60-minute, 21/55 EMA) agrees with the signal direction, using the same strict condition as SURGE and ANCHOR — the HTF fast EMA must be above the slow EMA and the HTF close must be above the fast EMA for a bull vote. A bull OTE entry against a bearish HTF is a counter-trend trade; this layer ensures PIVOT's signals align with the macro institutional flow.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 5 — Liquidity Sweep[/b]

Awards 1 point when a qualifying sweep has occurred within the three-bar recency window in the correct direction. A sweep before or coinciding with the OTE entry dramatically increases the probability that the pullback is a genuine institutional accumulation event rather than a mechanical retracement. When the Sweep Filter is disabled, this layer is not available for scoring — the total achievable score drops to 6 of 6 in that configuration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 6 — Rejection Candle[/b]

Awards 1 point when a qualifying bull rejection or bullish engulfing candle (long) or bear rejection or bearish engulfing candle (short) is present on the current bar. This is the candle confirmation layer — confirming that the institutional response to the OTE touch is visible and decisive on the current bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 7 — ADX + Volume Expansion[/b]

Awards 1 point when both the ADX filter and the volume expansion filter pass simultaneously. ADX confirms the market has directional strength rather than ranging. Volume exceeding the moving average confirms genuine institutional participation on the entry candle rather than a low-activity drift through the OTE zone. Both conditions must be true for the single layer point — they are evaluated jointly.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Two Setup Types — A and B[/b]

PIVOT fires signals through two distinct setup configurations, each representing a different institutional entry scenario. Both can be enabled simultaneously.

[b]Setup A — OTE Pullback:[/b]
The foundational PIVOT setup. Fires when the market structure is established (BOS or CHoCH has confirmed), the displacement leg is active, price pulls back into the 61.8–78.6% OTE zone, a rejection candle forms within the zone, and the full confluence stack meets the minimum score. This is the highest-frequency setup type — it captures the standard institutional pullback sequence following any qualifying structure event.

[b]Setup B — Sweep + CHoCH:[/b]
The premium PIVOT setup. Requires all Setup A conditions [i]plus[/i] a Change of Character within the lookback window (40 bars) [i]and[/i] a qualifying liquidity sweep within the three-bar recency window. The sequence is: liquidity sweep (stop hunt) → CHoCH (structural reversal confirmation) → OTE pullback (optimal entry). When all three institutional events converge simultaneously in the OTE zone with a rejection candle, this is among the highest-conviction setups available in the entire AlphaX indicator suite.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Structural Stop Loss Placement[/b]

PIVOT uses structurally anchored stop placement — the stop is placed beyond the most recent confirmed swing low (for bull entries) or swing high (for bear entries), plus a small configurable ATR buffer (default: 0.25× ATR).

[b]Why this is the correct stop for OTE entries:[/b] The OTE entry is made on the premise that the structural swing low (bull) or high (bear) will hold — it is the key level whose violation would invalidate the entire structural thesis. If price closes through the swing low after a bull OTE entry, the structure leg is negated, the displacement was a false break, and the position thesis is fundamentally wrong. The structural swing is therefore not an arbitrary stop choice — it is the precise price at which the trade is provably wrong.

This produces stops that adapt naturally to the leg size: large legs with distant swings produce wider stops and wider profit targets; tight legs with nearby swings produce tighter, higher-precision entries. The risk/reward is computed dynamically as `(close − slGuide) × TP Reward (R)`.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 16-row real-time dashboard displays the complete internal state across four sections.

[b]STRUCTURE[/b]
[list]
[*][b]Market Struct[/b] — current structural trend: ▲ BULLISH, ▼ BEARISH, or — NEUTRAL
[*][b]PD Zone[/b] — current position relative to leg equilibrium: ◧ DISCOUNT, ◧ PREMIUM, or — EQ
[*][b]Leg EQ[/b] — the exact leg equilibrium price (50% of the structure leg range) in real time
[*][b]OTE Band[/b] — the current OTE zone bottom and top prices. Updates live as the leg expands
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — higher timeframe EMA alignment: ▲ BULL, ▼ BEAR, or — FLAT
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF
[/list]

[b]LEVELS[/b]
[list]
[*][b]Swing Hi[/b] — the most recent confirmed fractal swing high price. This is the current sell-side liquidity level and bear structural reference
[*][b]Swing Lo[/b] — the most recent confirmed fractal swing low. The current buy-side liquidity level and bull structural stop reference
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull Score[/b] — live 0–7 confluence score. Background highlights yellow-green when threshold is met
[*][b]Bear Score[/b] — live 0–7 score. Background highlights red when threshold is met
[/list]

[b]Live confluence label:[/b] During BUILDING and active leg phases, a small label near the OTE zone on the last bar shows [b]B x/7 · S x/7[/b] in real time — identical to ANCHOR's live score display — so you can monitor confluence building without dashboard attention.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Structure Leg Box (purple, semi-transparent)[/b] — the dealing range of the current displacement leg from structural origin to current price extreme. Adapts as the leg evolves
[*][b]OTE Band Box (purple, deeper tint)[/b] — the 61.8–78.6% retracement zone of the current leg, extending two bars beyond the current bar for forward visibility
[*][b]Leg Equilibrium Line (purple dots)[/b] — the 50% midpoint of the structure leg, continuously updated
[*][b]Swing High Line (red dashed)[/b] — the most recent confirmed fractal swing high
[*][b]Swing Low Line (yellow-green dashed)[/b] — the most recent confirmed fractal swing low
[*][b]▲ Small Triangle (BOS Bull)[/b] — bullish Break of Structure, semi-transparent yellow-green
[*][b]▲ Large Triangle (CHoCH Bull)[/b] — bullish Change of Character, bright yellow-green, larger size
[*][b]▼ Small Triangle (BOS Bear)[/b] — bearish Break of Structure, semi-transparent red
[*][b]▼ Large Triangle (CHoCH Bear)[/b] — bearish Change of Character, bright red, larger size
[*][b]● Circle (optional, orange)[/b] — sweep detection markers when Show Sweep Markers is enabled
[*][b]▲ Large Triangle (bull signal)[/b] — PIVOT long entry. All conditions confirmed
[*][b]▼ Large Triangle (bear signal)[/b] — PIVOT short entry
[*][b]Live confluence label[/b] — B x/7 · S x/7 near the OTE zone on the current bar
[*][b]SL Guide (red dotted circles)[/b] — structural stop loss level below/above the swing reference
[*][b]TP Guide (yellow-green dotted circles)[/b] — dynamically computed reward target based on R multiple
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX PIVOT — Step by Step[/b]

[b]Step 1 — Identify the Structural Context[/b]
[list]
[*]Check the dashboard Market Struct row. ▲ BULLISH or ▼ BEARISH tells you the directional bias. — NEUTRAL means no structure is established — no setup can develop
[*]Note the Swing Hi and Swing Lo levels on the dashboard. These are the current liquidity pools and structural stop references
[*]Check HTF Bias — does the higher timeframe agree with the current structure? HTF alignment is worth 1 confluence point and significantly improves setup quality
[/list]

[b]Step 2 — Watch for a Structure Event[/b]
[list]
[*]A large bright ▲ CHoCH triangle below the bar marks a bullish Change of Character — the highest-priority structural event. The structure leg box and OTE zone will draw immediately
[*]A smaller ▲ BOS triangle marks a bullish Break of Structure — confirmation the trend is continuing
[*]After either event, the Structure Leg Box and OTE Band are drawn in real time. Note where the OTE zone sits in absolute price terms from the dashboard's OTE Band row
[/list]

[b]Step 3 — Wait for the OTE Pullback[/b]
[list]
[*]After the displacement, watch price retrace toward the OTE zone. The purple OTE box on the chart gives you the exact price boundaries
[*]Check PD Zone on the dashboard — for bull entries, you want ◧ DISCOUNT to confirm price is below the leg equilibrium when it enters the OTE
[*]Watch the live B x/7 score label near the OTE zone. As price approaches the zone, the score builds in real time
[/list]

[b]Step 4 — Enter on the PIVOT Signal[/b]
[list]
[*]A ▲ triangle at the OTE zone confirms all conditions — structure direction, OTE touch, PD zone, HTF bias, sweep (if applicable), rejection candle, and ADX/volume
[*]The SL guide is plotted below the structural swing low (bull) — your structural invalidation level
[*]The TP guide is plotted at the computed reward target based on your configured R multiple
[*]For Setup B signals (Sweep + CHoCH), all three institutional events have converged — this is the highest-conviction PIVOT entry available
[/list]

[b]Step 5 — Manage and Exit[/b]
[list]
[*]At the TP guide level, take partial or full profit
[*]If a new CHoCH fires in the opposite direction during the trade, the structure has reversed — this is the exit signal for any remaining position
[*]If price retests the OTE zone again during the same structural leg without triggering a new signal (cooldown active), wait for the cooldown to clear and assess whether the fresh confluence score still meets the minimum
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Market Struct shows — NEUTRAL[/b] — no structural direction is established. Without a confirmed BOS or CHoCH, the leg box and OTE zone have no directional context. Wait for a structural event to occur before looking for OTE entries
[*][b]HTF Bias opposes structure direction[/b] — a bullish current timeframe structure against a bearish HTF is a counter-trend setup. These carry significantly lower success rates. The HTF alignment layer will not score, reducing the confluence count
[*][b]Price is in the wrong PD zone for the setup direction[/b] — a bull entry above the leg equilibrium (premium) or a bear entry below (discount) means entering when price is institutionally expensive relative to the leg's fair value. The PD zone filter blocks these when enabled
[*][b]Score is at 4/7 and the minimum is 5/7[/b] — the setup is present but not enough layers confirm. Do not force entries when confluence is borderline
[*][b]Structure events (BOS/CHoCH) are flipping rapidly in both directions[/b] — alternating bull and bear structure events in quick succession indicate a choppy market with no clean trend. The OTE zones will be constantly resetting without producing completed pullback sequences
[*][b]OTE zone is very close to the swing low (bull) or swing high (bear)[/b] — when the OTE band and the structural stop reference are nearly at the same price, the risk/reward is poor. The stop would be just below the OTE entry. Reduce position size or pass the setup
[/list]

[b]The ideal PIVOT setup:[/b]
[list]
[*]CHoCH event followed by a clean displacement leg with a well-defined leg box
[*]Price retraces into the OTE zone while in discount (bull) or premium (bear)
[*]A qualifying sweep has occurred within the last three bars
[*]HTF Bias aligned with structure direction
[*]Rejection candle forms within the OTE zone
[*]Confluence score at 6/7 or 7/7
[*]ADX confirms trending and volume is expanding
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]📐 Real-time market structure engine — fractal pivot detection with configurable sensitivity, tracking BOS and CHoCH events with body-close confirmation mode
[*]📦 Structure Leg Box — automatically drawn from the structural origin to the current price extreme, expanding in real time as the leg develops
[*]🎯 Optimal Trade Entry zone — 61.8–78.6% Fibonacci retracement band computed from the structure leg, rendered as a live OTE box and displayed with exact price levels on the dashboard
[*]⚖ Leg Equilibrium line — 50% midpoint of the structure leg acting as the dynamic PD zone divider, plotted continuously and updated as the leg grows
[*]💧 Liquidity sweep detection — identifies stop-hunt events relative to the recent price range with configurable ATR depth and three-bar recency window
[*]🏅 Two setup types — Setup A (OTE Pullback after any BOS/CHoCH) and Setup B (Sweep + CHoCH + OTE — the highest-conviction institutional entry pattern)
[*]🕯 Dual candle confirmation — bullish/bearish rejection candles and engulfing candles both qualify, ensuring the OTE touch produced a genuine institutional reversal response
[*]🧠 7-layer confluence engine — Market Structure, OTE Touch, PD Zone, HTF Bias, Liquidity Sweep, Rejection Candle, and ADX + Volume Expansion all scored independently
[*]📊 Live confluence label near OTE zone — B x/7 · S x/7 displayed in real time on the current bar without requiring dashboard reference
[*]🎯 Structural stop loss — placed beyond the confirmed swing low (bull) or swing high (bear) plus ATR buffer, anchored to the genuine structural invalidation level
[*]💹 Dynamic TP target — computed as `risk × R multiple`, adapting to leg size rather than using a fixed ATR distance
[*]📡 HTF EMA bias filter — strict dual-condition HTF alignment (EMA crossover + price above fast EMA) for maximum higher timeframe conviction
[*]🕐 Session filter — restricts signals to configurable active trading hours
[*]📊 16-row live dashboard — Structure, Filters, Levels, and Confluence sections updated in real time
[*]🔔 6 alert conditions — long/short entry, bull/bear CHoCH, sweep low, sweep high
[*]🎨 Fully cohesive dual-tone color system — yellow-green for all bullish elements, red for all bearish, purple for structural reference levels and OTE zone, orange for sweeps
[*]⚙ Fully configurable — pivot length, structure break mode, OTE Fibonacci levels, sweep depth and lookback, setup types, confluence minimum, HTF timeframe and EMAs, ADX, volume filter, session, SL buffer, TP reward multiple, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Structure Engine[/b]
[list]
[*]Pivot Length (bars each side) — fractal sensitivity. 3 for scalping, 5 for standard intraday (default), 7+ for swing trading
[*]Structure Break: Close Only — when on, requires a candle body close beyond the swing level (default: on). Off = wick touch counts
[*]Show Active Swing Levels — toggle swing high and swing low dashed lines
[*]Show BOS / CHoCH Markers — toggle all structure event triangles
[*]CHoCH Only (hide BOS markers) — when on, only CHoCH events are marked. BOS events still update structure but are not labeled
[/list]

[b]Structure Leg & OTE[/b]
[list]
[*]Show Structure Leg Box — toggle the displacement leg dealing range box
[*]Show Leg Equilibrium (50%) — toggle the leg midpoint line
[*]Show OTE Band (62–79%) — toggle the Fibonacci retracement entry zone box
[*]OTE Fib Low — lower Fibonacci level of the OTE band (default: 0.618)
[*]OTE Fib High — upper Fibonacci level of the OTE band (default: 0.786)
[*]Require Premium / Discount — when on, longs require discount positioning, shorts require premium (default: on)
[/list]

[b]Liquidity Sweep[/b]
[list]
[*]Enable Sweep Filter — when on, Layer 5 scores the recent sweep and Setup B becomes available
[*]Show Sweep Markers — toggle optional orange circle markers at sweep detection bars
[*]Min Sweep Depth (xATR) — minimum wick extension beyond the reference extreme to qualify as a sweep (default: 0.1)
[*]Sweep Reference Lookback — bars used to define the recent high/low reference for sweep detection (default: 20)
[/list]

[b]Entries & Confluence[/b]
[list]
[*]Setup A · OTE Pullback — enable standard OTE pullback entries after BOS or CHoCH
[*]Setup B · Sweep + CHoCH — enable the premium sweep + reversal + OTE setup type
[*]Min Confluence Layers (of 7) — minimum score required for a signal (default: 5)
[*]Show Entry Signals — toggle signal triangles
[*]Show Confluence Label — toggle the live B/S score label near the OTE zone
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 8)
[/list]

[b]Filters[/b]
[list]
[*]HTF Trend Filter — toggle the higher timeframe EMA alignment requirement
[*]HTF Timeframe — the higher timeframe for EMA data (default: 60-minute)
[*]HTF Fast / Slow EMA — EMA periods on the HTF (defaults: 21 / 55)
[*]ADX Trend Filter — toggle the ADX strength requirement (default: off)
[*]ADX Length / ADX Minimum — ADX parameters (defaults: 14 / 18)
[*]Volume Expansion Confirm — when on, entry candle volume must exceed the moving average by the minimum multiplier
[*]Min Volume vs Avg — minimum volume ratio for the expansion filter (default: 1.1)
[*]Volume Avg Length — SMA length for the volume baseline (default: 20)
[*]Session Filter — toggle active hours restriction (default: off)
[*]Active Session — configurable session window
[/list]

[b]Exit Guidance[/b]
[list]
[*]ATR Length — lookback for ATR calculation (default: 14)
[*]Show SL / TP Guides — toggle stop and target dotted circle plots
[*]SL Buffer Beyond Swing (xATR) — additional ATR buffer beyond the structural swing stop reference (default: 0.25)
[*]TP Reward (R) — take profit distance as a multiple of the risk from entry to stop (default: 2.0)
[/list]

[b]Display[/b]
[list]
[*]Show Dashboard — toggle the full dashboard panel
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for bullish signals, fills, and labels
[*]Bear / Bear Bright — red family for bearish signals, fills, and labels
[*]Sweep / Alert — orange for sweep markers and alerts
[*]Equilibrium / OTE Band — purple for structural reference levels and OTE zone
[*]SL Guide / TP Guide — stop and target circle colors
[*]Bull / Bear Label Text — text color for signal labels
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (6 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Pivot Long Entry — all conditions confirmed for a long OTE setup. Signal label fired
[*]Pivot Short Entry — all conditions confirmed for a short OTE setup
[/list]

[b]Structure Alerts[/b]
[list]
[*]Pivot Bull CHoCH — bullish Change of Character detected. Watch for OTE pullback in discount zone
[*]Pivot Bear CHoCH — bearish Change of Character detected. Watch for OTE pullback in premium zone
[/list]

[b]Sweep Alerts[/b]
[list]
[*]Pivot Sweep Low — sell-side liquidity swept below recent lows. Potential long setup developing
[*]Pivot Sweep High — buy-side liquidity swept above recent highs. Potential short setup developing
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD on M5–M15[/b], with general suitability for major forex pairs and crypto on the same timeframes:
[list]
[*]Pivot Length at 5 — the classic fractal sensitivity for intraday gold and forex. Balances signal frequency with structural significance
[*]Close Only on — body close structure breaks eliminate the vast majority of wick-based false breaks on gold and volatile instruments
[*]Setup B (Sweep + CHoCH) on — the highest-quality setups on gold involve a sweep before the CHoCH, making this setup type particularly effective on XAUUSD
[*]HTF at 60-minute — the standard intraday reference for M5–M15 trading
[*]ADX filter off by default — the OTE + rejection candle requirements already provide strong quality filtering without needing ADX as an additional gate
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Pivot Length to 3, increase Cooldown to 5, reduce TP Reward to 1.5, use tight session filter
[*][b]H1–H4 swing trading[/b] — increase Pivot Length to 7–10, set HTF to Daily or Weekly, increase TP Reward to 3.0–4.0, increase SL Buffer to 0.5
[*][b]Crypto (BTC, ETH)[/b] — increase Sweep Depth to 0.2–0.3× ATR for the wider wicks typical of crypto, consider enabling ADX filter at 20
[*][b]Indices (NAS100, US30)[/b] — use Pivot Length 5–7, enable Session Filter to 09:30–16:00, enable ADX filter
[*][b]More signals[/b] — lower Min Confluence to 4, disable PD Zone requirement, enable Setup A only, reduce Cooldown
[*][b]Ultra-selective entries only[/b] — raise Min Confluence to 6 or 7, require Setup B only, enable ADX filter, enable Volume Expansion
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🎯 [b]OTE and Fibonacci pullback traders[/b] — PIVOT is the definitive quantitative implementation of the Optimal Trade Entry framework. Every component — structure detection, leg computation, Fibonacci zone rendering, and rejection confirmation — is automated and scored
[*]🏦 [b]Smart money concepts and ICT methodology traders[/b] — PIVOT encodes the CHoCH → displacement → OTE pullback sequence that forms the core of ICT's entry model. The Sweep + CHoCH setup type specifically captures the stop hunt → reversal → optimal entry sequence
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — the default settings are calibrated for intraday gold trading, where OTE pullbacks after CHoCH events are among the most consistent institutional patterns available
[*]📊 [b]Traders who want structure-defined risk[/b] — the structural stop placement means every trade has a stop at a genuinely meaningful level — the swing that would invalidate the structure thesis — rather than an arbitrary ATR distance
[*]🧠 [b]Systematic traders who want to quantify OTE entries[/b] — the 7-layer scoring system removes subjectivity from OTE trading. Every potential entry is scored objectively against the same seven criteria on every bar
[*]📈 [b]Traders who want to enter later at a better price[/b] — PIVOT's entire philosophy is about waiting for the pullback. If you consistently enter at breakouts and then watch price retrace before continuing, PIVOT is the solution — it waits for that retracement and enters at the optimal Fibonacci level within it
[*]⚠ [b]Traders who struggle with stop placement[/b] — the structural swing reference + ATR buffer produces a stop that makes structural sense. You are not guessing where to put the stop — the market's structure tells you exactly where it belongs
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Pivot detection, structure break logic, OTE zone calculation, and confluence scoring all finalize on confirmed bars only
[*]The pivot detection has an inherent offset of pivotLen bars — a pivot is only confirmed after pivotLen bars have passed on both sides. This is standard behavior for fractal-based pivot systems and is not repainting — it is the mathematical requirement for confirming the fractal pattern
[*]The Structure Leg Box and OTE Zone are redrawn only on the last bar for chart cleanliness. Historical bars retain signal markers and BOS/CHoCH labels but do not show outdated box overlays
[*]The CHoCH window for Setup B (40 bars) means a Sweep + CHoCH setup can fire up to 40 bars after the CHoCH event, as long as the OTE zone is still valid and all other conditions are met. On slower timeframes this window covers a wider clock-time range — adjust if needed
[*]The confluence label near the OTE zone is drawn only on the last bar. It is a real-time awareness tool, not a historical indicator
[*]Maximum 500 labels, 500 lines, and 80 boxes are rendered. On very active charts, the oldest markers may be removed by TradingView's limits
[*]The session filter is off by default — PIVOT's structural approach is timeframe and session-agnostic. Enable the session filter for instruments where specific sessions (London, NY) produce more reliable structure events
[*]The TP guide is computed dynamically as risk × R multiple. On bars where the swing reference and current price are very close (producing near-zero risk), the fallback is ATR × R multiple
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who know that the move has already started — and who want to enter it at the precise price where the institutions who created the move are still adding to their position.[/i]

## Source Code

````pine
// © AlphaX — PIVOT v1.0
// Smart Money Structure + OTE Pullback Engine — AlphaX branded (styled after ANCHOR).

//@version=6
indicator("[ A L P H A X ] PIVOT - Smart Money Structure", shorttitle="AlphaX PIVOT",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=80, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — STRUCTURE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpStruct = "Structure Engine"
pivotLen      = input.int(5, "Pivot Length (bars each side)", minval=2, maxval=20, group=grpStruct,
  tooltip="Fractal sensitivity. 5 suits 5–15m gold; 3 for scalping, 7+ for swing.")
bosCloseOnly  = input.bool(true, "Structure Break: Close Only", group=grpStruct,
  tooltip="ON = body close must break the level (cleaner, fewer false breaks).")
showSwingLn   = input.bool(true, "Show Active Swing Levels", group=grpStruct)
showStructEvt = input.bool(true, "Show BOS / CHoCH Markers", group=grpStruct)
structChochOnly = input.bool(false, "CHoCH Only (hide BOS markers)", group=grpStruct,
  tooltip="ON = only reversal flips on chart. Cleaner when BOS labels feel noisy.")

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — STRUCTURE LEG & OTE
// ═══════════════════════════════════════════════════════════════════════════════
grpOte = "Structure Leg & OTE"
showLegBox    = input.bool(true, "Show Structure Leg Box", group=grpOte,
  tooltip="Dealing range of the active impulse leg — same idea as ANCHOR trend segment.")
showEqLine    = input.bool(true, "Show Leg Equilibrium (50%)", group=grpOte)
showOteZone   = input.bool(true, "Show OTE Band (62–79%)", group=grpOte)
oteFibLo      = input.float(0.618, "OTE Fib Low",  minval=0.5, maxval=0.7, step=0.01, group=grpOte)
oteFibHi      = input.float(0.786, "OTE Fib High", minval=0.7, maxval=0.9, step=0.01, group=grpOte)
requirePdZone = input.bool(true, "Require Premium / Discount", group=grpOte,
  tooltip="Longs in discount (below leg EQ). Shorts in premium (above leg EQ).")

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — LIQUIDITY SWEEP
// ═══════════════════════════════════════════════════════════════════════════════
grpSweep = "Liquidity Sweep"
useSweep      = input.bool(true, "Enable Sweep Filter", group=grpSweep)
showSweepMk   = input.bool(false, "Show Sweep Markers", group=grpSweep,
  tooltip="Off by default — sweeps still count toward confluence when filter is on.")
sweepAtr      = input.float(0.1, "Min Sweep Depth (xATR)", minval=0.0, maxval=1.0, step=0.05, group=grpSweep)
sweepLookback = input.int(20, "Sweep Reference Lookback", minval=5, maxval=100, group=grpSweep)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — ENTRIES & CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════════
grpEntry = "Entries & Confluence"
enableOtePullback = input.bool(true, "Setup A · OTE Pullback", group=grpEntry,
  tooltip="After BOS/CHoCH displacement, enter on rejection inside the OTE band.")
enableSweepChoch  = input.bool(true, "Setup B · Sweep + CHoCH", group=grpEntry,
  tooltip="Liquidity grab + structure flip + OTE tap within the CHoCH window.")
minConf       = input.int(5, "Min Confluence Layers (of 7)", minval=4, maxval=7, group=grpEntry)
showSignals   = input.bool(true, "Show Entry Signals", group=grpEntry)
showConfLbl   = input.bool(true, "Show Confluence Label", group=grpEntry)
cooldown      = input.int(8, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpEntry)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
grpFilt = "Filters"
useHtf        = input.bool(true, "HTF Trend Filter", group=grpFilt)
htfTf         = input.timeframe("60", "HTF Timeframe", group=grpFilt)
htfFast       = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpFilt)
htfSlow       = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpFilt)
useAdx        = input.bool(false, "ADX Trend Filter", group=grpFilt)
adxLen        = input.int(14, "ADX Length", minval=5, maxval=50, group=grpFilt)
adxMin        = input.float(18.0, "ADX Minimum", minval=10, maxval=50, step=0.5, group=grpFilt)
useVolConfirm = input.bool(true, "Volume Expansion Confirm", group=grpFilt)
volMult       = input.float(1.1, "Min Volume vs Avg", minval=0.8, maxval=3.0, step=0.1, group=grpFilt)
volAvgLen     = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpFilt)
useSession    = input.bool(false, "Session Filter", group=grpFilt)
sessStart     = input.session("0700-2000", "Active Session", group=grpFilt)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — EXIT GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
grpExit = "Exit Guidance"
atrLen        = input.int(14, "ATR Length", minval=2, maxval=100, group=grpExit)
showExits     = input.bool(true, "Show SL / TP Guides", group=grpExit)
slBufferAtr   = input.float(0.25, "SL Buffer Beyond Swing (xATR)", minval=0.0, maxval=2.0, step=0.05, group=grpExit)
tp1RR         = input.float(2.0, "TP Reward (R)", minval=0.5, maxval=20, step=0.5, group=grpExit)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
showDash      = input.bool(true, "Show Dashboard", group=grpVis)
dashPos       = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

// ═══════════════════════════════════════════════════════════════════════════════
//  COLORS (ANCHOR palette)
// ═══════════════════════════════════════════════════════════════════════════════
grpColors = "Colors"
colBull       = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear       = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze    = input.color(#ff9800, "Sweep / Alert",      group=grpColors)
colNeutral    = input.color(#555555, "Neutral",            group=grpColors)
colEqLine     = input.color(#8b6fd0, "Equilibrium",        group=grpColors)
colOte        = input.color(#8b6fd0, "OTE Band",           group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
colLabelBull  = input.color(#0d0d0d, "Bull Label Text",    group=grpColors)
colLabelBear  = input.color(#ffffff, "Bear Label Text",    group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec    = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_adx(len) =>
    float up   = ta.change(high)
    float down = -ta.change(low)
    float plusDM  = up > down and up > 0 ? up : 0.0
    float minusDM = down > up and down > 0 ? down : 0.0
    float trVal   = ta.tr(true)
    float trRma   = ta.rma(trVal, len)
    float plusRma  = trRma != 0 ? 100 * ta.rma(plusDM, len) / trRma : 0.0
    float minusRma = trRma != 0 ? 100 * ta.rma(minusDM, len) / trRma : 0.0
    float sumDM = plusRma + minusRma
    float dx = sumDM != 0 ? 100 * math.abs(plusRma - minusRma) / sumDM : 0.0
    ta.rma(dx, len)

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volAvgLen)
rng    = math.max(high - low, syminfo.mintick)

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
htfOKLong  = not useHtf or htfBull
htfOKShort = not useHtf or htfBear

adxVal = f_adx(adxLen)
adxOK  = not useAdx or adxVal >= adxMin
volOK  = not useVolConfirm or volume >= volMa * volMult
inSession = not useSession or not na(time(timeframe.period, sessStart))

// ═══════════════════════════════════════════════════════════════════════════════
//  SWING PIVOTS & MARKET STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float swingHigh = na
var float swingLow  = na
var int   swingHighBar = na
var int   swingLowBar  = na
var int   structure = 0
var float prevSwingHigh = na
var float prevSwingLow  = na

bool mBosBull   = false
bool mChochBull = false
bool mBosBear   = false
bool mChochBear = false

if not na(ph)
    prevSwingHigh := swingHigh
    swingHigh := ph
    swingHighBar := bar_index - pivotLen

if not na(pl)
    prevSwingLow := swingLow
    swingLow := pl
    swingLowBar := bar_index - pivotLen

float breakHi = bosCloseOnly ? close : high
float breakLo = bosCloseOnly ? close : low

if not na(swingHigh) and breakHi > swingHigh and bar_index > nz(swingHighBar, 0)
    if structure <= 0
        mChochBull := true
        structure := 1
    else
        mBosBull := true
    swingHigh := breakHi
    swingHighBar := bar_index

if not na(swingLow) and breakLo < swingLow and bar_index > nz(swingLowBar, 0)
    if structure >= 0
        mChochBear := true
        structure := -1
    else
        mBosBear := true
    swingLow := breakLo
    swingLowBar := bar_index

bool structBreakBull = mBosBull or mChochBull
bool structBreakBear = mBosBear or mChochBear

// ── Structure leg (ANCHOR-style segment) ──────────────────────────────────────
var float legHigh = na
var float legLow  = na
var int   legDir  = 0
var int   legStartBar = 0
var box   legBox  = na
var box   oteBox  = na

if structBreakBull
    legLow  := nz(prevSwingLow, nz(swingLow, low))
    legHigh := breakHi
    legDir  := 1
    legStartBar := bar_index

if structBreakBear
    legHigh := nz(prevSwingHigh, nz(swingHigh, high))
    legLow  := breakLo
    legDir  := -1
    legStartBar := bar_index

if legDir != 0
    legHigh := math.max(legHigh, high)
    legLow  := math.min(legLow, low)

eqLevel    = legDir != 0 and not na(legHigh) and not na(legLow) ? (legHigh + legLow) / 2.0 : na
inDiscount = not na(eqLevel) and close < eqLevel
inPremium  = not na(eqLevel) and close > eqLevel
pdOKLong   = not requirePdZone or inDiscount
pdOKShort  = not requirePdZone or inPremium

float oteTop = na
float oteBot = na
if legDir == 1 and not na(legLow) and not na(legHigh)
    float leg = legHigh - legLow
    oteTop := legHigh - leg * oteFibLo
    oteBot := legHigh - leg * oteFibHi
else if legDir == -1 and not na(legLow) and not na(legHigh)
    float legS = legHigh - legLow
    oteBot := legLow + legS * oteFibLo
    oteTop := legLow + legS * oteFibHi

bool inOteLong  = legDir == 1 and not na(oteTop) and not na(oteBot) and low <= oteTop and low >= oteBot
bool inOteShort = legDir == -1 and not na(oteTop) and not na(oteBot) and high >= oteBot and high <= oteTop

// ── Liquidity sweeps ──────────────────────────────────────────────────────────
refLow  = ta.lowest(low[1], sweepLookback)
refHigh = ta.highest(high[1], sweepLookback)
sweepLong  = useSweep and low < refLow - sweepAtr * atrVal and close > refLow and close > open
sweepShort = useSweep and high > refHigh + sweepAtr * atrVal and close < refHigh and close < open
recentSweepLong  = sweepLong or sweepLong[1] or sweepLong[2]
recentSweepShort = sweepShort or sweepShort[1] or sweepShort[2]

// ── Candle triggers ───────────────────────────────────────────────────────────
bullReject = close > open and (close - low) / rng > 0.55
bearReject = close < open and (high - close) / rng > 0.55
bullEngulf = close > open and close[1] < open[1] and close >= open[1]
bearEngulf = close < open and close[1] > open[1] and close <= open[1]
bullTrig = bullReject or bullEngulf
bearTrig = bearReject or bearEngulf

// ── CHoCH window for Setup B ──────────────────────────────────────────────────
var int lastChochBullBar = na
var int lastChochBearBar = na
if mChochBull
    lastChochBullBar := bar_index
if mChochBear
    lastChochBearBar := bar_index

int chochWindow = 40
bool recentChochBull = not na(lastChochBullBar) and bar_index - lastChochBullBar <= chochWindow
bool recentChochBear = not na(lastChochBearBar) and bar_index - lastChochBearBar <= chochWindow

// ═══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE (7 layers — ANCHOR style)
// ═══════════════════════════════════════════════════════════════════════════════
int bullScore = (structure == 1 ? 1 : 0) + (inOteLong ? 1 : 0) + (pdOKLong ? 1 : 0) +
     (htfOKLong ? 1 : 0) + (recentSweepLong ? 1 : 0) + (bullTrig ? 1 : 0) + (adxOK and volOK ? 1 : 0)
int bearScore = (structure == -1 ? 1 : 0) + (inOteShort ? 1 : 0) + (pdOKShort ? 1 : 0) +
     (htfOKShort ? 1 : 0) + (recentSweepShort ? 1 : 0) + (bearTrig ? 1 : 0) + (adxOK and volOK ? 1 : 0)

setupOteLong  = enableOtePullback and structure == 1 and legDir == 1 and inOteLong and bullTrig and pdOKLong
setupOteShort = enableOtePullback and structure == -1 and legDir == -1 and inOteShort and bearTrig and pdOKShort
setupSweepLong  = enableSweepChoch and recentChochBull and recentSweepLong and inOteLong and bullTrig and pdOKLong
setupSweepShort = enableSweepChoch and recentChochBear and recentSweepShort and inOteShort and bearTrig and pdOKShort

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

bool bullSignal = showSignals and barstate.isconfirmed and (setupOteLong or setupSweepLong) and
     bullScore >= minConf and inSession and cooled and adxOK and volOK
bool bearSignal = showSignals and barstate.isconfirmed and (setupOteShort or setupSweepShort) and
     bearScore >= minConf and inSession and cooled and adxOK and volOK

if bullSignal or bearSignal
    lastSigBar := bar_index

// ── Exit guides (signal bar only — ANCHOR style) ─────────────────────────────
float slGuide = na
float tpGuide = na
if bullSignal
    slGuide := math.min(nz(swingLow, low), nz(legLow, low)) - slBufferAtr * atrVal
    float risk = close - slGuide
    tpGuide := risk > 0 ? close + risk * tp1RR : close + atrVal * tp1RR
if bearSignal
    slGuide := math.max(nz(swingHigh, high), nz(legHigh, high)) + slBufferAtr * atrVal
    float riskS = slGuide - close
    tpGuide := riskS > 0 ? close - riskS * tp1RR : close - atrVal * tp1RR

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS — draw on last bar only (clean chart)
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    if not na(legBox)
        box.delete(legBox)
        legBox := na
    if not na(oteBox)
        box.delete(oteBox)
        oteBox := na

    if showLegBox and legDir != 0 and not na(legHigh) and not na(legLow)
        legBox := box.new(legStartBar, legHigh, bar_index, legLow,
          border_color=color.new(colEqLine, 75), bgcolor=color.new(colEqLine, 94), border_width=1)

    if showOteZone and legDir != 0 and not na(oteTop) and not na(oteBot)
        oteBox := box.new(legStartBar, oteTop, bar_index + 2, oteBot,
          border_color=color.new(colOte, 55), bgcolor=color.new(colOte, 88), border_width=1)

plot(showEqLine and legDir != 0 ? eqLevel : na, "Leg EQ", color=color.new(colEqLine, 35), linewidth=1, style=plot.style_linebr)
plot(showSwingLn and not na(swingHigh) ? swingHigh : na, "Swing High", color=color.new(colBear, 55), linewidth=1, style=plot.style_linebr)
plot(showSwingLn and not na(swingLow) ? swingLow : na, "Swing Low", color=color.new(colBull, 55), linewidth=1, style=plot.style_linebr)

plot(showExits and not na(slGuide) ? slGuide : na, "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(tpGuide) ? tpGuide : na, "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)

bool showBosBull = showStructEvt and mBosBull and not structChochOnly
bool showBosBear = showStructEvt and mBosBear and not structChochOnly
bool showChBull  = showStructEvt and mChochBull
bool showChBear  = showStructEvt and mChochBear

plotshape(showBosBull, title="BOS Bull", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 30), size=size.tiny)
plotshape(showChBull, title="CHoCH Bull", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBullBr, 0), size=size.small)
plotshape(showBosBear, title="BOS Bear", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 30), size=size.tiny)
plotshape(showChBear, title="CHoCH Bear", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBearBr, 0), size=size.small)

plotshape(showSweepMk and sweepLong, title="Sweep Low", style=shape.circle, location=location.belowbar,
  color=color.new(colSqueeze, 40), size=size.tiny)
plotshape(showSweepMk and sweepShort, title="Sweep High", style=shape.circle, location=location.abovebar,
  color=color.new(colSqueeze, 40), size=size.tiny)

plotshape(bullSignal, title="Pivot Long", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.small)
plotshape(bearSignal, title="Pivot Short", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.small)

if showConfLbl and barstate.islast and legDir != 0
    string confTxt = "B " + str.tostring(bullScore) + "/7  ·  S " + str.tostring(bearScore) + "/7"
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    float lblY = legDir == 1 ? nz(oteBot, legLow) - atrVal * 0.4 : nz(oteTop, legHigh) + atrVal * 0.4
    label.new(bar_index, lblY, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD (ANCHOR layout)
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 16,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX PIVOT", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── STRUCTURE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    string trTxt = structure == 1 ? "▲ BULLISH" : structure == -1 ? "▼ BEARISH" : "— NEUTRAL"
    color  trClr = structure == 1 ? colBull : structure == -1 ? colBear : colNeutral
    table.cell(dash, 0, 2, "MARKET STRUCT", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, trTxt, text_color=trClr, text_size=size.small, bgcolor=dbg)

    string pdTxt = inDiscount ? "◧ DISCOUNT" : inPremium ? "◧ PREMIUM" : "— EQ"
    color  pdClr = inDiscount ? colBull : inPremium ? colBear : colNeutral
    table.cell(dash, 0, 3, "PD ZONE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, pdTxt, text_color=pdClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "LEG EQ", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, not na(eqLevel) ? str.tostring(eqLevel, format.mintick) : "—",
      text_color=colEqLine, text_size=size.small, bgcolor=dbg)

    string oteRng = not na(oteTop) and not na(oteBot) ? str.tostring(oteBot, format.mintick) + " / " + str.tostring(oteTop, format.mintick) : "—"
    table.cell(dash, 0, 5, "OTE BAND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, oteRng, text_color=colOte, text_size=size.tiny, bgcolor=dbg)

    table.cell(dash, 0, 6, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 6, "", bgcolor=secBg)

    table.cell(dash, 0, 7, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(adxVal, "#.#") + (adxOK ? " ✓" : " ✗"),
      text_color=adxOK ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "SESSION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, inSession ? "✓ ACTIVE" : "✗ OFF",
      text_color=inSession ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "─── LEVELS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 10, "", bgcolor=secBg)

    table.cell(dash, 0, 11, "SWING HI", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, not na(swingHigh) ? str.tostring(swingHigh, format.mintick) : "—",
      text_color=colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "SWING LO", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, not na(swingLow) ? str.tostring(swingLow, format.mintick) : "—",
      text_color=colBull, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 13, "", bgcolor=secBg)

    table.cell(dash, 0, 14, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 14, str.tostring(bullScore) + "/7" + (bullScore >= minConf ? " ✓" : ""),
      text_color=bullScore >= minConf ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 15, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 15, str.tostring(bearScore) + "/7" + (bearScore >= minConf ? " ✓" : ""),
      text_color=bearScore >= minConf ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="Pivot Long Entry",
  message="[AlphaX PIVOT] LONG — OTE structure setup fired.")
alertcondition(bearSignal, title="Pivot Short Entry",
  message="[AlphaX PIVOT] SHORT — OTE structure setup fired.")
alertcondition(mChochBull, title="Pivot Bull CHoCH",
  message="[AlphaX PIVOT] Bullish CHoCH — watch OTE pullback in discount.")
alertcondition(mChochBear, title="Pivot Bear CHoCH",
  message="[AlphaX PIVOT] Bearish CHoCH — watch OTE pullback in premium.")
alertcondition(sweepLong, title="Pivot Sweep Low",
  message="[AlphaX PIVOT] Liquidity sweep below lows.")
alertcondition(sweepShort, title="Pivot Sweep High",
  message="[AlphaX PIVOT] Liquidity sweep above highs.")
````
