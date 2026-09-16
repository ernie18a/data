<!-- tradingview-pine-id: PUB;5395becb9c0c46a497aee9511fbf8ae8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AM - 7h Session Candles

Source: https://www.tradingview.com/script/MXeLV0hq-AM-7h-Session-Candles/

## Description

Version 2.0.0

This is a major version because two defaults changed, so the tool behaves differently out of the box than v1.0.0 did.

NEW: SESSION BOUNDARY LINES
• Vertical lines on the real price bars showing where each 7-hour bucket starts, so it is obvious which stretch of chart each drawn candle is made of: the daily open (A starts), plus 7 hours (L starts), plus 14 hours (N starts), and where N ends.
• They cover exactly the buckets the strip is showing and no more, so raising "Sessions back" extends the lines along with the candles. There is no second control that can fall out of step with the first.
• The times come from the same daily-open arithmetic that decides which minute belongs to which bucket, never from a fixed clock, so a line cannot drift away from the candle it marks on any symbol or across a daylight saving change.
• Drawn on 1 hour charts and below only. Above that a 7-hour boundary falls too far inside a single bar for the line to mark anything useful. The candles themselves are unaffected on every timeframe.
• Own input group: show, colour, style and thickness. Drawn light grey at a fixed 25 percent opacity, so a boundary reads as a reference mark rather than competing with the price action.

CHANGED DEFAULT: THE 3 HOUR OVERNIGHT STUB IS NOW PART OF N
• New "NY 7h Candle Data Composition" dropdown. The new default, "NY plus 3h Overnight Stub", folds the last three hours of the day into the same N candle, so N runs from hour 14 to the end of the day and nothing is discarded.
• Why: dropping those hours left three hours of price action in no candle at all, so one day's N closed and the next day's A opened with a hole between them that nothing on the strip accounted for. Including them gives an unbroken day, with every minute in some candle and the bodies joining up.
• What it costs, stated plainly: a 10-hour N is no longer TradingView's own 7-hour bar, and it is no longer the three-equal-block model this tool credits to AMTrades. Choose "NY 7h Candle" to restore both. That setting is exactly what v1.0.0 shipped as.
• The letter stays N either way and no fourth candle ever appears. Only N's high, low and close can move, and it keeps updating for three hours longer than before. Where a day never reaches hour 21 at all, a short regular session for instance, there is no stub and the setting has no effect.

REMOVED: VERTICAL POSITION
• The "Vertical Position" input and its "Centred on Current Price" mode are gone. The strip now always sits at true prices, so a session high or low reads straight across to where that level falls in the price action.
• Why: centred mode added a constant to every drawn price and recomputed it on every tick, so the whole strip slid up and down as price moved and the completed A, L and N candles looked as though they were still forming. It was the default, so that was the out of the box behaviour.
• If you had already selected "Relative Position", your strip is unchanged.
• The cost is that a wide strip is now counted by the chart's auto scale and can compress the price action. Pine cannot exempt an overlay drawing from the scale, so the levers are a lower "Sessions back" or turning auto scale off.

SETTINGS PANEL
• Every tooltip rewritten in short lines, with anything that is a list set out one item per line instead of running on as a paragraph. A settings dialog does not wrap a paragraph usefully and a long one arrived as a dense slab.
• Laid out one row per element rather than one control per line. The boundary lines are a single row: the toggle carrying the name, then the colour, the style, and the width. The three candle colours share a row, and Wick Width shares one with Label Size. Fifteen rows became six, and each field now sits against its own label instead of in the dialog's shared left aligned column.
• Both Opacity inputs are gone. The candles are fixed fully solid and the boundary lines fixed faint, each at exactly what its input used to default to, so a chart on the defaults looks the same as before. Two fewer controls to set.

SMALLER CHANGES
• Candle Width and Gap Between Candles are no longer inputs. They are fixed at 2 bars and 1 bar, down from the 6 and 3 v1.0.0 shipped with, for a tighter strip. The wick still sits on true centre because 2 is even. Offset From Last Bar is now the only layout control.
• The originator is now credited as AMTrades throughout, rather than "AM".
• Documented that Extended hours is not the same as 24 hours and what it contains depends on the feed. US equity extended hours are 04:00 to 20:00, which is 16 hours, so even with the setting correct N gets only the two hours left after A and L and is a 2-hour candle presented as a New York 7-hour one.

FEEDBACK
Please let me know if you experience any issues, or have feedback for improvements or additions in the comments below. Thank you, Tom

---

## Source Code

````pine
//@version=6
// =============================================================================
// AM - 7H SESSION CANDLES
// =============================================================================
// Author:       Tom Brown
// Description:  The 7-hour session model is AMTrades' core idea, credited to him with thanks
//               (see the CREDIT note below). RUN ON EXTENDED HOURS (ETH) ONLY, and ONLY
//               on a Japanese candlestick or bar chart — see the notes below.
//               Draws the three 7-hour "HTF candles" of the trading day as a small
//               candle strip in the empty space to the right of the last bar. Each
//               bucket is measured from the instrument's OWN daily open: A(sia) =
//               hours 0-7, L(ondon) = 7-14, N(ew York) = 14-21. Hours 21-24 are the
//               3h overnight stub, and BY DEFAULT they are folded into the N candle,
//               which then runs from hour 14 to the end of the day. The
//               NY 7h Candle Data Composition input can drop them instead, which is
//               the original three-block model. OHLC is aggregated from 1-minute data, so
//               the candles are 1-minute accurate wherever intrabars are available
//               (on charts at or below 1 minute the chart bar is used and is already
//               at least that fine). Today's buckets are drawn as they form,
//               optionally preceded by up to six completed buckets walking back
//               through the prior days. The strip sits at true prices. Optional
//               vertical boundary lines mark where each bucket starts
//               and ends on the real price bars.
// Version:      2.0.0
// Date:         2026-08-24
// =============================================================================
// Notes for future-me:
//   - ⭐ CREDIT — THE 7-HOUR SESSION MODEL IS AMTRADES'. The idea this whole tool is built
//     on is his: splitting the trading day into three 7-hour blocks anchored on the daily
//     open, and reading Asia / London / New York off them. It is his core concept,
//     taught on his YouTube channel, and this tool exists because of it. Written with
//     respect and acknowledgement to AMTrades. It is an independent implementation of his
//     idea, not a copy of anyone's code: the TradingView script "AM - 7H HTF Candles"
//     (AUDE_FX) is protected source, so it was never readable and nothing was taken
//     from it. Keep this credit on the tool, in the description, and anywhere it is
//     published.
//   - The bucket rule is IDENTICAL to the "7H HTF Candles" Sessions Model in
//     market_liquidity_levels.pine (elapsed ms since time("D"), integer-divided by
//     7h; index 0/1/2 = A/L/N, index 3 ignored). ⛔ THE TWO TOOLS NOW AGREE ONLY ON
//     `NY 7h Candle Data Composition` = 'NY 7h Candle', WHICH IS NOT THE SHIPPED
//     DEFAULT. The default
//     folds index 3 into N, so out of the box this tool deliberately diverges from
//     market_liquidity_levels, which has no such option and still ignores index 3 —
//     correct for it. Do not "fix" the difference by copying the stub option across
//     without deciding that on its own merits, and do not assume the shipped behaviour
//     of the two tools matches, because it does not.
//   - Daily-open anchored means NO timezone handling and NO DST toggle: the anchor
//     is the instrument's own daily open, which already carries its exchange's
//     clock and DST rules.
//   - WHY per-INTRABAR bucketing, not per-chart-bar: a chart bar can straddle the
//     daily open (e.g. a 4h bar spanning 21:00-01:00). Each 1-minute intrabar
//     carries its OWN time("D") from the nested request, so the minutes before the
//     open are booked to the previous day's N bucket and the minutes after to the
//     new day's A bucket. Bucketing on the chart bar's single timestamp would push
//     the whole bar into one day and corrupt both.
//   - INTRABAR-HISTORY LIMIT: request.security_lower_tf can only reconstruct a
//     bounded number of intrabars (TradingView caps this per plan), which is what
//     bounds how far back buckets can be rebuilt on high chart timeframes. The
//     practical limit here is not binding: 6 sessions back reaches at most ~3
//     calendar days = ~4,320 one-minute intrabars, which fits inside the intrabar
//     budget on every plan and every chart timeframe this runs on. The cap only
//     starts to matter for depths far beyond the 6-session maximum.
//   - Buckets accumulate into `var` arrays and rely on Pine's realtime rollback, so
//     the live (current) bucket re-accumulates cleanly from its intrabars on every
//     tick instead of double-counting them.
//   - ACCURACY IS CONDITIONAL, not unconditional: a bucket is 1-minute accurate when
//     intrabars are returned, and equally accurate on charts at or below 1 minute
//     where the chart bar itself is the finest data available. Above 1 minute, if the
//     intrabar request comes back empty (budget exhausted deep in history) the bucket
//     is SKIPPED rather than rebuilt coarsely from a multi-hour chart bar — same rule
//     as "a bucket with no data is not drawn".
//   - Drawing is last-bar-only delete-then-redraw, so a reload reproduces exactly
//     the same objects (provenance: PINE/snippets/3-object-mgmt/
//     full-refresh-cleanup-and-lazy-label.md and 4-forward-projection/
//     projected-box-line-future-bar.md — last-bar guard + 500-bar clamp).
//   - Max 9 candles (3 today + 6 back) = 9 boxes / 9 lines / 9 labels, plus at most 16
//     boundary lines (a start per drawn bucket, plus an end wherever the next drawn bucket
//     does not continue from it — worst case is every prior bucket isolated, 6 starts +
//     6 ends, on top of today's 3 starts + 1 end). 25 lines worst case, so every type stays
//     inside Pine's default per-type budget of 50 and no max_*_count override is needed.
//   - THE BOUNDARY LINES SPAN THE DRAWN BUCKETS AND NOTHING ELSE. They are built from the
//     drawn set's own keys (indices `start` to `n - 1`), so Sessions back moves the candles
//     and the lines together and there is no second control to fall out of step. A drawn
//     bucket contributes its start; it contributes its end only where the next drawn bucket
//     does not begin there. On the DEFAULT composition, N's end is not drawn at all: N
//     runs to the end of the day, that instant IS the next daily open, and the next bucket's
//     own start already marks it. On 'NY 7h Candle' the 21:00-24:00 gap intervenes after N,
//     so there N's end IS drawn as a boundary in its own right. One exception falls
//     out of that and is accepted: if the next day's A bucket is missing for want of data,
//     nothing marks the roll, because the instant was never observed and the only way to
//     draw it would be to assume a day length.
//     Precisely: the lines are the drawn buckets' own starts and ends. Where a bucket was
//     skipped for want of data the neighbouring bucket's end still draws, so a boundary can
//     mark an instant no candle sits beside. It is still that bucket's true edge.
//     Consequence worth knowing: no buckets means no lines, so on a chart where the intrabar
//     request comes back empty and every bucket is skipped, nothing is drawn at all. That is
//     the intended reading of "the lines cover what the strip shows".
//   - BOUNDARY LINES ARE GATED TO 1H AND BELOW. Above that a 7-hour boundary falls too far
//     inside a single chart bar for the line to mark anything useful, so drawing it would
//     assert a precision the chart cannot show. The candles are NOT gated and render on
//     every timeframe.
//   - ⭐ WHY THE BOUNDARY LINES ARE DERIVED FROM THE BUCKET MATHS, NOT FROM A CLOCK. Every
//     boundary timestamp is the instrument's OWN daily open plus 0 / 7 / 14 hours, plus the
//     bucket ends where those are drawn —
//     the same `time("D")` anchor and the same 7h step that decide which bucket an
//     intrabar is booked to. That is the whole point: a line and the candle it marks are
//     computed from one source, so they cannot drift apart on any symbol, any feed, or
//     across a DST change. A fixed-clock implementation (draw at 00:00 / 07:00 / 14:00 in
//     some named timezone) looks identical on a symbol whose day happens to open at that
//     hour and is silently wrong on every other one — its lines wander away from its own
//     candles. Do NOT reintroduce a timezone, a session string, or a DST toggle here.
//     The boundary instants are the drawn buckets' OWN keys, so there is no second store
//     and no second source to fall out of step: no buckets means no lines. The store is
//     assumed strictly increasing, which the push guard maintains, and the dedupe below
//     relies on that.
//   - A boundary in the FUTURE is not drawn. That is a CHOICE, not a limitation: forward
//     drawing with `xloc.bar_time` works — the 500-bar future-drawing limit exists precisely
//     because Pine does render ahead of the last bar — but a boundary the day has not
//     reached yet marks nothing that has happened, so it is chart noise. The test is
//     `math.min(time_close, timenow)`: a boundary reached INSIDE the live bar draws
//     immediately, one still ahead of the clock does not, and on a closed market the bound
//     stays at the end of the data instead of running out into empty space. Today's later
//     boundaries appear as the day reaches them.
//   - EXTENDED HOURS (ETH) ONLY. This is a usage instruction, not a preference. The three
//     buckets need a ~21-hour day, and a Regular-hours session is typically far shorter — US
//     equities are 6.5h. On a session under 7h every intrabar of the day books to bucket 0, so
//     the strip shows nothing but "A" candles; on a longer regular session (European cash, ~8.5h)
//     L appears but N never can. It is
//     silent: the tool looks like it is working. Set the chart to Extended hours on any symbol
//     that offers the choice. Symbols that trade continuously (FX, crypto, index CFDs) have no
//     such setting and are unaffected. Deliberately NOT enforced in code —
//     gating on syminfo.session would false-fire on the continuous symbols.
//   - EXTENDED HOURS IS NOT 24 HOURS, AND IT IS FEED-DEPENDENT. Setting the chart to Extended
//     does not guarantee the ~21-hour day the three buckets need: US-equity extended hours are
//     04:00-20:00, i.e. 16h, so A takes hours 0-7, L takes 7-14 and N gets only the two hours
//     that remain. Every drawn value is arithmetically correct, but N is then a 2-hour candle
//     presented as a New York 7-hour session candle, and `NY 7h Candle Data Composition` makes no difference
//     to it. Read the strip on such a symbol knowing N is truncated. Also a usage note, not a
//     code gate, for the same reason as the ETH instruction above.
//   - JAPANESE CANDLESTICK OR BAR CHARTS ONLY. Also a usage instruction, and also deliberately
//     NOT enforced in code. On Heikin Ashi the lower-timeframe request returns
//     HA-TRANSFORMED data, so the session candles are averaged synthetic values that look
//     entirely normal but match no real session high or low. On Renko, Kagi, Point & Figure and
//     Range the bar timestamps are not clock time at all, so src_t - src_d is meaningless and
//     the bucket assignment is arbitrary. Line and area charts are fine — they carry the same
//     real OHLC underneath, only the rendering differs.
//   - THE 3H OVERNIGHT STUB is hours 21 to 24 of the day, and BY DEFAULT it is folded into
//     the N candle, keyed to the SAME bucket (daily open + 14h) so N simply runs from hour
//     14 to the end of the day and
//     no fourth candle appears, and where the day has no such remainder (a short session that
//     never reaches hour 21) the option is simply inert. The letter stays N. Only N's high,
//     low and close can move,
//     its open cannot, and it keeps updating for three hours longer than it otherwise would.
//     What the default gives up, and Tom chose it knowingly on 2026-08-20: a 10-hour N is
//     not TradingView's 7h bar, so the candle-for-candle match with a TV 7h chart is lost,
//     and it is not the three-equal-block model this tool credits to AMTrades. `Data
//     Inclusion` set to 'NY 7h Candle' restores both. The published v1.0.0 behaviour is
//     that setting, not this one, so the listing description has to say so at republish.
//   - WHY THE STUB IS THE DEFAULT (Tom, 2026-08-20). Dropping it leaves three hours of price
//     action in no candle at all, so one day's N closes and the next day's A opens with a
//     hole between them that nothing on the strip accounts for. Folding it in costs the
//     purity of a 7-hour N and buys an unbroken day: every minute is in some candle, the
//     bodies join up, and the strip reads as one continuous sequence. Tom's words: the last
//     NY is not pure 7h, but it removes gaps in the bodies that would otherwise be there,
//     and it is cleaner to his eye. That is a reading preference, not a correctness claim,
//     and it is why the choice is an input rather than a rewrite.
//   - THE STRIP SITS AT TRUE PRICES AND THERE IS NO CHOICE ABOUT IT. A 'Centred on
//     Current Price' mode existed up to v1.0.0 and was the default: it added one
//     constant, `close - midrange`, to every drawn price so the strip's mid-range sat
//     level with the live price. Removed in 2.0.0 because that constant is recomputed
//     on EVERY TICK, so the whole strip visibly slides up and down as price moves and
//     the completed A / L / N candles look like they are still forming. Do not
//     reintroduce it. The cost of true prices is that a wide strip is counted by the
//     chart's auto-scale and can compress the price action; that is the accepted
//     trade, because a level that reads straight across is the point of the tool.

indicator("AM - 7h Session Candles", overlay = true)

// --- input group headers ------------------------------------------------------
grp_sessions   = "════════ SESSIONS ════════"
grp_ny         = "════════ NY 7H CANDLE ════════"
grp_styling    = "════════ CANDLE STYLING ════════"
grp_layout     = "════════ LAYOUT ════════"
grp_boundaries = "════════ SESSION BOUNDARY LINES ════════"

// --- sessions -----------------------------------------------------------------
sessions_back = input.int(1, "Sessions back", minval = 0, maxval = 6, group = grp_sessions, inline = "sess_back", tooltip = "How many COMPLETED buckets to show\nbefore today's first bucket.\n\n- 0 = today only.\n- 1 = also the previous day's N\n  (New York) candle.\n- 6 reaches back roughly two days.\n\nIt counts buckets that HAVE DATA, not\ncalendar days, so across a holiday or a\npartial session it reaches further back.\n\nToday's own buckets are always drawn as\nthey form.")

// --- NY 7h candle -------------------------------------------------------------
ny_mode = input.string("NY + 3h Overnight Stub", "NY 7h Candle Data Composition", options = ["NY 7h Candle", "NY + 3h Overnight Stub"], group = grp_ny, inline = "ny_mode", tooltip = "What the N (New York) candle is built from.\n\n1. NY + 3h Overnight Stub (the default)\n  - Folds the 3h overnight stub into the\n    SAME N candle.\n  - N runs from hour 14 to the end of the\n    day and nothing is discarded.\n  - The letter stays N and no fourth\n    candle appears.\n  - Only N's high, low and close can move,\n    and it keeps updating for three hours\n    longer.\n\n2. NY 7h Candle\n  - The original model: hours 14 to 21\n    from the daily open.\n  - The last three hours of the day are a\n    gap, never drawn and never\n    accumulated.\n\nWhere a day never reaches hour 21 at all,\na short regular session for instance,\nthere is no stub and the default is inert.\n\nWhat the default gives up:\n- It does not match TradingView's own 7h\n  bars.\n- It is not the three-equal-block model\n  this tool credits to AMTrades.\n\nSwitch to NY 7h Candle for both.")
include_stub = ny_mode == "NY + 3h Overnight Stub"

// --- candle styling -----------------------------------------------------------
bull_colour    = input.color(color.white, "Bull", group = grp_styling, inline = "cols")
bear_colour    = input.color(color.black, "Bear", group = grp_styling, inline = "cols")
wick_colour    = input.color(color.gray,  "Wick", group = grp_styling, inline = "cols", tooltip = "The three candle colours.\n\n- Bull: body colour when the bucket\n  closed at or above its open.\n- Bear: body colour when it closed\n  below its open.\n- Wick: the high-to-low wick line, and\n  the outline around every body.\n\nThe outline is deliberately NOT the body\ncolour: a white bullish body would\ndisappear on a white chart, and a doji\nwould vanish entirely.")
wick_width     = input.int(1, "Wick Width", minval = 1, maxval = 4, group = grp_styling, inline = "look")
label_size_str = input.string("Small", "Label Size", options = ["Normal", "Small", "Tiny"], group = grp_styling, inline = "look", tooltip = "Wick Width: thickness of the vertical\nhigh-to-low wick line.\n\nLabel Size: size of the A / L / N letters\ndrawn above each candle.")

// --- layout -------------------------------------------------------------------
offset_bars  = input.int(10, "Offset From Last Bar", minval = 1, maxval = 200, group = grp_layout, inline = "offs", tooltip = "Bars of clear space between the last\nprice bar and the first drawn candle.")
// FIXED, not inputs. Both were inputs up to 2026-08-24 and these are the values they defaulted to,
// so a chart on the defaults is unchanged. A body of 2 keeps the wick on true centre (an even width
// has a real middle bar); a gap of 1 is the tightest strip that still separates the candles. The
// 500-bar clamp below still applies and still shrinks `step`, so a deep `Sessions back` cannot run
// the strip past Pine's future-drawing limit.
candle_width = 2
candle_gap   = 1

// --- session boundary lines ---------------------------------------------------
bnd_show      = input.bool(true, "Vert. Lines", group = grp_boundaries, inline = "bnd")
bnd_colour    = input.color(color.silver, "", group = grp_boundaries, inline = "bnd")
bnd_style_str = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = grp_boundaries, inline = "bnd")
bnd_width     = input.int(1, "Width", minval = 1, maxval = 4, group = grp_boundaries, inline = "bnd", tooltip = "Vertical lines on the real price bars\nmarking where each 7-hour bucket starts\nand ends.\n\nThe lines mark:\n- the daily open (A starts)\n- +7h (L starts)\n- +14h (N starts)\n- where N ends\n\nBy default N runs to the end of the day,\nand that instant is not drawn as its own\nline because the next day's A start\nalready marks it. On NY 7h Candle Data Composition =\nNY 7h Candle, N ends at +21h and that end\nIS drawn.\n\nThey cover exactly the buckets the strip\nis showing and no more, so raising\nSessions back extends them too.\n\nThe times come from the same daily-open\nmaths that decides which bucket a minute\nbelongs to, so a line can never disagree\nwith the candle it marks.\n\nDrawn on 1 hour charts and below only:\nabove that a boundary falls too far\ninside a single bar to mark anything\nuseful.\n\nOne colour for all of them, deliberately:\nthe A / L / N letters already carry which\nsession is which, and four colours across\nseveral days reads as clutter.\n\nDrawn faint, at a fixed 25 percent, so the\nboundaries sit behind the price action\nwhile the strip stays solid.")

// THERE IS NO OPACITY INPUT. Both were removed on 2026-08-24 and each element is fixed at what its
// input used to default to: candles fully solid, boundary lines faint. Pine's second colour argument
// is TRANSPARENCY, not opacity, so the two constants below are the INVERSE of the old input values
// (100 opacity became 0 transparency, 25 opacity became 75). Read them that way before changing one.
body_transparency = 0                             // candles are FIXED SOLID; the Opacity input was removed 2026-08-24 and this is its old default (100 opacity = 0 transparency)
final_wick_colour = color.new(wick_colour, body_transparency)

// Size-string mapper — concept from CODING_SKILLS/PINE/snippets/9-utils/size-from-string.md,
// trimmed to the three sizes this tool offers and written as a SINGLE-LINE ternary to match the
// form already used elsewhere in this file. The snippet's own multi-line layout does not compile:
// Pine reads a continuation line indented by a multiple of 4 spaces as a new statement.
// Anything unrecognised falls through to normal, so picker and test cannot disagree.
label_size = label_size_str == "Tiny" ? size.tiny : label_size_str == "Small" ? size.small : size.normal

// Style-string mapper — concept from CODING_SKILLS/PINE/snippets/9-utils/style-from-string.md,
// written as a SINGLE-LINE ternary for the same reason as the size mapper above: the snippet's
// own multi-line layout does not compile. Anything unrecognised falls through to dotted.
bnd_style        = bnd_style_str == "Solid" ? line.style_solid : bnd_style_str == "Dashed" ? line.style_dashed : line.style_dotted
final_bnd_colour = color.new(bnd_colour, 75)      // boundaries are FIXED FAINT; the Opacity input was removed 2026-08-24 and 75 transparency is its old default of 25 opacity

// --- bucket aggregation — 1-minute intrabars booked to daily-open-anchored 7h buckets ---
// Bucket rule (same as market_liquidity_levels' 7H Sessions Model): elapsed ms since the
// instrument's own daily open, integer-divided by 7 hours. 0 = A(sia), 1 = L(ondon), 2 = N(ew York).
// Index 3 (the 21:00-24:00 remainder) is FOLDED INTO INDEX 2 BY DEFAULT, so N runs to the end of
// the day. `NY 7h Candle Data Composition` = 'NY 7h Candle' makes it a gap instead: no candle drawn, no data
// accumulated. See the stub note in the header. There is never a fourth candle either way.
h7_ms       = 7 * 60 * 60 * 1000
MAX_BUCKETS = 12                                  // 9 drawable + headroom, so a partial day at the head of the store cannot starve Sessions back = 6

// Request 1-minute intrabars, except on charts already at or below 1 minute, where the chart's own
// timeframe is requested instead — on those charts each chart bar is already at (or finer than)
// 1-minute accuracy. request.security_lower_tf accepts a timeframe LOWER THAN OR EQUAL TO the
// chart's, so requesting `timeframe.period` on a 1m or seconds chart is valid and returns data.
// This ternary is what fixed the original crash: the old code asked for "1" unconditionally, which
// on a SECONDS chart is HIGHER than the chart and halts the script. `ignore_invalid_timeframe`
// is kept on all six calls as a backstop against ever reaching that state again — but note what
// it actually does if it fires: the reference says the call returns `na`, NOT an empty array, and
// an array.* call on an na array id is itself a runtime error. It is insurance, never a path the
// code is designed to run down.
ltf = timeframe.in_seconds() > 60 ? "1" : timeframe.period

ltf_time  = request.security_lower_tf(syminfo.tickerid, ltf, time,      ignore_invalid_timeframe = true)
ltf_dopen = request.security_lower_tf(syminfo.tickerid, ltf, time("D"), ignore_invalid_timeframe = true)   // nested request: each intrabar's OWN daily open
ltf_open  = request.security_lower_tf(syminfo.tickerid, ltf, open,      ignore_invalid_timeframe = true)
ltf_high  = request.security_lower_tf(syminfo.tickerid, ltf, high,      ignore_invalid_timeframe = true)
ltf_low   = request.security_lower_tf(syminfo.tickerid, ltf, low,       ignore_invalid_timeframe = true)
ltf_close = request.security_lower_tf(syminfo.tickerid, ltf, close,     ignore_invalid_timeframe = true)

n_ltf = math.min(math.min(math.min(array.size(ltf_time), array.size(ltf_dopen)), math.min(array.size(ltf_open), array.size(ltf_high))), math.min(array.size(ltf_low), array.size(ltf_close)))

// Parallel bucket store, oldest first. `key` is the bucket's own start time in ms
// (daily open + index * 7h) — unique, strictly increasing, and doubles as the
// today/not-today test, so no separate day field is needed.
var array<int>   b_key = array.new<int>()
var array<int>   b_idx = array.new<int>()   // 0 = A, 1 = L, 2 = N
var array<float> b_o   = array.new<float>()
var array<float> b_h   = array.new<float>()
var array<float> b_l   = array.new<float>()
var array<float> b_c   = array.new<float>()
var int last_day_open = na                  // daily open of the most recently seen intrabar = "today"

// The no-intrabar case has TWO distinct causes and they are NOT equivalent:
//   1. The chart is at or below 1 minute and the request came back empty anyway. The request IS
//      issued on these charts (at the chart's own timeframe) and normally succeeds — this is the
//      fallback for when it does not. The chart bar IS at least as fine as one minute, so building
//      the bucket from it is EXACT and nothing is lost.
//   2. The chart is above 1 minute and the array came back empty — the intrabar budget ran out
//      deep in history. Building a bucket from a multi-hour chart bar there would be a silent
//      accuracy loss, so the bucket is SKIPPED, matching "a bucket with no data is not drawn".
use_ltf   = n_ltf > 0
build_bar = not use_ltf and timeframe.in_seconds() <= 60      // case 1 only
n_src     = use_ltf ? n_ltf : 1

// Loop-invariant, so hoisted out of a body that runs once per 1-minute intrabar in the chart bar:
// up to 1,440 times on a Daily chart, ~10,080 on Weekly and ~44,640 on Monthly (1,440 is the DAILY
// figure, not the ceiling — `ltf` requests "1" on every chart above 1 minute). Pine counts
// request-family calls per script (40 max) and they must not depend on loop state — hoisting
// removes the question entirely.
bar_time  = time
bar_dopen = time("D")

if use_ltf or build_bar
    for i = 0 to n_src - 1
        // Seeded from the chart bar, then overwritten from the intrabar arrays. No array.get is
        // syntactically reachable unless `use_ltf` is true, so an empty array can never be read.
        int   src_t = bar_time
        int   src_d = bar_dopen
        float src_o = open
        float src_h = high
        float src_l = low
        float src_c = close
        if use_ltf
            src_t := array.get(ltf_time,  i)
            src_d := array.get(ltf_dopen, i)
            src_o := array.get(ltf_open,  i)
            src_h := array.get(ltf_high,  i)
            src_l := array.get(ltf_low,   i)
            src_c := array.get(ltf_close, i)
        if not na(src_t) and not na(src_d) and src_t >= src_d
            int since = src_t - src_d
            int bi    = int(since / h7_ms)
            // The 3h overnight stub. Index 3 is the last three hours of the day. By DEFAULT it is
            // booked into index 2, the SAME bucket as N, so those minutes extend the existing N
            // candle rather than creating a fourth one; on 'NY 7h Candle' it is a gap instead,
            // never drawn and never accumulated. The key is derived from the effective index,
            // which is what makes it the same bucket: N stays keyed at daily open + 14h and runs
            // on to the end of the day.
            int bi_eff = include_stub and bi == 3 ? 2 : bi
            // `last_day_open` is set for EVERY in-day intrabar, including index 3, so "today" is
            // known through the 21:00-24:00 slot whether that slot is drawn or discarded.
            last_day_open := src_d
            if bi_eff <= 2
                int key = src_d + bi_eff * h7_ms
                int sz  = array.size(b_key)
                if sz == 0 or key != array.get(b_key, sz - 1)
                    array.push(b_key, key)
                    array.push(b_idx, bi_eff)
                    array.push(b_o,   src_o)      // open = first intrabar's open in the bucket
                    array.push(b_h,   src_h)
                    array.push(b_l,   src_l)
                    array.push(b_c,   src_c)
                    if array.size(b_key) > MAX_BUCKETS
                        array.shift(b_key)
                        array.shift(b_idx)
                        array.shift(b_o)
                        array.shift(b_h)
                        array.shift(b_l)
                        array.shift(b_c)
                else
                    array.set(b_h, sz - 1, math.max(array.get(b_h, sz - 1), src_h))   // running extremes
                    array.set(b_l, sz - 1, math.min(array.get(b_l, sz - 1), src_l))
                    array.set(b_c, sz - 1, src_c)                                     // close = last intrabar's close

// --- draw — last bar only, delete-then-redraw ---------------------------------
var array<box>   d_body = array.new<box>()
var array<line>  d_wick = array.new<line>()
var array<label> d_lbl  = array.new<label>()
var array<line>  d_bnd  = array.new<line>()   // boundary lines: own store, own lifecycle

if barstate.islast
    // Delete the objects THEN clear the refs — clearing alone orphans them on the chart.
    if array.size(d_body) > 0
        for i = 0 to array.size(d_body) - 1
            box.delete(array.get(d_body, i))
        array.clear(d_body)
    if array.size(d_wick) > 0
        for i = 0 to array.size(d_wick) - 1
            line.delete(array.get(d_wick, i))
        array.clear(d_wick)
    if array.size(d_lbl) > 0
        for i = 0 to array.size(d_lbl) - 1
            label.delete(array.get(d_lbl, i))
        array.clear(d_lbl)
    if array.size(d_bnd) > 0
        for i = 0 to array.size(d_bnd) - 1
            line.delete(array.get(d_bnd, i))
        array.clear(d_bnd)

    int n = array.size(b_key)
    if n > 0 and not na(last_day_open)
        // First stored bucket belonging to today. Keys are chronological, so everything from
        // here to the end is today's (1, 2 or 3 candles depending on the time of day); a bucket
        // with no data yet was never pushed and so is never drawn.
        int first_today = n
        for i = 0 to n - 1
            if array.get(b_key, i) >= last_day_open
                first_today := i
                break

        int start = math.max(0, first_today - sessions_back)
        int count = n - start
        if count > 0
            // Boundary lines, drawn from the DRAWN BUCKET SET itself — indices `start` to
            // `n - 1`, exactly the buckets on the strip. Raising Sessions back extends the
            // lines with the candles; nothing else decides how far they reach, so the two can
            // never cover different spans. Each drawn bucket contributes its START (its own
            // key). Its END (key + 7h) is contributed only where the next drawn bucket does
            // not begin there: between A and L, and L and N, the end IS the next start and one
            // line serves both. After N it depends on NY 7h Candle Data Composition: on the DEFAULT, N's end is
            // not drawn at all, for the reason set out below; on 'NY 7h Candle' the 21:00-24:00
            // gap intervenes and N's end IS a boundary in its own right. Worst case is
            // NOT the tidy contiguous one: a bucket
            // skipped for want of data breaks contiguity and then contributes an end of its own,
            // so today's 3 contiguous buckets give 3 starts + 1 end and the 6 prior ones can each
            // be isolated, giving 6 starts + 6 ends. 16 boundary lines, + 9 wicks = 25.
            // Gated to 1h and below: above that a boundary sits too far inside a single bar to
            // mark anything useful, so the line would assert a precision the chart cannot show.
            if bnd_show and timeframe.in_seconds() <= 3600
                for i = start to n - 1
                    int b_start = array.get(b_key, i)
                    int b_end   = b_start + h7_ms
                    // N's END IS NOT DRAWN WHEN THE STUB IS INCLUDED, which is the DEFAULT. The
                    // reason is worth keeping.
                    // There, N runs to the END OF THE DAY, not to a fixed +10h: a daily open is not
                    // always 24h after the previous one (a DST change makes the day 23h or 25h, and
                    // a weekend or holiday makes the gap far longer). Computing the end as +10h
                    // would put the line an hour inside the next day's A after a spring-forward, or
                    // an hour before the candle actually stopped after a fall-back, which is the
                    // one thing these lines exist not to do. The instant N ends IS the next daily
                    // open, and that is already drawn as the next bucket's own start, so the line
                    // is not computed at all: it is inherited. For the newest N there is no next
                    // bucket yet, and its end is in the future, which the reached test below
                    // refuses anyway.
                    bool is_ny  = array.get(b_idx, i) == 2
                    bool no_end = include_stub and is_ny
                    bool end_is_next_start = i < n - 1 and array.get(b_key, i + 1) == b_end
                    for pass = 0 to 1
                        int bnd_t = pass == 0 ? b_start : b_end
                        bool wanted = pass == 0 or (not end_is_next_start and not no_end)
                        // REACHED, and not merely inside the forming bar. Both halves of the min
                        // are load-bearing. `time` (the bar's OPEN) holds a reached boundary back
                        // by up to a whole bar. `time_close` alone is the forming bar's PROJECTED
                        // close, so it would draw a boundary up to a bar EARLY, asserting a session
                        // change that has not happened, which is worse than a missing one.
                        // `timenow` alone is real wall-clock, so on a closed market it sits far
                        // past the last bar and authorises lines out in empty space. The min is
                        // right in every case: on history it collapses to `time_close`, on the live
                        // bar to `timenow`.
                        if wanted and bnd_t <= math.min(time_close, timenow)
                            // y arguments are placeholders that `extend.both` overrides, but they
                            // must still be two DIFFERENT values: on a flat bar (high == low, e.g.
                            // the first tick of a new realtime bar) coincident endpoints leave
                            // `extend` no direction to extend along. Nothing here touches the time
                            // axis.
                            array.push(d_bnd, line.new(bnd_t, close, bnd_t, close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = final_bnd_colour, style = bnd_style, width = bnd_width))

            // Label padding is derived from the DRAWN set's own price range so the letters clear
            // the wick tips at any instrument scale without an input. `start` to `n - 1` is
            // exactly the drawn set (count == n - start) and every one of them is now drawn —
            // the 500-bar limit shrinks the spacing rather than dropping candles.
            float cluster_hi = na
            float cluster_lo = na
            for i = start to n - 1
                cluster_hi := na(cluster_hi) ? array.get(b_h, i) : math.max(cluster_hi, array.get(b_h, i))
                cluster_lo := na(cluster_lo) ? array.get(b_l, i) : math.min(cluster_lo, array.get(b_l, i))
            float pad = (cluster_hi - cluster_lo) * 0.06
            if pad <= 0
                pad := syminfo.mintick * 10

            int base = bar_index + offset_bars
            // Pine cannot draw more than 500 bars into the future. The LAYOUT is clamped to that,
            // never the candle set: the spacing shrinks until the whole strip fits, so every
            // candle is kept. Dropping instead would drop the NEWEST candles — the loop ascends —
            // including today's live bucket, the most useful one on the strip.
            int room = 500 - offset_bars - candle_width          // bars available for the leftmost-to-rightmost span
            int step = candle_width + candle_gap
            if count > 1
                step := math.max(1, math.min(step, int(room / (count - 1))))

            for i = 0 to count - 1
                int idx   = start + i               // oldest drawn candle leftmost, newest rightmost
                int left  = base + i * step
                int right = left + candle_width
                // TRUE PRICES, always. Every candle sits where its own high and low actually
                // were, so a session extreme reads straight across to the price action.
                float b_open  = array.get(b_o, idx)
                float b_high  = array.get(b_h, idx)
                float b_low   = array.get(b_l, idx)
                float b_close = array.get(b_c, idx)
                color body_colour = color.new(b_close >= b_open ? bull_colour : bear_colour, body_transparency)
                int   mid         = left + int(candle_width / 2)
                string letter     = array.get(b_idx, idx) == 0 ? "A" : array.get(b_idx, idx) == 1 ? "L" : "N"
                array.push(d_wick, line.new(mid, b_low, mid, b_high, color = final_wick_colour, width = wick_width))
                // The outline takes the WICK colour, never the fill: a white bull body on a white
                // chart would otherwise vanish entirely. It also keeps a doji (open == close)
                // visible, which is what a fill-matched border used to do.
                array.push(d_body, box.new(left, math.max(b_open, b_close), right, math.min(b_open, b_close), border_color = final_wick_colour, bgcolor = body_colour))
                // chart.fg_color tracks the user's light/dark theme, so the letters stay legible
                // on either without adding a colour input for them. style_none draws no bubble at
                // all, so no `color` argument is passed — it would be inert.
                array.push(d_lbl, label.new(mid, b_high + pad, letter, style = label.style_none, textcolor = chart.fg_color, size = label_size, text_font_family = font.family_monospace))
````
