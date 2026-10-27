# MTF FVG / iFVG + Volume Profile LVN

- url: https://www.tradingview.com/script/YVwmeIND/
- type: indicator
- pine_id: PUB;cf2d836faa5e4566ac252a1cb12d8395
- version: 2.0

## Description

MTF FVG / iFVG + Volume Profile LVN

OVERVIEW
This indicator detects Fair Value Gaps (FVGs) on up to five higher timeframes and filters them with a composite volume profile built from the chart's own candles. The idea is simple: a gap that forms over a Low Volume Node (LVN) is an area the market moved through quickly with little participation, so it is more likely to act as an inefficiency worth watching. Gaps that form over high-volume areas are filtered out by default, which removes a lot of noise compared to a plain FVG indicator.

HOW IT WORKS

1) Composite volume profile
- The profile is built from the chart candles, covering today plus a configurable number of previous sessions.
- Each candle's volume is spread evenly across the price rows it traded through.
- Row size is automatic (daily ATR / 40, fixed at the start of the chart history) or can be set manually in points.
- The oldest session is removed as new sessions are added, so the profile always covers a rolling window.

2) Multi-timeframe FVG detection
- FVGs are detected on up to 5 timeframes (default: 15m, 1H, 4H, Daily, with 30m optional).
- Only closed candles of each timeframe are used, so zones do not repaint.
- A minimum gap size, measured in ATR of the gap's own timeframe, removes tiny gaps.
- Timeframes lower than the chart timeframe are ignored.

3) LVN confirmation (relative volume)
- Each gap gets a relative volume score: the average volume per row inside the gap divided by the average volume per row of the whole profile.
- The edge rows are excluded when the gap is large enough, because they belong to the candles that form the gap, not to the gap itself.
- If the score is at or below the LVN threshold (default 0.6), the gap is considered LVN-confirmed.
- A score of 1.0 means the gap traded the same volume as an average row. A score of 0.6 means it traded 40% less.
- Gaps outside the profile's price range are labeled "no VP". Increase the number of sessions to cover older 4H/Daily gaps.

4) Inversion (iFVG)
- An FVG becomes an iFVG when a candle of its own timeframe closes beyond it:
  - A bullish FVG closed below becomes resistance (orange).
  - A bearish FVG closed above becomes support (blue).
- An iFVG is removed when a candle of its timeframe closes back through it.
- By default, iFVGs are only created from LVN-confirmed FVGs. This can be changed to all FVGs.

WHAT YOU SEE ON THE CHART
- FVG and iFVG zones with their timeframe and relative volume score (e.g. "FVG 1H · LVN 0.42").
- Optional CE (50%) line inside each zone.
- The composite volume profile drawn to the right of price, with the POC and LVN rows highlighted.

HOW TO USE IT
- Use a 1m to 5m chart so the profile has enough resolution. Higher timeframe charts produce a coarse profile.
- Treat LVN-confirmed higher timeframe FVGs as areas of interest, not as standalone entry signals. Combine them with your own market structure, session and risk management rules.
- iFVGs can be used as potential support/resistance after the original gap has failed.
- Adjust the LVN threshold to be stricter (lower value) or looser (higher value).

ALERTS
- Bullish FVG on LVN
- Bearish FVG on LVN
- iFVG support
- iFVG resistance
- Any FVG / iFVG event

LIMITATIONS
- The volume profile is an approximation built from OHLCV candles, not tick or bid/ask data. Volume is distributed evenly across each candle's range.
- The profile depends on the chart history loaded and on the volume data provided by the symbol's exchange.
- The indicator does not generate buy or sell signals and does not guarantee any trading result.

This script is for educational purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator("MTF FVG / iFVG + Volume Profile LVN", shorttitle = "FVG·LVN", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

// How it works
//  1) A composite volume profile is built from the chart candles (today + previous sessions).
//     Each candle's volume is spread evenly across the rows it traded through.
//  2) FVGs are detected on up to 5 higher timeframes (only closed candles, no repainting).
//  3) Each FVG gets a "relative volume" = average volume per row inside the gap / average volume per row of the profile.
//     rel <= LVN threshold  ->  the gap sits on a low volume node  ->  confirmed FVG.
//  4) An FVG becomes an iFVG when a candle of ITS OWN timeframe closes beyond it. The iFVG dies when a candle closes back through it.
//  5) With "Show only LVN-confirmed FVGs" on, unconfirmed gaps are not stored at all,
//     so "Max zones kept per timeframe" counts only the zones you actually see.
//  Tip: use a 1m-5m chart so the profile has enough resolution.

//---------------------------------------------------------------------------------------------------------------------
// Inputs
//---------------------------------------------------------------------------------------------------------------------
grpT = "FVG timeframes"
en1 = input.bool(true,  "", inline = "1", group = grpT)
tf1 = input.timeframe("15",  "", inline = "1", group = grpT)
en2 = input.bool(false, "", inline = "2", group = grpT)
tf2 = input.timeframe("30",  "", inline = "2", group = grpT)
en3 = input.bool(true,  "", inline = "3", group = grpT)
tf3 = input.timeframe("60",  "", inline = "3", group = grpT)
en4 = input.bool(true,  "", inline = "4", group = grpT)
tf4 = input.timeframe("240", "", inline = "4", group = grpT)
en5 = input.bool(true,  "", inline = "5", group = grpT)
tf5 = input.timeframe("D",   "", inline = "5", group = grpT, tooltip = "Timeframes lower than the chart are ignored.")

grpF = "FVG"
minAtr = input.float(0.15, "Min gap size (× ATR of its timeframe)", minval = 0, step = 0.05, group = grpF, tooltip = "Removes tiny gaps. 0 = no filter.")
maxPer = input.int(8, "Max zones kept per timeframe", minval = 1, maxval = 15, group = grpF)
showCE = input.bool(true, "Show CE (50%)", group = grpF)
lblOn  = input.bool(true, "Text inside zones", group = grpF)
fBullC = input.color(#089981, "Bullish FVG", inline = "fc", group = grpF)
fBearC = input.color(#f23645, "Bearish FVG", inline = "fc", group = grpF)
boxTr  = input.int(85, "Zone transparency", minval = 0, maxval = 100, group = grpF)

grpI = "iFVG"
iOn    = input.bool(true, "Show iFVGs", group = grpI)
iFrom  = input.string("Confirmed FVGs only", "Create iFVG from", options = ["Confirmed FVGs only", "All FVGs"], group = grpI, tooltip = "Confirmed only: an iFVG is shown only if the original FVG was on an LVN (less noise). 'All FVGs' needs 'Show only LVN-confirmed FVGs' turned off, otherwise unconfirmed gaps are not stored.")
iSupC  = input.color(#2962ff, "iFVG support (was bearish)", inline = "ic", group = grpI)
iResC  = input.color(#ff9800, "iFVG resistance (was bullish)", inline = "ic2", group = grpI)

grpV = "Volume profile filter"
vpOn     = input.bool(true, "Confirm FVGs with the volume profile", group = grpV)
vpDays   = input.int(3, "Sessions in the profile (incl. today)", minval = 1, maxval = 15, group = grpV, tooltip = "More sessions = the profile covers older 4H / Daily gaps. Gaps outside the profile range show 'no VP'.")
rowPts   = input.float(0, "Row size in points (0 = auto)", minval = 0, group = grpV, tooltip = "Auto = daily ATR / 40, fixed at the start of the chart history.")
lvnTh    = input.float(0.6, "LVN threshold (rel. volume ≤)", minval = 0.05, step = 0.05, group = grpV, tooltip = "1.0 = average row of the profile. 0.6 = the gap traded 40% less volume than an average row.")
showOnly = input.bool(true, "Show only LVN-confirmed FVGs", group = grpV, tooltip = "On: unconfirmed gaps are discarded and don't use up the per-timeframe zone limit.")
vpDraw   = input.bool(true, "Draw the profile on the right", group = grpV)
vpW      = input.int(40, "Profile width (bars)", minval = 5, maxval = 200, group = grpV)
vpOff    = input.int(15, "Profile offset (bars)", minval = 0, maxval = 200, group = grpV)
vpC      = input.color(color.new(color.gray, 70), "Rows", inline = "vc", group = grpV)
lvnC     = input.color(color.new(#ff9800, 55), "LVN", inline = "vc", group = grpV)
pocC     = input.color(color.new(#f23645, 30), "POC", inline = "vc", group = grpV)

grpD = "Display"
lblOff = input.int(3, "Zones extend past the last bar (bars)", minval = 0, maxval = 50, group = grpD)
txtSz  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)

sz = txtSz == "Tiny" ? size.tiny : txtSz == "Small" ? size.small : txtSz == "Normal" ? size.normal : size.large

//---------------------------------------------------------------------------------------------------------------------
// Types
//---------------------------------------------------------------------------------------------------------------------
type Day
    map<int, float> m

type Profile
    array<Day>      days
    map<int, float> cmp      // composite: sum of all kept sessions
    float           total

type Fvg
    int   dir               // 1 = bullish gap, -1 = bearish gap (original direction)
    float top
    float bot
    int   t0
    int   state             // 0 = FVG, 1 = iFVG, 2 = dead
    float rel
    bool  conf
    box   bx = na
    line  ce = na

type Book
    string     tfTxt
    array<Fvg> list

//---------------------------------------------------------------------------------------------------------------------
// Helpers
//---------------------------------------------------------------------------------------------------------------------
f_tf(string tf) =>
    s = timeframe.in_seconds(tf)
    str.endswith(tf, "M") ? tf : s >= 604800 ? str.tostring(s / 604800) + "W" : s >= 86400 ? str.tostring(s / 86400) + "D" : s >= 3600 ? str.tostring(s / 3600) + "H" : str.tostring(s / 60) + "m"

// data of the last CLOSED candle of the requested timeframe
f_sec() =>
    [low[1] > high[3], high[1] < low[3], low[1], high[3], low[3], high[1], time[2], close[1], ta.atr(14)[1]]

f_newDay(Profile p) =>
    p.days.push(Day.new(map.new<int, float>()))
    while p.days.size() > vpDays
        old = p.days.shift()
        for k in old.m.keys()
            ov = old.m.get(k)
            nv = nz(p.cmp.get(k)) - ov
            p.total := p.total - ov
            if nv <= 0.000001
                p.cmp.remove(k)
            else
                p.cmp.put(k, nv)
    true

f_addBar(Profile p, float h, float l, float v, float bs) =>
    if p.days.size() > 0 and v > 0 and h >= l
        k0  = math.floor(l / bs)
        k1  = math.floor(h / bs)
        per = v / (k1 - k0 + 1)
        d   = p.days.last()
        for k = k0 to k1
            d.m.put(k, nz(d.m.get(k)) + per)
            p.cmp.put(k, nz(p.cmp.get(k)) + per)
        p.total := p.total + v
    true

// average volume per row inside the zone / average volume per row of the profile (na if the zone is outside the profile)
f_rel(Profile p, float top, float bot, float bs) =>
    float r = na
    if p.cmp.size() > 0 and p.total > 0
        ks   = p.cmp.keys()
        kMin = ks.min()
        kMax = ks.max()
        kc   = math.floor((top + bot) / 2 / bs)
        if kc >= kMin and kc <= kMax
            k0 = math.floor(bot / bs)
            k1 = math.floor(top / bs)
            if k1 - k0 >= 2           // skip the edge rows, they belong to candles 1 and 3
                k0 += 1
                k1 -= 1
            float s = 0.0
            for k = k0 to k1
                s += nz(p.cmp.get(k))
            r := (s / (k1 - k0 + 1)) / (p.total / p.cmp.size())
    r

f_draw(Fvg f, string tfTxt) =>
    inv  = f.state == 1
    base = inv ? (f.dir == 1 ? iResC : iSupC) : (f.dir == 1 ? fBullC : fBearC)
    vpT  = vpOn ? (na(f.rel) ? " · no VP" : " · " + (f.conf ? "LVN " : "") + str.tostring(f.rel, "#.##")) : ""
    txt  = lblOn ? (inv ? "iFVG " : "FVG ") + tfTxt + vpT : ""
    if na(f.bx)
        f.bx := box.new(f.t0, f.top, time, f.bot, xloc = xloc.bar_time, border_color = color.new(base, 60), bgcolor = color.new(base, boxTr), text = txt, text_size = sz, text_color = base, text_halign = text.align_right, text_valign = text.align_center)
    else
        f.bx.set_bgcolor(color.new(base, boxTr))
        f.bx.set_border_color(color.new(base, 60))
        f.bx.set_text(txt)
        f.bx.set_text_color(base)
    mid = (f.top + f.bot) / 2
    if showCE
        if na(f.ce)
            f.ce := line.new(f.t0, mid, time, mid, xloc = xloc.bar_time, color = color.new(base, 40), style = line.style_dotted)
        else
            f.ce.set_color(color.new(base, 40))
    true

f_kill(Fvg f) =>
    f.bx.delete()
    f.ce.delete()
    f.state := 2
    true

// processes one timeframe when its candle closes
f_book(Book b, bool on, bool newTF, bool bU, bool bD, float uTop, float uBot, float dTop, float dBot, int t2, float cC, float atr, Profile p, float bs) =>
    bool nBull = false
    bool nBear = false
    bool iSup  = false
    bool iRes  = false
    if on and newTF
        // 1) existing zones against the closed candle of their timeframe
        if b.list.size() > 0
            for i = b.list.size() - 1 to 0
                f = b.list.get(i)
                if f.state == 0
                    brk = f.dir == 1 ? cC < f.bot : cC > f.top
                    if brk
                        f.state := 1
                        if iOn and (iFrom == "All FVGs" or f.conf)
                            f_draw(f, b.tfTxt)
                            iRes := iRes or f.dir == 1
                            iSup := iSup or f.dir == -1
                        else
                            f_kill(f)
                            b.list.remove(i)
                else if f.state == 1
                    dead = f.dir == 1 ? cC > f.top : cC < f.bot
                    if dead
                        f_kill(f)
                        b.list.remove(i)
        // 2) new gaps (hidden unconfirmed gaps are not stored, so they don't use up maxPer)
        if bU and not na(atr) and uTop - uBot >= minAtr * atr
            float rel = na
            if vpOn and not na(bs)
                rel := f_rel(p, uTop, uBot, bs)
            conf = not vpOn or (not na(rel) and rel <= lvnTh)
            if conf or not showOnly
                f = Fvg.new(1, uTop, uBot, t2, 0, rel, conf)
                b.list.push(f)
                f_draw(f, b.tfTxt)
            nBull := conf
        if bD and not na(atr) and dTop - dBot >= minAtr * atr
            float rel = na
            if vpOn and not na(bs)
                rel := f_rel(p, dTop, dBot, bs)
            conf = not vpOn or (not na(rel) and rel <= lvnTh)
            if conf or not showOnly
                f = Fvg.new(-1, dTop, dBot, t2, 0, rel, conf)
                b.list.push(f)
                f_draw(f, b.tfTxt)
            nBear := conf
        while b.list.size() > maxPer
            f_kill(b.list.shift())
    [nBull, nBear, iSup, iRes]

f_extend(Book b) =>
    xr = time + lblOff * timeframe.in_seconds() * 1000
    for f in b.list
        if not na(f.bx)
            f.bx.set_right(xr)
        if not na(f.ce)
            f.ce.set_x2(xr)
    true

//---------------------------------------------------------------------------------------------------------------------
// Volume profile (from chart candles)
//---------------------------------------------------------------------------------------------------------------------
dAtr = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)

var float bs = na
if na(bs)
    raw = rowPts > 0 ? rowPts : dAtr / 40
    if not na(raw) and raw > 0
        bs := math.max(syminfo.mintick, math.round(raw / syminfo.mintick) * syminfo.mintick)

var Profile prof = Profile.new(array.new<Day>(), map.new<int, float>(), 0.0)

if vpOn
    if prof.days.size() == 0 or timeframe.change("D")
        f_newDay(prof)
    if not na(bs)
        f_addBar(prof, high, low, nz(volume), bs)

//---------------------------------------------------------------------------------------------------------------------
// MTF FVG data (closed candles only)
//---------------------------------------------------------------------------------------------------------------------
chS = timeframe.in_seconds(timeframe.period)
on1 = en1 and timeframe.in_seconds(tf1) >= chS
on2 = en2 and timeframe.in_seconds(tf2) >= chS
on3 = en3 and timeframe.in_seconds(tf3) >= chS
on4 = en4 and timeframe.in_seconds(tf4) >= chS
on5 = en5 and timeframe.in_seconds(tf5) >= chS

[u1, d1, ut1, ub1, dt1, db1, tt1, cc1, at1] = request.security(syminfo.tickerid, tf1, f_sec(), lookahead = barmerge.lookahead_on)
[u2, d2, ut2, ub2, dt2, db2, tt2, cc2, at2] = request.security(syminfo.tickerid, tf2, f_sec(), lookahead = barmerge.lookahead_on)
[u3, d3, ut3, ub3, dt3, db3, tt3, cc3, at3] = request.security(syminfo.tickerid, tf3, f_sec(), lookahead = barmerge.lookahead_on)
[u4, d4, ut4, ub4, dt4, db4, tt4, cc4, at4] = request.security(syminfo.tickerid, tf4, f_sec(), lookahead = barmerge.lookahead_on)
[u5, d5, ut5, ub5, dt5, db5, tt5, cc5, at5] = request.security(syminfo.tickerid, tf5, f_sec(), lookahead = barmerge.lookahead_on)

var Book bk1 = Book.new(f_tf(tf1), array.new<Fvg>())
var Book bk2 = Book.new(f_tf(tf2), array.new<Fvg>())
var Book bk3 = Book.new(f_tf(tf3), array.new<Fvg>())
var Book bk4 = Book.new(f_tf(tf4), array.new<Fvg>())
var Book bk5 = Book.new(f_tf(tf5), array.new<Fvg>())

[a1, b1, c1, e1] = f_book(bk1, on1, timeframe.change(tf1), u1, d1, ut1, ub1, dt1, db1, tt1, cc1, at1, prof, bs)
[a2, b2, c2, e2] = f_book(bk2, on2, timeframe.change(tf2), u2, d2, ut2, ub2, dt2, db2, tt2, cc2, at2, prof, bs)
[a3, b3, c3, e3] = f_book(bk3, on3, timeframe.change(tf3), u3, d3, ut3, ub3, dt3, db3, tt3, cc3, at3, prof, bs)
[a4, b4, c4, e4] = f_book(bk4, on4, timeframe.change(tf4), u4, d4, ut4, ub4, dt4, db4, tt4, cc4, at4, prof, bs)
[a5, b5, c5, e5] = f_book(bk5, on5, timeframe.change(tf5), u5, d5, ut5, ub5, dt5, db5, tt5, cc5, at5, prof, bs)

newBull = a1 or a2 or a3 or a4 or a5
newBear = b1 or b2 or b3 or b4 or b5
newISup = c1 or c2 or c3 or c4 or c5
newIRes = e1 or e2 or e3 or e4 or e5

//---------------------------------------------------------------------------------------------------------------------
// Last bar: extend zones and draw the profile
//---------------------------------------------------------------------------------------------------------------------
var array<box> vpBx = array.new<box>()

if barstate.islast
    f_extend(bk1)
    f_extend(bk2)
    f_extend(bk3)
    f_extend(bk4)
    f_extend(bk5)

    for bx in vpBx
        bx.delete()
    vpBx.clear()
    if vpOn and vpDraw and not na(bs) and prof.cmp.size() > 0
        maxV = prof.cmp.values().max()
        avgP = prof.total / prof.cmp.size()
        for k in prof.cmp.keys()
            if vpBx.size() >= 350
                break
            v   = prof.cmp.get(k)
            w   = math.max(1, math.round(vpW * v / maxV))
            col = v == maxV ? pocC : v / avgP <= lvnTh ? lvnC : vpC
            vpBx.push(box.new(bar_index + vpOff, (k + 1) * bs, bar_index + vpOff + w, k * bs, border_color = color.new(col, 100), bgcolor = col))

//---------------------------------------------------------------------------------------------------------------------
// Alerts
//---------------------------------------------------------------------------------------------------------------------
alertcondition(newBull, "Bullish FVG on LVN", "New LVN-confirmed bullish FVG on {{ticker}}")
alertcondition(newBear, "Bearish FVG on LVN", "New LVN-confirmed bearish FVG on {{ticker}}")
alertcondition(newISup, "iFVG support", "Bearish FVG inverted into support (iFVG) on {{ticker}}")
alertcondition(newIRes, "iFVG resistance", "Bullish FVG inverted into resistance (iFVG) on {{ticker}}")
alertcondition(newBull or newBear or newISup or newIRes, "Any FVG / iFVG", "FVG / iFVG event on {{ticker}}")
````
