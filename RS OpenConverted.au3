#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=RS OpenConverted.ico
#AutoIt3Wrapper_Outfile=RS OpenConverted.exe
#AutoIt3Wrapper_Outfile_x64=RS OpenConverted64.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Open files with previous conversion.
#AutoIt3Wrapper_Res_Description=Open files with previous conversion.
#AutoIt3Wrapper_Res_Fileversion=1.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=RS OpenConverted
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=Ruling Solutions
#AutoIt3Wrapper_Res_LegalCopyright=© 2022, Ruling Solutions
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt('MustDeclareVars', 1)

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include '..\Shared\RS.au3'
#include '..\Shared\RS_INI.au3'

; Constants and variables
Local Const $AppPath = RS_addSlash(@ScriptDir)
Local Const $AppName = RS_removeExt(@ScriptName)
Local Const $INIFile = $AppPath & $AppName & '.ini'

Local $boolConvert = 0
Local $boolVerbose
Local $strLNGFile
Local $strCommand
Local $strConverterEXE
Local $strConverterCmd
Local $strConverterInput
Local $strConverterOutput
Local $strToolEXE
Local $strToolCmd
Local $strInputFile1
Local $strInputFile2
Local $strOutputFile1
Local $strOutputFile2
Local $strOutputDir

; Check INI file
If FileExists($INIFile) Then
  $strLNGFile = RS_removeExt(INI_valueLoad($INIFile, 'General', 'Language', 'English', False)) & '.lng'
  $boolVerbose = INI_valueLoad($INIFile, 'General', 'Verbose', '0')
  $strConverterEXE = INI_valueLoad($INIFile, 'Converter', 'EXE', '', False)
  $strConverterCmd = INI_valueLoad($INIFile, 'Converter', 'Command', '')
  $strConverterInput = INI_valueLoad($INIFile, 'Converter', 'Input', 'svg, svgz')
  $strConverterOutput = INI_valueLoad($INIFile, 'Converter', 'Output', 'png')
  $strToolEXE = INI_valueLoad($INIFile, 'Tool', 'EXE', '', False)
  $strToolCmd = INI_valueLoad($INIFile, 'Tool', 'Command', '')
Else
  $strLNGFile = INI_valueWrite($INIFile, 'General', 'Language', 'English', False) & '.lng'
  $boolVerbose = INI_valueWrite($INIFile, 'General', 'Verbose', '0')
  $strConverterEXE = INI_valueWrite($INIFile, 'Converter', 'EXE', '', False)
  $strConverterCmd = INI_valueWrite($INIFile, 'Converter', 'Command', '')
  $strConverterInput = INI_valueWrite($INIFile, 'Converter', 'Input', 'svg, svgz')
  $strConverterOutput = INI_valueWrite($INIFile, 'Converter', 'Output', 'png')
  $strToolEXE = INI_valueWrite($INIFile, 'Tool', 'EXE', '', False)
  $strToolCmd = INI_valueWrite($INIFile, 'Tool', 'Command', '')
EndIf
$boolVerbose = RS_intBoolean($boolVerbose)

; Check language file
$strLNGFile = RS_addDir($strLNGFile, $AppPath)
If Not FileExists($strLNGFile) Then
  $strLNGFile = $AppPath & 'English.lng'
  INI_valueWrite($strLNGFile, 'Error', '001', 'Error')
  INI_valueWrite($strLNGFile, 'Error', '002', 'Required programs not found.')
  INI_valueWrite($strLNGFile, 'Error', '003', 'Missing input file.')
  INI_valueWrite($strLNGFile, 'Error', '004', 'Input file %1 not found.')
  INI_valueWrite($strLNGFile, 'Error', '005', 'Error deleting converted file %1.')
EndIf

; Check options
Local $strOption = RS_cmdOption('-c')
If StringLen($strOption) > 0 Then $strConverterEXE = $strOption
$strOption = RS_cmdOption('-cc')
If StringLen($strOption) > 0 Then $strConverterCmd = $strOption
$strOption = RS_cmdOption('-t')
If StringLen($strOption) > 0 Then $strToolEXE = $strOption
$strOption = RS_cmdOption('-tc')
If StringLen($strOption) > 0 Then $strToolCmd = $strOption

RS_addDir($strConverterEXE, $AppPath)
RS_addDir($strToolEXE, $AppPath)
If RS_cmdOption('-i', True) Then $strConverterInput = RS_cmdOption('-i')
If RS_cmdOption('-o', True) Then $strConverterOutput = RS_cmdOption('-o')
If RS_cmdOption('-v', True) Then $boolVerbose = RS_cmdOption('-v', True)

$strConverterInput = StringLower(StringReplace($strConverterInput, '.', ''))
$strConverterInput = StringReplace($strConverterInput, ', ', ',')
$strConverterOutput = StringLower(RS_trim($strConverterOutput, '.'))

; Check tools
If Not FileExists($strConverterEXE) or Not FileExists($strToolEXE) Then
  If $boolVerbose Then MsgBox(16, INI_valueLoad($strLNGFile, 'Error', '001', 'Error'), INI_valueLoad($strLNGFile, 'Error', '002', 'Required programs not found.'), 3)
  Exit(1)
EndIf

; Get source filenames
Local $strFiles = RS_cmdLines()
If $strFiles[0] < 2 Then
  If $boolVerbose Then MsgBox(16, INI_valueLoad($strLNGFile, 'Error', '001', 'Error'), INI_valueLoad($strLNGFile, 'Error', '003', 'Missing input file.'), 3)
  Exit(2)
EndIf
$strInputFile1 = $strFiles[1]
$strInputFile2 = $strFiles[2]

; Create converted filenames
If StringLen($strConverterOutput) = 0 Then $strConverterOutput = 'png'
$strOutputDir = RS_addSlash(RS_removeExt(_TempFile()))
$strOutputFile1 = $strOutputDir & '1\' & RS_fileNameInfo($strInputFile1, 1) & '.' & $strConverterOutput
$strOutputFile2 = $strOutputDir & '2\' & RS_fileNameInfo($strInputFile2, 1) & '.' & $strConverterOutput

; Check files
If Not FileExists(RS_trim(RS_trim($strInputFile1, '"'), "'")) Then
  If $boolVerbose Then
    MsgBox(16, INI_valueLoad($strLNGFile, 'Error', '001', 'Error'), StringReplace(INI_valueLoad($strLNGFile, 'Error', '004', 'Input file %1 not found.'), '%1', $strInputFile1), 3)
  EndIf
  Exit(3)
ElseIf Not FileExists(RS_trim(RS_trim($strInputFile2, '"'), "'")) Then
  If $boolVerbose Then
    MsgBox(16, INI_valueLoad($strLNGFile, 'Error', '001', 'Error'), StringReplace(INI_valueLoad($strLNGFile, 'Error', '004', 'Input file %1 not found.'), '%1', $strInputFile2), 3)
  EndIf
  Exit(3)
EndIf
$strInputFile1 = RS_quote($strInputFile1)
$strInputFile2 = RS_quote($strInputFile2)

; Check if source files extensions are listed in conversion list
For $strInputExtension In StringSplit($strConverterInput, ',', 2)
  If RS_fileNameInfo($strInputFile1, 2) = '.' & $strInputExtension Then
    $boolConvert = BitOR($boolConvert, 1)
  EndIf
  If RS_fileNameInfo($strInputFile2, 2) = '.' & $strInputExtension Then
    $boolConvert = BitOR($boolConvert, 2)
  EndIf
Next

; Execute converter if source files extension are in conversion list
If $boolConvert = 0 Then
  $strOutputFile1 = $strInputFile1
  $strOutputFile2 = $strInputFile2
Else
  DirCreate($strOutputDir)
  DirCreate($strOutputDir & '1')
  DirCreate($strOutputDir & '2')
  $strConverterCmd = StringReplace($strConverterCmd, '%Converted_Format%', $strConverterOutput)
  If BitAND($boolConvert, 1) Then
    $strCommand = StringReplace($strConverterCmd, '%Source_File%', $strInputFile1)
    $strCommand = StringReplace($strCommand, '%Converted_File%', $strOutputFile1)
    RS_run($strConverterEXE & ' ' & $strCommand)
  EndIf
  If BitAND($boolConvert, 2) Then
    $strCommand = StringReplace($strConverterCmd, '%Source_File%', $strInputFile2)
    $strCommand = StringReplace($strCommand, '%Converted_File%', $strOutputFile2)
    RS_run($strConverterEXE & ' ' & $strCommand)
  EndIf
EndIf

; Execute main tool
$strCommand = StringReplace($strToolCmd, '%File1%', $strOutputFile1)
$strCommand = StringReplace($strCommand, '%File2%', $strOutputFile2)
$strCommand = StringReplace($strCommand, '%Name1%', $strInputFile1)
$strCommand = StringReplace($strCommand, '%Name2%', $strInputFile2)
RS_run($strToolEXE & ' ' & $strCommand)

; Delete temporal folders and files
If BitAND($boolConvert, 1) Then _deleteFile($strOutputFile1)
If BitAND($boolConvert, 2) Then _deleteFile($strOutputFile2)
DirRemove($strOutputDir, 1)
Exit(0)

; Delete temporal files
Func _deleteFile($pFile)
  If FileExists($pFile) Then
    If FileDelete(RS_trim(RS_trim($pFile, '"'), "'")) = 0 Then
      If $boolVerbose Then
        MsgBox(16, INI_valueLoad($strLNGFile, 'Error', '001', 'Error'), StringReplace(INI_valueLoad($strLNGFile, 'Error', '005', 'Error deleting converted file %1.'), '%1', $pFile), 3)
      EndIf
      Exit(4)
    EndIf
  EndIf
EndFunc