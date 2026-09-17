<!-- tradingview-pine-id: PUB;fe6a57edfdd647fab1c0d29277eb46d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: Trend Participation Monitor (TPM) v1.0.8

Source: https://www.tradingview.com/script/abGBPJp1-TF-Trend-Participation-Monitor-TPM/

## Description

TradingFlow: Trend Participation Monitor (TPM)

TradingFlow: Trend Participation Monitor (TPM) combines price behavior and relative volume in a separate pane to show recent directional pressure and whether that pressure is improving or deteriorating relative to its recent average.
TPM is designed to track relatively short-term changes in price/volume pressure. The time horizon depends on the chart timeframe and lookback settings.
TPM separates the level of pressure from the change in pressure. Positive pressure can be weakening, while negative pressure can be recovering. This helps traders distinguish the direction of recent price/volume behavior from changes in its strength.
TPM is a pressure monitor, not a predictive reversal indicator or a standalone entry and exit system.

Price and Participation Model
The model combines two components with equal weight: directional price efficiency and relative-volume-weighted bar pressure.

Price efficiency compares net price movement with the total distance traveled by consecutive closes. Bar pressure combines the close-to-close move, normalized by the previous bar's ATR, with the close's position within the candle range. Close-to-close movement includes gaps; closing near the high after a gap down does not automatically make the bar positive.
Relative volume compares each bar's volume with the average of preceding bars. Its contribution is capped to limit the influence of isolated volume spikes. The result is smoothed into a pressure score bounded between -100 and +100. This is a price/volume proxy, not actual buy/sell volume or measured capital flows.

Pressure and Reference Lines
The blue line shows pressure. Values above zero indicate positive pressure within the model, while values below zero indicate negative pressure. The gray line is a slower average of that pressure, providing a reference for recent change.

Recent Change Histogram
The histogram equals half the difference between pressure and its reference. It measures pressure relative to its recent average, rather than price direction or the change from just one bar ago.
With default settings, a change score must remain at or above +5, or at or below -5, for two consecutive bars to receive a confirmed directional color.

Four-Shade Color System
Purple represents confirmed improvement; gold represents confirmed deterioration.
Gray: the threshold or confirmation requirement has not been met.
Darker shades indicate columns growing away from zero; lighter shades indicate columns shrinking toward zero or remaining unchanged, compared with the preceding bar. Gray does not mean price is stable, and a lighter gold column can still represent confirmed deterioration even as its magnitude decreases.

Compact Dashboard and Activity Context
The compact table shows the displayed bar status, recent condition, and pressure/change values. The optional detailed view adds volume, rolling relative volume, estimated stock traded value, optional free-float turnover, and data status.
Estimated traded value uses typical price multiplied by volume. Turnover requires a manually supplied free-float figure in millions of shares. Both are stock-only context measurements and do not contribute additional votes to the pressure score. A fixed float figure may not represent historical share counts accurately.

Closed-Bar Display and Alerts
By default, the indicator holds the last completed bar's readings while the current candle forms. Disabling this option displays provisional live values and colors that may change before the bar closes. Alerts remain restricted to bar close and identify newly confirmed improvement or deterioration. They confirm observed pressure changes; they do not identify the start of a price trend.

Volume Data Handling
Missing or invalid volume, a zero-volume evaluated bar, and insufficient usable activity suppress pressure output and alerts. The pressure window needs at least two bars with usable positive volume weights. After missing data, a valid recovery window is required before output resumes. Small positive volume is supported, but thin trading can still produce noisy readings.

How to Read the Chart
Positive pressure with purple columns means pressure is positive and sufficiently above its reference. Positive pressure with gold columns means it remains positive but has weakened relative to that reference.
Negative pressure with purple columns indicates recovery within negative pressure, not a confirmed bullish reversal. A histogram near zero means pressure is close to its reference; it does not establish a sideways price trend.

Flexible Configuration
Users can adjust the activity baseline, pressure window, smoothing, reference length, ATR length, volume cap, change threshold, confirmation period, histogram colors, and dashboard display.
The defaults are intended as a starting point for daily stock charts. All lengths count chart bars. On intraday charts, relative volume uses a rolling-bar comparison, not a same-time-of-day comparison, so session openings, closings, and extended hours can affect readings. Use standard candles and consider the meaning of the symbol's volume feed.

Practical Use
TPM is best approached as a short-term reference when considering entry and exit timing. Its relatively responsive readings can change frequently within an ongoing move, so using every change to reassess an open position may encourage unnecessary second-guessing. For holding decisions, give greater weight to your trading timeframe, broader price structure, and original trade plan. A change in TPM alone is not a reason to enter or exit.
TPM can help assess changes in price/volume pressure during advances, pullbacks, and consolidations. Read it alongside price structure and market context. Smoothing and confirmation introduce delay; faster settings can increase noise. Scores are not probabilities, and TPM does not guarantee future price direction or trading profitability.

---

TradingFlow: Trend Participation Monitor (TPM)

TradingFlow: Trend Participation Monitor (TPM) 結合價格行為與相對成交量，在獨立窗格中呈現近期的方向性壓力，以及壓力相對於近期平均值正在改善還是惡化。
TPM 著重觀察相對短期的量價壓力變化，實際涵蓋的時間範圍取決於圖表週期與回看設定。
TPM 將「壓力的正負」與「壓力的變化」分開呈現。正向壓力可能正在減弱，負向壓力也可能正在回升，讓交易者能區分近期量價表現的方向與強弱變化。
TPM 是壓力觀察工具，並非預測反轉的指標，也不是獨立的進出場系統。

價格與成交參與模型
模型以相同權重結合兩個部分：價格方向效率，以及相對成交量加權的單根 K 線壓力。
價格方向效率比較價格淨變化與連續收盤價的總移動距離。單根 K 線壓力則結合「以前一根 ATR 標準化的收盤價變化」與「收盤價在當根高低區間中的位置」。收盤價之間的變化包含跳空，因此向下跳空後收在當根高點附近，不一定會得到正向判定。
相對成交量比較當根成交量與先前數根 K 線的平均成交量，並限制其權重上限，避免單次爆量過度主導結果。模型經平滑後形成介於 -100 至 +100 的壓力分數。這是根據量價推算的數值，並非實際買賣方成交量或資金流入流出。

壓力線與參考線
藍線代表壓力。高於零表示模型中的正向壓力，低於零則表示負向壓力。灰線是壓力的較慢平均值，用來比較近期變化。

近期變化柱狀圖
柱狀圖等於壓力與參考線差值的一半。它衡量壓力相對近期平均值的位置，並非直接表示價格方向，也不只是與上一根 K 線相比的變化。
預設情況下，變化分數需要連續兩根達到 +5 或以上，或 -5 或以下，才會顯示已確認的方向顏色。

四色深淺設計
紫色代表已確認的改善；金色代表已確認的惡化。
灰色：尚未符合門檻或連續確認條件。
與前一根相比，較深色表示柱體朝遠離零軸的方向增長；較淺色表示柱體朝零軸縮短或持平。灰色不代表價格穩定；淺金色即使正在縮短，仍可能處於已確認的惡化狀態。

精簡資訊表與成交背景
精簡資訊表顯示目前採用的 K 線狀態、近期狀況，以及壓力與變化分數。詳細模式另顯示成交量、滾動相對成交量、股票估算成交額、可選的流通股換手率與資料狀態。
估算成交額以典型價格乘以成交量計算。換手率需手動輸入流通股數，單位為百萬股。這兩項僅提供股票的成交背景，不會額外加入壓力分數，避免重複計入成交量。固定的流通股數也未必能準確反映歷史股數變化。

收盤顯示與提醒
預設在當根 K 線形成期間，維持上一根已收盤 K 線的讀值。關閉此選項後，會顯示即時數值與顏色，兩者在當根收盤前都可能改變。提醒仍只在收盤時觸發，用來通知新確認的改善或惡化。這些提醒確認的是已發生的壓力變化，不代表價格趨勢剛剛開始。

成交量資料處理
當成交量缺失或無效、被評估的 K 線成交量為零，或有效成交活動不足時，指標會停止顯示壓力讀值並抑制提醒。壓力窗口內至少需要兩根具有有效正成交量權重的 K 線。資料缺失後，需累積完整的有效恢復窗口才會重新輸出。極小的正成交量仍可計算，但交投清淡時的讀值可能較嘈雜。

如何閱讀圖表
正向壓力搭配紫色柱，表示壓力為正，且已充分高於參考線。正向壓力搭配金色柱，表示壓力仍為正，但相對參考線已轉弱。
負向壓力搭配紫色柱，代表負向壓力正在回升，並非已確認的多頭反轉。柱狀圖接近零，代表壓力接近參考線，不代表價格必然處於橫盤。

彈性設定
可調整成交量基準期、壓力窗口、平滑期、參考期、ATR 週期、成交量權重上限、變化門檻、確認根數、柱狀圖顏色與資訊表顯示方式。
預設參數以股票日線作為起點，所有週期均按圖表的 K 線根數計算。日內相對成交量採用滾動比較，並非與過往相同時段比較，因此開盤、收盤與延長交易時段可能影響讀值。請使用標準 K 線，並留意商品所提供的成交量資料類型。

實際使用方式
TPM 的定位較適合作為評估進出場時機的短期輔助參考。由於反應較快，即使同一段走勢仍在延續，讀值也可能頻繁變化；持倉期間若每次變化都重新判斷是否續抱，容易反覆猶豫，打亂原有節奏。是否繼續持有，應更重視自己的交易週期、較大範圍的價格結構與原先的交易計畫，不宜僅因 TPM 的變化就決定進出場。
TPM 可協助觀察上漲、回調與整理期間的量價壓力變化，適合搭配價格結構與市場背景使用。平滑與確認機制會帶來延遲；較快的設定也可能增加雜訊。分數並非機率，TPM 不保證未來價格方向或交易獲利。

---

TradingFlow: Trend Participation Monitor (TPM)

TradingFlow: Trend Participation Monitor (TPM) は、値動きと相対出来高を組み合わせ、直近の上昇・下落圧力と、その圧力が最近の平均に対して改善しているか、悪化しているかを別のペインに表示するインジケーターです。
TPM は、価格と出来高から読み取れる比較的短期の圧力変化を捉えることを目的としています。対象となる時間の長さは、チャートの時間足と計算期間の設定によって変わります。
圧力の水準と、その変化を分けて見ることで、プラス圏にありながら勢いが弱まっている状態や、マイナス圏から持ち直している状態を把握できます。
TPM は圧力の変化を観察するためのツールです。反転を予測するものではなく、単独で売買のタイミングを判断するためのシステムでもありません。

価格と出来高を組み合わせたモデル
モデルは「値動きの方向効率」と「相対出来高で加重した各足の圧力」を、同じ比率で組み合わせています。

値動きの方向効率は、期間中の始点と終点の価格差を、終値が上下に動いた距離の合計と比較します。各足の圧力は、前の足の ATR で調整した終値の変化と、その足の高値・安値の範囲内での終値の位置から計算します。終値間の変化には窓開けも含まれるため、下に窓を開けた後にその足の高値付近で引けても、必ずしもプラスの評価にはなりません。
相対出来高は、各足の出来高をそれ以前の足の平均出来高と比較したものです。単発の出来高急増に左右されすぎないよう、計算に使う重みには上限を設けています。計算結果を平滑化し、-100 から +100 の圧力スコアとして表示します。このスコアは価格と出来高に基づく推定値であり、実際の買い・売り別出来高や資金流出入を測定したものではありません。

圧力ラインと基準ライン
青いラインは圧力スコアです。ゼロより上はモデル上の上昇圧力、ゼロより下は下落圧力を示します。グレーのラインは圧力をより長い期間で平均したもので、直近の変化を判断する基準になります。

直近の変化を示すヒストグラム
ヒストグラムは、圧力スコアと基準ラインの差を 2 で割った値です。価格そのものの方向や、単純な前の足との差ではなく、圧力が最近の平均に対してどの位置にあるかを示します。
初期設定では、変化スコアが 2 本連続で +5 以上、または -5 以下になると、条件成立を示す色が付きます。

色と濃淡の見方
紫は改善条件の成立、ゴールドは悪化条件の成立を示します。
グレーは、しきい値または連続確認の条件を満たしていない状態です。
前の足と比べてゼロから離れる方向に棒が伸びると濃い色、ゼロに向かって縮むか横ばいになると薄い色で表示します。グレーは価格が安定していることを意味しません。また、薄いゴールドの棒がゼロに向かって縮んでいても、悪化の判定条件は引き続き満たしている場合があります。

コンパクトな情報テーブル
通常表示では、表示対象の足の状態、直近の判定、圧力スコアと変化スコアを確認できます。詳細表示では、出来高、相対出来高、株式の推定売買代金、任意設定の浮動株回転率、データの状態も表示します。
推定売買代金は、代表価格（高値・安値・終値の平均）に出来高を掛けて計算します。浮動株回転率を表示するには、浮動株数を百万株単位で手入力してください。いずれも株式向けの参考情報であり、圧力スコアには加算しません。なお、固定の浮動株数では、過去の株数の変化を正確に反映できない場合があります。

確定足の表示とアラート
初期設定では、現在の足が形成されている間も、直前の確定足の値を表示します。この設定をオフにすると、リアルタイムの値と色を表示しますが、どちらも足が確定するまでは変わる可能性があります。アラートは設定にかかわらず足の確定時にのみ発生し、改善または悪化の条件が新たに成立したことを通知します。すでに生じた圧力変化を確認するものであり、価格トレンドの始まりを示すものではありません。

出来高データの扱い
出来高の欠損・無効値、判定対象の足の出来高がゼロの場合、または計算に使える取引データが不足している場合は、圧力の表示とアラートを停止します。圧力の計算期間内には、有効な正の出来高ウェイトを持つ足が少なくとも 2 本必要です。データ欠損後は、所定の期間にわたって有効なデータがそろうと表示を再開します。ごく少量の出来高でも計算できますが、取引が少ない銘柄では値が不安定になることがあります。

チャートの読み方
圧力がプラスで紫の棒が出ている場合は、圧力がプラス圏にあり、基準ラインを十分に上回っている状態です。圧力がプラスでもゴールドの棒が出ている場合は、プラス圏を維持しながらも、基準ラインに対して弱まっていることを示します。
圧力がマイナスで紫の棒が出ている場合は、マイナス圏からの持ち直しを示します。上昇トレンドへの転換が確定したわけではありません。ヒストグラムがゼロ付近にある場合は、圧力が基準ラインに近い状態であり、価格が横ばいであるとは限りません。

カスタマイズ
出来高の比較期間、圧力の計算期間、平滑化期間、基準ラインの期間、ATR の期間、出来高ウェイトの上限、変化のしきい値、確認本数、ヒストグラムの色、テーブルの表示を調整できます。
初期設定は株式の日足を想定しています。各期間は、チャート上の足の本数で数えます。日中足の相対出来高は直前の一定本数との比較であり、過去の同じ時間帯との比較ではありません。そのため、寄り付き・引け・時間外取引の影響を受けます。通常のローソク足で使用し、対象銘柄の出来高データが何を表しているかも確認してください。

活用方法
TPM は、エントリーや決済のタイミングを検討する際の、短期的な補助指標としての利用を想定しています。比較的反応が速く、一つの値動きが続いている途中でも表示が頻繁に変わることがあります。保有中にその変化を追いすぎると、判断がぶれたり、当初の売買計画を必要以上に見直したりする原因になりかねません。保有を続けるかどうかは、ご自身の取引時間軸、より大きな値動きの流れ、当初の売買計画を軸に判断し、TPM の変化だけを理由に売買しないことが大切です。
TPM は、上昇局面、押し目、もみ合いの中で、価格と出来高から読み取れる圧力がどう変化しているかを確認するのに役立ちます。高値・安値の位置関係や相場全体の状況と併せて判断してください。平滑化と確認処理には遅れが伴い、反応を速くする設定ではノイズが増えることがあります。スコアは確率ではなく、将来の値動きや取引の利益を保証するものではありません。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// --------------------------------------------------------------------
//  TradingFlow: Trend Participation Monitor
// --------------------------------------------------------------------
indicator("TradingFlow: Trend Participation Monitor (TPM) v1.0.8", "TF: TPM", overlay = false, precision = 1, max_bars_back = 1000)

// Threshold events confirm pressure already observed; no directional markers.
// Intended first for daily stocks. Intraday RVOL below is rolling-bar RVOL,
// NOT same-time-of-day RVOL. No pivots, future data, or backdated markers.
groupModel = "Model"
activityLength = input.int(20, "Activity Baseline", minval = 5, maxval = 200, group = groupModel)
pressureLength = input.int(5, "Pressure Window", minval = 2, maxval = 50, group = groupModel)
smoothLength = input.int(3, "Pressure Smoothing", minval = 1, maxval = 20, group = groupModel)
referenceLength = input.int(13, "Recent Pressure Reference", minval = 3, maxval = 100, group = groupModel)
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupModel)
volumeCap = input.float(3.0, "Maximum Relative Volume Weight", minval = 1, maxval = 10, step = 0.25, group = groupModel, tooltip = "Caps each bar's influence so one volume spike cannot dominate the pressure window.")

groupContext = "Activity Context"
floatMillions = input.float(0, "Manual Free Float (Million Shares)", minval = 0, group = groupContext, tooltip = "Optional stock-only turnover estimate: bar volume / manually supplied free float. Zero disables it. A fixed current float is not historically accurate after share-count changes. Never used in the score.")

groupSignals = "Signals"
changeThreshold = input.float(5, "Minimum Change Score", minval = 0.5, maxval = 50, step = 0.5, group = groupSignals)
confirmBars = input.int(2, "Consecutive Confirmation Bars", minval = 1, maxval = 10, group = groupSignals)
closedBarsOnly = input.bool(true, "Display Closed Bars Only", group = groupSignals, tooltip = "Holds plots and dashboard at the last completed bar. When disabled, live values are provisional; alerts still require a closed bar.")

groupVisual = "Visuals"
showDashboard = input.bool(true, "Show Dashboard", group = groupVisual)
dashboardDetails = input.bool(false, "Detailed Dashboard", group = groupVisual, tooltip = "Default: three compact rows. Enable for activity diagnostics. All diagnostic plots remain available in the Data Window.")
dashboardCorner = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = groupVisual)
dashboardFont = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = groupVisual)
bullColor = input.color(color.rgb(151, 113, 214), "Improving: Growing", group = groupVisual)
bullFadeColor = input.color(color.rgb(179, 157, 219), "Improving: Shrinking / Flat", group = groupVisual)
bearColor = input.color(color.rgb(232, 164, 55), "Deteriorating: Growing", group = groupVisual)
bearFadeColor = input.color(color.rgb(239, 193, 112), "Deteriorating: Shrinking / Flat", group = groupVisual)

clamp(float value, float lowBound, float highBound) =>
    math.max(lowBound, math.min(highBound, value))

numberText(float value, string pattern) =>
    na(value) ? "N/A" : str.tostring(value, pattern)

// Use prior baselines: the current spike cannot inflate its own denominator.
volumeValid = not na(volume) and volume >= 0
barVolume = volumeValid ? volume : 0.0
volumeBaseline = ta.sma(barVolume, activityLength)[1]
baselineMissing = math.sum(volumeValid ? 0.0 : 1.0, activityLength)[1]
baselineReady = not na(baselineMissing) and baselineMissing == 0 and volumeBaseline > 0
relativeVolume = volumeValid and baselineReady ? barVolume / volumeBaseline : na
atrBaseline = ta.atr(atrLength)[1]
atrSafe = not na(atrBaseline) ? math.max(atrBaseline, syminfo.mintick > 0 ? syminfo.mintick : 1e-10) : na
priceChange = ta.change(close)

// Close-to-close movement includes gaps. Close location contributes only 30% of bar bias:
// a gap down closing near its high is not automatically bullish.
barRange = high - low
closeLocation = barRange > 0 ? (2 * close - high - low) / barRange : 0.0
normalizedMove = not na(atrSafe) and atrSafe > 0 ? clamp(priceChange / atrSafe, -1, 1) : 0.0
barBias = 0.7 * normalizedMove + 0.3 * closeLocation
activityWeight = not na(relativeVolume) ? math.min(relativeVolume, volumeCap) : 0.0
weightSum = math.sum(activityWeight, pressureLength)
// One isolated print must not make an otherwise inactive window signal.
contributingBars = math.sum(activityWeight > 0 ? 1.0 : 0.0, pressureLength)
weightedBiasSum = math.sum(activityWeight * barBias, pressureLength)
flowPressure = weightSum > 0 ? weightedBiasSum / weightSum : 0.0

// Price efficiency is directional progress / total close-to-close travel.
// It captures smaller declines and improving structure without requiring a high-volume bar.
// Volume is used once, in flowPressure, rather than repeated votes from volume, traded value, turnover and RVOL.
totalTravel = math.sum(math.abs(priceChange), pressureLength)
netTravel = math.sum(priceChange, pressureLength)
priceEfficiency = totalTravel > 0 ? netTravel / totalTravel : 0.0
rawPressure = 100 * (0.5 * priceEfficiency + 0.5 * flowPressure)
pressure = ta.ema(rawPressure, smoothLength)
pressureReference = ta.ema(pressure, referenceLength)
// Both pressure inputs are bounded +/-100, so half their difference is too.
changeScore = (pressure - pressureReference) / 2


// Missing volume must not silently become a neutral/bullish signal.
// A fully populated recovery window is required after missing data.
// Zero-volume bars are valid observations, but the current bar must trade and the pressure
// window must contain at least two bars with usable positive volume weights.
recoveryLength = activityLength + pressureLength + smoothLength + referenceLength
missingCount = math.sum(volumeValid ? 0.0 : 1.0, recoveryLength)
warmupLength = recoveryLength + atrLength
ready = bar_index >= warmupLength and missingCount == 0 and baselineReady and barVolume > 0 and contributingBars >= 2 and weightSum > 0 and not na(changeScore)
improving = ready and changeScore >= changeThreshold
deteriorating = ready and changeScore <= -changeThreshold
var int improvingCount = 0
var int deterioratingCount = 0
improvingCount := improving ? improvingCount + 1 : 0
deterioratingCount := deteriorating ? deterioratingCount + 1 : 0
// State describes the current confirmed condition, not a permanent latch.
state = improvingCount >= confirmBars ? 1 : deterioratingCount >= confirmBars ? -1 : 0
improvementStart = barstate.isconfirmed and ready and ready[1] and state == 1 and state[1] != 1
deteriorationStart = barstate.isconfirmed and ready and ready[1] and state == -1 and state[1] != -1

// Stock diagnostics only: these proxies must not be called actual money flow.
stockVolume = syminfo.type == "stock" and volumeValid
estimatedValue = stockVolume ? hlc3 * barVolume : na
valueBaseline = ta.sma(estimatedValue, activityLength)[1]
relativeValue = stockVolume and baselineReady and valueBaseline > 0 ? estimatedValue / valueBaseline : na
turnover = stockVolume and floatMillions > 0 ? 100 * barVolume / (floatMillions * 1000000) : na

holdLive = closedBarsOnly and not barstate.isconfirmed
displayReady = holdLive ? ready[1] : ready
displayPressure = displayReady ? (holdLive ? pressure[1] : pressure) : na
displayReference = displayReady ? (holdLive ? pressureReference[1] : pressureReference) : na
displayChange = displayReady ? (holdLive ? changeScore[1] : changeScore) : na
displayState = holdLive ? state[1] : state
displayRvol = holdLive ? relativeVolume[1] : relativeVolume
displayValue = holdLive ? estimatedValue[1] : estimatedValue
displayRelativeValue = holdLive ? relativeValue[1] : relativeValue
displayTurnover = holdLive ? turnover[1] : turnover
displayVolume = holdLive ? volume[1] : volume
displayMissing = holdLive ? missingCount[1] : missingCount
displayBaselineReady = holdLive ? baselineReady[1] : baselineReady
displayContributingBars = holdLive ? contributingBars[1] : contributingBars

neutralColor = color.rgb(145, 155, 170)
// Separate table text tones preserve contrast on the light dashboard.
tableStatusColor = displayState == 1 ? color.rgb(103, 65, 157) : displayState == -1 ? color.rgb(132, 83, 10) : color.rgb(80, 89, 105)
// Compare the same completed bar represented by displayChange with its predecessor.
// displayChange[1] would compare a held live value with itself.
previousChange = holdLive ? changeScore[2] : changeScore[1]
improvementGrowing = not na(previousChange) and displayChange > previousChange
deteriorationGrowing = not na(previousChange) and displayChange < previousChange
histogramColor = displayState == 1 ? (improvementGrowing ? bullColor : bullFadeColor) : displayState == -1 ? (deteriorationGrowing ? bearColor : bearFadeColor) : color.new(neutralColor, 45)
hline(0, "Neutral", color = color.new(neutralColor, 50), display=display.none)
hline(changeThreshold, "Improvement Threshold", color = color.new(bullColor, 65), linestyle = hline.style_dotted)
hline(-changeThreshold, "Deterioration Threshold", color = color.new(bearColor, 65), linestyle = hline.style_dotted)
plot(displayChange, "Recent Change", style = plot.style_columns, color = histogramColor)
plot(displayPressure, "Pressure", color = color.rgb(90, 175, 245), linewidth = 2, style = plot.style_linebr)
plot(displayReference, "Pressure Reference", color = color.new(neutralColor, 25), style = plot.style_linebr)
plot(displayReady ? displayState : na, "Change: +1 Improving / 0 Unconfirmed / -1 Deteriorating", display = display.data_window)
plot(displayRvol, "Rolling Relative Volume", display = display.data_window)
plot(displayValue, "Estimated Stock Traded Value (Quote Currency)", display = display.data_window)
plot(displayRelativeValue, "Relative Estimated Traded Value", display = display.data_window)
plot(displayTurnover, "Estimated Free-Float Turnover (%)", display = display.data_window)

tablePosition = switch dashboardCorner
    "Bottom Right" => position.bottom_right
    "Top Left" => position.top_left
    "Bottom Left" => position.bottom_left
    => position.top_right
tableFont = dashboardFont == "Tiny" ? size.tiny : dashboardFont == "Small" ? size.small : size.normal
var table dashboard = table.new(tablePosition, 2, dashboardDetails ? 7 : 3, bgcolor = color.rgb(247, 248, 251), border_width = 1, border_color = color.rgb(216, 221, 230))
if barstate.islast and showDashboard
    unavailableText = na(displayVolume) or displayVolume < 0 ? "No volume data" : displayVolume == 0 ? "No trading" : displayMissing > 0 ? "Recovering" : not displayBaselineReady or displayContributingBars < 2 ? "Thin history" : "Warming up"
    statusText = not displayReady ? unavailableText : displayState == 1 ? "Improving" : displayState == -1 ? "Deteriorating" : "No signal"
    modeText = holdLive ? "Prev. close" : barstate.isconfirmed ? "Closed" : "LIVE"
    dataText = not displayReady ? unavailableText : timeframe.isintraday ? "RVOL: intraday*" : "RVOL: rolling"
    array<string> labels = array.from("TPM", "Change", "Press / chg")
    array<string> values = array.from(modeText, statusText, numberText(displayPressure, "#.0") + " / " + numberText(displayChange, "#.0"))
    array<string> tips = array.from("TPM v1.0.7. Prev. close holds the last completed bar; LIVE values are provisional. " + dataText + ". Intraday RVOL is rolling-bar volume, not adjusted for time of day.", "Improving/deteriorating requires the change threshold for the confirmation period. No signal means the threshold or persistence requirement is not met, not that price is stable.", "Pressure / recent change. Change = (pressure - reference) / 2. Positive pressure can coexist with deterioration.")
    if dashboardDetails
        array.push(labels, "Vol / RVOL")
        array.push(values, (na(displayVolume) ? "N/A" : str.tostring(displayVolume, format.volume)) + " / " + numberText(displayRvol, "#.00") + "x")
        array.push(tips, "Bar volume / rolling relative volume. Intraday comparisons have time-of-day bias.")
        array.push(labels, "Value / rel")
        array.push(values, (na(displayValue) ? "N/A" : str.tostring(displayValue, format.volume)) + " / " + numberText(displayRelativeValue, "#.00") + "x")
        array.push(tips, "Estimated stock traded value in " + syminfo.currency + " / its relative baseline. This is not actual money flow.")
        array.push(labels, "Turnover")
        array.push(values, numberText(displayTurnover, "#.00") + "%")
        array.push(tips, "Estimated bar volume / manual free float. Requires a stock and a supplied float.")
        array.push(labels, "Data")
        array.push(values, dataText)
        array.push(tips, "Missing volume or insufficient active history suppresses signals. * Intraday RVOL is not adjusted for time of day.")
    for row = 0 to array.size(labels) - 1
        table.cell(dashboard, 0, row, array.get(labels, row), bgcolor = color.rgb(237, 240, 245), text_color = color.rgb(80, 89, 105), text_size = tableFont, text_halign = text.align_left, tooltip = array.get(tips, row))
        table.cell(dashboard, 1, row, array.get(values, row), bgcolor = color.rgb(247, 248, 251), text_color = row == 1 and displayReady ? tableStatusColor : color.rgb(42, 49, 62), text_size = tableFont, text_halign = text.align_left, tooltip = array.get(tips, row))

alertcondition(improvementStart, "TPM: Improving Pressure Confirmed", "TPM: recent pressure improvement confirmed on {{ticker}} ({{interval}}). Lagging observation, not an entry or reversal signal.")
alertcondition(deteriorationStart, "TPM: Deteriorating Pressure Confirmed", "TPM: recent pressure deterioration confirmed on {{ticker}} ({{interval}}). Lagging observation, not an entry or reversal signal.")
````
