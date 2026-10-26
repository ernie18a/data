【基準】取「上一個已完成」的日/週/月K群（回測依資料時間分組，不含當前未完成期）算出 POC、VAH、VAL，下列判斷都拿當根 K 線與這三個值比較。
【計算】期間最高 hi、最低 lo；列數 48，step=(hi-lo)/48（hi=lo 時用最小跳動×48 當範圍）。每根K量 v（0 則視為1）：close>open 全算多方量，close<open 全算空方量，相等各半。該K覆蓋的列為 floor((low-lo)/step) 到 floor((high-lo)/step)（夾在0~47），v 平均分到各列，每列總量=多+空。POC列=總量最大列（同量取較低列），POC=lo+(idx+0.5)*step。價值區：從POC列起，累計量<總量×70% 時，比較上方鄰列與下方鄰列，上方量>=下方量就納入上方，否則納入下方（一側用完則另一側），直到累計>=70%。VAH=lo+(最高納入列+1)*step，VAL=lo+最低納入列*step。
【做多】
1. 站上VAH：close>VAH（多方接受）；嚴格版：最近2根 close 都>VAH 且2根前 close<=VAH。
2. VAL防守：low<=VAL 且 close>VAL（含跌破後收回：low<VAL、close>VAL、前一根 close>=VAL）。
3. 收復POC：close>POC 且前一根 close<=POC。
4. 失敗拍賣向上：low<VAL 且 close>VAH。
5. 本期POC高於前一期POC（POC上移，標多）。
6. 某價格列多方量占該列總量>=75%（多方失衡列）標多。
【做空】
1. 跌破VAL：close<VAL（空方接受）；嚴格版：最近2根 close 都<VAL 且2根前 close>=VAL。
2. VAH拒絕：high>VAH、close<VAH 且前一根 close<=VAH。
3. 跌破POC：close<POC 且前一根 close>=POC。
4. 失敗拍賣向下：high>VAH 且 close<VAL。
5. 本期POC低於前一期POC（POC下移，標空）。
6. 某價格列空方量占該列總量>=75%（空方失衡列）標空。
【過濾】只有已存在上一個完成期的 POC/VAH/VAL 時才判斷；close 介於VAL與VAH之間且無上述事件視為平衡，不做多也不做空。