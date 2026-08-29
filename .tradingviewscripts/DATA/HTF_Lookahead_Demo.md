<!-- tradingview-pine-id: PUB;8e3dd396bac744debe2cf075d7934ba9 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Lookahead Demo

Source: https://www.tradingview.com/script/0AyPNtct-HTF-Lookahead-Demo/

## Description

Two identical higher-timeframe requests plotted together, so you can see what lookahead actually does rather than take someone's word for it.

Both lines call request.security on the daily timeframe with lookahead = barmerge.lookahead_on. The only difference between them is a one-bar offset on the expression.

RED asks for the daily close with no offset. On a historical intraday bar it is already sitting at that day's closing price, a number that did not exist yet when the bar formed. Look at where it sits during the first hours of any day on the chart.

CYAN asks for close[1], the previous day's close. That was knowable at the time, so the line is honest. It is also duller, which is rather the point.

A strategy built on the red line backtests beautifully and cannot reproduce it live.

WHY NOT JUST TURN LOOKAHEAD OFF

Because the offset and the lookahead argument are interdependent. TradingView's documentation states that neither can be removed without compromising the result. There are four shapes and only one of them is correct:

expr[1] with lookahead_on - correct
expr with lookahead_on - leaks future data into historical bars
expr[1] with lookahead_off - history and realtime disagree, because the higher-timeframe bar only reaches the chart once it has closed, so the offset adds a full timeframe of lag on history that the live bar never gets
expr with lookahead_off - the realtime bar sees the still-forming higher-timeframe bar

The third one is the trap. It looks like the cautious choice.

NOTES

Any offset of one bar or more works. [2] is larger and strictly safer, so a checker that insists on a literal [1] will wrongly flag it as a repaint.

The daily timeframe and close are hard-coded on purpose. This is a demonstration, not a tool. The source is twelve lines, please read it.

Open source under MPL 2.0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon

//@version=6
indicator("HTF Lookahead Demo", "HTF Leak", overlay = true)

// Two identical higher-timeframe requests. Same symbol, same daily timeframe,
// same lookahead_on. The ONLY difference is a one-bar offset on the expression.
//
//   red   request.security(sym, "D", close,    lookahead_on)  <- leaks
//   cyan  request.security(sym, "D", close[1], lookahead_on)  <- correct
//
// On a historical intraday bar the red line already sits at that day CLOSING
// price, a number that did not exist yet when the bar formed. The cyan line
// sits at the previous day close, which was knowable at the time.
//
// The offset and the lookahead argument are interdependent: TradingView docs
// state that neither can be removed without compromising the result. Dropping
// the offset leaks the future. Keeping the offset but setting lookahead_off is
// worse than it looks, because the higher-timeframe bar only arrives once it
// has closed, so history gains a full timeframe of lag the live bar never has.
//
// Any offset of one bar or more is fine. [2] is larger and strictly safer.

leak = request.security(syminfo.tickerid, "D", close,    lookahead = barmerge.lookahead_on)
safe = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

plot(leak, "No offset - leaks future data", color = color.new(#ff4d4d, 0), linewidth = 2)
plot(safe, "close[1] - correct",            color = color.new(#22d3ee, 0), linewidth = 2)

// Shade the first bar of each new day so the steps are easy to line up.
bgcolor(ta.change(time("D")) != 0 ? color.new(color.gray, 88) : na)
````
