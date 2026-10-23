//+------------------------------------------------------------------+
//|                                  All Charts Switch Timeframe.mq4 |
//|                                                   Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   long chartIds[];
   long chartId;
   if(GetChartIds(chartIds))
     {
      for(int i=ArraySize(chartIds)-1;i>=0;i--)
        {
         chartId=chartIds[i];
         ChartSetInteger(chartId,CHART_SCALEFIX,0,false);
         ChartRedraw(chartId);
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
