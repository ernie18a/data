# [ A L P H A X ] FORTRESS - Supply & Demand Zone Engine

- url: https://www.tradingview.com/script/KwDR1mrj-A-L-P-H-A-X-FORTRESS-Supply-Demand-Zone-Engine/
- type: indicator
- pine_id: PUB;0e6ba1e941154ce29da7b884d2b3b8f6
- version: 1.0

## Description

[b]AlphaX FORTRESS — Supply & Demand Zone Engine with Zone Grading, Session VWAP Confluence, Liquidity Sweep Signals, HTF Zone Overlay & Live Backtest Statistics[/b]

AlphaX FORTRESS is a professional-grade supply and demand system built around an institutional zone detection engine that identifies, grades, and tracks every significant supply and demand zone on the chart — then fires precision entry signals only when price returns to those zones with genuine rejection confirmation, multi-layer filter alignment, and a qualifying zone grade. Where most supply and demand indicators simply draw boxes and leave the trader to decide what to do, FORTRESS integrates a five-factor zone grading algorithm (A+ through C), session VWAP confluence scoring, higher timeframe zone overlay, liquidity sweep detection, a full suite of entry quality filters, and a live on-chart backtest statistics tracker that counts wins, losses, and win rate in real time directly from the chart's history. Every signal is supported by zone grade verification, trend alignment, ADX confirmation, volume delta pressure, premium/discount positioning, and rejection wick quality — producing a complete, self-contained supply and demand trading system. Designed for active traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏛 [b]Supply & Demand — The Institutional Framework[/b]

Supply and demand zones are the foundational building blocks of institutional price delivery. Unlike horizontal support and resistance drawn from price memory, genuine supply and demand zones are identified from the [b]origin of explosive moves[/b] — the exact price range where institutions accumulated or distributed their positions before driving price aggressively in one direction.

[b]Demand Zone:[/b] Formed when price makes an explosive bullish move away from a base. The base — one or more low-momentum candles directly preceding the explosive candle — represents the range where institutional buyers accumulated their full position. When price returns to this zone, unfilled buy orders are waiting. The most reliable demand zone retests produce sharp, rejection-candle bounces from within the zone.

[b]Supply Zone:[/b] The mirror image. An explosive bearish move preceded by a base of low-momentum candles. Institutions distributed their position in the base before driving price aggressively lower. On return, unfilled sell orders produce sharp rejection moves downward from within the zone.

[b]Why FORTRESS detects zones differently from most indicators:[/b] Most zone detectors use a simple pivot or pattern check. FORTRESS requires [b]three simultaneous conditions[/b] for a zone to qualify — the departure candle must be explosive (ATR-scaled range), the body must represent a minimum proportion of the total range (body quality filter), and volume must confirm when enabled. Only zones formed by genuine institutional displacement are registered.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]Zone Detection Engine — Quality Filters[/b]

Every zone formed by FORTRESS passes three mandatory quality gates before being registered:

[b]Explosive Move Filter:[/b]
The departure candle (the candle that leaves the base and drives price) must have a total range exceeding the ATR by a configurable multiplier (default: 1.2×). This filters out zones formed by slow, grinding moves — only impulsive, institutionally driven departures qualify. Smaller ATR multipliers produce more zones; larger values produce fewer, higher-quality zones.

[b]Body Quality Filter:[/b]
The departure candle's body must represent at least a configurable percentage of its total range (default: 55%). A small body in a large-range candle indicates indecision — the candle moved far but closed near its midpoint, suggesting weak directional conviction. A large body relative to range confirms genuine one-directional pressure on the departure move.

[b]Volume Confirmation (optional):[/b]
When enabled, the departure candle's volume must exceed the average volume (configurable period, default: 20 bars) by a minimum multiplier (default: 1.1×). High-volume departures carry more institutional weight than same-range moves on average volume. The volume filter is off by default — this allows the system to work effectively on instruments where volume data is unreliable (forex spot, crypto perpetuals) while providing an additional quality gate when reliable volume is available.

[b]Base Detection:[/b]
The base candles immediately preceding the explosive departure are automatically detected — up to the configurable maximum (default: 2 candles). Base candles must have a body smaller than 0.5× ATR and must not themselves be explosive. The full base range is incorporated into the zone boundaries, accurately reflecting the complete accumulation or distribution range rather than just the departure candle alone.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏅 [b]Zone Grading System — A+ Through C[/b]

Not all supply and demand zones are equal. A zone formed on massive volume with VWAP confluence during a premium price area carries fundamentally more institutional weight than the same pattern on average volume in a random price area. FORTRESS quantifies this difference with a [b]five-factor algorithmic grading system[/b] that assigns every zone a grade of A+, A, B, or C at the moment of formation.

[b]Grading factors and their weights:[/b]
[list]
[*][b]Move Strength (up to 30 points)[/b] — the ratio of the departure candle's range to ATR, capped at 30 points. Stronger, more explosive departures score higher. A 3× ATR departure scores maximum; a 1.2× departure (the minimum threshold) scores proportionally lower
[*][b]Volume Ratio (up to 20 points)[/b] — when volume confirmation is enabled, the ratio of departure volume to average volume, capped at 20 points. When volume confirmation is off, a flat 10 points is awarded to maintain grade comparability across instruments. High-volume departures receive the full bonus
[*][b]VWAP Confluence (20 points)[/b] — full 20 points awarded when the session VWAP is within a configurable ATR tolerance of the zone boundaries at the time of formation. A zone that forms directly at the institutional session reference level carries significantly more weight than a zone formed far from VWAP. This is the VWAP Boosts Grade feature
[*][b]HTF Zone Match (20 points)[/b] — full 20 points when the zone overlaps with an active higher timeframe supply or demand zone. Confluence between the current timeframe zone and the HTF zone indicates institutional activity at multiple timeframe levels simultaneously — the strongest possible zone quality condition
[*][b]PD Zone Match (15 points)[/b] — awarded when the zone forms in the institutionally correct price area: supply zones in premium (above dealing range equilibrium) and demand zones in discount (below equilibrium). A supply zone in premium and a demand zone in discount are positioned where institutions naturally distribute and accumulate respectively
[*][b]Base bonus (5 points)[/b] — a flat quality bonus applied to all qualifying zones
[/list]

[b]Grade thresholds:[/b]
[list]
[*][b]A+ (80+ points)[/b] — elite institutional zone. All or most factors aligned. Maximum conviction
[*][b]A (65–79 points)[/b] — strong zone with multiple confirming factors. High quality
[*][b]B (50–64 points)[/b] — solid zone with partial confirmation. Standard quality
[*][b]C (below 50 points)[/b] — low-quality zone. Formed with minimal supporting factors
[/list]

The grade badge is displayed directly on the zone box on the chart. The minimum grade filter (default: B) blocks signals from C-grade zones entirely — preventing entries at the lowest-quality institutional levels.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 [b]Session VWAP Confluence[/b]

The session VWAP is plotted as a continuous purple line and serves two distinct roles in FORTRESS.

[b]Visual reference:[/b] The VWAP line and optional ±1σ bands provide the institutional session fair value reference directly on the price chart. Optional band display shows the first standard deviation envelope around VWAP.

[b]Grade booster:[/b] When VWAP Boosts Grade is enabled (default: on), every zone that forms within ATR tolerance of the session VWAP receives 20 additional grade points — frequently elevating a B-grade zone to A or A+ when VWAP proximity confirms institutional positioning at that level.

[b]Why VWAP at the zone matters:[/b] The session VWAP is the single most widely watched intraday reference level by institutional desks, algorithms, and market makers. When a supply or demand zone forms directly at the VWAP, it means the institutional activity that created the zone coincided with the session's fairest price level — the most contested and significant price in the session. Retests of these zones carry the highest probability of generating a sharp institutional response.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 [b]HTF Zone Overlay[/b]

FORTRESS pulls supply and demand zones from a configurable higher timeframe (default: 60-minute) and overlays them on the current chart as purple dashed boxes.

[b]What HTF zones represent:[/b] A supply or demand zone on H1 was created by a significantly larger impulsive move than anything visible on M5 or M1. These zones represent institutional positioning decisions made on a multi-hour timeframe — they carry far more weight than same-pattern zones on the current timeframe. When a current timeframe demand zone overlaps with an active H1 demand zone, two independent timeframes of institutional evidence are concentrated at the same price level.

[b]Zone matching in the grader:[/b] When a newly formed current timeframe zone overlaps with an active HTF zone of the same type, it receives the full 20-point HTF Match bonus in the grading system — frequently pushing the zone from B to A or A+ grade. The label also appends ·HTF to confirm the match.

[b]HTF zone lifecycle:[/b] HTF zones are maintained in real time. When price closes above an HTF supply zone or below an HTF demand zone, the zone is deleted automatically — mitigated zones are no longer relevant and are removed to keep the chart clean.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💧 [b]Liquidity Sweep Signal Mode[/b]

In addition to standard zone rejection signals, FORTRESS detects a powerful second entry type: the [b]liquidity sweep</b> — where price wicks through a zone's boundary to grab stop orders before reclaiming back inside.

[b]Demand sweep (bull):[/b] Price wicks below the demand zone bottom by at least the minimum sweep depth (default: 0.15× ATR), then closes back above the zone bottom. Retail stops placed just below the demand zone have been triggered — institutions used that liquidity to accumulate. The reclaim close is the entry signal.

[b]Supply sweep (bear):[/b] Price wicks above the supply zone top by at least the minimum sweep depth, then closes back below the zone top. Buy stops above supply have been triggered; the close back below is the entry.

[b]Why sweeps are powerful:[/b] A standard zone rejection is a clean, textbook entry. A zone sweep adds an additional dimension — institutions have actively manufactured a liquidity event at the zone boundary, triggered counterparty stops to fill their own orders, and then reversed. This sequence is a clear signature of institutional stop hunting followed by directional commitment. Sweep signals are marked with an orange circle rather than a triangle to distinguish them visually from standard rejections.

[b]Stop placement for sweeps:[/b] The SL for sweep entries is placed at the wick extreme (the sweep low for bull sweeps, the sweep high for bear sweeps) plus a small ATR buffer — anchored to the actual manipulation point rather than the zone boundary.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]Signal Entry Logic — Multi-Layer Filtering[/b]

A FORTRESS signal fires when a zone touch is detected with candle rejection and all configured filters pass. The full filter stack applied to every potential entry:

[b]Zone touch verification:[/b]
The current bar's low must reach within the demand zone (for longs) or the current bar's high must reach within the supply zone (for shorts). Touch detection includes a small ATR tolerance (0.05×) to account for minor overshoot or spread differences.

[b]Rejection candle confirmation:[/b]
The bar must close in the correct direction — bullish close (close above open) for demand entries, bearish close for supply entries. Additionally, the rejection wick must meet the minimum wick percentage requirement (default: 50% of bar range). A bar touching a zone with a tiny lower wick but a large body is a weak rejection — the minimum wick filter ensures the zone produced a genuine, visible rejection impulse.

[b]Filter stack (all must pass):[/b]
[list]
[*][b]Trend EMA[/b] — price must be above the trend EMA (default: 50-period) for demand longs, below for supply shorts. Prevents counter-trend entries
[*][b]ADX minimum[/b] — market must be trending above the configured ADX threshold (default: 18). Blocks zone entries in choppy, ranging conditions
[*][b]Volume Delta[/b] — estimated directional volume pressure must agree with the signal direction. Bull volume dominance for longs, bear for shorts
[*][b]PD Zone requirement[/b] — price must be in discount for demand entries (below dealing range equilibrium) and in premium for supply entries (above equilibrium)
[*][b]Zone grade minimum[/b] — only zones at or above the configured minimum grade (default: B) can trigger signals
[*][b]Fresh zone filter[/b] — when enabled, only zones that have not been previously tested can trigger signals. A zone that has already been retested once carries less institutional fresh-order weight
[*][b]One signal per zone[/b] — when enabled, each zone can only generate one signal regardless of how many valid touches occur. Prevents repeated entries at the same level
[*][b]Signal cooldown[/b] — minimum bars between any two signals (default: 5). Prevents signal clustering during complex multi-touch zone reactions
[*][b]Session filter[/b] — when enabled, restricts all signals to the configured active hours window
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Zone Mitigation & Lifecycle Management[/b]

FORTRESS tracks the full lifecycle of every zone from formation through mitigation. The mitigation mode is configurable:

[b]Body Close (default):[/b] A zone is mitigated when price closes beyond its boundary — a close above a supply zone top or a close below a demand zone bottom. This is the stricter, lower-noise mode. Wicks through the zone do not count as mitigation unless they are accompanied by a body close — consistent with the idea that a wick through the zone is a sweep (an opportunity) rather than a genuine break.

[b]Wick Touch:[/b] A zone is mitigated as soon as any price touches the boundary — high above supply top, low below demand bottom. This is a more aggressive mitigation mode that removes zones faster, keeping the chart cleaner but potentially removing zones that could have produced more entries.

When a zone is mitigated under either mode, its box, label, and grade badge are immediately deleted from the chart. The system maintains a rolling maximum of the configured number of active zones per side (default: 3), automatically removing the oldest zones when the limit is exceeded.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Live Backtest Statistics Tracker[/b]

One of FORTRESS's most distinctive features is its [b]on-chart live backtest statistics system[/b]. Every signal fired is tracked in memory with its entry price, ATR at signal time, direction, and grade. On every subsequent bar, the tracker evaluates whether each open signal has hit the configured target (default: 2.0× ATR) or stop (default: 1.0× ATR).

[b]Statistics tracked and displayed on the dashboard:[/b]
[list]
[*][b]Total Signals[/b] — the total count of signals logged in the tracking window
[*][b]Wins[/b] — signals that reached the target before the stop
[*][b]Losses[/b] — signals that hit the stop before the target
[*][b]Win Rate[/b] — wins as a percentage of all closed (decided) signals. Color-coded yellow-green when at or above 50%, red when below
[*][b]Pending[/b] — signals still open — neither target nor stop hit yet. Shown in orange
[/list]

[b]What this tells you:[/b] The win rate displayed is not a theoretical backtest result — it is computed directly from the current chart's historical signals using the exact filter configuration currently active. Change the zone grade minimum and the win rate updates. Enable the ADX filter and it updates. This gives you immediate, live feedback on how your configuration is performing on the current instrument and timeframe without leaving the chart.

[b]Important note on interpretation:[/b] The statistics reflect signals fired at the current settings on the current chart's visible history. They are not forward-tested results and do not account for slippage, spread, or live execution. They serve as a real-time tuning tool — not a performance guarantee.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The real-time dashboard displays the complete internal state across four sections.

[b]ZONES[/b]
[list]
[*][b]Supply[/b] — count of currently active, unmitigated supply zones on the chart
[*][b]Demand[/b] — count of currently active, unmitigated demand zones on the chart
[/list]

[b]FILTERS[/b]
[list]
[*][b]Trend[/b] — current EMA trend state: ▲ BULL, ▼ BEAR, or —
[*][b]PD Zone[/b] — current premium/discount position: ◧ DISCOUNT, ◧ PREMIUM, or — EQ
[*][b]ADX[/b] — live ADX value with ✓ or ✗ pass/fail indicator
[*][b]Vol Delta[/b] — current volume delta direction: ▲ BULL, ▼ BEAR, or —
[/list]

[b]STATS[/b]
[list]
[*][b]Signals[/b] — total signals tracked in the current window
[*][b]Wins[/b] — confirmed target-hit signals
[*][b]Losses[/b] — confirmed stop-hit signals
[*][b]Win Rate[/b] — live win percentage across all closed signals, color-coded
[*][b]Pending[/b] — signals awaiting outcome
[*][b]Min Grade[/b] — the currently configured minimum zone grade filter
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Demand Zone Boxes (yellow-green)[/b] — semi-transparent yellow-green filled boxes with solid yellow-green borders. Extend right until mitigated
[*][b]Supply Zone Boxes (red)[/b] — semi-transparent red filled boxes with solid red borders. Extend right until mitigated
[*][b]DEMAND / SUPPLY Labels[/b] — appear at zone formation with ·VWAP and ·HTF suffixes when those confluences are present
[*][b]Grade Badges (A+ / A / B / C)[/b] — small labels at the zone's left edge showing the computed quality grade. Color-coded: A+ bright yellow-green, A yellow-green, B orange, C gray
[*][b]HTF Zone Boxes (purple dashed)[/b] — higher timeframe supply and demand zones overlaid from the configured HTF. Automatically deleted when mitigated
[*][b]Session VWAP Line (purple)[/b] — continuous VWAP anchored to each session's first bar
[*][b]VWAP Bands (purple, optional)[/b] — ±1σ envelope around the session VWAP
[*][b]Equilibrium Line (purple dotted)[/b] — the 50% midpoint of the dealing range
[*][b]Trend EMA (optional gray line)[/b] — the trend filter EMA plotted when Show EMA is enabled
[*][b]▲ Triangle (below bar, yellow-green)[/b] — standard demand rejection long signal
[*][b]▼ Triangle (above bar, red)[/b] — standard supply rejection short signal
[*][b]● Circle (below bar, orange)[/b] — liquidity sweep long signal at demand zone
[*][b]● Circle (above bar, orange)[/b] — liquidity sweep short signal at supply zone
[*][b]SL Guide (red dotted circles)[/b] — stop loss reference level on signal bars
[*][b]TP Guide (yellow-green dotted circles)[/b] — take profit reference level on signal bars
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX FORTRESS — Step by Step[/b]

[b]Step 1 — Assess the Zone Landscape[/b]
[list]
[*]Check the dashboard: how many supply and demand zones are active? Multiple demand zones stacked in the same price area indicate a strong institutional accumulation cluster — a high-priority retest target
[*]Identify the highest-grade zones on the chart. An A+ demand zone with ·VWAP ·HTF in the label is the highest-conviction level FORTRESS can display. Mark these as priority levels
[*]Note the equilibrium line — are you in discount (favorable for longs) or premium (favorable for shorts)?
[/list]

[b]Step 2 — Confirm the Filter Environment[/b]
[list]
[*]Check the dashboard: Trend ▲ BULL, PD Zone ◧ DISCOUNT, ADX ✓, Vol Delta ▲ BULL — all four green simultaneously is the ideal filter state for long entries
[*]If any critical filter is failing, reduce position size on signals or skip the setup entirely
[*]Watch the VWAP line — is it near the zone you are watching? VWAP proximity at the zone level confirms the highest-grade setups
[/list]

[b]Step 3 — Enter on the Signal[/b]
[list]
[*]A ▲ triangle below the bar is a confirmed demand rejection — all quality and filter conditions met. Enter on the close or next bar open
[*]An orange ● circle below the bar is a sweep long — the zone was violated, stops triggered, and price reclaimed. Enter on the close. Place the stop at the wick extreme
[*]Both signal types display SL and TP guide levels (dotted circles) when Show SL / TP on Signal is enabled
[/list]

[b]Step 4 — Monitor with the Stats Dashboard[/b]
[list]
[*]Watch the Win Rate row on the dashboard. If the current configuration is producing a win rate below 50% on this instrument and timeframe, consider tightening the filters — raise the minimum grade, increase the ADX threshold, or enable the volume filter
[*]The Pending count tells you how many trades are currently open and unresolved — useful for position sizing decisions
[*]If Losses are rising without corresponding Wins, check whether the market has entered a choppy regime (ADX dropping) and consider pausing trading until ADX recovers
[/list]

[b]Step 5 — Zone Management and Exit[/b]
[list]
[*]When price reaches the TP guide level, take partial or full profit
[*]If price closes through the zone boundary opposite to your entry (body close mitigation), the zone is invalidated — this is also your stop signal if not already stopped out
[*]Watch for the zone to be deleted from the chart — when the box disappears, the zone has been mitigated and the trade thesis is over
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]ADX ✗ on the dashboard[/b] — the market is ranging. Supply and demand zones in range conditions are frequently tested and broken repeatedly without producing clean continuation moves. The ADX filter blocks signals in these conditions automatically
[*][b]All active zones are grade C[/b] — no high-quality institutional levels are present. The zones on the chart were formed by weak, low-displacement moves and are unlikely to produce sharp institutional responses on retest
[*][b]Win Rate is below 40% on the live stats tracker[/b] — the current configuration is underperforming on this instrument and timeframe. Tighten filters or review whether the instrument is suitable for zone-based trading at this time
[*][b]Zones are being mitigated rapidly before retesting[/b] — fast, impulsive markets break through zones without retesting them. In this environment, wait for a new zone to form in the direction of the impulse rather than trying to catch retests of quickly broken levels
[*][b]PD Zone shows — EQ[/b] — price is at the dealing range midpoint. Entries from equilibrium carry the worst risk/reward — the institutional advantage of buying in deep discount or selling in deep premium is absent
[*][b]Vol Delta opposes the signal direction[/b] — institutional volume pressure is working against the zone entry. Even if all other conditions pass, a demand zone long with bearish volume delta means selling pressure is still dominant — the zone may not hold
[*][b]No HTF zones visible[/b] and current timeframe zones are grading mostly B and C — the institutional context on the higher timeframe is not confirming the current timeframe levels. Wait for HTF supply or demand to align before entering aggressively
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🏛 Institutional supply and demand zone detection — explosive move filter, body quality filter, and optional volume confirmation identify only genuine displacement zones
[*]📦 Automatic base detection — incorporates up to the configured maximum of low-momentum candles preceding the explosive departure into the zone boundaries
[*]🏅 Five-factor algorithmic zone grading — Move Strength, Volume Ratio, VWAP Confluence, HTF Match, and PD Zone together produce an A+/A/B/C grade for every zone at formation
[*]🌐 Session VWAP integration — plotted live with optional bands, boosts zone grades when VWAP is within tolerance of the zone, and confirmed in zone labels
[*]📡 Higher timeframe zone overlay — pulls supply and demand zones from a configurable HTF and overlays them as purple dashed boxes. HTF-matching zones receive maximum grade bonus
[*]💧 Liquidity sweep detection — identifies stop-hunt sequences where price wicks through a zone boundary and reclaims, marking these with distinct orange circle signals
[*]🧠 Multi-layer filter stack — Trend EMA, ADX, Volume Delta, PD Zone, Zone Grade, Fresh Zone, One-Shot, Cooldown, and Session filters all independently configurable
[*]⚖ Premium/Discount zone requirement — enforces institutionally correct entry positioning using a dynamic equilibrium across the dealing range
[*]📊 Live backtest statistics tracker — tracks every signal's win/loss outcome in real time on the chart, displaying signal count, wins, losses, win rate, and pending count on the dashboard
[*]🔀 Two zone mitigation modes — Body Close (stricter, lower noise) and Wick Touch (more aggressive zone clearance)
[*]📝 Zone labels with confluence indicators — DEMAND / SUPPLY labels append ·VWAP and ·HTF when those confluences are present at formation
[*]🏷 Grade badges — A+/A/B/C badges displayed directly on each zone box with color-coded visual hierarchy
[*]🎯 SL and TP guide levels — dotted circle plots at the stop and target levels on every signal bar
[*]📊 16-row live dashboard — Zones, Filters, and Stats sections updated in real time
[*]🔔 6 alert conditions — demand long, supply short, sweep long, sweep short, new demand zone formation, new supply zone formation
[*]🎨 Fully cohesive dual-tone color system — yellow-green for all demand/bullish elements, red for supply/bearish, orange for sweeps and pending stats, purple for VWAP/HTF/equilibrium
[*]⚙ Fully configurable — all zone detection thresholds, grading weights, filter settings, mitigation mode, backtest parameters, display options, and colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Zone Detection[/b]
[list]
[*]Max Base Candles — maximum number of low-momentum base candles to incorporate into zone boundaries (default: 2)
[*]Move Strength (ATR x) — minimum departure candle range as a multiple of ATR (default: 1.2)
[*]ATR Length — lookback for ATR calculation (default: 14)
[*]Volume Multiplier — minimum volume relative to average when volume confirmation is enabled (default: 1.1)
[*]Volume Avg Length — lookback for volume average (default: 20)
[*]Min Body % of Range — minimum body size as a fraction of the departure candle's total range (default: 0.55)
[*]Require Volume Confirmation — when on, departure candle must exceed the volume average by the configured multiplier (default: off)
[/list]

[b]Signal Filters[/b]
[list]
[*]Fresh Zones Only — when on, only zones that have not been previously touched can trigger signals
[*]One Signal Per Zone — when on, each zone produces a maximum of one signal regardless of subsequent valid touches
[*]Min Rejection Wick % — minimum lower/upper wick as a fraction of bar range for rejection confirmation (default: 0.50)
[*]Cooldown Bars — minimum bars between consecutive signals (default: 5)
[*]Chart EMA Trend Filter — when on, requires price to be on the correct side of the trend EMA
[*]Trend EMA Length — EMA period for the trend filter (default: 50)
[*]Min Zone Grade — minimum grade required for a zone to generate signals. A+ / A / B / C (default: B)
[*]ADX Filter — toggle the ADX trend strength gate
[*]ADX Length / ADX Minimum — ADX calculation and threshold parameters (defaults: 14 / 18)
[*]Volume Delta Filter — toggle the directional volume pressure requirement
[*]Volume Delta Length — smoothing length for volume delta calculation (default: 14)
[*]Require PD Zone — when on, longs require discount positioning, shorts require premium
[*]Dealing Range Length — bars used for the equilibrium midpoint calculation (default: 50)
[/list]

[b]Liquidity Sweep[/b]
[list]
[*]Enable Sweep Signals — toggle the sweep entry signal mode
[*]Min Sweep Depth (ATR x) — minimum wick extension beyond the zone boundary to qualify as a sweep (default: 0.15)
[/list]

[b]HTF Zones[/b]
[list]
[*]Show HTF Zones — toggle the higher timeframe zone overlay
[*]HTF Resolution — the timeframe to pull HTF zones from (default: 60-minute)
[/list]

[b]VWAP Confluence[/b]
[list]
[*]Show Session VWAP — toggle the VWAP line on the chart
[*]VWAP Boosts Grade — when on, zones within VWAP tolerance receive 20 additional grade points
[*]VWAP Tolerance (ATR x) — maximum distance from VWAP to qualify for the grade boost (default: 0.5)
[*]Show VWAP Bands — toggle ±1σ band plots around the session VWAP
[/list]

[b]Backtest Stats[/b]
[list]
[*]Track Signal Stats — toggle the live win/loss tracking system
[*]Target (ATR x) — take-profit distance for stat tracking purposes (default: 2.0)
[*]Stop (ATR x) — stop-loss distance for stat tracking purposes (default: 1.0)
[*]Max Signals Tracked — rolling window size for the statistics tracker (default: 50)
[/list]

[b]Display[/b]
[list]
[*]Max Active Zones / Side — maximum supply zones and demand zones maintained simultaneously (default: 3 per side)
[*]Mitigation — Body Close or Wick Touch zone invalidation mode
[*]Extend Zones Right — when on, zone boxes extend indefinitely to the right until mitigated
[*]Show Zone Labels — toggle SUPPLY/DEMAND text labels on zones
[*]Show Grade Badge — toggle A+/A/B/C grade badges on zone boxes
[*]Show Stats Dashboard — toggle the full dashboard panel
[*]Plot Trend EMA — toggle the trend EMA line on the chart
[*]Show SL / TP on Signal — toggle stop and target guide circle plots on signal bars
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Session[/b]
[list]
[*]Buy / Sell Signals — master toggle for all entry signals
[*]Session Filter — toggle the active hours restriction
[*]Active Session — configurable session window string
[/list]

[b]Colors[/b]
[list]
[*]Demand / Bull / Bull Bright — yellow-green family for all demand zones, signals, and labels
[*]Supply / Bear / Bear Bright — red family for all supply zones, signals, and labels
[*]HTF Zone — purple for higher timeframe zone overlays
[*]VWAP / Equilibrium — purple for VWAP and equilibrium lines
[*]SL Guide / TP Guide — stop and target circle colors
[*]Sweep Signal — orange for liquidity sweep entry circles
[*]Dash Text / Neutral / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (6 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Fortress Demand Long — standard demand zone rejection long signal. All quality and filter conditions met
[*]Fortress Supply Short — standard supply zone rejection short signal
[*]Fortress Sweep Long — liquidity sweep and reclaim at demand zone. Sweep entry confirmed
[*]Fortress Sweep Short — liquidity sweep and reclaim at supply zone
[/list]

[b]Zone Formation Alerts[/b]
[list]
[*]New Demand Zone — a qualifying demand zone has been detected and added to the chart
[*]New Supply Zone — a qualifying supply zone has been detected and added to the chart
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M1–M15[/b]:
[list]
[*]Move Strength at 1.2× ATR — sensitive enough to catch meaningful departures on fast-moving intraday instruments
[*]Min Grade at B — filters out the lowest-quality zones while allowing solid B-grade setups to signal
[*]Fresh Zones Only on — fresh, untested zones carry the most unfilled institutional orders
[*]HTF at 60-minute — provides meaningful confluence context for intraday M1–M15 trading
[*]Volume Confirmation off — reliable for futures and equities, unreliable for spot forex and crypto perpetuals
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]Higher timeframes (H1, H4)[/b] — increase Move Strength to 1.5–2.0× ATR, set HTF to Daily or Weekly, raise Min Grade to A, increase Dealing Range Length to 100–200
[*][b]Crypto (BTC, ETH)[/b] — enable Volume Confirmation with 1.2× multiplier on exchanges with reliable volume data, increase Move Strength to 1.4–1.6, increase Min Sweep Depth to 0.25×
[*][b]Indices (NAS100, US30)[/b] — enable Session Filter to 09:30–16:00, enable Volume Confirmation, set Min Grade to A for cleaner signal quality
[*][b]More zones and signals[/b] — reduce Move Strength to 1.0, lower Min Grade to C, disable Fresh Zones Only, disable One Signal Per Zone
[*][b]Fewer, highest-quality signals only[/b] — raise Min Grade to A or A+, enable Volume Confirmation, enable HTF Zones, set VWAP Boosts Grade on. Only A+ zones with VWAP and HTF alignment will produce signals
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🏛 [b]Supply and demand traders[/b] — FORTRESS is the most complete quantitative implementation of supply and demand zone trading available in the AlphaX suite. Every concept — zone quality, freshness, grade, mitigation, sweep detection — is encoded objectively and applied consistently
[*]📊 [b]Traders who want data on their strategy[/b] — the live backtest statistics tracker provides immediate, chart-specific feedback on how the current configuration is performing without leaving the platform
[*]🥇 [b]Gold (XAUUSD) and forex traders[/b] — supply and demand zone mechanics are most consistent on highly liquid institutional instruments. Default settings are calibrated for gold and major pairs
[*]🌐 [b]Multi-timeframe traders[/b] — the HTF zone overlay and VWAP confluence create a natural two-timeframe framework within a single indicator
[*]🧠 [b]Systematic traders[/b] — every entry parameter is quantified and configurable. The grading system replaces subjective zone quality assessment with objective numerical scoring
[*]💧 [b]Stop hunt and sweep traders[/b] — the dedicated sweep signal mode is purpose-built for traders who specifically want to enter on liquidity grab and reclaim events at institutional zones
[*]⚠ [b]Traders who want to stop chasing entries[/b] — FORTRESS enforces patience by design. You wait for institutional zones to form, wait for price to return, wait for the rejection candle, and wait for all filters to confirm — discipline is built into the system architecture
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Zone detection, grading, mitigation, and signal logic all finalize on confirmed bars only
[*]The live backtest statistics use ATR-based fixed targets and stops for tracking purposes. These are not the same as any broker-level trade execution. The purpose is configuration tuning, not performance reporting
[*]Maximum 200 boxes, 200 labels, and 100 lines are rendered. On charts with long history and frequent zone formation, the oldest zones are automatically removed by TradingView's rendering limits. The Max Active Zones / Side setting provides additional control over zone count
[*]HTF zone detection uses Pine Script's request.security function with lookahead off — HTF zones are non-repainting and reflect the HTF close price at each lower timeframe bar
[*]The PD Zone equilibrium is calculated from the highest high and lowest low over the Dealing Range Length. On strongly trending instruments this level will shift progressively — it is a relative measure within the recent range, not a fixed level
[*]The session VWAP resets at each session's first bar. For 24-hour crypto instruments, the VWAP anchors to the first bar of each calendar day. Consider disabling the VWAP grade boost on instruments where session definition is ambiguous
[*]The sweep signal mode and standard zone rejection signal mode are independent. A zone that produces a sweep signal is marked as used (when One Signal Per Zone is enabled), preventing a subsequent standard rejection signal from the same zone — ensuring only one entry per zone regardless of which entry type fires first
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who believe that the strongest entries are not found by predicting where price will go — but by knowing exactly where institutions have left their orders waiting.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX — FORTRESS v1.0
// Supply / Demand + Session VWAP + Liquidity Sweep + Confluence Engine

//@version=6
indicator("[ A L P H A X ] FORTRESS", shorttitle="AlphaX FORTRESS",
  overlay=true, max_boxes_count=200, max_labels_count=200, max_lines_count=100, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

grpZ = "Zone Detection"
basePeriod = input.int(2,   "Max Base Candles",        minval=1, maxval=5,  group=grpZ)
moveMult   = input.float(1.2, "Move Strength (ATR x)", minval=0.5, step=0.1, group=grpZ)
atrLen     = input.int(14,  "ATR Length",              minval=1, group=grpZ)
volMult    = input.float(1.1, "Volume Multiplier",     minval=1.0, step=0.1, group=grpZ)
volLen     = input.int(20,  "Volume Avg Length",       minval=1, group=grpZ)
bodyPct    = input.float(0.55, "Min Body % of Range", minval=0.3, maxval=0.9, step=0.05, group=grpZ)
useVolume  = input.bool(false, "Require Volume Confirmation", group=grpZ)

grpF = "Signal Filters"
freshOnly  = input.bool(true,  "Fresh Zones Only",      group=grpF)
oneShot    = input.bool(true,  "One Signal Per Zone",   group=grpF)
minWickPct = input.float(0.5, "Min Rejection Wick %", minval=0.2, maxval=0.9, step=0.05, group=grpF)
cooldown   = input.int(5,     "Cooldown Bars",         minval=0, maxval=50, group=grpF)
useTrend   = input.bool(true,  "Chart EMA Trend Filter", group=grpF)
emaLen     = input.int(50,    "Trend EMA Length",      minval=5, group=grpF)
minGrade   = input.string("B", "Min Zone Grade", options=["A+", "A", "B", "C"], group=grpF)
useADX     = input.bool(true,  "ADX Filter",            group=grpF)
adxLen     = input.int(14,    "ADX Length",            minval=7, maxval=30, group=grpF)
adxMin     = input.float(18,  "ADX Minimum",           minval=10, maxval=40, group=grpF)
useVolDelta = input.bool(true, "Volume Delta Filter",  group=grpF)
volDeltaLen = input.int(14,   "Volume Delta Length",   minval=5, maxval=50, group=grpF)
requirePd  = input.bool(true,  "Require PD Zone",       group=grpF,
  tooltip="Longs in discount. Shorts in premium.")
pdLen      = input.int(50,    "Dealing Range Length",  minval=20, maxval=200, group=grpF)

grpSweep = "Liquidity Sweep"
sweepOn  = input.bool(true, "Enable Sweep Signals", group=grpSweep,
  tooltip="Zone wicked through + body close reclaim = stop hunt entry.")
sweepAtr = input.float(0.15, "Min Sweep Depth (ATR x)", minval=0.05, maxval=1.0, step=0.05, group=grpSweep)

grpMTF = "HTF Zones"
mtfOn  = input.bool(true, "Show HTF Zones", group=grpMTF)
htfRes = input.timeframe("60", "HTF Resolution", group=grpMTF)

grpVwap = "VWAP Confluence"
vwapOn   = input.bool(true,  "Show Session VWAP", group=grpVwap)
vwapConf = input.bool(true,  "VWAP Boosts Grade", group=grpVwap)
vwapTol  = input.float(0.5,  "VWAP Tolerance (ATR x)", minval=0.1, maxval=2.0, step=0.1, group=grpVwap)
vwapBands = input.bool(false, "Show VWAP Bands", group=grpVwap)

grpBT = "Backtest Stats"
btOn      = input.bool(true,  "Track Signal Stats", group=grpBT)
targetATR = input.float(2.0,  "Target (ATR x)",   minval=0.5, step=0.1, group=grpBT)
stopATR   = input.float(1.0,  "Stop (ATR x)",     minval=0.3, step=0.1, group=grpBT)
maxTrack  = input.int(50,     "Max Signals Tracked", minval=10, maxval=200, group=grpBT)

grpD = "Display"
maxZones  = input.int(3, "Max Active Zones / Side", minval=1, maxval=8, group=grpD)
mitMode   = input.string("Body Close", "Mitigation", options=["Wick Touch", "Body Close"], group=grpD)
extendRt  = input.bool(true, "Extend Zones Right", group=grpD)
showLbl   = input.bool(true, "Show Zone Labels", group=grpD)
showGrade = input.bool(true, "Show Grade Badge", group=grpD)
showStats = input.bool(true, "Show Stats Dashboard", group=grpD)
showEma   = input.bool(false, "Plot Trend EMA", group=grpD)
showExits = input.bool(true, "Show SL / TP on Signal", group=grpD)
dashPos   = input.string("Bottom Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpD)

grpSig = "Session"
sigOn  = input.bool(true,  "Buy / Sell Signals", group=grpSig)
sessOn = input.bool(false, "Session Filter", group=grpSig)
sess   = input.session("0700-2000", "Active Session", group=grpSig)

grpColors = "Colors"
colBull      = input.color(#c8e624, "Demand / Bull",      group=grpColors)
colBullBr    = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear      = input.color(#ff1744, "Supply / Bear",      group=grpColors)
colBearBr    = input.color(#ff5252, "Bear Bright",        group=grpColors)
colHtf       = input.color(#8b6fd0, "HTF Zone",           group=grpColors)
colVwap      = input.color(#8b6fd0, "VWAP",               group=grpColors)
colEq        = input.color(#8b6fd0, "Equilibrium",        group=grpColors)
colSl        = input.color(#ff1744, "SL Guide",           group=grpColors)
colTp        = input.color(#c8e624, "TP Guide",           group=grpColors)
colSweep     = input.color(#ff9800, "Sweep Signal",       group=grpColors)
colTextLt    = input.color(#cccccc, "Dash Text",         group=grpColors)
colNeutral   = input.color(#555555, "Neutral",           group=grpColors)
colDashBg    = input.color(#1a1a1a, "Dash BG",           group=grpColors)
colDashHdr   = input.color(#111111, "Dash Header BG",    group=grpColors)
colDashSec   = input.color(#222222, "Dash Section BG",   group=grpColors)
colDashFrame = input.color(#c8e624, "Dash Frame",        group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right

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

f_gradeRank(g) =>
    g == "A+" ? 4 : g == "A" ? 3 : g == "B" ? 2 : 1

f_badgeColor(g) =>
    g == "A+" ? color.new(colBullBr, 0) : g == "A" ? color.new(colBull, 10) : g == "B" ? color.new(colSweep, 20) : color.new(colNeutral, 40)

const color COL_LABEL_DARK = #0d0d0d

// ═══════════════════════════════════════════════════════════════════════════════
// CORE
// ═══════════════════════════════════════════════════════════════════════════════

atr    = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
ema    = ta.ema(close, emaLen)
rng    = high - low
body   = math.abs(close - open)
upWick = high - math.max(close, open)
dnWick = math.min(close, open) - low
isBull = close > open
isBear = close < open

[vwapVal, vwapU1, vwapL1] = ta.vwap(hlc3, session.isfirstbar, 1.0)
vwapDev = vwapU1 - vwapVal
vwapUpper = vwapVal + vwapDev
vwapLower = vwapVal - vwapDev

volOK     = not useVolume or volume > volAvg * volMult
explosive = rng > atr * moveMult and volOK and body > rng * bodyPct
inSess    = not sessOn or not na(time(timeframe.period, sess))
trendUp   = not useTrend or close > ema
trendDn   = not useTrend or close < ema
adxVal    = f_adx(adxLen)
adxOK     = not useADX or adxVal >= adxMin

candleRange = high - low
bullVolEst  = candleRange != 0 ? volume * (close - low) / candleRange : volume * 0.5
bearVolEst  = volume - bullVolEst
volDelta    = ta.ema(bullVolEst, volDeltaLen) - ta.ema(bearVolEst, volDeltaLen)
volBull     = volDelta > 0
volBear     = volDelta < 0

rangeHigh = ta.highest(high, pdLen)
rangeLow  = ta.lowest(low, pdLen)
eqLevel   = (rangeHigh + rangeLow) / 2.0
inDiscount = close < eqLevel
inPremium  = close > eqLevel
pdLongOK   = not requirePd or inDiscount
pdShortOK  = not requirePd or inPremium

detectSupply = explosive[1] and isBear[1]
detectDemand = explosive[1] and isBull[1]

minRank = f_gradeRank(minGrade)

f_grade(float moveRatio, float volRatio, bool vwapInZone, bool htfMatch, bool pdMatch) =>
    float s = 0.0
    s += math.min(moveRatio * 18.0, 30.0)
    s += useVolume ? math.min(volRatio * 13.0, 20.0) : 10.0
    s += vwapInZone ? 20.0 : 0.0
    s += htfMatch ? 20.0 : 0.0
    s += pdMatch ? 15.0 : 0.0
    s += 5.0
    string g = s >= 80.0 ? "A+" : s >= 65.0 ? "A" : s >= 50.0 ? "B" : "C"
    [g, s]

f_vwapInZone(float zTop, float zBot) =>
    vwapConf and vwapVal >= zBot - atr * vwapTol and vwapVal <= zTop + atr * vwapTol

// ═══════════════════════════════════════════════════════════════════════════════
// HTF ZONE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

f_htfDetect() =>
    float a = ta.atr(atrLen)
    float r = high - low
    float bd = math.abs(close - open)
    float va = ta.sma(volume, volLen)
    bool vo = not useVolume or volume > va * volMult
    bool ex = r > a * moveMult and vo and bd > r * bodyPct
    bool bu = close > open
    bool be = close < open
    bool ds = ex[1] and be[1]
    bool dd = ex[1] and bu[1]
    float sT = ds ? high[2] : na
    float sB = ds ? math.min(low[2], open[1]) : na
    float dT = dd ? math.max(high[2], open[1]) : na
    float dB = dd ? low[2] : na
    [ds, dd, sT, sB, dT, dB]

[htfSupNew, htfDemNew, htfSupT, htfSupB, htfDemT, htfDemB] =
  request.security(syminfo.tickerid, htfRes, f_htfDetect(), barmerge.gaps_off, barmerge.lookahead_off)

var box   htfSupBox  = na
var box   htfDemBox  = na
var float htfSupTopV = na
var float htfSupBotV = na
var float htfDemTopV = na
var float htfDemBotV = na

htfFill = color.new(colHtf, 88)
htfEdge = color.new(colHtf, 35)

if mtfOn and htfSupNew and not na(htfSupT)
    if not na(htfSupBox)
        box.delete(htfSupBox)
    htfSupBox  := box.new(bar_index - 20, htfSupT, bar_index, htfSupB,
      border_color=htfEdge, bgcolor=htfFill, extend=extendRt ? extend.right : extend.none,
      border_width=1, border_style=line.style_dashed)
    htfSupTopV := htfSupT
    htfSupBotV := htfSupB

if mtfOn and htfDemNew and not na(htfDemT)
    if not na(htfDemBox)
        box.delete(htfDemBox)
    htfDemBox  := box.new(bar_index - 20, htfDemT, bar_index, htfDemB,
      border_color=htfEdge, bgcolor=htfFill, extend=extendRt ? extend.right : extend.none,
      border_width=1, border_style=line.style_dashed)
    htfDemTopV := htfDemT
    htfDemBotV := htfDemB

if mtfOn and not na(htfSupTopV) and close > htfSupTopV
    if not na(htfSupBox)
        box.delete(htfSupBox)
        htfSupBox := na
    htfSupTopV := na
    htfSupBotV := na

if mtfOn and not na(htfDemBotV) and close < htfDemBotV
    if not na(htfDemBox)
        box.delete(htfDemBox)
        htfDemBox := na
    htfDemTopV := na
    htfDemBotV := na

// ═══════════════════════════════════════════════════════════════════════════════
// ZONE STORAGE
// ═══════════════════════════════════════════════════════════════════════════════

var array<box>    supBox    = array.new<box>()
var array<label>  supLbl    = array.new<label>()
var array<label>  supBadge  = array.new<label>()
var array<float>  supTop    = array.new<float>()
var array<float>  supBot    = array.new<float>()
var array<bool>   supTested = array.new<bool>()
var array<bool>   supUsed   = array.new<bool>()
var array<string> supGrade  = array.new<string>()
var array<bool>   supSwept  = array.new<bool>()

var array<box>    demBox    = array.new<box>()
var array<label>  demLbl    = array.new<label>()
var array<label>  demBadge  = array.new<label>()
var array<float>  demTop    = array.new<float>()
var array<float>  demBot    = array.new<float>()
var array<bool>   demTested = array.new<bool>()
var array<bool>   demUsed   = array.new<bool>()
var array<string> demGrade  = array.new<string>()
var array<bool>   demSwept  = array.new<bool>()

var int lastSigBar = -9999

f_trimSupply() =>
    while array.size(supBox) > maxZones
        box.delete(array.shift(supBox))
        label.delete(array.shift(supLbl))
        label.delete(array.shift(supBadge))
        array.shift(supTop)
        array.shift(supBot)
        array.shift(supTested)
        array.shift(supUsed)
        array.shift(supGrade)
        array.shift(supSwept)

f_trimDemand() =>
    while array.size(demBox) > maxZones
        box.delete(array.shift(demBox))
        label.delete(array.shift(demLbl))
        label.delete(array.shift(demBadge))
        array.shift(demTop)
        array.shift(demBot)
        array.shift(demTested)
        array.shift(demUsed)
        array.shift(demGrade)
        array.shift(demSwept)

f_base() =>
    float bh = high[2]
    float bl = low[2]
    int off = 2
    for i = 2 to basePeriod + 1
        if math.abs(close[i] - open[i]) < atr[1] * 0.5 and not explosive[i]
            bh := math.max(bh, high[i])
            bl := math.min(bl, low[i])
            off := i
        else
            break
    [bh, bl, off]

supBg = color.new(colBear, 82)
demBg = color.new(colBull, 82)
supBd = color.new(colBear, 0)
demBd = color.new(colBull, 0)

// ═══════════════════════════════════════════════════════════════════════════════
// CREATE ZONES
// ═══════════════════════════════════════════════════════════════════════════════

if detectSupply and barstate.isconfirmed
    [bh, bl, off] = f_base()
    float zTop = bh
    float zBot = math.min(bl, open[1])
    float moveRatio = rng[1] / atr[1]
    float volRatio  = volAvg[1] > 0 ? volume[1] / volAvg[1] : 1.0
    bool vwapIn = f_vwapInZone(zTop, zBot)
    bool htfMatch = mtfOn and not na(htfSupTopV) and zTop >= htfSupBotV and zBot <= htfSupTopV
    bool pdMatch = inPremium
    [grade, _] = f_grade(moveRatio, volRatio, vwapIn, htfMatch, pdMatch)
    box bx = box.new(bar_index - off, zTop, bar_index, zBot, border_color=supBd, bgcolor=supBg,
      extend=extendRt ? extend.right : extend.none, border_width=1)
    string lblText = showLbl ? "SUPPLY" + (vwapIn ? " ·VWAP" : "") + (htfMatch ? " ·HTF" : "") : ""
    label lb = label.new(bar_index, zTop, lblText, style=label.style_label_down,
      color=showLbl ? color.new(colBear, 30) : color.new(color.white, 100), textcolor=color.white, size=size.small)
    label badge = label.new(bar_index - off, (zTop + zBot) / 2, showGrade ? grade : "",
      style=label.style_label_right, color=f_badgeColor(grade), textcolor=#0d0d0d, size=size.tiny)
    array.push(supBox, bx)
    array.push(supLbl, lb)
    array.push(supBadge, badge)
    array.push(supTop, zTop)
    array.push(supBot, zBot)
    array.push(supTested, false)
    array.push(supUsed, false)
    array.push(supGrade, grade)
    array.push(supSwept, false)
    f_trimSupply()

if detectDemand and barstate.isconfirmed
    [bh, bl, off] = f_base()
    float zTop = math.max(bh, open[1])
    float zBot = bl
    float moveRatio = rng[1] / atr[1]
    float volRatio  = volAvg[1] > 0 ? volume[1] / volAvg[1] : 1.0
    bool vwapIn = f_vwapInZone(zTop, zBot)
    bool htfMatch = mtfOn and not na(htfDemTopV) and zTop >= htfDemBotV and zBot <= htfDemTopV
    bool pdMatch = inDiscount
    [grade, _] = f_grade(moveRatio, volRatio, vwapIn, htfMatch, pdMatch)
    box bx = box.new(bar_index - off, zTop, bar_index, zBot, border_color=demBd, bgcolor=demBg,
      extend=extendRt ? extend.right : extend.none, border_width=1)
    string lblText = showLbl ? "DEMAND" + (vwapIn ? " ·VWAP" : "") + (htfMatch ? " ·HTF" : "") : ""
    label lb = label.new(bar_index, zBot, lblText, style=label.style_label_up,
      color=showLbl ? color.new(colBull, 30) : color.new(color.white, 100), textcolor=COL_LABEL_DARK, size=size.small)
    label badge = label.new(bar_index - off, (zTop + zBot) / 2, showGrade ? grade : "",
      style=label.style_label_right, color=f_badgeColor(grade), textcolor=#0d0d0d, size=size.tiny)
    array.push(demBox, bx)
    array.push(demLbl, lb)
    array.push(demBadge, badge)
    array.push(demTop, zTop)
    array.push(demBot, zBot)
    array.push(demTested, false)
    array.push(demUsed, false)
    array.push(demGrade, grade)
    array.push(demSwept, false)
    f_trimDemand()

// ═══════════════════════════════════════════════════════════════════════════════
// MITIGATION
// ═══════════════════════════════════════════════════════════════════════════════

int si = array.size(supBox) - 1
while si >= 0
    float t = array.get(supTop, si)
    bool broken = mitMode == "Body Close" ? close > t : high > t
    if broken
        box.delete(array.get(supBox, si))
        label.delete(array.get(supLbl, si))
        label.delete(array.get(supBadge, si))
        array.remove(supBox, si)
        array.remove(supLbl, si)
        array.remove(supBadge, si)
        array.remove(supTop, si)
        array.remove(supBot, si)
        array.remove(supTested, si)
        array.remove(supUsed, si)
        array.remove(supGrade, si)
        array.remove(supSwept, si)
    si -= 1

int di = array.size(demBox) - 1
while di >= 0
    float b = array.get(demBot, di)
    bool broken = mitMode == "Body Close" ? close < b : low < b
    if broken
        box.delete(array.get(demBox, di))
        label.delete(array.get(demLbl, di))
        label.delete(array.get(demBadge, di))
        array.remove(demBox, di)
        array.remove(demLbl, di)
        array.remove(demBadge, di)
        array.remove(demTop, di)
        array.remove(demBot, di)
        array.remove(demTested, di)
        array.remove(demUsed, di)
        array.remove(demGrade, di)
        array.remove(demSwept, di)
    di -= 1

// ═══════════════════════════════════════════════════════════════════════════════
// BACKTEST TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

var array<int>    sigBar    = array.new<int>()
var array<float>  sigPrice  = array.new<float>()
var array<float>  sigATR    = array.new<float>()
var array<int>    sigDir    = array.new<int>()
var array<int>    sigResult = array.new<int>()
var array<string> sigGradeA = array.new<string>()
var array<bool>   sigSweep  = array.new<bool>()

f_logSignal(int dir, string grade, bool isSweep) =>
    if btOn
        array.push(sigBar, bar_index)
        array.push(sigPrice, close)
        array.push(sigATR, atr)
        array.push(sigDir, dir)
        array.push(sigResult, 0)
        array.push(sigGradeA, grade)
        array.push(sigSweep, isSweep)
        while array.size(sigBar) > maxTrack
            array.shift(sigBar)
            array.shift(sigPrice)
            array.shift(sigATR)
            array.shift(sigDir)
            array.shift(sigResult)
            array.shift(sigGradeA)
            array.shift(sigSweep)

if btOn and barstate.isconfirmed
    int n = array.size(sigBar)
    if n > 0
        for k = 0 to n - 1
            if array.get(sigResult, k) == 0
                float entry = array.get(sigPrice, k)
                float eAtr  = array.get(sigATR, k)
                int dir     = array.get(sigDir, k)
                float tgt   = dir == 1 ? entry + eAtr * targetATR : entry - eAtr * targetATR
                float stp   = dir == 1 ? entry - eAtr * stopATR   : entry + eAtr * stopATR
                bool hitWin = dir == 1 ? high >= tgt : low <= tgt
                bool hitLoss = dir == 1 ? low <= stp : high >= stp
                if hitWin
                    array.set(sigResult, k, 1)
                else if hitLoss
                    array.set(sigResult, k, -1)

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════

bool buySig    = false
bool sellSig   = false
bool sweepBuy  = false
bool sweepSell = false
string sigGradeUsed = "C"
float sigSl = na
float sigTp = na

bool cooldownOK = bar_index - lastSigBar >= cooldown
bool wickOKLong  = rng > 0 and dnWick / rng >= minWickPct
bool wickOKShort = rng > 0 and upWick / rng >= minWickPct
bool volOKLong   = not useVolDelta or volBull
bool volOKShort  = not useVolDelta or volBear

if sigOn and inSess and barstate.isconfirmed and cooldownOK
    // Demand rejection longs
    if trendUp and adxOK and pdLongOK and volOKLong
        int dSz = array.size(demBox)
        if dSz > 0
            for idx = dSz - 1 to 0
                if not buySig and not sweepBuy
                    float zTop = array.get(demTop, idx)
                    float zBot = array.get(demBot, idx)
                    string grd = array.get(demGrade, idx)
                    bool gradeOK = f_gradeRank(grd) >= minRank
                    bool freshOK = not freshOnly or not array.get(demTested, idx)
                    bool usedOK  = not oneShot or not array.get(demUsed, idx)
                    bool touch   = low <= zTop and low >= zBot - atr * 0.05
                    bool reject  = isBull and close > zBot and wickOKLong
                    if gradeOK and freshOK and usedOK and touch and reject
                        buySig := true
                        sigGradeUsed := grd
                        sigSl := zBot - atr * stopATR
                        sigTp := close + atr * targetATR
                        array.set(demTested, idx, true)
                        array.set(demUsed, idx, true)
                    if sweepOn and not buySig and gradeOK and usedOK
                        bool swept = low < zBot - atr * sweepAtr and close > zBot
                        bool bodyMit = mitMode == "Body Close" ? close > zBot : true
                        if swept and bodyMit and not array.get(demSwept, idx)
                            sweepBuy := true
                            sigGradeUsed := grd
                            sigSl := low - atr * 0.5
                            sigTp := close + atr * targetATR
                            array.set(demSwept, idx, true)
                            array.set(demUsed, idx, true)

    // Supply rejection shorts
    if trendDn and adxOK and pdShortOK and volOKShort
        int sSz = array.size(supBox)
        if sSz > 0
            for idx = sSz - 1 to 0
                if not sellSig and not sweepSell
                    float zTop = array.get(supTop, idx)
                    float zBot = array.get(supBot, idx)
                    string grd = array.get(supGrade, idx)
                    bool gradeOK = f_gradeRank(grd) >= minRank
                    bool freshOK = not freshOnly or not array.get(supTested, idx)
                    bool usedOK  = not oneShot or not array.get(supUsed, idx)
                    bool touch   = high >= zBot and high <= zTop + atr * 0.05
                    bool reject  = isBear and close < zTop and wickOKShort
                    if gradeOK and freshOK and usedOK and touch and reject
                        sellSig := true
                        sigGradeUsed := grd
                        sigSl := zTop + atr * stopATR
                        sigTp := close - atr * targetATR
                        array.set(supTested, idx, true)
                        array.set(supUsed, idx, true)
                    if sweepOn and not sellSig and gradeOK and usedOK
                        bool swept = high > zTop + atr * sweepAtr and close < zTop
                        bool bodyMit = mitMode == "Body Close" ? close < zTop : true
                        if swept and bodyMit and not array.get(supSwept, idx)
                            sweepSell := true
                            sigGradeUsed := grd
                            sigSl := high + atr * 0.5
                            sigTp := close - atr * targetATR
                            array.set(supSwept, idx, true)
                            array.set(supUsed, idx, true)

bool longSig  = buySig or sweepBuy
bool shortSig = sellSig or sweepSell

if longSig or shortSig
    lastSigBar := bar_index
    f_logSignal(longSig ? 1 : -1, sigGradeUsed, sweepBuy or sweepSell)

// ═══════════════════════════════════════════════════════════════════════════════
// STATS AGGREGATION
// ═══════════════════════════════════════════════════════════════════════════════

int wins = 0
int losses = 0
int pending = 0
int nSig = array.size(sigResult)
if nSig > 0
    for k = 0 to nSig - 1
        int r = array.get(sigResult, k)
        wins += r == 1 ? 1 : 0
        losses += r == -1 ? 1 : 0
        pending += r == 0 ? 1 : 0
int closed = wins + losses
float winRate = closed > 0 ? 100.0 * wins / closed : na

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

plot(showEma ? ema : na, "Trend EMA", color=color.new(colNeutral, 40), linewidth=2)
plot(vwapOn ? vwapVal : na, "Session VWAP", color=color.new(colVwap, 20), linewidth=2)
plot(vwapOn and vwapBands ? vwapUpper : na, "VWAP Upper", color=color.new(colVwap, 60), linewidth=1)
plot(vwapOn and vwapBands ? vwapLower : na, "VWAP Lower", color=color.new(colVwap, 60), linewidth=1)
plot(eqLevel, "Equilibrium", color=color.new(colEq, 50), linewidth=1, style=plot.style_linebr)

plotshape(buySig, title="Demand Long", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.small)
plotshape(sellSig, title="Supply Short", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.small)
plotshape(sweepBuy, title="Sweep Long", style=shape.circle, location=location.belowbar,
  color=color.new(colSweep, 0), size=size.tiny)
plotshape(sweepSell, title="Sweep Short", style=shape.circle, location=location.abovebar,
  color=color.new(colSweep, 0), size=size.tiny)

plot(showExits and longSig ? sigSl : na, "Long SL", color=color.new(colSl, 30), style=plot.style_circles, linewidth=1)
plot(showExits and longSig ? sigTp : na, "Long TP", color=color.new(colTp, 30), style=plot.style_circles, linewidth=1)
plot(showExits and shortSig ? sigSl : na, "Short SL", color=color.new(colSl, 30), style=plot.style_circles, linewidth=1)
plot(showExits and shortSig ? sigTp : na, "Short TP", color=color.new(colTp, 30), style=plot.style_circles, linewidth=1)

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = na
if showStats
    dash := table.new(getDashPos(dashPos), 2, 16,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

if showStats and barstate.islast
    color dbg = color.new(colDashBg, 0)
    color sec = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX FORTRESS", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHdr, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "SD v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHdr, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── ZONES ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=sec)

    table.cell(dash, 0, 2, "SUPPLY", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, str.tostring(array.size(supBox)), text_color=colBear, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 3, "DEMAND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, str.tostring(array.size(demBox)), text_color=colBull, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "─── FILTERS ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 4, "", bgcolor=sec)

    table.cell(dash, 0, 5, "TREND", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, trendUp ? "▲ BULL" : trendDn ? "▼ BEAR" : "—",
      text_color=trendUp ? colBull : trendDn ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 6, "PD ZONE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, inDiscount ? "◧ DISCOUNT" : inPremium ? "◧ PREMIUM" : "— EQ",
      text_color=inDiscount ? colBull : inPremium ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 7, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, str.tostring(adxVal, "#.#") + (adxOK ? " ✓" : " ✗"),
      text_color=adxOK ? colBull : colBear, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 8, "VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, volBull ? "▲ BULL" : volBear ? "▼ BEAR" : "—",
      text_color=volBull ? colBull : volBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "─── STATS ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 9, "", bgcolor=sec)

    table.cell(dash, 0, 10, "SIGNALS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 10, str.tostring(nSig), text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 11, "WINS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, str.tostring(wins), text_color=colBull, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 12, "LOSSES", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, str.tostring(losses), text_color=colBear, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 13, "WIN RATE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 13, closed > 0 ? str.tostring(winRate, "#.#") + "%" : "—",
      text_color=closed > 0 and winRate >= 50 ? colBull : colBear, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 14, "PENDING", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 14, str.tostring(pending), text_color=colSweep, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 15, "MIN GRADE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 15, minGrade + "+", text_color=colTextLt, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(buySig, title="Fortress Demand Long",
  message="[AlphaX FORTRESS] DEMAND LONG — Rejection at demand zone.")
alertcondition(sellSig, title="Fortress Supply Short",
  message="[AlphaX FORTRESS] SUPPLY SHORT — Rejection at supply zone.")
alertcondition(sweepBuy, title="Fortress Sweep Long",
  message="[AlphaX FORTRESS] SWEEP LONG — Liquidity grab + reclaim at demand.")
alertcondition(sweepSell, title="Fortress Sweep Short",
  message="[AlphaX FORTRESS] SWEEP SHORT — Liquidity grab + reclaim at supply.")
alertcondition(detectDemand, title="New Demand Zone",
  message="[AlphaX FORTRESS] New DEMAND zone formed.")
alertcondition(detectSupply, title="New Supply Zone",
  message="[AlphaX FORTRESS] New SUPPLY zone formed.")
````
