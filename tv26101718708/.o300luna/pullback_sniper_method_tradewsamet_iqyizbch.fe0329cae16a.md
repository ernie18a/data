計算：實體＝abs(close−open)；上影線＝high−max(open,close)；下影線＝min(open,close)−low
計算：趨勢快／慢 EMA、回踩 EMA、ATR、RSI；前期高／低＝不含當根的回看區間 high 最大值／low 最小值
計算：McGinley Dynamic＝初值為 close 的 EMA；後續值＝前值＋(close−前值)/(McGinley 期×(close/前值)^4)
計算：多單止損＝進場價−ATR×止損倍數；空單止損＝進場價＋ATR×止損倍數；風險距離＝進場價與止損價的差距；TP3 距離＝風險距離×風險報酬倍數；TP1、TP2 距離＝TP3 距離分別乘以遞增的比例，且兩比例皆小於完整 TP3 距離
做多：無持倉且無未完成設定，趨勢快 EMA＞慢 EMA 且 close＞慢 EMA 且快 EMA＞其較早回看值；close＞前期高點且 close＞open 且實體≥ATR×突破門檻；突破後設定未失效或過期，至少等待最短間隔且未超過最長間隔，low≤回踩 EMA 且 close＞設定時以前期低點計算的失效價；回踩已觸及且趨勢條件仍成立；確認模式為快速時 close＞回踩 EMA 且 close＞open，或為平衡時再滿足 close＞前根 high 或下影線≥實體的一半，或為嚴格時再滿足 close＞前根 high 且實體≥ATR×確認門檻；abs(close−回踩 EMA)≤ATR×進場距離上限；若啟用 McGinley 過濾則 abs(close−McGinley Dynamic)≥ATR×距離門檻；若啟用 RSI 過濾則 RSI≥多方門檻；若啟用冷卻則距上次訊號至少達冷卻間隔；本根未平倉且未平倉交易；若上次 TP3 為空單則方向鎖已解除
做空：無持倉且無未完成設定，趨勢快 EMA＜慢 EMA 且 close＜慢 EMA 且快 EMA＜其較早回看值；close＜前期低點且 close＜open 且實體≥ATR×突破門檻；突破後設定未失效或過期，至少等待最短間隔且未超過最長間隔，high≥回踩 EMA 且 close＜設定時以前期高點計算的失效價；回踩已觸及且趨勢條件仍成立；確認模式為快速時 close＜回踩 EMA 且 close＜open，或為平衡時再滿足 close＜前根 low 或上影線≥實體的一半，或為嚴格時再滿足 close＜前根 low 且實體≥ATR×確認門檻；abs(close−回踩 EMA)≤ATR×進場距離上限；若啟用 McGinley 過濾則 abs(close−McGinley Dynamic)≥ATR×距離門檻；若啟用 RSI 過濾則 RSI≤空方門檻；若啟用冷卻則距上次訊號至少達冷卻間隔；本根未平倉且未平倉交易；若上次 TP3 為多單則方向鎖已解除
出場：多單，high≥TP3；或 low≤止損價；或曾觸及 TP1／TP2 後 low≤止損價時以曾觸及的最高 TP 出場。若同根觸及任一 TP 與止損，按止損出場
出場：空單，low≤TP3；或 high≥止損價；或曾觸及 TP1／TP2 後 high≥止損價時以曾觸及的最高 TP 出場。若同根觸及任一 TP 與止損，按止損出場