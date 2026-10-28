# TF: Efficiency & Absorption Index (EAI)

- url: https://www.tradingview.com/script/8u5O1Zne-TF-Efficiency-Absorption-Index-EAI/
- type: indicator
- pine_id: PUB;21b5921221614261b3e5f068b7b5862d
- version: 3.0

## Description

[b]TradingFlow: Efficiency & Absorption Index (EAI)[/b]

EAI studies the relationship between market participation and price progress. It helps answer two connected questions:
1. Is trading activity moving price efficiently in one direction?
2. Is participation high while price makes limited progress near an important area?

The first condition can support continuation. The second may indicate absorption: buying or selling is active, but opposing interest is preventing price from advancing easily.

[b]What “Efficiency” Means[/b]

Efficiency measures close-to-close price progress relative to participation, with price movement adjusted for the instrument’s normal volatility. In practical terms, it asks how much directional progress the market produced for the amount of activity involved.

Strong positive efficiency means price is advancing upward effectively. Strong negative efficiency means price is advancing downward effectively. Low efficiency means participation is producing relatively little net movement; this alone does not imply a reversal.

[b]How to Read the Main Plot[/b]

• [b]Cyan columns above zero:[/b] upward price efficiency.
• [b]Pink columns below zero:[/b] downward price efficiency.
• [b]Taller columns:[/b] greater directional progress relative to participation.
• [b]Orange line:[/b] a smoothed view of efficiency, useful for seeing the broader change rather than every bar-to-bar fluctuation.

The teal upper line and red lower line are adaptive boundaries based on recent readings. A column extending beyond a boundary means movement in that direction is unusually efficient compared with the recent market. It can confirm directional expansion, but it is not an automatic entry signal.

[b]Potential Absorption[/b]

EAI also looks for bars where participation is unusually high but close-to-close progress is limited. To reduce noise, potential bullish or bearish absorption additionally requires a meaningful bar range, a prior directional approach, a test near a recent range edge, and a recovery away from that edge.

• [b]Green:[/b] price approached a recent lower area, tested it, and recovered from the low. This indicates potential bullish absorption.
• [b]Red:[/b] price approached a recent upper area, tested it, and pulled back from the high. This indicates potential bearish absorption.

The colored column and matching background show the same potential absorption state. Matching triangles make these locations easier to find on the chart. Because absorption can develop before price visibly turns, a triangle can sometimes serve as an early hint of a potential reversal.

This is an early warning, not reversal confirmation. Look for subsequent price movement away from the tested area before acting.

[b]High-Participation, Limited-Progress Events[/b]

A light gray band means participation was high, but the close made limited net progress from the previous close. The bar can still have a wide intrabar range.

This is context only. It does not predict direction or imply that the next bar will move sharply. It may occur during consolidation, a reversal attempt, or a pause within a clean trend. Its meaning comes from the price response that follows.

[b]Practical Reading Process[/b]

1. Read the columns and orange line to identify direction and whether efficiency is strengthening or fading.
2. Use the adaptive boundaries to recognize unusually efficient expansion.
3. Give potential absorption more weight near support, resistance, range edges, or failed breakouts.
4. Wait for subsequent price confirmation rather than trading a marker by itself.

The optional dashboard summarizes the current state, relative volume, close-to-close progress in ATR units, and location within the recent range.

[b]Important[/b]

EAI uses chart OHLCV data. It cannot see the order book, aggressor-side trades, or institutional positions. The markers indicate potential absorption based on filtered conditions; they do not prove actual order-flow absorption. Results are less meaningful on symbols without reliable traded volume.

---

[b]TradingFlow: Efficiency & Absorption Index (EAI)[/b]

EAI 研究市場參與程度與價格淨進展之間的關係，主要協助交易者回答兩個相互關聯的問題：
1. 當前的成交活動，是否正在有效推動價格向某個方向前進？
2. 市場參與度很高，但價格在重要位置是否仍然只能取得有限進展？

第一種情況可用於判斷走勢是否具備延續動力；第二種情況則可能反映吸收現象：買盤或賣盤相當活躍，但對手方力量令價格難以繼續推進。

[b]这里的「效率」是什么？[/b]

效率衡量的是：相對於市場參與程度，價格從前一收盤價到當前收盤價走出了多少淨距離；價格變化同時會按標的本身的正常波動幅度調整。簡單來說，就是觀察市場付出了多少成交活動，最終換來了多少方向性進展。

正值較強，表示價格正在有效向上推進；負值較強，表示價格正在有效向下推進。效率偏低只代表成交活動帶來的淨進展較少，本身並不等於即將反轉。

[b]如何阅读主要图形[/b]

• [b]零軸上方的青色柱：[/b]向上價格效率。
• [b]零軸下方的粉紅色柱：[/b]向下價格效率。
• [b]柱體越高：[/b]相對於市場參與程度，方向性淨進展越大。
• [b]橙色線：[/b]效率的平滑走勢，用來觀察整體變化，減少單根 K 線波動造成的干擾。

青綠色上邊界與紅色下邊界會根據近期讀數自動調整。柱體超越邊界，表示該方向的價格推進效率相對於近期市場異常強，可用於確認方向性擴張，但不是自動進場訊號。

[b]潛在吸收[/b]

EAI 也會尋找市場參與度異常高，但收盤價淨進展有限的 K 線。為減少雜訊，潛在多頭或空頭吸收還需要同時具備足夠的 K 線波幅、此前的方向性靠近、對近期區間邊緣的測試，以及價格從該邊緣收回。

• [b]綠色：[/b]價格先靠近並測試近期低位，之後從低位回升，表示潛在多頭吸收。
• [b]紅色：[/b]價格先靠近並測試近期高位，之後從高位回落，表示潛在空頭吸收。

彩色柱與同色背景表達同一個潛在吸收狀態；同色三角形可協助在圖表中找到這些位置。由於吸收現象可能早於價格明顯轉向，三角形有時也可視為潛在反轉的早期提示。

這只是早期預警，並不代表反轉已經確認。實際操作前，應觀察價格之後是否進一步離開測試區域。

[b]高參與、有限進展事件[/b]

淺灰色事件帶表示市場參與度高，但當前收盤價相對前一收盤價的淨進展有限；該根 K 線的盤中高低波幅仍可能很大。

這項顯示只提供背景資訊，不預測方向，也不表示下一根 K 線必然大幅波動。它可能發生在盤整、轉折嘗試，或乾淨趨勢中的短暫停頓。其意義應由之後的價格反應判斷。

[b]實用判讀流程[/b]

1. 用柱狀圖與橙色線判斷方向，以及效率正在增強還是減弱。
2. 用自適應邊界辨認異常有效的方向性擴張。
3. 潛在吸收若出現在支撐、阻力、區間邊緣或假突破附近，通常更值得留意。
4. 等待後續價格確認，不要只憑單一標記交易。

選用的資訊面板會摘要目前狀態、相對成交量、以 ATR 計算的收盤價淨進展，以及價格在近期區間內的位置。

[b]重要說明[/b]

EAI 使用圖表上的 OHLCV 資料，無法看到訂單簿、主動買賣方向或機構持倉。這些標記只表示經過條件過濾後的潛在吸收，並非真實訂單流吸收的直接證明。缺乏可靠實際成交量的標的，結果會較缺乏意義。

---

[b]TradingFlow: Efficiency & Absorption Index (EAI)[/b]

EAIは、市場参加の大きさと価格の進み方との関係を分析し、次の2つの問いに答えるための指標です。
1. 現在の取引活動は、価格を一方向へ効率よく動かしているか？
2. 市場参加が活発であるにもかかわらず、重要な価格帯で値動きが伸び悩んでいないか？

前者はトレンド継続の判断材料になります。後者は、買いや売りが活発でも反対側の注文に受け止められ、価格が進みにくくなる「吸収」の可能性を示します。

[b]ここでいう「効率」とは[/b]

効率は、市場参加の大きさに対して、終値が前の足の終値からどれだけ動いたかを測ります。値動きは銘柄本来のボラティリティに合わせて調整されるため、取引活動の大きさに対して、どれだけ明確な方向性が生まれたかを確認できます。

強いプラス値は、価格が上方向へ効率よく進んでいる状態です。強いマイナス値は、下方向へ効率よく進んでいる状態です。効率が低いことは、活発な取引の割に価格の純変化が小さいことを意味しますが、それだけで反転を示すものではありません。

[b]メイン表示の見方[/b]

• [b]ゼロラインより上のシアンの柱：[/b]上方向の価格効率。
• [b]ゼロラインより下のピンクの柱：[/b]下方向の価格効率。
• [b]柱が高いほど：[/b]市場参加に対する方向性のある価格変化が大きい状態。
• [b]オレンジのライン：[/b]効率を平滑化したもので、各足の細かな変動を抑えながら全体の変化を確認できます。

上側のティールラインと下側の赤いラインは、直近の値に応じて変化する適応型の境界線です。柱が境界線を超えると、その方向への価格推移が最近と比べて特に効率的であることを示します。方向性のある拡大を確認する材料にはなりますが、それ自体がエントリーシグナルではありません。

[b]潜在的な吸収[/b]

EAIは、市場参加が通常より活発である一方、終値ベースの価格変化が限られている足も検出します。ノイズを抑えるため、潜在的な強気または弱気の吸収には、十分な値幅、直前までの方向性、直近レンジ端のテスト、そしてその水準から押し戻された動きも必要です。

• [b]緑：[/b]価格が直近の安値圏へ接近して試した後、安値から持ち直した状態。強気の吸収が起きている可能性を示します。
• [b]赤：[/b]価格が直近の高値圏へ接近して試した後、高値から押し戻された状態。弱気の吸収が起きている可能性を示します。

色付きの柱と同色の背景は、同じ潜在的な吸収状態を表します。同色の三角形は、チャート上でその位置を見つけやすくするための補助マーカーです。吸収は価格が明確に転換する前から進むことがあるため、三角形が反転の可能性を早期に示す場合もあります。

ただし、これは早期の注意喚起であり、反転の確定を意味しません。判断する際は、その後に価格がテストした水準から離れていく動きを確認してください。

[b]高い市場参加・限定的な価格進展[/b]

薄いグレーの帯は、市場参加が活発だった一方、現在の終値が前の足の終値からあまり進まなかったことを示します。ただし、その足の高値と安値の値幅が小さいとは限りません。

これは相場状況を把握するための補助情報であり、方向を予測するものでも、次の足で大きく動くことを示すものでもありません。持ち合い、反転の試み、または明確なトレンド途中の一時的な停滞でも発生します。意味を判断するには、その後の値動きを確認してください。

[b]実践的な読み方[/b]

1. 柱とオレンジのラインから方向を読み、効率が強まっているか弱まっているかを確認します。
2. 適応型の境界線を使い、通常より効率的な方向性の拡大を見つけます。
3. サポート、レジスタンス、レンジ端、またはダマシのブレイク付近に現れる潜在的な吸収を重視します。
4. マーカーだけで判断せず、その後の値動きによる確認を待ちます。

オプションのダッシュボードでは、現在の状態、相対出来高、ATR単位で表した終値間の価格変化、直近レンジ内での位置を確認できます。

[b]重要事項[/b]

EAIはチャート上のOHLCVデータを使用します。板情報、買い手・売り手のどちらが主導した約定か、機関投資家のポジションを直接確認することはできません。マーカーは複数の条件から潜在的な吸収を示すものであり、実際の注文フローにおける吸収を証明するものではありません。信頼できる実出来高が提供されていない銘柄では、指標の有効性が低下します。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// -------------------------------------------------------------------------------
//  TradingFlow: Efficiency & Absorption Index
// -------------------------------------------------------------------------------
indicator("TradingFlow: Efficiency & Absorption Index (EAI) v2.2.3", "TF: EAI", overlay=false, precision=1, max_bars_back=500)

// -------------------------------------
// Inputs
// -------------------------------------

grpCore = "Efficiency Model"
atrLength = input.int(14, "ATR Length", minval=2, maxval=200, group=grpCore)
volumeLength = input.int(30, "Relative Volume Length", minval=10, maxval=200, group=grpCore)
smoothLength = input.int(5, "Efficiency Smoothing", minval=1, maxval=100, group=grpCore)
signalLength = input.int(5, "Signal Line Length", minval=1, maxval=100, group=grpCore)
bandLength = input.int(80, "Adaptive Band Length", minval=20, maxval=300, group=grpCore)
bandMultiplier = input.float(1.5, "Band Standard Deviations", minval=0.5, maxval=3.0, step=0.1, group=grpCore)

grpAbs = "Potential Absorption"
volumeThreshold = input.float(1.6, "Minimum Relative Volume", minval=1.0, maxval=5.0, step=0.1, group=grpAbs)
progressThreshold = input.float(0.25, "Maximum Net Progress (ATR)", minval=0.05, maxval=1.0, step=0.05, group=grpAbs,
     tooltip="Maximum absolute close-to-close progress, measured in ATR units.")
minimumRange = input.float(0.45, "Minimum Bar Range (ATR)", minval=0.1, maxval=2.0, step=0.05, group=grpAbs,
     tooltip="Rejects tiny micro-bars that have low progress simply because nothing traded.")
contextLength = input.int(30, "Auction Location Length", minval=10, maxval=100, group=grpAbs)
approachLength = input.int(5, "Prior Approach Length", minval=2, maxval=20, group=grpAbs,
     tooltip="Measures whether price approached the potential absorption bar from above or below.")
minimumApproach = input.float(0.50, "Minimum Prior Approach (ATR)", minval=0.0, maxval=3.0, step=0.05, group=grpAbs,
     tooltip="Requires a meaningful directional approach before an event can be assigned a bullish or bearish absorption direction.")
edgeThreshold = input.float(0.65, "Required Range-Edge Location", minval=0.50, maxval=0.90, step=0.05, group=grpAbs)
rejectionThreshold = input.float(0.15, "Minimum Rejection Bias", minval=0.0, maxval=0.8, step=0.05, group=grpAbs)
cooldownBars = input.int(3, "Signal Cooldown", minval=0, maxval=20, group=grpAbs)

grpVisual = "Visuals"
showSignals = input.bool(true, "Show Potential Absorption Markers", group=grpVisual)
showBackground = input.bool(true, "Shade Potential Absorption Bars", group=grpVisual)
showLimitedProgress = input.bool(true, "Shade High-Participation, Limited-Progress Events", group=grpVisual)
showDashboard = input.bool(false, "Show Dashboard", group=grpVisual)

// -------------------------------------
// Palette and Helpers
// -------------------------------------

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

color bullAbsorptionColor = color.rgb(76, 175, 80)
color bearAbsorptionColor = color.rgb(244, 67, 54)
color bullAbsorptionDeep = color.rgb(39, 144, 42)
color bearAbsorptionDeep = color.rgb(201, 48, 37)
color positiveStrong = color.rgb(38, 198, 218)
color positiveWeak = color.rgb(128, 222, 234)
color negativeStrong = color.rgb(236, 64, 121)
color negativeWeak = color.rgb(244, 143, 177)
color signalColor = color.rgb(255, 152, 0)
color upperBandColor = color.rgb(38, 166, 154)
color lowerBandColor = color.rgb(239, 83, 80)
color neutralColor = color.rgb(137, 148, 163)
color limitedProgressEventColor = color.rgb(183, 191, 202)
color warningColor = color.rgb(184, 146, 74)
color tableHeaderColor = color.rgb(218, 239, 237)
color tableLabelColor = color.rgb(235, 241, 244)
color tableValueColor = color.rgb(250, 252, 252)
color tableTextColor = color.rgb(38, 50, 56)
color tableMutedTextColor = color.rgb(75, 91, 99)
color tableBorderColor = color.rgb(91, 132, 128)
color tableBullColor = color.rgb(225, 243, 227)
color tableBearColor = color.rgb(252, 229, 232)
color tablePositiveColor = color.rgb(222, 244, 246)
color tableNegativeColor = color.rgb(250, 229, 235)
color tableWarningColor = color.rgb(246, 238, 218)
color tableBullTextColor = color.rgb(35, 115, 56)
color tableBearTextColor = color.rgb(165, 47, 54)
color tablePositiveTextColor = color.rgb(25, 120, 129)
color tableNegativeTextColor = color.rgb(173, 48, 92)
color tableWarningTextColor = color.rgb(126, 94, 34)

// -------------------------------------
// Observable Components
// -------------------------------------

barRange = high - low
atrValue = ta.atr(atrLength)
atrBaseline = atrValue[1]
tickFloor = syminfo.mintick > 0.0 ? syminfo.mintick : 1e-10
atrSafe = not na(atrBaseline) ? math.max(atrBaseline, tickFloor) : na

// CLV: close position inside this bar. This is not volume delta.
clv = barRange > 0.0 ? clamp((2.0 * close - high - low) / barRange, -1.0, 1.0) : 0.0
upperWick = barRange > 0.0 ? high - math.max(open, close) : 0.0
lowerWick = barRange > 0.0 ? math.min(open, close) - low : 0.0
wickBias = barRange > 0.0 ? (lowerWick - upperWick) / barRange : 0.0
rejectionBias = clamp(0.65 * wickBias + 0.35 * clv, -1.0, 1.0)

// Net result is actual close-to-close progress, not candle body/range.
netProgress = not na(atrSafe) ? (close - close[1]) / atrSafe : na
progressMagnitude = not na(netProgress) ? math.abs(netProgress) : na
rangeInAtr = not na(atrSafe) ? barRange / atrSafe : na

// Median normalization is robust to isolated volume spikes. Participation is
// clamped so one exceptional print cannot dominate the oscillator indefinitely.
volumeBaseline = ta.median(volume[1], volumeLength)
hasVolume = not na(volume) and volume > 0.0 and not na(volumeBaseline) and volumeBaseline > 0.0
relativeVolumeRaw = hasVolume ? volume / volumeBaseline : na
relativeVolume = hasVolume ? clamp(relativeVolumeRaw, 0.25, 4.0) : na

// Directional price progress obtained per sqrt(relative participation).
// Positive/negative retain direction; larger absolute values mean price moved
// more efficiently for the amount of participation observed.
rawEfficiency = hasVolume and not na(netProgress) ? netProgress / math.sqrt(relativeVolume) : na
efficiency = ta.ema(rawEfficiency, smoothLength)
signalLine = ta.ema(efficiency, signalLength)

// Compare the current reading with a completed prior distribution so an
// exceptional current bar cannot raise the boundary used to assess itself.
efficiencyMean = ta.sma(efficiency[1], bandLength)
efficiencyDeviation = ta.stdev(efficiency[1], bandLength)
upperBand = efficiencyMean + bandMultiplier * efficiencyDeviation
lowerBand = efficiencyMean - bandMultiplier * efficiencyDeviation

// -------------------------------------
// Context-aware Potential Absorption
// -------------------------------------

// Compare the current auction with the range that existed BEFORE this bar.
// Using low/high instead of close preserves genuine sweep-and-reject events
// that probe a range edge and then close back toward the middle.
priorContextHigh = ta.highest(high[1], contextLength)
priorContextLow = ta.lowest(low[1], contextLength)
contextSpan = priorContextHigh - priorContextLow
lowTestPosition = contextSpan > 0.0 ? clamp((low - priorContextLow) / contextSpan, 0.0, 1.0) : 0.5
highTestPosition = contextSpan > 0.0 ? clamp((high - priorContextLow) / contextSpan, 0.0, 1.0) : 0.5

priorApproach = not na(atrSafe) ? (close[1] - close[approachLength + 1]) / atrSafe : 0.0

hasHighEffort = hasVolume and relativeVolumeRaw >= volumeThreshold
hasLowResult = not na(progressMagnitude) and progressMagnitude <= progressThreshold
hasMeaningfulAuction = not na(rangeInAtr) and rangeInAtr >= minimumRange
highParticipationLimitedProgress = hasHighEffort and hasLowResult and hasMeaningfulAuction

// Potential bullish absorption: a meaningful sell approach tested the prior range's lower
// edge, but lower prices were rejected. Bearish is the symmetrical upper test.
bullEdgeTest = lowTestPosition <= 1.0 - edgeThreshold
bearEdgeTest = highTestPosition >= edgeThreshold
bullContext = priorApproach < -minimumApproach and bullEdgeTest and rejectionBias > rejectionThreshold
bearContext = priorApproach > minimumApproach and bearEdgeTest and rejectionBias < -rejectionThreshold

// Potential absorption states wait for the close, so realtime markers do not flicker and
// disappear as volume, close, and wick geometry change intrabar.
closedBar = barstate.isconfirmed
bullState = closedBar and highParticipationLimitedProgress and bullContext
bearState = closedBar and highParticipationLimitedProgress and bearContext
limitedProgressState = closedBar and highParticipationLimitedProgress and not bullContext and not bearContext

// Cooldown is measured from the last displayed marker, not every qualifying
// state. Suppressed events therefore cannot keep extending the cooldown.
var int lastBullMarkerBar = na
var int lastBearMarkerBar = na
var int lastLimitedProgressEventBar = na

bullSignal = bullState and (na(lastBullMarkerBar) or bar_index - lastBullMarkerBar > cooldownBars)
bearSignal = bearState and (na(lastBearMarkerBar) or bar_index - lastBearMarkerBar > cooldownBars)
limitedProgressSignal = limitedProgressState and (na(lastLimitedProgressEventBar) or bar_index - lastLimitedProgressEventBar > cooldownBars)

if bullSignal
    lastBullMarkerBar := bar_index
if bearSignal
    lastBearMarkerBar := bar_index
if limitedProgressSignal
    lastLimitedProgressEventBar := bar_index

// -------------------------------------
// Visuals
// -------------------------------------

color efficiencyColor = neutralColor
if bullState
    efficiencyColor := bullAbsorptionColor
else if bearState
    efficiencyColor := bearAbsorptionColor
else if efficiency > 0.0
    efficiencyColor := efficiency >= efficiency[1] ? positiveStrong : positiveWeak
else if efficiency < 0.0
    efficiencyColor := efficiency <= efficiency[1] ? negativeStrong : negativeWeak

plot(efficiency, "Directional Price Efficiency", color=efficiencyColor, style=plot.style_columns)
plot(signalLine, "Efficiency Signal", color=color.new(signalColor, 25), linewidth=2)
plot(efficiencyMean, "Efficiency Mean", color=neutralColor, linewidth=1, display=display.data_window)
upperBandPlot = plot(upperBand, "Upper Adaptive Band", color=upperBandColor, linewidth=1)
lowerBandPlot = plot(lowerBand, "Lower Adaptive Band", color=lowerBandColor, linewidth=1)
hline(0.0, "Zero", color=neutralColor, display=display.none)

// This event is direction-neutral, so shade only that bar's adaptive range.
// It describes high participation with limited net price progress, not a forecast.
limitedProgressFillColor = showLimitedProgress and limitedProgressSignal ? color.new(limitedProgressEventColor, 60) : na
fill(upperBandPlot, lowerBandPlot, color=limitedProgressFillColor, title="High-Participation, Limited-Progress Event")

plotshape(showSignals and bullSignal, "Potential Bullish Absorption", shape.triangleup, location.bottom, bullAbsorptionDeep, size=size.tiny, display=display.pane)
plotshape(showSignals and bearSignal, "Potential Bearish Absorption", shape.triangledown, location.top, bearAbsorptionDeep, size=size.tiny, display=display.pane)

bgColor = bullState ? color.rgb(232, 245, 233) : bearState ? color.rgb(255, 235, 238) : na
bgcolor(showBackground ? bgColor : na)

// Diagnostics available without changing the pane scale.
plot(relativeVolumeRaw, "Diagnostic: Relative Volume", display=display.data_window)
plot(progressMagnitude, "Diagnostic: Net Progress (ATR)", display=display.data_window)
plot(rejectionBias, "Diagnostic: Rejection Bias", display=display.data_window)
plot(priorApproach, "Diagnostic: Prior Approach (ATR)", display=display.data_window)
plot(lowTestPosition, "Diagnostic: Low Test Position", display=display.data_window)
plot(highTestPosition, "Diagnostic: High Test Position", display=display.data_window)

// -------------------------------------
// Dashboard
// -------------------------------------

string stateText = "NORMAL AUCTION"
string actionText = "OBSERVE"
color stateBackgroundColor = tableValueColor
color stateTextColor = tableMutedTextColor

if not hasVolume
    stateText := "NO USABLE VOLUME"
    actionText := "UNAVAILABLE"
else if bullState
    stateText := "POTENTIAL BULLISH ABSORPTION"
    actionText := "WAIT FOR PRICE CONFIRMATION"
    stateBackgroundColor := tableBullColor
    stateTextColor := tableBullTextColor
else if bearState
    stateText := "POTENTIAL BEARISH ABSORPTION"
    actionText := "WAIT FOR PRICE CONFIRMATION"
    stateBackgroundColor := tableBearColor
    stateTextColor := tableBearTextColor
else if limitedProgressState
    stateText := "HIGH PARTICIPATION / LIMITED PROGRESS"
    actionText := "WAIT FOR PRICE RESPONSE"
    stateBackgroundColor := tableWarningColor
    stateTextColor := tableWarningTextColor
else if not na(efficiency) and not na(upperBand) and efficiency > upperBand
    stateText := "EFFICIENT UP EXPANSION"
    actionText := "CONTEXT ONLY"
    stateBackgroundColor := tablePositiveColor
    stateTextColor := tablePositiveTextColor
else if not na(efficiency) and not na(lowerBand) and efficiency < lowerBand
    stateText := "EFFICIENT DOWN EXPANSION"
    actionText := "CONTEXT ONLY"
    stateBackgroundColor := tableNegativeColor
    stateTextColor := tableNegativeTextColor

progressText = na(netProgress) ? "—" : (netProgress > 0.0 ? "+" : "") + str.tostring(netProgress, "#.00") + " ATR"
locationText = bullEdgeTest and bearEdgeTest ? "BOTH EDGE ZONES" : bullEdgeTest ? "LOW EDGE ZONE" : bearEdgeTest ? "HIGH EDGE ZONE" : "MID RANGE"

var table dashboard = table.new(position.top_right, 2, 6,
     bgcolor=tableValueColor,
     frame_color=tableBorderColor, frame_width=1,
     border_color=tableBorderColor, border_width=1)

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "EAI", text_color=tableTextColor, bgcolor=tableHeaderColor, text_size=size.tiny)
        table.cell(dashboard, 1, 0, "CURRENT", text_color=tableTextColor, bgcolor=tableHeaderColor, text_size=size.tiny)
        table.cell(dashboard, 0, 1, "STATE", text_color=tableMutedTextColor, bgcolor=tableLabelColor, text_size=size.tiny)
        table.cell(dashboard, 1, 1, stateText, text_color=stateTextColor, bgcolor=stateBackgroundColor, text_size=size.tiny)
        table.cell(dashboard, 0, 2, "ACTION", text_color=tableMutedTextColor, bgcolor=tableLabelColor, text_size=size.tiny)
        table.cell(dashboard, 1, 2, actionText, text_color=tableTextColor, bgcolor=tableValueColor, text_size=size.tiny)
        table.cell(dashboard, 0, 3, "REL VOLUME", text_color=tableMutedTextColor, bgcolor=tableLabelColor, text_size=size.tiny)
        table.cell(dashboard, 1, 3, hasVolume ? str.tostring(relativeVolumeRaw, "#.00") + "x" : "—", text_color=hasHighEffort ? tableWarningTextColor : tableTextColor, bgcolor=hasHighEffort ? tableWarningColor : tableValueColor, text_size=size.tiny)
        table.cell(dashboard, 0, 4, "NET PROGRESS", text_color=tableMutedTextColor, bgcolor=tableLabelColor, text_size=size.tiny)
        table.cell(dashboard, 1, 4, progressText, text_color=hasLowResult ? tableWarningTextColor : netProgress > 0.0 ? tablePositiveTextColor : netProgress < 0.0 ? tableNegativeTextColor : tableTextColor, bgcolor=hasLowResult ? tableWarningColor : tableValueColor, text_size=size.tiny)
        table.cell(dashboard, 0, 5, "LOCATION", text_color=tableMutedTextColor, bgcolor=tableLabelColor, text_size=size.tiny)
        table.cell(dashboard, 1, 5, locationText, text_color=tableTextColor, bgcolor=tableValueColor, text_size=size.tiny)
    else
        table.clear(dashboard, 0, 0, 1, 5)
````
