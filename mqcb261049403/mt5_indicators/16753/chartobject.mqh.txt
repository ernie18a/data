#property strict

#include <EventBase.mqh>

#ifdef __MQL5__
  #define OBJPROP_PRICE1 OBJPROP_PRICE, 0
  #define OBJPROP_PRICE2 OBJPROP_PRICE, 1
#endif

class CHARTOBJECT : public EVENTBASE
{
protected:
  virtual bool ChartXYToTimePrice( const int x, const int y, int &sub_window, datetime &time, double &price, const bool Add = true ) const
  {
    bool Res = (x < CHARTOBJECT::GetProperty(CHART_WIDTH_IN_PIXELS, sub_window));

    datetime TmpTime;

    ::ChartXYToTimePrice(this.Chart, x, (y > 0) ? y - 1 : y + 1, sub_window, TmpTime, price);
    ::ChartXYToTimePrice(this.Chart, x, y, sub_window, time, price);

    if (Res && (TmpTime == time) && (time > 0)) // Из-за проблем на стыке подокон
    {
      if (Add)
        time += ::PeriodSeconds(::ChartPeriod(this.Chart)) >> 1;
    }
    else
      time = 0;

    return(Res);
  }

  static bool IsMouseLeftDown( const string &sparam )
  {
    return(((uint)sparam) & 1);
  }

  static bool IsMouseShiftDown( const string &sparam )
  {
    return(((uint)sparam) & 4);
  }

  static string TimeToString( const ulong uTime, const int mode = TIME_DATE | TIME_SECONDS )
  {
   return(::TimeToString(uTime / 1000, mode) + "." + ::IntegerToString(uTime % 1000, 3, '0'));
  }

public:
  const string Name;
  const long Chart;
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
               : EVENTBASE(Add), Name(object_name), Chart((chart_id == 0) ? ::ChartID() : chart_id), Type(object_type)
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
//      if (::ObjectFind(this.Chart, this.Name) != -1) // https://www.mql5.com/ru/forum/1111/page1762#comment_2913243
        ::ObjectDelete(this.Chart, this.Name);

        CHARTOBJECT::Visual(); // https://www.mql5.com/ru/forum/98641/page2#comment_2914902
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

  bool SetProperty( const ENUM_OBJECT_PROPERTY_INTEGER id, const int Value, const int Modifier = 0 ) const
  {
    return(::ObjectSetInteger(this.Chart, this.Name, id, Modifier, Value));
  }

  bool SetProperty( const ENUM_OBJECT_PROPERTY_DOUBLE id, const double Value, const int Modifier = 0 ) const
  {
    return(::ObjectSetDouble(this.Chart, this.Name, id, Modifier, Value));
  }

  bool SetProperty( const ENUM_OBJECT_PROPERTY_STRING id, const string Value, const int Modifier = 0 ) const
  {
    return(::ObjectSetString(this.Chart, this.Name, id, Modifier, Value));
  }

  long GetProperty( const ENUM_OBJECT_PROPERTY_INTEGER Property, const int Modifier = 0 ) const
  {
    return(::ObjectGetInteger(this.Chart, this.Name, Property, Modifier));
  }

  double GetProperty( const ENUM_OBJECT_PROPERTY_DOUBLE Property, const int Modifier = 0 ) const
  {
    return(::ObjectGetDouble(this.Chart, this.Name, Property, Modifier));
  }

  string GetProperty( const ENUM_OBJECT_PROPERTY_STRING Property, const int Modifier = 0 ) const
  {
    return(::ObjectGetString(this.Chart, this.Name, Property, Modifier));
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_INTEGER id, const int Value ) const
  {
    return(::ChartSetInteger(this.Chart, id, Value));
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_DOUBLE id, const double Value ) const
  {
    return(::ChartSetDouble(this.Chart, id, Value));
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_STRING id, const string Value ) const
  {
    return(::ChartSetString(this.Chart, id, Value));
  }

  virtual long GetProperty( const ENUM_CHART_PROPERTY_INTEGER Property, const int SubWindow = 0 ) const
  {
    return(::ChartGetInteger(this.Chart, Property, this.GetSubWindow()));
  }

  virtual double GetProperty( const ENUM_CHART_PROPERTY_DOUBLE Property, const int SubWindow = 0 ) const
  {
    return(::ChartGetDouble(this.Chart, Property, this.GetSubWindow()));
  }

  virtual string GetProperty( const ENUM_CHART_PROPERTY_STRING Property ) const
  {
    return(::ChartGetString(this.Chart, Property));
  }

  int GetSubWindow( void ) const
  {
    return(::ObjectFind(this.Chart, this.Name));
  }

  virtual void Comment( const string Str = "" ) const
  {
    CHARTOBJECT::SetProperty(CHART_COMMENT, Str);

    return;
  }

  bool GetXY( int &X, int &Y, const int Num = 0 ) const
  {
    int TmpX;
    bool Res = FALSE;

    switch (this.Type)
    {
      case OBJ_HLINE:
        Res = ::ChartTimePriceToXY(this.Chart, this.GetSubWindow(), 0, this.GetPrice(Num), TmpX, Y);

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

  virtual void operator =( const long Value )
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