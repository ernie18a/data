# NIFTY Wave C-3 Map + A-3 Analog

- url: https://www.tradingview.com/script/0FQAzw0k-NIFTY-Wave-C-3-Map-A-3-Analog/
- type: indicator
- pine_id: PUB;eb43241ddb0f45238dc822b72caf975e
- version: 2.0

## Description

NIFTY Wave C-3 Map + A-3 Analog Sub waves with targets

## Source Code

````pine
//@version=5
indicator("NIFTY Full Elliott Wave Cycles + C-3 Projection", overlay=true, max_lines_count=200, max_labels_count=100, max_boxes_count=5)

// ═══════════════════════════════════════════════════════════════════════
// NIFTY Elliott Wave — Complete A-B-C from Jan 2026 ATH
//
// Wave A internals (5-wave impulse):
//   A-1: Jan 5  (26,372) → Jan 21 (24,920)
//   A-2: Jan 21 (24,920) → Feb 3  (26,308)  Budget Day bounce 95.6%
//   A-3: Feb 3  (26,308) → Mar 23 (22,483)  Extended -14.5%
//   A-4: Mar 23 (22,483) → Mar 25 (23,465)
//   A-5: Mar 25 (23,465) → Apr 2  (22,183)
//
// Wave B: Apr 2 (22,183) → Apr 21 (24,600)  57.7% retrace
//
// Wave C internals (in progress):
//   C-1: Apr 21 (24,600) → Apr 24 (23,815)
//   C-2: Apr 24 (23,815) → May 7  (24,466)  82.9% retrace
//   C-3: May 7  (24,466) → IN PROGRESS  [revised to A-B-C sub-structure]
//     C-3-A: May 7  (24,466) → May 13 (23,263)
//     C-3-B: May 13 (23,263) → May 26 (24,051)  EXPIRY DAY — topping?
//     C-3-C: PENDING  → primary target 22,908
//
// Today May 26 = Feb 26 analog (corrected +4 day offset vs A-3)
// ═══════════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────────────
show_a_waves = input.bool(true,  "Wave A sub-waves (A-1 to A-5)")
show_b_wave  = input.bool(true,  "Wave B")
show_c_waves = input.bool(true,  "Wave C sub-waves (C-1, C-2, C-3)")
show_proj    = input.bool(true,  "A-3 Analog Projection (C-3-C)")
show_tgts    = input.bool(true,  "C-3-C Target Levels")
show_labels  = input.bool(true,  "Wave Labels")
show_levels  = input.bool(true,  "Key Support/Resistance")
show_table   = input.bool(true,  "Info Table")

// ─── TIMESTAMPS — WAVE A ────────────────────────────────────────────────
t_ath    = timestamp(2026, 1,  5, 0, 0, 0)  // ATH     26,372
t_a1e    = timestamp(2026, 1, 21, 0, 0, 0)  // A-1 end  24,920
t_a2e    = timestamp(2026, 2,  3, 0, 0, 0)  // A-2 end  26,308 (Budget Day)
t_a3e    = timestamp(2026, 3, 23, 0, 0, 0)  // A-3 end  22,483
t_a4e    = timestamp(2026, 3, 25, 0, 0, 0)  // A-4 end  23,465
t_a5e    = timestamp(2026, 4,  2, 0, 0, 0)  // A-5 end  22,183 = Wave A low

// ─── TIMESTAMPS — WAVE B ────────────────────────────────────────────────
t_bhi    = timestamp(2026, 4, 21, 0, 0, 0)  // Wave B high  24,600

// ─── TIMESTAMPS — WAVE C ────────────────────────────────────────────────
t_c1e    = timestamp(2026, 4, 24, 0, 0, 0)  // C-1 end  23,815
t_c2e    = timestamp(2026, 5,  7, 0, 0, 0)  // C-2 end  24,466 = C-3 start
t_c3ae   = timestamp(2026, 5, 13, 0, 0, 0)  // C-3-A end  23,263
t_c3b    = timestamp(2026, 5, 26, 0, 0, 0)  // C-3-B top?  24,051 EXPIRY

// ─── TIMESTAMPS — PROJECTION (A-3 analog, corrected offset) ─────────────
t_d14  = timestamp(2026, 5, 27, 0, 0, 0)   // ~23,422  -4.3%
t_d15  = timestamp(2026, 5, 28, 0, 0, 0)   // ~23,121  -5.5%
t_d16  = timestamp(2026, 5, 29, 0, 0, 0)   // ~22,767  -6.9%
t_d17  = timestamp(2026, 6,  1, 0, 0, 0)   // ~23,031  -5.9%  bounce
t_d18  = timestamp(2026, 6,  2, 0, 0, 0)   // ~22,754  -7.0%
t_d19  = timestamp(2026, 6,  3, 0, 0, 0)   // ~22,338  -8.7%
t_d20  = timestamp(2026, 6,  4, 0, 0, 0)   // ~22,580  -7.7%  bounce
t_d21  = timestamp(2026, 6,  5, 0, 0, 0)   // ~22,173  -9.3%
t_d22  = timestamp(2026, 6,  8, 0, 0, 0)   // ~21,975  -10.2%
t_d23  = timestamp(2026, 6,  9, 0, 0, 0)   // ~21,521  -12.0%
t_d24  = timestamp(2026, 6, 10, 0, 0, 0)   // ~21,711  -11.2% bounce
t_d25  = timestamp(2026, 6, 11, 0, 0, 0)   // ~21,929  -10.4% bounce
t_d27  = timestamp(2026, 6, 15, 0, 0, 0)   // ~21,391  -12.6%
t_d29  = timestamp(2026, 6, 17, 0, 0, 0)   // ~20,913  -14.5% A-3 end analog
t_end  = timestamp(2026, 7,  8, 0, 0, 0)   // label anchor right edge

// ─── PRICES — WAVE A ────────────────────────────────────────────────────
p_ath   = 26372.0
p_a1e   = 24920.0
p_a2e   = 26308.0
p_a3e   = 22483.0
p_a4e   = 23465.0
p_a5e   = 22183.0

// ─── PRICES — WAVE B / C ────────────────────────────────────────────────
p_bhi   = 24600.0
p_c1e   = 23815.0
p_c2e   = 24466.0
p_c3ae  = 23263.0
p_c3b   = 24051.0

// ─── PRICES — PROJECTION ────────────────────────────────────────────────
p_d14 = 23422.0
p_d15 = 23121.0
p_d16 = 22767.0
p_d17 = 23031.0
p_d18 = 22754.0
p_d19 = 22338.0
p_d20 = 22580.0
p_d21 = 22173.0
p_d22 = 21975.0
p_d23 = 21521.0
p_d24 = 21711.0
p_d25 = 21929.0
p_d27 = 21391.0
p_d29 = 20913.0

// ─── TARGET LEVELS ──────────────────────────────────────────────────────
p_tgt_618  = 23368.0   // C-3-C = 0.618 x C-3-A
p_tgt_100  = 22908.0   // C-3-C = 1.000 x C-3-A  PRIMARY
p_tgt_1618 = 22165.0   // C-3-C = 1.618 x C-3-A  (near Wave A low)
p_bull_inv  = 24466.0  // above = bull reversal
p_bear_trig = 23900.0  // bear trigger (C-3-B rolling over)
p_dbl_bot   = 23263.0  // May 13 double bottom

// ─── COLORS ─────────────────────────────────────────────────────────────
// Wave degree: primary dim, intermediate bright, minor light
c_dn_p  = color.new(color.red,     0)   // primary down  (thick)
c_up_p  = color.new(color.green,   0)   // primary up    (thick)
c_dn_i  = color.new(color.red,    20)   // intermediate down
c_up_i  = color.new(color.green,  20)   // intermediate up
c_dn_m  = color.new(color.red,    45)   // minor down
c_up_m  = color.new(color.green,  45)   // minor up (C-3-B)
c_proj  = color.new(color.orange,   0)  // projection path
c_wht   = color.white

// ─── DRAW ON LAST BAR ────────────────────────────────────────────────────
if barstate.islast

    // ════════════════════════════════════════════════════════════════
    // WAVE A  —  5-wave impulse down (Jan 5 → Apr 2)
    // ════════════════════════════════════════════════════════════════
    if show_a_waves
        // A-1 down
        line.new(x1=t_ath,  y1=p_ath,  x2=t_a1e, y2=p_a1e, xloc=xloc.bar_time, color=c_dn_i, width=2)
        // A-2 up  (Budget Day bounce — 95.6% retrace, near ATH retest)
        line.new(x1=t_a1e,  y1=p_a1e,  x2=t_a2e, y2=p_a2e, xloc=xloc.bar_time, color=c_up_i, width=2)
        // A-3 down  (extended, -14.5%)
        line.new(x1=t_a2e,  y1=p_a2e,  x2=t_a3e, y2=p_a3e, xloc=xloc.bar_time, color=c_dn_p, width=3)
        // A-4 up
        line.new(x1=t_a3e,  y1=p_a3e,  x2=t_a4e, y2=p_a4e, xloc=xloc.bar_time, color=c_up_i, width=2)
        // A-5 down  (final leg to Wave A low)
        line.new(x1=t_a4e,  y1=p_a4e,  x2=t_a5e, y2=p_a5e, xloc=xloc.bar_time, color=c_dn_i, width=2)

    // ════════════════════════════════════════════════════════════════
    // WAVE B  —  single corrective up (Apr 2 → Apr 21)
    // ════════════════════════════════════════════════════════════════
    if show_b_wave
        line.new(x1=t_a5e, y1=p_a5e, x2=t_bhi, y2=p_bhi, xloc=xloc.bar_time, color=c_up_p, width=3)

    // ════════════════════════════════════════════════════════════════
    // WAVE C  —  internals (Apr 21 → ongoing)
    // ════════════════════════════════════════════════════════════════
    if show_c_waves
        // C-1 down
        line.new(x1=t_bhi,  y1=p_bhi,  x2=t_c1e,  y2=p_c1e,  xloc=xloc.bar_time, color=c_dn_i, width=2)
        // C-2 up  (deep 82.9% retrace)
        line.new(x1=t_c1e,  y1=p_c1e,  x2=t_c2e,  y2=p_c2e,  xloc=xloc.bar_time, color=c_up_i, width=2)
        // C-3-A down  (first leg of C-3 revised A-B-C)
        line.new(x1=t_c2e,  y1=p_c2e,  x2=t_c3ae, y2=p_c3ae, xloc=xloc.bar_time, color=c_dn_p, width=3)
        // C-3-B up  (bounce, in progress — dashed)
        line.new(x1=t_c3ae, y1=p_c3ae, x2=t_c3b,  y2=p_c3b,  xloc=xloc.bar_time, color=c_up_m, width=2, style=line.style_dashed)

    // ════════════════════════════════════════════════════════════════
    // C-3-B RESISTANCE ZONE
    // ════════════════════════════════════════════════════════════════
    box.new(left=t_c3b, top=p_bull_inv, right=t_end, bottom=24111.0, xloc=xloc.bar_time, border_color=color.new(color.orange, 40), bgcolor=color.new(color.orange, 88), text="C-3-B ZONE  24,111 - 24,466", text_color=color.orange, text_size=size.small)

    // ════════════════════════════════════════════════════════════════
    // A-3 ANALOG PROJECTION  —  C-3-C projected path (orange dashed)
    // ════════════════════════════════════════════════════════════════
    if show_proj
        // Down legs
        line.new(x1=t_c3b, y1=p_c3b, x2=t_d14, y2=p_d14, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d14, y1=p_d14, x2=t_d15, y2=p_d15, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d15, y1=p_d15, x2=t_d16, y2=p_d16, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d17, y1=p_d17, x2=t_d18, y2=p_d18, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d18, y1=p_d18, x2=t_d19, y2=p_d19, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d20, y1=p_d20, x2=t_d21, y2=p_d21, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d21, y1=p_d21, x2=t_d22, y2=p_d22, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d22, y1=p_d22, x2=t_d23, y2=p_d23, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d25, y1=p_d25, x2=t_d27, y2=p_d27, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        line.new(x1=t_d27, y1=p_d27, x2=t_d29, y2=p_d29, xloc=xloc.bar_time, color=c_proj, width=2, style=line.style_dashed)
        // Bounce legs (thin green dashed)
        line.new(x1=t_d16, y1=p_d16, x2=t_d17, y2=p_d17, xloc=xloc.bar_time, color=c_up_m, width=1, style=line.style_dashed)
        line.new(x1=t_d19, y1=p_d19, x2=t_d20, y2=p_d20, xloc=xloc.bar_time, color=c_up_m, width=1, style=line.style_dashed)
        line.new(x1=t_d23, y1=p_d23, x2=t_d25, y2=p_d25, xloc=xloc.bar_time, color=c_up_m, width=1, style=line.style_dashed)

    // ════════════════════════════════════════════════════════════════
    // WAVE LABELS
    // ════════════════════════════════════════════════════════════════
    if show_labels

        // ── Primary degree labels (large) ──────────────────────────
        label.new(x=t_ath,  y=p_ath  + 100, text="ATH\n26,372\nJan 5",         xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.navy,  10), textcolor=c_wht, size=size.normal)
        label.new(x=t_a5e,  y=p_a5e  -  80, text="Wave A\n22,183\nApr 2",      xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(color.red,   15), textcolor=c_wht, size=size.normal)
        label.new(x=t_bhi,  y=p_bhi  + 100, text="Wave B\n24,600\nApr 21",     xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.green, 15), textcolor=c_wht, size=size.normal)

        // ── Wave A sub-wave labels (small) ─────────────────────────
        label.new(x=t_a1e,  y=p_a1e  -  50, text="a1\n24,920\nJan 21",         xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(color.red,   35), textcolor=c_wht, size=size.small)
        label.new(x=t_a2e,  y=p_a2e  +  50, text="a2\n26,308\nFeb 3\nBudget",  xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.green, 35), textcolor=c_wht, size=size.small)
        label.new(x=t_a3e,  y=p_a3e  -  50, text="a3\n22,483\nMar 23\n-14.5%", xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(color.red,   25), textcolor=c_wht, size=size.small)
        label.new(x=t_a4e,  y=p_a4e  +  40, text="a4\n23,465\nMar 25",         xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.green, 35), textcolor=c_wht, size=size.small)

        // ── Wave C sub-wave labels ─────────────────────────────────
        label.new(x=t_c1e,  y=p_c1e  -  50, text="C-1\n23,815\nApr 24",        xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(color.red,   30), textcolor=c_wht, size=size.small)
        label.new(x=t_c2e,  y=p_c2e  +  50, text="C-2\n24,466\nMay 7\nC-3 start", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.green, 25), textcolor=c_wht, size=size.small)
        label.new(x=t_c3ae, y=p_c3ae -  60, text="C-3-A\n23,263\nMay 13\nDbl bottom", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.red, 25), textcolor=c_wht, size=size.small)
        label.new(x=t_c3b,  y=p_c3b  +  60, text="C-3-B TOP?\nEXPIRY TODAY\n24,051 | May 26\nFeb 26 analog", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.red, 10), textcolor=c_wht, size=size.small)

        // ── Projection labels ──────────────────────────────────────
        if show_proj
            label.new(x=t_d14, y=p_d14 -  60, text="May 27 D+1\n~23,422 (-4.3%)", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.red, 20), textcolor=c_wht, size=size.small)
            label.new(x=t_d16, y=p_d16 -  60, text="May 29\n~22,767 (-6.9%)",      xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.red, 30), textcolor=c_wht, size=size.tiny)
            label.new(x=t_d19, y=p_d19 -  60, text="Jun 3\n~22,338 (-8.7%)",       xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.red, 25), textcolor=c_wht, size=size.small)
            label.new(x=t_d23, y=p_d23 -  80, text="Jun 9\n~21,521 (-12.0%)",      xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.red, 15), textcolor=c_wht, size=size.small)
            label.new(x=t_d29, y=p_d29 - 100, text="Jun 17\n~20,913 (-14.5%)\nA-3 end", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.maroon, 10), textcolor=c_wht, size=size.small)

    // ════════════════════════════════════════════════════════════════
    // TARGET LEVELS
    // ════════════════════════════════════════════════════════════════
    if show_tgts
        line.new(x1=t_c3b, y1=p_tgt_618,  x2=t_end, y2=p_tgt_618,  xloc=xloc.bar_time, color=color.new(color.orange, 30), width=1, style=line.style_dotted)
        line.new(x1=t_c3b, y1=p_tgt_100,  x2=t_end, y2=p_tgt_100,  xloc=xloc.bar_time, color=color.new(color.red,    15), width=2, style=line.style_dotted)
        line.new(x1=t_c3b, y1=p_tgt_1618, x2=t_end, y2=p_tgt_1618, xloc=xloc.bar_time, color=color.new(color.maroon, 15), width=1, style=line.style_dotted)
        line.new(x1=t_a5e, y1=p_a5e,      x2=t_end, y2=p_a5e,      xloc=xloc.bar_time, color=color.new(color.maroon, 50), width=1, style=line.style_dotted)

        label.new(x=t_end, y=p_tgt_618  + 10, text="0.618x  23,368",     xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.orange, 60), textcolor=color.orange, size=size.tiny)
        label.new(x=t_end, y=p_tgt_100  + 10, text="PRIMARY  22,908",    xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.red,    15), textcolor=color.red,    size=size.small)
        label.new(x=t_end, y=p_tgt_1618 + 10, text="1.618x  22,165",     xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.maroon, 35), textcolor=color.maroon, size=size.tiny)
        label.new(x=t_end, y=p_a5e      - 20, text="Wave A low  22,183", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.maroon, 55), textcolor=color.maroon, size=size.tiny)

    // ════════════════════════════════════════════════════════════════
    // KEY LEVELS
    // ════════════════════════════════════════════════════════════════
    if show_levels
        line.new(x1=t_c2e,  y1=p_bull_inv,  x2=t_end, y2=p_bull_inv,  xloc=xloc.bar_time, color=color.new(color.green, 40), width=1, style=line.style_dashed)
        line.new(x1=t_c3b,  y1=p_bear_trig, x2=t_end, y2=p_bear_trig, xloc=xloc.bar_time, color=color.new(color.red,   55), width=1, style=line.style_dotted)
        line.new(x1=t_c3ae, y1=p_dbl_bot,   x2=t_end, y2=p_dbl_bot,   xloc=xloc.bar_time, color=color.new(color.teal, 50), width=1, style=line.style_dotted)

        label.new(x=t_end, y=p_bull_inv  + 25, text="Bull invalidation  24,466", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.green, size=size.tiny)
        label.new(x=t_end, y=p_bear_trig + 15, text="Bear trigger  23,900",      xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.red,   65), textcolor=color.red,   size=size.tiny)
        label.new(x=t_end, y=p_dbl_bot   - 25, text="Double bottom  23,263",     xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.teal, 65), textcolor=color.teal,  size=size.tiny)

    // ════════════════════════════════════════════════════════════════
    // INFO TABLE (top-right)
    // ════════════════════════════════════════════════════════════════
    if show_table
        var tbl = table.new(position.top_right, 2, 13, bgcolor=color.new(color.navy, 15), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)
        table.cell(tbl, 0, 0,  "NIFTY WAVE STATUS",     text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 10))
        table.cell(tbl, 1, 0,  "EXPIRY DAY May 26",     text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy, 10))
        table.cell(tbl, 0, 1,  "Structure",             text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 1,  "A-B-C from ATH",        text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 0, 2,  "Wave A",                text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 2,  "5-wave  22,183 done",   text_color=color.lime,   text_size=size.tiny)
        table.cell(tbl, 0, 3,  "Wave B",                text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 3,  "24,600 done  57.7%",    text_color=color.lime,   text_size=size.tiny)
        table.cell(tbl, 0, 4,  "C-3-B analog",          text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 4,  "Feb 26 (Day 13)",       text_color=color.orange, text_size=size.tiny)
        table.cell(tbl, 0, 5,  "C-3-B close",           text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 5,  "24,051  -1.7%",         text_color=color.orange, text_size=size.tiny)
        table.cell(tbl, 0, 6,  "A-3 was at Feb 26",     text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 6,  "-3.1%  BOUNCE",         text_color=color.lime,   text_size=size.tiny)
        table.cell(tbl, 0, 7,  "PROJECTION",            text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 1, 7,  "A-3 analog",            text_color=color.gray,   text_size=size.tiny)
        table.cell(tbl, 0, 8,  "May 27 D+1",            text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 1, 8,  "~23,422 -4.3%",         text_color=color.red,    text_size=size.tiny)
        table.cell(tbl, 0, 9,  "May 29 (D16)",          text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 1, 9,  "~22,767 -6.9%",         text_color=color.red,    text_size=size.tiny)
        table.cell(tbl, 0, 10, "Jun 3  (D19)",          text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 1, 10, "~22,338 -8.7%",         text_color=color.red,    text_size=size.tiny)
        table.cell(tbl, 0, 11, "Jun 9  (D23)",          text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 1, 11, "~21,521 -12.0%",        text_color=color.red,    text_size=size.tiny)
        table.cell(tbl, 0, 12, "PRIMARY TARGET",        text_color=color.white,  text_size=size.tiny)
        table.cell(tbl, 1, 12, "22,908",                text_color=color.red,    text_size=size.small)
````
