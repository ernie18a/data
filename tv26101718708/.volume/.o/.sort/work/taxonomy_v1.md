# 分類體系 v1（依 sample_0 歸納）

歸群單位為第二層葉節點。濾網（F.）與出場（X.）標籤只描述小異，不作為分群依據。
一份檔案含多套獨立進場邏輯時拆開，分別列入對應葉節點（樣本欄以「檔名#段落說明」標示）。

---

## MA 均線／序列關係（順勢）

### MA.CROSS 兩線交叉
- 構成方式：計算快線與慢線（價格本身、各類移動平均、平滑後價格如線性回歸值皆可擔任快線）→ 做多：快線由下向上穿越慢線的事件 → 做空：對稱，由上向下穿越。
- 判別：觸發是「穿越事件」且兩線均在價格單位；兩線皆為振盪器值（如 MACD 與訊號線）歸 OSC.SIG；只要求多條線排列狀態而無穿越事件歸 MA.STACK。
- 樣本：quantnomad_evwma_cross_strategy_yrdwiw44、aggregate_btc_volume_ema_strat_zat6a1qs、confluence_engine_strategy_joat_4w7xgwip

### MA.STACK 多線排列狀態
- 構成方式：計算快、中、慢多條均線 → 做多：快>中>慢 且價格位於快線之上的「狀態」成立即進場（空倉時）→ 做空：對稱，排列反向且價格位於快線之下。
- 判別：無穿越事件，只看當下排列狀態；有穿越事件歸 MA.CROSS。
- 樣本：triple_ema_rsi_atr_heruurt5

---

## OSC 振盪器／動能訊號

### OSC.ZERO 振盪器穿越零軸／中線
- 構成方式：計算振盪器（動能、導數、RSI 類）→ 做多：振盪器由負轉正（或由下穿越中線）→ 做空：對稱，由正轉負。
- 判別：參考線是固定零軸或中線；參考線是振盪器自身平滑線歸 OSC.SIG；看斜率轉折而非符號歸 OSC.TURN。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#零軸模式

### OSC.SIG 振盪器穿越其訊號線
- 構成方式：計算振盪器與其平滑訊號線 → 做多：振盪器由下向上穿越訊號線 → 做空：對稱。
- 判別：兩線都在振盪器值域；兩線在價格單位歸 MA.CROSS。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#訊號線模式

### OSC.TURN 振盪器斜率轉折
- 構成方式：計算振盪器 → 做多：前值處於負區且為局部低點（前值低於其前值、現值高於前值）→ 做空：對稱，正區局部高點後轉下。
- 判別：觸發為振盪器方向反轉（局部極值），不要求穿越任何參考線。
- 樣本：deltarsi_strategy_with_filters_0odcms2t#轉折模式

---

## BRK 突破（順勢）

### BRK.CHAN 滾動通道突破
- 構成方式：計算滾動通道邊界（回看最高／最低、布林帶、肯特納通道等）→ 做多：收盤價（或最高價觸及）突破上界 → 做空：對稱，跌破下界；可只做多。
- 判別：邊界為逐根滾動的統計通道；邊界為固定時段區間歸 BRK.ORB；邊界為確認擺動點歸 SW.BOS；需先有壓縮狀態再釋放歸 BRK.SQZ。
- 樣本：keltner_channel_trend_based_strategy_ezsbm5ms、super_breakout_day_trading_scnniaco、gold_breakout_strategy_rr_4_lpo7kcs9、channelbreakoutstrategyv21_0ikdxjnd

### BRK.ORB 固定時段區間突破
- 構成方式：計算特定時段（開盤首根、首段區間、盤前、前一日）的高低點並在當日固定 → 做多：收盤價上穿區間高點 → 做空：對稱，下穿區間低點。
- 判別：參考價位在時段結束後固定不再滾動；越界後收回反向進場歸 LQ.SWEEP。
- 樣本：thinktech_ai_signals_xjjyblba#首根日線區間突破

### BRK.SQZ 波動壓縮釋放
- 構成方式：計算內通道（布林帶）與外通道（肯特納通道）判定壓縮開啟／解除，另算動能值 → 做多：前一根壓縮開啟、當根壓縮解除且動能為正 → 做空：對稱，動能為負。
- 判別：觸發是壓縮狀態轉換，方向由動能符號決定，不要求價格穿越通道邊界；直接穿越邊界歸 BRK.CHAN。
- 樣本：squeeze_momentum_strategy_g9yz2qif

---

## REV 通道回歸（逆勢）

### REV.REENTRY 越界後回到通道內
- 構成方式：計算滾動通道邊界（布林帶、回看最高／最低等）→ 做多：前一根收在下界之下（或創回看新低），當根收回下界之上（可要求回升超過 ATR 門檻）→ 做空：對稱，上界越界後收回。
- 判別：邊界為滾動統計通道且方向為逆勢；邊界為固定時段價位或確認擺動點歸 LQ.SWEEP；順勢穿越歸 BRK.CHAN。
- 樣本：bollinger_bounce_reversal_strategy_visual_edition_30vzsmvl、thinktech_ai_signals_xjjyblba#回看極值反彈

---

## DIV 背離（逆勢）

### DIV.REG 常規背離
- 構成方式：比較兩個回看窗口中價格極值與振盪器極值 → 做多：價格低點更低而振盪器低點更高 → 做空：對稱，價格高點更高而振盪器高點更低。
- 判別：觸發來自價格與振盪器極值方向不一致；僅看振盪器本身轉折歸 OSC.TURN。
- 樣本：reversal_trading_bot_strategybullbyte_cxvnf1wh

---

## SW 擺動結構

### SW.PIVOT 確認樞紐反轉
- 構成方式：以左右回看確認樞紐高／低點 → 做多：本根確認樞紐低點（並落在以樞紐低點加 ATR 定義的需求區內）即逆勢做多 → 做空：對稱，確認樞紐高點做空。
- 判別：觸發是樞紐點本身被確認（逆勢）；突破樞紐點歸 SW.BOS。
- 樣本：ultimate_prop_firm_artillery_pkupybw7

### SW.BOS 擺動結構突破
- 構成方式：以左右回看確認擺動高低點 → 做多：收盤價向上突破最近確認擺動高點（可要求配合均線穿越的先後次序與時窗）→ 做空：對稱，跌破最近確認擺動低點。
- 判別：參考價位是離散確認擺動點而非滾動通道（後者歸 BRK.CHAN）；先有掃蕩再以 BOS 確認時歸 LQ.SWEEP。
- 樣本：13_ema_breakout_liquidity_sweep_bos_confirmation_a_a_iueqdndd#形態路徑（雙底、區間收斂、高低點收斂後 BOS）

---

## LQ 流動性掃蕩（逆勢）

### LQ.SWEEP 關鍵價位掃蕩後收回
- 構成方式：計算離散關鍵價位（前日／前時段／時段初始區間高低、確認擺動點）→ 做多：價格先跌破低位至少一段距離，並在允許時窗內收回低位之上（常再以 BOS 或均線穿越確認）→ 做空：對稱，刺穿高位後收回其下。
- 判別：參考價位為離散固定價位；滾動統計通道越界收回歸 REV.REENTRY。
- 樣本：13_ema_breakout_liquidity_sweep_bos_confirmation_a_a_iueqdndd#掃蕩路徑

---

## 濾網標籤

- F.trend_ma：價格或快線相對長期均線（或兩均線相對位置）決定可做方向。
- F.ma_stack：多條均線依序排列才可進場。
- F.slope：均線或通道邊界的斜率方向需與進場方向一致。
- F.htf：較高週期指標條件須同向。
- F.adx_di：ADX 高於門檻及／或 +DI、−DI 相對大小同向。
- F.osc_dir：輔助振盪器方向同向（如 MACD 高於訊號線、動能線高於其平滑線、量能加權值符號）。
- F.osc_cross：輔助振盪器發生同向交叉作確認（如短期 RSI 上穿長期 RSI）。
- F.rsi_band：振盪器須位於指定區間（未超買／未超賣、偏離中點、超賣才做多等）。
- F.volume：成交量高於均量或其倍數。
- F.volatility：ATR 或波動度高於其長期均值的倍數。
- F.band_pos：價格須位於某通道內特定位置（如中軌之上、下軌之下）。
- F.key_level：價格須在指定關鍵價位之上／下（如盤前高點）。
- F.extension：近期漲跌幅不超過上限，避免追高殺低。
- F.candle_dir：進場 K 棒須為同向實體（陽線做多、陰線做空）。
- F.pattern：須先出現指定價格形態（雙底、區間收斂、高低點收斂）。
- F.retest：須回測突破位或均線後再進場。
- F.score：多項條件加權分數須高於門檻。
- F.session：僅在指定交易時段進場。
- F.date：僅在指定年份或日期之後交易。
- F.daily_limit：當日交易次數或回撤未達上限。
- F.cooldown：距上次出場須經過指定根數。
- F.flat：須空倉或每段僅允許一次進場。
- F.confirm：須等 K 棒收定或暖機完成。

## 出場標籤

- X.stop_pct：進場價固定百分比停損。
- X.tp_pct：進場價固定百分比停利。
- X.stop_atr：進場價減（加）ATR 倍數停損。
- X.tp_atr：進場價加（減）ATR 倍數停利。
- X.tp_rr：以初始風險距離乘風險報酬比設定停利。
- X.tp_multi：多段停利目標或分批減倉。
- X.stop_bar：以訊號 K 棒高低點為停損。
- X.stop_swing：以最近確認擺動點加緩衝為停損。
- X.stop_level：以區間或關鍵價位對側（加緩衝）為停損。
- X.tp_level：以相反側流動性位或區間寬度投影為停利。
- X.trailing_atr：以收盤價減（加）ATR 倍數逐根推進的移動停損。
- X.trailing_ma：價格跌破（升破）均線即出場。
- X.trailing_step：依獲利比率分段收緊的移動停損。
- X.breakeven：達到指定獲利後停損移至進場價。
- X.band_opposite：收盤價穿越通道對側或反向邊界出場。
- X.trend_flip：趨勢均線關係反轉出場。
- X.reverse_signal：出現反向進場訊號出場。
- X.momentum_fade：動能值歸零或不再擴張出場。
- X.indicator_cap：指標超過過熱上限出場。
- X.volume_spike：成交量暴增超過均量倍數出場。
- X.sar：價格跌破拋物線轉向指標出場。
- X.candle_reversal：出現大幅反向 K 棒且獲利未達門檻時出場。
- X.time：持倉根數達上限出場。
- X.session_end：時段結束平倉。
