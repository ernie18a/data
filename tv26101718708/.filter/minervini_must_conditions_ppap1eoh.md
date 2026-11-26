# Minervini Must Conditions 

- url: https://www.tradingview.com/script/PPAP1eOh-Minervini-Must-Conditions/
- type: indicator
- pine_id: PUB;bd620cf880ec40708d44350da77513bd
- version: 1.0

## Description

Here's the full description:

Mark Minervini's Trend Template Screener

⚠️ Disclaimer: This indicator is for educational and informational purposes only. It is NOT a buy, sell, or hold recommendation. Always do your own research and consult a SEBI-registered financial advisor before making any investment decisions. Past performance does not guarantee future results.

What is this?
This indicator automates Mark Minervini's famous Trend Template — a checklist he uses to identify stocks in a confirmed Stage 2 uptrend before they make big moves. Minervini is a U.S. Stock Champion (1997) and author of Trade Like a Stock Market Wizard.

The 9 Conditions & Why They Matter:

CMP > 50 MA — Price is above its short-term average. This confirms immediate bullish momentum. If price can't hold above 50 MA, short-term sellers are in control.
CMP > 150 MA — Price is above intermediate trend. This filters out stocks that may have bounced short-term but are still in a broader downtrend.
CMP > 200 MA — Price is above the long-term average. Institutional investors watch 200 MA closely. Trading above it signals big money is supportive.
50 MA > 150 MA — Short-term trend is stronger than intermediate. This means recent buying pressure is accelerating, not fading.
50 MA > 200 MA — Short-term trend leads long-term. Confirms the stock isn't just surviving — it's outperforming its own history.
150 MA > 200 MA — Intermediate trend leads long-term. This is the structural backbone. When this flips bullish, it signals a genuine trend shift, not just a bounce.
200 MA trending up (1 month) — The slowest moving average is rising. This is the hardest condition to fake. A rising 200 MA means sustained accumulation over months.
Within 25% of 52-week high — Stock is near its highs. Minervini avoids "fallen angels" trading far from highs. Stocks near highs have less overhead resistance (trapped sellers) and more momentum.
>25% above 52-week low — Stock has moved significantly off its lows. This eliminates bottom-fishers and ensures the stock has already proven buyer interest with a strong base breakout.


Why all 9 together?
Any single condition can give false signals. A stock above 50 MA might still be in a long-term downtrend. A stock near 52-week highs might have collapsing moving averages. Minervini's genius is stacking all 9 — when every condition aligns, you're looking at a stock where short-term, intermediate, and long-term trends are all bullish, momentum is accelerating, and the price structure confirms institutional accumulation. This drastically reduces the universe of stocks to only the strongest candidates.

How to use:

✓ = condition passed, ✗ = condition failed
All 9 must show ✓ for a stock to qualify
Supports EMA/SMA toggle
Daily timeframe only
Table size and position adjustable

This is a screening tool, not a trading signal. Use it to build your watchlist, then apply your own entry/exit strategy, risk management, and position sizing.
© financetalkswithaman

## Source Code

````pine
// © financetalkswithaman
//@version=5
indicator("Minervini Template", overlay=true)

pos = input.string(position.top_right, 'Position', options=[position.top_left, position.top_right, position.bottom_left, position.bottom_right], group='Table')
txtcol = input(color.white, "Text", group='Table')
txtsz = input.string(size.tiny, 'Size', options=[size.auto, size.tiny, size.small, size.normal], group='Table')
bgcol = input(color.gray, "BG", group='Table')
matype = input.string('EMA', options=['EMA','SMA'], title='MA Type', group='MA')

var t = table.new(pos, 3, 12, frame_color=color.rgb(49,71,131), border_width=1, frame_width=1, border_color=color.black)

ma50  = matype=='EMA' ? ta.ema(close,50)  : ta.sma(close,50)
ma150 = matype=='EMA' ? ta.ema(close,150) : ta.sma(close,150)
ma200 = matype=='EMA' ? ta.ema(close,200) : ta.sma(close,200)
ma200_22 = ma200[22]

c1 = close>ma50
c2 = close>ma150
c3 = close>ma200
c4 = ma50>ma150
c5 = ma50>ma200
c6 = ma150>ma200
c7 = ma200>ma200_22

price_52wh = request.security(syminfo.tickerid,"1D",ta.highest(high,252),lookahead=barmerge.lookahead_off)
price_52wl = request.security(syminfo.tickerid,"1D",ta.lowest(low,252),lookahead=barmerge.lookahead_off)

get_ath() =>
    h = 0.0
    h := bar_index==0 ? high : high>h[1] ? high : h[1]
    h
get_atl() =>
    l = 0.0
    l := bar_index==0 ? low : low<l[1] ? low : l[1]
    l

ath = request.security(syminfo.tickerid,'D',get_ath())
atl = request.security(syminfo.tickerid,'D',get_atl())
if high>ath
    ath:=high
if low<atl
    atl:=low
if bar_index<=252
    price_52wh:=ath
    price_52wl:=atl

p52h = (1-(price_52wh/close))*100
p52l = ((close/price_52wl)-1)*100
c8 = p52h > -25
c9 = p52l > 25

col(bool b) => b ? bgcol : color.red
mk(bool b) => b ? '✓' : '✗'
cyan = color.rgb(6,192,224)

if timeframe.isdaily
    table.merge_cells(t,0,0,2,0)
    table.cell(t,0,0,'Minervini Template',bgcolor=color.rgb(88,247,114),text_size=txtsz,text_color=color.black)

    labels  = array.from('CMP>50','CMP>150','CMP>200','50>150','50>200','150>200','200 Up','<25% fr 52H','>25% fr 52L')
    checks  = array.from(c1,c2,c3,c4,c5,c6,c7,c8,c9)
    vals    = array.from(
     str.tostring(ma50,'#.#'),str.tostring(ma150,'#.#'),str.tostring(ma200,'#.#'),
     str.tostring((1-ma50/ma150)*100,'#.#')+'%',str.tostring((1-ma50/ma200)*100,'#.#')+'%',str.tostring((1-ma150/ma200)*100,'#.#')+'%',
     str.tostring((1-ma200/close)*100,'#.#')+'%',
     str.tostring(price_52wh,'#.#')+'('+str.tostring(p52h,'#.#')+'%)',
     str.tostring(price_52wl,'#.#')+'('+str.tostring(p52l,'#.#')+'%)')

    for i = 0 to 8
        table.cell(t,0,i+1,mk(array.get(checks,i)),bgcolor=col(array.get(checks,i)),text_size=txtsz,text_color=txtcol)
        table.cell(t,1,i+1,array.get(labels,i),bgcolor=cyan,text_size=txtsz,text_color=color.black)
        table.cell(t,2,i+1,array.get(vals,i),bgcolor=bgcol,text_size=txtsz,text_color=txtcol)

    allpass = c1 and c2 and c3 and c4 and c5 and c6 and c7 and c8 and c9
    fcol = allpass ? color.rgb(88,247,114) : color.red
    ftxt = allpass ? color.black : color.white
    table.merge_cells(t,0,10,1,10)
    table.cell(t,0,10,'Satisfies Minervini?',bgcolor=fcol,text_size=txtsz,text_color=ftxt)
    table.cell(t,2,10,allpass?'✓✓✓':'✗',bgcolor=fcol,text_size=txtsz,text_color=ftxt)
````
