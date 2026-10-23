#property strict

#include "ChartObject_Chart.mqh"
#include "ChartObjectRectangle.mqh"
#include "ChartObjectHLine.mqh"
#include "ChartObjectVLine.mqh"
#include "ChartObjectText.mqh"
#include "ChartObject_ZoomTicks.mqh"

class CHARTOBJECT_ZOOMPRICE : public CHARTOBJECT_CHART
{
private:
  const bool ChartEventMouseMove;

  const uint VelocityScale;
  const bool SubWindowFlag;

  int LastX;
  int LastY;

  double Scale;

  void SetProperties( void ) const
  {
    if (this.SubWindowFlag)
    {
      this.SetProperty(OBJPROP_XSIZE, (int)CHARTOBJECT::GetProperty(CHART_WIDTH_IN_PIXELS));  // Ширина объекта по оси X в пикселях
      this.SetProperty(OBJPROP_YSIZE, (int)CHARTOBJECT::GetProperty(CHART_HEIGHT_IN_PIXELS)); // Ширина объекта по оси Y в пикселях
    }
    else
    {
      this.SetProperty(OBJPROP_WIDTH, 5);         // Размер точки привязки, с помощью которой можно перемещать объект

      this.SetProperty(OBJPROP_SELECTABLE, true); // Доступность объекта
      this.SetProperty(OBJPROP_SELECTED, true);   // Выделенность объекта
    }

    this.SetProperty(OBJPROP_DATE_SCALE, false); // Признак отображения шкалы времени для объекта "График"

    this.SetProperty(OBJPROP_BACK, false);       // Объект на заднем плане

    this.SetProperty(CHART_AUTOSCROLL, false);   // Режим автоматического перехода к правому краю графика
    this.SetProperty(CHART_SHIFT, false);        // Режим отступа ценового графика от правого края

    this.SetProperty(CHART_SHOW_OHLC, false);                // Отображение в левом верхнем углу значений OHLC
    this.SetProperty(CHART_SHOW_PERIOD_SEP, false);          // Отображение вертикальных разделителей между соседними периодами
    this.SetProperty(CHART_SHOW_VOLUMES, CHART_VOLUME_HIDE); // Отображение объемов на графике
    this.SetProperty(CHART_SHOW_TRADE_LEVELS, false);        // Отображение на графике торговых уровней (уровни открытых позиций, Stop Loss, Take Profit и отложенных ордеров)

    this.SetProperty(CHART_MODE, CHART_LINE);          // Тип графика (свечи, бары или линия)
    this.SetProperty(CHART_COLOR_CHART_LINE, clrNONE); // Цвет линии графика и японских свечей "Доджи"

    this.SetProperty(CHART_SCALEFIX, true);            // Режим фиксированного масштаба

    this.SetProperty(OBJPROP_CHART_SCALE, 0);          // Масштаб для объекта "График". 0 - нужен для плавности вертикальной линии

    return;
  }

  void SetTextPrices( const ulong TimeCross, const int Y )
  {
    const TICK Tick = this.Ticks.GetTick(TimeCross);

    if (Tick > 0)
    {
      this.HLineBid = Tick.bid;
      this.HLineAsk = Tick.ask;

      datetime time;
      double price;
      int SubWindow;

      this.ChartXYToTimePrice((int)CHARTOBJECT::GetProperty(OBJPROP_XDISTANCE) +
                              (int)this.GetProperty(CHART_WIDTH_IN_PIXELS), Y, SubWindow, time, price, false);

      if (time > 0)
      {
        this.TextPrices.SetProperty(OBJPROP_TIME, (int)time);
        this.TextPrices.SetProperty(OBJPROP_PRICE, (Tick.bid + Tick.ask) / 2);

        const double point = ::SymbolInfoDouble(::ChartSymbol(this.Chart), SYMBOL_POINT);

        this.TextPrices = CHARTOBJECT::TimeToString(Tick.time, TIME_SECONDS) + " (" + ::DoubleToString((Tick.ask - Tick.bid) / point, 0) + ")";
      }
    }

    return;

  }

  void SetTextCross( const int X, const int Y )
  {
    if (this.GetProperty(CHART_WIDTH_IN_PIXELS) == 0)
      return;

    const ulong TimeCross = (ulong)(this.Ticks.GetTime() + this.Ticks.GetInterval() *
                                    ((double)(X - (int)CHARTOBJECT::GetProperty(OBJPROP_XDISTANCE) - OBJ_CHART_BORDER_SIZE) /
                                     this.GetProperty(CHART_WIDTH_IN_PIXELS) - 0.5));

    this.TextCross.SetProperty(OBJPROP_TIME, (int)this.VLineCross.GetProperty(OBJPROP_TIME));
    this.TextCross.SetProperty(OBJPROP_PRICE, this.GetProperty(CHART_PRICE_MIN));

    this.TextCross = CHARTOBJECT::TimeToString(TimeCross);

    this.SetTextPrices(TimeCross, Y);

    return;
  }

  void SetScale( const int X, const int Y )
  {
    if ((this.GetProperty(CHART_HEIGHT_IN_PIXELS) == 0) || (this.GetProperty(CHART_WIDTH_IN_PIXELS) == 0))
      return;

    this.Scale *= 1 + this.VelocityScale * (double)(Y - this.LastY) / this.GetProperty(CHART_HEIGHT_IN_PIXELS);
    datetime Interval = (datetime)(this.Ticks.GetInterval() * (1 + this.VelocityScale * (double)(this.LastX - X) / this.GetProperty(CHART_WIDTH_IN_PIXELS)));

    if (Interval < 2)
      Interval = 2;

    this.ZoomTicks = this.Scale;
    this.ZoomTicks = Interval;

    return;
  }

  void SetMove( const int X )
  {
    if (this.GetProperty(CHART_WIDTH_IN_PIXELS) == 0)
      return;

    this.ZoomTicks = (long)(this.Ticks.GetTime() + (double)this.Ticks.GetInterval() * (this.LastX - X) / this.GetProperty(CHART_WIDTH_IN_PIXELS));

    return;
  }

  void SetRectangleInterval( void ) const
  {
    const long HalfInterval = this.Ticks.GetInterval() >> 1;
    const ulong LastTime = this.Ticks.GetTime();
    const int CorrectX = ::PeriodSeconds(::ChartPeriod(this.Chart)) >> 1;

    this.RectangleInterval.SetProperty(OBJPROP_TIME, (int)((LastTime + HalfInterval) / THOUSAND) - CorrectX);
    this.RectangleInterval.SetProperty(OBJPROP_PRICE, this.GetProperty(CHART_PRICE_MAX));

    this.RectangleInterval.SetProperty(OBJPROP_TIME, (int)((LastTime - HalfInterval) / THOUSAND) - CorrectX, 1);
    this.RectangleInterval.SetProperty(OBJPROP_PRICE, this.GetProperty(CHART_PRICE_MIN), 1);

    return;
  }

  void SetAutoScroll( void )
  {
    if (CHARTOBJECT::GetProperty(CHART_AUTOSCROLL))
    {
      const ulong HalfInterval = this.Ticks.GetInterval() >> 1;

      this.ZoomTicks = (long)(this.Ticks.GetNowTime() - HalfInterval +
                              (CHARTOBJECT::GetProperty(CHART_SHIFT) ? (HalfInterval << 1) * CHARTOBJECT::GetProperty(CHART_SHIFT_SIZE) / 100 : 0));

      this.ZoomTicks.Visual();
      this.SetRectangleInterval();
      this.SetTextCross(this.LastX, this.LastY);
    }
    else if (this.Ticks.GetTo() >= this.Ticks.GetNowTime())
    {
      this.ZoomTicks.Visual();
      this.SetRectangleInterval();
      this.SetTextCross(this.LastX, this.LastY);
    }

    return;
  }

protected:
  const CHARTOBJECT* RectangleInterval;

  CHARTOBJECT* HLineCross;
  CHARTOBJECT* VLineCross;
  const CHARTOBJECT* TextCross;

  CHARTOBJECT* HLineBid;
  CHARTOBJECT* HLineAsk;
  CHARTOBJECT* TextPrices;

  TICKS* Ticks;
  CHARTOBJECT* ZoomTicks;

public:
  CHARTOBJECT_ZOOMPRICE( const long chart_id = 0, const int sub_window = 0,
                         const uint iVelocityScale = 5, const color cColorCross = ::clrSienna,
                         const color cColorBid = ::clrBlue, const color cColorAsk = ::clrRed,
                         const color cColorSpread = ::clrYellow, const uchar Transparency = 0x7F ) :
                         CHARTOBJECT_CHART(chart_id, sub_window, true),
                         Ticks(new TICKS(::ChartSymbol(this.chartID))),
                         RectangleInterval(new CHARTOBJECTRECTANGLE(this.Chart)),
                         HLineCross(new CHARTOBJECTHLINE(this.chartID)),
                         VLineCross(new CHARTOBJECTVLINE(this.chartID)),
                         TextCross(new CHARTOBJECTTEXT(this.chartID)),
                         HLineBid(new CHARTOBJECTHLINE(this.chartID)),
                         HLineAsk(new CHARTOBJECTHLINE(this.chartID)),
                         TextPrices(new CHARTOBJECTTEXT(this.chartID)),
                         ZoomTicks(new CHARTOBJECT_ZOOMTICKS(this.Ticks, this.chartID, cColorBid, cColorAsk, cColorSpread, Transparency)),
                         ChartEventMouseMove(CHARTOBJECT::GetProperty(CHART_EVENT_MOUSE_MOVE)),
                         VelocityScale((iVelocityScale == 0) ? 1 : iVelocityScale),
                         SubWindowFlag(this.GetSubWindow() > 0),
                         LastX(0), LastY(0), Scale(1)
  {
    this.RectangleInterval.SetProperty(OBJPROP_COLOR, cColorCross);
    this.RectangleInterval.SetProperty(OBJPROP_FILL, true);
    this.RectangleInterval.SetProperty(OBJPROP_BACK, true);

    this.TextCross.SetProperty(OBJPROP_ANGLE, 90);
    this.TextCross.SetProperty(OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    this.TextCross.SetProperty(OBJPROP_COLOR, cColorCross);

    this.HLineCross.SetProperty(OBJPROP_COLOR, cColorCross);
    this.VLineCross.SetProperty(OBJPROP_COLOR, cColorCross);

    this.HLineBid.SetProperty(OBJPROP_COLOR, cColorBid);
    this.HLineAsk.SetProperty(OBJPROP_COLOR, cColorAsk);

    this.TextPrices.SetProperty(OBJPROP_ANGLE, 90);
    this.TextPrices.SetProperty(OBJPROP_ANCHOR, ANCHOR_LOWER);
    this.TextPrices.SetProperty(OBJPROP_COLOR, cColorCross);

    this.SetProperties();

    datetime time;
    double price;
    int SubWindow;

    CHARTOBJECT::ChartXYToTimePrice(0, 0, SubWindow, time, price);

    if (time > 0)
    {
      this.ZoomTicks = (long)(time * THOUSAND);

      this.ZoomTicks.Visual();
      this.SetRectangleInterval();
    }

    this.Visual();

    CHARTOBJECT::Visual();

    CHARTOBJECT::SetProperty(CHART_EVENT_MOUSE_MOVE, true);

    ::EventSetMillisecondTimer(50);
  }

  ~CHARTOBJECT_ZOOMPRICE( void )
  {
    ::EventKillTimer();

    CHARTOBJECT::SetProperty(CHART_EVENT_MOUSE_MOVE, this.ChartEventMouseMove);

    POINTER::DeleteObject(this.ZoomTicks);

    POINTER::DeleteObject(this.TextPrices);
    POINTER::DeleteObject(this.HLineAsk);
    POINTER::DeleteObject(this.HLineBid);

    POINTER::DeleteObject(this.TextCross);
    POINTER::DeleteObject(this.VLineCross);
    POINTER::DeleteObject(this.HLineCross);

    POINTER::DeleteObject(this.RectangleInterval);

    POINTER::DeleteObject(this.Ticks);

    CHARTOBJECT::SetProperty(CHART_MOUSE_SCROLL, true);
  }

// Метод-обработчик события прихода нового тика
  virtual void EventTick( void )
  {
    this.SetAutoScroll();

    return;
  }

// Метод-обработчик события таймера
  virtual void EventTimer( void )
  {
    this.SetAutoScroll();

    return;
  }

  virtual void Event( const int id, const long &lparam, const double &dparam, const string &sparam )
  {
    if ((id == ::CHARTEVENT_CHART_CHANGE) || (((id == ::CHARTEVENT_OBJECT_DRAG) || (id == ::CHARTEVENT_OBJECT_CHANGE)) && (this.Name == sparam)))
    {
      if (this.SubWindowFlag)
      {
        this.SetProperty(OBJPROP_XSIZE, (int)CHARTOBJECT::GetProperty(CHART_WIDTH_IN_PIXELS));
        this.SetProperty(OBJPROP_YSIZE, (int)CHARTOBJECT::GetProperty(CHART_HEIGHT_IN_PIXELS));

        this.Visual();

        this.ZoomTicks.Visual();
      }
    }
    else if (id == CHARTEVENT_MOUSE_MOVE)
    {
      const int X = (int)lparam;
      const int Y = (int)dparam;

      datetime time;
      double price;
      int SubWindow;

      CHARTOBJECT::ChartXYToTimePrice(X, Y, SubWindow, time, price);

      const bool Flag = this.IsCursor(X, Y);

      CHARTOBJECT::SetProperty(CHART_MOUSE_SCROLL, !Flag);

      if (Flag)
      {
        if (CHARTOBJECT::IsMouseLeftDown(sparam))
        {
          if (CHARTOBJECT::IsMouseShiftDown(sparam))
            this.SetScale(X, Y);
          else
            this.SetMove(X);

          this.ZoomTicks.Visual();
          this.SetRectangleInterval();
        }

        this.ChartXYToTimePrice(X, Y, SubWindow, time, price, false);

        this.HLineCross = price;
        this.VLineCross = time;

        this.SetTextCross(X, Y);

        this.Visual();
      }
      else if ((CHARTOBJECT::IsMouseShiftDown(sparam)) && (time > 0))
      {
        this.ZoomTicks = (long)(time * THOUSAND);

        this.ZoomTicks.Visual();
        this.SetRectangleInterval();

        this.SetTextCross(X, Y);
      }

      this.LastX = X;
      this.LastY = Y;
    }

    return;
  }
};