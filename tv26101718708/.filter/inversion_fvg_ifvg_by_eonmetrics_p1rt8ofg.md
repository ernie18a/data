# Inversion FVG (iFVG) by EonMetrics

- url: https://www.tradingview.com/script/P1Rt8Ofg-Inversion-FVG-iFVG-by-EonMetrics/
- type: indicator
- pine_id: PUB;e05418795342445db75dc3177b14b7b2
- version: 3.0

## Description

Inversion FVG (iFVG) by EonMetrics

🔶[b]WHAT IT DOES[/b]

A "fair value gap" (FVG) is a three-candle pattern where price moved so fast that the wicks of the first and third candle never overlapped — leaving a void on the chart that the market skipped over. While an FVG is fresh, traders typically expect a bullish gap to act as support and a bearish gap as resistance.

https://www.tradingview.com/x/VD4ZdpQy/

This indicator focuses on the moment that expectation FAILS — and on how it fails. An inversion FVG (iFVG) happens when price displaces through an existing gap with enough force to print a NEW fair value gap in the opposite direction, overlapping the old one. The inversion zone drawn by this script is the COMMON GROUND of those two opposing gaps — the price area where both imbalances intersect. That is where one side got trapped: broken demand turns into supply, broken supply turns into demand, and the market tends to defend that exact area when price returns to it.

https://www.tradingview.com/x/1TNYrQZq/

It is a structure-annotation tool: it shows you where these events happen and how significant they were. It deliberately does not give buy/sell signals, entries, targets, stops, or win-rate statistics.

🔶[b]HOW THIS SCRIPT IS DIFFERENT[/b]

Most inversion-FVG tools use a simple rule: when a candle closes through a gap, the whole gap is recolored and called inverted. This script uses a stricter, structural definition, and adds level-management logic around it:

1. Two gaps required, intersection drawn. A slow drift through an FVG does not create an inversion here. The traversal must be violent enough to leave a fresh FVG in the opposite direction, and the zone drawn is only the overlap of the two gaps — the exact prices where the old imbalance and the new one coincide — not the whole original gap.

2. Spent levels never invert. The first candle close through the far side of a gap opens a short pairing window. If no opposing gap confirms within it, the level is considered spent and permanently dropped. Levels that price has already chopped through several times can never produce a late, meaningless inversion zone.

3. Levels are remembered independently of what you see. A gap's box may be mitigated and removed from the chart, yet its price range keeps working invisibly as a candidate level for a configurable number of bars. The displacement that flips a level often arrives well after the gap was first touched — display and detection are deliberately separated.

4. Partial consumption. When an opposing gap overlaps only part of a remembered level, only that part is consumed; the remainder stays available. A small opposing gap therefore cannot "steal" a large level from a later, proper displacement. One inverting gap can flip several remembered levels at once, and the resulting zones never overlap each other.

5. Two-condition strength grading. An inversion is tagged STRONG only when the inverting gap is both large relative to volatility AND backed by elevated volume on its displacement candle — size or volume alone is not enough.

🔶[b]HOW IT DETECTS EACH EVENT (THE EXACT METHOD)[/b]

1. Regular FVG: on every closed bar the script checks the classic three-candle condition — for a bullish gap, the current bar's low must be above the high from two bars ago (mirrored for bearish). Gaps smaller than a chosen multiple of ATR (a standard volatility unit, measured at the moment the gap forms) are ignored. By default these regular gaps stay INVISIBLE — they are tracked in the background purely as raw material for inversions, so the chart shows only what the tool is about: the inversion zones. One switch reveals them as a quiet context layer if you want to see what may flip next.

2. Regular FVG expiry (display): each displayed gap lives until price mitigates it, by your rules — at its 50% midpoint or only on a full fill, touched by any wick or requiring a candle close. Mitigated gaps disappear, or stay frozen as reference if you prefer. This controls only what you SEE.

3. Level memory (detection): independently of the display, every detected gap's price range is remembered for a set number of bars from its creation (Inversion Memory). A remembered level dies early if price closes through its far side and no opposing gap confirms within the pairing window (Pairing Window After Break) — that level is spent.

4. Inversion (iFVG): when a fresh gap forms in the OPPOSITE direction of a remembered level and their price ranges overlap, the inversion fires:
- The drawn zone is the intersection of the two full gaps: its top is the lower of the two gap tops, its bottom is the higher of the two gap bottoms.
- An overlap thinner than the Min FVG Size threshold neither draws a zone nor consumes the level.
- The zone is colored by its new role: support (a bearish gap was displaced upward through) or resistance (a bullish gap was displaced downward through).
- The zone is drawn starting from the ORIGINAL gap's origin, so you see the full history of the level — from the moment the imbalance first appeared, through the displacement that flipped it.
- The zone's age counter, retest and expiry logic are anchored at the inversion moment, not at the original gap.

5. Strong grading: the NEW (inverting) gap is measured. If its height is at least a chosen multiple of ATR AND the volume of its displacement candle exceeds the 20-bar volume average by a chosen multiplier, the inversion is tagged STRONG — the old gap was taken out with conviction on real participation, not by low-volume drift.

https://www.tradingview.com/x/99OXYUBM/

6. Inversion zone life: each iFVG shows its 50% equilibrium line (the consequent encroachment level), an age counter in bars, fires an alert on the first retest from outside, and expires by the same mitigation rules as regular gaps (50% or full, wick or close) once price trades through it against its new role.

Everything is evaluated on closed bars only, so zones, colors and labels do not repaint.

🔶[b]HOW TO ACTUALLY USE IT (STEP BY STEP)[/b]

1. Out of the box you see only inversion zones — that is the point of the tool. If you also want the raw material (regular gaps that may flip later), enable "Show Regular FVGs" and they appear as quiet green/red context boxes.
2. When a colored inversion zone appears, read its meaning: orange resistance = former demand that got displaced through downward; cyan support = former supply that got displaced through upward.
3. Give more weight to zones tagged STRONG — the inverting gap was large and backed by elevated volume, which traders treat as a more meaningful role-flip than a quiet leak.
4. The first return of price into the zone is the moment most iFVG traders wait for (there is a dedicated retest alert). Watch how price reacts there — rejection confirms the new role, a pass-through negates it.
5. The gray line inside each zone is its 50% midpoint (EQ) — many traders use it as the precise reaction level rather than the zone edges.
6. The age counter (e.g. "34b") tells you how long a zone has existed since its inversion — fresh zones are generally considered more reliable than stale ones, and you can enable fading to de-emphasize old zones automatically.
7. Combine with your own analysis of trend and higher-timeframe levels. The indicator describes structure; it does not predict.

If you want the full life cycle of REGULAR fair value gaps (creation, strength grading and retest alerts while they still act in their original direction), that is what our free Smart FVG indicator does — this tool picks up where it ends, at the moment a gap fails and flips. Both use the same visual language, so they pair naturally.

🔶[b]EVERY SETTING EXPLAINED[/b]

🔵Visualization group
- Bullish FVG / Bearish FVG — colors of the quiet regular-gap context layer.
- iFVG Support / iFVG Resistance — colors of the inversion zones.
- Show Regular FVGs — off by default: only inversion zones are displayed. Turn on to also see the not-yet-inverted gaps as context (hidden gaps are still tracked, so inversions keep firing either way).
- Show 50% Line (EQ) / EQ Line Color — the midpoint line inside each zone.
- Width Mode — how zones extend to the right: Dynamic (to the current bar), Fixed (a set number of bars), or Extended (infinitely).
- Fixed Width (bars) — zone width when Fixed mode is selected.
- Min FVG Size (x ATR) — the smallest height that registers, applied twice: to every new gap AND to the common ground of the two gaps (an overlap thinner than this neither draws a zone nor consumes the level); 0 disables both checks.

BEFORE ATR
https://www.tradingview.com/x/KrC2GDib/

AFTER ATR
https://www.tradingview.com/x/ZvNBemEr/

🔵Mitigation group
- Delete Mitigated Zones — remove finished zones, or freeze them on the chart as reference.
- Mitigation Level — a zone is finished when price reaches its 50% midpoint, or only on a full fill.
- Mitigation Confirmation — what must reach that level: any wick, or a candle close.
- Inversion Memory (bars) — how long each detected gap's range stays eligible to form inversions, counted from the gap's creation and independent of when its box disappears from the chart. Larger = more inversions detected, including from older levels.
- Pairing Window After Break (bars) — once price CLOSES through the far side of a remembered gap, the opposing gap must confirm within this many bars for the inversion to count. If it does not, the level is treated as spent and dropped.

🔵Imbalance Age group
- Show Age Label — the bar counter inside each zone.
- Fade Old Zones / Max Age for Full Fade — gradually de-emphasize stale zones.

🔵Strong Inversion group
- Mark Strong Inversions — enables the two-condition strength check.
- Min Inverting Gap Size (x ATR) — condition 1: how large the inverting gap must be relative to volatility. Note this grades the STRONG tag only; it does not filter which zones appear (that is Min FVG Size).
- Min Volume (x SMA 20) — condition 2: how elevated the displacement candle volume must be versus its 20-bar average.
- Show 'STRONG' Tag — the text tag on qualifying zones.

🔵Labels group
- Show Labels / Label Text Color — master switch and color for all in-zone text.
- Label Offset (bars left of price) — keeps each zone's label trailing near the current bar so it stays readable, instead of sitting far back at the zone's left edge; 0 pins it on the current bar.

🔶[b]ALERTS[/b]

New iFVG Support / New iFVG Resistance / New STRONG iFVG / iFVG Retest / iFVG Mitigated — standard TradingView alert conditions. Select "Once Per Bar Close" when creating alerts for non-repainting behavior.

🔶[b]WHAT THIS TOOL DELIBERATELY DOES NOT DO[/b]

No buy or sell signals, no take-profit or stop-loss levels, no win-rate dashboard. Detecting a structural pattern is not the same as having a tradable edge, and presenting pattern marks as trade signals would overstate what any indicator of this kind can honestly claim. Use it as a lens for reading market structure, together with your own judgment.

## Source Code

````pine
//@version=6
indicator("Inversion FVG (iFVG) by EonMetrics", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  STYLE
// ═══════════════════════════════════════════════════════════════════════════════
group_viz = "Visualization"

bull_color = input.color(color.new(color.green, 88), "Bullish FVG",
  group=group_viz,
  tooltip="Background color for regular bullish (demand) Fair Value Gap zones - the quiet context layer.")

bear_color = input.color(color.new(color.red, 88), "Bearish FVG",
  group=group_viz,
  tooltip="Background color for regular bearish (supply) Fair Value Gap zones - the quiet context layer.")

ifvg_sup_color = input.color(color.new(#00e5ff, 70), "iFVG Support",
  group=group_viz,
  tooltip="Color for inversion zones acting as SUPPORT (a bearish gap was displaced upward through - broken supply turned demand).")

ifvg_res_color = input.color(color.new(#ff6d00, 70), "iFVG Resistance",
  group=group_viz,
  tooltip="Color for inversion zones acting as RESISTANCE (a bullish gap was displaced downward through - broken demand turned supply).")

show_fresh = input.bool(false, "Show Regular FVGs",
  group=group_viz,
  tooltip="OFF (default): only inversion zones are displayed - regular gaps are tracked invisibly in the background so inversions keep working. ON: also draws the not-yet-inverted gaps as quiet context. Applies to the chart timeframe only - the HTF layer never draws its context gaps.")

show_eq = input.bool(true, "Show 50% Line (EQ)",
  group=group_viz,
  tooltip="Draws a midpoint line at 50% of each zone (Equilibrium / consequent encroachment). Many traders use it as the precise reaction level inside the zone.")

eq_color = input.color(color.gray, "EQ Line Color",
  group=group_viz,
  tooltip="Color of the 50% equilibrium line drawn inside each zone.")

width_mode = input.string("Dynamic", "Width Mode", options=["Dynamic", "Fixed", "Extended"],
  group=group_viz,
  tooltip="How to extend zones to the right:\n'Dynamic' - extends to the current bar in real time\n'Fixed' - fixed number of bars from creation\n'Extended' - extends infinitely to the right.\nHTF zones always extend to the current bar (except 'Extended', which extends infinitely).")

fixed_width = input.int(20, "Fixed Width (bars)", minval=1,
  group=group_viz,
  tooltip="Number of bars for zone width. Only active when Width Mode is 'Fixed'.")

fvg_min_atr = input.float(0.1, "Min FVG Size (x ATR)", minval=0.0, maxval=2.0, step=0.05,
  group=group_viz,
  tooltip="Minimum height as a multiple of ATR(14), applied twice: gaps smaller than this are ignored entirely, AND an inversion only counts when the common ground of the two gaps is itself at least this tall - slivers of overlap neither draw a zone nor consume the level. Set to 0 to disable both checks. The HTF layer applies the same rule using the HTF's own ATR(14).")

// ═══════════════════════════════════════════════════════════════════════════════
//  MITIGATION
// ═══════════════════════════════════════════════════════════════════════════════
group_mit = "Mitigation"

delete_mit = input.bool(true, "Delete Mitigated Zones",
  group=group_mit,
  tooltip="When enabled, mitigated zones disappear. When disabled, they stop at the mitigation bar and remain as historical reference.")

mit_when = input.string("0.5 fill", "Mitigation Level", options=["0.5 fill", "Full fill"],
  group=group_mit,
  tooltip="When is a zone considered mitigated:\n'0.5 fill' - price reaches the 50% EQ midpoint\n'Full fill' - price completely closes the zone.\nApplies to regular FVGs and to inversion zones alike (HTF zones included - checked against chart price). Controls DISPLAY only - a gap's level stays pairable for inversions per Inversion Memory below.")

use_conf = input.string("Wicks", "Mitigation Confirmation", options=["Wicks", "Close"],
  group=group_mit,
  tooltip="What must reach the mitigation level:\n'Wicks' - any wick through the level\n'Close' - candle must close beyond the level.")

inv_memory = input.int(200, "Inversion Memory (bars)", minval=10, maxval=2000,
  group=group_mit,
  tooltip="How long each detected gap's price range stays eligible to form an inversion, counted from the gap's creation. The range keeps working invisibly even after the gap's box was mitigated and removed from the chart. Larger = more inversions detected, including from older levels. For the HTF layer this window counts HTF bars, keeping the logic consistent on its own timeframe.")

pair_win = input.int(8, "Pairing Window After Break (bars)", minval=1, maxval=50,
  group=group_mit,
  tooltip="Once price CLOSES through the far side of a remembered gap, the opposing gap must confirm within this many bars for an inversion to count. If it does not, the level is considered spent and is dropped - price chopping back and forth through a gap several times means the imbalance is gone, and pairing it much later would mark meaningless zones. For the HTF layer this window counts HTF bars.")

// ═══════════════════════════════════════════════════════════════════════════════
//  IMBALANCE AGE
// ═══════════════════════════════════════════════════════════════════════════════
group_age = "Imbalance Age"

show_age = input.bool(true, "Show Age Label",
  group=group_age,
  tooltip="Displays bar count since the zone was created (e.g. '34b'). Older untested zones are generally weaker - fresh zones are higher probability. For HTF zones the count is in CHART bars since the inversion appeared here.")

age_fade = input.bool(false, "Fade Old Zones",
  group=group_age,
  tooltip="Gradually increases zone transparency as bars pass. Helps visually prioritize fresh zones over stale ones. HTF zones are excluded - their age in chart bars would fade them unfairly fast.")

age_max = input.int(100, "Max Age for Full Fade (bars)", minval=10, maxval=500,
  group=group_age,
  tooltip="Number of bars after which the zone reaches maximum fade.")

// ═══════════════════════════════════════════════════════════════════════════════
//  STRONG INVERSION
// ═══════════════════════════════════════════════════════════════════════════════
group_strong = "Strong Inversion"

use_strong = input.bool(true, "Mark Strong Inversions",
  group=group_strong,
  tooltip="An inversion is STRONG when BOTH conditions are met by the NEW (inverting) gap: gap size >= ATR threshold AND displacement candle volume >= SMA(20) threshold. The gap was taken out with conviction, not by slow drift. The HTF layer grades with the HTF's own ATR and volume SMA.")

strong_atr_mult = input.float(1.0, "Min Inverting Gap Size (x ATR)", minval=0.1, maxval=5.0, step=0.1,
  group=group_strong,
  tooltip="Condition 1/2 - the height of the inverting gap must be at least this multiple of ATR(14) at formation time. Note: every inverting gap is a displacement gap by nature, so this threshold is deliberately higher than in a regular FVG tool.")

strong_vol_mult = input.float(2.0, "Min Volume (x SMA 20)", minval=1.0, maxval=5.0, step=0.1,
  group=group_strong,
  tooltip="Condition 2/2 - volume of the inverting gap's displacement candle (middle candle) must exceed SMA(20) of volume by this multiplier.")

show_strong_label = input.bool(true, "Show 'STRONG' Tag",
  group=group_strong,
  tooltip="Prefixes the zone label with STRONG for inversions that qualify.")

// ═══════════════════════════════════════════════════════════════════════════════
//  HIGHER TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════════
group_htf = "Higher Timeframe"

use_htf = input.bool(false, "Show HTF Inversions",
  group=group_htf,
  tooltip="Runs the full inversion engine a second time on a higher timeframe and overlays its iFVG zones on this chart. Each HTF event is processed exactly once, when the HTF bar confirms - no smearing, no repainting. HTF context gaps are never drawn; only the inversion zones.")

htf_tf = input.timeframe("60", "Higher Timeframe",
  group=group_htf,
  tooltip="Timeframe the second engine runs on. Must be higher than the chart timeframe for meaningful results.")

htf_sup_color = input.color(color.new(#00bcd4, 80), "HTF iFVG Support",
  group=group_htf,
  tooltip="Color for HTF inversion zones acting as support.")

htf_res_color = input.color(color.new(#ff5722, 80), "HTF iFVG Resistance",
  group=group_htf,
  tooltip="Color for HTF inversion zones acting as resistance.")

htf_show_label = input.bool(true, "Show 'HTF' Tag",
  group=group_htf,
  tooltip="Prefixes the zone label with HTF for zones imported from the higher timeframe.")

// ═══════════════════════════════════════════════════════════════════════════════
//  LABELS
// ═══════════════════════════════════════════════════════════════════════════════
group_lbl = "Labels"

show_labels = input.bool(true, "Show Labels",
  group=group_lbl,
  tooltip="Master switch for all text inside zones. When disabled, no text is shown regardless of other label settings.")

label_color = input.color(color.white, "Label Text Color",
  group=group_lbl,
  tooltip="Color of all text labels displayed inside zones. Default: white.")

label_offset = input.int(5, "Label Offset (bars left of price)", minval=0, maxval=50,
  group=group_lbl,
  tooltip="Places each zone's label this many bars to the left of the current bar, so it stays readable near price instead of sitting far back at the zone's left edge. 0 pins it exactly on the current bar.")

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPE
//  Mechanics note: an iFVG SUPPORT zone behaves exactly like a bullish FVG
//  (retested from above, mitigated downward), and an iFVG RESISTANCE zone like a
//  bearish FVG - so both kinds share one update path via `is_bull`.
// ═══════════════════════════════════════════════════════════════════════════════
type Zone
    box    b
    line   l_eq
    label  lbl
    float  top_val
    float  bot_val
    float  mid
    float  target_level
    bool   is_bull
    bool   is_ifvg
    bool   is_htf
    int    start_bar   // left edge of the drawing (for an iFVG: the ORIGINAL gap's origin)
    int    inv_bar     // logic anchor: creation/inversion bar (age, retest, mitigation guards)
    bool   is_strong
    color  zone_color
    bool   retested

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
// Visible zones only (context gaps + inversion zones, both layers).
var array<Zone> zones = array.new<Zone>()

// Invisible pairing levels — CHART layer: every detected gap's range, extended
// right in the background for `inv_memory` bars regardless of display mitigation.
// Parallel arrays: top / bottom / direction / creation bar / drawing origin bar.
var array<float> rng_top    = array.new<float>()
var array<float> rng_bot    = array.new<float>()
var array<bool>  rng_bull   = array.new<bool>()
var array<int>   rng_born   = array.new<int>()
var array<int>   rng_left   = array.new<int>()
// Full extents of the ORIGINAL parent gap (inherited unchanged by remnants).
// Consumption bookkeeping runs on the trimmed top/bot above, but a drawn iFVG is
// always the intersection of the two FULL gaps - not of bookkeeping leftovers.
var array<float> rng_otop   = array.new<float>()
var array<float> rng_obot   = array.new<float>()
// Bar of the first CLOSE through the range's far side (-1 = still intact). Starts
// the short pairing window; an expired window means the level is spent.
var array<int>   rng_breach = array.new<int>()

// Invisible pairing levels — HTF layer (same shape; clocks count HTF bars).
var array<float> hrng_top    = array.new<float>()
var array<float> hrng_bot    = array.new<float>()
var array<bool>  hrng_bull   = array.new<bool>()
var array<int>   hrng_born   = array.new<int>()
var array<int>   hrng_left   = array.new<int>()
var array<float> hrng_otop   = array.new<float>()
var array<float> hrng_obot   = array.new<float>()
var array<int>   hrng_breach = array.new<int>()

atr14     = ta.atr(14)
vol_sma20 = ta.sma(volume, 20)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
fade_color(c, age, max_age) =>
    base_t = color.t(c)
    extra  = math.min(age, max_age) / float(max_age) * (95.0 - base_t)
    color.new(c, math.min(95.0, base_t + extra))

build_label_text(bool is_ifvg, bool is_str, int age, bool is_htf) =>
    string core = is_ifvg ? (is_str and show_strong_label ? "STRONG iFVG" : "iFVG") : ""
    string prefix = is_htf and htf_show_label and core != "" ? "HTF " + core : core
    age_str = show_age ? str.tostring(age) + "b" : ""
    result  = prefix != "" and age_str != "" ? prefix + "  " + age_str :
              prefix != "" ? prefix : age_str
    result

create_zone(float top, float bot, bool is_bull, bool is_ifvg, bool is_strong, int left_bar, int anchor_bar, bool is_htf) =>
    mid     = (top + bot) / 2.0
    t_level = mit_when == "0.5 fill" ? mid : (is_bull ? bot : top)

    color base_c  = is_htf ? (is_bull ? htf_sup_color : htf_res_color) : is_ifvg ? (is_bull ? ifvg_sup_color : ifvg_res_color) : (is_bull ? bull_color : bear_color)
    // Strong inversions render slightly more opaque than the user-picked base.
    color z_color = is_ifvg and is_strong ? color.new(base_c, math.max(0, color.t(base_c) - 15)) : base_c

    // Fixed width counts from the left edge but must at least reach the creation bar
    // (an iFVG's left edge can sit far in the past, at the original gap's origin).
    int right_init = width_mode == "Fixed" ? math.max(left_bar + fixed_width, anchor_bar + 1) : left_bar + 1

    b = box.new(left_bar, top, right_init, bot,
      border_color = na,
      bgcolor      = z_color,
      xloc         = xloc.bar_index)

    l = show_eq ? line.new(left_bar, mid, right_init, mid,
      color = eq_color,
      style = line.style_solid,
      xloc  = xloc.bar_index) : na

    if width_mode == "Extended"
        box.set_extend(b, extend.right)
        if not na(l)
            line.set_extend(l, extend.right)

    lbl_text = show_labels ? build_label_text(is_ifvg, is_strong, 0, is_htf) : ""

    lbl = label.new(left_bar, mid, lbl_text,
      color     = color.new(color.white, 100),
      textcolor = label_color,
      style     = label.style_label_center,
      size      = size.small,
      xloc      = xloc.bar_index)

    Zone.new(b, l, lbl, top, bot, mid, t_level, is_bull, is_ifvg, is_htf, left_bar, anchor_bar, is_strong, z_color, false)

kill_zone(Zone z) =>
    box.delete(z.b)
    line.delete(z.l_eq)
    label.delete(z.lbl)

// Remove displayed context gaps of the consumed side that overlap a new iFVG slice
// (their invisible remnants, if any, keep working in the range memory).
// Chart layer only - HTF inversions must not erase chart-TF context gaps.
kill_overlapping_fresh(float s_top, float s_bot, bool old_bull) =>
    int n = zones.size()
    if n > 0
        for j = n - 1 to 0
            Zone z = zones.get(j)
            if not z.is_ifvg and not z.is_htf and z.is_bull == old_bull and z.bot_val < s_top and z.top_val > s_bot
                kill_zone(z)
                zones.remove(j)

// ═══════════════════════════════════════════════════════════════════════════════
//  RANGE-MEMORY ENGINE (shared by both layers)
//  All clocks run on the layer's own bar counter (`now`): chart layer passes
//  bar_index, HTF layer passes its confirmed-HTF-bar counter.
// ═══════════════════════════════════════════════════════════════════════════════

// Age/cap purge + breach bookkeeping for one layer's memory.
purge_and_breach(array<float> a_top, array<float> a_bot, array<bool> a_bull, array<int> a_born, array<int> a_left, array<int> a_breach, array<float> a_otop, array<float> a_obot, int now, float close_val) =>
    // Age/cap purge (oldest entries sit at the head).
    while a_born.size() > 0 and (now - a_born.get(0) > inv_memory or a_born.size() > 100)
        a_top.shift()
        a_bot.shift()
        a_bull.shift()
        a_born.shift()
        a_left.shift()
        a_breach.shift()
        a_otop.shift()
        a_obot.shift()
    // Breach bookkeeping: the first close through the far side of a range starts
    // its pairing window; once the window expires unpaired, the level is spent.
    int nR = a_born.size()
    if nR > 0
        for i = nR - 1 to 0
            int br = a_breach.get(i)
            if br < 0
                bool thru = a_bull.get(i) ? close_val < a_bot.get(i) : close_val > a_top.get(i)
                if thru
                    a_breach.set(i, now)
            else if now - br > pair_win
                a_top.remove(i)
                a_bot.remove(i)
                a_bull.remove(i)
                a_born.remove(i)
                a_left.remove(i)
                a_breach.remove(i)
                a_otop.remove(i)
                a_obot.remove(i)
    // Explicit trailing no-op so the loop's if/else stays in statement position -
    // otherwise this void helper would be typed by those (mismatched) branches.
    true

// New-gap handler for one layer: pairs the gap against that layer's memory,
// draws inversion slices, keeps remainders pairable, registers the leftover gap.
//   now        - layer bar counter (chart: bar_index; HTF: confirmed-bar counter)
//   left_bar   - CHART bar used as the drawing origin for this gap
//   anchor_bar - CHART bar used as the zone's logic anchor (age/retest/mitigation)
//   atr_val / vol_val / vsma_val - the layer's own ATR(14)[1], volume[1], SMA20[1]
handle_new_gap(array<float> a_top, array<float> a_bot, array<bool> a_bull, array<int> a_born, array<int> a_left, array<int> a_breach, array<float> a_otop, array<float> a_obot, float top, float bot, bool gap_is_bull, int now, int left_bar, int anchor_bar, float atr_val, float vol_val, float vsma_val, bool is_htf) =>
    // Strong grading comes from the NEW (inverting) gap: size + displacement volume.
    bool is_str = use_strong and (top - bot) >= nz(atr_val) * strong_atr_mult and nz(vsma_val) > 0 and vol_val >= nz(vsma_val) * strong_vol_mult
    bool inverted_any = false

    // Minimum height a leftover range piece must keep to stay in memory.
    float keep_min = nz(atr_val) * math.max(fvg_min_atr, 0.05)

    // The new gap as a shrinking interval (slices are subtracted as they pair).
    float gT = top
    float gB = bot
    bool  gAlive = true

    // Rebuild the range memory while pairing (safe removal/replacement).
    array<float> k_top    = array.new<float>()
    array<float> k_bot    = array.new<float>()
    array<bool>  k_bull   = array.new<bool>()
    array<int>   k_born   = array.new<int>()
    array<int>   k_left   = array.new<int>()
    array<int>   k_breach = array.new<int>()
    array<float> k_otop   = array.new<float>()
    array<float> k_obot   = array.new<float>()

    int n = a_born.size()
    if n > 0
        for i = 0 to n - 1
            float r_top    = a_top.get(i)
            float r_bot    = a_bot.get(i)
            bool  r_bull   = a_bull.get(i)
            int   r_born   = a_born.get(i)
            int   r_left   = a_left.get(i)
            int   r_breach = a_breach.get(i)
            float r_otop   = a_otop.get(i)
            float r_obot   = a_obot.get(i)

            float i_top = math.min(gT, r_top)
            float i_bot = math.max(gB, r_bot)
            // Drawn zone = intersection of the two FULL parent gaps.
            float z_top = math.min(top, r_otop)
            float z_bot = math.max(bot, r_obot)

            if not gAlive or r_bull == gap_is_bull or i_top <= i_bot or z_top - z_bot < nz(atr_val) * fvg_min_atr
                // Same direction, no overlap, meaningless sliver of common ground
                // (below Min FVG Size - the level stays intact), or the new gap is
                // spent: keep the entry as-is.
                k_top.push(r_top)
                k_bot.push(r_bot)
                k_bull.push(r_bull)
                k_born.push(r_born)
                k_left.push(r_left)
                k_breach.push(r_breach)
                k_otop.push(r_otop)
                k_obot.push(r_obot)
                continue

            // Overlap found. Consumption bookkeeping uses the remnant slice
            // (i_top/i_bot), but the DRAWN zone is the intersection of the two
            // FULL parent gaps, drawn from the original gap's origin.
            zones.push(create_zone(z_top, z_bot, gap_is_bull, true, is_str, r_left, anchor_bar, is_htf))
            if not is_htf
                kill_overlapping_fresh(z_top, z_bot, r_bull)
            inverted_any := true

            // Keep the unconsumed remainders of the old range pairable (they
            // inherit the breach clock, so they expire soon after the event).
            if r_top - i_top >= keep_min
                k_top.push(r_top)
                k_bot.push(i_top)
                k_bull.push(r_bull)
                k_born.push(r_born)
                k_left.push(r_left)
                k_breach.push(r_breach)
                k_otop.push(r_otop)
                k_obot.push(r_obot)
            if i_bot - r_bot >= keep_min
                k_top.push(i_bot)
                k_bot.push(r_bot)
                k_bull.push(r_bull)
                k_born.push(r_born)
                k_left.push(r_left)
                k_breach.push(r_breach)
                k_otop.push(r_otop)
                k_obot.push(r_obot)

            // Subtract the slice from the new gap.
            if i_top >= gT and i_bot <= gB
                gAlive := false
            else if i_top >= gT
                gT := i_bot
            else if i_bot <= gB
                gB := i_top
            else
                // Interior overlap (rare): keep the upper part of the new gap.
                gB := i_top
            if gAlive and gT - gB < keep_min
                gAlive := false

    // Swap the rebuilt memory back in (mutating contents is allowed on params).
    a_top.clear()
    array.concat(a_top, k_top)
    a_bot.clear()
    array.concat(a_bot, k_bot)
    a_bull.clear()
    array.concat(a_bull, k_bull)
    a_born.clear()
    array.concat(a_born, k_born)
    a_left.clear()
    array.concat(a_left, k_left)
    a_breach.clear()
    array.concat(a_breach, k_breach)
    a_otop.clear()
    array.concat(a_otop, k_otop)
    a_obot.clear()
    array.concat(a_obot, k_obot)

    // Whatever is left of the new gap becomes a remembered level itself
    // (its original extents = the full new gap).
    if gAlive and gT - gB >= keep_min
        a_top.push(gT)
        a_bot.push(gB)
        a_bull.push(gap_is_bull)
        a_born.push(now)
        a_left.push(left_bar)
        a_breach.push(-1)
        a_otop.push(top)
        a_obot.push(bot)

    // Only never-inverted CHART gaps get a visible context box (when enabled).
    if not inverted_any and show_fresh and not is_htf
        zones.push(create_zone(top, bot, gap_is_bull, false, false, left_bar, anchor_bar, false))

    [inverted_any, is_str]

// ═══════════════════════════════════════════════════════════════════════════════
//  DETECTION — CHART LAYER
//  Regular FVG = classic 3-candle imbalance. On every new gap, scan the remembered
//  opposite-direction ranges: each overlap creates an iFVG = the INTERSECTION slice.
// ═══════════════════════════════════════════════════════════════════════════════
is_bull_fvg = low[0] > high[2]
is_bear_fvg = high[0] < low[2]

// Alert event flags - reset every bar; consumed by alertcondition calls at the end.
bool new_ifvg_sup    = false
bool new_ifvg_res    = false
bool new_ifvg_strong = false
bool new_htf_sup     = false
bool new_htf_res     = false

// Range-memory bookkeeping (confirmed bars only).
if barstate.isconfirmed
    purge_and_breach(rng_top, rng_bot, rng_bull, rng_born, rng_left, rng_breach, rng_otop, rng_obot, bar_index, close)

if barstate.isconfirmed and is_bull_fvg and not na(atr14[1]) and (low[0] - high[2]) >= atr14[1] * fvg_min_atr
    [inv, istr] = handle_new_gap(rng_top, rng_bot, rng_bull, rng_born, rng_left, rng_breach, rng_otop, rng_obot, low[0], high[2], true, bar_index, bar_index - 1, bar_index - 1, atr14[1], volume[1], vol_sma20[1], false)
    if inv
        new_ifvg_sup    := true
        new_ifvg_strong := new_ifvg_strong or istr

if barstate.isconfirmed and is_bear_fvg and not na(atr14[1]) and (low[2] - high[0]) >= atr14[1] * fvg_min_atr
    [inv, istr] = handle_new_gap(rng_top, rng_bot, rng_bull, rng_born, rng_left, rng_breach, rng_otop, rng_obot, low[2], high[0], false, bar_index, bar_index - 1, bar_index - 1, atr14[1], volume[1], vol_sma20[1], false)
    if inv
        new_ifvg_res    := true
        new_ifvg_strong := new_ifvg_strong or istr

// ═══════════════════════════════════════════════════════════════════════════════
//  DETECTION — HTF LAYER
//  One request.security call brings the full HTF context. With lookahead_off the
//  values seen right after an HTF rollover are those of the JUST-CLOSED HTF bar,
//  and each HTF bar is processed exactly once → no smearing, no repaint (same
//  pattern as our Smart FVG HTF overlay).
// ═══════════════════════════════════════════════════════════════════════════════
// All values are requested with a one-bar offset and lookahead_on - the canonical
// non-repainting HTF fetch: every chart bar receives the data of the last CLOSED
// HTF bar, identically on historical and realtime bars, with no future leak.
// The triplet frame is therefore [1]/[3] (newest closed bar / two before it), and
// the displacement-candle context shifts accordingly: middle candle volume = [2],
// ATR at formation = [2].
[h_l0, h_h0, h_l2, h_h2, h_close, h_atr, h_vol, h_vsma] = request.security(
  syminfo.tickerid, htf_tf,
  [low[1], high[1], low[3], high[3], close[1], ta.atr(14)[2], volume[2], ta.sma(volume, 20)[2]],
  gaps      = barmerge.gaps_off,
  lookahead = barmerge.lookahead_on)

// ta.change() is hoisted out of the `and` so it evaluates on EVERY bar - hiding a
// stateful call behind a condition breaks its per-bar history.
htf_bar_changed = ta.change(time(htf_tf)) != 0
// The HTF layer only makes sense when its timeframe is actually higher than the
// chart's - on an equal/lower one it would just duplicate the chart layer.
htf_is_higher = timeframe.in_seconds(htf_tf) > timeframe.in_seconds()
htf_new_bar = use_htf and htf_is_higher and htf_bar_changed and barstate.isconfirmed

// Confirmed-HTF-bar counter: the HTF layer's clock for memory/pairing windows.
var int htf_count = 0

if htf_new_bar
    htf_count += 1
    purge_and_breach(hrng_top, hrng_bot, hrng_bull, hrng_born, hrng_left, hrng_breach, hrng_otop, hrng_obot, htf_count, h_close)

    if h_l0 > h_h2 and not na(h_atr) and (h_l0 - h_h2) >= h_atr * fvg_min_atr
        [inv, istrh] = handle_new_gap(hrng_top, hrng_bot, hrng_bull, hrng_born, hrng_left, hrng_breach, hrng_otop, hrng_obot, h_l0, h_h2, true, htf_count, bar_index, bar_index, h_atr, h_vol, h_vsma, true)
        if inv
            new_htf_sup := true

    if h_h0 < h_l2 and not na(h_atr) and (h_l2 - h_h0) >= h_atr * fvg_min_atr
        [inv, istrh] = handle_new_gap(hrng_top, hrng_bot, hrng_bull, hrng_born, hrng_left, hrng_breach, hrng_otop, hrng_obot, h_l2, h_h0, false, htf_count, bar_index, bar_index, h_atr, h_vol, h_vsma, true)
        if inv
            new_htf_res := true

// ═══════════════════════════════════════════════════════════════════════════════
//  UPDATE LOOP - extend zones, fade, update labels, retest, mitigation
//  (mitigation here affects the DISPLAYED zones only; the invisible range memory
//  above is independent and purged solely by Inversion Memory.)
// ═══════════════════════════════════════════════════════════════════════════════
bool ev_retest = false
bool ev_mit    = false

if barstate.isconfirmed and zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        age = bar_index - z.inv_bar

        // HTF zones always track the current bar (except Extended, which extends
        // infinitely from creation).
        if width_mode == "Dynamic" or (z.is_htf and width_mode != "Extended")
            box.set_right(z.b, bar_index)
            if not na(z.l_eq)
                line.set_x2(z.l_eq, bar_index)

        // Age fade - HTF zones are excluded: their age in chart bars is not
        // comparable with chart-TF zones.
        if age_fade and not z.is_htf
            box.set_bgcolor(z.b, fade_color(z.zone_color, age, age_max))

        label.set_text(z.lbl, show_labels ? build_label_text(z.is_ifvg, z.is_strong, age, z.is_htf) : "")
        label.set_textcolor(z.lbl, label_color)
        // Trail the label near price (offset left of the current bar) for readability.
        label.set_x(z.lbl, bar_index - label_offset)

        // Retest - fires once, when price first re-enters the zone's proximal edge.
        // CHART-layer zones only: HTF zones retest/mitigate on CLOSED HTF data in
        // the dedicated pass below, so they behave exactly like on their own chart.
        if not z.is_htf and not z.retested and bar_index > z.inv_bar + 1
            entered = z.is_bull ? low <= z.top_val : high >= z.bot_val
            if entered
                z.retested := true
                if z.is_ifvg
                    ev_retest := true

        // Mitigation check (display layer) - chart layer only, see HTF pass below.
        price_chk = use_conf == "Wicks" ? (z.is_bull ? low : high) : close
        is_mit    = not z.is_htf and (z.is_bull ? price_chk <= z.target_level : price_chk >= z.target_level)

        if is_mit and bar_index > z.inv_bar + 1
            if z.is_ifvg
                ev_mit := true
            if delete_mit
                kill_zone(z)
                zones.remove(i)
            else
                box.set_right(z.b, bar_index)
                box.set_extend(z.b, extend.none)
                if not na(z.l_eq)
                    line.set_x2(z.l_eq, bar_index)
                    line.set_extend(z.l_eq, extend.none)
                zones.remove(i)

// HTF retest/mitigation pass - evaluated once per CLOSED HTF bar, on that bar's
// own high/low/close. Mitigating 4H zones with every 15m wick would kill them far
// sooner than the same zones survive on the 4H chart itself - the layers must
// agree with what the user sees on the HTF chart. Zones created this very chart
// bar are skipped (their creation data would self-check).
if htf_new_bar and zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        if z.is_htf and z.inv_bar != bar_index
            if not z.retested
                bool h_entered = z.is_bull ? h_l0 <= z.top_val : h_h0 >= z.bot_val
                if h_entered
                    z.retested := true
            float h_chk = use_conf == "Wicks" ? (z.is_bull ? h_l0 : h_h0) : h_close
            bool  h_mit = z.is_bull ? h_chk <= z.target_level : h_chk >= z.target_level
            if h_mit
                if delete_mit
                    kill_zone(z)
                    zones.remove(i)
                else
                    box.set_right(z.b, bar_index)
                    box.set_extend(z.b, extend.none)
                    if not na(z.l_eq)
                        line.set_x2(z.l_eq, bar_index)
                        line.set_extend(z.l_eq, extend.none)
                    zones.remove(i)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
//  Set "Once Per Bar Close" when creating alerts for non-repainting behavior.
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(new_ifvg_sup, "New iFVG Support",
  "iFVG: bearish FVG inverted - new SUPPORT inversion zone on {{ticker}} ({{interval}}).")

alertcondition(new_ifvg_res, "New iFVG Resistance",
  "iFVG: bullish FVG inverted - new RESISTANCE inversion zone on {{ticker}} ({{interval}}).")

alertcondition(new_ifvg_strong, "New STRONG iFVG",
  "iFVG: STRONG inversion (large gap + high volume) on {{ticker}} ({{interval}}).")

alertcondition(ev_retest, "iFVG Retest",
  "iFVG: price returned to an inversion zone on {{ticker}} ({{interval}}).")

alertcondition(ev_mit, "iFVG Mitigated",
  "iFVG: an inversion zone was mitigated on {{ticker}} ({{interval}}).")

alertcondition(new_htf_sup, "New HTF iFVG Support",
  "iFVG: higher-timeframe SUPPORT inversion zone on {{ticker}} ({{interval}}).")

alertcondition(new_htf_res, "New HTF iFVG Resistance",
  "iFVG: higher-timeframe RESISTANCE inversion zone on {{ticker}} ({{interval}}).")
````
