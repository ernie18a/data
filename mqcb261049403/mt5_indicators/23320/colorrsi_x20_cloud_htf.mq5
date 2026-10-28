//+------------------------------------------------------------------+ 
//|                                       ColorRSI_X20_Cloud_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "ColorRSI_X20_Cloud с фиксированным во входных параметрах таймфреймом"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define LINES_TOTAL         20               // Константа для количества линий индикатора
#define RESET               0                // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "ColorRSI_X20_Cloud"  // Константа для имени индикатора
#define SIZE                44               // Константа для количества вызовов функции CountIndicator в коде LINES_TOTAL*2+4
//+----------------------------------------------+
//---- использовано всего графических построений
#property indicator_buffers 44 //LINES_TOTAL*2+4
//---- использовано всего графических построений
#property indicator_plots   22 //LINES_TOTAL+2
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'183,183,255'
#property indicator_color1 C'183,183,255'
//---- отображение метки индикатора
#property indicator_label1  "Upper XFisher_org_v1"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,185,255'
#property indicator_color2 C'255,185,255'
//---- отображение метки индикатора
#property indicator_label2  "Lower XFisher_org_v1"
//+----------------------------------------------+
//|  Параметры отрисовки индикаторов             |
//+----------------------------------------------+
//---- отрисовка осцилляторов в виде цветных линий
#property indicator_type3 DRAW_COLOR_LINE
//---- выбор цветов линий
#property indicator_color3 clrSpringGreen,clrGray,clrRed
//---- линии - штрихпунктирные кривые
#property indicator_style3 STYLE_SOLID
//---- толщина линий 2
#property indicator_width3 2
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;        // Период графика индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint StartRSIPeriod=5;                       // стартовый период
input uint  step = 1;                              // шаг периода
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;   // цена
input uint                 HighLevelM=80;          // уровень максимальной перекупленности
input uint                 HighLevel=60;           // уровень перекупленности
input uint                 MidLevel=50;            // уровень середины
input uint                 LowLevel=40;            // уровень перепроданности
input uint                 LowLevelM=20;           // уровень минимальной перепроданности
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
public: double    ColorIndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора ColorRSI_X20_Cloud
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ColorRSI_X20_Cloud",StartRSIPeriod,step,RSIPrice,HighLevelM,HighLevel,MidLevel,LowLevel,LowLevelM);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorRSI_X20_Cloud");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов  
   IndInit(0,UpUpBuffer,INDICATOR_DATA);
   IndInit(1,UpDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(2,DnUpBuffer,INDICATOR_DATA);
   IndInit(3,DnDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(1,NULL,min_rates_total,0);
//----
   uint period=StartRSIPeriod;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;
      string shortname="";
      StringConcatenate(shortname,"iRSI X",LINES_TOTAL,"*",period,")");
      int numb1=numb+2;
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb1,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb1,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb+4,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb+1+4,Ind[numb].ColorIndBuffer,INDICATOR_COLOR_INDEX);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].ColorIndBuffer,true);
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb1,PLOT_DRAW_TYPE,PlotIndexGetInteger(2,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb1,PLOT_LINE_STYLE,PlotIndexGetInteger(2,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb1,PLOT_LINE_WIDTH,PlotIndexGetInteger(2,PLOT_LINE_WIDTH));
      PlotIndexSetInteger(numb1,PLOT_COLOR_INDEXES,3);
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,0,PlotIndexGetInteger(2,PLOT_LINE_COLOR,0));
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,1,PlotIndexGetInteger(2,PLOT_LINE_COLOR,1));
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,2,PlotIndexGetInteger(2,PLOT_LINE_COLOR,2));
      //---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
      PlotIndexSetInteger(numb1,PLOT_SHOW_DATA,false);
     }
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 5   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevelM);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,MidLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,LowLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,LowLevelM);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrDodgerBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrDodgerBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlueViolet);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrMagenta);
//---- в линии горизонтального уровня использованы сплошная линия и короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASHDOTDOT);
//---- завершение инициализации
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
   ChartRedraw(0);
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      int count=4+2*numb;
      if(!CountIndicator(count,NULL,TimeFrame,Ind_Handle,count,Ind[numb].IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(count+1,NULL,TimeFrame,Ind_Handle,count+1,Ind[numb].ColorIndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
     }
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,UpUpBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,UpDnBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,DnUpBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,DnDnBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
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
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Number,PLOT_SHOW_DATA,false);
//---
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора 1
                    double&  IndBuf[],        // Приемный буфер индикатора 1
                    const datetime& Time[],   // Таймсерия времени
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
      if(CopyTime(Symbol(),TFrame,Time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(Time[bar]>=IndTime[0] && Time[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,Time[bar],1,Arr)<=0) return(RESET);
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
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Comment("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика! \n Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
