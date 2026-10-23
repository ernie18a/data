#property strict

#ifdef __MQL5__
  #ifndef FALSE
    #define FALSE false
  #endif

  #ifndef TRUE
    #define TRUE true
  #endif

  #define EMPTY (-1)
#endif

// Базовый класс всех классов для событий
class EVENTBASE
{
private:
  static EVENTBASE* AllEventClasses[];
  static uint TimerInterval;
  static int EventCustoms;

  static int GetAllEventClassesSize( const EVENTBASE &This )
  {
    const int Size = ::ArraySize(EVENTBASE::AllEventClasses);
    int Pos = 0;

    for (int i = 0; i < Size; i++)
    {
      EVENTBASE::AllEventClasses[Pos] = EVENTBASE::AllEventClasses[i];

      if ((::CheckPointer(EVENTBASE::AllEventClasses[i]) != ::POINTER_INVALID) &&
          (EVENTBASE::AllEventClasses[i] != ::GetPointer(This)))
        Pos++;
    }

    return(Pos);
  }

  static void CalcTimerInterval( void )
  {
    static uint PrevTime = 0;

    const uint CurrTime = ::GetTickCount();

    EVENTBASE::TimerInterval = CurrTime - PrevTime;

    PrevTime = CurrTime;

    return;
  }

// Метод-обработчик события (входные параметры можно сделать под свою событийную модель)
// Например, сработал TakeProfit - событие. Или спред стал отрицательным - событие. И т.д.
// В примере входные параметры взяты для штатной событийной модели OnChartEvent
  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    return;
  }

// Метод-обработчик события прихода нового тика
  virtual void EventTick( void )
  {
    return;
  }

// Метод-обработчик события таймера
  virtual void EventTimer( void )
  {
    return;
  }

protected:
  int EventCustom;

public:
  EVENTBASE( const bool Add = TRUE ) : EventCustom(-1)
  {
    if (Add)
    {
      const int Pos = GetAllEventClassesSize(this);

      ::ArrayResize(EVENTBASE::AllEventClasses, Pos + 1);

      EVENTBASE::AllEventClasses[Pos] = ::GetPointer(this);

      this.EventCustom = EVENTBASE::EventCustoms;
      EVENTBASE::EventCustoms++;
    }
  }

  ~EVENTBASE( void )
  {
    ::ArrayResize(AllEventClasses, GetAllEventClassesSize(this));
  }

// Вызов обработчиков событий всех классов
  static void MyEvent( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    const int Size = ::ArraySize(EVENTBASE::AllEventClasses);

    for (int i = 0; i < Size; i++)
      if (::CheckPointer(EVENTBASE::AllEventClasses[i]) != ::POINTER_INVALID)
        EVENTBASE::AllEventClasses[i].Event(id, lparam, dparam, sparam);

    return;
  }

// Вызов обработчиков событий прихода нового тика всех классов
  static void MyEventTick( void )
  {
    const int Size = ::ArraySize(EVENTBASE::AllEventClasses);

    for (int i = 0; i < Size; i++)
      if (::CheckPointer(EVENTBASE::AllEventClasses[i]) != ::POINTER_INVALID)
        EVENTBASE::AllEventClasses[i].EventTick();

    return;
  }

// Вызов обработчиков событий таймера всех классов
  static void MyEventTimer( void )
  {
    EVENTBASE::CalcTimerInterval();

    const int Size = ::ArraySize(EVENTBASE::AllEventClasses);

    for (int i = 0; i < Size; i++)
      if (::CheckPointer(EVENTBASE::AllEventClasses[i]) != ::POINTER_INVALID)
        EVENTBASE::AllEventClasses[i].EventTimer();

    return;
  }

  static uint GetTimerInterval( void )
  {
    return(EVENTBASE::TimerInterval);
  }

  int GetEventCustom( void ) const
  {
    return(this.EventCustom + ::CHARTEVENT_CUSTOM);
  }

  static int GetEventCustoms( void )
  {
    return(EVENTBASE::EventCustoms);
  }
};

EVENTBASE* EVENTBASE::AllEventClasses[];
uint EVENTBASE::TimerInterval = ::INT_MAX;
int EVENTBASE::EventCustoms = 0;