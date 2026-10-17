# MohdTZ Trade Journal Dashboard

- url: https://www.tradingview.com/script/MAAkk1Jg-MohdTZ-Trade-Journal-Dashboard/
- type: indicator
- pine_id: PUB;bdcb244f9c764aa1a7fa84d8b1614283
- version: 1.0

## Description

এটা আপনার Pine Script (trade_journal_indicator.pine)।

এটি একটি TradingView Trade Journal Dashboard Indicator — চার্টের উপর একটি dashboard/table দেখায় যেখানে:

Trade Counts
Total trades
Win
Loss
Breakeven
Running trades
Money Management
Starting balance
Risk per trade
Risk:Reward ratio
Auto Calculations
Win rate %
Loss rate %
Breakeven %
Gross profit
Gross loss
Net P&L
Current balance
ROI %
Expectancy per trade (EV)
Customizable UI
Table position (Top/Bottom/Center)
Text size
Background opacity
Show/hide percentage
Show/hide money section
Show/hide breakeven row

সমস্যা/নোট:

## Source Code

````pine
// ============================================================
//  TRADE JOURNAL — Win/Loss/BE Stats + P&L Dashboard
//  by Claude (for Mohd) | Pine Script v5
//  Copy → TradingView Pine Editor → Add to Chart
// ============================================================
//@version=5
indicator("📊 Trade Journal Dashboard", overlay=true, max_labels_count=0)

// ─────────────────────────────────────────────
// ░░  GROUP 1 — TRADE COUNTS
// ─────────────────────────────────────────────
grp1 = "📋 Trade Counts"
i_total     = input.int(31,  "Total Trades",     minval=0, group=grp1)
i_win       = input.int(10,  "Wins  ✅",          minval=0, group=grp1)
i_loss      = input.int(15,  "Losses ❌",         minval=0, group=grp1)
i_be        = input.int(4,   "Breakeven ➖",      minval=0, group=grp1)
i_running   = input.int(2,   "Running 🔄",        minval=0, group=grp1)

// ─────────────────────────────────────────────
// ░░  GROUP 2 — MONEY MANAGEMENT
// ─────────────────────────────────────────────
grp2 = "💰 Money Management"
i_balance   = input.float(10000.0, "Starting Balance ($)", minval=1,    step=100,  group=grp2)
i_risk_usd  = input.float(100.0,   "Risk Per Trade ($)",   minval=0.01, step=10,   group=grp2)
i_rr        = input.float(2.0,     "Risk:Reward Ratio",    minval=0.1,  step=0.1,  group=grp2,
                           tooltip="e.g. 2.0 means for every $1 risk you target $2 reward")

// ─────────────────────────────────────────────
// ░░  GROUP 3 — TABLE POSITION & STYLE
// ─────────────────────────────────────────────
grp3 = "🎨 Table Appearance"
pos_choice  = input.string("Top Right", "Table Position",
              options=["Top Left","Top Center","Top Right",
                       "Middle Left","Middle Center","Middle Right",
                       "Bottom Left","Bottom Center","Bottom Right"],
              group=grp3)

i_textSize  = input.string("Normal", "Text Size",
              options=["Tiny","Small","Normal","Large","Huge"], group=grp3)

i_opacity   = input.int(90, "Background Opacity %", minval=0, maxval=100, group=grp3)
i_showPct   = input.bool(true,  "Show Percentages", group=grp3)
i_showMoney = input.bool(true,  "Show P&L in ($)",  group=grp3)
i_showBE    = input.bool(true,  "Show Breakeven Row", group=grp3)

// ─────────────────────────────────────────────
// ░░ CALCULATIONS
// ─────────────────────────────────────────────
closed      = math.max(i_total - i_running, 0)

win_pct     = closed > 0 ? (i_win  / closed) * 100 : 0.0
loss_pct    = closed > 0 ? (i_loss / closed) * 100 : 0.0
be_pct      = closed > 0 ? (i_be   / closed) * 100 : 0.0

gross_profit  = i_win  * (i_risk_usd * i_rr)
gross_loss    = i_loss * i_risk_usd
net_pnl       = gross_profit - gross_loss
current_bal   = i_balance + net_pnl
roi_pct       = (net_pnl / i_balance) * 100
exp_val       = (win_pct/100 * i_risk_usd * i_rr) - (loss_pct/100 * i_risk_usd)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
f_pos() =>
    switch pos_choice
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_size() =>
    switch i_textSize
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

f_money(v) =>
    prefix = v >= 0 ? "+ $" : "- $"
    prefix + str.tostring(math.abs(v), "#,##0.00")

f_pct(v) =>
    str.tostring(v, "0.00") + "%"

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
C_BG      = color.new(color.rgb(18,18,28), i_opacity)
C_HEADER  = color.new(color.rgb(88,24,69), i_opacity)
C_WIN     = color.new(color.rgb(0,200,120), 0)
C_LOSS    = color.new(color.rgb(220,50,80), 0)
C_BE      = color.new(color.rgb(160,160,160), 0)
C_RUNNING = color.new(color.rgb(80,180,255), 0)
C_NEUTRAL = color.new(color.rgb(220,220,240), 0)
C_GOLD    = color.new(color.rgb(255,200,50), 0)
C_ROW_ALT = color.new(color.rgb(28,28,42), i_opacity)

// ─────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────
var table tbl = na

if barstate.islast

    if not na(tbl)
        table.delete(tbl)

    extra_rows = (i_showBE ? 1 : 0) + (i_showMoney ? 3 : 0)

    tbl := table.new(
         f_pos(),
         3,
         12 + extra_rows,
         bgcolor=C_BG,
         border_color=color.rgb(80,80,120),
         border_width=1,
         frame_color=color.rgb(120,80,180),
         frame_width=2)

    sz = f_size()

    table.cell(tbl,0,0,"📊 TRADE JOURNAL",
         text_color=C_GOLD,text_size=sz,bgcolor=C_HEADER,
         text_halign=text.align_center)

    table.merge_cells(tbl,0,0,2,0)

    table.cell(tbl,0,1,"METRIC",text_color=C_NEUTRAL,text_size=sz,bgcolor=C_HEADER)
    table.cell(tbl,1,1,"COUNT",text_color=C_NEUTRAL,text_size=sz,bgcolor=C_HEADER)
    table.cell(tbl,2,1,i_showPct ? "%" : "VALUE",
         text_color=C_NEUTRAL,text_size=sz,bgcolor=C_HEADER)

    table.cell(tbl,0,2,"TOTAL")
    table.cell(tbl,1,2,str.tostring(i_total))
    table.cell(tbl,2,2,"All")

    table.cell(tbl,0,3,"✅ WIN",text_color=C_WIN,bgcolor=C_ROW_ALT)
    table.cell(tbl,1,3,str.tostring(i_win),text_color=C_WIN,bgcolor=C_ROW_ALT)
    table.cell(tbl,2,3,i_showPct ? f_pct(win_pct) : "—",text_color=C_WIN,bgcolor=C_ROW_ALT)

    table.cell(tbl,0,4,"❌ LOSS",text_color=C_LOSS)
    table.cell(tbl,1,4,str.tostring(i_loss),text_color=C_LOSS)
    table.cell(tbl,2,4,i_showPct ? f_pct(loss_pct) : "—",text_color=C_LOSS)

    cur_row = 5

    if i_showBE
        table.cell(tbl,0,cur_row,"➖ BE",text_color=C_BE,bgcolor=C_ROW_ALT)
        table.cell(tbl,1,cur_row,str.tostring(i_be),text_color=C_BE,bgcolor=C_ROW_ALT)
        table.cell(tbl,2,cur_row,i_showPct ? f_pct(be_pct) : "—",text_color=C_BE,bgcolor=C_ROW_ALT)
        cur_row += 1

    table.cell(tbl,0,cur_row,"🔄 RUNNING",text_color=C_RUNNING)
    table.cell(tbl,1,cur_row,str.tostring(i_running),text_color=C_RUNNING)
    table.cell(tbl,2,cur_row,"Live",text_color=C_RUNNING)
    cur_row += 1

    if i_showMoney
        table.cell(tbl,0,cur_row,"💹 Gross Profit",text_color=C_WIN)
        table.cell(tbl,1,cur_row,f_money(gross_profit),text_color=C_WIN)
        table.merge_cells(tbl,1,cur_row,2,cur_row)
        cur_row += 1

        table.cell(tbl,0,cur_row,"📉 Gross Loss",text_color=C_LOSS)
        table.cell(tbl,1,cur_row,f_money(-gross_loss),text_color=C_LOSS)
        table.merge_cells(tbl,1,cur_row,2,cur_row)
        cur_row += 1

        net_col = net_pnl >= 0 ? C_WIN : C_LOSS
        table.cell(tbl,0,cur_row,"⚡ Net P&L",text_color=net_col)
        table.cell(tbl,1,cur_row,f_money(net_pnl),text_color=net_col)
        table.merge_cells(tbl,1,cur_row,2,cur_row)
        cur_row += 1

    bal_col = current_bal >= i_balance ? C_WIN : C_LOSS
    table.cell(tbl,0,cur_row,"🏦 Balance",text_color=C_GOLD)
    table.cell(tbl,1,cur_row,"$ " + str.tostring(current_bal,"#,##0.00"),text_color=bal_col)
    table.merge_cells(tbl,1,cur_row,2,cur_row)
    cur_row += 1

    roi_col = roi_pct >= 0 ? C_WIN : C_LOSS
    roi_str = (roi_pct >= 0 ? "▲ +" : "▼ ") + str.tostring(roi_pct,"0.00") + "%"

    table.cell(tbl,0,cur_row,"📈 ROI",text_color=C_GOLD)
    table.cell(tbl,1,cur_row,roi_str,text_color=roi_col)
    table.merge_cells(tbl,1,cur_row,2,cur_row)
    cur_row += 1

    ev_col = exp_val >= 0 ? C_WIN : C_LOSS
    table.cell(tbl,0,cur_row,"🎯 EV/Trade")
    table.cell(tbl,1,cur_row,f_money(exp_val),text_color=ev_col)
    table.merge_cells(tbl,1,cur_row,2,cur_row)
````
