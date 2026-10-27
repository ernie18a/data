ATR=ATR(14)。
【做多】
1. 多方FVG區：low > high[2]，且 low-high[2] >= 0.15*ATR，且中間K(close[1]>open[1])實體 abs(close[1]-open[1]) >= 0.6*ATR。區間=[high[2], low]。之後(生成後第2根起)K線low<=區間上緣且close>=區間中點→偏多(支撐)。close<區間中點→失效；close<區間下緣→移除。
2. 多方懸浮塊(SB)：連續3根陽線，open[1]>close[2] 且 open>close[1]，且 open-close[2] >= 0.15*ATR。區間=[close[2], open]，用法同多方FVG。
3. 多方OB：以pivot(左5右3)取最近swing high；close首次收盤突破該高點(每個swing只算一次)。OB=自該swing high到現在(最多50根)內收盤最低的陰線(收盤相同取實體大者)，並向前合併連續且實體介於錨點0.5~2倍的陰線(最多4根)，區間=[該組最低收盤, 該組第一根open]，實體高度需>=0.25*ATR。突破K之後3根內需有多方FVG(其起點晚於OB K)才成立。成立後K線low<=OB上緣→偏多(支撐)。
4. 空方OB被close<該組整根最低價(wick到wick)擊穿→轉為多方Breaker？不；空方OB被close>該組最高價擊穿→變多方Breaker，區間=整根K高低；之後low<=Breaker上緣→偏多；close<Breaker下緣→移除。
5. 偏多(過濾/背景)：當週(1H以上)或當日(1H以下)累積高低點中點為均衡，close<均衡→偏多。
【做空】(鏡像)
1. 空方FVG：high<low[2]，low[2]-high>=0.15*ATR，中間K陰線且實體>=0.6*ATR。區間=[high, low[2]]。high>=區間下緣且close<=區間中點→偏空(壓力)；close>中點失效；close>上緣移除。
2. 空方SB：連續3根陰線，open[1]<close[2]且open<close[1]，close[2]-open>=0.15*ATR；區間=[open, close[2]]。
3. 空方OB：close首次跌破最近swing low(pivot 左5右3)；OB=自該swing low到現在(最多50根)內收盤最高的陽線，向前合併相似實體連續陽線(最多4根)，區間=[該組第一根open, 該組最高收盤]，高度>=0.25*ATR；突破後3根內需有空方FVG。high>=OB下緣→偏空。
4. 多方OB被close<該組整根最低價擊穿→變空方Breaker，區間=整根K高低；之後high>=Breaker下緣→偏空；close>Breaker上緣→移除。
5. 偏空背景：close>當週/當日高低點中點。
【出場】
持多：close<所用FVG/SB區間中點(或下緣)、close<OB整根最低價、close>空方Breaker上緣為反向；持空鏡像：close>FVG/SB區間中點(或上緣)、close>OB整根最高價、close<多方Breaker下緣。