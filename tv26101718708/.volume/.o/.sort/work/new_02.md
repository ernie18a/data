## NEW.02_level_fade 離散基準價位越界幅度逆勢進場

- 構成方式：以確認樞紐（可要求放量、其後高低點連續回升）定出離散支撐／壓力基準並沿用最新值（可限最大存續柱數）→ 做多：空倉且收盤價低於支撐基準達設定跌幅即逆勢做多，不等待收回 → 做空：對稱，收盤價高於壓力基準達設定漲幅。
- 與最近既有葉的判別：REV.EXTREME 的邊界為逐根滾動的統計通道或振盪器門檻，本葉為離散固定樞紐價位；LQ.SWEEP 須越界後收回，本葉在界外當下即進場；SR.TOUCH 觸及而未越界，本葉要求越界達幅度。
- 成員：3c_qfl_mean_reversal_sdrm0bby.397d8bae5d15.md#1

## NEW.02_pyramid 順勢獲利加碼

- 構成方式：已有持倉且未達加碼上限 → 做多加碼：收盤價自初始進場價（或持倉均價）順向推進達間距（持有單位數乘 ATR 間距，或漲幅百分比門檻）即再進場 → 做空：對稱。初始進場另歸其觸發所屬葉。
- 與最近既有葉的判別：PM.DCA 由不利價格移動觸發加碼，本葉由有利價格移動觸發加碼，方向相反。
- 成員：big_trend_catcher_quadgate_vcp_atr_trailing_swing_trade_srrb0tts.3aea9ce4f096.md#3、shanmugha_intraday_and_positional_for_selling_4r2zsx3v.1e9cc2a6d1ca.md#2
