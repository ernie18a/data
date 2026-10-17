# Sullys Sorcery Levels V2 by TenAMTrader

- url: https://www.tradingview.com/script/fA4GgFfC-Sullys-Sorcery-Levels-V2-by-TenAMTrader/
- type: indicator
- pine_id: PUB;30ea1522c8f849c1ad4be4433bbb8640
- version: 4.0

## Description

Sully's Sorcery Levels – by TenAMTrader
Paste your morning market notes into the single text box in settings and this indicator automatically plots all your key price levels on the chart — no manual entry needed.
How it works:

Reads your notes and extracts every price level automatically
The first level mentioned near the word "hold" becomes the yellow pivot line
Everything above the pivot plots in green (upside targets)
Everything below plots in red (downside support)
The full sentence from your notes appears as a label on each line so you always know what to do when price approaches that level

Settings:

Paste your notes into the text box — works with any format, bullet points, paragraphs, or all caps
Use Pivot Override if you want to manually force a specific level as the pivot
Customize color, width, and line style separately for pivot, upside, and downside lines
Adjust label size, background color, and horizontal offset to fit your chart layout

Works best on SPX, NQ, ES and similar index charts.

Short version if you just need a one-liner:
"Paste your morning notes and it auto-plots all your levels — yellow pivot, green upside, red downside, with your own notes written right on the lines."

## Source Code

````pine
//@version=6
indicator('Sully\'s Sorcery Levels w/ ES Converter – by TenAMTrader', overlay = true, max_lines_count = 100, max_labels_count = 100)

//─────────────────────
// SINGLE PASTE BOX
//─────────────────────
textInput = input.text_area('', title = '📋 Paste Morning Notes Here')
pivotOverride = input.float(0, 'Pivot Override (0 = auto)', group = 'Settings')
noteMode = input.string('Action', 'Label text', options = ['Action', 'Action + note', 'Note only', 'Tag only'], group = 'Settings', tooltip = 'Action = what to do at that level (next level up/down). Note = the part of Sully\'s sentence that mentions the level. Hover any label for the full source sentence(s).')
maxNoteLen = input.int(70, 'Max note length (chars)', minval = 10, group = 'Settings')
minLvl = input.float(100, 'Min valid level', group = 'Settings')
maxLvl = input.float(999999, 'Max valid level', group = 'Settings')
maxDistPct = input.float(10, 'Hide levels farther than % from price (0 = off)', minval = 0, group = 'Settings')
trigSolid = input.bool(true, 'Draw trigger levels solid', group = 'Settings')

//─────────────────────
// CONVERTER TOGGLE
//─────────────────────
show_converter = input.bool(true, 'Show Price Converter Box', group = '📊 Price Converter')
tbl_pos = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Top Center', 'Bottom Right', 'Bottom Left', 'Bottom Center'], group = '📊 Price Converter')
tbl_pt = input.int(12, 'Text size (pt)', minval = 6, maxval = 40, group = '📊 Price Converter')
show_us500 = input.bool(false, 'Show US 500 (S&P 500 Index CFD)', group = '📊 Price Converter')
show_nq = input.bool(false, 'Show NQ  (E-mini Nasdaq Futures)', group = '📊 Price Converter')
show_qqq = input.bool(false, 'Show QQQ (Nasdaq ETF)', group = '📊 Price Converter')

//─────────────────────
// PIVOT STYLE
//─────────────────────
col_pivot = input.color(color.yellow, 'Color', group = '⬛ Pivot Style')
pivot_width = input.int(1, 'Width', minval = 1, maxval = 5, group = '⬛ Pivot Style')
pivot_style = input.string('Dotted', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = '⬛ Pivot Style')

//─────────────────────
// UPSIDE STYLE
//─────────────────────
col_up = input.color(color.green, 'Color', group = '🟢 Upside Style')
up_width = input.int(1, 'Width', minval = 1, maxval = 5, group = '🟢 Upside Style')
up_style = input.string('Dashed', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = '🟢 Upside Style')

//─────────────────────
// DOWNSIDE STYLE
//─────────────────────
col_dn = input.color(color.red, 'Color', group = '🔴 Downside Style')
dn_width = input.int(1, 'Width', minval = 1, maxval = 5, group = '🔴 Downside Style')
dn_style = input.string('Dashed', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = '🔴 Downside Style')

//─────────────────────
// LABEL STYLE
//─────────────────────
lbl_bg = input.color(color.rgb(0, 0, 0, 60), 'Label background', group = 'Label Style')
lbl_offset = input.int(10, 'Label offset (bars)', group = 'Label Style')
lbl_size = input.string('Normal', 'Label size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Label Style')
lbl_place = input.string('On line', 'Label placement', options = ['On line', 'Above line', 'Below line'], group = 'Label Style')
showTips = input.bool(true, 'Hover tooltips (full sentence)', group = 'Label Style')

//─────────────────────
// EXTEND
//─────────────────────
extendLeft = input.bool(true, 'Extend left', group = 'Style')
extendRight = input.bool(true, 'Extend right', group = 'Style')

//─────────────────────
// RESOLVE STYLES
//─────────────────────
f_lineStyle(s) =>
    s == 'Solid' ? line.style_solid : s == 'Dashed' ? line.style_dashed : line.style_dotted

f_labelSize(s) =>
    s == 'Auto' ? size.auto : s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : s == 'Normal' ? size.normal : s == 'Large' ? size.large : size.huge

f_lblStyle(s) =>
    s == 'Above line' ? label.style_label_lower_left : s == 'Below line' ? label.style_label_upper_left : label.style_label_left

extMode = extendLeft and extendRight ? extend.both : extendLeft ? extend.left : extendRight ? extend.right : extend.none

//─────────────────────
// VOCABULARY
//─────────────────────
BULL_W = 'above|over|reclaim|reclaims|reclaiming|up|higher|squeeze|squeezes|rally|rip|bounce|upside|breakout|bullish'
BEAR_W = 'below|under|lose|loses|losing|lost|down|lower|sell|sells|selling|selloff|flush|drop|dump|downside|fade|breakdown|bearish'
TRIG_W = 'above|over|below|under|reclaim|reclaims|lose|loses|hold|holds|holding|through|break|breaks|accept|accepts'
TGT_W = 'to|into|at|towards|toward|target|targets|tag|tags|test|tests|hit|fill'
PIV_W = 'pivot|tested|backtested|backtest|retest|retested|rejecting|rejected|rejection|inflection|flip'
REF_W = 'there|that|it|here'

//─────────────────────
// STORAGE
//─────────────────────
var array<float> lvlArr = array.new_float()
var array<bool> aPivot = array.new_bool()
var array<bool> aBullTrig = array.new_bool()
var array<bool> aBearTrig = array.new_bool()
var array<bool> aBullTgt = array.new_bool()
var array<bool> aBearTgt = array.new_bool()
var array<int> aHint = array.new_int()
var array<string> aSnip = array.new_string()
var array<string> aTip = array.new_string()
var array<string> aNextUp = array.new_string()
var array<string> aNextDn = array.new_string()
var array<string> usedSnips = array.new_string()
var array<line> drawnLn = array.new_line()
var array<label> drawnLb = array.new_label()
var string lastTxt = ''

//─────────────────────
// TEXT HELPERS
//─────────────────────
f_fmt(float v) =>
    str.tostring(v, '#.##')

f_in(string w, string list) =>
    str.contains('|' + list + '|', '|' + w + '|')

f_strip(string s) =>
    string chars = '.,;:!?()[]{}"\'~*-•…'
    string r = s
    bool changed = true
    while changed and str.length(r) > 0
        changed := false
        if str.contains(chars, str.substring(r, 0, 1))
            r := str.substring(r, 1)
            changed := true
        int n = str.length(r)
        if n > 0 and str.contains(chars, str.substring(r, n - 1, n))
            r := str.substring(r, 0, n - 1)
            changed := true
    r

f_trunc(string s, int n) =>
    str.length(s) > n ? str.substring(s, 0, n - 1) + '…' : s

f_markClauses(string s) =>
    string r = s
    r := str.replace_all(r, ' and then ', ' ^ ')
    r := str.replace_all(r, ' then ', ' ^ ')
    r := str.replace_all(r, ' Then ', ' ^ ')
    r := str.replace_all(r, ' THEN ', ' ^ ')
    r := str.replace_all(r, ' and we ', ' ^ we ')
    r := str.replace_all(r, ', ', ' ^ ')
    r := str.replace_all(r, '; ', ' ^ ')
    r := str.replace_all(r, ' but ', ' ^ ')
    r := str.replace_all(r, ' But ', ' ^ ')
    r := str.replace_all(r, ' otherwise ', ' ^ ')
    r := str.replace_all(r, ' Otherwise ', ' ^ ')
    r := str.replace_all(r, ' — ', ' ^ ')
    r := str.replace_all(r, ' - ', ' ^ ')
    r

// role: 0 = unknown, 1 = trigger, 2 = target, 3 = pivot | side: 1 bull, -1 bear, 0 neutral
f_addLevel(float v, int role, int side, string snip, string sent) =>
    int idx = array.indexof(lvlArr, v)
    if idx == -1
        string sn = snip != '' and array.includes(usedSnips, snip) ? '' : snip
        if sn != ''
            array.push(usedSnips, sn)
        array.push(lvlArr, v)
        array.push(aPivot, false)
        array.push(aBullTrig, false)
        array.push(aBearTrig, false)
        array.push(aBullTgt, false)
        array.push(aBearTgt, false)
        array.push(aHint, 0)
        array.push(aSnip, sn)
        array.push(aTip, '• ' + sent)
        array.push(aNextUp, '')
        array.push(aNextDn, '')
        idx := array.size(lvlArr) - 1
    else if not str.contains(array.get(aTip, idx), sent)
        array.set(aTip, idx, array.get(aTip, idx) + '\n• ' + sent)
    if role == 3 or (role == 1 and side == 0)
        array.set(aPivot, idx, true)
    else if role == 1
        if side > 0
            array.set(aBullTrig, idx, true)
        else
            array.set(aBearTrig, idx, true)
    else if role == 2
        if side > 0
            array.set(aBullTgt, idx, true)
        else if side < 0
            array.set(aBearTgt, idx, true)
    if side != 0 and array.get(aHint, idx) == 0
        array.set(aHint, idx, side)
    idx

// Records "from src, the next move is tgt" in the direction of side
f_addEdge(float src, float tgt, int side) =>
    int i = na(src) ? -1 : array.indexof(lvlArr, src)
    bool ok = i >= 0 and ((side > 0 and tgt > src) or (side < 0 and tgt < src))
    if ok
        string tv = f_fmt(tgt)
        string cur = side > 0 ? array.get(aNextUp, i) : array.get(aNextDn, i)
        if not str.contains(' / ' + cur + ' / ', ' / ' + tv + ' / ')
            string nw = cur == '' ? tv : cur + ' / ' + tv
            if side > 0
                array.set(aNextUp, i, nw)
            else
                array.set(aNextDn, i, nw)
    ok

f_visible(float lv) =>
    maxDistPct <= 0 or math.abs(lv - close) / close * 100 <= maxDistPct

//─────────────────────
// PARSE
//─────────────────────
if textInput != lastTxt
    lastTxt := textInput
    array.clear(lvlArr)
    array.clear(aPivot)
    array.clear(aBullTrig)
    array.clear(aBearTrig)
    array.clear(aBullTgt)
    array.clear(aBearTgt)
    array.clear(aHint)
    array.clear(aSnip)
    array.clear(aTip)
    array.clear(aNextUp)
    array.clear(aNextDn)
    array.clear(usedSnips)

    string txt = textInput

    // "7,800" -> "7800"
    for k = 0 to 200
        string m = str.match(txt, '\\b\\d{1,3},\\d{3}\\b')
        if m == ''
            break
        txt := str.replace(txt, m, str.replace_all(m, ',', ''), 0)

    // "7840, 7850" / "7840/7850" / "7840-7850" -> "7840 and 7850"
    for k = 0 to 200
        string m = str.match(txt, '\\d\\s*[,/–-]\\s*\\d')
        if m == ''
            break
        int mLen = str.length(m)
        txt := str.replace(txt, m, str.substring(m, 0, 1) + ' and ' + str.substring(m, mLen - 1), 0)

    // sentence breaks (decimals like 7812.50 survive)
    txt := str.replace_all(txt, '\n', ' | ')
    txt := str.replace_all(txt, '. ', ' | ')
    txt := str.replace_all(txt, '! ', ' | ')
    txt := str.replace_all(txt, '? ', ' | ')

    array<string> sentRaw = str.split(txt, '|')
    array<string> sentMk = str.split(f_markClauses(txt), '|')
    float lastSeen = na

    for [s, rawS] in sentRaw
        string sent = f_strip(str.trim(rawS))
        if str.length(sent) < 2
            continue
        string mk = str.trim(array.get(sentMk, s))
        array<string> clauses = str.split(mk, '^')
        array<string> toks = str.split(str.lower(mk), ' ')

        bool pivSent = false
        for tk in toks
            if f_in(f_strip(tk), PIV_W)
                pivSent := true

        int lastDir = 0
        int lastRole = 0
        int lastSide = 0
        int clause = 0
        float srcLvl = na
        float grpLast = na
        string p1 = ''
        string p2 = ''
        string p3 = ''

        for tk in toks
            string w = f_strip(tk)
            if w == ''
                continue
            if w == '^'
                clause += 1
                p1 := ''
                p2 := ''
                p3 := ''
                continue

            if f_in(w, BULL_W)
                lastDir := 1
            else if f_in(w, BEAR_W)
                lastDir := -1

            // "hold above there" -> the last level mentioned becomes the trigger / source
            if f_in(w, REF_W) and (f_in(p1, TRIG_W) or f_in(p2, TRIG_W)) and not na(lastSeen)
                f_addLevel(lastSeen, 1, lastDir, '', sent)
                srcLvl := lastSeen
                grpLast := na

            float v = str.tonumber(w)
            if not na(v) and v >= minLvl and v <= maxLvl
                int role = 0
                int side = lastDir
                bool sameGroup = f_in(p1, 'and|or|&') and lastRole == 2
                if f_in(p1, TRIG_W) or f_in(p2, TRIG_W)
                    role := 1
                else if f_in(p1, TGT_W) or f_in(p2, TGT_W) or f_in(p3, TGT_W)
                    role := 2
                else if f_in(p1, 'and|or|&') and lastRole != 0
                    role := lastRole
                    side := lastSide
                else if pivSent
                    role := 3

                string cl = clause < array.size(clauses) ? f_strip(str.trim(array.get(clauses, clause))) : sent
                f_addLevel(v, role, side, f_trunc(cl, maxNoteLen), sent)

                // Build the "next move" chain
                if role == 2
                    if not sameGroup and not na(grpLast)
                        srcLvl := grpLast
                    f_addEdge(srcLvl, v, side)
                    grpLast := v
                else
                    srcLvl := v
                    grpLast := na

                lastRole := role
                lastSide := side
                lastSeen := v

            p3 := p2
            p2 := p1
            p1 := w

//─────────────────────
// CONVERTER DATA
//─────────────────────
// Live last-price ticks every update (incl. after-hours/overnight on instruments that trade then).
// Previous-close is pulled separately off a confirmed daily bar so % change still compares to yesterday's settle.
spx = request.security('SP:SPX', '1', close, lookahead = barmerge.lookahead_off)
spx_prev = request.security('SP:SPX', 'D', close[1], lookahead = barmerge.lookahead_off)
us500 = request.security('CAPITALCOM:SPX500', '1', close, lookahead = barmerge.lookahead_off)
us500_prev = request.security('CAPITALCOM:SPX500', 'D', close[1], lookahead = barmerge.lookahead_off)
es = request.security('CME_MINI:ES1!', '1', close, lookahead = barmerge.lookahead_off)
es_prev = request.security('CME_MINI:ES1!', 'D', close[1], lookahead = barmerge.lookahead_off)
spy = request.security('AMEX:SPY', '1', close, lookahead = barmerge.lookahead_off)
spy_prev = request.security('AMEX:SPY', 'D', close[1], lookahead = barmerge.lookahead_off)
nq = request.security('CME_MINI:NQ1!', '1', close, lookahead = barmerge.lookahead_off)
nq_prev = request.security('CME_MINI:NQ1!', 'D', close[1], lookahead = barmerge.lookahead_off)
qqq = request.security('NASDAQ:QQQ', '1', close, lookahead = barmerge.lookahead_off)
qqq_prev = request.security('NASDAQ:QQQ', 'D', close[1], lookahead = barmerge.lookahead_off)

spx_chg = spx - spx_prev
us500_chg = us500 - us500_prev
es_chg = es - es_prev
spy_chg = spy - spy_prev
nq_chg = nq - nq_prev
qqq_chg = qqq - qqq_prev

spx_pct = spx_chg / spx_prev * 100
us500_pct = us500_chg / us500_prev * 100
es_pct = es_chg / es_prev * 100
spy_pct = spy_chg / spy_prev * 100
nq_pct = nq_chg / nq_prev * 100
qqq_pct = qqq_chg / qqq_prev * 100

//─────────────────────
// CONVERTER HELPERS
//─────────────────────
conv_pos() =>
    switch tbl_pos
        'Top Right'      => position.top_right
        'Top Left'       => position.top_left
        'Top Center'     => position.top_center
        'Bottom Right'   => position.bottom_right
        'Bottom Left'    => position.bottom_left
        'Bottom Center'  => position.bottom_center
        => position.top_right

conv_sz() =>
    tbl_pt

color_of(chg) =>
    chg >= 0 ? color.new(#00c853, 0) : color.new(#ff1744, 0)
chg_str(v) =>
    (v >= 0 ? '+' : '') + str.tostring(v, '#.##')
pct_str(v) =>
    (v >= 0 ? '+' : '') + str.tostring(v, '#.##') + '%'

//─────────────────────
// CONVERTER TABLE
//─────────────────────
var table t = table.new(conv_pos(), 4, 7, border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1, bgcolor = color.new(#0d1117, 10))

//─────────────────────
// DRAW
//─────────────────────
if barstate.islast

    // ── Clear previous drawings ────────────
    lnSz = array.size(drawnLn)
    if lnSz > 0
        for i = lnSz - 1 to 0 by 1
            line.delete(array.get(drawnLn, i))
    array.clear(drawnLn)

    lbSz = array.size(drawnLb)
    if lbSz > 0
        for i = lbSz - 1 to 0 by 1
            label.delete(array.get(drawnLb, i))
    array.clear(drawnLb)

    int n = array.size(lvlArr)

    // ── Resolve pivot ──────────────────────
    float pivot = na
    if pivotOverride != 0
        pivot := pivotOverride
    else if n > 0
        for i = 0 to n - 1
            if array.get(aPivot, i) and f_visible(array.get(lvlArr, i))
                pivot := array.get(lvlArr, i)
                break
        if na(pivot)
            for i = 0 to n - 1
                if array.get(aBullTrig, i) and array.get(aBearTrig, i) and f_visible(array.get(lvlArr, i))
                    pivot := array.get(lvlArr, i)
                    break

    if n > 0
        // ── Pass 1: resolve side of every level ──
        array<int> sides = array.new_int(n, 0)
        for i = 0 to n - 1
            float lv = array.get(lvlArr, i)
            bool bull = array.get(aBullTgt, i) or array.get(aBullTrig, i)
            bool bear = array.get(aBearTgt, i) or array.get(aBearTrig, i)
            int side = 0
            if not (not na(pivot) and lv == pivot)
                if bull and not bear
                    side := 1
                else if bear and not bull
                    side := -1
                else if array.get(aHint, i) != 0
                    side := array.get(aHint, i)
                else
                    side := lv >= (na(pivot) ? close : pivot) ? 1 : -1
            array.set(sides, i, side)

        // ── Pass 2: draw ──────────────────────
        for i = 0 to n - 1
            float lv = array.get(lvlArr, i)
            if not f_visible(lv)
                continue

            int side = array.get(sides, i)
            bool isPivot = not na(pivot) and lv == pivot
            bool bullTg = array.get(aBullTgt, i)
            bool bearTg = array.get(aBearTgt, i)
            bool isTrig = (side == 1 and array.get(aBullTrig, i)) or (side == -1 and array.get(aBearTrig, i))

            // Nearest visible level above / below (fallback for the next move)
            float nearUpAny = na
            float nearDnAny = na
            float nearUpBull = na
            float nearDnBear = na
            for j = 0 to n - 1
                float o = array.get(lvlArr, j)
                if j != i and f_visible(o)
                    if o > lv and (na(nearUpAny) or o < nearUpAny)
                        nearUpAny := o
                    if o < lv and (na(nearDnAny) or o > nearDnAny)
                        nearDnAny := o
                    if o > lv and array.get(sides, j) == 1 and (na(nearUpBull) or o < nearUpBull)
                        nearUpBull := o
                    if o < lv and array.get(sides, j) == -1 and (na(nearDnBear) or o > nearDnBear)
                        nearDnBear := o

            // Target rank outward from pivot
            int rank = 0
            if side == 1 and bullTg
                rank := 1
                for j = 0 to n - 1
                    float o = array.get(lvlArr, j)
                    if j != i and array.get(aBullTgt, j) and f_visible(o) and o < lv
                        rank += 1
            else if side == -1 and bearTg
                rank := 1
                for j = 0 to n - 1
                    float o = array.get(lvlArr, j)
                    if j != i and array.get(aBearTgt, j) and f_visible(o) and o > lv
                        rank += 1

            // Tag
            string tag = ''
            if isPivot
                tag := '◆ PIVOT'
            else
                string parts = ''
                if rank > 0
                    parts := 'T' + str.tostring(rank)
                if isTrig
                    parts := parts == '' ? 'trigger' : parts + ' · trigger'
                if array.get(aPivot, i)
                    parts := parts == '' ? 'key' : parts + ' · key'
                string arrow = side == 1 ? '▲' : '▼'
                tag := parts == '' ? arrow : arrow + ' ' + parts

            // Action: what to do AT this level
            string act = ''
            if isPivot
                string up = array.get(aNextUp, i)
                string dn = array.get(aNextDn, i)
                if up == '' and not na(nearUpAny)
                    up := f_fmt(nearUpAny)
                if dn == '' and not na(nearDnAny)
                    dn := f_fmt(nearDnAny)
                act := (up != '' ? 'Above → ' + up : '') + (up != '' and dn != '' ? '  ·  ' : '') + (dn != '' ? 'Below → ' + dn : '')
            else if side == 1
                string nx = array.get(aNextUp, i)
                if nx == '' and not na(nearUpBull)
                    nx := f_fmt(nearUpBull)
                act := nx == '' ? 'Last upside target' : (isTrig ? 'Hold above → ' : 'Above → ') + nx
            else
                string nx = array.get(aNextDn, i)
                if nx == '' and not na(nearDnBear)
                    nx := f_fmt(nearDnBear)
                act := nx == '' ? 'Last downside target' : (isTrig ? 'Hold below → ' : 'Below → ') + nx

            string sn = array.get(aSnip, i)
            string body = ''
            if noteMode == 'Action'
                body := act
            else if noteMode == 'Action + note'
                body := act + (sn != '' ? '   |   ' + sn : '')
            else if noteMode == 'Note only'
                body := sn

            string labelText = f_fmt(lv) + '  ' + tag + (body != '' ? '  —  ' + body : '')

            color col = isPivot ? col_pivot : side == 1 ? col_up : col_dn
            int lnW = isPivot ? pivot_width : side == 1 ? up_width : dn_width
            string styName = isPivot ? pivot_style : side == 1 ? up_style : dn_style
            lnSty = trigSolid and isTrig and not isPivot ? line.style_solid : f_lineStyle(styName)

            ln = line.new(bar_index - 1, lv, bar_index, lv, color = col, width = lnW, style = lnSty, extend = extMode)
            array.push(drawnLn, ln)

            lb = label.new(bar_index + lbl_offset, lv, labelText, style = f_lblStyle(lbl_place), color = lbl_bg, textcolor = col, size = f_labelSize(lbl_size))
            if showTips
                label.set_tooltip(lb, array.get(aTip, i))
            array.push(drawnLb, lb)

    // ── Converter Table ────────────────────
    if show_converter
        table.cell(t, 0, 0, '', text_color = color.new(color.gray, 30), text_size = conv_sz(), bgcolor = color.new(#161b22, 5))
        table.cell(t, 1, 0, 'PRICE', text_color = color.new(color.gray, 20), text_size = conv_sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)
        table.cell(t, 2, 0, 'CHG', text_color = color.new(color.gray, 20), text_size = conv_sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)
        table.cell(t, 3, 0, '%', text_color = color.new(color.gray, 20), text_size = conv_sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)

        // SPX
        table.cell(t, 0, 1, ' SPX ', text_color = color.new(#58a6ff, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
        table.cell(t, 1, 1, str.tostring(spx, '#.##'), text_color = color_of(spx_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 2, 1, chg_str(spx_chg), text_color = color_of(spx_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 3, 1, pct_str(spx_pct), text_color = color_of(spx_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

        // ES
        table.cell(t, 0, 2, ' ES  ', text_color = color.new(#f0a500, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
        table.cell(t, 1, 2, str.tostring(es, '#.##'), text_color = color_of(es_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 2, 2, chg_str(es_chg), text_color = color_of(es_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 3, 2, pct_str(es_pct), text_color = color_of(es_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

        // SPY
        table.cell(t, 0, 3, ' SPY ', text_color = color.new(#3fb950, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
        table.cell(t, 1, 3, str.tostring(spy, '#.##'), text_color = color_of(spy_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 2, 3, chg_str(spy_chg), text_color = color_of(spy_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 3, 3, pct_str(spy_pct), text_color = color_of(spy_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

        // US 500 — optional
        nextRow = 4
        if show_us500
            table.cell(t, 0, nextRow, ' US500 ', text_color = color.new(#e3b341, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
            table.cell(t, 1, nextRow, str.tostring(us500, '#.##'), text_color = color_of(us500_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 2, nextRow, chg_str(us500_chg), text_color = color_of(us500_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 3, nextRow, pct_str(us500_pct), text_color = color_of(us500_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            nextRow += 1

        // NQ — optional
        if show_nq
            table.cell(t, 0, nextRow, ' NQ  ', text_color = color.new(#d2a8ff, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
            table.cell(t, 1, nextRow, str.tostring(nq, '#.##'), text_color = color_of(nq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 2, nextRow, chg_str(nq_chg), text_color = color_of(nq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 3, nextRow, pct_str(nq_pct), text_color = color_of(nq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            nextRow += 1

        // QQQ — optional
        if show_qqq
            table.cell(t, 0, nextRow, ' QQQ ', text_color = color.new(#ff7b72, 0), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10))
            table.cell(t, 1, nextRow, str.tostring(qqq, '#.##'), text_color = color_of(qqq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 2, nextRow, chg_str(qqq_chg), text_color = color_of(qqq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
            table.cell(t, 3, nextRow, pct_str(qqq_pct), text_color = color_of(qqq_chg), text_size = conv_sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

plot(close, display = display.none, editable = false)
````
