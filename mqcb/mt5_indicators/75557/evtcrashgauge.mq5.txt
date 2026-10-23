//+------------------------------------------------------------------+
//|                                                EVTCrashGauge.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23278 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23278"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "EVT VaR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrangeRed
#property indicator_width1  2

#include <EVT\GPDModel.mqh>

//--- inputs
input int    Lookback        = 800;    // rolling window (bars) for the fit
input double ThresholdQuant  = 0.95;   // POT threshold quantile
input double Confidence      = 0.99;   // VaR/ES confidence
input int    RefitEvery      = 1;      // refit every N new bars
input bool   ShowPanel       = true;   // draw the on-chart text panel

//--- buffers
double VaRBuffer[];

//--- state
CGPDModel  g_model;
int        g_bars_since_fit=0;
string     g_prefix="EVTGauge_";

//--- last computed readout (for the panel)
double     g_var=0.0, g_es=0.0, g_xi=0.0;
int        g_exceed=0;
ENUM_GPD_STATUS g_status=GPD_NOT_FITTED;

//+------------------------------------------------------------------+
//| Indicator initialization: bind the buffer and build the panel.   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VaRBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Lookback);

   g_model.SetThresholdQuantile(ThresholdQuant);

   IndicatorSetString(INDICATOR_SHORTNAME,"EVT Crash Gauge");
   IndicatorSetInteger(INDICATOR_DIGITS,5);

   if(ShowPanel)
      CreatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator shutdown: remove the panel objects from the chart.     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
  }

//+------------------------------------------------------------------+
//| Build the downside-loss series from a window of closes ending at |
//| bar index 'end' (older->newer) and fit the GPD.                  |
//|  loss_i = max(0, -logreturn_i) = magnitude of a down move.       |
//+------------------------------------------------------------------+
bool FitWindow(const double &close[],int end,int total)
  {
   int start=end-Lookback;          // need Lookback returns
   if(start<1)
      return false;

   double losses[];
   int k=0;
   ArrayResize(losses,end-start+1);    // loop runs (end-start+1) times
   for(int i=start;i<=end;i++)
     {
      if(i<1 || i>=total)
         continue;
      if(close[i-1]<=0.0 || close[i]<=0.0)
         continue;
      double r=MathLog(close[i]/close[i-1]);   // log return
      double loss=(r<0.0)?-r:0.0;              // downside magnitude
      losses[k++]=loss;
     }
   if(k<Lookback/2)
      return false;           // window too sparse
   ArrayResize(losses,k);

   return g_model.Fit(losses,k);
  }

//+------------------------------------------------------------------+
//| Refit the GPD on the rolling window and update the VaR buffer    |
//| and the readout panel.                                           |
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
   if(rates_total<Lookback+2)
      return(rates_total);

//--- compute from the first fittable bar up to the last
   int begin=Lookback+1;
   int start=(prev_calculated>begin)?prev_calculated-1:begin;

   for(int bar=start;bar<rates_total;bar++)
     {
      bool do_fit=(bar==rates_total-1) || (g_bars_since_fit<=0);
      if(do_fit)
        {
         if(FitWindow(close,bar,rates_total))
           {
            g_status =g_model.Status();
            g_xi     =g_model.Xi();
            g_exceed =g_model.ExceedanceCount();
            g_var    =g_model.VaR(Confidence);
            g_es     =g_model.ExpectedShortfall(Confidence);
           }
         else
            g_status=g_model.Status();
         g_bars_since_fit=RefitEvery;
        }
      else
         g_bars_since_fit--;

      VaRBuffer[bar]=(g_status==GPD_OK)?g_var:0.0;
     }

   if(ShowPanel)
      UpdatePanel();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Panel: simple OBJ_LABEL rows in the chart corner.                |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   string rows[]= {"title","var","es","xi","status"};
   int y=20;
   for(int i=0;i<ArraySize(rows);i++)
     {
      string name=g_prefix+rows[i];
      if(ObjectFind(0,name)<0)
         ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,12);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(i==0)?11:10);
      ObjectSetString(0,name,OBJPROP_FONT,(i==0)?"Arial Bold":"Consolas");
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrGainsboro);
      y+=(i==0)?24:18;
     }
   ObjectSetString(0,g_prefix+"title",OBJPROP_TEXT,"EVT Crash Gauge");
  }

//+------------------------------------------------------------------+
//| Map xi to a tail-heaviness color (calm -> elevated -> extreme).  |
//+------------------------------------------------------------------+
color XiColor(double xi)
  {
   if(xi<0.10)
      return clrLimeGreen;     // light tail, calm
   if(xi<0.30)
      return clrGold;          // moderately heavy
   return clrOrangeRed;                 // heavy tail, extreme
  }

//+------------------------------------------------------------------+
//| Refresh the panel text: VaR, ES and xi when the fit is reliable, |
//| otherwise a status line explaining why it is not.                |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(g_status!=GPD_OK)
     {
      ObjectSetString(0,g_prefix+"var",OBJPROP_TEXT,"VaR : --");
      ObjectSetString(0,g_prefix+"es",OBJPROP_TEXT,"ES  : --");
      ObjectSetString(0,g_prefix+"xi",OBJPROP_TEXT,"xi  : --");
      ObjectSetInteger(0,g_prefix+"xi",OBJPROP_COLOR,clrGray);
      ObjectSetString(0,g_prefix+"status",OBJPROP_TEXT,"status: "+g_model.StatusText());
      ObjectSetInteger(0,g_prefix+"status",OBJPROP_COLOR,clrSilver);
      return;
     }

   int    pct=(int)MathRound(Confidence*100.0);
   ObjectSetString(0,g_prefix+"var",OBJPROP_TEXT,
                   StringFormat("VaR%d : %.3f%%",pct,g_var*100.0));
   ObjectSetString(0,g_prefix+"es",OBJPROP_TEXT,
                   StringFormat("ES%d  : %.3f%%",pct,g_es*100.0));
   ObjectSetString(0,g_prefix+"xi",OBJPROP_TEXT,
                   StringFormat("xi    : %+.3f  (tail)",g_xi));
   ObjectSetInteger(0,g_prefix+"xi",OBJPROP_COLOR,XiColor(g_xi));
   ObjectSetString(0,g_prefix+"status",OBJPROP_TEXT,
                   StringFormat("exceed: %d   OK",g_exceed));
   ObjectSetInteger(0,g_prefix+"status",OBJPROP_COLOR,clrMediumSeaGreen);

   ObjectSetInteger(0,g_prefix+"var",OBJPROP_COLOR,clrGainsboro);
   ObjectSetInteger(0,g_prefix+"es",OBJPROP_COLOR,clrGainsboro);
  }
//+------------------------------------------------------------------+
