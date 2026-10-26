買賣量拆分：每根 K 棒買量 = volume*(close-low)/(high-low)，賣量 = volume-買量；high=low 時各半。

做多（OFF BALANCE TO BUY 標示）：取最近 N 根（預設 23 根，或所選交易時段內的 K 棒），累計買量 sumB、賣量 sumS，傾斜度 tilt = 100*(sumB-sumS)/(sumB+sumS)。同時成立才做多：OVL < 0.75，且 tilt >= 5。
做空（OFF BALANCE TO SELL 標示）：OVL < 0.75，且 tilt <= -5。

OVL 的算法：
- 每根有區間的 K 棒（high>low），買、賣各建一個截斷常態分布，範圍限於 [low, high]，sigma = (high-low)/3。
- 買方中心 = low+(close-low)/2，賣方中心 = close+(high-close)/2。
- 每根的分布面積等於該棒的買量或賣量。
- 把全部 K 棒的買方分布加總、賣方分布加總，各自除以自己的總量，得到兩條機率密度。
- OVL = 兩條密度逐價位取較小值後的積分。
- high=low 的 K 棒視為落在 close 的單點質量，同價位的買賣取較小的比例併入 OVL。

若 OVL >= 0.75 或 |tilt| < 5，則為中性，不指向多空。

另有單根 K 棒的買賣領先標示：當根買量 >= 賣量為「BUY」領先（偏多），否則「SELL」領先（偏空）。依 close 在 K 棒區間的位置，close 在區間中點或以上即買量領先。

出場：READ 無獨立出場判斷。