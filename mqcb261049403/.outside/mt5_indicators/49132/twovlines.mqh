class TWOVLINES
{
private:
  datetime Time1;
  datetime Time2;

public:
  TWOVLINES( void ) : Time1(0), Time2(0)
  {
    ::ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
  }

  ~TWOVLINES( void )
  {
    ::ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
  }

  bool IsChange( void )
  {
    const int Size = ::ObjectsTotal(0, -1, OBJ_VLINE);
    bool Res = (Size > 1);

    if (Res)
    {
      datetime Times[];

      for (uint i = ::ArrayResize(Times, Size); (bool)i--;)
        Times[i] = (datetime)::ObjectGetInteger(0, ::ObjectName(0, i, -1, OBJ_VLINE), OBJPROP_TIME);

      ::ArraySort(Times);

      const datetime NewTime1 = Times[Size - 2];
      const datetime NewTime2 = Times[Size - 1];

      Res = (NewTime1 != NewTime2) && ((NewTime1 != this.Time1) || (NewTime2 != this.Time2));

      if (Res)
      {
        this.Time1 = NewTime1;
        this.Time2 = NewTime2;
      }
    }

    return(Res);
  }

  datetime GetTime1( void ) const
  {
    return(this.Time1);
  }

  datetime GetTime2( void ) const
  {
    return(this.Time2);
  }

  string ToString( void ) const
  {
    return((string)this.Time1 + " - " + (string)this.Time2);
  }
};