【指標】atr14=ATR(14)，atr50=ATR(50)。volRatio=atr14/atr50（atr50為0時取1）。左窗L=round(clamp(10/max(0.5,volRatio),4,16))，右窗R=2。tol=0.25*atr14。前50根不產生訊號。

【流動性池】
1.樞紐高：high[R]為前L根與後R根中的最高點。樞紐低：low[R]為前L根與後R根中的最低點。
2.新樞紐價p出現時，找同類型（高/低）、仍為active、|p-pool.level|<=tol，且距該池最後觸碰<=200根的池。
3.找到就更新：level=(level*n+p)/(n+1)，n加1，最後觸碰=樞紐所在bar_index。
4.找不到就新建：level=p，n=1，active。
5.池的上下界=level±tol/2，tol取更新或建立當根的值。
6.cumVol：樞紐K的volume，加上之後每根high或low落入上下界（或K線完全包覆上下界）的K的volume，不含樞紐K本身。
7.volMedian=所有池cumVol的中位數，池數>=3才有值，每25根更新一次。

【池強度】age=bar_index-最後觸碰bar_index。
strength=min(35,(n-1)*9)+35*0.5^(age/150)+min(20,ln(max(1,cumVol/volMedian))*8)，限制在0到100。volMedian無值時，量項為0。

【做多】在已收盤K檢查所有active的「低點池」，條件須同時成立：
- bar_index>=最後觸碰+R+1
- low<池下界
- close>池level
- strength>=25

【做空】在已收盤K檢查所有active的「高點池」，條件須同時成立：
- bar_index>=最後觸碰+R+1
- high>池上界
- close<池level
- strength>=25

只要high>池上界（高點池）或low<池下界（低點池），該池就不再active，不論close是否收回。同根同時出現多空訊號時取多。

【持倉過濾】持倉中忽略新訊號。例外是當根K已觸發目前持倉的止損或TP3出場，此時新訊號可進場。

【進場價與停損停利】進場價=訊號K收盤價。R=1.5*ATR(14)（取訊號K的值）。
- 多單：SL=進場-R，TP1=進場+1R，TP2=進場+2R，TP3=進場+3R。
- 空單：SL=進場+R，TP1=進場-1R，TP2=進場-2R，TP3=進場-3R。

【出場】進場當根不判斷出場，之後每根K依序判斷：
- 多單：low<=SL出場；否則high>=TP3出場。
- 空單：high>=SL出場；否則low<=TP3出場。
- 同根K同時觸及SL與TP3，視為止損。
- 該K的出場判斷用本根開始前的SL，不用本根新移動的SL。

【保本移動】持倉中某根K觸及TP1（多單high>=TP1，空單low<=TP1），且同根未觸及SL，則SL改為進場價，從下一根起生效。TP1之後的出場仍用上述判斷，只是SL換成進場價。