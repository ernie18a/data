//+------------------------------------------------------------------+
//|                                          AccountInfo_byPairs.mq5 |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//---
#include <Trade\AccountInfo.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//---
//+------------------------------------------------------------------+
//| Script to testing the use of class CAccountInfo.                 |
//+------------------------------------------------------------------+
//---

// Structure to store aggregated profit/loss and swaps for each symbol
struct SymbolInfo
  {
   string            symbol;
   double            profit;
   double            swap;
  };

//+------------------------------------------------------------------+
//| Account Info Sample script class                                 |
//+------------------------------------------------------------------+
class CAccountInfoSample
  {
protected:
   CAccountInfo      m_account;
   //--- chart objects
   CChartObjectLabel m_label[19];
   CChartObjectLabel m_label_info[19];
   //--- Array to store symbol information
   SymbolInfo        m_symbols[];

public:
                     CAccountInfoSample(void);
                    ~CAccountInfoSample(void);
   //---
   bool              Init(void);
   void              Deinit(void);
   void              Processing(void);

private:
   void              AccountInfoToChart(void);
  };

CAccountInfoSample ExtScript;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAccountInfoSample::CAccountInfoSample(void)
  {
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAccountInfoSample::~CAccountInfoSample(void)
  {
  }

//+------------------------------------------------------------------+
//| Method to initialize the script.                                 |
//+------------------------------------------------------------------+
bool CAccountInfoSample::Init(void)
  {
   int i, sy = 30;
   int dy = 20;
   color color_label;
   color color_info;
//--- tuning colors
   color_info = (color)(ChartGetInteger(0, CHART_COLOR_BACKGROUND) ^ 0xFFFFFF);
   color_label = (color)(color_info ^ 0x202020);
//---
   if(ChartGetInteger(0, CHART_SHOW_OHLC))
      sy += 16;
// Get information about currency pairs and their additional values
   ArrayResize(m_symbols, 0);
   sInfo(m_symbols);
//--- creation Labels[]
   for(i = 0; i < 19; i++)
     {
      // Check if the index exceeds the number of pairs in init_str_custom
      if(i >= ArraySize(m_symbols))
         continue;
      m_label[i].Create(0, "Label" + IntegerToString(i), 0, 20, sy + dy * i);
      m_label[i].Description(m_symbols[i].symbol);
      m_label[i].Color(color_label);
      m_label[i].FontSize(10);
      //---
      m_label_info[i].Create(0, "LabelInfo" + IntegerToString(i), 0, 90, sy + dy * i);
      m_label_info[i].Description(" ");
      m_label_info[i].Color(color_info);
      m_label_info[i].FontSize(10);
     }
// Update chart with received information
   AccountInfoToChart();
//--- redraw chart
   ChartRedraw();
//---
   return (true);
  }

//+------------------------------------------------------------------+
//| Method to deinitialize the script.                               |
//+------------------------------------------------------------------+
void CAccountInfoSample::Deinit(void)
  {
  }

//+------------------------------------------------------------------+
//| Main processing method.                                          |
//+------------------------------------------------------------------+
void CAccountInfoSample::Processing(void)
  {
// Clear the m_symbols array before updating data
   ArrayResize(m_symbols, 0);
// Get new data about positions and update user data
   sInfo(m_symbols);
   AccountInfoToChart();
//--- redraw chart
   ChartRedraw();
   Sleep(50);
  }

//+------------------------------------------------------------------+
//| Method to update chart with account information.                 |
//+------------------------------------------------------------------+
void CAccountInfoSample::AccountInfoToChart(void)
  {
   for(int i = 0; i < ArraySize(m_symbols); i++)
     {
      m_label[i].Description(m_symbols[i].symbol);
      if(m_symbols[i].profit == NULL)
         m_label_info[i].Description("");
      else
         m_label_info[i].Description(FormatNumberWithSpaces(NormalizeDouble((m_symbols[i].profit + m_symbols[i].swap), 2)));
     }
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart(void)
  {
//--- call init function
   if(ExtScript.Init())
     {
      //--- cycle until the script is not halted
      while(!IsStopped())
         ExtScript.Processing();
     }
//--- call deinit function
   ExtScript.Deinit();
  }

//+------------------------------------------------------------------+
//| Function to retrieve position information and calculate aggregated profit/loss. |
//+------------------------------------------------------------------+
void sInfo(SymbolInfo &symbols[])
  {
// Get the number of open positions
   int total = PositionsTotal();
   int position_ticket;
   string customSymbols[] = {"", "Balance", "Equity", "Profit"};
   double customProfits[] = {NULL, NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2), NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2), NormalizeDouble(AccountInfoDouble(ACCOUNT_PROFIT), 2)};
// Iterate through all open positions
   for(int i = 0; i < total; i++)
     {
      // Get position information
      position_ticket = int(PositionGetTicket(i));
      if(!PositionSelectByTicket(position_ticket))
         continue;
      // Get symbol of the position
      string symbol = PositionGetString(POSITION_SYMBOL);
      // Get profit/loss of the position
      double profit = PositionGetDouble(POSITION_PROFIT);
      // Get swap of the position
      double swap = PositionGetDouble(POSITION_SWAP);
      // Check if information about this symbol has already been collected
      int index = -1;
      for(int j = 0; j < ArraySize(symbols); j++)
        {
         if(symbols[j].symbol == symbol)
           {
            index = j;
            break;
           }
        }
      if(index == -1)
        {
         // If information about this symbol does not exist, add a new entry
         SymbolInfo newSymbol;
         newSymbol.symbol = symbol;
         newSymbol.profit = profit;
         newSymbol.swap = swap;
         ArrayResize(symbols, ArraySize(symbols) + 1);
         symbols[ArraySize(symbols) - 1] = newSymbol;
        }
      else
        {
         // If information about this symbol already exists, update profit/loss and swap
         symbols[index].profit += profit;
         symbols[index].swap += swap;
        }
     }
// Sort the symbols array by profit in descending order
   for(int m = 0; m < ArraySize(symbols) - 1; m++)
     {
      for(int n = 0; n < ArraySize(symbols) - m - 1; n++)
        {
         if((symbols[n].profit + symbols[n].swap) < (symbols[n + 1].profit + symbols[n + 1].swap))
           {
            SymbolInfo temp = symbols[n];
            symbols[n] = symbols[n + 1];
            symbols[n + 1] = temp;
           }
        }
     }
// Add custom data to the SymbolInfo structure
   for(int k = 0; k < ArraySize(customSymbols); k++)
     {
      SymbolInfo customData;
      customData.symbol = customSymbols[k];
      customData.profit = customProfits[k];
      customData.swap = 0;
      ArrayResize(symbols, ArraySize(symbols) + 1);
      symbols[ArraySize(symbols) - 1] = customData;
     }
  }

//+------------------------------------------------------------------+
//| Function to format number with spaces.                          |
//+------------------------------------------------------------------+
string FormatNumberWithSpaces(double number)
  {
   string positiveShift = (number >= 0) ? "  " : "- ";
   string formattedNumber = DoubleToString(MathAbs(number), 2);
// Separate the number into integer and fractional parts
   int dotPos = StringFind(formattedNumber, ".");
   string integerPart = (dotPos == -1) ? formattedNumber : StringSubstr(formattedNumber, 0, dotPos);
   string fractionalPart = (dotPos == -1) ? "" : StringSubstr(formattedNumber, dotPos);
// Format the integer part by adding spaces between digits
   string result = "";
   int integerLen = StringLen(integerPart);
   for(int i = 0; i < integerLen; i++)
     {
      result += StringSubstr(integerPart, i, 1);
      if((integerLen - i - 1) % 3 == 0 && i != integerLen - 1)
         result += " ";
     }
// Assemble the number back, adding the fractional part
   result += fractionalPart;
   result = positiveShift + result;
   return result;
  }
