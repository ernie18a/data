<!-- tradingview-pine-id: PUB;c994f527a6764a3abab089e434e6e06c -->
<!-- tradingviewscripts-format: 1 -->
# TORY 40 Buy Breakout Matrix v1.0

Source: https://www.tradingview.com/script/0Xig3518-TORY-40-Buy-Breakout-Matrix-v1-0/

## Description

TORY 40 Buy Breakout Matrix v1.0 — First Release
TORY 40 Buy Breakout Matrix is a multi-symbol breakout scanner designed to help traders quickly identify fresh bullish signals across a customizable list of up to 40 instruments.
If any symbol is incorrect the whole indicator may not load, you have to re pick the symbols.
Instead of checking each chart individually, the indicator displays qualifying symbols in a compact on-chart dashboard, together with the active technical triggers, current price, analyst target data, potential upside, analyst consensus, and analyst count.

How it works
The scanner monitors five bullish conditions:

TL — TORY Trendline: Detects a break above a descending resistance line formed from two confirmed swing highs. A buy signal requires a resistance breach followed by a candle closing above the breach candle’s high.

ST — Supertrend: Triggers when Supertrend changes from bearish to bullish.

R55 — RSI 55: Triggers when RSI crosses above 55, indicating strengthening bullish momentum.

MARU — Bullish Marubozu: Identifies a strong bullish candle with upper and lower wicks within the selected maximum percentage.

BOS — Bullish Break of Structure: Triggers when price closes above the latest confirmed swing high.

The Score column shows how many enabled signals are currently fresh. In two-timeframe mode, signals from both timeframes contribute to the score, so the maximum is 10. The score measures signal confluence—it is not a prediction or probability of success.

Scanner layouts

The indicator provides three layouts:

40 symbols, one timeframe: Scans the entire symbol list on one selected timeframe.

Group A, 20 symbols, two timeframes: Scans the chart symbol plus positions 2–20 on two timeframes.

Group B, 20 symbols, two timeframes: Scans the chart symbol plus positions 21–40 on two timeframes.

The chart symbol always occupies the first position. When Always show chart symbol first is enabled, it remains pinned at the top even when no new trigger is present. In that case, the dashboard displays WAIT.

All symbols in Groups A and B can be replaced through the indicator settings.

Filtering the results

Rows can be filtered to show:

Any enabled buy signal

Two or more simultaneous signals

TORY trendline signals only

Supertrend signals only

RSI 55 signals only

Marubozu signals only

Bullish BOS signals only

Individual signal types can also be enabled or disabled.

The Keep a new signal visible for setting determines how many bars a new trigger remains on the dashboard. A value of 1 shows only the newest qualifying signal candle.

For more stable scanning, Use completed candles only is enabled by default. Turning it off allows the scanner to react to the currently forming candle, but live signals may change before that candle closes.

Analyst Lens

Where TradingView provides analyst information for a symbol, the dashboard can display:

Median analyst price target

Estimated upside or downside from the scanned price

Consensus rating

Number of contributing analysts

Optional filters include:

Buy or Strong Buy

Strong Buy only

Positive target upside

Minimum analyst count

The consensus label is calculated from the available Strong Buy, Buy, Hold, Sell, and Strong Sell recommendations. Some instruments may not have analyst coverage, so their values can appear as unavailable.

The pinned chart symbol may remain visible regardless of the selected technical or analyst filters.

Suggested starting setup

For a balanced scan:

Use completed candles only

Keep signals visible for 1–2 bars

Enable all five signal types

Select “Any selected buy signal” for broader discovery

Select “2 or more signals” when looking for stronger confluence

Use a higher second timeframe to add broader market context

Important notes

Pivot-based trendline and structure calculations require confirmed swing points, so they naturally appear only after the selected swing-strength period has passed.

This indicator is a scanning and decision-support tool. It does not provide entries, stop-loss levels, position sizing, or guaranteed outcomes. Analyst targets and recommendations may be delayed, incomplete, or unavailable and should not be treated as independent trade signals.

Always confirm signals using price structure, volume, liquidity, risk management, and your own trading plan.

Version 1.0 includes:

Scanning for up to 40 customizable symbols

Single- and dual-timeframe layouts

Five bullish technical triggers

Signal-confluence scoring

Fresh-signal filtering

Optional completed-candle confirmation

Analyst consensus and price-target filters

Customizable dashboard position, size, and displayed data

For educational and informational purposes only. This indicator is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("TORY 40 Buy Breakout Matrix v1.0", overlay=true, dynamic_requests=true)

// ─────────────────────────────────────────────────────────────────────────────
// 1. MATRIX MAP
// ─────────────────────────────────────────────────────────────────────────────
string G_MAP = "1  MATRIX MAP"
mode = input.string("40 symbols · one timeframe", "Scanner layout", options=["40 symbols · one timeframe", "Group A · 20 symbols · two timeframes", "Group B · 20 symbols · two timeframes"], group=G_MAP)
tfOne = input.timeframe("", "Primary / single timeframe", tooltip="Blank uses the current chart timeframe.", group=G_MAP)
tfTwo = input.timeframe("D", "Second / higher timeframe", group=G_MAP)
freshBars = input.int(1, "Keep a new signal visible for", minval=1, maxval=10, tooltip="1 = only the newest completed signal candle.", group=G_MAP)
confirmedOnly = input.bool(true, "Use completed candles only", group=G_MAP)
pinChart = input.bool(true, "Always show chart symbol first", tooltip="Shows the chart symbol even while it is waiting for a new buy signal.", group=G_MAP)

// ─────────────────────────────────────────────────────────────────────────────
// 2. BUY SIGNALS
// ─────────────────────────────────────────────────────────────────────────────
string G_SIG = "2  BUY SIGNALS"
signalFilter = input.string("Any selected buy signal", "Show rows containing", options=["Any selected buy signal", "2 or more signals", "TORI trendline only", "Supertrend only", "RSI 55 only", "Marubozu only", "Bullish BOS only"], group=G_SIG)
useTL = input.bool(true, "TORY descending-trendline breakout", group=G_SIG)
useST = input.bool(true, "Supertrend turns bullish", group=G_SIG)
useRSI = input.bool(true, "RSI crosses above 55", group=G_SIG)
useMaru = input.bool(true, "Bullish Marubozu candle", group=G_SIG)
useBOS = input.bool(true, "Bullish break of structure", group=G_SIG)

// ─────────────────────────────────────────────────────────────────────────────
// 3. SIGNAL INTELLIGENCE
// ─────────────────────────────────────────────────────────────────────────────
string G_LOGIC = "3  SIGNAL INTELLIGENCE"
pivotLen = input.int(3, "Swing strength", minval=2, maxval=12, group=G_LOGIC)
touchGap = input.int(3, "Minimum bars between touchpoints", minval=3, maxval=30, group=G_LOGIC)
stAtr = input.int(10, "Supertrend ATR length", minval=1, group=G_LOGIC)
stFactor = input.float(3.0, "Supertrend factor", minval=0.1, step=0.1, group=G_LOGIC)
rsiLen = input.int(14, "RSI length", minval=2, group=G_LOGIC)
maruWick = input.float(10.0, "Maximum Marubozu wick %", minval=0, maxval=30, step=1, group=G_LOGIC) / 100.0

// ─────────────────────────────────────────────────────────────────────────────
// 4. ANALYST LENS
// ─────────────────────────────────────────────────────────────────────────────
string G_AN = "4  ANALYST LENS"
analystGate = input.string("No analyst restriction", "Analyst filter", options=["No analyst restriction", "Buy or Strong Buy", "Strong Buy only", "Positive target upside"], group=G_AN)
minAnalysts = input.int(0, "Minimum analyst count", minval=0, maxval=100, group=G_AN)

// ─────────────────────────────────────────────────────────────────────────────
// 5. APPEARANCE
// ─────────────────────────────────────────────────────────────────────────────
string G_STYLE = "5  APPEARANCE"
tablePlace = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_STYLE)
tableSize = input.string("Tiny", "Text size", options=["Tiny", "Small"], group=G_STYLE)
showPrice = input.bool(true, "Current price", group=G_STYLE)
showTarget = input.bool(true, "Analyst target", group=G_STYLE)
showUpside = input.bool(true, "Upside potential", group=G_STYLE)

// ─────────────────────────────────────────────────────────────────────────────
// 6. SYMBOL MAP — chart symbol is always position 1
// Group A = chart + positions 2–20. Group B = chart + positions 21–40.
// ─────────────────────────────────────────────────────────────────────────────
string G_A = "6A  GROUP A · POSITIONS 2–20"
s02=input.symbol("NASDAQ:TSEM","02",group=G_A)
s03=input.symbol("NYSE:SNOW","03",group=G_A)
s04=input.symbol("NASDAQ:RKLB","04",group=G_A)
s05=input.symbol("NASDAQ:SITM","05",group=G_A)
s06=input.symbol("NASDAQ:TSLA","06",group=G_A)
s07=input.symbol("NASDAQ:SMTC","07",group=G_A)
s08=input.symbol("NASDAQ:SNDK","08",group=G_A)
s09=input.symbol("NASDAQ:MELI","09",group=G_A)
s10=input.symbol("NYSE:KEYS","10",group=G_A)
s11=input.symbol("NASDAQ:SOFI","11",group=G_A)
s12=input.symbol("NASDAQ:CIFR","12",group=G_A)
s13=input.symbol("NYSE:CPNG","13",group=G_A)
s14=input.symbol("NASDAQ:AEHR","14",group=G_A)
s15=input.symbol("NASDAQ:DASH","15",group=G_A)
s16=input.symbol("NYSE:CVNA","16",group=G_A)
s17=input.symbol("NYSE:CIEN","17",group=G_A)
s18=input.symbol("NYSE:LMND","18",group=G_A)
s19=input.symbol("NASDAQ:LRCX","19",group=G_A)
s20=input.symbol("NASDAQ:GLBE","20",group=G_A)

string G_B = "6B  GROUP B · POSITIONS 21–40"
s21=input.symbol("NASDAQ:RBRK","21",group=G_B)
s22=input.symbol("NASDAQ:MTSI","22",group=G_B)
s23=input.symbol("NASDAQ:PLTR","23",group=G_B)
s24=input.symbol("NYSE:TSM","24",group=G_B)
s25=input.symbol("NASDAQ:AVGO","25",group=G_B)
s26=input.symbol("NYSE:OKLO","26",group=G_B)
s27=input.symbol("NASDAQ:CAMT","27",group=G_B)
s28=input.symbol("NASDAQ:APP","28",group=G_B)
s29=input.symbol("NASDAQ:INTC","29",group=G_B)
s30=input.symbol("NASDAQ:GRAB","30",group=G_B)
s31=input.symbol("NASDAQ:CSCO","31",group=G_B)
s32=input.symbol("NASDAQ:CBRS","32",group=G_B)
s33=input.symbol("NYSE:OSCR","33",group=G_B)
s34=input.symbol("NASDAQ:CORZ","34",group=G_B)
s35=input.symbol("NYSE:HIMS","35",group=G_B)
s36=input.symbol("NYSE:LEU","36",group=G_B)
s37=input.symbol("NASDAQ:LWLG","37",group=G_B)
s38=input.symbol("NASDAQ:RMBS","38",group=G_B)
s39=input.symbol("NASDAQ:NVTS","39",group=G_B)
s40=input.symbol("NASDAQ:IREN","40",group=G_B)

var array<string> symbols = array.from(syminfo.tickerid,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39,s40)

// One compact calculation package per symbol/timeframe.
f_metrics() =>
    int off = confirmedOnly ? 1 : 0
    float ph = ta.pivothigh(high,pivotLen,pivotLen)
    int phBar = bar_index-pivotLen
    var float newestHigh = na
    var float olderHigh = na
    var int newestHighBar = na
    var int olderHighBar = na
    if not na(ph) and (na(newestHighBar) or phBar-newestHighBar >= touchGap)
        olderHigh := newestHigh
        olderHighBar := newestHighBar
        newestHigh := ph
        newestHighBar := phBar
    bool descending = not na(olderHigh) and newestHigh < olderHigh and newestHighBar > olderHighBar
    float slope = descending ? (newestHigh-olderHigh)/(newestHighBar-olderHighBar) : na
    float resistance = descending ? newestHigh+slope*(bar_index-newestHighBar) : na
    float resistancePrev = resistance[1]
    // Breach first; confirmation candle must then close above the breach candle high.
    bool tlBuy = descending and high[1] > resistancePrev and close > high[1]
    [superLine,superDir] = ta.supertrend(stFactor,stAtr)
    bool stBuy = superDir < 0 and superDir[1] > 0
    float rsi = ta.rsi(close,rsiLen)
    bool rsiBuy = ta.crossover(rsi,55)
    float candleRange = high-low
    bool maruBuy = candleRange > 0 and close > open and (high-close) <= candleRange*maruWick and (open-low) <= candleRange*maruWick
    float structureHigh = ta.valuewhen(not na(ph),ph,0)
    bool bosBuy = not na(structureHigh) and ta.crossover(close,structureHigh)
    int tlAge = ta.barssince(tlBuy)[off]
    int stAge = ta.barssince(stBuy)[off]
    int rsiAge = ta.barssince(rsiBuy)[off]
    int maruAge = ta.barssince(maruBuy)[off]
    int bosAge = ta.barssince(bosBuy)[off]
    float recTotal = syminfo.recommendations_total
    float recScore = recTotal > 0 ? (nz(syminfo.recommendations_buy_strong)*5.0+nz(syminfo.recommendations_buy)*4.0+nz(syminfo.recommendations_hold)*3.0+nz(syminfo.recommendations_sell)*2.0+nz(syminfo.recommendations_sell_strong))/recTotal : na
    float target = syminfo.target_price_median
    float price = close[off]
    float upside = not na(target) and price > 0 ? target/price-1.0 : na
    [tlAge,stAge,rsiAge,maruAge,bosAge,price,target,upside,recScore,recTotal,rsi[off],superDir[off]]

f_live(int age) => not na(age) and age >= 0 and age < freshBars

f_selected(bool tl,bool st,bool rs,bool ma,bool bo) =>
    bool a = useTL and tl
    bool b = useST and st
    bool c = useRSI and rs
    bool d = useMaru and ma
    bool e = useBOS and bo
    int n = (a?1:0)+(b?1:0)+(c?1:0)+(d?1:0)+(e?1:0)
    bool pass = signalFilter=="Any selected buy signal" ? n>0 : signalFilter=="2 or more signals" ? n>=2 : signalFilter=="TORI trendline only" ? tl : signalFilter=="Supertrend only" ? st : signalFilter=="RSI 55 only" ? rs : signalFilter=="Marubozu only" ? ma : bo
    [pass,n]

f_analystPass(float score,float total,float upside) =>
    bool countOK = nz(total,0) >= minAnalysts
    bool gateOK = analystGate=="No analyst restriction" ? true : analystGate=="Buy or Strong Buy" ? score>=3.5 : analystGate=="Strong Buy only" ? score>=4.25 : upside>0
    countOK and gateOK

f_rec(float score) => na(score)?"N/A":score>=4.25?"STRONG BUY":score>=3.5?"BUY":score>=2.5?"HOLD":score>=1.75?"SELL":"STRONG SELL"
f_recColor(float score) => na(score)?color.rgb(71,85,105):score>=4.25?color.rgb(16,185,129):score>=3.5?color.rgb(34,197,94):score>=2.5?color.rgb(234,179,8):color.rgb(239,68,68)
f_fmt(float v) => na(v)?"—":str.tostring(v,format.mintick)
f_pct(float v) => na(v)?"—":str.tostring(v*100,"#.0")+"%"
f_name(string sym) =>
    array<string> p = str.split(sym,":")
    array.size(p)>1 ? array.get(p,1) : sym
f_tf(string tf) => tf==""?timeframe.period:tf
f_sigText(bool tl,bool st,bool rs,bool ma,bool bo,string tf) =>
    string x=""
    x := tl ? x+"TL " : x
    x := st ? x+"ST " : x
    x := rs ? x+"R55 " : x
    x := ma ? x+"MARU " : x
    x := bo ? x+"BOS " : x
    str.trim(x)+" · "+tf

pos = tablePlace=="Top Left"?position.top_left:tablePlace=="Bottom Right"?position.bottom_right:tablePlace=="Bottom Left"?position.bottom_left:position.top_right
txtSize = tableSize=="Small"?size.small:size.tiny
var table panel = table.new(pos,9,43,border_width=1,border_color=color.new(color.rgb(148,163,184),65),frame_width=2,frame_color=color.rgb(14,165,233))

f_cell(int col,int row,string cellText,color bg,color fg=color.white) => table.cell(panel,col,row,cellText,bgcolor=bg,text_color=fg,text_size=txtSize)
f_row(int row,string nm,string tfText,string signals,int score,float price,float target,float upside,float recScore,float recTotal,bool pinned) =>
    color bg = row%2==0?color.rgb(15,23,42):color.rgb(24,34,55)
    color sigBg = score>=2?color.rgb(5,150,105):color.rgb(2,132,199)
    f_cell(0,row,pinned?"★ "+nm:nm,pinned?color.rgb(88,28,135):bg)
    f_cell(1,row,tfText,bg,color.rgb(186,230,253))
    f_cell(2,row,signals,signals=="WAIT"?color.rgb(71,85,105):sigBg)
    f_cell(3,row,str.tostring(score)+"/5",bg,score>=2?color.rgb(110,231,183):color.white)
    f_cell(4,row,showPrice?f_fmt(price):"—",bg)
    f_cell(5,row,showTarget?f_fmt(target):"—",bg)
    f_cell(6,row,showUpside?f_pct(upside):"—",bg,upside>0?color.rgb(74,222,128):color.rgb(248,113,113))
    f_cell(7,row,f_rec(recScore),f_recColor(recScore))
    f_cell(8,row,na(recTotal)?"—":str.tostring(int(recTotal)),bg,color.rgb(203,213,225))

if barstate.islast
    table.clear(panel,0,0,8,42)
    color titleBg=color.rgb(8,47,73)
    table.cell(panel,0,0,"TORY BUY BREAKOUT RADAR",bgcolor=titleBg,text_color=color.rgb(125,211,252),text_size=txtSize)
    table.merge_cells(panel,0,0,8,0)
    string modeLine = mode+"  |  Fresh: "+str.tostring(freshBars)+" bar"+(freshBars>1?"s":"")
    table.cell(panel,0,1,modeLine,bgcolor=color.rgb(12,74,110),text_color=color.white,text_size=txtSize)
    table.merge_cells(panel,0,1,8,1)
    array<string> heads=array.from("SYMBOL","TF","LIVE BUY TRIGGER","SCORE","PRICE","TARGET","UPSIDE","ANALYST VIEW","N")
    for h=0 to 8
        f_cell(h,2,array.get(heads,h),color.rgb(30,64,175),color.white)
    int row=3
    bool dual = mode!="40 symbols · one timeframe"
    bool groupB = mode=="Group B · 20 symbols · two timeframes"
    int scanCount = dual?20:40
    string primaryTf=f_tf(tfOne)
    string higherTf=f_tf(tfTwo)
    for j=0 to scanCount-1
        int idx = groupB ? (j==0?0:j+19) : j
        string sym=array.get(symbols,idx)
        [aTL,aST,aRS,aMA,aBO,aPrice,aTarget,aUp,aRec,aTotal,aRsi,aDir]=request.security(sym,primaryTf,f_metrics(),gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_off,ignore_invalid_symbol=true)
        bool tl1=f_live(aTL), st1=f_live(aST), rs1=f_live(aRS), ma1=f_live(aMA), bo1=f_live(aBO)
        [pass1,count1]=f_selected(tl1,st1,rs1,ma1,bo1)
        bool pass2=false
        int count2=0
        string sig2=""
        if dual
            [bTL,bST,bRS,bMA,bBO,bPrice,bTarget,bUp,bRec,bTotal,bRsi,bDir]=request.security(sym,higherTf,f_metrics(),gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_off,ignore_invalid_symbol=true)
            bool tl2=f_live(bTL), st2=f_live(bST), rs2=f_live(bRS), ma2=f_live(bMA), bo2=f_live(bBO)
            [p2,c2]=f_selected(tl2,st2,rs2,ma2,bo2)
            pass2:=p2
            count2:=c2
            sig2:=p2?f_sigText(tl2,st2,rs2,ma2,bo2,higherTf):""
        bool pinned = idx==0 and pinChart
        bool analystOK=f_analystPass(aRec,aTotal,aUp)
        bool show = pinned or ((pass1 or pass2) and analystOK)
        if show and row<=42
            string sig1=pass1?f_sigText(tl1,st1,rs1,ma1,bo1,primaryTf):""
            string combined=sig1+(sig1!="" and sig2!=""?" | ":"")+sig2
            combined:=combined==""?"WAIT":combined
            string tfText=dual?primaryTf+" / "+higherTf:primaryTf
            f_row(row,f_name(sym),tfText,combined,count1+count2,aPrice,aTarget,aUp,aRec,aTotal,pinned)
            row+=1
    if row==3
        table.cell(panel,0,3,"No fresh buy breakouts match your filters",bgcolor=color.rgb(30,41,59),text_color=color.rgb(203,213,225),text_size=txtSize)
        table.merge_cells(panel,0,3,8,3)
````
