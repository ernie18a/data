//+------------------------------------------------------------------+
//|                                        GRFLeadingEdger_Pivot.mq5 | 
//|                                  Copyright © 2007, GammaRatForex | 
//|                                   http://www.gammarat.com/Forex/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GammaRatForex"
#property link "http://www.gammarat.com/Forex/"
/*
 * LSQ line fitting to the a number of samples.
 * The trendline is the leading point in the fit;
 * the bands are calculated somewhat differently, check the math below and adapt to 
 * your own needs as appropriate
 * also the point estimate is given by the geometric mean
 * MathPow(HCCC,.025) (see function "get_avg" below) rather than 
 * more standard estimates.
 * It's computationally fairly intensive
 */
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+------------------------------------------------+ 
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  Объявление констант                           |
//+------------------------------------------------+
#define INDICATOR_NAME      "GRFLeadingEdger_Pivot"     // Имя индикатора
#define RESET               0                           // Константа для возврата терминалу команды на пересчет индикатора
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input string Symbols_Sirname="GRFLeadingEdger_Pivot_";  // Название для меток индикатора
input uint Samples=60;
input int  LookAhead=0;
input double StdLevel1=2.0;
input double  StdLevel2=4.0;
input color Up_Color=clrSpringGreen;                    // Цвет верхней полосы индикатора
input color Dn_Color=clrYellow;                         // Цвет нижней полосы индикатора
input uint SignalBar=0;                                 // номер бара для получения значений индикатора
input uint SignalLen=40;                                // Длина полос индикатора
//+------------------------------------------------+ 
double pStdLevel1,pStdLevel2;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление глобальных переменных
string UpName,DnName;
int PerSignalLen;
//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,Symbols_Sirname,-1,-1);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Samples);
   pStdLevel1=StdLevel1*_Point;
   pStdLevel2=StdLevel2*_Point;

//---- инициализация переменных
   UpName=Symbols_Sirname+"Upper Band";
   DnName=Symbols_Sirname+"Lower Band";
   PerSignalLen=int(SignalLen)*PeriodSeconds();

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double c0,c1,alpha,beta,s0,s1,c01,c11;
   static double base_det,a[2][2],b[2][2];
   static double Up1,Up2,Dn1,Dn2;
//---- Объявление целых переменных
   int first,bar,kkk;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_total; // стартовый номер для расчёта всех баров
      ArrayInitialize(a,0);
      for(int iii=0; iii<int(Samples); iii++)
        {
         a[0][0]+=iii*iii;
         a[0][1]+=iii;
         a[1][0]+=iii;
         a[1][1]++;
        }

      base_det=det2(a);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      c0=0;
      c1=0;
      for(kkk=0; kkk<int(Samples); kkk++)
        {
         double res=get_avg(bar-kkk,high,low,close);
         c0+=kkk*res;
         c1+=res;
        }

      ArrayCopy(b,a);
      b[0][0]=c0;
      b[1][0]=c1;
      alpha=det2(b)/base_det;

      ArrayCopy(b,a);
      b[0][1]=c0;
      b[1][1]=c1;
      beta=det2(b)/base_det;
      double Leading=(beta-alpha*LookAhead)*_Point;
      c0 = 0;
      c1 = 0;
      c11=0;
      c01=0;
      for(kkk=0; kkk<int(Samples); kkk++)
        {
         s0=get_avg(bar-kkk,high,low,close);
         s1=kkk*alpha+beta;
         double res=MathPow(s0-s1,2);

         if(s0<s1)
           {
            c0+=res;
            c01++;
           }
         else
           {
            c1+=res;
            c11++;
           }
        }

      if(!c01) c01=1;
      if(!c11) c11=1;

      c01=MathSqrt(1./(0.5/MathPow(Samples,2)+0.5/c01/c01));
      c11=MathSqrt(1./(0.5/MathPow(Samples,2)+0.5/c11/c11));
      c0=MathSqrt(c0/c01);
      c1=MathSqrt(c1/c11);

      if(MathAbs(StdLevel1)>0)
        {
         Up1=Leading+pStdLevel1*c0;
         Dn1=Leading-pStdLevel1*c1;
        }

      if(MathAbs(StdLevel2)>0)
        {
         Up2=Leading+pStdLevel2*c0;
         Dn2=Leading-pStdLevel2*c1;
        }

     }
   int bar0=rates_total-1;
   int bar1=rates_total-int(MathMax(SignalLen-1,0));
   datetime time0=time[bar0]+2*PeriodSeconds();
   datetime time1=time0-PerSignalLen;


//---- Рисуем на графике верхний прямоугольник полосы Боллинджера
   SetRectangle(0,UpName,0,time1,Up1,time0,Up2,Up_Color,STYLE_SOLID,1,UpName);
//---- Рисуем на графике нижний прямоугольник полосы Боллинджера
   SetRectangle(0,DnName,0,time1,Dn1,time0,Dn2,Dn_Color,STYLE_SOLID,1,DnName);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_avg(int index,const double &High[],const double &Low[],const double &Close[])
  {
//----
   return(MathPow((High[index]*Low[index]*Close[index]*Close[index]),1/4.0)/_Point);
  }
//+------------------------------------------------------------------+
//| Point and figure                                                 |
//+------------------------------------------------------------------+       
double det2(double &a[][2])
  {
//----
   return(a[0][0]*a[1][1]-a[1][0]*a[0][1]);
  }
//+------------------------------------------------------------------+
