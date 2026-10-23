//+------------------------------------------------------------------+
//|                                             StringArraySuite.mqh |
//|                                    Copyright © 2006-2008, sx ted |
//|                                               sxted@talktalk.net |
//|                                                       2006.07.14 |
//| Purpose.: Functions for handling two dimensional string arrays.  |
//|           Usefull for prototyping.                               |
//| ThankYou: Compliments to the programmers and the MetaQuotes team |
//|           for MT4, amazing.                                      |
//| Notes...: See StringArraySuiteSample.mq4 for usage.              |
//| Revision: 1) 2008.01.08 StringArrayLoad() now accepts NULL values|
//|              which are replaced with empty strings in the array, |
//|              comment lines catered for, algorythm enhanced.      |
//|              Added StringArrayFindUnsorted(), StringArrayLoad1D()|
//|              and StringArrayWrite1D().                           |
//|              Function Error() removed, functions return -1 if an |
//|              error is encountered and the error cause may be     |
//|              retrieved using GetLastError().                     |
//|              Added debugging functions Array2DoubleWrite() and   |
//|              Array2IntWrite().                                   |
//|           2) 2009.04.22 StringArraySort() corrected and replaced |
//|              with bubble sort.                                   |
//|              StringArrayLoad() added new parameter sDelimiter.   |
//|              Added new functions StringCell(), StringCells(),    |
//|              StringToArray(), StringToColor(), StringTran() and  |
//|              StringChangeToUpperCase().                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2008, sx ted"
#property link      "sxted@talktalk.net"
#define ERROR -1

//+------------------------------------------------------------------+
//| Function..: StringArrayAdd                                       |
//| Parameters: A      - Name of the string array.                   |
//|             iCount - Number of new rows to be added, defaults to |
//|                      one row if the parameter is omitted.        |
//|             sValue - Value to be set for the cells of the new    |
//|                      row(s), defaults to a string of zero        |
//|                      length (the string "").                     |
//| Purpose...: Append one or more new row(s) to a two dimensional   |
//|             string array, and set the new cells with <sValue>.   |
//| Returns...: Position number of the first row added, or -1 if an  |
//|             error occured and the array is not resized.          |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayAdd(string& A[][], int iCount=1, string sValue="") 
  {
    int iRows = ArrayRange(A, 0);
//----
    if(ArrayResize(A, iRows+iCount) > 0) 
      {
        StringArrayIni(A, sValue, iRows, iCount);
        return(iRows);
      }
    return(ERROR);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayDelete                                    |
//| Parameters: A      - Name of the string array.                   |
//|             iRow   - Index position in dimension 1 where the row |
//|                      is to be deleted from the array.            |
//|             iCount - Number of rows to be deleted starting at    |
//|                      position <iRow>, the default is to delete   |
//|                      one row (if the parameter is omitted).      |
//| Purpose...: Delete one or more row(s) in a two dimensional array.|
//| Returns...: Count of cells remaining in the array after deleting |
//|             otherwise returns -1 if an error occured and the     |
//|             array is not resized.                                |
//| Sample....: int iRow=StringArrayFind(A,"2000",1); // exact match |
//|             if(iRow >= 0) StringArrayDelete(A, iRow);            |
//+------------------------------------------------------------------+
int StringArrayDelete(string& A[][], int iRow, int iCount = 1) 
  {
    int iRows = ArrayRange(A, 0); 
    int iRowsToCopy = MathMin(iRows - iCount - iRow, iCount); 
    int iCols, iCol, iDestination, iSource, i;
//----
    if(!(iRows > 0 && iRows > iRow && iRows >= iRow + iCount - 1)) 
        return(ERROR);
    iCols = ArraySize(A) / iRows;
    string sCopy[]; // backup
//----
    for(iSource = iRows - iRowsToCopy, i = 0; iSource < iRows; iSource++, i++) 
      {
        if(ArrayResize(sCopy, (i + 1)*iCols) > 0) 
          {
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                iDestination = i*iCols + iCol;
                sCopy[iDestination] = A[iSource][iCol];
              }
          }
        else return(ERROR); 
      }
//----
    if(ArrayResize(A, iRows - iCount) >= 0) 
      {
        iRows -= iCount;
        //----
        for(iDestination = iRow; iDestination < iRows-iRowsToCopy; iDestination++) 
          {
            iSource = iDestination + iCount;
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                A[iDestination][iCol] = A[iSource][iCol];
              }
          }
        //----
        for(iDestination = iRows - iRowsToCopy, i = 0; iDestination < iRows; iDestination++, i++) 
          {
            for(iCol = 0; iCol < iCols; iCol++) 
              {
                iSource=i*iCols + iCol;
                A[iDestination][iCol] = sCopy[iSource];
              }
          }
        return (iRows*iCols);
      }
    return(ERROR);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayFind                                      |
//| Parameters: A      - The string array in which to search for.    |
//|             sFind  - The string to find.                         |
//|             bExact - Pass value 1 for exact search match,        |
//|                      pass value 0 for soft seek.                 |
//|                      Defaults to TRUE (1) if no value is passed. |
//|             iStart - Starting index to search for. Default value |
//|                      is 0 for search to start on first row.      |
//|             iCount - Count of elements to search for.            |
//|                      By default searches the whole array.        |
//|             iDir   - Search direction. It can be either of the   |
//|                      following values:                           |
//|                      MODE_ASCEND  (1) search array sorted A to Z,|
//|                      MODE_DESCEND (2) search array sorted Z to A.|
//|                      The default is to search for a value in an  |
//|                      array whose first dimension is sorted in    |
//|                      ascending mode.                             |
//| Purpose...: Find a value in a sorted two dimension string array. |
//| Returns...: If bExact is passed as 0 (false) returns the index   |
//|             of the first occurrence of a value in the first      |
//|             dimension of array if possible, or the nearest one   |
//|             if the occurrence is not found.                      |
//|             If bExact is passed as 1 (true) StringArrayFind will |
//|             return -1 if the value is not found, otherwise the   |
//|             index position.                                      |
//| Notes.....: Ensure that if numbers are to be searched for in the |
//|             first dimension that they are all of the same length |
//|             by pre-pending with "*" or other character with lower|
//|             ASCII code value, same applies to the search string. |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayFind(string A[][], string sFind, bool bExact = TRUE, int iStart = 0, 
                    int iCount = WHOLE_ARRAY, int iDir = MODE_ASCEND) 
  {
    int iMiddle;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = ArrayRange(A, 0)-1; 
    else 
        iCount = (iStart + iCount) -1 ;
//----
    if(iDir == MODE_ASCEND) 
      {
        while(iCount - iStart > 1) 
          {
            iMiddle = (iStart+iCount) / 2;
            //----
            if(A[iMiddle][0] == sFind) 
                return(iMiddle);
            //----
            if(sFind > A[iMiddle][0]) 
                iStart = iMiddle; 
            else 
                iCount=iMiddle;
          }
      }
    else 
      {
        while(iCount - iStart > 1) 
          {
            iMiddle = (iStart + iCount) / 2;
            //----
            if(A[iMiddle][0] == sFind) 
                return(iMiddle);
            //----
            if(sFind < A[iMiddle][0]) 
                iStart=iMiddle; 
            else 
                iCount=iMiddle;
          }
      }
//----
    if(A[iStart][0] == sFind || (!bExact && sFind < A[iStart][0])) 
        return(iStart); 
    else 
        if(A[iCount][0] == sFind || !bExact) 
            return(iCount);
    return(-1);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayFindUnsorted                              |
//| Parameters: A      - The string array in which to search for.    |
//|             sFind  - The string to find in the first dimension.  |
//| Purpose...: Find a value in an unsorted two dimensional string   |
//|             array.                                               |
//| Returns...: StringArrayFindUnsorted will return -1 if the value  |
//|             is not found, otherwise the index position.          |
//| Notes.....: Ensure that if numbers are to be searched for in the |
//|             first dimension that they are all of the same length |
//|             by pre-pending with "*" or other character with lower|
//|             ASCII code value, same applies to the search string. |
//| Sample....: string A[2][2]={ "GBPUSD","500","EURUSD","400" };    |
//|             int iRow=StringArrayFindUnsorted(A, "EURUSD");       |
//|             if(iRow >= 0) Print("Found at row ", iRow);          |
//|             else Print("Not found");                             |
//+------------------------------------------------------------------+
int StringArrayFindUnsorted(string A[][], string sFind) {
  int iRows=ArrayRange(A, 0);
  for(int iRow=0; iRow < iRows; iRow++) {
    if(A[iRow][0] == sFind)
      return(iRow);
  }
  return(-1);
}

//+------------------------------------------------------------------+
//| Function..: StringArrayIni                                       |
//| Parameters: A      - Name of the string array.                   |
//|             sValue - New value to be set, defaults to a string   |
//|                      of zero length (the string "").             |
//|             iStart - Index position in dimension 1 start row for |
//|                      which the cells are  to be initialized, the |
//|                      default value is row zero if the parameter  |
//|                      is omitted.                                 |
//|             iCount - Count of rows to be initialized, defaults   |
//|                      to the whole array if the parameter is not  |
//|                      passed.                                     |
//| Purpose...: Set all cells of one or more row(s) of a two         |
//|             dimensional string array to the same value.          |
//| Returns...: Number of cells initialized.                         |
//| Sample....: StringArrayIni(A, "0");                              |
//+------------------------------------------------------------------+
int StringArrayIni(string& A[][], string sValue = "", int iStart = 0, int iCount = WHOLE_ARRAY) 
  {
    int iCells = 0;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount=ArrayRange(A, 0); 
    else 
        iCount = (iStart + iCount) - 1;
//----
    for(int iRow = iStart; iRow <= iCount; iRow++) 
      {
        iCells += StringArrayIniRow(A, sValue, iRow);
      }
    return(iCells);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayIniRow                                    |
//| Parameters: A      - Name of the string array.                   |
//|             sValue - New value to be set.                        |
//|             iRow   - Index position in dimension 1 where the row |
//|                      whose cells are to be initialized.          |
//| Purpose...: Initialize the cells of a row with new value.        |
//| Returns...: Number of cells initialized.                         |
//| Sample....: StringArrayIniRow(A, "0", iRow);                     |
//+------------------------------------------------------------------+
int StringArrayIniRow(string& A[][], string sValue, int iRow) 
  {
    int iCols = ArrayRange(A, 0);
    if(iCols > 0) 
      {
        iCols = ArraySize(A) / iCols;
        for(int iCol = 0; iCol < iCols; iCol++) 
          {
            A[iRow][iCol] = sValue;
          }
      }
    return (iCols);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayInsert                                    |
//| Parameters: A      - Name of the string array.                   |
//|             iRow   - Index position in dimension 1 where the new |
//|                      row is to be inserted in the array.         |
//|             iCount - Number of new rows to be inserted starting  |
//|                      at position <iRow>, the default is to insert|
//|                      one row (if the parameter is omitted).      |
//|             sValue - Value to be set for the cells of the new    |
//|                      row(s), defaults to a string of zero length |
//|                      (the string "").                            |
//| Purpose...: Insert one or more new row(s) in a two dimensional   |
//|             array, and initialize the new cells with a value.    |
//| Returns...: Position number of the first row inserted, or        |
//|             -1 if an attempt is made to insert after last row or |
//|             if an error occured and the array is not resized.    |
//| Sample....: string A[2][2]={ "EURUSD","500","GBPUSD","400" };    |
//|             string sKey=Symbol();                                |
//|             int iRows=ArrayRange(A, 0);                          |
//|             int iRow =StringArrayFind(A, sKey, 0) // soft seek   |
//|             if(iRows == 0 || A[iRow][0] < sKey)                  |
//|               iRow=StringArrayAdd(A, 1, sKey);                   |
//|             else if(A[iRow][0] != sKey)                          |
//|               iRow=StringArrayInsert(A, iRow, 1, sKey);          |
//|             if(iRow == -1) return (-1);                          |
//|             A[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//+------------------------------------------------------------------+
int StringArrayInsert(string& A[][], int iRow, int iCount = 1, string sValue = "") 
  {
    int iRows = ArrayRange(A, 0), iCells, iCols, iDestination;
//----
    if(iRows == 0) 
        return(StringArrayAdd(A, iCount, sValue));
//----
    if(iRows <= iRow) 
        return(ERROR);
    iCells = ArrayResize(A, iRows + iCount);
//----
    if(iCells > 0) 
      {
        iCols = iCells / (iRows + iCount);
        for(int iSource = iRows; iSource >= iRow; iSource--) 
          {
            iDestination = iSource + iCount;
            for(int iCol = 0; iCol < iCols; iCol++) 
              {
                A[iDestination][iCol] = A[iSource][iCol];
              }
          }
        StringArrayIni(A, sValue, iRow, iCount);
        return(iRow);
      }
    return(ERROR);
  }

//+------------------------------------------------------------------+
//| Function..: StringArrayLoad                                      |
//| Parameters: sFile - File name, file may be with any extension,   |
//|             A     - Array where data will be stored,             |
//|             iCols - Number of columns to be loaded starting from |
//|                     column one in the CSV file.                  |
//|             sDelimiter - Delimiter character for csv files.      |
//|                          By default, the "," symbol applies.     |
//|                          NOTE: different to MT4 which uses ";"   |
//| Purpose...: Read all text elements from a CSV file into a two    |
//|             dimensional array.                                   |
//| Returns...: Returns number of rows loaded or -1 if an error      |
//|             occured which can be examined using GetLastError().  |
//| Notes.....: The array is resized dynamically.                    |
//|             Cells in the CSV file with NULL values are replaced  |
//|             in the array with empty strings.                     |
//|             Any line starting with the // symbols is treated as  |
//|             a comment line and not loaded into the array.        |
//| Sample....: string A[2][2]={"GBPUSD","500","EURUSD","600"};      |
//|             StringArraySort(A);                                  |
//|             StringArrayWrite(A);                                 |
//|                                                                  |
//|             string B[][2];                                       |
//|             int iRows=StringArrayLoad("My.CSV", B, 2); //import A|
//|             int iRow =StringArrayAdd(B, 1, Symbol());            |
//|             B[iRow][1]=DoubleToStr(iVolume(NULL,PERIOD_MN1,0),0);|
//|             StringArrayWrite(B, "B.CSV");                        |
//+------------------------------------------------------------------+
int StringArrayLoad(string sFile, string& A[][], int iCols, string sDelimiter = ",") {
  int handle=FileOpen(sFile,FILE_CSV|FILE_READ,sDelimiter), iRows=ArrayRange(A,0), iRow, iCol;
  if(handle<1 || FileSize(handle)==0) return(ERROR);
  string sCell;
    
  while(!FileIsEnding(handle)) {
    sCell=FileReadString(handle);
    if(StringLen(sCell)<1 || StringSubstr(sCell,0,2)=="//") {
      while(!FileIsLineEnding(handle)) FileReadString(handle); // empty lines or comment lines ignored
      continue;
    }
    if(iRow>=iRows) {
      if(ArrayResize(A,iRows+1) == 0 ) return(ERROR);
      iRows+=1;
    }
    A[iRow][0]=sCell;
    for(iCol=1; iCol<iCols; iCol++) {
      A[iRow][iCol]=FileReadString(handle);
      if(StringLen(A[iRow][iCol])<1) A[iRow][iCol]=""; // NULL or empty string replaced with empty string
    }
    while(!FileIsLineEnding(handle)) FileReadString(handle);
    iRow++;
  }
  FileClose(handle);
  return(iRow);
}

//+------------------------------------------------------------------+
//| Function..: StringArrayLoad1D                                    |
//| Parameters: sFile - File name, file may be with any extension,   |
//|             A     - Array where data will be stored.             |
//| Purpose...: Read all text elements from a CSV file into a single |
//|             dimensional array.                                   |
//| Returns...: Returns number of rows loaded or -1 if an error      |
//|             occured which can be examined using GetLastError().  |
//| Notes.....: The array is resized dynamically.                    |
//|             Any line starting with the // symbols is treated as  |
//|             a comment line and not loaded into the array.        |
//+------------------------------------------------------------------+
int StringArrayLoad1D(string sFile, string& A[]) {
  int    handle=FileOpen(sFile, FILE_CSV|FILE_READ, ";"), 
         iRows =ArrayRange(A,0),
         iRow;
  string sCell;
  
  if(handle<1 || FileSize(handle)==0) return(ERROR);

  while(!FileIsEnding(handle)) {
    sCell=FileReadString(handle);
    if(StringLen(sCell)<1 || StringSubstr(sCell,0,2)=="//") continue; // empty lines or comment lines ignored
    if(iRow>=iRows) {
      if(ArrayResize(A,iRows+1) == 0 ) return(ERROR);
      iRows+=1;
    }
    A[iRow]=sCell;
    iRow++;
  }
  FileClose(handle);
  return(iRow);
}

//+------------------------------------------------------------------+
//| Function..: StringArraySort                                      |
//| Parameters: A        - Name of the string array.                 |
//|             iSortCol - column number which is to be sorted,      |
//|                        defaults to the first column (zero).      |
//| Purpose...: Sort a two dimensional array in ascending mode.      |
//| Returns...: The sorted string array passed by reference.         |
//| Sample....: string A[2][2]={"GBPUSD","500","EURUSD","600"};      |
//|             StringArraySort(A);                                  |
//|             StringArrayWrite(A);                                 |
//+------------------------------------------------------------------+
void StringArraySort(string& A[][], int iSortCol = 0) {
  bool   ok    = false;
  int    iRows = ArrayRange(A, 0), iRow;
  if(iRows == 0) return;
  int    iCols = ArraySize(A) / iRows, iCol;
  string sTemp = "";
  
  while(!ok) {
    ok=true ;
    for(iRow=0; iRow < iRows-1; iRow++) {
      if(A[iRow][iSortCol] > A[iRow+1][iSortCol]) {
        ok=false;
        for(iCol=0; iCol<iCols; iCol++) {
          sTemp=A[iRow+1][iCol];
          A[iRow+1][iCol]=A[iRow][iCol];
          A[iRow][iCol]=sTemp;
        }
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Function..: StringArrayWrite                                     |
//| Parameters: A      - Name of the string array.                   |
//|             sFile  - Output file name, defaults to "My.CSV".     |
//|             bAdd   - If set to 1 (true) appends the data to the  |
//|                      existing file <sFile>, otherwise if set to  |
//|                      the default 0 (false) the previous contents |
//|                      are over written with the new data.         |
//|             iStart - First row to be written to the file, the    |
//|                      default is row 0.                           |
//|             iCount - Number of rows to be written to the file,   |
//|                      the  default is all rows.                   |
//| Purpose...: Write a two dimensional array to a CSV file for      |
//|             viewing with a text editor or further manipulations  |
//|             using a spreadsheet. Usefull for debugging.          |
//| Returns...: Number of rows written, or a negative value if an    |
//|             error occurs.                                        |
//| Sample....: string sProfit[2][2]={"Jan","-150","Feb","200"};     |
//|             StringArrayWrite(sProfit);                           |
//+------------------------------------------------------------------+
int StringArrayWrite(string A[][], string sFile = "My.CSV", bool bAdd = false, 
                     int iStart = 0, int iCount = WHOLE_ARRAY) 
  {
    int iRows = ArrayRange(A, 0), iCols, handle, iRowsWritten, iRow, iCol;
//----
    if(iRows == 0) 
        return (0);
    iCols = ArraySize(A) / iRows;
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = iRows; 
    else 
        iCount = iStart + iCount - 1;
//----
    if(!bAdd) 
        handle = FileOpen(sFile, FILE_CSV|FILE_WRITE, ',');
    else 
        handle = FileOpen(sFile, FILE_CSV|FILE_READ|FILE_WRITE, ',');
//----
    if(handle < 1) 
        return (ERROR);
//----
    if(bAdd) 
        FileSeek(handle, 0, SEEK_END);
    string sColSeperator = ",";
//----
    for(iRow = iStart; iRow < iCount; iRow++) 
      {
        for(iCol = 0; iCol < iCols-1; iCol++) 
          {
            FileWrite(handle, A[iRow][iCol] + sColSeperator);
            FileSeek(handle, -2, SEEK_END);
          } 
        FileWrite(handle, A[iRow][iCol]);
        iRowsWritten++;
      }
    FileClose(handle);
    return(iRowsWritten);
}

//+------------------------------------------------------------------+
//| Function..: StringArrayWrite1D                                   |
//| Parameters: A      - Name of the string array.                   |
//|             sFile  - Output file name, defaults to "My.CSV".     |
//|             bAdd   - If set to 1 (true) appends the data to the  |
//|                      existing file <sFile>, otherwise if set to  |
//|                      the default 0 (false) the previous contents |
//|                      are over written with the new data.         |
//|             iStart - First row to be written to the file, the    |
//|                      default is row 0.                           |
//|             iCount - Number of rows to be written to the file,   |
//|                      the  default is all rows.                   |
//| Purpose...: Write a one dimensional array to a CSV file for      |
//|             viewing with a text editor or further manipulations  |
//|             using a spreadsheet. Usefull for debugging.          |
//| Returns...: Number of rows written, or a negative value if an    |
//|             error occurs.                                        |
//| Sample....: string sErrors[2]={"Error1","Error2"};               |
//|             StringArrayWrite(sErrors);                           |
//+------------------------------------------------------------------+
int StringArrayWrite1D(string A[], string sFile = "My.CSV", bool bAdd = false, 
                     int iStart = 0, int iCount = WHOLE_ARRAY) 
  {
    int iRows = ArrayRange(A, 0), handle, iRowsWritten, iRow;
//----
    if(iRows == 0) 
        return (0);
//----
    if(iCount == WHOLE_ARRAY) 
        iCount = iRows; 
    else 
        iCount = iStart + iCount - 1;
//----
    if(!bAdd) 
        handle = FileOpen(sFile, FILE_CSV|FILE_WRITE, ',');
    else 
        handle = FileOpen(sFile, FILE_CSV|FILE_READ|FILE_WRITE, ',');
//----
    if(handle < 1) 
        return (ERROR);
//----
    if(bAdd) 
        FileSeek(handle, 0, SEEK_END);
//----
    for(iRow = iStart; iRow < iCount; iRow++) 
      {
        FileWrite(handle, A[iRow]);
        iRowsWritten++;
      }
    FileClose(handle);
    return(iRowsWritten);
}

//+==================================================================+
// Added here for debugging
//+------------------------------------------------------------------+
//| Function..: Array2DoubleWrite                                    |
//| Parameters: A      - Name of the double array.                   |
//|             sFile  - Output file name, defaults to "My.CSV".     |
//|             bAdd   - If set to 1 (true) appends the data to the  |
//|                      existing file <sFile>, otherwise if set to  |
//|                      the default 0 (false) the previous contents |
//|                      are over written with the new data.         |
//|             iStart - First row to be written to the file, the    |
//|                      default is row 0.                           |
//|             iCount - Number of rows to be written to the file,   |
//|                      the  default is all rows.                   |
//| Purpose...: Write a two dimensional array to a CSV file for      |
//|             viewing with a text editor or further manipulations  |
//|             using a spreadsheet. Usefull for debugging.          |
//| Returns...: Number of rows written, or a negative value if an    |
//|             error occurs.                                        |
//| Example...:                                                      |
//+------------------------------------------------------------------+
int Array2DoubleWrite(double A[][], string sFile = "My.CSV", bool bAdd = false, int iStart = 0, int iCount = WHOLE_ARRAY) {
  int iRows = ArrayRange(A, 0), iCols, handle, iRowsWritten, iRow, iCol;

  if(iRows == 0) return(0);  
  iCols = ArraySize(A) / iRows;
  if(iCount == WHOLE_ARRAY) iCount = iRows; 
  else                      iCount = iStart + iCount - 1;
  if(!bAdd) handle = FileOpen(sFile, FILE_CSV|FILE_WRITE, ',');
  else      handle = FileOpen(sFile, FILE_CSV|FILE_READ|FILE_WRITE, ',');
  if(handle < 1) return(ERROR); 
  if(bAdd) {
    FileSeek(handle, 0, SEEK_END);
    FileWrite(handle, "***** ", TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS), " *****");
  }
  string sColSeperator = ",";
  for(iRow = iStart; iRow < iCount; iRow++) {
    for(iCol = 0; iCol < iCols-1; iCol++) {
      FileWrite(handle, A[iRow][iCol], sColSeperator);
      //FileSeek(handle, -2, SEEK_END);
      FileSeek(handle, -3, SEEK_END);
    } 
    FileWrite(handle, A[iRow][iCol]);
    iRowsWritten++;
  }
  FileClose(handle);
  return(iRowsWritten);
}

//+------------------------------------------------------------------+
//| Function..: Array2IntWrite                                       |
//| Parameters: A      - Name of the integer array.                  |
//|             sFile  - Output file name, defaults to "My.CSV".     |
//|             bAdd   - If set to 1 (true) appends the data to the  |
//|                      existing file <sFile>, otherwise if set to  |
//|                      the default 0 (false) the previous contents |
//|                      are over written with the new data.         |
//|             iStart - First row to be written to the file, the    |
//|                      default is row 0.                           |
//|             iCount - Number of rows to be written to the file,   |
//|                      the  default is all rows.                   |
//| Purpose...: Write a two dimensional array to a CSV file for      |
//|             viewing with a text editor or further manipulations  |
//|             using a spreadsheet. Usefull for debugging.          |
//| Returns...: Number of rows written, or a negative value if an    |
//|             error occurs.                                        |
//| Example...:                                                      |
//+------------------------------------------------------------------+
int Array2IntWrite(int A[][], string sFile = "My.CSV", bool bAdd = false, int iStart = 0, int iCount = WHOLE_ARRAY) {
  int iRows = ArrayRange(A, 0), iCols, handle, iRowsWritten, iRow, iCol;

  if(iRows == 0) return(0);  
  iCols = ArraySize(A) / iRows;
  if(iCount == WHOLE_ARRAY) iCount = iRows; 
  else                      iCount = iStart + iCount - 1;
  if(!bAdd) handle = FileOpen(sFile, FILE_CSV|FILE_WRITE, ',');
  else      handle = FileOpen(sFile, FILE_CSV|FILE_READ|FILE_WRITE, ',');
  if(handle < 1) return(ERROR); 
  if(bAdd) {
    FileSeek(handle, 0, SEEK_END);
    FileWrite(handle, "***** ", TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS), " *****");
  }
  string sColSeperator = ",";
  for(iRow = iStart; iRow < iCount; iRow++) {
    for(iCol = 0; iCol < iCols-1; iCol++) {
      FileWrite(handle, A[iRow][iCol], sColSeperator);
      FileSeek(handle, -3, SEEK_END);
    } 
    FileWrite(handle, A[iRow][iCol]);
    iRowsWritten++;
  }
  FileClose(handle);
  return(iRowsWritten);
}

//+------------------------------------------------------------------+
//| Function..: StringToArray                                        |
//| Parameters: sData      - Text string with data seperated by the  |
//|                          delimiter <sDelimiter>.                 |
//|             sArray     - name of the array passed by reference.  |
//|             sDelimiter - the delimiter used to seperate the      |
//|                          fields of the array, the default is ",".|
//| Purpose...: Transform a text string into an array.               |
//| Returns...: The number of data elements contained in <sData> or  |
//|             -1 if an error was encountered which can be examined |
//|             using GetLastError().                                |
//| Notes.....: Usefull for getting information that was stored in   |
//|             OrderComment().                                      | 
//| Sample....: string sTxt[]; // or sTxt[4] if total elements known |
//|             int iElements=StringToArray("012,111,204,373",sTxt); |
//|             for(int i=0; i<iElements; i++) {                     |
//|               Print(sTxt[i]);                                    |
//|             }                                                    |
//+------------------------------------------------------------------+
int StringToArray(string sData, string& sArray[], string sDelimiter=",") {
  int iEnd=-2, iCnt, i, iStart;
  
  if(StringLen(sData)==0) return(0);
  while(iEnd != -1) {
    iEnd=StringFind(sData,sDelimiter,iStart);
    iCnt++;
    iStart=iEnd+1;
  }
  if((iCnt>ArraySize(sArray)) && (ArrayResize(sArray,iCnt)==-1)) return(ERROR);
  iStart=0;
  for(i=0; i<iCnt-1; i++) {
    iEnd=StringFind(sData,sDelimiter,iStart);
    sArray[i]=StringSubstr(sData,iStart,iEnd-iStart);
    iStart=iEnd+1;
  }
  sArray[iCnt-1]=StringSubstr(sData,iStart);
  return(iCnt);
}

//+------------------------------------------------------------------+
//| Function..: StringToColor()                                      |
//| Parameter.: sColor - string to be passed.                        |
//+------------------------------------------------------------------+
color StringToColor(string sColor) {
  color acColor[133]={Black,DarkGreen,DarkSlateGray,Olive,Green,Teal,Navy,Purple,
                      Maroon,Indigo,MidnightBlue,DarkBlue,DarkOliveGreen,SaddleBrown,
                      ForestGreen,OliveDrab,SeaGreen,DarkGoldenrod,DarkSlateBlue,
                      Sienna,MediumBlue,Brown,DarkTurquoise,DimGray,LightSeaGreen,
                      DarkViolet,FireBrick,MediumVioletRed,MediumSeaGreen,Chocolate,
                      Crimson,SteelBlue,Goldenrod,MediumSpringGreen,LawnGreen,CadetBlue,
                      DarkOrchid,YellowGreen,LimeGreen,OrangeRed,DarkOrange,Orange,Gold,
                      Yellow,Chartreuse,Lime,SpringGreen,Aqua,DeepSkyBlue,Blue,Magenta,
                      Red,Gray,SlateGray,Peru,BlueViolet,LightSlateGray,DeepPink,
                      MediumTurquoise,DodgerBlue,Turquoise,RoyalBlue,SlateBlue,DarkKhaki,
                      IndianRed,MediumOrchid,GreenYellow,MediumAquamarine,DarkSeaGreen,
                      Tomato,RosyBrown,Orchid,MediumPurple,PaleVioletRed,Coral,CornflowerBlue,
                      DarkGray,SandyBrown,MediumSlateBlue,Tan,DarkSalmon,BurlyWood,HotPink,
                      Salmon,Violet,LightCoral,SkyBlue,LightSalmon,Plum,Khaki,LightGreen,
                      Aquamarine,Silver,LightSkyBlue,LightSteelBlue,LightBlue,PaleGreen,
                      Thistle,PowderBlue,PaleGoldenrod,PaleTurquoise,LightGray,Wheat,
                      NavajoWhite,Moccasin,LightPink,Gainsboro,PeachPuff,Pink,Bisque,
                      LightGoldenrod,BlanchedAlmond,LemonChiffon,Beige,AntiqueWhite,
                      PapayaWhip,Cornsilk,LightYellow,LightCyan,Linen,Lavender,MistyRose,
                      OldLace,WhiteSmoke,Seashell,Ivory,Honeydew,AliceBlue,LavenderBlush,
                      MintCream,Snow,White,CLR_NONE 
                     };
  string asColor[133]={"BLACK","DARKGREEN","DARKSLATEGRAY","OLIVE","GREEN","TEAL","NAVY","PURPLE",
                      "MAROON","INDIGO","MIDNIGHTBLUE","DARKBLUE","DARKOLIVEGREEN","SADDLEBROWN",
                      "FORESTGREEN","OLIVEDRAB","SEAGREEN","DARKGOLDENROD","DARKSLATEBLUE",
                      "SIENNA","MEDIUMBLUE","BROWN","DARKTURQUOISE","DIMGRAY","LIGHTSEAGREEN",
                      "DARKVIOLET","FIREBRICK","MEDIUMVIOLETRED","MEDIUMSEAGREEN","CHOCOLATE",
                      "CRIMSON","STEELBLUE","GOLDENROD","MEDIUMSPRINGGREEN","LAWNGREEN","CADETBLUE",
                      "DARKORCHID","YELLOWGREEN","LIMEGREEN","ORANGERED","DARKORANGE","ORANGE","GOLD",
                      "YELLOW","CHARTREUSE","LIME","SPRINGGREEN","AQUA","DEEPSKYBLUE","BLUE","MAGENTA",
                      "RED","GRAY","SLATEGRAY","PERU","BLUEVIOLET","LIGHTSLATEGRAY","DEEPPINK",
                      "MEDIUMTURQUOISE","DODGERBLUE","TURQUOISE","ROYALBLUE","SLATEBLUE","DARKKHAKI",
                      "INDIANRED","MEDIUMORCHID","GREENYELLOW","MEDIUMAQUAMARINE","DARKSEAGREEN",
                      "TOMATO","ROSYBROWN","ORCHID","MEDIUMPURPLE","PALEVIOLETRED","CORAL","CORNFLOWERBLUE",
                      "DARKGRAY","SANDYBROWN","MEDIUMSLATEBLUE","TAN","DARKSALMON","BURLYWOOD","HOTPINK",
                      "SALMON","VIOLET","LIGHTCORAL","SKYBLUE","LIGHTSALMON","PLUM","KHAKI","LIGHTGREEN",
                      "AQUAMARINE","SILVER","LIGHTSKYBLUE","LIGHTSTEELBLUE","LIGHTBLUE","PALEGREEN",
                      "THISTLE","POWDERBLUE","PALEGOLDENROD","PALETURQUOISE","LIGHTGRAY","WHEAT",
                      "NAVAJOWHITE","MOCCASIN","LIGHTPINK","GAINSBORO","PEACHPUFF","PINK","BISQUE",
                      "LIGHTGOLDENROD","BLANCHEDALMOND","LEMONCHIFFON","BEIGE","ANTIQUEWHITE",
                      "PAPAYAWHIP","CORNSILK","LIGHTYELLOW","LIGHTCYAN","LINEN","LAVENDER","MISTYROSE",
                      "OLDLACE","WHITESMOKE","SEASHELL","IVORY","HONEYDEW","ALICEBLUE","LAVENDERBLUSH",
                      "MINTCREAM","SNOW","WHITE","CLR_NONE" 
                     };
  sColor=StringChangeToUpperCase(sColor);
  for(int i=0; i<133; i++) {
    if(asColor[i]==sColor) return(acColor[i]);
  }
  return(CLR_NONE);                     
}

//+------------------------------------------------------------------+
//| Function..: StringChangeToUpperCase                              |
//| Example...: StringChangeToUpperCase("oNe mAn"); // ONE MAN       |
//+------------------------------------------------------------------+
string StringChangeToUpperCase(string sText) {
  int iLen=StringLen(sText), i, iChar;

  for(i=0; i < iLen; i++) {
    iChar=StringGetChar(sText, i);
    if(iChar >= 97 && iChar <= 122) sText=StringSetChar(sText, i, iChar-32);
  }
  return(sText);
}

//+------------------------------------------------------------------+
//| Function..: StringCell                                           |
//| Example...: StringCell("1,2,3,4",2); // "3"                      |
//+------------------------------------------------------------------+
string StringCell(string sData, int iCell, string sDelimiter=",") {
  int iEnd=-2, iCnt, i, iStart;
  
  if(StringLen(sData)==0) return("");
  while(iEnd != -1) {
    iEnd=StringFind(sData,sDelimiter,iStart);
    if(iCell==iCnt) return(StringSubstr(sData,iStart,iEnd-iStart));
    iCnt++;
    iStart=iEnd+1;
  }
  return("");
}

//+------------------------------------------------------------------+
//| Function..: StringCells                                          |
//| Example...: StringCells("1,2,3,4"); // 4                         |
//+------------------------------------------------------------------+
int StringCells(string sData, string sDelimiter=",") {
  int iEnd=-2, iCnt, i, iStart;
  
  if(StringLen(sData)==0) return(0);
  while(iEnd != -1) {
    iEnd=StringFind(sData,sDelimiter,iStart);
    iCnt++;
    iStart=iEnd+1;
  }
  return(iCnt);
}

//+------------------------------------------------------------------+
//| Function..: StringTransform                                      |
//| Purpose...: Transform a matched string in text with a new string.|
//| Example...: StringTransform("oNe mAn"," ",""); // oNemAn         |
//+------------------------------------------------------------------+
string StringTransform(string sText, string sFind=" ", string sReplace="") {
  int    iLenText=StringLen(sText), iLenFind=StringLen(sFind), i;
  string sReturn="";
  
  for(i=0; i<iLenText; i++) {
    if(StringSubstr(sText,i,iLenFind)==sFind) {
      sReturn=sReturn+sReplace;
      i=i+iLenFind-1;
    }
    else sReturn=sReturn+StringSubstr(sText,i,1);
  }
  return(sReturn);
}
//+------------------------------------------------------------------+

