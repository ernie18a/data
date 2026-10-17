# [ A L P H A X ]  Structure Edge

- url: https://www.tradingview.com/script/omVnJeRG-A-L-P-H-A-X-Structure-Edge/
- type: indicator
- pine_id: PUB;de213f6b43ca4906b78ce6afd38bc049
- version: 1.0

## Description

[b]AlphaX Structure Edge — Swing Structure Detection, BOS, CHoCH, Structure Levels, Premium/Discount Zones, Swing Forecast & Fibonacci Extensions[/b]

AlphaX Structure Edge is a professional-grade Smart Money Concepts indicator that maps the complete picture of market structure directly on your chart. It detects confirmed swing pivots, identifies Break of Structure and Change of Character events in real time, draws adaptive structure levels with touch-count strength scoring, visualizes the Premium and Discount range between the last major swing high and low, and projects the next probable swing target using a statistical forecast engine built from your instrument's own historical swing behavior. Every element works together as a single unified system — from the first confirmed pivot to the forecast target and its Fibonacci extensions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]
[image]https://www.tradingview.com/x/58ET4j9L/[/image]
[i]AlphaX Structure Edge on XAUUSD — swing pivot markers, BOS and CHoCH labels, structure level lines with pill labels, Premium/Discount/EQ band, forecast corridor with step markers, target zone, and Fibonacci extensions[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]Swing Pivot Detection[/b]

The foundation of Structure Edge is a robust pivot detection engine built on [b]ta.pivothigh[/b] and [b]ta.pivotlow[/b] — Pine's native confirmed pivot functions. A pivot is only confirmed once the required number of bars on both sides have closed without making a new extreme, meaning every pivot you see on the chart is structurally confirmed and non-repainting.

The [b]Swing Length[/b] setting controls how many bars on each side are required to confirm a pivot. Larger values produce fewer but stronger, more institutionally significant pivots. Smaller values are more sensitive and catch minor structure swings.

Every confirmed swing high is marked with a small red triangle above the bar. Every confirmed swing low is marked with a small green triangle below the bar. These markers appear at the actual pivot bar, offset by the confirmation delay, and give you a clean visual map of the market's structural sequence at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Break of Structure (BOS) and Change of Character (CHoCH)[/b]

Market structure is defined by the sequence of highs and lows price is printing. AlphaX Structure Edge tracks this sequence in real time and identifies two critical structural events:

[b]Break of Structure (BOS)[/b]

A BOS occurs when price closes beyond the last confirmed swing level in the direction of the current trend — confirming that the trend is continuing. A bullish BOS means price closed above the last confirmed swing high, extending the bullish structure. A bearish BOS means price closed below the last confirmed swing low, extending the bearish structure.

BOS events are marked with a dashed horizontal line drawn from the broken swing level to the close bar, and a compact [b]BOS[/b] label. Bull BOS uses green tones. Bear BOS uses red tones. BOS signals that the prevailing trend remains intact and confirms continuation.

[b]Change of Character (CHoCH)[/b]

A CHoCH occurs when price closes beyond the last confirmed swing level in the [b]opposite[/b] direction of the current trend — the first sign that market character is changing. If the trend has been bullish and price closes below the last confirmed swing low, the structure is printing a CHoCH. If the trend has been bearish and price closes above the last confirmed swing high, the same event occurs in the bullish direction.

CHoCH events are marked with a solid line and a prominent [b]CHoCH ▲[/b] or [b]CHoCH ▼[/b] label. CHoCH is not a confirmed reversal — it is the earliest available warning that the current trend may be ending and new structure is forming. The distinction between BOS and CHoCH is critical:

[list]
[*]A [b]BOS[/b] in the direction of the trend → trend continuation. Stay aligned with the bias.
[*]A [b]CHoCH[/b] against the trend → character is changing. Be alert for reversal setups forming.
[*]A CHoCH followed by a BOS in the new direction → structural reversal confirmed.
[/list]

Both events are confirmed on bar close only — no repainting.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Structure Levels with Touch-Count Strength Scoring[/b]

Every confirmed swing pivot creates a [b]Structure Level[/b] — a horizontal line drawn from the pivot bar forward in time with a right-side pill label showing the exact price and touch count.

Structure levels are not static zones. AlphaX Structure Edge manages every level dynamically bar by bar:

[b]Touch counting:[/b] When price enters the level's sensitivity band without closing through it, the touch counter increments. Levels that have been tested two or more times display a [b]×N[/b] badge on their pill label — showing exactly how many times the market has respected that level. When the Highlight Tested Levels option is enabled, multi-touch levels are rendered with a stronger, more opaque line — making the most significant levels immediately visible without reading the labels.

[b]Age fading:[/b] Unbroken levels gradually fade in opacity as they age relative to the Max Level Age setting. Fresh levels are more prominent; old untested levels fade toward transparency. This keeps the chart focused on recently relevant structure without manually cleaning up old levels.

[b]Break detection:[/b] When price closes beyond a level by more than the sensitivity threshold, the level is considered broken. Its line switches to a dotted style and fades to a low-opacity color — remaining visible as a reference point for prior structure without competing for attention with active levels.

[b]Auto-removal:[/b] Broken levels are removed 30 bars after breaking. Unbroken levels older than the Max Level Age setting are removed automatically.

[i]Structure levels with pill labels — multi-touch levels show ×N badge and are rendered with stronger color[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Premium / Discount / Equilibrium Band[/b]

Between the last confirmed swing high and swing low lies the [b]institutional trading range[/b]. AlphaX Structure Edge visualizes this range as a unified band divided into three zones:

[list]
[*][b]PREM (Premium)[/b] — the upper half of the range. Price is trading above the midpoint, meaning it is relatively expensive compared to the recent range. Smart money institutions are more likely to be distributing (selling) in this zone.
[*][b]DISC (Discount)[/b] — the lower half of the range. Price is below the midpoint and relatively cheap. Smart money institutions are more likely to be accumulating (buying) in this zone.
[*][b]EQ (Equilibrium)[/b] — the exact midpoint of the range, marked with a dotted line. This is the fair value level of the current swing range. Price often finds temporary resistance or support at this level before continuing to one extreme or the other.
[/list]

The band updates dynamically on every bar using the most recent confirmed swing high and low — it always reflects the current structural context, not a fixed historical range.

[b]How to use the Premium/Discount band:[/b]
[list]
[*]In a bullish structure (after a BOS up), look for long entries from the Discount zone. Price pulling back into Discount during an uptrend is a Smart Money accumulation opportunity.
[*]In a bearish structure (after a BOS down), look for short entries from the Premium zone. Price rallying into Premium during a downtrend is a distribution opportunity.
[*]EQ acts as a decision point — price reacting from EQ suggests conviction in the current direction. Price grinding through EQ without reaction suggests the move has momentum behind it.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 [b]Swing Forecast Engine[/b]

AlphaX Structure Edge contains a statistical forecast engine that projects the [b]next probable swing target[/b] based on your instrument's own historical swing behavior — not a fixed percentage or ATR multiple.

[b]How the forecast is calculated:[/b]

Every time a swing direction change occurs, the engine records the size of the completed swing as a percentage move and its duration in bars. These values accumulate over the last N swings (controlled by the History Samples setting). When the last bar is reached, the engine aggregates these historical swings using your chosen method and projects the next swing from the current pivot:

[list]
[*][b]Weighted[/b] — the most recent swings carry more weight than older ones. Best for instruments where recent behavior is more predictive than distant history.
[*][b]Average[/b] — all samples are weighted equally. More stable and resistant to individual outliers.
[*][b]Median[/b] — uses the middle value of all recorded swings, ignoring extremes entirely. Best when your instrument occasionally prints unusually large or small swings that skew the average.
[/list]

The standard deviation across all recorded swings determines the [b]uncertainty band[/b] — how wide the forecast corridor is. A narrow corridor means your instrument moves consistently. A wide corridor means swing sizes vary significantly and the target should be treated with lower confidence.

[b]Forecast visuals:[/b]
[list]
[*][b]Forecast Corridor[/b] — a semi-transparent box from the current pivot to the projected target area, sized by the uncertainty band. Bull forecasts use green tones. Bear forecasts use red tones.
[*][b]Center Trajectory[/b] — a dashed line from the current pivot price to the projected target, showing the expected path of the move.
[*][b]Step Markers[/b] — three small horizontal tick marks along the trajectory at evenly spaced intervals, creating a visual stepping path feel along the projected route.
[*][b]Target Zone[/b] — a tighter box at the end of the corridor showing the exact projected target level and the projected percentage move. When the target overlaps with an existing structure level, the target box changes color to match the level and displays a [b]⬡[/b] confluence badge — highlighting a higher-probability target.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Fibonacci Extensions with Structure Confluence Highlighting[/b]

Beyond the forecast target, AlphaX Structure Edge draws up to five Fibonacci extension levels projected from the current swing origin. Five levels are available with independently toggleable and configurable ratios:

[list]
[*][b]Level 1[/b] — 1.000 (100% of the projected move, the base target)
[*][b]Level 2[/b] — 1.272 (127.2%)
[*][b]Level 3[/b] — 1.618 (161.8%)
[*][b]Level 4[/b] — 2.000 (200%, disabled by default)
[*][b]Level 5[/b] — 2.618 (261.8%, disabled by default)
[/list]

All five levels are fully customizable — you can change the ratio values to any number you prefer, not just the classic Fibonacci sequence.

[b]Structure confluence highlighting:[/b] When a Fibonacci level falls within the sensitivity band of an existing active structure level, that fib line is rendered with a thicker width and stronger color, and a [b]⬡[/b] badge appears on its label. Fib levels that coincide with prior structure are meaningfully stronger targets than those in open price space — the highlighting makes these confluences immediately visible without manual comparison.

[i]Fibonacci extensions beyond the forecast target — ⬡ badges highlighting levels that overlap with active structure levels[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 [b]Live Dashboard[/b]

The dashboard gives a real-time text summary of every structural condition in a compact panel:

[list]
[*][b]STRUCTURE[/b] — current structure trend: ▲ BULLISH, ▼ BEARISH, or — UNDEFINED. Highlighted in the corresponding color when a clear bias is active.
[*][b]LAST PIVOT[/b] — whether the most recently confirmed pivot was a high or low.
[*][b]BOS[/b] — whether a BOS occurred on the current bar and in which direction. Highlighted when active.
[*][b]CHoCH[/b] — whether a CHoCH occurred on the current bar and in which direction. Highlighted when active.
[*][b]LEVELS[/b] — count of active unbroken structure levels currently on the chart.
[*][b]FORECAST[/b] — the projected direction and average percentage move based on current swing history.
[*][b]CONFLUENCE[/b] — shows ⬡ YES — HIGH PROB when the forecast target overlaps with an active structure level. This is one of the most important rows — a forecast target with structure confluence is a significantly higher-probability setup.
[*][b]SAMPLES[/b] — how many swing samples have been loaded versus the configured maximum.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]

[list]
[*]🔬 Robust swing pivot detection using ta.pivothigh / ta.pivotlow — non-repainting, confirmed on bar close
[*]📈 BOS detection — dashed line and label at the broken swing level, directional color coded
[*]⚠ CHoCH detection — solid line and label at the first counter-trend structural break, the earliest reversal warning
[*]📊 Structure levels with touch counting — lines + pill labels, multi-touch levels highlighted with ×N badge and stronger color
[*]🎯 Premium / Discount / EQ band — institutional range visualization updating dynamically from the current swing high and low
[*]🔮 Statistical swing forecast — projects next target from historical swing % data using Weighted, Average, or Median aggregation
[*]📐 Forecast uncertainty corridor — width driven by standard deviation of historical swings, narrower when price moves consistently
[*]⬡ Target confluence detection — forecast target and fib levels highlighted when they overlap with active structure levels
[*]📏 Five configurable Fibonacci extension levels — all ratios adjustable, individually toggleable
[*]📋 Live 8-row dashboard — structure trend, last pivot, BOS, CHoCH, level count, forecast, confluence, sample count
[*]🔔 8 alert conditions — swing high/low confirmed, bull/bear BOS, bull/bear CHoCH, any BOS, any CHoCH
[*]✅ Zero repainting — all signals confirmed on bar close
[*]🎨 Full AlphaX visual theme — yellow-green for bullish, red for bearish, dark background dashboard, consistent throughout
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Detection[/b]
[list]
[*]Swing Length — bars required on each side to confirm a pivot (default: 16)
[/list]

[b]Market Structure[/b]
[list]
[*]Show BOS — toggle BOS lines and labels
[*]Show CHoCH — toggle CHoCH lines and labels
[*]Show Premium / Discount / EQ Band — toggle the institutional range visualization
[/list]

[b]Structure Levels[/b]
[list]
[*]Show Structure Levels — toggle all level lines and pill labels
[*]Level Sensitivity (ATR×) — controls the touch detection band and break threshold, scaled to ATR(200)
[*]Max Level Age (bars) — how long an unbroken level remains before automatic removal
[*]Highlight Tested Levels — render multi-touch levels with stronger color and show ×N badge
[/list]

[b]Swing Forecast[/b]
[list]
[*]History Samples — number of recent swing legs used for the projection calculation (default: 20)
[*]Calculation — aggregation method: Weighted (recent swings count more), Average (equal weight), Median (ignores outliers)
[*]Projection Width — how many bars to the right the corridor and target are drawn
[*]Show Forecast Corridor — toggle the corridor box and center trajectory
[*]Show Target Zone — toggle the target box and percentage label
[*]Show Fib Extensions — toggle Fibonacci extension lines and labels
[*]Level 1–5 — independently enable/disable each Fib level and set its ratio
[/list]

[b]Dashboard[/b]
[list]
[*]Show Dashboard — toggle the dashboard panel
[*]Position — Top Right, Top Left, Bottom Right, Bottom Left
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Structure Edge — Step by Step[/b]

[b]Step 1 — Establish the structural bias[/b]
[list]
[*]Check the STRUCTURE row on the dashboard — is it ▲ BULLISH or ▼ BEARISH?
[*]A confirmed BOS in the bullish direction with a sequence of higher highs and higher lows = bullish structure. Only look for long setups.
[*]A confirmed BOS in the bearish direction with lower highs and lower lows = bearish structure. Only look for short setups.
[*]If a CHoCH just printed, the structure is transitioning. Wait for a BOS in the new direction before committing to the new bias.
[/list]

[b]Step 2 — Identify your entry zone[/b]
[list]
[*]In bullish structure, price should be pulling back. Look for the pullback to enter the [b]Discount zone[/b] below EQ. This is where smart money accumulates.
[*]In bearish structure, price should be rallying back. Look for the rally to enter the [b]Premium zone[/b] above EQ. This is where smart money distributes.
[*]Check whether an active structure level sits inside the Discount or Premium zone — a level that has been tested multiple times (×N badge) inside the Discount during an uptrend is a high-confluence long entry zone.
[/list]

[b]Step 3 — Confirm the entry with structure signals[/b]
[list]
[*]Wait for price to reach your identified zone — Discount during uptrends, Premium during downtrends.
[*]Look for a BOS in the trend direction after the pullback. A new BOS confirming the trend is resuming from Discount (bull) or Premium (bear) is your entry trigger.
[*]If you see a CHoCH appear at the zone — price briefly broke the swing level against the trend but then reversed — this is a classic liquidity sweep. If price then resumes in the trend direction with a new BOS, this is a high-probability entry.
[/list]

[b]Step 4 — Use the forecast target for your take profit[/b]
[list]
[*]Check the forecast corridor — where is the projected target? This is your primary TP reference.
[*]If the CONFLUENCE row shows ⬡ YES — HIGH PROB, the forecast target coincides with an active structure level. This level is likely to act as resistance (in a bull move) or support (in a bear move). Consider taking full or partial profit at the target zone.
[*]Use the Fibonacci extension levels for secondary targets. The 1.272 and 1.618 levels are particularly significant. Any Fib level with a ⬡ badge overlapping a structure level is a priority target.
[/list]

[b]Step 5 — Manage with structural signals[/b]
[list]
[*]If a CHoCH prints against your open trade, the structure is warning you. Tighten your stop or reduce position size.
[*]If a BOS prints in your trade direction during the move, the structure is extending — the forecast target may be exceeded. Consider trailing your stop to the most recent BOS level.
[*]If price reaches the forecast target zone but fails to break through, and a CHoCH appears, the move may be complete. Close the trade.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]

[list]
[*]Swing High Confirmed — new swing high confirmed after full bar-close validation
[*]Swing Low Confirmed — new swing low confirmed after full bar-close validation
[*]Bull BOS — price closed above the last confirmed swing high in a bullish continuation
[*]Bear BOS — price closed below the last confirmed swing low in a bearish continuation
[*]Bull CHoCH — price closed above the last swing high against a bearish structure — potential reversal up
[*]Bear CHoCH — price closed below the last swing low against a bullish structure — potential reversal down
[*]Any BOS — fires on any BOS event regardless of direction
[*]Any CHoCH — fires on any CHoCH event regardless of direction
[/list]

All alert messages include {{ticker}} and {{interval}} for webhook integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]

[list]
[*]🥇 [b]Smart Money Concepts traders[/b] — built specifically around the SMC framework of BOS, CHoCH, structure levels, Premium/Discount, and institutional swing targets
[*]📉 [b]Forex and Gold traders[/b] — works across all liquid instruments where swing structure drives price behavior
[*]📊 [b]Swing traders and intraday traders[/b] — the forecast engine adapts to both short and longer timeframe swing behavior automatically
[*]🧠 [b]Systematic traders[/b] — BOS and CHoCH provide objective, non-discretionary structural signals with zero repainting
[*]📈 [b]Traders who want one complete structure tool[/b] — pivots, BOS, CHoCH, levels, Premium/Discount, forecast, and Fibs in a single indicator
[*]🔔 [b]Alert-driven traders[/b] — 8 alert conditions with clean webhook-ready messages for every structural event
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]

[list]
[*]All pivot detections and BOS/CHoCH signals are confirmed on [b]bar close[/b] — this indicator does not repaint. Signals visible on historical bars will not change or disappear.
[*]The forecast engine requires a minimum of 2 completed swing samples before it begins projecting. The SAMPLES row on the dashboard shows how many have loaded. The more samples loaded, the more statistically stable the forecast becomes.
[*]Increasing the Swing Length reduces the frequency of pivots and structural signals but increases their significance — each event represents a larger, more meaningful market structure event. Decreasing it produces more frequent signals on smaller structural moves.
[*]The Level Sensitivity (ATR×) setting controls both the touch detection radius and the break threshold simultaneously. Increasing it creates a wider zone around each level — more touches are registered and a larger close is needed to break it. Decreasing it is more precise but may register fewer touches on fast-moving instruments.
[*]The forecast target is a [b]statistical projection[/b] based on historical average swing behavior — not a guarantee. It represents the most probable outcome given recent history. Always use proper risk management and do not treat the forecast target as a certain price destination.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who read price through the lens of structure — where every swing tells a story and every break means something.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX

//@version=6
indicator("[ A L P H A X ]  Structure Edge", shorttitle="AlphaX SE",
  overlay=true, max_labels_count=500, max_boxes_count=500,
  max_lines_count=500, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ INPUTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

GRP_D  = "Detection"
swingLen = input.int(16, "Swing Length", minval=5, maxval=50, group=GRP_D,
  tooltip="Bars on each side required to confirm a swing pivot. Larger = fewer but more significant pivots.")

GRP_MS = "Market Structure"
showBOS   = input.bool(true, "Show BOS (Break of Structure)",      group=GRP_MS,
  tooltip="Horizontal line drawn at the broken swing level when price closes through it, confirming trend continuation.")
showCHoCH = input.bool(true, "Show CHoCH (Change of Character)",   group=GRP_MS,
  tooltip="Marks the first break of structure that opposes the current trend — the earliest reversal warning.")
showEQ    = input.bool(true, "Show Premium / Discount / EQ Band",  group=GRP_MS,
  tooltip="Shades the range between the last swing high and low. Upper half = Premium (institutional selling), Lower half = Discount (institutional buying), center line = Equilibrium.")

GRP_SR = "Structure Levels"
showLevels  = input.bool(true,  "Show Structure Levels",        group=GRP_SR)
zoneATR     = input.float(0.3,  "Level Sensitivity (ATR×)",     minval=0.05, maxval=1.0, step=0.05, group=GRP_SR,
  tooltip="Controls how close price must get to a level to register a touch, and the break threshold. Scaled to ATR(200).")
maxAge      = input.int(300,    "Max Level Age (bars)",          minval=30, group=GRP_SR,
  tooltip="How long an unbroken level remains visible before being automatically removed.")
showTouches = input.bool(true,  "Highlight Tested Levels",       group=GRP_SR,
  tooltip="Levels that have been tested multiple times without breaking are highlighted more prominently.")

GRP_P = "Swing Forecast"
samples    = input.int(20,           "History Samples",   minval=3, maxval=20, group=GRP_P,
  tooltip="Number of recent swing legs used to compute the forecast projection. More = smoother, fewer = faster.")
method     = input.string("Weighted","Calculation",       options=["Weighted","Average","Median"], group=GRP_P,
  tooltip="How recent swings are aggregated. Weighted = recent swings count more. Average = equal weight. Median = ignores outliers.")
fwdBars    = input.int(5,            "Projection Width",  minval=3, group=GRP_P,
  tooltip="How many bars to the right the forecast corridor and target are drawn.")
showCorridor = input.bool(true, "Show Forecast Corridor",  group=GRP_P)
showTarget   = input.bool(true, "Show Target Zone",        group=GRP_P)
showFibs     = input.bool(true, "Show Fib Extensions",     group=GRP_P)
fib1Active   = input.bool(true,  "Level 1", group=GRP_P, inline="f1")
fib1Val      = input.float(1.0,  "",        group=GRP_P, inline="f1", minval=0.001, step=0.001)
fib2Active   = input.bool(true,  "Level 2", group=GRP_P, inline="f2")
fib2Val      = input.float(1.272,"",        group=GRP_P, inline="f2", minval=0.001, step=0.001)
fib3Active   = input.bool(true,  "Level 3", group=GRP_P, inline="f3")
fib3Val      = input.float(1.618,"",        group=GRP_P, inline="f3", minval=0.001, step=0.001)
fib4Active   = input.bool(false, "Level 4", group=GRP_P, inline="f4")
fib4Val      = input.float(2.0,  "",        group=GRP_P, inline="f4", minval=0.001, step=0.001)
fib5Active   = input.bool(false, "Level 5", group=GRP_P, inline="f5")
fib5Val      = input.float(2.618,"",        group=GRP_P, inline="f5", minval=0.001, step=0.001)

GRP_DASH = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=GRP_DASH)
dashPos  = input.string("Top Right", "Position",
  options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ THEME / COLOR INPUTS ══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

GRP_CLR = "Theme"

color i_bull_primary = input.color(#c8e624, "Bull Primary",          group=GRP_CLR,
  tooltip="Main bullish color used for BOS up, pivot lows, support levels, and forecast corridors.")
color i_bull_bright  = input.color(#d4f03a, "Bull Bright",           group=GRP_CLR,
  tooltip="Highlighted bull color — used for CHoCH up labels and confluence target zones.")
color i_bull_dim     = input.color(#9ab81c, "Bull Dim",              group=GRP_CLR,
  tooltip="Muted bull color used for BOS lines, support level lines, and dim bull elements.")

color i_bear_primary = input.color(#ff1744, "Bear Primary",          group=GRP_CLR,
  tooltip="Main bearish color used for BOS down, pivot highs, resistance levels, and forecast corridors.")
color i_bear_bright  = input.color(#ff5252, "Bear Bright",           group=GRP_CLR,
  tooltip="Highlighted bear color — used for CHoCH down labels and high-probability bear targets.")
color i_bear_dim     = input.color(#d50032, "Bear Dim",              group=GRP_CLR,
  tooltip="Muted bear color used for BOS lines, resistance level lines, and dim bear elements.")

color i_neutral      = input.color(#555555, "Neutral",               group=GRP_CLR,
  tooltip="Color for undefined structure, equilibrium zone, and neutral dashboard states.")
color i_neutral_lt   = input.color(#a0aec0, "Neutral Light",         group=GRP_CLR,
  tooltip="Light neutral for EQ line, touch count badges, and secondary text.")
color i_text_lt      = input.color(#cccccc, "Label Text",            group=GRP_CLR,
  tooltip="Text color inside level pill labels and secondary dashboard labels.")

color i_dash_bg      = input.color(#0a0a0a, "Dashboard Background",  group=GRP_CLR,
  tooltip="Background fill for the info dashboard table.")
color i_dash_border  = input.color(#1a1a1a, "Dashboard Border",      group=GRP_CLR,
  tooltip="Border color between dashboard cells.")
color i_dash_frame   = input.color(#242424, "Dashboard Frame",       group=GRP_CLR,
  tooltip="Outer frame color of the dashboard table.")

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ RESOLVED COLORS ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// All internal references use these variables so the palette is driven entirely
// by the user inputs above.

_bull        = i_bull_primary
_bull_bright = i_bull_bright
_bull_dim    = i_bull_dim
_bear        = i_bear_primary
_bear_bright = i_bear_bright
_bear_dim    = i_bear_dim
_neutral     = i_neutral
_neutral_lt  = i_neutral_lt
_text_lt     = i_text_lt
_white       = #ffffff
_dash_bg     = i_dash_bg
_dash_border = i_dash_border
_dash_frame  = i_dash_frame
CLEAR        = color.new(color.black, 100)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ TYPES ═════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

type Pivot
    float price
    int   idx

// A structure level: single line + right-side pill label
type StructLevel
    float price
    int   startIdx
    bool  isResistance
    bool  broken
    int   touches
    line  lvlLine
    label pillLabel

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ STATE ═════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var hi  = Pivot.new(na, na)
var lo  = Pivot.new(na, na)
var bool dir = false

var float lastSwingHigh    = na
var int   lastSwingHighIdx = na
var float lastSwingLow     = na
var int   lastSwingLowIdx  = na

var int  structureTrend = 0
var int  bosCount       = 0
var int  chochCount     = 0

var box      corridorBox = na
var line     centerLine  = na
var line[]   stepLines   = array.new<line>()
var box      tgtBox      = na
var label    tgtLabel    = na
var line[]   fibLines    = array.new<line>()
var label[]  fibLabels   = array.new<label>()

var box   pdBox    = na
var line  eqLine   = na
var label eqLabel  = na
var label premLabel = na
var label discLabel = na

var levels = array.new<StructLevel>()
var pcts   = array.new<float>()
var durs   = array.new<float>()

atr200 = ta.atr(200)

var bool bosBullFired  = false
var bool bosBearFired  = false
var bool chochBullFired = false
var bool chochBearFired = false

bosBullFired   := false
bosBearFired   := false
chochBullFired := false
chochBearFired := false

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ HELPERS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

f_dashPos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

f_pillTxt(float price, int touches, bool tested) =>
    badge = tested and touches >= 2 ? " ×" + str.tostring(touches) : ""
    str.tostring(price, format.mintick) + badge

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ PIVOT DETECTION ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low,  swingLen, swingLen)

newHigh = not na(ph)
newLow  = not na(pl)

if newHigh
    lastSwingHigh    := ph
    lastSwingHighIdx := bar_index - swingLen
    hi.price         := ph
    hi.idx           := bar_index - swingLen
    dir              := true

if newLow
    lastSwingLow    := pl
    lastSwingLowIdx := bar_index - swingLen
    lo.price        := pl
    lo.idx          := bar_index - swingLen
    dir             := false

plotshape(newHigh, title="Swing High", style=shape.triangledown,
  location=location.abovebar, color=color.new(_bear, 0),
  size=size.tiny, offset=-swingLen)

plotshape(newLow, title="Swing Low", style=shape.triangleup,
  location=location.belowbar, color=color.new(_bull, 0),
  size=size.tiny, offset=-swingLen)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ BOS & CHoCH ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if not na(lastSwingHigh) and close[1] <= lastSwingHigh and close > lastSwingHigh
    if structureTrend == -1
        if showCHoCH
            line.new(lastSwingHighIdx, lastSwingHigh, bar_index, lastSwingHigh,
              color=color.new(_bear_bright, 0), width=2, style=line.style_solid)
            label.new(bar_index, lastSwingHigh, "CHoCH ▲",
              style=label.style_label_down,
              color=color.new(_bear_bright, 10),
              textcolor=_white, size=size.small)
        chochBullFired := true
        chochCount     += 1
    else
        if showBOS
            line.new(lastSwingHighIdx, lastSwingHigh, bar_index, lastSwingHigh,
              color=color.new(_bull_dim, 0), width=1, style=line.style_dashed)
            label.new(bar_index, lastSwingHigh, "BOS",
              style=label.style_label_down,
              color=color.new(_bull_dim, 20),
              textcolor=color.new(_bull_bright, 0), size=size.tiny)
        bosBullFired := true
        bosCount     += 1
    structureTrend := 1

if not na(lastSwingLow) and close[1] >= lastSwingLow and close < lastSwingLow
    if structureTrend == 1
        if showCHoCH
            line.new(lastSwingLowIdx, lastSwingLow, bar_index, lastSwingLow,
              color=color.new(_bear_bright, 0), width=2, style=line.style_solid)
            label.new(bar_index, lastSwingLow, "CHoCH ▼",
              style=label.style_label_up,
              color=color.new(_bear_bright, 10),
              textcolor=_white, size=size.small)
        chochBearFired := true
        chochCount     += 1
    else
        if showBOS
            line.new(lastSwingLowIdx, lastSwingLow, bar_index, lastSwingLow,
              color=color.new(_bear_dim, 0), width=1, style=line.style_dashed)
            label.new(bar_index, lastSwingLow, "BOS",
              style=label.style_label_up,
              color=color.new(_bear_dim, 20),
              textcolor=color.new(_bear_bright, 0), size=size.tiny)
        bosBearFired := true
        bosCount     += 1
    structureTrend := -1

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ PREMIUM / DISCOUNT / EQ ══════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if showEQ and not na(lastSwingHigh) and not na(lastSwingLow) and barstate.islast
    rangeTop = math.max(lastSwingHigh, lastSwingLow)
    rangeBot = math.min(lastSwingHigh, lastSwingLow)
    midPoint = (rangeTop + rangeBot) / 2.0
    startX   = math.min(lastSwingHighIdx, lastSwingLowIdx)
    endX     = bar_index + 8

    if not na(pdBox)
        pdBox.delete()
    if not na(eqLine)
        eqLine.delete()
    if not na(eqLabel)
        eqLabel.delete()
    if not na(premLabel)
        premLabel.delete()
    if not na(discLabel)
        discLabel.delete()

    pdBox    := box.new(startX, rangeTop, endX, rangeBot,
      border_color=CLEAR,
      bgcolor=color.new(_neutral, 92))

    eqLine   := line.new(startX, midPoint, endX, midPoint,
      color=color.new(_neutral_lt, 40), width=1, style=line.style_dotted)

    eqLabel  := label.new(endX + 1, midPoint, "EQ",
      style=label.style_label_right,
      color=CLEAR, textcolor=color.new(_neutral_lt, 0), size=size.tiny)
    premLabel := label.new(endX + 1, rangeTop, "PREM",
      style=label.style_label_right,
      color=CLEAR, textcolor=color.new(_bear, 0), size=size.tiny)
    discLabel := label.new(endX + 1, rangeBot, "DISC",
      style=label.style_label_right,
      color=CLEAR, textcolor=color.new(_bull, 0), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ SWING HISTORY & LEVEL CREATION ════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

dirChanged = dir != dir[1]

if dirChanged
    pct  = dir ? (hi.price - lo.price) / math.max(lo.price, 0.0001) * 100.0
               : (hi.price - lo.price) / math.max(hi.price, 0.0001) * 100.0
    pcts.push(math.abs(pct))
    durs.push(float(math.abs(hi.idx - lo.idx)))
    if pcts.size() > samples
        pcts.shift()
        durs.shift()

    if showLevels
        isRes = dir
        lvlPrice = isRes ? hi.price : lo.price
        lvlIdx   = isRes ? hi.idx   : lo.idx
        clr      = isRes ? _bear : _bull

        lvl = StructLevel.new()
        lvl.price       := lvlPrice
        lvl.startIdx    := lvlIdx
        lvl.isResistance := isRes
        lvl.broken      := false
        lvl.touches     := 0
        lvl.lvlLine     := line.new(lvlIdx, lvlPrice, bar_index + 5, lvlPrice,
          color=color.new(clr, 30), width=1, style=line.style_solid)
        lvl.pillLabel   := label.new(bar_index + 6, lvlPrice,
          f_pillTxt(lvlPrice, 0, false),
          style=label.style_label_right,
          color=color.new(clr, 45),
          textcolor=color.new(_text_lt, 0),
          size=size.tiny)
        levels.push(lvl)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ LEVEL MANAGEMENT ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if levels.size() > 0
    for i = levels.size() - 1 to 0
        lvl = levels.get(i)
        age = bar_index - lvl.startIdx
        clr = lvl.isResistance ? _bear : _bull

        if not lvl.broken
            inBand = lvl.isResistance
              ? high >= lvl.price - atr200 * zoneATR and close <= lvl.price + atr200 * zoneATR * 0.5
              : low  <= lvl.price + atr200 * zoneATR and close >= lvl.price - atr200 * zoneATR * 0.5
            if inBand
                lvl.touches += 1

            broken = lvl.isResistance ? close > lvl.price + atr200 * zoneATR * 0.3
                                      : close < lvl.price - atr200 * zoneATR * 0.3
            if broken
                lvl.broken := true
                line.set_style(lvl.lvlLine, line.style_dotted)
                line.set_color(lvl.lvlLine, color.new(clr, 82))
                label.set_color(lvl.pillLabel, color.new(clr, 88))
                label.set_textcolor(lvl.pillLabel, color.new(_neutral_lt, 0))

        if age > maxAge or (lvl.broken and age > 30)
            line.delete(lvl.lvlLine)
            label.delete(lvl.pillLabel)
            levels.remove(i)
            continue

        if not lvl.broken
            fade      = math.min(float(age) / float(maxAge), 1.0)
            tested    = showTouches and lvl.touches >= 2
            lineAlpha = tested ? int(30.0 + 35.0 * fade)
                               : int(50.0 + 40.0 * fade)

            line.set_x2(lvl.lvlLine, bar_index + 5)
            label.set_x(lvl.pillLabel, bar_index + 6)
            line.set_color(lvl.lvlLine, color.new(clr, lineAlpha))
            label.set_color(lvl.pillLabel, tested ? color.new(clr, 45) : color.new(clr, 65))
            label.set_text(lvl.pillLabel, f_pillTxt(lvl.price, lvl.touches, showTouches))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ FORECAST ENGINE ═══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.islast and pcts.size() >= 2

    if not na(corridorBox)
        corridorBox.delete()
    if not na(centerLine)
        centerLine.delete()
    if not na(tgtBox)
        tgtBox.delete()
    if not na(tgtLabel)
        tgtLabel.delete()
    for sl in stepLines
        sl.delete()
    stepLines.clear()
    for fl in fibLines
        fl.delete()
    fibLines.clear()
    for flb in fibLabels
        flb.delete()
    fibLabels.clear()

    fPct  = 0.0
    fBars = 0.0

    if method == "Weighted"
        tw = 0.0
        wp = 0.0
        wb = 0.0
        for i = 0 to pcts.size() - 1
            w   = float(i + 1)
            wp += pcts.get(i) * w
            wb += durs.get(i) * w
            tw += w
        fPct  := wp / tw
        fBars := wb / tw
    else if method == "Median"
        fPct  := pcts.median()
        fBars := durs.median()
    else
        fPct  := pcts.avg()
        fBars := durs.avg()

    variance = 0.0
    for i = 0 to pcts.size() - 1
        d         = pcts.get(i) - fPct
        variance += d * d
    stdDev   = math.sqrt(variance / pcts.size())
    bandHalf = math.max(atr200 * 0.4, atr200 * stdDev / 10.0)

    isBull    = dir
    origin    = isBull ? lo.price : hi.price
    originIdx = isBull ? lo.idx   : hi.idx
    target    = isBull ? origin * (1.0 + fPct / 100.0)
                       : origin * (1.0 - fPct / 100.0)
    endIdx    = bar_index + fwdBars
    projClr   = isBull ? _bull : _bear

    confluenceFound = false
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            lv = levels.get(i)
            if not lv.broken and math.abs(target - lv.price) <= atr200 * zoneATR * 1.5
                confluenceFound := true
                break

    if showCorridor
        corridorBox := box.new(originIdx, target + bandHalf, endIdx, target - bandHalf,
          border_color=color.new(projClr, 55),
          border_width=1,
          bgcolor=color.new(projClr, 91))

        centerLine := line.new(originIdx, origin, endIdx, target,
          color=color.new(projClr, 25), width=1, style=line.style_dashed)

        for s = 1 to 3
            t     = float(s) / 4.0
            x     = originIdx + int((endIdx - originIdx) * t)
            y     = origin + (target - origin) * t
            hw    = math.max(1, int((endIdx - originIdx) / 10))
            alpha = int(30 + 40 * t)
            stepLines.push(line.new(x - hw, y, x + hw, y,
              color=color.new(projClr, alpha), width=2))

    if showTarget
        tClr     = confluenceFound ? (isBull ? _bull_bright : _bear_bright) : projClr
        tgtTop   = target + bandHalf * 0.5
        tgtBot   = target - bandHalf * 0.5

        tgtBox := box.new(endIdx - 1, tgtTop, endIdx + 4, tgtBot,
          border_color=color.new(tClr, 20),
          border_width=2,
          bgcolor=color.new(tClr, 72))

        confBadge = confluenceFound ? " ⬡" : ""
        arrow     = isBull ? "▲ " : "▼ "
        tgtLabel  := label.new(endIdx + 5, target,
          arrow + str.tostring(fPct, "#.##") + "%" + confBadge + "\n"
          + str.tostring(target, format.mintick),
          style=label.style_label_left,
          color=color.new(tClr, 15),
          textcolor=_white, size=size.small)

    if showFibs
        fullMove  = target - origin
        fibActive = array.from(fib1Active, fib2Active, fib3Active, fib4Active, fib5Active)
        fibVals   = array.from(fib1Val, fib2Val, fib3Val, fib4Val, fib5Val)
        fibAlpha  = array.from(20, 35, 45, 55, 65)

        for i = 0 to 4
            if not fibActive.get(i)
                continue
            ratio    = fibVals.get(i)
            fibPrice = origin + fullMove * ratio

            fibOnLevel = false
            if levels.size() > 0
                for zi = 0 to levels.size() - 1
                    lz = levels.get(zi)
                    if not lz.broken and math.abs(fibPrice - lz.price) <= atr200 * zoneATR
                        fibOnLevel := true
                        break

            fAlpha = fibAlpha.get(i)
            fClr   = fibOnLevel ? projClr : (isBull ? _bull_dim : _bear_dim)
            fWidth = fibOnLevel ? 2 : 1
            fStyle = ratio == 1.0 ? line.style_solid : line.style_dashed

            fibLines.push(line.new(bar_index, fibPrice, endIdx + 18, fibPrice,
              color=color.new(fClr, fibOnLevel ? fAlpha - 15 : fAlpha),
              width=fWidth, style=fStyle))

            fibBadge = fibOnLevel ? " ⬡" : ""
            fibLabels.push(label.new(endIdx + 20, fibPrice,
              str.tostring(ratio, "#.###") + "  "
              + str.tostring(fibPrice, format.mintick) + fibBadge,
              style=label.style_label_left,
              color=CLEAR,
              textcolor=color.new(fibOnLevel ? projClr : (isBull ? _bull_dim : _bear_dim),
                fibOnLevel ? 0 : 20),
              size=size.tiny))

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ DASHBOARD ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(f_dashPos(dashPos), 2, 9,
  bgcolor      = color.new(_dash_bg,     0),
  border_width = 1,
  border_color = color.new(_dash_border, 0),
  frame_width  = 1,
  frame_color  = color.new(_dash_frame,  0))

if showDash and barstate.islast
    headerBg = color.new(#111111, 0)
    cellBg   = color.new(_dash_bg, 0)
    lblCol   = color.new(_text_lt, 0)
    sz       = size.small

    table.cell(dash, 0, 0, "AlphaX  S T R U C T U R E  E D G E",
      text_color=color.new(_bull, 0), text_size=sz,
      bgcolor=headerBg, text_halign=text.align_center)
    table.cell(dash, 1, 0, "", bgcolor=headerBg)

    sTxt = structureTrend == 1  ? "▲ BULLISH"
         : structureTrend == -1 ? "▼ BEARISH" : "— UNDEFINED"
    sClr = structureTrend == 1  ? color.new(_bull, 0)
         : structureTrend == -1 ? color.new(_bear, 0) : color.new(_neutral, 0)
    sBg  = structureTrend == 1  ? color.new(_bull, 82)
         : structureTrend == -1 ? color.new(_bear, 82) : cellBg
    table.cell(dash, 0, 1, "STRUCTURE", text_color=lblCol, text_size=sz, bgcolor=sBg)
    table.cell(dash, 1, 1, sTxt,        text_color=sClr,   text_size=sz, bgcolor=sBg)

    lpTxt = dir ? "↑ Last: High" : "↓ Last: Low"
    lpClr = dir ? color.new(_bear, 0) : color.new(_bull, 0)
    table.cell(dash, 0, 2, "LAST PIVOT", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 2, lpTxt,        text_color=lpClr,  text_size=sz, bgcolor=cellBg)

    bosTxt = bosBullFired ? "▲ BULL BOS" : bosBearFired ? "▼ BEAR BOS" : "— NONE"
    bosClr = bosBullFired  ? color.new(_bull_dim, 0)
           : bosBearFired  ? color.new(_bear_dim, 0)
           : color.new(_neutral, 0)
    bosBg  = bosBullFired  ? color.new(_bull_dim, 80)
           : bosBearFired  ? color.new(_bear_dim, 80)
           : cellBg
    table.cell(dash, 0, 3, "BOS",   text_color=lblCol, text_size=sz, bgcolor=bosBg)
    table.cell(dash, 1, 3, bosTxt,  text_color=bosClr, text_size=sz, bgcolor=bosBg)

    chTxt = chochBullFired ? "▲ BULL CHoCH" : chochBearFired ? "▼ BEAR CHoCH" : "— NONE"
    chClr = chochBullFired  ? color.new(_bull_bright, 0)
           : chochBearFired ? color.new(_bear_bright, 0)
           : color.new(_neutral, 0)
    chBg  = chochBullFired ? color.new(_bull, 82) : chochBearFired ? color.new(_bear, 82) : cellBg
    table.cell(dash, 0, 4, "CHoCH",  text_color=lblCol, text_size=sz, bgcolor=chBg)
    table.cell(dash, 1, 4, chTxt,    text_color=chClr,  text_size=sz, bgcolor=chBg)

    activeLvls = levels.size()
    lvlTxt = activeLvls > 0 ? str.tostring(activeLvls) + " active" : "— NONE"
    lvlClr = activeLvls > 0 ? color.new(_neutral_lt, 0) : color.new(_neutral, 0)
    table.cell(dash, 0, 5, "LEVELS",    text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 5, lvlTxt,      text_color=lvlClr, text_size=sz, bgcolor=cellBg)

    hasForecast = pcts.size() >= 2
    fcTxt = hasForecast
           ? (dir ? "▲ " : "▼ ") + str.tostring(pcts.avg(), "#.##") + "% avg move"
           : "— building..."
    fcClr = hasForecast ? (dir ? color.new(_bull, 0) : color.new(_bear, 0)) : color.new(_neutral, 0)
    table.cell(dash, 0, 6, "FORECAST",  text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 6, fcTxt,       text_color=fcClr,  text_size=sz, bgcolor=cellBg)

    dashConf = false
    if hasForecast and levels.size() > 0
        oD  = dir ? lo.price : hi.price
        tD  = dir ? oD * (1.0 + pcts.avg() / 100.0) : oD * (1.0 - pcts.avg() / 100.0)
        for zi = 0 to levels.size() - 1
            lz = levels.get(zi)
            if not lz.broken and math.abs(tD - lz.price) <= atr200 * zoneATR * 1.5
                dashConf := true
                break
    confTxt = dashConf ? "⬡ YES — HIGH PROB" : "— NONE"
    confClr = dashConf ? color.new(_bull_bright, 0) : color.new(_neutral, 0)
    confBg  = dashConf ? color.new(_bull_dim, 75) : cellBg
    table.cell(dash, 0, 7, "CONFLUENCE", text_color=lblCol,  text_size=sz, bgcolor=confBg)
    table.cell(dash, 1, 7, confTxt,      text_color=confClr, text_size=sz, bgcolor=confBg)

    table.cell(dash, 0, 8, "SAMPLES",    text_color=lblCol,                    text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 8, str.tostring(pcts.size()) + " / " + str.tostring(samples),
      text_color=color.new(_neutral_lt, 0), text_size=sz, bgcolor=cellBg)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ ALERTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(newHigh,
  title="Swing High Confirmed",
  message="[AlphaX SE] Swing High — {{ticker}} {{interval}} @ {{close}}")
alertcondition(newLow,
  title="Swing Low Confirmed",
  message="[AlphaX SE] Swing Low — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bosBullFired,
  title="Bull BOS",
  message="[AlphaX SE] BULL BOS — Structure break above swing high — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bosBearFired,
  title="Bear BOS",
  message="[AlphaX SE] BEAR BOS — Structure break below swing low — {{ticker}} {{interval}} @ {{close}}")
alertcondition(chochBullFired,
  title="Bull CHoCH — Reversal Warning",
  message="[AlphaX SE] BULL CHoCH — Change of Character, possible reversal UP — {{ticker}} {{interval}} @ {{close}}")
alertcondition(chochBearFired,
  title="Bear CHoCH — Reversal Warning",
  message="[AlphaX SE] BEAR CHoCH — Change of Character, possible reversal DOWN — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bosBullFired or bosBearFired,
  title="Any BOS",
  message="[AlphaX SE] BOS — {{ticker}} {{interval}} @ {{close}}")
alertcondition(chochBullFired or chochBearFired,
  title="Any CHoCH",
  message="[AlphaX SE] CHoCH — potential reversal — {{ticker}} {{interval}} @ {{close}}")
````
