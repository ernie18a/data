# RSI Triangle Detector

- url: https://www.tradingview.com/script/8fog1dcC-RSI-Triangle-Detector/
- type: indicator
- pine_id: PUB;5d4e62523c3e481e8558edb7cf7c0592
- version: 1.0

## Description

RSI Triangle Detector

OVERVIEW
This indicator automatically finds triangle patterns that form on the RSI itself, not on price. When the RSI later breaks out of the triangle, it marks the breakout bar on the price chart and draws the key price levels of the consolidation, so you can see at a glance where momentum was compressing and where it was released.

It is designed as a tool to support your own analysis. It does not provide entry or exit signals on its own.

HOW IT WORKS
1. Pivot detection
The script tracks the two most recent pivot highs and the two most recent pivot lows of the RSI. The upper line of the triangle connects the two highs, and the lower line connects the two lows.

2. Triangle conditions
A triangle is recognized only when all of the following are true:
- The upper line is flat or falling, and the lower line is flat or rising (within the slope tolerance).
- The two lines converge at least at the minimum rate you set.
- The width of the pattern is within the minimum and maximum number of bars.
- The highs and lows overlap in time, so the lines actually enclose the RSI.
- The RSI has stayed between the two lines from the start of the pattern to the current bar (a small overshoot is allowed).

3. Optional filters
- Midline filter: only triangles sitting entirely above or entirely below the midline (default 50) are used.
- Direction filter: above the midline, the upper line must be flat or falling. Below the midline, the lower line must be flat or rising.

4. Breakout
Once a triangle is formed, both lines are extended bar by bar. A breakout is confirmed when the RSI closes above the upper line or below the lower line. The pattern is discarded if the lines meet at the apex or if no breakout happens within the waiting period.

WHAT YOU SEE
In the RSI pane:
- The RSI and its moving average
- The triangle (two lines with a shaded area) and its type: Ascending, Descending, or Symmetrical

On the price chart:
- A "Break Up" or "Break Down" label on the breakout bar
- For triangles above the midline: a dashed horizontal line at the highest price of the consolidation, and a trendline connecting the price lows at the RSI pivot lows
- For triangles below the midline: a dashed horizontal line at the lowest price of the consolidation, and a trendline connecting the price highs at the RSI pivot highs
- These lines are extended to the right for a set number of bars after the breakout

HOW TO USE
- Treat a breakout as a sign that momentum has left a period of compression. Check it against your own view of trend, structure, and support and resistance.
- The horizontal line and trendline show the price range that corresponded to the RSI triangle. Watching how price reacts to these levels after the breakout can help you judge whether the move has follow-through.
- If too many or too few patterns appear, adjust the pivot bars, the minimum convergence, and the width settings first.

MAIN SETTINGS
- RSI Length / MA Length
- Pivot Left Bars / Pivot Right Bars: sensitivity of the pivot highs and lows
- Min / Max Triangle Width: allowed size of the pattern in bars
- Flat Slope Tolerance: how much slope is still treated as flat
- Min Convergence: how quickly the two lines must approach each other
- Line Overshoot Tolerance: how far the RSI may exceed the lines while the pattern forms
- Breakout Buffer: extra distance required to confirm a breakout
- Bars to Wait for Breakout: how long a formed triangle stays valid
- Midline and direction filters
- Chart display: lines, labels, number of line sets to keep, extension length, colors

ALERTS
- Triangle Formed
- Triangle Breakout Up
- Triangle Breakout Down

NOTES
- All conditions are evaluated on confirmed bars, so signals do not change after the bar closes.
- Pivots need the "right bars" to be confirmed, so a triangle appears a few bars after its last pivot.
- Not every breakout leads to a sustained move. Results vary by symbol and timeframe, so please check recent signals on the chart you trade before relying on them.
- This script is for informational purposes only and is not financial advice.

――――――――――――――――――――
日本語版 (Japanese)
――――――――――――――――――――

RSI Triangle Detector(RSI 三角持ち合い判定)

概要
このインジケーターは、価格ではなくRSIそのものにできる三角持ち合いを自動で見つけます。その後RSIが三角形を抜けると、価格チャート上の抜けた足に印をつけ、持ち合い期間の重要な価格水準を線で示します。勢いがどこでたまり、どこで放たれたのかをひと目で確認できます。

ご自身の分析を助けるための道具であり、これだけで売買の合図を出すものではありません。

仕組み
1. 山と谷の検出
RSIの直近2つの山と直近2つの谷を記録します。三角形の上の線は2つの山を、下の線は2つの谷を結んだものです。

2. 三角形の条件
次の条件をすべて満たしたときだけ、三角形と判定します。
- 上の線が水平か右下がり、下の線が水平か右上がりであること(傾きの許容幅の範囲内)
- 2本の線が、設定した最小の速さ以上でせばまっていること
- 形の幅が、最小と最大の本数の範囲に収まっていること
- 山と谷の期間が重なっていて、2本の線が実際にRSIをはさんでいること
- 形の始まりから現在の足まで、RSIが2本の線の間に収まっていること(わずかなはみ出しは許容)

3. 任意の絞りこみ
- 中央の線による絞りこみ: 全体が中央の線(初期値50)より上、または下に収まっている三角形だけを使います。
- 線の向きによる絞りこみ: 中央の線より上では、上の線が水平か右下がりのものだけ。中央の線より下では、下の線が水平か右上がりのものだけを使います。

4. ブレイク
三角形ができると、2本の線を1本ごとに延ばしていきます。RSIの終値が上の線を上回るか、下の線を下回ったときにブレイクと判定します。2本の線が頂点で交わった場合や、待つ本数のうちに抜けなかった場合は、その形を取り消します。

表示されるもの
RSIの画面:
- RSIとその移動平均
- 三角形(2本の線と塗りつぶし)とその種類(Ascending=上昇三角、Descending=下降三角、Symmetrical=対称三角)

価格チャート:
- 抜けた足に「Break Up」(上抜け)または「Break Down」(下抜け)の吹き出し
- 中央の線より上の三角形: 持ち合い期間の高値に破線の水平線、RSIの谷にあたる足の安値どうしを結ぶトレンドライン
- 中央の線より下の三角形: 持ち合い期間の安値に破線の水平線、RSIの山にあたる足の高値どうしを結ぶトレンドライン
- これらの線は、抜けたあとも設定した本数だけ右へ延びます

使い方
- ブレイクは、たまっていた勢いが動きだした合図としてとらえ、トレンドや値動きの形、支持線・抵抗線についてのご自身の見立てと照らし合わせてください。
- 水平線とトレンドラインは、RSIの三角形に対応する価格の範囲を示します。抜けたあとに価格がこれらの水準でどう反応するかを見ると、動きが続くかどうかを判断する助けになります。
- 形が多すぎる、または少なすぎる場合は、まず山・谷の判定本数、最小のせばまり方、幅の設定を調整してください。

主な設定
- RSI Length / MA Length: RSIの期間 / 移動平均の期間
- Pivot Left Bars / Pivot Right Bars: 山と谷を判定する感度
- Min / Max Triangle Width: 形として認める幅(本数)
- Flat Slope Tolerance: 水平とみなす傾きの幅
- Min Convergence: 2本の線がせばまる速さの最小値
- Line Overshoot Tolerance: 形ができるまでの間に許すRSIのはみ出し
- Breakout Buffer: ブレイクと判定するために必要な余裕
- Bars to Wait for Breakout: できた三角形を有効とする本数
- 中央の線と線の向きによる絞りこみ
- チャート上の表示: 線、吹き出し、残す線の組数、延ばす本数、色

アラート
- Triangle Formed: 三角持ち合いの形成
- Triangle Breakout Up: 上抜け
- Triangle Breakout Down: 下抜け

注意点
- すべての条件は確定した足で判定するため、足が確定したあとに合図が変わることはありません。
- 山と谷は右側の本数がそろって初めて確定するため、三角形は最後の山または谷から数本遅れて表示されます。
- ブレイクのあとに必ず大きな動きが続くわけではありません。結果は銘柄や時間足によって変わるため、実際に使うチャートで直近の合図を確かめてからご利用ください。
- このスクリプトは情報提供を目的としたものであり、投資の助言ではありません。

## Source Code

````pine
//@version=6
indicator("RSI Triangle Detector", shorttitle="RSI Triangle", overlay=false, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ───────── Inputs ─────────
grpR   = "RSI"
src    = input.source(close, "Source", group=grpR)
rsiLen = input.int(14, "RSI Length", minval=1, group=grpR)
maLen  = input.int(14, "MA Length", minval=1, group=grpR)

grpT     = "Triangle"
pivL     = input.int(3, "Pivot Left Bars", minval=1, group=grpT)
pivR     = input.int(3, "Pivot Right Bars", minval=1, group=grpT)
minWidth = input.int(8, "Min Triangle Width (bars)", minval=2, group=grpT)
maxWidth = input.int(100, "Max Triangle Width (bars)", minval=5, maxval=300, group=grpT)
flatTol  = input.float(0.10, "Flat Slope Tolerance (RSI/bar)", minval=0, step=0.01, group=grpT)
minConv  = input.float(0.10, "Min Convergence (RSI/bar)", minval=0.01, step=0.01, group=grpT, tooltip="How much the upper and lower lines approach each other per bar. Higher values pick up only clearly defined triangles.")
tol      = input.float(2.0, "Line Overshoot Tolerance (RSI)", minval=0, step=0.5, group=grpT)
breakBuf = input.float(0.0, "Breakout Buffer (RSI)", minval=0, step=0.5, group=grpT)
maxWait  = input.int(40, "Bars to Wait for Breakout After Formation", minval=1, group=grpT)
useMid   = input.bool(true, "Exclude Triangles Crossing the Midline", group=grpT, tooltip="Only triangles that sit entirely above or entirely below the midline are evaluated.")
midLv    = input.float(50.0, "Midline", minval=1, maxval=99, step=1, group=grpT)
useDir   = input.bool(true, "Filter by Line Direction", group=grpT, tooltip="Triangles above the midline: exclude those whose upper line slopes up (flat or falling only). Triangles below the midline: exclude those whose lower line slopes down (flat or rising only).")

grpV     = "Display"
showType = input.bool(true, "Show Triangle Type", group=grpV)
colTri   = input.color(color.white, "Triangle Lines", group=grpV)
colBull  = input.color(color.teal, "Breakout Up", group=grpV)
colBear  = input.color(color.red, "Breakout Down", group=grpV)

grpC       = "Chart Display"
showLv     = input.bool(true, "Show Horizontal Line and Trendline", group=grpC, tooltip="Triangles above the midline: a horizontal line at the period high, and a trendline connecting the lows on the lower side. Triangles below the midline: a horizontal line at the period low, and a trendline connecting the highs on the upper side.")
showChartL = input.bool(true, "Show Label on Breakout Bar", group=grpC)
maxSets    = input.int(50, "Line Sets to Keep", minval=1, maxval=100, group=grpC, tooltip="One set consists of two lines: a horizontal line and a trendline. Older lines beyond this number are deleted.")
extBars    = input.int(50, "Bars to Extend Lines After Breakout", minval=1, group=grpC)
colLv      = input.color(color.orange, "Line Color", group=grpC)

// ───────── RSI ─────────
rsi   = ta.rsi(src, rsiLen)
rsiMa = ta.sma(rsi, maLen)

plot(rsi, "RSI", color=color.new(#7e57c2, 0))
plot(rsiMa, "RSI MA", color=color.yellow)
hU = hline(70, "Upper Band", color=color.gray, linestyle=hline.style_dashed)
hline(midLv, "Midline", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hD = hline(30, "Lower Band", color=color.gray, linestyle=hline.style_dashed)
fill(hU, hD, color=color.new(#7e57c2, 92))

// ───────── Pivot high / low tracking ─────────
ph = ta.pivothigh(rsi, pivL, pivR)
pl = ta.pivotlow(rsi, pivL, pivR)

var int   h1x = na
var float h1y = na
var int   h2x = na
var float h2y = na
var int   l1x = na
var float l1y = na
var int   l2x = na
var float l2y = na

bool newPivot = false
if barstate.isconfirmed
    if not na(ph)
        h1x := h2x
        h1y := h2y
        h2x := bar_index - pivR
        h2y := ph
        newPivot := true
    if not na(pl)
        l1x := l2x
        l1y := l2y
        l2x := bar_index - pivR
        l2y := pl
        newPivot := true

// ───────── Triangle being monitored ─────────
var bool  active    = false
var int   aHx       = na
var float aHy       = na
var float aSH       = na
var int   aLx       = na
var float aLy       = na
var float aSL       = na
var int   aHx2      = na
var float aHy2      = na
var int   aLx2      = na
var float aLy2      = na
var int   formedBar = na
var line  upLn      = na
var line  loLn      = na

bool formed    = false
bool bullBreak = false
bool bearBreak = false

// Check the formed triangle on every bar
if active and barstate.isconfirmed
    u = aHy + aSH * (bar_index - aHx)
    l = aLy + aSL * (bar_index - aLx)
    line.set_xy2(upLn, bar_index, u)
    line.set_xy2(loLn, bar_index, l)
    if u <= l
        active := false // Reached the apex (no breakout)
    else if rsi > u + breakBuf
        bullBreak := true
        active := false
    else if rsi < l - breakBuf
        bearBreak := true
        active := false
    else if bar_index - formedBar > maxWait
        active := false

// ───────── Chart display (horizontal line and trendline) ─────────
var line[]  lvLines = array.new<line>()
var int[]   lvBars  = array.new<int>()
var float[] lvSlope = array.new<float>()

if bullBreak or bearBreak
    startX = math.min(aHx, aLx)
    n = bar_index - startX
    // Find the high and low of the consolidation period only, excluding the breakout bar
    float hh = high[1]
    float ll = low[1]
    if n >= 1
        for i = 1 to n
            hh := math.max(hh, high[i])
            ll := math.min(ll, low[i])
    // Whether the triangle is above or below the midline
    upperSide = (aHy + aHy2 + aLy + aLy2) / 4 >= midLv
    if showLv
        if upperSide
            // Upper: horizontal line at the period high / Lower: trendline connecting the lows of the RSI pivot-low bars
            y1 = low[bar_index - aLx]
            y2 = low[bar_index - aLx2]
            sl = (y2 - y1) / (aLx2 - aLx)
            lvLines.push(line.new(startX, hh, bar_index, hh, color=colLv, style=line.style_dashed, width=1, force_overlay=true))
            lvSlope.push(0.0)
            lvLines.push(line.new(aLx, y1, bar_index, y1 + sl * (bar_index - aLx), color=colLv, style=line.style_solid, width=1, force_overlay=true))
            lvSlope.push(sl)
        else
            // Lower: horizontal line at the period low / Upper: trendline connecting the highs of the RSI pivot-high bars
            y1 = high[bar_index - aHx]
            y2 = high[bar_index - aHx2]
            sl = (y2 - y1) / (aHx2 - aHx)
            lvLines.push(line.new(startX, ll, bar_index, ll, color=colLv, style=line.style_dashed, width=1, force_overlay=true))
            lvSlope.push(0.0)
            lvLines.push(line.new(aHx, y1, bar_index, y1 + sl * (bar_index - aHx), color=colLv, style=line.style_solid, width=1, force_overlay=true))
            lvSlope.push(sl)
        lvBars.push(bar_index)
        lvBars.push(bar_index)
        while lvLines.size() > maxSets * 2
            line.delete(lvLines.shift())
            lvBars.shift()
            lvSlope.shift()
    if showChartL
        label.new(bar_index, na, bullBreak ? "Break Up" : "Break Down", yloc=bullBreak ? yloc.belowbar : yloc.abovebar, style=bullBreak ? label.style_label_up : label.style_label_down, color=bullBreak ? colBull : colBear, textcolor=color.white, size=size.small, force_overlay=true)

// Extend the remaining lines to the right (trendlines keep their slope)
if lvLines.size() > 0
    for i = 0 to lvLines.size() - 1
        if bar_index - lvBars.get(i) <= extBars
            ln = lvLines.get(i)
            line.set_xy2(ln, bar_index, line.get_y1(ln) + lvSlope.get(i) * (bar_index - line.get_x1(ln)))

// When a new pivot high or low is confirmed, check whether a triangle has formed
if barstate.isconfirmed and newPivot and not active and not na(h1x) and not na(l1x)
    sH    = (h2y - h1y) / (h2x - h1x)
    sL    = (l2y - l1y) / (l2x - l1x)
    width = math.max(h2x, l2x) - math.min(h1x, l1x)
    shapeOk   = sH <= flatTol and sL >= -flatTol and (sL - sH) >= minConv
    widthOk   = width >= minWidth and width <= maxWidth
    overlapOk = math.max(h1x, l1x) < math.min(h2x, l2x)
    // Whether all four pivot points are on the same side of the midline
    sideOk    = not useMid or math.min(l1y, l2y) >= midLv or math.max(h1y, h2y) <= midLv
    // Above the midline: upper line flat or falling only / Below the midline: lower line flat or rising only
    upperTri  = (h1y + h2y + l1y + l2y) / 4 >= midLv
    dirOk     = not useDir or (upperTri ? sH <= 0 : sL >= 0)
    if shapeOk and widthOk and overlapOk and sideOk and dirOk
        startX = math.max(h1x, l1x)
        ok = true
        for i = 0 to bar_index - startX
            x = bar_index - i
            u = h1y + sH * (x - h1x)
            l = l1y + sL * (x - l1x)
            if u <= l or rsi[i] > u + tol or rsi[i] < l - tol
                ok := false
                break
        if ok
            active    := true
            formed    := true
            formedBar := bar_index
            aHx := h1x
            aHy := h1y
            aSH := sH
            aLx := l1x
            aLy := l1y
            aSL := sL
            aHx2 := h2x
            aHy2 := h2y
            aLx2 := l2x
            aLy2 := l2y
            upLn := line.new(h1x, h1y, bar_index, h1y + sH * (bar_index - h1x), color=colTri, width=1)
            loLn := line.new(l1x, l1y, bar_index, l1y + sL * (bar_index - l1x), color=colTri, width=1)
            linefill.new(upLn, loLn, color.new(colTri, 90))
            if showType
                triType = math.abs(sH) <= flatTol ? "Ascending Triangle" : math.abs(sL) <= flatTol ? "Descending Triangle" : "Symmetrical Triangle"
                label.new(h1x, h1y, triType, style=label.style_none, textcolor=colTri, size=size.small, yloc=yloc.price)

// ───────── Alerts ─────────
alertcondition(formed, "Triangle Formed", "RSI has formed a triangle pattern")
alertcondition(bullBreak, "Triangle Breakout Up", "RSI broke out above the triangle")
alertcondition(bearBreak, "Triangle Breakout Down", "RSI broke out below the triangle")
````
