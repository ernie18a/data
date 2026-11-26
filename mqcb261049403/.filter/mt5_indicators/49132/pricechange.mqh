#include "Error.mqh"

struct PRICECHANGE
{
private:
  template <typename T>
  static string NumToString( const T Num, const int digits = 1 )
  {
    return(((Num > 0) ? "+" : "") + ((typename(T) == "double") ? ::DoubleToString(Num, digits) : (string)Num));
  }

  static double GetPrice( const MqlRates &Rates )
  {
    return((Rates.open + Rates.close) / 2);
  }

  double CalcMinMax( const MqlRates &Rates[] )
  {
    bool MaxLast = true;
    double Min = DBL_MAX;
    double Max = -DBL_MAX;

    for (uint i = ::ArraySize(Rates); (bool)i--;)
    {
      const double Price = PRICECHANGE::GetPrice(Rates[i]);

      if (Price > Max)
      {
        Max = Price;

        MaxLast = false;
      }

      if (Price < Min)
      {
        Min = Price;

        MaxLast = true;
      }
    }

    return((Min != DBL_MAX) ? (MaxLast ? Max / Min : Min / Max) - 1 : 0);
  }

public:
  double Value;
  double MinMax;

  string Name;

  void Calc( const string Symb, const datetime Time1, const datetime Time2 )
  {
    MqlRates Rates[];
    const int Size = _E2(::CopyRates(Symb, PERIOD_M1, Time1, Time2, Rates), Symb);

    const double Price1 = (Size > 0) ? PRICECHANGE::GetPrice(Rates[0]) : 1;
    const double Price2 = (Size > 0) ? PRICECHANGE::GetPrice(Rates[Size - 1]) : Price1;

    this.Value = Price2 / Price1 - 1;
    this.MinMax = this.CalcMinMax(Rates);

    this.Name = Symb;

    return;
  }

  string ToString( const double MaxValue = 0 ) const
  {
    return(this.Name + ": " + PRICECHANGE::NumToString(this.Value * 1e4) + "%%" +
           ((MaxValue > 0) ? " (" + DoubleToString(100 * ::MathAbs(this.Value / MaxValue), 1) + "%)" : NULL) +
           ", MinMax = " + PRICECHANGE::NumToString(this.MinMax * 1e4) + "%%" +
           ((MaxValue < 0) ? " (" + DoubleToString(100 * ::MathAbs(this.MinMax / MaxValue), 1) + "%)" : NULL) +
           (this.Name == _Symbol ? " - current symbol." : NULL));
  }
};