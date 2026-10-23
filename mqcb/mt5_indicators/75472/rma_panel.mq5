//+------------------------------------------------------------------+
//|                                                    RMA_Panel.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright   "MMQ — Muhammad Minhas Qamar"
#property link        "https://www.mql5.com/en/articles/23693"
#property description "Re-plots one group of RMA_Engine buffers in its own window."
#property version     "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE

#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| A window is not a plot budget - it is a scale.                   |
//|                                                                  |
//|  One indicator renders into exactly one window, and the engine   |
//|  already owns a window whose vertical axis runs 0 to 1 because   |
//|  that is where the fractiles live. D_k shares that range, but    |
//|  d_med_w is centred on zero, and the rma family is measured in   |
//|  fractions of a percent. Put together they would render as flat  |
//|  lines and one that moves.                                       |
//|                                                                  |
//|  So this file exists to borrow a second axis. It computes        |
//|  nothing: it locates the engine already attached to the chart,   |
//|  reads three of its buffers, and draws them. The engine stays    |
//|  the single source of every number, which is the property worth  |
//|  protecting - a panel that recomputed would eventually disagree  |
//|  with the trades, and the disagreement would be invisible.       |
//|                                                                  |
//|  Locating the engine rather than instantiating one matters for   |
//|  the same reason. iCustom with a duplicated input list would     |
//|  bind to whatever those inputs happened to say, and one stale    |
//|  parameter would silently produce a second, different engine     |
//|  drawn beside the real one.                                      |
//+------------------------------------------------------------------+

input ENUM_RMA_PANEL_MODE InpMode = RMA_PANEL_ADVERSE;  // What to draw

input group "=== Adverse thresholds (guide lines) ==="
input double InpAdverseThresholdDown = 0.3;   // D_k below this = trending down
input double InpAdverseThresholdUp   = 0.7;   // D_k above this = trending up

double BufA[];
double BufB[];
double BufC[];

//--- which engine buffers this mode maps onto, filled in OnInit.
int    g_source[3];
int    g_engine=INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Dress one plot.                                                  |
//+------------------------------------------------------------------+
void Configure(const int plot,const string label,const color clr,
               const int style,const int width)
  {
   PlotIndexSetString(plot,PLOT_LABEL,label);
   PlotIndexSetInteger(plot,PLOT_LINE_COLOR,clr);
   PlotIndexSetInteger(plot,PLOT_LINE_STYLE,style);
   PlotIndexSetInteger(plot,PLOT_LINE_WIDTH,width);
   PlotIndexSetDouble(plot,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| Guide lines, one set per mode.                                   |
//+------------------------------------------------------------------+
void SetupLevels(const int count,const double &values[])
  {
   IndicatorSetInteger(INDICATOR_LEVELS,count);
   for(int i=0;i<count;i++)
     {
      IndicatorSetDouble(INDICATOR_LEVELVALUE,i,values[i]);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,i,clrDimGray);
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,i,STYLE_DOT);
     }
  }

//+------------------------------------------------------------------+
//| Map the chosen mode onto three engine buffers and three plots.   |
//+------------------------------------------------------------------+
string ApplyMode(void)
  {
   if(InpMode==RMA_PANEL_ADVERSE)
     {
      g_source[0]=RMA_BUF_D_K;
      g_source[1]=RMA_BUF_D_MED_W;
      g_source[2]=-1;
      Configure(0,"D_k",clrGold,STYLE_SOLID,2);
      Configure(1,"d_med_w",clrSilver,STYLE_SOLID,1);
      Configure(2,"",clrNONE,STYLE_SOLID,1);

      double levels[]={InpAdverseThresholdDown,0.0,0.5,InpAdverseThresholdUp};
      SetupLevels(4,levels);
      return "RMA Panel: adverse movement";
     }

   g_source[0]=RMA_BUF_RMA_W;
   g_source[1]=RMA_BUF_RMA_MIN;
   g_source[2]=RMA_BUF_RMA_MAX;
   Configure(0,"rma_w",clrDodgerBlue,STYLE_SOLID,2);
   Configure(1,"rma_min",clrTomato,STYLE_SOLID,1);
   Configure(2,"rma_max",clrLimeGreen,STYLE_SOLID,1);

   double levels[]={0.0};
   SetupLevels(1,levels);
   return "RMA Panel: rma family";
  }

//+------------------------------------------------------------------+
//| Find the engine already attached to this chart.                  |
//|  Matching on the short name's prefix rather than the whole       |
//|  string is deliberate: the engine appends its window length, so  |
//|  the panel keeps working when that is retuned - which is exactly |
//|  when a hand-built iCustom handle would quietly fork into a      |
//|  second calculation.                                             |
//+------------------------------------------------------------------+
int ResolveEngine(void)
  {
   long chart=ChartID();
   int  windows=(int)ChartGetInteger(chart,CHART_WINDOWS_TOTAL);

   for(int w=0;w<windows;w++)
     {
      int total=ChartIndicatorsTotal(chart,w);
      for(int k=0;k<total;k++)
        {
         string name=ChartIndicatorName(chart,w,k);
         if(StringFind(name,"RMA Engine")==0)
            return ChartIndicatorGet(chart,w,name);
        }
     }
   return INVALID_HANDLE;
  }

//+------------------------------------------------------------------+
//| Panel init: bind buffers and dress the window.                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(0,BufA,INDICATOR_DATA);
   SetIndexBuffer(1,BufB,INDICATOR_DATA);
   SetIndexBuffer(2,BufC,INDICATOR_DATA);

   string title=ApplyMode();
   IndicatorSetString(INDICATOR_SHORTNAME,title);
   IndicatorSetInteger(INDICATOR_DIGITS,4);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Release the reference ChartIndicatorGet took out.                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_engine!=INVALID_HANDLE)
     {
      IndicatorRelease(g_engine);
      g_engine=INVALID_HANDLE;
     }
  }

//+------------------------------------------------------------------+
//| Copy one engine buffer into one panel buffer.                    |
//|  The temporary is not redundant. CopyBuffer counts its start     |
//|  position back from the newest bar, so it fills element zero     |
//|  with the oldest bar it was asked for - which is bar 'from',     |
//|  not bar zero. Landing it straight in the plot would shift the   |
//|  whole series left by the length of the history.                 |
//+------------------------------------------------------------------+
bool Pull(const int source,double &dest[],const int total,const int from)
  {
   if(source<0)
     {
      for(int i=from;i<total;i++)
         dest[i]=EMPTY_VALUE;
      return true;
     }

   int count=total-from;
   double tmp[];
   ArraySetAsSeries(tmp,false);
   if(CopyBuffer(g_engine,source,0,count,tmp)!=count)
      return false;

   for(int j=0;j<count;j++)
      dest[from+j]=tmp[j];
   return true;
  }

//+------------------------------------------------------------------+
//| Panel calculation: three copies, no arithmetic.                  |
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
   if(g_engine==INVALID_HANDLE)
     {
      g_engine=ResolveEngine();
      if(g_engine==INVALID_HANDLE)
        {
         //--- the engine may simply not be attached yet on a fresh
         //--- chart. Returning zero asks to be called again rather
         //--- than declaring a failure the user cannot act on.
         return 0;
        }
     }

   int from=(prev_calculated>0)?prev_calculated-1:0;
   if(from>=rates_total)
      return rates_total;

   if(!Pull(g_source[0],BufA,rates_total,from))
      return 0;
   if(!Pull(g_source[1],BufB,rates_total,from))
      return 0;
   if(!Pull(g_source[2],BufC,rates_total,from))
      return 0;

   return rates_total;
  }
//+------------------------------------------------------------------+
