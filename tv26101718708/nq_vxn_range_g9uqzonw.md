# NQ VXN Range

- url: https://www.tradingview.com/script/G9UQzonw/
- type: indicator
- pine_id: PUB;f44afe05d6004aeab4af6f5b4ae5ad57
- version: 1.0

## Description

Using option-implied volatility (VXN / VIX), one can back-calculate the approximate magnitude of a single standard deviation for the day. Then, centering this range on the day's opening price at 9:30 ET, one can construct a symmetrical "expected volatility band."

Intuition: Through option pricing, the market itself signals to you "roughly how much it expects to fluctuate today." If the price breaks outside this band, it suggests that volatility has exceeded normal parameters; conversely, if it remains within the band, the market is simply engaging in "normal breathing."

## Source Code

````pine
//@version=6
indicator("NQ VXN Range", overlay=true)

// ─── 参数 ───────────────────────────────────────────
multiplier1     = input.float(0.5, title="Inner Band Multiplier (σ×N)", step=0.1)
multiplier2     = input.float(0.8, title="Outer Band Multiplier (σ×N)", step=0.1)
keepHistory     = input.bool(false, title="保留历史日线段（关闭只看当天）")
lineColor_up1   = input.color(color.new(color.green, 20), title="Inner Upper Band Color")
lineColor_down1 = input.color(color.new(color.red,   20), title="Inner Lower Band Color")
lineColor_up2   = input.color(color.new(color.green, 20), title="Outer Upper Band Color")
lineColor_down2 = input.color(color.new(color.red,   20), title="Outer Lower Band Color")
lineWidth       = input.int(1, title="Line Width", minval=1, maxval=4)

// ─── 把合约强制切到 RTH 会话，请求日线 open = 9:30 ET 开盘 ─
rthTicker  = ticker.modify(syminfo.tickerid, session = session.regular)
rthDayOpen = request.security(rthTicker, "D", open, barmerge.gaps_off, barmerge.lookahead_on)

// ─── 抓 VXN 日线开盘 ────────────────────────────────
vxnDayOpen = request.security("CBOE:VXN", "D", open, barmerge.gaps_off, barmerge.lookahead_on)

// ─── 线对象 ─────────────────────────────────────────
var line lnUpper1 = na
var line lnLower1 = na
var line lnUpper2 = na
var line lnLower2 = na

// ─── 每天 RTH 开盘值变化时刷新 ──────────────────────
newDay = not na(rthDayOpen) and not na(vxnDayOpen) and ta.change(rthDayOpen) != 0

if newDay
    if not keepHistory
        line.delete(lnUpper1)
        line.delete(lnLower1)
        line.delete(lnUpper2)
        line.delete(lnLower2)
    else if not na(lnUpper1)
        line.set_extend(lnUpper1, extend.none)
        line.set_extend(lnLower1, extend.none)
        line.set_extend(lnUpper2, extend.none)
        line.set_extend(lnLower2, extend.none)
        line.set_x2(lnUpper1, bar_index)
        line.set_x2(lnLower1, bar_index)
        line.set_x2(lnUpper2, bar_index)
        line.set_x2(lnLower2, bar_index)

    float sigma = rthDayOpen * (vxnDayOpen / 100.0) / math.sqrt(252)
    float u1 = rthDayOpen + sigma * multiplier1
    float l1 = rthDayOpen - sigma * multiplier1
    float u2 = rthDayOpen + sigma * multiplier2
    float l2 = rthDayOpen - sigma * multiplier2

    lnUpper1 := line.new(bar_index, u1, bar_index + 1, u1, color=lineColor_up1,   width=lineWidth, extend=extend.right)
    lnLower1 := line.new(bar_index, l1, bar_index + 1, l1, color=lineColor_down1, width=lineWidth, extend=extend.right)
    lnUpper2 := line.new(bar_index, u2, bar_index + 1, u2, color=lineColor_up2,   width=lineWidth, extend=extend.right)
    lnLower2 := line.new(bar_index, l2, bar_index + 1, l2, color=lineColor_down2, width=lineWidth, extend=extend.right)

// ─── 可选：在状态栏输出调试用的值（排查用）─────────
plot(rthDayOpen, title="DBG RTH Open", display = display.status_line)
plot(vxnDayOpen, title="DBG VXN Open", display = display.status_line)
````
