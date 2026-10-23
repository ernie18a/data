#property strict

#include <EventBase.mqh>

#ifdef __MQL4__
  #define ENUM_OBJECT_PROPERTY_DOUBLE int
  #define ENUM_OBJECT_PROPERTY_STRING int
  #define ENUM_OBJECT_PROPERTY_INTEGER int

  #define OBJPROP_PRICE1 OBJPROP_PRICE
#endif

#ifdef __MQL5__
  #define OBJPROP_PRICE1 OBJPROP_PRICE, 0
  #define OBJPROP_PRICE2 OBJPROP_PRICE, 1
#endif

class CHARTOBJECT : public EVENTBASE
{
public:
  const string Name;
  const int Chart;
  const int SubWindow;
  const int Type;

  CHARTOBJECT( const bool Add,                      // добавлять событийность или нет
               const long          chart_id,        // идентификатор графика
               const string        object_name,     // имя объекта
               const ENUM_OBJECT   object_type,     // тип объекта
               const int           sub_window,      // индекс окна
               const datetime      time1,           // время первой точки привязки
               const double        price1,          // цена первой точки привязки
               const datetime      time2 = 0,       // время второй точки привязки
               const double        price2 = 0,      // цена второй точки привязки
               const datetime      time3 = 0,       // время третьей точки привязки
               const double        price3 = 0 )     // цена третьей точки привязки
               : EVENTBASE(Add), Name(object_name), Chart((int)chart_id), SubWindow(sub_window), Type(object_type)
  {
    ::ObjectCreate(chart_id, object_name, object_type, sub_window, time1, price1, time2, price2, time3, price3);
  }

  ~CHARTOBJECT( void )
  {
    #ifdef __MQL4__
      if (::ObjectFind(this.Name) != -1)
        ::ObjectDelete(this.Name);
    #endif

    #ifdef __MQL5__
      if (::ObjectFind(this.Chart, this.Name) != -1)
        ::ObjectDelete(this.Chart, this.Name);
    #endif
  }

  double GetPrice( const int Num = 0 ) const
  {
    return(::ObjectGetDouble(this.Chart, this.Name, ::OBJPROP_PRICE, Num));
  }

  datetime GetTime( const int Num = 0 ) const
  {
    return((datetime)::ObjectGetInteger(this.Chart, this.Name, ::OBJPROP_TIME, Num));
  }

  template <typename T>
  void SetProperty( const int id, const T Value, const int Modifier = 0 ) const
  {
    const string sType = typename(T);

    if (sType == "double")
      ::ObjectSetDouble(this.Chart, this.Name, (ENUM_OBJECT_PROPERTY_DOUBLE)id, Modifier, (double)Value);
    else if (sType == "string")
      ::ObjectSetString(this.Chart, this.Name, (ENUM_OBJECT_PROPERTY_STRING)id, Modifier, (string)Value);
    else
      ::ObjectSetInteger(this.Chart, this.Name, (ENUM_OBJECT_PROPERTY_INTEGER)id, Modifier, (long)Value);

    return;
  }

  datetime GetVisibleTime( void ) const
  {
    datetime TmpTime;
    double TmpPrice;
    int TmpSubWindow;

    ::ChartXYToTimePrice(this.Chart, 0, 0, TmpSubWindow, TmpTime, TmpPrice); // находим корректные координаты для ChartTimePriceToXY

    return(TmpTime);
  }

  bool GetXY( int &X, int &Y, const int Num = 0 ) const
  {
    int TmpX;
    bool Res = FALSE;


    switch (this.Type)
    {
      case OBJ_HLINE:
        Res = ::ChartTimePriceToXY(this.Chart, this.SubWindow, this.GetVisibleTime(), this.GetPrice(Num), TmpX, Y);

        break;
    }


    return(Res);
  }

  virtual void operator =( const double Value )
  {
    return;
  }

  virtual void operator =( const datetime Value )
  {
    return;
  }

  virtual void operator =( const int Value )
  {
    return;
  }

  virtual void operator =( const string Value ) const
  {
    this.SetProperty(OBJPROP_TEXT, Value);

    return;
  }

  virtual const CHARTOBJECT* GetMe( void ) const
  {
    return(&this);
  }

  virtual void Visual( void ) const
  {
    ::ChartRedraw(this.Chart);

    return;
  }
};