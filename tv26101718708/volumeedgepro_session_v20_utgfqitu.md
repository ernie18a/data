# VolumeEdgePro Session v2.0

- url: https://www.tradingview.com/script/UTgFqITU-VolumeEdgePro-Session-v2-0/
- type: indicator
- pine_id: PUB;ee9783bc2941445395dacefee96832bd
- version: 6.0

## Description

[b]VolumeEdgePro Session — Fixed Range Volume Profile + Edge Exhaustion Detection[/b]

VolumeEdgePro Session builds a fresh Fixed Range Volume Profile for every session you choose (Daily, Weekly, Monthly, Quarterly, Half-Year, or Yearly) and watches the profile's own boundaries for exhaustion — a wick that rejects the edge of the session's traded range while volume thins out right at that edge. That combination is the core signal this tool is built around: EDGE EXH (Edge Exhaustion).

After many months of testing, forward testing, and tweaking, I'm releasing this as the final version — v2.0 — that any user can truly have confidence using.

[b]Why I built this[/b]

Most Fixed Range Volume Profile tools available are static drawing tools — you draw a profile over a range yourself, it doesn't rebuild automatically at session boundaries, and it has no way to detect or alert on anything happening at its own edges. You get the profile and nothing else; reading exhaustion, confirmation, or timing out of it is entirely manual, bar by bar, chart by chart. I wanted a profile that resets itself at every session boundary automatically, flags the moment price exhausts against its own edge, and tells me when that happens instead of me having to keep watching for it — [b]so I built this from the ground up, rather than modifying or reskinning an existing script.[/b]

If you read volume before you read price, this is one of the better tools you can put on a chart. Most indicators tell you where price has been. This one tells you where price ran out of participants to keep going — the empty bins at a profile boundary are the direct evidence that the move lacks the volume to continue, not a lagging guess built from price alone.

[b]The best part: reading where the market tends to go next[/b]

An empty-bin exhaustion at a profile boundary isn't just a rejection — it's a readable signal about direction. When price pushes to the edge of the session's range and volume dries up right at that edge, it tells you the move ran out of participants before it ran out of room, which is the setup that tends to precede a reversal back into the value area. When volume stays present all the way to the edge instead, that absence of exhaustion tells you the opposite — the move still has participation behind it and continuation is more likely than rejection. That's what sets this apart from a plain price-action read: you're not guessing which way a touch resolves, you're reading the volume evidence that usually decides it.

[b]Core features[/b]

[list]
[*]Session-anchored Fixed Range Volume Profile, rebuilt fresh at every session boundary rather than sliding forward bar by bar
[*]EDGE EXH detection — rejection wick at a profile boundary + a minimum run of empty volume bins at that edge
[*]Signals are never hidden, only color-coded — a touch that doesn't clear your empty-bin, session-maturity, or confluence threshold still draws a gray, paused label instead of vanishing, so you see every touch and why it was or wasn't treated as valid
[*]Optional MA Cross and PC Cross confirmation layers on top of the base EDGE EXH signal
[*]On-chart dashboard showing live watch states, session info, and PC (previous session close) position
[*]Discord and Telegram alert support, including Telegram topic routing
[*]Custom time-of-day and day-of-week alert filtering
[/list]
[b]Volume trading vs. price trading[/b]

Price trading reads candles, trendlines, and price-based indicators (moving averages, RSI, Fibonacci levels) — all of it derived from where price has already traded, with volume as an afterthought at best. Two charts can show an identical price pattern and mean completely different things, because price alone can't tell you whether that pattern was built on heavy participation or almost none.

Volume trading reads where the trading actually happened, not just where the last price printed. A Volume Profile shows you the full distribution of traded volume across price, bar by bar — the high-volume nodes where the market agreed on value, and the low-volume nodes where price moved through with little resistance. A price chart alone can't show you either of those.

The practical difference: a price-only trader sees price reject a level and has to guess whether that rejection means something. A volume trader sees the same rejection happen at a profile boundary with empty bins behind it and knows the move already lacks the volume to extend — the rejection isn't a guess, it's a measurable shortage of participation. That's the edge this tool is built to surface directly on your chart, rather than leaving you to infer it from price shape alone.

[b]Settings[/b]

Session Mode (Auto or manual: Daily/Weekly/Monthly/Quarterly/Half-Year/Yearly), Min Empty Bins (high/low side), Boundary Scan Window, MA Cross and PC Cross confirmation toggles, dashboard display options, and Discord/Telegram alert routing with per-day/time filtering.

[b][b]A note on volume data[/b][/b]

The volume this script reads comes from TradingView's own data feed for whatever symbol you have charted — not from this script itself. For exchange-traded instruments (crypto, stocks, futures), that's real traded volume from that exchange. For forex and most CFD symbols, there's no single central exchange, so what's shown is tick volume — a count of price-change events, used as a proxy for actual volume — sourced from whichever broker/data provider is feeding that symbol on TradingView. It's not literal executed volume in that case, but it's the best proxy available for an OTC market, and it's the same convention every other volume-based tool on TradingView relies on for forex. Worth keeping in mind when comparing signal strength across symbols from different asset classes.

[i]This script is for informational and educational purposes only. It does not constitute financial advice. Past performance of any signal or strategy does not guarantee future results. Always do your own research and manage your own risk.[/i]

[i]Developed with the assistance of Claude, Anthropic's AI assistant. Claude and Anthropic are trademarks of Anthropic PBC.[/i]

## Source Code

````pine
//@version=6
const string SCRIPT_VERSION = "v2.07"
const string SCRIPT_NAME    = "VolumeEdgePro Session " + SCRIPT_VERSION

// ================================================================
//  VolumeEdgePro Session (Pine Port) v1.0
//  ================================================================
//  v2.07: added the D1 Direction Dashboard panel, ported verbatim from VolumeEdgeProFlow for
//  parity. v1.0 of this port left the panel out, reasoning it was VEP-only and unrelated to
//  VEPS's session-anchored design - but the underlying D1 bias data (d1_poc/d1_vah/d1_val/
//  d1_adx, PEP, flip tracking) was never actually removed; it's been computed and feeding
//  pepStr/the alert payload's d1Ctx/flipCtx the whole time. Only the on-chart table was
//  missing. Added back since D1 bias is a standing part of the overall VEP strategy (a
//  higher-timeframe filter above whichever profile logic runs underneath), not something
//  specific to the rolling-profile design.
//  v2.06 fix: v2.04/v2.05's caching approach was itself flawed, confirmed via an identical bug
//  report on the sibling VolumeEdgeProFlow script ("seems not fixed for flow") that uses the
//  same pattern. The whole EDGE EXH label loop runs inside `if barstate.islast`, which only
//  executes ONCE per full calculation pass, not once per historical bar as the script walks
//  through history. On a fresh load/reload, every pre-existing historical bar's "first cache
//  encounter" happens in that SAME single pass, using TODAY's live gate/cooldown/dead-time
//  state and TODAY's fuller bin counts for all of them at once - the exact bug v2.04/v2.05
//  were trying to fix, just hidden behind map.contains()/map.put() instead of removed. No
//  caching needed at all: sigOk is now computed per touch bar via genuine continuous per-bar
//  series offsets (gateOpen[b], onCooldown[b], the new inDeadTimeAt(b)) - valid because those
//  series are computed unconditionally on every bar, not just inside this block. binOk is
//  recomputed per touch bar from calcProfile(): for the still-open session (pNum==0), whose
//  near edge keeps sliding forward every bar, as calcProfile(s, b); for already-closed
//  sessions (pNum>=1), whose boundaries are fixed absolute bar indices, by reusing the
//  already-correct tVols from the outer calcProfile(s, e) call directly, since those profiles
//  never drift in the first place.
//  v2.05 fix: same retroactive-flip bug as v2.04, one layer deeper. v2.04 froze the empty-bin
//  verdict but deliberately left sigOk (gate/cooldown/dead-time) live, on the reasoning that
//  it describes whether a signal is tradeable NOW rather than whether it was valid when it
//  fired. Confirmed wrong from the user's own two screenshots of the same chart, taken
//  minutes apart: Signal Cooldown went from CLEAR to active (0b/66.8p left) between them,
//  and every EDGE EXH label on screen - including ones from already-closed historical
//  profiles, not the live session - flipped from colored to gray at once. Root cause: sigOk
//  is recomputed every redraw from gateOpen/onCooldown/inDeadTime(), all of which reflect the
//  CURRENT bar's live state, and that one result gets applied uniformly to every bar b in the
//  label loop regardless of which profile or session it belongs to. A touch from three
//  sessions ago has no business changing color because cooldown is active on THIS bar.
//  Fixed the same way as v2.04: sigOk is now frozen in sigOkCache the first time each bar is
//  evaluated (the pass where it was the newest/live bar, so the cached value is genuinely
//  that bar's own point-in-time gate/cooldown/dead-time state) and reused on every later
//  redraw. Color now depends only on two frozen, point-in-time facts - did it meet the empty
//  bin requirement, and was a signal actually tradeable at that moment - never on anything
//  happening on the chart right now.
//  v2.04 fix: EDGE EXH chart labels on the still-open current session could retroactively
//  flip from colored to gray "not enough empty bins" hours after firing - confirmed from a
//  live chart (EURUSD) showing valid touches turn gray as the session filled in. Root cause:
//  the label-redraw loop reruns every bar close and recomputes each touch's bin count
//  against the session's CURRENT (now fuller) profile, not the profile as it stood at the
//  time of that touch. Fixed by freezing each touch's empty-bin verdict in a map the first
//  time it's evaluated (naturally, the bar where it was the newest bar) and reusing that
//  frozen verdict on every later redraw - sellBinOkCache/buyBinOkCache, keyed by bar index.
//  v2.02 fix: Tier 3 (PC Cross Alert) was re-firing the SAME signal every bar once price
//  was already past PC - confirmed from a live USDJPY alert log (identical SELL signal
//  repeating every 30 min, entry/buffer drifting only because ATR kept moving). Root cause:
//  once a watch fires and clears, the backward scan immediately re-finds the SAME old
//  signal bar (it's evaluated against the current live profile, which keeps matching) and
//  re-arms off it, so it fires again next bar, and the next, indefinitely. Fixed by
//  tracking the last signal bar that armed a watch per direction (pdcLastArmedBarBuy/Sell)
//  and refusing to re-arm off that same bar again - mirrors the cBot's own existing fix for
//  this exact failure mode (_pcLastArmedSignalTimeBuy/Sell). A genuinely new signal bar
//  still arms normally.
//  v2.01: Tier 2 (MA Cross Alert) now reports Entry/SL/TP/Empty Bins, same as Tier 3 -
//  previously it sent only a bare confirmation line while Tier 1 and Tier 3 both carried
//  structural SL/TP. Forward confirm: Entry = confirm bar's close, SL = the signal bar's
//  own structural extreme (now frozen at arm time in maWatchStructuralSl/maWatchEmptyBins,
//  mirroring Tier 3's pdcWatchStructuralSl/pdcWatchEmptyBins), TP = SL distance x Risk:Reward
//  Ratio. Backward confirm: Entry/SL/TP computed directly off the signal bar, no freeze
//  needed since it fires same-bar. Both reuse "PC Alert SL Buffer (x ATR)" for the SL
//  buffer - no new parameter added, same shared-buffer convention Tier 1 already uses.
//  Built from vep.pine (VOLUME EDGE [PRO UI] v2.3) as the starting point, per direct
//  instruction after two earlier from-scratch attempts at this port produced a broken,
//  undifferentiated profile visualization. vep.pine's own proven profile engine (calcProfile,
//  the proportional-width box-drawing technique, countEmptyBins), Discord alert JSON format,
//  cooldown, dead-time filter, MA Cross plotting, and PC Cross Alert watch/arm/expire state
//  machine are all kept intact and unmodified except where noted below - this is a
//  modification of proven, working code, not a rewrite.
//
//  What changed from vep.pine, and why:
//  - SESSION-ANCHORED, not rolling: the "AUTO-LOOKBACK" section (a fixed, hardcoded-per-
//    timeframe bar count that slides forward every bar) is replaced with hard session resets
//    - Daily/Weekly/Monthly, auto-detected from the chart's own timeframe (H1-and-below ->
//    Daily, strictly between H1 and D1 -> Weekly, D1-and-above -> Monthly) or manually
//    overridden via the new Session Mode input. The variable name effectiveLookback is kept
//    (now computed as barsSinceReset + 1) specifically so every existing downstream consumer
//    - calcProfile() calls, the PC line, the dashboard's LOOKBACK row - keeps working
//    unchanged; only what feeds into it changed.
//  - EDGE EXH ONLY: VA TRAP, POC, and REJECTION signal detection, their inputs, and their
//    trigger conditions are removed, matching VEPS's actual feature set (VEP has all four
//    signal types; VEPS never did).
//  - Cross-profile confluence removed along with numProfiles: it compared POCs across N
//    fixed-bar rolling segments, a concept that doesn't map cleanly onto variable-length
//    sessions. The Signal Gate now runs on the Volatility Filter alone. Worth building a
//    real cross-session version later if wanted - not attempted here rather than guessing at
//    an untested replacement.
//  - D1 Direction Dashboard PANEL removed (not part of VEPS) - but its underlying data
//    (d1_biasStr, d1_poc, etc.) is deliberately KEPT, since PEP genuinely depends on it and
//    VEPS's own C# dashboard has its own PEP row.
//  - PDC generalized to PC: UpdatePDC's read is now session-matched (Daily/Weekly/Monthly)
//    instead of always Daily. Internal identifiers (pdcValue, pdcColor, etc.) are
//    deliberately kept unchanged - only displayed labels changed from PDC to PC - same
//    precedent the cAlgo VSPC port set generalizing VPDC's own PDC.
//  - Three-tier alert design: Tier 1 is the general EDGE EXH alert, immediate, now EDGE-EXH-
//    only and explicitly tagged "TIER 1" in its title. Tier 2 (MA Cross) is genuinely NEW -
//    vep.pine's own MA Cross was purely visual (plot lines + cross markers), no alert
//    attached at all - built here mirroring the exact same watch/arm/expire pattern Tier 3
//    already proves works. Tier 3 is vep.pine's own PDC Cross Alert, unmodified in mechanism,
//    generalized to PC and tagged "TIER 3". All three route through TradingView's own single
//    "Any alert() function call" condition to one Discord webhook, per the confirmed design -
//    tier tags in the message text are what distinguish them in that one channel, not
//    separate webhook routing (Pine can't pick a destination webhook at runtime anyway).
//  - Google Sheets logging: never existed in vep.pine to begin with (Pine has no arbitrary
//    network access outside the alert/webhook system) - nothing to remove here.
//
//  v1.0 was confirmed compiling and showing a real, differentiated profile (bull/bear/
//  exhaustion structure, not a solid block) on a live XAUUSD chart - the profile engine
//  ported from vep.pine works correctly once session-anchored.
//
//  v1.1: two fixes from that same test.
//  - Compiler warning fixed: getRecentMaCrossDir() (Tier 2's backward-check helper) was
//    being called conditionally, inside an if-block that only runs when EDGE EXH fires.
//    Pine's own compiler flags this for functions containing historical [] lookups - called
//    conditionally, their internal bookkeeping isn't guaranteed consistent bar to bar. Now
//    called unconditionally every bar into backDirEveryBar, read conditionally instead.
//  - Number of Sessions restored: v1.0 dropped vep.pine's own Number of Profiles entirely
//    when confluence was simplified away, leaving no way to show more than the live session.
//  Number of Sessions (default 1) brings this back, generalized to real session boundaries
//  instead of fixed-bar segments - sessionStartBars now tracks each session's actual start
//  as it happens, and getSessionOffsets(pNum) resolves session pNum (0 = live, 1 = previous
//  completed session, 2 = the one before that, ...) into calcProfile's own offset arguments,
//  falling back to "not valid yet" if the chart's history doesn't go back that far. This is
//  a genuinely different mechanism from vep.pine's own numProfiles (which compared POCs
//  across N fixed-bar rolling segments) - the confluence GATE itself is still not rebuilt,
//  only the ability to see multiple sessions' profiles is restored.
//
//  v1.2: fixed a real runtime error confirmed on a live CADJPY chart after running for some
//  time - "requested historical offset (117) is beyond the historical buffer's limit (116)"
//  at calcProfile(). Pine auto-sizes this buffer by analyzing the script's [] lookback usage
//  on the chart's first 244 bars; an early, shorter session under-provisioned the buffer,
//  and a later, longer session (most likely one spanning a weekend gap) then exceeded it.
//  Fixed two ways together: max_bars_back=2000 added to the indicator() declaration
//  (sizes the buffer explicitly rather than relying on Pine's own auto-detection), and a new
//  Max Session Length (bars) safety cap applied to both the live session (effectiveLookback)
//  and every historical session (getSessionOffsets) - caps how far any single session's
//  profile calc reaches even if that session genuinely ran longer, protecting against both
//  this error and excessive loop time on an anomalously long session.
//
//  v1.3: Number of Sessions capped at 5 (was 20) and Max Session Length capped at 400 (was
//  2000) on direct request - both for chart readability at higher session counts, and so
//  their product (5 × 400 = 2000) exactly matches max_bars_back above. This makes the
//  worst-case buffer reach a genuine mathematical guarantee rather than the prior "unlikely
//  in practice" hand-wave, which undersold how far the old 20 × 2000 combination could
//  actually have exceeded it.
//
//  v1.4: fixed box-width scaling using the wrong reference for historical sessions -
//  calcWidth used the global effectiveLookback (which only ever represents the LIVE
//  session's own length) to scale every session's boxes, including historical ones
//  (pNum >= 1) whose actual length could differ. Now uses each session's own real span
//  (s - e + 1) instead. Only affects Number of Sessions > 1 - the live session's own boxes
//  were already correct, since effectiveLookback and its own span were identical.
// ================================================================
//
//  v1.5: fixed a real bug found on direct request - pdcValue (the PC line/value) was still
//  hardcoded to request.security(..., "D", ...) (Daily) despite this file's own v1.0 header
//  claiming PC had already been generalized to the session-matched value. The header
//  described the intended change; the actual code was never updated to match it. Now three
//  fixed calls (Daily/Weekly/Monthly), picked by effectiveSessionMode, matching the C# side's
//  own GetSessionTimeFrame() pattern. Also added the MA WATCH (T2) dashboard row, porting the
//  C# side's own v1.14 addition - PC WATCH (T3) already existed here (vep.pine's own proven
//  PDC watch mechanism), but MA WATCH (T2) did not. One disclosed trade-off: MA WATCH shows
//  the previous bar's state, not this bar's freshest update, since Tier 2's own section runs
//  after the dashboard renders in this script's top-to-bottom order - moving Tier 2 earlier
//  would also require moving Tier 1's trig_EdgeExh_Buy/Sell (which Tier 2's arming depends
//  on), a much larger restructure of proven detection logic than this lag justifies. Checked
//  the C# side's other recent changes (v1.15 parameter ordering, v1.16 tier-tagged titles,
//  v1.17 watch-tracking independent of alerts) against this file - all three were already
//  satisfied by this script's existing structure, nothing to port. v1.18 (duplicate alert on
//  cAlgo reload) has no Pine equivalent - confirmed directly from TradingView's own docs that
//  alert() only ever fires on the realtime bar, never during historical reprocessing, so this
//  class of bug is structurally impossible here.
// ================================================================
//
//  v1.6: PC line moved inside the per-session drawing loop, on direct request - it was
//  being drawn once, globally, always for the LIVE session's own PC (pdcValue), regardless
//  of how many historical sessions Number of Sessions was also showing. Every session now
//  gets its own PC line/label, computed from the bar right before that session's own start
//  (close[s+1]) - by definition, the immediately preceding session's own close - so no
//  extra request.security call was needed. pdcValue itself is untouched, since the PC Cross
//  Alert watch and the dashboard's own PC row are specifically about the live session's
//  reference level, not historical ones.
// ================================================================
//
//  v1.7: on direct request, ports three of the cTrader VEPS indicator's own maturity
//  additions (v1.19/v1.21/v1.22) into this Pine port:
//    + "| Session Profile" appended to every Tier 1/2/3 alert title, matching the cTrader
//      side's own v1.22 tag (this port is the session-anchored engine, as distinct from
//      vep.pine's rolling/fixed-bar one, which would get "| Fixed Bar Profile" instead).
//    + Alert Time/Day Filter (new group: per-day start/end hour, optional local-time
//      conversion via Time Zone Offset, optional per-day Alert[Day] toggles) now gates all
//      three tiers' alert() calls, matching cTrader v1.19. Built on Pine's own hour()/
//      dayofweek() timezone-string argument rather than a manual UTC offset calculation.
//    + Reverse-signal invalidation, matching cTrader v1.21 - a fresh EDGE EXH in the
//      opposite direction now silently cancels the other side's still-pending Tier 2/3
//      watch, decoupled from Enable Discord Alerts so a contradicted watch stops counting
//      down regardless of whether alerts happen to be on.
//  Two cTrader-side additions deliberately NOT ported, no natural Pine equivalent:
//    - Session Reset Hour (UTC/Local): this port's session boundaries already come from
//      TradingView's own time("D")/time("W")/time("M") (the chart's exchange/session
//      calendar), not a manual hour-offset calculation the way the cAlgo side computes
//      GetSessionKey. Building a true configurable reset-hour into Pine would mean
//      replacing that boundary mechanism entirely - a much larger, riskier rework of the
//      session-anchoring engine (which took several real bug-fix rounds to get right; see
//      this file's own v1.0-v1.6 history above) than this update's scope justifies without
//      being asked for specifically.
//    - Telegram Bot Token/Channel ID/Topic ID: Pine's alert() sends one JSON payload to
//      whichever single webhook URL is configured in TradingView's own Create Alert dialog
//      at alert-creation time - the script has no direct outbound API access to pick a
//      destination (Discord vs Telegram) or make its own HTTP call the way the cTrader
//      cBots/indicator do. See v1.8 directly below - this was resolved without a relay,
//      once confirmed that TradingView's webhook can point straight at Telegram's own API.
// ================================================================
//
//  v1.23: added Half-Year (6-month) as a third manual-only Session Mode tier alongside
//  Quarterly and Yearly, on direct request - same pattern as v1.22: a new
//  ta.change(time("6M")) anchor for isNewSession, a new pcHalfYear via request.security for
//  pdcValue, and the dropdown option added. Auto still never selects it (unchanged reasoning
//  from v1.12/v1.22 - the cTrader source has no Half-Year bucket to infer towards).
//
//  v1.22: real bug fix, found on direct request about W1 charts only getting ~4 bars per
//  Monthly session. Quarterly and Yearly were already valid Session Mode selections and
//  isNewSession already anchored them correctly (ta.change(time("3M"))/time("12M")) - but
//  pdcValue (the PC line and above/below read) never got the matching cases and silently
//  fell back to pcMonthly's close for both. Added pcQuarterly/pcYearly via request.security
//  and wired them into pdcValue's ternary chain. Auto itself still only ever picks
//  Daily/Weekly/Monthly (unchanged, see v1.12 below) - Quarterly/Yearly remain manual-only
//  selections, now correct ones. Pick "Quarterly" directly on a W1 chart for a 3-month
//  window (~13 weekly bars) instead of Monthly's ~4.
//
//  v1.21: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.23 (Telegram Topic ID added, mapping to Telegram's own
//  message_thread_id field, so an alert can land in one specific topic thread of a supergroup
//  rather than always the General topic). This port's own telegramTopicId input and
//  buildAlertJson()'s topicFrag handling already do exactly this, ported in this port's own
//  v1.8 when Telegram support was first added - left blank, behaves exactly as before.
//  (cTrader changelog v1.22 - appending "| Session Profile" to every Discord title - is
//  skipped per the task's own instruction as cosmetic-only; also already present here anyway,
//  ported in this port's own v1.7.)
// ================================================================
//
//  v1.20: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.21 (a fresh EDGE EXH in the opposite direction now cancels
//  the other side's still-pending Tier 2/Tier 3 watch, since the two directions were
//  previously fully independent slots). This port's own Reverse-signal invalidation block
//  (TIER 1 - BARE EDGE EXH section above) already does exactly this - on a confirmed bar
//  with a fresh trig_EdgeExh_Buy/Sell, it cancels maWatchActive/pdcWatchActive if either is
//  armed in the opposite direction - ported in this port's own v1.7, decoupled from
//  enableAlerts the same way the C# side's fix is.
// ================================================================
//
//  v1.19: SKIPPED - cTrader changelog v1.20 (a local-time alternative to the UTC-based Session
//  Reset Hour, since a fixed UTC hour crosses midnight confusingly at non-UTC-friendly
//  offsets) has no equivalent to port, for the same reason already given in this port's own
//  v1.7 entry above: this port's session boundaries come from TradingView's own native
//  time("D")/time("W")/time("M") calls (the chart's own exchange/session calendar), not a
//  manual Session Reset Hour input at all - there is no SessionResetHourUtc/
//  SessionResetHourLocal equivalent in this script to add a local-time toggle to. Building a
//  genuine configurable reset-hour into Pine would mean replacing the session-anchoring
//  mechanism itself, the same much larger, riskier rework already declined in v1.7 for the
//  same underlying reason - still out of scope here without being asked to rebuild that
//  mechanism specifically.
// ================================================================
//
//  v1.18: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.19 (Custom Time Filter + per-day Alert[Day] toggles gating
//  only whether a confirmed signal's alert actually sends, independent of the existing
//  session/EDGE EXH detection itself). This port's own Alert Time/Day Filter group (per-day
//  Start/End Hour inputs, Use Local Time for Filters + Time Zone Offset, Enable Day Filter +
//  per-day Alert[Day] toggles, isAlertTimeAllowed()) already has this exact mechanism, ported
//  in this port's own v1.7, gating all three tiers' alert() calls the same way - detection
//  and the dashboard stay fully visible outside the window, only the notification itself is
//  suppressed, matching the C# side's own design.
// ================================================================
//
//  v1.17: confirmed N/A, no code change - checked against the cTrader Session indicator's own
//  changelog v1.18 (a real duplicate-alert bug, confirmed live on USDJPY: cAlgo reprocesses
//  recent history on load/reload, calling the alert-monitoring function once per historical
//  bar in that catch-up, not just once for the live bar, so an already-alerted signal could
//  fire again on reload before a new _startupBarIndex guard was added). This class of bug is
//  structurally impossible in Pine, already confirmed and documented in this port's own v1.5
//  entry above: TradingView's own docs confirm alert() only ever fires on the realtime bar,
//  never during historical reprocessing/backfill, so there is no "catch-up reprocessing calls
//  the alert path again" scenario for Pine to guard against in the first place.
// ================================================================
//
//  v1.16: mostly confirmed-matching, one real addition made. Checked against the cTrader
//  Session indicator's own changelog v1.17 (PC WATCH (T3)/MA WATCH (T2) track and arm
//  regardless of EnableAlerts, decoupled from whether an alert actually sends). This port's
//  own watch-arming logic (PC CROSS ALERT - TIER 3 WATCH STATE MACHINE and MA CROSS ALERT -
//  TIER 2 WATCH STATE MACHINE sections above) was already built this way from the start -
//  arming only ever checks inDeadTime()/trig_EdgeExh_*/enableMaCrossAlert (the tier's own
//  toggle, not the overall enableAlerts switch), with enableAlerts checked only at the actual
//  alert() send inside each branch - so there was nothing to decouple there.
//  What was missing: the C# side's own v1.17 dashboard tweak, appending " (Active)"/
//  " (Not Active)" to an armed watch row (omitted for "None") so the dashboard tells you
//  whether a confirmation would actually notify you externally right now, or just update the
//  row silently. Added that here too, to both PC WATCH (T3) and MA WATCH (T2) rows, reflecting
//  the live enableAlerts input exactly as the C# side does.
// ================================================================
//
//  v1.15: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.16 (a real title parameter threaded through SendAlert/
//  SendDiscordMsg/SendTelegramMsg, so each tier's Discord embed shows its own tier-tagged
//  title instead of one hardcoded generic title for every alert). This port's own
//  buildAlertJson() already takes a title parameter and has since this port's own v1.8, and
//  every one of the four Tier 1/2/3 alert call sites already passes its own direction-aware,
//  tier-tagged title string built at the call site - the same design the C# side adopted
//  here. (cTrader changelog v1.15 - moving a parameter to the top of its input group - is
//  purely a cosmetic UI-ordering fix with no Pine equivalent to port; skipped per the task's
//  own instruction.)
// ================================================================
//
//  v1.14: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.14 (added live PC WATCH (T3) and MA WATCH (T2) dashboard
//  rows, showing "None" or "BUY/SELL k/N" for an active watch). This port's own dashboard
//  already has both rows (see MAIN DASHBOARD HUD above, rows 11 and 12), added in this
//  port's own v1.5 when MA WATCH (T2) was ported alongside PC WATCH (T3) - present here
//  ahead of this specific cTrader version landing it there.
// ================================================================
//
//  v1.13: SKIPPED - cTrader changelog v1.13's three-tier Discord webhook routing (a separate
//  WebhookUrl/WebhookUrlMaConfirm/WebhookUrlPcConfirm per tier, each its own Discord channel)
//  has no Pine equivalent, confirmed against TradingView's own alert() model: a Pine script
//  has no network/HTTP access of its own and cannot set or choose a webhook URL at runtime -
//  every alert() call from one alert instance is delivered to the single webhook URL
//  configured in TradingView's own Create Alert dialog at alert-creation time, regardless of
//  which tier's code path triggered it. This script's existing design already works around
//  the same limitation the only way Pine allows: tier tags in the message text/title (TIER 1/
//  TIER 2/TIER 3) distinguish tiers within one channel, and reaching separate channels means
//  creating separate alert instances from this one script, each pointed at its own webhook in
//  TradingView's Notifications tab - not a per-tier input this script itself can add.
// ================================================================
//
//  v1.12: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.12 (Session Mode gained an Auto option, now the default,
//  inferring Daily/Weekly/Monthly from the chart's own timeframe: H1-and-below -> Daily,
//  strictly between H1 and D1 -> Weekly, D1-and-above -> Monthly). This port's own
//  sessionModeInput already defaults to "Auto" with that exact same boundary
//  (tfSeconds <= 3600 -> Daily, < 86400 -> Weekly, else Monthly - see SESSION ANCHORING
//  above), present here since this port's own v1.0 for the reason explained there: Pine's
//  session boundaries come from TradingView's own time("D")/time("W")/time("M"), not a
//  manual hour-offset, so there was never an "always defaults to Daily" problem to fix in the
//  first place - Auto was the natural default from the start.
// ================================================================
//
//  v1.11: SKIPPED - cTrader changelog v1.10/v1.11 (MA Cross lines not rendering on a new bar
//  without a manual refresh) describes a bug class specific to cAlgo's manual line.new()+
//  remove/redraw pattern: a same-bar guard set before the draw loop ran (so an exception
//  left it falsely "remembered"), and separately, a drawn range that included the live,
//  still-forming bar and therefore went stale once the guard locked for the bar. Neither
//  mechanism exists in this port's own MA Cross implementation (see the v2.2 section above) -
//  it uses Pine's native plot(), which recomputes and redraws its value every single bar
//  automatically, with no manual object array, no same-bar guard, and no concept of a
//  "drawn range" that could go stale. This is a genuine platform/architecture difference, not
//  an oversight: plot() was chosen specifically over this file's own line.new()+allLines
//  pattern to avoid exactly this class of manual-redraw bug. No equivalent fix is applicable.
// ================================================================
//
//  v1.10: confirmed-matching, no code change needed - checked against the cTrader Session
//  indicator's own changelog v1.9 (EDGE EXH label nudge changed from ATR-scaled to a small,
//  fixed 5-tick offset, since the old ATR-scaled nudge looked too far from the candle on
//  higher-ATR assets like Gold/XAUUSD). This port's own label.new() calls for EDGE EXH
//  (SELL/BUY) already use syminfo.mintick * 5 as the wick-touch tolerance/nudge, not an
//  ATR-scaled value - same fixed-5-tick behavior the C# side just adopted, present here
//  since this port's own v1.0.
// ================================================================
//
//  v1.9: real bug fix, confirmed on chart - gray/paused EDGE EXH labels never appeared when
//  the empty-bin count fell short, because that check sat in the outer entry condition and
//  skipped the whole label (no draw at all, not even gray). Restructured so only the
//  wick-touch gates entry; empty-bin count and the existing sigOk (cooldown/gate/dead-time)
//  checks are now evaluated side by side, and either one failing draws the gray "⏸" label
//  instead of drawing nothing - matching the cTrader Session indicator (v1.23), where
//  insufficient empty bins is just one of several reasons a touch still gets a gray label.
//
//  v1.8: Telegram support added directly, no relay/bridge service needed - confirmed
//  against a real working example (bot created via @BotFather, chat ID read from
//  getUpdates, TradingView's webhook URL pointed straight at
//  https://api.telegram.org/bot<TOKEN>/sendMessage). New Alert Output Format input
//  (Discord/Telegram) plus Telegram Chat ID and optional Telegram Topic ID, all in the
//  existing Discord/Telegram Alerts group. buildAlertJson() now builds either Discord's
//  embed JSON or Telegram's {"chat_id":...,"text":...} shape, shared by all four Tier 1/2/3
//  alert sites, replacing each site's own hardcoded Discord-only JSON string. One format
//  per alert instance still applies - Pine has no way to fire two differently-shaped bodies
//  from a single alert() call, so "both" means adding the indicator to the chart twice (or
//  creating two alerts from the one script), one set to Discord, one to Telegram, each with
//  its own webhook URL/API endpoint and its own Telegram Chat ID if needed.
// ================================================================
//
//  Everything below this line is vep.pine's own original changelog, kept intact for
//  provenance - describes that script's own history, not this port's.
// ================================================================
//
//  v2.1 - cTrader parity pass
//  Two real gaps found and fixed, both matching bugs already confirmed
//  and fixed on the cTrader side. Everything else in this script was
//  already close to parity; these two were genuine, portable misses,
//  not stylistic differences.
//
//  1. EMPTY label only ever drew on the live profile (pNum == 0), never
//     on historical ones - same bug confirmed and fixed on the cTrader
//     indicator in v2.11. The consecutive-empty-bin count itself was
//     always computed correctly per profile; only the label's own
//     pNum == 0 gate was wrong. Fixed - EMPTY now draws on every
//     profile shown. (The separate v2.12 label-position drift fix does
//     not apply here - that bug was specific to cTrader's "+8 bars past
//     the profile's own end" placement, which this script never used;
//     Pine already anchors at the profile's own end bar directly.)
//
//  2. The PDC Cross Alert's confirmation only ever required closing
//     past BARE PDC - the same real gap confirmed and fixed on both the
//     cTrader indicator (v2.14) and VEPS (v2.31): the alert could fire
//     on a close that barely ticked past PDC, reporting an entry price
//     nothing would ever really be filled at, since the real cBot
//     always targets PDC ± its own Entry Buffer, never raw PDC. New
//     input PDC Alert Entry Buffer (x ATR) (default 0.2, matching its
//     SL-buffer sibling's own style) fixes this: the alert now requires
//     closing past PDC ± the buffer before firing, and reports that
//     buffered level as Entry. Real effect: fires later and less often
//     than before, but the number in it is now the real level. The
//     Entry line also now shows the underlying math directly (matching
//     indicator v2.15) - e.g. "Entry: 1.38732 (PDC 1.38792 - 6.0p
//     buffer)" - so the buffer is verifiable from the alert itself.
//
//  Deliberately still excluded, same as every prior Pine revision:
//  License System (no account/network layer in Pine to gate) and any
//  cBot-side, account-connected logic from more recent cTrader sessions
//  (the cross-process Mutex fix, the post-placement cap re-check, the
//  standing OVER CAP detector, Volume Confirmation) - all of these
//  depend on a live broker account connection that Pine, in this
//  alert-only style, simply does not have.
//
//  v2.2 - MA Cross, parity with the cTrader indicator's own v2.19 addition. Two
//  configurable moving averages (type, length, color, width, style each
//  independently) plus a cross marker, colored by direction - purely visual here,
//  same as everywhere else in this script, no alert or trade logic attached.
//
//  Built with plot() rather than this file's usual line.new()+allLines pattern
//  (see POC/VAH/PDC above) - deliberately different, not an oversight: a moving
//  average exists on every single bar, unlike POC/VAH/PDC's sparse, periodic
//  reference levels, and redrawing potentially hundreds of manual line objects
//  every bar via array.clear()+rebuild would be real, avoidable overhead plot()
//  simply doesn't have. This also directly matches how the original, simple Pine
//  MA Cross script this feature is based on was built - plot() for the lines,
//  Pine's own native plot.style_cross for the cross marker (via ta.crossover()/
//  ta.crossunder()), not a manual label the way this file's other markers work.
//
//  One real, worth-knowing tradeoff: plot() can't do genuine Dashed/Dotted the
//  way line.new() can - MA Short/Long Line Style pick from plot()'s own native
//  style options instead (Line/Stepline/Circles), not Solid/Dashed/Dotted like
//  every other Style input in this file (getMaPlotStyle(), separate from
//  getStyle() above which remains line.new()-only).
// ================================================================
//
//  v2.3 - added MA Cross Marker Size (linewidth for the cross plots), matching the same
//  gap just found and fixed on the cTrader indicator's own v2.21 - the cross marker was
//  hardcoded (linewidth=4) with no way to change it. Range set to 1-10 as a reasonable,
//  safe default - not independently verified against Pine's actual maximum linewidth for
//  plot.style_cross specifically, so raise maxval here if 10 turns out to be overly
//  conservative.
// ================================================================

// v1.2 (this port): max_bars_back added after a real runtime error at bar 21272 -
// "requested historical offset (117) is beyond the historical buffer's limit (116)". Pine
// auto-sizes this buffer by analyzing the script's own [] lookback usage on the chart's
// first 244 bars; a session that's short early in the chart's history under-provisions the
// buffer, and a longer session appearing later (most likely one spanning a weekend gap -
// Friday into Sunday/Monday can read as one continuous "Daily" session if the boundary
// detection doesn't catch the gap) then exceeds it. 2000 comfortably covers any realistic
// single session across all three modes, with real margin - see maxSessionBars below for
// the matching safety cap on the loop side.
indicator(SCRIPT_NAME, overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=100, max_bars_back=2000)

// --- BUFFER STABILIZATION ---
max_bars_back(volume, 4999)
max_bars_back(high,   4999)
max_bars_back(low,    4999)
max_bars_back(close,  4999)

// ============================================================
//   INPUTS
// ============================================================

// UI Controls
showDash      = input.bool(true,   "Show Dashboard HUD",                group="UI Controls")
dashTxtSize   = input.string("Small", "Dashboard Text Size",            options=["Tiny","Small","Normal","Large"], group="UI Controls")
dashVPos      = input.string("Top",   "Dashboard Vertical Alignment",   options=["Top","Middle","Bottom"], group="UI Controls")
dashHPos      = input.string("Right", "Dashboard Horizontal Alignment", options=["Left","Right"], group="UI Controls")

sizeConst = dashTxtSize == "Tiny" ? size.tiny : dashTxtSize == "Small" ? size.small : dashTxtSize == "Normal" ? size.normal : size.large
vPosConst = dashVPos == "Top" ? position.top_right : dashVPos == "Middle" ? position.middle_right : position.bottom_right
finalPos  = dashHPos == "Left" ? (dashVPos == "Top" ? position.top_left : dashVPos == "Middle" ? position.middle_left : position.bottom_left) : vPosConst

// Session Settings [VEPS] - the core organizing concept this port adds on top of VEP's own
// proven profile/alert engine. Auto infers the session from the chart's own timeframe -
// H1-and-below -> Daily, strictly between H1 and D1 -> Weekly, D1-and-above -> Monthly -
// same boundary as the cAlgo VEPS source's own GetEffectiveSessionMode(). A non-Auto value
// is a genuine manual override, e.g. Monthly on an H4 chart. Quarterly, Half-Year and Yearly
// are all manual-only additions on top of that - the cTrader source has none of the three, so
// Auto never selects any of them; pick Quarterly or Half-Year explicitly on a W1 chart for a
// 3- or 6-month profile instead of Monthly's ~4 bars, or Yearly for a full-year one.
sessionModeInput = input.string("Auto", "Session Mode", options=["Auto", "Daily", "Weekly", "Monthly", "Quarterly", "Half-Year", "Yearly"], group="Session Settings")
minBarsSinceReset = input.int(5, "Min Bars Since Session Reset (cold-start gate)", minval=0, group="Session Settings")

// Signal Label Toggles - EDGE EXH only, matching VEPS's actual feature set. VEP's own
// VA TRAP/POC/REJECTION signal types are deliberately not carried over to this build.
showEdgeExh   = input.bool(true, "Enable Edge Exhaustion Labels",   group="Alerts (Discord & Chart Labels)")

// EDGE EXH bin settings [NEW v2.0] - matches cTrader's consecutive empty-bin definition exactly.
// Not a cosmetic filter - this IS the definition of the signal. A single isolated empty bin with
// real volume on either side no longer counts; the void must be genuinely consecutive from the
// true price extreme inward.
minEmptyBinsHigh = input.int(3,     "Min Empty Bins (High/Sell Side)", minval=1, maxval=5, group="EDGE EXH Bin Settings")
minEmptyBinsLow  = input.int(2,     "Min Empty Bins (Low/Buy Side)", minval=1, maxval=5, group="EDGE EXH Bin Settings")
boundaryScanPct = input.float(15.0,"Boundary Scan Window (% of bins)", minval=5.0, maxval=50.0, group="EDGE EXH Bin Settings")

// Volatility Filter
useVolFilter = input.bool(true,  "Enable Volatility Filter", group="Volatility Filter")
minAtrPips   = input.float(2.0,  "Min ATR (Pips)",           group="Volatility Filter")

// Risk Management
useRiskMgmt    = input.bool(true,  "Enable Risk Calculations",    group="Risk Management")
showRiskLabels = input.bool(true,  "Show PTP/PSL on Chart Labels", group="Risk Management")
rrRatio        = input.float(2.0,  "Risk:Reward Ratio",  minval=0.1, step=0.1, group="Risk Management")
slAtrMult      = input.float(1.5,  "Stop Loss ATR Multiplier", minval=0.1, step=0.1, group="Risk Management")

// Volume Analysis
volZLen     = input.int(20,    "Volume Lookback Length",    minval=1,  group="Volume Analysis")
spikeZScore = input.float(2.0, "Spike Z-Score Multiplier", step=0.1,  group="Volume Analysis")
quietZScore = input.float(-0.5,"Quiet Z-Score Multiplier", step=0.1,  group="Volume Analysis")

// Range Settings
// v1.0 (this port): useAutoLookback/numProfiles/lookbackBars removed - session-anchoring
// (see Session Settings above) replaces the rolling-window concept entirely. There is one
// live profile per session, its window bounded by the session's own start, not a
// fixed/hardcoded bar count, and no cross-profile confluence the way VEP's numProfiles
// compared POCs across N fixed-bar segments - see the Confluence Gate note further down for
// why that's deliberately not carried over in this pass.
numSessions     = input.int(1,      "Number of Sessions to Show", minval=1, maxval=5, group="Range Settings",
     tooltip="1 shows only the live, current session. Higher values also draw the last N-1 COMPLETED sessions' own profiles alongside it - the session-based equivalent of vep.pine's own Number of Profiles. Capped at 5 for chart readability - more than a few overlaid profiles gets cluttered fast. See Max Session Length below for how this combines with that setting to stay inside the historical buffer.")
maxSessionBars  = input.int(400,    "Max Session Length (bars, safety cap)", minval=50, maxval=400, group="Range Settings",
     tooltip="Caps how many bars back any single session's profile calc reaches, even if the session itself ran longer (e.g. a weekend-spanning session). Capped at 400 specifically so numSessions(max 5) × maxSessionBars(max 400) = 2000 exactly matches max_bars_back above - a genuinely guaranteed-safe worst case, not just an unlikely-in-practice one. Raise max_bars_back on the indicator() line itself first if you need more room than that.")
priceBins       = input.int(30,     "Price Rows (Bins)", minval=10, maxval=200, group="Range Settings")
widthFactor     = input.float(70.0, "Profile Width (%)", minval=1.0, maxval=100.0, group="Range Settings") / 100.0
vaPercent       = input.float(40.0, "Value Area Volume %", group="Range Settings")

// Visual Settings
showVolLabels   = input.bool(true,  "Show Volume Labels (Latest Only)", group="Visual Settings")
volLabelBullCol = input.color(color.new(#00ff08, 0), "Buy Volume Color",        group="Visual Settings")
volLabelBearCol = input.color(color.new(#ff0000, 0), "Sell Volume Color",       group="Visual Settings")
volLabelExhCol  = input.color(color.new(#cccccc, 0), "Exhaustion Volume Color", group="Visual Settings")
volLabelSize    = input.string("tiny", "Label Text Size", options=["auto","tiny","small","normal"], group="Visual Settings")

// Visuals
bullColor     = input.color(color.new(#2e8b57, 30), "Bullish Bar",    group="Visuals")
bearColor     = input.color(color.new(#b22222, 30), "Bearish Bar",    group="Visuals")
exhBarColor   = input.color(color.new(#696969, 30), "Exhaustion Bar", group="Visuals")
profOpacity   = input.int(65,  "Profile Opacity (0-100)", group="Visuals")
bullSigCol    = input.color(color.new(#00ff00, 0), "Bullish Signal Color", group="Visuals")
bearSigCol    = input.color(color.new(#ff0000, 0), "Bearish Signal Color", group="Visuals")
pocColor      = input.color(color.rgb(255, 235, 59, 34), "POC Color",  group="Visuals")
pocWidth      = input.int(4, "POC Line Width", group="Visuals")
pocStyleStr   = input.string("Solid",  "POC Line Style",  options=["Solid","Dashed","Dotted"], group="Visuals")
vahColor      = input.color(color.rgb(2, 248, 56, 31),  "VAH Color",  group="Visuals")
vahWidth      = input.int(2, "VAH Line Width", group="Visuals")
vahStyleStr   = input.string("Dotted", "VAH Line Style",  options=["Solid","Dashed","Dotted"], group="Visuals")
valColor      = input.color(color.rgb(255, 6, 6, 35),   "VAL Color",  group="Visuals")
valWidth      = input.int(2, "VAL Line Width", group="Visuals")
valStyleStr   = input.string("Dotted", "VAL Line Style",  options=["Solid","Dashed","Dotted"], group="Visuals")
showLabels    = input.bool(true, "Show Price Labels (Inside)", group="Boundary Customization")
boundColor    = input.color(color.gray, "Boundary Color",      group="Boundary Customization")
boundWidth    = input.int(1, "Boundary Width", group="Boundary Customization")
boundStyle    = input.string("Dotted","Boundary Style", options=["Solid","Dashed","Dotted"], group="Boundary Customization")

// PC Settings [NEW v2.0, generalized from PDC in this port] - internal identifiers (pdcValue,
// pdcColor, etc.) deliberately kept unchanged, matching the same precedent the cAlgo VSPC
// port set generalizing VPDC's own PDC - only the displayed labels change from PDC to PC,
// since a Weekly or Monthly reference literally labeled "Previous DAY Close" would be wrong.
showPdcLine  = input.bool(true, "Show PC Line", group="PC Settings")
pdcColor     = input.color(color.new(#2196f3, 0), "PC Color", group="PC Settings")
pdcWidth     = input.int(1, "PC Line Width", minval=1, maxval=4, group="PC Settings")
pdcStyleStr  = input.string("Dotted", "PC Line Style", options=["Solid","Dashed","Dotted"], group="PC Settings")

// MA Cross [NEW v2.2] - parity with the cTrader indicator's own v2.19 addition. Uses plot()
// rather than this file's usual line.new()+allLines pattern (see POC/VAH/PDC above) -
// deliberately different, not an oversight: a moving average exists on every single bar,
// unlike POC/VAH/PDC's sparse, periodic reference levels, and redrawing potentially hundreds
// of manual line objects every bar via array.clear()+rebuild would be real, avoidable
// overhead that plot() simply doesn't have. This also directly matches how the original,
// simple Pine MA Cross script this feature is based on was built - plot() for the lines,
// Pine's own native plot.style_cross for the cross marker, not a manual label.
// One real, worth-knowing tradeoff: plot() can't do genuine Dashed/Dotted the way line.new()
// can - "MA Line Style" below picks from plot()'s own native style options instead
// (Line/Stepline/Circles), not Solid/Dashed/Dotted like every other Style input in this file.
showMaCross      = input.bool(true, "Show MA Cross", group="MA Cross")
maTypeStr        = input.string("SMA", "MA Type", options=["SMA","EMA","WMA"], group="MA Cross")
maShortLen       = input.int(9, "MA Short Length", minval=1, group="MA Cross")
maLongLen        = input.int(26, "MA Long Length", minval=1, group="MA Cross")
maShortColor     = input.color(color.new(#00e676, 0), "MA Short Color", group="MA Cross")
maShortWidth     = input.int(2, "MA Short Width", minval=1, maxval=5, group="MA Cross")
maShortStyleStr  = input.string("Line", "MA Short Line Style", options=["Line","Stepline","Circles"], group="MA Cross")
maLongColor      = input.color(color.new(#ff9100, 0), "MA Long Color", group="MA Cross")
maLongWidth      = input.int(2, "MA Long Width", minval=1, maxval=5, group="MA Cross")
maLongStyleStr   = input.string("Line", "MA Long Line Style", options=["Line","Stepline","Circles"], group="MA Cross")
showMaCrossMarks = input.bool(true, "Show MA Cross Markers", group="MA Cross")
maCrossMarkSize  = input.int(4, "MA Cross Marker Size", minval=1, maxval=10, group="MA Cross")
maBullCrossColor = input.color(color.new(#2962ff, 0), "Bullish Cross Color", group="MA Cross")
maBearCrossColor = input.color(color.new(#ff1744, 0), "Bearish Cross Color", group="MA Cross")

// PC Cross Alert - Tier 3 [generalized from PDC Cross Alert in this port] - mirrors the
// Sniper cBot's own EDGE EXH + PC watch mechanism. A separate, later-firing alert from the
// Tier 1 general EDGE EXH one: this only fires once price actually closes back across PC
// after an EDGE EXH signal, not on the raw pattern alone. Internal identifiers kept as pdc*,
// same precedent as PC Settings above.
enablePdcCrossAlert = input.bool(true, "Enable PC Cross Alert (Tier 3)", group="PC Cross Alert (Tier 3)")
pdcAlertExpiryBars  = input.int(8, "PC Cross Expiry (bars)", minval=1, maxval=50, group="PC Cross Alert (Tier 3)")
pdcAlertSlBufferAtr = input.float(0.1, "PC Alert SL Buffer (x ATR)", minval=0.0, group="PC Cross Alert (Tier 3)")
// [v2.1 parity fix] the cross previously required only closing beyond BARE PDC - the same real
// gap confirmed and fixed on both the cTrader indicator (v2.14) and VEPS (v2.31): a trade/alert
// could confirm on a close that barely ticked past PDC, reporting an entry nothing would really
// be filled at, since the real cBot always targets PDC ± its own Entry Buffer, never raw PDC.
pdcAlertEntryBufferAtr = input.float(0.2, "PC Alert Entry Buffer (x ATR)", minval=0.0, group="PC Cross Alert (Tier 3)")

// MA Cross Alert - Tier 2 [NEW in this port] - vep.pine's own MA Cross section (above) is
// purely visual (plot lines + cross markers), with no alert mechanism attached at all. This
// adds one, mirroring the exact same watch/arm/expire pattern the PC Cross Alert above
// already proves works - backward check first (a cross already happened recently), and if
// that finds nothing, a forward watch arms instead of the moment just passing.
enableMaCrossAlert    = input.bool(false, "Enable MA Cross Alert (Tier 2)", group="MA Cross Alert (Tier 2)")
backwardCrossLookback = input.int(3, "Backward Cross Lookback (bars)", minval=1, maxval=20, group="MA Cross Alert (Tier 2)")
maForwardExpiryBars   = input.int(5, "MA Cross Forward Expiry (bars)", minval=1, maxval=20, group="MA Cross Alert (Tier 2)")

// Dead Time Filter [NEW v2.0] - Pine has no equivalent to cAlgo's Symbol.MarketHours (the broker's
// own real trading calendar), so this is a manual UTC window instead of an automatically-detected
// one. Set this to whatever hours you know this symbol is illiquid/closed for your broker.
enableDeadTime      = input.bool(false, "Enable Dead Time Filter", group="Dead Time Filter")
deadTimeStartHourUTC = input.int(21, "Dead Time Start Hour (UTC)", minval=0, maxval=23, group="Dead Time Filter")
deadTimeEndHourUTC   = input.int(22, "Dead Time End Hour (UTC)",   minval=0, maxval=23, group="Dead Time Filter")

// Confluence Gate
// v1.0 (this port): Min Confluence to Open Gate removed with numProfiles above - it compared
// POCs across N fixed-bar rolling segments, a concept that doesn't map cleanly onto
// variable-length sessions. The gate below now runs on the Volatility Filter alone. Worth
// revisiting as a real cross-session confluence feature later if wanted - not attempted here
// rather than guessing at an untested replacement mechanism.

// Signal Cooldown
enableCooldown  = input.bool(true,  "Enable Signal Cooldown",           group="Signal Cooldown")
cooldownBars    = input.int(5,      "Cooldown Duration (bars)",          minval=1, maxval=50,  group="Signal Cooldown")
cooldownAtrMult = input.float(1.5,  "Cooldown ATR Distance Multiplier", minval=0.1, step=0.1, group="Signal Cooldown")

// Alert Time/Day Filter [v1.7] - ported from the cTrader suite's own proven pattern
// (VPDC/VSPC/VMAX/VSMA/VEPS), on direct request. Independent of the Dead Time Filter above
// (that's a manual illiquid-hours window); this only gates whether a confirmed Tier 1/2/3
// signal actually fires its alert() call. Pine has no direct Telegram/Discord API access of
// its own (see the Communications section's own note on that), so this only ever gates the
// single alert() call each tier makes - not a per-destination decision the way the cTrader
// side's SendAlert can make.
enableCustomTimeFilter = input.bool(false, "Enable Custom Time Filter", group="Alert Time/Day Filter")
monStartHour = input.int(0,  "Monday Start Hour",    minval=0, maxval=23, group="Alert Time/Day Filter")
monEndHour   = input.int(23, "Monday End Hour",      minval=0, maxval=23, group="Alert Time/Day Filter")
tueStartHour = input.int(0,  "Tuesday Start Hour",   minval=0, maxval=23, group="Alert Time/Day Filter")
tueEndHour   = input.int(23, "Tuesday End Hour",      minval=0, maxval=23, group="Alert Time/Day Filter")
wedStartHour = input.int(0,  "Wednesday Start Hour", minval=0, maxval=23, group="Alert Time/Day Filter")
wedEndHour   = input.int(23, "Wednesday End Hour",    minval=0, maxval=23, group="Alert Time/Day Filter")
thuStartHour = input.int(0,  "Thursday Start Hour",  minval=0, maxval=23, group="Alert Time/Day Filter")
thuEndHour   = input.int(23, "Thursday End Hour",     minval=0, maxval=23, group="Alert Time/Day Filter")
friStartHour = input.int(0,  "Friday Start Hour",    minval=0, maxval=23, group="Alert Time/Day Filter")
friEndHour   = input.int(23, "Friday End Hour",       minval=0, maxval=23, group="Alert Time/Day Filter")
satStartHour = input.int(0,  "Saturday Start Hour",  minval=0, maxval=23, group="Alert Time/Day Filter")
satEndHour   = input.int(23, "Saturday End Hour",     minval=0, maxval=23, group="Alert Time/Day Filter")
sunStartHour = input.int(0,  "Sunday Start Hour",    minval=0, maxval=23, group="Alert Time/Day Filter")
sunEndHour   = input.int(23, "Sunday End Hour",       minval=0, maxval=23, group="Alert Time/Day Filter")
useLocalTimeForFilters = input.bool(false, "Use Local Time for Filters", group="Alert Time/Day Filter")
alertTzOffsetHours     = input.int(8, "Time Zone Offset (UTC+)", minval=-12, maxval=14, group="Alert Time/Day Filter")
enableDayFilter = input.bool(false, "Enable Day Filter", group="Alert Time/Day Filter")
alertMonday    = input.bool(true,  "Alert Monday",    group="Alert Time/Day Filter")
alertTuesday   = input.bool(true,  "Alert Tuesday",   group="Alert Time/Day Filter")
alertWednesday = input.bool(true,  "Alert Wednesday", group="Alert Time/Day Filter")
alertThursday  = input.bool(true,  "Alert Thursday",  group="Alert Time/Day Filter")
alertFriday    = input.bool(true,  "Alert Friday",    group="Alert Time/Day Filter")
alertSaturday  = input.bool(false, "Alert Saturday",  group="Alert Time/Day Filter")
alertSunday    = input.bool(false, "Alert Sunday",    group="Alert Time/Day Filter")

// Discord/Telegram Alerts [v1.8] - on direct request. Pine's alert() sends one JSON body to
// whichever single webhook URL you configure in TradingView's own Create Alert dialog - the
// script can't pick a destination at runtime the way the cTrader side's SendAlert can. What
// it CAN do is build the body in either shape: Discord's own embed JSON, or Telegram's own
// {"chat_id":...,"text":...} shape, which TradingView can POST directly to
// https://api.telegram.org/bot<YOUR_TOKEN>/sendMessage with no relay/bridge service needed -
// confirmed against a real working example (Telegram bot created via @BotFather, chat ID
// read from getUpdates, webhook URL pointed straight at the sendMessage endpoint). To use
// BOTH: add this indicator to the chart twice (or create two alerts from the one script,
// each with its own "Any alert() function call" condition), set Alert Output Format to
// Discord on one and Telegram on the other, and give each its own webhook URL/API endpoint
// in TradingView's Notifications tab. One alert format per alert instance - Pine has no way
// to fire two differently-shaped bodies from one alert() call.
enableAlerts   = input.bool(false, "Enable Discord Alerts", group="Discord Alerts")
alertFormat    = input.string("Discord", "Alert Output Format", options=["Discord", "Telegram"], group="Discord Alerts")
telegramChatId = input.string("", "Telegram Chat ID (for Telegram format)", group="Discord Alerts")
telegramTopicId = input.string("", "Telegram Topic ID (optional)", group="Discord Alerts")

// [v2.07 fix] v1.0 of this port left the D1 Direction Dashboard PANEL out, reasoning it was a
// VEP-only display unrelated to VEPS's session-anchored design. On review, that reasoning
// didn't hold up: the D1 bias DATA itself (d1_poc/d1_vah/d1_val/d1_adx, the PEP calc, flip
// tracking) was never actually removed - it's all still computed further down and already
// feeds pepStr and the alert payload's d1Ctx/flipCtx. Only the separate on-chart table that
// displays it was skipped. VEP's own multi-timeframe design treats D1 bias as a standing
// filter sitting above whichever profile logic runs underneath it (session here, rolling in
// VEPF) - there's no reason VEPS should compute this data but never show it. Added for parity
// with VEPF, verbatim same panel.
// D1 Dashboard
showD1Dash    = input.bool(true,      "Show D1 Direction Dashboard",         group="D1 Dashboard")
d1DashVPos    = input.string("Bottom","D1 Dashboard Vertical Position",      options=["Top","Middle","Bottom"], group="D1 Dashboard")
d1DashHPos    = input.string("Left",  "D1 Dashboard Horizontal Position",    options=["Left","Right"],          group="D1 Dashboard")
d1DashTxtSize = input.string("Small", "D1 Dashboard Text Size",              options=["Tiny","Small","Normal"], group="D1 Dashboard")

d1SizeConst = d1DashTxtSize == "Tiny" ? size.tiny : d1DashTxtSize == "Small" ? size.small : size.normal
d1FinalPos  = d1DashVPos == "Top" and d1DashHPos == "Left" ? position.top_left : d1DashVPos == "Top" and d1DashHPos == "Right" ? position.top_right : d1DashVPos == "Middle" and d1DashHPos == "Left" ? position.middle_left : d1DashVPos == "Middle" and d1DashHPos == "Right" ? position.middle_right : d1DashVPos == "Bottom" and d1DashHPos == "Left" ? position.bottom_left : position.bottom_right

// ============================================================
//   HELPERS
// ============================================================

getStyle(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// plot()'s own native style set, distinct from getStyle() above which is for line.new() only.
getMaPlotStyle(s) => s == "Line" ? plot.style_line : s == "Stepline" ? plot.style_stepline : plot.style_circles

// Pine has no single unified "moving average type" function the way cAlgo's MovingAverageType
// enum does - each type is its own separate ta.* call, selected here via a plain string switch.
getMa(src, len, t) => t == "EMA" ? ta.ema(src, len) : t == "WMA" ? ta.wma(src, len) : ta.sma(src, len)

atrValRaw    = ta.atr(14)

// MA Cross computation and plotting - self-contained here, same as the rest of this file
// tends to keep each feature localized rather than scattered across the script.
maShortVal = getMa(close, maShortLen, maTypeStr)
maLongVal  = getMa(close, maLongLen, maTypeStr)

plot(showMaCross ? maShortVal : na, title="MA Short", color=maShortColor, linewidth=maShortWidth, style=getMaPlotStyle(maShortStyleStr))
plot(showMaCross ? maLongVal  : na, title="MA Long",  color=maLongColor,  linewidth=maLongWidth,  style=getMaPlotStyle(maLongStyleStr))

maCrossUp   = ta.crossover(maShortVal, maLongVal)
maCrossDown = ta.crossunder(maShortVal, maLongVal)
plot(showMaCross and showMaCrossMarks and maCrossUp   ? maShortVal : na, title="MA Bullish Cross", color=maBullCrossColor, style=plot.style_cross, linewidth=maCrossMarkSize)
plot(showMaCross and showMaCrossMarks and maCrossDown ? maShortVal : na, title="MA Bearish Cross", color=maBearCrossColor, style=plot.style_cross, linewidth=maCrossMarkSize)
float riskDist   = atrValRaw * slAtrMult
float rewardDist = riskDist * rrRatio
pipVal  = syminfo.mintick * 10
atrPips = atrValRaw / pipVal

getRiskLabel(bool isBuy, float entryPrice) =>
    string txt = ""
    if useRiskMgmt and showRiskLabels
        float tpPrice = isBuy ? entryPrice + rewardDist : entryPrice - rewardDist
        float slPrice = isBuy ? entryPrice - riskDist   : entryPrice + riskDist
        txt := "\n🎬 Entry: " + str.tostring(entryPrice, format.mintick) + "\n🎯 PTP: " + str.tostring(tpPrice, format.mintick) + "\n🛡️ PSL: " + str.tostring(slPrice, format.mintick)
    txt

// Dead Time check [NEW v2.0] - manual UTC window, since Pine has no broker-calendar equivalent.
// Handles a window that wraps past midnight UTC (e.g. 23:00-01:00) the same as one that doesn't.
inDeadTime() =>
    if not enableDeadTime
        false
    else
        int h = hour(time, "UTC")
        deadTimeStartHourUTC <= deadTimeEndHourUTC ? (h >= deadTimeStartHourUTC and h < deadTimeEndHourUTC) : (h >= deadTimeStartHourUTC or h < deadTimeEndHourUTC)

// Historical variant of inDeadTime(), using time[off] instead of time. Needed to correctly
// freeze EDGE EXH label color at the bar where the touch actually happened (v2.06 fix) -
// see the comment above sellBinOkCache's old declaration site in the DRAWING ENGINE section.
inDeadTimeAt(int off) =>
    if not enableDeadTime
        false
    else
        int h = hour(time[off], "UTC")
        deadTimeStartHourUTC <= deadTimeEndHourUTC ? (h >= deadTimeStartHourUTC and h < deadTimeEndHourUTC) : (h >= deadTimeStartHourUTC or h < deadTimeEndHourUTC)

// Alert Time/Day Filter check [v1.7] - ported from the cTrader suite's own pattern. tz is
// built as a "UTC±N" string, Pine's own accepted format for hour()/dayofweek()'s timezone
// argument, so Use Local Time for Filters reads local hours/day-of-week rather than UTC ones
// without needing a separate local-time library. dayofweek() returns dayofweek.sunday..
// dayofweek.saturday (Sunday=1..Saturday=7), matched directly against those constants below.
isAlertTimeAllowed() =>
    string tz = useLocalTimeForFilters ? ("UTC" + (alertTzOffsetHours >= 0 ? "+" : "") + str.tostring(alertTzOffsetHours)) : "UTC"
    int fHour = hour(time, tz)
    int fDow  = dayofweek(time, tz)
    int startH = fDow == dayofweek.monday ? monStartHour : fDow == dayofweek.tuesday ? tueStartHour : fDow == dayofweek.wednesday ? wedStartHour : fDow == dayofweek.thursday ? thuStartHour : fDow == dayofweek.friday ? friStartHour : fDow == dayofweek.saturday ? satStartHour : sunStartHour
    int endH   = fDow == dayofweek.monday ? monEndHour   : fDow == dayofweek.tuesday ? tueEndHour   : fDow == dayofweek.wednesday ? wedEndHour   : fDow == dayofweek.thursday ? thuEndHour   : fDow == dayofweek.friday ? friEndHour   : fDow == dayofweek.saturday ? satEndHour   : sunEndHour
    bool timeOk = not enableCustomTimeFilter or (startH <= endH ? (fHour >= startH and fHour <= endH) : (fHour >= startH or fHour <= endH))
    bool dayAllowed = fDow == dayofweek.monday ? alertMonday : fDow == dayofweek.tuesday ? alertTuesday : fDow == dayofweek.wednesday ? alertWednesday : fDow == dayofweek.thursday ? alertThursday : fDow == dayofweek.friday ? alertFriday : fDow == dayofweek.saturday ? alertSaturday : alertSunday
    bool dayOk = not enableDayFilter or dayAllowed
    timeOk and dayOk

// v1.8: single JSON-builder shared by all four Tier 1/2/3 alert sites, so Alert Output
// Format is read once, in one place, rather than duplicating the Discord/Telegram branch at
// every call site. title/desc are passed in already built (with any \n already escaped as
// the literal two-character "\n" the JSON call sites already use); timeStr is the ISO
// timestamp string built at each call site (Telegram's own JSON has no timestamp field, so
// it's simply unused in that branch). Telegram's text field concatenates title+desc since
// Telegram messages have no separate title - unlike Discord's embed, which keeps them apart.
buildAlertJson(string title, string desc, int discCol, string timeStr) =>
    string result = ""
    if alertFormat == "Telegram"
        string topicFrag = telegramTopicId == "" ? "" : ",\"message_thread_id\":" + telegramTopicId
        string fullText = title + "\\n\\n" + desc
        result := "{\"chat_id\":\"" + telegramChatId + "\",\"text\":\"" + fullText + "\",\"parse_mode\":\"Markdown\"" + topicFrag + "}"
    else
        result := "{\"content\": null, \"embeds\": [{\"title\": \"" + title + "\", \"description\": \"" + desc + "\", \"color\": " + str.tostring(discCol) + ", \"footer\": {\"text\": \"" + SCRIPT_NAME + "\"}, \"timestamp\": \"" + timeStr + "\"}]}"
    result

// ============================================================
//   SESSION ANCHORING [replaces AUTO-LOOKBACK from vep.pine]
// ============================================================
// v1.0 (this port): the core structural change from VEP. Where VEP's effectiveLookback was
// a fixed bar count that slides forward every bar, VEPS hard-resets at each session
// boundary - the profile starts genuinely fresh at each reset, not a continuation of the
// previous window shifted by one bar.

tfSeconds = timeframe.in_seconds()
autoSessionMode = tfSeconds <= 3600 ? "Daily" : tfSeconds < 86400 ? "Weekly" : "Monthly"
effectiveSessionMode = sessionModeInput == "Auto" ? autoSessionMode : sessionModeInput

newDaySession     = ta.change(time("D")) != 0
newWeekSession    = ta.change(time("W")) != 0
newMonthSession   = ta.change(time("M")) != 0
newQuarterSession = ta.change(time("3M")) != 0
newHalfYearSession = ta.change(time("6M")) != 0
newYearSession    = ta.change(time("12M")) != 0
isNewSession = effectiveSessionMode == "Daily" ? newDaySession : effectiveSessionMode == "Weekly" ? newWeekSession : effectiveSessionMode == "Monthly" ? newMonthSession : effectiveSessionMode == "Quarterly" ? newQuarterSession : effectiveSessionMode == "Half-Year" ? newHalfYearSession : newYearSession

var int sessionStartBar = na
if isNewSession or na(sessionStartBar)
    sessionStartBar := bar_index

barsSinceReset = bar_index - sessionStartBar
// effectiveLookback kept as the name calcProfile's call sites already use - now the current
// session's own age in bars, not a fixed rolling window size. calcProfile(sIdx, eIdx) takes
// sIdx bars back to eIdx bars back; barsSinceReset bars back is exactly the session's own
// start.
effectiveLookback = math.min(barsSinceReset + 1, maxSessionBars)

// v1.2 (this port): historical session boundaries, tracked so multiple PAST sessions' own
// profiles can be shown - the generalized, session-based equivalent of vep.pine's own
// numProfiles (which compared N fixed-bar rolling segments, a concept dropped when this port
// moved to session-anchoring). Kept as a separate array from sessionStartBar above rather
// than replacing it, since sessionStartBar's own single-value role (feeding barsSinceReset)
// is unrelated to needing the FULL history of boundaries.
var int[] sessionStartBars = array.new_int(0)
if isNewSession or array.size(sessionStartBars) == 0
    array.push(sessionStartBars, bar_index)
    if array.size(sessionStartBars) > 21 // one more than the input's own maxval, below
        array.shift(sessionStartBars)

// v1.2 (this port): resolves session pNum (0 = live/current, 1 = previous completed
// session, 2 = the one before that, ...) into calcProfile's own (sIdx, eIdx) offset
// arguments. valid is false when fewer than pNum+1 sessions have occurred yet in this
// chart's history - the caller skips drawing that pNum rather than reading a
// not-yet-existing array index.
getSessionOffsets(int pNum) =>
    int n = array.size(sessionStartBars)
    int startArrIdx = n - 1 - pNum
    bool valid = startArrIdx >= 0
    int sIdxOut = -1
    int eIdxOut = -1
    if valid
        int startBarIdx = array.get(sessionStartBars, startArrIdx)
        int endBarIdx   = pNum == 0 ? bar_index : array.get(sessionStartBars, n - pNum) - 1
        eIdxOut := bar_index - endBarIdx
        int rawSIdx = bar_index - startBarIdx
        // Same safety cap as effectiveLookback above - caps the SPAN of any single session's
        // profile calc, not just the live one, since a historical session (an earlier
        // pNum >= 1) can just as easily have run long across a weekend gap.
        sIdxOut := math.min(rawSIdx, eIdxOut + maxSessionBars - 1)
    [valid, sIdxOut, eIdxOut]

// ============================================================
//   VOLUME ANALYSIS
// ============================================================

volMean = ta.sma(volume, volZLen)
volStd  = ta.stdev(volume, volZLen)
spikeThreshold = volMean + (volStd * spikeZScore)
quietThreshold = volMean + (volStd * quietZScore)

marketPhase = volume > spikeThreshold ? "AGGRESSIVE 🚀" : volume < quietThreshold ? "EXHAUSTED 💤" : "STABLE ⚖️"
phaseColor  = volume > spikeThreshold ? color.new(#ffaa00,0) : volume < quietThreshold ? color.new(#696969,0) : color.new(#00ffff,0)

// ============================================================
//   ADX
// ============================================================

adxLen = 14
[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxLen)

trendStrength = adxValue > 40 ? "VERY STRONG 💪" : adxValue > 25 ? "TRENDING 📈" : adxValue > 20 ? "WEAK ⚠️" : "RANGING 😴"
trendColor    = adxValue > 40 ? color.lime : adxValue > 25 ? color.green : adxValue > 20 ? color.red : color.gray

// ============================================================
//   GHOSTING PREVENTION
// ============================================================

var box[]   allBoxes  = array.new_box()
var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()
var label[] volLabels = array.new_label()

clearAll() =>
    if array.size(allBoxes) > 0
        for i = 0 to array.size(allBoxes) - 1
            box.delete(array.get(allBoxes, i))
        array.clear(allBoxes)
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)

// ============================================================
//   HTF MAPPING
// ============================================================

htfTF = switch timeframe.period
    "15"  => "120"
    "30"  => "120"
    "60"  => "240"
    "120" => "D"
    "240" => "W"
    "D"   => "W"
    "1D"  => "W"
    => "Invalid"

// ============================================================
//   CALC PROFILE FUNCTION
// ============================================================

calcProfile(int sIdx, int eIdx) =>
    float h = -1.0e10, float l = 1.0e10, float tVol = 0.0
    for i = eIdx to sIdx
        h    := math.max(h, high[i])
        l    := math.min(l, low[i])
        tVol := tVol + volume[i]
    float bSize = (h - l) / priceBins
    float[] bVols = array.new_float(priceBins + 1, 0.0)
    float[] tVols = array.new_float(priceBins + 1, 0.0)
    for i = eIdx to sIdx
        int bIdx = math.min(priceBins, int((close[i] - l) / bSize))
        if close[i] >= open[i]
            array.set(bVols, bIdx, array.get(bVols, bIdx) + volume[i])
        array.set(tVols, bIdx, array.get(tVols, bIdx) + volume[i])
    float maxV    = array.max(tVols)
    int   pBin    = array.indexof(tVols, maxV)
    float pP      = l + (pBin * bSize) + (bSize / 2)
    float targetV = array.sum(tVols) * (vaPercent / 100.0)
    float curV    = array.get(tVols, pBin)
    int tP = pBin, bP = pBin
    while curV < targetV and (tP < priceBins or bP > 0)
        float topV = tP < priceBins ? array.get(tVols, tP + 1) : 0.0
        float botV = bP > 0         ? array.get(tVols, bP - 1) : 0.0
        if topV >= botV and tP < priceBins
            tP   := tP + 1
            curV := curV + topV
        else if bP > 0
            bP   := bP - 1
            curV := curV + botV
        else
            break
    [pP, l + (tP * bSize) + bSize, l + (bP * bSize), tVol / (sIdx - eIdx + 1), h, l, maxV, tVols, bVols, bSize]

// Consecutive empty-bin counter [NEW v2.0] - walks inward from the TRUE price extreme, stopping
// at the first non-empty bin. Matches cTrader's fixed logic exactly (previously a real bug there
// too: a blind total count let a [empty, filled, empty] pattern miscount as 2 consecutive, when
// it's genuinely only 1). A single isolated empty bin with real volume on either side is noise,
// not exhaustion - only a genuine, unbroken void from the edge counts.
countEmptyBinsFromTop(float[] tVols, int totalBins, int boundaryScanN) =>
    int topStart = math.max(0, totalBins - boundaryScanN)
    int count = 0
    for b = totalBins to topStart
        if array.get(tVols, b) == 0.0
            count := count + 1
        else
            break
    count

countEmptyBinsFromBot(float[] tVols, int boundaryScanN) =>
    int count = 0
    for b = 0 to boundaryScanN - 1
        if array.get(tVols, b) == 0.0
            count := count + 1
        else
            break
    count

// ============================================================
//   FETCH PROFILES
// ============================================================

[p0, vh0, vl0, av0, h0, l0, max0, tv0, bv0, bs0] = calcProfile(effectiveLookback - 1, 0)
[htf_pP, htf_vhP, htf_vlP, htf_av, htf_h, htf_l, htf_mx, htf_tv, htf_bv, htf_bs] = request.security(syminfo.tickerid, htfTF != "Invalid" ? htfTF : timeframe.period, calcProfile(effectiveLookback - 1, 0))

// PC - Previous [Session] Close, generalized from PDC. lookahead_off + close[1] on each
// series is the standard non-repainting pattern: on any bar, this reads that period's
// last CONFIRMED close, never a still-forming one. Bug fix: this was left hardcoded to "D"
// (Daily) despite the header above claiming it was already generalized - the header
// described the intended change, but the actual request.security call was never updated to
// match. Three fixed calls (Daily/Weekly/Monthly), picked by effectiveSessionMode, rather
// than a single dynamically-built resolution string - avoids any risk around
// request.security's resolution argument needing to be a simple/constant string in some
// Pine contexts, same reasoning the C# side's GetSessionTimeFrame() comment gives.
float pcDaily     = request.security(syminfo.tickerid, "D",  close[1], lookahead=barmerge.lookahead_off)
float pcWeekly    = request.security(syminfo.tickerid, "W",  close[1], lookahead=barmerge.lookahead_off)
float pcMonthly   = request.security(syminfo.tickerid, "M",  close[1], lookahead=barmerge.lookahead_off)
float pcQuarterly = request.security(syminfo.tickerid, "3M", close[1], lookahead=barmerge.lookahead_off)
float pcHalfYear  = request.security(syminfo.tickerid, "6M", close[1], lookahead=barmerge.lookahead_off)
float pcYearly    = request.security(syminfo.tickerid, "12M", close[1], lookahead=barmerge.lookahead_off)
// v1.22 fix: Quarterly/Yearly fell through to pcMonthly here (a real bug) - this is the PDC
// line and above/below read, so selecting Quarterly or Yearly silently showed the wrong PC
// price the whole time, even though session anchoring itself (isNewSession above) already
// handled both correctly. v1.23 adds Half-Year the same way, from the start this time.
float pdcValue = effectiveSessionMode == "Daily" ? pcDaily : effectiveSessionMode == "Weekly" ? pcWeekly : effectiveSessionMode == "Monthly" ? pcMonthly : effectiveSessionMode == "Quarterly" ? pcQuarterly : effectiveSessionMode == "Half-Year" ? pcHalfYear : pcYearly
bool  pdcAbove = close > pdcValue

// Boundary scan window for empty-bin counting, and this bar's counts on the CURRENT (pNum=0) profile
int boundaryScanN0 = math.max(3, int(priceBins * boundaryScanPct / 100.0))
int emptyBinsTop0   = countEmptyBinsFromTop(tv0, priceBins, boundaryScanN0)
int emptyBinsBot0   = countEmptyBinsFromBot(tv0, boundaryScanN0)

// ============================================================
//   SIGNAL GATE
// ============================================================
// v1.0 (this port): cross-profile confluence removed along with numProfiles - see the note
// on Range Settings above. confluenceScore is kept as a fixed value (not computed) so the
// dashboard/alert text below still shows something coherent rather than needing every one
// of their references hunted down and removed too; gateOpen now runs on the Volatility
// Filter alone.

int confluenceScore = 1
bool gateVolOk  = not useVolFilter or (atrPips >= minAtrPips)
bool gateOpen   = gateVolOk

string gateStatusStr = not gateVolOk ? "CLOSED ✖ LOW VOL" : "OPEN ✔"
color  gateStatusCol = gateOpen ? color.new(#00ff00, 0) : color.new(#ff4444, 0)
string confluenceStr = confluenceScore >= 3 ? "HIGH ★★★" : confluenceScore == 2 ? "MED ★★" : "LOW ★"
color  confluenceCol = confluenceScore >= 3 ? color.new(#00ff00, 0) : confluenceScore == 2 ? color.new(#ffcc00, 0) : color.new(#ff4444, 0)

// ============================================================
//   SIGNAL COOLDOWN TRACKER
// ============================================================

var int   cooldown_lastBar   = -999
var float cooldown_lastPrice = float(na)

// [v2.04/v2.05 fix, SUPERSEDED in v2.06] v2.04/v2.05 cached sigOk/binOk per touch bar in a
// map keyed by absolute bar index, on the theory that "cache on first encounter" would freeze
// each label's color at its own true historical moment. That's wrong: the whole EDGE EXH label
// loop runs inside `if barstate.islast`, which only executes ONCE per full calculation pass -
// not once per historical bar as the script walks through history. On a fresh load/reload,
// every pre-existing historical bar's "first encounter" happens in that SAME single pass, using
// TODAY's live gate/cooldown/dead-time state for all of them at once - exactly the bug this was
// meant to fix, just hidden behind a cache instead of removed. (Confirmed broken via an
// identical bug report on the sibling VolumeEdgeProFlow script, "seems not fixed for flow",
// which uses the same pattern.)
//
// v2.06 fix: no caching at all. sigOk is recomputed per touch bar `b` using genuine continuous
// per-bar series offset by Pine's `[]` operator - gateOpen[b], onCooldown[b], inDeadTimeAt(b) -
// which are valid because gateOpen/onCooldown are computed unconditionally on every bar (not
// just inside this block), so `[b]` reliably recovers bar b's own true state. binOk is
// recomputed per touch bar via calcProfile(): for the still-open session (pNum==0) the window's
// near edge keeps sliding forward every bar, so it's rebuilt as calcProfile(s, b) (same `s`,
// substituting the touch bar for "today"); for already-closed sessions (pNum>=1) the window's
// boundaries are fixed absolute bar indices set once at the session boundary, so the existing
// `tVols` from the outer calcProfile(s, e) call is already correct and reused directly.

cooldownActive() =>
    if not enableCooldown
        false
    else if na(cooldown_lastPrice)
        false
    else
        bool barsStillCooling = (bar_index - cooldown_lastBar) < cooldownBars
        bool distStillCooling = math.abs(close - cooldown_lastPrice) < (atrValRaw * cooldownAtrMult)
        barsStillCooling or distStillCooling

bool  onCooldown    = cooldownActive()
int   barsRemaining = math.max(0, cooldownBars - (bar_index - cooldown_lastBar))
float distRemaining = na(cooldown_lastPrice) ? 0.0 : math.max(0.0, (atrValRaw * cooldownAtrMult) - math.abs(close - cooldown_lastPrice)) / (syminfo.mintick * 10)

string cooldownStr = not enableCooldown ? "DISABLED" : na(cooldown_lastPrice) ? "CLEAR ✔" : onCooldown ? str.tostring(barsRemaining) + "b / " + str.tostring(distRemaining, "#.#") + "p left" : "CLEAR ✔"
color  cooldownCol = not enableCooldown ? color.gray : na(cooldown_lastPrice) ? color.new(#00ff00, 0) : onCooldown ? color.new(#ffcc00, 0) : color.new(#00ff00, 0)

// ============================================================
//   HTF ALERT LOGIC
// ============================================================

volOk = not useVolFilter or (atrPips >= minAtrPips)

htf_cross_up   = ta.crossover(close,  htf_vhP)
htf_cross_down = ta.crossunder(close, htf_vlP)

var string htf_alert_txt = "WAITING..."
var color  htf_alert_col = color.new(#808080, 0)

if htf_cross_up
    htf_alert_txt := "BULLISH BREAKOUT 🚀"
    htf_alert_col := color.new(#00ff00, 0)
if htf_cross_down
    htf_alert_txt := "BEARISH BREAKDOWN 📉"
    htf_alert_col := color.new(#ff0000, 0)

// ============================================================
//   DASHBOARD ZONE LOGIC
// ============================================================

float avoidHigh = p0 + bs0
float avoidLow  = p0 - bs0
bool inStrongBuy  = close > vh0
bool inPotBuy     = close > avoidHigh and close <= vh0
bool inNeutral    = close >= avoidLow  and close <= avoidHigh
bool inPotSell    = close < avoidLow   and close >= vl0
bool inStrongSell = close < vl0

string activeSigLbl = "AVOID ZONE"
string activeSigVal = ""
color  activeSigCol = color.gray

if inStrongBuy
    activeSigLbl := "STRONG BUY"
    activeSigVal := "> " + str.format("{0,number,#.##}", vh0)
    activeSigCol := color.new(#00ff00, 0)
else if inPotBuy
    activeSigLbl := "POTENTIAL BUY"
    activeSigVal := "> " + str.format("{0,number,#.##}", avoidHigh)
    activeSigCol := color.new(#adff2f, 0)
else if inNeutral
    activeSigLbl := "AVOID ZONE"
    activeSigVal := str.format("{0,number,#.##}", avoidLow) + "-" + str.format("{0,number,#.##}", avoidHigh)
    activeSigCol := color.new(#00ffff, 0)
else if inPotSell
    activeSigLbl := "POTENTIAL SELL"
    activeSigVal := "< " + str.format("{0,number,#.##}", avoidLow)
    activeSigCol := color.new(#ffa500, 0)
else if inStrongSell
    activeSigLbl := "STRONG SELL"
    activeSigVal := "< " + str.format("{0,number,#.##}", vl0)
    activeSigCol := color.new(#ff0000, 0)


// ============================================================
//   D1 DIRECTION DASHBOARD DATA
// ============================================================

[d1_poc, d1_vah, d1_val, d1_avgVol, d1_high, d1_low, d1_maxV, d1_tv, d1_bv, d1_bs] = request.security(syminfo.tickerid, "D", calcProfile(effectiveLookback - 1, 0))
[_d1_plus, _d1_minus, d1_adx] = request.security(syminfo.tickerid, "D", ta.dmi(14, 14))

float d1_vaRange     = d1_vah - d1_val
float d1_longLeanTh  = d1_poc + d1_vaRange * 0.30
float d1_shortLeanTh = d1_poc - d1_vaRange * 0.30
float d1_distPips    = (close - d1_poc) / (syminfo.mintick * 10)

string d1_biasStr = close > d1_vah ? "LONG ⬆" : close < d1_val ? "SHORT ⬇" : close > d1_longLeanTh ? "LONG LEAN ↗" : close < d1_shortLeanTh ? "SHORT LEAN ↘" : "NEUTRAL →"
color  d1_biasCol = str.contains(d1_biasStr, "LONG") ? color.new(#00ff00, 0) : str.contains(d1_biasStr, "SHORT") ? color.new(#ff4444, 0) : color.new(#ffcc00, 0)
string d1_zoneStr = close > d1_vah ? "ABOVE VAH" : close < d1_val ? "BELOW VAL" : "INSIDE VA"
color  d1_zoneCol = close > d1_vah ? color.new(#00ff00, 0) : close < d1_val ? color.new(#ff4444, 0) : color.new(#ffcc00, 0)
string d1_adxStr  = d1_adx > 25 ? "TRENDING 📈" : d1_adx > 20 ? "WEAK ⚠️" : "RANGING 😴"
color  d1_adxCol  = d1_adx > 25 ? color.new(#00ff00, 0) : d1_adx > 20 ? color.new(#ff8800, 0) : color.gray
string d1_distStr = d1_distPips >= 0 ? "+" + str.tostring(d1_distPips, "#.#") + " pips" : str.tostring(d1_distPips, "#.#") + " pips"
color  d1_distCol = d1_distPips > 0 ? color.new(#00ff00, 0) : d1_distPips < 0 ? color.new(#ff4444, 0) : color.new(#ffcc00, 0)

// D1 strict bias flip tracking
string d1_strictBias   = close > d1_vah ? "LONG" : close < d1_val ? "SHORT" : "NEUTRAL"
string d1_prevStrict   = d1_strictBias[1]
bool   d1_flipOccurred = d1_strictBias != d1_prevStrict and not na(d1_prevStrict)

var string d1_flip1_from  = "—"
var string d1_flip1_to    = "—"
var float  d1_flip1_price = float(na)
var string d1_flip2_from  = "—"
var string d1_flip2_to    = "—"
var float  d1_flip2_price = float(na)

if d1_flipOccurred and barstate.isconfirmed
    d1_flip2_from  := d1_flip1_from
    d1_flip2_to    := d1_flip1_to
    d1_flip2_price := d1_flip1_price
    d1_flip1_from  := d1_prevStrict
    d1_flip1_to    := d1_strictBias
    d1_flip1_price := close

string d1_flip1_str = d1_flip1_from == "—" ? "none yet" : d1_flip1_from + "→" + d1_flip1_to + "  @" + str.tostring(d1_flip1_price, format.mintick)
string d1_flip2_str = d1_flip2_from == "—" ? "—" : d1_flip2_from + "→" + d1_flip2_to + "  @" + str.tostring(d1_flip2_price, format.mintick)
color  d1_flip1_col = d1_flip1_to == "LONG" ? color.new(#00ff00, 0) : d1_flip1_to == "SHORT" ? color.new(#ff4444, 0) : color.new(#ffcc00, 0)
color  d1_flip2_col = d1_flip2_to == "LONG" ? color.new(#00ff00, 0) : d1_flip2_to == "SHORT" ? color.new(#ff4444, 0) : color.gray

// D1 POC strength
float  d1_pocStrengthRatio = 0.0
string d1_pocStr           = "WEAK"
color  d1_pocCol           = color.new(#ffcc00, 0)

if not na(d1_maxV) and d1_maxV > 0
    float d1_secondMax = 0.0
    if array.size(d1_tv) > 1
        for i = 0 to array.size(d1_tv) - 1
            float v = array.get(d1_tv, i)
            if v < d1_maxV and v > d1_secondMax
                d1_secondMax := v
    d1_pocStrengthRatio := d1_secondMax > 0 ? d1_maxV / d1_secondMax : 0.0
    d1_pocStr := d1_pocStrengthRatio >= 2.0 ? "STRONG ★" : "WEAK"
    d1_pocCol  := d1_pocStrengthRatio >= 2.0 ? color.new(#00ff00, 0) : color.new(#ffcc00, 0)

// ============================================================
//   PEP - POSSIBLE ENTRY POINT
// ============================================================

bool d1Long  = str.contains(d1_biasStr, "LONG")
bool d1Short = str.contains(d1_biasStr, "SHORT")
bool d1Neut  = not d1Long and not d1Short
bool zoneBull = inStrongBuy or inPotBuy
bool zoneBear = inStrongSell or inPotSell
bool trending = adxValue > 25

string pepStr = ""
color  pepCol = color.gray

if not gateOpen
    pepStr := "WAIT - GATE CLOSED"
    pepCol := color.gray
else if zoneBull and d1Long
    pepStr := "LONG" + (trending ? " - TRENDING" : " - RANGE")
    pepCol := color.new(#00ff00, 0)
else if zoneBear and d1Short
    pepStr := "SHORT" + (trending ? " - TRENDING" : " - RANGE")
    pepCol := color.new(#ff4444, 0)
else if zoneBull and d1Neut
    pepStr := "LEAN LONG - D1 NEUTRAL"
    pepCol := color.new(#ffcc00, 0)
else if zoneBear and d1Neut
    pepStr := "LEAN SHORT - D1 NEUTRAL"
    pepCol := color.new(#ffcc00, 0)
else if (zoneBull and d1Short) or (zoneBear and d1Long)
    pepStr := "CONFLICT - SKIP"
    pepCol := color.new(#ff4444, 0)
else
    pepStr := "NEUTRAL - INSIDE VA"
    pepCol := color.new(#00ffff, 0)


// ============================================================
//   DRAWING ENGINE
// ============================================================

if barstate.islast
    clearAll()
    if array.size(volLabels) > 0
        for i = 0 to array.size(volLabels) - 1
            label.delete(array.get(volLabels, i))
        array.clear(volLabels)

    for pNum = 0 to numSessions - 1
        [pValid, s, e] = getSessionOffsets(pNum)
        if pValid
            [pP, vhP, vlP, avgV, h, l, maxV_seg, tVols, bVols, bSize] = calcProfile(s, e)
            int boundaryScanN = math.max(3, int(priceBins * boundaryScanPct / 100.0))
            // Computed once per profile - the TRUE consecutive run from each edge, matching exactly
            // what the detection logic counts. Only bins within these counts get labeled EMPTY below,
            // not any zero bin found anywhere in the wider static scan window.
            int trueEmptyTop = countEmptyBinsFromTop(tVols, priceBins, boundaryScanN)
            int trueEmptyBot = countEmptyBinsFromBot(tVols, boundaryScanN)

            // Profile bars
            // v1.4 (this port): calcWidth now uses THIS session's own actual span (s - e + 1),
            // not the global effectiveLookback - that variable only ever represents the LIVE
            // session's (pNum=0) length, so a historical session (pNum>=1) with a genuinely
            // different length was having its box widths scaled against the wrong reference,
            // making them disproportionate whenever Number of Sessions > 1 and session
            // lengths actually differed.
            int thisSessionSpan = s - e + 1
            for i = 0 to priceBins
                float rowV    = array.get(tVols, i)
                float calcWidth = maxV_seg > 0 ? (rowV / maxV_seg) * (thisSessionSpan * widthFactor) : 0
                int   wBars   = int(math.max(2, calcWidth))
                color baseCol = rowV < (maxV_seg * 0.15) ? exhBarColor : (array.get(bVols, i) >= (rowV - array.get(bVols, i)) ? bullColor : bearColor)
                array.push(allBoxes, box.new(bar_index[e + wBars], l + (i * bSize) + bSize, bar_index[e], l + (i * bSize), border_color=color.new(#ffffff, 100), bgcolor=color.new(baseCol, 100 - profOpacity)))

                if pNum == 0 and showVolLabels and rowV > 0
                    float binBull  = array.get(bVols, i)
                    float binBear  = rowV - binBull
                    string stratTag = rowV > maxV_seg * 0.85 ? " [HVN]" : (binBull > binBear and binBear > (rowV * 0.45)) or (binBear > binBull and binBull > (rowV * 0.45)) ? " [ABS]" : binBull > binBear * 3 or binBear > binBull * 3 ? " [IMB]" : rowV < maxV_seg * 0.15 ? " [EXH]" : ""
                    string volTxt  = str.tostring(binBull, "#.#") + " / " + str.tostring(binBear, "#.#") + stratTag
                    color  textCol = rowV < (maxV_seg * 0.15) ? volLabelExhCol : (binBull >= binBear ? volLabelBullCol : volLabelBearCol)
                    array.push(volLabels, label.new(bar_index[e], l + (i * bSize) + (bSize / 2), volTxt, color=color.new(color.black, 100), textcolor=textCol, style=label.style_label_left, size=volLabelSize))
                else if showVolLabels and rowV == 0.0 and (i >= priceBins - trueEmptyTop or i < trueEmptyBot)
                    // [v2.1 parity fix] EMPTY now draws on every profile, not just pNum == 0 - the
                    // same real bug confirmed and fixed on the cTrader indicator (v2.11): the
                    // consecutive-empty-bin count itself was always computed correctly per profile,
                    // but the label only ever rendered for the live one, so every historical
                    // profile's empty boundary showed nothing at all even with labels on. The buy/
                    // sell volume-number branch above stays pNum == 0 only, deliberately - showing
                    // those on every profile would clutter badly at 7+ profiles the way EMPTY alone
                    // does not. Pine draws this at the profile's own end index already (bar_index[e]),
                    // so there's no equivalent to the separate v2.12 position-drift fix needed here -
                    // that bug was specific to cTrader's "+8 bars past end" placement, which this
                    // script never used in the first place.
                    array.push(volLabels, label.new(bar_index[e], l + (i * bSize) + (bSize / 2), "EMPTY", color=color.new(color.black, 100), textcolor=color.new(#ffcc00, 0), style=label.style_label_left, size=volLabelSize))

            // Signal labels - EDGE EXH only, matching VEPS's feature set (VA TRAP/POC/REJECTION
            // removed from this port)
            bool fEES=false, bool fEEB=false

            for b = e to s
                float ep      = close[b]
                int   absBar  = bar_index[b]
                // [v2.06 fix] sigOk recomputed per touch bar from genuine continuous series -
                // gateOpen[b]/onCooldown[b] are valid offsets because both are computed
                // unconditionally on every bar, outside this islast block, so gateOpen[b] is
                // bar b's own true historical gate state, not today's. See the fix note at
                // this file's former sigOkCache declaration (DRAWING ENGINE section intro).
                bool sigOk = gateOpen[b] and (not onCooldown[b] or not enableCooldown) and not inDeadTimeAt(b)

                if showEdgeExh
                    // [v2.06 fix] binOk is recomputed per touch bar rather than cached, and
                    // only inside each touch branch below (not unconditionally every bar in
                    // this loop) to keep the recompute cost limited to bars that actually
                    // register a wick-touch.
                    // pNum == 0 (the still-open session): the profile's near edge keeps
                    // sliding forward every bar, so tVols (computed above from calcProfile(s,
                    // e) = calcProfile(s, 0), i.e. "today") is NOT what the profile looked like
                    // when bar b was itself the newest bar. Rebuild it as calcProfile(s, b) -
                    // same `s` (distance to the fixed session start), substituting b for the
                    // live/near edge.
                    // pNum >= 1 (already-closed sessions): s/e here are already fixed absolute
                    // bar ranges (from sessionStartBars, set once at the real session boundary),
                    // so tVols never drifts - reuse it directly, no recompute needed.
                    // v1.9 fix: the empty-bin check used to sit in the outer condition, so a
                    // touch with too few empty bins produced NO label at all (not even gray) -
                    // that whole block reason was invisible on chart. Now the wick-touch alone
                    // gates entry, binOk is evaluated same as sigOk, and EITHER failing shows
                    // the gray/paused label - matching the cTrader Session indicator (v1.23),
                    // where "not enough empty bins" is one of several reasons a signal still
                    // gets a gray label instead of none.
                    if not fEES and high[b] >= (h - syminfo.mintick * 5) and close[b] < h
                        array<float> tVolsTop = tVols
                        if pNum == 0
                            [_pP2,_vh2,_vl2,_av2,_h2,_l2,_mx2, tVolsB1, _bv2,_bs2] = calcProfile(s, b)
                            tVolsTop := tVolsB1
                        int binsTopHere = countEmptyBinsFromTop(tVolsTop, priceBins, boundaryScanN)
                        bool binOkTop = binsTopHere >= minEmptyBinsHigh
                        if binOkTop and sigOk
                            array.push(allLabels, label.new(bar_index[b], high[b], "EDGE EXH (SELL)" + getRiskLabel(false, ep), color=color.new(bearSigCol, 80), textcolor=bearSigCol, style=label.style_label_down, size=size.small))
                            cooldown_lastBar := bar_index - b
                            cooldown_lastPrice := ep
                        else
                            array.push(allLabels, label.new(bar_index[b], high[b], "EDGE EXH (SELL) ⏸", color=color.new(color.gray, 80), textcolor=color.gray, style=label.style_label_down, size=size.small))
                        fEES := true
                    if not fEEB and low[b] <= (l + syminfo.mintick * 5) and close[b] > l
                        array<float> tVolsBot = tVols
                        if pNum == 0
                            [_pP3,_vh3,_vl3,_av3,_h3,_l3,_mx3, tVolsB2, _bv3,_bs3] = calcProfile(s, b)
                            tVolsBot := tVolsB2
                        int binsBotHere = countEmptyBinsFromBot(tVolsBot, boundaryScanN)
                        bool binOkBot = binsBotHere >= minEmptyBinsLow
                        if binOkBot and sigOk
                            array.push(allLabels, label.new(bar_index[b], low[b], "EDGE EXH (BUY)" + getRiskLabel(true, ep), color=color.new(bullSigCol, 80), textcolor=bullSigCol, style=label.style_label_up, size=size.small))
                            cooldown_lastBar := bar_index - b
                            cooldown_lastPrice := ep
                        else
                            array.push(allLabels, label.new(bar_index[b], low[b], "EDGE EXH (BUY) ⏸", color=color.new(color.gray, 80), textcolor=color.gray, style=label.style_label_up, size=size.small))
                        fEEB := true

            // Boundary lines
            profileLineStyle = getStyle(boundStyle)
            array.push(allLines, line.new(bar_index[s], h, bar_index[e], h, color=boundColor, width=boundWidth, style=profileLineStyle))
            array.push(allLines, line.new(bar_index[s], l, bar_index[e], l, color=boundColor, width=boundWidth, style=profileLineStyle))
            array.push(allLines, line.new(bar_index[e], h, bar_index[e], l, color=boundColor, width=boundWidth, style=profileLineStyle))
            if showLabels
                array.push(allLabels, label.new(bar_index[e], h, "H: " + str.tostring(h, "#.##"), color=color.new(#000000, 100), textcolor=boundColor, style=label.style_label_lower_right, size=size.small))
                array.push(allLabels, label.new(bar_index[e], l, "L: " + str.tostring(l, "#.##"), color=color.new(#000000, 100), textcolor=boundColor, style=label.style_label_upper_right, size=size.small))
            array.push(allLines, line.new(bar_index[s], pP,  bar_index[e], pP,  color=pocColor, width=pocWidth, style=getStyle(pocStyleStr)))
            array.push(allLines, line.new(bar_index[s], vhP, bar_index[e], vhP, color=vahColor, width=vahWidth, style=getStyle(vahStyleStr)))
            array.push(allLines, line.new(bar_index[s], vlP, bar_index[e], vlP, color=valColor, width=valWidth, style=getStyle(valStyleStr)))

            // v1.6 (this port): PC line/label moved INSIDE this per-session loop, on direct
            // request - it used to be drawn once, outside this loop, always for the LIVE
            // session only (pdcValue), regardless of how many historical sessions
            // Number of Sessions was also showing. Each session has its OWN previous-period
            // close, not the live session's one value. Computed from data already available:
            // the bar right before THIS session's own start (offset s+1) is, by definition,
            // the immediately preceding session's own close - no extra request.security call
            // needed. pdcValue itself (used by the PC Cross Alert watch, the dashboard PC
            // row) is untouched - those are specifically about the LIVE session's own
            // reference level, not historical ones, so they correctly keep using it.
            if showPdcLine and not na(close[s + 1])
                float sessionPc = close[s + 1]
                bool  sessionPcAbove = pNum == 0 ? pdcAbove : close[e] > sessionPc
                array.push(allLines, line.new(bar_index[s], sessionPc, bar_index[e], sessionPc, color=pdcColor, width=pdcWidth, style=getStyle(pdcStyleStr)))
                array.push(allLabels, label.new(bar_index[e], sessionPc, "PC " + str.tostring(sessionPc, format.mintick) + (sessionPcAbove ? " ABOVE" : " BELOW"), color=color.new(color.black, 100), textcolor=pdcColor, style=label.style_label_left, size=size.small))

// ============================================================
//   D1 DIRECTION DASHBOARD
// ============================================================
// [v2.07] ported verbatim from VEPF for parity - the underlying d1_* data was already being
// computed above (D1 DIRECTION DASHBOARD DATA section); this just adds the panel that was
// never drawn for it.

if barstate.islast and showD1Dash
    var table d1dash = table.new(d1FinalPos, 2, 15, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(#444444, 0))

    table.cell(d1dash, 0, 0, "D1 DIRECTION DASHBOARD", text_color=color.new(#ffcc00,0), text_size=d1SizeConst, bgcolor=color.new(color.black, 70))
    table.merge_cells(d1dash, 0, 0, 1, 0)

    table.cell(d1dash, 0, 1, "BIAS",     text_color=color.white, text_size=d1SizeConst)
    table.cell(d1dash, 1, 1, d1_biasStr, text_color=d1_biasCol,  text_size=d1SizeConst)

    table.cell(d1dash, 0, 2, "ZONE",     text_color=color.white, text_size=d1SizeConst)
    table.cell(d1dash, 1, 2, d1_zoneStr, text_color=d1_zoneCol,  text_size=d1SizeConst)

    table.cell(d1dash, 0, 3, "D1 POC",   text_color=color.new(#ffcc00,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 3, str.tostring(d1_poc, format.mintick), text_color=color.new(#ffcc00,0), text_size=d1SizeConst)

    table.cell(d1dash, 0, 4, "vs POC",   text_color=color.white, text_size=d1SizeConst)
    table.cell(d1dash, 1, 4, d1_distStr, text_color=d1_distCol,  text_size=d1SizeConst)

    table.cell(d1dash, 0, 5, "D1 VAH",   text_color=color.new(#00ff00,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 5, str.tostring(d1_vah, format.mintick), text_color=color.new(#00ff00,0), text_size=d1SizeConst)

    table.cell(d1dash, 0, 6, "D1 VAL",   text_color=color.new(#ff4444,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 6, str.tostring(d1_val, format.mintick), text_color=color.new(#ff4444,0), text_size=d1SizeConst)

    table.cell(d1dash, 0, 7, "VA WIDTH",  text_color=color.white, text_size=d1SizeConst)
    table.cell(d1dash, 1, 7, str.tostring(d1_vaRange / (syminfo.mintick * 10), "#.#") + " pips", text_color=color.white, text_size=d1SizeConst)

    table.cell(d1dash, 0, 8, "D1 ADX",   text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 8, str.tostring(d1_adx, "#.##") + "  " + d1_adxStr, text_color=d1_adxCol, text_size=d1SizeConst)

    table.cell(d1dash, 0, 9, "POC NODE", text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 9, d1_pocStr + "  (" + str.tostring(d1_pocStrengthRatio, "#.##") + "x)", text_color=d1_pocCol, text_size=d1SizeConst)

    table.cell(d1dash, 0, 10, "── FLIP HISTORY ──", text_color=color.new(#666666,0), text_size=d1SizeConst)
    table.merge_cells(d1dash, 0, 10, 1, 10)

    table.cell(d1dash, 0, 11, "LAST FLIP", text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 11, d1_flip1_str, text_color=d1_flip1_col, text_size=d1SizeConst)

    table.cell(d1dash, 0, 12, "PREV FLIP", text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 12, d1_flip2_str, text_color=d1_flip2_col, text_size=d1SizeConst)

    table.cell(d1dash, 0, 13, "D1 HIGH",  text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 13, str.tostring(d1_high, format.mintick), text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)

    table.cell(d1dash, 0, 14, "D1 LOW",   text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)
    table.cell(d1dash, 1, 14, str.tostring(d1_low, format.mintick), text_color=color.new(#aaaaaa,0), text_size=d1SizeConst)

// ============================================================
//   PC CROSS ALERT - TIER 3 WATCH STATE MACHINE  [generalized from PDC in this port]
// ============================================================
// Mirrors the Sniper cBot exactly: EDGE EXH fires -> arm a watch -> wait up to
// pdcAlertExpiryBars candles for price to close back across PDC -> fire a SEPARATE,
// later alert. This is deliberately a different, more conservative signal than the
// general EDGE EXH alert below, which fires immediately on the raw pattern alone.

var bool   pdcWatchActive      = false
var string pdcWatchDirection   = ""
var int    pdcWatchArmedBar    = na
var float  pdcWatchStructuralSl = na
var int    pdcWatchEmptyBins   = 0
// [v2.02 fix] last signal bar that armed a watch, per direction - without this, the backward
// scan below re-finds the SAME old EDGE EXH signal bar every single bar once price is already
// past PC (the scan re-evaluates it against the CURRENT live profile, which keeps matching),
// re-arming and immediately re-firing the alert bar after bar with the same signal, drifting
// entry/buffer only because ATR keeps moving. Mirrors the cBot's own fix
// (_pcLastArmedSignalTimeBuy/Sell) - a given signal bar may arm a watch at most once per
// direction. Genuinely new signal bars are unaffected.
var int    pdcLastArmedBarBuy  = na
var int    pdcLastArmedBarSell = na

// v1.1 (this port): relocated here from Tier 2's own section further down - the dashboard
// block reads these, and Pine doesn't allow referencing a variable before its declaration
// point, so they need to live before the dashboard even though the logic that UPDATES them
// still runs later, in Tier 2's own section (see MA WATCH row's own dashboard comment for
// the one-bar-lag trade-off this creates).
var bool   maWatchActive    = false
var string maWatchDirection = ""
var int    maWatchArmedBar  = na
// [NEW] frozen at arm time (signal bar), same pattern as pdcWatchStructuralSl/pdcWatchEmptyBins
// above - lets the forward MA confirmation below report Entry/SL/TP/Empty Bins the same way
// Tier 3 does, instead of the bare confirmation line it used to send. Reuses PC Alert SL
// Buffer (x ATR) (pdcAlertSlBufferAtr) rather than adding a dedicated MA SL buffer input -
// same shared-buffer convention Tier 1 already uses.
var float  maWatchStructuralSl = na
var int    maWatchEmptyBins    = 0

if barstate.isconfirmed
    if pdcWatchActive
        int barsSinceWatch = bar_index - pdcWatchArmedBar
        if barsSinceWatch > pdcAlertExpiryBars
            pdcWatchActive := false
        else
            // [v2.1 parity fix] the cross now requires closing past PDC ± Entry Buffer, not
            // bare PDC - matches the confirmed fix on both the cTrader indicator (v2.14) and
            // VEPS (v2.31). Real effect: this alert now fires later and less often than
            // before, but the entry it reports is the real level, not one a moment earlier.
            float entryBufferDistPdc = atrValRaw * pdcAlertEntryBufferAtr
            float crossTriggerLevel  = pdcWatchDirection == "BUY" ? pdcValue + entryBufferDistPdc : pdcValue - entryBufferDistPdc
            bool crossedForEntry = pdcWatchDirection == "BUY" ? close >= crossTriggerLevel : close <= crossTriggerLevel
            if crossedForEntry
                float entryPrice = crossTriggerLevel
                float slPrice    = pdcWatchStructuralSl
                float riskDistPdc = math.abs(entryPrice - slPrice)
                float tpPrice    = pdcWatchDirection == "BUY" ? entryPrice + riskDistPdc * rrRatio : entryPrice - riskDistPdc * rrRatio
                if enableAlerts and enablePdcCrossAlert and isAlertTimeAllowed()
                    string timeStringPdc = str.format_time(timenow, "yyyy-MM-dd'T'HH:mm:ss", "UTC") + "Z"
                    int    discColPdc    = pdcWatchDirection == "BUY" ? 2329344 : 14427675
                    string titlePdc      = "TIER 3 | " + (pdcWatchDirection == "BUY" ? "🟢 " : "🔴 ") + "PC CROSS " + pdcWatchDirection + "  —  " + syminfo.ticker + " (" + timeframe.period + ") | Session Profile"
                    // [v2.1 parity fix - matches indicator v2.15] Entry line now shows the raw
                    // PC value and buffer distance alongside the final entry price, so the
                    // buffer is directly verifiable from the alert itself.
                    string bufferSignPdc      = pdcWatchDirection == "BUY" ? "+" : "-"
                    string entryBufferPipsStr = str.tostring(entryBufferDistPdc / (syminfo.mintick * 10), "#.#")
                    string descPdc       = "EDGE EXH " + pdcWatchDirection + " confirmed — price crossed PC after " + str.tostring(barsSinceWatch) + " candle(s).\\n" + "Empty Bins: " + str.tostring(pdcWatchEmptyBins) + " (required: " + str.tostring(pdcWatchDirection == "BUY" ? minEmptyBinsLow : minEmptyBinsHigh) + ")\\n" + "🎬 Entry: " + str.tostring(entryPrice, format.mintick) + "  (PC " + str.tostring(pdcValue, format.mintick) + " " + bufferSignPdc + " " + entryBufferPipsStr + "p buffer)" + "\\n🛡️ SL: " + str.tostring(slPrice, format.mintick) + "\\n🎯 TP: " + str.tostring(tpPrice, format.mintick)
                    string jsonPdc       = buildAlertJson(titlePdc, descPdc, discColPdc, timeStringPdc)
                    alert(jsonPdc, alert.freq_once_per_bar_close)
                pdcWatchActive := false

    if not pdcWatchActive and not inDeadTime()
        // Backward scan within the expiry window for a fresh EDGE EXH, same approach as
        // the cBot's own Stage 1 - only arms on the most recent matching bar, and only if
        // price is still on the correct side of PDC for that direction to make sense.
        int scanBackTo = math.max(0, bar_index - pdcAlertExpiryBars)
        bool foundBuy = false
        bool foundSell = false
        int  foundBarIdx = na
        float foundClose = na
        int  foundEmptyBins = 0

        for bb = bar_index to scanBackTo
            int offsetBb = bar_index - bb
            bool isExhBb = array.get(tv0, math.min(priceBins, int((close[offsetBb] - l0) / bs0))) < (max0 * 0.25)
            int binsTopBb = countEmptyBinsFromTop(tv0, priceBins, boundaryScanN0)
            int binsBotBb = countEmptyBinsFromBot(tv0, boundaryScanN0)
            bool sellHereBb = high[offsetBb] >= (h0 - syminfo.mintick * 5) and close[offsetBb] < h0 and binsTopBb >= minEmptyBinsHigh
            bool buyHereBb  = low[offsetBb]  <= (l0 + syminfo.mintick * 5) and close[offsetBb] > l0  and binsBotBb >= minEmptyBinsLow
            if buyHereBb
                foundBuy := true
                foundBarIdx := bb
                foundClose := close[offsetBb]
                foundEmptyBins := binsBotBb
                break
            if sellHereBb
                foundSell := true
                foundBarIdx := bb
                foundClose := close[offsetBb]
                foundEmptyBins := binsTopBb
                break

        if foundBuy and foundClose < pdcValue and foundBarIdx != pdcLastArmedBarBuy
            pdcWatchActive := true
            pdcWatchDirection := "BUY"
            pdcWatchArmedBar := foundBarIdx
            pdcWatchStructuralSl := l0 - (atrValRaw * pdcAlertSlBufferAtr)
            pdcWatchEmptyBins := foundEmptyBins
            pdcLastArmedBarBuy := foundBarIdx
        else if foundSell and foundClose > pdcValue and foundBarIdx != pdcLastArmedBarSell
            pdcWatchActive := true
            pdcWatchDirection := "SELL"
            pdcWatchArmedBar := foundBarIdx
            pdcWatchStructuralSl := h0 + (atrValRaw * pdcAlertSlBufferAtr)
            pdcWatchEmptyBins := foundEmptyBins
            pdcLastArmedBarSell := foundBarIdx

// ============================================================
//   MAIN DASHBOARD HUD
// ============================================================

if barstate.islast and showDash
    var table dash = table.new(finalPos, 2, 14, bgcolor=color.new(color.black, 100), border_width=1, border_color=color.new(#808080, 0))

    table.cell(dash, 0, 0, "VolumeEdge PRO " + SCRIPT_VERSION, text_color=color.new(#ffcc00,0), text_size=sizeConst)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1: PEP
    table.cell(dash, 0, 1, "PEP",    text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 1, pepStr,   text_color=pepCol, text_size=sizeConst)

    // Row 2: HTF merged (status - alert)
    string htf_status = htfTF == "Invalid" ? "N/A" : close > htf_vhP ? "STR BULLISH 📈" : close < htf_vlP ? "STR BEARISH 📉" : "NEUTRAL"
    color  htf_status_col = htf_status == "STR BULLISH 📈" ? color.new(#00ff00,0) : htf_status == "STR BEARISH 📉" ? color.new(#ff0000,0) : color.new(#00ffff,0)
    string htf_merged = htf_status + (htf_alert_txt != "WAITING..." ? "  -  " + htf_alert_txt : "")
    table.cell(dash, 0, 2, "HTF (" + htfTF + ")", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 2, htf_merged, text_color=htf_status_col, text_size=sizeConst)

    // Row 3: ADX inline (trend + number)
    string adxMerged = trendStrength + "  (" + str.format("{0,number,#.#}", adxValue) + ")"
    table.cell(dash, 0, 3, "ADX TREND",  text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 3, adxMerged,    text_color=trendColor, text_size=sizeConst)

    // Row 4: Market Mode
    table.cell(dash, 0, 4, "MARKET MODE", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 4, marketPhase,   text_color=phaseColor, text_size=sizeConst)

    // Row 5: Active Zone
    table.cell(dash, 0, 5, activeSigLbl, text_color=activeSigCol, text_size=sizeConst)
    table.cell(dash, 1, 5, activeSigVal, text_color=activeSigCol, text_size=sizeConst)

    // Row 6: Volatility
    table.cell(dash, 0, 6, "VOLATILITY", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 6, volOk ? "ACTIVE 🔥" : "LOW ❌", text_color=volOk ? color.new(#00ff00,0) : color.new(#ff0000,0), text_size=sizeConst)

    // Row 7: Signal Gate
    table.cell(dash, 0, 7, "SIGNAL GATE", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 7, gateStatusStr, text_color=gateStatusCol, text_size=sizeConst)

    // Row 8: Confluence
    table.cell(dash, 0, 8, "CONFLUENCE", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 8, confluenceStr, text_color=confluenceCol, text_size=sizeConst)

    // Row 9: Cooldown
    table.cell(dash, 0, 9, "COOLDOWN",  text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 9, cooldownStr, text_color=cooldownCol, text_size=sizeConst)

    // Row 10: PDC [NEW v2.0]
    table.cell(dash, 0, 10, "PC", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 10, str.tostring(pdcValue, format.mintick) + (pdcAbove ? " ABOVE" : " BELOW"), text_color=pdcAbove ? color.new(#00ff00,0) : color.new(#ff4444,0), text_size=sizeConst)

    // Row 11: PDC Watch [NEW v2.0]
    // v1.16: appends " (Active)"/" (Not Active)" to an armed watch, reflecting live
    // enableAlerts state - matches the C# side's own v1.17 dashboard tweak. Omitted for
    // "None", same as the C# side - not meaningful when nothing's armed anyway.
    string watchStr = pdcWatchActive ? pdcWatchDirection + " " + str.tostring(math.max(0, pdcAlertExpiryBars - (bar_index - pdcWatchArmedBar))) + "/" + str.tostring(pdcAlertExpiryBars) + (enableAlerts ? " (Active)" : " (Not Active)") : "None"
    color  watchCol = pdcWatchActive ? (pdcWatchDirection == "BUY" ? color.new(#00ff00,0) : color.new(#ff4444,0)) : color.gray
    table.cell(dash, 0, 11, "PC WATCH (T3)", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 11, watchStr, text_color=watchCol, text_size=sizeConst)

    // Row 12: MA Watch (T2) - added on direct request, porting the C# side's own v1.14
    // dashboard addition. One honest trade-off, disclosed rather than hidden: maWatchActive
    // is declared and updated further down the script (Tier 2's own section, after this
    // dashboard block) - Pine executes top-to-bottom once per bar, so this row shows the
    // watch state as of the END of the PREVIOUS bar, not this bar's own freshest update,
    // unlike PC WATCH (T3) above (whose own state lives earlier in the script, before this
    // block). Moving Tier 2's whole section earlier to fully match would also mean moving
    // Tier 1's trig_EdgeExh_Buy/Sell (which Tier 2's arming depends on) - a much larger,
    // riskier restructure of proven detection logic than this one-bar lag justifies.
    // v1.16: same " (Active)"/" (Not Active)" tag as PC WATCH (T3) above, reflecting live
    // enableAlerts state, matching the C# side's own v1.17 dashboard tweak.
    string maWatchStr = maWatchActive ? maWatchDirection + " " + str.tostring(math.max(0, maForwardExpiryBars - (bar_index - maWatchArmedBar))) + "/" + str.tostring(maForwardExpiryBars) + (enableAlerts ? " (Active)" : " (Not Active)") : "None"
    color  maWatchCol = maWatchActive ? (maWatchDirection == "BUY" ? color.new(#00ff00,0) : color.new(#ff4444,0)) : color.gray
    table.cell(dash, 0, 12, "MA WATCH (T2)", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 12, maWatchStr, text_color=maWatchCol, text_size=sizeConst)

    // Row 13: Lookback
    table.cell(dash, 0, 13, "LOOKBACK", text_color=color.white, text_size=sizeConst)
    table.cell(dash, 1, 13, str.tostring(effectiveLookback) + " bars", text_color=color.gray, text_size=sizeConst)

// ============================================================
//   TIER 1 - BARE EDGE EXH (immediate, same-bar)
// ============================================================
// v1.0 (this port): VA TRAP/POC/REJECTION trigger conditions and the a_isExh/a_isSpk helpers
// they depended on are removed - EDGE EXH only, matching VEPS's feature set.

bool trig_EdgeExh_Sell = high >= (h0 - syminfo.mintick * 5) and close < h0 and emptyBinsTop0 >= minEmptyBinsHigh
bool trig_EdgeExh_Buy  = low  <= (l0 + syminfo.mintick * 5) and close > l0  and emptyBinsBot0 >= minEmptyBinsLow

// Reverse-signal invalidation [v1.7] - ported from the cTrader suite's own v1.21 fix, on
// direct request: a fresh EDGE EXH in the opposite direction now silently cancels the other
// side's still-pending Tier 2 (MA) and Tier 3 (PC) watch. Deliberately decoupled from
// enableAlerts - a watch should stop counting down toward a now-contradicted signal
// regardless of whether Discord alerts happen to be switched on. Runs on every confirmed
// bar where either direction's trigger condition is true, ahead of showEdgeExh/inDeadTime -
// those gate whether THIS bar's own signal alerts, not whether it invalidates the opposite
// watch, matching the cTrader side's own placement (before the isFired/blocked branch).
if barstate.isconfirmed and (trig_EdgeExh_Buy or trig_EdgeExh_Sell)
    bool freshIsBuy = trig_EdgeExh_Buy
    if maWatchActive and maWatchDirection != (freshIsBuy ? "BUY" : "SELL")
        maWatchActive := false
    if pdcWatchActive and pdcWatchDirection != (freshIsBuy ? "BUY" : "SELL")
        pdcWatchActive := false

if (trig_EdgeExh_Buy or trig_EdgeExh_Sell) and showEdgeExh and barstate.isconfirmed and enableAlerts and not inDeadTime() and isAlertTimeAllowed()
    float  entryPrice  = close
    bool   isBuy       = trig_EdgeExh_Buy
    // Real structural SL/TP (profile boundary + ATR buffer), matching what the PC Cross
    // Alert (Tier 3) below and the actual cBot both use for the same signal.
    float  a_sl = isBuy ? l0 - (atrValRaw * pdcAlertSlBufferAtr) : h0 + (atrValRaw * pdcAlertSlBufferAtr)
    float  riskDistEdge = math.abs(entryPrice - a_sl)
    float  a_tp = isBuy ? entryPrice + riskDistEdge * rrRatio : entryPrice - riskDistEdge * rrRatio
    string timeString  = str.format_time(timenow, "yyyy-MM-dd'T'HH:mm:ss", "UTC") + "Z"
    int    discCol     = isBuy ? 2329344 : 14427675
    string cleanTitle  = "TIER 1 | " + (isBuy ? "🟢 " : "🔴 ") + "EDGE EXH (" + (isBuy ? "BUY" : "SELL") + ")  —  " + syminfo.ticker + " (" + timeframe.period + ") | Session Profile"
    string binCtx      = "Empty Bins: " + str.tostring(isBuy ? emptyBinsBot0 : emptyBinsTop0) + " (required: " + str.tostring(isBuy ? minEmptyBinsLow : minEmptyBinsHigh) + ")\\n"
    string gateCtx     = "Gate: " + gateStatusStr
    string d1Ctx       = "D1 Bias: " + d1_biasStr + "  |  D1 POC: " + str.tostring(d1_poc, format.mintick) + "  |  POC Node: " + d1_pocStr
    string flipCtx     = "Last Flip: " + d1_flip1_str
    string desc        = "🎬 **Entry:** " + str.tostring(entryPrice, format.mintick) + "\\n🎯 **PTP:** " + str.tostring(a_tp, format.mintick) + "\\n🛡️ **PSL:** " + str.tostring(a_sl, format.mintick) + "\\n" + binCtx + "\\n📊 **Market Context**\\n🎯 **PEP:** " + pepStr + "\\nATR: " + str.tostring(atrValRaw / (syminfo.mintick * 10), "#.#") + " pips  |  ADX: " + str.tostring(adxValue, "#.#") + "  " + trendStrength + "\\n" + gateCtx + "\\n" + d1Ctx + "\\n" + flipCtx
    string jsonAlert   = buildAlertJson(cleanTitle, desc, discCol, timeString)
    alert(jsonAlert, alert.freq_once_per_bar_close)

// ============================================================
//   MA CROSS ALERT - TIER 2 WATCH STATE MACHINE  [NEW in this port]
// ============================================================
// vep.pine's own MA Cross (above, in HELPERS) is purely visual - maCrossUp/maCrossDown exist
// as plotted markers only, with no alert attached. This mirrors the exact same
// watch/arm/expire pattern the PC Cross Alert (Tier 3) above already proves works: backward
// check first (a matching cross already happened recently), and if that finds nothing, a
// forward watch arms instead of the moment just passing.

getRecentMaCrossDir(int lookback) =>
    string dir = "NONE"
    for k = 0 to lookback - 1
        if maCrossUp[k]
            dir := "BUY"
            break
        if maCrossDown[k]
            dir := "SELL"
            break
    dir

// v1.1 (this port): moved out of the conditional block below per Pine's own compiler
// warning - a user-defined function containing historical-reference lookups ([]) should be
// called unconditionally every bar for consistent internal bookkeeping, not only when a
// signal happens to fire. Result is stored here and just READ conditionally below instead.
string backDirEveryBar = getRecentMaCrossDir(backwardCrossLookback)

if barstate.isconfirmed
    if maWatchActive
        int barsSinceMaWatch = bar_index - maWatchArmedBar
        if barsSinceMaWatch > maForwardExpiryBars
            maWatchActive := false
        else
            bool matchingCross = maWatchDirection == "BUY" ? maCrossUp : maCrossDown
            if matchingCross
                if enableAlerts and enableMaCrossAlert and isAlertTimeAllowed()
                    // Entry re-anchored to THIS (confirm) bar's close - the cross just
                    // happened, so this is the live price, not the stale signal-bar price.
                    // SL stays the signal bar's own structural extreme, frozen at arm time
                    // (maWatchStructuralSl), same as Tier 3's pdcWatchStructuralSl.
                    float  entryPriceMa = close
                    float  slPriceMa    = maWatchStructuralSl
                    float  riskDistMa   = math.abs(entryPriceMa - slPriceMa)
                    float  tpPriceMa    = maWatchDirection == "BUY" ? entryPriceMa + riskDistMa * rrRatio : entryPriceMa - riskDistMa * rrRatio
                    string timeStringMa = str.format_time(timenow, "yyyy-MM-dd'T'HH:mm:ss", "UTC") + "Z"
                    int    discColMa    = maWatchDirection == "BUY" ? 2329344 : 14427675
                    string titleMa      = "TIER 2 | " + (maWatchDirection == "BUY" ? "🟢 " : "🔴 ") + "MA CROSS " + maWatchDirection + " (forward)  —  " + syminfo.ticker + " (" + timeframe.period + ") | Session Profile"
                    string descMa       = "EDGE EXH " + maWatchDirection + " confirmed — MA cross (forward, " + str.tostring(barsSinceMaWatch) + "/" + str.tostring(maForwardExpiryBars) + " bar(s))." + "\\nEmpty Bins: " + str.tostring(maWatchEmptyBins) + " (required: " + str.tostring(maWatchDirection == "BUY" ? minEmptyBinsLow : minEmptyBinsHigh) + ")" + "\\n🎬 Entry: " + str.tostring(entryPriceMa, format.mintick) + "\\n🛡️ SL: " + str.tostring(slPriceMa, format.mintick) + "\\n🎯 TP: " + str.tostring(tpPriceMa, format.mintick)
                    string jsonMa       = buildAlertJson(titleMa, descMa, discColMa, timeStringMa)
                    alert(jsonMa, alert.freq_once_per_bar_close)
                maWatchActive := false

    if (trig_EdgeExh_Buy or trig_EdgeExh_Sell) and showEdgeExh and enableMaCrossAlert and not inDeadTime()
        string thisDir  = trig_EdgeExh_Buy ? "BUY" : "SELL"
        string backDir  = backDirEveryBar
        if backDir == thisDir
            if enableAlerts and isAlertTimeAllowed()
                // Backward confirm fires on the signal bar itself - Entry/SL come straight
                // from this bar's own close/profile extreme, no frozen state needed.
                bool   isBuyMaB      = thisDir == "BUY"
                float  entryPriceMaB = close
                float  slPriceMaB    = isBuyMaB ? l0 - (atrValRaw * pdcAlertSlBufferAtr) : h0 + (atrValRaw * pdcAlertSlBufferAtr)
                float  riskDistMaB   = math.abs(entryPriceMaB - slPriceMaB)
                float  tpPriceMaB    = isBuyMaB ? entryPriceMaB + riskDistMaB * rrRatio : entryPriceMaB - riskDistMaB * rrRatio
                int    emptyBinsMaB  = isBuyMaB ? emptyBinsBot0 : emptyBinsTop0
                string timeStringMaB = str.format_time(timenow, "yyyy-MM-dd'T'HH:mm:ss", "UTC") + "Z"
                int    discColMaB    = thisDir == "BUY" ? 2329344 : 14427675
                string titleMaB      = "TIER 2 | " + (thisDir == "BUY" ? "🟢 " : "🔴 ") + "MA CROSS " + thisDir + " (backward)  —  " + syminfo.ticker + " (" + timeframe.period + ") | Session Profile"
                string descMaB       = "EDGE EXH " + thisDir + " confirmed with MA cross (backward, within " + str.tostring(backwardCrossLookback) + " bar(s))." + "\\nEmpty Bins: " + str.tostring(emptyBinsMaB) + " (required: " + str.tostring(isBuyMaB ? minEmptyBinsLow : minEmptyBinsHigh) + ")" + "\\n🎬 Entry: " + str.tostring(entryPriceMaB, format.mintick) + "\\n🛡️ SL: " + str.tostring(slPriceMaB, format.mintick) + "\\n🎯 TP: " + str.tostring(tpPriceMaB, format.mintick)
                string jsonMaB       = buildAlertJson(titleMaB, descMaB, discColMaB, timeStringMaB)
                alert(jsonMaB, alert.freq_once_per_bar_close)
            maWatchActive := false
        else
            // Same "most recent signal always wins" convention as PC Watch (Tier 3) above -
            // a fresh EDGE EXH overwrites any previous, still-unresolved watch on this
            // indicator, rather than gating on "not already active".
            maWatchActive       := true
            maWatchDirection    := thisDir
            maWatchArmedBar     := bar_index
            // Frozen here (signal bar), read back by the forward confirm block above once
            // the matching cross actually happens - same freeze-at-arm pattern Tier 3 uses.
            maWatchStructuralSl := thisDir == "BUY" ? l0 - (atrValRaw * pdcAlertSlBufferAtr) : h0 + (atrValRaw * pdcAlertSlBufferAtr)
            maWatchEmptyBins    := thisDir == "BUY" ? emptyBinsBot0 : emptyBinsTop0
````
