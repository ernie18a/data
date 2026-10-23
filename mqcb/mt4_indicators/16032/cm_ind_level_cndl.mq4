//+------------------------------------------------------------------+
//|                                            cm_ind_level_cndl.mq4 |
//|                                Copyright 2014, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, cmillion@narod.ru"
#property link      "http://cmillion.ru"
#property description "Level"
#property strict

#property indicator_chart_window

input int Candles=5; //сколько свечей зацепила цена
input int History=50; //на каком промежутке ищем
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!ObjectFind("UP1")) ObjectDelete(0,"UP1");
   if(!ObjectFind("DN1")) ObjectDelete(0,"DN1");
   if(!ObjectFind("UP")) ObjectDelete(0,"UP");
   if(!ObjectFind("DN")) ObjectDelete(0,"DN");
  }
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
   for(int j=0,i=0; i<History; i++)
     {
      double H = High[i];
      double L = MathMax(Open[i],Close[i]);
      bool YES=true;
      for(j=i; j<i+Candles; j++)
        {
         if(High[j]<L || MathMax(Open[j],Close[j])>H) {YES=false;break;}
         if(H>High[j]) H=High[j];
         if(L<MathMax(Open[j],Close[j])) L=MathMax(Open[j],Close[j]);
        }
      if(YES)
        {
         TrendCreate(0,"UP",0,Time[j],H,Time[i],H,clrGreen,STYLE_SOLID,5);
         TrendCreate(0,"UP1",0,Time[j],H,Time[0],H,clrGreen);
        }

      H = MathMin(Open[i],Close[i]);
      L = Low[i];
      YES=true;
      for(j=i; j<i+Candles; j++)
        {
         if(MathMin(Open[j],Close[j])<L || Low[j]>H) {YES=false;break;}
         if(H>MathMin(Open[j],Close[j])) H=MathMin(Open[j],Close[j]);
         if(L<Low[j]) L=Low[j];
        }
      if(YES)
        {
         TrendCreate(0,"DN",0,Time[j],L,Time[i],L,clrRed,STYLE_SOLID,5);
         TrendCreate(0,"DN1",0,Time[j],L,Time[0],L,clrRed);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // ID графика
                 const string          name="TrendLine",  // имя линии
                 const int             sub_window=0,      // номер подокна
                 datetime              time1=0,           // время первой точки
                 double                price1=0,          // цена первой точки
                 datetime              time2=0,           // время второй точки
                 double                price2=0,          // цена второй точки
                 const color           clr=clrRed,        // цвет линии
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии
                 const int             width=1,           // толщина линии
                 const bool            back=false,        // на заднем плане
                 const bool            selection=false,   // выделить для перемещений
                 const bool            ray_left=false,    // продолжение линии влево
                 const bool            ray_right=false,   // продолжение линии вправо
                 const bool            hidden=true,       // скрыт в списке объектов
                 const long            z_order=0)         // приоритет на нажатие мышью
  {
   if(!ObjectFind(name)) ObjectDelete(chart_ID,name);
   ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
