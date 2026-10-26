通用定義：ATR=14根ATR；實體=|收盤-開盤|；EMA快線=收盤21期EMA；均量不用。多單位移=收>開且實體>1.5ATR，空單位移=收<開且實體>1.5ATR。結構狀態state初始0，多方CHOCH/BOS成立後設1，空方成立後設-1。

【A. 流動性掃蕩（EQH/EQL）】前30根(不含當根)最高價H30與最低價L30。做多：low<L30且close>L30。做空：high>H30且close<H30。

【B. MSS（需先有掃蕩）】內部樞紐長度4：某根high為前後各4根內最高即樞紐高（low同理為樞紐低），第4根後確認，取最近一個樞紐高SH、樞紐低SL。
做多MSS：25根內(含之前、不含當根)出現過做多掃蕩，且 close>SH、open<SH、實體>0.6ATR、(當根與前一根皆為多單位移，或當根為多單位移且實體>0.95ATR)、|close-EMA21|>0.4ATR、EMA21>2根前的EMA21。
做空MSS：25根內出現過做空掃蕩，且 close<SL、open>SL、實體>0.6ATR、(當根與前一根皆為空單位移，或當根為空單位移且實體>0.95ATR)、|close-EMA21|>0.4ATR、EMA21<2根前的EMA21。

【C. 內部CHOCH/BOS】用B的SH/SL。向上突破：close>SH且前一根close<=SH；向下突破：close<SL且前一根close>=SL。位移多=收>開且實體>0.8ATR，位移空=收<開且實體>0.8ATR。
做多CHOCH：向上突破且state<=0且位移多。做多BOS：向上突破且位移多且state>0。
做空CHOCH：向下突破且state>=0且位移空。做空BOS：向下突破且位移空且state<0。

【D. 外部結構】樞紐長度12的最近樞紐高EH、樞紐低EL。外部做多BOS：close>EH且前一根close<=EH且位移多；外部做多CHOCH：同條件且state<=0。外部做空BOS：close<EL且前一根close>=EL且位移空；外部做空CHOCH：同條件且state>=0。

【E. 結構引擎2.0】內部(樞紐長度5)與波段(樞紐長度20)各記最近樞紐高、樞紐低，每個樞紐只能被突破一次。收盤第一次>樞紐高→做多（偏向原為-1則為CHoCH，否則BOS），偏向設1；收盤第一次<樞紐低→做空（偏向原為1則為CHoCH，否則BOS），偏向設-1。內部與波段偏向各自獨立。

【F. 誘導（局部樞紐掃蕩）】樞紐長度3的最近樞紐低PL、樞紐高PH。
做多：low<PL-0.03ATR、close>PL、min(open,close)-low>=0.1ATR、距上次做多誘導>=5根、PL與上次做多誘導的PL差>0.03ATR、state>=0。
做空：high>PH+0.03ATR、close<PH、high-max(open,close)>=0.1ATR、距上次做空誘導>=5根、PH與上次差>0.03ATR、state<=0。