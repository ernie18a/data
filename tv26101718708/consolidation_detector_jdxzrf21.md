# Consolidation Detector

- url: https://www.tradingview.com/script/JDXZrf21-Consolidation-Detector/
- type: indicator
- pine_id: PUB;09c37925648e4df58363f1ff17b70eae
- version: 1.0

## Description

[b]Institutional tier detection for Micro Gold Futures[/b]

Identifies price consolidation zones during the MGC Globex session (6 PM – 5 PM ET) and classifies them into three tiers based on how long price holds within a defined range. Built specifically for Micro Gold Futures (MGC) but applicable to any instrument with extended trading hours.

[i]How it works[/i]

The script tracks three independent range thresholds simultaneously (5pt, 7pt, and 10pt). When price holds within a threshold for a sustained period, the zone is promoted through a tier system:

B-Tier (yellow) — consolidation held for 15+ minutes. Zone is forming.
A-Tier (orange) — consolidation held for 30+ minutes. Institutionally relevant.
S-Tier (purple) — consolidation held for 60+ minutes. High-conviction accumulation or distribution zone.

Each tier upgrade fires a separate alert. Zones are drawn as boxes and extend forward until price breaks out. When price exits a zone, the box border updates to reflect the final tier achieved.

[i]What to look for[/i]

S-Tier zones represent price areas where neither buyers nor sellers were willing to push price significantly. These are the levels institutions use to quietly accumulate or distribute positions. A breakout from an S-Tier zone — especially with elevated volume — is a high-probability directional signal.
Inputs

Range thresholds for each of the three trackers
Tier promotion times (B / A / S in minutes)
Session window (default 6 PM – 5 PM ET)
Per-tier visibility toggles

## Source Code

````pine
//@version=6
indicator("Consolidation Detector", shorttitle="Consolidation", overlay=true,
          max_lines_count=100, max_boxes_count=50, max_labels_count=250)

// ══════════════════════════════════════════════════════════════════════════════
//  MGC CONSOLIDATION DETECTOR  |  Pine Script v6
//  Asset: MGC (Micro Gold Futures, CME)
//  Session: 6:00 PM ET → 5:00 PM ET (next day)
//
//  Features:
//    · 3 quantitative ranges: 5pt / 7pt / 10pt
//    · Tier promotion: B (15 min) → A (30 min) → S (60 min+)
//    · Alerts fire ONCE per zone at each tier threshold
//    · Daily 6PM–5PM session high/low range lines
//    · Cyan Reversal Bounds — input simulation of manual dotted cyan lines
//
//  ⚠ NOTE ON CYAN LINE DETECTION:
//    Pine Script CANNOT read manually drawn chart lines — hard platform limit.
//    WORKAROUND: Enter the same prices as your cyan lines in the inputs below.
//    Script draws matching dotted cyan lines, fires alerts on touches, and
//    clamps consolidation detection within those bounds.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp1 = "① Consolidation Range Thresholds (Points)"
r5   = input.float(5.0,  "Range α — Tight   (5pt)",  minval=0.5, step=0.5, group=grp1)
r7   = input.float(7.0,  "Range β — Medium  (7pt)",  minval=0.5, step=0.5, group=grp1)
r10  = input.float(10.0, "Range γ — Wide    (10pt)", minval=0.5, step=0.5, group=grp1)

grp2 = "② Tier Time Thresholds (minutes)"
t_b  = input.int(15, "B Tier entry (min)", minval=1, group=grp2, tooltip="15–30 min = B Tier (Yellow)")
t_a  = input.int(30, "A Tier entry (min)", minval=1, group=grp2, tooltip="30–60 min = A Tier (Orange)")
t_s  = input.int(60, "S Tier entry (min)", minval=1, group=grp2, tooltip="60+ min   = S Tier (Purple)")

grp3 = "③ Cyan Reversal Bounds  (Simulates manual dotted cyan lines)"
use_cyan   = input.bool(false, "Enable Cyan Reversal Bounds", group=grp3,
                        tooltip="Enter prices matching your manually drawn cyan lines.")
cyan_upper = input.price(0.0, "Cyan Upper Bound price", confirm=false, group=grp3)
cyan_lower = input.price(0.0, "Cyan Lower Bound price", confirm=false, group=grp3)

grp4       = "④ Display Options"
show_boxes  = input.bool(true,  "Show Consolidation Boxes",   group=grp4)
show_labels = input.bool(true,  "Show Tier Labels on Boxes",  group=grp4)
show_daily  = input.bool(true,  "Show Daily Range (6PM–5PM)", group=grp4)
show_cyan   = input.bool(true,  "Draw Cyan Bound Lines",      group=grp4)

grp5    = "➕ Tier Visibility  (toggle individual tiers on/off)"
show_b  = input.bool(true, "🔷 Show B Tier (15 min)", group=grp5)
show_a  = input.bool(true, "🔶 Show A Tier (30 min)", group=grp5)
show_s  = input.bool(true, "⬛ Show S Tier (60 min)", group=grp5)

// ─────────────────────────────────────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────────────────────────────────────
C_B      = color.new(color.yellow, 70)
C_A      = color.new(color.orange, 65)
C_S      = color.new(color.purple, 55)
C_B_BDR  = color.new(color.yellow, 15)
C_A_BDR  = color.new(color.orange, 15)
C_S_BDR  = color.new(color.purple,  5)
C_CYAN   = color.new(#00DFFF, 0)
C_DAILY  = color.new(#00CED1, 0)

// ─────────────────────────────────────────────────────────────────────────────
//  SESSION  (MGC Globex: 6 PM ET → 5 PM ET, 23-hour)
// ─────────────────────────────────────────────────────────────────────────────
TZ       = "America/New_York"
MGC_SESS = "1800-1700"

bool in_sess  = not na(time("1", MGC_SESS, TZ))
bool new_sess = in_sess and not in_sess[1]

// ─────────────────────────────────────────────────────────────────────────────
//  DAILY RANGE  6 PM → 5 PM
//  Session high/low are natural consolidation anchors.
// ─────────────────────────────────────────────────────────────────────────────
var float d_hi    = na
var float d_lo    = na
var line  d_hi_ln = na
var line  d_lo_ln = na

if new_sess
    d_hi := high
    d_lo := low
    if show_daily
        d_hi_ln := line.new(bar_index, high, bar_index + 1, high,
                            color=C_DAILY, style=line.style_dashed, width=1)
        d_lo_ln := line.new(bar_index, low,  bar_index + 1, low,
                            color=C_DAILY, style=line.style_dashed, width=1)

if in_sess and not new_sess and not na(d_hi)
    d_hi := math.max(d_hi, high)
    d_lo := math.min(d_lo, low)
    if show_daily and not na(d_hi_ln)
        line.set_y1(d_hi_ln, d_hi)
        line.set_y2(d_hi_ln, d_hi)
        line.set_x2(d_hi_ln, bar_index + 30)
        line.set_y1(d_lo_ln, d_lo)
        line.set_y2(d_lo_ln, d_lo)
        line.set_x2(d_lo_ln, bar_index + 30)

// Session labels on last bar — declared as vars to avoid CE10235 in the block
var label d_hi_lbl = na
var label d_lo_lbl = na

if barstate.islast and show_daily and in_sess and not na(d_hi)
    if not na(d_hi_lbl)
        label.delete(d_hi_lbl)
    if not na(d_lo_lbl)
        label.delete(d_lo_lbl)
    float span = d_hi - d_lo
    d_hi_lbl := label.new(bar_index + 4, d_hi,
                          "⬆ Sess H: " + str.tostring(d_hi, "#.##") +
                          "  |  Range: " + str.tostring(span, "#.##") + "pt",
                          style=label.style_label_left,
                          color=C_DAILY, textcolor=color.black, size=size.small)
    d_lo_lbl := label.new(bar_index + 4, d_lo,
                          "⬇ Sess L: " + str.tostring(d_lo, "#.##"),
                          style=label.style_label_left,
                          color=C_DAILY, textcolor=color.black, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  CYAN REVERSAL BOUNDS
// ─────────────────────────────────────────────────────────────────────────────
bool cyan_ok = use_cyan and cyan_upper > 0.0 and cyan_lower > 0.0 and cyan_upper > cyan_lower

var line  c_up_ln   = na
var line  c_lo_ln   = na
var label c_up_lbl  = na
var label c_lo_lbl  = na

if barstate.islast and cyan_ok and show_cyan
    if not na(c_up_ln)
        line.delete(c_up_ln)
    if not na(c_lo_ln)
        line.delete(c_lo_ln)
    if not na(c_up_lbl)
        label.delete(c_up_lbl)
    if not na(c_lo_lbl)
        label.delete(c_lo_lbl)
    c_up_ln  := line.new(bar_index - 400, cyan_upper, bar_index + 80, cyan_upper,
                         color=C_CYAN, style=line.style_dotted, width=2)
    c_lo_ln  := line.new(bar_index - 400, cyan_lower, bar_index + 80, cyan_lower,
                         color=C_CYAN, style=line.style_dotted, width=2)
    c_up_lbl := label.new(bar_index + 6, cyan_upper,
                          "↑ Cyan Upper: " + str.tostring(cyan_upper, "#.##") +
                          "\n(Reversal Bound)",
                          style=label.style_label_left,
                          color=C_CYAN, textcolor=color.black, size=size.small)
    c_lo_lbl := label.new(bar_index + 6, cyan_lower,
                          "↓ Cyan Lower: " + str.tostring(cyan_lower, "#.##") +
                          "\n(Reversal Bound)",
                          style=label.style_label_left,
                          color=C_CYAN, textcolor=color.black, size=size.small)

bool cyan_upper_touch = cyan_ok and high >= cyan_upper and close < cyan_upper
bool cyan_lower_touch = cyan_ok and low  <= cyan_lower and close > cyan_lower
bool cyan_break       = cyan_ok and (high > cyan_upper or low < cyan_lower)

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
tier_fill(int t) =>
    t == 3 ? C_S : t == 2 ? C_A : C_B

tier_bdr(int t) =>
    t == 3 ? C_S_BDR : t == 2 ? C_A_BDR : C_B_BDR

tier_str(int t) =>
    t == 3 ? "⭐ S TIER" : t == 2 ? "🔶 A TIER" : "🔷 B TIER"

// ─────────────────────────────────────────────────────────────────────────────
//  UDT — CONSOLIDATION ZONE STATE
// ─────────────────────────────────────────────────────────────────────────────
type ConsolZone
    float sz
    float hi
    float lo
    int   bar0
    int   ms0
    bool  active
    int   tier
    bool  sent_b
    bool  sent_a
    bool  sent_s
    box   bx
    label lb

// ─────────────────────────────────────────────────────────────────────────────
//  CORE: PROCESS ONE ZONE TRACKER PER BAR
//
//  FIX CE10235: Replaced every  if/else  where one branch returned
//  series label/box and the other returned void.
//  Pattern used: split into  if na()  +  if not na()  so both blocks
//  are purely void (assignments and .set_* calls only).
// ─────────────────────────────────────────────────────────────────────────────
process_zone(ConsolZone z) =>
    float bar_hi = cyan_ok ? math.min(high, cyan_upper) : high
    float bar_lo = cyan_ok ? math.max(low,  cyan_lower) : low

    // Reset on session end or new session start
    if not in_sess or new_sess
        z.active := false
        z.tier   := 0
        z.sent_b := false
        z.sent_a := false
        z.sent_s := false
        z.bx     := na
        z.lb     := na

    // Start fresh zone on first bar in session
    if in_sess and not z.active
        z.hi     := bar_hi
        z.lo     := bar_lo
        z.bar0   := bar_index
        z.ms0    := time
        z.active := true
        z.tier   := 0
        z.sent_b := false
        z.sent_a := false
        z.sent_s := false

    if z.active
        float new_hi = math.max(z.hi, bar_hi)
        float new_lo = math.min(z.lo, bar_lo)
        float span   = new_hi - new_lo
        bool  broken = span > z.sz or cyan_break

        if broken
            // Invalidate zone — historical box stays on chart
            z.active := false
            z.tier   := 0
            z.bx     := na
            z.lb     := na

        if z.active
            z.hi := new_hi
            z.lo := new_lo

            float mins = (time - z.ms0) / 60000.0
            int new_tier = mins >= t_s ? 3 : mins >= t_a ? 2 : mins >= t_b ? 1 : 0
            z.tier := new_tier

            bool tier_visible = (new_tier == 1 and show_b) or (new_tier == 2 and show_a) or (new_tier == 3 and show_s)
            if show_boxes and new_tier > 0 and tier_visible
                color fc = tier_fill(new_tier)
                color bc = tier_bdr(new_tier)

                // ── Box: create if missing ──────────────────────────────────
                // FIXED CE10235: split if/else into two separate if blocks
                if na(z.bx)
                    z.bx := box.new(z.bar0, z.hi, bar_index, z.lo,
                                    border_color=bc, bgcolor=fc, border_width=1)

                if not na(z.bx)
                    box.set_right(z.bx,        bar_index)
                    box.set_top(z.bx,          z.hi)
                    box.set_bottom(z.bx,       z.lo)
                    box.set_border_color(z.bx, bc)
                    box.set_bgcolor(z.bx,       fc)

                // ── Label: create if missing ────────────────────────────────
                // FIXED CE10235: same split pattern
                if show_labels
                    string txt = tier_str(new_tier) + "  [" +
                                 str.tostring(z.sz, "#") + "pt | " +
                                 str.tostring(math.round(mins)) + "m]"

                    if na(z.lb)
                        z.lb := label.new(bar_index, z.hi, txt,
                                          style    =label.style_label_down,
                                          color    =bc,
                                          textcolor=color.white,
                                          size     =size.small)

                    if not na(z.lb)
                        label.set_x(z.lb,     bar_index)
                        label.set_y(z.lb,     z.hi)
                        label.set_text(z.lb,  txt)
                        label.set_color(z.lb, bc)

// ─────────────────────────────────────────────────────────────────────────────
//  INSTANTIATE THREE ZONE TRACKERS
// ─────────────────────────────────────────────────────────────────────────────
var ConsolZone z5  = ConsolZone.new(r5,  na, na, 0, 0, false, 0, false, false, false, na, na)
var ConsolZone z7  = ConsolZone.new(r7,  na, na, 0, 0, false, 0, false, false, false, na, na)
var ConsolZone z10 = ConsolZone.new(r10, na, na, 0, 0, false, 0, false, false, false, na, na)

process_zone(z5)
process_zone(z7)
process_zone(z10)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERT TRIGGER BOOLEANS
//  sent_* flags ensure each tier fires exactly once per zone.
//
//  FIXED CE10156: removed all `then` keywords — Pine v6 uses indented blocks.
// ─────────────────────────────────────────────────────────────────────────────
bool fire_b5  = z5.active  and z5.tier  >= 1 and not z5.sent_b
bool fire_b7  = z7.active  and z7.tier  >= 1 and not z7.sent_b
bool fire_b10 = z10.active and z10.tier >= 1 and not z10.sent_b

bool fire_a5  = z5.active  and z5.tier  >= 2 and not z5.sent_a
bool fire_a7  = z7.active  and z7.tier  >= 2 and not z7.sent_a
bool fire_a10 = z10.active and z10.tier >= 2 and not z10.sent_a

bool fire_s5  = z5.active  and z5.tier  == 3 and not z5.sent_s
bool fire_s7  = z7.active  and z7.tier  == 3 and not z7.sent_s
bool fire_s10 = z10.active and z10.tier == 3 and not z10.sent_s

// Mark sent — FIXED: no `then`, proper indented block
if fire_b5
    z5.sent_b := true
if fire_b7
    z7.sent_b := true
if fire_b10
    z10.sent_b := true
if fire_a5
    z5.sent_a := true
if fire_a7
    z7.sent_a := true
if fire_a10
    z10.sent_a := true
if fire_s5
    z5.sent_s := true
if fire_s7
    z7.sent_s := true
if fire_s10
    z10.sent_s := true

bool any_b = fire_b5  or fire_b7  or fire_b10
bool any_a = fire_a5  or fire_a7  or fire_a10
bool any_s = fire_s5  or fire_s7  or fire_s10

// ─────────────────────────────────────────────────────────────────────────────
//  ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(any_b,
               title  ="MGC 🔷 B-Tier Consolidation (15 min)",
               message="MGC: B-Tier zone — 15+ min consolidation. Watch for reversal setup.")

alertcondition(any_a,
               title  ="MGC 🔶 A-Tier Consolidation (30 min)",
               message="MGC: A-Tier zone — 30+ min consolidation. Higher-conviction reversal window.")

alertcondition(any_s,
               title  ="MGC ⭐ S-Tier Consolidation (60 min+)",
               message="MGC: ★ S-TIER ★  1+ HOUR of consolidation. Major move likely.")

alertcondition(cyan_ok and cyan_upper_touch,
               title  ="MGC Cyan UPPER Bound Touch",
               message="MGC: Price touched UPPER cyan bound. Potential downside reversal.")

alertcondition(cyan_ok and cyan_lower_touch,
               title  ="MGC Cyan LOWER Bound Touch",
               message="MGC: Price touched LOWER cyan bound. Potential upside reversal.")

// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
//  BACKGROUND SHADING
// ─────────────────────────────────────────────────────────────────────────────
int  best_tier = math.max(z5.tier, math.max(z7.tier, z10.tier))
bool any_live  = (z5.active or z7.active or z10.active) and best_tier > 0

bgcolor(show_b and any_live and best_tier == 1 ? color.new(color.yellow, 93) : na, title="B Tier BG")
bgcolor(show_a and any_live and best_tier == 2 ? color.new(color.orange, 90) : na, title="A Tier BG")
bgcolor(show_s and any_live and best_tier == 3 ? color.new(color.purple, 86) : na, title="S Tier BG")

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD LABEL (last bar)
// ─────────────────────────────────────────────────────────────────────────────
var label dash_lbl = na

if barstate.islast
    if not na(dash_lbl)
        label.delete(dash_lbl)

    string s5  = z5.active  ? (z5.tier  > 0 ? tier_str(z5.tier)  : "⏳ Forming") : "—"
    string s7  = z7.active  ? (z7.tier  > 0 ? tier_str(z7.tier)  : "⏳ Forming") : "—"
    string s10 = z10.active ? (z10.tier > 0 ? tier_str(z10.tier) : "⏳ Forming") : "—"
    string cy  = cyan_ok ? "✅ " + str.tostring(cyan_upper,"#.##") +
                           " / " + str.tostring(cyan_lower,"#.##") : "off"

    string d = "━━━━━━━━━━━━━━━━━━━━━━━\n" +
               "  MGC CONSOLIDATION\n"      +
               "━━━━━━━━━━━━━━━━━━━━━━━\n" +
               " 5pt  │ " + s5  + "\n"     +
               " 7pt  │ " + s7  + "\n"     +
               "10pt  │ " + s10 + "\n"     +
               "━━━━━━━━━━━━━━━━━━━━━━━\n" +
               " Cyan │ " + cy

    dash_lbl := label.new(bar_index, ta.highest(high, 20), d,
                          style    =label.style_label_left,
                          color    =color.new(#111111, 20),
                          textcolor=color.white,
                          size     =size.small,
                          xloc     =xloc.bar_index,
                          yloc     =yloc.price)
````
