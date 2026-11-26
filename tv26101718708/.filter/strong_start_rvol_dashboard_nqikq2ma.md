# Strong Start RVOL Dashboard

- url: https://www.tradingview.com/script/NQikq2mA-Strong-Start-RVOL-Dashboard/
- type: indicator
- pine_id: PUB;36140b1cbee54a8c89e85a1537aafca9
- version: 1.0

## Description

Strong Start RVOL Dashboard is a live watchlist scanner that ranks the symbols you paste in by Relative Volume (RVOL), highest first, and flags the names that have made a "strong start" to the day. It is built for one job: glancing at a basket of stocks and quickly shortlisting the few that are worth a closer look for a long entry, without flipping through dozens of charts.

It runs on daily data, so it works on any chart timeframe and any market, and updates in real time through the session.

[quote]This code is modified fom an original unpublished code by @FadeToGreen (aka FreerThinkEd)[/quote]

[b]⦿ INTRODUCTION[/b]

[b]Relative Volume[/b] 
Relative Volume (RVOL) answers a simple question: is this stock trading more (or less), than it usually does by this point in the day?*

RVOL = volume traded so far today  ÷  average daily volume over the lookback period

Shown as a percentage, 100% means a full average day's worth of volume has already traded, 300% means three times normal, and so on. Unusually heavy volume early in the session is the footprint of real participation. 

[b]Strong Start[/b] 
A strong start means that the price opened higher and has held the gap. 
[quote]Manas Arora, the veteran Indian trader, popularised this terminology. [/quote]The script designates a strong start by a ★, which is shown when both of these are true today:
[list=1]
[*]Today's open is above the previous day's close i.e. the stock gapped up.
[*]Today's low has stayed at or above the previous close × 0.995 i.e. it has not traded more than ~0.5% back below where it closed yesterday.
[/list]A stock that gaps up and immediately fills the gap is not a strong start; one that opens up and refuses to give the level back is. Combining RVOL with a "strong start" (price gapping up and holding above the prior close), provides context many traders look for before committing to a name. So, pairing the ★ with a high RVOL and a green row is the core pattern the dashboard is designed to surface.

[b]⦿ COMPONENTS[/b]

[b]The watchlist table[/b] is the main panel. One row per symbol, sorted by RVOL descending, with these columns:
[list]
[*][b]Symbol[/b]: the ticker (the exchange prefix is stripped for readability).
[*][b]RVOL[/b]: relative volume, as described above.
[*][b]Chg%[/b]: percentage change versus the previous day's close. (Optional; hidden by default.)
[*][b]SS[/b]: a ★ appears when the stock qualifies as a strong start (defined above).
[/list]
Row colouring: Only the heaviest-volume slice of the list is tinted. By default, the top 50% by RVOL. As this is a rank, it recalibrates through the day and naturally highlights names whose volume climbs as the session progresses. Within that tinted group:
[list]
[*][b]Green[/b]: the stock is up by at least the move threshold (default 1.5%)
[*][b]Amber[/b]: heavy volume but the move is still flat: activity without direction yet (early, or churning).
[*][b]Red[/b]: heavy volume but the stock is down by the threshold: being sold into.
[/list]
[b]The current-symbol box[/b] is a small one-cell readout for the symbol on your chart, reading e.g. `★ RVOL 669%'. It shows that symbol's own relative volume and a ★ if it is itself a strong start. It can be placed in any corner, shown on its own, or hidden.

[b]⦿ SETTINGS[/b]
[list]
[*][b]Avg volume lookback (days)[/b]: the window for the average-volume baseline. Default 20 (a steadier baseline; set 10 for a more reactive one).
[*][b]Show RVOL as[/b]: Percent or Ratio.
[*][b]Flag when RVOL% ≥[/b]: the level at which RVOL is treated as "high" for the value's own colour (in Dark theme).
[*][b]Move threshold (Chg% for green)[/b]: how far a tinted row must move to turn green (up) or red (down) rather than amber. Default 1.5%.
[*][b]Light up top % by RVO[/b]L: what fraction of the list, ranked by RVOL, is eligible for a tinted row. Lower = fewer, hotter names only.
[/list]
[b]Watchlist (paste)[/b]
[list]
[*][b]Default exchange for bare tickers[/b]: bare symbols with no `EXCHANGE:` prefix get this added. Default is NSE.
[*][b]Paste watchlist[/b]: paste a TradingView watchlist export or a plain comma-separated list (e.g. from a screener). Section dividers and blanks are skipped automatically; bare tickers are auto-prefixed.
[*][b]Start at symbol #[/b]: skip this many symbols before filling the table, so you can page through a list longer than the per-script symbol limit.
[/list]
[b]Table Options[/b]
[list]
[*][b]Show[/b]: Watchlist only, Current symbol only, or Both.
[*][b]Size / ↕ / ↔[/b]: table text size and on-screen position.
[*][b]Show Chg% column[/b]: reveal the change column (hidden by default).
[*][b]Current-symbol box position[/b]: which corner the box sits in. If it would land on the exact same corner as the table, it auto-moves to the opposite corner so the two never overlap.
[*][b]Theme[/b]: Light (default) or Dark, to match your chart background.
[/list]

[b]⦿ NOTES & LIMITATIONS[/b]
[list]
[*]The dashboard reads daily values (today's running total versus completed prior days), which is why it works on any chart timeframe.
[*]It uses one data request per symbol. A single script can request a limited number of symbols (40 on most plans; the current-symbol box uses one of those slots, so the table holds up to 39 alongside it). Use the  'Start at symbol #' option to page through longer lists, or run a second copy.
[*]RVOL needs at least the lookback number of completed daily bars to be meaningful for each symbol.
[*]Indices and instruments without real volume will simply show no value and drop out of the ranking.
[*]The default exchange is `NSE`, but the tool is market-agnostic — change the default or paste fully-qualified `EXCHANGE:TICKER` symbols for any market.
[/list]

[b]⦿ DISCLAIMER[/b]
[i]This script is a screening and visualisation tool, not financial advice or a trading signal. It highlights where volume and a holding gap-up coincide; it does not predict price and does not account for your risk, position sizing, or strategy. Always do your own analysis. Past activity does not guarantee future results.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © finallynitin
// thanks to @FreeThinkEd for the original script
// thanks to Manas Arora for the strong start concept

//@version=6
indicator("Strong Start RVOL Dashboard", shorttitle = 'SS RVOL', overlay = true, max_bars_back = 500)

const float SS_LOWMULT = 0.995   // day low must hold ≥ prev close × this

// ---- settings ----
int    lookback = input.int(20, "Avg volume lookback (days)", minval = 1, maxval = 100, tooltip = "20 is a steadier baseline than 10. Set 10 to match the screener exactly.", group = "Settings")
string showAs   = input.string("Percent", "Show RVOL as", options = ["Percent", "Ratio"], group = "Settings")
float  rvolFlag = input.float(8.0, "Flag when RVOL% ≥", step = 0.5, group = "Settings")
float  chgFlag  = input.float(1.5, "Move threshold (Chg% for green)", step = 0.1, tooltip = "Row tints green when up at least this, red when down by it, amber in between. Drives color even when the Chg% column is hidden.", group = "Settings")
int    gatePct  = input.int(50, "Light up top % by RVOL", minval = 10, maxval = 100, step = 5, tooltip = "Only the heaviest-volume X% of the list gets a tinted row. Lower = fewer, hotter names.", group = "Settings")

// ---- watchlist (paste) ----
string gWL  = "Watchlist (paste)"
string DEF  = ""
string defExch = input.string("NSE", "Default exchange for bare tickers", tooltip = "Chartink lists are bare tickers. Any token without 'EXCHANGE:' gets this prefix.", group = gWL)
string pasted  = input.text_area(DEF, "Paste watchlist", tooltip = "Up to 40 symbols (39 when the corner box is on); page with 'Start at symbol #'.", group = gWL)
int    startAt = input.int(0, "Start at symbol #", minval = 0, step = 10, tooltip = "Skip this many valid symbols — page a long list past the cap.", group = gWL)

// ---- table options ----
string GRP3       = "════════ Table Options ═════════"
string showWhat   = input.string("Both", "Show", group = GRP3, options = ["Both", "Watchlist only", "Current symbol only"], tooltip = "Which to display: the watchlist table, just the current chart symbol's box, or both.")
string sortBy     = input.string("RVOL", "Sort by", group = GRP3, options = ["RVOL", "Chg%", "SS"], tooltip = "Row order. RVOL = heaviest volume first; Chg% = biggest movers first; SS = strong starts on top (RVOL-ranked within). Volume-leads coloring always highlights the heaviest-RVOL names regardless of sort.")
bool   showChg    = input.bool(false, "Show Chg% column", tooltip = "Hidden by default. Row coloring still reflects the move.", group = GRP3)
string theme      = input.string("Light", "Theme", options = ["Dark", "Light"], tooltip = "Light is the default. Switch to Dark for a dark chart background.", group = GRP3)
string tablesize  = input.string("small", "Table", inline = "tbl", group = GRP3, options = ["tiny", "small", "normal", "large", "huge", "auto"], tooltip = "Watchlist table: size and position (vertical ↕, horizontal ↔).")
string tableposY  = input.string("middle", "↕", inline = "tbl", group = GRP3, options = ["top", "middle", "bottom"])
string tableposX  = input.string("right", "↔", inline = "tbl", group = GRP3, options = ["left", "center", "right"])
string cornerSize = input.string("large", "Box", inline = "box", group = GRP3, options = ["tiny", "small", "normal", "large", "huge", "auto"], tooltip = "Current-symbol box: its own size and position. If it lands on the table's exact spot it's auto-moved so they don't overlap.")
string cornerPosY = input.string("top", "↕", inline = "box", group = GRP3, options = ["top", "middle", "bottom"])
string cornerPosX = input.string("center", "↔", inline = "box", group = GRP3, options = ["left", "center", "right"])

bool showTable  = showWhat != "Current symbol only"
bool showCorner = showWhat != "Watchlist only"

// ---- parse pasted blob → clean EXCHANGE:TICKER list (Chartink bare tickers get defExch) ----
parseSymbols(string raw, string exch) =>
    string norm = str.replace_all(raw, "\n", ",")
    norm := str.replace_all(norm, "\r", ",")
    array<string> out  = array.new<string>()
    array<string> toks = str.split(norm, ",")
    for i = 0 to array.size(toks) - 1
        string tk = str.trim(array.get(toks, i))
        if tk != "" and not str.startswith(tk, "###")
            array.push(out, str.contains(tk, ":") ? tk : exch + ":" + tk)
    out

var array<string> ALL = parseSymbols(pasted, defExch)

// ---- daily metrics per symbol (one request each) ----
calcDaily(simple int N) =>
    float avgv = ta.sma(volume[1], N)
    float rv   = avgv > 0 ? volume / avgv : na
    float cg   = close[1] != 0 ? (close - close[1]) / close[1] * 100 : na
    [rv, cg, open, low, close[1]]

isStrongStart(float o, float l, float pc) =>
    not na(o) and not na(l) and not na(pc) and o > pc and l >= pc * SS_LOWMULT

// ---- watchlist (every bar) ----
int total = array.size(ALL)
int avail = math.max(0, total - startAt)
int cap   = showTable ? (showCorner ? 39 : 40) : 0
int slots = math.min(avail, cap)

array<string> names = array.new<string>()
array<float>  rvs   = array.new<float>()
array<float>  cgs   = array.new<float>()
array<bool>   qs    = array.new<bool>()

if slots > 0
    for i = 0 to slots - 1
        string sym = array.get(ALL, startAt + i)
        [rv, cg, dOpen, dLow, dPrev] = request.security(sym, "1D", calcDaily(lookback), ignore_invalid_symbol = true)
        array.push(names, sym)
        array.push(rvs, rv)
        array.push(cgs, cg)
        array.push(qs, isStrongStart(dOpen, dLow, dPrev))

// sort key for the chosen order (higher = nearer the top)
keyOf(int i) =>
    float rv = array.get(rvs, i)
    float cg = array.get(cgs, i)
    bool  q  = array.get(qs, i)
    sortBy == "RVOL" ? (na(rv) ? -1e18 : rv) : sortBy == "Chg%" ? (na(cg) ? -1e18 : cg) : ((q ? 1e9 : 0.0) + (na(rv) ? 0.0 : rv))

// ---- current chart symbol (corner box) ----
float cRv  = na
bool  cSS  = false
if showCorner
    [crv, ccg, cO, cL, cPc] = request.security(syminfo.tickerid, "1D", calcDaily(lookback), ignore_invalid_symbol = true)
    cRv := crv
    cSS := isStrongStart(cO, cL, cPc)

// ---- palette ----
bool  light  = theme == "Light"
color cText  = light ? color.black : color.white
color cUp    = light ? #0b8043     : color.lime
color cDown  = light ? #cc2222     : color.red
color cFlat  = light ? #c77800     : color.orange
color cMuted = light ? #5b616b     : color.silver
color cNa    = light ? #9aa0aa     : color.gray
color cHdrBg = light ? color.new(#e2e5ea, 0) : color.new(color.gray, 15)
color cHdrTx = light ? color.black : color.white
color cStar  = light ? #0b8043     : color.lime

// ---- geometry ----
tablePos = tableposY == "top" ? (tableposX == "left" ? position.top_left : tableposX == "center" ? position.top_center : position.top_right) : tableposY == "middle" ? (tableposX == "left" ? position.middle_left : tableposX == "center" ? position.middle_center : position.middle_right) : (tableposX == "left" ? position.bottom_left : tableposX == "center" ? position.bottom_center : position.bottom_right)

// corner box position, auto-bumped vertically if it collides exactly with the table
bool   collide = showTable and showCorner and tableposY == cornerPosY and tableposX == cornerPosX
string cYf = collide ? (cornerPosY == "top" ? "bottom" : cornerPosY == "bottom" ? "top" : "top") : cornerPosY
string cXf = cornerPosX
cornerPos = cYf == "top" ? (cXf == "left" ? position.top_left : cXf == "center" ? position.top_center : position.top_right) : cYf == "middle" ? (cXf == "left" ? position.middle_left : cXf == "center" ? position.middle_center : position.middle_right) : (cXf == "left" ? position.bottom_left : cXf == "center" ? position.bottom_center : position.bottom_right)

var table t  = table.new(tablePos,  4, 41, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))
var table tc = table.new(cornerPos, 1, 1, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))

szOf(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : s == "huge" ? size.huge : size.auto
sz  = szOf(tablesize)
csz = szOf(cornerSize)

int chgCol = showChg ? 2 : -1
int ssCol  = showChg ? 3 : 2

fmtRvol(float rv) =>
    na(rv) ? "–" : showAs == "Percent" ? str.tostring(rv * 100, "#") + "%" : str.tostring(rv, "#.00")

if barstate.islast
    // ---- watchlist table ----
    if showTable and array.size(ALL) == 0
        table.clear(t, 0, 0, 3, 40)
        table.cell(t, 0, 0, "Strong Start RVOL Dashboard", text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_formatting = text.format_bold)
        table.cell(t, 0, 1, "Paste a watchlist in  Settings → Paste watchlist", text_color = cText, text_size = sz)
        table.cell(t, 0, 2, "Bare tickers get the default exchange (NSE)", text_color = cMuted, text_size = sz)
        table.cell(t, 0, 3, "Up to 40 symbols", text_color = cMuted, text_size = sz)
    else if showTable
        table.cell(t, 0, 0, "Symbol", text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_formatting = text.format_bold)
        table.cell(t, 1, 0, "RVOL",   text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_formatting = text.format_bold)
        if showChg
            table.cell(t, chgCol, 0, "Chg%", text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_formatting = text.format_bold)
        table.cell(t, ssCol, 0, "SS", text_color = cHdrTx, bgcolor = cHdrBg, text_size = sz, text_formatting = text.format_bold)

        idx = array.new<int>()
        for i = 0 to array.size(names) - 1
            if array.get(names, i) != "" and not na(array.get(rvs, i))
                array.push(idx, i)
        cnt = array.size(idx)

        // RVOL rank (drives the volume-leads highlight, independent of the display sort)
        rvOrder = array.copy(idx)
        if cnt > 1
            for a = 0 to cnt - 2
                for b = a + 1 to cnt - 1
                    if array.get(rvs, array.get(rvOrder, b)) > array.get(rvs, array.get(rvOrder, a))
                        int tmp = array.get(rvOrder, a)
                        array.set(rvOrder, a, array.get(rvOrder, b))
                        array.set(rvOrder, b, tmp)
        rank = array.new<int>(array.size(names), 100000)
        if cnt > 0
            for p = 0 to cnt - 1
                array.set(rank, array.get(rvOrder, p), p)

        // display order per the "Sort by" choice
        if cnt > 1
            for a = 0 to cnt - 2
                for b = a + 1 to cnt - 1
                    if keyOf(array.get(idx, b)) > keyOf(array.get(idx, a))
                        int tmp = array.get(idx, a)
                        array.set(idx, a, array.get(idx, b))
                        array.set(idx, b, tmp)

        table.clear(t, 0, 1, 3, 40)

        int hiCount = math.max(1, int(math.round(cnt * gatePct / 100.0)))

        if cnt > 0
            for r = 0 to cnt - 1
                i  = array.get(idx, r)
                rr = array.get(rank, i)
                nm = array.get(names, i)
                parts = str.split(nm, ":")
                disp  = array.size(parts) > 1 ? array.get(parts, 1) : nm
                rv = array.get(rvs, i)
                cg = array.get(cgs, i)
                bool q = array.get(qs, i)
                float rvPct = na(rv) ? na : rv * 100
                bool isHigh = rr < hiCount
                int  tp = light ? 70 + int(16.0 * rr / math.max(1, hiCount - 1)) : 45 + int(35.0 * rr / math.max(1, hiCount - 1))
                color rowBg = na
                if isHigh and not na(cg)
                    rowBg := cg >= chgFlag ? color.new(color.green, tp) : cg <= -chgFlag ? color.new(color.red, tp) : color.new(color.orange, tp)
                color rvCol = light ? color.black : na(rvPct) ? cNa : rvPct >= rvolFlag ? cUp : rvPct >= rvolFlag * 0.6 ? cFlat : cMuted
                color cgCol = light ? color.black : na(cg) ? cNa : cg >= 0 ? cUp : cDown
                table.cell(t, 0, r + 1, disp, text_color = cText, bgcolor = rowBg, text_size = sz, text_formatting = text.format_bold)
                table.cell(t, 1, r + 1, fmtRvol(rv), text_color = rvCol, bgcolor = rowBg, text_size = sz)
                if showChg
                    table.cell(t, chgCol, r + 1, na(cg) ? "–" : str.tostring(cg, "#.0") + "%", text_color = cgCol, bgcolor = rowBg, text_size = sz)
                table.cell(t, ssCol, r + 1, q ? "★" : "", text_color = cStar, bgcolor = rowBg, text_size = sz)

    // ---- current-symbol box ----
    if showCorner
        color cbg = cSS ? color.new(color.green, light ? 70 : 50) : cHdrBg
        table.cell(tc, 0, 0, (cSS ? "★ " : "") + "RVOL " + fmtRvol(cRv), text_color = cText, bgcolor = cbg, text_size = csz)
````
