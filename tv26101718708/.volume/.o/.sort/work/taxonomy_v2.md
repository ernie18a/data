# 分類體系 v2（依 sample_0、sample_1 歸納）

歸群單位為第二層葉節點。濾網（F.）與出場（X.）標籤只描述小異，不作為分群依據。
一份檔案含多套獨立進場邏輯時拆開，分別列入對應葉節點（樣本欄以「檔名#段落說明」標示）。同一進場條件內以「或」並列的不同觸發路徑亦視為獨立邏輯拆開。
部位管理本身為核心（DCA、網格）時，進場觸發與部位管理分別列入對應葉節點。

---

## MA 均線／序列關係（順勢）

### MA.CROSS 兩線交叉
- 構成方式：計算快線與慢線（價格本身、各類移動平均、VWAP、平滑後價格如線性回歸值皆可擔任）→ 做多：快線由下向上穿越慢線的事件 → 做空：對稱，由上向下穿越。
- 判別：觸發是「穿越事件」且兩線均在價格單位、慢線為平均類；兩線皆為振盪器值（如 MACD 與訊號線）歸 OSC.SIG；只要求位置或排列狀態而無穿越事件歸 MA.STATE；慢線為單向推進的追蹤停損線（Supertrend、PSAR）歸 TS.FLIP；慢線為通道邊界歸 BRK.CHAN。
- 樣本：quantnomad_evwma_cross_strategy_yrdwiw44、aggregate_btc_volume_ema_strat_zat6a1qs、confluence_engine_strategy_joat_4w7xgwip、code_a_terminal_core_x5m5zevx#EMA 交叉路徑、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#趨勢模式上穿錨定 VWAP、3strategy_auto_switch_range_trend_breakout_mol1swle#趨勢模式、quantumforextradersniperfusionstrategyv2_oq1ju4ha#EMA 交叉路徑

### MA.STATE 價格／均線位置與排列狀態
- 構成方式：計算一條或多條均線（可為較高週期）→ 做多：價格位於均線之上，或快>中>慢且價格位於快線之上的「狀態」成立即進場（空倉時）→ 做空：對稱。
- 判別：無穿越事件，只看當下位置或排列狀態；有穿越事件歸 MA.CROSS。單線位置與多線排列同屬順序關係狀態，不分葉。
- 樣本：triple_ema_rsi_atr_heruurt5、multipletimeframestrategyjiahejuzhen_6clgb3x4#高週期收盤價在 EMA 上方

---

## TS 追蹤線翻轉（順勢）

### TS.FLIP 追蹤停損線方向翻轉
- 構成方式：計算只隨方向單向推進、方向切換時跳至對側的追蹤線（Supertrend、拋物線 SAR、HalfTrend、Chandelier 等）→ 做多：方向由空翻多（收盤價穿越追蹤線）→ 做空：對稱，由多翻空。
- 判別：參考線具棘輪性質（只朝持倉方向移動）；參考線為一般平均類歸 MA.CROSS；參考線為滾動通道邊界歸 BRK.CHAN。
- 樣本：high_activity_penny_stock_strategy_v6_nfihxkxr

---

## OSC 振盪器／動能訊號

### OSC.ZERO 振盪器穿越零軸／中線
- 構成方式：計算振盪器（動能、導數、RSI 類）→ 做多：振盪器由負轉正（或由下穿越中線）→ 做空：對稱，由正轉負。
- 判別：參考線是固定零軸或中線；參考線是振盪器自身平滑線歸 OSC.SIG；看斜率轉折而非符號歸 OSC.TURN；只要求處於超買超賣區歸 REV.EXTREME。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#零軸模式

### OSC.SIG 振盪器穿越其訊號線
- 構成方式：計算振盪器與其平滑訊號線 → 做多：振盪器由下向上穿越訊號線（可要求穿越時位於負區或超賣區）→ 做空：對稱。
- 判別：兩線都在振盪器值域；兩線在價格單位歸 MA.CROSS。要求穿越時位於極端區屬附加濾網（F.rsi_band），不分葉。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#訊號線模式、code_a_terminal_core_x5m5zevx#波動波線穿越訊號線路徑、haeri_network_qvstezum#CCI／RSI 穿越其 EMA 轉折路徑

### OSC.TURN 振盪器斜率轉折
- 構成方式：計算振盪器 → 做多：前值處於負區且為局部低點（前值低於其前值、現值高於前值）→ 做空：對稱，正區局部高點後轉下。
- 判別：觸發為振盪器方向反轉（局部極值），不要求穿越任何參考線。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#轉折模式

---

## BRK 突破（順勢）

### BRK.CHAN 滾動通道突破
- 構成方式：計算滾動通道邊界（回看最高／最低含僅前一根高低、布林帶、肯特納通道、VWAP 標準差帶、多條均線的最大／最小值等）→ 做多：收盤價（或最高價觸及）突破上界 → 做空：對稱，跌破下界；可只做多。
- 判別：邊界為逐根滾動的統計通道；邊界為固定時段區間歸 BRK.ORB；邊界為確認擺動點歸 SW.BOS；需先有壓縮狀態再以動能定方向的狀態轉換歸 BRK.SQZ（僅以壓縮作前提再突破邊界者仍歸本葉，壓縮記 F.squeeze）。以「回看期最近創高晚於最近創低」定方向（Aroon 型）等同回看極值突破後的停留狀態，歸本葉。
- 樣本：keltner_channel_trend_based_strategy_ezsbm5ms、super_breakout_day_trading_scnniaco、gold_breakout_strategy_rr_4_lpo7kcs9、channelbreakoutstrategyv21_0ikdxjnd、multipletimeframestrategyjiahejuzhen_6clgb3x4#均線帶壓縮後站上全部 EMA、multipletimeframestrategyjiahejuzhen_6clgb3x4#平倉後突破布林上軌再進場、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#趨勢模式上穿上軌帶、3strategy_auto_switch_range_trend_breakout_mol1swle#突破模式、golden_trident_swinganchored_vwap_trend_system_eq4kprrj、smb_magic_b85od95c

### BRK.ORB 固定時段區間突破
- 構成方式：計算特定時段（開盤首根、首段區間、盤前、前一日、亞洲盤）的高低點並在當日固定 → 做多：收盤價上穿區間高點（可加緩衝）→ 做空：對稱，下穿區間低點。
- 判別：參考價位在時段結束後固定不再滾動；越界後收回反向進場歸 LQ.SWEEP；觸及但未越界即反向歸 SR.TOUCH。
- 樣本：thinktech_ai_signals_xjjyblba#首根日線區間突破、ai_mes_asian_session_strategy_hr3tvgbs#突破路徑

### BRK.SQZ 波動壓縮釋放
- 構成方式：計算內通道（布林帶）與外通道（肯特納通道）判定壓縮開啟／解除，另算動能值 → 做多：前一根壓縮開啟、當根壓縮解除且動能為正 → 做空：對稱，動能為負。
- 判別：觸發是壓縮狀態轉換，方向由動能符號決定，不要求價格穿越通道邊界；直接穿越邊界歸 BRK.CHAN。
- 樣本：squeeze_momentum_strategy_g9yz2qif

---

## REV 通道／振盪器回歸（逆勢）

### REV.EXTREME 超買超賣區狀態
- 構成方式：計算振盪器（RSI、隨機、MFI、威廉、CCI 等，可多個同時）或滾動通道 → 做多：振盪器低於超賣線，或價格位於（接近）通道下界之下的狀態成立（或剛向下穿越下界）即進場 → 做空：對稱，超買或位於上界之上。
- 判別：處於極端區當下即逆勢進場，不等待反轉事件。價格相對通道位置與振盪器同為標準化偏離（如 %B），不分葉。需先越界再收回歸 REV.REENTRY；極端區內振盪器穿越訊號線歸 OSC.SIG；順勢突破歸 BRK.CHAN。
- 樣本：strategyrsmarxbabu_4_oscillators_v0_21jneuwf、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#均值回歸模式位於或下穿下軌帶、3strategy_auto_switch_range_trend_breakout_mol1swle#震盪模式

### REV.REENTRY 越界後回到通道內
- 構成方式：計算滾動通道邊界（布林帶、VWAP 標準差帶、回看最高／最低等）→ 做多：前一根收在下界之下（或創回看新低、或當根最低價刺穿下界），當根收回下界之上（可要求回升超過 ATR 門檻）→ 做空：對稱，上界越界後收回。
- 判別：邊界為滾動統計通道且方向為逆勢、需有收回事件；邊界為固定時段價位或確認擺動點歸 LQ.SWEEP；仍在界外即進場歸 REV.EXTREME；順勢穿越歸 BRK.CHAN。
- 樣本：bollinger_bounce_reversal_strategy_visual_edition_30vzsmvl、thinktech_ai_signals_xjjyblba#回看極值反彈、vwap_suite_trend_mean_reversion_with_adaptive_filters_l7p3quuz#均值回歸模式刺穿後收回

---

## DIV 背離（逆勢）

### DIV.REG 常規背離
- 構成方式：比較兩個回看窗口（或兩個確認擺動點）中價格極值與振盪器極值 → 做多：價格低點更低而振盪器低點更高 → 做空：對稱，價格高點更高而振盪器高點更低。
- 判別：觸發來自價格與振盪器極值方向不一致；僅看振盪器本身轉折歸 OSC.TURN；背離只作另一觸發的前提時記 F.divergence，不歸本葉。
- 樣本：reversal_trading_bot_strategybullbyte_cxvnf1wh

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

---

## LQ 流動性掃蕩（逆勢）

### LQ.SWEEP 關鍵價位掃蕩後收回
- 構成方式：計算離散關鍵價位（前日／前時段／時段初始區間高低、未破壞的確認擺動點）→ 做多：價格先跌破低位（可要求至少 ATR 緩衝）或前一根收在低位之下，並在允許時窗內收回低位之上（常再以 BOS、吞噬或均線穿越確認）→ 做空：對稱，刺穿高位後收回其下。
- 判別：參考價位為離散固定價位且須先越界；滾動統計通道越界收回歸 REV.REENTRY；觸及而未越界即反向歸 SR.TOUCH。
- 樣本：13_ema_breakout_liquidity_sweep_bos_confirmation_a_a_iueqdndd#掃蕩路徑、liquidity_sweep_tracker_smart_money_stop_hunts_on7jauut、ai_mes_asian_session_strategy_hr3tvgbs#均值回歸路徑

---

## SR 支撐阻力觸及（逆勢）

### SR.TOUCH 固定價位區觸及反轉
- 構成方式：計算離散固定價位（前一日高低、自適應擴大的多日區間高低）及其周圍觸及區 → 做多：當根低點落入支撐觸及區但仍高於區間下界 → 做空：對稱，高點落入阻力觸及區但低於上界。
- 判別：觸發是價格進入價位區而未越界；須先越界再收回歸 LQ.SWEEP；觸發是擺動點本身被確認歸 SW.PIVOT。
- 樣本：adaptive_sr_reversal_rsi_divergence_dca_be_stop_5m_pfdze7mb#初始進場

---

## PAT K 棒形態

### PAT.BAR 單／雙根 K 棒形態
- 構成方式：比較當根與前一根的開高低收 → 做多：形成指定形態（外包線：高點高於前高且低點低於前低）且當根收陽 → 做空：對稱，形態成立且收陰（或以形態自身方向定義，如看跌外包）。
- 判別：觸發只來自少數 K 棒的相對高低與實體方向；以前一根高低為邊界的收盤突破歸 BRK.CHAN；吞噬等形態只作確認時記 F.confirm_bar。
- 樣本：advanced_outside_with_hma_and_klinger_forex_swing_strategy_v5vo0vnc

---

## CMP 多指標合成

### CMP.SCORE 加權計分門檻
- 構成方式：將多項指標條件（均線位置、振盪器方向、背離、追蹤線方向、成交量、高週期等）依權重加總為多、空方向分數 → 做多：多方分數達門檻（可要求領先空方達差額、或方向狀態由非多轉多）→ 做空：對稱。
- 判別：分數本身即觸發，無單一主導結構；分數只作另一觸發的前提時記 F.score，不歸本葉。
- 樣本：quantumforextradersniperfusionstrategyv2_oq1ju4ha#計分路徑、haeri_network_qvstezum#方向分數路徑

---

## PM 部位管理核心

### PM.DCA 逆向間距加碼
- 構成方式：已有持倉且未達加碼上限 → 做多加碼：價格自最差進場價逆向達間距比例即再進場 → 做空：對稱；目標與停損改以首次進場價或最差進場價偏移計算。
- 判別：加碼由不利價格移動觸發；順勢加碼或固定價格網格另議。初始進場另歸其觸發所屬葉節點。
- 樣本：adaptive_sr_reversal_rsi_divergence_dca_be_stop_5m_pfdze7mb#加碼

---

## 濾網標籤

- F.trend_ma：價格或快線相對長期均線、VWAP（或兩均線相對位置）決定可做方向。
- F.ma_stack：多條均線依序排列才可進場。
- F.slope：均線、VWAP 或通道邊界的斜率方向需與進場方向一致（含 Hull 均線由降轉升）。
- F.htf：較高週期指標條件須同向，或價位須鄰近較高週期擺動點。
- F.adx_di：ADX 高於門檻（趨勢）或低於門檻（盤整），及／或 +DI、−DI 相對大小同向；可用於模式切換。
- F.osc_dir：輔助振盪器方向同向（如 MACD 高於訊號線、動能線高於其平滑線、量能加權值符號、Klinger、資金流符號）。
- F.osc_cross：輔助振盪器發生同向交叉作確認（如短期 RSI 上穿長期 RSI、RSI 自超賣上穿）。
- F.rsi_band：振盪器須位於指定區間（未超買／未超賣、偏離中點、超賣才做多、訊號線位於負區等）。
- F.divergence：須於有效回看期內出現同向常規背離。
- F.trail_side：價格須位於拋物線 SAR、Supertrend 等追蹤線的同向側。
- F.volume：成交量高於均量、前一根成交量或其倍數，或高於最低門檻。
- F.volatility：ATR、帶寬或回看高低範圍高於門檻（絕對、相對收盤價或相對其長期均值的倍數）。
- F.range_width：參考區間（如開盤區間）幅度須介於下限與上限之間。
- F.squeeze：須處於壓縮狀態（如多條均線纏繞範圍小於布林帶寬）。
- F.band_pos：價格須位於某通道內特定位置（如中軌之上、下軌之下）。
- F.key_level：價格須在指定關鍵價位之上／下（如盤前高點）。
- F.fvg：價格須位於同向公平價值缺口內。
- F.extension：近期漲跌幅或連續同向根數不超過上限，或價格距均值不超過 ATR 倍數，避免追高殺低。
- F.candle_dir：進場 K 棒須為同向實體，或開收高於（低於）前一根、創高（創低）。
- F.confirm_bar：須出現確認 K 棒（吞噬、實體達 ATR 位移、收盤突破訊號 K 棒高低點）。
- F.pattern：須先出現指定價格形態（雙底、區間收斂、高低點收斂）。
- F.retest：須回測突破位或均線後再進場。
- F.score：多項條件加權分數須高於門檻。
- F.min_rr：預期目標距離除以停損距離須達報酬風險比門檻。
- F.session：僅在指定交易時段或進場截止時點前進場。
- F.date：僅在指定年份、日期或回測區間內交易。
- F.daily_limit：當日（或當時段）交易次數或回撤未達上限。
- F.cooldown：距上次出場或進場須經過指定根數。
- F.rearm：同向訊號須在條件先失效後才可再觸發，或須較上次同向訊號價推進 ATR 距離。
- F.flat：須空倉或每段僅允許一次進場。
- F.confirm：須等 K 棒收定或暖機完成。

## 出場標籤

- X.stop_pct：進場價固定百分比（或固定距離）停損。
- X.tp_pct：進場價固定百分比（或固定距離）停利。
- X.stop_atr：進場價減（加）ATR 倍數停損（可乘波動比並以最大距離封頂）。
- X.tp_atr：進場價加（減）ATR 倍數停利。
- X.tp_rr：以初始風險距離乘風險報酬比設定停利。
- X.tp_multi：多段停利目標、逐級推進的獲利限價或分批減倉。
- X.stop_bar：以訊號 K 棒高低點為停損。
- X.stop_swing：以最近確認擺動點或近期極值加緩衝為停損。
- X.stop_level：以區間、掃蕩極值、通道帶線或關鍵價位對側（加緩衝）為停損。
- X.tp_level：以相反側流動性位、未填補缺口中點、外層帶線或區間寬度投影為停利。
- X.tp_mid：以通道中軸、區間中點或 VWAP 為回歸停利。
- X.trailing_atr：以收盤價（或極值）減（加）ATR 或波動幅度倍數逐根推進的移動停損。
- X.trailing_swing：移動停損至進場後最新反向擺動點加緩衝。
- X.trailing_pct：啟動後自持倉期間最高（最低）收盤回撤達百分比出場。
- X.trailing_ma：價格跌破（升破）均線即出場。
- X.trailing_step：依獲利比率分段收緊的移動停損。
- X.breakeven：達到指定獲利（百分比或 ATR 倍數）後停損移至進場價或其偏移。
- X.band_opposite：收盤價穿越通道對側或反向邊界出場。
- X.trend_flip：趨勢均線關係或追蹤線方向反轉出場。
- X.structure_break：出現反向擺動結構突破出場。
- X.reverse_signal：出現反向進場訊號（或反向弱訊號）出場。
- X.osc_cross：輔助振盪器反向交叉出場（如隨機 RSI K 線低於 D 線）。
- X.momentum_fade：動能值歸零、不再擴張或低於出場門檻出場。
- X.indicator_cap：指標超過過熱上限或自超買（超賣）區回落出場。
- X.volume_spike：成交量暴增超過均量倍數出場。
- X.sar：價格跌破拋物線轉向指標出場。
- X.candle_reversal：出現反向 K 棒或吞噬形態（可附加獲利未達門檻）時出場。
- X.min_hold：出場訊號須持倉達最短根數才生效。
- X.time：持倉根數達上限出場（可附加未獲利、未出現有利結構突破條件）。
- X.session_end：時段結束平倉（可依獲利條件延後一次）。

---

## v1→v2 變更

- 新增核心族 TS 及葉 TS.FLIP：Supertrend 方向翻轉類樣本無法放入 MA.CROSS（參考線為棘輪追蹤線而非平均類）。
- 新增葉 REV.EXTREME：振盪器同時處於超買超賣區、價格位於通道外即逆勢進場，不等待收回事件，與 REV.REENTRY 觸發結構不同；振盪器極端與價格相對通道位置視為同構，合併於此葉。
- 新增核心族 SR 及葉 SR.TOUCH：前日區間價位觸及而未越界即反轉，與 LQ.SWEEP（須越界後收回）及 SW.PIVOT（樞紐確認）區分。
- 新增核心族 PAT 及葉 PAT.BAR：外包線等 K 棒形態本身即觸發。
- 新增核心族 CMP 及葉 CMP.SCORE：加權計分本身即觸發的策略，與作為濾網的 F.score 區分。
- 新增核心族 PM 及葉 PM.DCA：依原則將 DCA 逆向加碼納入分群依據，初始進場與加碼分列。
- 擴充並更名 MA.STACK → MA.STATE：單線價格位置狀態與多線排列狀態同屬順序關係狀態，合併為一葉。
- 擴充 BRK.CHAN 邊界：納入前一根高低、VWAP 標準差帶、均線帶最大最小值；明定 Aroon 型「最近創高晚於創低」定方向歸本葉；明定僅以壓縮為前提的邊界突破仍歸本葉，與 BRK.SQZ 邊界釐清。
- 擴充 MA.CROSS 慢線納入 VWAP，並在判別中與 TS.FLIP、BRK.CHAN 劃界。
- 擴充 OSC.SIG：容許穿越時位於極端區，極端區要求視為 F.rsi_band 濾網。
- 擴充 REV.REENTRY、LQ.SWEEP 的越界定義（當根刺穿、前一根收在界外），並補充與 REV.EXTREME、SR.TOUCH 的判別。
- 擴充 DIV.REG 判別：背離僅作前提時記 F.divergence。
- 新增規則：同一進場條件內以「或」並列的不同觸發路徑拆開分別歸群；部位管理為核心時進場與管理分列。
- 新增濾網標籤：F.divergence、F.trail_side、F.range_width、F.squeeze、F.fvg、F.confirm_bar、F.min_rr、F.rearm。
- 擴充濾網標籤定義：F.trend_ma、F.slope、F.htf、F.adx_di、F.osc_dir、F.osc_cross、F.rsi_band、F.volume、F.volatility、F.extension、F.candle_dir、F.session、F.date、F.daily_limit、F.cooldown。
- 新增出場標籤：X.tp_mid、X.trailing_swing、X.trailing_pct、X.structure_break、X.osc_cross、X.min_hold。
- 擴充出場標籤定義：X.stop_pct、X.tp_pct、X.stop_atr、X.tp_multi、X.stop_swing、X.stop_level、X.tp_level、X.trailing_atr、X.breakeven、X.trend_flip、X.reverse_signal、X.momentum_fade、X.indicator_cap、X.candle_reversal、X.time、X.session_end。
