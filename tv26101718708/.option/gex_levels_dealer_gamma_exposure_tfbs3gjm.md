# GEX Levels - Dealer Gamma Exposure 

- url: https://www.tradingview.com/script/TfBS3GjM-GEX-Levels-Dealer-Gamma-Exposure/
- type: indicator
- pine_id: PUB;637ce7618c904f0fbe06add5790e4b1d
- version: 9.0

## Description

GEX DAILY LEVELS — Dealer Gamma Exposure Levels

This indicator plots dealer gamma exposure (GEX) levels as horizontal lines, computed from index option chain data and supplied via a compact text string. It is designed for NQ/NDX but works with any instrument given matching data.

█ METHODOLOGY

The levels follow the standard "naive" dealer positioning convention (dealers long calls, short puts). Per-strike net GEX = gamma × open interest × contract multiplier × spot² × 1%, summed with calls positive and puts negative.

- Call Wall / Put Wall — strikes holding the maximum positive / most negative net GEX across expiries. Dealer hedging around these strikes dampens moves toward them in positive gamma (pinning) and defines major resistance/support.
- 0DTE Walls — the same computation restricted to the current session's expiry, isolating the most reactive intraday hedging flows.
- Gamma Flip — the spot level where aggregate dealer gamma changes sign, obtained by recomputing Black-Scholes gamma across a grid of hypothetical spot prices. Above it, hedging is mean-reverting; below it, hedging amplifies moves.
- Expected Move — the at-the-money straddle price for the nearest expiry: the move the options market is pricing for the day. Fractional bands (e.g. ±50%, ±150% of the straddle) are included because the straddle approximates 0.8 standard deviations, giving each band a defined statistical meaning.
- 1D Min/Max — the one-day range implied by annualized ATM volatility (IV/√252), a complementary volatility-based estimate.
- Max Pain — the strike minimizing total option holder payout at the nearest expiry.
- G+/G− — remaining top strikes ranked by absolute net GEX.

█ WHY A TEXT STRING INPUT

Open interest is static intraday, so gamma levels are constant for the session. Injecting them as data rather than recomputing on chart makes the indicator repaint-free, lookahead-free and provider-agnostic: any gamma data source, or your own option-chain computation, can feed it.

Format: price,label,kind;price,label,kind;...
Kind codes: res, sup (walls) · res0, sup0 (0DTE walls) · flip · emh, eml (expected move) · emb (fractional bands) · ivh, ivl (1D range) · mpain · gpos, gneg
Example: 21100.0,Call Wall,res;20950.5,Gamma Flip,flip;20800.0,Put Wall,sup

█ FEATURES

- Per-family styling: visibility, color, width (1–5), line style for each level type
- Alerts on price crossing walls, 0DTE walls or the gamma flip
- Proximity table showing the nearest level above and below current price with distances
- Label size, offset and price display options

█ LIMITATIONS

Levels are a pre-session snapshot; walls do not move intraday since open interest is settled overnight. The gamma flip may legitimately be absent in strongly positive gamma regimes. Educational tool; nothing here is financial advice.

## Source Code

````pine
//@version=6
indicator("GEX Daily Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)
// ============================================================================
// GEX Daily Levels
// Plots externally computed dealer gamma exposure (GEX) levels from a compact
// text string. Format: price,label,kind;price,label,kind;...
// kinds: res/sup (Call/Put Wall) . res0/sup0 (0DTE walls) . flip (Gamma Flip)
//                  emh/eml (ATM straddle Expected Move) . emb (fractional EM bands)
//                  ivh/ivl (IV-based 1D range) . mpain (Max Pain) . gpos/gneg (top gamma)
//                  opo/opu/opd (Daily Open anchor and +/- ATR-multiple grid from the open)
//                  hgex (dominant absolute gamma strike — the session's main magnet)
// Levels can come from any gamma data source or your own option-chain math.
// script now work fully with the Chrome Extension to past automatically every level.
// ============================================================================
const string TIP = "Format: price,label,kind;price,label,kind;... See the script description for the full format specification and kind codes."
const string GM = "Familles (mêmes groupes que le dashboard)"
bool mGEX    = input.bool(true, "GEX — walls · 0DTE · flip · HGEX · Max Pain · G±", group = GM)
bool mEM      = input.bool(true, "EM · 1D — expected move · bandes · 1D min/max", group = GM)
bool mOPEN = input.bool(true, "Open — Daily O · grille ATR", group = GM)
f_master(string k) =>
    switch k
        "res"      => mGEX
        "sup"      => mGEX
        "res0"    => mGEX
        "sup0"    => mGEX
        "flip"    => mGEX
        "hgex"    => mGEX
        "mpain" => mGEX
        "gpos"    => mGEX
        "gneg"    => mGEX
        "emh"      => mEM
        "eml"      => mEM
        "emb"      => mEM
        "ivh"      => mEM
        "ivl"      => mEM
        "opo"      => mOPEN
        "opu"      => mOPEN
        "opd"      => mOPEN
        => true
string market = input.string("Auto", "Market", options = ["Auto", "NQ", "ES", "SPX", "GOLD GC", "GOLD XAUUSD"], tooltip = "Auto picks the right levels string from the chart symbol: NQ/MNQ/NDX -> NQ, ES/MES -> ES, SPX/SP500 -> SPX, GC/MGC futures -> GOLD GC, XAUUSD/spot gold -> GOLD XAUUSD. Force a market if needed.")
string srcNQ    = input.string(defval = "", title = "NQ — levels string", tooltip = TIP)
string srcES    = input.string(defval = "", title = "ES — levels string", tooltip = TIP)
string srcSPX = input.string(defval = "", title = "SPX — levels string", tooltip = TIP)
string srcGC    = input.string(defval = "", title = "GOLD GC — levels string", tooltip = TIP)
string srcXAU = input.string(defval = "", title = "GOLD XAUUSD — levels string", tooltip = TIP)
const string GQUICK = "Manual Levels — Quick Control"
bool usePastedLevels = input.bool(true, "Use pasted levels", group = GQUICK, tooltip = "Switch off to instantly hide every pasted level and clear the HUD calculation without deleting the saved strings. Switch it back on to restore them.")
const string GOR = "Ajustement de prix"
// ─────────── Décalage manuel ───────────
// Utile si ton flux diffère de la référence (courtier CFD, contrat different).
// Laisse a 0 dans le cas normal : les deux echelles de l'or sont deja
// calculees a la source par gexdash, une correction ici les fausserait.
float pxOff = input.float(0.0, "Décalage manuel des niveaux ($)", step = 0.1, group = GOR, tooltip = "0 = aucune correction. Les strings GC et XAUUSD sont deja a la bonne echelle : n'utilise ce champ que si ton flux de prix diverge de la reference.")
f_market() =>
    string m = market
    if m == "Auto"
        string sym = str.upper(syminfo.root + " " + syminfo.ticker)
        bool isGoldFut = syminfo.type == "futures" and (str.contains(sym, "GC") or str.contains(sym, "MGC"))
        m := isGoldFut ? "GOLD GC" : str.contains(sym, "XAU") or str.contains(sym, "GOLD") ? "GOLD XAUUSD" : str.contains(sym, "NQ") or str.contains(sym, "NDX") or str.contains(sym, "US100") or str.contains(sym, "USTEC") ? "NQ" : str.contains(sym, "SPX") or str.contains(sym, "SP500") ? "SPX" : str.contains(sym, "ES") or str.contains(sym, "US500") ? "ES" : "NQ"
    m
string selectedSrc = f_market() == "ES" ? srcES : f_market() == "SPX" ? srcSPX : f_market() == "GOLD GC" ? srcGC : f_market() == "GOLD XAUUSD" ? srcXAU : srcNQ
string src = usePastedLevels ? selectedSrc : ""
// ---- global ----------------------------------------------------------------
const string GG = "Global"
bool      gShowLbl = input.bool(true, "Labels", group = GG, inline = "g1")
string gSize         = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Custom"], group = GG, inline = "g1")
int         gOff          = input.int(8, "Décalage (barres)", minval = 0, maxval = 200, group = GG, inline = "g1")
int gCustomSize = input.int(36, "Custom size", minval = 6, maxval = 72, step = 2, group = GG, tooltip = "Used when Text size is set to Custom. Increase up to 72 for improved readability.")
bool gPrice = input.bool(true, "Prix dans le label", group = GG, inline = "g2")
string gLabelPos = input.string("Above", "Label position", options = ["Above", "Centered", "Below"], group = GG, inline = "g2", tooltip = "Places label text above, centered on, or below the exact level price. This only changes the visual position of the text.")
// ---- premium rendering -------------------------------------------------------
const string GR = "Display — Lines"
string lineRenderMode = input.string("Subtle Glow", "Render mode", options = ["Clean", "Subtle Glow", "Focus Glow"], group = GR, tooltip = "Clean is the most restrained preset. Subtle Glow adds soft depth. Focus Glow adds a stronger two-layer halo for important displays.")
int glowSpread = input.int(2, "Glow spread", minval = 1, maxval = 8, group = GR, inline = "glow")
int glowIntensity = input.int(35, "Intensity", minval = 20, maxval = 100, group = GR, inline = "glow", tooltip = "Controls the visibility of the glow without changing the precise core line.")
string lineExtendMode = input.string("Both", "Line extension", options = ["Both", "Right"], group = GR)
const string GL_STYLE = "Display — Level Labels"
string gLabelTheme = input.string("Minimal", "Label style", options = ["Minimal", "Glass", "Tinted"], group = GL_STYLE, inline = "lbl1")
string gLabelFont = input.string("Default", "Font", options = ["Default", "Monospace"], group = GL_STYLE, inline = "lbl1")
bool gLabelBold = input.bool(false, "Bold", group = GL_STYLE, inline = "lbl1")
string gLabelTextMode = input.string("Level color", "Text", options = ["Level color", "White"], group = GL_STYLE, inline = "lbl2")
bool gLabelMarker = input.bool(false, "Show ◆ symbol", group = GL_STYLE, inline = "lbl2", tooltip = "Optional visual accent before each level name. Disabled by default for a cleaner chart.")
string gLabelSeparator = input.string(" · ", "Separator", options = [" · ", " | ", "  "], group = GL_STYLE, inline = "lbl2")
color gLabelBgColor = input.color(#101318, "Glass background", group = GL_STYLE, inline = "lbl3")
int gLabelBgTransparency = input.int(22, "Transparency", minval = 0, maxval = 100, group = GL_STYLE, inline = "lbl3", tooltip = "0 is fully opaque; 100 is fully transparent.")
int gLabelTintTransparency = input.int(84, "Tint transparency", minval = 0, maxval = 100, group = GL_STYLE, tooltip = "Used by the Tinted label style.")
// ---- level appearance: [visible] [color] [width] [style] ---------------------
const string GN_KEY    = "Levels — Key GEX"
const string GN_EM      = "Levels — Expected Move & Range"
const string GN_GAMMA = "Levels — Gamma Structure"
const string GN_OPEN   = "Levels — Open & ATR Grid"
const string SOL = "Solide", DSH = "Tirets", DOT = "Points"
bool      shRes = input.bool(true, "Call Wall             ", group = GN_KEY, inline = "res")
color    cRes    = input.color(#26A69A, "", group = GN_KEY, inline = "res")
int         wRes    = input.int(1, "", minval = 1, maxval = 5, group = GN_KEY, inline = "res")
string sRes    = input.string(SOL, "", options = [SOL, DSH, DOT], group = GN_KEY, inline = "res")
bool      shSup = input.bool(true, "Put Wall               ", group = GN_KEY, inline = "sup")
color    cSup    = input.color(#EF5350, "", group = GN_KEY, inline = "sup")
int         wSup    = input.int(1, "", minval = 1, maxval = 5, group = GN_KEY, inline = "sup")
string sSup    = input.string(SOL, "", options = [SOL, DSH, DOT], group = GN_KEY, inline = "sup")
bool      shRes0 = input.bool(true, "Call Wall 0DTE ", group = GN_KEY, inline = "res0")
color    cRes0    = input.color(#26A69A, "", group = GN_KEY, inline = "res0")
int         wRes0    = input.int(1, "", minval = 1, maxval = 5, group = GN_KEY, inline = "res0")
string sRes0    = input.string(DSH, "", options = [SOL, DSH, DOT], group = GN_KEY, inline = "res0")
bool      shSup0 = input.bool(true, "Put Wall 0DTE    ", group = GN_KEY, inline = "sup0")
color    cSup0    = input.color(#EF5350, "", group = GN_KEY, inline = "sup0")
int         wSup0    = input.int(1, "", minval = 1, maxval = 5, group = GN_KEY, inline = "sup0")
string sSup0    = input.string(DSH, "", options = [SOL, DSH, DOT], group = GN_KEY, inline = "sup0")
bool      shFlip = input.bool(true, "Gamma Flip          ", group = GN_KEY, inline = "flip")
color    cFlip    = input.color(#F0B90B, "", group = GN_KEY, inline = "flip")
int         wFlip    = input.int(1, "", minval = 1, maxval = 5, group = GN_KEY, inline = "flip")
string sFlip    = input.string(DSH, "", options = [SOL, DSH, DOT], group = GN_KEY, inline = "flip")
bool      shEM = input.bool(true, "Expected Move    ", group = GN_EM, inline = "em")
color    cEM    = input.color(#E8E6E1, "", group = GN_EM, inline = "em")
int         wEM    = input.int(1, "", minval = 1, maxval = 5, group = GN_EM, inline = "em")
string sEM    = input.string(DOT, "", options = [SOL, DSH, DOT], group = GN_EM, inline = "em")
bool      shEMB = input.bool(true, "EM Bands ±x%      ", group = GN_EM, inline = "emb")
color    cEMB    = input.color(#E8E6E180, "", group = GN_EM, inline = "emb")
int         wEMB    = input.int(1, "", minval = 1, maxval = 5, group = GN_EM, inline = "emb")
string sEMB    = input.string(DOT, "", options = [SOL, DSH, DOT], group = GN_EM, inline = "emb")
bool      shIV = input.bool(true, "1D Min/Max (IV)", group = GN_EM, inline = "iv")
color    cIV    = input.color(#7A7A85, "", group = GN_EM, inline = "iv")
int         wIV    = input.int(1, "", minval = 1, maxval = 5, group = GN_EM, inline = "iv")
string sIV    = input.string(DOT, "", options = [SOL, DSH, DOT], group = GN_EM, inline = "iv")
bool      shHG    = input.bool(true, "HGEX                        ", group = GN_GAMMA, inline = "hg")
color    cHG      = input.color(#F0B90B, "", group = GN_GAMMA, inline = "hg")
int         wHG      = input.int(2, "", minval = 1, maxval = 5, group = GN_GAMMA, inline = "hg")
string sHG      = input.string(SOL, "", options = [SOL, DSH, DOT], group = GN_GAMMA, inline = "hg")
bool      shMP = input.bool(true, "Max Pain               ", group = GN_GAMMA, inline = "mp")
color    cMP    = input.color(#F0B90B80, "", group = GN_GAMMA, inline = "mp")
int         wMP    = input.int(1, "", minval = 1, maxval = 5, group = GN_GAMMA, inline = "mp")
string sMP    = input.string(DOT, "", options = [SOL, DSH, DOT], group = GN_GAMMA, inline = "mp")
bool      shGp = input.bool(true, "G+ (top gamma) ", group = GN_GAMMA, inline = "gp")
color    cGp    = input.color(#26A69A80, "", group = GN_GAMMA, inline = "gp")
int         wGp    = input.int(1, "", minval = 1, maxval = 5, group = GN_GAMMA, inline = "gp")
string sGp    = input.string(SOL, "", options = [SOL, DSH, DOT], group = GN_GAMMA, inline = "gp")
bool      shGn = input.bool(true, "G- (top gamma) ", group = GN_GAMMA, inline = "gn")
color    cGn    = input.color(#EF535080, "", group = GN_GAMMA, inline = "gn")
int         wGn    = input.int(1, "", minval = 1, maxval = 5, group = GN_GAMMA, inline = "gn")
string sGn    = input.string(SOL, "", options = [SOL, DSH, DOT], group = GN_GAMMA, inline = "gn")
bool      shOPG = input.bool(true, "Open ATR grid    ", group = GN_OPEN, inline = "opg")
color    cOPG    = input.color(#F0B90B, "", group = GN_OPEN, inline = "opg")
int         wOPG    = input.int(1, "", minval = 1, maxval = 5, group = GN_OPEN, inline = "opg")
string sOPG    = input.string(DOT, "", options = [SOL, DSH, DOT], group = GN_OPEN, inline = "opg")
// ---- lookups -----------------------------------------------------------------
f_show_family(string k) =>
    switch k
        "res"      => shRes
        "res0"    => shRes0
        "sup"      => shSup
        "sup0"    => shSup0
        "flip"    => shFlip
        "emh"      => shEM
        "eml"      => shEM
        "emb"      => shEMB
        "ivh"      => shIV
        "ivl"      => shIV
        "mpain" => shMP
        "gpos"    => shGp
        "gneg"    => shGn
        "hgex"    => shHG
        "opo"      => shOPG
        "opu"      => shOPG
        "opd"      => shOPG
        => true
f_show(string k) =>
    f_master(k) and f_show_family(k)
f_col(string k) =>
    switch k
        "res"      => cRes
        "res0"    => cRes0
        "sup"      => cSup
        "sup0"    => cSup0
        "flip"    => cFlip
        "emh"      => cEM
        "eml"      => cEM
        "emb"      => cEMB
        "ivh"      => cIV
        "ivl"      => cIV
        "mpain" => cMP
        "gpos"    => cGp
        "gneg"    => cGn
        "hgex"    => cHG
        "opo"      => cOPG
        "opu"      => color.new(#EF5350, 55)
        "opd"      => color.new(#26A69A, 55)
        => color.new(#7A7A85, 30)
f_w(string k) =>
    switch k
        "res"      => wRes
        "res0"    => wRes0
        "sup"      => wSup
        "sup0"    => wSup0
        "flip"    => wFlip
        "emh"      => wEM
        "eml"      => wEM
        "emb"      => wEMB
        "ivh"      => wIV
        "ivl"      => wIV
        "mpain" => wMP
        "gpos"    => wGp
        "gneg"    => wGn
        "hgex"    => wHG
        "opo"      => wOPG
        "opu"      => wOPG
        "opd"      => wOPG
        => 1
f_ls(string s) =>
    s == DSH ? line.style_dashed : s == DOT ? line.style_dotted : line.style_solid
f_style(string k) =>
    string s = switch k
        "res"      => sRes
        "res0"    => sRes0
        "sup"      => sSup
        "sup0"    => sSup0
        "flip"    => sFlip
        "emh"      => sEM
        "eml"      => sEM
        "emb"      => sEMB
        "ivh"      => sIV
        "ivl"      => sIV
        "mpain" => sMP
        "gpos"    => sGp
        "gneg"    => sGn
        "hgex"    => sHG
        "opo"      => sOPG
        "opu"      => sOPG
        "opd"      => sOPG
        => SOL
    f_ls(s)
f_size(string s, int customSize) =>
    s == "Small" ? 10 : s == "Normal" ? 12 : s == "Large" ? 18 : s == "Huge" ? 24 : s == "Custom" ? customSize : 7
f_positioned_text(string txt, string positionMode) =>
    positionMode == "Above" ? txt + "\n" : positionMode == "Below" ? "\n" + txt : txt
f_font_family(string f) =>
    f == "Monospace" ? font.family_monospace : font.family_default
f_text_format(bool bold) =>
    bold ? text.format_bold : text.format_none
f_label_bg(color levelColor) =>
    gLabelTheme == "Glass" ? color.new(gLabelBgColor, gLabelBgTransparency) : gLabelTheme == "Tinted" ? color.new(levelColor, gLabelTintTransparency) : color.new(color.black, 100)
f_label_text(color levelColor) =>
    gLabelTextMode == "White" ? color.white : levelColor
f_line_extend(string mode) =>
    mode == "Right" ? extend.right : extend.both
f_glow_color(color levelColor, float transparency) =>
    color.new(levelColor, math.max(color.t(levelColor), transparency))
// ---- alerts -------------------------------------------------------------------
const string GA = "Alerts — Key Levels"
bool useAlerts = input.bool(true, "Alert on key level cross (walls / 0DTE / flip)", group = GA)
// ---- HUD: layout & level selection --------------------------------------------
const string GH_LAYOUT = "HUD — Layout & Levels"
bool    showTable          = input.bool(true, "Show HUD", group = GH_LAYOUT)
string hudPosition       = input.string("Top Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = GH_LAYOUT)
string hudSize             = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Custom"], group = GH_LAYOUT, inline = "hud_size")
int hudCustomSize = input.int(48, "Custom size", minval = 6, maxval = 72, step = 2, group = GH_LAYOUT, inline = "hud_size", tooltip = "Used when Text size is set to Custom. Increase up to 72 for improved readability.")
string hudLevelScope    = input.string("All levels", "Levels considered", options = ["All levels", "Visible levels", "Key levels only"], group = GH_LAYOUT, tooltip = "All levels: nearest level from the full data string. Visible levels: only level families currently enabled in Settings. Key levels only: Call Wall, Put Wall, 0DTE walls and Gamma Flip.")
// ---- HUD: visible content ------------------------------------------------------
const string GH_CONTENT = "HUD — Content"
bool hudShowTitle         = input.bool(true, "Market title", group = GH_CONTENT, inline = "hud2")
bool hudShowHeaders      = input.bool(true, "Column headers", group = GH_CONTENT, inline = "hud2")
bool hudShowAbove         = input.bool(true, "Nearest above", group = GH_CONTENT, inline = "hud3")
bool hudShowBelow         = input.bool(true, "Nearest below", group = GH_CONTENT, inline = "hud3")
bool hudShowLabel         = input.bool(true, "Level name", group = GH_CONTENT, inline = "hud4")
bool hudShowPrice         = input.bool(true, "Price", group = GH_CONTENT, inline = "hud4")
bool hudShowDistance    = input.bool(true, "Distance (points)", group = GH_CONTENT, inline = "hud5")
bool hudShowPercent      = input.bool(false, "Distance (%)", group = GH_CONTENT, inline = "hud5")
// ---- HUD: appearance -----------------------------------------------------------
const string GH_STYLE = "HUD — Colors & Border"
color hudBgColor          = input.color(#131316D9, "Background", group = GH_STYLE, inline = "hud6")
color hudBorderColor    = input.color(#222228, "Border", group = GH_STYLE, inline = "hud6")
color hudTextColor       = input.color(#E8E6E1, "Values", group = GH_STYLE, inline = "hud7")
color hudMutedColor      = input.color(#7A7A85, "Secondary", group = GH_STYLE, inline = "hud7")
color hudTitleColor      = input.color(#F0B90B, "Title", group = GH_STYLE, inline = "hud8")
color hudAboveColor      = input.color(#26A69A, "Above", group = GH_STYLE, inline = "hud8")
color hudBelowColor      = input.color(#EF5350, "Below", group = GH_STYLE, inline = "hud8")
int    hudBorderWidth    = input.int(1, "Border width", minval = 0, maxval = 3, group = GH_STYLE)
string hudFont = input.string("Monospace", "Font", options = ["Default", "Monospace"], group = GH_STYLE, inline = "hud9")
bool hudBoldValues = input.bool(true, "Bold values", group = GH_STYLE, inline = "hud9")
bool hudTintRows = input.bool(true, "Tint directional rows", group = GH_STYLE, tooltip = "Adds a subtle green/red background to the nearest-above and nearest-below rows.")
f_hud_position(string p) =>
    switch p
        "Top Left"         => position.top_left
        "Top Center"      => position.top_center
        "Middle Left"    => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"   => position.middle_right
        "Bottom Left"    => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"   => position.bottom_right
        => position.top_right
f_hud_size(string s, int customSize) =>
    s == "Small" ? 10 : s == "Normal" ? 14 : s == "Large" ? 20 : s == "Huge" ? 36 : s == "Custom" ? customSize : 8
var array<float>    aP = array.new<float>()
var array<string> aT = array.new<string>()
var array<string> aK = array.new<string>()
if barstate.isfirst and str.length(src) > 0
    array<string> rows0 = str.split(src, ";")
    for r0 in rows0
        array<string> f0 = str.split(r0, ",")
        if array.size(f0) == 3
            float p0 = str.tonumber(array.get(f0, 0))
            if not na(p0)
                // Keep alerts and HUD aligned with the manually shifted chart levels.
                array.push(aP, p0 - pxOff)
                array.push(aT, array.get(f0, 1))
                array.push(aK, array.get(f0, 2))
f_isKey(string k) =>
    k == "res" or k == "sup" or k == "res0" or k == "sup0" or k == "flip"
f_hud_candidate(string k) =>
    hudLevelScope == "Key levels only" ? f_isKey(k) : hudLevelScope == "Visible levels" ? f_show(k) : true
if useAlerts and barstate.isconfirmed and array.size(aP) > 0
    for i = 0 to array.size(aP) - 1
        if f_isKey(array.get(aK, i))
            float lv = array.get(aP, i)
            bool crossUp = close[1] < lv and close >= lv
            bool crossDn = close[1] > lv and close <= lv
            if crossUp or crossDn
                alert("GEX level cross: " + array.get(aT, i) + " @ " + str.tostring(lv, format.mintick) + (crossUp ? " (up)" : " (down)"), alert.freq_once_per_bar)
// Four optional content columns and up to four rows (title, headers, above, below).
var table tb = table.new(position.top_right, 4, 4, bgcolor = hudBgColor, border_width = hudBorderWidth, border_color = hudBorderColor)
if barstate.islast
    table.clear(tb, 0, 0, 3, 3)
    table.set_position(tb, f_hud_position(hudPosition))
    table.set_bgcolor(tb, hudBgColor)
    table.set_border_color(tb, hudBorderColor)
    table.set_border_width(tb, hudBorderWidth)
    if showTable and array.size(aP) > 0
        float bestUp = na
        float bestDn = na
        string upT = ""
        string dnT = ""
        for i = 0 to array.size(aP) - 1
            float lv = array.get(aP, i)
            string kind = array.get(aK, i)
            if f_hud_candidate(kind)
                if lv >= close and (na(bestUp) or lv < bestUp)
                    bestUp := lv
                    upT := array.get(aT, i)
                if lv <= close and (na(bestDn) or lv > bestDn)
                    bestDn := lv
                    dnT := array.get(aT, i)
        int hudTxtSize = f_hud_size(hudSize, hudCustomSize)
        string hudFontFamily = f_font_family(hudFont)
        color hudAboveBg = hudTintRows ? color.new(hudAboveColor, 90) : color.new(hudBgColor, 100)
        color hudBelowBg = hudTintRows ? color.new(hudBelowColor, 90) : color.new(hudBgColor, 100)
        int row = 0
        if hudShowTitle
            table.cell(tb, 0, row, "GEX  •  " + f_market(), text_color = hudTitleColor, text_size = hudTxtSize, bgcolor = color.new(hudTitleColor, 92), text_font_family = hudFontFamily, text_formatting = text.format_bold)
            row += 1
        if hudShowHeaders
            int headerCol = 0
            if hudShowLabel
                table.cell(tb, headerCol, row, "LEVEL", text_color = hudMutedColor, text_size = hudTxtSize, text_font_family = hudFontFamily)
                headerCol += 1
            if hudShowPrice
                table.cell(tb, headerCol, row, "PRICE", text_color = hudMutedColor, text_size = hudTxtSize, text_font_family = hudFontFamily)
                headerCol += 1
            if hudShowDistance
                table.cell(tb, headerCol, row, "DIST", text_color = hudMutedColor, text_size = hudTxtSize, text_font_family = hudFontFamily)
                headerCol += 1
            if hudShowPercent
                table.cell(tb, headerCol, row, "%", text_color = hudMutedColor, text_size = hudTxtSize, text_font_family = hudFontFamily)
            row += 1
        if hudShowAbove and not na(bestUp)
            int upCol = 0
            if hudShowLabel
                table.cell(tb, upCol, row, "▲  " + upT, text_color = hudAboveColor, text_size = hudTxtSize, bgcolor = hudAboveBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                upCol += 1
            if hudShowPrice
                table.cell(tb, upCol, row, str.tostring(bestUp, format.mintick), text_color = hudTextColor, text_size = hudTxtSize, bgcolor = hudAboveBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                upCol += 1
            if hudShowDistance
                table.cell(tb, upCol, row, "+" + str.tostring(bestUp - close, "#.#"), text_color = hudMutedColor, text_size = hudTxtSize, bgcolor = hudAboveBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                upCol += 1
            if hudShowPercent
                table.cell(tb, upCol, row, "+" + str.tostring((bestUp - close) / close * 100, "#.##") + "%", text_color = hudMutedColor, text_size = hudTxtSize, bgcolor = hudAboveBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
            row += 1
        if hudShowBelow and not na(bestDn)
            int dnCol = 0
            if hudShowLabel
                table.cell(tb, dnCol, row, "▼  " + dnT, text_color = hudBelowColor, text_size = hudTxtSize, bgcolor = hudBelowBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                dnCol += 1
            if hudShowPrice
                table.cell(tb, dnCol, row, str.tostring(bestDn, format.mintick), text_color = hudTextColor, text_size = hudTxtSize, bgcolor = hudBelowBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                dnCol += 1
            if hudShowDistance
                table.cell(tb, dnCol, row, str.tostring(bestDn - close, "#.#"), text_color = hudMutedColor, text_size = hudTxtSize, bgcolor = hudBelowBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
                dnCol += 1
            if hudShowPercent
                table.cell(tb, dnCol, row, str.tostring((bestDn - close) / close * 100, "#.##") + "%", text_color = hudMutedColor, text_size = hudTxtSize, bgcolor = hudBelowBg, text_font_family = hudFontFamily, text_formatting = f_text_format(hudBoldValues))
// ---- draw --------------------------------------------------------------------
var array<line>    lns = array.new<line>()
var array<label> lbs = array.new<label>()
if barstate.islast
    for l in lns
        line.delete(l)
    array.clear(lns)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)
    if str.length(src) > 0
        array<string> rows = str.split(src, ";")
        for r in rows
            array<string> f = str.split(r, ",")
            if array.size(f) == 3
                float    p0      = str.tonumber(array.get(f, 0))
                float    p         = na(p0) ? na : p0 - pxOff
                string tag    = array.get(f, 1)
                string kind = array.get(f, 2)
                if not na(p) and f_show(kind)
                    color c = f_col(kind)
                    int coreWidth = f_w(kind)
                    float innerGlowTransparency = math.max(68.0, 94.0 - glowIntensity * 0.25)
                    float outerGlowTransparency = math.max(82.0, 97.0 - glowIntensity * 0.10)
                    if lineRenderMode == "Focus Glow"
                        array.push(lns, line.new(bar_index - 1, p, bar_index, p, extend = f_line_extend(lineExtendMode), color = f_glow_color(c, outerGlowTransparency), width = coreWidth + glowSpread * 2, style = line.style_solid))
                    if lineRenderMode == "Subtle Glow" or lineRenderMode == "Focus Glow"
                        array.push(lns, line.new(bar_index - 1, p, bar_index, p, extend = f_line_extend(lineExtendMode), color = f_glow_color(c, innerGlowTransparency), width = coreWidth + glowSpread, style = line.style_solid))
                    array.push(lns, line.new(bar_index - 1, p, bar_index, p, extend = f_line_extend(lineExtendMode), color = c, width = coreWidth, style = f_style(kind)))
                    if gShowLbl
                        string displayTag = gLabelMarker ? "◆  " + tag : tag
                        string rawText = gPrice ? displayTag + gLabelSeparator + str.tostring(p, format.mintick) : displayTag
                        string positionedText = f_positioned_text(rawText, gLabelPos)
                        array.push(lbs, label.new(bar_index + gOff, p, positionedText, style = label.style_label_left, color = f_label_bg(c), textcolor = f_label_text(c), size = f_size(gSize, gCustomSize), textalign = text.align_left, text_font_family = f_font_family(gLabelFont), text_formatting = f_text_format(gLabelBold)))
````
