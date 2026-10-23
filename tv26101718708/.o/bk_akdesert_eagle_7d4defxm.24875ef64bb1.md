【共用計算】σ(Yang-Zhang,n=20)：OR=ln(open/前收),CO=ln(close/open),HO=ln(high/open),HC=ln(high/close),LO=ln(low/open),LC=ln(low/close)；k=0.34/(1.34+21/19)；σ=sqrt(max(var20(OR)+k*var20(CO)+(1-k)*sma20(HO*HC+LO*LC),0))。

【單一尺度趨勢】週期p，5個區塊i=0..4：hi_i=high在距今i*p根前的最近p根最高價，lo_i=low同窗最低價，gm_i=sqrt(hi_i*lo_i)，cx_i=當前索引-i*p-floor(p/2)。若gm0==gm1則方向為0；否則pd=gm0>gm1?+1:-1，seg=1，i從1到3：若gm_i與gm_(i+1)的方向等於pd則seg=i+1，否則中斷。角度=atan((ln gm0-ln gm_seg)/σ/(cx0-cx_seg))換算成度；|角度|<=0.5則dir=0，否則dir=pd。

【主通道(p=13)】取區塊0..seg：HH=最大hi(位置xHH)、LH=最小hi(xLH)、HL=最大lo(xHL)、LL=最小lo(xLL)，位置用cx。通道線在ln價格上線性外插到當前索引：t時價=exp(ln p1+(ln p2-ln p1)*(t-x1)/(x2-x1))。dir=+1：上緣過(xLH,LH)、(xHH,HH)，下緣過(xLL,LL)、(xHL,HL)。dir=-1：上緣過(xHH,HH)、(xLH,LH)，下緣過(xHL,HL)、(xLL,LL)。dir=0：上緣=HH，下緣=LL。pos=(ln close-ln 下緣)/(ln 上緣-ln 下緣)。distUp=|ln close-ln 上緣|/σ，distDn=|ln close-ln 下緣|/σ。

【突破/回測狀態機】狀態有INSIDE、BO_UP、RT_UP、BO_DN、RT_DN。每根先看：若dir≠前一根dir且前一根dir≠0，則狀態重置為INSIDE並結束本根判斷。否則：
INSIDE：pos>1→BO_UP(做多)；pos<0→BO_DN(做空)。
BO_UP：distUp>=1則記distanced；pos<0→轉BO_DN(翻空)；pos<=1→回INSIDE(假突破，多單出場)；distanced且distUp<1→RT_UP。
RT_UP：pos<0→BO_DN(翻空)；pos<=1→INSIDE(多單出場)；distUp>=1→BO_UP並標記已確認(回測後續漲，多方確認)。
BO_DN：distDn>=1則記distanced；pos>1→BO_UP(翻多)；pos>=0→INSIDE(空單出場)；distanced且distDn<1→RT_DN。
RT_DN：pos>1→BO_UP(翻多)；pos>=0→INSIDE(空單出場)；distDn>=1→BO_DN並標記已確認(空方確認)。

【級聯反轉】用p=3,7,13的dir加總為fastNet，p=19,29,47的dir加總為slowNet，各取正負號fSign、sSign。fSign=+1且sSign=-1→看多反轉(做多)；fSign=-1且sSign=+1→看空反轉(做空)。

【壓縮釋放】寬度=(ln 上緣-ln 下緣)/σ(主通道)；ratio=寬度/寬度的50期均值；壓縮=ratio<0.8，擴張=ratio>1.2。前一根壓縮且本根擴張，且主通道dir=+1且fSign=+1→做多；前一根壓縮且本根擴張，且dir=-1且fSign=-1→做空。