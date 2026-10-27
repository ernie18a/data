【符號】tick=標的最小跳動；EMA/SMA/RMA(Wilder)；ATR(10)=Wilder ATR；rsi=RSI(close,14)；+DI,-DI,adx=DMI(14,14)；R=max(high-low,tick)；pw=|close-open|/(high-low)(high=low時0)；vol20=SMA(volume,20)；volStrong=volume>1.2*vol20；e10/e6/e12/e15/e18/e20/e50=close的EMA。

【一、雲帶(多空判斷用)】
br=pw；rr=R/RMA(R,20)；a10=ATR(10)；A=RMA(a10,10)；ar=A/RMA(A,50)。
S=RMA(bull-bear,4)：bull=maB+macdB+rsiB+divB，bear鏡像。maB：e10>e20>e50 得2；否則e10>e20且close>e50 得1.25；否則close>e20 得0.55；否則0。macdB：MACD(12,26,9)線>訊號且RMA(hist,3)>=前值 得1。rsiB：r=RMA(rsi,3)，r>55得1，>50得0.55(bear：<45得1，<50得0.55)。divB：18根內出現看漲背離得0.75，背離=low的pivotlow(5,5)與rsi(14)的pivotlow(5,5)同根出現，價格低點低於前一個價格低點且RSI低點高於前一個RSI低點；看跌背離用pivothigh鏡像，價格高點更高且RSI高點更低。
TS=RMA(min(1.8,|S|/3.6+min(0.8,|e10-e50|/A/4)),4)。
expand=clamp(0.6+0.609*rr+0.558*br+0.18*ar+0.26*TS,0.8,3.5)；tight=max(0.45,1-min(0.42,0.22*TS))；wide=1+min(0.85,max(0,1-TS)*0.45)。
gap=(tick+0.342*A)*tight*0.12；ov=max(A*(0.07+0.025*br),0.241*R)；W=max(tick,A*1.95*expand*wide,0.54675*R)；dw=max(tick,A*0.24*(0.34+0.16*TS+0.05*ar))；ex=A*(0.18+0.035*expand)。
權重 cw=0.8384，mw=0.0846，tw=0.077。
上升雲：near=cw*(low+ov-gap)+mw*min(e6,e10,e20)+tw*EMA(low,6)；upTopRaw=clamp(near,low-gap-ex,low+ov+0.35*ex)；upBotRaw=RMA(upTopRaw-W,2)。
下降雲：near=cw*(high-ov+gap)+mw*max(e6,e10,e20)+tw*EMA(high,6)；dnBotRaw=clamp(near,high-ov-0.35*ex,high+gap+ex)；dnTopRaw=RMA(dnBotRaw+W,2)。
m=3(若RMA(rr,3)>=1.15)否則2。upLightTop=SMA(upTopRaw[1],m)，upLightBot=SMA(upBotRaw[1],m)，dnLightBot=SMA(dnBotRaw[1],m)，dnLightTop=SMA(dnTopRaw[1],m)(na時用當根raw)。
深色帶：N=15(若RMA(rr,3)>=1.2)否則10。upDarkRaw=RMA(upLightBot-dw,5)；dnDarkRaw=RMA(dnLightTop+dw,5)。凍結值每5根更新一次(首次算得出即設)：upTopF=SMA(upLightBot[1],N)，upBotF=SMA(upDarkRaw[1],N)，dnTopF=SMA(dnDarkRaw[1],N)，dnBotF=SMA(dnLightTop[1],N)。
upDarkBot=upBotF；upDarkTopD=max(upLightBot,upBotF+0.8*dw)；dnDarkTop=dnTopF；dnDarkBotD=min(dnLightTop,dnTopF-0.8*dw)。

【二、趨勢狀態s(1=多方向,-1=空方向,0=盤整不進場；初值0；s_prev=前一根收盤後的s)】
bullStrong=close>e10 且 close>e6 且 e10>e18 且 e10>e10[1] 且 +DI>-DI 且 adx>=8.4 且 rsi>50；bearStrong鏡像(close<e10,close<e6,e10<e18,e10<e10[1],-DI>+DI,adx>=8.4,rsi<50)。bullBase=close>e10 且 close>e18 且 e10>=e10[1] 且 +DI>=-DI 且 rsi>50；bearBase鏡像。
(1)記憶區：s_prev=1時nUp=[upBotF,upTopF](本根值)；s_prev=-1時nDn=[dnBotF,dnTopF]。ctx=s_prev≠0?s_prev:(fix≠0?fix:0)，fix初值0。touchU=ctx=1且low<=nUp.top且high>=nUp.bot；touchD=ctx=-1且high>=nDn.bot且low<=nDn.top；breakDn=ctx=1且close<nUp.bot；breakUp=ctx=-1且close>nDn.top。若breakDn或touchU則fix=1，否則若breakUp或touchD則fix=-1。
(2)舊區：s_prev=1的那根記錄前一根的[upDarkBot,upDarkTopD]為refU，80根內沿用，過期或從未記錄則用前一根的值；refD用[dnDarkBotD,dnDarkTop]，s_prev=-1時同理記錄。bearOld=low<refU.bot 且 close<refU.top；bullOld=high>refD.top 且 close>refD.bot。touchOld=(s_prev∈{1,0}且非bearOld且low<=refU.top且high>=refU.bot)或(s_prev∈{-1,0}且非bullOld且high>=refD.bot且low<=refD.top)；near3=最近3根(含本根)內曾touchOld。
side=near3 或(touchU且非breakDn)或(touchD且非breakUp)。
(3)更新s，依序取第一個成立：breakUp且非breakDn→1並fix=0；breakDn且非breakUp→-1並fix=0；bullOld且非bearOld→1；bearOld且非bullOld→-1；side→0；s_prev=0時：bullStrong且S>0.55→1，bearStrong且S<-0.55→-1，bullBase且S>0.85且adx>=6.6→1，bearBase且S<-0.85且adx>=6.6→-1，否則0；其餘維持s_prev。
s由非1變1、由非-1變-1為READ標示的多/空方向起點，s=0為盤整標示。

【三、做多(僅在K線收盤、s=1時判斷)】
rsiHi=highest(rsi,10)，rsiLo=lowest(rsi,10)。
buyFilter：45<rsi<68 且 rsiHi<85 且 rsiHi-rsiLo<=20。buyPower：+DI>-DI 且 adx>=8.4。
buyOpp=volStrong 且 close<open 且 pw>=0.42。
touch=((low<=upLightTop 且 high>=upLightBot 且 close>=upDarkBot) 或 (bodyBot<=upLightTop 且 bodyTop>=upLightBot 且 close>=upDarkBot) 或 (cross(low,upLightTop) 或 cross(close,upLightTop) 或 (low<=upLightTop 且 close>upLightTop)，且 close>=upLightBot))；cross為任一方向穿越；bodyTop/Bot=max/min(open,close)。
fresh=touch且前一根非touch；consec=touch且前一根touch。
rebound=touch 且 close>open 且 close>upLightTop 且 close>close[1] 且 非buyOpp。
touchEntry=(fresh 或 (consec 且 rebound)) 且 buyFilter 且 buyPower 且 非buyOpp。
followEntry=最近3根內(不含本根)曾touch 且 本根非touch 且 close>open 且 pw>=0.28 且 close>=low+0.55*(high-low) 且 (非volStrong 或 close>close[1] 或 volume>=volume[1]) 且 close>e10 且 非buyOpp 且 buyFilter 且 buyPower。
normalEntry=(low<=e10 或 low<=e15 或 low<=upLightTop) 且 close>=upLightBot*0.998 且 close>open 且 pw>=0.35 且 close>=low+0.6*(high-low) 且 buyFilter 且 buyPower 且 close>e10 且 close-min(e12,e18)<=2.8*ATR(10) 且 非consec 且 非buyOpp，且距上一次任何多空訊號超過5根。
做多=touchEntry 或 followEntry 或 normalEntry；同一趨勢段內多空訊號合計最多100次(s改變時歸零)。

【四、做空(僅在K線收盤、s=-1時判斷，與做多鏡像)】
sellFilter：32<rsi<55 且 rsiLo>15 且 rsiHi-rsiLo<=20。sellPower：-DI>+DI 且 adx>=8.4。sellOpp=volStrong 且 close>open 且 pw>=0.42。
touch=((high>=dnLightBot 且 low<=dnLightTop 且 close<=dnDarkTop) 或 (bodyTop>=dnLightBot 且 bodyBot<=dnLightTop 且 close<=dnDarkTop) 或 (cross(high,dnLightBot) 或 cross(close,dnLightBot) 或 (high>=dnLightBot 且 close<dnLightBot)，且 close<=dnLightTop))。fresh/consec定義同上。
rebound=touch 且 close<open 且 close<dnLightBot 且 close<close[1] 且 非sellOpp。touchEntry=(fresh 或 (consec 且 rebound)) 且 sellFilter 且 sellPower 且 非sellOpp。
followEntry=最近3根內(不含本根)曾touch 且 本根非touch 且 close<open 且 pw>=0.28 且 close<=high-0.55*(high-low) 且 (非volStrong 或 close<close[1] 或 volume>=volume[1]) 且 close<e10 且 非sellOpp 且 sellFilter 且 sellPower。
normalEntry=(high>=e10 或 high>=e15 或 high>=dnLightBot) 且 close<=dnLightTop*1.002 且 close<open 且 pw>=0.35 且 close<=high-0.6*(high-low) 且 sellFilter 且 sellPower 且 close<e10 且 max(e12,e18)-close<=2.8*ATR(10) 且 非consec 且 非sellOpp，且距上一次任何訊號超過5根。
做空=touchEntry 或 followEntry 或 normalEntry。

【五、出場(以進場價entry與訊號K線數值計)】
多單：entry=min(open,close)(訊號K線)；stop=min(e12,e18,upDarkBot,low-ATR(10)) (訊號K線)；risk=max(tick,entry-stop)；TP1=entry+0.3*risk，TP2=entry+0.6*risk，TP3=entry+1.0*risk。後續K線 low<=stop 出場停損；high>=TP1/TP2/TP3 達標出場；同一根K線兩者都觸及時，以open較接近者為先。
空單：entry=max(open,close)；stop=max(e12,e18,dnDarkTop,high+ATR(10))；risk=max(tick,stop-entry)；TP1=entry-0.3*risk，TP2=entry-0.6*risk，TP3=entry-1.0*risk。後續K線 high>=stop 停損；low<=TP 達標；同根雙觸以open較近者為先。