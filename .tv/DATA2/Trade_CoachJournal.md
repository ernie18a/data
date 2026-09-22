<!-- tradingview-pine-id: PUB;38e812f1fb424cd99f100a5e7fadbb32 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trade Coach-Journal

Source: https://www.tradingview.com/script/bJdRd5Gd-Trade-Coach-Journal/

## Description

Every trader knows they should journal. Almost nobody does it, and the ones who do
mostly end up with a spreadsheet of numbers they never open again.

The problem isn't discipline. It's that a journal tells you what happened last month,
and the moment you actually need it is right now — with your finger over the button,
about to take a trade at 2pm on a Thursday after two losses, which is exactly the
combination that has cost you money forty times before.

This puts your journal on the chart and reduces it to a verdict that changes as your
day does. At 9:50am it might say:

    GOOD WINDOW
    this is when you trade best

By 2:15pm, after a loss, the same panel says:

    STOP · DONE TODAY
    weak window and you're coming off a loss

Nothing in between those two moments came from the market. It came from you, forty
trades ago, doing the same thing.

THE PART THAT ACTUALLY CHANGES THINGS

Timing patterns are useful. Knowing your afternoons win 30% is worth something. But
you can't decide to make afternoons behave differently.

You can decide to stop chasing.

So every trade can carry tags — words you invent, starting with #. Log a trade you
chased as:

    8/17  13:35  S  29140  14:10  29168.75  #fomo

Do that twenty times and the panel stops talking about the clock:

    TOP FIX
    #fomo trades win 18% (n=22)
    → stop taking #fomo entries

That's a different kind of sentence than "your Tuesdays are weak." It names a habit,
it's yours, and you can change it tomorrow morning. Tag findings outrank timing
findings in the panel for exactly that reason.

Use whatever vocabulary fits how you actually trade — #plan, #revenge, #late, #news,
#tired, #a+. The only requirement is honesty. Putting #plan on a trade you chased
makes the whole thing useless, and nobody sees this but you.

LOGGING A TRADE

One line, in the settings:

    8/17  9:45  L  29048  10:15  29096.5  #plan

August 17th, 9:45am, long from 29048, out at 10:15 at 29096.50, planned setup.

The parser tries hard not to make you think about formatting. These four lines are
the same trade:

    8/17  9:45  L  29048  10:15  29096.5
    8/17, 9:45, L, 29048, 10:15, 29096.5
    08-17 0945 LONG 29048 1015 29096.5
    2026-08-17 09:45 buy 29048 10:15 29096.5

Dates take 8/17, 08-17, 2026-08-17, 0817 or 20260817. Times take 9:45, 09:45 or 0945.
Side takes L/S, LONG/SHORT or BUY/SELL in any case. Spaces and commas both work. The
year is set once in settings so you're not retyping it. Exit time is optional — leave
it out and you keep every statistic, you just lose the line drawn on the chart. An
exit time earlier than the entry is read as an overnight hold.

Times should match the clock on your chart's time axis.

WHAT YOU SEE

Under the verdict, the panel is deliberately short:

    now: pm    ▰▰▰▱▱▱▱▱▱▱   30%  n=20
    form       ●●○○●○○○●○
    equity     █▇▆▄▅▃▂▁
    today      3 trades · -2.1R

Four lines, and the third one is the one that hurts. Your form dots can look fine
while the equity sparkline slides down the page — that's the shape of winning often
and losing big, and it's the most common way a trader who looks profitable isn't.

The footer says the same thing in numbers:

    40 trades · 67% win · -0.12R avg

A green win rate sitting next to a red R average is worth more than any entry signal
you'll read this year.

Every statistic carries its sample count, and rows stay grey until they've earned an
opinion. A grey row means the script doesn't know yet — more honest than a confident
percentage built on six trades.

Turn on "show full detail" for the full breakdown: morning against afternoon, long
against short, after-loss, average winner against average loser, worst losing streak,
and every tag ranked by how often you use it.

On the chart itself each trade draws where it happened — a triangle at the entry, a
line to the exit, the R result labeled, tags in the tooltip.

ALERTS

The panel only helps if you're looking at it, and the moments you most need it are
the moments you're not.

    Entering a weak window
    Daily stop hit
    STOP for today

Set them once. Then the coach speaks first, and you don't have to remember to ask.

ON THE NEURAL NETWORK IN GROUP 4

There's a small neural network in the advanced settings that trains on your logged
trades and estimates whether a trade taken under current conditions would win. Most
of the time it says this:

    verdict     not significant
    vs control  58% vs 62%

That second line is the whole reason to trust it. Alongside the real network, the
script trains an identical one on deliberately shuffled labels — a model that cannot
possibly know anything. If the real network can't clearly beat that, its opinion is
suppressed and the panel says so.

A network with this many parameters needs several hundred trades before it can
separate a pattern from a coincidence. It will probably read "not significant" for a
long time, and that's the safeguard working rather than the tool failing.

Nothing in the verdict, TOP FIX, or the pattern tables involves the model. That's all
plain counting, which is why it becomes usable around 20 trades and trustworthy around
40 — while the network is still deciding whether it knows anything at all.

IF SOMETHING LOOKS WRONG

The panel tells you which of three things went wrong rather than making you guess:

    ⚠ 3 lines unreadable (line 12)

Line 12 didn't parse. Usually a missing price, a typo in the date, or a side it
didn't recognize.

    ⚠ 8 trades off-chart — check timezone

The timestamps don't land on a loaded bar. Either scroll left for more history, or
your times aren't in the exchange's timezone.

    ⚠ 5 trades too early on this chart

The script needs 220 bars of warmup before it can read market context. Load more
history or move to a higher timeframe.

If it reads "0 of 40," everything was rejected or fell outside the chart. Work
through those three in order.

This is a review tool. It reports patterns in trades you've already taken, generates
no entry signals, and makes no claim about future results. What it shows you is your
own history.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheRealDrip2Rip

//@version=6
// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  TRADE COACH-JOURNAL                                                     ║
// ║                                                                          ║
// ║  Log a trade — spaces or commas, both fine:                              ║
// ║      8/17  9:45  L  29048  10:15  29096.5  #plan                         ║
// ║      08/17 09:45 LONG 29048 29096.5  #fomo #late                         ║
// ║                                                                          ║
// ║  Anything starting with # (after the first token) is a TAG. Tags are     ║
// ║  yours to invent: #plan #fomo #revenge #news #late #a+ #tired            ║
// ║  The coach counts win rate per tag — why you entered, not just when.     ║
// ║                                                                          ║
// ║  Drawings are placed by TIME, not bar index, so long journals don't      ║
// ║  overrun Pine's historical buffer.                                       ║
// ╚══════════════════════════════════════════════════════════════════════════╝
indicator("Trade Coach-Journal", overlay = true, max_labels_count = 500,
          max_lines_count = 500, max_bars_back = 5000)

N_IN   = 8
N_HID  = 5
MAXTAG = 12

// ── journal ────────────────────────────────────────────────────────────────
gJ = "1 · your trades"
journal = input.text_area(
  "# date time L/S entry [exit time] exit  #tags\n" +
  "8/17  9:45   L  29048    10:15  29096.5  #plan\n" +
  "8/17  13:35  S  29140    14:10  29168.75 #fomo\n" +
  "8/18  9:40   S  29155.75 10:25  29102.25 #plan\n" +
  "8/18  13:15  L  29160.25 14:00  29128    #revenge",
  "log", group = gJ)
defYear = input.int(2026, "year (if not in date)", group = gJ)

// ── coach ──────────────────────────────────────────────────────────────────
gC       = "2 · coach"
splitHr  = input.float(11.0, "morning ends at (hour)", minval = 6, maxval = 20, step = 0.5, group = gC)
minN     = input.int(15,    "min trades per pattern", minval = 8, group = gC)
minTagN  = input.int(8,     "min trades per tag", minval = 4, group = gC)
edgeMin  = input.float(0.15,"flag gap over", minval = 0.05, maxval = 0.5, step = 0.01, group = gC)
dayStopR = input.float(-3.0,"daily stop (R)", maxval = 0.0, step = 0.5, group = gC)
detail   = input.bool(false,"show full detail", group = gC)

// ── display ────────────────────────────────────────────────────────────────
gD      = "3 · display"
showMk  = input.bool(true, "mark trades",     group = gD)
showLn  = input.bool(true, "entry→exit line", group = gD)
showR   = input.bool(true, "R labels",        group = gD)
maxDraw = input.int(120,   "max drawn", minval = 10, maxval = 300, group = gD)
txtSz   = input.string("normal", "size",
          options = ["small", "normal", "large", "huge"], group = gD)
pPos    = input.string("top left", "position",
          options = ["top right", "middle right", "bottom right",
                     "top left", "middle left", "bottom left"], group = gD)

// ── model (advanced) ───────────────────────────────────────────────────────
gM       = "4 · model (advanced)"
trSplit  = input.float(0.70, "train split", minval = 0.4, maxval = 0.9, group = gM)
lr       = input.float(0.02, "lr", step = 0.001, group = gM)
maxEp    = input.int(40,     "max epochs", minval = 1, maxval = 300, group = gM)
stepsBar = input.int(60,     "steps/bar",  minval = 5, maxval = 400, group = gM)
wd       = input.float(0.002,"weight decay", minval = 0.0, step = 0.001, group = gM)
minTest  = input.int(25,     "min test trades", minval = 10, group = gM)
minZ     = input.float(2.0,  "min z", minval = 1.0, step = 0.1, group = gM)

C_BG   = #0d1117
C_BAND = #1b2231
C_ALT  = #131a26
C_LBL  = #8b96a5
C_KEY  = #8ab4ff
C_NUM  = #f0b968
C_TXT  = #e6edf3
C_POS  = #3ae0b0
C_NEG  = #ff8a9b
C_WARN = #ffb454
C_INK  = #0a0e14
C_NONE = color.new(color.black, 100)

// ════════════════════════════════════════════════════════════ helpers ══════
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))
f_fin(v, d)        => na(v) ? d : v

f_tanh(x) =>
    e = math.exp(2.0 * f_clamp(x, -15.0, 15.0))
    (e - 1.0) / (e + 1.0)

f_sig(x) => 1.0 / (1.0 + math.exp(-f_clamp(x, -15.0, 15.0)))

var rngS = array.new_int(1, 20260902)
f_rand() =>
    s = (1664525 * array.get(rngS, 0) + 1013904223) % 2147483648
    array.set(rngS, 0, s)
    s / 2147483648.0
f_ri(n) => math.min(n - 1, int(math.floor(f_rand() * n)))

f_pad(s, n) =>
    string r = s
    while str.length(r) < n
        r := r + " "
    r
f_lpad(s, n) =>
    string r = s
    while str.length(r) < n
        r := " " + r
    r

f_pct0(v) => str.tostring(math.round(f_fin(v, 0.0) * 100)) + "%"
f_pct1(v) => str.tostring(f_fin(v, 0.0) * 100, "0.0") + "%"

f_bar(v, n) =>
    k = int(math.round(f_clamp(f_fin(v, 0.0), 0.0, 1.0) * n))
    string s = ""
    for i = 0 to n - 1
        s := s + (i < k ? "▰" : "▱")
    s

f_stat(lbl, w, n) =>
    n > 0 ? f_pad(lbl, 10) + f_bar(w / float(n), 10) + "  " + f_lpad(f_pct0(w / float(n)), 4) + "  n=" + str.tostring(n) : f_pad(lbl, 10) + "—"

f_form(arr, n) =>
    sz  = array.size(arr)
    cnt = math.min(sz, n)
    string s = ""
    if cnt > 0
        for i = sz - cnt to sz - 1
            s := s + (array.get(arr, i) > 0.5 ? "●" : "○")
    s

f_spark(arr, n) =>
    sz  = array.size(arr)
    cnt = math.min(sz, n)
    string s = ""
    if cnt > 1
        cum = array.new_float(0)
        float run = 0.0
        for i = sz - cnt to sz - 1
            run += array.get(arr, i)
            array.push(cum, run)
        lo  = array.min(cum)
        hi  = array.max(cum)
        rgs = hi - lo
        for i = 0 to array.size(cum) - 1
            v = rgs <= 0 ? 0.5 : (array.get(cum, i) - lo) / rgs
            k = int(math.round(v * 7))
            s := s + (k <= 0 ? "▁" : k == 1 ? "▂" : k == 2 ? "▃" : k == 3 ? "▄" :
                      k == 4 ? "▅" : k == 5 ? "▆" : k == 6 ? "▇" : "█")
    s

f_tok(lineIn) =>
    s = str.replace_all(lineIn, ",", " ")
    s := str.replace_all(s, "\t", " ")
    s := str.replace_all(s, "\"", " ")
    parts = str.split(s, " ")
    out = array.new_string(0)
    if array.size(parts) > 0
        for i = 0 to array.size(parts) - 1
            p = array.get(parts, i)
            if str.length(p) > 0
                array.push(out, p)
    out

f_isSide(t) =>
    u = str.upper(t)
    u == "L" or u == "S" or u == "LONG" or u == "SHORT" or u == "BUY" or u == "SELL"

f_sideVal(t) =>
    u = str.upper(t)
    (u == "L" or u == "LONG" or u == "BUY") ? 1 : -1

f_isTime(t) =>
    bool r = str.contains(t, ":")
    if not r and str.length(t) == 4 and not str.contains(t, ".")
        v = str.tonumber(t)
        r := not na(v) and v >= 0 and v < 2400
    r

f_toInt(s) =>
    v = str.tonumber(s)
    int r = na
    if not na(v)
        r := int(v)
    r

f_date(t, dy) =>
    int yy = dy
    int mm = na
    int dd = na
    string s = str.replace_all(t, "/", "-")
    if str.contains(s, "-")
        p = str.split(s, "-")
        if array.size(p) == 3
            yv = f_toInt(array.get(p, 0))
            yy := na(yv) ? dy : yv
            mm := f_toInt(array.get(p, 1))
            dd := f_toInt(array.get(p, 2))
        else if array.size(p) == 2
            mm := f_toInt(array.get(p, 0))
            dd := f_toInt(array.get(p, 1))
    else if str.length(s) == 4
        mm := f_toInt(str.substring(s, 0, 2))
        dd := f_toInt(str.substring(s, 2, 4))
    else if str.length(s) == 8
        yv = f_toInt(str.substring(s, 0, 4))
        yy := na(yv) ? dy : yv
        mm := f_toInt(str.substring(s, 4, 6))
        dd := f_toInt(str.substring(s, 6, 8))
    [yy, mm, dd]

f_time(t) =>
    int hh = na
    int mi = na
    if str.contains(t, ":")
        p = str.split(t, ":")
        if array.size(p) >= 2
            hh := f_toInt(array.get(p, 0))
            mi := f_toInt(array.get(p, 1))
    else if str.length(t) == 4
        hh := f_toInt(str.substring(t, 0, 2))
        mi := f_toInt(str.substring(t, 2, 4))
    [hh, mi]

// ════════════════════════════════════ net (weights passed in) ══════════════
f_fwd(W1, B1, W2, Bo, hAr, xs) =>
    for j = 0 to N_HID - 1
        float s = array.get(B1, j)
        for i = 0 to N_IN - 1
            s += array.get(W1, j * N_IN + i) * array.get(xs, i)
        array.set(hAr, j, f_tanh(s))
    float o = array.get(Bo, 0)
    for j = 0 to N_HID - 1
        o += array.get(W2, j) * array.get(hAr, j)
    f_sig(o)

f_step(W1, B1, W2, Bo, hAr, dHr, xs, y, pw) =>
    bool ok = not na(y)
    for i = 0 to N_IN - 1
        if na(array.get(xs, i))
            ok := false
    float err = na
    if ok
        yh = f_fwd(W1, B1, W2, Bo, hAr, xs)
        if not na(yh)
            dz2 = f_clamp((yh - y) * (y > 0.5 ? pw : 1.0), -4.0, 4.0)
            for j = 0 to N_HID - 1
                h = array.get(hAr, j)
                array.set(dHr, j, f_clamp(dz2 * array.get(W2, j) * (1.0 - h * h), -4.0, 4.0))
            for j = 0 to N_HID - 1
                w = array.get(W2, j)
                array.set(W2, j, f_clamp(w - lr * (dz2 * array.get(hAr, j) + wd * w), -8.0, 8.0))
            array.set(Bo, 0, f_clamp(array.get(Bo, 0) - lr * dz2, -8.0, 8.0))
            for j = 0 to N_HID - 1
                d = array.get(dHr, j)
                for i = 0 to N_IN - 1
                    k = j * N_IN + i
                    w = array.get(W1, k)
                    array.set(W1, k, f_clamp(w - lr * (d * array.get(xs, i) + wd * w), -8.0, 8.0))
                array.set(B1, j, f_clamp(array.get(B1, j) - lr * d, -8.0, 8.0))
            err := math.abs(yh - y)
    err

var A1 = array.new_float(N_HID * N_IN, 0.0)
var Ab = array.new_float(N_HID, 0.0)
var A2 = array.new_float(N_HID, 0.0)
var Ao = array.new_float(1, 0.0)
var S1 = array.new_float(N_HID * N_IN, 0.0)
var Sb = array.new_float(N_HID, 0.0)
var S2 = array.new_float(N_HID, 0.0)
var So = array.new_float(1, 0.0)
var hA = array.new_float(N_HID, 0.0)
var dH = array.new_float(N_HID, 0.0)

// ════════════════════════════════════════════════════════════ parsing ══════
var jTime = array.new_int(0)
var jXTm  = array.new_int(0)
var jSide = array.new_int(0)
var jEnt  = array.new_float(0)
var jExt  = array.new_float(0)
var jEBar = array.new_int(0)
var jXBar = array.new_int(0)
var jTagS = array.new_string(0)          // "3,7" — indices into the tag registry
var int   nBad  = 0
var string badLn = ""

// tag registry
var tagNm = array.new_string(0)
var tagN  = array.new_int(0)
var tagW  = array.new_int(0)
var tagR  = array.new_float(0)

if barstate.isfirst
    lines = str.split(journal, "\n")
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            raw = array.get(lines, i)
            if str.length(str.replace_all(raw, " ", "")) > 0 and
               not str.startswith(str.replace_all(raw, " ", ""), "#")
                all = f_tok(raw)
                // split tags out first so field positions stay predictable
                tk  = array.new_string(0)
                tgs = array.new_string(0)
                if array.size(all) > 0
                    for q = 0 to array.size(all) - 1
                        p = array.get(all, q)
                        if str.startswith(p, "#") and str.length(p) > 1
                            array.push(tgs, str.lower(p))
                        else
                            array.push(tk, p)
                if array.size(tk) >= 4
                    int si = -1
                    for q = 0 to array.size(tk) - 1
                        if f_isSide(array.get(tk, q))
                            si := q
                            break
                    bool good = si >= 2 and array.size(tk) >= si + 3
                    int   et = na
                    int   xt = na
                    float en = na
                    float ex = na
                    int   sd = 0
                    if good
                        [yy, mm, dd] = f_date(array.get(tk, si - 2), defYear)
                        [hh, mi]     = f_time(array.get(tk, si - 1))
                        if na(mm) or na(dd) or na(hh) or na(mi)
                            good := false
                        else if mm < 1 or mm > 12 or dd < 1 or dd > 31 or hh > 23 or mi > 59
                            good := false
                        else
                            et := timestamp(syminfo.timezone, yy, mm, dd, hh, mi, 0)
                            sd := f_sideVal(array.get(tk, si))
                            en := str.tonumber(array.get(tk, si + 1))
                            rem = array.size(tk) - (si + 2)
                            if rem >= 2 and f_isTime(array.get(tk, si + 2))
                                [xh, xm] = f_time(array.get(tk, si + 2))
                                if not na(xh) and not na(xm) and xh <= 23 and xm <= 59
                                    xt := timestamp(syminfo.timezone, yy, mm, dd, xh, xm, 0)
                                    if xt < et
                                        xt := xt + 86400000     // crossed midnight
                                ex := str.tonumber(array.get(tk, si + 3))
                            else if rem >= 1
                                ex := str.tonumber(array.get(tk, si + 2))
                            if na(en) or na(ex) or en <= 0 or ex <= 0
                                good := false
                    if good
                        // register tags, build the index list for this trade
                        string tstr = ""
                        if array.size(tgs) > 0
                            for q = 0 to array.size(tgs) - 1
                                nm = array.get(tgs, q)
                                int ti = -1
                                if array.size(tagNm) > 0
                                    for z = 0 to array.size(tagNm) - 1
                                        if array.get(tagNm, z) == nm
                                            ti := z
                                            break
                                if ti < 0 and array.size(tagNm) < MAXTAG
                                    array.push(tagNm, nm)
                                    array.push(tagN, 0)
                                    array.push(tagW, 0)
                                    array.push(tagR, 0.0)
                                    ti := array.size(tagNm) - 1
                                if ti >= 0
                                    tstr := tstr + (str.length(tstr) > 0 ? "," : "") + str.tostring(ti)
                        array.push(jTime, et)
                        array.push(jXTm,  na(xt) ? et : xt)
                        array.push(jSide, sd)
                        array.push(jEnt, en)
                        array.push(jExt, ex)
                        array.push(jEBar, -1)
                        array.push(jXBar, -1)
                        array.push(jTagS, tstr)
                    else
                        nBad += 1
                        if str.length(badLn) == 0
                            badLn := "line " + str.tostring(i + 1)

    if array.size(jTime) > 1
        ord = array.sort_indices(jTime, order.ascending)
        t2 = array.new_int(0)
        u2 = array.new_int(0)
        s2 = array.new_int(0)
        e2 = array.new_float(0)
        x2 = array.new_float(0)
        g2 = array.new_string(0)
        for i = 0 to array.size(ord) - 1
            k = array.get(ord, i)
            array.push(t2, array.get(jTime, k))
            array.push(u2, array.get(jXTm,  k))
            array.push(s2, array.get(jSide, k))
            array.push(e2, array.get(jEnt,  k))
            array.push(x2, array.get(jExt,  k))
            array.push(g2, array.get(jTagS, k))
        array.clear(jTime)
        array.clear(jXTm)
        array.clear(jSide)
        array.clear(jEnt)
        array.clear(jExt)
        array.clear(jTagS)
        for i = 0 to array.size(t2) - 1
            array.push(jTime, array.get(t2, i))
            array.push(jXTm,  array.get(u2, i))
            array.push(jSide, array.get(s2, i))
            array.push(jEnt,  array.get(e2, i))
            array.push(jExt,  array.get(x2, i))
            array.push(jTagS, array.get(g2, i))

    l1 = math.sqrt(6.0 / (N_IN + N_HID))
    l2 = math.sqrt(6.0 / (N_HID + 1))
    for i = 0 to N_HID * N_IN - 1
        v = (f_rand() * 2.0 - 1.0) * l1
        array.set(A1, i, v)
        array.set(S1, i, v)
    for j = 0 to N_HID - 1
        v = (f_rand() * 2.0 - 1.0) * l2
        array.set(A2, j, v)
        array.set(S2, j, v)

var xOrd = array.new_int(0)
var xCur = array.new_int(1, 0)
if barstate.isfirst and array.size(jXTm) > 0
    o = array.sort_indices(jXTm, order.ascending)
    for i = 0 to array.size(o) - 1
        array.push(xOrd, array.get(o, i))

// ════════════════════════════════════════════════════ market context ═══════
atr    = ta.atr(14)
ema2   = ta.ema(close, 200)
rsi14  = ta.rsi(close, 14)
vw     = ta.vwap
trendF = (close - ema2) / atr
vregF  = atr / ta.sma(atr, 100) - 1.0
rsiF   = (rsi14 - 50.0) / 25.0
vwapF  = (close - vw) / atr
todF   = (hour + minute / 60.0) / 24.0
dowF   = (dayofweek - 1) / 6.0

warm = bar_index > 220 and not na(atr) and not na(ema2) and not na(rsi14) and not na(vregF)

// ═══════════════════════════ capture + running counters (global scope) ═════
var smpX  = array.new_float(0)
var smpY  = array.new_float(0)
var smpYs = array.new_float(0)
var smpR  = array.new_float(0)
var smpI  = array.new_int(0)
var cur   = array.new_int(1, 0)

var int prevLoss = 0
var int wins = 0
var float sumR = 0.0
var float sumW = 0.0
var float sumL = 0.0
var int nW = 0
var int nL = 0
var int strk = 0
var int mxSt = 0
var int amN = 0
var int amW = 0
var int pmN = 0
var int pmW = 0
var int lgN = 0
var int lgW = 0
var int shN = 0
var int shW = 0
var int alN = 0
var int alW = 0
var int nSkipEarly = 0        // trades that fell before the warmup window
// rolling "day so far", keyed to the last logged trading day
var int   curDay = na
var int   todN   = 0
var float todR   = 0.0

nTr = array.size(jTime)

// Pine does not short-circuit `and`: bounds check must control loop entry.
if nTr > 0
    while array.get(cur, 0) < nTr
        c  = array.get(cur, 0)
        jt = array.get(jTime, c)
        if jt >= time_close
            break
        if jt >= time
            if not warm
                nSkipEarly += 1
            else
                sd = array.get(jSide, c)
                en = array.get(jEnt, c)
                ex = array.get(jExt, c)
                // guard a zero/na ATR: halts and illiquid symbols produce inf
                aRef = atr[1]
                if na(aRef) or aRef <= 0
                    aRef := syminfo.mintick * 4
                r  = (ex - en) * sd / aRef
                wn = r > 0
                tr = f_clamp(f_fin(trendF[1], 0.0), -6.0, 6.0)
                array.push(smpX, f_fin(todF, 0.5))
                array.push(smpX, f_fin(dowF, 0.5))
                array.push(smpX, tr)
                array.push(smpX, f_clamp(f_fin(vregF[1], 0.0), -2.0, 2.0))
                array.push(smpX, f_clamp(f_fin(rsiF[1],  0.0), -2.0, 2.0))
                array.push(smpX, f_clamp(f_fin(vwapF[1], 0.0), -6.0, 6.0))
                array.push(smpX, sd * math.sign(tr))
                array.push(smpX, prevLoss)
                array.push(smpY,  wn ? 1.0 : 0.0)
                array.push(smpYs, wn ? 1.0 : 0.0)
                array.push(smpR, r)
                array.push(smpI, c)
                array.set(jEBar, c, bar_index)

                // day-so-far
                dnum = year(jt) * 10000 + month(jt) * 100 + dayofmonth(jt)
                if na(curDay) or dnum != curDay
                    curDay := dnum
                    todN   := 0
                    todR   := 0.0
                todN += 1
                todR += r

                // tag counters
                ts = array.get(jTagS, c)
                if str.length(ts) > 0
                    tp = str.split(ts, ",")
                    for q = 0 to array.size(tp) - 1
                        ti = f_toInt(array.get(tp, q))
                        if not na(ti) and ti < array.size(tagN)
                            array.set(tagN, ti, array.get(tagN, ti) + 1)
                            array.set(tagR, ti, array.get(tagR, ti) + r)
                            if wn
                                array.set(tagW, ti, array.get(tagW, ti) + 1)

                wins += wn ? 1 : 0
                sumR += r
                if wn
                    sumW += r
                    nW += 1
                    strk := 0
                else
                    sumL += r
                    nL += 1
                    strk += 1
                    mxSt := math.max(mxSt, strk)
                if hour + minute / 60.0 < splitHr
                    amN += 1
                    amW += wn ? 1 : 0
                else
                    pmN += 1
                    pmW += wn ? 1 : 0
                if sd > 0
                    lgN += 1
                    lgW += wn ? 1 : 0
                else
                    shN += 1
                    shW += wn ? 1 : 0
                if prevLoss == 1
                    alN += 1
                    alW += wn ? 1 : 0
                prevLoss := wn ? 0 : 1
        array.set(cur, 0, c + 1)

if array.size(xOrd) > 0
    while array.get(xCur, 0) < array.size(xOrd)
        p  = array.get(xCur, 0)
        k  = array.get(xOrd, p)
        xt = array.get(jXTm, k)
        if xt >= time_close
            break
        if xt >= time
            array.set(jXBar, k, bar_index)
        array.set(xCur, 0, p + 1)

var shuf = array.new_bool(1, false)
if array.get(cur, 0) >= nTr and nTr > 0 and not array.get(shuf, 0) and array.size(smpY) > 4
    for i = array.size(smpYs) - 1 to 1
        k = f_ri(i + 1)
        a = array.get(smpYs, i)
        array.set(smpYs, i, array.get(smpYs, k))
        array.set(smpYs, k, a)
    array.set(shuf, 0, true)

// ════════════════════════════════════════════════════ train, amortised ════
var sX    = array.new_float(N_IN, 0.0)
var nStep = array.new_int(1, 0)

nS   = array.size(smpY)
nTrn = int(math.floor(nS * trSplit))

if array.get(shuf, 0) and nTrn >= 8 and array.get(nStep, 0) < maxEp * nTrn
    float p = 0.0
    for i = 0 to nTrn - 1
        p += array.get(smpY, i)
    pw = p > 0 ? f_clamp((nTrn - p) / p, 1.0, 6.0) : 1.0
    for s = 0 to stepsBar - 1
        idx = f_ri(nTrn)
        for i = 0 to N_IN - 1
            array.set(sX, i, array.get(smpX, idx * N_IN + i))
        f_step(A1, Ab, A2, Ao, hA, dH, sX, array.get(smpY,  idx), pw)
        f_step(S1, Sb, S2, So, hA, dH, sX, array.get(smpYs, idx), pw)
        array.set(nStep, 0, array.get(nStep, 0) + 1)

// ═══════════════════════════ LIVE STATUS — counts only, every bar ══════════
ovr   = nS > 0 ? wins / float(nS) : 0.5
expR  = nS > 0 ? sumR / nS : na
avgW  = nW > 0 ? sumW / nW : na
avgL  = nL > 0 ? sumL / nL : na

nowDay  = year * 10000 + month * 100 + dayofmonth
isToday = not na(curDay) and curDay == nowDay
tdN     = isToday ? todN : 0
tdR     = isToday ? todR : 0.0

isAM   = hour + minute / 60.0 < splitHr
winN   = isAM ? amN : pmN
winW   = isAM ? amW : pmW
winWR  = winN > 0 ? winW / float(winN) : na
tiltWR = alN > 0 ? alW / float(alN) : na
tilted = prevLoss == 1

badWin   = winN >= minN and not na(winWR) and winWR < ovr - edgeMin
goodWin  = winN >= minN and not na(winWR) and winWR > ovr + edgeMin
badTilt  = tilted and alN >= minN and not na(tiltWR) and tiltWR < ovr - 0.12
dayBlown = tdN > 0 and tdR <= dayStopR

// 0 good · 1 neutral · 2 caution · 3 stop
risk = dayBlown ? 3 : nS < 20 ? 1 : (badWin and badTilt) ? 3 :
       (badWin or badTilt) ? 2 : goodWin ? 0 : 1

alertcondition(risk >= 2 and risk[1] < 2, "Entering a weak window",
     "COACH: your stats say step back right now")
alertcondition(dayBlown and not dayBlown[1], "Daily stop hit",
     "COACH: you've hit your daily stop. Close the platform.")
alertcondition(risk == 3, "STOP for today",
     "COACH: stop trading for today.")

// ════════════════════════════════════════════════════════════ render ══════
var array<label> marks  = array.new<label>()
var array<line>  tlines = array.new<line>()
var cMsg = array.new_string(0)
var cAct = array.new_string(0)
var cSev = array.new_float(0)

tPos = pPos == "top right"    ? position.top_right    :
       pPos == "bottom right" ? position.bottom_right :
       pPos == "middle right" ? position.middle_right :
       pPos == "middle left"  ? position.middle_left  :
       pPos == "bottom left"  ? position.bottom_left  : position.top_left

var table pnl = table.new(tPos, 1, 36, border_width = 0)

pBase = txtSz == "small" ? size.small : txtSz == "large" ? size.large : txtSz == "huge"  ? size.huge  : size.normal
pBig  = txtSz == "small" ? size.normal : txtSz == "large" ? size.huge : txtSz == "huge"  ? size.huge   : size.large
pSml  = txtSz == "small" ? size.tiny : txtSz == "large" ? size.normal : txtSz == "huge"  ? size.large : size.small

f_cell(r, t, col, sz, bg) =>
    table.cell(pnl, 0, r, t, text_color = col, bgcolor = bg,
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)

f_row(r, t, col) => f_cell(r, "  " + t + "  ", col, pBase, C_NONE)
f_alt(r, t, col) => f_cell(r, "  " + t + "  ", col, pBase, C_ALT)
f_sub(r, t, col) => f_cell(r, "  " + t + "  ", col, pSml, C_NONE)
f_hdr(r, t)      => f_cell(r, "  " + t + "  ", C_KEY, pSml, C_BAND)
f_gap(r)         => f_cell(r, "", C_LBL, size.tiny, C_NONE)

if barstate.islast
    if array.size(marks) > 0
        for i = 0 to array.size(marks) - 1
            label.delete(array.get(marks, i))
        array.clear(marks)
    if array.size(tlines) > 0
        for i = 0 to array.size(tlines) - 1
            line.delete(array.get(tlines, i))
        array.clear(tlines)

    // ── model check ────────────────────────────────────────────────────────
    float hitR  = na
    float hitS  = na
    float zEdge = na
    int   nTest = nS - nTrn
    if nTest >= 4 and array.get(shuf, 0)
        int okA = 0
        int okS = 0
        int tot = 0
        for i = nTrn to nS - 1
            for k = 0 to N_IN - 1
                array.set(sX, k, array.get(smpX, i * N_IN + k))
            ya = f_fwd(A1, Ab, A2, Ao, hA, sX)
            ys = f_fwd(S1, Sb, S2, So, hA, sX)
            y  = array.get(smpY, i)
            if not na(ya)
                okA += ((ya >= 0.5 ? 1.0 : 0.0) == y) ? 1 : 0
                okS += ((ys >= 0.5 ? 1.0 : 0.0) == y) ? 1 : 0
                tot += 1
        if tot > 0
            hitR  := okA / float(tot)
            hitS  := okS / float(tot)
            zEdge := (hitR - hitS) / math.sqrt(2.0 * 0.25 / tot)
    sig = not na(zEdge) and zEdge >= minZ and nTest >= minTest

    // ── findings ───────────────────────────────────────────────────────────
    array.clear(cMsg)
    array.clear(cAct)
    array.clear(cSev)

    // tags first: intent outranks timing because it's more fixable
    if array.size(tagNm) > 0
        for z = 0 to array.size(tagNm) - 1
            n = array.get(tagN, z)
            if n >= minTagN
                wr = array.get(tagW, z) / float(n)
                nm = array.get(tagNm, z)
                if wr < ovr - edgeMin
                    array.push(cMsg, nm + " trades win " + f_pct0(wr) +
                               " (n=" + str.tostring(n) + ")")
                    array.push(cAct, "stop taking " + nm + " entries")
                    array.push(cSev, (ovr - wr) * 4)
                else if wr > ovr + edgeMin
                    array.push(cMsg, nm + " trades win " + f_pct0(wr) +
                               " (n=" + str.tostring(n) + ")")
                    array.push(cAct, "take more " + nm + " setups, fewer of everything else")
                    array.push(cSev, (wr - ovr) * 2.5)

    if dayBlown
        array.push(cMsg, "you're down " + str.tostring(tdR, "0.0") + "R today")
        array.push(cAct, "close the platform — the day is over")
        array.push(cSev, 5.0)
    if amN >= minN and pmN >= minN
        d = (amW / float(amN)) - (pmW / float(pmN))
        if math.abs(d) >= edgeMin
            bad = d > 0 ? "afternoons" : "mornings"
            array.push(cMsg, "your " + bad + " lose " + f_pct0(math.abs(d)) + " more")
            array.push(cAct, d > 0 ? "stop trading after " + str.tostring(splitHr, "#.#") + ":00"
                                   : "don't start before " + str.tostring(splitHr, "#.#") + ":00")
            array.push(cSev, math.abs(d) * 2)
    if lgN >= minN and shN >= minN
        d = (lgW / float(lgN)) - (shW / float(shN))
        if math.abs(d) >= edgeMin
            array.push(cMsg, "your " + (d > 0 ? "shorts" : "longs") + " win " +
                       f_pct0(math.abs(d)) + " less")
            array.push(cAct, "take " + (d > 0 ? "longs" : "shorts") + " only for one week")
            array.push(cSev, math.abs(d) * 2)
    if alN >= minN and not na(tiltWR)
        d = ovr - tiltWR
        if d >= 0.12
            array.push(cMsg, "after a loss you win " + f_pct0(tiltWR))
            array.push(cAct, "one loss and you're done for the day")
            array.push(cSev, d * 3)
    if not na(avgW) and not na(avgL)
        if avgW < math.abs(avgL)
            array.push(cMsg, "your losers are bigger than your winners")
            array.push(cAct, "hard stop at " + str.tostring(avgW, "0.0") + "R")
            array.push(cSev, 0.55)
    if mxSt >= 5
        array.push(cMsg, str.tostring(mxSt) + " losses in a row has happened")
        array.push(cAct, "half size after 2 straight losses")
        array.push(cSev, 0.45)
    if array.size(tagNm) == 0 and nS >= 10
        array.push(cMsg, "no tags in your log")
        array.push(cAct, "add #plan / #fomo to each trade — biggest win available")
        array.push(cSev, 0.9)
    if nS < 40 and nS > 0
        array.push(cMsg, "only " + str.tostring(nS) + " trades logged")
        array.push(cAct, "log " + str.tostring(40 - nS) + " more for real patterns")
        array.push(cSev, 0.35)

    // ── draw trades ────────────────────────────────────────────────────────
    // Placed by TIME, not bar_index: bar_index drawings are capped by the
    // historical buffer and throw RE10045 on long journals.
    if nS > 0 and (showMk or showLn)
        lim = math.min(nS, maxDraw)
        for i = nS - lim to nS - 1
            ji = array.get(smpI, i)
            eb = array.get(jEBar, ji)
            xb = array.get(jXBar, ji)
            if eb >= 0
                et   = array.get(jTime, ji)
                xt   = array.get(jXTm, ji)
                en   = array.get(jEnt, ji)
                ex   = array.get(jExt, ji)
                sd   = array.get(jSide, ji)
                r    = array.get(smpR, i)
                cl   = r > 0 ? C_POS : C_NEG
                hasX = xb > eb and xt > et
                ts   = array.get(jTagS, ji)
                string tnm = ""
                if str.length(ts) > 0
                    tp = str.split(ts, ",")
                    for q = 0 to array.size(tp) - 1
                        ti = f_toInt(array.get(tp, q))
                        if not na(ti) and ti < array.size(tagNm)
                            tnm := tnm + " " + array.get(tagNm, ti)
                if showLn and hasX
                    array.push(tlines, line.new(et, en, xt, ex, xloc = xloc.bar_time,
                         color = color.new(cl, 25), width = 2))
                if showMk
                    array.push(marks, label.new(et, en, "", xloc = xloc.bar_time,
                         size = size.small,
                         style = sd > 0 ? label.style_triangleup : label.style_triangledown,
                         color = cl,
                         tooltip = (sd > 0 ? "LONG" : "SHORT") + " @ " +
                                   str.tostring(en, format.mintick) + tnm))
                if showR and hasX
                    array.push(marks, label.new(xt, ex, " " + str.tostring(r, "0.0") + "R",
                         xloc = xloc.bar_time, style = label.style_label_left,
                         color = C_NONE, textcolor = cl,
                         size = size.small, text_font_family = font.family_monospace))

    // ── panel ──────────────────────────────────────────────────────────────
    table.set_bgcolor(pnl, color.new(C_BG, 2))
    table.set_border_color(pnl, na)

    sTxt = dayBlown ? "STOP · DAY IS OVER" :
           nS < 20 ? "KEEP LOGGING" : risk == 3 ? "STOP · DONE TODAY" :
           risk == 2 ? "CAUTION" : risk == 0 ? "GOOD WINDOW" : "NEUTRAL"
    sBg  = dayBlown ? C_NEG : nS < 20 ? C_LBL : risk == 3 ? C_NEG :
           risk == 2 ? C_WARN : risk == 0 ? C_POS : C_BAND
    sFg  = (dayBlown or nS < 20 or risk != 1) ? C_INK : C_TXT

    clk = f_lpad(str.tostring(hour), 2) + ":" + f_lpad(str.tostring(minute), 2)
    why = dayBlown ? "daily stop hit — nothing good happens from here" :
          nS < 20 ? "need 20+ trades before I can judge" :
          risk == 3 ? "weak window and you're coming off a loss" :
          badTilt   ? "you're on tilt" :
          badWin    ? "this is a weak window for you" :
          risk == 0 ? "this is when you trade best" : "nothing for or against"

    recR = f_spark(smpR, 16)
    recN = math.min(nS, 10)
    int recW = 0
    if recN > 0
        for i = nS - recN to nS - 1
            recW += array.get(smpY, i) > 0.5 ? 1 : 0
    recCol = recN == 0 ? C_LBL : recW * 2 >= recN ? C_POS : C_NEG

    f_cell(0, "  " + syminfo.ticker + " · " + timeframe.period + " · " + clk + "  ",
           C_LBL, pSml, C_BAND)
    f_cell(1, "  " + sTxt + "  ", sFg, pBig, sBg)
    f_sub(2, why, C_LBL)
    f_gap(3)

    f_alt(4, f_stat(isAM ? "now: am" : "now: pm", winW, winN),
             badWin ? C_NEG : goodWin ? C_POS : C_TXT)
    f_row(5, f_pad("form", 10) + (recN > 0 ? f_form(smpY, 10) : "—"), recCol)
    f_alt(6, f_pad("equity", 10) + (str.length(recR) > 0 ? recR : "—"),
             f_fin(expR, 0.0) > 0 ? C_POS : C_NEG)
    f_row(7, f_pad("today", 10) + (tdN > 0 ?
             str.tostring(tdN) + " trades · " + str.tostring(tdR, "0.0") + "R" : "no trades"),
             tdN == 0 ? C_LBL : dayBlown ? C_NEG : tdR >= 0 ? C_POS : C_WARN)
    f_gap(8)

    f_hdr(9, "TOP FIX")
    if array.size(cMsg) > 0
        ordC = array.sort_indices(cSev, order.descending)
        k0 = array.get(ordC, 0)
        f_row(10, array.get(cMsg, k0), C_NUM)
        f_row(11, "→ " + array.get(cAct, k0), C_TXT)
    else
        f_row(10, "nothing alarming in your log", C_POS)
        f_gap(11)
    f_gap(12)

    f_sub(13, str.tostring(nS) + " trades · " + f_pct0(ovr) + " win · " +
              str.tostring(expR, "0.00") + "R avg",
              f_fin(expR, 0.0) > 0 ? C_POS : C_NEG)
    // one diagnostic line, most actionable failure first
    if nBad > 0
        f_sub(14, "⚠ " + str.tostring(nBad) + " lines unreadable (" + badLn + ")", C_NEG)
    else if nSkipEarly > 0
        f_sub(14, "⚠ " + str.tostring(nSkipEarly) + " trades too early on this chart", C_WARN)
    else if nS < nTr and nTr > 0
        f_sub(14, "⚠ " + str.tostring(nTr - nS) + " trades off-chart — check timezone", C_WARN)
    else
        f_gap(14)
    f_gap(15)

    // ── detail ─────────────────────────────────────────────────────────────
    if detail
        f_hdr(16, "ALL PATTERNS")
        f_alt(17, f_stat("morning",  amW, amN), amN >= minN ? C_TXT : C_LBL)
        f_row(18, f_stat("afternoon",pmW, pmN), pmN >= minN ? C_TXT : C_LBL)
        f_alt(19, f_stat("long",     lgW, lgN), lgN >= minN ? C_TXT : C_LBL)
        f_row(20, f_stat("short",    shW, shN), shN >= minN ? C_TXT : C_LBL)
        f_alt(21, f_stat("aftr loss",alW, alN), alN >= minN ? C_TXT : C_LBL)
        f_row(22, f_pad("avg w/l", 10) + str.tostring(avgW, "0.00") + " / " +
                  str.tostring(avgL, "0.00"),
                  f_fin(avgW, 0.0) > math.abs(f_fin(avgL, 0.0)) ? C_POS : C_NEG)
        f_alt(23, f_pad("worst run", 10) + str.tostring(mxSt) + " losses",
                  mxSt >= 5 ? C_NEG : C_TXT)

        f_hdr(24, "WHY YOU ENTERED")
        if array.size(tagNm) > 0
            tOrd = array.sort_indices(tagN, order.descending)
            for slot = 0 to 5
                if slot < array.size(tOrd)
                    z  = array.get(tOrd, slot)
                    n  = array.get(tagN, z)
                    wr = n > 0 ? array.get(tagW, z) / float(n) : na
                    cl = n < minTagN ? C_LBL : wr < ovr - edgeMin ? C_NEG :
                         wr > ovr + edgeMin ? C_POS : C_TXT
                    f_cell(25 + slot, "  " + f_stat(array.get(tagNm, z),
                           array.get(tagW, z), n) + "  ", cl, pBase,
                           slot % 2 == 0 ? C_ALT : C_NONE)
                else
                    f_gap(25 + slot)
        else
            f_row(25, "no tags yet — add #plan, #fomo, #revenge", C_LBL)
            for slot = 1 to 5
                f_gap(25 + slot)

        f_hdr(31, "MODEL")
        f_row(32, f_pad("verdict", 10) + (na(hitR) ? "need data" :
                  sig ? "edge +" + f_pct1(hitR - hitS) : "not significant"),
                  na(hitR) ? C_LBL : sig ? C_POS : C_NUM)
        f_alt(33, f_pad("vs control", 10) + (na(hitR) ? "—" :
                  f_pct0(hitR) + " vs " + f_pct0(hitS)), C_LBL)
        if array.size(cMsg) > 1
            f_hdr(34, "ALSO")
            ordC2 = array.sort_indices(cSev, order.descending)
            f_row(35, array.get(cMsg, array.get(ordC2, 1)), C_LBL)
        else
            f_gap(34)
            f_gap(35)
    else
        for r = 16 to 35
            f_gap(r)
````
