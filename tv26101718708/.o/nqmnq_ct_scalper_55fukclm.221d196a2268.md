【共用指標】atr=ATR(14)。adx=DMI(14,14)的ADX。ema21、ema100為收盤EMA。rsi=RSI(14)。mfi=MFI(hlc3,14)。vwap=hlc3的每日重置VWAP。vwapDev=stdev(close-vwap,20)，vwapUp2/Dn2=vwap±2*vwapDev，vwapUp3/Dn3=±3*vwapDev。relVol=volume/SMA(volume,20)。BB=布林(20,1.5)，bbPos=(close-下軌)/(上軌-下軌)。freeBarBelow=high<BB下軌，freeBarAbove=low>BB上軌。
趨勢：ER=|close-close[10]|/近10根|Δclose|總和；門檻=min(0.25*atr/SMA(atr,50),0.65)；trending=ER>門檻；downtrend=trending且close<close[10]；uptrend=trending且close>close[10]；choppy=ER<=門檻且atr>SMA(atr,50)。
擠壓動能：sqzMom=linreg(close-avg(avg(highest(high,20),lowest(low,20)),SMA(close,20)),20,0)。momDecelBull=sqzMom>0且連2根下降；momDecelBear=sqzMom<0且連2根上升。momFlipBull=sqzMom>0且前值<=0；momFlipBear=sqzMom<0且前值>=0。sqzOn=BB完全落在KC(EMA20±1.5*ATR20)內；sqzFired=前一根sqzOn且本根非sqzOn。momStr=|sqzMom|。
動能懲罰pen：做多時若sqzMom<0且非momDecelBear，momStr>2得2、>1得1、否則0；做空鏡像(sqzMom>0且非momDecelBull)。
K線：body=|close-open|，上影=high-max(o,c)，下影=min(o,c)-low。bigLowerWick=下影>1.5*body且>0.3*atr；bigUpperWick同理用上影。doji=range>0且body<0.05*range。bullEngulf=陽線、前一根陰線、body>SMA(body,14)、close>open[1]且open<=close[1]；bearEngulf鏡像。hammer=下影>2*body、上影<0.3*body、0<body<SMA(body,14)；shootingStar鏡像。
結構：pivot左右各5根取swing high/low，保留最近兩個。fullBearStruct=最新swing low<前一swing low且最新swing high<前一swing high；fullBullStruct=兩者皆較高。hhBullish=最新swing high>前一個；llBearish=最新swing low<前一個。chochBull=fullBearStruct且close>最新swing high；chochBear=fullBullStruct且close<最新swing low。
吸收：absorbBull=volume>1.8*均量且range<0.6*SMA(range,20)且body/range<0.4且close>open；absorbBear同條件但close<open。
掃流動性：高=highest(high,20)[1]，低=lowest(low,20)[1]。bearSweep(指向做多)=low<前低且close>前低，並同時滿足：任一側影線>0.6*atr；max(上影,下影)/body>=1.2；relVol>=1.5；range>1.2*SMA(range,20)；下影>SMA(下影,20)+1.5*stdev(下影,20)。bullSweep(指向做空)=high>前高且close<前高，條件同但用上影。
RSI背離：price與rsi各用左右5根pivot。bullDiv=新pivot low價格低於前一個、對應rsi高於前一個(做多)；bearDiv=價格pivot high更高、rsi更低(做空)。hiddenBullDiv=價格pivot low更高但rsi pivot low更低；hiddenBearDiv=價格pivot high更低但rsi pivot high更高；僅在pivot確認那根為真。
VRZ：volume>均量*m的K線為量區，m=1.8+(trending+0.2/choppy-0.2)+(adx>=30:+0.2/adx<20:-0.15)，夾在1.2~2.8；保留最近3個量區的high/low/mid(vrzMid=最新量區中點)。vrzDist=(close-vrzMid)/atr。價格與所有量區中點的距離都>=atr*A時標記wasAway=true，A=1.5+(trending+0.3/choppy-0.2)夾0.8~2.5。vrzRetestSup=wasAway且存在量區low<=區低+0.5*atr且close>區低(觸發後wasAway=false)；vrzRetestRes=wasAway且high>=區高-0.5*atr且close<區高(同樣重置)。

【過度延伸分數】做多(價在均值下方)累加：
1. d=(ema21-close)/atr，e=downtrend且adx>=30:2.5，trending:2.0，choppy:1.0，其餘1.5；d>=1.5e得2，d>=e得1。
2. v=(vwap-close)/atr，vt=adx>=35:2.5，adx>=25:1.8，其餘1.2；v>=1.3vt得1.5，v>=vt得0.75。
3. hhBullish得1.5。
4. MFI超賣：mfi<=20-(trending:3/choppy:-3，即trending-3、choppy+3)-(adx>=35:2/adx<20:-2)(夾10~28)，則得wt*mag；mag=min(1.5,|mfi-50|/30)；wt=relVol>=H得1.5，>=L得1.0，否則0.5；H=1.5+(trending+0.15/choppy-0.1)+(adx>=30:+0.15/adx<20:-0.1)夾1~2.2；L=1+(trending+0.1/choppy-0.1)夾0.6~1.5。
5. relVol<(trending:0.7，其餘0.8)得0.5。
6. bigLowerWick得0.5。
7. vrzDist<=-1.5*T得1.5，<=-T得0.75；T=max(1.0,(trending:2.2否則1.8)+(adx>=30:0.3/adx<20:-0.2))。
8. freeBarBelow得1。
9. RSI超賣：rsi<=30+(trending:-3/choppy:+3)+(adx>=35:-2/adx<20:+2)(夾22~37)，則得w*min(1.5,|rsi-50|/30)，w=(trending且adx>=30)?0.6:0.4。
10. close<vwapDn2得0.75，close<vwapDn3再加0.5。
做空為鏡像：用(close-ema21)/atr、(close-vwap)/atr、llBearish(1.5)、MFI超買(mfi>=80+(trending:3/choppy:-3)+(adx>=35:2/adx<20:-2)，夾72~90)、bigUpperWick、vrzDist>=、freeBarAbove、RSI超買(rsi>=70+(trending:3/choppy:-3)+(adx>=35:2/adx<20:-2)，夾63~78)、close>vwapUp2/Up3；uptrend且adx>=30時e=2.5。
過度延伸門檻TH=夾1.5~5 的 2.5+(adx>=35:1.0/adx>=25:0.5)+(trending:0.3/choppy:-0.3)。overextOk=分數>=TH。

【信心分數conf】做多累加：①過度延伸分數>=TH+1.5，或>=TH+0.5且fullBearStruct，得1；②MFI超賣成立得(mag>=1.2?2:1)；③relVol>=1.5*Hc得2，relVol>=Hc得1(Hc=夾1.3~3.0 的 2.0+(trending+0.2/choppy-0.2)+(adx>=35:+0.3/adx<20:-0.2))；④bigLowerWick或freeBarBelow得1；⑤bbPos<(trending?0.08:0.12)或close<vwapDn2得1；⑥momDecelBear或momFlipBull或(sqzFired且sqzMom>0)得1；⑦chochBull得(trending?2:1)；⑧(bullEngulf或hammer)且非doji得1。做空鏡像(MFI超買、bigUpperWick/freeBarAbove、bbPos>(trending?0.92:0.88)或close>vwapUp2、momDecelBull或momFlipBear或(sqzFired且sqzMom<0)、chochBear、bearEngulf或shootingStar)。
minConf=夾2~6 的 3+((trending且adx>=35)?1:0)。

【閘門】做多須同時：downtrend；adx>=20；relVol>=0.5；做多overextOk；做多conf>=minConf；非(hiddenBearDiv且adx>=(trending:15/choppy:25/其餘20))。做空：uptrend；其餘鏡像，阻擋條件改用hiddenBullDiv。持倉中同方向不重複，每根最多一個方向訊號。
regBoost=(trending且adx>=30)?2:(trending且adx>=25)?1:0。做多額外門檻extraBuy=max(0,regBoost-1)；做空extraSell=regBoost。

【做多進場(閘門通過後，下列任一成立，在該根收盤進場)】
A.FADE：非doji，且fadeConf>=夾1~6 的 2+(adx>=35?1:0)+pen+extraBuy；fadeConf=bigLowerWick+absorbBull+momDecelBear+momFlipBull+(sqzFired且sqzMom>0)+freeBarBelow+((bullEngulf或hammer)且非doji)+chochBull*(trending?2:1)(每項成立為1)。
B.DIV/ABSORB：momDecelBear；或absorbBull且pen=0。
C.TRAP：bearSweep且pen=0 時才可成立(pen>0則不成立)。
D.VRZ：vrzRetestSup，且bigLowerWick+absorbBull+momFlipBull>=夾1~3 的 1+(adx>=35?1:0)+pen+extraBuy。
做空鏡像：fadeConf用bigUpperWick、absorbBear、momDecelBull、momFlipBear、(sqzFired且sqzMom<0)、freeBarAbove、(bearEngulf或shootingStar且非doji)、chochBear；DIV/ABSORB用momDecelBull或absorbBear；TRAP用bullSweep；VRZ用vrzRetestRes，門檻改extraSell。

【方向標記(單獨成立即各自指向該方向)】做多：bullDiv；absorbBull且做多overextOk；vrzRetestSup且做多overextOk且做多conf>=minConf；bearSweep且做多overextOk且做多conf>=minConf；chochBull剛轉真(前一根為假)且relVol>=0.8；sqzFired且sqzMom>0；momFlipBull且|sqzMom|>1且relVol>=0.8。做空：bearDiv；absorbBear且做空overextOk；vrzRetestRes且做空overextOk且做空conf>=minConf；bullSweep且做空overextOk且做空conf>=minConf；chochBear剛轉真且relVol>=0.8；sqzFired且sqzMom<0；momFlipBear且|sqzMom|>1且relVol>=0.8。

【停損停利與出場】進場價=進場根close，進場根不判出場。
多單SL=max(close-3atr, min(最新swing low - atr*buf, close-1.5atr))(再限制 close-SL 至少0.8atr)；buf=夾0.6~2.5 的 1.0+(trending+0.3/choppy-0.05)+(adx>=35:+0.2/adx<20:-0.05)+(relVol>=Hc:+0.2/relVol<L:-0.05)。空單SL=min(close+3atr, max(最新swing high + atr*buf, close+1.5atr))。
多單TP：候選為高於close的ema21、vwap、ema100，取最近值nearT與最遠值farT(無候選則nearT=close+1atr，farT=nearT；候選限制在close+0.5atr~close+5atr)；raw=conf>=5用farT，conf>=3用(nearT+farT)/2，否則nearT。TP距離=max(0.5atr,(raw-close)*0.85*clamp(0.8,1.3,0.8+過度延伸分數*0.05)*(adx>=35?0.8:adx>=25?0.9:1)*clamp(0.8,1.2,relVol*0.3+0.7)*(trending?0.85:choppy?1.1:1))，TP=close+距離。空單鏡像，候選為低於close的ema21、vwap、ema100，TP=close-距離。
出場：進場根之後，多單 low<=SL 出場(止損)，high>=TP 出場(止盈)；空單 high>=SL 或 low<=TP 出場。出場後才可再進場。