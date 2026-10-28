//+------------------------------------------------------------------+
//|                                                   SymbolsLib.mq4 |
//|                                          Copyright © 2009, Ilnur |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+

//    Library of functions for working with financial instruments
// downloaded to the trading terminal.

#property copyright "Copyright © 2009, Ilnur"
#property link      "https://www.metaquotes.net"
#property library

//+------------------------------------------------------------------+
//| Get the list of available symbols                                |
//+------------------------------------------------------------------+
int SymbolsList(string &Symbols[], bool Selected)
{
   string SymbolsFileName;
   int Offset, SymbolsNumber;
   
   if(Selected) SymbolsFileName = "symbols.sel";
   else         SymbolsFileName = "symbols.raw";
   
// Open the file with symbols description

   int hFile = FileOpenHistory(SymbolsFileName, FILE_BIN|FILE_READ);
   if(hFile < 0) return(-1);

// Define the number of symbols registered in the file

   if(Selected) { SymbolsNumber = (FileSize(hFile) - 4) / 128; Offset = 116;  }
   else         { SymbolsNumber = FileSize(hFile) / 1936;      Offset = 1924; }

   ArrayResize(Symbols, SymbolsNumber);

// Read symbols from the file

   if(Selected) FileSeek(hFile, 4, SEEK_SET);
   
   for(int i = 0; i < SymbolsNumber; i++)
   {
      Symbols[i] = FileReadString(hFile, 12);
      FileSeek(hFile, Offset, SEEK_CUR);
   }
   
   FileClose(hFile);
   
// Get the number of read instruments

   return(SymbolsNumber);
}

//+------------------------------------------------------------------+
//| Get the decrypted symbol name                                    |
//+------------------------------------------------------------------+
string SymbolDescription(string SymbolName)
{
   string SymbolDescription = "";
   
// Open the file with symbols description

   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");

// Define the number of symbols registered in the file

   int SymbolsNumber = FileSize(hFile) / 1936;

// Search for symbol decryption in the file

   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
         SymbolDescription = FileReadString(hFile, 64);
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   return(SymbolDescription);
}

//+------------------------------------------------------------------+
//| Define the instrument type                                       |
//+------------------------------------------------------------------+
string SymbolType(string SymbolName)
{
   int GroupNumber = -1;
   string SymbolGroup = "";
   
// Open the file with symbols description

   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
   
// Define the number of symbols registered in the file
   
   int SymbolsNumber = FileSize(hFile) / 1936;
   
// Search for the symbol in the file
   
   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
      // Define the group index number
         
         FileSeek(hFile, 1936*i + 100, SEEK_SET);
         GroupNumber = FileReadInteger(hFile);
         
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   if(GroupNumber < 0) return("");
   
// Open the file with groups description
   
   hFile = FileOpenHistory("symgroups.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
   
   FileSeek(hFile, 80*GroupNumber, SEEK_SET);
   SymbolGroup = FileReadString(hFile, 16);
   
   FileClose(hFile);
   
   return(SymbolGroup);
}