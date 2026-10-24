做多：當根 low 大於前兩根（2 根前）的 high，即向上跳空缺口（bullish FVG），指向做多。缺口區間為 high[2] 到 low，中點為 (high[2]+low)/2。
做空：當根 high 小於前兩根（2 根前）的 low，即向下跳空缺口（bearish FVG），指向做空。缺口區間為 high 到 low[2]，中點為 (high+low[2])/2。
兩個判斷都至少要有 3 根 K 棒才能計算，並以收盤確認的 K 棒為準。
沒有獨立的出場判斷。