做多、做空判斷（皆逐根以收盤價與指標計算）：
1. VWAP穿越：VWAP為每日重置的成交量加權均價，每根典型價取(high+low+close)/3，累計(典型價×volume)/累計volume。close由下往上穿越VWAP（前一根close<=前一根VWAP且本根close>VWAP）指向做多；close由上往下跌破VWAP（前一根close>=前一根VWAP且本根close<VWAP）指向做空。同時close>VWAP偏多、close<VWAP偏空。
2. EMA排列：EMA(close,9)>EMA(close,21)指向做多；EMA(close,9)<EMA(close,21)指向做空；相等為中性。
3. 線性回歸通道中線：L=ta.linreg(close,80,0)，即最近80根close的最小平方法回歸線在當根的值。L>前一根L（上升）指向做多，否則（下降）指向做空。
4. 放量K線方向：量比=volume/最近10根volume的簡單平均（含當根）。量比>=1.2且close>open指向做多；量比>=1.2且close<open指向做空；量比<1.2或close==open無方向。
另有過濾：量比>=1.2才採信第4項。其餘判斷無額外過濾。無出場判斷。