【符號】V(n)=前n根(不含當根)成交量均值；bull=close>open，bear=close<=open；body=|close-open|(下限最小跳動)；上影=high-max(open,close)；下影=min(open,close)-low；ATR=ATR(14)；EMA50=close的EMA(50)。

【量能K棒方向】
1. 力竭(做多)：bear且volume>=6*V(60)，close<EMA50-2*stdev(close,50)，body>2*SMA(body,50)。
2. 爆量頂(做空)：bull且volume>=6*V(60)，close>EMA50+2*stdev(close,50)，body>2*SMA(body,50)。
3. Peak：bull且volume>=6*V(10)且非爆量頂→做多；bear且volume>=6*V(10)且非力竭→做空。
4. Surge：bull且(volume>=2*V(10) 或 volume*(high-low)>=前10根該值最大)，且非Peak、非爆量頂→做多；bear同條件且非Peak、非力竭→做空。
5. Pulse：bull且volume>=1.5*V(10)，非Surge/Peak/爆量頂→做多；bear同條件，非Surge/Peak/力竭→做空。

【RSI】RSI(14)由下往上穿越15→做多；由上往下跌破85→做空。

【結構方向】
- 主結構：pivot high/low左右各5根確認。close突破最近未被突破的pivot high(且在pivot之後)→多方(BOS/CHoCH)，趨勢記為+1；close跌破最近未被突破的pivot low→空方，趨勢記為-1。突破後該pivot失效，且內部pivot清除。
- 內部結構：同法用左右各3根pivot，僅在該根無主結構突破時判斷，突破高→多(趨勢+1)，跌破低→空(趨勢-1)。
- 結構趨勢多=主趨勢==1或內部趨勢==1；空=主趨勢==-1或內部趨勢==-1。

【Stop Hunt】H20=前20根最高high，L20=前20根最低low。
- 做多：low<L20且close>L20，下影/body>=2，volume>2*V(20)，(high-low)>=ATR，且結構趨勢多。
- 做空：high>H20且close<H20，上影/body>=2，volume>2*V(20)，(high-low)>=ATR，且結構趨勢空。

【Stopping Volume】
- 做多：close<open，volume>2*V(20)，下影/body>=3，body<2*ATR，low[1]>low，low<VWAP(以close計、每日重置)；
- 做空：close>open，volume>2*V(20)，上影/body>=3，body<2*ATR，high[1]<high，high>VWAP。
- 同方向兩次訊號間隔需>5根。

【Volume Displacement】volume>=3*V(10)且close>=1.01*EMA(close,50)→做多；volume>=3*V(10)且close<=0.99*EMA(close,50)→做空。

【Liquidity Grab】body>1.5*SMA(body,30前一根)且volume>2*V(30)：
- 做多：low<前30根最低low，close>該低點，close>open；
- 做空：high>前30根最高high，close<該高點，close<open。

【Wick】EMA50=EMA(close,50)，volume>=1.5*V(10)，|close-EMA50|>=1%*EMA50：
- 做多：上影<=0.2*body且下影>=2*body；
- 做空：下影<=0.2*body且上影>=2*body。

【FVG方向】low>high[2](缺口>=5 ticks)→多方缺口；high<low[2](缺口>=5 ticks)→空方缺口。

【量能Pivot區】pivot low(左右各2根)且該pivot根volume>1.5*EMA(volume,20)→多方區；pivot high同條件→空方區。多方區被low跌破區下緣、空方區被high突破區上緣即失效。

【均線顏色】close>EMA(close,50)標多，否則標空。

【出場】以訊號K棒close為進場價：多單 high>=進場價*1.01停利，low<=進場價*0.99停損；空單 low<=進場價*0.99停利，high>=進場價*1.01停損。同一根兩邊都觸及視為停損。另有固定停損參考線：多單訊號K低點*(1-1%)，空單訊號K高點*(1+1%)。