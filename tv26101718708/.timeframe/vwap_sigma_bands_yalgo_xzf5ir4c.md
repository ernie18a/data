# VWAP Sigma Bands [Y.Algo]

- url: https://www.tradingview.com/script/XZf5ir4C-VWAP-Sigma-Bands-Y-Algo/
- type: indicator
- pine_id: PUB;4ab4e1945a4a4bb79acf011b978f1280
- version: 2.0

## Description

VWAP Sigma Bands [Y.Algo] — Rolling VWAP, 6-Layer Deviation Bands, HTF Engine & Market State Panel

VWAP Sigma Bands turns the volume-weighted fair-value line into a complete mean-reversion and trend framework. A continuously rolling VWAP acts as the equilibrium anchor, six graduated standard-deviation bands map how stretched price is on both sides, and a momentum-confirmed reversal engine plus an on-chart Market State panel let you read the whole picture at a glance — built for crypto, futures, stocks, forex and indices on any intraday-to-daily timeframe.

Fully open-source (CC BY-NC-SA 4.0) — every calculation is documented below and visible in the script.

[b]🔶 USAGE[/b]

VWAP Sigma Bands is built around a "fair value → stretch → reversal" workflow. First read the VWAP midline: price trading above it favors longs, below it favors shorts, and a reclaim or loss of the line marks a regime shift. Next read the deviation bands: the inner zones are normal oscillation, the outer zones are statistically stretched areas where the odds of a snap-back rise. Finally, act on the reversal arrows, which only print when a band/line test lines up with an RSI momentum extreme.

Because every band is a potential support/resistance level, the indicator works equally well for two opposite styles. Mean-reversion traders fade the outer bands back toward VWAP; trend traders treat a decisive VWAP reclaim and an expanding band walk as continuation. The optional higher-timeframe engine lets a fast execution chart trade against a slower, more meaningful VWAP structure — for example reading the daily fair-value zones while entering on a 15-minute chart.

The Market State panel condenses all of this into one corner table — direction versus VWAP, the z-score (how many standard deviations price sits from fair value), the current zone, a composite bias, and RSI momentum status — so you get a same-side / overextended read without measuring anything by hand. Pair it with the alerts to be notified on VWAP crosses and confirmed reversals instead of watching the screen.

[b]🔹 Rolling VWAP Midline[/b]
The core anchor is a continuously rolling volume-weighted average price (over the last 200 bars by default, using hlc3 as the price source), not a session-reset VWAP. Because it rolls over a fixed window it never resets at the daily open, so it behaves consistently on 24/7 markets like crypto and across every timeframe. The line auto-colors to your bull/bear theme depending on whether price is above or below it, giving an instant trend-bias read. Treat reclaims and losses of this line as the primary regime trigger.

[b]🔹 6-Layer Standard Deviation Bands[/b]
Six bands are drawn above and below VWAP at one through six standard deviations (1σ–6σ), with graduated zone fills. σ is the volume-weighted standard deviation measured over the same rolling window as the VWAP. Inner layers contain normal, everyday oscillation, while the outer layers flag price stretched far from fair value, where mean-reversion probability climbs. Together they form a dynamic support/resistance grid that breathes with volatility — widening in fast markets, tightening in quiet ones. In linear mode each band is simply VWAP ± k·σ (symmetric). An optional geometric (log) mode instead plots VWAP × exp(±k·σ_rel) where σ_rel = σ / VWAP, making the bands asymmetric and proportional to percentage moves — the better fit for crypto and other high-volatility assets.

[b]🔹 Higher-Timeframe Engine[/b]
You can compute the VWAP and σ from a higher timeframe and project that structure onto your current chart, so a lower-timeframe entry chart can trade against a more significant fair-value reference. Only the VWAP and σ series are pulled via request.security and the twelve bands are then rebuilt locally to stay efficient. A repaint toggle switches between a responsive realtime fetch (which can repaint) and a confirmed, lookahead-based fetch (no repaint). Optional smoothing applies a triple-EMA to the VWAP and σ; because EMA is a linear operator, smoothing the center and σ is mathematically equivalent to smoothing every band.

[b]🔹 Momentum-Confirmed Reversal Arrows[/b]
Reversal triangles print only when two conditions align: price tests and rejects any band or the VWAP line (a touch within a tolerance, default 0.10σ, or a pierce that closes back), and RSI confirms momentum — by reaching overbought/oversold (default 70 / 30), crossing back out of those zones, or printing a regular RSI divergence (TradingView's standard pivot logic). This two-factor gate filters out the countless times price simply taps a band without reversing. An "extreme-outside" bypass keeps signals alive when price runs far beyond the outermost ±6σ band, and a pure band-cross mode (crossings of ±2σ to ±6σ) is available for traders who prefer raw crossings. Arrow size is adjustable.

[b]🔹 RSI-Strength Bar Coloring[/b]
Each candle can be gradient-colored by RSI strength around the 50 midline like a thermometer: a deep bull tone when RSI is washed out and turning up, neutral grey in the middle, and a deep bear tone when RSI is overheated. This turns the entire price chart into a momentum heat map so you can see strengthening and weakening without opening a separate subchart.

[b]🔹 Market State Panel[/b]
A compact on-chart table summarizes the current regime: price direction versus VWAP, the deviation z-score (close − VWAP) / σ, the active zone (core, inner, mid, or beyond), a composite bias (bullish, bearish, overbought-reversion or oversold-reversion), and live RSI momentum status. It is bilingual (Chinese / English), can be placed in any of the four chart corners, and offers four text sizes.

[b]🔶 DETAILS[/b]

VWAP Sigma Bands is fully open-source (CC BY-NC-SA 4.0). Here is exactly how it works.

Fair value & bands — On every bar the script computes a rolling volume-weighted average price over the last N bars (default 200), using hlc3 as the price source. From the same window it derives the volume-weighted variance, Σ(vol·price²)/Σvol − VWAP², and takes its square root to get the standard deviation σ. Six band levels are drawn at 1σ through 6σ on each side. Linear mode = VWAP ± k·σ (symmetric); geometric (log) mode = VWAP × exp(±k·σ_rel) with σ_rel = σ / VWAP, giving asymmetric bands that scale with percentage moves.

Higher timeframe — With the HTF engine on, only the VWAP and σ series are resolved from the higher timeframe via request.security; the twelve bands are rebuilt locally. The repaint toggle chooses between a realtime fetch and a confirmed lookahead fetch. Optional smoothing applies a triple-EMA to the VWAP and σ — since EMA is linear, ema(VWAP ± k·σ) ≡ ema(VWAP) ± k·ema(σ), so smoothing the two series is equivalent to smoothing every band.

Reversal logic — The engine combines a location test with an RSI momentum read. Location is true when price touches within the tolerance (default 0.10σ) of any band or the midline, or pierces a line and closes back. Momentum is true on any of three events inside a lookback window (default 5 bars): RSI reaching overbought/oversold (default 70 / 30), RSI crossing back out of those zones, or a regular RSI divergence. When price is parked beyond the outermost ±6σ band, the extreme-outside bypass drops the location requirement and signals on momentum alone. A pure band-cross mode is available as an alternative.

Bar coloring & panel — Candle coloring is a gradient driven by RSI around the 50 midline. The panel's deviation score is the z-score (close − VWAP) / σ, which also drives the zone and bias readouts.

All visuals share a unified theme system (Classic Warm / Neon Cool / Custom), so VWAP Sigma Bands integrates cleanly with the rest of the Y.Algo suite.

[b]🔶 SETTINGS[/b]

[b]🔹 VWAP Settings[/b]
[list]
[*][b]VWAP Length[/b]: Lookback window for the rolling VWAP and σ (default 200); also sets band width.
[*][b]Show StdDev Bands[/b]: Toggles the six deviation bands on each side.
[*][b]Fill Bands[/b]: Toggles the graduated zone fills between bands.
[*][b]Geometric (Log) Bands[/b]: Switches from linear VWAP ± k·σ to log bands VWAP × exp(±k·σ_rel) that scale with percentage moves — better for crypto / high-volatility assets.
[/list]

[b]🔹 Higher Timeframe[/b]
[list]
[*][b]Use Chart Timeframe[/b]: Anchors VWAP to the current chart timeframe; disable to set a higher timeframe manually.
[*][b]Higher Timeframe[/b]: The timeframe used when "Use Chart Timeframe" is off.
[*][b]Enable HTF Compute[/b]: Resolves VWAP/σ from real higher-timeframe data instead of approximating on the chart.
[*][b]Allow HTF Repaint[/b]: On = realtime but repaints; Off = confirmed (lookahead), no repaint.
[*][b]Smooth HTF[/b]: Applies a triple-EMA to the higher-timeframe VWAP and σ.
[*][b]Smoothing Factor[/b]: Divisor controlling the smoothing window length (larger = shorter window).
[/list]

[b]🔹 Display Settings[/b]
[list]
[*][b]Show Reversal Signal Arrows[/b]: Toggles the reversal triangle markers.
[*][b]Reversal Arrow Size[/b]: Tiny / Small / Normal / Large.
[*][b]RSI-Strength Bar Coloring[/b]: Gradient-colors candles by RSI strength around 50 (thermometer).
[/list]

[b]🔹 RSI Reversal Filter[/b]
[list]
[*][b]Reversal = Near-Line + RSI[/b]: Two-factor reversal (line test + RSI momentum); turn off for pure band-cross signals.
[*][b]RSI Length[/b]: Lookback for the RSI (default 14).
[*][b]RSI Overbought[/b]: Level treated as overheated, bearish momentum (default 70).
[*][b]RSI Oversold[/b]: Level treated as washed-out, bullish momentum (default 30).
[*][b]Near-Line Tolerance (×σ)[/b]: How close to a line counts as a test, in σ units (default 0.10).
[*][b]Momentum Window (bars)[/b]: How long an RSI event stays valid to pair with a line test (default 5).
[*][b]Also Trigger on RSI Divergence[/b]: Lets a regular RSI divergence count as momentum confirmation.
[*][b]Divergence Pivot Length[/b]: Pivot left/right bars for divergence (default 5; larger = stricter and later).
[*][b]Extreme-Outside RSI-Only[/b]: When price runs beyond ±6σ, bypass the line condition and signal on RSI alone.
[/list]

[b]🔹 Market State Panel[/b]
[list]
[*][b]Show Market State Panel[/b]: Toggles the on-chart summary table.
[*][b]Panel Position[/b]: Top Right / Bottom Right / Top Left / Bottom Left.
[*][b]Panel Language[/b]: Chinese / English.
[*][b]Panel Size[/b]: Tiny / Small / Normal / Large.
[/list]

[b]🔹 Color Theme[/b]
[list]
[*][b]Color Theme[/b]: Classic Warm / Neon Cool / Custom.
[*][b]Bull / Lower & Bear / Upper Color[/b]: Custom band colors, active only in Custom theme.
[/list]

[b]🔹 Alerts[/b]
[list]
[*][b]VWAP Cross-Up Alert[/b]: Price crosses above the VWAP midline.
[*][b]VWAP Cross-Down Alert[/b]: Price crosses below the VWAP midline.
[*][b]Bullish Reversal Alert[/b]: A confirmed bullish reversal (line test + RSI momentum) prints.
[*][b]Bearish Reversal Alert[/b]: A confirmed bearish reversal (line test + RSI momentum) prints.
[/list]

[b]🔶 DISCLAIMER[/b]

This indicator and all its signals, markers, and alerts are provided for technical analysis study and research reference only. They do not constitute investment advice, financial advice, trading recommendations, or solicitations to buy or sell any asset. Financial market trading involves substantial risk; investors may lose part or all of their principal. Past performance does not represent and does not guarantee future results. All trading decisions made using this indicator are the sole responsibility of the user. The author and publishing platform assume no legal liability. Please fully understand market rules and your own risk tolerance, and consult a licensed professional financial advisor when necessary.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━
中文版本 CHINESE VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VWAP Sigma Bands | VWAP 標準差帶 [Y.Algo] — 滾動 VWAP × 6 層標準差帶 × 高時間框架 × 市場狀態面板

VWAP Sigma Bands 把量價加權的公允價值線，升級成一套完整的均值回歸與順勢框架。持續滾動的 VWAP 作為平衡錨點，六層漸層標準差帶標示出價格在兩側偏離的程度，再搭配「動能確認反轉引擎」與圖上即時「市場狀態面板」，讓你一眼讀懂全局——適用加密貨幣、期貨、股票、外匯與指數，從當沖到日線各週期皆可套用。

完全開源（CC BY-NC-SA 4.0）——以下完整說明每一項計算，原始碼公開可查。

[b]🔶 用途說明[/b]

VWAP Sigma Bands 圍繞「公允價值 → 偏離 → 反轉」的工作流設計。第一步先看 VWAP 中線：價格在線上偏多、線下偏空，而站回或跌破中線即代表盤勢轉換。第二步看標準差帶：內層是正常震盪區間，外層則是統計上明顯偏離的區域，回歸機率隨之升高。最後再依「反轉箭頭」行動——只有當價格測試某條帶線／中線、同時 RSI 動能來到極端時，箭頭才會出現。

由於每一條帶線都是潛在的支撐／壓力位，這支指標可同時服務兩種相反的風格。均值回歸者於外層帶反向佈局、預期價格回拉 VWAP；順勢者則把果斷站回 VWAP 與帶寬擴張的「沿帶推進」視為續勢。選用的高時間框架引擎，讓快速的執行圖能對照較慢、較具意義的 VWAP 結構——例如以日線公允價值區為背景，於 15 分鐘圖進場。

市場狀態面板把以上資訊濃縮進角落單一表格——價格相對 VWAP 的方向、偏離 Z 值（價格距公允價值幾個標準差）、目前所在區間、綜合偏向、以及 RSI 動能狀態——不必手動測量，就能取得「同向／過度延伸」的判讀。再搭配警報，即可在 VWAP 穿越與確認反轉時收到通知，不必盯盤。

[b]🔹 滾動 VWAP 中線[/b]
核心錨點是「持續滾動」的量價加權平均（預設取最近 200 根、以 hlc3 為價格來源），而非每日重置的 session VWAP。因為它以固定窗口滾動、不在每日開盤歸零，所以在加密這類 24 小時市場與任何週期上行為都保持一致。中線會依價格位於其上或其下，自動套用多／空主題色，提供即時的趨勢偏向判讀。請把站回與跌破這條線，視為最主要的盤勢轉換觸發。

[b]🔹 6 層標準差帶[/b]
VWAP 上下各畫出 1σ 至 6σ 共六層標準差帶，並以漸層填充區隔。σ 為與 VWAP 同一滾動窗口計算的「量價加權標準差」。內層涵蓋日常的正常震盪，外層則標示出遠離公允價值、回歸機率攀升的延伸區。整體形成一張會「呼吸」的動態支撐／壓力網——行情快時擴張、盤整時收窄。線性模式下每條帶即 VWAP ± k·σ（對稱）；另提供幾何（對數）模式，改畫 VWAP × exp(±k·σ_rel)，其中 σ_rel = σ / VWAP，使帶呈上下不對稱、貼合百分比波動，對加密及其他高波動標的的擬合遠優於對稱線性帶。

[b]🔹 高時間框架引擎[/b]
你可以用較高週期的資料計算 VWAP 與 σ，並將該結構投影到當前圖表，讓較低週期的進場圖能對照更具份量的公允價值參考。僅 VWAP 與 σ 兩個序列透過 request.security 取得，十二條帶則於本地重建以維持效率。重繪開關可在「即時抓取（會重繪）」與「確認抓取（lookahead，不重繪）」之間切換。選用的平滑階段對 VWAP 與 σ 套用三重 EMA；由於 EMA 為線性算子，平滑中線與 σ 在數學上等同於平滑每一條帶。

[b]🔹 動能確認反轉箭頭[/b]
反轉三角只在兩個條件同時成立時出現：價格測試並拒絕了任一帶線或 VWAP 中線（觸及容差內，預設 0.10σ，或刺穿後收回），且 RSI 確認動能——達到超買／超賣（預設 70 / 30）、自該區翻轉穿越、或出現常規 RSI 背離（採 TradingView 標準樞軸邏輯）。這道雙重閘門能濾掉價格只是輕觸帶線卻未真正反轉的大量雜訊。另設「極端在外」旁路：當價格遠離最外層 ±6σ 帶時仍能給出訊號；也保留純帶穿越模式（±2σ 至 ±6σ 的穿越）給偏好原始穿越的交易者。箭頭大小可調整。

[b]🔹 RSI 強弱 K 棒著色[/b]
每根 K 棒可依 RSI 強弱（以 50 為中線）以漸層著色，宛如溫度計：RSI 極度衰竭並轉強時呈深多頭色、中性時為灰、過熱時呈深空頭色。整張價格圖因此化為一張動能熱力圖，不必另開副圖即可看出動能的增強與轉弱。

[b]🔹 市場狀態面板[/b]
圖上一個精巧表格即時統整當前盤勢：價格相對 VWAP 的方向、偏離 Z 值 (close − VWAP) / σ、所在區間（核心、內層、中層或更外）、綜合偏向（偏多、偏空、超買回歸或超賣回歸）、以及即時 RSI 動能狀態。面板支援中／英雙語、可放置於四個圖角、並提供四種文字大小。

[b]🔶 技術細節[/b]

VWAP Sigma Bands 完全開源（CC BY-NC-SA 4.0），以下完整說明運作方式。

公允價值與帶線——每根 K 棒計算最近 N 根（預設 200）、以 hlc3 為來源的滾動量價加權平均；自同一窗口推導量價加權變異數 Σ(vol·price²)/Σvol − VWAP²，開根號得標準差 σ。上下各畫 1σ 至 6σ 六層。線性模式 = VWAP ± k·σ（對稱）；幾何（對數）模式 = VWAP × exp(±k·σ_rel)，σ_rel = σ / VWAP，得到隨百分比波動縮放的不對稱帶。

高時間框架——開啟 HTF 引擎時，僅 VWAP 與 σ 序列以 request.security 自高週期解析，十二條帶於本地重建。重繪開關在即時抓取與確認 lookahead 抓取間擇一。選用平滑對 VWAP 與 σ 套三重 EMA——因 EMA 線性，ema(VWAP ± k·σ) ≡ ema(VWAP) ± k·ema(σ)，故平滑兩序列等同平滑每條帶。

反轉邏輯——引擎結合「位置測試」與「RSI 動能判讀」。位置：價格觸及任一帶線或中線容差內（預設 0.10σ），或刺穿後收回。動能：於回看窗口內（預設 5 根）任一事件成立——RSI 達超買／超賣（預設 70 / 30）、RSI 自該區翻轉穿越、或常規 RSI 背離。當價格停留於最外層 ±6σ 之外時，「極端在外」旁路會略過位置條件、純以動能給訊號。另提供純帶穿越模式作為替代。

K 棒著色與面板——K 棒著色為以 50 為中線、由 RSI 驅動的漸層。面板偏離分數即 Z 值 (close − VWAP) / σ，亦同時驅動區間與偏向判讀。

所有視覺共用統一主題色系（經典暖色／霓虹冷色／自訂），可無縫融入 Y.Algo 全系列指標的視覺語言。

[b]🔶 設定說明[/b]

[b]🔹 VWAP 設定[/b]
[list]
[*][b]VWAP 計算長度[/b]：滾動 VWAP 與 σ 的回看窗口（預設 200），亦決定帶寬。
[*][b]顯示標準差帶[/b]：開關上下各六層標準差帶。
[*][b]填充標準差帶[/b]：開關帶與帶之間的漸層區塊填充。
[*][b]幾何 (對數) 帶[/b]：由線性 VWAP ± k·σ 切換為隨百分比波動縮放的對數帶 VWAP × exp(±k·σ_rel)——更適合加密／高波動標的。
[/list]

[b]🔹 高時間框架[/b]
[list]
[*][b]使用圖表時間框架[/b]：將 VWAP 錨定於當前圖表週期；關閉後可於下方手動指定高週期。
[*][b]高時間框架[/b]：當「使用圖表時間框架」關閉時所採用的週期。
[*][b]啟用高時間框架運算[/b]：以真實高週期資料解析 VWAP/σ，而非於本圖近似估算。
[*][b]允許高時間框架重繪[/b]：開＝即時但會重繪；關＝確認（lookahead）、不重繪。
[*][b]平滑高時間框架[/b]：對高週期 VWAP 與 σ 套用三重 EMA。
[*][b]平滑因子[/b]：作為除數，控制平滑窗口長度（越大窗口越短）。
[/list]

[b]🔹 顯示設定[/b]
[list]
[*][b]顯示反轉訊號箭頭[/b]：開關反轉三角標記。
[*][b]反轉箭頭大小[/b]：極小／小／正常／大。
[*][b]RSI 強弱 K 棒著色[/b]：依 RSI 強弱（以 50 為中線）以漸層著色 K 棒（溫度計）。
[/list]

[b]🔹 RSI 反轉確認[/b]
[list]
[*][b]反轉＝接近線 + RSI 動能[/b]：位置測試＋RSI 動能的雙重反轉；關閉則為純帶穿越訊號。
[*][b]RSI 長度[/b]：RSI 的回看長度（預設 14）。
[*][b]RSI 超買門檻[/b]：判定為過熱、空頭動能的水準（預設 70）。
[*][b]RSI 超賣門檻[/b]：判定為超賣、多頭動能的水準（預設 30）。
[*][b]接近線容差 (×σ)[/b]：距帶線多近仍算作測試，以 σ 為單位（預設 0.10）。
[*][b]動能確認窗 (根)[/b]：RSI 事件可保持有效、用以搭配位置測試的根數（預設 5）。
[*][b]RSI 背離也觸發[/b]：讓常規 RSI 背離也計為動能確認。
[*][b]背離樞軸長度[/b]：背離偵測的樞軸左右根數（預設 5；越大越嚴格、確認越晚）。
[*][b]極端在外純看 RSI[/b]：價格遠離 ±6σ 時，略過位置條件，純以 RSI 給出訊號。
[/list]

[b]🔹 市場狀態面板[/b]
[list]
[*][b]顯示市場狀態面板[/b]：開關圖上的狀態統整表。
[*][b]面板位置[/b]：右上／右下／左上／左下。
[*][b]面板語言[/b]：中文／English。
[*][b]面板大小[/b]：極小／小／正常／大。
[/list]

[b]🔹 顏色主題[/b]
[list]
[*][b]顏色主題[/b]：經典暖色／霓虹冷色／自訂。
[*][b]多頭 / 下軌色與空頭 / 上軌色[/b]：自訂帶色，僅於自訂主題時生效。
[/list]

[b]🔹 警報[/b]
[list]
[*][b]VWAP 上穿警報[/b]：價格上穿 VWAP 中線。
[*][b]VWAP 下穿警報[/b]：價格下穿 VWAP 中線。
[*][b]多頭反轉警報[/b]：出現確認的多頭反轉（接近線＋RSI 動能）。
[*][b]空頭反轉警報[/b]：出現確認的空頭反轉（接近線＋RSI 動能）。
[/list]

[b]🔶 免責聲明[/b]

本指標及其所產生之所有信號、標記與警報，僅供技術分析學習與研究參考，不構成任何形式之投資建議、財務建議、交易推薦或買賣邀約。金融市場交易涉及高度風險，投資人可能損失部分或全部本金。過去表現不代表亦不保證未來結果。使用本指標之任何交易決策均由使用者自行判斷並承擔完全責任，作者與發布平台不負任何法律責任。請充分了解市場規則與自身風險承受能力，必要時諮詢具備合法資質的專業財務顧問。

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
//  VWAP Sigma Bands (VSB) — VWAP 標準差帶指標
//  滾動 VWAP + 6 層標準差帶｜高時間框架｜市場狀態面板｜外帶反轉訊號
//  Rolling VWAP + 6-layer StdDev Bands | HTF | Market State Panel | Reversals
//  © Y.Algo
//  Licensed under CC BY-NC-SA 4.0 — https://creativecommons.org/licenses/by-nc-sa/4.0/
// ════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("VWAP Sigma Bands | VWAP 標準差帶 [Y.Algo]", shorttitle="VSB [Y.Algo]", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// ════════════════════════════════════════════════════════════════════════════
// ██ 1. 函數 | Functions ██
// ════════════════════════════════════════════════════════════════════════════

// 滾動 VWAP + 標準差（只回傳兩量，12 條帶於本地計算 → 大幅減少 request.security）
// Rolling VWAP + StdDev (returns only two series; 12 bands computed locally)
computeVWAP(src, vol, len) =>
    sumVol     = 0.0   // Σ vol
    sumVolSrc  = 0.0   // Σ vol·src
    sumVolSrc2 = 0.0   // Σ vol·src²
    for i = 1 to len - 1
        sumVol     := sumVol     + vol[i]
        sumVolSrc  := sumVolSrc  + vol[i] * src[i]
        sumVolSrc2 := sumVolSrc2 + vol[i] * math.pow(src[i], 2)
    _vwap    = sumVolSrc / sumVol
    variance = sumVolSrc2 / sumVol - math.pow(_vwap, 2)
    variance := variance < 0 ? 0 : variance
    stDev    = math.sqrt(variance)
    [_vwap, stDev]

// 當前時間框架 → 分鐘 | Current timeframe to minutes
f_resInMinutes() =>
    timeframe.multiplier * (timeframe.isseconds ? 1. / 60. : timeframe.isminutes ? 1. : timeframe.isdaily ? 1440. : timeframe.isweekly ? 10080. : timeframe.ismonthly ? 43800. : na)

// 週期顯示字串（語言中性）| Pretty timeframe label (language-neutral)
f_tfStr() => timeframe.isseconds ? str.tostring(timeframe.multiplier) + "s" : timeframe.isminutes ? (timeframe.multiplier % 60 == 0 and timeframe.multiplier >= 60 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.isdaily ? str.tostring(timeframe.multiplier) + "D" : timeframe.isweekly ? str.tostring(timeframe.multiplier) + "W" : timeframe.ismonthly ? str.tostring(timeframe.multiplier) + "M" : timeframe.period

// 統一快訊函數：組裝動態訊息並依開關觸發 | Unified alert helper: builds the message and fires
f_alert(fire, zhEvent, enEvent) =>
    if fire
        alert("VSB｜" + syminfo.ticker + " " + f_tfStr() + " " + str.tostring(close, format.mintick) + "｜" + zhEvent + " | " + enEvent, alert.freq_once_per_bar_close)

// ════════════════════════════════════════════════════════════════════════════
// ██ 2. 輸入設定 | Inputs ██
// ════════════════════════════════════════════════════════════════════════════

gr_vwap = "═══ VWAP 設定 | VWAP Settings ═══"
_len       = input.int(200, "VWAP 計算長度 | VWAP Length", minval=2, group=gr_vwap, tooltip="滾動 VWAP 與標準差的回看窗口。\nLookback window for rolling VWAP & StdDev.")
showStd    = input.bool(true, "顯示標準差帶 | Show StdDev Bands", group=gr_vwap)
fill_bands = input.bool(true, "填充標準差帶 | Fill Bands", group=gr_vwap)
band_geometric = input.bool(true, "幾何 (對數) 帶 | Geometric (Log) Bands", group=gr_vwap, tooltip="關：線性帶 vwap ± k·σ（上下對稱）。開：幾何帶 vwap × exp(±k·σ_rel)，上下不對稱、貼合 % 波動，適合加密/高波動標的。\nOff: linear bands vwap ± k·σ (symmetric). On: geometric bands vwap × exp(±k·σ_rel), asymmetric & fit %-moves — better for crypto/high-vol assets.")

gr_htf = "═══ 高時間框架 | Higher Timeframe ═══"
useChartTF  = input.bool(true, "使用圖表時間框架 | Use Chart Timeframe", group=gr_htf, tooltip="關閉後可在下方手動指定高時間框架。\nDisable to manually set a higher timeframe below.")
HTF         = useChartTF ? timeframe.period : input.timeframe("D", "高時間框架 | Higher Timeframe", group=gr_htf)
HTF_switch  = input.bool(true, "啟用高時間框架運算 | Enable HTF Compute", group=gr_htf, tooltip="開啟：VWAP 以高週期資料計算並下放本圖。關閉：以本圖長度×膨脹倍數近似。\nOn: compute VWAP on HTF data. Off: approximate via dilation multiplier.")
HTFRepaints = input.bool(true, "允許高時間框架重繪 | Allow HTF Repaint", group=gr_htf, tooltip="開啟較即時但會重繪；關閉用 lookahead 取確認值不重繪。\nOn = realtime but repaints; Off = confirmed (no repaint).")
HTF_Smooth     = input.bool(true, "平滑高時間框架 | Smooth HTF", group=gr_htf)
HTF_Smooth_len = input.int(1, "平滑因子 | Smoothing Factor", minval=1, group=gr_htf, tooltip="作為除數：數值越大平滑窗口越短。\nUsed as divisor: larger value = shorter smoothing window.")

gr_display = "═══ 顯示設定 | Display Settings ═══"
show_signals = input.bool(true, "顯示反轉訊號箭頭 | Show Reversal Signal Arrows", group=gr_display, tooltip="反轉訊號箭頭（預設＝碰線拒絕 + RSI 超買超賣或背離，可於 RSI 群組切回純帶穿越）。\nReversal arrows (default = line-rejection + RSI OB/OS or divergence; switch to pure band-cross in the RSI group).")
sig_size_str = input.string("極小 | Tiny", "反轉箭頭大小 | Reversal Arrow Size", options=["極小 | Tiny", "小 | Small", "正常 | Normal", "大 | Large"], group=gr_display, tooltip="反轉訊號箭頭大小。\nSize of the reversal signal arrows.")
show_rsi_bars = input.bool(true, "RSI 強弱 K 棒著色 | RSI-Strength Bar Coloring", group=gr_display, tooltip="依 RSI 強弱漸層染 K 棒（趨勢溫度計）：超賣→多頭色、中性→灰、超買→空頭色。\nGradient-color bars by RSI strength (thermometer): oversold→bull, neutral→grey, overbought→bear.")

gr_rsi = "═══ RSI 反轉確認 | RSI Reversal Filter ═══"
use_rsi_filter   = input.bool(true, "反轉＝接近線 + RSI 動能 | Reversal = Near-Line + RSI", group=gr_rsi, tooltip="開：反轉 = 價格接近任一線（每條帶線＋VWAP 中線皆可能 S/R）＋下列任一 RSI 動能：①達到超買/超賣（近 N 根都算）②超買/超賣翻轉穿越 ③RSI 背離。關：純帶穿越（±2σ~±6σ）。\nOn: reversal = price near ANY line (every band + VWAP midline = potential S/R) AND any RSI momentum: (1) reached OB/OS within N bars, (2) OB/OS crossover, (3) RSI divergence. Off: pure band-cross.")
rsi_len          = input.int(14, "RSI 長度 | RSI Length", minval=1, group=gr_rsi)
rsi_ob           = input.int(70, "RSI 超買門檻 | RSI Overbought", minval=50, maxval=100, group=gr_rsi, tooltip="RSI 達到或翻轉穿越此值＝空頭動能。\nRSI reaching or crossing down this = bearish momentum.")
rsi_os           = input.int(30, "RSI 超賣門檻 | RSI Oversold", minval=0, maxval=50, group=gr_rsi, tooltip="RSI 達到或翻轉穿越此值＝多頭動能。\nRSI reaching or crossing up this = bullish momentum.")
near_tol         = input.float(0.10, "接近線容差 | Near-Line Tolerance (×σ)", minval=0.0, step=0.05, group=gr_rsi, tooltip="判定「接近線」的容差，以 σ 為單位。0＝必須觸及；越大越寬鬆。\nTolerance for 'near a line', in σ units. 0 = must touch; larger = looser.")
mom_window       = input.int(5, "動能確認窗 (根) | Momentum Window (bars)", minval=1, group=gr_rsi, tooltip="RSI 達到超買/超賣、翻轉穿越或背離後，幾根 K 內接近線仍可搭配觸發反轉。\nWithin how many bars of an RSI event (OB/OS reach, crossover, or divergence) a near-line touch can still fire.")
use_divergence   = input.bool(true, "RSI 背離也觸發 | Also Trigger on RSI Divergence", group=gr_rsi, tooltip="開：常規 RSI 背離（價格更高高點但 RSI 更低高點＝看跌；價格更低低點但 RSI 更高低點＝看漲）也算動能確認。\nOn: regular RSI divergence also counts as momentum.")
div_pivot_len    = input.int(5, "背離樞軸長度 | Divergence Pivot Length", minval=1, group=gr_rsi, tooltip="樞軸左右各幾根確認轉折；越大越嚴格、確認越晚。\nPivot left/right bars; larger = stricter & later.")
use_extreme_rsi  = input.bool(true, "極端在外純看 RSI | Extreme-Outside RSI-Only", group=gr_rsi, tooltip="價格極端、長時間待在最外帶（±6σ）之外時，「接近線」永遠不成立 → 反轉訊號鎖死。開啟後此情況自動略過接近線條件，純由 RSI 動能（達到/翻轉/背離）給訊號。\nWhen price stays extremely outside the outermost ±6σ band, 'near-line' never holds → reversals lock up. On: bypass the near-line condition there and signal purely on RSI momentum.")

gr_panel = "═══ 市場狀態面板 | Market State Panel ═══"
show_panel    = input.bool(true, "顯示市場狀態面板 | Show Market State Panel", group=gr_panel)
panel_pos_str = input.string("右上 | Top Right", "面板位置 | Panel Position", options=["右上 | Top Right", "右下 | Bottom Right", "左上 | Top Left", "左下 | Bottom Left"], group=gr_panel)
panelLang      = input.string("中文", "面板語言 | Panel Language", options=["中文", "English"], group=gr_panel, tooltip="切換面板顯示語言。\nSwitch panel display language.")
panel_size_str = input.string("小 | Small", "面板大小 | Panel Size", options=["極小 | Tiny", "小 | Small", "正常 | Normal", "大 | Large"], group=gr_panel, tooltip="市場狀態面板文字大小。\nText size of the Market State panel.")
// 雙語文字切換（依面板語言）| Bilingual text switch (by panel language)
f_txt(zh, en) => panelLang == "English" ? en : zh

// 顏色主題 | Color Theme
gr_theme = "═══ 顏色主題 | Color Theme ═══"
color_theme = input.string("經典暖色 | Classic Warm", "顏色主題 | Color Theme", options=["經典暖色 | Classic Warm", "霓虹冷色 | Neon Cool", "自訂 | Custom"], group=gr_theme, tooltip="Y.Algo 雙主題；切換「自訂」後於下方自訂顏色群組手動調色。\nY.Algo dual theme; switch to Custom to set colors manually below.")

gr_custom = "═══ 自訂顏色 | Custom Colors ═══"
custom_bull = input.color(#557571, "多頭 / 下軌色 | Bull / Lower", group=gr_custom, tooltip="僅在主題=自訂時生效。\nActive only when theme = Custom.")
custom_bear = input.color(#D49A89, "空頭 / 上軌色 | Bear / Upper", group=gr_custom, tooltip="僅在主題=自訂時生效。\nActive only when theme = Custom.")

// 依主題解析多空色 | Resolve bull/bear colors from theme
theme_bull = color_theme == "霓虹冷色 | Neon Cool" ? #00bcd4 : color_theme == "自訂 | Custom" ? custom_bull : #557571
theme_bear = color_theme == "霓虹冷色 | Neon Cool" ? #e91e63 : color_theme == "自訂 | Custom" ? custom_bear : #D49A89
col_neutral = #dbdbdb

// 透明度平衡：霓虹冷色偏亮，額外加透明度 | Transparency balance: neon cool is brighter, add extra transparency
band_alpha = color_theme == "霓虹冷色 | Neon Cool" ? 15 : 0

gr_alerts = "═══ 警報設定 | Alert Settings ═══"
alert_vwap_up   = input.bool(true, "VWAP 上穿警報 | VWAP Cross-Up Alert",   group=gr_alerts, tooltip="價格上穿 VWAP 時推送/可選條件（建立快訊時生效）。\nFires when price crosses above VWAP (applied when the alert is created).")
alert_vwap_down = input.bool(true, "VWAP 下穿警報 | VWAP Cross-Down Alert", group=gr_alerts, tooltip="價格下穿 VWAP 時推送/可選條件（建立快訊時生效）。\nFires when price crosses below VWAP (applied when the alert is created).")
alert_rev_bull  = input.bool(true, "多頭反轉警報 | Bullish Reversal Alert", group=gr_alerts, tooltip="接近線 + RSI 超賣/翻轉/背離（多頭反轉）。\nNear-line + RSI OS/cross/divergence (bullish).")
alert_rev_bear  = input.bool(true, "空頭反轉警報 | Bearish Reversal Alert", group=gr_alerts, tooltip="接近線 + RSI 超買/翻轉/背離（空頭反轉）。\nNear-line + RSI OB/cross/divergence (bearish).")

// 標準差倍數（標準 1~6 σ 層級，固定常數）| StdDev multipliers (standard 1–6 σ levels)
stDevMultiplier_1 = 1
stDevMultiplier_2 = 2
stDevMultiplier_3 = 3
stDevMultiplier_4 = 4
stDevMultiplier_5 = 5
stDevMultiplier_6 = 6

// ════════════════════════════════════════════════════════════════════════════
// ██ 3. 計算 | Calculations ██
// ════════════════════════════════════════════════════════════════════════════

src = hlc3
vol = volume

// 高週期膨脹倍數（估算 HTF 對本圖的 K 線數比例）| HTF dilation multiplier (global request.security)
chartResMin = f_resInMinutes()
htfResMin   = request.security(syminfo.tickerid, HTF, f_resInMinutes())
_mult       = htfResMin / chartResMin

// 有效計算長度（int 防呆 + 封頂，避免 float 迴圈邊界與歷史 buffer 溢位）| Effective length (int-guarded + capped)
lenEff = math.min(5000, math.max(2, int(HTF_switch ? _len : _len * _mult)))

[rVWAP, rStDev] = computeVWAP(src, vol, lenEff)

// 平滑窗口 | Smoothing window
vHtfSmoothLen = int(math.max(2, _len / HTF_Smooth_len))

// HTF 解析（全域 request.security，僅 VWAP + StdDev 兩量）| HTF resolution (global, 2 series only)
vwap_raw  = not HTF_switch ? rVWAP  : HTFRepaints ? request.security(syminfo.tickerid, HTF, rVWAP)  : request.security(syminfo.tickerid, HTF, rVWAP[1],  lookahead=barmerge.lookahead_on)
stdev_raw = not HTF_switch ? rStDev : HTFRepaints ? request.security(syminfo.tickerid, HTF, rStDev) : request.security(syminfo.tickerid, HTF, rStDev[1], lookahead=barmerge.lookahead_on)

// 三重 EMA 平滑（EMA 為線性算子 → ema(vwap±σ·k) ≡ ema(vwap)±k·ema(σ)）| Triple-EMA (linear → per-band equivalent)
vwap_out  = HTF_switch and HTF_Smooth ? ta.ema(ta.ema(ta.ema(vwap_raw,  vHtfSmoothLen), vHtfSmoothLen), vHtfSmoothLen) : vwap_raw
stdev_out = HTF_switch and HTF_Smooth ? ta.ema(ta.ema(ta.ema(stdev_raw, vHtfSmoothLen), vHtfSmoothLen), vHtfSmoothLen) : stdev_raw

// 本地計算 12 條帶 | Local 12-band computation
// 線性：vwap ± k·σ（對稱）｜幾何/對數：vwap × exp(±k·σ_rel)（上下不對稱，貼合 % 波動）
// Linear: vwap ± k·σ (symmetric) | Geometric: vwap × exp(±k·σ_rel) (asymmetric, fits %-moves)
rel = (not na(vwap_out) and vwap_out != 0) ? stdev_out / vwap_out : 0.0
stup1_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_1 * rel) : vwap_out + stdev_out * stDevMultiplier_1
stup2_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_2 * rel) : vwap_out + stdev_out * stDevMultiplier_2
stup3_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_3 * rel) : vwap_out + stdev_out * stDevMultiplier_3
stup4_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_4 * rel) : vwap_out + stdev_out * stDevMultiplier_4
stup5_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_5 * rel) : vwap_out + stdev_out * stDevMultiplier_5
stup6_out = band_geometric ? vwap_out * math.exp( stDevMultiplier_6 * rel) : vwap_out + stdev_out * stDevMultiplier_6
stdn1_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_1 * rel) : vwap_out - stdev_out * stDevMultiplier_1
stdn2_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_2 * rel) : vwap_out - stdev_out * stDevMultiplier_2
stdn3_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_3 * rel) : vwap_out - stdev_out * stDevMultiplier_3
stdn4_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_4 * rel) : vwap_out - stdev_out * stDevMultiplier_4
stdn5_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_5 * rel) : vwap_out - stdev_out * stDevMultiplier_5
stdn6_out = band_geometric ? vwap_out * math.exp(-stDevMultiplier_6 * rel) : vwap_out - stdev_out * stDevMultiplier_6

// ════════════════════════════════════════════════════════════════════════════
// ██ 4. 訊號 | Signals ██
// ════════════════════════════════════════════════════════════════════════════

vwapCrossUp   = ta.crossover(close, vwap_out)    // 價格上穿 VWAP | Price crosses above VWAP
vwapCrossDown = ta.crossunder(close, vwap_out)   // 價格下穿 VWAP | Price crosses below VWAP

// RSI 動能（反轉確認用）| RSI momentum (reversal confirmation)
rsi = ta.rsi(close, rsi_len)

// ── RSI 背離（對齊 TradingView 官方 RSI 背離邏輯；確認延遲 div_pivot_len 根，不重繪）| RSI divergence (TV-official logic)
div_rangeUpper = 60
div_rangeLower = 5
f_inRange(cond) =>
    bars = ta.barssince(cond)
    div_rangeLower <= bars and bars <= div_rangeUpper
rsiLBR  = rsi[div_pivot_len]
plFound = not na(ta.pivotlow(rsi,  div_pivot_len, div_pivot_len))
phFound = not na(ta.pivothigh(rsi, div_pivot_len, div_pivot_len))
// 預先求值以維持 ta.* 歷史狀態一致 | Pre-compute to keep ta.* history consistent
inRangePL = f_inRange(plFound[1])
inRangePH = f_inRange(phFound[1])
// 看漲背離：RSI 更高低點 + 價格更低低點 | Bullish: RSI higher-low + price lower-low
rsiHL   = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangePL
priceLL = low[div_pivot_len] < ta.valuewhen(plFound, low[div_pivot_len], 1)
bullDiv = plFound and rsiHL and priceLL
// 看跌背離：RSI 更低高點 + 價格更高高點 | Bearish: RSI lower-high + price higher-high
rsiLH   = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangePH
priceHH = high[div_pivot_len] > ta.valuewhen(phFound, high[div_pivot_len], 1)
bearDiv = phFound and rsiLH and priceHH

// ── 接近線：價格觸及/接近任一線(含 VWAP 中線)，容差 = near_tol×σ（每條都可能 S/R）| Near ANY line (incl. VWAP midline)
tol = stdev_out * near_tol
// 看跌位：高點接近某線(測試壓力) 或 上影刺穿後收回線下 | Bearish loc: high near a line, or pierced & closed back below
f_nearUp(L)   => (high >= L - tol and high <= L + tol) or (high >= L and close < L)
// 看漲位：低點接近某線(測試支撐) 或 下影刺穿後收回線上 | Bullish loc: low near a line, or pierced & closed back above
f_nearDown(L) => (low  <= L + tol and low  >= L - tol) or (low  <= L and close > L)
nearUp   = f_nearUp(stup6_out) or f_nearUp(stup5_out) or f_nearUp(stup4_out) or f_nearUp(stup3_out) or f_nearUp(stup2_out) or f_nearUp(stup1_out) or f_nearUp(vwap_out) or f_nearUp(stdn1_out) or f_nearUp(stdn2_out) or f_nearUp(stdn3_out) or f_nearUp(stdn4_out) or f_nearUp(stdn5_out) or f_nearUp(stdn6_out)
nearDown = f_nearDown(stdn6_out) or f_nearDown(stdn5_out) or f_nearDown(stdn4_out) or f_nearDown(stdn3_out) or f_nearDown(stdn2_out) or f_nearDown(stdn1_out) or f_nearDown(vwap_out) or f_nearDown(stup1_out) or f_nearDown(stup2_out) or f_nearDown(stup3_out) or f_nearDown(stup4_out) or f_nearDown(stup5_out) or f_nearDown(stup6_out)

// ── 動能確認（三路任一，皆容許近 mom_window 根）| Momentum: any of 3 paths, each within mom_window
//   ① 達到超買/超賣（狀態，近 N 根都算）② 翻轉穿越離開超買/超賣 ③ RSI 背離
bearReachOB = nz(ta.barssince(rsi >= rsi_ob), 1000000) <= mom_window
bullReachOS = nz(ta.barssince(rsi <= rsi_os), 1000000) <= mom_window
bearTurn    = nz(ta.barssince(ta.crossunder(rsi, rsi_ob)), 1000000) <= mom_window
bullTurn    = nz(ta.barssince(ta.crossover(rsi, rsi_os)),  1000000) <= mom_window
barsBearDiv = nz(ta.barssince(bearDiv), 1000000)
barsBullDiv = nz(ta.barssince(bullDiv), 1000000)
bearDivWin  = use_divergence and barsBearDiv <= mom_window
bullDivWin  = use_divergence and barsBullDiv <= mom_window
bearMom = bearReachOB or bearTurn or bearDivWin
bullMom = bullReachOS or bullTurn or bullDivWin

// 純帶穿越（任一 ±2σ~±6σ）— RSI 過濾關閉時的退路 | Pure band-cross fallback (filter off)
// 各條穿越先求值再合併，維持 ta.* 歷史狀態一致 | Pre-compute each cross, then combine
xDn2 = ta.crossunder(close, stup2_out)
xDn3 = ta.crossunder(close, stup3_out)
xDn4 = ta.crossunder(close, stup4_out)
xDn5 = ta.crossunder(close, stup5_out)
xDn6 = ta.crossunder(close, stup6_out)
xUp2 = ta.crossover(close, stdn2_out)
xUp3 = ta.crossover(close, stdn3_out)
xUp4 = ta.crossover(close, stdn4_out)
xUp5 = ta.crossover(close, stdn5_out)
xUp6 = ta.crossover(close, stdn6_out)
pureRevDown = xDn2 or xDn3 or xDn4 or xDn5 or xDn6
pureRevUp   = xUp2 or xUp3 or xUp4 or xUp5 or xUp6

// 極端在外：價格收在最外帶 ±6σ 之外（強趨勢遠離所有線）→ 接近線失效，純看 RSI | Extreme: close outside outermost ±6σ → bypass near-line, RSI-only
extremeAbove = close > stup6_out
extremeBelow = close < stdn6_out

// 最終反轉：(接近線 或 極端在外旁路) + 動能(達到/翻轉/背離)，取上升緣去重；或純帶穿越 | Final: (near-line OR extreme-outside) + momentum (rising-edge dedup), or pure cross
rawRevDown  = (nearUp   or (use_extreme_rsi and extremeAbove)) and bearMom
rawRevUp    = (nearDown or (use_extreme_rsi and extremeBelow)) and bullMom
bandRevDown = use_rsi_filter ? (rawRevDown and not rawRevDown[1]) : pureRevDown
bandRevUp   = use_rsi_filter ? (rawRevUp   and not rawRevUp[1])   : pureRevUp

// ════════════════════════════════════════════════════════════════════════════
// ██ 5. 繪圖 | Plotting ██
// ════════════════════════════════════════════════════════════════════════════

// 透明度梯度：基準對暖色在黑底清晰；冷色 +band_alpha 自動降亮（取平衡點）| baseline crisp for warm on black; cool gets +band_alpha to auto-balance
fill_colup = color.new(theme_bear, 74 + band_alpha)
fill_coldn = color.new(theme_bull, 74 + band_alpha)
vwap_col   = close > vwap_out ? theme_bull : theme_bear

Mid    = plot(vwap_out, "VWAP 中線 | VWAP", color=vwap_col, style=plot.style_stepline, linewidth=2)
s6up_A = plot(showStd ? stup6_out : na, "上軌 6 | Upper 6", color=color.new(theme_bear, 74 + band_alpha), style=plot.style_stepline, linewidth=2)
s5up_A = plot(showStd ? stup5_out : na, "上軌 5 | Upper 5", color=color.new(theme_bear, 64 + band_alpha), style=plot.style_stepline, linewidth=2)
s4up_A = plot(showStd ? stup4_out : na, "上軌 4 | Upper 4", color=color.new(theme_bear, 55 + band_alpha), style=plot.style_stepline, linewidth=2)
s3up_A = plot(showStd ? stup3_out : na, "上軌 3 | Upper 3", color=color.new(theme_bear, 50 + band_alpha), style=plot.style_stepline, linewidth=2)
s2up_A = plot(showStd ? stup2_out : na, "上軌 2 | Upper 2", color=color.new(theme_bear, 42 + band_alpha), style=plot.style_stepline, linewidth=2)
s1up_A = plot(showStd ? stup1_out : na, "上軌 1 | Upper 1", color=color.new(col_neutral, 62 + band_alpha), style=plot.style_stepline, linewidth=2)
s1dn_A = plot(showStd ? stdn1_out : na, "下軌 1 | Lower 1", color=color.new(col_neutral, 62 + band_alpha), style=plot.style_stepline, linewidth=2)
s2dn_A = plot(showStd ? stdn2_out : na, "下軌 2 | Lower 2", color=color.new(theme_bull, 42 + band_alpha), style=plot.style_stepline, linewidth=2)
s3dn_A = plot(showStd ? stdn3_out : na, "下軌 3 | Lower 3", color=color.new(theme_bull, 50 + band_alpha), style=plot.style_stepline, linewidth=2)
s4dn_A = plot(showStd ? stdn4_out : na, "下軌 4 | Lower 4", color=color.new(theme_bull, 55 + band_alpha), style=plot.style_stepline, linewidth=2)
s5dn_A = plot(showStd ? stdn5_out : na, "下軌 5 | Lower 5", color=color.new(theme_bull, 64 + band_alpha), style=plot.style_stepline, linewidth=2)
s6dn_A = plot(showStd ? stdn6_out : na, "下軌 6 | Lower 6", color=color.new(theme_bull, 74 + band_alpha), style=plot.style_stepline, linewidth=2)

fill(s6up_A, s5up_A, color=fill_bands ? fill_colup : na, title="上方外帶填充 | Upper Outer Fill")
fill(s3up_A, s2up_A, color=fill_bands ? fill_colup : na, title="上方內帶填充 | Upper Inner Fill")
fill(s3dn_A, s2dn_A, color=fill_bands ? fill_coldn : na, title="下方內帶填充 | Lower Inner Fill")
fill(s6dn_A, s5dn_A, color=fill_bands ? fill_coldn : na, title="下方外帶填充 | Lower Outer Fill")

// 反轉標記（用 label 以支援可調大小）| Reversal markers (label supports adjustable size)
lbl_size = switch sig_size_str
    "極小 | Tiny" => size.tiny
    "正常 | Normal" => size.normal
    "大 | Large"  => size.large
    => size.small
if show_signals and bandRevDown
    label.new(bar_index, high, "", yloc=yloc.abovebar, style=label.style_triangledown, color=theme_bear, size=lbl_size)
if show_signals and bandRevUp
    label.new(bar_index, low, "", yloc=yloc.belowbar, style=label.style_triangleup, color=theme_bull, size=lbl_size)

// RSI 強弱漸層 K 棒著色：實體+外框+影線(針尖)全著色、完全不透明（最明顯）| RSI gradient candles: body+border+wick, fully opaque
bar_neutral = #888888
rsiGrad = rsi >= 50 ? color.from_gradient(rsi, 50, rsi_ob, bar_neutral, theme_bear) : color.from_gradient(rsi, rsi_os, 50, theme_bull, bar_neutral)
rc_o = show_rsi_bars ? open  : na
rc_h = show_rsi_bars ? high  : na
rc_l = show_rsi_bars ? low   : na
rc_c = show_rsi_bars ? close : na
plotcandle(rc_o, rc_h, rc_l, rc_c, title="RSI 強弱 K 棒 | RSI-Strength Bars", color=rsiGrad, wickcolor=rsiGrad, bordercolor=rsiGrad)

// ════════════════════════════════════════════════════════════════════════════
// ██ 6. 市場狀態面板 | Market State Panel ██
// ════════════════════════════════════════════════════════════════════════════

panelPos = switch panel_pos_str
    "右下 | Bottom Right" => position.bottom_right
    "左上 | Top Left"     => position.top_left
    "左下 | Bottom Left"  => position.bottom_left
    => position.top_right

panel_size = switch panel_size_str
    "極小 | Tiny"  => size.tiny
    "正常 | Normal" => size.normal
    "大 | Large"   => size.large
    => size.small

var table msPanel = na
if show_panel and barstate.islast
    z       = not na(stdev_out) and stdev_out != 0 and not na(vwap_out) ? (close - vwap_out) / stdev_out : 0.0
    absz    = math.abs(z)
    isBull  = close >= vwap_out
    posTxt  = isBull ? f_txt("多頭 ▲", "Above ▲") : f_txt("空頭 ▼", "Below ▼")
    posCol  = isBull ? theme_bull : theme_bear
    zoneTxt = absz < 1 ? f_txt("VWAP 核心", "Core") : absz < 2 ? "±1σ ~ ±2σ" : absz < 3 ? "±2σ ~ ±3σ" : f_txt("±3σ 外", "Beyond ±3σ")
    biasTxt = z > 2 ? f_txt("超買回歸", "Overbought") : z < -2 ? f_txt("超賣回歸", "Oversold") : isBull ? f_txt("偏多", "Bullish") : f_txt("偏空", "Bearish")
    biasCol = z > 2 ? theme_bear : z < -2 ? theme_bull : isBull ? theme_bull : theme_bear
    rsiStat = rsi >= rsi_ob ? f_txt("超買", "OB") : rsi <= rsi_os ? f_txt("超賣", "OS") : f_txt("中性", "Neutral")
    rsiCol  = rsi >= rsi_ob ? theme_bear : rsi <= rsi_os ? theme_bull : color.new(color.white, 25)

    msPanel := table.new(panelPos, 2, 7, bgcolor=#000000, border_color=#2e2e2e, border_width=1, frame_color=#2e2e2e, frame_width=1)
    // Row 0 — Y.Algo 品牌標題列 | Brand header row
    table.cell(msPanel, 0, 0, "Y.Algo",    text_color=#FFD740, text_size=panel_size, text_halign=text.align_center, bgcolor=#1a1a1a)
    table.cell(msPanel, 1, 0, "VSB V2.0", text_color=#FFD740, text_size=panel_size, text_halign=text.align_center, bgcolor=#1a1a1a)
    // Row 1 — 區段標題（右欄顯示當前週期）| Section title (right cell shows chart timeframe)
    table.cell(msPanel, 0, 1, f_txt("市場狀態", "Market State"), text_color=color.white, text_size=panel_size, text_halign=text.align_center, bgcolor=#1a1a1a)
    table.cell(msPanel, 1, 1, f_tfStr(),                         text_color=#a0a0a0,     text_size=panel_size, text_halign=text.align_center, bgcolor=#1a1a1a)
    // Row 2 — 價格 vs VWAP
    table.cell(msPanel, 0, 2, f_txt("價格 vs VWAP", "Price vs VWAP"), text_color=#a0a0a0, text_size=panel_size, text_halign=text.align_center)
    table.cell(msPanel, 1, 2, posTxt, text_color=posCol, text_size=panel_size, text_halign=text.align_center)
    // Row 3 — 偏離 Z 值
    table.cell(msPanel, 0, 3, f_txt("偏離 Z 值", "Z-Score"), text_color=#a0a0a0, text_size=panel_size, text_halign=text.align_center)
    table.cell(msPanel, 1, 3, str.tostring(z, "0.00"), text_color=biasCol, text_size=panel_size, text_halign=text.align_center)
    // Row 4 — 所在區間
    table.cell(msPanel, 0, 4, f_txt("所在區間", "Zone"), text_color=#a0a0a0, text_size=panel_size, text_halign=text.align_center)
    table.cell(msPanel, 1, 4, zoneTxt, text_color=color.white, text_size=panel_size, text_halign=text.align_center)
    // Row 5 — 綜合偏向
    table.cell(msPanel, 0, 5, f_txt("綜合偏向", "Bias"), text_color=#a0a0a0, text_size=panel_size, text_halign=text.align_center)
    table.cell(msPanel, 1, 5, biasTxt, text_color=biasCol, text_size=panel_size, text_halign=text.align_center)
    // Row 6 — RSI 動能
    table.cell(msPanel, 0, 6, f_txt("RSI 動能", "RSI"), text_color=#a0a0a0, text_size=panel_size, text_halign=text.align_center)
    table.cell(msPanel, 1, 6, str.tostring(rsi, "0.0") + "  " + rsiStat, text_color=rsiCol, text_size=panel_size, text_halign=text.align_center)

// ════════════════════════════════════════════════════════════════════════════
// ██ 7. 警報 | Alerts ██
// ════════════════════════════════════════════════════════════════════════════

// alertcondition：TV 警報對話框的具名條件（由開關閘控；{{ }} 佔位符由 TradingView 填入）
// alertcondition: named conditions for the TV alert dialog ({{ }} placeholders filled by TradingView)
alertcondition(alert_vwap_up   and vwapCrossUp,   "VWAP 上穿 | Cross Above VWAP", "VSB｜{{ticker}} {{interval}} {{close}}｜價格上穿 VWAP | Price crossed above VWAP")
alertcondition(alert_vwap_down and vwapCrossDown, "VWAP 下穿 | Cross Below VWAP", "VSB｜{{ticker}} {{interval}} {{close}}｜價格下穿 VWAP | Price crossed below VWAP")
alertcondition(alert_rev_bull  and bandRevUp,     "多頭反轉 | Bullish Reversal",  "VSB｜{{ticker}} {{interval}} {{close}}｜多頭反轉 Bullish Reversal")
alertcondition(alert_rev_bear  and bandRevDown,   "空頭反轉 | Bearish Reversal",  "VSB｜{{ticker}} {{interval}} {{close}}｜空頭反轉 Bearish Reversal")

// alert() 即時推送：每根收盤觸發一次 | Runtime push via alert() (once per bar close)
f_alert(alert_vwap_up   and vwapCrossUp,   "價格上穿 VWAP", "Price crossed above VWAP")
f_alert(alert_vwap_down and vwapCrossDown, "價格下穿 VWAP", "Price crossed below VWAP")
f_alert(alert_rev_bull  and bandRevUp,     "多頭反轉",      "Bullish Reversal")
f_alert(alert_rev_bear  and bandRevDown,   "空頭反轉",      "Bearish Reversal")
````
