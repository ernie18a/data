計算：K棒實體占比＝abs(close－open)／(high－low)
計算：Bar2回撤區＝由Bar2高點向下量取兩個斐波那契回撤界線；短回撤界線與長回撤界線
做多：Bar1與Bar2實體占比均不低於同一門檻，且volume[1]＞volume[2]，且（Bar1與Bar2均收漲，或Bar2收盤＞Bar1最高價且兩棒並非均收漲），且close＞VWAP，且low位於Bar2回撤區內
做空：Bar1與Bar2實體占比均不低於同一門檻，且volume[1]＞volume[2]，且（Bar1與Bar2均收跌，或Bar2收盤＜Bar1最低價且兩棒並非均收跌），且close＜VWAP，且high位於由Bar2低點向上量取的兩個斐波那契回撤界線之間
出場：做多持倉，low≤Bar2最低價下方的停損價
出場：做空持倉，high≥Bar2最高價上方的停損價