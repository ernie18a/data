<!-- tradingview-pine-id: PUB;0ae9c00594d84d1dbd716c83be8ad17b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Comparative Relative Strength Multi-Mode [MDT]

Source: https://www.tradingview.com/script/TUaYjEjR-Comparative-Relative-Strength-Multi-Mode-MDT/

## Description

===============================================================
SUGGESTED TITLE (English only, as required)
===============================================================

Comparative Relative Strength Multi-Mode [MDT]

===============================================================
SHORT TITLE (chart label)
===============================================================

CRS [MDT]

===============================================================
DESCRIPTION - ENGLISH (must appear first)
===============================================================

OVERVIEW

Comparative Relative Strength measures how one instrument is performing
against another instrument, rather than against its own past. It answers a
different question from Wilder's RSI. RSI is internal: it compares a stock to
its own recent closes. This indicator is external: it compares the chart
symbol to a benchmark you choose, such as an index, a sector index, or a
second stock.

The core relationship is simply the price of the chart symbol divided by the
price of the benchmark. When that ratio rises, the chart symbol is gaining
ground on the benchmark. When it falls, the chart symbol is losing ground.
The absolute level of the ratio carries no meaning, because it depends
entirely on the two price scales involved. Only the direction of the line
matters.

An important reading point: a rising line does not mean price is going up. In
a falling market a rising line means the symbol is falling less than the
benchmark. Relative strength is relative, not directional.

WHAT THIS VERSION ADDS

The raw price relative is a well known idea and is available through the
built-in compare function. This script exists because the raw ratio alone is
hard to work with in practice, for three reasons: its level is arbitrary, it
cannot be compared across two different symbols, and it gives no structure to
read. This version addresses all three in one pane.

1. Four normalizations of the same relationship, switchable from one input,
   so you can move between an absolute view and a comparable view without
   changing indicators.

2. A Mansfield style normalization, which rebases the ratio around a zero
   line and therefore makes readings comparable across different symbols.

3. Relative strength structure detection. The script tracks new highs and
   new lows of the relative strength line itself over a lookback window, and
   marks them on the pane. This is what lets you see relative strength break
   out while price is still inside a base.

4. A moving average applied to the relative strength line, with the line
   colour and a shaded band both driven by the line's position against that
   average, so a change in relative leadership is visible at a glance.

5. A reading table that states the current benchmark, the current relative
   strength value, whether the symbol is currently outperforming or
   underperforming, and the raw percentage gap over the chosen lookback.

CALCULATION

Let BASE be the selected price source of the chart symbol and COMP be the
same source requested from the benchmark symbol on the same timeframe, with
lookahead off and gaps off.

Mode 1, Ratio:
    CRS = BASE / COMP

Mode 2, Ratio x100:
    CRS = (BASE / COMP) * 100
    Identical to mode 1 but scaled so the numbers read comfortably on most
    instruments.

Mode 3, Percent out or under-performance:
    symbol return   = (BASE / BASE[n] - 1) * 100
    benchmark return= (COMP / COMP[n] - 1) * 100
    CRS = symbol return - benchmark return
    This is a rate rather than a level. It expresses, in percentage points,
    how much the symbol has gained on or lost to the benchmark over the last
    n bars. It oscillates around zero.

Mode 4, Mansfield relative strength:
    ratio = BASE / COMP
    CRS   = ((ratio / SMA(ratio, m)) - 1) * 100
    This rebases the ratio against its own longer average. A positive value
    means the symbol is stronger against the benchmark than it has been on
    average over the base period, and a negative value means the opposite.
    Because the output is a deviation from a self-referencing average rather
    than an absolute ratio, readings from two different symbols can be
    compared to each other. Stan Weinstein used a 52 period base on weekly
    charts.

A moving average of the selected output is then computed. All three moving
average types are calculated on every bar and only then selected, so
switching type does not create a broken calculation history.

Note that mode 3 and mode 4 can disagree with mode 1 and 2 over short
windows. That is expected, not an error. Mode 3 measures a rate of change
over a fixed window while modes 1 and 2 measure a level.

HOW TO READ THE PANE

Main line
    Rising means the chart symbol is outperforming the benchmark. Falling
    means it is underperforming. Flat means it is tracking the benchmark.

Line colour and shaded band
    By default the colour is set by whether the line sits above or below its
    own moving average. The colour flip is the moment relative leadership is
    changing, which usually precedes the visual change in slope.

Grey moving average line
    A smoothed reference for the relative strength line, used for the colour
    logic and for the crossover alerts.

Zero line
    Drawn automatically in the percentage and Mansfield modes only, because
    those two modes are centred on zero and the ratio modes are not.

Triangles
    An up triangle at the bottom of the pane marks a new high in relative
    strength over the lookback window. A down triangle at the top marks a new
    low. These fire on the relative strength line, not on price.

Table
    Top right. Shows the active benchmark, the current reading, the current
    outperforming or underperforming state, and the percentage gap over the
    chosen lookback.

HOW TO USE IT

Selecting candidates against a broad index
    Set the benchmark to a broad index and use Ratio x100. Names whose
    relative strength line is making higher highs are your long side
    candidates. Names making lower lows are your short side candidates. You
    are filtering for where money is actually rotating, before deciding
    anything about entry.

Two stage top down filter
    First put a sector index on the chart with the broad index as benchmark,
    to see whether the sector is leading. Then put an individual stock on the
    chart with that sector index as the benchmark, to see whether the stock
    is leading inside its own sector. A stock that is strong inside a strong
    sector is a higher quality candidate than a stock that is merely strong
    in isolation.

Relative strength leading price
    Watch for an up triangle, that is a new relative strength high, while
    price itself is still inside a range or base. This often appears before
    the price breakout. The inverse is a warning: price makes a new high but
    the relative strength line does not, which suggests the move is being
    carried by the whole market rather than by demand specific to that name.

Longer term positional filter
    Switch to Mansfield relative strength with a 52 period base on a weekly
    chart. Treat the zero line as a regime filter and only consider long side
    setups while the reading is above zero.

Comparing two indices intraday
    Put one index on the chart with a second index as the benchmark and use
    the percentage mode with a short lookback. This tells you which of the
    two is leading on the day, which is useful when deciding which instrument
    to express a directional view in.

Spread work
    Because the ratio is literally the spread between two instruments, mode 1
    can be used directly as the input for pair or spread analysis between two
    correlated symbols.

INPUTS

Benchmark symbol
    The instrument you are comparing against. Default is a broad index.

Price source
    Which price of each bar is used, for both the chart symbol and the
    benchmark. Close is the usual choice.

Display mode
    Selects between the four calculations described above.

RS moving average type and length
    The smoothing applied to the relative strength line, used for colour and
    for the crossover alerts.

Mansfield base length
    The base period for the Mansfield normalization. 52 on weekly charts
    follows the original use. On daily charts a longer base, around 200, is
    the closer equivalent.

Percent performance lookback
    The window used by mode 3 and by the percentage figure in the table.

New RS high and low lookback
    The window used to decide whether the relative strength line has made a
    new extreme.

Visual settings
    Toggles for the moving average, the shading, the triangles and the table,
    plus the two colours used for the outperforming and underperforming
    states.

ALERTS

Four alert conditions are available:
    Relative strength crossing above its moving average.
    Relative strength crossing below its moving average.
    A new relative strength high over the lookback.
    A new relative strength low over the lookback.

LIMITATIONS AND WHAT THIS IS NOT

This is a selection and context tool. It tells you where relative leadership
sits. It does not tell you when to enter or exit, and it is not designed to
be used as a standalone signal.

The output has no fixed bounds, so there are no overbought or oversold levels
to read. Attempting to use it that way will produce poor results.

Raw ratio values from two different symbols are not comparable to each other,
because each pair of price scales produces its own arbitrary level. Use the
Mansfield or percentage mode if you need to rank several symbols.

Unadjusted data will distort the line. If the chart symbol has had a split,
bonus or similar corporate action and the data series is not adjusted, the
ratio will show a break that has nothing to do with relative strength.

If the benchmark does not trade during the same session as the chart symbol,
readings near session edges can be unreliable.

DISCLAIMER

This script is published as an educational technical analysis tool. It is not
investment advice and it is not a recommendation to buy or sell any security.
No claim is made or implied regarding past or future performance. Trading and
investing in securities and derivatives carries a substantial risk of loss.
Please consult a SEBI registered investment adviser before making any
investment decision, and take responsibility for your own risk management.

===============================================================
DESCRIPTION - TELUGU (place immediately below the English block)
===============================================================

పరిచయం

Comparative Relative Strength అంటే ఒక స్క్రిప్ట్ (షేరు లేదా ఇండెక్స్) పనితీరును
దాని స్వంత గతంతో కాకుండా, మరొక ఇన్‌స్ట్రుమెంట్‌తో పోల్చి కొలవడం. ఇది RSI కాదు.
RSI అనేది అంతర్గతమైనది, అది షేరును దాని సొంత గత ధరలతో పోలుస్తుంది. ఈ ఇండికేటర్
బాహ్యమైనది, ఇది చార్ట్‌లో ఉన్న స్క్రిప్ట్‌ను మీరు ఎంచుకున్న బెంచ్‌మార్క్‌తో
పోలుస్తుంది. బెంచ్‌మార్క్ అనేది ఒక బ్రాడ్ ఇండెక్స్ కావచ్చు, సెక్టార్ ఇండెక్స్
కావచ్చు, లేదా మరొక షేరు కూడా కావచ్చు.

లెక్క చాలా సరళం. చార్ట్ స్క్రిప్ట్ ధరను బెంచ్‌మార్క్ ధరతో భాగిస్తే వచ్చే
నిష్పత్తి (ratio) ఇక్కడ ప్రధానం. ఆ లైన్ పైకి వెళ్తుంటే చార్ట్ స్క్రిప్ట్
బెంచ్‌మార్క్ కంటే మెరుగ్గా పని చేస్తోంది (outperforming). కిందికి వెళ్తుంటే
వెనుకబడుతోంది (underperforming). ఆ నిష్పత్తి యొక్క సంఖ్యా విలువకు అర్థం లేదు,
ఎందుకంటే అది రెండు ధరల స్థాయిలపై ఆధారపడి ఉంటుంది. లైన్ దిశ (direction) మాత్రమే
ముఖ్యం.

ఇక్కడ ఒక కీలకమైన విషయం గుర్తుంచుకోవాలి. లైన్ పైకి వెళ్తోంది అంటే ధర పైకి
వెళ్తోందని అర్థం కాదు. మార్కెట్ పడుతున్నప్పుడు లైన్ పైకి వెళ్తోందంటే, ఆ స్క్రిప్ట్
బెంచ్‌మార్క్ కంటే తక్కువగా పడుతోందని అర్థం. రిలేటివ్ స్ట్రెంత్ అనేది సాపేక్షమైనది,
దిశను సూచించేది కాదు.

ఈ వెర్షన్‌లో అదనంగా ఏముంది

ప్రైస్ రిలేటివ్ అనే భావన కొత్తది కాదు. కానీ ముడి నిష్పత్తిని ఆచరణలో వాడటం కష్టం.
దానికి మూడు కారణాలు: దాని స్థాయికి అర్థం ఉండదు, రెండు వేర్వేరు స్క్రిప్ట్‌ల
విలువలను పోల్చలేము, మరియు చదవడానికి ఎలాంటి స్ట్రక్చర్ ఉండదు. ఈ స్క్రిప్ట్ ఆ
మూడింటినీ ఒకే పేన్‌లో పరిష్కరిస్తుంది.

1. ఒకే రిలేషన్‌షిప్‌ను నాలుగు వేర్వేరు రూపాల్లో చూపిస్తుంది, ఒకే ఇన్‌పుట్ నుంచి
   మార్చుకోవచ్చు. ఇండికేటర్ మార్చకుండానే absolute view నుంచి comparable view కు
   వెళ్ళవచ్చు.

2. Mansfield తరహా నార్మలైజేషన్ ఉంది. ఇది నిష్పత్తిని జీరో లైన్ చుట్టూ
   అమరుస్తుంది, అందువల్ల వేర్వేరు స్క్రిప్ట్‌ల రీడింగ్‌లను ఒకదానితో ఒకటి
   పోల్చవచ్చు.

3. రిలేటివ్ స్ట్రెంత్ స్ట్రక్చర్‌ను గుర్తిస్తుంది. ఎంచుకున్న లుక్‌బ్యాక్‌లో
   రిలేటివ్ స్ట్రెంత్ లైన్ కొత్త హై లేదా కొత్త లో చేసిందా అన్నది గుర్తు
   పెడుతుంది. ధర ఇంకా బేస్‌లోనే ఉండగా రిలేటివ్ స్ట్రెంత్ బ్రేక్ అవడాన్ని
   చూడటానికి ఇది ఉపయోగపడుతుంది.

4. రిలేటివ్ స్ట్రెంత్ లైన్‌పై ఒక మూవింగ్ యావరేజ్ వేయబడుతుంది. లైన్ రంగు మరియు
   షేడెడ్ బ్యాండ్ రెండూ ఆ యావరేజ్‌తో పోలిస్తే లైన్ ఎక్కడ ఉందో దాన్ని బట్టి
   మారతాయి. దీనివల్ల లీడర్‌షిప్ మార్పు ఒక్క చూపులో కనిపిస్తుంది.

5. ఒక రీడింగ్ టేబుల్ ఉంది. ప్రస్తుత బెంచ్‌మార్క్, ప్రస్తుత విలువ, outperforming
   లేదా underperforming స్థితి, మరియు ఎంచుకున్న లుక్‌బ్యాక్‌లో శాతం తేడా
   చూపిస్తుంది.

లెక్కింపు విధానం

BASE అంటే చార్ట్ స్క్రిప్ట్ యొక్క ఎంచుకున్న ప్రైస్ సోర్స్. COMP అంటే అదే
టైమ్‌ఫ్రేమ్‌లో బెంచ్‌మార్క్ నుంచి తీసుకున్న అదే సోర్స్ (lookahead ఆఫ్, gaps ఆఫ్).

మోడ్ 1, Ratio:
    CRS = BASE / COMP

మోడ్ 2, Ratio x100:
    CRS = (BASE / COMP) * 100
    మోడ్ 1 లాంటిదే, కానీ సంఖ్యలు చదవడానికి సౌకర్యంగా ఉండేలా స్కేల్ చేయబడింది.

మోడ్ 3, శాతం అవుట్ లేదా అండర్ పెర్ఫార్మెన్స్:
    స్క్రిప్ట్ రిటర్న్   = (BASE / BASE[n] - 1) * 100
    బెంచ్‌మార్క్ రిటర్న్ = (COMP / COMP[n] - 1) * 100
    CRS = స్క్రిప్ట్ రిటర్న్ - బెంచ్‌మార్క్ రిటర్న్
    ఇది స్థాయి కాదు, రేటు. గత n బార్లలో స్క్రిప్ట్ బెంచ్‌మార్క్‌పై ఎన్ని శాతం
    పాయింట్లు సంపాదించిందో లేదా కోల్పోయిందో చెబుతుంది. ఇది సున్నా చుట్టూ
    కదులుతుంది.

మోడ్ 4, Mansfield రిలేటివ్ స్ట్రెంత్:
    ratio = BASE / COMP
    CRS   = ((ratio / SMA(ratio, m)) - 1) * 100
    ఇది నిష్పత్తిని దాని సొంత దీర్ఘకాలిక సగటుతో పోల్చి రీబేస్ చేస్తుంది. విలువ
    ధనాత్మకంగా ఉంటే, ఆ స్క్రిప్ట్ బెంచ్‌మార్క్‌పై తన సగటు కంటే బలంగా ఉందని అర్థం.
    రుణాత్మకంగా ఉంటే దానికి వ్యతిరేకం. అవుట్‌పుట్ ఒక absolute ratio కాకుండా తన
    సొంత సగటు నుంచి విచలనం (deviation) కాబట్టి, రెండు వేర్వేరు స్క్రిప్ట్‌ల
    రీడింగ్‌లను పోల్చవచ్చు. Stan Weinstein వీక్లీ చార్ట్‌లపై 52 బేస్ వాడేవారు.

తరువాత ఎంచుకున్న అవుట్‌పుట్‌పై మూవింగ్ యావరేజ్ లెక్కించబడుతుంది. మూడు రకాల
మూవింగ్ యావరేజ్‌లూ ప్రతి బార్‌పై లెక్కించి, ఆ తర్వాతే ఎంపిక జరుగుతుంది. అందువల్ల
టైప్ మార్చినప్పుడు లెక్కింపు చరిత్ర దెబ్బతినదు.

గమనిక: తక్కువ వ్యవధిలో మోడ్ 3 మరియు మోడ్ 4, మోడ్ 1 మరియు 2 తో విభేదించవచ్చు. అది
తప్పు కాదు, సహజం. మోడ్ 3 ఒక నిర్ణీత విండోలో మార్పు రేటును కొలుస్తుంది, మోడ్ 1
మరియు 2 స్థాయిని కొలుస్తాయి.

పేన్‌ను ఎలా చదవాలి

ప్రధాన లైన్
    పైకి వెళ్తుంటే చార్ట్ స్క్రిప్ట్ బెంచ్‌మార్క్ కంటే మెరుగ్గా ఉంది. కిందికి
    వెళ్తుంటే వెనుకబడి ఉంది. ఫ్లాట్‌గా ఉంటే బెంచ్‌మార్క్‌తో పాటే కదులుతోంది.

లైన్ రంగు మరియు షేడెడ్ బ్యాండ్
    డిఫాల్ట్‌గా లైన్ తన మూవింగ్ యావరేజ్ పైన ఉందా కిందా అన్నదాన్ని బట్టి రంగు
    మారుతుంది. రంగు మారిన క్షణమే లీడర్‌షిప్ మారుతున్న క్షణం, ఇది సాధారణంగా
    లైన్ వాలు (slope) కంటితో కనిపించే ముందే వస్తుంది.

బూడిద రంగు మూవింగ్ యావరేజ్ లైన్
    రిలేటివ్ స్ట్రెంత్ లైన్‌కు స్మూత్ చేసిన రిఫరెన్స్. రంగు లాజిక్‌కు మరియు
    క్రాస్‌ఓవర్ అలర్ట్‌లకు ఇదే ఆధారం.

జీరో లైన్
    శాతం మోడ్‌లో మరియు Mansfield మోడ్‌లో మాత్రమే ఆటోమేటిక్‌గా వస్తుంది.
    ఎందుకంటే ఆ రెండు మోడ్‌లే సున్నా చుట్టూ కేంద్రీకృతమై ఉంటాయి.

త్రిభుజాలు (Triangles)
    పేన్ కింద పైకి చూపే త్రిభుజం అంటే లుక్‌బ్యాక్‌లో రిలేటివ్ స్ట్రెంత్ కొత్త హై
    చేసింది. పైన కిందికి చూపే త్రిభుజం అంటే కొత్త లో చేసింది. ఇవి ధరపై కాదు,
    రిలేటివ్ స్ట్రెంత్ లైన్‌పై పని చేస్తాయి.

టేబుల్
    కుడి పైన ఉంటుంది. ప్రస్తుత బెంచ్‌మార్క్, ప్రస్తుత రీడింగ్, outperforming
    లేదా underperforming స్థితి, మరియు లుక్‌బ్యాక్‌లో శాతం తేడా చూపిస్తుంది.

ఎలా ఉపయోగించాలి

బ్రాడ్ ఇండెక్స్‌తో పోల్చి స్క్రిప్ట్‌లను ఎంచుకోవడం
    బెంచ్‌మార్క్‌గా బ్రాడ్ ఇండెక్స్ పెట్టి Ratio x100 వాడండి. ఏ స్క్రిప్ట్‌ల
    రిలేటివ్ స్ట్రెంత్ లైన్ హయ్యర్ హైస్ చేస్తోందో అవి లాంగ్ వైపు అభ్యర్థులు.
    లోయర్ లోస్ చేస్తున్నవి షార్ట్ వైపు అభ్యర్థులు. డబ్బు ఎక్కడికి
    తిరుగుతోందో ఫిల్టర్ చేయడమే ఇక్కడ పని, ఎంట్రీ నిర్ణయం ఇంకా కాదు.

రెండు దశల టాప్ డౌన్ ఫిల్టర్
    ముందు సెక్టార్ ఇండెక్స్‌ను చార్ట్‌లో పెట్టి, బ్రాడ్ ఇండెక్స్‌ను
    బెంచ్‌మార్క్‌గా పెట్టండి. సెక్టార్ లీడ్ చేస్తోందా అన్నది తెలుస్తుంది.
    తర్వాత ఒక్కో స్క్రిప్ట్‌ను చార్ట్‌లో పెట్టి, ఆ సెక్టార్ ఇండెక్స్‌ను
    బెంచ్‌మార్క్‌గా పెట్టండి. బలమైన సెక్టార్ లోపల బలంగా ఉన్న స్క్రిప్ట్,
    ఒంటరిగా బలంగా ఉన్న స్క్రిప్ట్ కంటే మెరుగైన అభ్యర్థి.

ధర కంటే ముందు రిలేటివ్ స్ట్రెంత్
    ధర ఇంకా రేంజ్‌లో లేదా బేస్‌లో ఉండగానే పైకి చూపే త్రిభుజం వస్తే గమనించండి.
    ఇది తరచుగా ప్రైస్ బ్రేక్‌అవుట్ కంటే ముందే కనిపిస్తుంది. దీనికి వ్యతిరేకం
    ఒక హెచ్చరిక: ధర కొత్త హై చేస్తోంది కానీ రిలేటివ్ స్ట్రెంత్ లైన్ చేయడం
    లేదు. అంటే ఆ కదలికను మొత్తం మార్కెట్ మోస్తోంది, ఆ స్క్రిప్ట్‌కు ప్రత్యేకమైన
    డిమాండ్ కాదు.

దీర్ఘకాలిక పొజిషనల్ ఫిల్టర్
    వీక్లీ చార్ట్‌పై Mansfield మోడ్‌కు మారి, బేస్ 52 పెట్టండి. జీరో లైన్‌ను ఒక
    రెజీమ్ ఫిల్టర్‌గా వాడండి. రీడింగ్ సున్నా పైన ఉన్నప్పుడు మాత్రమే లాంగ్ వైపు
    సెటప్‌లను పరిశీలించండి.

ఇంట్రాడేలో రెండు ఇండెక్స్‌లను పోల్చడం
    ఒక ఇండెక్స్‌ను చార్ట్‌లో పెట్టి, రెండో ఇండెక్స్‌ను బెంచ్‌మార్క్‌గా పెట్టి,
    తక్కువ లుక్‌బ్యాక్‌తో శాతం మోడ్ వాడండి. ఆ రోజు ఏ ఇండెక్స్ లీడ్ చేస్తోందో
    తెలుస్తుంది. దిశాత్మక అభిప్రాయాన్ని ఏ ఇన్‌స్ట్రుమెంట్‌లో వ్యక్తపరచాలో
    నిర్ణయించుకోవడానికి ఇది ఉపయోగపడుతుంది.

స్ప్రెడ్ విశ్లేషణ
    నిష్పత్తి అంటే రెండు ఇన్‌స్ట్రుమెంట్ల మధ్య స్ప్రెడ్ కాబట్టి, రెండు
    కోరిలేటెడ్ స్క్రిప్ట్‌ల పెయిర్ విశ్లేషణకు మోడ్ 1 నేరుగా వాడుకోవచ్చు.

ఇన్‌పుట్‌లు

Benchmark symbol
    దేనితో పోల్చాలో ఆ ఇన్‌స్ట్రుమెంట్. డిఫాల్ట్‌గా ఒక బ్రాడ్ ఇండెక్స్.

Price source
    ప్రతి బార్‌లో ఏ ధరను వాడాలి అన్నది. చార్ట్ స్క్రిప్ట్‌కు మరియు
    బెంచ్‌మార్క్‌కు ఇదే వర్తిస్తుంది. సాధారణంగా close వాడతారు.

Display mode
    పైన చెప్పిన నాలుగు లెక్కల్లో ఒకదాన్ని ఎంచుకుంటుంది.

RS moving average type and length
    రిలేటివ్ స్ట్రెంత్ లైన్‌పై వేసే స్మూతింగ్. రంగు మరియు క్రాస్‌ఓవర్
    అలర్ట్‌లకు ఇది ఆధారం.

Mansfield base length
    Mansfield నార్మలైజేషన్‌కు బేస్ పీరియడ్. వీక్లీ చార్ట్‌లపై 52 అనేది అసలు
    పద్ధతి. డైలీ చార్ట్‌లపై 200 దగ్గర ఉండే విలువ దానికి దగ్గరి సమానం.

Percent performance lookback
    మోడ్ 3 వాడే విండో, టేబుల్‌లో చూపే శాతానికి కూడా ఇదే విండో.

New RS high and low lookback
    రిలేటివ్ స్ట్రెంత్ లైన్ కొత్త ఎక్స్‌ట్రీమ్ చేసిందా అని నిర్ణయించే విండో.

Visual settings
    మూవింగ్ యావరేజ్, షేడింగ్, త్రిభుజాలు, టేబుల్ ఆన్ ఆఫ్ చేసే టోగుల్‌లు,
    మరియు outperforming, underperforming స్థితులకు రెండు రంగులు.

అలర్ట్‌లు

నాలుగు అలర్ట్ కండిషన్‌లు ఉన్నాయి:
    రిలేటివ్ స్ట్రెంత్ తన మూవింగ్ యావరేజ్‌ను పైకి దాటడం.
    రిలేటివ్ స్ట్రెంత్ తన మూవింగ్ యావరేజ్‌ను కిందికి దాటడం.
    లుక్‌బ్యాక్‌లో కొత్త రిలేటివ్ స్ట్రెంత్ హై.
    లుక్‌బ్యాక్‌లో కొత్త రిలేటివ్ స్ట్రెంత్ లో.

పరిమితులు, మరియు ఇది ఏమి కాదు

ఇది ఒక సెలక్షన్ మరియు కాంటెక్స్ట్ టూల్. లీడర్‌షిప్ ఎక్కడ ఉందో చెబుతుంది.
ఎప్పుడు ఎంటర్ కావాలో, ఎప్పుడు ఎగ్జిట్ కావాలో చెప్పదు. దీన్ని ఒంటరిగా సిగ్నల్‌గా
వాడేలా రూపొందించలేదు.

దీని అవుట్‌పుట్‌కు నిర్దిష్ట పరిమితులు (bounds) లేవు. కాబట్టి ఓవర్‌బాట్,
ఓవర్‌సోల్డ్ స్థాయిలు అంటూ ఏమీ ఉండవు. అలా వాడితే ఫలితాలు సరిగా ఉండవు.

రెండు వేర్వేరు స్క్రిప్ట్‌ల ముడి నిష్పత్తి విలువలను ఒకదానితో ఒకటి పోల్చలేము,
ఎందుకంటే ప్రతి జతకు దాని సొంత ఏకపక్ష స్థాయి ఉంటుంది. చాలా స్క్రిప్ట్‌లను
ర్యాంక్ చేయాలంటే Mansfield లేదా శాతం మోడ్ వాడండి.

అడ్జస్ట్ చేయని డేటా లైన్‌ను వక్రీకరిస్తుంది. స్ప్లిట్, బోనస్ వంటి కార్పొరేట్
యాక్షన్ జరిగి డేటా సిరీస్ అడ్జస్ట్ కాకపోతే, రిలేటివ్ స్ట్రెంత్‌తో సంబంధం లేని
ఒక బ్రేక్ లైన్‌లో కనిపిస్తుంది.

బెంచ్‌మార్క్ మరియు చార్ట్ స్క్రిప్ట్ ఒకే సెషన్‌లో ట్రేడ్ కాకపోతే, సెషన్ అంచుల
దగ్గర రీడింగ్‌లు నమ్మదగినవి కాకపోవచ్చు.

నిరాకరణ (Disclaimer)

ఈ స్క్రిప్ట్ విద్యాపరమైన సాంకేతిక విశ్లేషణ సాధనంగా మాత్రమే ప్రచురించబడింది. ఇది
పెట్టుబడి సలహా కాదు, ఏ సెక్యూరిటీని కొనమని లేదా అమ్మమని ఇచ్చే సిఫారసు కాదు. గత
లేదా భవిష్యత్ పనితీరు గురించి ఎటువంటి వాదన చేయడం లేదు. సెక్యూరిటీలు మరియు
డెరివేటివ్‌లలో ట్రేడింగ్, పెట్టుబడులకు గణనీయమైన నష్ట ప్రమాదం ఉంటుంది. ఏదైనా
పెట్టుబడి నిర్ణయం తీసుకునే ముందు SEBI రిజిస్టర్డ్ ఇన్వెస్ట్‌మెంట్ అడ్వైజర్‌ను
సంప్రదించండి, మరియు మీ సొంత రిస్క్ మేనేజ్‌మెంట్‌కు మీరే బాధ్యత వహించండి.

---

## Source Code

````pine
//@version=6
// =====================================================================
//  COMPARATIVE RELATIVE STRENGTH (CRS)  —  Market Discipline Telugu
// ---------------------------------------------------------------------
//  Compares the chart symbol against a benchmark (default NSE:NIFTY).
//
//    Line RISING   = chart symbol is OUTPERFORMING the benchmark
//    Line FALLING  = chart symbol is UNDERPERFORMING the benchmark
//    Line FLAT     = moving in line with the benchmark
//
//  NOTE: this is NOT Wilder's RSI. RSI compares a stock to its own
//  past. CRS compares a stock to another instrument. The absolute
//  value of the line is meaningless - only its DIRECTION matters.
// =====================================================================

indicator("Comparative Relative Strength Multi-Mode [MDT]", shorttitle="CRS [MDT]", overlay=false)

// ----------------------------- INPUTS --------------------------------
gD = "Data"
compSym = input.symbol("NSE:NIFTY", "Benchmark symbol", group=gD,
     tooltip="Stock vs NSE:NIFTY, or stock vs its own sector index, or NSE:BANKNIFTY vs NSE:NIFTY.")
srcType = input.string("close", "Price source", options=["close","open","high","low","hl2","hlc3","ohlc4"], group=gD)

gC = "Calculation"
mode = input.string("Ratio x100", "Display mode",
     options=["Ratio","Ratio x100","% Out/Under-performance","Mansfield RS"], group=gC,
     tooltip="Ratio = raw price relative. % Out/Under-performance = symbol's % move minus benchmark's % move over the lookback. Mansfield RS = Stan Weinstein's normalised version with a zero line.")
maType  = input.string("EMA", "RS moving average type", options=["SMA","EMA","WMA"], group=gC)
maLen   = input.int(21, "RS moving average length", minval=1, group=gC)
mansLen = input.int(52, "Mansfield base length", minval=2, group=gC,
     tooltip="Weinstein used 52 on weekly charts. Use 200 or so on daily charts.")
perfLen = input.int(20, "% performance lookback (bars)", minval=1, group=gC)
hiLoLen = input.int(60, "New RS high / low lookback (bars)", minval=2, group=gC)

gV = "Visuals"
colByMA   = input.bool(true,  "Colour RS line by position vs its MA", group=gV)
showMA    = input.bool(true,  "Show RS moving average", group=gV)
showFill  = input.bool(true,  "Shade between RS and its MA", group=gV)
showNewHL = input.bool(true,  "Mark new RS highs / lows", group=gV)
showTable = input.bool(true,  "Show reading table", group=gV)
upCol     = input.color(#089981, "Outperforming",   inline="c", group=gV)
dnCol     = input.color(#f23645, "Underperforming", inline="c", group=gV)

// ---------------------------- HELPERS --------------------------------
// Source selector. No ta.* calls inside, so a switch is safe here.
f_src(t) =>
    switch t
        "open"  => open
        "high"  => high
        "low"   => low
        "hl2"   => hl2
        "hlc3"  => hlc3
        "ohlc4" => ohlc4
        => close

// MA selector. All three are computed on EVERY bar and only then
// selected, so the moving averages never develop a broken history.
f_ma(s, len, t) =>
    smaV = ta.sma(s, len)
    emaV = ta.ema(s, len)
    wmaV = ta.wma(s, len)
    t == "EMA" ? emaV : t == "WMA" ? wmaV : smaV

// ------------------------ CORE CALCULATION ---------------------------
base = f_src(srcType)
comp = request.security(compSym, timeframe.period, f_src(srcType),
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// 1. Raw price relative
ratio = comp != 0 ? base / comp : na

// 2. Percentage out/under-performance over the lookback
basePerf = nz(base[perfLen]) != 0 ? (base / base[perfLen] - 1) * 100 : na
compPerf = nz(comp[perfLen]) != 0 ? (comp / comp[perfLen] - 1) * 100 : na
spread   = basePerf - compPerf

// 3. Mansfield RS  =  ((ratio / SMA(ratio, n)) - 1) * 100
ratioSma  = ta.sma(ratio, mansLen)
mansfield = nz(ratioSma) != 0 ? (ratio / ratioSma - 1) * 100 : na

rs = switch mode
    "Ratio"                   => ratio
    "Ratio x100"              => ratio * 100
    "% Out/Under-performance" => spread
    => mansfield

rsMa = f_ma(rs, maLen, maType)

// ---------------------------- STATE ----------------------------------
zeroMode = mode == "% Out/Under-performance" or mode == "Mansfield RS"

isUp = colByMA
     ? (not na(rs) and not na(rsMa) ? rs > rsMa : false)
     : (not na(rs) and not na(rs[1]) ? rs > rs[1] : false)

rsCol = isUp ? upCol : dnCol

hiV = ta.highest(rs, hiLoLen)
loV = ta.lowest(rs, hiLoLen)
newHi = showNewHL and not na(rs) and not na(hiV) ? rs >= hiV : false
newLo = showNewHL and not na(rs) and not na(loV) ? rs <= loV : false

// ----------------------------- PLOTS ---------------------------------
pRs = plot(rs, "CRS", color=rsCol, linewidth=2)
pMa = plot(showMA ? rsMa : na, "CRS MA", color=color.new(color.gray, 20), linewidth=1)
fill(pRs, pMa, color=showFill ? color.new(rsCol, 88) : na, title="RS vs MA")

plot(zeroMode ? 0 : na, "Zero line", color=color.new(color.gray, 40), style=plot.style_line)

plotshape(newHi, "New RS high", shape.triangleup,   location.bottom, upCol, size=size.tiny)
plotshape(newLo, "New RS low",  shape.triangledown, location.top,    dnCol, size=size.tiny)

// ----------------------------- TABLE ---------------------------------
var table tbl = table.new(position.top_right, 2, 4,
     bgcolor=color.new(color.black, 82), border_width=1, border_color=color.new(color.gray, 60))

f_txt(v, fmt) => na(v) ? "n/a" : str.tostring(v, fmt)

if showTable and barstate.islast
    table.cell(tbl, 0, 0, "Benchmark", text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, compSym,     text_color=color.white, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 1, "CRS",            text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, f_txt(rs, "#.###"), text_color=color.white, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "Trend",  text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, isUp ? "Outperforming" : "Underperforming",
         text_color=rsCol, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 3, str.tostring(perfLen) + "-bar edge", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 3, f_txt(spread, "#.##") + "%",
         text_color=nz(spread) >= 0 ? upCol : dnCol, text_size=size.small, text_halign=text.align_right)

// ----------------------------- ALERTS --------------------------------
alertcondition(ta.crossover(rs, rsMa),  "CRS crossed above its MA",
     "Relative strength turning up - symbol starting to outperform the benchmark")
alertcondition(ta.crossunder(rs, rsMa), "CRS crossed below its MA",
     "Relative strength turning down - symbol starting to underperform the benchmark")
alertcondition(newHi, "CRS new high", "Relative strength has made a new high for the lookback period")
alertcondition(newLo, "CRS new low",  "Relative strength has made a new low for the lookback period")
````
