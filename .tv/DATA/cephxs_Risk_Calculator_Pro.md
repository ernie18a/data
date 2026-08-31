<!-- tradingview-pine-id: PUB;87d1e3b40d3940e18a8656c3094a1fcc -->
<!-- tradingviewscripts-format: 1 -->
# cephxs / Risk Calculator [Pro +]

Source: https://www.tradingview.com/script/8vJ3F4oL-cephxs-Risk-Calculator-Pro/

## Description

Risk Calculator [Pro +]
Type your stop in ticks and the dollars you accept to lose. The table tells you how many contracts fit, and what those contracts actually risk.

WHAT IT DOES
Position sizing is the one calculation that decides whether a losing streak is survivable, and it is the one most people do in their head, wrong, on the way into a trade.

This is a manual sizer. Two inputs, one small table, nothing else on your chart. No signals, no boxes, no arrows, no alerts. It reads the symbol you are on, converts your stop from ticks into dollars, and reports how many contracts fit inside the risk you set.

It reports both the standard contract and its micro sibling, side by side, every time. There is no micro toggle to remember, because the choice between one mini and twelve micros is a trading decision, not a setting. This tool is calibrated specifically to Futures contracts, Updates will follow soon for support for Forex CFD Lots and instructions on how to understand them and speed up your trading for cross platform trading (externl execution and TradingView charting for example.)

HOW IT WORKS
Three ideas, and the third is the one that gets sizers wrong.

1. Ticks, not points. You think in ticks, because that is what your stop is measured in on the DOM. Contract specifications are quoted per point. The script converts between them using the symbol's own tick size, so a 50-tick stop on [symbol="CME_MINI:RTY1!"]CME_MINI:RTY1![/symbol] (0.1 tick) and a 50-tick stop on [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] (0.25 tick) are correctly priced as different distances instead of being treated as the same number.

2. A contract pair, not a contract. The script carries a lookup of index, metal, energy and FX futures. Each entry stores the dollar value of a one-point move for the standard contract and for its micro. The same pair resolves whichever side of it you are charting: load [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] or load [symbol="CME_MINI:MNQ1!"]CME_MINI:MNQ1![/symbol] and you get the same two columns, in the same order. Micro tickers are matched before their standard root, so [symbol="CME_MINI:MNQ1!"]CME_MINI:MNQ1![/symbol] is never mistaken for the [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] entry.

3. Floor division, and no rounding up. Contract counts come from your risk budget divided by the dollar cost of one contract at your stop, rounded down. A partial contract is not a contract. This means the reported figures are never the budget read back at you — they are what the position genuinely risks, which is at or under the budget by the size of the remainder.

HOW TO READ THE TABLE
Four stacked rows. The example below is a 25-tick stop with a $400 budget on [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] (Same as the publication Screenshot):

ES1!
25 ticks
$313 / $375
1 mini / 12 micros

[*] Row 1 — Asset. The symbol the numbers were computed for. Confirms the script resolved what you think it resolved.
[*] Row 2 — Stop. Your stop, as typed.
[*] Row 3 — Risk. What each position actually loses if the stop is hit.
[*] Row 4 — Size. What to place.

Rows 3 and 4 are a pair and read column for column. Standard contract on the left, micro on the right. $313 is what that 1 mini risks. $375 is what those 12 micros risk. Both sit under the $400 budget. Neither is the budget itself.

The colors are the warnings.

[*] Grey — normal. Both sides are tradeable.
[*] Amber — one standard contract already exceeds your budget. Its count reads 0. Only the micro column is tradeable.
[*] Red — even one micro exceeds your budget. Row 4 reads "Risk too big", and row 3 switches to showing what one of each contract would cost, so you can see how far over you are.

Every cell carries a tooltip with the full arithmetic: ticks, dollars per tick, dollars per contract, and the budget the counts were divided by. Hover it when a number surprises you.

HOW TO USE

[*] Load it on the futures contract you trade.
[*] Set Preferred Risk once. This is your per-trade loss limit in dollars, and it should not change trade to trade.
[*] Before each entry, set Stop Size to where your stop actually goes — below the swing, past the level, wherever your method puts it. Do not pick the stop that makes the size convenient.
[*] Read row 4 and place that size.
[*] If the block turns red, the trade is not untradeable — the stop is too wide for your account at this risk. Wait for a tighter structure rather than moving the stop in.

The order matters. Risk is fixed, stop is dictated by the chart, and size is the output of those two. Sizing first and then hunting for a stop that fits is the habit this table exists to break.

INPUTS

[*] Stop Size (ticks): 25. Distance to your stop, in ticks. Drives everything. Fully customizable.
[*] Preferred Risk ([symbol="AMEX:USD"]AMEX:USD[/symbol]): 400. Maximum dollars you accept to lose. Both contract counts stay at or below it. Add a small leeway $50 if you're willing to get even closer to your preferred risk.
[*] Table Position: Bottom Left. Any of the nine pane anchors.
[*] Layout: Values Only, or Labeled (adds a dimmed caption column).
[*] Text Align: Left, Center, Right. Applies to the value column.
[*] Edge Padding (rows): 2. Blank rows between the block and the pane edge it hugs. Inert on the three Middle positions, which have no edge to lift off.
[*] Text / Warn / Error colors: the three states above, in that order.
[*] Table Text Size: Standard. Compact through Extra Large, or Auto.

The table draws as plain text with no background and no border, so it sits on the chart without covering price.

SYMBOLS COVERED
Indices: [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] · [symbol="CME_MINI:MNQ1!"]CME_MINI:MNQ1![/symbol] · [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] · [symbol="CME_MINI:MES1!"]CME_MINI:MES1![/symbol] · [symbol="CBOT_MINI:YM1!"]CBOT_MINI:YM1![/symbol] · [symbol="CBOT_MINI:MYM1!"]CBOT_MINI:MYM1![/symbol] · [symbol="CME_MINI:RTY1!"]CME_MINI:RTY1![/symbol] · [symbol="CME_MINI:M2K1!"]CME_MINI:M2K1![/symbol]
Metals: [symbol="COMEX:GC1!"]COMEX:GC1![/symbol] · [symbol="COMEX_MINI:MGC1!"]COMEX_MINI:MGC1![/symbol] · [symbol="COMEX:SI1!"]COMEX:SI1![/symbol] · [symbol="COMEX_MINI:SIL1!"]COMEX_MINI:SIL1![/symbol] · [symbol="COMEX:HG1!"]COMEX:HG1![/symbol] · [symbol="COMEX_MINI:MHG1!"]COMEX_MINI:MHG1![/symbol]
Energy: [symbol="NYMEX:CL1!"]NYMEX:CL1![/symbol] · [symbol="NYMEX:MCL1!"]NYMEX:MCL1![/symbol] · [symbol="NYMEX:RB1!"]NYMEX:RB1![/symbol] · [symbol="NYMEX:HO1!"]NYMEX:HO1![/symbol]
FX: [symbol="CME:6E1!"]CME:6E1![/symbol] · [symbol="CME_MINI:M6E1!"]CME_MINI:M6E1![/symbol] · [symbol="CME:6B1!"]CME:6B1![/symbol] · [symbol="CME_MINI:M6B1!"]CME_MINI:M6B1![/symbol] · [symbol="CME:6C1!"]CME:6C1![/symbol] · 

[symbol="NYMEX:RB1!"]NYMEX:RB1![/symbol] and [symbol="NYMEX:HO1!"]NYMEX:HO1![/symbol] have no micro, so they report a single column. Every other symbol reports the pair.

LIMITS — read these

[*] It does not know your account. There is no balance, no margin check, no daily loss limit. If your broker's day-trade margin will not carry 12 micros, the table will still say 12. That number is what your risk allows, not what your buying power allows.
[*] It does not know your position. It is a pre-trade calculator, not a position tracker. It never reads open orders or fills.
[*] Commissions and fees are excluded. Twelve micros cost meaningfully more in round-turn fees than one mini for the same risk. That gap is real and this table does not show it.
[*] Off-list symbols degrade, they do not fail. On anything outside the list above, the script falls back to the symbol's own point value, finds no sibling, and collapses to a single column labeled in plain "contracts". Stocks, crypto and forex spot will produce a number this way. Confirm it against your broker before you trade it.
[*] Futures-first by design. The tick-to-dollar chain assumes a contract with a fixed point value. It is not a share sizer.
[*] No performance claim is made or implied. Correct sizing controls the size of a loss. It does not make a losing setup profitable.

FAQ
why does it show both minis and micros instead of picking one?
Because the right answer depends on what you are doing, not on the arithmetic. Twelve micros let you scale out in twelve pieces and cost more in fees. One mini is cheaper and all-or-nothing. The table gives you both and stays out of the decision.

why is the risk figure lower than my preferred risk?
Rounding down. If one contract costs $400 and your budget is $500, one contract fits and $100 goes unused, because 1.25 contracts do not exist. The figure shown is the real risk of the real position.

it says "Risk too big" — is something broken?
No. One micro at your current stop costs more than your entire budget. Either the stop is wider than your account can carry at that risk, or the risk input is set low. Row 3 shows what one of each contract would cost, so you can see the gap.

does it repaint?
There is nothing to repaint. The table is computed on the last bar from your two inputs and the symbol's specification. It uses no history, no higher timeframe requests and no future data.

my broker's contract value differs from the table.
Trust your broker. Contract specifications change and exchanges list variants. The tooltip shows the exact dollars-per-tick used, so you can compare in one look. 

DISCLAIMER
This script is a calculator. It gives no trade signals and makes no forecast. Contract specifications are hardcoded and can become out of date, and off-list symbols use a fallback value — always confirm the numbers against your broker before you place an order. Trading futures involves substantial risk of loss and is not suitable for every investor. Nothing here is financial advice.

Open source under the Mozilla Public License 2.0. Read the code, fork it, change the contract table to suit your instruments.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cephxs
// © fstarcapital

//@version=6

// - - - - - - - - -
// cephxs / Risk Calculator [Pro +]
//
// A manual position sizer. You give it two numbers: the stop distance in ticks,
// and the dollars you accept to lose. It gives you one table. There are no
// signals, no drawings, and no alerts.
//
//   NQ1!
//   40 ticks
//   $400 / $480
//   1 mini / 12 micros
//
// THE TABLE
// Four rows: the chart asset, the stop as typed, the risk of each position, and
// the size to place. Rows 3 and 4 are a pair. The main contract is on the left,
// and the micro contract is on the right. The main contract is the mini or the
// full contract, whichever the asset has.
//
// The two columns align. $400 is the risk of that 1 mini. $480 is the risk of
// those 12 micros. Neither figure repeats the preferred risk. Each figure is a
// contract count multiplied by the cost of the stop for one contract. Each
// figure lands at or below the preferred risk.
//
// The table always shows both sides. There is no micro preference to set. The
// table reports both counts, and you make the choice.
//
// COLOR STATES
// Grey:  both sides fit inside the preferred risk.
// Amber: one main contract costs more than the preferred risk. The main count
//        reads 0. Only the micro column is tradeable.
// Red:   one micro contract also costs more than the preferred risk. Row 4 reads
//        "Risk too big". Row 3 then shows the cost of ONE of each contract,
//        because there is no position to report.
//
// THE CONTRACT PAIR
// The resolveContract function holds a registry of futures. Each entry stores
// the point value of the chart asset and the point value of its sibling. The
// same pair resolves from either side, so NQ and MNQ give the same two columns.
//
// Off-registry symbols still work. syminfo.pointvalue replaces the registry
// value, and there is no sibling. Both pair rows then collapse to one figure in
// plain "contracts". The micro-less futures in the registry (RB, HO) behave the
// same way.
//
// TICKS, NOT POINTS
// The registry stores dollars per 1.0 of PRICE, which is one point. Every figure
// passes through syminfo.mintick first: ticks → price distance → dollars. The
// mintick of RTY is 0.1, so one tick is $5.00 on the mini and $0.50 on the
// micro. A 50-tick stop there costs $250 / $25.
//
// Every cell carries the same tooltip. It shows the full chain, and it shows the
// preferred risk that divided the counts. If a figure looks wrong, read it.
//
// THE TABLE CHROME
// The table draws as plain text. There is no background and no border. You can
// set the pane position, the layout, the text align, the text size and the three
// state colors. Edge padding is the one setting that reads the position. The
// script lays the blank rows on the side that faces the pane edge. The three
// Middle positions skip the blank rows, because a centered table has no edge.
// - - - - - - - - -

indicator("cephxs / Risk Calculator [Pro +]",
         shorttitle = "cephxs / Risk Calculator [Pro +]",
         overlay = true,
         calc_bars_count = 1)

// - - - - - - - - -
// Input Groups
string g_risk   = "1. 💰 Risk Parameters"
string g_table  = "2. 📊 Table"
string g_access = "3. ♿ Accessibility"

// - - - - - - - - -
// Constants
color C_TRANSPARENT = color.new(color.white, 100)

// Risk table text — normal, auto-downgraded-to-micros, and stop-too-wide.
color RISK_TXT_COL  = #787b86
color RISK_WARN_COL = #ff8c00
color RISK_ERR_COL  = #db5755

// Content rows (asset / stop / risk / size) and the maximum blank rows that can
// be stacked against the pane edge. The table is built to hold both at once.
const int RISK_ROWS = 4
const int RISK_PAD_MAX = 5

// - - - - - - - - -
// Types
// Contract Spec — resolved sizing profile for the chart asset + its sibling.
type ContractSpec
    bool   found          = false
    string variant        = ""     // "Mini" / "Micro" / "Full" (chart asset)
    float  pointValue     = 0.0    // chart asset $ per 1.0 price move / contract
    bool   hasSibling     = false
    string siblingVariant = ""     // sibling label
    float  siblingPV      = 0.0

// - - - - - - - - -
// Inputs — Risk Parameters
int   stopTicksInput  = input.int(40, 'Stop Size (ticks)', minval = 1, group = g_risk, tooltip = "How far away your stop sits, in ticks. Drives the whole table.")
float riskAmountInput = input.float(500, 'Preferred Risk ($USD)', minval = 0, group = g_risk, tooltip = "The maximum dollars you accept to lose on the setup. Both contract counts stay at or below it.")

// - - - - - - - - -
// Inputs — Table
string tablePosInput      = input.string("Bottom Left", "📊 Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = g_table, tooltip = "Which of the nine pane anchors the block sits on.")
string tableLayoutInput   = input.string("Values Only", "Layout", options = ["Values Only", "Labeled"], group = g_table, tooltip = "Values Only: the four figures alone.\nLabeled: a dimmed caption column beside them.")
string tableAlignInput    = input.string("Left", "Text Align", options = ["Left", "Center", "Right"], group = g_table, tooltip = "Alignment of the value column. Captions always read left.")
int    tablePadInput      = input.int(2, "Edge Padding (rows)", minval = 0, maxval = RISK_PAD_MAX, group = g_table, active = tablePosInput != "Middle Left" and tablePosInput != "Middle Center" and tablePosInput != "Middle Right", tooltip = "Blank rows laid between the block and the pane edge it hugs.\nTip: greys out on the three Middle positions — nothing to lift off there.")
color  riskTxtColInput    = input.color(RISK_TXT_COL, "Text / Warn / Error", inline = "txt", group = g_table, tooltip = "Left to right: normal, only-the-micros-fit, nothing-fits.")
color  riskWarnColInput   = input.color(RISK_WARN_COL, "", inline = "txt", group = g_table)
color  riskErrColInput    = input.color(RISK_ERR_COL, "", inline = "txt", group = g_table)

// - - - - - - - - -
// Inputs — Accessibility
string tableTextScaleInput = input.string("Standard", "♿ Table Text Size", options = ["Auto", "Compact", "Standard", "Comfortable", "Extra Large"], group = g_access, tooltip = "Text size for every table cell.\nAuto: TradingView picks.\nStandard: the house default.")

// - - - - - - - - -
// Resolved table settings
// Text size — one preset, resolved once, read by every cell.
// @param base    (string) Baseline size.* constant to offset from.
// @param offset  (int)    Steps up (+) or down (-) the tiny → huge ladder.
scaleSize(string base, int offset) =>
    int baseIdx   = base == size.tiny ? 0 : base == size.small ? 1 : base == size.normal ? 2 : base == size.large ? 3 : base == size.huge ? 4 : 1
    int targetIdx = math.max(0, math.min(4, baseIdx + offset))
    targetIdx == 0 ? size.tiny : targetIdx == 1 ? size.small : targetIdx == 2 ? size.normal : targetIdx == 3 ? size.large : size.huge

// @param preset  (string) One of 'Compact', 'Standard', 'Comfortable', 'Extra Large'.
scalePresetToOffset(string preset) =>
    switch preset
        "Compact"     => -1
        "Comfortable" => 1
        "Extra Large" => 2
        => 0

// Baseline is size.small, so 'Standard' is the house default and every other
// preset is one step off it.
string resolvedTableSize = tableTextScaleInput == "Auto" ? size.auto : scaleSize(size.small, scalePresetToOffset(tableTextScaleInput))

// The nine pane anchors.
tablePosition(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.bottom_left

string resolvedAlign = tableAlignInput == "Center" ? text.align_center : tableAlignInput == "Right" ? text.align_right : text.align_left

// Padding hangs off the pane edge the block is anchored to: above for the Top
// row, below for the Bottom row, and nowhere for Middle — a centered block has
// no edge to be lifted off, so the setting goes inert rather than shifting it.
bool riskPadAbove = str.contains(tablePosInput, "Top")
bool riskPadBelow = str.contains(tablePosInput, "Bottom")
int  riskPadRows  = (riskPadAbove or riskPadBelow) ? tablePadInput : 0
int  riskRowOff   = riskPadAbove ? riskPadRows : 0

bool riskLabeled = tableLayoutInput == "Labeled"

// - - - - - - - - -
// Contract registry
// Resolve the chart ticker to a contract profile. Micro variants are matched
// FIRST (they contain the standard root, e.g. MNQ contains NQ). Point-values
// are $ per 1.0 of quoted price, per contract. Futures only for now.
resolveContract(string t) =>
    ContractSpec s = ContractSpec.new()
    // Indices
    if str.contains(t, 'MNQ')
        s := ContractSpec.new(true, 'Micro', 2.0, true, 'Mini', 20.0)
    else if str.contains(t, 'NQ')
        s := ContractSpec.new(true, 'Mini', 20.0, true, 'Micro', 2.0)
    else if str.contains(t, 'MES')
        s := ContractSpec.new(true, 'Micro', 5.0, true, 'Mini', 50.0)
    else if str.contains(t, 'ES')
        s := ContractSpec.new(true, 'Mini', 50.0, true, 'Micro', 5.0)
    else if str.contains(t, 'MYM')
        s := ContractSpec.new(true, 'Micro', 0.5, true, 'Mini', 5.0)
    else if str.contains(t, 'YM')
        s := ContractSpec.new(true, 'Mini', 5.0, true, 'Micro', 0.5)
    else if str.contains(t, 'M2K')
        s := ContractSpec.new(true, 'Micro', 5.0, true, 'Mini', 50.0)
    else if str.contains(t, 'RTY')
        s := ContractSpec.new(true, 'Mini', 50.0, true, 'Micro', 5.0)
    // Metals
    else if str.contains(t, 'MGC')
        s := ContractSpec.new(true, 'Micro', 10.0, true, 'Full', 100.0)
    else if str.contains(t, 'GC')
        s := ContractSpec.new(true, 'Full', 100.0, true, 'Micro', 10.0)
    else if str.contains(t, 'SIL')
        s := ContractSpec.new(true, 'Micro', 1000.0, true, 'Full', 5000.0)
    else if str.contains(t, 'SI')
        s := ContractSpec.new(true, 'Full', 5000.0, true, 'Micro', 1000.0)
    else if str.contains(t, 'MHG')
        s := ContractSpec.new(true, 'Micro', 2500.0, true, 'Full', 25000.0)
    else if str.contains(t, 'HG')
        s := ContractSpec.new(true, 'Full', 25000.0, true, 'Micro', 2500.0)
    // Energy
    else if str.contains(t, 'MCL')
        s := ContractSpec.new(true, 'Micro', 100.0, true, 'Full', 1000.0)
    else if str.contains(t, 'CL')
        s := ContractSpec.new(true, 'Full', 1000.0, true, 'Micro', 100.0)
    else if str.contains(t, 'RB')
        s := ContractSpec.new(true, 'Full', 42000.0, false, '', 0.0)
    else if str.contains(t, 'HO')
        s := ContractSpec.new(true, 'Full', 42000.0, false, '', 0.0)
    // Forex
    else if str.contains(t, 'M6E')
        s := ContractSpec.new(true, 'Micro', 12500.0, true, 'Full', 125000.0)
    else if str.contains(t, '6E')
        s := ContractSpec.new(true, 'Full', 125000.0, true, 'Micro', 12500.0)
    else if str.contains(t, 'M6B')
        s := ContractSpec.new(true, 'Micro', 6250.0, true, 'Full', 62500.0)
    else if str.contains(t, '6B')
        s := ContractSpec.new(true, 'Full', 62500.0, true, 'Micro', 6250.0)
    else if str.contains(t, 'M6C')
        s := ContractSpec.new(true, 'Micro', 10000.0, true, 'Full', 100000.0)
    else if str.contains(t, '6C')
        s := ContractSpec.new(true, 'Full', 100000.0, true, 'Micro', 10000.0)
    s

var ContractSpec contractSpec = resolveContract(syminfo.ticker)

// - - - - - - - - -
// Sizing math
// $ risk of the stop for ONE contract at the given point-value. mintick converts
// the stop from TICKS to a price distance — the registry's point-values are $ per
// 1.0 of price, so skipping it would overstate the risk by 1/mintick.
riskPerContract(float pointValue) =>
    stopTicksInput * syminfo.mintick * pointValue

// Spoken name of a contract variant — 'Full' and off-registry alike read as the
// neutral "contract", since "one full" is not how anyone says it.
contractUnit(string variant) =>
    variant == 'Micro' ? 'micro' : variant == 'Mini' ? 'mini' : 'contract'

// Contract-count cell text, e.g. 6 → "6 micros".
contractCountText(int n, string variant) =>
    str.tostring(n) + ' ' + contractUnit(variant) + (n == 1 ? '' : 's')

// Registry resolution. An off-registry symbol has no sibling, so it behaves like
// the micro-less futures (RB, HO) already in the registry: one contract, no pair.
bool   riskChartIsMicro = contractSpec.variant == 'Micro'
bool   riskHasMicro     = contractSpec.found and (riskChartIsMicro or contractSpec.siblingVariant == 'Micro')
float  riskMicroPV      = riskChartIsMicro ? contractSpec.pointValue : contractSpec.siblingPV
float  riskMainPV       = contractSpec.found ? (riskChartIsMicro ? contractSpec.siblingPV : contractSpec.pointValue) : syminfo.pointvalue
string riskMainVariant  = contractSpec.found ? (riskChartIsMicro ? contractSpec.siblingVariant : contractSpec.variant) : 'Contract'

// Stop cost for ONE contract of each side of the pair. The micro side stays na on
// an asset with no micro sibling — every paired string below then collapses to the
// main figure alone.
float riskMainRPC  = riskPerContract(riskMainPV)
float riskMicroRPC = riskHasMicro ? riskPerContract(riskMicroPV) : na

// How many contracts fit inside the preferred risk. 0 when one already busts it.
riskCount(float rpc) =>
    na(rpc) or rpc <= 0 ? 0 : int(math.floor(riskAmountInput / rpc))

// Paired dollar cell, e.g. "$400 / $480" — or "$400" alone when there is no micro.
riskPairText(float mainVal, float microVal) =>
    '$' + str.tostring(math.round(mainVal)) + (riskHasMicro ? ' / $' + str.tostring(math.round(microVal)) : '')

// One tick-chain line of the tooltip: ticks → $/tick → $ for one contract.
riskMathLine(float rpc, string variant) =>
    str.tostring(stopTicksInput) + ' ticks × $' + str.tostring(rpc / stopTicksInput, '0.00') + '/tick = $' + str.tostring(rpc, '0.00') + ' per ' + contractUnit(variant) + '.'

// - - - - - - - - -
// Table
// Two columns (caption + value) and every row the layout can need: the four
// content rows plus a full pad stack. Unused cells are never written, and an
// unpopulated row or column has no size, so the block collapses to whatever the
// current settings actually draw.
var table riskTable = table.new(tablePosition(tablePosInput), 2, RISK_ROWS + RISK_PAD_MAX,
     bgcolor      = C_TRANSPARENT,
     frame_color  = C_TRANSPARENT,
     frame_width  = 0,
     border_color = C_TRANSPARENT,
     border_width = 0)

// One content row. In Labeled layout the caption takes column 0 (dimmed off the
// row's own state color, so a warning row's caption warns too) and the value
// moves to column 1; in Values Only the value keeps column 0 and column 1 is
// never written.
// @param row       (int)    Content row index, before edge padding is applied.
// @param caption   (string) Labeled-layout caption; ignored in Values Only.
// @param txt       (string) The figure itself.
// @param txtColor  (color)  Resolved state color for the whole row.
// @param tip       (string) Shared tick-chain tooltip.
riskRow(int row, string caption, string txt, color txtColor, string tip) =>
    if riskLabeled
        table.cell(riskTable, 0, riskRowOff + row, caption, text_color = color.new(txtColor, 45), text_size = resolvedTableSize, text_halign = text.align_left, tooltip = tip)
    table.cell(riskTable, riskLabeled ? 1 : 0, riskRowOff + row, txt, text_color = txtColor, text_size = resolvedTableSize, text_halign = resolvedAlign, tooltip = tip)

if barstate.islast
    int  riskMainN    = riskCount(riskMainRPC)
    int  riskMicroN   = riskCount(riskMicroRPC)
    // Nothing at all fits (red) vs. only the micros fit (amber).
    bool riskTooBig   = riskMainN < 1 and riskMicroN < 1
    bool riskMainOver = not riskTooBig and riskMainN < 1
    color riskCol = riskTooBig ? riskErrColInput : riskMainOver ? riskWarnColInput : riskTxtColInput
    // Nothing is tradeable, so there is no position risk to report — the risk row
    // shows what ONE of each contract would cost instead, which is the number that
    // explains the error.
    string riskAmtTxt = riskTooBig ? riskPairText(riskMainRPC, riskMicroRPC) : riskPairText(riskMainN * riskMainRPC, riskMicroN * riskMicroRPC)
    string riskCntTxt = riskTooBig ? 'Risk too big' : contractCountText(riskMainN, riskMainVariant) + (riskHasMicro ? ' / ' + contractCountText(riskMicroN, 'Micro') : '')
    // The whole tick chain, spelled out for both contracts: $ per tick → $ per
    // contract → the budget the counts were divided by. This is the line to read
    // when a figure looks off.
    string riskMath = riskMathLine(riskMainRPC, riskMainVariant)
    if riskHasMicro
        riskMath += '\n' + riskMathLine(riskMicroRPC, 'Micro')
    riskMath += '\nPreferred risk $' + str.tostring(riskAmountInput, '0.00') + '.'
    string riskTip = riskTooBig ? 'One ' + contractUnit(riskHasMicro ? 'Micro' : riskMainVariant) + ' already exceeds your preferred risk.\n' + riskMath : riskMainOver ? 'A single ' + contractUnit(riskMainVariant) + ' exceeds your preferred risk — only the micros fit.\n' + riskMath : riskMath
    riskRow(0, 'Asset', syminfo.ticker, riskCol, riskTip)
    riskRow(1, 'Stop',  str.tostring(stopTicksInput) + ' ticks', riskCol, riskTip)
    riskRow(2, 'Risk',  riskAmtTxt, riskCol, riskTip)
    riskRow(3, 'Size',  riskCntTxt, riskCol, riskTip)
    // Spacer rows — a single space gives each one a line of height. They stack
    // above the content on a Top anchor and below it on a Bottom one; the guard
    // matters because `for i = 0 to -1` would count DOWN and draw two of them.
    if riskPadRows > 0
        int riskPadStart = riskPadAbove ? 0 : RISK_ROWS
        for i = 0 to riskPadRows - 1
            table.cell(riskTable, 0, riskPadStart + i, ' ', text_size = resolvedTableSize)
````
