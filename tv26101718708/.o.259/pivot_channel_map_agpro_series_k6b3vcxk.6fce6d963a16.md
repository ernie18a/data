【通道建構】
1. 轉折點：以左右各5根判定的高低轉折，高低交替，連續同類取較極端者。高點與前一高點比較，較高為HH，否則為LH；低點與前一低點比較，較高為HL，否則為LL。
2. 主要/次要：維持一組Major高、Major低。轉折超出Major高或低時成為Major（MHH、MLL等），否則為次要（mHH、mLL、mHL、mLH等）。收盤突破Major高或低時，把最近的次要反向轉折升級為Major。
3. 八族通道各取同類型最近兩個轉折點(x0,y0)、(x1,y1)，新轉折出現時更新：
   - 上升通道：Ext Up用LL轉折，Int Up用HL轉折，需y1>y0。
   - 下降通道：Ext Down用HH轉折，Int Down用LH轉折，需y1<y0。
   - Major用M轉折，Minor用m轉折。
4. origin線為連接兩點的直線，向右延伸。Diff為x0之後（排除最近5根）各根上升通道取max(high-線價)，下降通道取min(low-線價)。
5. 通道有效條件：x0之後所有收盤都在origin線正確一側，上升通道close>線價，下降通道close<線價。channel線=origin線+Diff。
6. 通道活著直到被突破。
7. 以下Major、Minor皆適用，下稱「當根origin價」「當根channel價」。ATR為ATR(14)。

【進出場判斷】僅在收盤確認的K棒、通道活著時判斷。做多訊號同時是空單出場，做空訊號同時是多單出場。

A. 突破（BREAK）：
- 上升通道：close<=當根origin價，做空；close>當根channel價，做多。
- 下降通道：close>=當根origin價，做多；close<當根channel價，做空。
- 突破當根記下突破價：channel突破記channel價，origin突破記origin價。通道隨即失效。

B. 反應（REACT，僅Major有標示）：
- 上升通道：low<當根origin價<close，做多。
- 下降通道：close<當根origin價<high，做空。
- 同族上次REACT已距今>=20根，且|當根origin價-上次REACT時的origin價|/ATR>=0.75（沒有上次時視為通過），才成立。

C. 突破後回測/收復（RETEST/RECLAIM，僅Major，預設）：
- 條件：突破後第1到第20根內、尚未觸發過，以突破價為基準，每次突破只觸發一次。
- 上升通道：low<=突破價且close>突破價，做多。
- 下降通道：high>=突破價且close<突破價，做空。

過濾：通道品質過濾預設關閉（Off），不限制判斷。