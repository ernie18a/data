//+------------------------------------------------------------------+ 
//|                                                   Para_B_HTF.mq5 | 
//|                                   Copyright © 2017, Leonid Basis | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Leonid Basis"
#property link ""
//--- номер версии индикатора
#property version   "1.60"
#property description "десять параболиков  с фиксированными во входных параметрах таймфреймами"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- количество индикаторных буферов десять
#property indicator_buffers 10 
//--- использовано десять графических построений
#property indicator_plots   10
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                          // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Para_B_HTF"      // Константа для имени индикатора
#define SIZE 10                          // Константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки индикаторов              |
//+----------------------------------------------+
//--- отрисовка индикаторов в виде значков
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_type5   DRAW_ARROW
#property indicator_type6   DRAW_ARROW
#property indicator_type7   DRAW_ARROW
#property indicator_type8   DRAW_ARROW
#property indicator_type9   DRAW_ARROW
#property indicator_type10  DRAW_ARROW
//--- в качестве цветов индикаторов использованы
#property indicator_color1  clrMediumOrchid
#property indicator_color2  clrMediumOrchid
#property indicator_color3  clrMediumOrchid
#property indicator_color4  clrMediumOrchid
#property indicator_color5  clrMediumOrchid
#property indicator_color6  clrMediumOrchid
#property indicator_color7  clrMediumOrchid
#property indicator_color8  clrMediumOrchid
#property indicator_color9  clrMediumOrchid
#property indicator_color10 clrMediumOrchid
//--- толщина индикаторов
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_width9  2
#property indicator_width10 2
//--- отображение меток индикаторов
#property indicator_label1  "Sar"
#property indicator_label2  "Sar2"
#property indicator_label3  "Sar3"
#property indicator_label4  "Sar4"
#property indicator_label5  "Sar5"
#property indicator_label6  "Sar6"
#property indicator_label7  "Sar7"
#property indicator_label8  "Sar8"
#property indicator_label9  "Sar9"
#property indicator_label10 "Sar10"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M30;  // Период графика индикатора 1
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H1;   // Период графика индикатора 2
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H2;   // Период графика индикатора 3
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H3;   // Период графика индикатора 4
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H4;   // Период графика индикатора 5
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_H6;   // Период графика индикатора 6
input ENUM_TIMEFRAMES TimeFrame7=PERIOD_H8;   // Период графика индикатора 7
input ENUM_TIMEFRAMES TimeFrame8=PERIOD_H12;  // Период графика индикатора 8
input ENUM_TIMEFRAMES TimeFrame9=PERIOD_D1;   // Период графика индикатора 9
input ENUM_TIMEFRAMES TimeFrame10=PERIOD_W1;  // Период графика индикатора 10
//---
input double Step=0.01;
input double Maximum=0.5;
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
ENUM_TIMEFRAMES TimeFrame[SIZE];
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle[10];
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[SIZE];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных 
   min_rates_total=2;
   TimeFrame[0]=TimeFrame1;
   TimeFrame[1]=TimeFrame2;
   TimeFrame[2]=TimeFrame3;
   TimeFrame[3]=TimeFrame4;
   TimeFrame[4]=TimeFrame5;
   TimeFrame[5]=TimeFrame6;
   TimeFrame[6]=TimeFrame7;
   TimeFrame[7]=TimeFrame8;
   TimeFrame[8]=TimeFrame9;
   TimeFrame[9]=TimeFrame10;
//--- получение хендлов индикаторов iSAR
   for(int numb=0; numb<SIZE; numb++)
     {
      Ind_Handle[numb]=iSAR(Symbol(),TimeFrame[numb],Step,Maximum);
      if(Ind_Handle[numb]==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора iSAR "+string(numb)+"!");
         return(INIT_FAILED);
        }
     }
//--- инициализация индикаторных буферов
   for(int numb=0; numb<SIZE; numb++) IndInit(numb,Ind[numb].IndBuffer,EMPTY_VALUE,min_rates_total,0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   for(int numb=0; numb<SIZE; numb++) if(BarsCalculated(Ind_Handle[numb])<Bars(Symbol(),TimeFrame[numb])) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   for(int numb=0; numb<SIZE; numb++)
      if(!CountIndicator(numb,Symbol(),TimeFrame[numb],Ind_Handle[numb],0,Ind[numb].IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(prev_calculated);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приемный буфер индикатора
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
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
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
