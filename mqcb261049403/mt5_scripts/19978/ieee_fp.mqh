//+------------------------------------------------------------------+
//|                                                      ieee_fp.mqh |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property strict


#ifndef _LOAD_MODULE_IEEE_FLOAT
#define _LOAD_MODULE_IEEE_FLOAT


// https://randomascii.wordpress.com/2012/01/11/tricks-with-the-floating-point-format/
// https://www.exploringbinary.com/floating-point-converter/
// https://www.h-schmidt.net/FloatConverter/IEEE754.html
// https://float.exposed/0x40490fdb
// http://evanw.github.io/float-toy/
// https://bartaz.github.io/ieee754-visualization/
// https://docs.python.org/3/tutorial/floatingpoint.html
// A 32 bit floating point number (s e m) represents the real value (-1^s)*(2^(e-127))*[1 +m/(2^23)]
// A 64 bit floating point number (s e m) represents the real value (-1^s)*(2^(e-1023))*[1 +m/(2^52)]
union Float_t
  {
   float             _f;
   int               _i;

   void        Float_t(const float number=0.0) : _f(number) { }
   void        operator=(const float number) { _f=number; }

   // Portable extraction of components.
   int         sign()                        const { return (int)_getBits(_i, 31, 1);         }
   int         exponent()                    const { return (int)_getBits(_i, 23, 8) - 127;   }
   int         mantissa()                    const { return (int)_getBits(_i, 0, 23);         }

   // Display the actual stored value of a floating-point number.
   string      raw_hexadecimal()             const { return StringFormat("0x%.8I64x", _i);    }
   string      hex_float_constant()          const { return StringFormat("%.6a", _f); }
   string      norm_exp_notation()           const { return StringFormat("%s%.24g x 2^%.0f", sign() ? "-" : "", 1.0 + mantissa() / MathPow(2, 23), exponent() ); }
   string      exp_notation()                const { return StringFormat("%s%.0f x 2^%.0f", sign() ? "-" : "", MathPow(2, 23) + mantissa(), exponent() - 23 ); }
   string      as_integer_ratio()            const { return StringFormat("%s%.0f / %.0f", sign() ? "-" : "", MathPow(2, 23) + mantissa(), MathPow(2, 23 - exponent()) ); }

   // https://www.exploringbinary.com/maximum-number-of-decimal-digits-in-binary-floating-point-numbers/
   //string    decimal()                     const { return StringFormat("%.*f", 23 - (int)MathFloor(MathLog(MathAbs(_f))/M_LN2), _f); }
   string      decimal()                     const { return StringFormat("%.*f", 23 - exponent(), _f); }  // binary point size
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
union Double_t
  {
   double            _f;
   long              _i;

   void        Double_t(const double number=0.0) : _f(number) { }
   void        operator=(const double number) { _f=number; }

   // Portable extraction of components.
   int         sign()                        const { return (int)_getBits(_i, 63, 1);         }
   int         exponent()                    const { return (int)_getBits(_i, 52, 11) - 1023; }
   long        mantissa()                    const { return (long)_getBits(_i, 0, 52);        }

   // Display the actual stored value of a floating-point number.
   string      raw_hexadecimal()             const { return StringFormat("0x%.16I64x", _i);   }
   string      hex_float_constant()          const { return StringFormat("%.13a", _f); }
   string      norm_exp_notation()           const { return StringFormat("%s%.53g x 2^%.0f", sign() ? "-" : "", (1.0 + mantissa() / MathPow(2, 52)), exponent() ); }
   string      exp_notation()                const { return StringFormat("%s%.0f x 2^%.0f", sign() ? "-" : "", MathPow(2, 52) + mantissa(), exponent() - 52 ); }
   string      as_integer_ratio()            const { return StringFormat("%s%.0f / %.0f", sign() ? "-" : "", MathPow(2, 52) + mantissa(), MathPow(2, 52 - exponent()) ); }

   // https://www.exploringbinary.com/maximum-number-of-decimal-digits-in-binary-floating-point-numbers/
   //string    decimal()                     const { return StringFormat("%.*f", 52 - (int)MathFloor(MathLog(MathAbs(_f))/M_LN2), _f); }
   string      decimal()                     const { return StringFormat("%.*f", 52 - exponent(), _f); }  // binary point size
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong _getBits(ulong num,int pos,int cnt=1)
  {
   ulong mask=((ulong)1<<cnt)-1; // 2^n - 1
   return (num >> pos) & mask;
  }

#endif
//+------------------------------------------------------------------+
