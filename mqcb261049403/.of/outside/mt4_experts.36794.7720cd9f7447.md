News-straddle breakout strategy driven by an external economic-calendar feed. It applies to whatever instrument the bot runs on and does not filter events by the instrument's currency or country.

1. Event list. Periodically (on a timer, not every tick) download the current week's economic calendar from a web feed in XML format. Parse each event's title, country, date, time and impact level. Keep only events whose impact is the highest level (high impact) and whose release datetime, in GMT, is still in the future. For each kept event, store the release time and an expiry time a short fixed interval after the release. The stored list is what the trading step reads.

2. Trading step, run on every price tick. Use the current GMT time. For each stored high-impact event, check whether the current time falls inside a short pre-release window. The window opens a short fixed time before the release and closes at the release time. Outside the window, do nothing for that event.

3. Entry. If the current time is inside the window, evaluate the two sides independently:
 - Long side: if the bot has no existing pending buy-stop order of its own on this symbol, and the configured lot size is valid for the symbol (not below the minimum, not above the maximum, and an exact multiple of the volume step), place a pending buy-stop order. Its entry price is the current ask plus a fixed distance in points. Its stop-loss is a fixed distance below the entry price. Its take-profit is a fixed distance above the entry price, and a zero value means no take-profit.
 - Short side: if the bot has no existing pending sell-stop order of its own on this symbol, and the lot size is valid, place a pending sell-stop order. Its entry price is the current bid minus a fixed distance in points. Its stop-loss is a fixed distance above the entry price. Its take-profit is a fixed distance below the entry price.
 - Both pending orders get an expiry a short fixed time after placement, so any order not triggered by the news move is cancelled automatically.
 - Identify the bot's own pending orders by a comment tag combining side, symbol, timeframe and a news suffix. This prevents duplicate placement while an order of that side is still pending.

4. Exit. There is no discretionary exit logic. Positions that are triggered close only through their fixed stop-loss or take-profit. Untriggered pending orders disappear at their expiry.

5. The long and short decisions are symmetric. Whichever pending order the post-news price move reaches first becomes the position.