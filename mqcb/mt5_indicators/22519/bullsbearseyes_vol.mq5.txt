//+------------------------------------------------------------------+
//|                                           BullsBearsEyes_Vol.mq5 | 
//|                   Copyright © 2007, EmeraldKing, transport_david | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, EmeraldKing, transport_david"
#property link "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property description "BullsBearsEyes"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано пять графических построений
#property indicator_plots   5
//+-----------------------------------------+
//|  Параметры отрисовки максимума          |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DeepSkyBlue цвет
#property indicator_color1 clrDeepSkyBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "BullsBearsEyes_Vol Max"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Res         |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color2 clrBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "BullsBearsEyes_Vol Res"
//+-----------------------------------------+
//| Параметры отрисовки индикатора WPR      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type3   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color3  clrLime,clrTeal,clrMediumPurple,clrBrown,clrDeepPink
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки индикатора
#property indicator_label3  "BullsBearsEyes_Vol"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Supr        |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color4 clrBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style4  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "BullsBearsEyes_Vol Supr"
//+-----------------------------------------+
//|  Параметры отрисовки минимума           |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован DeepSkyBlue цвет
#property indicator_color5 clrDeepSkyBlue
//---- линия индикатора - штрих-пунктир
#property indicator_style5  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "BullsBearsEyes_Vol Min"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint   period=13;                             // период усреднения индикатора
input double gamma=0.6;                             // коэффициент сглаживания индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   // объём 
input int    HighLevel2=+25;                        // уровень перекупленности 2
input int    HighLevel1=+10;                        // уровень перекупленности 1
input int    LowLevel1=-10;                         // уровень перепроданности 1
input int    LowLevel2=-25;                         // уровень перепроданности 2
input int    Shift=0;                               // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double UpIndBuffer[],DnIndBuffer[];
double MaxIndBuffer[],MinIndBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int Bears_Handle,Bulls_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| BullsBearsEyes indicator initialization function                 | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(period+1);

//---- получение хендла индикатора iBearsPower
   Bears_Handle=iBearsPower(NULL,0,int(period));
   if(Bears_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iBearsPower");

//---- получение хендла индикатора iBullsPower
   Bulls_Handle=iBullsPower(NULL,0,int(period));
   if(Bulls_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iBullsPower");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,MaxIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MaxIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,MinIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MinIndBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"BullsBearsEyes_Vol(",period,", ",gamma,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| BullsBearsEyes iteration function                                | 
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Bears_Handle)<rates_total
      || BarsCalculated(Bulls_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- Объявление переменных с плавающей точкой  
   double result,Bears[],Bulls[],CU,CD;
   double L0,L1,L2,L3,L0A,L1A,L2A,L3A;
   double vol;
   static double L0_,L1_,L2_,L3_;
//---- Объявление целых переменных и получение уже посчитанных баров
   int limit,bar,to_copy;

//---- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(Bears,true);
   ArraySetAsSeries(Bulls,true);
//---- индексация элементов в массивах как в таймсериях  
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else ArraySetAsSeries(volume,true);

//---- копируем вновь появившиеся данные в массив  
   if(CopyBuffer(Bears_Handle,0,0,to_copy,Bears)<=0) return(RESET);
   if(CopyBuffer(Bulls_Handle,0,0,to_copy,Bulls)<=0) return(RESET);

//---- восстанавливаем значения переменных
   L0=L0_;
   L1=L1_;
   L2=L2_;
   L3=L3_;

//---- пересчёт значений индикаторов
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         L0_=L0;
         L1_=L1;
         L2_=L2;
         L3_=L3;
        }

      L0A=L0;
      L1A=L1;
      L2A=L2;
      L3A=L3;

      L0=(1.0-gamma)*(Bears[bar]+Bulls[bar])+gamma*L0A;
      L1=-gamma*L0+L0A+gamma*L1A;
      L2=-gamma*L1+L1A+gamma*L2A;
      L3=-gamma*L2+L2A+gamma*L3A;
      
      CU=0.0;
      CD=0.0;
      result=0.0;
      if(L0>=L1) CU=L0-L1; else CD=L1-L0;
      if(L1>=L2) CU+=L1-L2; else CD+=L2-L1;
      if(L2>=L3) CU+=L2-L3; else CD+=L3-L2;
      if(CU+CD!=0) result=CU/(CU+CD);
      
      IndBuffer[bar]=result*100-50;
      if(VolumeType==VOLUME_TICK) vol=double(tick_volume[bar]);
      else vol=double(volume[bar]);
      
      IndBuffer[bar]*=vol; //домножаем значение WPR на объём
      MaxIndBuffer[bar]=HighLevel2*vol;
      UpIndBuffer[bar]=HighLevel1*vol;
      DnIndBuffer[bar]=LowLevel1*vol;
      MinIndBuffer[bar]=LowLevel2*vol;

      int clr=2.0;
      if(IndBuffer[bar]>MaxIndBuffer[bar]) clr=0.0;
      else if(IndBuffer[bar]>UpIndBuffer[bar]) clr=1.0;
      else if(IndBuffer[bar]<MinIndBuffer[bar]) clr=4.0;
      else if(IndBuffer[bar]<DnIndBuffer[bar]) clr=3.0;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
