# Volume Vault | Volume Order Block Retest Strategy

- url: https://www.tradingview.com/script/ouvmvItR-Volume-Vault-Volume-Order-Block-Retest-Strategy/
- type: strategy
- pine_id: PUB;9f2201f3c7144aa193fe88dfcd76e59b
- version: 1.0

## Description

Volume Vault is a strategy that finds order block zones created by high-volume displacement candles and trades the first retest of each zone. A zone only forms when a candle has a large body relative to ATR and trades on above-average volume, so the strategy focuses on moves with real participation behind them. Each zone is drawn on the chart with its impulse volume ratio (for example “×1.8”), so you can see which zones were created on heavier volume.

Entries are taken when price returns to a zone and shows confirmation in the trade direction. Risk is defined from the start: the stop goes beyond the zone plus an ATR buffer, and the target is a multiple of that risk.

[b]How the Strategy Works[/b]
[list]
[*]Displacement detection: A candle counts as an impulse if its body is at least a set multiple of the previous bar’s ATR and its volume is at least a set multiple of the previous bar’s volume average.
[*]Zone creation: The candle before the impulse becomes the order block. A bullish impulse creates a demand zone and a bearish impulse creates a supply zone. You can use the full high/low range or just the candle body.
[*]Zone management: Zones extend to the right until they are invalidated (a close through the far side), expire (max age), or are pushed out by newer zones (max zone count). Overlapping same-direction zones are not duplicated.
[*]Retest entry: When price touches a zone while the strategy is flat, optional filters decide whether to enter. A zone is only marked as used when a trade actually fires, so a zone that fails the filters can still trade later.
[*]Exit: The stop sits beyond the zone plus an ATR buffer. The take profit is a fixed R multiple. The stop can move to break-even at a chosen R, and an optional time stop closes stale trades.
[*]Signals are evaluated on bar close and orders fill on the next bar, which avoids intrabar signal flicker.
[/list]

[b]Features[/b]
[list]
[*]Volume-qualified order block detection (body vs ATR plus volume vs average)
[*]Bullish and bearish zones drawn with the impulse volume ratio on each box
[*]Full range or body-only zone option
[*]Optional filters, each with its own toggle:
[*]opposite-colour candle before the impulse
[*]close beyond the prior candle’s range
[*]confirmation candle in the trade direction
[*]rejection wick with adjustable minimum size
[*]volume dry-up on the retest
[/list]

[b]EMA trend filter[/b]
[list]
[*]Zone consumed only when a trade fires
[*]ATR-buffered stop beyond the zone
[*]Fixed R-multiple take profit
[*]Optional break-even move and time stop
[*]Long and short toggles
[*]Impulse markers on the chart
[*]Realistic backtest defaults: 10% of equity per trade, 0.05% commission, 2 ticks slippage
[/list]

[b]Tips[/b]
[list]
[*]Start loose, then tighten. The defaults are set for higher trade frequency. Add filters one at a time (trend, rejection wick, volume dry-up) and watch how profit factor and drawdown change, not just net profit.
[*]Match the timeframe to your style. Lower timeframes (5m to 1h) produce more zones and trades. Higher timeframes produce fewer, larger setups.
[*]Use symbols with reliable volume. If volume data is missing or zero, set the impulse volume multiplier to 0 or the zones will not form.
[*]Tune ATR sensitivity per market. Volatile markets may need a higher displacement multiplier, and slower markets a lower one.
[*]Try the EMA filter. Trading only with the trend often reduces the number of losing counter-trend retests.
[*]Check results over a long sample. Aim for enough trades (100 or more) before drawing conclusions from the Strategy Tester.
[*]Adjust costs to your market. Update commission, slippage and position size to match your broker and instrument.
[/list]

[b]Warnings[/b]
[list]
[*]This is not financial advice. The script is for educational and research purposes.
[*]Past performance does not predict future results. A good backtest can come from overfitting to one symbol or period.
[*]Lower-frequency settings are not “safer”. Looser filters trade more but usually with lower quality per trade, and strict filters may leave you with too few trades to judge.
[*]Backtests are simplified. Real fills, spreads, gaps and slippage during fast moves can differ from the simulation.
[*]Orders fill on the next bar. Because signals use closed candles, entries can be some distance from the signal price, which affects the actual risk.
[*]Stops and targets can be hit in the same bar. The tester assumes a fixed order of events inside a bar, which may not match live trading.
[*]Volume varies by data source. Volume on spot, futures and different exchanges can differ, so results may not carry across markets.
[*]Risk management is your responsibility. Never risk money you cannot afford to lose, and forward test on a demo account first.
[/list]

## Source Code

````pine
//@version=6
// -----------------------------------------------------------------------------
// Volume Order Block Retest Strategy (higher-frequency defaults)
// DISCLAIMER: Educational only. Backtest results are not predictive. Not financial advice.
// -----------------------------------------------------------------------------
strategy("Volume Order Block Retest Strategy", overlay=true, max_boxes_count=100, max_labels_count=100,
  initial_capital=10000, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=10,
  commission_type=strategy.commission.percent, commission_value=0.05, slippage=2)

// ===================== INPUTS =====================
string G1 = "Order Block Detection"
int    atrLen     = input.int(14, "ATR length", minval=1, group=G1)
float  dispMult   = input.float(0.8, "Displacement body ≥ ATR ×", minval=0.1, step=0.1, group=G1)
int    volLen     = input.int(20, "Volume SMA length", minval=1, group=G1)
float  impVolMult = input.float(1.0, "Impulse volume ≥ SMA ×", minval=0.0, step=0.1, group=G1)
bool   needOpp    = input.bool(false, "Require opposite-colour candle before impulse", group=G1)
bool   needBreak  = input.bool(false, "Require impulse close beyond prior candle range", group=G1)
bool   bodyZone   = input.bool(false, "Use candle body only for zone (else full high/low)", group=G1)
int    maxZones   = input.int(15, "Max active zones", minval=1, maxval=40, group=G1)
int    maxAge     = input.int(300, "Max zone age (bars)", minval=10, group=G1)

string G2 = "Entry Filters"
bool   firstTouch   = input.bool(true, "Each zone trades once (consumed only when a trade fires)", group=G2)
bool   needCandle   = input.bool(true, "Require candle in trade direction", group=G2)
bool   useRejection = input.bool(false, "Require rejection wick", group=G2)
float  wickPct      = input.float(25.0, "Min wick % of range", minval=5, maxval=95, step=1, group=G2)
bool   useRetestVol = input.bool(false, "Require volume dry-up on retest", group=G2)
float  retestVolMax = input.float(1.0, "Retest volume ≤ impulse volume ×", minval=0.1, step=0.05, group=G2)
bool   useTrend     = input.bool(false, "EMA trend filter", group=G2)
int    emaLen       = input.int(100, "EMA length", minval=2, group=G2)
bool   allowLong    = input.bool(true, "Allow longs", group=G2)
bool   allowShort   = input.bool(true, "Allow shorts", group=G2)

string G3 = "Risk Management"
float  slBuf    = input.float(0.2, "SL buffer beyond zone (ATR ×)", minval=0.0, step=0.05, group=G3)
float  rrTarget = input.float(1.5, "Take profit (R multiple)", minval=0.2, step=0.1, group=G3)
bool   useBE    = input.bool(true, "Move stop to break-even", group=G3)
float  beAtR    = input.float(1.0, "Break-even trigger (R)", minval=0.2, step=0.1, group=G3)
int    maxBars  = input.int(60, "Time stop (bars, 0 = off)", minval=0, group=G3)

string G4 = "Visuals"
color  bullCol   = input.color(color.rgb(38, 166, 154), "Bull zone", group=G4)
color  bearCol   = input.color(color.rgb(239, 83, 80), "Bear zone", group=G4)
bool   showZones = input.bool(true, "Draw zones", group=G4)

// ===================== TYPES / STATE =====================
type OB
    float top
    float bottom
    float impVol
    int   bornBar
    bool  isBull
    bool  used
    box   bx

var array<OB> zones = array.new<OB>()

// ===================== CALCULATIONS =====================
float atr    = ta.atr(atrLen)
float volSma = ta.sma(volume, volLen)
float ema    = ta.ema(close, emaLen)

float body = math.abs(close - open)
float rng  = high - low
float upW  = high - math.max(open, close)
float loW  = math.min(open, close) - low

bool bigBody = body >= nz(atr[1]) * dispMult
bool bigVol  = volume >= nz(volSma[1]) * impVolMult

bool bullImpulse = close > open and bigBody and bigVol
     and (not needBreak or close > high[1])
     and (not needOpp or close[1] < open[1])
bool bearImpulse = close < open and bigBody and bigVol
     and (not needBreak or close < low[1])
     and (not needOpp or close[1] > open[1])

// ===================== MANAGE EXISTING ZONES (before new ones are created) =====================
bool  flat      = strategy.position_size == 0
bool  longSig   = false
bool  shortSig  = false
float sigBottom = na
float sigTop    = na

if zones.size() > 0
    for i = zones.size() - 1 to 0
        OB z = zones.get(i)
        bool dead = (z.isBull and close < z.bottom) or (not z.isBull and close > z.top) or (bar_index - z.bornBar > maxAge)
        if dead
            if not na(z.bx)
                box.delete(z.bx)
            zones.remove(i)
        else
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
            bool touched = high >= z.bottom and low <= z.top
            if touched and flat and not (firstTouch and z.used)
                bool volOK = not useRetestVol or volume <= z.impVol * retestVolMax
                if z.isBull
                    bool rej     = not useRejection or (rng > 0 and loW / rng * 100 >= wickPct)
                    bool trendOK = not useTrend or close > ema
                    bool candle  = not needCandle or close > open
                    if candle and close > z.bottom and rej and volOK and trendOK and allowLong and not longSig and not shortSig
                        longSig := true
                        sigBottom := z.bottom
                        z.used := true
                else
                    bool rej     = not useRejection or (rng > 0 and upW / rng * 100 >= wickPct)
                    bool trendOK = not useTrend or close < ema
                    bool candle  = not needCandle or close < open
                    if candle and close < z.top and rej and volOK and trendOK and allowShort and not longSig and not shortSig
                        shortSig := true
                        sigTop := z.top
                        z.used := true

// ===================== CREATE NEW ZONES =====================
f_overlaps(bool _bull, float _top, float _bot) =>
    bool hit = false
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            OB z = zones.get(i)
            if z.isBull == _bull and _top >= z.bottom and _bot <= z.top
                hit := true
    hit

f_addZone(bool _bull, float _top, float _bot) =>
    if not f_overlaps(_bull, _top, _bot)
        float ratio = nz(volSma[1]) > 0 ? volume / volSma[1] : 1.0
        box b = na
        if showZones
            b := box.new(bar_index - 1, _top, bar_index, _bot,
                 bgcolor=color.new(_bull ? bullCol : bearCol, 80), border_color=color.new(_bull ? bullCol : bearCol, 40),
                 text="×" + str.tostring(ratio, "#.0"), text_color=chart.fg_color, text_size=size.small,
                 text_halign=text.align_right)
        zones.push(OB.new(_top, _bot, volume, bar_index, _bull, false, b))
        if zones.size() > maxZones
            OB old = zones.shift()
            if not na(old.bx)
                box.delete(old.bx)

if bar_index > math.max(atrLen, volLen) + 1
    if bullImpulse and allowLong
        float zt = bodyZone ? math.max(open[1], close[1]) : high[1]
        float zb = bodyZone ? math.min(open[1], close[1]) : low[1]
        f_addZone(true, zt, zb)
    if bearImpulse and allowShort
        float zt = bodyZone ? math.max(open[1], close[1]) : high[1]
        float zb = bodyZone ? math.min(open[1], close[1]) : low[1]
        f_addZone(false, zt, zb)

// ===================== ENTRIES =====================
var float longStop  = na
var float longTp    = na
var float longRisk  = na
var float shortStop = na
var float shortTp   = na
var float shortRisk = na
var int   entryBar  = na

if longSig and flat
    float stopPx = sigBottom - atr * slBuf
    float risk   = close - stopPx
    if risk > syminfo.mintick
        longStop := stopPx
        longRisk := risk
        longTp   := close + risk * rrTarget
        strategy.entry("Long", strategy.long)
        label.new(bar_index, low, "L", style=label.style_label_up, color=color.new(bullCol, 20), textcolor=color.white, size=size.tiny)

if shortSig and flat
    float stopPx = sigTop + atr * slBuf
    float risk   = stopPx - close
    if risk > syminfo.mintick
        shortStop := stopPx
        shortRisk := risk
        shortTp   := close - risk * rrTarget
        strategy.entry("Short", strategy.short)
        label.new(bar_index, high, "S", style=label.style_label_down, color=color.new(bearCol, 20), textcolor=color.white, size=size.tiny)

if strategy.position_size != 0 and strategy.position_size[1] == 0
    entryBar := bar_index

// ===================== EXITS =====================
if strategy.position_size > 0
    float avg = strategy.position_avg_price
    if useBE and not na(longRisk) and high >= avg + longRisk * beAtR
        longStop := math.max(longStop, avg)
    strategy.exit("XL", from_entry="Long", stop=longStop, limit=longTp)
else if strategy.position_size < 0
    float avg = strategy.position_avg_price
    if useBE and not na(shortRisk) and low <= avg - shortRisk * beAtR
        shortStop := math.min(shortStop, avg)
    strategy.exit("XS", from_entry="Short", stop=shortStop, limit=shortTp)

if maxBars > 0 and strategy.position_size != 0 and not na(entryBar) and bar_index - entryBar >= maxBars
    strategy.close_all(comment="Time stop")

// ===================== PLOTS =====================
plot(useTrend ? ema : na, "EMA", color=color.new(color.gray, 30))
plotshape(bullImpulse, "Bull impulse", shape.triangleup, location.belowbar, color.new(bullCol, 50), size=size.tiny)
plotshape(bearImpulse, "Bear impulse", shape.triangledown, location.abovebar, color.new(bearCol, 50), size=size.tiny)
````
