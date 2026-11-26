# Shark Hunt | Anonycryptous

- url: https://www.tradingview.com/script/SRmvlBub-Shark-Hunt-Anonycryptous/
- type: indicator
- pine_id: PUB;013613bb1350475b8fad989030157685
- version: 1.0

## Description

Shark Hunt | Anonycryptous
Description & user manual
(Some chart snapshots below)

Why makes this indicator different?
Most liquidity indicators show you levels. They draw a box where a swing high or low formed and wait for price to return. They do not tell you whether the return matters. They do not filter what is noise from what is a genuine institutional event. They do not confirm whether the move that touched the level was a stop hunt or just a graze. They show you where. Not what.
Shark Hunt works differently.
It does not just detect liquidity zones. It hunts what happens at them — mechanically, bar by bar, through a multi-layer confirmation engine that evaluates wick penetration, volume, rejection strength, and optional pattern confluence before a signal fires. Every condition has a purpose. Every filter reflects something that institutional order flow actually leaves behind.
Most traders can look at a chart in hindsight and spot a liquidity sweep. They see the wick, they see the reversal, they understand what happened. The challenge is identifying it as it forms, before the move is over. That is what Shark Hunt is built to do.

And then there is the Failure Entry engine.
Not every meaningful institutional move starts at a marked zone. Sometimes price sweeps a structural pivot mid-chart — no zone, no prior markup — and reverses sharply. These are swing failure patterns: a wick through a recent high or low, a close back inside, and the market moving the other way. Shark Hunt includes a complete standalone engine for detecting and trading these setups, with its own signal system, trade block, and performance tracking. It is an indicator within an indicator. When you enable it, the entire color scheme shifts to make the mode change unmistakable.

Most indicators are built for one idea. Shark Hunt is built for two ways of reading the same market — and it tells you clearly which mode you are in.

Important notice
Shark Hunt generates trading signals based on pattern detection and volume analysis.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Shark Hunt is a liquidity zone detection and sweep confirmation indicator built around the behavior of institutional participants — how they build positions, how they run stops, and how that activity shows up on a chart.

What it includes:
- Impulse-scored liquidity zone detection at swing highs and lows
- Three-tier zone significance: scalp, intermediate, and major
- Multi-layer sweep confirmation: wick penetration, volume, rejection, and pattern gates
- Zone flip logic: broken support becomes resistance and vice versa
- Zone hold statistics with percentage display and liquidity value per zone
- Five price pattern detections: imbalances, absorption bars, price failures, level break retests, and wick traps
- Trade block visualization with configurable RR ratio, SL mode, and width
- Failure Entry engine: standalone SFP signal system with independent settings and trade blocks
- Sweep and failure mode color switching: fluor green/red for zone mode, fluor cyan/red for failure mode
- Neon glow rendering for both candles and zones: independently configurable
- Live dashboard showing active mode, zones, trade statistics, and PnL in R
- Alerts for zone sweep longs, zone sweep shorts, failure longs, and failure shorts

2. How zones are built
Shark Hunt detects liquidity pools at confirmed swing highs and lows using a pivot-based engine. Every zone is scored at the moment of formation using a composite impulse quality score — a weighted combination of body strength, volume relative to average, and bar range relative to ATR. Higher scores mean the move away from the zone was more decisive. When two zones form too close together, the weaker one is removed. Only the more significant level survives.
Zone significance is configurable in three modes:
-Scalp
Short pivot lookback. More zones formed, closer to current price. Suited for fast timeframes and intraday scalp setups.
-Intermediate
Balanced detection. A practical default across most instruments and timeframes.
-Major
Extended pivot lookback. Only the most significant structural levels qualify. Fewer zones, higher conviction per zone.

Each zone extends to the right in real time. A stats label shows the percentage of touches where price held without sweeping — the hold rate — and the estimated liquidity value at the formation bar, calculated as volume multiplied by price. These two numbers tell you how historically respected a zone is and how much institutional interest was present when it formed.
When price closes decisively through a zone, the zone flip logic converts it to the opposite side. A broken demand zone becomes supply. A broken supply zone becomes demand. This mirrors how smart money re-uses levels.

3. Sweep confirmation
A sweep fires only when all enabled conditions are satisfied on the same bar at close.

Wick penetration
The wick must break through the zone boundary by at least a configurable percentage of price. This filters grazes from genuine stop hunts. At 0.05%, small but intentional penetrations qualify. At 0.2% and above, only decisive spikes are counted.

Volume confirmation
The sweep bar must have volume at or above a configurable multiple of the rolling average. Institutional sweeps require size to move price and collect stops. A sweep on below-average volume is usually noise. This filter is toggleable.

Wick rejection
The wick that swept the zone must represent a minimum percentage of the bar's total range. A high rejection percentage means the bar closed far from its sweep extreme — price was pushed back hard. A low percentage means price drifted through and kept going. This filter is toggleable.

Pattern confirmation gates
Three optional gates can be added on top of the base sweep conditions:
- Require Price Failure (SFP): the sweep bar must also close back inside a recent pivot. Stop hunt confirmed by structure.
- Require Wick Trap: the sweeping wick must be at least twice the body size and larger than half an ATR. Pin-bar quality required.
- Require Absorption Bar: the sweep bar must fully engulf the previous candle. One-sided institutional commitment on the sweep itself.
Each gate is independent. Any combination can be active simultaneously. When all three are off, the base filters apply. When one or more are on, they stack as AND conditions — all must pass.
A cooldown setting prevents duplicate signals on the same level by requiring a minimum number of bars between confirmed sweeps.
When a sweep confirms, the zone is marked as swept and fades. A trade block is drawn showing the SL zone and TP zone based on the configured stop loss mode and RR ratio.

4. Price patterns
Five independent price pattern detections run continuously alongside the zone engine. Each can be toggled on or off.
-Price imbalances
Three-candle gaps where price moved too fast for two-sided trading. The gap between the first and third candle is visible as a small filled box. These areas act as magnets — price tends to return. A bull imbalance forms when a bullish candle leaves a gap above. A bear imbalance forms the same way in the opposite direction.
-Absorption bars
A candle that fully engulfs the previous candle in body. The current bar opened inside the prior bar's body and closed beyond it on the opposite side. This shows one side overpowering the other in a single bar — a sign of directional commitment. Marked with a small dot above or below the bar.
-Price failures
A bar that breaks a recent swing pivot with its wick but closes back inside. The market attempted a breakout, ran the stops beyond the pivot, then reversed. This is the mechanical signature of an institutional stop hunt at a structural level. Marked with a clean "F" label in bull or bear color.
-Level break and retest
When price closes through a recent pivot level and then returns to test it from the other side, a retest marker fires. Broken resistance retested as support, and vice versa. The cross marker appears at the retest bar.
-Wick traps
Candles with a wick at least twice the body size and larger than half an ATR. These mark areas of strong rejection. When a wick trap appears at or near a zone, it adds weight to the setup. Marked with a directional arrow.

5. Trade block
When a zone sweep confirms, a trade block is drawn from the signal bar forward. It shows the SL zone in red and the TP zone above or below entry.
Two stop loss modes are available:
-Zone mode
The stop is placed at the zone boundary plus a configurable ATR buffer. Consistent across setups — the SL is anchored to the structural level that defined the zone.

-Wick mode
The stop is placed at the deepest point of the sweep wick plus a configurable ATR buffer. Tighter, and closer to the actual sweep extreme. Can vary significantly bar to bar depending on wick size.
The RR ratio scales the TP distance as a multiple of the SL distance. At 1.0, TP equals SL distance — a 1:1 setup. At 2.0, TP is twice the SL distance. The trade block width in bars is configurable.
The backtest engine runs alongside the live chart. Every confirmed signal is tracked. When TP or SL is reached, the result is recorded as positive or negative R and accumulated in the dashboard.

6. Dashboard
The dashboard is displayed in a configurable position at tiny, small, or normal size.
It shows:
- Active mode: Sweep — on or off. Failure — on or off. Immediately visible at a glance.
- Depth: the current zone significance setting.
- Bull liquidity: number of active bull zones, with fresh zone count.
- Bear liquidity: same for bear zones.
- ATR: current ATR value for the active calculation period.
- Trades, longs, shorts, wins, losses, win rate: cumulative signal statistics.
- Total PnL in R: cumulative result across all signals.
- Expected value in R: average result per trade.

Mode colors are active throughout. In zone sweep mode, bull elements appear in fluor green. In failure entry mode, everything bull switches to fluor cyan. Bear elements remain in fluor red in both modes. The mode switch is visible across every element on the chart — zones, candles, markers, trade blocks, and the dashboard simultaneously.

7. Neon glow
Two independent glow systems are available under the Visuals section.
Neon glow candles
Three stacked plotcandle layers render the candles in fluor color with a soft outer glow. Body transparency and wick and border transparency are separately adjustable — softer body, harder wicks gives the most readable result. Two glow layers control the diffuse outer glow and the inner primary glow independently.
For best results: open chart settings, go to the Style tab, and set the default candle body, border, and wick to fully transparent. This removes the standard TradingView candle rendering and lets only the glow candles show.
Neon glow zones
Four stacked box layers per zone produce a layered neon glow from the zone boundary outward. A single Zone Glow Strength slider controls all layers simultaneously — lower values produce a more intense neon effect, higher values produce a softer ambient glow.
Both systems work in both modes. When failure entry mode is active, the glow shifts to fluor cyan for all bull elements.

8. ⚡ The Failure Entry engine — the Bonus 🦈
Zone sweeps are the core of Shark Hunt. But not every institutional move starts at a marked level.
Sometimes price sweeps a structural pivot that has no zone drawn on it — a recent swing high or low that formed mid-session, between established zones. The move is decisive: a wick beyond the pivot, a close back inside, and price accelerating in the opposite direction. These are swing failure patterns. They are one of the cleanest institutional signatures available — a stop hunt at a structural level, confirmed by the bar's own price action.
The Failure Entry engine is a fully independent system inside Shark Hunt, built specifically to detect and trade these setups.
When Failure Entry mode is enabled, the zone sweep signal system is suspended. Zones remain on the chart as structural context — they often align with logical TP levels for failure trades. But entries come only from the failure engine.
The failure engine uses its own pivot lookback, separate from the zone detection engine. A dedicated wick size filter measured in ATR is the primary quality gate — it controls how large the failure wick must be relative to current volatility. Small values allow minor structural failures. Larger values require significant spike reversals. This is the primary lever for tightening or loosening signal quality.
A separate wick rejection percentage filter ensures the sweep bar closed convincingly away from its extreme. Volume confirmation with its own multiplier can be applied independently. A cooldown prevents duplicate signals on the same pivot.
The failure engine has its own trade block: fluor cyan for TP, fluor red for SL. The SL can be placed at the wick tip or at the pivot level itself, each with its own ATR buffer. The RR ratio and block width are independently configurable.
Performance is tracked separately. The failure PnL, win rate, and expected value accumulate in their own records and are reflected in the total dashboard figures. Every failure trade contributes to the overall session result.
Enabling failure entry mode changes the entire visual environment. All bull elements — zones, candles, markers, trade blocks — switch from fluor green to fluor cyan. The mode status rows in the dashboard confirm what is active at a glance. Switching modes is one toggle. The chart responds immediately across every element.
The failure engine is not a replacement for the zone sweep system. It is a complementary tool for catching institutional moves that do not begin at a pre-mapped level. Used in combination with the zone context still visible on the chart, it gives Shark Hunt coverage of both types of setup — the anticipated sweep at a known level, and the opportunistic reversal at an unmarked pivot.

9. Settings reference
9.1 Zone detection
- Pivot lookback: bars each side to confirm a swing high or low
- Zone significance: scalp, intermediate, or major
- Max active zones per side: upper limit on tracked zones
- Zone ATR width: zone height as a multiple of ATR
- Min zone separation (ATR): minimum distance between zones of the same type
- Show fresh zones only: hide swept zones or keep them faded
- Enable zone flip: convert broken zones to the opposite side

9.2 Sweep confirmation
- Min wick penetration (%): minimum wick break through zone boundary
- Volume confirmation: toggle volume filter on or off
- Min volume multiple: minimum sweep bar volume relative to average
- Volume average period: rolling volume baseline length
- Wick rejection filter: toggle wick size filter on or off
- Min wick rejection (%): minimum wick as percentage of bar range
- Cooldown bars between sweeps: minimum gap between signals
- Require price failure (SFP): optional pattern gate
- Require wick trap: optional pattern gate
- Require absorption bar: optional pattern gate

9.3 Price patterns
- Show price imbalances
- Show absorption bars
- Show price failures
- Show level breaks and retests
- Show wick traps

9.4 Trade block
- Show trade block on sweep
- RR ratio
- SL mode: zone or wick
- SL buffer (ATR)
- Trade block width (bars)

9.5 Visuals
- Bull and bear liquidity zone transparency
- Show zone stats label
- Show % hold
- Show liquidity value
- Zone label size
- Min % hold to show zone
- Enable neon glow candles
- Body transparency (soft)
- Wick and border transparency (hard)
- Primary glow strength
- Secondary glow strength (diffuse)
- Enable neon glow zones
- Zone glow strength

9.6 Failure entry
- Enable failure entry mode
- Pivot lookback
- Min failure wick (ATR)
- Min wick rejection (%)
- Volume confirmation
- Min volume multiple
- Cooldown bars between failures
- SL mode: wick or pivot
- SL buffer (ATR)
- RR ratio
- Trade block width (bars)
- Show trade block on failure

9.7 Dashboard
- Show dashboard
- Position: top left, top right, bottom left, bottom right
- Size: tiny, small, normal

10. How to use
10.1 Initial setup
1. Set zone significance to match your timeframe. Major works well on 3m and 15m as a starting point.
2. Enable the filters you want active. Volume confirmation and wick rejection are on by default — these are the minimum recommended filters.
3. Set your RR ratio. The default of 1.0 is conservative. Adjust based on your own risk management rules.
4. Decide whether to use zone mode or failure entry mode. Both can be tested and compared using the dashboard statistics.
5. If you want neon glow rendering, set default chart candles to transparent first, then enable the glow toggles.

10.2 Reading the chart
Zones in fluor green are bull liquidity pools — unfilled stop clusters below recent swing lows. Zones in fluor red are bear liquidity pools above swing highs. The opacity and label show how historically respected each zone is.
When price approaches a zone, watch the sweep confirmation criteria. A qualifying bar at close triggers the signal and draws the trade block.
"F" labels mark price failure patterns. When an F appears near a zone boundary, it strengthens the setup. A price failure at a liquidity zone is the clearest confluence available in Shark Hunt — a structural stop hunt confirmed by both the zone engine and the failure pattern simultaneously.
Imbalance boxes, absorption dots, retest crosses, and wick trap arrows all provide additional context. None of them are trade signals by themselves. They are confluence indicators — the more of them align with a zone sweep, the higher the contextual quality of the setup.

10.3 Illustrative bull scenario
Educational example only. Not a trading recommendation.
A swing low forms with strong impulse score. A bull liquidity zone is drawn below it, showing 100% hold and a high liquidity value. Several bars later, price dips into the zone with a sharp wick on elevated volume. The wick is larger than the body, covering more than 25% of the bar range. The bar closes above the zone boundary. A fluor green triangle fires below the bar. The trade block appears showing the TP zone above and the SL zone below. An "F" label also appears on the same bar — the zone sweep and the price failure both confirmed simultaneously.

10.4 Illustrative bear scenario
Educational example only. Not a trading recommendation.
Price rallies into a bear liquidity zone marked from a prior swing high. The approach candle is an absorption bar — a dot appears above it. On the next bar, a sharp spike above the zone on high volume forms a wick that covers more than 25% of the bar range, closing back below the zone top. The sweep confirms. A fluor red triangle fires above the bar. The trade block drops from entry to the TP target below. A wick trap arrow also marks the same bar — strong institutional rejection at a known supply level.

10.5 Using failure entry mode
Enable failure entry mode when you want to trade swing failure patterns without requiring a pre-mapped zone.
The zone boundaries remain on the chart. Use them as context. A failure trade that targets a nearby bull or bear zone as its TP has structural justification for the exit level.
The min failure wick (ATR) setting is the primary quality control. Start at 0.4. If you see too many minor failures firing, raise it. If the engine is missing moves you can see visually, lower it.
The dashboard will show failure-specific statistics. Compare the failure win rate and expected value to the zone sweep statistics. Over time, this data tells you which setup type performs better on your instrument and timeframe.

10.6 Timeframe guide
- 1m–2m: scalp depth, loose filters, high zone count, failure mode useful
- 3m–5m: recommended default settings, both engines perform well
- 15m: major depth, tighter wick penetration, fewer but higher quality setups
- 30m and above: increase pivot lookback for both zone and failure engines

11. Tip
The zone hold percentage is information. A zone with 0% hold has been swept every time price visited it. That is a weak zone — it may not hold the next time either. A zone at 95% hold has defended itself repeatedly. That is a level with a track record.
Volume confirmation is your noise filter. On most instruments, genuine institutional sweeps show up on volume. A sweep on below-average volume is usually a retail move or a thin-market spike. Keep volume confirmation on unless your instrument has unreliable volume data.
The pattern confirmation gates stack. Requiring price failure, wick trap, and absorption simultaneously will produce very few signals — but the ones that fire will have three independent confirmations in addition to the base sweep conditions. Use the gates selectively based on how many signals your timeframe normally generates.
Zone glow and candle glow are independent. You can use zone glow without candle glow, or both together. The neon rendering is a visual choice — it does not affect signal logic.
Failure mode changes everything visually. When you enable it, the entire chart shifts to fluor cyan for bull elements. This is intentional — it makes the mode switch obvious. There is no ambiguity about which engine is active.
The dashboard expected value is the most useful long-term metric. A positive expected value means the average signal generates profit over time. A negative value means the current settings lose on average even if the win rate looks reasonable. Track it across sessions to validate your configuration.

Chart snapshots:

[image]https://www.tradingview.com/x/w4BYZabj/[/image]

[image]https://www.tradingview.com/x/CQzxGymq/[/image]

[image]https://www.tradingview.com/x/h7tH3DU9/[/image]

[image]https://www.tradingview.com/x/3ROz8hbH/[/image]

[image]https://www.tradingview.com/x/W2jAqW89/[/image]

[image]https://www.tradingview.com/x/zjuZhH4a/[/image]

12. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Anonycryptous

//@version=6
indicator("Shark Hunt | Anonycryptous", shorttitle="Shark Hunt | Anon",
     overlay=true, max_boxes_count=500, max_labels_count=300, max_lines_count=100)

// ═══════════════════════════════════════════════════════════════════════════════
// Shark Hunt v1.0 | Anonycryptous
// Institutional liquidity pool zones with multi-layer sweep confirmation
// + Failure Entry Engine — standalone SFP signal system
// ═══════════════════════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────────────────────
// GROUPS
// ───────────────────────────────────────────────────────────────────────────────
G_ZONE  = "🦈 Zone Detection"
G_SWEEP = "🎯 Sweep Confirmation"
G_PAT   = "📐 Price Patterns"
G_TRADE = "📦 Trade Block"
G_VIS   = "🎨 Visuals"
G_FAIL  = "⚡ Failure Entry"
G_DASH  = "🖥 Dashboard"

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — ZONE DETECTION
// ───────────────────────────────────────────────────────────────────────────────
i_pivLen    = input.int(10,    "Pivot Lookback",
     minval=3, maxval=50, group=G_ZONE,
     tooltip="Bars each side to confirm a swing high/low. Higher = fewer but more significant zones.")
i_depth     = input.string("Major", "Zone Significance",
     options=["Scalp","Intermediate","Major"], group=G_ZONE,
     tooltip="Scalp = short-term pivots, frequent zones. Intermediate = balanced. Major = only the most significant structural levels.")
i_maxZones  = input.int(10,   "Max Active Zones Per Side",
     minval=2, maxval=20, group=G_ZONE,
     tooltip="Maximum number of bullish and bearish liquidity zones tracked simultaneously. When this limit is reached, the oldest zone is removed to make room for new ones. Higher values show more historical context but can clutter the chart. Recommended: 5–10.")
i_zoneWidth = input.float(0.4, "Zone ATR Width",
     minval=0.1, maxval=2.0, step=0.1, group=G_ZONE,
     tooltip="Controls how tall each zone box is, expressed as a multiple of ATR.\n\nSmaller (0.1–0.3): Tight zones, very precise entry levels, fewer zone touches before a sweep is confirmed.\nLarger (0.5–1.0): Wide zones, more price tolerance inside the zone, better for volatile markets or higher timeframes.\n\nIf you see price bouncing just outside your zones, increase this value. If zones are too big and catching too much noise, decrease it.")
i_minDist   = input.float(1.5, "Min Zone Separation (ATR)",
     minval=0.5, maxval=10.0, step=0.5, group=G_ZONE,
     tooltip="Minimum distance between two zones of the same type, expressed as ATR multiples. If a new zone forms too close to an existing one, only the stronger zone (higher impulse score) is kept.\n\nSmaller (0.5–1.0): Allows closely spaced zones — useful on choppy markets or lower timeframes where levels cluster.\nLarger (3.0–5.0): Forces significant price separation between zones — keeps only the most distinct structural levels.\n\nIf you see many overlapping zones in the same price area, increase this value.")
i_showFresh = input.bool(false, "Show Fresh Zones Only",
     group=G_ZONE,
     tooltip="When on: zones disappear after being swept. Chart stays clean — only untouched liquidity pools are visible.\nWhen off: swept zones remain on chart in a faded state, useful for reference or to see how many zones have already been tested.")
i_zoneFlip  = input.bool(true, "Enable Zone Flip",
     group=G_ZONE,
     tooltip="When price breaks decisively through a liquidity pool (closes below it with strong body), the zone flips to supply. When price breaks through a liquidity pool (closes above it), it flips to demand.\n\nThis mirrors institutional behavior — broken support becomes resistance, broken resistance becomes support.\nFlipped zones are shown in the opposite color and can trigger new sweep entries.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — SWEEP CONFIRMATION
// ───────────────────────────────────────────────────────────────────────────────
i_minWickPct = input.float(0.05, "Min Wick Penetration (%)",
     minval=0.0, maxval=2.0, step=0.01, group=G_SWEEP,
     tooltip="The wick must break through the zone boundary by at least this percentage of the zone price before a sweep is confirmed.\n\n0.0% = any wick into the zone qualifies (most signals, more noise).\n0.05% = small but meaningful penetration required.\n0.2%+ = only decisive stop hunts qualify (fewer signals, higher quality).\n\nIncrease this if you see too many weak grazes being counted as sweeps.")
i_useVol    = input.bool(true,  "Volume Confirmation",
     group=G_SWEEP,
     tooltip="When on: the sweep candle must have above-average volume to be confirmed.\n\nInstitutional sweeps leave a volume footprint — they need size to run the stops. A sweep on low volume is often noise.\nWhen off: volume is ignored, more signals but lower quality.")
i_volMult   = input.float(1.4,  "Min Volume Multiple",
     minval=0.5, maxval=5.0, step=0.1, group=G_SWEEP,
     tooltip="The sweep bar volume must be at least this multiple of the rolling average volume.\n\n1.0 = any above-average volume qualifies.\n1.5 = 50% above average — moderate filter.\n2.0+ = strong volume spike required — high confidence sweeps only.\n\nOnly active when Volume Confirmation is enabled.")
i_volLen    = input.int(20, "Volume Average Period",
     minval=5, group=G_SWEEP,
     tooltip="Number of bars used to calculate the average volume baseline. The sweep bar volume is compared against this average.\n\nLower (10): More reactive to recent volume changes.\nHigher (50): Stable baseline, less sensitive to short-term spikes.")
i_useWick   = input.bool(true,  "Wick Rejection Filter",
     group=G_SWEEP,
     tooltip="When on: the sweep bar must show strong wick rejection — the wick that swept the zone must be significantly larger than the candle body.\n\nThis confirms that price was rejected back into the zone, not just passing through. A sweep with strong rejection is the clearest sign of institutional absorption.")
i_wickMin   = input.float(25.0, "Min Wick Rejection (%)",
     minval=10.0, maxval=90.0, step=5.0, group=G_SWEEP,
     tooltip="Minimum percentage of the total bar range (high to low) that must consist of wick.\n\n40% = moderate rejection required — wick must be larger than body.\n60% = strong rejection — most of the bar must be wick.\n80% = very tight body, near-perfect pin bar.\n\nOnly active when Wick Rejection Filter is enabled.")
i_cooldown  = input.int(5,     "Cooldown Bars Between Sweeps",
     minval=0, maxval=50, group=G_SWEEP,
     tooltip="Minimum bars between two sweep signals. Prevents duplicate entries on same level.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — TRADE BLOCK (Zone Sweep)
// ───────────────────────────────────────────────────────────────────────────────
i_showTrade = input.bool(true,  "Show Trade Block on Sweep", group=G_TRADE)
i_rrRatio   = input.float(1.0,  "RR Ratio",
     minval=0.5, maxval=10.0, step=0.5, group=G_TRADE,
     tooltip="Reward-to-risk ratio. TP = entry + (SL distance × RR). TP1 always 1:1, TP2 at this ratio.")
i_slMode    = input.string("Zone", "SL Mode",
     options=["Zone", "Wick"], group=G_TRADE,
     tooltip="Zone: SL placed at zone boundary + ATR buffer. Consistent and predictable — TP scales proportionally.\nWick: SL placed at the deepest point of the sweep wick + ATR buffer. Tighter but unpredictable on spike bars.")
i_slBuffer  = input.float(0.4,  "SL Buffer (ATR)",
     minval=0.0, maxval=2.0, step=0.1, group=G_TRADE,
     tooltip="Additional ATR buffer added to the SL beyond the zone boundary (Zone mode) or sweep wick (Wick mode).")
i_tradeW    = input.int(25,    "Trade Block Width (bars)",
     minval=5, maxval=100, group=G_TRADE)


// ── Pattern Confirmation ──────────────────────────────────────────────────────
i_reqFailure    = input.bool(false, "Require Price Failure (SFP)",
     group=G_SWEEP,
     tooltip="When on: sweep only fires if the sweep bar also shows a Price Failure — wick through a recent pivot but close back inside. Zone sweep + SFP = institutional stop hunt followed by reversal. Strongest pattern gate. Off = no requirement.")
i_reqWickTrap   = input.bool(false, "Require Wick Trap",
     group=G_SWEEP,
     tooltip="When on: sweep bar must have a wick at least 2× the body size and larger than 0.5× ATR. Stricter than the Wick Rejection filter — requires a clear pin-bar structure on the sweep candle. Off = no requirement.")
i_reqAbsorption = input.bool(false, "Require Absorption Bar",
     group=G_SWEEP,
     tooltip="When on: sweep bar must fully engulf the previous candle (bullish engulf for longs, bearish engulf for shorts). Confirms one-sided institutional commitment on the sweep candle. Off = no requirement.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — PRICE PATTERNS
// ───────────────────────────────────────────────────────────────────────────────
i_showImbalance  = input.bool(true,  "Show Price Imbalances",
     group=G_PAT,
     tooltip="Marks gaps in price where candles moved too fast to fill both sides. These areas act as magnets — price tends to return to fill them. A bull imbalance forms when the low of bar N is above the high of bar N-2 on a bullish move.")
i_showAbsorption = input.bool(true,  "Show Absorption Bars",
     group=G_PAT,
     tooltip="Marks bars where price fully engulfs the previous candle. This shows one side completely overpowering the other — a sign of directional commitment and often the start of a move.")
i_showPriceFailure = input.bool(true, "Show Price Failures",
     group=G_PAT,
     tooltip="Marks bars where price breaks a recent swing level with a wick but closes back inside — a failed breakout. The market tried to push through, ran the stops, then reversed. These are high-probability reversal signals, especially when they occur at a liquidity zone.")
i_showLevelBreak = input.bool(true,  "Show Level Breaks & Retests",
     group=G_PAT,
     tooltip="Marks when price closes through a recent swing level and then comes back to retest it from the other side. The retest is the entry point — broken resistance becomes support and vice versa.")
i_showWickTrap   = input.bool(true,  "Show Wick Traps",
     group=G_PAT,
     tooltip="Marks candles with an unusually long wick relative to the body — at least 2× the body size and above average range. These show areas where price was aggressively rejected. When a wick trap appears at a liquidity zone, it strengthens the zone signal.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — FAILURE ENTRY ENGINE
// ───────────────────────────────────────────────────────────────────────────────
i_failMode    = input.bool(false, "Enable Failure Entry Mode",
     group=G_FAIL,
     tooltip="Standalone SFP engine — fires signals purely on swing failure patterns without requiring a zone sweep.\n\nWhen ON: zone sweep signals are disabled. Zones remain visible as structural context and potential TP targets.\nWhen OFF: normal zone sweep mode, failure engine is inactive.")
i_failPivLen  = input.int(10, "Pivot Lookback",
     minval=3, maxval=50, group=G_FAIL,
     tooltip="Bars each side used to identify swing highs and lows for failure detection.\n\nLower (5–8): More reactive, catches shorter-term failures. More signals, more noise on lower timeframes.\nHigher (15–20): Only significant structural pivots qualify. Fewer but cleaner signals.\n\nRecommended: 10 for intraday (1–5m), 15–20 for higher timeframes.")
i_failWickATR = input.float(0.4, "Min Failure Wick (ATR)",
     minval=0.05, maxval=3.0, step=0.05, group=G_FAIL,
     tooltip="The wick that breaks through the pivot must be at least this multiple of ATR.\n\nThis is the primary quality filter — it separates meaningful stop hunts from random noise.\n\n0.1–0.2: Loose — catches small failures, more signals, more false positives.\n0.3–0.5: Balanced — filters minor grazes, keeps clean institutional sweeps.\n0.8+: Strict — only significant spike reversals qualify, very few signals.\n\nStart at 0.3 and tighten if you see too many weak setups firing.")
i_failWickRej = input.float(25.0, "Min Wick Rejection (%)",
     minval=10.0, maxval=90.0, step=5.0, group=G_FAIL,
     tooltip="The failure wick must make up at least this percentage of the total bar range.\n\n40%: Moderate rejection — wick larger than body.\n60%: Strong rejection — most of the bar is wick.\n80%: Near pin-bar — very tight body, very strong reversal signal.")
i_failUseVol  = input.bool(true, "Volume Confirmation",
     group=G_FAIL,
     tooltip="When on: the failure bar must have above-average volume. Institutional failures leave a volume footprint — size is needed to run the stops. A failure on low volume is often noise.")
i_failVolMult = input.float(1.2, "Min Volume Multiple",
     minval=0.5, maxval=5.0, step=0.1, group=G_FAIL,
     tooltip="Volume on the failure bar must be at least this multiple of the rolling average.\n\n1.0 = any above-average volume.\n1.5 = 50% above average.\n2.0+ = strong spike required.\n\nOnly active when Volume Confirmation is enabled.")
i_failCooldown = input.int(3, "Cooldown Bars Between Failures",
     minval=0, maxval=50, group=G_FAIL,
     tooltip="Minimum bars between two failure signals on the same pivot direction. Prevents duplicate entries on the same level.")
i_failSlMode  = input.string("Wick", "SL Mode",
     options=["Wick", "Pivot"], group=G_FAIL,
     tooltip="Wick: SL placed at the tip of the failure wick + ATR buffer. Tightest possible stop, maximises RR.\nPivot: SL placed at the pivot level that was swept + ATR buffer. More room, lower risk of stop hunt on re-test.")
i_failSlBuf   = input.float(0.4, "SL Buffer (ATR)",
     minval=0.0, maxval=2.0, step=0.1, group=G_FAIL,
     tooltip="ATR buffer added beyond the SL reference point (wick tip or pivot level).")
i_failRR      = input.float(1.0, "RR Ratio",
     minval=0.5, maxval=10.0, step=0.5, group=G_FAIL,
     tooltip="Reward-to-risk ratio for the failure trade block. TP1 = 1:1, TP2 = this ratio.")
i_failTradeW  = input.int(25, "Trade Block Width (bars)",
     minval=5, maxval=100, group=G_FAIL)
i_failShowTrade = input.bool(true, "Show Trade Block on Failure",
     group=G_FAIL,
     tooltip="Draws TP and SL zones on the chart when a failure signal fires.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — VISUALS
// ───────────────────────────────────────────────────────────────────────────────
i_bullTrans  = input.int(80, "Bull Liquidity Zone Transparency", minval=0, maxval=99, group=G_VIS)
i_bearTrans  = input.int(80, "Bear Liquidity Zone Transparency", minval=0, maxval=99, group=G_VIS)
i_showScore  = input.bool(true, "Show Zone Stats Label", group=G_VIS,
     tooltip="Shows % Hold (how often zone held vs was swept) and liquidity value (volume × price at zone formation) on each zone.")
i_showHold   = input.bool(true, "Show % Hold", group=G_VIS,
     tooltip="Percentage of zone touches that held without being swept. Higher = stronger zone historically.")
i_showLiq    = input.bool(true, "Show Liquidity Value", group=G_VIS,
     tooltip="Estimated liquidity at zone formation: volume × price. Higher = more institutional interest at this level.")
i_labelSize  = input.string("Tiny", "Zone Label Size",
     options=["Tiny", "Small"], group=G_VIS,
     tooltip="Text size of the zone stats label. Tiny for dense charts, Small for more readable labels.")
i_minHold    = input.int(0, "Min % Hold to Show Zone",
     minval=0, maxval=100, step=5, group=G_VIS,
     tooltip="Only show and trade zones where % Hold is at or above this threshold. 0 = show all. New zones (no touches yet) are always shown. Lower the threshold to see more zones — raise it to show only historically strong zones.\n\nZones below threshold become invisible and will not trigger entries. Change this value and zones reappear or disappear instantly.")

// ── Neon Glow Candles ─────────────────────────────────────────────────────────
i_glowEnable  = input.bool(false, "Enable Neon Glow Candles",
     group=G_VIS,
     tooltip="Renders candles with a layered neon glow effect in bull/bear fluor colors.\n\n⚠️ For best results, hide the default TradingView candles:\n1. Open chart settings → Style tab\n2. Set body, border and wick colors to fully transparent\nThis lets only the glow candles show.")
i_glowBody    = input.int(85, "Body Transparency (soft)",
     minval=0, maxval=99, group=G_VIS,
     tooltip="Transparency of the candle body. Higher = more transparent and softer. Lower = solid and bright.\nRecommended: 80–90 for a subtle glowing body.")
i_glowWick    = input.int(0, "Wick & Border Transparency (hard)",
     minval=0, maxval=99, group=G_VIS,
     tooltip="Transparency of the wick and border. 0 = fully visible and sharp. Higher = softer wicks.\nRecommended: 0–20 for crisp neon wicks.")
i_glowTrans1  = input.int(95, "Primary Glow Strength",
     minval=0, maxval=99, group=G_VIS,
     tooltip="Transparency of the inner glow layer around the candle. Lower = more intense. Recommended: 60–75.")
i_glowTrans2  = input.int(95, "Secondary Glow Strength (Diffuse)",
     minval=0, maxval=99, group=G_VIS,
     tooltip="Transparency of the outer diffuse glow layer. Higher = softer and wider glow. Recommended: 85–92.")

// ── Neon Glow Zones ───────────────────────────────────────────────────────────
i_zoneGlow   = input.bool(false, "Enable Neon Glow Zones",
     group=G_VIS,
     tooltip="Adds layered neon glow to all liquidity zones — four stacked box layers from diffuse outer glow to sharp inner core.\n\nWorks independently from candle glow. For the full neon effect, enable both.\n\nLower glow strength = more intense. Higher = softer and more subtle.")
i_zoneGlowStr = input.int(85, "Zone Glow Strength",
     minval=0, maxval=99, group=G_VIS,
     tooltip="Controls the intensity of the zone glow layers. Lower = brighter neon effect. Higher = subtle ambient glow.\n\nRecommended: 80–87 for balanced glow, 50–65 for intense neon.")

// ───────────────────────────────────────────────────────────────────────────────
// INPUTS — DASHBOARD
// ───────────────────────────────────────────────────────────────────────────────
i_showDash = input.bool(true, "Show Dashboard", group=G_DASH)
i_dashPos  = input.string("Bottom Right", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
i_dashSize = input.string("Tiny", "Size",
     options=["Tiny","Small","Normal"], group=G_DASH)

// ───────────────────────────────────────────────────────────────────────────────
// CONSTANTS — fluor colors
// ───────────────────────────────────────────────────────────────────────────────
bullCol  = color.rgb(0,   255, 0)
bearCol  = color.rgb(255, 0,   0)
failCol  = color.rgb(21,  244, 238)   // fluor cyan/aqua — failure entry
eliteCol = color.rgb(187, 134, 252)
mutedCol = color.rgb(139, 148, 158)

// Active bull color — switches to failCol when Failure Entry Mode is on
activeBullCol = i_failMode ? failCol : bullCol

// ───────────────────────────────────────────────────────────────────────────────
// NEON GLOW CANDLES — three layered plotcandle calls
// Default chart candles should be hidden for best effect (see tooltip)
// ───────────────────────────────────────────────────────────────────────────────
isBull = close >= open
isBear = close < open

glowBaseCol = isBull ? activeBullCol : bearCol
invisCol    = color.new(color.gray, 100)

glowBody    = i_glowEnable ? color.new(glowBaseCol, i_glowBody)   : invisCol
glowWick    = i_glowEnable ? color.new(glowBaseCol, i_glowWick)   : invisCol
glowLayer1  = i_glowEnable ? color.new(glowBaseCol, i_glowTrans1) : invisCol
glowLayer2  = i_glowEnable ? color.new(glowBaseCol, i_glowTrans2) : invisCol

plotcandle(open, high, low, close, "Glow Diffuse", color=glowLayer2, wickcolor=glowLayer2, bordercolor=glowLayer2)
plotcandle(open, high, low, close, "Glow Primary", color=glowLayer1, wickcolor=glowLayer1, bordercolor=glowLayer1)
plotcandle(open, high, low, close, "Glow Candles", color=glowBody,   wickcolor=glowWick,   bordercolor=glowWick)


pivLen = switch i_depth
    "Scalp"        => math.max(3, i_pivLen / 2)
    "Major"        => i_pivLen * 2
    =>               i_pivLen

// ───────────────────────────────────────────────────────────────────────────────
// BASE CALCULATIONS
// ───────────────────────────────────────────────────────────────────────────────
atrVal  = ta.atr(14)
avgVol  = ta.sma(volume, i_volLen)
zoneH   = atrVal * i_zoneWidth
minDist = atrVal * i_minDist

// Zone pivot detection
pivH = ta.pivothigh(high, pivLen, pivLen)
pivL = ta.pivotlow(low,   pivLen, pivLen)

// ───────────────────────────────────────────────────────────────────────────────
// ZONE TYPE
// ───────────────────────────────────────────────────────────────────────────────
type Zone
    float zTop
    float zBot
    float score
    bool  isDemand
    bool  isFresh
    int   startBar
    int   tests
    float liqVal
    box   coreBox
    box   glowBox
    box   glowBox2
    box   glowBox3
    label scoreLbl

var array<Zone> bullZones = array.new<Zone>()
var array<Zone> bearZones = array.new<Zone>()

// ───────────────────────────────────────────────────────────────────────────────
// IMPULSE QUALITY SCORE
// ───────────────────────────────────────────────────────────────────────────────
f_score(idx) =>
    rng   = high[idx] - low[idx]
    body  = math.abs(close[idx] - open[idx])
    bodyR = rng > 0 ? body / rng : 0.0
    volR  = avgVol[idx] > 0 ? volume[idx] / avgVol[idx] : 1.0
    atrR  = atrVal[idx] > 0 ? rng / atrVal[idx] : 1.0
    s = (bodyR * 40.0) + (math.min(volR, 4.0) / 4.0 * 35.0) + (math.min(atrR, 3.0) / 3.0 * 25.0)
    math.max(0.0, math.min(100.0, s))

// ───────────────────────────────────────────────────────────────────────────────
// CLUSTER CHECK
// ───────────────────────────────────────────────────────────────────────────────
f_cluster(array<Zone> arr, float mid, float score) =>
    blocked = false
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            z = arr.get(i)
            existMid = (z.zTop + z.zBot) / 2
            if math.abs(mid - existMid) < minDist
                if z.score >= score
                    blocked := true
                else
                    box.delete(z.coreBox)
                    box.delete(z.glowBox)
                    box.delete(z.glowBox2)
                    box.delete(z.glowBox3)
                    label.delete(z.scoreLbl)
                    arr.remove(i)
                break
    blocked

// ───────────────────────────────────────────────────────────────────────────────
// ZONE CREATION
// ───────────────────────────────────────────────────────────────────────────────
if not na(pivL) and barstate.isconfirmed
    pBar   = bar_index - pivLen
    pPrice = low[pivLen]
    zTop   = pPrice + zoneH
    zBot   = pPrice
    mid    = (zTop + zBot) / 2
    sc     = f_score(pivLen)

    if sc > 0 and not f_cluster(bullZones, mid, sc)
        zCol    = activeBullCol
        liqVal  = volume[pivLen] * pPrice
        lblSize = i_labelSize == "Small" ? size.small : size.tiny
        sLbl    = i_showScore
             ? label.new(pBar, zBot, "...",
                  color=color.new(color.black, 100),
                  textcolor=color.new(zCol, 0),
                  style=label.style_label_up, size=lblSize)
             : label.new(pBar, zBot, "",
                  color=color.new(color.black, 100),
                  textcolor=color.new(color.black, 100), size=size.tiny)
        // 4-layer glow: outer diffuse → mid → inner → core
        g3Box = box.new(pBar, zTop + atrVal * 0.15, bar_index, zBot - atrVal * 0.15,
             bgcolor=color.new(zCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99),
             border_color=color.new(color.black, 100))
        g2Box = box.new(pBar, zTop + atrVal * 0.10, bar_index, zBot - atrVal * 0.10,
             bgcolor=color.new(zCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 8) : 99),
             border_color=color.new(color.black, 100))
        gBox  = box.new(pBar, zTop + atrVal * 0.05, bar_index, zBot - atrVal * 0.05,
             bgcolor=color.new(zCol, i_zoneGlow ? i_zoneGlowStr : math.min(99, i_bullTrans + 10)),
             border_color=color.new(color.black, 100))
        cBox  = box.new(pBar, zTop, bar_index, zBot,
             bgcolor=color.new(zCol, i_bullTrans),
             border_color=color.new(zCol, math.max(0, i_bullTrans - 25)), border_width=1)
        bullZones.push(Zone.new(zTop, zBot, sc, true, true, pBar, 0, liqVal, cBox, gBox, g2Box, g3Box, sLbl))
        if bullZones.size() > i_maxZones
            old = bullZones.shift()
            box.delete(old.coreBox)
            box.delete(old.glowBox)
            box.delete(old.glowBox2)
            box.delete(old.glowBox3)
            label.delete(old.scoreLbl)

if not na(pivH) and barstate.isconfirmed
    pBar   = bar_index - pivLen
    pPrice = high[pivLen]
    zTop   = pPrice
    zBot   = pPrice - zoneH
    mid    = (zTop + zBot) / 2
    sc     = f_score(pivLen)

    if sc > 0 and not f_cluster(bearZones, mid, sc)
        zCol    = bearCol
        liqVal  = volume[pivLen] * pPrice
        lblSize = i_labelSize == "Small" ? size.small : size.tiny
        sLbl    = i_showScore
             ? label.new(pBar, zTop, "...",
                  color=color.new(color.black, 100),
                  textcolor=color.new(zCol, 0),
                  style=label.style_label_down, size=lblSize)
             : label.new(pBar, zTop, "",
                  color=color.new(color.black, 100),
                  textcolor=color.new(color.black, 100), size=size.tiny)
        g3Box = box.new(pBar, zTop + atrVal * 0.15, bar_index, zBot - atrVal * 0.15,
             bgcolor=color.new(zCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99),
             border_color=color.new(color.black, 100))
        g2Box = box.new(pBar, zTop + atrVal * 0.10, bar_index, zBot - atrVal * 0.10,
             bgcolor=color.new(zCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 8) : 99),
             border_color=color.new(color.black, 100))
        gBox  = box.new(pBar, zTop + atrVal * 0.05, bar_index, zBot - atrVal * 0.05,
             bgcolor=color.new(zCol, i_zoneGlow ? i_zoneGlowStr : math.min(99, i_bearTrans + 10)),
             border_color=color.new(color.black, 100))
        cBox  = box.new(pBar, zTop, bar_index, zBot,
             bgcolor=color.new(zCol, i_bearTrans),
             border_color=color.new(zCol, math.max(0, i_bearTrans - 25)), border_width=1)
        bearZones.push(Zone.new(zTop, zBot, sc, false, true, pBar, 0, liqVal, cBox, gBox, g2Box, g3Box, sLbl))
        if bearZones.size() > i_maxZones
            old = bearZones.shift()
            box.delete(old.coreBox)
            box.delete(old.glowBox)
            box.delete(old.glowBox2)
            box.delete(old.glowBox3)
            label.delete(old.scoreLbl)

// ───────────────────────────────────────────────────────────────────────────────
// SWEEP BAR CHARACTERISTICS — shared by zone sweep + pattern gates
// ───────────────────────────────────────────────────────────────────────────────
barRange    = high - low
bodySize    = math.abs(close - open)
lowerWick   = math.min(open, close) - low
upperWick   = high - math.max(open, close)
wickPctLow  = barRange > 0 ? (lowerWick / barRange) * 100 : 0.0
wickPctHigh = barRange > 0 ? (upperWick / barRange) * 100 : 0.0
volOk       = not i_useVol or volume >= avgVol * i_volMult

// ───────────────────────────────────────────────────────────────────────────────
// PATTERN CALCULATIONS — hoisted for use in both sweep gates and pattern display
// ───────────────────────────────────────────────────────────────────────────────

// Price Failure (SFP) — uses patPivHi/Lo, lookback 5 bars each side
var float patPivHi = na
var float patPivLo = na
patPh = ta.pivothigh(high, 5, 5)
patPl = ta.pivotlow(low,   5, 5)
if not na(patPh)
    patPivHi := patPh
if not na(patPl)
    patPivLo := patPl

bullFailure = not na(patPivLo) and low < patPivLo and close > patPivLo and low[1] >= patPivLo
bearFailure = not na(patPivHi) and high > patPivHi and close < patPivHi and high[1] <= patPivHi

// Absorption Bar
bullAbsorption = close > open and open[1] > close[1] and close > open[1] and open < close[1]
bearAbsorption = close < open and open[1] < close[1] and close < open[1] and open > close[1]

// Wick Trap
patBodySize  = math.abs(close - open)
patLowerWick = math.min(close, open) - low
patUpperWick = high - math.max(close, open)

bullWickTrap = patLowerWick > patBodySize * 2 and patLowerWick > atrVal * 0.5
bearWickTrap = patUpperWick > patBodySize * 2 and patUpperWick > atrVal * 0.5

// Pattern confirmation gates for zone sweep
bullPatOk = (not i_reqFailure    or bullFailure)    and
             (not i_reqWickTrap   or bullWickTrap)   and
             (not i_reqAbsorption or bullAbsorption)
bearPatOk = (not i_reqFailure    or bearFailure)    and
             (not i_reqWickTrap   or bearWickTrap)   and
             (not i_reqAbsorption or bearAbsorption)

// ───────────────────────────────────────────────────────────────────────────────
// LABEL UPDATE HELPER
// ───────────────────────────────────────────────────────────────────────────────
f_holdPct(Zone z) =>
    z.tests > 0 ? math.round(float(z.tests - 1) / z.tests * 100) : 100

f_updateLabel(Zone z) =>
    if i_showScore
        holdPct = f_holdPct(z)
        liqFmt  = z.liqVal >= 1e9 ? str.tostring(math.round(z.liqVal / 1e9, 1)) + "B"
             : z.liqVal >= 1e6 ? str.tostring(math.round(z.liqVal / 1e6, 1)) + "M"
             : z.liqVal >= 1e3 ? str.tostring(math.round(z.liqVal / 1e3, 1)) + "K"
             : str.tostring(math.round(z.liqVal, 0))
        parts = ""
        if i_showHold
            parts := str.tostring(holdPct) + "% Hold"
        if i_showLiq
            parts := parts == "" ? liqFmt : parts + " | " + liqFmt
        label.set_text(z.scoreLbl, parts)
        label.set_x(z.scoreLbl, bar_index)

// ───────────────────────────────────────────────────────────────────────────────
// COUNTERS — zone sweep
// ───────────────────────────────────────────────────────────────────────────────
var int   totalSignals = 0
var int   totalLongs   = 0
var int   totalShorts  = 0
var int   totalWins    = 0
var int   totalLoss    = 0
var float totalPnlR    = 0.0

var int   activeBull = 0
var int   freshBull  = 0
var int   activeBear = 0
var int   freshBear  = 0

activeBull := 0
freshBull  := 0
activeBear := 0
freshBear  := 0

// ───────────────────────────────────────────────────────────────────────────────
// ZONE SWEEP LOOPS — only active when Failure Entry Mode is OFF
// ───────────────────────────────────────────────────────────────────────────────
var int lastBullSweep = -999
var int lastBearSweep = -999

// ── Demand zones ──────────────────────────────────────────────────────────────
if bullZones.size() > 0
    for i = bullZones.size() - 1 to 0
        z = bullZones.get(i)

        box.set_right(z.coreBox,  bar_index)
        box.set_right(z.glowBox,  bar_index)
        box.set_right(z.glowBox2, bar_index)
        box.set_right(z.glowBox3, bar_index)

        if low <= z.zTop and low >= z.zBot and z.isFresh
            z.tests += 1

        f_updateLabel(z)

        holdPct = f_holdPct(z)
        holdOk  = z.tests == 0 or holdPct >= i_minHold
        box.set_bgcolor(z.coreBox,  color.new(activeBullCol, holdOk ? i_bullTrans : 99))
        box.set_border_color(z.coreBox, holdOk ? color.new(activeBullCol, math.max(0, i_bullTrans - 25)) : color.new(activeBullCol, 99))
        box.set_bgcolor(z.glowBox,  color.new(activeBullCol, holdOk and i_zoneGlow ? i_zoneGlowStr             : 99))
        box.set_bgcolor(z.glowBox2, color.new(activeBullCol, holdOk and i_zoneGlow ? math.min(99, i_zoneGlowStr + 8)  : 99))
        box.set_bgcolor(z.glowBox3, color.new(activeBullCol, holdOk and i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99))
        label.set_textcolor(z.scoreLbl, holdOk ? color.new(activeBullCol, 0) : color.new(color.black, 100))

        wickPenetration = z.zBot > 0 ? ((z.zBot - low) / z.zBot) * 100 : 0.0
        minPenetOk      = wickPenetration >= i_minWickPct
        closeOk         = close > z.zBot
        wickRejOk       = not i_useWick or wickPctLow >= i_wickMin
        coolOk          = bar_index >= lastBullSweep + i_cooldown

        swept = not i_failMode and holdOk and low < z.zBot and minPenetOk and closeOk and volOk and wickRejOk and coolOk and bullPatOk and barstate.isconfirmed

        if swept and z.isFresh
            lastBullSweep := bar_index
            z.isFresh     := false
            totalSignals  += 1
            totalLongs    += 1

            box.set_bgcolor(z.coreBox, color.new(activeBullCol, math.min(99, i_bullTrans + 15)))
            box.set_border_color(z.coreBox, color.new(activeBullCol, i_bullTrans))

            if i_showTrade
                entryPrice = close
                slPrice    = i_slMode == "Zone"
                     ? z.zBot - atrVal * i_slBuffer
                     : low    - atrVal * i_slBuffer
                dist     = math.abs(entryPrice - slPrice)
                tp1Price = entryPrice + dist
                tp2Price = entryPrice + dist * i_rrRatio
                tEnd     = bar_index + i_tradeW

                box.new(bar_index, entryPrice, tEnd, slPrice,
                     bgcolor=color.new(bearCol, 82), border_color=color.new(bearCol, 50), border_width=1)
                box.new(bar_index, tp1Price, tEnd, entryPrice,
                     bgcolor=color.new(activeBullCol, 80), border_color=color.new(activeBullCol, 45), border_width=1)
                box.new(bar_index, tp2Price, tEnd, tp1Price,
                     bgcolor=color.new(activeBullCol, 88), border_color=color.new(activeBullCol, 60), border_width=1,
                     border_style=line.style_dashed)

        zoneFlipped = i_zoneFlip and close < z.zBot and barstate.isconfirmed and z.isFresh

        if zoneFlipped
            z.isDemand := false
            z.isFresh  := true
            box.set_bgcolor(z.coreBox,  color.new(bearCol, i_bearTrans))
            box.set_border_color(z.coreBox, color.new(bearCol, math.max(0, i_bearTrans - 25)))
            box.set_bgcolor(z.glowBox,  color.new(bearCol, i_zoneGlow ? i_zoneGlowStr             : 99))
            box.set_bgcolor(z.glowBox2, color.new(bearCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 8)  : 99))
            box.set_bgcolor(z.glowBox3, color.new(bearCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99))
            label.set_textcolor(z.scoreLbl, color.new(bearCol, 0))
        else
            farAway = low > z.zTop + atrVal * 12
            if (i_showFresh and not z.isFresh) or farAway
                box.delete(z.coreBox)
                box.delete(z.glowBox)
                box.delete(z.glowBox2)
                box.delete(z.glowBox3)
                label.delete(z.scoreLbl)
                bullZones.remove(i)
            else
                activeBull += 1
                if z.isFresh
                    freshBull += 1

if bullZones.size() > 0
    for i = bullZones.size() - 1 to 0
        z = bullZones.get(i)
        if not z.isDemand
            bearZones.push(z)
            bullZones.remove(i)

// ── Supply zones ──────────────────────────────────────────────────────────────
if bearZones.size() > 0
    for i = bearZones.size() - 1 to 0
        z = bearZones.get(i)
        if z.isDemand
            bullZones.push(z)
            bearZones.remove(i)

        box.set_right(z.coreBox,  bar_index)
        box.set_right(z.glowBox,  bar_index)
        box.set_right(z.glowBox2, bar_index)
        box.set_right(z.glowBox3, bar_index)

        if high >= z.zBot and high <= z.zTop and z.isFresh
            z.tests += 1

        f_updateLabel(z)

        holdPct = f_holdPct(z)
        holdOk  = z.tests == 0 or holdPct >= i_minHold
        box.set_bgcolor(z.coreBox,  color.new(bearCol, holdOk ? i_bearTrans : 99))
        box.set_border_color(z.coreBox, holdOk ? color.new(bearCol, math.max(0, i_bearTrans - 25)) : color.new(bearCol, 99))
        box.set_bgcolor(z.glowBox,  color.new(bearCol, holdOk and i_zoneGlow ? i_zoneGlowStr             : 99))
        box.set_bgcolor(z.glowBox2, color.new(bearCol, holdOk and i_zoneGlow ? math.min(99, i_zoneGlowStr + 8)  : 99))
        box.set_bgcolor(z.glowBox3, color.new(bearCol, holdOk and i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99))
        label.set_textcolor(z.scoreLbl, holdOk ? color.new(bearCol, 0) : color.new(color.black, 100))

        wickPenetration = z.zTop > 0 ? ((high - z.zTop) / z.zTop) * 100 : 0.0
        minPenetOk      = wickPenetration >= i_minWickPct
        closeOk         = close < z.zTop
        wickRejOk       = not i_useWick or wickPctHigh >= i_wickMin
        coolOk          = bar_index >= lastBearSweep + i_cooldown

        swept = not i_failMode and holdOk and high > z.zTop and minPenetOk and closeOk and volOk and wickRejOk and coolOk and bearPatOk and barstate.isconfirmed

        if swept and z.isFresh
            lastBearSweep := bar_index
            z.isFresh     := false
            totalSignals  += 1
            totalShorts   += 1

            box.set_bgcolor(z.coreBox, color.new(bearCol, math.min(99, i_bearTrans + 15)))
            box.set_border_color(z.coreBox, color.new(bearCol, i_bearTrans))

            if i_showTrade
                entryPrice = close
                slPrice    = i_slMode == "Zone"
                     ? z.zTop + atrVal * i_slBuffer
                     : high   + atrVal * i_slBuffer
                dist     = math.abs(entryPrice - slPrice)
                tp1Price = entryPrice - dist
                tp2Price = entryPrice - dist * i_rrRatio
                tEnd     = bar_index + i_tradeW

                box.new(bar_index, slPrice, tEnd, entryPrice,
                     bgcolor=color.new(bearCol, 82), border_color=color.new(bearCol, 50), border_width=1)
                box.new(bar_index, entryPrice, tEnd, tp1Price,
                     bgcolor=color.new(activeBullCol, 80), border_color=color.new(activeBullCol, 45), border_width=1)
                box.new(bar_index, tp1Price, tEnd, tp2Price,
                     bgcolor=color.new(activeBullCol, 88), border_color=color.new(activeBullCol, 60), border_width=1,
                     border_style=line.style_dashed)

        supplyFlipped = i_zoneFlip and close > z.zTop and barstate.isconfirmed and z.isFresh

        if supplyFlipped
            z.isDemand := true
            z.isFresh  := true
            box.set_bgcolor(z.coreBox,  color.new(activeBullCol, i_bullTrans))
            box.set_border_color(z.coreBox, color.new(activeBullCol, math.max(0, i_bullTrans - 25)))
            box.set_bgcolor(z.glowBox,  color.new(activeBullCol, i_zoneGlow ? i_zoneGlowStr             : 99))
            box.set_bgcolor(z.glowBox2, color.new(activeBullCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 8)  : 99))
            box.set_bgcolor(z.glowBox3, color.new(activeBullCol, i_zoneGlow ? math.min(99, i_zoneGlowStr + 15) : 99))
            label.set_textcolor(z.scoreLbl, color.new(activeBullCol, 0))
        else
            farAway = high < z.zBot - atrVal * 12
            if (i_showFresh and not z.isFresh) or farAway
                box.delete(z.coreBox)
                box.delete(z.glowBox)
                box.delete(z.glowBox2)
                box.delete(z.glowBox3)
                label.delete(z.scoreLbl)
                bearZones.remove(i)
            else
                activeBear += 1
                if z.isFresh
                    freshBear += 1

if bearZones.size() > 0
    for i = bearZones.size() - 1 to 0
        z = bearZones.get(i)
        if z.isDemand
            bullZones.push(z)
            bearZones.remove(i)

// ───────────────────────────────────────────────────────────────────────────────
// ZONE SWEEP BACKTEST LOOP
// ───────────────────────────────────────────────────────────────────────────────
var float bEntry = na
var float bSL    = na
var float bTP    = na
var int   bDir   = 0

newLong  = totalLongs  > totalLongs[1]
newShort = totalShorts > totalShorts[1]

if bDir == 0
    if newLong
        bDir   := 1
        bEntry := close
        bSL    := i_slMode == "Zone" ? close - atrVal * (i_zoneWidth + i_slBuffer) : low  - atrVal * i_slBuffer
        bTP    := close + math.abs(close - bSL) * i_rrRatio
    else if newShort
        bDir   := -1
        bEntry := close
        bSL    := i_slMode == "Zone" ? close + atrVal * (i_zoneWidth + i_slBuffer) : high + atrVal * i_slBuffer
        bTP    := close - math.abs(bSL - close) * i_rrRatio

if bDir != 0 and not na(bSL) and not na(bTP)
    isWin  = bDir == 1 ? high >= bTP : low  <= bTP
    isLoss = bDir == 1 ? low  <= bSL : high >= bSL
    if isWin or isLoss
        totalPnlR += isWin ? i_rrRatio : -1.0
        if isWin
            totalWins += 1
        else
            totalLoss += 1
        bDir := 0

// ───────────────────────────────────────────────────────────────────────────────
// ⚡ FAILURE ENTRY ENGINE
// Standalone SFP detection — fires when Failure Entry Mode is ON
// ───────────────────────────────────────────────────────────────────────────────
var float fPivHi = na
var float fPivLo = na
fPivH = ta.pivothigh(high, i_failPivLen, i_failPivLen)
fPivL = ta.pivotlow(low,   i_failPivLen, i_failPivLen)
if not na(fPivH)
    fPivHi := fPivH
if not na(fPivL)
    fPivLo := fPivL

// Failure bar volume
fVolOk = not i_failUseVol or volume >= avgVol * i_failVolMult

// Failure conditions
fBullWickSize = math.min(open, close) - low
fBearWickSize = high - math.max(open, close)

fBullOk = not na(fPivLo) and
     low < fPivLo and
     close > fPivLo and
     low[1] >= fPivLo and
     fBullWickSize >= atrVal * i_failWickATR and
     wickPctLow >= i_failWickRej and
     fVolOk and
     barstate.isconfirmed

fBearOk = not na(fPivHi) and
     high > fPivHi and
     close < fPivHi and
     high[1] <= fPivHi and
     fBearWickSize >= atrVal * i_failWickATR and
     wickPctHigh >= i_failWickRej and
     fVolOk and
     barstate.isconfirmed

// Cooldown
var int lastFailBull = -999
var int lastFailBear = -999

fBullFired = i_failMode and fBullOk and bar_index >= lastFailBull + i_failCooldown
fBearFired = i_failMode and fBearOk and bar_index >= lastFailBear + i_failCooldown

// Failure counters
var int   failLongs   = 0
var int   failShorts  = 0
var int   failWins    = 0
var int   failLoss    = 0
var float failPnlR    = 0.0

if fBullFired
    lastFailBull := bar_index
    failLongs    += 1
    totalSignals += 1
    totalLongs   += 1

    if i_failShowTrade
        fEntry   = close
        fSL      = i_failSlMode == "Wick" ? low - atrVal * i_failSlBuf : fPivLo - atrVal * i_failSlBuf
        fDist    = math.abs(fEntry - fSL)
        fTP1     = fEntry + fDist
        fTP2     = fEntry + fDist * i_failRR
        fTEnd    = bar_index + i_failTradeW

        box.new(bar_index, fEntry, fTEnd, fSL,
             bgcolor=color.new(bearCol, 82), border_color=color.new(bearCol, 50), border_width=1)
        box.new(bar_index, fTP1, fTEnd, fEntry,
             bgcolor=color.new(failCol, 80), border_color=color.new(failCol, 45), border_width=1)
        box.new(bar_index, fTP2, fTEnd, fTP1,
             bgcolor=color.new(failCol, 88), border_color=color.new(failCol, 60), border_width=1,
             border_style=line.style_dashed)

if fBearFired
    lastFailBear := bar_index
    failShorts   += 1
    totalSignals += 1
    totalShorts  += 1

    if i_failShowTrade
        fEntry   = close
        fSL      = i_failSlMode == "Wick" ? high + atrVal * i_failSlBuf : fPivHi + atrVal * i_failSlBuf
        fDist    = math.abs(fEntry - fSL)
        fTP1     = fEntry - fDist
        fTP2     = fEntry - fDist * i_failRR
        fTEnd    = bar_index + i_failTradeW

        box.new(bar_index, fSL, fTEnd, fEntry,
             bgcolor=color.new(bearCol, 82), border_color=color.new(bearCol, 50), border_width=1)
        box.new(bar_index, fEntry, fTEnd, fTP1,
             bgcolor=color.new(failCol, 80), border_color=color.new(failCol, 45), border_width=1)
        box.new(bar_index, fTP1, fTEnd, fTP2,
             bgcolor=color.new(failCol, 88), border_color=color.new(failCol, 60), border_width=1,
             border_style=line.style_dashed)

// Failure backtest loop
var float fBEntry = na
var float fBSL    = na
var float fBTP    = na
var int   fBDir   = 0

fNewLong  = failLongs  > failLongs[1]
fNewShort = failShorts > failShorts[1]

if fBDir == 0
    if fNewLong
        fBDir   := 1
        fBEntry := close
        fBSL    := i_failSlMode == "Wick" ? low  - atrVal * i_failSlBuf : fPivLo - atrVal * i_failSlBuf
        fBTP    := close + math.abs(close - fBSL) * i_failRR
    else if fNewShort
        fBDir   := -1
        fBEntry := close
        fBSL    := i_failSlMode == "Wick" ? high + atrVal * i_failSlBuf : fPivHi + atrVal * i_failSlBuf
        fBTP    := close - math.abs(fBSL - close) * i_failRR

if fBDir != 0 and not na(fBSL) and not na(fBTP)
    fIsWin  = fBDir == 1 ? high >= fBTP : low  <= fBTP
    fIsLoss = fBDir == 1 ? low  <= fBSL : high >= fBSL
    if fIsWin or fIsLoss
        fPnlR     = fIsWin ? i_failRR : -1.0
        failPnlR += fPnlR
        totalPnlR += fPnlR
        if fIsWin
            failWins  += 1
            totalWins += 1
        else
            failLoss  += 1
            totalLoss += 1
        fBDir := 0

// ───────────────────────────────────────────────────────────────────────────────
// ENTRY MARKERS
// ───────────────────────────────────────────────────────────────────────────────

// Zone sweep markers — triangles
plotshape(not i_failMode and totalLongs  > totalLongs[1],  "Long",  shape.triangleup,   location.belowbar,
     color.new(activeBullCol, 0), size=size.tiny)
plotshape(not i_failMode and totalShorts > totalShorts[1], "Short", shape.triangledown, location.abovebar,
     color.new(bearCol, 0), size=size.tiny)

// Failure entry markers — triangles in failCol
plotshape(fBullFired, "Failure Long",  shape.triangleup,   location.belowbar,
     color.new(failCol, 0), size=size.tiny)
plotshape(fBearFired, "Failure Short", shape.triangledown, location.abovebar,
     color.new(failCol, 0), size=size.tiny)

// ───────────────────────────────────────────────────────────────────────────────
// PRICE PATTERNS — display only
// ───────────────────────────────────────────────────────────────────────────────

// Pattern 1 — Price Imbalance
bullImbalance = low > high[2] and close[1] > open[1]
bearImbalance = high < low[2] and close[1] < open[1]

if i_showImbalance and bullImbalance
    box.new(bar_index - 2, low, bar_index, high[2],
         bgcolor=color.new(activeBullCol, 88), border_color=color.new(activeBullCol, 65), border_width=1)
if i_showImbalance and bearImbalance
    box.new(bar_index - 2, high, bar_index, low[2],
         bgcolor=color.new(bearCol, 88), border_color=color.new(bearCol, 65), border_width=1)

// Pattern 2 — Absorption Bar
plotshape(i_showAbsorption and bullAbsorption, "Bull Absorption",
     shape.circle, location.belowbar, color.new(activeBullCol, 0), size=size.tiny)
plotshape(i_showAbsorption and bearAbsorption, "Bear Absorption",
     shape.circle, location.abovebar, color.new(bearCol, 0), size=size.tiny)

// Pattern 3 — Price Failure — clean "F" label, no shape background
if i_showPriceFailure and bullFailure
    label.new(bar_index, low, "F",
         color=color.new(color.black, 100),
         textcolor=color.new(activeBullCol, 0),
         style=label.style_none, size=size.tiny)
if i_showPriceFailure and bearFailure
    label.new(bar_index, high, "F",
         color=color.new(color.black, 100),
         textcolor=color.new(bearCol, 0),
         style=label.style_none, size=size.tiny)

// Pattern 4 — Level Break & Retest
var float brokenHi = na
var float brokenLo = na

bullLevelBreak = ta.crossover(close, patPivHi)
bearLevelBreak = ta.crossunder(close, patPivLo)

if bullLevelBreak
    brokenHi := patPivHi
if bearLevelBreak
    brokenLo := patPivLo

bullRetest = not na(brokenHi[1]) and not bullLevelBreak and low <= brokenHi and close >= brokenHi
bearRetest = not na(brokenLo[1]) and not bearLevelBreak and high >= brokenLo and close <= brokenLo

if bullRetest or (not na(brokenHi) and close < brokenHi)
    brokenHi := na
if bearRetest or (not na(brokenLo) and close > brokenLo)
    brokenLo := na

plotshape(i_showLevelBreak and bullRetest, "Bull Retest",
     shape.xcross, location.belowbar, color.new(activeBullCol, 0), size=size.tiny)
plotshape(i_showLevelBreak and bearRetest, "Bear Retest",
     shape.xcross, location.abovebar, color.new(bearCol, 0), size=size.tiny)

// Pattern 5 — Wick Trap
plotshape(i_showWickTrap and bullWickTrap, "Bull Wick Trap",
     shape.arrowup, location.belowbar, color.new(activeBullCol, 30), size=size.tiny)
plotshape(i_showWickTrap and bearWickTrap, "Bear Wick Trap",
     shape.arrowdown, location.abovebar, color.new(bearCol, 30), size=size.tiny)

// ───────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ───────────────────────────────────────────────────────────────────────────────
winRate  = totalSignals > 0 ? float(totalWins) / float(totalSignals) * 100 : 0.0
expValue = totalSignals > 0 ? totalPnlR / totalSignals : 0.0

failWinRate  = (failLongs + failShorts) > 0 ? float(failWins) / float(failLongs + failShorts) * 100 : 0.0
failExpValue = (failLongs + failShorts) > 0 ? failPnlR / float(failLongs + failShorts) : 0.0

// Dashboard — 18 rows
var table dash = table.new(position.bottom_right, 2, 18,
     bgcolor      = color.new(color.rgb(13, 17, 23),  10),
     border_color = color.new(color.rgb(48, 54, 61),  20), border_width=1,
     frame_color  = color.new(color.rgb(48, 54, 61),  40), frame_width=1)

if i_showDash and barstate.islast
    dSz    = i_dashSize == "Tiny" ? size.tiny : i_dashSize == "Small" ? size.small : size.normal
    cPanel = color.new(color.rgb(22, 27, 34),    0)
    cMuted = color.new(mutedCol, 0)
    cWhite = color.new(color.rgb(255, 255, 255), 0)
    cElite = color.new(eliteCol, 0)
    cBull  = color.new(activeBullCol,  0)
    cBear  = color.new(bearCol,  0)
    cFail  = color.new(failCol,  0)

    dashPosVal = switch i_dashPos
        "Top Left"    => position.top_left
        "Top Right"   => position.top_right
        "Bottom Left" => position.bottom_left
        =>              position.bottom_right
    table.set_position(dash, dashPosVal)

    pnlCol = totalPnlR >= 0 ? cBull : cBear
    wrCol  = winRate   >= 50 ? cBull : cBear
    evCol  = expValue  >= 0  ? cBull : cBear

    // Row 0 — Header
    table.cell(dash, 0, 0, "🦈 Shark Hunt 🦈", text_color=cElite, text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 0, timeframe.period,    text_color=cMuted, text_size=dSz, bgcolor=cPanel)

    // Row 1 — Sweep mode status
    table.cell(dash, 0, 1, "Sweep",          text_color=cMuted, text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 1, i_failMode ? "OFF" : "ON",
         text_color=i_failMode ? cMuted : cBull, text_size=dSz, bgcolor=cPanel)

    // Row 2 — Failure mode status
    table.cell(dash, 0, 2, "Failure",        text_color=cMuted, text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 2, i_failMode ? "ON" : "OFF",
         text_color=i_failMode ? cFail : cMuted, text_size=dSz, bgcolor=cPanel)

    // Row 3 — Depth
    table.cell(dash, 0, 3, "Depth",          text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 3, i_depth,          text_color=cElite,  text_size=dSz, bgcolor=cPanel)

    // Row 4 — Demand
    table.cell(dash, 0, 4, "Bull Liquidity", text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 4, str.tostring(activeBull) + " (" + str.tostring(freshBull) + " fresh)", text_color=cBull, text_size=dSz, bgcolor=cPanel)

    // Row 5 — Supply
    table.cell(dash, 0, 5, "Bear Liquidity", text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 5, str.tostring(activeBear) + " (" + str.tostring(freshBear) + " fresh)", text_color=cBear, text_size=dSz, bgcolor=cPanel)

    // Row 6 — ATR
    table.cell(dash, 0, 6, "ATR",            text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 6, str.tostring(math.round(atrVal, 4)), text_color=cWhite, text_size=dSz, bgcolor=cPanel)

    // Row 7 — Trades separator
    table.cell(dash, 0, 7, "── Trades ──",   text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 7, "Count",          text_color=cMuted,  text_size=dSz, bgcolor=cPanel)

    // Row 8 — Total
    table.cell(dash, 0, 8, "Total",          text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 8, str.tostring(totalSignals), text_color=cWhite, text_size=dSz, bgcolor=cPanel)

    // Row 9 — Longs
    table.cell(dash, 0, 9, "Longs",          text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 9, str.tostring(totalLongs),  text_color=cBull,  text_size=dSz, bgcolor=cPanel)

    // Row 10 — Shorts
    table.cell(dash, 0, 10, "Shorts",        text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 10, str.tostring(totalShorts), text_color=cBear, text_size=dSz, bgcolor=cPanel)

    // Row 11 — Wins
    table.cell(dash, 0, 11, "Wins",          text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 11, str.tostring(totalWins),  text_color=cBull,  text_size=dSz, bgcolor=cPanel)

    // Row 12 — Losses
    table.cell(dash, 0, 12, "Losses",        text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 12, str.tostring(totalLoss),  text_color=cBear,  text_size=dSz, bgcolor=cPanel)

    // Row 13 — Win Rate
    table.cell(dash, 0, 13, "Win Rate",      text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 13, str.tostring(math.round(winRate, 1)) + "%", text_color=wrCol, text_size=dSz, bgcolor=cPanel)

    // Row 14 — PnL separator
    table.cell(dash, 0, 14, "── PnL ──",    text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 14, "in R",         text_color=cMuted,  text_size=dSz, bgcolor=cPanel)

    // Row 15 — Total PnL
    table.cell(dash, 0, 15, "Total PnL",    text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 15, (totalPnlR >= 0 ? "+" : "") + str.tostring(math.round(totalPnlR, 2)) + "R",
         text_color=pnlCol, text_size=dSz, bgcolor=cPanel)

    // Row 16 — Exp Value
    table.cell(dash, 0, 16, "Exp Value",    text_color=cMuted,  text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 16, (expValue >= 0 ? "+" : "") + str.tostring(math.round(expValue, 2)) + "R",
         text_color=evCol, text_size=dSz, bgcolor=cPanel)

    // Row 17 — Brand
    table.cell(dash, 0, 17, "Anonycryptous", text_color=cElite, text_size=dSz, bgcolor=cPanel)
    table.cell(dash, 1, 17, "v1.0",          text_color=cMuted, text_size=dSz, bgcolor=cPanel)

// ───────────────────────────────────────────────────────────────────────────────
// ALERTS
// ───────────────────────────────────────────────────────────────────────────────
alertcondition(not i_failMode and totalLongs  > totalLongs[1],   "Shark Long",    "Shark Hunt: Bull sweep confirmed — long entry.")
alertcondition(not i_failMode and totalShorts > totalShorts[1],  "Shark Short",   "Shark Hunt: Bear sweep confirmed — short entry.")
alertcondition(fBullFired,                                        "Failure Long",  "Shark Hunt: Bull failure confirmed — long entry.")
alertcondition(fBearFired,                                        "Failure Short", "Shark Hunt: Bear failure confirmed — short entry.")
````
