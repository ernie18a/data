# Trade Quality Scorecard

- url: https://www.tradingview.com/script/2AW10FJN-Trade-Quality-Scorecard/
- type: indicator
- pine_id: PUB;4d6f68134d214b68a4731ec3194e9956
- version: 1.0

## Description

Trading checklist made by jack to be reviewed by taylor for Dax

## Source Code

````pine
// ============================================================
// TRADE QUALITY SCORECARD (TQS)
// Pine Script v6
// Version: 1.8
//
// PURPOSE:
// A clean discretionary trade quality checklist and scoring dashboard.
// This indicator does NOT place trades or generate buy/sell signals.
// It helps assess whether a setup is high enough quality to execute.
//
// SCORING:
// Each checked item = 1 point.
// Reversal:     6 common criteria + 2 reversal criteria     = 8 max.
// Continuation: 6 common criteria + 1 continuation criteria = 7 max.
// ============================================================

//@version=6
indicator(title="Trade Quality Scorecard", shorttitle="TQS", overlay=true)

// ============================================================
// SECTION 1: DISPLAY SETTINGS
// ============================================================

grp_display = "Display Settings"

show_dashboard = input.bool(
     defval=true,
     title="Show Dashboard",
     group=grp_display)

position_choice = input.string(
     defval="Top Right",
     title="Dashboard Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=grp_display)

compact_mode = input.bool(
     defval=false,
     title="Compact Mode",
     group=grp_display,
     tooltip="When enabled, only Setup, Score, Grade and Decision are shown.")

dashboard_size = input.string(
     defval="Normal",
     title="Dashboard Size",
     options=["Small", "Normal", "Large"],
     group=grp_display,
     tooltip="Adjusts the dashboard text size while keeping the same working layout.")

min_grade_input = input.string(
     defval="B+",
     title="Minimum Executable Grade",
     options=["A+", "A", "B+"],
     group=grp_display,
     tooltip="Default is B+. B+ means the setup meets the minimum execution threshold.")

// ============================================================
// SECTION 2: SETUP TYPE
// ============================================================

grp_setup = "Setup Configuration"

setup_type = input.string(
     defval="Continuation",
     title="Setup Type",
     options=["Continuation", "Reversal"],
     group=grp_setup,
     tooltip="Select whether the setup is a continuation or reversal. This controls which setup-specific criteria are scored.")

// ============================================================
// SECTION 3: COMMON CHECKLIST CRITERIA
// These are always scored for both Reversal and Continuation.
// ============================================================

grp_common = "Common Criteria"

c1_htf_narrative = input.bool(
     defval=false,
     title="HTF Alignment",
     group=grp_common,
     tooltip="Daily, 4H and 1H narrative align with the intended trade direction. Price should be framed from clear HTF context such as a PD array, FVG, IRL/ERL logic, premium/discount, or a defined draw on liquidity.")

c2_key_liquidity = input.bool(
     defval=false,
     title="Key Liquidity Present",
     group=grp_common,
     tooltip="Relevant liquidity is present and usable. This may include session highs/lows, Asia H/L, London H/L, PDH/PDL, PWH/PWL, equal highs/lows, BSL or SSL.")

c3_session_hours = input.bool(
     defval=false,
     title="Session Timing",
     group=grp_common,
     tooltip="Setup forms within your planned London AM execution window, ideally 07:00-10:00. Avoid forcing trades outside session timing or directly on the 07:00/08:00 open.")

c4_breakeven = input.bool(
     defval=false,
     title="BE Level Available",
     group=grp_common,
     tooltip="There is a logical breakeven level available, usually at the next swing high/low, after liquidity is taken, or around a clear unmitigated FVG.")

c5_clear_r2 = input.bool(
     defval=false,
     title="DOL 1:2+ Available",
     group=grp_common,
     tooltip="The draw on liquidity is at least 1:2 RR away from entry, with clean delivery preferred towards 1:3. Avoid if internal liquidity, opposing structure or FVGs block price.")

c6_no_red_flags = input.bool(
     defval=false,
     title="No Red Flags",
     group=grp_common,
     tooltip="No obvious reason to avoid the trade: high-impact news, NFP/CPI/FOMC risk, news-range chop, poor spread, weak displacement, large pre-session expansion, holiday volume, session-open impulse entry, or HTF conflict.")

// ============================================================
// SECTION 4: REVERSAL-SPECIFIC CRITERIA
// Only scored when Setup Type = Reversal.
// ============================================================

grp_reversal = "Reversal Criteria"

r1_vshape = input.bool(
     defval=false,
     title="Sweep + V-Reaction",
     group=grp_reversal,
     tooltip="Liquidity has been swept and price reacts sharply away from the zone. The reaction should be clean, impulsive and show genuine rejection.")

r2_ifvg = input.bool(
     defval=false,
     title="5m/15m IFVG Present",
     group=grp_reversal,
     tooltip="A 5m or 15m IFVG forms after displacement. Entry should be based on the close through the FVG or retest of the IFVG, aligned with the HTF draw on liquidity.")

// ============================================================
// SECTION 5: CONTINUATION-SPECIFIC CRITERIA
// Only scored when Setup Type = Continuation.
// ============================================================

grp_continuation = "Continuation Criteria"

k1_gap = input.bool(
     defval=false,
     title="5m/15m Entry FVG",
     group=grp_continuation,
     tooltip="A valid 5m or 15m FVG / imbalance is respected in line with HTF bias and acts as the continuation entry vehicle towards the draw on liquidity.")

// ============================================================
// SECTION 6: SCORING LOGIC
// ============================================================

is_reversal = setup_type == "Reversal"

common_score =
     (c1_htf_narrative ? 1 : 0) +
     (c2_key_liquidity ? 1 : 0) +
     (c3_session_hours ? 1 : 0) +
     (c4_breakeven     ? 1 : 0) +
     (c5_clear_r2      ? 1 : 0) +
     (c6_no_red_flags  ? 1 : 0)

specific_score = is_reversal
     ? ((r1_vshape ? 1 : 0) + (r2_ifvg ? 1 : 0))
     : (k1_gap ? 1 : 0)

total_score = common_score + specific_score
max_score = is_reversal ? 8 : 7

// ============================================================
// SECTION 7: GRADE LOGIC
// ============================================================
//
// Reversal:
// 8   = A+
// 7   = A
// 6   = B+
// 5   = B
// 4   = C
// 0-3 = F
//
// Continuation:
// 7   = A+
// 6   = A
// 5   = B+
// 4   = B
// 3   = C
// 0-2 = F
// ============================================================

grade = is_reversal
     ? total_score == 8 ? "A+"
     : total_score == 7 ? "A"
     : total_score == 6 ? "B+"
     : total_score == 5 ? "B"
     : total_score == 4 ? "C"
     : "F"
     : total_score == 7 ? "A+"
     : total_score == 6 ? "A"
     : total_score == 5 ? "B+"
     : total_score == 4 ? "B"
     : total_score == 3 ? "C"
     : "F"

// ============================================================
// SECTION 8: DECISION LOGIC
// ============================================================

min_exec_score = is_reversal
     ? min_grade_input == "A+" ? 8
     : min_grade_input == "A"  ? 7
     : 6
     : min_grade_input == "A+" ? 7
     : min_grade_input == "A"  ? 6
     : 5

decision = total_score >= min_exec_score ? "EXECUTE" :
           grade == "B"                  ? "CAUTION" :
           "PASS"

// ============================================================
// SECTION 9: COLOURS
// ============================================================

col_header_bg = color.new(#020617, 0)
col_panel_bg  = color.new(#0f172a, 0)
col_label_bg  = color.new(#111827, 0)
col_value_bg  = color.new(#1e293b, 0)
col_border    = color.new(#64748b, 5)

col_header_txt = color.new(#f8fafc, 0)
col_label_txt  = color.new(#dbeafe, 0)
col_value_txt  = color.new(#f8fafc, 0)
col_muted_txt  = color.new(#cbd5e1, 0)

col_execute_bg = color.new(#15803d, 0)
col_caution_bg = color.new(#b45309, 0)
col_pass_bg    = color.new(#b91c1c, 0)

col_strong_txt = color.new(#ffffff, 0)

col_check = color.new(#22c55e, 0)
col_cross = color.new(#ef4444, 0)

decision_bg = decision == "EXECUTE" ? col_execute_bg :
              decision == "CAUTION" ? col_caution_bg :
              col_pass_bg

grade_bg = decision_bg

// ============================================================
// SECTION 10: TABLE POSITION AND SIZE
// ============================================================

tbl_position = position_choice == "Top Right"    ? position.top_right :
               position_choice == "Top Left"     ? position.top_left :
               position_choice == "Bottom Right" ? position.bottom_right :
               position.bottom_left

table_rows = compact_mode ? 5 : is_reversal ? 15 : 14

// ============================================================
// SECTION 11: HELPER FUNCTIONS
// ============================================================

f_mark(condition) =>
    condition ? "✓" : "✕"

f_mark_colour(condition) =>
    condition ? col_check : col_cross

f_header_cell(tbl, col_num, row_num, cell_text) =>
    if dashboard_size == "Small"
        table.cell(
             table_id=tbl,
             column=col_num,
             row=row_num,
             text=cell_text,
             text_color=col_header_txt,
             bgcolor=col_header_bg,
             text_size=size.small,
             text_halign=text.align_center)
    else if dashboard_size == "Large"
        table.cell(
             table_id=tbl,
             column=col_num,
             row=row_num,
             text=cell_text,
             text_color=col_header_txt,
             bgcolor=col_header_bg,
             text_size=size.large,
             text_halign=text.align_center)
    else
        table.cell(
             table_id=tbl,
             column=col_num,
             row=row_num,
             text=cell_text,
             text_color=col_header_txt,
             bgcolor=col_header_bg,
             text_size=size.normal,
             text_halign=text.align_center)

f_summary_row(tbl, row_num, label_text, value_text, value_colour, value_bg_colour, is_key_row) =>
    if dashboard_size == "Small"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.small,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=value_text,
             text_color=value_colour,
             bgcolor=value_bg_colour,
             text_size=size.small,
             text_halign=text.align_center)
    else if dashboard_size == "Large"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.large,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=value_text,
             text_color=value_colour,
             bgcolor=value_bg_colour,
             text_size=size.large,
             text_halign=text.align_center)
    else
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.normal,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=value_text,
             text_color=value_colour,
             bgcolor=value_bg_colour,
             text_size=size.normal,
             text_halign=text.align_center)

f_check_row(tbl, row_num, label_text, condition) =>
    if dashboard_size == "Small"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.tiny,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=f_mark(condition),
             text_color=f_mark_colour(condition),
             bgcolor=col_value_bg,
             text_size=size.small,
             text_halign=text.align_center)
    else if dashboard_size == "Large"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.normal,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=f_mark(condition),
             text_color=f_mark_colour(condition),
             bgcolor=col_value_bg,
             text_size=size.large,
             text_halign=text.align_center)
    else
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=label_text,
             text_color=col_label_txt,
             bgcolor=col_label_bg,
             text_size=size.small,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=f_mark(condition),
             text_color=f_mark_colour(condition),
             bgcolor=col_value_bg,
             text_size=size.normal,
             text_halign=text.align_center)

f_section_row(tbl, row_num, left_text, right_text) =>
    if dashboard_size == "Small"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.tiny,
             text_halign=text.align_center)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.tiny,
             text_halign=text.align_center)
    else if dashboard_size == "Large"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.normal,
             text_halign=text.align_center)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.normal,
             text_halign=text.align_center)
    else
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.small,
             text_halign=text.align_center)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_header_txt,
             bgcolor=col_panel_bg,
             text_size=size.small,
             text_halign=text.align_center)

f_footer_row(tbl, row_num, left_text, right_text) =>
    if dashboard_size == "Small"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.tiny,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.tiny,
             text_halign=text.align_center)
    else if dashboard_size == "Large"
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.normal,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.normal,
             text_halign=text.align_center)
    else
        table.cell(
             table_id=tbl,
             column=0,
             row=row_num,
             text=left_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.small,
             text_halign=text.align_left)

        table.cell(
             table_id=tbl,
             column=1,
             row=row_num,
             text=right_text,
             text_color=col_muted_txt,
             bgcolor=col_panel_bg,
             text_size=size.small,
             text_halign=text.align_center)

// ============================================================
// SECTION 12: TABLE CREATION AND REBUILD LOGIC
// ============================================================

var table tqs_table = na
var string last_position_choice = ""
var bool last_compact_mode = false
var string last_setup_type = ""
var bool last_show_dashboard = false
var string last_dashboard_size = ""

needs_rebuild =
     show_dashboard and (
         na(tqs_table) or
         last_position_choice != position_choice or
         last_compact_mode != compact_mode or
         last_setup_type != setup_type or
         last_show_dashboard != show_dashboard or
         last_dashboard_size != dashboard_size
     )

if not show_dashboard and not na(tqs_table)
    table.delete(tqs_table)
    tqs_table := na
    last_show_dashboard := show_dashboard

if needs_rebuild
    if not na(tqs_table)
        table.delete(tqs_table)

    tqs_table := table.new(
         position=tbl_position,
         columns=2,
         rows=table_rows,
         border_color=col_border,
         border_width=1,
         frame_color=col_border,
         frame_width=1)

    last_position_choice := position_choice
    last_compact_mode := compact_mode
    last_setup_type := setup_type
    last_show_dashboard := show_dashboard
    last_dashboard_size := dashboard_size

// ============================================================
// SECTION 13: DASHBOARD DRAWING
// ============================================================

if show_dashboard and not na(tqs_table) and barstate.islast
    // Header
    f_header_cell(tqs_table, 0, 0, "TRADE QUALITY")
    f_header_cell(tqs_table, 1, 0, "SCORECARD")

    // Core summary
    f_summary_row(tqs_table, 1, "Setup", setup_type, col_value_txt, col_value_bg, false)
    f_summary_row(tqs_table, 2, "Score", str.tostring(total_score) + " / " + str.tostring(max_score), col_value_txt, col_value_bg, false)

    // Grade and Decision kept clear, strong, but not oversized
    f_summary_row(tqs_table, 3, "Grade", grade, col_strong_txt, grade_bg, true)
    f_summary_row(tqs_table, 4, "Decision", decision, col_strong_txt, decision_bg, true)

    // Full checklist view only
    if not compact_mode
        f_section_row(tqs_table, 5, "CHECKLIST", "STATUS")

        // Common checklist
        f_check_row(tqs_table, 6,  "HTF Alignment", c1_htf_narrative)
        f_check_row(tqs_table, 7,  "Key Liquidity", c2_key_liquidity)
        f_check_row(tqs_table, 8,  "Session Timing", c3_session_hours)
        f_check_row(tqs_table, 9,  "BE Level", c4_breakeven)
        f_check_row(tqs_table, 10, "DOL 1:2+", c5_clear_r2)
        f_check_row(tqs_table, 11, "No Red Flags", c6_no_red_flags)

        // Setup-specific checklist
        if is_reversal
            f_check_row(tqs_table, 12, "Sweep + V-Reaction", r1_vshape)
            f_check_row(tqs_table, 13, "5m/15m IFVG", r2_ifvg)
            f_footer_row(tqs_table, 14, "Min Execute", min_grade_input)
        else
            f_check_row(tqs_table, 12, "5m/15m Entry FVG", k1_gap)
            f_footer_row(tqs_table, 13, "Min Execute", min_grade_input)

// ============================================================
// SECTION 14: ALERT CONDITIONS
// ============================================================

execute_signal = decision == "EXECUTE"

alertcondition(
     condition=execute_signal,
     title="TQS: EXECUTE Setup",
     message="Trade Quality Scorecard: EXECUTE setup detected. Check the dashboard for Grade and Score.")

alertcondition(
     condition=execute_signal and grade == "A+",
     title="TQS: EXECUTE - Grade A+",
     message="Trade Quality Scorecard: EXECUTE setup detected. Grade: A+.")

alertcondition(
     condition=execute_signal and grade == "A",
     title="TQS: EXECUTE - Grade A",
     message="Trade Quality Scorecard: EXECUTE setup detected. Grade: A.")

alertcondition(
     condition=execute_signal and grade == "B+",
     title="TQS: EXECUTE - Grade B+",
     message="Trade Quality Scorecard: EXECUTE setup detected. Grade: B+.")

alertcondition(
     condition=decision == "CAUTION",
     title="TQS: CAUTION - Grade B",
     message="Trade Quality Scorecard: CAUTION. Grade B. Below execution threshold.")
````
