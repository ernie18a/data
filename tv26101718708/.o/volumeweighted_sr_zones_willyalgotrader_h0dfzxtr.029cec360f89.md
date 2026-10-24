【指標】ATR=14期ATR(RMA)。Pivot高/低=左右各21根的極值,第21根後才確認。
【區域】確認Pivot高→壓力區,Pivot低→支撐區。新區 top/bot=pivot價±0.15*ATR(確認當根ATR)。若有同型、未被突破的區,其中點與新pivot價距離<=0.5*ATR就合併:top=max(top,price),bot=min(bot,price),touches+1;否則新建。
評分:volScore=有量時min(40,pivot根量/pivot根之前20根均量*20),無量為20。reactScore=min(30,max(pivot後第1~5根的反向最大幅度)/pivot根ATR*10),反向幅度對壓力區為pivot高-後續low,對支撐區為後續high-pivot低。base=vol+react+10。新區分數=min(100,base)。合併後分數=min(100,原分+0.3*base+0.5*min(20,sqrt(新touches)*4))。
區域維護:每根分數-0.05;分數<5、年齡>30天(換算成根數)、已突破超過60根就移除;區數超過8時移除最弱者。熱身期內不建區。
【做多/做空判斷】
1.突破做多:未被突破的壓力區,收盤>zoneTop且前一根收盤<=zoneTop。該區標記為已突破,記下其top/bot與突破根序號。
2.突破做空:未被突破的支撐區,收盤<zoneBot且前一根收盤>=zoneBot。該區標記為已突破,記下其top/bot與突破根序號。
3.回測做多:最近一次突破為向上,且距突破根2~30根內,同時滿足 low<=該突破區top、close>該區top、(close-low)>=0.5*ATR。
4.回測做空:最近一次突破為向下,且距突破根2~30根內,同時滿足 high>=該突破區bot、close<該區bot、(high-close)>=0.5*ATR。
5.以上均以收盤確認。突破/回測做多(空)訊號出現且空手時,以該根收盤價進場。同根多空同時出現時,取最近一次突破的方向。持倉中的新訊號忽略。
6.選用過濾(預設關閉),只限制突破訊號:量能下限(volume>=前20根均量*1.3)與量能上限(volume<=前20根均量*5),動能(high-low>=1.0*ATR)。回測可選只取突破後第一次回測。
【出場判斷】進場後逐根檢查,進場當根不檢查。
做多:SL=max(entry-1.5*ATR, 突破區bot-0.2*ATR)。做空:SL=min(entry+1.5*ATR, 突破區top+0.2*ATR)。R=|entry-SL|,ATR取進場根的值。
TP1/TP2/TP3=entry±1R/2R/3R(做多為加、做空為減),部位三等分,各在TP1、TP2、TP3出1/3。
出場:做多low<=SL,做空high>=SL,即全部出場;或觸及TP3出場。同一根同時觸及SL與任何TP,以SL優先。
保本:某根首次觸及TP1且該根未觸SL,下一根起SL移到entry價(做多low<=entry、做空high>=entry就出場)。