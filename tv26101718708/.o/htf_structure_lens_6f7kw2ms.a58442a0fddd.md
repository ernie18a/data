【K線定義】以下 C2/C3 的「K線」可用回測資料逐根 K 線，也可用把回測資料依固定根數聚合成的較高週期 K 線（開=首根開、高=最高、低=最低、收=末根收）。cur=剛收完的 K 線，prv=前一根，pp=再前一根。只在 cur 收盤後判斷。

【做多】符合任一條：
1. 看多 C2：cur.low<prv.low 且 cur.close>prv.low，並且 cur 不是外包線（不可同時 cur.low<prv.low 且 cur.high>prv.high）。
2. 看多 C3：prv.close<prv.open（前一根為陰線），且 cur.low>=prv.low，且 cur.open<=min(prv.open,prv.close)，且 cur.close>max(prv.open,prv.close)。另外 cur 不得是看多或看空 C2；prv 本身不得是看多 C2（prv.low<pp.low 且 prv.close>pp.low）。需要有 pp。
3. 看多 CISD：見下方 CISD 狀態機，當根收盤觸發看多事件。

【做空】符合任一條：
1. 看空 C2：cur.high>prv.high 且 cur.close<prv.high，並且 cur 不是外包線（同上）。
2. 看空 C3：prv.close>prv.open（前一根為陽線），且 cur.high<=prv.high，且 cur.open>=max(prv.open,prv.close)，且 cur.close<min(prv.open,prv.close)。另外 cur 不得是看多或看空 C2；prv 本身不得是看空 C2（prv.high>pp.high 且 prv.close<pp.high）。需要有 pp。
3. 看空 CISD：見下方 CISD 狀態機，當根收盤觸發看空事件。

【出場】未提供獨立的出場條件。

【CISD 狀態機】逐根 K 線計算，可用回測資料的週期。方向 d=收>開為 1，收<開為-1，平盤為 0。
- run(w)：從當根開盤價起。若當根 d==w，往前逐根掃描（最多 500 根），d==0 的略過，遇到 d!=w 即停止。w=1 取連續區間內最低的開盤價，w=-1 取最高的開盤價。若當根 d!=w，結果為當根開盤價。
- prevrun(w)：往前找到第一根 d==w 的 K 線（略過 d==0），以它的開盤價為起點，再繼續往前取同向連續區間（略過 d==0，遇到 d!=w 即停止）。w=1 取最低的開盤價，w=-1 取最高的開盤價。找不到則為 na。
- 狀態：bias（初始為 0）、level、ext。
- 初始化：當 bias==0 且已有超過 10 根 K 線時，取當根 d；若 d==0，改取前 50 根內最近一根非 0 的 d。若得到非 0 的 d，設 bias=d、level=run(d)、ext=（d==1 取 high，d==-1 取 low）。
- 更新：若 bias==1 且 high>ext，則 ext=high，並令 newLevel=（當根 d==1 ? run(1) : prevrun(1)）；newLevel 不為 na 時 level=newLevel。若 bias==-1 且 low<ext，則 ext=low，並令 newLevel=（當根 d==-1 ? run(-1) : prevrun(-1)）；newLevel 不為 na 時 level=newLevel。
- 事件：看多事件=bias==-1 且 close>level；看空事件=bias==1 且 close<level。事件觸發後，bias 翻轉（看多事件變 1，看空事件變 -1），level=run(新bias)，ext=（新bias==1 取 high，新bias==-1 取 low）。