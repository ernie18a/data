計算：適應性 R² 門＝close 與 bar 序列的相關係數平方後平滑；門關閉時高於滾動均值加標準差門檻才開啟，門開啟時低於該門檻的較低遲滯界才關閉
計算：Chop 分數＝1－|close 與回看期前 close 的差|／回看期內逐根 close 變動絕對值總和
計算：H-Infinity 平滑值＝以 close 遞迴更新估計值，增益為誤差估計除以誤差估計與雜訊、擾動之和；誤差估計依增益遞迴更新
計算：Laguerre RSI＝將 close 遞迴通過四級 Laguerre 濾波，以上行級間差總和除以全部級間差絕對值總和，乘以百分比尺度；再以 JMA 平滑
計算：累積成交量差＝逐根累加方向成交量：close 高於 open 加 volume，低於 open 減 volume，相等則不變；以 EMA 平滑後取逐根差值
計算：平滑 ATR＝ATR 經兩級 EMA 平滑後，以第一級 EMA 加上兩級 EMA 的差值
做多：空倉且適應性 R² 門開啟且 Chop 分數不高於其門檻且 H-Infinity 平滑值斜率非負且 JMA 平滑 Laguerre RSI 高於多方門檻且平滑累積成交量差斜率為正且 volume 不低於其較長期 SMA 乘以最低成交量比例且 datetime 落在啟用的交易時段內且距上次出場已達冷卻期
做空：空倉且適應性 R² 門開啟且 Chop 分數不高於其門檻且 H-Infinity 平滑值斜率為負且 JMA 平滑 Laguerre RSI 低於空方門檻且平滑累積成交量差斜率為負且 volume 不低於其較長期 SMA 乘以最低成交量比例且 datetime 落在啟用的交易時段內且距上次出場已達冷卻期
出場：多單，low 不高於進場價減平滑 ATR 乘以停損係數或 high 不低於進場價加平滑 ATR 乘以停利係數或適應性 R² 門關閉或 Chop 分數高於門檻或 H-Infinity 平滑值斜率轉負或 JMA 平滑 Laguerre RSI 低於多單出場門檻
出場：空單，high 不低於進場價加平滑 ATR 乘以停損係數或 low 不高於進場價減平滑 ATR 乘以停利係數或適應性 R² 門關閉或 Chop 分數高於門檻或 H-Infinity 平滑值斜率轉正或 JMA 平滑 Laguerre RSI 高於空單出場門檻