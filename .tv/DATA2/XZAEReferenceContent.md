<!-- tradingview-pine-id: PUB;63bfe5330edf4a258e3f13a9e7130a29 -->
<!-- tradingview-pine-version: 12.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_AE_Reference_Content

Source: https://www.tradingview.com/script/Fftvo16d-XZ-AE-Reference-Content/

## Description

Library  "XZ_AE_Reference_Content"

quickReadBody()
  Full XZ AE Quick Read onboarding body.
  Returns: User-visible Quick Read text.

quickReadTitleTip()
  Quick Read title-cell hover.
  Returns: User-visible title tooltip.

quickReadBodyTip()
  Quick Read body hover.
  Returns: User-visible methodology/invariance tooltip.

glossaryCode(i)
  Compact Glossary code for a zero-based entry index.
  Parameters:
    i (int): Zero-based glossary index.
  Returns: Compact user-visible code.

glossaryTerm(i)
  Unabbreviated Glossary term for a zero-based entry index.
  Parameters:
    i (int): Zero-based glossary index.
  Returns: User-visible term.

glossaryTip(i)
  Full Glossary hover definition for a zero-based entry index.
  Parameters:
    i (int): Zero-based glossary index.
  Returns: User-visible definition.

---

## Source Code

````pine
//@version=6
// © Steel-Sovereign
// XZ AE Reference Content exposes only user-visible onboarding/glossary text.
// It contains no analytical registry, qualification, lifecycle, S&D, MS, or Range authority logic.
library("XZ_AE_Reference_Content", overlay = true)

// @function Full XZ AE Quick Read onboarding body.
// @returns User-visible Quick Read text.
export quickReadBody() =>
    "WHAT IT MAPS\nXZ AE maps source-owned auction hypotheses and validated Ranges from confirmed\nXZ structure and Swing-associated S&D. It separates analytical existence from\nwhat is currently drawn, focused or archived on the chart.\n\nSOURCE AUTHORITY\nThe selected Auction Source Timeframe owns pivots, S&D, Candidates, qualification,\nRanges and lineages within AE's 100,000-source-bar replay budget. The host chart\ntimeframe is a presentation view only within the supported Source ≥ Chart domain.\n\nCANDIDATE → RANGE\nOpposite confirmed Trend Swings form a pure T↔T Candidate (C#). That pair is a\nstructural hypothesis, not yet a Range. A Candidate becomes R# only after the selected Qualification Policy is satisfied\ncoherently.\n\nQUALIFICATION\nStructural Pair is mandatory. Pair Auction uses defended pair Price Action (PA) + pair-relative rotation.\nStructural Containment independently uses defense + a later canonical pivot rotating inside\nthe older Candidate. Policy selects Pair, Structural, Either or Both. Later pivots may still\nform new structures; they never redefine Pair Rotation.\n\nCHOP AUTHORITY\nPair Auction ignores Chop Authority. Structural Containment accepts Trend pivots always and\nChop pivots only when Integrated. Sidewalled Chop remains retained through L# research.\n\nSESSION CONTEXT\nSelected canonical sessions add bounded H-L context and per-session Status relationships.\nHover SYD/TYO/LDN/NY for occurrence timing, range activity, AE overlap/excursion and prior-same-session comparison.\n\nLIFECYCLE & AUDIT\nCandidates, validated Ranges and precautionary lineages retain their own lifecycle\nand provenance. Chart hovers report object-specific forensic facts; Quick Read\nexplains methodology, while the Glossary decodes terminology."

// @function Quick Read title-cell hover.
// @returns User-visible title tooltip.
export quickReadTitleTip() =>
    "Temporary XZ AE onboarding surface. Turn it off once Candidate formation, qualification, Range authority, Chop Authority and lifecycle are familiar. The Quick Read is informational only and never changes analytical state."

// @function Quick Read body hover.
// @returns User-visible methodology/invariance tooltip.
export quickReadBodyTip() =>
    "XZ SOURCE REGISTRY INVARIANCE: for the same symbol, Auction Source Timeframe and methodology settings, the analytical C#/R#/L# registry is identical across supported host chart timeframes. Focus, display limits, visual archive visibility, Nearest PA Geometry and table settings never create, delete, validate or otherwise redefine analytical objects or lifecycle."

// @function Compact Glossary code for a zero-based entry index.
// @param i Zero-based glossary index.
// @returns Compact user-visible code.
export glossaryCode(int i) =>
    switch i
        0 => "AE"
        1 => "PA"
        2 => "NPA"
        3 => "C#"
        4 => "R#"
        5 => "L#"
        6 => "TSH"
        7 => "TSL"
        8 => "CSH"
        9 => "CSL"
        10 => "T↔T"
        11 => "SP"
        12 => "P / PAQ"
        13 => "SC"
        14 => "E / B"
        15 => "DEF"
        16 => "RC"
        17 => "SD"
        18 => "R25/50/75"
        19 => "D25/50/75"
        20 => "2D"
        21 => "AQ"
        22 => "V"
        23 => "X"
        24 => "A"
        25 => "V↑ / V↓"
        26 => "BO↑ / BO↓"
        27 => "Arc"
        28 => "Ar1"
        29 => "Ar2"
        30 => "Re#"
        31 => "OCh"
        32 => "OD"
        33 => "PE"
        34 => "P#"
        35 => "ChRO / ChInt"
        36 => "Act"
        37 => "Lkd"
        38 => "EndT"
        39 => "Sup"
        40 => "Fail"
        41 => "SYD/TYO/LDN/NY"
        42 => "Live / Last"
        43 => "Sess H-L"
        => ""

// @function Unabbreviated Glossary term for a zero-based entry index.
// @param i Zero-based glossary index.
// @returns User-visible term.
export glossaryTerm(int i) =>
    switch i
        0 => "Auction Engine"
        1 => "Price Action"
        2 => "Nearest Price-Action Geometry"
        3 => "Trend-to-Trend Candidate"
        4 => "Validated Range"
        5 => "Precautionary Lineage"
        6 => "Trend Swing High"
        7 => "Trend Swing Low"
        8 => "Chop Swing High"
        9 => "Chop Swing Low"
        10 => "Trend-to-Trend"
        11 => "Structural Pair"
        12 => "Pair Auction / Pair Auction Qualification"
        13 => "Structural Containment"
        14 => "Either / Both Qualification Policy"
        15 => "Defense"
        16 => "Boundary Reclaim"
        17 => "Supply & Demand Zone Defense"
        18 => "Required 25/50/75% Pair Rotation"
        19 => "Observed 25/50/75% Pair Rotation"
        20 => "Two-Sided Defense"
        21 => "Awaiting Qualification"
        22 => "Validated Candidate"
        23 => "Failed / Superseded Candidate"
        24 => "Active Range"
        25 => "Upper / Lower Boundary Violation"
        26 => "Upper / Lower Breakout Developing"
        27 => "Visual Archive"
        28 => "First Archive Evidence"
        29 => "Second Archive Evidence"
        30 => "Reactivation Count"
        31 => "Origin-Chop"
        32 => "Origin Defense"
        33 => "Precautionary Event Count"
        34 => "Precautionary Boundary Layer"
        35 => "Chop Research Only / Integrated"
        36 => "Active Lineage"
        37 => "Locked Lineage"
        38 => "Ended by Trend"
        39 => "Superseded Lineage"
        40 => "Origin Failed"
        41 => "Canonical Session Codes"
        42 => "Developing / Most Recent Completed Session"
        43 => "Session High-Low Context"
        => ""

// @function Full Glossary hover definition for a zero-based entry index.
// @param i Zero-based glossary index.
// @returns User-visible definition.
export glossaryTip(int i) =>
    switch i
        0 => "Source-owned XZ auction registry and lifecycle engine."
        1 => "Price movement/reaction evidence. AE uses PA in Pair Auction qualification language and in NPA naming."
        2 => "Presentation-only context marking the globally nearest retained validated-Range quartile geometry bracketing live Price Action. NPA does not create authority or alter the analytical registry."
        3 => "Pure opposite-Trend-Swing structural hypothesis retained until qualification or formal failure/supersession."
        4 => "Retained validated Auction Range record."
        5 => "Trend-origin→Chop lineage retaining P0/P1+ development, retests and lifecycle state."
        6 => "Confirmed high-side Trend Swing used by pure T↔T Candidate pairing."
        7 => "Confirmed low-side Trend Swing used by pure T↔T Candidate pairing."
        8 => "Confirmed high-side Chop Swing. Always observed; authority depends on Chop Authority mode."
        9 => "Confirmed low-side Chop Swing. Always observed; authority depends on Chop Authority mode."
        10 => "Pair geometry formed from two opposite confirmed Trend Swings."
        11 => "Mandatory opposite-Trend-Swing Candidate pairing condition."
        12 => "P is the compact promotion-provenance code for Pair Auction; PAQ names the Pair Auction Qualification method. Existing-pair qualification uses defended Price Action and pair-relative rotation; no later pivot is required."
        13 => "Independent qualification from coherent defense plus a later eligible canonical pivot rotating inside the older Candidate."
        14 => "Qualification Policy codes. E = Either Method; B = Both Methods. Policy controls promotion authority while Pair Auction and Structural Containment continue to be observed for audit/Research."
        15 => "Compact qualification code for coherent defense evidence used by Structural Containment."
        16 => "Optional qualification evidence: boundary test followed by a later confirmed source close back inside Candidate geometry."
        17 => "Optional qualification evidence based on interaction with the relevant Swing-associated Supply/Demand territory and confirmed recovery."
        18 => "Enabled minimum pair-relative post-defense rotation requirements. Rotation is measured through the immutable Candidate geometry and never requires a later Trend/Chop pivot."
        19 => "Measured pair-relative post-defense rotation evidence actually achieved from either defended side."
        20 => "Optional requirement/evidence that both Candidate boundaries complete sequential defense/reclaim episodes."
        21 => "Retained C# that has neither validated nor formally failed/superseded."
        22 => "Candidate lifecycle state indicating promotion into validated Range authority. Distinct from R# V↑/V↓ boundary-violation codes."
        23 => "Candidate lifecycle state indicating formal structural failure or supersession."
        24 => "R# activity state: price is not in a retained boundary-violation/breakout-development state."
        25 => "R# activity state showing confirmed violation development through the upper or lower boundary. Distinct from Candidate V = Validated."
        26 => "R# inactive/breakout-development state through the upper or lower side."
        27 => "Retained R# is visually archived; analytical history is not deleted."
        28 => "First objective archive-evidence stage in the current Range archive lifecycle."
        29 => "Second objective archive-evidence stage in the current Range archive lifecycle."
        30 => "Number of retained R# reactivations after prior lifecycle displacement."
        31 => "Integrated Trend-origin→Chop Range genesis pathway. Sidewalled Chop Authority blocks this pathway from main R# authority."
        32 => "Origin-side defense evidence used by the Integrated Origin-Chop pathway."
        33 => "Number of retained precautionary boundary-transition events across L# history."
        34 => "P0 = lineage waiting for its first Chop boundary. P1+ = retained Chop boundary layers as the lineage develops."
        35 => "Compact Status codes for the selected Chop Authority mode."
        36 => "L# remains open and continues to observe Chop development."
        37 => "L# reached its retained lock condition."
        38 => "L# was ended by later confirmed Trend structure."
        39 => "L# was superseded by a later retained lineage/structural development."
        40 => "L# origin-side structural condition formally failed."
        41 => "Canonical Sydney, Tokyo, London and New York identifiers under the selected Session Standard. On-chart codes are hover targets when Session Codes are enabled."
        42 => "Live means the session occurrence is developing now. Last means Status is showing that selected session’s most recent completed retained occurrence."
        43 => "Bounded developing/completed session High-Low envelope used for descriptive chart and forensic context. It is not automatically support/resistance or an AE qualification condition."
        => ""

//==============================================================================
// USER-VISIBLE SETTINGS HELP
//==============================================================================
// These constants reproduce text already exposed in XZ AE's Settings UI.
// They contain no analytical derivation, registry construction, qualification, lifecycle,
// hierarchy, S&D/MS authority or selection logic.

export const string TT_AUCTION_SOURCE_TIMEFRAME = "Authoritative timeframe for the complete XZ Auction Engine registry. Daily is the default, not a methodological requirement. Pivots, S&D, C# Candidates, qualification evidence, R# Ranges, L# lineages, failure/supersession, hierarchy and archive/reactivation are all calculated in this source context. The Source Timeframe must be equal to or higher than the host chart timeframe so chart timeframe remains presentation-only."
export const string TT_CHOP_AUTHORITY_MODE = "Controls Chop authority, not Chop observation. Research Only · Sidewalled retains CSH/CSL and L# research but blocks Origin-Chop promotion. Pair Auction is unaffected. Structural Containment always accepts Trend pivots and accepts Chop pivots only when Integrated."
export const string TT_QUALIFICATION_POLICY = "Pair Auction uses the Candidate's own defended Price Action (PA) and pair-relative rotation. Structural Containment uses coherent defense plus a later eligible canonical pivot rotating inside the older Candidate. Either promotes on the first method; Both requires both. Policy controls promotion authority only; both methods continue to be observed and retained for audit and Research evidence."
export const string TT_STRUCTURAL_CONTAINMENT_DEPTH = "After coherent Candidate defense, a later canonical pivot must rotate away by at least this share of the Candidate's 0–100 geometry while remaining inside its external S&D envelope. Trend pivots always count; Chop pivots count only when Integrated."
export const string TT_REQUIRE_BOUNDARY_RECLAIM = "Pair Auction only. Requires a post-completion test of either close-defined 0%/100% boundary followed by a later confirmed source close back inside the Candidate."
export const string TT_REQUIRE_ZONE_DEFENSE = "Pair Auction only. Requires the defended side to trade beyond its close-defined anchor into the associated Swing Supply/Demand territory and subsequently close back inside the Candidate."
export const string TT_REQUIRE_ROTATION25 = "Pair Auction only. Requires at least one coherently defended Candidate side to rotate PA at least 25% through that Candidate's immutable close-defined 0–100 geometry. No later Trend/Chop pivot is required."
export const string TT_REQUIRE_ROTATION50 = "Pair Auction only. Requires at least one coherently defended Candidate side to rotate PA at least 50% through the immutable 0–100 geometry. The observed path therefore also passed 25%."
export const string TT_REQUIRE_ROTATION75 = "Pair Auction only. Requires at least one coherently defended Candidate side to rotate PA at least 75% through the immutable 0–100 geometry."
export const string TT_REQUIRE_TWO_SIDED_DEFENSE = "Pair Auction only. Requires both Candidate boundaries to complete sequential defense/reclaim episodes. If Pair Auction S&D Defense is also required, both sides must enter their own associated S&D zones."
export const string TT_PRIMARY_RANGE_FOCUS = "Focus-substitution policy only. The operational R# is selected independently by lifecycle activity priority and definitive chronology. If that R# is Origin-Chop, Pure T↔T First may keep a structurally related open root T↔T Candidate as the effective visual/operational focus. Validated R# First keeps the selected operational R# in focus. This never creates, deletes, validates or reprioritises analytical registry records."
export const string TT_FOCUSED_RANGE_IDS = "Comma-separated retained R# values, e.g. 37,39,42. Every valid ID receives display-allocation priority and detailed focus treatment; only up to Max Validated Ranges Displayed (allowed 0–20) can render. The first listed valid ID is the lead focus where ordering matters. Leave blank for no manual Range focus. Presentation only; focus never changes analytical authority."
export const string TT_FOCUSED_CANDIDATE_IDS = "Comma-separated retained C# values, e.g. 101,102. Every valid ID receives display-allocation priority and detailed focus treatment; only up to Max Candidates Displayed (allowed 0–10) can render. The first listed valid ID is the lead focus where ordering matters. Leave blank for no manual Candidate focus. Presentation only; focus never validates a Candidate or changes authority."
export const string TT_MUTE_NON_FOCUS_DURING_MANUAL_FOCUS = "When one or more valid R#/C# focus IDs are entered, keep those focused objects detailed while strongly fading other displayed Range/Candidate quartiles, S&D zones, Range frames and audit tags. Context remains visible and interactive; analytical state is unchanged."
export const string TT_HISTORICAL_RANGE_DISPLAY = "Automatic R# selector after focused IDs receive priority. Range Hierarchy = operational/local R# → materially enclosing Ranges → formal parent/children → optional strongest pure T↔T R# → newest distinct backfill. Current + Parents = operational R# plus its retained parent chain. Visible Window = newest retained Ranges whose qualifying pivot pair overlaps the visible chart window; archived history is intentionally discoverable. Recent Eligible = newest non-inactive eligible Ranges. All Eligible = retained eligible history, newest-first unless Study Start is enabled. Focus Only = focused IDs only. All modes remain subject to Max Validated Ranges Displayed."
export const string TT_VALIDATED_RANGE_DISPLAY_LIMIT = "Hard chart cap for validated Ranges. Allowed 0–20 · default 3. 0 hides all validated Range geometry. Focused Range IDs receive slots first; the selected automatic Range scope fills only remaining capacity. Presentation only."
export const string TT_SHOW_TIGHTEST_PA_BRACKET = "Presentation override showing the nearest eligible retained validated-Range quartile below and above live Price Action (PA), while explicit Focused R#/C# objects remain available as the study layer. NPA lines render as the live-context layer; their tags face inward from the live edge so they do not cover focused structural endpoint/quartile labels at coincident prices."
export const string TT_INCLUDE_STRONGEST_VALIDATED_RANGE = "Range Hierarchy helper. Strongest retained pure T↔T R# is considered only after operational/local and explicit hierarchy-relevance context (nearest enclosing Ranges, formal parent and direct children). It may fill spare capacity but never evicts those more locally relevant hierarchy members. Strength uses retained qualification evidence, then deepest Pair Auction rotation, then qualification recency."
export const string TT_SHOW_OPERATIONAL_FOCUS_RANGE = "Allows the current operational Auction Range to use an automatic validated-Range display slot. Focused Range IDs retain allocation priority when the display cap is full. Exceptions: Focus Only ignores the operational pin; Visible Window includes the operational R# only when its qualifying pivot pair overlaps the visible window; All Eligible + Study Start lets the manual historical allocation own the automatic slots instead of forcing the operational R#. Analytical authority continues regardless."
export const string TT_HIDE_VISUALLY_ARCHIVED_RANGES = "ON suppresses visually archived Ranges from normal automatic selectors. Visible Window is the deliberate exception because it is a historical discovery view and can expose archived retained history. Focused Range IDs can also force retained archived Ranges into display. Archive evidence is always calculated."
export const string TT_USE_RANGE_STUDY_START_DATE = "Historical research helper for dense assets. In All Eligible mode, automatic Range allocation begins at the first retained Range whose structural completion is on/after the selected date and fills forward up to Max Validated Ranges. Focused Range IDs bypass this filter."
export const string TT_RANGE_STUDY_START_DATE = "UTC start anchor for All Eligible historical study allocation. The Max Validated Ranges cap (allowed 0–20 · default 3) counts forward from this date instead of always taking the newest retained Ranges."
export const string TT_CANDIDATE_DISPLAY_MODE = "Automatic T↔T Candidate selector after focused IDs receive priority. Off = no automatic C# geometry. Latest Defended Unvalidated = newest retained unresolved C# with recorded defense. Latest Unvalidated = newest retained unresolved C#. Primary Unvalidated Root = newest unresolved root Candidate (parentCandidateId = 0). Latest Registry = newest retained C# record regardless of terminal lifecycle state, so validated/failed records may be exposed. Automatic matches fill only slots left after focused IDs; analytical C# retention is unchanged."
export const string TT_CANDIDATE_DISPLAY_LIMIT = "Hard chart cap for T↔T Candidates. Allowed 0–10 · default 1. Default 1 preserves one explicit focused-C# study slot even though automatic Candidate Display Scope defaults Off. 0 hides all Candidate geometry including focused IDs. Focused Candidate IDs receive slots first; automatic scope fills only remaining capacity. Presentation only."
export const string TT_SHOW_WAITING_ORIGIN = "Shows the associated source-timeframe Trend-Swing Supply/Demand zone after a TSH/TSL confirms while no opposite Auction boundary exists yet. Show Associated S&D Zones is the master zone-visibility switch and must also be On. No Fib is drawn until two valid boundaries exist."
export const string TT_SHOW_PRECAUTIONARY_DEVELOPMENT = "Display-only master for retained precautionary L# geometry. The engine always observes/calculates L# regardless of this switch or Chop Authority. OFF is the clean-chart default and does not mean Integrated Chop forces L# display On."
export const string TT_PRECAUTIONARY_DISPLAY_MODE = "Selects one retained Trend-origin→Chop L# for display. Off = none. Latest Active = newest open lineage. Latest Registry = newest retained lineage with at least P1, including terminal states. Latest Locked = newest locked lineage. Selected Lineage ID = requested retained L#; ID 0 falls back to Latest Active. Display choice never changes lineage observation, retention or Chop Authority."
export const string TT_INSPECT_PRECAUTIONARY_LINEAGE_ID = "Enter the retained L# to display when Precautionary Lineage Display is Selected Lineage ID. Minimum 0; 0 falls back to Latest Active. Positive values are retained L# IDs and are not capped by this input."
export const string TT_PRECAUTIONARY_GEOMETRY_DETAIL = "Controls only the selected Chop lineage drawing. The lineage engine always calculates."
export const string TT_SHOW_ASSOCIATED_ZONES = "Master visibility switch for canonical Swing-associated Supply/Demand zones related to displayed R#/C#/L# objects, including the waiting Trend-Swing origin zone. Shared structural zones can participate in more than one retained object. Presentation only."
export const string TT_ZONE_TAG_DISPLAY_MODE = "Audit Tag is the default compact ownership surface at the right/end of each displayed S&D zone: e.g. R#35 · D or C#47 · S. The tag faces inward over the zone so structural R#/C# quartile/endpoints keep a separate outside-right label lane on narrow charts. Hovering the tag reports canonical S&D origin plus retained object relationships using that Swing-associated zone. Compact Text keeps the larger two-line ownership decoder at the object origin. Off removes zone tags."
export const string TT_SHOW_QUARTILE_LABELS = "Shows labels on every currently focused Range and Candidate. Structural 0% and 100% endpoint tags carry the owning R#/C# ID and act as the forensic hover surface when Chart Audit Tooltips are enabled; 25/50/75 remain geometry decoders. Focused quartile/endpoint labels own the outside-right lane, while S&D/NPA tags use inward-facing lanes to reduce narrow/mobile collisions."
export const string TT_SHOW_VALIDATED_RANGE_FRAMES = "Optional line-only Range frame. Adds faint dashed left/right rails; the existing 0%/100% Range boundaries form the horizontal edges. Uses no box and no fill, so there is no full-area Range hover surface. R# identity/audit remains on the endpoint tags. Presentation only."
export const string TT_SHOW_CHART_AUDIT_TOOLTIPS = "Master switch for chart-side forensic hover data. Focused R#/C# 0%/100% tags, NPA tags and S&D ownership tags become their own hover surfaces; L# keeps its independent icon-only audit fallback; Range-pair Trend-pivot discovery icons remain separately controlled below. Label lanes are separated by role to reduce narrow/mobile collisions."
export const string TT_AUDIT_DISTANCE_UNIT = "Controls absolute geometry-distance units used in chart and Status audit telemetry. Auto uses Ticks for futures and Points for all other instrument types. Points = raw price difference. Ticks = raw price difference divided by the symbol's minimum tick. Formatting only."
export const string TT_SHOW_RANGE_PAIR_PIVOT_AUDIT_ICONS = "Audit/discovery overlay. Shows tiny ⓘ discovery targets on retained Trend pivots that participate in T↔T Candidates, even when related geometry is hidden. ‘Range-pair pivot’ means the Swing participates in range-classification geometry; it does not mean the pivot itself has qualified a Range. Hover to see every retained C# and R# relationship using that pivot. Newest retained relationships are allocated first up to the Pivot Audit Icon Limit. ON by default for direct historical discovery."
export const string TT_MAX_RANGE_PAIR_PIVOT_AUDIT_ICONS = "Presentation/performance cap for Range-Pair Pivot Audit icons. Allowed 20–300 · default 200. Newest retained T↔T relationships are traversed first and unique pivots are allocated until this limit is reached. This does not limit the C#/R# registry or the relationships reported by any allocated pivot tooltip."
export const string TT_SHOW_PIVOT_PAIR_LINKS = "Optional finite diagonal pair decoder. OFF by default."
export const string TT_AUTO_DEDUPLICATE_DISPLAY = "Suppresses materially coincident automatic presentation geometry in hierarchy/recent Range context and automatic Candidate/Lineage rendering. Explicit focused/selected IDs bypass deduplication. Discovery-oriented Range modes Visible Window and All Eligible intentionally preserve retained historical records rather than deduplicating their allocation. Analytical records are never merged."
export const string TT_DEDUP_TOLERANCE_PCT = "Near-duplicate threshold for BOTH 0% and 100% relative to the larger geometry width. Allowed 0–10% · step 0.25% · default 2%."
export const string TT_USE_UNIFIED_COLOR = "Optional chart-object override. When enabled, XZ AE Range/Candidate/Lineage geometry and associated Supply/Demand hues derive from Unified Color while transparency, width, line style, lifecycle fade, focus fade and visibility remain intact. It never changes auction calculations, registry state, Research data, or any table palette."
export const string TT_UNIFIED_COLOR = "Single chart-object hue used when Use Unified Color is enabled. Defaults to XZ Gold #B8860B. Native Auction/Supply/Demand colours remain stored and return when the override is disabled. Tables do not inherit this override."
export const string TT_AUCTION_GEOMETRY_COLOR = "Native R#/C#/L# geometry colour when Unified Color is disabled. This includes Range/Candidate quartiles, Range frames, pair links and related chart-semantic audit geometry."
export const string TT_NEAREST_PA_GEOMETRY_COLOR = "Native NPA context hue when Unified Color is disabled. Defaults to a muted XZ steel blue so Nearest PA geometry is distinct from focused/native auction geometry without becoming visually dominant. Use Unified Color overrides this hue."
export const string TT_ASSOCIATED_SUPPLY_COLOR = "Native Swing-associated Supply hue when Unified Color is disabled. Defaults to XZ Oxblood."
export const string TT_ASSOCIATED_DEMAND_COLOR = "Native Swing-associated Demand hue when Unified Color is disabled. Defaults to XZ Verdigris."
export const string TT_PRECAUTIONARY_TRANSPARENCY = "Transparency applied to displayed precautionary L# geometry. Allowed 0–95% · default 72%. 0% = opaque; 95% is the most transparent selectable value."
export const string TT_ZONE_TRANSPARENCY = "Transparency of active associated S&D zones. Allowed 50–98% · default 86%. 50% is the most opaque selectable value; 98% is the most transparent."
export const string TT_CONSUMED_ZONE_TRANSPARENCY = "Transparency of consumed associated S&D zones retained for R#/C#/L# context. Allowed 70–100% · default 94%. 70% is the most opaque selectable value; 100% is fully transparent."
export const string TT_SHOW_RESEARCH_LAB = "Optional objective XZ Auction Engine research table. OFF by default. It studies retained C# qualification, R# lifecycle and L# Chop-lineage behaviour from the source-owned registry. It never creates Candidates, validates Ranges, changes Chop Authority, produces trade outcomes or alters chart display allocation."
export const string TT_RESEARCH_SECTION = "Candidate Qualification studies C# lifecycle, latency, first defense, promotion method and Pair Auction rotation. Range Lifecycle studies R# genesis/lifecycle/hierarchy. Chop Lineages studies retained L# development and outcomes."
export const string TT_RESEARCH_STATISTIC_MODE = "Chooses Median or Mean for sampled qualification latency, Range archive latency, Range height, lineage layer and lineage resolution-time observations. Median is the XZ default because unusually long-lived auction structures can distort arithmetic averages."
export const string TT_RESEARCH_TABLE_POSITION = "Screen position of the optional XZ AE Research Lab. Bottom-left follows the XZ suite convention because Quick Read is temporary onboarding. If both are enabled at the same anchor, disable Quick Read or move one table."
export const string TT_RESEARCH_TEXT_SIZE = "Text size used by the XZ AE Research Lab."
export const string TT_RESEARCH_BG_COLOR = "Background colour of the Research Lab. Defaults to XZ graphite #1E222D."
export const string TT_RESEARCH_TEXT_COLOR = "Neutral text colour used for Research labels and ordinary calculated values."
export const string TT_RESEARCH_ACCENT_COLOR = "XZ suite accent used for the Research Lab title and selected emphasis."
export const string TT_RESEARCH_SHOW_LINES = "Shows the Research Lab frame and cell borders. ON is the XZ suite default."
export const string TT_RESEARCH_LINE_COLOR = "Neutral graphite colour used by the Research Lab frame and cell borders."
export const string TT_SHOW_STATUS_TABLE = "Master visibility switch for the compact XZ AE operational Status table. OFF is the AE clean-chart default. Turning it OFF hides only the table; source-owned calculations, chart drawings, Research and audit surfaces continue normally."
export const string TT_STATUS_TABLE_MODE = "Expanded is the forensic operating view: Source, Authority, Qualification, Geometry, Registry, Display Allocation, Focus, Chop Authority and effective Audit state. Collapsed becomes a one-row glance strip with XZ AE, Source, current Authority and compact Qualification policy/evidence. Both are presentation-only."
export const string TT_STATUS_TABLE_POSITION = "Screen position of the XZ AE operational Status table. Top-right is the XZ suite default."
export const string TT_STATUS_TEXT_SIZE = "Text size used by the XZ AE Status table."
export const string TT_STATUS_BG_COLOR = "Background colour of the Status table. Defaults to XZ graphite #1E222D."
export const string TT_STATUS_TEXT_COLOR = "Neutral text colour used for Status labels and ordinary contextual values."
export const string TT_STATUS_ACCENT_COLOR = "XZ suite accent used for Status title and selected current-state emphasis. Independent of the chart-object Unified Color override."
export const string TT_STATUS_SHOW_LINES = "Shows the Status table frame and cell borders. ON is the XZ suite default."
export const string TT_STATUS_LINE_COLOR = "Neutral graphite colour used by the Status table frame and cell borders."
export const string TT_SHOW_QUICK_READ = "Optional XZ Auction Engine onboarding guide. OFF by default in AE. It explains source authority, Candidate→Range progression, qualification, Chop Authority and lifecycle/display separation. Informational only."
export const string TT_QUICK_READ_POSITION = "Screen position of the optional XZ AE Quick Read."
export const string TT_QUICK_READ_TEXT_SIZE = "Text size used only by the XZ AE Quick Read table."
export const string TT_QUICK_READ_BG_COLOR = "Background colour of the Quick Read. Defaults to XZ graphite #1E222D."
export const string TT_QUICK_READ_TEXT_COLOR = "Neutral body-text colour used by Quick Read. The title retains the XZ Gold suite accent."
export const string TT_QUICK_READ_SHOW_LINES = "Shows the Quick Read frame and cell borders. ON is the XZ suite default."
export const string TT_QUICK_READ_LINE_COLOR = "Neutral graphite colour used by the Quick Read frame and cell borders."
export const string TT_SHOW_GLOSSARY = "Shows the compact XZ AE code → unabbreviated-term decoder. Longer definitions live only on the compact code cell. OFF by default."
export const string TT_GLOSSARY_POSITION = "Screen position of the optional XZ AE Glossary."
export const string TT_GLOSSARY_TEXT_SIZE = "Text size used by the compact XZ AE Glossary."
export const string TT_GLOSSARY_BG_COLOR = "Background colour of the Glossary. Defaults to XZ graphite #1E222D."
export const string TT_GLOSSARY_TEXT_COLOR = "Neutral colour used for unabbreviated Glossary terms."
export const string TT_GLOSSARY_ACCENT_COLOR = "XZ suite accent used for Glossary codes and title. Independent of chart-object Unified Color."
export const string TT_GLOSSARY_SHOW_LINES = "Shows the Glossary frame and cell borders."
export const string TT_GLOSSARY_LINE_COLOR = "Neutral graphite colour used by the Glossary frame and cell borders."

//==============================================================================
// USER-VISIBLE TABLE / REFERENCE COPY
//==============================================================================
// Static labels and explanatory text already exposed by XZ AE tables.
// No analytical values, registry reads, qualification/lifecycle logic or selection logic live here.

export const string RS_HEADER_LEFT_TIP = "Objective descriptive observations from the source-owned C#/R#/L# registry snapshot within the 100,000-source-bar replay budget. Display scope, focus IDs, visual archive visibility and chart timeframe do not filter these statistics."
export const string RS_HEADER_RIGHT_TIP = "Research observes retained auction history only. It never creates analytical authority, changes qualification, alters Chop Authority or produces trade-performance statistics."
export const string RS_CANDIDATE_LABELS = "C# Studied¦C# State Mix¦Resolved Conversion¦¦First Defense Side¦Promotion Method¦Observed Pair Rotation Reach¦Two-Sided Defense"
export const string RS_CANDIDATE_TIPS = "Total retained pure T↔T Candidate records in the source-owned registry. Displayed Candidate scope does not filter this sample.¦AQ = awaiting qualification · V = validated · X = formally failed/superseded. These are retained lifecycle states, not display states.¦Validated share of resolved Candidates only: V / (V + X). Awaiting Candidates are excluded. Descriptive only; not a trade win rate.¦Selected Median/Mean completion→validation time across validated pure T↔T Candidates only.¦First coherent Candidate defense: L = lower · U = upper · — = none recorded. Same-candle two-sided traversal is deliberately ambiguous and cannot earn first defense.¦Promotion provenance: P = Pair Auction · SC = Structural Containment · B = Both.¦Cumulative D25/D50/D75 Pair Auction rotation reach, independent of later pivot classification.¦Candidates whose retained Pair Auction evidence reached two-sided defense."
export const string RS_RANGE_LABELS = "R# Studied¦Range Genesis¦Lifecycle Mix¦Hierarchy¦Reactivation¦¦"
export const string RS_RANGE_TIPS = "Total retained validated Range records in the source-owned registry.¦T↔T = pure Trend-to-Trend genesis · OCh = Origin-Validated Chop genesis available through Integrated Chop Authority.¦A = Active · Viol = Violating · BO = Breakout Developing · Arc = Visually Archived. Bare V remains reserved for Candidate Validated.¦Root has no retained parentRangeId. Child has an explicit parent Range relationship.¦Ranges reactivated at least once, followed by total retained reactivation events.¦Selected Median/Mean definitive validation→visual archive elapsed time for archived Ranges only.¦Selected Median/Mean close-defined R# height as a percentage of the lower anchor."
export const string RS_LINEAGE_LABELS = "L# Studied¦L# State Mix¦Resolved Lock Share¦Retained P-Events¦¦Origin Retest¦"
export const string RS_LINEAGE_TIPS = "Total retained Trend-origin→Chop precautionary lineages.¦Act = active · Lkd = locked · EndT = ended by later Trend structure · Sup = superseded · Fail = origin failure.¦Locked share of resolved lineages only. Active unresolved L# records are excluded. Descriptive control-group evidence only.¦Total retained P1→P2→… boundary-transition events across all L# lineages.¦Selected Median/Mean retained P-layer reached per lineage.¦Lineages that began an origin-side retest episode.¦Selected Median/Mean origin-confirmation→non-open-state elapsed time. Active lineages are excluded."

export const string ST_COLLAPSED_TITLE_TIP = "Collapsed operational strip. Historical object forensics belong to chart hovers; lifecycle distributions belong to Research."
export const string ST_EXPANDED_TITLE_TIP = "Current operational snapshot only. Historical object forensics belong to chart audit hovers; registry distributions and lifecycle research belong to Research."
export const string ST_SOURCE_TIP = "Auction Source Timeframe and source-owned registry context within the 100,000-source-bar replay budget. Supported host domain: Source ≥ Chart."
export const string ST_QUALIFICATION_LABEL_TIP = "Req = selected Qualification Policy plus method-specific requirements. P = Pair Auction · SC = Structural Containment · E = Either · B = Both. Obs = method state plus retained evidence. OD = Origin Defense for Integrated Origin-Chop authority."
export const string ST_GEOMETRY_LABEL_TIP = "Current operational/focused object pair and close-defined lower→upper geometry."
export const string ST_REGISTRY_LABEL_TIP = "Retained source-owned registry counts within the 100,000-source-bar replay budget. R = validated Ranges · C = pure T↔T Candidates · L = precautionary Trend→Chop lineages."
export const string ST_DISPLAY_LABEL_TIP = "Current chart allocation before geometry deduplication and Nearest-PA presentation overrides."
export const string ST_FOCUS_LABEL_TIP = "Explicit visual focus IDs and lead-focus ordering."
export const string ST_CHOP_LABEL_TIP = "ChRO = Research Only · Sidewalled. ChInt = Integrated. PE = retained precautionary event count."
export const string ST_AUDIT_LABEL_TIP = "Effective presentation/audit state. Pivot ⓘ is On only when both Chart Audit Tooltips and Pivot Audit Icons are enabled."
export const string ST_AUTHORITY_LABEL_TIP = "Current operational Auction object/state."
export const string ST_QUALIFICATION_PREFIX = "Qualification policy/evidence. "
export const string ST_RANGE_SCOPE_PREFIX = "Range scope: "
export const string ST_CANDIDATE_SCOPE_PREFIX = "\nCandidate scope: "
export const string ST_PIVOT_LIMIT_PREFIX = "Pivot icon limit: "
export const string ST_PIVOT_LIMIT_SUFFIX = " (allowed 20–300; default 200)."
export const string ST_PIVOT_NOT_RENDERABLE = "Pivot icons are not currently renderable."

//==============================================================================
// USER-VISIBLE PRESENTATION DECODERS / FORMATTERS
//==============================================================================
// These functions only translate already-derived AE facts into text the user can see.
// They do not create pivots, Candidates, Ranges, lineages, qualification evidence,
// lifecycle state, hierarchy, selection authority or object relationships.

export activityText(int state) =>
    state == 2 ? "Violating ↑" :
     state == 3 ? "Violating ↓" :
     state == 4 ? "Breakout Developing ↑" :
     state == 5 ? "Breakout Developing ↓" : "Active"

export activityCode(int state) =>
    state == 2 ? "V↑" :
     state == 3 ? "V↓" :
     state == 4 ? "BO↑" :
     state == 5 ? "BO↓" : "A"

export qualificationMethodText(int method) =>
    method == 1 ? "Pair Auction" : method == 2 ? "Structural Containment" : method == 3 ? "Both Methods" : "None"

export lineageStateText(int state) =>
    state == 2 ? "Locked" :
     state == 3 ? "Ended by Trend" :
     state == 4 ? "Superseded" :
     state == 5 ? "Origin Failed" : "Active"

export tooltipSwingCode(int side, int family) =>
    family == 1 ? (side == 1 ? "TSH" : side == -1 ? "TSL" : "—") :
     family == 2 ? (side == 1 ? "CSH" : side == -1 ? "CSL" : "—") : "—"

export tooltipValidationSideText(int side) =>
    side == -1 ? "Lower boundary defense" : side == 1 ? "Upper boundary defense" : "Composite / both"

export tooltipZoneGeometry(int side, float outer, float inner) =>
    not na(outer) and not na(inner) ?
     (side == 1 ? str.tostring(inner, format.mintick) + " → " + str.tostring(outer, format.mintick) : str.tostring(outer, format.mintick) + " → " + str.tostring(inner, format.mintick)) : "—"

export focusedEndpointAuditText(string objectId, string levelText) =>
    str.length(objectId) > 0 ? objectId + " · " + levelText : levelText

appendRequirement(string baseText, string itemText) =>
    str.length(baseText) == 0 ? itemText : baseText + " + " + itemText

export validationRequirementsCode(bool boundaryReclaim, bool zoneDefense, bool rotation25, bool rotation50, bool rotation75, bool twoSidedDefense, string containmentDepth, string policy) =>
    string pairCode = ""
    if boundaryReclaim
        pairCode := appendRequirement(pairCode, "RC")
    if zoneDefense
        pairCode := appendRequirement(pairCode, "SD")
    if rotation25
        pairCode := appendRequirement(pairCode, "R25")
    if rotation50
        pairCode := appendRequirement(pairCode, "R50")
    if rotation75
        pairCode := appendRequirement(pairCode, "R75")
    if twoSidedDefense
        pairCode := appendRequirement(pairCode, "2D")
    pairCode := str.length(pairCode) == 0 ? "SP" : pairCode
    string scCode = "DEF+SC" + (containmentDepth == "75%" ? "75" : containmentDepth == "50%" ? "50" : "25")
    policy == "Pair Auction Only" ? "P[" + pairCode + "]" :
     policy == "Structural Containment Only" ? "SC[" + scCode + "]" :
     policy == "Both Methods" ? "B[P:" + pairCode + "|SC:" + scCode + "]" :
     "E[P:" + pairCode + "|SC:" + scCode + "]"

export validationRequirementsText(bool boundaryReclaim, bool zoneDefense, bool rotation25, bool rotation50, bool rotation75, bool twoSidedDefense, string containmentDepth, string policy) =>
    string pairText = ""
    if boundaryReclaim
        pairText := appendRequirement(pairText, "Boundary Reclaim")
    if zoneDefense
        pairText := appendRequirement(pairText, "S&D Defense")
    if rotation25
        pairText := appendRequirement(pairText, "Pair Rotation ≥25%")
    if rotation50
        pairText := appendRequirement(pairText, "Pair Rotation ≥50%")
    if rotation75
        pairText := appendRequirement(pairText, "Pair Rotation ≥75%")
    if twoSidedDefense
        pairText := appendRequirement(pairText, "Two-Sided Defense")
    pairText := str.length(pairText) == 0 ? "Structural Pair Only" : pairText
    string scText = "Boundary Defense + canonical pivot rotation ≥" + (containmentDepth == "75%" ? "75%" : containmentDepth == "50%" ? "50%" : "25%")
    policy == "Pair Auction Only" ? "Pair Auction: " + pairText :
     policy == "Structural Containment Only" ? "Structural Containment: " + scText :
     policy == "Both Methods" ? "Both Methods required · Pair Auction: " + pairText + " · Structural Containment: " + scText :
     "Either Method may qualify · Pair Auction: " + pairText + " · Structural Containment: " + scText

export candidateObservedEvidenceCode(bool boundaryReclaim, bool zoneDefense, int rotationDepth, bool twoSidedDefense, bool structuralContainment) =>
    string result = "SP"
    if boundaryReclaim
        result += "+RC"
    if zoneDefense
        result += "+SD"
    if rotationDepth >= 75
        result += "+D75"
    else if rotationDepth >= 50
        result += "+D50"
    else if rotationDepth >= 25
        result += "+D25"
    if twoSidedDefense
        result += "+2D"
    if structuralContainment
        result += "+SC"
    result

export candidateObservedEvidenceText(bool boundaryReclaim, bool zoneDefense, int rotationDepth, bool twoSidedDefense, bool structuralContainment) =>
    string result = "Structural Pair"
    if boundaryReclaim
        result += " + Boundary Reclaim"
    if zoneDefense
        result += " + S&D Zone Defense"
    if rotationDepth >= 75
        result += " + Pair Rotation ≥75%"
    else if rotationDepth >= 50
        result += " + Pair Rotation ≥50%"
    else if rotationDepth >= 25
        result += " + Pair Rotation ≥25%"
    if twoSidedDefense
        result += " + Two-Sided Defense"
    if structuralContainment
        result += " + Structural Containment"
    result

export candidateStateSummary(bool failed, bool validated) =>
    failed ? "Failed / superseded" : validated ? "Validated" : "Awaiting qualification"

//==============================================================================
// USER-VISIBLE FORENSIC TOOLTIP FORMATTERS
//==============================================================================
// These functions assemble text from facts already derived by protected AE.
// They do not search registries, detect relationships, qualify Candidates, change lifecycle,
// select authority, or calculate MS/S&D/Range methodology.

export candidateDefenseRotationText(string lowDate, string lowRotation, string highDate, string highRotation) =>
    "Lower: " + lowDate + " · post-defense rotation " + lowRotation + " | Upper: " + highDate + " · post-defense rotation " + highRotation

export candidateEpisodeText(int firstDefenseSide, string firstDefenseDate) =>
    firstDefenseSide == -1 ? "Lower-boundary defense · " + firstDefenseDate :
     firstDefenseSide == 1 ? "Upper-boundary defense · " + firstDefenseDate :
     "Waiting for first coherent defense"

export candidateQualificationBlock(string methodText, string qualificationTime, string validationSideText, string durationText) =>
    "\nPromoted by: " + methodText +
     "\nQualification time: " + qualificationTime + " · " + validationSideText +
     "\nCompletion → qualification duration: " + durationText

export candidateFailureBlock(string failureTime, string failureSideText, string durationText) =>
    "\nFailure / supersession time: " + failureTime + " · later external T↔T pair beyond " + failureSideText +
     "\nCompletion → failure duration: " + durationText

export promotedRangeLifecycleText(bool archived, int archiveSide, string activityTextValue, int reactivationCount) =>
    string result = archived ? "Visually archived " + (archiveSide == 1 ? "↑" : archiveSide == -1 ? "↓" : "") : activityTextValue
    if not archived and reactivationCount > 0
        result += " · Reactivations " + str.tostring(reactivationCount)
    result

export rangeArchiveText(bool archived, string archiveDate, int archiveSide, int developingSide, string firstPivotDate) =>
    archived ? archiveDate + " · two external Trend pivots " + (archiveSide == 1 ? "↑" : "↓") :
     developingSide != 0 ? "Developing 1/2 " + (developingSide == 1 ? "↑" : "↓") + " · first pivot " + firstPivotDate :
     "Not archived"

export candidatePromotedRangeBlock(bool exists, string rangeId, string qualificationTime, string lifecycleText, string archiveText, string parentText) =>
    exists ?
     "\nPromoted Range: R#" + rangeId +
     "\nPromoted Range qualification time: " + qualificationTime +
     "\nPromoted Range lifecycle: " + lifecycleText +
     "\nPromoted Range visual archive: " + archiveText +
     "\nPromoted Range parent: " + parentText :
     "\nPromoted Range: None"

export candidateAuditTooltip(
     string candidateId, string stateText, string pairText,
     string lowPrice, string highPrice, string heightText, string moveText, string livePriceText, string formationText,
     string firstPivotCode, string firstPivotDate, string firstPivotPrice, string firstConfirmDate,
     string secondPivotCode, string secondPivotDate, string secondPivotPrice, string secondConfirmDate,
     string completionTime, string episodeText, string pairMethodTime, string structuralMethodTime, string policyText,
     string observedEvidence, string requiredEvidence, string anchorTests, string zoneTests, string defenseText,
     string originZone, string boundaryZone, string qualificationBlock, string failureBlock, string promotedBlock,
     string parentText
 ) =>
    "C#" + candidateId + " · T↔T Candidate · " + stateText + "\n" +
     "Structure: " + pairText + "\n" +
     "Candidate geometry (0% → 100%): " + lowPrice + " → " + highPrice + "\n" +
     "Candidate height: " + heightText + "\n" +
     "Directional pair move (first → second pivot): " + moveText + "\n" +
     livePriceText + "\n" +
     "Candidate pivot-to-pivot duration: " + formationText + "\n" +
     "First pivot (" + firstPivotCode + "): " + firstPivotDate + " @ " + firstPivotPrice + " · confirmed " + firstConfirmDate + "\n" +
     "Second pivot (" + secondPivotCode + "): " + secondPivotDate + " @ " + secondPivotPrice + " · confirmed " + secondConfirmDate + "\n" +
     "Candidate completion time: " + completionTime + "\n" +
     "Qualification episode start: " + episodeText + "\n" +
     "Methods: Pair " + pairMethodTime + " · SC " + structuralMethodTime + " · Policy " + policyText + "\n" +
     "Observed qualification evidence: " + observedEvidence + "\n" +
     "Required qualification evidence: " + requiredEvidence + "\n" +
     "Lower / upper anchor tests: " + anchorTests + "\n" +
     "Lower / upper S&D tests: " + zoneTests + "\n" +
     "Lower / upper boundary defenses + pair rotations: " + defenseText + "\n" +
     "Origin S&D zone: " + originZone + "\n" +
     "Boundary S&D zone: " + boundaryZone +
     qualificationBlock + failureBlock + promotedBlock + "\n" +
     "Parent Candidate: " + parentText

export lineageWaitingGeometry() =>
    "Lineage geometry: Waiting for Chop boundary"

export lineageGeometryBlock(string lowPrice, string highPrice, string heightText, string moveText, string livePriceText, string durationText) =>
    "Lineage geometry (0% → 100%): " + lowPrice + " → " + highPrice +
     "\nLineage height: " + heightText +
     "\nDirectional pair move (first → second pivot): " + moveText +
     "\n" + livePriceText +
     "\nLineage pivot-to-pivot duration: " + durationText

export lineageWaitingBoundary() =>
    "Current Chop boundary pivot: Waiting"

export lineageBoundaryBlock(string boundaryCode, string boundaryDate, string boundaryPrice, string boundaryConfirmDate) =>
    "Current Chop boundary pivot (" + boundaryCode + "): " + boundaryDate + " @ " + boundaryPrice + " · confirmed " + boundaryConfirmDate

export lineageAuditTooltip(
     string lineageId, string stateText, string originCode, string boundaryCode, string layerText,
     string geometryBlock, string originDate, string originPrice, string originConfirmDate,
     string boundaryBlock, string retestDate, bool retestStarted, string originZone, bool hasBoundary,
     string boundaryZone, string stateTime, string promotedRangeText
 ) =>
    "L#" + lineageId + " · Precautionary Lineage · " + stateText + "\n" +
     "Structure: " + originCode + " → " + boundaryCode + "\n" +
     "Precautionary layer: P" + layerText + "\n" +
     geometryBlock + "\n" +
     "Origin Trend pivot (" + originCode + "): " + originDate + " @ " + originPrice + " · confirmed " + originConfirmDate + "\n" +
     boundaryBlock + "\n" +
     "Origin-boundary retest: " + retestDate + (retestStarted ? " · started" : " · not started") + "\n" +
     "Origin S&D zone: " + originZone +
     (hasBoundary ? "\nBoundary S&D zone: " + boundaryZone : "") + "\n" +
     "Lineage state time: " + stateTime + "\n" +
     "Promoted Range: " + promotedRangeText

export rangeAuditTooltip(
     string rangeId, string rangeType, string pairText, string lowPrice, string highPrice,
     string heightText, string moveText, string livePriceText, string formationText,
     string firstPivotCode, string firstPivotDate, string firstPivotPrice,
     string secondPivotCode, string secondPivotDate, string secondPivotPrice,
     string completionTime, string observedEvidence, string requiredEvidence,
     string qualificationTime, string qualificationLatency, bool includeDefense, string defenseText,
     string originZone, string boundaryZone, string archiveText, string lifecycleText,
     string lastActiveTime, string parentText, string sourceText
 ) =>
    "R#" + rangeId + " · " + rangeType + "\n" +
     "Structure: " + pairText + "\n" +
     "Range geometry (0% → 100%): " + lowPrice + " → " + highPrice + "\n" +
     "Range height: " + heightText + "\n" +
     "Directional pair move (first → second pivot): " + moveText + "\n" +
     livePriceText + "\n" +
     "Range pivot-to-pivot duration: " + formationText + "\n" +
     "First pivot (" + firstPivotCode + "): " + firstPivotDate + " @ " + firstPivotPrice + "\n" +
     "Second pivot (" + secondPivotCode + "): " + secondPivotDate + " @ " + secondPivotPrice + "\n" +
     "Range structural completion time: " + completionTime + "\n" +
     "Observed qualification evidence: " + observedEvidence + "\n" +
     "Required qualification evidence: " + requiredEvidence + "\n" +
     "Qualification time: " + qualificationTime + "\n" +
     "Structural completion → qualification duration: " + qualificationLatency + "\n" +
     (includeDefense ? "Lower / upper boundary defenses + pair rotations: " + defenseText + "\n" : "") +
     "Origin S&D zone: " + originZone + "\n" +
     "Boundary S&D zone: " + boundaryZone + "\n" +
     "Visual archive state: " + archiveText + "\n" +
     "Range lifecycle state: " + lifecycleText + "\n" +
     "Last active time: " + lastActiveTime + "\n" +
     "Parent Range: " + parentText + "\n" +
     "Source: " + sourceText



//==============================================================================
// GENERIC OBJECT-RELATIONSHIP PRESENTATION
//==============================================================================
// Protected AE discovers the relationship first. These helpers only render caller-supplied facts.

export relationshipGeometryBlock(
     string header, string relationLine, string pairText, string geometryName,
     string lowText, string highText, string heightText, string moveText,
     string livePositionText, string durationText, string tailText
 ) =>
    header +
     (str.length(relationLine) > 0 ? "\n" + relationLine : "") +
     "\nStructure: " + pairText +
     "\n" + geometryName + " geometry (0% → 100%): " + lowText + " → " + highText +
     "\n" + geometryName + " height: " + heightText +
     "\nDirectional pair move (first → second pivot): " + moveText +
     "\n" + livePositionText +
     (str.length(durationText) > 0 ? "\n" + geometryName + " pivot-to-pivot duration: " + durationText : "") +
     (str.length(tailText) > 0 ? "\n" + tailText : "")

export pivotRelationshipTooltip(string pivotCode, string pivotDate, string pivotPrice, string relationships) =>
    pivotCode + " · Range-pair Trend pivot" +
     "\nPivot time: " + pivotDate +
     "\nPivot close anchor: " + pivotPrice +
     (str.length(relationships) > 0 ? "\n\nObject relationships\n\n" + relationships : "\n\nObject relationships: None")

export zoneOwnershipTooltip(string zoneType, string originDate, string lowText, string highText, string displayedThroughId, string relationships) =>
    zoneType + " S&D zone" +
     "\nS&D origin: " + originDate +
     "\nZone price: " + lowText + " → " + highText +
     (str.length(displayedThroughId) > 0 ? "\nDisplayed through: " + displayedThroughId : "") +
     (str.length(relationships) > 0 ? "\n\nObject relationships\n\n" + relationships : "\n\nObject relationships: None")

export npaSourceBlock(string header, string pairText, string lowText, string highText, string heightText, string moveText, string livePositionText) =>
    relationshipGeometryBlock(header, "", pairText, "Range", lowText, highText, heightText, moveText, livePositionText, "", "")

export npaTooltip(string sideText, string percentText, string priceText, string sources) =>
    "Nearest PA Geometry · " + sideText + "\n" + percentText + " · " + priceText + "\n\nSource relationships\n\n" + sources

//==============================================================================
// SESSION FORENSIC PRESENTATION
//==============================================================================
// AE chooses the session occurrence and AE reference geometry first. These helpers only perform
// generic coordinate arithmetic and render those already-decided facts as user-visible text.

sessionSigned(float value) =>
    na(value) ? "N/A" : (value > 0 ? "+" : "") + str.tostring(value, "#.##")

sessionTimeText(int openTime, int closeTime, int observedTime, bool liveOccurrence, string timezone) =>
    string result = str.format_time(openTime, "dd MMM yyyy HH:mm", timezone) + " → " + str.format_time(closeTime, "dd MMM yyyy HH:mm", timezone) + " · " + timezone
    if liveOccurrence and not na(observedTime)
        result += "\nObserved through: " + str.format_time(observedTime, "dd MMM yyyy HH:mm", timezone)
    result

sessionWidthText(float low, float high) =>
    float width = high - low
    float midpoint = (high + low) * 0.5
    str.tostring(width, format.mintick) + (midpoint > 0 ? " · " + str.tostring(width / midpoint * 100.0, "#.##") + "%" : "")

export sessionRangeRelationText(float sessionLow, float sessionHigh, float geometryLow, float geometryHigh) =>
    float span = geometryHigh - geometryLow
    not na(sessionLow) and not na(sessionHigh) and not na(geometryLow) and not na(geometryHigh) and span > 0 ?
     str.tostring((sessionLow - geometryLow) / span * 100.0, "#.##") + "%→" + str.tostring((sessionHigh - geometryLow) / span * 100.0, "#.##") + "%" : ""

sessionGeometryClass(float sessionLow, float sessionHigh, float geometryLow, float geometryHigh) =>
    sessionHigh < geometryLow ? "Wholly below 0%" :
     sessionLow > geometryHigh ? "Wholly above 100%" :
     sessionLow < geometryLow and sessionHigh > geometryHigh ? "Spans below 0% through above 100%" :
     sessionLow < geometryLow ? "Extends below 0% into 0–100%" :
     sessionHigh > geometryHigh ? "Extends above 100% from 0–100%" : "Contained inside 0–100%"

sessionQuartileEnvelopeText(float sessionLow, float sessionHigh, float geometryLow, float geometryHigh) =>
    float span = geometryHigh - geometryLow
    string levels = ""
    if span > 0
        for levelIndex = 0 to 4
            float levelPrice = geometryLow + span * float(levelIndex) * 0.25
            if sessionLow <= levelPrice and sessionHigh >= levelPrice
                string token = levelIndex == 0 ? "0" : levelIndex == 1 ? "25" : levelIndex == 2 ? "50" : levelIndex == 3 ? "75" : "100"
                levels += (str.length(levels) > 0 ? " / " : "") + token
    str.length(levels) > 0 ? levels + "%" : "None"

export sessionForensicTooltip(
     string code, bool liveOccurrence,
     int openTime, int scheduledCloseTime, int observedTime, string timezone,
     float sessionLow, float sessionHigh, float currentPrice,
     string geometryId, float geometryLow, float geometryHigh,
     bool hasPrior, int priorOpenTime, int priorCloseTime, float priorLow, float priorHigh,
     string clockStandard
 ) =>
    float sessionSpan = sessionHigh - sessionLow
    float sessionMid = (sessionHigh + sessionLow) * 0.5
    int duration = scheduledCloseTime - openTime
    int observed = liveOccurrence and not na(observedTime) ? observedTime : scheduledCloseTime
    string progressText = duration > 0 ? str.tostring(math.max(0.0, math.min(100.0, float(observed - openTime) / float(duration) * 100.0)), "#.##") + "%" : "N/A"
    string paText = sessionSpan > 0 and not na(currentPrice) ? str.tostring((currentPrice - sessionLow) / sessionSpan * 100.0, "#.##") + "% of session H-L · " + (currentPrice < sessionLow ? "below L" : currentPrice > sessionHigh ? "above H" : "inside H-L") : "N/A"
    string tooltip = (liveOccurrence ? "Developing " : "Completed ") + code + " session" +
         "\nOccurrence: " + sessionTimeText(openTime, scheduledCloseTime, observedTime, liveOccurrence, timezone) +
         "\nH-L: " + str.tostring(sessionLow, format.mintick) + "→" + str.tostring(sessionHigh, format.mintick) +
         "\nMidpoint: " + str.tostring(sessionMid, format.mintick) +
         "\nRange width: " + sessionWidthText(sessionLow, sessionHigh) +
         "\nTime progress: " + progressText +
         "\nCurrent PA: " + paText

    float geometrySpan = geometryHigh - geometryLow
    if not na(geometryLow) and not na(geometryHigh) and geometrySpan > 0
        string relation = sessionRangeRelationText(sessionLow, sessionHigh, geometryLow, geometryHigh)
        float overlap = math.max(0.0, math.min(sessionHigh, geometryHigh) - math.max(sessionLow, geometryLow))
        float overlapAEPct = overlap / geometrySpan * 100.0
        float overlapSessionPct = sessionSpan > 0 ? overlap / sessionSpan * 100.0 : 0.0
        float belowPct = math.max(0.0, geometryLow - sessionLow) / geometrySpan * 100.0
        float abovePct = math.max(0.0, sessionHigh - geometryHigh) / geometrySpan * 100.0
        string refText = str.length(geometryId) > 0 ? geometryId : "AE geometry"
        refText += " · " + str.tostring(geometryLow, format.mintick) + "→" + str.tostring(geometryHigh, format.mintick)
        tooltip += "\n\nAE Reference · " + refText +
             "\nSession position: " + relation +
             "\nClassification: " + sessionGeometryClass(sessionLow, sessionHigh, geometryLow, geometryHigh) +
             "\nSession midpoint: " + str.tostring((sessionMid - geometryLow) / geometrySpan * 100.0, "#.##") + "%" +
             "\nSession width / AE width: " + str.tostring(sessionSpan / geometrySpan * 100.0, "#.##") + "%" +
             "\nAE overlap: " + str.tostring(overlap, format.mintick) + " · " + str.tostring(overlapAEPct, "#.##") + "% of AE · " + str.tostring(overlapSessionPct, "#.##") + "% of session" +
             "\nExternal excursion: below 0% " + str.tostring(belowPct, "#.##") + "% AE · above 100% " + str.tostring(abovePct, "#.##") + "% AE" +
             "\nAE levels inside session H-L envelope: " + sessionQuartileEnvelopeText(sessionLow, sessionHigh, geometryLow, geometryHigh)
    else
        tooltip += "\n\nAE Reference · unavailable"

    if hasPrior and not na(priorLow) and not na(priorHigh)
        float priorSpan = priorHigh - priorLow
        float priorMid = (priorHigh + priorLow) * 0.5
        float priorOverlap = math.max(0.0, math.min(sessionHigh, priorHigh) - math.max(sessionLow, priorLow))
        string priorClass = sessionLow > priorHigh ? "Wholly above prior H-L" : sessionHigh < priorLow ? "Wholly below prior H-L" : sessionHigh > priorHigh and sessionLow < priorLow ? "Expanded both sides" : sessionHigh > priorHigh ? "Extended above prior H" : sessionLow < priorLow ? "Extended below prior L" : "Contained by prior H-L"
        string widthChange = priorSpan > 0 ? sessionSigned((sessionSpan - priorSpan) / priorSpan * 100.0) + "%" : "N/A"
        string midShift = priorSpan > 0 ? sessionSigned((sessionMid - priorMid) / priorSpan * 100.0) + "% of prior range" : "N/A"
        string overlapText = str.tostring(priorOverlap, format.mintick) + " · " + str.tostring(priorSpan > 0 ? priorOverlap / priorSpan * 100.0 : 0.0, "#.##") + "% prior · " + str.tostring(sessionSpan > 0 ? priorOverlap / sessionSpan * 100.0 : 0.0, "#.##") + "% current"
        tooltip += "\n\nVs prior " + code +
             "\nPrior occurrence: " + sessionTimeText(priorOpenTime, priorCloseTime, na, false, timezone) +
             "\nPrior H-L: " + str.tostring(priorLow, format.mintick) + "→" + str.tostring(priorHigh, format.mintick) +
             "\nRelationship: " + priorClass +
             "\nRange-width change: " + widthChange +
             "\nMidpoint shift: " + midShift +
             "\nH-L overlap: " + overlapText

    tooltip += "\n\nClock standard: " + clockStandard
    tooltip

//==============================================================================
// AE SESSION CONTEXT — USER-VISIBLE COPY ONLY
//==============================================================================

export const string TT_ENABLE_SESSION_CONTEXT = "Adds canonical XZ session/overlap context to AE presentation and forensic surfaces. Session context is descriptive only: it never creates, validates, ranks, archives or otherwise changes C#/R#/L#, XZ Market Structure, XZ Supply & Demand or Auction authority."
export const string TT_SESSION_STANDARD = "Clock standard used only for descriptive AE session context. Market Centres (FX) uses the canonical Sydney/Tokyo/London/New York market-centre windows. Exchange Cash Hours uses each centre's canonical cash-session schedule, including the Tokyo lunch break. IANA timezone/DST authority comes from XZ Session Authority. Exchange Cash Hours does not infer exchange holidays or early closes on unrelated symbols."
export const string ST_SESSION_LABEL_TIP = "Selected canonical session context. Live uses the current developing occurrence; Last uses that session’s most recent completed retained occurrence. Hover for detailed session/AE relationship telemetry."

export sessionStatusTooltip(string standard, string contextText) =>
    "Standard: " + standard + "\nContext: " + contextText + "\nClock authority: XZ Session Authority"
//==============================================================================
// AE SESSION RANGE CONTEXT — USER-VISIBLE COPY ONLY
//==============================================================================

export const string TT_SHOW_SESSION_RANGES = "Draws bounded developing/completed High-Low frames for the selected canonical sessions. Frames are descriptive chart context only; they never participate in Candidate qualification, Range authority, lifecycle, hierarchy, XZ Market Structure or XZ Supply & Demand decisions."
export const string TT_SESSION_HISTORY_OCCURRENCES = "Maximum recent occurrences retained for each selected session in the chart context. Allowed 1–20 · Default 5. This is a display-history limit only and does not change analytical history."
export const string TT_SESSION_SHOW_CODES = "Shows compact SYD/TYO/LDN/NY identifiers on Session High-Low frames. In AE the visible code itself is the hover target for that exact occurrence’s timing, H-L, activity metrics, current/focused AE relationship and prior-same-session comparison."
export const string TT_SESSION_FRAME_TRANSPARENCY = "Transparency of Session High-Low frame presentation. Allowed 70–98 · Default 92. Higher values make session context quieter behind AE geometry."
export const string TT_SESSION_MARKET_TOGGLE = "Selects this canonical market session for AE Session Context. The selection controls its Expanded Status row and, when Session High-Low Frames are enabled, its bounded chart frames. Selection never changes the canonical session clock or any AE/MS/S&D analytical state."
````
