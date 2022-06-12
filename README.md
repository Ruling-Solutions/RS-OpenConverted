# RS OpenConverted
## Description
RS OpenConverted allow to open files with previous conversion. Can be used to call a file compare tool to compare not supported files, applying a conversion of the unsopported files to a valid format and then call the main tool to compare them.
## Before use
* Modify in RS OpenConverted.ini or RS OpenConverted64.ini:
* Converter program path, command, input formats and output format.
* Main tool program path and command to open converted files.
## Usage
``` batch
RS OpenConverted.exe %file1% %file2%
```
## Remarks
RS OpenConverted will apply conversion only to files with extensions defined in configuration file.
