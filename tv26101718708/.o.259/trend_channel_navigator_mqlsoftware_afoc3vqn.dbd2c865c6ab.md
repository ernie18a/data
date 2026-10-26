【指標】
1) ATR14、ATR100 為 Wilder ATR。波動比 v=ATR14/ATR100，擺動窗 lb=round(18/clamp(v,0.7,1.6))。
2) 擺動高點：第 lb 根前的 high 嚴格高於更早 lb 根的 high，且 >= 之後 lb 根的 high。擺動低點反向。該點須比目前錨點新才採用。
3) 錨點(最近有效擺動點)：沒有錨點時，第一個擺動點直接成為錨點。之後出現反型擺動點，須與錨點相距 >=8 根且價差 >=2.5*ATR14 才取代錨點，否則忽略。同型擺動點只有更極端(更高的高點或更低的低點)時才取代錨點。
4) 巨觀方向 macro：錨點為低點則 macro=上(+1)，錨點為高點則 macro=下(-1)。尚無錨點或當根 bar_index<=錨點 bar 時，無巨觀方向。
5) 巨觀通道：端點用錨點價與前一根 close，兩點成線，這條線是基準線 basis(x)，x 為距錨點的根數。對錨點到前一根的每根 K 棒，上偏差=max(0,high-basis)，下偏差=max(0,basis-low)。updev、dndev 分別取各自的 90 百分位(線性內插)。hw_up=max(1.1*updev,ATR14)，hw_dn=max(1.1*dndev,ATR14)。把基準線沿同斜率外推到當根，upper=basis+hw_up，lower=basis-hw_dn。
6) 微觀回歸：取前 20 根 close(不含當根)，i=0 為最新、i=19 最舊，權重 0.94^i，對 x=i 做加權最小平方。intercept 為最新點的擬合值，slope 為回歸斜率。微觀角度=atan(-slope/ATR14) 換成度數，>3 為微觀上，<-3 為微觀下，其餘為平。R² 為加權相關係數平方。stdev=sqrt(加權殘差平方平均)。micro_upper=intercept+2*stdev，micro_lower=intercept-2*stdev。R²>=0.2 才算有效(visible)。
7) 通道位置 pos%=(close-lower)/(upper-lower)*100。
8) 分數(無巨觀方向時為 0)。做多分=35(macro上且微觀上，否則0)+clamp((100-pos%)*0.2,0,20)+(visible 則 R²*20，否則0)+12.5*(兩個高週期中方向為上的個數)。做空分=35(macro下且微觀下)+clamp(pos%*0.2,0,20)+R²項(同上)+12.5*(兩個高週期中方向為下的個數)。高週期方向指把資料重採樣到更高兩個週期，用相同演算法算出前一根已收盤 K 棒的巨觀方向。

【判斷】都只在收盤確認的 K 棒評估。
做多：
A) 突破：macro為下，且 close 上穿 upper(前一根 close<=前一根 upper，當根 close>upper)，做多分>=40，距上次突破訊號>=15根。
B) 回檔：macro為上，且 lower<=close<=lower+0.2*ATR14，前一根不滿足此條件(剛進入)，做多分>=40，距上次回檔訊號>=15根。
C) 續勢：macro為上，微觀有效，close 上穿 micro_upper(前一根 close<=前一根 micro_upper，當根 close>micro_upper)，且距錨點 3~25 根，做多分>=40，距上次續勢訊號>=15根。
D) 進場分數：macro為上，且做多分上穿 75(前一根<=75，當根>75)，距上次進場分數訊號>=20根。

做空(對稱)：
A) macro為上，且 close 下穿 lower，做空分>=40，冷卻15根。
B) macro為下，且 upper-0.2*ATR14<=close<=upper，前一根不滿足(剛進入)，做空分>=40，冷卻15根。
C) macro為下，微觀有效，close 下穿 micro_lower，距錨點 3~25 根，做空分>=40，冷卻15根。
D) macro為下，且做空分上穿 75，冷卻20根。

出場：無明確出場規則。