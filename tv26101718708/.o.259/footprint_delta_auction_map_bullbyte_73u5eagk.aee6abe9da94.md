【共用計算】rng=max(high-low,極小值)。bodyRatio=|close-open|/rng。TR 取真實波幅，TR 上限為近30根 TR 中位數×2.5，atr=max(上限後TR 的14期RMA, close×0.05%)。rangeRatio=rng/atr。
壓力 d=(2×close-low-high)/rng×volume；uDelta=d/近30根|d|最大值×100，限制在-100到100，最大值為0則為0。
【綜合分數】fpScore=min(100, |uDelta|/100×40 + min(1,bodyRatio/0.65)×20 + min(1,rangeRatio/2)×15 + |(close-low)/rng-0.5|×2×25)。
水準階梯：tol=close×1.2%；以日期變更為 session 起點，sH/sL 為 session 起點至當根的最高/最低。各水準權重：(sH+sL)/2 為2.5；sH×0.999 為2；sL×1.001 為2；sH 為2；sL 為2；前一日高、前一日低、前一週高、前一週低各為3(由 datetime 聚合，有值才計入)。每個水準 prox=1-|close-水準|/tol(距離>tol 為0)。hits=prox>0 的水準數；ladder=min(100, Σ(權重×prox)/Σ(權重)×100)，分母只含有值的水準。
composite=min(100, fpScore×0.6+ladder×0.4)。
IB 日型：session 前6根的 high-low 為 IB 區間。第6根形成時，若已有至少3個歷史 IB(最近20個 session)，ratio=本日 IB/歷史中位數。ratio>=1.25 為 Trend Day，adj=+5，ibScalar=1.15；ratio<=0.75 為 Balance Day，adj=-5，ibScalar=0.85；其他 adj=0，ibScalar=1。之後才把本日 IB 加入歷史。每個 session 開始時 adj 與日型重設為中性。
【做多進場】以下全部成立才做多：1) IB 已形成，且加入本日後歷史樣本>=4；2) |uDelta|>=35；3) bodyRatio>=0.5；4) hits>=2；5) composite>=58+adj；6) uDelta>0 且 close>open；7) HTF 過濾：把資料重採樣成嚴格大於當前週期的較高週期(如1小時)，取已收完的 HTF 收盤價 EMA21，最近已收完那根的 EMA 大於前一根的 EMA；8) 目前無持倉，且上次出場後已過20根(含)。
【做空進場】條件同上，但 uDelta<0 且 close<open，HTF 的 EMA21 最近已收完那根小於前一根。
【出場】進場價=訊號根 close。訊號根計算尺度 unit：atrPct=atr/close×100；minPct、maxPct 分別為近500根 atrPct 的第10、90百分位(最近排名法)，maxPct=max(maxPct, minPct+0.05)，樣本不足時用0.15/0.55；atrPos=(atr-近100根atr最低)/(近100根atr最高-最低)，區間為0則0.5；unit=close×(minPct+atrPos×(maxPct-minPct))/100。volScalar=clip(atr/atr近50期SMA, 0.8, 1.6)；k2=max(2.0, 2.5×ibScalar×volScalar)。
多單：high>=進場價+k2×unit 出場(延伸目標)；low<=進場價-1.5×unit 出場(失效)。空單：low<=進場價-k2×unit 出場；high>=進場價+1.5×unit 出場。同一根同時觸及兩者時，離前一根 close 較近的那個先成立，距離相同則以延伸目標為準。