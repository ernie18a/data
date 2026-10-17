# Market Dictionary [GBB]

- url: https://www.tradingview.com/script/pBzEazZb-Market-Dictionary-GBB/
- type: indicator
- pine_id: PUB;c5e85cb7a7e144f281a1537ce8a2592d
- version: 1.0

## Description

[b]Can price be translated into a language?[/b]

I wondered if it could. So I built a dictionary for the market. This
indicator is that dictionary — including everything it does NOT say.

How it reads the chart: Every bar, the recent closes are reduced to
their shape and spelled as a short word — a few letters describing where
price sat along the way, from a (lowest zone) up to the top of the
alphabet (highest zone). A sharp drop that goes quiet spells "ddaa". With
short words and a small alphabet, the market has a finite vocabulary:
256 words in the standard config, 6,561 in the long one. Every bar on
your chart is speaking exactly one of them.

[b]The readout:[/b]

The current word translated into plain English:
"THE MARKET JUST SAID: sharp drop, now quiet at the lows" — plus how
many times this exact word has been seen on your chart and how rare
that is. A description of shape, not a signal.
The regime wash. The background tinted by the word's temperature —
toward red when the word lives in the low zones, toward green in the
high zones, stronger when the shape is more extreme.
The letter ribbon. A letter-colored track under price showing the
letter each bar is writing right now. Calm markets babble; you will see
the tone shift.

[b]The Lexicon Panel[/b]

The full dictionary entry: seen-count, rarity
percentile, and causal win rate / average forward return over the next
1, 4 and 16 bars, computed on your chart's history with nothing peeking
into the future — each line carrying its validation verdict. Faint
numbers mean thin data, on purpose: your eyes should trust a statistic
exactly as much as the sample deserves.
Events. When the chart prints a word it has NEVER printed before,
you get a violet flare: "NEVER SEEN BEFORE". And on exactly two
market/timeframe combinations, a gold marker when a study-validated
word completes (more on both below — read the caveats).


[b]
Most words mean nothing[/b]

"no significant edge" is its most common verdict, by design.
Rare words looked like they preceded volatility in-sample on 5 of 7
markets. Out of sample: 0 of 28 configurations passed. The
"NEVER SEEN BEFORE" flare is a curiosity flag, and its own tooltip
tells you rarity's predictive power is not confirmed.
The vocabulary itself is remarkably stable: in 25 of 28 configurations
the word frequencies stayed the same from the research years into the
held-out years. Markets from 2008 and 2025 speak the same language.
It just mostly is not saying anything predictive.
Two words survived everything: "ddaa" on gold H1 (564 out-of-sample
occurrences; remained net-positive after median spread cost in the
study — informational, not a recommendation) and one BTC 1h pattern
that passed at 69% degradation against a 70% cutoff with 38 samples —
the panel labels that one "marginal" because that is what it is.

The surviving edges are breakpoint-fragile: they appear under the
empirically fitted letter boundaries, not under textbook Gaussian ones.
I tell you this because it is a real limitation.

[b]
What this tool is[/b]

A translator, not a signal. It tells you what the
current shape is called, how common it is, and what the record shows,
with the verdict attached to every number. Whether any of that adds
something to YOUR strategy is your test to run — that is not a
disclaimer, it is the design.

[b]Frozen parameters[/b]

The letter boundaries, variance gates, and rarity
thresholds are hardcoded from the validation study (2026-07) and cannot
be edited or refit — there is deliberately no adaptive mode, because
refitting live would detach the display from its validation. Crypto
combos were validated on Binance USDT-M perpetual data; the indicator
accepts the same symbol on other venues since perp prices track closely
across exchanges — the panel tooltip names the exact validated
instrument. The panel's live statistics (seen-counts, win rates,
averages) are built from your chart's visible history; the validation
verdicts are not — they are the study's hardcoded results. On markets
outside the study, the indicator runs in EXPLORER MODE: fully functional,
clearly labeled, and it will never show you a validation star it did not
earn.

[b]No Repainting:[/b] 

Words finalize on bar close; statistics
update only when their forward horizons complete; nothing is drawn on
unconfirmed bars. Don't take my word for it: open bar replay, step
through a session, and try to catch a value changing after its bar
closes.

## Source Code

````pine
//@version=6
// Market Dictionary [GBB] — v1.3
// "I wondered if price could be translated into a language."

indicator("Market Dictionary [GBB]", "Dictionary [GBB]", overlay = true,
     max_boxes_count = 500, max_labels_count = 500,
     max_polylines_count = 100, max_lines_count = 100, max_bars_back = 200)

// ================================ INPUTS ================================
// presets retained in code, selector removed (owner, 2026-07-12)
string preset = "Clear"

grpL = "Language"
cfgIn = input.string("C1 (32/4/4)", "Config", options = ["C1 (32/4/4)", "C2 (64/8/3)"],
     group = grpL, tooltip = "C1: 32-bar window, 4-letter words, 4-letter alphabet (vocabulary 256). C2: 64-bar window, 8-letter words, 3-letter alphabet (vocabulary 6,561). Both fully validated in the study.")

grpD = "Display"
themeIn     = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpD)
bool showStrip  = false
bool showSkel   = false
panelMode   = input.string("On", "Lexicon Panel", options = ["On", "Off"], group = grpD, tooltip = "The panel carries the validation verdicts, study numbers, the Explorer Mode label, and the frozen-breakpoints footer. On by default.")
bool showRibbon = false
panelPos    = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpD)
showWash        = input.bool(true, "Regime wash", group = grpD, tooltip = "Background tinted by the current word's temperature — red in low-zone regimes, green in high-zone. Opacity follows how extreme the word is.")
showLetterRibbon = input.bool(true, "Letter ribbon", group = grpD, tooltip = "A glowing letter-colored track under price showing the letter each bar is writing within its own window.")
showHero    = input.bool(true, "Hero readout", group = grpD, tooltip = "The market's current word translated into plain English. A description of shape, not a signal — the validation verdict lives in the panel.")
heroPos     = input.string("Top center", "Hero position", options = ["Top center", "Top left", "Top right", "Bottom center"], group = grpD)
heroSize    = input.string("Normal", "Hero size", options = ["Small", "Normal", "Large"], group = grpD)
glowIn          = input.string("Standard", "Glow intensity", options = ["Subtle", "Standard", "Maximum"], group = grpD, tooltip = "One control scaling the opacity of every glow layer.")

grpE = "Events"
showSurv    = input.bool(true, "Survivor event markers", group = grpE, tooltip = "Gold box when an OOS-validated word completes. Only ever appears on the exact validated market + timeframe + config.")
showDiscord = input.bool(true, "Discord / novel-word markers", group = grpE, tooltip = "Rarity is real; predictive power is not confirmed. In the study's out-of-sample tests, rare words did NOT reliably precede volatility (0 of 28 markets passed).")
bool showRegime = false

grpA = "Alerts"
dynAlerts = input.bool(false, "Dynamic alert() messages", group = grpA, tooltip = "Fires alert() with the word text on events (needs an 'Any alert() function call' alert). The four fixed alertcondition entries work without this.")

grpX = "Diagnostics"
runSelfTest = input.bool(false, "Run engine self-test (reference vectors)", group = grpX,
     tooltip = "Runs the study's 6 hand-computed reference vectors through the live engine functions and shows PASS/FAIL per vector, both breakpoint modes. This is the Pine side of the parity gate.")

bool cin          = preset == "Cinematic"
bool clr          = preset == "Clear"
bool fShowStrip   = clr ? false : showStrip
bool fShowSkel    = preset == "Linguist" ? true : (preset == "Minimal" or cin or clr ? false : showSkel)
bool fShowRibbon  = preset == "Minimal" or clr ? false : showRibbon
bool fShowSurv    = preset == "Minimal" ? false : showSurv
bool fShowDiscord = preset == "Minimal" ? false : showDiscord
bool fLinguist    = preset == "Linguist"
bool fWash          = (cin or clr) and showWash
bool fLetterRibbon  = (cin or clr) and showLetterRibbon
bool fRegimeStamps  = cin and showRegime
bool fHero          = clr and showHero
bool fShowPanel     = panelMode == "On"
int glowAdj = glowIn == "Subtle" ? 4 : glowIn == "Maximum" ? -6 : 0
glowT(int t) =>
    math.max(0, math.min(97, t + glowAdj))

// =============================== PALETTE ================================
// The alphabet IS the color system 
bool darkTheme = themeIn == "Dark" or (themeIn == "Auto" and color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color) < 384)
color colLA     = darkTheme ? #EF5350 : #C62828   // a  deep low   red
color colLB     = darkTheme ? #42A5F5 : #1565C0   // b  below mid  blue
color colLC     = darkTheme ? #FFB74D : #F57C00   // c  above mid  amber
color colLD     = darkTheme ? #66BB6A : #2E7D32   // d  high       green
color colNull   = darkTheme ? #546E7A : #90A4AE   // null symbol   dim slate
color colGold   = #FFD54F                          // survivor accent
color colViolet = #B388FF                          // novel / discord accent
color colText   = darkTheme ? #ECEFF1 : #263238
color colMuted  = darkTheme ? #78909C : #607D8B
color colPanBg  = darkTheme ? color.new(#131722, 15) : color.new(#FFFFFF, 10)
color colGradLo = #26A69A
color colGradHi = #FF7043

letterChar(int idx) =>
    idx == 0 ? "a" : idx == 1 ? "b" : idx == 2 ? "c" : idx == 3 ? "d" : "?"

gradCol(float t) =>   // single gradient for every intensity encoding
    color.from_gradient(math.max(0.0, math.min(1.0, t)), 0.0, 1.0, colGradLo, colGradHi)

ordinal(float pct) =>
    int p = int(math.round(pct))
    string suf = p % 100 >= 11 and p % 100 <= 13 ? "th" : p % 10 == 1 ? "st" : p % 10 == 2 ? "nd" : p % 10 == 3 ? "rd" : "th"
    str.tostring(p) + suf

// === BEGIN GENERATED CONSTANTS ===


mkFRZ_KEY() =>
    a = array.new<string>()
    array.push(a, "BTCUSDT|15|C1")
    array.push(a, "BTCUSDT|15|C2")
    array.push(a, "BTCUSDT|60|C1")
    array.push(a, "BTCUSDT|60|C2")
    array.push(a, "ETHUSDT|15|C1")
    array.push(a, "ETHUSDT|15|C2")
    array.push(a, "ETHUSDT|60|C1")
    array.push(a, "ETHUSDT|60|C2")
    array.push(a, "SOLUSDT|15|C1")
    array.push(a, "SOLUSDT|15|C2")
    array.push(a, "SOLUSDT|60|C1")
    array.push(a, "SOLUSDT|60|C2")
    array.push(a, "EURUSD|60|C1")
    array.push(a, "EURUSD|60|C2")
    array.push(a, "EURUSD|15|C1")
    array.push(a, "EURUSD|15|C2")
    array.push(a, "GBPUSD|60|C1")
    array.push(a, "GBPUSD|60|C2")
    array.push(a, "GBPUSD|15|C1")
    array.push(a, "GBPUSD|15|C2")
    array.push(a, "USDJPY|60|C1")
    array.push(a, "USDJPY|60|C2")
    array.push(a, "USDJPY|15|C1")
    array.push(a, "USDJPY|15|C2")
    array.push(a, "XAUUSD|60|C1")
    array.push(a, "XAUUSD|60|C2")
    array.push(a, "XAUUSD|15|C1")
    array.push(a, "XAUUSD|15|C2")
    a
var FRZ_KEY = mkFRZ_KEY()
mkFRZ_SMIN() =>
    a = array.new<float>()
    array.push(a, 0.001181391078302428)
    array.push(a, 0.0016745572886195474)
    array.push(a, 0.0025289109226251665)
    array.push(a, 0.004216758087238792)
    array.push(a, 0.001578390923277909)
    array.push(a, 0.002295631792989187)
    array.push(a, 0.0034404764208305484)
    array.push(a, 0.005365727469738582)
    array.push(a, 0.0031179735651066516)
    array.push(a, 0.004582024068953056)
    array.push(a, 0.006815249987926776)
    array.push(a, 0.010823549536496222)
    array.push(a, 0.0007181705079300086)
    array.push(a, 0.0011094821501079098)
    array.push(a, 0.0002639059396038015)
    array.push(a, 0.00044886018420381695)
    array.push(a, 0.0007960056853006326)
    array.push(a, 0.0012254211142455635)
    array.push(a, 0.0002754026113977757)
    array.push(a, 0.00048502079751605576)
    array.push(a, 0.0006808041323198351)
    array.push(a, 0.0010467431111477255)
    array.push(a, 0.0002949797463286282)
    array.push(a, 0.0004491701145721729)
    array.push(a, 0.0012990640888055408)
    array.push(a, 0.0020174824808691138)
    array.push(a, 0.0005284523156816923)
    array.push(a, 0.0008472552060426954)
    a
var FRZ_SMIN = mkFRZ_SMIN()
mkFRZ_FSTAR() =>
    a = array.new<float>()
    array.push(a, 0.0011006790933363567)
    array.push(a, 2.0429165705203838e-05)
    array.push(a, 0.001045563678486436)
    array.push(a, 4.327515006024254e-05)
    array.push(a, 0.0011343663396799883)
    array.push(a, 2.2455106638377508e-05)
    array.push(a, 0.0009553013205668697)
    array.push(a, 4.309011264074523e-05)
    array.push(a, 0.0010364913488494691)
    array.push(a, 2.4175280458124587e-05)
    array.push(a, 0.0010022986837551495)
    array.push(a, 4.7296977723123494e-05)
    array.push(a, 0.0011017443001246653)
    array.push(a, 3.4238558206943396e-05)
    array.push(a, 0.0012012266842179986)
    array.push(a, 1.9870841850017697e-05)
    array.push(a, 0.0009561561455419287)
    array.push(a, 3.2874647004002916e-05)
    array.push(a, 0.0011218967186322898)
    array.push(a, 1.9095266868544352e-05)
    array.push(a, 0.0009032684877445322)
    array.push(a, 3.092513469421445e-05)
    array.push(a, 0.0011537090021672748)
    array.push(a, 2.000736564861494e-05)
    array.push(a, 0.0009420007729492939)
    array.push(a, 3.0864292793673334e-05)
    array.push(a, 0.0012121463919143106)
    array.push(a, 1.989140882126682e-05)
    a
var FRZ_FSTAR = mkFRZ_FSTAR()
mkFRZ_BP_OFS() =>
    a = array.new<int>()
    array.push(a, 0)
    array.push(a, 3)
    array.push(a, 5)
    array.push(a, 8)
    array.push(a, 10)
    array.push(a, 13)
    array.push(a, 15)
    array.push(a, 18)
    array.push(a, 20)
    array.push(a, 23)
    array.push(a, 25)
    array.push(a, 28)
    array.push(a, 30)
    array.push(a, 33)
    array.push(a, 35)
    array.push(a, 38)
    array.push(a, 40)
    array.push(a, 43)
    array.push(a, 45)
    array.push(a, 48)
    array.push(a, 50)
    array.push(a, 53)
    array.push(a, 55)
    array.push(a, 58)
    array.push(a, 60)
    array.push(a, 63)
    array.push(a, 65)
    array.push(a, 68)
    array.push(a, 70)
    a
var FRZ_BP_OFS = mkFRZ_BP_OFS()
mkFRZ_BP() =>
    a = array.new<float>()
    array.push(a, -0.6359953756707581)
    array.push(a, 0.005307568136696805)
    array.push(a, 0.6380366149258854)
    array.push(a, -0.4578962479207906)
    array.push(a, 0.46754898297682207)
    array.push(a, -0.6438325174249756)
    array.push(a, 0.00459020264015611)
    array.push(a, 0.6450029631575551)
    array.push(a, -0.47398520735247646)
    array.push(a, 0.4778245280552562)
    array.push(a, -0.6451178397373466)
    array.push(a, 0.0112422533725159)
    array.push(a, 0.645169096317683)
    array.push(a, -0.4613442133891761)
    array.push(a, 0.4781405954776472)
    array.push(a, -0.659824440976859)
    array.push(a, 0.012844027864962429)
    array.push(a, 0.6642814787036437)
    array.push(a, -0.4699785030937212)
    array.push(a, 0.4869629745708295)
    array.push(a, -0.6595193828444148)
    array.push(a, 0.0029239124152314333)
    array.push(a, 0.6600997365534245)
    array.push(a, -0.47580956028108323)
    array.push(a, 0.4807278704751985)
    array.push(a, -0.669850228949054)
    array.push(a, 9.549701335660049e-05)
    array.push(a, 0.6693724623916286)
    array.push(a, -0.47907486634226326)
    array.push(a, 0.48884519618221983)
    array.push(a, -0.6723879329876163)
    array.push(a, -0.0010426911155229784)
    array.push(a, 0.671796316854156)
    array.push(a, -0.4981868677694681)
    array.push(a, 0.49372345905185844)
    array.push(a, -0.6480729574108967)
    array.push(a, 0.0008952195752160441)
    array.push(a, 0.6462660261363179)
    array.push(a, -0.4727908254338673)
    array.push(a, 0.47432260623102546)
    array.push(a, -0.6713612513427236)
    array.push(a, -0.0009651148827150222)
    array.push(a, 0.6715946482353468)
    array.push(a, -0.49992562940156304)
    array.push(a, 0.49582542408795116)
    array.push(a, -0.6425852469740592)
    array.push(a, 0.0024845463400708576)
    array.push(a, 0.6423113037871839)
    array.push(a, -0.4660167650822931)
    array.push(a, 0.4683628866352717)
    array.push(a, -0.6671306151443894)
    array.push(a, 0.005063008684468122)
    array.push(a, 0.6697852844691955)
    array.push(a, -0.4848168128685279)
    array.push(a, 0.49433237648194606)
    array.push(a, -0.652203350642288)
    array.push(a, 0.0043140815865856386)
    array.push(a, 0.6519639494032722)
    array.push(a, -0.4763263154726505)
    array.push(a, 0.4864343030842934)
    array.push(a, -0.6677703485300329)
    array.push(a, 0.006670426469152765)
    array.push(a, 0.6666235611706827)
    array.push(a, -0.49785198992694)
    array.push(a, 0.5029180165510758)
    array.push(a, -0.6482280128440836)
    array.push(a, 0.003055007630173523)
    array.push(a, 0.6493449967481775)
    array.push(a, -0.46828760849892753)
    array.push(a, 0.47741883321495104)
    a
var FRZ_BP = mkFRZ_BP()

mkSURV_KEY() =>
    a = array.new<string>()
    array.push(a, "BTCUSDT|60|C2")
    array.push(a, "XAUUSD|60|C1")
    a
var SURV_KEY = mkSURV_KEY()
mkSURV_CODE() =>
    a = array.new<int>()
    array.push(a, 476)
    array.push(a, 240)
    a
var SURV_CODE = mkSURV_CODE()
mkSURV_WORD() =>
    a = array.new<string>()
    array.push(a, "aabccbcc")
    array.push(a, "ddaa")
    a
var SURV_WORD = mkSURV_WORD()
mkSURV_H() =>
    a = array.new<int>()
    array.push(a, 16)
    array.push(a, 4)
    a
var SURV_H = mkSURV_H()
mkSURV_IS_EFF() =>
    a = array.new<float>()
    array.push(a, -0.010898737985994313)
    array.push(a, -0.0006602339814137134)
    a
var SURV_IS_EFF = mkSURV_IS_EFF()
mkSURV_OOS_EFF() =>
    a = array.new<float>()
    array.push(a, -0.0033304834011130984)
    array.push(a, -0.0003410387261724142)
    a
var SURV_OOS_EFF = mkSURV_OOS_EFF()
mkSURV_DEGR() =>
    a = array.new<float>()
    array.push(a, 69.4415683229286)
    array.push(a, 48.3457780464175)
    a
var SURV_DEGR = mkSURV_DEGR()
mkSURV_N_OOS() =>
    a = array.new<int>()
    array.push(a, 38)
    array.push(a, 564)
    a
var SURV_N_OOS = mkSURV_N_OOS()
mkSURV_MARGINAL() =>
    a = array.new<bool>()
    array.push(a, true)
    array.push(a, false)
    a
var SURV_MARGINAL = mkSURV_MARGINAL()

mkRV_ID() =>
    a = array.new<string>()
    array.push(a, "rv1_step_up")
    array.push(a, "rv2_step_down")
    array.push(a, "rv3_v_shape_boundary")
    array.push(a, "rv4_ramp")
    array.push(a, "rv5_c2_hill")
    array.push(a, "rv6_flat_null")
    a
var RV_ID = mkRV_ID()
mkRV_N() =>
    a = array.new<int>()
    array.push(a, 32)
    array.push(a, 32)
    array.push(a, 32)
    array.push(a, 32)
    array.push(a, 64)
    array.push(a, 32)
    a
var RV_N = mkRV_N()
mkRV_W() =>
    a = array.new<int>()
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 8)
    array.push(a, 4)
    a
var RV_W = mkRV_W()
mkRV_A() =>
    a = array.new<int>()
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 4)
    array.push(a, 3)
    array.push(a, 4)
    a
var RV_A = mkRV_A()
mkRV_SMIN() =>
    a = array.new<float>()
    array.push(a, 0.0)
    array.push(a, 0.0)
    array.push(a, 0.0)
    array.push(a, 0.0)
    array.push(a, 0.0)
    array.push(a, 0.001)
    a
var RV_SMIN = mkRV_SMIN()
mkRV_OFS() =>
    a = array.new<int>()
    array.push(a, 0)
    array.push(a, 32)
    array.push(a, 64)
    array.push(a, 96)
    array.push(a, 128)
    array.push(a, 192)
    array.push(a, 224)
    a
var RV_OFS = mkRV_OFS()
mkRV_CLOSE() =>
    a = array.new<float>()
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 1.0)
    array.push(a, 2.718281828459045)
    array.push(a, 7.38905609893065)
    array.push(a, 20.085536923187668)
    array.push(a, 54.598150033144236)
    array.push(a, 148.4131591025766)
    array.push(a, 403.4287934927351)
    array.push(a, 1096.6331584284585)
    array.push(a, 2980.9579870417283)
    array.push(a, 8103.083927575384)
    array.push(a, 22026.465794806718)
    array.push(a, 59874.14171519782)
    array.push(a, 162754.79141900392)
    array.push(a, 442413.3920089205)
    array.push(a, 1202604.2841647768)
    array.push(a, 3269017.3724721107)
    array.push(a, 8886110.520507872)
    array.push(a, 24154952.7535753)
    array.push(a, 65659969.13733051)
    array.push(a, 178482300.96318725)
    array.push(a, 485165195.4097903)
    array.push(a, 1318815734.4832146)
    array.push(a, 3584912846.131592)
    array.push(a, 9744803446.248903)
    array.push(a, 26489122129.84347)
    array.push(a, 72004899337.38588)
    array.push(a, 195729609428.83878)
    array.push(a, 532048240601.7986)
    array.push(a, 1446257064291.475)
    array.push(a, 3931334297144.042)
    array.push(a, 10686474581524.463)
    array.push(a, 29048849665247.426)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 20.085536923187668)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 7.38905609893065)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 2.718281828459045)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 1.0)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    array.push(a, 148.4131591025766)
    a
var RV_CLOSE = mkRV_CLOSE()
mkRV_WORD_G() =>
    a = array.new<string>()
    array.push(a, "abcd")
    array.push(a, "dcba")
    array.push(a, "daad")
    array.push(a, "abcd")
    array.push(a, "aaccccaa")
    array.push(a, "NULL")
    a
var RV_WORD_G = mkRV_WORD_G()
mkRV_WORD_E() =>
    a = array.new<string>()
    array.push(a, "bccd")
    array.push(a, "dccb")
    array.push(a, "dccd")
    array.push(a, "bccd")
    array.push(a, "abbccbba")
    array.push(a, "NULL")
    a
var RV_WORD_E = mkRV_WORD_E()
mkRV_BPE_OFS() =>
    a = array.new<int>()
    array.push(a, 0)
    array.push(a, 3)
    array.push(a, 6)
    array.push(a, 9)
    array.push(a, 12)
    array.push(a, 14)
    array.push(a, 17)
    a
var RV_BPE_OFS = mkRV_BPE_OFS()
mkRV_BPE() =>
    a = array.new<float>()
    array.push(a, -1.5)
    array.push(a, -1.0)
    array.push(a, 1.0)
    array.push(a, -1.5)
    array.push(a, -1.0)
    array.push(a, 1.0)
    array.push(a, -1.5)
    array.push(a, -1.0)
    array.push(a, 1.0)
    array.push(a, -1.5)
    array.push(a, -1.0)
    array.push(a, 1.0)
    array.push(a, -1.0)
    array.push(a, 1.0)
    array.push(a, -1.5)
    array.push(a, -1.0)
    array.push(a, 1.0)
    a
var RV_BPE = mkRV_BPE()
// === END GENERATED CONSTANTS ===

// ======================== CONFIG & COMBO MATCHING =======================
bool isC1 = str.startswith(cfgIn, "C1")
int N = isC1 ? 32 : 64
int W = isC1 ? 4 : 8
int A = isC1 ? 4 : 3
int SEG = N / W
int BURN_IN = isC1 ? 500 : 3000
string cfgKey = isC1 ? "C1" : "C2"

// Letter color, alphabet-aware: the TOP letter of the active alphabet is
// always the hot end so C1 and C2 share one temperature scale (a 3-letter
// alphabet otherwise never leaves amber and reads "cooler" side by side).
letterColor(int idx) =>
    idx < 0 ? colNull :
     A == 3 ? (idx == 0 ? colLA : idx == 1 ? colLB : colLD) :
     (idx == 0 ? colLA : idx == 1 ? colLB : idx == 2 ? colLC : colLD)


levOf(string ch) =>
    ch == "a" ? 0 : ch == "b" ? 1 : ch == "c" ? 2 : ch == "d" ? 3 : 0

glossOf(string wrd) =>
    int wl = str.length(wrd)
    float span = math.max(1, A - 1)
    float f = levOf(str.substring(wrd, 0, 1)) / span
    float l = levOf(str.substring(wrd, wl - 1, wl)) / span
    float l2 = levOf(str.substring(wrd, wl - 2, wl - 1)) / span
    float net = l - f
    float maxStep = 0.0
    float eSum = 0.0
    for i = 1 to wl - 1
        float st = math.abs(levOf(str.substring(wrd, i, i + 1)) - levOf(str.substring(wrd, i - 1, i))) / span
        maxStep := math.max(maxStep, st)
        eSum += st
    float energy = eSum / (wl - 1)
    string move = net <= -0.5 ? (maxStep >= 0.67 ? "sharp drop" : "steady slide") :
         net >= 0.5 ? (maxStep >= 0.67 ? "sharp rally" : "steady climb") :
         energy >= 0.4 ? "choppy swing" : "sideways drift"
    bool flatEnd = l == l2
    string tail = l >= 0.66 ? "holding the highs" :
         l <= 0.34 ? (flatEnd ? "now quiet at the lows" : "ending near the lows") :
         flatEnd ? "gone quiet mid-range" : "ending mid-range"
    move + ", " + tail

// Gaussian (Mode G) breakpoints for Explorer Mode
gaussBps(int a) =>
    bps = array.new<float>()
    if a == 4
        array.push(bps, -0.6744897501960817)
        array.push(bps, 0.0)
        array.push(bps, 0.6744897501960817)
    else
        array.push(bps, -0.4307272992954576)
        array.push(bps, 0.4307272992954576)
    bps


matchSymbol(string ticker, string base) =>
    ticker == base or str.startswith(ticker, base + ".") or str.startswith(ticker, base + "_") or str.startswith(ticker, base + "PERP")

findCombo() =>
    int found = -1
    if array.size(FRZ_KEY) > 0
        for i = 0 to array.size(FRZ_KEY) - 1
            parts = str.split(array.get(FRZ_KEY, i), "|")
            if matchSymbol(syminfo.ticker, array.get(parts, 0)) and timeframe.period == array.get(parts, 1) and array.get(parts, 2) == cfgKey
                found := i
                break
    found

var int comboIdx = findCombo()
var bool validated = comboIdx >= 0


mkBPS() =>
    out = gaussBps(A)
    if validated
        out := array.slice(FRZ_BP, array.get(FRZ_BP_OFS, comboIdx), array.get(FRZ_BP_OFS, comboIdx + 1))
    out
var array<float> BPS = mkBPS()
var float SIGMA_MIN_FROZEN = na
var float FSTAR_FROZEN = na
if barstate.isfirst and validated
    SIGMA_MIN_FROZEN := array.get(FRZ_SMIN, comboIdx)
    FSTAR_FROZEN := array.get(FRZ_FSTAR, comboIdx)

// survivor entry for this combo (if any), cached as scalars
findSurvivor() =>
    int found = -1
    if validated and array.size(SURV_KEY) > 0
        for i = 0 to array.size(SURV_KEY) - 1
            if array.get(SURV_KEY, i) == array.get(FRZ_KEY, comboIdx)
                found := i
                break
    found
var int survIdx = findSurvivor()
var int survCode = -999
var int survH = -1
var bool survMarg = false
var float survIsEff = na
var float survOosEff = na
var float survDegrV = na
var int survNOos = 0
var string survWordS = ""
if barstate.isfirst and survIdx >= 0
    survCode := array.get(SURV_CODE, survIdx)
    survH := array.get(SURV_H, survIdx)
    survMarg := array.get(SURV_MARGINAL, survIdx)
    survIsEff := array.get(SURV_IS_EFF, survIdx)
    survOosEff := array.get(SURV_OOS_EFF, survIdx)
    survDegrV := array.get(SURV_DEGR, survIdx)
    survNOos := array.get(SURV_N_OOS, survIdx)
    survWordS := array.get(SURV_WORD, survIdx)

// ============================ ENGINE (SHARED) ===========================

encodeFull(array<float> closes, int w, array<float> bps, float sigmaMin, int a) =>
    int n = array.size(closes)
    logc = array.new<float>()
    for i = 0 to n - 1
        array.push(logc, math.log(array.get(closes, i)))
    float mu = array.avg(logc)
    float acc = 0.0
    for i = 0 to n - 1
        float d = array.get(logc, i) - mu
        acc += d * d
    float sigma = math.sqrt(acc / n)
    string word = ""
    int code = -1
    paa = array.new<float>()
    if sigma == 0.0 or sigma < sigmaMin
        word := "NULL"
    else
        int seg = n / w
        for s = 0 to w - 1
            float m = 0.0
            for j = 0 to seg - 1
                m += (array.get(logc, s * seg + j) - mu) / sigma
            array.push(paa, m / seg)
        code := 0
        for s = 0 to w - 1
            float v = array.get(paa, s)
            int idx = 0
            for b = 0 to array.size(bps) - 1
                if v >= array.get(bps, b)   // == breakpoint -> upper region
                    idx += 1
            word += letterChar(idx)
            code := code * a + idx
    [word, code, paa, mu, sigma]

letterOf(float paaVal) =>
    int idx = 0
    for b = 0 to array.size(BPS) - 1
        if paaVal >= array.get(BPS, b)
            idx += 1
    idx

hamming(string wa, string wb) =>
    int d = 0
    if str.length(wa) == str.length(wb)
        for i = 0 to str.length(wa) - 1
            if str.substring(wa, i, i + 1) != str.substring(wb, i, i + 1)
                d += 1
    else
        d := 999
    d

// ========================== PER-BAR STATE ===============================
// causal tables (map-based), one per horizon; delayed updates
var map<int, int>   mCount = map.new<int, int>()      // emissions per word
var int totalEmissions = 0
var map<int, int>   mN1    = map.new<int, int>()
var map<int, float> mSum1  = map.new<int, float>()
var map<int, int>   mWin1  = map.new<int, int>()
var map<int, int>   mN4    = map.new<int, int>()
var map<int, float> mSum4  = map.new<int, float>()
var map<int, int>   mWin4  = map.new<int, int>()
var map<int, int>   mN16   = map.new<int, int>()
var map<int, float> mSum16 = map.new<int, float>()
var map<int, int>   mWin16 = map.new<int, int>()
var array<int> recentCodes = array.new<int>()         // codes of last 17 bars
var array<int> letterCounts = array.new<int>(4, 0)    // causal per-letter counts


var array<int> rfHist = array.new<int>(513, 0)
var int rfHistTotal = 0
rfBin(float rf) =>
    rf <= 0.0 ? 0 : 1 + math.min(511, math.max(0, int((math.log10(rf) + 7.0) / 7.0 * 512.0)))
rfPercentile(float rf) =>   // share of prior emitted bars with rf <= this
    int b = rfBin(rf)
    int cum = 0
    for i = 0 to b
        cum += array.get(rfHist, i)
    rfHistTotal > 0 ? 100.0 * cum / rfHistTotal : 50.0
explorerFstar() =>          // 1st percentile of POSITIVE support (amended 7.3)
    int posTotal = rfHistTotal - array.get(rfHist, 0)
    float out = 0.0
    if posTotal > 0
        int target = math.max(1, int(math.ceil(0.01 * posTotal)))
        int cum = 0
        for i = 1 to 512
            cum += array.get(rfHist, i)
            if cum >= target
                out := math.pow(10, (i - 1) / 512.0 * 7.0 - 7.0)
                break
    out

// explorer sigma_min: causal 5th percentile of window sigma (histogram,
// active after 500 windows) — unvalidated markets are descriptive anyway
var array<int> sigHist = array.new<int>(513, 0)
var int sigHistTotal = 0
sigBin(float s) =>
    s <= 0.0 ? 0 : 1 + math.min(511, math.max(0, int((math.log10(s) + 7.0) / 7.0 * 512.0)))
explorerSigmaMin() =>
    float out = 0.0
    if sigHistTotal >= 500
        int target = math.max(1, int(math.ceil(0.05 * sigHistTotal)))
        int cum = 0
        for i = 0 to 512
            cum += array.get(sigHist, i)
            if cum >= target
                out := i == 0 ? 0.0 : math.pow(10, (i - 1) / 512.0 * 7.0 - 7.0)
                break
    out

// ring buffers for ribbon (last 40 words)
var array<int>    ribCodes = array.new<int>()
var array<string> ribWords = array.new<string>()
var array<float>  ribPct   = array.new<float>()
var array<bool>   ribNovel = array.new<bool>()

// current-bar outputs (set on confirmed bars)
var int    curCode = -1
var string curWord = "NULL"
var float  curRf = na
var float  curPct = na
var bool   curDiscord = false
var bool   curNovel = false
var array<float> curPaa = array.new<float>()
var float  curMu = na
var float  curSigma = na
var color  washCol = na
var float  curTemp = na
var int ribbonLetterCur = -1
// display snapshot, taken post-read / pre-credit so the panel matches the
// Python oracle's stats_at(t) exactly (visibility rule: s + h + 1)
var array<int>   dispN   = array.new<int>(3, 0)
var array<float> dispAvg = array.new<float>(3, na)
var array<float> dispWin = array.new<float>(3, na)
var int dispSeen = 0
bool survivorFired = false

statsFor(int code, map<int, int> mN, map<int, float> mSum, map<int, int> mWin) =>
    int nn = code >= 0 and map.contains(mN, code) ? map.get(mN, code) : 0
    float avg = nn > 0 ? map.get(mSum, code) / nn : na
    float win = nn > 0 ? 100.0 * map.get(mWin, code) / nn : na
    [nn, avg, win]

// globals for drawing (ta.* must stay in global scope)
float gAtr   = ta.atr(14)
float gWinLo = ta.lowest(low, N)
float gWinHi = ta.highest(high, N)

// ------------------------- MAIN PER-BAR UPDATE -------------------------
bool ok = bar_index >= N and barstate.isconfirmed
if ok
    // 1) encode current window (bars t-N+1 .. t, chronological)
    closesArr = array.new<float>()
    for i = 0 to N - 1
        array.push(closesArr, close[N - 1 - i])
    float sMin = validated ? SIGMA_MIN_FROZEN : explorerSigmaMin()
    [wrd, cde, paaArr, mu_, sig_] = encodeFull(closesArr, W, BPS, sMin, A)
    curWord := wrd
    curCode := cde
    curPaa := paaArr
    curMu := mu_
    curSigma := sig_
    int sb = sigBin(sig_)
    array.set(sigHist, sb, array.get(sigHist, sb) + 1)
    sigHistTotal += 1

    // 2) READS first (table visible at t == credits through t-1; a word
    //    emitted at s is credited at s+h, so it becomes readable at s+h+1
    //    — identical to the Python oracle's as-of rule)
    bool burned = totalEmissions >= BURN_IN
    if cde >= 0
        curRf := totalEmissions > 0 ? (map.contains(mCount, cde) ? map.get(mCount, cde) : 0) / float(totalEmissions) : 0.0
        curPct := rfPercentile(curRf)
        float fst = validated ? FSTAR_FROZEN : explorerFstar()
        curDiscord := burned and curRf < fst
        curNovel := burned and curRf == 0.0
    else
        curRf := na
        curPct := na
        curDiscord := false
        curNovel := false

    // 2b) SNAPSHOT display stats for the current word — still pre-credit,
    //     so the panel shows what a live table could have known at t
    dispSeen := cde >= 0 and map.contains(mCount, cde) ? map.get(mCount, cde) : 0
    for hIdx = 0 to 2
        [snn, savg, swin] = statsFor(cde, hIdx == 0 ? mN1 : hIdx == 1 ? mN4 : mN16, hIdx == 0 ? mSum1 : hIdx == 1 ? mSum4 : mSum16, hIdx == 0 ? mWin1 : hIdx == 1 ? mWin4 : mWin16)
        array.set(dispN, hIdx, snn)
        array.set(dispAvg, hIdx, savg)
        array.set(dispWin, hIdx, swin)

    // regime wash + temperature (identity ramp over letter zones — an
    // extension of the letter palette, distinct from the intensity
    // gradient rule; wash has its own base/span opacity table)
    if cde >= 0
        float tempSum = 0.0
        float extSum = 0.0
        for s = 0 to W - 1
            tempSum += letterOf(array.get(curPaa, s))
            extSum += math.abs(array.get(curPaa, s))
        curTemp := tempSum / (W * (A - 1))
        float ext = math.min(1.0, (extSum / W) / 1.5)
        int washBase = glowIn == "Subtle" ? 97 : glowIn == "Maximum" ? 92 : 95
        int washSpan = glowIn == "Subtle" ? 8 : glowIn == "Maximum" ? 20 : 14
        int washTr = math.max(72, int(washBase - ext * washSpan))
        washCol := color.new(color.from_gradient(curTemp, 0.0, 1.0, colLA, colLD), washTr)
    else
        curTemp := na
        washCol := na

    // letter ribbon: the letter THIS bar writes within its own window
    if cde >= 0 and curSigma > 0
        float zNow = (math.log(close) - curMu) / curSigma
        ribbonLetterCur := letterOf(zNow)
    else
        ribbonLetterCur := -1

    // 3) CREDIT completed horizons (word emitted h bars ago)
    int nRec = array.size(recentCodes)
    for hIdx = 0 to 2
        int hh = hIdx == 0 ? 1 : hIdx == 1 ? 4 : 16
        if nRec >= hh
            int sCode = array.get(recentCodes, nRec - hh)
            if sCode >= 0
                float fr = math.log(close / close[hh])
                mN   = hIdx == 0 ? mN1   : hIdx == 1 ? mN4   : mN16
                mSum = hIdx == 0 ? mSum1 : hIdx == 1 ? mSum4 : mSum16
                mWin = hIdx == 0 ? mWin1 : hIdx == 1 ? mWin4 : mWin16
                map.put(mN, sCode,   (map.contains(mN, sCode) ? map.get(mN, sCode) : 0) + 1)
                map.put(mSum, sCode, (map.contains(mSum, sCode) ? map.get(mSum, sCode) : 0.0) + fr)
                map.put(mWin, sCode, (map.contains(mWin, sCode) ? map.get(mWin, sCode) : 0) + (fr > 0 ? 1 : 0))

    // 4) INSERT current word (after reads: query-before-insert)
    if cde >= 0
        map.put(mCount, cde, (map.contains(mCount, cde) ? map.get(mCount, cde) : 0) + 1)
        totalEmissions += 1
        int rb = rfBin(curRf)
        array.set(rfHist, rb, array.get(rfHist, rb) + 1)
        rfHistTotal += 1
        for s = 0 to W - 1
            int li = math.min(letterOf(array.get(curPaa, s)), 3)
            array.set(letterCounts, li, array.get(letterCounts, li) + 1)
    array.push(recentCodes, cde)
    if array.size(recentCodes) > 17
        array.shift(recentCodes)

    // ribbon buffers
    array.push(ribCodes, cde)
    array.push(ribWords, cde >= 0 ? wrd : "∅")
    array.push(ribPct, nz(curPct, 50.0))
    array.push(ribNovel, curNovel)
    if array.size(ribCodes) > 40
        array.shift(ribCodes)
        array.shift(ribWords)
        array.shift(ribPct)
        array.shift(ribNovel)

    // survivor completion (survCode is -999 unless this exact combo has one)
    if cde >= 0 and cde == survCode
        survivorFired := true

// ========================= CINEMATIC: REGIME WASH =======================
bgcolor(fWash ? washCol : na, title = "Regime wash")

// ======================= CINEMATIC: LETTER RIBBON =======================
float ribbonY = fLetterRibbon and ribbonLetterCur >= 0 ? low - 0.5 * gAtr : na
color ribbonCol = letterColor(ribbonLetterCur)
plot(ribbonY, "Letter ribbon glow", color = color.new(ribbonCol, glowT(85)), linewidth = 8, style = plot.style_linebr)
plot(ribbonY, "Letter ribbon mid", color = color.new(ribbonCol, glowT(65)), linewidth = 4, style = plot.style_linebr)
plot(ribbonY, "Letter ribbon core", color = color.new(ribbonCol, glowT(30)), linewidth = 2, style = plot.style_linebr)
pRibHi = plot(fLetterRibbon and ribbonLetterCur >= 0 ? low - 0.28 * gAtr : na, "Ribbon band hi", display = display.none)
pRibLo = plot(fLetterRibbon and ribbonLetterCur >= 0 ? low - 0.72 * gAtr : na, "Ribbon band lo", display = display.none)
fill(pRibHi, pRibLo, color = fLetterRibbon and ribbonLetterCur >= 0 ? color.new(ribbonCol, glowT(92)) : na, title = "Ribbon glow field")

// ========================= SURVIVOR EVENT MARKERS =======================
var array<box>   survBoxes  = array.new<box>()
var array<label> survLabels = array.new<label>()
var array<line>  survLines  = array.new<line>()
var int survLblBar = -1000000
if survivorFired and fShowSurv
    bool marg = survMarg
    color gc = marg ? color.new(colGold, 50) : colGold
    box bx = box.new(bar_index - N + 1, gWinHi, bar_index, gWinLo,
         border_color = gc, border_width = 1, bgcolor = color.new(colGold, 85))
    array.push(survBoxes, bx)
    // Debounce: clustered firings overlap into unreadable text, so a fresh
    // label only draws when none was drawn in the last 8 bars. Box and ray
    // still mark every occurrence.
    if bar_index - survLblBar > 8
        string txt = (marg ? "★ marginal — " : "★ ") + "“" + survWordS + "” — OOS-validated shape (h=" + str.tostring(survH) + ")"
        string tip = "Pre-registered validation: IS effect " + str.tostring(survIsEff * 10000, "#.#") + " bp, OOS effect " + str.tostring(survOosEff * 10000, "#.#") + " bp (" + str.tostring(survDegrV, "#") + "% degradation), " + str.tostring(survNOos) + " OOS occurrences." + (marg ? " MARGINAL: passed at 69% against a 70% gate with 38 OOS samples — treat as weak evidence." : " Net-positive after median spread cost in the study (informational, not advice).")
        label lb = label.new(bar_index, gWinHi, txt, style = label.style_label_down,
             color = color.new(colGold, 80), textcolor = gc, size = size.small, tooltip = tip)
        array.push(survLabels, lb)
        survLblBar := bar_index
        if array.size(survLabels) > 15
            label.delete(array.shift(survLabels))
    if cin or clr
        line bl = line.new(bar_index, close, bar_index, close + gAtr, extend = extend.both,
             color = color.new(colGold, glowT(60)), width = 2)
        array.push(survLines, bl)
        if array.size(survLines) > 15
            line.delete(array.shift(survLines))
    if array.size(survBoxes) > 15
        box.delete(array.shift(survBoxes))

// ======================= DISCORD / NOVEL MARKERS ========================
// Rare-but-seen discords keep the small diamond in every preset except
// Clear (hidden there). Novel words get the supernova in Cinematic and
// Clear (diamond in Standard/Linguist).
var array<label> discLabels = array.new<label>()
var array<box>   novaBoxes  = array.new<box>()
var array<label> novaLabels = array.new<label>()
if ok and curDiscord and fShowDiscord
    if curNovel and (cin or clr)
        for ring = 0 to 2
            int hw = ring == 0 ? 2 : ring == 1 ? 4 : 7
            float hh = ring == 0 ? 1.0 : ring == 1 ? 2.0 : 3.2
            int rtr = ring == 0 ? 55 : ring == 1 ? 75 : 90
            box rb = box.new(bar_index - hw, close + hh * gAtr, bar_index + hw, close - hh * gAtr,
                 border_color = color.new(colViolet, glowT(rtr)), border_width = 1,
                 bgcolor = color.new(colViolet, glowT(math.min(97, rtr + 5))))
            array.push(novaBoxes, rb)
        label nvl = label.new(bar_index, close + 3.6 * gAtr, "NEVER SEEN BEFORE — “" + curWord + "”",
             style = label.style_label_down, color = color.new(colViolet, glowT(70)), textcolor = colText,
             size = size.large, text_font_family = font.family_monospace,
             tooltip = "Rarity is real; predictive power is not confirmed. In our out-of-sample tests, rare words did NOT reliably precede volatility (0 of 28 markets passed).")
        array.push(novaLabels, nvl)
        if array.size(novaLabels) > 8
            label.delete(array.shift(novaLabels))
            box.delete(array.shift(novaBoxes))
            box.delete(array.shift(novaBoxes))
            box.delete(array.shift(novaBoxes))
    else if not clr
        string dtxt = curNovel ? "◆ first time ever spoken" : "◆ near-novel — <1st pct"
        label dl = label.new(bar_index, high, dtxt, style = label.style_label_down, yloc = yloc.abovebar,
             color = color.new(colViolet, 70), textcolor = colViolet, size = size.small,
             tooltip = "Rarity is real; predictive power is not confirmed. In our out-of-sample tests, rare words did NOT reliably precede volatility (0 of 28 markets passed).")
        array.push(discLabels, dl)
        if array.size(discLabels) > 50
            label.delete(array.shift(discLabels))

// ==================== CINEMATIC: REGIME-BREAK STAMPS ====================
var string prevEmittedWord = "NULL"
var array<line>  regimeLines  = array.new<line>()
var array<label> regimeLabels = array.new<label>()
if ok
    bool haveWords = curCode >= 0 and prevEmittedWord != "NULL"
    if fRegimeStamps and haveWords and hamming(curWord, prevEmittedWord) >= int(math.ceil(W / 2.0)) and not na(curTemp)
        color rc = color.from_gradient(curTemp, 0.0, 1.0, colLA, colLD)
        line rl = line.new(bar_index, close, bar_index, close + gAtr, extend = extend.both,
             color = color.new(rc, glowT(80)), width = 1)
        label rlb = label.new(bar_index, close + 2.4 * gAtr, "“" + curWord + "”",
             style = label.style_label_down, color = color.new(rc, glowT(70)), textcolor = colText,
             size = size.large, text_font_family = font.family_monospace,
             tooltip = "Regime break: the market's word just changed in at least half its letters. Descriptive — a change of shape, not a signal.")
        array.push(regimeLines, rl)
        array.push(regimeLabels, rlb)
        if array.size(regimeLines) > 12
            line.delete(array.shift(regimeLines))
            label.delete(array.shift(regimeLabels))
    prevEmittedWord := curCode >= 0 ? curWord : "NULL"

// ============================= WORD STRIP ===============================
var array<box>   stripBoxes  = array.new<box>()
var array<label> stripLabels = array.new<label>()
var polyline skel = na
if barstate.islast and fShowStrip and bar_index >= N
    while array.size(stripBoxes) > 0
        box.delete(array.shift(stripBoxes))
    while array.size(stripLabels) > 0
        label.delete(array.shift(stripLabels))
    if not na(skel)
        polyline.delete(skel)
    bool below = close > (gWinLo + gWinHi) / 2   // free-space side selection
    float yTop = below ? gWinLo - gAtr * 0.8 : gWinHi + gAtr * 1.6
    float yBot = below ? gWinLo - gAtr * 1.6 : gWinHi + gAtr * 0.8
    if curCode < 0
        box nb = box.new(bar_index - N + 1, yTop, bar_index, yBot, border_color = colNull, bgcolor = color.new(colNull, 70))
        array.push(stripBoxes, nb)
        label nl = label.new(bar_index - N / 2, below ? yBot : yTop, "∅  too quiet to speak (variance gate)",
             style = below ? label.style_label_up : label.style_label_down,
             color = color.new(colNull, 100), textcolor = colNull, size = size.normal)
        array.push(stripLabels, nl)
    else
        for s = 0 to W - 1
            int lft = bar_index - N + 1 + s * SEG
            int li = letterOf(array.get(curPaa, s))
            box tb = box.new(lft, yTop, lft + SEG - 1, yBot, border_color = color.new(letterColor(li), 40), bgcolor = color.new(letterColor(li), 70))
            array.push(stripBoxes, tb)
            label tl = label.new(lft + SEG / 2, (yTop + yBot) / 2, letterChar(li), style = label.style_none, textcolor = colText, size = size.large)
            array.push(stripLabels, tl)
        string spaced = ""
        for s = 0 to W - 1
            spaced += (s > 0 ? " " : "") + letterChar(letterOf(array.get(curPaa, s)))
        string hdr = "“ " + spaced + " ” — " + (curPct < 5 ? "rare (" : curPct > 80 ? "common (" : "(") + ordinal(curPct) + " pct)"
        label hl = label.new(bar_index - N / 2, below ? yBot - gAtr * 0.3 : yTop + gAtr * 0.3, hdr,
             style = below ? label.style_label_up : label.style_label_down,
             color = color.new(colNull, 100), textcolor = colText, size = size.normal,
             tooltip = "The market's current word: the last " + str.tostring(N) + " bars z-normalized, compressed to " + str.tostring(W) + " segments, each mapped to a letter by frozen breakpoints. Percentile = how often words at least this rare occur (causal).")
        array.push(stripLabels, hl)
        if fShowSkel and curSigma > 0
            pts = array.new<chart.point>()
            for s = 0 to W - 1
                float py = math.exp(curMu + curSigma * array.get(curPaa, s))
                array.push(pts, chart.point.from_index(bar_index - N + 1 + s * SEG + SEG / 2, py))
            skel := polyline.new(pts, curved = false, line_color = color.new(colText, 30), line_width = 2)

// ============================ LEXICON PANEL =============================
posOf(string p) =>
    p == "Top right" ? position.top_right : p == "Top left" ? position.top_left : p == "Bottom right" ? position.bottom_right : position.bottom_left

dataBar(float pct, int cells) =>
    int filled = int(math.round(pct / 100.0 * cells))
    string s = ""
    for i = 1 to cells
        s += i <= filled ? "█" : "░"
    s

verdictFor(int h) =>
    string v = "no significant edge"
    color vc = colMuted
    string tip = "This word/horizon showed no Holm-corrected edge in the pre-registered study (37,000 tests, 6 IS hits, 2 OOS survivors). The most common verdict, by design."
    if not validated
        v := "descriptive"
        tip := "EXPLORER MODE — this market/timeframe was not part of the validation study. Everything shown is descriptive only."
    else if curCode >= 0 and curCode == survCode and h == survH
        v := survMarg ? "★ marginal" : "★ OOS-VALIDATED"
        vc := survMarg ? color.new(colGold, 50) : colGold
        // built from generated constants — one source of truth with the marker
        string sNums = str.tostring(survDegrV, "#") + "% degradation, " + str.tostring(survNOos) + " OOS occurrences"
        tip := survMarg ? "Survived the out-of-sample gate barely: " + sNums + " against a 70% cutoff. Real, but thin — weak evidence by construction." : "One of 2 words (of 37,000 tested) that survived the one-shot out-of-sample gate: same sign, " + sNums + ", net-positive after median spread cost."
    [v, vc, tip]

var table panel = na
if barstate.islast and fShowPanel
    if na(panel)
        panel := table.new(posOf(panelPos), 5, 8, bgcolor = colPanBg, border_width = 1, border_color = color.new(colMuted, 80))
    string hdrR = syminfo.ticker + " · " + timeframe.period + " · " + cfgKey + " · v1.3"
    table.cell(panel, 0, 0, "MARKET LEXICON [GBB]", text_color = colText, text_halign = text.align_left, text_size = size.small)
    table.cell(panel, 1, 0, "", text_size = size.tiny)
    table.cell(panel, 2, 0, "", text_size = size.tiny)
    table.cell(panel, 3, 0, validated ? "validated market" : "EXPLORER MODE — descriptive only", text_color = validated ? colGold : colViolet, text_size = size.tiny,
         tooltip = validated ? "This symbol/timeframe/config was part of the pre-registered validation. Frozen Mode E breakpoints active. Crypto combos were validated on Binance USDT-M perpetuals." : "Unvalidated market: Gaussian breakpoints, verdicts locked to descriptive, no survivor markers possible.")
    table.cell(panel, 4, 0, hdrR, text_color = colMuted, text_halign = text.align_right, text_size = size.tiny)
    // word row (dispSeen is the pre-insert snapshot — consistent with the
    // percentile, which was also computed before inserting this bar's word)
    table.cell(panel, 0, 1, "WORD", text_color = colMuted, text_size = size.small)
    table.cell(panel, 1, 1, curCode >= 0 ? "“" + curWord + "”" : "∅", text_color = colText, text_size = size.normal, text_font_family = font.family_monospace)
    table.cell(panel, 2, 1, curCode >= 0 ? "seen " + str.tostring(dispSeen, "#,###") + "×" : "variance gate", text_color = colMuted, text_size = size.small)
    table.cell(panel, 3, 1, curCode >= 0 ? ordinal(curPct) + " pct" : "", text_color = colMuted, text_size = size.small)
    table.cell(panel, 4, 1, curCode >= 0 ? dataBar(curPct, 10) : "", text_color = gradCol(nz(curPct, 50) / 100), text_size = size.small, text_font_family = font.family_monospace)
    // horizon header
    table.cell(panel, 0, 2, "HZN", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 1, 2, "n", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 2, 2, "win %", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 3, 2, "avg fwd", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 4, 2, "verdict", text_color = colMuted, text_size = size.tiny)
    for row = 0 to 2
        int hh = row == 0 ? 1 : row == 1 ? 4 : 16
        // render from the pre-credit snapshot (matches Python stats_at(t))
        int nn = array.get(dispN, row)
        float avg = array.get(dispAvg, row)
        float win = array.get(dispWin, row)
        [v, vc, tip] = verdictFor(hh)
        float conf = math.min(1.0, nn / 100.0)                        // visual epistemology
        color statCol = nn == 0 ? colMuted : color.new(gradCol(nz(win, 50) / 100), int((1 - conf) * 70))
        bool insuff = validated and nn < 30 and v == "no significant edge"
        table.cell(panel, 0, 3 + row, "h=" + str.tostring(hh), text_color = colText, text_size = size.small)
        table.cell(panel, 1, 3 + row, str.tostring(nn, "#,###"), text_color = colMuted, text_size = size.small)
        table.cell(panel, 2, 3 + row, na(win) ? "—" : str.tostring(win, "#.#") + "%", text_color = statCol, text_size = size.small,
             tooltip = "Causal win rate: share of this word's completed h=" + str.tostring(hh) + " horizons with positive forward return, on this chart's history only. Faint text = thin data.")
        table.cell(panel, 3, 3 + row, na(avg) ? "—" : str.tostring(avg * 10000, "#.#") + " bp", text_color = statCol, text_size = size.small,
             tooltip = "Causal average forward log return over h=" + str.tostring(hh) + " bars after this word, in basis points.")
        table.cell(panel, 4, 3 + row, insuff ? "insufficient data" : v, text_color = insuff ? color.new(colMuted, 40) : vc, text_size = size.small, tooltip = tip)
    // rarity / discord row
    table.cell(panel, 0, 6, "RARITY", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 1, 6, curCode >= 0 ? dataBar(100 - nz(curPct, 50), 10) : "", text_color = gradCol((100 - nz(curPct, 50)) / 100), text_size = size.small, text_font_family = font.family_monospace)
    table.cell(panel, 2, 6, curCode >= 0 ? (curPct < 5 ? "rare" : curPct > 80 ? "common" : "typical") : "", text_color = colMuted, text_size = size.small)
    table.cell(panel, 3, 6, "DISCORD", text_color = colMuted, text_size = size.tiny)
    table.cell(panel, 4, 6, curDiscord ? (curNovel ? "◆ novel" : "◆ rare") : "—", text_color = curDiscord ? colViolet : colMuted, text_size = size.small,
         tooltip = "Rarity is real; predictive power is not confirmed: 0 of 28 markets passed the out-of-sample volatility tests.")
    // footer — non-negotiable, not toggleable
    table.cell(panel, 0, 7, "breakpoints frozen from validation (2026-07) · not adaptive", text_color = color.new(colMuted, 20), text_size = size.tiny, text_halign = text.align_left)
    table.cell(panel, 1, 7, "", text_size = size.tiny)
    table.cell(panel, 2, 7, "", text_size = size.tiny)
    if fLinguist
        int totL = array.get(letterCounts, 0) + array.get(letterCounts, 1) + array.get(letterCounts, 2) + array.get(letterCounts, 3)
        string dist = totL == 0 ? "" : "a " + str.tostring(100.0 * array.get(letterCounts, 0) / totL, "#") + "% · b " + str.tostring(100.0 * array.get(letterCounts, 1) / totL, "#") + "% · c " + str.tostring(100.0 * array.get(letterCounts, 2) / totL, "#") + "%" + (A > 3 ? " · d " + str.tostring(100.0 * array.get(letterCounts, 3) / totL, "#") + "%" : "")
        table.cell(panel, 3, 7, dist, text_color = colMuted, text_size = size.tiny, tooltip = "Causal letter distribution across all emitted words. Mode E breakpoints target equiprobable letters; drift here means the frozen calibration is aging.")
        table.cell(panel, 4, 7, "", text_size = size.tiny)
    else
        table.cell(panel, 3, 7, "", text_size = size.tiny)
        table.cell(panel, 4, 7, "", text_size = size.tiny)

// ======================= CLEAR: HERO READOUT ============================

heroPosOf(string p) =>
    p == "Top center" ? position.top_center : p == "Top left" ? position.top_left : p == "Top right" ? position.top_right : position.bottom_center

var table hero = na
if barstate.islast and fHero
    if na(hero)
        hero := table.new(heroPosOf(heroPos), 1, 4, bgcolor = colPanBg, border_width = 1, border_color = color.new(colMuted, 80))
    string szHdr  = heroSize == "Small" ? size.tiny : heroSize == "Large" ? size.small : size.tiny
    string szGls  = heroSize == "Small" ? size.normal : heroSize == "Large" ? size.huge : size.large
    string szSeen = heroSize == "Small" ? size.tiny : heroSize == "Large" ? size.normal : size.small
    string szFine = heroSize == "Small" ? size.tiny : heroSize == "Large" ? size.small : size.tiny
    string heroTip = "A plain-English description of the shape of the last " + str.tostring(N) + " closes. Descriptive only — the validation verdict lives in the Lexicon Panel."
    table.cell(hero, 0, 0, "THE MARKET JUST SAID:", text_color = colMuted, text_size = szHdr, text_halign = text.align_center)
    // glossOf/ordinal run on BOTH ternary branches (Pine has no
    // short-circuit); safe only because curWord is always >= 2 chars
    // (the "NULL" sentinel or a W-letter word).
    table.cell(hero, 0, 1, curCode >= 0 ? "“" + glossOf(curWord) + "”" : "— (too quiet to read)", text_color = colText, text_size = szGls, text_halign = text.align_center, tooltip = heroTip)
    table.cell(hero, 0, 2, curCode >= 0 ? "seen " + str.tostring(dispSeen, "#,###") + "× before" : "", text_color = colMuted, text_size = szSeen, text_halign = text.align_center)
    table.cell(hero, 0, 3, curCode >= 0 ? "“" + curWord + "” · " + ordinal(curPct) + " pct" : "∅", text_color = colMuted, text_size = szFine, text_halign = text.align_center, text_font_family = font.family_monospace)

// ========================= WORD HISTORY RIBBON ==========================
var table ribbon = na
if barstate.islast and fShowRibbon
    if na(ribbon)
        ribbon := table.new(position.bottom_center, 40, 2, bgcolor = color.new(#000000, 100))
    int m = array.size(ribCodes)
    for i = 0 to 39
        if i < m
            int c = array.get(ribCodes, i)
            float p = array.get(ribPct, i)
            bool nv = array.get(ribNovel, i)
            int firstLetter = c < 0 ? -1 : int(c / int(math.pow(A, W - 1)))
            color cc = c < 0 ? color.new(colNull, 60) : color.new(letterColor(firstLetter), int(20 + p * 0.6))
            table.cell(ribbon, i, 0, nv ? "•" : " ", text_color = colViolet, text_size = size.tiny, bgcolor = color.new(#000000, 100))
            table.cell(ribbon, i, 1, " ", bgcolor = nv ? color.new(colViolet, 30) : cc, text_size = size.tiny,
                 tooltip = (c < 0 ? "∅ null" : "“" + array.get(ribWords, i) + "” · " + ordinal(p) + " pct") + (nv ? " · first time ever spoken" : ""))
        else
            table.cell(ribbon, i, 0, " ", bgcolor = color.new(#000000, 100), text_size = size.tiny)
            table.cell(ribbon, i, 1, " ", bgcolor = color.new(#000000, 100), text_size = size.tiny)

// =============================== ALERTS =================================
alertcondition(survivorFired, "Survivor word completed",
     "Market Lexicon: an OOS-validated word just completed on a validated market. Check the panel for horizon and study stats.")
alertcondition(ok and curNovel, "Novel word — first time ever spoken",
     "Market Lexicon: the market just spoke a word never seen before on this chart. Note: rarity is real; predictive power is not confirmed (0 of 28 markets passed OOS volatility tests).")
alertcondition(ok and curDiscord, "Rare word (<1st pct)",
     "Market Lexicon: current word is rarer than the 1st percentile (causal). Descriptive flag; no confirmed OOS edge.")
alertcondition(ok and curCode >= 0, "Any word completed",
     "Market Lexicon: a word completed. Enable dynamic alerts for the word text.")
if dynAlerts and ok and curCode >= 0
    alert("Lexicon “" + curWord + "” (" + ordinal(curPct) + " pct)" + (curDiscord ? " ◆discord" : "") + (survivorFired ? " ★survivor" : ""), alert.freq_once_per_bar_close)

// ============================== SELF-TEST ===============================

var table stTable = na
if barstate.islastconfirmedhistory and runSelfTest
    if na(stTable)
        stTable := table.new(position.middle_center, 4, array.size(RV_ID) + 1, bgcolor = colPanBg, border_width = 1, border_color = colMuted)
    table.cell(stTable, 0, 0, "ENGINE SELF-TEST", text_color = colText, text_size = size.small)
    table.cell(stTable, 1, 0, "mode G", text_color = colMuted, text_size = size.small)
    table.cell(stTable, 2, 0, "mode E", text_color = colMuted, text_size = size.small)
    table.cell(stTable, 3, 0, "verdict", text_color = colMuted, text_size = size.small)
    for i = 0 to array.size(RV_ID) - 1
        closesRv = array.slice(RV_CLOSE, array.get(RV_OFS, i), array.get(RV_OFS, i + 1))
        bpsE = array.slice(RV_BPE, array.get(RV_BPE_OFS, i), array.get(RV_BPE_OFS, i + 1))
        float sm = array.get(RV_SMIN, i)
        [wg, cg, pg, mg, sg] = encodeFull(closesRv, array.get(RV_W, i), gaussBps(array.get(RV_A, i)), sm, array.get(RV_A, i))
        [we, ce, pe, me, se] = encodeFull(closesRv, array.get(RV_W, i), bpsE, sm, array.get(RV_A, i))
        bool passG = wg == array.get(RV_WORD_G, i)
        bool passE = we == array.get(RV_WORD_E, i)
        table.cell(stTable, 0, i + 1, array.get(RV_ID, i), text_color = colText, text_size = size.tiny, text_font_family = font.family_monospace)
        table.cell(stTable, 1, i + 1, wg + (passG ? " ✓" : " ✗ want " + array.get(RV_WORD_G, i)), text_color = passG ? colLB : colLD, text_size = size.tiny, text_font_family = font.family_monospace)
        table.cell(stTable, 2, i + 1, we + (passE ? " ✓" : " ✗ want " + array.get(RV_WORD_E, i)), text_color = passE ? colLB : colLD, text_size = size.tiny, text_font_family = font.family_monospace)
        table.cell(stTable, 3, i + 1, passG and passE ? "PASS" : "FAIL", text_color = passG and passE ? colLB : colLD, text_size = size.tiny)
````
