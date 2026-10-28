//+------------------------------------------------------------------+
//|                                                   ipulsar_v3.mq4 |
//|                              Copyright 2012, 2015 Тарабанов А.В. |
//|                                                    alextar@bk.ru |
//+------------------------------------------------------------------+
/* iPulsar  Отображает количество периодов размером Scale(по умолчанию - дней), 
            на протяжении которых не были пробиты текущие значения High и Low. 
            Условно, характеризует "силу" тестируемых уровней. 
            Используемые фильтры: 
            1. Фильтр уровня горизонта ретроспективы, LevelFilter . При горизонте, 
            меньшем заданного числа периодов Scale, значение индикатора не отображается.
            2. Фильтр значимости сигнала (значения индикатора),SignalFilter . 
            Отображаются только те значения индикатора, которые "заглядывают" 
            в прошлое не менее, чем на заданное число баров глубже, чем предыдущее 
            отображенное значение. */
#property   copyright "Copyright 2012, 2015 Тарабанов А.В."
#property   link      "alextar@bk.ru"
#property   strict
#property   indicator_separate_window  // Атрибуты индикатора
#property   indicator_buffers 2
#property   indicator_color1 Magenta   // Атрибуты буферов
#property   indicator_width1 2
#property   indicator_color2 Teal
#property   indicator_width2 2
#define     Version  "iPulsar_v3"      // Константы
#define     Zero     0.00000001
bool        IsHighReported,            // Флаги срабатывания алертов
            IsLowReported;
int         Hval,Lval,                 // Предыдущие значения
            Signals;                   // Количество сформированных сигналов
datetime    HT,LT,                     // Время предыдущих значений
            BarTime;                   // Время начала текущего бара
double      HP[],LP[],                 // Буферы
            Periods;                   // Число баров в единице шкалы
//--- Внешние переменные: 
extern bool    SetSignalFilter=true;   // Фильтровать сигнал?
extern double  LevelFilter    =5,      // Горизонт ретроспективы, Scales
SignalFilter   =0;                     // Значимость сигнала, Bars/Scales при<0
extern int     Scale          =1440,   // Минимальный интервал сигналов
ScaleDigits=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName(Version);        // Атрибуты индикатора
   IndicatorDigits(ScaleDigits);
   SetIndexLabel(0,"High");            // Атрибуты буферов
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,HP);
   SetIndexLabel(1,"Low");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,LP);
   if(Scale<0) Scale=-Scale;           // Контроль внешних переменных
   if(Scale==0) Scale=Period();
   if(ScaleDigits<0) ScaleDigits=-ScaleDigits;
   if(ScaleDigits>Digits()) ScaleDigits=Digits();
   Periods=Scale/Period();             // Инициализация глобальных переменных
   IsHighReported=false;
   IsLowReported =false;
   HT     =0;
   LT     =0;
   BarTime=0;
   Hval   =0;
   Lval   =0;
   Signals=0;
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double H,L,HB,LB,dSF,
   dLF=LevelFilter*Periods+0.5;
   bool HD,LD;
   int LF=(int)dLF,                    // Горизонт ретроспективы, Bars
   SF,                                 // Значимость сигнала, Bars
   i,k,Hbar,Lbar,History=Bars-1;
   if(SignalFilter>-Zero) dSF=SignalFilter+0.5;
   else dSF=-SignalFilter*Periods+0.5;
   SF=(int)dSF;
   if( HT > 0 ) Hbar=iBarShift(NULL,0,HT);
   if( LT > 0 ) Lbar=iBarShift(NULL,0,LT);
   int j=History-IndicatorCounted();   // Рассматриваемые бары
   while(j>=0)
     {
      H=High[j];
      L=Low[j];
      HD=false;                        // Флаги обнаружения пробоев
      LD=false;
      HB=0;                            // Число баров до пробоя High
      LB=0;                            // Число баров до пробоя Low
      i=j;
      //--- Поиск пробоев
      while(i<History)
        {              
         if(HD && LD) break;           // Пробои найдены
         i++;
         k=i-j-1;                      // Текущая глубина поиска
         if(!HD && High[i]-H>Zero)
           {
            HD=true;                   // Пробой High
            //--- Фильтрация уровня
            if(k-LF>-Zero)
              {        
               if(!SetSignalFilter)
                 {
                  HB=k;
                  Signals++;
                 }
               else HB=Signal(j,k,SF,Hbar,Hval,HT,Lbar,Lval,LT);
              }
           }
         if(!LD && L-Low[i]>Zero)
           {
            LD=true;                   // Пробой Low
            //--- Фильтрация уровня
            if(k-LF>-Zero)
              {        
               if(!SetSignalFilter)
                 {
                  LB=k;
                  Signals++;
                 }
               else LB=Signal(j,k,SF,Lbar,Lval,LT,Hbar,Hval,HT);
              }
           }
        }
      //--- Контроль обнаружения пробоев
      if(!SetSignalFilter)
        {          
         if(!HD)
           {
            HB=History-j-2;
            Signals++;
           }
         if(!LD)
           {
            LB=History-j-2;
            Signals++;
           }
        }
      //--- Приведение к заданной шкале и отображение:
      HP[j]= NormalizeDouble(HB/Periods,ScaleDigits);
      LP[j]=-NormalizeDouble(LB/Periods,ScaleDigits);
      if(!j)             // Только в реальном времени
        {                        
         if(IsNewBar())
           {             // Только на первом тике бара
            IsHighReported=false;
            IsLowReported =false;
            Comment(Version,": сформировано ",Signals," сигналов для ",Symbol(),", ",Period());
           }
         //--- Не более, чем по одному алерту для каждого направления за бар:
         if(!IsHighReported && HP[j]>Zero)
           {
            IsHighReported=true;
            Alert(Symbol(),", ",Period(),": пробит максимум за ",DoubleToStr(HP[j],ScaleDigits),"*",Scale);
           }
         if(!IsLowReported && LP[j]<-Zero)
           {
            IsLowReported=true;
            Alert(Symbol(),", ",Period(),": пробит минимум  за ",DoubleToStr(-LP[j],ScaleDigits),"*",Scale);
           }
        }
      j--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Signal(int       Bar1,          // Текущий бар
              int       Val1,          // Текущее значение, Bars
              int       F,             // Значимость сигнала, Bars
              int&      Bar0,          // Предыдущий бар
              int&      Val0,          // Предыдущее значение, Bars
              datetime& T,             // Предыдущее время
              int&      contrBar,      // Предыдущий оппозитный бар
              int&      contrVal,      // Предыдущее оппозитное значение
              datetime &contrT)        // Предыдущее оппозитное время
  {
   double S=0;                         // Значение текущего сигнала
   int I=Val1-Val0-Bar0+Bar1;          // Преобладание текущего сигнала
   if(I>= F)                           // Есть преобладающий сигнал
     {                       
      Signals++;
      S=Val1;                          // Запомнить параметры сигнала
      Bar0    =Bar1;
      Val0    =Val1;
      T       =Time[Bar1];
      if(Bar1<contrBar)
        {
         contrBar=0;                   // Забыть предыдущий оппозитный сигнал
         contrVal=0;
         contrT  =0;
        }
     }
   return(S);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()                        // Регистрация нового бара
  {                       
   bool NewBar=false;                  // Нового бара нет
   if(BarTime!=Time[0])
     {
      BarTime=Time[0];                 // Теперь время такое
      NewBar =true;                    // Поймался новый бар
     }
   return(NewBar);
  }
//+------------------------------------------------------------------+
