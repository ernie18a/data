# TGW Risk Calculator INDEX FUTRES

- url: https://www.tradingview.com/script/sGOKxmOm-TGW-Risk-Calculator-INDEX-FUTRES/
- type: indicator
- pine_id: PUB;787d3bdd6b4e4dc789082bfa55ae1943
- version: 1.0

## Description

TGW RISK CALCULATOR 







I know many sturggle with calculating the risk while traidng chart.

especially futures contract.

## Source Code

````pine
//@version=5
indicator("TGW Risk Calculator INDEX [PRO]", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// ==================== MASTER TOGGLES =================================
// =====================================================================
show_risk_calc = input.bool(true, "Turn ON Risk Calculator Tool", group="MASTER TOGGLES", tooltip="Master switch for the entire Risk Tool", display=display.none)

// =====================================================================
// ==================== RISK CALCULATOR SETTINGS =======================
// =====================================================================
grp_acc  = "Risk Tool: 1. Account & Risk"
acc_size = input.float(100000, "Account Balance ($)", group=grp_acc, display=display.none)
risk_typ = input.string("Percentage (%)", "Risk Input Type", options=["Percentage (%)", "Fixed Dollar Amount ($)"], group=grp_acc, display=display.none)
risk_val = input.float(1.0, "Risk Value", step=0.1, tooltip="Enter % (e.g., 1.0) or Amount (e.g., 500)", group=grp_acc, display=display.none)
pt_opt   = input.string("NQ ($20)", "Instrument Multiplier", options=["NQ ($20)", "MNQ ($2)", "ES ($50)", "Custom"], group=grp_acc, display=display.none)
pt_cust  = input.float(20.0, "Custom Multiplier ($)", tooltip="Only used if 'Custom' is selected above", group=grp_acc, display=display.none)

grp_trade  = "Risk Tool: 2. Measurement"
sl_method  = input.string("Enter Points Directly", "Stop Loss Method", options=["Enter Points Directly", "Measure by Prices"], group=grp_trade, display=display.none)
custom_pts = input.float(15.0, "Custom SL Points", step=0.5, tooltip="Type your exact Stop Loss points here", group=grp_trade, display=display.none)
trade_dir  = input.string("Long", "Direction", options=["Long", "Short"], group=grp_trade, display=display.none)
anchor_p   = input.float(0.0, "Anchor Price (Entry)", tooltip="Leave 0 to use current price", group=grp_trade, display=display.none)
target_p   = input.float(0.0, "Target Price (Stop Loss)", tooltip="Used only if 'Measure by Prices' is selected", group=grp_trade, display=display.none)

grp_vis         = "Risk Tool: 3. Visuals"
show_risk_tbl   = input.bool(true, "Show Risk Table Display", group=grp_vis, tooltip="Toggle to hide just the table but keep the lines", display=display.none)
risk_show_lines = input.bool(true, "Show Measurement Lines on Chart", group=grp_vis, tooltip="Toggle to hide just the lines but keep the table", display=display.none)
line_offset     = input.int(15, "Line Placement (Shift Right)", minval=0, maxval=100, group=grp_vis, display=display.none)
table_pos       = input.string("Bottom Right", "Table Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=grp_vis, display=display.none)

// --- Internal Helpers ---
get_tbl_pos(p) => p == "Top Right" ? position.top_right : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_left

// =====================================================================
// ==================== WATERMARK ENGINE (HARDCODED) ===================
// =====================================================================
// Configured internally to keep the settings menu clean
var table wm_tbl = table.new(position.middle_center, 1, 1, bgcolor=color.new(color.white, 100), frame_width=0, border_width=0)

if barstate.islast
    table.cell(wm_tbl, 0, 0, "𝗧𝗚𝗪 𝗢𝗙𝗙𝗜𝗖𝗜𝗔𝗟", text_color=color.new(#434651, 80), text_size=size.huge, text_halign=text.align_center, text_valign=text.align_center)

// =====================================================================
// ==================== RISK CALCULATOR ENGINE =========================
// =====================================================================

// Risk Math
float risk_pt_val = pt_opt == "NQ ($20)" ? 20.0 : pt_opt == "MNQ ($2)" ? 2.0 : pt_opt == "ES ($50)" ? 50.0 : pt_cust
float risk_amt = risk_typ == "Percentage (%)" ? acc_size * (risk_val / 100) : risk_val

float actual_anchor = anchor_p == 0 ? close : anchor_p
float actual_target = 0.0
float sl_dist       = 0.0

if sl_method == "Enter Points Directly"
    sl_dist := custom_pts
    actual_target := trade_dir == "Long" ? actual_anchor - custom_pts : actual_anchor + custom_pts
else
    actual_target := target_p == 0 ? (trade_dir == "Long" ? actual_anchor - 10 : actual_anchor + 10) : target_p
    sl_dist := math.abs(actual_anchor - actual_target)

float pos_size = sl_dist == 0 ? 0 : risk_amt / (sl_dist * risk_pt_val)

var line l_anchor = na
var label lbl_anchor = na
var line l_target = na
var label lbl_target = na
var line l_meas = na
var label lbl_meas = na

if barstate.islast 
    if show_risk_calc
        if show_risk_tbl
            table risk_tbl = table.new(get_tbl_pos(table_pos), 2, 5, bgcolor=color.new(#1e222d, 10), border_width=1, border_color=color.new(#434651, 50))
            table.cell(risk_tbl, 0, 0, "ACCOUNT SIZE", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
            table.cell(risk_tbl, 1, 0, "$" + str.tostring(acc_size, "#,###"), text_color=color.white, text_size=size.normal, text_halign=text.align_right)
            
            string risk_lbl = risk_typ == "Percentage (%)" ? "RISK AMT (" + str.tostring(risk_val) + "%)" : "RISK AMT (Fixed)"
            table.cell(risk_tbl, 0, 1, risk_lbl, text_color=color.gray, text_size=size.small, text_halign=text.align_left)
            table.cell(risk_tbl, 1, 1, "-$" + str.tostring(risk_amt, "#,###.##"), text_color=color.red, text_size=size.normal, text_halign=text.align_right)
            
            table.cell(risk_tbl, 0, 2, "STOP DISTANCE", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
            table.cell(risk_tbl, 1, 2, str.tostring(sl_dist, "#.##") + " pts", text_color=color.white, text_size=size.normal, text_halign=text.align_right)
            
            table.cell(risk_tbl, 0, 3, "MULTIPLIER", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
            table.cell(risk_tbl, 1, 3, "$" + str.tostring(risk_pt_val) + "/pt", text_color=color.silver, text_size=size.normal, text_halign=text.align_right)
            
            table.cell(risk_tbl, 0, 4, "POSITION SIZE", text_color=color.white, text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(color.blue, 80))
            table.cell(risk_tbl, 1, 4, str.tostring(pos_size, "#.##") + " Cont", text_color=color.white, text_size=size.large, text_halign=text.align_right, bgcolor=color.new(color.blue, 80))

        if risk_show_lines
            line.delete(l_anchor)
            label.delete(lbl_anchor)
            line.delete(l_target)
            label.delete(lbl_target)
            line.delete(l_meas)
            label.delete(lbl_meas)
            
            int start_idx = bar_index + line_offset
            int end_idx   = start_idx + 15
            
            l_anchor := line.new(start_idx, actual_anchor, end_idx, actual_anchor, color=color.gray, style=line.style_solid, width=2)
            lbl_anchor := label.new(end_idx, actual_anchor, "ANCHOR", color=color.new(color.gray, 100), textcolor=color.gray, style=label.style_label_left, size=size.small)
            
            l_target := line.new(start_idx, actual_target, end_idx, actual_target, color=color.red, style=line.style_dashed, width=2)
            lbl_target := label.new(end_idx, actual_target, "SL", color=color.new(color.red, 100), textcolor=color.red, style=label.style_label_left, size=size.small)
            
            int mid_idx = start_idx + 7
            l_meas := line.new(mid_idx, actual_anchor, mid_idx, actual_target, color=color.orange, style=line.style_dotted, width=2)
            
            float risk_mid_price = (actual_anchor + actual_target) / 2
            lbl_meas := label.new(mid_idx, risk_mid_price, str.tostring(sl_dist, "#.##") + " pts", color=color.new(color.orange, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
        else
            line.delete(l_anchor)
            label.delete(lbl_anchor)
            line.delete(l_target)
            label.delete(lbl_target)
            line.delete(l_meas)
            label.delete(lbl_meas)
    else
        line.delete(l_anchor)
        label.delete(lbl_anchor)
        line.delete(l_target)
        label.delete(lbl_target)
        line.delete(l_meas)
        label.delete(lbl_meas)
````
