【共用算式】ATR21=ta.atr(21)。ER20=|c-c[20]|/Σ|Δc|(20根)。KAMA:ER34=|c-c[34]|/Σ|Δc|(34根),sc=(ER34*(2/3-2/31)+2/31)^2,kama=kama[1]+sc*(c-kama[1]),首根=c。slopeAtr=(kama-kama[5])/ATR21。半寬=ATR21*(1.05+0.65*(1-ER20)),upper=kama+半寬,lower=kama-半寬。bullRaw=c>kama且slopeAtr>=0.07且ER20>=0.24;bearRaw=c<kama且slopeAtr<=-0.07且ER20>=0.24。
【結構狀態S(1/0/-1)】前一根S=1:c<lower則連續計數+1,否則歸0,計數>=2時S=(bearRaw?-1:0),否則維持1。前一根S=-1:c>upper連續計數>=2時S=(bullRaw?1:0),否則維持-1。前一根S=0:bullRaw→1,bearRaw→-1,否則0。收盤時S由非1變1=結構轉多,由非-1變-1=結構轉空。
【楔形】取最近兩個已確認pivot high(左3右3,older=ph2、newer=ph1,含bar序號)與兩個pivot low(pl2、pl1)。highSlope=(ph1-ph2)/(bar差),lowSlope同理。以兩點連線外推到當根得upperNow/lowerNow;起點bar=max(ph2Bar,pl2Bar),起點寬度=兩線在起點bar之差,當前寬=upperNow-lowerNow,楔形年齡=現bar-起點<=55。下降楔形:ph1<ph2、pl1<pl2、lowSlope<0、highSlope<lowSlope、當前寬>0、起點寬>0、當前寬<=0.8*起點寬。上升楔形:ph1>ph2、pl1>pl2、highSlope>0、lowSlope>highSlope、其餘寬度條件相同。run=條件連續成立根數。下降楔形run恰等於4=COIL偏多(bullArmed);上升楔形run恰等於4=COIL偏空。

【做多】收盤確認,且距最近一次bullArmed<=12根,同時符合其一:(a)結構轉多;(b)下降楔形突破:前一根下降楔形run>=4,c>upperNow,且距上次下降楔形突破>=20根。

【做多(杯柄突破SIG9)】rim=highest(high,30)[1],base=lowest(low,30),depth=rim-base,handleHigh=highest(high,6)[1],handleLow=lowest(low,6),handleFrac=depth>0?(rim-handleLow)/depth:999。杯柄候選=S>=0且depth>=2*ATR21且c>=rim-0.22*depth且0<=handleFrac<=0.42且handleHigh>=rim-0.22*depth。候選連續根數為run;前一根run>=4且c>handleHigh且距上次SIG9>=20根→SIG9突破(偏多)。

【做多(STRONG+)】c>SMA200(c)且c上穿EMA9(c)且volume/SMA20(volume)>=1.1,該狀態由假變真的那根(原作用4H已收盤K棒計算)。

【做空】先算Gravity:相對量rel=volume/同一時刻的基準(同分鐘樣本EMA,alpha=2/21,>=5筆樣本,不足用EMA50(volume));無量用TR;限制0~20。loc=(2c-h-l)/(h-l)限-1~1(h=l則0)。effort=SMA24(rel);posE=SMA24(rel*max(loc,0));negE=SMA24(rel*max(-loc,0));imb=(posE-negE)/(posE+negE+1e-10)。r=ln(c/c[1]);net=|ln(c/c[24])|;signedNet=ln(c/c[24]);path=Σ|r|(24);exp=stdev(r,30)*sqrt(24);disp=net/(exp+1e-10);eff=clip(net/(path+1e-10),0,1);downDisp=Σmax(-r,0)(24)/(exp+1e-10);upDisp=Σmax(r,0)(24)/(exp+1e-10);ineff=max(1-eff,1e-10)。gravity=EMA3(ln(1+effort)-ln(disp+1e-10)+0.75*ln(ineff+1e-10));upG=ln(1+posE)-ln(upDisp+1e-10)+0.75*ln(ineff+1e-10);downG=ln(1+negE)-ln(downDisp+1e-10)+0.75*ln(ineff+1e-10);spread=upG-downG。gC=Δgravity,gA=ΔgC。robust z(300根)=(x-median)/(1.4826*MAD+1e-10),分別得zG、zEffort、zDisp、zGC(gC的z)。pressureNow=zEffort>1且zDisp<-0.75且zGC>0.2且eff<0.25;stored=過去8根(不含當根)zG最大值>1 或 過去8根任一根pressureNow。
分數(9項各1分):signedNet<0;eff>=0.42;Δeff>0;zGC<0;ΔzDisp>0;zEffort>-0.75;imb<0;spread>0;(stored 或 gA<=0)。
rawShort=各z與指標皆有值且signedNet<0且eff>=0.6且分數>=7。做空=收盤確認、rawShort為真且前一根rawShort為假、同根無SIG9、距上次做空或SIG9>=5根。

【做空(STRONG+)】c<SMA200(c)且c下穿EMA9(c)且volume/SMA20(volume)>=1.1,該狀態由假變真的那根。
【做空(其他標示)】結構轉空(S變-1);COIL偏空(上升楔形run=4)。另:COIL偏多(下降楔形run=4)與結構轉多亦指向做多。

【出場】進場價=訊號根收盤,一次只持一單,持倉中新訊號忽略。d=ATR14*0.75(四捨五入到最小跳動)。多單:初始停損=進場-d;TP1=進場+4/3*d;TP2=進場+2*d;TP3=進場+8/3*d;鎖利停損=進場+d/3。空單方向相反。自進場後下一根起逐根判斷:停損=(TP1已在先前某根觸及)?鎖利停損:初始停損;先判停損,多單low<=停損/空單high>=停損→出場;否則有利幅度=多單high-進場/空單進場-low,>=d*4/3記為TP1已觸及(鎖利從下一根起生效),>=d*8/3→TP3出場,否則持有根數(bar-進場bar)>=40→逾時出場。