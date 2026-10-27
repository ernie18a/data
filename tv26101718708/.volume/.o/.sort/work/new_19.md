## NEW.19_trail_state 追蹤線方向狀態（順勢）
- 構成方式：計算 Supertrend 等只隨方向單向推進、方向切換時跳至對側的追蹤線 → 做多：追蹤線方向為多（價格位於追蹤線之上）的狀態成立即進場 → 做空：對稱，方向為空。
- 與最近既有葉的判別：TS.FLIP 要求方向翻轉的當根事件，本葉只看持續成立的方向狀態；MA.STATE 的參考線為一般平均類，本葉參考線具棘輪性質；追蹤線方向只作其他觸發的濾網時記 F.trail_side，不歸本葉。
- 成員：ai_supertrend_x_pivot_percentile_strategy_presenttrading_ec3qaynq.5b8495300c9e.md#1、btc_v67_total_control_screener_klkroe7c.c90b40cf7cf5.md#4、supertrend_hombrok_bot_lzzgoo0d.5a404decd73a.md#1、trend_flow_strategy_z4kcougt.5f02790afa49.md#10

## NEW.19_pyramid 順勢獲利加碼
- 構成方式：已有持倉且未達加碼上限 → 做多加碼：收盤價相對持倉均價的漲幅超過門檻（並位於趨勢均線之上）即再進場 → 做空：對稱（本批成員只做多）。
- 與最近既有葉的判別：PM.DCA 由不利價格移動觸發加碼，本葉由有利價格移動觸發；初始進場另歸其觸發所屬葉節點。
- 成員：big_trend_catcher_dualgate_ema_atr_trailing_swing_trader_5lobhpnz.19aafd4da3b7.md#3

## NEW.19_trendline_break 樞紐連線趨勢線突破（順勢）
- 構成方式：以兩個依序較低（較高）的確認樞紐高（低）點連成下降阻力線（上升支撐線），並依兩點斜率延伸至當根 → 做多：收盤價突破下降阻力線加 ATR 緩衝（線未失效、未過期、未觸發過）→ 做空：對稱，跌破上升支撐線減 ATR 緩衝。
- 與最近既有葉的判別：SW.BOS 的參考價位是單一擺動點的水平價位，本葉參考線為兩樞紐連線延伸的斜線；BRK.CHAN 的邊界為逐根滾動統計通道，本葉為由離散樞紐推導的幾何線。
- 成員：trendbreaker_pro_auto_trendline_break_strategy_with_momentum_2u7kkccg.a11dee46be65.md#1

## NEW.19_exit_only 僅出場規則
- 構成方式：檔案只有出場規則，無任何進場條件；出場由獲利門檻後跌破短均線、百分比止損、災難止損、最大止盈與分級鎖利上移止損構成。
- 與最近既有葉的判別：所有既有葉皆以進場觸發定義，本檔缺進場規則無法歸入；出場內容記為 X. 標籤。
- 成員：forex_apex_matrix_v5_hmm_stationarity_core_poxbawem.2ed497e86ff0.md#1
