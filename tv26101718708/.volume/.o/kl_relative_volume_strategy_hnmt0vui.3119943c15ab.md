計算：下影線比例＝（min(open,close)－low）／（high－low）
計算：追蹤停損價＝持倉期間 low－ATR 停損距離的最高值，空倉時以 low－ATR 停損距離初始化
做多：volume 大於 volume 的移動平均值乘相對量能門檻，且 ATR 大於 close 的標準差，且下影線比例大於門檻
出場：多單，low 小於或等於追蹤停損價