【共用定義】tol=3(價格單位,依商品調整);ATR=ATR(14);volR=volume/SMA(volume,10);body=|C-O|,rng=H-L,bullFrac=(C-L)/rng,bearFrac=(H-C)/rng(rng=0時為0.5)。
CVD:每根delta=((C-L)-(H-C))/rng*volume,每日歸零後累加;cvdDir=sign(累計值-5根前累計值)。
量價分布:日/週/月各自在新週期歸零,每根K的volume平均分攤到H~L涵蓋的所有價格格(格寬=8個最小跳動),POC=量最大格,VAH/VAL=從POC起每次往較大量的鄰格擴張直到累積量≥70%。用當期(含當根)與前期:日取前3、週取前2、月取前1。
levels=所有這些POC/VAH/VAL加日VWAP、週VWAP(各自週期內以(H+L+C)/3加權volume)。touch(k)=high[k]>=lvl-tol 且 low[k]<=lvl+tol;atLvl(k)=任一level touch(k);prevAtLvl=atLvl(1)。
DPOC/DVAH/DVAL=當日量分布,WVAH/WVAL=當週量分布。
pva分數(用前一日量分布):C>pVAH=+2;C>pPOC=+1;C<pVAL=-2;C<pPOC=-1;否則0(無前日為0)。htfBull=pva>=1 或(pva==0且cvdDir>0);htfBear=pva<=-1 或(pva==0且cvdDir<0)。
aboveDVAH=C>DVAH+0.3tol;belowDVAL=C<DVAL-0.3tol;twoAbove=aboveDVAH且C[1]>DVAH-tol;twoBelow=belowDVAL且C[1]<DVAL+tol;priorBelow=C[1]、C[2]都<DVAL;priorAbove=C[1]、C[2]都>DVAH;failedBullBreak=C<DVAH且(C[1]>DVAH或C[2]>DVAH);failedBearBreak=C>DVAL且(C[1]<DVAL或C[2]<DVAL)。
farBelowPOC=C<DPOC且|C-DPOC|/ATR>=1.5;farAbovePOC同理反向;sigma=(C-日VWAP)/日內VWAP加權標準差。
bullCommit=C>O且body/rng>=0.5且C>high[1];bearCommit=C<O且body/rng>=0.5且C<low[1]。
sweepBull=low[1]<DVAL-tol/2 或 <DPOC-tol/2 或 <WVAL-tol/2;sweepBear=high[1]>DVAH+tol/2 或 >DPOC+tol/2 或 >WVAH+tol/2。
FVG:low>high[2]記為多缺口(下緣high[2]、上緣low);high<low[2]記為空缺口(上緣low[2]、下緣high);各取最近一個。

【做多進場】以下全部成立才做多:
1) 型態分數S>=7。S=下列各型態的最高分(需偵測成立):
·突破:aboveDVAH成立,基礎2;twoAbove+2;bodyFrac(body/rng)>=0.55 +1;body>=0.4ATR +1;volR>=1.3 +1;cvdDir>0 +1;C>WVAH +1;htfBear則-2。
·延續:htfBull且prevAtLvl,基礎2;bullCommit+2,否則(C>O且bullFrac>=0.5)+1;sweepBull+2;DVAL<=C<=DVAL+2tol +1;cvdDir>=0 +1;volR>=0.7 +1。
·反轉:priorBelow且prevAtLvl,基礎2;sweepBull+2;bullCommit+2;C>DVAL +1;cvdDir>0 +1;htfBear則-1。
·均值回歸:farBelowPOC或sigma<=-1.5,基礎2;(C>O且bullFrac>=0.45)+2;bullCommit+1;volR>=1.5 +2;cvdDir>0 +1;sigma<=-2 +1。
·失敗突破:failedBearBreak,基礎3;sweepBull+2;bullCommit+2;bodyFrac>=0.55 +1;volR>=1.3 +1;cvdDir>0 +1。
·掃損回收:sweepBull且prevAtLvl,基礎4;bullCommit+2,否則(C>O且bullFrac>=0.45)+1;cvdDir>=0 +1;volR>=1.3 +1;需總分>=5才算成立。
2) 確認數>=所需數。確認數=下列各+1:掃損回收成立;bullCommit;(open[1]>close[1]且C>open[1])或(open[1]>close[1]且C>(open[1]+close[1])/2);high[1]<=多缺口上緣、low[1]>=多缺口下緣且缺口形成<=30根內;twoAbove;拒絕成立[prevAtLvl且(C[1]-L[1])/(H[1]-L[1])>=0.4且C>O,且(bullFrac>=0.6或cvdDir>0)];failedBearBreak。
所需數=(grade總分>=80?3:2)+(逆勢?1:0)。grade總分=int(min(longBias*2.5,20))+位置分+int(min(確認數/4*30,30))+入場分。位置分:前一根碰到日VWAP、週VWAP或當日POC=30;碰到日VAH/VAL或當週POC=20;碰到其他level=10;否則0。入場分=int(20*q),stop距離<=0或>10為0,<=5為1,其間q=(10-stop)/(10-5)。逆勢=shortBias>longBias+1且shortBias>=4。
longBias累加:pva>=2 +3;pva==1 +1;cvdDir>0 +1;C>WVAH +2;C>DPOC+0.3tol +1;failedBearBreak +2;twoAbove +1。shortBias鏡像:pva<=-2 +3;pva==-1 +1;cvdDir<0 +1;C<WVAL +2;C<DPOC-0.3tol +1;failedBullBreak +2;twoBelow +1。
3) prevAtLvl成立(同時滿足位置與區域品質過濾)。
4) stop距離=C-min(low[1],low[2],low[3]),需>0且<=10。
5) 追價限制:max(0,C-ref)<=10,ref=sweepBull?DVAL:high[1]。
6) 報酬風險:取所有level(含各日/週profile與VWAP)中高於C的最近一個為目標,(目標-C)/stop距離>=1.5,且目標存在。
7) 距上次做多訊號>=10根。
8) 閂鎖:上次做多訊號後,需出現連續兩根(當根與前一根)都沒碰任何level才解除;未解除不再做多。

【做空進場】完全鏡像:aboveDVAH↔belowDVAL、DVAH↔DVAL、WVAH↔WVAL、C>O↔C<O、bullFrac↔bearFrac、bullCommit↔bearCommit、cvd與sigma(>=1.5/>=2)符號反向、htfBull↔htfBear、sweepBull↔sweepBear、farBelowPOC↔farAbovePOC、twoAbove↔twoBelow、priorBelow↔priorAbove、failedBearBreak↔failedBullBreak、longBias↔shortBias;延續型位置條件改為DVAH-2tol<=C<=DVAH;CSD為open[1]<close[1]且C<open[1](或C<(open[1]+close[1])/2);空缺口以low[1]>=下緣、high[1]<=上緣判斷;拒絕為(H[1]-C[1])/(H[1]-L[1])>=0.4且C<O且(bearFrac>=0.6或cvdDir<0);stop距離=max(high[1],high[2],high[3])-C;追價ext=max(0,ref-C),ref=sweepBear?DVAH:low[1];目標取低於C的最近level,(C-目標)/stop距離>=1.5;近VWAP與有效位置的aboveDVAH/farAbovePOC對應條件同理。

【早期訊號(預設關閉,啟用時才有)】
早期做多:當根碰到任一日/週/月profile的POC/VAH/VAL(含前期);(C-L)/rng>=0.4;pva>=0;cvdDir>=0;該方向早期閂鎖未啟動(當根與前一根都沒碰任何level時解除,觸發後設定);且當根不是上述做多進場。
早期做空:同樣碰到任一日/週/月profile level;(H-C)/rng>=0.4;pva<=0;cvdDir<=0;閂鎖與不重複條件同理。