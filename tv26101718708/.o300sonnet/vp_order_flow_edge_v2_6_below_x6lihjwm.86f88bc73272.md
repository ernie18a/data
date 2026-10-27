【共用指標】ATR=14根ATR；avgVol=成交量20根SMA；body=|close-open|；range=high-low；avgBody=body的20根SMA；EMA9、EMA21、EMA50=收盤價EMA。VP=最近50根K線的成交量剖面：把50根最高到最低價切成40格，每根K線成交量按價格重疊比例分到各格。POC是量最大那格的中價。VAH、VAL是從POC往兩側擴張，每次加入量較大的鄰格，直到累積量≥總量70%，取外緣價。

【做空訊號】
1.吸收空：body/range≤0.15，且量>3×avgVol，且量是近20根最高(量>=20根最高量)，且close>open，距上次同訊號>15根。
2.陷阱空(多方被套)：前一根為大陽線(close[1]>open[1]、body[1]>1.5×avgBody[1]、量[1]>2.5×avgVol[1])，本根close<open[1]且body>0.8×avgBody，距上次>15根。
3.上探失敗LAF：|high-VAH|<2ATR，且close<EMA50+1.5ATR，且high>前一根起算45根最高價，突破幅度>close×0.05%，且close<該45根最高價，且close<open，距上次>15根。
4.量價背離空：以左右各5根確認的pivot high，新pivot高點價格>前一個pivot高點，且pivot處量<前一個pivot量×0.85，距上次背離>10根；訊號落後5根。
5.動能衰竭空(REV WARN)：|close-VAH|<2ATR或|close-VAL|<2ATR，且close>close[3]，下列7項計分≥3：body連2根縮小(body<body[1]<body[2])；量連2根下降；close<open；上影線>2×body且>0.3ATR；吸收空；LAF；陷阱空。距上次警示>35根。

【做多訊號】(上述鏡像)
1.吸收多：同吸收空，但close<=open。
2.陷阱多(空方被套)：前一根為大陰線(同樣門檻)，本根close>open[1]且body>0.8×avgBody，距上次>15根。
3.下探失敗LBF：|low-VAL|<2ATR，且close>EMA50-1.5ATR，且low<前一根起算45根最低價，跌幅>close×0.05%，且close>該45根最低價，且close>open，距上次>15根。
4.量價背離多：pivot low價更低，且該處量<前一個pivot low量×0.85。
5.動能衰竭多：靠近VAH或VAL(2ATR內)，且close<close[3]，7項計分(close>open、下影線>2×body且>0.3ATR、吸收多、LBF、陷阱多，其餘同前)≥3。

【進場】
進場過濾：冷卻期內(1分K 35根)不得反向或重複進場；量>avgVol。
EMA趨勢過濾：trend_up=(EMA21近3根斜率>0且close>EMA21)或(close>EMA9且close>EMA21)；trend_dn鏡像。做多需trend_up或位在VAL，做空需trend_dn或位在VAH。
價值遷移過濾：每15根取樣一次POC，連續兩次上升=Higher，連續兩次下降=Lower，其餘=Stable。Lower時只在VAL支撐做多(low<=VAL+0.75ATR、low>=VAL-1.5ATR、close[3]>VAL、且收在VAL下方未滿10根)；Higher時只在VAH做空(high>=VAH-0.75ATR、high<=VAH+1.5ATR、close[3]<VAH)。
積極做多：(吸收多、陷阱多或LBF任一，且位在VAL)，或(上述任一訊號且VAL<close<VAL+2ATR)，加close>open且量>avgVol且通過過濾。
積極做空：鏡像，用吸收空、陷阱空或LAF，位在VAH，或VAH-2ATR<close<VAH，加close<open且量>avgVol。
確認做多：先有一根low跌破VAL(或VAH/VAL附近出現LBF/吸收多/陷阱多)且close>VAL且close>open，記為待確認；之後60根內出現close>VAL、close>open、close高於待確認期間最低點+0.5ATR、且(量>1.5×avgVol或有多方訊號)的K線才進場，待確認期間若low<VAL-2ATR則作廢。確認做空鏡像：先有high突破VAH後收在VAH下方的陰線，之後close<VAH、close<open、close低於期間最高點-0.5ATR、量>1.5×avgVol或有空方訊號。
突破回測：close突破VAH/VAL達1ATR以上後，連續3根以上收在突破側，25根內價格回測該線(low<=線+0.8ATR且>=線-0.5ATR)，回測量<突破K量×1.2、回測body<突破K body×1.5，且close在突破側、close>open(空方鏡像)，量>1.2×avgVol或有同向訊號，則順突破方向進場。
擠壓反向：空單進場20~60根內，close>空單位階+1.5ATR且close>open且量>1.5×avgVol則做多；多單進場20~60根內，close<多單位階-1.5ATR且close<open且量>1.5×avgVol則做空。

【停損停利】
做多停損=min(low,觸及價位)-0.75ATR(回測進場用-1ATR)；做空停損=max(近3根high,價位)+0.75ATR。
TP1=進場價±1.5×風險(一半部位出場並移停損至保本)。TP2=風險0.8~3倍範圍內最近的POC或VAH/VAL，沒有則為2倍風險。TP2報酬風險比<1.8則不進場。