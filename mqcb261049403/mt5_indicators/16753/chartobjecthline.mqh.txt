#include "ChartObject.mqh"

class CHARTOBJECTHLINE : public CHARTOBJECT
{
private:
// Метод-обработчик события таймера
  virtual void EventTimer( void )
  {
    if (this.SetPrice())
      ::EventChartCustom(this.Chart, (ushort)(this.EventCustom), 0, this.Price, "");

    return;
  }

  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    if ((id == ::CHARTEVENT_OBJECT_DRAG) || (id == ::CHARTEVENT_OBJECT_CHANGE))
      this.EventTimer();

    return;
  }

protected:
  double Price;

  bool SetPrice( void )
  {
    const double TmpPrice = this.GetProperty(OBJPROP_PRICE1);
    const bool Res = (TmpPrice != this.Price);

    if (Res)
      this.Price = TmpPrice;

    return(Res);
  }

public:
  CHARTOBJECTHLINE( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_HLINE, sub_window, 0, 0), Price(0)
  {
  }

  virtual void operator =( const double Value )
  {
    this.SetProperty(OBJPROP_PRICE, Value);

    this.Price = this.GetPrice();

    return;
  }
};