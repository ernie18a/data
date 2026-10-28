//+------------------------------------------------------------------+
//|                                                 Power of NZD.mq4 |
//|                                                    Jan Opočenský |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opočenský"
#property link      ""
#property version   "R050120"
#property strict
#property indicator_separate_window
#property indicator_buffers    1
#property indicator_color1     Red

double Power_of_NZD_Buffer[];
int i;
int pos;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping ------------------
   IndicatorBuffers(1);
   SetIndexBuffer(0,Power_of_NZD_Buffer);
   SetIndexStyle(0,DRAW_LINE,EMPTY,2);
//------------------------------------------------
//********************************************************************

//********************************************************************
   return(INIT_SUCCEEDED);
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
//----------------------------------------

pos=Bars-IndicatorCounted();

//----------------------------------------
   
for (i=0;i<pos;i++)
{
   
   Power_of_NZD_Buffer[i]= 
   
   (-iClose("EURNZD",0,i) // REVERZNÍ PÁR
   -iClose("GBPNZD",0,i) // REVERZNÍ PÁR
   -iClose("AUDNZD",0,i) // REVERZNÍ PÁR   
   +iClose("NZDUSD",0,i) 
   +iClose("NZDCAD",0,i)
   +(iClose("NZDJPY",0,i)/100)
   +iClose("NZDCHF",0,i))/7
   ;
   
   
   
}    
//   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
