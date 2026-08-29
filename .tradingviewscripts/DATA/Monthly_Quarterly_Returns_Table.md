<!-- tradingview-pine-id: PUB;21b027a9dc2d4361b267b467e48b1f6a -->
<!-- tradingviewscripts-format: 1 -->
# Monthly & Quarterly Returns Table

Source: https://www.tradingview.com/script/c2VY8mzq-Monthly-Quarterly-Returns-Table/

## Description

Monthly & Quarterly Returns TableMonthly & Quarterly Returns TableMonthly & Quarterly Returns TableMonthly & Quarterly Returns TableMonthly & Quarterly Returns TableMonthly & Quarterly Returns TableMonthly & Quarterly Returns Table

---

## Source Code

````pine
//@version=6
indicator("Monthly & Quarterly Returns Table", overlay = true)

// ═══ Symbols ═══
sym1 = input.symbol("TVC:SPX",       "Symbol 1", group = "Symbols")
sym2 = input.symbol("TVC:SX5E",      "Symbol 2", group = "Symbols")
sym3 = input.symbol("KRX:KOSPI200",  "Symbol 3", group = "Symbols")
sym4 = input.symbol("TVC:NI225",     "Symbol 4", group = "Symbols")
sym5 = input.symbol("NASDAQ:TSLA",   "Symbol 5", group = "Symbols")
sym6 = input.symbol("NASDAQ:PLTR",   "Symbol 6", group = "Symbols")
sym7 = input.symbol("NASDAQ:NVDA",   "Symbol 7", group = "Symbols")

lbl1 = input.string("S&P 500",      "Label 1", group = "Labels")
lbl2 = input.string("EuroStoxx 50", "Label 2", group = "Labels")
lbl3 = input.string("KOSPI 200",    "Label 3", group = "Labels")
lbl4 = input.string("Nikkei 225",   "Label 4", group = "Labels")
lbl5 = input.string("TSLA",         "Label 5", group = "Labels")
lbl6 = input.string("PLTR",         "Label 6", group = "Labels")
lbl7 = input.string("NVDA",         "Label 7", group = "Labels")

// ═══ Display ═══
showLive = input.bool(true,  "Include current (unfinished) period", group = "Display")
tblPos   = input.string("Middle Center", "Table position", options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group = "Display")
fSize    = input.int(18,     "Font size (pt)",     minval = 6, maxval = 40, group = "Display")
colW     = input.float(4.6,  "Column width (%)",   minval = 0, maxval = 10, step = 0.1, group = "Display")
nameW    = input.float(9.0,  "Name column (%)",    minval = 0, maxval = 20, step = 0.5, group = "Display")
rowH     = input.float(4.0,  "Row height (%)",     minval = 0, maxval = 12, step = 0.1, group = "Display")

posUp    = input.color(color.new(color.green,  50), "Monthly up",   group = "Colors", inline = "m")
posDn    = input.color(color.new(color.red,    50), "Monthly down", group = "Colors", inline = "m")
qUp      = input.color(color.new(color.teal,   30), "Quarter up",   group = "Colors", inline = "q")
qDn      = input.color(color.new(color.orange, 30), "Quarter down", group = "Colors", inline = "q")
neutral  = input.color(color.new(color.gray,   60), "No data",      group = "Colors")

// ═══ Monthly closes (repeating HTF value, 1 call per symbol) ═══
mc1 = request.security(sym1, "1M", close, ignore_invalid_symbol = true)
mc2 = request.security(sym2, "1M", close, ignore_invalid_symbol = true)
mc3 = request.security(sym3, "1M", close, ignore_invalid_symbol = true)
mc4 = request.security(sym4, "1M", close, ignore_invalid_symbol = true)
mc5 = request.security(sym5, "1M", close, ignore_invalid_symbol = true)
mc6 = request.security(sym6, "1M", close, ignore_invalid_symbol = true)
mc7 = request.security(sym7, "1M", close, ignore_invalid_symbol = true)

// ═══ Storage: completed monthly / quarterly closes, oldest first ═══
var m1 = array.new_float()
var m2 = array.new_float()
var m3 = array.new_float()
var m4 = array.new_float()
var m5 = array.new_float()
var m6 = array.new_float()
var m7 = array.new_float()

var q1 = array.new_float()
var q2 = array.new_float()
var q3 = array.new_float()
var q4 = array.new_float()
var q5 = array.new_float()
var q6 = array.new_float()
var q7 = array.new_float()

var tM = array.new_int()
var tQ = array.new_int()

// ═══ Calendar boundary detection ═══
var int prevM = na
var int prevQ = na

int curM = month
int curQ = int((month - 1) / 3)

bool newM = not na(prevM) and prevM != curM
bool newQ = not na(prevQ) and prevQ != curQ

// A quarter boundary is always a month boundary, so the quarter's
// closing price equals the final month's close. No extra requests.
if newM
    array.push(m1, mc1[1])
    array.push(m2, mc2[1])
    array.push(m3, mc3[1])
    array.push(m4, mc4[1])
    array.push(m5, mc5[1])
    array.push(m6, mc6[1])
    array.push(m7, mc7[1])
    array.push(tM, time[1])

if newQ
    array.push(q1, mc1[1])
    array.push(q2, mc2[1])
    array.push(q3, mc3[1])
    array.push(q4, mc4[1])
    array.push(q5, mc5[1])
    array.push(q6, mc6[1])
    array.push(q7, mc7[1])
    array.push(tQ, time[1])

prevM := curM
prevQ := curQ

// ═══ Lookup helpers (ago = 0 -> live period, 1 -> last completed) ═══
getv(array<float> a, float live, int ago) =>
    float r = na
    if ago == 0
        r := live
    else
        int n = array.size(a)
        int idx = n - ago
        if n > 0 and idx >= 0 and idx < n
            r := array.get(a, idx)
    r

gett(array<int> a, int ago) =>
    int r = na
    if ago == 0
        r := time
    else
        int n = array.size(a)
        int idx = n - ago
        if n > 0 and idx >= 0 and idx < n
            r := array.get(a, idx)
    r

rt(float a, float b) => not na(a) and not na(b) and b != 0 ? (a / b - 1) * 100 : na
tx(float r)  => na(r) ? "-" : str.tostring(math.round(r, 1)) + "%"
bgM(float r) => na(r) ? neutral : r > 0 ? posUp : r < 0 ? posDn : neutral
bgQ(float r) => na(r) ? neutral : r > 0 ? qUp   : r < 0 ? qDn   : neutral

pos() =>
    switch tblPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

var table tb = table.new(pos(), 17, 8, frame_color = color.black, frame_width = 1, border_color = color.black, border_width = 1)

fillRow(int row, string nm, array<float> am, array<float> aq, float live, int off) =>
    table.cell(tb, 0, row, nm, text_color = color.white, bgcolor = color.black, text_size = fSize, text_halign = text.align_left, width = nameW, height = rowH)

    for i = 0 to 11
        int ago = 11 - i + off
        float r = rt(getv(am, live, ago), getv(am, live, ago + 1))
        table.cell(tb, i + 1, row, tx(r), text_color = color.white, bgcolor = bgM(r), text_size = fSize, width = colW, height = rowH)

    for k = 0 to 3
        int ago = 3 - k + off
        float r = rt(getv(aq, live, ago), getv(aq, live, ago + 1))
        table.cell(tb, 13 + k, row, tx(r), text_color = color.white, bgcolor = bgQ(r), text_size = fSize, width = colW, height = rowH)

if barstate.islast
    int off = showLive ? 0 : 1

    table.cell(tb, 0, 0, "Ticker", text_color = color.white, bgcolor = color.gray, text_size = fSize, width = nameW, height = rowH)

    for i = 0 to 11
        int ago = 11 - i + off
        int tt  = gett(tM, ago)
        string lb = na(tt) ? "-" : str.format("{0,number,00}.{1,number,00}", year(tt) % 100, month(tt))
        table.cell(tb, i + 1, 0, lb, text_color = color.white, bgcolor = color.gray, text_size = fSize, width = colW, height = rowH)

    for k = 0 to 3
        int ago = 3 - k + off
        int tt  = gett(tQ, ago)
        string lb = na(tt) ? "-" : str.format("{0,number,00} Q{1}", year(tt) % 100, int((month(tt) - 1) / 3) + 1)
        table.cell(tb, 13 + k, 0, lb, text_color = color.white, bgcolor = color.navy, text_size = fSize, width = colW, height = rowH)

    fillRow(1, lbl1, m1, q1, mc1, off)
    fillRow(2, lbl2, m2, q2, mc2, off)
    fillRow(3, lbl3, m3, q3, mc3, off)
    fillRow(4, lbl4, m4, q4, mc4, off)
    fillRow(5, lbl5, m5, q5, mc5, off)
    fillRow(6, lbl6, m6, q6, mc6, off)
    fillRow(7, lbl7, m7, q7, mc7, off)
````
