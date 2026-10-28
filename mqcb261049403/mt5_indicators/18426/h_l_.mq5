//+------------------------------------------------------------------+
//|                                                         H_L_.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован голубой цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "High 2"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии 1          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета верхней линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычей метки индикатора
#property indicator_label2  "High 1"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии 1           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета нижней линии индикатора использован красный цвет
#property indicator_color3  clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 1
#property indicator_width3 1 
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Low 1"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии 2           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета нижней линии индикатора использован розовый цвет
#property indicator_color4  clrMagenta
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 1
#property indicator_width4 1 
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Low 2"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint S=4;
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Buffer_0[],Buffer_1[],Buffer_2[],Buffer_3[];
//---- Объявление переменной значения вертикального сдвига
double MaRo;
//---- Объявление переменной для хранения хендла индикатора
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(S);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Buffer_0,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Buffer_1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Buffer_2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Buffer_3,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer_0,true);
   ArraySetAsSeries(Buffer_1,true);
   ArraySetAsSeries(Buffer_2,true);
   ArraySetAsSeries(Buffer_3,true);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"H_L_(",S,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XMA iteration function                                           | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int limit,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   limit=rates_total-1-int(S); // стартовый номер для расчёта всех баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//----   
   int A1=0;int A1d=0;
   int A2=0;int A2d=0;
   int V1=0;int V1d=0;
   int V2=0;int V2d=0;
   int AX=0;int AXd=0;
   int BX=0;int BXd=0;
   int CX=0;int CXd=0;
   int DX=0;int DXd=0;
//----
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Buffer_0[bar]=high[bar];
      Buffer_1[bar]=low[bar];
      Buffer_2[bar]=(open[bar]+close[bar])/2;
      Buffer_3[bar]=(open[bar]+close[bar])/2;
     }

//---- Основной цикл расчёта индикатора
   for(int cnt2=0; cnt2<int(S); cnt2++)
     {
      AX=0;BX=0;CX=0;DX=0;A1=0;A2=0;V1=0;V2=0;
      AXd=0;BXd=0;CXd=0;DXd=0;A1d=0;A2d=0;V1d=0;V2d=0;
      //----
      for(bar=limit-1; bar>=0 && !IsStopped(); bar--)
        {
         //---------------------------------------------------
         if(bar>0 && Buffer_0[bar]<Buffer_0[bar-1])
           {
            AX=bar-1;
            BX=AX;
           }
         if(bar>0 && Buffer_0[bar]==Buffer_0[bar-1] && AX>0)
           {
            BX=bar-1;
           }
         if(bar>0 && Buffer_0[bar]>Buffer_0[bar-1] && AX>0) //
           {
            if(A1==0)
              {
               A1=(AX+BX)/2;
              }
            if(A1>0)
              {
               A2=(AX+BX)/2;
              }
            if(A1>0 && A2>0)
              {
               for(int cnt4=1; cnt4<=A1-A2; cnt4++)
                 {
                  Buffer_0[A2+cnt4]=Buffer_0[A2]+(((Buffer_0[A1]-Buffer_0[A2])*cnt4)/(A1-A2));
                 }
               A1=A2;
               A2=0;
              }
           }
         //-----------------------------------------------
         if(bar>0 && Buffer_1[bar]>Buffer_1[bar-1])
           {
            CX=bar-1;
            DX=CX;
           }
         if(bar>0 && Buffer_1[bar]==Buffer_1[bar-1] && CX>0)
           {
            DX=bar-1;
           }
         if(bar>0 && Buffer_1[bar]<Buffer_1[bar-1] && CX>0)
           {
            if(V1==0)
              {
               V1=(CX+DX)/2;
              }
            if(V1>0)
              {
               V2=(CX+DX)/2;
              }
            if(V1>0 && V2>0)
              {
               for(int cnt5=1;cnt5<=V1-V2;cnt5++)
                 {
                  Buffer_1[V2+cnt5]=Buffer_1[V2]+(((Buffer_1[V1]-Buffer_1[V2])*cnt5)/(V1-V2));
                 }
               V1=V2;
               V2=0;
              }
           }
         //---------------------------------------------------
         if(bar>0 && Buffer_2[bar]<Buffer_2[bar-1])
           {
            AXd=bar-1;
            BXd=AXd;
           }
         if(bar>0 && Buffer_2[bar]==Buffer_2[bar-1] && AXd>0)
           {
            BXd=bar-1;
           }
         if(bar>0 && Buffer_2[bar]>Buffer_2[bar-1] && AXd>0)
           {
            if(A1d==0)
              {
               A1d=(AXd+BXd)/2;
              }
            if(A1d>0)
              {
               A2d=(AXd+BXd)/2;
              }
            if(A1d>0 && A2d>0)
              {
               for(int cnt41=1; cnt41<=A1d-A2d; cnt41++)
                 {
                  Buffer_2[A2d+cnt41]=Buffer_2[A2d]+(((Buffer_2[A1d]-Buffer_2[A2d])*cnt41)/(A1d-A2d));
                 }
               A1d=A2d;
               A2d=0;
              }
           }
         //-----------------------------------------------
         if(bar>0 && Buffer_3[bar]>Buffer_3[bar-1])
           {
            CXd=bar-1;
            DXd=CXd;
           }
         if(bar>0 && Buffer_3[bar]==Buffer_3[bar-1] && CXd>0)
           {
            DXd=bar-1;
           }
         if(bar>0 && Buffer_3[bar]<Buffer_3[bar-1] && CXd>0)
           {
            if(V1d==0)
              {
               V1d=(CXd+DXd)/2;
              }
            if(V1d>0)
              {
               V2d=(CXd+DXd)/2;
              }
            if(V1d>0 && V2d>0)
              {
               for(int cnt51=1; cnt51<=V1d-V2d; cnt51++)
                 {
                  Buffer_3[V2d+cnt51]=Buffer_3[V2d]+(((Buffer_3[V1d]-Buffer_3[V2d])*cnt51)/(V1d-V2d));
                 }
               V1d=V2d;
               V2d=0;
              }
           }
        }
      //-----------------------------------------------------
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
