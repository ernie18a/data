# Strong Risk Management | ProjectSyndicate

- url: https://www.tradingview.com/script/GInEibfZ-Strong-Risk-Management-ProjectSyndicate/
- type: indicator
- pine_id: PUB;99a088d7f93642408f2fc721cc35e2c5
- version: 2.0

## Description

[b]Strong Risk Management turns trade planning into an institutional-grade pre-trade cockpit. Click your Entry, Stop, and three Take-Profit levels straight onto the chart and the tool instantly sizes the position, derives your leverage and margin, estimates the liquidation price, scores the setup, and stress-tests it against your prop-firm rules — all on two clean Bloomberg-amber panels. Every figure is computed live from your own inputs and the symbol's real tick size, not hard-coded, so the numbers describe the exact trade you are about to take, right now.[/b]

🎯 Click-to-Place Interactive Levels — drop Entry, Stop Loss, and TP1 / TP2 / TP3 directly on the chart and drag them whenever you want, just like native drawing tools. An anchor-time input lets you pin the setup to a specific bar, direction (Long / Short) is auto-detected from where your stop sits, and every level you place is always respected — the auto R-multiples only fill in the targets you leave blank.

🧮 Fee-Aware Position Sizing — the engine uses the classic fixed-fractional model and sizes the position so a full stop-out equals exactly the risk you defined, with entry and exit fees folded into the math. Choose your risk as a percentage of balance, a percentage of allocated trade capital, or a fixed cash amount, and read the precise contracts/size and notional position value it produces.

⚡ Three Leverage Modes + Liquidation Engine — run Isolated Capital (leverage derived from the margin you commit), Fixed Leverage (you set the multiplier), or Auto-Safe Leverage, which automatically picks the highest leverage that still keeps your liquidation price safely beyond your stop by a configurable buffer. The panel shows effective trade leverage, account leverage, maintenance margin rate and amount, the estimated liquidation price, and how many times further it sits than your stop — with a loud warning if liquidation would ever come before your stop is hit.

📊 Dual Bloomberg-Amber Panels — Panel 1 (Risk Console) lays out balance, trade capital, risk model, max loss, the full setup (entry, stop, stop distance, break-even, size, position value), the leverage and liquidation block, and the setup-quality verdict. Panel 2 (Prop Guardrails + Take-Profit Plan) handles the funded-account rule checks and the full target ladder. Position each panel independently anywhere on the chart.

🛡️ Prop-Firm Guardrails — purpose-built for funded and challenge traders. Set your account size, phase (Challenge / Verification / Funded), daily loss limit, maximum drawdown (with a trailing option), profit target, per-trade risk cap, and consistency rule, then see this trade scored against every one of them with SAFE / CAUTION / VIOLATION lights and an overall status. It also tells you how many trades like this you can take before breaching your daily and max-drawdown budgets, how much budget is left, and how many wins remain to the profit target.

🎚️ Take-Profit Ladder with FULL / SLICE — each target shows its price, R multiple, and allocation %, plus the dollars it books two ways: FULL (if you closed the whole position there) next to SLICE (what your partial allocation actually books). The plan rolls up into a Plan Profit row with blended R and ROI on margin, so partial exits never look inconsistent against a full-size stop again.

↔️ Reward : Risk Verdict — a single, color-coded 1 : x line grades the whole plan EXCELLENT / GOOD / MARGINAL / POOR, so a setup whose targets sit inside the stop distance screams at you instead of hiding inside an average. A companion "1R Value (full, net)" read exposes the fee drag by showing what one clean R is actually worth in cash after costs.

★ 0–10 Setup Quality Score — a composite grade blending reward-to-risk quality, risk-per-trade discipline, liquidation safety, and prop-rule headroom into one number and an ELITE / STRONG / FAIR / WEAK tier, for a fast go/no-go read before you commit.

🟢 Risk-Free-After-TP1 Read — shows exactly what closing your first partial locks in, and confirms that trailing your stop to break-even afterwards takes the remaining downside to near zero — the de-risking move spelled out in dollars.

🖥️ On-Chart Trade Map — the full trade is drawn as banded zones (profit, loss, a liquidation-danger band, and a runner zone beyond TP3), precise level lines for entry, stop, every target, break-even, and liquidation, and right-edge labels carrying each level's price, R multiple, and cash value at a glance.

🔴 Honest Live Trade Tracker — once price reaches your entry, the tool tracks floating P&L and then prints a clear ✓ TARGET HIT or ✘ STOPPED OUT outcome. Losers are never hidden, and same-bar ambiguity is always resolved pessimistically to the stop, so the read stays truthful.

🔔 Native Alerts — fire on entry triggered, target hit, stopped out, and any prop-firm guardrail violation, so you can wire the cockpit straight into your workflow.

🧩 Fully Customizable — choose each panel's position (Top / Middle / Bottom paired with Left / Right) and text size, pick your quote-currency symbol, set entry and exit fees, the maintenance-margin rate and liquidation safety factor, your R multiples and allocation split, auto-vs-manual targets, and toggle the chart zones, liquidation line, break-even line, and live tracker — all from the settings menu, no code editing required.

🎯 Why this is different — most position-size calculators hand you a lot size and stop there. This is a complete pre-trade cockpit: it sizes the trade, derives leverage and margin, estimates liquidation, scores the setup, grades the reward-to-risk honestly with fees included, and checks the whole thing against your funded-account rules — two panels that answer "how big, how safe, and is this even worth taking?" before you click buy or sell.

🚀 Where to use it — works on any symbol and timeframe. Built with crypto perpetuals, futures, and margin/leverage trading in mind, but equally useful for forex and stocks: plan the trade, validate the sizing and prop-rule headroom, then execute with the levels already mapped on your chart.

⚠️ Important — this is a research and decision-support tool, not a buy/sell system, and it makes no performance guarantees. Liquidation price, fees, maintenance margin, and leverage figures are simplified estimates and can differ from your specific broker or exchange — always verify against their exact contract specifications before sizing a live position. Nothing here is financial advice. Pair it with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Strong Risk Management", shorttitle="STRONG RISK", overlay=true,
     max_lines_count=120, max_labels_count=120, max_boxes_count=120, max_bars_back=5000)

gA = "① ACCOUNT & RISK"
i_balance   = input.float(10000, "Account Balance", group=gA, minval=0, step=100, tooltip="Total account equity.")
i_curSel    = input.string("$ USD", "Quote Currency", options=["$ USD","€ EUR","£ GBP","¥ JPY","₮ USDT","₿ BTC","Ξ ETH"], group=gA)
i_riskMode  = input.string("% of Balance", "Risk Model", options=["% of Balance","% of Trade Capital","Fixed Amount"], group=gA, tooltip="How the maximum loss per trade is defined.")
i_riskPct   = input.float(1.0, "Risk %", group=gA, minval=0.01, step=0.1, tooltip="Used when Risk Model is a percentage.")
i_riskFixed = input.float(100, "Fixed Risk Amount", group=gA, minval=0, step=10, tooltip="Used when Risk Model = Fixed Amount.")
i_tradeCap  = input.float(1000, "Trade Capital Allocated (Margin)", group=gA, minval=0, step=50, tooltip="Capital (isolated margin) you commit to this single trade.")

gL = "② TRADE LEVELS  (click to place)"
i_dirMode   = input.string("Auto", "Direction", options=["Auto","Long","Short"], group=gL, tooltip="Auto infers Long if Stop is below Entry, Short if above.")
i_anchor    = input.time(timestamp("01 Jan 2020 00:00"), "◷ Anchor Time", confirm=true, group=gL, tooltip="Click the chart bar where the setup begins.")
i_entry     = input.price(0.0, "⌖ Entry Price", confirm=true, group=gL, tooltip="Click to set the entry.")
i_stop      = input.price(0.0, "⛔ Stop Loss", confirm=true, group=gL, tooltip="Click to set the stop loss.")
i_autoTP    = input.bool(true, "Auto Take-Profits from R multiples", group=gL, tooltip="If on (or a TP is left at 0), TP prices are derived from the R multiples below.")
i_tp1       = input.price(0.0, "TP1 Price (0 = auto)", confirm=true, group=gL)
i_tp2       = input.price(0.0, "TP2 Price (0 = auto)", confirm=true, group=gL)
i_tp3       = input.price(0.0, "TP3 Price (0 = auto)", confirm=true, group=gL)

gT = "③ TAKE-PROFIT PLAN"
i_r1   = input.float(1.0, "TP1 R multiple", group=gT, minval=0.1, step=0.1, inline="r1")
i_a1   = input.float(50,  "alloc %",        group=gT, minval=0, maxval=100, step=5, inline="r1")
i_r2   = input.float(2.0, "TP2 R multiple", group=gT, minval=0.1, step=0.1, inline="r2")
i_a2   = input.float(30,  "alloc %",        group=gT, minval=0, maxval=100, step=5, inline="r2")
i_r3   = input.float(3.0, "TP3 R multiple", group=gT, minval=0.1, step=0.1, inline="r3")
i_a3   = input.float(20,  "alloc %",        group=gT, minval=0, maxval=100, step=5, inline="r3")

gM = "④ LEVERAGE / MARGIN / FEES"
i_levMode  = input.string("Isolated Capital", "Leverage Mode", options=["Isolated Capital","Fixed Leverage","Auto-Safe Leverage"], group=gM, tooltip="Isolated Capital: leverage derived from Trade Capital.\nFixed: you set leverage.\nAuto-Safe: max leverage that keeps liquidation beyond your stop.")
i_lev      = input.int(10, "Fixed Leverage (x)", group=gM, minval=1, maxval=200)
i_mmr      = input.float(0.5, "Maint. Margin Rate %", group=gM, minval=0, step=0.1, tooltip="Exchange maintenance margin rate, drives the liquidation estimate.")
i_safety   = input.float(0.75, "Liq. Safety Factor", group=gM, minval=0.3, maxval=0.95, step=0.05, tooltip="Auto-Safe mode: stop sits at this fraction of the distance to liquidation (0.75 = 25% buffer).")
i_feeEntry = input.float(0.045, "Entry Fee % (taker)", group=gM, minval=0, step=0.005)
i_feeExit  = input.float(0.045, "Exit Fee % (taker)",  group=gM, minval=0, step=0.005)

gP = "⑤ PROP-FIRM GUARDRAILS"
i_propOn       = input.bool(true, "Enable Prop Guardrails (Panel 2)", group=gP)
i_propPhase    = input.string("Funded", "Account Phase", options=["Challenge","Verification","Funded"], group=gP)
i_propSize     = input.float(100000, "Prop Account Size", group=gP, minval=0, step=1000)
i_ddDaily      = input.float(5.0, "Daily Loss Limit %", group=gP, minval=0.1, step=0.5)
i_ddMax        = input.float(10.0, "Max Overall Drawdown %", group=gP, minval=0.1, step=0.5)
i_ddTrailing   = input.bool(true, "Trailing Max Drawdown", group=gP)
i_profitTgt    = input.float(8.0, "Profit Target %", group=gP, minval=0.1, step=0.5)
i_dailyUsed    = input.float(0.0, "Daily Loss Already Used", group=gP, minval=0, step=50, tooltip="Realised loss so far today (positive number).")
i_ddUsed       = input.float(0.0, "Current Drawdown from Peak", group=gP, minval=0, step=50, tooltip="How far below your peak balance you are now (positive number).")
i_maxRiskCap   = input.float(2.0, "Max Risk per Trade % (firm rule)", group=gP, minval=0.1, step=0.1)
i_consistPct   = input.float(40.0, "Consistency Rule % (max share of target)", group=gP, minval=1, step=5, tooltip="Many firms cap how much of the profit target can come from a single trade/day.")

gV = "⑥ VISUALS & PANELS"
i_showZones  = input.bool(true,  "Show Chart Zones & Levels", group=gV)
i_showLiq    = input.bool(true,  "Show Liquidation Line",     group=gV)
i_showBE     = input.bool(true,  "Show Break-even Line",      group=gV)
i_showTrack  = input.bool(true,  "Live Trade Tracker (PnL / outcome)", group=gV)
i_rightOff   = input.int(20, "Zone Right Extension (bars)", group=gV, minval=2, maxval=200)
i_zoneShift  = input.int(60, "⇥ Shift Zones Right of Price (bars)", group=gV, minval=0, maxval=450, tooltip="Moves the whole Entry/SL/TP block into the empty space to the right of the current candle so it doesn't overlap price or other indicators (e.g. a regression channel). 0 = anchored to the setup (original behaviour).")
i_zoneWidth  = input.int(60, "⇥ Shifted Zones Width (bars)", group=gV, minval=5, maxval=300, tooltip="Width of the Entry/SL/TP block when Shift > 0.")
i_p1pos      = input.string("Top Right", "Panel 1 — Risk Console", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=gV)
i_p2pos      = input.string("Top Left", "Panel 2 — Prop Guardrails", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=gV)
i_txtSize    = input.string("Small", "Panel Text Size", options=["Tiny","Small","Normal"], group=gV)
i_theme      = input.string("Cold Steel", "Panel Color Theme", options=["Amber","Cold Steel","Graphite","Midnight","Emerald","Slate Light"], group=gV, tooltip="Recolors the dashboard panels only. The on-chart zones and SL/TP levels are not affected.")

C_BLACK   = color.new(#000000, 0)
C_BG0     = color.new(#050402, 0)
C_BG1     = color.new(#0C0A05, 0)
C_BG2     = color.new(#15110A, 0)
C_HDR     = color.new(#241803, 0)
C_BORDER  = color.new(#3A2A0A, 0)

C_AMBER   = color.new(#FFB000, 0)
C_AMBER_B = color.new(#FFC83D, 0)
C_AMBER_D = color.new(#A8741A, 0)
C_AMBER_P = color.new(#FFE3AE, 0)

C_GREEN   = color.new(#33D17A, 0)
C_GREEN_D = color.new(#1F8F52, 0)
C_RED     = color.new(#FF453A, 0)
C_RED_D   = color.new(#B5281F, 0)
C_DANGER  = color.new(#FF1A0D, 0)

C_PROFIT_FILL = color.new(#1F8F52, 84)
C_LOSS_FILL   = color.new(#B5281F, 84)
C_DANGER_FILL = color.new(#FF1A0D, 80)
C_EXT_FILL    = color.new(#FFB000, 90)

// ── Panel palette (dashboards only) — defaults to Amber, overridden per theme ──
color pBg0    = #050402
color pBg1    = #0C0A05
color pBg2    = #15110A
color pHdr    = #241803
color pBorder = #3A2A0A
color pDim    = #A8741A
color pTxt    = #FFE3AE
color pBright = #FFC83D
color pAccent = #FFB000
color pPos    = #33D17A
color pPosD   = #1F8F52
color pNeg    = #FF453A
color pNegD   = #B5281F
color pWarn   = #FFC83D
color pDanger = #FF1A0D

if i_theme == "Cold Steel"
    pBg0 := #0B0F15
    pBg1 := #121A24
    pBg2 := #1A2431
    pHdr := #223142
    pBorder := #33475E
    pDim := #7089A0
    pTxt := #CFDEEC
    pBright := #EAF3FB
    pAccent := #6FB7DA
    pPos := #45C4A8
    pPosD := #2C7D6E
    pNeg := #F06E6E
    pNegD := #A84A48
    pWarn := #E2B95C
    pDanger := #FF6B5E
else if i_theme == "Graphite"
    pBg0 := #0D0D0F
    pBg1 := #16161A
    pBg2 := #1E1E23
    pHdr := #26262C
    pBorder := #3A3A42
    pDim := #8A8A93
    pTxt := #DCDCE2
    pBright := #F2F2F6
    pAccent := #B8B8C2
    pPos := #5FD08A
    pPosD := #358252
    pNeg := #F0665F
    pNegD := #A6423C
    pWarn := #E0B457
    pDanger := #FF6257
else if i_theme == "Midnight"
    pBg0 := #0A0E1A
    pBg1 := #101528
    pBg2 := #161D33
    pHdr := #1E2748
    pBorder := #313D66
    pDim := #6E7BA6
    pTxt := #CBD5F5
    pBright := #E6ECFF
    pAccent := #8AA0FF
    pPos := #5CD0A0
    pPosD := #2F8464
    pNeg := #F27089
    pNegD := #A6465A
    pWarn := #E7B85C
    pDanger := #FF6B87
else if i_theme == "Emerald"
    pBg0 := #06110B
    pBg1 := #0B1A12
    pBg2 := #11241A
    pHdr := #163020
    pBorder := #26523A
    pDim := #5F9B7B
    pTxt := #CDEBD8
    pBright := #E6F7EC
    pAccent := #57C98A
    pPos := #4FD08A
    pPosD := #2C8A5A
    pNeg := #F0776E
    pNegD := #A64B45
    pWarn := #E4BC5E
    pDanger := #FF6E5E
else if i_theme == "Slate Light"
    pBg0 := #E9EDF2
    pBg1 := #F2F5F9
    pBg2 := #E3E9F0
    pHdr := #D2DAE6
    pBorder := #B4C0CF
    pDim := #5A6B7D
    pTxt := #1E2A38
    pBright := #0F1822
    pAccent := #2C6E9E
    pPos := #1F9D57
    pPosD := #157A42
    pNeg := #D23B3B
    pNegD := #A82C2C
    pWarn := #B8860B
    pDanger := #E23A2A

f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

f_tsize() => i_txtSize == "Tiny" ? size.tiny : i_txtSize == "Small" ? size.small : size.normal

curSym = i_curSel == "$ USD" ? "$" : i_curSel == "€ EUR" ? "€" : i_curSel == "£ GBP" ? "£" : i_curSel == "¥ JPY" ? "¥" : i_curSel == "₮ USDT" ? "₮" : i_curSel == "₿ BTC" ? "₿" : i_curSel == "Ξ ETH" ? "Ξ" : "$"

f_money(x) =>
    na(x) ? "—" : (x < 0 ? "-" : "") + curSym + str.format("{0,number,#,##0.00}", math.abs(x))
f_money0(x) =>
    na(x) ? "—" : (x < 0 ? "-" : "") + curSym + str.format("{0,number,#,##0}", math.abs(x))
f_px(x) =>
    na(x) or x == 0 ? "—" : str.tostring(x, format.mintick)
f_pct(x) =>
    na(x) ? "—" : str.tostring(x, "#,##0.00") + "%"
f_x(x) =>
    na(x) ? "—" : str.tostring(x, "#,##0.0") + "x"
f_qty(x) =>
    na(x) ? "—" : str.tostring(x, "#,##0.######")
f_r(x) =>
    na(x) ? "—" : str.tostring(x, "#,##0.0") + "R"

f_cell(t, c, r, txt, txtCol, bgCol, align) =>
    table.cell(t, c, r, txt, text_color=txtCol, bgcolor=bgCol, text_size=f_tsize(), text_halign=align)

f_delL(ln) =>
    if not na(ln)
        line.delete(ln)
f_delB(bx) =>
    if not na(bx)
        box.delete(bx)
f_delLab(lb) =>
    if not na(lb)
        label.delete(lb)

entry   = i_entry
stop    = i_stop
bool setup_ready = entry > 0 and stop > 0 and entry != stop

bool isLong = i_dirMode == "Long" ? true : i_dirMode == "Short" ? false : (setup_ready ? stop < entry : true)

feEntry = i_feeEntry / 100.0
feExit  = i_feeExit  / 100.0
mmr     = i_mmr / 100.0

slDist  = setup_ready ? math.abs(entry - stop) : na
slPct   = setup_ready ? slDist / entry * 100.0 : na

riskAmt = i_riskMode == "% of Balance"        ? i_balance  * i_riskPct / 100.0 :
          i_riskMode == "% of Trade Capital"  ? i_tradeCap * i_riskPct / 100.0 :
          i_riskFixed
riskPctOfBal = i_balance > 0 ? riskAmt / i_balance * 100.0 : na

float qty = na
if setup_ready
    denom = slDist + entry * feEntry + stop * feExit
    qty := denom > 0 ? riskAmt / denom : na

notional = setup_ready and not na(qty) ? qty * entry : na
maintAmt = not na(notional) ? notional * mmr : na

f_tpPrice(userP, rMult) =>
    userP > 0 ? userP : (i_autoTP ? (isLong ? entry + rMult * slDist : entry - rMult * slDist) : na)
tp1 = setup_ready ? f_tpPrice(i_tp1, i_r1) : na
tp2 = setup_ready ? f_tpPrice(i_tp2, i_r2) : na
tp3 = setup_ready ? f_tpPrice(i_tp3, i_r3) : na

r1 = setup_ready and not na(tp1) ? math.abs(tp1 - entry) / slDist : na
r2 = setup_ready and not na(tp2) ? math.abs(tp2 - entry) / slDist : na
r3 = setup_ready and not na(tp3) ? math.abs(tp3 - entry) / slDist : na

float autoLev = na
if setup_ready and (slPct / 100.0) > 0
    autoLev := math.floor(1.0 / ((slPct / 100.0) / i_safety + mmr))
    autoLev := math.max(autoLev, 1)

float reqMargin = na
float lev = na
if setup_ready and not na(notional)
    if i_levMode == "Isolated Capital"
        reqMargin := i_tradeCap
        lev := reqMargin > 0 ? notional / reqMargin : na
    else if i_levMode == "Fixed Leverage"
        lev := i_lev
        reqMargin := notional / lev
    else
        lev := autoLev
        reqMargin := not na(lev) and lev > 0 ? notional / lev : na

effLev = not na(notional) and not na(reqMargin) and reqMargin > 0 ? notional / reqMargin : na
accLev = not na(notional) and i_balance > 0 ? notional / i_balance : na

float liqPrice = na
if setup_ready and not na(qty) and qty > 0 and not na(reqMargin) and not na(maintAmt)
    liqPrice := isLong ? entry - (reqMargin - maintAmt) / qty : entry + (reqMargin - maintAmt) / qty
liqDist     = not na(liqPrice) ? math.abs(entry - liqPrice) : na
liqBuffer   = not na(liqDist) and not na(slDist) and slDist > 0 ? liqDist / slDist : na
bool liqBeforeStop = not na(liqBuffer) and liqBuffer <= 1.0

beShift = entry * (feEntry + feExit)
bePrice = setup_ready ? (isLong ? entry + beShift : entry - beShift) : na

entryFeeTot = not na(notional) ? notional * feEntry : na

f_tpProfit(tpP, allocPct) =>
    float pr = na
    if setup_ready and not na(qty)
        q   = qty * allocPct / 100.0
        gp  = q * math.abs(tpP - entry)
        ef  = q * entry * feEntry
        xf  = q * tpP   * feExit
        pr := gp - ef - xf
    pr
np1 = f_tpProfit(tp1, i_a1)
np2 = f_tpProfit(tp2, i_a2)
np3 = f_tpProfit(tp3, i_a3)

f_tpProfitFull(tpP) =>
    float pr = na
    if setup_ready and not na(tpP) and not na(qty)
        pr := qty * math.abs(tpP - entry) - qty * entry * feEntry - qty * tpP * feExit
    pr
full1 = f_tpProfitFull(tp1)
full2 = f_tpProfitFull(tp2)
full3 = f_tpProfitFull(tp3)

float blendProfit = na
if setup_ready
    blendProfit := nz(np1) + nz(np2) + nz(np3)
blendR    = not na(blendProfit) and riskAmt > 0 ? blendProfit / riskAmt : na
roiMargin = not na(blendProfit) and not na(reqMargin) and reqMargin > 0 ? blendProfit / reqMargin * 100.0 : na

rrTxt    = na(blendR) ? "—" : "1 : " + str.tostring(blendR, "#,##0.00")
rrVerd   = na(blendR) ? "—" : blendR >= 2.0 ? "EXCELLENT" : blendR >= 1.5 ? "GOOD" : blendR >= 1.0 ? "MARGINAL" : "POOR ✗"
rrCol    = na(blendR) ? pDim : blendR >= 1.5 ? pPos : blendR >= 1.0 ? pBright : pNeg

float oneR_full = na
if setup_ready and not na(qty)
    float tp1R = isLong ? entry + slDist : entry - slDist
    oneR_full := qty * slDist - qty * entry * feEntry - qty * tp1R * feExit
oneR_ratio = not na(oneR_full) and riskAmt > 0 ? oneR_full / riskAmt : na

bool be_after_tp1 = i_a1 > 0
lockedTP1 = not na(np1) ? nz(np1) : na

allocSum = i_a1 + i_a2 + i_a3

dailyLimit   = i_propSize * i_ddDaily   / 100.0
maxDD        = i_propSize * i_ddMax     / 100.0
profitTarget = i_propSize * i_profitTgt / 100.0

thisRisk     = setup_ready ? riskAmt : na
remainDaily  = dailyLimit - i_dailyUsed
remainMaxDD  = maxDD - i_ddUsed

riskVsDaily  = not na(thisRisk) and dailyLimit > 0 ? thisRisk / dailyLimit * 100.0 : na
riskVsMaxDD  = not na(thisRisk) and maxDD > 0 ? thisRisk / maxDD * 100.0 : na
tradesDaily  = not na(thisRisk) and thisRisk > 0 ? math.floor(remainDaily / thisRisk) : na
tradesMaxDD  = not na(thisRisk) and thisRisk > 0 ? math.floor(remainMaxDD / thisRisk) : na
tradesToTgt  = not na(blendProfit) and blendProfit > 0 ? math.ceil(profitTarget / blendProfit) : na

consistShare = not na(blendProfit) and profitTarget > 0 ? blendProfit / profitTarget * 100.0 : na

f_statusTxt(s) => s == 0 ? "SAFE" : s == 1 ? "CAUTION" : "VIOLATION"
f_statusCol(s) => s == 0 ? pPos : s == 1 ? pWarn : pDanger

int stDaily = na
if not na(thisRisk)
    stDaily := thisRisk > remainDaily ? 2 : thisRisk > remainDaily * 0.5 ? 1 : 0
int stMaxDD = na
if not na(thisRisk)
    stMaxDD := (i_ddUsed + thisRisk) > maxDD ? 2 : (i_ddUsed + thisRisk) > maxDD * 0.5 ? 1 : 0
int stRisk = na
if not na(riskPctOfBal)
    stRisk := riskPctOfBal > i_maxRiskCap ? 2 : riskPctOfBal > i_maxRiskCap * 0.75 ? 1 : 0
int stConsist = na
if not na(consistShare)
    stConsist := consistShare > i_consistPct ? 1 : 0
int stLiq = na
if not na(liqBuffer)
    stLiq := liqBeforeStop ? 2 : liqBuffer < 1.5 ? 1 : 0

int stOverall = na
if setup_ready
    stOverall := math.max(nz(stDaily), nz(stMaxDD), nz(stRisk), nz(stConsist), nz(stLiq))

f_clamp(v, lo, hi) => math.min(math.max(v, lo), hi)

float sRR   = na
float sRisk = na
float sLiq  = na
float sProp = na
if setup_ready
    sRR   := f_clamp(nz(blendR) * 3.0, 0, 10)
    sRisk := na(riskPctOfBal) ? 7.0 : riskPctOfBal <= 1.0 ? 10.0 : f_clamp(10.0 - (riskPctOfBal - 1.0) * 2.5, 0, 10)
    sLiq  := na(liqBuffer) ? 5.0 : f_clamp((liqBuffer - 1.0) / 2.0 * 10.0, 0, 10)
    sProp := not i_propOn ? 7.0 : (na(thisRisk) or thisRisk <= 0 ? 7.0 : f_clamp((remainDaily / thisRisk - 1.0) / 9.0 * 10.0, 0, 10))
float qScore = setup_ready ? f_clamp(sRR * 0.30 + sRisk * 0.30 + sLiq * 0.20 + sProp * 0.20, 0, 10) : na
qStars = na(qScore) ? "" : str.tostring(math.round(qScore), "#")
qTier  = na(qScore) ? "—" : qScore >= 8 ? "ELITE" : qScore >= 6 ? "STRONG" : qScore >= 4 ? "FAIR" : "WEAK"
qCol   = na(qScore) ? pDim : qScore >= 8 ? pPos : qScore >= 6 ? pBright : qScore >= 4 ? pAccent : pNeg

var int anchorBar = na
if na(anchorBar) and i_anchor > 0 and time >= i_anchor
    anchorBar := bar_index
int startBar = na(anchorBar) ? bar_index - 50 : anchorBar
int rightBar = bar_index + i_rightOff
// Shift the whole level block into empty space to the right of price (0 = anchored)
if i_zoneShift > 0
    startBar := bar_index + i_zoneShift
    rightBar := bar_index + i_zoneShift + i_zoneWidth
// TradingView only draws ~500 bars into the future — clamp so nothing disappears
rightBar := int(math.min(rightBar, bar_index + 500))
startBar := int(math.min(startBar, rightBar - 1))

var bool trk_in    = false
var bool trk_done  = false
var int  trk_res   = 0
var float trk_pnl  = na

if i_showTrack and setup_ready and not na(anchorBar) and bar_index >= anchorBar
    bool touchedEntry = (low <= entry and high >= entry)
    if not trk_in and not trk_done and touchedEntry
        trk_in := true
    if trk_in and not trk_done
        bool hitSL = isLong ? low  <= stop : high >= stop
        bool hitT3 = isLong ? high >= tp3  : low  <= tp3
        if hitSL
            trk_done := true
            trk_res  := -1
            trk_pnl  := -riskAmt
        else if hitT3
            trk_done := true
            trk_res  := 1
            trk_pnl  := blendProfit
        else
            float openR = isLong ? (close - entry) / slDist : (entry - close) / slDist
            trk_pnl := openR * riskAmt

var line  ln_entry = na
var line  ln_stop  = na
var line  ln_tp1   = na
var line  ln_tp2   = na
var line  ln_tp3   = na
var line  ln_liq   = na
var line  ln_be    = na
var box   bx_loss  = na
var box   bx_prof  = na
var box   bx_dang  = na
var box   bx_ext   = na
var label lb_entry = na
var label lb_stop  = na
var label lb_tp1   = na
var label lb_tp2   = na
var label lb_tp3   = na
var label lb_liq   = na
var label lb_trk   = na

if barstate.islast
    f_delL(ln_entry)
    f_delL(ln_stop)
    f_delL(ln_tp1)
    f_delL(ln_tp2)
    f_delL(ln_tp3)
    f_delL(ln_liq)
    f_delL(ln_be)
    f_delB(bx_loss)
    f_delB(bx_prof)
    f_delB(bx_dang)
    f_delB(bx_ext)
    f_delLab(lb_entry)
    f_delLab(lb_stop)
    f_delLab(lb_tp1)
    f_delLab(lb_tp2)
    f_delLab(lb_tp3)
    f_delLab(lb_liq)
    f_delLab(lb_trk)

    if i_showZones and setup_ready
        if not na(tp3)
            bx_prof := box.new(startBar, math.max(entry, tp3), rightBar, math.min(entry, tp3), xloc=xloc.bar_index, border_color=color.new(C_GREEN_D, 60), bgcolor=C_PROFIT_FILL)
        bx_loss := box.new(startBar, math.max(entry, stop), rightBar, math.min(entry, stop), xloc=xloc.bar_index, border_color=color.new(C_RED_D, 60), bgcolor=C_LOSS_FILL)
        if i_showLiq and not na(liqPrice)
            bx_dang := box.new(startBar, math.max(stop, liqPrice), rightBar, math.min(stop, liqPrice), xloc=xloc.bar_index, border_color=color.new(C_DANGER, 70), bgcolor=C_DANGER_FILL)
        if not na(tp3)
            float extTo = isLong ? tp3 + slDist : tp3 - slDist
            bx_ext := box.new(startBar, math.max(tp3, extTo), rightBar, math.min(tp3, extTo), xloc=xloc.bar_index, border_color=color.new(C_AMBER, 80), bgcolor=C_EXT_FILL)

        ln_entry := line.new(startBar, entry, rightBar, entry, xloc=xloc.bar_index, color=C_AMBER, width=2)
        ln_stop  := line.new(startBar, stop,  rightBar, stop,  xloc=xloc.bar_index, color=C_RED, width=2, style=line.style_dashed)
        if not na(tp1)
            ln_tp1 := line.new(startBar, tp1, rightBar, tp1, xloc=xloc.bar_index, color=C_GREEN, width=2, style=line.style_dotted)
        if not na(tp2)
            ln_tp2 := line.new(startBar, tp2, rightBar, tp2, xloc=xloc.bar_index, color=C_GREEN, width=2, style=line.style_dotted)
        if not na(tp3)
            ln_tp3 := line.new(startBar, tp3, rightBar, tp3, xloc=xloc.bar_index, color=C_GREEN, width=2, style=line.style_dotted)
        if i_showBE and not na(bePrice)
            ln_be := line.new(startBar, bePrice, rightBar, bePrice, xloc=xloc.bar_index, color=C_AMBER_D, style=line.style_dotted)
        if i_showLiq and not na(liqPrice)
            ln_liq := line.new(startBar, liqPrice, rightBar, liqPrice, xloc=xloc.bar_index, color=C_DANGER, width=1, style=line.style_dashed)

        int lx = rightBar
        lb_entry := label.new(lx, entry, (isLong ? "▲ LONG" : "▼ SHORT") + "  ENTRY " + f_px(entry), xloc=xloc.bar_index, style=label.style_label_left, color=C_HDR, textcolor=C_AMBER_B, size=size.small)
        lb_stop  := label.new(lx, stop, "SL " + f_px(stop) + "  ·  -" + f_pct(slPct) + "  ·  " + f_money(riskAmt), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_RED_D, 0), textcolor=color.white, size=size.small)
        if not na(tp1)
            lb_tp1 := label.new(lx, tp1, "TP1 (" + str.tostring(i_a1, "#") + "%) " + f_px(tp1) + "  ·  " + str.tostring(r1, "#,##0.0") + "R  ·  " + f_money(np1), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_GREEN_D, 0), textcolor=color.white, size=size.small)
        if not na(tp2)
            lb_tp2 := label.new(lx, tp2, "TP2 (" + str.tostring(i_a2, "#") + "%) " + f_px(tp2) + "  ·  " + str.tostring(r2, "#,##0.0") + "R  ·  " + f_money(np2), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_GREEN_D, 0), textcolor=color.white, size=size.small)
        if not na(tp3)
            lb_tp3 := label.new(lx, tp3, "TP3 (" + str.tostring(i_a3, "#") + "%) " + f_px(tp3) + "  ·  " + str.tostring(r3, "#,##0.0") + "R  ·  " + f_money(np3), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_GREEN_D, 0), textcolor=color.white, size=size.small)
        if i_showLiq and not na(liqPrice)
            lb_liq := label.new(lx, liqPrice, "☠ LIQ " + f_px(liqPrice) + (liqBeforeStop ? "  ⚠ BEFORE STOP" : "  ·  " + f_x(liqBuffer) + " buffer"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(C_DANGER, 0), textcolor=color.white, size=size.small)

        if i_showTrack and (trk_in or trk_done)
            string tTxt = trk_done ? (trk_res == 1 ? "✓ TARGET HIT  " + f_money(trk_pnl) : trk_res == -1 ? "✘ STOPPED OUT  " + f_money(trk_pnl) : "● CLOSED  " + f_money(trk_pnl)) : "● OPEN  " + f_money(trk_pnl)
            color tCol = trk_done ? (trk_res == 1 ? C_GREEN_D : trk_res == -1 ? C_RED_D : C_AMBER_D) : (nz(trk_pnl) >= 0 ? C_GREEN_D : C_RED_D)
            float trkY = nz(trk_pnl) >= 0 ? (not na(tp1) ? tp1 : entry) : stop
            int trkX = i_zoneShift > 0 ? startBar : bar_index
            lb_trk := label.new(trkX, trkY, tTxt, xloc=xloc.bar_index, style=label.style_label_down, color=color.new(tCol, 0), textcolor=color.white, size=size.small)

var table P1 = table.new(f_pos(i_p1pos), 2, 22, bgcolor=pBg0, border_width=1, border_color=pBorder, frame_width=1, frame_color=pBorder)

if barstate.islast
    int r = 0
    f_cell(P1, 0, r, "⚡ RISK CONSOLE", pBright, pHdr, text.align_left)
    f_cell(P1, 1, r, isLong ? "LONG" : "SHORT", isLong ? pPos : pNeg, pHdr, text.align_right)
    r += 1

    f_cell(P1, 0, r, "Symbol", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, syminfo.ticker, pTxt, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Account Balance", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_money0(i_balance), pTxt, pBg2, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Trade Capital (Margin)", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_money0(reqMargin), pTxt, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Risk Model", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, i_riskMode + (i_riskMode == "Fixed Amount" ? "" : "  " + f_pct(i_riskPct)), pAccent, pBg2, text.align_right)
    r += 1
    f_cell(P1, 0, r, "⚠ Max Loss (full, at SL)", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_money(riskAmt) + (na(riskPctOfBal) ? "" : "  (" + f_pct(riskPctOfBal) + ")"), pNeg, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "1R Value (full, net)", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_money(oneR_full) + (na(oneR_ratio) ? "" : "  (" + str.tostring(oneR_ratio, "#,##0.00") + "R)"), pPos, pBg2, text.align_right)
    r += 1

    f_cell(P1, 0, r, "── SETUP ──", pBright, pHdr, text.align_left)
    f_cell(P1, 1, r, "", pBright, pHdr, text.align_right)
    table.merge_cells(P1, 0, r, 1, r)
    r += 1
    f_cell(P1, 0, r, "⌖ Entry", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_px(entry), pBright, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "⛔ Stop Loss" + (na(slPct) ? "" : "  (" + f_pct(slPct) + ")"), pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_px(stop), pNeg, pBg2, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Stop Distance", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, na(slDist) ? "—" : f_px(slDist), pTxt, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Break-even (fees)", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_px(bePrice), pTxt, pBg2, text.align_right)
    r += 1
    f_cell(P1, 0, r, "◆ Contracts / Size", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_qty(qty), pBright, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Position Value", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_money0(notional), pTxt, pBg2, text.align_right)
    r += 1

    f_cell(P1, 0, r, "── LEVERAGE ──", pBright, pHdr, text.align_left)
    f_cell(P1, 1, r, "", pBright, pHdr, text.align_right)
    table.merge_cells(P1, 0, r, 1, r)
    r += 1
    f_cell(P1, 0, r, "⚡ Eff. Trade Leverage", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_x(effLev), pBright, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Account Leverage", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_x(accLev), pTxt, pBg2, text.align_right)
    r += 1
    f_cell(P1, 0, r, "Maint. Margin (" + f_pct(i_mmr) + ")", pDim, pBg1, text.align_left)
    f_cell(P1, 1, r, f_money(maintAmt), pTxt, pBg1, text.align_right)
    r += 1
    f_cell(P1, 0, r, "☠ Est. Liquidation", pDim, pBg2, text.align_left)
    f_cell(P1, 1, r, f_px(liqPrice) + (na(liqBuffer) ? "" : "  (" + f_x(liqBuffer) + ")"), liqBeforeStop ? pDanger : pTxt, pBg2, text.align_right)
    r += 1

    f_cell(P1, 0, r, "★ SETUP QUALITY", qCol, pHdr, text.align_left)
    f_cell(P1, 1, r, na(qScore) ? "—" : str.tostring(qScore, "#,##0.0") + "/10  " + qTier, qCol, pHdr, text.align_right)
    r += 1

    string warnTxt = not setup_ready ? "⚠ Set Entry & Stop (click chart)" :
                     liqBeforeStop ? "⚠ LIQUIDATION BEFORE STOP — cut leverage" :
                     allocSum != 100 ? "⚠ TP allocations = " + str.tostring(allocSum, "#") + "% (≠100)" :
                     "✓ Setup valid"
    color warnCol = (not setup_ready or liqBeforeStop) ? pDanger : allocSum != 100 ? pBright : pPos
    f_cell(P1, 0, r, warnTxt, warnCol, pBg0, text.align_left)
    f_cell(P1, 1, r, "", warnCol, pBg0, text.align_right)
    table.merge_cells(P1, 0, r, 1, r)

var table P2 = table.new(f_pos(i_p2pos), 3, 22, bgcolor=pBg0, border_width=1, border_color=pBorder, frame_width=1, frame_color=pBorder)

if barstate.islast and i_propOn
    int r = 0
    f_cell(P2, 0, r, "🛡 PROP GUARDRAILS", pBright, pHdr, text.align_left)
    f_cell(P2, 1, r, i_propPhase, pAccent, pHdr, text.align_center)
    f_cell(P2, 2, r, na(stOverall) ? "—" : f_statusTxt(stOverall), na(stOverall) ? pDim : f_statusCol(stOverall), pHdr, text.align_right)
    r += 1

    f_cell(P2, 0, r, "RULE", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, "THIS TRADE", pDim, pBg2, text.align_center)
    f_cell(P2, 2, r, "STATUS", pDim, pBg2, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Daily Loss " + f_pct(i_ddDaily), pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, na(riskVsDaily) ? "—" : f_pct(riskVsDaily) + " of limit", pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, na(stDaily) ? "—" : f_statusTxt(stDaily), na(stDaily) ? pDim : f_statusCol(stDaily), pBg1, text.align_right)
    r += 1
    f_cell(P2, 0, r, "Daily Budget Left", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, f_money0(remainDaily), remainDaily > 0 ? pTxt : pDanger, pBg2, text.align_center)
    f_cell(P2, 2, r, na(tradesDaily) ? "—" : str.tostring(tradesDaily, "#") + " trades", pAccent, pBg2, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Max DD " + f_pct(i_ddMax) + (i_ddTrailing ? " (trail)" : ""), pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, na(riskVsMaxDD) ? "—" : f_pct(riskVsMaxDD) + " of limit", pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, na(stMaxDD) ? "—" : f_statusTxt(stMaxDD), na(stMaxDD) ? pDim : f_statusCol(stMaxDD), pBg1, text.align_right)
    r += 1
    f_cell(P2, 0, r, "Max DD Buffer Left", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, f_money0(remainMaxDD), remainMaxDD > 0 ? pTxt : pDanger, pBg2, text.align_center)
    f_cell(P2, 2, r, na(tradesMaxDD) ? "—" : str.tostring(tradesMaxDD, "#") + " trades", pAccent, pBg2, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Risk/Trade ≤ " + f_pct(i_maxRiskCap), pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, na(riskPctOfBal) ? "—" : f_pct(riskPctOfBal), pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, na(stRisk) ? "—" : f_statusTxt(stRisk), na(stRisk) ? pDim : f_statusCol(stRisk), pBg1, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Liq. Safety", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, na(liqBuffer) ? "—" : f_x(liqBuffer) + " buffer", pTxt, pBg2, text.align_center)
    f_cell(P2, 2, r, na(stLiq) ? "—" : f_statusTxt(stLiq), na(stLiq) ? pDim : f_statusCol(stLiq), pBg2, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Consistency ≤ " + f_pct(i_consistPct), pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, na(consistShare) ? "—" : f_pct(consistShare) + " of target", pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, na(stConsist) ? "—" : f_statusTxt(stConsist), na(stConsist) ? pDim : f_statusCol(stConsist), pBg1, text.align_right)
    r += 1

    f_cell(P2, 0, r, "Profit Target " + f_pct(i_profitTgt), pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, f_money0(profitTarget), pTxt, pBg2, text.align_center)
    f_cell(P2, 2, r, na(tradesToTgt) ? "—" : str.tostring(tradesToTgt, "#") + " to go", pPos, pBg2, text.align_right)
    r += 1

    f_cell(P2, 0, r, "── TAKE-PROFIT PLAN ──", pBright, pHdr, text.align_left)
    f_cell(P2, 1, r, "", pBright, pHdr, text.align_center)
    f_cell(P2, 2, r, "", pBright, pHdr, text.align_right)
    table.merge_cells(P2, 0, r, 2, r)
    r += 1
    f_cell(P2, 0, r, "LEVEL", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, "PRICE · R", pDim, pBg2, text.align_center)
    f_cell(P2, 2, r, "FULL / SLICE", pDim, pBg2, text.align_right)
    r += 1
    f_cell(P2, 0, r, "TP1  " + str.tostring(i_a1, "#") + "%", pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, f_px(tp1) + "  " + f_r(r1), pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, f_money(full1) + " / " + f_money(np1), pPos, pBg1, text.align_right)
    r += 1
    f_cell(P2, 0, r, "TP2  " + str.tostring(i_a2, "#") + "%", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, f_px(tp2) + "  " + f_r(r2), pTxt, pBg2, text.align_center)
    f_cell(P2, 2, r, f_money(full2) + " / " + f_money(np2), pPos, pBg2, text.align_right)
    r += 1
    f_cell(P2, 0, r, "TP3  " + str.tostring(i_a3, "#") + "%", pDim, pBg1, text.align_left)
    f_cell(P2, 1, r, f_px(tp3) + "  " + f_r(r3), pTxt, pBg1, text.align_center)
    f_cell(P2, 2, r, f_money(full3) + " / " + f_money(np3), pPos, pBg1, text.align_right)
    r += 1
    f_cell(P2, 0, r, "◉ PLAN PROFIT (slices)", pBright, pHdr, text.align_left)
    f_cell(P2, 1, r, na(blendR) ? "—" : str.tostring(blendR, "#,##0.00") + "R", pBright, pHdr, text.align_center)
    f_cell(P2, 2, r, f_money(blendProfit) + "  " + f_pct(roiMargin), na(blendProfit) ? pDim : blendProfit >= 0 ? pPos : pNeg, pHdr, text.align_right)
    r += 1
    f_cell(P2, 0, r, "↔ REWARD : RISK", rrCol, pBg1, text.align_left)
    f_cell(P2, 1, r, rrTxt, rrCol, pBg1, text.align_center)
    f_cell(P2, 2, r, rrVerd, rrCol, pBg1, text.align_right)
    r += 1
    f_cell(P2, 0, r, "Risk-free @TP1 (SL→BE)", pDim, pBg2, text.align_left)
    f_cell(P2, 1, r, "locks " + f_money(lockedTP1), pTxt, pBg2, text.align_center)
    f_cell(P2, 2, r, be_after_tp1 ? "downside → ~0" : "—", pPos, pBg2, text.align_right)

bool al_entry = i_showTrack and setup_ready and not na(anchorBar) and trk_in and not trk_in[1]
bool al_tp    = i_showTrack and setup_ready and trk_done and trk_res == 1 and not (trk_done[1] and trk_res[1] == 1)
bool al_sl    = i_showTrack and setup_ready and trk_done and trk_res == -1 and not (trk_done[1] and trk_res[1] == -1)
bool al_viol  = setup_ready and not na(stOverall) and stOverall == 2 and (na(stOverall[1]) or stOverall[1] != 2)

alertcondition(al_entry, "Entry Triggered", "Strong Risk: price reached entry")
alertcondition(al_tp,    "Target Hit",      "Strong Risk: take-profit target reached")
alertcondition(al_sl,    "Stopped Out",     "Strong Risk: stop loss hit")
alertcondition(al_viol,  "Guardrail Violation", "Strong Risk: prop-firm guardrail VIOLATION on this setup")
````
