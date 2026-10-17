# XI0033 Watermark

- url: https://www.tradingview.com/script/b2gOE7nm-XI0033-Watermark/
- type: indicator
- pine_id: PUB;98aaaca5067a4f28905bf4b8a990500e
- version: 1.0

## Description

A watermark earns nothing. It labels a chart: whose it is, what instrument, what timeframe, and what price was doing when the snapshot was taken. If you publish charts, record trades or stream, that label is the difference between a screenshot and a document.

This script prints up to four lines of text over the chart: three free lines and one symbol line. Any line can carry live tokens that resolve to the current symbol, timeframe, date, weekday, clock, price, change against the previous daily, weekly or monthly close, and volume. It draws text and nothing else: no levels, no signals, no analysis.

[b]One template language for every line[/b]

Each line is a template. Plain text stays as typed; tokens are replaced with live values:

{ticker} {exchange} {tf} {date} {time} {dow} {price} {chgabs} {chg} {chg:D} {chg:W} {chg:M} {vol}

{chg} is the percent change against the previous daily close — the same number the quote header shows. {chg:W} and {chg:M} measure against the previous weekly and monthly closes. {chgabs} is the daily change in price units, {dow} is the weekday name, {vol} is the current bar's volume compacted to K/M/B and printed as n/a where the instrument has no volume feed. Separators are typed straight into the template, so reordering a line is just reordering its text. An empty template hides the line.
 https://www.tradingview.com/x/5WuCchrG/  The two free lines under the brand text are plain templates: one prints the daily, weekly and monthly change side by side, the other stamps the date and the exchange clock. What is typed is what resolves; the line at the bottom of the chart is the symbol line running its own template.

[b]The symbol line[/b]

The fourth line ships with a default template that mirrors the quote header:

{exchange}:{ticker} · {tf} · {date} · {dow} · {price} · {chgabs} · {chg} · {vol}

It is an ordinary template line: delete a token you do not want, move the ones you keep, retype the separators. Nothing in its order is hardcoded.

[b]Sign colouring, token by token[/b]

A Pine table cell holds exactly one text colour. To paint the price green and the weekly change red inside one line, the script slices the symbol line into segments: every {price}, {chgabs} and change token becomes its own cell, coloured by the sign of its own change — {price}, {chgabs} and {chg} follow the daily change, {chg:W} the weekly, {chg:M} the monthly. The text between tokens keeps the line colour. Turn the option off and the line renders as a single cell in a single colour. The one visible cost of the segmented mode is worth naming: cell padding makes the gaps around coloured tokens slightly wider than a plain space.
 https://www.tradingview.com/x/3uoyETiR/  Sign colouring on: the daily percent carries the daily sign; the weekly percent, marked W and appended at the end of the template, carries its own — one line, two directions, base colour in between.

[b]Nine anchors and offsets that tables do not have[/b]

Every line is anchored independently to one of nine chart positions. Lines that land on the same anchor do not overlap: they are collected into one table and stacked in declaration order — Line 1 above Line 2 above Line 3 above the symbol line.

Pine tables expose no pixel offset, so Offset X and Y are built from geometry instead: an empty spacer column sized in percent of chart width pushes a group inward from a left or right edge, and an empty spacer row sized in percent of chart height pushes it away from the top or bottom. X is ignored on a centered anchor and Y on a middle one, because there is no edge to push from. When several lines share an anchor, the group takes the offsets of its first line.  https://www.tradingview.com/x/oiYOBuPc/  Four lines on four different anchors, each block its own table; the corner blocks are pushed inward from their edges by the spacer offsets.

[b]Every line is yours[/b]

Per line: colour, size from 8 to 80, Default or Monospace font, bold, italic. A free line can additionally colour itself as a whole by the sign of the change token it contains. Global: the Positive/Negative pair used by all sign colouring, an extra transparency slider that fades every line on top of its own colour, and a background fill behind the text blocks.

[b]What repaints, and what does not[/b]

Nothing is drawn on historical bars, so there is nothing to repaint in the signal sense. The tables are rebuilt on the last bar and every token updates with the live tape — price, changes and volume move tick by tick, which is what a live watermark is for. The previous daily, weekly and monthly closes are requested from the higher timeframes with a one-bar offset, so only completed bars are read and those references stay fixed until their period rolls over. {date}, {time} and {dow} follow the exchange clock, not bar time.

[b]What is actually original here[/b] 

A chart watermark is public domain — the platform has plenty, and another script that prints a static string would have no reason to exist. Three parts of this one are engineering rather than styling, and the source is open, so they can be read:

[b]A single token engine for all four lines.[/b] One substitution pass resolves thirteen tokens, including three change bases — daily, weekly, monthly — measured the way the quote header measures them, so the symbol line and the free lines speak the same language.

[b]Per-token colouring inside one table row.[/b] The symbol line is split into cells at token boundaries so each value carries the sign colour of its own change, while single-colour lines sharing the anchor are merged across the full row width and stay centered above the segmented one.

[b]Offsets that Pine tables do not offer.[/b] Anchoring, stacking and two-axis fine-tuning are assembled from table geometry — spacer cells sized in percent of the pane — because the platform provides no pixel offset for tables.

[b]What it does not do[/b]

It computes nothing tradeable. No levels, no signals, no alerts, no statistics — it reads the same values the quote header already shows and prints them where and how you want them. It is a labelling tool; the trading remains your job.

[b]The Inputs allow you to set:[/b]

- Line 1–3: template text, colour, size, font (Default/Monospace), bold, italic, colour by change sign, anchor (vertical and horizontal), Offset X and Y
- Symbol line: show/hide, template text, colour price/change by sign, colour, size, font, bold, italic, anchor, Offset X and Y
- Appearance: Positive and Negative colours, extra transparency, background colour

[b]About the chart[/b]

BYBIT:BTCUSDT.P, 5-minute chart. The only script on it is this one, and the three free lines stack at the top center on their default texts — XI0033 with a panda emoji, then the Example and Your text here placeholders. The symbol line sits at the bottom center; its template is trimmed to the exchange, ticker, timeframe, date, weekday and the daily percent change, and sign colouring paints that percent by the sign of the day. No other indicators, no drawings.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © XI0033

indicator("XI0033 Watermark", overlay = true)

// ═══════════════════════════════════════════════════════════════════
// XI0033 Chart Text Engine — a text layout engine for the chart canvas.
//
// Four template lines: three free-text lines plus a symbol line whose
// default template mirrors the quote header. Every line is anchored
// INDEPENDENTLY to one of nine chart anchors and then fine-tuned on
// BOTH axes (spacer geometry, see f_drawGroup). Lines that land on the
// same anchor are merged into a single table and stack in declaration
// order instead of overlapping.
//
// Live tokens (work in every line):
//   {ticker} {exchange} {tf} {date} {time} {dow} {price}
//   {chgabs} {chg} {chg:D} {chg:W} {chg:M} {vol}
// A line carrying a change token can auto-colour by the sign of that
// change, resolved per line from the token it actually contains. The
// symbol line can additionally paint {price}, {chgabs} and every
// change token INDIVIDUALLY by the sign of its own change: it is then
// rendered as one table cell per token segment (a cell holds a single
// colour), which adds a slightly wider gap around painted tokens.
// ═══════════════════════════════════════════════════════════════════

string G_L1  = "Line 1"
string G_L2  = "Line 2"
string G_L3  = "Line 3"
string G_SYM = "Symbol line"
string G_APP = "Appearance"

string TOK = "Any text. Live tokens: {ticker} {exchange} {tf} {date} {time} {dow} {price} {chgabs} {chg} {chg:D} {chg:W} {chg:M} {vol}. Empty field = line hidden."
string ANC = "Anchor for this line. Lines sharing the same anchor stack one under another in declaration order (Line 1, Line 2, Line 3, Symbol) instead of overlapping."
string OFF = "Fine-tune this line inward from its anchored edge. X is measured as % of chart width, Y as % of chart height (Pine tables have no pixel offset). X is ignored on a centered anchor, Y is ignored on a middle anchor. When several lines share an anchor, the group takes the offsets of the FIRST line in it."
string AUT = "Colour this line by the sign of the change token it contains: green when positive, red when negative. {price} and {chgabs} follow the daily change. Ignored if the line has no change or price token."
string SYT = "The symbol line is assembled from this template: reorder, remove or duplicate tokens freely, separators are typed right here. Change tokens are measured against the previous daily/weekly/monthly close (like the quote header). {vol} is the current bar's volume and shows n/a when the instrument has no volume data. Empty field = line hidden."
string SGN = "Paint {price}, {chgabs} and every change token in the Positive/Negative colour by the sign of its own change ({chg:W} follows the weekly change, and so on). The rest of the line keeps the line colour. Off = the whole line is one colour, exactly as a free line."

// ── Line 1 ──
l1Text = input.string("   XI0033 🐼", "Text", group = G_L1, tooltip = TOK)
l1Col  = input.color(#0F3D34, "Color", inline = "l1a", group = G_L1)
l1Size = input.int(21, "Size", minval = 8, maxval = 80, inline = "l1a", group = G_L1)
l1Font = input.string("Default", "Font", options = ["Default", "Monospace"], inline = "l1a", group = G_L1)
l1Bold = input.bool(false, "Bold", inline = "l1b", group = G_L1)
l1Ital = input.bool(false, "Italic", inline = "l1b", group = G_L1)
l1Auto = input.bool(false, "Colour by change sign", inline = "l1b", group = G_L1, tooltip = AUT)
l1V    = input.string("top", "Anchor", options = ["top", "middle", "bottom"], inline = "l1p", group = G_L1, tooltip = ANC)
l1H    = input.string("center", "", options = ["left", "center", "right"], inline = "l1p", group = G_L1)
l1Ox   = input.int(0, "Offset X", minval = 0, maxval = 45, inline = "l1o", group = G_L1, tooltip = OFF)
l1Oy   = input.int(0, "Y", minval = 0, maxval = 45, inline = "l1o", group = G_L1)

// ── Line 2 ──
l2Text = input.string("Example", "Text", group = G_L2, tooltip = TOK)
l2Col  = input.color(#654B14, "Color", inline = "l2a", group = G_L2)
l2Size = input.int(12, "Size", minval = 8, maxval = 80, inline = "l2a", group = G_L2)
l2Font = input.string("Default", "Font", options = ["Default", "Monospace"], inline = "l2a", group = G_L2)
l2Bold = input.bool(true, "Bold", inline = "l2b", group = G_L2)
l2Ital = input.bool(false, "Italic", inline = "l2b", group = G_L2)
l2Auto = input.bool(false, "Colour by change sign", inline = "l2b", group = G_L2, tooltip = AUT)
l2V    = input.string("top", "Anchor", options = ["top", "middle", "bottom"], inline = "l2p", group = G_L2, tooltip = ANC)
l2H    = input.string("center", "", options = ["left", "center", "right"], inline = "l2p", group = G_L2)
l2Ox   = input.int(0, "Offset X", minval = 0, maxval = 45, inline = "l2o", group = G_L2, tooltip = OFF)
l2Oy   = input.int(0, "Y", minval = 0, maxval = 45, inline = "l2o", group = G_L2)

// ── Line 3 ──
l3Text = input.string("Your text here", "Text", group = G_L3, tooltip = TOK)
l3Col  = input.color(#654B14, "Color", inline = "l3a", group = G_L3)
l3Size = input.int(11, "Size", minval = 8, maxval = 80, inline = "l3a", group = G_L3)
l3Font = input.string("Default", "Font", options = ["Default", "Monospace"], inline = "l3a", group = G_L3)
l3Bold = input.bool(false, "Bold", inline = "l3b", group = G_L3)
l3Ital = input.bool(false, "Italic", inline = "l3b", group = G_L3)
l3Auto = input.bool(false, "Colour by change sign", inline = "l3b", group = G_L3, tooltip = AUT)
l3V    = input.string("top", "Anchor", options = ["top", "middle", "bottom"], inline = "l3p", group = G_L3, tooltip = ANC)
l3H    = input.string("center", "", options = ["left", "center", "right"], inline = "l3p", group = G_L3)
l3Ox   = input.int(0, "Offset X", minval = 0, maxval = 45, inline = "l3o", group = G_L3, tooltip = OFF)
l3Oy   = input.int(0, "Y", minval = 0, maxval = 45, inline = "l3o", group = G_L3)

// ── Symbol line ──
symShow = input.bool(true, "Show symbol line", group = G_SYM)
symText = input.string("{exchange}:{ticker} · {tf} · {date} · {dow} · {price} · {chgabs} · {chg} · {vol}", "Text", group = G_SYM, tooltip = SYT)
symSign = input.bool(true, "Colour price/change by sign", group = G_SYM, tooltip = SGN)
symCol  = input.color(#0F3D34, "Color", inline = "sya", group = G_SYM)
symSize = input.int(17, "Size", minval = 8, maxval = 80, inline = "sya", group = G_SYM)
symFont = input.string("Default", "Font", options = ["Default", "Monospace"], inline = "sya", group = G_SYM)
symBold = input.bool(false, "Bold", inline = "syb", group = G_SYM)
symItal = input.bool(false, "Italic", inline = "syb", group = G_SYM)
symV    = input.string("bottom", "Anchor", options = ["top", "middle", "bottom"], inline = "syp", group = G_SYM, tooltip = ANC)
symH    = input.string("center", "", options = ["left", "center", "right"], inline = "syp", group = G_SYM)
symOx   = input.int(0, "Offset X", minval = 0, maxval = 45, inline = "syo", group = G_SYM, tooltip = OFF)
symOy   = input.int(0, "Y", minval = 0, maxval = 45, inline = "syo", group = G_SYM)

// ── Appearance ──
upCol   = input.color(#1D9E75, "Positive", inline = "chc", group = G_APP, tooltip = "Colours used by the sign-colouring options.")
dnCol   = input.color(#D85A30, "Negative", inline = "chc", group = G_APP)
gTransp = input.int(0, "Extra transparency", minval = 0, maxval = 100, group = G_APP, tooltip = "Fades every line by this amount on top of its own colour. Higher = more delicate.")
bgCol   = input.color(color.new(color.white, 100), "Background", group = G_APP)

// ═══════════════════════════════════════════════════════════════════
// MARKET DATA FOR TOKENS
// ═══════════════════════════════════════════════════════════════════
prevD = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)
prevW = request.security(syminfo.tickerid, "W", close[1], lookahead = barmerge.lookahead_on)
prevM = request.security(syminfo.tickerid, "M", close[1], lookahead = barmerge.lookahead_on)

f_pct(_prev) => na(_prev) or _prev == 0 ? na : (close - _prev) / _prev * 100

chgD = f_pct(prevD)
chgW = f_pct(prevW)
chgM = f_pct(prevM)

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════
f_font(_o) => _o == "Monospace" ? font.family_monospace : font.family_default

f_fmt(_b, _i) => _b and _i ? text.format_bold + text.format_italic : _b ? text.format_bold : _i ? text.format_italic : text.format_none

f_pos(_v, _h) =>
    _v == "top" ? (_h == "left" ? position.top_left : _h == "right" ? position.top_right : position.top_center) : _v == "middle" ? (_h == "left" ? position.middle_left : _h == "right" ? position.middle_right : position.middle_center) : (_h == "left" ? position.bottom_left : _h == "right" ? position.bottom_right : position.bottom_center)

f_col(_c) => color.new(_c, math.min(100, color.t(_c) + gTransp))

f_tfStr() =>
    m = timeframe.multiplier
    timeframe.isseconds ? str.tostring(m) + "s" : timeframe.isminutes ? (m >= 60 and m % 60 == 0 ? str.tostring(m / 60) + "h" : str.tostring(m) + "m") : timeframe.isdaily ? str.tostring(m) + "D" : timeframe.isweekly ? str.tostring(m) + "W" : timeframe.ismonthly ? str.tostring(m) + "M" : timeframe.period

f_dowStr() =>
    d = dayofweek(timenow, syminfo.timezone)
    d == dayofweek.monday ? "Monday" : d == dayofweek.tuesday ? "Tuesday" : d == dayofweek.wednesday ? "Wednesday" : d == dayofweek.thursday ? "Thursday" : d == dayofweek.friday ? "Friday" : d == dayofweek.saturday ? "Saturday" : "Sunday"

f_chgStr(_v) => na(_v) ? "n/a" : (_v > 0 ? "+" : "") + str.tostring(_v, "#.##") + "%"
f_chgAbsStr(_prev) => na(_prev) or _prev == 0 ? "n/a" : (close - _prev >= 0 ? "+" : "") + str.tostring(close - _prev, format.mintick)
f_volStr(_v) => _v >= 1e9 ? str.tostring(_v / 1e9, "#.##") + "B" : _v >= 1e6 ? str.tostring(_v / 1e6, "#.##") + "M" : _v >= 1e3 ? str.tostring(_v / 1e3, "#.##") + "K" : str.tostring(_v, "#")

// Substitute every live token in a line template.
f_tok(_s) =>
    r = str.replace_all(_s, "{ticker}", syminfo.ticker)
    r := str.replace_all(r, "{exchange}", syminfo.prefix)
    r := str.replace_all(r, "{tf}", f_tfStr())
    r := str.replace_all(r, "{date}", str.format_time(timenow, "dd.MM.yyyy", syminfo.timezone))
    r := str.replace_all(r, "{time}", str.format_time(timenow, "HH:mm", syminfo.timezone))
    r := str.replace_all(r, "{dow}", f_dowStr())
    r := str.replace_all(r, "{price}", str.tostring(close, format.mintick))
    r := str.replace_all(r, "{chgabs}", f_chgAbsStr(prevD))
    r := str.replace_all(r, "{chg:D}", f_chgStr(chgD))
    r := str.replace_all(r, "{chg:W}", f_chgStr(chgW))
    r := str.replace_all(r, "{chg:M}", f_chgStr(chgM))
    r := str.replace_all(r, "{chg}", f_chgStr(chgD))
    r := str.replace_all(r, "{vol}", na(volume) ? "n/a" : f_volStr(volume))
    r

// Which change does THIS line show? Resolves the sign source per line.
f_signOf(_s) =>
    float v = na
    if str.contains(_s, "{chg:W}")
        v := chgW
    else if str.contains(_s, "{chg:M}")
        v := chgM
    else if str.contains(_s, "{chg:D}")
        v := chgD
    else if str.contains(_s, "{chg}") or str.contains(_s, "{chgabs}") or str.contains(_s, "{price}")
        v := chgD
    v

f_lineCol(_raw, _base, _auto) =>
    color c = _base
    if _auto
        float v = f_signOf(_raw)
        if not na(v)
            c := v >= 0 ? upCol : dnCol
    f_col(c)

// Text and sign source for one sign-coloured token of the symbol line.
f_tokVal(_tk) =>
    string t = ""
    float  s = na
    if _tk == "{price}"
        t := str.tostring(close, format.mintick)
        s := chgD
    else if _tk == "{chgabs}"
        t := f_chgAbsStr(prevD)
        s := chgD
    else if _tk == "{chg:W}"
        t := f_chgStr(chgW)
        s := chgW
    else if _tk == "{chg:M}"
        t := f_chgStr(chgM)
        s := chgM
    else
        t := f_chgStr(chgD)
        s := chgD
    [t, s]

// Split the symbol template into renderable segments.
// _split off: one segment, one colour — the line renders exactly as a
// free line does. _split on: every {price}/{chgabs}/change token
// becomes its own segment coloured by the sign of its own change; the
// text between tokens keeps the base colour. One table cell holds one
// colour, hence the segmentation.
f_symSegs(_raw, _base, _split) =>
    array<string> sgs = array.new<string>()
    array<color>  cls = array.new<color>()
    if not _split
        array.push(sgs, f_tok(_raw))
        array.push(cls, f_col(_base))
    else
        array<string> toks = array.from("{chgabs}", "{chg:D}", "{chg:W}", "{chg:M}", "{chg}", "{price}")
        string rest = _raw
        while str.length(rest) > 0
            int bp = -1
            string bt = ""
            for i = 0 to array.size(toks) - 1
                string tk = array.get(toks, i)
                int p = str.pos(rest, tk)
                if not na(p) and (bp < 0 or p < bp)
                    bp := p
                    bt := tk
            if bp < 0
                array.push(sgs, f_tok(rest))
                array.push(cls, f_col(_base))
                rest := ""
            else
                if bp > 0
                    array.push(sgs, f_tok(str.substring(rest, 0, bp)))
                    array.push(cls, f_col(_base))
                [vt, vs] = f_tokVal(bt)
                array.push(sgs, vt)
                array.push(cls, f_col(na(vs) ? _base : vs >= 0 ? upCol : dnCol))
                rest := str.substring(rest, bp + str.length(bt))
    [sgs, cls]

// One rendered line: one or more coloured segments sharing one font,
// size and geometry. Free lines are always a single segment; the
// symbol line splits into per-token segments when sign colouring is on.
type WLine
    array<string> segs
    array<color>  cols
    int    sz
    string fnt
    bool   bld
    bool   itl
    string av
    string ah
    int    ox
    int    oy

f_add(_arr, _raw, _base, _auto, _sz, _fnt, _bld, _itl, _av, _ah, _ox, _oy) =>
    if str.length(_raw) > 0
        array<string> sgs = array.new<string>()
        array<color>  cls = array.new<color>()
        array.push(sgs, f_tok(_raw))
        array.push(cls, f_lineCol(_raw, _base, _auto))
        array.push(_arr, WLine.new(sgs, cls, _sz, _fnt, _bld, _itl, _av, _ah, _ox, _oy))

// Render one anchor group as a single table.
//
// Pine tables expose no pixel offset, so the fine-tune is built from
// geometry: an empty spacer COLUMN sized in % of chart width pushes the
// text inward from a left/right edge, and an empty spacer ROW sized in %
// of chart height pushes it down from the top or up from the bottom.
// Centered / middle anchors take no spacer — there is no edge to leave.
// The group's geometry comes from the first line that landed on it.
//
// One row per line. A single-segment line takes the whole row (its
// cells are merged into one), a segmented line takes one cell per
// segment — so plain lines stay centered over a segmented neighbour.
f_drawGroup(_grp, _bg) =>
    table t = na
    int n = array.size(_grp)
    if n > 0
        WLine f = array.get(_grp, 0)
        int maxSeg = 1
        for i = 0 to n - 1
            maxSeg := math.max(maxSeg, array.size(array.get(_grp, i).segs))
        bool hsp = f.ox > 0 and (f.ah == "left" or f.ah == "right")
        bool vsp = f.oy > 0 and (f.av == "top" or f.av == "bottom")
        int cols   = maxSeg + (hsp ? 1 : 0)
        int rows   = vsp ? n + 1 : n
        int txtC0  = hsp and f.ah == "left" ? 1 : 0
        int spcCol = f.ah == "left" ? 0 : cols - 1
        int row0   = vsp and f.av == "top" ? 1 : 0
        int spcRow = f.av == "top" ? 0 : n
        t := table.new(f_pos(f.av, f.ah), cols, rows, bgcolor = _bg)
        if hsp
            table.cell(t, spcCol, row0, "", width = f.ox, bgcolor = _bg)
        if vsp
            table.cell(t, txtC0, spcRow, "", height = f.oy, bgcolor = _bg)
        for i = 0 to n - 1
            WLine ln = array.get(_grp, i)
            int k = array.size(ln.segs)
            for j = 0 to k - 1
                table.cell(t, txtC0 + j, row0 + i, array.get(ln.segs, j), text_color = array.get(ln.cols, j), text_size = ln.sz, text_font_family = f_font(ln.fnt), text_formatting = f_fmt(ln.bld, ln.itl), bgcolor = _bg)
            if k < maxSeg
                table.merge_cells(t, txtC0 + k - 1, row0 + i, txtC0 + maxSeg - 1, row0 + i)
    t

// ═══════════════════════════════════════════════════════════════════
// RENDER — last bar only. Up to four anchor groups, rebuilt cleanly.
// ═══════════════════════════════════════════════════════════════════
var table t0 = na
var table t1 = na
var table t2 = na
var table t3 = na

if barstate.islast
    if not na(t0)
        table.delete(t0)
    if not na(t1)
        table.delete(t1)
    if not na(t2)
        table.delete(t2)
    if not na(t3)
        table.delete(t3)
    t0 := na
    t1 := na
    t2 := na
    t3 := na

    array<WLine> lines = array.new<WLine>()

    f_add(lines, l1Text, l1Col, l1Auto, l1Size, l1Font, l1Bold, l1Ital, l1V, l1H, l1Ox, l1Oy)
    f_add(lines, l2Text, l2Col, l2Auto, l2Size, l2Font, l2Bold, l2Ital, l2V, l2H, l2Ox, l2Oy)
    f_add(lines, l3Text, l3Col, l3Auto, l3Size, l3Font, l3Bold, l3Ital, l3V, l3H, l3Ox, l3Oy)

    if symShow and str.length(symText) > 0
        [ss, sc] = f_symSegs(symText, symCol, symSign)
        array.push(lines, WLine.new(ss, sc, symSize, symFont, symBold, symItal, symV, symH, symOx, symOy))

    // Unique anchors, in the order the lines were declared.
    array<string> keys = array.new<string>()
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            WLine ln = array.get(lines, i)
            string k = ln.av + "|" + ln.ah
            if not array.includes(keys, k)
                array.push(keys, k)

    if array.size(keys) > 0
        for ki = 0 to array.size(keys) - 1
            string k = array.get(keys, ki)
            array<WLine> grp = array.new<WLine>()
            for i = 0 to array.size(lines) - 1
                WLine ln = array.get(lines, i)
                if ln.av + "|" + ln.ah == k
                    array.push(grp, ln)
            table t = f_drawGroup(grp, bgCol)
            if ki == 0
                t0 := t
            else if ki == 1
                t1 := t
            else if ki == 2
                t2 := t
            else if ki == 3
                t3 := t
````
