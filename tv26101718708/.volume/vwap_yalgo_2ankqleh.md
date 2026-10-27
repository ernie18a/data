# VWAP+ [Y.Algo]

- url: https://www.tradingview.com/script/2aNKQLeh-VWAP-Y-Algo/
- type: indicator
- pine_id: PUB;ff073185fbcd492989807b6d8aa1ce01
- version: 2.0

## Description

VWAP+ [Y.Algo] — Five Anchored VWAPs, Rolling Multi-Exchange VWAP Bands, Previous-Period Zones & Session Initial Balance

VWAP+ layers up to nine independent VWAP structures on a single chart — five freely anchored VWAPs (Day through Year), four rolling-window VWAPs with optional cross-exchange aggregated volume, a snapshot of the previous completed period's VWAP channel, and a session Initial Balance box — so you can read fair value across every timeframe you trade at once, without switching charts or stacking multiple indicators.

Fully open-source (CC BY-NC-SA 4.0) — every calculation is documented below and visible in the script.

[b]🔶 USAGE[/b]

VWAP+ is built as a multi-timeframe fair-value reference wall rather than a single-signal indicator. Instead of one VWAP, you can stack five independently anchored VWAPs (assign each to Day, Week, Month, Quarter, or Year) alongside four rolling VWAPs on any day-count window you like, and watch how price behaves against all of them at once. When several VWAPs converge into a tight band, that price zone tends to act as a stronger confluence support/resistance; when they fan apart, the market is caught between competing fair-value references on different horizons.

Anchored VWAPs are best for framing swing/position bias — set slots to Week, Month, Quarter and Year to see at a glance whether price sits above or below the "institutional" fair value on each horizon simultaneously, and treat a reclaim or loss of any of them as a potential regime shift on that timeframe. Rolling VWAPs behave differently: because they use a fixed trailing time window instead of resetting at a period boundary, they never gap at a session or period open, which makes them a smoother, more consistent reference on 24-hour markets like crypto.

The Previous VWAP Markers extend a fixed snapshot of the last (or second-to-last) completed period's VWAP channel to the right edge of the chart, giving you a static historical reference band to judge whether current price is trading rich or cheap relative to where the market closed out its last day, week, month, quarter, or year. Combine this with the Initial Balance box — built from the first hour of the Tokyo session — as a session-range reference, and use the touch alerts so you don't have to watch every VWAP manually.

[b]🔹 Background Mode — Three-Way Color Management[/b]
VWAP+ carries no bull/bear theme, since it's a reference-line tool rather than a trend/signal indicator. Instead, a single three-way Background Mode switch governs the color of every VWAP, deviation band, previous-period marker, and Initial Balance box at once. Dark Background and Light Background each lock in a fixed palette tuned for that chart tone and override every individual color picker below, so most users can flip one switch and never worry about visibility again. Switching to Custom releases that lock — every color you've set on each VWAP, band, marker, and the IB box is used exactly as configured, putting visibility fully in your hands. In total, 36 individual color settings across five anchored VWAPs, four rolling VWAPs, eight previous-period markers, and the Initial Balance box are governed by this one switch.

[b]🔹 Five Independent Anchored VWAPs[/b]
Five separate VWAP slots (VWAP1–VWAP5) can each be assigned its own anchor period — Day, Week, Month, Quarter, or Year — and toggled on independently, all off by default so you build exactly the combination you need. Each slot plots its own VWAP line plus a 1-standard-deviation upper/lower band with a fillable zone, all in fully customizable colors, letting you view several timeframes' fair value simultaneously on one chart.

[b]🔹 Previous-Period VWAP Zone Markers[/b]
Eight independent toggles (previous day, week, two-back week, month, two-back month, quarter, two-back quarter, and year) each draw the corresponding completed period's VWAP channel — upper band, lower band, and VWAP line — as a box and labeled line projected to the right edge of the chart. This is a frozen historical snapshot, not a live-updating series, giving you a stable reference to compare current price against where the market's fair value settled in a prior period.

[b]🔹 Rolling VWAP with Optional Multi-Exchange Aggregated Volume[/b]
Four independent rolling-window VWAPs (7D/30D/90D/365D by default, but each day-count is fully adjustable from a preset list) compute a true trailing-window VWAP that never resets at a period boundary. An optional aggregated-volume mode combines volume from up to four separately configured symbols (defaulting to BTC pairs across four major exchanges, but changeable to any instrument) before feeding the VWAP calculation — useful for markets where volume is fragmented across multiple venues. Deviation bands around each rolling VWAP can be switched between a percentage-based Symmetrical mode and a statistical Standard (standard-deviation) mode, with an adjustable multiplier controlling band width.

[b]🔹 Initial Balance Range (Tokyo Session)[/b]
A box is drawn from the Tokyo trading session (09:00–15:00), with its high/low seeded by the first hour of that session (09:00–10:00) — the classic "Initial Balance" concept from auction market theory. The box extends across the full session and a configurable number of recent days remain visible on the chart, letting you gauge whether the current session is breaking out of, or staying contained within, its opening-hour range.

[b]🔹 Touch Alert System[/b]
Nine independently toggleable alerts fire the instant price wicks touch any enabled anchored VWAP (VWAP1–VWAP5) or rolling VWAP (7D/30D/90D/365D), regardless of approach direction — a direction-agnostic heads-up that price has reached a fair-value reference worth reviewing, delivered once per bar close.

[b]🔶 DETAILS[/b]

VWAP+ is fully open-source (CC BY-NC-SA 4.0). Here is exactly how it works.

Background palette — Dark and Light modes each route every color input through a single switch function into one of two hard-coded palettes: a high-transparency white-based set for Dark backgrounds, or a darker navy/grey set for Light backgrounds. While either fixed mode is active, the color pickers below are still evaluated but their values are discarded. Selecting Custom short-circuits that switch and returns each color input unchanged, so every picker takes effect.

Anchored VWAPs — Each of the five slots calls Pine Script's built-in ta.vwap(source, new-period-flag, 1) on hlc3, where the new-period flag fires on timeframe.change('D'/'W'/'M'/'3M'/'12M') depending on the chosen anchor. The VWAP and its bands reset to zero accumulation at the start of each anchor period; the multiplier of 1 draws bands at one volume-weighted standard deviation of price around the VWAP, widening or narrowing as the period progresses.

Previous-period markers — On every bar the script caches the just-completed period's upper band, lower band, and VWAP value (sampled one bar before the reset). Once the chart reaches its last bar, these cached values are drawn once as a static box, a dotted VWAP line, and three labels — they do not update afterward; they are a fixed snapshot, not a live series.

Rolling VWAP — Unlike the anchored VWAPs, this path uses the PineCoders ConditionalAverages library to sum price×volume, volume, and volume×price² over a fixed trailing time window (the day-count converted to milliseconds), computed fresh on every bar: VWAP = Σ(price·volume)/Σvolume, variance = Σ(volume·price²)/Σvolume − VWAP² (floored at zero), σ = √variance. In Standard mode, bands = VWAP ± multiplier×σ. In Symmetrical mode, bands = VWAP ± (multiplier/100)×VWAP — a flat percentage envelope rather than a statistical one.

Aggregated volume — When enabled, the script pulls volume via request.security from up to four independently configured symbols and sums them before it feeds the rolling VWAP formula above, in place of using only the current chart's own volume. This is designed for instruments whose real volume is fragmented across multiple venues (the default four fields point at the same crypto pair listed on four different exchanges), but the symbol fields can be changed to any ticker.

Initial Balance — Two Tokyo-time session windows are compared bar-by-bar: a 1-hour opening range (09:00–10:00) that seeds a box's high/low the moment it starts, and the surrounding full session (09:00–15:00) across which that box's right edge is extended. A rolling array retains only the most recent N day-boxes (the configured day count), deleting the oldest box once that limit is exceeded.

Alerts — Every alert fires at most once per bar close, formatted as: VWAP+｜{ticker} {timeframe} {price}｜{event name}.

[b]🔶 SETTINGS[/b]

[b]🔹 Background Mode[/b]
[list]
[*][b]Background Mode[/b]: Dark Background (default) / Light Background / Custom. Dark and Light each lock every VWAP, band, previous-period marker, and IB color to a fixed palette tuned for that background tone — the color pickers below have no effect in these two modes. Custom releases the lock and uses exactly the color you've set on each line.
[/list]

[b]🔹 Anchored VWAP Settings (VWAP1–VWAP5, five independent slots)[/b]
[list]
[*][b]VWAP1 / VWAP2 / VWAP3 / VWAP4 / VWAP5[/b]: Enables that slot; all five are off by default.
[*][b]Anchor Period[/b]: Day / Week / Month / Quarter / Year — sets when that slot's VWAP resets.
[*][b]VWAP[/b]: Line color for that slot.
[*][b]Bands[/b]: Color for the 1-standard-deviation upper/lower bands.
[*][b]Fill[/b]: Color for the band-fill zone.
[/list]

[b]🔹 Previous VWAP Markers[/b]
[list]
[*][b]pDay / pWeek / ppWeek / pMonth / ppMonth / pQuarter / ppQuarter / pYear[/b]: Each toggle draws that completed period's VWAP channel (box + line + labels) projected to the right of the chart; all off by default.
[*][b]Color (per marker)[/b]: Sets the box/line/label tint for that specific marker.
[/list]

[b]🔹 Rolling VWAP[/b]
[list]
[*][b]7D / 30D / 90D / 365D[/b]: Enables that rolling-window slot; all four are on by default.
[*][b]Day Count[/b]: Choose the rolling window length from a preset list (1/3/5/7/14/21/28/30/60/90/182/365 days) — independent of the slot's label.
[*][b]RVWAP[/b]: Line color for that slot's rolling VWAP.
[*][b]Bands[/b]: Color for that slot's deviation bands.
[*][b]Fill[/b]: Color for that slot's band-fill zone.
[/list]

[b]🔹 Rolling VWAP StdDev Bands[/b]
[list]
[*][b]Use Aggregated Volume[/b]: Combines volume from the checked exchanges below into the rolling VWAP calculation instead of using only the current chart's volume.
[*][b]Deviation Bands[/b]: Symmetrical (flat percentage bands around VWAP) or Standard (statistical standard-deviation bands).
[*][b]Multiplier[/b]: Scales band width (minimum 0.5, in steps of 0.5).
[*][b]Exchange 1 / 2 / 3 / 4[/b]: Toggles whether that symbol's volume is included in the aggregate.
[*][b]Symbol fields (Exchange 1–4)[/b]: Set which instrument's volume feeds each exchange slot — default to the same pair across four major exchanges, but any symbol can be used.
[/list]

[b]🔹 Initial Balance Range[/b]
[list]
[*][b]Show IB Range[/b]: Toggles the Initial Balance box, built from the Tokyo session (09:00–15:00, with the 09:00–10:00 opening range defining the box's high/low).
[*][b]Days[/b]: How many days of IB boxes stay visible before the oldest is removed.
[*][b]Color[/b]: Box border/fill tint.
[/list]

[b]🔹 Alerts[/b]
[list]
[*][b]VWAP1–VWAP5 Touch[/b]: Fires once per bar close the instant price wicks touch that anchored VWAP, regardless of direction (that VWAP must be enabled).
[*][b]7D/30D/90D/365D RVWAP Touch[/b]: Same touch logic for each enabled rolling VWAP.
[/list]

[b]🔶 DISCLAIMER[/b]

This indicator and all its signals, markers, and alerts are provided for technical analysis study and research reference only. They do not constitute investment advice, financial advice, trading recommendations, or solicitations to buy or sell any asset. Financial market trading involves substantial risk; investors may lose part or all of their principal. Past performance does not represent and does not guarantee future results. All trading decisions made using this indicator are the sole responsibility of the user. The author and publishing platform assume no legal liability. Please fully understand market rules and your own risk tolerance, and consult a licensed professional financial advisor when necessary.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━
中文版本 CHINESE VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VWAP+ | 多重VWAP通道 [Y.Algo] — 5組獨立錨定VWAP、滾動多交易所VWAP帶、前期區間標記與時段初始平衡

VWAP+ 在同一張圖表上疊加最多九組獨立的 VWAP 結構——五組可自由錨定的 VWAP（日至年）、四組可選聚合多交易所成交量的滾動 VWAP、前一完整週期 VWAP 通道的靜態快照，以及一個時段初始平衡箱型——讓你不必切圖或疊多個指標，就能同時讀懂各個你在交易的時框上的公允價值。

完全開源（CC BY-NC-SA 4.0）——以下完整說明每一項計算，原始碼公開可查。

[b]🔶 用途說明[/b]

VWAP+ 的設計是一整面「多時框公允價值參考牆」，而非單一訊號指標。你可以疊上五組獨立錨定的 VWAP（各自指定日／週／月／季／年），再搭配四組可自訂天數窗口的滾動 VWAP，同時觀察價格對所有這些線的相對位置。當多條 VWAP 收斂成一條窄帶，該價格區往往形成較強的支撐壓力匯聚；當它們彼此散開，代表市場正被不同時框的公允價值參考拉扯。

錨定 VWAP 較適合用來框定波段／部位偏向——把插槽設定為週、月、季、年，即可一眼看出價格是否同時站在（或跌破）各個時框的「機構級」公允價值之上，並把任一條線的站回或跌破視為該時框上潛在的盤勢轉換。滾動 VWAP 的行為不同：因為它以固定的回看時間窗滾動、而非在週期邊界重置，所以不會在時段或週期開盤時跳空，在加密貨幣這類 24 小時市場上是更平滑、更一致的參考線。

前期 VWAP 標記會把上一個（或上上一個）已完整結束週期的 VWAP 通道，以固定快照的形式投影到圖表右側，讓你有一條靜態的歷史參考帶，用來判斷目前價格相對於市場上次收在哪個公允價值區間是偏貴還是偏便宜。搭配以東京時段第一小時建立的初始平衡箱型作為時段區間參考，再啟用觸及警報，就不必手動盯著每一條 VWAP。

[b]🔹 背景模式——三段式配色管理[/b]
VWAP+ 沒有多空主題色（因為它是參考線工具，不是趨勢／訊號指標），改用「背景模式」三選一，一次管理所有 VWAP、標準差帶、前期標記與 IB 框的顏色。黑色背景與白色背景各自鎖定一組對應該背景色調的固定配色，並會覆蓋下方每一條線的個別顏色設定，讓大多數人一鍵切換就不必煩惱可見度。切到「自訂」則解除鎖定，完全依你在每條 VWAP、每組標準差帶、每個前期標記與 IB 框個別設定的顏色顯示，可見度自己把關。全指標共 36 個顏色設定點——5 條錨定 VWAP、4 條滾動 VWAP、8 個前期 VWAP 標記、1 個 IB 區間框——皆由這個開關統一控管。

[b]🔹 5組獨立錨定 VWAP[/b]
五個獨立的 VWAP 插槽（VWAP1–VWAP5）各自可指定錨定週期——日、週、月、季、年——並各自獨立開關，預設全部關閉，讓你自由組合出所需的時框組合。每個插槽各自繪製其 VWAP 線，搭配 1 個標準差的上下帶與可填色區域，顏色皆可完全自訂，讓你在同一張圖上同時檢視多個時框的公允價值。

[b]🔹 前期 VWAP 區間標記[/b]
八個獨立開關（前日、前週、前前週、前月、前前月、前季、前前季、前年）各自會把對應已結束週期的 VWAP 通道——上帶、下帶與 VWAP 線——以箱型加標籤線的形式投影到圖表右側。這是一個凍結的歷史快照，而非即時更新的序列，提供一條穩定的參考帶，用來比較目前價格相對於市場上一個週期收在哪個公允價值區間。

[b]🔹 4組滾動 VWAP（可選聚合多交易所成交量）[/b]
四組獨立的滾動窗口 VWAP（預設 7D／30D／90D／365D，天數皆可從預設清單自由調整）計算真正的「回看時間窗」VWAP，不隨任何週期邊界重置。可選的聚合成交量模式會合併最多四個獨立設定標的的成交量（預設指向四大交易所的 BTC 交易對，但可改為任何標的）後再送入 VWAP 計算——適合成交量分散在多個交易場所的市場。每組滾動 VWAP 周圍的偏差帶，可在「百分比對稱」與「統計標準差」兩種模式間切換，並可用倍數調整帶寬。

[b]🔹 初始平衡區間（東京時段）[/b]
以東京交易時段（09:00–15:00）畫出箱型，其高低點由該時段的第一小時（09:00–10:00）決定——這正是拍賣市場理論中經典的「初始平衡（Initial Balance）」概念。箱型會延伸涵蓋整個時段，且可設定保留在圖表上的天數，讓你判斷當前時段是正在突破、還是仍被限制在開盤第一小時的區間內。

[b]🔹 觸及警報系統[/b]
九個獨立開關的警報，會在價格影線碰觸任一啟用中的錨定 VWAP（VWAP1–VWAP5）或滾動 VWAP（7D/30D/90D/365D）的瞬間觸發，不分逼近方向——單純提醒你價格已到達一條值得關注的公允價值參考線，於每根 K 棒收盤時最多觸發一次。

[b]🔶 技術細節[/b]

VWAP+ 完全開源（CC BY-NC-SA 4.0），以下完整說明運作方式。

背景配色——黑色與白色模式皆透過同一個切換函數，把每個顏色設定對應到兩組寫死的固定配色之一：黑色背景使用高透明度的白階配色，白色背景使用較深的藏青／灰階配色。固定模式生效時，下方的顏色選擇器仍會被讀取，但其數值會被捨棄不用。選擇自訂則直接跳過此切換，原樣傳回你所設定的每個顏色，讓每個選色器都實際生效。

錨定 VWAP——五個插槽各自呼叫 Pine Script 內建函數 ta.vwap(source, 週期起始旗標, 1)，以 hlc3 為價格來源；週期起始旗標依所選錨定週期由 timeframe.change('D'/'W'/'M'/'3M'/'12M') 觸發。VWAP 與其帶線會在每個錨定週期開始時重置累積歸零；倍數 1 代表帶線畫在「以量價加權的價格標準差」1 倍處，隨週期推進而擴張或收窄。

前期標記——每根 K 棒都會快取剛結束週期的上帶、下帶與 VWAP 值（於重置前一根取樣）。當圖表來到最後一根 K 棒時，這些快取值會被一次性繪製為靜態箱型、一條虛線 VWAP 線與三個標籤——之後不再更新，是固定快照而非即時序列。

滾動 VWAP——與錨定 VWAP 不同，此路徑使用 PineCoders ConditionalAverages 函式庫，在固定的回看時間窗（天數換算為毫秒）內加總 price×volume、volume 與 volume×price²，每根 K 棒重新計算：VWAP = Σ(price·volume)/Σvolume，變異數 = Σ(volume·price²)/Σvolume − VWAP²（下限為零），σ = √變異數。Standard 模式下，帶線 = VWAP ± 倍數×σ；Symmetrical 模式下，帶線 = VWAP ± (倍數/100)×VWAP——為一個固定百分比包絡，而非統計性帶線。

聚合成交量——啟用時，腳本會透過 request.security 從最多四個獨立設定的標的抓取成交量並加總，取代僅使用目前圖表自身的成交量，再送入上述滾動 VWAP 公式。此設計是為了成交量分散於多個交易場所的商品（預設四個欄位指向同一加密貨幣交易對在四家交易所的成交量），但欄位可改為任何標的代碼。

初始平衡——逐根 K 棒比較兩個東京時區時段窗口：一個 1 小時的開盤區間（09:00–10:00），在其開始時決定箱型的高低點；以及涵蓋整個時段的 09:00–15:00 區間，箱型的右緣會延伸至此範圍內。一個滾動陣列僅保留最近 N 個日箱型（依所設定天數），超過上限時刪除最舊的箱型。

警報——每個警報於每根 K 棒收盤時最多觸發一次，格式為：VWAP+｜{標的} {時框} {價格}｜{事件名稱}。

[b]🔶 設定說明[/b]

[b]🔹 背景模式[/b]
[list]
[*][b]背景模式[/b]：黑色背景（預設）／白色背景／自訂。黑色與白色背景會將所有 VWAP、帶、前期標記與 IB 框的顏色鎖定為對應該背景的固定配色，此時下方各條線的顏色設定不生效；切到自訂則解除鎖定，完全依你為每條線分別設定的顏色顯示。
[/list]

[b]🔹 主要 VWAP 設定（VWAP1–VWAP5，五組獨立插槽）[/b]
[list]
[*][b]VWAP1 / VWAP2 / VWAP3 / VWAP4 / VWAP5[/b]：啟用該插槽；五組預設皆為關閉。
[*][b]錨定週期[/b]：日／週／月／季／年——設定該插槽 VWAP 的重置時機。
[*][b]VWAP[/b]：該插槽 VWAP 線的顏色。
[*][b]Bands[/b]：1 個標準差上下帶的顏色。
[*][b]Fill[/b]：帶線填色區域的顏色。
[/list]

[b]🔹 前期 VWAP 標記[/b]
[list]
[*][b]前日 / 前週 / 前前週 / 前月 / 前前月 / 前季 / 前前季 / 前年[/b]：各自開關會將該已結束週期的 VWAP 通道（箱型＋線＋標籤）投影至圖表右側；預設皆為關閉。
[*][b]顏色（各標記）[/b]：設定該標記的箱型／線／標籤色調。
[/list]

[b]🔹 滾動 VWAP[/b]
[list]
[*][b]7D / 30D / 90D / 365D[/b]：啟用該滾動窗口插槽；四組預設皆為開啟。
[*][b]天數[/b]：從預設清單（1/3/5/7/14/21/28/30/60/90/182/365 天）自由選擇該插槽的滾動窗口長度，與插槽標籤無關。
[*][b]RVWAP[/b]：該插槽滾動 VWAP 線的顏色。
[*][b]Bands[/b]：該插槽偏差帶的顏色。
[*][b]Fill[/b]：該插槽帶線填色區域的顏色。
[/list]

[b]🔹 滾動 VWAP 標準差帶[/b]
[list]
[*][b]使用聚合成交量[/b]：合併下方勾選交易所的成交量計算滾動 VWAP，取代僅使用目前圖表的成交量。
[*][b]偏差帶模式[/b]：Symmetrical（VWAP 上下對稱的百分比帶）或 Standard（統計標準差帶）。
[*][b]倍數[/b]：調整帶寬（最小 0.5，以 0.5 為單位遞增）。
[*][b]交易所 1 / 2 / 3 / 4[/b]：開關該標的成交量是否納入聚合計算。
[*][b]標的欄位（交易所 1–4）[/b]：設定每個交易所插槽所抓取的成交量標的，預設為同一交易對在四大交易所的成交量，可改為任何標的。
[/list]

[b]🔹 初始平衡區間[/b]
[list]
[*][b]顯示 IB 區間[/b]：開關初始平衡箱型，以東京時段（09:00–15:00）繪製，其高低點由 09:00–10:00 的開盤區間決定。
[*][b]天數[/b]：圖表上保留幾天的 IB 箱型，超過後自動刪除最舊的一個。
[*][b]顏色[/b]：箱型邊框／填色色調。
[/list]

[b]🔹 警報[/b]
[list]
[*][b]VWAP1–VWAP5 觸及[/b]：價格影線碰到該錨定 VWAP 即於當根 K 棒收盤時觸發一次，不分逼近方向（該 VWAP 需先啟用）。
[*][b]7D/30D/90D/365D RVWAP 觸及[/b]：同樣的觸及邏輯，適用於每一組已啟用的滾動 VWAP。
[/list]

[b]🔶 免責聲明[/b]

本指標及其所產生之所有信號、標記與警報，僅供技術分析學習與研究參考，不構成任何形式之投資建議、財務建議、交易推薦或買賣邀約。金融市場交易涉及高度風險，投資人可能損失部分或全部本金。過去表現不代表亦不保證未來結果。使用本指標之任何交易決策均由使用者自行判斷並承擔完全責任，作者與發布平台不負任何法律責任。請充分了解市場規則與自身風險承受能力，必要時諮詢具備合法資質的專業財務顧問。

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator(title = 'VWAP+ | 多重VWAP通道 [Y.Algo]', shorttitle = 'VWAP+ [Y.Algo]', overlay = true, max_bars_back = 4999, max_polylines_count = 100, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

import PineCoders/ConditionalAverages/1 as pc

// ════════════════════════════════════════════════════════════════════════════
// ██ 1. 函數 | Functions ██
// ════════════════════════════════════════════════════════════════════════════

f_tfStr() => timeframe.isseconds ? str.tostring(timeframe.multiplier) + "s" : timeframe.isminutes ? (timeframe.multiplier % 60 == 0 and timeframe.multiplier >= 60 ? str.tostring(int(timeframe.multiplier / 60)) + "H" : str.tostring(timeframe.multiplier) + "m") : timeframe.isdaily ? str.tostring(timeframe.multiplier) + "D" : timeframe.isweekly ? str.tostring(timeframe.multiplier) + "W" : timeframe.ismonthly ? str.tostring(timeframe.multiplier) + "M" : timeframe.period

f_alert(fire, zhEvent, enEvent) =>
    if fire
        alert("VWAP+｜" + syminfo.ticker + " " + f_tfStr() + " " + str.tostring(close, format.mintick) + "｜" + zhEvent + " | " + enEvent, alert.freq_once_per_bar_close)

f_is_new_period(anchor) =>
    switch anchor
        'Day' => timeframe.change('D')
        'Week' => timeframe.change('W')
        'Month' => timeframe.change('M')
        'Quarter' => timeframe.change('3M')
        'Year' => timeframe.change('12M')
        => false

f_calculate_vwap(src, is_active, is_new_period) =>
    if not is_active
        [na, na, na]

    ta.vwap(src, is_new_period, 1)

f_volume(_ticker) =>
    request.security(_ticker, timeframe.period, volume)

// ════════════════════════════════════════════════════════════════════════════
// ██ 2. 輸入設定 | Inputs ██
// ════════════════════════════════════════════════════════════════════════════

gr_bg = "═══ 背景模式 | Background Mode ═══"
bgMode = input.string("黑色背景 | Dark Background", "背景模式 | Background Mode", options = ["黑色背景 | Dark Background", "白色背景 | Light Background", "自訂 | Custom"], group = gr_bg, tooltip = "黑色背景／白色背景：全部 VWAP/帶/標記線鎖定各自對應的固定配色（此時下方各線條的顏色設定不生效）。自訂：完全依你在各線條分別設定的顏色顯示，可見度由你自己把關。\nDark/Light: every VWAP/band/marker line is locked to a fixed palette for that mode (the color pickers below have no effect while Dark/Light is selected). Custom: shows exactly the color you set on each line — visibility is on you.")

gr_anchor = "═══ 主要 VWAP 設定 | Anchored VWAP Settings ═══"
VWAP5_Settings = 'VWAP #5 Settings'
VWAP5_Ctl = input(false, title = 'VWAP5', group = gr_anchor, inline = VWAP5_Settings)
Anchor5 = input.string(defval = 'Year', title = '', group = gr_anchor, inline = VWAP5_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'], tooltip = "錨定週期 | Anchor period")
VWAP5_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = gr_anchor, inline = VWAP5_Settings)
Bands5_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = gr_anchor, inline = VWAP5_Settings)
VWAP5_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_anchor, inline = VWAP5_Settings)

VWAP1_Settings = 'VWAP #1 Settings'
VWAP1_Ctl = input(false, title = 'VWAP1', group = gr_anchor, inline = VWAP1_Settings)
Anchor1 = input.string(defval = 'Quarter', title = '', group = gr_anchor, inline = VWAP1_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'], tooltip = "錨定週期 | Anchor period")
VWAP1_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = gr_anchor, inline = VWAP1_Settings)
Bands1_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = gr_anchor, inline = VWAP1_Settings)
VWAP1_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_anchor, inline = VWAP1_Settings)

VWAP2_Settings = 'VWAP #2 Settings'
VWAP2_Ctl = input(false, title = 'VWAP2', group = gr_anchor, inline = VWAP2_Settings)
Anchor2 = input.string(defval = 'Month', title = '', group = gr_anchor, inline = VWAP2_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'], tooltip = "錨定週期 | Anchor period")
VWAP2_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = gr_anchor, inline = VWAP2_Settings)
Bands2_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = gr_anchor, inline = VWAP2_Settings)
VWAP2_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_anchor, inline = VWAP2_Settings)

VWAP3_Settings = 'VWAP #3 Settings'
VWAP3_Ctl = input(false, title = 'VWAP3', group = gr_anchor, inline = VWAP3_Settings)
Anchor3 = input.string(defval = 'Week', title = '', group = gr_anchor, inline = VWAP3_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'], tooltip = "錨定週期 | Anchor period")
VWAP3_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = gr_anchor, inline = VWAP3_Settings)
Bands3_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = gr_anchor, inline = VWAP3_Settings)
VWAP3_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_anchor, inline = VWAP3_Settings)

VWAP4_Settings = 'VWAP #4 Settings'
VWAP4_Ctl = input(false, title = 'VWAP4', group = gr_anchor, inline = VWAP4_Settings)
Anchor4 = input.string(defval = 'Day', title = '', group = gr_anchor, inline = VWAP4_Settings, options = ['Day', 'Week', 'Month', 'Quarter', 'Year'], tooltip = "錨定週期 | Anchor period")
VWAP4_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'VWAP', group = gr_anchor, inline = VWAP4_Settings)
Bands4_Col = input.color(defval = color.rgb(255, 255, 255, 80), title = 'Bands', group = gr_anchor, inline = VWAP4_Settings)
VWAP4_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_anchor, inline = VWAP4_Settings)

gr_prev = "═══ 前期 VWAP 標記 | Previous VWAP Markers ═══"
Pday_Ctl = input(false, title = '', group = gr_prev, inline = 'day')
Pday_Val = input.string(defval = 'pDay | 前日', title = '', group = gr_prev, inline = 'day', options = ['pDay | 前日'])
Pday_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = gr_prev, inline = 'day')

Pyear_Ctl = input(false, title = '', group = gr_prev, inline = 'day')
Pyear_Val = input.string(defval = 'pYear | 前年', title = '', group = gr_prev, inline = 'day', options = ['pYear | 前年'])
Pyear_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = gr_prev, inline = 'day')

Pweek_Ctl = input(false, title = '', group = gr_prev, inline = 'week')
Pweek_Val = input.string(defval = 'pWeek | 前週', title = '', group = gr_prev, inline = 'week', options = ['pWeek | 前週'])
Pweek_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = gr_prev, inline = 'week')

Ppweek_Ctl = input(false, title = '', group = gr_prev, inline = 'week')
Ppweek_Val = input.string(defval = 'ppWeek | 前前週', title = '', group = gr_prev, inline = 'week', options = ['ppWeek | 前前週'])
Ppweek_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = gr_prev, inline = 'week')

Pmonth_Ctl = input(false, title = '', group = gr_prev, inline = 'month')
Pmonth_Val = input.string(defval = 'pMonth | 前月', title = '', group = gr_prev, inline = 'month', options = ['pMonth | 前月'])
Pmonth_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = gr_prev, inline = 'month')

Ppmonth_Ctl = input(false, title = '', group = gr_prev, inline = 'month')
Ppmonth_Val = input.string(defval = 'ppMonth | 前前月', title = '', group = gr_prev, inline = 'month', options = ['ppMonth | 前前月'])
Ppmonth_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = gr_prev, inline = 'month')

Pquarter_Ctl = input(false, title = '', group = gr_prev, inline = 'quarter')
Pquarter_Val = input.string(defval = 'pQuarter | 前季', title = '', group = gr_prev, inline = 'quarter', options = ['pQuarter | 前季'])
Pquarter_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = '', group = gr_prev, inline = 'quarter')

Ppquarter_Ctl = input(false, title = '', group = gr_prev, inline = 'quarter')
Ppquarter_Val = input.string(defval = 'ppQuarter | 前前季', title = '', group = gr_prev, inline = 'quarter', options = ['ppQuarter | 前前季'])
Ppquarter_Col = input.color(defval = color.rgb(91, 156, 246, 60), title = '', group = gr_prev, inline = 'quarter')

int MS_IN_DAY = 60 * 1000 * 60 * 24

gr_roll = "═══ 滾動 VWAP | Rolling VWAP ═══"
bool enable7 = input.bool(true, '7D', group = gr_roll, inline = '1', tooltip = "選好天數後啟用，可多組同時開啟。\nPick a day count then enable; multiple periods can run at once.")
int pdaysInput7 = input.int(7, '', group = gr_roll, inline = '1', minval = 1, maxval = 3650, tooltip = "自訂天數，不限預設值。\nCustom day count, not limited to presets.") * MS_IN_DAY
color RVWAP1_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = gr_roll, inline = '1')
color RBands1_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = gr_roll, inline = '1')
color RVWAP1_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_roll, inline = '1')

bool enable30 = input.bool(true, '30D', group = gr_roll, inline = '2')
int pdaysInput30 = input.int(30, '', group = gr_roll, inline = '2', minval = 1, maxval = 3650) * MS_IN_DAY
color RVWAP2_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = gr_roll, inline = '2')
color RBands2_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = gr_roll, inline = '2')
color RVWAP2_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_roll, inline = '2')

bool enable90 = input.bool(true, '90D', group = gr_roll, inline = '3')
int pdaysInput90 = input.int(90, '', group = gr_roll, inline = '3', minval = 1, maxval = 3650) * MS_IN_DAY
color RVWAP3_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = gr_roll, inline = '3')
color RBands3_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = gr_roll, inline = '3')
color RVWAP3_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_roll, inline = '3')

bool enable365 = input.bool(true, '365D', group = gr_roll, inline = '4')
int pdaysInput365 = input.int(365, '', group = gr_roll, inline = '4', minval = 1, maxval = 3650) * MS_IN_DAY
color RVWAP4_Col = input.color(defval = color.rgb(255, 255, 255, 60), title = 'RVWAP', group = gr_roll, inline = '4')
color RBands4_Col = input.color(defval = color.rgb(255, 255, 255, 90), title = 'Bands', group = gr_roll, inline = '4')
color RVWAP4_Bgc = input.color(defval = color.rgb(255, 255, 255, 95), title = 'Fill', group = gr_roll, inline = '4')

gr_rollstd = "═══ 滾動 VWAP 標準差帶 | Rolling VWAP StdDev Bands ═══"
bool aggr = input.bool(defval = true, title = '使用聚合成交量 | Use Aggregated Volume', group = gr_rollstd, inline = "1", tooltip = "合併下方勾選交易所的成交量計算滾動VWAP。\nCombine volume across the exchanges checked below when computing the rolling VWAP.")
string devMode = input.string(defval = 'Symmetrical', title = '偏差帶模式 | Deviation Bands', group = gr_rollstd, inline = '2', options = ['Symmetrical', 'Standard'], tooltip = "Symmetrical＝百分比對稱帶；Standard＝標準差帶。\nSymmetrical = %-based symmetric bands; Standard = StdDev-based bands.")
float stdevMult = input.float(0.5, '倍數 | Multiplier', group = gr_rollstd, inline = '2', minval = 0.5, step = 0.5)
i_sym1 = input.bool(true, '交易所1 | Exchange 1', inline='3', group=gr_rollstd)
i_sym2 = input.bool(true, '交易所2 | Exchange 2', inline='4', group=gr_rollstd)
i_sym3 = input.bool(true, '交易所3 | Exchange 3', inline='5', group=gr_rollstd)
i_sym4 = input.bool(true, '交易所4 | Exchange 4', inline='6', group=gr_rollstd)

i_sym1_ticker = input.symbol('BINANCE:BTCUSDT', '', inline='3', group=gr_rollstd)
i_sym2_ticker = input.symbol('COINBASE:BTCUSD', '', inline='4', group=gr_rollstd)
i_sym3_ticker = input.symbol('BYBIT:BTCUSDT', '', inline='5', group=gr_rollstd)
i_sym4_ticker = input.symbol('OKX:BTCUSDT', '', inline='6', group=gr_rollstd)

gr_ib = "═══ 初始平衡區間 | Initial Balance Range ═══"
enable_ib = input(true, '顯示 IB 區間 | Show IB Range', group = gr_ib, inline = 'ib', tooltip = "以東京時段(09:00-15:00，開盤09:00-10:00定義高低)畫出初始平衡箱型。\nDraws Initial Balance boxes from the Tokyo session (09:00-15:00; IB defined 09:00-10:00).")
DaysToShow = input.int(7, '天數 | Days', minval = 1, group = gr_ib, inline = 'ib')
ib_color = input.color(color.rgb(91, 156, 246), '', group = gr_ib, inline = 'ib')

gr_alerts = "═══ 警報設定 | Alert Settings ═══"
alert_v1   = input.bool(true, "VWAP1 觸及 | Touch",   group = gr_alerts, inline = "v1", tooltip = "價格影線碰到 VWAP1 即觸發，不分上/下方向逼近（VWAP1 需先啟用）——單純提醒「該去關注了」。\nFires as soon as price wicks touch VWAP1, regardless of approach direction (VWAP1 must be enabled) — a plain reminder to pay attention.")
alert_v2   = input.bool(true, "VWAP2 觸及 | Touch",   group = gr_alerts, inline = "v2")
alert_v3   = input.bool(true, "VWAP3 觸及 | Touch",   group = gr_alerts, inline = "v3")
alert_v4   = input.bool(true, "VWAP4 觸及 | Touch",   group = gr_alerts, inline = "v4")
alert_v5   = input.bool(true, "VWAP5 觸及 | Touch",   group = gr_alerts, inline = "v5")
alert_r7    = input.bool(true, "7D RVWAP 觸及 | Touch",   group = gr_alerts, inline = "r7", tooltip = "價格影線碰到滾動VWAP即觸發，不分方向（該週期需先啟用）。\nFires as soon as price wicks touch the rolling VWAP, regardless of direction (that period must be enabled).")
alert_r30   = input.bool(true, "30D RVWAP 觸及 | Touch",  group = gr_alerts, inline = "r30")
alert_r90   = input.bool(true, "90D RVWAP 觸及 | Touch",  group = gr_alerts, inline = "r90")
alert_r365   = input.bool(true, "365D RVWAP 觸及 | Touch", group = gr_alerts, inline = "r365")

// ════════════════════════════════════════════════════════════════════════════
// ██ 3. 背景色彩解析 | Resolved Background-Adaptive Colors ██
// ════════════════════════════════════════════════════════════════════════════

// 黑色背景／白色背景＝鎖定的固定色（無視個別線條的顏色設定）；自訂＝完全讀取個別線條顏色
// Dark/Light = locked fixed palettes (ignore each line's color input); Custom = reads each line's own color
f_bgColor(userColor, darkColor, litColor) =>
    switch bgMode
        "自訂 | Custom" => userColor
        "白色背景 | Light Background" => litColor
        => darkColor

DARK_LINE    = color.rgb(255, 255, 255, 60)
DARK_BAND80  = color.rgb(255, 255, 255, 80)
DARK_BAND90  = color.rgb(255, 255, 255, 90)
DARK_FILL    = color.rgb(255, 255, 255, 95)
DARK_MARK    = color.rgb(255, 255, 255, 60)
DARK_ACCENT  = color.rgb(91, 156, 246, 60)
DARK_IB      = color.rgb(91, 156, 246)

LIGHT_LINE   = color.rgb(20, 20, 20, 60)
LIGHT_BAND80 = color.rgb(20, 20, 20, 80)
LIGHT_BAND90 = color.rgb(20, 20, 20, 90)
LIGHT_FILL   = color.rgb(20, 20, 20, 95)
LIGHT_MARK   = color.rgb(20, 20, 20, 60)
LIGHT_ACCENT = color.rgb(13, 71, 161, 60)
LIGHT_IB     = color.rgb(13, 71, 161)

e_VWAP5_Col = f_bgColor(VWAP5_Col, DARK_LINE, LIGHT_LINE)
e_Bands5_Col = f_bgColor(Bands5_Col, DARK_BAND80, LIGHT_BAND80)
e_VWAP5_Bgc = f_bgColor(VWAP5_Bgc, DARK_FILL, LIGHT_FILL)
e_VWAP1_Col = f_bgColor(VWAP1_Col, DARK_LINE, LIGHT_LINE)
e_Bands1_Col = f_bgColor(Bands1_Col, DARK_BAND80, LIGHT_BAND80)
e_VWAP1_Bgc = f_bgColor(VWAP1_Bgc, DARK_FILL, LIGHT_FILL)
e_VWAP2_Col = f_bgColor(VWAP2_Col, DARK_LINE, LIGHT_LINE)
e_Bands2_Col = f_bgColor(Bands2_Col, DARK_BAND80, LIGHT_BAND80)
e_VWAP2_Bgc = f_bgColor(VWAP2_Bgc, DARK_FILL, LIGHT_FILL)
e_VWAP3_Col = f_bgColor(VWAP3_Col, DARK_LINE, LIGHT_LINE)
e_Bands3_Col = f_bgColor(Bands3_Col, DARK_BAND80, LIGHT_BAND80)
e_VWAP3_Bgc = f_bgColor(VWAP3_Bgc, DARK_FILL, LIGHT_FILL)
e_VWAP4_Col = f_bgColor(VWAP4_Col, DARK_LINE, LIGHT_LINE)
e_Bands4_Col = f_bgColor(Bands4_Col, DARK_BAND80, LIGHT_BAND80)
e_VWAP4_Bgc = f_bgColor(VWAP4_Bgc, DARK_FILL, LIGHT_FILL)

e_Pday_Col = f_bgColor(Pday_Col, DARK_MARK, LIGHT_MARK)
e_Pyear_Col = f_bgColor(Pyear_Col, DARK_MARK, LIGHT_MARK)
e_Pweek_Col = f_bgColor(Pweek_Col, DARK_MARK, LIGHT_MARK)
e_Ppweek_Col = f_bgColor(Ppweek_Col, DARK_ACCENT, LIGHT_ACCENT)
e_Pmonth_Col = f_bgColor(Pmonth_Col, DARK_MARK, LIGHT_MARK)
e_Ppmonth_Col = f_bgColor(Ppmonth_Col, DARK_ACCENT, LIGHT_ACCENT)
e_Pquarter_Col = f_bgColor(Pquarter_Col, DARK_MARK, LIGHT_MARK)
e_Ppquarter_Col = f_bgColor(Ppquarter_Col, DARK_ACCENT, LIGHT_ACCENT)

e_RVWAP1_Col = f_bgColor(RVWAP1_Col, DARK_LINE, LIGHT_LINE)
e_RBands1_Col = f_bgColor(RBands1_Col, DARK_BAND90, LIGHT_BAND90)
e_RVWAP1_Bgc = f_bgColor(RVWAP1_Bgc, DARK_FILL, LIGHT_FILL)
e_RVWAP2_Col = f_bgColor(RVWAP2_Col, DARK_LINE, LIGHT_LINE)
e_RBands2_Col = f_bgColor(RBands2_Col, DARK_BAND90, LIGHT_BAND90)
e_RVWAP2_Bgc = f_bgColor(RVWAP2_Bgc, DARK_FILL, LIGHT_FILL)
e_RVWAP3_Col = f_bgColor(RVWAP3_Col, DARK_LINE, LIGHT_LINE)
e_RBands3_Col = f_bgColor(RBands3_Col, DARK_BAND90, LIGHT_BAND90)
e_RVWAP3_Bgc = f_bgColor(RVWAP3_Bgc, DARK_FILL, LIGHT_FILL)
e_RVWAP4_Col = f_bgColor(RVWAP4_Col, DARK_LINE, LIGHT_LINE)
e_RBands4_Col = f_bgColor(RBands4_Col, DARK_BAND90, LIGHT_BAND90)
e_RVWAP4_Bgc = f_bgColor(RVWAP4_Bgc, DARK_FILL, LIGHT_FILL)

e_ib_color = f_bgColor(ib_color, DARK_IB, LIGHT_IB)

float Src = hlc3
float finvol = 0
color label_color_setting = color.new(#ecf008, 100)
int right_bar = bar_index + 21
string format_level = '#.####'
string DEFAULT_LINE_STYLE = line.style_dotted
string DEFAULT_LABEL_STYLE = label.style_label_left

// ════════════════════════════════════════════════════════════════════════════
// ██ 4. 計算 | Calculations ██
// ════════════════════════════════════════════════════════════════════════════

[vwap1, band1_upper, band1_lower] = f_calculate_vwap(Src, VWAP1_Ctl, f_is_new_period(Anchor1))
[vwap2, band2_upper, band2_lower] = f_calculate_vwap(Src, VWAP2_Ctl, f_is_new_period(Anchor2))
[vwap3, band3_upper, band3_lower] = f_calculate_vwap(Src, VWAP3_Ctl, f_is_new_period(Anchor3))
[vwap4, band4_upper, band4_lower] = f_calculate_vwap(Src, VWAP4_Ctl, f_is_new_period(Anchor4))
[vwap5, band5_upper, band5_lower] = f_calculate_vwap(Src, VWAP5_Ctl, f_is_new_period(Anchor5))

vwap_plot1 = plot(VWAP1_Ctl ? vwap1 : na, color=e_VWAP1_Col)
lowerBand_1 = plot(VWAP1_Ctl ? band1_lower : na, color=e_Bands1_Col)
upperBand_1 = plot(VWAP1_Ctl ? band1_upper : na, color=e_Bands1_Col)
fill(upperBand_1, lowerBand_1, color=e_VWAP1_Bgc)

vwap_plot2 = plot(VWAP2_Ctl ? vwap2 : na, color=e_VWAP2_Col)
lowerBand_2 = plot(VWAP2_Ctl ? band2_lower : na, color=e_Bands2_Col)
upperBand_2 = plot(VWAP2_Ctl ? band2_upper : na, color=e_Bands2_Col)
fill(upperBand_2, lowerBand_2, color=e_VWAP2_Bgc)

vwap_plot3 = plot(VWAP3_Ctl ? vwap3 : na, color=e_VWAP3_Col)
lowerBand_3 = plot(VWAP3_Ctl ? band3_lower : na, color=e_Bands3_Col)
upperBand_3 = plot(VWAP3_Ctl ? band3_upper : na, color=e_Bands3_Col)
fill(upperBand_3, lowerBand_3, color=e_VWAP3_Bgc)

vwap_plot4 = plot(VWAP4_Ctl ? vwap4 : na, color=e_VWAP4_Col)
lowerBand_4 = plot(VWAP4_Ctl ? band4_lower : na, color=e_Bands4_Col)
upperBand_4 = plot(VWAP4_Ctl ? band4_upper : na, color=e_Bands4_Col)
fill(upperBand_4, lowerBand_4, color=e_VWAP4_Bgc)

vwap_plot5 = plot(VWAP5_Ctl ? vwap5 : na, color=e_VWAP5_Col)
lowerBand_5 = plot(VWAP5_Ctl ? band5_lower : na, color=e_Bands5_Col)
upperBand_5 = plot(VWAP5_Ctl ? band5_upper : na, color=e_Bands5_Col)
fill(upperBand_5, lowerBand_5, color=e_VWAP5_Bgc)

bool anyRollingEnabled = enable7 or enable30 or enable90 or enable365

if anyRollingEnabled
    if aggr == true
        v1 = (i_sym1 ? f_volume(i_sym1_ticker) : 0)
        v2 = (i_sym2 ? f_volume(i_sym2_ticker) : 0)
        v3 = (i_sym3 ? f_volume(i_sym3_ticker) : 0)
        v4 = (i_sym4 ? f_volume(i_sym4_ticker) : 0)

        finvol := v1+v2+v3+v4
    else
        finvol := volume

calculateRollingVWAP(int period) =>
    float sumSrcVol = pc.totalForTimeWhen(Src * finvol, period, true)
    float sumVol = pc.totalForTimeWhen(finvol, period, true)
    float sumSrcSrcVol = pc.totalForTimeWhen(finvol * math.pow(Src, 2), period, true)
    float rollingVWAP = sumSrcVol / sumVol
    float variance = sumSrcSrcVol / sumVol - math.pow(rollingVWAP, 2)
    variance := math.max(0, variance)
    float stDev = math.sqrt(variance)
    float upperBand = rollingVWAP + (devMode == 'Standard' ? stdevMult : stdevMult / 100) * (devMode == 'Standard' ? stDev : rollingVWAP)
    float lowerBand = rollingVWAP - (devMode == 'Standard' ? stdevMult : stdevMult / 100) * (devMode == 'Standard' ? stDev : rollingVWAP)
    [rollingVWAP, upperBand, lowerBand]

var float rollingVWAP7 = na
var float upperBand7 = na
var float lowerBand7 = na
var float rollingVWAP30 = na
var float upperBand30 = na
var float lowerBand30 = na
var float rollingVWAP90 = na
var float upperBand90 = na
var float lowerBand90 = na
var float rollingVWAP365 = na
var float upperBand365 = na
var float lowerBand365 = na

if enable7
    [_v7, _u7, _l7] = calculateRollingVWAP(pdaysInput7)
    rollingVWAP7 := _v7
    upperBand7 := _u7
    lowerBand7 := _l7
if enable30
    [_v30, _u30, _l30] = calculateRollingVWAP(pdaysInput30)
    rollingVWAP30 := _v30
    upperBand30 := _u30
    lowerBand30 := _l30
if enable90
    [_v90, _u90, _l90] = calculateRollingVWAP(pdaysInput90)
    rollingVWAP90 := _v90
    upperBand90 := _u90
    lowerBand90 := _l90
if enable365
    [_v365, _u365, _l365] = calculateRollingVWAP(pdaysInput365)
    rollingVWAP365 := _v365
    upperBand365 := _u365
    lowerBand365 := _l365

plot(enable7 ? rollingVWAP7 : na, '7-Day VWAP', e_RVWAP1_Col, linewidth = 1)
plot(enable30 ? rollingVWAP30 : na, '30-Day VWAP', e_RVWAP2_Col, linewidth = 1)
plot(enable90 ? rollingVWAP90 : na, '90-Day VWAP', e_RVWAP3_Col, linewidth = 1)
plot(enable365 ? rollingVWAP365 : na, '365-Day VWAP', e_RVWAP4_Col, linewidth = 1)

p1_7 = plot(enable7 ? upperBand7 : na, color = e_RBands1_Col)
p2_7 = plot(enable7 ? lowerBand7 : na, color = e_RBands1_Col)
fill(p1_7, p2_7, e_RVWAP1_Bgc)

p1_30 = plot(enable30 ? upperBand30 : na, color = e_RBands2_Col)
p2_30 = plot(enable30 ? lowerBand30 : na, color = e_RBands2_Col)
fill(p1_30, p2_30, e_RVWAP2_Bgc)

p1_90 = plot(enable90 ? upperBand90 : na, color = e_RBands3_Col)
p2_90 = plot(enable90 ? lowerBand90 : na, color = e_RBands3_Col)
fill(p1_90, p2_90, e_RVWAP3_Bgc)

p1_365 = plot(enable365 ? upperBand365 : na, color = e_RBands4_Col)
p2_365 = plot(enable365 ? lowerBand365 : na, color = e_RBands4_Col)
fill(p1_365, p2_365, e_RVWAP4_Bgc)

var float lastdailyLower = na
var float lastdailyUpper = na
var int thisDayStart = na
var float lastdailyPOC = na

var int thisWeekStart = na
var float lastWeeklyLower = na
var float lastWeeklyUpper = na
var int lastWeeklyStart = na
var float lastWeeklyPOC = na

var float lastlastWeeklyLower = na
var float lastlastWeeklyUpper = na
var float lastlastWeeklyPOC = na

var int thisMonthStart = na
var float lastMonthlyLower = na
var float lastMonthlyUpper = na
var int lastMonthlyStart = na
var float lastMonthlyPOC = na

var float lastlastMonthlyLower = na
var float lastlastMonthlyUpper = na
var float lastlastMonthlyPOC = na

var int thisQuarterStart = na
var float lastQuarterlyLower = na
var float lastQuarterlyUpper = na
var int lastQuarterlyStart = na
var float lastQuarterlyPOC = na

var float lastlastQuarterlyLower = na
var float lastlastQuarterlyUpper = na
var float lastlastQuarterlyPOC = na

var int thisYearStart = na
var float lastYearlyLower = na
var float lastYearlyUpper = na
var int lastYearlyStart = na
var float lastYearlyPOC = na

[yearlyVWAP, yearlyUpper, yearlyLower] = ta.vwap(Src, timeframe.change('12M'), 1)
[quarterlyVWAP, quarterlyUpper, quarterlyLower] = ta.vwap(Src, timeframe.change('3M'), 1)
[monthlyVWAP, monthlyUpper, monthlyLower] = ta.vwap(Src, timeframe.change('M'), 1)
[weeklyVWAP, weeklyUpper, weeklyLower] = ta.vwap(Src, timeframe.change('W'), 1)
[dailyVWAP, dailyUpper, dailyLower] = ta.vwap(Src, timeframe.change('D'), 1)

if timeframe.change('3M')
    lastlastQuarterlyLower := lastQuarterlyLower
    lastlastQuarterlyUpper := lastQuarterlyUpper
    lastlastQuarterlyPOC := lastQuarterlyPOC
    lastQuarterlyLower := quarterlyLower[1]
    lastQuarterlyUpper := quarterlyUpper[1]
    lastQuarterlyStart := thisQuarterStart
    lastQuarterlyPOC := quarterlyVWAP[1]
    thisQuarterStart := bar_index
    lastQuarterlyPOC

if timeframe.change('M')
    lastlastMonthlyLower := lastMonthlyLower
    lastlastMonthlyUpper := lastMonthlyUpper
    lastlastMonthlyPOC := lastMonthlyPOC
    lastMonthlyLower := monthlyLower[1]
    lastMonthlyUpper := monthlyUpper[1]
    lastMonthlyStart := thisMonthStart
    lastMonthlyPOC := monthlyVWAP[1]
    thisMonthStart := bar_index
    lastMonthlyPOC

if timeframe.change('W')
    lastlastWeeklyLower := lastWeeklyLower
    lastlastWeeklyUpper := lastWeeklyUpper
    lastlastWeeklyPOC := lastWeeklyPOC
    lastWeeklyLower := weeklyLower[1]
    lastWeeklyUpper := weeklyUpper[1]
    lastWeeklyStart := thisWeekStart
    lastWeeklyPOC := weeklyVWAP[1]
    thisWeekStart := bar_index
    lastWeeklyPOC

if timeframe.change('D')
    lastdailyLower := dailyLower[1]
    lastdailyUpper := dailyUpper[1]
    thisDayStart := bar_index
    lastdailyPOC := dailyVWAP[1]
    lastdailyPOC

if timeframe.change("12M")
    lastYearlyLower := yearlyLower[1]
    lastYearlyUpper := yearlyUpper[1]
    lastYearlyPOC :=  yearlyVWAP[1]
    thisYearStart := bar_index

if barstate.islast
    if Pday_Ctl
        var pDayBox = box.new(left = thisDayStart, right = right_bar, top = lastdailyUpper, bottom = lastdailyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Pday_Col, 95))
        var pDayLine = line.new(x1 = thisDayStart, y1 = lastdailyPOC, x2 = right_bar, y2 = lastdailyPOC, color = color.new(e_Pday_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pDayLowerLabel = label.new(right_bar, y = lastdailyLower, text = 'pd VWAP -1', tooltip = str.tostring(lastdailyLower, format_level), color = label_color_setting, textcolor = color.new(e_Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pDayUpperLabel = label.new(x = right_bar, y = lastdailyUpper, text = 'pd VWAP +1', tooltip = str.tostring(lastdailyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pDayPOCLabel = label.new(x = right_bar, y = lastdailyPOC, text = 'pd VWAP', tooltip = str.tostring(lastdailyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Pday_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pyear_Ctl
        var pYearBox = box.new(left = thisYearStart, right = right_bar, top = lastYearlyUpper, bottom = lastYearlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Pyear_Col, 95))
        var pYearLine = line.new(x1 = thisYearStart, y1 = lastYearlyPOC, x2 = right_bar, y2 = lastYearlyPOC, color = color.new(e_Pyear_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pYearLowerLabel = label.new(right_bar, y = lastYearlyLower, text = 'py VWAP -1', tooltip = str.tostring(lastYearlyLower, format_level), color = label_color_setting, textcolor = color.new(e_Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pYearUpperLabel = label.new(x = right_bar, y = lastYearlyUpper, text = 'py VWAP +1', tooltip = str.tostring(lastYearlyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pYearPOCLabel = label.new(x = right_bar, y = lastYearlyPOC, text = 'py VWAP', tooltip = str.tostring(lastYearlyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Pyear_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pweek_Ctl
        var pWeekBox = box.new(left = thisWeekStart, right = right_bar, top = lastWeeklyUpper, bottom = lastWeeklyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Pweek_Col, 95))
        var pWeekLine = line.new(x1 = thisWeekStart, y1 = lastWeeklyPOC, x2 = right_bar, y2 = lastWeeklyPOC, color = color.new(e_Pweek_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pWeekLowerLabel = label.new(right_bar, y = lastWeeklyLower, text = 'pw VWAP -1', tooltip = str.tostring(lastWeeklyLower, format_level), color = label_color_setting, textcolor = color.new(e_Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pWeekUpperLabel = label.new(x = right_bar, y = lastWeeklyUpper, text = 'pw VWAP +1', tooltip = str.tostring(lastWeeklyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pWeekPOCLabel = label.new(x = right_bar, y = lastWeeklyPOC, text = 'pw VWAP', tooltip = str.tostring(lastWeeklyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Pweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppweek_Ctl
        var ppWeekBox = box.new(left = lastWeeklyStart, right = right_bar, top = lastlastWeeklyUpper, bottom = lastlastWeeklyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Ppweek_Col, 95))
        var ppWeekLine = line.new(x1 = lastWeeklyStart, y1 = lastlastWeeklyPOC, x2 = right_bar, y2 = lastlastWeeklyPOC, color = color.new(e_Ppweek_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppWeekLowerLabel = label.new(right_bar, y = lastlastWeeklyLower, text = 'ppw VWAP -1', tooltip = str.tostring(lastlastWeeklyLower, format_level), color = label_color_setting, textcolor = color.new(e_Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppWeekUpperLabel = label.new(x = right_bar, y = lastlastWeeklyUpper, text = 'ppw VWAP +1', tooltip = str.tostring(lastlastWeeklyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppWeekPOCLabel = label.new(x = right_bar, y = lastlastWeeklyPOC, text = 'ppw VWAP', tooltip = str.tostring(lastlastWeeklyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Ppweek_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pmonth_Ctl
        var pMonthBox = box.new(left = thisMonthStart, right = right_bar, top = lastMonthlyUpper, bottom = lastMonthlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Pmonth_Col, 95))
        var pMonthLine = line.new(x1 = thisMonthStart, y1 = lastMonthlyPOC, x2 = right_bar, y2 = lastMonthlyPOC, color = color.new(e_Pmonth_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pMonthLowerLabel = label.new(right_bar, y = lastMonthlyLower, text = 'pm VWAP -1', tooltip = str.tostring(lastMonthlyLower, format_level), color = label_color_setting, textcolor = color.new(e_Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pMonthUpperLabel = label.new(x = right_bar, y = lastMonthlyUpper, text = 'pm VWAP +1', tooltip = str.tostring(lastMonthlyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pMonthPOCLabel = label.new(x = right_bar, y = lastMonthlyPOC, text = 'pm VWAP', tooltip = str.tostring(lastMonthlyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Pmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppmonth_Ctl
        var ppMonthBox = box.new(left = lastMonthlyStart, right = right_bar, top = lastlastMonthlyUpper, bottom = lastlastMonthlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Ppmonth_Col, 95))
        var ppMonthLine = line.new(x1 = lastMonthlyStart, y1 = lastlastMonthlyPOC, x2 = right_bar, y2 = lastlastMonthlyPOC, color = color.new(e_Ppmonth_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppMonthLowerLabel = label.new(right_bar, y = lastlastMonthlyLower, text = 'ppm VWAP -1', tooltip = str.tostring(lastlastMonthlyLower, format_level), color = label_color_setting, textcolor = color.new(e_Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppMonthUpperLabel = label.new(x = right_bar, y = lastlastMonthlyUpper, text = 'ppm VWAP +1', tooltip = str.tostring(lastlastMonthlyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppMonthPOCLabel = label.new(x = right_bar, y = lastlastMonthlyPOC, text = 'ppm VWAP', tooltip = str.tostring(lastlastMonthlyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Ppmonth_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Pquarter_Ctl
        var pQuarterBox = box.new(left = thisQuarterStart, right = right_bar, top = lastQuarterlyUpper, bottom = lastQuarterlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Pquarter_Col, 95))
        var pQuarterLine = line.new(x1 = thisQuarterStart, y1 = lastQuarterlyPOC, x2 = right_bar, y2 = lastQuarterlyPOC, color = color.new(e_Pquarter_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var pQuarterLowerLabel = label.new(right_bar, y = lastQuarterlyLower, text = 'pq VWAP -1', tooltip = str.tostring(lastQuarterlyLower, format_level), color = label_color_setting, textcolor = color.new(e_Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pQuarterUpperLabel = label.new(x = right_bar, y = lastQuarterlyUpper, text = 'pq VWAP +1', tooltip = str.tostring(lastQuarterlyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var pQuarterPOCLabel = label.new(x = right_bar, y = lastQuarterlyPOC, text = 'pq VWAP', tooltip = str.tostring(lastQuarterlyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Pquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if Ppquarter_Ctl
        var ppqBox = box.new(left = lastYearlyStart, right = right_bar, top = lastlastQuarterlyUpper, bottom = lastlastQuarterlyLower, border_color = color.rgb(255, 255, 255, 100), bgcolor = color.new(e_Ppquarter_Col, 95))
        var ppqLine = line.new(x1 = lastYearlyStart, y1 = lastlastQuarterlyPOC, x2 = right_bar, y2 = lastlastQuarterlyPOC, color = color.new(e_Ppquarter_Col, 60), width = 1, style = DEFAULT_LINE_STYLE)
        var ppqLowerLabel = label.new(right_bar, y = lastlastQuarterlyLower, text = 'ppq VWAP -1', tooltip = str.tostring(lastlastQuarterlyLower, format_level), color = label_color_setting, textcolor = color.new(e_Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppqUpperLabel = label.new(x = right_bar, y = lastlastQuarterlyUpper, text = 'ppq VWAP +1', tooltip = str.tostring(lastlastQuarterlyUpper, format_level), color = label_color_setting, textcolor = color.new(e_Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)
        var ppqPOCLabel = label.new(x = right_bar, y = lastlastQuarterlyPOC, text = 'ppq VWAP', tooltip = str.tostring(lastlastQuarterlyPOC, format_level), color = label_color_setting, textcolor = color.new(e_Ppquarter_Col, 40), style = DEFAULT_LABEL_STYLE, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if enable7
        var rollingVWAP7Label = label.new(x = right_bar - 20, y = rollingVWAP7, text = str.tostring(pdaysInput7 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP7, '#.####'), color = color.new(#ecf008, 100), textcolor = color.new(e_RBands1_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if enable30
        var rollingVWAP30Label = label.new(x = right_bar - 20, y = rollingVWAP30, text = str.tostring(pdaysInput30 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP30, '#.####'), color = color.new(#0f90f0, 100), textcolor = color.new(e_RBands2_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if enable90
        var rollingVWAP90Label = label.new(x = right_bar - 20, y = rollingVWAP90, text = str.tostring(pdaysInput90 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP90, '#.####'), color = color.new(#ec0080, 100), textcolor = color.new(e_RBands3_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)

    if enable365
        var rollingVWAP365Label = label.new(x = right_bar - 20, y = rollingVWAP365, text = str.tostring(pdaysInput365 / MS_IN_DAY) + 'D RVWAP', tooltip = str.tostring(rollingVWAP365, '#.####'), color = color.new(#0090f0, 100), textcolor = color.new(e_RBands4_Col, 40), style = label.style_label_left, xloc = xloc.bar_index, text_font_family = font.family_monospace)

var array<box> boxesArray = array.new<box>()
var string Tokyo = '0900-1500'
var string Tokyo_Range = '0900-1000'
TokyoTZ = 'Asia/Tokyo'
On_sesTokyo = math.sign(nz(time(timeframe.period, Tokyo, TokyoTZ)))
On_rangeTokyo = math.sign(nz(time(timeframe.period, Tokyo_Range, TokyoTZ)))

LowHighSessionDetector(On_Range, On_Session, Color_Session) =>
    var int Bar = 0
    var float High = 0.0
    var float Low = 0.0
    var box BoX = na

    if On_Range[1] == 0 and On_Range == 1
        Bar := bar_index
        High := high
        Low := low
        Low
    else if On_Range[1] == 1 and On_Range == 1
        High := math.max(high, High)
        Low := math.min(low, Low)
        Low
    else if On_Session == 0
        High := 0.0
        Low := 0.0
        Bar := 0
        Bar

    if On_Session > On_Session[1] and str.tonumber(timeframe.period) <= 60
        BoX := box.new(bar_index, High, bar_index, Low, bgcolor = color.new(Color_Session, 85), border_color = color.new(Color_Session, 100))
        array.push(boxesArray, BoX)

        if array.size(boxesArray) > DaysToShow
            box.delete(array.shift(boxesArray))
    if On_Range[1] == 1 and On_Range == 1
        box.set_top(BoX, High)
        box.set_bottom(BoX, Low)
    if On_Session[1] == 1 and On_Session == 1
        box.set_right(BoX, bar_index)
    if not timeframe.change('D')
        box.set_right(BoX, bar_index)

if enable_ib
    LowHighSessionDetector(On_rangeTokyo, On_sesTokyo, e_ib_color)

// ════════════════════════════════════════════════════════════════════════════
// ██ 5. 警報 | Alerts ██
// ════════════════════════════════════════════════════════════════════════════

touch_v1 = VWAP1_Ctl and high >= vwap1 and low <= vwap1 and not (high[1] >= vwap1[1] and low[1] <= vwap1[1])
touch_v2 = VWAP2_Ctl and high >= vwap2 and low <= vwap2 and not (high[1] >= vwap2[1] and low[1] <= vwap2[1])
touch_v3 = VWAP3_Ctl and high >= vwap3 and low <= vwap3 and not (high[1] >= vwap3[1] and low[1] <= vwap3[1])
touch_v4 = VWAP4_Ctl and high >= vwap4 and low <= vwap4 and not (high[1] >= vwap4[1] and low[1] <= vwap4[1])
touch_v5 = VWAP5_Ctl and high >= vwap5 and low <= vwap5 and not (high[1] >= vwap5[1] and low[1] <= vwap5[1])

touch_r7 = enable7 and high >= rollingVWAP7 and low <= rollingVWAP7 and not (high[1] >= rollingVWAP7[1] and low[1] <= rollingVWAP7[1])
touch_r30 = enable30 and high >= rollingVWAP30 and low <= rollingVWAP30 and not (high[1] >= rollingVWAP30[1] and low[1] <= rollingVWAP30[1])
touch_r90 = enable90 and high >= rollingVWAP90 and low <= rollingVWAP90 and not (high[1] >= rollingVWAP90[1] and low[1] <= rollingVWAP90[1])
touch_r365 = enable365 and high >= rollingVWAP365 and low <= rollingVWAP365 and not (high[1] >= rollingVWAP365[1] and low[1] <= rollingVWAP365[1])

f_alert(alert_v1 and touch_v1, "VWAP1 觸及", "VWAP1 Touch")
f_alert(alert_v2 and touch_v2, "VWAP2 觸及", "VWAP2 Touch")
f_alert(alert_v3 and touch_v3, "VWAP3 觸及", "VWAP3 Touch")
f_alert(alert_v4 and touch_v4, "VWAP4 觸及", "VWAP4 Touch")
f_alert(alert_v5 and touch_v5, "VWAP5 觸及", "VWAP5 Touch")

f_alert(alert_r7 and touch_r7, "7天滾動VWAP 觸及", "7D RVWAP Touch")
f_alert(alert_r30 and touch_r30, "30天滾動VWAP 觸及", "30D RVWAP Touch")
f_alert(alert_r90 and touch_r90, "90天滾動VWAP 觸及", "90D RVWAP Touch")
f_alert(alert_r365 and touch_r365, "365天滾動VWAP 觸及", "365D RVWAP Touch")
````
