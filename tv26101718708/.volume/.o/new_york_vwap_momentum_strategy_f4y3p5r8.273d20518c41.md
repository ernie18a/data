計算：Session VWAP＝每根以（high＋low＋close）／3 乘以 volume 累積後，除以累積 volume；於 VWAP 計算時段開始時重設
做多：前一根 close＞open 且當根 close＞open，且當根 volume≥前一根 volume×設定倍數，且當根 low＞Session VWAP，且當根 |close−open|＞當根 high−low×設定比例，且位於允許的交易時段與星期，且當日尚無已平倉交易或當日唯一一筆已平倉交易為虧損，且空倉
做空：前一根 close＜open 且當根 close＜open，且當根 volume≥前一根 volume×設定倍數，且當根 high＜Session VWAP，且當根 |close−open|＞當根 high−low×設定比例，且位於允許的交易時段與星期，且當日尚無已平倉交易或當日唯一一筆已平倉交易為虧損，且空倉
出場：多頭，當根 low≤進場時的 Session VWAP 或當根 high≥進場價＋（進場價−進場時的 Session VWAP）×設定風險報酬倍數
出場：空頭，當根 high≥進場時的 Session VWAP 或當根 low≤進場價−（進場時的 Session VWAP−進場價）×設定風險報酬倍數