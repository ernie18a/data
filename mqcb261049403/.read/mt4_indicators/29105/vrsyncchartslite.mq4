//************************************************************************************************/
//*                                 VR Template Lite MT 4.mq4                                    */
//*                            Copyright 2020, Trading-go Project.                               */
//*            Author: Voldemar, Version: 08.05.2020, Site https://trading-go.ru                 */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//| Full version MetaTrader 4  https://www.mql5.com/en/market/product/38527
//| Demo version MetaTrader 4  https://www.mql5.com/en/market/product/38528
//| Lite version MetaTrader 4  https://www.mql5.com/en/code/25502/
//| Full version MetaTrader 5  https://www.mql5.com/en/market/product/38529
//| Demo version MetaTrader 5  https://www.mql5.com/en/market/product/38530
//| Lite version MetaTrader 5  https://www.mql5.com/en/code/25503/
//| Blog Russian https://www.mql5.com/ru/blogs/post/726504
//| Blog English https://www.mql5.com/en/blogs/post/726505
//************************************************************************************************/
//| All products of the Author https://www.mql5.com/en/users/voldemar/seller
//************************************************************************************************/
#property strict
#property copyright     "Copyright 2019, Trading-go Project."
#property link          "https://trading-go.ru"
#property version       "20.052"
#property description   "Indicator for synchronizing graphical objects on different charts"
#property description   "Synchronizes all properties of objects and their location."
#property description   "For maximum efficiency, place the indicator on open charts."
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

string names="";
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
class CCore
  {
public:
   struct CHART
     {
      long              id;
      string            sy;
      ENUM_TIMEFRAMES   tf;
     };
   CHART             window[];
   int               GetAllCharts(CHART  &chart[]);
   bool              SetObjects(string aName);
   bool              SetDeleteObject(string aName,long aWindow);
  };
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
int CCore :: GetAllCharts(CHART  &chart[])
  {
   int i=0;
   long prevChart=ChartFirst();
   ArrayResize(chart,i+1,1000);
   chart[i].id=prevChart;
   chart[i].sy=ChartSymbol(prevChart);
   chart[i].tf=ChartPeriod(prevChart);

   while(i<30)
     {
      i++;
      if((prevChart=ChartNext(prevChart))<0)
        {
         ResetLastError();
         return i;
        }
      ArrayResize(chart,i+1,1000);
      chart[i].id=prevChart;
      chart[i].sy=ChartSymbol(prevChart);
      chart[i].tf=ChartPeriod(prevChart);
     }
   return i;
  }
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
datetime        time_1       = NULL;
datetime        time_2       = NULL;
double          price_1      = NULL;
double          price_2      = NULL;
color           color_1      = NULL;
bool            back         = NULL;
bool            fill         = NULL;
ENUM_LINE_STYLE style        = NULL;
long            width        = NULL;
//+---
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
bool CCore :: SetObjects(string aName)
  {
   long            chart_ID = ChartID();
   ENUM_OBJECT     xType    = (ENUM_OBJECT)ObjectGetInteger(chart_ID,aName,OBJPROP_TYPE);
   string          name     = aName;
   string          sy       = Symbol();
// ========
   if(xType==OBJ_RECTANGLE)
     {

      price_1  =                 ObjectGetDouble (chart_ID,name,OBJPROP_PRICE,0);
      price_2  =                 ObjectGetDouble (chart_ID,name,OBJPROP_PRICE,1);
      time_1   =       (datetime)ObjectGetInteger(chart_ID,name,OBJPROP_TIME,0);
      time_2   =       (datetime)ObjectGetInteger(chart_ID,name,OBJPROP_TIME,1);
      color_1  =          (color)ObjectGetInteger(chart_ID,name,OBJPROP_COLOR);
      back     =                 ObjectGetInteger(chart_ID,name,OBJPROP_BACK);
      style    =(ENUM_LINE_STYLE)ObjectGetInteger(chart_ID,name,OBJPROP_STYLE);
      width    =                 ObjectGetInteger(chart_ID,name,OBJPROP_WIDTH);
      fill     =                 ObjectGetInteger(chart_ID,name,OBJPROP_FILL);

      if(time_1!=NULL && price_1!=NULL && price_2!=NULL && time_2!=NULL)
         for(int i=0;i<ArraySize(core.window);i++)
            if(core.window[i].sy==sy)
              {
               int dt=(int)SymbolInfoInteger(core.window[i].sy,SYMBOL_DIGITS);

               price_1=NormalizeDouble(price_1,dt);
               price_2=NormalizeDouble(price_2,dt);

               if(ObjectFind(core.window[i].id,name)!=0)
                  ObjectCreate(core.window[i].id,name,xType,0,time_1,price_1,time_2,price_2);
               else
                 {
                  ObjectSetDouble (core.window[i].id,name,OBJPROP_PRICE,0 ,price_1);
                  ObjectSetDouble (core.window[i].id,name,OBJPROP_PRICE,1 ,price_2);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_TIME,0  ,time_1);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_TIME,1  ,time_2);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_COLOR   ,color_1);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_BACK    ,back);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_STYLE   ,style);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_WIDTH   ,width);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_FILL    ,fill);
                  ObjectSetInteger(core.window[i].id,name,OBJPROP_SELECTABLE,true);
                 }
               ChartRedraw(core.window[i].id);
              }
      //**************************************************************************************/
     }
   return false;
  }
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
bool CCore :: SetDeleteObject(string aName,long aWindow)
  {
   if(ObjectDelete(aWindow,aName))
     {
      ChartRedraw(aWindow);
      return true;
     }
   return false;
  }
//************************************************************************************************/
//                                                                                               */
//************************************************************************************************/
CCore core;
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   Comment("");
   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
   core.GetAllCharts(core.window);
   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      names=sparam;
      core.SetObjects(sparam);
     }

   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      names=sparam;
      core.SetObjects(names);
     }

   if(id==CHARTEVENT_OBJECT_CHANGE)
     {
      core.SetObjects(sparam);
     }

   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      core.SetObjects(sparam);
     }

   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      core.SetObjects(names);
     }

   if(id==CHARTEVENT_OBJECT_DELETE)
      for(int i=0;i<ArraySize(core.window);i++)
         if(ObjectDelete(core.window[i].id,sparam))
            ChartRedraw(core.window[i].id);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
   return(rates_total);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {

  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
