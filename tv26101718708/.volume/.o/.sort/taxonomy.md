# 分類體系 v3（依 sample_0、sample_1、sample_2 歸納；供全量歸類共用）

歸群單位為第二層葉節點（代號唯一）。濾網（F.）與出場（X.）標籤只描述小異，不作為分群依據。

## 總覽

| 代號 | 名稱 | 一句構成方式 |
|---|---|---|
| MA.CROSS | 兩線交叉（順勢） | 價格單位的快線穿越平均類慢線即同向進場 |
| MA.STATE | 價格／均線位置與排列狀態（順勢） | 價格在均線之上或均線依序排列的狀態成立即同向進場 |
| MA.FADE | 均線穿越逆勢（逆勢） | 價格逆大勢向下穿越短均線即逆勢做多 |
| TS.FLIP | 追蹤停損線方向翻轉（順勢） | Supertrend、PSAR 等棘輪追蹤線方向翻轉即同向進場 |
| TS.STATE | 追蹤線方向狀態（順勢） | Supertrend 等棘輪追蹤線方向為多的狀態成立即做多 |
| TS.FADE | 追蹤線翻轉反向進場（逆勢） | 追蹤線轉空翻轉當根反向做多 |
| OSC.ZERO | 振盪器穿越零軸／中線（順勢） | 振盪器由負轉正（穿越固定中線）即做多 |
| OSC.SIG | 振盪器穿越其訊號線 | 振盪器穿越自身平滑訊號線即同向進場 |
| OSC.TURN | 振盪器斜率轉折 | 振盪器於負區形成局部低點後轉上即做多 |
| OSC.LEVEL | 振盪器／流量值門檻狀態（順勢） | 振盪器或帶符號流量值處於正門檻之上的狀態即做多 |
| OSC.SLOPE | 振盪器斜率方向狀態 | 振盪器現值高於前值的狀態即做多 |
| BRK.CHAN | 滾動通道突破（順勢） | 收盤價突破逐根滾動的通道上界即做多 |
| BRK.ORB | 固定時段區間突破（順勢） | 收盤價突破特定時段固定高低點即同向進場 |
| BRK.SQZ | 波動壓縮釋放 | 壓縮狀態解除當根依動能符號定方向進場 |
| BRK.KEYBAR | 事件棒衍生價位突破（順勢） | 收盤價越過由特徵 K 棒（放量反向棒、動能突破棒）衍生並延續的價位即同向進場 |
| BRK.SQZON | 壓縮開始雙通道邊界交叉 | 肯特納上軌上穿布林上軌（壓縮開始）即做多 |
| REV.EXTREME | 超買超賣區狀態（逆勢） | 振盪器或價格處於極端區（通道外）當下即逆勢進場 |
| REV.REENTRY | 越界後收回（逆勢） | 價格收回通道內或振盪器自極端區穿回門檻即逆勢進場 |
| REV.OVERSHOOT | 離散價位越界幅度逆勢 | 價格越過離散基準價位達偏移幅度當下即逆勢進場 |
| DIV.REG | 常規背離（逆勢） | 價格極值與振盪器極值方向不一致即逆勢進場 |
| DIV.HID | 隱藏背離（順勢） | 價格低點較高而振盪器低點較低即順勢做多 |
| SW.PIVOT | 確認樞紐反轉（逆勢） | 樞紐低點被確認即做多 |
| SW.BOS | 擺動結構突破（順勢） | 收盤價突破最近確認擺動高點即做多 |
| SW.TLBRK | 擺動點連線趨勢線突破（順勢） | 收盤價突破兩個確認擺動點連線延伸的斜向趨勢線即同向進場 |
| LQ.SWEEP | 關鍵價位掃蕩後收回（逆勢） | 價格刺穿離散關鍵低位後收回其上即做多 |
| SR.TOUCH | 固定價位區觸及反轉（逆勢） | 無趨勢前提下價格進入支撐區而未越界即做多 |
| PB.TOUCH | 順勢回檔觸及參考線 | 趨勢前提成立時價格回檔觸及均線、通道內軌或回撤位即同向進場 |
| PB.BAR | 順勢中逆向 K 棒進場 | 參考線斜率向上時出現收陰 K 棒即做多 |
| PAT.BAR | K 棒形態 | 少數 K 棒的相對高低、實體、影線構成指定形態即進場 |
| PAT.DIR | 週期 K 棒方向狀態（順勢） | 當根或較高週期 K 棒收盤高於開盤即做多 |
| CNT.PEAK | 狀態變化計數達峰值 | 對 K 棒顏色或量能狀態的變化計數，達峰值即進場 |
| CNT.EXHAUST | 連續同向計數耗竭（逆勢） | 收盤相對前值（或 N 根前）連續同向根數達門檻即逆勢進場 |
| CNT.STREAK | 連續同向計數延續（順勢） | 連續上漲根數（或 tick 數）達門檻即順勢做多 |
| CMP.SCORE | 順勢加權計分門檻 | 多項順勢條件加總分數達門檻或勝過對側即同向進場 |
| CMP.EXHAUST | 逆勢超伸計分門檻 | 多項反向超伸與反轉確認項目加總達門檻即逆勢進場 |
| PM.DCA | 逆向間距加碼 | 持倉後價格逆向達間距即加碼 |
| PM.PYRAMID | 順勢間距加碼 | 持倉後價格順向達間距即同向加碼 |
| PM.GRID | 價格網格 | 價格穿越等距離散網格價位（或階梯移動）即進場 |
| PM.TIER | 分級目標權重調倉 | 依順勢位置量化目標權重，升階加倉、降階減倉 |
| PM.SLREV | 停損後反手 | 持倉停損觸發後反向進場 |
| VOL.CLIMAX | 爆量逆趨勢（逆勢） | 下跌趨勢中成交量達極端即逆勢做多 |
| VOL.SURGE | 無號放量異動狀態 | 成交量高於均量倍數（可附價格變動幅度）的狀態即做多 |
| VOL.LEVEL | 成交量相對均量定向 | 成交量低於均量做多、高於均量做空 |
| VOL.ABSORB | 流量耗竭吸收後突破起始棒（逆勢） | 帶符號流量持續極端而價格守住起始棒，再突破起始棒即逆勢進場 |
| ML.KNN | 近鄰分類標籤翻轉 | 最近鄰距離加權分類結果轉為多頭即做多 |
| NUL.ALWAYS | 恆真進場 | 進場條件恆真，無判斷結構 |
| NUL.RANDOM | 偽隨機觸發 | 偽隨機序列值低於當根最低價即做多 |
| NUL.NOENTRY | 僅出場無進場 | 檔案只有出場規則，無進場條件 |
| EXT.FEED | 外部來源通用轉接 | 以未定義計算的外部輸入來源比較或穿越作訊號 |

---

## 歸類決策順序

1. 拆段
1.1 一份檔案含多套可切換模式、多條獨立「做多：」規則，或同一進場條件內以「或」並列、各自具有不同觸發結構的路徑，拆成多段分別歸類（樣本欄以「檔名#段落說明」標示）。
1.2 嵌套「或」若各分支只是濾網的替代寫法（如「收盤高於突破屏障或曾處超賣區」），不拆，記為對應 F. 標籤。
1.3 多段以「前述共同過濾條件成立且…」共用前提時，共用前提記為各段濾網，各段依其專屬條件歸類；若另有一段僅由共用前提本身構成，該段依共用前提歸類。
1.4 部位管理為核心時（DCA、網格），初始進場與加碼／網格分列。

2. 整份特判
2.1 進場條件只引用未定義計算的外部輸入來源（如「主要來源」「次要來源」「止盈來源」），無法判定數學結構者，整份歸 EXT.FEED，不拆段。

3. 每段先找「事件」，事件優先於狀態
3.1 事件指當根發生的變化：穿越、突破、收回、樞紐確認、形態成立、方向翻轉、觸及價位區、計數到達峰值。
3.2 狀態指持續成立的條件：位於某線之上／下、處於極端區、排列、分數高於門檻、ADX 高於門檻、K 棒方向。
3.3 段內有事件時以事件定核心，其餘狀態一律降為 F. 標籤；段內無事件時依第 5 條在狀態間選核心。

4. 多個事件同時出現（同根 AND 或先後序列）時，依以下優先序取最前者為核心，其餘事件降為 F.confirm_bar、F.osc_cross、F.retest 等確認濾網
4.1 LQ.SWEEP（掃蕩後再以 BOS、吞噬或均線交叉確認，仍歸掃蕩）
4.2 DIV.REG
4.3 SW.BOS、SW.PIVOT
4.4 PB.TOUCH、SR.TOUCH
4.5 PAT.BAR
4.6 BRK.ORB、BRK.SQZ、BRK.CHAN、REV.REENTRY
4.7 TS.FLIP
4.8 MA.CROSS、OSC.SIG
4.9 OSC.ZERO、OSC.TURN
4.10 CNT.PEAK
4.11 原則依據：先後序列中以界定方向與順逆勢性質的結構事件為核心，而非最後發生的確認事件；同根多事件時以參考物越具體（離散價位、擺動點、形態）者為核心，泛用交叉與零軸穿越居後。

5. 無事件時，狀態間依以下優先序取核心
5.1 CMP.SCORE、CMP.EXHAUST（分數比較本身為唯一觸發；分數項目以順勢條件為主歸 CMP.SCORE，以反向超伸為主歸 CMP.EXHAUST）
5.2 REV.EXTREME
5.3 OSC.LEVEL
5.4 PAT.DIR
5.5 MA.STATE

6. 順逆勢判定
6.1 以核心觸發的方向定順逆勢，不以濾網定；例如支撐觸及做多，若趨勢方向是參考線本身的構成要件或明列為前提，歸 PB.TOUCH，否則歸 SR.TOUCH。

7. 不分葉的情況
7.1 參數數值、同類指標替換（EMA↔SMA、RSI↔Stoch、成交量 Delta↔資金流作同角色）、附加濾網、出場差異，皆不分葉，只記標籤。

---

## MA 均線／序列關係（順勢）

### MA.CROSS 兩線交叉
- 構成方式：計算快線與慢線（價格本身、各類移動平均、VWAP、平滑後價格如線性回歸值、均線加斜率修正值皆可擔任）→ 做多：快線由下向上穿越慢線的事件 → 做空：對稱，由上向下穿越；可只做多。
- 判別：觸發是「穿越事件」且兩線均在價格單位、慢線為平均類；兩線皆為振盪器值（如 MACD 與訊號線）歸 OSC.SIG；只要求位置或排列狀態而無穿越事件歸 MA.STATE；慢線為單向推進的追蹤停損線（Supertrend、PSAR）歸 TS.FLIP；慢線為通道邊界歸 BRK.CHAN。
- 樣本：quantnomad_evwma_cross_strategy_yrdwiw44、aggregate_btc_volume_ema_strat_zat6a1qs、confluence_engine_strategy_joat_4w7xgwip、code_a_terminal_core_x5m5zevx#EMA 交叉路徑、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#趨勢模式上穿錨定 VWAP、3strategy_auto_switch_range_trend_breakout_mol1swle#趨勢模式、quantumforextradersniperfusionstrategyv2_oq1ju4ha#EMA 交叉路徑、optimized_zhaocaijinbao_strategy_lqsxah8y、masu_institutional_fibonacci_mtf_btt_qckigf3z#ADX 趨勢下 EMA 交叉路徑

### MA.STATE 價格／均線位置與排列狀態
- 構成方式：計算一條或多條均線（可為較高週期）→ 做多：價格位於均線之上，或快>中>慢且價格位於快線之上的「狀態」成立即進場（空倉時）→ 做空：對稱。
- 判別：無穿越事件，只看當下位置或排列狀態；有穿越事件歸 MA.CROSS。單線位置與多線排列同屬順序關係狀態，不分葉。比較對象為 K 棒自身開盤價（含較高週期開盤）歸 PAT.DIR。
- 樣本：triple_ema_rsi_atr_heruurt5、multipletimeframestrategyjiahejuzhen_6clgb3x4#高週期收盤價在 EMA 上方

### MA.FADE 均線穿越逆勢（逆勢）
- 構成方式：計算短期與長期均線 → 做多：收盤價位於長期均線之下，且由前一根高於短期均線轉為當根不高於短期均線（向下穿越）即逆勢做多 → 做空：對稱，長期均線之上向上穿越短期均線做空；可只做多。
- 判別：與 MA.CROSS 同為價格單位穿越平均類線，但進場方向與穿越方向相反（逆勢）；參考為通道邊界或振盪器門檻歸 REV.EXTREME／REV.REENTRY；長期均線位置只是方向前提，記 F.trend_ma。
- 樣本：free_strategy_08_combo_of_01_and_02_es_spy_fe0nxce4#段1

---

## TS 追蹤線翻轉（順勢）

### TS.FLIP 追蹤停損線方向翻轉
- 構成方式：計算只隨方向單向推進、方向切換時跳至對側的追蹤線（Supertrend、拋物線 SAR、HalfTrend、Chandelier 等）→ 做多：方向由空翻多（收盤價穿越追蹤線）→ 做空：對稱，由多翻空。
- 判別：參考線具棘輪性質（只朝持倉方向移動）；參考線為一般平均類歸 MA.CROSS；參考線為滾動通道邊界歸 BRK.CHAN。
- 樣本：high_activity_penny_stock_strategy_v6_nfihxkxr

### TS.STATE 追蹤線方向狀態（順勢）
- 構成方式：計算只隨方向單向推進、方向切換時跳至對側的追蹤線（Supertrend 等，可多組同時）→ 做多：追蹤線方向為多（價格位於追蹤線之上）的狀態成立即進場（空倉時）→ 做空：對稱，方向為空。
- 判別：無翻轉事件，只看持續成立的方向狀態；有翻轉當根事件歸 TS.FLIP；參考線為一般平均類歸 MA.STATE；追蹤線方向只作其他核心的前提時記 F.trail_side。依決策順序第 5 條，與 MA.STATE 同列狀態優先序，排在 MA.STATE 之前。
- 樣本：ema_trend_pro_hedging_fixed_risk_xe3clizc#段2、ai_supertrend_x_pivot_percentile_strategy_presenttrading_ec3qaynq#段1、btc_v67_total_control_screener_klkroe7c#段4、supertrend_hombrok_bot_lzzgoo0d#段1、trend_flow_strategy_z4kcougt#段10

### TS.FADE 追蹤線翻轉反向進場（逆勢）
- 構成方式：計算拋物線 SAR 等追蹤線 → 做多：追蹤線由價格下方翻至價格上方（轉空翻轉）當根反向做多 → 做空：對稱，追蹤線翻至價格下方時做空；常附長均線同側、振盪器未過熱等濾網。
- 判別：與 TS.FLIP 同為追蹤線翻轉事件，但進場方向與翻轉方向相反；依第 6.1 條以核心觸發定順逆勢，長均線同側僅記 F.trend_ma，不改歸 PB.TOUCH。
- 樣本：indian_scalper_2025_psar_sma50_rsi50_high_volume_75_kqnzkldq#段1

---

## OSC 振盪器／動能訊號

### OSC.ZERO 振盪器穿越零軸／中線
- 構成方式：計算振盪器（動能、導數、RSI 類、量能指數標準化值）→ 做多：振盪器由負轉正（或由下穿越中線）的事件 → 做空：對稱，由正轉負。
- 判別：參考線是固定零軸或中線且為穿越事件；只要求處於門檻之上的狀態歸 OSC.LEVEL；參考線是振盪器自身平滑線歸 OSC.SIG；看斜率轉折而非符號歸 OSC.TURN；穿越的是超買超賣門檻且方向為逆勢（自超賣上穿做多）歸 REV.REENTRY。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#零軸模式、high_gain_volume_strategy_only_2_candles_lfy24cmy

### OSC.SIG 振盪器穿越其訊號線
- 構成方式：計算振盪器與其平滑訊號線（或另一振盪器）→ 做多：振盪器由下向上穿越訊號線（可要求穿越時位於負區或超賣區）→ 做空：對稱。
- 判別：兩線都在振盪器值域；兩線在價格單位歸 MA.CROSS。要求穿越時位於極端區屬附加濾網（F.rsi_band），不分葉；同根另有振盪器自超賣區穿回門檻的事件時，依決策順序歸 REV.REENTRY。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#訊號線模式、code_a_terminal_core_x5m5zevx#波動波線穿越訊號線路徑、haeri_network_qvstezum#CCI／RSI 穿越其 EMA 轉折路徑

### OSC.TURN 振盪器斜率轉折
- 構成方式：計算振盪器 → 做多：前值處於負區且為局部低點（前值低於其前值、現值高於前值）→ 做空：對稱，正區局部高點後轉下。
- 判別：觸發為振盪器方向反轉（局部極值），不要求穿越任何參考線。僅要求「高於前值」而無局部極值確認時屬 F.osc_dir。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#轉折模式

### OSC.LEVEL 振盪器／流量值門檻狀態
- 構成方式：計算振盪器或帶符號流量值（成交量 Delta、足跡加總、資金流、動能）→ 做多：數值高於正門檻（或零軸）的狀態成立即進場 → 做空：對稱，低於負門檻。
- 判別：順勢解讀（數值越高越做多）且為狀態；逆勢解讀（高值做空）歸 REV.EXTREME；有穿越事件歸 OSC.ZERO；數值在價格單位歸 MA.STATE。
- 樣本：zc_footprint_strategy_final_long_short_xyz9cdal

### OSC.SLOPE 振盪器斜率方向狀態
- 構成方式：計算振盪器（如 MACD 線）→ 做多：振盪器現值高於前一根值的狀態 → 做空：對稱，現值不高於前值。
- 判別：只看逐根斜率符號，無區域與局部極值要求；負區局部低點後轉上歸 OSC.TURN；相對固定門檻的狀態歸 OSC.LEVEL；斜率只作其他核心的前提時記 F.osc_dir。
- 樣本：macd_rsi_ema_sma_ichimoku_overbought_buy_sell_doji_dnjh5qa9#段5

---

## BRK 突破（順勢）

### BRK.CHAN 滾動通道突破
- 構成方式：計算滾動通道邊界（回看最高／最低含僅前一根高低、布林帶、肯特納通道、VWAP 標準差帶、多條均線的最大／最小值等，可加 ATR 緩衝）→ 做多：收盤價（或最高價觸及）突破上界 → 做空：對稱，跌破下界；可只做多。
- 判別：邊界為逐根滾動的統計通道；邊界為固定時段區間歸 BRK.ORB；邊界為確認擺動點歸 SW.BOS；需先有壓縮狀態再以動能定方向的狀態轉換歸 BRK.SQZ（僅以壓縮作前提再突破邊界者仍歸本葉，壓縮記 F.squeeze）。以「回看期最近創高晚於最近創低」定方向（Aroon 型）等同回看極值突破後的停留狀態，歸本葉。
- 樣本：keltner_channel_trend_based_strategy_ezsbm5ms、super_breakout_day_trading_scnniaco、gold_breakout_strategy_rr_4_lpo7kcs9、channelbreakoutstrategyv21_0ikdxjnd、multipletimeframestrategyjiahejuzhen_6clgb3x4#均線帶壓縮後站上全部 EMA、multipletimeframestrategyjiahejuzhen_6clgb3x4#平倉後突破布林上軌再進場、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#趨勢模式上穿上軌帶、3strategy_auto_switch_range_trend_breakout_mol1swle#突破模式、golden_trident_swinganchored_vwap_trend_system_eq4kprrj、smb_magic_b85od95c、masu_institutional_fibonacci_mtf_btt_qckigf3z#收盤突破前回看高點路徑、cluster_breakout_strategy_v6_robust_dkdnmqsn

### BRK.ORB 固定時段區間突破
- 構成方式：計算特定時段（開盤首根、首段區間、盤前、前一日、亞洲盤）的高低點並在當日固定 → 做多：收盤價上穿區間高點（可加緩衝）→ 做空：對稱，下穿區間低點。
- 判別：參考價位在時段結束後固定不再滾動；越界後收回反向進場歸 LQ.SWEEP；觸及但未越界即反向歸 SR.TOUCH。
- 樣本：thinktech_ai_signals_xjjyblba#首根日線區間突破、ai_mes_asian_session_strategy_hr3tvgbs#突破路徑

### BRK.SQZ 波動壓縮釋放
- 構成方式：計算內通道（布林帶）與外通道（肯特納通道）判定壓縮開啟／解除，另算動能值 → 做多：前一根壓縮開啟、當根壓縮解除且動能為正 → 做空：對稱，動能為負。
- 判別：觸發是壓縮狀態轉換，方向由動能符號決定，不要求價格穿越通道邊界；直接穿越邊界歸 BRK.CHAN。
- 樣本：squeeze_momentum_strategy_g9yz2qif

### BRK.KEYBAR 事件棒衍生價位突破（順勢）
- 構成方式：先以單根 K 棒特徵（放量、實體比例、收盤方向、收盤變動超過 ATR 倍數）篩出關鍵棒，以其高低點（或加減波幅／ATR 偏移）設定價位並延續至下一根關鍵棒 → 做多：收盤價（或價格）由下向上越過該價位 → 做空：對稱，跌破對應價位。
- 判別：參考價位由事件棒衍生，非逐根滾動通道（BRK.CHAN）、非固定時段區間（BRK.ORB）、非左右回看確認擺動點（SW.BOS）；越界後收回歸 LQ.SWEEP；越過偏移即逆勢進場歸 REV.OVERSHOOT；觸發為關鍵棒形態本身成立歸 PAT.BAR；回測守住記 F.retest。多事件優先序與 BRK.ORB 同列。
- 樣本：catch_the_big_fish_zkyk1bvd#段2、kptahab_poor_mans_orderflow_simple_algopilot_mqddel1e#段1、breakout_trend_trading_strategy_v1_npquimkd#段1

### BRK.SQZON 壓縮開始雙通道邊界交叉
- 構成方式：計算布林帶與肯特納通道 → 做多：肯特納上軌由下向上穿越布林上軌（布林上側收入肯特納內，壓縮開始）→ 做空：對稱，肯特納下軌由上向下穿越布林下軌。
- 判別：觸發為壓縮開始事件且方向由交叉的邊界側決定；壓縮解除並以動能符號定方向歸 BRK.SQZ；價格穿越通道邊界歸 BRK.CHAN。
- 樣本：bb_and_kc_strategy_huk5mtui#段1

---

## REV 通道／振盪器回歸（逆勢）

### REV.EXTREME 超買超賣區狀態
- 構成方式：計算振盪器（RSI、隨機、MFI、威廉、CCI 等，可多個同時）或滾動通道 → 做多：振盪器低於超賣線，或價格位於（接近）通道下界之下的狀態成立（或剛向下穿越下界）即進場 → 做空：對稱，超買或位於上界之上。
- 判別：處於極端區當下即逆勢進場，不等待反轉事件。價格相對通道位置與振盪器同為標準化偏離（如 %B），不分葉。需先越界再收回（含振盪器自超賣上穿門檻）歸 REV.REENTRY；極端區內振盪器穿越訊號線歸 OSC.SIG；順勢解讀的門檻狀態歸 OSC.LEVEL；順勢突破歸 BRK.CHAN；多項超伸指標加權計分歸 CMP.EXHAUST。
- 樣本：strategyrsmarxbabu_4_oscillators_v0_21jneuwf、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#均值回歸模式位於或下穿下軌帶、3strategy_auto_switch_range_trend_breakout_mol1swle#震盪模式、eworsi_advanced_signals_strategy_exhaustion_filter_b7mqqwes#RSI 低於門檻且 EWO 負區回升路徑

### REV.REENTRY 越界後收回
- 構成方式：計算滾動通道邊界（布林帶、VWAP 標準差帶、回看最高／最低等）或振盪器超買超賣門檻 → 做多：前一根收在下界之下（或創回看新低、或當根最低價刺穿下界）而當根收回下界之上（可要求回升超過 ATR 門檻），或振盪器由超賣區向上穿越超賣門檻 → 做空：對稱，上界越界後收回或振盪器自超買區下穿門檻。
- 判別：邊界為滾動統計通道或振盪器門檻，方向為逆勢且需有收回事件；邊界為固定時段價位或確認擺動點歸 LQ.SWEEP；仍在界外即進場歸 REV.EXTREME；順勢穿越歸 BRK.CHAN；穿越中線歸 OSC.ZERO。
- 樣本：bollinger_bounce_reversal_strategy_visual_edition_30vzsmvl、thinktech_ai_signals_xjjyblba#回看極值反彈、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#均值回歸模式刺穿後收回、stochrsirsidoublestrategycmwilliamsvixfixmfi_ikgt0gxk、masu_institutional_fibonacci_mtf_btt_qckigf3z#ADX 盤整下布林下軌外 RSI 上穿超賣路徑、eworsi_advanced_signals_strategy_exhaustion_filter_b7mqqwes#RSI 上穿門檻路徑

### REV.OVERSHOOT 離散價位越界幅度逆勢
- 構成方式：計算離散基準價位（放量確認樞紐、唯一放量大區間反應棒的高低點，可限最大存續柱數）→ 做多：收盤價（或最低價觸及限價）低於支撐基準達設定跌幅或區間比例偏移即逆勢做多，不等待收回 → 做空：對稱，越過壓力基準達偏移。
- 判別：基準為離散固定價位且在界外當下進場；邊界為滾動統計通道或振盪器門檻歸 REV.EXTREME；須越界後收回歸 LQ.SWEEP；觸及而未越界歸 SR.TOUCH；同向突破歸 BRK.KEYBAR 或 SW.BOS。
- 樣本：3c_qfl_mean_reversal_sdrm0bby#段1、obs_volume_spike_reaction_fade_nq_fmpc9fwd#段1

---

## DIV 背離（逆勢）

### DIV.REG 常規背離
- 構成方式：比較兩個回看窗口（或兩個確認擺動點）中價格極值與振盪器或累積成交差額極值 → 做多：價格低點更低而振盪器低點更高 → 做空：對稱，價格高點更高而振盪器高點更低。
- 判別：觸發來自價格與振盪器極值方向不一致；僅看振盪器本身轉折歸 OSC.TURN；背離只作另一觸發的前提或計分項時記 F.divergence，不歸本葉。
- 樣本：reversal_trading_bot_strategybullbyte_cxvnf1wh、nqmnq_ct_scalper_backtest_1kekmbb9#價格破前波段低點而 Delta／RSI 背離路徑

### DIV.HID 隱藏背離（順勢）
- 構成方式：比較兩個確認擺動點（或樞紐）的價格極值與振盪器值 → 做多：價格低點高於前低而振盪器低點低於前低 → 做空：對稱，價格高點低於前高而振盪器高點高於前高。
- 判別：與 DIV.REG 同為極值方向不一致，但比較方向相反、屬順勢延續；背離只作其他觸發的前提時記 F.divergence。多事件優先序與 DIV.REG 同列。
- 樣本：adaptive_dualengine_strategy_momentum_mean_reversion_bt_f9xlzqpf#段4、rsi_overbought_oversold_divergence_strategy_w_buysell_signals_d92hvfqx#段2

---

## SW 擺動結構

### SW.PIVOT 確認樞紐反轉
- 構成方式：以左右回看確認樞紐高／低點 → 做多：本根確認樞紐低點（並落在以樞紐低點加 ATR 定義的需求區內）即逆勢做多 → 做空：對稱，確認樞紐高點做空。
- 判別：觸發是樞紐點本身被確認（逆勢）；突破樞紐點歸 SW.BOS；觸及既有固定價位區歸 SR.TOUCH。
- 樣本：ultimate_prop_firm_artillery_pkupybw7

### SW.BOS 擺動結構突破
- 構成方式：以左右回看確認擺動高低點 → 做多：收盤價向上突破最近確認擺動高點（可要求配合均線穿越的先後次序與時窗、或位於同向公平價值缺口）→ 做空：對稱，跌破最近確認擺動低點。
- 判別：參考價位是離散確認擺動點而非滾動通道（後者歸 BRK.CHAN）；先有掃蕩再以 BOS 確認時歸 LQ.SWEEP。
- 樣本：13_ema_breakout_liquidity_sweep_bos_confirmation_a_a_iueqdndd#形態路徑（雙底、區間收斂、高低點收斂後 BOS）、vortex_confluence_protocol_joat_xtp27uk6

### SW.TLBRK 擺動點連線趨勢線突破（順勢）
- 構成方式：以兩個（或以上）依序較低（較高）的確認擺動高（低）點連成斜向趨勢線並延伸至當根 → 做多：收盤價向上突破下降阻力線（可加 ATR 緩衝、要求線未失效未過期）→ 做空：對稱，跌破上升支撐線。
- 判別：參考為兩擺動點決定的斜線；單一擺動點水平價位歸 SW.BOS；逐根滾動統計通道歸 BRK.CHAN。多事件優先序與 SW.BOS 同列。
- 樣本：the_strategy_ichimoku_kinko_hyo_and_more_dqayjnzk#段11、diy_custom_strategy_builder_zp_v1_strategy_8z6wbyw5#段5、trendbreaker_pro_auto_trendline_break_strategy_with_momentum_2u7kkccg#段1

---

## LQ 流動性掃蕩（逆勢）

### LQ.SWEEP 關鍵價位掃蕩後收回
- 構成方式：計算離散關鍵價位（前日／前時段／時段初始區間高低、前期區間高低、未破壞且未過期的確認擺動點）→ 做多：價格先跌破低位（可要求至少 ATR 緩衝）或前一根收在低位之下，並在允許時窗內收回低位之上（常再以 BOS、吞噬、次根收過掃蕩中點或均線穿越確認）→ 做空：對稱，刺穿高位後收回其下。
- 判別：參考價位為離散固定價位且須先越界；滾動統計通道越界收回歸 REV.REENTRY；觸及而未越界即反向歸 SR.TOUCH。
- 樣本：13_ema_breakout_liquidity_sweep_bos_confirmation_a_a_iueqdndd#掃蕩路徑、liquidity_sweep_tracker_smart_money_stop_hunts_on7jauut、ai_mes_asian_session_strategy_hr3tvgbs#均值回歸路徑、sweep_reverse_liquidity_sweep_reversal_strategy_goeqo1ev、nqmnq_ct_scalper_backtest_1kekmbb9#前期區間低點掃蕩收回路徑

---

## SR 支撐阻力觸及（逆勢）

### SR.TOUCH 固定價位區觸及反轉
- 構成方式：計算離散固定價位（前一日高低、自適應擴大的多日區間高低、高成交量區邊界）及其周圍觸及區 → 做多：當根低點落入（或由上方回測）支撐觸及區而收盤守在區間下界之上 → 做空：對稱，高點落入阻力觸及區而收盤守在上界之下。
- 判別：觸發是價格進入價位區而未越界，且無趨勢方向前提；以趨勢方向為前提或價位由趨勢擺動推導（斐波那契回撤）歸 PB.TOUCH；須先越界再收回歸 LQ.SWEEP；觸發是擺動點本身被確認歸 SW.PIVOT。
- 樣本：adaptive_sr_reversal_rsi_divergence_dca_be_stop_5m_pfdze7mb#初始進場、nqmnq_ct_scalper_backtest_1kekmbb9#高成交量區回測守住路徑

---

## PB 順勢回檔（順勢）

### PB.TOUCH 順勢回檔觸及參考線
- 構成方式：先以趨勢分數、基線方向、擺動方向（最近高點晚於低點）等界定趨勢 → 計算參考線（自適應基線周圍的內通道、均線、最近擺動的斐波那契回撤位）→ 做多：上升趨勢中最低價回落觸及參考線或其 ATR 容差區，且收盤守在參考線之上（可要求下影線比例或收陽）→ 做空：對稱，下降趨勢中最高價反彈觸及參考線。
- 判別：趨勢方向是構成要件，進場方向與趨勢同向；無趨勢前提的水平價位觸及歸 SR.TOUCH；先突破再回測突破位者歸其突破葉並記 F.retest；價格位於均線之上即進場而無觸及事件歸 MA.STATE。
- 樣本：masu_institutional_fibonacci_mtf_btt_qckigf3z#上行擺動中觸及斐波那契回撤區路徑、crownmark_allocation_engine_joat_wf07i8bf

### PB.BAR 順勢中逆向 K 棒進場
- 構成方式：計算趨勢參考線（VWAP 等）並以當根與前根值定斜率 → 做多：參考線上升時當根收盤低於開盤（逆向陰線）即做多 → 做空：對稱，參考線下降時當根收陽即做空。
- 判別：以逆向 K 棒作回檔訊號，不要求觸及參考線；觸及參考線歸 PB.TOUCH；K 棒方向與進場同向歸 PAT.DIR；看價格相對參考線位置歸 MA.STATE。
- 樣本：vj_viper_vwap_intraday_eh1lm5kx#段1

---

## PAT K 棒形態

### PAT.BAR K 棒形態
- 構成方式：比較當根與前數根（通常一至三根）的開高低收、實體、影線，或其相對 ATR、近期均值的大小 → 做多：形成指定看多形態（外包線且收陽、吞噬、錘子、晨星、三白兵、放量小實體收陽等；可為形態庫中達強度門檻者的平均強度）→ 做空：對稱，看空形態。
- 判別：觸發只來自少數 K 棒的形態特徵；只看單根收盤是否高於開盤而無形態要求歸 PAT.DIR；以前一根高低為邊界的收盤突破歸 BRK.CHAN；形態只作其他觸發的確認時記 F.confirm_bar；形態要求鄰近支撐阻力記 F.near_level。
- 樣本：advanced_outside_with_hma_and_klinger_forex_swing_strategy_v5vo0vnc、grand_masters_candlestick_dominance_atr_enhanced_ubnhdo2q、mcg1_5min_egevkh_prznz3m7、nqmnq_ct_scalper_backtest_1kekmbb9#放量小區間小實體收陽路徑

### PAT.DIR 週期 K 棒方向狀態
- 構成方式：取當根或較高週期 K 棒的開盤與收盤（較高週期以期內首根開盤、末根收盤）→ 做多：收盤價高於開盤價的狀態 → 做空：對稱，收盤低於開盤。
- 判別：只看 K 棒漲跌方向，不涉多根形態；附加形態結構歸 PAT.BAR；比較對象為均線歸 MA.STATE。
- 樣本：htf_candle_direction_strategy_v1_3kv64pea

---

## CNT 計數循環

### CNT.PEAK 狀態變化計數達峰值
- 構成方式：對某二元狀態（K 棒收陽與否、成交量高於均量與否）的每次變化按當前方向累加計數，絕對值達峰值時反轉計數方向 → 做多：計數等於負向峰值 → 做空：對稱，等於正向峰值。
- 判別：觸發來自事件次數累計而非價格水準；以連續同向根數作上限濾網記 F.extension。
- 樣本：sine_wave_theory_krgoqyrb#K 線顏色變化計數、sine_wave_theory_krgoqyrb#成交量狀態變化計數

### CNT.EXHAUST 連續同向計數耗竭（逆勢）
- 構成方式：逐根比較收盤價與前一根（或回看 N 根前）收盤價，累計連續（或累加）同向根數，觸發或遇反向即歸零 → 做多：下跌計數達門檻（可多組回看與門檻），可再要求反向收 K、觸及回看最低價、放量或位於通道外確認，即逆勢做多 → 做空：對稱（多空門檻可不同）。
- 判別：計數對象為同向延續根數（TD／Leledc 型）；二元狀態變化次數達峰值反轉歸 CNT.PEAK；順勢以計數達門檻追進歸 CNT.STREAK；連續根數只作上限濾網記 F.extension；反向 K 棒與回看極值觸及記 F.candle_dir、F.key_level。
- 樣本：the_bar_counter_trend_reversal_strategy_tradedots_0katqqdd#段1、strategy_death_to_the_bear_cowm0rkz#段1、ema_bands_leledc_bollinger_bands_trend_following_strategy_v2_rqclxyiw#段3

### CNT.STREAK 連續同向計數延續（順勢）
- 構成方式：計算連續上漲（收盤高於前一收盤）的根數或 tick 數，非上漲即歸零 → 做多：連續上漲數達門檻（可要求當根收陽）即順勢做多 → 做空：對稱，連續下跌數達門檻。
- 判別：與 CNT.EXHAUST 計數結構相同但進場方向相反（順勢）；少數固定根數形態歸 PAT.BAR。
- 樣本：tick_strategy_j2vh9jlh#段1

---

## CMP 多指標合成

### CMP.SCORE 順勢加權計分門檻
- 構成方式：將多項順勢條件（均線位置、振盪器方向、背離、追蹤線方向、成交量、高週期、VWAP、斐波那契方向、ADX 等）依權重或成立項數加總為多、空方向分數 → 做多：多方分數達門檻、高於空方分數或領先達差額（或方向狀態由非多轉多）→ 做空：對稱。
- 判別：分數本身即唯一觸發，無單一主導結構；分數只作另一觸發的前提時記 F.score，不歸本葉；分數項目以反向超伸為主歸 CMP.EXHAUST。
- 樣本：quantumforextradersniperfusionstrategyv2_oq1ju4ha#計分路徑、haeri_network_qvstezum#方向分數路徑、masu_institutional_fibonacci_mtf_btt_qckigf3z#多空分數比較路徑

### CMP.EXHAUST 逆勢超伸計分門檻
- 構成方式：將反向超伸項目（價格偏離均線與 VWAP、通道外位置、振盪器極值、相對成交量、影線拒絕、動能衰減）與反轉確認項目（吞噬、錘形、反向結構突破、背離、掃蕩收回）分別加權加總 → 做多：先前下跌且空頭超伸分數與反轉確認分數皆達門檻 → 做空：對稱。
- 判別：分數構成以逆勢偏離為主；單一振盪器或通道極端歸 REV.EXTREME；分數只作其他觸發的前提時記 F.score。
- 樣本：nqmnq_ct_scalper_backtest_1kekmbb9#超伸與反轉確認分數基本路徑

---

## PM 部位管理核心

### PM.DCA 逆向間距加碼
- 構成方式：已有持倉且未達加碼上限 → 做多加碼：價格自最差進場價逆向達間距比例即再進場 → 做空：對稱；目標與停損改以首次進場價或最差進場價偏移計算。
- 判別：加碼由不利價格移動觸發；順勢加碼或固定價格網格另議。初始進場另歸其觸發所屬葉節點。
- 樣本：adaptive_sr_reversal_rsi_divergence_dca_be_stop_5m_pfdze7mb#加碼

### PM.PYRAMID 順勢間距加碼
- 構成方式：已有持倉且加碼次數（或距初始進場時窗）未達上限 → 做多加碼：收盤價自初始進場價或持倉均價順向推進達間距（持有單位數乘 ATR、漲幅百分比、固定距離、持倉獲利分級門檻，或持倉期間突破短回看最高價）即同向再進場 → 做空：對稱。初始進場另歸其觸發所屬葉。
- 判別：加碼由有利價格移動觸發；不利移動觸發歸 PM.DCA；依位置分級調整目標部位歸 PM.TIER；持倉期間的突破加碼以既有持倉為構成要件，不歸 BRK.CHAN。
- 樣本：turtle_swing_v20_0igxqoj5#段2、big_trend_catcher_quadgate_vcp_atr_trailing_swing_trade_srrb0tts#段3、shanmugha_intraday_and_positional_for_selling_4r2zsx3v#段2、v3_valentini_pro_scalper_dashboard_3yqoiuyr#段2、automate_on_hyperliquid_strategy_webhook_template_hyprrun_khbr2h0r#段4、follow_the_money_v110_8giafrcp#段2、padayappa_jazexika#段2、big_trend_catcher_dualgate_ema_atr_trailing_swing_trader_5lobhpnz#段3

### PM.GRID 價格網格
- 構成方式：以回看高低區間等距切分網格，或維護價格階梯（收盤超出前階梯加減間距即更新為當前收盤）→ 做多：收盤由上向下穿越某網格價位（可限區間下半部），或階梯下移（逆勢網格）／上移（順勢網格）即做多，常以上方鄰近網格停利 → 做空：對稱。
- 判別：每次進場由網格價位穿越觸發，不須已有持倉；持倉後自最差進場價逆向間距加碼歸 PM.DCA；通道邊界極端或收回歸 REV.EXTREME／REV.REENTRY；觸及支撐而收盤守住歸 SR.TOUCH。
- 樣本：crypto_grid_2025_long_only_asym_tp_xvyn23oc#段1、the_strategy_ichimoku_kinko_hyo_and_more_dqayjnzk#段12

### PM.TIER 分級目標權重調倉
- 構成方式：計算收盤價相對多條均線的 ATR 標準化距離，截限後平均並量化為階梯目標權重 → 做多加倉：目標權重升階即加倉 → 減倉：目標權重降階（可附收盤不低於平滑線）即減倉，權重歸零平倉；只做多。
- 判別：部位由目標權重函數連續調整；以進場價順向間距加碼歸 PM.PYRAMID；逆向間距歸 PM.DCA。初始進場（權重大於零）另歸 MA.STATE。
- 樣本：turks_tiered_unit_risk_kernel_strategy_worximlc#段2

### PM.SLREV 停損後反手
- 構成方式：已有持倉並觸及停損（或前一筆因停損出場而空倉）→ 經等待期、冷卻或當日次數限制，並可要求收盤位於最近擺動點同側 → 反向進場；多空對稱，翻倉單可另設時間停損。
- 判別：觸發來自自身持倉的停損事件；以反向訊號出場記 X.reverse_signal；擺動點同側只是狀態濾網記 F.key_level。初始進場另歸其觸發葉。
- 樣本：btc_mtf_engulfing_flip_pyramid_strategy_1h_2x_gouoysjs#段2、btc_mtf_engulfing_flip_strategy_1h_2x_xgqszuxj#段2、nas100_3min_breakout_reverse_after_sl_vw4m6aca#段2

---

## EXT 外部來源

### EXT.FEED 外部來源通用轉接
- 構成方式：以使用者指定的外部輸入來源（主要、次要、第三來源、止盈止損來源）作比較、穿越、非零有效等多種可選模式 → 做多：所選模式成立 → 做空：對應模式成立（不必對稱）。
- 判別：來源的計算未定義，無法判定數學結構；只要任一來源有明確計算即依其結構歸類，不歸本葉。整份不拆段。
- 樣本：universal_strategy_feed_gu6rduh5

---

## VOL 量能結構

### VOL.CLIMAX 爆量逆趨勢（逆勢）
- 構成方式：計算成交量均值與標準差，另以快慢均線定趨勢 → 做多：成交量高於均量加標準差倍數且快線低於慢線即逆勢做多 → 做空：對稱，上升趨勢中爆量即做空。
- 判別：極端值為無方向的成交量，方向取自與趨勢相反；帶方向的振盪器或價格極端歸 REV.EXTREME；放量只作濾網記 F.volume；方向與趨勢相同歸 VOL.SURGE。
- 樣本：velocity_breakout_strategy_vbs_m1jdhfr9#段4

### VOL.SURGE 無號放量異動狀態
- 構成方式：計算成交量均線（及回看期價格變動絕對值）→ 做多：成交量高於均量倍數（且價格變動絕對值超過門檻比例）的狀態成立，方向由輔助動能決定或只做多 → 做空：若有，則由輔助動能對稱決定。
- 判別：核心為無號放量或無號異動幅度；帶符號流量值的順勢門檻歸 OSC.LEVEL；逆趨勢方向歸 VOL.CLIMAX；放量只作濾網記 F.volume；動能方向記 F.osc_dir。
- 樣本：kl_relative_volume_atr_strategy_e1iapmtk#段1、max_pain_strategy_jujejit7#段1

### VOL.LEVEL 成交量相對均量定向
- 構成方式：計算成交量與其移動平均 → 做多：成交量低於均量的狀態 → 做空：成交量高於均量的狀態；不涉任何價格方向或價位。
- 判別：方向純由無號量能高低映射；放量時方向取自趨勢歸 VOL.CLIMAX／VOL.SURGE。
- 樣本：hidden_gaps_vsa_volume_d9rrdb4s#段1

### VOL.ABSORB 流量耗竭吸收後突破起始棒（逆勢）
- 構成方式：計算衰減累積的帶符號高量影響 → 熊市耗竭：累積影響低於負極端門檻且連續非正達根數門檻、價格區間窄且最低價未跌破起始棒最低價 → 做多：耗竭成立後本根最高價突破耗竭起始棒最高價 → 做空：對稱。
- 判別：需流量極端與價格守住同時成立再以突破起始棒確認；極端區當下進場歸 REV.EXTREME；比較兩個極值歸 DIV.REG；起始棒突破只作確認，不歸 BRK.KEYBAR。
- 樣本：volume_block_order_analyzer_nmag7dki#段3

---

## ML 機器學習分類

### ML.KNN 近鄰分類標籤翻轉
- 構成方式：以均線或追蹤線關係作歷史樣本標籤，依當前特徵與樣本距離取最近鄰並以距離倒數加權得分類 → 做多：分類由非多轉為多（可多組回看期任一）→ 做空：對稱。
- 判別：觸發為分類器輸出的狀態轉換，與當根均線或追蹤線關係不等價；直接比較兩線歸 MA.CROSS／MA.STATE；追蹤線本身翻轉歸 TS.FLIP；分類結果只作濾網記 F.other。
- 樣本：multitf_ai_supertrend_with_adx_strategy_presenttrading_feoube91#段1、ai_supertrend_strategy_presenttrading_eatiyety#段1

---

## NUL 無判斷結構

### NUL.ALWAYS 恆真進場
- 構成方式：進場條件為「收盤價不為零」之類恆真式 → 做多／做空：所選方向於每根皆成立（受持倉狀態與出場條件約束）。
- 判別：條件已定義但恆真；來源計算未定義歸 EXT.FEED。
- 樣本：the_strategy_ichimoku_kinko_hyo_and_more_dqayjnzk#段3

### NUL.RANDOM 偽隨機觸發
- 構成方式：以逐棒索引遞推偽隨機值並轉為常態值，再以價格回看均值與標準差縮放 → 做多：該值低於當根（或連續數根）最低價 → 不做空。
- 判別：觸發值為與價格無統計關聯的確定性偽隨機序列，非通道或均線。
- 樣本：aphrodite_xdxpllf1#段1

### NUL.NOENTRY 僅出場無進場
- 構成方式：檔案無任何進場條件，只定義出場（停損、停利、鎖利、均線出場等）。
- 判別：所有其他葉皆以進場觸發定義；出場內容記 X. 標籤。
- 樣本：forex_apex_matrix_v5_hmm_stationarity_core_poxbawem#段1

---

## 濾網標籤

- F.trend_ma：價格或快線相對長期均線、VWAP、自適應基線（或兩均線相對位置）決定可做方向。
- F.ma_stack：多條均線依序排列，或相鄰均線對同向排列的組數達門檻，才可進場。
- F.slope：均線、VWAP、基線或通道邊界的斜率方向需與進場方向一致（含 Hull 均線由降轉升、均線高於回看期前值）。
- F.htf：較高週期指標條件須同向，或價位須鄰近較高週期擺動點。
- F.adx_di：ADX 高於門檻（趨勢）或低於門檻（盤整），及／或 +DI、−DI 相對大小同向；可用於模式切換。
- F.efficiency：效率比（淨變動除以逐根變動總和）須高於（或低於）門檻。
- F.prior_move：回看期淨變動方向須與進場方向相反（逆勢策略要求先跌後做多）或相同。
- F.swing_dir：最近擺動高點晚於最近擺動低點，或高低點呈較高高點、較高低點結構，決定可做方向。
- F.osc_dir：輔助振盪器方向同向（如 MACD 高於訊號線、動能線高於其平滑線或前值、量能加權值符號、Klinger、資金流符號、壓力值高於其訊號）。
- F.osc_cross：輔助振盪器發生同向交叉作確認（如短期 RSI 上穿長期 RSI、RSI 自超賣上穿、隨機 K 上穿比較線）。
- F.rsi_band：振盪器須位於指定區間（未超買／未超賣、偏離中點、超賣才做多、訊號線位於負區、MFI 高於門檻等）。
- F.divergence：須於有效回看期內出現同向常規背離，或近期不得出現反向（含隱藏）背離。
- F.trail_side：價格須位於拋物線 SAR、Supertrend 等追蹤線的同向側。
- F.volume：成交量高於均量、前一根成交量或其倍數，或高於最低門檻（含掃蕩 K 棒放量）。
- F.volatility：ATR、帶寬、真實波幅標準分數或回看高低範圍高於門檻（絕對、相對收盤價或相對其長期均值的倍數）。
- F.range_width：參考區間（如開盤區間）幅度須介於下限與上限之間。
- F.squeeze：須處於壓縮狀態（多條均線纏繞範圍小於布林帶寬、回看區間寬度不大於 ATR 倍數、ATR 低於較早值）。
- F.band_pos：價格須位於某通道內特定位置（如中軌之上、下軌之下、價值區內、不超過外通道）。
- F.key_level：價格須在指定關鍵價位之上／下（如盤前高點、前回看高點）。
- F.near_level：價格須位於支撐阻力、擺動點、回撤位或高成交量區的容差範圍內（ATR 倍數或百分比）。
- F.fvg：價格須位於同向公平價值缺口內。
- F.extension：近期漲跌幅或連續同向根數不超過上限，或價格距均值不超過 ATR 倍數，避免追高殺低。
- F.candle_dir：進場 K 棒須為同向實體，或收盤高於（低於）開盤、前收盤、前一根開盤，或創高（創低）。
- F.close_pos：收盤價在當根全幅中的位置須達強勢（弱勢）門檻。
- F.wick：影線相對實體或全幅的比例須達門檻（拒絕影線）。
- F.confirm_bar：須出現確認 K 棒（吞噬、實體達 ATR 位移、收盤突破訊號 K 棒高低點、次根收盤越過掃蕩 K 棒中點）。
- F.pattern：須先出現指定價格形態（雙底、區間收斂、高低點收斂）。
- F.retest：須回測突破位或均線後再進場。
- F.score：多項條件加權分數或成立項數須高於門檻。
- F.min_rr：預期目標距離除以停損距離須達報酬風險比門檻。
- F.min_risk：停損距離不得小於 ATR 倍數（避免過窄停損）。
- F.session：僅在指定交易時段或進場截止時點前進場。
- F.date：僅在指定年份、日期或回測區間內交易（含起始日）。
- F.daily_limit：當日（或當時段）交易次數或回撤未達上限。
- F.cooldown：距上次出場或進場須經過指定根數。
- F.rearm：同向訊號須在條件先失效後才可再觸發、前次訊號方向須不同，或須較上次同向訊號價推進 ATR 距離。
- F.flat：須空倉或每段僅允許一次進場。
- F.confirm：須等 K 棒收定或暖機完成。

## 出場標籤

- X.stop_pct：進場價（或持倉均價）固定百分比（或固定距離）停損。
- X.tp_pct：進場價（或持倉均價）固定百分比（或固定距離）停利。
- X.stop_atr：進場價減（加）ATR 倍數停損（可乘波動比並以最大距離封頂）。
- X.tp_atr：進場價加（減）ATR 倍數停利。
- X.tp_rr：以初始風險距離乘風險報酬比設定停利。
- X.tp_multi：多段停利目標、任一停利比例觸發、逐級推進的獲利限價或分批減倉（如第一目標平半倉）。
- X.stop_bar：以訊號 K 棒高低點為停損。
- X.stop_swing：以最近確認擺動點或近期極值加緩衝為停損。
- X.stop_level：以區間、掃蕩極值（影線）、通道帶線或關鍵價位對側（加緩衝）為停損。
- X.tp_level：以相反側流動性位、未填補缺口中點、外層帶線或區間寬度投影為停利。
- X.tp_mid：以通道中軸、區間中點或 VWAP 為回歸停利。
- X.trailing_atr：以收盤價（或極值）減（加）ATR 或波動幅度倍數逐根推進的移動停損。
- X.trailing_swing：移動停損至進場後最新反向擺動點加緩衝。
- X.trailing_pct：啟動後（或首段停利觸發後）自持倉期間最高（最低）價回撤達百分比出場。
- X.trailing_ma：價格跌破（升破）均線即出場。
- X.trailing_step：依獲利比率分段收緊的移動停損。
- X.breakeven：達到指定獲利（百分比、ATR 倍數或進場至目標距離的進度比例）後停損移至進場價或其偏移。
- X.band_opposite：收盤價穿越通道對側或反向邊界出場。
- X.trend_flip：趨勢均線關係、追蹤線方向反轉，或收盤穿越自適應基線出場。
- X.structure_break：出現反向擺動結構突破出場。
- X.reverse_signal：出現反向進場訊號（或反向弱訊號）出場或反手。
- X.osc_cross：輔助振盪器反向交叉出場（如隨機 RSI K 線低於 D 線）。
- X.momentum_fade：動能值、趨勢分數或壓力值歸零（反向越過零）、不再擴張或低於出場門檻出場。
- X.indicator_cap：指標超過過熱上限或自超買（超賣）區回落出場。
- X.divergence：近期出現反向背離出場。
- X.volume_spike：成交量暴增超過均量倍數出場。
- X.sar：價格跌破拋物線轉向指標出場。
- X.candle_reversal：出現反向 K 棒或吞噬形態（可附加獲利未達門檻）時出場。
- X.external：外部指定的止盈或止損來源由零轉為非零時出場。
- X.min_hold：出場訊號須持倉達最短根數才生效。
- X.time：持倉根數達上限或進場後固定根數出場（可附加未獲利、未出現有利結構突破條件）。
- X.session_end：時段結束平倉（可依獲利條件延後一次）。

---

## v1→v2 變更

- 新增核心族 TS 及葉 TS.FLIP；新增葉 REV.EXTREME；新增核心族 SR（SR.TOUCH）、PAT（PAT.BAR）、CMP（CMP.SCORE）、PM（PM.DCA）。
- 擴充並更名 MA.STACK → MA.STATE；擴充 BRK.CHAN、MA.CROSS、OSC.SIG、REV.REENTRY、LQ.SWEEP、DIV.REG 的定義與判別。
- 新增「或」並列路徑拆開、部位管理與進場分列規則；擴充濾網與出場標籤。

## v2→v3 變更

- 新增檔首總覽表與「歸類決策順序」一節：拆段規則（含嵌套「或」不拆、共用前提的處理）、EXT.FEED 整份特判、事件優先於狀態、多事件優先序、無事件時狀態優先序、以核心觸發定順逆勢。
- 新增葉 OSC.LEVEL：振盪器或帶符號流量值（足跡 Delta）處於門檻之上即順勢進場的狀態，與 OSC.ZERO（穿越事件）、REV.EXTREME（逆勢解讀）區分。
- 新增核心族 PB 及葉 PB.TOUCH：以趨勢為構成前提的回檔觸及（自適應基線內通道、斐波那契回撤位），與無趨勢前提的 SR.TOUCH 區分。
- 新增葉 PAT.DIR：當根或較高週期 K 棒收盤相對開盤的方向狀態。
- 新增核心族 CNT 及葉 CNT.PEAK：狀態變化次數計數達峰值即進場。
- 新增葉 CMP.EXHAUST，並將 CMP.SCORE 限定為順勢計分：計分項以反向超伸為主時方向為逆勢，依粒度原則分葉。
- 新增核心族 EXT 及葉 EXT.FEED：來源未定義計算的通用訊號轉接器，整份歸此葉。
- 擴充 REV.REENTRY：納入振盪器自超賣（超買）區穿回門檻的事件，與通道越界收回視為同構；OSC.ZERO、OSC.SIG、REV.EXTREME 判別同步更新。
- 擴充 PAT.BAR：由「單／雙根」改為少數 K 棒形態，納入三根形態、形態庫強度門檻、放量小實體形態。
- 擴充 SR.TOUCH 價位納入高成交量區並增設「無趨勢前提」判別；LQ.SWEEP 價位納入前期區間高低與未過期擺動點，確認方式納入次根收過掃蕩中點；DIV.REG 比較對象納入累積成交差額；MA.CROSS 慢線納入均線加斜率修正值；BRK.CHAN 邊界可加 ATR 緩衝。
- 新增濾網標籤：F.efficiency、F.prior_move、F.swing_dir、F.near_level、F.close_pos、F.wick、F.min_risk。
- 擴充濾網標籤定義：F.trend_ma、F.ma_stack、F.slope、F.osc_dir、F.osc_cross、F.rsi_band、F.divergence、F.volume、F.volatility、F.squeeze、F.band_pos、F.key_level、F.candle_dir、F.confirm_bar、F.score、F.date、F.rearm。
- 新增出場標籤：X.divergence、X.external。
- 擴充出場標籤定義：X.stop_pct、X.tp_pct、X.tp_multi、X.stop_level、X.trailing_pct、X.breakeven、X.trend_flip、X.reverse_signal、X.momentum_fade、X.time。
- v1→v2 變更小節精簡保留要點。

## 全量歸類後新增

- 新增族：VOL（量能結構）、ML（機器學習分類）、NUL（無判斷結構）。
- MA.FADE 均線穿越逆勢（逆勢）：價格逆大勢向下穿越短均線即逆勢做多（由 NEW.07_ma_cross_fade 合併）。
- TS.STATE 追蹤線方向狀態（順勢）：Supertrend 等棘輪追蹤線方向為多的狀態成立即做多（由 NEW.06_trail_state、NEW.19_trail_state 合併）。
- TS.FADE 追蹤線翻轉反向進場（逆勢）：追蹤線轉空翻轉當根反向做多（由 NEW.06_ts_flip_fade 合併）。
- OSC.SLOPE 振盪器斜率方向狀態：振盪器現值高於前值的狀態即做多（由 NEW.07_osc_slope 合併）。
- BRK.KEYBAR 事件棒衍生價位突破（順勢）：收盤價越過由特徵 K 棒（放量反向棒、動能突破棒）衍生並延續的價位即同向進場（由 NEW.00_keybar_break、NEW.13_impulse_level_break 合併）。
- BRK.SQZON 壓縮開始雙通道邊界交叉：肯特納上軌上穿布林上軌（壓縮開始）即做多（由 NEW.17_squeeze_onset 合併）。
- REV.OVERSHOOT 離散價位越界幅度逆勢：價格越過離散基準價位達偏移幅度當下即逆勢進場（由 NEW.02_level_fade、NEW.07_spike_fade 合併）。
- DIV.HID 隱藏背離（順勢）：價格低點較高而振盪器低點較低即順勢做多（由 NEW.08_div_hidden、NEW.10_div_hidden 合併）。
- SW.TLBRK 擺動點連線趨勢線突破（順勢）：收盤價突破兩個確認擺動點連線延伸的斜向趨勢線即同向進場（由 NEW.03_trendline_brk、NEW.04_trendline_brk、NEW.19_trendline_break 合併）。
- PB.BAR 順勢中逆向 K 棒進場：參考線斜率向上時出現收陰 K 棒即做多（由 NEW.11_counter_bar_trend 合併）。
- CNT.EXHAUST 連續同向計數耗竭（逆勢）：收盤相對前值（或 N 根前）連續同向根數達門檻即逆勢進場（由 NEW.03_streak_rev、NEW.13_seq_count、NEW.14_seq_exhaust 合併）。
- CNT.STREAK 連續同向計數延續（順勢）：連續上漲根數（或 tick 數）達門檻即順勢做多（由 NEW.14_streak 合併）。
- PM.PYRAMID 順勢間距加碼：持倉後價格順向達間距即同向加碼（由 NEW.00_pyramid、NEW.02_pyramid、NEW.10_pyramid、NEW.15_pyramid、NEW.19_pyramid 合併）。
- PM.GRID 價格網格：價格穿越等距離散網格價位（或階梯移動）即進場（由 NEW.16_grid_level、NEW.03_price_ladder 合併）。
- PM.TIER 分級目標權重調倉：依順勢位置量化目標權重，升階加倉、降階減倉（由 NEW.12_tier_weight 合併）。
- PM.SLREV 停損後反手：持倉停損觸發後反向進場（由 NEW.09_stop_reverse、NEW.10_stop_reverse、NEW.15_sl_reverse 合併）。
- VOL.CLIMAX 爆量逆趨勢（逆勢）：下跌趨勢中成交量達極端即逆勢做多（由 NEW.03_vol_climax 合併）。
- VOL.SURGE 無號放量異動狀態：成交量高於均量倍數（可附價格變動幅度）的狀態即做多（由 NEW.08_relvol_state、NEW.06_abs_move_spike 合併）。
- VOL.LEVEL 成交量相對均量定向：成交量低於均量做多、高於均量做空（由 NEW.12_vol_vs_avg 合併）。
- VOL.ABSORB 流量耗竭吸收後突破起始棒（逆勢）：帶符號流量持續極端而價格守住起始棒，再突破起始棒即逆勢進場（由 NEW.08_absorption_break 合併）。
- ML.KNN 近鄰分類標籤翻轉：最近鄰距離加權分類結果轉為多頭即做多（由 NEW.04_knn_flip、NEW.07_knn_flip 合併）。
- NUL.ALWAYS 恆真進場：進場條件恆真，無判斷結構（由 NEW.03_always 合併）。
- NUL.RANDOM 偽隨機觸發：偽隨機序列值低於當根最低價即做多（由 NEW.17_random_draw 合併）。
- NUL.NOENTRY 僅出場無進場：檔案只有出場規則，無進場條件（由 NEW.19_exit_only 合併）。
