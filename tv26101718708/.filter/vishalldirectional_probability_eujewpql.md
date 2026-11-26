# Vishall-Directional Probability

- url: https://www.tradingview.com/script/eUJEwPql-Vishall-Directional-Probability/
- type: indicator
- pine_id: PUB;fecded078d8a4f0f93c8757c3e85feda
- version: 4.0

## Description

Vishall-Directionl Probability

All * dont have future contracts , based on there stock future contact , in case change in index stock , need to change the Stock here also
-----------------------------------------------------------------------------
If Future HA close is higher than Future normal close, it means the HA chart is still showing strength. It does not directly mean the next day will open lower.

Easy meaning
HA close > normal close = trend is still strong / bullish on that candle.

HA close < normal close = trend is weaker / bearish on that candle.

About next day open
You cannot confirm next day opening lower or higher from this one condition alone. Heikin Ashi is mainly for trend reading, not exact next-day prediction.

Simple rule
If HA candle is green, strong, and no lower wick → upside continuation is more likely.

If HA candle is small, weak, or has long upper wick → trend may slow or reverse.

So in short:
Future HA close > Future normal close = bullish strength, not a guaranteed lower open next day.

-------------------------------------------------------------------------------------------
you can frame this as a probability edge, not a prediction rule. Heikin Ashi is built to smooth noise and help traders see trend direction more clearly, so the useful question is whether the relationship between a, b, c, d improves the chance that the next candle is bullish or bearish.

Your variables
a = future HA close

b = future normal close

c = cash HA close

d = cash normal close

A practical way to read them is by measuring how much each HA close differs from its normal close, then comparing futures and cash. Heikin Ashi closes are averaged values, so the gap between HA close and normal close is a way to read how much smoothing is happening in that market.

Simple correlation idea
Use these two spreads:

F = a - b

C = c - d

Then create:

A = F - C = (a - b) - (c - d)

Interpretation:

A > 0: futures are showing relatively stronger HA support than cash.

A < 0: cash is showing relatively stronger HA support than futures.

A near 0: both are similar, so the signal is weaker.

This is not a guaranteed forecast, but it is a clean way to compare relative trend strength between futures and cash using Heikin Ashi smoothing.

Better probability setup
For better chance of usefulness, do not rely on one formula alone. Add simple conditions:

Bullish bias if a > b, c > d, and A > 0.

Bearish bias if a < b, c < d, and A < 0.

Neutral if the values conflict or A is small.

Heikin Ashi works best for trend continuation and reversal awareness, not exact price targets, so this type of rule is more useful for “which side has better probability” than “where price will exactly go”.

Practical formula options
If you want a stronger single-number score, try:

Score 1 = (a - b) + (c - d), to measure total HA strength.

Score 2 = (a - b) - (c - d), to measure futures vs cash imbalance.

Score 3 = (a / b) - (c / d), if you prefer ratio-based comparison.

Among these, Score 2 is usually the most useful for your purpose because it directly compares futures strength against cash strength. Ratios can help, but subtraction is easier to read and more stable for trading interpretation.

How to use it
For next-day and rest-of-day strength:

Use the formula on multiple past days.

Check whether positive A more often led to green next candles.

Check whether negative A more often led to red next candles.

Keep separate records for intraday and overnight behavior.
---------------------------------------------------------------------------------------
the right way is to normalize A as a percentage, so a ₹10 stock and a Nifty contract can be compared on the same scale. Heikin Ashi itself is meant to smooth price and highlight trend strength, so using raw points alone is not enough when prices are at very different levels.

Normalize the signal
Use this first:

𝐹
=
𝑎
−
𝑏
𝑏
×
100
F= 
b
a−b
​
 ×100
𝐶
=
𝑐
−
𝑑
𝑑
×
100
C= 
d
c−d
​
 ×100
𝐴
=
𝐹
−
𝐶
A=F−C
This makes A a relative strength percentage, not a raw rupee difference. That is the cleanest way to compare a low-priced stock with an index or a high-priced stock because the signal becomes size-independent.

What it means
Positive A means futures HA strength is greater than cash HA strength on a percentage basis.

Negative A means cash HA strength is greater than futures HA strength.

Near zero A means both are showing similar relative strength.

This is better than using absolute rupee movement because a ₹1 move is huge for a ₹10 stock but tiny for a ₹20,000 index. Normalizing by price turns the move into a comparable ratio, which is closer to a true strength measure.

Better strength score
If you want one single number, use:

## Source Code

````pine
//@version=6
indicator("Vishall-Directionl Probability", overlay=true)

grpTable = "Table Settings"
tblPosInput = input.string("Middle Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpTable)
txtSizeInput = input.string("Tiny", "Font Size", options=["Tiny","Small","Normal"], group=grpTable)
showValues = input.bool(true, "Show Values", group=grpTable)

grpColors = "Color Settings"
colBullStrong = input.color(color.rgb(95, 184, 90), "Strong Bullish", group=grpColors)
colBullMild   = input.color(color.rgb(144, 238, 144), "Mild Bullish", group=grpColors)
colNeutral    = input.color(color.rgb(204, 153, 0), "Neutral", group=grpColors)
colBearMild   = input.color(color.rgb(255, 182, 193), "Mild Bearish", group=grpColors)
colBearStrong = input.color(color.rgb(255, 92, 117), "Strong Bearish", group=grpColors)
colText       = input.color(color.black, "Text Color", group=grpColors)
colBorder     = input.color(color.gray, "Border Color", group=grpColors)

grpDirect = "Direct Futures Indexes"
symNiftyCash = input.string("NSE:NIFTY", "Nifty 50 Cash", group=grpDirect)
symNiftyFut  = input.string("NSE:NIFTY1!", "Nifty 50 Future", group=grpDirect)
symBankCash  = input.string("NSE:BANKNIFTY", "Nifty Bank Cash", group=grpDirect)
symBankFut   = input.string("NSE:BANKNIFTY1!", "Nifty Bank Future", group=grpDirect)
symPSUCash   = input.string("NSE:CNXPSUBANK", "PSU Bank Cash", group=grpDirect)
symPSUFut    = input.string("", "PSU Bank Future (blank if unavailable)", group=grpDirect)
symFinCash   = input.string("NSE:CNXFINANCE", "Fin Services Cash", group=grpDirect)
symFinFut    = input.string("NSE:FINNIFTY1!", "Fin Services Future", group=grpDirect)

grpProxy = "Proxy Inputs"
auto1 = input.string("NSE:M&M", "Auto", group=grpProxy)
real1 = input.string("NSE:DLF", "Realty", group=grpProxy)
fmcg1 = input.string("NSE:ITC", "FMCG", group=grpProxy)
ph1 = input.string("NSE:SUNPHARMA", "Pharma", group=grpProxy)
en1 = input.string("NSE:RELIANCE", "Energy", group=grpProxy)
mt1 = input.string("NSE:TATASTEEL", "Metal", group=grpProxy)
it1 = input.string("NSE:TCS", "IT", group=grpProxy)

f_tablePos(p) => p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Top Right" ? position.top_right : p == "Middle Left" ? position.middle_left : p == "Middle Center" ? position.middle_center : p == "Middle Right" ? position.middle_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Center" ? position.bottom_center : position.bottom_right
f_textSize(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal
f_haClose(sym) => request.security(ticker.heikinashi(sym), "D", close, ignore_invalid_symbol=true)
f_close(sym) => request.security(sym, "D", close, ignore_invalid_symbol=true)

f_normForce(sym) =>
    ha = f_haClose(sym)
    cl = f_close(sym)
    not na(ha) and not na(cl) and cl != 0 ? ((ha - cl) / cl) * 100.0 : na

f_directStrict(cash, fut) =>
    isBlank = str.length(str.trim(fut)) == 0
    sameSym = cash == fut
    futForce = isBlank or sameSym ? na : f_normForce(fut)
    cashForce = f_normForce(cash)
    not na(futForce) and not na(cashForce) ? futForce - cashForce : na

f_directOrCash(cash, fut) =>
    isBlank = str.length(str.trim(fut)) == 0
    cashForce = f_normForce(cash)
    direct = f_directStrict(cash, fut)
    isBlank ? cashForce : nz(direct, cashForce)

f_bg(v) => na(v) ? color.new(color.gray, 85) : v > 0.5 ? colBullStrong : v > 0.2 ? colBullMild : v >= -0.2 ? colNeutral : v >= -0.5 ? colBearMild : colBearStrong
f_fmt(v) => na(v) ? "NA" : str.tostring(v, "#.##") + "%"
f_cellText(label, value) => showValues ? label + "\n" + f_fmt(value) : label
f_setCell(t, c, r, label, value) => table.cell(t, c, r, f_cellText(label, value), text_color=colText, text_size=f_textSize(txtSizeInput), bgcolor=f_bg(value), text_halign=text.align_center, text_valign=text.align_center)

A_nifty50 = f_directStrict(symNiftyCash, symNiftyFut)
A_bank = f_directStrict(symBankCash, symBankFut)
A_psu = f_directOrCash(symPSUCash, symPSUFut)
A_fin = f_directStrict(symFinCash, symFinFut)
A_auto = f_normForce(auto1)
A_realty = f_normForce(real1)
A_fmcg = f_normForce(fmcg1)
A_pharma = f_normForce(ph1)
A_energy = f_normForce(en1)
A_metal = f_normForce(mt1)
A_it = f_normForce(it1)

chart = str.upper(syminfo.tickerid)
A_chart = str.contains(chart, "BANKNIFTY") ? A_bank : str.contains(chart, "FINNIFTY") ? A_fin : str.contains(chart, "AUTO") ? A_auto : str.contains(chart, "REALTY") ? A_realty : str.contains(chart, "FMCG") ? A_fmcg : str.contains(chart, "PHARMA") ? A_pharma : str.contains(chart, "ENERGY") ? A_energy : str.contains(chart, "METAL") ? A_metal : str.contains(chart, "IT") ? A_it : A_nifty50

var table t = table.new(f_tablePos(tblPosInput), 3, 4, bgcolor=color.new(color.white, 0), border_color=colBorder, border_width=1, frame_color=colBorder, frame_width=1)
if barstate.islast
    table.clear(t, 0, 0, 2, 3)
    f_setCell(t, 0, 0, "Stk Gap", A_chart)
    f_setCell(t, 1, 0, "N50", A_nifty50)
    f_setCell(t, 2, 0, "Bank", A_bank)
    f_setCell(t, 0, 1, "PSU*", A_psu)
    f_setCell(t, 1, 1, "Fin", A_fin)
    f_setCell(t, 2, 1, "Auto*", A_auto)
    f_setCell(t, 0, 2, "Realty*", A_realty)
    f_setCell(t, 1, 2, "FMCG*", A_fmcg)
    f_setCell(t, 2, 2, "Phrm*", A_pharma)
    f_setCell(t, 0, 3, "Enrg*", A_energy)
    f_setCell(t, 1, 3, "Metal*", A_metal)
    f_setCell(t, 2, 3, "IT*", A_it)
````
