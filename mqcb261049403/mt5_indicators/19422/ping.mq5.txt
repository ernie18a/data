// Реал-тайм индикатор лага котировок терминала

#define HISTOGRAM_VIEW // Закомментировать, чтобы сменить вид индикатора с гистограмм на свечи

#property indicator_separate_window

const bool Init = IndicatorSetDouble(INDICATOR_MINIMUM, 0) && IndicatorSetInteger(INDICATOR_DIGITS, 3) && IndicatorSetString(INDICATOR_SHORTNAME, "PING");

class BUFFER
{
private:
  static int BuffersTotal;
  const int Index;
  int Pos;

public:
  double Buffer[];

  BUFFER( void ) : Index(BUFFER::BuffersTotal++), Pos(0)
  {
    ::SetIndexBuffer(this.Index, this.Buffer);
  }

  // Ширина гистограммы
  bool SetScale( void ) const
  {
    const int Width = 9 / (1 << (5 - (int)::ChartGetInteger(0, CHART_SCALE)));

    return((Width != ::PlotIndexGetInteger(this.Index, PLOT_LINE_WIDTH)) && ::PlotIndexSetInteger(this.Index, PLOT_LINE_WIDTH, Width));
  }

  void Fill( const double Value = EMPTY_VALUE )
  {
    ::ArrayInitialize(this.Buffer, Value);
  }

  BUFFER* operator[]( const int iPos )
  {
    this.Pos = iPos;

    return(&this);
  }

  void operator =( const double Value )
  {
    this.Buffer[this.Pos] = Value;
  }

  bool operator >( const double Value ) const
  {
    return(this.Buffer[this.Pos] > Value);
  }

  bool operator <( const double Value ) const
  {
    return(this.Buffer[this.Pos] < Value);
  }
};

static int BUFFER::BuffersTotal = 0;

class INDICATOR
{
protected:
  const int Amount;
  BUFFER Buffers[];

  int PrevPos;

  bool IsNewBar( int &Pos )
  {
    if (!PrevPos)
      this.Fill();

    Pos = ::ArraySize(this.Buffers[0].Buffer) - 1;

    const bool Res = (Pos != this.PrevPos);

    this.PrevPos = Pos;

    return(Res);
  }

public:
  INDICATOR( const int iAmount ) : PrevPos(0), Amount(iAmount) {}

  void Fill( const double Value = EMPTY_VALUE )
  {
    for (int i = 0; i < this.Amount; i++)
      this.Buffers[i].Fill(Value);
  }

  void SetScale( void ) const
  {
    bool Res = false;

    for (int i = 0; i < this.Amount; i++)
      Res |= this.Buffers[i].SetScale();

    if (Res)
      ::ChartRedraw();
  }

  virtual void Add( const double Value );
};

class CANDLES : public INDICATOR
{
public:
  CANDLES( void ) : INDICATOR(::ArrayResize(this.Buffers, 4)) {}

#define OPEN  0
#define HIGH  1
#define LOW   2
#define CLOSE 3

  virtual void Add( const double Value )
  {
    int Pos;

    if (IsNewBar(Pos))
    {
      this.Buffers[OPEN][Pos] = Value;
      this.Buffers[HIGH][Pos] = Value;
      this.Buffers[LOW][Pos] = Value;
    }
    else if (this.Buffers[HIGH][Pos] < Value)
      this.Buffers[HIGH][Pos] = Value;
    else if (this.Buffers[LOW][Pos] > Value)
      this.Buffers[LOW][Pos] = Value;

    this.Buffers[CLOSE][Pos] = Value;
  }
};

class AVERAGE : public INDICATOR
{
protected:
  double Sum;
  int Count;

public:
  AVERAGE( void ) : INDICATOR(::ArrayResize(this.Buffers, 1)) {}

  virtual void Add( const double Value )
  {
    int Pos;

    if (this.IsNewBar(Pos))
    {
      this.Sum = 0;
      this.Count = 0;
    }

    this.Sum += Value;
    this.Count++;

    this.Buffers[0][Pos] = this.Sum / this.Count;

    return;
  }
};

class HISTOGRAM : public INDICATOR
{
protected:
  double Sum;
  int Count;

public:
  HISTOGRAM( void ) : INDICATOR(::ArrayResize(this.Buffers, 3)) {}

#define MAX 0
#define AVG 1
#define MIN 2

  virtual void Add( const double Value )
  {
    int Pos;

    if (IsNewBar(Pos))
    {
      this.Buffers[MAX][Pos] = Value;
      this.Buffers[MIN][Pos] = Value;

      this.Sum = 0;
      this.Count = 0;
    }
    else if (this.Buffers[MAX][Pos] < Value)
      this.Buffers[MAX][Pos] = Value;
    else if (this.Buffers[MIN][Pos] > Value)
      this.Buffers[MIN][Pos] = Value;

    this.Sum += Value;
    this.Count++;

    this.Buffers[AVG][Pos] = this.Sum / this.Count;
  }
};

#ifdef HISTOGRAM_VIEW
  #property indicator_buffers 3
  #property indicator_plots   3

  #property indicator_label1 "Ping Max"
  #property indicator_type1  DRAW_HISTOGRAM
  #property indicator_color1 Blue

  #property indicator_label2  "Ping Average"
  #property indicator_type2  DRAW_HISTOGRAM
  #property indicator_color2 Lime

  #property indicator_label3 "Ping Min"
  #property indicator_type3  DRAW_HISTOGRAM
  #property indicator_color3 Red

  HISTOGRAM Histogram;

  void OnChartEvent( const int id, const long&, const double&, const string& )
  {
    if (id == CHARTEVENT_CHART_CHANGE)
      Histogram.SetScale();
  }
#else // HISTOGRAM_VIEW
  #property indicator_buffers 5
  #property indicator_plots   2

  #property indicator_label1 "Ping Open;Ping High;Ping Low;Ping Close"
  #property indicator_type1  DRAW_CANDLES
  #property indicator_color1 clrGreen, clrWhite, clrRed

  #property indicator_label2 "Ping Average"
  #property indicator_type2  DRAW_LINE
  #property indicator_color2 clrBlue
  #property indicator_width2 2

  CANDLES Candles;
  AVERAGE Average;
#endif // HISTOGRAM_VIEW

#include <TypeToBytes.mqh> // https://www.mql5.com/ru/code/16280

// Получение свежего тика с величиной внутреннего лага котировки (в миллисекундах)
bool SymbolInfoTick( const string &Symb, MqlTick &Tick, double &Ping )
{
  static const bool IsTester = (MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION));

  static MqlTick PrevTick = {0};
  static ulong PrevTime = 0;

  const ulong NowTime = IsTester ? 0 : GetMicrosecondCount();
  const bool Res = SymbolInfoTick(Symb, Tick);

  if ((!IsTester) && Res)
  {
    if (_R(Tick) != PrevTick)
    {
      Ping = PrevTime ? MathAbs(Tick.time_msc - PrevTick.time_msc - (NowTime - PrevTime) / 1e3) : 0;

      PrevTime = NowTime;
      PrevTick = Tick;
    }
    else
      Ping = 0;
  }

  return(Res);
}

string GetTickFlag( uint tickflag )
{
  string flag = "";

#define TICKFLAG_MACRO(A) flag += ((bool)(tickflag & TICK_FLAG_##A)) ? " TICK_FLAG_" + #A : "";
  TICKFLAG_MACRO(BID)
  TICKFLAG_MACRO(ASK)
  TICKFLAG_MACRO(LAST)
  TICKFLAG_MACRO(VOLUME)
  TICKFLAG_MACRO(BUY)
  TICKFLAG_MACRO(SELL)
#undef TICKFLAG_MACRO

  if (flag == "")
    flag = " FLAG_UNKNOWN (" + (string)tickflag + ")";

  return(flag);
}

#define TOSTRING(A) " " + #A + " = " + (string)Tick.A

string TickToString( const MqlTick &Tick )
{
  return(TOSTRING(time) + "." + (string)IntegerToString(Tick.time_msc %1000, 3, '0') +
         TOSTRING(bid) + TOSTRING(ask) + TOSTRING(last)+ TOSTRING(volume) + GetTickFlag(Tick.flags));
}

#undef TOSTRING

#define TOSTRING(A) "\n" + #A + " = " + (string)(A)

int OnCalculate( const int rates_total, const int prev_calculated, const int, const double &[] )
// void OnTick()
{
  static MqlTick Tick;
  static double Ping;

  static const bool IsIndicator = (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_INDICATOR);
  static int Count = 0;

  if (SymbolInfoTick(_Symbol, Tick, Ping) &&
      (!IsIndicator || (Count++ > 1))) // SymbolInfoTick в индикаторах требует "разогрева" в виде нескольких первых Calculate-событий
  {
#ifdef HISTOGRAM_VIEW
    Histogram.Add(Ping);
#else // HISTOGRAM_VIEW
    Candles.Add(Ping);

    Average.Add(Ping);
#endif // HISTOGRAM_VIEW

    Comment(__FILE__ + TOSTRING(AccountInfoString(ACCOUNT_SERVER)) + TOSTRING(TerminalInfoInteger(TERMINAL_PING_LAST)) +
            "\nLast Ping = " + DoubleToString(Ping, 3) + "\nLast Tick =" + TickToString(Tick));

//    Print(TickToString(Tick) + TOSTRING(Ping));
  }

  return(rates_total);
}