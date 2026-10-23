【定義】K0=最新已收盤K棒,K1=前一根,依此類推。bull=收>=開,bear=收<開。range=高-低。上影=高-max(開,收),下影=min(開,收)-低。mid=(開+收)/2。bodypos=(mid-低)/range。tall(K)=該K的range>=1.5×其前14根range的平均。doji=|收-開|/range<=0.04。DJ(K)=doji且非長腳,長腳指上影>=3×前14根上影平均,或下影>=3×前14根下影平均,平均均算至該K的前一根。介於(x,a,b)=x嚴格介於a、b之間,不含端點。實體吞噬=max(開,收)>前者max且min(開,收)<前者min,皆為嚴格比較。
趨勢:n根形態以K_n(形態第一根之前一根)判斷,收>SMA(收,20)為U_n,否則為D_n。
Marubozu:陽線高=收或低=開,陰線低=收或高=開,即至少一側無影線。
同一根若多個形態成立,根數多者優先。

【做多】(皆在K0收盤判斷)
1 錘子:D1,折棄影線<=0.35×|實體|,使用影線>=2×|實體|。bodypos>0.5時折棄影線為上影、使用影線為下影,否則相反。
2 多頭吞噬:D2,K1 bear,K0 bull,K0實體吞噬K1實體。
3 最後吞噬底:D2,K1 bull,K0 bear,K0實體吞噬K1實體。
4 多頭孕線:D2,K1 bear且tall,K0 bull,K0開、收皆介於K1低與高,且K0實體不與K1實體相同或相反。
5 多頭孕十字:D2,K1 bear且tall,DJ(K0),K0高低皆介於K1低與高。
6 多頭十字星:D2,K1 bear且tall,DJ(K0),K0高<K1收。
7 倒錘:D2,K1 bear且tall,bodypos0<=0.5,下影0<=0.35×|實體0|,上影0>=2×|實體0|。
8 歸鴿:D2,K1 bear且tall,K0 bear,K0開、收皆介於K1開與收。
9 相同低價:D2,K1 bear且tall,K0 bear且非tall,收0=收1。
10 刺透:D2,K1 bear,K0 bull,開0<低1,收0>mid1,收0<開1。
11 多頭會合線:D2,K1 bear,K0 bull,二者皆tall,|收0-收1|<=0.05×range1(嚴格內)。
12 多頭分離線:U2,K1 bear,K0 bull,二者皆tall,開0介於開1±0.05×range1。
13 腹上:D2,K1 bear且tall,K0 bull,開0>=mid1且收0>=mid1。
14 鑷底:D2,K1與K0顏色相反,低0介於低1±0.025×range1。
15 下跌窗口:D2,高0<低1,視為做多。上升窗口:U2,低0>高1,同樣視為做多。
16 多頭踢腿:K1 bear且Marubozu,K0 bull且Marubozu,二者皆tall,低0>高1。
17 晨星/晨十字星:D3,K2與K0皆tall,K2 bear,K0 bull,max(開1,收1)<收2且<開0,收0>mid2。K1是否為十字皆可。
18 多頭棄嬰:D3,K2 bear,DJ(K1),K0 bull,高1<低2且高1<低0。
19 三內升:D3,K2 bear且tall,K1 bull,K0 bull,收1<=開2,開1>=收2,且不是開1=收2同時收1=開2,收0>收1。
20 三外升:D3,K2 bear,K1 bull,K0 bull,K1實體吞噬K2實體,收0>收1。
21 多頭三星:D3,DJ(K2)、DJ(K1)、DJ(K0)皆成立,max(開1,收1)<min(開2,收2)且<min(開0,收0)。
22 三白兵:D3,三根皆bull且tall,每根收在其range上端3%內((收-低)/range>=0.97),開1介於開2與收2,收1>收2,開0介於開1與收1,收0>收1。
23 棒狀夾心:D3,K2 bear,K1 bull且收1>開2,K0 bear,收0介於收2±0.1×|實體2|。
24 唯一三河底:D3,K2 bear且tall,K1 bear,開1介於開2與收2,低1<低2,K0 bull且非tall,收0<收1。
25 下跌缺口三法:D3,K2與K1皆tall,K2 bear,K1 bear且高1<低2,K0 bull,開0介於開1與收1,收0介於開2與收2。
26 下跌跳空助手(Downside Tasuki):D3,K2 bear,K1 bear且高1<低2,K0 bull,開0介於開1與收1,收0介於高1與低2。
27 多頭並列:U3,K2 bull,K1 bull且開1>收2,K0 bull且開0>收2,開0介於開1±0.15×實體1,收0介於收1±0.15×實體1。
28 多頭三線反擊:D4,K3 bear,K2 bear且低2<低3,K1 bear且低1<低2,K0 bull且tall,開0<收1,收0>開3。
29 隱蔽燕子:D4,K3、K2皆Marubozu bear且tall,K1 bear且開1<收2,|實體1|/上影1<=0.5,高1介於開2與收2,K0 range吞噬K1 range(高0>高1且低0<低1)且為Marubozu bear。
30 多頭突破:D5,K4 bear且tall,K0 bull且tall,K3 bear且開3<收4。令hi2=max(開2,收2),lo2=min(開2,收2),須lo2<收3且hi2<收4。K1 bear,收1<lo2,開1<收4,收0>開3,收0<收4。
31 梯底:D5,K4、K3、K2皆tall,K4 bear,K3 bear且開3<開4且收3<收4,K2 bear且開2<開3且收2<收3,K1 bear且上影1/range1介於0.5與0.9,K0 bull且開0>開1。
32 下降三法:D5,K4 bear且tall,K0 bear且tall,收0<收4。K3 bull,開3>低4,收3<高4。K2 hi2>收3,lo2>開3,hi2<高4。K1 bull,開1>lo2,收1>hi2,收1<高4。
33 母子/其餘:Takuri線(D1,bodypos>0.5,下影>=3×|實體|,上影<=0.35×|實體|)同視為做多。
34 上漲缺口三法:U3,K2與K1皆tall,K2 bull,K1 bull且低1>高2,K0 bear,開0介於開1與收1,收0介於開2與收2,視為做多。
35 上漲跳空助手(Upside Tasuki):U3,K2 bull,K1 bull且低1>高2,K0 bear,開0介於開1與收1,收0介於低1與高2,視為做多。
36 多頭分離/突破類另見上列。
37 上升三法:U5,K4 bull且tall,K0 bull且tall,收0>收4。K3 bear,收3>低4,開3<高4。令hi2、lo2同上,須hi2<開3,lo2>低4。K1 bear,開1<hi2,收1>低4。
38 持有墊(Mat Hold):U5,K4 bull且tall,K3 bear且收3>收4,hi2<開3,K1 bear且開1<hi2,K0 bull且tall,收0>max(高4,高3,高2,高1),且收3、lo2、收1皆>低4。

【做空】
1 空頭吞噬:U2,K1 bull,K0 bear,K0實體吞噬K1實體。
2 最後吞噬頂:U2,K1 bear,K0 bull,K0實體吞噬K1實體。
3 烏雲罩頂:U2,K1 bull且tall,K0 bear,開0>高1,收0<mid1,收0>開1。
4 空頭孕線:U2,K1 bull且tall,K0 bear,K0開、收皆介於K1低與高,且K0實體不與K1實體相同或相反。
5 空頭孕十字:U2,K1 bull且tall,DJ(K0),K0高低皆介於K1低與高。
6 空頭十字星:U2,K1 bull且tall,DJ(K0),低0>收1。
7 吊人:U1,bodypos>0.5,上影<=0.35×|實體|,下影>=2×|實體|。
8 流星:U1,bodypos<=0.5,下影<=0.35×|實體|,上影>=2×|實體|。
9 雙線流星:U2,K1 bull,bodypos0<=0.5,下影0<=0.35×|實體0|,上影0>=3×|實體0|。
10 空頭會合線:U2,K1 bull,K0 bear,二者皆tall,|收0-收1|<=0.05×range1。
11 空頭分離線:D2,K1 bull,K0 bear,二者皆tall,開0介於開1±0.05×range1。
12 腹下:U2,K1 bull且tall,K0 bear,開0<=mid1且收0<=mid1。
13 鑷頂:U2,K1與K0顏色相反,高0介於高1±0.025×range1。
14 空頭踢腿:K1 bear且Marubozu,K0 bull且Marubozu,二者皆tall,低0>高1為做多;反之K1 bull且Marubozu,K0 bear且Marubozu,二者皆tall,高0<低1為做空。
15 夜星/夜十字星:U3,K2與K0皆tall,K2 bull,K0 bear,min(開1,收1)>收2且>開0,收0<mid2。K1是否為十字皆可。
16 空頭棄嬰:U3,K2 bull,DJ(K1),K0 bear,低1>高2且低1>高0。
17 三內降:U3,K2 bull且tall,K1 bear,K0 bear,收1>=開2,開1<=收2,且不是收1=開2同時開1=收2,收0<收1。
18 三外降:U3,K2 bull,K1 bear,K0 bear,K1實體吞噬K2實體,收0<收1。
19 空頭三星:U3,DJ(K2)、DJ(K1)、DJ(K0)皆成立,min(開1,收1)>max(開2,收2)且>max(開0,收0)。
20 三隻烏鴉:U3,三根皆bear且tall,每根收在其range下端3%內((收-低)/range<=0.03),開1介於開2與收2,低1<低2,開0介於開1與收1,低0<低1。
21 雙烏鴉:U3,K2 bull且tall,K1 bear且收1>收2,K0 bear,開0介於開1與收1,收0介於開2與收2。
22 上漲跳空雙烏鴉:U3,K2 bull且tall,K1 bear且收1>收2,K0 bear,K0實體吞噬K1實體,收0>收2。
23 前進受阻:U3,三根皆bull,開1介於開2與收2,上影1>上影2,開0介於開1與收1,上影0>上影1。
24 崩塌十字:U3,K2 bull,DJ(K1),高1<低2,K0 bear,低1>高0。
25 醞釀:U3,K2 bull且tall,K1 bull且tall且收1>收2,K0 bull,開0介於(收1+0.1×實體1)與收1,實體0<=(實體2+實體1)/2×0.33。
26 空頭並列:D3,K2 bear,K1 bull且收1<收2,K0 bull且收0<收2,開0介於開1±0.15×實體1,收0介於收1±0.15×實體1。
27 空頭三線反擊:U4,K3 bull,K2 bull且高2>高3,K1 bull且高1>高2,K0 bear且tall,開0>收1,收0<開3。
28 空頭突破:U5,K4 bull且tall,K0 bear且tall,K3 bull且開3>收4,hi2>收3且lo2>收4,K1 bull,收1>hi2,開1>開4,收0>收4,收0<開3。
29 下跌跳空助手以外的上升窗口/下跌窗口方向:下降窗口已列於做多第15項;下跌窗口不另列做空。
30 下跌缺口類:D5,見做空第31項。
31 下降三法以外:下跌跳空窗口(高0<低1,D2)視為做空,與做多第15項對應。
32 下降三法:見做多第32項,該項方向為做空。