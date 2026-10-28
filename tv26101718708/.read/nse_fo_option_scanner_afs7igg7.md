# NSE F&O Option Scanner

- url: https://www.tradingview.com/script/Afs7iGg7-NSE-F-O-Option-Scanner/
- type: indicator
- pine_id: PUB;256dedca51b944009611209e439fbee5
- version: 1.0

## Description

How the Scoring Works (0–5 points)
Each condition adds 1 point:
✅ 8 EMA above 20 EMA (trend direction)
✅ OI Proxy confirms direction (Volume + Price interpretation)
✅ Sector index trading above its 20 EMA
✅ RSI not in extreme zone (not overbought for CE / not oversold for PE)
✅ Volume spike ≥ 1.5× the 20-bar average
Score ≥ 4 → High conviction signal → BUY CE or BUY PE label appears on chart
Score 3 → Weak setup — wait for confirmation
Score < 3 → No trade
Dashboard Shows (top-right panel)
🔹 8/20 EMA trend + gap %
🔹 OI Proxy: Long Buildup / Short Buildup / Short Covering / Long Unwinding
🔹 Sector trend vs 20 EMA
🔹 Relative Strength vs sector (20-bar)
🔹 RSI (14) with overbought/oversold alert
🔹 MACD Histogram direction
🔹 Volume — Normal or Spike with multiplier
🔹 Setup Score (0–5)
🔹 Recommendation — 🟢 BUY CALL (CE) / 🔴 BUY PUT (PE) / ⏳ NO SETUP
🔹 Auto Strike Suggestion — ATM + 1 OTM (calculated from CMP)
🔹 Entry (CMP), Stop Loss, Target 1 (1:2), Target 2 (1:3)
🔹 ATR with volatility %
🔹 News reminder
How to Use

Add to any NSE F&O stock on Daily or 1H timeframe
Change the Sector Index input to match the stock — NIFTY_BANK, NIFTY_IT, NIFTY_AUTO, NIFTY_PHARMA, NIFTY_FMCG, NIFTY_METAL etc.
Read the dashboard — Score ≥ 4 = high conviction setup
Always verify news and catalyst on NSE website or Screener.in before entering
Set alerts using the 5 built-in alert conditions

Built-in Alerts
🟢 Strong BUY CE — EMA cross + OI + Sector all aligned (score ≥ 4)
🔴 Strong BUY PE — EMA cross + OI + Sector all aligned (score ≥ 4)
📊 EMA Bull Cross — 8 EMA crossed above 20 EMA
📊 EMA Bear Cross — 8 EMA crossed below 20 EMA
📈 Volume Spike in Bull Trend
Note on OI Data
For real open interest data, switch to the futures chart (e.g. NSE:RELIANCE1!). On equity charts this script uses Volume + Price direction as an OI proxy, which closely mirrors standard OI interpretation (Long Buildup, Short Buildup, Short Covering, Long Unwinding).
Settings
All parameters are adjustable — EMA lengths, ATR multiplier, Risk:Reward ratio, OI proxy sensitivity, and sector index. Tooltips explain each input.
⚠️ For educational and analysis purposes only. Not financial advice. Always use proper risk managemen

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════╗
// ║       NSE F&O Option Scanner — by Karthik                          ║
// ║  All-in-one options trade setup for NSE F&O stocks.                ║
// ║  8/20 EMA + OI Proxy + Sector + RSI + MACD + Volume               ║
// ║  Score ≥4 → BUY CE / BUY PE with Strike, SL & Targets             ║
// ║  Version : 1.0   |   Author : Karthik                             ║
// ╚══════════════════════════════════════════════════════════════════════╝

indicator("NSE F&O Option Scanner by Karthik | 8/20 EMA + OI + Sector",
         shorttitle       = "FnO[K]",
         overlay          = true,
         max_lines_count  = 100,
         max_labels_count = 100)

// ── INPUTS ───────────────────────────────────────
fastLen   = input.int(8,    "Fast EMA Length",      minval=1,   group="📈 EMA Settings",   tooltip="Default 8. Standard for intraday & swing options.")
slowLen   = input.int(20,   "Slow EMA Length",      minval=1,   group="📈 EMA Settings",   tooltip="Default 20. Price above 20 EMA = bullish bias.")
atrLen    = input.int(14,   "ATR Length",           minval=1,   group="🛡️ Risk",           tooltip="Used to calculate SL and Targets dynamically.")
atrMult   = input.float(1.5,"SL ATR Multiplier",    minval=0.5, group="🛡️ Risk", step=0.1, tooltip="SL = Entry ± (ATR × multiplier). 1.5 = standard.")
rrRatio   = input.float(2.0,"Risk:Reward Ratio",    minval=1.0, group="🛡️ Risk", step=0.5, tooltip="Target 1 = Entry ± (SL distance × R:R).")
oiLen     = input.int(5,    "OI Proxy Avg Bars",    minval=2,   group="📊 OI Proxy",       tooltip="Bars to average volume for OI proxy.")
sectorSym = input.symbol("NSE:NIFTY_IT","Sector Index", group="🏦 Sector",                 tooltip="NIFTY_BANK / NIFTY_IT / NIFTY_AUTO / NIFTY_PHARMA etc.")
showDash  = input.bool(true,"Show Dashboard",               group="🖥️ Display")
showEMAs  = input.bool(true,"Show EMAs",                    group="🖥️ Display")
showSigs  = input.bool(true,"Show BUY CE / BUY PE Labels",  group="🖥️ Display")

// ── EMAs ─────────────────────────────────────────
fastEMA   = ta.ema(close, fastLen)
slowEMA   = ta.ema(close, slowLen)
emaBull   = fastEMA > slowEMA
bullCross = ta.crossover(fastEMA,  slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)
emaGapPct = (fastEMA - slowEMA) / slowEMA * 100

// ── OI PROXY (Volume + Price) ─────────────────────
volAvg    = ta.sma(volume, oiLen)
volRising = volume > volAvg
priceUp   = close > close[1]

oiAnalysis = volRising  and priceUp     ? "Long Buildup"   :
             volRising  and not priceUp ? "Short Buildup"  :
             not volRising and priceUp  ? "Short Covering" :
             "Long Unwinding"

oiForBull = oiAnalysis == "Long Buildup"  or oiAnalysis == "Short Covering"
oiForBear = oiAnalysis == "Short Buildup" or oiAnalysis == "Long Unwinding"

// ── SECTOR ───────────────────────────────────────
secClose  = request.security(sectorSym, timeframe.period, close)
secEMA20  = request.security(sectorSym, timeframe.period, ta.ema(close, 20))
secBull   = secClose > secEMA20
rsStrong  = (close / close[20] - 1) > (secClose / secClose[20] - 1)

// ── MOMENTUM & VOLUME ────────────────────────────
rsi                        = ta.rsi(close, 14)
[macdLine, sigLine, macdH] = ta.macd(close, 12, 26, 9)
atrVal                     = ta.atr(atrLen)
volSMA                     = ta.sma(volume, 20)
volSpike                   = volume > volSMA * 1.5

// ── SCORING (0–5) ────────────────────────────────
bullPts = (emaBull     ? 1 : 0) + (oiForBull  ? 1 : 0) + (secBull     ? 1 : 0) + (rsi < 65 ? 1 : 0) + (volSpike ? 1 : 0)
bearPts = (not emaBull ? 1 : 0) + (oiForBear  ? 1 : 0) + (not secBull ? 1 : 0) + (rsi > 35 ? 1 : 0) + (volSpike ? 1 : 0)

strongBull = bullPts >= 4 and bullCross
strongBear = bearPts >= 4 and bearCross
activeBull = bullPts >= 3 and emaBull
activeBear = bearPts >= 3 and not emaBull

// ── SL / TARGETS ─────────────────────────────────
longSL  = close - atrVal * atrMult
longT1  = close + atrVal * atrMult * rrRatio
longT2  = close + atrVal * atrMult * rrRatio * 1.5
shortSL = close + atrVal * atrMult
shortT1 = close - atrVal * atrMult * rrRatio
shortT2 = close - atrVal * atrMult * rrRatio * 1.5

// ── STRIKE (ATM + 1 OTM) ─────────────────────────
strikeStep    = close > 5000 ? 100 : close > 2000 ? 50 : close > 500 ? 20 : close > 100 ? 10 : 5
atmStrike     = math.round(close / strikeStep) * strikeStep
otmCallStrike = atmStrike + strikeStep
otmPutStrike  = atmStrike - strikeStep

// ── PLOTS ────────────────────────────────────────
p1 = plot(showEMAs ? fastEMA : na, "8 EMA",  color=color.orange,            linewidth=2)
p2 = plot(showEMAs ? slowEMA : na, "20 EMA", color=color.new(color.blue,0), linewidth=2)
fill(p1, p2, color = emaBull ? color.new(color.green,88) : color.new(color.red,88))

plotshape(showSigs and bullCross,  "EMA ▲",  shape.triangleup,   location.belowbar, color.green,              size=size.small,  text="▲EMA")
plotshape(showSigs and bearCross,  "EMA ▼",  shape.triangledown, location.abovebar, color.red,                size=size.small,  text="▼EMA")
plotshape(showSigs and strongBull, "BUY CE", shape.labelup,      location.belowbar, color.new(color.green,0), size=size.normal, text="BUY CE", textcolor=color.white)
plotshape(showSigs and strongBear, "BUY PE", shape.labeldown,    location.abovebar, color.new(color.red,0),   size=size.normal, text="BUY PE", textcolor=color.white)

// ── DASHBOARD ────────────────────────────────────
if showDash and barstate.islast
    var table t = table.new(position.top_right, 2, 18,
         bgcolor=color.new(color.black,5), border_color=color.new(color.gray,40),
         border_width=1, frame_color=color.white, frame_width=2)

    cG  = color.new(color.green, 0)
    cR  = color.new(color.red,   0)
    cY  = color.yellow
    cW  = color.white
    cGr = color.gray
    cH  = color.new(color.navy, 15)
    cHR = color.new(color.maroon, 40)

    table.cell(t,0,0,"🎯 NSE F&O OPTION SETUP",             text_color=cY,  bgcolor=cH, text_size=size.small, text_halign=text.align_center)
    table.cell(t,1,0,syminfo.ticker+" | "+timeframe.period, text_color=cY,  bgcolor=cH, text_size=size.small, text_halign=text.align_center)

    emaLbl = emaBull ? "BULLISH ✅  gap "+str.tostring(math.round(emaGapPct,2))+"%" : "BEARISH 🔴  gap "+str.tostring(math.round(emaGapPct,2))+"%"
    table.cell(t,0,1,"8 / 20 EMA",          text_color=cW,           text_size=size.small)
    table.cell(t,1,1,emaLbl,                 text_color=emaBull?cG:cR,text_size=size.small)

    table.cell(t,0,2,"OI Proxy (Vol+Price)", text_color=cW,                            text_size=size.small)
    table.cell(t,1,2,oiAnalysis+(oiForBull?" ✅":" 🔴"), text_color=oiForBull?cG:oiForBear?cR:cGr, text_size=size.small)

    table.cell(t,0,3,"Sector Trend",         text_color=cW,           text_size=size.small)
    table.cell(t,1,3,secBull?"BULLISH ✅":"BEARISH 🔴", text_color=secBull?cG:cR, text_size=size.small)

    table.cell(t,0,4,"RS vs Sector (20)",    text_color=cW,           text_size=size.small)
    table.cell(t,1,4,rsStrong?"OUTPERFORMING ✅":"UNDERPERFORMING ⚠️", text_color=rsStrong?cG:cGr, text_size=size.small)

    rsiLbl = str.tostring(math.round(rsi,1))+(rsi>70?" OB ⚠️":rsi<30?" OS ✅":" Neutral")
    table.cell(t,0,5,"RSI (14)",             text_color=cW,                 text_size=size.small)
    table.cell(t,1,5,rsiLbl,                 text_color=rsi>70?cR:rsi<30?cG:cW, text_size=size.small)

    table.cell(t,0,6,"MACD Hist",            text_color=cW,           text_size=size.small)
    table.cell(t,1,6,str.tostring(math.round(macdH,2))+(macdH>0?" ✅":" 🔴"), text_color=macdH>0?cG:cR, text_size=size.small)

    volLbl = volSpike ? "SPIKE ✅ "+str.tostring(math.round(volume/volSMA,1))+"x avg" : "Normal"
    table.cell(t,0,7,"Volume",               text_color=cW,             text_size=size.small)
    table.cell(t,1,7,volLbl,                 text_color=volSpike?cG:cGr,text_size=size.small)

    scoreDir = activeBull ? "BULL "+str.tostring(bullPts)+"/5 🟢" : activeBear ? "BEAR "+str.tostring(bearPts)+"/5 🔴" : "MIXED – WAIT ⏳"
    table.cell(t,0,8,"Setup Score",          text_color=cW, bgcolor=color.new(color.navy,35), text_size=size.small)
    table.cell(t,1,8,scoreDir,               text_color=activeBull?cG:activeBear?cR:cY, bgcolor=color.new(color.navy,35), text_size=size.small)

    recLbl = activeBull and bullPts>=4 ? "🟢 BUY CALL (CE)" : activeBear and bearPts>=4 ? "🔴 BUY PUT (PE)" : activeBull ? "🟡 Weak BUY CE" : activeBear ? "🟡 Weak BUY PE" : "⏳ NO SETUP"
    recClr = activeBull and bullPts>=4 ? cG : activeBear and bearPts>=4 ? cR : cY
    table.cell(t,0,9,"RECOMMENDATION",       text_color=cY,    bgcolor=cHR, text_size=size.small)
    table.cell(t,1,9,recLbl,                 text_color=recClr,bgcolor=cHR, text_size=size.small)

    strikeLbl = activeBull ? "ATM CE: "+str.tostring(atmStrike)+"  OTM: "+str.tostring(otmCallStrike) : activeBear ? "ATM PE: "+str.tostring(atmStrike)+"  OTM: "+str.tostring(otmPutStrike) : "–"
    table.cell(t,0,10,"Strike Suggest",      text_color=cW,text_size=size.small)
    table.cell(t,1,10,strikeLbl,             text_color=cY,text_size=size.small)

    table.cell(t,0,11,"Entry (CMP)",         text_color=cW,text_size=size.small)
    table.cell(t,1,11,str.tostring(math.round(close,2)), text_color=cW,text_size=size.small)

    slVal = activeBull ? longSL : activeBear ? shortSL : na
    table.cell(t,0,12,"Stop Loss",           text_color=cW,text_size=size.small)
    table.cell(t,1,12,na(slVal)?"–":str.tostring(math.round(slVal,2)), text_color=cR,text_size=size.small)

    t1Val = activeBull ? longT1 : activeBear ? shortT1 : na
    table.cell(t,0,13,"Target 1  (1:"+str.tostring(rrRatio)+")", text_color=cW,text_size=size.small)
    table.cell(t,1,13,na(t1Val)?"–":str.tostring(math.round(t1Val,2)), text_color=cG,text_size=size.small)

    t2Val = activeBull ? longT2 : activeBear ? shortT2 : na
    table.cell(t,0,14,"Target 2  (1:"+str.tostring(rrRatio*1.5)+")", text_color=cW,text_size=size.small)
    table.cell(t,1,14,na(t2Val)?"–":str.tostring(math.round(t2Val,2)), text_color=color.lime,text_size=size.small)

    table.cell(t,0,15,"ATR / Volatility",    text_color=cW,text_size=size.small)
    table.cell(t,1,15,str.tostring(math.round(atrVal,2))+"  ("+str.tostring(math.round(atrVal/close*100,2))+"%)", text_color=color.orange,text_size=size.small)

    table.cell(t,0,16,"📰 News / Catalyst",  text_color=cW,text_size=size.small)
    table.cell(t,1,16,"Verify on NSE / Screener.in / X", text_color=color.new(color.silver,20),text_size=size.tiny)

    table.cell(t,0,17,"",            text_color=cGr,text_size=size.tiny)
    table.cell(t,1,17,"© by Karthik",text_color=color.new(color.gray,30),text_size=size.tiny,text_halign=text.align_right)

// ── ALERTS ───────────────────────────────────────
alertcondition(strongBull,           "🟢 STRONG BUY CE — by Karthik", "EMA Bull Cross + OI + Sector → BUY CALL (Score ≥4)")
alertcondition(strongBear,           "🔴 STRONG BUY PE — by Karthik", "EMA Bear Cross + OI + Sector → BUY PUT (Score ≥4)")
alertcondition(bullCross,            "EMA Bull Cross",                 "8 EMA crossed ABOVE 20 EMA")
alertcondition(bearCross,            "EMA Bear Cross",                 "8 EMA crossed BELOW 20 EMA")
alertcondition(volSpike and emaBull, "Vol Spike in Bull Trend",        "High volume surge in bullish EMA trend")
````
