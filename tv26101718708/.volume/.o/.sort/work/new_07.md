## NEW.07_knn_flip KNN 分類標籤翻轉

- 構成方式：計算追蹤線（SuperTrend）值作樣本，樣本標籤為加權收盤均線高於加權追蹤線均線 → 依當前值與樣本距離選最近鄰並以距離倒數加權標籤得分類 → 做多：分類由非 1 轉為 1 → 做空：對稱，分類由非 0 轉為 0。
- 與最近既有葉的判別：TS.FLIP 以追蹤線本身方向翻轉為觸發；MA.CROSS 以兩線實際穿越為觸發；本葉觸發是最近鄰分類器的預測標籤切換，不直接比較當根價格與參考線。
- 成員：ai_supertrend_strategy_presenttrading_eatiyety.5756766d6934.md#1

## NEW.07_ma_cross_fade 均線下穿逆勢做多

- 構成方式：計算短、中、長期 SMA 與 EMA → 做多：收盤價位於長期 SMA 之下，且由前一根高於短期 SMA 轉為當根不高於短期 SMA（向下穿越）即逆勢買進 → 本例只做多。
- 與最近既有葉的判別：MA.CROSS 為順勢（上穿做多）；REV.REENTRY 與 REV.EXTREME 的參考為通道邊界或振盪器門檻；本葉以價格向下穿越平均線本身作逆勢進場事件。
- 成員：free_strategy_08_combo_of_01_and_02_es_spy_fe0nxce4.20dd88448b9f.md#1

## NEW.07_osc_slope 振盪器斜率方向狀態

- 構成方式：計算振盪器（短長 EMA 差即 MACD 線）→ 做多：振盪器現值高於前一根值的狀態 → 做空：現值不高於前一根值。
- 與最近既有葉的判別：OSC.TURN 要求負區局部低點後轉上的極值確認；OSC.LEVEL 看數值相對固定門檻；本葉只看振盪器逐根斜率符號，無區域與極值要求（作為濾網時即 F.osc_dir）。
- 成員：macd_rsi_ema_sma_ichimoku_overbought_buy_sell_doji_dnjh5qa9.e4f92b41ee99.md#5

## NEW.07_spike_fade 放量反應棒外側限價逆勢

- 構成方式：辨識回看期內唯一的放量且區間相對放大的反應棒 → 以反應棒高低點外加區間比例偏移設限價、停損、目標 → 做多：最低價跌至反應低點減區間比例的限價即買進 → 做空：對稱，最高價升至反應高點加區間比例。
- 與最近既有葉的判別：REV.EXTREME 的參考為逐根滾動的統計通道或振盪器極端區；LQ.SWEEP 需越界後收回；SR.TOUCH 需觸及而未越界；本葉參考價位由單一放量事件棒定義，越過其外側偏移即以限價逆勢進場，不需收回。
- 成員：obs_volume_spike_reaction_fade_nq_fmpc9fwd.769fdac1a43c.md#1
