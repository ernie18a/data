# nanako_zigzag

- url: https://www.tradingview.com/script/CbkbVDit/
- type: indicator
- pine_id: PUB;f17a525191a34d76a56bdbd476dd74a0
- version: 1.0

## Description

ZigZag++ Bounce / Break Probability is an enhanced ZigZag indicator designed to help traders analyze market structure and evaluate the probability of support and resistance levels breaking or holding.

FEATURES

■ Advanced ZigZag Structure Detection

The indicator automatically detects swing highs and swing lows and draws ZigZag structures in real time.

Each pivot is classified as:

• HH (Higher High)
• HL (Higher Low)
• LH (Lower High)
• LL (Lower Low)

This provides a clear visual representation of trend development and market structure.

■ Automatic Support and Resistance Updates

The two most recent significant pivot levels are automatically converted into support or resistance zones.

Levels update dynamically whenever a new pivot is confirmed, eliminating the need for manual drawing.

■ Breakout and Bounce Probability Engine

The indicator estimates the probability of a level breaking or rejecting by combining multiple technical factors:

• Market structure bias (HH/HL/LH/LL)
• RSI momentum
• EMA21 trend direction
• ATR-based distance scoring
• Volume strength
• Historical touch frequency
• Rejection candle behavior

The result is displayed as a Break Probability and Bounce Probability for each active level.

■ Real-Time Probability Table

A compact table in the top-right corner displays:

• Current level price
• Break probability
• Bounce probability

This allows traders to evaluate key levels instantly without searching through the chart.

■ Clean and Readable Design

The indicator focuses on visual clarity by highlighting only the most relevant information, making it suitable for discretionary traders, breakout traders, and market structure analysis.

USE CASES

• Breakout trading
• Pullback entries
• Support and resistance trading
• Trend continuation analysis
• Market structure confirmation

DISCLAIMER

This indicator does not predict future prices. It is designed to evaluate current market conditions and visualize the relative probability of a breakout or rejection based on multiple technical factors.


ZigZag++ Bounce / Break Probability は、従来の ZigZag インジケーターを拡張し、相場構造の分析とサポート・レジスタンスラインの突破確率を視覚的に判断できるよう設計されたインジケーターです。

【主な機能】

■ ZigZag構造の自動描画
高値・安値を自動検出し、ZigZagラインをリアルタイムで描画します。

■ HH・HL・LH・LLの表示
各ピボットポイントに対して市場構造を自動判定します。

・HH（Higher High）
・HL（Higher Low）
・LH（Lower High）
・LL（Lower Low）

これによりトレンドの方向性を直感的に把握できます。

■ サポート・レジスタンスラインの自動更新
直近2つの重要なピボットを基準に、サポートライン・レジスタンスラインを自動生成します。

ラインは新しいピボット形成時に自動更新されるため、手動でラインを引く必要はありません。

■ ブレイク確率・反発確率の計算
ライン付近では以下の情報を組み合わせて確率を算出します。

・市場構造（HH/HL/LH/LL）
・RSI
・EMA21
・ATRによる距離評価
・出来高
・ライン接触回数
・プライスアクションによる反発判定

これらを総合評価し、現在のラインが突破される可能性と反発する可能性を表示します。

■ 右上の確率テーブル
チャート右上には現在重要な2本のラインについて、

・レベル価格
・ブレイク確率
・反発確率

を一覧表示します。

ラインまで価格が離れていても現在の状況をすぐ確認できます。

■ 視認性を重視した設計
チャート上に必要な情報だけを表示し、分析に集中できるよう設計されています。

【活用例】

・押し目買いポイントの判断
・戻り売りポイントの判断
・ブレイクアウト戦略
・レンジ相場の反発狙い
・相場構造分析

本インジケーターは将来の価格を予測するものではありません。現在の市場構造やテクニカル要素を基に、ブレイクと反発の優位性を視覚化するための補助ツールです。

## Source Code

````pine
//@version=6
indicator("ZigZag++ Bounce / Break Probability", shorttitle="ZZ++Pred", overlay=true, max_lines_count=500, max_labels_count=500)

// ========================
// Inputs
// ========================
depth           = input.int(8,     "ZigZag Depth",                 minval=2)
showActiveLeg   = input.bool(true, "Show Active Leg")
zzUpColor       = input.color(color.lime,  "ZigZag Up Color")
zzDownColor     = input.color(color.red,   "ZigZag Down Color")
zzWidth         = input.int(2,     "ZigZag Line Width",            minval=1, maxval=5)
labelTextColor  = input.color(color.white, "Label Text Color")
showPivotPrice  = input.bool(false,"Show Pivot Price in Label")
levelExtendBars = input.int(80,    "Prediction Line Extend Bars",  minval=10, maxval=500)
probLookback    = input.int(150,   "Probability Lookback",         minval=30, maxval=500)
showProbability = input.bool(true, "Show Break / Bounce Probability")
showLevelLines  = input.bool(true, "Show Previous 2 Pivot Lines")
touchTolATR     = input.float(0.15,"Touch Tolerance (ATR x)",      minval=0.05, step=0.05)

// =========================
// Arrays  ※ time ベースで管理 (RE10026 対策)
// =========================
var int[]   pivotTimes  = array.new_int()    // bar_index ではなく time を格納
var float[] pivotPrices = array.new_float()
var bool[]  pivotIsHigh = array.new_bool()

var line[]  zzLines  = array.new_line()
var label[] zzLabels = array.new_label()

var line  activeLeg = na
var line  lvlLine1  = na
var line  lvlLine2  = na
var label probLbl1  = na
var label probLbl2  = na

// =========================
// Pure helpers
// =========================
f_prevSameTypeIndex(_idx, _isHigh) =>
    int prev = int(na)
    if _idx > 0
        for j = 0 to _idx - 1
            if array.get(pivotIsHigh, j) == _isHigh
                prev := j
    prev

f_pivotText(_idx) =>
    bool   isHigh  = array.get(pivotIsHigh, _idx)
    float  price   = array.get(pivotPrices, _idx)
    int    prevIdx = f_prevSameTypeIndex(_idx, isHigh)
    string txt     = isHigh ? "H" : "L"
    if not na(prevIdx)
        float prevPrice = array.get(pivotPrices, prevIdx)
        if isHigh
            txt := price > prevPrice ? "HH" : "LH"
        else
            txt := price > prevPrice ? "HL" : "LL"
    showPivotPrice ? txt + "\n" + str.tostring(price, format.mintick) : txt

f_structureBias() =>
    int lastHigh1 = int(na), lastHigh2 = int(na), lastLow1 = int(na), lastLow2 = int(na)
    int n = array.size(pivotTimes)
    if n > 0
        for i = 0 to n - 1
            if array.get(pivotIsHigh, i)
                lastHigh2 := lastHigh1
                lastHigh1 := i
            else
                lastLow2 := lastLow1
                lastLow1 := i
    int bias = 0
    if not na(lastHigh1) and not na(lastHigh2) and not na(lastLow1) and not na(lastLow2)
        bool hh = array.get(pivotPrices, lastHigh1) > array.get(pivotPrices, lastHigh2)
        bool hl = array.get(pivotPrices, lastLow1)  > array.get(pivotPrices, lastLow2)
        bool lh = array.get(pivotPrices, lastHigh1) < array.get(pivotPrices, lastHigh2)
        bool ll = array.get(pivotPrices, lastLow1)  < array.get(pivotPrices, lastLow2)
        bias := hh and hl ? 1 : lh and ll ? -1 : 0
    bias

f_touchCount(_level, _tol, _lookback) =>
    int cnt = 0
    for i = 0 to _lookback - 1
        if high[i] >= _level - _tol and low[i] <= _level + _tol
            cnt += 1
    cnt

f_rejectionAtResistance(_level, _tol) =>
    float body      = math.abs(close - open)
    float upperWick = high - math.max(open, close)
    high >= _level - _tol and close < open and upperWick > body

f_rejectionAtSupport(_level, _tol) =>
    float body      = math.abs(close - open)
    float lowerWick = math.min(open, close) - low
    low <= _level + _tol and close > open and lowerWick > body

f_breakProbability(_level, _isResistance) =>
    float atr_     = ta.atr(14)
    float tol      = atr_ * touchTolATR
    float rsiVal   = ta.rsi(close, 14)
    float ema21    = ta.ema(close, 21)
    float volMa    = ta.sma(volume, 20)
    int   bias     = f_structureBias()
    int   touches  = f_touchCount(_level, tol, probLookback)
    float dist     = math.abs(close - _level)
    float distScore = dist <= atr_ * 0.25 ? 12.0 :
                      dist <= atr_ * 0.50 ?  8.0 :
                      dist <= atr_ * 1.00 ?  4.0 : 0.0
    bool volStrong = volume > volMa * 1.2
    float prob = 50.0
    if _isResistance
        prob += bias ==  1 ? 15.0 : bias == -1 ? -10.0 : 0.0
        prob += rsiVal > 55 ? 10.0 : rsiVal < 45 ? -8.0 : 0.0
        prob += close > ema21 ?  8.0 : -4.0
        prob += distScore
        prob += math.min(touches, 4) * 3.0
        prob += volStrong ? 8.0 : 0.0
        prob += f_rejectionAtResistance(_level, tol) ? -15.0 : 0.0
    else
        prob += bias == -1 ? 15.0 : bias ==  1 ? -10.0 : 0.0
        prob += rsiVal < 45 ? 10.0 : rsiVal > 55 ? -8.0 : 0.0
        prob += close < ema21 ?  8.0 : -4.0
        prob += distScore
        prob += math.min(touches, 4) * 3.0
        prob += volStrong ? 8.0 : 0.0
        prob += f_rejectionAtSupport(_level, tol) ? -15.0 : 0.0
    math.max(5.0, math.min(95.0, prob))

// =========================
// Pivot add / update  ※ time を記録
// =========================
f_addOrUpdatePivot(_t, _price, _isHigh) =>
    bool changed = false
    int n = array.size(pivotTimes)
    if n == 0
        array.push(pivotTimes,  _t)
        array.push(pivotPrices, _price)
        array.push(pivotIsHigh, _isHigh)
        changed := true
    else
        bool  lastIsHigh = array.get(pivotIsHigh, n - 1)
        float lastPrice  = array.get(pivotPrices, n - 1)
        if lastIsHigh == _isHigh
            bool more = _isHigh ? _price > lastPrice : _price < lastPrice
            if more
                array.set(pivotTimes,  n - 1, _t)
                array.set(pivotPrices, n - 1, _price)
                changed := true
        else
            array.push(pivotTimes,  _t)
            array.push(pivotPrices, _price)
            array.push(pivotIsHigh, _isHigh)
            changed := true
    changed

// =========================
// Pivot Detection
// =========================
ph = ta.pivothigh(high, depth, depth)
pl = ta.pivotlow(low,  depth, depth)

// ピボット確定時のタイムスタンプ (depth本前のバーのtime)
int pivotTime = time[depth]

bool zzChanged = false
if not na(ph)
    zzChanged := f_addOrUpdatePivot(pivotTime, ph, true)  or zzChanged
if not na(pl)
    zzChanged := f_addOrUpdatePivot(pivotTime, pl, false) or zzChanged

// =========================
// Rebuild ZigZag — inline, xloc.bar_time
// =========================
if zzChanged
    for l  in zzLines
        line.delete(l)
    for lb in zzLabels
        label.delete(lb)
    array.clear(zzLines)
    array.clear(zzLabels)

    int n = array.size(pivotTimes)

    if n >= 2
        for i = 1 to n - 1
            int   t1 = array.get(pivotTimes,  i - 1)
            int   t2 = array.get(pivotTimes,  i)
            float p1 = array.get(pivotPrices, i - 1)
            float p2 = array.get(pivotPrices, i)
            color c  = p2 >= p1 ? zzUpColor : zzDownColor
            array.push(zzLines, line.new(t1, p1, t2, p2,
                 xloc=xloc.bar_time, color=c, width=zzWidth))

    if n >= 1
        for i = 0 to n - 1
            int   t   = array.get(pivotTimes,  i)
            float p   = array.get(pivotPrices, i)
            bool  isH = array.get(pivotIsHigh, i)
            color bg  = isH ? zzDownColor : zzUpColor
            array.push(zzLabels, label.new(
                 t, p, f_pivotText(i),
                 xloc=xloc.bar_time,
                 style=isH ? label.style_label_down : label.style_label_up,
                 textcolor=labelTextColor, color=bg, size=size.tiny))

// =========================
// Active Leg — xloc.bar_time
// =========================
if showActiveLeg and array.size(pivotTimes) > 0
    line.delete(activeLeg)
    int   at_ = array.get(pivotTimes,  array.size(pivotTimes)  - 1)
    float ap  = array.get(pivotPrices, array.size(pivotPrices) - 1)
    color ac  = close >= ap ? zzUpColor : zzDownColor
    activeLeg := line.new(at_, ap, time, close,
         xloc=xloc.bar_time, color=color.new(ac, 35), width=1, style=line.style_dashed)

// =========================
// Prediction Lines — xloc.bar_time
// 右端はバー数ではなくタイムオフセットで延長
// =========================
int nPivots  = array.size(pivotTimes)

// 1バー分のミリ秒幅を推定 (timeframe.in_seconds * 1000)
int msPerBar = timeframe.in_seconds() * 1000
int extMs    = msPerBar * levelExtendBars   // 延長幅をmsに変換

// ラインは pivot 確定時のみ再描画、ラベルは毎バー再計算して右上テーブルと一致させる
if zzChanged
    line.delete(lvlLine1)
    line.delete(lvlLine2)
    lvlLine1 := na
    lvlLine2 := na

    if nPivots >= 2 and showLevelLines
        int   idx1 = nPivots - 2
        int   t1   = array.get(pivotTimes,  idx1)
        float p1   = array.get(pivotPrices, idx1)
        bool  ih1  = array.get(pivotIsHigh, idx1)
        color lc1  = ih1 ? color.new(color.red, 0) : color.new(color.aqua, 0)
        lvlLine1 := line.new(t1, p1, time + extMs, p1,
             xloc=xloc.bar_time, extend=extend.none,
             color=lc1, width=2, style=line.style_dotted)

    if nPivots >= 3 and showLevelLines
        int   idx2 = nPivots - 3
        int   t2   = array.get(pivotTimes,  idx2)
        float p2   = array.get(pivotPrices, idx2)
        bool  ih2  = array.get(pivotIsHigh, idx2)
        color lc2  = ih2 ? color.new(color.red, 0) : color.new(color.aqua, 0)
        lvlLine2 := line.new(t2, p2, time + extMs, p2,
             xloc=xloc.bar_time, extend=extend.none,
             color=lc2, width=2, style=line.style_dotted)

// ラインの右端を毎バー延長（zzChangedと独立して更新）
if not na(lvlLine1)
    line.set_x2(lvlLine1, time + extMs)
if not na(lvlLine2)
    line.set_x2(lvlLine2, time + extMs)

// 確率ラベルは毎バー再計算
label.delete(probLbl1)
label.delete(probLbl2)
probLbl1 := na
probLbl2 := na

if nPivots >= 2 and showProbability
    float p1   = array.get(pivotPrices, nPivots - 2)
    bool  ih1  = array.get(pivotIsHigh, nPivots - 2)
    float bp1  = f_breakProbability(p1, ih1)
    float bnp1 = 100.0 - bp1
    string t1s = ih1
         ? "Line 1  上抜け " + str.tostring(math.round(bp1))  + "% / 反落 " + str.tostring(math.round(bnp1)) + "%"
         : "Line 1  下抜け " + str.tostring(math.round(bp1))  + "% / 反発 " + str.tostring(math.round(bnp1)) + "%"
    color bg1  = bp1 >= 70 ? color.new(color.red, 0) : bp1 >= 55 ? color.new(color.orange, 0) : color.new(color.gray, 15)
    probLbl1 := label.new(time + extMs, p1, t1s,
         xloc=xloc.bar_time, style=label.style_label_left,
         textcolor=color.white, color=bg1, size=size.small)

if nPivots >= 3 and showProbability
    float p2   = array.get(pivotPrices, nPivots - 3)
    bool  ih2  = array.get(pivotIsHigh, nPivots - 3)
    float bp2  = f_breakProbability(p2, ih2)
    float bnp2 = 100.0 - bp2
    string t2s = ih2
         ? "Line 2  上抜け " + str.tostring(math.round(bp2))  + "% / 反落 " + str.tostring(math.round(bnp2)) + "%"
         : "Line 2  下抜け " + str.tostring(math.round(bp2))  + "% / 反発 " + str.tostring(math.round(bnp2)) + "%"
    color bg2  = bp2 >= 70 ? color.new(color.red, 0) : bp2 >= 55 ? color.new(color.orange, 0) : color.new(color.gray, 15)
    probLbl2 := label.new(time + extMs, p2, t2s,
         xloc=xloc.bar_time, style=label.style_label_left,
         textcolor=color.white, color=bg2, size=size.small)

// =========================
// 右上テーブル: Line1 / Line2 の抜け・反発確率
// =========================
var table probTable = table.new(position.top_right, 4, 3,
     bgcolor=color.new(color.black, 60),
     border_color=color.new(color.gray, 40), border_width=1,
     frame_color=color.new(color.gray, 20), frame_width=1)

if barstate.islast
    // ヘッダー行
    table.cell(probTable, 0, 0, "",        bgcolor=color.new(color.gray, 55), text_color=color.white, text_size=size.small)
    table.cell(probTable, 1, 0, "レベル",  bgcolor=color.new(color.gray, 55), text_color=color.white, text_size=size.small)
    table.cell(probTable, 2, 0, "抜け %",  bgcolor=color.new(color.gray, 55), text_color=color.new(color.orange, 0), text_size=size.small)
    table.cell(probTable, 3, 0, "反発 %",  bgcolor=color.new(color.gray, 55), text_color=color.new(color.aqua, 0),   text_size=size.small)

    // Line 1
    if nPivots >= 2
        float lv1   = array.get(pivotPrices, nPivots - 2)
        bool  ih1   = array.get(pivotIsHigh, nPivots - 2)
        float brk1  = f_breakProbability(lv1, ih1)
        float bnc1  = 100.0 - brk1
        string kind1 = ih1 ? "抵抗" : "支持"
        color  brkCol1 = brk1 >= 70 ? color.new(color.red, 0) : brk1 >= 55 ? color.new(color.orange, 0) : color.new(color.gray, 20)
        color  bncCol1 = bnc1 >= 70 ? color.new(#26A69A, 0)   : bnc1 >= 55 ? color.new(color.aqua, 0)   : color.new(color.gray, 20)
        table.cell(probTable, 0, 1, "Line 1 (" + kind1 + ")",
             bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
        table.cell(probTable, 1, 1, str.tostring(lv1, format.mintick),
             bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
        table.cell(probTable, 2, 1, str.tostring(math.round(brk1)) + "%",
             bgcolor=brkCol1, text_color=color.white, text_size=size.small)
        table.cell(probTable, 3, 1, str.tostring(math.round(bnc1)) + "%",
             bgcolor=bncCol1, text_color=color.white, text_size=size.small)

    // Line 2
    if nPivots >= 3
        float lv2   = array.get(pivotPrices, nPivots - 3)
        bool  ih2   = array.get(pivotIsHigh, nPivots - 3)
        float brk2  = f_breakProbability(lv2, ih2)
        float bnc2  = 100.0 - brk2
        string kind2 = ih2 ? "抵抗" : "支持"
        color  brkCol2 = brk2 >= 70 ? color.new(color.red, 0) : brk2 >= 55 ? color.new(color.orange, 0) : color.new(color.gray, 20)
        color  bncCol2 = bnc2 >= 70 ? color.new(#26A69A, 0)   : bnc2 >= 55 ? color.new(color.aqua, 0)   : color.new(color.gray, 20)
        table.cell(probTable, 0, 2, "Line 2 (" + kind2 + ")",
             bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
        table.cell(probTable, 1, 2, str.tostring(lv2, format.mintick),
             bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)
        table.cell(probTable, 2, 2, str.tostring(math.round(brk2)) + "%",
             bgcolor=brkCol2, text_color=color.white, text_size=size.small)
        table.cell(probTable, 3, 2, str.tostring(math.round(bnc2)) + "%",
             bgcolor=bncCol2, text_color=color.white, text_size=size.small)

// =========================
// Alerts
// =========================
float level1 = nPivots >= 2 ? array.get(pivotPrices, nPivots - 2) : na
float level2 = nPivots >= 3 ? array.get(pivotPrices, nPivots - 3) : na

bool cross_above_l1 = ta.crossover(close,  level1)
bool cross_below_l1 = ta.crossunder(close, level1)
bool cross_above_l2 = ta.crossover(close,  level2)
bool cross_below_l2 = ta.crossunder(close, level2)

alertcondition(not na(level1) and cross_above_l1, "Cross Above Line 1", "Price crossed above prediction line 1")
alertcondition(not na(level1) and cross_below_l1, "Cross Below Line 1", "Price crossed below prediction line 1")
alertcondition(not na(level2) and cross_above_l2, "Cross Above Line 2", "Price crossed above prediction line 2")
alertcondition(not na(level2) and cross_below_l2, "Cross Below Line 2", "Price crossed below prediction line 2")
````
