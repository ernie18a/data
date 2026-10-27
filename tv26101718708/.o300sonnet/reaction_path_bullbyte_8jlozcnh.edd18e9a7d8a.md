【通用定義】s=0.75。ATR=14期ATR。K線的range=high-low，body=|close-open|，eff=body/range（range為0時取1）。upW=high-max(open,close)，loW=min(open,close)-low，upR=upW/range，loR=loW/range。
加權：w=1-body/range（range為0時w=0）。
公平價：bp=(high+low+2*close)/4。fair=最近20根（含當根）Σ(bp*w)/Σw。half=Σ(|bp-fair|*w)/Σw，最小為2個tick。upper=fair+half，lower=fair-half。前一根的上軌是用第1到20根算出的同一公式。
aboveFair=close>upper。belowFair=close<lower。
壓力中心P(k)：取從第k根起的10根，loc=(close-low)/range（range為0取0.5），P(k)=Σ(loc*w)/Σw（無權重時取0.5）。
m=P(0)-P(5)，pm=P(1)-P(6)。stall=0.015*s。
exhaustion=P(0)>=0.8或P(0)<=0.2。
reversing=非exhaustion，且(m>=stall且pm<=-stall)或(m<=-stall且pm>=stall)。
building=非exhaustion、非reversing，且(P(0)>=0.68，或P(0)>=0.70)，且P(0)>P(5)（0.68到0.70之間時需此條件，>=0.70時不需），且m>0。
migUp=非exhaustion、非reversing、非building，且m>stall。
migDown=非exhaustion、非reversing、非building、非migUp，且m<-stall。
pressureUp=m>0且(migUp或building或reversing)。pressureDown=m<0且(migDown或reversing)。
contLong=m>0且(building或migUp)。contShort=m<0且migDown。
趨勢：net=close-close[15]。path=Σ(i=0..14)|close[i]-close[i+1]|。te=|net|/path。trendLong=net>0且te>=0.38*s。trendShort=net<0且te>=0.38*s。
speed=range/(前1到5根range平均)。
volR=volume/(前1到20根volume平均)。若最近20根volume的標準差/平均<=0.05，視為成交量無效，volR取1。
最近5根（含當根）中，陽線（close>open）的body/range平均為effL，陽線數/5為domL。陰線（close<open）的同樣算法為effS、domS。
disp=(close-fair)/half。
depthB=前1到5根max((fair-low)/half)。depthA=前1到5根max((high-fair)/half)。
spike=range>3*avgRange5（前1到5根range平均）且eff<0.2。
前一根spike回測=前一根range>3*avgRange5，且前一根body/range<0.2，且當根close落在前一根的low與high之間。
normal=非spike且非前一根spike回測。
expand=range>=前1到5根最大range，且range>=ATR*0.7/s。

【門檻】連續失敗次數f（0到3）：每次失效+1，到達目標或30根後歸0。
D=0.8/s+0.08f，E=0.55*s+0.03f，SP=0.9*s+0.04f，DP=0.5/s+0.05f，V=0.8*s+0.05f，W=0.35/s。

【做多（反應型）】disp<-D，effL>=E，domL>=0.4，loR>upR且loW>upW，speed>=SP，volR>=V，depthB>=DP，normal，pressureUp。全部成立，以收盤價進多。
【做空（反應型）】disp>D，effS>=E，domS>=0.4，upR>loR且upW>loW，speed>=SP，volR>=V，depthA>=DP，normal，pressureDown。全部成立，以收盤價進空。
【做多（延續型）】aboveFair，expand，upR<W，eff>0.5，speed>=SP，volR>=V，trendLong，normal，contLong。全部成立，以收盤價進多。
【做空（延續型）】belowFair，expand，loR<W，eff>0.5，speed>=SP，volR>=V，trendShort，normal，contShort。全部成立，以收盤價進空。
同時成立時優先順序：反應多、反應空、延續多、延續空。
只在無持倉時進場。

【進場限制】
1. 某方向與類型（反應或延續）進場後即鎖定，不可再同向同類型進場，直到解鎖。解鎖條件：反應多為disp>0.15且m<=0。反應空為disp<-0.15且m>=0。延續多為非aboveFair且m<=-stall。延續空為非belowFair且m>=stall。
2. 失效出場後暫停所有進場，直到下列任一成立：|disp|<0.35，或|m|<0.025，或m朝失效方向的反方向超過0.025（多單失效時m<-0.025，空單失效時m>0.025），或當根range/ATR>失效那根range/ATR的1.25倍，或已過30根。

【出場】進場價=訊號K收盤價，ATR取進場時的值。
多單：T2=進場價+2.4*ATR。
空單：T2=進場價-2.4*ATR。
反應型多單的失效價=訊號K的low-1.2*ATR。反應型空單的失效價=訊號K的high+1.2*ATR。
延續型的失效價=進場當根的fair。
多單：low<=失效價則出場（停損）。否則high>=T2則出場（停利）。
空單：high>=失效價則出場（停損）。否則low<=T2則出場（停利）。
同一根K線同時碰到兩者，以失效價優先。
持倉中，若同方向的延續型條件再度成立（延續型進場條件全部成立，且無需訊號鎖定），T2沿持倉方向外移1.2*當根ATR（多單加、空單減），最多3次。