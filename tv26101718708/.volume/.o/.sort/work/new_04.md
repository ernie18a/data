## NEW.04_trendline_brk 趨勢線突破（順勢）
- 構成方式：連接擺動點畫出斜向趨勢線並向後延伸 → 做多：價格向上突破下降趨勢線 → 做空：對稱，跌破上升趨勢線。
- 與最近既有葉的判別：SW.BOS 的參考是水平的確認擺動點價位，BRK.CHAN 的參考是逐根滾動的統計通道；這裡的參考是用兩個以上擺動點外推出來的斜線。
- 成員：diy_custom_strategy_builder_zp_v1_strategy_8z6wbyw5.48c7f442aa91.md#5

## NEW.04_knn_flip kNN 趨勢分類翻轉（順勢）
- 構成方式：用均線相對位置當歷史標籤，依特徵距離取最近鄰居做距離倒數加權分類 → 做多：分類結果轉為全多頭 → 做空：對稱，轉為全空頭。
- 與最近既有葉的判別：MA.CROSS 和 MA.STATE 直接比較兩條線；這裡觸發的是近鄰分類器輸出的狀態轉換。標籤雖然來自均線關係，分類結果卻要經過鄰居加權，與當根均線關係不等價。
- 成員：multitf_ai_supertrend_with_adx_strategy_presenttrading_feoube91.215a4dd54e42.md#1
