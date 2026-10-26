【指標】range=high-low；geo=(close-low)/range；delta=volume*(2*geo-1)；delta_pct=delta/volume*100；rvol=volume/SMA(volume,20)；body=|close-open|/range；下影=(min(open,close)-low)/range；上影=(high-max(open,close))/range；avgD=SMA(|delta|,20)（為0則取1）。影線門檻W依週期：<=1分0.38、<=15分0.35、<=4小時0.30、更大0.25，再乘0.983（上限0.55）。
【吸收條件】效力足=rvol>=1.5 或 |delta|/avgD>=1.25。
多方吸收A=下影>=W 且 close>=low+0.5*range 且效力足 且(delta<0 或 |delta_pct|>=26.1)。
空方吸收B=上影>=W 且 close<=high-0.5*range 且效力足 且(delta>0 或 |delta_pct|>=26.1)。
多方背離=(low<low[1] 或 low<low[2]) 且 delta>0 且(close>open 或 close>low+0.35*range)。
空方背離=(high>high[1] 或 high>high[2]) 且 delta<0 且(close<open 或 close<high-0.35*range)。
買方吸收=A 或(多方背離 且 rvol>=1.25)；賣方吸收=B 或(空方背離 且 rvol>=1.25)。
【驅動】多頭驅動=rvol>=1.575 且 body>=0.661 且 close>open 且(delta>0 或 delta_pct>=25)；空頭驅動=rvol>=1.575 且 body>=0.661 且 close<open 且(delta<0 或 delta_pct<=-25)。
【做多】買方吸收 且 非空頭驅動 且(非賣方吸收 或 close>=open 或 delta>=0)→做多；或 多頭驅動 且 非「賣方吸收成立且未被買方吸收否決」→做多（即賣方吸收成立時不做多驅動）。
【做空】賣方吸收 且 非多頭驅動 且 做多吸收條件未成立→做空；或 空頭驅動 且 做多吸收條件未成立→做空。
【出場】無獨立出場判斷。