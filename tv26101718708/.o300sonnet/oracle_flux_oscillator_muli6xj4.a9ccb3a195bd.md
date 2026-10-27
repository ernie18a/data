【共用指標】
1) Heikin Ashi：haC=(O+H+L+C)/4；haO 首根=(O+C)/2，之後=(haO[1]+haC[1])/2；haH=max(H,haO,haC)；haL=min(L,haO,haC)；src=(haH+haL+haC)/3。
2) Flux Wave：esa=EMA(src,9)；dev=EMA(|src-esa|,9)；adapt=0.015*(1+ATR14/src*0.15)。ciW=(src-esa)/(adapt*dev)。vwm=VWMA(src,9)，devV=EMA(|src-vwm|,9)，ciV=(src-vwm)/(adapt*devV)。body=(C-O)/(H-L)，mfr=body*volume*min(sqrt(volume/SMA(volume,9)),2)，ciM=0.75*mfr/(adapt*EMA(|mfr|,9))。tW、tV、tM 分別為 ciW、ciV、ciM 的 EMA(12)。acc=EMA(ciW-ciW[1],3)。primary=clamp((1*tW+0.8*tV+0.6*tM)/2.4+0.22*acc,-160,160)；signal=SMA(primary,3)。引擎數 bull=tW、tV、tM 中大於0的個數，bear=小於0的個數。
3) mfNorm=SMA((C-O)/(H-L)*volume,14)/SMA(volume,14)*100；mfIn=mfNorm>=0，mfOut=mfNorm<0。

【1. Flux Wave 交叉】
做多：primary 上穿 signal。
做空：primary 下穿 signal。

【2. 背離菱形 ◆（regular divergence）】
signal 的樞紐：pivotlow/pivothigh(signal,左4,右2)，樞紐出現在 2 根之前。primary 另算一組樞紐(4,2)。樞紐間隔需 10~100 根。
做多：新的 signal 低點樞紐，其對應 K 線 low 低於前一個 signal 低點樞紐的 low 至少 0.38*ATR14，且新 signal 值高於前一個 signal 低點值至少 5.75；並且符合下列任一條件：(a) 同方式的 primary 低點背離也成立（近3根內），(b) 該樞紐 signal<=-80，(c) 當根 signal<=-60，(d) mfIn。
做空：新的 signal 高點樞紐，其 high 高於前一個 signal 高點樞紐的 high 至少 0.38*ATR14，且新 signal 值低於前一個高點值至少 5.75；並且符合下列任一條件：(a) 同方式的 primary 高點背離成立，(b) 樞紐 signal>=80，(c) 當根 signal>=60，(d) mfOut。
同方向兩個菱形之間至少隔 10 根。

【3. TOP / BOTTOM 反轉】
武裝 TOP：上述 signal 高點背離成立，且近 6 根最高價 >= 近 48 根最高價，同時（若有鎖定）近 6 根最高價 > 鎖定價。記下 level=近6根最高價，並記下武裝的那一根。
解除武裝：high > level+0.1*ATR14，或距武裝超過 8 根。
觸發 TOP（做空）：處於武裝中，且 primary<signal、bear 引擎數>=2、(primary 下穿 signal 或 primary<primary[1])，且 close < 前一根為止的前 3 根最低價的最低值。
觸發後解除武裝，並把鎖定價設為 level。之後要等 low 比鎖定價低至少 4*ATR14 才解除鎖定，BOTTOM 觸發也會清除該鎖定。
BOTTOM（做多）完全鏡像：signal 低點背離，近6根最低價 <= 近48根最低價，low < level-0.1*ATR14 失效，primary>signal、bull 引擎數>=2、(primary 上穿 signal 或 primary>primary[1])，且 close > 前3根最高價的最高值（不含當根）。鎖定價改為 BOTTOM 的 level，需 high 比鎖定價高至少 4*ATR14 才解除。