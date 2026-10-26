【做多】掃到的低點位（已確認 pivot 低點，左右各 8 根，Structural 預設；Reactive 為 2）必須先被「掃」再「收回」。
掃低：本根 low < 位 且前一根 low >= 位（首次穿越）；深度 d=(位-low)/ATR(14)，需 0.05<=d<=0.80；首次穿越才算（該位未被穿過）；若同一根同時掃高與掃低則不算。穿越類型 Wick 或 Body 皆可（body 低點=min(open,close)<位 為 body，否則 wick）。
收回（掃的同根或之後 3 根內，視窗 Flexible=3），收盤確認時全部成立：
1) close >= 位 + 0.05*ATR；
2) (close-low)/max(high-low,mintick) >= 0.70；
3) |close-open|/ATR >= 0.15；
4) 若掃與收回同一根：(min(open,close)-low)/(high-low) >= 0.28；
5) 品質分 >= 80（Strict）。品質分=各項加總四捨五入：掃深度(15)：n=clamp((d-0.05)/0.75,0,1)，clamp(1-|n-0.35|/0.65,0,1)*15；收盤位置(20)：clamp((closeLoc-0.45)/0.55,0,1)*20；下影線(15)：同根時 clamp(lowerWick比例/0.45,0,1)*15，否則 max(wick型掃0.72/body型掃0.42, 0.65*clamp(wick比例/0.45,0,1))*15；新鮮度(10)：(1-clamp(位年齡/500,0,1))^0.65*10；量能(10)：clamp((volume/SMA(volume,20)-0.55)/1.25,0,1)*10（無量為5）；位移(15)：(0.65*clamp(body/ATR/0.55,0,1)+0.35*clamp(|close-位|/ATR/0.45,0,1))*15；市場(10)：rangeATR=(high-low)/ATR，r<=1.2 則 r/1.2 否則 clamp(1-(r-1.2)/2.8,0,1)，與 regime=ATR/SMA(ATR,20)的 clamp((regime-0.65)/0.85,0,1) 以 0.6/0.4 加權*10；乾淨度(5)：穿越次數<=1 得5，2 得3，否則1。
6) 趨勢偏向（Combined EMA）：close > EMA(close,200)（本週期），且更高週期（60 分）前一根已收盤 close > 該週期 EMA(200) 前一根值。
7) 冷卻：同方向上次做多訊號距今 >5 根；與上次做多訊號價距離 |close-上次價|/ATR >= 0.5；目前無持倉；本根非剛平倉那根。
8) 同根若也有做空候選：品質高者勝，相同則兩者皆放棄。多個做多候選取品質最高者。
滿足以上即於收盤做多，進場價=收盤。

【做空】鏡像：已確認 pivot 高點位，穿越 high > 位 且前一根 high <= 位，深度 d=(high-位)/ATR 在 0.05~0.80，首次穿越，body 型為 max(open,close)>位。收回視窗內：close <= 位 - 0.05*ATR；(high-close)/(high-low) >= 0.70；|close-open|/ATR >= 0.15；同根時上影線 (high-max(open,close))/(high-low) >= 0.28；品質分（用上影線與 (high-close)/range 計算，其餘同上）>= 80；趨勢偏向：close < EMA(close,200) 且 60 分前一根收盤 < 其 EMA(200) 前一根值；同方向冷卻 >5 根、與上次做空價距 >=0.5 ATR、無持倉。收盤做空，進場價=收盤。

【出場】進場後下一根起檢查：做多停損=進場價-2*ATR(進場時)，停利=進場價+2*風險(即 +4*ATR)；做空停損=進場價+2*ATR，停利=進場價-4*ATR。做多 low<=停損 出場，high>=停利 出場；做空 high>=停損 出場，low<=停利 出場。同根兩者皆觸及時以停損優先。持倉期間不接受新訊號。