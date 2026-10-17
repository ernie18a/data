# Historical Pattern Overlay [ShigemiQuant]

- url: https://www.tradingview.com/script/FzexGo4M-Historical-Pattern-Overlay-ShigemiQuant/
- type: indicator
- pine_id: PUB;2a07e1f65e1b49e19197cb0d433842e8
- version: 1.0

## Description

[b]Historical Pattern Overlay[/b] searches the chart's own past for the single bar window whose shape best resembles the most recent N bars, then redraws that historical window — and the bars that came after it — directly over your current price. It is a pure shape-similarity overlay paired with a long-run continuation statistic, not a single extrapolated line and not a signal generator.

Most analogue tools on TradingView either draw one extrapolated line, or render an oscillator-style probability. This indicator does neither. It pins the actual historical shape onto the present, then attaches a separate, statistically-defined number that tells you how often, in this chart's own history, that kind of analogue has continued in the same direction. The visual and the statistic are independent by design — you read the shape with your eyes, and you read the continuation evidence as a number.

───────────────

[b]Why this combination[/b]

A pure similarity search can find a past window that looks very much like the present, but the visual match alone does not tell you whether such matches have historically led anywhere. A pure rate statistic, on the other hand, hides the shape — you cannot see whether the analogue is a clean impulse, a choppy range, or a failed breakout. This script joins the two because each one corrects the weakness of the other:

[list]
[*]The overlay shows you [b]what[/b] the closest historical analogue actually looked like, bar by bar, on the same price axis as the live chart.
[*]The Continuation Rate table shows you [b]how often[/b], across all resolved analogues this chart has produced, the projection direction agreed with the realised move.
[/list]

Neither layer alone would be enough. Together they form a self-contained read of "this is the closest past analogue, and here is the historical base rate for analogues like it".

───────────────

[b]What it does[/b]

[list]
[*]Takes the most recent [i]Lookback Window[/i] closes and treats them as the reference shape.
[*]Scans up to [i]History Scan Depth[/i] bars further back (up to 5000) for the window whose normalised shape has the smallest squared-distance to the reference.
[*]Selects the single best historical match (Top 1).
[*]Draws that historical window as a polyline rebased to the live price axis, ending exactly at the current bar.
[*]Extends the drawing to the right of the current bar by [i]Projection Length[/i] bars, using the actual bars that came after the historical match.
[*]Stamps a similarity label at the right edge of the projection (e.g. [i]Top1 87.5%[/i]).
[*]On every confirmed bar, records a snapshot of the direction implied by the projection and resolves it after [i]Projection Length[/i] bars by comparing against the realised move, then reports the running statistic in the [b]Continuation Rate[/b] table.
[/list]

───────────────

[b]Originality[/b]

[list]
[*][b]Shape on shape, not line on line.[/b] Other analogue overlays usually compress the matched window into a single extrapolated curve. Historical Pattern Overlay preserves the full bar-by-bar shape of the historical window and the bars that followed it, redrawn on the live price axis. The visual is the raw analogue, not a smoothed approximation.
[*][b]Rebase to the live axis.[/b] The historical match is automatically scaled so its last close coincides with the current close. You can read the analogue in the same dollar / pip units as the live chart, with no manual chart arithmetic.
[*][b]Statistic is retrospective.[/b] The Continuation Rate is a [i]historical base rate[/i] computed from snapshots taken on this very chart. It does not claim to estimate future probability; it reports the share of past resolved analogues in which the projection's sign matched the realised return.
[*][b]Top 1 only, by design.[/b] Showing several analogues at once tends to produce a fan of conflicting directions and visually defeats the analogue idea. This Lite build commits to a single best analogue so that the overlay is unambiguous; the statistical layer then carries the uncertainty signal numerically.
[/list]

───────────────

[b]How it does it[/b]

[list]
[*][b]Reference window[/b] — the most recent [i]Lookback Window[/i] closes are normalised so the oldest bar in the window is 100. This removes the absolute price level and leaves only the shape.
[*][b]Distance metric[/b] — for every candidate window in the historical scan range, the same normalisation is applied and a squared-distance sum (sum of squared differences between the two normalised series, point by point) is computed. The candidate with the lowest squared distance wins.
[*][b]Scan range[/b] — the most recent eligible candidate ends [i]Lookback + Projection[/i] bars in the past (so the bars after the match exist and can be drawn forward). The oldest eligible candidate is [i]History Scan Depth[/i] bars further back, subject to the chart's available history.
[*][b]Min Gap[/b] — a minimum bar gap between candidate centres is enforced. In a single-match (Top 1) build, this primarily reserves room for future multi-match extensions; structurally it is kept active.
[*][b]Rebase[/b] — once the winning historical window is picked, its last close is mapped to the current bar's close and every other bar in the historical window is multiplied by the same scale factor. This keeps the analogue readable in the same axis as the live price without distorting its shape.
[*][b]Similarity score[/b] — the squared distance is converted to a percentage in the 0–100 range via [i]max(0, 100 − (distance / sqrt(Lookback)) × 5)[/i], shown on the projection's right edge.
[*][b]Continuation Rate[/b] — on every confirmed bar, a snapshot stores the implied direction ([i]+1[/i] if the projection ends higher than current close, [i]−1[/i] if lower) and the implied magnitude. After [i]Projection Length[/i] bars have elapsed, the snapshot resolves: it compares the realised return over those bars against the implied direction and counts as a hit when the signs agree. The table then reports total resolved, pending, hit rate, mean realised return, and mean absolute error of the implied magnitude.
[*][b]No look-ahead.[/b] All heavy work is gated by [i]barstate.islast[/i] for drawing and [i]barstate.isconfirmed[/i] for snapshot writes. Snapshots are taken on a bar only after that bar has closed, and resolved only when [i]Projection Length[/i] additional confirmed bars exist after it.
[/list]

───────────────

[b]How to use[/b]

[list=1]
[*]Add the indicator to any chart and any timeframe. The defaults (Lookback 50, Projection 20, Scan Depth 3000) are a balanced starting point for intraday and swing work.
[*]Let the chart load enough history that the right side of the scan range is populated. On very short charts the analogue overlay will appear close to the current bar; on long histories it can sit far to the left.
[*]Read the overlay first. The thin coloured line on the left half of the chart is the historical analogue; the thicker line to the right of the current bar is the same analogue's [i]own[/i] subsequent bars, redrawn on the live axis.
[*]Read the [b]Top1 XX.X%[/b] label at the right edge of the projection. Values close to 100% mean the historical shape sits very close to the present shape in normalised-distance terms.
[*]Open the [b]Continuation Rate[/b] table (top-right by default). Wait for the [i]Resolved[/i] count to reach [i]Min Resolved Samples[/i] (default 10) before reading the numeric rate. Below that threshold the table shows [i]Insufficient samples[/i] to discourage reading noise.
[*]Once enough samples exist, treat Continuation Rate >= 50% as the minimum threshold for "this chart's analogues have continued in the projection's direction more often than not". Treat [i]Mean Return[/i] as the average realised move size and [i]MAE[/i] as the average absolute discrepancy between the implied magnitude and the realised one.
[*]Use the overlay as context, not as a trigger. The projection is a redrawn historical sequence, not an order or a target. Combine with your own entry method, position sizing, and stop placement.
[/list]

───────────────

[b]Inputs reference[/b]

[list]
[*][b]Lookback Window[/b] (default 50, range 10–100) — number of recent bars used as the reference shape.
[*][b]Projection Length[/b] (default 20, range 5–30) — number of bars drawn to the right of the current bar, taken from the bars that followed the historical match.
[*][b]History Scan Depth[/b] (default 3000, range 500–5000) — maximum number of historical bars to scan for candidate windows.
[*][b]Min Gap Between Matches[/b] (default 50, minimum 1) — minimum bar distance between selected match centres.
[*][b]Top1 Color[/b] (default orange) — colour of the overlay polyline and the projection lines.
[*][b]Show Similarity Label[/b] (default On) — toggles the [i]Top1 XX.X%[/i] label at the projection's right edge.
[*][b]Show Continuation Rate Table[/b] (default On) — toggles the statistics table.
[*][b]Table Position[/b] (default Top Right) — six positions: Top/Middle/Bottom × Left/Right.
[*][b]History Size (snapshots)[/b] (default 100, range 10–500) — maximum number of snapshots retained in FIFO order.
[*][b]Table Text Size[/b] (default Small) — Tiny / Small / Normal.
[*][b]Min Resolved Samples[/b] (default 10, range 5–50) — sample-count floor below which the table shows [i]Insufficient samples[/i] instead of a number.
[/list]

───────────────

[b]Reading the Continuation Rate table[/b]

[list]
[*][b]Resolved[/b] — number of snapshots whose [i]Projection Length[/i] follow-up window has fully elapsed.
[*][b]Pending[/b] — number of snapshots still inside their follow-up window.
[*][b]Continuation Rate[/b] — share of resolved snapshots where the projection's sign matched the realised return's sign. Coloured green when >= 50%, orange when below. Reads [i]Insufficient samples (N<…)[/i] until [i]Resolved[/i] reaches [i]Min Resolved Samples[/i].
[*][b]Mean Return[/b] — average realised return over the resolved follow-up windows.
[*][b]MAE[/b] — mean absolute error between the implied magnitude (projection's final return implied by the historical match) and the realised return.
[*][b]Disclaimer line[/b] — [i]Retrospective only, no future guarantee.[/i]
[/list]

───────────────

[b]Limitations[/b]

[list]
[*]The shape search is based on squared-distance over normalised closes. It does not consider volume, volatility regime, session, macroeconomic context, or any cross-chart signal. Two windows can match very closely in shape while sitting in completely different market regimes.
[*]The Continuation Rate is computed from snapshots accumulated during the current session of the chart. Reloading the chart, switching timeframes, or changing inputs resets the snapshot history; the rate will need time to rebuild.
[*]Pine has a maximum lookback of 5000 bars; the scan cannot reach beyond that boundary.
[*]The rebase keeps the analogue readable on the live axis but does not adjust for differences in volatility scale between the historical period and now. A historical move drawn at the same vertical distance can correspond to a very different percentage move in absolute terms.
[*]A high similarity percentage means the shapes are close in normalised-distance terms only. It does not imply that the same outcome will repeat.
[/list]

───────────────

[b]Disclaimer[/b]

This indicator is a retrospective visualisation and statistic tool. It does not place orders, does not estimate future returns, and does not guarantee any outcome. The overlay shows what the closest historical analogue on this chart actually did, and the table reports how often past analogues continued in their projection's direction. Past behaviour does not indicate future results. Trade decisions, position sizing, and risk acceptance remain entirely the user's responsibility. Always combine with your own analysis and proper risk management.

By ShigemiQuant.

## Source Code

````pine
// @version=6
// Historical Pattern Overlay (HPO) Lite v1
// =============================================================================
// Historical Pattern Overlay [ShigemiQuant] — Lite v1
// 作成日: 2026-05-19
// Base: HPO_Pro_v2.0_phase3_hotfix6.pine (949 lines, complete)
// Approach: 機械的減算 (再設計ではない)。Pro 完成済資産から以下を削除:
//   1. Top N 多段 (Top 1 固定化、Pro: 1-5 → Lite: 1)
//   2. クロスシンボル探索 (self picked のみに簡素化)
//   3. セッション・タイムゾーン絞り込み
//   4. マクロイベント除外
//   5. 信頼区間バンド (±σ レンジ)
//   6. アラート 3 種
// 残す機能:
//   - 同一銘柄 Top 1 マッチング (self picked)
//   - Continuation Rate テーブル (Top 1 専用集計、6 ポジ選択)
//   - 過去 polyline + 中継 line + 未来 line 描画 (ATR Plotter 流: bar_index ベース)
//   - rebase ロジック、類似度% 算出
// 設計思想 (絶対):
//   Top 1 固定 = Top N 散乱 (複数候補が異方向に発散して「予測力なしに見える」問題) の構造的回避
//   Continuation Rate テーブル = 「予測ではなく統計」を視覚的に成立させる核機能
// 制限値変更 (Pro → Lite):
//   Lookback max: 300 → 100 (default 50)
//   Projection max: 50 → 30  (default 20)
// =============================================================================

indicator("Historical Pattern Overlay [ShigemiQuant]", "HPO", overlay = true, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 100, max_bars_back = 5000)

// UDT Snapshot 型 (Continuation Rate トラッキング用)
// anchor 時の bar_index/close と target bar 到達後の resolve 状態を保持
type Snapshot
    int   anchorBarIndex
    float baselinePrice
    int   forecastDir      // +1 / -1 / 0
    float forecastMag      // forecastLen 後の予測倍率 (1.0 基準)
    int   targetBarIndex   // anchorBarIndex + forecastLen
    bool  resolved
    float actualReturn     // 実測リターン (resolved 時のみ有効)

// ---- Inputs --------------------------------------------------------------
// 計算量は Lookback * History Scan Depth に比例するため、最大値は Pro よりさらに控えめに固定
lookback     = input.int(50,   "Lookback Window",         minval = 10,  maxval = 100,   tooltip = "Reference window length. The most recent N close-price bars are used as the pattern to compare against history.")
forecastLen  = input.int(20,   "Projection Length",       minval = 5,   maxval = 30,    tooltip = "Number of bars to overlay after the historical match as a projection path to the right of the current bar.")
scanDepth    = input.int(3000, "History Scan Depth",      minval = 500, maxval = 5000,  tooltip = "Maximum number of historical bars to scan. Larger values improve precision but increase compute load.")
minGap       = input.int(50,   "Min Gap Between Matches", minval = 1,                   tooltip = "Duplicate-match exclusion gap. Any candidate within N bars of an already selected match center is skipped (a value close to Lookback is recommended).")

color1       = input.color(color.orange, "Top1 Color")
showLabel    = input.bool(true, "Show Similarity Label", tooltip = "Show the similarity percentage label at the right edge of the projected match.")

// Continuation Rate テーブル (核機能、6 ポジ選択)
showStats        = input.bool(true,    "Show Continuation Rate Table",                       group = "Statistics", tooltip = "Show the historical Top 1 match continuation rate table on the chart.")
statsTablePos    = input.string("Top Right", "Table Position", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = "Statistics", tooltip = "Position of the Continuation Rate table on the chart.")
statsHistorySize = input.int(100,      "History Size (snapshots)",   minval = 10, maxval = 500, group = "Statistics", tooltip = "Maximum number of Snapshot records retained in FIFO order.")
statsTableSize   = input.string("Small", "Table Text Size",          options = ["Tiny", "Small", "Normal"], group = "Statistics", tooltip = "Font size of the table text.")
minSamplesForStats = input.int(10,     "Min Resolved Samples",       minval = 5, maxval = 50, group = "Statistics", tooltip = "Until this many resolved samples accumulate, the table shows 'Insufficient samples' instead of a numeric value.")

// statsTableSize → size.* マップ (3 値ターナリで Pine v6 1 行制約に収める)
tblTextSize = statsTableSize == "Tiny" ? size.tiny : statsTableSize == "Normal" ? size.normal : size.small

// statsTablePos (string) → position.* (series string) マップ
// Pine v6 ローカルリファレンス drawing_utility_functions.md より table.new(position, ...) は series string を受ける
// var table の初回固定問題への補強として barstate.islast 内で毎回 table.set_position() を呼ぶ
tblPositionConst = switch statsTablePos
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Middle Left"  => position.middle_left
    "Middle Right" => position.middle_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    =>                position.top_right  // fallback (options で 6 値に閉じているが安全側)

// ---- Persistent draw object containers (ATR Plotter 流) -------------------
// var line[] / var polyline[] / var label[] パターン。bar_index ベース描画で縦軸スケール・
// ドラッグ・ズームに完全追随。毎バー全削除 → barstate.islast で再生成して固着を回避
var line[]     lineArr = array.new_line()
var polyline[] plArr   = array.new<polyline>()
var label[]    lblArr  = array.new_label()

// Snapshot FIFO + 統計テーブル (Continuation Rate)
// var table の position 引数は初回のみ評価されるが、Pine v6 では input 変更で再コンパイル
// 相当のためユーザ視点では正常動作する。さらに barstate.islast 内で table.set_position()
// を毎回呼んで動的切替を二重保険として確実化する
var array<Snapshot> snapshots = array.new<Snapshot>()
var table hitRateTable = table.new(tblPositionConst, 2, 7, border_width = 1)

// ---- Main: heavy work only on the last bar --------------------------------
// 過去走査は O(Lookback * scanDepth) で重いため barstate.islast 内に閉じ込める
if barstate.islast
    // 既存描画を全削除 (固着防止、ATR Plotter と同じ降順ループ)
    // Pine v6: for by は正必須。降順は from>to で自動 (Hotfix3 教訓)
    if array.size(lineArr) > 0
        for i = array.size(lineArr) - 1 to 0
            line.delete(array.get(lineArr, i))
        array.clear(lineArr)
    if array.size(plArr) > 0
        for i = array.size(plArr) - 1 to 0
            polyline.delete(array.get(plArr, i))
        array.clear(plArr)
    if array.size(lblArr) > 0
        for i = array.size(lblArr) - 1 to 0
            label.delete(array.get(lblArr, i))
        array.clear(lblArr)

    // ---- 基準ウィンドウ正規化 (初日 = 100) -------------------------------
    // 0 = 最新足、lookback-1 = 最古足。base[0]..base[lookback-1]
    float baseAnchor = close[lookback - 1]
    array<float> baseNorm = array.new<float>(lookback, na)
    if not na(baseAnchor) and baseAnchor != 0.0
        for i = 0 to lookback - 1
            array.set(baseNorm, i, close[i] / baseAnchor * 100.0)

    // ---- 過去走査 ------------------------------------------------------
    // 各候補ウィンドウは「右端 offset = e、左端 offset = e + lookback - 1」
    // 未来取得分 forecastLen バーを e の左側に確保するため最小 e = lookback + forecastLen
    int scanStart  = lookback + forecastLen           // 最も新しい候補の右端 offset
    int scanEndMax = scanStart + scanDepth - 1        // 最も古い候補の右端 offset
    int availableBars = bar_index                     // 利用可能なバー数 (0-indexed)
    int scanEnd    = math.min(scanEndMax, availableBars - (lookback - 1))

    // 候補の (offset, distance) を貯める並列配列
    array<int>   candOffsets = array.new<int>()
    array<float> candDists   = array.new<float>()

    // ---- 自シンボル走査 (Lite は self のみ、cross 削除) ----
    bool canScanSelf = scanEnd >= scanStart and not na(baseAnchor) and baseAnchor != 0.0
    if canScanSelf
        for e = scanStart to scanEnd
            // 距離計算 (SSD)
            float anchor = close[e + lookback - 1]
            if not na(anchor) and anchor != 0.0
                float dsum = 0.0
                bool  ok   = true
                for i = 0 to lookback - 1
                    float c = close[e + i]
                    if na(c)
                        ok := false
                        break
                    float n = c / anchor * 100.0
                    float b = array.get(baseNorm, i)
                    float d = n - b
                    dsum += d * d
                if ok
                    array.push(candOffsets, e)
                    array.push(candDists,   math.sqrt(dsum))

    // ---- Top 1 抽出 (重複除外: 既選択中心 ± minGap) ----
    // Lite は topN = 1 固定。topN 入力削除、ループ簡素化 (Top 1 のみ取得後即 break)
    int nCand = array.size(candOffsets)
    array<int>   picked     = array.new<int>()  // 採用 offset
    array<float> pickedDist = array.new<float>()

    if nCand > 0
        array<int> idxSorted = array.sort_indices(candDists, order.ascending)
        // Top 1 のみなので minGap 重複判定は事実上不要だが、構造保全のためロジック維持
        int taken = 0
        for k = 0 to array.size(idxSorted) - 1
            if taken >= 1  // topN = 1 固定
                break
            int ci = array.get(idxSorted, k)
            int eC = array.get(candOffsets, ci)
            int centerC = eC + lookback / 2
            bool conflict = false
            if array.size(picked) > 0
                for j = 0 to array.size(picked) - 1
                    int eP = array.get(picked, j)
                    int centerP = eP + lookback / 2
                    if math.abs(centerC - centerP) <= minGap
                        conflict := true
                        break
            if not conflict
                array.push(picked,     eC)
                array.push(pickedDist, array.get(candDists, ci))
                taken += 1

    int nPicked = array.size(picked)

    // ============================================================================
    // 描画: 過去 lookback 本 (基準ウィンドウ上に重ね) + 未来 forecastLen 本
    // ============================================================================
    // 距離→類似度% 変換: lookback で正規化。1 点平均 1% ズレを penalty 1 とみなす目安
    // similarity = max(0, 100 - (d / sqrt(lookback)) * 5)
    if nPicked > 0
        for r = 0 to nPicked - 1
            int eC   = array.get(picked, r)
            float dC = array.get(pickedDist, r)

            float matchLastClose = close[eC]
            float curClose = close
            if na(matchLastClose) or matchLastClose == 0.0 or na(curClose)
                continue

            // rebase 係数: マッチ最終値が現在 close に一致するようスケール
            float scale = curClose / matchLastClose

            color col = color1

            // ---- 過去部分: polyline 1 本 (フル解像度) ----
            // u = 0 → 最古、u = lookback-1 → 現在足
            array<chart.point> pastPts = array.new<chart.point>()
            bool broke = false
            for u = 0 to lookback - 1
                int xCur = bar_index - (lookback - 1) + u
                int mOff = eC + (lookback - 1) - u
                float mc = close[mOff]
                if na(mc)
                    broke := true
                    break
                float yCur = mc * scale
                array.push(pastPts, chart.point.from_index(xCur, yCur))

            // 過去 polyline 生成 + 最終点を prev に引き継ぎ
            float prevX = na
            float prevY = na
            bool  hasPrev = false
            if array.size(pastPts) >= 2
                polyline pl = polyline.new(pastPts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(col, 60), line_width = 1)
                array.push(plArr, pl)
            if array.size(pastPts) > 0
                chart.point lastPastPt = array.get(pastPts, array.size(pastPts) - 1)
                prevX := lastPastPt.index
                prevY := lastPastPt.price
                hasPrev := true

            // ---- 未来部分: 現在足の右側 ----
            float lastY = prevY
            int   lastX = int(prevX)
            if not broke
                for s = 1 to forecastLen
                    int fOff = eC - s
                    if fOff < 0
                        break
                    float fc = close[fOff]
                    if na(fc)
                        break
                    int xCur = bar_index + s
                    float yCur = fc * scale
                    if hasPrev
                        array.push(lineArr, line.new(int(prevX), prevY, xCur, yCur, color = col, width = 2))
                    prevX := xCur
                    prevY := yCur
                    hasPrev := true
                    lastX := xCur
                    lastY := yCur

            // ---- ラベル ----
            if showLabel and hasPrev
                float perPoint = dC / math.sqrt(lookback)
                float sim = math.max(0.0, 100.0 - perPoint * 5.0)
                string txt = "Top1 " + str.tostring(sim, "#.0") + "%"
                label lb = label.new(lastX, lastY, text = txt, style = label.style_label_left, color = col, textcolor = color.black, size = size.small)
                array.push(lblArr, lb)

    // ============================================================================
    // Continuation Rate トラッキング (Top 1 専用集計、Lite の核機能)
    // ============================================================================
    // Snapshot push: barstate.isconfirmed で realtime tick 重複防止
    if barstate.isconfirmed and nPicked >= 1
        int eC0 = array.get(picked, 0)
        float matchLastClose0 = close[eC0]
        float curClose0 = close
        if not na(matchLastClose0) and matchLastClose0 != 0.0 and not na(curClose0)
            float scale0 = curClose0 / matchLastClose0
            int fOff0 = eC0 - forecastLen
            if fOff0 >= 0
                float fc0 = close[fOff0]
                if not na(fc0)
                    float forecastPx0  = fc0 * scale0
                    float forecastMag0 = forecastPx0 / curClose0
                    int dir0 = forecastMag0 > 1.0 ? 1 : (forecastMag0 < 1.0 ? -1 : 0)
                    Snapshot sNew = Snapshot.new(anchorBarIndex = bar_index, baselinePrice = curClose0, forecastDir = dir0, forecastMag = forecastMag0, targetBarIndex = bar_index + forecastLen, resolved = false, actualReturn = na)
                    array.push(snapshots, sNew)
                    if array.size(snapshots) > statsHistorySize
                        array.shift(snapshots)  // FIFO

    // Snapshot resolve: target バー到達後に実測リターン確定
    // index 付きループ + array.set で書き戻し必須 (priority B feedback_pine_udt_array_set)
    if array.size(snapshots) > 0
        for i = 0 to array.size(snapshots) - 1
            Snapshot s = array.get(snapshots, i)
            if not s.resolved and bar_index >= s.targetBarIndex
                if not na(s.baselinePrice) and s.baselinePrice != 0.0
                    s.actualReturn := close / s.baselinePrice - 1.0
                    s.resolved := true
                    array.set(snapshots, i, s)  // array.set 必須

    // 集計 (resolve 後)
    int   totalResolved = 0
    int   hitCount      = 0
    float sumAbsErr     = 0.0
    float sumActual     = 0.0
    if array.size(snapshots) > 0
        for i = 0 to array.size(snapshots) - 1
            Snapshot s = array.get(snapshots, i)
            if s.resolved
                totalResolved += 1
                bool hit = (s.forecastDir == 1 and s.actualReturn > 0) or (s.forecastDir == -1 and s.actualReturn < 0)
                if hit
                    hitCount += 1
                sumAbsErr += math.abs((s.forecastMag - 1.0) - s.actualReturn)
                sumActual += s.actualReturn

    float contRate = totalResolved > 0 ? hitCount * 100.0 / totalResolved : na
    float mae      = totalResolved > 0 ? sumAbsErr * 100.0 / totalResolved : na
    float meanRet  = totalResolved > 0 ? sumActual * 100.0 / totalResolved : na
    int   pending  = array.size(snapshots) - totalResolved

    // テーブル描画
    // テーブル位置を動的切替 (var table の初回固定問題への二重保険として毎回 set_position)
    if showStats
        table.set_position(hitRateTable, tblPositionConst)
        table.clear(hitRateTable, 0, 0, 1, 6)
        table.cell(hitRateTable, 0, 0, "Historical Pattern Continuation Rate", text_color = color.white, bgcolor = color.new(color.blue, 60), text_size = tblTextSize)
        table.merge_cells(hitRateTable, 0, 0, 1, 0)
        table.cell(hitRateTable, 0, 1, "Resolved",        text_color = color.silver, text_size = tblTextSize)
        table.cell(hitRateTable, 1, 1, str.tostring(totalResolved), text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 2, "Pending",         text_color = color.silver, text_size = tblTextSize)
        table.cell(hitRateTable, 1, 2, str.tostring(pending),       text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 3, "Continuation Rate", text_color = color.silver, text_size = tblTextSize)
        string rateText = totalResolved < minSamplesForStats ? "Insufficient samples (N<" + str.tostring(minSamplesForStats) + ")" : str.tostring(contRate, "#.0") + "%"
        color  rateColor = totalResolved < minSamplesForStats ? color.gray : (contRate >= 50.0 ? color.lime : color.orange)
        table.cell(hitRateTable, 1, 3, rateText, text_color = rateColor, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 4, "Mean Return",     text_color = color.silver, text_size = tblTextSize)
        string meanText = totalResolved < minSamplesForStats ? "-" : str.tostring(meanRet, "#.00") + "%"
        table.cell(hitRateTable, 1, 4, meanText, text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 5, "MAE",             text_color = color.silver, text_size = tblTextSize)
        string maeText = totalResolved < minSamplesForStats ? "-" : str.tostring(mae, "#.00") + "%"
        table.cell(hitRateTable, 1, 5, maeText, text_color = color.white, text_size = tblTextSize)
        table.cell(hitRateTable, 0, 6, "Retrospective only, no future guarantee.", text_color = color.gray, text_size = size.tiny)
        table.merge_cells(hitRateTable, 0, 6, 1, 6)
````
