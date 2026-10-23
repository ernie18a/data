//+------------------------------------------------------------------+
//|                                              Refresh28Charts.mq4 |
//|            Copyright © 2019 by Jt, FXFledgling Forex Study Group |
//|                     https://www.facebook.com/groups/FXFledgling/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019 by Jt, FXFledgling Forex Study Group"
#property link      "https://www.facebook.com/groups/FXFledgling/"
#property version   "3.00"
#property strict

extern int BarsToRefresh=50; //Number Of Bars To Extract

int tfCount=9;
int TF[9]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};

//=====================================================================================================
//If your broker uses different symbols for the 28 charts, just replace list of symbols below.
//=====================================================================================================
int    PairCount=28;
string Pairs[28]=
  {
   "EURGBP","GBPAUD","AUDNZD","NZDUSD","USDCAD","CADCHF","CHFJPY",
   "EURAUD","GBPNZD","AUDUSD","NZDCAD","USDCHF","CADJPY",
   "EURNZD","GBPUSD","AUDCAD","NZDCHF","USDJPY",
   "EURUSD","GBPCAD","AUDCHF","NZDJPY",
   "EURCAD","GBPCHF","AUDJPY",
   "EURCHF","GBPJPY",
   "EURJPY"
  };
//=====================================================================================================

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- one-off refresh of 28 Charts on initialization

   for(int x=0;x<PairCount; x++)
     {
      for(int y=0;y<tfCount; y++)
        {
         long IDChart=ChartOpen(Pairs[x],TF[y]);
         ChartSetInteger(IDChart,CHART_AUTOSCROLL,false);

         for(int try=0; try<1000 && iBars(Pairs[x],TF[y])<BarsToRefresh; try++)
           {
            RefreshRates();
            ChartNavigate(IDChart,CHART_BEGIN,-10000);
            Sleep(500);
           }
         if(iBars(Pairs[x],TF[y])<BarsToRefresh) Print("*** "+IntegerToString(x)+"   "+"Pair/Timeframe: "+Pairs[x]+"/"+IntegerToString(TF[y])+" has "+IntegerToString(iBars(Pairs[x],TF[y]))+" only.");
         ChartClose(IDChart);
        }
     }
   Print("*********** Done.");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

  }
//+------------------------------------------------------------------+
