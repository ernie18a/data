<!-- tradingview-pine-id: PUB;06f6a04e647d4d01836e2beb7956a3f5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Portfolio Open Risk Dashboard [SMC]

Source: https://www.tradingview.com/script/Nd2bPUAs-Portfolio-Open-Risk-and-Position-Heat-Tracker-India-SMC/

## Description

WHAT THIS DOES

Position sizing tells you how much to buy on one trade. It says nothing about what happens when you are holding eight of them at once.
This tracks all your open positions together. Pick up to twenty symbols, give each one a quantity, an entry and a stop, and it prices what you are carrying: what you lose if every stop fills, which sectors that loss is concentrated in, and how much room is left before you reach the total loss you are willing to take.

TWO NUMBERS THAT ARE NOT THE SAME

Most risk calculators quietly conflate these. They answer different questions and both are worth knowing.

OPEN LOSS
what you give back from today's price down to your stops. Money currently on the table.

LOSS VS COST
what you lose measured from your entries. On a position whose stop has been trailed above cost this is zero, no matter how much open loss it still carries. A trader running trailed stops can be carrying a large open loss and no loss at all against cost. One number says exposed, the other says protected. Both are true, so the dashboard prints both.

The sample position in WIPRO shows it: stop at 172 against a 170 entry. Real open loss, zero loss against cost.

THE ARITHMETIC

    Open loss     = Qty x (Last - Stop)
    Loss vs cost  = Qty x max(0, Entry - Stop)
    P&L           = Qty x (Last - Entry)
    Deployed      = sum of Qty x Last
    Room left     = Max total open loss - Open loss

A position trading below its stop is counted as zero open loss and flagged "past stop", because that loss is already realised. Counting it again would flatter the total.

YOUR LIMIT, NOT MINE

You set the maximum total open loss in rupees. The default of thirty thousand is six percent of the default capital, being six trades at one percent each. That is a common starting point, not a rule from this script. Set it to what you actually run.

The bar fills toward your number. Room left translates whatever remains into a rough count of further trades at your standard risk per trade.

SECTOR CLUSTERING

Open loss is grouped by sector, taken automatically from exchange data. This exists because five positions in one sector is not five independent risks.
Total risk can look comfortable while sitting almost entirely in one group. In the sample portfolio three of five positions are Technology Services and carry half the open loss. The headline number never shows that. The sector block does.

THE POSITION TABLE

Rows sort by open loss, heaviest first, so the position you would feel most is not buried at the bottom. Note that this ordering is not P&L ordering. A stock up five percent with a trailed stop can sit last, because it has the least left on the table.

Entry, stop and last are reference prices and are shown muted. P&L and open loss are the numbers you act on and stay at full strength. A stop above cost is shown in the up colour, which is a fact about the position, not a view on the trade.

GETTING STARTED

The first five rows arrive filled with sample positions so the dashboard shows something useful before you type anything. Replace them with your own. A row counts once it has a symbol, a quantity and a stop. Entry is optional, though without it P&L and loss vs cost cannot be worked out.

Pine cannot add input rows on demand, so all twenty exist from the start and empty ones are ignored.

WHAT THIS DOES NOT DO

It does not know your real broker positions, so what you type is what it believes. It does not tell you whether any position is worth holding, whether your stops are sensible, or whether you are too concentrated. It measures. The judgement stays with you.

LIMITATIONS

Long positions only. Figures exclude brokerage, exchange and statutory charges, taxes, slippage, partial fills, and gap risk. Gap risk matters most here: if several positions gap below their stops at once, the total loss will exceed every figure shown, and no dashboard can prevent that. Open loss assumes each stop fills at its exact price. Treat it as a floor. Prices are daily closes for each symbol and update while the session is open. Positions whose symbol cannot be priced are excluded from every total and
flagged.

Educational and decision-support only. Not investment advice, and not a recommendation to buy or sell any security.

---

## Source Code

````pine
//@version=6
indicator('Portfolio Open Risk Dashboard [SMC]', shorttitle = 'Portfolio Risk', overlay = true, dynamic_requests = true)

// ══════════════════════════════════════════════════════════════════════════════
// SMART MONEY CLUB - PORTFOLIO OPEN RISK
// ══════════════════════════════════════════════════════════════════════════════
// Pick your open positions from the twenty symbol dropdowns and give each one
// a quantity, an entry and a stop. The first five arrive filled with sample
// positions so the dashboard shows something useful before you type anything.
// Pine has no way to add rows on demand, so all twenty exist from the start
// and empty ones are simply ignored. The dashboard prices what happens if every
// stop fills, groups that loss by sector, and tells you what is left before
// you hit the total open loss you are willing to carry.
//
// It reports two different numbers, because they are genuinely different and
// most risk calculators quietly conflate them:
//
//   OPEN LOSS      what you give back from today's price down to your stops.
//                  This is money currently on the table.
//   LOSS VS COST   what you lose measured from your entries. On a position
//                  whose stop has been trailed above cost this is zero, no
//                  matter how much open loss it still carries.
//
// A trader running trailed stops can be carrying a large open loss and no
// loss at all against cost. Both numbers are true and they answer different
// questions.
//
// The maximum total open loss is yours to set. The default is a starting
// point, not advice. Nothing here says whether a position is worth holding.
// ══════════════════════════════════════════════════════════════════════════════

//#region ───────────────────────── INPUTS ──────────────────────────────────
const string G_ACC = 'Account'
const string G_POS = 'Positions'
const string G_DSP = '════════ Display ════════'

float capitalInput = input.float(500000.0, 'Trading capital (INR)', minval = 1.0, step = 10000.0, group = G_ACC, tooltip = 'Total account value. Used to express each loss as a percent of capital.', display = display.none)
float maxOpenLoss  = input.float(30000.0, 'Max total open loss (INR)', minval = 1.0, step = 1000.0, group = G_ACC, tooltip = 'The most you are willing to have on the table across every open position at once. The default is six percent of the default capital, being six trades at one percent each. It is your policy, not a rule from this script.', display = display.none)
float stdRisk      = input.float(1.0, 'Standard risk per trade %', minval = 0.1, maxval = 10.0, step = 0.1, group = G_ACC, tooltip = 'Used only to translate the remaining room into a number of further trades.', display = display.none)

// One line per position: symbol, quantity, entry, stop.
// A row counts once it has a symbol, a quantity above zero and a stop above
// zero. Entry is optional; without it the loss against cost and the open
// profit cannot be worked out and show as a dash.
string sy01 = input.symbol('NSE:RELIANCE', '', inline = 'p01', group = G_POS, tooltip = 'Rows one to five are filled with sample positions so the dashboard has something to show. Replace them with your own. A row counts once it has a symbol, a quantity above zero and a stop above zero. Entry is optional.')
int    qt01 = input.int(40, 'Qty', inline = 'p01', minval = 0, group = G_POS, display = display.none)
float  en01 = input.float(1240.0, 'Entry', inline = 'p01', minval = 0.0, group = G_POS, display = display.none)
float  sl01 = input.float(1195.0, 'Stop', inline = 'p01', minval = 0.0, group = G_POS, display = display.none)

string sy02 = input.symbol('NSE:HDFCBANK', '', inline = 'p02', group = G_POS)
int    qt02 = input.int(60, 'Qty', inline = 'p02', minval = 0, group = G_POS, display = display.none)
float  en02 = input.float(690.0, 'Entry', inline = 'p02', minval = 0.0, group = G_POS, display = display.none)
float  sl02 = input.float(672.0, 'Stop', inline = 'p02', minval = 0.0, group = G_POS, display = display.none)

string sy03 = input.symbol('NSE:INFY', '', inline = 'p03', group = G_POS)
int    qt03 = input.int(45, 'Qty', inline = 'p03', minval = 0, group = G_POS, display = display.none)
float  en03 = input.float(1090.0, 'Entry', inline = 'p03', minval = 0.0, group = G_POS, display = display.none)
float  sl03 = input.float(1055.0, 'Stop', inline = 'p03', minval = 0.0, group = G_POS, display = display.none)

string sy04 = input.symbol('NSE:TCS', '', inline = 'p04', group = G_POS)
int    qt04 = input.int(12, 'Qty', inline = 'p04', minval = 0, group = G_POS, display = display.none)
float  en04 = input.float(2280.0, 'Entry', inline = 'p04', minval = 0.0, group = G_POS, display = display.none)
float  sl04 = input.float(2210.0, 'Stop', inline = 'p04', minval = 0.0, group = G_POS, display = display.none)

string sy05 = input.symbol('NSE:WIPRO', '', inline = 'p05', group = G_POS)
int    qt05 = input.int(250, 'Qty', inline = 'p05', minval = 0, group = G_POS, display = display.none)
float  en05 = input.float(170.0, 'Entry', inline = 'p05', minval = 0.0, group = G_POS, display = display.none)
float  sl05 = input.float(172.0, 'Stop', inline = 'p05', minval = 0.0, group = G_POS, display = display.none)

string sy06 = input.symbol('', '', inline = 'p06', group = G_POS)
int    qt06 = input.int(0, 'Qty', inline = 'p06', minval = 0, group = G_POS, display = display.none)
float  en06 = input.float(0.0, 'Entry', inline = 'p06', minval = 0.0, group = G_POS, display = display.none)
float  sl06 = input.float(0.0, 'Stop', inline = 'p06', minval = 0.0, group = G_POS, display = display.none)

string sy07 = input.symbol('', '', inline = 'p07', group = G_POS)
int    qt07 = input.int(0, 'Qty', inline = 'p07', minval = 0, group = G_POS, display = display.none)
float  en07 = input.float(0.0, 'Entry', inline = 'p07', minval = 0.0, group = G_POS, display = display.none)
float  sl07 = input.float(0.0, 'Stop', inline = 'p07', minval = 0.0, group = G_POS, display = display.none)

string sy08 = input.symbol('', '', inline = 'p08', group = G_POS)
int    qt08 = input.int(0, 'Qty', inline = 'p08', minval = 0, group = G_POS, display = display.none)
float  en08 = input.float(0.0, 'Entry', inline = 'p08', minval = 0.0, group = G_POS, display = display.none)
float  sl08 = input.float(0.0, 'Stop', inline = 'p08', minval = 0.0, group = G_POS, display = display.none)

string sy09 = input.symbol('', '', inline = 'p09', group = G_POS)
int    qt09 = input.int(0, 'Qty', inline = 'p09', minval = 0, group = G_POS, display = display.none)
float  en09 = input.float(0.0, 'Entry', inline = 'p09', minval = 0.0, group = G_POS, display = display.none)
float  sl09 = input.float(0.0, 'Stop', inline = 'p09', minval = 0.0, group = G_POS, display = display.none)

string sy10 = input.symbol('', '', inline = 'p10', group = G_POS)
int    qt10 = input.int(0, 'Qty', inline = 'p10', minval = 0, group = G_POS, display = display.none)
float  en10 = input.float(0.0, 'Entry', inline = 'p10', minval = 0.0, group = G_POS, display = display.none)
float  sl10 = input.float(0.0, 'Stop', inline = 'p10', minval = 0.0, group = G_POS, display = display.none)

string sy11 = input.symbol('', '', inline = 'p11', group = G_POS)
int    qt11 = input.int(0, 'Qty', inline = 'p11', minval = 0, group = G_POS, display = display.none)
float  en11 = input.float(0.0, 'Entry', inline = 'p11', minval = 0.0, group = G_POS, display = display.none)
float  sl11 = input.float(0.0, 'Stop', inline = 'p11', minval = 0.0, group = G_POS, display = display.none)

string sy12 = input.symbol('', '', inline = 'p12', group = G_POS)
int    qt12 = input.int(0, 'Qty', inline = 'p12', minval = 0, group = G_POS, display = display.none)
float  en12 = input.float(0.0, 'Entry', inline = 'p12', minval = 0.0, group = G_POS, display = display.none)
float  sl12 = input.float(0.0, 'Stop', inline = 'p12', minval = 0.0, group = G_POS, display = display.none)

string sy13 = input.symbol('', '', inline = 'p13', group = G_POS)
int    qt13 = input.int(0, 'Qty', inline = 'p13', minval = 0, group = G_POS, display = display.none)
float  en13 = input.float(0.0, 'Entry', inline = 'p13', minval = 0.0, group = G_POS, display = display.none)
float  sl13 = input.float(0.0, 'Stop', inline = 'p13', minval = 0.0, group = G_POS, display = display.none)

string sy14 = input.symbol('', '', inline = 'p14', group = G_POS)
int    qt14 = input.int(0, 'Qty', inline = 'p14', minval = 0, group = G_POS, display = display.none)
float  en14 = input.float(0.0, 'Entry', inline = 'p14', minval = 0.0, group = G_POS, display = display.none)
float  sl14 = input.float(0.0, 'Stop', inline = 'p14', minval = 0.0, group = G_POS, display = display.none)

string sy15 = input.symbol('', '', inline = 'p15', group = G_POS)
int    qt15 = input.int(0, 'Qty', inline = 'p15', minval = 0, group = G_POS, display = display.none)
float  en15 = input.float(0.0, 'Entry', inline = 'p15', minval = 0.0, group = G_POS, display = display.none)
float  sl15 = input.float(0.0, 'Stop', inline = 'p15', minval = 0.0, group = G_POS, display = display.none)

string sy16 = input.symbol('', '', inline = 'p16', group = G_POS)
int    qt16 = input.int(0, 'Qty', inline = 'p16', minval = 0, group = G_POS, display = display.none)
float  en16 = input.float(0.0, 'Entry', inline = 'p16', minval = 0.0, group = G_POS, display = display.none)
float  sl16 = input.float(0.0, 'Stop', inline = 'p16', minval = 0.0, group = G_POS, display = display.none)

string sy17 = input.symbol('', '', inline = 'p17', group = G_POS)
int    qt17 = input.int(0, 'Qty', inline = 'p17', minval = 0, group = G_POS, display = display.none)
float  en17 = input.float(0.0, 'Entry', inline = 'p17', minval = 0.0, group = G_POS, display = display.none)
float  sl17 = input.float(0.0, 'Stop', inline = 'p17', minval = 0.0, group = G_POS, display = display.none)

string sy18 = input.symbol('', '', inline = 'p18', group = G_POS)
int    qt18 = input.int(0, 'Qty', inline = 'p18', minval = 0, group = G_POS, display = display.none)
float  en18 = input.float(0.0, 'Entry', inline = 'p18', minval = 0.0, group = G_POS, display = display.none)
float  sl18 = input.float(0.0, 'Stop', inline = 'p18', minval = 0.0, group = G_POS, display = display.none)

string sy19 = input.symbol('', '', inline = 'p19', group = G_POS)
int    qt19 = input.int(0, 'Qty', inline = 'p19', minval = 0, group = G_POS, display = display.none)
float  en19 = input.float(0.0, 'Entry', inline = 'p19', minval = 0.0, group = G_POS, display = display.none)
float  sl19 = input.float(0.0, 'Stop', inline = 'p19', minval = 0.0, group = G_POS, display = display.none)

string sy20 = input.symbol('', '', inline = 'p20', group = G_POS)
int    qt20 = input.int(0, 'Qty', inline = 'p20', minval = 0, group = G_POS, display = display.none)
float  en20 = input.float(0.0, 'Entry', inline = 'p20', minval = 0.0, group = G_POS, display = display.none)
float  sl20 = input.float(0.0, 'Stop', inline = 'p20', minval = 0.0, group = G_POS, display = display.none)
bool showPositions = input.bool(true, 'Position rows', group = G_DSP, display = display.none)
bool showSectors   = input.bool(true, 'Sector clustering', group = G_DSP, tooltip = 'Groups open loss by sector, taken automatically from exchange data. Five positions in one sector is not five independent risks.', display = display.none)
string theme     = input.string('Auto', 'Theme', options = ['Auto', 'Dark', 'Light'], group = G_DSP, display = display.none)
string tableSize = input.string('small', 'Table', inline = 'tbl', options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'], group = G_DSP, display = display.none)
string tablePosY = input.string('top', '↕', inline = 'tbl', options = ['top', 'middle', 'bottom'], group = G_DSP, display = display.none)
string tablePosX = input.string('right', '↔', inline = 'tbl', options = ['left', 'center', 'right'], group = G_DSP, display = display.none)
//#endregion

//#region ───────────────────────── CONSTANTS ───────────────────────────────
const int MAXSEC = 10
const int NCOL   = 8
const int LASTC  = 7
const int BAR_W  = 22
const int SEC_W  = 10
//#endregion

//#region ───────────────────────── PALETTE ─────────────────────────────────
bool light = theme == 'Light' or theme == 'Auto' and color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color) >= 384

color cText  = light ? color.black           : color.white
color cMuted = light ? #5b616b               : color.silver
color cNa    = light ? #9aa0aa               : color.gray
color cUp    = light ? #0b8043               : #34d399
color cDown  = light ? #cc2222               : #f87171
color cFlat  = light ? #c77800               : #fbbf24
color cHdrBg = light ? color.new(#e2e5ea, 0) : color.new(color.gray, 15)
color cHdrTx = light ? color.black           : color.white
color cRowBg = na
color cAltBg = color.new(color.gray, light ? 94 : 90)
color cFrame = color.new(color.gray, 40)
color cBordr = color.new(color.gray, 70)
//#endregion

//#region ───────────────────────── GEOMETRY ────────────────────────────────
tablePos = tablePosY == 'top' ? (tablePosX == 'left' ? position.top_left : tablePosX == 'center' ? position.top_center : position.top_right) : tablePosY == 'middle' ? (tablePosX == 'left' ? position.middle_left : tablePosX == 'center' ? position.middle_center : position.middle_right) : (tablePosX == 'left' ? position.bottom_left : tablePosX == 'center' ? position.bottom_center : position.bottom_right)

szOf(string s) =>
    s == 'tiny' ? size.tiny : s == 'small' ? size.small : s == 'normal' ? size.normal : s == 'large' ? size.large : s == 'huge' ? size.huge : size.auto

sz = szOf(tableSize)
//#endregion

//#region ───────────────────────── FORMATTERS ──────────────────────────────
fmtInr(float v) =>
    string outTxt = '–'
    if not na(v)
        float av = math.abs(v)
        outTxt := av >= 10000000.0 ? str.tostring(v / 10000000.0, '#,##0.00') + 'Cr' : av >= 100000.0 ? str.tostring(v / 100000.0, '#,##0.00') + 'L' : av >= 1000.0 ? str.tostring(v / 1000.0, '#,##0.00') + 'K' : str.tostring(v, '#,##0')
    outTxt

fmtPx(float v) =>
    na(v) or v <= 0 ? '–' : str.tostring(v, format.mintick)

fmtQty(float v) =>
    na(v) ? '–' : str.tostring(v, '#,##0')

fmtPct(float v) =>
    na(v) ? '–' : str.tostring(v, '#.00') + '%'

fmtSigned(float v) =>
    na(v) ? '–' : (v > 0 ? '+' : '') + str.tostring(v, '#.0') + '%'

// A bar drawn in text. Cheap, theme proof, and it reads at a glance.
bar(float value, float full, int cells) =>
    int filled = full > 0 and not na(value) ? math.max(0, math.min(cells, int(math.round(value / full * cells)))) : 0
    (filled > 0 ? str.repeat('█', filled) : '') + (cells - filled > 0 ? str.repeat('░', cells - filled) : '')
//#endregion

//#region ───────────────────────── POSITIONS ───────────────────────────────
addPos(array<string> sy, array<float> q, array<float> e, array<float> s, string sym, int qty, float ent, float stp) =>
    if sym != '' and qty > 0 and stp > 0
        array.push(sy, sym)
        array.push(q, qty)
        array.push(e, ent)
        array.push(s, stp)
    true

var array<string> pSym = array.new<string>()
var array<float>  pQty = array.new<float>()
var array<float>  pEnt = array.new<float>()
var array<float>  pStp = array.new<float>()

if barstate.isfirst
    addPos(pSym, pQty, pEnt, pStp, sy01, qt01, en01, sl01)
    addPos(pSym, pQty, pEnt, pStp, sy02, qt02, en02, sl02)
    addPos(pSym, pQty, pEnt, pStp, sy03, qt03, en03, sl03)
    addPos(pSym, pQty, pEnt, pStp, sy04, qt04, en04, sl04)
    addPos(pSym, pQty, pEnt, pStp, sy05, qt05, en05, sl05)
    addPos(pSym, pQty, pEnt, pStp, sy06, qt06, en06, sl06)
    addPos(pSym, pQty, pEnt, pStp, sy07, qt07, en07, sl07)
    addPos(pSym, pQty, pEnt, pStp, sy08, qt08, en08, sl08)
    addPos(pSym, pQty, pEnt, pStp, sy09, qt09, en09, sl09)
    addPos(pSym, pQty, pEnt, pStp, sy10, qt10, en10, sl10)
    addPos(pSym, pQty, pEnt, pStp, sy11, qt11, en11, sl11)
    addPos(pSym, pQty, pEnt, pStp, sy12, qt12, en12, sl12)
    addPos(pSym, pQty, pEnt, pStp, sy13, qt13, en13, sl13)
    addPos(pSym, pQty, pEnt, pStp, sy14, qt14, en14, sl14)
    addPos(pSym, pQty, pEnt, pStp, sy15, qt15, en15, sl15)
    addPos(pSym, pQty, pEnt, pStp, sy16, qt16, en16, sl16)
    addPos(pSym, pQty, pEnt, pStp, sy17, qt17, en17, sl17)
    addPos(pSym, pQty, pEnt, pStp, sy18, qt18, en18, sl18)
    addPos(pSym, pQty, pEnt, pStp, sy19, qt19, en19, sl19)
    addPos(pSym, pQty, pEnt, pStp, sy20, qt20, en20, sl20)

int nPos = array.size(pSym)

// True while the shipped example rows are still untouched.
bool sampleData = sy01 == 'NSE:RELIANCE' and qt01 == 40 and en01 == 1240.0 and sy05 == 'NSE:WIPRO' and qt05 == 250
//#endregion

//#region ───────────────────────── ROW HELPERS ─────────────────────────────
spanRow(table tbl, int row, string txt, color txtCol, color bg, bool bold) =>
    table.cell(tbl, 0, row, txt, text_color = txtCol, text_size = sz, bgcolor = bg, text_halign = text.align_left, text_formatting = bold ? text.format_bold : text.format_none)
    for c = 1 to LASTC
        table.cell(tbl, c, row, '', bgcolor = bg)
    table.merge_cells(tbl, 0, row, LASTC, row)
    true

// Label left, detail merged in the middle, headline value right.
statRow(table tbl, int row, string lbl, string mid, color midCol, string val, color valCol, color bg) =>
    table.cell(tbl, 0, row, lbl, text_color = cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_left)
    table.cell(tbl, 1, row, mid, text_color = midCol, text_size = sz, bgcolor = bg, text_halign = text.align_left)
    for c = 2 to LASTC - 1
        table.cell(tbl, c, row, '', bgcolor = bg)
    table.merge_cells(tbl, 1, row, LASTC - 1, row)
    table.cell(tbl, LASTC, row, val, text_color = valCol, text_size = sz, bgcolor = bg, text_halign = text.align_right, text_formatting = text.format_bold)
    true
//#endregion

//#region ───────────────────────── RENDER ──────────────────────────────────
var table t = na

if barstate.islast
    if not na(t)
        table.delete(t)
    t := table.new(tablePos, NCOL, 45, bgcolor = color.new(color.gray, 100), frame_width = 1, frame_color = cFrame, border_width = 1, border_color = cBordr)

    int r = 0
    bool capOk = not na(capitalInput) and capitalInput > 0

    array<float>  lastPx = array.new<float>()
    array<float>  openLs = array.new<float>()
    array<float>  costLs = array.new<float>()
    array<float>  pnlPc  = array.new<float>()
    array<float>  pnlRs  = array.new<float>()
    array<bool>   breach = array.new<bool>()
    array<bool>   freeRl = array.new<bool>()
    array<string> pSec   = array.new<string>()

    float totOpen = 0.0
    float totCost = 0.0
    float totVal  = 0.0
    int   nBreach = 0
    int   nUnres  = 0
    int   nFree   = 0

    if nPos > 0
        for i = 0 to nPos - 1
            // One request per position returns both the price and the sector,
            // which keeps the request count at one per symbol.
            [lp, sec] = request.security(array.get(pSym, i), 'D', [close, syminfo.sector], ignore_invalid_symbol = true)
            float q  = array.get(pQty, i)
            float e  = array.get(pEnt, i)
            float st = array.get(pStp, i)
            bool  ok = not na(lp) and lp > 0
            bool  hasEntry = not na(e) and e > 0

            // Below the stop means the position is already past it. Counting
            // loss that has already been realised would flatter the total.
            bool  br = ok and lp < st
            bool  fr = hasEntry and st >= e
            float ol = ok and not br ? q * (lp - st) : 0.0
            float cl = hasEntry ? math.max(0.0, q * (e - st)) : na
            float pp = ok and hasEntry ? (lp / e - 1.0) * 100.0 : na
            float pr = ok and hasEntry ? q * (lp - e) : na

            array.push(lastPx, ok ? lp : na)
            array.push(openLs, ol)
            array.push(costLs, cl)
            array.push(pnlPc, pp)
            array.push(pnlRs, pr)
            array.push(breach, br)
            array.push(freeRl, fr)
            array.push(pSec, na(sec) or sec == '' ? 'Untagged' : sec)

            totOpen += ol
            totCost += na(cl) ? 0.0 : cl
            totVal  += ok ? q * lp : 0.0
            nBreach += br ? 1 : 0
            nUnres  += ok ? 0 : 1
            nFree   += fr ? 1 : 0

    float openPct = capOk ? totOpen / capitalInput * 100.0 : na
    float costPct = capOk ? totCost / capitalInput * 100.0 : na
    float expoPct = capOk ? totVal / capitalInput * 100.0 : na
    float limPct  = capOk ? maxOpenLoss / capitalInput * 100.0 : na
    float roomRs  = maxOpenLoss - totOpen
    float stdRs   = capOk ? capitalInput * stdRisk / 100.0 : na
    int   roomN   = na(stdRs) or stdRs <= 0 or roomRs <= 0 ? 0 : int(math.floor(roomRs / stdRs))

    color lossCol = totOpen >= maxOpenLoss ? cDown : totOpen >= maxOpenLoss * 0.6 ? cFlat : cText

    table.cell(t, 0, r, 'PORTFOLIO OPEN RISK', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_left, text_formatting = text.format_bold, tooltip = 'Open loss is measured from today\'s price down to your stops. Loss vs cost is measured from your entries. Figures exclude brokerage, taxes, slippage, gaps below stops and partial fills.')
    for c = 1 to LASTC - 1
        table.cell(t, c, r, '', bgcolor = cHdrBg)
    table.merge_cells(t, 0, r, LASTC - 1, r)
    table.cell(t, LASTC, r, str.tostring(nPos) + (nPos == 1 ? ' position' : ' positions'), text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
    r += 1

    if nPos == 0
        spanRow(t, r, 'Add positions in the settings.', cText, cRowBg, true)
        r += 1
        spanRow(t, r, 'Pick a symbol, then set quantity, entry and stop on the same line.', cMuted, cRowBg, false)
        r += 1
        spanRow(t, r, 'A row counts once it has a symbol, a quantity and a stop.', cNa, cRowBg, false)
    else
        statRow(t, r, 'Total open loss', bar(totOpen, maxOpenLoss, BAR_W), lossCol, fmtInr(totOpen), lossCol, cRowBg)
        r += 1

        statRow(t, r, 'Limit', 'you set ' + fmtInr(maxOpenLoss) + ', that is ' + fmtPct(limPct) + ' of capital', cMuted, fmtPct(openPct), lossCol, cAltBg)
        r += 1

        statRow(t, r, 'Loss vs cost', nFree > 0 ? str.tostring(nFree) + (nFree == 1 ? ' position' : ' positions') + ' stopped above cost' : 'measured from your entries', cMuted, fmtInr(totCost) + '  ' + fmtPct(costPct), totCost <= 0 ? cUp : cText, cRowBg)
        r += 1

        statRow(t, r, 'Deployed', fmtPct(expoPct) + ' of capital', cMuted, fmtInr(totVal), cText, cAltBg)
        r += 1

        string roomTxt = roomRs < 0 ? 'over your limit by ' + fmtInr(-roomRs) : 'about ' + str.tostring(roomN) + ' more at ' + fmtPct(stdRisk) + ' each'
        statRow(t, r, 'Room left', roomTxt, roomRs < 0 ? cDown : cMuted, roomRs < 0 ? fmtInr(roomRs) : fmtInr(roomRs), roomRs < 0 ? cDown : cText, cRowBg)
        r += 1

        if showPositions
            table.cell(t, 0, r, 'Symbol', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(t, 1, r, 'Qty', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 2, r, 'Entry', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 3, r, 'Stop', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 4, r, 'Last', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 5, r, 'P&L', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 6, r, '%', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(t, 7, r, 'Open loss', text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_halign = text.align_right, text_formatting = text.format_bold)
            r += 1

            // Heaviest open loss on top. The row you would feel most is the
            // one you should not have to hunt for.
            array<int> ord = array.new<int>()
            for i = 0 to nPos - 1
                array.push(ord, i)
            if nPos > 1
                for a = 0 to nPos - 2
                    for b = a + 1 to nPos - 1
                        if array.get(openLs, array.get(ord, b)) > array.get(openLs, array.get(ord, a))
                            int tmp = array.get(ord, a)
                            array.set(ord, a, array.get(ord, b))
                            array.set(ord, b, tmp)

            for k = 0 to nPos - 1
                int i = array.get(ord, k)
                color bg = k % 2 == 0 ? cRowBg : cAltBg
                float lp = array.get(lastPx, i)
                float ol = array.get(openLs, i)
                float pp = array.get(pnlPc, i)
                float pr = array.get(pnlRs, i)
                bool br = array.get(breach, i)
                bool fr = array.get(freeRl, i)
                color pnlCol = na(pp) ? cNa : pp >= 0 ? cUp : cDown

                string disp = array.get(pSym, i)
                array<string> parts = str.split(disp, ':')
                disp := array.size(parts) > 1 ? array.get(parts, 1) : disp

                table.cell(t, 0, r, disp, text_color = br ? cDown : cText, text_size = sz, bgcolor = bg, text_halign = text.align_left, text_formatting = text.format_bold)
                table.cell(t, 1, r, fmtQty(array.get(pQty, i)), text_color = cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                table.cell(t, 2, r, fmtPx(array.get(pEnt, i)), text_color = cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                // A stop above cost is shown in the up colour. That is a fact
                // about the position, not a view on the trade.
                table.cell(t, 3, r, fmtPx(array.get(pStp, i)), text_color = fr ? cUp : cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                table.cell(t, 4, r, na(lp) ? '–' : fmtPx(lp), text_color = na(lp) ? cDown : cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                table.cell(t, 5, r, na(pr) ? '–' : (pr > 0 ? '+' : '') + fmtInr(pr), text_color = pnlCol, text_size = sz, bgcolor = bg, text_halign = text.align_right, text_formatting = text.format_bold)
                table.cell(t, 6, r, fmtSigned(pp), text_color = pnlCol, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                table.cell(t, 7, r, br ? 'past stop' : fmtInr(ol), text_color = br ? cDown : cText, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                r += 1

        if showSectors
            array<string> secName = array.new<string>()
            array<float>  secRisk = array.new<float>()
            array<int>    secCnt  = array.new<int>()

            for i = 0 to nPos - 1
                string s = array.get(pSec, i)
                int at = -1
                if array.size(secName) > 0
                    for j = 0 to array.size(secName) - 1
                        if array.get(secName, j) == s
                            at := j
                if at >= 0
                    array.set(secRisk, at, array.get(secRisk, at) + array.get(openLs, i))
                    array.set(secCnt, at, array.get(secCnt, at) + 1)
                else if array.size(secName) < MAXSEC
                    array.push(secName, s)
                    array.push(secRisk, array.get(openLs, i))
                    array.push(secCnt, 1)

            int nSec = array.size(secName)
            if nSec > 1
                for a = 0 to nSec - 2
                    for b = a + 1 to nSec - 1
                        if array.get(secRisk, b) > array.get(secRisk, a)
                            float tr = array.get(secRisk, a)
                            string tn = array.get(secName, a)
                            int tc = array.get(secCnt, a)
                            array.set(secRisk, a, array.get(secRisk, b))
                            array.set(secName, a, array.get(secName, b))
                            array.set(secCnt, a, array.get(secCnt, b))
                            array.set(secRisk, b, tr)
                            array.set(secName, b, tn)
                            array.set(secCnt, b, tc)

            if nSec > 0
                float topRisk = array.get(secRisk, 0)
                spanRow(t, r, 'OPEN LOSS BY SECTOR', cHdrTx, cHdrBg, true)
                r += 1
                for j = 0 to nSec - 1
                    float sr = array.get(secRisk, j)
                    float sp = capOk ? sr / capitalInput * 100.0 : na
                    color bg = j % 2 == 0 ? cRowBg : cAltBg
                    table.cell(t, 0, r, array.get(secName, j) + '  ' + str.tostring(array.get(secCnt, j)), text_color = cText, text_size = sz, bgcolor = bg, text_halign = text.align_left, text_formatting = text.format_bold)
                    table.cell(t, 1, r, bar(sr, topRisk, SEC_W), text_color = cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_left)
                    for c = 2 to 5
                        table.cell(t, c, r, '', bgcolor = bg)
                    table.merge_cells(t, 1, r, 5, r)
                    table.cell(t, 6, r, fmtInr(sr), text_color = cText, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                    table.cell(t, 7, r, fmtPct(sp), text_color = cMuted, text_size = sz, bgcolor = bg, text_halign = text.align_right)
                    r += 1

        if sampleData
            spanRow(t, r, 'Sample positions. Replace them in the settings with your own.', cFlat, cRowBg, false)
            r += 1
        if nUnres > 0
            spanRow(t, r, str.tostring(nUnres) + ' symbol' + (nUnres == 1 ? '' : 's') + ' could not be priced and are excluded from every total', cDown, cRowBg, false)
            r += 1
        if nBreach > 0
            spanRow(t, r, str.tostring(nBreach) + ' position' + (nBreach == 1 ? ' is' : 's are') + ' trading below the stop, so that loss is already realised', cFlat, cRowBg, false)
//#endregion
````
