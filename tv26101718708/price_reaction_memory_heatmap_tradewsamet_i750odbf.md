# Price Reaction Memory Heatmap [tradewsamet]

- url: https://www.tradingview.com/script/i750ODBF-Price-Reaction-Memory-Heatmap-tradewsamet/
- type: indicator
- pine_id: PUB;80b3161f4ae6458289a8648b18fac1df
- version: 1.0

## Description

🎯 [b]Price Reaction Memory Heatmap[/b] is an overlay indicator that turns confirmed price reactions into stateful memory zones and continuously re-evaluates how much reaction memory each zone still retains.
Ever marked a clean reaction area, only to find that it looked just as important after dozens of bars, repeated retests, deeper penetration and weaker responses? Most zone tools are good at showing [i]where[/i] price reacted, but much less explicit about whether that reaction still carries the same relevance now.
The core idea: [b]a reaction zone should not keep the same importance forever.[/b] Once a reaction is qualified, its memory can decay, reinforce, weaken, deplete or become structurally invalid as new price behavior interacts with it.

[b]📊 OVERVIEW[/b]

A confirmed pivot is only the beginning. It becomes a Memory Zone only after price produces a sufficiently large ATR-normalized directional reaction within the qualification window.
Once active, the zone becomes a persistent object with its own history. The script tracks its age, distinct retests, penetration depth, post-touch reaction strength and completed interaction outcomes. Those variables are used to update the same zone state rather than acting as separate confirmation indicators.
The result is a Bullish or Bearish Memory Zone with a descriptive [b]0-100 Memory Score[/b] and lifecycle state.
The key question is:
[b]Does this confirmed reaction still matter now?[/b]
Memory Score is not a probability, win rate or trade recommendation. It describes the current historical state of the zone according to the model.

[b]🧩 WHY THESE COMPONENTS WORK TOGETHER[/b]

Traditional swing and zone tools answer "where did price react?", but that alone does not answer "how strong was the reaction?", "how much has the zone been consumed?", "has it survived repeated interaction?" or "does it still deserve the same visual importance?".
Price Reaction Memory Heatmap links those questions into one lifecycle:
[b]Pivot confirmation → Reaction qualification → Memory zone → Retest history → Penetration damage → Time decay → Reinforcement / weakening → Memory Score → Lifecycle retirement[/b]
Reaction qualification prevents every local swing from becoming a zone. Retest history records repeated interaction. Penetration measures structural damage inside the zone. Time decay reduces stale memory. Completed reactions can reinforce or weaken accumulated evidence. The Memory Score summarizes the current state, and lifecycle rules determine when the zone remains active, fades, depletes or becomes structurally invalid.
Without qualification, every swing would become a zone. Without penetration tracking, a shallow retest and a full traversal would look the same. Without decay, old reactions could remain important indefinitely. Without reinforcement and weakening, new behavior could not update the original evidence.
ATR is used only as a scale-normalization unit for reaction distance, zone depth, spacing and invalidation distance. It does not determine Bullish/Bearish direction and is not used as a separate confirmation signal.

[b]🔍 WHAT MAKES THIS MODEL ORIGINAL[/b]

1️⃣ [b]Qualified reactions — not raw pivots[/b]

A confirmed pivot does not automatically become a memory zone.
With the default 3-left / 3-right pivot structure, the pivot is known only after the required right-side bars have completed. The candidate then has a limited qualification window and, by default, must produce at least a 2.00 ATR directional reaction within 20 completed bars.
— Bullish candidate: confirmed pivot low → sufficient upward excursion
— Bearish candidate: confirmed pivot high → sufficient downward excursion
— Failed candidate: qualification window ends without the required reaction
[b]Why it matters:[/b] the script stores areas that demonstrated measurable reaction instead of treating every local swing as equally important.

2️⃣ [b]Persistent zone memory — each zone keeps its own history[/b]

A new touch is counted only when price moves from outside the zone to inside it. Several consecutive bars inside the same zone belong to one interaction rather than being counted as multiple retests.
Each active zone records:
— distinct retest count
— first and most recent interaction
— deepest historical penetration
— current and completed post-touch reaction
— reinforced, neutral and weakened interaction counts
[b]Why it matters:[/b] the zone is evaluated through accumulated behavior instead of a static touch count.

3️⃣ [b]Penetration as structural damage[/b]

Penetration is normalized to the physical depth of the zone and capped at 100%.
— 0% = price has only reached the near side
— 100% = price has traversed the full zone depth
A move beyond the far edge is not represented as 200%, 400% or another unbounded value. Structural failure is handled separately by the lifecycle engine.
[b]Why it matters:[/b] penetration remains interpretable across zones while structural invalidation stays a separate event.

4️⃣ [b]Memory can decay, reinforce or weaken[/b]

The model does not assume that a zone becomes weaker only because time passes.
Age, repeated retests and penetration create natural memory decay. Completed interactions can then update the evidence:
— [b]REINFORCED[/b] — a sufficiently strong post-touch reaction occurred without excessive penetration
— [b]NEUTRAL[/b] — the interaction met neither reinforcement nor weakening conditions
— [b]WEAKENED[/b] — price penetrated deeply and failed to produce sufficient post-touch reaction
[b]Why it matters:[/b] new price behavior can strengthen or damage the zone's evidence instead of leaving the original reaction frozen forever.

5️⃣ [b]One 0-100 Memory Score — five state variables[/b]

Each active zone receives a bounded Memory Score built from five components:
— Reaction Quality — 25%
— Freshness — 20%
— Retest Resilience — 15%
— Zone Integrity — 20%
— Outcome Evidence — 20%
Conceptually:
[b]Memory Score =
Reaction Quality × 0.25
+ Freshness × 0.20
+ Retest Resilience × 0.15
+ Zone Integrity × 0.20
+ Outcome Evidence × 0.20[/b]
Score bands:
— 80-100 → STRONG
— 60-79 → ACTIVE
— 40-59 → WEAKENING
— 20-39 → FADING
— 0-19 → DEPLETED
[b]Why it matters:[/b] the visible score is tied to explicit variables from the same zone lifecycle rather than to an unexplained ranking.
A score of 80 does not mean there is an 80% probability that price will react again.

6️⃣ [b]Memory depletion ≠ structural invalidation[/b]

A zone can still carry a relatively high Memory Score and then become structurally invalidated by a confirmed close beyond its far edge.
Structural invalidation uses the configured ATR buffer; the default is 0.10 ATR.
Memory depletion is different. It occurs when the descriptive score falls into the depleted range after the configured minimum age; by default, depletion retirement can begin after 30 bars.
[b]Why it matters:[/b] historical reaction strength and present structural validity are treated as different properties.

[b]🧠 HOW IT WORKS — CALCULATION FLOW[/b]

[b]Step 1 — Pivot confirmation:[/b] the script waits for the configured left/right pivot structure to be confirmed. With the default 3/3 setting, the pivot is known three right-side bars after its extreme.
[b]Step 2 — Candidate creation:[/b] the confirmed pivot becomes a Bullish or Bearish reaction candidate.
[b]Step 3 — Reaction qualification:[/b] directional excursion is measured in ATR units during the qualification window. A candidate that reaches the threshold becomes a Memory Zone; otherwise it expires.
[b]Step 4 — Zone-quality filtering:[/b] same-side candidates that are too close in price or born too close together are filtered to reduce duplicate zones. The default configuration also limits the number of active zones.
[b]Step 5 — Interaction tracking:[/b] the script detects outside-to-inside retests, measures penetration and starts a post-touch reaction cycle.
[b]Step 6 — Interaction classification:[/b] the completed cycle is classified as Reinforced, Neutral or Weakened using the configured reaction and penetration thresholds.
[b]Step 7 — Memory update:[/b] age, repeated interaction, penetration and accumulated outcome evidence update the zone state.
[b]Step 8 — Memory Score:[/b] Reaction Quality, Freshness, Retest Resilience, Zone Integrity and Outcome Evidence are combined into the current 0-100 score.
[b]Step 9 — Lifecycle decision:[/b] the zone remains active, fades, depletes or becomes structurally invalidated. Terminal zones stop behaving as active memory objects and can optionally remain as archived context.

[b]📖 HOW TO USE[/b]

🎯 [b]Quick start:[/b]

1. Add the indicator with the default settings.
2. Read the location of the zone first.
3. Read its Memory Score second.
4. Check whether the zone is Active, Reinforced, Weakening, Fading or Depleted.
5. Use the map as analytical context rather than an automatic entry instruction.

👁️ [b]Reading the chart:[/b]

— Bullish memory zones originate from qualified reactions at confirmed pivot lows
— Bearish memory zones originate from qualified reactions at confirmed pivot highs
— BULL / BEAR badges show direction and the current Memory Score
— ✅ = reinforced memory
— ⚠️ = weakening memory
— ❌ = fading or depleted memory
— stronger zones remain visually dominant
— weaker zones use a softer palette
— archived zones are historical context, not active memory objects

📊 [b]Memory Map panel:[/b]

— Active Zones
— Strong Memory
— Average Memory Score

🔧 [b]Display controls:[/b]

— Both / Bullish Only / Bearish Only
— minimum displayed Memory Score
— Compact / Full / Off badge mode
— Dark / Light theme
— optional archived badges
— optional advanced candidate diagnostics

[b]🎨 VISUALS[/b]

Active maps use a constant forward display horizon. The default is 50 bars.
As each new bar forms, the right edge advances by one bar so the map keeps the same forward distance from the current bar.
This is a display convention only. It does not mean the script predicts that price will visit, respect or react from the zone during the next 50 bars.

[b]⚙️ KEY SETTINGS[/b]

⚙️ [b]Reaction structure:[/b]

— Pivot Left / Right: default 3 / 3
— Qualification Window: default 20 bars
— Minimum Reaction: default 2.00 ATR
— Zone Depth: default 0.30 ATR

🧹 [b]Zone quality:[/b]

— Same-Side Merge Distance: default 0.50 ATR
— Minimum Same-Side Birth Spacing: default 8 bars
— Maximum Active Zones: default 12

🧠 [b]Memory model:[/b]

— Time Decay Lookback: default 120 bars
— Touch Decay Weight: controls repeated-interaction decay
— Penetration Damage Weight: controls structural damage from penetration
— Reaction Evaluation Window: default 12 bars
— Reinforcement / weakening thresholds: define how completed retests modify evidence

♻️ [b]Lifecycle:[/b]

— Structural Invalidation Buffer: default 0.10 ATR
— Minimum Age Before Depletion: default 30 bars
— archived zones can remain visible after retirement

🎨 [b]Visual settings:[/b]

— Theme: Dark / Light
— Map Projection Bars: default 50
— Status Emoji: optional
— Badge Mode: Compact / Full / Off

🎚️ [b]Production controls:[/b]

— Active Side Filter: Both / Bullish Only / Bearish Only
— Minimum Displayed Score: visual filter only; hidden zones continue to be tracked internally

[b]🔔 ALERTS[/b]

The script provides confirmed-bar alert conditions for:
— Memory Zone Touch
— Strong Memory Zone Touch
— Memory Zone Reinforced
— Memory Zone Invalidated
— New Strong Memory Zone
— Any Price Reaction Memory Alert
The script also supports TradingView's "Any alert() function call" workflow for a combined dynamic event stream when enabled in settings.
Alerts describe changes in the reaction-memory model. They are not automated trade instructions.

[b]⚠️ IMPORTANT NOTES[/b]

— ⏳ [b]Pivot confirmation is delayed by design.[/b] A pivot is only known after the configured right-side bars have completed.
— 🕰️ [b]Historical zone origin is not realtime availability.[/b] After qualification, a zone can be drawn from its original pivot location for historical context. That does not mean the zone was known on that pivot bar; the pivot first required confirmation and the reaction then had to qualify.
— 📐 [b]Post-touch reaction excludes the touch bar.[/b] Standard OHLC data does not reveal whether the favorable extreme of that candle occurred before or after the zone interaction, so reaction measurement begins after the touch bar.
— 🧮 [b]Memory Score is not probability.[/b] It does not represent expected return, win rate, signal accuracy or the probability that a zone will hold.
— 🧱 [b]Structural invalidation uses confirmed closes.[/b] A wick can penetrate deeply and damage Zone Integrity without automatically invalidating the zone.
— ↔️ [b]The forward map is not a forecast.[/b] Projection length controls visual display only.
— 🗃️ [b]Archived zones are historical context.[/b] Once retired, they no longer participate as active memory objects.
— 🌐 [b]Zone density will differ across markets and timeframes.[/b] The model uses local ATR normalization rather than being tuned to one specific instrument.
— ⚡ Fast markets, gaps, session transitions, low-liquidity conditions and large volatility changes can cause zones to qualify, weaken, deplete or invalidate quickly.
— 🛠️ Changing model settings changes the meaning and lifecycle of the zones. Tighter settings do not automatically make the output more reliable.

[b]🛡️ DISCLAIMER[/b]

This script is provided for educational and analytical purposes. It does not provide financial advice or guarantee future market behavior.
Bullish/Bearish classifications, Memory Scores, reaction zones, lifecycle states, status markers and alerts describe the script's internal model only. They should be evaluated together with the user's own analysis, risk management and understanding of market conditions.

## Source Code

````pine
//@version=6
indicator("Price Reaction Memory Heatmap [tradewsamet]", "Price Reaction Memory Heatmap [tradewsamet]", overlay = true, max_labels_count = 220, max_boxes_count = 50)

// Release: v1
// Price Reaction Memory Heatmap models how confirmed reaction zones retain, lose, reinforce, and ultimately retire historical reaction memory.
// Memory Score is a descriptive 0-100 index built from reaction quality, freshness, retest resilience, zone integrity, and completed retest evidence.
// Bullish/Bearish labels describe zone direction. The script does not issue trade instructions, targets, stops, or probability forecasts.

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

string GROUP_CANDIDATE = "🧠 Reaction Candidate Engine"
string GROUP_REACTION  = "⚡ Reaction Qualification"
string GROUP_ZONE      = "🗂️ Memory Zone Engine"
string GROUP_QUALITY   = "🎯 Zone Quality Filter"
string GROUP_INTERACTION = "🔁 Interaction Engine"
string GROUP_MEMORY      = "🧠 Memory Decay Engine"
string GROUP_REINFORCE   = "🔄 Reinforcement & Failure"
string GROUP_SCORE       = "📊 Memory Score Model"
string GROUP_LIFECYCLE   = "♻️ Lifecycle & Invalidation"
string GROUP_VISUAL      = "🎨 Heatmap & Visual Identity"
string GROUP_PROD        = "🛠️ Production Controls"
string GROUP_ALERTS      = "🔔 Alerts"
string GROUP_SCALE     = "📐 Normalization"
string GROUP_DEBUG     = "🧪 Advanced Diagnostics"

int pivotLeft = input.int(
     3, "Pivot Left Bars",
     minval = 1, maxval = 20,
     group = GROUP_CANDIDATE,
     tooltip = "Bars required on the left side of a pivot.",
     display = display.none)

int pivotRight = input.int(
     3, "Pivot Right Bars",
     minval = 1, maxval = 20,
     group = GROUP_CANDIDATE,
     tooltip = "Bars required on the right side. A candidate is created only after these bars have closed.",
     display = display.none)

int qualificationWindow = input.int(
     20, "Qualification Window",
     minval = 5, maxval = 100,
     group = GROUP_REACTION,
     tooltip = "Maximum completed bars after confirmation in which a pending candidate may qualify.",
     display = display.none)

float reactionThresholdATR = input.float(
     2.00, "Minimum Reaction (ATR)",
     minval = 0.25, maxval = 10.0, step = 0.05,
     group = GROUP_REACTION,
     tooltip = "Minimum directional excursion from the pivot required to qualify. Distance is normalized by ATR captured on the confirmation bar.",
     display = display.none)

float zoneDepthATR = input.float(
     0.30, "Zone Depth (ATR)",
     minval = 0.05, maxval = 2.0, step = 0.05,
     group = GROUP_ZONE,
     tooltip = "Directional depth of a newly activated memory zone. Bullish zones extend upward from the pivot low; bearish zones extend downward from the pivot high. Width is normalized by ATR captured at candidate confirmation.",
     display = display.none)

bool showMemoryZones = input.bool(
     true, "Show Memory Zones",
     group = GROUP_ZONE,
     tooltip = "Displays reactions that pass the zone-quality gate. Active memory maps keep a constant forward projection horizon until structural invalidation, memory depletion, or capacity retirement removes them.",
     display = display.none)

float zoneMergeDistanceATR = input.float(
     0.50, "Same-Side Zone Merge Distance (ATR)",
     minval = 0.0, maxval = 5.0, step = 0.05,
     group = GROUP_QUALITY,
     tooltip = "A newly qualified reaction does not create another zone when its center is too close to an existing active zone of the same direction. Distance is normalized by ATR.",
     display = display.none)

int minSameSideBirthBars = input.int(
     8, "Minimum Same-Side Birth Bars",
     minval = 0, maxval = 100,
     group = GROUP_QUALITY,
     tooltip = "Minimum bars required between newly activated zones of the same direction. This reduces clusters created by closely timed reactions.",
     display = display.none)

int maxActiveZones = input.int(
     12, "Maximum Active Zones",
     minval = 2, maxval = 30,
     group = GROUP_QUALITY,
     tooltip = "Maximum number of active reaction-memory zones kept on the chart. When the cap is exceeded, the oldest active zone is removed.",
     display = display.none)

bool showMemoryScore = input.bool(
     true, "Show Memory Score",
     group = GROUP_SCORE,
     tooltip = "Displays the current 0-100 Memory Score beside each active zone. This score is a descriptive index built from reaction quality, freshness, retest resilience, zone integrity, and completed retest evidence. It is not a probability.",
     active = showMemoryZones,
     display = display.none)

bool showScoreBand = input.bool(
     false, "Show Score Band",
     group = GROUP_SCORE,
     tooltip = "Adds a compact score-band suffix to active memory badges: Strong, Active, Weakening, Fading, or Depleted.",
     active = showMemoryZones and showMemoryScore,
     display = display.none)

float invalidationBufferATR = input.float(
     0.10, "Invalidation Close Buffer (ATR)",
     minval = 0.0, maxval = 2.0, step = 0.05,
     group = GROUP_LIFECYCLE,
     tooltip = "A bullish zone is structurally invalidated when a confirmed close finishes below its lower edge by this ATR buffer. A bearish zone is invalidated by the mirrored condition.",
     display = display.none)

bool retireDepletedZones = input.bool(
     true, "Retire Depleted Memory",
     group = GROUP_LIFECYCLE,
     tooltip = "Stops extending a zone when its descriptive Memory Score falls into the depleted range after the minimum age. This is memory retirement, not structural invalidation.",
     display = display.none)

int depletionMinAgeBars = input.int(
     30, "Minimum Age Before Depletion",
     minval = 1, maxval = 2000,
     group = GROUP_LIFECYCLE,
     tooltip = "Minimum zone age required before a score below the depleted threshold can retire the zone.",
     display = display.none)

bool keepArchivedZones = input.bool(
     true, "Keep Archived Zones",
     group = GROUP_LIFECYCLE,
     tooltip = "Keeps a limited history of invalidated or depleted zones on the chart after they stop extending.",
     display = display.none)

int maxArchivedZones = input.int(
     20, "Maximum Archived Zones",
     minval = 0, maxval = 30,
     group = GROUP_LIFECYCLE,
     tooltip = "Maximum number of stopped invalidated/depleted zones retained for context.",
     active = keepArchivedZones,
     display = display.none)

bool showMemoryPanel = input.bool(
     true, "Show Memory Map Panel",
     group = GROUP_VISUAL,
     tooltip = "Displays a compact panel with Active Zones, Strong Memory count, and average active Memory Score.",
     display = display.none)

bool showArchivedBadges = input.bool(
     false, "Show Archived Badges",
     group = GROUP_VISUAL,
     tooltip = "Shows final score badges on invalidated/depleted historical zones. Off by default so archived context stays visually quiet.",
     active = keepArchivedZones,
     display = display.none)

bool emphasizeStrongZones = input.bool(
     true, "Emphasize Strong Memory",
     group = GROUP_VISUAL,
     tooltip = "Gives 80+ Memory Score zones slightly stronger visual contrast without changing the underlying model.",
     active = showMemoryZones,
     display = display.none)

string visualTheme = input.string(
     "Dark", "Visual Theme",
     options = ["Dark", "Light"],
     group = GROUP_VISUAL,
     tooltip = "Switches the indicator palette between a dark-chart version and a light-chart version.",
     display = display.none)

int mapProjectionBars = input.int(
     50, "Map Projection Bars",
     minval = 10, maxval = 300,
     group = GROUP_VISUAL,
     tooltip = "Active memory maps always project this many bars forward. As each new bar forms, the map shifts forward by one bar so the forward horizon stays constant.",
     active = showMemoryZones,
     display = display.none)

bool showStatusEmoji = input.bool(
     true, "Show Memory Status Emoji",
     group = GROUP_VISUAL,
     tooltip = "Makes weakening and fading memory maps easier to identify: ⚠️ for weakening and ❌ for fading/depleted memory. Reinforced maps use ✅.",
     active = showMemoryZones,
     display = display.none)

string activeSideFilter = input.string(
     "Both", "Active Side Filter",
     options = ["Both", "Bullish Only", "Bearish Only"],
     group = GROUP_PROD,
     tooltip = "Controls which active memory zones remain visible on the chart. This is a display filter only; the engine still tracks all active zones internally.",
     display = display.none)

int minimumDisplayedScore = input.int(
     0, "Minimum Displayed Score",
     minval = 0, maxval = 100,
     group = GROUP_PROD,
     tooltip = "Hides active zones whose current Memory Score is below this threshold. The engine still calculates them until normal retirement or invalidation.",
     display = display.none)

string badgeMode = input.string(
     "Compact", "Badge Mode",
     options = ["Compact", "Full", "Off"],
     group = GROUP_PROD,
     tooltip = "Compact uses BULL/BEAR with score. Full uses BULLISH/BEARISH. Off hides live badges while keeping zones visible.",
     active = showMemoryZones,
     display = display.none)

bool showOnlyStrongInPanel = input.bool(
     false, "Panel Uses Display Filter",
     group = GROUP_PROD,
     tooltip = "When enabled, the panel uses the current side filter and minimum displayed score. Otherwise it only respects side filter.",
     active = showMemoryPanel,
     display = display.none)

bool alertOnZoneTouch = input.bool(
     true, "Alert: Any Zone Touch",
     group = GROUP_ALERTS,
     tooltip = "Triggers when price newly enters any displayed active zone on a confirmed bar.",
     display = display.none)

bool alertOnStrongTouch = input.bool(
     true, "Alert: Strong Zone Touch",
     group = GROUP_ALERTS,
     tooltip = "Triggers when price newly enters a displayed active zone with Memory Score at or above the Strong threshold.",
     display = display.none)

bool alertOnReinforcement = input.bool(
     true, "Alert: Reinforced Retest",
     group = GROUP_ALERTS,
     tooltip = "Triggers when a completed interaction is classified as REINFORCED.",
     display = display.none)

bool alertOnInvalidation = input.bool(
     true, "Alert: Structural Invalidation",
     group = GROUP_ALERTS,
     tooltip = "Triggers when an active zone is structurally invalidated by a confirmed close beyond the far edge.",
     display = display.none)

bool alertOnNewStrongZone = input.bool(
     false, "Alert: New Strong Zone",
     group = GROUP_ALERTS,
     tooltip = "Triggers when a newly created zone begins with Memory Score at or above the Strong threshold.",
     display = display.none)

bool enableAnyAlertCall = input.bool(
     true, "Enable Any alert() Function Call",
     group = GROUP_ALERTS,
     tooltip = "Enables one dynamic bar-close alert() message when any enabled memory event occurs. Use TradingView's 'Any alert() function call' option for this combined stream.",
     display = display.none)

int timeDecayLookback = input.int(
     120, "Time Decay Lookback",
     minval = 10, maxval = 2000,
     group = GROUP_MEMORY,
     tooltip = "Controls how quickly zone memory fades with age. At an age equal to this value, the time factor is 0.50.",
     display = display.none)

float touchDecayWeight = input.float(
     0.20, "Touch Decay Weight",
     minval = 0.0, maxval = 2.0, step = 0.05,
     group = GROUP_MEMORY,
     tooltip = "Controls memory loss from repeated distinct retests. Higher values penalize repeatedly used zones more strongly.",
     display = display.none)

float penetrationDamageWeight = input.float(
     0.70, "Penetration Damage Weight",
     minval = 0.0, maxval = 1.0, step = 0.05,
     group = GROUP_MEMORY,
     tooltip = "Controls memory damage from the deepest historical penetration into the zone. Penetration is bounded to 0-100%.",
     display = display.none)

float minimumMemoryFloor = input.float(
     0.15, "Minimum Memory Floor",
     minval = 0.0, maxval = 0.50, step = 0.05,
     group = GROUP_MEMORY,
     tooltip = "Temporary floor for ACTIVE zones in the raw decay model. Later lifecycle stages can still invalidate and remove a zone.",
     display = display.none)

float initialReactionNormalizerATR = input.float(
     3.00, "Initial Reaction Normalizer (ATR)",
     minval = 0.50, maxval = 10.0, step = 0.25,
     group = GROUP_MEMORY,
     tooltip = "Initial reaction strength reaches full quality at this ATR multiple. Smaller qualified reactions begin with proportionally lower raw memory.",
     display = display.none)

int reactionEvaluationBars = input.int(
     12, "Reaction Evaluation Window",
     minval = 3, maxval = 100,
     group = GROUP_REINFORCE,
     tooltip = "Maximum bars used to evaluate the outcome of a retest. A new retest can finalize the previous interaction earlier.",
     display = display.none)

float reinforceReactionATR = input.float(
     1.00, "Reinforcement Reaction (ATR)",
     minval = 0.10, maxval = 10.0, step = 0.05,
     group = GROUP_REINFORCE,
     tooltip = "Minimum post-touch favorable excursion required for a completed interaction to qualify as reinforced.",
     display = display.none)

float reinforceMaxPenetration = input.float(
     0.60, "Maximum Reinforcement Penetration",
     minval = 0.0, maxval = 1.0, step = 0.05,
     group = GROUP_REINFORCE,
     tooltip = "A reinforced interaction must stay at or below this maximum zone penetration. 0.60 means no deeper than 60% of zone depth.",
     display = display.none)

float weakenReactionATR = input.float(
     0.50, "Weak Reaction Threshold (ATR)",
     minval = 0.0, maxval = 10.0, step = 0.05,
     group = GROUP_REINFORCE,
     tooltip = "A deep interaction with post-touch reaction below this value can be classified as weakened.",
     display = display.none)

float weakenMinPenetration = input.float(
     0.70, "Minimum Weakening Penetration",
     minval = 0.0, maxval = 1.0, step = 0.05,
     group = GROUP_REINFORCE,
     tooltip = "Minimum penetration required before a weak reaction can damage the zone's evidence factor.",
     display = display.none)

float reinforcementBoost = input.float(
     0.22, "Reinforcement Boost",
     minval = 0.0, maxval = 1.0, step = 0.01,
     group = GROUP_REINFORCE,
     tooltip = "Maximum evidence-factor increase contributed by one reinforced interaction. The actual increase is scaled by reaction strength and penetration quality.",
     display = display.none)

float weakeningPenalty = input.float(
     0.28, "Weakening Penalty",
     minval = 0.0, maxval = 1.0, step = 0.01,
     group = GROUP_REINFORCE,
     tooltip = "Maximum evidence-factor reduction contributed by one weakened interaction. The actual reduction is scaled by penetration severity and reaction weakness.",
     display = display.none)

int atrLength = input.int(
     14, "ATR Length",
     minval = 1, maxval = 200,
     group = GROUP_SCALE,
     tooltip = "ATR is only a scale-normalization unit for spacing, reaction distance, and zone depth. It does not determine direction.",
     display = display.none)

float minSeparationATR = input.float(
     0.35, "Minimum Same-Side Separation (ATR)",
     minval = 0.0, maxval = 5.0, step = 0.05,
     group = GROUP_SCALE,
     tooltip = "Nearby pending candidates of the same direction are treated as one local reaction area. The more extreme pivot is retained.",
     display = display.none)

bool showDiagnostics = input.bool(
     false, "Show Candidate Diagnostics",
     group = GROUP_DEBUG,
     tooltip = "Optional diagnostics for candidate formation. Pending candidates use △/▽. Keep disabled for the clean release view.",
     display = display.none)

bool showExpired = input.bool(
     false, "Keep Expired Markers",
     group = GROUP_DEBUG,
     tooltip = "Shows a small × when a pending candidate expires. Available only while Advanced Diagnostics are enabled.",
     active = showDiagnostics,
     display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const int DIR_BULL = 1
const int DIR_BEAR = -1

const int ZONE_ACTIVE = 0

const int TERMINAL_NONE        = 0
const int TERMINAL_INVALIDATED = 1
const int TERMINAL_DEPLETED    = 2

const int OUTCOME_NONE       = 0
const int OUTCOME_REINFORCED = 1
const int OUTCOME_NEUTRAL    = 2
const int OUTCOME_WEAKENED   = 3

const float EVIDENCE_MIN = 0.55
const float EVIDENCE_MAX = 1.40

// Memory Score weights. They intentionally sum to 1.00.
const float SCORE_W_REACTION    = 0.25
const float SCORE_W_FRESHNESS   = 0.20
const float SCORE_W_RETEST      = 0.15
const float SCORE_W_INTEGRITY   = 0.20
const float SCORE_W_EVIDENCE    = 0.20

const int SCORE_STRONG_MIN      = 80
const int SCORE_ACTIVE_MIN      = 60
const int SCORE_WEAKENING_MIN   = 40
const int SCORE_FADING_MIN      = 20

const int MAX_EXPIRED_MARKERS = 40

color BULL_COLOR        = visualTheme == "Dark" ? #22D3EE : #0284C7
color BEAR_COLOR        = visualTheme == "Dark" ? #F472B6 : #DB2777
color BULL_SOFT_COLOR   = visualTheme == "Dark" ? #67E8F9 : #0891B2
color BEAR_SOFT_COLOR   = visualTheme == "Dark" ? #F9A8D4 : #BE185D
color EXPIRED_COLOR     = visualTheme == "Dark" ? #94A3B8 : #64748B
color PANEL_BG          = visualTheme == "Dark" ? #111318 : #FFFFFF
color PANEL_FRAME       = visualTheme == "Dark" ? #2B3038 : #CBD5E1
color PANEL_TEXT        = visualTheme == "Dark" ? #F3F4F6 : #0F172A
color PANEL_MUTED       = visualTheme == "Dark" ? #9CA3AF : #475569

// ─────────────────────────────────────────────────────────────────────────────
// PENDING STORAGE
// Only pending candidates are scanned on each confirmed bar.
// ─────────────────────────────────────────────────────────────────────────────

var array<int>   pId         = array.new<int>()
var array<int>   pDir        = array.new<int>()
var array<int>   pPivotBar   = array.new<int>()
var array<int>   pConfirmBar = array.new<int>()
var array<float> pPrice      = array.new<float>()
var array<float> pAtr        = array.new<float>()
var array<float> pMaxExc     = array.new<float>()
var array<label> pMarker     = array.new<label>()

// ─────────────────────────────────────────────────────────────────────────────
// MEMORY ZONE STORAGE
// Zones are created only after a candidate qualifies.
// Active zones retain interaction, decay, and outcome state. Only the small active-zone set is scanned each confirmed bar.
// ─────────────────────────────────────────────────────────────────────────────

var array<int>   zId                 = array.new<int>()
var array<int>   zDir                = array.new<int>()
var array<int>   zPivotBar           = array.new<int>()
var array<int>   zConfirmBar         = array.new<int>()
var array<int>   zBirthBar           = array.new<int>()
var array<float> zPivotPrice         = array.new<float>()
var array<float> zAtr                = array.new<float>()
var array<float> zTop                = array.new<float>()
var array<float> zBottom             = array.new<float>()
var array<float> zInitialReactionATR = array.new<float>()
var array<int>   zState              = array.new<int>()

// Interaction state. Only the small active-zone population is scanned each confirmed bar.
var array<int>   zTouchCount          = array.new<int>()
var array<int>   zFirstRetestBar      = array.new<int>()
var array<int>   zLastInteractionBar  = array.new<int>()
var array<int>   zInteractionStartBar = array.new<int>()
var array<bool>  zWasInside           = array.new<bool>()
var array<float> zCurrentPenetration  = array.new<float>()
var array<float> zLastPenetration     = array.new<float>()
var array<float> zMaxPenetration      = array.new<float>()
var array<bool>  zReactionTracking    = array.new<bool>()
var array<float> zCurrentReactionATR  = array.new<float>()
var array<float> zLastReactionATR     = array.new<float>()
var array<float> zMaxReactionATR      = array.new<float>()

// Raw memory state. The displayed integer cache avoids needless chart-object updates.
var array<float> zMemoryStrength      = array.new<float>()
var array<int>   zDisplayedMemory     = array.new<int>()

// Descriptive Memory Score is kept separately from raw multiplicative decay memory
// so both layers remain auditable in tooltips.
var array<float> zMemoryScore         = array.new<float>()
var array<int>   zDisplayedScore      = array.new<int>()

// Outcome memory. Evidence starts neutral at 1.0 and is adjusted only when a retest is finalized.
var array<float> zEvidenceFactor       = array.new<float>()
var array<int>   zLastOutcome          = array.new<int>()
var array<int>   zLastOutcomeBar       = array.new<int>()
var array<float> zLastOutcomePen       = array.new<float>()
var array<float> zLastOutcomeReaction  = array.new<float>()
var array<int>   zReinforcedCount      = array.new<int>()
var array<int>   zNeutralCount         = array.new<int>()
var array<int>   zWeakenedCount        = array.new<int>()

var array<box>   zBox                = array.new<box>()
var array<label> zMarker             = array.new<label>()

// Terminal chart objects are detached from active-zone state so the active engine
// stays bounded and light. Only a small visual history is retained.
var array<box>   archivedBoxes        = array.new<box>()
var array<label> archivedMarkers      = array.new<label>()

var array<label> expiredMarkers = array.new<label>()

var table memoryPanel = table.new(
     position.top_right,
     2,
     4,
     bgcolor = color.new(PANEL_BG, 8),
     frame_color = color.new(PANEL_FRAME, 25),
     frame_width = 1,
     border_width = 0)

// Confirmed-bar alert buses.
var bool barAlertZoneTouch        = false
var bool barAlertStrongTouch      = false
var bool barAlertReinforced       = false
var bool barAlertInvalidated      = false
var bool barAlertNewStrongZone    = false
var string barAlertZoneText       = ""
var string barAlertStrongText     = ""
var string barAlertReinforcedText = ""
var string barAlertInvalidText    = ""
var string barAlertNewStrongText  = ""

var int nextCandidateId = 1

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

f_dirName(int dir) =>
    dir == DIR_BULL ? "Bullish" : "Bearish"

f_pendingSymbol(int dir) =>
    dir == DIR_BULL ? "△" : "▽"

f_dirColor(int dir) =>
    dir == DIR_BULL ? BULL_COLOR : BEAR_COLOR

f_zoneVisualColor(int dir, float memoryScore) =>
    bool useSoftColor = memoryScore < SCORE_ACTIVE_MIN
    dir == DIR_BULL
         ? (useSoftColor ? BULL_SOFT_COLOR : BULL_COLOR)
         : (useSoftColor ? BEAR_SOFT_COLOR : BEAR_COLOR)

f_reactionATR(float excursion, float atrRef) =>
    not na(atrRef) and atrRef > 0.0 ? excursion / atrRef : na

f_isQualified(float excursion, float atrRef) =>
    float reactionATR = f_reactionATR(excursion, atrRef)
    not na(reactionATR) and reactionATR >= reactionThresholdATR

f_pendingTooltip(int dir, int id, int pivotBar, int confirmBar, float pivotPrice, float atrRef, float maxExc) =>
    float reactionATR = f_reactionATR(maxExc, atrRef)
    f_dirName(dir) + " Candidate" +
     "\nID: " + str.tostring(id) +
     "\nPivot: " + str.tostring(pivotPrice, format.mintick) +
     "\nPivot bar: " + str.tostring(pivotBar) +
     "\nConfirmed bar: " + str.tostring(confirmBar) +
     "\nMax reaction: " + (na(reactionATR) ? "n/a" : str.tostring(reactionATR, "#.##") + " ATR") +
     "\nRequired: " + str.tostring(reactionThresholdATR, "#.##") + " ATR" +
     "\nState: PENDING"

f_memoryMetrics(
     int birthBar,
     float initialReactionATR,
     int touchCount,
     float maxPenetration,
     float evidenceFactor) =>

    int ageBars = math.max(0, bar_index - birthBar)

    float initialQuality = math.min(
         1.0,
         math.max(0.0, initialReactionATR / initialReactionNormalizerATR))

    float timeFactor = 1.0 / (1.0 + ageBars / float(timeDecayLookback))
    float touchFactor = 1.0 / (1.0 + touchCount * touchDecayWeight)
    float penetrationFactor = math.max(
         0.0,
         1.0 - math.min(1.0, math.max(0.0, maxPenetration)) * penetrationDamageWeight)

    float baseMemory = initialQuality * timeFactor * touchFactor * penetrationFactor
    float adjustedMemory = baseMemory * evidenceFactor
    float memoryStrength = math.min(1.0, math.max(minimumMemoryFloor, adjustedMemory))

    [initialQuality, timeFactor, touchFactor, penetrationFactor, baseMemory, memoryStrength]

f_evidenceScore(float evidenceFactor) =>
    // Piecewise normalization keeps neutral evidenceFactor=1.0 at exactly 0.50.
    // EVIDENCE_MIN -> 0.00, 1.00 -> 0.50, EVIDENCE_MAX -> 1.00.
    float normalized = evidenceFactor >= 1.0
         ? 0.50 + 0.50 * (evidenceFactor - 1.0) / math.max(0.000001, EVIDENCE_MAX - 1.0)
         : 0.50 * (evidenceFactor - EVIDENCE_MIN) / math.max(0.000001, 1.0 - EVIDENCE_MIN)

    math.min(1.0, math.max(0.0, normalized))

f_memoryScoreComponents(
     int birthBar,
     float initialReactionATR,
     int touchCount,
     float maxPenetration,
     float evidenceFactor) =>

    int ageBars = math.max(0, bar_index - birthBar)

    float reactionQuality = math.min(
         1.0,
         math.max(0.0, initialReactionATR / initialReactionNormalizerATR))

    float freshness = 1.0 / (1.0 + ageBars / float(timeDecayLookback))
    float retestResilience = 1.0 / (1.0 + touchCount * touchDecayWeight)

    float zoneIntegrity = math.max(
         0.0,
         1.0 - math.min(1.0, math.max(0.0, maxPenetration)) * penetrationDamageWeight)

    float outcomeEvidence = f_evidenceScore(evidenceFactor)

    float weighted =
         reactionQuality * SCORE_W_REACTION +
         freshness * SCORE_W_FRESHNESS +
         retestResilience * SCORE_W_RETEST +
         zoneIntegrity * SCORE_W_INTEGRITY +
         outcomeEvidence * SCORE_W_EVIDENCE

    float memoryScore = math.min(100.0, math.max(0.0, weighted * 100.0))

    [reactionQuality, freshness, retestResilience, zoneIntegrity, outcomeEvidence, memoryScore]

f_scoreBand(float memoryScore) =>
    memoryScore >= SCORE_STRONG_MIN ? "STRONG" :
     memoryScore >= SCORE_ACTIVE_MIN ? "ACTIVE" :
     memoryScore >= SCORE_WEAKENING_MIN ? "WEAKENING" :
     memoryScore >= SCORE_FADING_MIN ? "FADING" :
     "DEPLETED"

f_scoreBandShort(float memoryScore) =>
    memoryScore >= SCORE_STRONG_MIN ? "S" :
     memoryScore >= SCORE_ACTIVE_MIN ? "A" :
     memoryScore >= SCORE_WEAKENING_MIN ? "W" :
     memoryScore >= SCORE_FADING_MIN ? "F" :
     "D"

f_lifecycleName(
     int birthBar,
     int touchCount,
     int lastOutcome,
     float memoryScore) =>

    int ageBars = math.max(0, bar_index - birthBar)

    memoryScore < SCORE_FADING_MIN ? "DEPLETED" :
     memoryScore < SCORE_WEAKENING_MIN ? "FADING" :
     lastOutcome == OUTCOME_WEAKENED ? "WEAKENED" :
     lastOutcome == OUTCOME_REINFORCED ? "REINFORCED" :
     touchCount > 0 ? "TESTED" :
     ageBars <= 1 ? "NEW" :
     "ACTIVE"

f_terminalName(int terminalReason) =>
    terminalReason == TERMINAL_INVALIDATED ? "INVALIDATED" :
     terminalReason == TERMINAL_DEPLETED ? "DEPLETED" :
     "NONE"

f_isStructurallyInvalidated(int dir, float zoneTop, float zoneBottom, float atrRef) =>
    float buffer = math.max(0.0, atrRef * invalidationBufferATR)

    dir == DIR_BULL
         ? close < zoneBottom - buffer
         : close > zoneTop + buffer

f_outcomeName(int outcome) =>
    outcome == OUTCOME_REINFORCED ? "REINFORCED" :
     outcome == OUTCOME_WEAKENED ? "WEAKENED" :
     outcome == OUTCOME_NEUTRAL ? "NEUTRAL" :
     "NONE"

f_isZoneAllowedBySide(int dir) =>
    activeSideFilter == "Both" or
     (activeSideFilter == "Bullish Only" and dir == DIR_BULL) or
     (activeSideFilter == "Bearish Only" and dir == DIR_BEAR)

f_isZoneDisplayEligible(int dir, float memoryScore) =>
    showMemoryZones and
     f_isZoneAllowedBySide(dir) and
     memoryScore >= minimumDisplayedScore

f_directionBadge(int dir) =>
    badgeMode == "Full"
         ? (dir == DIR_BULL ? "BULLISH" : "BEARISH")
         : (dir == DIR_BULL ? "BULL" : "BEAR")

f_memoryStatusEmoji(float memoryScore, int lastOutcome) =>
    if not showStatusEmoji
        ""
    else if memoryScore < SCORE_WEAKENING_MIN
        "❌ "
    else if memoryScore < SCORE_ACTIVE_MIN or lastOutcome == OUTCOME_WEAKENED
        "⚠️ "
    else if lastOutcome == OUTCOME_REINFORCED
        "✅ "
    else
        ""

f_memoryMarkerText(int dir, float memoryScore, int lastOutcome) =>
    string outcomeSuffix = lastOutcome == OUTCOME_REINFORCED ? "+" :
         lastOutcome == OUTCOME_WEAKENED ? "-" : ""
    string bandSuffix = showScoreBand ? " · " + f_scoreBandShort(memoryScore) : ""

    badgeMode == "Off"
         ? ""
         : f_memoryStatusEmoji(memoryScore, lastOutcome) +
           f_directionBadge(dir) + " · M" +
           str.tostring(int(math.round(memoryScore))) +
           outcomeSuffix + bandSuffix

f_memoryFillTransparency(float memoryScore) =>
    memoryScore >= SCORE_STRONG_MIN
         ? (emphasizeStrongZones ? 70 : 74)
         : memoryScore >= SCORE_ACTIVE_MIN
         ? 78
         : memoryScore >= SCORE_WEAKENING_MIN
         ? 83
         : memoryScore >= SCORE_FADING_MIN
         ? 87
         : 91

f_memoryBorderTransparency(float memoryScore) =>
    memoryScore >= SCORE_STRONG_MIN
         ? (emphasizeStrongZones ? 22 : 30)
         : memoryScore >= SCORE_ACTIVE_MIN
         ? 38
         : memoryScore >= SCORE_WEAKENING_MIN
         ? 48
         : memoryScore >= SCORE_FADING_MIN
         ? 58
         : 70

f_badgeTransparency(float memoryScore) =>
    memoryScore >= SCORE_STRONG_MIN ? 8 :
     memoryScore >= SCORE_ACTIVE_MIN ? 18 :
     memoryScore >= SCORE_WEAKENING_MIN ? 28 :
     memoryScore >= SCORE_FADING_MIN ? 38 :
     48

f_zoneTooltip(
     int dir,
     int id,
     int pivotBar,
     int confirmBar,
     int birthBar,
     float pivotPrice,
     float atrRef,
     float zoneTop,
     float zoneBottom,
     float reactionATR,
     int touchCount,
     int firstRetestBar,
     int lastInteractionBar,
     float maxPenetration,
     float currentReactionATR,
     float lastReactionATR,
     float maxReactionATR,
     float evidenceFactor,
     int lastOutcome,
     int lastOutcomeBar,
     float lastOutcomePenetration,
     float lastOutcomeReactionATR,
     int reinforcedCount,
     int neutralCount,
     int weakenedCount) =>

    [initialQuality, timeFactor, touchFactor, penetrationFactor, baseMemory, memoryStrength] =
         f_memoryMetrics(birthBar, reactionATR, touchCount, maxPenetration, evidenceFactor)

    [scoreReaction, scoreFreshness, scoreRetest, scoreIntegrity, scoreEvidence, memoryScore] =
         f_memoryScoreComponents(birthBar, reactionATR, touchCount, maxPenetration, evidenceFactor)

    int ageBars = math.max(0, bar_index - birthBar)

    string tooltipText =
         f_dirName(dir) + " Memory Zone" +
         "\nZone ID: " + str.tostring(id) +
         "\nPivot: " + str.tostring(pivotPrice, format.mintick) +
         "\nPivot bar: " + str.tostring(pivotBar) +
         "\nConfirmed bar: " + str.tostring(confirmBar) +
         "\nActivated bar: " + str.tostring(birthBar) +
         "\nInitial reaction: " + str.tostring(reactionATR, "#.##") + " ATR" +
         "\nZone top: " + str.tostring(zoneTop, format.mintick) +
         "\nZone bottom: " + str.tostring(zoneBottom, format.mintick) +
         "\nATR reference: " + str.tostring(atrRef, format.mintick) +
         "\nTouches: " + str.tostring(touchCount) +
         "\nMax penetration: " + str.tostring(maxPenetration * 100.0, "#.#") + "% (capped at zone depth)" +
         "\nCurrent post-touch reaction: " + str.tostring(currentReactionATR, "#.##") + " ATR" +
         "\nLast completed reaction: " + str.tostring(lastReactionATR, "#.##") + " ATR" +
         "\nMax post-touch reaction: " + str.tostring(maxReactionATR, "#.##") + " ATR" +
         "\nAge: " + str.tostring(ageBars) + " bars" +
         "\nInitial quality: " + str.tostring(initialQuality * 100.0, "#.#") + "%" +
         "\nTime factor: " + str.tostring(timeFactor, "#.###") +
         "\nTouch factor: " + str.tostring(touchFactor, "#.###") +
         "\nPenetration factor: " + str.tostring(penetrationFactor, "#.###") +
         "\nBase memory: " + str.tostring(baseMemory * 100.0, "#.#") + "%" +
         "\nEvidence factor: " + str.tostring(evidenceFactor, "#.###") +
         "\nDecay memory: " + str.tostring(memoryStrength * 100.0, "#.#") + "%" +
         "\nMemory Score: " + str.tostring(memoryScore, "#.#") + " / 100" +
         "\nScore band: " + f_scoreBand(memoryScore) +
         "\nScore Reaction Quality: " + str.tostring(scoreReaction * 100.0, "#.#") +
         "\nScore Freshness: " + str.tostring(scoreFreshness * 100.0, "#.#") +
         "\nScore Retest Resilience: " + str.tostring(scoreRetest * 100.0, "#.#") +
         "\nScore Zone Integrity: " + str.tostring(scoreIntegrity * 100.0, "#.#") +
         "\nScore Outcome Evidence: " + str.tostring(scoreEvidence * 100.0, "#.#") +
         "\nIndex note: descriptive memory score, not probability" +
         "\nLast outcome: " + f_outcomeName(lastOutcome) +
         "\nOutcome counts R/N/W: " + str.tostring(reinforcedCount) + "/" + str.tostring(neutralCount) + "/" + str.tostring(weakenedCount) +
         "\nLifecycle: " + f_lifecycleName(birthBar, touchCount, lastOutcome, memoryScore) +
         "\nEngine state: ACTIVE"

    if not na(firstRetestBar)
        tooltipText += "\nFirst retest bar: " + str.tostring(firstRetestBar)

    if not na(lastInteractionBar)
        tooltipText +=
             "\nLast interaction bar: " + str.tostring(lastInteractionBar) +
             "\nBars since interaction: " + str.tostring(bar_index - lastInteractionBar)

    if lastOutcome != OUTCOME_NONE and not na(lastOutcomeBar)
        tooltipText +=
             "\nLast outcome bar: " + str.tostring(lastOutcomeBar) +
             "\nLast outcome penetration: " + str.tostring(lastOutcomePenetration * 100.0, "#.#") + "%" +
             "\nLast outcome reaction: " + str.tostring(lastOutcomeReactionATR, "#.##") + " ATR"

    tooltipText

f_makePendingMarker(int dir, int id, int pivotBar, int confirmBar, float pivotPrice, float atrRef, float maxExc) =>
    label marker = na
    if showDiagnostics
        marker := label.new(
             pivotBar, pivotPrice,
             f_pendingSymbol(dir),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = f_dirColor(dir),
             size = size.small)
        label.set_tooltip(marker, f_pendingTooltip(dir, id, pivotBar, confirmBar, pivotPrice, atrRef, maxExc))
    marker

f_makeZoneMarker(
     int dir,
     int id,
     int pivotBar,
     int confirmBar,
     int birthBar,
     float pivotPrice,
     float atrRef,
     float zoneTop,
     float zoneBottom,
     float reactionATR) =>

    label marker = na
    if showMemoryScore
        float midPrice = (zoneTop + zoneBottom) * 0.5
        color baseColor = f_dirColor(dir)

        marker := label.new(
             x = birthBar + 1,
             y = midPrice,
             text = f_memoryMarkerText(dir, 0.0, OUTCOME_NONE),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.new(baseColor, 28),
             textcolor = color.white,
             size = size.small)

        label.set_tooltip(
             marker,
             f_zoneTooltip(
                 dir, id, pivotBar, confirmBar, birthBar,
                 pivotPrice, atrRef, zoneTop, zoneBottom, reactionATR,
                 0, na, na, 0.0, 0.0, 0.0, 0.0,
                 1.0, OUTCOME_NONE, na, 0.0, 0.0, 0, 0, 0))
    marker


f_makeZoneBox(int dir, int pivotBar, int birthBar, float zoneTop, float zoneBottom) =>
    box zoneBox = na
    if showMemoryZones
        color baseColor = f_dirColor(dir)
        zoneBox := box.new(
             left = pivotBar,
             top = zoneTop,
             right = birthBar + mapProjectionBars,
             bottom = zoneBottom,
             xloc = xloc.bar_index,
             extend = extend.none,
             border_color = color.new(baseColor, 62),
             border_width = 1,
             bgcolor = color.new(baseColor, 90))
    zoneBox

f_zoneOverlap(float zoneTop, float zoneBottom) =>
    high >= zoneBottom and low <= zoneTop

f_penetrationRatio(int dir, float zoneTop, float zoneBottom) =>
    float depth = math.max(syminfo.mintick, zoneTop - zoneBottom)
    float rawPenetration = dir == DIR_BULL
         ? (zoneTop - low) / depth
         : (high - zoneBottom) / depth

    // Penetration describes depth *inside* the zone, so it is physically bounded to 0-100%.
    // A move beyond the far edge is a later lifecycle/invalidation concern, not 400% penetration.
    math.min(1.0, math.max(0.0, rawPenetration))

f_postTouchReactionATR(int dir, float zoneTop, float zoneBottom, float atrRef) =>
    if na(atrRef) or atrRef <= 0.0
        0.0
    else
        float excursion = dir == DIR_BULL
             ? math.max(0.0, high - zoneTop)
             : math.max(0.0, zoneBottom - low)
        excursion / atrRef

f_refreshZoneMemory(int index, bool forceUpdate) =>
    int dir = array.get(zDir, index)
    int birthBar = array.get(zBirthBar, index)
    float initialReactionATR = array.get(zInitialReactionATR, index)
    int touchCount = array.get(zTouchCount, index)
    float maxPenetration = array.get(zMaxPenetration, index)
    float evidenceFactor = array.get(zEvidenceFactor, index)
    int lastOutcome = array.get(zLastOutcome, index)

    [initialQuality, timeFactor, touchFactor, penetrationFactor, baseMemory, memoryStrength] =
         f_memoryMetrics(birthBar, initialReactionATR, touchCount, maxPenetration, evidenceFactor)

    [scoreReaction, scoreFreshness, scoreRetest, scoreIntegrity, scoreEvidence, memoryScore] =
         f_memoryScoreComponents(birthBar, initialReactionATR, touchCount, maxPenetration, evidenceFactor)

    array.set(zMemoryStrength, index, memoryStrength)
    array.set(zMemoryScore, index, memoryScore)

    int memoryPct = int(math.round(memoryStrength * 100.0))
    int scorePct = int(math.round(memoryScore))
    int displayedMemoryPct = array.get(zDisplayedMemory, index)
    int displayedScorePct = array.get(zDisplayedScore, index)
    bool eligibleDisplay = f_isZoneDisplayEligible(dir, memoryScore)

    bool visualChanged =
         forceUpdate or
         memoryPct != displayedMemoryPct or
         scorePct != displayedScorePct

    if visualChanged
        array.set(zDisplayedMemory, index, memoryPct)
        array.set(zDisplayedScore, index, scorePct)

        color baseColor = f_dirColor(dir)
        color zoneColor = f_zoneVisualColor(dir, memoryScore)
        color badgeColor = baseColor
        box zoneBox = array.get(zBox, index)

        if not na(zoneBox)
            box.set_right(zoneBox, bar_index + mapProjectionBars)
            box.set_bgcolor(
                 zoneBox,
                 eligibleDisplay ? color.new(zoneColor, f_memoryFillTransparency(memoryScore)) : color.new(zoneColor, 100))
            box.set_border_color(
                 zoneBox,
                 eligibleDisplay ? color.new(zoneColor, f_memoryBorderTransparency(memoryScore)) : color.new(zoneColor, 100))

        label marker = array.get(zMarker, index)

        if not na(marker)
            label.set_text(marker, eligibleDisplay ? f_memoryMarkerText(dir, memoryScore, lastOutcome) : "")
            label.set_color(marker, color.new(badgeColor, eligibleDisplay and badgeMode != "Off" ? f_badgeTransparency(memoryScore) : 100))
            label.set_textcolor(marker, color.white)
            label.set_size(
                 marker,
                 showStatusEmoji and memoryScore < SCORE_ACTIVE_MIN
                      ? size.normal
                      : size.small)
            label.set_tooltip(
                 marker,
                 f_zoneTooltip(
                     dir,
                     array.get(zId, index),
                     array.get(zPivotBar, index),
                     array.get(zConfirmBar, index),
                     birthBar,
                     array.get(zPivotPrice, index),
                     array.get(zAtr, index),
                     array.get(zTop, index),
                     array.get(zBottom, index),
                     initialReactionATR,
                     touchCount,
                     array.get(zFirstRetestBar, index),
                     array.get(zLastInteractionBar, index),
                     maxPenetration,
                     array.get(zCurrentReactionATR, index),
                     array.get(zLastReactionATR, index),
                     array.get(zMaxReactionATR, index),
                     evidenceFactor,
                     lastOutcome,
                     array.get(zLastOutcomeBar, index),
                     array.get(zLastOutcomePen, index),
                     array.get(zLastOutcomeReaction, index),
                     array.get(zReinforcedCount, index),
                     array.get(zNeutralCount, index),
                     array.get(zWeakenedCount, index)))

    // Keep the badge aligned to the active right edge even when the rounded score
    // does not change on this bar.
    label liveMarker = array.get(zMarker, index)
    if not na(liveMarker) and f_isZoneDisplayEligible(dir, array.get(zMemoryScore, index)) and badgeMode != "Off"
        label.set_x(liveMarker, bar_index + 1)
        label.set_y(liveMarker, (array.get(zTop, index) + array.get(zBottom, index)) * 0.5)


f_classifyInteraction(float penetration, float reactionATR) =>
    bool reinforced = reactionATR >= reinforceReactionATR and penetration <= reinforceMaxPenetration
    bool weakened = penetration >= weakenMinPenetration and reactionATR < weakenReactionATR

    reinforced ? OUTCOME_REINFORCED :
     weakened ? OUTCOME_WEAKENED :
     OUTCOME_NEUTRAL

f_finalizeInteraction(int index) =>
    if array.get(zReactionTracking, index)
        float penetration = math.min(1.0, math.max(0.0, array.get(zCurrentPenetration, index)))
        float reactionATR = math.max(0.0, array.get(zCurrentReactionATR, index))
        int outcome = f_classifyInteraction(penetration, reactionATR)

        float evidenceFactor = array.get(zEvidenceFactor, index)

        if outcome == OUTCOME_REINFORCED
            float reactionQuality = math.min(
                 1.0,
                 reactionATR / math.max(0.000001, reinforceReactionATR * 1.50))
            float penetrationQuality = 1.0 - penetration * 0.50
            float boost = reinforcementBoost * reactionQuality * penetrationQuality

            evidenceFactor := math.min(EVIDENCE_MAX, evidenceFactor + boost)
            array.set(zReinforcedCount, index, array.get(zReinforcedCount, index) + 1)

        else if outcome == OUTCOME_WEAKENED
            float reactionWeakness = 1.0 - math.min(
                 1.0,
                 reactionATR / math.max(0.000001, weakenReactionATR))
            float penalty = weakeningPenalty * penetration * reactionWeakness

            evidenceFactor := math.max(EVIDENCE_MIN, evidenceFactor - penalty)
            array.set(zWeakenedCount, index, array.get(zWeakenedCount, index) + 1)

        else
            array.set(zNeutralCount, index, array.get(zNeutralCount, index) + 1)

        array.set(zEvidenceFactor, index, evidenceFactor)
        array.set(zLastOutcome, index, outcome)
        array.set(zLastOutcomeBar, index, bar_index)
        array.set(zLastOutcomePen, index, penetration)
        array.set(zLastOutcomeReaction, index, reactionATR)
        array.set(zLastPenetration, index, penetration)
        array.set(zLastReactionATR, index, reactionATR)
        array.set(zReactionTracking, index, false)


f_addExpiredMarker(int dir, int pivotBar, float pivotPrice) =>
    if showDiagnostics and showExpired
        label marker = label.new(
             pivotBar, pivotPrice,
             "×",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_none,
             textcolor = EXPIRED_COLOR,
             size = size.tiny)
        array.push(expiredMarkers, marker)

        if array.size(expiredMarkers) > MAX_EXPIRED_MARKERS
            label oldest = array.shift(expiredMarkers)
            if not na(oldest)
                label.delete(oldest)

f_removePendingAt(int index, bool deleteMarker) =>
    label marker = array.get(pMarker, index)
    if deleteMarker and not na(marker)
        label.delete(marker)

    array.remove(pId, index)
    array.remove(pDir, index)
    array.remove(pPivotBar, index)
    array.remove(pConfirmBar, index)
    array.remove(pPrice, index)
    array.remove(pAtr, index)
    array.remove(pMaxExc, index)
    array.remove(pMarker, index)

f_removeZoneAt(int index, bool deleteObjects) =>
    box zoneBox = array.get(zBox, index)
    label zoneMarker = array.get(zMarker, index)

    if deleteObjects
        if not na(zoneBox)
            box.delete(zoneBox)
        if not na(zoneMarker)
            label.delete(zoneMarker)

    array.remove(zId, index)
    array.remove(zDir, index)
    array.remove(zPivotBar, index)
    array.remove(zConfirmBar, index)
    array.remove(zBirthBar, index)
    array.remove(zPivotPrice, index)
    array.remove(zAtr, index)
    array.remove(zTop, index)
    array.remove(zBottom, index)
    array.remove(zInitialReactionATR, index)
    array.remove(zState, index)
    array.remove(zTouchCount, index)
    array.remove(zFirstRetestBar, index)
    array.remove(zLastInteractionBar, index)
    array.remove(zInteractionStartBar, index)
    array.remove(zWasInside, index)
    array.remove(zCurrentPenetration, index)
    array.remove(zLastPenetration, index)
    array.remove(zMaxPenetration, index)
    array.remove(zReactionTracking, index)
    array.remove(zCurrentReactionATR, index)
    array.remove(zLastReactionATR, index)
    array.remove(zMaxReactionATR, index)
    array.remove(zMemoryStrength, index)
    array.remove(zDisplayedMemory, index)
    array.remove(zMemoryScore, index)
    array.remove(zDisplayedScore, index)
    array.remove(zEvidenceFactor, index)
    array.remove(zLastOutcome, index)
    array.remove(zLastOutcomeBar, index)
    array.remove(zLastOutcomePen, index)
    array.remove(zLastOutcomeReaction, index)
    array.remove(zReinforcedCount, index)
    array.remove(zNeutralCount, index)
    array.remove(zWeakenedCount, index)
    array.remove(zBox, index)
    array.remove(zMarker, index)


f_trimArchivedObjects() =>
    int limit = keepArchivedZones ? maxArchivedZones : 0

    while array.size(archivedBoxes) > limit
        box oldBox = array.shift(archivedBoxes)
        if not na(oldBox)
            box.delete(oldBox)

    while array.size(archivedMarkers) > limit
        label oldMarker = array.shift(archivedMarkers)
        if not na(oldMarker)
            label.delete(oldMarker)

f_archiveZone(int index, int terminalReason) =>
    int dir = array.get(zDir, index)
    int id = array.get(zId, index)
    int birthBar = array.get(zBirthBar, index)
    int touchCount = array.get(zTouchCount, index)
    int lastOutcome = array.get(zLastOutcome, index)
    float memoryScore = array.get(zMemoryScore, index)
    float maxPenetration = array.get(zMaxPenetration, index)
    float evidenceFactor = array.get(zEvidenceFactor, index)

    box zoneBox = array.get(zBox, index)
    label marker = array.get(zMarker, index)

    string terminalText = f_terminalName(terminalReason)
    string lifecycleBefore = f_lifecycleName(birthBar, touchCount, lastOutcome, memoryScore)


    if not na(zoneBox)
        box.set_extend(zoneBox, extend.none)
        box.set_right(zoneBox, bar_index)
        box.set_bgcolor(zoneBox, color.new(EXPIRED_COLOR, 93))
        box.set_border_color(zoneBox, color.new(EXPIRED_COLOR, 72))

    if not na(marker)
        if showArchivedBadges
            label.set_x(marker, bar_index)
            label.set_y(marker, (array.get(zTop, index) + array.get(zBottom, index)) * 0.5)
            string archivedEmoji =
                 not showStatusEmoji ? "" :
                 terminalReason == TERMINAL_INVALIDATED ? "❌ " : "⚠️ "

            color archivedColor =
                 terminalReason == TERMINAL_INVALIDATED
                      ? (visualTheme == "Dark" ? #DC2626 : #B91C1C)
                      : EXPIRED_COLOR

            label.set_text(
                 marker,
                 archivedEmoji + "ARCHIVED · M" + str.tostring(int(math.round(memoryScore))))
            label.set_style(marker, label.style_label_left)
            label.set_color(marker, color.new(archivedColor, 42))
            label.set_textcolor(marker, color.white)
            label.set_size(marker, size.normal)
            label.set_tooltip(
                 marker,
                 f_dirName(dir) + " Memory Zone" +
                 "\nZone ID: " + str.tostring(id) +
                 "\nTerminal state: " + terminalText +
                 "\nPrevious lifecycle: " + lifecycleBefore +
                 "\nFinal Memory Score: " + str.tostring(memoryScore, "#.#") + " / 100" +
                 "\nTouches: " + str.tostring(touchCount) +
                 "\nMax penetration: " + str.tostring(maxPenetration * 100.0, "#.#") + "%" +
                 "\nEvidence factor: " + str.tostring(evidenceFactor, "#.###") +
                 "\nStopped bar: " + str.tostring(bar_index) +
                 "\nIndex note: descriptive memory score, not probability")
        else
            label.delete(marker)
            marker := na

    if keepArchivedZones and maxArchivedZones > 0
        if not na(zoneBox)
            array.push(archivedBoxes, zoneBox)
        if not na(marker)
            array.push(archivedMarkers, marker)
    else
        if not na(zoneBox)
            box.delete(zoneBox)
        if not na(marker)
            label.delete(marker)

    // Detach terminal zone from all active-state arrays without deleting retained objects.
    f_removeZoneAt(index, false)
    f_trimArchivedObjects()

f_findNearbyActiveZone(int dir, float newTop, float newBottom, float atrRef) =>
    int foundIndex = -1
    float nearestDistance = 1e20
    float newCenter = (newTop + newBottom) * 0.5
    int count = array.size(zId)

    if count > 0
        for i = 0 to count - 1
            if array.get(zDir, i) == dir and array.get(zState, i) == ZONE_ACTIVE
                float existingCenter = (array.get(zTop, i) + array.get(zBottom, i)) * 0.5
                float existingAtr = array.get(zAtr, i)
                float allowedDistance = math.max(atrRef, existingAtr) * zoneMergeDistanceATR
                float distance = math.abs(newCenter - existingCenter)

                if distance <= allowedDistance and distance < nearestDistance
                    nearestDistance := distance
                    foundIndex := i

    foundIndex

f_lastSameSideBirthBar(int dir) =>
    int latestBirth = na
    int count = array.size(zId)

    if count > 0
        for i = 0 to count - 1
            if array.get(zDir, i) == dir and array.get(zState, i) == ZONE_ACTIVE
                int birth = array.get(zBirthBar, i)
                latestBirth := na(latestBirth) ? birth : math.max(latestBirth, birth)

    latestBirth

f_zonePassesQualityGate(int dir, int birthBar, float zoneTop, float zoneBottom, float atrRef) =>
    int latestBirth = f_lastSameSideBirthBar(dir)
    bool spacingPass = na(latestBirth) or birthBar - latestBirth >= minSameSideBirthBars
    bool proximityPass = f_findNearbyActiveZone(dir, zoneTop, zoneBottom, atrRef) == -1
    spacingPass and proximityPass

f_removeOldestZone() =>
    if array.size(zId) > 0
        box oldestBox = array.shift(zBox)
        label oldestMarker = array.shift(zMarker)

        if not na(oldestBox)
            box.delete(oldestBox)
        if not na(oldestMarker)
            label.delete(oldestMarker)

        array.shift(zId)
        array.shift(zDir)
        array.shift(zPivotBar)
        array.shift(zConfirmBar)
        array.shift(zBirthBar)
        array.shift(zPivotPrice)
        array.shift(zAtr)
        array.shift(zTop)
        array.shift(zBottom)
        array.shift(zInitialReactionATR)
        array.shift(zState)
        array.shift(zTouchCount)
        array.shift(zFirstRetestBar)
        array.shift(zLastInteractionBar)
        array.shift(zInteractionStartBar)
        array.shift(zWasInside)
        array.shift(zCurrentPenetration)
        array.shift(zLastPenetration)
        array.shift(zMaxPenetration)
        array.shift(zReactionTracking)
        array.shift(zCurrentReactionATR)
        array.shift(zLastReactionATR)
        array.shift(zMaxReactionATR)
        array.shift(zMemoryStrength)
        array.shift(zDisplayedMemory)
        array.shift(zMemoryScore)
        array.shift(zDisplayedScore)
        array.shift(zEvidenceFactor)
        array.shift(zLastOutcome)
        array.shift(zLastOutcomeBar)
        array.shift(zLastOutcomePen)
        array.shift(zLastOutcomeReaction)
        array.shift(zReinforcedCount)
        array.shift(zNeutralCount)
        array.shift(zWeakenedCount)


f_createMemoryZone(
     int id,
     int dir,
     int pivotBar,
     int confirmBar,
     int birthBar,
     float pivotPrice,
     float atrRef,
     float reactionATR) =>

    float zoneDepth = math.max(syminfo.mintick, atrRef * zoneDepthATR)
    float zoneTop = dir == DIR_BULL ? pivotPrice + zoneDepth : pivotPrice
    float zoneBottom = dir == DIR_BULL ? pivotPrice : pivotPrice - zoneDepth

    bool created = false

    if f_zonePassesQualityGate(dir, birthBar, zoneTop, zoneBottom, atrRef)
        box zoneBox = f_makeZoneBox(dir, pivotBar, birthBar, zoneTop, zoneBottom)
        label marker = f_makeZoneMarker(
             dir, id, pivotBar, confirmBar, birthBar,
             pivotPrice, atrRef, zoneTop, zoneBottom, reactionATR)

        array.push(zId, id)
        array.push(zDir, dir)
        array.push(zPivotBar, pivotBar)
        array.push(zConfirmBar, confirmBar)
        array.push(zBirthBar, birthBar)
        array.push(zPivotPrice, pivotPrice)
        array.push(zAtr, atrRef)
        array.push(zTop, zoneTop)
        array.push(zBottom, zoneBottom)
        array.push(zInitialReactionATR, reactionATR)
        array.push(zState, ZONE_ACTIVE)

        // New zones begin with no retest history. The formation pivot itself is not counted as a touch.
        array.push(zTouchCount, 0)
        array.push(zFirstRetestBar, na)
        array.push(zLastInteractionBar, na)
        array.push(zInteractionStartBar, na)
        array.push(zWasInside, false)
        array.push(zCurrentPenetration, 0.0)
        array.push(zLastPenetration, 0.0)
        array.push(zMaxPenetration, 0.0)
        array.push(zReactionTracking, false)
        array.push(zCurrentReactionATR, 0.0)
        array.push(zLastReactionATR, 0.0)
        array.push(zMaxReactionATR, 0.0)

        array.push(zMemoryStrength, 0.0)
        array.push(zDisplayedMemory, -1)
        array.push(zMemoryScore, 0.0)
        array.push(zDisplayedScore, -1)

        array.push(zEvidenceFactor, 1.0)
        array.push(zLastOutcome, OUTCOME_NONE)
        array.push(zLastOutcomeBar, na)
        array.push(zLastOutcomePen, 0.0)
        array.push(zLastOutcomeReaction, 0.0)
        array.push(zReinforcedCount, 0)
        array.push(zNeutralCount, 0)
        array.push(zWeakenedCount, 0)

        array.push(zBox, zoneBox)
        array.push(zMarker, marker)

        // Apply birth-time memory immediately after all aligned arrays exist.
        int newIndex = array.size(zId) - 1
        f_refreshZoneMemory(newIndex, true)

        while array.size(zId) > maxActiveZones
            f_removeOldestZone()

        created := true

    created

f_findNearbyPending(int dir, float pivotPrice, float atrRef) =>
    int foundIndex = -1
    float nearestDistance = 1e20
    int count = array.size(pId)

    if count > 0
        for i = 0 to count - 1
            if array.get(pDir, i) == dir
                float storedPrice = array.get(pPrice, i)
                float storedAtr = array.get(pAtr, i)
                float separation = math.max(atrRef, storedAtr) * minSeparationATR
                float distance = math.abs(pivotPrice - storedPrice)

                if distance <= separation and distance < nearestDistance
                    nearestDistance := distance
                    foundIndex := i

    foundIndex

f_addPending(int id, int dir, int pivotBar, int confirmBar, float pivotPrice, float atrRef, float initialExc) =>
    label marker = f_makePendingMarker(dir, id, pivotBar, confirmBar, pivotPrice, atrRef, initialExc)

    array.push(pId, id)
    array.push(pDir, dir)
    array.push(pPivotBar, pivotBar)
    array.push(pConfirmBar, confirmBar)
    array.push(pPrice, pivotPrice)
    array.push(pAtr, atrRef)
    array.push(pMaxExc, initialExc)
    array.push(pMarker, marker)

f_renderMemoryPanel() =>
    int totalZones = array.size(zId)
    int activeCount = 0
    int strongCount = 0
    float scoreSum = 0.0

    if totalZones > 0
        for i = 0 to totalZones - 1
            int dir = array.get(zDir, i)
            float score = array.get(zMemoryScore, i)
            bool eligible = showOnlyStrongInPanel ? f_isZoneDisplayEligible(dir, score) : f_isZoneAllowedBySide(dir)

            if eligible
                activeCount += 1
                scoreSum += score

                if score >= SCORE_STRONG_MIN
                    strongCount += 1

    float avgScore = activeCount > 0 ? scoreSum / activeCount : na

    if showMemoryPanel
        table.cell(
             memoryPanel, 0, 0, "MEMORY MAP",
             text_color = PANEL_TEXT,
             bgcolor = color.new(PANEL_BG, 0),
             text_size = size.small)
        table.cell(
             memoryPanel, 1, 0, "LIVE",
             text_color = BULL_COLOR,
             bgcolor = color.new(PANEL_BG, 0),
             text_size = size.tiny)

        table.cell(memoryPanel, 0, 1, "Active Zones", text_color = PANEL_MUTED, text_size = size.tiny)
        table.cell(memoryPanel, 1, 1, str.tostring(activeCount), text_color = PANEL_TEXT, text_size = size.tiny)

        table.cell(memoryPanel, 0, 2, "Strong Memory", text_color = PANEL_MUTED, text_size = size.tiny)
        table.cell(memoryPanel, 1, 2, str.tostring(strongCount), text_color = PANEL_TEXT, text_size = size.tiny)

        table.cell(memoryPanel, 0, 3, "Avg Memory", text_color = PANEL_MUTED, text_size = size.tiny)
        table.cell(
             memoryPanel, 1, 3,
             activeCount > 0 ? str.tostring(avgScore, "#") : "—",
             text_color = PANEL_TEXT,
             text_size = size.tiny)
    else
        table.clear(memoryPanel, 0, 0, 1, 3)

// ─────────────────────────────────────────────────────────────────────────────
// CORE SERIES
// ─────────────────────────────────────────────────────────────────────────────

float atrNow = ta.atr(atrLength)
float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

// Calculate rolling extremes on every bar.
// Keeping history-dependent ta.* calls outside conditional scopes avoids
// consistency warnings and guarantees the same series state on every calculation.
float reactionWindowHigh = ta.highest(high, pivotRight + 1)
float reactionWindowLow = ta.lowest(low, pivotRight + 1)

// ─────────────────────────────────────────────────────────────────────────────
// MAINTAIN ACTIVE ZONE INTERACTIONS
// A touch is counted only on an OUTSIDE -> INSIDE transition after zone activation.
// Staying inside the zone for multiple bars remains one interaction.
// ─────────────────────────────────────────────────────────────────────────────

if barstate.isconfirmed
    barAlertZoneTouch := false
    barAlertStrongTouch := false
    barAlertReinforced := false
    barAlertInvalidated := false
    barAlertNewStrongZone := false
    barAlertZoneText := ""
    barAlertStrongText := ""
    barAlertReinforcedText := ""
    barAlertInvalidText := ""
    barAlertNewStrongText := ""

    int zoneCount = array.size(zId)

    if zoneCount > 0
        for i = zoneCount - 1 to 0
            if array.get(zState, i) == ZONE_ACTIVE and bar_index > array.get(zBirthBar, i)
                int dir = array.get(zDir, i)
                float zoneTop = array.get(zTop, i)
                float zoneBottom = array.get(zBottom, i)
                float atrRef = array.get(zAtr, i)
                int birthBar = array.get(zBirthBar, i)
                float memoryScoreBefore = array.get(zMemoryScore, i)
                int ageBars = math.max(0, bar_index - birthBar)

                bool structurallyInvalidated =
                     f_isStructurallyInvalidated(dir, zoneTop, zoneBottom, atrRef)

                bool memoryDepleted =
                     retireDepletedZones and
                     ageBars >= depletionMinAgeBars and
                     memoryScoreBefore < SCORE_FADING_MIN

                if structurallyInvalidated
                    if alertOnInvalidation and f_isZoneAllowedBySide(dir)
                        barAlertInvalidated := true
                        barAlertInvalidText := f_dirName(dir) + " structural invalidation | Final Score " + str.tostring(memoryScoreBefore, "#")

                    f_archiveZone(i, TERMINAL_INVALIDATED)

                else if memoryDepleted
                    f_archiveZone(i, TERMINAL_DEPLETED)

                else
                    bool insideNow = f_zoneOverlap(zoneTop, zoneBottom)
                    bool wasInside = array.get(zWasInside, i)
                    bool trackingReaction = array.get(zReactionTracking, i)
                    bool diagnosticsChanged = false

                    // New distinct interaction: OUTSIDE -> INSIDE.
                    if insideNow and not wasInside
                        float zoneScoreBeforeTouch = array.get(zMemoryScore, i)

                        if alertOnZoneTouch and f_isZoneDisplayEligible(dir, zoneScoreBeforeTouch)
                            barAlertZoneTouch := true
                            barAlertZoneText := f_dirName(dir) + " zone touch | Score " + str.tostring(zoneScoreBeforeTouch, "#")

                        if alertOnStrongTouch and zoneScoreBeforeTouch >= SCORE_STRONG_MIN and f_isZoneDisplayEligible(dir, zoneScoreBeforeTouch)
                            barAlertStrongTouch := true
                            barAlertStrongText := f_dirName(dir) + " strong zone touch | Score " + str.tostring(zoneScoreBeforeTouch, "#")

                        // A new retest closes the previous evaluation cycle early.
                        if trackingReaction
                            f_finalizeInteraction(i)

                            if alertOnReinforcement and array.get(zLastOutcome, i) == OUTCOME_REINFORCED and f_isZoneAllowedBySide(dir)
                                barAlertReinforced := true
                                barAlertReinforcedText := f_dirName(dir) + " reinforced retest"

                            diagnosticsChanged := true

                        int newTouchCount = array.get(zTouchCount, i) + 1
                        array.set(zTouchCount, i, newTouchCount)

                        if na(array.get(zFirstRetestBar, i))
                            array.set(zFirstRetestBar, i, bar_index)

                        array.set(zLastInteractionBar, i, bar_index)
                        array.set(zInteractionStartBar, i, bar_index)
                        array.set(zCurrentPenetration, i, 0.0)
                        array.set(zCurrentReactionATR, i, 0.0)
                        array.set(zReactionTracking, i, true)
                        diagnosticsChanged := true

                    // Penetration exists only while price overlaps the zone.
                    if insideNow
                        float penetration = f_penetrationRatio(dir, zoneTop, zoneBottom)
                        float currentPenetration = math.max(array.get(zCurrentPenetration, i), penetration)
                        float previousMaxPenetration = array.get(zMaxPenetration, i)

                        array.set(zCurrentPenetration, i, currentPenetration)
                        array.set(zLastInteractionBar, i, bar_index)

                        if currentPenetration > previousMaxPenetration
                            array.set(zMaxPenetration, i, currentPenetration)
                            diagnosticsChanged := true

                    // Leaving the zone finalizes the penetration depth of that interaction.
                    if wasInside and not insideNow
                        array.set(zLastPenetration, i, array.get(zCurrentPenetration, i))

                    // Once a touch has occurred, measure favorable excursion until the next touch.
                    // The first touch bar is excluded because OHLC data cannot prove whether the
                    // favorable extreme happened before or after the zone interaction.
                    int interactionStartBar = array.get(zInteractionStartBar, i)
                    if array.get(zReactionTracking, i) and not na(interactionStartBar) and bar_index > interactionStartBar
                        float reactionNowATR = f_postTouchReactionATR(dir, zoneTop, zoneBottom, atrRef)
                        float currentReactionATR = math.max(array.get(zCurrentReactionATR, i), reactionNowATR)
                        float previousMaxReactionATR = array.get(zMaxReactionATR, i)

                        array.set(zCurrentReactionATR, i, currentReactionATR)

                        if currentReactionATR > previousMaxReactionATR
                            array.set(zMaxReactionATR, i, currentReactionATR)
                            diagnosticsChanged := true

                    // Use a fixed maximum horizon so outcome classification is comparable
                    // across zones. A new retest can still finalize the cycle earlier.
                    interactionStartBar := array.get(zInteractionStartBar, i)
                    if array.get(zReactionTracking, i) and not na(interactionStartBar)
                        int evaluationAge = bar_index - interactionStartBar

                        if evaluationAge >= reactionEvaluationBars
                            f_finalizeInteraction(i)

                            if alertOnReinforcement and array.get(zLastOutcome, i) == OUTCOME_REINFORCED and f_isZoneAllowedBySide(dir)
                                barAlertReinforced := true
                                barAlertReinforcedText := f_dirName(dir) + " reinforced retest"

                            diagnosticsChanged := true

                    array.set(zWasInside, i, insideNow)

                    // Memory evolves with both interactions and age. Chart objects update only
                    // when the rounded M-score changes or interaction state forces a refresh.
                    f_refreshZoneMemory(i, diagnosticsChanged)

// ─────────────────────────────────────────────────────────────────────────────
// MAINTAIN ONLY PENDING CANDIDATES
// Qualifying candidates leave the pending population. Only reactions passing the quality gate become visible zones.
// ─────────────────────────────────────────────────────────────────────────────

if barstate.isconfirmed
    int pendingCount = array.size(pId)

    if pendingCount > 0
        for i = pendingCount - 1 to 0
            int dir = array.get(pDir, i)
            float pivotPrice = array.get(pPrice, i)
            float atrRef = array.get(pAtr, i)
            int confirmBar = array.get(pConfirmBar, i)
            int ageBars = bar_index - confirmBar

            if ageBars > qualificationWindow
                f_addExpiredMarker(dir, array.get(pPivotBar, i), pivotPrice)
                f_removePendingAt(i, true)
            else
                float currentExc = dir == DIR_BULL
                     ? math.max(0.0, high - pivotPrice)
                     : math.max(0.0, pivotPrice - low)

                float updatedMaxExc = math.max(array.get(pMaxExc, i), currentExc)
                array.set(pMaxExc, i, updatedMaxExc)

                if f_isQualified(updatedMaxExc, atrRef)
                    int id = array.get(pId, i)
                    int pivotBar = array.get(pPivotBar, i)
                    float reactionATR = f_reactionATR(updatedMaxExc, atrRef)

                    f_removePendingAt(i, true)
                    bool createdZone = f_createMemoryZone(
                         id, dir, pivotBar, confirmBar, bar_index,
                         pivotPrice, atrRef, reactionATR)

                    if createdZone and alertOnNewStrongZone and array.size(zId) > 0
                        int createdIndex = array.size(zId) - 1
                        float createdScore = array.get(zMemoryScore, createdIndex)
                        if createdScore >= SCORE_STRONG_MIN and f_isZoneAllowedBySide(dir)
                            barAlertNewStrongZone := true
                            barAlertNewStrongText := f_dirName(dir) + " new strong memory zone | Score " + str.tostring(createdScore, "#")
                else
                    label marker = array.get(pMarker, i)
                    if not na(marker)
                        label.set_tooltip(
                             marker,
                             f_pendingTooltip(
                                 dir,
                                 array.get(pId, i),
                                 array.get(pPivotBar, i),
                                 confirmBar,
                                 pivotPrice,
                                 atrRef,
                                 updatedMaxExc))

// ─────────────────────────────────────────────────────────────────────────────
// BULLISH CANDIDATE
// ─────────────────────────────────────────────────────────────────────────────

bool bullishPivotConfirmed = barstate.isconfirmed and not na(pivotLow) and not na(atrNow)

if bullishPivotConfirmed
    int pivotBar = bar_index - pivotRight
    float pivotPrice = pivotLow
    float initialExc = math.max(0.0, reactionWindowHigh - pivotPrice)
    int nearbyIndex = f_findNearbyPending(DIR_BULL, pivotPrice, atrNow)

    if nearbyIndex >= 0
        float existingPrice = array.get(pPrice, nearbyIndex)

        // Lower is more extreme for bullish candidates.
        if pivotPrice < existingPrice
            int id = array.get(pId, nearbyIndex)
            f_removePendingAt(nearbyIndex, true)

            if f_isQualified(initialExc, atrNow)
                bool createdZone = f_createMemoryZone(
                     id, DIR_BULL, pivotBar, bar_index, bar_index,
                     pivotPrice, atrNow, f_reactionATR(initialExc, atrNow))

                if createdZone and alertOnNewStrongZone and array.size(zId) > 0
                    int createdIndex = array.size(zId) - 1
                    float createdScore = array.get(zMemoryScore, createdIndex)
                    if createdScore >= SCORE_STRONG_MIN and f_isZoneAllowedBySide(DIR_BULL)
                        barAlertNewStrongZone := true
                        barAlertNewStrongText := f_dirName(DIR_BULL) + " new strong memory zone | Score " + str.tostring(createdScore, "#")
            else
                f_addPending(
                     id, DIR_BULL, pivotBar, bar_index,
                     pivotPrice, atrNow, initialExc)
    else
        int id = nextCandidateId
        nextCandidateId += 1

        if f_isQualified(initialExc, atrNow)
            bool createdZone = f_createMemoryZone(
                 id, DIR_BULL, pivotBar, bar_index, bar_index,
                 pivotPrice, atrNow, f_reactionATR(initialExc, atrNow))

            if createdZone and alertOnNewStrongZone and array.size(zId) > 0
                int createdIndex = array.size(zId) - 1
                float createdScore = array.get(zMemoryScore, createdIndex)
                if createdScore >= SCORE_STRONG_MIN and f_isZoneAllowedBySide(DIR_BULL)
                    barAlertNewStrongZone := true
                    barAlertNewStrongText := f_dirName(DIR_BULL) + " new strong memory zone | Score " + str.tostring(createdScore, "#")
        else
            f_addPending(
                 id, DIR_BULL, pivotBar, bar_index,
                 pivotPrice, atrNow, initialExc)

// ─────────────────────────────────────────────────────────────────────────────
// BEARISH CANDIDATE
// ─────────────────────────────────────────────────────────────────────────────

bool bearishPivotConfirmed = barstate.isconfirmed and not na(pivotHigh) and not na(atrNow)

if bearishPivotConfirmed
    int pivotBar = bar_index - pivotRight
    float pivotPrice = pivotHigh
    float initialExc = math.max(0.0, pivotPrice - reactionWindowLow)
    int nearbyIndex = f_findNearbyPending(DIR_BEAR, pivotPrice, atrNow)

    if nearbyIndex >= 0
        float existingPrice = array.get(pPrice, nearbyIndex)

        // Higher is more extreme for bearish candidates.
        if pivotPrice > existingPrice
            int id = array.get(pId, nearbyIndex)
            f_removePendingAt(nearbyIndex, true)

            if f_isQualified(initialExc, atrNow)
                bool createdZone = f_createMemoryZone(
                     id, DIR_BEAR, pivotBar, bar_index, bar_index,
                     pivotPrice, atrNow, f_reactionATR(initialExc, atrNow))

                if createdZone and alertOnNewStrongZone and array.size(zId) > 0
                    int createdIndex = array.size(zId) - 1
                    float createdScore = array.get(zMemoryScore, createdIndex)
                    if createdScore >= SCORE_STRONG_MIN and f_isZoneAllowedBySide(DIR_BEAR)
                        barAlertNewStrongZone := true
                        barAlertNewStrongText := f_dirName(DIR_BEAR) + " new strong memory zone | Score " + str.tostring(createdScore, "#")
            else
                f_addPending(
                     id, DIR_BEAR, pivotBar, bar_index,
                     pivotPrice, atrNow, initialExc)
    else
        int id = nextCandidateId
        nextCandidateId += 1

        if f_isQualified(initialExc, atrNow)
            bool createdZone = f_createMemoryZone(
                 id, DIR_BEAR, pivotBar, bar_index, bar_index,
                 pivotPrice, atrNow, f_reactionATR(initialExc, atrNow))

            if createdZone and alertOnNewStrongZone and array.size(zId) > 0
                int createdIndex = array.size(zId) - 1
                float createdScore = array.get(zMemoryScore, createdIndex)
                if createdScore >= SCORE_STRONG_MIN and f_isZoneAllowedBySide(DIR_BEAR)
                    barAlertNewStrongZone := true
                    barAlertNewStrongText := f_dirName(DIR_BEAR) + " new strong memory zone | Score " + str.tostring(createdScore, "#")
        else
            f_addPending(
                 id, DIR_BEAR, pivotBar, bar_index,
                 pivotPrice, atrNow, initialExc)


// ─────────────────────────────────────────────────────────────────────────────
// MEMORY MAP PANEL
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast
    f_renderMemoryPanel()


// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

bool anyMemoryAlert =
     barAlertZoneTouch or
     barAlertStrongTouch or
     barAlertReinforced or
     barAlertInvalidated or
     barAlertNewStrongZone

alertcondition(barAlertZoneTouch, "Memory Zone Touch", "A confirmed bar entered an active displayed memory zone.")
alertcondition(barAlertStrongTouch, "Strong Memory Zone Touch", "A confirmed bar entered an active strong memory zone.")
alertcondition(barAlertReinforced, "Memory Zone Reinforced", "A completed interaction reinforced a memory zone.")
alertcondition(barAlertInvalidated, "Memory Zone Invalidated", "A memory zone was structurally invalidated.")
alertcondition(barAlertNewStrongZone, "New Strong Memory Zone", "A newly created memory zone started in the strong band.")
alertcondition(anyMemoryAlert, "Any Price Reaction Memory Alert", "A Price Reaction Memory Heatmap event occurred on a confirmed bar.")

if barstate.isconfirmed and enableAnyAlertCall and anyMemoryAlert
    string dynamicAlertMessage = ""

    if barAlertStrongTouch
        dynamicAlertMessage += (dynamicAlertMessage == "" ? "" : " | ") + barAlertStrongText
    else if barAlertZoneTouch
        dynamicAlertMessage += (dynamicAlertMessage == "" ? "" : " | ") + barAlertZoneText

    if barAlertReinforced
        dynamicAlertMessage += (dynamicAlertMessage == "" ? "" : " | ") + barAlertReinforcedText

    if barAlertInvalidated
        dynamicAlertMessage += (dynamicAlertMessage == "" ? "" : " | ") + barAlertInvalidText

    if barAlertNewStrongZone
        dynamicAlertMessage += (dynamicAlertMessage == "" ? "" : " | ") + barAlertNewStrongText

    alert(
         dynamicAlertMessage == "" ? "Price Reaction Memory Heatmap event" : dynamicAlertMessage,
         alert.freq_once_per_bar_close)
````
