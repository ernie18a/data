【1 EMA回測進場】指標：EMA12(close)；RSI14；MACD(12,26,9)柱狀圖H。
・多方準備：近10根（含當根）內曾出現RSI<30，且近10根內曾出現H>H[1]。空方準備：近10根內曾出現RSI>70，且近10根內曾出現H<H[1]。
・突破：多=open<EMA且close>EMA；空=open>EMA且close<EMA。
・待命時，若出現突破、對應方向準備成立、且距上次進場超過20根，就記下當根EMA值為基準價L，並記止損價S。多方S=近20根最低low，空方S=近20根最高high。
・進場（之後每根檢查，含突破當根）：多=low<=L+EMA×0.1%且close>L，就在close做多；空=high>=L-EMA×0.1%且close<L，就在close做空。
・取消待命：多方close<L-EMA×0.1%，空方close>L+EMA×0.1%，或突破後超過15根仍未進場。
・出場，進場價E、風險R=|E-S|：多方low<=S停損，同根先判停損；high>=E+1.7R停利。空方high>=S停損；low<=E-1.7R停利。持倉滿100根仍未出場就平倉。

【2 流動性掃蕩】取最近一個已確認的pivot high（左右各5根）為PH，pivot low為PL。起始值為第一根的high/low。
・做空：high>PH且close<PH且high>high[1]，且自上次該方向訊號後已出現新的pivot high。
・做多：low<PL且close>PL且low<low[1]，且自上次該方向訊號後已出現新的pivot low。

【3 平滑軌跡趨勢（多空顏色）】atr=ATR(100)。ST=supertrend(因子6, ATR週期64)。up=HMA(high,27)+2×atr，dn=HMA(low,27)-2×atr。hh=最高close(32)+atr，ll=最低close(32)+atr。
T=close>ST ? (3×ST+dn+ll)/5 : (3×ST+up+hh)/5。close>T 視為多方（綠），否則視為空方（紅）。

【4 SFP假突破】
・多方候選：low>low[1]且low[1]<low[2]，且前一根volume>SMA(volume,21)。候選價=前5根最低low（若不是low[1]，low[1]也列入候選）。
・空方候選：high<high[1]且high[1]>high[2]，且前一根volume>SMA(volume,21)。候選價=前5根最高high（若不是high[1]，high[1]也列入候選）。
・多方成立：之後某根low<候選價且close>候選價，且volume>SMA(volume,21)，就做多。若close<候選價就移除候選。空方成立：high>候選價且close<候選價，且量同樣大於均量，就做空。若close>候選價就移除候選。

【5 FVG缺口】
・多方：low>high[2]且close[1]>low[1]。
・空方：low[2]>high且close[1]<high[1]。