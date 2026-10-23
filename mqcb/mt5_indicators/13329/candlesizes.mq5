//+------------------------------------------------------------------+
//|                                                  СandleSizes.mq5 |
//|                                                         Tapochun |
//|                           https://www.mql5.com/ru/users/tapochun |
//+------------------------------------------------------------------+
#property copyright "Tapochun"
#property link      "https://www.mql5.com/ru/users/tapochun"
#property version   "1.00"
#property indicator_separate_window
//---
#property indicator_plots 2
#property indicator_buffers 3
#property indicator_minimum 0
//---
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_label1 "CandleSize"
//---
#property indicator_type2 DRAW_LINE
#property indicator_label2 "csAverage"
//+------------------------------------------------------------------+
//| Глобальные переменные                                            |
//+------------------------------------------------------------------+
double bufSize[];               // Буфер значений
double bufSizeClr[];            // Буфер цвета
double bufAverage[];            // Буфер средних значений
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CONSTRUCTION_TYPE  // Тип построения
  {
   upper_shadows,            // Верхние тени
   lower_shadows,            // Нижние тени
   bodies                    // Тела
  };
//+------------------------------------------------------------------+
//| Входные параметры                                                |
//+------------------------------------------------------------------+
input ENUM_CONSTRUCTION_TYPE inpType = upper_shadows;  // Тип построения индикатора
input color inpClr = clrLime;                          // Цвет построения
input color inpNeutralClr=clrGray;                     // Нейтральный цвет
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ТФ д.б. не больше Н2
   if(_Period>PERIOD_H2) // Если ТФ > Н2
     {
      Print(__FUNCTION__,": ВНИМАНИЕ! Индикатор предназначен для работы на ТФ ниже Н2");
      return(INIT_FAILED); // Выходим с ошибкой
     }
//--- Устанавливаем параметры индикатора
   SetIndicatorParameters(inpType,inpClr,inpNeutralClr);
//---
   return( INIT_SUCCEEDED );
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
//--- Проверка наличия рассчитанных данных
   if( rates_total <= 0 ) return( 0 );
//---
   static int dNum;                       // Номер проверяемого дня
   static int dCount = 0;                 // Количество образованных свечей за текущий день
   static int dSum=0;                     // Сумма соответствующих размеров свечей за текущий день
//---
   if(prev_calculated!=0) // Если не первый запуск
     {
      int n;                          // Номер проверяемой свечи
      if(rates_total>prev_calculated) // Если образовался новый бар
        {
         //--- Сбрасываем значение на нулевом баре
         bufSize[rates_total-1]=0.0;
         bufAverage[rates_total-1]=bufAverage[rates_total-2];
         //---
         n=rates_total-2;                  // Номер сформированной свечи
         //--- Расчет индикатора на сформировавшейся свече
         Calculation_bar(inpType,n,dCount,dSum,time,high,low,open,close);
         //--- Проверяем образование нового дня
         CheckNewDay(time[n+1],dNum,dCount,dSum);
        }
      else                                 // Если текущий бар
        {
         n=rates_total-1;                  // Номер текущей свечи
         //--- Рассчитываем индикатор на текущей свече
         Calculation(inpType,n,dCount+1,dSum,time[n],high[n],low[n],open[n],close[n]);
        }
     }
   else                                    // Если первый запуск
     {
      //--- Инициализируем индикаторные буферы начальными значениями
      ArrayInitialize(bufSize,0.0);
      ArrayInitialize(bufAverage,0.0);
      //--- Определяем номер бара первого полностью доступного дня
      int first = GetFirstBar( time, rates_total, dNum );
      if( first == 0 ) return( 0 );
      //--- Расчет индикатора на истории
      for(int i=first; i<rates_total-1; i++)
        {
         //--- Расчет значений (по барам)
         Calculation_bar(inpType,i,dCount,dSum,time,high,low,open,close);
         //--- Проверяем образование нового дня
         CheckNewDay(time[i+1],dNum,dCount,dSum);
        }
     }
//---
   return( rates_total );
  }
//+------------------------------------------------------------------+
//| Определяем тип свечи                                             |
//+------------------------------------------------------------------+
int GetCandleType(const double open,  // Цена открытия свечи
                  const double close) // Цена закрытия свечи
  {
   if( open > close ) return( 1 );    // Если цена открытия выше цены закрытия - нисходящая
   else               return( 0 );    // Если наоборот - восходящая
  }
//+------------------------------------------------------------------+
//| Устанавливаем параметры индикатора                               |
//+------------------------------------------------------------------+
bool SetIndicatorParameters(const ENUM_CONSTRUCTION_TYPE type, // Тип построения
                            const color clr,                   // Цвет элементов
                            const color neutralClr)            // Нейтральный цвет
  {
//--- Присваиваем индексы индикаторным буферам
   SetIndexBuffer(0,bufSize);
   SetIndexBuffer(1,bufSizeClr,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,bufAverage);
//--- Устанавливаем точность значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- Устанавливаем пустые значения графических серий
   PlotIndexSetDouble( 0, PLOT_EMPTY_VALUE, EMPTY_VALUE );   // Гистограммы
   PlotIndexSetDouble( 1, PLOT_EMPTY_VALUE, EMPTY_VALUE );   // Средней линии
//--- Устанавливаем цвета индикатора
   PlotIndexSetInteger( 0, PLOT_COLOR_INDEXES, 2 );           // Количество цветов гистограммы
   PlotIndexSetInteger( 0, PLOT_LINE_COLOR, 0, neutralClr );  // Цвет нейтрального столбца
   PlotIndexSetInteger( 0, PLOT_LINE_COLOR, 1, clr );         // Цвет превышающего столбца
   PlotIndexSetInteger( 1, PLOT_LINE_COLOR, 0, clr );         // Цвет средней линии
//--- Устанавливаем имя в подокне
   string name="CandleSizes ("+GetConstructionStringType(type)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,name);
//---
   return( true );
  }
//+------------------------------------------------------------------+
//| Получаем строковый тип построения индикатора                     |
//+------------------------------------------------------------------+
string GetConstructionStringType(const ENUM_CONSTRUCTION_TYPE type) // Тип построения
  {
   switch(type)
     {
      case upper_shadows: return( "upper" );
      case lower_shadows: return( "lower" );
      case bodies:         return( "bodies" );
      default:
         Print(__FUNCTION__,": ОШИБКА! Неизвестный тип построения "+EnumToString(type));
         return( "" );
     }
  }
//+------------------------------------------------------------------+
//| Получаем номер первого бара полностью доступного дня             |
//+------------------------------------------------------------------+
int GetFirstBar(const datetime &time[], // Массив времен открытия баров по текущему ТФ
                const int rates_total,  // Количество просчитанных баров
                int &dayNum)            // Номер проверяемого дня (out)
  {
   int prev = GetDayNumber(time[ 0 ] ); // Номер дня на предыдущем баре
   int curr;                            // Номер дня на текущем баре
   for(int i=1; i<rates_total; i++)     // Цикл по просчитанных барам
     {
      curr=GetDayNumber(time[i]);       // Определяем номер дня на текущем баре
      if(curr==prev) continue;          // Если номера совпадаюют - переходим к след. бару
      else                              // Если номера не совпадают
        {
         dayNum = curr;                 // Запоминаем номер первого проверяемого дня
         return(i );                    // Возвращаем номер бара первого полного дня
        }
     }
//---
   Print(__FUNCTION__,": Ожидаем больше данных..");
   return(0);                           // Возвращаем 0
  }
//+------------------------------------------------------------------+
//| Определяем номер дня по времени   бара                           |
//+------------------------------------------------------------------+
int GetDayNumber(const datetime time) // Время бара
  {
   MqlDateTime tStr;                  // Структура времени
   TimeToStruct( time,tStr );         // Время в структуру
   return(tStr.day);                  // Возвращаем номер текущего дня
  }
//+------------------------------------------------------------------+
//| Функция расчета индикатора на текущей свече                      |
//+------------------------------------------------------------------+
void Calculation(const ENUM_CONSTRUCTION_TYPE type, // Тип построения
                 const int num,                     // Номер текущего бара
                 const int dCount,                  // Количество образовавшихся баров за день (с учетом текущего)
                 const int dSum,                    // Сумма соответствующих значений за день (на предыдущем баре)
                 const datetime time,               // Массив времен открытия просчитанных баров
                 const double high,                 // Массив максимумов просчитанных баров
                 const double low,                  // Массив минимумов просчитанных баров
                 const double open,                 // Массив цен открытия
                 const double close)                // Массив цен закрытия
  {
//--- Определяем размер элемента на текущем баре
   int cdlType = GetCandleType( open, close );                           // Тип текущей свечи
   int size = GetElementSize( type, cdlType, open, high, low, close );   // Размер элемента
   if( size == 0 ) return;
//--- Запоминаем параметры в буфер
   bufSize[ num ] = size;      // Размер 
   bufSizeClr[ num ] = 0;      // Цвет
//--- Определяем среднее значение за день
   bufAverage[num]=int(MathRound(( dSum+size)/dCount));
//--- Проверяем превышение размера элемента среднее значение на текущем баре
   if(bufSize[num]>bufAverage[num]) // Если значение превышено
      bufSizeClr[num]=1;            // Меняем цвет столбика гистограммы
  }
//+------------------------------------------------------------------+
//| Расчет значений индикатора на новой свече                        |
//+------------------------------------------------------------------+
void Calculation_bar(const ENUM_CONSTRUCTION_TYPE type, // Тип построения
                     const int num,                     // Номер сформированного
                     int &dCount,                       // Количество сформированных баров за день (out)
                     int &dSum,                         // Сумма соответствующих значений за день (out)
                     const datetime &time[],            // Массив времен открытия просчитанных баров
                     const double &high[],              // Массив максимумов просчитанных баров
                     const double &low[],               // Массив минимумов просчитанных баров
                     const double &open[],              // Массив цен открытия
                     const double &close[])             // Массив цен закрытия
  {
//--- Увеличиваем счетчик сформированных баров
   dCount++;
//--- Определяем размер на предыдущей свече
   int cdlType = GetCandleType( open[ num ],close[ num ] );                                          // Тип предыдущей свечи
   int size = GetElementSize( type, cdlType, open[ num ], high[ num ], low[ num ], close[ num ] );   // Размер элемента
   if( size == -1 ) return;
//--- Добавляем размер к сумме
   dSum+=size;
//--- Обновляем значение столбца гистограммы
   bufSize[num]=size;
//--- Обновляем среднее значение
   bufAverage[num]=int(MathRound(dSum/dCount));
//--- Проверка размера элемента тени
   if(bufSize[num]>bufAverage[num]) // Если элемент больше среднего значения
      bufSizeClr[num]=1;            // Подсветка столбца гистограммы
   else                             // Если значение не больше среднего
   bufSizeClr[num]=0;               // Столбец без подсветки
  }
//+------------------------------------------------------------------+
//| Получаем размер элемента типа type                               |
//+------------------------------------------------------------------+
int GetElementSize(const ENUM_CONSTRUCTION_TYPE type, // Тип построения
                   const int cdlType,                 // Тип свечи
                   const double open,                 // Цена открытия
                   const double high,                 // Цена максимума
                   const double low,                  // Цена минимума
                   const double close)                // Цена закрытия
  {
   switch(type) // В зависимости от типа построения
     {
      case upper_shadows:                                 // Верхние тени
         if( cdlType == 0 ) return( int( NormalizeDouble( high - close, _Digits )/_Point ) );   // Восходящая свеча
         else               return( int( NormalizeDouble( high - open, _Digits  )/_Point ) );   // Нисходящая свеча
         break;
      case lower_shadows:                                 // Нижние тени
         if( cdlType == 0 ) return( int( NormalizeDouble( open  - low, _Digits )/_Point ) );   // Восходящая свеча
         else               return( int( NormalizeDouble( close - low, _Digits )/_Point ) );   // Нисходящая свеча
         break;
      case bodies:                                       // Тела свечей
         if( cdlType == 0 ) return( int( NormalizeDouble( close - open, _Digits )/_Point ) );   // Восходящая свеча
         else               return( int( NormalizeDouble( open - close, _Digits )/_Point ) );   // Нисходящая свеча
         break;
      default:                                          // Неизвестный тип
         Print(__FUNCTION__,": ОШИБКА! Неизвестный тип построения: "+EnumToString(type));
         return(-1);                                    // Выход с ошибкой
     }
  }
//+------------------------------------------------------------------+
//| Функция проверки образования нового дня + сброс статич. парам-в  |
//+------------------------------------------------------------------+
void CheckNewDay(const datetime time, // Время открытия бара
                 int &dNum,           // Номер проверяемого дня (out)
                 int &dCount,         // Количество образованных свечей за текущий день (out)
                 int &dSum)           // Сумма соответствующих размеров свечей за текущий день (out)
  {
   int currDayNum=GetDayNumber(time); // Номер текущего дня
   if(currDayNum!=dNum)               // Если номер не совпадает с сохраненным
     {
      //--- Сбрасываем параметры статических переменных
      dNum= currDayNum;               // Номер дня
      dCount = 0;                     // Количество баров текущего дня
      dSum= 0;                        // Сумма значений на сформировавшихся барах
     }
  }
//+------------------------------------------------------------------+
