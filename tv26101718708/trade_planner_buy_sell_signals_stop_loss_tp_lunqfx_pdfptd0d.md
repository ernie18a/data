# Trade Planner Buy Sell Signals, Stop Loss, TP [LunqFX]

- url: https://www.tradingview.com/script/pdfPtD0d-Trade-Planner-Buy-Sell-Signals-Stop-Loss-TP-LunqFX/
- type: indicator
- pine_id: PUB;2585b5014b734683964b79a9d36fc8f9
- version: 1.0

## Description

Trade Planner prints buy and sell signals with the stop loss, three take-profit targets and the lot size for your account — all on the bar the setup confirms. Works on forex, gold (XAUUSD), indices and crypto, on intraday charts.

A signal is half a trade. The other half — where the stop goes, where the targets sit, and how large the position must be so the stop costs exactly what you decided to risk — is usually worked out by hand after the arrow appears, while price keeps moving. This tool does that half on the same bar — and converts the size into your account currency, so the stop costs exactly your risk percentage.

The setup itself is deliberately simple and fully described below: trade with the trend, wait for price to pull back into the value zone around the fast moving average, and enter when momentum turns back in the trend's direction. The originality is not in the moving averages or the RSI — both are standard, and they are named plainly — but in turning a pullback into a complete, sized trade plan on one bar, and in tracking that plan until it resolves.

Included: trend and value-zone logic, entry signals, a stop built from the pullback's own extreme, three targets in R multiples, automatic position size in lots, units or contracts, optional stop-to-entry after the first target, a plan panel, and alerts that carry the full plan.

❶ THE SETUP

Trend. The trend is up while the fast EMA is above the slow EMA, price holds above the slow EMA and the slow EMA is not falling. Down is the mirror. When neither holds, the market is treated as having no trend and no plan is printed.

Value zone. A band around the fast EMA, its width a fraction of ATR. It is drawn on the chart and tinted by the trend. A pullback counts once price trades into it while the trend is intact.

Trigger. After a pullback, the plan is printed on the first closed bar that closes back beyond the fast EMA in the trend's direction, closes in that direction itself, and has RSI on the trend's side of 50 and rising (falling, for shorts). The RSI here does one job: confirm that momentum has turned back with the trend, so the plan is not printed while the pullback is still running.

❷ THE PLAN

Entry — the close of the trigger bar. Stop — beyond the lowest low (highest high, for shorts) of the last few bars — the pullback itself, not an older swing — plus an ATR buffer. If that stop would be tighter than a minimum distance in ATR it is widened to the minimum, so one noisy candle does not end the trade. If it would be wider than a maximum distance in ATR, the setup is skipped and no plan is printed: a stop five ATR away is not a pullback trade any more. Targets — TP1, TP2 and TP3 at 1R, 2R and 3R of that stop by default, each adjustable. They are drawn as gold dotted lines with price tags; the risk and reward are shaded as two zones.

❸ POSITION SIZE

Risk money is your balance times your risk percentage. The size is that amount divided by what one unit of the instrument loses over the stop distance — using the symbol's point value and converting from the symbol's currency into your account currency. The result is shown in lots for forex (100,000 units), gold (100 oz) and silver (5,000 oz), in contracts for futures, and in units for everything else. If your broker uses a different lot size, it can be entered directly.

The entry label shows the size, the stop tag shows what the stop costs, and the TP1 tag shows what the first target is worth at that size.

❹ TRACKING THE PLAN

A plan stays open until the stop or TP3 is reached, or — optionally — until an opposite plan appears. Targets reached along the way are ticked on their tags. If one bar touches both the stop and a target, it is counted as the stop: the order of fills inside a bar is unknown, and the honest reading is the loss. Optionally the stop moves to the entry after TP1. The panel shows the open plan, where price stands in R right now, and how the previous plan ended.

HOW TO USE IT

1 — Set your balance, risk percentage and account currency first. The size is only as right as these numbers.

2 — Read the panel before the arrow. "Uptrend · waiting for pullback" means there is nothing to do yet. "In value zone" means a plan may print on the next bars.

3 — Check the size against your broker. The script calculates it from TradingView's symbol data; your broker's contract size or margin rules can differ.

4 — Decide what you do at TP1. The plan gives three targets; whether you scale out, move the stop or hold is yours. With the stop-to-entry option on, the chart tracks the plan with the stop moved to the entry after TP1, and a return to the entry closes the plan as "exit at entry". The script places no orders either way.

5 — Use it on liquid instruments on intraday charts, where pullbacks to a moving average are frequent and spreads are small relative to the stop.

HOW IT WORKS

Two exponential moving averages define the trend, an ATR-scaled band around the fast one defines the value zone, and RSI confirms the turn. The lowest low (or highest high) of a short recent window becomes the anchor for the stop, and a stop outside the allowed ATR range either widens to the minimum or cancels the setup. Targets are multiples of the resulting stop distance. The position size divides the risk money by the stop distance times the symbol's point value, converted with TradingView's currency-rate data. Every decision — trend state, pullback, trigger, target hits and stop hits — is made on closed bars only.

LIMITATIONS — read before relying on it

▸ It is a trend-pullback method. In a range the trend condition switches on and off and plans are printed into chop. The "no trend" state in the panel is the warning; there is no filter that removes ranging markets completely.

▸ The stop is placed by structure, not by your preference. On a deep pullback it can be wide, and the size shrinks to keep the risk constant. Setups whose stop exceeds the maximum ATR distance are skipped, so a strong trend with deep pullbacks can print fewer plans than you expect.

▸ Position size is an estimate from TradingView's data. Broker contract sizes, account currency conversions, commissions, spreads and minimum lot steps are not known to the script. Check the number before using it.

▸ Targets are fixed multiples of the stop. They do not look at the next level of support or resistance, which may sit before TP1.

▸ When one bar spans both the stop and a target, the plan is recorded as stopped. On fast markets and higher timeframes this is conservative by design.

▸ The ticks on reached targets and the "last plan" line describe individual plans. They are not collected into a win rate, and nothing here is a statement about future results.

▸ Signals appear on the close of the trigger bar. Between that close and your order, price can already have moved.

▸ On one- and five-minute charts the stop can be only a few pips, and the spread then takes a large share of it — the size grows to match. Raise the minimum stop distance if you trade those timeframes.

WHY IT IS ORIGINAL

Pullback entries and R-multiple targets are common ideas, and this description does not pretend otherwise. What this script adds is the step most signal tools leave to the trader: it anchors the stop on the pullback's own extreme, derives three targets from it, and sizes the position for the account in its own currency — on the same bar, as one plan — and then follows that plan to its end on the chart.

It is also not a version of my other scripts. Adaptive SuperTrend and Trend Trail are trailing-stop trend tools with no entry plan and no sizing. The Position Size Calculator sizes levels you place by hand; it does not find setups. Trade Planner finds the setup and builds the sized plan itself.

SETTINGS

▸ Account & risk — balance, risk %, account currency, units per lot. ▸ Setup — fast EMA, slow EMA, RSI length, value-zone width, stop buffer, minimum and maximum stop distance, pullback lookback. ▸ Targets & management — TP1, TP2, TP3 in R, stop to entry after TP1, close on opposite signal. ▸ Visuals — five candle palettes plus off, value zone, size of the level tags and entry label, number of plans kept on the chart, panel position and text size.

ALERTS — buy plan and sell plan (the message carries entry, stop, all three targets and the size), target reached, stop reached. Create them as "Any alert() function call", or use the four classic alert conditions.

NON-REPAINTING — every signal, stop, target and hit is decided on a closed bar. A printed plan never moves.

This indicator is an educational tool for planning trades and sizing risk. It is not financial advice and it does not predict price. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  Trade Planner Buy Sell Signals, Stop Loss, TP & Lot Size [LunqFX]
// ----------------------------------------------------------------------------
//  A signal is half a trade. The other half — where the stop goes, where the
//  targets are, and how big the position must be so that the stop costs
//  exactly what you decided to risk — is usually worked out by hand, after
//  the arrow, while price moves. This tool prints the whole plan on the bar
//  the setup confirms:
//
//      ENTRY   the close of a trend-pullback-resume bar
//      STOP    beyond the extreme of the pullback, plus an ATR buffer
//      TP1-3   at 1R, 2R and 3R of that stop (adjustable)
//      SIZE    lots / units / contracts sized to your account and risk %,
//              converted into your account currency
//
//  The setup is deliberately simple and fully described: trade with the
//  trend, wait for price to pull back into the value zone around the fast
//  EMA, enter when momentum turns back in the trend's direction.
//
//  NON-REPAINTING: every signal, stop, target and hit is decided on a closed
//  bar. A printed plan never moves.
// ============================================================================
indicator("Trade Planner Buy Sell Signals, Stop Loss, TP & Lot Size [LunqFX]",
     "Trade Planner", overlay = true,
     max_boxes_count = 60, max_lines_count = 120, max_labels_count = 200)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
UP    = #00F5D4
DN    = #FF2E88
RISK  = #FF4D6D
GOLD  = #FFD250
CARD  = #131A24
CARD2 = #1B2431
HEAD  = #0E141D
TXT   = #F1F5F9
MUTE  = #94A3B8

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gA      = "Account & risk"
balance = input.float(10000, "Account balance", minval = 1, step = 100, group = gA)
riskPct = input.float(1.0, "Risk per trade %", minval = 0.01, maxval = 10, step = 0.1, group = gA, tooltip = "The share of the account the stop is allowed to cost. The position size is calculated from this and the stop distance.")
accCur  = input.string("USD", "Account currency", options = ["USD","EUR","GBP","JPY","CHF","AUD","CAD","NZD","USDT"], group = gA)
lotOver = input.float(0, "Units per lot (0 = automatic)", minval = 0, step = 1, group = gA, tooltip = "Automatic: forex 100,000 · gold 100 oz · silver 5,000 oz · futures in contracts · everything else in units. Set your broker's figure here if it differs.")

gS      = "Setup"
fastLen = input.int(21, "Fast EMA (value zone)", minval = 2, maxval = 200, group = gS)
slowLen = input.int(50, "Slow EMA (trend)", minval = 5, maxval = 400, group = gS)
rsiLen  = input.int(14, "Momentum (RSI length)", minval = 2, maxval = 50, group = gS)
zoneW   = input.float(0.25, "Value zone width (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gS, tooltip = "How close to the fast EMA price has to come for the move to count as a pullback.")
slBuf   = input.float(0.20, "Stop buffer beyond pullback (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gS)
minStop = input.float(0.50, "Minimum stop distance (× ATR)", minval = 0.1, maxval = 3.0, step = 0.05, group = gS, tooltip = "A stop tighter than this is widened to it, so one noisy candle does not end the trade.")
maxStop = input.float(3.0, "Maximum stop distance (× ATR)", minval = 0.5, maxval = 10.0, step = 0.25, group = gS, tooltip = "A setup whose stop would be wider than this is skipped rather than printed. A plan with a stop five ATR away is not a pullback trade any more.")
pbBars  = input.int(10, "Pullback lookback (bars)", minval = 2, maxval = 50, group = gS, tooltip = "The stop is anchored on the lowest low (highest high for shorts) of this many recent bars — the pullback itself, not an old swing from before it.")

gT      = "Targets & management"
r1      = input.float(1.0, "TP1 (R)", minval = 0.25, maxval = 20, step = 0.25, group = gT)
r2      = input.float(2.0, "TP2 (R)", minval = 0.25, maxval = 20, step = 0.25, group = gT)
r3      = input.float(3.0, "TP3 (R)", minval = 0.25, maxval = 20, step = 0.25, group = gT)
beOn    = input.bool(false, "Move stop to entry after TP1", group = gT)
oppOn   = input.bool(true, "Close on opposite signal", group = gT)

gV      = "Visuals"
candSty = input.string("Neon Bloom", "Candle palette", options = ["Neon Bloom","Midnight Cyan","Vibrant Neon","Classic Soft","Cool Blue","Off"], group = gV)
showZone= input.bool(true, "Show value zone", group = gV)
tagSize = input.string("Normal", "Level tag size", options = ["Small","Normal","Large","Huge"], group = gV, tooltip = "Size of the SL / TP1 / TP2 / TP3 tags and of the entry label.")
keepN   = input.int(2, "Plans kept on chart", minval = 1, maxval = 10, group = gV)
showHUD = input.bool(true, "Show panel", group = gV)
hudPos  = input.string("Top Right", "Panel position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)
hudSize = input.string("Normal", "Panel text", options = ["Small","Normal","Large"], group = gV)

// tag size, and the entry label one step louder so the plan reads first
tagSz = switch tagSize
    "Small" => size.small
    "Large" => size.large
    "Huge"  => size.huge
    => size.normal
entSz = switch tagSize
    "Small" => size.normal
    "Normal" => size.large
    => size.huge

// ─────────────────────────────────────────────────────────────────────────
//  CORE SERIES
// ─────────────────────────────────────────────────────────────────────────
atr  = ta.atr(14)
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
rsi  = ta.rsi(close, rsiLen)
zone = atr * zoneW

// The trend is up while the fast EMA leads the slow one, price holds above the
// slow EMA and the slow EMA is not falling. Mirror for down. Anything else is
// no trend, and no plan is printed.
trendUp = emaF > emaS and close > emaS and emaS >= emaS[3]
trendDn = emaF < emaS and close < emaS and emaS <= emaS[3]

// The stop anchors on the pullback's own extreme — the last few bars only —
// and a plan whose stop would be unreasonably wide is not printed at all.
anchorL = ta.lowest(low, pbBars)
anchorH = ta.highest(high, pbBars)
stopL0  = anchorL - atr * slBuf
stopS0  = anchorH + atr * slBuf
stopL   = close - stopL0 < atr * minStop ? close - atr * minStop : stopL0
stopS   = stopS0 - close < atr * minStop ? close + atr * minStop : stopS0
okL     = close - stopL <= atr * maxStop
okS     = stopS - close <= atr * maxStop

// ─────────────────────────────────────────────────────────────────────────
//  POSITION SIZE
//  risk money / (stop distance × value of one price unit per unit, converted
//  from the symbol's currency into the account's)
// ─────────────────────────────────────────────────────────────────────────
tk = str.upper(syminfo.ticker)
autoUnits = syminfo.type == "forex" ? 100000.0 : str.contains(tk, "XAU") ? 100.0 : str.contains(tk, "XAG") ? 5000.0 : 1.0
lotUnits  = lotOver > 0 ? lotOver : autoUnits
sizeWord  = syminfo.type == "futures" ? "contracts" : lotUnits > 1 ? "lots" : "units"
fxRate    = request.currency_rate(syminfo.currency, accCur, ignore_invalid_currency = true)
rate      = na(fxRate) or fxRate <= 0 ? 1.0 : fxRate
riskMoney = balance * riskPct / 100.0

sizeFor(float dist) =>
    perUnit = dist * syminfo.pointvalue * rate
    perUnit > 0 ? riskMoney / perUnit / lotUnits : na

money(float v) =>
    (accCur == "USD" or accCur == "USDT" ? "$" : accCur + " ") + str.tostring(v, "#,##0")

sizeTxt(float s) =>
    na(s) ? "—" : str.tostring(s, s < 10 ? "0.00" : "#,##0.0") + " " + sizeWord

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES — neon pair, translucent body against a solid edge
// ─────────────────────────────────────────────────────────────────────────
cBull = switch candSty
    "Neon Bloom"    => #00F5D4
    "Midnight Cyan" => #34E89E
    "Vibrant Neon"  => #00E5B0
    "Classic Soft"  => #3FB68B
    "Cool Blue"     => #4C9AFF
    => #00F5D4
cBear = switch candSty
    "Neon Bloom"    => #FF2E88
    "Midnight Cyan" => #FF4D7D
    "Vibrant Neon"  => #FF2E63
    "Classic Soft"  => #E0556B
    "Cool Blue"     => #8A94A6
    => #FF2E88
cEdge = close >= open ? cBull : cBear
plotcandle(candSty == "Off" ? na : open, high, low, close, "Candles",
     color = color.new(cEdge, 24), wickcolor = color.new(cEdge, 18), bordercolor = cEdge)

// ── the value zone: a soft band around the fast EMA, tinted by the trend ──
zCol = trendUp ? UP : trendDn ? DN : MUTE
zTop = plot(showZone ? emaF + zone : na, "Value zone top", color = color.new(zCol, 70), linewidth = 1)
zBot = plot(showZone ? emaF - zone : na, "Value zone bottom", color = color.new(zCol, 70), linewidth = 1)
fill(zTop, zBot, color = color.new(zCol, 88), title = "Value zone")
plot(showZone ? emaS : na, "Trend EMA", color = color.new(zCol, 40), linewidth = 2)

// ─────────────────────────────────────────────────────────────────────────
//  SETUP STATE
// ─────────────────────────────────────────────────────────────────────────
var bool  pbL    = false      // a long pullback has reached the value zone
var float pbLow  = na
var bool  pbS    = false
var float pbHigh = na

// trade in progress
var int   tDir   = 0
var float tEntry = na
var float tSL    = na
var float tSL0   = na          // original stop, for R and sizing
var float tTP1   = na
var float tTP2   = na
var float tTP3   = na
var int   tBar   = na
var int   tStage = 0           // 0 open, 1 TP1 hit, 2 TP2 hit
var float tSize  = na
var string lastOut = ""        // how the previous plan ended

// drawings of the current plan
var box   bRisk = na
var box   bRew  = na
var line  l1 = na
var line  l2 = na
var line  l3 = na
var label kSL = na
var label k1  = na
var label k2  = na
var label k3  = na
// every plan's drawings, oldest first, so old plans can be retired whole
var array<box>   allB = array.new<box>()
var array<line>  allL = array.new<line>()
var array<label> allK = array.new<label>()

longSig  = false
shortSig = false
hitTP1   = false
hitTP2   = false
hitTP3   = false
hitSL    = false

px(float v) => str.tostring(v, format.mintick)

// closes the current plan and freezes its drawings at this bar
closePlan(string how) =>
    box.set_right(bRisk, bar_index)
    box.set_right(bRew, bar_index)
    line.set_x2(l1, bar_index)
    line.set_x2(l2, bar_index)
    line.set_x2(l3, bar_index)
    for k in array.from(kSL, k1, k2, k3)
        label.set_x(k, bar_index)
    how

if barstate.isconfirmed
    // ── 1. manage the open plan (bars after the entry bar only) ──────────
    if tDir != 0 and bar_index > tBar
        slHit = tDir == 1 ? low <= tSL : high >= tSL
        h1 = tStage < 1 and (tDir == 1 ? high >= tTP1 : low <= tTP1)
        h2 = tStage < 2 and (tDir == 1 ? high >= tTP2 : low <= tTP2)
        h3 = tDir == 1 ? high >= tTP3 : low <= tTP3
        // the stop is checked first: when one bar spans stop and target the
        // order of fills is unknown, and the honest reading is the stop
        if slHit
            hitSL := true
            atEntry = tSL == tEntry
            label.set_text(kSL, (atEntry ? "EXIT AT ENTRY  " : "STOPPED  ") + px(tSL))
            lastOut := closePlan(atEntry ? "exit at entry" : "stopped")
            tDir := 0
        else
            if h1
                tStage := 1
                hitTP1 := true
                label.set_text(k1, "TP1 ✓  " + px(tTP1))
                if beOn
                    tSL := tEntry
                    box.set_bottom(bRisk, tEntry)
                    box.set_top(bRisk, tEntry)
                    label.set_y(kSL, tEntry)
                    label.set_text(kSL, "STOP AT ENTRY  " + px(tEntry))
            if h2
                tStage := 2
                hitTP2 := true
                label.set_text(k2, "TP2 ✓  " + px(tTP2))
            if h3
                hitTP3 := true
                label.set_text(k3, "TP3 ✓  " + px(tTP3))
                lastOut := closePlan("TP3 reached")
                tDir := 0
        // keep an open plan's drawings reaching the live bar
        if tDir != 0
            xr = bar_index + 3
            box.set_right(bRisk, xr)
            box.set_right(bRew, xr)
            line.set_x2(l1, xr)
            line.set_x2(l2, xr)
            line.set_x2(l3, xr)
            for k in array.from(kSL, k1, k2, k3)
                label.set_x(k, xr)

    // ── 2. track pullbacks into the value zone ────────────────────────────
    if trendUp
        if low <= emaF + zone
            pbL := true
        if pbL
            pbLow := na(pbLow) ? low : math.min(pbLow, low)
    else
        pbL := false
        pbLow := na
    if trendDn
        if high >= emaF - zone
            pbS := true
        if pbS
            pbHigh := na(pbHigh) ? high : math.max(pbHigh, high)
    else
        pbS := false
        pbHigh := na

    // ── 3. the trigger: momentum turns back in the trend's direction ──────
    goLong  = trendUp and pbL and close > emaF and close > open and rsi > 50 and rsi > rsi[1] and okL and tDir != 1 and (tDir == 0 or oppOn)
    goShort = trendDn and pbS and close < emaF and close < open and rsi < 50 and rsi < rsi[1] and okS and tDir != -1 and (tDir == 0 or oppOn)

    if goLong or goShort
        if tDir != 0
            lastOut := closePlan("closed on opposite signal")
        d = goLong ? 1 : -1
        e = close
        s = goLong ? stopL : stopS
        risk = math.abs(e - s)
        tDir := d
        tEntry := e
        tSL := s
        tSL0 := s
        tTP1 := e + d * risk * r1
        tTP2 := e + d * risk * r2
        tTP3 := e + d * risk * r3
        tBar := bar_index
        tStage := 0
        tSize := sizeFor(risk)
        longSig := goLong
        shortSig := goShort
        pbL := false
        pbLow := na
        pbS := false
        pbHigh := na

        col  = d == 1 ? UP : DN
        xr   = bar_index + 3
        tpHi = d == 1 ? tTP3 : e
        tpLo = d == 1 ? e : tTP3
        bRisk := box.new(bar_index, math.max(e, s), xr, math.min(e, s), border_color = color.new(RISK, 45), border_width = 1, bgcolor = color.new(RISK, 84))
        bRew  := box.new(bar_index, tpHi, xr, tpLo, border_color = color.new(col, 55), border_width = 1, bgcolor = color.new(col, 90))
        l1 := line.new(bar_index, tTP1, xr, tTP1, color = color.new(GOLD, 20), style = line.style_dotted, width = 2)
        l2 := line.new(bar_index, tTP2, xr, tTP2, color = color.new(GOLD, 35), style = line.style_dotted, width = 2)
        l3 := line.new(bar_index, tTP3, xr, tTP3, color = color.new(GOLD, 50), style = line.style_dotted, width = 2)
        rew1 = riskMoney * r1
        kSL := label.new(xr, s, "SL  " + px(s) + "   −" + money(riskMoney), style = label.style_label_left, color = HEAD, textcolor = RISK, size = tagSz)
        k1  := label.new(xr, tTP1, "TP1 · " + str.tostring(r1, "#.##") + "R  " + px(tTP1) + "   +" + money(rew1), style = label.style_label_left, color = HEAD, textcolor = GOLD, size = tagSz)
        k2  := label.new(xr, tTP2, "TP2 · " + str.tostring(r2, "#.##") + "R  " + px(tTP2), style = label.style_label_left, color = HEAD, textcolor = color.new(GOLD, 20), size = tagSz)
        k3  := label.new(xr, tTP3, "TP3 · " + str.tostring(r3, "#.##") + "R  " + px(tTP3), style = label.style_label_left, color = HEAD, textcolor = color.new(GOLD, 35), size = tagSz)
        kE  = label.new(bar_index, d == 1 ? low : high, (d == 1 ? "▲ BUY  " : "▼ SELL  ") + sizeTxt(tSize), yloc = d == 1 ? yloc.belowbar : yloc.abovebar, style = d == 1 ? label.style_label_up : label.style_label_down, color = col, textcolor = #04211D, size = entSz)
        if d == -1
            label.set_textcolor(kE, #2B0716)

        for b in array.from(bRisk, bRew)
            array.push(allB, b)
        for l in array.from(l1, l2, l3)
            array.push(allL, l)
        for k in array.from(kSL, k1, k2, k3, kE)
            array.push(allK, k)
        // every plan adds 2 boxes, 3 lines and 5 labels, so retiring by
        // fixed counts always removes one whole plan and nothing else
        while array.size(allB) > keepN * 2
            box.delete(array.shift(allB))
        while array.size(allL) > keepN * 3
            line.delete(array.shift(allL))
        while array.size(allK) > keepN * 5
            label.delete(array.shift(allK))

// ─────────────────────────────────────────────────────────────────────────
//  PANEL
// ─────────────────────────────────────────────────────────────────────────
hudP(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

tSz(string s) =>
    switch s
        "Small" => size.small
        "Large" => size.large
        => size.normal

rowL(table tb, int r, string k, string v, color c, color bg, string ts) =>
    table.cell(tb, 0, r, "  " + k, text_color = MUTE, text_size = ts, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, v + "  ", text_color = c, text_size = ts, text_halign = text.align_right, bgcolor = bg)

var table hud = table.new(position.top_right, 2, 11)
if showHUD and barstate.islast
    table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 11, bgcolor = CARD, border_color = color.new(#28323F, 0), border_width = 1)
    ts = tSz(hudSize)
    active = tDir != 0
    riskNow = active ? math.abs(tEntry - tSL0) : na
    liveR = active and riskNow > 0 ? (close - tEntry) * tDir / riskNow : na

    planTx  = (tDir == 1 ? "▲ LONG PLAN" : "▼ SHORT PLAN") + (tStage == 2 ? "  ·  TP2 ✓" : tStage == 1 ? "  ·  TP1 ✓" : "")
    trendTx = trendUp ? (pbL ? "▲ UPTREND · in value zone" : "▲ UPTREND · waiting for pullback") : trendDn ? (pbS ? "▼ DOWNTREND · in value zone" : "▼ DOWNTREND · waiting for pullback") : "NO TREND · no plan"
    hTx = active ? planTx : trendTx
    hBg = active ? (tDir == 1 ? #0A5F55 : #8E1148) : CARD2
    table.cell(hud, 0, 0, "  TRADE PLANNER  ", text_color = UP, text_size = size.small, text_halign = text.align_left, bgcolor = HEAD)
    table.cell(hud, 1, 0, riskPct == 0 ? "" : str.tostring(riskPct, "#.##") + "% risk  ", text_color = MUTE, text_size = size.small, text_halign = text.align_right, bgcolor = HEAD)
    table.cell(hud, 0, 1, "  " + hTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hBg)
    table.merge_cells(hud, 0, 1, 1, 1)

    rowL(hud, 2, "Entry",    active ? px(tEntry) : "—", TXT, CARD, ts)
    rowL(hud, 3, "Stop",     active ? px(tSL) + "   −" + money(riskMoney) : "—", RISK, CARD2, ts)
    // one row per target: three prices in one cell do not fit on a narrow panel
    rowL(hud, 4, "TP1 · " + str.tostring(r1, "#.##") + "R", active ? (tStage >= 1 ? "✓  " : "") + px(tTP1) : "—", GOLD, CARD, ts)
    rowL(hud, 5, "TP2 · " + str.tostring(r2, "#.##") + "R", active ? (tStage >= 2 ? "✓  " : "") + px(tTP2) : "—", GOLD, CARD2, ts)
    rowL(hud, 6, "TP3 · " + str.tostring(r3, "#.##") + "R", active ? px(tTP3) : "—", GOLD, CARD, ts)
    rowL(hud, 7, "Position", active ? sizeTxt(tSize) : "—", UP, CARD2, ts)
    rowL(hud, 8, "Risk", money(riskMoney) + "  ·  " + str.tostring(riskPct, "#.##") + "%", TXT, CARD, ts)
    rowL(hud, 9, "Now", active and not na(liveR) ? (liveR >= 0 ? "+" : "") + str.tostring(liveR, "0.0") + " R" : "—", active and not na(liveR) ? (liveR >= 0 ? UP : RISK) : MUTE, CARD2, ts)
    rowL(hud, 10, "Last plan", lastOut == "" ? "—" : lastOut, MUTE, CARD, ts)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — each message carries the full plan
// ─────────────────────────────────────────────────────────────────────────
planMsg(string side) =>
    syminfo.ticker + " " + side + " @ " + px(tEntry) + " | SL " + px(tSL) + " | TP1 " + px(tTP1) + " | TP2 " + px(tTP2) + " | TP3 " + px(tTP3) + " | size " + sizeTxt(tSize)

if longSig
    alert("LunqFX Trade Planner: " + planMsg("BUY"), alert.freq_once_per_bar_close)
if shortSig
    alert("LunqFX Trade Planner: " + planMsg("SELL"), alert.freq_once_per_bar_close)
if hitTP1 or hitTP2 or hitTP3
    alert("LunqFX Trade Planner: " + syminfo.ticker + (hitTP3 ? " TP3" : hitTP2 ? " TP2" : " TP1") + " reached", alert.freq_once_per_bar_close)
if hitSL
    alert("LunqFX Trade Planner: " + syminfo.ticker + " stop reached", alert.freq_once_per_bar_close)

alertcondition(longSig,  "Buy plan",   "LunqFX Trade Planner: new BUY plan")
alertcondition(shortSig, "Sell plan",  "LunqFX Trade Planner: new SELL plan")
alertcondition(hitTP1 or hitTP2 or hitTP3, "Target reached", "LunqFX Trade Planner: a target was reached")
alertcondition(hitSL,    "Stop reached", "LunqFX Trade Planner: the stop was reached")
````
