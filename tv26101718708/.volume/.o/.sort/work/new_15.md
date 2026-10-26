## NEW.15_pyramid 順勢加碼
- 構成方式：已有持倉且加碼次數（或距初始進場時窗）未達上限 → 做多加碼：價格朝有利方向推進達條件（持倉獲利達分級門檻、價格達進場價加持倉單位數乘 ATR 間距，或持倉期間收盤突破短回看最高價）即同向再進場 → 做空：對稱。初始進場另歸其觸發所屬葉。
- 與最近既有葉的判別：PM.DCA 的加碼由不利價格移動觸發（逆向攤平），本葉由有利移動觸發（順勢金字塔）；持倉期間的突破加碼雖用回看極值，但以既有持倉為構成要件且角色為加碼，不歸 BRK.CHAN。
- 成員：automate_on_hyperliquid_strategy_webhook_template_hyprrun_khbr2h0r.d2a5edd42867.md#4、follow_the_money_v110_8giafrcp.47bd8adfef97.md#2、padayappa_jazexika.a1f9deb95ba6.md#2

## NEW.15_sl_reverse 停損後反手
- 構成方式：前一筆交易因停損出場且目前空倉 → 做多：前一筆做空停損後，收盤價位於最近確認擺動低點之上即反向做多（當日限一次）→ 做空：對稱，前一筆做多停損後收盤低於最近確認擺動高點。
- 與最近既有葉的判別：觸發來自前一筆交易的停損出場事件，而非價格結構本身；X.reverse_signal 是以反向訊號出場，本葉是以停損出場作為反向進場的觸發；擺動點位置只是同側狀態濾網，不構成 SW.BOS 的突破事件。
- 成員：nas100_3min_breakout_reverse_after_sl_vw4m6aca.839fed0f3439.md#2
