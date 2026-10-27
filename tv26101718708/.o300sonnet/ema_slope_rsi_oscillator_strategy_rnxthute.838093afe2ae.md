【指標】shortMA=EMA(close,20)，longMA=EMA(close,160)，pct=(longMA-shortMA)/shortMA*100。raw=longMA-longMA[3]，S=100/π*atan(raw/max(stdev(raw,140),1e-10))。T=10。delta=S-S[1]，deltaOK=|delta|>=2.3。a=|S-S[1]|*6，acc=min(50*a/highest(a,200),50)（分母為0則acc=0）。c=SMA(RSI(close,12),3)-50。gap=|S-c|。

【通用過濾，所有進場都要滿足】
- 只在無倉或反向倉時進場，同向不加碼。反向訊號直接平倉反手。
- |S|>T。
- 做多需 close>open 且 close[1]>open[1]，做空需 close<open 且 close[1]<open[1]。

【做多（以下任一成立）】
1. 趨勢穿越：c 本根沒有上穿也沒有下穿 S；且（S>T 且 S[1]<=T，或 S>T 且 delta>0 且 deltaOK）；且 pct>=-0.34；且 shortMA>longMA。
2. 加速：acc>=5 且 deltaOK 且 delta>0 且 S>T 且 pct>=-0.34 且 shortMA>longMA。
3. 斜率-RSI背離（反轉做多）：acc>=5 且 delta<0 且 S<-T 且 c>c[5] 且 c>c[10] 且 gap>=5。
4. RSI價格背離（預設關閉）：對 smoothed RSI(=c+50) 和 low 各取左右10根的 pivot low，兩者在同一根確認。若 pivot low 價<前8個已存 RSI pivot low 中任一個的價，且 pivot RSI>該前 pivot 的 RSI，則做多。
5. RSI-斜率震盪（預設關閉）：c 上穿 S 且 |S|>T，且不是（c>T 且 S>T），則武裝。武裝後 3 根內（含穿越當根），一旦 c>c[1] 且 S>S[1] 就做多。出現反向武裝或被擋掉的穿越會取消武裝。進場後清除武裝。

【做空】全部鏡像：
1. 趨勢穿越：S<-T 且 S[1]>=-T，或 S<-T 且 delta<0 且 deltaOK；且 pct<=0.34；且 shortMA<longMA。
2. 加速：acc>=5 且 deltaOK 且 delta<0 且 S<-T，濾網同上鏡像。
3. 斜率-RSI背離（反轉做空）：acc>=5 且 delta>0 且 S>T 且 c<c[5] 且 c<c[10] 且 gap>=5。
4. RSI價格背離（預設關閉）：pivot high 價創更高、pivot RSI 較低。
5. 震盪（預設關閉）：c 下穿 S 且 |S|>T，且不是（c<-T 且 S<-T）。武裝後 3 根內 c<c[1] 且 S<S[1] 就做空。

【出場】
- RSI-斜率交叉出場（預設開，只平倉不反手，適用所有持倉）：
  - 多單：c 下穿 S（當根，或下穿後3根內且其間沒有上穿）且 c<c[1] 且 S<S[1] 且 close<open，則平多。
  - 空單：c 上穿 S（當根，或上穿後3根內且其間沒有下穿）且 c>c[1] 且 S>S[1] 且 close>open，則平空。
- 趨勢穿越／加速進場的持倉（預設開）：
  - 多單：S<=T 且 S[1]>T（由上方回到中性區）時平多。
  - 空單：S>=-T 且 S[1]<-T 時平空。
  - 進場當根不檢查。
- 震盪進場的持倉：出現反向震盪訊號（多單遇震盪做空訊號，空單遇震盪做多訊號）就平倉。
- ATR移動停損（預設關閉，ATR=Wilder RMA of TR）：
  - 多單初始停損=進場close-4.4*ATR(10)。持倉根數超過寬限後，停損=max(前停損, high-因子*ATR(12))，只上移。close<停損則平多。
  - 空單鏡像：初始停損=進場close+4.4*ATR(10)，之後=min(前停損, low+因子*ATR(12))，只下移。close>停損則平空。
  - 一般進場因子7、寬限3根；RSI背離進場因子6、寬限5根；震盪進場因子6、寬限3根。
  - 背離進場只靠此停損出場。