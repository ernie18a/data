# OMBREZ Liquidity Map

- url: https://www.tradingview.com/script/XOGBiPGp/
- type: indicator
- pine_id: PUB;b7661627378a412c88646691c2a75a04
- version: 1.0

## Description

OMBREZ Liquidity Map shows the few price levels where most stop orders are waiting right now - and tells you if the market only grabbed those stops or really broke out.

>>> IMPORTANT: PIN THE INDICATOR TO THE RIGHT PRICE SCALE <<<
If the lines or labels look shifted away from the candles, the indicator sits on the wrong scale. Fix it in 5 seconds:
Click the three dots (...) next to the indicator name on your chart -> "Pin to scale" -> "Pin to right scale".
The script already asks for the right scale, but some chart layouts override it. Do this once and you are set.

Quick Start (30 seconds)
1. Pin to the right price scale (see above).
2. Market preset: leave it on "Auto". It detects Gold, US100 (Nasdaq) and Bitcoin by itself. The dashboard header shows what it found, for example "OMBREZ - GOLD".
3. Best timeframes: 5m and 15m.
4. Verdicts only appear after a candle has closed. Nothing is repainted or removed later.
5. Not sure what something means? Hover your mouse over any label or dashboard row. It explains itself.

What It Shows
Places where many traders keep their stop orders:
- Equal highs and equal lows (several highs or lows at the same price)
- Session highs and lows (Asia, London, New York)
- Previous day high and low

Every level gets 1 to 3 stars. More stars = more important = thicker line.
You only see the strongest 3 levels above and below price. Used levels disappear on their own.
Two levels on the same spot? You get one clean label, for example "Prev. Day Low + Equal Lows", plus one extra star.

Why It Matters
Price loves to run these spots. It spikes through a level, takes out the stops sitting there, and very often turns around right after. Most tools only draw the zones. This one also tells you what happened.

The Verdict
When price pushes through a level, the map waits for a few closed candles and then decides:
- "Stops grabbed" (green check) - price spiked through and came straight back. Often the start of a move the other way.
- "Breakout" (cross) - price stayed on the other side. A real breakout, not a trap. Hidden on the chart by default to keep it clean - the alert still fires.
Every stop grab is marked exactly: a small diamond at the wick, a dotted line to the label and a short dash on the level that got swept.

Example (US100)
Price drops 20 points below yesterday's low early in the session, then climbs back above it within 3 candles. The map prints "Stops grabbed - Prev. Day Low" with a diamond on the wick. Spots like this are often where the move of the day starts.

The Dashboard
Compact (default):
- Detected market, current session, price above or below today's open
- Next key level above and below (2 stars and up, same names as on the chart)
- Honest hit rate with a colored bar
Detailed (Settings -> Look and feel -> Dashboard style):
- Your last 10 signals at a glance
- Highs vs. lows
- Which level types work best on THIS chart

Honest Hit Rate - How We Count
- Reversed = price moved 1.5 x ATR away from the level BEFORE it broke the wick of the stop grab.
- Not reversed = price broke the wick first, or nothing happened within 40 candles.
- If both happen in the same candle, it counts as not reversed.
- Every signal counts. Closed candles only. No cherry-picking.
- Below 20 signals the dashboard says "small sample". Small samples can swing a lot.
The number changes with market, timeframe and conditions. Use it to judge for yourself, not as a promise.

Settings in Plain Words
1) Your market - Auto, or pick US100 / GOLD / BTC yourself (or Custom for other markets)
2) What to show - level types, how many per side, used levels on or off
3) Sensitivity - Fine (scalping), Normal, Coarse (swing trading)
4) Look and feel - theme (auto dark/light), text size, line thickness, dashboard style and position, label language (English / German)
5) Honest hit rate - how many signals to count and what counts as "reversed"
6) Session times - only needed with the Custom preset

Alerts
- OMBREZ - Stops grabbed
- OMBREZ - Real breakout

Good to Know
- A stop grab is context, not a buy or sell button. Combine it with your own plan and risk management.
- Bitcoin trades 24/7, so session levels are switched off automatically on BTC.
- Works great together with OMBREZ Zones and OMBREZ Trend.

Disclaimer
This indicator is a tool for technical analysis and education only. It is not financial advice and not a recommendation to buy or sell anything. Trading involves a high risk of loss. Past price behavior does not guarantee future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © OMBREZ · Liquidity Map v2.0
//@version=6
indicator("OMBREZ Liquidity Map", "OMBREZ · LMap", overlay = true, scale = scale.right, max_lines_count = 500, max_labels_count = 500)

grpA = "① Your market"
preset = input.string("Auto", "Market preset", options = ["Auto", "US100", "GOLD", "BTC", "Custom"], group = grpA, tooltip = "Auto detects Gold, US100 and BTC from your chart and sets sensitivity and session times for you. 'Custom' uses the session times below.")

grpB = "② What to show"
showEQ = input.bool(true, "Equal highs & lows (stop clusters)", group = grpB, tooltip = "Several highs at the same price = lots of stop orders above. Same for lows. The market loves to run these spots.")
showSess = input.bool(true, "Session highs & lows (Asia · London · New York)", group = grpB, tooltip = "The highest and lowest point of each trading session. Auto-off for BTC (trades 24/7).")
showPD = input.bool(true, "Previous day high & low", group = grpB, tooltip = "The two most watched levels of all – almost every trader looks at them.")
maxSide = input.int(3, "Max levels per side (above/below price)", minval = 1, maxval = 5, group = grpB, tooltip = "Less is more: we only show the strongest levels.")
showUsed = input.bool(false, "Show used levels (faded)", group = grpB, tooltip = "Off = a level disappears from the list as soon as it has done its job. The diamonds and labels on the chart still show what happened.")

grpC = "③ Sensitivity"
sensIn = input.string("Normal", "Sensitivity", options = ["Fine", "Normal", "Coarse"], group = grpC, tooltip = "Fine = more, smaller levels (scalping). Coarse = only the big marks (swing). When in doubt: Normal.")
confirmN = input.int(3, "Candles until verdict (stops grabbed / breakout)", minval = 2, maxval = 5, group = grpC, tooltip = "After a level gets pierced we wait this many CLOSED candles before judging. More candles = safer, but later.")

grpD = "④ Look & feel"
themeIn = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpD, tooltip = "Auto detects your chart background and adjusts label colors. Or force Dark / Light.")
langIn = input.string("English", "Label language", options = ["English", "Deutsch"], group = grpD)
sizeIn = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = grpD, tooltip = "Size of level labels and the dashboard. Verdict labels are always one step smaller, so they never cover the price.")
thickIn = input.string("Auto (by stars)", "Line thickness", options = ["Auto (by stars)", "Thin", "Medium", "Thick"], group = grpD, tooltip = "Auto: important levels (★★★) are drawn thicker than small ones (★). Or set one thickness for all.")
verdictMode = input.string("Only stops grabbed ✓", "Show verdicts on chart", options = ["All", "Only stops grabbed ✓", "None"], group = grpD, tooltip = "'Stops grabbed' is the signal that matters. Breakout labels are mostly noise – alerts still fire for both.")
showMarks = input.bool(true, "Mark the exact spot (◆ + line)", group = grpD, tooltip = "A diamond at the wick where the stops were taken, a dotted line to the label, and a short dash on the level that got swept.")
onlyStrong = input.bool(true, "Verdicts only for important levels (★★ and up)", group = grpD, tooltip = "Small levels (★) get no verdict label – less clutter.")
maxVerdicts = input.int(8, "Max verdict labels on chart", minval = 2, maxval = 30, group = grpD, tooltip = "Oldest verdicts disappear automatically – your chart stays clean.")
colUp = input.color(#E8A33D, "Levels above price", group = grpD)
colDn = input.color(#E8A33D, "Levels below price", group = grpD)
showDash = input.bool(true, "Dashboard", group = grpD)
dashMode = input.string("Compact", "Dashboard style", options = ["Compact", "Detailed"], group = grpD, tooltip = "Compact: market, next key levels and hit rate. Detailed: also shows your last 10 signals, highs vs lows, and which level types work best on THIS chart.")
dashPosIn = input.string("Bottom right", "Dashboard position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpD)
fadeBars = input.int(30, "Forget used levels after … candles", minval = 5, maxval = 200, group = grpD, tooltip = "How long a used level is kept in memory (and shown faded, if 'Show used levels' is on).")

grpF = "⑤ Honest hit rate"
showStats = input.bool(true, "Show hit rate in dashboard", group = grpF, tooltip = "We count how often a 'Stops grabbed' really turned into a move. No cherry-picking: every signal counts, measured on closed candles only.")
statN = input.int(20, "Count the last … stop grabs", minval = 5, maxval = 100, group = grpF)
statMove = input.float(1.5, "Counts as 'reversed' after a move of … × ATR", minval = 0.5, maxval = 5.0, step = 0.5, group = grpF, tooltip = "Reversed = price moves this far away from the level BEFORE it breaks the sweep wick. If it breaks the wick first, or nothing happens within 40 candles, it counts as not reversed.")

grpE = "⑥ Session times (UTC) – only used with 'Custom'"
sessAsia = input.session("0000-0800", "Asia", group = grpE)
sessLdn = input.session("0700-1200", "London", group = grpE)
sessNY = input.session("1330-2000", "New York", group = grpE)

string tk = str.upper(syminfo.ticker)
string mkt = preset != "Auto" ? preset : str.contains(tk, "XAU") or str.contains(tk, "GOLD") ? "GOLD" : str.contains(tk, "BTC") or str.contains(tk, "XBT") ? "BTC" : "US100"

float bgBright = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3
bool darkMode = themeIn == "Dark" ? true : themeIn == "Light" ? false : bgBright < 128
color thBg = darkMode ? #131722 : #FFFFFF
color thTxt = darkMode ? #D1D4DC : #2A2E39
color thMut = darkMode ? #787B86 : #9598A1
color thVerT = #1E222D
color cGood = #26A69A
color cBad = #EF5350

txtSize = sizeIn == "Small" ? size.small : sizeIn == "Large" ? size.large : size.normal
vSize = sizeIn == "Small" ? size.tiny : sizeIn == "Large" ? size.normal : size.small
dashPos = dashPosIn == "Top right" ? position.top_right : dashPosIn == "Top left" ? position.top_left : dashPosIn == "Bottom left" ? position.bottom_left : position.bottom_right

float tolMult = mkt == "GOLD" ? 1.2 : mkt == "BTC" ? 1.5 : 1.0
int pivLen = mkt == "BTC" ? 12 : 10
bool sessOn = showSess and mkt != "BTC"
tolMult := sensIn == "Fine" ? tolMult * 0.7 : sensIn == "Coarse" ? tolMult * 1.5 : tolMult
pivLen := sensIn == "Fine" ? math.max(5, pivLen - 4) : sensIn == "Coarse" ? pivLen + 5 : pivLen

bool de = langIn == "Deutsch"
f_txt(string d, string e) => de ? d : e

float atr = ta.atr(14)
float tol = atr * 0.25 * tolMult
float pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
float pdl = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)
float dOpen = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)

inAsia = not na(time(timeframe.period, sessAsia + ":1234567", "UTC"))
inLdn = not na(time(timeframe.period, sessLdn + ":1234567", "UTC"))
inNY = not na(time(timeframe.period, sessNY + ":1234567", "UTC"))

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)

type Pool
    float price
    string kind
    bool upper
    int born
    int touches
    int breachCloses
    int breachBar
    bool done
    int doneBar
    int verdict

type Track
    bool up
    float wick
    float target
    int start
    string kind
    bool hi

var array<Pool> pools = array.new<Pool>()
var array<Track> tracks = array.new<Track>()
var array<int> res = array.new<int>()
var array<string> resK = array.new<string>()
var array<bool> resH = array.new<bool>()

f_base(string k) => k == "PDH" or k == "PDL" ? 5.0 : k == "EQH" or k == "EQL" ? 2.0 : 3.5

f_score(Pool p) =>
    float s = f_base(p.kind) + p.touches * 1.2
    s - (bar_index - p.born) / 600.0

f_stars(float s) => s >= 5.5 ? "★★★" : s >= 3.5 ? "★★" : "★"

f_width(float s) =>
    thickIn == "Thin" ? 1 : thickIn == "Medium" ? 2 : thickIn == "Thick" ? 3 : s >= 5.5 ? 3 : s >= 3.5 ? 2 : 1

f_name(string k) =>
    k == "EQH" ? f_txt("Gleiche Hochs", "Equal Highs") : k == "EQL" ? f_txt("Gleiche Tiefs", "Equal Lows") : k == "AsiaH" ? f_txt("Asien-Hoch", "Asia High") : k == "AsiaL" ? f_txt("Asien-Tief", "Asia Low") : k == "LdnH" ? f_txt("London-Hoch", "London High") : k == "LdnL" ? f_txt("London-Tief", "London Low") : k == "NYH" ? f_txt("NY-Hoch", "NY High") : k == "NYL" ? f_txt("NY-Tief", "NY Low") : k == "PDH" ? f_txt("Vortageshoch", "Prev. Day High") : f_txt("Vortagestief", "Prev. Day Low")

f_cat(string k) => k == "PDH" or k == "PDL" ? "PD" : k == "EQH" or k == "EQL" ? "EQ" : "SE"

f_explain(string k) =>
    string c = f_cat(k)
    c == "PD" ? f_txt("Vortageshoch/-tief – das meistbeachtete Level des Tages. Direkt dahinter liegen viele Stops.", "Yesterday's high/low – the most watched level of the day. Lots of stop orders sit just beyond it.") : c == "EQ" ? f_txt("Mehrere Hochs/Tiefs auf gleicher Höhe – direkt dahinter sammeln sich Stop-Orders.", "Several highs/lows at the same price – stop orders cluster just beyond it.") : f_txt("Hoch/Tief einer Handelssession – direkt dahinter liegen Stops.", "The high/low of a trading session – stop orders sit just beyond it.")

f_upsert(float price, string kind, bool upper) =>
    bool found = false
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            Pool p = array.get(pools, i)
            if not p.done and p.kind == kind and math.abs(p.price - price) <= tol
                p.price := (p.price * p.touches + price) / (p.touches + 1)
                p.touches += 1
                found := true
                break
    if not found
        array.push(pools, Pool.new(price, kind, upper, bar_index, 1, 0, 0, false, 0, 0))

f_setSess(float price, string kind, bool upper) =>
    if array.size(pools) > 0
        for i = array.size(pools) - 1 to 0
            Pool p = array.get(pools, i)
            if p.kind == kind and not p.done
                array.remove(pools, i)
    array.push(pools, Pool.new(price, kind, upper, bar_index, 1, 0, 0, false, 0, 0))

f_pushRes(int r, string k, bool h) =>
    array.push(res, r)
    array.push(resK, k)
    array.push(resH, h)
    while array.size(res) > statN
        array.shift(res)
        array.shift(resK)
        array.shift(resH)

var float aH = na
var float aL = na
var float lH = na
var float lL = na
var float nH = na
var float nL = na

if barstate.isconfirmed
    if showEQ and not na(ph)
        f_upsert(ph, "EQH", true)
    if showEQ and not na(pl)
        f_upsert(pl, "EQL", false)
    if sessOn
        aH := inAsia ? (na(aH) or not inAsia[1] ? high : math.max(aH, high)) : aH
        aL := inAsia ? (na(aL) or not inAsia[1] ? low : math.min(aL, low)) : aL
        lH := inLdn ? (na(lH) or not inLdn[1] ? high : math.max(lH, high)) : lH
        lL := inLdn ? (na(lL) or not inLdn[1] ? low : math.min(lL, low)) : lL
        nH := inNY ? (na(nH) or not inNY[1] ? high : math.max(nH, high)) : nH
        nL := inNY ? (na(nL) or not inNY[1] ? low : math.min(nL, low)) : nL
        if inAsia[1] and not inAsia and not na(aH)
            f_setSess(aH, "AsiaH", true)
            f_setSess(aL, "AsiaL", false)
        if inLdn[1] and not inLdn and not na(lH)
            f_setSess(lH, "LdnH", true)
            f_setSess(lL, "LdnL", false)
        if inNY[1] and not inNY and not na(nH)
            f_setSess(nH, "NYH", true)
            f_setSess(nL, "NYL", false)
    if showPD and pdh != pdh[1]
        f_setSess(pdh, "PDH", true)
        f_setSess(pdl, "PDL", false)

if barstate.isconfirmed and array.size(tracks) > 0
    for i = array.size(tracks) - 1 to 0
        Track t = array.get(tracks, i)
        if bar_index > t.start
            bool win = t.up ? high >= t.target : low <= t.target
            bool lose = t.up ? low < t.wick : high > t.wick
            if lose
                f_pushRes(0, t.kind, t.hi)
                array.remove(tracks, i)
            else if win
                f_pushRes(1, t.kind, t.hi)
                array.remove(tracks, i)
            else if bar_index - t.start > 40
                f_pushRes(0, t.kind, t.hi)
                array.remove(tracks, i)

bool alertReject = false
bool alertAccept = false

var array<label> vLab = array.new<label>()
var array<label> vDia = array.new<label>()
var array<line> vCon = array.new<line>()
var array<line> vDash = array.new<line>()

f_mark(int b, float wickY, float labY, float lvl, bool up, string txt, color bg, color tc, string tip) =>
    label lb = label.new(b, labY, txt, style = up ? label.style_label_down : label.style_label_up, color = bg, textcolor = tc, size = vSize, tooltip = tip)
    array.push(vLab, lb)
    if showMarks
        array.push(vDia, label.new(b, wickY, "", style = label.style_diamond, size = size.tiny, color = bg, tooltip = tip))
        array.push(vCon, line.new(b, wickY, b, labY, color = color.new(bg, 20), style = line.style_dotted, width = 1))
        array.push(vDash, line.new(math.max(0, b - 6), lvl, b + 2, lvl, color = color.new(bg, 10), width = 2))
    while array.size(vLab) > maxVerdicts
        label.delete(array.shift(vLab))
        if array.size(vDia) > 0
            label.delete(array.shift(vDia))
        if array.size(vCon) > 0
            line.delete(array.shift(vCon))
        if array.size(vDash) > 0
            line.delete(array.shift(vDash))

if barstate.isconfirmed and array.size(pools) > 0
    for i = 0 to array.size(pools) - 1
        Pool p = array.get(pools, i)
        if not p.done
            bool pierced = p.upper ? high > p.price : low < p.price
            bool closedBeyond = p.upper ? close > p.price : close < p.price
            if p.breachBar == 0
                if pierced
                    p.breachBar := bar_index
                    p.breachCloses := closedBeyond ? 1 : 0
            else
                p.breachCloses := closedBeyond ? p.breachCloses + 1 : p.breachCloses
                bool windowOver = bar_index - p.breachBar >= confirmN
                bool labOK = not onlyStrong or f_score(p) >= 3.5
                int back = bar_index - p.breachBar
                float ext = p.upper ? high : low
                for k = 0 to back
                    ext := p.upper ? math.max(ext, high[k]) : math.min(ext, low[k])
                string nmV = f_name(p.kind)
                if p.breachCloses >= 2
                    p.done := true
                    p.doneBar := bar_index
                    p.verdict := 2
                    if verdictMode == "All" and labOK
                        string tipA = f_txt("Der Preis hat " + nmV + " durchstochen und schließt weiter dahinter. Ein echter Ausbruch – kein Stop-Grab.", "Price pierced " + nmV + " and keeps closing beyond it. A real breakout – not a stop grab.")
                        f_mark(bar_index, p.upper ? high : low, p.upper ? ext + atr * 1.0 : ext - atr * 1.0, p.price, p.upper, f_txt("Ausbruch ✗", "Breakout ✗") + "  " + nmV, color.new(thMut, 40), thTxt, tipA)
                    alertAccept := true
                else if windowOver and not closedBeyond
                    p.done := true
                    p.doneBar := bar_index
                    p.verdict := 1
                    if labOK
                        array.push(tracks, Track.new(not p.upper, ext, p.upper ? p.price - atr * statMove : p.price + atr * statMove, bar_index, p.kind, p.upper))
                        if verdictMode != "None"
                            string tipR = f_txt("Der Preis hat " + nmV + " durchstochen, die Stops abgeholt und ist innerhalb von " + str.tostring(confirmN) + " Kerzen zurückgekommen. Oft startet hier eine Bewegung in die Gegenrichtung – nicht immer. Schau auf die Trefferquote im Dashboard.", "Price pierced " + nmV + ", took the stops and came back within " + str.tostring(confirmN) + " candles. A move the other way often starts here – not always. Check the hit rate in the dashboard.")
                            f_mark(p.breachBar, p.upper ? high[back] : low[back], p.upper ? ext + atr * 1.0 : ext - atr * 1.0, p.price, p.upper, f_txt("Stops abgeholt ✓", "Stops grabbed ✓") + "  " + nmV, colUp, thVerT, tipR)
                    alertReject := true
    for i = array.size(pools) - 1 to 0
        Pool p = array.get(pools, i)
        if (p.done and bar_index - p.doneBar > fadeBars) or bar_index - p.born > 1500
            array.remove(pools, i)
    while array.size(pools) > 40
        int worst = 0
        float ws = 1e9
        for i = 0 to array.size(pools) - 1
            float s = f_score(array.get(pools, i))
            if s < ws
                ws := s
                worst := i
        array.remove(pools, worst)

var array<line> lns = array.new<line>()
var array<label> lbs = array.new<label>()

f_clear() =>
    while array.size(lns) > 0
        line.delete(array.pop(lns))
    while array.size(lbs) > 0
        label.delete(array.pop(lbs))

f_draw(Pool p, string nm, float sc) =>
    int faded = p.done ? math.min(85, 40 + (bar_index - p.doneBar) * 45 / fadeBars) : 0
    color cBase = p.price > close ? colUp : colDn
    color cl = color.new(cBase, p.done ? faded : 25)
    line l = line.new(p.born, p.price, bar_index + 4, p.price, color = cl, width = p.done ? 1 : f_width(sc), style = p.done ? line.style_dotted : line.style_solid)
    array.push(lns, l)
    string tag = nm + " · " + f_stars(sc) + (p.done ? (p.verdict == 1 ? "  ✓" : "  ✗") : "")
    string tip = nm + " · " + f_stars(sc) + "\n" + f_explain(p.kind) + "\n" + f_txt("Mehr Sterne = wichtiger. Zwei Level übereinander = doppelte Stops.", "More stars = more important. Two levels on top of each other = double the stops.")
    label lb = label.new(bar_index + 4, p.price, tag, style = label.style_label_left, size = txtSize, color = color.new(thBg, 15), textcolor = color.new(cBase, p.done ? faded : 0), tooltip = tip)
    array.push(lbs, lb)

var float kUpP = na
var float kDnP = na
var string kUpN = "–"
var string kDnN = "–"
var float aUpP = na
var float aDnP = na
var string aUpN = "–"
var string aDnN = "–"

if barstate.isconfirmed or barstate.islast
    f_clear()
    kUpP := na
    kDnP := na
    aUpP := na
    aDnP := na
    kUpN := "–"
    kDnN := "–"
    aUpN := "–"
    aDnN := "–"
    int nUp = 0
    int nDn = 0
    float gap = atr * 0.35
    var array<int> used = array.new<int>()
    array.clear(used)
    for step = 1 to maxSide * 2
        int best = -1
        float bs = -1e9
        if array.size(pools) > 0
            for i = 0 to array.size(pools) - 1
                if not array.includes(used, i)
                    Pool p = array.get(pools, i)
                    if showUsed or not p.done
                        bool up = p.price > close
                        if not ((up and nUp >= maxSide) or (not up and nDn >= maxSide))
                            float s = f_score(p)
                            if s > bs
                                bs := s
                                best := i
        if best >= 0
            array.push(used, best)
            Pool p = array.get(pools, best)
            string nm = f_name(p.kind)
            string second = ""
            int more = 0
            float bonus = 0.0
            for j = 0 to array.size(pools) - 1
                if not array.includes(used, j)
                    Pool q = array.get(pools, j)
                    if (showUsed or not q.done) and q.done == p.done and math.abs(q.price - p.price) <= gap
                        array.push(used, j)
                        bonus += 1.0
                        string qn = f_name(q.kind)
                        if qn != nm and qn != second
                            if second == ""
                                second := qn
                            else
                                more += 1
            string full = nm + (second != "" ? " + " + second : "") + (more > 0 ? " (+" + str.tostring(more) + ")" : "")
            float sc = f_score(p) + bonus
            f_draw(p, full, sc)
            if not p.done
                bool isUp = p.price > close
                if isUp and (na(aUpP) or p.price < aUpP)
                    aUpP := p.price
                    aUpN := full
                if not isUp and (na(aDnP) or p.price > aDnP)
                    aDnP := p.price
                    aDnN := full
                if sc >= 3.5
                    if isUp and (na(kUpP) or p.price < kUpP)
                        kUpP := p.price
                        kUpN := full
                    if not isUp and (na(kDnP) or p.price > kDnP)
                        kDnP := p.price
                        kDnN := full
            if p.price > close
                nUp += 1
            else
                nDn += 1

// ═════════════ DASHBOARD ═════════════
var table dash = table.new(dashPos, 2, 9, bgcolor = color.new(#131722, 8), frame_width = 1, frame_color = color.new(#E8A33D, 50), border_width = 0)

f_row(int r, string a, string b, color cb, string tip) =>
    table.cell(dash, 0, r, a, text_color = thMut, text_size = txtSize, text_halign = text.align_left, tooltip = tip)
    table.cell(dash, 1, r, b, text_color = cb, text_size = txtSize, text_halign = text.align_left, tooltip = tip)

f_bar(float pct) =>
    int f = math.round(pct / 10)
    string s = ""
    for i = 1 to 10
        s += i <= f ? "█" : "░"
    s

f_frac(int w, int n) => n == 0 ? "–" : str.tostring(w) + "/" + str.tostring(n)

if showDash and barstate.islast
    table.set_bgcolor(dash, color.new(thBg, 8))
    table.set_frame_color(dash, color.new(colUp, 50))
    color hdBg = color.new(colUp, 82)
    string sNow = inNY ? "New York" : inLdn ? "London" : inAsia ? f_txt("Asien", "Asia") : f_txt("Zwischen Sessions", "Between sessions")
    sNow := mkt == "BTC" ? "24/7" : sNow
    string bias = close > dOpen ? f_txt("▲ über Tageseröffnung", "▲ above day open") : f_txt("▼ unter Tageseröffnung", "▼ below day open")
    string hdTip = f_txt("Erkannter Markt, aktuelle Handelszeit und ob der Preis über oder unter der heutigen Eröffnung steht.", "Detected market, current trading session, and whether price is above or below today's open.")
    table.cell(dash, 0, 0, "OMBREZ · " + mkt, text_color = colUp, bgcolor = hdBg, text_size = txtSize, text_halign = text.align_left, tooltip = hdTip)
    table.cell(dash, 1, 0, sNow + "  ·  " + bias, text_color = thTxt, bgcolor = hdBg, text_size = txtSize, text_halign = text.align_left, tooltip = hdTip)
    float upP = na(kUpP) ? aUpP : kUpP
    float dnP = na(kDnP) ? aDnP : kDnP
    string upN = na(kUpP) ? aUpN : kUpN
    string dnN = na(kDnP) ? aDnN : kDnN
    string lvTip = f_txt("Das nächste wichtige Level (★★ oder mehr) – mit demselben Namen wie am Chart.", "The nearest important level (★★ or more) – same name as on the chart.")
    f_row(1, f_txt("↑ Nächstes Key-Level", "↑ Next key level"), na(upP) ? f_txt("keins – Preis auf neuen Hochs", "none – price at new highs") : upN + "  " + str.tostring(upP, format.mintick), colUp, lvTip)
    f_row(2, f_txt("↓ Nächstes Key-Level", "↓ Next key level"), na(dnP) ? f_txt("keins – Preis auf neuen Tiefs", "none – price at new lows") : dnN + "  " + str.tostring(dnP, format.mintick), colDn, lvTip)
    if showStats
        int nRes = array.size(res)
        int nWin = 0
        int hW = 0
        int hN = 0
        int lW = 0
        int lN = 0
        int pW = 0
        int pN = 0
        int sW = 0
        int sN = 0
        int eW = 0
        int eN = 0
        if nRes > 0
            for i = 0 to nRes - 1
                int r = array.get(res, i)
                string c = f_cat(array.get(resK, i))
                nWin += r
                if array.get(resH, i)
                    hN += 1
                    hW += r
                else
                    lN += 1
                    lW += r
                if c == "PD"
                    pN += 1
                    pW += r
                else if c == "EQ"
                    eN += 1
                    eW += r
                else
                    sN += 1
                    sW += r
        string hrTip = f_txt("Wie oft ein 'Stops abgeholt' wirklich gedreht hat: Der Preis lief " + str.tostring(statMove) + "× ATR vom Level weg, BEVOR er den Docht gebrochen hat. Jedes Signal zählt, nur fertige Kerzen.", "How often a 'Stops grabbed' really reversed: price moved " + str.tostring(statMove) + "× ATR away from the level BEFORE breaking the wick. Every signal counts, closed candles only.")
        if nRes < 5
            f_row(3, f_txt("Trefferquote", "Hit rate"), f_txt("sammle Daten … ", "collecting data … ") + str.tostring(nRes) + "/5", thMut, hrTip)
        else
            float pct = 100.0 * nWin / nRes
            color pc = pct >= 60 ? cGood : pct >= 45 ? colUp : cBad
            string small = nRes < 20 ? f_txt("  (kleine Stichprobe)", "  (small sample)") : ""
            f_row(3, f_txt("Trefferquote", "Hit rate"), f_bar(pct) + "  " + str.tostring(math.round(pct)) + "% · " + str.tostring(nWin) + "/" + str.tostring(nRes) + small, pc, hrTip)
        if dashMode == "Detailed" and nRes > 0
            string dots = ""
            int st = math.max(0, nRes - 10)
            for i = st to nRes - 1
                dots += (array.get(res, i) == 1 ? "●" : "○") + " "
            f_row(4, f_txt("Letzte 10 (neueste →)", "Last 10 (newest →)"), dots, thTxt, f_txt("● = gedreht   ○ = nicht gedreht", "● = reversed   ○ = not reversed"))
            f_row(5, f_txt("Hochs · Tiefs", "Highs · Lows"), f_frac(hW, hN) + "  ·  " + f_frac(lW, lN), thTxt, f_txt("Stop-Grabs über Hochs vs. unter Tiefs.", "Stop grabs above highs vs. below lows."))
            string byType = f_txt("Vortag ", "Prev. Day ") + f_frac(pW, pN) + (mkt == "BTC" ? "" : "  ·  Session " + f_frac(sW, sN)) + "  ·  " + f_txt("Gleiche ", "Equal ") + f_frac(eW, eN)
            f_row(6, f_txt("Nach Level-Art", "By level type"), byType, thTxt, f_txt("Welche Level-Arten auf DIESEM Chart am besten funktionieren.", "Which level types work best on THIS chart."))
            f_row(7, f_txt("Regel", "Rule"), f_txt("gedreht = " + str.tostring(statMove) + "× ATR bevor der Docht bricht", "reversed = " + str.tostring(statMove) + "× ATR before wick breaks"), thMut, hrTip)

plot(na, "·", display = display.none)

alertcondition(alertReject, "OMBREZ · Stops grabbed", "{{ticker}}: Stops grabbed – check the level.")
alertcondition(alertAccept, "OMBREZ · Real breakout", "{{ticker}}: Price is holding beyond the level.")
````
