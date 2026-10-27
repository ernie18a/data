## NEW.10_stop_reverse 停損後反向翻倉
- 構成方式：已有持倉觸及停損 → 排定反向翻倉，等待期結束且未處於回撤停交易狀態即反向進場 → 多空對稱；翻倉單另設時間停損。
- 與最近既有葉的判別：與 PM.DCA 同屬部位管理核心，但 PM.DCA 為逆向同向加碼，本葉為停損事件觸發的反向進場；初始進場另歸其觸發葉（本例 PAT.BAR）。
- 成員：btc_mtf_engulfing_flip_strategy_1h_2x_xgqszuxj.71e5e70a2fce.md#2

## NEW.10_div_hidden 隱藏背離（順勢）
- 構成方式：以振盪器樞紐低點比較相鄰兩個樞紐 → 做多：價格低點高於前低點而振盪器低點低於前低點 → 做空：對稱，價格高點更低而振盪器高點更高。
- 與最近既有葉的判別：DIV.REG 為價格更低而振盪器更高的逆勢背離；本葉價格與振盪器極值不一致的方向相反，屬順勢延續解讀。
- 成員：rsi_overbought_oversold_divergence_strategy_w_buysell_signals_d92hvfqx.843525398873.md#2

## NEW.10_pyramid 順勢距離加碼
- 構成方式：已有持倉 → 價格自進場價順向達加碼觸發距離即同向加碼 → 加碼後停損移至進場價；多空對稱。
- 與最近既有葉的判別：PM.DCA 由不利價格移動觸發加碼；本葉由有利價格移動觸發，方向相反；初始進場另歸其觸發葉（本例 BRK.CHAN）。
- 成員：v3_valentini_pro_scalper_dashboard_3yqoiuyr.b971708b20e4.md#2
