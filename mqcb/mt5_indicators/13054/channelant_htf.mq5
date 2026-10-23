//+------------------------------------------------------------------+ 
//|                                               ChannelAnt_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор ChannelAnt с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                      // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "ChannelAnt"                  // константа для имени индикатора
#define SIZE 1                                       // константа для количества вызовов функции CountIndicator
#define INDTOTAL 11                                  // константа для количества отображаемых мувингов
//+----------------------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers INDTOTAL 
//---- использовано всего одно графическое построение
#property indicator_plots   INDTOTAL
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ChannelAnt"
//+--------------------------------------------+
//| Параметры отрисовки индикатора уровней     |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
#property indicator_type10   DRAW_LINE
#property indicator_type11   DRAW_LINE
//---- выбор цветов уровней
#property indicator_color2  clrIndigo
#property indicator_color3  clrDarkSlateGray
#property indicator_color4  clrPurple
#property indicator_color5  clrRed
#property indicator_color6  clrBlue
#property indicator_color7  clrBlue
#property indicator_color8  clrRed
#property indicator_color9  clrPurple
#property indicator_color10 clrDarkSlateGray
#property indicator_color11 clrIndigo
//---- уровни - штрихпунктирные кривые
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_SOLID
#property indicator_style9 STYLE_DASHDOTDOT
#property indicator_style10 STYLE_SOLID
#property indicator_style11 STYLE_DASHDOTDOT
//---- толщина уровней равна 1
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  2
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  2
#property indicator_width9  1
#property indicator_width10 2
#property indicator_width11 1
//---- отображение меток уровней
#property indicator_label2  "+5 Level"
#property indicator_label3  "+4 Level"
#property indicator_label4  "+3 Level"
#property indicator_label5  "+2 Level"
#property indicator_label6  "+1 Level"
#property indicator_label7  "-1 Level"
#property indicator_label8  "-2 Level"
#property indicator_label9  "-3 Level"
#property indicator_label10 "-4 Level"
#property indicator_label11 "-5 Level"
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора
input Smooth_Method MA_Method1=MODE_SMA;    // Метод первого усреднения
input uint Length1=40; // Глубина  первого сглаживания                    
input int Phase1=15;   // Параметр первого среднения
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; // Метод второго усреднения
input uint Length2=20; // Глубина  второго усреднения 
input int Phase2=100;  // Параметр второго сглаживания
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input double Deviation=1; // Коэффициент расширения
input Applied_price_ IPC=PRICE_CLOSE;// Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах      
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- объявление строковых переменных
string Symbol_,Word;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Класс индикаторных буферов                                       |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
public:
   double            m_LineBuffer[];
  };
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//---- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//---- получение хендла индикатора ChannelAnt
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,Deviation,IPC,0,PriceShift);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ChannelAnt");
      return(INIT_FAILED);
     }
//---- инициализация индикаторного буферов
   for(int count=0; count<INDTOTAL; count++) IndInit(count,Ind[count].m_LineBuffer,EMPTY_VALUE,min_rates_total,Shift);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//----
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//----
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
//---- отрисовка индикаторов в виде линий   
   PlotIndexSetInteger(Number,PLOT_DRAW_TYPE,DRAW_LINE);
//---- отображение меток индикаторов
   PlotIndexSetString(Number,PLOT_LABEL,"Line "+string(Number+1));
//----
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // символ графика
                    ENUM_TIMEFRAMES TFrame,   // период графика
                    int      IndHandle,       // хендл обрабатываемого индикатора
                    const datetime& iTime[],  // таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчета
      for(int count=0; count<INDTOTAL; count++) Ind[count].m_LineBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         //---
         for(int count=0; count<INDTOTAL; count++)
           {
            double Arr[1];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(IndHandle,count,iTime[bar],1,Arr)<=0) return(RESET);
            Ind[count].m_LineBuffer[bar]=Arr[0];
           }
        }
      else for(int count=0; count<INDTOTAL; count++) Ind[count].m_LineBuffer[bar]=Ind[count].m_LineBuffer[bar+1];
     }
//----     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //период графика индикатора
  {
//---- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
