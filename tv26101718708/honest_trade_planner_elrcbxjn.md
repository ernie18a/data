# Honest Trade Planner

- url: https://www.tradingview.com/script/elRcbxJn-Honest-Trade-Planner/
- type: indicator
- pine_id: PUB;598aff7980564d07aea1f1bafa378f0c
- version: 1.0

## Description

[b]Honest Trade Planner[/b]

[i]On-chart position sizer & risk/reward planner. Place entry, stop, target — it sizes the trade so a single loss can't exceed your risk budget. Decision-support, not signals.[/i]

[b]Honest Trader Toolkit[/b] — decision-support, not prediction. No signals, no forecasts, no win-rate claims. Just a correct read of what's actually on your chart.

The Honest Trade Planner turns a trade idea into a correctly sized order. You place your **entry**, **stop**, and (optionally) **target** on the chart; it shows you exactly how big to trade and precisely what you're risking — with the cross-asset math done right.

**What it does**
• Sizes a single trade from your **account size × risk %** and your **entry-to-stop distance**.
• Correct across **stocks, crypto, index, futures, and forex** — futures use the contract point value; forex reports both units and standard lots.
• Shows the full picture: **Risk $, Reward $, R:R ratio, position notional, and % of account** both risked and deployed.
• Optional **ATR-assisted stop** with an explicit Long/Short bias, so the distance math is never ambiguous.
• Draws a **risk zone** and a **reward zone** on the chart, plus a clean dashboard table.

**Honest by design**
• Position size is always rounded **DOWN** to your instrument's step — so your planned loss never sneaks past your risk budget. It will never round up to make a number look nicer.
• Money figures are shown in the symbol's **quote currency** (Pine can't read your broker, so account size is a manual input — convert if your account currency differs).
• On unsupported instruments or missing contract data it says **"verify contract specs"** rather than display a confidently wrong number.
• Bad inputs (zero account, entry = stop, target on the wrong side) **suppress** the nonsense output and tell you why. A low R:R is shown as information, never as a command to act.

**This tool does not predict anything and gives no buy or sell signals.** Every number is yours to act on or ignore — it only informs the decision you're already making.

**How to use**
1. Add it to any chart. You'll be prompted to click **Entry**, then **Stop** (both are draggable afterward). Set a **Target** in settings, or drag it, to get R:R.
2. Open settings → enter your **account size** and pick a **risk %** (0.25 / 0.5 / 1 / 2% or custom).
3. For fractional instruments (crypto, fractional shares) set the **Quantity step** (e.g. 0.001).
4. Read the dashboard. Drag entry/stop/target to plan different scenarios live.

**Limitations (so you know exactly what you're getting)**
• Pine cannot connect to your broker — account size and levels are manual inputs.
• Figures are in the symbol's quote currency.
• This is a planning and sizing tool, not financial advice. Always verify contract specifications for your instrument and broker before trading.

Open-source — read every line of the math yourself. Feedback welcome in the comments.

## Source Code

````pine
//@version=6
// =============================================================================
// Honest Trade Planner (v1, free)  ·  PersonalProject / trading-tools wedge
// -----------------------------------------------------------------------------
// An on-chart visual trade planner / position sizer. You place entry, stop, and
// (optionally) target; it tells you exactly how big to trade and what you're
// risking — with the cross-asset math actually correct.
//
// Pure decision-support. No prediction, no signals, no hype. Everything is the
// trader's decision; this tool only informs. Position size is ALWAYS rounded
// DOWN so the planned loss never exceeds your risk budget.
//
// NOTE on currency: Pine cannot read your broker account, so account size is a
// manual input and all money figures are in the symbol's QUOTE currency
// (syminfo.currency, shown in the dashboard). If your account is in a different
// currency, convert accordingly.
// =============================================================================
indicator("Honest Trade Planner", overlay = true, max_boxes_count = 20, max_lines_count = 20, max_labels_count = 20)

// ----------------------------------------------------------------------------
// 1. INPUTS
// ----------------------------------------------------------------------------
grpAcct = "Account & Risk"
accountSize   = input.float(10000.0, "Account size (quote currency)", minval = 0.0, group = grpAcct, tooltip = "Your account equity, in the symbol's quote currency. Pine cannot read your broker; enter it manually.")
riskPctStr    = input.string("1%", "Risk per trade", options = ["0.25%", "0.5%", "1%", "2%", "Custom"], group = grpAcct)
riskPctCustom = input.float(1.0, "Custom risk %", minval = 0.0, step = 0.05, group = grpAcct)

grpTrade = "Trade levels (draggable on chart)"
entry  = input.price(0.0, "Entry",             group = grpTrade, confirm = true)
stop   = input.price(0.0, "Stop",              group = grpTrade, confirm = true)
target = input.price(0.0, "Target (optional)", group = grpTrade)

grpAtr = "ATR-assisted stop (optional)"
useAtrStop = input.bool(false, "Use ATR stop instead of manual stop", group = grpAtr)
tradeBias  = input.string("Long", "Bias (only used for ATR stop)", options = ["Long", "Short"], group = grpAtr)
atrLen     = input.int(14, "ATR length", minval = 1, group = grpAtr)
atrMult    = input.float(2.0, "ATR multiple", minval = 0.0, step = 0.1, group = grpAtr)

grpInst = "Instrument"
qtyStep = input.float(1.0, "Quantity step (round size DOWN to this)", minval = 0.0, group = grpInst, tooltip = "Smallest tradable increment. 1 = whole shares/contracts. Lower it for crypto or fractional shares (e.g. 0.001).")

grpDisp = "Display"
showZones = input.bool(true, "Show risk/reward zones", group = grpDisp)
showTable = input.bool(true, "Show dashboard", group = grpDisp)
tblPos    = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDisp)
dashTheme    = input.string("Auto", "Dashboard colors", options = ["Auto", "Dark", "Light", "Custom"], group = grpDisp, tooltip = "Auto matches your chart's light/dark theme automatically. Dark/Light force a scheme. Custom uses the two colors below.")
dashTextCust = input.color(color.white, "    Custom: text color", group = grpDisp, tooltip = "Used only when Dashboard colors = Custom.")
dashBgCust   = input.color(#1e222d, "    Custom: background", group = grpDisp, tooltip = "Used only when Dashboard colors = Custom. Adjust its opacity in the color picker to taste.")

// ----------------------------------------------------------------------------
// 2. HELPERS (global scope — Pine forbids local function declarations)
// ----------------------------------------------------------------------------
fmtNum(x, digits) =>
    na(x) ? "—" : digits == 0 ? str.tostring(math.round(x)) : digits == 2 ? str.tostring(x, "#.##") : str.tostring(x, "#.######")

// ----------------------------------------------------------------------------
// 3. RESOLVE RISK % AND STOP
// ----------------------------------------------------------------------------
riskPct = switch riskPctStr
    "0.25%" => 0.25
    "0.5%"  => 0.5
    "1%"    => 1.0
    "2%"    => 2.0
    => riskPctCustom

atrVal = ta.atr(atrLen)
stopResolved = stop
if useAtrStop and not na(atrVal) and not na(entry)
    stopResolved := tradeBias == "Long" ? entry - atrMult * atrVal : entry + atrMult * atrVal

// ----------------------------------------------------------------------------
// 4. INSTRUMENT VALUE-PER-POINT (the cross-asset core)
//    valuePerPt = currency change, in quote currency, for a 1.0 price move on
//    1 unit/contract. Futures use the contract point value; stocks, crypto,
//    index and forex (priced per unit of base currency) are 1.0 in quote terms.
// ----------------------------------------------------------------------------
symType   = syminfo.type
pv        = syminfo.pointvalue
isFutures = symType == "futures"
isForex   = symType == "forex"
isKnown   = symType == "stock" or symType == "crypto" or symType == "index" or symType == "fund" or isFutures or isForex

valuePerPt    = isFutures ? pv : 1.0
contractKnown = isFutures ? (not na(pv) and pv > 0) : true

unitLabel = isFutures ? "contracts" : isForex ? "units" : symType == "crypto" ? "coins" : "shares"

// ----------------------------------------------------------------------------
// 5. VALIDATION
// ----------------------------------------------------------------------------
validInputs = accountSize > 0 and riskPct > 0 and not na(entry) and entry > 0 and not na(stopResolved) and stopResolved > 0 and entry != stopResolved
showSize    = validInputs and contractKnown and isKnown

isLong     = entry > stopResolved
stopDist   = math.abs(entry - stopResolved)
riskAmount = accountSize * riskPct / 100.0

// ----------------------------------------------------------------------------
// 6. POSITION SIZE (rounded DOWN to the instrument step) AND METRICS
// ----------------------------------------------------------------------------
rawQty = (showSize and stopDist > 0 and valuePerPt > 0) ? riskAmount / (stopDist * valuePerPt) : na
qty    = na(rawQty) ? na : (qtyStep > 0 ? math.floor(rawQty / qtyStep) * qtyStep : rawQty)

hasTarget         = not na(target) and target > 0
targetOnRightSide = hasTarget and (isLong ? target > entry : target < entry)
rewardDist        = hasTarget ? math.abs(target - entry) : na
rr                = (hasTarget and targetOnRightSide and stopDist > 0) ? rewardDist / stopDist : na

riskDollars   = na(qty) ? na : qty * stopDist * valuePerPt
rewardDollars = (na(qty) or not targetOnRightSide) ? na : qty * rewardDist * valuePerPt
notional      = na(qty) ? na : qty * entry * valuePerPt
pctRisked     = na(riskDollars) ? na : riskDollars / accountSize * 100.0
pctDeployed   = na(notional) ? na : notional / accountSize * 100.0
stopDistPct   = (showSize and entry > 0) ? stopDist / entry * 100.0 : na
lots          = isForex and not na(qty) ? qty / 100000.0 : na

// ----------------------------------------------------------------------------
// 7. WARNINGS & NOTES (integrity is the point)
// ----------------------------------------------------------------------------
notes = array.new<string>()
if accountSize <= 0
    array.push(notes, "⚠ Account size must be > 0")
if riskPct <= 0
    array.push(notes, "⚠ Risk % must be > 0")
if na(entry) or entry <= 0
    array.push(notes, "⚠ Place a valid entry")
if na(stopResolved) or stopResolved <= 0
    array.push(notes, "⚠ Place a valid stop")
if not na(entry) and not na(stopResolved) and entry == stopResolved
    array.push(notes, "⚠ Entry and stop are equal")
if not isKnown
    array.push(notes, "⚠ Unsupported instrument — verify contract specs")
if isFutures and not contractKnown
    array.push(notes, "⚠ Verify contract specs (point value unavailable)")
if hasTarget and not targetOnRightSide
    array.push(notes, "⚠ Target is on the wrong side of entry — R:R not shown")
if isForex
    array.push(notes, "ℹ Forex: figures in " + syminfo.currency + "; verify if your account currency differs")
if not na(rr) and rr < 1.0
    array.push(notes, "ℹ R:R below 1 (informational only)")
notesText = array.size(notes) > 0 ? array.join(notes, "\n") : "✓ Inputs valid"

// ----------------------------------------------------------------------------
// 8. ON-CHART ZONES
// ----------------------------------------------------------------------------
var box  riskBox   = na
var box  rewardBox = na
var line entryLn   = na
var line stopLn    = na
var line targetLn  = na

if barstate.islast
    // clear previous drawings
    if not na(riskBox)
        box.delete(riskBox)
        riskBox := na
    if not na(rewardBox)
        box.delete(rewardBox)
        rewardBox := na
    if not na(entryLn)
        line.delete(entryLn)
        entryLn := na
    if not na(stopLn)
        line.delete(stopLn)
        stopLn := na
    if not na(targetLn)
        line.delete(targetLn)
        targetLn := na

    if showZones and showSize
        leftX  = bar_index - 3
        rightX = bar_index + 25
        rTop   = math.max(entry, stopResolved)
        rBot   = math.min(entry, stopResolved)
        riskBox := box.new(leftX, rTop, rightX, rBot, border_color = color.new(color.red, 40), bgcolor = color.new(color.red, 85))
        if targetOnRightSide
            gTop = math.max(entry, target)
            gBot = math.min(entry, target)
            rewardBox := box.new(leftX, gTop, rightX, gBot, border_color = color.new(color.green, 40), bgcolor = color.new(color.green, 85))
        entryLn := line.new(leftX, entry, rightX, entry, color = color.gray, style = line.style_solid, width = 1)
        stopLn  := line.new(leftX, stopResolved, rightX, stopResolved, color = color.red, style = line.style_dashed, width = 1)
        if targetOnRightSide
            targetLn := line.new(leftX, target, rightX, target, color = color.green, style = line.style_dashed, width = 1)

// ----------------------------------------------------------------------------
// 8b. DASHBOARD THEME (readable on dark AND light; Auto matches the chart, or
//     the user overrides). chart.fg_color / chart.bg_color track the user's
//     current TradingView theme, so "Auto" is always legible.
// ----------------------------------------------------------------------------
dashText = switch dashTheme
    "Dark"   => color.new(color.white, 0)
    "Light"  => color.new(#131722, 0)
    "Custom" => dashTextCust
    => chart.fg_color
dashPanel = switch dashTheme
    "Dark"   => color.new(#1e222d, 8)
    "Light"  => color.new(#ffffff, 8)
    "Custom" => dashBgCust
    => color.new(chart.bg_color, 8)
dashHdr = color.from_gradient(0.22, 0.0, 1.0, dashPanel, dashText)
dashLbl = color.from_gradient(0.10, 0.0, 1.0, dashPanel, dashText)

// ----------------------------------------------------------------------------
// 9. DASHBOARD TABLE
// ----------------------------------------------------------------------------
tablePosition = switch tblPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table dash = na

if barstate.islast
    if showTable and na(dash)
        dash := table.new(tablePosition, 2, 12, border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)
    if not showTable and not na(dash)
        table.delete(dash)
        dash := na

    if showTable and not na(dash)
        txtC   = dashText
        hdrBg  = dashHdr
        lblBg  = dashLbl
        noteC  = array.size(notes) > 0 ? #e58900 : #2e9e4f

        dirStr  = not showSize ? "—" : (isLong ? "LONG" : "SHORT")
        sizeStr = na(qty) ? "—" : isForex ? (fmtNum(qty, 0) + " units (" + fmtNum(lots, 2) + " lots)") : (fmtNum(qty, 6) + " " + unitLabel)
        stopStr = (na(stopDist) or not showSize) ? "—" : fmtNum(stopDist, 6) + " (" + fmtNum(stopDistPct, 2) + "%)"

        // header
        table.cell(dash, 0, 0, "Honest Trade Planner", text_color = txtC, text_size = size.small, bgcolor = hdrBg, text_halign = text.align_left)
        table.cell(dash, 1, 0, syminfo.currency, text_color = txtC, text_size = size.small, bgcolor = hdrBg, text_halign = text.align_right)
        // metrics
        table.cell(dash, 0, 1, "Direction", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 1, dirStr, text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 2, "Position size", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 2, sizeStr, text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Risk $", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 3, fmtNum(riskDollars, 2), text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 4, "% of account risked", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 4, na(pctRisked) ? "—" : fmtNum(pctRisked, 2) + "%", text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Reward $", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 5, fmtNum(rewardDollars, 2), text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 6, "R : R", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 6, na(rr) ? "—" : fmtNum(rr, 2), text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Stop distance", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 7, stopStr, text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 8, "Notional", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 8, fmtNum(notional, 2), text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 9, "% of account deployed", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 9, na(pctDeployed) ? "—" : fmtNum(pctDeployed, 2) + "%", text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        table.cell(dash, 0, 10, "Max loss (after round-down)", text_color = txtC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 10, fmtNum(riskDollars, 2), text_color = txtC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
        // notes (status-colored: green = valid, amber = warnings)
        table.cell(dash, 0, 11, "Notes", text_color = noteC, text_size = size.small, bgcolor = lblBg, text_halign = text.align_left)
        table.cell(dash, 1, 11, notesText, text_color = noteC, text_size = size.small, bgcolor = dashPanel, text_halign = text.align_right)
````
