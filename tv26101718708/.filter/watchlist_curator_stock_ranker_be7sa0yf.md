# Watchlist Curator     Stock Ranker

- url: https://www.tradingview.com/script/BE7sa0yf-Watchlist-Curator-Stock-Ranker/
- type: indicator
- pine_id: PUB;37a5bcce26494ad0b53a3d7bdf040bcf
- version: 1.0

## Description

[b]Pick a sector — it scores ten of that sector's biggest names and ranks the top five leaders. A fast, honest starting point for your watchlist.[/b]

[b]You've spotted the strong sector. Now — which stocks? Watchlist Curator takes one sector, scores ten of its biggest, most-traded names against the same yardstick, and hands you the top five in ranked order. That's a working watchlist in one look, instead of an hour of chart-flipping.[/b]

It works on its own — nothing else required.

[b]Why a composite rank instead of raw relative strength?[/b]

Sorting a basket by relative strength alone hands you whatever ran the hardest — which is often the name that's most stretched and least enterable. The Curator's score starts with RS but lets the other components confirm or veto it: the trend stack rewards names in clean uptrends, the RSI sweet-spot deliberately down-ranks anything already overbought, and volume confirms real participation. The point of combining them is to surface leaders you can still enter — a different question than "what went up the most."

[b]What it ranks — clearly said[/b]

Each of the 11 sectors carries a fixed basket of ten household-name bellwethers (Technology = AAPL, MSFT, NVDA, AVGO, CRM, AMD, ADBE, ORCL, CSCO, ACN — and so on for the rest). The Curator ranks *within that basket*. It doesn't scan every stock in the sector — it tells you which of the sector's big liquid names lead, which is where most swing traders should be looking anyway.

[b]The Leadership Score (hover the Score header for this on the chart)[/b]

[list]
[*][b] Relative strength vs SPY[/b] — the stock's % move minus SPY's over the lookback (20 bars by default). The backbone of the score.
[*] [b]Trend stack[/b] — up to +6: above the fast EMA, fast EMA above slow, above the slow EMA (+2 each).
[*][b] RSI sweet spot[/b] — +3 only when RSI sits between 50 and 70: trending, but not overbought. This is deliberate — a red-hot name that's already stretched ranks lower on purpose, so the list points you at leaders you can still enter, not chases.
[*][b] Volume[/b] — +2 for trading above its average.
[/list]

The score is relative-strength % plus points — not a 0–100 scale. The Rating column translates it: [b]15+ Strong · 5–15 Good · 0–5 Fair · below 0 Lagging[/b] the market. The #1 row is highlighted in gold; a name whose data can't load shows "n/a".

[b]How to use it[/b]

 1. Find the leading sector — use whatever sector-strength read you trust.
 2. Pick that sector in the dropdown.
 3. Read the top five. Gold row = the current leader.
4.  Those names are the charts worth your study time.


[b]Settings — defaults work out of the box[/b]

[list]
[*] Sector (dropdown, 11 choices) and timeframe (Daily by default — the ranking uses this timeframe no matter what chart you're on). 
[*] RS/momentum lookback (20), fast/slow EMA (20/50), RSI length (14).
[*] Stocks to show (up to 5), table position, text size, dark/light theme, colors.
[/list]


⚠ Educational tool for building a focused watchlist. It ranks relative strength — it does not give buy/sell signals or predict price. Not financial advice.

## Source Code

````pine
//@version=6
// Static-request design only (no dynamic requests) -> avoids RE10137.
// Ranks the full sector basket (10 names) and shows the top 5 leaders.
indicator("Watchlist Curator — Stock Ranker", "Curator", overlay=true)

// ============================ INPUTS ============================
sectorIn = input.string("Technology", "Sector (set to Sector Sweeper's #1)", options=["Technology","Financials","Health Care","Energy","Industrials","Cons Disc","Cons Staples","Utilities","Materials","Real Estate","Comm Svcs"])
tf       = input.timeframe("D", "Timeframe")
rsLen    = input.int(20, "RS / Momentum lookback", minval=5)
emaFast  = input.int(20, "Fast EMA", minval=2)
emaSlow  = input.int(50, "Slow EMA", minval=5)
rsiLen   = input.int(14, "RSI length", minval=2)
topN     = input.int(5,  "Stocks to show", minval=1, maxval=5)

grpDash = "Dashboard"
tablePos  = input.string("Top Right", "Table position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=grpDash)
tableSize = input.string("Normal", "Table text size", options=["Tiny","Small","Normal","Large"], group=grpDash)

grpTheme = "Theme & Colors"
darkMode = input.bool(true, "Dark theme (uncheck for light charts)", group=grpTheme)
colGood  = input.color(#089981, "Strong", group=grpTheme, inline="c1")
colBad   = input.color(#f23645, "Weak",   group=grpTheme, inline="c1")

// ============================ STATIC SYMBOL SLOTS ============================
s0 = switch sectorIn
    "Technology"=>"NASDAQ:AAPL"
    "Financials"=>"NYSE:BRK.B"
    "Health Care"=>"NYSE:LLY"
    "Energy"=>"NYSE:XOM"
    "Industrials"=>"NYSE:GE"
    "Cons Disc"=>"NASDAQ:AMZN"
    "Cons Staples"=>"NYSE:PG"
    "Utilities"=>"NYSE:NEE"
    "Materials"=>"NYSE:LIN"
    "Real Estate"=>"NYSE:PLD"
    =>"NASDAQ:META"
s1 = switch sectorIn
    "Technology"=>"NASDAQ:MSFT"
    "Financials"=>"NYSE:JPM"
    "Health Care"=>"NYSE:UNH"
    "Energy"=>"NYSE:CVX"
    "Industrials"=>"NYSE:CAT"
    "Cons Disc"=>"NASDAQ:TSLA"
    "Cons Staples"=>"NASDAQ:COST"
    "Utilities"=>"NYSE:SO"
    "Materials"=>"NYSE:SHW"
    "Real Estate"=>"NYSE:AMT"
    =>"NASDAQ:GOOGL"
s2 = switch sectorIn
    "Technology"=>"NASDAQ:NVDA"
    "Financials"=>"NYSE:V"
    "Health Care"=>"NYSE:JNJ"
    "Energy"=>"NYSE:COP"
    "Industrials"=>"NYSE:RTX"
    "Cons Disc"=>"NYSE:HD"
    "Cons Staples"=>"NYSE:WMT"
    "Utilities"=>"NYSE:DUK"
    "Materials"=>"NYSE:FCX"
    "Real Estate"=>"NASDAQ:EQIX"
    =>"NASDAQ:NFLX"
s3 = switch sectorIn
    "Technology"=>"NASDAQ:AVGO"
    "Financials"=>"NYSE:MA"
    "Health Care"=>"NYSE:MRK"
    "Energy"=>"NYSE:EOG"
    "Industrials"=>"NASDAQ:HON"
    "Cons Disc"=>"NYSE:MCD"
    "Cons Staples"=>"NYSE:KO"
    "Utilities"=>"NASDAQ:CEG"
    "Materials"=>"NYSE:APD"
    "Real Estate"=>"NYSE:WELL"
    =>"NYSE:DIS"
s4 = switch sectorIn
    "Technology"=>"NYSE:CRM"
    "Financials"=>"NYSE:BAC"
    "Health Care"=>"NYSE:ABBV"
    "Energy"=>"NYSE:SLB"
    "Industrials"=>"NYSE:UNP"
    "Cons Disc"=>"NASDAQ:BKNG"
    "Cons Staples"=>"NASDAQ:PEP"
    "Utilities"=>"NYSE:SRE"
    "Materials"=>"NYSE:ECL"
    "Real Estate"=>"NYSE:SPG"
    =>"NYSE:T"
s5 = switch sectorIn
    "Technology"=>"NASDAQ:AMD"
    "Financials"=>"NYSE:WFC"
    "Health Care"=>"NYSE:TMO"
    "Energy"=>"NYSE:MPC"
    "Industrials"=>"NYSE:BA"
    "Cons Disc"=>"NYSE:LOW"
    "Cons Staples"=>"NYSE:PM"
    "Utilities"=>"NASDAQ:AEP"
    "Materials"=>"NYSE:NEM"
    "Real Estate"=>"NYSE:PSA"
    =>"NYSE:VZ"
s6 = switch sectorIn
    "Technology"=>"NASDAQ:ADBE"
    "Financials"=>"NYSE:GS"
    "Health Care"=>"NYSE:ABT"
    "Energy"=>"NYSE:PSX"
    "Industrials"=>"NYSE:DE"
    "Cons Disc"=>"NYSE:NKE"
    "Cons Staples"=>"NYSE:MO"
    "Utilities"=>"NYSE:D"
    "Materials"=>"NYSE:DOW"
    "Real Estate"=>"NYSE:O"
    =>"NASDAQ:TMUS"
s7 = switch sectorIn
    "Technology"=>"NYSE:ORCL"
    "Financials"=>"NYSE:MS"
    "Health Care"=>"NYSE:PFE"
    "Energy"=>"NYSE:WMB"
    "Industrials"=>"NYSE:LMT"
    "Cons Disc"=>"NASDAQ:SBUX"
    "Cons Staples"=>"NASDAQ:MDLZ"
    "Utilities"=>"NASDAQ:EXC"
    "Materials"=>"NYSE:NUE"
    "Real Estate"=>"NYSE:CCI"
    =>"NASDAQ:CMCSA"
s8 = switch sectorIn
    "Technology"=>"NASDAQ:CSCO"
    "Financials"=>"NYSE:AXP"
    "Health Care"=>"NYSE:DHR"
    "Energy"=>"NYSE:OXY"
    "Industrials"=>"NYSE:UPS"
    "Cons Disc"=>"NYSE:TJX"
    "Cons Staples"=>"NYSE:CL"
    "Utilities"=>"NASDAQ:XEL"
    "Materials"=>"NYSE:CTVA"
    "Real Estate"=>"NYSE:DLR"
    =>"NASDAQ:CHTR"
s9 = switch sectorIn
    "Technology"=>"NYSE:ACN"
    "Financials"=>"NYSE:SPGI"
    "Health Care"=>"NASDAQ:AMGN"
    "Energy"=>"NYSE:VLO"
    "Industrials"=>"NYSE:ETN"
    "Cons Disc"=>"NASDAQ:ABNB"
    "Cons Staples"=>"NYSE:TGT"
    "Utilities"=>"NYSE:PEG"
    "Materials"=>"NYSE:DD"
    "Real Estate"=>"NYSE:EXR"
    =>"NASDAQ:EA"

// ============================ DATA + SCORE ============================
f_data(simple string sym) =>
    request.security(sym, tf, [close, ta.ema(close, emaFast), ta.ema(close, emaSlow), ta.rsi(close, rsiLen), ta.roc(close, rsLen), volume / math.max(ta.sma(volume, rsLen), 1)], ignore_invalid_symbol = true)

f_score(float c, float ef, float es, float r, float roc, float rvol, float benchRoc) =>
    na(c) ? -1e9 : (roc - benchRoc) * 1.0 + ((c > ef ? 1 : 0) + (ef > es ? 1 : 0) + (c > es ? 1 : 0)) * 2.0 + (r > 50 and r < 70 ? 1 : 0) * 3.0 + (rvol > 1 ? 1 : 0) * 2.0

[bc, bef, bes, br, bRoc, brv] = f_data("AMEX:SPY")
[c0,ef0,es0,r0,rc0,rv0]=f_data(s0)
[c1,ef1,es1,r1,rc1,rv1]=f_data(s1)
[c2,ef2,es2,r2,rc2,rv2]=f_data(s2)
[c3,ef3,es3,r3,rc3,rv3]=f_data(s3)
[c4,ef4,es4,r4,rc4,rv4]=f_data(s4)
[c5,ef5,es5,r5,rc5,rv5]=f_data(s5)
[c6,ef6,es6,r6,rc6,rv6]=f_data(s6)
[c7,ef7,es7,r7,rc7,rv7]=f_data(s7)
[c8,ef8,es8,r8,rc8,rv8]=f_data(s8)
[c9,ef9,es9,r9,rc9,rv9]=f_data(s9)

stkSym   = array.from(s0,s1,s2,s3,s4,s5,s6,s7,s8,s9)
stkScore = array.from(f_score(c0,ef0,es0,r0,rc0,rv0,bRoc), f_score(c1,ef1,es1,r1,rc1,rv1,bRoc), f_score(c2,ef2,es2,r2,rc2,rv2,bRoc), f_score(c3,ef3,es3,r3,rc3,rv3,bRoc), f_score(c4,ef4,es4,r4,rc4,rv4,bRoc), f_score(c5,ef5,es5,r5,rc5,rv5,bRoc), f_score(c6,ef6,es6,r6,rc6,rv6,bRoc), f_score(c7,ef7,es7,r7,rc7,rv7,bRoc), f_score(c8,ef8,es8,r8,rc8,rv8,bRoc), f_score(c9,ef9,es9,r9,rc9,rv9,bRoc))

// ============================ THEME ============================
// BlueBeck brand: navy #0a1527 · gold #c0a571 · blue #4789d1
c_navy   = #0a1527
c_gold   = #c0a571
c_hdrBg  = darkMode ? color.new(#16233c, 0) : color.new(#e8ecf2, 0)
c_bodyBg = darkMode ? color.new(#0e1a2f, 6) : color.new(#ffffff, 4)
c_lbl    = darkMode ? #9aa4b2 : #5b6470
c_txt    = darkMode ? #e8e8ec : #0a1527
c_grid   = darkMode ? color.new(#2a3950, 0) : color.new(#d0d4dc, 0)

// Score → rating word + color. Bands are a rough guide (the score is RS% + structure points, not a 0-100 scale).
f_rateTxt(float v) => v <= -1e8 ? "n/a" : v >= 15 ? "Strong" : v >= 5 ? "Good" : v >= 0 ? "Fair" : "Lagging"
f_rateCol(float v) => v <= -1e8 ? c_lbl : v >= 5 ? colGood : v >= 0 ? c_lbl : colBad

scoreTip = "Leadership score = relative strength vs SPY (%) + trend stack (max 6) + RSI 50-70 sweet spot (+3) + above-average volume (+2). Higher = stronger. Use it to rank names WITHIN a sector on one timeframe — the #1 is the leader. Rough guide:  15+ Strong  ·  5-15 Good  ·  0-5 Fair  ·  below 0 Lagging SPY."

tpos = switch tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    =>                 position.bottom_right
tsz = switch tableSize
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    =>         size.normal
tszSm = switch tableSize
    "Tiny"  => size.tiny
    "Small" => size.tiny
    "Large" => size.normal
    =>         size.small

// ============================ TABLE ============================
var table t = table.new(tpos, 3, 7, border_width = 1, border_color = c_grid, frame_color = c_gold, frame_width = 1)
if barstate.islast
    table.set_position(t, tpos)
    table.clear(t, 0, 0, 2, 6)
    table.cell(t, 0, 0, "WATCHLIST CURATOR", text_color=c_gold, bgcolor=c_navy, text_size=tsz, text_halign=text.align_left)
    table.cell(t, 1, 0, "", bgcolor=c_navy)
    table.cell(t, 2, 0, sectorIn, text_color=color.white, bgcolor=c_navy, text_size=tsz, text_halign=text.align_right)
    table.cell(t, 0, 1, "#  Ticker", text_color=c_lbl, bgcolor=c_hdrBg, text_size=tszSm)
    table.cell(t, 1, 1, "Score", text_color=c_lbl, bgcolor=c_hdrBg, text_size=tszSm, text_halign=text.align_right, tooltip=scoreTip)
    table.cell(t, 2, 1, "Rating", text_color=c_lbl, bgcolor=c_hdrBg, text_size=tszSm, text_halign=text.align_right, tooltip=scoreTip)
    used = array.new_bool(array.size(stkScore), false)
    for rank = 0 to topN - 1
        best = -1
        bestVal = -1e18
        for j = 0 to array.size(stkScore) - 1
            if not array.get(used, j) and array.get(stkScore, j) > bestVal
                bestVal := array.get(stkScore, j)
                best := j
        if best >= 0
            array.set(used, best, true)
            sym = str.replace_all(array.get(stkSym, best), "NASDAQ:", "")
            sym := str.replace_all(sym, "NYSE:", "")
            sym := str.replace_all(sym, "AMEX:", "")
            isTop = rank == 0
            validScore = bestVal > -1e8
            rowBg   = isTop ? color.new(c_gold, 82) : c_bodyBg
            symCol  = isTop ? c_gold : c_txt
            scoreCol = not validScore ? c_lbl : bestVal >= 5 ? colGood : bestVal < 0 ? colBad : c_txt
            scoreTxt = validScore ? str.tostring(bestVal, "#.0") : "n/a"
            table.cell(t, 0, rank + 2, str.tostring(rank+1) + "  " + sym, text_color=symCol, bgcolor=rowBg, text_size=tsz, text_halign=text.align_left)
            table.cell(t, 1, rank + 2, scoreTxt, text_color=scoreCol, bgcolor=rowBg, text_size=tsz, text_halign=text.align_right)
            table.cell(t, 2, rank + 2, f_rateTxt(bestVal), text_color=f_rateCol(bestVal), bgcolor=rowBg, text_size=tsz, text_halign=text.align_right)
````
