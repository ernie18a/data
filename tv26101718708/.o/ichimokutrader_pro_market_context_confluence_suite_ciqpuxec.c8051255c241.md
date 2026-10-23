【指標】Tenkan(TK)=(近9根最高high+近9根最低low)/2；Kijun(KJ)=近26根同法；SA=(TK+KJ)/2；SB=近52根同法。雲=SA、SB 往前26根的值，雲上緣kH=max(SA[26],SB[26])、雲下緣kL=min(SA[26],SB[26])。Chikou=close。

【B1做多／S1做空】
B1條件：TK>=KJ，且close>kH，且close>high[26]，且close>max(SA[52],SB[52])，且當根SA>SB。
S1條件：TK<=KJ，且close<kL，且close<low[26]，且close<min(SA[52],SB[52])，且當根SA<SB。
訊號只在條件由不成立轉成立的那根K收盤後觸發；而且必須與上一次觸發的方向不同（同方向不重複）。

【IB做多／IS做空（共振計分）】
先對下列比較各給分：成立+1、反向-1、相等0。
1 close對TK；2 close對KJ；3 close對雲（>kH為+1，<kL為-1）；4 close對high[26]（>為+1）及low[26]（<為-1）；5 close對TK[26]；6 close對KJ[26]；7 close對雲上下緣（取SA[52]、SB[52]的max、min）；8 TK對KJ；9 TK對雲（kH、kL）；10 KJ對雲；11 SA對SB；12 B1為+1、S1為-1；13 close對SA[26]；14 TK對SA[26]；15 KJ對SA[26]；16 close對SA[52]；17 close對SB[26]；18 TK對SB[26]；19 KJ對SB[26]；20 close對SB[52]。
總分score＝以上相加。
偏向b：close>kH為+1，close<kL為-1，否則0。
做多狀態：score>=max(7-b,0)+1。做空狀態：score<=-(max(7+b,0)+1)。
狀態由非做多轉成做多的那根觸發IB，由非做空轉成做空的那根觸發IS；而且必須與上一次觸發的方向不同。

【缺口K】
多：low>high[2]（向上缺口）；空：high<low[2]（向下缺口）。

【分形背景】
以左右各2根的樞紐高、低點取最近一個樞紐高點與樞紐低點。high>最近樞紐高點為多；low<最近樞紐低點為空。