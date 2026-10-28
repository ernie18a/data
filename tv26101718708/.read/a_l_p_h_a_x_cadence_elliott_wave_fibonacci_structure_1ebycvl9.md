# [ A L P H A X ] CADENCE - Elliott Wave + Fibonacci + Structure

- url: https://www.tradingview.com/script/1ebYcvL9-A-L-P-H-A-X-CADENCE-Elliott-Wave-Fibonacci-Structure/
- type: indicator
- pine_id: PUB;280fcc7dc9ed4b92b467046a1d8b1446
- version: 1.0

## Description

[b]AlphaX CADENCE — Elliott Wave + Fibonacci + Market Structure Engine: Live W2/W4 Golden Zone Pullbacks, W3 Momentum Breakout, RSI Divergence Exit Warnings & Fibonacci Extension Targets[/b]

AlphaX CADENCE is a professional-grade Elliott Wave and Fibonacci confluence system built around the most powerful and time-tested framework in technical analysis — the five-wave impulse and three-wave corrective structure that governs institutional price delivery across all timeframes and all markets. Where most Elliott Wave indicators focus on labeling historical waves after the fact, CADENCE is engineered for [i]live trade execution[/i]: it identifies the current wave phase in real time, marks the active golden Fibonacci pullback zone, and fires entry signals at the precise moment price enters the optimal entry window with market structure, higher timeframe bias, volume, and momentum confirmation all aligned. Four setup types — Wave 2 Golden Zone, Wave 4 Golden Zone, Wave 3 Momentum Breakout, and ABC Correction End — cover both pullback and breakout entries within the Elliott Wave framework. A dedicated RSI divergence exit warning system alerts you to potential Wave 5 exhaustion before the reversal strikes. Fibonacci extension targets (TP1 at Wave 1 high, TP2 at 1.618× extension) are computed automatically from the identified impulse leg. Designed for traders who want the rigor of Elliott Wave theory applied with quantitative precision, across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

〰 [b]The Elliott Wave Framework — Why Institutional Price Moves in Waves[/b]

Elliott Wave theory is one of the oldest and most institutionally respected frameworks in technical analysis. Its core observation is that market prices do not move randomly — they move in structured, repeating patterns that reflect the collective psychology of all participants. The primary pattern is the five-wave impulse:

[b]Impulse wave structure (bull):[/b]
[list]
[*][b]Wave 0 → Wave 1:[/b] The initial impulse move — institutions begin accumulating, price moves sharply higher
[*][b]Wave 1 → Wave 2:[/b] The first pullback — retail traders who missed the initial move sell back gains; Wave 2 never fully retraces Wave 1
[*][b]Wave 2 → Wave 3:[/b] The most powerful wave — institutional participation accelerates, Wave 3 is typically the longest and strongest impulse
[*][b]Wave 3 → Wave 4:[/b] A corrective pullback after Wave 3's extension, typically shallower than Wave 2; Wave 4 never enters Wave 1's territory in a valid impulse
[*][b]Wave 4 → Wave 5:[/b] The final impulse leg, often accompanied by declining momentum and RSI divergence as the move exhausts
[/list]

[b]Why the golden zone matters:[/b] Waves 2 and 4 are the pullback waves — the retracement phases where price temporarily retreats before the next impulse. The Fibonacci golden zone (61.8%–38.2% retracement of the prior wave) is where these pullbacks most frequently terminate and reverse. Entering at the golden zone means entering with the lowest possible risk relative to the impulse target — the tight stop is at the wave invalidation level, and the target is the next wave's extension.

CADENCE is built to detect when the market is in a Wave 2 or Wave 4 pullback, when price has entered the golden zone, and when a qualified rejection candle confirms the reversal — producing entries at the statistically optimal Fibonacci reversal level within a confirmed Elliott Wave structure.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌊 [b]The Wave Engine — Pivot-Based Leg Classification[/b]

CADENCE uses a real-time swing pivot detection system to classify the current Elliott Wave phase from confirmed price structure. On every bar, confirmed fractal pivot highs and lows are collected into a rolling swing array (configurable depth, default: 8 swings). The alternating sequence of highs and lows is then pattern-matched against Elliott Wave leg configurations.

[b]3-swing classification (W2 phase):[/b]
When the three most recent confirmed swings form the pattern Low → High → Low (for bull impulse), CADENCE identifies:
[list]
[*]W0 at the first low (impulse origin)
[*]W1 at the high (impulse peak)
[*]W2 in progress at the current low (the pullback)
[/list]

If W1 is above W0 (valid impulse direction), the wave phase is classified as [b]W2 PULL[/b] — the system is watching for the golden zone entry.

[b]5-swing classification (W4 phase):[/b]
When five confirmed swings form Low → High → Low → High → Low (bull), CADENCE identifies all five wave points (W0 through W4). When W3 is above W1 (confirming the wave hierarchy) and W1 is above W0, the phase is classified as [b]W4 PULL[/b] — the system is watching for the Wave 4 golden zone entry before the final Wave 5 push.

[b]Wave phase display:[/b] The current wave phase is displayed prominently on the dashboard as W2 PULL, W4 PULL, CORR, or SCAN. This single row tells you exactly where CADENCE believes the market is in its current impulse cycle.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Fibonacci Golden Zone — The Optimal Entry Window[/b]

The Fibonacci golden zone is the price range between the 38.2% and 61.8% retracement of the prior impulse wave. This zone, sometimes called the "golden pocket," represents the most common termination range for corrective waves within a healthy impulse structure.

[b]Wave 2 golden zone calculation:[/b]
[list]
[*]Zone top = W1 − (W1 − W0) × 38.2%
[*]Zone bottom = W1 − (W1 − W0) × 61.8%
[*]Three Fibonacci levels displayed: 38.2% (dotted), 50.0% (solid, the equilibrium), 61.8% (dotted)
[/list]

[b]Wave 4 golden zone calculation:[/b]
Computed from the W2 → W3 leg rather than the W0 → W1 leg, reflecting that Wave 4 corrects Wave 3 specifically:
[list]
[*]Zone top = W3 − (W3 − W2) × 38.2%
[*]Zone bottom = W3 − (W3 − W2) × 61.8%
[/list]

[b]Golden zone visualization:[/b]
A semi-transparent box spans the golden zone from the prior wave's start bar to 15 bars beyond the current bar. Yellow-green for bull zones, red for bear zones. The box extends forward in real time — you can see the target zone approaching as price pulls back toward it.

[b]In-zone detection:[/b]
Price is considered inside the golden zone when the bar's low (bull) or high (bear) reaches within the zone boundaries AND the candle closes on the correct side of the zone. The close-inside condition ensures the touch is a genuine rejection from within the zone rather than a pass-through.

[b]Live Fibonacci levels:[/b]
The 38.2%, 50%, and 61.8% retracement lines are plotted from the Wave 1 pivot bar to 15 bars beyond current, updating in real time as the wave structure develops. The 50% line is plotted as a brighter solid line — the golden pocket midpoint.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Four Live Setup Types[/b]

CADENCE fires signals through four distinct entry setups, each targeting a specific phase of the Elliott Wave cycle. Each has different risk/reward characteristics and different position within the wave sequence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]W2 Golden Zone — Wave 2 Pullback Entry[/b]

The most frequent high-conviction setup. Fires when price retraces into the 38.2%–61.8% golden zone of Wave 1 during an identified Wave 2 correction.

[b]Full conditions for long:[/b]
[list]
[*]Bull impulse identified (three-swing pattern W0→W1→W2)
[*]Wave phase is W2 PULL
[*]Market structure is bullish (or HTF is bullish as a fallback)
[*]The bar's low has entered the golden zone (between 38.2% and 61.8% retracement)
[*]The bar closes above the zone bottom — confirming rejection, not breakdown
[*]Wave 2 (the pullback) is holding above Wave 0 (the impulse origin) — the Elliott Wave rule that W2 never fully retraces W1 is validated
[*]The impulse leg (W1 − W0) is at least the minimum size (default: 1.0× ATR) — filtering micro-waves
[*]A qualifying bull trigger candle (rejection wick above 48% of range or bullish engulfing) is present
[/list]

[b]Stop placement:[/b] Below the minimum of W2 and W0 (the prior impulse origin) plus the ATR buffer. If price violates Wave 0, the impulse structure is invalid by Elliott Wave rules.

[b]Targets:[/b] TP1 at W1 (the prior wave high); TP2 at the close plus 1.618× the impulse leg distance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]W4 Golden Zone — Wave 4 Pullback Entry[/b]

The higher-conviction pullback setup. Wave 4 occurs after Wave 3 — the strongest and longest wave — has completed. The W4 correction offers the final opportunity to enter before Wave 5.

[b]Key differences from W2:[/b]
[list]
[*]Requires confirmed market structure (structure == 1 for bull, not just HTF fallback) — Wave 4 entries demand structural confirmation
[*]Golden zone is computed from the W2 → W3 leg (correcting Wave 3, not Wave 1)
[*]Requires five confirmed swings (W0 through W4) — a more mature wave count
[/list]

[b]Why W4 is high-conviction:[/b] By the time a Wave 4 is identifiable, the impulse sequence has completed three waves with Wave 3 confirming above Wave 1. The institutional participants who accumulated during Wave 2 are in strong profit and will add to positions during Wave 4. The golden zone for Wave 4 is the most actively defended pullback level in the entire five-wave sequence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]W3 Momentum Breakout — Wave 3 Entry[/b]

The highest-momentum setup. Fires when price breaks above the Wave 1 high (bull) or below the Wave 1 low (bear) during a Wave 2 or Wave 4 pullback phase — the moment Wave 3 begins.

[b]Long conditions:[/b]
[list]
[*]Wave phase is W2 PULL or W4 PULL (the correction is completing)
[*]Price closes above the last identified swing high (the Wave 1 level) in a single bar
[*]The prior bar was at or below the breakout level
[*]Market structure is bullish
[*]Impulse leg size meets the minimum threshold
[/list]

[b]The W3 breakout philosophy:[/b] The Wave 3 breakout is the moment institutional participation accelerates explosively — the "Wall of Worry" is cleared and the crowd that was short begins covering. Entering at this exact bar captures the beginning of the fastest and largest wave of the impulse. The risk is paying a higher price than the golden zone pullback entries, but the momentum confirmation is unambiguous.

[b]Target for W3 entries:[/b] TP1 is at entry + the full impulse leg distance (projecting a Wave 3 equal to Wave 1); TP2 is at the 1.618× extension.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]ABC Correction End — Three-Wave Reversal Entry[/b]

The counter-trend corrective setup. Disabled by default — the lower-conviction alternate wave scenario. Fires when a three-wave ABC correction retraces to the 61.8% level of the prior impulse with a rejection candle.

[b]ABC conditions (bull):[/b]
[list]
[*]Three-swing pattern confirms an ABC correction structure (Low → High → Low within a bull structure)
[*]Price reaches the 61.8% retracement of the A leg from the B peak
[*]Close recovers back above the 61.8% level
[*]Bull trigger candle confirms

[/list]

[b]Why ABC is off by default:[/b] ABC entries are counter-corrective — they attempt to catch the end of a pullback at a single Fibonacci level without the full five-wave context. They work well when the prior impulse was clean and the ABC is proportional, but carry higher failure rates in choppy or range-bound conditions. Enable this setup only after studying its behavior on your specific instrument and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]W5 RSI Divergence Exit Warning System[/b]

One of CADENCE's most valuable risk management features is the dedicated Wave 5 exhaustion detection system. When price is making new highs in a bull structure but the RSI is simultaneously making lower highs — a classic bearish divergence — the system plots small orange circles above the relevant bars as exit warnings.

[b]How the divergence is detected:[/b]
Using confirmed pivot highs and lows from both price and RSI, CADENCE identifies:
[list]
[*][b]Bearish divergence (bull W5 exhaustion):[/b] Price's pivot high exceeds the prior pivot high, but RSI's corresponding pivot is below its prior reading — price strength is not confirmed by momentum
[*][b]Bullish divergence (bear W5 exhaustion):[/b] Price's pivot low is below the prior low, but RSI's reading is above its prior — selling momentum is fading at lower prices
[/list]

[b]Why W5 divergence is the most important Elliott Wave exit signal:[/b] Wave 5 is structurally the most exhausted wave — it occurs after four prior waves have already moved in the impulse direction, and is frequently accompanied by declining institutional participation. RSI divergence at Wave 5 is the most reliable early warning of the corrective ABC wave that follows. The small orange circles appear at the divergence bars — not blocking entry signals (divergence can persist for multiple bars) but providing continuous awareness that the impulse is aging.

These exit warnings fire separate alert conditions — CADENCE W5 Exit Bear and W5 Exit Bull — allowing you to set targeted notifications that prompt profit-taking on active wave trades.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 10-Layer Confluence Engine[/b]

Every setup is scored through a 10-layer confluence system. The default minimum is 4 of 10, producing a relatively permissive signal environment. Raising the minimum to 6–7 restricts signals to the highest-conviction wave setups only.

[b]Layer 1 — Market Structure (1 point):[/b]
The current market structure state (bull or bear from the BOS/CHoCH engine) aligns with the signal direction. A W2 Golden Long in a bullish structure scores this point. A W2 Golden Long against a bearish structure does not.

[b]Layer 2 — Fibonacci Zone (1 point):[/b]
Price is inside the applicable golden zone (W2 zone for W2 entries, W4 zone for W4 entries). For W3 and ABC entries, this layer is always credited since those setups do not require Fibonacci zone confirmation.

[b]Layer 3 — Trigger Candle (1 point):[/b]
A qualifying bull or bear trigger candle is present — either a rejection pin bar (lower wick above 48% of range for bull) or a bullish engulfing. For W3 momentum entries, this layer is always credited since the breakout bar itself is the trigger.

[b]Layer 4 — HTF Bias (1 point):[/b]
The higher timeframe EMA structure agrees with the signal direction. Can be set as a hard block (requireHtf = on) or as a soft scoring layer (default: off). When HTF is disabled, this layer awards 1 neutral point.

[b]Layer 5 — Volume Expansion (1 point):[/b]
Current bar volume exceeds the volume moving average by the configured multiplier (default: 1.1×). Confirms institutional participation on the entry bar.

[b]Layer 6 — Non-Chop Market (1 point):[/b]
Choppiness Index is below the configured threshold. Also enforced as a hard gate — extreme chop blocks all signals regardless of wave count quality.

[b]Layer 7 — RSI Zone (1 point, optional):[/b]
RSI is in the appropriate zone for the signal direction — above the minimum for longs (default: 38), below the maximum for shorts (default: 62). Off by default — when enabled, adds a momentum context filter.

[b]Layer 8 — EMA Trend Filter (1 point, optional):[/b]
Price is on the correct side of the configurable EMA. Off by default — when enabled, adds a trend alignment filter.

[b]Layer 9 — RSI Momentum (1 point, optional):[/b]
RSI is actively rising (bull) or falling (bear) on the current bar — momentum is accelerating in the signal direction. Off by default.

[b]Layer 10 — Base Credit (1 point):[/b]
A flat credit awarded to all qualifying setups — the minimum point that acknowledges the setup type itself has passed its structural requirements. This ensures that even with optional filters disabled, the maximum achievable score is 10.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Fibonacci Extension Targets — Automatic TP Calculation[/b]

Every CADENCE signal produces two automatically computed take profit levels based on the identified impulse wave measurement.

[b]TP1 — Wave 1 High / Wave Projection:[/b]
For W2 and W4 golden zone entries, TP1 is set at the prior Wave 1 level — the high that preceded the current pullback. This is the minimum structural target: the expectation that Wave 3 or Wave 5 will at least reclaim Wave 1's high. For W3 momentum entries, TP1 is set at entry plus the full impulse leg distance (Wave 3 = Wave 1 in length).

[b]TP2 — 1.618× Extension:[/b]
The primary Fibonacci extension target, computed as `entry + impulse_leg × 1.618`. The 1.618 extension (the Golden Ratio) is the most common Wave 3 termination level and a standard Wave 5 target when Wave 3 is extended. This level is configurable (default: 1.618, range: 1.0–2.618).

[b]Visual output:[/b] TP1 is plotted as a lime-green dotted line. TP2 is plotted as a bright yellow-green dashed line at width 2. Both extend forward by the configured guide bars (default: 35). The stop loss is plotted as a red dotted line below the wave invalidation level plus ATR buffer.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 9-row real-time dashboard displays the complete wave analysis state.

[list]
[*][b]Wave Phase[/b] — W2 PULL, W4 PULL, CORR, or SCAN. The current position within the Elliott Wave cycle. Purple color
[*][b]Structure[/b] — BULL MS (bullish market structure), BEAR MS (bearish), or RANGE (no clear structural direction)
[*][b]Setup[/b] — the current or most recent setup name: W2 GOLDEN, W4 GOLDEN, W3 BREAK, ABC END, ARM LONG (golden zone approached but not yet triggered), ARM SHORT, or —. Color-coded by directional bias
[*][b]Layers[/b] — the current confluence score out of 10. Yellow-green when at or above the minimum threshold
[*][b]Chop[/b] — live Choppiness Index value. Yellow-green when clear, red when above the stand-aside threshold
[*][b]TP1[/b] — the current or most recent TP1 level. Shows — between signals
[*][b]TP2[/b] — the current or most recent TP2 level
[*][b]HTF[/b] — the higher timeframe EMA bias: UP, DOWN, or MIX
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Live Wave Path Lines[/b] — lines connecting the most recent confirmed swing pivots, color-coded yellow-green for bull impulse and red for bear impulse. Shows the current wave sequence structure directly on the price chart
[*][b]Golden Zone Box[/b] — semi-transparent box spanning the 38.2%–61.8% Fibonacci retracement zone from the prior wave. Yellow-green for bull, red for bear. Extends 15 bars forward and updates in real time as the wave structure evolves
[*][b]Fibonacci Levels[/b] — three horizontal dotted/solid lines at 38.2%, 50%, and 61.8% retracement from the Wave 1 pivot bar. The 50% level is the brightest solid line — the golden pocket center
[*][b]▲ Triangle (below bar, bright yellow-green)[/b] — bull entry signal. W2 Golden, W4 Golden, W3 Breakout, or ABC End
[*][b]▼ Triangle (above bar, bright red)[/b] — bear entry signal
[*][b]● Orange Circle (above bar)[/b] — W5 bearish RSI divergence exit warning
[*][b]● Orange Circle (below bar)[/b] — W5 bullish RSI divergence exit warning
[*][b]Entry Line (bull/bear color dashed)[/b] — entry close level extending guideExtend bars forward
[*][b]Stop Loss Line (red dotted)[/b] — structural stop below wave invalidation level plus ATR buffer
[*][b]TP1 Line (lime dotted)[/b] — first target at Wave 1 high or equal-leg projection
[*][b]TP2 Line (bright yellow-green dashed, width 2)[/b] — 1.618× Fibonacci extension target
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX CADENCE — Step by Step[/b]

[b]Step 1 — Read the Wave Phase[/b]
[list]
[*]Check the Wave Phase row on the dashboard. W2 PULL or W4 PULL means the system has identified a valid pullback phase — a setup may be approaching
[*]Confirm Structure — BULL MS for long setups, BEAR MS for short. If Structure shows RANGE, the wave context is weaker
[*]Check the golden zone box on the chart. Is it near current price? Is price approaching from above (bull W2 pullback)?
[/list]

[b]Step 2 — Watch the Golden Zone Approach[/b]
[list]
[*]When Setup shows ARM LONG, price is approaching the golden zone. Watch for a rejection candle forming inside or at the zone boundary
[*]Check Layers — if it is approaching the minimum threshold, a signal is likely imminent. Check HTF to confirm the macro direction
[*]The Fibonacci levels on the chart show the exact 38.2%, 50%, and 61.8% prices — monitor for price rejection specifically at the 61.8% level (the deepest golden zone entry) for the highest-conviction golden pocket entry
[/list]

[b]Step 3 — Enter on the Triangle Signal[/b]
[list]
[*]A ▲ triangle below the bar confirms all wave, Fibonacci, structural, and confluence conditions are met simultaneously. The setup name shows on the dashboard (W2 GOLDEN, W4 GOLDEN, W3 BREAK, ABC END)
[*]The SL line is at the structural wave invalidation level — if price closes below Wave 0 (W2 entries) or below Wave 2 (W4 entries), the Elliott Wave count is invalid. This is a structural stop, not arbitrary ATR
[*]TP1 is at the prior Wave 1 high — the minimum expectation for the next impulse wave
[*]TP2 is at the 1.618× Fibonacci extension — the classical Wave 3 or Wave 5 termination level
[/list]

[b]Step 4 — Monitor for W5 Exit Warnings[/b]
[list]
[*]As price advances toward TP2, watch for the orange W5 exit warning circles appearing above (bear divergence) or below (bull divergence) price bars
[*]When orange circles begin appearing regularly as price approaches TP2, consider taking full profit rather than holding for further extension
[*]A W5 divergence warning combined with price near TP2 is the strongest exit signal the system produces
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Wave Phase shows SCAN or CORR[/b] — the system has not yet identified a clear impulse structure with sufficient pivot history. SCAN means fewer than 3 qualified swings are stored; CORR means the three-swing pattern does not satisfy the impulse directional rules. Do not force entries without clear wave context
[*][b]Chop Index is red on the dashboard[/b] — the hard chop gate is active. Elliott Wave patterns are fundamentally trend-following structures and lose their predictive power in extreme chop. All signals are blocked
[*][b]Structure shows RANGE[/b] — no clear bullish or bearish market structure is established. W2 and W4 golden zone entries without structural support are lower quality. Consider waiting for a CHoCH or BOS to establish directional structure before entering
[*][b]Layers score is at minimum (4/10) with all optional filters disabled[/b] — the bare-minimum score means only the most basic conditions are met. In this environment, require a higher layer count (increase minimum to 5–6) or wait for more confluence factors to align
[*][b]W5 exit warnings are already appearing when entering[/b] — if orange circles are appearing before a new entry signal fires, RSI divergence is already present. This suggests the wave is potentially in a late W5 stage rather than a healthy W2 or W4. Do not enter a new position when existing divergence warnings are active
[*][b]Golden zone is very narrow (W4 zone nearly coincides with stop)[/b] — when the 38.2% and 61.8% levels are very close together (small Wave 3 leg), the golden zone provides minimal entry edge. The risk/reward is poor when the zone height is less than 0.5× ATR
[/list]

[b]The ideal CADENCE setup:[/b]
[list]
[*]Wave Phase W4 PULL with confirmed 5-swing structure
[*]Market structure BULL MS or BEAR MS — clear directional bias
[*]Price at or near the 61.8% golden zone boundary — the deepest valid pullback
[*]HTF aligned with impulse direction
[*]Volume expanding on the rejection bar
[*]Layers at 7–8 out of 10
[*]No W5 divergence warnings on the current sequence
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]〰 Real-time Elliott Wave classification — 3-swing (W2 phase) and 5-swing (W4 phase) pattern matching from confirmed fractal pivots, updated on every bar
[*]📐 Adaptive Fibonacci golden zone — 38.2%–61.8% retracement zone computed from the current wave's impulse leg, rendered as a live box and three labeled levels updating in real time
[*]📦 Live wave path visualization — lines connecting the most recent confirmed swing pivots, color-coded by impulse direction, showing the current wave sequence structure
[*]🏷 Four setup types — W2 Golden Zone, W4 Golden Zone, W3 Momentum Breakout, and ABC Correction End (optional) — covering both pullback and breakout entries within the wave framework
[*]📈 Fibonacci extension targets — TP1 at the Wave 1 high (minimum wave projection), TP2 at the configurable Fibonacci extension (default: 1.618×) automatically computed from the identified impulse leg
[*]⚠ W5 RSI Divergence Exit Warning — pivot-based RSI divergence detection produces orange warning circles as price approaches potential Wave 5 exhaustion, with dedicated alert conditions
[*]🧠 10-layer confluence engine — Market Structure, Fibonacci Zone, Trigger Candle, HTF Bias, Volume, Non-Chop, RSI Zone, EMA Filter, RSI Momentum, and Base Credit scored independently
[*]🛡 Wave-anchored structural stop — SL placed below the Elliott Wave invalidation point (Wave 0 for W2 entries, Wave 2 for W4 entries) plus ATR buffer — not an arbitrary distance
[*]📊 Live dashboard — Wave Phase, Structure, Setup, Layers, Chop, TP1, TP2, and HTF updated on every bar
[*]📡 JSON alerts on FIRED — structured alert payload with weapon, side, setup name, entry, SL, TP1, TP2 for webhook integration
[*]🔔 4 alert conditions — CADENCE Long, CADENCE Short, W5 Exit Bear Warning, W5 Exit Bull Warning
[*]⚙ Fully configurable — pivot length, minimum leg size, Fibonacci zone levels, extension target, RSI divergence settings, all four setup enables, confluence minimum, HTF parameters, all optional filters, chop gate, SL buffer, guide bars, wave path and golden box display, dashboard size, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Wave Engine[/b]
[list]
[*]Swing Pivot Length — fractal sensitivity for pivot detection (default: 5)
[*]ATR Length — ATR calculation lookback (default: 14)
[*]Min Leg Size (xATR) — minimum impulse leg height in ATR multiples for wave classification (default: 1.0)
[*]Swings Stored — rolling swing array depth (default: 8)
[/list]

[b]Fibonacci Zones[/b]
[list]
[*]Pullback Zone Low (Fib) — lower Fibonacci level of the golden zone (default: 0.382)
[*]Pullback Zone High (Fib) — upper Fibonacci level (default: 0.618)
[*]TP2 Extension — Fibonacci extension level for the full measured move target (default: 1.618)
[*]Show Active Fib Levels — toggle the 38.2%, 50%, and 61.8% horizontal lines
[/list]

[b]Market Structure[/b]
[list]
[*]BOS: Close Only — when on, structure breaks require a close beyond the swing level (default: on)
[/list]

[b]Live Setups[/b]
[list]
[*]W2 / W4 Golden Pullback — toggle both golden zone entry setup types
[*]W3 Momentum Breakout — toggle the Wave 3 breakout entry
[*]ABC Correction End — toggle the corrective three-wave reversal entry (default: off)
[*]W5 RSI Divergence Exit Warn — toggle the exit warning system
[*]RSI Length — RSI calculation period (default: 14)
[*]Divergence Lookback — bars for pivot-based RSI divergence detection (default: 14)
[/list]

[b]Confluence[/b]
[list]
[*]Min Layers (of 10) — minimum score to fire a signal (default: 4)
[*]Hard HTF Alignment — when on, counter-HTF signals are blocked (default: off)
[*]HTF Trend Bias / HTF Timeframe / HTF Fast / HTF Slow EMA — higher timeframe parameters
[*]Volume Confirm / Volume vs Avg / Volume Avg — volume expansion layer parameters
[*]RSI Momentum Filter — optional RSI direction filter (default: off)
[*]RSI Min (Long) / RSI Max (Short) — RSI zone thresholds when filter is enabled
[*]EMA Trend Filter / EMA Length — optional EMA directional filter (default: off)
[*]Block Extreme Chop / Choppiness Length / Chop Block Above — chop gate parameters
[*]Signal Cooldown (bars) — minimum bars between signals (default: 8)
[/list]

[b]Entry / Exit Guides[/b]
[list]
[*]Show SL + TP1 + TP2 — toggle the guide lines
[*]SL Buffer (xATR) — ATR buffer beyond the wave invalidation point (default: 0.25)
[*]Guide Extend (bars) — how many bars forward the guide lines project (default: 35)
[/list]

[b]Display[/b]
[list]
[*]Show Live Wave Path — toggle the swing-to-swing connecting lines
[*]Show Golden Zone Box — toggle the Fibonacci retracement zone box
[*]Show Entry Markers — toggle signal triangles
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Text Size — Standard / Small
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Wave Up — yellow-green for bullish waves, signals, and zones
[*]Bear / Wave Down — red for bearish elements
[*]Fib / Wave Accent — purple for Fibonacci levels, wave path, and neutral zone elements
[*]W3 / Exit Accent — orange for W3 breakout accents and W5 exit warning markers
[*]Stop Line / TP1 Line / TP2 Line — individual guide line colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (4 total + JSON)[/b]

[b]Entry Alerts[/b]
[list]
[*]CADENCE Long — all wave, Fibonacci, structure, and confluence conditions confirmed. JSON payload delivered with setup, entry, SL, TP1, TP2
[*]CADENCE Short — all conditions confirmed for a short wave setup. JSON payload delivered
[/list]

[b]Exit Warning Alerts[/b]
[list]
[*]CADENCE W5 Exit Bear — bearish RSI divergence detected at a price pivot high in a bull structure. Wave 5 exhaustion may be approaching
[*]CADENCE W5 Exit Bull — bullish RSI divergence detected at a price pivot low in a bear structure
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M15–H4[/b]:
[list]
[*]Pivot Length at 5 — captures meaningful structural swings without excessive sensitivity on intraday timeframes
[*]Min Leg Size at 1.0× ATR — filters micro-waves while capturing the significant legs that represent genuine Elliott impulses
[*]Fibonacci zone from 38.2% to 61.8% — the classic golden zone that encompasses the highest-probability pullback termination range
[*]HTF at 60-minute as a soft scoring layer — adds confluence when aligned without hard-blocking the counter-HTF wave setups that occasionally occur at institutional correction boundaries
[*]ABC Correction End off by default — the corrective pattern carries more interpretation risk and is better enabled only when the user has studied Elliott corrective structures
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M5 scalping[/b] — reduce Pivot Length to 3, reduce Min Leg Size to 0.5, increase Cooldown to 5–6 bars, reduce Guide Extend to 15–20
[*][b]H4–Daily swing trading[/b] — increase Pivot Length to 8–10, increase Min Leg Size to 1.5–2.0, increase TP2 Extension to 2.0–2.618, increase Min Layers to 5–6
[*][b]Crypto (BTC, ETH)[/b] — increase Min Leg Size to 1.5 for the larger swing amplitudes, increase Fibonacci zone to 0.382–0.786 for the deeper corrections common in crypto waves
[*][b]Higher confidence signals only[/b] — raise Min Layers to 6–7, enable Hard HTF Alignment, enable EMA Trend Filter and RSI Momentum Filter, disable ABC Correction End
[*][b]More signals[/b] — lower Min Layers to 3, enable ABC Correction End, disable Volume Confirm, reduce Min Leg Size to 0.5
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]〰 [b]Elliott Wave traders[/b] — CADENCE is the definitive quantitative implementation of the Elliott Wave trading framework for the AlphaX suite. Every component — swing identification, wave phase classification, golden zone computation, wave invalidation stop, Fibonacci extension target — is automated and applied consistently
[*]📐 [b]Fibonacci traders who want wave context[/b] — the Fibonacci zone in CADENCE is not a standalone level but a wave-specific retracement within a confirmed impulse structure. This context dramatically improves the reliability of Fibonacci entries compared to drawing retracement levels manually without wave classification
[*]🎯 [b]Pullback traders[/b] — the W2 and W4 golden zone setups are fundamentally the most optimal pullback entry in all of technical analysis — buying the deepest valid retracement within a confirmed trend impulse, with a stop at the structural invalidation point
[*]⚡ [b]Momentum traders[/b] — the W3 Momentum Breakout entry targets the beginning of the fastest and largest wave of the impulse sequence, providing explosive breakout entries within a wave-confirmed context
[*]🧠 [b]Systematic traders who want quantified wave analysis[/b] — the 10-layer scoring system and deterministic pivot-based classification replace the subjectivity of traditional Elliott Wave labeling with objective, repeatable criteria
[*]📈 [b]Traders who struggle with knowing when to exit trending trades[/b] — the W5 RSI divergence exit warning system provides early, systematic notification of impulse exhaustion — the most common and costly mistake in Elliott Wave trading is riding Wave 5 too long
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Pivot detection, wave classification, Fibonacci zone computation, and confluence scoring all finalize on confirmed bars only
[*]Elliott Wave classification requires a minimum of 3–5 confirmed swings in the rolling array. On charts with fewer than 200 bars of history, the wave phase may show SCAN until sufficient pivot history accumulates
[*]The wave path lines and golden zone box are redrawn on the last bar only for chart performance. Historical signal triangles and exit warnings are preserved on their original bars
[*]The minimum leg size filter (default: 1.0× ATR) ensures that only waves with meaningful price movement are classified. Very small swings below the ATR threshold are ignored by the wave engine, preventing micro-structure noise from producing false wave counts
[*]The W5 divergence detection uses pivot-based RSI comparison with a configurable lookback. The detection is based on confirmed pivots and is non-repainting, but the divergence signal appears at the confirmation bar (pivLen bars after the actual pivot), not at the pivot bar itself
[*]When both W2 and W4 conditions are simultaneously met (a rare occurrence in transition periods), W4 takes priority in the signal selection because W4 entries occur in more mature, structurally confirmed wave counts
[*]The indicator does not automatically label historical waves — it focuses on the live wave phase and active entry setups. For historical wave labeling, combine with a standalone Elliott Wave labeling tool
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that markets move in waves — and who want a system precise enough to position them at the exact Fibonacci level where the next wave begins.[/i]

## Source Code

````pine
// © AlphaX — CADENCE v1.3
// Elliott Wave + Fibonacci + Market Structure Engine.
// Live setups: W2/W4 golden-zone pullbacks, W3 momentum break, ABC correction end.
// Exits: Fib extensions + structure invalidation SL.

//@version=6
indicator("[ A L P H A X ] CADENCE ", shorttitle="AlphaX CADENCE",
  overlay=true, max_labels_count=50, max_lines_count=500, max_boxes_count=60, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  WAVE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpWave = "Wave Engine"
pivLen         = input.int(5, "Swing Pivot Length", minval=2, maxval=20, group=grpWave)
atrLen         = input.int(14, "ATR Length", minval=2, maxval=100, group=grpWave)
zigMinAtr      = input.float(1.0, "Min Leg Size (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpWave)
maxSwings      = input.int(8, "Swings Stored", minval=5, maxval=12, group=grpWave)

grpFib = "Fibonacci Zones"
fibLo          = input.float(0.382, "Pullback Zone Low (Fib)", minval=0.236, maxval=0.5, step=0.01, group=grpFib)
fibHi          = input.float(0.618, "Pullback Zone High (Fib)", minval=0.5, maxval=0.786, step=0.01, group=grpFib)
ext161         = input.float(1.618, "TP2 Extension", minval=1.0, maxval=2.618, step=0.01, group=grpFib)
showFib        = input.bool(true, "Show Active Fib Levels", group=grpFib)

grpStruct = "Market Structure"
bosCloseOnly   = input.bool(true, "BOS: Close Only", group=grpStruct)

grpSetups = "Live Setups"
enW2W4         = input.bool(true, "W2 / W4 Golden Pullback", group=grpSetups)
enW3           = input.bool(true, "W3 Momentum Breakout", group=grpSetups)
enAbc          = input.bool(false, "ABC Correction End", group=grpSetups,
  tooltip="Lower conviction — off by default. Enable only if you want corrective reversals.")
enDivExit      = input.bool(true, "W5 RSI Divergence Exit Warn", group=grpSetups)
rsiLen         = input.int(14, "RSI Length", minval=2, maxval=50, group=grpSetups)
divLookback    = input.int(14, "Divergence Lookback", minval=5, maxval=40, group=grpSetups)

grpConf = "Confluence"
minLayers      = input.int(4, "Min Layers (of 10)", minval=3, maxval=10, group=grpConf)
requireHtf     = input.bool(false, "Hard HTF Alignment", group=grpConf,
  tooltip="Off = HTF only adds confluence score. On = blocks counter-HTF entries.")
useHtf         = input.bool(true, "HTF Trend Bias", group=grpConf)
htfTf          = input.timeframe("60", "HTF Timeframe", group=grpConf)
htfFast        = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpConf)
htfSlow        = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpConf)
useVol         = input.bool(true, "Volume Confirm", group=grpConf)
volMult        = input.float(1.1, "Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpConf)
volLen         = input.int(20, "Volume Avg", minval=5, maxval=100, group=grpConf)
useRsiFilt     = input.bool(false, "RSI Momentum Filter", group=grpConf,
  tooltip="Off by default — adds score when on, not a hard block unless Min Layers is high.")
rsiMinLong     = input.float(38.0, "RSI Min (Long)", minval=30.0, maxval=55.0, step=1.0, group=grpConf)
rsiMaxShort    = input.float(62.0, "RSI Max (Short)", minval=45.0, maxval=70.0, step=1.0, group=grpConf)
useEmaFilt     = input.bool(false, "EMA Trend Filter", group=grpConf)
emaLen         = input.int(21, "EMA Length", minval=5, maxval=100, group=grpConf)
useChop        = input.bool(true, "Block Extreme Chop", group=grpConf)
chopLen        = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpConf)
chopMax        = input.float(62.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpConf)
cooldown       = input.int(8, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpConf)

grpExit = "Entry / Exit Guides"
showGuides     = input.bool(true, "Show SL + TP1 + TP2", group=grpExit)
slBufAtr       = input.float(0.25, "SL Buffer (xATR)", minval=0.0, maxval=2.0, step=0.05, group=grpExit)
guideExtend    = input.int(35, "Guide Extend (bars)", minval=10, maxval=80, group=grpExit)

grpVis = "Display"
showWavePath   = input.bool(true, "Show Live Wave Path", group=grpVis)
showGoldenBox  = input.bool(true, "Show Golden Zone Box", group=grpVis)
showSignals    = input.bool(true, "Show Entry Markers", group=grpVis)
showDash       = input.bool(true, "Show Dashboard", group=grpVis)
dashSize       = input.string("Standard", "Dashboard Text Size",
  options=["Standard", "Small"], group=grpVis)
dashPos        = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors (AlphaX Palette)"
colBull        = input.color(#c8e624, "Bull / Wave Up", group=grpColors)
colBullBr      = input.color(#d4f03a, "Bull Signal", group=grpColors)
colBear        = input.color(#ff1744, "Bear / Wave Down", group=grpColors)
colBearBr      = input.color(#ff5252, "Bear Signal", group=grpColors)
colLattice     = input.color(#8b6fd0, "Fib / Wave Accent", group=grpColors)
colPending     = input.color(#ff9800, "W3 / Exit Accent", group=grpColors)
colSlLine      = input.color(#ff1744, "Stop Line", group=grpColors)
colTp1Line     = input.color(#9ccc65, "TP1 Line (partial)", group=grpColors)
colTp2Line     = input.color(#c8e624, "TP2 Line (full target)", group=grpColors)
colNeutral     = input.color(#555555, "Neutral", group=grpColors)
colTextLt      = input.color(#cccccc, "Dash Text", group=grpColors)
colDashBg      = input.color(#1a1a1a, "Dash BG", group=grpColors)
colDashHeader  = input.color(#111111, "Dash Header", group=grpColors)
colDashSec     = input.color(#222222, "Dash Section", group=grpColors)
colDashFrame   = input.color(#c8e624, "Dash Frame", group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPES & STATE
// ═══════════════════════════════════════════════════════════════════════════════
type Swing
    float price
    int   bar
    bool  isHigh

type TradePlan
    bool   valid
    bool   bull
    string setup
    float  entry
    float  stop
    float  tp1
    float  tp2

var Swing[] swings = array.new<Swing>()
var int structure = 0
var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na
var float prevSwingHigh = na
var float prevSwingLow = na

var line[] fibLns = array.new_line()
var line[] guideLns = array.new_line()
var line[] waveLns = array.new_line()
var box[] waveBoxes = array.new_box()

var int lastSigBar = na
var int guideBar = na
var TradePlan activePlan = TradePlan.new(false, false, "", na, na, na, na)
var string dWave = "—"
var string dSetup = "—"
var string dBias = "—"
var int dLayers = 0
var float dTp1 = na
var float dTp2 = na

EMPTY_PLAN = TradePlan.new(false, false, "", na, na, na, na)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)
rng    = math.max(high - low, syminfo.mintick)
rsiVal = ta.rsi(close, rsiLen)
emaVal = ta.ema(close, emaLen)

float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0
bool chopOk = not useChop or chopIdx < chopMax

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
volOk    = not useVol or volume >= volMa * volMult

bool rsiOkLong  = not useRsiFilt or rsiVal >= rsiMinLong
bool rsiOkShort = not useRsiFilt or rsiVal <= rsiMaxShort
bool rsiMomLong  = not useRsiFilt or rsiVal > rsiVal[1]
bool rsiMomShort = not useRsiFilt or rsiVal < rsiVal[1]
bool emaOkLong  = not useEmaFilt or close > emaVal
bool emaOkShort = not useEmaFilt or close < emaVal

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_dashTitle(sz) =>
    sz == "Small" ? size.small : size.normal

f_dashBody(sz) =>
    sz == "Small" ? size.tiny : size.small

f_dashSub(sz) =>
    sz == "Small" ? size.tiny : size.small

f_pushSwing(float price, int b, bool isHigh) =>
    if swings.size() == 0 or swings.get(0).isHigh != isHigh
        if swings.size() > 0
            if math.abs(price - swings.get(0).price) < atrVal * zigMinAtr
                swings.set(0, Swing.new(price, b, isHigh))
            else
                swings.unshift(Swing.new(price, b, isHigh))
                if swings.size() > maxSwings
                    swings.pop()
        else
            swings.unshift(Swing.new(price, b, isHigh))
    true

f_bullTrig() =>
    (close > open and (close - low) / rng > 0.48) or (close > open and close[1] < open[1] and close >= open[1])

f_bearTrig() =>
    (close < open and (high - close) / rng > 0.48) or (close < open and close[1] > open[1] and close <= open[1])

f_layers(bool bull, bool structOk, bool fibOk, bool trig, bool rsiOk, bool emaOk, bool rsiMom) =>
    int n = 0
    n += structOk ? 1 : 0
    n += fibOk ? 1 : 0
    n += trig ? 1 : 0
    n += bull and htfBull and useHtf ? 1 : not bull and htfBear and useHtf ? 1 : useHtf ? 0 : 1
    n += volOk ? 1 : 0
    n += chopOk ? 1 : 0
    n += rsiOk ? 1 : 0
    n += emaOk ? 1 : 0
    n += rsiMom ? 1 : 0
    n += 1
    n

f_clearFib() =>
    for ln in fibLns
        if not na(ln)
            line.delete(ln)
    array.clear(fibLns)

f_clearWave() =>
    for ln in waveLns
        if not na(ln)
            line.delete(ln)
    for bx in waveBoxes
        if not na(bx)
            box.delete(bx)
    array.clear(waveLns)
    array.clear(waveBoxes)

f_clearGuide() =>
    for ln in guideLns
        if not na(ln)
            line.delete(ln)
    array.clear(guideLns)

f_drawFib(float y382, float y50, float y618, int x1, int x2) =>
    if showFib
        array.push(fibLns, line.new(x1, y382, x2, y382, color=color.new(colLattice, 40), style=line.style_dotted))
        array.push(fibLns, line.new(x1, y50, x2, y50, color=color.new(colLattice, 8), width=2))
        array.push(fibLns, line.new(x1, y618, x2, y618, color=color.new(colLattice, 40), style=line.style_dotted))
    true

f_drawGuide(TradePlan p, int x1) =>
    if showGuides and p.valid
        f_clearGuide()
        int x2 = x1 + guideExtend
        color entryCol = p.bull ? colBullBr : colBearBr
        array.push(guideLns, line.new(x1, p.entry, x2, p.entry, color=entryCol, style=line.style_dashed))
        array.push(guideLns, line.new(x1, p.stop, x2, p.stop, color=colSlLine, style=line.style_dotted))
        array.push(guideLns, line.new(x1, p.tp1, x2, p.tp1, color=colTp1Line, style=line.style_dotted))
        array.push(guideLns, line.new(x1, p.tp2, x2, p.tp2, color=colTp2Line, style=line.style_dashed, width=2))
    true

f_drawWavePath(float topGolden, float botGolden, int goldenBar, bool bullImp, bool bearImp) =>
    if showWavePath and swings.size() >= 2
        int n = math.min(swings.size(), bullImp or bearImp ? 5 : maxSwings)
        for i = n - 1 to 1
            Swing a = swings.get(i)
            Swing b = swings.get(i - 1)
            color lc = bullImp ? colBull : bearImp ? colBear : colLattice
            array.push(waveLns, line.new(a.bar, a.price, b.bar, b.price, color=color.new(lc, 10), width=2, style=line.style_solid))
        if showGoldenBox and not na(topGolden) and not na(botGolden)
            float gTop = math.max(topGolden, botGolden)
            float gBot = math.min(topGolden, botGolden)
            color gc = bullImp ? colBull : colBear
            array.push(waveBoxes, box.new(goldenBar, gTop, bar_index + 15, gBot,
              border_color=color.new(colLattice, 50), bgcolor=color.new(gc, 93), border_width=1))
    true

// ═══════════════════════════════════════════════════════════════════════════════
//  SWING PIVOTS & STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

bool mBosBull = false
bool mChochBull = false
bool mBosBear = false
bool mChochBear = false

if not na(ph)
    prevSwingHigh := swingHigh
    swingHigh := ph
    swingHighBar := bar_index - pivLen
    f_pushSwing(ph, bar_index - pivLen, true)

if not na(pl)
    prevSwingLow := swingLow
    swingLow := pl
    swingLowBar := bar_index - pivLen
    f_pushSwing(pl, bar_index - pivLen, false)

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

var int lastBosBullBar = na
var int lastBosBearBar = na
if mBosBull or mChochBull
    lastBosBullBar := bar_index
if mBosBear or mChochBear
    lastBosBearBar := bar_index

int bosWindow = 24
bool recentBullMs = not na(lastBosBullBar) and bar_index - lastBosBullBar <= bosWindow
bool recentBearMs = not na(lastBosBearBar) and bar_index - lastBosBearBar <= bosWindow

// ═══════════════════════════════════════════════════════════════════════════════
//  ELLIOTT WAVE CONTEXT (pivot-leg classification)
// ═══════════════════════════════════════════════════════════════════════════════
float w0 = na
float w1 = na
float w2 = na
float w3 = na
float w4 = na
float w5 = na
string wavePhase = "SCAN"
bool bullImpulse = false
bool bearImpulse = false

if swings.size() >= 3
    Swing s0 = swings.get(0)
    Swing s1 = swings.get(1)
    Swing s2 = swings.get(2)
    if not s0.isHigh and s1.isHigh and not s2.isHigh
        w0 := s2.price
        w1 := s1.price
        w2 := s0.price
        bullImpulse := w1 > w0
        wavePhase := bullImpulse ? "W2 PULL" : "CORR"
    else if s0.isHigh and not s1.isHigh and s2.isHigh
        w0 := s2.price
        w1 := s1.price
        w2 := s0.price
        bearImpulse := w1 < w0
        wavePhase := bearImpulse ? "W2 PULL" : "CORR"

if swings.size() >= 5
    Swing s0 = swings.get(0)
    Swing s1 = swings.get(1)
    Swing s2 = swings.get(2)
    Swing s3 = swings.get(3)
    Swing s4 = swings.get(4)
    if not s0.isHigh and s1.isHigh and not s2.isHigh and s3.isHigh and not s4.isHigh
        w0 := s4.price
        w1 := s3.price
        w2 := s2.price
        w3 := s1.price
        w4 := s0.price
        bullImpulse := w3 > w1 and w1 > w0
        wavePhase := bullImpulse ? "W4 PULL" : wavePhase
    else if s0.isHigh and not s1.isHigh and s2.isHigh and not s3.isHigh and s4.isHigh
        w0 := s4.price
        w1 := s3.price
        w2 := s2.price
        w3 := s1.price
        w4 := s0.price
        bearImpulse := w3 < w1 and w1 < w0
        wavePhase := bearImpulse ? "W4 PULL" : wavePhase

bool bullTrig = f_bullTrig()
bool bearTrig = f_bearTrig()

// ═══════════════════════════════════════════════════════════════════════════════
//  FIBONACCI ZONES
// ═══════════════════════════════════════════════════════════════════════════════
float fibTopB = na
float fibBotB = na
float fibTopS = na
float fibBotS = na
float y382B = na
float y50B = na
float y618B = na
float y382S = na
float y50S = na
float y618S = na

if bullImpulse and not na(w0) and not na(w1)
    float leg = w1 - w0
    y382B := w1 - leg * 0.382
    y50B := w1 - leg * 0.5
    y618B := w1 - leg * fibHi
    fibTopB := w1 - leg * fibLo
    fibBotB := w1 - leg * fibHi

if bearImpulse and not na(w0) and not na(w1)
    float legS = w0 - w1
    y382S := w1 + legS * 0.382
    y50S := w1 + legS * 0.5
    y618S := w1 + legS * fibHi
    fibTopS := w1 + legS * fibHi
    fibBotS := w1 + legS * fibLo

bool inGoldenB = bullImpulse and not na(fibTopB) and low <= fibTopB and low >= fibBotB and close >= fibBotB and bullTrig
bool inGoldenS = bearImpulse and not na(fibTopS) and high >= fibBotS and high <= fibTopS and close <= fibTopS and bearTrig

// W4 fib from W2–W3 leg
float w4TopB = na
float w4BotB = na
float w4TopS = na
float w4BotS = na
if bullImpulse and not na(w2) and not na(w3) and wavePhase == "W4 PULL"
    float leg34 = w3 - w2
    w4TopB := w3 - leg34 * fibLo
    w4BotB := w3 - leg34 * fibHi
if bearImpulse and not na(w2) and not na(w3) and wavePhase == "W4 PULL"
    float leg34s = w2 - w3
    w4TopS := w3 + leg34s * fibHi
    w4BotS := w3 + leg34s * fibLo

bool inW4B = not na(w4TopB) and low <= w4TopB and low >= w4BotB and close >= w4BotB and bullTrig
bool inW4S = not na(w4TopS) and high >= w4BotS and high <= w4TopS and close <= w4TopS and bearTrig

int goldenBar = swings.size() >= 2 ? swings.get(1).bar : bar_index
float goldenTop = wavePhase == "W4 PULL" and bullImpulse ? w4TopB : wavePhase == "W4 PULL" and bearImpulse ? w4TopS : bullImpulse ? fibTopB : bearImpulse ? fibTopS : na
float goldenBot = wavePhase == "W4 PULL" and bullImpulse ? w4BotB : wavePhase == "W4 PULL" and bearImpulse ? w4BotS : bullImpulse ? fibBotB : bearImpulse ? fibBotS : na

// ABC correction end (3-leg into 61.8% of prior impulse)
bool abcLong = false
bool abcShort = false
if swings.size() >= 3 and enAbc
    Swing a0 = swings.get(0)
    Swing a1 = swings.get(1)
    Swing a2 = swings.get(2)
    if not a0.isHigh and a1.isHigh and not a2.isHigh and structure == 1
        float abcLeg = a1.price - a2.price
        float abc618 = a1.price - abcLeg * 0.618
        abcLong := low <= abc618 and close > abc618 and f_bullTrig()
    if a0.isHigh and not a1.isHigh and a2.isHigh and structure == -1
        float abcLegS = a2.price - a1.price
        float abc618s = a1.price + abcLegS * 0.618
        abcShort := high >= abc618s and close < abc618s and f_bearTrig()

// ═══════════════════════════════════════════════════════════════════════════════
//  RSI DIVERGENCE (W5 exit warning)
// ═══════════════════════════════════════════════════════════════════════════════
float phRsi = ta.pivothigh(rsiVal, divLookback, divLookback)
float plRsi = ta.pivotlow(rsiVal, divLookback, divLookback)
bool bearDiv = false
bool bullDiv = false
if enDivExit and not na(ph) and not na(phRsi)
    float prevPh = ta.valuewhen(not na(ph), high[divLookback], 1)
    float prevR = ta.valuewhen(not na(phRsi), rsiVal[divLookback], 1)
    bearDiv := high[divLookback] > prevPh and rsiVal[divLookback] < prevR and structure == 1
if enDivExit and not na(pl) and not na(plRsi)
    float prevPl = ta.valuewhen(not na(pl), low[divLookback], 1)
    float prevRl = ta.valuewhen(not na(plRsi), rsiVal[divLookback], 1)
    bullDiv := low[divLookback] < prevPl and rsiVal[divLookback] > prevRl and structure == -1

// ═══════════════════════════════════════════════════════════════════════════════
//  LIVE SETUPS — high-conviction filters only
// ═══════════════════════════════════════════════════════════════════════════════
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

float impulseLegB = bullImpulse and not na(w0) and not na(w1) ? w1 - w0 : na
float impulseLegS = bearImpulse and not na(w0) and not na(w1) ? w0 - w1 : na
bool legSizeOkB = not na(impulseLegB) and impulseLegB >= atrVal * zigMinAtr
bool legSizeOkS = not na(impulseLegS) and impulseLegS >= atrVal * zigMinAtr
bool w2HoldB = not na(w2) and not na(w0) and w2 > w0
bool w2HoldS = not na(w2) and not na(w0) and w2 < w0

bool msLong  = structure == 1 or (structure == 0 and htfBull)
bool msShort = structure == -1 or (structure == 0 and htfBear)

bool w2Long = enW2W4 and bullImpulse and wavePhase == "W2 PULL" and msLong and
     inGoldenB and w2HoldB and legSizeOkB
bool w2Short = enW2W4 and bearImpulse and wavePhase == "W2 PULL" and msShort and
     inGoldenS and w2HoldS and legSizeOkS
bool w4Long = enW2W4 and bullImpulse and wavePhase == "W4 PULL" and structure == 1 and
     inW4B and legSizeOkB
bool w4Short = enW2W4 and bearImpulse and wavePhase == "W4 PULL" and structure == -1 and
     inW4S and legSizeOkS

float w1BreakBull = na
float w1BreakBear = na
if swings.size() >= 2
    Swing b0 = swings.get(0)
    Swing b1 = swings.get(1)
    if not b0.isHigh and b1.isHigh
        w1BreakBull := b1.price
    if b0.isHigh and not b1.isHigh
        w1BreakBear := b1.price

bool w3Long = false
bool w3Short = false
if enW3 and (wavePhase == "W2 PULL" or wavePhase == "W4 PULL")
    bool brkB = not na(w1BreakBull) and close > w1BreakBull and close[1] <= w1BreakBull
    bool brkS = not na(w1BreakBear) and close < w1BreakBear and close[1] >= w1BreakBear
    w3Long := msLong and brkB and legSizeOkB
    w3Short := msShort and brkS and legSizeOkS

bool fibZoneB = inGoldenB or inW4B
bool fibZoneS = inGoldenS or inW4S

int layW2L = f_layers(true, msLong, fibZoneB, bullTrig, rsiOkLong, emaOkLong, rsiMomLong)
int layW2S = f_layers(false, msShort, fibZoneS, bearTrig, rsiOkShort, emaOkShort, rsiMomShort)
int layW4L = f_layers(true, structure == 1, inW4B, bullTrig, rsiOkLong, emaOkLong, rsiMomLong)
int layW4S = f_layers(false, structure == -1, inW4S, bearTrig, rsiOkShort, emaOkShort, rsiMomShort)
int layW3L = f_layers(true, msLong, true, true, rsiOkLong, emaOkLong, rsiMomLong)
int layW3S = f_layers(false, msShort, true, true, rsiOkShort, emaOkShort, rsiMomShort)
int layAbcL = f_layers(true, structure == 1, true, bullTrig, rsiOkLong, emaOkLong, rsiMomLong)
int layAbcS = f_layers(false, structure == -1, true, bearTrig, rsiOkShort, emaOkShort, rsiMomShort)

bool htfOKLong  = not requireHtf or htfBull
bool htfOKShort = not requireHtf or htfBear

bool w2LongOk = w2Long and layW2L >= minLayers
bool w4LongOk = w4Long and layW4L >= minLayers
bool w3LongOk = w3Long and layW3L >= minLayers
bool abcLongOk = abcLong and layAbcL >= minLayers
bool w2ShortOk = w2Short and layW2S >= minLayers
bool w4ShortOk = w4Short and layW4S >= minLayers
bool w3ShortOk = w3Short and layW3S >= minLayers
bool abcShortOk = abcShort and layAbcS >= minLayers

bool bullSignal = showSignals and barstate.isconfirmed and cooled and chopOk and htfOKLong and
     (w4LongOk or w2LongOk or w3LongOk or abcLongOk)
bool bearSignal = showSignals and barstate.isconfirmed and cooled and chopOk and htfOKShort and
     (w4ShortOk or w2ShortOk or w3ShortOk or abcShortOk)

TradePlan plan = EMPTY_PLAN
if bullSignal
    string su = w4LongOk ? "W4 GOLDEN" : w2LongOk ? "W2 GOLDEN" : w3LongOk ? "W3 BREAK" : "ABC END"
    float sl = math.min(nz(w2, nz(w0, low)), nz(swingLow, low)) - slBufAtr * atrVal
    float impulse = math.max(nz(w1, close) - nz(w0, sl), atrVal)
    float tp1 = w3LongOk ? close + impulse : nz(w1, close + impulse * 0.618)
    float tp2 = close + impulse * ext161
    plan := TradePlan.new(true, true, su, close, sl, tp1, tp2)
    lastSigBar := bar_index
    dWave := wavePhase
    dSetup := su
    dBias := "BULL"
    dLayers := w4LongOk ? layW4L : w2LongOk ? layW2L : w3LongOk ? layW3L : layAbcL
    dTp1 := tp1
    dTp2 := tp2
    activePlan := plan
    guideBar := bar_index

if bearSignal
    string sus = w4ShortOk ? "W4 GOLDEN" : w2ShortOk ? "W2 GOLDEN" : w3ShortOk ? "W3 BREAK" : "ABC END"
    float sls = math.max(nz(w2, nz(w0, high)), nz(swingHigh, high)) + slBufAtr * atrVal
    float impulseS = math.max(nz(w0, sls) - nz(w1, close), atrVal)
    float tp1s = w3ShortOk ? close - impulseS : nz(w1, close - impulseS * 0.618)
    float tp2s = close - impulseS * ext161
    plan := TradePlan.new(true, false, sus, close, sls, tp1s, tp2s)
    lastSigBar := bar_index
    dWave := wavePhase
    dSetup := sus
    dBias := "BEAR"
    dLayers := w4ShortOk ? layW4S : w2ShortOk ? layW2S : w3ShortOk ? layW3S : layAbcS
    dTp1 := tp1s
    dTp2 := tp2s
    activePlan := plan
    guideBar := bar_index

if not bullSignal and not bearSignal
    dWave := wavePhase
    dBias := structure == 1 ? "BULL" : structure == -1 ? "BEAR" : "NEUTRAL"
    dSetup := inGoldenB or inW4B ? "ARM LONG" : inGoldenS or inW4S ? "ARM SHORT" : "—"
    int layBest = dBias == "BULL" ? math.max(layW2L, math.max(layW4L, math.max(layW3L, layAbcL))) :
         dBias == "BEAR" ? math.max(layW2S, math.max(layW4S, math.max(layW3S, layAbcS))) : 0
    dLayers := layBest

// ═══════════════════════════════════════════════════════════════════════════════
//  LIVE CHART OVERLAY (refresh on last bar)
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast
    f_clearFib()
    f_clearWave()
    if bullImpulse and not na(y50B) and swings.size() >= 2
        f_drawFib(y382B, y50B, y618B, swings.get(1).bar, bar_index + 15)
    else if bearImpulse and not na(y50S) and swings.size() >= 2
        f_drawFib(y382S, y50S, y618S, swings.get(1).bar, bar_index + 15)
    f_drawWavePath(goldenTop, goldenBot, goldenBar, bullImpulse, bearImpulse)
    if showGuides and activePlan.valid and not na(guideBar)
        f_drawGuide(activePlan, guideBar)

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS — clean markers, no on-chart text
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(bullSignal, title="Long Entry", style=shape.triangleup, location=location.belowbar,
  color=colBullBr, size=size.small)
plotshape(bearSignal, title="Short Entry", style=shape.triangledown, location=location.abovebar,
  color=colBearBr, size=size.small)

plotshape(bearDiv and enDivExit, title="Exit Warn Bear", style=shape.circle, location=location.abovebar,
  color=color.new(colPending, 30), size=size.tiny)
plotshape(bullDiv and enDivExit, title="Exit Warn Bull", style=shape.circle, location=location.belowbar,
  color=color.new(colPending, 30), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(getDashPos(dashPos), 2, 9,
  border_width=1, border_color=color.new(colDashFrame, 60),
  frame_width=1, frame_color=color.new(colDashFrame, 40))
if showDash and barstate.islast
    szTitle = f_dashTitle(dashSize)
    szBody = f_dashBody(dashSize)
    szSub = f_dashSub(dashSize)
    color biasCol = dBias == "BULL" ? colBull : dBias == "BEAR" ? colBear : colNeutral
    table.cell(dash, 0, 0, "CADENCE", text_color=colBull, bgcolor=colDashHeader, text_size=szTitle)
    table.cell(dash, 1, 0, "EW + FIB + MS", text_color=colTextLt, bgcolor=colDashHeader, text_size=szSub)
    table.cell(dash, 0, 1, "Wave Phase", text_color=colTextLt, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 1, 1, dWave, text_color=colLattice, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 0, 2, "Structure", text_color=colTextLt, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 1, 2, structure == 1 ? "BULL MS" : structure == -1 ? "BEAR MS" : "RANGE", text_color=biasCol, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 0, 3, "Setup", text_color=colTextLt, bgcolor=colDashSec, text_size=szBody)
    color setupCol = dBias == "BULL" ? colBullBr : dBias == "BEAR" ? colBearBr : colTextLt
    table.cell(dash, 1, 3, dSetup, text_color=setupCol, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 0, 4, "Layers", text_color=colTextLt, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 1, 4, str.tostring(dLayers) + " / 10", text_color=dLayers >= minLayers ? colBull : colNeutral, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 0, 5, "Chop", text_color=colTextLt, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 1, 5, str.tostring(chopIdx, "#.#"), text_color=chopOk ? colBull : colBear, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 0, 6, "TP1", text_color=colTextLt, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 1, 6, na(dTp1) ? "—" : str.tostring(dTp1, format.mintick), text_color=colTp1Line, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 0, 7, "TP2", text_color=colTextLt, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 1, 7, na(dTp2) ? "—" : str.tostring(dTp2, format.mintick), text_color=colTp2Line, bgcolor=colDashSec, text_size=szBody)
    table.cell(dash, 0, 8, "HTF", text_color=colTextLt, bgcolor=colDashBg, text_size=szBody)
    table.cell(dash, 1, 8, htfBull ? "UP" : htfBear ? "DOWN" : "MIX", text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, bgcolor=colDashBg, text_size=szBody)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, "CADENCE Long", "AlphaX CADENCE LONG — check chart for W2/W3/W4/ABC setup")
alertcondition(bearSignal, "CADENCE Short", "AlphaX CADENCE SHORT — check chart for W2/W3/W4/ABC setup")
alertcondition(bearDiv, "CADENCE W5 Exit Bear", "AlphaX CADENCE — bearish RSI divergence at highs (W5 exit caution)")
alertcondition(bullDiv, "CADENCE W5 Exit Bull", "AlphaX CADENCE — bullish RSI divergence at lows (W5 exit caution)")

if bullSignal
    alert('{"weapon":"CADENCE","side":"LONG","setup":"' + plan.setup + '","entry":' + str.tostring(close) + ',"sl":' + str.tostring(plan.stop) + ',"tp1":' + str.tostring(plan.tp1) + ',"tp2":' + str.tostring(plan.tp2) + '}', alert.freq_once_per_bar_close)
if bearSignal
    alert('{"weapon":"CADENCE","side":"SHORT","setup":"' + plan.setup + '","entry":' + str.tostring(close) + ',"sl":' + str.tostring(plan.stop) + ',"tp1":' + str.tostring(plan.tp1) + ',"tp2":' + str.tostring(plan.tp2) + '}', alert.freq_once_per_bar_close)
````
