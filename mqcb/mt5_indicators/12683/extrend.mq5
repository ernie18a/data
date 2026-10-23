//+------------------------------------------------------------------+
//|                                                      ExTrend.mq5 |
//|                           Copyright © 2006, Alex Sidd (Executer) | 
//|                                           mailto:work_st@mail.ru | 
//+------------------------------------------------------------------+ 
//--- авторство индикатора
#property copyright "Copyright © 2006, Alex Sidd (Executer)k"
//--- авторство индикатора
#property link      "mailto:work_st@mail.ru"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета основной линии индикатора использован цвет Lime
#property indicator_color1  clrLime
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение метки линии индикатора
#property indicator_label1  "Up Line"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета сигнальной линии индикатора использован цвет Magenta
#property indicator_color2  clrMagenta
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение метки линии индикатора
#property indicator_label2  "Down Line"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0     // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input color UpLineColor=clrTeal;     // Цвет тренда верхних фракталов
input color DnLineColor=clrMagenta;  // Цвет тренда нижних фракталов
input int Shift=0;                   // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int FRA_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---
string Up_level_name,Dn_level_name;
double FractUp1,FractUp2,FractDn1,FractDn2;
datetime FTimeUp1,FTimeUp2,FTimeDn1,FTimeDn2,curTime;
//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // идентификатор графика
                 string   name,          // имя объекта
                 int      nwin,          // индекс окна
                 datetime time1,         // время 1 ценового уровня
                 double   price1,        // 1 ценовой уровень
                 datetime time2,         // время 2 ценового уровня
                 double   price2,        // 2 ценовой уровень
                 color    Color,         // цвет линии
                 int      style,         // стиль линии
                 int      width,         // толщина линии
                 string   text)          // текст
  {
//---
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//---
  }
//+------------------------------------------------------------------+
//| Переустановка трендовой линии                                    |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,      // идентификатор графика
              string   name,          // имя объекта
              int      nwin,          // индекс окна
              datetime time1,         // время 1 ценового уровня
              double   price1,        // 1 ценовой уровень
              datetime time2,         // время 2 ценового уровня
              double   price2,        // 2 ценовой уровень
              color    Color,         // цвет линии
              int      style,         // стиль линии
              int      width,         // толщина линии
              string   text)          // текст
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=10;
   FractUp1=0.0;
   FractUp2=0.0;
   FractDn1=0.0;
   FractDn2=0.0;
//--- получение хендла индикатора ATR
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iFractals");
      return(INIT_FAILED);
     }
//--- превращение динамического массива UpBuffer[] в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//--- превращение динамического массива DnBuffer[] в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ExTrend(",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---  
   Up_level_name=shortname+" Up_level";
   Dn_level_name=shortname+" Dn_level";
   if(ObjectFind(0,Up_level_name)==-1) SetTline(0,Up_level_name,0,0,0,0,0,UpLineColor,0,1,Up_level_name);
   if(ObjectFind(0,Dn_level_name)==-1) SetTline(0,Dn_level_name,0,0,0,0,0,DnLineColor,0,1,Dn_level_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//--- удаляем трендовые линии с графика
   ObjectDelete(0,Up_level_name);
   ObjectDelete(0,Dn_level_name);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit;
   double UpFr[],DnFr[];
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      to_copy=rates_total; // расчетное количество всех копируемых данных
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      to_copy=rates_total-prev_calculated+6; // расчетное количество только новых копируемых данных
      limit=rates_total-prev_calculated+2; // стартовый номер для расчета новых баров
     }
//--- копируем вновь появившиеся данные в массивы UpFr[] и DnFr[]
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFr)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFr)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(UpFr,true);
   ArraySetAsSeries(DnFr,true);
   ArraySetAsSeries(time,true);
//--- обнуление неиспользуемых ячеек буферов
   for(int bar=2; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
     }
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double negative=0;
      double positive=0;
      double Fup=UpFr[bar+3];
      double Fdn=DnFr[bar+3];
      //---
      if(Fup && Fup!=EMPTY_VALUE)
        {
         if(!FractUp1 && !FractUp2)
           {
            FractUp1 = Fup;
            FTimeUp1 = time[bar+3];
           }
         //---
         if(FractUp1 && !FractUp2 && FTimeUp1!=time[bar+3])
           {
            FractUp2 = Fup;
            FTimeUp2 = time[bar+3];
           }
         //---
         if(FractUp1 && FractUp2 && FTimeUp2!=time[bar+3])
           {
            FractUp1 = FractUp2;
            FTimeUp1 = FTimeUp2;
            FractUp2 = Fup;
            FTimeUp2 = time[bar+3];
           }
        }
      //---
      if(Fdn && Fdn!=EMPTY_VALUE)
        {
         if(!FractDn1 && !FractDn2)
           {
            FractDn1 = Fdn;
            FTimeDn1 = time[bar+3];
           }
         //---
         if(FractDn1 && !FractDn2 && FTimeDn1!=time[bar+3])
           {
            FractDn2 = Fdn;
            FTimeDn2 = time[bar+3];
           }
         //---
         if(FractDn1 && FractDn2 && FTimeDn2!=time[bar+3])
           {
            FractDn1 = FractDn2;
            FTimeDn1 = FTimeDn2;
            FractDn2 = Fdn;
            FTimeDn2 = time[bar+3];
           }
        }
      //---
      if(FractUp1 && FractUp2)
        {
         SetTline(0,Up_level_name,0,FTimeUp1,FractUp1,FTimeUp2,FractUp2,UpLineColor,0,1,Up_level_name);
         double y = double((FTimeUp2 - FTimeUp1) / (240*60.0));
         double x = (FractUp2 - FractUp1)*(240.0);
         if(!y) y=double(1/(240*60.0));
         positive=MathArctan(x/y);
        }
      //---
      if(FractDn1 && FractDn2)
        {
         SetTline(0,Dn_level_name,0,FTimeDn1,FractDn1,FTimeDn2,FractDn2,DnLineColor,0,1,Dn_level_name);
         double a = double((FTimeDn2 - FTimeDn1) / (240*60.0));
         double b = (FractDn2 - FractDn1)*(240.0);
         if(!a) a=double(1/(240*60.0));
         negative=MathArctan(b/a);
        }
      UpBuffer[bar+3]=positive;
      DnBuffer[bar+3]=negative;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
