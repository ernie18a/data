//+------------------------------------------------------------------+
//|                                                   RMA_Engine.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright   "MMQ — Muhammad Minhas Qamar"
#property link        "https://www.mql5.com/en/articles/23693"
#property description "Relative Moving Average fractiles and the state the EA trades on."
#property version     "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 19
#property indicator_plots   6
#property indicator_minimum 0.0
#property indicator_maximum 1.0

#property indicator_label1  "Regime"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_width1  5

#property indicator_label2  "f_w"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2

#property indicator_label3  "f_min"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrTomato
#property indicator_style3  STYLE_DOT

#property indicator_label4  "f_max"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_DOT

#property indicator_label5  "alpha_lo_mean"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrMediumPurple

#property indicator_label6  "alpha_hi_mean"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrange

#include <RMA\RmaCore.mqh>
#include <RMA\RegimeDetector.mqh>
#include <RMA\AdverseMonitor.mqh>

//+------------------------------------------------------------------+
//| The engine every other RMA component reads from.                 |
//|                                                                  |
//|  Putting the arithmetic in an indicator rather than in the EA    |
//|  buys three things at once. The series become visible without a  |
//|  second implementation to keep in step; they get recomputed on   |
//|  closed bars through prev_calculated, which is the natural       |
//|  idiom here rather than something to remember; and the EA is     |
//|  left holding only decisions, which is all it should own.        |
//|                                                                  |
//|  Six plots are drawn here. The rest of the buffers exist so the  |
//|  Expert and the passthrough panels can read the same numbers     |
//|  with CopyBuffer instead of recomputing them, which is the only  |
//|  way to be certain the chart and the trades agree.               |
//|                                                                  |
//|  This file deliberately holds no mathematics. Every series is    |
//|  produced by a class in Include\RMA, and what remains here is    |
//|  binding buffers, forwarding inputs and copying results out -    |
//|  so the same classes can serve a script or a tester harness      |
//|  with nothing stubbed.                                           |
//+------------------------------------------------------------------+

input group "=== Window ==="
input int      InpWindowSize        = 106;      // Window size (W)
input int      InpSmoothingPeriod   = 10;       // Smoothing period for the alpha means

input group "=== Regime detection ==="
input double   InpEpsilonLow        = 0.15;     // Epsilon low (contraction threshold)
input double   InpEpsilonHigh       = 3.0;      // Epsilon high (expansion threshold)
input double   InpSlopeThreshold    = 0.0001;   // Slope threshold for regime transition
input int      InpRegimeLookback    = 20;       // Lookback for slope and variation ratio
input double   InpVariationRatioLow = 0.1;      // Variation ratio below this reads as steady
input double   InpZScoreExpansion   = 1.0;      // Z-score above this reads as expansion
input int      InpRangeHistoryLookback = 100;   // Range min/max envelope (0 = unlimited)

input group "=== Adverse movement ==="
input int      InpAdverseLookback   = 10;       // Lookback bars for D_k

input group "=== Reference lines ==="
input double   InpEntryUpperThreshold = 0.9;    // f_w that arms a downward traversal
input double   InpEntryLowerThreshold = 0.1;    // f_w that arms an upward traversal

input group "=== Panels ==="
input bool     InpAutoAttachPanels  = true;     // Open the passthrough panels automatically
input bool     InpPanelAdverse      = true;     // Panel: D_k and d_med_w
input bool     InpPanelRmaValues    = false;    // Panel: rma_w / rma_min / rma_max
input double   InpAdverseThresholdDown = 0.3;   // D_k below this = trending down
input double   InpAdverseThresholdUp   = 0.7;   // D_k above this = trending up

input group "=== Regime backdrop ==="
input bool     InpShowRegimeBand    = true;                   // Shade the window by regime
input color    InpColorExpansion    = C'20,45,25';            // Expansion
input color    InpColorContraction  = C'50,25,25';            // Contraction
input color    InpColorToContraction= C'45,40,20';            // Expansion rolling over
input color    InpColorToExpansion   = C'20,35,50';           // Contraction breaking out

//--- plotted
double BufRegimeBg[];
double BufRegimeColor[];
double BufFw[];
double BufFMin[];
double BufFMax[];
double BufAlphaLoMean[];
double BufAlphaHiMean[];
//--- calculation only
double BufSma[];
double BufRmaW[];
double BufRma1[];
double BufRmaMid[];
double BufRmaMin[];
double BufRmaMax[];
double BufRange[];
double BufAlphaLo[];
double BufAlphaHi[];
double BufRegime[];
double BufDk[];
double BufDMedW[];

CRmaCore         g_core;
CRegimeDetector  g_regime;
CAdverseMonitor  g_adverse;

//--- panels are attached once, on the first calculation rather than
//--- in OnInit: an indicator being loaded is not yet on the chart it
//--- is about to be on, so ChartIndicatorAdd there has nothing to
//--- add to and the subwindow count it would read is a bar behind.
bool g_panels_attached=false;

//--- short names the panels publish, which is also how they are
//--- recognised on the chart. They must match RMA_Panel's OnInit.
const string PanelName[2]=
  {
   "RMA Panel: adverse movement",
   "RMA Panel: rma family"
  };

//+------------------------------------------------------------------+
//| Mark one bar as carrying no value in every buffer.               |
//|  EMPTY_VALUE rather than zero, so a reader that arrives during   |
//|  warmup sees "absent" instead of a plausible number. The colour  |
//|  index is the exception: it is an index, not a measurement, and  |
//|  an out-of-range one has nothing sensible to select.             |
//+------------------------------------------------------------------+
void ClearBar(const int i)
  {
   BufRegimeBg[i]=EMPTY_VALUE;
   BufRegimeColor[i]=0.0;
   BufFw[i]=EMPTY_VALUE;
   BufFMin[i]=EMPTY_VALUE;
   BufFMax[i]=EMPTY_VALUE;
   BufAlphaLoMean[i]=EMPTY_VALUE;
   BufAlphaHiMean[i]=EMPTY_VALUE;
   BufSma[i]=EMPTY_VALUE;
   BufRmaW[i]=EMPTY_VALUE;
   BufRma1[i]=EMPTY_VALUE;
   BufRmaMid[i]=EMPTY_VALUE;
   BufRmaMin[i]=EMPTY_VALUE;
   BufRmaMax[i]=EMPTY_VALUE;
   BufRange[i]=EMPTY_VALUE;
   BufAlphaLo[i]=EMPTY_VALUE;
   BufAlphaHi[i]=EMPTY_VALUE;
   BufRegime[i]=EMPTY_VALUE;
   BufDk[i]=EMPTY_VALUE;
   BufDMedW[i]=EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Bind every buffer to its agreed index.                           |
//|  The order here is the enum's order, and it has to stay that     |
//|  way: MQL5 hands plot N to the Nth INDICATOR_DATA buffer, so a   |
//|  swap would silently repaint one series as another.              |
//+------------------------------------------------------------------+
void BindBuffers(void)
  {
   SetIndexBuffer(RMA_BUF_REGIME_BG,     BufRegimeBg,      INDICATOR_DATA);
   SetIndexBuffer(RMA_BUF_REGIME_COLOR,  BufRegimeColor,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(RMA_BUF_FW,            BufFw,            INDICATOR_DATA);
   SetIndexBuffer(RMA_BUF_FMIN,          BufFMin,          INDICATOR_DATA);
   SetIndexBuffer(RMA_BUF_FMAX,          BufFMax,          INDICATOR_DATA);
   SetIndexBuffer(RMA_BUF_ALPHA_LO_MEAN, BufAlphaLoMean,   INDICATOR_DATA);
   SetIndexBuffer(RMA_BUF_ALPHA_HI_MEAN, BufAlphaHiMean,   INDICATOR_DATA);

   SetIndexBuffer(RMA_BUF_SMA,           BufSma,           INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RMA_W,         BufRmaW,          INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RMA_1,         BufRma1,          INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RMA_MID,       BufRmaMid,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RMA_MIN,       BufRmaMin,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RMA_MAX,       BufRmaMax,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_RANGE,         BufRange,         INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_ALPHA_LO,      BufAlphaLo,       INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_ALPHA_HI,      BufAlphaHi,       INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_REGIME,        BufRegime,        INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_D_K,           BufDk,            INDICATOR_CALCULATIONS);
   SetIndexBuffer(RMA_BUF_D_MED_W,       BufDMedW,         INDICATOR_CALCULATIONS);
  }

//+------------------------------------------------------------------+
//| Draw the levels the strategy actually reacts to.                 |
//|  Hard-coded 0.1 / 0.9 guides would be a lie the moment somebody  |
//|  retunes the entries, so the lines are built from the same       |
//|  inputs the EA is given. A chart that disagrees with the rules   |
//|  is worse than a chart with no guides at all.                    |
//|                                                                  |
//|  Three lines, because there are three levels the rules name.     |
//|  The outer pair is where a traversal arms; the dashed middle is  |
//|  the median a cross-reverse has to still be on the right side    |
//|  of to be entered, and crossing it is what closes the position.  |
//+------------------------------------------------------------------+
void SetupLevels(void)
  {
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,InpEntryLowerThreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,InpEntryUpperThreshold);

   for(int i=0;i<3;i++)
     {
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,i,(i==1)?clrGray:clrDimGray);
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,i,(i==1)?STYLE_DASH:STYLE_DOT);
     }
  }

//+------------------------------------------------------------------+
//| Palette for the regime backdrop, in ENUM_RMA_REGIME order.       |
//|  The colours are meant to be dark: this plot sits behind five    |
//|  lines and its job is to tint the window, not to compete with    |
//|  them. The unknown slot draws nothing at all, so a warmup does   |
//|  not open with a wash of colour that means "no answer yet".      |
//+------------------------------------------------------------------+
void SetupRegimePalette(void)
  {
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,RMA_REGIME_COLORS);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,RMA_REGIME_EXPANSION,      InpColorExpansion);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,RMA_REGIME_CONTRACTION,    InpColorContraction);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,RMA_REGIME_TO_CONTRACTION, InpColorToContraction);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,RMA_REGIME_TO_EXPANSION,   InpColorToExpansion);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,RMA_REGIME_UNKNOWN,        clrNONE);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
  }

//+------------------------------------------------------------------+
//| Is a panel with this short name already on the chart?            |
//+------------------------------------------------------------------+
bool PanelPresent(const string shortname)
  {
   long chart=ChartID();
   int  windows=(int)ChartGetInteger(chart,CHART_WINDOWS_TOTAL);
   for(int w=0;w<windows;w++)
     {
      int total=ChartIndicatorsTotal(chart,w);
      for(int k=0;k<total;k++)
        {
         if(ChartIndicatorName(chart,w,k)==shortname)
            return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Open one panel in a subwindow of its own.                        |
//|  Checked against the chart first, so a template that already     |
//|  carries the panels, or a reinitialisation after an input        |
//|  change, does not stack a second copy behind the first.          |
//+------------------------------------------------------------------+
void AttachPanel(const ENUM_RMA_PANEL_MODE mode)
  {
   string shortname=PanelName[mode];
   if(PanelPresent(shortname))
      return;

//--- the "" is RMA_Panel's `input group`, which occupies a parameter
//--- slot even though it holds no value. Without it the two thresholds
//--- shift up by one and the panel draws its lower guide at the upper
//--- threshold - wrong, and quietly so, because nothing fails to load.
   int handle=iCustom(_Symbol,_Period,"RMA\\RMA_Panel",
                      mode,
                      "",
                      InpAdverseThresholdDown,InpAdverseThresholdUp);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("could not load RMA_Panel for '%s'",shortname);
      return;
     }

//--- a subwindow index one past the last existing one is the request
//--- to create a new one; anything lower would land on top of a
//--- window that already has a tenant.
   if(!ChartIndicatorAdd(ChartID(),(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),handle))
      PrintFormat("could not attach '%s': error %d",shortname,GetLastError());

//--- the chart holds its own reference once the add succeeds.
   IndicatorRelease(handle);
  }

//+------------------------------------------------------------------+
//| Open whichever panels the user asked for.                        |
//+------------------------------------------------------------------+
void AttachPanels(void)
  {
   if(!InpAutoAttachPanels)
      return;
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return;

   if(InpPanelAdverse)
      AttachPanel(RMA_PANEL_ADVERSE);
   if(InpPanelRmaValues)
      AttachPanel(RMA_PANEL_RMA_VALUES);
  }

//+------------------------------------------------------------------+
//| Take the panels down with the engine, but only on removal.       |
//|  A chart change or a recompile also lands here, and a user who   |
//|  switched timeframe expects to find the layout they left.        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason!=REASON_REMOVE)
      return;

   long chart=ChartID();
   int  windows=(int)ChartGetInteger(chart,CHART_WINDOWS_TOTAL);
   for(int m=0;m<ArraySize(PanelName);m++)
     {
      for(int w=windows-1;w>=1;w--)
         ChartIndicatorDelete(chart,w,PanelName[m]);
     }
  }

//+------------------------------------------------------------------+
//| Indicator init: bind buffers, build the modules, dress the plot. |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   BindBuffers();

   if(!g_core.Init(InpWindowSize,InpSmoothingPeriod))
      return INIT_PARAMETERS_INCORRECT;

   if(!g_regime.Init(InpWindowSize,InpRegimeLookback,InpRangeHistoryLookback,
                     InpEpsilonLow,InpEpsilonHigh,InpSlopeThreshold,
                     InpVariationRatioLow,InpZScoreExpansion))
      return INIT_PARAMETERS_INCORRECT;

   if(!g_adverse.Init(InpAdverseLookback,g_core.FirstBar()))
      return INIT_PARAMETERS_INCORRECT;

//--- each plot starts where its own module can first answer, not at
//--- the longest warmup of the set: a shared start would hide the
//--- fractiles for the twenty bars the regime detector still needs.
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpShowRegimeBand?g_regime.FirstBar():INT_MAX);
   for(int p=1;p<RMA_PLOT_COUNT;p++)
      PlotIndexSetInteger(p,PLOT_DRAW_BEGIN,g_core.FirstBar());
   for(int p=0;p<RMA_PLOT_COUNT;p++)
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   SetupRegimePalette();
   SetupLevels();

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("RMA Engine (%d)",InpWindowSize));
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Copy the core's window statistics into their buffers.            |
//+------------------------------------------------------------------+
void EmitCore(const int total,const int from)
  {
   int start=(from<g_core.FirstBar())?g_core.FirstBar():from;
   for(int i=start;i<total;i++)
     {
      BufFw[i]          =g_core.Fw(i);
      BufFMin[i]        =g_core.FMin(i);
      BufFMax[i]        =g_core.FMax(i);
      BufAlphaLoMean[i] =g_core.AlphaLowerMean(i);
      BufAlphaHiMean[i] =g_core.AlphaUpperMean(i);

      BufSma[i]         =g_core.Sma(i);
      BufRmaW[i]        =g_core.RmaW(i);
      BufRma1[i]        =g_core.RmaFirst(i);
      BufRmaMid[i]      =g_core.RmaMid(i);
      BufRmaMin[i]      =g_core.RmaMin(i);
      BufRmaMax[i]      =g_core.RmaMax(i);
      BufRange[i]       =g_core.Range(i);
      BufAlphaLo[i]     =g_core.AlphaLower(i);
      BufAlphaHi[i]     =g_core.AlphaUpper(i);
     }
  }

//+------------------------------------------------------------------+
//| Copy the regime out, both as a number and as a backdrop.         |
//|  The band is a full-height bar carrying no information in its    |
//|  value - only in its colour - so it is kept out of the data      |
//|  window and left empty wherever the regime is undecided.         |
//+------------------------------------------------------------------+
void EmitRegime(const int total,const int from)
  {
   int start=(from<g_regime.FirstBar())?g_regime.FirstBar():from;
   for(int i=start;i<total;i++)
     {
      ENUM_RMA_REGIME r=g_regime.Regime(i);
      BufRegime[i]=(double)r;

      if(!InpShowRegimeBand || r==RMA_REGIME_UNKNOWN)
         continue;

      BufRegimeBg[i]   =1.0;
      BufRegimeColor[i]=(double)r;
     }
  }

//+------------------------------------------------------------------+
//| Copy the adverse-movement pair out.                              |
//+------------------------------------------------------------------+
void EmitAdverse(const int total,const int from)
  {
   int start=(from<g_adverse.FirstBar())?g_adverse.FirstBar():from;
   for(int i=start;i<total;i++)
     {
      BufDMedW[i]=g_adverse.DMedW(i);
      BufDk[i]   =(i>=g_adverse.FirstDk())?g_adverse.Dk(i):EMPTY_VALUE;
     }
  }

//+------------------------------------------------------------------+
//| Indicator calculation.                                           |
//|  Recomputing from prev_calculated-1 rather than prev_calculated  |
//|  is the whole point: the bar at prev_calculated-1 was the        |
//|  forming bar last pass, and its close only became final now.     |
//|  Leaving it alone would make f_w_diff a difference between two   |
//|  unfinished numbers.                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(!g_panels_attached)
     {
      g_panels_attached=true;
      AttachPanels();
     }

   if(rates_total<=g_regime.FirstBar()+1)
      return 0;

//--- CRmaCore reads a window as price[i-W+1 .. i], so the arrays have
//--- to run oldest-first. OnCalculate already delivers them that way;
//--- saying so explicitly keeps a silent reversal from ever being one
//--- default away.
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);

   int from=(prev_calculated>0)?prev_calculated-1:0;

   for(int i=(prev_calculated>0)?from:0;i<rates_total;i++)
      ClearBar(i);

   if(!g_core.Calculate(close,rates_total,from))
      return 0;
   EmitCore(rates_total,from);

//--- the modules read the buffers the core has just filled, not the
//--- core itself, so a panel or a test harness can drive them from
//--- CopyBuffer output with no change to the classes.
   if(g_regime.Calculate(BufRange,rates_total,from))
      EmitRegime(rates_total,from);

   if(g_adverse.Calculate(BufFw,rates_total,from))
      EmitAdverse(rates_total,from);

   return rates_total;
  }
//+------------------------------------------------------------------+
