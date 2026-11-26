# PEAD strategy

- url: https://www.tradingview.com/script/tKPgsKss-PEAD-strategy/
- type: strategy
- pine_id: PUB;81a583cbb4c7462c9180f2a8ab638c80
- version: 4.0

## Description

█ [b]OVERVIEW[/b]

This strategy trades the classic post-earnings announcement drift (PEAD).  
It goes long only when the market gaps up after a positive EPS surprise.

[English follows | 日本語は後半にあります]

█ [b]LOGIC[/b]

1 — [b]Earnings filter[/b] — EPS surprise > [i]epsSprThresh[/i] %  
2 — [b]Gap filter[/b] — first regular 5-minute bar gaps ≥ [i]gapThresh[/i] % above yesterday’s close  
3 — [b]Timing[/b] — only the [i]first[/i] qualifying gap within one trading day of the earnings bar  
4 — [b]Momentum filter[/b] — last [i]perfDays[/i] trading-day performance is positive  
5 — [b]Risk management[/b]  
  • Fixed stop-loss: [i]stopPct[/i] % below entry  
  • Trailing exit: price < Daily EMA([i]emaLen[/i])

█ [b]INPUTS[/b]

• [b]Gap up threshold (%)[/b] — 1 (gap size for entry)  
• [b]EPS surprise threshold (%)[/b] — 5 (min positive surprise)  
• [b]Past price performance[/b] — 20 (look-back bars for trend check)
• [b]Fixed stop-loss (%)[/b] — 8 (hard stop distance)  
• [b]Daily EMA length[/b] — 30 (trailing exit length)  

[i]Note[/i] — Back-tests fill on the second 5-minute bar (Pine limitation).  
Live trading: enable [code]calc_on_every_tick=true[/code] for first-tick entries.

────────────────────────────────────────────

█ [b]概要（日本語）[/b]

本ストラテジーは決算後の PEAD を狙い、  
[b]EPS サプライズがプラス[/b] かつ [b]寄付きギャップアップ[/b] が発生した銘柄をスイングで買い持ちします。

█ [b]ロジック[/b]

1 — [b]決算フィルター[/b] — EPS サプライズ > [i]epsSprThresh[/i] %  
2 — [b]ギャップフィルター[/b] — レギュラー時間最初の 5 分足が前日終値＋[i]gapThresh[/i] %以上  
3 — [b]タイミング[/b] — 決算当日または翌営業日の最初のギャップのみエントリー  
4 — [b]モメンタムフィルター[/b] — 過去 [i]perfDays[/i] 営業日の騰落率がプラス  
5 — [b]リスク管理[/b]  
  • 固定ストップ：エントリー − [i]stopPct[/i] %  
  • 利確：終値が日足 EMA([i]emaLen[/i]) を下抜け

█ [b]入力パラメータ[/b]

• [b]Gap up threshold (%)[/b] — 1 (ギャップ条件)  
• [b]EPS surprise threshold (%)[/b] — 5 (EPS サプライズ最小値)  
• [b]Past price performance[/b] — 20 (パフォーマンス判定日数)
• [b]Fixed stop-loss (%)[/b] — 8 (固定ストップ幅)  
• [b]Daily EMA length[/b] — 30 (利確用 EMA 期間)  

[i]注意[/i] — Pine の仕様上、バックテストでは寄付き 5 分足の次バーで約定します。  
実運用で寄付き成行に合わせたい場合は [code]calc_on_every_tick=true[/code] を有効にしてください。

────  
ご意見や質問があればお気軽にコメントください。  
Happy trading!

## Source Code

````pine
//@version=5
strategy("PEAD Strategy", overlay=true, calc_on_every_tick=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// ────── User Inputs ──────
gapThresh     = input.float(1.0 , "Gap-up threshold (%)", minval=0.1)
epsSprThresh  = input.float(5.0 , "EPS surprise threshold (%)", minval=0.1)
perfDays      = input.int  (20  , "Positive-performance look-back", minval=0)
stopPct       = input.float(8.0 , "Initial fixed stop-loss (%)", minval=0.1)
emaLen        = input.int  (50  , "Daily EMA length for trail stop", minval=1, maxval=400)
maxHoldBars   = input.int  (50  , "Exit after N bars from entry", minval=1)

// ────── Earnings Data (Daily) ──────
epsAct   = request.earnings(syminfo.tickerid, earnings.actual  , barmerge.gaps_on)
epsEst   = request.earnings(syminfo.tickerid, earnings.estimate, barmerge.gaps_on)

earnBar  = request.security(syminfo.tickerid, "D", ta.change(epsAct)!=0 or (not na(epsAct) and na(epsAct[1])), lookahead=barmerge.lookahead_on)
daysSinceEarn = ta.barssince(earnBar)

[epsSurpPct, posSurprise] = request.security(syminfo.tickerid, "D", [ (epsAct - epsEst) / math.abs(epsEst) * 100, (epsAct - epsEst) / math.abs(epsEst) * 100 > epsSprThresh ], lookahead=barmerge.lookahead_on)

// ────── Gap-Up Detection and Past Performance ──────
gapOpen = request.security(syminfo.tickerid, "D", (close[1] != 0 ? (open / close[1] - 1) : 0) >= gapThresh / 100, lookahead=barmerge.lookahead_on)

perfPos = request.security(syminfo.tickerid, "D", close[1] > close[perfDays + 1], lookahead=barmerge.lookahead_on)

// ────── Entry Logic ──────
isNewDay  = ta.change(time("D")) != 0
entryCond = isNewDay and posSurprise and perfPos and gapOpen and daysSinceEarn <= 1 and strategy.position_size == 0

if entryCond
    strategy.entry("PEAD", strategy.long)

// ────── EMA Exit Logic ──────
emaDaily = request.security(syminfo.tickerid, "D", ta.ema(close, emaLen), lookahead=barmerge.lookahead_on)

emaExit = strategy.position_size > 0 and ta.crossunder(close, emaDaily)
if emaExit
    strategy.close("PEAD", comment="EMA" + str.tostring(emaLen) + " cross-under")

// ────── Fixed Stop / Breakeven Exit Logic ──────
var float stopLvl = na
var bool fixedExit = false

if strategy.position_size > 0
    if na(stopLvl)
        stopLvl := strategy.position_avg_price * (1 - stopPct / 100)

    if strategy.opentrades > 0
        tradeProfit = close -  strategy.position_avg_price
        riskAmount = strategy.position_avg_price * (stopPct / 100)
        if not na(tradeProfit) and tradeProfit >= 2 * riskAmount and stopLvl < strategy.position_avg_price
            stopLvl := strategy.position_avg_price

    // Only submit stop order if stopLvl is above current price
    if close > stopLvl
        strategy.exit("Fixed SL", from_entry="PEAD", stop=stopLvl)
        fixedExit := true
else
    stopLvl := na
    fixedExit := false

// ────── Max Hold Exit Logic ──────
var int entryBar = na
if ta.change(strategy.position_size) > 0
    entryBar := bar_index
if strategy.position_size == 0
    entryBar := na

barsInTrade = strategy.position_size != 0 and not na(entryBar) ? bar_index - entryBar : 0
maxHoldExit = strategy.position_size > 0 and barsInTrade >= maxHoldBars
if maxHoldExit
    strategy.close("PEAD", comment="Max-hold exit")

// ────── Track Last Exit Type for Accurate Labeling ──────
var string lastExitType = na

if emaExit
    lastExitType := "EMA"

if maxHoldExit
    lastExitType := "MAXHOLD"

if fixedExit and not emaExit and not maxHoldExit
    lastExitType := "SL_BE"

// ────── Plot Shapes ──────
plotshape(earnBar    , "Earnings bar" , shape.triangledown, color=color.gray   , location=location.belowbar, size=size.small)
plotshape(entryCond  , "Entry"        , shape.triangleup  , color=color.yellow , location=location.belowbar, size=size.small)
plotshape(posSurprise, "Positive EPS" , shape.circle      , color=color.green  , location=location.abovebar, size=size.tiny)

// ────── Visual Labels: ENTRY ──────
if entryCond
    label.new(bar_index, low * 0.97, text="ENTRY", yloc=yloc.price, style=label.style_label_up, color=color.new(color.yellow, 0), textcolor=color.black, size=size.small)

// ────── Visual Labels: EPS Surprise ──────
if posSurprise
    label.new(bar_index, high, text="EPS: " + str.tostring(epsSurpPct, "#.##") + "%", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.purple, 0), textcolor=color.white, size=size.tiny)

// ────── Visual Labels: EXIT (Single Type Only) ──────
justClosed = ta.change(strategy.position_size) < 0

if justClosed and not na(lastExitType)
    labelColor = lastExitType == "EMA"     ? color.red     :
                 lastExitType == "MAXHOLD" ? color.fuchsia :
                 color.orange

    labelText = "EXIT: " + lastExitType
    label.new(bar_index, high * 1.03, text=labelText, yloc=yloc.price, style=label.style_label_down, color=labelColor, textcolor=color.white, size=size.small)

    lastExitType := na  // reset
````
