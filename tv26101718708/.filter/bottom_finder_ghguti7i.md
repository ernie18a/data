# Bottom Finder

- url: https://www.tradingview.com/script/GHGUTi7i/
- type: indicator
- pine_id: PUB;790fae26e2b54f18a271a228e3597a04
- version: 2.0

## Description

・条件の収集：
高値からの調整率、
ボラティリティ（値動きの幅）、
出来高、
移動平均線、
RSI（買われ過ぎ売られ過ぎを測る指標）など、
底打ちにつながる複数の条件を、
銘柄ごとに同時に監視します。

・点数化（スコアリング）：
集めた条件を「底打ちにどれくらい近いか」という観点で重み付けし、
0〜100点の総合スコアに変換します。

・3段階の見える化：
①背景が薄緑＝底値ゾーン（仕込みの場）
②緑のラベル＝底値サイン点灯（買い候補）
③スコア表示＝接近度、この3つで画面に出します。

## Source Code

````pine
//@version=6

indicator(title = "Bottom Finder",
          shorttitle = "底値ツール",
          overlay = true,
          max_labels_count = 100,
          max_lines_count = 50,
          max_boxes_count = 50)

// ─────────────────────────────────────────────
// 入力パラメータ
// ─────────────────────────────────────────────

grp1 = "■ 下落確認フィルター"
lookbackHigh   = input.int(252, "高値を見にいく日数（日足）", minval = 60, maxval = 500, group = grp1)
declinePctMin  = input.float(30.0, "高値からの最低調整率（％）", minval = 10, maxval = 80, step = 1, group = grp1)
lookbackLow    = input.int(90, "最安値を見にいく日数（戻し除外）", minval = 30, maxval = 250, group = grp1)
risenPctMax    = input.float(40.0, "最安値からの最大戻り率（％）", minval = 5, maxval = 80, step = 1, group = grp1, tooltip = "デフォルト40％。きつくしたいなら25％。")

grp2 = "■ 底値ゾーン形成フィルター"
atrShort       = input.int(20, "短期ATR本数", minval = 5, maxval = 60, group = grp2)
atrLong        = input.int(60, "比較用 長期ATR本数", minval = 20, maxval = 200, group = grp2)
atrShrinkRatio = input.float(0.85, "ボラ収縮しきい値", minval = 0.3, maxval = 1.0, step = 0.05, group = grp2, tooltip = "デフォルト0.85（15%縮んだ感覚）。きつくしたいなら0.75。")
volShort       = input.int(20, "短期出来高平均本数", minval = 5, maxval = 60, group = grp2)
volLong        = input.int(60, "比較用 長期出来高平均", minval = 20, maxval = 200, group = grp2)
volDryRatio    = input.float(0.85, "出来高枯渇しきい値", minval = 0.3, maxval = 1.0, step = 0.05, group = grp2, tooltip = "デフォルト0.85。きつくしたいなら0.70。")
zoneMode       = input.string("OR(ゆるい)", "ゾーン判定モード", options = ["OR(ゆるい)", "AND(きつい)"], group = grp2, tooltip = "ボラ収縮と出来高枯渇を、どちらか1つでゾーン入り(OR)、両方必要(AND)。デフォルトOR。")

grp3 = "■ 反転シグナル発火フィルター"
maLen          = input.int(20, "上抜きを見る移動平均", minval = 5, maxval = 60, group = grp3)
volSpikeMult   = input.float(1.2, "出来高急増の倍率", minval = 1.0, maxval = 5.0, step = 0.1, group = grp3, tooltip = "デフォルト1.2倍。")
rsiLen         = input.int(14, "RSIの長さ", minval = 5, maxval = 30, group = grp3)
rsiOversold    = input.float(40.0, "RSI買われ過ぎ脱出ライン", minval = 20, maxval = 50, step = 1, group = grp3, tooltip = "デフォルト40。")
confirmBars    = input.int(5, "条件成立を見るバー数（緩和窓）", minval = 1, maxval = 15, group = grp3, tooltip = "1=当日のみ、3=きつめ、5=デフォルト、7以上=ゆるめ。")

grp4 = "■ 表示設定"
showZone       = input.bool(true, "底値ゾーンを背景で塗る", group = grp4)
showPanel      = input.bool(true, "右上に情報パネルを表示", group = grp4)
showTargets    = input.bool(true, "利確目標ラインを描画", group = grp4)
showMA         = input.bool(true, "移動平均線を表示", group = grp4)
labelText      = input.string("底値サイン", "ラベル文言", group = grp4)

grp5 = "■ 利確目標"
tp1Pct         = input.float(50.0, "利確目標①（高値までの戻し％）", minval = 10, maxval = 100, step = 5, group = grp5)
tp2Pct         = input.float(100.0, "利確目標②（高値までの戻し％）", minval = 50, maxval = 200, step = 5, group = grp5)

// ─────────────────────────────────────────────
// 計算
// ─────────────────────────────────────────────

periodHigh   = ta.highest(high, lookbackHigh)
periodLow    = ta.lowest(low, lookbackHigh)
declinePct   = (periodHigh - close) / periodHigh * 100.0

recentLow    = ta.lowest(low, lookbackLow)
risenPct     = recentLow > 0 ? (close - recentLow) / recentLow * 100.0 : 0
notTooRisen  = risenPct <= risenPctMax

filter1      = declinePct >= declinePctMin and notTooRisen

atrS         = ta.atr(atrShort)
atrL         = ta.atr(atrLong)
atrRatio     = atrL > 0 ? atrS / atrL : 1.0
volShrink    = atrRatio <= atrShrinkRatio

volS         = ta.sma(volume, volShort)
volL         = ta.sma(volume, volLong)
volRatio     = volL > 0 ? volS / volL : 1.0
volDried     = volRatio <= volDryRatio

filter2      = zoneMode == "AND(きつい)" ? (volShrink and volDried) : (volShrink or volDried)
inBottomZone = filter1 and filter2

// 反転シグナル（緩和窓 confirmBars 内で各条件が起きていればOK）
ma20         = ta.sma(close, maLen)
maCrossUp    = ta.crossover(close, ma20)
volSpike     = volume >= volL * volSpikeMult
bullishBar   = close > open
rsi          = ta.rsi(close, rsiLen)
rsiCrossUp   = ta.crossover(rsi, rsiOversold)

maCrossUpRecent  = ta.barssince(maCrossUp) <= confirmBars
volSpikeRecent   = ta.barssince(volSpike) <= confirmBars
rsiCrossUpRecent = ta.barssince(rsiCrossUp) <= math.max(confirmBars + 2, 5)

filter3      = maCrossUpRecent and volSpikeRecent and bullishBar and rsiCrossUpRecent

bottomSignal = filter1 and filter2 and filter3

scoreDecline = math.min(declinePct / declinePctMin, 1.0) * 25
scoreAtr     = math.min((atrShrinkRatio / math.max(atrRatio, 0.01)), 1.0) * 25
scoreVol     = math.min((volDryRatio / math.max(volRatio, 0.01)), 1.0) * 25
scoreRsi     = rsi <= 50 ? (50 - rsi) / 50 * 25 : 0
totalScore   = math.round(scoreDecline + scoreAtr + scoreVol + scoreRsi)

// ─────────────────────────────────────────────
// 描画
// ─────────────────────────────────────────────

plot(showMA ? ma20 : na, "20日移動平均", color = color.new(color.orange, 0), linewidth = 1)

bgcolor(showZone and inBottomZone ? color.new(color.green, 88) : na, title = "底値ゾーン")

if bottomSignal
    label.new(x = bar_index, y = low,
              text = labelText + "\n score:" + str.tostring(totalScore),
              style = label.style_label_up,
              color = color.new(color.green, 0),
              textcolor = color.white,
              size = size.normal)

var line tp1Line = na
var line tp2Line = na
var label tp1Lab = na
var label tp2Lab = na

if bottomSignal and showTargets
    declineSize = periodHigh - close
    tp1Price = close + declineSize * (tp1Pct / 100.0)
    tp2Price = close + declineSize * (tp2Pct / 100.0)

    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp1Lab)
        label.delete(tp1Lab)
    if not na(tp2Lab)
        label.delete(tp2Lab)

    tp1Line := line.new(x1 = bar_index, y1 = tp1Price,
                        x2 = bar_index + 30, y2 = tp1Price,
                        color = color.new(color.aqua, 0), width = 2, style = line.style_dashed)
    tp2Line := line.new(x1 = bar_index, y1 = tp2Price,
                        x2 = bar_index + 30, y2 = tp2Price,
                        color = color.new(color.fuchsia, 0), width = 2, style = line.style_dashed)
    tp1Lab  := label.new(x = bar_index + 30, y = tp1Price,
                         text = "利確① " + str.tostring(math.round_to_mintick(tp1Price)),
                         style = label.style_label_left,
                         color = color.new(color.aqua, 30),
                         textcolor = color.white, size = size.small)
    tp2Lab  := label.new(x = bar_index + 30, y = tp2Price,
                         text = "利確② " + str.tostring(math.round_to_mintick(tp2Price)),
                         style = label.style_label_left,
                         color = color.new(color.fuchsia, 30),
                         textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────
// 情報パネル（右上）
// ─────────────────────────────────────────────
labelBg     = color.new(#1F2937, 0)
okBg        = color.new(#16A34A, 0)
warnBg      = color.new(#EA580C, 0)
ngBg        = color.new(#9CA3AF, 0)
badBg       = color.new(#DC2626, 0)
headerBg    = color.new(#0B1E3F, 0)

var table panel = table.new(position.top_right, 2, 7, border_width = 1, frame_color = color.black, frame_width = 1)
if showPanel and barstate.islast
    table.cell(panel, 0, 0, "Roger's 底値ツール", bgcolor = headerBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 0, "状態", bgcolor = headerBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 1, " 高値からの調整率 ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 1, " " + str.tostring(math.round(declinePct, 1)) + "% ",
               bgcolor = declinePct >= declinePctMin ? okBg : ngBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 2, " 最安値からの戻り率 ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 2, " " + str.tostring(math.round(risenPct, 1)) + "% ",
               bgcolor = notTooRisen ? okBg : badBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 3, " ボラ収縮(短期÷長期ATR) ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 3, " " + str.tostring(math.round(atrRatio, 2)) + " ",
               bgcolor = volShrink ? okBg : ngBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 4, " 出来高枯渇(短期÷長期) ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 4, " " + str.tostring(math.round(volRatio, 2)) + " ",
               bgcolor = volDried ? okBg : ngBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 5, " 底値ゾーン入り ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 5, " " + (inBottomZone ? "YES" : "NO") + " ",
               bgcolor = inBottomZone ? okBg : ngBg, text_color = color.white, text_size = size.large)

    table.cell(panel, 0, 6, " 総合スコア(0-100) ", bgcolor = labelBg, text_color = color.white, text_size = size.large)
    table.cell(panel, 1, 6, " " + str.tostring(totalScore) + " ",
               bgcolor = totalScore >= 75 ? okBg : totalScore >= 50 ? warnBg : ngBg, text_color = color.white, text_size = size.large)

// ─────────────────────────────────────────────
// アラート
// ─────────────────────────────────────────────
alertcondition(bottomSignal,
               title = "底値サイン点灯",
               message = "{{ticker}} に底値サインが点灯しました(スコア表示は画面で確認)。")
alertcondition(inBottomZone and not inBottomZone[1],
               title = "底値ゾーン入り",
               message = "{{ticker}} が底値ゾーンに入りました。反転発火を待ってください。")
````
