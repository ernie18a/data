# [ A L P H A X ] MAGNET - Liquidity Magnet Engine

- url: https://www.tradingview.com/script/RnSmPShM-A-L-P-H-A-X-MAGNET-Liquidity-Magnet-Engine/
- type: indicator
- pine_id: PUB;5b3ab755c3ed4f9a8bbfc49ace617f94
- version: 1.0

## Description

[b]AlphaX MAGNET — Liquidity Magnet Engine: Hybrid Pool Detection, Sweep State Machine, Delayed Reclaim Entries, Absorption Pins, FVG Confluence & Weighted Scoring System[/b]

AlphaX MAGNET is a professional-grade liquidity-based trading system built around a single foundational observation: price is magnetically attracted to liquidity pools. Buy-side liquidity sitting above Equal Highs and sell-side liquidity sitting below Equal Lows are not random price levels — they are concentrations of institutional stop orders and pending market orders that price is consistently drawn toward before major directional moves begin. MAGNET detects these pools with a dual-method engine (pivot cluster analysis combined with Equal High/Equal Low range scanning), tracks every sweep event through a dedicated state machine, and fires precision entries through four distinct setup types — same-bar sweep and reclaim, delayed post-sweep reclaim, absorption pin bar, and FVG-liquidity overlap — scored through a weighted 9-point confluence system that rewards quality setup combinations over arbitrary filter accumulation. Unlike systems that suppress signals through cascading hard blocks, MAGNET is built on the philosophy that quality comes from the combination of setup type and confluence score, not from eliminating signal opportunities through excessive gating. Designed for active traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💧 [b]The Liquidity Pool Concept — Why Price Is Magnetic[/b]

Retail traders place stop losses at technically logical locations — just below swing lows (buy stops become sell orders when triggered, providing sell-side liquidity or SSL) and just above swing highs (sell stops become buy orders when triggered, providing buy-side liquidity or BSL). These clusters are not secrets. Institutional participants, who need massive liquidity to fill their position sizes, deliberately engineer price moves toward these clusters — hunting the stops to generate the counterparty order flow they need.

This creates a recurring, exploitable pattern:
[list]
[*]SSL pools below significant lows are swept — price dips below to trigger sell stops, filling institutional buy orders
[*]The sweep reverses sharply as the institutional position is filled and price moves in the intended direction
[*]BSL pools above significant highs are swept — price spikes above to trigger buy stops, filling institutional sell orders
[*]The spike reverses as the selling position is filled
[/list]

MAGNET is built to detect these pools before the sweep, identify the sweep the moment it occurs, and provide structured entry signals at the precise points where the institutional reversal is most likely to begin. The word "magnet" captures the system's core thesis: liquidity pools are not just price levels to avoid — they are targets that price is attracted to, and the moment after the sweep is the highest-probability institutional entry available.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 [b]The Hybrid Pool Detection Engine[/b]

MAGNET identifies liquidity pools using two independent methods running simultaneously, then combines their outputs to determine the single most relevant BSL and SSL level at any moment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Method 1 — Pivot Cluster Analysis[/b]

The first engine detects fractal swing highs and lows using a configurable pivot length (default: 5 bars each side) and tracks clusters of pivots near the same price level. Rather than marking every single pivot as a liquidity level, MAGNET uses a weighted averaging approach:

When a new pivot forms near an existing pivot level (within 1.5× the ATR pool tolerance), the two pivots are merged — the new cluster level is the weighted average of both, and the touch count increments. When a new pivot forms far from the existing cluster, a new level is established.

A pivot cluster only becomes an active liquidity pool when its touch count meets the minimum threshold (default: 2 pivot touches) and its age exceeds the minimum pool age (default: 3 bars). These two conditions ensure the pool represents genuine accumulated stop orders rather than a single swing point that may not yet have attracted meaningful liquidity.

[b]Why pivot clustering matters:[/b] A level touched twice or more has drawn retail traders to place stops at it on multiple occasions. Each time price revisits without breaking, more stops accumulate just beyond it. The cluster represents not a single trader's stop but a compounding concentration of stop orders — the largest and most powerful liquidity pools in the market.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Method 2 — Equal High / Equal Low (EQH/EQL) Range Scanning[/b]

The second engine scans the entire lookback window (default: 40 bars) to find the highest high and lowest low in the range, then counts how many bars within that window came within the ATR pool tolerance of those extremes. When the touch count meets the minimum EQ touch threshold (default: 2 touches), the extreme qualifies as a genuine Equal High (BSL pool) or Equal Low (SSL pool).

[b]Why EQH/EQL scanning is powerful:[/b] The highest level in a range with multiple near-touches is the quintessential Equal Highs pattern — the most widely recognized institutional liquidity target in smart money trading. Every time price approaches but fails to break through the level, another wave of retail traders places buy stops above it "in case it breaks." The more touches, the denser the liquidity cluster above. The EQL range scan identifies these levels objectively and in real time without requiring manual identification.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Pool Selection Logic[/b]

From both methods, MAGNET selects the single most relevant active BSL and SSL level at any moment. When both methods have identified a valid pool of the same type, the closer one to the current price is selected — the near-term liquidity target takes precedence over a more distant one. The active pools are displayed on the dashboard as exact prices and plotted as dashed lines extending forward on the chart.

[b]Magnet Above / Magnet Below:[/b] The active BSL (if above current price) is displayed as MAGNET ABOVE — the level price is currently being drawn toward on the upside. The active SSL (if below price) is MAGNET BELOW — the downside liquidity target. These two levels are also used as the take-profit targets when TP at Opposing Magnet is enabled, with the opposing pool being the natural delivery target after a sweep reversal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]The Sweep State Machine — Separating Sweeps from Entries[/b]

One of MAGNET's most important architectural decisions is the separation of the sweep detection from the entry signal. Many liquidity-based systems fire entries on the sweep bar itself — which frequently catches false sweeps, wicks that briefly cross the pool but are part of a larger continuation move, and cascade waterfall bars that are not genuine reversals.

MAGNET uses a [b]dedicated sweep state machine[/b] that tracks every sweep event independently from the entry logic:

[b]Sweep detection:[/b]
An SSL sweep is detected when the current bar's low extends below the active SSL pool by more than the minimum sweep depth (default: 0.10× ATR). A BSL sweep is detected when the high extends above the active BSL by more than the minimum depth. Both are registered in memory with the bar index and the exact pool level that was swept.

[b]Sweep window tracking:[/b]
After a sweep is registered, the system tracks how many bars have elapsed since the sweep. The configurable reclaim window (default: 8 bars) defines how long a sweep remains "fresh" for delayed reclaim entry qualification. The dashboard's SWEEP WINDOW row displays the active sweep state in real time — "SSL 2b ago" means an SSL sweep occurred 2 bars ago and the reclaim window is still open.

[b]Cascade block (same-bar only):[/b]
A "cascade" bar is a strong, large-body continuation bar in the trend direction — close below open, body above 0.45× ATR, closing below the structure EMA and 50 EMA (bear cascade). When a sweep coincides with a cascade bar on the [i]same bar[/i], the same-bar sweep entry (Setup A) is blocked — entering against a waterfall candle in the same bar is the highest-risk stop-hunt entry scenario. Critically, this block only applies to same-bar entries — the cascade does not prevent the delayed reclaim entries (Setup B) that fire on subsequent bars once the cascade has resolved.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Four Setup Types — Quality Through Combination[/b]

MAGNET's philosophy explicitly rejects quality-through-suppression. Rather than applying increasingly aggressive filters that block more and more signals, MAGNET provides four distinct setup types of varying quality, grades them A or B, scores them through the weighted confluence engine, and lets the score threshold determine which signals reach the chart. Each setup type captures a different institutional entry scenario.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup A — SSL/BSL Sweep + Same-Bar Reclaim (Grade A, Primary)[/b]

The highest-conviction single-bar pattern. Fires when the sweep and the reclaim occur within the same bar — the classic stop-hunt candle.

[b]Long conditions (SSL sweep + reclaim):[/b]
[list]
[*]Current bar's low extends below the active SSL pool by more than the minimum sweep depth
[*]The bar closes back above the SSL pool — the sweep was rejected within the same candle
[*]A qualifying bull trigger candle is present — close above open, body at least 0.22× ATR, and the close-to-low distance exceeds 50% of total range (strong rejection wick)
[*]The bar is not a cascade/waterfall bar — the same-bar cascade block applies
[/list]

[b]The institutional sequence:[/b] Price spikes below the SSL, triggering retail sell stops and filling institutional buy orders. Buyers immediately overwhelm the sell-stop flow and drive price back above the level within the same bar. This same-bar recovery is the clearest possible sign of genuine institutional absorption — they bought the stop-triggered selling and bid price back up in a single candle.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup B — Delayed SSL/BSL Reclaim (Grade A, Primary)[/b]

The most powerful setup type for catching genuine post-sweep reversals. Fires in the 1 to N bars following a sweep event — capturing entries that miss the same-bar candle.

[b]Long conditions (delayed SSL reclaim):[/b]
[list]
[*]A qualifying SSL sweep occurred within the reclaim window (1 to 8 bars ago — the current bar is not the sweep bar)
[*]The current bar's low is within ATR tolerance of the swept SSL level — price has returned to test the swept level
[*]The current bar closes above the swept level — reclaiming it from below
[*]A qualifying bull trigger candle confirms the reclaim with body and wick requirements
[/list]

[b]Why delayed reclaim is the highest-quality setup:[/b] Many genuine institutional sweep-and-reversal sequences do not complete in a single bar. After the sweep candle, price may consolidate below the swept level for 1–3 bars as retail traders interpret the sweep as a genuine breakdown and add to short positions. This consolidation below the swept level creates the highest-quality delayed reclaim entry — buying precisely as the "trapped shorts" below the swept level begin to be squeezed on the reclaim. Entries here have the swept level as a natural structural reference for the stop, the opposing BSL pool as a natural target, and the maximum available momentum from both the original sweep exhaustion and the trapped short squeeze.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup C — SSL/BSL Absorption Pin (Grade B, Secondary)[/b]

A volume-confirmed pin bar at the pool zone — institutional absorption without a full sweep event.

[b]Long conditions (SSL absorption):[/b]
[list]
[*]Price is at or near the active SSL zone (within ATR pool tolerance)
[*]A pin bar forms — lower wick exceeds 42% of the bar range, body is less than 38% of range, bar closes bullish
[*]Volume is spiking above the configured volume threshold (default: 1.05× average) — confirming institutional activity at the zone
[*]The bar closes above the SSL level — the absorption is from the buy side
[/list]

[b]The absorption scenario:[/b] Not every institutional accumulation at a liquidity pool involves a dramatic sweep. Sometimes institutions absorb all available sell-side liquidity at the SSL boundary without price needing to fully breach the level — the large volume at the pin bar low represents the same buying activity, just without the stop-triggering violation. The combination of the pin bar rejection shape and the volume spike at the zone is the visual and volumetric evidence of this absorption.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup D — FVG + SSL/BSL Magnet Confluence (Grade B, Secondary)[/b]

The institutional structure overlap entry — a Fair Value Gap forming directly at the liquidity pool level.

[b]Long conditions (FVG + SSL magnet):[/b]
[list]
[*]A bullish Fair Value Gap is present on the current bar — the current bar's low is above the high of the bar two bars ago, creating a gap in the price structure
[*]The FVG zone (between the current bar's low and the two-bars-ago high) overlaps with the active SSL pool level within ATR tolerance
[*]A qualifying bull trigger candle confirms
[/list]

[b]The FVG-liquidity overlap concept:[/b] When a bullish FVG coincides with an SSL pool level, two independent institutional frameworks are pointing to the same price zone simultaneously. The FVG represents an imbalance in order flow that price will fill. The SSL pool represents a liquidity concentration that price is magnetically drawn toward. When they overlap at the same level, the zone has double-layer institutional significance — it is both an unfilled order imbalance and a liquidity pool, making it the highest-value structural level available at that moment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Weighted Confluence Scoring — Quality Through Combination[/b]

MAGNET uses a [b]weighted scoring system[/b] where primary setups (A and B — sweep and reclaim) count for 2 points while secondary setups (C and D — absorption and FVG) count for 1 point. The remaining 7 points come from confluence quality layers. The default minimum threshold is 5 points.

[b]Score structure (maximum: 9 points):[/b]
[list]
[*][b]Setup Type (2 points for primary, 1 for secondary)[/b] — the foundational quality weighting. A sweep or delayed reclaim inherently carries more institutional evidence than an absorption or FVG overlap
[*][b]Active Pool Valid (1 point)[/b] — the SSL (for bull) or BSL (for bear) pool is currently active and qualified. Signals without a valid pool cannot score this point — there is no institutional liquidity reference without a qualified pool
[*][b]HTF Bias Alignment (1 point)[/b] — the higher timeframe EMA structure agrees with the signal direction. Unlike most AlphaX systems where HTF is a hard block, MAGNET treats HTF as a soft confluence layer — counter-HTF trades can still fire if other confluence is sufficient. This reflects the reality that sweep-and-reclaim sequences frequently work counter-HTF precisely because institutions are sweeping retail positions that were trading with the HTF trend
[*][b]Volume Layer (1 point)[/b] — current bar volume meets or exceeds the volume spike threshold. Confirms institutional participation on the signal bar
[*][b]Structural Bias (1 point)[/b] — price is above the Structure EMA or RSI is above 45 for longs (close > structure EMA or RSI > 45); price below EMA or RSI < 55 for shorts. This dual condition accepts both trend-aligned and momentum-recovering entries
[*][b]RSI Exhaustion (1 point)[/b] — RSI below 38 for longs with a recent SSL sweep, or RSI above 62 for shorts with a recent BSL sweep. This bonus point rewards entries where the RSI is genuinely oversold or overbought at the sweep level — the classic exhaustion reversal condition that historically produces the sharpest recoveries
[*][b]Non-Chop Market (1 point)[/b] — Choppiness Index below the configured threshold (default: 65). Also enforced as a hard gate — unlike the HTF, extreme chop does block all signals regardless of score
[*][b]At Pool Zone (1 point)[/b] — the current bar is within the pool tolerance of the active SSL (bull) or BSL (bear) zone. Rewards entries that are precisely positioned at the institutional level
[/list]

[b]Score examples:[/b]
A primary sweep reclaim (2 points) with valid pool, HTF alignment, volume, structural bias, and non-chop market reaches 7/9 — a high-conviction signal. A secondary FVG entry (1 point) with valid pool, volume, structural bias, and non-chop but no HTF alignment reaches 5/9 — the minimum threshold. The scoring naturally produces a gradient of signal quality without hard-blocking any combination.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Magnet-Anchored Stop Loss and Target[/b]

[b]Stop Loss Placement:[/b]
For bull signals, the stop is placed at the minimum of the current bar's low and the swept SSL level (using the stored sweep level from the state machine when a sweep occurred), minus the configured ATR buffer (default: 1.0× ATR). For bear signals, the maximum of the bar's high and the swept BSL level plus the ATR buffer.

This produces stops anchored to the structural invalidation point — the level that proves the institutional thesis wrong. A bull stop below the swept SSL means: if price closes below the sweep level after the reclaim, the sweep thesis has failed and institutions are not actually buying at this level.

[b]Take Profit — Opposing Magnet (default: on):[/b]
When TP at Opposing Magnet is enabled, the take profit target is automatically set to the opposing liquidity pool — the BSL pool above price for long entries, the SSL pool below for shorts. This is the single most powerful TP mechanic available for liquidity-based trading: after a sweep of the SSL, the natural delivery target is the opposing BSL pool, because institutions who bought the SSL sweep will deliver price toward the next concentration of liquidity above. The magnet-to-magnet target represents the true institutional delivery destination.

When no opposing magnet is available (pool not yet qualified), the fallback is a configurable R-multiple target (default: 2.5R).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 17-row real-time dashboard displays the complete internal state across five sections.

[b]LIQUIDITY[/b]
[list]
[*][b]BSL (EQH)[/b] — the active buy-side liquidity pool price. The current institutional overhead target. Red dashed line on chart with BSL · EQH label
[*][b]SSL (EQL)[/b] — the active sell-side liquidity pool price. The current institutional downside target. Yellow-green dashed line with SSL · EQL label
[*][b]Magnet Above[/b] — the BSL pool when it is above current price — the upside delivery target
[*][b]Magnet Below[/b] — the SSL pool when below current price — the downside delivery target
[/list]

[b]SWEEP STATE[/b]
[list]
[*][b]Sweep Window[/b] — live sweep state: "SSL 2b ago" when within the reclaim window, "BSL 3b ago" for BSL sweeps, or — IDLE when no recent sweep is active. This is the critical pre-signal awareness row — when it shows an active sweep state, Setup B entries are monitoring for the reclaim
[/list]

[b]SETUPS[/b]
[list]
[*][b]Long Setup[/b] — the currently active long setup type: SWEEP, RECLAIM, ABSORB, FVG, or — when none is active
[*][b]Short Setup[/b] — the currently active short setup type
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — ▲ BULL, ▼ BEAR, or — FLAT. Soft confluence layer for scoring
[*][b]Chop Index[/b] — live Choppiness Index value. Orange when above the block threshold — the only hard filter in MAGNET
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull / Bear[/b] — live scores displayed as "x / y" with a ▲ or ▼ arrow when either score meets the minimum threshold
[*][b]Playbook[/b] — the current actionable state: LONG A, SHORT A, LONG B, SHORT B when a signal just fired; WATCH RECLAIM ▲ or ▼ during active sweep windows; WATCH MAGNETS when pools are defined but no active sweep
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]BSL Pool Line (red dashed)[/b] — the active buy-side liquidity level with "BSL · EQH" label extending to the right. Redrawn on the last bar to reflect the current pool state
[*][b]SSL Pool Line (yellow-green dashed)[/b] — the active sell-side liquidity level with "SSL · EQL" label
[*][b]▲ Large Triangle (below bar, yellow-green)[/b] — Grade A long signal. SSL sweep or delayed reclaim with qualifying confluence
[*][b]▲ Small Triangle (below bar, dim yellow-green)[/b] — Grade B long signal. Absorption pin or FVG magnet setup
[*][b]▼ Large Triangle (above bar, red)[/b] — Grade A short signal
[*][b]▼ Small Triangle (above bar, dim red)[/b] — Grade B short signal
[*][b]● Sweep Circles (optional, orange)[/b] — appear above (BSL sweep) or below (SSL sweep) the bar when a sweep event is detected. Off by default — sweeps are tracked internally regardless of marker visibility
[*][b]SL Guide (red dotted circles)[/b] — sweep-anchored stop loss below or above the pool level
[*][b]TP Guide (yellow-green dotted circles)[/b] — opposing magnet target or R-multiple fallback
[*][b]Live confluence label[/b] — B x · S x near the current price on the last bar, updating in real time
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX MAGNET — Step by Step[/b]

[b]Step 1 — Read the Liquidity Map[/b]
[list]
[*]Check the dashboard BSL and SSL rows. These are the current institutional targets — price will be drawn toward both levels over time. Note which is closer to current price
[*]Check Magnet Above and Magnet Below. These are your directional delivery destinations. If SSL is below and BSL is above, the market is sandwiched between two magnets — the next major move will likely target one of them
[*]Note the Chop Index. When it is approaching or above the threshold (65), the liquidity pool targets lose reliability — pools become harder to reach when the market is oscillating without direction
[/list]

[b]Step 2 — Monitor the Sweep Window[/b]
[list]
[*]The Sweep Window row is the most critical pre-signal dashboard row. "SSL 1b ago" means an SSL sweep just occurred one bar ago and the reclaim window is wide open — Setup B is actively scanning the next bars for a qualifying reclaim candle
[*]WATCH RECLAIM ▲ in the Playbook row is the highest-priority alert state. Prepare your entry parameters immediately — the delayed reclaim may fire on the very next qualifying bar
[*]Watch the chart for the reclaim candle forming at or above the swept SSL level with a bullish rejection body
[/list]

[b]Step 3 — Enter on the MAGNET Signal[/b]
[list]
[*]A large ▲ triangle (Grade A) confirms a sweep or delayed reclaim with qualifying confluence. This is the primary MAGNET entry
[*]A small ▲ triangle (Grade B) confirms an absorption or FVG setup. Valid entry with slightly lower setup-type evidence — manage with smaller size if preferred
[*]The SL guide is plotted below the swept level plus ATR buffer. Your structural invalidation
[*]The TP guide points to the opposing BSL magnet when available — the institutional delivery target. When this lines up with the opposing pool, you have a magnet-to-magnet trade with a clear institutional narrative
[/list]

[b]Step 4 — Manage the Trade[/b]
[list]
[*]Monitor the Sweep Window — if a new sweep of the opposing pool occurs while you are in a trade, it may be a signal that the delivery is completing or extending
[*]When price approaches the MAGNET ABOVE level (for long trades), consider taking partial profit — the opposing pool is the target but also potential new resistance
[*]If a new valid sweep of your entry SSL occurs in the opposite direction during the trade, this could indicate the SSL was not the final sweep — reassess the position
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Chop Index above threshold[/b] — this is the only hard filter in MAGNET. All signals are blocked. More importantly, in extreme chop, liquidity pools are being tested repeatedly without producing clean sweeps and reversals — the institutional dynamic is absent
[*][b]BSL and SSL are very close to each other[/b] — when the two magnets are tightly compressed around current price, the market is ranging within a narrow liquidity cluster. Sweeps in this environment frequently continue through multiple levels rather than reversing at the first pool
[*][b]Sweep Window shows IDLE for an extended period[/b] — no sweeps means no primary setup type is available. Only absorption and FVG setups (Grade B) can fire. If you prefer primary setups only, wait for a sweep to register
[*][b]HTF Bias strongly opposes the signal[/b] — while HTF is a soft confluence layer in MAGNET, a strongly opposing HTF reduces the score by 1 point. In these conditions, a Grade B signal at the minimum threshold becomes marginal — consider requiring a higher score for counter-HTF entries
[*][b]Grade B signals with minimum score (5/9) in a non-trending market[/b] — absorption pins and FVG overlaps require more supporting confluence to be reliable in Balance or transitional markets. When Grade B fires at exactly the minimum score without HTF support, reduce size or skip
[*][b]Multiple consecutive sweeps of the same level without recovery[/b] — when price sweeps the SSL three times in succession, each time recovering only partially before sweeping again, the level is being absorbed in stages by a larger institutional seller rather than being swept for a reversal. Do not continue entering on each successive sweep
[/list]

[b]The ideal MAGNET setup:[/b]
[list]
[*]Clear, well-aged SSL or BSL pool with multiple touches (3+ pivots or EQ touches)
[*]Clean, decisive sweep below SSL with a single strong bar
[*]1–3 bar consolidation below the swept level (confirming trapped shorts)
[*]Delayed reclaim candle forming at the swept level with bull trigger confirmation
[*]RSI below 38 at the sweep low (exhaustion bonus point)
[*]Volume spike on the reclaim bar
[*]HTF aligned bullish
[*]Opposing BSL pool clearly defined above — the magnet-to-magnet trade
[*]Score at 8–9/9
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]💧 Hybrid dual-method pool detection — pivot cluster analysis (weighted average clustering with touch count and age requirements) combined with Equal High/Equal Low range scanning (touch count across lookback window)
[*]🎯 Active pool selection logic — nearest qualified pool to current price is selected as the active target, ensuring the most immediately relevant liquidity level is always the reference
[*]⚡ Dedicated sweep state machine — sweeps are detected and stored independently from entry logic, enabling delayed reclaim entries 1–8 bars after the sweep event with full state persistence
[*]🛡 Cascade block (same-bar only) — waterfall continuation bars are blocked from triggering same-bar sweep entries while preserving all delayed reclaim opportunities
[*]🏷 Four setup types with grade classification — Setup A (same-bar sweep reclaim), Setup B (delayed reclaim), Setup C (absorption pin), Setup D (FVG liquidity overlap), each graded A or B by primary/secondary classification
[*]📊 Weighted confluence scoring — primary setups count 2 points, secondary count 1, with 7 additional quality layers scoring independently. Quality through combination, not suppression
[*]🔴 RSI exhaustion bonus — extra confluence point when RSI is genuinely exhausted at the sweep level, rewarding the highest-quality reversal conditions
[*]📡 HTF bias as soft layer — higher timeframe alignment adds to the score but does not hard-block counter-HTF entries, reflecting the institutional reality that sweep reversals frequently work counter to the prevailing HTF trend
[*]🎯 Opposing magnet TP system — take profit automatically targets the opposing liquidity pool when available, providing an institutionally justified delivery destination rather than an arbitrary ATR multiple
[*]📍 Sweep-anchored SL placement — stop loss anchored to the swept pool level plus buffer, not an arbitrary ATR distance from entry
[*]💹 Live Sweep Window tracking — dashboard shows active sweep state with bars elapsed since sweep, providing pre-signal awareness before the delayed reclaim fires
[*]📊 Live Playbook row — displays WATCH RECLAIM ▲/▼ during active sweep windows, preparing you for the imminent Setup B signal
[*]📊 17-row live dashboard — Liquidity, Sweep State, Setups, Filters, and Confluence sections updated in real time
[*]🔔 4 alert conditions — long/short entries and SSL/BSL sweep events
[*]🎨 Fully cohesive dual-tone color system — yellow-green for SSL/SSL-related bull elements, red for BSL/BSL-related bear elements, orange for sweep markers and alerts
[*]⚙ Fully configurable — pivot length, EQH/EQL lookback, pool tolerance, touch minimums, pool age, sweep depth, reclaim window, signal body minimum, all four setup enables, confluence minimum, HTF timeframe and EMAs, chop threshold, volume filter, session, SL buffer, TP mode and R-multiple, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Liquidity Pool Engine[/b]
[list]
[*]Pivot Length — fractal sensitivity for pivot high/low detection (default: 5 bars each side)
[*]EQH/EQL Scan Lookback — bars used for the Equal High/Equal Low range scan (default: 40)
[*]Pool Tolerance (xATR) — ATR multiple defining the zone width around a pool level (default: 0.14)
[*]Min Pivot Touches — minimum pivot cluster touches for a pivot pool to qualify (default: 2)
[*]Min EQ Touches — minimum near-touches for an EQH/EQL level to qualify (default: 2)
[*]Min Pool Age (bars) — minimum bars since first pivot detection before the pool is active (default: 3)
[*]ATR Length — ATR calculation lookback (default: 14)
[/list]

[b]Sweep & Reclaim[/b]
[list]
[*]Min Sweep Depth (xATR) — minimum extension beyond the pool for a sweep to register (default: 0.10)
[*]Reclaim Window (bars after sweep) — how many bars after a sweep a delayed reclaim can fire (default: 8)
[*]Min Signal Body (xATR) — minimum candle body size for all entry triggers (default: 0.22)
[*]Show Sweep Markers — toggle optional orange circle markers at sweep detection bars (default: off)
[/list]

[b]Entry Setups[/b]
[list]
[*]A · SSL Sweep + Reclaim / A · BSL Sweep + Reclaim — toggle same-bar sweep entries
[*]B · Delayed SSL Reclaim / B · Delayed BSL Reclaim — toggle delayed reclaim entries
[*]C · SSL Absorption Pin / C · BSL Absorption Pin — toggle absorption pin bar entries
[*]D · FVG + SSL Magnet / D · FVG + BSL Magnet — toggle FVG-liquidity overlap entries
[*]Min Confluence Score — minimum weighted score required for a signal (default: 5)
[*]Show Entry Signals — toggle signal triangles
[*]Show Confluence Label — toggle the live B/S score label near the current price
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 5)
[*]Grade Signals (A / B) — when on, primary setups show as large triangles, secondary as small triangles
[/list]

[b]Filters[/b]
[list]
[*]HTF Bias Layer — adds 1 confluence point when HTF agrees (does not hard-block counter-trend)
[*]HTF Timeframe / HTF Fast / Slow EMA — higher timeframe parameters (defaults: 60-minute / 21 / 55)
[*]Block Extreme Chop — when on, Choppiness Index above threshold blocks all signals (the only hard filter)
[*]Choppiness Length / Chop Block Above — CI parameters (defaults: 14 / 65.0)
[*]Volume Layer — adds 1 confluence point when volume exceeds threshold
[*]Volume Spike Threshold / Volume Avg Length — volume parameters (defaults: 1.05 / 20)
[*]Session Filter / Active Session — trading hours restriction (default: off)
[*]Structure EMA — EMA used for the structural bias confluence layer (default: 21)
[/list]

[b]Exit Guidance[/b]
[list]
[*]Show SL / TP Guides — toggle stop and target dotted circle plots
[*]SL Beyond Sweep (xATR) — ATR buffer beyond the swept pool level for stop placement (default: 1.0)
[*]TP at Opposing Magnet — when on, TP targets the opposing active liquidity pool (default: on)
[*]TP Reward (R) if no magnet — fallback R-multiple target when no opposing pool is available (default: 2.5)
[/list]

[b]Display[/b]
[list]
[*]Show Liquidity Pool Lines — toggle BSL and SSL dashed reference lines
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish signals and SSL elements
[*]Bear / Bear Bright — red family for all bearish signals and BSL elements
[*]Sweep / Alert — orange for sweep markers and active alert states
[*]BSL Pool (EQH) / SSL Pool (EQL) — individual pool line colors
[*]SL Guide / TP Guide — stop and target circle colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (4 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Magnet Long — all conditions confirmed. Long signal fired across any qualifying setup type
[*]Magnet Short — all conditions confirmed. Short signal fired
[/list]

[b]Sweep Alerts[/b]
[list]
[*]Magnet SSL Swept — sell-side liquidity pool has been swept. Watch for reclaim within the configured window — Setup B is now monitoring
[*]Magnet BSL Swept — buy-side liquidity pool has been swept. Watch for reclaim — Setup B monitoring active
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–M15[/b]:
[list]
[*]Pivot Length at 5 — standard fractal sensitivity for intraday instruments. Captures meaningful swing points without over-sensitivity to micro-noise
[*]EQL Lookback at 40 — approximately 3–4 hours on M5, covering the relevant intraday Equal High/Low structure
[*]Pool Tolerance at 0.14× ATR — tight enough to require genuine proximity to the pool level without missing valid touches due to spread variation
[*]Reclaim Window at 8 bars — on M5 this is 40 minutes, sufficient to capture post-sweep consolidation and delayed reversal entries
[*]HTF at 60-minute as soft layer — adds score for alignment without blocking the counter-HTF sweeps that are often the most powerful entries
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Pivot Length to 3, reduce Pool Tolerance to 0.10, reduce Reclaim Window to 4–5 bars, reduce Cooldown to 3, increase Min Sweep Depth to 0.15 for tighter scalp sweeps
[*][b]H1–H4 swing trading[/b] — increase EQL Lookback to 80–100, increase Pivot Length to 7–8, increase Reclaim Window to 12–15, increase TP Reward to 3.5–5.0R for wider swing targets
[*][b]Crypto (BTC, ETH)[/b] — increase Pool Tolerance to 0.18–0.22 for the wider tick structure, increase Min Sweep Depth to 0.15–0.20, increase Chop Block to 68–70 for crypto's naturally higher choppiness
[*][b]Indices (NAS100, US30)[/b] — use session filter for cash market hours, increase Pool Tolerance slightly to 0.16, consider reducing EQL Lookback to 25–30 for the shorter-lived Equal High/Low structures in index futures
[*][b]More primary setups (A and B)[/b] — reduce Reclaim Window minimum expectation by ensuring both Setup A and B are enabled, and watch the Sweep Window row actively rather than waiting for signals
[*][b]Grade A signals only[/b] — disable Setup C (absorption) and Setup D (FVG), raise Min Confluence to 6. Only sweep and delayed reclaim entries with strong supporting factors will fire
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]💧 [b]Liquidity sweep traders and stop-hunt entry specialists[/b] — MAGNET is the most complete and technically sophisticated liquidity sweep system in the AlphaX suite. Every component — pool detection, sweep state machine, cascade blocking, delayed reclaim, magnet TP — is designed specifically for the institutional stop-hunt-and-reverse pattern
[*]🏦 [b]Smart money concepts and ICT methodology traders[/b] — the SSL/BSL, EQH/EQL, and sweep-reclaim framework directly implements the core ICT liquidity concepts with quantitative precision
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — liquidity sweeps are most consistent and most powerful on institutional instruments where market makers actively hunt stops. Default settings are calibrated for gold intraday
[*]🎯 [b]Traders who want the highest-quality post-sweep entries[/b] — the delayed reclaim (Setup B) is the system's most powerful setup type and is specifically designed for traders who have experienced the frustration of missing same-bar sweep reversals only to watch price surge without them
[*]🧠 [b]Systematic traders who want quantified liquidity analysis[/b] — the hybrid pool detection, weighted scoring, and sweep state machine replace entirely subjective liquidity level identification with objective, repeatable criteria
[*]📈 [b]Traders who struggle with stop placement on liquidity entries[/b] — the sweep-anchored stop placement and opposing magnet TP provide the most structurally appropriate risk parameters available for liquidity-based trading
[*]⚠ [b]Traders who have been stopped out by cascading waterfall bars[/b] — the cascade block on same-bar entries and the delayed reclaim system together prevent the most common failure mode of liquidity trading: entering during a genuine continuation move rather than a reversal
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Pool states, sweep state machine, setup conditions, and confluence scoring all finalize on confirmed bars only
[*]The pivot cluster averaging system means that as new pivots near the same level form, the pool level gradually adjusts toward the weighted average. This means the active pool level may shift slightly over time as new evidence accumulates — this is intentional and produces more accurate pool level estimates than using only the first or last pivot
[*]The cascade block applies only to the same-bar sweep entry (Setup A). Delayed reclaim entries (Setup B) are never blocked by cascade conditions — this is by design, as the cascade's resolution in subsequent bars is precisely the entry condition for Setup B
[*]The delayed reclaim window starts from 1 bar after the sweep (barsSinceSslSweep >= 1). Same-bar reclaims are handled exclusively by Setup A. There is no overlap between the two setup types
[*]When useMagnetTp is on and no opposing magnet is currently active (the opposing pool has not qualified or has been swept/invalidated), the system falls back automatically to the R-multiple TP without any gap in functionality
[*]The Choppiness Index is the only hard filter in MAGNET. All other filters (HTF, volume, structural bias) are soft confluence layers that add or do not add to the score. This reflects the intentional philosophy that quality through combination is superior to quality through suppression
[*]Maximum 500 labels and 500 lines are rendered. Pool lines are redrawn on the last bar, so they do not accumulate over history
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that price does not move randomly — it moves with purpose, toward the liquidity that institutions need, and away from it once that liquidity has been consumed.[/i]

## Source Code

````pine
// © AlphaX — MAGNET v2.0
// Liquidity Magnet Engine — multi-setup confluence (sweep, delayed reclaim, absorption, FVG).
// Quality through combination, not suppression. AlphaX branded — styled after ANCHOR.

//@version=6
indicator("[ A L P H A X ] MAGNET - Liquidity Magnet Engine", shorttitle="AlphaX MAGNET",
  overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  LIQUIDITY POOL ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpPool = "Liquidity Pool Engine"
pivotLen      = input.int(5, "Pivot Length", minval=2, maxval=15, group=grpPool)
eqLookback    = input.int(40, "EQH/EQL Scan Lookback", minval=15, maxval=120, group=grpPool)
poolTolAtr    = input.float(0.14, "Pool Tolerance (xATR)", minval=0.05, maxval=0.5, step=0.01, group=grpPool)
minPivotTouch = input.int(2, "Min Pivot Touches", minval=2, maxval=4, group=grpPool)
minEqTouch    = input.int(2, "Min EQ Touches", minval=2, maxval=5, group=grpPool)
poolMinAge    = input.int(3, "Min Pool Age (bars)", minval=1, maxval=30, group=grpPool)
atrLen        = input.int(14, "ATR Length", minval=2, maxval=100, group=grpPool)

// ═══════════════════════════════════════════════════════════════════════════════
//  SWEEP & RECLAIM
// ═══════════════════════════════════════════════════════════════════════════════
grpSweep = "Sweep & Reclaim"
sweepDepthAtr  = input.float(0.10, "Min Sweep Depth (xATR)", minval=0.03, maxval=0.5, step=0.01, group=grpSweep)
reclaimWindow  = input.int(8, "Reclaim Window (bars after sweep)", minval=2, maxval=20, group=grpSweep,
  tooltip="Delayed reclaim entries fire within this window — catches real reversals after stop-hunts.")
minBodyAtr     = input.float(0.22, "Min Signal Body (xATR)", minval=0.08, maxval=1.5, step=0.05, group=grpSweep)
showSweepMk    = input.bool(false, "Show Sweep Markers", group=grpSweep)

// ═══════════════════════════════════════════════════════════════════════════════
//  ENTRY SETUPS
// ═══════════════════════════════════════════════════════════════════════════════
grpEntry = "Entry Setups"
enableSweepLong   = input.bool(true, "A · SSL Sweep + Reclaim", group=grpEntry,
  tooltip="Same-bar stop-hunt below SSL + close back above.")
enableReclaimLong = input.bool(true, "B · Delayed SSL Reclaim", group=grpEntry,
  tooltip="Sweep 1–N bars ago, now displacement reclaim — high-quality post-crash entries.")
enableAbsorbLong  = input.bool(true, "C · SSL Absorption Pin", group=grpEntry,
  tooltip="Pin bar + volume at SSL without deep sweep — liquidity absorption.")
enableFvgLong     = input.bool(true, "D · FVG + SSL Magnet", group=grpEntry,
  tooltip="Bullish FVG overlapping SSL pool — imbalance fill into liquidity.")
enableSweepShort  = input.bool(true, "A · BSL Sweep + Reclaim", group=grpEntry)
enableReclaimShort= input.bool(true, "B · Delayed BSL Reclaim", group=grpEntry)
enableAbsorbShort = input.bool(true, "C · BSL Absorption Pin", group=grpEntry)
enableFvgShort    = input.bool(true, "D · FVG + BSL Magnet", group=grpEntry)
minConf           = input.int(5, "Min Confluence Score", minval=3, maxval=10, group=grpEntry)
showSignals       = input.bool(true, "Show Entry Signals", group=grpEntry)
showConfLbl       = input.bool(true, "Show Confluence Label", group=grpEntry)
cooldown          = input.int(5, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpEntry)
showGrade         = input.bool(true, "Grade Signals (A / B)", group=grpEntry,
  tooltip="A = primary sweep/reclaim. B = absorption/FVG secondary.")

// ═══════════════════════════════════════════════════════════════════════════════
//  FILTERS (soft — score layers, not hard blocks)
// ═══════════════════════════════════════════════════════════════════════════════
grpFilt = "Filters"
useHtf      = input.bool(true, "HTF Bias Layer", group=grpFilt,
  tooltip="Adds confluence when HTF aligns — does not hard-block counter-trend.")
htfTf       = input.timeframe("60", "HTF Timeframe", group=grpFilt)
htfFast     = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpFilt)
htfSlow     = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpFilt)
useChop     = input.bool(true, "Block Extreme Chop", group=grpFilt)
chopLen     = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpFilt)
chopMax     = input.float(65.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpFilt)
useVol      = input.bool(true, "Volume Layer", group=grpFilt)
volMult     = input.float(1.05, "Volume Spike Threshold", minval=0.8, maxval=3.0, step=0.05, group=grpFilt)
volLen      = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpFilt)
useSession  = input.bool(false, "Session Filter", group=grpFilt)
sessStart   = input.session("0700-2000", "Active Session", group=grpFilt)
trendEmaLen = input.int(21, "Structure EMA", minval=8, maxval=100, group=grpFilt)

// ═══════════════════════════════════════════════════════════════════════════════
//  EXIT GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
grpExit = "Exit Guidance"
showExits   = input.bool(true, "Show SL / TP Guides", group=grpExit)
slAtrMult   = input.float(1.0, "SL Beyond Sweep (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpExit)
useMagnetTp = input.bool(true, "TP at Opposing Magnet", group=grpExit)
tpRR        = input.float(2.5, "TP Reward (R) if no magnet", minval=0.5, maxval=20, step=0.5, group=grpExit)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
showPools   = input.bool(true, "Show Liquidity Pool Lines", group=grpVis)
showDash    = input.bool(true, "Show Dashboard", group=grpVis)
dashPos     = input.string("Top Right", "Dashboard Position",
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
colBsl        = input.color(#ff1744, "BSL Pool (EQH)",     group=grpColors)
colSsl        = input.color(#c8e624, "SSL Pool (EQL)",     group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
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

f_countNear(float lvl, bool isHigh, int lb, float tol) =>
    int cnt = 0
    for i = 0 to lb - 1
        float px = isHigh ? high[i] : low[i]
        if math.abs(px - lvl) <= tol
            cnt += 1
    cnt

f_pickMagnet(float a, float b, float px, bool wantBelow) =>
    bool aOk = not na(a) and (wantBelow ? a < px : a > px)
    bool bOk = not na(b) and (wantBelow ? b < px : b > px)
    aOk and bOk ? (math.abs(px - a) < math.abs(px - b) ? a : b) : aOk ? a : bOk ? b : na

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal  = ta.atr(atrLen)
volMa   = ta.sma(volume, volLen)
rng     = math.max(high - low, syminfo.mintick)
poolTol = atrVal * poolTolAtr
bodySz  = math.abs(close - open)
sweepDepth = sweepDepthAtr * atrVal

float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)

// ── Hybrid pools: pivot clusters + EQH/EQL range ────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float pivBsl = na
var float pivSsl = na
var int   pivBslTouch = 0
var int   pivSslTouch = 0
var int   pivBslBar = na
var int   pivSslBar = na

if not na(ph)
    if na(pivBsl) or math.abs(ph - pivBsl) > poolTol * 1.5
        pivBsl := ph
        pivBslTouch := 1
        pivBslBar := bar_index - pivotLen
    else
        pivBsl := (pivBsl * pivBslTouch + ph) / (pivBslTouch + 1)
        pivBslTouch += 1

if not na(pl)
    if na(pivSsl) or math.abs(pl - pivSsl) > poolTol * 1.5
        pivSsl := pl
        pivSslTouch := 1
        pivSslBar := bar_index - pivotLen
    else
        pivSsl := (pivSsl * pivSslTouch + pl) / (pivSslTouch + 1)
        pivSslTouch += 1

float rangeHi = ta.highest(high, eqLookback)
float rangeLo = ta.lowest(low, eqLookback)
int hiTouch = f_countNear(rangeHi, true, eqLookback, poolTol)
int loTouch = f_countNear(rangeLo, false, eqLookback, poolTol)

float eqBsl = hiTouch >= minEqTouch ? rangeHi : na
float eqSsl = loTouch >= minEqTouch ? rangeLo : na
float pivBslOk = pivBslTouch >= minPivotTouch and bar_index - nz(pivBslBar, bar_index) >= poolMinAge ? pivBsl : na
float pivSslOk = pivSslTouch >= minPivotTouch and bar_index - nz(pivSslBar, bar_index) >= poolMinAge ? pivSsl : na

float activeBsl = f_pickMagnet(pivBslOk, eqBsl, close, false)
float activeSsl = f_pickMagnet(pivSslOk, eqSsl, close, true)

bool bslValid = not na(activeBsl)
bool sslValid = not na(activeSsl)

float magnetAbove = bslValid and activeBsl > close ? activeBsl : na
float magnetBelow = sslValid and activeSsl < close ? activeSsl : na

// ── Sweep state machine (decouple sweep from entry) ───────────────────────────
var int   lastSslSweepBar = na
var float lastSslSweepLvl = na
var int   lastBslSweepBar = na
var float lastBslSweepLvl = na

bool rawSweepSsl = sslValid and low < activeSsl - sweepDepth
bool rawSweepBsl = bslValid and high > activeBsl + sweepDepth

if rawSweepSsl
    lastSslSweepBar := bar_index
    lastSslSweepLvl := activeSsl
if rawSweepBsl
    lastBslSweepBar := bar_index
    lastBslSweepLvl := activeBsl

int barsSinceSslSweep = bar_index - nz(lastSslSweepBar, bar_index - 999)
int barsSinceBslSweep = bar_index - nz(lastBslSweepBar, bar_index - 999)

bool recentSslSweep = not na(lastSslSweepBar) and barsSinceSslSweep >= 0 and barsSinceSslSweep <= reclaimWindow
bool recentBslSweep = not na(lastBslSweepBar) and barsSinceBslSweep >= 0 and barsSinceBslSweep <= reclaimWindow

// Cascade = waterfall bar — block same-bar sweep entries only (not delayed reclaim)
emaTrend = ta.ema(close, trendEmaLen)
ema50    = ta.ema(close, 50)
rsiVal   = ta.rsi(close, 14)

bool cascadeBear = close < open and bodySz > 0.45 * atrVal and close < emaTrend and emaTrend < ema50
bool cascadeBull = close > open and bodySz > 0.45 * atrVal and close > emaTrend and emaTrend > ema50

// ── Candle triggers ───────────────────────────────────────────────────────────
bool bullTrig = close > open and bodySz >= minBodyAtr * atrVal and (close - low) / rng > 0.50
bool bearTrig = close < open and bodySz >= minBodyAtr * atrVal and (high - close) / rng > 0.50

bool atSslZone = sslValid and low <= activeSsl + poolTol
bool atBslZone = bslValid and high >= activeBsl - poolTol

bool sameBarSweepL = rawSweepSsl and close > activeSsl and bullTrig and not cascadeBear
bool sameBarSweepS = rawSweepBsl and close < activeBsl and bearTrig and not cascadeBull

bool delayedReclaimL = recentSslSweep and barsSinceSslSweep >= 1 and close > lastSslSweepLvl and
     low <= lastSslSweepLvl + poolTol and bullTrig
bool delayedReclaimS = recentBslSweep and barsSinceBslSweep >= 1 and close < lastBslSweepLvl and
     high >= lastBslSweepLvl - poolTol and bearTrig

bool volSpike = volume >= volMa * volMult
bool pinBull = atSslZone and lowerWick / rng > 0.42 and bodySz / rng < 0.38 and close > open
bool pinBear = atBslZone and upperWick / rng > 0.42 and bodySz / rng < 0.38 and close < open

bool absorbL = pinBull and volSpike and close > activeSsl
bool absorbS = pinBear and volSpike and close < activeBsl

bool bullFvg = low > high[2]
bool bearFvg = high < low[2]
float fvgTopL = low
float fvgBotL = high[2]
float fvgTopS = low[2]
float fvgBotS = high

bool fvgSslOverlap = sslValid and fvgBotL <= activeSsl + poolTol and fvgTopL >= activeSsl - poolTol
bool fvgBslOverlap = bslValid and fvgBotS <= activeBsl + poolTol and fvgTopS >= activeBsl - poolTol

bool fvgMagnetL = bullFvg and fvgSslOverlap and bullTrig
bool fvgMagnetS = bearFvg and fvgBslOverlap and bearTrig

// ── Filters (soft layers) ─────────────────────────────────────────────────────
float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0
bool chopOk = not useChop or chopIdx < chopMax

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE

bool volLayer = not useVol or volSpike
bool structLong  = close > emaTrend or rsiVal > 45
bool structShort = close < emaTrend or rsiVal < 55
bool exhaustionL = rsiVal < 38 and recentSslSweep
bool exhaustionS = rsiVal > 62 and recentBslSweep

// ═══════════════════════════════════════════════════════════════════════════════
//  SETUPS & WEIGHTED CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════════
setupSweepL   = enableSweepLong and sameBarSweepL
setupReclaimL = enableReclaimLong and delayedReclaimL
setupAbsorbL  = enableAbsorbLong and absorbL
setupFvgL     = enableFvgLong and fvgMagnetL

setupSweepS   = enableSweepShort and sameBarSweepS
setupReclaimS = enableReclaimShort and delayedReclaimS
setupAbsorbS  = enableAbsorbShort and absorbS
setupFvgS     = enableFvgShort and fvgMagnetS

bool primaryL = setupSweepL or setupReclaimL
bool primaryS = setupSweepS or setupReclaimS
bool secondaryL = setupAbsorbL or setupFvgL
bool secondaryS = setupAbsorbS or setupFvgS

bool setupLong  = primaryL or secondaryL
bool setupShort = primaryS or secondaryS

// Weighted score — primary setups worth 2, layers add quality not quantity gates
int bullScore = (primaryL ? 2 : secondaryL ? 1 : 0) +
     (sslValid ? 1 : 0) + (htfBull and useHtf ? 1 : 0) + (volLayer ? 1 : 0) +
     (structLong ? 1 : 0) + (exhaustionL ? 1 : 0) + (chopOk ? 1 : 0) +
     (atSslZone ? 1 : 0)
int bearScore = (primaryS ? 2 : secondaryS ? 1 : 0) +
     (bslValid ? 1 : 0) + (htfBear and useHtf ? 1 : 0) + (volLayer ? 1 : 0) +
     (structShort ? 1 : 0) + (exhaustionS ? 1 : 0) + (chopOk ? 1 : 0) +
     (atBslZone ? 1 : 0)

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown
bool inSession = not useSession or not na(time(timeframe.period, sessStart))

bool bullSignal = showSignals and barstate.isconfirmed and setupLong and bullScore >= minConf and inSession and cooled and chopOk
bool bearSignal = showSignals and barstate.isconfirmed and setupShort and bearScore >= minConf and inSession and cooled and chopOk

string bullGrade = primaryL ? "A" : secondaryL ? "B" : ""
string bearGrade = primaryS ? "A" : secondaryS ? "B" : ""

if bullSignal or bearSignal
    lastSigBar := bar_index

// ── SL / TP ───────────────────────────────────────────────────────────────────
float slGuide = na
float tpGuide = na
if bullSignal
    float sslRef = nz(lastSslSweepLvl, activeSsl)
    slGuide := math.min(low, sslRef) - slAtrMult * atrVal
    float risk = close - slGuide
    tpGuide := useMagnetTp and not na(magnetAbove) ? magnetAbove : risk > 0 ? close + risk * tpRR : close + atrVal * tpRR
if bearSignal
    float bslRef = nz(lastBslSweepLvl, activeBsl)
    slGuide := math.max(high, bslRef) + slAtrMult * atrVal
    float riskS = slGuide - close
    tpGuide := useMagnetTp and not na(magnetBelow) ? magnetBelow : riskS > 0 ? close - riskS * tpRR : close - atrVal * tpRR

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
var line lnBsl = na
var line lnSsl = na
var label lbBsl = na
var label lbSsl = na

if barstate.islast and showPools
    if not na(lnBsl)
        line.delete(lnBsl)
    if not na(lnSsl)
        line.delete(lnSsl)
    if not na(lbBsl)
        label.delete(lbBsl)
    if not na(lbSsl)
        label.delete(lbSsl)
    int lnStart = math.max(0, bar_index - eqLookback)
    if bslValid
        lnBsl := line.new(lnStart, activeBsl, bar_index + 8, activeBsl,
          color=color.new(colBsl, 35), style=line.style_dashed, width=1)
        lbBsl := label.new(bar_index + 8, activeBsl, "BSL · EQH", color=na, textcolor=colBsl,
          style=label.style_label_left, size=size.tiny)
    if sslValid
        lnSsl := line.new(lnStart, activeSsl, bar_index + 8, activeSsl,
          color=color.new(colSsl, 35), style=line.style_dashed, width=1)
        lbSsl := label.new(bar_index + 8, activeSsl, "SSL · EQL", color=na, textcolor=colSsl,
          style=label.style_label_left, size=size.tiny)

plot(showExits and not na(slGuide) ? slGuide : na, "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(tpGuide) ? tpGuide : na, "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)

plotshape(bullSignal and (not showGrade or bullGrade == "A"), title="Magnet Long A",
  style=shape.triangleup, location=location.belowbar, color=color.new(colBull, 0), size=size.small)
plotshape(bullSignal and showGrade and bullGrade == "B", title="Magnet Long B",
  style=shape.triangleup, location=location.belowbar, color=color.new(colBullBr, 20), size=size.tiny)
plotshape(bearSignal and (not showGrade or bearGrade == "A"), title="Magnet Short A",
  style=shape.triangledown, location=location.abovebar, color=color.new(colBear, 0), size=size.small)
plotshape(bearSignal and showGrade and bearGrade == "B", title="Magnet Short B",
  style=shape.triangledown, location=location.abovebar, color=color.new(colBearBr, 20), size=size.tiny)

plotshape(showSweepMk and rawSweepSsl, title="SSL Sweep", style=shape.circle, location=location.belowbar,
  color=color.new(colSqueeze, 30), size=size.tiny)
plotshape(showSweepMk and rawSweepBsl, title="BSL Sweep", style=shape.circle, location=location.abovebar,
  color=color.new(colSqueeze, 30), size=size.tiny)

if showConfLbl and barstate.islast
    string confTxt = "B " + str.tostring(bullScore) + "  ·  S " + str.tostring(bearScore)
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    label.new(bar_index, close, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 17,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    string setupTxtL = setupSweepL ? "SWEEP" : setupReclaimL ? "RECLAIM" : setupAbsorbL ? "ABSORB" : setupFvgL ? "FVG" : "—"
    string setupTxtS = setupSweepS ? "SWEEP" : setupReclaimS ? "RECLAIM" : setupAbsorbS ? "ABSORB" : setupFvgS ? "FVG" : "—"

    table.cell(dash, 0, 0, "AlphaX MAGNET", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v2.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── LIQUIDITY ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    table.cell(dash, 0, 2, "BSL (EQH)", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, bslValid ? str.tostring(activeBsl, format.mintick) : "—",
      text_color=colBsl, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "SSL (EQL)", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, sslValid ? str.tostring(activeSsl, format.mintick) : "—",
      text_color=colSsl, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "MAGNET ABOVE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, not na(magnetAbove) ? str.tostring(magnetAbove, format.mintick) : "—",
      text_color=colBsl, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "MAGNET BELOW", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, not na(magnetBelow) ? str.tostring(magnetBelow, format.mintick) : "—",
      text_color=colSsl, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 6, "─── SWEEP STATE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 6, "", bgcolor=secBg)

    string swTxt = recentSslSweep ? "SSL " + str.tostring(barsSinceSslSweep) + "b ago" :
         recentBslSweep ? "BSL " + str.tostring(barsSinceBslSweep) + "b ago" : "— IDLE"
    color swCol = recentSslSweep ? colBull : recentBslSweep ? colBear : colTextLt
    table.cell(dash, 0, 7, "SWEEP WINDOW", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, swTxt, text_color=swCol, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "─── SETUPS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 8, "", bgcolor=secBg)

    table.cell(dash, 0, 9, "LONG SETUP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, setupTxtL, text_color=setupLong ? colBull : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "SHORT SETUP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, setupTxtS, text_color=setupShort ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 11, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 11, "", bgcolor=secBg)

    table.cell(dash, 0, 12, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "CHOP INDEX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 13, str.tostring(chopIdx, "#.#"), text_color=chopOk ? colTextLt : colSqueeze,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 14, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 14, "", bgcolor=secBg)

    table.cell(dash, 0, 15, "BULL / BEAR", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 15, str.tostring(bullScore) + " / " + str.tostring(bearScore) +
      (bullScore >= minConf ? " ▲" : bearScore >= minConf ? " ▼" : ""),
      text_color=bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral,
      text_size=size.small, bgcolor=dbg)

    string pbTxt = bullSignal ? "LONG " + bullGrade : bearSignal ? "SHORT " + bearGrade :
         recentSslSweep ? "WATCH RECLAIM ▲" : recentBslSweep ? "WATCH RECLAIM ▼" : "WATCH MAGNETS"
    color pbCol = bullSignal ? colBull : bearSignal ? colBear : colSqueeze
    table.cell(dash, 0, 16, "PLAYBOOK", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 16, pbTxt, text_color=pbCol, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="Magnet Long",
  message="[AlphaX MAGNET] LONG on {{ticker}} {{interval}} — liquidity setup.")
alertcondition(bearSignal, title="Magnet Short",
  message="[AlphaX MAGNET] SHORT on {{ticker}} {{interval}} — liquidity setup.")
alertcondition(rawSweepSsl, title="Magnet SSL Swept",
  message="[AlphaX MAGNET] SSL swept — watch for reclaim within window.")
alertcondition(rawSweepBsl, title="Magnet BSL Swept",
  message="[AlphaX MAGNET] BSL swept — watch for reclaim within window.")
````
