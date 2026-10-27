計算：成交量加權 MACD 柱＝（短期 EMA(close×volume)／EMA(volume)－長期 EMA(close×volume)／EMA(volume)）－其訊號線（對前述差值取 EMA）
做空：成交量加權 MACD 柱 < 0 且 close < HMA 且短期 TEMA(hlc3) < 長期 TEMA(hlc3) 且 datetime 位於設定的回測區間內
出場：空單，成交量加權 MACD 柱 > 0 或 close > HMA 或短期 TEMA(hlc3) 由不高於長期 TEMA(hlc3) 穿越至高於長期 TEMA(hlc3)
出場：空單，價格相對進場價下跌達設定獲利比例或上漲達設定停損比例