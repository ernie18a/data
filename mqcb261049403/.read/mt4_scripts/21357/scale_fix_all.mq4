//+------------------------------------------------------------------+
//|                                  All Charts Switch Timeframe.mq4 |
//|                                                   Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property strict
#property show_inputs

extern double Percent_Of_Current_Price=1.5;//Percent of current price
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   long chartIds[];
   long chartId;
   double pct = (Percent_Of_Current_Price * 0.01)/2;
   double price = 0;
   double size = 0;
   double max = 0;
   double min = 0;
   if(GetChartIds(chartIds))
     {
      for(int i=ArraySize(chartIds)-1;i>=0;i--)
        {
         chartId=chartIds[i];
         price = MarketInfo(ChartSymbol(chartId),MODE_ASK);
         size = price * pct;
         max = price + size;
         min = price - size;
         ChartSetInteger(chartId,CHART_SCALEFIX,0,true);
         ChartSetDouble(chartId,CHART_FIXED_MAX,max);
         ChartSetDouble(chartId,CHART_FIXED_MIN,min);
         ChartRedraw(chartId);
         price = 0;
         size = 0;
         max = 0;
         min = 0;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetChartIds(long &chartIds[])
  {
   int i=0;
   long chartId=ChartFirst();
   while(chartId>=0)
     {
      if(ArrayResize(chartIds,i+1)<0) return(false);
      chartIds[i]=chartId;
      chartId=ChartNext(chartId);
      i++;
     }
   if(ArraySize(chartIds)>0)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
