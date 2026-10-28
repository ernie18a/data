//+------------------------------------------------------------------+
//|                                                NotOnlySpread.mq4 |
//|                     Spread, its average, its maximum and minimum,|
//|                   and ticks per second (market speed) on comment.|
//+------------------------------------------------------------------+
#property copyright "Fabrizio"
#property link      "fajuzi@yahoo.it"
#property version   "1.01"
#property indicator_chart_window
input int     digi=1;//digits format
input int     sec=30;//seconds to refresh
input bool    clear=false;//if true clears comment after closing indicator
double newspread,averagespread,maxpread,minspread,cumulative;
int tickscount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   EventSetTimer(sec);
   averagespread=MarketInfo(Symbol(),MODE_SPREAD);
   maxpread=averagespread; minspread=averagespread;
   tickscount=0; cumulative=0.0;
   Comment("INSTANT SPREAD = ",DoubleToString(averagespread,digi),
           "; PLEASE WAIT ",IntegerToString(sec)," SECONDS...");
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(clear==true) Comment("");
  }
//+------------------------------------------------------------------+
//| On timer function                                                |
//+------------------------------------------------------------------+ 
void OnTimer()
  {
   Comment("INSTANT SPREAD = ",DoubleToString(newspread,digi),
           ";  AVERAGE = ",DoubleToString(averagespread,digi),
           ";  MAX = ",DoubleToString(maxpread,digi),
           ";  MIN = ",DoubleToString(minspread,digi),
           ";  TICKS/MINUTE SPEED = ",IntegerToString(60*tickscount/sec),
           "; ",IntegerToString(sec)," SECONDS TO REFRESH...");
   newspread=averagespread; maxpread=averagespread; minspread=averagespread;
   tickscount=0; cumulative=0.0;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   tickscount++;
   newspread=MarketInfo(Symbol(),MODE_SPREAD);
   cumulative+=newspread;
   maxpread=MathMax(maxpread,newspread);
   minspread=MathMin(minspread,newspread);
   averagespread=cumulative/tickscount;
   return(rates_total);
  }
//+------------------------------------------------------------------+
