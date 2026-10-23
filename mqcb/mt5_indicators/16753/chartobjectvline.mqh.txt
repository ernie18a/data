#include "ChartObject.mqh"

class CHARTOBJECTVLINE : public CHARTOBJECT
{
private:
  datetime time;

  bool SetTime( void )
  {
    const datetime TmpTime = this.GetTime();
    const bool Res = (TmpTime != this.time);

    if (Res)
      this.time = TmpTime;

    return(Res)    ;
  }

// Метод-обработчик события таймера
  virtual void EventTimer( void )
  {
    if (this.SetTime())
      ::EventChartCustom(this.Chart, (ushort)(this.EventCustom), this.time, 0, "");

    return;
  }

  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    if ((id == ::CHARTEVENT_OBJECT_DRAG) || (id == ::CHARTEVENT_OBJECT_CHANGE))
      this.EventTimer();

    return;
  }

public:
  CHARTOBJECTVLINE( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_VLINE, sub_window, 0, 0), time(0)
  {
  }

  virtual void operator =( const datetime Value )
  {
    this.SetProperty(OBJPROP_TIME, (int)Value);

    this.time = this.GetTime();

    return;
  }

};