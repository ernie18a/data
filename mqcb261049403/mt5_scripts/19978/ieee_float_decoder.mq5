//+------------------------------------------------------------------+
//|                                           IEEE_Float_Decoder.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "Display the actual stored value of a floating-point number (float or double type),"
#property description "with very high precision up to 55 decimal digits."
#property strict
#property script_show_inputs

#include "ieee_fp.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define PRINT(A) Print(#A + " = ", (A));

enum ENUM_DECODE_AS
  {
   FLOAT_TYPE,   // float (32-bits)
   DOUBLE_TYPE   // double (64-bits)
  };

input double          InpNumber = 0.1;            // Floating-point number
input ENUM_DECODE_AS  InpDecodeAs = DOUBLE_TYPE;  // Decode as
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpDecodeAs==FLOAT_TYPE)
     {
      Print("************ DECODING FLOAT (32-BITS) ************");
      PRINT(InpNumber);

      Float_t num=(float)InpNumber;

      PRINT(num.sign());
      PRINT(num.exponent());
      PRINT(num.mantissa());

      // Display the actual stored value
      PRINT(num.raw_hexadecimal());
      PRINT(num.hex_float_constant());
      PRINT(num.norm_exp_notation());
      PRINT(num.exp_notation());
      PRINT(num.as_integer_ratio());
      PRINT(num.decimal());
     }

   else if(InpDecodeAs==DOUBLE_TYPE)
     {
      Print("************ DECODING DOUBLE (64-BITS) ************");
      PRINT(InpNumber);

      Double_t num=(double)InpNumber;

      PRINT(num.sign());
      PRINT(num.exponent());
      PRINT(num.mantissa());

      // Display the actual stored value
      PRINT(num.raw_hexadecimal());
      PRINT(num.hex_float_constant());
      PRINT(num.norm_exp_notation());
      PRINT(num.exp_notation());
      PRINT(num.as_integer_ratio());
      PRINT(num.decimal());
     }
  }
//+------------------------------------------------------------------+

// sample output:
// --------------
// IEEE_Float_Decoder (GBPUSD,H1)	************ DECODING DOUBLE (64-BITS) ************
// IEEE_Float_Decoder (GBPUSD,H1)	InpNumber = 0.1
// IEEE_Float_Decoder (GBPUSD,H1)	num.sign() = 0
// IEEE_Float_Decoder (GBPUSD,H1)	num.exponent() = -4
// IEEE_Float_Decoder (GBPUSD,H1)	num.mantissa() = 2702159776422298
// IEEE_Float_Decoder (GBPUSD,H1)	num.raw_hexadecimal() = 0x3fb999999999999a
// IEEE_Float_Decoder (GBPUSD,H1)	num.hex_float_constant() = 0x1.999999999999ap-4
// IEEE_Float_Decoder (GBPUSD,H1)	num.norm_exp_notation() = 1.600000000000000088817841970012523233890533447265625 x 2^-4
// IEEE_Float_Decoder (GBPUSD,H1)	num.exp_notation() = 7205759403792794 x 2^-56
// IEEE_Float_Decoder (GBPUSD,H1)	num.as_integer_ratio() = 7205759403792794 / 72057594037927936
// IEEE_Float_Decoder (GBPUSD,H1)	num.decimal() = 0.10000000000000000555111512312578270211815834045410156250
