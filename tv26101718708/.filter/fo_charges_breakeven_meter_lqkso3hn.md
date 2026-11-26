# F&O Charges & Breakeven Meter

- url: https://www.tradingview.com/script/Lqkso3Hn-F-O-Charges-Breakeven-Meter/
- type: indicator
- pine_id: PUB;f8fce2a58be4403bbf3779370793f14c
- version: 1.0

## Description

[b]F&O Charges & Breakeven Meter[/b] shows the full cost of an Indian index futures or options trade before it can make a single rupee. It adds up every broker and statutory charge for a complete round trip (one buy order plus one sell order), solves for the exact price the contract must reach just to break even, and projects what those charges add up to over a month and a year at the trading frequency you choose.

Most traders know their brokerage. Far fewer add STT, the exchange transaction charge, the SEBI fee, stamp duty and GST, or notice how quickly they compound when several trades are placed every day. This script puts that cost on the chart, next to price, so it can be seen before a trade is taken.


[b]WHAT YOU SEE[/b]

On the chart (Auto mode):
- A dotted line at your entry price.
- A dashed breakeven line at the price where gross profit exactly pays all round-trip charges.
- A shaded cost zone between the two lines: the distance price has to travel before the trade stops losing to costs.
- Two labels, pinned to the right edge of the visible chart, showing the entry price and the breakeven price with the points needed and the rupee charges. They stay on screen when you scroll or drag the chart.

In the table:
- Every charge on its own line: brokerage, STT, exchange transaction charge, SEBI fee, stamp duty, GST.
- Total charges per round trip.
- Move needed to break even (in points) and the breakeven price.
- Charges as a percentage of the premium (options) or contract value (futures), with a 10-step bar.
- The breakeven move as a multiple of ATR(14) on the current timeframe, to compare the cost with how much this contract typically moves per bar.
- Habit projection: total charges per month and per year at your trades-per-day and days-per-month settings.


[b]HOW TO USE IT — AUTO MODE (one trade on the chart's contract)[/b]

1. Open the chart of the contract you want to cost, for example a NIFTY weekly option, a SENSEX option or NIFTY futures.
2. Add the indicator. TradingView asks you to click on the chart: click at your entry price. The table and the lines appear immediately.
3. The script reads the chart symbol and fills in the rest by itself:
   • option or futures, and for options the strike and CE/PE
   • the exchange (NSE or BSE)
   • the underlying, and its lot size from the built-in presets
   The second row of the table confirms what it detected, for example "NIFTY 22350 CE · NSE · 1 lot × 65 · Long".
4. In Settings → ② Trade, set Direction (Buy first = long, Sell first = short) and the number of Lots. For a short trade the breakeven line moves below the entry.
5. Read the table and the breakeven line before placing the trade.

Changing the entry price later — three ways:
- Click again: hover over the indicator name at the top left of the chart, open the More menu (⋯) and choose "Reset points". TradingView asks for a new click; click your new entry price. The indicator does not need to be removed.
- Drag: click the indicator once to select it, then drag the entry handle up or down. Everything updates as you move it.
- Type: Settings → ② Trade → type the price in the Entry price field.

Prefer it to follow the market? Set Entry price to "Last price" and the meter always costs a trade at the latest price.

If the table says "Open an index option or futures chart", the symbol could not be recognised (for example you are on the index chart itself). Set Instrument to "Option (CE/PE)" or "Futures" in ② Trade and type your entry price.


[b]HOW TO USE IT — MY STRATEGY MODE (multi-leg positions)[/b]

Use this for straddles, strangles, iron flies, spreads or hedged futures.

1. Settings → ① Mode → choose "My Strategy (legs below)".
2. Settings → ④ My Strategy: up to four legs. For each leg:
   • tick the box to switch the leg on
   • choose Buy or Sell
   • choose CE, PE or FUT
   • type the entry price (premium for options, price for futures)
   • set the number of lots
   The default is a short straddle (Sell CE + Sell PE). Legs 3 and 4 are off; switch them on to add wings for an iron fly or an iron condor.
3. All legs use the lot size and exchange from ③ Contract (detected from the chart, or set by you). Open any chart of the same underlying, or set the lot size to Custom.
4. The table shows, per leg: side, type, price, lots and the round-trip charges for that leg. Below it:
   • Total charges for the whole position, in and out
   • Net premium received (credit) or paid (debit), options legs only
   • Charges as a percentage of that net premium, with a bar
   • Credit left after charges (or debit including charges)
   • Monthly and yearly projection, where "cycles per day" means how many times a day you open and close the whole position
5. Chart lines are drawn in Auto mode only; My Strategy mode is a table.


[b]HOW IT CALCULATES[/b]

For a round trip of quantity Q = lots × lot size, with buy value B and sell value S:
- Brokerage: a flat fee per executed order for options; for futures, the lower of the flat fee and a percentage of order value.
- STT: a percentage of the sell-side value (premium for options, contract value for futures).
- Exchange transaction charge: a percentage of total turnover (B + S), with separate NSE and BSE rates for options and futures.
- SEBI fee: rupees per crore of turnover.
- Stamp duty: a percentage of the buy-side value.
- GST: a percentage of (brokerage + exchange transaction charge + SEBI fee).

The breakeven price is solved, not approximated: the script recomputes all charges at the candidate exit price and repeats until gross profit equals total charges. In My Strategy mode each leg is costed as a round trip at its own entry price.


[b]DEFAULT RATES AND HOW TO CHANGE THEM[/b]

Defaults are the published statutory and exchange rates as checked in October 2026, including the STT revision effective 1 April 2026:
- STT: options 0.15% of premium, futures 0.05% of value, sell side
- Exchange transaction charge: NSE options 0.03553%, NSE futures 0.00183%, BSE options 0.0325%, BSE futures 0
- SEBI fee: ₹10 per crore of turnover
- Stamp duty: options 0.003%, futures 0.002%, buy side
- GST: 18%
- Brokerage: ₹20 per executed order (futures: 0.03% capped at ₹20)

Every one of these is an editable input in ⑥ Charges, so the script stays usable when rates change or if your broker's plan is different (for example a zero-brokerage plan: set brokerage to 0).

Lot-size presets (exchange revisions as of October 2026): NIFTY 65, BANKNIFTY 30, FINNIFTY 60, MIDCPNIFTY 120, NIFTYNXT50 25, SENSEX 20. Exchanges revise lot sizes from time to time; choose Custom in ③ Contract if yours differs. Underlyings without a preset show a reminder to set the lot size.


[b]SETTINGS AT A GLANCE[/b]

① Mode: Auto (this chart) or My Strategy
② Trade: instrument override, direction, entry price (clicked/typed or last price), lots
③ Contract: lot size (preset or custom), exchange (auto, NSE, BSE)
④ My Strategy legs: up to four legs
⑤ Habit projection: trades or strategy cycles per day, trading days per month
⑥ Charges: every rate, editable
⑦ Chart visuals: show/hide lines and cost zone, how far back the lines start, breakeven line style and width, colours of the entry line, breakeven line and cost zone, label position (right edge of the chart or start of the lines), label size, label background and label text colours
⑧ Table: position, text size and every table colour
All inputs are hidden from the status line to keep the chart clean.


[b]PRACTICAL USES[/b]

- Before a trade: see how far price must move just to cover costs. If the breakeven move is a large fraction of the typical bar range (the ATR row), the trade needs a sizeable move before it can show a net profit.
- Option sellers: see what share of the premium collected is consumed by charges.
- Frequent traders: enter your real number of trades per day and look at the monthly and yearly totals.
- Comparing scenarios: change lots, premium or brokerage and watch the breakeven and percentages update.


[b]LIMITATIONS[/b]

- This is an estimate for planning and education, not a contract note. Brokers differ: zero-brokerage plans, per-order caps, platform or DP charges and other fees are not included. Always check against your broker's contract note.
- IPFT (about ₹0.01 per crore on NSE) is ignored as negligible.
- The script models a normal square-off. Options held to expiry and exercised are charged STT on intrinsic value and may attract additional broker fees; exercise and assignment are not modelled.
- In My Strategy mode all legs share one lot size and exchange, and each leg is costed at its entry price.
- Auto-detection relies on TradingView's ticker format for Indian index options and futures; if it does not recognise a contract, set the Instrument manually.
- The labels follow the visible right edge of the chart, so the script recalculates briefly when the chart is scrolled. This is expected.
- The script shows no buy or sell signals and makes no forecast about price. It only calculates costs.

This script is for educational purposes only and is not investment advice. Futures and options trading carries a high level of risk.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © subrajitmishra
//
// F&O Charges & Breakeven Meter
// Estimates the full round-trip cost of an Indian index F&O trade (brokerage, STT, exchange
// transaction charge, SEBI fee, stamp duty, GST), the price move needed just to break even,
// and what those costs add up to over a month and a year at a chosen trading frequency.
// Educational estimate only. Every rate is an editable input. Verify with your broker's contract note.

indicator("F&O Charges & Breakeven Meter", shorttitle = "Charges Meter", overlay = true, max_lines_count = 10, max_labels_count = 10, max_boxes_count = 4)

// ═════════════════════════════ INPUTS ═════════════════════════════
string G_MODE = "① Mode"
string modeIn = input.string("Auto (this chart)", "Mode", options = ["Auto (this chart)", "My Strategy (legs below)"], group = G_MODE, tooltip = "Auto: costs one trade on the option or futures contract open on this chart.\nMy Strategy: costs up to four legs you enter below (e.g. a straddle or an iron fly).", display = display.none)

string G_TRADE = "② Trade — Auto mode"
string instIn   = input.string("Auto-detect", "Instrument", options = ["Auto-detect", "Option (CE/PE)", "Futures"], group = G_TRADE, tooltip = "Auto-detect reads the chart symbol. Override it if detection fails, e.g. to cost an option while viewing the index chart.", display = display.none)
string dirIn    = input.string("Buy first (long)", "Direction", options = ["Buy first (long)", "Sell first (short)"], group = G_TRADE, display = display.none)
string entrySrc = input.string("Clicked / typed price", "Entry price", options = ["Clicked / typed price", "Last price"], group = G_TRADE, inline = "en", display = display.none)
float  entryFix = input.price(100.0, "", group = G_TRADE, inline = "en", confirm = true, tooltip = "When you add the script, click the chart at your entry price. To pick a new entry: indicator ⋯ menu → Reset points and click again, or select the indicator and drag the handle, or type a new price here.", display = display.none)
int    lotsIn   = input.int(1, "Lots", minval = 1, group = G_TRADE, display = display.none)

string G_CON = "③ Contract"
string lotMode = input.string("Preset by underlying", "Lot size", options = ["Preset by underlying", "Custom"], group = G_CON, inline = "lot", display = display.none)
int    lotCust = input.int(65, "", minval = 1, group = G_CON, inline = "lot", tooltip = "Presets (exchange revisions, last checked Oct 2026): NIFTY 65 · BANKNIFTY 30 · FINNIFTY 60 · MIDCPNIFTY 120 · NIFTYNXT50 25 · SENSEX 20.\nExchanges revise lot sizes periodically — choose Custom if yours differs. Custom is also used for any underlying without a preset.", display = display.none)
string exchIn  = input.string("Auto-detect", "Exchange", options = ["Auto-detect", "NSE", "BSE"], group = G_CON, display = display.none)

string G_LEG = "④ My Strategy — legs (same underlying, lot size and exchange as above)"
bool   l1on = input.bool(true, "Leg 1", group = G_LEG, inline = "l1", display = display.none)
string l1sd = input.string("Sell", "", options = ["Buy", "Sell"], group = G_LEG, inline = "l1", display = display.none)
string l1ty = input.string("CE", "", options = ["CE", "PE", "FUT"], group = G_LEG, inline = "l1", display = display.none)
float  l1px = input.float(120.0, "Price", minval = 0, step = 0.05, group = G_LEG, inline = "l1", display = display.none)
int    l1lt = input.int(1, "Lots", minval = 1, group = G_LEG, inline = "l1", display = display.none)
bool   l2on = input.bool(true, "Leg 2", group = G_LEG, inline = "l2", display = display.none)
string l2sd = input.string("Sell", "", options = ["Buy", "Sell"], group = G_LEG, inline = "l2", display = display.none)
string l2ty = input.string("PE", "", options = ["CE", "PE", "FUT"], group = G_LEG, inline = "l2", display = display.none)
float  l2px = input.float(110.0, "Price", minval = 0, step = 0.05, group = G_LEG, inline = "l2", display = display.none)
int    l2lt = input.int(1, "Lots", minval = 1, group = G_LEG, inline = "l2", display = display.none)
bool   l3on = input.bool(false, "Leg 3", group = G_LEG, inline = "l3", display = display.none)
string l3sd = input.string("Buy", "", options = ["Buy", "Sell"], group = G_LEG, inline = "l3", display = display.none)
string l3ty = input.string("CE", "", options = ["CE", "PE", "FUT"], group = G_LEG, inline = "l3", display = display.none)
float  l3px = input.float(30.0, "Price", minval = 0, step = 0.05, group = G_LEG, inline = "l3", display = display.none)
int    l3lt = input.int(1, "Lots", minval = 1, group = G_LEG, inline = "l3", display = display.none)
bool   l4on = input.bool(false, "Leg 4", group = G_LEG, inline = "l4", display = display.none)
string l4sd = input.string("Buy", "", options = ["Buy", "Sell"], group = G_LEG, inline = "l4", display = display.none)
string l4ty = input.string("PE", "", options = ["CE", "PE", "FUT"], group = G_LEG, inline = "l4", display = display.none)
float  l4px = input.float(25.0, "Price", minval = 0, step = 0.05, group = G_LEG, inline = "l4", display = display.none)
int    l4lt = input.int(1, "Lots", minval = 1, group = G_LEG, inline = "l4", display = display.none)

string G_HAB = "⑤ Habit projection"
int tpdIn = input.int(5, "Trades (or strategy cycles) per day", minval = 1, group = G_HAB, display = display.none)
int dpmIn = input.int(20, "Trading days per month", minval = 1, maxval = 31, group = G_HAB, display = display.none)

string G_RATE = "⑥ Charges — editable (defaults as published, checked Oct 2026)"
float brokFlat   = input.float(20.0,    "Brokerage per executed order (₹)", minval = 0, step = 1, group = G_RATE, tooltip = "Options: flat per order. Futures: the lower of this and the % below. Set to your broker's plan.", display = display.none)
float futBrokPct = input.float(0.03,    "Futures brokerage % (capped at the flat fee)", minval = 0, step = 0.001, group = G_RATE, display = display.none)
float sttOpt     = input.float(0.15,    "STT options — sell side, % of premium", minval = 0, step = 0.005, group = G_RATE, tooltip = "Revised from 0.10% to 0.15% with effect from 1 Apr 2026.", display = display.none)
float sttFut     = input.float(0.05,    "STT futures — sell side, % of value", minval = 0, step = 0.005, group = G_RATE, tooltip = "Revised from 0.02% to 0.05% with effect from 1 Apr 2026.", display = display.none)
float txOptNSE   = input.float(0.03553, "Exchange txn — NSE options, % of premium", minval = 0, step = 0.0001, group = G_RATE, display = display.none)
float txOptBSE   = input.float(0.0325,  "Exchange txn — BSE options, % of premium", minval = 0, step = 0.0001, group = G_RATE, display = display.none)
float txFutNSE   = input.float(0.00183, "Exchange txn — NSE futures, % of value", minval = 0, step = 0.0001, group = G_RATE, display = display.none)
float txFutBSE   = input.float(0.0,     "Exchange txn — BSE futures, % of value", minval = 0, step = 0.0001, group = G_RATE, display = display.none)
float sebiCr     = input.float(10.0,    "SEBI fee (₹ per crore of turnover)", minval = 0, step = 1, group = G_RATE, display = display.none)
float stampOpt   = input.float(0.003,   "Stamp duty options — buy side, %", minval = 0, step = 0.0005, group = G_RATE, display = display.none)
float stampFut   = input.float(0.002,   "Stamp duty futures — buy side, %", minval = 0, step = 0.0005, group = G_RATE, display = display.none)
float gstPct     = input.float(18.0,    "GST % (on brokerage + exchange + SEBI)", minval = 0, step = 1, group = G_RATE, display = display.none)

string G_VIS = "⑦ Chart visuals (Auto mode)"
bool   showLines = input.bool(true, "Show entry, breakeven and cost zone", group = G_VIS, display = display.none)
int    lineBack  = input.int(40, "Lines start this many bars back", minval = 1, maxval = 400, group = G_VIS, display = display.none)
string beStyleIn = input.string("Dashed", "Breakeven line style", options = ["Solid", "Dashed", "Dotted"], group = G_VIS, inline = "be", display = display.none)
int    lineW     = input.int(2, "Width", minval = 1, maxval = 4, group = G_VIS, inline = "be", display = display.none)
color  cEntry    = input.color(#FFFFFF, "Entry line", group = G_VIS, inline = "lc", display = display.none)
color  cBE       = input.color(#D4A63A, "Breakeven line", group = G_VIS, inline = "lc", display = display.none)
color  cZone     = input.color(color.new(#D4A63A, 82), "Cost zone fill", group = G_VIS, inline = "lc", display = display.none)
string lblPosIn  = input.string("Right of last bar", "Labels at", options = ["Right of last bar", "Left of last bar"], group = G_VIS, inline = "lp", tooltip = "Right of last bar: labels sit in the empty space after the latest candle (set the gap with Offset).\nLeft of last bar: labels end at the latest candle and never go under the price scale, even when the chart is dragged fully to the right.", display = display.none)
int    lblOff    = input.int(6, "Offset (bars)", minval = 0, maxval = 100, group = G_VIS, inline = "lp", display = display.none)
string lblSizeIn = input.string("Normal", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VIS, display = display.none)
color  cLblBg    = input.color(#0B2624, "Label background", group = G_VIS, inline = "lb", display = display.none)
color  cLblBE    = input.color(#F2C94C, "Breakeven label text", group = G_VIS, inline = "lb", display = display.none)
color  cLblEn    = input.color(#FFFFFF, "Entry label text", group = G_VIS, inline = "lb", display = display.none)

string G_TBL = "⑧ Table"
string posIn     = input.string("Top right", "Position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Middle left", "Bottom left", "Top center", "Bottom center"], group = G_TBL, display = display.none)
string txtSizeIn = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = G_TBL, display = display.none)
color  cHeadBg   = input.color(#0B2624, "Header background", group = G_TBL, inline = "t1", display = display.none)
color  cHeadTx   = input.color(#F2C94C, "Header text", group = G_TBL, inline = "t1", display = display.none)
color  cBodyBg   = input.color(#0F3532, "Body background", group = G_TBL, inline = "t2", display = display.none)
color  cBodyTx   = input.color(#FFFFFF, "Body text", group = G_TBL, inline = "t2", display = display.none)
color  cMuted    = input.color(#FFFFFF, "Label text (left column)", group = G_TBL, inline = "t3", display = display.none)
color  cAccent   = input.color(#F2C94C, "Totals / accent", group = G_TBL, inline = "t3", display = display.none)
color  cTotBg    = input.color(#16463F, "Totals background", group = G_TBL, inline = "t4", display = display.none)
color  cWarn     = input.color(#E07A5F, "Warnings", group = G_TBL, inline = "t4", display = display.none)
color  cFrame    = input.color(#D4A63A, "Frame", group = G_TBL, inline = "t5", display = display.none)

// ═════════════════════════════ HELPERS ═════════════════════════════
tSize = switch txtSizeIn
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

lSize = switch lblSizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    => size.normal

tPos = switch posIn
    "Middle right"  => position.middle_right
    "Bottom right"  => position.bottom_right
    "Top left"      => position.top_left
    "Middle left"   => position.middle_left
    "Bottom left"   => position.bottom_left
    "Top center"    => position.top_center
    "Bottom center" => position.bottom_center
    => position.top_right

beStyle = switch beStyleIn
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

fRs(float x)  => "₹ " + str.tostring(x, "#,##0.00")
fRs0(float x) => "₹ " + str.tostring(math.round(x), "#,##0")
fNum(float x) => str.tostring(x, "#,##0.00")
fPct(float x) => str.tostring(x, "0.00") + " %"

fBar(float pct, float full) =>
    int n = int(math.round(math.min(math.max(pct, 0.0), full) / full * 10.0))
    string s = ""
    for i = 1 to 10
        s := s + (i <= n ? "▰" : "▱")
    s

// Underlying from the chart ticker (longest names checked first)
fUnder(string t) =>
    string u = "OTHER"
    if str.startswith(t, "BANKNIFTY")
        u := "BANKNIFTY"
    else if str.startswith(t, "FINNIFTY")
        u := "FINNIFTY"
    else if str.startswith(t, "MIDCPNIFTY")
        u := "MIDCPNIFTY"
    else if str.startswith(t, "NIFTYNXT50")
        u := "NIFTYNXT50"
    else if str.startswith(t, "NIFTY")
        u := "NIFTY"
    else if str.startswith(t, "SENSEX50")
        u := "SENSEX50"
    else if str.startswith(t, "SENSEX")
        u := "SENSEX"
    else if str.startswith(t, "BANKEX")
        u := "BANKEX"
    u

fLotPreset(string u) =>
    switch u
        "NIFTY"      => 65
        "BANKNIFTY"  => 30
        "FINNIFTY"   => 60
        "MIDCPNIFTY" => 120
        "NIFTYNXT50" => 25
        "SENSEX"     => 20
        => 0

// ═════════════════════════════ DETECTION ═════════════════════════════
string tk      = str.upper(syminfo.ticker)
string optTag  = str.match(tk, "[CP][0-9]+(\\.[0-9]+)?$")
bool   autoOpt = optTag != ""
bool   autoFut = not autoOpt and syminfo.type == "futures"
bool   isOpt   = instIn == "Option (CE/PE)" ? true : instIn == "Futures" ? false : autoOpt
bool   known   = instIn != "Auto-detect" or autoOpt or autoFut
string cpTxt   = autoOpt ? (str.substring(optTag, 0, 1) == "C" ? "CE" : "PE") : (isOpt ? "Option" : "")
float  strike  = autoOpt ? str.tonumber(str.substring(optTag, 1)) : na
string under   = fUnder(tk)
int    preset  = fLotPreset(under)
int    lotSize = lotMode == "Custom" ? lotCust : (preset > 0 ? preset : lotCust)
bool   lotWarn = lotMode != "Custom" and preset == 0
bool   isBSE   = exchIn == "BSE" or (exchIn == "Auto-detect" and syminfo.prefix == "BSE")
string exTxt   = isBSE ? "BSE" : "NSE"

// ═════════════════════════════ COST MODEL ═════════════════════════════
// Round trip: one buy order + one sell order of `qty` units.
fCharges(bool opt, bool buyFirst, float entryPx, float exitPx, float qty) =>
    float buyPx   = buyFirst ? entryPx : exitPx
    float sellPx  = buyFirst ? exitPx : entryPx
    float buyVal  = buyPx * qty
    float sellVal = sellPx * qty
    float turn    = buyVal + sellVal
    float brok    = opt ? 2.0 * brokFlat : math.min(buyVal * futBrokPct / 100.0, brokFlat) + math.min(sellVal * futBrokPct / 100.0, brokFlat)
    float stt     = sellVal * (opt ? sttOpt : sttFut) / 100.0
    float txR     = opt ? (isBSE ? txOptBSE : txOptNSE) : (isBSE ? txFutBSE : txFutNSE)
    float txn     = turn * txR / 100.0
    float sebi    = turn * sebiCr / 10000000.0
    float stamp   = buyVal * (opt ? stampOpt : stampFut) / 100.0
    float gst     = (brok + txn + sebi) * gstPct / 100.0
    [brok, stt, txn, sebi, stamp, gst, brok + stt + txn + sebi + stamp + gst]

// Exit price at which gross P&L exactly pays the round-trip charges (charges recomputed at that exit).
fBreakeven(bool opt, bool buyFirst, float entryPx, float qty) =>
    float ex = entryPx
    for i = 0 to 4
        [b0, s0, t0, se0, st0, g0, tot] = fCharges(opt, buyFirst, entryPx, ex, qty)
        ex := buyFirst ? entryPx + tot / qty : entryPx - tot / qty
    ex

float atr14 = ta.atr(14)

// ═════════════════════════════ DRAWING OBJECTS ═════════════════════════════
var table tb     = na
var line  lEntry = na
var line  lBE    = na
var box   bZone  = na
var label lbBE   = na
var label lbEn   = na

fCell(table t, int c, int r, string txt, color tc, color bg, string ha) =>
    string pad = ha == text.align_center ? txt : "  " + txt + "  "
    table.cell(t, c, r, pad, text_color = tc, bgcolor = bg, text_size = tSize, text_halign = ha)

bool autoMode = modeIn == "Auto (this chart)"

if barstate.islast
    int cols = autoMode ? 2 : 6
    table.delete(tb)
    tb := table.new(tPos, cols, 24, bgcolor = cBodyBg, frame_color = cFrame, frame_width = 1, border_color = color.new(cFrame, 70), border_width = 1)
    line.delete(lEntry)
    line.delete(lBE)
    box.delete(bZone)
    label.delete(lbBE)
    label.delete(lbEn)

    fCell(tb, 0, 0, "CHARGES & BREAKEVEN", cHeadTx, cHeadBg, text.align_center)
    table.merge_cells(tb, 0, 0, cols - 1, 0)

    if autoMode
        // ───────── AUTO MODE ─────────
        bool  buyFirst = dirIn == "Buy first (long)"
        float entry    = entrySrc == "Last price" ? close : entryFix
        float qty      = float(lotsIn * lotSize)
        string instTxt = under + (isOpt ? (na(strike) ? " " + cpTxt : " " + str.tostring(strike, "#") + " " + cpTxt) : " FUT")
        string subTxt  = instTxt + " · " + exTxt + " · " + str.tostring(lotsIn) + " lot × " + str.tostring(lotSize) + " · " + (buyFirst ? "Long" : "Short")
        fCell(tb, 0, 1, subTxt, cMuted, cHeadBg, text.align_center)
        table.merge_cells(tb, 0, 1, 1, 1)

        if not known
            fCell(tb, 0, 2, "Open an index option or futures chart,\nor set Instrument in settings (②).", cWarn, cBodyBg, text.align_center)
            table.merge_cells(tb, 0, 2, 1, 2)
        else if na(entry) or entry <= 0
            fCell(tb, 0, 2, "Entry price must be above zero (②).", cWarn, cBodyBg, text.align_center)
            table.merge_cells(tb, 0, 2, 1, 2)
        else
            float bePx = fBreakeven(isOpt, buyFirst, entry, qty)
            [brok, stt, txn, sebi, stamp, gst, tot] = fCharges(isOpt, buyFirst, entry, bePx, qty)
            float beMove = math.abs(bePx - entry)
            float pctPrem = tot / (entry * qty) * 100.0
            float perMonth = tot * tpdIn * dpmIn
            int r = 2
            fCell(tb, 0, r, isOpt ? "Entry premium" : "Entry price", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fNum(entry), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Brokerage (2 orders)", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(brok), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "STT (sell side " + str.tostring(isOpt ? sttOpt : sttFut) + "%)", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(stt), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Exchange txn (" + exTxt + ")", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(txn), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "SEBI fee", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(sebi), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Stamp duty (buy side)", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(stamp), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "GST " + str.tostring(gstPct) + "%", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs(gst), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "TOTAL per round trip", cAccent, cTotBg, text.align_left)
            fCell(tb, 1, r, fRs(tot), cAccent, cTotBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Move needed to break even", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, (buyFirst ? "+" : "−") + fNum(beMove) + " pts", cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Breakeven price", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fNum(bePx), cAccent, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Charges vs " + (isOpt ? "premium" : "value"), cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fPct(pctPrem) + "  " + fBar(pctPrem, isOpt ? 5.0 : 0.5), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Breakeven vs ATR(14), this TF", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, na(atr14) or atr14 == 0 ? "—" : str.tostring(beMove / atr14, "0.00") + " × ATR", cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "HABIT · " + str.tostring(tpdIn) + "/day × " + str.tostring(dpmIn) + " days", cHeadTx, cHeadBg, text.align_center)
            table.merge_cells(tb, 0, r, 1, r)
            r += 1
            fCell(tb, 0, r, "Charges per month", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs0(perMonth), cAccent, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Charges per year (×12)", cMuted, cBodyBg, text.align_left)
            fCell(tb, 1, r, fRs0(perMonth * 12), cAccent, cBodyBg, text.align_right)
            r += 1
            if lotWarn
                fCell(tb, 0, r, "No lot-size preset — set Custom (③)", cWarn, cBodyBg, text.align_center)
                table.merge_cells(tb, 0, r, 1, r)
                r += 1
            fCell(tb, 0, r, "Educational estimate · rates editable (⑥)\nVerify with your contract note", cMuted, cHeadBg, text.align_center)
            table.merge_cells(tb, 0, r, 1, r)

            // ───────── Chart visuals ─────────
            if showLines
                int x1 = bar_index - lineBack
                int x2 = bar_index + 1
                bZone  := box.new(x1, math.max(entry, bePx), x2, math.min(entry, bePx), border_color = color.new(cBE, 100), bgcolor = cZone, extend = extend.right)
                lEntry := line.new(x1, entry, x2, entry, color = cEntry, width = 1, style = line.style_dotted, extend = extend.right)
                lBE    := line.new(x1, bePx, x2, bePx, color = cBE, width = lineW, style = beStyle, extend = extend.right)
                bool   beAbove = bePx >= entry
                string beTxt   = "Breakeven " + fNum(bePx) + "   " + (buyFirst ? "+" : "−") + fNum(beMove) + " pts · " + fRs(tot) + " charges"
                string enTxt   = "Entry " + fNum(entry)
                bool   onRight = lblPosIn == "Right of last bar"
                int    xl      = onRight ? bar_index + lblOff : bar_index - lblOff
                string sUp     = onRight ? label.style_label_lower_left : label.style_label_lower_right
                string sDn     = onRight ? label.style_label_upper_left : label.style_label_upper_right
                lbBE := label.new(xl, bePx, beTxt, style = beAbove ? sUp : sDn, color = cLblBg, textcolor = cLblBE, size = lSize)
                lbEn := label.new(xl, entry, enTxt, style = beAbove ? sDn : sUp, color = cLblBg, textcolor = cLblEn, size = lSize)
    else
        // ───────── MY STRATEGY MODE ─────────
        fCell(tb, 0, 1, under + " · " + exTxt + " · lot " + str.tostring(lotSize) + " · round trip per leg", cMuted, cHeadBg, text.align_center)
        table.merge_cells(tb, 0, 1, 5, 1)
        fCell(tb, 0, 2, "Leg", cHeadTx, cHeadBg, text.align_center)
        fCell(tb, 1, 2, "Side", cHeadTx, cHeadBg, text.align_center)
        fCell(tb, 2, 2, "Type", cHeadTx, cHeadBg, text.align_center)
        fCell(tb, 3, 2, "Price", cHeadTx, cHeadBg, text.align_center)
        fCell(tb, 4, 2, "Lots", cHeadTx, cHeadBg, text.align_center)
        fCell(tb, 5, 2, "Charges", cHeadTx, cHeadBg, text.align_center)

        array<bool>   aOn = array.from(l1on, l2on, l3on, l4on)
        array<string> aSd = array.from(l1sd, l2sd, l3sd, l4sd)
        array<string> aTy = array.from(l1ty, l2ty, l3ty, l4ty)
        array<float>  aPx = array.from(l1px, l2px, l3px, l4px)
        array<int>    aLt = array.from(l1lt, l2lt, l3lt, l4lt)

        float totAll = 0.0
        float netPrem = 0.0
        int   nLegs = 0
        int   r = 3
        for i = 0 to 3
            if array.get(aOn, i)
                bool   opt  = array.get(aTy, i) != "FUT"
                bool   bF   = array.get(aSd, i) == "Buy"
                float  px   = array.get(aPx, i)
                float  q    = float(array.get(aLt, i) * lotSize)
                [b1, s1, t1, se1, st1, g1, tot1] = fCharges(opt, bF, px, px, q)
                totAll += tot1
                nLegs += 1
                if opt
                    netPrem += (bF ? -1.0 : 1.0) * px * q
                color sideC = bF ? cBodyTx : cAccent
                fCell(tb, 0, r, str.tostring(i + 1), cMuted, cBodyBg, text.align_center)
                fCell(tb, 1, r, array.get(aSd, i), sideC, cBodyBg, text.align_center)
                fCell(tb, 2, r, array.get(aTy, i), cBodyTx, cBodyBg, text.align_center)
                fCell(tb, 3, r, fNum(px), cBodyTx, cBodyBg, text.align_right)
                fCell(tb, 4, r, str.tostring(array.get(aLt, i)), cBodyTx, cBodyBg, text.align_center)
                fCell(tb, 5, r, fRs(tot1), cBodyTx, cBodyBg, text.align_right)
                r += 1

        if nLegs == 0
            fCell(tb, 0, r, "Switch on at least one leg (④).", cWarn, cBodyBg, text.align_center)
            table.merge_cells(tb, 0, r, 5, r)
        else
            bool  credit = netPrem >= 0
            float absNet = math.abs(netPrem)
            float pctNet = absNet > 0 ? totAll / absNet * 100.0 : na
            float perMonth = totAll * tpdIn * dpmIn
            fCell(tb, 0, r, "TOTAL charges (all legs, in and out)", cAccent, cTotBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, fRs(totAll), cAccent, cTotBg, text.align_right)
            r += 1
            fCell(tb, 0, r, credit ? "Net premium received" : "Net premium paid", cMuted, cBodyBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, fRs(absNet), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Charges as % of net premium", cMuted, cBodyBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, na(pctNet) ? "—" : fPct(pctNet) + "  " + fBar(pctNet, 10.0), cBodyTx, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, credit ? "Credit left after charges" : "Debit including charges", cMuted, cBodyBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, fRs(credit ? absNet - totAll : absNet + totAll), cAccent, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "HABIT · " + str.tostring(tpdIn) + " cycles/day × " + str.tostring(dpmIn) + " days", cHeadTx, cHeadBg, text.align_center)
            table.merge_cells(tb, 0, r, 5, r)
            r += 1
            fCell(tb, 0, r, "Charges per month", cMuted, cBodyBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, fRs0(perMonth), cAccent, cBodyBg, text.align_right)
            r += 1
            fCell(tb, 0, r, "Charges per year (×12)", cMuted, cBodyBg, text.align_left)
            table.merge_cells(tb, 0, r, 4, r)
            fCell(tb, 5, r, fRs0(perMonth * 12), cAccent, cBodyBg, text.align_right)
            r += 1
            if lotWarn
                fCell(tb, 0, r, "No lot-size preset — set Custom (③)", cWarn, cBodyBg, text.align_center)
                table.merge_cells(tb, 0, r, 5, r)
                r += 1
            fCell(tb, 0, r, "Each leg costed as a round trip at its entry price\nEducational estimate · verify with your contract note", cMuted, cHeadBg, text.align_center)
            table.merge_cells(tb, 0, r, 5, r)
````
