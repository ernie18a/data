//+------------------------------------------------------------------+ 
//|                                                  Rainbow_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор Rainbow с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                      // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Rainbow"                     // константа для имени индикатора
#define SIZE 1                                       // константа для количества вызовов функции CountIndicator
#define INDTOTAL 60                                  // константа для количества отображаемых мувингов
//+----------------------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers INDTOTAL 
//---- использовано всего одно графическое построение
#property indicator_plots   INDTOTAL
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве цветов линий индикатора использованы
#property indicator_color1 clrGold
#property indicator_color2 clrGold
#property indicator_color3 clrGold
#property indicator_color4 clrGold
#property indicator_color5 clrGold
#property indicator_color6 clrGold
#property indicator_color7 clrGold
#property indicator_color8 clrGold
#property indicator_color9 clrGold
#property indicator_color10 clrGold
//----
#property indicator_color11 clrDodgerBlue
#property indicator_color12 clrDodgerBlue
#property indicator_color13 clrDodgerBlue
#property indicator_color14 clrDodgerBlue
#property indicator_color15 clrDodgerBlue
#property indicator_color16 clrDodgerBlue
#property indicator_color17 clrDodgerBlue
#property indicator_color18 clrDodgerBlue
#property indicator_color19 clrDodgerBlue
#property indicator_color20 clrDodgerBlue
#property indicator_color21 clrDodgerBlue
//---- 
#property indicator_color22 clrLimeGreen
#property indicator_color23 clrLimeGreen
#property indicator_color24 clrLimeGreen
#property indicator_color25 clrLimeGreen
#property indicator_color26 clrLimeGreen
#property indicator_color27 clrLimeGreen
#property indicator_color28 clrLimeGreen
#property indicator_color29 clrLimeGreen
#property indicator_color30 clrLimeGreen
#property indicator_color31 clrLimeGreen
#property indicator_color32 clrLimeGreen
#property indicator_color33 clrLimeGreen
//---- 
#property indicator_color34 clrRed
#property indicator_color35 clrRed
#property indicator_color36 clrRed
#property indicator_color37 clrRed
#property indicator_color38 clrRed
#property indicator_color39 clrRed
#property indicator_color40 clrRed
#property indicator_color41 clrRed
#property indicator_color42 clrRed
#property indicator_color43 clrRed
#property indicator_color44 clrRed
#property indicator_color45 clrRed
#property indicator_color46 clrRed
//---- 
#property indicator_color47 clrDarkOrchid
#property indicator_color48 clrDarkOrchid
#property indicator_color49 clrDarkOrchid
#property indicator_color50 clrDarkOrchid
#property indicator_color51 clrDarkOrchid
#property indicator_color52 clrDarkOrchid
#property indicator_color53 clrDarkOrchid
#property indicator_color54 clrDarkOrchid
#property indicator_color55 clrDarkOrchid
#property indicator_color56 clrDarkOrchid
#property indicator_color57 clrDarkOrchid
#property indicator_color58 clrDarkOrchid
#property indicator_color59 clrDarkOrchid
#property indicator_color60 clrDarkOrchid
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
//---
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
input Smooth_Method XMA_Method=MODE_EMA;    // Метод усреднения
input uint StartLength=2; // Первая глубина усреднения
input uint StartStep=2;   // Стартовый шаг изменения усреднения 
input uint EndStep=6;     // Финишный шаг изменения усреднения                                         
input int XPhase=15;      // Параметр усреднения
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                          // для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_QUARTER_; // Ценовая константа
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах
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
//---- получение хендла индикатора Rainbow
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,XMA_Method,StartLength,StartStep,EndStep,XPhase,IPC,0,PriceShift);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Rainbow");
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
//----
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
                     ENUM_TIMEFRAMES TFrame) // период графика индикатора
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
