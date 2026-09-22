<!-- tradingview-pine-id: PUB;cc240e79c70b4aed8ce5620d6ae46eed -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# High Tight Flag [DJYYLAB]

Source: https://www.tradingview.com/script/gvxOqFz6-High-Tight-Flag-DJYYLAB/

## Description

OVERVIEW
Finds high tight flags: a stock doubles within a few weeks, then pauses in a tight range just under the high. The indicator draws the pole and the flag and keeps track of what happens after each one forms: a breakout, a quick drop back under the top, invalidation, or no breakout in time. All thresholds are listed below, so every result can be checked by hand.

Everything is calculated on closed bars. A flag shows up on the bar where it is first confirmed, and its box then grows with each new bar until the flag ends.

HOW IT WORKS
1. Pole
- The pole top is the highest point of the whole pattern: no bar from the pole low up to it reaches it, and nothing after it trades above it until the breakout.
- The pole low is the lowest low of the 40 bars before the pole top.
- From the pole low to the pole top: a gain of at least 100%, taking 3 to 40 bars (40 bars is 8 weeks on a daily chart). The 3-bar minimum keeps out jumps of a day or two.
- Volume surges in the pole: the biggest pole bar has at least 1.3x the average volume of the 5 bars before the pole (skipped when the chart has fewer than 5 bars before it).

2. Flag
- Every bar after the pole top. The flag is 10 to 25 bars long.
- The flag low stays within 25% of the pole top.
- Volume dries up: the flag's average volume is at most 0.75x the pole's.
- No rule on the flag's shape. It can drift down, move sideways or narrow.
The flag forms on the first bar where all of the above is true, at the earliest 10 bars after the pole top.

3. After it forms (breakout level = pole top)
- Breakout: the first bar that trades above the pole top. The breakout price is the pole top, or the open if the bar opened above it.
- Back below in 5 bars: after a breakout, a close at or under the pole top within 5 bars.
- Invalidated: trading more than 25% under the pole top before a breakout.
- Expired: more than 25 flag bars without a breakout.
- A bar that trades both above the top and more than 25% under it counts on the side nearer to its open.

ON THE CHART
- The pole: a line from the pole low to the pole top.
- The flag: a box from the pole top level down to the flag low, from the pole top to the latest bar. It ends on the breakout bar. The bottom of the box moves down when the flag makes a new low, so the flag's candles always stay inside it.
- Purple = waiting, green label = broke out, orange label = back below in 5 bars, grey = invalidated or expired (the box is cut on that bar).
- On a breakout: a triangle under the bar and a dotted measured move. The measured move is half the pole height added to the flag low.
- Hover the "High Tight Flag" label for the pole dates, prices, length and gain, the flag length, depth and volume, the result, the breakout price and its volume against the 50-bar average, the measured move, and the move 5, 10 and 20 bars after the breakout.
- Alerts: "High tight flag formed", "Near the top" (close within 3% under the pole top), "High tight flag breakout" (price trades above the pole top).

SETTINGS AND TIMEFRAMES
- Pole length, pole gain, pole volume, flag length, flag depth, flag volume, the failure window and the number of flags kept on the chart (6 by default, up to 20) can all be changed.
- Works on any timeframe. Lengths are in bars, so on a weekly chart the pole can take up to 40 weeks.
- Volume rules are skipped on symbols without volume.
- On stocks, keep dividend adjustment (ADJ) on so ex-dividend gaps don't look like price moves.

ORIGINALITY
Written from scratch, no code taken from other scripts. The breakout level is the highest point of the pattern, not a sloping line over the flag, and the flag has to hold within 25% of that high for 10 to 25 bars. Every flag is followed after it forms, and the box always holds the flag's candles.

------------------------------------------------------------
日本語

概要
ハイ・タイト・フラッグ（数週間で株価がおよそ2倍になり、その高値のすぐ下で狭い範囲の横ばいになる形）を検出するインジケーターです。ポールとフラッグを描き、形成後にどうなったか（ブレイク、すぐにポールの頂上の下へ戻った、失効、期限切れ）まで追いかけます。しきい値はすべて下に書いてあるので、結果を自分で確かめられます。

計算はすべて確定足で行います。フラッグは初めて確定した足に表示され、その後はフラッグが終わるまで新しい足ごとに箱が伸びていきます。

判定ルール
1. ポール
- ポールの頂上はパターン全体の最高値です。ポールの安値から頂上までの間にこれに届く足はなく、頂上のあとブレイクまでこれを上回る足もありません。
- ポールの安値は、頂上より前の40本の中の最安値です。
- ポールの安値から頂上まで100%以上の上昇で、かかる本数は3〜40本（日足なら40本で8週間）。3本以上とするのは、1〜2日の急騰を除くためです。
- ポールで出来高が増えること：ポール内で最大の出来高が、ポールが始まる前の5本の平均の1.3倍以上（その前に5本ない場合はこの条件を使いません）。

2. フラッグ
- ポールの頂上のあとのすべての足。長さは10〜25本。
- フラッグの安値はポールの頂上から25%以内。
- 出来高が細ること：フラッグの平均出来高がポールの平均の0.75倍以下。
- 形の条件はありません。下向き、横ばい、収束のどれでもかまいません。
すべてを満たした最初の足でフラッグが形成されます（早くてもポールの頂上の10本後）。

3. 形成後（ブレイクの水準＝ポールの頂上）
- ブレイク：ポールの頂上を初めて上回った足。ブレイク価格はポールの頂上（その足が頂上より上で寄り付いた場合は始値）。
- 5本以内に戻る：ブレイク後5本以内に終値がポールの頂上以下になる。
- 失効：ブレイク前にポールの頂上から25%を超えて下げる。
- 期限切れ：フラッグが25本を超えてもブレイクしない。
- 1本の足が頂上の上と25%下の両方に届いた場合は、始値に近い側として数えます。

チャート表示
- ポール：安値から頂上までの1本の線。
- フラッグ：ポールの頂上の水準からフラッグの安値までの箱。頂上から最新の足まで伸び、ブレイクした足で終わります。フラッグが安値を更新すると箱の下辺も下がるので、フラッグのローソク足は常に箱の中に収まります。
- 紫＝ブレイク待ち、緑のラベル＝ブレイク、オレンジのラベル＝5本以内に戻る、グレー＝失効または期限切れ（箱はその足で切れます）。
- ブレイク時：足の下に三角と、点線の値幅目標。値幅目標はポールの高さの半分をフラッグの安値に足したものです。
- 「High Tight Flag」ラベルにカーソルを合わせると、ポールの日付・価格・本数・上昇率、フラッグの本数・深さ・出来高、結果、ブレイク価格とその出来高（直前50本の平均との比）、値幅目標、ブレイク後5・10・20本の値動きが表示されます。
- アラート：「High tight flag formed」「Near the top」（終値がポールの頂上の下3%以内）「High tight flag breakout」（ポールの頂上を上回る）。

設定と時間足
- ポールの本数・上昇率・出来高、フラッグの本数・深さ・出来高、「5本以内に戻る」の本数、チャートに残すフラッグの数（初期値6、最大20）は変更できます。
- どの時間足でも使えます。長さは本数なので、週足ならポールは最大40週になります。
- 出来高のない銘柄では出来高のルールは使いません。
- 株式では配当調整（ADJ）をオンにしてください。権利落ちの窓が値動きに見えるのを防げます。

独自性
他のスクリプトのコードは使わず、一から書いています。ブレイクの水準はフラッグの上の斜めの線ではなくパターンの最高値で、フラッグはその高値から25%以内で10〜25本持ちこたえる必要があります。形成後の経過まで追いかけ、箱は常にフラッグのローソク足を収めます。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DJYYLAB

//@version=6
indicator("High Tight Flag [DJYYLAB]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

// hidden anchor keeps every drawing on the main price scale
plot(close, "price anchor", color = color.new(color.gray, 100), editable = false, display = display.none)

// ============================================================ inputs
gP = "Pole"
iPoleMin = input.int(3, "Pole: at least this many bars from its low to its top", minval = 1, maxval = 100, group = gP,
     tooltip = "Keeps out jumps of a day or two.")
iPoleMax = input.int(40, "Pole: at most this many bars from its low to its top", minval = 5, maxval = 200, group = gP,
     tooltip = "The pole low is the lowest low of this many bars before the pole top. 40 bars is 8 weeks on a daily chart.")
iGain    = input.float(100.0, "Pole gain at least %", minval = 10.0, maxval = 1000.0, step = 5.0, group = gP,
     tooltip = "From the pole low to the pole top.") / 100.0
iPoleVol = input.float(1.3, "Biggest pole volume at least (times the 5-bar average before the pole)", minval = 0.0, step = 0.1, group = gP,
     tooltip = "Skipped when the chart has fewer than 5 bars before the pole. All volume rules are skipped on symbols without volume.")

gF = "Flag"
iFlagMin = input.int(10, "Flag length at least (bars)", minval = 2, maxval = 100, group = gF)
iFlagMax = input.int(25, "Flag length at most (bars)", minval = 5, maxval = 100, group = gF,
     tooltip = "A flag that grows longer than this without a breakout is over.")
iDepth   = input.float(25.0, "Flag low at most % under the pole top", minval = 5.0, maxval = 60.0, step = 1.0, group = gF,
     tooltip = "Trading lower than this before a breakout invalidates the flag.") / 100.0
iFlagVol = input.float(0.75, "Flag average volume at most (times the pole average)", minval = 0.1, maxval = 2.0, step = 0.05, group = gF)

gA = "After it forms"
iFail    = input.int(5, "Failed: a close at or under the pole top within (bars) after the breakout", minval = 1, maxval = 20, group = gA,
     tooltip = "The breakout is the first bar that trades above the pole top, the highest point of the pattern.")
iNear    = input.float(3.0, "Near the top: close within % under the pole top", minval = 0.5, maxval = 10.0, step = 0.5, group = gA) / 100.0

gV = "Display"
iShowN   = input.int(6, "Flags to keep on the chart", minval = 1, maxval = 20, group = gV)
iShowMM  = input.bool(true, "Measured move after a breakout", group = gV, tooltip = "Half the pole height added to the flag low.")
cFlag    = input.color(#AA00FF, "Flag",     inline = "c1", group = gV)
cBreak   = input.color(#00C853, "Breakout", inline = "c1", group = gV)
cFail    = input.color(#FF6D00, "Failed",   inline = "c2", group = gV)
cDead    = input.color(#9E9E9E, "Invalidated or expired", inline = "c2", group = gV)

VOL_N = 5        // bars before the pole that set its volume baseline

// ============================================================ per-bar history, indexed by bar_index
var array<int>   aT = array.new<int>()
var array<float> aH = array.new<float>()
var array<float> aL = array.new<float>()
var array<float> aC = array.new<float>()
var array<float> aV = array.new<float>()
var bool volSeen = false

if barstate.isconfirmed
    array.push(aT, time)
    array.push(aH, high)
    array.push(aL, low)
    array.push(aC, close)
    array.push(aV, nz(volume))
    if nz(volume) > 0
        volSeen := true

// average volume of the 50 bars before the current one
vAvgPrev = ta.sma(volume, 50)[1]

step = timeframe.in_seconds() * 1000
tAt(int i) =>
    n = array.size(aT)
    i < n ? array.get(aT, i) : (n > 0 ? array.get(aT, n - 1) + step * (i - n + 1) : time)

// time of a point between two bars
tX(float x) =>
    int i0 = int(math.floor(x))
    int(math.round(tAt(i0) + (x - i0) * (tAt(i0 + 1) - tAt(i0))))

f_date(int i) =>
    str.format_time(tAt(i), timeframe.isintraday ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd", syminfo.timezone)

f_sgn(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.#")

f_above(float v, float ln) => v - ln > 1e-9 * math.abs(ln)
f_below(float v, float ln) => ln - v > 1e-9 * math.abs(ln)

// thresholds compared with room for rounding, so a value that sits exactly on a limit passes
f_over(float v, float lim) => v > lim + 1e-9
f_under(float v, float lim) => v < lim - 1e-9

// a bar that trades past both limits at once is counted on the side nearer to its open
f_upFirst(float op, float u, float l) => u - op <= op - l

// ============================================================ the flag
type Flg
    int   seq
    int   iS
    float pS
    int   iA
    float pA
    float lowest    // flag low so far, the bottom of the box
    int   formed
    int   code      // 0 waiting, 1 broke out, 2 failed, 3 invalidated, 4 expired
    int   brk
    float price0    // breakout price: the pole top, or the open when the bar opened above it
    float target
    float bvR
    int   endI
    float volR
    line     pole
    polyline shape
    label    tag
    line     mmLine
    label    mmTag

var array<Flg> flags = array.new<Flg>()
var Flg live = na
var int flagSeq = 0

// bottom of the box: the flag low, or the pole top bar's own low when its wick reaches lower
f_boxLow(Flg f) => math.min(f.lowest, array.get(aL, f.iA))

// where the bottom of the box meets the pole
f_cross(Flg f, float bot) =>
    float x = f.iS + (bot - f.pS) / (f.pA - f.pS) * (f.iA - f.iS)
    math.max(f.iS, math.min(f.iA, x))

// closed shape: the pole top level from the pole top to the last bar, down to the bottom, back along it to the pole
f_shape(Flg f, int endI, color col) =>
    float bot = f_boxLow(f)
    float xc = f_cross(f, bot)
    pts = array.new<chart.point>()
    array.push(pts, chart.point.from_time(tAt(f.iA), f.pA))
    array.push(pts, chart.point.from_time(tAt(endI), f.pA))
    array.push(pts, chart.point.from_time(tAt(endI), bot))
    array.push(pts, chart.point.from_time(tX(xc), bot))
    polyline.new(pts, closed = true, xloc = xloc.bar_time, line_color = col, line_width = 2, fill_color = color.new(col, 88))

f_redraw(Flg f, int endI, color col, color tagCol) =>
    polyline.delete(f.shape)
    f.shape := f_shape(f, endI, col)
    line.set_color(f.pole, col)
    label.set_color(f.tag, color.new(tagCol, 10))
    0

f_res(int code) =>
    code == 1 ? "Broke out" : code == 2 ? "Back at or under the pole top within " + str.tostring(iFail) + " bars" : code == 3 ? "Fell more than " + str.tostring(iDepth * 100, "#") + "% under the pole top" : code == 4 ? "No breakout within " + str.tostring(iFlagMax) + " flag bars" : "Waiting for a breakout"

f_chg(Flg f, int k, int d) =>
    f.brk >= 0 and f.brk + k <= d and f.brk + k < array.size(aC) ? f_sgn((array.get(aC, f.brk + k) / f.price0 - 1) * 100.0) + "%" : "-"

f_tip(Flg f, int d) =>
    int fe = f.brk >= 0 ? f.brk - 1 : f.endI >= 0 ? f.endI : d
    string s = "High Tight Flag, formed " + f_date(f.formed)
    s += "\nPole " + f_date(f.iS) + " " + str.tostring(f.pS, format.mintick) + " to " + f_date(f.iA) + " " + str.tostring(f.pA, format.mintick) + ": " + str.tostring(f.iA - f.iS) + " bars, +" + str.tostring((f.pA / f.pS - 1) * 100, "#") + "%"
    s += "\nFlag " + str.tostring(fe - f.iA) + " bars, low " + str.tostring((1 - f.lowest / f.pA) * 100, "#.#") + "% under the pole top" + (na(f.volR) ? "" : ", volume " + str.tostring(f.volR, "#.##") + "x the pole average")
    s += "\nResult: " + f_res(f.code)
    if f.brk >= 0
        s += "\nBreakout " + f_date(f.brk) + " at " + str.tostring(f.price0, format.mintick) + ", close " + str.tostring(array.get(aC, f.brk), format.mintick) + (na(f.bvR) ? "" : ", volume " + str.tostring(f.bvR, "#.##") + "x the 50-bar average")
        s += "\nMeasured move " + str.tostring(f.target, format.mintick) + " (half the pole height above the flag low)"
        s += "\nFrom the breakout price: +5 bars " + f_chg(f, 5, d) + ", +10 bars " + f_chg(f, 10, d) + ", +20 bars " + f_chg(f, 20, d)
    else if f.endI >= 0
        s += " (" + f_date(f.endI) + ")"
    s

trimOld() =>
    int cut = flagSeq - iShowN
    if array.size(flags) > 0
        for k = array.size(flags) - 1 to 0
            Flg f = array.get(flags, k)
            if f.seq <= cut
                line.delete(f.pole)
                polyline.delete(f.shape)
                label.delete(f.tag)
                line.delete(f.mmLine)
                label.delete(f.mmTag)
                array.remove(flags, k)
    0

formedNow = false
broke = false

// ---------------------------------------------------------- following the live flag, bar by bar
if barstate.isconfirmed and not na(live)
    Flg f = live
    int d = bar_index
    float inv = f.pA * (1 - iDepth)
    bool upX = f_above(high, f.pA)
    bool dnX = f_below(low, inv)
    if upX and dnX
        upX := f_upFirst(open, f.pA, inv)
        dnX := not upX
    if dnX
        f.code := 3
        f.endI := d
        f_redraw(f, d, cDead, cDead)
        label.set_tooltip(f.tag, f_tip(f, d))
        live := na
    else
        // the bar belongs to the flag: the bottom of the box moves down to hold its low
        f.lowest := math.min(f.lowest, low)
        if upX
            f.code := 1
            f.brk := d
            f.price0 := math.max(open, f.pA)
            f.target := f.lowest + (f.pA - f.pS) / 2
            f.bvR := volSeen and vAvgPrev > 0 ? volume / vAvgPrev : na
            f.endI := d
            broke := true
            f_redraw(f, d, cFlag, cBreak)
            if iShowMM
                f.mmLine := line.new(time, f.price0, time, f.target, xloc = xloc.bar_time, color = cBreak, style = line.style_dotted, width = 2)
                f.mmTag := label.new(time, f.target, "measured move " + str.tostring(f.target, format.mintick), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(cBreak, 20), textcolor = color.white, size = size.tiny)
            live := na
        else if d - f.iA > iFlagMax
            f.code := 4
            f.endI := d
            f_redraw(f, d, cDead, cDead)
            label.set_tooltip(f.tag, f_tip(f, d))
            live := na
        else
            f_redraw(f, d, cFlag, cFlag)

// ---------------------------------------------------------- after a breakout
if barstate.isconfirmed and array.size(flags) > 0
    for f in flags
        if f.code == 1
            int n = bar_index - f.brk
            if n >= 1 and n <= iFail and close <= f.pA
                f.code := 2
                label.set_color(f.tag, color.new(cFail, 10))
        if f.code == 0 or (f.brk >= 0 and bar_index - f.brk <= 20)
            label.set_tooltip(f.tag, f_tip(f, bar_index))

// ---------------------------------------------------------- the detector
// The pole top is the highest point of the pattern: nothing above it from the pole low until today. The pole low is
// the lowest low of the bars before the top. The flag is every bar after the top.
bool  fnd = false
int   fS = -1
int   fA = -1
float fLow = 0.0
float fVolR = na

if barstate.isconfirmed and na(live)
    int d = bar_index
    int aNew = d - iFlagMin
    int aOld = math.max(1, d - iFlagMax)
    if aNew >= aOld
        for a = aNew to aOld
            float pA = array.get(aH, a)
            // the flag: nothing above the pole top since it
            bool ok = true
            float fl = pA
            for i = a + 1 to d
                if array.get(aH, i) > pA
                    ok := false
                    break
                fl := math.min(fl, array.get(aL, i))
            if not ok
                continue
            // the pole low: the lowest low before the top, earliest on ties
            int s = -1
            float pS = na
            for k = math.max(0, a - iPoleMax) to a - 1
                if na(pS) or array.get(aL, k) < pS
                    pS := array.get(aL, k)
                    s := k
            if s < 0 or pS <= 0 or a - s < iPoleMin
                continue
            // the top is the highest point of the pole, earliest on ties
            for i = s to a - 1
                if array.get(aH, i) >= pA
                    ok := false
                    break
            if not ok
                continue
            if f_under(pA / pS - 1, iGain)
                continue
            if f_over((pA - fl) / pA, iDepth)
                continue
            // volume: a surge in the pole, drying up in the flag
            float volR = na
            if volSeen
                float maxV = 0.0
                float sumV = 0.0
                for i = s to a
                    maxV := math.max(maxV, array.get(aV, i))
                    sumV += array.get(aV, i)
                float avgV = sumV / (a - s + 1)
                if avgV <= 0
                    continue
                // the surge test needs 5 bars before the pole; on a shorter history it is skipped
                if s >= VOL_N
                    float bs = 0.0
                    for i = s - VOL_N to s - 1
                        bs += array.get(aV, i)
                    float base = bs / VOL_N
                    if base > 0 and f_under(maxV / base, iPoleVol)
                        continue
                float fs = 0.0
                for i = a + 1 to d
                    fs += array.get(aV, i)
                volR := fs / (d - a) / avgV
                if f_over(volR, iFlagVol)
                    continue
            fnd := true
            fS := s
            fA := a
            fLow := fl
            fVolR := volR
            break

// ---------------------------------------------------------- a flag found today
if fnd
    int d = bar_index
    flagSeq += 1
    trimOld()
    Flg f = Flg.new(seq = flagSeq, iS = fS, pS = array.get(aL, fS), iA = fA, pA = array.get(aH, fA), lowest = fLow, formed = d, code = 0, brk = -1,
         price0 = na, target = na, bvR = na, endI = -1, volR = fVolR, pole = na, shape = na, tag = na, mmLine = na, mmTag = na)
    f.pole := line.new(tAt(f.iS), f.pS, tAt(f.iA), f.pA, xloc = xloc.bar_time, color = cFlag, width = 2)
    f.shape := f_shape(f, d, cFlag)
    f.tag := label.new(tAt(f.iA), f.pA, "High Tight Flag", xloc = xloc.bar_time, style = label.style_label_down,
         color = color.new(cFlag, 10), textcolor = color.white, size = size.small)
    label.set_tooltip(f.tag, f_tip(f, d))
    formedNow := true
    live := f
    array.push(flags, f)

// ============================================================ markers and alerts
plotshape(broke, "Breakout", shape.triangleup, location.belowbar, cBreak, size = size.tiny)
alertcondition(formedNow, "High tight flag formed", "A high tight flag formed")
near = not na(live) and close > 0 and close <= live.pA and (live.pA - close) / close <= iNear
alertcondition(near, "Near the top", "Close within a few percent under the pole top of a high tight flag")
touchNow = not na(live) and f_above(high, live.pA)
alertcondition(broke or touchNow, "High tight flag breakout", "Price traded above the pole top of a high tight flag")
````
