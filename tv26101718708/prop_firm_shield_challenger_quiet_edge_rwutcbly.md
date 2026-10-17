# Prop Firm Shield - Challenger [Quiet Edge]

- url: https://www.tradingview.com/script/RwUTCBly-Prop-Firm-Shield-Challenger-Quiet-Edge/
- type: indicator
- pine_id: PUB;d7791845012e4da39aa6f05ff2a3bcf2
- version: 1.0

## Description

Your prop firm's rules, enforced at the chart. Prop Firm Shield tracks your daily-loss budget, drawdown buffer, and position size in real time — so the limit is visible the moment you are near it.

This is the Challenger tier — free, no login required. Enter your account size, starting balance, and current balance. The dashboard does the rest.

What it tracks

Daily loss budget — how much you have left, in dollars and percent
Drawdown buffer — remaining room before breach
Position size calculator — enter entry, stop, and risk % to get a recommended lot size
SAFE / CAUTION / STOP status with chart background alert
Upgrade to Operator ($19/mo) for verified firm presets (FTMO, Topstep, The5ers, MyFundedFutures), trailing drawdown, consistency rule tracker, and session close countdown.

Upgrade to Principal ($39/mo) for lot size escalation guard and an Evaluation vs Funded phase toggle — the only on-chart tool that models intraday trailing drawdown for funded accounts.

quietedgelabs.com/indicators/risk-management/prop-firm-shield

## Source Code

````pine
//@version=5
// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
// Prop Firm Shield ‚Äî Challenger
// Risk Management  ¬∑  Quiet Edge Labs  ¬∑  v1.1
// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
// Free tier. Tracks daily-loss budget, static drawdown buffer,
// and position size. No firm presets ‚Äî use Custom and enter your
// firm's exact numbers.
//
// Tier: Challenger ¬∑ Free
// Upgrade to Operator ($19/mo) for firm presets, trailing
// drawdown, consistency tracker, and session close countdown.
// Upgrade to Principal ($39/mo) for lot size guard and
// evaluation vs funded phase toggle.
//
// quietedgelabs.com/indicators/risk-management/prop-firm-shield
// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ

indicator("Prop Firm Shield ‚Äî Challenger [Quiet Edge]", shorttitle="PF Shield ¬∑ Challenger", overlay=true, max_lines_count=3, max_labels_count=3)

// ‚îÄ Brand palette ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
var color C_ACCENT = #0a84ff
var color C_OK     = #1f8a5b
var color C_WARN   = #c98a05
var color C_DANGER = #d4351c
var color C_INK    = #1d1d1f
var color C_MUTED  = #f3f1ec
var color C_WHITE  = color.new(#ffffff, 0)

// ‚îÄ Input groups ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
string GRP_ACCT = "Account Settings"
string GRP_RISK = "Risk Parameters"
string GRP_CALC = "Position Calculator"
string GRP_DISP = "Display"

// ‚îÄ Inputs ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
i_accountSize     = input.float(100000, "Account Size ($)",              minval=1000,  step=1000,  group=GRP_ACCT)
i_startBalance    = input.float(100000, "Today's Starting Balance ($)",  minval=1000,  step=1000,  group=GRP_ACCT)
i_currentBalance  = input.float(100000, "Current Balance ($)",           minval=0,     step=100,   group=GRP_ACCT, tooltip="Update during the session to track live P&L")

i_maxDailyLossPct = input.float(5.0,   "Max Daily Loss %",   minval=0.0, maxval=20,  step=0.5, group=GRP_RISK, tooltip="Set 0 for no daily loss limit")
i_maxDrawdownPct  = input.float(10.0,  "Max Total Drawdown %", minval=1, maxval=30,  step=0.5, group=GRP_RISK)
i_maxLots         = input.float(10.0,  "Max Position Size (lots)", minval=0.01, maxval=500, step=0.5, group=GRP_RISK)
i_warnLevel       = input.float(80.0,  "Danger Threshold %", minval=50, maxval=95,   step=5,   group=GRP_RISK, tooltip="% of limit that triggers STOP TRADING")
i_cautionLevel    = input.float(50.0,  "Caution Threshold %", minval=20, maxval=80,  step=5,   group=GRP_RISK)

i_entryPrice      = input.float(0.0,   "Entry Price",         minval=0,  step=0.01,  group=GRP_CALC, tooltip="0 = use current close")
i_stopLoss        = input.float(0.0,   "Stop Loss Price",     minval=0,  step=0.01,  group=GRP_CALC)
i_riskPerTrade    = input.float(1.0,   "Risk Per Trade %",    minval=0.1, maxval=5,  step=0.1, group=GRP_CALC)
i_pipValue        = input.float(10.0,  "Pip Value ($) per Lot", minval=0.01, step=0.1, group=GRP_CALC, tooltip="Forex major = $10, mini = $1")

i_showTable       = input.bool(true,   "Show Dashboard",      group=GRP_DISP)
i_tablePos        = input.string("Top Right", "Position",     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_DISP)

// ‚îÄ Calculations ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
dailyPnL         = i_currentBalance - i_startBalance
dailyPnLPct      = (dailyPnL / i_startBalance) * 100

totalDrawdown    = i_accountSize - i_currentBalance
totalDrawdownPct = (totalDrawdown / i_accountSize) * 100

hasDLL           = i_maxDailyLossPct > 0
maxDailyLossAmt  = i_accountSize * (i_maxDailyLossPct / 100)
dailyLossUsed    = dailyPnL < 0 ? math.abs(dailyPnL) : 0.0
dailyLossUsedPct = hasDLL ? (dailyLossUsed / maxDailyLossAmt) * 100 : 0.0
remainDailyBuf   = maxDailyLossAmt - dailyLossUsed

maxDrawdownAmt   = i_accountSize * (i_maxDrawdownPct / 100)
remainDDBuf      = maxDrawdownAmt - math.max(totalDrawdown, 0)

// Position size
calcEntry  = i_entryPrice > 0 ? i_entryPrice : close
slDistance = math.abs(calcEntry - i_stopLoss)
riskAmount = i_accountSize * (i_riskPerTrade / 100)
calcLots   = slDistance > 0 and i_pipValue > 0 ? riskAmount / (slDistance / syminfo.mintick * i_pipValue / 10) : 0.0
adjLots    = math.min(calcLots, i_maxLots)
adjLots2   = math.max(math.round(adjLots * 100) / 100, 0.01)
lotsCapped = calcLots > i_maxLots

// Status
dailyStatus    = not hasDLL ? "N/A" : dailyLossUsedPct >= i_warnLevel ? "STOP TRADING" : dailyLossUsedPct >= i_cautionLevel ? "CAUTION" : "SAFE"
dailyStatusClr = not hasDLL ? C_INK : dailyLossUsedPct >= i_warnLevel ? C_DANGER : dailyLossUsedPct >= i_cautionLevel ? C_WARN : C_OK

ddUsedPct    = totalDrawdownPct > 0 ? (totalDrawdownPct / i_maxDrawdownPct) * 100 : 0
ddStatus     = ddUsedPct >= i_warnLevel ? "CRITICAL" : ddUsedPct >= i_cautionLevel ? "WARNING" : "HEALTHY"
ddStatusClr  = ddUsedPct >= i_warnLevel ? C_DANGER : ddUsedPct >= i_cautionLevel ? C_WARN : C_OK

overallDanger = math.max(dailyLossUsedPct, ddUsedPct)
overallStatus = overallDanger >= i_warnLevel ? "STOP" : overallDanger >= i_cautionLevel ? "CAUTION" : "CLEAR"
overallClr    = overallDanger >= i_warnLevel ? C_DANGER : overallDanger >= i_cautionLevel ? C_WARN : C_OK

// ‚îÄ Table ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
f_tablePos() =>
    switch i_tablePos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

if i_showTable and barstate.islast
    var table dash = table.new(f_tablePos(), 3, 13,
         bgcolor=C_MUTED, border_width=1, border_color=C_ACCENT,
         frame_width=2, frame_color=C_ACCENT)

    table.cell(dash, 0, 0, "Quiet Edge Labs", text_color=C_ACCENT, text_size=size.small, bgcolor=C_MUTED)
    table.merge_cells(dash, 0, 0, 2, 0)

    table.cell(dash, 0, 1, "PROP FIRM SHIELD", text_color=C_INK,    text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 1, "CHALLENGER",        text_color=C_ACCENT, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 1, overallStatus,        text_color=overallClr, text_size=size.normal, bgcolor=C_MUTED)

    table.cell(dash, 0, 2, "  ACCOUNT", text_color=C_INK, text_size=size.tiny, bgcolor=C_MUTED)
    table.merge_cells(dash, 0, 2, 2, 2)

    pnlSign = dailyPnL >= 0 ? "+" : ""
    table.cell(dash, 0, 3, "Today P&L",      text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 3, pnlSign + "$" + str.tostring(dailyPnL, "#,###.##"),
         text_color=dailyPnL >= 0 ? C_OK : C_DANGER, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 3, pnlSign + str.tostring(dailyPnLPct, "#.##") + "%",
         text_color=dailyPnL >= 0 ? C_OK : C_DANGER, text_size=size.small, bgcolor=C_MUTED)

    table.cell(dash, 0, 4, "Daily Loss Budget", text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 4, hasDLL ? "$" + str.tostring(remainDailyBuf, "#,###") + " left" : "No DLL",
         text_color=dailyStatusClr, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 4, dailyStatus, text_color=dailyStatusClr, text_size=size.small, bgcolor=C_MUTED)

    table.cell(dash, 0, 5, "  DRAWDOWN", text_color=C_INK, text_size=size.tiny, bgcolor=C_MUTED)
    table.merge_cells(dash, 0, 5, 2, 5)

    table.cell(dash, 0, 6, "DD Buffer",   text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 6, "$" + str.tostring(remainDDBuf, "#,###") + " left",
         text_color=ddStatusClr, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 6, ddStatus, text_color=ddStatusClr, text_size=size.small, bgcolor=C_MUTED)

    table.cell(dash, 0, 7, "Max DD",      text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 7, str.tostring(i_maxDrawdownPct, "#.#") + "% = $" + str.tostring(maxDrawdownAmt, "#,###"),
         text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 7, "static", text_color=C_INK, text_size=size.tiny, bgcolor=C_MUTED)

    table.cell(dash, 0, 8, "  POSITION CALC", text_color=C_INK, text_size=size.tiny, bgcolor=C_MUTED)
    table.merge_cells(dash, 0, 8, 2, 8)

    posText = i_stopLoss > 0 ? str.tostring(adjLots2, "#.##") + " lots" : "Set SL to calc"
    capNote = lotsCapped and i_stopLoss > 0 ? " CAPPED" : ""
    table.cell(dash, 0, 9, "Recommended Size", text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 9, posText + capNote,  text_color=lotsCapped ? C_WARN : C_OK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 9, "Risk " + str.tostring(i_riskPerTrade, "#.#") + "%",
         text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)

    table.cell(dash, 0, 10, "Account Size",    text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 10, "$" + str.tostring(i_accountSize, "#,###"), text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 10, "", text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)

    table.cell(dash, 0, 11, "Current Balance", text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 1, 11, "$" + str.tostring(i_currentBalance, "#,###"), text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)
    table.cell(dash, 2, 11, "", text_color=C_INK, text_size=size.small, bgcolor=C_MUTED)

    // Upgrade prompt
    table.cell(dash, 0, 12, "Upgrade to Operator for firm presets", text_color=C_ACCENT, text_size=size.tiny, bgcolor=C_MUTED)
    table.merge_cells(dash, 0, 12, 2, 12)

// ‚îÄ Chart overlays ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
bgcolor(overallDanger >= i_warnLevel ? color.new(C_DANGER, 92) : na, title="STOP TRADING Warning BG")

if barstate.islast and overallDanger >= i_warnLevel
    label.new(bar_index + 3, high, "STOP TRADING",
         style=label.style_label_left, color=C_DANGER, textcolor=C_WHITE, size=size.large)

// ‚îÄ Alerts ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
alertcondition(dailyLossUsedPct >= i_warnLevel,
     title="STOP TRADING ‚Äî Daily Loss", message="Prop Firm Shield: STOP TRADING ‚Äî daily loss warning level reached!")
alertcondition(ddUsedPct >= i_warnLevel,
     title="Drawdown Critical", message="Prop Firm Shield: CRITICAL ‚Äî total drawdown approaching maximum!")

// ‚îÄ Status line ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
plot(dailyPnL,         "Daily P&L ($)",      color=dailyPnL >= 0 ? C_OK : C_DANGER, display=display.status_line + display.data_window)
plot(dailyLossUsedPct, "Daily Limit Used %", color=dailyStatusClr,                  display=display.status_line + display.data_window)
````
