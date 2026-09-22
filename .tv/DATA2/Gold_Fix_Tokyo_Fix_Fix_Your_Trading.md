<!-- tradingview-pine-id: PUB;0b1533639a4643df8b9d3ae7f937cefd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Gold Fix — Tokyo Fix (Fix Your Trading)

Source: https://www.tradingview.com/script/zboM6lBb-Gold-Fix-Tokyo-Fix-Fix-Your-Trading/

## Description

This indicator marks the Tokyo gold fix on your chart: the scheduled minute (09:55 Tokyo time) when a benchmark price for gold is set during the Asian session. It is a time anchor, not a signal — it tells you when a scheduled institutional pricing event occurs, and what price your chart printed at that moment. It makes no predictions and plots no direction.

How it works. The script detects the bar containing 09:55 Asia/Tokyo using a session window, so it functions on any timeframe: on a 1-minute chart it marks the fix minute itself; on higher timeframes it marks the bar containing that minute. It highlights that bar's background, records the close of the fix bar, and extends it right as a horizontal line labelled with the fix name. Yesterday's line is kept in a faded colour for reference; older lines are removed. Japan does not observe daylight saving, so the fix time never shifts on the UTC clock.

How to use it. Add it to a gold chart (XAUUSD or similar) and observe how price behaves around the marked minute and the anchor line — before it, at it, and in the sessions after. It pairs naturally with a 1-minute or 5-minute view of the Asian session.

Limitations. The recorded price is your chart's close of the fix bar, which is a practical proxy — it is not the official benchmark print, which is published separately and may differ by a broker-dependent spread. On timeframes above 1 minute the anchor uses the containing bar's close. The indicator draws only the Tokyo morning fix; other scheduled fixes exist in the gold day and are not drawn by this version.

Open-source so the timing logic can be verified.

---

## Source Code

````pine
// Gold Fix Indicator — Tokyo Fix (free teaser, PUBLIC library)
// Marks the Tokyo gold fix (09:55 Asia/Tokyo — Japan has no DST) on any XAUUSD chart,
// with today's and yesterday's fix price. That's all it does, on purpose.
// The full clock — both Tokyo fixes and both London auctions — is free via
// The Weekly Fix: whop.com/fix-your-trading
//
// Publish as OPEN-SOURCE (nothing here is secret; a time marker can't be a signal),
// which also sits best with TradingView House Rules for public scripts.

//@version=6
indicator("Gold Fix — Tokyo Fix (Fix Your Trading)", overlay=true, max_lines_count=10, max_labels_count=10)

bool  i_bg   = input.bool(true, "Highlight the fix minute/bar")
bool  i_ray  = input.bool(true, "Draw fix price line")
bool  i_lbl  = input.bool(true, "Show label")
bool  i_yday = input.bool(true, "Keep yesterday's fix (faded)")
color C_TOK  = input.color(#00ff88, "Tokyo Fix")

int _transBG  = 78
int _transOld = 85

// Bar overlapping the fix minute (works on any timeframe; DST-free, JST is fixed)
inTok   = not na(time(timeframe.period, "0955-0956", "Asia/Tokyo"))
fireTok = inTok and not inTok[1]

bgcolor(i_bg and inTok ? color.new(C_TOK, _transBG) : na)

var line  today_ln = na
var label today_lb = na
var line  yday_ln  = na

if fireTok
    // retire yesterday's, fade today's into yesterday's, draw the new one
    line.delete(yday_ln)
    if i_yday and not na(today_ln)
        line.set_color(today_ln, color.new(C_TOK, _transOld))
        yday_ln := today_ln
    else
        line.delete(today_ln)
    label.delete(today_lb)
    today_ln := i_ray ? line.new(bar_index, close, bar_index + 1, close, extend=extend.right, color=C_TOK, width=1) : na
    today_lb := i_lbl and i_ray ? label.new(bar_index, close, "Tokyo fix", style=label.style_label_left, textcolor=C_TOK, color=color.new(color.black, 100), size=size.small) : na

// The fix price recorded is your chart's close of the fix minute — a time anchor,
// not the official auction print. No signals, no direction, no promises.
````
