# CTZ BTC Market Cycles 

- url: https://www.tradingview.com/script/2492MuYg-CTZ-BTC-Market-Cycles/
- type: indicator
- pine_id: PUB;f0eec802b1a5441493d2fc70929e2636
- version: 1.0

## Description

**CTZ BTC Market Cycles**

This indicator maps Bitcoin's major market cycle turning points using real historical dates — not fixed bar counts — so it works accurately on any timeframe (daily, weekly, monthly).

**What it draws:**

🔵 **Bottom → Bottom** (Cyan) — The full bear-to-bear cycle floor. Historical durations: 1,153d → 1,421d → 1,432d
🟠 **Top → Top** (Orange) — The full bull-to-bull cycle ceiling. Historical durations: 1,478d → 1,424d → 1,426d
🟢 **Bottom → Top** (Green) — The bull run phase from each cycle low to the next peak
🩷 **Top → Bottom** (Pink) — The bear market phase from each cycle peak to the next low

**Known pivots:**
- Bottoms: Nov 2011 → Jan 2015 → Dec 2018 → Nov 2022
- Tops: Nov 2013 → Dec 2017 → Nov 2021 → Oct 2025

**Projected (based on historical averages):**
- Next bottom: ~Oct 2026 (~$34k, based on diminishing drawdown pattern: 84% → 77% → ~69%)
- Next top: ~Sep 2029 (+1,430d from Oct 2025 top)

**Bear zone shading** highlights the current drawdown window from the Oct 2025 top to the projected Oct 2026 bottom.

**Status bar** on the current bar shows days since last bottom, days since last top, and days to projected next bottom.

All pivots, colours, arc height and projections are fully customisable in settings.

*Published by CTZ — 25 years trading experience. Part of the CTZ indicator suite.*

## Source Code

````pine
//@version=6
indicator("CTZ BTC Market Cycles", overlay = true, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 100)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
bool SHOW_B2B   = input.bool(true, "Bottom → Bottom", group = "Show / Hide")
bool SHOW_T2T   = input.bool(true, "Top → Top",       group = "Show / Hide")
bool SHOW_B2T   = input.bool(true, "Bottom → Top",    group = "Show / Hide")
bool SHOW_T2B   = input.bool(true, "Top → Bottom",    group = "Show / Hide")
bool SHOW_LBL   = input.bool(true, "Labels",          group = "Show / Hide")
bool SHOW_VLINE = input.bool(true, "Vertical lines",  group = "Show / Hide")
bool SHOW_NEXT  = input.bool(true, "Project next",    group = "Show / Hide")
bool SHOW_SHADE = input.bool(true, "Shade bear zone", group = "Show / Hide")
int  ARC_H      = input.int(40,   "Arc height %",     minval = 5,  maxval = 200, group = "Style")
int  LW         = input.int(2,    "Line width",       minval = 1,  maxval = 4,   group = "Style")
int  STEPS      = input.int(50,   "Arc smoothness",   minval = 10, maxval = 100, group = "Style")

color COL_B2B   = input.color(color.new(#00E5FF, 0), "Bottom → Bottom", group = "Colours")
color COL_T2T   = input.color(color.new(#FF6B35, 0), "Top → Top",       group = "Colours")
color COL_B2T   = input.color(color.new(#00E676, 0), "Bottom → Top",    group = "Colours")
color COL_T2B   = input.color(color.new(#FF4081, 0), "Top → Bottom",    group = "Colours")
color COL_SHADE = input.color(color.new(#FF4081, 88), "Bear zone fill", group = "Colours")

// ─── PIVOT TIMESTAMPS ────────────────────────────────────────────────────────
int B0 = timestamp(2011, 11, 18, 0, 0)
int B1 = timestamp(2015,  1, 14, 0, 0)
int B2 = timestamp(2018, 12, 15, 0, 0)
int B3 = timestamp(2022, 11, 21, 0, 0)
int B4 = timestamp(2026, 10,  5, 0, 0)  // projected ~364d from T3

int T0 = timestamp(2013, 11, 30, 0, 0)
int T1 = timestamp(2017, 12, 17, 0, 0)
int T2 = timestamp(2021, 11, 10, 0, 0)
int T3 = timestamp(2025, 10,  6, 0, 0)
int T4 = timestamp(2029,  9,  5, 0, 0)  // T3 + 1430d = Sep 5 2029

// ─── PIVOT PRICES ────────────────────────────────────────────────────────────
float PB0 = 2.0,      PT0 = 1163.0
float PB1 = 152.0,    PT1 = 19666.0
float PB2 = 3122.0,   PT2 = 67617.0
float PB3 = 15476.0,  PT3 = 109000.0
float PB4 = 34000.0,  PT4 = 185000.0   // conservative projected

// ─── ARC BUILDER ─────────────────────────────────────────────────────────────
// Peak lift is capped as a % of the LOWER of the two endpoint prices
// so arcs don't blow out on asymmetric moves
drawArc(int ts1, int ts2, float p1, float p2, float lift_pct, bool arc_up, color col, bool projected) =>
    float lift = math.min(p1, p2) * lift_pct / 100.0
    array<chart.point> pts = array.new<chart.point>(STEPS + 1)
    for i = 0 to STEPS
        float t    = i / STEPS
        int   ts   = int(ts1 + t * (ts2 - ts1))
        float base = p1 + t * (p2 - p1)
        float bump = lift * 4.0 * t * (1.0 - t)
        float y    = arc_up ? base + bump : base - bump
        array.set(pts, i, chart.point.from_time(ts, math.max(y, 1.0)))
    polyline.new(pts,
         line_color = color.new(col, projected ? 65 : 0),
         line_width = projected ? 1 : LW,
         curved     = true,
         xloc       = xloc.bar_time)

// ─── SHADED BEAR ZONE (now → projected bottom) ───────────────────────────────
// Drawn as a box from T3 to B4 using linefill between two lines
var line shade_top  = na
var line shade_bot  = na
var linefill shade_fill = na

if SHOW_SHADE and SHOW_NEXT and barstate.islast
    // Top boundary: horizontal at PT3 (cycle top)
    shade_top := line.new(T3, PT3, B4, PT3, xloc = xloc.bar_time,
         color = color.new(COL_T2B, 80), width = 1, style = line.style_dotted)
    // Bottom boundary: horizontal at PB4 (projected bottom ~$34k)
    shade_bot := line.new(T3, PB4, B4, PB4, xloc = xloc.bar_time,
         color = color.new(COL_T2B, 80), width = 1, style = line.style_dotted)
    shade_fill := linefill.new(shade_top, shade_bot, COL_SHADE)

// ─── LABEL + VLINE — strict once-only ────────────────────────────────────────
var bool lB0 = false
var bool lB1 = false
var bool lB2 = false
var bool lB3 = false
var bool lB4 = false
var bool lT0 = false
var bool lT1 = false
var bool lT2 = false
var bool lT3 = false
var bool lT4 = false

stamp(int ts, string txt, color col, bool above, bool isDone) =>
    bool fired = false
    if not isDone
        int tf_ms = int(timeframe.in_seconds() * 1000)
        bool isClosest = math.abs(time - ts) <= math.abs(time + tf_ms - ts)
        if math.abs(time - ts) < int(86400000) * 40 and isClosest
            if SHOW_VLINE
                line.new(bar_index, high * 1.1, bar_index, low * 0.9,
                     xloc = xloc.bar_index, color = color.new(col, 20),
                     width = 1, style = line.style_dashed)
            if SHOW_LBL
                label.new(bar_index, above ? high : low, text = txt,
                     xloc = xloc.bar_index, yloc = yloc.price,
                     color = color.new(col, 5), textcolor = color.white,
                     size = size.small,
                     style = above ? label.style_label_down : label.style_label_up)
            fired := true
    fired

if stamp(B0, "▼ Bottom\nNov 2011", COL_B2B, false, lB0)
    lB0 := true
if stamp(B1, "▼ Bottom\nJan 2015\n+1153d", COL_B2B, false, lB1)
    lB1 := true
if stamp(B2, "▼ Bottom\nDec 2018\n+1421d", COL_B2B, false, lB2)
    lB2 := true
if stamp(B3, "▼ Bottom\nNov 2022\n+1432d", COL_B2B, false, lB3)
    lB3 := true
if SHOW_NEXT
    if stamp(B4, "▼ Proj. Bottom\n~Oct 2026\n~$34k", color.new(COL_B2B, 40), false, lB4)
        lB4 := true

if stamp(T0, "▲ Top\nNov 2013", COL_T2T, true, lT0)
    lT0 := true
if stamp(T1, "▲ Top\nDec 2017\n+1484d", COL_T2T, true, lT1)
    lT1 := true
if stamp(T2, "▲ Top\nNov 2021\n+1422d", COL_T2T, true, lT2)
    lT2 := true
if stamp(T3, "▲ Top\nOct 2025\n+1430d", COL_T2T, true, lT3)
    lT3 := true
if SHOW_NEXT
    if stamp(T4, "▲ Proj. Top\n~Sep 2029\n+1430d", color.new(COL_T2T, 40), true, lT4)
        lT4 := true

// ─── ARCS ────────────────────────────────────────────────────────────────────
if barstate.islast
    float h = float(ARC_H)

    // Bottom → Bottom (cyan, arc up between bottoms)
    if SHOW_B2B
        drawArc(B0, B1, PB0, PB1, h, true, COL_B2B, false)
        drawArc(B1, B2, PB1, PB2, h, true, COL_B2B, false)
        drawArc(B2, B3, PB2, PB3, h, true, COL_B2B, false)
        if SHOW_NEXT
            // B→B: $15,476 → $45,000, small lift so it doesn't overshoot
            drawArc(B3, B4, PB3, PB4, h, true, COL_B2B, true)

    // Top → Top (orange, arc down between tops)
    if SHOW_T2T
        drawArc(T0, T1, PT0, PT1, h, false, COL_T2T, false)
        drawArc(T1, T2, PT1, PT2, h, false, COL_T2T, false)
        drawArc(T2, T3, PT2, PT3, h, false, COL_T2T, false)
        if SHOW_NEXT
            // T→T: $109k → $185k, gentle lift capped at 15% of lower price
            drawArc(T3, T4, PT3, PT4, h, false, COL_T2T, true)

    // Bottom → Top (green, bull run arcs)
    if SHOW_B2T
        drawArc(B0, T0, PB0, PT0, h, true, COL_B2T, false)
        drawArc(B1, T1, PB1, PT1, h, true, COL_B2T, false)
        drawArc(B2, T2, PB2, PT2, h, true, COL_B2T, false)
        drawArc(B3, T3, PB3, PT3, h, true, COL_B2T, false)

    // Top → Bottom (pink, bear market arcs)
    if SHOW_T2B
        drawArc(T0, B1, PT0, PB1, h, false, COL_T2B, false)
        drawArc(T1, B2, PT1, PB2, h, false, COL_T2B, false)
        drawArc(T2, B3, PT2, PB3, h, false, COL_T2B, false)
        if SHOW_NEXT
            // T→B: $109k → $45k, lift capped at 15% so it doesn't curl back up
            drawArc(T3, B4, PT3, PB4, h, false, COL_T2B, true)

    // Status bar
    int dsb = int((time - B3) / 86400000)
    int dst = int((time - T3) / 86400000)
    int dtb = int((B4 - time) / 86400000)
    string proj = dtb > 0 ? "~" + str.tostring(dtb) + "d to proj. bottom ~Oct 2026" : "Past proj. bottom date"
    label.new(bar_index, PB3 * 0.5,
         text  = str.tostring(dsb) + "d since Nov'22 bottom  |  " + str.tostring(dst) + "d since Oct'25 top  |  " + proj,
         xloc  = xloc.bar_index, yloc = yloc.price,
         color = color.new(color.gray, 15), textcolor = color.white,
         size  = size.normal, style = label.style_label_up)
````
