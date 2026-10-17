# Position Size Calculator - Risk Manager, Risk/Reward & L[LunqFX]

- url: https://www.tradingview.com/script/FWhsL4nb-Position-Size-Calculator-Risk-Manager-Risk-Reward-L-LunqFX/
- type: indicator
- pine_id: PUB;4cac23755bcc4f61a96e9a00d27fe2dd
- version: 1.0

## Description

Risk Manager is an on-chart position size and risk/reward calculator for TradingView that turns proper risk management into one click. Set your account size and risk per trade %, and it instantly gives you the exact position size (units / lots / contracts / shares), your risk and reward in dollars, the risk/reward ratio, and the breakeven win rate you need to be profitable — all visualized as clean risk and reward zones right on the chart. It works out of the box with an auto ATR setup (Entry / Stop Loss / Take Profit placed for you), or type your own levels. Built in Pine Script v6, it works on forex, crypto, stocks, indices, futures, gold (XAUUSD) and Bitcoin (BTCUSD), on any timeframe — because it sizes risk, not signals. Keywords: position size, position sizing, risk management, risk reward, risk/reward ratio, lot size calculator, money management, stop loss, take profit, R multiple, risk per trade, breakeven win rate, Kelly criterion, day trading, swing trading, scalping.

◆ WHY THIS MATTERS
Most traders blow accounts not because of bad entries, but because of bad position sizing and inconsistent risk. Professionals risk a fixed small % per trade (commonly 0.5–2%) and know their risk/reward before they click buy. This tool enforces that discipline on every trade — no spreadsheets, no external calculators.

◆ WHAT IT DOES

Exact position size from your account balance and risk %, in units, lots, contracts, shares or coins.
Risk and reward in account currency and as a % of account.
Risk/reward ratio with a clean visual meter.
Breakeven win rate — the minimum win rate needed to be profitable at your current R:R (a metric most calculators skip).
Visual risk zone (red) and reward zone (green) drawn between Entry, Stop and Target.
Optional fractional Kelly suggested risk %.
A modern, colour-coded dashboard.
[image]https://www.tradingview.com/x/SfFd5KOx/[/image]

◆ HOW IT WORKS
Auto mode (default): Entry is set at price, Stop at a chosen ATR distance, and Target at your chosen R multiple — a valid setup appears instantly on any instrument.
Manual mode: turn Auto off and enter your own exact Entry / Stop / Target prices in the settings.
Position size = (account balance × risk %) ÷ (distance from entry to stop). This guarantees that if the stop is hit, you lose exactly your chosen risk %.
Reward = position size × distance to target; R:R = reward ÷ risk.
Breakeven win rate = 100 ÷ (1 + R:R) — e.g., at 2R you only need to win >33% of trades to break even.
Lots/contracts = units ÷ your contract size (100000 for a forex standard lot, 1 for stocks/crypto, your multiplier for futures).

◆ HOW TO USE IT

Set Account balance and Risk per trade % once (e.g., 1%).
Pick Auto direction (Long/Short) or switch to manual and place your real Entry/Stop/Target.
Read the Position size — that is exactly how much to trade so your loss at stop = your set risk.
Check the R:R meter and Breakeven — only take trades whose math fits your strategy’s win rate.
Use the red/green zones to see risk and reward visually before entering.
Adjust Contract size to match your instrument (forex lots, futures multiplier, etc.).

◆ SETTINGS
Trade Setup (auto ATR or manual prices, direction, ATR stop, target R), Account & Risk (balance, risk %, contract size, size label), Kelly (optional), Visuals (box length, neon candles), Panel (text size, position, colours).

◆ ALERTS
Price hit Entry · Price hit Stop · Price hit Target.

◆ ORIGINALITY
This is original work. The auto-ATR setup engine, the account-aware sizing, the visual risk/reward zones, the colour-coded dashboard with the R:R meter and the breakeven-win-rate readout are all my own implementation. No third-party code is used.

◆ LIMITATIONS
This is a planning and sizing tool, not a signal generator — it does not tell you when to buy or sell.
Position size assumes your account currency matches the quote currency; for cross-currency pairs or unusual contracts, set Contract size to match your broker’s lot/units.
The auto ATR setup is a starting template — always adjust Stop and Target to real structure.
Results depend on the inputs you provide (balance, risk %, contract size); double-check them for your broker.

◆ NON-REPAINTING
This is a calculator: it draws from your inputs and the current price and never alters historical bars.

Risk Manager is an educational tool, not financial advice. Trading involves risk of loss. Always do your own research and manage risk responsibly. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Risk Manager - Position Size, Risk/Reward & Lot Calculator [LunqFX]
// ----------------------------------------------------------------------------
//  Position sizing is the single biggest driver of long-term profitability, yet
//  most traders eyeball it or jump to an external calculator. This tool puts a
//  full, account-aware risk manager directly on your chart.
//
//  It works out of the box: by default it auto-places a clean ENTRY / STOP /
//  TARGET around current price using ATR (a valid setup every time), then
//  computes everything you need to place the trade correctly:
//      • exact POSITION SIZE (units / lots / contracts / shares)
//      • RISK and REWARD in account currency and in % of account
//      • R:R ratio with a visual meter
//      • BREAKEVEN win rate needed to be profitable at that R:R
//      • optional fractional-Kelly suggested risk %
//  Turn Auto off to type your own exact Entry / Stop / Target in the settings.
//
//  Works on forex, crypto, stocks, indices and futures - it sizes risk, not
//  signals, so the same tool fits every market and timeframe.
//
//  NON-REPAINTING: this is a calculator. It draws from your inputs and the
//  current price; it never paints or alters history.
// ============================================================================
indicator("Risk Manager - Position Size, Risk/Reward & Lot Calculator [LunqFX]", "Risk Manager [LunqFX]", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 20)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
TEAL_MID = #12B8A6
TEAL_HI  = #4DFCE6
PINK_MID = #FF2E63
PINK_HI  = #FF6FA3
GOLD     = #FFB938
INK      = #0B0E14
MUTE     = #5C6675
INKHI    = #EAEEF6

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gTrade  = "Trade Setup"
autoMode= input.bool(true, "Auto levels (ATR)", group = gTrade, tooltip = "ON = Entry/Stop/Target auto-placed around price by ATR (always a clean setup). OFF = use your manual prices below.")
autoDir = input.string("Long", "Auto direction", options = ["Long","Short"], group = gTrade)
stopATR = input.float(1.5, "Auto stop (ATR x)", minval = 0.2, step = 0.1, group = gTrade)
autoRR  = input.float(2.0, "Auto target (R)",   minval = 0.5, step = 0.5, group = gTrade)
mEntry  = input.float(0.0, "Manual entry",  group = gTrade, tooltip = "Used only when Auto is OFF.")
mStop   = input.float(0.0, "Manual stop",   group = gTrade)
mTarget = input.float(0.0, "Manual target", group = gTrade)

gAcc    = "Account & Risk"
balance = input.float(10000, "Account balance",  minval = 1, step = 100, group = gAcc, tooltip = "Your account size in its currency.")
riskPct = input.float(1.0,   "Risk per trade %", minval = 0.01, maxval = 100, step = 0.1, group = gAcc, tooltip = "Percent of the account risked if the stop is hit. Pros use 0.5-2%.")
contract= input.float(1.0,   "Contract size (units per lot)", minval = 0.0000001, step = 1, group = gAcc, tooltip = "Units per 1 lot/contract. Forex standard lot = 100000. Stocks/crypto = 1. Futures = your contract's multiplier.")
unitName= input.string("units", "Size label", options = ["units","lots","contracts","shares","coins"], group = gAcc)

gKelly  = "Kelly (optional)"
useKelly= input.bool(false, "Show suggested risk % (Kelly)", group = gKelly)
winRate = input.float(50, "Estimated win rate %", minval = 1, maxval = 99, step = 1, group = gKelly)
kFrac   = input.float(0.5, "Kelly fraction",      minval = 0.05, maxval = 1.0, step = 0.05, group = gKelly)

gVis    = "Visuals"
barsBack= input.int(60, "Box start (bars back)", minval = 5, maxval = 500, group = gVis)
projBars= input.int(25, "Box length (bars)",     minval = 2, maxval = 200, group = gVis)
neonOn  = input.bool(true, "Neon gradient candles", group = gVis)

gP      = "Panel"
showHUD = input.bool(true, "Show dashboard", group = gP)
txtSize = input.string("Large","Text size", options = ["Normal","Large","Huge"], group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0C0F16, "Background", group = gP)
accent  = input.color(TEAL_MID, "Accent",    group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

f_money(float v) =>
    a = math.abs(v)
    a >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : a >= 1e3 ? str.tostring(v / 1e3, "#.##") + "k" : str.tostring(v, "#.##")

f_px(float v) => str.tostring(v, format.mintick)

f_sz(string s) => s == "Huge" ? size.huge : s == "Normal" ? size.normal : size.large

// one dashboard row: neon accent rail + label + value (custom card look)
f_row(table t, int r, color rail, string lbl, string val, color valC, bool head, color headBg, color surfBg, string szL, string szV) =>
    bg = head ? headBg : surfBg
    table.cell(t, 0, r, "  ", bgcolor = rail)
    table.cell(t, 1, r, "  " + lbl + "  ", text_color = head ? INKHI : MUTE, text_size = f_sz(szL), text_halign = text.align_left, bgcolor = bg)
    table.cell(t, 2, r, val + "  ", text_color = valC, text_size = f_sz(szV), text_halign = text.align_right, bgcolor = bg)

// ─────────────────────────────────────────────────────────────────────────
//  EFFECTIVE LEVELS  (auto ATR setup, or manual)
// ─────────────────────────────────────────────────────────────────────────
atr14  = ta.atr(14)
aLong  = autoDir == "Long"
entry  = autoMode ? close : mEntry
stop   = autoMode ? (aLong ? close - stopATR * atr14 : close + stopATR * atr14) : mStop
target = autoMode ? (aLong ? close + stopATR * atr14 * autoRR : close - stopATR * atr14 * autoRR) : mTarget

// ─────────────────────────────────────────────────────────────────────────
//  RISK MATH
// ─────────────────────────────────────────────────────────────────────────
valid    = entry > 0 and stop > 0 and target > 0 and entry != stop
isLong   = entry >= stop
riskUnit = math.abs(entry - stop)
rewUnit  = math.abs(target - entry)
rr       = riskUnit > 0 ? rewUnit / riskUnit : na

riskAmt  = balance * riskPct / 100.0
sizeUnit = riskUnit > 0 ? riskAmt / riskUnit : na
lots     = not na(sizeUnit) and contract > 0 ? sizeUnit / contract : na
notional = not na(sizeUnit) ? sizeUnit * entry : na
rewAmt   = not na(rr) ? riskAmt * rr : na

stopDistPct = entry != 0 ? math.abs(entry - stop) / entry * 100.0 : na
tgtDistPct  = entry != 0 ? math.abs(target - entry) / entry * 100.0 : na

goodTgt  = isLong ? target > entry : target < entry
tooClose = riskUnit < syminfo.mintick * 5 or rewUnit < syminfo.mintick * 5
setupOK  = valid and goodTgt and not tooClose

W      = winRate / 100.0
kellyF = not na(rr) and rr > 0 ? W - (1.0 - W) / rr : na
kellyR = not na(kellyF) ? math.max(0.0, kellyF * kFrac * 100.0) : na

// ─────────────────────────────────────────────────────────────────────────
//  DRAWING  (single objects on the last bar)
// ─────────────────────────────────────────────────────────────────────────
var box   bxRisk = na
var box   bxRew  = na
var line  lnE = na
var line  lnS = na
var line  lnT = na
var label lbE = na
var label lbS = na
var label lbT = na

if barstate.islast and not na(bxRisk)
    box.delete(bxRisk)
    box.delete(bxRew)
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT)
    label.delete(lbE)
    label.delete(lbS)
    label.delete(lbT)
    bxRisk := na

if barstate.islast and setupOK
    bb     = math.min(barsBack, bar_index)
    leftX  = bar_index - bb
    rightX = bar_index + projBars
    midX   = bar_index - bb / 2

    bxRisk := box.new(leftX, entry, rightX, stop,   border_color = color.new(PINK_MID, 45), border_width = 1, bgcolor = color.new(PINK_MID, 84))
    bxRew  := box.new(leftX, entry, rightX, target, border_color = color.new(TEAL_MID, 45), border_width = 1, bgcolor = color.new(TEAL_MID, 84))

    lnE := line.new(leftX, entry,  rightX, entry,  color = GOLD,     width = 3)
    lnS := line.new(leftX, stop,   rightX, stop,   color = PINK_MID, width = 1, style = line.style_dashed)
    lnT := line.new(leftX, target, rightX, target, color = TEAL_MID, width = 1, style = line.style_dashed)

    lbE := label.new(leftX, entry, " ENTRY  " + f_px(entry) + " ", style = label.style_label_right, color = color.new(GOLD, 0), textcolor = INK, size = size.normal)
    lbS := label.new(midX, (entry + stop) / 2.0, "STOP  " + f_px(stop) + "   −" + f_money(riskAmt) + "  ·  " + str.tostring(stopDistPct, "#.##") + "%", style = label.style_label_center, color = color.new(PINK_MID, 0), textcolor = INK, size = size.normal)
    lbT := label.new(midX, (entry + target) / 2.0, "TARGET  " + f_px(target) + "   +" + (na(rewAmt) ? "—" : f_money(rewAmt)) + "  ·  " + (na(rr) ? "—" : str.tostring(rr, "#.##") + "R"), style = label.style_label_center, color = color.new(TEAL_MID, 0), textcolor = INK, size = size.normal)

// ─────────────────────────────────────────────────────────────────────────
//  NEON GRADIENT CANDLES
// ─────────────────────────────────────────────────────────────────────────
mom   = math.abs(close - open)
strn  = atr14 > 0 ? math.min(1.0, mom / atr14) : 0.0
upC   = color.from_gradient(strn, 0, 1, TEAL_MID, TEAL_HI)
dnC   = color.from_gradient(strn, 0, 1, PINK_MID, PINK_HI)
bull  = close >= open
bodyC = bull ? upC : dnC
edgeC = bull ? TEAL_HI : PINK_HI
plotcandle(neonOn ? open : na, high, low, close, "Neon", color = bodyC, wickcolor = edgeC, bordercolor = edgeC)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    rows = useKelly ? 9 : 8
    // 3 columns: [neon accent rail] [label] [value]
    hud := table.new(hudPosition(hudPos), 3, rows, bgcolor = color.new(hudBg, 0), border_width = 0, frame_color = color.new(#222A38, 0), frame_width = 1)

    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #161C28), 0)
    teal  = accent

    dirT = not valid ? "—" : isLong ? "▲ LONG" : "▼ SHORT"
    dirC = not valid ? GOLD : isLong ? TEAL_MID : PINK_MID

    sizeT = na(sizeUnit) ? "—" : f_money(sizeUnit) + " " + unitName + (na(lots) or contract == 1 ? "" : "  ·  " + f_money(lots) + " lots")

    // R:R meter — green fill = reward's share of the 1:R span
    rrShare = na(rr) ? 0.0 : rr / (1.0 + rr)
    rmF = math.round(rrShare * 12)
    rmBar = ""
    for i = 1 to 12
        rmBar := rmBar + (i <= rmF ? "▰" : "▱")
    rrC = na(rr) ? MUTE : rr >= 2 ? TEAL_HI : rr >= 1 ? GOLD : PINK_MID

    be  = na(rr) ? na : 100.0 / (1.0 + rr)
    beT = na(be) ? "—" : "need > " + str.tostring(be, "#.#") + "% wins"
    beC = na(be) ? MUTE : be <= 40 ? TEAL_MID : be <= 50 ? GOLD : PINK_MID

    rewPctAcc = na(rr) ? na : riskPct * rr

    warnT = not valid ? "Set Entry / Stop / Target" : not goodTgt ? (isLong ? "Target ABOVE entry" : "Target BELOW entry") : tooClose ? "Levels too close" : riskPct > 3 ? "High risk %" : "Ready"
    warnC = not valid ? GOLD : (not goodTgt or tooClose or riskPct > 3) ? PINK_HI : TEAL_MID

    heroSz = txtSize == "Normal" ? "Large" : "Huge"

    f_row(hud, 0, accent,  "RISK MANAGER", dirT, dirC, true, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 1, accent,  "Position size", sizeT, accent, false, HEADR, SURF, txtSize, heroSz)
    f_row(hud, 2, rrC,     "Risk : Reward", na(rr) ? "—" : rmBar + "  " + str.tostring(rr, "#.##") + "R", rrC, false, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 3, PINK_MID,"Risk",   valid ? "−" + f_money(riskAmt) + "  ·  " + str.tostring(riskPct, "#.##") + "%" : "—", PINK_HI, false, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 4, TEAL_MID,"Reward", na(rewAmt) ? "—" : "+" + f_money(rewAmt) + "  ·  " + str.tostring(rewPctAcc, "#.##") + "%", TEAL_HI, false, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 5, beC,     "Breakeven", beT, beC, false, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 6, MUTE,    "Notional", na(notional) ? "—" : f_money(notional), INKHI, false, HEADR, SURF, txtSize, txtSize)
    f_row(hud, 7, warnC,   "Status", warnT, warnC, true, HEADR, SURF, txtSize, txtSize)
    if useKelly
        f_row(hud, 8, GOLD, "Kelly risk %", na(kellyR) ? "—" : str.tostring(kellyR, "#.##") + "%", GOLD, true, HEADR, SURF, txtSize, txtSize)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(setupOK and ta.cross(close, entry),  "Price hit ENTRY",  "Price reached the planned entry")
alertcondition(setupOK and ta.cross(close, stop),   "Price hit STOP",   "Price reached the stop-loss")
alertcondition(setupOK and ta.cross(close, target), "Price hit TARGET", "Price reached the take-profit")
````
