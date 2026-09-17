<!-- tradingview-pine-id: PUB;462d0146528647aeba1be01bb3c1ed4e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Sequence

Source: https://www.tradingview.com/script/yDQjznEx/

## Description

This indicator marks stop-hunt sweeps and, more importantly, counts how many
consecutive sweeps have occurred on the same side.
 
WHAT A SWEEP IS
 
Traders cluster their stops in predictable places: longs put theirs below the
last swing low, shorts put theirs above the last swing high. Those clusters are
resting liquidity. A sweep happens when price spikes through one of those levels,
triggers the stops, and then closes back on the original side — a wick through,
not a break.
 
The distinction that matters:
• Close beyond the level  = a real breakout, trend continuation
• Close back inside       = a sweep, failed breakout, potential reversal
 
WHY THE SEQUENCE COUNT
 
A single sweep is often just noise. What I found more useful is when they stack:
the first sweep traps, price fails to reverse, then a second sweep takes out an
even lower low. The second one is where selling pressure is actually exhausted.
 
The indicator labels these SWEEP, SWEEP², SWEEP³ and so on. The count resets when
an opposite-side sweep appears or when too many bars pass. By default the second
sweep must take out a deeper low (or higher high) to continue the sequence —
otherwise the count restarts at 1.
 
HOW IT WORKS
 
1. Swing highs and lows are tracked as liquidity levels using pivots.
2. A level is dropped as soon as price CLOSES through it. Once price closes above
   a swing high, that liquidity has already been taken and the level can no longer
   produce a sweep signal. This is the single most important filter here — without
   it, stale levels from far back generate false signals during trends.
3. A sweep requires: wick through an untouched level, close back inside, a minimum
   wick ratio, a minimum reclaim distance, and the bar must be a genuine local
   extreme (if the wick does not exceed recent bars, no stops were actually hit).
4. Next-bar confirmation requires the following candle to close in the reversal
   direction before the label is drawn.
5. Significance tiering: a sweep is marked "major" only when the wick is the
   extreme of the last N bars. Minor sweeps inside ranges are hidden by default.
 
All labels are drawn on confirmed bars only, so nothing repaints.
 
HOW I USE IT
 
My own preference is the 1H chart, entering on SWEEP² — the second sweep in a
sequence. The first sweep tells me the level is being attacked; the second one is
where I act.
 
This is built for short-term perpetual futures trading and works best there. The
reason is mechanical: perps run 24/7 with no gaps, they are heavily leveraged, and
liquidation clusters are dense and public. Stop hunts on perps are a real, visible
event rather than a metaphor. On instruments with overnight gaps, daily price
limits, or low leverage, a long wick often does not represent a genuine sweep at
all, and signal quality degrades noticeably.
 
Suggested timeframes: 15m to 4H. Lower is noisy; the daily compresses multi-hour
hunts into a single candle and loses the event.
 
LIMITATIONS — please read
 
• This is a mean-reversion tool, not a trend tool. A sweep is by definition a
  FAILED breakout, while a trend start is a SUCCESSFUL one. The two are mutually
  exclusive, so this indicator will not flag the beginning of a large trend, and
  it is not designed to.
• It only detects double-top and double-bottom style reversals. A V-shaped top
  that simply prints a new high and falls has no prior level above it to sweep,
  so no signal can appear there.
• Signals occur more frequently in ranging conditions. That is inherent to the
  concept, not a defect.
• Next-bar confirmation costs one bar of delay. Turn it off for immediacy at the
  cost of more failed signals.
• Pivot detection needs bars on both sides, so levels are registered with a lag
  equal to the swing sensitivity setting.
• Parameters need adjusting per market and timeframe. On 15m, the major-sweep
  lookback should be lowered to roughly 40–60.
 
SETTINGS WORTH TOUCHING FIRST
 
• Swing sensitivity — the main tightness control
• Major sweep lookback — how significant a sweep must be to display
• Show 2nd sweep and beyond only — reduces the chart to sequence signals alone
• Show untouched liquidity levels — draws the levels currently being tracked so
  you can verify the structure logic yourself
 
Alerts are included for major sweeps and for the second sweep in a sequence.
 
This indicator is a visualization and analysis tool. It does not generate buy or
sell recommendations and nothing here is financial advice. Test any approach on
your own before risking capital.
 
────────────────────────────────────────────────────────────────────
 
【繁體中文說明】
 
本指標標記獵殺止損的掃蕩訊號，並且會計算同方向連續掃蕩的次數。
 
什麼是掃蕩
 
交易者的停損放在可預測的位置：做多的放在前低下方，做空的放在前高上方。這些成堆
的停損就是「流動性」。當價格刺破那個價位、觸發停損，然後收盤又收回原本那一側，
就是一次掃蕩——是影線穿過，不是真正突破。
 
關鍵區別：
• 收盤站在價位外側 = 真突破，趨勢延續
• 收盤收回內側     = 掃蕩，假突破，可能反轉
 
為什麼要算連續次數
 
單一次掃蕩常常只是雜訊。比較有用的是它們接連出現：第一次掃蕩是陷阱，價格沒能反
轉，接著第二次掃蕩創了更低的低點——第二次才是賣壓真正耗盡的地方。
 
指標會標成 SWEEP、SWEEP²、SWEEP³。出現反向掃蕩或間隔過久就歸零重算。預設要求第
二次必須創更低低點（或更高高點）才算延續，否則計數從 1 重新開始。
 
運作方式
 
1. 用 pivot 追蹤前高前低作為流動性價位。
2. 價格一旦「收盤」穿過某個價位，該價位立刻作廢。收盤站上前高，代表那裡的流動性
   已經被吃掉，不再是掃蕩目標。這是本指標最重要的過濾——沒有這一層，久遠以前的
   死線會在趨勢中不斷產生假訊號。
3. 掃蕩成立條件：影線穿過未被吃掉的價位、收盤收回、影線佔比達標、收回幅度達標，
   且該K棒必須創局部極值（影線若沒超過近期K棒，代表根本沒有停損被觸發）。
4. 隔根確認：要求下一根收盤朝反轉方向，才畫出標籤。
5. 重要度分級：影線必須是近 N 根的極值才標為「主要」。震盪區間的次要掃蕩預設隱藏。
 
所有標籤都在收K後才繪製，不會重繪。
 
我自己怎麼用
 
我個人偏好 1 小時線，在 SWEEP²（連續第二次掃蕩）進場。第一次告訴我這個價位正在被
攻擊，第二次才是我動手的地方。
 
這支是為短線永續合約設計的，在那裡效果最好。原因是機制上的：永續 24 小時不間斷、
沒有跳空、槓桿高，清算價位密集而且公開。永續上的獵殺止損是實際發生、看得見的事件，
不是比喻。在有隔夜跳空、漲跌幅限制、或低槓桿的商品上，一根長影線常常根本不代表真
正的掃蕩，訊號品質會明顯下降。
 
建議時框：15 分鐘到 4 小時。更低太雜；日線把數小時的獵殺壓縮成一根K棒，事件本身就
消失了。
 
限制（請務必閱讀）
 
• 這是均值回歸工具，不是趨勢工具。掃蕩的定義就是「突破失敗」，而趨勢起點是「突破
  成功」，兩者互斥。所以它不會標出大趨勢的起點，也不是為此設計的。
• 只偵測得到雙頂／雙底型的反轉。直接創新高然後下跌的 V 型頂，上方根本沒有前高可
  掃，不可能出現訊號。
• 震盪盤中訊號較密集。這是概念本身的性質，不是缺陷。
• 隔根確認會延遲一根。關掉可即時，但假訊號會變多。
• Pivot 需要左右兩側的K棒，所以價位登記會延遲，延遲根數等於靈敏度設定值。
• 參數需依市場與時框調整。15 分鐘線建議把主要掃蕩回看根數降到 40–60。
 
本指標為視覺化與分析工具，不產生買賣建議，內容不構成投資建議。任何做法請自行驗證
後再投入資金。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Choliszt

//@version=6
indicator("Liquidity Sweep Sequence", shorttitle="LiqSweep", overlay=true, max_labels_count=500, max_lines_count=500)

// ════════════════════════════════════════════════════════════
//  DETECTION
// ════════════════════════════════════════════════════════════
gDet     = "Detection"
pivLen   = input.int(8,    "Swing sensitivity (bars each side)", minval=2, group=gDet, tooltip="Higher = only more prominent swing highs/lows are tracked. 5-10 is typical.")
wickRatio= input.float(55, "Minimum wick ratio (%)", minval=0, maxval=100, step=5, group=gDet, tooltip="The wick must be at least this share of the candle's full range. Higher = only long-wick rejections qualify.")
maxAge   = input.int(300,  "Level lifespan (bars)", minval=10, group=gDet, tooltip="Levels older than this stop being tracked.")
showBuy  = input.bool(true, "Show sell-side sweeps (bullish)", group=gDet)
showSell = input.bool(true, "Show buy-side sweeps (bearish)", group=gDet)

// ════════════════════════════════════════════════════════════
//  SEQUENCE COUNT
// ════════════════════════════════════════════════════════════
gSeq         = "Sequence count"
seqWindow    = input.int(50,   "Max gap between sweeps (bars)", minval=3, group=gSeq, tooltip="Two same-side sweeps further apart than this are treated as unrelated and the count restarts.")
requireDeeper= input.bool(true, "Require deeper low / higher high", group=gSeq, tooltip="ON: the second sweep must take out a lower low (or higher high) than the first to continue the sequence. OFF: any same-side sweep increments the count.")
resetOnOpp   = input.bool(true, "Reset count on opposite sweep", group=gSeq)
onlyShowSeq2 = input.bool(false,"Show 2nd sweep and beyond only", group=gSeq, tooltip="Hides first-in-sequence sweeps so only continuation sweeps remain on the chart.")
seq2Size     = input.string("normal","Label size for 2nd+", options=["small","normal","large"], group=gSeq)

// ════════════════════════════════════════════════════════════
//  SIGNIFICANCE
// ════════════════════════════════════════════════════════════
gTier     = "Significance"
onlyMajor = input.bool(true, "Show major sweeps only", group=gTier, tooltip="Filters out minor sweeps that occur inside ranges.")
majorLen  = input.int(60,    "Major sweep: extreme of last N bars", minval=20, group=gTier, tooltip="The sweeping wick must be the lowest low / highest high of the last N bars. Daily: 60-120. 15m: 40-60.")

// ════════════════════════════════════════════════════════════
//  STRUCTURE FILTERS
// ════════════════════════════════════════════════════════════
gStruct   = "Structure filters"
useConsume= input.bool(true, "Invalidate levels once closed through", group=gStruct, tooltip="A close above a swing high (or below a swing low) means that liquidity has already been taken. The level is dropped and can no longer produce a sweep signal.")
useExtreme= input.bool(true, "Sweep bar must be a local extreme", group=gStruct, tooltip="The wick must genuinely make a new local low/high, otherwise no stops were actually triggered.")
extLen    = input.int(10,    "Local extreme lookback (bars)", minval=3, group=gStruct)

// ════════════════════════════════════════════════════════════
//  QUALITY FILTERS
// ════════════════════════════════════════════════════════════
gFil      = "Quality filters"
useConfirm= input.bool(true,  "Next-bar confirmation", group=gFil, tooltip="Requires the following bar to close in the reversal direction. Costs one bar of delay but removes most failed signals.")
useDepth  = input.bool(true,  "Minimum reclaim filter", group=gFil)
depthATR  = input.float(0.15, "   Minimum reclaim (ATR multiple)", minval=0, step=0.05, group=gFil, tooltip="The close must reclaim the level by at least this much, not just barely.")
cooldown  = input.int(10,     "Same-side cooldown (bars)", minval=0, group=gFil)
useTrend  = input.bool(false, "Trend filter (with-trend only)", group=gFil, tooltip="Above the MA only bullish sweeps are shown, below it only bearish ones.")
trendLen  = input.int(100,    "   Trend MA length", minval=10, group=gFil)

// ════════════════════════════════════════════════════════════
//  STYLE
// ════════════════════════════════════════════════════════════
gStyle   = "Style"
labTxtB  = input.string("SWEEP", "Bullish label text", group=gStyle)
labTxtS  = input.string("SWEEP", "Bearish label text", group=gStyle)
majSize  = input.string("small", "Label size for 1st", options=["tiny","small","normal"], group=gStyle)
showLine = input.bool(true, "Show swept level line", group=gStyle)
lineExt  = input.int(12,    "   Extend right (bars)", minval=0, group=gStyle)
showLive = input.bool(false,"Show untouched liquidity levels", group=gStyle, tooltip="Draws the swing levels currently being tracked, so you can verify the structure logic yourself.")
showMA   = input.bool(false,"Show trend MA", group=gStyle)
atrLen   = input.int(14,    "ATR length", minval=1, group=gStyle)
offMult  = input.float(0.4, "Label offset (ATR multiple)", step=0.05, group=gStyle)

// ════════════════════════════════════════════════════════════
//  COLORS
// ════════════════════════════════════════════════════════════
gCol   = "Colors"
cBuy   = input.color(#00E676, "Bullish sweep", group=gCol)
cSell  = input.color(#FF1744, "Bearish sweep", group=gCol)
lineTr = input.int(45, "Swept level transparency", minval=0, maxval=100, group=gCol)
liveTr = input.int(72, "Untouched level transparency", minval=0, maxval=100, group=gCol)
minTr  = input.int(45, "Minor sweep transparency", minval=0, maxval=100, group=gCol)

// ════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════
atrVal  = ta.atr(atrLen)
trendMA = ta.ema(close, trendLen)
plot(showMA ? trendMA : na, "Trend MA", color=color.new(color.gray, 40), linewidth=1)

f_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small
mkSize  = f_size(majSize)
seqSize = f_size(seq2Size)

// Superscript digits for the sequence number
f_sup(n) =>
    switch n
        2 => "²"
        3 => "³"
        4 => "⁴"
        5 => "⁵"
        6 => "⁶"
        7 => "⁷"
        8 => "⁸"
        9 => "⁹"
        => str.tostring(n)

// ════════════════════════════════════════════════════════════
//  SWING LEVEL REGISTRY
// ════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)

var float[] hiPrice = array.new<float>()
var int[]   hiBar   = array.new<int>()
var float[] loPrice = array.new<float>()
var int[]   loBar   = array.new<int>()

if not na(ph)
    array.push(hiPrice, ph)
    array.push(hiBar,   bar_index - pivLen)
if not na(pl)
    array.push(loPrice, pl)
    array.push(loBar,   bar_index - pivLen)

f_prune(_price, _bar) =>
    if array.size(_bar) > 0
        for i = array.size(_bar) - 1 to 0
            if bar_index - array.get(_bar, i) > maxAge
                array.remove(_price, i)
                array.remove(_bar,   i)
f_prune(hiPrice, hiBar)
f_prune(loPrice, loBar)

// ════════════════════════════════════════════════════════════
//  CONDITIONS
// ════════════════════════════════════════════════════════════
rng      = high - low
lowWick  = math.min(open, close) - low
highWick = high - math.max(open, close)
lowWickOK  = rng > 0 and (lowWick  / rng) * 100 >= wickRatio
highWickOK = rng > 0 and (highWick / rng) * 100 >= wickRatio
atLowExtreme  = not useExtreme or low  <= ta.lowest(low,   extLen)
atHighExtreme = not useExtreme or high >= ta.highest(high, extLen)
isMajorLow    = low  <= ta.lowest(low,   majorLen)
isMajorHigh   = high >= ta.highest(high, majorLen)
trendOkBuy    = not useTrend or close > trendMA
trendOkSell   = not useTrend or close < trendMA

f_checkLow() =>
    float hit = na
    if array.size(loPrice) > 0
        for i = array.size(loPrice) - 1 to 0
            lvl = array.get(loPrice, i)
            depthOK = not useDepth or (close - lvl) >= atrVal * depthATR
            if low < lvl and close > lvl and depthOK
                hit := na(hit) ? lvl : math.max(hit, lvl)
                array.remove(loPrice, i)
                array.remove(loBar,   i)
    hit

f_checkHigh() =>
    float hit = na
    if array.size(hiPrice) > 0
        for i = array.size(hiPrice) - 1 to 0
            lvl = array.get(hiPrice, i)
            depthOK = not useDepth or (lvl - close) >= atrVal * depthATR
            if high > lvl and close < lvl and depthOK
                hit := na(hit) ? lvl : math.min(hit, lvl)
                array.remove(hiPrice, i)
                array.remove(hiBar,   i)
    hit

// A level that price has closed through has already had its liquidity taken
f_consume() =>
    if array.size(hiPrice) > 0
        for i = array.size(hiPrice) - 1 to 0
            if close > array.get(hiPrice, i)
                array.remove(hiPrice, i)
                array.remove(hiBar,   i)
    if array.size(loPrice) > 0
        for i = array.size(loPrice) - 1 to 0
            if close < array.get(loPrice, i)
                array.remove(loPrice, i)
                array.remove(loBar,   i)

// ════════════════════════════════════════════════════════════
//  DRAWING
// ════════════════════════════════════════════════════════════
f_drawBuy(_lvl, _back, _maj, _seq) =>
    y    = low[_back] - atrVal[_back] * offMult
    col  = _maj ? cBuy : color.new(cBuy, minTr)
    isS2 = _seq >= 2
    txt  = labTxtB + (isS2 ? f_sup(_seq) : "")
    sz   = isS2 ? seqSize : mkSize
    if _maj or isS2
        label.new(bar_index - _back, y, txt, yloc=yloc.price, style=label.style_label_up, color=col, textcolor=color.black, size=sz)
    else
        label.new(bar_index - _back, y, "▲", yloc=yloc.price, style=label.style_none, textcolor=col, size=size.tiny)
    if showLine and (_maj or isS2)
        line.new(bar_index - _back - pivLen, _lvl, bar_index - _back + lineExt, _lvl, color=color.new(cBuy, lineTr), width=1, style=line.style_dotted)

f_drawSell(_lvl, _back, _maj, _seq) =>
    y    = high[_back] + atrVal[_back] * offMult
    col  = _maj ? cSell : color.new(cSell, minTr)
    isS2 = _seq >= 2
    txt  = labTxtS + (isS2 ? f_sup(_seq) : "")
    sz   = isS2 ? seqSize : mkSize
    if _maj or isS2
        label.new(bar_index - _back, y, txt, yloc=yloc.price, style=label.style_label_down, color=col, textcolor=color.white, size=sz)
    else
        label.new(bar_index - _back, y, "▼", yloc=yloc.price, style=label.style_none, textcolor=col, size=size.tiny)
    if showLine and (_maj or isS2)
        line.new(bar_index - _back - pivLen, _lvl, bar_index - _back + lineExt, _lvl, color=color.new(cSell, lineTr), width=1, style=line.style_dotted)

// ════════════════════════════════════════════════════════════
//  STATE
// ════════════════════════════════════════════════════════════
var bool  pBuyOn   = false
var float pBuyLvl  = na
var float pBuyRef  = na
var float pBuyLow  = na
var bool  pBuyMaj  = false
var bool  pSellOn  = false
var float pSellLvl = na
var float pSellRef = na
var float pSellHi  = na
var bool  pSellMaj = false

var int   lastBuyBar     = na
var int   lastSellBar    = na
var int   buySeq         = 0
var int   sellSeq        = 0
var float lastBuySeqPx   = na
var int   lastBuySeqBar  = na
var float lastSellSeqPx  = na
var int   lastSellSeqBar = na

bool firedBuySeq2  = false
bool firedSellSeq2 = false
bool firedBuyMaj   = false
bool firedSellMaj  = false

if barstate.isconfirmed

    // ---- confirm pending bullish sweep ----
    if pBuyOn
        if close > pBuyRef
            bool willShow = pBuyMaj or not onlyMajor
            bool cdOK     = na(lastBuyBar) or bar_index - lastBuyBar >= cooldown
            if willShow and cdOK
                bool contd = not na(lastBuySeqBar) and (bar_index - lastBuySeqBar) <= seqWindow and (not requireDeeper or pBuyLow < lastBuySeqPx)
                buySeq        := contd ? buySeq + 1 : 1
                lastBuySeqPx  := pBuyLow
                lastBuySeqBar := bar_index - 1
                lastBuyBar    := bar_index - 1
                if resetOnOpp
                    sellSeq        := 0
                    lastSellSeqPx  := na
                    lastSellSeqBar := na
                if not onlyShowSeq2 or buySeq >= 2
                    f_drawBuy(pBuyLvl, 1, pBuyMaj, buySeq)
                if buySeq >= 2
                    firedBuySeq2 := true
                if pBuyMaj
                    firedBuyMaj := true
        pBuyOn := false

    // ---- confirm pending bearish sweep ----
    if pSellOn
        if close < pSellRef
            bool willShow = pSellMaj or not onlyMajor
            bool cdOK     = na(lastSellBar) or bar_index - lastSellBar >= cooldown
            if willShow and cdOK
                bool contd = not na(lastSellSeqBar) and (bar_index - lastSellSeqBar) <= seqWindow and (not requireDeeper or pSellHi > lastSellSeqPx)
                sellSeq        := contd ? sellSeq + 1 : 1
                lastSellSeqPx  := pSellHi
                lastSellSeqBar := bar_index - 1
                lastSellBar    := bar_index - 1
                if resetOnOpp
                    buySeq        := 0
                    lastBuySeqPx  := na
                    lastBuySeqBar := na
                if not onlyShowSeq2 or sellSeq >= 2
                    f_drawSell(pSellLvl, 1, pSellMaj, sellSeq)
                if sellSeq >= 2
                    firedSellSeq2 := true
                if pSellMaj
                    firedSellMaj := true
        pSellOn := false

    // ---- detect new sweeps ----
    float newLow  = na
    float newHigh = na
    if showBuy  and lowWickOK  and atLowExtreme  and trendOkBuy
        newLow  := f_checkLow()
    if showSell and highWickOK and atHighExtreme and trendOkSell
        newHigh := f_checkHigh()

    if not na(newLow)
        if useConfirm
            pBuyOn  := true
            pBuyLvl := newLow
            pBuyRef := close
            pBuyLow := low
            pBuyMaj := isMajorLow
        else
            bool willShowN = isMajorLow or not onlyMajor
            bool cdOKn     = na(lastBuyBar) or bar_index - lastBuyBar >= cooldown
            if willShowN and cdOKn
                bool contdN = not na(lastBuySeqBar) and (bar_index - lastBuySeqBar) <= seqWindow and (not requireDeeper or low < lastBuySeqPx)
                buySeq        := contdN ? buySeq + 1 : 1
                lastBuySeqPx  := low
                lastBuySeqBar := bar_index
                lastBuyBar    := bar_index
                if resetOnOpp
                    sellSeq        := 0
                    lastSellSeqPx  := na
                    lastSellSeqBar := na
                if not onlyShowSeq2 or buySeq >= 2
                    f_drawBuy(newLow, 0, isMajorLow, buySeq)
                if buySeq >= 2
                    firedBuySeq2 := true
                if isMajorLow
                    firedBuyMaj := true

    if not na(newHigh)
        if useConfirm
            pSellOn  := true
            pSellLvl := newHigh
            pSellRef := close
            pSellHi  := high
            pSellMaj := isMajorHigh
        else
            bool willShowS = isMajorHigh or not onlyMajor
            bool cdOKs     = na(lastSellBar) or bar_index - lastSellBar >= cooldown
            if willShowS and cdOKs
                bool contdS = not na(lastSellSeqBar) and (bar_index - lastSellSeqBar) <= seqWindow and (not requireDeeper or high > lastSellSeqPx)
                sellSeq        := contdS ? sellSeq + 1 : 1
                lastSellSeqPx  := high
                lastSellSeqBar := bar_index
                lastSellBar    := bar_index
                if resetOnOpp
                    buySeq        := 0
                    lastBuySeqPx  := na
                    lastBuySeqBar := na
                if not onlyShowSeq2 or sellSeq >= 2
                    f_drawSell(newHigh, 0, isMajorHigh, sellSeq)
                if sellSeq >= 2
                    firedSellSeq2 := true
                if isMajorHigh
                    firedSellMaj := true

    // ---- invalidate levels price has closed through ----
    if useConsume
        f_consume()

// ════════════════════════════════════════════════════════════
//  UNTOUCHED LIQUIDITY LEVELS
// ════════════════════════════════════════════════════════════
var line[] liveLines = array.new<line>()
if showLive and barstate.islast
    if array.size(liveLines) > 0
        for j = 0 to array.size(liveLines) - 1
            line.delete(array.get(liveLines, j))
        array.clear(liveLines)
    if array.size(hiPrice) > 0
        for i = 0 to array.size(hiPrice) - 1
            array.push(liveLines, line.new(array.get(hiBar, i), array.get(hiPrice, i), bar_index + 5, array.get(hiPrice, i), color=color.new(cSell, liveTr), width=1, style=line.style_dashed))
    if array.size(loPrice) > 0
        for i = 0 to array.size(loPrice) - 1
            array.push(liveLines, line.new(array.get(loBar, i), array.get(loPrice, i), bar_index + 5, array.get(loPrice, i), color=color.new(cBuy, liveTr), width=1, style=line.style_dashed))

// ════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════
alertcondition(firedBuySeq2,  title="2nd bullish sweep in sequence", message="Liquidity Sweep: second sell-side sweep confirmed - two-stage liquidity grab complete")
alertcondition(firedSellSeq2, title="2nd bearish sweep in sequence", message="Liquidity Sweep: second buy-side sweep confirmed - two-stage liquidity grab complete")
alertcondition(firedBuyMaj,   title="Major bullish sweep",           message="Liquidity Sweep: major sell-side liquidity swept and confirmed")
alertcondition(firedSellMaj,  title="Major bearish sweep",           message="Liquidity Sweep: major buy-side liquidity swept and confirmed")
````
