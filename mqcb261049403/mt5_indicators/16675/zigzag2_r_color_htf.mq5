//+------------------------------------------------------------------+ 
//|                                          Zigzag2_R_Color_HTF.mq5 |
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                                Khabarovsk, farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2014, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link      "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор Zigzag2_R_Color с возможностью изменения таймфрейма во входных параметрах."
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 3 буфера
#property indicator_buffers 3
//---- использовано всего 1 графическое построение
#property indicator_plots   1
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- в качестве цветов линии индикатора использованы
#property indicator_color1 clrMediumVioletRed,clrMediumSeaGreen
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Zigzag2_R_Color_HTF"
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+ 
#define RESET 0                             // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора (таймфрейм)
input uint ExtDepth=12;
input uint ExtDeviation=5;
input uint ExtBackstep=3;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в  дальнейшем использованы в качестве индикаторных буферов
double HighestBuffer[];
double LowestBuffer[];
double ColorBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
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
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*2+1;
//--- получение хендла индикатора Zigzag2_R_Color
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Zigzag2_R_Color",ExtDepth,ExtDeviation,ExtBackstep);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Zigzag2_R_Color");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Zigzag2_R_Color(",GetStringTimeframe(TimeFrame),", ",int(ExtDepth),", ",int(ExtDeviation),", ",int(ExtBackstep),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- завершение инициализации
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- объявления локальных переменных 
   double UpZigZag[1],DnZigZag[1];
   int limit,bar;
   static int LastCountBar,LastHighPos,LastLowPos;
   datetime ZigZagTime[1];

//---- расчеты необходимого количества копируемых данных
//---- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;              // стартовый номер для расчета всех баров
      LastCountBar=0;
      LastHighPos=0;
      LastLowPos=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
   LastHighPos+=limit;
   LastLowPos+=limit;
   limit+=LastCountBar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   LowestBuffer[LastLowPos]=0.0;
   HighestBuffer[LastHighPos]=0.0;
   
for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HighestBuffer[bar]=NULL;
      LowestBuffer[bar]=NULL;
     }

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- копируем вновь появившиеся данные в массивы
      if(CopyTime(NULL,TimeFrame,time[bar],1,ZigZagTime)<=0) return(RESET);

      if(time[bar+1]<ZigZagTime[0] && time[bar]>=ZigZagTime[0])
        {
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,1,time[bar],1,UpZigZag)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,0,time[bar],1,DnZigZag)<=0) return(RESET);

         if(UpZigZag[0])
           {
            int maxbar=FindMax(UpZigZag[0],bar,0,high);
            HighestBuffer[maxbar]=UpZigZag[0];
            LastHighPos=bar;
           }
         if(DnZigZag[0])
           {
            int minbar=FindMin(DnZigZag[0],bar,0,low);
            LowestBuffer[minbar]=DnZigZag[0];
            LastLowPos=bar;
           }
        }
     }
   LastCountBar=MathMax(LastHighPos,LastLowPos);

//---- Второй большой цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=HighestBuffer[bar];
      double Min=LowestBuffer[bar];
      
      if(!Max && !Min) ColorBuffer[bar]=ColorBuffer[bar+1];
      if( Max &&  Min)
        {
         if(ColorBuffer[bar+1]==0) ColorBuffer[bar]=1;
         else                      ColorBuffer[bar]=0;
        }

      if( Max && !Min) ColorBuffer[bar]=1;
      if(!Max &&  Min) ColorBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| Поиск первого экстремума по его значению в таймсерии             | 
//+------------------------------------------------------------------+  
int FindMax(double Value,int start,int end,const double &Array[])
  {
//----
   for(int bar=start; bar>=end; bar--) if(Array[bar]>=Value) return(bar);
//----
   return(ArrayMaximum(Array,end,start-end));
  }
//+------------------------------------------------------------------+    
//| Поиск первого экстремума по его значению в таймсерии             | 
//+------------------------------------------------------------------+  
int FindMin(double Value,int start,int end,const double &Array[])
  {
//----
   for(int bar=start; bar>=end; bar--) if(Array[bar]<=Value) return(bar);
//----
   return(ArrayMinimum(Array,end,start-end));
  }
//+------------------------------------------------------------------+
