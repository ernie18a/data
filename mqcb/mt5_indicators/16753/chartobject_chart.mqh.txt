#property strict

#include "ChartObject.mqh"

#define OBJ_CHART_BORDER_SIZE 3 // Размер рамки чарта в пикселах

class CHARTOBJECT_CHART : public CHARTOBJECT
{
protected:
  virtual bool ChartXYToTimePrice( const int x, const int y, int &sub_window, datetime &time, double &price, const bool Add = true ) const
  {
    const int Y = y - (int)CHARTOBJECT::GetProperty(CHART_WINDOW_YDISTANCE) -
                  (int)CHARTOBJECT::GetProperty(OBJPROP_YDISTANCE) - OBJ_CHART_BORDER_SIZE;     // OBJPROP_YDISTANCE - Left-Upper!

    const int X = x - (int)CHARTOBJECT::GetProperty(OBJPROP_XDISTANCE) - OBJ_CHART_BORDER_SIZE; // OBJPROP_YDISTANCE - Left-Upper!

    const bool Res = ::ChartXYToTimePrice(this.chartID, X, Y, sub_window, time, price);

    if (Add)
      time += ::PeriodSeconds(::ChartPeriod(this.chartID)) >> 1;

    const double PriceMax = this.GetProperty(CHART_PRICE_MAX);

    if (this.GetProperty(CHART_HEIGHT_IN_PIXELS) > 0)
      price = PriceMax - Y * (PriceMax - this.GetProperty(CHART_PRICE_MIN)) / this.GetProperty(CHART_HEIGHT_IN_PIXELS);

    return(Res);
  }

  bool IsCursor( const int X, const int Y ) const
  {
    const int X0 = (int)this.GetProperty(OBJPROP_XDISTANCE);
    const int Y0 = (int)(this.GetProperty(OBJPROP_YDISTANCE) + CHARTOBJECT::GetProperty(CHART_WINDOW_YDISTANCE));

    const int XEnd = X0 + (int)this.GetProperty(CHART_WIDTH_IN_PIXELS);
    const int YEnd = Y0 + (int)this.GetProperty(CHART_HEIGHT_IN_PIXELS);

    return((X >= X0) && (X < XEnd) && (Y >= Y0) && (Y < YEnd));
  }

private:
  static int iBarShift( const string Symb, const ENUM_TIMEFRAMES TimeFrame, const datetime time )
  {
    int Res = -1;
    datetime LastBar;

     if (::SeriesInfoInteger(Symb, TimeFrame, ::SERIES_LASTBAR_DATE, LastBar))
     {
        if (time > LastBar)
          Res = 0;
        else
        {
          const int Shift = ::Bars(Symb, TimeFrame, time, LastBar);

          if (Shift > 0)
            Res = Shift - 1;
        }
      }

    return(Res);
  }

public:
  const long chartID;

  CHARTOBJECT_CHART( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_CHART, sub_window, 0, 0), chartID(this.GetProperty(OBJPROP_CHART_ID))
  {
  }

  virtual void operator =( const long Value )
  {
    ::ChartNavigate(this.chartID, ::CHART_CURRENT_POS, (int)(::ChartGetInteger(this.chartID, ::CHART_FIRST_VISIBLE_BAR) - Value));

    return;
  }

  virtual void operator =( const datetime Value )
  {
    const int Pos = CHARTOBJECT_CHART::iBarShift(::ChartSymbol(this.chartID), ::ChartPeriod(this.chartID), Value);

    if (Pos != -1)
      this = Pos;

    return;
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_INTEGER id, const int Value ) const
  {
    return(::ChartSetInteger(this.chartID, id, Value));
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_DOUBLE id, const double Value ) const
  {
    return(::ChartSetDouble(this.chartID, id, Value));
  }

  virtual bool SetProperty( const ENUM_CHART_PROPERTY_STRING id, const string Value ) const
  {
    return(::ChartSetString(this.chartID, id, Value));
  }

  virtual long GetProperty( const ENUM_CHART_PROPERTY_INTEGER Property, const int SubWindow = 0 ) const
  {
    return(::ChartGetInteger(this.chartID, Property, SubWindow));
  }

  virtual double GetProperty( const ENUM_CHART_PROPERTY_DOUBLE Property, const int SubWindow = 0 ) const
  {
    return(::ChartGetDouble(this.chartID, Property, SubWindow));
  }

  virtual string GetProperty( const ENUM_CHART_PROPERTY_STRING Property ) const
  {
    return(::ChartGetString(this.chartID, Property));
  }

  virtual void Comment( const string Str = "" ) const
  {
    this.SetProperty(CHART_COMMENT, Str);

    return;
  }

  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    if ((id == ::CHARTEVENT_CHART_CHANGE) || (((id == ::CHARTEVENT_OBJECT_DRAG) || (id == ::CHARTEVENT_OBJECT_CHANGE)) && (this.Name == sparam)))
    {
      this = (int)CHARTOBJECT::GetProperty(CHART_FIRST_VISIBLE_BAR);

      this.Visual();
    }

    return;
  }

  virtual void Visual( void ) const
  {
    ::ChartRedraw(this.chartID);

    return;
  }
};