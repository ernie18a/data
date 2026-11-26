# [ A L P H A X ] Structure Flow Pro

- url: https://www.tradingview.com/script/lf2fAdH2-A-L-P-H-A-X-Structure-Flow-Pro/
- type: indicator
- pine_id: PUB;a914644002d04e57af16325f460007d2
- version: 1.0

## Description

[b]AlphaX Structure Flow Pro — Market Structure Engine, HPZ Order Blocks, Fair Value Gaps, Liquidity Sweeps, Equal Highs/Lows & SMC Confluence Signals[/b]

AlphaX Structure Flow Pro is a professional-grade Smart Money Concepts indicator built on a pivot-driven market structure engine that detects swing highs and lows in real time, identifies Market Structure Breaks with momentum Z-score validation and Body-Confirmed Breaks, discovers and scores Order Blocks using a proprietary High Probability Zone algorithm, maps Fair Value Gaps and Liquidity Sweeps as they form, identifies Equal Highs and Lows as liquidity pools, and synthesizes every active condition into a tiered SMC Confluence Score — all displayed on a live dashboard with 15+ alert conditions. Designed for traders who operate within the institutional Smart Money framework on any liquid instrument and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]
[image]https://www.tradingview.com/x/2HJnGrlr/[/image]

[i]Full chart view showing Market Structure swing lines, MSB/BMS labels, HPZ Order Blocks with POC lines, FVG zones, Liquidity Sweep markers, Equal High/Low connections, SMC tiered entry labels, and the live Dashboard panel on XAUUSD[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The Market Structure Engine — How It Works[/b]

At the core of AlphaX Structure Flow Pro is a real-time [b]pivot-based swing detection system[/b] that continuously tracks confirmed swing highs and swing lows using a configurable lookback window. Every confirmed pivot is labeled, connected, and used as the structural reference for all break logic downstream.

Each confirmed pivot produces:

[list]
[*]A [b]dotted swing line[/b] connecting the current and previous swing high or swing low — a live map of whether price is building higher highs and higher lows, or lower highs and lower lows
[*]Small compact [b]H[/b] and [b]L[/b] labels at every swing point to mark the structural sequence clearly
[/list]

From these pivots, the engine monitors two distinct types of structural break — each progressively more powerful than the last:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]1 ─ Market Structure Break (MSB)[/b]

A confirmed close beyond the last tracked swing high or low, validated by a [b]Momentum Z-Score filter[/b]. The Z-Score measures how many standard deviations the current bar's price change sits above or below its 50-bar mean. Only breaks where momentum is statistically significant above your configured threshold are accepted — low-conviction wicks, slow grinds, and false closes through structure are automatically ignored.

When a valid MSB fires:
[list]
[*]A horizontal line is drawn from the breached pivot to the current bar, anchored at the exact structural level
[*]An [b]MSB ▲[/b] or [b]MSB ▼[/b] label appears at the midpoint of that line
[*]The breached swing level is reset so the engine never double-fires on the same break
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]2 ─ Break of Market Structure (BMS)[/b]

A stricter and more powerful structural confirmation. In addition to closing beyond the pivot, BMS requires the breaking candle to have a [b]body-to-range ratio above 50%[/b] — the break must be driven by a full-bodied candle, not a wick spike. BMS fires as a compact [b]BMS[/b] label when it occurs without a simultaneous MSB, giving you a clear visual distinction between a momentum-confirmed break and a body-confirmed break.

How to read them together:
[list]
[*][b]MSB[/b] — momentum is statistically significant but the candle body is below 50% — a valid break, treat it with context
[*][b]BMS[/b] — the candle closed through structure with conviction — higher-probability structural shift
[*]When both fire simultaneously, only the MSB label is shown as it already captures the event
[/list]

Together, MSB and BMS form the structural backbone from which all Order Block discovery, FVG anchoring, and SMC Confluence scoring is triggered.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 [b]Order Block Engine with HPZ Scoring[/b]

Every Market Structure Break triggers an automatic search backward through the preceding candles to identify the [b]originating Order Block[/b] — the last candle moving against the direction of the break before price impulsed away. For a bullish MSB the engine finds the last bearish candle within the lookback window. For a bearish MSB it finds the last bullish candle.

Each discovered Order Block is assigned a [b]Quality Score from 0 to 100[/b] built from four independent factors:

[b]Momentum Strength[/b]
The absolute magnitude of the Momentum Z-Score at the time of the MSB. Stronger impulsive moves away from the OB produce higher scores — a zone that launched a 3-sigma move ranks far above one that launched a 0.5-sigma drift.

[b]Volume Percentile[/b]
The current bar's volume ranked against its last 100 bars using percentile rank. High-volume structural breaks indicate institutional participation — OBs discovered on high-volume breaks score significantly higher.

[b]Candle Body Ratio[/b]
The proportion of the breaking candle that is body versus wick. A full-bodied impulsive candle away from the OB signals conviction. A wick-heavy or indecision candle signals a weaker origin.

[b]OB Size Relative to ATR[/b]
The Order Block's height measured against the current 14-period ATR. Compact, well-defined OBs close to 1 ATR score proportionally — excessively large or tiny zones are naturally discounted.

These four factors are combined into the final [b]Quality Score[/b] displayed on every OB label. Zones that score above your configured [b]HPZ Threshold[/b] (default 75%) are promoted to [b]High Probability Zones ⬡[/b] and rendered with a brighter border and a distinct ⬡HPZ badge — the highest-conviction institutional zones on your chart.

[i]HPZ Order Blocks rendered with enhanced borders and ⬡HPZ badge — standard OBs shown with dimmer styling for instant visual hierarchy[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Order Block Management[/b]

Active Order Blocks are not static — AlphaX Structure Flow Pro manages every zone dynamically bar by bar:

[list]
[*][b]Live extension[/b] — every active, unmitigated OB extends its right edge forward to the current bar automatically, keeping your zones current at all times
[*][b]Point of Control (POC) line[/b] — a dashed line at the exact midpoint of every OB, showing the most important price level within the zone
[*][b]Mitigation detection[/b] — when price trades into the OB (low below OB bottom for bullish, high above OB top for bearish), the zone is marked as mitigated and dimmed to neutral gray
[*][b]Historical mode[/b] — mitigated OBs remain visible on the chart dimmed for reference, letting you study how price reacted after mitigation
[*][b]Present mode[/b] — mitigated OBs are deleted automatically, keeping the chart clean with only live unmitigated zones visible
[*][b]Extend Broken OBs[/b] — optionally continue extending mitigated zones for up to 50 bars after mitigation for post-mitigation analysis
[*][b]Overlap filtering[/b] — optionally hide new OBs that overlap existing active zones, preventing zone clustering in congested areas
[*][b]OB Reliability tracker[/b] — the dashboard shows a live percentage of how many total OBs have been mitigated versus left untouched, giving you a real-time measure of how well price is respecting the zones on your current instrument and timeframe
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Fair Value Gaps (FVG)[/b]

AlphaX Structure Flow Pro detects [b]Fair Value Gaps[/b] — three-candle imbalances where price moved so fast that the market left an unfilled gap between candle one's high/low and candle three's low/high.

[list]
[*][b]Bullish FVG[/b] — candle three's low is above candle one's high — an upward gap in price action that the market may return to fill
[*][b]Bearish FVG[/b] — candle three's high is below candle one's low — a downward gap
[/list]

A minimum FVG size filter (ATR × your configured factor) prevents micro-gaps from cluttering the chart — only imbalances of meaningful size relative to current volatility are plotted.

Each FVG is drawn as a shaded box that extends forward bar by bar. When price trades back into the gap, the box is marked as filled and dimmed to neutral, stopping its extension. The dashboard tracks how many FVGs remain unfilled at all times, and the SMC Confluence engine uses unfilled FVGs above and below price as draw-on-liquidity targets when scoring entry signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Liquidity Sweeps[/b]

A [b]Liquidity Sweep[/b] is one of the most important Smart Money patterns — institutions engineer price to run stop-loss liquidity beyond obvious highs or lows, then reverse sharply. AlphaX Structure Flow Pro identifies these events in real time.

[b]Bullish Sweep[/b] — the candle's low breaks below the lowest low of the recent lookback window but the candle closes back above that level as a bullish close. Stops below recent lows were hunted, liquidity was absorbed, and price reversed upward.

[b]Bearish Sweep[/b] — the candle's high breaks above the highest high of the recent lookback window but the candle closes back below that level as a bearish close. Stops above recent highs were hunted.

Each sweep is marked with a compact ⚡ label at the wick extreme. Sweeps feed directly into the SMC Confluence scoring system — a bullish sweep adds 20 points to the Bull SMC Score because it signals smart money accumulation, and a bearish sweep adds 20 points to the Bear SMC Score for the same reason in reverse.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

〰 [b]Equal Highs and Equal Lows (EQH / EQL)[/b]

[b]Equal Highs[/b] and [b]Equal Lows[/b] are areas where price has printed two swing highs or two swing lows at nearly the same level — these levels represent clusters of resting stop-loss orders and are prime targets for institutional liquidity sweeps.

AlphaX Structure Flow Pro detects EQH and EQL automatically by comparing consecutive confirmed pivots. When two swing highs are within your configured ATR-scaled tolerance of each other, an [b]EQH[/b] label and dotted connection line are drawn. When two swing lows match, an [b]EQL[/b] label appears.

The ATR-scaled tolerance ensures the detection adapts to current market volatility — what counts as "equal" on a calm Asian session is different from a high-volatility London open, and the indicator adjusts automatically.

[i]Equal Highs and Equal Lows marked with purple dotted lines — clear visual identification of stop-hunt targets above and below current price[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]SMC Confluence Scoring System[/b]

Every signal in AlphaX Structure Flow Pro feeds into a [b]real-time SMC Confluence Engine[/b] that evaluates all active conditions simultaneously and produces a score from 0 to 100 for both the bullish and bearish side. Only scores that meet your configured minimum threshold generate a visible entry label — weak, ambiguous, or isolated setups never reach the chart.

[b]Bull SMC Score Factors:[/b]

[list]
[*][b]Market Structure Break (30 points)[/b] — an MSB bull fires adds 30 points as the core structural trigger. A BMS bull without simultaneous MSB adds 20 points.
[*][b]Liquidity Sweep (20 points)[/b] — a bullish sweep on the current bar adds 20 points — smart money has absorbed sell-side liquidity
[*][b]Near Bullish HPZ Order Blocks (up to 18 points)[/b] — two or more unmitigated bullish HPZ OBs within 2 ATR of price adds 18 points. One HPZ OB nearby adds 10 points.
[*][b]Bearish FVG Draw on Liquidity (up to 10 points)[/b] — two or more unfilled bearish FVGs above price (magnets drawing price upward) adds 10 points. One adds 5 points.
[*][b]Momentum Z-Score confirmation (up to 12 points)[/b] — strong upward momentum (Z > 2.0) adds 12 points. Moderate (Z > 1.0) adds 7. Mild (Z > 0.5) adds 3.
[*][b]Volume ratio (up to 8 points)[/b] — volume spike (×2.0) adds 8, high volume (×1.3) adds 5, above average (×1.0) adds 2
[*][b]Candle body (up to 6 points)[/b] — a bullish close with body ratio above 60% adds 6 points. Any bullish close adds 3.
[*][b]Penalties[/b] — strong downward momentum (Z < −1.0) deducts 10 points. Two or more nearby bearish HPZ OBs deduct 8 points.
[/list]

[b]Bear SMC Score Factors[/b] are the exact mirror of the above, applied in reverse for all bearish conditions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Signal Tiers and Entry Labels[/b]

Every signal that clears the minimum SMC score threshold is classified into one of three tiers based on its final score:

[list]
[*][b]S-Tier[/b] — score ≥ 70. Maximum confluence. All major factors aligned. The highest-confidence setups the engine produces.
[*][b]A-Tier[/b] — score 55–69. Strong confluence with most major factors present.
[*][b]B-Tier[/b] — score at or above your minimum threshold but below 55. Valid setup with meaningful confluence but fewer confirming factors.
[/list]

Entry labels appear directly on the chart with the tier and score displayed:
[list]
[*][b]▲ S-SMC (82)[/b] — bullish S-tier signal with a score of 82
[*][b]▼ A-SMC (61)[/b] — bearish A-tier signal with a score of 61
[/list]

Label color intensity reflects the tier — S-tier labels use the brightest bull or bear color, A-tier uses the primary color, B-tier uses the dimmed shade. This gives you instant visual priority — your eyes go to the brightest labels first.

A configurable [b]Signal Cooldown[/b] prevents back-to-back signals within a set number of bars, eliminating label spam during fast-moving structural events.

[i]S-tier and A-tier entry labels appearing below bars during bullish SMC confluence — label brightness reflects confidence tier at a glance[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🗓 [b]Session Ranges[/b]

AlphaX Structure Flow Pro includes a full [b]Session Range overlay[/b] for the four major trading sessions — London, New York, Tokyo, and Sydney — each independently toggleable with customizable colors and time windows.

Session boxes draw in real time as the session opens, expanding their high and low dynamically as price prints new extremes within the session. The session label updates its position to stay centered above the range. Each session closes when its time window ends, leaving the completed range as a permanent reference box for that period.

Use session ranges to:
[list]
[*]Identify the high and low of a session as key liquidity targets for sweeps
[*]Determine whether an MSB or OB formation occurred during a high-liquidity or low-liquidity window
[*]Spot the London or New York open as a structural break origin
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The AlphaX Structure Flow Pro dashboard gives you a complete real-time readout of every active market condition in a compact panel — no need to visually scan the chart for each element individually.

[b]Market Structure section:[/b]
[list]
[*][b]MSB STATUS[/b] — shows whether a Bull MSB, Bear MSB, or no MSB is active on the current bar
[*][b]BMS (BODY)[/b] — shows whether a body-confirmed structural break is active
[*][b]MOMENTUM Z[/b] — current Z-score reading with direction label (STRONG / MODERATE / MILD / FLAT) and raw value
[/list]

[b]Order Blocks section:[/b]
[list]
[*][b]ACTIVE OBs[/b] — total count of unmitigated Order Blocks currently on the chart
[*][b]HPZ OBs[/b] — count of active High Probability Zone OBs, highlighted when any are present
[*][b]OB RELIABILITY[/b] — live percentage of total OBs that have been mitigated since the indicator started tracking — your real-time measure of how well structure is being respected
[/list]

[b]Liquidity & Imbalance section:[/b]
[list]
[*][b]LIQ SWEEP[/b] — shows whether a Bull or Bear liquidity sweep is active on the current bar
[*][b]OPEN FVGs[/b] — count of unfilled Fair Value Gaps currently active
[*][b]DRAW ON LIQ[/b] — shows whether price has unfilled FVGs drawing it upward, downward, or on both sides
[/list]

[b]SMC Confluence section:[/b]
[list]
[*][b]BULL SMC SCORE[/b] — current bullish confluence score with tier label (S-TIER / A-TIER / B-TIER / LOW)
[*][b]BEAR SMC SCORE[/b] — current bearish confluence score with tier label
[*][b]HPZ PROXIMITY[/b] — shows whether price is near a Bull HPZ zone, Bear HPZ zone, both sides, or neither
[/list]

[b]Market Conditions section:[/b]
[list]
[*][b]VOLUME[/b] — current volume classified as SPIKE / HIGH / NORMAL / DRY with the live ×ratio
[*][b]ATR (14)[/b] — current 14-period ATR value in price terms
[*][b]CANDLE BODY[/b] — current candle body ratio classified as STRONG / MODERATE / WEAK with percentage
[/list]

[b]Active Signal section:[/b]
[list]
[*][b]SIGNAL[/b] — shows the active entry signal direction and tier, or NONE — the single most important row if you need a quick status check
[/list]

Dashboard position (Top Left / Top Right / Bottom Left / Bottom Right) and text size (Tiny / Small / Normal / Large) are fully configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When NOT to Trade[/b]

Knowing when to stay out is just as important as knowing when to enter. AlphaX Structure Flow Pro gives you clear signals that the market is not in a tradeable condition:

[b]How to identify unfavorable conditions:[/b]
[list]
[*][b]No MSB or BMS on the dashboard[/b] — if the MSB STATUS row shows NONE, there is no confirmed structural trigger. No structural break means no Order Block discovery, and no SMC signals should be acted on.
[*][b]Bull and Bear SMC Scores both show LOW[/b] — when neither side can build enough confluence to reach even B-tier, the market is either ranging, choppy, or lacking institutional participation. Wait for a clear dominant side to emerge.
[*][b]OB RELIABILITY is very high (above 80–90%)[/b] — when nearly every OB is being quickly mitigated, price is not respecting structure and the market is in a sweep-and-reverse or noise regime. Reduce position size or stand aside.
[*][b]No SMC entry labels appearing[/b] — the confluence engine is running on every bar. If no labels are printing even after MSB events, the filters are doing their job blocking low-quality setups. Do not lower the threshold to force signals — wait for real confluence.
[*][b]DRAW ON LIQ shows BOTH SIDES[/b] — unfilled FVGs above and below simultaneously means price is in the middle of a contested range with equal magnets in both directions. No clean directional edge exists.
[*][b]MOMENTUM Z reads FLAT on the dashboard[/b] — flat momentum at a structural level often means a failed break rather than a true MSB. Treat these events with extra caution.
[/list]

[b]What to do during unfavorable conditions:[/b]
[list]
[*]Wait for a clean MSB or BMS to set the directional bias before considering any entry
[*]Look for one dominant side in the SMC Confluence section — both Bull and Bear scores being low simultaneously is a ranging signal
[*]Watch for a liquidity sweep followed immediately by an MSB in the same direction — that sequence is one of the highest-probability SMC setups and will produce a strong confluence score when it fires
[*]Consider switching to a higher timeframe to find cleaner structure — if the current timeframe is printing rapid alternating MSBs, the higher timeframe trend will show you the dominant direction
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Structure Flow Pro — Step by Step[/b]

[b]Step 1 — Read the Dashboard[/b]
[list]
[*]Check MSB STATUS and BMS — is there a live structural break?
[*]Check Bull and Bear SMC Scores — is one side clearly dominant with a B-tier or higher score?
[*]Check DRAW ON LIQ — are unfilled FVGs pulling price in one clear direction?
[*]If no clear dominant side and no MSB → do not trade. Wait for structure.
[/list]

[b]Step 2 — Identify the Structural Trigger[/b]
[list]
[*]An MSB ▲ or BMS bull sets your bullish directional bias
[*]An MSB ▼ or BMS bear sets your bearish directional bias
[*]Do not enter blindly on the MSB label alone — use it to set context, then wait for a tiered SMC signal to confirm
[/list]

[b]Step 3 — Enter on a Tiered SMC Signal[/b]
[list]
[*]Wait for a [b]▲ SMC[/b] or [b]▼ SMC[/b] label to appear with a tier of B or higher
[*]Prioritize S-tier and A-tier signals — these have the most factors aligned
[*]Check that an unmitigated HPZ Order Block is nearby in the direction of the trade — HPZ proximity is displayed on the dashboard in real time
[*]Place your stop loss beyond the most recent swing low (for longs) or swing high (for shorts), or just beyond the relevant OB's outer edge
[/list]

[b]Step 4 — Use FVGs and OBs as Targets and Re-Entry Zones[/b]
[list]
[*]Unfilled FVGs in the direction of the trade are natural draw-on-liquidity targets — they show you where price is likely being pulled toward
[*]Mitigated OBs (shown dimmed in Historical mode) mark areas where price has already visited and absorbed — useful as reference for prior institutional activity
[*]If price pulls back into an unmitigated bullish OB without triggering a new bearish MSB, that is a potential re-entry zone aligned with the original structural break
[/list]

[b]Step 5 — Monitor for Structural Invalidation[/b]
[list]
[*]If an opposing MSB fires after your entry, the structure has shifted — close or reduce your position
[*]If the SMC Score for your trade direction drops to LOW on the dashboard without a new signal, momentum is fading
[*]A liquidity sweep against your position that does not produce a reversal SMC signal is a warning — tighten your stop
[/list]

[b]Step 6 — Watch for Equal Highs/Lows as Exit Targets[/b]
[list]
[*]EQH levels above price during a bull trade are natural exit zones — institutions often sweep equal highs as final liquidity grabs before reversal
[*]EQL levels below price during a bear trade serve the same purpose
[*]Consider taking partial profit as price approaches an EQH or EQL level, then hold the remainder for a potential sweep and continuation
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]

[list]
[*]🔬 Pivot-based market structure engine with configurable swing lookback — tracks confirmed swing highs and lows in real time
[*]📈 MSB detection with Momentum Z-Score validation — filters out low-conviction structural breaks statistically
[*]💪 BMS detection with candle body ratio confirmation — only full-bodied closes through structure qualify
[*]📦 Order Block discovery anchored to every MSB — automatically finds the originating institutional candle
[*]⬡ Proprietary HPZ Quality Score (0–100) — four-factor scoring system promotes the highest-conviction zones to High Probability Zone status
[*]📍 Point of Control line on every Order Block — shows the midpoint of the zone for precision entries
[*]🔄 Dynamic OB management — live extension, mitigation detection, Historical and Present display modes, overlap filtering, and broken OB extension
[*]📊 Fair Value Gap detection with ATR-scaled minimum size filter — bullish and bearish imbalances mapped and tracked until filled
[*]⚡ Liquidity Sweep detection — wick-beyond plus close-inside logic identifies institutional stop hunts in real time
[*]〰 Equal Highs and Equal Lows detection with ATR-scaled tolerance — automatic identification of resting liquidity pools
[*]🧠 Multi-factor SMC Confluence Scoring Engine — synthesizes structure, sweeps, HPZ OBs, FVG draw, momentum, volume, and candle body into a single 0–100 score per side
[*]🏆 Three-tier signal classification — S-Tier (≥70), A-Tier (55–69), B-Tier (threshold to 54) with color-coded label intensity
[*]⏱ Signal cooldown timer — configurable minimum bars between signals to eliminate label spam
[*]✅ Optional volume confirmation filter — require minimum volume ratio before any signal fires
[*]🗓 Four-session range overlay — London, New York, Tokyo, and Sydney each independently toggleable with custom colors and time windows
[*]📋 Live 7-section dashboard — MSB/BMS status, momentum Z, OB counts, HPZ proximity, FVG draw direction, SMC scores, volume, ATR, and active signal — all in one panel
[*]🎨 Fully customizable color theme — 13 configurable colors covering bull, bear, neutral, FVG, sweep, EQL, and dashboard elements
[*]🔔 15+ alert conditions — MSB bull/bear, BMS bull/bear, S/A/B-tier bull signals, S/A/B-tier bear signals, any SMC signal, bull/bear sweeps, bull/bear FVGs, and MSB + HPZ confluence alerts
[*]⚙ Fully configurable — every lookback, threshold, score, toggle, color, and session window adjustable from the settings panel
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Market Structure[/b]
[list]
[*]Pivot Lookback — bars on each side required to confirm a swing high or low (default: 7, range: 3–21)
[*]MSB Momentum Z-Score — minimum standard deviation threshold for a valid Market Structure Break (default: 0.5)
[*]Show MSB Lines & Labels — toggle visibility of MSB/BMS lines and labels
[*]Show Structure Swings — toggle visibility of swing lines and H/L pivot labels
[*]Detect Break of Market Structure (BMS) — enable or disable body-confirmed structural break detection
[/list]

[b]Order Blocks[/b]
[list]
[*]Max Active OBs — maximum number of unmitigated Order Blocks kept on the chart at once (default: 10)
[*]OB Lookback (candles) — how many candles back the engine searches for the originating OB after an MSB (default: 10)
[*]Extend Broken OBs — continue extending mitigated OBs for up to 50 bars after mitigation
[*]Hide Overlapping OBs — skip new OBs that overlap existing active zones
[*]Display Mode — Historical (keep mitigated OBs dimmed) or Present (delete mitigated OBs automatically)
[*]HPZ Threshold Score (%) — minimum quality score required for HPZ promotion (default: 75%)
[*]Show OB Point of Control — toggle the midpoint POC dashed line on Order Blocks
[/list]

[b]Liquidity & Imbalance[/b]
[list]
[*]Show Fair Value Gaps — toggle FVG detection and display
[*]Min FVG Size (ATR × factor) — minimum gap size as a multiple of ATR to qualify as a valid FVG (default: 0.05)
[*]Show Liquidity Sweeps — toggle sweep detection and ⚡ markers
[*]Sweep Lookback (bars) — lookback window for determining the recent high/low that is swept (default: 20)
[*]Show Equal Highs / Lows — toggle EQH and EQL detection and display
[*]EQL Tolerance (ATR × factor) — how close two pivots must be to qualify as equal, scaled to ATR (default: 0.1)
[/list]

[b]Smart Money Confluence (SMC)[/b]
[list]
[*]Enable SMC Confluence Engine — master toggle for the scoring system and all entry labels
[*]Min SMC Score to Signal — minimum confluence score required to display an entry label (default: 30)
[*]Signal Cooldown (bars) — minimum bars between consecutive signals in the same direction (default: 3)
[*]Require Volume Confirmation — only fire signals when volume ratio meets the minimum threshold
[*]Min Volume Ratio — minimum volume-to-SMA ratio required when volume filter is enabled (default: 0.7)
[/list]

[b]Sessions[/b]
[list]
[*]Show Session Ranges — master toggle for the session overlay
[*]London / New York / Tokyo / Sydney — independently toggle each session with configurable time window and color
[/list]

[b]Dashboard[/b]
[list]
[*]Show Dashboard — toggle the dashboard panel on or off
[*]Position — Top Left / Top Right / Bottom Left / Bottom Right
[*]Size — Tiny / Small / Normal / Large
[/list]

[b]Appearance[/b]
[list]
[*]Label Size — controls the size of all MSB, BMS, sweep, EQH/EQL, and entry labels (Tiny / Small / Normal)
[/list]

[b]Colors[/b]
[list]
[*]Bull Primary / Bright / Dim — three shades of the bullish color family for OBs, labels, and signals
[*]Bear Primary / Bright / Dim — three shades of the bearish color family
[*]Neutral / Neutral Light — colors for mitigated zones and inactive states
[*]Text Light — color for dashboard row labels
[*]Dashboard Background — background color of the dashboard panel
[*]FVG Bull / Bear Color — colors for bullish and bearish Fair Value Gap zones
[*]Liquidity Sweep Color — color for sweep ⚡ labels
[*]Equal Hi/Lo Color — color for EQH and EQL lines and labels
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]

[list]
[*]Bull Market Structure Break — fires on every bullish MSB
[*]Bear Market Structure Break — fires on every bearish MSB
[*]Bull Break of Market Structure (Body Close) — fires on every bullish BMS
[*]Bear Break of Market Structure (Body Close) — fires on every bearish BMS
[*]S-Tier Bull SMC Signal — bullish signal with score ≥ 70
[*]A-Tier Bull SMC Signal — bullish signal with score 55–69
[*]B-Tier Bull SMC Signal — bullish signal below 55 but above minimum threshold
[*]S-Tier Bear SMC Signal — bearish signal with score ≥ 70
[*]A-Tier Bear SMC Signal — bearish signal with score 55–69
[*]B-Tier Bear SMC Signal — bearish signal below 55 but above minimum threshold
[*]Any SMC Signal — fires on any bullish or bearish signal regardless of tier
[*]Bull Liquidity Sweep — wick below recent lows with bullish close
[*]Bear Liquidity Sweep — wick above recent highs with bearish close
[*]Bullish Fair Value Gap — new bullish FVG formed
[*]Bearish Fair Value Gap — new bearish FVG formed
[*]Bull MSB + HPZ Confluence — bullish MSB with at least one nearby unmitigated HPZ OB
[*]Bear MSB + HPZ Confluence — bearish MSB with at least one nearby unmitigated HPZ OB
[/list]

All alert messages include {{ticker}} and {{interval}} placeholders for clean webhook and bot integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Use Case[/b]

The default configuration is tuned for [b]intraday trading on liquid instruments including XAUUSD, forex majors, and indices[/b] on M1 to M15 timeframes.

[b]For tighter, higher-conviction signals:[/b]
[list]
[*]Increase Min SMC Score to 45–55 — only S-tier and strong A-tier setups fire
[*]Enable Require Volume Confirmation and set Min Volume Ratio to 1.0–1.3
[*]Increase Pivot Lookback to 9–12 for larger, more significant swing points
[*]Set HPZ Threshold to 80% to tighten HPZ qualification
[/list]

[b]For more signals and aggressive scalping:[/b]
[list]
[*]Reduce Min SMC Score to 20–25
[*]Reduce Signal Cooldown to 1–2 bars
[*]Reduce Pivot Lookback to 3–5 for faster swing detection
[*]Keep Volume Confirmation off
[/list]

[b]For higher timeframes (H1, H4, Daily):[/b]
[list]
[*]Increase Pivot Lookback to 10–15
[*]Increase OB Lookback to 15–20
[*]Increase Min SMC Score to 40–50
[*]Increase Sweep Lookback to 30–50
[/list]

[b]For ranging or news-driven markets:[/b]
[list]
[*]Enable Hide Overlapping OBs to reduce zone clutter
[*]Switch Display Mode to Present to keep only live zones visible
[*]Monitor DRAW ON LIQ on the dashboard — if both sides show FVGs, avoid directional trades
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]

[list]
[*]🥇 [b]Smart Money Concepts traders[/b] — built specifically around the MSB → OB → FVG → Sweep framework that institutional-style traders use
[*]📉 [b]Forex and Gold traders[/b] — fully applicable to XAUUSD, forex majors and minors, and all liquid currency pairs
[*]📊 [b]Index traders[/b] — works on US30, NAS100, SPX500, DAX, and all major equity indices
[*]🧠 [b]Systematic and rule-based traders[/b] — the confluence scoring system provides a quantitative, objective framework rather than purely subjective visual reads
[*]📈 [b]Traders who want one complete SMC system[/b] — structure, OBs, FVGs, sweeps, EQH/EQL, sessions, scoring, and dashboard in a single indicator rather than layering five separate tools
[*]⚠ [b]Traders who struggle with overtrading[/b] — the minimum score filter, cooldown, and volume gate physically prevent low-quality signals from reaching the chart
[*]🔔 [b]Alert-driven traders and bot operators[/b] — 17 alert conditions with clean webhook-ready message formatting cover every meaningful event the indicator can detect
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]

[list]
[*]Session range features use the time zone of each configured session string — set your London and New York session times to match your chart's time zone if ranges appear offset
[*]The Momentum Z-Score is calculated over a 50-bar rolling window — on very short histories or immediately after a chart loads, early bars may have lower Z-Score values until the window fills
[*]OB Reliability percentage starts from zero when the indicator first loads and builds over time as OBs are discovered and mitigated — it is most meaningful after a full session of price action
[*]The SMC Confluence Engine evaluates conditions on bar close — all signals are non-repainting and confirmed on the closed bar
[*]With max_boxes_count, max_lines_count, and max_labels_count each set to 500 and max_bars_back at 500, on very low timeframes with extended chart history the oldest visual elements may be automatically removed by TradingView's rendering limits — this is a platform constraint, not an indicator limitation
[*]The HPZ proximity check uses a 2 ATR radius around the current close price — zones further away than 2 ATR are not counted in the SMC score even if they are unmitigated and visible on the chart
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who demand structure, confluence, and precision from their Smart Money analysis.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX

//@version=6
indicator("[ A L P H A X ] Structure Flow Pro", shorttitle="AlphaX SFP",
  overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ INPUTS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// ── Market Structure ──────────────────────────────────────────────────────────
pivotLen       = input.int(7,      "Pivot Lookback",            minval=3,   maxval=21,   group="Market Structure")
msbZScore      = input.float(0.5,  "MSB Momentum Z-Score",      minval=0.1, maxval=3.0,  step=0.1, group="Market Structure")
showMSB        = input.bool(true,  "Show MSB Lines & Labels",                            group="Market Structure")
showStructure  = input.bool(true,  "Show Structure Swings",                              group="Market Structure")
bmsEnabled     = input.bool(true,  "Detect Break of Market Structure (BMS)",             group="Market Structure")

// ── Order Blocks ──────────────────────────────────────────────────────────────
obCount        = input.int(10,     "Max Active OBs",            minval=1,   maxval=100,  group="Order Blocks")
obLookback     = input.int(10,     "OB Lookback (candles)",     minval=3,   maxval=20,   group="Order Blocks")
extendBroken   = input.bool(false, "Extend Broken OBs",                                  group="Order Blocks")
hideOverlaps   = input.bool(false, "Hide Overlapping OBs",                               group="Order Blocks")
obMode         = input.string("Historical", "Display Mode",
  options=["Historical","Present"],                                                        group="Order Blocks")
hpzThresh      = input.float(75.0, "HPZ Threshold Score (%)",   minval=50,  maxval=95,   step=5, group="Order Blocks")
showPOC        = input.bool(true,  "Show OB Point of Control",                           group="Order Blocks")

// ── Liquidity & Imbalance ─────────────────────────────────────────────────────
showFVG        = input.bool(true,  "Show Fair Value Gaps (FVG)",                         group="Liquidity & Imbalance")
fvgMinSize     = input.float(0.05, "Min FVG Size (ATR × factor)", minval=0.01, maxval=1.0, step=0.01, group="Liquidity & Imbalance")
showLiqSweep   = input.bool(true,  "Show Liquidity Sweeps",                              group="Liquidity & Imbalance")
sweepLookback  = input.int(20,     "Sweep Lookback (bars)",     minval=5,   maxval=50,   group="Liquidity & Imbalance")
showEQL        = input.bool(true,  "Show Equal Highs / Lows",                            group="Liquidity & Imbalance")
eqlTolerance   = input.float(0.1,  "EQL Tolerance (ATR × factor)", minval=0.01, maxval=0.5, step=0.01, group="Liquidity & Imbalance")

// ── Smart Money Confluence (SMC) ─────────────────────────────────────────────
smcEnabled     = input.bool(true,  "Enable SMC Confluence Engine",                       group="Smart Money Confluence")
minSMCScore    = input.int(30,     "Min SMC Score to Signal",   minval=10,  maxval=80,   group="Smart Money Confluence")
cooldownBars   = input.int(3,      "Signal Cooldown (bars)",    minval=1,   maxval=20,   group="Smart Money Confluence")
useVolFilter   = input.bool(false, "Require Volume Confirmation",                        group="Smart Money Confluence")
volMinRatio    = input.float(0.7,  "Min Volume Ratio",          minval=0.3, maxval=2.0,  step=0.1, group="Smart Money Confluence")

// ── Sessions ──────────────────────────────────────────────────────────────────
showSessions   = input.bool(true,  "Show Session Ranges",                                group="Sessions")
showLondon     = input.bool(false, "London Session",                                     group="Sessions")
londonSess     = input.session("0800-1700:1234567", "London Time",                       group="Sessions")
londonCol      = input.color(#3b82f6, "London Color",                                   group="Sessions", inline="London")
showNY         = input.bool(false, "New York Session",                                   group="Sessions")
nySess         = input.session("1300-2200:1234567", "New York Time",                     group="Sessions")
nyCol          = input.color(#f97316, "New York Color",                                  group="Sessions", inline="NY")
showTokyo      = input.bool(false, "Tokyo Session",                                      group="Sessions")
tokyoSess      = input.session("0000-0900:1234567", "Tokyo Time",                        group="Sessions")
tokyoCol       = input.color(#f43f5e, "Tokyo Color",                                    group="Sessions", inline="Tokyo")
showSydney     = input.bool(false, "Sydney Session",                                     group="Sessions")
sydneySess     = input.session("2100-0600:1234567", "Sydney Time",                       group="Sessions")
sydneyCol      = input.color(#eab308, "Sydney Color",                                   group="Sessions", inline="Sydney")

// ── Dashboard ─────────────────────────────────────────────────────────────────
showDash       = input.bool(true,  "Show Dashboard",                                     group="Dashboard")
dashPos        = input.string("Top Right", "Position",
  options=["Top Left","Top Right","Bottom Left","Bottom Right"],                          group="Dashboard")
dashSizeInp    = input.string("Small", "Size",
  options=["Tiny","Small","Normal","Large"],                                              group="Dashboard")

// ── Appearance ────────────────────────────────────────────────────────────────
labelSizeInp   = input.string("Small", "Label Size",
  options=["Tiny","Small","Normal"],                                                       group="Appearance")

// ── Colors ────────────────────────────────────────────────────────────────────
colBullPrimary  = input.color(#c8e624, "Bull Primary",        group="Colors")
colBullBright   = input.color(#d4f03a, "Bull Bright",         group="Colors")
colBullDim      = input.color(#9ab81c, "Bull Dim",            group="Colors")
colBearPrimary  = input.color(#ff1744, "Bear Primary",        group="Colors")
colBearBright   = input.color(#ff5252, "Bear Bright",         group="Colors")
colBearDim      = input.color(#d50032, "Bear Dim",            group="Colors")
colNeutral      = input.color(#555555, "Neutral",             group="Colors")
colNeutralLight = input.color(#888888, "Neutral Light",       group="Colors")
colTextLight    = input.color(#cccccc, "Text Light",          group="Colors")
colDashBg       = input.color(#1a1a1a, "Dashboard Background",group="Colors")
colFVGBull      = input.color(#c8e624, "FVG Bull Color",      group="Colors")
colFVGBear      = input.color(#ff1744, "FVG Bear Color",      group="Colors")
colSweep        = input.color(color.rgb(40, 41, 40, 19), "Liquidity Sweep",     group="Colors")
colEQL          = input.color(#9c27b0, "Equal Hi/Lo",         group="Colors")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ TYPE DEFINITIONS ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

type OrderBlock
    box        boxId
    label      labelId
    line       pocLineId
    float      qualityScore
    float      top
    float      bottom
    bool       isBull
    bool       isHPZ
    bool       mitigated
    int        mitigationBar
    int        birthBar

type FVG
    box        boxId
    float      top
    float      bottom
    bool       isBull
    bool       filled
    int        birthBar

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ HELPERS ══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

getLabelSize(sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

getDashSize(sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

labelSize    = getLabelSize(labelSizeInp)
dashTextSize = getDashSize(dashSizeInp)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ CORE CALCULATIONS ════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

atrVal       = ta.atr(14)
float priceChange = ta.change(close)
float avgChange   = ta.sma(priceChange, 50)
float stdChange   = ta.stdev(priceChange, 50)
float momentumZ   = stdChange > 0 ? (priceChange - avgChange) / stdChange : 0.0
float volPercent  = ta.percentrank(volume, 100)
volSMA            = ta.sma(volume, 20)
volRatio          = volSMA > 0 ? volume / volSMA : 1.0
volOK             = not useVolFilter or volRatio >= volMinRatio

// Candle metrics
candleBody  = math.abs(close - open)
candleRange = high - low
bodyRatio   = candleRange > 0 ? candleBody / candleRange : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ PIVOT DETECTION ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPh    = na
var float lastPl    = na
var int   lastPhIdx = na
var int   lastPlIdx = na

// Swing tracking for structure drawing
var float prevSwingHigh    = na
var float prevSwingLow     = na
var int   prevSwingHighIdx = na
var int   prevSwingLowIdx  = na
var float currSwingHigh    = na
var float currSwingLow     = na
var int   currSwingHighIdx = na
var int   currSwingLowIdx  = na

if not na(ph)
    prevSwingHigh    := currSwingHigh
    prevSwingHighIdx := currSwingHighIdx
    currSwingHigh    := ph
    currSwingHighIdx := bar_index - pivotLen
    lastPh    := ph
    lastPhIdx := bar_index - pivotLen

if not na(pl)
    prevSwingLow    := currSwingLow
    prevSwingLowIdx := currSwingLowIdx
    currSwingLow    := pl
    currSwingLowIdx := bar_index - pivotLen
    lastPl    := pl
    lastPlIdx := bar_index - pivotLen

// ── Structure Swing Lines ────────────────────────────────────────────────────
if showStructure and not na(ph) and not na(prevSwingHigh) and not na(prevSwingHighIdx)
    line.new(prevSwingHighIdx, prevSwingHigh, bar_index - pivotLen, ph,
      color=color.new(colBearDim, 60), style=line.style_dotted, width=1)

if showStructure and not na(pl) and not na(prevSwingLow) and not na(prevSwingLowIdx)
    line.new(prevSwingLowIdx, prevSwingLow, bar_index - pivotLen, pl,
      color=color.new(colBullDim, 60), style=line.style_dotted, width=1)

// ── Swing High/Low Labels ────────────────────────────────────────────────────
if showStructure and not na(ph)
    label.new(bar_index - pivotLen, ph, "H",
      style=label.style_label_down, color=color.new(colBearDim, 80),
      textcolor=colBearDim, size=size.tiny, yloc=yloc.price)

if showStructure and not na(pl)
    label.new(bar_index - pivotLen, pl, "L",
      style=label.style_label_up, color=color.new(colBullDim, 80),
      textcolor=colBullDim, size=size.tiny, yloc=yloc.price)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ MARKET STRUCTURE BREAK ═══════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bool isMSBBull = not na(lastPh) and close > lastPh and close[1] <= lastPh and momentumZ > msbZScore
bool isMSBBear = not na(lastPl) and close < lastPl and close[1] >= lastPl and momentumZ < -msbZScore

// Break of Market Structure (confirmed with body close)
bool isBMSBull = bmsEnabled and not na(lastPh) and close > lastPh and close[1] <= lastPh and candleBody / candleRange > 0.5
bool isBMSBear = bmsEnabled and not na(lastPl) and close < lastPl and close[1] >= lastPl and candleBody / candleRange > 0.5

if showMSB and isMSBBull and not na(lastPhIdx)
    int mid = math.round(math.avg(lastPhIdx, bar_index))
    line.new(lastPhIdx, lastPh, bar_index, lastPh,
      color=color.new(colBullPrimary, 0), width=2)
    label.new(mid, lastPh, "MSB ▲",
      color=color.new(colBullPrimary, 100),
      textcolor=colBullPrimary,
      style=label.style_label_down, size=labelSize)

if showMSB and isMSBBear and not na(lastPlIdx)
    int mid = math.round(math.avg(lastPlIdx, bar_index))
    line.new(lastPlIdx, lastPl, bar_index, lastPl,
      color=color.new(colBearPrimary, 0), width=2)
    label.new(mid, lastPl, "MSB ▼",
      color=color.new(colBearPrimary, 100),
      textcolor=colBearPrimary,
      style=label.style_label_up, size=labelSize)

// BMS is a stronger label
if showMSB and isBMSBull and not isMSBBull and not na(lastPhIdx)
    label.new(bar_index, lastPh, "BMS",
      color=color.new(colBullBright, 85),
      textcolor=colBullBright,
      style=label.style_label_down, size=size.tiny)

if showMSB and isBMSBear and not isMSBBear and not na(lastPlIdx)
    label.new(bar_index, lastPl, "BMS",
      color=color.new(colBearBright, 85),
      textcolor=colBearBright,
      style=label.style_label_up, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ORDER BLOCK ENGINE ════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var obArray = array.new<OrderBlock>()

// Mitigation stats
var float totalMitigated = 0.0
var float totalOBs       = 0.0

if isMSBBull or isMSBBear
    int obIdx = 0
    for i = 1 to obLookback
        if (isMSBBull and close[i] < open[i]) or (isMSBBear and close[i] > open[i])
            obIdx := i
            break

    if obIdx > 0
        float obTop    = high[obIdx]
        float obBottom = low[obIdx]
        float obPOC    = math.avg(obTop, obBottom)
        float obSize   = obTop - obBottom

        // Enhanced Quality Score (0-100)
        // Factors: momentum strength, volume, body ratio, ob size relative to ATR, z-score magnitude
        float baseScore = math.min(100.0,
          (math.abs(momentumZ) * 15.0) +
          (volPercent * 0.4) +
          (bodyRatio * 20.0) +
          (obSize / atrVal * 10.0))
        float score = math.max(0.0, math.min(100.0, baseScore))
        bool isHPZ  = score >= hpzThresh

        color baseColor = isMSBBull ? colBullPrimary : colBearPrimary
        color hpzColor  = isMSBBull ? colBullBright  : colBearBright

        // Overlap check
        bool overlapping = false
        if hideOverlaps and obArray.size() > 0
            for i = 0 to obArray.size() - 1
                OrderBlock o = obArray.get(i)
                if not o.mitigated
                    if (obTop <= o.top and obTop >= o.bottom) or (obBottom <= o.top and obBottom >= o.bottom)
                        overlapping := true
                        break

        if not overlapping
            box   obBox   = na
            label obLabel = na
            line  obPoc   = na

            if isHPZ
                obBox  := box.new(bar_index[obIdx], obTop, bar_index + 20, obBottom,
                  border_color=color.new(hpzColor, 30),
                  bgcolor=color.new(hpzColor, 82),
                  border_width=1, border_style=line.style_dashed)
                if showPOC
                    obPoc := line.new(bar_index[obIdx], obPOC, bar_index + 20, obPOC,
                      color=color.new(hpzColor, 35), width=1, style=line.style_dashed)
            else
                obBox  := box.new(bar_index[obIdx], obTop, bar_index + 20, obBottom,
                  border_color=color.new(baseColor, 55),
                  bgcolor=color.new(baseColor, 88),
                  border_style=line.style_dashed, border_width=1)
                if showPOC
                    obPoc := line.new(bar_index[obIdx], obPOC, bar_index + 20, obPOC,
                      color=color.new(baseColor, 65), style=line.style_dashed, width=1)

            string scoreLabel = str.tostring(score, "#") + "%" + (isHPZ ? " ⬡HPZ" : "")
            obLabel := label.new(bar_index + 22, obPOC, scoreLabel,
              color=color.new(baseColor, 100),
              textcolor=isHPZ ? hpzColor : baseColor,
              style=label.style_none, size=size.tiny, textalign=text.align_left)

            OrderBlock newOB = OrderBlock.new(
              obBox, obLabel, obPoc,
              score, obTop, obBottom,
              isMSBBull, isHPZ, false, 0, bar_index[obIdx])
            obArray.push(newOB)
            totalOBs += 1.0

    if isMSBBull
        lastPh := na
    else
        lastPl := na

// ── OB Dynamic Management ────────────────────────────────────────────────────
if obArray.size() > 0
    for i = obArray.size() - 1 to 0
        OrderBlock ob = obArray.get(i)
        if not ob.mitigated
            ob.boxId.set_right(bar_index + 20)
            ob.labelId.set_x(bar_index + 22)
            if showPOC and not na(ob.pocLineId)
                ob.pocLineId.set_x2(bar_index + 20)

            bool isMitigated = ob.isBull ? low < ob.bottom : high > ob.top
            if isMitigated
                ob.mitigated      := true
                ob.mitigationBar  := bar_index
                totalMitigated    += 1.0
                if obMode == "Present"
                    ob.boxId.delete()
                    ob.labelId.delete()
                    if not na(ob.pocLineId)
                        ob.pocLineId.delete()
                else
                    ob.boxId.set_bgcolor(color.new(colNeutral, 90))
                    ob.boxId.set_border_color(color.new(colNeutral, 70))
                    ob.labelId.set_textcolor(color.new(colNeutral, 50))
                    if not na(ob.pocLineId)
                        ob.pocLineId.set_color(color.new(colNeutral, 80))
                    ob.boxId.set_right(bar_index)
                    ob.labelId.set_x(bar_index)
                    if not na(ob.pocLineId)
                        ob.pocLineId.set_x2(bar_index)
        else
            bool shouldExtend = extendBroken and (bar_index - ob.mitigationBar <= 50)
            if obMode == "Present"
                ob.boxId.delete()
                ob.labelId.delete()
                if not na(ob.pocLineId)
                    ob.pocLineId.delete()
            else if shouldExtend
                ob.boxId.set_right(bar_index + 20)
                ob.labelId.set_x(bar_index + 22)
                if not na(ob.pocLineId)
                    ob.pocLineId.set_x2(bar_index + 20)

    if obArray.size() > obCount
        OrderBlock oldOB = obArray.shift()
        oldOB.boxId.delete()
        oldOB.labelId.delete()
        if not na(oldOB.pocLineId)
            oldOB.pocLineId.delete()

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ FAIR VALUE GAPS ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var fvgArray = array.new<FVG>()

// Detect FVG on bar_index - 1 (middle candle)
float fvgMinSz = atrVal * fvgMinSize

// Bullish FVG: gap between high[2] and low[0] — price ran up fast
bool bullFVG = low > high[2] and (low - high[2]) >= fvgMinSz
// Bearish FVG: gap between low[2] and high[0]
bool bearFVG = high < low[2] and (low[2] - high) >= fvgMinSz

if showFVG and bullFVG
    float top    = low
    float bottom = high[2]
    box b = box.new(bar_index - 2, top, bar_index + 30, bottom,
      border_color=color.new(colFVGBull, 50),
      bgcolor=color.new(colFVGBull, 91),
      border_width=1, border_style=line.style_dotted)
    fvgArray.push(FVG.new(b, top, bottom, true, false, bar_index))

if showFVG and bearFVG
    float top    = low[2]
    float bottom = high
    box b = box.new(bar_index - 2, top, bar_index + 30, bottom,
      border_color=color.new(colFVGBear, 50),
      bgcolor=color.new(colFVGBear, 91),
      border_width=1, border_style=line.style_dotted)
    fvgArray.push(FVG.new(b, top, bottom, false, false, bar_index))

// Extend and fill FVGs
if showFVG and fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        FVG fvg = fvgArray.get(i)
        if not fvg.filled
            fvg.boxId.set_right(bar_index + 30)
            // Filled when price trades into the gap
            bool filled = fvg.isBull ? low <= fvg.top : high >= fvg.bottom
            if filled
                fvg.filled := true
                fvg.boxId.set_bgcolor(color.new(colNeutral, 93))
                fvg.boxId.set_border_color(color.new(colNeutral, 75))
                fvg.boxId.set_right(bar_index)
        if fvgArray.size() > 50
            FVG old = fvgArray.shift()
            old.boxId.delete()

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ LIQUIDITY SWEEPS ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// A liquidity sweep: wick breaks previous high/low pivot then price reverses inside
var float   sweepHigh     = ta.highest(high, sweepLookback)
var float   sweepLow      = ta.lowest(low,   sweepLookback)

// Bullish sweep: wick below recent low + close back above it
bool bullSweep = showLiqSweep and
  low < ta.lowest(low[1], sweepLookback) and
  close > ta.lowest(low[1], sweepLookback) and
  close > open

// Bearish sweep: wick above recent high + close back below
bool bearSweep = showLiqSweep and
  high > ta.highest(high[1], sweepLookback) and
  close < ta.highest(high[1], sweepLookback) and
  close < open

if bullSweep
    label.new(bar_index, low,
      text="⚡",
      style=label.style_label_up,
      color=color.new(colSweep, 0),
      textcolor=colSweep,
      size=labelSize,
      yloc=yloc.belowbar)

if bearSweep
    label.new(bar_index, high,
      text="⚡",
      style=label.style_label_down,
      color=color.new(colSweep, 0),
      textcolor=colSweep,
      size=labelSize,
      yloc=yloc.abovebar)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ EQUAL HIGHS / LOWS ═══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

eqlTol = atrVal * eqlTolerance

if showEQL and not na(ph) and not na(prevSwingHigh)
    if math.abs(ph - prevSwingHigh) <= eqlTol
        line.new(prevSwingHighIdx, prevSwingHigh, bar_index - pivotLen, ph,
          color=color.new(colEQL, 30), style=line.style_dotted, width=2)
        label.new(math.round(math.avg(prevSwingHighIdx, bar_index - pivotLen)), ph,
          "EQH", color=color.new(colEQL, 85), textcolor=colEQL,
          style=label.style_label_down, size=size.tiny)

if showEQL and not na(pl) and not na(prevSwingLow)
    if math.abs(pl - prevSwingLow) <= eqlTol
        line.new(prevSwingLowIdx, prevSwingLow, bar_index - pivotLen, pl,
          color=color.new(colEQL, 30), style=line.style_dotted, width=2)
        label.new(math.round(math.avg(prevSwingLowIdx, bar_index - pivotLen)), pl,
          "EQL", color=color.new(colEQL, 85), textcolor=colEQL,
          style=label.style_label_up, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SMC CONFLUENCE SCORING ══════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// Count active HPZ OBs nearby (within 2x ATR)
int nearBullHPZ = 0
int nearBearHPZ = 0
if obArray.size() > 0
    for i = 0 to obArray.size() - 1
        OrderBlock ob = obArray.get(i)
        if not ob.mitigated and ob.isHPZ
            if ob.isBull and close >= ob.bottom - atrVal * 2 and close <= ob.top + atrVal * 2
                nearBullHPZ += 1
            if not ob.isBull and close >= ob.bottom - atrVal * 2 and close <= ob.top + atrVal * 2
                nearBearHPZ += 1

// Count unfilled FVGs below (bull) / above (bear) as draw-on-liquidity
int fvgBullBelow = 0
int fvgBearAbove = 0
if fvgArray.size() > 0
    for i = 0 to fvgArray.size() - 1
        FVG fvg = fvgArray.get(i)
        if not fvg.filled
            if fvg.isBull and fvg.top < close
                fvgBullBelow += 1
            if not fvg.isBull and fvg.bottom > close
                fvgBearAbove += 1

calcBullSMC() =>
    float s = 0.0
    // MSB or BMS signal (core)
    s += isMSBBull ? 30.0 : isBMSBull ? 20.0 : 0.0
    // Liquidity sweep at lows (smart money accumulation)
    s += bullSweep ? 20.0 : 0.0
    // Near bullish HPZ OB
    s += nearBullHPZ >= 2 ? 18.0 : nearBullHPZ == 1 ? 10.0 : 0.0
    // FVG imbalance above as magnet
    s += fvgBearAbove >= 2 ? 10.0 : fvgBearAbove == 1 ? 5.0 : 0.0
    // Momentum Z-score confirmation
    s += momentumZ > 2.0 ? 12.0 : momentumZ > 1.0 ? 7.0 : momentumZ > 0.5 ? 3.0 : 0.0
    // Volume confirmation
    s += volRatio > 2.0 ? 8.0 : volRatio > 1.3 ? 5.0 : volRatio > 1.0 ? 2.0 : 0.0
    // Candle body
    s += close > open and bodyRatio > 0.6 ? 6.0 : close > open ? 3.0 : 0.0
    // Penalties
    s -= momentumZ < -1.0 ? 10.0 : 0.0
    s -= nearBearHPZ >= 2 ? 8.0 : 0.0
    math.max(0.0, math.min(100.0, s))

calcBearSMC() =>
    float s = 0.0
    s += isMSBBear ? 30.0 : isBMSBear ? 20.0 : 0.0
    s += bearSweep ? 20.0 : 0.0
    s += nearBearHPZ >= 2 ? 18.0 : nearBearHPZ == 1 ? 10.0 : 0.0
    s += fvgBullBelow >= 2 ? 10.0 : fvgBullBelow == 1 ? 5.0 : 0.0
    s += momentumZ < -2.0 ? 12.0 : momentumZ < -1.0 ? 7.0 : momentumZ < -0.5 ? 3.0 : 0.0
    s += volRatio > 2.0 ? 8.0 : volRatio > 1.3 ? 5.0 : volRatio > 1.0 ? 2.0 : 0.0
    s += close < open and bodyRatio > 0.6 ? 6.0 : close < open ? 3.0 : 0.0
    s -= momentumZ > 1.0 ? 10.0 : 0.0
    s -= nearBullHPZ >= 2 ? 8.0 : 0.0
    math.max(0.0, math.min(100.0, s))

bullSMC = smcEnabled ? calcBullSMC() : 0.0
bearSMC = smcEnabled ? calcBearSMC() : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SMC SIGNAL GENERATION ════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bullSignalRaw = smcEnabled and bullSMC >= minSMCScore and volOK and
  (isMSBBull or bullSweep)

bearSignalRaw = smcEnabled and bearSMC >= minSMCScore and volOK and
  (isMSBBear or bearSweep)

var int lastBullBar = -999
var int lastBearBar = -999
bullCoolOK = bar_index - lastBullBar >= cooldownBars
bearCoolOK = bar_index - lastBearBar >= cooldownBars

bullSignal = bullSignalRaw and bullCoolOK
bearSignal = bearSignalRaw and bearCoolOK

if bullSignal
    lastBullBar := bar_index
if bearSignal
    lastBearBar := bar_index

// Signal tier
bullTier = bullSMC >= 70 ? "S" : bullSMC >= 55 ? "A" : "B"
bearTier = bearSMC >= 70 ? "S" : bearSMC >= 55 ? "A" : "B"

// ── Entry Labels ──────────────────────────────────────────────────────────────
if bullSignal
    string confText = str.tostring(bullSMC, "#")
    string entryTxt = "▲ " + bullTier + "-SMC  (" + confText + ")"
    color  bgClr    = bullSMC >= 70 ? color.new(colBullBright, 5) :
      bullSMC >= 55 ? color.new(colBullPrimary, 10) :
      color.new(colBullDim, 15)
    label.new(bar_index, low,
      text=entryTxt, yloc=yloc.belowbar,
      color=bgClr, textcolor=colDashBg,
      size=labelSize, style=label.style_label_up)

if bearSignal
    string confText = str.tostring(bearSMC, "#")
    string entryTxt = "▼ " + bearTier + "-SMC  (" + confText + ")"
    color  bgClr    = bearSMC >= 70 ? color.new(colBearBright, 5) :
      bearSMC >= 55 ? color.new(colBearPrimary, 10) :
      color.new(colBearDim, 15)
    label.new(bar_index, high,
      text=entryTxt, yloc=yloc.abovebar,
      color=bgClr, textcolor=#ffffff,
      size=labelSize, style=label.style_label_down)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ SESSIONS ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

drawSession(bool show, string sessStr, color col, string name) =>
    var box   sBox   = na
    var label sLabel = na
    var float sHigh  = na
    var float sLow   = na
    inSession = not na(time(timeframe.period, sessStr))
    isStart   = inSession and not inSession[1]
    if show and inSession
        if isStart
            sHigh  := high
            sLow   := low
            sBox   := box.new(bar_index, sHigh, bar_index, sLow,
              border_color=col, border_style=line.style_dotted,
              bgcolor=color.new(col, 92))
            sLabel := label.new(bar_index, sHigh, name,
              style=label.style_none, textcolor=col, size=size.small, textalign=text.align_center)
        else
            sHigh := math.max(sHigh, high)
            sLow  := math.min(sLow, low)
            sBox.set_top(sHigh)
            sBox.set_bottom(sLow)
            sBox.set_right(bar_index)
            sLabel.set_xy(math.round(math.avg(sBox.get_left(), bar_index)), sHigh)
    float(na)

if showSessions
    drawSession(showLondon, londonSess, londonCol, "London")
    drawSession(showNY,     nySess,     nyCol,     "New York")
    drawSession(showTokyo,  tokyoSess,  tokyoCol,  "Tokyo")
    drawSession(showSydney, sydneySess, sydneyCol, "Sydney")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ DASHBOARD ════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// Count active HPZs
int activeHPZ = 0
int activeOBs = 0
if obArray.size() > 0
    for i = 0 to obArray.size() - 1
        OrderBlock ob = obArray.get(i)
        if not ob.mitigated
            activeOBs += 1
            if ob.isHPZ
                activeHPZ += 1

float reliability = totalOBs > 0 ? (totalMitigated / totalOBs) * 100.0 : 0.0

// Unfilled FVG count
int activeFVGs = 0
if fvgArray.size() > 0
    for i = 0 to fvgArray.size() - 1
        if not fvgArray.get(i).filled
            activeFVGs += 1

var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 30,
      bgcolor=color.new(colDashBg, 0),
      border_width=1,
      border_color=color.new(colNeutral, 70),
      frame_width=2,
      frame_color=color.new(colBullPrimary, 60))

if showDash and barstate.islast
    color secBg = color.new(#222222, 0)

    // ── HEADER ────────────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "AlphaX  S T R U C T U R E  F L O W",
      text_color=colBullPrimary, text_size=dashTextSize,
      bgcolor=color.new(#111111, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "PRO",
      text_color=color.new(colBullDim, 0), text_size=size.tiny,
      bgcolor=color.new(#111111, 0), text_halign=text.align_center)

    // ── SECTION: MARKET STRUCTURE ─────────────────────────────────────────────
    table.cell(dash, 0, 1, "─── MARKET STRUCTURE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    // MSB status
    msbTxt = isMSBBull ? "▲ BULL MSB" : isMSBBear ? "▼ BEAR MSB" : "— NONE"
    msbClr = isMSBBull ? colBullPrimary : isMSBBear ? colBearPrimary : colNeutral
    msbBg  = isMSBBull ? color.new(colBullPrimary, 88) : isMSBBear ? color.new(colBearPrimary, 88) : color.new(colDashBg, 0)
    table.cell(dash, 0, 2, "MSB STATUS", text_color=colTextLight, text_size=dashTextSize, bgcolor=msbBg)
    table.cell(dash, 1, 2, msbTxt, text_color=msbClr, text_size=dashTextSize, bgcolor=msbBg)

    // BMS
    bmsTxt = isBMSBull ? "▲ BULL BREAK" : isBMSBear ? "▼ BEAR BREAK" : "— NONE"
    bmsClr = isBMSBull ? colBullBright : isBMSBear ? colBearBright : colNeutral
    table.cell(dash, 0, 3, "BMS (BODY)", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 3, bmsTxt, text_color=bmsClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // Momentum Z
    zTxt = momentumZ > 2.0 ? "▲▲ STRONG" : momentumZ > 1.0 ? "▲ MODERATE" :
      momentumZ > 0.3 ? "▲ MILD" : momentumZ < -2.0 ? "▼▼ STRONG" :
      momentumZ < -1.0 ? "▼ MODERATE" : momentumZ < -0.3 ? "▼ MILD" : "— FLAT"
    zClr = momentumZ > 1.0 ? colBullBright : momentumZ > 0.3 ? colBullPrimary :
      momentumZ < -1.0 ? colBearBright : momentumZ < -0.3 ? colBearPrimary : colNeutralLight
    table.cell(dash, 0, 4, "MOMENTUM Z", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 4, zTxt + "  (" + str.tostring(momentumZ, "#.##") + ")", text_color=zClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ── SECTION: ORDER BLOCKS ─────────────────────────────────────────────────
    table.cell(dash, 0, 5, "─── ORDER BLOCKS ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    table.cell(dash, 0, 6, "ACTIVE OBs", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 6, str.tostring(activeOBs), text_color=colNeutralLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    hpzTxtDash = activeHPZ > 0 ? str.tostring(activeHPZ) + " ⬡ ACTIVE" : "— NONE"
    hpzClrDash = activeHPZ > 0 ? colBullBright : colNeutral
    hpzBgDash  = activeHPZ > 0 ? color.new(colBullPrimary, 92) : color.new(colDashBg, 0)
    table.cell(dash, 0, 7, "HPZ OBs", text_color=colTextLight, text_size=dashTextSize, bgcolor=hpzBgDash)
    table.cell(dash, 1, 7, hpzTxtDash, text_color=hpzClrDash, text_size=dashTextSize, bgcolor=hpzBgDash)

    relClr = reliability > 65 ? colBullPrimary : reliability > 40 ? colBullDim : colBearDim
    table.cell(dash, 0, 8, "OB RELIABILITY", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 8, str.tostring(reliability, "#.#") + "%", text_color=relClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ── SECTION: LIQUIDITY & IMBALANCE ────────────────────────────────────────
    table.cell(dash, 0, 9, "─── LIQUIDITY & IMBALANCE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 9, "", bgcolor=secBg)

    // Sweep status
    sweepTxt = bullSweep ? "⚡ BULL SWEEP" : bearSweep ? "⚡ BEAR SWEEP" : "— NONE"
    sweepClr = bullSweep or bearSweep ? colSweep : colNeutral
    sweepBg  = bullSweep or bearSweep ? color.new(colSweep, 88) : color.new(colDashBg, 0)
    table.cell(dash, 0, 10, "LIQ SWEEP", text_color=colTextLight, text_size=dashTextSize, bgcolor=sweepBg)
    table.cell(dash, 1, 10, sweepTxt, text_color=sweepClr, text_size=dashTextSize, bgcolor=sweepBg)

    // FVG
    fvgClr = activeFVGs > 3 ? colBullBright : activeFVGs > 0 ? colBullPrimary : colNeutral
    table.cell(dash, 0, 11, "OPEN FVGs", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 11, str.tostring(activeFVGs) + " unfilled", text_color=fvgClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // FVG draw on liquidity
    drawOnLiqTxt = fvgBearAbove > 0 and fvgBullBelow > 0 ? "↕ BOTH SIDES" :
      fvgBearAbove > 0 ? "▲ DRAW UP (" + str.tostring(fvgBearAbove) + ")" :
      fvgBullBelow > 0 ? "▼ DRAW DOWN (" + str.tostring(fvgBullBelow) + ")" : "— NONE"
    drawClr = fvgBearAbove > 0 and fvgBullBelow == 0 ? colBullDim :
      fvgBullBelow > 0 and fvgBearAbove == 0 ? colBearDim : colNeutralLight
    table.cell(dash, 0, 12, "DRAW ON LIQ", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 12, drawOnLiqTxt, text_color=drawClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ── SECTION: SMC CONFLUENCE ───────────────────────────────────────────────
    table.cell(dash, 0, 13, "─── SMC CONFLUENCE ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 13, "", bgcolor=secBg)

    // Bull SMC score
    bTier = bullSMC >= 70 ? "S-TIER" : bullSMC >= 55 ? "A-TIER" : bullSMC >= minSMCScore ? "B-TIER" : "LOW"
    bClr  = bullSMC >= 70 ? colBullBright : bullSMC >= 55 ? colBullPrimary : bullSMC >= minSMCScore ? colBullDim : colNeutral
    table.cell(dash, 0, 14, "BULL SMC SCORE", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 14, str.tostring(bullSMC, "#") + "%  [" + bTier + "]", text_color=bClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // Bear SMC score
    sTier = bearSMC >= 70 ? "S-TIER" : bearSMC >= 55 ? "A-TIER" : bearSMC >= minSMCScore ? "B-TIER" : "LOW"
    sClr  = bearSMC >= 70 ? colBearBright : bearSMC >= 55 ? colBearPrimary : bearSMC >= minSMCScore ? colBearDim : colNeutral
    table.cell(dash, 0, 15, "BEAR SMC SCORE", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 15, str.tostring(bearSMC, "#") + "%  [" + sTier + "]", text_color=sClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // Near HPZ confluence
    hpzConfTxt = nearBullHPZ > 0 and nearBearHPZ > 0 ? "⬡ BOTH SIDES" :
      nearBullHPZ > 0 ? "⬡ BULL ZONE (" + str.tostring(nearBullHPZ) + ")" :
      nearBearHPZ > 0 ? "⬡ BEAR ZONE (" + str.tostring(nearBearHPZ) + ")" : "— NONE"
    hpzConfClr = nearBullHPZ > nearBearHPZ ? colBullPrimary :
      nearBearHPZ > nearBullHPZ ? colBearPrimary : colNeutralLight
    table.cell(dash, 0, 16, "HPZ PROXIMITY", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 16, hpzConfTxt, text_color=hpzConfClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ── SECTION: MARKET CONDITIONS ────────────────────────────────────────────
    table.cell(dash, 0, 17, "─── MARKET CONDITIONS ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 17, "", bgcolor=secBg)

    // Volume
    volTxt = volRatio > 2.0 ? "SPIKE  ×" + str.tostring(volRatio, "#.##") :
      volRatio > 1.3 ? "HIGH  ×" + str.tostring(volRatio, "#.##") :
      volRatio > 0.7 ? "NORMAL  ×" + str.tostring(volRatio, "#.##") : "DRY  ×" + str.tostring(volRatio, "#.##")
    volClr = volRatio > 2.0 ? colBullBright : volRatio > 1.3 ? colBullPrimary :
      volRatio > 0.7 ? colNeutralLight : colNeutral
    table.cell(dash, 0, 18, "VOLUME", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 18, volTxt, text_color=volClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ATR
    table.cell(dash, 0, 19, "ATR (14)", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 19, str.tostring(atrVal, format.mintick), text_color=colNeutralLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // Body Ratio
    bodyTxt = bodyRatio > 0.7 ? "STRONG" : bodyRatio > 0.4 ? "MODERATE" : "WEAK / INDECISION"
    bodyClr = bodyRatio > 0.7 ? colBullPrimary : bodyRatio > 0.4 ? colNeutralLight : colBearDim
    table.cell(dash, 0, 20, "CANDLE BODY", text_color=colTextLight, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))
    table.cell(dash, 1, 20, bodyTxt + "  (" + str.tostring(bodyRatio * 100, "#") + "%)", text_color=bodyClr, text_size=dashTextSize, bgcolor=color.new(colDashBg, 0))

    // ── SECTION: SIGNAL ───────────────────────────────────────────────────────
    table.cell(dash, 0, 21, "─── ACTIVE SIGNAL ───",
      text_color=color.new(colNeutral, 20), text_size=size.tiny,
      bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 21, "", bgcolor=secBg)

    sigTxt = bullSignal ? "▲ LONG  (" + bullTier + ")" : bearSignal ? "▼ SHORT  (" + bearTier + ")" : "— NONE"
    sigClr = bullSignal ? colBullPrimary : bearSignal ? colBearPrimary : colNeutral
    sigBg  = bullSignal ? color.new(colBullPrimary, 85) : bearSignal ? color.new(colBearPrimary, 85) : color.new(colDashBg, 0)
    table.cell(dash, 0, 22, "SIGNAL", text_color=colTextLight, text_size=dashTextSize, bgcolor=sigBg)
    table.cell(dash, 1, 22, sigTxt, text_color=sigClr, text_size=dashTextSize, bgcolor=sigBg)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ALERTS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// MSB Alerts
alertcondition(isMSBBull,
  title="Bull Market Structure Break",
  message="[AlphaX SFP] BULL MSB — {{ticker}} {{interval}} @ {{close}}")
alertcondition(isMSBBear,
  title="Bear Market Structure Break",
  message="[AlphaX SFP] BEAR MSB — {{ticker}} {{interval}} @ {{close}}")

// BMS Alerts
alertcondition(isBMSBull,
  title="Bull Break of Market Structure (Body Close)",
  message="[AlphaX SFP] BULL BMS (body close) — {{ticker}} {{interval}} @ {{close}}")
alertcondition(isBMSBear,
  title="Bear Break of Market Structure (Body Close)",
  message="[AlphaX SFP] BEAR BMS (body close) — {{ticker}} {{interval}} @ {{close}}")

// SMC Confluence Signals
alertcondition(bullSignal and bullSMC >= 70,
  title="S-Tier Bull SMC Signal",
  message="[AlphaX SFP] S-TIER BULL SMC — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullSignal and bullSMC >= 55 and bullSMC < 70,
  title="A-Tier Bull SMC Signal",
  message="[AlphaX SFP] A-TIER BULL SMC — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullSignal and bullSMC < 55,
  title="B-Tier Bull SMC Signal",
  message="[AlphaX SFP] B-TIER BULL SMC — {{ticker}} {{interval}} @ {{close}}")

alertcondition(bearSignal and bearSMC >= 70,
  title="S-Tier Bear SMC Signal",
  message="[AlphaX SFP] S-TIER BEAR SMC — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearSignal and bearSMC >= 55 and bearSMC < 70,
  title="A-Tier Bear SMC Signal",
  message="[AlphaX SFP] A-TIER BEAR SMC — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearSignal and bearSMC < 55,
  title="B-Tier Bear SMC Signal",
  message="[AlphaX SFP] B-TIER BEAR SMC — {{ticker}} {{interval}} @ {{close}}")

alertcondition(bullSignal or bearSignal,
  title="Any SMC Signal",
  message="[AlphaX SFP] SMC signal — {{ticker}} {{interval}} @ {{close}}")

// Liquidity Sweep Alerts
alertcondition(bullSweep,
  title="Bull Liquidity Sweep",
  message="[AlphaX SFP] BULL liquidity sweep — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearSweep,
  title="Bear Liquidity Sweep",
  message="[AlphaX SFP] BEAR liquidity sweep — {{ticker}} {{interval}} @ {{close}}")

// FVG Alerts
alertcondition(bullFVG,
  title="Bullish Fair Value Gap",
  message="[AlphaX SFP] Bull FVG formed — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearFVG,
  title="Bearish Fair Value Gap",
  message="[AlphaX SFP] Bear FVG formed — {{ticker}} {{interval}} @ {{close}}")

// HPZ Alert
alertcondition(isMSBBull and nearBullHPZ > 0,
  title="Bull MSB + HPZ Confluence",
  message="[AlphaX SFP] Bull MSB at HPZ zone — {{ticker}} {{interval}} @ {{close}}")
alertcondition(isMSBBear and nearBearHPZ > 0,
  title="Bear MSB + HPZ Confluence",
  message="[AlphaX SFP] Bear MSB at HPZ zone — {{ticker}} {{interval}} @ {{close}}")
````
