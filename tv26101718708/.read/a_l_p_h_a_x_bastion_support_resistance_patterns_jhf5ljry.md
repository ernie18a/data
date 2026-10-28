# [ A L P H A X ] BASTION - Support & Resistance Patterns

- url: https://www.tradingview.com/script/jhf5ljRY-A-L-P-H-A-X-BASTION-Support-Resistance-Patterns/
- type: indicator
- pine_id: PUB;cddcc09d6e544a28a3e1df674402a2c4
- version: 2.0

## Description

[b]AlphaX BASTION — Support & Resistance Lattice Engine: Touch-Clustered Zone Detection, HTF Level Blending, Four Interaction Playbooks & Level-to-Level Target System[/b]

AlphaX BASTION is a professional-grade support and resistance system built around the concept of a [i]lattice[/i] — a dynamic, self-updating grid of strength-scored price zones that are continuously constructed from fractal pivot clusters, blended with higher timeframe levels, decayed over time as they lose relevance, and scored by touch frequency and institutional significance. Unlike static horizontal line indicators or basic pivot systems, BASTION treats every support and resistance level as a living structure with a birth date, a touch history, an HTF weight, and a decay clock. Where most S/R systems simply identify levels and leave the trader to decide what to do, BASTION goes one step further: it monitors every active level for four specific micro-pattern interactions — DEFEND, SWEEP, RETEST, and COIL — and fires precision entry signals when those interactions occur at qualified levels with sufficient confluence. The target for every signal is not an arbitrary ATR multiple or measured move — it is the [i]next Bastion level[/i] in the signal direction, the natural institutional delivery destination from one defended wall to the next. Designed for traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏰 [b]The Lattice — A Self-Building Defended Price Map[/b]

The word "lattice" captures the core concept precisely: BASTION constructs an interconnected grid of defended price levels that represents the current institutional support and resistance landscape. This lattice is not drawn manually, not imported from a fixed timeframe, and not redrawn from scratch on every bar. It is built incrementally — growing as new pivots form, strengthened as levels are retested, and pruned as levels age beyond their relevance window.

[b]How the lattice is constructed:[/b]
On every bar, BASTION detects confirmed fractal pivot highs and lows (using a configurable pivot length, default: 5 bars each side). Each new pivot is fed into the lattice's merge algorithm:

[list]
[*]If the new pivot is within the merge tolerance (default: 0.22× ATR) of an existing level, it merges with that level — the level's midpoint shifts to the weighted average of all contributing pivots, the touch count increments, the zone boundaries expand if necessary, and the last touch timestamp updates
[*]If the new pivot is farther than the merge tolerance from any existing level, a new level is created with the pivot as its midpoint, zone height of ±0.18× ATR above and below, touch count of 1, and the current bar as its birth bar
[*]When the number of levels per side exceeds the configured maximum (default: 4), the oldest level is dropped from the end of the array
[/list]

[b]Level decay:[/b]
Levels that have not been touched in more than the configured decay period (default: 250 bars) are pruned automatically. This ensures the lattice reflects current institutional market memory rather than accumulating ancient, irrelevant levels that clutter the chart and produce false signals.

[b]Why touch clustering produces better levels than standard S/R:[/b] A single pivot high at a price is a weak level — it represents one instance of sellers overwhelming buyers. The same price area touched three times across different sessions represents a genuine institutional order cluster — the level where significant participants have repeatedly defended their position. BASTION's weighted averaging and touch counting system identifies these genuine defended levels and distinguishes them from noise pivots.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 [b]HTF Level Blending — Multi-Timeframe Institutional Walls[/b]

Every Bastion level is either a current timeframe pivot cluster or a [b]higher timeframe structural level[/b]. When Show HTF Swing Levels is enabled (default: on), BASTION pulls pivot highs and lows from the configured HTF (default: H4) and feeds them into the same merge algorithm as current timeframe pivots.

[b]HTF levels receive a special weight in the strength calculation:[/b] +2 additional strength points beyond their touch count. This reflects the institutional significance differential — a resistance level formed on H4 represents a zone where a much larger institutional participant defended their position, and carries proportionally more weight than a current timeframe pivot at the same price.

[b]HTF levels are visually distinguished:[/b] HTF-sourced zones are rendered with a slightly different purple color (slateblue rather than the standard purple), and HTF-contributing midlines use a thicker dashed line (width 2 vs 1 for standard levels). This allows you to immediately identify which levels have higher timeframe structural backing.

[b]How HTF blending works in practice:[/b] When an H4 resistance level is at 2490.00 and a current timeframe resistance forms at 2491.50 — within the merge tolerance — they merge into a single strengthened level. The merged level receives the touch count of both the HTF pivot and any current timeframe retests, plus the HTF weight bonus, making it one of the strongest levels in the lattice. This is the precise behavior of real institutional support and resistance: the H4 level acts as the anchor, and intraday touches confirm it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💪 [b]Level Strength Scoring[/b]

Every level in the lattice has a dynamically computed strength score used to qualify signals and sort level priority.

[b]Strength components:[/b]
[list]
[*][b]Touch count[/b] — the primary strength component. Each time a new pivot merges into the level, touch count increments. A level with 4 touches is significantly stronger than one with 1
[*][b]HTF bonus (+2)[/b] — levels that have HTF pivot contributions receive 2 additional strength points, reflecting their higher institutional significance
[*][b]Recency bonus (+1)[/b] — levels born within the last 80 bars receive 1 additional point. Fresh levels that were recently created and immediately retested carry more immediate institutional relevance than older levels with the same touch count
[/list]

[b]Minimum strength gate:[/b] Signals are blocked from firing at levels with strength below the configured minimum (default: 2 touches). This single filter eliminates the single most common false signal in S/R trading — entering at an untested level that has not proven itself as a genuine defended zone.

[b]Strength display on dashboard:[/b] The nearest support and resistance levels are displayed on the dashboard with their strength scores in brackets — e.g., "2450.50 [4]" means the level at 2450.50 has a strength score of 4. At a glance, you know which levels are most defended.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎮 [b]The Four Interaction Playbooks[/b]

The lattice provides the structural map. The playbook engine defines what to do when price arrives at a lattice level. Four specific micro-pattern interactions are monitored continuously — each representing a different way price can interact with a defended wall and a different entry scenario.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]DEFEND — Wick Rejection at Level[/b]

The most common and cleanest S/R interaction. A wick rejection candle forms when price tests the level and is immediately repelled — buyers overwhelm sellers at support, or sellers overwhelm buyers at resistance, within a single candle.

[b]Long conditions (support DEFEND):[/b]
[list]
[*]The current bar's low is within the proxAtr distance of the nearest support level
[*]The lower wick exceeds the configured minimum (default: 52% of bar range) — a dominant rejection wick
[*]The close is in the upper quarter of the bar (above bodyBot + 25% of range)
[*]The close is above the zone bottom — price rejected from inside the zone
[/list]

[b]The DEFEND signal tells you:[/b] The support level absorbed the selling pressure on this bar with a clear institutional response. The wick is the signature of buyers stepping in aggressively at the defended zone. This is the most textbook S/R signal available and the highest-frequency of the four playbooks.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]SWEEP — Liquidity Grab + Reclaim[/b]

The institutional stop-hunt interaction. Price breaches the zone boundary to trigger stop orders, then immediately reverses and closes back inside the zone.

[b]Long conditions (support SWEEP):[/b]
[list]
[*]The current bar's low extends below the zone bottom by more than the minimum sweep depth (default: 0.12× ATR) — stop orders below support have been triggered
[*]The bar closes above the zone midline — the reclaim is decisive, not just touching the boundary
[*]The bar closes bullish (close above open) — institutional buying drove the recovery

[/list]

[b]Why SWEEP is the highest-conviction signal:[/b] A liquidity sweep at a lattice level combines two layers of institutional evidence. The level itself has been defended multiple times (touch count) and has institutional order significance. The sweep event confirms that institutions actively used the liquidity pool below the level to fill their buy positions — the same sweep-and-reclaim dynamic that underlies MAGNET, but now occurring specifically at a pre-qualified lattice level with known strength.

[b]The SWEEP playbook carries a confluence bonus (+1 layer point)[/b] because of this elevated institutional evidence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]RETEST — Break Then Hold (S/R Flip)[/b]

The classic support-becomes-resistance and resistance-becomes-support interaction. Price previously broke through the level from the other side, and is now returning to test the flipped level.

[b]Long conditions (support RETEST):[/b]
[list]
[*]Within the lookback window (default: 12 bars), the close was below the zone bottom — a genuine prior breakdown
[*]The current bar's low is within the zone and the close is above the zone midline — the retest from above is holding
[*]The current bar closes bullish

[/list]

[b]The RETEST signal captures:[/b] The moment when a broken resistance becomes confirmed new support. When a level that previously acted as resistance is broken, retail traders who were long above the level are stopped out or become sellers. When price returns to test the level from above — and the close holds above the midline — the same institutional level that attracted sellers is now attracting buyers who missed the initial breakout. This is the "second chance" entry that offers excellent risk/reward relative to the original breakout candle.

[b]The RETEST playbook also carries a confluence bonus (+1 layer point).</b>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]COIL — Compression into Level[/b]

The pre-breakout compression interaction. Price has been ranging with narrow ATR bars approaching the level — a coiling squeeze that frequently precedes an explosive directional move.

[b]Long conditions (support COIL):[/b]
[list]
[*]The last N bars (default: 4) each have an ATR of less than 0.75× the overall ATR — the market is compressing with below-average volatility
[*]The close is within the proxAtr distance of the support level — the compression is occurring directly at the lattice level
[*]The close is above the zone midline — the compression is occurring on the correct side of the level

[/list]

[b]The COIL signal captures:[/b] The energy-building phase at a defended level. When price approaches a lattice level with declining volatility over multiple bars, it indicates the institutional response to that level is suppressing price movement — buyers and sellers are in equilibrium at the level, but the institutional bias (toward defending it as support or resistance) creates a coiled spring. The first decisive bar after the coil frequently produces a large directional move.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Level-to-Level Target System — The Bastion's Unique Approach[/b]

Every other entry system in the AlphaX suite uses ATR multiples, Fibonacci measured moves, or pattern heights to compute take profit targets. BASTION uses none of these. The target for every BASTION signal is [b]the next Bastion level[/b] in the direction of the trade.

[b]For a long signal at support:[/b] The target is the nearest resistance level above the entry price in the current lattice. This is the next defended wall — the level where sellers are expected to step in and potentially cap the move.

[b]For a short signal at resistance:[/b] The target is the nearest support level below the entry price — the next defended wall where buyers are expected to step in.

[b]Why level-to-level targeting is superior to measured moves for S/R trading:[/b] The market does not move from support to an arbitrary ATR multiple above. It moves from support to resistance — from one institutional wall to the next. Using the actual lattice level as the target ensures the trade is exited at the next genuine institutional interaction point rather than at an arbitrary mathematical distance. This aligns the trade's exit with the same institutional framework that generated the entry.

[b]NEXT WALL TGT on dashboard and chart:[/b] The target level is displayed on the dashboard as NEXT WALL TGT and plotted as a yellow-green dashed line on the chart labeled "NEXT WALL." When no opposing lattice level is currently qualified (the target would be beyond the available lattice), the system shows — rather than fabricating a target.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 7-Layer Confluence Engine[/b]

Every playbook signal is evaluated through a 7-layer scoring system. Signals below the minimum layer count (default: 4) are suppressed.

[b]Layer 1 — Level Strength (1 point):[/b]
The interacted level meets the minimum strength threshold (touch count + HTF bonus + recency bonus ≥ minimum). Levels that do not meet this floor cannot produce signals regardless of playbook quality.

[b]Layer 2 — HTF Trend Bias (1 point):[/b]
The higher timeframe EMA structure (default: 60-minute, 21/55 EMA) agrees with the signal direction. Bull signals require HTF bull, bear signals require HTF bear. When HTF bias is disabled, this layer is neutral (0 points). Note that the HTF bias is also enforced as a hard condition in the signal firing logic — signals opposing the HTF are blocked entirely when useHtfBias is on.

[b]Layer 3 — Volume Expansion (1 point):[/b]
Current bar volume exceeds the volume moving average by the configured multiplier (default: 1.08×). Confirms institutional participation on the interaction bar.

[b]Layer 4 — Non-Chop Market (1 point):[/b]
Choppiness Index is below the configured threshold (default: 62). Also enforced as a hard gate — extreme chop blocks all signals. S/R interactions during extreme chop frequently produce false breakouts and fake rejections.

[b]Layer 5 — Playbook Bonus (1 point):[/b]
SWEEP and RETEST playbooks receive 1 additional point reflecting their elevated institutional evidence. DEFEND and COIL do not receive this bonus — they are valid but carry less structural confirmation than a sweep reclaim or S/R flip.

[b]Layer 6 — Bar Range Quality (1 point):[/b]
The current bar's range is at least 0.35× ATR — the interaction bar has sufficient price action to produce a genuine signal. Doji and near-doji bars in critical zones do not score this point.

[b]Layer 7 — Session Active (1 point):[/b]
The current bar is within the configured active session window when the session filter is enabled. When the filter is off, this layer always contributes its point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 14-row real-time dashboard displays the complete state of the lattice and the current signal context.

[b]LATTICE[/b]
[list]
[*][b]Nearest Sup[/b] — the price of the nearest support level below current price, with its strength score in brackets (e.g., "2450.50 [4]"). Yellow-green color
[*][b]Nearest Res[/b] — the price of the nearest resistance level above current price with strength score. Red color
[*][b]Zone Count[/b] — the total number of active support and resistance levels in the lattice (e.g., "3 sup · 4 res"). Provides awareness of how populated the current lattice is
[/list]

[b]PLAYBOOK[/b]
[list]
[*][b]State[/b] — the current playbook state: the active playbook name (DEFEND, SWEEP, RETEST, COIL) when a signal just fired; WATCH WALLS during the inter-signal period
[*][b]Bias[/b] — ▲ LONG or ▼ SHORT when a signal fired; NEAR RES, NEAR SUP, or MID-RANGE based on current price position relative to the lattice when idle
[*][b]Next Wall Tgt[/b] — the price of the next opposing lattice level — the level-to-level target for the current trade
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — ▲ BULL, ▼ BEAR, or — FLAT
[*][b]Chop[/b] — live Choppiness Index value. Orange when above the stand-aside threshold
[*][b]Volume[/b] — EXPAND (above threshold) or QUIET
[*][b]Playbooks On[/b] — abbreviations of all currently enabled playbooks (DEF SWP RET COIL) for quick reference
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Resistance Zone Boxes (purple / slateblue)[/b] — semi-transparent boxes spanning each resistance level from its birth bar to 15 bars beyond current. Standard purple for current timeframe levels, slateblue for HTF-blended levels
[*][b]Resistance Midlines (purple dashed)[/b] — the exact midpoint of each resistance zone. Width 1 for standard, width 2 for HTF levels
[*][b]Support Zone Boxes (yellow-green)[/b] — semi-transparent yellow-green boxes for all active support levels
[*][b]Support Midlines (yellow-green dashed)[/b] — support zone midpoints. Width 2 for HTF levels
[*][b]⬡ Diamond (below bar, bright yellow-green)[/b] — BASTION long signal. Playbook fired at a support level with qualifying confluence
[*][b]⬡ Diamond (above bar, bright red)[/b] — BASTION short signal
[*][b]Playbook Label[/b] — appears above or below the signal diamond showing "BASTION LONG/SHORT" + playbook name + level price
[*][b]SL Guide (red dotted)[/b] — stop loss below the zone bottom plus ATR buffer (long) or above zone top plus ATR buffer (short), extending 30 bars forward with "SL" label
[*][b]NEXT WALL Guide (yellow-green dashed)[/b] — the level-to-level target extending 30 bars forward with "NEXT WALL" label
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX BASTION — Step by Step[/b]

[b]Step 1 — Read the Lattice[/b]
[list]
[*]Check the NEAREST SUP and NEAREST RES rows on the dashboard. Note the strength scores in brackets. Levels with strength 4+ are the most defended — prioritize interactions at these levels
[*]Look at the Zone Count row — a lattice with 3–4 levels on each side represents a well-populated market map. A sparse lattice (1–2 levels per side) means fewer reference points and potentially lower signal quality
[*]Check whether the nearest support or resistance has HTF origin — the slateblue color on the chart or the higher strength score indicates institutional level significance
[/list]

[b]Step 2 — Monitor Price Approaching a Level[/b]
[list]
[*]When the dashboard Bias row shows NEAR RES or NEAR SUP, price is approaching a lattice level within the proximity threshold. Watch for a playbook interaction to develop
[*]Identify which playbook is most likely: Is price approaching with narrow bars (COIL)? Did price recently spike below (SWEEP potential)? Has the level previously been broken (RETEST setup)? Is price arriving with a clear wick forming (DEFEND setup)?
[*]Check HTF Bias and Chop on the dashboard — both must be favorable before a signal can fire
[/list]

[b]Step 3 — Enter on the Diamond Signal[/b]
[list]
[*]A ⬡ diamond below the bar confirms a qualifying long interaction. The playbook label shows which of the four setups fired and at which exact level
[*]The SL guide shows the stop level — placed below the zone bottom plus ATR buffer (long) or above zone top plus buffer (short). This is the structural invalidation point: if price closes through the zone boundary in the wrong direction, the level has failed to defend
[*]The NEXT WALL guide shows the target level — the next opposing lattice wall
[*]SWEEP and RETEST signals carry the highest confluence (extra playbook layer point) — size these entries at full allocation. DEFEND and COIL at standard allocation
[/list]

[b]Step 4 — Manage to the Next Wall[/b]
[list]
[*]The trade targets the NEXT WALL level shown on the chart. As price approaches that level, watch for rejection signals in the opposing direction — if BASTION fires a signal at the target level against your trade, this is a natural exit point
[*]Monitor the lattice continuously — new levels may form during the trade that become relevant intermediate targets or stop adjustment points
[*]If the lattice map shifts significantly (a level is pruned by decay or a strong new level forms), reassess the trade's target
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Chop Index is orange on the dashboard[/b] — the hard gate is active. No signals fire in extreme chop. S/R levels lose their predictive power when the market is oscillating — every touch becomes ambiguous
[*][b]Zone Count shows 1–2 levels per side[/b] — a sparse lattice means the system has insufficient structural reference. The market may be trending strongly through all levels or may be too early in the session to have built meaningful clusters. Wait for the lattice to populate
[*][b]Nearest level strength is 1[/b] — the minimum strength gate will block signals at untested levels, but if the nearest levels all show [1], the lattice is populated with fresh, unproven levels. Increase the minimum level strength in settings to require at least 2–3 touches
[*][b]HTF Bias shows FLAT[/b] — no higher timeframe directional conviction. Counter-trend S/R interactions in a flat HTF environment fail at a higher rate because neither institutional buyers nor sellers have committed to a directional view
[*][b]NEXT WALL TGT shows —[/b] — no opposing qualified level exists in the lattice above (for longs) or below (for shorts). Without a level-to-level target, the trade lacks a natural exit framework. Consider skipping signals when no next wall target is available
[*][b]Playbook is COIL at a level with strength 2[/b] — a coil at a weak, lightly-tested level carries the lowest probability of the signal matrix. COIL at high-strength (4+) levels with HTF backing is a quality setup; COIL at minimum-strength levels is marginal
[/list]

[b]The ideal BASTION setup:[/b]
[list]
[*]Support or resistance level with strength 4+ (multiple touches, ideally HTF-blended)
[*]HTF Bias aligned with the trade direction
[*]SWEEP or RETEST playbook (highest confluence bonus)
[*]Volume expanding on the interaction bar
[*]Chop Index well below threshold
[*]Clear NEXT WALL target on the opposing side of the lattice
[*]Signal layers at 6–7 out of 7
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🏰 Dynamic S/R lattice — self-building, self-pruning grid of touch-clustered support and resistance zones. New pivots merge into existing levels, incrementing touch counts and adjusting zone boundaries automatically
[*]📡 HTF level blending — H4 (or any configurable HTF) pivot levels fed into the same lattice with a strength bonus, producing a multi-timeframe S/R map in a single indicator
[*]💪 Level strength scoring — touch count + HTF bonus + recency bonus produces a composite strength score for every level. Minimum strength gate blocks signals at untested levels
[*]⏱ Level decay — zones older than the configurable decay period are automatically pruned, keeping the lattice relevant to current institutional market memory
[*]🎮 Four interaction playbooks — DEFEND (wick rejection), SWEEP (liquidity grab + reclaim), RETEST (S/R flip), COIL (compression) — each detecting a different institutional level interaction scenario
[*]🎯 Level-to-level target system — take profit targets the next opposing lattice wall rather than an arbitrary ATR multiple or measured move. The most institutionally grounded target method available
[*]🛡 Zone-anchored stop loss — stop placed beyond the zone boundary plus configurable ATR buffer, at the structural invalidation point for each interaction type
[*]🧠 7-layer confluence engine — Level Strength, HTF Trend Bias, Volume, Non-Chop, Playbook Bonus, Bar Range Quality, Session Active
[*]📊 Live lattice dashboard — Nearest Support/Resistance with strength scores, Zone Count, active Playbook, Bias, Next Wall Target, and all filter states
[*]🎨 Phase-coded zone visualization — resistance zones in purple/slateblue, support zones in yellow-green. HTF levels distinguished by color shade and line width
[*]🔔 2 alert conditions + runtime alerts — Bastion Long and Bastion Short with level price and target in the alert message
[*]⚙ Fully configurable — pivot length, zone merge and half-height tolerances, max levels per side, level decay, HTF timeframe for levels, all four playbook enables, proximity, wick minimum, sweep depth, retest lookback, coil bars, minimum level strength, confluence minimum, HTF bias timeframe and EMAs, volume filter, chop gate, session, cooldown, SL buffer, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]S/R Lattice[/b]
[list]
[*]Swing Pivot Length — fractal sensitivity for pivot detection (default: 5)
[*]Zone Merge (xATR) — ATR distance within which new pivots merge into existing levels (default: 0.22)
[*]Zone Half-Height (xATR) — ATR distance above and below each level midpoint defining the zone boundaries (default: 0.18)
[*]Max Levels per Side — maximum active resistance and support levels maintained simultaneously (default: 4 each)
[*]Level Decay (bars) — bars since last touch after which a level is pruned from the lattice (default: 250)
[*]ATR Length — ATR calculation lookback (default: 14)
[*]Show S/R Zones — toggle lattice boxes and midlines
[*]Blend HTF Swing Levels — toggle higher timeframe level incorporation
[*]HTF for Levels — the higher timeframe from which pivot levels are imported (default: H4)
[*]HTF Pivot Length — pivot length for HTF level detection (default: 5)
[/list]

[b]Interaction Playbooks[/b]
[list]
[*]DEFEND — Wick Rejection at Level — toggle the rejection wick playbook
[*]SWEEP — Liquidity Grab + Reclaim — toggle the sweep and reclaim playbook
[*]RETEST — Break then Hold — toggle the S/R flip retest playbook
[*]COIL — Compression into Level — toggle the narrow-bar compression playbook
[*]Max Distance to Level (xATR) — ATR distance from level within which an interaction is considered proximate (default: 0.35)
[*]Min Rejection Wick % — minimum wick fraction of bar range for DEFEND (default: 0.52)
[*]Min Sweep Depth (xATR) — minimum extension below/above zone boundary for SWEEP (default: 0.12)
[*]RETEST Lookback (bars) — bars to scan for the prior breakout in RETEST detection (default: 12)
[*]COIL Min Narrow Bars — consecutive narrow-ATR bars required for COIL (default: 4)
[*]Min Level Strength (touches) — minimum composite strength for a level to generate signals (default: 2)
[/list]

[b]Confluence[/b]
[list]
[*]Min Layers (of 7) — minimum confluence score to fire a signal (default: 4)
[*]HTF Trend Bias / HTF Bias TF / HTF Fast / Slow EMA — trend bias filter parameters
[*]Volume Expansion / Volume vs Avg / Volume Avg Length — volume layer parameters
[*]Block Extreme Chop / Choppiness Length / Chop Block Above — chop gate parameters
[*]Session Filter / Active Session — trading hours restriction
[*]Signal Cooldown (bars) — minimum bars between signals (default: 6)
[/list]

[b]Level-to-Level Guidance[/b]
[list]
[*]Show SL + Next Level Target — toggle the stop and target guide lines
[*]SL Beyond Sweep/Zone (xATR) — ATR buffer beyond the zone boundary for stop placement (default: 0.35)
[*]Show Playbook Label — toggle the signal label showing playbook name and level price
[/list]

[b]Display[/b]
[list]
[*]Show Entry Markers — toggle the ⬡ diamond signal shapes
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Support — yellow-green for support zones and bullish signal elements
[*]Bear / Resistance — red for resistance zones and bearish signal elements
[*]S/R Lattice — purple for standard lattice zones and midlines
[*]HTF Level — slateblue for HTF-blended level zones and midlines
[*]Sweep Accent — orange for SWEEP playbook accents and chop warnings
[*]Stop Guide / Next Level Target — stop and target line colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (2 total + runtime)[/b]

[b]Entry Alerts[/b]
[list]
[*]Bastion Long — qualifying long interaction fired at a support level. Alert message includes playbook name, level price, and next wall target
[*]Bastion Short — qualifying short interaction fired at a resistance level
[/list]

Runtime alerts (via the alert() function) fire simultaneously with the chart signals, also containing the playbook, level price, and target in the message for immediate actionability.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–H1[/b]:
[list]
[*]Pivot Length at 5 — balanced sensitivity for intraday lattice construction
[*]Zone Merge at 0.22× ATR — appropriate for gold's tick structure; tighter than typical forex parameters
[*]Level Decay at 250 bars — approximately 20 hours on M5; sufficient to maintain intraday relevance without accumulating ancient levels
[*]HTF for Levels at H4 — the most widely respected swing timeframe for gold and forex institutional structure
[*]Minimum Level Strength at 2 — requires at least two confirmed touches before a level can generate signals
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Pivot Length to 3, reduce Zone Merge to 0.15, reduce Level Decay to 100–150 bars, reduce Cooldown to 3, reduce COIL Min Narrow Bars to 2–3
[*][b]H4–Daily swing trading[/b] — increase Pivot Length to 8–10, increase Zone Merge to 0.35, increase Level Decay to 500+, set HTF for Levels to Weekly, increase Min Level Strength to 3
[*][b]Crypto (BTC, ETH)[/b] — increase Zone Merge to 0.28–0.35 for wider tick structure, increase Min Sweep Depth to 0.18, increase Level Decay to 300
[*][b]Indices (NAS100, US30)[/b] — use session filter for cash market hours, increase Zone Merge to 0.25, increase Min Level Strength to 3 for index structure
[*][b]More signals[/b] — lower Min Layers to 3, reduce Min Level Strength to 1, increase Max Distance to Level to 0.50
[*][b]Highest-quality only[/b] — raise Min Layers to 5–6, increase Min Level Strength to 3+, enable only SWEEP and RETEST playbooks
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🏰 [b]Support and resistance traders[/b] — BASTION is the most complete and systematic S/R implementation in the AlphaX suite. Every aspect of the S/R trading approach — level identification, strength scoring, interaction detection, stop placement, target identification — is automated and quantified
[*]📡 [b]Multi-timeframe S/R traders[/b] — the HTF level blending system automatically incorporates H4 (or any configurable timeframe) swing levels into the same lattice, producing a multi-timeframe S/R map without requiring manual level drawing across timeframes
[*]💧 [b]Liquidity sweep traders[/b] — the SWEEP playbook at lattice levels is the highest-conviction signal type in BASTION, combining the stop-hunt reversal concept from MAGNET with the pre-qualified, strength-scored level framework of the lattice
[*]🎯 [b]Traders who want structurally meaningful targets[/b] — the level-to-level target system is the most institutionally grounded TP approach available — targeting the next defended wall rather than an arbitrary distance
[*]🧠 [b]Systematic traders who want quantified S/R[/b] — touch counts, strength scores, decay parameters, and confluence layers replace entirely subjective level identification with objective, repeatable criteria
[*]📈 [b]Traders across all asset classes[/b] — the ATR-normalized zone parameters adapt naturally to gold, forex, crypto, and indices without manual recalibration between instruments
[*]⚠ [b]Traders who draw too many or too few S/R levels manually[/b] — BASTION manages level count automatically through the Max Levels per Side setting and the decay system — always showing the most current and most relevant levels without chart clutter
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Lattice construction, level strength, playbook detection, and confluence scoring all finalize on confirmed bars only
[*]The lattice is built incrementally from the first bar of chart history. On initial chart loads, the lattice will be sparse for the first 50–100 bars as pivots begin to form and levels begin to cluster. Signal quality improves as the lattice populates
[*]The level decay mechanism (default: 250 bars) means that on very active instruments with frequent pivots, the lattice refreshes relatively quickly. On slower instruments or higher timeframes, levels persist longer. Adjust the decay period to match your instrument's typical S/R memory window
[*]HTF level blending uses Pine Script's request.security — HTF pivots are confirmed on the HTF's own bar close schedule, not the current timeframe. This is non-repainting and consistent with all standard security requests
[*]When multiple playbooks fire at the same level on the same bar, the signal with the highest layer count is selected. The dashboard's playbook abbreviations show which playbooks are currently enabled
[*]Maximum 500 lines, 500 labels, and 60 boxes are rendered. The lattice visualization uses boxes and lines for each level, the signal uses a label, and the guide uses lines and labels. On very active charts with maximum level counts, older elements may be removed by TradingView rendering limits
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that price does not move in a vacuum — it moves between walls, and the key to reading the market is knowing where those walls are, how strong they are, and exactly what price does when it arrives at them.[/i]

## Source Code

````pine
// © AlphaX — BASTION v1.0
// Support / Resistance Lattice + Pattern Interaction Engine.
// Maps defended price levels (touch-clustered S/R), scores level strength,
// fires playbook signals when classical micro-patterns interact with those walls:
// DEFEND · SWEEP · RETEST · COIL. Targets = next Bastion level (not measured moves).


//@version=6
indicator("[ A L P H A X ] BASTION - Support & Resistance Patterns", shorttitle="AlphaX BASTION",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=60, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  LATTICE ENGINE — dynamic S/R zones
// ═══════════════════════════════════════════════════════════════════════════════
grpLat = "S/R Lattice"
pivLen         = input.int(5, "Swing Pivot Length", minval=2, maxval=15, group=grpLat)
zoneTolAtr     = input.float(0.22, "Zone Merge (xATR)", minval=0.08, maxval=0.8, step=0.01, group=grpLat)
zoneHalfAtr    = input.float(0.18, "Zone Half-Height (xATR)", minval=0.05, maxval=0.5, step=0.01, group=grpLat)
maxPerSide     = input.int(4, "Max Levels per Side", minval=2, maxval=6, group=grpLat)
levelDecayBars = input.int(250, "Level Decay (bars)", minval=50, maxval=800, group=grpLat)
atrLen         = input.int(14, "ATR Length", minval=2, maxval=100, group=grpLat)
showLattice    = input.bool(true, "Show S/R Zones", group=grpLat)
showHtfLevels  = input.bool(true, "Blend HTF Swing Levels", group=grpLat)
htfTf          = input.timeframe("240", "HTF for Levels", group=grpLat)
htfPivLen      = input.int(5, "HTF Pivot Length", minval=2, maxval=15, group=grpLat)

// ═══════════════════════════════════════════════════════════════════════════════
//  PLAYBOOKS — pattern × level interaction
// ═══════════════════════════════════════════════════════════════════════════════
grpPlay = "Interaction Playbooks"
enDefend       = input.bool(true, "DEFEND — Wick Rejection at Level", group=grpPlay)
enSweep        = input.bool(true, "SWEEP — Liquidity Grab + Reclaim", group=grpPlay)
enRetest       = input.bool(true, "RETEST — Break then Hold (S/R Flip)", group=grpPlay)
enCoil         = input.bool(true, "COIL — Compression into Level", group=grpPlay)
proxAtr        = input.float(0.35, "Max Distance to Level (xATR)", minval=0.1, maxval=1.5, step=0.05, group=grpPlay)
wickMin        = input.float(0.52, "Min Rejection Wick %", minval=0.3, maxval=0.85, step=0.02, group=grpPlay)
sweepDepth     = input.float(0.12, "Min Sweep Depth (xATR)", minval=0.03, maxval=0.5, step=0.01, group=grpPlay)
retestBars     = input.int(12, "RETEST Lookback (bars)", minval=3, maxval=40, group=grpPlay)
coilBars       = input.int(4, "COIL Min Narrow Bars", minval=2, maxval=10, group=grpPlay)
minLevelStr    = input.int(2, "Min Level Strength (touches)", minval=1, maxval=6, group=grpPlay)

// ═══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE & FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
grpConf = "Confluence"
minLayers      = input.int(4, "Min Layers (of 7)", minval=3, maxval=7, group=grpConf)
useHtfBias     = input.bool(true, "HTF Trend Bias", group=grpConf)
htfBiasTf      = input.timeframe("60", "HTF Bias TF", group=grpConf)
htfFast        = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpConf)
htfSlow        = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpConf)
useVol         = input.bool(true, "Volume Expansion", group=grpConf)
volMult        = input.float(1.08, "Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpConf)
volLen         = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpConf)
useChop        = input.bool(true, "Block Extreme Chop", group=grpConf)
chopLen        = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpConf)
chopMax        = input.float(62.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpConf)
useSession     = input.bool(false, "Session Filter", group=grpConf)
sessStart      = input.session("0700-2000", "Active Session", group=grpConf)
cooldown       = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpConf)

// ═══════════════════════════════════════════════════════════════════════════════
//  GUIDANCE — level-to-level (unique vs FORGE measured moves)
// ═══════════════════════════════════════════════════════════════════════════════
grpGuide = "Level-to-Level Guidance"
showGuide      = input.bool(true, "Show SL + Next Level Target", group=grpGuide)
slBeyondAtr    = input.float(0.35, "SL Beyond Sweep/Zone (xATR)", minval=0.1, maxval=2.0, step=0.05, group=grpGuide)
showConfLbl    = input.bool(true, "Show Playbook Label", group=grpGuide)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
showSignals    = input.bool(true, "Show Entry Markers", group=grpVis)
showDash       = input.bool(true, "Show Dashboard", group=grpVis)
dashPos        = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors (AlphaX Palette)"
colBull        = input.color(#c8e624, "Bull / Support", group=grpColors)
colBullBr      = input.color(#d4f03a, "Bull Signal", group=grpColors)
colBear        = input.color(#ff1744, "Bear / Resistance", group=grpColors)
colBearBr      = input.color(#ff5252, "Bear Signal", group=grpColors)
colLattice     = input.color(#8b6fd0, "S/R Lattice", group=grpColors)
colHtf         = input.color(#6a5acd, "HTF Level", group=grpColors)
colSweep       = input.color(#ff9800, "Sweep Accent", group=grpColors)
colSl          = input.color(#ff1744, "Stop Guide", group=grpColors)
colTgt         = input.color(#c8e624, "Next Level Target", group=grpColors)
colNeutral     = input.color(#555555, "Neutral", group=grpColors)
colTextLt      = input.color(#cccccc, "Dash Text", group=grpColors)
colDashBg      = input.color(#1a1a1a, "Dash BG", group=grpColors)
colDashHeader  = input.color(#111111, "Dash Header", group=grpColors)
colDashSec     = input.color(#222222, "Dash Section", group=grpColors)
colDashFrame   = input.color(#c8e624, "Dash Frame", group=grpColors)

grpAlrt = "Alerts"
alertEn        = input.bool(true, "Enable Alerts", group=grpAlrt)

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPES
// ═══════════════════════════════════════════════════════════════════════════════
type Level
    float mid
    float top
    float bot
    bool  isRes
    int   touches
    int   bornBar
    int   lastTouch
    bool  htf

type Signal
    bool   fire
    bool   bull
    string playbook
    float  atLevel
    float  entry
    float  stop
    float  target
    int    strength
    int    layers

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
var Level[] resLevels = array.new<Level>()
var Level[] supLevels = array.new<Level>()
var line[] latLines = array.new_line()
var box[] latBoxes = array.new_box()
var label[] guideLbls = array.new_label()
var line[] guideLns = array.new_line()

var int lastSigBar = na
var string dashPlay = "—"
var string dashSide = "—"
var float dashSup = na
var float dashRes = na
var int dashSupStr = 0
var int dashResStr = 0
var float dashTgt = na

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)
rng    = math.max(high - low, syminfo.mintick)
body   = math.abs(close - open)
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low
bodyTop = math.max(close, open)
bodyBot = math.min(close, open)

float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0
bool chopOk = not useChop or chopIdx < chopMax
bool inSession = not useSession or not na(time(timeframe.period, sessStart))
bool volOk = not useVol or volume >= volMa * volMult

htfClose = request.security(syminfo.tickerid, htfBiasTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfBiasTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfBiasTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfSlowE

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_nearLevel(float price, Level lv) =>
    math.abs(price - lv.mid) <= atrVal * proxAtr or (price <= lv.top and price >= lv.bot)

f_strength(Level lv) =>
    int s = lv.touches
    s += lv.htf ? 2 : 0
    s += bar_index - lv.bornBar < 80 ? 1 : 0
    s

f_mergeLevel(Level[] arr, float price, bool isRes, bool htf) =>
    float half = atrVal * zoneHalfAtr
    bool merged = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            Level lv = arr.get(i)
            if math.abs(price - lv.mid) <= atrVal * zoneTolAtr
                lv.mid := (lv.mid * lv.touches + price) / (lv.touches + 1)
                lv.top := math.max(lv.top, price + half)
                lv.bot := math.min(lv.bot, price - half)
                lv.touches += 1
                lv.lastTouch := bar_index
                arr.set(i, lv)
                merged := true
                break
    if not merged
        Level nu = Level.new(price, price + half, price - half, isRes, 1, bar_index, bar_index, htf)
        arr.unshift(nu)
        if arr.size() > maxPerSide
            arr.pop()

f_prune(Level[] arr) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Level lv = arr.get(i)
            if bar_index - lv.lastTouch > levelDecayBars
                arr.remove(i)

f_nearestSup() =>
    float best = na
    int str = 0
    if supLevels.size() > 0
        float d = 1e10
        for lv in supLevels
            if lv.mid <= close
                float dist = close - lv.mid
                if dist < d
                    d := dist
                    best := lv.mid
                    str := f_strength(lv)
    [best, str]

f_nearestRes() =>
    float best = na
    int str = 0
    if resLevels.size() > 0
        float d = 1e10
        for lv in resLevels
            if lv.mid >= close
                float dist = lv.mid - close
                if dist < d
                    d := dist
                    best := lv.mid
                    str := f_strength(lv)
    [best, str]

f_nextTarget(bool bull, float from) =>
    float tgt = na
    if bull and resLevels.size() > 0
        float d = 1e10
        for lv in resLevels
            if lv.mid > from + syminfo.mintick
                float dist = lv.mid - from
                if dist < d
                    d := dist
                    tgt := lv.mid
    if not bull and supLevels.size() > 0
        float d = 1e10
        for lv in supLevels
            if lv.mid < from - syminfo.mintick
                float dist = from - lv.mid
                if dist < d
                    d := dist
                    tgt := lv.mid
    tgt

f_layers(bool bull, Level lv, string pb) =>
    int n = 0
    n += f_strength(lv) >= minLevelStr ? 1 : 0
    n += bull and htfBull and useHtfBias ? 1 : not bull and htfBear and useHtfBias ? 1 : useHtfBias ? 0 : 1
    n += volOk ? 1 : 0
    n += chopOk ? 1 : 0
    n += pb == "SWEEP" ? 1 : pb == "RETEST" ? 1 : 0
    n += rng >= atrVal * 0.35 ? 1 : 0
    n += inSession ? 1 : 0
    n

f_clearLattice() =>
    for ln in latLines
        if not na(ln)
            line.delete(ln)
    for bx in latBoxes
        if not na(bx)
            box.delete(bx)
    array.clear(latLines)
    array.clear(latBoxes)

f_clearGuide() =>
    for ln in guideLns
        if not na(ln)
            line.delete(ln)
    for lb in guideLbls
        if not na(lb)
            label.delete(lb)
    array.clear(guideLns)
    array.clear(guideLbls)

// Build lattice from pivots
float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)
if not na(ph)
    f_mergeLevel(resLevels, ph, true, false)
if not na(pl)
    f_mergeLevel(supLevels, pl, false, false)

float htfPh = request.security(syminfo.tickerid, htfTf, ta.pivothigh(high, htfPivLen, htfPivLen), barmerge.gaps_off, barmerge.lookahead_off)
float htfPl = request.security(syminfo.tickerid, htfTf, ta.pivotlow(low, htfPivLen, htfPivLen), barmerge.gaps_off, barmerge.lookahead_off)
if showHtfLevels and not na(htfPh)
    f_mergeLevel(resLevels, htfPh, true, true)
if showHtfLevels and not na(htfPl)
    f_mergeLevel(supLevels, htfPl, false, true)

f_prune(resLevels)
f_prune(supLevels)

// ═══════════════════════════════════════════════════════════════════════════════
//  PLAYBOOK SCANNER
// ═══════════════════════════════════════════════════════════════════════════════
Signal EMPTY_SIG = Signal.new(false, false, "", na, na, na, na, 0, 0)
Signal best = EMPTY_SIG

if bar_index > 100 and chopOk and inSession
    // LONG playbooks at support
    if supLevels.size() > 0
        for lv in supLevels
            if f_strength(lv) < minLevelStr
                continue
            if not f_nearLevel(low, lv)
                continue
            string pb = ""
            bool ok = false
            if enDefend and dnWick / rng >= wickMin and close > bodyBot + rng * 0.25 and close > lv.bot
                pb := "DEFEND"
                ok := true
            if not ok and enSweep and low < lv.bot - atrVal * sweepDepth and close > lv.mid and close > open
                pb := "SWEEP"
                ok := true
            if not ok and enRetest
                bool broke = false
                for k = 1 to retestBars
                    if close[k] < lv.bot and close > lv.mid
                        broke := true
                        break
                if broke and low <= lv.top and close > lv.mid and close > open
                    pb := "RETEST"
                    ok := true
            if not ok and enCoil
                bool narrow = true
                for k = 0 to coilBars - 1
                    if ta.atr(1)[k] > atrVal * 0.75
                        narrow := false
                if narrow and f_nearLevel(close, lv) and close > lv.mid
                    pb := "COIL"
                    ok := true
            if ok
                float entry = close
                float stop = lv.bot - atrVal * slBeyondAtr
                float tgt = f_nextTarget(true, entry)
                int layers = f_layers(true, lv, pb)
                if layers >= minLayers and (not useHtfBias or htfBull)
                    Signal cand = Signal.new(true, true, pb, lv.mid, entry, stop, tgt, f_strength(lv), layers)
                    if not best.fire or cand.layers > best.layers
                        best := cand

    // SHORT playbooks at resistance
    if resLevels.size() > 0
        for lv in resLevels
            if f_strength(lv) < minLevelStr
                continue
            if not f_nearLevel(high, lv)
                continue
            string pb = ""
            bool ok = false
            if enDefend and upWick / rng >= wickMin and close < bodyTop - rng * 0.25 and close < lv.top
                pb := "DEFEND"
                ok := true
            if not ok and enSweep and high > lv.top + atrVal * sweepDepth and close < lv.mid and close < open
                pb := "SWEEP"
                ok := true
            if not ok and enRetest
                bool broke = false
                for k = 1 to retestBars
                    if close[k] > lv.top and close < lv.mid
                        broke := true
                        break
                if broke and high >= lv.bot and close < lv.mid and close < open
                    pb := "RETEST"
                    ok := true
            if not ok and enCoil
                bool narrow = true
                for k = 0 to coilBars - 1
                    if ta.atr(1)[k] > atrVal * 0.75
                        narrow := false
                if narrow and f_nearLevel(close, lv) and close < lv.mid
                    pb := "COIL"
                    ok := true
            if ok
                float entry = close
                float stop = lv.top + atrVal * slBeyondAtr
                float tgt = f_nextTarget(false, entry)
                int layers = f_layers(false, lv, pb)
                if layers >= minLayers and (not useHtfBias or htfBear)
                    Signal cand = Signal.new(true, false, pb, lv.mid, entry, stop, tgt, f_strength(lv), layers)
                    if not best.fire or cand.layers > best.layers
                        best := cand

var int lastPbBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown
bool bullSig = showSignals and best.fire and best.bull and cooled and barstate.isconfirmed
bool bearSig = showSignals and best.fire and not best.bull and cooled and barstate.isconfirmed

if bullSig or bearSig
    lastSigBar := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
//  DRAW LATTICE (refresh on last bar)
// ═══════════════════════════════════════════════════════════════════════════════
if showLattice and barstate.islast
    f_clearLattice()
    int drawnRes = 0
    int drawnSup = 0
    for lv in resLevels
        if drawnRes >= maxPerSide
            break
        color lc = lv.htf ? colHtf : colLattice
        box bx = box.new(lv.bornBar, lv.top, bar_index + 15, lv.bot,
          border_color=color.new(lc, 50), bgcolor=color.new(lc, 88), border_width=1)
        line ln = line.new(lv.bornBar, lv.mid, bar_index + 15, lv.mid,
          color=color.new(lc, 20), width=lv.htf ? 2 : 1, style=line.style_dashed)
        array.push(latBoxes, bx)
        array.push(latLines, ln)
        drawnRes += 1
    for lv in supLevels
        if drawnSup >= maxPerSide
            break
        color lc = lv.htf ? colHtf : colLattice
        box bx = box.new(lv.bornBar, lv.top, bar_index + 15, lv.bot,
          border_color=color.new(colBull, 60), bgcolor=color.new(colBull, 90), border_width=1)
        line ln = line.new(lv.bornBar, lv.mid, bar_index + 15, lv.mid,
          color=color.new(colBull, 30), width=lv.htf ? 2 : 1, style=line.style_dashed)
        array.push(latBoxes, bx)
        array.push(latLines, ln)
        drawnSup += 1

// ═══════════════════════════════════════════════════════════════════════════════
//  SIGNAL MARKERS + GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(bullSig, title="Bastion Long", style=shape.diamond, location=location.belowbar,
  color=colBullBr, size=size.small, text="⬡")
plotshape(bearSig, title="Bastion Short", style=shape.diamond, location=location.abovebar,
  color=colBearBr, size=size.small, text="⬡")

if (bullSig or bearSig) and showConfLbl
    string side = best.bull ? "LONG" : "SHORT"
    string txt = "BASTION " + side + "\n" + best.playbook + " @ " + str.tostring(best.atLevel, format.mintick)
    label.new(bar_index, best.bull ? low : high, txt,
      color=color.new(colDashBg, 10), textcolor=best.bull ? colBullBr : colBearBr,
      style=best.bull ? label.style_label_up : label.style_label_down, size=size.small)

if (bullSig or bearSig) and showGuide
    f_clearGuide()
    int x2 = bar_index + 30
    line lSl = line.new(bar_index, best.stop, x2, best.stop, color=colSl, style=line.style_dotted, width=1)
    array.push(guideLns, lSl)
    label lSlb = label.new(x2, best.stop, "SL", style=label.style_label_left,
      color=color.new(colDashBg, 30), textcolor=colSl, size=size.tiny)
    array.push(guideLbls, lSlb)
    if not na(best.target)
        line lTg = line.new(bar_index, best.target, x2, best.target, color=colTgt, style=line.style_dashed, width=1)
        array.push(guideLns, lTg)
        label lTb = label.new(x2, best.target, "NEXT WALL", style=label.style_label_left,
          color=color.new(colDashBg, 30), textcolor=colTgt, size=size.tiny)
        array.push(guideLbls, lTb)

if alertEn and bullSig
    alert("BASTION LONG " + best.playbook + " @ " + str.tostring(best.atLevel, format.mintick) +
      " | tgt " + str.tostring(best.target, format.mintick), alert.freq_once_per_bar_close)
if alertEn and bearSig
    alert("BASTION SHORT " + best.playbook + " @ " + str.tostring(best.atLevel, format.mintick) +
      " | tgt " + str.tostring(best.target, format.mintick), alert.freq_once_per_bar_close)

// Dashboard state
[ns, ss] = f_nearestSup()
[nr, rs] = f_nearestRes()
if bullSig or bearSig
    dashPlay := best.playbook
    dashSide := best.bull ? "▲ LONG" : "▼ SHORT"
    dashTgt := best.target
else if barstate.islast
    dashPlay := "WATCH WALLS"
    dashSide := close > nz(nr, close) ? "NEAR RES" : close < nz(ns, close) ? "NEAR SUP" : "MID-RANGE"
    dashTgt := na

dashSup := ns
dashRes := nr
dashSupStr := ss
dashResStr := rs

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(getDashPos(dashPos), 2, 14,
  border_width=1, border_color=color.new(colDashFrame, 60),
  frame_width=1, frame_color=color.new(colDashFrame, 40))

if showDash and barstate.islast
    color dbg = color.new(colDashBg, 0)
    color sec = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX BASTION", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period,
      text_color=color.new(colBull, 30), text_size=size.tiny, bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── LATTICE ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=sec)

    table.cell(dash, 0, 2, "NEAREST SUP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, not na(dashSup) ? str.tostring(dashSup, format.mintick) + "  [" + str.tostring(dashSupStr) + "]" : "—",
      text_color=colBull, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "NEAREST RES", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, not na(dashRes) ? str.tostring(dashRes, format.mintick) + "  [" + str.tostring(dashResStr) + "]" : "—",
      text_color=colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "ZONE COUNT", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, str.tostring(supLevels.size()) + " sup · " + str.tostring(resLevels.size()) + " res",
      text_color=colLattice, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── PLAYBOOK ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=sec)

    table.cell(dash, 0, 6, "STATE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, dashPlay, text_color=dashPlay == "SWEEP" ? colSweep : colLattice, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 7, "BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, dashSide, text_color=str.contains(dashSide, "LONG") ? colBull : str.contains(dashSide, "SHORT") ? colBear : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "NEXT WALL TGT", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, not na(dashTgt) ? str.tostring(dashTgt, format.mintick) : "—",
      text_color=colTgt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "─── FILTERS ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 9, "", bgcolor=sec)

    table.cell(dash, 0, 10, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 11, "CHOP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, str.tostring(chopIdx, "#.#"), text_color=chopOk ? colTextLt : colSweep, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "VOLUME", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, volOk ? "EXPAND" : "QUIET", text_color=volOk ? colBull : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "PLAYBOOKS ON", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    string pbOn = (enDefend ? "DEF " : "") + (enSweep ? "SWP " : "") + (enRetest ? "RET " : "") + (enCoil ? "COIL" : "")
    table.cell(dash, 1, 13, pbOn, text_color=colTextLt, text_size=size.tiny, bgcolor=dbg)

alertcondition(bullSig, title="Bastion Long", message="[AlphaX BASTION] Long at S/R interaction on {{ticker}} {{interval}}.")
alertcondition(bearSig, title="Bastion Short", message="[AlphaX BASTION] Short at S/R interaction on {{ticker}} {{interval}}.")
````
