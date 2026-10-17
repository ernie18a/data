# Risk Manager & Position Sizer [martineye15]

- url: https://www.tradingview.com/script/OBENNZdw-Risk-Manager-Position-Sizer-martineye15/
- type: indicator
- pine_id: PUB;e691843888194d06a5fae0022234e113
- version: 1.0

## Description

Prop Firm Risk Manager & Position Sizer — a position-size calculator and rule checker built for funded-account and challenge traders. Place your entry, stop-loss and take-profit on the chart, and the panel returns the exact lot size for your chosen risk, then checks that trade against your prop-firm rules before you take it.

THE CORE IDEA: RISK IS FIXED, LOT SIZE FLOATS
Risk money = account size x risk % (or a fixed cash amount). Lot size = risk money / (stop distance x value per lot + commission). Widening the stop shrinks the position; tightening it grows the position. The money at risk never changes. Sizes are rounded DOWN to your broker's lot step, so actual risk never exceeds planned risk.

TRADE LEVELS
Entry, stop-loss and take-profit are interactive price inputs — click to place them when you add the indicator, then drag the price lines to re-plan and watch every number update live. Entry can follow the current price (market) or sit at a placed level (pending). Direction is derived from the stop's side of entry, or forced long/short to validate your geometry. Optionally, an ATR module sets the stop and target automatically at entry -/+ ATR x multiplier, using the chart timeframe or a higher one, and either the live or the last closed bar's ATR.

ACCOUNT & INSTRUMENT
Set your account size, account currency and risk (percent of account or a fixed cash amount). If the symbol's quote currency differs from your account currency, a conversion rate is fetched automatically (direct pair first, then inverse) and a warning appears if neither resolves. Broker specs are fully adjustable: contract size (auto-derived or manual, for the many CFD symbols whose specs differ from the exchange's), lot step, minimum and maximum lot, and round-trip commission per lot, which is treated as part of the loss. A manual lot override works in reverse: enter a size you already have in mind and the panel tells you the risk money and risk percentage it actually carries.

PROP-FIRM RULE ENGINE
Enter your firm's limits — maximum daily loss, maximum total drawdown, per-trade risk cap, maximum lots, maximum portfolio open risk, and profit target (typical challenge rules are 5% daily, 10% total, 10% target). Log how much you have already lost today and your running P/L, and the panel shows:
- Remaining daily loss budget, and whether this trade fits inside it
- How many identical losing trades it would take to breach the daily limit
- Remaining total drawdown buffer, reduced by any running loss
- Pass/fail on the per-trade risk cap, the lot cap, and combined open risk across positions
- Distance to your profit target, in money and in R multiples of this trade's risk
- A minimum risk:reward check
With hard block enabled, any failed check turns the panel header red and shows DO NOT TRADE.

PANEL, DRAWINGS & ALERTS
A dashboard table (four corner positions, normal or compact, dark or light) shows direction, levels, lot size, units, risk and reward in money and percent, risk:reward, per-pip value for the sized position, every rule check, and a plain-language warnings list explaining anything that is wrong or clamped. Entry, stop and target are drawn as labelled lines with shaded risk and reward zones. Alerts are available for entry, stop or target touches — with the computed lot size and risk in the message — and for any rule check flipping to fail.

HOW TO USE
Add the indicator, click to place entry, stop and target. Set your account size, currency and risk percentage, then enter your broker's contract size, lot step and commission (check these against your own account — CFD specs vary between brokers). Enter your firm's daily loss, drawdown, target and cap rules once. Before each trade, drag the levels to your plan, update the loss-taken-today and current P/L fields, read the lot size, and only take the trade if every check passes.

WHAT MAKES IT DIFFERENT
Most position sizers stop at the lot size. This one continues into the rules that actually end funded accounts: it treats the daily loss budget, the drawdown buffer and total open risk as constraints the trade must fit inside, tells you how many more losses you can survive today, expresses your remaining profit target in R multiples of the position in front of you, and can visibly block the trade when a rule fails. Commission is priced into the size, results are rounded conservatively, and every clamp or failure is explained in plain language rather than silently applied.

IMPORTANT LIMITATIONS — PLEASE READ
Pine Script cannot access your broker account. Account size, loss already taken today, current P/L and risk committed to other open positions are MANUAL inputs — the tool is only as accurate as what you enter, so keep them current during the session. It cannot read your live balance, equity, open positions, spread, swap or margin, and it cannot place, modify or close orders — this is a calculator and a checklist, not an execution tool. TradingView's symbol specifications may not match your prop firm's CFD specifications, which is what the manual contract size override is for: verify the lot size against your broker before trading. The total drawdown check assumes a static limit measured from the initial balance and does not model trailing drawdown. Figures update live with the current bar (ATR in "Current" mode changes as the bar forms); use the "Previous" ATR setting for stable values.

This is a calculation and decision-support tool. It is not a strategy, generates no trade signals, and is not financial advice. Always verify position sizes against your own broker and risk rules.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════════════════
//  PROP FIRM RISK MANAGER & POSITION SIZER
//
//  Invariant:  RISK STAYS FIXED — LOT SIZE FLOATS.
//      Risk money      = AccountSize × Risk%          (or a fixed cash amount)
//      SL distance     = |Entry − StopLoss|
//      Value per 1.00  = ContractSize (per lot), converted to account currency
//      Lots            = Risk money ÷ (SL distance × value-per-1.00-per-lot + commission)
//  Widening the SL shrinks the lots; tightening it grows them. Risk money never changes.
//  Lots are rounded DOWN to the lot step so actual risk never exceeds planned risk.
//
//  HONEST LIMITATIONS (Pine cannot fake these — read before trusting the numbers):
//   • Pine cannot read your real broker balance, equity, open positions, spread, swap or
//     margin. Account size, open risk, today's loss and P/L are MANUAL inputs.
//   • Entry/SL/TP are input.price() levels: drag the interactive price line TradingView
//     renders for each input, or edit them in Settings → Inputs. They are not free-floating
//     MT4-style objects, but dragging them recalculates everything live.
//   • This is an indicator — it cannot place, modify or close trades.
//   • TradingView's symbol specs (point value, contract size) may differ from your prop
//     firm's CFD specs — that is exactly what the "Manual contract size" override is for.
// ════════════════════════════════════════════════════════════════════════════════════════
indicator("Prop Firm Risk Manager & Position Sizer", shorttitle = "PropSizer",
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 1 — INPUTS
// ════════════════════════════════════════════════════════════════════════════════════════
GRP_LVL = "① Trade levels"
GRP_ATR = "② ATR-based SL/TP"
GRP_ACC = "③ Account & risk"
GRP_INS = "④ Instrument / broker specs"
GRP_PRP = "⑤ Prop-firm rules"
GRP_PNL = "⑥ Panel & drawings"
GRP_ALR = "⑦ Alerts"

// ── ① Trade levels ──────────────────────────────────────────────────────────────────────
entryType = input.string("Pending", "Entry type", options = ["Market", "Pending"], group = GRP_LVL,
     tooltip = "Market: entry follows the current price (the Entry line input is ignored). Pending: the placed Entry line is used, like a limit/stop order.")
entryIn   = input.price(0.0, "Entry price", confirm = true, inline = "entryPt", group = GRP_LVL,
     tooltip = "Click on the chart to place the Entry level when adding the indicator. Afterwards drag the interactive entry point or edit the value in Settings → Inputs.")
anchorTime = input.time(0, "@ time", confirm = true, inline = "entryPt", group = GRP_LVL,
     tooltip = "Captured by the SAME click as the Entry price (no extra click). This is the horizontal position of the whole drawing block: DRAG THE ENTRY POINT LEFT/RIGHT to move the lines, labels and risk/reward zones anywhere on the chart; drag it up/down to change the entry price.")
slIn      = input.price(0.0, "Stop-Loss price", confirm = true, group = GRP_LVL,
     tooltip = "Click to place the Stop-Loss. Dragging it FURTHER from entry SHRINKS the lot size; dragging it CLOSER GROWS the lot size — the money at risk never changes.")
tpIn      = input.price(0.0, "Take-Profit price", confirm = true, group = GRP_LVL,
     tooltip = "Click to place the Take-Profit. Set it to 0 (or leave it on the wrong side) to trade without a TP — reward and R:R will show as '—'.")
dirMode   = input.string("Auto", "Direction", options = ["Auto", "Long", "Short"], group = GRP_LVL,
     tooltip = "Auto: SL below entry ⇒ Long, SL above entry ⇒ Short (like the EarnForex EA). Force Long/Short to validate geometry instead — a warning is shown if the SL sits on the wrong side of entry.")

// ── ② ATR module ────────────────────────────────────────────────────────────────────────
useAtr     = input.bool(false, "Use ATR-based SL/TP", group = GRP_ATR,
     tooltip = "When ON, SL and TP are computed as entry ∓/± ATR×multiplier and the placed SL/TP lines are ignored. Direction comes from the Direction input (Auto falls back to the placed SL side, else Long).")
atrLen     = input.int(14, "ATR period", minval = 1, group = GRP_ATR, tooltip = "Length of the Average True Range used for SL/TP distances.")
atrSlMult  = input.float(1.5, "SL multiplier", minval = 0.01, step = 0.1, group = GRP_ATR, tooltip = "SL distance = ATR × this multiplier.")
atrTpMult  = input.float(3.0, "TP multiplier", minval = 0.0, step = 0.1, group = GRP_ATR, tooltip = "TP distance = ATR × this multiplier. Set 0 to disable the ATR take-profit.")
atrBarMode = input.string("Current", "ATR value from", options = ["Current", "Previous"], group = GRP_ATR,
     tooltip = "Current: ATR of the live bar (changes while the bar forms). Previous: ATR of the last closed bar (stable, like the EA's 'previous bar' option).")
atrTf      = input.timeframe("", "ATR timeframe", group = GRP_ATR,
     tooltip = "Optional higher timeframe for the ATR (e.g. 1D on an H1 chart). Leave empty to use the chart timeframe. Fetched with request.security, no lookahead.")

// ── ③ Account & risk ────────────────────────────────────────────────────────────────────
acctSize  = input.float(100000.0, "Account size", minval = 0.01, group = GRP_ACC,
     tooltip = "Your prop-firm account balance (or the balance risk should be computed from). Pine CANNOT read the real broker balance — keep this up to date manually.")
acctCcy   = input.string("USD", "Account currency", options = ["USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD", "SGD", "USDT"], group = GRP_ACC,
     tooltip = "Currency your account is denominated in. If it differs from the symbol's quote currency, a conversion pair is fetched automatically (direct pair first, then inverse). If neither resolves, factor 1.0 is used and a warning is shown.")
riskMode  = input.string("% of account", "Risk mode", options = ["% of account", "Fixed money"], group = GRP_ACC,
     tooltip = "% of account: risk = account × risk%. Fixed money: risk the cash amount below regardless of account size.")
riskPct   = input.float(1.0, "Risk % per trade", minval = 0.0, step = 0.25, group = GRP_ACC,
     tooltip = "Percent of the account risked between entry and SL. Quick presets used by most prop traders: 0.25 / 0.5 / 1 / 2 %. This input's step is 0.25, so the +/− arrows walk through those presets.")
riskFixed = input.float(1000.0, "Fixed risk (money)", minval = 0.0, group = GRP_ACC,
     tooltip = "Cash amount (in account currency) to risk when Risk mode = Fixed money.")
manualLotsOn = input.bool(false, "Fixed lot size (manual override)", group = GRP_ACC,
     tooltip = "ON: use the lot size below instead of the computed one. The panel then REVERSE-calculates and displays the risk money and risk % that size actually carries — useful for checking a size you already have in mind.")
manualLots   = input.float(1.0, "Manual lots", minval = 0.0, step = 0.01, group = GRP_ACC,
     tooltip = "Lot size used when the manual override is ON. Still rounded down to the lot step and clamped to min/max lots.")

// ── ④ Instrument / broker specs ─────────────────────────────────────────────────────────
csMode   = input.string("Auto", "Contract size", options = ["Auto", "Manual"], group = GRP_INS,
     tooltip = "Auto derives the per-point value from TradingView's symbol info (syminfo.pointvalue / mintick / type): forex ⇒ 100,000 units per lot; other symbols ⇒ 1 contract per lot at syminfo.pointvalue. Prop-firm CFD specs often differ — switch to Manual and enter YOUR broker's contract size (forex 100,000; gold XAUUSD 100 oz; most index/crypto CFDs 1).")
csManual = input.float(100000.0, "Manual contract size (units per lot)", minval = 0.0000001, group = GRP_INS,
     tooltip = "Units controlled by 1.00 lot. The value of a 1.0 price move per lot equals this number, in the symbol's quote currency. Examples: EURUSD 100,000 → a 0.0001 move per lot = 10 USD. XAUUSD 100 → a 1.00 move per lot = 100 USD. US30 CFD 1 → a 1.0 move per lot = 1 USD.")
lotStep  = input.float(0.01, "Lot step", minval = 0.0000001, group = GRP_INS,
     tooltip = "Broker volume step. The computed size is rounded DOWN to this step so actual risk never exceeds planned risk.")
minLot   = input.float(0.01, "Min lot", minval = 0.0, group = GRP_INS,
     tooltip = "Broker minimum volume. If the computed size falls below it, the size is clamped UP to min lot and a warning is shown (actual risk then exceeds the plan).")
maxLot   = input.float(100.0, "Max lot", minval = 0.0000001, group = GRP_INS,
     tooltip = "Broker maximum volume per order. The computed size is capped here (with a warning).")
commRT   = input.float(0.0, "Commission per lot, round-trip", minval = 0.0, group = GRP_INS,
     tooltip = "Round-trip commission per 1.00 lot in ACCOUNT currency (e.g. 7 for a typical 7 USD/lot raw-spread account). It is treated as part of the loss, exactly like the EarnForex 'Commission' input: lots = risk ÷ (SL-distance value + commission).")

// ── ⑤ Prop-firm rules ───────────────────────────────────────────────────────────────────
maxDailyPct   = input.float(5.0, "Max daily loss %", minval = 0.0, step = 0.5, group = GRP_PRP,
     tooltip = "FTMO-style daily loss limit as % of account size (FTMO and most firms: 5%).")
maxTotalPct   = input.float(10.0, "Max total drawdown %", minval = 0.0, step = 0.5, group = GRP_PRP,
     tooltip = "Maximum overall loss limit as % of account size (FTMO and most firms: 10%). Assumed static, measured from initial balance; combined with 'Current P/L %' below to compute the remaining buffer.")
lossTodayVal  = input.float(0.0, "Loss already taken today", minval = 0.0, group = GRP_PRP,
     tooltip = "How much you have ALREADY lost today (enter a positive number). Unit selected below. Pine cannot read this from the broker — update it manually during the day.")
lossTodayUnit = input.string("Money", "…entered as", options = ["Money", "% of account"], group = GRP_PRP,
     tooltip = "Whether the value above is account-currency money or % of account size.")
maxTradePct   = input.float(2.0, "Max risk per trade % (cap)", minval = 0.0, step = 0.25, group = GRP_PRP,
     tooltip = "Personal per-trade risk cap. A FAIL is shown if the selected risk exceeds it.")
maxLotsCap    = input.float(20.0, "Max lots cap", minval = 0.0, group = GRP_PRP,
     tooltip = "Hard cap on position size imposed by your firm or your own rules. FAIL if the computed size exceeds it.")
maxOpenPct    = input.float(5.0, "Max open risk % (portfolio)", minval = 0.0, step = 0.5, group = GRP_PRP,
     tooltip = "Maximum total risk allowed across ALL open trades, as % of account.")
openOtherPct  = input.float(0.0, "Risk open in other trades %", minval = 0.0, step = 0.25, group = GRP_PRP,
     tooltip = "Risk currently committed to other open positions (% of account). Manual input — Pine cannot see your open trades. This trade must fit inside Max open risk % minus this.")
targetPct     = input.float(10.0, "Profit target %", minval = 0.0, step = 0.5, group = GRP_PRP,
     tooltip = "Challenge/verification profit target as % of account (FTMO phase 1: 10%).")
curPlPct      = input.float(0.0, "Current P/L % (from initial balance)", step = 0.25, group = GRP_PRP,
     tooltip = "Your running profit (positive) or loss (negative) as % of INITIAL account size. Used for the distance-to-target helper and the total-drawdown buffer. Manual input.")
minRR         = input.float(2.0, "Minimum R:R", minval = 0.0, step = 0.5, group = GRP_PRP,
     tooltip = "The R:R row turns green when reward:risk ≥ this value (default 1:2).")
hardBlock     = input.bool(true, "Hard block on failed checks", group = GRP_PRP,
     tooltip = "When ON and any prop-firm check FAILS (or the trade geometry is invalid), the panel header turns red and shows DO NOT TRADE.")

// ── ⑥ Panel & drawings ──────────────────────────────────────────────────────────────────
pnlPos    = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GRP_PNL, tooltip = "Corner of the chart where the dashboard is anchored.")
pnlSize   = input.string("Normal", "Panel size", options = ["Normal", "Compact"], group = GRP_PNL, tooltip = "Compact hides secondary rows (units, per-pip value, some prop rows) and uses smaller text.")
pnlTheme  = input.string("Dark", "Theme", options = ["Dark", "Light"], group = GRP_PNL, tooltip = "Dark or light dashboard colors.")
showZones = input.bool(true, "Shade risk/reward zones", group = GRP_PNL, tooltip = "Translucent red box between entry and SL (risk), translucent green box between entry and TP (reward).")
extendRight = input.bool(true, "Extend lines to the right", group = GRP_PNL, tooltip = "ON: Entry/SL/TP lines run from the anchor to the right edge of the chart (EA-style). OFF: the lines stay a fixed-width block around the anchor point, so they don't stripe across the whole chart.")
colEntry  = input.color(color.rgb(33, 150, 243), "Entry color", group = GRP_PNL, tooltip = "Color of the entry line and label.")
colSL     = input.color(color.rgb(239, 83, 80), "Stop-Loss color", group = GRP_PNL, tooltip = "Color of the SL line/label and the risk zone.")
colTP     = input.color(color.rgb(38, 166, 154), "Take-Profit color", group = GRP_PNL, tooltip = "Color of the TP line/label and the reward zone.")

// ── ⑦ Alerts ────────────────────────────────────────────────────────────────────────────
alertLevels = input.bool(false, "Alert on level touches", group = GRP_ALR,
     tooltip = "Fires a dynamic alert() when price touches the Entry (pending only), SL or TP level. The message includes the computed lot size and risk figures. Create the alert with condition 'Any alert() function call'.")
alertRisk   = input.bool(false, "Alert on risk-parameters breach", group = GRP_ALR,
     tooltip = "Fires once when any prop-firm check flips to FAIL (daily budget, per-trade cap, lots cap, open-risk cap, drawdown buffer).")

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 2 — INSTRUMENT MATH
// ════════════════════════════════════════════════════════════════════════════════════════
pointSize = syminfo.mintick                                     // 1 point = smallest price increment
isForex   = syminfo.type == "forex"
// Pip: on 5/3-digit forex quotes a pip is 10 points; elsewhere pip = point.
pipSize   = isForex and (pointSize == 0.00001 or pointSize == 0.001) ? pointSize * 10 : pointSize

// Contract size = units controlled by 1.00 lot.
contractSize = csMode == "Manual" ? csManual : isForex ? 100000.0 : 1.0
// Money (in the SYMBOL's currency) produced by a 1.0 price-unit move, per 1.00 lot.
//   Auto  : syminfo.pointvalue × contractSize  (forex: 1 × 100,000; futures/CFD: pointvalue × 1)
//   Manual: the contract size itself (direct-quoted instruments: 1.0 move × units = quote money)
moneyPerUnitMove = csMode == "Manual" ? csManual : syminfo.pointvalue * contractSize

// ── Currency conversion (quote currency → account currency) ─────────────────────────────
quoteCcy = syminfo.currency
needConv = quoteCcy != acctCcy
// Try the direct pair (QUOTE+ACCT ⇒ multiply), then the inverse (ACCT+QUOTE ⇒ divide).
// ignore_invalid_symbol returns na instead of raising an error when a pair does not exist.
pxDirect  = request.security(quoteCcy + acctCcy, timeframe.period, close, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)
pxInverse = request.security(acctCcy + quoteCcy, timeframe.period, close, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)
convFactor = not needConv ? 1.0 :
     not na(pxDirect)  and pxDirect  > 0 ? pxDirect :
     not na(pxInverse) and pxInverse > 0 ? 1.0 / pxInverse : 1.0
convFailed = needConv and (na(pxDirect) or pxDirect <= 0) and (na(pxInverse) or pxInverse <= 0)

// ── ATR (chart or higher timeframe, current or previous bar, no lookahead) ──────────────
atrTfEff   = atrTf == "" ? timeframe.period : atrTf
usePrevAtr = atrBarMode == "Previous"
atrVal     = request.security(syminfo.tickerid, atrTfEff, usePrevAtr ? ta.atr(atrLen)[1] : ta.atr(atrLen), lookahead = barmerge.lookahead_off)

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 3 — SIZING ENGINE
// ════════════════════════════════════════════════════════════════════════════════════════
// Effective entry
entryPx = entryType == "Market" ? close : entryIn
entryOk = not na(entryPx) and entryPx > 0

// Direction: explicit input wins; Auto derives it from the placed SL side (SL below ⇒ long).
dirFromSl = not na(slIn) and slIn > 0 and entryOk ? (slIn < entryPx ? 1 : -1) : 1
dir = dirMode == "Long" ? 1 : dirMode == "Short" ? -1 : dirFromSl

// SL / TP (the ATR module overrides the placed lines when enabled)
slPx = useAtr ? entryPx - dir * atrVal * atrSlMult : slIn
tpPx = useAtr ? (atrTpMult > 0 ? entryPx + dir * atrVal * atrTpMult : na) : tpIn

// Geometry validation
slPlaced    = not na(slPx) and slPx > 0
slWrongSide = slPlaced and entryOk and ((dir == 1 and slPx >= entryPx) or (dir == -1 and slPx <= entryPx))
slDist      = slPlaced and entryOk and not slWrongSide ? math.abs(entryPx - slPx) : na
slZero      = slPlaced and entryOk and not slWrongSide and slDist == 0

tpPlaced    = not na(tpPx) and tpPx > 0
tpWrongSide = tpPlaced and entryOk and ((dir == 1 and tpPx <= entryPx) or (dir == -1 and tpPx >= entryPx))
tpDist      = tpPlaced and entryOk and not tpWrongSide ? math.abs(tpPx - entryPx) : na

// Distances in points / pips
slPoints = na(slDist) ? na : slDist / pointSize
slPips   = na(slDist) ? na : slDist / pipSize
tpPoints = na(tpDist) ? na : tpDist / pointSize
tpPips   = na(tpDist) ? na : tpDist / pipSize

// Planned risk money (account currency)
plannedRisk = riskMode == "Fixed money" ? riskFixed : acctSize * riskPct / 100.0

// Per-lot loss between entry and SL, in ACCOUNT currency, commission included
riskPerLotEx = na(slDist) ? na : slDist * moneyPerUnitMove * convFactor   // excl. commission
riskPerLot   = na(riskPerLotEx) ? na : riskPerLotEx + commRT              // incl. round-trip commission

// Round DOWN to the lot step; the epsilon fixes float-floor artefacts (5.00 → 4.99).
f_stepDown(x) => math.floor(x / lotStep + 1e-9) * lotStep

lotsRaw      = not na(riskPerLot) and riskPerLot > 0 ? plannedRisk / riskPerLot : na
lotsStepped  = na(lotsRaw) ? na : f_stepDown(lotsRaw)
belowMinLot  = not na(lotsStepped) and lotsStepped < minLot
aboveMaxLot  = not na(lotsStepped) and lotsStepped > maxLot
lotsComputed = na(lotsStepped) ? na : math.min(math.max(lotsStepped, minLot), maxLot)

// Manual override: fixed lots ⇒ reverse-calculate the risk this size actually carries
lotsManual = math.min(math.max(f_stepDown(manualLots), minLot), maxLot)
lots       = manualLotsOn ? lotsManual : lotsComputed
units      = na(lots) ? na : lots * contractSize

// Actual (post-rounding / post-override) risk & reward in account currency
actualRisk    = na(lots) or na(riskPerLot) ? na : lots * riskPerLot
actualRiskPct = na(actualRisk) or acctSize <= 0 ? na : actualRisk / acctSize * 100.0
rewardMoney   = na(lots) or na(tpDist) ? na : lots * tpDist * moneyPerUnitMove * convFactor - lots * commRT
rewardPct     = na(rewardMoney) or acctSize <= 0 ? na : rewardMoney / acctSize * 100.0
rr            = na(tpDist) or na(slDist) or slDist == 0 ? na : tpDist / slDist
pipValuePos   = na(lots) ? na : pipSize * moneyPerUnitMove * convFactor * lots  // money per pip for the sized position

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 4 — PROP-FIRM CHECKS
// ════════════════════════════════════════════════════════════════════════════════════════
lossToday      = lossTodayUnit == "% of account" ? acctSize * lossTodayVal / 100.0 : lossTodayVal
dailyBudget    = acctSize * maxDailyPct / 100.0
dailyRemaining = dailyBudget - lossToday
chkDaily       = not na(actualRisk) and actualRisk <= dailyRemaining + 1e-9
// Identical losing trades in a row that would hit/breach the daily limit
tradesToBreach = na(actualRisk) or actualRisk <= 0 ? na : math.max(0, math.ceil(dailyRemaining / actualRisk))

// Total drawdown buffer: static limit from initial balance, reduced by any running loss
totalRemPct   = maxTotalPct + math.min(curPlPct, 0.0)
totalRemMoney = acctSize * totalRemPct / 100.0
chkTotal      = not na(actualRisk) and actualRisk <= totalRemMoney + 1e-9

chkTradeCap = not na(actualRiskPct) and actualRiskPct <= maxTradePct + 1e-9
chkLots     = not na(lots) and lots <= maxLotsCap + 1e-9
chkOpen     = not na(actualRiskPct) and openOtherPct + actualRiskPct <= maxOpenPct + 1e-9
chkRR       = not na(rr) and rr >= minRR

// Profit-target helper
remToTargetPct   = math.max(0.0, targetPct - curPlPct)
remToTargetMoney = acctSize * remToTargetPct / 100.0
rNeeded          = na(actualRisk) or actualRisk <= 0 ? na : remToTargetMoney / actualRisk

geomInvalid = not entryOk or not slPlaced or slWrongSide or slZero or na(lots)
anyFail     = geomInvalid or not chkDaily or not chkTotal or not chkTradeCap or not chkLots or not chkOpen
doNotTrade  = hardBlock and anyFail

// ════════════════════════════════════════════════════════════════════════════════════════
//  FORMAT HELPERS
// ════════════════════════════════════════════════════════════════════════════════════════
// Pine v6 has no built-in thousands-separator constant for str.tostring(), so we group manually:
// f_comma(12345.678, 2) → "12,345.68"   |   f_comma(-1234, 0) → "-1,234"
f_comma(x, dec) =>
    float v   = math.round(math.abs(x), dec)
    bool  neg = x < 0 and v > 0
    int   iInt  = math.floor(v + 1e-9)
    int   scale = int(math.round(math.pow(10, dec)))
    int   fd    = math.round((v - iInt) * scale)
    if dec > 0 and fd >= scale             // carry a rounded-up fraction (e.g. 1.999 → 2.00)
        fd   := 0
        iInt += 1
    string s = str.tostring(iInt)
    int    n = str.length(s)
    string out = ""
    for i = 0 to n - 1
        out := out + str.substring(s, i, i + 1)
        if i < n - 1 and (n - 1 - i) % 3 == 0
            out := out + ","
    string fs = str.tostring(fd)
    for _ = str.length(fs) to dec - 1
        fs := "0" + fs
    (neg ? "-" : "") + out + (dec > 0 ? "." + fs : "")

f_fmtPx(p) => str.tostring(p, format.mintick)
f_money(x) => na(x) ? "—" : f_comma(x, 2)
f_pct(x)   => na(x) ? "—" : str.tostring(math.round(x, 2)) + "%"
f_lots(x)  => na(x) ? "—" : f_comma(x, 2)
f_dist(pips, pts) => na(pips) ? "" : isForex ? f_comma(pips, 1) + " pips (" + f_comma(pts, 0) + " pts)" : f_comma(pts, 1) + " pts"

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 5 — DRAWINGS  (created/updated on the last bar only — CPU-light)
// ════════════════════════════════════════════════════════════════════════════════════════
var line  lnEntry  = na
var line  lnSL     = na
var line  lnTP     = na
var label lbEntry  = na
var label lbSL     = na
var label lbTP     = na
var box   bxRisk   = na
var box   bxReward = na

if barstate.islast
    // wipe & redraw — stays far below object limits (≤3 lines, ≤3 labels, ≤2 boxes alive)
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbTP)
    box.delete(bxRisk)
    box.delete(bxReward)

    // Horizontal position of the whole block:
    //  • If the Entry click captured a time anchor (anchorTime > 0), everything is drawn in
    //    TIME coordinates at that spot — drag the entry point left/right to move the section.
    //  • Fallback (anchor = 0, e.g. after pasting a new version without re-adding): pinned
    //    to the right edge like before.
    bool   useT  = anchorTime > 0
    int    msBar = timeframe.in_seconds(timeframe.period) * 1000
    int    xA    = useT ? anchorTime : math.max(0, bar_index - 40)          // block start
    int    xB    = useT ? anchorTime + 40 * msBar : bar_index               // line end (when not extending)
    int    xLab  = useT ? anchorTime + 52 * msBar : bar_index + 12          // label / zone edge
    string xm    = useT ? xloc.bar_time : xloc.bar_index
    string lnExt = extendRight ? extend.right : extend.none

    if entryOk
        lnEntry := line.new(xA, entryPx, xB, entryPx, xloc = xm, extend = lnExt, color = colEntry, width = 2)
        lbEntry := label.new(xLab, entryPx, "ENTRY " + (entryType == "Market" ? "(mkt) " : "") + f_fmtPx(entryPx), xloc = xm, style = label.style_label_left, color = color.new(colEntry, 20), textcolor = color.white, size = size.small)
    if slPlaced
        lnSL := line.new(xA, slPx, xB, slPx, xloc = xm, extend = lnExt, color = colSL, width = 2)
        lbSL := label.new(xLab, slPx, "SL " + f_fmtPx(slPx) + (na(slPips) ? "" : "  •  " + f_dist(slPips, slPoints)), xloc = xm, style = label.style_label_left, color = color.new(colSL, 20), textcolor = color.white, size = size.small)
    if tpPlaced and not tpWrongSide
        lnTP := line.new(xA, tpPx, xB, tpPx, xloc = xm, extend = lnExt, color = colTP, width = 2)
        lbTP := label.new(xLab, tpPx, "TP " + f_fmtPx(tpPx) + (na(tpPips) ? "" : "  •  " + f_dist(tpPips, tpPoints)) + (na(rr) ? "" : "  •  R " + str.tostring(math.round(rr, 2))), xloc = xm, style = label.style_label_left, color = color.new(colTP, 20), textcolor = color.white, size = size.small)
    if showZones and entryOk
        if slPlaced and not slWrongSide
            bxRisk := box.new(xA, math.max(entryPx, slPx), xLab, math.min(entryPx, slPx), xloc = xm, border_color = na, bgcolor = color.new(colSL, 88))
        if tpPlaced and not tpWrongSide
            bxReward := box.new(xA, math.max(entryPx, tpPx), xLab, math.min(entryPx, tpPx), xloc = xm, border_color = na, bgcolor = color.new(colTP, 88))

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 6 — PANEL (dashboard table)
// ════════════════════════════════════════════════════════════════════════════════════════
compact  = pnlSize == "Compact"
txtSz    = compact ? size.small : size.normal
isDark   = pnlTheme == "Dark"
cBg      = isDark ? color.rgb(20, 24, 35)    : color.rgb(250, 250, 252)
cBgAlt   = isDark ? color.rgb(28, 33, 46)    : color.rgb(240, 242, 246)
cTxt     = isDark ? color.rgb(209, 212, 220) : color.rgb(19, 23, 34)
cDim     = isDark ? color.rgb(140, 145, 160) : color.rgb(110, 115, 130)
cHead    = doNotTrade ? color.rgb(178, 24, 43) : (isDark ? color.rgb(41, 98, 255) : color.rgb(33, 150, 243))
cPass    = color.rgb(38, 166, 154)
cFail    = color.rgb(239, 83, 80)
cWarnBg  = isDark ? color.rgb(66, 44, 22)    : color.rgb(255, 243, 224)
cNone    = color.new(color.black, 100)       // transparent = "no background"
posTable = pnlPos == "Top right" ? position.top_right : pnlPos == "Top left" ? position.top_left : pnlPos == "Bottom right" ? position.bottom_right : position.bottom_left

f_pf(ok)    => ok ? "PASS ✓" : "FAIL ✗"
f_pfCol(ok) => ok ? cPass : cFail

// Adds one label/value row; returns the next row index.
f_row(tbl, row, lTxt, vTxt, lCol, vCol, bg, lSz, vSz) =>
    table.cell(tbl, 0, row, lTxt, text_color = lCol, bgcolor = bg, text_size = lSz, text_halign = text.align_left)
    table.cell(tbl, 1, row, vTxt, text_color = vCol, bgcolor = bg, text_size = vSz, text_halign = text.align_right)
    row + 1

// Adds one full-width (merged) row; returns the next row index.
f_sec(tbl, row, txt, tCol, bg, sz, halign) =>
    table.cell(tbl, 0, row, txt, text_color = tCol, bgcolor = bg, text_size = sz, text_halign = halign)
    table.merge_cells(tbl, 0, row, 1, row)
    row + 1

var table pnl = na

if barstate.islast
    table.delete(pnl)
    pnl := table.new(posTable, 2, 40, bgcolor = cBg, frame_width = 1, frame_color = color.new(cDim, 60), border_width = 1, border_color = color.new(cBg, 100))
    int r = 0

    // ── Header ──
    r := f_sec(pnl, r, doNotTrade ? "⛔ DO NOT TRADE" : "PROP FIRM RISK MANAGER", color.white, cHead, txtSz, text.align_center)

    // ── POSITION ──
    r := f_sec(pnl, r, "POSITION", cDim, cBgAlt, size.tiny, text.align_left)
    r := f_row(pnl, r, "Direction", (dir == 1 ? "LONG ▲" : "SHORT ▼") + (dirMode == "Auto" ? " (auto)" : ""), cDim, dir == 1 ? cPass : cFail, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Entry", entryOk ? f_fmtPx(entryPx) + (entryType == "Market" ? " (mkt)" : "") : "—", cDim, cTxt, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Stop-Loss", slPlaced ? f_fmtPx(slPx) + (na(slPips) ? "" : "  (" + f_dist(slPips, slPoints) + ")") : "—", cDim, slWrongSide ? cFail : cTxt, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Take-Profit", tpPlaced and not tpWrongSide ? f_fmtPx(tpPx) + (na(tpPips) ? "" : "  (" + f_dist(tpPips, tpPoints) + ")") : "—", cDim, cTxt, cNone, txtSz, txtSz)
    // Lot size — the headline number
    r := f_row(pnl, r, manualLotsOn ? "LOTS (manual)" : "LOT SIZE", f_lots(lots), cTxt, doNotTrade ? cFail : color.rgb(255, 193, 7), cBgAlt, txtSz, compact ? size.normal : size.large)
    if not compact
        r := f_row(pnl, r, "Units", na(units) ? "—" : f_comma(units, 0), cDim, cTxt, cNone, txtSz, txtSz)
    r := f_row(pnl, r, manualLotsOn ? "Risk (reverse-calc)" : "Risk", f_money(actualRisk) + " " + acctCcy + "  (" + f_pct(actualRiskPct) + ")", cDim, cFail, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Reward", na(rewardMoney) ? "—" : f_money(rewardMoney) + " " + acctCcy + "  (" + f_pct(rewardPct) + ")", cDim, cPass, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Risk : Reward", na(rr) ? "—" : "1 : " + str.tostring(math.round(rr, 2)), cDim, na(rr) ? cDim : chkRR ? cPass : cTxt, cNone, txtSz, txtSz)
    if not compact
        r := f_row(pnl, r, "Value per pip (position)", na(pipValuePos) ? "—" : f_money(pipValuePos) + " " + acctCcy, cDim, cTxt, cNone, txtSz, txtSz)

    // ── PROP FIRM ──
    r := f_sec(pnl, r, "PROP FIRM", cDim, cBgAlt, size.tiny, text.align_left)
    r := f_row(pnl, r, "Daily loss remaining", f_money(dailyRemaining) + " " + acctCcy, cDim, dailyRemaining > 0 ? cTxt : cFail, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Trade vs daily budget", f_pf(chkDaily), cDim, f_pfCol(chkDaily), cNone, txtSz, txtSz)
    if not compact
        r := f_row(pnl, r, "Losses to breach daily", na(tradesToBreach) ? "—" : str.tostring(tradesToBreach) + " trade(s)", cDim, na(tradesToBreach) ? cDim : tradesToBreach <= 2 ? cFail : cTxt, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Total DD remaining", f_money(totalRemMoney) + " " + acctCcy + "  (" + f_pct(totalRemPct) + ")", cDim, chkTotal ? cTxt : cFail, cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Risk-per-trade cap " + f_pct(maxTradePct), f_pf(chkTradeCap), cDim, f_pfCol(chkTradeCap), cNone, txtSz, txtSz)
    r := f_row(pnl, r, "Max lots cap " + f_lots(maxLotsCap), f_pf(chkLots), cDim, f_pfCol(chkLots), cNone, txtSz, txtSz)
    if not compact
        r := f_row(pnl, r, "Open risk " + f_pct(openOtherPct + nz(actualRiskPct)) + " / " + f_pct(maxOpenPct), f_pf(chkOpen), cDim, f_pfCol(chkOpen), cNone, txtSz, txtSz)
    r := f_row(pnl, r, "R:R ≥ " + str.tostring(minRR), na(rr) ? "—" : f_pf(chkRR), cDim, na(rr) ? cDim : f_pfCol(chkRR), cNone, txtSz, txtSz)
    if not compact
        r := f_row(pnl, r, "To target " + f_pct(remToTargetPct), f_money(remToTargetMoney) + " " + acctCcy + (na(rNeeded) ? "" : "  ≈ " + str.tostring(math.round(rNeeded, 1)) + " R"), cDim, cTxt, cNone, txtSz, txtSz)

    // ── WARNINGS ──
    warns = array.new_string()
    if not entryOk
        array.push(warns, "Entry price is not set / invalid")
    if not slPlaced
        array.push(warns, "Stop-Loss is not set — cannot size the position")
    if slWrongSide
        array.push(warns, "SL is on the WRONG side of entry for a " + (dir == 1 ? "long" : "short"))
    if slZero
        array.push(warns, "SL distance is 0 — cannot size the position")
    if tpPlaced and tpWrongSide
        array.push(warns, "TP is on the wrong side of entry — R:R shown as '—'")
    if not tpPlaced
        array.push(warns, "No TP set — reward and R:R unavailable")
    if convFailed
        array.push(warns, "Conversion pair " + quoteCcy + acctCcy + " / " + acctCcy + quoteCcy + " not found — factor 1.0 used")
    if belowMinLot and not manualLotsOn
        array.push(warns, "Computed size below min lot — clamped up, ACTUAL RISK EXCEEDS PLAN")
    if aboveMaxLot and not manualLotsOn
        array.push(warns, "Computed size above max lot — capped at " + f_lots(maxLot))
    if not chkTradeCap and not na(actualRiskPct)
        array.push(warns, "Risk " + f_pct(actualRiskPct) + " exceeds per-trade cap " + f_pct(maxTradePct))
    if not chkDaily and not na(actualRisk)
        array.push(warns, "This trade does NOT fit in today's remaining loss budget")
    if manualLotsOn
        array.push(warns, "Manual lot override active — risk is reverse-calculated")

    if array.size(warns) > 0
        r := f_sec(pnl, r, "WARNINGS", color.rgb(255, 152, 0), cBgAlt, size.tiny, text.align_left)
        int maxW = compact ? 3 : 8
        for i = 0 to math.min(array.size(warns) - 1, maxW - 1)
            r := f_sec(pnl, r, "⚠ " + array.get(warns, i), cTxt, cWarnBg, size.tiny, text.align_left)

// ════════════════════════════════════════════════════════════════════════════════════════
//  SECTION 7 — ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════
touchEntry = entryType == "Pending" and entryOk and high >= entryPx and low <= entryPx
touchSL    = slPlaced and high >= slPx and low <= slPx
touchTP    = tpPlaced and not tpWrongSide and high >= tpPx and low <= tpPx
riskBreach = anyFail and not geomInvalid   // only meaningful once a valid trade is defined

// Static alertconditions (selectable in the Create Alert dialog; messages must be constant)
alertcondition(touchEntry, "Entry level touched", "PropSizer: price touched the ENTRY level")
alertcondition(touchSL,    "Stop-Loss level touched", "PropSizer: price touched the STOP-LOSS level")
alertcondition(touchTP,    "Take-Profit level touched", "PropSizer: price touched the TAKE-PROFIT level")
alertcondition(riskBreach, "Risk parameters breached", "PropSizer: a prop-firm risk check has FAILED")

// Dynamic alert() calls — include live lot size & risk figures (use 'Any alert() function call')
alertTail = " | Lots: " + f_lots(lots) + " | Risk: " + f_money(actualRisk) + " " + acctCcy + " (" + f_pct(actualRiskPct) + ")"
if alertLevels and touchEntry and not touchEntry[1]
    alert("PropSizer " + syminfo.ticker + ": ENTRY touched @ " + f_fmtPx(entryPx) + alertTail, alert.freq_once_per_bar)
if alertLevels and touchSL and not touchSL[1]
    alert("PropSizer " + syminfo.ticker + ": STOP-LOSS touched @ " + f_fmtPx(slPx) + alertTail, alert.freq_once_per_bar)
if alertLevels and touchTP and not touchTP[1]
    alert("PropSizer " + syminfo.ticker + ": TAKE-PROFIT touched @ " + f_fmtPx(tpPx) + alertTail, alert.freq_once_per_bar)
if alertRisk and riskBreach and not riskBreach[1]
    alert("PropSizer " + syminfo.ticker + ": RISK PARAMETERS BREACHED — check the panel." + alertTail, alert.freq_once_per_bar)
````
