//+------------------------------------------------------------------+
//|                                             Collect Close Prices |
//|                        Saves Data to CSV                         |
//+------------------------------------------------------------------+
#property script_show_inputs

// Input parameter
input int NBars = 100;  // Number of bars to collect

// Function to write data to CSV
void WriteToCSV(string filename, const string &data[])
{
   int fileHandle = FileOpen(filename, FILE_CSV|FILE_WRITE|FILE_ANSI, ',');
   if(fileHandle != INVALID_HANDLE)
   {
      for(int i = 0; i < ArraySize(data); i++)
      {
         FileWrite(fileHandle, data[i]);
      }
      FileClose(fileHandle);
      Print("File successfully written: ", filename);
   }
   else
   {
      Print("Error: Unable to open file ", filename);
   }
}

// Main script execution
void OnStart()
{
   // Ensure NBars is valid
   if(NBars <= 0)
   {
      Print("Error: NBars must be greater than 0");
      return;
   }
   
   // Prepare file name
   string filename = Symbol() + "_ClosePrices.csv";
   
   // Collect data
   string data_array[];
   
   // Add header
   ArrayResize(data_array, 1);
   data_array[0] = "Date,Time,Close Price";
   
   // Ensure correct indexing order
   ArraySetAsSeries(data_array, false);
   
   for(int i = NBars - 1; i >= 0; i--)
   {
      datetime barTime = iTime(Symbol(), PERIOD_CURRENT, i);
      double closePrice = iClose(Symbol(), PERIOD_CURRENT, i);
      
      if(barTime == 0) break;  // Stop if no more data
      
      int index = ArraySize(data_array);
      ArrayResize(data_array, index + 1);
      data_array[index] = TimeToString(barTime, TIME_DATE) + "," + TimeToString(barTime, TIME_SECONDS) + "," + DoubleToString(closePrice, Digits());
   }
   
   // Write to CSV
   WriteToCSV(filename, data_array);
   
   Print("Close prices collected and saved to ", filename);
}
