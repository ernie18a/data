//+------------------------------------------------------------------+
//|                                                   FileReader.mqh |
//|                               Copyright (c) 2019-2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|                            https://www.mql5.com/ru/articles/5638 |
//|                                                   rev.2020.02.17 |
//+------------------------------------------------------------------+

#include "RubbArray.mqh"
#include "HashMapTemplate.mqh"

#ifndef CLEAR
  #define CLEAR(P) if(CheckPointer(P) == POINTER_DYNAMIC) delete P;
#endif

#define SOURCE_LENGTH 100000

#ifdef __MQL5__
  #define MQL_VER "5"
#else
  #define MQL_VER "4"
#endif

class Source
{
  private:
    string source;
    Map<uint,string> files;

  public:
    Source(const uint length = SOURCE_LENGTH)
    {
      StringInit(source, length);
    }

    Source *operator+=(const string &x)
    {
      source += x;
      return &this;
    }

    Source *operator+=(const ushort x)
    {
      source += ShortToString(x);
      return &this;
    }
    
    ushort operator[](uint i) const
    {
      return source[i];
    }
    
    string get(uint start = 0, uint length = -1) const
    {
      return StringSubstr(source, start, length);
    }
    
    uint length() const
    {
      return StringLen(source);
    }
    
    void mark(const uint offset, const string file)
    {
      files.put(offset, file);
    }
    
    string filename(const uint offset, uint &filestart, uint &line) const
    {
      if(files.getSize() == 1)
      {
        filestart = 0;
        return files[0];
      }
      for(int i = files.getSize() - 1; i >= 0; i--)
      {
        filestart = files.getKey(i);
        if(offset >= filestart)
        {
          line = 1;
          for(uint j = filestart; j < offset; j++)
          {
            if(source[j] == '\n') line++;
          }
          
          for(int k = i - 2; k >= 0; k--)
          {
            if(files[k] == files[i])
            {
              filestart -= files.getKey(k + 1) - files.getKey(k);
              for(uint j = files.getKey(k); j < files.getKey(k + 1); j++)
              {
                if(source[j] == '\n') line++;
              }
            }
          }
          
          return files[i];
        }
      }
      return NULL;
    }
    
    void printFiles() const
    {
      for(int i = 0; i < files.getSize(); i++)
      {
        Print(files[i], " ", files.getKey(i));
      }
    }
    
    uint size() const
    {
      return (uint)files.getSize();
    }
    
    string file(const uint n) const
    {
      if(n >= (uint)files.getSize()) return NULL;
      return files[(int)n];
    }
    
    void dump(const string filename) const
    {
      int h = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_UNICODE, 0, CP_UTF8);
      FileWriteString(h, source);
      FileClose(h);
    }
};


class FileReader
{
  protected:
    const string filename;
    int handle;
    string line;
    int linenumber;
    int cursor;
    Source *text;
    bool unicode;
    
  public:
    FileReader(const string _filename, Source *container = NULL,
      const int flags = FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE,
      const uint codepage = CP_UTF8): filename(_filename)
    {
      handle = FileOpen(filename, flags, 0, codepage);
      if(handle == INVALID_HANDLE)
      {
        Print("FileOpen failed ", filename, " ", GetLastError());
      }
      line = NULL;
      cursor = 0;
      linenumber = 0;
      text = container;
      unicode = false;
    }
    
    string pathname() const
    {
      return filename;
    }
    
    bool scanLine()
    {
      if(!FileIsEnding(handle))
      {
        line = FileReadString(handle);
        linenumber++;
        cursor = 0;
        if(text != NULL)
        {
          text += line;
          text += '\n';
        }
        return true;
      }
      
      return false;
    }

    ushort getChar(const bool autonextline = true)
    {
      if(cursor >= StringLen(line))
      {
        if(autonextline)
        {
          if(!scanLine()) return 0;
          cursor = 0;
        }
        else
        {
          return 0;
        }
      }
      const ushort c = StringGetCharacter(line, cursor++);
      #ifdef UNICODE_WARNING
      if(c > 128)
      {
        if(!unicode) // show first wide character in each file
        {
          Print("UNICODE: ", filename, " ", linenumber, " ", cursor - 1, "\n", line, " ", c, " (", StringFormat("%c", c), ")");
          unicode = true;
        }
      }
      #endif
      return c;
    }
    
    bool probe(const string lexeme) const
    {
      return StringFind(line, lexeme, cursor) == cursor;
    }

    bool match(const string lexeme) const
    {
      ushort c = StringGetCharacter(line, cursor + StringLen(lexeme));
      return probe(lexeme) && (c == ' ' || c == '\t' || c == 0);
    }
    
    bool consume(const string lexeme)
    {
      if(match(lexeme))
      {
        advance(StringLen(lexeme));
        return true;
      }
      return false;
    }
    
    void advance(const int next)
    {
      cursor += next;
      if(cursor > StringLen(line))
      {
        error(StringFormat("line is out of bounds [%d+%d]", cursor, next));
      }
    }
    
    void error(const string message)
    {
      Print(filename, "::", linenumber, ": ", line);
      if(message != NULL) Print("Error: ", message);
    }
    
    string source() const
    {
      return line;
    }
    
    int column() const
    {
      return cursor;
    }
    
    int lineNumber() const
    {
      return linenumber;
    }
    
    bool isEOF()
    {
      return FileIsEnding(handle) && cursor >= StringLen(line);
    }
    
    bool isOK()
    {
      return (handle > 0);
    }
    
    ~FileReader()
    {
      FileClose(handle);
    }
};


class FileReaderController
{
  protected:
    Stack<FileReader *> includes;
    Map<string, FileReader *> files;
    FileReader *current;
    const int flags;
    const uint codepage;
    
    ushort lastChar;
    Source *source;
    
  public:
    FileReaderController(const int _flags = FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE,
      const uint _codepage = CP_UTF8, const uint _length = SOURCE_LENGTH): flags(_flags), codepage(_codepage)
    {
      current = NULL;
      lastChar = 0;
      source = new Source(_length);
    }
    
    ushort getLastChar() const
    {
      return lastChar;
    }
    
    ushort getChar(const bool autonextline = true)
    {
      if(current == NULL) return 0;
      
      if(!current.isEOF())
      {
        lastChar = current.getChar(autonextline);
        return lastChar;
      }
      else
      {
        while(includes.size() > 0)
        {
          current = includes.pop();
          source.mark(source.length(), current.pathname());

          if(!current.isEOF())
          {
            if(autonextline)
            {
              lastChar = current.getChar();
              return lastChar;
            }
            else
            {
              return 0;
            }
          }
        }
      }
      return 0;
    }
    
    const Source *text() const
    {
      return source;
    }
    
    FileReader *reader()
    {
      return current;
    }
    
    int level() const
    {
      return includes.size();
    }
    
    bool include(const string _filename, const bool load = true)
    {
      string margin;
      StringInit(margin, level() * 2, ' ');

      Print(margin + (current != NULL ? "Including " : "Processing "), _filename);
      
      if(files.containsKey(_filename)) return true;
      
      if(load)
      {
        if(current != NULL)
        {
          includes.push(current);
        }
        
        current = new FileReader(_filename, source, flags, codepage);
        source.mark(source.length(), current.pathname());
      }
      
      files.put(_filename, current);
      
      return current.isOK();
    }
    
    bool isAtEnd()
    {
      return current == NULL || (current.isEOF() && includes.size() == 0);
    }
    
    int total() const
    {
      return files.getSize();
    }
    
    string getFilename(const int i) const
    {
      return files.getKey(i);
    }
    
    ~FileReaderController()
    {
      for(int i = 0; i < files.getSize(); i++)
      {
        CLEAR(files[i]);
      }
      delete source;
    }
};


class Preprocessor
{
  protected:
    FileReaderController *controller;
    const string includes;
    
    int blockcomments;
    int linecomments;
    
    bool loadIncludes;
    
  
  public:
    Preprocessor(const string _filename, const string _includes, const bool _loadIncludes = false, const int _flags = FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE, const uint _codepage = CP_UTF8, const uint _length = SOURCE_LENGTH): includes(_includes)
    {
      controller = new FileReaderController(_flags, _codepage, _length);
      controller.include(_filename);
      blockcomments = 0;
      linecomments = 0;
      loadIncludes = _loadIncludes;
    }
    
    ~Preprocessor()
    {
      CLEAR(controller);
    }
    
    int lineComments() const
    {
      return linecomments;
    }

    int blockComments() const
    {
      return blockcomments;
    }

    const Source *text() const
    {
      return controller.text();
    }

    bool run(const ushort terminal = 0) // until terminal, 0 means end of input
    {
      while(!isAtEnd())
      {
        if(!scanLexeme(terminal)) return false;
        if(terminal != 0 && terminal == controller.getLastChar()) return true;
      }
      return true;
    }

    uint scannedFilesCount() const
    {
      return controller.total();
    }
    
    string scannedFilename(const int i) const
    {
      return controller.getFilename(i);
    }
    
    uint totalCharactersCount() const
    {
      return controller.text().length();
    }
    

  protected:    
    bool isAtEnd()
    {
      return controller.isAtEnd();
    }
    
    bool scanLexeme(const ushort terminal = 0)
    {
      ushort c = controller.getChar();
      
      if(terminal != 0 && c == terminal)
      {
        return true;
      }
      
      int startline = controller.reader().lineNumber();
      
      switch(c)
      {
        case '#':
          if(controller.reader().consume("include"))
          {
            if(!include())
            {
              controller.reader().error("bad include");
              return false;
            }
          }
          else if(controller.reader().consume("property"))
          {
            ushort _c = skipWhitespace();
            if(_c == 'i' && controller.reader().consume("con"))
            {
              if(!include(false))
              {
                controller.reader().error("bad property icon");
                return false;
              }
            }
          }
          else if(controller.reader().consume("resource"))
          {
            if(!include(false))
            {
              controller.reader().error("bad resource");
              return false;
            }
          }

          break;
        case '/':
          if(controller.reader().probe("*"))
          {
            controller.reader().advance(1);
            if(!blockcomment())
            {
              controller.reader().error("bad block comment, started at line " + (string)startline);
              return false;
            }
          }
          else
          if(controller.reader().probe("/"))
          {
            controller.reader().advance(1);
            linecomment();
          }
          break;
        case '"':
        case '\'':
          if(!literal(c))
          {
            controller.reader().error("unterminated string, started at line " + (string)startline);
            return false;
          }
          break;
      }
      
      return true; // symbol consumed
    }
    
    bool literal(const ushort type)
    {
      ushort c = 0, c_;
      
      do
      {
        c_ = c;
        c = controller.getChar();
        if(c == type && c_ != '\\') return true;
        if(c == '\\' && c_ == '\\') c = '/';
      }
      while(!controller.reader().isEOF());
      
      return false;
    }
    
    bool blockcomment()
    {
      blockcomments++;
      
      ushort c = 0, c_;
      
      do
      {
        c_ = c;
        c = controller.getChar();
        if(c == '/' && c_ == '*') return true;
      }
      while(!controller.reader().isEOF()); // c != 0 - can be on empty line
      
      return false;
    }

    void linecomment()
    {
      linecomments++;
      
      ushort c;
      do
      {
        c = controller.getChar(false);
      }
      while(c != 0);
    }
    
    ushort skipWhitespace()
    {
      ushort c;
      do
      {
        c = controller.getChar();
      }
      while(c == ' ' || c == '\t' || c == 0);
      return c;
    }
    
    bool include(const bool load = true)
    {
      ushort c = skipWhitespace();
      
      if(c == '"' || c == '<')
      {
        ushort q = c;
        if(q == '<') q = '>';
        
        int start = controller.reader().column();
        
        do
        {
          c = controller.getChar();
        }
        while(c != q && c != 0);
        
        if(c == q)
        {
          if(loadIncludes)
          {
            string margin;
            StringInit(margin, controller.level() * 2, ' ');
            Print(margin + controller.reader().source());

            int stop = controller.reader().column();
  
            string name = StringSubstr(controller.reader().source(), start, stop - start - 1);
            StringReplace(name, "\\", "/");
            StringReplace(name, "//", "/");
            string path = "";
  
            if(q == '"')
            {
              path = controller.reader().pathname();
            }
            else // '<' '>'
            {
              path = includes; // folder;
            }
            
            StringReplace(path, "\\", "/");
            string parts[];
            int n = StringSplit(path, '/', parts);
            if(n > 0)
            {
              ArrayResize(parts, n - 1); // remove name or trailing slash
            }
            else
            {
              Print("Path is empty: ", path);
              return false;
            }

            int upfolder = 0;
            while(StringFind(name, "../") == 0)
            {
              name = StringSubstr(name, 3);
              upfolder++;
            }
            
            if(upfolder > 0)
            {
              if(upfolder <= ArraySize(parts))
              {
                ArrayResize(parts, ArraySize(parts) - upfolder);
              }
              else
              {
                Print("Too many (", upfolder, ") upfolder jumps (..) for ", path);
              }
            }
            
            if(resource(name))
            {
              path = "";
            }
            else
            {
              path = stringImplodeExt(parts, "/", true);
            }

            bool implicit = false;
            if(stringEndsWith(name, ".ex" + MQL_VER))
            {
              StringReplace(name, ".ex" + MQL_VER, ".mq" + MQL_VER);
              implicit = true;
            }
            
            return controller.include(path + name, load || implicit);
          }
          else
          {
            return true;
          }
        }
        else
        {
          Print("Incomplete include");
        }
      }
      return false;
    }
    
    bool resource(string &name)
    {
      const string defaultDirs[] = {"/files/", "/images/", "/sounds/", "/indicators/"};

      string lower = name;
      StringToLower(lower);
      
      string srcroot = includes;
      StringToLower(srcroot);
      int p = StringFind(srcroot, "/include/");
      srcroot = StringSubstr(includes, 0, p);
      
      for(int i = 0; i < ArraySize(defaultDirs); i++)
      {
        if(StringFind(lower, defaultDirs[i]) == 0)
        {
          name = srcroot + name;
          return true;
        }
      }
      
      return false;
    }
  
  public:  
    static string stringImplodeExt(string &lines[], const string delimiter = "", const bool addTrailingDelimiter = false)
    {
      int i, n;
      n = ArraySize(lines);
      string result = "";
      for(i = 0; i < n; i++)
      {
        if(StringLen(lines[i]) > 0)
        {
          if(result != "")
          {
            result = result + delimiter + lines[i];
          }
          else
          {
            result = lines[i];
          }
        }
      }
      if(addTrailingDelimiter && StringLen(result) > 0) result += delimiter;
      return(result);
    }

    static bool stringEndsWith(const string text, const string suffix)
    {
      return StringFind(text, suffix) == StringLen(text) - StringLen(suffix);
    }
};
