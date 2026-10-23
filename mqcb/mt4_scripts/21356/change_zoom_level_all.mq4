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

ENUM_CHART_PROPERTY_INTEGER Chart_Property=CHART_SCALE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Zoom_Level
  {
   None,
   One,
   Two,
   Three,
   Four,
   Max
  };
extern Zoom_Level Chart_Property_Value=None;//Zoom Level
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
         ChartSetInteger(chartId,Chart_Property,0,Chart_Property_Value);
         ChartNavigate(chartId,CHART_END,0);
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
