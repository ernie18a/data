# Smart FVG by EonMetrics

- url: https://www.tradingview.com/script/U9sR4lhu-Smart-FVG-by-EonMetrics/
- type: indicator
- pine_id: PUB;8811c03f0f9140c38e8d2097f58aeebb
- version: 1.0

## Description

SMART FVG

[b]What it does[/b]

A "Fair Value Gap" (FVG) is a small gap left behind in price when a move happens so fast that a whole price area gets skipped over — nobody actually traded there. It shows up as a gap between three candles in a row. These gaps often get "filled" later, meaning price comes back to trade through that skipped area before continuing on its way (or reversing). This indicator finds these gaps automatically and draws a box around each one.

It also tells you which gaps look more important: a gap is marked "STRONG" only when BOTH of these are true at the same time — the gap is unusually large (measured against recent average volatility) AND the candle that created it traded on unusually high volume. Both conditions have to be true together; a big gap on quiet volume, or high volume with only a small gap, does not count as Strong. This two-part check is stricter than simply flagging "any big gap," which is what most similar tools do.

https://www.tradingview.com/x/pR9aDqXN/

[b]How to actually use it (step by step)[/b]

Let gaps form naturally as price moves. Each one is drawn as a colored box — green/cyan-ish tones for bullish (demand) gaps, red/orange tones for bearish (supply) gaps.
Pay extra attention to boxes marked "STRONG" — these represent a real, forceful, high-conviction move, not just random noise.
When price comes back down (or up) into a gap box, that's a potential trade opportunity — buy near a bullish gap, sell near a bearish gap — especially reacting at the dotted 50% line drawn through the middle of the box.
Look at the small number in the corner of each box — it counts how many candles ago the gap formed. A small number (fresh gap) is generally considered more reliable than a large number (old, already-tested-many-times gap).
If you turn on the higher-timeframe overlay, you'll also see gaps from a bigger timeframe (marked "HTF") plotted directly on your current chart — these represent bigger, more significant levels than same-timeframe gaps.
Every setting explained

https://www.tradingview.com/x/iJ9iiyIb/

[b]Visualization group[/b]

Bullish FVG / Bearish FVG — the fill color for ordinary gaps.
Strong Bullish FVG / Strong Bearish FVG — the fill color for gaps that pass the "Strong" test above.
Show 50% Line (EQ) — draws a line through the exact middle of every gap box; this is a common spot for price to react to.
EQ Line Color.
Width Mode — controls how far the box stretches to the right: "Dynamic" keeps growing the box to reach today's candle in real time, "Fixed" stops the box at a set number of candles wide, "Extended" stretches the box all the way to the right edge of your screen forever.
Fixed Width (bars) — how many candles wide the box is, only used when Width Mode is set to Fixed.
Min FVG Size (x ATR) — the smallest gap size the script will bother drawing, measured against recent average volatility. Raise this to ignore tiny, insignificant gaps; set to 0 to see every gap no matter how small.
Mitigation group (mitigation = "price has now traded back through the gap")

Delete Mitigated Zones — when turned on, a gap box disappears completely once price fills it. When off, it stops growing and stays on the chart as a faded historical marker.
Mitigation Level — decide what counts as "filled": either price reaching the halfway (50%) point of the gap, or price completely closing the entire gap.
Mitigation Confirmation — decide what counts as reaching that level: any wick poking into it ("Wicks"), or a full candle close past it ("Close" — stricter, fewer false triggers).
Imbalance Age group

Show Age Label — displays a small number (like "34b") showing how many candles ago the gap was created.
Fade Old Zones — when turned on, gap boxes slowly become more transparent as they age, so your eye is naturally drawn to the freshest ones.
Max Age for Full Fade (bars) — how many candles it takes for a gap to reach maximum fade/transparency.
Strong Imbalance group

Mark Strong Imbalances — master on/off switch for the whole Strong-gap detection described above.
Min Gap Size (x ATR) — how big the gap must be (relative to recent volatility) to count toward "Strong" — this is one of the two required conditions.
Min Volume (x SMA 20) — how much higher than the recent 20-candle average volume the gap-forming candle's volume must be — this is the second required condition. Both this and the size condition must be true at the same time.
Show 'STRONG' Tag — shows the word "STRONG" written inside qualifying gap boxes.
Labels group

Show Labels — master switch for all text written inside gap boxes (age number, STRONG tag, HTF tag). Turn this off to hide all text and keep only the colored boxes.
Label Text Color.
MTF FVG group (MTF = "multiple timeframes")

Show Higher Timeframe FVGs — turns on the overlay of gaps from a bigger timeframe, drawn directly on your current chart.
Higher Timeframe — which bigger timeframe to pull gaps from (should be higher than whatever timeframe you're currently viewing).
HTF Bullish FVG / HTF Bearish FVG — colors for these imported higher-timeframe gaps.
Show HTF Label — shows an "HTF" tag inside these imported gaps so you can tell them apart from same-timeframe ones.

## Source Code

````pine
//@version=6
indicator("Smart FVG by EonMetrics", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  STYLE
// ═══════════════════════════════════════════════════════════════════════════════
group_viz = "Visualization"

bull_color = input.color(color.new(color.green, 85), "Bullish FVG",
  group=group_viz,
  tooltip="Background color for bullish (demand) Fair Value Gap zones.")

bear_color = input.color(color.new(color.red, 85), "Bearish FVG",
  group=group_viz,
  tooltip="Background color for bearish (supply) Fair Value Gap zones.")

strong_bull_color = input.color(color.new(#00e5ff, 70), "Strong Bullish FVG",
  group=group_viz,
  tooltip="Color for bullish FVGs classified as Strong Imbalance (size > ATR threshold). High-priority institutional demand zones.")

strong_bear_color = input.color(color.new(#ff6d00, 70), "Strong Bearish FVG",
  group=group_viz,
  tooltip="Color for bearish FVGs classified as Strong Imbalance (size > ATR threshold). High-priority institutional supply zones.")

show_eq = input.bool(true, "Show 50% Line (EQ)",
  group=group_viz,
  tooltip="Draws a midpoint line at 50% of each FVG zone (Equilibrium). Price returning to EQ before filling indicates balanced institutional interest.")

eq_color = input.color(color.gray, "EQ Line Color",
  group=group_viz,
  tooltip="Color of the 50% equilibrium line drawn inside each FVG zone.")

width_mode = input.string("Dynamic", "Width Mode", options=["Dynamic", "Fixed", "Extended"],
  group=group_viz,
  tooltip="How to extend FVG zones to the right:\n'Dynamic' – extends to the current bar in real time\n'Fixed' – fixed number of bars from creation\n'Extended' – extends infinitely to the right.")

fixed_width = input.int(20, "Fixed Width (bars)", minval=1,
  group=group_viz,
  tooltip="Number of bars for zone width. Only active when Width Mode is 'Fixed'.")

fvg_min_atr = input.float(0.1, "Min FVG Size (× ATR)", minval=0.0, maxval=2.0, step=0.05,
  group=group_viz,
  tooltip="Minimum gap height as a multiple of ATR(14). FVGs smaller than this threshold are ignored entirely. Set to 0 to disable the filter.\nExample: 0.1 = gap must be at least 10% of ATR(14) at the time of formation.")

// ═══════════════════════════════════════════════════════════════════════════════
//  MITIGATION
// ═══════════════════════════════════════════════════════════════════════════════
group_mit = "Mitigation"

delete_mit = input.bool(true, "Delete Mitigated Zones",
  group=group_mit,
  tooltip="When enabled, mitigated zones disappear. When disabled, they stop at the mitigation bar and remain as historical reference.")

mit_when = input.string("0.5 fill", "Mitigation Level", options=["0.5 fill", "Full fill"],
  group=group_mit,
  tooltip="When is a zone considered mitigated:\n'0.5 fill' – price reaches the 50% EQ midpoint\n'Full fill' – price completely closes the gap.")

use_conf = input.string("Wicks", "Mitigation Confirmation", options=["Wicks", "Close"],
  group=group_mit,
  tooltip="What must reach the mitigation level:\n'Wicks' – any wick through the level\n'Close' – candle must close beyond the level.")

// ═══════════════════════════════════════════════════════════════════════════════
//  IMBALANCE AGE
// ═══════════════════════════════════════════════════════════════════════════════
group_age = "Imbalance Age"

show_age = input.bool(true, "Show Age Label",
  group=group_age,
  tooltip="Displays bar count since the FVG was created (e.g. '34b'). Older unmitigated zones are generally weaker — fresh zones are higher probability.")

age_fade = input.bool(false, "Fade Old Zones",
  group=group_age,
  tooltip="Gradually increases zone transparency as bars pass. Helps visually prioritize fresh imbalances over stale ones.")

age_max = input.int(100, "Max Age for Full Fade (bars)", minval=10, maxval=500,
  group=group_age,
  tooltip="Number of bars after which the zone reaches maximum fade. Zones older than this value are drawn at maximum transparency.")

// ═══════════════════════════════════════════════════════════════════════════════
//  STRONG IMBALANCE
// ═══════════════════════════════════════════════════════════════════════════════
group_strong = "Strong Imbalance"

use_strong = input.bool(true, "Mark Strong Imbalances",
  group=group_strong,
  tooltip="A zone is STRONG when BOTH conditions are met: gap size >= ATR threshold AND displacement candle volume >= SMA(20) threshold. Both filters must pass simultaneously.")

strong_atr_mult = input.float(0.5, "Min Gap Size (× ATR)", minval=0.1, maxval=5.0, step=0.1,
  group=group_strong,
  tooltip="Condition 1/2 — Minimum FVG height as a multiple of ATR(14) measured at the moment the FVG formed. Example: 0.5 = gap must be at least half the ATR at creation time.")

strong_vol_mult = input.float(1.5, "Min Volume (× SMA 20)", minval=1.0, maxval=5.0, step=0.1,
  group=group_strong,
  tooltip="Condition 2/2 — Volume of the displacement candle (middle candle) must exceed SMA(20) of volume by this multiplier. Example: 1.5 = displacement volume must be 50% above the 20-bar average.")

show_strong_label = input.bool(true, "Show 'STRONG' Tag",
  group=group_strong,
  tooltip="Displays a 'STRONG' text tag centered inside zones that qualify as Strong Imbalance.")

// ═══════════════════════════════════════════════════════════════════════════════
//  LABELS
// ═══════════════════════════════════════════════════════════════════════════════
group_lbl = "Labels"

show_labels = input.bool(true, "Show Labels",
  group=group_lbl,
  tooltip="Master switch for all text inside FVG zones. When disabled, no text is shown regardless of other label settings (age, STRONG, HTF).")

label_color = input.color(color.white, "Label Text Color",
  group=group_lbl,
  tooltip="Color of all text labels displayed inside FVG zones (age counter, STRONG tag, HTF tag). Default: white.")

// ═══════════════════════════════════════════════════════════════════════════════
//  MTF FVG
// ═══════════════════════════════════════════════════════════════════════════════
group_mtf = "MTF FVG"

use_mtf = input.bool(false, "Show Higher Timeframe FVGs",
  group=group_mtf,
  tooltip="Overlays FVG zones from a higher timeframe. Each HTF zone is drawn only once, when the HTF bar confirms — no smearing or duplicates.")

mtf_tf = input.timeframe("60", "Higher Timeframe",
  group=group_mtf,
  tooltip="Timeframe from which FVGs are imported. Must be higher than the current chart timeframe for meaningful results.")

mtf_bull_color = input.color(color.new(#00bcd4, 75), "HTF Bullish FVG",
  group=group_mtf,
  tooltip="Fill color for bullish FVG zones imported from the higher timeframe.")

mtf_bear_color = input.color(color.new(#ff5722, 75), "HTF Bearish FVG",
  group=group_mtf,
  tooltip="Fill color for bearish FVG zones imported from the higher timeframe.")

mtf_show_label = input.bool(true, "Show HTF Label",
  group=group_mtf,
  tooltip="Shows a 'HTF' tag centered inside each higher-timeframe FVG zone.")

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPE
// ═══════════════════════════════════════════════════════════════════════════════
type FVG
    box    b
    line   l_eq
    label  lbl
    float  top_val
    float  bot_val
    float  mid
    float  target_level
    bool   is_bull
    int    start_bar
    bool   is_strong
    bool   is_htf
    color  zone_color
    bool   retested

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
var array<FVG> active_fvgs     = array.new<FVG>()
var array<FVG> active_mtf_fvgs = array.new<FVG>()

atr14    = ta.atr(14)
vol_sma20 = ta.sma(volume, 20)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
fade_color(c, age, max_age) =>
    base_t = color.t(c)
    extra  = math.min(age, max_age) / float(max_age) * (95.0 - base_t)
    color.new(c, math.min(95.0, base_t + extra))

build_label_text(bool is_str, int age, bool is_htf) =>
    prefix  = is_htf ? (mtf_show_label ? "HTF" : "") : (is_str and show_strong_label ? "STRONG" : "")
    age_str = show_age ? str.tostring(age) + "b" : ""
    result  = prefix != "" and age_str != "" ? prefix + "  " + age_str :
              prefix != "" ? prefix : age_str
    result

// ═══════════════════════════════════════════════════════════════════════════════
//  CREATE FVG
//  left_bar = bar_index[1] at detection time = displacement candle (middle of 3)
//  Label is placed at left_bar (center between candle 1 and 3), at mid price
// ═══════════════════════════════════════════════════════════════════════════════
create_fvg(float top, float bot, bool is_bull, color base_c, color strong_c, int left_bar, bool is_htf, float atr_snap, float vol_disp, float vol_avg) =>
    mid     = (top + bot) / 2.0
    t_level = mit_when == "0.5 fill" ? mid : (is_bull ? bot : top)
    fvg_sz  = top - bot
    cond_atr = fvg_sz >= atr_snap * strong_atr_mult
    cond_vol = vol_avg > 0 and vol_disp >= vol_avg * strong_vol_mult
    is_str   = use_strong and not is_htf and cond_atr and cond_vol
    z_color = is_str ? strong_c : base_c

    int right_init = width_mode == "Fixed" ? left_bar + fixed_width : left_bar + 1

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

    lbl_text  = show_labels ? build_label_text(is_str, 0, is_htf) : ""

    lbl = label.new(left_bar, mid, lbl_text,
      color     = color.new(color.white, 100),
      textcolor = label_color,
      style     = label.style_label_center,
      size      = size.small,
      xloc      = xloc.bar_index)

    FVG.new(b, l, lbl, top, bot, mid, t_level, is_bull, left_bar, is_str, is_htf, z_color, false)

// ═══════════════════════════════════════════════════════════════════════════════
//  CURRENT TF DETECTION
//  3-candle FVG pattern:
//    candle[2] = gap origin  | candle[1] = displacement | candle[0] = gap close
//  Box left edge = bar_index[1] = displacement candle = center of the 3 candles
// ═══════════════════════════════════════════════════════════════════════════════
is_bull_fvg = low[0] > high[2]
is_bear_fvg = high[0] < low[2]

// Alert event flags — reset every bar; consumed by alertcondition calls at end of script.
bool new_fvg_bull = false
bool new_fvg_bear = false
bool new_strong   = false

// barstate.isconfirmed → only register an FVG once the gap-close candle closes (non-repainting).
if barstate.isconfirmed and is_bull_fvg
    if (low[0] - high[2]) >= nz(atr14[1]) * fvg_min_atr
        f = create_fvg(low[0], high[2], true, bull_color, strong_bull_color, bar_index[1], false, nz(atr14[1]), volume[1], nz(vol_sma20[1]))
        array.push(active_fvgs, f)
        new_fvg_bull := true
        new_strong   := new_strong or f.is_strong

if barstate.isconfirmed and is_bear_fvg
    if (low[2] - high[0]) >= nz(atr14[1]) * fvg_min_atr
        f = create_fvg(low[2], high[0], false, bear_color, strong_bear_color, bar_index[1], false, nz(atr14[1]), volume[1], nz(vol_sma20[1]))
        array.push(active_fvgs, f)
        new_fvg_bear := true
        new_strong   := new_strong or f.is_strong

// ═══════════════════════════════════════════════════════════════════════════════
//  MTF DETECTION
//  htf_new_bar fires only once per confirmed HTF bar → prevents smearing
// ═══════════════════════════════════════════════════════════════════════════════
[mtf_low0, mtf_high0, mtf_low2, mtf_high2] = request.security(
  syminfo.tickerid, mtf_tf,
  [low[0], high[0], low[2], high[2]],
  gaps      = barmerge.gaps_off,
  lookahead = barmerge.lookahead_off)

// ta.change() is hoisted out of the `and` so it evaluates on EVERY bar. In Pine v6
// `and` short-circuits, so `use_mtf and ta.change(...)` would skip the stateful
// ta.change() call whenever use_mtf is off — breaking its per-bar history.
htf_bar_changed = ta.change(time(mtf_tf)) != 0
htf_new_bar = use_mtf and htf_bar_changed

if htf_new_bar
    if mtf_low0 > mtf_high2
        array.push(active_mtf_fvgs,
          create_fvg(mtf_low0, mtf_high2, true, mtf_bull_color, mtf_bull_color, bar_index, true, 0.0, 0.0, 0.0))

    if mtf_high0 < mtf_low2
        array.push(active_mtf_fvgs,
          create_fvg(mtf_low2, mtf_high0, false, mtf_bear_color, mtf_bear_color, bar_index, true, 0.0, 0.0, 0.0))

// ═══════════════════════════════════════════════════════════════════════════════
//  UPDATE LOOP — extend zones, fade, update labels, check mitigation
// ═══════════════════════════════════════════════════════════════════════════════
update_fvgs(arr, is_htf) =>
    bool ev_retest_bull = false
    bool ev_retest_bear = false
    bool ev_mit         = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            fvg = array.get(arr, i)
            age = bar_index - fvg.start_bar

            // Extend right edge (Dynamic and HTF always extend)
            if width_mode == "Dynamic" or (is_htf and width_mode != "Extended")
                box.set_right(fvg.b, bar_index)
                if not na(fvg.l_eq)
                    line.set_x2(fvg.l_eq, bar_index)

            // Age fade — HTF zones are excluded: their bar count in current TF is meaningless
            current_color = fvg.is_htf ? (fvg.is_bull ? mtf_bull_color : mtf_bear_color) : fvg.zone_color
            apply_fade    = age_fade and not fvg.is_htf
            box.set_bgcolor(fvg.b, apply_fade ? fade_color(current_color, age, age_max) : current_color)

            // Update label text and color
            label.set_text(fvg.lbl, show_labels ? build_label_text(fvg.is_strong, age, fvg.is_htf) : "")
            label.set_textcolor(fvg.lbl, label_color)

            // Retest detection — fires once, when price first re-enters the zone's proximal edge
            if not fvg.retested and bar_index > fvg.start_bar + 1
                entered = fvg.is_bull ? low <= fvg.top_val : high >= fvg.bot_val
                if entered
                    fvg.retested := true
                    if fvg.is_bull
                        ev_retest_bull := true
                    else
                        ev_retest_bear := true

            // Mitigation check
            price_chk = use_conf == "Wicks" ? (fvg.is_bull ? low : high) : close
            is_mit    = fvg.is_bull ? price_chk <= fvg.target_level : price_chk >= fvg.target_level

            if is_mit and bar_index > fvg.start_bar + 1
                ev_mit := true
                if delete_mit
                    box.delete(fvg.b)
                    line.delete(fvg.l_eq)
                    label.delete(fvg.lbl)
                    array.remove(arr, i)
                else
                    box.set_right(fvg.b, bar_index)
                    box.set_extend(fvg.b, extend.none)
                    if not na(fvg.l_eq)
                        line.set_x2(fvg.l_eq, bar_index)
                        line.set_extend(fvg.l_eq, extend.none)
                    array.remove(arr, i)
    [ev_retest_bull, ev_retest_bear, ev_mit]

[rt_bull, rt_bear, mit_ev] = update_fvgs(active_fvgs, false)

// HTF zones are maintained (extend/mitigate) but do not drive alerts — the return
// tuple must still be destructured, so its events are captured and intentionally unused.
// (Pine's ?: operator can't branch on tuples, so this uses if/else instead of a ternary.)
var bool htf_rt_bull = false
var bool htf_rt_bear = false
var bool htf_mit     = false
if use_mtf
    [a, b, c] = update_fvgs(active_mtf_fvgs, true)
    htf_rt_bull := a
    htf_rt_bear := b
    htf_mit     := c

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
//  Set "Once Per Bar Close" when creating alerts for non-repainting behavior.
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(new_fvg_bull, "New Bullish FVG",
  "Smart FVG: new bullish (demand) Fair Value Gap formed on {{ticker}} ({{interval}}).")

alertcondition(new_fvg_bear, "New Bearish FVG",
  "Smart FVG: new bearish (supply) Fair Value Gap formed on {{ticker}} ({{interval}}).")

alertcondition(new_strong, "New Strong Imbalance",
  "Smart FVG: new STRONG imbalance (large gap + high volume) formed on {{ticker}} ({{interval}}).")

alertcondition(rt_bull, "Bullish FVG Retest",
  "Smart FVG: price returned to a bullish (demand) FVG on {{ticker}} ({{interval}}).")

alertcondition(rt_bear, "Bearish FVG Retest",
  "Smart FVG: price returned to a bearish (supply) FVG on {{ticker}} ({{interval}}).")

alertcondition(mit_ev, "FVG Mitigated",
  "Smart FVG: an FVG was mitigated on {{ticker}} ({{interval}}).")
````
