【K線分類】與前一根比較：內包=high<=前high且low>=前low；外包=high>前high且low<前low；2U=high>前high且low>=前low；2D=其餘(low<前low且high<=前high)。
【陷阱K做多/做空，預設進場來源】收盤確認時：2U且close<open→做空；2D且close>open→做多；close==open不算。進場價=該K close。
【STRAT型態觸發，另一進場來源(模式選STRAT Trigger時使用；Both時陷阱K優先，同根陷阱K方向覆蓋觸發方向)】收盤時依序(由新到舊)比對已收K分類序列，長型態優先，符合即建立待觸發setup：
做多序列(舊→新)：3-2U；2D-2U；2U-2U；3-2D-2U；3-1-2U；2D-1-2U；2U-1-2U；1-2D-2U。
做空序列：3-2D；2U-2D；2D-2D；3-2U-2D；3-1-2D；2U-1-2D；2D-1-2D；1-2U-2D。
(選用擴充：2U-2U-2U、2D-2U-2D-2U 做多，鏡像做空；單根外包K且close>前high做多、close<前low做空。)
setup K的high/low為觸發/停損邊。之後每根收盤K先計數+1：多單若close<setup low→作廢；空單若close>setup high→作廢；否則多單high>setup high(空單low<setup low)→觸發，多(空)進場價=該K close；否則計數>=3根→失效。同根又出現新型態則以新setup取代。
【錘子/射擊之星標記】K線不是內包且range>0：下影(min(open,close)-low)>=0.75*(high-low)→標多向三角；上影(high-max(open,close))>=0.75*(high-low)→標空向三角。
【過濾：趨勢狀態(預設開)】basis=EMA(close,21)；ATR100；外軌=basis±3*ATR100；內軌=basis±2*ATR100。狀態逐根收盤更新：多頭狀態時close下穿下內軌→中性；空頭狀態時close上穿上內軌→中性；再判斷close上穿上外軌→多頭(1)；close下穿下外軌→空頭(-1)。只有多頭狀態可做多，只有空頭狀態可做空，中性不進場。
【過濾：成交量(預設關)】volume>SMA(volume,20)*1.2，無量資料則略過。
【停損/風險】ATR=ATR(14)。做多SL=min(錨點-0.25*ATR, close-0.5*ATR)；做空SL=max(錨點+0.25*ATR, close+0.5*ATR)。陷阱K錨點=該K的low(多)/high(空)；觸發進場錨點=被突破的setup high(多)/setup low(空)。risk=|close-SL|，risk>3*ATR則不進場。
【出場】空手才可進場，進場後從下一根起逐根檢查。TP1/TP2/TP3=進場價±1R/2R/3R(R=risk)。多單：high>=TP1(首次觸及)→停損移到進場價(保本)，保本同根不被停損；high>=TP3→全部出場；low<=停損→出場；同根若首次觸及TP1或TP3則不算停損。空單全部鏡像(low<=TP、high>=停損)。