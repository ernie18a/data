【共用指標】ATR=ATR(14)；volSma=成交量20期均；N=10，pivot high/low為左右各N根的高/低點(第N根後確認)。lastHH=最近pivot high價、lastLL=最近pivot low價；lastLH=依序比較pivot high時最近一個低於前一個pivot high的價；lastHL=依序比較pivot low時最近一個高於前一個pivot low的價。波動比=ATR/SMA(ATR,100)；比>1.5則f=+0.2，<0.7則f=-0.2，否則0。門檻thr=round(65+25f)；volM=1.5(1+f)；fvgMin=0.5(1+f)。

【趨勢狀態trend】初始0。close>lastHH且trend<=0→trend=1(多BOS)；close<lastLL且trend>=0→trend=-1(空BOS)；trend==-1且close>lastLH→trend=1(多CHoCH)；trend==1且close<lastHL→trend=-1(空CHoCH)。記錄最近一次BOS/CHoCH所在bar。

【因子，多/空】
f2：多=trend==1且距最近BOS/CHoCH≤10根；空=trend==-1且≤10根。
f3(掃流動性)：流動性位=兩個同類pivot價差≤max(0.15%×close,0.5ATR)時的均價(pivot high群為BSL，pivot low群為SSL，保留最近15個)。BSL未被掃且high>價位且close<價位→掃BSL，視為空方掃；SSL未被掃且low<價位且close>價位→掃SSL，視為多方掃。f3多=最近一次掃的是SSL且≤15根；f3空=最近一次是BSL且≤15根。
f4(多)：取值0/0.5/0.7/1，取最大者。1=存在未緩解多OB且bar的[low,high]與OB區間重疊；多OB產生於多BOS那根，往回1~20根找最近一根陰線(close<open)且volume/volSma>=1.3，區間為該K的[low,high]，之後若有收盤落入區間即視為已緩解，存活60根，且需該volume/volSma>=volM。0.7=存在未被填滿的多FVG且bar與其重疊；多FVG：low>high[2]且low-high[2]>=fvgMin×ATR，區間[high[2],low]，之後只要low<=下緣即視為填滿，存活80根。0.5=bar的[low,high]與OTE區重疊。OTE區：rangeTop=max(lastHH,lastLL)、rangeBot=min，R=top-bot；trend>=0時fib=top-r×R，否則fib=bot+r×R，取r=0.62與0.79兩價之間。空方鏡像：空OB(陽線、空BOS後)、空FVG(high<low[2]且low[2]-high>=fvgMin×ATR，區間[high,low[2]]，high>=上緣即填滿)、同一OTE區。f4計為有效須>=0.5。
f5：多=close<=(lastHH+lastLL)/2；空=close>=該中點。
分數=100×(0.20f2+0.20f3+0.20f4+0.15f5)。有效因子數=f2、f3、f5各為1、f4>=0.5的個數。

【做多】空手，且分數>=thr，有效因子數>=3，且K線收盤確認；另需風險報酬：SL多=lastLL-0.5ATR(lastLL無值則close-2ATR)；stop=max(close-SL,0.1ATR)；TP1=close+1.5stop；TP2=在close之上、未被掃的最近BSL(須>TP1)，否則close+3stop；(TP2-close)/stop>=1.5；且stop<=5%×close才進場。
【做空】空手，條件鏡像：以空方的f2/f3/f4/f5計分與計因子數，分數>=thr，因子數>=3；SL空=lastHH+0.5ATR(無值則close+2ATR)；stop=max(SL-close,0.1ATR)；TP1=close-1.5stop；TP2=在close之下、未被掃的最近SSL(須<TP1)，否則close-3stop；(close-TP2)/stop>=1.5；stop<=5%×close。

【出場】持多：low<=SL→全部停損出場；high>=TP1(未達TP1前)→平50%並把SL移到進場價；其後high>=TP2→出清。未達TP1前，若high-進場價>=0.7×(進場價-原SL)，SL上移到進場價。TP1後追蹤：SL=max(SL,lastHL-0.5ATR)。持空鏡像：high>=SL停損；low<=TP1平50%並SL移到進場價；low<=TP2出清；進場價-low>=0.7×(原SL-進場價)則SL下移到進場價；TP1後SL=min(SL,lastLH+0.5ATR)。