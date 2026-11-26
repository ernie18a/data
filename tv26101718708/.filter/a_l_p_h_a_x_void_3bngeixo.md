# [ A L P H A X ] VOID

- url: https://www.tradingview.com/script/3Bngeixo-A-L-P-H-A-X-VOID/
- type: indicator
- pine_id: PUB;ced4b470ca1a40ada142ad9672fcc573
- version: 1.0

## Description

[b]AlphaX VOID — Fair Value Gap Confluence System: FVG Detection, 5-Layer Retest Entries, CE Rejection Filter & ATR Trailing Exit Engine[/b]

AlphaX VOID is a professional-grade smart money confluence system built around the single most powerful concept in institutional price action: the Fair Value Gap. Where price moves so aggressively that it leaves an unmitigated imbalance in the order book — a void — institutions return to fill orders at those levels. VOID detects every qualifying gap in real time, tracks its state, and waits. When price returns to retest that void, a 5-layer confluence engine evaluates the quality of that retest across EMA structure, squeeze momentum, volume delta pressure, VWAP bias, and ADX directional strength. Only when enough layers agree does a signal fire — not on the gap formation, not on the first touch, but on a confirmed, high-quality institutional retest with the trend and momentum behind it. Designed for active traders on crypto, forex, gold, and indices across the 1-minute to 15-minute timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕳 [b]What Is a Fair Value Gap?[/b]

A Fair Value Gap (FVG) is a three-candle price structure where the middle candle moves with such force that it creates a gap between the wick of the first candle and the wick of the third candle — a zone where no two-sided trading occurred. Price moved through that area too fast for the market to establish fair value.

[b]Bull FVG:[/b] The low of candle 3 is above the high of candle 1. Price left a gap to the upside — an unmitigated bullish imbalance. When price returns to this zone, institutions are likely resting buy orders there.

[b]Bear FVG:[/b] The high of candle 3 is below the low of candle 1. Price left a gap to the downside — an unmitigated bearish imbalance. When price returns to this zone, institutions are likely resting sell orders there.

[b]Why FVGs matter to institutional traders:[/b] Market makers and large institutions cannot fill their full order size in a single fast move. When price revisits the FVG zone, they use the retest to complete their position. This is why FVG retests so frequently produce high-velocity continuation moves — they are not random support/resistance, they are unfilled institutional order clusters.

AlphaX VOID does not simply draw FVG boxes. It tracks the [b]lifecycle of every gap[/b] — from formation through active, retest, and filled — and only presents entry signals when the retest coincides with genuine multi-layer confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]FVG Detection Engine — Quality Filters[/b]

Not every gap is worth trading. Gaps formed during weak, choppy price action are noise. VOID applies two mandatory quality filters to every detected gap before registering it as valid.

[b]Displacement Filter:[/b]
The middle candle of the three-candle structure must show genuine displacement — its body must exceed the average body size over the last 14 bars by a configurable multiplier (default: 1.15×). This ensures the gap was formed by a real impulsive move, not a slow grind that happened to leave a small gap. A gap without displacement is a weak gap.

[b]Minimum Gap Size Filter:[/b]
The physical size of the gap (the distance between the relevant wicks of candle 1 and candle 3) must meet a minimum threshold expressed as a multiple of ATR (default: 0.15×). This eliminates micro-gaps that are too small to be meaningful — gaps so narrow that spread and noise would immediately invalidate any retest entry.

Only gaps passing both filters are registered, stored, and tracked.

[b]FVG Lifecycle Tracking:[/b]
Every registered FVG is stored in memory arrays with its top, bottom, direction, formation bar, and fill state. On every bar, VOID updates the state of all active gaps:
[list]
[*][b]Active[/b] — gap is unmitigated. Box and CE line extend forward in real time
[*][b]Filled[/b] — price has fully closed through the gap boundary. Box color shifts to neutral gray, CE line fades. Optionally hidden entirely via the Hide Filled FVGs setting
[*][b]Age cutoff[/b] — gaps older than the configured Max FVG Age (default: 120 bars) are excluded from retest scanning. Old gaps lose institutional relevance as market structure evolves
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]The FVG Visual System[/b]

Every active FVG is rendered directly on the price chart as a structured visual zone with three components.

[b]FVG Box:[/b]
A shaded rectangle spanning the full gap from top to bottom. Bull gaps are shaded in semi-transparent yellow-green; bear gaps in semi-transparent red. The box extends forward by the configured number of bars (default: 30) and updates in real time as price evolves. When a gap fills, the box shifts to neutral gray — or is removed entirely if Hide Filled FVGs is enabled.

[b]CE Line (Consequent Encroachment — 50% Level):[/b]
A dashed line at the exact midpoint of the FVG zone. This is the [b]Consequent Encroachment level[/b] — the 50% retracement into the gap. This level is critical for entries: the most reliable FVG retests are those where price dips into the gap but closes back above (bull) or below (bear) the CE line, demonstrating that the institutional zone held and rejected price cleanly. The CE Rejection filter is on by default and can be toggled in settings.

[b]FVG Formation Dots:[/b]
Small squares appear below (bull FVG) or above (bear FVG) the bar at the moment a new qualifying gap is formed, providing instant chart-level notification of every new gap without requiring dashboard attention.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The Retest Detection Engine[/b]

Detecting a gap is the easy part. Detecting a [b]high-quality retest[/b] of that gap is the core intellectual challenge VOID is built to solve.

On every bar, VOID scans all active, unfilled FVGs of the appropriate direction for a valid retest condition. A retest requires all of the following to be true simultaneously:

[b]1. Price overlap:[/b] The current bar's low must be at or below the FVG top, and the current bar's high must be at or above the FVG bottom. Price is physically inside or touching the zone.

[b]2. Candle rejection:[/b] The bar must close in the correct direction — a bullish close (close above open) for a bull FVG retest, a bearish close for a bear FVG retest. Price entered the gap but the candle closed back out, demonstrating rejection.

[b]3. CE rejection (when enabled):[/b] For bull retests, the close must be at or above the CE midline — not just any bullish close, but one that reclaims the institutional midpoint. For bear retests, the close must be at or below the CE midline. This is the single most important retest quality filter in the system. A retest that fails to reclaim the 50% level is a weak, indecisive retest.

[b]4. Age validation:[/b] The gap must be no older than the configured maximum age. Gaps older than this threshold are excluded even if all other conditions are met.

[b]5. Most recent qualifying gap priority:[/b] When multiple gaps qualify simultaneously, VOID selects the most recently formed gap — the freshest institutional imbalance takes precedence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]The 5-Layer Confluence Engine[/b]

A valid FVG retest alone is not sufficient for a signal. VOID requires that the retest occur within a high-quality confluence environment across five independent layers. Each layer casts a directional vote on every bar. Signals only fire when a configurable minimum number of votes align (default: 3 of 5).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 1 — EMA Ribbon (Trend Structure)[/b]

A triple EMA ribbon using Fast (default: 8), Slow (default: 21), and Signal (default: 50) EMAs. All three must stack in directional order and price must be on the correct side for a full ribbon vote.

[b]Bull:[/b] Fast above Slow above Signal, close above Fast EMA.
[b]Bear:[/b] Fast below Slow below Signal, close below Fast EMA.

A separate [b]EMA Trend Alignment[/b] setting (default: on) enforces that bull FVG retest signals only fire when the fast EMA is above the slow EMA — the minimum trend structure condition — even if the full ribbon stack is not met. This prevents counter-trend FVG entries that carry the lowest success rate.

The ribbon is plotted on the chart as a gradient fill between the Fast and Slow EMA lines — yellow-green fill during bull structure, red during bear, gray during flat.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 2 — Squeeze Momentum (Energy Detection)[/b]

The TTM Squeeze momentum engine measures whether energy is building or releasing and in which direction.

[b]Squeeze state:[/b] When Bollinger Bands compress inside Keltner Channels, volatility is contracting and a directional breakout is loading. This state is displayed as an orange background tint and flagged on the dashboard as ⚡ SQZ. An FVG retest that coincides with a squeeze release is one of the highest-quality setups the system can detect — the gap provides the structural level, the squeeze provides the breakout energy.

[b]Momentum direction:[/b] Calculated via linear regression of price relative to the midpoint of the recent high-low range. Positive and rising = bull momentum. Negative and falling = bear momentum.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 3 — Volume Delta (Institutional Pressure)[/b]

A proprietary volume pressure model that splits each candle's volume into estimated bullish and bearish components based on the close position within the high-low range, smoothed by EMA. A secondary OBV slope confirms the dominant pressure direction over the configured lookback.

[b]Bull vote:[/b] Bull volume EMA exceeds bear, delta EMA is positive, and OBV slope is rising — three independent volume signals all confirming buying pressure.
[b]Bear vote:[/b] The full inverse.

An FVG retest with genuine volume delta confirmation means real capital is flowing into the gap zone, not just price drifting back. This is the distinction between a high-probability institutional retest and a low-energy drift that is likely to fail.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 4 — VWAP Bias (Institutional Session Reference)[/b]

The Volume Weighted Average Price anchored to the session provides the clearest single reference for institutional directional bias. Price above VWAP means institutions are net buyers for the session. Price below means net sellers.

[b]Bull vote:[/b] Close above VWAP.
[b]Bear vote:[/b] Close below VWAP.

A bull FVG retest that occurs while price is above VWAP is a with-institution trade. A bull FVG retest while price is below VWAP is counter-institutional — the gap exists, the retest is clean, but the session-level bias is working against the entry. This distinction is worth one full confluence point and often determines whether a retest succeeds or fails.

The VWAP filter can be toggled off, and the VWAP line itself can be shown or hidden independently.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Layer 5 — ADX Directional Strength (+DI / -DI)[/b]

The ADX filter in VOID operates at two levels. First, the ADX value must meet the minimum threshold (default: 18) confirming the market is trending rather than ranging. Second, the [b]directional component[/b] is used — +DI versus -DI — to confirm that the ADX strength is aligned with the signal direction.

[b]Bull vote:[/b] ADX above threshold and +DI exceeding -DI — the trend strength is directionally bullish.
[b]Bear vote:[/b] ADX above threshold and -DI exceeding +DI — the trend strength is directionally bearish.

This is fundamentally different from a simple ADX on/off gate. An ADX reading of 25 with +DI above -DI in a bull FVG setup is confirming. An ADX reading of 25 with -DI above +DI in a bull FVG setup means the trend strength is bearish — directionally opposed to the signal — and this layer will not vote for it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Signal Firing Logic[/b]

A VOID signal fires when [b]all of the following are simultaneously true:[/b]
[list]
[*]A valid FVG retest is detected (overlap + candle rejection + CE rejection if enabled + age check)
[*]The confluence score meets or exceeds the configured minimum (default: 3 of 5 layers)
[*]ADX confirms a trending market (value above minimum threshold)
[*]Session filter confirms active hours
[*]Signal cooldown has elapsed since the last signal (default: 8 bars) — prevents repeated signals during extended retest zones
[*]EMA trend alignment condition is met if the Require EMA Trend Alignment setting is enabled
[/list]

[b]Edge triggering:[/b] The signal fires only on the bar where all conditions first become true simultaneously — not on every bar they remain true. Each triangle on the chart represents a distinct, fresh confluence event.

[b]Score label:[/b] Every signal prints a label (e.g., [b]4/5 FVG[/b]) showing the live confluence score at signal time. The [b]FVG[/b] suffix confirms this is an institutional gap retest entry, not a generic momentum entry.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]FVG-Anchored Stop Loss Placement[/b]

VOID includes a purpose-built stop loss mode unique to FVG trading: [b]Place SL Beyond FVG Edge[/b] (default: on).

When enabled, the stop loss for a bull retest entry is placed at the [b]bottom of the retested FVG[/b] minus an ATR buffer — not below the current bar's low. For a bear retest, the stop is placed at the [b]top of the retested FVG[/b] plus an ATR buffer.

[b]Why this matters:[/b] The FVG boundary is the institutional invalidation level. If price closes beyond the far edge of the gap, the imbalance has been fully absorbed — the institutional thesis for the retest is gone and the trade is structurally invalid. Using the FVG edge as the stop base produces stops that are:
[list]
[*]Structurally meaningful — anchored to the actual invalidation level, not an arbitrary ATR distance from entry
[*]Tighter when gaps are narrow — better risk-reward on high-quality, precise gaps
[*]Wider when gaps are large — providing the trade room to breathe within the full institutional zone
[/list]

When this setting is off, the stop reverts to a standard ATR-based distance from the bar's low or high — consistent with the Pulse Scalper behavior.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡 [b]Dynamic ATR Exit System[/b]

All three exit mechanisms from the VOID exit engine work together on every open trade:

[b]Stop Loss:[/b] Placed at the FVG far edge (when enabled) or bar low/high, minus/plus an ATR buffer (default: 1.2×). Your maximum risk boundary. Does not move.

[b]TP1 — Partial Target (50%):[/b] 1.8× ATR from entry. Scale out half the position here and move the remainder to breakeven. A small circle marker appears at the TP1 bar.

[b]TP2 — Full Target:[/b] 3.5× ATR from entry. Full position exits and the system resets. A labeled [b]TP[/b] marker confirms the exit on the chart.

[b]ATR Trailing Stop:[/b] A dynamic stop that advances with price every bar — always positioned 1.5× ATR behind the current bar's low (bull) or high (bear). Plotted as a live orange line. In strong institutional continuation moves, the trail captures significantly more than the fixed TP2 target. In weak retests that stall early, the trail cuts the loss before the fixed SL is reached — providing a tighter actual exit than the structural stop.

All exit levels are plotted as live lines on the chart for the duration of the trade and cleared automatically on exit.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The real-time dashboard displays the complete internal state of the indicator across four sections, updated on every bar.

[b]FVG STATE[/b]
[list]
[*][b]Bull FVGs[/b] — count of currently active, unfilled bull FVGs being tracked
[*][b]Bear FVGs[/b] — count of currently active, unfilled bear FVGs being tracked
[*][b]Retest[/b] — live retest detection status: ▲ BULL RETEST or ▼ BEAR RETEST when a valid gap touch is occurring, — NONE otherwise. This updates in real time so you can see a retest developing before the full signal fires
[/list]

[b]MARKET[/b]
[list]
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF-HOURS. Confirms whether the session filter gate is open
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail. Confirms whether market structure is trending strongly enough to support FVG retest entries
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]L1 EMA[/b] — current ribbon state: ▲ BULL, ▼ BEAR, or — FLAT
[*][b]L2 Momentum[/b] — current momentum state: ⚡ SQZ (squeeze building), ▲ BULL, ▼ BEAR, or — FLAT. The squeeze state is the highest pre-signal alert condition
[*][b]L3 Vol Delta[/b] — current volume pressure: ▲ BULL, ▼ BEAR, or — NEUTRAL
[*][b]L4 VWAP[/b] — current VWAP position: ▲ ABOVE (institutional bull bias) or ▼ BELOW (institutional bear bias)
[*][b]L5 ADX Dir[/b] — ADX directional vote: ▲ BULL (+DI dominant), ▼ BEAR (-DI dominant), or — FLAT
[*][b]Bull Score[/b] — live 0–5 score. Background highlights yellow-green when the minimum threshold is met
[*][b]Bear Score[/b] — live 0–5 score. Background highlights red when the minimum threshold is met
[/list]

[b]POSITION[/b]
[list]
[*][b]Position[/b] — current tracked position: ▲ LONG, ▼ SHORT, or — FLAT with background color highlight
[*][b]Stop Loss[/b] — the active SL level (FVG-anchored or ATR-based depending on settings), color-coded by direction
[*][b]TP1 / TP2[/b] — the active first take-profit level; TP2 is tracked internally and triggers the full exit marker
[*][b]Bars in Trade[/b] — bars elapsed since entry, tracking trade duration
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]FVG Boxes (yellow-green / red)[/b] — active imbalance zones extending forward in real time. Color shifts to gray on fill
[*][b]CE Dashed Lines[/b] — the 50% midpoint of every active FVG. The key level for CE rejection filtering
[*][b]Formation Dots[/b] — small squares marking the exact bar a new qualifying FVG was detected
[*][b]▲ Triangle (below bar)[/b] — bull retest entry signal. All conditions met
[*][b]▼ Triangle (above bar)[/b] — bear retest entry signal. All conditions met
[*][b]Score Label (e.g. 4/5 FVG)[/b] — confluence score at signal time, printed on every entry triangle
[*][b]EMA Ribbon Fill[/b] — yellow-green fill during bull EMA structure, red during bear, gray during flat
[*][b]VWAP Line (purple)[/b] — optional, toggleable session VWAP reference
[*][b]Orange Squeeze Background[/b] — active during Bollinger/Keltner squeeze conditions
[*][b]Yellow-green background tint[/b] — active during open long trades
[*][b]Red background tint[/b] — active during open short trades
[*][b]SL Line[/b] — fixed stop loss level, active while trade is open
[*][b]TP1 Line[/b] — first partial take-profit target
[*][b]TP2 Line (bright)[/b] — full exit target
[*][b]Trail Line (orange)[/b] — dynamic trailing stop, advances with price every bar
[*][b]TP marker[/b] — confirms TP2 hit and full exit
[*][b]SL marker[/b] — confirms stop loss or trail triggered
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX VOID — Step by Step[/b]

[b]Step 1 — Read the FVG State[/b]
[list]
[*]Check the dashboard: how many active bull and bear FVGs are on the chart?
[*]Multiple active FVGs in one direction indicate a well-defined institutional order cluster — a zone with stacked imbalances that price is likely to respect strongly on retest
[*]Zero active FVGs in a direction means no institutional retest opportunity exists yet — wait for a new gap to form
[/list]

[b]Step 2 — Watch for Retest Alert on the Dashboard[/b]
[list]
[*]The RETEST row updates in real time. ▲ BULL RETEST or ▼ BEAR RETEST appearing means price is currently inside a valid FVG zone with a rejection candle forming
[*]This is your cue to check the confluence score rows. Watch the bull or bear score building in real time on the current bar — if it is approaching or has crossed the threshold, a signal may be seconds away
[/list]

[b]Step 3 — Enter on the Signal Triangle[/b]
[list]
[*]A ▲ triangle below the bar is a confirmed bull FVG retest entry. All conditions — FVG retest quality, confluence score, ADX, session, cooldown, trend alignment — are met simultaneously
[*]A ▼ triangle above the bar is a confirmed bear FVG retest entry
[*]Read the score label. A 5/5 signal is the maximum confluence available — all five layers and the gap retest aligned simultaneously. These are the highest-conviction setups VOID produces
[*]Enter on the close of the signal bar or the open of the next bar
[/list]

[b]Step 4 — Manage the Trade with Live Exit Lines[/b]
[list]
[*]The SL line is your structural invalidation. If you used the FVG-anchored SL, price closing beyond this level means the institutional gap has been fully absorbed — the thesis is invalid
[*]Watch the orange Trail Stop advancing with price as the trade moves in your favor
[*]At TP1, scale out 50% of the position. Move your stop to breakeven on the remainder
[*]Let the trailing stop manage the rest — it captures whatever continuation the institutional imbalance produces
[/list]

[b]Step 5 — Exit and Reset[/b]
[list]
[*]A [b]TP[/b] marker confirms TP2 hit. Full exit and system reset
[*]An [b]SL[/b] marker confirms stop or trail triggered. Accept the loss and wait — the FVG that was retested is now filled or invalidated, and a new setup will develop from the next qualifying gap
[*]Never re-enter immediately after a stopped trade. Wait for the confluence score to rebuild and a new qualifying gap to form or a fresh retest of a different active gap
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]ADX ✗ on the dashboard[/b] — the market is not trending. FVG retests in ranging markets are frequently absorbed rather than rejected, producing whipsaw exits
[*][b]RETEST shows ▲ or ▼ but no triangle appears[/b] — a retest is occurring but the confluence score or other filters are blocking the signal. This is the system explicitly telling you the quality threshold is not met — do not override it manually
[*][b]Session ✗ OFF-HOURS[/b] — thin liquidity environments produce unreliable FVG reactions. The institutional actors who created the gap are not active
[*][b]Multiple gap fills in quick succession[/b] — if several FVGs are filling rapidly without producing entries, the market is in a trending impulse phase eating through old imbalances rather than respecting them. Wait for the new gaps being created by this impulse to age and become valid retest candidates
[*][b]Score stuck at 1 or 2 of 5[/b] — the confluence environment is fragmented. Too few layers agree for a reliable institutional retest
[*][b]Orange squeeze background present but score below threshold[/b] — energy is coiling but the directional confluence is not established. Wait for the squeeze to release in a clear direction with score confirmation before acting
[/list]

[b]What to do:[/b]
[list]
[*]Monitor the dashboard for the RETEST row and confluence scores building simultaneously — the ideal setup shows both developing on the same bar
[*]Prioritize gaps with the CE Rejection filter active — CE-rejected retests are the cleanest institutional entries available
[*]Wait for ADX to confirm — a trending ADX above threshold combined with a directional +DI/-DI alignment is the ideal background for FVG retest entries
[*]The highest-quality VOID setup: active squeeze on the dashboard, price retesting a fresh FVG at the CE level, 5/5 confluence score, ADX ✓, session ✓. These conditions together rarely occur — when they do, they produce the strongest continuation moves the system identifies
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🕳 Real-time FVG detection engine — identifies all qualifying bull and bear Fair Value Gaps with displacement and minimum gap size filters
[*]📦 Full FVG lifecycle tracking — every gap stored in memory arrays with top, bottom, direction, age, and fill state updated on every bar
[*]📐 CE (Consequent Encroachment) filter — requires price to reclaim the 50% midpoint of the gap on retest, eliminating weak, indecisive touches
[*]🧠 5-layer confluence gate — EMA Ribbon, Squeeze Momentum, Volume Delta, VWAP Bias, and ADX Directional Strength must agree before a retest signal fires
[*]📊 Live confluence scoring — bull and bear scores updated every bar, displayed on the dashboard before the signal appears
[*]🎯 FVG-anchored stop loss — places the SL at the structural invalidation level (the far FVG edge) rather than a generic ATR distance, producing structurally meaningful risk levels
[*]⚡ Squeeze momentum integration — TTM-style Bollinger/Keltner squeeze detection flags pre-breakout energy buildup with orange background tint and dashboard state
[*]📡 VWAP session bias — confirms whether a retest is with or against institutional session direction
[*]🔬 ADX directional filter — uses both the ADX value and +DI/-DI directionality, not just a simple trend/no-trend gate
[*]🛡 Dynamic ATR trailing stop — orange line advances with price every bar, capturing extended institutional continuation moves beyond the fixed TP2 level
[*]📈 EMA ribbon with trend alignment enforcement — prevents counter-trend FVG entries that carry the lowest success rate
[*]🕐 Session filter — restricts entries to active market hours, eliminating thin-liquidity false retest reactions
[*]⏱ Signal cooldown — prevents repeated signals during extended retest zones, ensuring each entry represents a distinct high-quality event
[*]📊 21-row live dashboard — FVG State, Market, Confluence, and Position sections updated in real time
[*]🔔 10 alert conditions — new FVG formation, retest entry, TP1/TP2 hits, stop hits for both bull and bear
[*]🎨 Fully cohesive dual-tone color system — yellow-green for all bullish elements, red for all bearish elements, orange for squeeze and trail, gray for filled gaps and neutral states
[*]⚙ Fully configurable — FVG parameters, confluence layers, EMA periods, squeeze settings, VWAP filter, ADX threshold, exit multipliers, session window, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Fair Value Gaps[/b]
[list]
[*]Show FVG Zones — toggle FVG boxes on or off
[*]Show CE (50%) Lines — toggle the consequent encroachment midpoint lines
[*]Max Active FVGs — maximum number of FVGs stored in memory simultaneously (default: 40)
[*]Zone Extend (bars) — how many bars forward the FVG box and CE line project (default: 30)
[*]Max FVG Age for Entries — gaps older than this bar count are excluded from retest scanning (default: 120)
[*]Min Gap Size (ATR x) — minimum gap width as a multiple of ATR required for gap registration (default: 0.15)
[*]Min Displacement (body x) — middle candle body must exceed average body by this multiplier (default: 1.15)
[*]Require CE Rejection — close must reclaim the 50% gap midpoint on retest (default: on — strongly recommended)
[*]Hide Filled FVGs — removes boxes and CE lines for gaps that have been fully mitigated (default: off)
[/list]

[b]EMA Ribbon[/b]
[list]
[*]Fast EMA — fastest ribbon line (default: 8)
[*]Slow EMA — intermediate ribbon line (default: 21)
[*]Signal EMA — macro trend anchor (default: 50)
[*]Show EMA Ribbon — toggle ribbon fill and lines
[/list]

[b]Squeeze Momentum[/b]
[list]
[*]BB Length / BB Mult — Bollinger Band parameters for squeeze detection (defaults: 20 / 2.0)
[*]KC Length / KC Mult — Keltner Channel parameters (defaults: 20 / 1.5)
[*]Momentum Length — linear regression period for momentum direction (default: 12)
[/list]

[b]Volume Delta[/b]
[list]
[*]Volume MA Length — EMA smoothing for bull and bear volume estimates (default: 14)
[*]OBV Slope Length — lookback for OBV slope directionality (default: 10)
[/list]

[b]VWAP[/b]
[list]
[*]Use VWAP Filter — when on, Layer 4 requires close to be on the correct side of VWAP (default: on)
[*]Show VWAP Line — toggle the VWAP line on the chart (default: off)
[/list]

[b]Confluence Gate[/b]
[list]
[*]Min Layers Required — minimum confluence votes needed for a signal (default: 3 of 5)
[*]Session Filter — toggle active hours restriction
[*]Active Session — configurable session window (default: 0700-2000)
[*]Signal Cooldown — minimum bars between consecutive signals (default: 8)
[*]Require EMA Trend Alignment — enforces minimum EMA directional alignment even when full ribbon is not stacked (default: on)
[/list]

[b]ADX Filter[/b]
[list]
[*]Use ADX Filter — toggle the trend quality and directional gate
[*]ADX Length — calculation lookback (default: 14)
[*]ADX Minimum — threshold below which all signals are suppressed (default: 18)
[/list]

[b]Exit Settings[/b]
[list]
[*]ATR Length — lookback for all ATR exit calculations (default: 10)
[*]SL ATR Mult — stop loss ATR buffer beyond FVG edge or bar low/high (default: 1.2)
[*]TP1 ATR Mult — first take-profit target (default: 1.8)
[*]TP2 ATR Mult — full exit target (default: 3.5)
[*]Use ATR Trailing Stop — toggle dynamic trailing stop
[*]Trail ATR Mult — trailing distance from current bar's extreme (default: 1.5)
[*]Show Exit Levels — toggle SL, TP1, TP2, and trail lines on the chart
[*]Place SL Beyond FVG Edge — anchors stop to the structural gap invalidation level (default: on)
[/list]

[b]Display[/b]
[list]
[*]Show Confluence Score Label — prints live score on every signal triangle
[*]Show Dashboard — toggle the full dashboard panel
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for all bullish signals, fills, ribbons, and labels
[*]Bear / Bear Bright — red family for all bearish signals, fills, ribbons, and labels
[*]Squeeze — orange for squeeze tint and trailing stop line
[*]Bull FVG / Bear FVG — gap box fill and border colors
[*]Filled FVG — neutral gray for mitigated gaps
[*]EMA Fast / Slow / Signal — individual EMA line colors
[*]Ribbon Fill Bull / Bear / Flat — ribbon fill colors for each trend state
[*]VWAP Line — VWAP plot color (default: purple)
[*]SL / TP / TP2 / Trail Lines — individual exit level line colors
[*]Long Zone BG / Short Zone BG — active trade background tints
[*]Bull Label Text / Bear Label Text — text color for score labels on bull and bear signals
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (10 total)[/b]

[b]FVG Formation Alerts[/b]
[list]
[*]New Bull FVG Formed — a qualifying bullish Fair Value Gap has been detected. Watch for retest entry
[*]New Bear FVG Formed — a qualifying bearish Fair Value Gap has been detected. Watch for retest entry
[/list]

[b]Entry Alerts[/b]
[list]
[*]Bull FVG Retest Entry — all conditions met: bull FVG retest, CE rejection, confluence score, ADX, session
[*]Bear FVG Retest Entry — all conditions met for a short institutional retest entry
[/list]

[b]Exit Alerts[/b]
[list]
[*]Bull TP1 Hit — price reaches the first bull take-profit. Scale out 50%
[*]Bull TP2 Hit — price reaches the full bull exit target. Position closed
[*]Bull Stop Hit — stop loss or trailing stop triggered on a long position
[*]Bear TP1 Hit — price reaches the first bear take-profit. Scale out 50%
[*]Bear TP2 Hit — price reaches the full bear exit target. Position closed
[*]Bear Stop Hit — stop loss or trailing stop triggered on a short position
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M1–M5[/b]:
[list]
[*]Min Layers at 3/5 — strong confluence without requiring perfection on every bar
[*]CE Rejection on — the single most important FVG quality filter. Leave this enabled in all configurations
[*]ADX minimum at 18 — slightly more permissive than the Pulse Scalper default, accounting for the structural quality already provided by the FVG retest condition
[*]FVG-anchored SL on — structurally superior stop placement for all FVG-specific entries
[*]Max FVG Age at 120 bars — covers approximately 2 hours on M1, 10 hours on M5. Sufficient for intraday imbalances without trading excessively old gaps
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]Higher timeframes (M15, H1, H4)[/b] — increase Max FVG Age to 200–300, increase Retest Cooldown to 15–25, increase TP2 to 4.5–5.5× ATR, raise Min Confidence to 4/5
[*][b]Crypto (BTC, ETH)[/b] — increase Min Gap Size to 0.25–0.35× ATR to filter micro-gaps in volatile crypto price action, increase KC Mult to 2.0 for the squeeze layer
[*][b]Indices (NAS100, US30)[/b] — use defaults with session tightened to 09:30–16:00. Increase displacement multiplier to 1.3 for cleaner gap quality on index moves
[*][b]More signals[/b] — lower Min Layers to 2, disable CE Rejection, increase Max FVG Age, reduce Cooldown
[*][b]Fewer, higher-quality signals[/b] — raise Min Layers to 4 or 5, keep CE Rejection on, raise ADX minimum to 22–25, reduce Max FVG Age to 60–80 bars
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🏦 [b]Smart money and institutional price action traders[/b] — VOID is built on the core concept that institutional order flow creates imbalances and returns to fill them. This is the foundational logic of ICT methodology applied with quantitative confluence filters
[*]🥇 [b]Gold (XAUUSD) and forex scalpers[/b] — FVGs are particularly reliable on gold and major forex pairs where institutional order flow is most dominant
[*]📊 [b]Crypto and index traders[/b] — the displacement and gap size filters adapt the system to higher-volatility instruments without producing noise
[*]🎯 [b]Precision entry traders[/b] — the CE rejection filter and FVG-anchored stop produce tighter, more structurally defined entries than generic momentum systems
[*]🧠 [b]Systematic traders[/b] — the 5-layer confluence score provides a quantitative quality metric for every retest event, not just a visual signal
[*]📉 [b]Traders who want to stop chasing breakouts[/b] — VOID forces you to wait for price to return to the institutional level, eliminating the discipline failure of entering on extended, overheated moves
[*]⚠ [b]Traders who struggle with stop placement[/b] — the FVG-anchored SL system provides structurally meaningful stop levels determined by the market's own imbalance boundaries, not arbitrary ATR multiples
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. FVG boxes and CE lines may extend or update visually on the current bar, but no signal is generated until bar close confirmation
[*]The CE Rejection filter is strongly recommended. Disabling it allows signals on any touch of the FVG box, including weak wicks that are unlikely to produce clean continuation moves
[*]Maximum 500 labels, 500 lines, and 500 boxes are rendered. On very low timeframes with extended chart history, the oldest FVG boxes, CE lines, and signal markers may be automatically removed by TradingView's rendering limits. Reduce Max Active FVGs if this becomes an issue
[*]FVG fill state is based on bar close — a wick through the gap boundary that closes inside or above the zone does not mark the gap as filled. Only a close beyond the boundary constitutes a fill
[*]The VWAP calculation resets at the start of each session. On 24-hour crypto instruments, the VWAP anchors to the chart's visible history. For best VWAP behavior on crypto, consider disabling the VWAP filter (Layer 4) and relying on the remaining four layers
[*]Gap age counting begins from the formation bar. A gap formed 5 bars ago on M5 is 25 minutes old — very fresh. The same gap age on H1 is 5 hours old — potentially stale. Adjust Max FVG Age to your timeframe context
[*]The Trade Status section tracks position direction from signal to exit within a single chart session — it does not connect to your broker or brokerage account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that price always returns to where it left unfinished business — and who want a system precise enough to be there when it does.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX — VOID v1.0
// Fair Value Gap Confluence System: FVG Detection + 5-Layer Retest Entries

//@version=6
indicator("[ A L P H A X ] VOID", shorttitle="AlphaX VOID",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ INPUTS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

grpFvg = "Fair Value Gaps"
showFvgs      = input.bool(true,  "Show FVG Zones",              group=grpFvg)
showFvgCe     = input.bool(true,  "Show CE (50%) Lines",         group=grpFvg)
maxFvgs       = input.int(40,     "Max Active FVGs",             minval=5,  maxval=100, group=grpFvg)
fvgExtend     = input.int(30,     "Zone Extend (bars)",          minval=5,  maxval=200, group=grpFvg)
maxFvgAge     = input.int(120,    "Max FVG Age for Entries",     minval=10, maxval=500, group=grpFvg)
minGapAtr     = input.float(0.15, "Min Gap Size (ATR x)",        minval=0.05, maxval=2.0, step=0.05, group=grpFvg)
dispMult      = input.float(1.15, "Min Displacement (body x)",   minval=0.5, maxval=3.0, step=0.05, group=grpFvg,
  tooltip="Middle candle body must exceed average body × this multiplier.")
retestCe      = input.bool(true,  "Require CE Rejection",        group=grpFvg,
  tooltip="Close must reclaim the 50% consequent encroachment level on retest.")
hideFilled    = input.bool(false, "Hide Filled FVGs",            group=grpFvg)

grp1 = "EMA Ribbon"
emaFast    = input.int(8,  "Fast EMA",   minval=3,  maxval=20,  group=grp1)
emaSlow    = input.int(21, "Slow EMA",   minval=10, maxval=50,  group=grp1)
emaSig     = input.int(50, "Signal EMA", minval=20, maxval=200, group=grp1)
showRibbon = input.bool(true, "Show EMA Ribbon", group=grp1)

grp2 = "Squeeze Momentum"
sqzBBLen  = input.int(20,   "BB Length",         minval=5,  maxval=50,  group=grp2)
sqzBBMult = input.float(2.0,"BB Mult",           minval=1.0,maxval=3.0, step=0.1, group=grp2)
sqzKCLen  = input.int(20,   "KC Length",         minval=5,  maxval=50,  group=grp2)
sqzKCMult = input.float(1.5,"KC Mult",           minval=1.0,maxval=3.0, step=0.1, group=grp2)
momLen    = input.int(12,   "Momentum Length",   minval=5,  maxval=30,  group=grp2)

grp3 = "Volume Delta"
volLen = input.int(14, "Volume MA Length",  minval=5, maxval=50, group=grp3)
obvLen = input.int(10, "OBV Slope Length",  minval=3, maxval=30, group=grp3)

grp4 = "VWAP"
useVwap   = input.bool(true,  "Use VWAP Filter",  group=grp4)
showVwap  = input.bool(false, "Show VWAP Line",   group=grp4)

grp5 = "Confluence Gate"
minConf    = input.int(3, "Min Layers Required (of 5)", minval=2, maxval=5, group=grp5,
  tooltip="How many of the 5 confluence layers must agree before a retest entry fires.")
useSession = input.bool(true, "Session Filter", group=grp5)
sessStart  = input.session("0700-2000", "Active Session", group=grp5)
cooldown   = input.int(8, "Signal Cooldown (bars)", minval=1, maxval=50, group=grp5)
requireTrend = input.bool(true, "Require EMA Trend Alignment", group=grp5)

grp6 = "ADX Filter"
useADX = input.bool(true,   "Use ADX Filter", group=grp6)
adxLen = input.int(14,      "ADX Length",     minval=7,  maxval=30, group=grp6)
adxMin = input.float(18,    "ADX Minimum",    minval=10, maxval=40, group=grp6)

grp7 = "Exit Settings"
atrLen    = input.int(10,    "ATR Length",          minval=5,  maxval=30,  group=grp7)
slMult    = input.float(1.2, "SL ATR Mult",         minval=0.5,maxval=3.0, step=0.1, group=grp7)
tp1Mult   = input.float(1.8, "TP1 ATR Mult (50%)",  minval=0.5,maxval=5.0, step=0.1, group=grp7)
tp2Mult   = input.float(3.5, "TP2 ATR Mult (full)", minval=1.0,maxval=8.0, step=0.1, group=grp7)
useTrail  = input.bool(true, "Use ATR Trailing Stop", group=grp7)
trailMult = input.float(1.5, "Trail ATR Mult",       minval=0.5,maxval=4.0, step=0.1, group=grp7)
showExits = input.bool(true, "Show Exit Levels", group=grp7)
slBeyondFvg = input.bool(true, "Place SL Beyond FVG Edge", group=grp7,
  tooltip="Uses the far edge of the retested FVG plus ATR buffer for stop placement.")

grp8 = "Display"
showConf = input.bool(true, "Show Confluence Score Label", group=grp8)
showDash = input.bool(true, "Show Dashboard",              group=grp8)
dashPos  = input.string("Top Right", "Dashboard Position",
  options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp8)

grp9 = "Colors"
colBull    = input.color(#c8e624, "Bull",              group=grp9)
colBullBr  = input.color(#d4f03a, "Bull Bright",       group=grp9)
colBear    = input.color(#ff1744, "Bear",              group=grp9)
colBearBr  = input.color(#ff5252, "Bear Bright",       group=grp9)
colSqueeze = input.color(#ff9800, "Squeeze",           group=grp9)
colNeutral = input.color(#555555, "Neutral",           group=grp9)
colEmaFast = input.color(#c8e624, "EMA Fast",           group=grp9)
colEmaSlow = input.color(#9ab81c, "EMA Slow",          group=grp9)
colEmaSig  = input.color(#555555, "EMA Signal",        group=grp9)
colRibbonBull = input.color(#c8e624, "Ribbon Fill Bull", group=grp9)
colRibbonBear = input.color(#ff1744, "Ribbon Fill Bear", group=grp9)
colRibbonFlat = input.color(#555555, "Ribbon Fill Flat", group=grp9)
colFvgBull = input.color(#c8e624, "Bull FVG",          group=grp9)
colFvgBear = input.color(#ff1744, "Bear FVG",          group=grp9)
colFvgFilled = input.color(#555555, "Filled FVG",      group=grp9)
colVwap    = input.color(#8b6fd0, "VWAP Line",         group=grp9)
colSlLine  = input.color(#ff1744, "SL Line",           group=grp9)
colTpLine  = input.color(#c8e624, "TP Line",           group=grp9)
colTpLineBr = input.color(#d4f03a, "TP2 Line",         group=grp9)
colTrailLine = input.color(#ff9800, "Trail Line",      group=grp9)
colLongZone  = input.color(#c8e624, "Long Zone BG",    group=grp9)
colShortZone = input.color(#ff1744, "Short Zone BG",   group=grp9)
colLabelBullTxt = input.color(#0d0d0d, "Bull Label Text", group=grp9)
colLabelBearTxt = input.color(#ffffff, "Bear Label Text", group=grp9)
colTextLt  = input.color(#cccccc, "Dash Text",         group=grp9)
colDashBg  = input.color(#1a1a1a, "Dash BG",           group=grp9)
colDashHeader = input.color(#111111, "Dash Header BG", group=grp9)
colDashSec = input.color(#222222, "Dash Section BG",  group=grp9)
colDashFrame = input.color(#c8e624, "Dash Frame",      group=grp9)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ HELPERS ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

fvgMid(top, btm) =>
    (top + btm) * 0.5

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ FVG STORAGE ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var array<float> fvgTops   = array.new_float()
var array<float> fvgBtms   = array.new_float()
var array<int>   fvgBars   = array.new_int()
var array<int>   fvgDirs   = array.new_int()
var array<bool>  fvgFilled = array.new_bool()
var array<box>   fvgBoxes  = array.new_box()
var array<line>  fvgLines  = array.new_line()

trimFvgs() =>
    while array.size(fvgTops) > maxFvgs
        box bxOld = array.shift(fvgBoxes)
        line lnOld = array.shift(fvgLines)
        if not na(bxOld)
            box.delete(bxOld)
        if not na(lnOld)
            line.delete(lnOld)
        array.shift(fvgTops)
        array.shift(fvgBtms)
        array.shift(fvgBars)
        array.shift(fvgDirs)
        array.shift(fvgFilled)

addFvg(float top, float btm, int dir, int leftBar) =>
    trimFvgs()
    color fillCol = dir == 1 ? color.new(colFvgBull, 88) : color.new(colFvgBear, 88)
    color edgeCol = dir == 1 ? color.new(colFvgBull, 35) : color.new(colFvgBear, 35)
    box bx = showFvgs ? box.new(leftBar, top, bar_index + fvgExtend, btm,
      border_color=edgeCol, border_width=1,
      bgcolor=fillCol, xloc=xloc.bar_index) : na
    line ln = showFvgs and showFvgCe ? line.new(leftBar, fvgMid(top, btm), bar_index + fvgExtend, fvgMid(top, btm),
      color=color.new(dir == 1 ? colFvgBull : colFvgBear, 55),
      style=line.style_dashed, width=1, xloc=xloc.bar_index) : na
    array.push(fvgTops, top)
    array.push(fvgBtms, btm)
    array.push(fvgBars, leftBar)
    array.push(fvgDirs, dir)
    array.push(fvgFilled, false)
    array.push(fvgBoxes, bx)
    array.push(fvgLines, ln)

updateFvgStates() =>
    int n = array.size(fvgTops)
    if n > 0
        for i = 0 to n - 1
            if not array.get(fvgFilled, i)
                float top = array.get(fvgTops, i)
                float btm = array.get(fvgBtms, i)
                int dir = array.get(fvgDirs, i)
                box bx = array.get(fvgBoxes, i)
                line ln = array.get(fvgLines, i)
                if not na(bx)
                    box.set_right(bx, bar_index + fvgExtend)
                if not na(ln)
                    line.set_x2(ln, bar_index + fvgExtend)
                bool nowFilled = dir == 1 ? low <= btm : high >= top
                if nowFilled
                    array.set(fvgFilled, i, true)
                    if not na(bx)
                        if hideFilled
                            box.delete(bx)
                            array.set(fvgBoxes, i, na)
                        else
                            box.set_bgcolor(bx, color.new(colFvgFilled, 93))
                            box.set_border_color(bx, color.new(colFvgFilled, 75))
                    if not na(ln)
                        if hideFilled
                            line.delete(ln)
                            array.set(fvgLines, i, na)
                        else
                            line.set_color(ln, color.new(colFvgFilled, 80))

scanRetest(int dirWanted) =>
    bool  touch = false
    float tTop  = na
    float tBtm  = na
    int   tBar  = na
    int   n = array.size(fvgTops)
    if n > 0
        for i = 0 to n - 1
            if not array.get(fvgFilled, i) and array.get(fvgDirs, i) == dirWanted
                int leftBar = array.get(fvgBars, i)
                int age = bar_index - leftBar
                if age <= maxFvgAge
                    float top = array.get(fvgTops, i)
                    float btm = array.get(fvgBtms, i)
                    float mid = fvgMid(top, btm)
                    bool overlap = low <= top and high >= btm
                    bool bullReject = close > open and (retestCe ? close >= mid : close >= btm)
                    bool bearReject = close < open and (retestCe ? close <= mid : close <= top)
                    bool reject = dirWanted == 1 ? bullReject : bearReject
                    if overlap and reject and (na(tBar) or leftBar > tBar)
                        touch := true
                        tTop := top
                        tBtm := btm
                        tBar := leftBar
    [touch, tTop, tBtm, tBar]

countActiveFvgs(int dirWanted) =>
    int cnt = 0
    int n = array.size(fvgTops)
    if n > 0
        for i = 0 to n - 1
            if not array.get(fvgFilled, i) and array.get(fvgDirs, i) == dirWanted
                cnt += 1
    cnt

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 1: EMA RIBBON ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float emaF  = ta.ema(close, emaFast)
float emaS  = ta.ema(close, emaSlow)
float emaSG = ta.ema(close, emaSig)

bool emaBull = emaF > emaS and emaS > emaSG and close > emaF
bool emaBear = emaF < emaS and emaS < emaSG and close < emaF
bool emaTrendBull = emaF > emaS
bool emaTrendBear = emaF < emaS

p1 = plot(showRibbon ? emaF  : na, "Fast EMA",   color=color.new(colEmaFast, 30), linewidth=1)
p2 = plot(showRibbon ? emaS  : na, "Slow EMA",   color=color.new(colEmaSlow, 40), linewidth=1)
p3 = plot(showRibbon ? emaSG : na, "Signal EMA", color=color.new(colEmaSig,  20), linewidth=2)
fill(p1, p2, color=emaBull ? color.new(colRibbonBull, 80) : emaBear ? color.new(colRibbonBear, 80) : color.new(colRibbonFlat, 90))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 2: SQUEEZE MOMENTUM ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float bbBasis = ta.sma(close, sqzBBLen)
float bbDev   = sqzBBMult * ta.stdev(close, sqzBBLen)
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev

float kcBasis = ta.ema(close, sqzKCLen)
float kcRange = ta.atr(sqzKCLen)
float kcUpper = kcBasis + sqzKCMult * kcRange
float kcLower = kcBasis - sqzKCMult * kcRange

bool sqzOn  = bbUpper < kcUpper and bbLower > kcLower

float momVal  = ta.linreg(close - math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen)), momLen, 0)
float momPrev = momVal[1]

bool momBull = momVal > 0 and momVal > momPrev
bool momBear = momVal < 0 and momVal < momPrev

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 3: VOLUME DELTA ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float candleRange = high - low
float bullVolEst  = candleRange != 0 ? volume * (close - low) / candleRange : volume * 0.5
float bearVolEst  = volume - bullVolEst

float volMaBull  = ta.ema(bullVolEst, volLen)
float volMaBear  = ta.ema(bearVolEst, volLen)
float volDelta   = volMaBull - volMaBear
float volDeltaMA = ta.ema(volDelta, 5)

float obv      = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
float obvSlope = obv - obv[obvLen]

bool volBull = volDelta > 0 and volDeltaMA > 0 and obvSlope > 0
bool volBear = volDelta < 0 and volDeltaMA < 0 and obvSlope < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 4: VWAP DEVIATION ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

[vwapVal, vwapPlus1, _] = ta.vwap(hlc3, session.isfirstbar, 1.0)

bool vwapBull = useVwap ? close > vwapVal : true
bool vwapBear = useVwap ? close < vwapVal : true

plot(showVwap ? vwapVal : na, "VWAP", color=color.new(colVwap, 40), linewidth=2)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ LAYER 5: ADX FILTER ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float upMove2   = high - high[1]
float downMove2 = low[1] - low
float plusDM2   = upMove2 > downMove2  and upMove2  > 0 ? upMove2   : 0.0
float minusDM2  = downMove2 > upMove2  and downMove2 > 0 ? downMove2 : 0.0
float trRange2  = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
float smTR2     = ta.rma(trRange2, adxLen)
float smPlus2   = ta.rma(plusDM2,  adxLen)
float smMinus2  = ta.rma(minusDM2, adxLen)
float pDI2      = smTR2 != 0 ? 100 * smPlus2  / smTR2 : 0.0
float mDI2      = smTR2 != 0 ? 100 * smMinus2 / smTR2 : 0.0
float dx2       = (pDI2 + mDI2) != 0 ? 100 * math.abs(pDI2 - mDI2) / (pDI2 + mDI2) : 0.0
float adxVal    = ta.rma(dx2, adxLen)
bool  adxOK      = not useADX or adxVal >= adxMin
bool  adxDirBull = not useADX or (adxOK and pDI2 > mDI2)
bool  adxDirBear = not useADX or (adxOK and mDI2 > pDI2)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ FVG DETECTION ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float atrVal   = ta.atr(atrLen)
float avgBody  = ta.sma(math.abs(close - open), 14)
float dispBody = math.abs(close[1] - open[1])
bool  hasDisp  = dispBody >= avgBody * dispMult

bool bullFvgRaw = low > high[2]
bool bearFvgRaw = high < low[2]

float bullGap = low - high[2]
float bearGap = low[2] - high

bool bullFvgNew = barstate.isconfirmed and bullFvgRaw and hasDisp and bullGap >= minGapAtr * atrVal
bool bearFvgNew = barstate.isconfirmed and bearFvgRaw and hasDisp and bearGap >= minGapAtr * atrVal

if bullFvgNew
    addFvg(low, high[2], 1, bar_index - 2)
if bearFvgNew
    addFvg(low[2], high, -1, bar_index - 2)

updateFvgStates()

[bullRetest, bullFvgTop, bullFvgBtm, bullFvgBar] = scanRetest(1)
[bearRetest, bearFvgTop, bearFvgBtm, bearFvgBar] = scanRetest(-1)

int activeBullFvgs = countActiveFvgs(1)
int activeBearFvgs = countActiveFvgs(-1)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ SESSION + CONFLUENCE ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bool inSession = not useSession or not na(time(timeframe.period, sessStart))

int bullScore = (emaBull ? 1 : 0) + (momBull ? 1 : 0) + (volBull ? 1 : 0) +
  (vwapBull ? 1 : 0) + (adxDirBull ? 1 : 0)
int bearScore = (emaBear ? 1 : 0) + (momBear ? 1 : 0) + (volBear ? 1 : 0) +
  (vwapBear ? 1 : 0) + (adxDirBear ? 1 : 0)

var int lastBullSig = -10000
var int lastBearSig = -10000

bool bullCoolOK = bar_index - lastBullSig >= cooldown
bool bearCoolOK = bar_index - lastBearSig >= cooldown

bool bullTrendOK = not requireTrend or emaTrendBull
bool bearTrendOK = not requireTrend or emaTrendBear

bool bullSetup = bullRetest and bullScore >= minConf and adxOK and inSession and bullCoolOK and bullTrendOK
bool bearSetup = bearRetest and bearScore >= minConf and adxOK and inSession and bearCoolOK and bearTrendOK

bool bullSignal = bullSetup and not bullSetup[1]
bool bearSignal = bearSetup and not bearSetup[1]

if bullSignal
    lastBullSig := bar_index
if bearSignal
    lastBearSig := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════ ATR + EXITS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var float bullSL    = na
var float bullTP1   = na
var float bullTP2   = na
var float bearSL    = na
var float bearTP1   = na
var float bearTP2   = na
var float trailStop = na
var int   tradeDir  = 0
var int   tradeBar  = na

slBaseBull = slBeyondFvg and not na(bullFvgBtm) ? bullFvgBtm : low
slBaseBear = slBeyondFvg and not na(bearFvgTop) ? bearFvgTop : high

if bullSignal
    bullSL    := slBaseBull - atrVal * slMult
    bullTP1   := close + atrVal * tp1Mult
    bullTP2   := close + atrVal * tp2Mult
    trailStop := slBaseBull - atrVal * trailMult
    tradeDir  := 1
    tradeBar  := bar_index

if bearSignal
    bearSL    := slBaseBear + atrVal * slMult
    bearTP1   := close - atrVal * tp1Mult
    bearTP2   := close - atrVal * tp2Mult
    trailStop := slBaseBear + atrVal * trailMult
    tradeDir  := -1
    tradeBar  := bar_index

int barsInTrade = not na(tradeBar) ? bar_index - tradeBar : 0

if tradeDir == 1 and useTrail and barsInTrade > 0
    trailStop := math.max(trailStop, low - atrVal * trailMult)
if tradeDir == -1 and useTrail and barsInTrade > 0
    trailStop := math.min(trailStop, high + atrVal * trailMult)

bool exitBullSL  = tradeDir ==  1 and not na(bullSL)  and low  <= bullSL   and barsInTrade > 0
bool exitBullTR  = tradeDir ==  1 and useTrail        and not na(trailStop) and low  <= trailStop and barsInTrade > 1
bool exitBullTP1 = tradeDir ==  1 and not na(bullTP1) and high >= bullTP1  and barsInTrade > 0
bool exitBullTP2 = tradeDir ==  1 and not na(bullTP2) and high >= bullTP2  and barsInTrade > 0
bool exitBearSL  = tradeDir == -1 and not na(bearSL)  and high >= bearSL   and barsInTrade > 0
bool exitBearTR  = tradeDir == -1 and useTrail        and not na(trailStop) and high >= trailStop and barsInTrade > 1
bool exitBearTP1 = tradeDir == -1 and not na(bearTP1) and low  <= bearTP1  and barsInTrade > 0
bool exitBearTP2 = tradeDir == -1 and not na(bearTP2) and low  <= bearTP2  and barsInTrade > 0

bool exitBull = exitBullSL or exitBullTP2 or exitBullTR
bool exitBear = exitBearSL or exitBearTP2 or exitBearTR

if exitBull
    tradeDir  := 0
    bullSL    := na
    bullTP1   := na
    bullTP2   := na
    trailStop := na

if exitBear
    tradeDir  := 0
    bearSL    := na
    bearTP1   := na
    bearTP2   := na
    trailStop := na

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════ PLOTS ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

plotshape(bullFvgNew, title="New Bull FVG",
  style=shape.square, location=location.belowbar,
  color=color.new(colFvgBull, 35), size=size.tiny)

plotshape(bearFvgNew, title="New Bear FVG",
  style=shape.square, location=location.abovebar,
  color=color.new(colFvgBear, 35), size=size.tiny)

plotshape(bullSignal, title="Bull FVG Entry",
  style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.normal)

plotshape(bearSignal, title="Bear FVG Entry",
  style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.normal)

bgcolor(sqzOn ? color.new(colSqueeze, 92) : na, title="Squeeze BG")

if showConf and bullSignal
    label.new(bar_index, low - atrVal * 1.8,
      text=str.tostring(bullScore) + "/5 FVG",
      style=label.style_label_up,
      color=color.new(colBull, 10),
      textcolor=color.new(colLabelBullTxt, 0),
      size=size.small)

if showConf and bearSignal
    label.new(bar_index, high + atrVal * 1.8,
      text=str.tostring(bearScore) + "/5 FVG",
      style=label.style_label_down,
      color=color.new(colBear, 10),
      textcolor=color.new(colLabelBearTxt, 0),
      size=size.small)

plotshape(exitBullTP1 and not exitBullTP2, title="Bull TP1",
  style=shape.circle, location=location.abovebar,
  color=color.new(colBull, 20), size=size.tiny)
plotshape(exitBullTP2, title="Bull TP2",
  style=shape.labeldown, location=location.abovebar,
  color=color.new(colBullBr, 0), size=size.tiny, text="TP")
plotshape(exitBullSL or exitBullTR, title="Bull SL",
  style=shape.labeldown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.tiny, text="SL")

plotshape(exitBearTP1 and not exitBearTP2, title="Bear TP1",
  style=shape.circle, location=location.belowbar,
  color=color.new(colBear, 20), size=size.tiny)
plotshape(exitBearTP2, title="Bear TP2",
  style=shape.labelup, location=location.belowbar,
  color=color.new(colBearBr, 0), size=size.tiny, text="TP")
plotshape(exitBearSL or exitBearTR, title="Bear SL",
  style=shape.labelup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.tiny, text="SL")

plot(showExits and tradeDir ==  1 and not na(bullSL)   ? bullSL   : na,
  "Bull SL",    color=color.new(colSlLine,   20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP1)  ? bullTP1  : na,
  "Bull TP1",   color=color.new(colTpLine,   50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and not na(bullTP2)  ? bullTP2  : na,
  "Bull TP2",   color=color.new(colTpLineBr, 10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir ==  1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bull Trail", color=color.new(colTrailLine, 30), linewidth=1, style=plot.style_linebr)

plot(showExits and tradeDir == -1 and not na(bearSL)   ? bearSL   : na,
  "Bear SL",    color=color.new(colSlLine,   20), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP1)  ? bearTP1  : na,
  "Bear TP1",   color=color.new(colTpLine,   50), linewidth=1, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and not na(bearTP2)  ? bearTP2  : na,
  "Bear TP2",   color=color.new(colTpLineBr, 10), linewidth=2, style=plot.style_linebr)
plot(showExits and tradeDir == -1 and useTrail and not na(trailStop) ? trailStop : na,
  "Bear Trail", color=color.new(colTrailLine, 30), linewidth=1, style=plot.style_linebr)

bgcolor(tradeDir ==  1 ? color.new(colLongZone,  95) : na, title="Long Zone BG")
bgcolor(tradeDir == -1 ? color.new(colShortZone, 95) : na, title="Short Zone BG")

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════ DASHBOARD ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 21,
      bgcolor=color.new(colDashBg, 0),
      border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2,  frame_color=color.new(colDashFrame, 50))

if showDash and barstate.islast

    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX VOID",
      text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "FVG v1.0",
      text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── FVG STATE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    table.cell(dash, 0, 2, "BULL FVGs", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, str.tostring(activeBullFvgs) + " active",
      text_color=colBull, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "BEAR FVGs", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, str.tostring(activeBearFvgs) + " active",
      text_color=colBear, text_size=size.small, bgcolor=dbg)

    string retestTxt = bullRetest ? "▲ BULL RETEST" : bearRetest ? "▼ BEAR RETEST" : "— NONE"
    color  retestClr = bullRetest ? colBull : bearRetest ? colBear : colNeutral
    table.cell(dash, 0, 4, "RETEST", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, retestTxt, text_color=retestClr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── MARKET ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    string sessTxt = inSession ? "✓ ACTIVE" : "✗ OFF-HOURS"
    color  sessClr = inSession ? colBull : colBear
    table.cell(dash, 0, 6, "SESSION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, sessTxt, text_color=sessClr, text_size=size.small, bgcolor=dbg)

    string adxTxt = str.tostring(adxVal, "#.#") + (adxOK ? "  ✓" : "  ✗")
    table.cell(dash, 0, 7, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, adxTxt, text_color=adxOK ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "─── CONFLUENCE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 8, "", bgcolor=secBg)

    table.cell(dash, 0, 9, "L1 EMA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, emaBull ? "▲ BULL" : emaBear ? "▼ BEAR" : "— FLAT",
      text_color=emaBull ? colBull : emaBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "L2 MOMENTUM", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, sqzOn ? "⚡ SQZ" : momBull ? "▲ BULL" : momBear ? "▼ BEAR" : "— FLAT",
      text_color=sqzOn ? colSqueeze : momBull ? colBull : momBear ? colBear : colNeutral,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 11, "L3 VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, volBull ? "▲ BULL" : volBear ? "▼ BEAR" : "— NEUTRAL",
      text_color=volBull ? colBull : volBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "L4 VWAP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, vwapBull ? "▲ ABOVE" : vwapBear ? "▼ BELOW" : "— MID",
      text_color=vwapBull ? colBull : vwapBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "L5 ADX DIR", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 13, adxDirBull ? "▲ BULL" : adxDirBear ? "▼ BEAR" : "— FLAT",
      text_color=adxDirBull ? colBull : adxDirBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    string bullScoreTxt = str.tostring(bullScore) + " / 5  " + (bullScore >= minConf ? "✓" : "✗")
    string bearScoreTxt = str.tostring(bearScore) + " / 5  " + (bearScore >= minConf ? "✓" : "✗")
    table.cell(dash, 0, 14, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 14, bullScoreTxt,
      text_color=bullScore >= minConf ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 15, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 15, bearScoreTxt,
      text_color=bearScore >= minConf ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf ? color.new(colBear, 88) : dbg)

    table.cell(dash, 0, 16, "─── POSITION ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 16, "", bgcolor=secBg)

    string posTxt = tradeDir == 1 ? "▲ LONG" : tradeDir == -1 ? "▼ SHORT" : "— FLAT"
    color  posClr = tradeDir == 1 ? colBull : tradeDir == -1 ? colBear : colNeutral
    color  posBg  = tradeDir == 1 ? color.new(colBull, 88) : tradeDir == -1 ? color.new(colBear, 88) : dbg
    table.cell(dash, 0, 17, "POSITION", text_color=colTextLt, text_size=size.small, bgcolor=posBg)
    table.cell(dash, 1, 17, posTxt, text_color=posClr, text_size=size.small, bgcolor=posBg)

    string slTxt = "—"
    if tradeDir == 1 and not na(bullSL)
        slTxt := str.tostring(bullSL, format.mintick)
    else if tradeDir == -1 and not na(bearSL)
        slTxt := str.tostring(bearSL, format.mintick)
    table.cell(dash, 0, 18, "STOP LOSS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 18, slTxt,
      text_color=tradeDir == 1 ? colBear : tradeDir == -1 ? colBull : colNeutral,
      text_size=size.small, bgcolor=dbg)

    string tp1Txt = "—"
    if tradeDir == 1 and not na(bullTP1)
        tp1Txt := str.tostring(bullTP1, format.mintick)
    else if tradeDir == -1 and not na(bearTP1)
        tp1Txt := str.tostring(bearTP1, format.mintick)
    table.cell(dash, 0, 19, "TP1 / TP2", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 19, tp1Txt, text_color=colBull, text_size=size.small, bgcolor=dbg)

    string barsTxt = tradeDir != 0 ? str.tostring(barsInTrade) + " bars" : "—"
    table.cell(dash, 0, 20, "BARS IN TRADE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 20, barsTxt, text_color=colNeutral, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
// ════════════════════════════════ ALERTS ══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(bullFvgNew,
  title="New Bull FVG Formed",
  message="[AlphaX VOID] BULL FVG CREATED — Watch for retest entry.")
alertcondition(bearFvgNew,
  title="New Bear FVG Formed",
  message="[AlphaX VOID] BEAR FVG CREATED — Watch for retest entry.")
alertcondition(bullSignal,
  title="Bull FVG Retest Entry",
  message="[AlphaX VOID] LONG FVG RETEST — Confluence entry fired.")
alertcondition(bearSignal,
  title="Bear FVG Retest Entry",
  message="[AlphaX VOID] SHORT FVG RETEST — Confluence entry fired.")
alertcondition(exitBullTP1 and not exitBullTP2,
  title="Bull TP1 Hit",
  message="[AlphaX VOID] BULL TP1 HIT — Scale out 50%.")
alertcondition(exitBullTP2,
  title="Bull TP2 Hit",
  message="[AlphaX VOID] BULL TP2 HIT — Full exit.")
alertcondition(exitBullSL or exitBullTR,
  title="Bull Stop Hit",
  message="[AlphaX VOID] BULL STOPPED — SL or trail triggered.")
alertcondition(exitBearTP1 and not exitBearTP2,
  title="Bear TP1 Hit",
  message="[AlphaX VOID] BEAR TP1 HIT — Scale out 50%.")
alertcondition(exitBearTP2,
  title="Bear TP2 Hit",
  message="[AlphaX VOID] BEAR TP2 HIT — Full exit.")
alertcondition(exitBearSL or exitBearTR,
  title="Bear Stop Hit",
  message="[AlphaX VOID] BEAR STOPPED — SL or trail triggered.")
````
