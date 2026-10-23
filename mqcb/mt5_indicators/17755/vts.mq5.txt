//+------------------------------------------------------------------+
//|                                                          VTS.mq5 |
//|                                           Copyright © 2007, IZZY | 
//|                                                                  | 
//+------------------------------------------------------------------+  
//--- авторство индикатора
#property copyright "Copyright © 2007, IZZY"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//--- использовано всего восемь графических построений
#property indicator_plots   8
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 1 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type1   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 1     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type2   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrMediumSeaGreen
//--- толщина линии индикатора равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 2 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type3   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color3  clrMagenta
//--- толщина линии индикатора равна 2
#property indicator_width3  2
//--- отображение бычей метки индикатора
#property indicator_label3  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 2     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type4   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color4  clrMediumSeaGreen
//--- толщина линии индикатора равна 2
#property indicator_width4  2
//--- отображение медвежьей метки индикатора
#property indicator_label4 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 3 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type5   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color5  clrMagenta
//--- толщина линии индикатора равна 2
#property indicator_width5  2
//--- отображение бычей метки индикатора
#property indicator_label5  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 3     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type6   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color6  clrMediumSeaGreen
//--- толщина линии индикатора равна 2
#property indicator_width6  2
//--- отображение медвежьей метки индикатора
#property indicator_label6 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 4 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде символа
#property indicator_type7   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color7  clrRed
//--- толщина линии индикатора равна 2
#property indicator_width7  2
//--- отображение бычей метки индикатора
#property indicator_label7  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 4     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде символа
#property indicator_type8   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color8  clrBlue
//--- толщина линии индикатора равна 2
#property indicator_width8  2
//--- отображение медвежьей метки индикатора
#property indicator_label8 "VTS Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint   ATR_Period=10;
input double kATR=2.0;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpIndBuffer1[],DnIndBuffer1[];
double UpIndBuffer2[],DnIndBuffer2[];
double UpIndBuffer3[],DnIndBuffer3[];
double UpIndBuffer4[],DnIndBuffer4[];
//---
int ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=int(ATR_Period)+30;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer1,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer2,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,UpIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnIndBuffer3,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer3,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,UpIndBuffer3,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer3,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,DnIndBuffer4,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   //PlotIndexSetInteger(6,PLOT_ARROW,234);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer4,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,UpIndBuffer4,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   //PlotIndexSetInteger(7,PLOT_ARROW,233);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer4,true);

//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="VTS";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double ATR[];
   double VTS,VTS1,VTS2,VTS3,VTS4,VTS5,VTS6,VTS7,VTS8,VTS9;
   double VTS10,VTS11,VTS12,VTS13,VTS14,VTS15,VTS16,VTS17,VTS18,VTS19;
   double VTS20,VTS21,VTS22,VTS23;

   static double VTS_prev,VTS1_prev,VTS2_prev,VTS3_prev,VTS4_prev,VTS5_prev,VTS6_prev,VTS7_prev,VTS8_prev,VTS9_prev;
   static double VTS10_prev,VTS11_prev,VTS12_prev,VTS13_prev,VTS14_prev,VTS15_prev,VTS16_prev,VTS17_prev,VTS18_prev,VTS19_prev;
   static double VTS20_prev,VTS21_prev,VTS22_prev,VTS23_prev;

//--- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      double res=close[limit+1];
      VTS_prev=res;
      VTS1_prev=res;
      VTS2_prev=res;
      VTS3_prev=res;
      VTS4_prev=res;
      VTS5_prev=res;
      VTS6_prev=res;
      VTS7_prev=res;
      VTS8_prev=res;
      VTS9_prev=res;
      VTS10_prev=res;
      VTS11_prev=res;
      VTS12_prev=res;
      VTS13_prev=res;
      VTS14_prev=res;
      VTS15_prev=res;
      VTS16_prev=res;
      VTS17_prev=res;
      VTS18_prev=res;
      VTS19_prev=res;
      VTS20_prev=res;
      VTS21_prev=res;
      VTS22_prev=res;
      VTS23_prev=res;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1; 
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---
      VTS=close[bar]-kATR*ATR[bar];
      VTS1=close[bar]+kATR*ATR[bar];
      //---  
      VTS2= MathMax(VTS,VTS_prev);
      VTS3= MathMin(VTS1,VTS1_prev);
      VTS4= MathMax(VTS2,VTS2_prev);
      VTS5= MathMin(VTS3,VTS3_prev);
      VTS6= MathMax(VTS4,VTS4_prev);
      VTS7= MathMin(VTS5,VTS5_prev);
      VTS8= MathMax(VTS6,VTS6_prev);
      VTS9= MathMin(VTS7,VTS7_prev);
      VTS10= MathMax(VTS8,VTS8_prev);
      VTS11= MathMin(VTS9,VTS9_prev);
      VTS12= MathMax(VTS10,VTS10_prev);
      VTS13= MathMin(VTS11,VTS11_prev);
      VTS14= MathMax(VTS12,VTS12_prev);
      VTS15= MathMin(VTS13,VTS13_prev);
      VTS16= MathMax(VTS14,VTS14_prev);
      VTS17= MathMin(VTS15,VTS15_prev);
      VTS18= MathMax(VTS16,VTS16_prev);
      VTS19= MathMin(VTS17,VTS17_prev);
      VTS20= MathMax(VTS18,VTS18_prev);
      VTS21= MathMin(VTS19,VTS19_prev);
      VTS22= MathMax(VTS20,VTS20_prev);
      VTS23= MathMin(VTS21,VTS21_prev);
      UpIndBuffer1[bar]= MathMax(VTS22,VTS22_prev);
      DnIndBuffer1[bar]= MathMin(VTS23,VTS23_prev);
      UpIndBuffer2[bar]= MathMax(UpIndBuffer1[bar],UpIndBuffer1[bar+1]);
      DnIndBuffer2[bar]= MathMin(DnIndBuffer1[bar],DnIndBuffer1[bar+1]);
      UpIndBuffer3[bar]= MathMax(UpIndBuffer2[bar],UpIndBuffer2[bar+1]);
      DnIndBuffer3[bar]= MathMin(DnIndBuffer2[bar],DnIndBuffer2[bar+1]);
      UpIndBuffer4[bar]=UpIndBuffer4[bar+1];
      DnIndBuffer4[bar]=DnIndBuffer4[bar+1];
      if(close[bar]>DnIndBuffer3[bar])
        {
         UpIndBuffer4[bar]=UpIndBuffer3[bar];
         DnIndBuffer4[bar]=NULL;
        }
      if(close[bar]<UpIndBuffer3[bar])
        {
         DnIndBuffer4[bar]=DnIndBuffer3[bar];
         UpIndBuffer4[bar]=NULL;
        }

      if(bar)
        {
         VTS_prev=VTS;
         VTS1_prev=VTS1;
         VTS2_prev=VTS2;
         VTS3_prev=VTS3;
         VTS4_prev=VTS4;
         VTS5_prev=VTS5;
         VTS6_prev=VTS6;
         VTS7_prev=VTS7;
         VTS8_prev=VTS8;
         VTS9_prev=VTS9;
         VTS10_prev=VTS10;
         VTS11_prev=VTS11;
         VTS12_prev=VTS12;
         VTS13_prev=VTS13;
         VTS14_prev=VTS14;
         VTS15_prev=VTS15;
         VTS16_prev=VTS16;
         VTS17_prev=VTS17;
         VTS18_prev=VTS18;
         VTS19_prev=VTS19;
         VTS20_prev=VTS20;
         VTS21_prev=VTS21;
         VTS22_prev=VTS22;
         VTS23_prev=VTS23;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
