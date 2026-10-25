//+------------------------------------------------------------------+ 
//|                                  AdaptiveRVICloud_System_HTF.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "AdaptiveRVICloud с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//--- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                   // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "AdaptiveRVICloud_System"  // Константа для имени индикатора
#define SIZE1 1                                   // Константа для количества вызовов функции CountIndicator1 коде
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrAquamarine,clrPink
//--- отображение метки индикатора
#property indicator_label1  "AdaptiveRVICloud_HTF1"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrTeal
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки индикатора
#property indicator_label2  "AdaptiveRVICloud2 Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type3 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color3 clrMagenta
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки индикатора
#property indicator_label3  "AdaptiveRVICloud2 Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет Teal
#property indicator_color4  clrTeal
//---- толщина линии индикатора 4 равна 5
#property indicator_width4  5
//---- отображение бычьей метки индикатора
#property indicator_label4  "Buy AdaptiveRVICloud2 signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет Magenta
#property indicator_color5  clrMagenta
//---- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//---- отображение медвежьей метки индикатора
#property indicator_label5  "Sell AdaptiveRVICloud2 signal"
//+----------------------------------------------+
//| Входные параметры индикатора 1               |
//+----------------------------------------------+ 
input string in1="<<<  Входные параметры индикатора 1  >>>";
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H4; // Период графика индикатора (таймфрейм)
input double Alpha1=0.07;                   // Коэффициент усреднения индикатора 
input int       Shift1=0;                   // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//| Входные параметры индикатора 2               |
//+----------------------------------------------+ 
input string in2="<<<  Входные параметры индикатора 2  >>>";
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H1; // Период графика индикатора (таймфрейм)
input double Alpha2=0.07;                   // Коэффициент усреднения индикатора 
input int       Shift2=0;                   // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
double TrendUp[],TrendDown[];
double SignUp[],SignDown[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle1,Ind_Handle2;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame1)) return(INIT_FAILED);
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame2)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора AdaptiveRVICloud 1
   Ind_Handle1=iCustom(Symbol(),TimeFrame1,"AdaptiveRVICloud",Alpha1,0);
   if(Ind_Handle1==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AdaptiveRVICloud 1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора AdaptiveRVICloud 2
   Ind_Handle2=iCustom(Symbol(),TimeFrame2,"AdaptiveRVICloud",Alpha2,0);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AdaptiveRVICloud 2");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,UpIndBuffer,INDICATOR_DATA);
   IndInit(1,DnIndBuffer,INDICATOR_DATA);
   IndInit(2,TrendUp,INDICATOR_DATA);
   IndInit(3,TrendDown,INDICATOR_DATA);
   IndInit(4,SignUp,INDICATOR_DATA);
   IndInit(5,SignDown,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,0,Shift1);
   PlotInit(1,EMPTY_VALUE,0,Shift2);
   PlotInit(2,EMPTY_VALUE,0,Shift2);
   PlotInit(3,EMPTY_VALUE,0,Shift2);
   PlotInit(4,EMPTY_VALUE,0,Shift2);
   //--- символы для индикаторов
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,174);
   PlotIndexSetInteger(4,PLOT_ARROW,174);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame1),",",GetStringTimeframe(TimeFrame2),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle1)<Bars(Symbol(),TimeFrame1)) return(prev_calculated);
   if(BarsCalculated(Ind_Handle2)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator1(0,NULL,TimeFrame1,Ind_Handle1,0,UpIndBuffer,1,DnIndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator2(NULL,TimeFrame2,Ind_Handle2,TrendUp,TrendDown,SignUp,SignDown,time,rates_total,prev_calculated,min_rates_total,UpIndBuffer,DnIndBuffer)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- запрет на отображение значений построения в окне DataWindow   
   PlotIndexSetInteger(Number,PLOT_SHOW_DATA,false);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator1(uint     Numb,// Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                     string   Symb,            // Символ графика
                     ENUM_TIMEFRAMES TFrame,   // Период графика
                     int      IndHandle,       // Хендл обрабатываемого индикатора
                     uint     UpBuffNumb,      // Номер верхнего буфера обрабатываемого индикатора для облака
                     double&  UpIndBuf[],      // Приемный верхний буфер индикатора для облака
                     uint     DnBuffNumb,      // Номер нижнего буфера обрабатываемого индикатора для облака
                     double&  DnIndBuf[],      // Приемный нижний буфер индикатора для облака
                     const datetime& iTime[],  // Таймсерия времени
                     const int Rates_Total,    // количество истории в барах на текущем тике
                     const int Prev_Calculated,// количество истории в барах на предыдущем тике
                     const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE1];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double UpArr[1],DnArr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,UpBuffNumb,iTime[bar],1,UpArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,DnBuffNumb,iTime[bar],1,DnArr)<=0) return(RESET);
         //---         
         UpIndBuf[bar]=UpArr[0];
         DnIndBuf[bar]=DnArr[0];
        }
      else
        {
         UpIndBuf[bar]=UpIndBuf[bar+1];
         DnIndBuf[bar]=DnIndBuf[bar+1];
        }
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator2(string   Symb,            // Символ графика
                     ENUM_TIMEFRAMES TFrame,   // Период графика
                     int      IndHandle,       // Хендл обрабатываемого индикатора
                     double&  UpIndBuf[],      // Приемный верхний буфер индикатора тренда
                     double&  DnIndBuf[],      // Приемный нижний буфер индикатора тренда
                     double&  BuyIndBuf[],     // Приемный верхний буфер индикатора тренда
                     double&  SellIndBuf[],    // Приемный нижний буфер индикатора тренда
                     const datetime& iTime[],  // Таймсерия времени
                     const int Rates_Total,    // количество истории в барах на текущем тике
                     const int Prev_Calculated,// количество истории в барах на предыдущем тике
                     const int Min_Rates_Total,// минимальное количество истории в барах для расчета
                     const double&  UpVal[],   // Верхний буфер индикатора значений
                     const double&  DnVal[])   // Нижний буфер индикатора значений
  {
//---
   static int LastCountBar;
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar=limit;
     }
   else limit=LastCountBar+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         double UpArr[2],DnArr[2];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,0,iTime[bar],2,UpArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,1,iTime[bar],2,DnArr)<=0) return(RESET);
         //----
         UpIndBuf[bar]=DnIndBuf[bar]=EMPTY_VALUE;
         BuyIndBuf[bar]=SellIndBuf[bar]=EMPTY_VALUE;
         double val=(UpVal[bar]+DnVal[bar])/2.0;
         if(UpArr[1]>=DnArr[1])
           {
            UpIndBuf[bar]=val;
            if(UpArr[0]<DnArr[0]) BuyIndBuf[bar]=val;
           }
         else
           {
            DnIndBuf[bar]=val;
            if(UpArr[0]>=DnArr[0]) SellIndBuf[bar]=val;
           }
        }
      else
        {
         UpIndBuf[bar]=DnIndBuf[bar]=EMPTY_VALUE;
         BuyIndBuf[bar]=SellIndBuf[bar]=EMPTY_VALUE;
        }
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора (таймфрейм)
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
