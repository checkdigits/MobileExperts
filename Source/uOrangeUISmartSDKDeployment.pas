﻿unit uOrangeUISmartSDKDeployment;

interface

uses
  {$IFDEF MSWINDOWS}
    ShlwApi,
    ShellAPI,
    ActiveX,
    Winapi.Windows,
    System.Win.Registry,
  {$ENDIF MSWINDOWS}

  System.SysUtils,
  System.Variants,
  XMLDoc,
  XMLIntf,
  uBaseList_Copy,
  uBaseLog_Copy,
  uLang_Copy,
  uFuncCommon_Copy,
  IniFiles,
  Math,
  StrUtils,
  FMX.Forms,
  FMX.Dialogs,
  XSuperObject_Copy,
  uCommandLineHelper,
  System.Classes;

const
  CONST_JAR_TEMP_DIR            = 'OrangeSDK_JarGen';
  Const_OrangeSDKConfig_FileExt = '.OrangeSDKConfig';

type
  TDeployConfigLogEvent = procedure(Sender: TObject; const ALog: String) of object;

  TDeployFilePlatform = class
    public
      Platform_:  String;
      RemoteDir:  String;
      RemoteName: String;
      Overwrite:  String;
      Enabled:    String;
  end;

  TDeployFilePlatformList = class(TBaseList)
    private
      function GetItem(Index: Integer): TDeployFilePlatform;
    public
      function FindItemByPlatform(APlatform: String): TDeployFilePlatform;
      property Items[Index: Integer]: TDeployFilePlatform read GetItem; default;
  end;

  TDeployFile = class
    public
      LocalName:     String;
      Class_:        String;
      Configuration: String;
      Platforms:     TDeployFilePlatformList;
    public
      constructor Create;
      destructor Destroy; override;
    public
      function PlatformsCommaText: String;
      function FindPlatform(APlatform: String): TDeployFilePlatform;
  end;

  TDeployFileList = class(TBaseList)
    private
      function GetItem(Index: Integer): TDeployFile;
    public
      property Items[Index: Integer]: TDeployFile read GetItem; default;
    public
      function FindItemByLocalName(ALocalName: String): TDeployFile;
      function FindItemByRemoteName(ARemotePath: String; APlatform: String)
        : TDeployFile;
  end;

  TDeployConfig = class
    public
      Platform_: String;
      LocalDir:  String;
      RemoteDir: String;
    public
      LocalFiles:  TStringList;
      RemoteFiles: TStringList;
      constructor Create;
      destructor Destroy; override;
    public
      procedure LoadFileList(AProjectDir: String);
  end;

  TDeployConfigList = class(TBaseList)
    private
      function GetItem(Index: Integer): TDeployConfig;
    public
      property Items[Index: Integer]: TDeployConfig read GetItem; default;
    public
      FPreviewDeployFileList: TDeployFileList;
      function GeneratePreviewDeployFileList(AProjectPath: String): Boolean;
    public
      constructor Create(
        const AObjectOwnership: TObjectOwnership = ooOwned;
        const AIsCreateObjectChangeManager: Boolean = True
        ); override;
      destructor Destroy; override;
  end;

  TConfigVariable = class
    public
      Name:  String;
      Value: String;
      Desc:  String;
  end;

  TConfigVariableList = class(TBaseList)
    private
      function GetItem(Index: Integer): TConfigVariable;
    public
      property Items[Index: Integer]: TConfigVariable read GetItem; default;
      function FindItemByName(AName: String): TConfigVariable;
  end;

  TProjectConfig = class
    public
      FLastProjectFilePath:   String;
      FCurrentDeployFileList: TDeployFileList;

    public
      FDeployConfigList:             TDeployConfigList;
      FAndroidJarList:               TStringList;
      FAndroidAarList:               TStringList;
      FAndroidVariableList:          TConfigVariableList;
      FAndroidUsersPermissions:      TStringList;
      FAndroidApplicationChildNodes: TStringList;
      FIOSPlistRootNodes:            TStringList;
      FIOSLinkerOptions:             String;
    private
      function FindDeployFileXMLNode(ADeployFile: TDeployFile;
        AXMLNode: IXMLNode;
        AExistsLocalNameList: TStringList;
        var AIsLostSomePlatform: Boolean
        ): IXMLNode;

      function FindDeployFilePlatformXMLNode(APlatform: String;
        ADeployFileXMLNode: IXMLNode): IXMLNode;
    public
      constructor Create;
      destructor Destroy; override;
    public
      function LoadDeployFileListFromProject(AProjectFilePath: String): Boolean;

      function SaveDeployFileListToProject(ADeployFileList: TDeployFileList;
        AProjectFilePath: String): Boolean;

      function SaveDeployFileToXMLNode(ADeployFile: TDeployFile;
        AXMLNode: IXMLNode;
        AProjectFilePath: String;
        var AIsModified: Boolean): Boolean;
      function AddDeployFileToXMLNode(ADeployFile: TDeployFile;
        AXMLNode: IXMLNode): Boolean;
      function AddDeployFilePlatformToXMLNode(ADeployFile: TDeployFile;
        ADeployFilePlatform: TDeployFilePlatform;
        ADeployFileXMLNode: IXMLNode;
        var AIsModified: Boolean): Boolean;

      function SaveAndroidJarListToProject(AAndroidJarList: TStringList;
        AProjectFilePath: String): Boolean;

      function SaveAndroidAarListToProject(AAndroidAarList: TStringList;
        AProjectFilePath: String): Boolean;

      function LoadAndroidJarListFromProject(AAndroidJarList: TStringList;
        AProjectFilePath: String): Boolean;

      procedure CheckAndroidManifestTemplateXmlFile(AProjectFilePath: String);

      function SaveAndroidUsersPermissionsToProject(AAndroidUsersPermissions
        : TStringList;
        AConfigVariables: TConfigVariableList;
        AProjectFilePath: String): Boolean;

      function SaveAndroidApplicationChildNodesToProject
        (AAndroidApplicationChildNodes: TStringList;
        AConfigVariables: TConfigVariableList;
        AProjectFilePath: String): Boolean;

      function SaveProjectIconToProject(AProjectFilePath: String): Boolean;
      function SaveProjectPictureToProjectXMLNode(AIconWidth: Integer; AIconHeight: Integer; ANodeName: String; AXMLNode: IXMLNode; AText: String = ''): Boolean;
      function SaveProjectLaunchImageToProject(AProjectFilePath: String): Boolean;
      procedure CheckInfoPlistTemplateiOSXmlFile(AProjectFilePath: String);

      procedure CheckEntitlementTemplateiOSXmlFile(AProjectFilePath: String);
      function SaveIOSInfoPlistToProject(AProjectFilePath: String;
        AInfoPlistRootNodes: TStringList;
        AConfigVariables: TConfigVariableList
        ): Boolean;

      function SaveIOSLinkerOptionsToProject(AProjectFilePath: String;
        ALinkerOptions: String
        ): Boolean;

      function GetAndroidSDKSetting(
        // 19.0,20
        ADelphiVersion: String;
        var AJDKDir: String;
        var AAndroidSDKDir: String;
        var AAndroidSDKPlatform: String;
        var AAndroidSDKBuildTools: String
        ): Boolean;

    public
      procedure RemoveNoUseResource(RTextFileName, RJavaFileName: string;
        NewRJavaFileName: string = '');
      function GenerateJar(AProjectFilePath: String;
        AGeneratedJarDir: String;
        AJarSourceCodeDir: String;
        AGeneratedJarPackage: String;
        AAndroidPackage: String;
        AGeneratedJarFileName: String;
        AUsedAndroidJars: TStrings;
        AJDKDir: String;
        AAndroidSDKDir: String;
        AAndroidSDKPlatform: String;
        AAndroidSDKBuildTools: String
        ): Boolean;

      function GenerateR_Java(AGenJarFileNameNoExt: String;
        AJarGenRootDir: String;
        AProjectResPath: String;
        AAndroidManifestXmlFilePath: String;
        AJDKDir: String;
        AAndroidSDKDir: String;
        AAndroidSDKPlatform: String;
        AAndroidSDKBuildTools: String;
        var AR_JAVA_FilePath: String;
        AGetCommandLineOutputEvent: TGetCommandLineOutputEvent
        ): Boolean;
    public
      procedure LoadFromINI(AINIFilePath: String);
      procedure SaveToINI(AINIFilePath: String);
      function ProcessAll(AProjectFilePath: String): Boolean;
    public
  end;

var
  GlobalDeployConfigRemoteDirList: TStringList;
  GlobalIOSFrameworkList:          TStringList;
  GlobalIOSDylibList:              TStringList;
  OnDeployConfigLog:               TDeployConfigLogEvent;

function ConvertRelativePathToAbsolutePath(ABaseDirPath: String; ARelativePath: String): String;
function ConvertAbsolutePathToRelativePath(ABaseDirPath: String; AAbsolutePath: String): String;
procedure ReplaceStringList(AFrom: String; ATo: String; AStringList: TStrings);

function GenerateJarBatStringList(ATempJarDirPath: String;
  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;
  AJarFileName: String;
  AUsedAndroidJars: TStrings;
  AJavaSourceFiles: TStrings;
  ATempDexedJarFilePath: String;
  ABatStringList: TStringList
  ): Boolean;

function GenerateJarBatToProject(ATempJarDirPath: String;
  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;
  AJarFilePath: String;
  AUsedAndroidJars: TStrings;
  AJavaSourceFiles: TStrings;
  AGenJarBatFilePath: String;
  ATempDexedJarFilePath: String = ''
  ): Boolean;

function GenerateWeiXinJarBatToProject(AJarGenRootDir: String;
  ATempJarDir: String;
  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;
  AJarFilePath: String;
  AUsedAndroidJars: TStrings;

  AAndroidPackage: String;
  AWXEntryActivityLines: TStrings;
  AWXPayEntryActivityLines: TStrings;
  AOnWeixinListenerLines: TStrings;
  AWxApiPasLines: TStrings
  ): Boolean;

// 生成R.Java的命令
function GenerateResJavaBatString(
  AGenResJavaSrcDirPath: String;
  // C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt
  AAndroidSDKAaptExeFilePath: String;
  // C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar
  AAndroidSystemJarFilePath: String;
  // res目录
  AProjectResPath: String;
  // AndroidManifest.xml的路径
  AAndroidManifestXmlFilePath: String;
  // //
  // AGenRJavaBatFilePath:String;

  var AGenR_Java_Command: String;
  AGetCommandLineOutputEvent: TGetCommandLineOutputEvent
  ): Boolean;
// function GenerateResJavaBat(
// AGenResJavaSrcDirPath:String;
// //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt
// AAndroidSDKAaptExeFilePath:String;
// //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar
// AAndroidSystemJarFilePath:String;
// //res目录
// AProjectResPath:String;
// //AndroidManifest.xml的路径
// AAndroidManifestXmlFilePath:String;
// //
// AGenRJavaBatFilePath:String
// ):Boolean;

// 输出日志
procedure DoDeployConfigLog(Sender: TObject; const ALog: String);

procedure DoGetFileList(dirName: string; AFilePathList: TStringList);

function GetAndroidPackageName(AAndroidManifestXmlFilePath: String): String;

procedure ProcessConfigVariables(AStringList: TStringList;
  AConfigVariableList: TConfigVariableList);

procedure AddLibraryToIOSSDK(
  ADelphiVersion: String;
  AIOS_SDK: String;
  APathType: Integer;
  APathName: String;
  APathDir: String;
  AIncludeSubDir: String
  );
function GetInstalledDelphiVersions: TStringList;
function GetInstalledDelphiVersionsCommaText: String;
function GetInstalledPlatforms(ADelphiVersion: String): TStringList;

procedure AddLibraryToAllIOSSDK(
  APathType: Integer;
  APathName: String;
  APathDir: String;
  AIncludeSubDir: String
  );

function SaveEnabledSDKS(AProjectFilePath: String;
  ASDKs: TStringList): Boolean;
function ProcessEnabledSDKS(AProjectFilePath: String;
  ASDKConfigFilePath: String): Boolean;

function ExtractFileNameNoExt(AFilePath: String): String;
function ChangeFileExt(AFilePath: String; ANewFileExt: String): String;
function GetJarDexedFileName(AJarFileName: String): String;


implementation

function ChangeFileExt(AFilePath: String; ANewFileExt: String): String;
var
  AConfigFileExt: String;
begin
  Result         := ExtractFileName(AFilePath);
  AConfigFileExt := ExtractFileExt(Result);
  Result         := ExtractFilePath(AFilePath) + Copy(Result, 1,
    Length(Result) - Length(AConfigFileExt));
  Result := Result + ANewFileExt;
end;

function ExtractFileNameNoExt(AFilePath: String): String;
var
  AConfigFileExt: String;
begin
  Result         := ExtractFileName(AFilePath);
  AConfigFileExt := ExtractFileExt(Result);
  Result         := Copy(Result, 1, Length(Result) - Length(AConfigFileExt));
end;

function ProcessEnabledSDKS(AProjectFilePath: String;
  ASDKConfigFilePath: String): Boolean;
var
  I:              Integer;
  ASDK:           String;
  ASuperObject:   ISuperObject;
  AProjectConfig: TProjectConfig;
begin
  if not FileExists(ASDKConfigFilePath) then
  begin
    raise Exception.Create(QuotedStr(ASDKConfigFilePath) + ' is not exist');
    Exit;
  end;

  ASuperObject := TSuperObject.ParseFile(ASDKConfigFilePath);

  for I := 0 to ASuperObject.A['enabled_sdks'].Length - 1 do
  begin

    ASDK := ExtractFilePath(AProjectFilePath) + ASuperObject.A
      ['enabled_sdks'].S[I];


    // //是个aar文件
    // if ExtractFileExt(ASDK)='.aar' then
    // begin
    //
    //
    // Continue;
    // end;

    // SDK是个目录
    if not DirectoryExists(ASDK) then
    begin
      raise Exception.Create(QuotedStr(ASDK) + '不存在,请拷贝该SDK目录到工程目录下');
      Exit;
    end
    else
    begin
      AProjectConfig := TProjectConfig.Create;
      try
        AProjectConfig.LoadFromINI(
          ASDK + '\' + 'DeployConfig.ini'
          );
        if not AProjectConfig.ProcessAll(AProjectFilePath) then
        begin
          ShowMessage(ASuperObject.A['enabled_sdks'].S[I] + '布署失败');
          Exit;
        end;
      finally
        AProjectConfig.Free;
      end;
    end;

  end;

end;

function SaveEnabledSDKS(AProjectFilePath: String;
  ASDKs: TStringList): Boolean;
var
  ASuperObject:    ISuperObject;
  ASuperArray:     ISuperArray;
  I:               Integer;
  AConfigFileName: String;
  AConfigFileExt:  String;
  AConfigFilePath: String;
begin

  AConfigFileName := ExtractFileName(AProjectFilePath);
  AConfigFileExt  := ExtractFileExt(AConfigFileName);
  AConfigFileName := Copy(AConfigFileName, 1, Length(AConfigFileName) -
    Length(AConfigFileExt));
  AConfigFilePath := ExtractFilePath(AProjectFilePath)
    + AConfigFileName + '.OrangeSDKConfig';

  // 先判断配置文件是否存在
  ASuperObject                   := TSuperObject.Create();
  ASuperObject.S['version']      := '1.0.0';
  ASuperArray                    := TSuperArray.Create;
  ASuperObject.A['enabled_sdks'] := ASuperArray;
  for I                          := 0 to ASDKs.Count - 1 do
  begin
    ASuperArray.S[I] := ASDKs[I];
  end;

  SaveStringToFile(ASuperObject.AsJSON, AConfigFilePath, TEncoding.UTF8);

end;



// function GetInfoPlistTemplateCustomNodeStr(AInfoPlistFilePath:String;var ACustomNodeStr:String):Boolean;
// var
// ADataString:String;
// AStartIndex:Integer;
// AEndIndex:Integer;
// AStringStream:TStringStream;
// begin
// Result:=False;
// ACustomNodeStr:='';
//
// if FileExists(AInfoPlistFilePath) then
// begin
// AStringStream:=TStringStream.Create;
// try
// AStringStream.LoadFromFile(AInfoPlistFilePath);
// ADataString:=AStringStream.DataString;
//
// //再找到最后一个</dict>
// AEndIndex:=0;
// AStartIndex:=Pos('</dict>',ADataString,0);
// while AStartIndex>0 do
// begin
// AEndIndex:=AStartIndex;
// AStartIndex:=Pos('</dict>',ADataString,AEndIndex+1);
// end;
//
// if AEndIndex>0 then
// begin
//
// AStartIndex:=Pos('<%ExtraInfoPListKeys%>',ADataString);
// if AStartIndex>0 then
// begin
// AStartIndex:=AStartIndex+Length('<%ExtraInfoPListKeys%>');
// ACustomNodeStr:=Copy(ADataString,AStartIndex,AEndIndex-AStartIndex);
//
// Result:=True;
// end
// else
// begin
// //不存在最后一个<%ExtraInfoPListKeys%>
// DoDeployConfigLog(nil,'不存在<%ExtraInfoPListKeys%>');
// end;
//
// end
// else
// begin
// //不存在最后一个</dict>
// DoDeployConfigLog(nil,'不存在最后一个</dict>');
// end;
//
//
// finally
// FreeAndNil(AStringStream);
// end;
// end;
// end;

procedure AddLibraryToAllIOSSDK(
  // 框架类型,
  // 比如Include Paths,0
  // Library Paths,1
  // Frameworks,2
  APathType: Integer;
  // 框架名称,比如SystemConfiguration
  APathName: String;
  // 路径,$(SDKROOT)/System/Library/Frameworks,$(SDKROOT)/usr/lib
  APathDir: String;
  // 是否包含子路径,0,1
  AIncludeSubDir: String
  );
var
  ADelphiVersions: TStringList;
  APlatforms:      TStringList;
  I:               Integer;
  J:               Integer;
begin
  ADelphiVersions := GetInstalledDelphiVersions;
  try
    for I := 0 to ADelphiVersions.Count - 1 do
    begin
      APlatforms := GetInstalledPlatforms(ADelphiVersions[I]);
      try
        for J := 0 to APlatforms.Count - 1 do
        begin
          if Copy(APlatforms[J], 1, Length('iPhoneOS')) = 'iPhoneOS' then
          begin
            AddLibraryToIOSSDK(
              ADelphiVersions[I],
              APlatforms[J],
              APathType,
              APathName,
              APathDir,
              AIncludeSubDir
              );
          end;
        end;
      finally
        FreeAndNil(APlatforms);
      end;
    end;
  finally
    FreeAndNil(ADelphiVersions);
  end;
end;

function GetInstalledPlatforms(ADelphiVersion: String): TStringList;
{$IFDEF MSWINDOWS}
var
  AKey: String;
  AReg: TRegistry;
  {$ENDIF}
begin
  Result := TStringList.Create;

  {$IFDEF MSWINDOWS}
  AReg := TRegistry.Create;
  try
    AReg.RootKey := HKEY_CURRENT_USER;

    AKey := '\Software\Embarcadero\BDS\'
      + ADelphiVersion + '\'
      + 'PlatformSDKs' + '\';

    if AReg.OpenKey(AKey, True) then
    begin

      AReg.GetKeyNames(Result);

    end;
  finally
    FreeAndNil(AReg);
  end;
  {$ENDIF}
end;

function GetInstalledDelphiVersionsCommaText: String;
var
  ADelphiVersions: TStringList;
begin
  ADelphiVersions := GetInstalledDelphiVersions;
  Result          := ADelphiVersions.CommaText;
  ADelphiVersions.Free;
end;

function GetInstalledDelphiVersions: TStringList;
{$IFDEF MSWINDOWS}
var
  AKey: String;
  AReg: TRegistry;
  {$ENDIF}
begin
  Result := TStringList.Create;

  {$IFDEF MSWINDOWS}
  AReg := TRegistry.Create;
  try
    AReg.RootKey := HKEY_CURRENT_USER;

    AKey := '\Software\Embarcadero\BDS\';

    if AReg.OpenKey(AKey, True) then
    begin

      AReg.GetKeyNames(Result);

    end;
  finally
    FreeAndNil(AReg);
  end;
  {$ENDIF}
end;

// HKEY_CURRENT_USER\Software\Embarcadero\BDS\
// 18.0\
// PlatformSDKs
procedure AddLibraryToIOSSDK(
  // Delphi的版本,比如18,0
  ADelphiVersion: String;
  // IOS SDK的版本号,比如iPhoneOS10.3.sdk
  AIOS_SDK: String;
  // 框架类型,
  // 比如Include Paths,0
  // Library Paths,1
  // Frameworks,2
  APathType: Integer;
  // 框架名称,比如SystemConfiguration,或者库名libicucore.tbd
  APathName: String;
  // 路径,$(SDKROOT)/System/Library/Frameworks,$(SDKROOT)/usr/lib
  APathDir: String;
  // 是否包含子路径,0,1
  AIncludeSubDir: String
  );
{$IFDEF MSWINDOWS}
var
  I:              Integer;
  AKey:           String;
  APathCount:     Integer;
  AReg:           TRegistry;
  AIsExists:      Boolean;
  ATempStr:       String;
  AKeyStringList: TStringList;
  {$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  // 设置注册表
  AReg           := TRegistry.Create;
  AKeyStringList := TStringList.Create;
  try
    AReg.RootKey := HKEY_CURRENT_USER;

    AKey := '\Software\Embarcadero\BDS\'
      + ADelphiVersion + '\'
      + 'PlatformSDKs' + '\'
      + AIOS_SDK + '\';

    // 不需要创建
    if AReg.OpenKey(AKey, False) then
    begin

      AIsExists := False;
      if AReg.ValueExists('PathCount') then
      begin
        try
          APathCount := AReg.ReadInteger('PathCount');

          AReg.GetValueNames(AKeyStringList);
          for I := 0 to AKeyStringList.Count - 1 do
          begin
            if Copy(AKeyStringList[I], 1, 4) = 'Mask' then
            begin

              ATempStr := Copy(AKeyStringList[I], 5, MaxInt);

              // 取出值,比对是否存在
              if AReg.ReadString(AKeyStringList[I]) = APathName then
              begin
                // 已经存在,不用添加了
                AIsExists := True;
                Break;
              end;

            end;
          end;

          // 注册表里没有
          if Not AIsExists then
          begin
            AReg.WriteInteger('Type' + IntToStr(APathCount), APathType);
            AReg.WriteString('Mask' + IntToStr(APathCount), APathName);
            AReg.WriteString('Path' + IntToStr(APathCount), APathDir);
            AReg.WriteString('IncludeSubDir' + IntToStr(APathCount),
              AIncludeSubDir);

            AReg.WriteInteger('PathCount', APathCount + 1);
          end;
        except
          on E: Exception do
          begin
            DoDeployConfigLog(nil, 'AddLibraryToIOSSDK Error:' + E.Message);
          end;
        end;
      end
      else
      begin
        DoDeployConfigLog(nil, 'AddLibraryToIOSSDK PathCount is not exist!');
      end;

    end
    else
    begin
      DoDeployConfigLog(nil, 'AddLibraryToIOSSDK Open key "' + AKey +
        '" fail!');
    end;
  finally
    FreeAndNil(AReg);
    FreeAndNil(AKeyStringList);
  end;
  {$ENDIF}
end;

function GetAndroidPackageName(AAndroidManifestXmlFilePath: String): String;
var
  AXMLDocument: TXMLDocument;
  AXMLNode:     IXMLNode;
begin
  Result := '';
  AXMLDocument := TXMLDocument.Create(Application);
  try
    AXMLDocument.LoadFromFile(AAndroidManifestXmlFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;

    // <?xml version="1.0" encoding="utf-8"?>
    // <manifest xmlns:android="http://schemas.android.com/apk/res/android"
    // package="tb.audio"
    // android:versionCode="1"
    // android:versionName="1.0" >

    Result := AXMLNode.Attributes['package'];

  finally
    AXMLDocument.Free;
  end;

end;

// procedure CombineXML(AXMLAFilePath:String;AXMLBFilePath:String;ADestXMLFilePath:String);
// var
// AXMLADocument: TXMLDocument;
// AXMLBDocument: TXMLDocument;
// AXMLANode: IXMLNode;
// AXMLBNode: IXMLNode;
// I: Integer;
// AXMLNode:IXMLNode;
// begin
// //创建XML文档
// AXMLADocument:=TXMLDocument.Create(Application);
// AXMLBDocument:=TXMLDocument.Create(Application);
// try
// AXMLADocument.LoadFromFile(AXMLAFilePath);
// AXMLADocument.Active:=True;
// AXMLANode:=AXMLADocument.DocumentElement;
//
// AXMLBDocument.LoadFromFile(AXMLBFilePath);
// AXMLBDocument.Active:=True;
// AXMLBNode:=AXMLBDocument.DocumentElement;
//
// //再把XMLB合进来
// for I := 0 to AXMLBNode.ChildNodes.Count-1 do
// begin
//
// //判断是否存在重复的节点
// AXMLNode:=FindSameAndroidResourceNode(AXMLANode,AXMLBNode.ChildNodes[I]);
// if AXMLNode=nil then
// begin
// //不存在此名称的
// //直接复制
// AXMLANode.ChildNodes.Add(AXMLBNode.ChildNodes[I]);
// end
// else
// begin
// //已经存在此节点
// DoDeployConfigLog(nil,GetLangString(['此XML节点已存在',
// 'The xml node is not exist']));
// end;
//
// end;
//
//
// AXMLADocument.SaveToFile(ADestXMLFilePath);
//
// finally
// AXMLADocument.Free;
// AXMLBDocument.Free;
// end;
//
// end;

procedure DoDeployConfigLog(Sender: TObject; const ALog: String);
begin
  uBaseLog_Copy.HandleException(nil, ALog);
  if Assigned(OnDeployConfigLog) then
  begin
    OnDeployConfigLog(Sender, ALog);
  end;
end;

// 把相对目录转换成绝对目录
// .\baidumap\ 转换成 D:\aaa\baidumap\
function ConvertRelativePathToAbsolutePath(ABaseDirPath: String;
  ARelativePath: String): String;
var
  Dest: array [0 .. MAX_PATH] of char;
begin
  {$IFDEF MSWINDOWS}
  FillChar(Dest, MAX_PATH + 1, 0);
  PathCombine(Dest, PChar(ABaseDirPath), PChar(ARelativePath));
  Result := string(Dest);
  {$ENDIF}
end;

// 把绝对目录转换成相对目录
// D:\aaa\baidumap\ 转换成 .\baidumap\
function ConvertAbsolutePathToRelativePath(ABaseDirPath: String;
  AAbsolutePath: String): String;
var
  p: array [0 .. MAX_PATH] of char;
begin
  ABaseDirPath := ExtractFilePath(ABaseDirPath);

  {$IFDEF MSWINDOWS}
  // if FileExists(AAbsolutePath) then
  if AAbsolutePath[Length(AAbsolutePath)] = '\' then
  begin
    // 是目录
    PathRelativePathTo(p, PChar(ABaseDirPath), FILE_ATTRIBUTE_DIRECTORY,
      PChar(AAbsolutePath), FILE_ATTRIBUTE_DIRECTORY);
  end
  else
  begin
    // 是文件
    PathRelativePathTo(p, PChar(ABaseDirPath), FILE_ATTRIBUTE_DIRECTORY,
      PChar(AAbsolutePath), FILE_ATTRIBUTE_NORMAL);
  end;
  {$ENDIF}
  Result := StrPas(p);

  if Copy(Result, 1, 2) = '.\' then
  begin
    // 去掉
    Result := Copy(Result, 3, MaxInt);
  end;

end;

procedure DoGetFileList(dirName: string; AFilePathList: TStringList);
var
  sr:   TSearchRec;
  dLen: Integer;
  str:  string;
begin
  dLen := Length(dirName);
  if dirName[dLen] <> '\' then
    dirName := dirName + '\';
  if FindFirst(dirName + '*.*', faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Name = '.') or (sr.Name = '..') then
        continue;
      str := dirName + sr.Name;

      if (sr.Attr and faDirectory) = faDirectory then
      begin
        DoGetFileList(str, AFilePathList);
      end
      else
      begin
        if sr.Name <> 'Thumbs.db' then
        begin
          AFilePathList.Add(str);
        end;
      end;

    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

end;

function GetJarDexedFileName(AJarFileName: String): String;
begin
  Result := ExtractFileNameNoExt(AJarFileName) + '-dexed.jar';
end;

function GenerateJarBatStringList(ATempJarDirPath: String;

  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;

  AJarFileName: String;
  AUsedAndroidJars: TStrings;
  AJavaSourceFiles: TStrings;
  // AAndroidPackageName:String;
  ATempDexedJarFilePath: String;

  ABatStringList: TStringList
  ): Boolean;
var
  I:         Integer;
  ANeedJars: String;
begin

  Result := False;

  ForceDirectories(ATempJarDirPath);


  // //生成Jar
  // //创建bat
  // Result:=TStringList.Create;


  // 先删除临时文件

  // R_JAVA_TwitterLogin-dexed.jar
  if ATempDexedJarFilePath <> '' then
  begin
    ABatStringList.Add('del ' + '"' + ATempDexedJarFilePath + '"');
  end;

  ABatStringList.Add('@echo off');
  ABatStringList.Add('cd ' + ATempJarDirPath);
  ABatStringList.Add(Copy(ATempJarDirPath, 1, 2));
  ABatStringList.Add('');
  ABatStringList.Add('setlocal');
  ABatStringList.Add('');
  ABatStringList.Add('set JarOutName=' + AJarFileName);
  ABatStringList.Add('');
  ABatStringList.Add('set JDKDir=' + AJDKDir);
  ABatStringList.Add('');
  ABatStringList.Add('set ANDROID=' + AAndroidSDKDir);
  ABatStringList.Add('');
  ABatStringList.Add('set ANDROID_PLATFORM=' + AAndroidSDKPlatform);
  ABatStringList.Add('');
  ABatStringList.Add('set ANDROID_BT=' + AAndroidSDKBuildTools);
  ABatStringList.Add('');
  ABatStringList.Add('set DX_LIB=%ANDROID_BT%\lib');
  ABatStringList.Add('');
  ABatStringList.Add('set PROJ_DIR=%CD%');
  ABatStringList.Add('');
  ABatStringList.Add('set VERBOSE=0');
  ABatStringList.Add('');
  ABatStringList.Add('mkdir output 2> nul');
  ABatStringList.Add('');
  ABatStringList.Add('mkdir output\classes 2> nul');
  ABatStringList.Add('');
  ABatStringList.Add('if x%VERBOSE% == x1 SET VERBOSE_FLAG=-verbose');
  ABatStringList.Add('');




  // 编译多个java源文件,要写多条
  // ABatStringList.Add('"%JDKDir%\bin\javac" %VERBOSE_FLAG% -g -source 1.6 -target 1.6 -Xlint:deprecation -cp '
  // +' "%ANDROID_PLATFORM%\android.jar;%EMBO_LIB%\fmx.jar;" '
  // +' -d output\classes '
  // +'src\com\ggggcexx\orangeui\wxapi\*.java');

  ANeedJars := '';
  if AUsedAndroidJars <> nil then
  begin
    for I := 0 to AUsedAndroidJars.Count - 1 do
    begin
      ANeedJars := ANeedJars + AUsedAndroidJars[I] + ';';
    end;
  end;

  // 要编译哪些源码,输出到output目录
  for I := 0 to AJavaSourceFiles.Count - 1 do
  begin
    ABatStringList.Add(
      '"%JDKDir%\bin\javac" %VERBOSE_FLAG% -g -source 1.6 -target 1.6 -Xlint:deprecation -cp '
      // +' "%ANDROID_PLATFORM%\android.jar;%EMBO_LIB%\fmx.jar;" '
      + ' "' + ANeedJars + '" '

      // class文件输出目录
      // +' -d output\classes '
      + ' -d ' + '"' + ATempJarDirPath + 'output\classes' + '"'

      // 不能用引号"，不然java文件找不到
      // +'"'+AJavaSourceFiles[I]+'"'
      + ' ' + AJavaSourceFiles[I] + ''
      // +'src\com\ggggcexx\orangeui\wxapi\*.java'

      );
    ABatStringList.Add('');
  end;

  ABatStringList.Add('if x%VERBOSE% == x1 SET VERBOSE_FLAG=v');
  ABatStringList.Add('');


  // ABatStringList.Add('"%JDKDir%\bin\jar" c%VERBOSE_FLAG%f %JarOutName% -C output\classes com');

  // if Pos('.',AAndroidPackageName)>0 then
  // begin
  // 有com.**.***
  ABatStringList.Add('"%JDKDir%\bin\jar" c%VERBOSE_FLAG%f %JarOutName% -C '
    + '"' + ATempJarDirPath + 'output\classes' + '"'
    // 并不是每个jar都是com.****
    // +' '+'com'
    // com.gggcexx.orangeui
    + ' ' + '.' // Copy(AAndroidPackageName,1,Pos('.',AAndroidPackageName)-1)
    );
  // end
  // else
  // begin
  // //没有com.***.***,而是直接用jkm7ems
  // ABatStringList.Add('"%JDKDir%\bin\jar" c%VERBOSE_FLAG%f %JarOutName% -C '
  // +'"'+ATempJarDirPath+'output\classes'+'"'
  // //并不是每个jar都是com.****
  // //              +' '+'jkm7ems'
  // //              jkm7ems
  // +' '+'.'//+AAndroidPackageName
  // );
  // end;

  // 生成dex.jar
  // 4、将生成的 base.jar 转换成 classes.dex 通过  命令
  // dx工具在android sdk build-tools 里有
  // dx --dex --output classes2.dex base.jar
  if ATempDexedJarFilePath <> '' then
  begin
    ABatStringList.Add('"%ANDROID_BT%\dx" --dex --output ' +
      ATempDexedJarFilePath + ' ' + AJarFileName);
  end
  else
  begin
    ABatStringList.Add('"%ANDROID_BT%\dx" --dex --output ' +
      GetJarDexedFileName(AJarFileName) + ' ' + AJarFileName);
  end;

  ABatStringList.Add('');
  // ABatStringList.Add('cd '+ATempDir);
  // ABatStringList.Add(Copy(ATempDir,1,2));
  // ABatStringList.Add('explorer.exe /e,'
  // +' /select, '+ATempDir+AJarFileName
  /// /            +' /root, '+ATempDir
  //
  // );
  ABatStringList.Add('');

  // 调试
  ABatStringList.Add('');
  ABatStringList.Add('endlocal');

  ABatStringList.Add('');
  // ABatStringList.Add('pause');
  ABatStringList.Add('');
  ABatStringList.Add('');
  ABatStringList.Add('');
  ABatStringList.Add('');
  ABatStringList.Add('');
  ABatStringList.Add('');
  ABatStringList.Add('');

  Result := True;

end;

procedure ReplaceStringList(AFrom: String; ATo: String; AStringList: TStrings);
var
  I: Integer;
begin
  for I := 0 to AStringList.Count - 1 do
  begin
    AStringList[I] := ReplaceStr(AStringList[I], AFrom, ATo);
  end;
end;

{ TDeployFile }

constructor TDeployFile.Create;
begin
  Platforms := TDeployFilePlatformList.Create;
end;

destructor TDeployFile.Destroy;
begin
  FreeAndNil(Platforms);
  inherited;
end;

function TDeployFile.FindPlatform(APlatform: String): TDeployFilePlatform;
var
  I: Integer;
begin
  Result := nil;
  for I  := 0 to Self.Platforms.Count - 1 do
  begin
    if Self.Platforms[I].Platform_ = APlatform then
    begin
      Result := Self.Platforms[I];
      Break;
    end;
  end;
end;

function TDeployFile.PlatformsCommaText: String;
var
  I: Integer;
begin
  Result := '';
  for I  := 0 to Self.Platforms.Count - 1 do
  begin
    if I <> Self.Platforms.Count - 1 then
    begin
      Result := Result + Self.Platforms[I].Platform_ + ',';
    end
    else
    begin
      Result := Result + Self.Platforms[I].Platform_;
    end;
  end;
end;

{ TDeployFilePlatformList }

function TDeployFilePlatformList.FindItemByPlatform(APlatform: String)
  : TDeployFilePlatform;
var
  I: Integer;
begin
  Result := nil;
  for I  := 0 to Self.Count - 1 do
  begin
    // if Pos(LowerCase(APlatform),LowerCase(Self.Items[I].Platform_))>0 then
    if LowerCase(APlatform) = LowerCase(Self.Items[I].Platform_) then
    begin
      Result := Self.Items[I];
      Break;
    end;
  end;
end;

function TDeployFilePlatformList.GetItem(Index: Integer): TDeployFilePlatform;
begin
  Result := TDeployFilePlatform(Inherited Items[Index]);
end;

{ TDeployFileList }

function TDeployFileList.FindItemByLocalName(ALocalName: String): TDeployFile;
var
  I: Integer;
begin
  Result := nil;
  for I  := 0 to Self.Count - 1 do
  begin
    if SameText(Items[I].LocalName, ALocalName) then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TDeployFileList.FindItemByRemoteName(ARemotePath: String;
  APlatform: String): TDeployFile;
var
  I: Integer;
  J: Integer;
begin
  Result := nil;
  for I  := 0 to Self.Count - 1 do
  begin
    for J := 0 to Items[I].Platforms.Count - 1 do
    begin
      if (Items[I].Platforms[J].RemoteDir + Items[I].Platforms[J]
        .RemoteName = ARemotePath)
        and (Items[I].Platforms[J].Platform_ = APlatform) then
      begin
        Result := Items[I];
        Break;
      end;
    end;
  end;
end;

function TDeployFileList.GetItem(Index: Integer): TDeployFile;
begin
  Result := TDeployFile(Inherited Items[Index]);
end;


// { TDeployConfigList }
//
// function TDeployConfigList.GetItem(Index: Integer): TDeployConfig;
// begin
// Result:=TDeployConfig(Inherited Items[Index]);
// end;

{ TProjectConfig }

// function AddDeployFileToXMLNodeWithPlatform():Boolean;
// begin
//
// end;

function TProjectConfig.AddDeployFilePlatformToXMLNode(ADeployFile: TDeployFile;
  ADeployFilePlatform: TDeployFilePlatform;
  ADeployFileXMLNode: IXMLNode;
  var AIsModified: Boolean): Boolean;
var
  ADeployFilePlatformXMLNode: IXMLNode;
  ARemoteDirNode:             IXMLNode;
  ARemoteNameNode:            IXMLNode;
  APlatformOverwriteNode:     IXMLNode;
  APlatformEnabledNode:       IXMLNode;
begin

  Result := False;

  // 判断这个本地文件是否存在
  ADeployFilePlatformXMLNode := FindDeployFilePlatformXMLNode(
    ADeployFilePlatform.Platform_,
    ADeployFileXMLNode);
  if ADeployFilePlatformXMLNode = nil then
  begin
    ADeployFilePlatformXMLNode := ADeployFileXMLNode.AddChild('Platform');
    AIsModified                := True;
  end;
  // 哪个平台
  if (ADeployFilePlatformXMLNode.Attributes['Name'] <>
    ADeployFilePlatform.Platform_) then
  begin
    ADeployFilePlatformXMLNode.Attributes['Name'] :=
      ADeployFilePlatform.Platform_;
    AIsModified := True;
  end;

  // 布署到哪个目录
  ARemoteDirNode := ADeployFilePlatformXMLNode.ChildNodes.FindNode('RemoteDir');
  // FindChildXMLNode('RemoteDir',ADeployFilePlatformXMLNode);
  if ARemoteDirNode = nil then
  begin
    ARemoteDirNode := ADeployFilePlatformXMLNode.AddChild('RemoteDir');
    AIsModified    := True;
  end;
  // 如果之前是布署到res\drawable\,现在要布署到res\drawable-hdpi\
  if ARemoteDirNode.Text <> ADeployFilePlatform.RemoteDir then
  begin
    ARemoteDirNode.Text := ADeployFilePlatform.RemoteDir;
    AIsModified         := True;
  end;

  // 布署到远程目录中的哪个文件
  ARemoteNameNode := ADeployFilePlatformXMLNode.ChildNodes.FindNode
    ('RemoteName');
  // FindChildXMLNode('RemoteName',ADeployFilePlatformXMLNode);
  if ARemoteNameNode = nil then
  begin
    ARemoteNameNode := ADeployFilePlatformXMLNode.AddChild('RemoteName');
    AIsModified     := True;
  end;
  if ARemoteNameNode.Text <> ADeployFilePlatform.RemoteName then
  begin
    ARemoteNameNode.Text := ADeployFilePlatform.RemoteName;
    AIsModified          := True;
  end;

  // 是否覆盖
  APlatformOverwriteNode := ADeployFilePlatformXMLNode.ChildNodes.FindNode
    ('Overwrite');
  // FindChildXMLNode('Overwrite',ADeployFilePlatformXMLNode);
  if APlatformOverwriteNode = nil then
  begin
    APlatformOverwriteNode := ADeployFilePlatformXMLNode.AddChild('Overwrite');
    AIsModified            := True;
  end;
  if APlatformOverwriteNode.Text = ADeployFilePlatform.Overwrite then
  begin
    APlatformOverwriteNode.Text := ADeployFilePlatform.Overwrite;
    AIsModified                 := True;
  end;

  // 是否启用
  if ADeployFilePlatform.Enabled <> '' then
  begin
    APlatformEnabledNode := ADeployFilePlatformXMLNode.ChildNodes.FindNode
      ('Enabled');
    if APlatformEnabledNode = nil then
    begin
      APlatformEnabledNode := ADeployFilePlatformXMLNode.AddChild('Enabled');
      AIsModified          := True;
    end;
    if APlatformEnabledNode.Text <> ADeployFilePlatform.Enabled then
    begin
      APlatformEnabledNode.Text := ADeployFilePlatform.Enabled;
      AIsModified               := True;
    end;
  end;

  Result := True;

end;

function TProjectConfig.AddDeployFileToXMLNode(ADeployFile: TDeployFile;
  AXMLNode: IXMLNode): Boolean;
var
  ALastDeployFileNodeIndex: Integer;
  ADeployFileXMLNode:       IXMLNode;
  // ADeployFilePlatformXMLNode:IXMLNode;
  I: Integer;
  // ARemoteDirNode:IXMLNode;
  // ARemoteNameNode:IXMLNode;
  // APlatformOverwriteNode:IXMLNode;
  // APlatformEnabledNode:IXMLNode;
  AIsModified: Boolean;
begin
  // 不存在,则添加
  // 添加到最后一个
  ALastDeployFileNodeIndex := FindLastChildXMLNodeIndex('DeployFile', AXMLNode);
  ADeployFileXMLNode := AXMLNode.AddChild('DeployFile',
    ALastDeployFileNodeIndex);

  // 不需要Configuration,因为都是Debug+Release
  ADeployFileXMLNode.Attributes['LocalName'] := ADeployFile.LocalName;
  ADeployFileXMLNode.Attributes['Class']     := ADeployFile.Class_;

  // <Platform Name="Android">
  // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
  // <RemoteName>libTbDemuxer.so</RemoteName>
  // <Overwrite>true</Overwrite>
  // </Platform>
  // 这个文件要布署到哪些平台
  for I := 0 to ADeployFile.Platforms.Count - 1 do
  begin

    AddDeployFilePlatformToXMLNode(ADeployFile,
      ADeployFile.Platforms[I],
      ADeployFileXMLNode,
      AIsModified);

  end;
end;

procedure TProjectConfig.CheckAndroidManifestTemplateXmlFile
  (AProjectFilePath: String);
var
  AFileContentList: TStringList;
begin
  if not FileExists(ExtractFilePath(AProjectFilePath) +
    'AndroidManifest.template.xml') then
  begin
    AFileContentList := TStringList.Create;

    AFileContentList.Add('<?xml version="1.0" encoding="utf-8"?>');
    AFileContentList.Add('<!-- BEGIN_INCLUDE(manifest) -->');
    AFileContentList.Add
      ('<manifest xmlns:android="http://schemas.android.com/apk/res/android"');
    AFileContentList.Add('        package="%package%"');
    AFileContentList.Add('        android:versionCode="%versionCode%"');
    AFileContentList.Add('        android:versionName="%versionName%"');
    AFileContentList.Add
      ('        android:installLocation="%installLocation%">');
    AFileContentList.Add
      ('                                                     ');
    AFileContentList.Add
      ('    <uses-sdk android:minSdkVersion="%minSdkVersion%" android:targetSdkVersion="%targetSdkVersion%" />');
    AFileContentList.Add('    <%uses-permission%>');
    AFileContentList.Add
      ('    <uses-feature android:glEsVersion="0x00020000" android:required="True"/>');
    AFileContentList.Add('    <application android:persistent="%persistent%"');
    AFileContentList.Add
      ('        android:restoreAnyVersion="%restoreAnyVersion%"');
    AFileContentList.Add('        android:label="%label%"');
    AFileContentList.Add('        android:debuggable="%debuggable%"');
    AFileContentList.Add('        android:largeHeap="%largeHeap%"');
    AFileContentList.Add('        android:icon="%icon%"');
    AFileContentList.Add('        android:theme="%theme%"');
    AFileContentList.Add
      ('        android:hardwareAccelerated="%hardwareAccelerated%"');
    AFileContentList.Add('        android:resizeableActivity="false">');
    AFileContentList.Add('                                            ');
    AFileContentList.Add('        <%provider%>');
    AFileContentList.Add('        <%application-meta-data%>');
    AFileContentList.Add('        <%services%>');
    AFileContentList.Add
      ('        <!-- Our activity is a subclass of the built-in NativeActivity framework class.');
    AFileContentList.Add
      ('             This will take care of integrating with our NDK code. -->');
    AFileContentList.Add
      ('        <activity android:name="com.embarcadero.firemonkey.FMXNativeActivity"');
    AFileContentList.Add('                android:label="%activityLabel%"');
    AFileContentList.Add
      ('                android:configChanges="orientation|keyboard|keyboardHidden|screenSize"');
    AFileContentList.Add('                android:launchMode="singleTask">');
    AFileContentList.Add
      ('            <!-- Tell NativeActivity the name of our .so -->');
    AFileContentList.Add
      ('            <meta-data android:name="android.app.lib_name"');
    AFileContentList.Add('                android:value="%libNameValue%" />');
    AFileContentList.Add('            <intent-filter>');
    AFileContentList.Add
      ('                <action android:name="android.intent.action.MAIN" />');
    AFileContentList.Add
      ('                <category android:name="android.intent.category.LAUNCHER" />');
    AFileContentList.Add('            </intent-filter>');
    AFileContentList.Add('        </activity>');
    AFileContentList.Add('        <%activity%>');
    AFileContentList.Add('        <%receivers%>');
    AFileContentList.Add('    </application>');
    AFileContentList.Add('</manifest>');
    AFileContentList.Add('<!-- END_INCLUDE(manifest) -->');

    AFileContentList.SaveToFile(ExtractFilePath(AProjectFilePath) +
      'AndroidManifest.template.xml', TEncoding.UTF8);
    AFileContentList.Free;
  end;

end;

procedure TProjectConfig.CheckEntitlementTemplateiOSXmlFile
  (AProjectFilePath: String);
var
  AFileContentList: TStringList;
begin
  if not FileExists(ExtractFilePath(AProjectFilePath) +
    'Entitlement.TemplateiOS.xml') then
  begin
    AFileContentList := TStringList.Create;

    AFileContentList.Add('<?xml version="1.0" encoding="UTF-8"?>');
    AFileContentList.Add
      ('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
    AFileContentList.Add('<plist version="1.0">');
    AFileContentList.Add('<dict>');
    AFileContentList.Add('	<%getTaskAllowKey%>');
    AFileContentList.Add('	<%applicationIdentifier%>');
    AFileContentList.Add('	<%pushNotificationKey%>');
    AFileContentList.Add('	<%keychainAccessGroups%>');
    AFileContentList.Add('</dict>');
    AFileContentList.Add('</plist>');

    AFileContentList.SaveToFile(ExtractFilePath(AProjectFilePath) +
      'Entitlement.TemplateiOS.xml', TEncoding.UTF8);
    AFileContentList.Free;
  end;

end;

procedure TProjectConfig.CheckInfoPlistTemplateiOSXmlFile
  (AProjectFilePath: String);
var
  AFileContentList: TStringList;
begin
  if not FileExists(ExtractFilePath(AProjectFilePath) +
    'info.plist.TemplateiOS.xml') then
  begin
    AFileContentList := TStringList.Create;

    AFileContentList.Add('<?xml version="1.0" encoding="UTF-8"?>');
    AFileContentList.Add
      ('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
    AFileContentList.Add('<plist version="1.0">');
    AFileContentList.Add('<dict>');
    AFileContentList.Add('<%VersionInfoPListKeys%>');
    AFileContentList.Add('<%ExtraInfoPListKeys%>');
    AFileContentList.Add('</dict>');
    AFileContentList.Add('</plist>');

    AFileContentList.SaveToFile(ExtractFilePath(AProjectFilePath) +
      'info.plist.TemplateiOS.xml', TEncoding.UTF8);
    AFileContentList.Free;
  end;
end;

// function TProjectConfig.ClearIOSLaunchImageToProject(AProjectFilePath: String): Boolean;
// var
// AXMLNode: IXMLNode;
// AXMLChildNode: IXMLNode;
// AXMLDocument: TXMLDocument;
// I: Integer;
// begin
// Result:=False;
//
// //因为需要计算出相对目录
// if (AProjectFilePath='') then
// begin
// DoDeployConfigLog(nil,
// GetLangString(['请选择工程文件','Please select projet file'])
// );
// Exit;
// end;
//
// if Not FileExists(AProjectFilePath) then
// begin
// DoDeployConfigLog(nil,
// //'工程文件不存在'
// GetLangString(['工程文件不存在','Projet file is not exist'])
// );
// Exit;
// end;
//
//
//
//
// //创建XML文档
// AXMLDocument:=TXMLDocument.Create(Application);
// try
// AXMLDocument.LoadFromFile(AProjectFilePath);
// AXMLDocument.Active:=True;
// AXMLNode:=AXMLDocument.DocumentElement;
//
/// /    <PropertyGroup Condition="'$(Cfg_2_Android)'!=''">
/// /        <PF_KeyStorePass>857E479A5FCF07DFCF26E560A4467BA2E44808467EBBECAD97E40FA78E273CF6DB5EA3DEE3551C63C1A4572EFACFC36ABAB3361C046522D316204584E58822A2C958F35CD507FA8FBFBAAF0007301D44921D3E131DF90939EB006E7F</PF_KeyStorePass>
/// /        <PF_AliasKey>police</PF_AliasKey>
/// /        <PF_KeyStore>E:\MyFiles\OrangeUIProduct\粤警党风\APP\police_138575wangneng.keystore</PF_KeyStore>
/// /        <PF_AliasKeyPass>857E479A5FCF07DFCF26E560D171E33F81850535A05F97C997AA0FF88E783C8ADB56A385E3111C2FC1E2577DFAC4C363BA95367E043722D3163A459DE5E4229DC938F341D558FA9BBFF8AF117237859AF7D53319C3477255EB006E7F</PF_AliasKeyPass>
/// /        <BT_BuildType>AppStore</BT_BuildType>
//
/// /        <Android_LauncherIcon36>android36.png</Android_LauncherIcon36>
/// /        <Android_LauncherIcon48>android48.png</Android_LauncherIcon48>
/// /        <Android_LauncherIcon72>android72.png</Android_LauncherIcon72>
/// /        <Android_LauncherIcon96>android96.png</Android_LauncherIcon96>
//
/// /        <Android_LauncherIcon144>android144.png</Android_LauncherIcon144>
//
/// /        <VerInfo_Build>1</VerInfo_Build>
/// /        <Android_SplashTileMode>disabled</Android_SplashTileMode>
/// /        <Android_SplashGravity>fill</Android_SplashGravity>
//
/// /        <Android_SplashImage426>android_fill_426x320.png</Android_SplashImage426>
/// /        <Android_SplashImage470>android_fill_470x320.png</Android_SplashImage470>
/// /        <Android_SplashImage640>android_fill_640x480.png</Android_SplashImage640>
/// /        <Android_SplashImage960>android_fill_960x720.png</Android_SplashImage960>
//
/// /        <VerInfo_Keys>package=com.ggggcexx.policepartywind;label=粤警党风;versionCode=1;versionName=1.2.0;persistent=False;restoreAnyVersion=False;installLocation=auto;largeHeap=False;theme=TitleBar;hardwareAccelerated=true;apiKey=</VerInfo_Keys>
/// /    </PropertyGroup>
//
/// /                <DeployFile LocalName="android144.png" Configuration="Release" Class="Android_LauncherIcon144">
/// /                    <Platform Name="Android">
/// /                        <RemoteName>ic_launcher.png</RemoteName>
/// /                        <Overwrite>true</Overwrite>
/// /                    </Platform>
/// /                </DeployFile>
//
//
//
/// /    <PropertyGroup Condition="'$(Cfg_2_iOSDevice32)'!=''">
/// /        <VerInfo_MinorVer>2</VerInfo_MinorVer>
/// /        <PF_AutoMobileProvisionAdHoc>False</PF_AutoMobileProvisionAdHoc>
/// /        <PF_MobileProvisionAdHoc>2f334ed2-a196-42bd-8a75-fd893d9fe907</PF_MobileProvisionAdHoc>
/// /        <PF_DevAdHoc>iPhone Distribution: silin fang (L7K5FEPWXY)</PF_DevAdHoc>
/// /        <PF_AutoCertificateAdHoc>False</PF_AutoCertificateAdHoc>
/// /        <PF_DevDebug>iPhone Developer: silin fang (2K9E4G72YV)</PF_DevDebug>
/// /        <PF_AutoCertificateDebug>False</PF_AutoCertificateDebug>
/// /        <PF_AutoMobileProvisionDebug>False</PF_AutoMobileProvisionDebug>
/// /        <VerInfo_UIDeviceFamily>iPhoneAndiPad</VerInfo_UIDeviceFamily>
/// /        <VerInfo_IncludeVerInfo>true</VerInfo_IncludeVerInfo>
/// /        <VerInfo_BundleId>com.ggggcexx.policepartywind</VerInfo_BundleId>
/// /        <PF_MobileProvisionDebug>fe1056dd-7240-4fda-8aff-4af81ceeb5b8</PF_MobileProvisionDebug>
/// /
/// /        <iPad_SpotLight40>iphone40.png</iPad_SpotLight40>
/// /        <iPad_SpotLight50>iphone50.png</iPad_SpotLight50>
/// /        <iPad_SpotLight80>iphone80.png</iPad_SpotLight80>
/// /        <iPad_SpotLight100>iphone100.png</iPad_SpotLight100>
/// /        <iPhone_Spotlight29>iphone29.png</iPhone_Spotlight29>
/// /        <iPhone_Spotlight40>iphone40.png</iPhone_Spotlight40>
/// /        <iPhone_Spotlight58>iphone58.png</iPhone_Spotlight58>
/// /        <iPhone_Spotlight80>iphone80.png</iPhone_Spotlight80>
/// /
/// /        <iPad_Setting29>iphone29.png</iPad_Setting29>
/// /        <iPad_Setting58>iphone58.png</iPad_Setting58>
/// /
/// /        <iPhone_AppIcon57>iphone57.png</iPhone_AppIcon57>
/// /        <iPhone_AppIcon60>iphone60.png</iPhone_AppIcon60>
/// /        <iPhone_AppIcon87>iphone87.png</iPhone_AppIcon87>
/// /        <iPhone_AppIcon114>iphone114.png</iPhone_AppIcon114>
/// /        <iPhone_AppIcon120>iphone120.png</iPhone_AppIcon120>
/// /        <iPhone_AppIcon180>iphone180.png</iPhone_AppIcon180>
/// /        <iPad_AppIcon72>iphone72.png</iPad_AppIcon72>
/// /        <iPad_AppIcon76>iphone76.png</iPad_AppIcon76>
/// /        <iPad_AppIcon144>ipad144.png</iPad_AppIcon144>
/// /        <iPad_AppIcon152>ipad152.png</iPad_AppIcon152>
/// /
/// /        <iPad_Setting29>iphone29.png</iPad_Setting29>
/// /        <iPad_Setting58>iphone58.png</iPad_Setting58>
/// /
/// /        <iPad_Launch768>ipad768_1004.png</iPad_Launch768>
/// /        <iPad_Launch768x1024>ipad768_1024.png</iPad_Launch768x1024>
/// /        <iPad_Launch1024>ipad1024_748.png</iPad_Launch1024>
/// /        <iPad_Launch1024x768>ipad1024_768.png</iPad_Launch1024x768>
/// /        <iPad_Launch1536>ipad1536_2008.png</iPad_Launch1536>
/// /        <iPad_Launch1536x2048>ipad1536_2048.png</iPad_Launch1536x2048>
/// /        <iPad_Launch2048>ipad2048_1496.png</iPad_Launch2048>
/// /        <iPad_Launch2048x1536>ipad2048_1536.png</iPad_Launch2048x1536>
/// /
/// /        <iPhone_Launch320>iphone320_480.png</iPhone_Launch320>
/// /        <iPhone_Launch640>iphone640_960.png</iPhone_Launch640>
/// /        <iPhone_Launch640x1136>iphone640_1136.png</iPhone_Launch640x1136>
/// /        <iPhone_Launch750>iphone750_1334.png</iPhone_Launch750>
/// /        <iPhone_Launch1242>iphone1242_2208.png</iPhone_Launch1242>
/// /        <iPhone_Launch2208>iphone2208_1242.png</iPhone_Launch2208>
/// /
/// /        <VerInfo_Keys>
/// /            CFBundleName=$(MSBuildProjectName);
/// /            CFBundleDevelopmentRegion=en;
/// /            CFBundleDisplayName=粤警党风;
/// /            CFBundleIdentifier=com.ggggcexx.policepartywind;
/// /            CFBundleInfoDictionaryVersion=7.1;
/// /            CFBundleVersion=1.2.0;
/// /            CFBundlePackageType=APPL;
/// /            CFBundleSignature=????;
/// /            LSRequiresIPhoneOS=true;
/// /            CFBundleAllowMixedLocalizations=YES;
/// /            CFBundleExecutable=$(MSBuildProjectName);
/// /            UIDeviceFamily=iPhone &amp; iPad;
/// /            CFBundleResourceSpecification=ResourceRules.plist;
/// /            NSLocationAlwaysUsageDescription=The reason for accessing the location information of the user;
/// /            NSLocationWhenInUseUsageDescription=The reason for accessing the location information of the user;
/// /            FMLocalNotificationPermission=false;
/// /            UIBackgroundModes=;
/// /            DTSDKName=iphoneos7.0;
/// /            DTPlatformVersion=7.0;
/// /            UIStatusBarStyle=UIStatusBarStyleLightContent;
/// /            DTPlatFormName=iphoneos;
/// /            NSContactsUsageDescription=The reason for accessing the contacts;
/// /            NSPhotoLibraryUsageDescription=The reason for accessing the photo library;
/// /            NSCameraUsageDescription=The reason for accessing the camera</VerInfo_Keys>
/// /    </PropertyGroup>
//
//
/// /      AXMLNode:=AXMLDocument.DocumentElement;
/// /      if AXMLNode<>nil then
/// /      begin
/// /        for I := 0 to AXMLNode.ChildNodes.Count-1 do
/// /        begin
/// /          AXMLChildNode:=AXMLNode.ChildNodes[I];
/// /
/// /
/// ///            //Android
/// ///            if (AXMLChildNode.NodeName='PropertyGroup')
/// ///              and (
/// ///                   (AXMLChildNode.Attributes['Condition']='''$(Base_Android)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_1_Android)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_2_Android)''!=''''')
/// ///                ) then
/// ///            begin
/// ///
/// ///              SaveProjectPictureToProjectXMLNode(426,320,'Android_SplashImage426',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(470,320,'Android_SplashImage470',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(640,480,'Android_SplashImage640',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(960,720,'Android_SplashImage960',AXMLNode.ChildNodes[I]);
/// ///
/// ///            end;
/// /
/// /
/// ///            //IOS
/// ///            if (AXMLChildNode.NodeName='PropertyGroup')
/// ///              and (
/// ///                   (AXMLChildNode.Attributes['Condition']='''$(Base_iOSDevice32)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_1_iOSDevice32)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_2_iOSDevice32)''!=''''')
/// ///
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Base_iOSDevice64)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_1_iOSDevice64)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_2_iOSDevice64)''!=''''')
/// ///
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Base_iOSSimulator)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_1_iOSSimulator)''!=''''')
/// ///                or (AXMLChildNode.Attributes['Condition']='''$(Cfg_2_iOSSimulator)''!=''''')
/// ///                ) then
/// ///            begin
/// ///    //        <iPad_Launch768>ipad768_1004.png</iPad_Launch768>
/// ///    //        <iPad_Launch768x1024>ipad768_1024.png</iPad_Launch768x1024>
/// ///    //        <iPad_Launch1024>ipad1024_748.png</iPad_Launch1024>
/// ///    //        <iPad_Launch1024x768>ipad1024_768.png</iPad_Launch1024x768>
/// ///    //        <iPad_Launch1536>ipad1536_2008.png</iPad_Launch1536>
/// ///    //        <iPad_Launch1536x2048>ipad1536_2048.png</iPad_Launch1536x2048>
/// ///    //        <iPad_Launch2048>ipad2048_1496.png</iPad_Launch2048>
/// ///    //        <iPad_Launch2048x1536>ipad2048_1536.png</iPad_Launch2048x1536>
/// ///    //
/// ///    //        <iPhone_Launch320>iphone320_480.png</iPhone_Launch320>
/// ///    //        <iPhone_Launch640>iphone640_960.png</iPhone_Launch640>
/// ///    //        <iPhone_Launch640x1136>iphone640_1136.png</iPhone_Launch640x1136>
/// ///    //        <iPhone_Launch750>iphone750_1334.png</iPhone_Launch750>
/// ///    //        <iPhone_Launch1242>iphone1242_2208.png</iPhone_Launch1242>
/// ///    //        <iPhone_Launch2208>iphone2208_1242.png</iPhone_Launch2208>
/// ///
/// ///              SaveProjectPictureToProjectXMLNode(768,1004,'iPad_Launch768',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(768,1024,'iPad_Launch768x1024',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(1024,748,'iPad_Launch1024',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(1024,768,'iPad_Launch1024x768',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(1536,2008,'iPad_Launch1536',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(1536,2048,'iPad_Launch1536x2048',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(2048,1496,'iPad_Launch2048',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(2048,1536,'iPad_Launch2048x1536',AXMLNode.ChildNodes[I]);
/// ///
/// ///              SaveProjectPictureToProjectXMLNode(320,480,'iPhone_Launch320',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(640,960,'iPhone_Launch640',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(640,1136,'iPhone_Launch640x1136',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(750,1334,'iPhone_Launch750',AXMLNode.ChildNodes[I]);
/// ///
/// ///              SaveProjectPictureToProjectXMLNode(1242,2208,'iPhone_Launch1242',AXMLNode.ChildNodes[I]);
/// ///              SaveProjectPictureToProjectXMLNode(2208,1242,'iPhone_Launch2208',AXMLNode.ChildNodes[I]);
/// ///
/// ///
/// ///            end;
/// /
/// /
/// /
/// /        end;
/// /      end;
//
//
//
//
//
//
// AXMLNode:=AXMLNode.ChildNodes.FindNode('ProjectExtensions');
// if AXMLNode<>nil then
// begin
// AXMLNode:=AXMLNode.ChildNodes.FindNode('BorlandProject');
// if AXMLNode<>nil then
// begin
// AXMLNode:=AXMLNode.ChildNodes.FindNode('Deployment');
// if (AXMLNode<>nil) then
// begin
// if (AXMLNode.Attributes['Version']='3') then
// begin
//
// //把IOS的启动图片都删除掉
/// /
/// /                <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPad\FM_LaunchImagePortrait_1536x2008.png" Configuration="Release" Class="iPad_Launch1536"/>
/// /                <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPad\FM_LaunchImageLandscape_2388x1668.png" Configuration="Release" Class="iPad_Launch2388x1668">
/// /                    <Platform Name="iOSDevice64">
/// /                        <RemoteName>Default-Landscape-1668w-2388h@2x~ipad.png</RemoteName>
/// /                        <Overwrite>true</Overwrite>
/// /                    </Platform>
/// /                </DeployFile>
/// /                <DeployFile LocalName="640x1136.png" Configuration="Release" Class="iPhone_Launch640x1136">
/// /                    <Platform Name="iOSDevice64">
/// /                        <RemoteName>Default-568h@2x.png</RemoteName>
/// /                        <Overwrite>true</Overwrite>
/// /                    </Platform>
/// /                </DeployFile>
//
// for I := AXMLNode.ChildNodes.Count-1 downto 0 do
// begin
// AXMLChildNode:=AXMLNode.ChildNodes[I];
//
// if (AXMLChildNode.NodeName='DeployFile')
// and
// ((Pos('iPad_Launch',AXMLChildNode.Attributes['Class'])>0)
// or (Pos('iPhone_Launch',AXMLChildNode.Attributes['Class'])>0)) then
// begin
//
// AXMLNode.ChildNodes.Delete(I);
// end;
//
// end;
//
// Result:=True;
//
// end
// else
// begin
// DoDeployConfigLog(nil,GetLangString(['不支持此Deployment版本', 'not support this Deployment version']));
// //'不支持此Deployment版本');
// end;
// end
// else
// begin
// DoDeployConfigLog(nil,GetLangString(['不存在Deployment节点','Deployment node is not exist']));
// //'不存在Deployment节点');
// end;
// end
// else
// begin
// DoDeployConfigLog(nil,GetLangString(['不存在BorlandProject节点','BorlandProject node is not exist']));
// //'不存在BorlandProject节点');
// end;
// end
// else
// begin
// DoDeployConfigLog(nil,GetLangString(['不存在ProjectExtensions节点','ProjectExtensions node is not exist']));
// //'不存在ProjectExtensions节点');
// end;
//
//
// AXMLDocument.SaveToFile(AProjectFilePath);
// finally
// AXMLDocument.Free;
// end;
//
//
// end;

constructor TProjectConfig.Create;
begin

  FCurrentDeployFileList        := TDeployFileList.Create;
  FDeployConfigList             := TDeployConfigList.Create;
  FAndroidJarList               := TStringList.Create;
  FAndroidAarList               := TStringList.Create;
  FAndroidVariableList          := TConfigVariableList.Create;
  FAndroidUsersPermissions      := TStringList.Create;
  FAndroidApplicationChildNodes := TStringList.Create;

  FIOSPlistRootNodes := TStringList.Create;

  {$IFDEF MSWINDOWS}
  // XML要用到
  ActiveX.CoInitialize(nil);
  {$ENDIF}
end;

destructor TProjectConfig.Destroy;
begin
  {$IFDEF MSWINDOWS}
  ActiveX.CoUnInitialize();
  {$ENDIF}
  FreeAndNil(FAndroidApplicationChildNodes);
  FreeAndNil(FAndroidUsersPermissions);
  FreeAndNil(FCurrentDeployFileList);
  FreeAndNil(FDeployConfigList);
  FreeAndNil(FAndroidJarList);
  FreeAndNil(FAndroidAarList);
  FreeAndNil(FAndroidVariableList);

  FreeAndNil(FIOSPlistRootNodes);
  inherited;
end;

// function TProjectConfig.FindChildXMLNode(ANodeName: String;AXMLNode: IXMLNode): IXMLNode;
// var
// I: Integer;
// begin
// Result:=nil;
//
// for I := 0 to AXMLNode.ChildNodes.Count-1 do
// begin
// if (AXMLNode.ChildNodes[I].NodeName=ANodeName) then
// begin
// Result:=AXMLNode.ChildNodes[I];
// Break;
// end;
// end;
//
// end;

// function FindSameNameButDiffAttrNode(ANodeName: String;
// AAttrName:String;
// AAttrValue:Variant;
// AXMLNode: IXMLNode): IXMLNode;
// var
// I: Integer;
// begin
// Result:=nil;
//
// for I := 0 to AXMLNode.ChildNodes.Count-1 do
// begin
// if (AXMLNode.ChildNodes[I].NodeName=ANodeName)
// and (AXMLNode.ChildNodes[I].Attributes[AAttrName]=AAttrValue)
// then
// begin
// Result:=AXMLNode.ChildNodes[I];
// end;
// end;
//
// end;

function GenerateJarBatToProject(ATempJarDirPath: String;

  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;

  AJarFilePath: String;
  AUsedAndroidJars: TStrings;
  AJavaSourceFiles: TStrings;
  AGenJarBatFilePath: String;
  // AAndroidPackageName:String;
  ATempDexedJarFilePath: String
  ): Boolean;
var
  AJarBatList: TStringList;
begin
  AJarBatList := TStringList.Create;

  // 生成jar
  GenerateJarBatStringList(ATempJarDirPath,

    AJDKDir,
    AAndroidSDKDir,
    AAndroidSDKPlatform,
    AAndroidSDKBuildTools,

    AJarFilePath,
    AUsedAndroidJars,
    AJavaSourceFiles,

    // AAndroidPackageName,

    ATempDexedJarFilePath,
    AJarBatList
    );

  // 保存到文件
  AJarBatList.SaveToFile(AGenJarBatFilePath);

  AJarBatList.Free;

  {$IFDEF MSWINDOWS}
  ShellExecute(0, nil, PChar(AGenJarBatFilePath), nil, nil, SW_SHOWMAXIMIZED);
  {$ENDIF}

end;

function GenerateResJavaBatString(
  // R.java生成后放在哪个目录
  AGenResJavaSrcDirPath: String;
  // C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt
  AAndroidSDKAaptExeFilePath: String;
  // C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar
  AAndroidSystemJarFilePath: String;
  // res目录
  AProjectResPath: String;
  // 需要生成多少个R.java
  AAndroidManifestXmlFilePath: String;
  // //Main.Gen_R_Java.bat
  // AGenRJavaBatFilePath:String;

  var AGenR_Java_Command: String;
  AGetCommandLineOutputEvent: TGetCommandLineOutputEvent
  ): Boolean;
// {$IFDEF MSWINDOWS}
// var
// AAnsiGenR_Java_Command:AnsiString;
// {$ENDIF MSWINDOWS}
begin
  Result := False;





  // //生成bat
  // Result:=TStringList.Create;





  // C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt.exe
  // package -f -m

  // 生成R.java的路径
  // -J E:\test

  // 根据res目录来生成,后面不能有\,不然生成不了
  // -S res

  // 所需要引用的android.jar
  // -I C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar

  // 根据这个项目的程序清单文件
  // -M AndroidManifest.xml







  // 对应每个aar也要生成R.java
  // AGenR_JavaBatList.Add('CD '+ExtractFilePath(AAndroidManifestXmlFilePath));
  // AGenR_JavaBatList.Add(Copy(AAndroidManifestXmlFilePath,1,2));


  // ABatStringList.Add('ECHO AGenResJavaSrcDirPath '+AGenResJavaSrcDirPath);
  // ABatStringList.Add('ECHO AProjectResPath '+AProjectResPath);
  // ABatStringList.Add('ECHO AAndroidManifestXmlFilePath '+AAndroidManifestXmlFilePath);

  {$IFDEF MSWINDOWS}
  AGenR_Java_Command :=
    '"' + AAndroidSDKAaptExeFilePath + '"'
    + ' ' + 'package -f -m'
  // 生成的源码目录
    + ' ' + '-J ' + '"' + AGenResJavaSrcDirPath + '"'
  // 资源目录
    + ' ' + '-S ' + '"' + AProjectResPath + '"'
  // 所使用的系统jar
    + ' ' + '-I ' + '"' + AAndroidSystemJarFilePath + '"'
  // +' '+'-M '+'"'+'AndroidManifest.xml'+'"'
  // AndroidManifest.xml路径,主要使用了里面的包名
    + ' ' + '-M ' + '"' + AAndroidManifestXmlFilePath + '"'
  // +#13#10
  // +'PAUSE'
    ;
  // 立即执行
  // ShellExecute不立即生成
  // ShellExecute(0, nil, PChar(AGenR_Java_Command), nil, nil, SW_SHOWMAXIMIZED);

  // //WinExec立即生成
  // AAnsiGenR_Java_Command:=AGenR_Java_Command;
  // WinExec(PAnsiChar(AAnsiGenR_Java_Command),SW_SHOWMAXIMIZED);
  uCommandLineHelper.ExecuteCommand(AGenR_Java_Command, 'C:\', '生成R.java',
    AGetCommandLineOutputEvent);

  {$ENDIF MSWINDOWS}

  // ABatStringList.Add(AGenR_Java_Command);
  //
  // //调试
  /// /  ABatStringList.Add('pause');
  // ABatStringList.Add('');
  // ABatStringList.Add('');
  // ABatStringList.Add('');
  // ABatStringList.Add('');





  // //保存到文件
  // Result.SaveToFile(AGenRJavaBatFilePath);
  //
  // Result.Free;
  //
  // //运行
  // ShellExecute(0, nil, PChar(AGenRJavaBatFilePath), nil, nil, SW_SHOWMAXIMIZED);

  Result := True;
end;

function GenerateWeiXinJarBatToProject(AJarGenRootDir: String;
  ATempJarDir: String;
  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;
  AJarFilePath: String;
  AUsedAndroidJars: TStrings;

  AAndroidPackage: String;
  AWXEntryActivityLines: TStrings;
  AWXPayEntryActivityLines: TStrings;
  AOnWeixinListenerLines: TStrings;
  AWxApiPasLines: TStrings): Boolean;
var
  // AJarGenRootDir:String;
  // ATempJarDir:String;
  AJavaSources:       TStringList;
  AJavaSourceDir:     String;
  AWxJavaSourceFiles: TStringList;
begin
  // //因为需要计算出相对目录
  // if (AProjectFilePath='') then
  // begin
  // DoDeployConfigLog(nil,'请选择工程文件');
  // Exit;
  // end;
  //
  // if Not FileExists(AProjectFilePath) then
  // begin
  // DoDeployConfigLog(nil,'工程文件不存在');
  // Exit;
  // end;
  //
  //
  //
  // //先创建临时文件夹Temp
  // //先创建临时文件夹Temp,以aar为命名
  // //ProjectFilePath\JarGen\Main_R_Java\
  // AJarGenRootDir:=ExtractFilePath(AProjectFilePath)+CONST_JAR_TEMP_DIR+'\';
  /// /  AJarGenRootDir:=ExtractFilePath(AProjectFilePath)+'WeiXinSDK'+'\';
  //
  // ATempJarDir:=AJarGenRootDir+'wxapi'+'\';

  ForceDirectories(AJarGenRootDir);
  AJavaSourceDir := ATempJarDir
    + 'src' + '\'
    + ReplaceStr(AAndroidPackage, '.', '\') + '\'
    + 'wxapi' + '\';
  ForceDirectories(AJavaSourceDir);

  AWxJavaSourceFiles := TStringList.Create;
  AJavaSources       := TStringList.Create;
  try
    AJavaSources.Clear;
    AJavaSources.Assign(AWXEntryActivityLines);
    ReplaceStringList('com.ggggcexx.orangeui', AAndroidPackage, AJavaSources);
    AJavaSources.SaveToFile(AJavaSourceDir + 'WXEntryActivity.java');

    AJavaSources.Clear;
    AJavaSources.Assign(AWXPayEntryActivityLines);
    ReplaceStringList('com.ggggcexx.orangeui', AAndroidPackage, AJavaSources);
    AJavaSources.SaveToFile(AJavaSourceDir + 'WXPayEntryActivity.java');

    AJavaSources.Clear;
    AJavaSources.Assign(AOnWeixinListenerLines);
    ReplaceStringList('com.ggggcexx.orangeui', AAndroidPackage, AJavaSources);
    AJavaSources.SaveToFile(AJavaSourceDir + 'OnWeixinListener.java');

    // JNI单元
    AJavaSources.Clear;
    AJavaSources.Assign(AWxApiPasLines);
    ReplaceStringList('com.ggggcexx.orangeui', AAndroidPackage, AJavaSources);
    ReplaceStringList('com/ggggcexx/orangeui', ReplaceStr(AAndroidPackage, '.',
      '/'), AJavaSources);
    AJavaSources.SaveToFile(ATempJarDir + 'Androidapi.JNI.wxapi.pas');

    // 要编译这些源文件
    AWxJavaSourceFiles.Add(AJavaSourceDir + '*.java');

    // 生成微信jar
    GenerateJarBatToProject(
      ATempJarDir,

      AJDKDir,
      AAndroidSDKDir,
      AAndroidSDKPlatform,
      AAndroidSDKBuildTools,

      AJarFilePath,
      AUsedAndroidJars,
      AWxJavaSourceFiles,
      AJarGenRootDir + 'Gen_Jar_' + 'wxapi' + '.bat' // ,
      // AAndroidPackage
      );

  finally
    AJavaSources.Free;
    AWxJavaSourceFiles.Free;
  end;

end;

function TProjectConfig.FindDeployFilePlatformXMLNode(APlatform: String;
  ADeployFileXMLNode: IXMLNode): IXMLNode;
var
  I: Integer;
begin
  Result := nil;


  // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
  // <Platform Name="Android">
  // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
  // <RemoteName>libTbDemuxer.so</RemoteName>
  // <Overwrite>true</Overwrite>

  for I := 0 to ADeployFileXMLNode.ChildNodes.Count - 1 do
  begin
    // <Platform Name="Android">
    if (ADeployFileXMLNode.ChildNodes[I].NodeName = 'Platform')
      and (ADeployFileXMLNode.ChildNodes[I].Attributes['Name'] = APlatform) then
    begin
      Result := ADeployFileXMLNode.ChildNodes[I];
      Break;
    end;
  end;

end;

function TProjectConfig.FindDeployFileXMLNode(ADeployFile: TDeployFile;
  AXMLNode: IXMLNode;
  // 文件布署节点下面的子平台节点
  // var ADeployFilePlatformXMLNode:IXMLNode;
  // 大的文件布署节点
  // var AEnabledDeployFileXMLNode:IXMLNode;
  AExistsLocalNameList: TStringList;
  // 是否少了一些平台没有布署
  var AIsLostSomePlatform: Boolean): IXMLNode;
var
  I:                  Integer;
  J:                  Integer;
  ADeployFileXMLNode: IXMLNode;

  ATempDeployFilePlatformXMLNode: IXMLNode;

  ARemoteDirNode:  IXMLNode;
  ARemoteNameNode: IXMLNode;
  AEnabledNode:    IXMLNode;
  ARemoteDir:      String;
  ARemoteName:     String;
  AEnabled:        String;
begin

  // 列出所有DeployFile
  // 要根据远程目录来判断RemoteDir+RemoteName
  Result := nil;
  // ADeployFilePlatformXMLNode:=nil;
  // AEnabledDeployFileXMLNode:=nil;
  AIsLostSomePlatform := False;
  AExistsLocalNameList.Clear;

  // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so"
  // Configuration="Release"
  // Class="File">
  // <Platform Name="Android">
  // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
  // <RemoteName>libTbDemuxer.so</RemoteName>
  // <Overwrite>true</Overwrite>
  for I := 0 to AXMLNode.ChildNodes.Count - 1 do
  begin

    // 必须要DeployFile的节点才可以
    if (AXMLNode.ChildNodes[I].NodeName = 'DeployFile') then
    begin

      ADeployFileXMLNode := AXMLNode.ChildNodes[I];

      // 方法一:
      // 如果存在LocalName一致的节点,那么直接返回
      if (ADeployFile.LocalName = AXMLNode.ChildNodes[I].Attributes['LocalName'])
        or ('\' + ADeployFile.LocalName = '\' + AXMLNode.ChildNodes[I]
        .Attributes['LocalName'])
      then
      begin
        // Inc(ASameCount);
        Result := AXMLNode.ChildNodes[I];
        // Break;
      end
      else
      begin
        continue;
      end;





      // 方法二:
      // 判断一下是否远程目录相同
      // 如果相同,那么是同一个文件

      // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
      // <Platform Name="Android">
      // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
      // <RemoteName>libTbDemuxer.so</RemoteName>
      // <Overwrite>true</Overwrite>

      for J := 0 to ADeployFile.Platforms.Count - 1 do
      begin
        // 找到当前平台的<Platform>布署结点,如下:
        // <Platform Name="Android">
        // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
        // <RemoteName>libTbDemuxer.so</RemoteName>
        // <Overwrite>true</Overwrite>
        ATempDeployFilePlatformXMLNode :=
          FindDeployFilePlatformXMLNode(ADeployFile.Platforms[J].Platform_,
          ADeployFileXMLNode);

        if ATempDeployFilePlatformXMLNode <> nil then
        begin
          // 有这个平台的节点

          ARemoteDir  := '';
          ARemoteName := '';
          AEnabled    := 'true';

          // 远程路径
          ARemoteDirNode := ATempDeployFilePlatformXMLNode.ChildNodes.FindNode
            ('RemoteDir');
          if ARemoteDirNode <> nil then
          begin
            ARemoteDir := ARemoteDirNode.Text;
          end;

          // 远程文件名
          ARemoteNameNode := ATempDeployFilePlatformXMLNode.ChildNodes.FindNode
            ('RemoteName');
          if ARemoteNameNode <> nil then
          begin
            ARemoteName := ARemoteNameNode.Text;
          end;

          // 是否启用
          AEnabledNode := ATempDeployFilePlatformXMLNode.ChildNodes.FindNode
            ('Enabled');
          if AEnabledNode <> nil then
          begin
            AEnabled := AEnabledNode.Text;
          end;

          // ADeployFile在XML中已经存在
          // '.\res\values\'='res\values\'
          if (ARemoteDir = ADeployFile.Platforms[J].RemoteDir)
            and (ARemoteName = ADeployFile.Platforms[J].RemoteName) then
          begin
            Result := ADeployFileXMLNode;
            // ADeployFilePlatformXMLNode:=ATempDeployFilePlatformXMLNode;

            AExistsLocalNameList.Add(ADeployFileXMLNode.Attributes
              ['LocalName']);


            // //启用的布署项才行
            // if SameText(AEnabled,'true') then
            // begin
            // if AEnabledDeployFileXMLNode=nil then
            // begin
            // AEnabledDeployFileXMLNode:=ADeployFileXMLNode;
            // end
            // else
            // begin
            // //已经有启用的,那么这个不再启用
            // if AEnabledNode=nil then
            // begin
            // AEnabledNode:=ATempDeployFilePlatformXMLNode.AddChild('Enabled');
            // end;
            // AEnabledNode.Text:='false';
            //
            // end;
            // end;

            // Break;
          end;

        end
        else
        begin
          // 没有这个平台的布署节点,则需要添加
          AIsLostSomePlatform := True;

        end;

      end;

      Break;
    end;

  end;

end;

function FileNameIsExists(AFileName: String;
  AFilePathList: TStringList): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to AFilePathList.Count - 1 do
  begin
    if Pos(AFileName, ExtractFileName(AFilePathList[I])) > 0 then
    begin
      // AFilePathList.Delete(I);
      Result := I;
      Break;
    end;
  end;

end;

function FileContentIsExistsInFile(AFileContent: String;
  AFileContentList: TStringList): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to AFileContentList.Count - 1 do
  begin
    if Pos(AFileContent, AFileContentList[I]) > 0 then
    begin
      // AFilePathList.Delete(I);
      Result := True;
      Exit;
    end;
  end;

end;

function FileContentIsExistsInFileList(AFileContent: String;
  AFilePathList: TStringList): Boolean;
var
  I:                Integer;
  AFileContentList: TStringList;
begin
  Result := False;

  for I := 0 to AFilePathList.Count - 1 do
  begin
    AFileContentList := TStringList.Create;
    try
      AFileContentList.LoadFromFile(AFilePathList[I]);
      if FileContentIsExistsInFile(AFileContent, AFileContentList) then
      begin
        Result := True;
        Exit;
      end;
    finally
      AFileContentList.Free;
    end;

  end;

end;

procedure TProjectConfig.RemoveNoUseResource(RTextFileName,
  RJavaFileName: string; NewRJavaFileName: string = '');
var
  lstResource: TStringList;
  lstText:     TStringList;
  lstJava:     TStringList;
  lstNew:      TStringList;
  lstTmp:      TStringList;

  I:            Integer;
  strLine:      string;
  strClassName: string;
  strKeyName:   string;
  AEncoding:    TEncoding;

  AFilePathList: TStringList;
  AIsExists:     Boolean;
begin
  AEncoding := TMBCSEncoding.Create(936);

  if NewRJavaFileName = '' then
    NewRJavaFileName := RJavaFileName;

  // C:\OrangeFreeSDK\Android图片视频选择器DVMediaSelector_V1_0_0\Support_V4\coordinatorlayout-28.0.0_aar\R.txt
  if not FileExists(RTextFileName) then
    raise Exception.Create('文件' + RTextFileName + '找不到!');

  // C:\OrangeFreeSDK\Android图片视频选择器DVMediaSelector_V1_0_0\OrangeSDK_JarGen\TestDVMediaSelector\src\android\support\coordinatorlayout\R.java
  if not FileExists(RJavaFileName) then
    raise Exception.Create('文件' + RJavaFileName + '找不到!');

  AFilePathList := TStringList.Create;

  lstText := TStringList.Create;
  lstText.LoadFromFile(RTextFileName);
  lstJava := TStringList.Create;
  lstJava.LoadFromFile(RJavaFileName, AEncoding);
  lstResource := TStringList.Create;
  lstNew      := TStringList.Create;

  DoGetFileList(ExtractFilePath(RTextFileName), AFilePathList);
  // 去掉R.txt
  I := FileNameIsExists('R.txt', AFilePathList);
  if I <> -1 then
  begin
    AFilePathList.Delete(I);
  end;

  // 先提取资源ID Key
  lstTmp := TStringList.Create;

  try

    for I := 0 to lstText.Count - 1 do
    begin
      strLine          := lstText.Strings[I];
      strLine          := StringReplace(strLine, ' ', ',', [rfReplaceAll]);
      lstTmp.CommaText := strLine;
      lstResource.Add(lstTmp[1] + '-' + lstTmp[2]); // 要第2和第3栏
    end;

    //
    I := 0;
    while I <= lstJava.Count - 1 do
    begin
      strLine := lstJava.Strings[I];

      if Pos('/*', strLine) > 0 then // 备注行
      begin
        lstNew.Add(strLine);

        // 一直找下一行的 */
        I       := I + 1;
        strLine := lstJava.Strings[I];
        while (Pos('*/', strLine) <= 0) and (I < lstJava.Count - 1) do
        begin
          lstNew.Add(strLine);

          I       := I + 1;
          strLine := lstJava.Strings[I];
        end;
        lstNew.Add(strLine);

        I       := I + 1;
        strLine := lstJava.Strings[I];
      end;

      if Pos('public static final class', strLine) > 0 then
      begin
        lstNew.Add(strLine);
        strClassName :=
          Trim(StringReplace(strLine, 'public static final class', '', []));
        strClassName := Trim(StringReplace(strClassName, '{', '', []));

        I       := I + 1;
        strLine := lstJava.Strings[I];
        while (Trim(strLine) <> '}') and (Trim(strLine) <> '};') and
          (I <= lstJava.Count - 1) do // 一直找到下一个 }
        begin

          if Pos('public static final ', strLine) > 0 then
          begin
            strKeyName :=
              Trim(StringReplace(strLine, 'public static final ', '', []));
            strKeyName := Copy(strKeyName, Pos(' ', strKeyName) + 1, 255);
            strKeyName := Trim(Copy(strKeyName, 1, Pos('=', strKeyName) - 1));

            if lstResource.IndexOf(strClassName + '-' + strKeyName) > -1 then
            begin
              // 找到就加进去
              // 判断这个资源是否在res文件和文件内容中

              AIsExists := False;

              AIsExists := True;
              if (Pos('Compat_V7', RTextFileName) = 0)
                and (Pos('Lifecycle', RTextFileName) = 0)
                and (Pos('Support_V4', RTextFileName) = 0) then
              begin

                if FileNameIsExists(strKeyName, AFilePathList) <> -1 then
                begin
                  // 存在这个文件,则需要添加
                  AIsExists := True;
                end
                else
                  // OutputDebugString(strKeyName);
                  // 判断是否在文内容中
                  if FileContentIsExistsInFileList(strKeyName, AFilePathList)
                  then
                  begin
                    AIsExists := True;
                  end
                  else if (Pos('_', strKeyName) > 0) then
                  begin
                    // public static final int RatioImageView_ratio = 0;
                    // <declare-styleable name="RatioImageView"><attr format="float" name="ratio"/></declare-styleable>
                    AIsExists := True;

                  end;

              end
              else
              begin
                AIsExists := True;
              end;

              if AIsExists then
              begin
                lstNew.Add(strLine);
              end
              else
              begin
                // @Deprecated
                // 如果不存在,则要去掉前一行的@Deprecated
                if Trim(lstNew[lstNew.Count - 1]) = '@Deprecated' then
                begin
                  lstNew[lstNew.Count - 1] := '//' + lstNew[lstNew.Count - 1];
                end;

                OutputDebugString(RJavaFileName + ' Removed ' + strLine);
              end;

              // public static final int[] CoordinatorLayout = {
              // 0x7f010103, 0x7f010104
              // };
              if Pos('[]', strLine) > 0 then // 是数组一直加到 '}'
              begin
                I       := I + 1;
                strLine := lstJava.Strings[I];
                while (Pos('}', strLine) <= 0) and (I <= lstJava.Count - 1) do
                begin
                  if AIsExists then
                    lstNew.Add(strLine);
                  I       := I + 1;
                  strLine := lstJava.Strings[I];
                end;

                if Pos('}', strLine) > 0 then
                begin
                  if AIsExists then
                    lstNew.Add(strLine);
                end;
              end;

            end
            else
            begin
              // 在RText中资源找不到
              if Pos('[]', strLine) > 0 then // 是数组  一直到 '}' 都不要
              begin
                I       := I + 1;
                strLine := lstJava.Strings[I];
                while (Pos('}', strLine) <= 0) and (I <= lstJava.Count - 1) do
                begin
                  I       := I + 1;
                  strLine := lstJava.Strings[I];
                end;
              end;

              // 删除上一行的注解
              if Copy(Trim(lstNew.Strings[lstNew.Count - 1]), 1, 1) = '@' then
              begin
                lstNew.Delete(lstNew.Count - 1);
              end;

            end;
          end
          else
          begin
            lstNew.Add(strLine); // 不是 'public static final ' 行
          end;
          I       := I + 1;
          strLine := lstJava.Strings[I];

        end;

        if (Trim(strLine) = '}') or (Trim(strLine) = '};') then
        begin
          lstNew.Add(strLine);
          I := I + 1;
        end;

      end
      else
      begin
        lstNew.Add(strLine);
        I := I + 1;
      end;

    end;

    lstNew.SaveToFile(NewRJavaFileName, AEncoding);
    // Form

  finally
    lstText.Free;
    lstJava.Free;
    lstResource.Free;
    lstNew.Free;
    lstTmp.Free;
    AEncoding.Free;

    AFilePathList.Free;
  end;

end;

function TProjectConfig.GenerateJar(AProjectFilePath: String;
  // WeixinSDK
  AGeneratedJarDir: String;
  // Jar源码目录,JarSource
  AJarSourceCodeDir: String;
  // jar中的包名com.ggggcexx.orangeui.wxapi
  AGeneratedJarPackage: String;
  AAndroidPackage: String;
  // wxapi.jar
  AGeneratedJarFileName: String;
  AUsedAndroidJars: TStrings;

  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String
  ): Boolean;
var
  AJarGenRootDir:          String;
  AGeneratedJavaSourceDir: String;
  AJarSouceFileList:       TStringList;
  I:                       Integer;
  AJavaSources:            TStringList;

begin
  Result := False;

  AJarSouceFileList := TStringList.Create;
  AJavaSources      := TStringList.Create;

  AJarGenRootDir := ExtractFilePath(AProjectFilePath) + AGeneratedJarDir + '\';

  // 生成jar源码目录
  ForceDirectories(AJarGenRootDir);
  AGeneratedJavaSourceDir := AJarGenRootDir
    + 'src' + '\'
    + ReplaceStr(AGeneratedJarPackage, '.', '\') + '\';
  ForceDirectories(AGeneratedJavaSourceDir);

  // 读取jar源码文件列表
  // 将源码拷到生成目录
  DoGetFileList(AJarGenRootDir + AJarSourceCodeDir, AJarSouceFileList);
  for I := 0 to AJarSouceFileList.Count - 1 do
  begin
    {$IFDEF MSWINDOWS}
    CopyFile(PWideChar(AJarSouceFileList[I]),
      PWideChar(AGeneratedJavaSourceDir + ExtractFileName(AJarSouceFileList[I]
      )), False);
    {$ENDIF}
  end;

  // 读取生成目录的jar源码文件列表
  // 替换包名
  AJarSouceFileList.Clear;
  DoGetFileList(AGeneratedJavaSourceDir, AJarSouceFileList);
  for I := 0 to AJarSouceFileList.Count - 1 do
  begin
    AJavaSources.Clear;
    AJavaSources.LoadFromFile(AJarSouceFileList[I]);
    ReplaceStringList('com.ggggcexx.orangeui', AAndroidPackage, AJavaSources);
    AJavaSources.SaveToFile(AJarSouceFileList[I]);
  end;

  AJarSouceFileList.Clear;
  AJarSouceFileList.Add(AGeneratedJavaSourceDir + '*.java');

  // 生成微信jar
  GenerateJarBatToProject(
    AJarGenRootDir,

    AJDKDir,
    AAndroidSDKDir,
    AAndroidSDKPlatform,
    AAndroidSDKBuildTools,

    AJarGenRootDir + AGeneratedJarFileName,

    // %ANDROID_PLATFORM%\android.jar
    AUsedAndroidJars,

    AJarSouceFileList,
    AJarGenRootDir + AGeneratedJarFileName + '.bat' // ,
    // AAndroidPackage
    );

  AJarSouceFileList.Free;
  AJavaSources.Free;
end;


// procedure TProjectConfig.GenerateR_Java_And_Jar_Bat_List(AJarGenRootDir:String;
// AProjectResPath:String;
// AAndroidManifestXmlFilePaths:TStringList;
// AGenJarFileNamesNoExt:TStringList
// );
// var
// I:Integer;
// ATempJarDir:String;
// AGenResJavaSrcDirPath:String;
// AJavaSourceFiles:TStringList;
//
// AAndroidSDKAaptExeFilePath:String;
// AAndroidSystemJarFilePath:String;
// begin
// for I := 0 to AAndroidManifestXmlFilePaths.Count-1 do
// begin
//
// //先创建临时文件夹Temp,以aar为命名
// //ProjectFilePath\JarGen\Main_R_Java\
// ATempJarDir:=AJarGenRootDir+AGenJarFileNamesNoExt[I]+'\';
//
//
// //ProjectFilePath\JarGen\Main_R_Java\main\src
// //src后面不能有\,不然生成不了
// AGenResJavaSrcDirPath:=ATempJarDir+'src';
//
//
// ForceDirectories(AJarGenRootDir);
// ForceDirectories(ATempJarDir);
// ForceDirectories(AGenResJavaSrcDirPath+'\');
//
//
// //生成R.java的批处理文件
// GenerateResJavaBat( //R.java文件要生成在哪个目录
//
// //E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\JarGen\TwitterLogin\src
// AGenResJavaSrcDirPath,
//
//
/// /                          'C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt.exe',
// Self.edtAndroidSDKBuildTools.Text+'\'+'aapt.exe',
/// /                          'C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar',
// Self.edtAndroidSDKPlatform.Text+'\'+'android.jar',
//
//
// //E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\Android\Release\TwitterLogin\res
// //要编译的res目录
// AProjectResPath,
//
// //E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\Android\Release\TwitterLogin\AndroidManifest.xml
// //要编译的AndroidManifest.xml中路径
// AAndroidManifestXmlFilePaths[I],
//
// //生成R.Java的.bat文件路径
// AJarGenRootDir+'1.Gen_R_Java_'+AGenJarFileNamesNoExt[I]+'.bat'
// );
//
//
//
// //等待R.java生成
// Sleep(3000);
//
//
//
// AJavaSourceFiles:=TStringList.Create;
// //遍历有哪些Java源文件需要编译
// DoGetFileList(AGenResJavaSrcDirPath,AJavaSourceFiles);
// //打包成Jar
// GenerateJarBatToProject(
// //E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\JarGen\TwitterLogin\
// ATempJarDir,
//
//
// //C:\Program Files\Java\jdk1.8.0_151
// Self.edtJDKDir.Text,
// //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows
// Self.edtAndroidSDKDir.Text,
// //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22
// Self.edtAndroidSDKPlatform.Text,
// //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1
// Self.edtAndroidSDKBuildTools.Text,
//
//
// //生成的jar文件名
// 'R_JAVA_'+AGenJarFileNamesNoExt[I]+'.jar',
// nil,
// //java源文件
// AJavaSourceFiles,
//
//
// //生成的.bat文件路径
// AJarGenRootDir+'2.Gen_R_Jar_'+AGenJarFileNamesNoExt[I]+'.bat',
// //com.embarcadero.TwitterLogin
// GetAndroidPackageName(AAndroidManifestXmlFilePaths[I]),
//
// ExtractFilePath(AAndroidManifestXmlFilePaths[I])
// +'..\'
// +'R_JAVA_'+AGenJarFileNamesNoExt[I]+'-dexed'+'.jar'
//
// );
//
//
// AJavaSourceFiles.Free;
//
// end;
//
// end;

function TProjectConfig.GenerateR_Java(AGenJarFileNameNoExt: String;
  AJarGenRootDir: String;
  AProjectResPath: String;
  AAndroidManifestXmlFilePath: String;
  // AGenJarFileNameNoExt:String;
  AJDKDir: String;
  AAndroidSDKDir: String;
  AAndroidSDKPlatform: String;
  AAndroidSDKBuildTools: String;

  // ABatStringList:TStringList;
  var AR_JAVA_FilePath: String;
  AGetCommandLineOutputEvent: TGetCommandLineOutputEvent
  ): Boolean;
var
  I:                     Integer;
  ATempJarDir:           String;
  AGenResJavaSrcDirPath: String;
  // AJavaSourceFiles:TStringList;
  //
  // AAndroidSDKAaptExeFilePath:String;
  // AAndroidSystemJarFilePath:String;

  AGenR_Java_Command: String;
  AR_TXT_FilePath:    String;

  AR_JAVA_FilePath1: String;

  // ARetryCount:Integer;
begin
  Result := False;




  // AJarGenRootDir为ProjectFilePath\JarGen\Project1\

  // 先创建临时文件夹Temp,以aar为命名
  // ProjectFilePath\JarGen\Project1\  +  jar包名Project1\
  ATempJarDir := AJarGenRootDir; // +AGenJarFileNameNoExt+'\';

  // ProjectFilePath\JarGen\Project1\Project1\    src
  // src后面不能有\,不然生成不了
  AGenResJavaSrcDirPath := ATempJarDir + 'src';

  ForceDirectories(AJarGenRootDir);
  ForceDirectories(ATempJarDir);
  ForceDirectories(AGenResJavaSrcDirPath + '\');

  // 判断aar中是否存在R.txt,如果存在,那么要去除R.java中多余的资源ID
  AR_TXT_FilePath  := ExtractFilePath(AAndroidManifestXmlFilePath) + 'R.txt';
  AR_JAVA_FilePath := AGenResJavaSrcDirPath + '\' +
    ReplaceStr(GetAndroidPackageName(AAndroidManifestXmlFilePath), '.', '\') +
    '\R.java';
  AR_JAVA_FilePath1 := AR_JAVA_FilePath;
  // AGenResJavaSrcDirPath+'\'+ReplaceStr(GetAndroidPackageName(AAndroidManifestXmlFilePath),'.','\')+'\R1.java';
  if FileExists(AR_JAVA_FilePath) then
  begin
    DeleteFile(AR_JAVA_FilePath);
  end;

  // 生成R.java源码的批处理文件
  GenerateResJavaBatString(

    // 准备生成的jar源码的目录
    // E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\JarGen\TwitterLogin\src
    AGenResJavaSrcDirPath,

    // aapt.exe路径
    // 'C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1\aapt.exe',
    // Self.edtAndroidSDKBuildTools.Text+'\'+'aapt.exe',
    // AAndroidSDKBuildTools+'\'+'aapt.exe',
    AAndroidSDKBuildTools + 'aapt.exe',
    // Android系统jar包android.jar路径
    // 'C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22\android.jar',
    // Self.edtAndroidSDKPlatform.Text+'\'+'android.jar',
    // AAndroidSDKPlatform+'\'+'android.jar',
    AAndroidSDKPlatform + '\' + 'android.jar',

    // 工程的res生成目录
    // E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\Android\Release\TwitterLogin\res
    // 要编译的res目录
    AProjectResPath,

    // E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\Android\Release\TwitterLogin\AndroidManifest.xml
    // 要编译的AndroidManifest.xml中路径
    AAndroidManifestXmlFilePath,



    // //生成R.Java的.bat文件路径
    // AJarGenRootDir+'1.Gen_R_Java_'+AGenJarFileNameNoExt+'.bat',

    AGenR_Java_Command, // ABatStringList
    AGetCommandLineOutputEvent
    );





  // ABatStringList.Add(AGenR_Java_Command);



  // //等待R.java生成
  // Sleep(3000);




  // 判断是否生成成功

  // ARetryCount:=10;
  if FileExists(AR_TXT_FilePath) then
  begin
    // //等R.Java生成好
    // while not FileExists(AR_JAVA_FilePath) and (ARetryCount>0) do
    // begin
    // Application.ProcessMessages;
    // Sleep(1000);
    // Dec(ARetryCount);
    // end;
    // Sleep(3000);

    if // (ARetryCount<=0) or
      not FileExists(AR_JAVA_FilePath) then
    begin
      HandleException(nil, AGenJarFileNameNoExt + ':' + 'R.java生成失败' +
        AAndroidManifestXmlFilePath);
      AGetCommandLineOutputEvent('', AGenJarFileNameNoExt,
        '准备根据aar包中的R.txt去除R.java中的重复资源定义');
      ShowMessage(AGenJarFileNameNoExt + ':' + 'R.java生成失败' +
        AAndroidManifestXmlFilePath);
      Exit;
    end;

    // 去除多余的资源ID
    if FileExists(AR_JAVA_FilePath) then
    begin
      // if Assigned(AGetCommandLineOutputEvent) then
      // begin
      HandleException(nil, AGenJarFileNameNoExt + ':' +
        '准备根据aar包中的R.txt去除R.java中的重复资源定义');
      AGetCommandLineOutputEvent('', AGenJarFileNameNoExt,
        '准备根据aar包中的R.txt去除R.java中的重复资源定义');
      // end;

      RemoveNoUseResource(AR_TXT_FilePath, AR_JAVA_FilePath, AR_JAVA_FilePath1);

      // if Assigned(AGetCommandLineOutputEvent) then
      // begin
      HandleException(nil, AGenJarFileNameNoExt + ':' +
        '根据aar包中的R.txt去除R.java中的重复资源定义完成');
      AGetCommandLineOutputEvent('', AGenJarFileNameNoExt,
        '根据aar包中的R.txt去除R.java中的重复资源定义完成');
      // end;
    end;

  end;










  // AJavaSourceFiles:=TStringList.Create;
  //
  //
  //
  //
  // //遍历有哪些Java源文件需要编译
  // //C:\MyFiles\ThirdPartySDK\Android的ZBar二维码扫描me_dm7_barcodescanner\JarGen\Project1\src\
  // //加上包名com\embarcadero\Project1
  // //加上\R.java
  // //DoGetFileList(AGenResJavaSrcDirPath,AJavaSourceFiles);
  // //bat不执行了,所以要自已生成了
  // AJavaSourceFiles.Add(AGenResJavaSrcDirPath+'\'
  // +ReplaceStr(GetAndroidPackageName(AAndroidManifestXmlFilePath),'.','\')
  // +'\R.java');
  //
  //
  //
  //
  //
  // //将jar源码打包成Jar
  // //只生成批处理,不执行
  // GenerateJarBatStringList(
  // //E:\MyFiles\ThirdPartySDK\Twitter接口\Twitter_Core\JarGen\TwitterLogin\
  // ATempJarDir,
  //
  //
  // //生成Jar所需要的Android SDK配置
  // //C:\Program Files\Java\jdk1.8.0_151
  /// /                              Self.edtJDKDir.Text,
  // AJDKDir,
  // //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows
  /// /                              Self.edtAndroidSDKDir.Text,
  // AAndroidSDKDir,
  // //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\platforms\android-22
  /// /                              ASelf.edtAndroidSDKPlatform.Text,
  // AAndroidSDKPlatform,
  // //C:\Users\Public\Documents\Embarcadero\Studio\17.0\PlatformSDKs\android-sdk-windows\build-tools\22.0.1
  /// /                              Self.edtAndroidSDKBuildTools.Text,
  // AAndroidSDKBuildTools,
  //
  //
  // //生成的jar文件名,生成在哪个路径呢?
  /// /                              '..\'+
  // 'R_JAVA_'+AGenJarFileNameNoExt+'.jar',
  //
  //
  // //编译所需要引用的jar
  // nil,
  // //java源文件列表
  // AJavaSourceFiles,
  //
  //
  /// /                              //生成的.bat文件路径
  /// /                              AJarGenRootDir+'2.Gen_R_Jar_'+AGenJarFileNameNoExt+'.bat',
  //
  //
  // //Jar的包名
  // //com.embarcadero.TwitterLogin
  // GetAndroidPackageName(AAndroidManifestXmlFilePath),
  //
  // //需要删除的临时文件
  // ExtractFilePath(AAndroidManifestXmlFilePath)
  // +'..\'
  // +'R_JAVA_'+AGenJarFileNameNoExt+'-dexed'+'.jar',
  //
  // ABatStringList
  //
  // );
  //
  //
  //
  //
  //
  // AJavaSourceFiles.Free;

  Result := True;

end;

function TProjectConfig.GetAndroidSDKSetting(ADelphiVersion: String; var AJDKDir,
  AAndroidSDKDir, AAndroidSDKPlatform, AAndroidSDKBuildTools: String): Boolean;
{$IFDEF MSWINDOWS}
var
  I:    Integer;
  AKey: String;
  // APathCount:Integer;
  AReg: TRegistry;
  // AIsExists:Boolean;
  ATempStr:       String;
  AKeyStringList: TStringList;
  {$ENDIF}
begin
  Result := False;

  {$IFDEF MSWINDOWS}
  // 设置注册表
  AReg           := TRegistry.Create;
  AKeyStringList := TStringList.Create;
  try
    AReg.RootKey := HKEY_CURRENT_USER;

    AKey := '\Software\Embarcadero\BDS\' + ADelphiVersion + '\' +
      'PlatformSDKs' + '\';

    // 找到AndroidSDK
    if AReg.OpenKey(AKey, False) then
    begin
      ATempStr := AReg.ReadString('Default_Android');

      if ATempStr <> '' then
      begin
        if AReg.OpenKey(AKey + ATempStr, False) then
        begin

          // C:\Program Files\Java\jdk1.8.0_202\bin\KeyTool.exe

          AJDKDir := AReg.ReadString('JDKKeyToolPath');
          AJDKDir := ExtractFilePath(AJDKDir);
          AJDKDir := AJDKDir.Substring(0, AJDKDir.Length - 1);
          AJDKDir := ExtractFilePath(AJDKDir);
          AJDKDir := AJDKDir.Substring(0, AJDKDir.Length - 1);

          AAndroidSDKDir        := AReg.ReadString('SystemRoot');
          AAndroidSDKPlatform   := AReg.ReadString('SDKApiLevelPath');
          AAndroidSDKBuildTools :=
            ExtractFilePath(AReg.ReadString('SDKAaptPath'));

          if DirectoryExists(AJDKDir)
            or DirectoryExists(AAndroidSDKDir)
            or DirectoryExists(AAndroidSDKPlatform)
            or DirectoryExists(AAndroidSDKBuildTools)
          then
          begin
            Result := True;
          end;

        end;
      end;

    end
    else
    begin
      DoDeployConfigLog(nil, 'AddLibraryToIOSSDK Open key "' + AKey +
        '" fail!');
      Exit;
    end;


    // AIsExists:=False;
    // if AReg.ValueExists('PathCount') then
    // begin
    // try
    // APathCount:=AReg.ReadInteger('PathCount');
    //
    //
    // AReg.GetValueNames(AKeyStringList);
    // for I := 0 to AKeyStringList.Count-1 do
    // begin
    // if Copy(AKeyStringList[I],1,4)='Mask' then
    // begin
    //
    // ATempStr:=Copy(AKeyStringList[I],5,MaxInt);
    //
    // //取出值,比对是否存在
    // if AReg.ReadString(AKeyStringList[I])=APathName then
    // begin
    // //已经存在,不用添加了
    // AIsExists:=True;
    // Break;
    // end;
    //
    //
    // end;
    // end;
    //
    //
    // //注册表里没有
    // if Not AIsExists then
    // begin
    // AReg.WriteInteger('Type'+IntToStr(APathCount),APathType);
    // AReg.WriteString('Mask'+IntToStr(APathCount),APathName);
    // AReg.WriteString('Path'+IntToStr(APathCount),APathDir);
    // AReg.WriteString('IncludeSubDir'+IntToStr(APathCount),AIncludeSubDir);
    //
    // AReg.WriteInteger('PathCount',APathCount+1);
    // end;
    // except
    // on E:Exception do
    // begin
    // DoDeployConfigLog(nil,'AddLibraryToIOSSDK Error:'+E.Message);
    // end;
    // end;
    // end
    // else
    // begin
    // DoDeployConfigLog(nil,'AddLibraryToIOSSDK PathCount is not exist!');
    // end;

  finally
    FreeAndNil(AReg);
    FreeAndNil(AKeyStringList);
  end;
  {$ENDIF}

end;

function TProjectConfig.LoadAndroidJarListFromProject(
  AAndroidJarList: TStringList; AProjectFilePath: String): Boolean;
var
  I:                  Integer;
  AXMLNode:           IXMLNode;
  AXMLDocument:       TXMLDocument;
  AJavaReferenceNode: IXMLNode;
begin
  Result := False;

  AAndroidJarList.Clear;

  // 创建XML文档
  AXMLDocument := TXMLDocument.Create(Application);
  try
    // AXMLDocument.Version:='1.0';
    // AXMLDocument.Encoding:='GB2312';
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;

    // <ItemGroup>
    // <DelphiCompile Include="$(MainSource)">
    // <MainSource>MainSource</MainSource>
    // </DelphiCompile>
    // <DCCReference Include="MapForm.pas">
    // <Form>frmMap</Form>
    // </DCCReference>
    // <JavaReference Include="BaiduMapSDK\BaiduLBS_Android.jar">
    // <Disabled/>
    // </JavaReference>
    // <JavaReference Include="BaiduNaviSDK\BaiduNaviSDK_3.1.1.jar">
    // <Disabled/>
    // </JavaReference>

    AXMLNode := AXMLNode.ChildNodes.FindNode('ItemGroup');
    if AXMLNode <> nil then
    begin

      // 加载已经添加过的jar
      for I := 0 to AXMLNode.ChildNodes.Count - 1 do
      begin
        if AXMLNode.ChildNodes[I].NodeName = 'JavaReference' then
        begin
          AJavaReferenceNode := AXMLNode.ChildNodes[I];

          AAndroidJarList.Add(AJavaReferenceNode.Attributes['Include']);

        end;
      end;

    end;

  finally
    AXMLDocument.Free;
  end;

  Result := True;

end;

function TProjectConfig.LoadDeployFileListFromProject(AProjectFilePath
  : String): Boolean;
var
  XMLNode:                    IXMLNode;
  ADeployFileXMLNode:         IXMLNode;
  ADeployFilePlatformXMLNode: IXMLNode;
  AXMLDocument:               TXMLDocument;
  I:                          Integer;
  J:                          Integer;
  K:                          Integer;
  ADeployFile:                TDeployFile;
  ADeployFilePlatform:        TDeployFilePlatform;
begin
  Result := False;

  // 预览
  Self.FCurrentDeployFileList.Clear(True);

  // 创建XML文档
  AXMLDocument := TXMLDocument.Create(Application);
  try
    // AXMLDocument.Version:='1.0';
    // AXMLDocument.Encoding:='GB2312';
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    XMLNode             := AXMLDocument.DocumentElement;


    // <Project
    // <ProjectExtensions>
    // <BorlandProject>
    // <Deployment Version="3">
    // <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPad\FM_LaunchImageLandscape_1024x768.png" Configuration="Release" Class="iPad_Launch1024x768"/>
    // <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPhone\FM_SpotlightSearchIcon_29x29.png" Configuration="Debug" Class="iPhone_Spotlight29"/>
    // <DeployFile LocalName="BaiduMapSDK\BaiduMapAPIFramework\BaiduMapAPI_Map.framework\Resources\mapapi.bundle\files\DVDirectory.cfg" Configuration="Release" Class="File">
    // <Platform Name="iOSDevice32">
    // <RemoteDir>.\mapapi.bundle\files\</RemoteDir>
    // <RemoteName>DVDirectory.cfg</RemoteName>
    // <Overwrite>true</Overwrite>
    // </Platform>
    // </DeployFile>



    // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
    // <Platform Name="Android">
    // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
    // <RemoteName>libTbDemuxer.so</RemoteName>
    // <Overwrite>true</Overwrite>
    // </Platform>
    // </DeployFile>

    // <DeployFile LocalName="$(BDS)\bin\Artwork\Android\FM_NotificationIcon_24x24.png" Configuration="Release" Class="Android_NotificationIcon24">
    // <Platform Name="Android64">
    // <RemoteName>ic_notification.png</RemoteName>
    // <Overwrite>true</Overwrite>
    // </Platform>
    // </DeployFile>

    XMLNode := XMLNode.ChildNodes.FindNode('ProjectExtensions');
    if XMLNode <> nil then
    begin
      XMLNode := XMLNode.ChildNodes.FindNode('BorlandProject');
      if XMLNode <> nil then
      begin
        XMLNode := XMLNode.ChildNodes.FindNode('Deployment');
        if (XMLNode <> nil) then
        begin
          if (XMLNode.Attributes['Version'] = '3') then
          begin
            // 列出所有DeployFile

            for I := 0 to XMLNode.ChildNodes.Count - 1 do
            begin
              if (XMLNode.ChildNodes[I].NodeName = 'DeployFile') then
              begin

                ADeployFileXMLNode := XMLNode.ChildNodes[I];

                ADeployFile := TDeployFile.Create;

                // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
                ADeployFile.LocalName := ADeployFileXMLNode.Attributes
                  ['LocalName'];
                if ADeployFileXMLNode.HasAttribute('Configuration') then
                begin
                  // 是否只适用于Debug或Release
                  ADeployFile.Configuration := ADeployFileXMLNode.Attributes
                    ['Configuration'];
                end;
                if ADeployFileXMLNode.HasAttribute('Class') then
                begin
                  // 文件类型
                  ADeployFile.Class_ := ADeployFileXMLNode.Attributes['Class'];
                end;




                // 列举出此文件需要布署到哪些平台(IOS,Android,Mac,Windows)
                // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
                // <Platform Name="Android">
                // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
                // <RemoteName>libTbDemuxer.so</RemoteName>
                // <Overwrite>true</Overwrite>

                for J := 0 to ADeployFileXMLNode.ChildNodes.Count - 1 do
                begin
                  // <Platform Name="Android">
                  if (ADeployFileXMLNode.ChildNodes[J].NodeName = 'Platform')
                  then
                  begin

                    ADeployFilePlatformXMLNode :=
                      ADeployFileXMLNode.ChildNodes[J];

                    ADeployFilePlatform := TDeployFilePlatform.Create;

                    ADeployFilePlatform.Platform_ :=
                      ADeployFilePlatformXMLNode.Attributes['Name'];

                    for K := 0 to ADeployFilePlatformXMLNode.ChildNodes.
                      Count - 1 do
                    begin
                      // 布署到哪个远程文件夹
                      if (ADeployFilePlatformXMLNode.ChildNodes[K]
                        .NodeName = 'RemoteDir') then
                      begin
                        ADeployFilePlatform.RemoteDir :=
                          ADeployFilePlatformXMLNode.ChildNodes[K].Text;
                      end;
                      // 布署之后的文件名
                      if (ADeployFilePlatformXMLNode.ChildNodes[K]
                        .NodeName = 'RemoteName') then
                      begin
                        ADeployFilePlatform.RemoteName :=
                          ADeployFilePlatformXMLNode.ChildNodes[K].Text;
                      end;
                      // 是否需要覆盖
                      if (ADeployFilePlatformXMLNode.ChildNodes[K]
                        .NodeName = 'Overwrite') then
                      begin
                        ADeployFilePlatform.Overwrite :=
                          ADeployFilePlatformXMLNode.ChildNodes[K].Text;
                      end;
                      // 是否启用
                      if (ADeployFilePlatformXMLNode.ChildNodes[K]
                        .NodeName = 'Enabled') then
                      begin
                        ADeployFilePlatform.Enabled :=
                          ADeployFilePlatformXMLNode.ChildNodes[K].Text;
                      end;
                    end;

                    ADeployFile.Platforms.Add(ADeployFilePlatform);

                  end;
                end;

                Self.FCurrentDeployFileList.Add(ADeployFile);

              end;

            end;

            Result := True;

          end
          else
          begin
            DoDeployConfigLog(nil, GetLangString(['不支持此Deployment版本',
              'Not support this deployment version']));
            // '不支持此Deployment版本');
          end;
        end
        else
        begin
          DoDeployConfigLog(nil, GetLangString(['不存在Deployment节点',
            'Deployment node is not exist']));
          // '不存在Deployment节点');
        end;
      end
      else
      begin
        DoDeployConfigLog(nil, GetLangString(['不存在BorlandProject节点',
          'BorlandProject node is not exist']));
        // '不存在BorlandProject节点');
      end;
    end
    else
    begin
      DoDeployConfigLog(nil, GetLangString(['不存在ProjectExtensions节点',
        'ProjectExtensions node is not exist']));
      // '不存在ProjectExtensions节点');
    end;

  finally
    AXMLDocument.Free;
  end;

end;

procedure TProjectConfig.LoadFromINI(AINIFilePath: String);
var
  I:               Integer;
  ASectionName:    String;
  AIniFile:        TIniFile;
  ADeployConfig:   TDeployConfig;
  AConfigVariable: TConfigVariable;
begin

  if not FileExists(AINIFilePath) then
  begin
    raise Exception.Create(QuotedStr(AINIFilePath) + ' is not exist');
    Exit;
  end;

  AIniFile := TIniFile.Create(AINIFilePath);

  // 上次打开的工程
  Self.FLastProjectFilePath := AIniFile.ReadString('',
    'LastProjectFilePath', '');

  // 布署配置
  Self.FDeployConfigList.Clear(True);

  for I := 0 to 100 do
  begin
    ASectionName := 'DeployConfigList ' + IntToStr(I);

    if AIniFile.SectionExists(ASectionName) then
    begin

      ADeployConfig           := TDeployConfig.Create;
      ADeployConfig.Platform_ := AIniFile.ReadString(ASectionName,
        'Platform', '');
      ADeployConfig.LocalDir := AIniFile.ReadString(ASectionName,
        'LocalDir', '');
      ADeployConfig.RemoteDir := AIniFile.ReadString(ASectionName,
        'RemoteDir', '');

      Self.FDeployConfigList.Add(ADeployConfig);
    end;

  end;

  // 加载Jar配置
  Self.FAndroidJarList.Clear;
  for I := 0 to 100 do
  begin
    if AIniFile.ReadString('AndroidJar', IntToStr(I), '') <> '' then
    begin
      FAndroidJarList.Add(AIniFile.ReadString('AndroidJar', IntToStr(I), ''));
    end;
  end;
  // FIsDisableSysJars:=AIniFile.ReadBool('AndroidJar','IsDisableSysJars',False);

  // 加载Aar配置
  Self.FAndroidAarList.Clear;
  for I := 0 to 100 do
  begin
    if AIniFile.ReadString('AndroidAar', IntToStr(I), '') <> '' then
    begin
      FAndroidAarList.Add(AIniFile.ReadString('AndroidAar', IntToStr(I), ''));
    end;
  end;

  // 保存变量
  Self.FAndroidVariableList.Clear;
  for I := 0 to 100 do
  begin
    if AIniFile.ReadString('AndroidVariable', 'Name' + IntToStr(I), '') <> ''
    then
    begin
      AConfigVariable      := TConfigVariable.Create;
      AConfigVariable.Name := AIniFile.ReadString('AndroidVariable',
        'Name' + IntToStr(I), '');
      AConfigVariable.Value := AIniFile.ReadString('AndroidVariable',
        'Value' + IntToStr(I), '');
      AConfigVariable.Desc := AIniFile.ReadString('AndroidVariable',
        'Desc' + IntToStr(I), '');
      FAndroidVariableList.Add(AConfigVariable);
    end;
  end;

  // 加载AndroidManifest.xml中的权限配置
  Self.FAndroidUsersPermissions.Clear;
  for I := 0 to 400 do
  begin
    if AIniFile.ReadString('AndroidUsersPermissions', IntToStr(I), '') <> ''
    then
    begin
      FAndroidUsersPermissions.Add
        (AIniFile.ReadString('AndroidUsersPermissions', IntToStr(I), ''));
    end;
  end;

  // 加载AndroidManifest.xml中的Application子节点
  Self.FAndroidApplicationChildNodes.Clear;
  for I := 0 to 300 do
  begin
    if AIniFile.ReadString('AndroidApplicationChildNodes', IntToStr(I), '') <> ''
    then
    begin
      FAndroidApplicationChildNodes.Add
        (AIniFile.ReadString('AndroidApplicationChildNodes', IntToStr(I), ''));
    end;
  end;

  // 加载IOSPlistRootNodes子节点
  Self.FIOSPlistRootNodes.Clear;
  for I := 0 to 100 do
  begin
    if AIniFile.ReadString('IOSPlistRootNodes', IntToStr(I), '') <> '' then
    begin
      FIOSPlistRootNodes.Add(AIniFile.ReadString('IOSPlistRootNodes',
        IntToStr(I), ''));
    end;
  end;

  // IOS链接参数
  Self.FIOSLinkerOptions := AIniFile.ReadString('', 'IOSLinkerOptions', '');

  FreeAndNil(AIniFile);

end;

function TProjectConfig.ProcessAll(AProjectFilePath: String): Boolean;
var
  I: Integer;
begin
  Result := False;

  // 根据工程文件
  // 生成需要布署的所有文件列表
  if not Self.FDeployConfigList.GeneratePreviewDeployFileList(
    AProjectFilePath
    ) then
    Exit;

  // 把文件布署列表处理到工程文件
  if not Self.SaveDeployFileListToProject(
    Self.FDeployConfigList.FPreviewDeployFileList,
    AProjectFilePath
    ) then
    Exit;

  // 保存Applcation子节点列表
  if not Self.SaveAndroidApplicationChildNodesToProject(
    Self.FAndroidApplicationChildNodes,
    Self.FAndroidVariableList,
    AProjectFilePath) then
    Exit;

  // 保存Android权限列表
  if not Self.SaveAndroidUsersPermissionsToProject(
    Self.FAndroidUsersPermissions,
    Self.FAndroidVariableList,
    AProjectFilePath) then
    Exit;

  // 保存AndroidJar到
  if not Self.SaveAndroidJarListToProject(
    Self.FAndroidJarList,
    AProjectFilePath) then
    Exit;

  // 保存AndroidAar到
  if not Self.SaveAndroidAarListToProject(
    Self.FAndroidAarList,
    AProjectFilePath) then
    Exit;

  // 保存IOS链接参数
  if not Self.SaveIOSLinkerOptionsToProject(
    AProjectFilePath,
    Self.FIOSLinkerOptions
    ) then
    Exit;

  // 保存IOS Plist RootNodes
  if not Self.SaveIOSInfoPlistToProject(
    AProjectFilePath,
    Self.FIOSPlistRootNodes,
    Self.FAndroidVariableList
    ) then
    Exit;

  // 获取有哪些Delphi Version
  // 获取有哪个IOS SDK
  // 再逐一添加所需要的Frameworks
  for I := 0 to GlobalIOSFrameworkList.Count - 1 do
  begin
    AddLibraryToAllIOSSDK(
      2,
      GlobalIOSFrameworkList[I],
      '$(SDKROOT)/System/Library/Frameworks',
      '0'
      );
  end;

  // 获取有哪些Delphi Version
  // 获取有哪个IOS SDK
  // 再逐一添加所需要的Dylibs
  for I := 0 to GlobalIOSDylibList.Count - 1 do
  begin
    AddLibraryToAllIOSSDK(
      1,
      GlobalIOSDylibList[I],
      '$(SDKROOT)/usr/lib',
      '0'
      );
  end;

  Result := True;
end;

function TProjectConfig.SaveAndroidApplicationChildNodesToProject(
  AAndroidApplicationChildNodes: TStringList;
  AConfigVariables: TConfigVariableList;
  AProjectFilePath: String): Boolean;
var
  AAndroidManifestFilePath:               String;
  AAndroidManifestList:                   TStringList;
  APorcessedAndroidApplicationChildNodes: TStringList;
  ATrimAndroidManifestList:               TStringList;
  I:                                      Integer;
  AIsAllExists:                           Boolean;
  AUsesFeatureIndex:                      Integer;
begin
  Result := False;

  // 判断是否有内容
  if AAndroidApplicationChildNodes.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  // 判断内容的XML格式是否能正常解析
  CheckAndroidManifestTemplateXmlFile(AProjectFilePath);

  // 找到所在的AndroidManifest.template.xml的路径
  AAndroidManifestFilePath := ExtractFilePath(AProjectFilePath) +
    'AndroidManifest.template.xml';

  if not FileExists(AAndroidManifestFilePath) then
  begin
    ShowMessage
      (GetLangString(['AndroidManifest.template.xml文件不存在,请先在Android平台下编译生成该文件',
      'AndroidManifest.template.xml is not exist,Please build at Android platform first']
      ));
    // 'AndroidManifest.template.xml文件不存在,请先在Android平台下编译生成该文件');
    Exit;
  end;

  // 是utf-8编码的
  AAndroidManifestList                   := TStringList.Create;
  ATrimAndroidManifestList               := TStringList.Create;
  APorcessedAndroidApplicationChildNodes := TStringList.Create;
  try

    // 先替换AAndroidUsersPermissions中的变量为指定值
    APorcessedAndroidApplicationChildNodes.Assign
      (AAndroidApplicationChildNodes);
    ProcessConfigVariables(APorcessedAndroidApplicationChildNodes,
      AConfigVariables);

    try
      AAndroidManifestList.LoadFromFile(AAndroidManifestFilePath,
        TEncoding.UTF8);
    except
      AAndroidManifestList.LoadFromFile(AAndroidManifestFilePath,
        TEncoding.ANSI);
    end;

    // 去掉空格
    for I := 0 to AAndroidManifestList.Count - 1 do
    begin
      ATrimAndroidManifestList.Add(Trim(AAndroidManifestList[I]));
    end;

    // 先判断一下整体是否存在
    AIsAllExists := True;
    for I        := 0 to APorcessedAndroidApplicationChildNodes.Count - 1 do
    begin
      if ATrimAndroidManifestList.IndexOf
        (Trim(APorcessedAndroidApplicationChildNodes[I])) = -1 then
      begin
        // 整体不存在
        AIsAllExists := False;
        Break;
      end;
    end;

    // 整体不存在
    // 那么添加
    // 添加在</application>前面
    if Not AIsAllExists then
    begin

      // 定位</application>
      // 在哪一行
      AUsesFeatureIndex := -1;
      for I             := 0 to AAndroidManifestList.Count - 1 do
      begin
        if Pos('</application>', AAndroidManifestList[I]) > 0 then
        begin
          AUsesFeatureIndex := I;
          Break;
        end;
      end;

      // 插入在</application>
      // 上面
      if AUsesFeatureIndex > -1 then
      begin

        // 插入8个空白行
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');

        // 插入节点列表
        for I := 0 to APorcessedAndroidApplicationChildNodes.Count - 1 do
        begin
          AAndroidManifestList.Insert(AUsesFeatureIndex + 4 + I,
            APorcessedAndroidApplicationChildNodes[I]);
        end;

        AAndroidManifestList.SaveToFile(AAndroidManifestFilePath,
          TEncoding.UTF8);

      end
      else
      begin
        ShowMessage
          (GetLangString(['AndroidManifest.template.xml格式不正确,无法定位</application>',
          'Can not find </application> in AndroidManifest.template.xml']));
        // 'AndroidManifest.template.xml格式不正确,无法定位</application>');
        Exit;
      end;

    end
    else
    begin
      DoDeployConfigLog(nil,
        GetLangString(['AndroidManifest.template.xml中已经存在该SDK所需要的应用节点',
        'AndroidManifest.template.xml has been exist all need']));
      // 'AndroidManifest.template.xml中已经存在该SDK所需要的应用节点');
    end;

    Result := True;
  finally
    AAndroidManifestList.Free;
    ATrimAndroidManifestList.Free;
    APorcessedAndroidApplicationChildNodes.Free;
  end;

end;

function TProjectConfig.SaveAndroidJarListToProject(AAndroidJarList
  : TStringList; AProjectFilePath: String): Boolean;
var
  I:                          Integer;
  AXMLNode:                   IXMLNode;
  AXMLDocument:               TXMLDocument;
  AJavaReferenceNode:         IXMLNode;
  J:                          Integer;
  AExistedAndroidJarNameList: TStringList;
  AIsModified:                Boolean;
begin
  Result := False;

  AIsModified := False;

  if AAndroidJarList.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  AExistedAndroidJarNameList := TStringList.Create;

  // 创建XML文档
  AXMLDocument := TXMLDocument.Create(Application);
  try
    // AXMLDocument.Version:='1.0';
    // AXMLDocument.Encoding:='GB2312';
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;






    // <ItemGroup>
    // <DelphiCompile Include="$(MainSource)">
    // <MainSource>MainSource</MainSource>
    // </DelphiCompile>
    // <DCCReference Include="MapForm.pas">
    // <Form>frmMap</Form>
    // </DCCReference>
    // <JavaReference Include="BaiduMapSDK\BaiduLBS_Android.jar">
    // <Disabled/>
    // </JavaReference>
    // <JavaReference Include="BaiduNaviSDK\BaiduNaviSDK_3.1.1.jar">
    // <Disabled/>
    // </JavaReference>

    AXMLNode := AXMLNode.ChildNodes.FindNode('ItemGroup');
    if AXMLNode <> nil then
    begin

      // 加载已经添加过的jar
      for I := 0 to AXMLNode.ChildNodes.Count - 1 do
      begin
        if AXMLNode.ChildNodes[I].NodeName = 'JavaReference' then
        begin
          AJavaReferenceNode := AXMLNode.ChildNodes[I];

          AExistedAndroidJarNameList.Add(
            ExtractFileName(AJavaReferenceNode.Attributes['Include'])
            );

        end;
      end;

      // 添加不存在的Jar
      for I := 0 to AAndroidJarList.Count - 1 do
      begin
        if Trim(AAndroidJarList[I]) = '' then
          continue;

        if AExistedAndroidJarNameList.IndexOf
          (ExtractFileName(AAndroidJarList[I])) = -1 then
        begin
          AJavaReferenceNode := AXMLNode.AddChild('JavaReference');
          AJavaReferenceNode.Attributes['Include'] := AAndroidJarList[I];
          AJavaReferenceNode.AddChild('Disabled');

          AIsModified := True;
        end
        else
        begin
          DoDeployConfigLog(nil,
            GetLangString(['工程文件中已经添加过该Jar' + AAndroidJarList[I],
            'This Jar is already exist:' + AAndroidJarList[I]]));
          // '工程文件中已经添加过该jar:'+AAndroidJarList[I]);
        end;
      end;

      if AIsModified then
      begin
        AXMLDocument.SaveToFile(AProjectFilePath);
      end;

      Result := True;

    end
    else
    begin
      DoDeployConfigLog(nil, GetLangString(['工程文件中不存在ItemGroup节点',
        'ItemGroup node is not exist in project file']));
      // '工程文件中不存在ItemGroup节点');
      Exit;
    end;

  finally
    AXMLDocument.Free;
    AExistedAndroidJarNameList.Free;
  end;

end;

function TProjectConfig.SaveAndroidAarListToProject(AAndroidAarList
  : TStringList; AProjectFilePath: String): Boolean;
var
  I:                          Integer;
  AAndroidJarList:            TStringList;
  AAndroidAarFilePath:        String;
  AAndroidAarRelativeDirPath: String;
  AAndroidAarDirPath:         String;
  {$IFNDEF IN_ORANGESDK}
  // ziper:TVCLZip;
  {$ENDIF}
  ADeployConfig:     TDeployConfig;
  ADeployConfigList: TDeployConfigList;
begin
  Result := False;

  if AAndroidAarList.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  AAndroidJarList   := TStringList.Create;
  ADeployConfigList := TDeployConfigList.Create;
  try

    // 先解压aar文件
    for I := 0 to AAndroidAarList.Count - 1 do
    begin
      if Trim(AAndroidAarList[I]) = '' then
        continue;

      // dmcBig_MediaPicker\support-compat-28.0.0.aar
      AAndroidAarFilePath        := AAndroidAarList[I];
      AAndroidAarRelativeDirPath := ChangeFileExt(AAndroidAarList[I],
        '_aar') + '\';

      AAndroidAarFilePath := ConvertRelativePathToAbsolutePath
        (ExtractFilePath(AProjectFilePath), AAndroidAarFilePath);
      AAndroidAarDirPath := ChangeFileExt(AAndroidAarFilePath, '_aar') + '\';
      // dmcBig_MediaPicker\support-compat-28.0.0_aar\support-compat-28.0.0.aar.jar
      AAndroidJarList.Add(AAndroidAarRelativeDirPath +
        ExtractFileName(AAndroidAarList[I]) + '.jar');

      if not DirectoryExists(AAndroidAarDirPath) then
      begin

        {$IFNDEF IN_ORANGESDK}
        // 目录不存在,则解压
        // ziper:=TVCLZip.Create(application);
        // ziper.ZipName:=AAndroidAarFilePath;//获取压缩文件名
        // ziper.DestDir:=AAndroidAarDirPath;
        // ziper.DoAll := True;
        // ziper.OverwriteMode := Always;
        // ziper.RelativePaths:=true;//是否保持目录bai结构
        // ziper.AddDirEntriesOnRecurse:=true;
        // ziper.RecreateDirs:=true;//创建目录
        // ziper.UnZip;
        // ziper.Free;
        {$ENDIF}
        // 将里面的classes.jar重命名
        ReNameFile(AAndroidAarDirPath + '\' + 'classes.jar',
          AAndroidAarDirPath + '\' + ExtractFileName(AAndroidAarFilePath)
          + '.jar');

      end;

      // 判断res目录是否存在需要布署的文件,如果有,则需要布署
      // 无论有没有,都布署即可,省事
      if DirectoryExists(AAndroidAarDirPath + 'res') then
      begin

        ADeployConfig           := TDeployConfig.Create;
        ADeployConfig.Platform_ := 'Android';
        ADeployConfig.LocalDir  := AAndroidAarRelativeDirPath + 'res\';
        ADeployConfig.RemoteDir := 'res\';

        ADeployConfigList.Add(ADeployConfig);
      end;

      // 判断jni目录是否存在需要布署的文件,如果有,则需要布署
      // 无论有没有,都布署即可,省事
      if DirectoryExists(AAndroidAarDirPath + 'jni') then
      begin

        ADeployConfig           := TDeployConfig.Create;
        ADeployConfig.Platform_ := 'Android';
        ADeployConfig.LocalDir  := AAndroidAarRelativeDirPath + 'jni\';
        ADeployConfig.RemoteDir := 'library\lib\';

        ADeployConfigList.Add(ADeployConfig);

      end;

    end;

    Self.SaveAndroidJarListToProject(AAndroidJarList, AProjectFilePath);

    // 根据工程文件
    // 生成需要布署的所有文件列表
    if not ADeployConfigList.GeneratePreviewDeployFileList(
      AProjectFilePath
      ) then
      Exit;

    // 把文件布署列表处理到工程文件
    if not Self.SaveDeployFileListToProject(
      ADeployConfigList.FPreviewDeployFileList,
      AProjectFilePath
      ) then
      Exit;

    Result := True;

  finally
    AAndroidJarList.Free;
    ADeployConfigList.Free;
  end;

end;

procedure ProcessConfigVariables(AStringList: TStringList;
  AConfigVariableList: TConfigVariableList);
var
  I: Integer;
  J: Integer;
begin
  for I := 0 to AStringList.Count - 1 do
  begin
    for J := 0 to AConfigVariableList.Count - 1 do
    begin
      if Pos(AConfigVariableList[J].Name, AStringList[I]) > 0 then
      begin
        AStringList[I] := ReplaceStr(AStringList[I],
          AConfigVariableList[J].Name,
          AConfigVariableList[J].Value
          );
      end;
    end;
  end;
end;

function TProjectConfig.SaveAndroidUsersPermissionsToProject(
  AAndroidUsersPermissions: TStringList;
  AConfigVariables: TConfigVariableList;
  AProjectFilePath: String): Boolean;
var
  AAndroidManifestFilePath:          String;
  AAndroidManifestList:              TStringList;
  ATrimAndroidManifestList:          TStringList;
  I:                                 Integer;
  AIsAllExists:                      Boolean;
  AUsesFeatureIndex:                 Integer;
  AProcessedAndroidUsersPermissions: TStringList;
begin
  Result := False;

  if AAndroidUsersPermissions.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  // 判断Android模板文件是否存在
  // 不存在的话从工具的exe目录拷一个出来
  // 判断内容的XML格式是否能正常解析
  CheckAndroidManifestTemplateXmlFile(AProjectFilePath);

  AAndroidManifestFilePath := ExtractFilePath(AProjectFilePath) +
    'AndroidManifest.template.xml';

  if not FileExists(AAndroidManifestFilePath) then
  begin
    ShowMessage
      (GetLangString(['AndroidManifest.template.xml文件不存在,请先在Android平台下编译生成该文件',
      'AndroidManifest.template.xml is not exist,Please build at Android platform first']
      ));
    // 'AndroidManifest.template.xml文件不存在,请先在Android平台下编译生成该文件');
    Exit;
  end;

  // 文件存在
  // 是utf-8编码的
  AAndroidManifestList              := TStringList.Create;
  ATrimAndroidManifestList          := TStringList.Create;
  AProcessedAndroidUsersPermissions := TStringList.Create;
  try

    // 先替换AAndroidUsersPermissions中的变量
    AProcessedAndroidUsersPermissions.Assign(AAndroidUsersPermissions);
    ProcessConfigVariables(AProcessedAndroidUsersPermissions,
      AConfigVariables);
    // 解析出里面的xml

    //
    try
      AAndroidManifestList.LoadFromFile(AAndroidManifestFilePath,
        TEncoding.UTF8);
    except
      AAndroidManifestList.LoadFromFile(AAndroidManifestFilePath,
        TEncoding.ANSI);
    end;

    for I := 0 to AAndroidManifestList.Count - 1 do
    begin
      ATrimAndroidManifestList.Add(Trim(AAndroidManifestList[I]));
    end;

    // 先判断一下权限设置整体是否存在
    AIsAllExists := True;
    for I        := 0 to AProcessedAndroidUsersPermissions.Count - 1 do
    begin
      if ATrimAndroidManifestList.IndexOf
        (Trim(AProcessedAndroidUsersPermissions[I])) = -1 then
      begin
        // 整体不存在
        AIsAllExists := False;
        Break;
      end;
    end;

    // 整体不存在
    // 那么添加
    // 添加在<uses-feature android:glEsVersion="0x00020000" android:required="True"/>前面
    if Not AIsAllExists then
    begin

      // 定位<uses-feature android:glEsVersion="0x00020000" android:required="True"/>
      // 在哪一行
      AUsesFeatureIndex := -1;
      for I             := 0 to AAndroidManifestList.Count - 1 do
      begin
        if Pos('<uses-feature', AAndroidManifestList[I]) > 0 then
        begin
          AUsesFeatureIndex := I;
          Break;
        end;
      end;

      // 插入在<uses-feature android:glEsVersion="0x00020000" android:required="True"/>
      // 上面
      if AUsesFeatureIndex > -1 then
      begin

        // 插入8个空白行
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        AAndroidManifestList.Insert(AUsesFeatureIndex - 1, '');
        // 插入权限列表
        for I := 0 to AProcessedAndroidUsersPermissions.Count - 1 do
        begin
          AAndroidManifestList.Insert(AUsesFeatureIndex + 4 + I,
            AProcessedAndroidUsersPermissions[I]);
        end;

        AAndroidManifestList.SaveToFile(AAndroidManifestFilePath,
          TEncoding.UTF8);

      end
      else
      begin
        ShowMessage
          (GetLangString(['AndroidManifest.template.xml格式不正确,无法定位<uses-feature',
          'Can not find <uses-feature in AndroidManifest.template.xml']));
        // 'AndroidManifest.template.xml格式不正确,无法定位<uses-feature');
        Exit;
      end;

    end
    else
    begin
      DoDeployConfigLog(nil,
        GetLangString(['AndroidManifest.template.xml中已经存在该SDK所需要的权限',
        'AndroidManifest.template.xml has existed all need']));
      // 'AndroidManifest.template.xml中已经存在该SDK所需要的权限');
    end;

    Result := True;
  finally
    AAndroidManifestList.Free;
    ATrimAndroidManifestList.Free;
    AProcessedAndroidUsersPermissions.Free;
  end;

end;

function TProjectConfig.SaveIOSInfoPlistToProject(AProjectFilePath: String;
  AInfoPlistRootNodes: TStringList;
  AConfigVariables: TConfigVariableList): Boolean;
var
  AInfoPlistTemplateFilePath:     String;
  AStringStream:                  TStringStream;
  AInfoPlistXMLStr:               String;
  AInfoPlistRootNodesStr:         String;
  AProcessedInfoPlistRootNodes:   TStringList;
  I:                              Integer;
  AXMLNode:                       IXMLNode;
  AXMLDocument:                   TXMLDocument;
  AFindNodeIndex:                 Integer;
  ACFBundleURLTypesArrayNode:     IXMLNode;
  ACFBundleURLTypesArrayDictNode: IXMLNode;
  ACFBundleURLSchemesArrayNode:   IXMLNode;
  ACFBundleURLSchemesList:        TStringList;

  AInsertXMLNode:                       IXMLNode;
  AInsertXMLDocument:                   TXMLDocument;
  AInsertCFBundleURLTypesArrayNode:     IXMLNode;
  AInsertCFBundleURLTypesArrayDictNode: IXMLNode;
  AInsertCFBundleURLSchemesArrayNode:   IXMLNode;

  J:          Integer;
  AIsExisted: Boolean;
  AIndex:     Integer;
begin
  Result := False;

  if AInfoPlistRootNodes.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  if Not FileExists(AProjectFilePath) then
  begin
    ShowMessage(GetLangString(['工程文件不存在',
      'Project file is not exist']));
    // '工程文件不存在');
    Exit;
  end;

  CheckInfoPlistTemplateiOSXmlFile(AProjectFilePath);

  AInfoPlistTemplateFilePath := ExtractFilePath(AProjectFilePath) +
    'info.plist.TemplateiOS.xml';
  if not FileExists(AInfoPlistTemplateFilePath) then
  begin
    ShowMessage
      (GetLangString(['info.plist.TemplateiOS.xml文件不存在,请先在IOS平台下运行一下,它会自动生成',
      'info.plist.TemplateiOS.xml is not exist,Please build at IOS platform first']
      ));
    // 'info.plist.TemplateiOS.xml文件不存在,请先在IOS平台下运行一下,它会自动生成');
    Exit;
  end;

  if AInfoPlistRootNodes.Count = 0 then
  begin
    Result := True;
    Exit;
  end;

  // 工程文件中的info.plist.TemplateiOS.xml
  AStringStream := TStringStream.Create('', TEncoding.UTF8);
  try
    AStringStream.LoadFromFile(AInfoPlistTemplateFilePath);
    AInfoPlistXMLStr := AStringStream.DataString;
    // 去掉这两个变量,才是合法的XML格式文档,后面再加上去
    AInfoPlistXMLStr := ReplaceStr(AInfoPlistXMLStr,
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
      '');
    AInfoPlistXMLStr := ReplaceStr(AInfoPlistXMLStr,
      '<%VersionInfoPListKeys%>', '');
    AInfoPlistXMLStr := ReplaceStr(AInfoPlistXMLStr,
      '<%ExtraInfoPListKeys%>', '');
  finally
    FreeAndNil(AStringStream);
  end;

  // 替换变量
  AInfoPlistRootNodesStr       := '';
  AProcessedInfoPlistRootNodes := TStringList.Create;
  AProcessedInfoPlistRootNodes.Assign(AInfoPlistRootNodes);
  try
    ProcessConfigVariables(AProcessedInfoPlistRootNodes, AConfigVariables);
    for I := 0 to AProcessedInfoPlistRootNodes.Count - 1 do
    begin
      AInfoPlistRootNodesStr := AInfoPlistRootNodesStr +
        AProcessedInfoPlistRootNodes[I];
    end;
    AInfoPlistRootNodesStr := '<array>'
      + AInfoPlistRootNodesStr
      + '</array>';
  finally
    FreeAndNil(AProcessedInfoPlistRootNodes);
  end;

  // 处理XML
  // 创建XML文档
  AXMLDocument            := TXMLDocument.Create(Application);
  AInsertXMLDocument      := TXMLDocument.Create(Application);
  ACFBundleURLSchemesList := TStringList.Create;
  try
    AXMLDocument.LoadFromXML(AInfoPlistXMLStr);
    AXMLDocument.Active   := True;
    AXMLDocument.Version  := '1.0';
    AXMLDocument.Encoding := 'UTF-8';
    AXMLNode              := AXMLDocument.DocumentElement; // plist
    AXMLNode              := AXMLNode.ChildNodes[0];       // dict

    // 需要插入的XML
    AInsertXMLDocument.LoadFromXML(AInfoPlistRootNodesStr);
    AInsertXMLDocument.Active := True;
    AInsertXMLNode            := AInsertXMLDocument.DocumentElement;

    AIndex := 0;
    while AIndex < AInsertXMLNode.ChildNodes.Count - 1 do
    begin

      // 'CFBundleURLTypes',IOS Schema
      if AInsertXMLNode.ChildNodes[AIndex].Text = 'CFBundleURLTypes' then
      begin
        // 要插入的IOS Schema数组
        AInsertCFBundleURLTypesArrayNode := AInsertXMLNode.ChildNodes
          [AIndex + 1];

        // 结构是
        // <key> CFBundleURLTypes</key>
        // <array>
        // <dict>微信</dict>
        // <dict>支付宝</dict>
        // <dict>facebook</dict>
        // <dict>twitter</dict>
        // </array>
        // 插入到这里,先判断已经插入了哪些了
        ACFBundleURLTypesArrayNode := FindKeyValueNode(AXMLNode,
          'CFBundleURLTypes');
        if ACFBundleURLTypesArrayNode <> nil then
        begin
          ACFBundleURLSchemesList.Clear;

          // <array>里面是<dict>列表
          for I := 0 to ACFBundleURLTypesArrayNode.ChildNodes.Count - 1 do
          begin
            // <dict>
            // <key>CFBundleURLSchemes</key>
            // <array>
            // <string>fb+你的AppID</string>
            // </array>
            // </dict>
            ACFBundleURLTypesArrayDictNode :=
              ACFBundleURLTypesArrayNode.ChildNodes[I];
            // <array>里面是<string>列表
            ACFBundleURLSchemesArrayNode :=
              FindKeyValueNode(ACFBundleURLTypesArrayDictNode,
              'CFBundleURLSchemes');
            if ACFBundleURLSchemesArrayNode <> nil then
            begin
              for J := 0 to ACFBundleURLSchemesArrayNode.ChildNodes.Count - 1 do
              begin
                ACFBundleURLSchemesList.Add
                  (ACFBundleURLSchemesArrayNode.ChildNodes[J].Text);
              end;
            end;

          end;
        end
        else
        begin
          // 不存在,则添加
          ACFBundleURLTypesArrayNode      := AXMLNode.AddChild('key');
          ACFBundleURLTypesArrayNode.Text := 'CFBundleURLTypes';
          ACFBundleURLTypesArrayNode      := AXMLNode.AddChild('array');
        end;

        // 需要插入的<dict>列表
        for I := 0 to AInsertCFBundleURLTypesArrayNode.ChildNodes.Count - 1 do
        begin
          // CFBundleURLSchemes中判断是否已经存在
          AInsertCFBundleURLTypesArrayDictNode :=
            AInsertCFBundleURLTypesArrayNode.ChildNodes[I];
          AInsertCFBundleURLSchemesArrayNode :=
            FindKeyValueNode(AInsertCFBundleURLTypesArrayDictNode,
            'CFBundleURLSchemes');
          if AInsertCFBundleURLSchemesArrayNode <> nil then
          begin
            AIsExisted := False;
            for J      := 0 to AInsertCFBundleURLSchemesArrayNode.ChildNodes.
              Count - 1 do
            begin
              if ACFBundleURLSchemesList.IndexOf
                (AInsertCFBundleURLSchemesArrayNode.ChildNodes[J].Text) <> -1
              then
              begin
                // 不存在,则添加该<dict>
                AIsExisted := True;
                Break;
              end;
            end;

            if Not AIsExisted then
            begin
              ACFBundleURLTypesArrayDictNode :=
                ACFBundleURLTypesArrayNode.AddChild('dict');
              CopyXMLNode(AInsertCFBundleURLTypesArrayDictNode,
                ACFBundleURLTypesArrayDictNode);
            end;
          end;
        end;

      end
      else if AInsertXMLNode.ChildNodes[AIndex].Text = 'LSApplicationQueriesSchemes'
      then
      begin

        // IOS Schema白名单
        AInsertCFBundleURLTypesArrayNode := AInsertXMLNode.ChildNodes
          [AIndex + 1];

        // 结构是
        // <key>LSApplicationQueriesSchemes</key>
        // <array>
        // <string>fbapi</string>
        // <string>fb-messenger-api</string>
        // <string>fbauth2</string>
        // <string>fbshareextension</string>
        // </array>
        ACFBundleURLTypesArrayNode := FindKeyValueNode(AXMLNode,
          'LSApplicationQueriesSchemes');
        if (ACFBundleURLTypesArrayNode <> nil) then
        begin
          ACFBundleURLSchemesList.Clear;
          // <array>里面是<string>列表
          for I := 0 to ACFBundleURLTypesArrayNode.ChildNodes.Count - 1 do
          begin
            // <string>fbapi</string>
            // <string>fb-messenger-api</string>
            // <string>fbauth2</string>
            // <string>fbshareextension</string>
            ACFBundleURLSchemesList.Add
              (ACFBundleURLTypesArrayNode.ChildNodes[I].Text);
          end;
        end
        else
        begin
          // 不存在,则添加
          ACFBundleURLTypesArrayNode      := AXMLNode.AddChild('key');
          ACFBundleURLTypesArrayNode.Text := 'LSApplicationQueriesSchemes';
          ACFBundleURLTypesArrayNode      := AXMLNode.AddChild('array');
        end;

        // <dict>列表
        for I := 0 to AInsertCFBundleURLTypesArrayNode.ChildNodes.Count - 1 do
        begin
          // LSApplicationQueriesSchemes中判断是否已经存在
          AIsExisted := False;
          if ACFBundleURLSchemesList.IndexOf
            (AInsertCFBundleURLTypesArrayNode.ChildNodes[I].Text) <> -1 then
          begin
            // 不存在,则添加该<string>
            AIsExisted := True;
          end;

          if Not AIsExisted then
          begin
            ACFBundleURLTypesArrayDictNode :=
              ACFBundleURLTypesArrayNode.AddChild('string');
            CopyXMLNode(AInsertCFBundleURLTypesArrayNode.ChildNodes[I],
              ACFBundleURLTypesArrayDictNode);
          end;
        end;

      end
      else
      begin
        // 判断是否存在
        if FindChildXMLNodeIndex(AInsertXMLNode.ChildNodes[AIndex].NodeName,
          AInsertXMLNode.ChildNodes[AIndex].Text,
          AXMLNode) = -1 then
        begin
          // <key>FacebookAppID</key>
          // <string>1218646208237299</string>
          ACFBundleURLTypesArrayDictNode :=
            AXMLNode.AddChild(AInsertXMLNode.ChildNodes[AIndex].NodeName);
          CopyXMLNode(AInsertXMLNode.ChildNodes[AIndex],
            ACFBundleURLTypesArrayDictNode);
          ACFBundleURLTypesArrayDictNode :=
            AXMLNode.AddChild(AInsertXMLNode.ChildNodes[AIndex + 1].NodeName);
          CopyXMLNode(AInsertXMLNode.ChildNodes[AIndex + 1],
            ACFBundleURLTypesArrayDictNode);
        end;
      end;

      // key+value对形式的
      Inc(AIndex, 2);
    end;

    AXMLDocument.SaveToFile(ExtractFilePath(AProjectFilePath) +
      'info.plist.TemplateiOS.xml');
    AStringStream := TStringStream.Create('', TEncoding.UTF8);
    try
      AStringStream.LoadFromFile(ExtractFilePath(AProjectFilePath) +
        'info.plist.TemplateiOS.xml');
      AInfoPlistXMLStr := AStringStream.DataString;
      // 插入这两个变量,才是合法的XML格式文档
      I := Pos('<plist version="1.0">', AInfoPlistXMLStr);
      if I > 0 then
      begin
        AInfoPlistXMLStr := Copy(AInfoPlistXMLStr, 1, I - 1)
          + '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
          + Copy(AInfoPlistXMLStr, I, MaxInt);
      end;
      I := Pos('<dict>', AInfoPlistXMLStr);
      if I > 0 then
      begin
        I                := I + Length('<dict>');
        AInfoPlistXMLStr := Copy(AInfoPlistXMLStr, 1, I - 1)
          + '<%VersionInfoPListKeys%>'
          + '<%ExtraInfoPListKeys%>'
          + Copy(AInfoPlistXMLStr, I, MaxInt);
      end;

      AStringStream.Position := 0;
      AStringStream.WriteString(AInfoPlistXMLStr);

      AStringStream.Position := 0;
      AStringStream.SaveToFile(ExtractFilePath(AProjectFilePath) +
        'info.plist.TemplateiOS.xml');
    finally
      FreeAndNil(AStringStream);
    end;

    Result := True;
  finally
    AXMLDocument.Free;
    AInsertXMLDocument.Free;
    ACFBundleURLSchemesList.Free;
  end;

end;

function TProjectConfig.SaveIOSLinkerOptionsToProject(AProjectFilePath,
  ALinkerOptions: String): Boolean;
var
  AXMLNode:                    IXMLNode;
  AXMLChildNode:               IXMLNode;
  AXMLDocument:                TXMLDocument;
  I:                           Integer;
  J:                           Integer;
  ADCC_LinkerOptionsNode:      IXMLNode;
  AOldLinkerOptions:           String;
  ALinkerOptionsStringList:    TStringList;
  AOldLinkerOptionsStringList: TStringList;
  AIsModified:                 Boolean;
begin
  Result := False;

  AIsModified := False;

  // 因为需要计算出相对目录
  if (AProjectFilePath = '') then
  begin
    ShowMessage(GetLangString(['请选择工程文件',
      'Please select project file']));
    // '请选择工程文件');
    Exit;
  end;

  if Not FileExists(AProjectFilePath) then
  begin
    ShowMessage(GetLangString(['工程文件不存在',
      'Project file is not exist']));
    // '工程文件不存在');
    Exit;
  end;

  if ALinkerOptions = '' then
  begin
    Result := True;
    Exit;
  end;

  // 创建XML文档
  AXMLDocument := TXMLDocument.Create(Application);
  try
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;

    if AXMLNode <> nil then
    begin
      for I := 0 to AXMLNode.ChildNodes.Count - 1 do
      begin
        AXMLChildNode := AXMLNode.ChildNodes[I];

        // IOS
        if (AXMLChildNode.NodeName = 'PropertyGroup')
          and (
          (AXMLChildNode.Attributes['Condition']
          = '''$(Base_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_iOSDevice32)''!=''''')

          or (AXMLChildNode.Attributes['Condition']
          = '''$(Base_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_iOSDevice64)''!=''''')

          // or (AXMLChildNode.Attributes['Condition']='''$(Base_iOSSimulator)''!=''''')
          // or (AXMLChildNode.Attributes['Condition']='''$(Cfg_1_iOSSimulator)''!=''''')
          // or (AXMLChildNode.Attributes['Condition']='''$(Cfg_2_iOSSimulator)''!=''''')
          ) then
        begin

          // <PropertyGroup Condition="'$(Cfg_2_iOSDevice32)'!=''">
          // <DCC_LinkerOptions>-framework SystemConfiguration</DCC_LinkerOptions>

          ADCC_LinkerOptionsNode := AXMLChildNode.ChildNodes.FindNode
            ('DCC_LinkerOptions');
          if ADCC_LinkerOptionsNode = nil then
          begin
            ADCC_LinkerOptionsNode := AXMLChildNode.AddChild
              ('DCC_LinkerOptions');
          end;
          AOldLinkerOptions := ADCC_LinkerOptionsNode.Text;

          ALinkerOptionsStringList    := TStringList.Create;
          AOldLinkerOptionsStringList := TStringList.Create;
          try
            ALinkerOptionsStringList.Delimiter       := ' ';
            ALinkerOptionsStringList.StrictDelimiter := True;
            ALinkerOptionsStringList.DelimitedText   := ALinkerOptions;

            AOldLinkerOptionsStringList.Delimiter       := ' ';
            AOldLinkerOptionsStringList.StrictDelimiter := True;
            AOldLinkerOptionsStringList.DelimitedText   := AOldLinkerOptions;

            // -framework CFNetwork
            // -framework SystemConfiguration
            // -framework CoreTelephony
            // -lstdc++
            for J := 0 to ALinkerOptionsStringList.Count - 1 do
            begin
              if
              // 新的编译指令不存在,需要添加
                (AOldLinkerOptionsStringList.IndexOf(ALinkerOptionsStringList[J]
                ) = -1)
                and (ALinkerOptionsStringList[J] <> '-framework')
                and (ALinkerOptionsStringList[J] <> '-force_load') then
              begin

                if (ALinkerOptionsStringList[J - 1] = '-framework')
                  or (ALinkerOptionsStringList[J - 1] = '-force_load') then
                begin
                  AOldLinkerOptions := AOldLinkerOptions
                    + ' ' + ALinkerOptionsStringList[J - 1] + ' ' +
                    ALinkerOptionsStringList[J];
                end
                else
                begin
                  AOldLinkerOptions := AOldLinkerOptions
                    + ' ' + ALinkerOptionsStringList[J];
                end;

                AIsModified := True;

              end;
            end;

            ADCC_LinkerOptionsNode.Text := AOldLinkerOptions;

          finally
            FreeAndNil(ALinkerOptionsStringList);
            FreeAndNil(AOldLinkerOptionsStringList);
          end;

        end;

      end;
    end;

    if AIsModified then
    begin
      AXMLDocument.SaveToFile(AProjectFilePath);
    end;

    Result := True;
  finally
    AXMLDocument.Free;
  end;
end;

function TProjectConfig.SaveDeployFileListToProject(
  ADeployFileList: TDeployFileList; AProjectFilePath: String): Boolean;
var
  I:            Integer;
  AXMLNode:     IXMLNode;
  AXMLDocument: TXMLDocument;
  AIsModified:  Boolean;
begin
  Result := False;

  AIsModified := False;

  // 创建XML文档
  AXMLDocument := TXMLDocument.Create(Application);
  try
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;


    // <Project
    // <ProjectExtensions>
    // <BorlandProject>
    // <Deployment Version="3">
    // <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPad\FM_LaunchImageLandscape_1024x768.png"
    // Configuration="Release"
    // Class="iPad_Launch1024x768"/>
    // <DeployFile LocalName="$(BDS)\bin\Artwork\iOS\iPhone\FM_SpotlightSearchIcon_29x29.png" Configuration="Debug" Class="iPhone_Spotlight29"/>
    // <DeployFile LocalName="BaiduMapSDK\BaiduMapAPIFramework\BaiduMapAPI_Map.framework\Resources\mapapi.bundle\files\DVDirectory.cfg" Configuration="Release" Class="File">
    // <Platform Name="iOSDevice32">
    // <RemoteDir>.\mapapi.bundle\files\</RemoteDir>
    // <RemoteName>DVDirectory.cfg</RemoteName>
    // <Overwrite>true</Overwrite>
    // </Platform>
    // </DeployFile>
    //
    // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so" Configuration="Release" Class="File">
    // <Platform Name="Android">
    // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
    // <RemoteName>libTbDemuxer.so</RemoteName>
    // <Overwrite>true</Overwrite>
    // </Platform>
    // </DeployFile>

    AXMLNode := AXMLNode.ChildNodes.FindNode('ProjectExtensions');
    if AXMLNode <> nil then
    begin
      AXMLNode := AXMLNode.ChildNodes.FindNode('BorlandProject');
      if AXMLNode <> nil then
      begin
        AXMLNode := AXMLNode.ChildNodes.FindNode('Deployment');
        if (AXMLNode <> nil) then
        begin
          if (AXMLNode.Attributes['Version'] = '3') then
          begin

            // 把布署文件列表添加到工程文件的xml
            for I := 0 to ADeployFileList.Count - 1 do
            begin
              SaveDeployFileToXMLNode(ADeployFileList[I],
                AXMLNode,
                AProjectFilePath,
                AIsModified);
            end;

            if AIsModified then
            begin
              AXMLDocument.SaveToFile(AProjectFilePath);
            end;

            Result := True;

          end
          else
          begin
            // DoDeployConfigLog(Self,'不支持此工程文件的Deployment版本');
            ShowMessage(GetLangString(['不支持此工程文件的Deployment版本',
              'Can not support this deployment version']));
            // '不支持此工程文件的Deployment版本');
          end;
        end
        else
        begin
          // DoDeployConfigLog(Self,'此工程文件不存在Deployment节点');
          ShowMessage(GetLangString(['此工程文件不存在Deployment节点',
            'Deployment node is not exist']));
          // '此工程文件不存在Deployment节点');
        end;
      end
      else
      begin
        // DoDeployConfigLog(Self,'此工程文件不存在BorlandProject节点');
        ShowMessage(GetLangString(['此工程文件不存在BorlandProject节点',
          'BorlandProject node is not exist']));
        // '此工程文件不存在BorlandProject节点');
      end;
    end
    else
    begin
      ShowMessage(GetLangString(['不存在ProjectExtensions节点',
        'ProjectExtensions node is not exist']));
      // '不存在ProjectExtensions节点');
    end;

  finally
    AXMLDocument.Free;
  end;

end;

function TProjectConfig.SaveDeployFileToXMLNode(ADeployFile: TDeployFile;
  AXMLNode: IXMLNode;
  AProjectFilePath: String;
  var AIsModified: Boolean): Boolean;
var
  ALastDeployFileNodeIndex: Integer;
  // AEnabledDeployFileXMLNode:IXMLNode;
  ADeployFileXMLNode: IXMLNode;
  // ADeployFilePlatformXMLNode:IXMLNode;

  I:                    Integer;
  ARemoteDirNode:       IXMLNode;
  ARemoteNameNode:      IXMLNode;
  AIsLostSomePlatform:  Boolean;
  AExistsLocalNameList: TStringList;

  // AXMLAFilePath:String;
  // AXMLBFilePath:String;
  // ADestXMLFileName:String;
  // ADestXMLFilePath:String;
  // AEnableXMLNode:IXMLNode;
  //
  // AMixedXMLDeployFile:TDeployFile;
  // ADeployFilePlatform:TDeployFilePlatform;
begin




  // <DeployFile LocalName="TBUISDK\APK\lib\armeabi\libTbDemuxer.so"
  // Configuration="Release"
  // Class="File">
  // <Platform Name="Android">
  // <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>
  // <RemoteName>libTbDemuxer.so</RemoteName>
  // <Overwrite>true</Overwrite>
  // </Platform>
  // </DeployFile>

  // AEnabledDeployFileXMLNode:=nil;
  AIsLostSomePlatform  := False;
  AExistsLocalNameList := TStringList.Create;

  // 判断是否已经存在部署XML节点
  // 目前是使用最简单的方法
  // 根据RemoteDir+RemoteName+Platform来判断
  ADeployFileXMLNode := FindDeployFileXMLNode(ADeployFile,
    AXMLNode,
    // ADeployFilePlatformXMLNode,
    // AEnabledDeployFileXMLNode,
    AExistsLocalNameList,
    AIsLostSomePlatform);

  // if AEnabledDeployFileXMLNode<>nil then
  // begin
  // ADeployFileXMLNode:=AEnabledDeployFileXMLNode;
  // end;

  if (ADeployFileXMLNode <> nil)
  // 只合并XML文件
  // and SameText(ExtractFileExt(ADeployFile.LocalName),'.xml')
  then
  begin
    // 已经存在DeployFile的节点,但是没有Platform的子节点
    // 只需要添加Platform的子节点

    // 这个文件要布署到哪些平台
    for I := 0 to ADeployFile.Platforms.Count - 1 do
    begin

      AddDeployFilePlatformToXMLNode(ADeployFile,
        ADeployFile.Platforms[I],
        ADeployFileXMLNode,
        AIsModified);

    end;

    //
    // //已存在,合并XML
    // //是自己吗?根据LocalName来判断
    // //是上次配置的自己吗?
    // if (AExistsLocalNameList.IndexOf(ADeployFile.LocalName)<>-1)
    // //SameText(ADeployFileXMLNode.Attributes['LocalName'],ADeployFile.LocalName)
    // then
    // begin
    // //是自己,跳过
    //
    // end
    // //此布署项是启用的,需要合并,
    // //不启用的不合并
    // else if AEnabledDeployFileXMLNode<>nil then
    // begin
    //
    //
    //
    // //需要合并
    // DoDeployConfigLog(Self,'已经存在此布署文件'+ADeployFile.LocalName);
    //
    //
    /// /                //不是自己,合并
    /// /                AXMLAFilePath:=
    /// /                          ConvertRelativePathToAbsolutePath(ExtractFilePath(AProjectFilePath),
    /// /                              ADeployFileXMLNode.Attributes['LocalName']);
    /// /
    /// /                if Not FileExists(AXMLAFilePath) then
    /// /                begin
    /// /    //                DoDeployConfigLog(Self,'此布署文件不存在'+ADeployFileXMLNode.Attributes['LocalName']);
    /// /                    //不存在,则跳过,
    /// /                    //不过有一种情况是style.xml
    /// /                    if (ADeployFileXMLNode.LocalName='Android\Release\styles.xml')
    /// /                      or (ADeployFileXMLNode.LocalName='Android\Debug\styles.xml') then
    /// /                    begin
    /// /                      Exit;
    /// /                    end
    /// /                    else
    /// /                    begin
    /// /                      Exit;
    /// /                    end;
    /// /                end;
    /// /
    /// /
    /// /
    /// /                //存在相同的xml,则需要合并
    /// /                //E:\DelphiTwitterKitTest\TwitterKitSDK\twitter-core-3.0.0\res\values\values.xml
    /// /                AXMLBFilePath:=
    /// /                          ConvertRelativePathToAbsolutePath(ExtractFilePath(AProjectFilePath),
    /// /                              ADeployFile.LocalName);
    /// /                //.\MixedXML\Android\values.xml
    /// /                ADestXMLFileName:='.'+'\'
    /// /                                    +'MixedXML'+'\'
    /// /                                    +ADeployFile.Platforms[0].Platform_+'\'
    /// /                                    +ExtractFileName(ADeployFile.LocalName);
    /// /                //E:\DelphiTwitterKitTest\MixedXML\Android\values.xml
    /// /                ADestXMLFilePath:=
    /// /                          ConvertRelativePathToAbsolutePath(ExtractFilePath(AProjectFilePath),
    /// /                              ADestXMLFileName);
    /// /                ForceDirectories(ExtractFilePath(ADestXMLFilePath));
    /// /
    /// /                //合并XML文件
    /// ///                CombineXML(AXMLAFilePath,AXMLBFilePath,ADestXMLFilePath);
    /// /
    /// /
    /// /
    /// /                //如果不是自己,因为合并过的文件项不用再添加到工程文件中了
    /// /                if not SameText(ADeployFileXMLNode.Attributes['LocalName'],ADestXMLFileName) then
    /// /                begin
    /// /
    /// /                    ADeployFile.Platforms[0].Enabled:='false';
    /// /                    AddDeployFileToXMLNode(ADeployFile,AXMLNode);
    /// /
    /// /
    /// /                    //并且把原先布署启用的XML节点设置为不启用布署
    /// /                    AEnableXMLNode:=ADeployFilePlatformXMLNode.ChildNodes.FindNode('Enabled');
    /// /                    if AEnableXMLNode=nil then
    /// /                    begin
    /// /                      AEnableXMLNode:=ADeployFilePlatformXMLNode.AddChild('Enabled');
    /// /                    end;
    /// /                    AEnableXMLNode.Text:='false';
    /// /
    /// /
    /// /                    //添加合并后的xml
    /// /                    AMixedXMLDeployFile:=TDeployFile.Create;
    /// /                    AMixedXMLDeployFile.LocalName:=ADestXMLFileName;
    /// /                    AMixedXMLDeployFile.Class_:='File';
    /// /                    //布署到指定平台
    /// /                    ADeployFilePlatform:=TDeployFilePlatform.Create;
    /// /                    ADeployFilePlatform.Platform_:=ADeployFile.Platforms[0].Platform_;
    /// /
    /// /                    //取出文件名
    /// /                    ADeployFilePlatform.RemoteName:=ADeployFile.Platforms[0].RemoteName;
    /// /                    //取出文件路径
    /// /                    ADeployFilePlatform.RemoteDir:=ADeployFile.Platforms[0].RemoteDir;
    /// /                    //避免每次都布署
    /// /                    ADeployFilePlatform.Overwrite:='False';
    /// /                    AMixedXMLDeployFile.Platforms.Add(ADeployFilePlatform);
    /// /
    /// /                    AddDeployFileToXMLNode(AMixedXMLDeployFile,AXMLNode);
    /// /
    /// /                end;
    //
    //
    //
    // end;
  end
  else
  begin
    // Exit;//测试跳过

    // 不存在该布署节点,直接添加
    AddDeployFileToXMLNode(ADeployFile, AXMLNode);

    AIsModified := True;
  end;

end;

function TProjectConfig.SaveProjectIconToProject(AProjectFilePath : String): Boolean;
var
  AXMLNode      : IXMLNode;
  AXMLChildNode : IXMLNode;
  AXMLDocument  : TXMLDocument;
  I             : Integer;
  AIsModified   : Boolean;
begin
  Result := False;

  if (AProjectFilePath.Equals(EmptyStr)) then
  begin
    DoDeployConfigLog(nil, 'Please select a Project File');
    Exit;
  end;

//  if (AProjectFilePath = '') then
//  begin
//    DoDeployConfigLog(nil, 'Please select project file');
//    Exit;
//  end;

  if not FileExists(AProjectFilePath) then
  begin
    DoDeployConfigLog(nil, 'Project file is not exist.');
    Exit;
  end;

  AXMLDocument := TXMLDocument.Create(Application);

  try
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;
    AXMLNode            := AXMLDocument.DocumentElement;

    if AXMLNode <> nil then
    begin
      for I := 0 to AXMLNode.ChildNodes.Count - 1 do
      begin
        AXMLChildNode := AXMLNode.ChildNodes[I];

        //Android
        if (
             AXMLChildNode.NodeName = 'PropertyGroup')
             and ((AXMLChildNode.Attributes['Condition'] = '''$(Base_Android)''!='''''   )
             or   (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_1_Android)''!='''''  )
             or   (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_2_Android)''!='''''  )
             or   (AXMLChildNode.Attributes['Condition'] = '''$(Base_Android64)''!=''''' )
             or   (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_1_Android64)''!=''''')
             or   (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_2_Android64)''!=''''')
          )
        then
        begin
          //D:\2.2 GitHub Adriano Santos\xPlat.OpenPDF\samples\Delphi 10\images\
          SaveProjectPictureToProjectXMLNode(36 , 36 , 'Android_LauncherIcon36'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(48 , 48 , 'Android_LauncherIcon48'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(72 , 72 , 'Android_LauncherIcon72'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(96 , 96 , 'Android_LauncherIcon96'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(144, 144, 'Android_LauncherIcon144'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(192, 192, 'Android_LauncherIcon192'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(24 , 24 , 'Android_NotificationIcon24', AXMLNode.ChildNodes[I], '24_24.png');
          SaveProjectPictureToProjectXMLNode(36 , 36 , 'Android_NotificationIcon36', AXMLNode.ChildNodes[I], '36_36.png');
          SaveProjectPictureToProjectXMLNode(48 , 48 , 'Android_NotificationIcon48', AXMLNode.ChildNodes[I], '48_48.png');
          SaveProjectPictureToProjectXMLNode(72 , 72 , 'Android_NotificationIcon72', AXMLNode.ChildNodes[I], '72_72.png');
          SaveProjectPictureToProjectXMLNode(96 , 96 , 'Android_NotificationIcon96', AXMLNode.ChildNodes[I], '96_96.png');
        end;

        // IOS
        if (AXMLChildNode.NodeName = 'PropertyGroup')
          and (
          (AXMLChildNode.Attributes['Condition'] = '''$(Base_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_1_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_2_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Base_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_1_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_2_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Base_iOSSimulator)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_1_iOSSimulator)''!=''''')
          or (AXMLChildNode.Attributes['Condition'] = '''$(Cfg_2_iOSSimulator)''!=''''')
          )
        then
        begin
          SaveProjectPictureToProjectXMLNode(57  , 57  , 'iPhone_AppIcon57'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(60  , 60  , 'iPhone_AppIcon60'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(87  , 87  , 'iPhone_AppIcon87'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(114 , 114 , 'iPhone_AppIcon114'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(120 , 120 , 'iPhone_AppIcon120'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(180 , 180 , 'iPhone_AppIcon180'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(72  , 72  , 'iPad_AppIcon72'      , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(76  , 76  , 'iPad_AppIcon76'      , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(144 , 144 , 'iPad_AppIcon144'     , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(152 , 152 , 'iPad_AppIcon152'     , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(29  , 29  , 'iPhone_Spotlight29'  , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(40  , 40  , 'iPhone_Spotlight40'  , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(58  , 58  , 'iPhone_Spotlight58'  , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(80  , 80  , 'iPhone_Spotlight80'  , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(40  , 40  , 'iPad_Spotlight40'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(50  , 50  , 'iPad_Spotlight50'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(80  , 80  , 'iPad_Spotlight80'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(100 , 100 , 'iPad_Spotlight100'   , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(29  , 29  , 'iPad_Setting29'      , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(58  , 58  , 'iPad_Setting58'      , AXMLNode.ChildNodes[I]);

          // 10.3
          SaveProjectPictureToProjectXMLNode(83  , 83  , 'iPad_AppIcon83_5'    , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(167 , 167 , 'iPad_AppIcon167'     , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(120 , 120 , 'iPhone_Spotlight120' , AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1024, 1024, 'iOS_AppStore1024'    , AXMLNode.ChildNodes[I]);
        end;
      end;
    end;
    AXMLDocument.SaveToFile(AProjectFilePath);
  finally
    AXMLDocument.Free;
  end;

end;

function TProjectConfig.SaveProjectLaunchImageToProject(AProjectFilePath : String): Boolean;
var
  AXMLNode:      IXMLNode;
  AXMLChildNode: IXMLNode;
  AXMLDocument:  TXMLDocument;
  I:             Integer;
  AIsModified:   Boolean;
begin
  Result := False;

  if (AProjectFilePath = '') then
  begin
    DoDeployConfigLog(nil, 'Please select project file');
    Exit;
  end;

  if Not FileExists(AProjectFilePath) then
  begin
    DoDeployConfigLog(nil, 'Project file is not exist');
    Exit;
  end;

  // Criar documentos XML
  AXMLDocument := TXMLDocument.Create(Application);
  try
    AXMLDocument.LoadFromFile(AProjectFilePath);
    AXMLDocument.Active := True;
    AXMLNode            := AXMLDocument.DocumentElement;

    AXMLNode := AXMLDocument.DocumentElement;
    if AXMLNode <> nil then
    begin
      for I := 0 to AXMLNode.ChildNodes.Count - 1 do
      begin
        AXMLChildNode := AXMLNode.ChildNodes[I];

        // Android
        if (AXMLChildNode.NodeName = 'PropertyGroup')
          and (
          (AXMLChildNode.Attributes['Condition'] = '''$(Base_Android)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_Android)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_Android)''!=''''')

          or (AXMLChildNode.Attributes['Condition']
          = '''$(Base_Android64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_Android64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_Android64)''!=''''')
          ) then
        begin

          SaveProjectPictureToProjectXMLNode(426, 320, 'Android_SplashImage426',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(470, 320, 'Android_SplashImage470',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(640, 480, 'Android_SplashImage640',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(960, 720, 'Android_SplashImage960',
            AXMLNode.ChildNodes[I]);
        end;

        // IOS
        if (AXMLChildNode.NodeName = 'PropertyGroup')
          and (
          (AXMLChildNode.Attributes['Condition']
          = '''$(Base_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_iOSDevice32)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_iOSDevice32)''!=''''')

          or (AXMLChildNode.Attributes['Condition']
          = '''$(Base_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_iOSDevice64)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_iOSDevice64)''!=''''')

          or (AXMLChildNode.Attributes['Condition']
          = '''$(Base_iOSSimulator)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_1_iOSSimulator)''!=''''')
          or (AXMLChildNode.Attributes['Condition']
          = '''$(Cfg_2_iOSSimulator)''!=''''')
          ) then
        begin
          SaveProjectPictureToProjectXMLNode(768, 1004, 'iPad_Launch768',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(768, 1024, 'iPad_Launch768x1024',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1024, 748, 'iPad_Launch1024',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1024, 768, 'iPad_Launch1024x768',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1536, 2008, 'iPad_Launch1536',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1536, 2048, 'iPad_Launch1536x2048',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2048, 1496, 'iPad_Launch2048',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2048, 1536, 'iPad_Launch2048x1536',
            AXMLNode.ChildNodes[I]);

          SaveProjectPictureToProjectXMLNode(320, 480, 'iPhone_Launch320',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(640, 960, 'iPhone_Launch640',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(640, 1136, 'iPhone_Launch640x1136',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(750, 1334, 'iPhone_Launch750',
            AXMLNode.ChildNodes[I]);

          SaveProjectPictureToProjectXMLNode(1242, 2208, 'iPhone_Launch1242',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2208, 1242, 'iPhone_Launch2208',
            AXMLNode.ChildNodes[I]);

          // 10.3
          SaveProjectPictureToProjectXMLNode(1136, 640, 'iPhone_Launch1136x640',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1334, 750, 'iPhone_Launch1334',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(828, 1792, 'iPhone_Launch828',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1792, 828, 'iPhone_Launch1792',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1125, 2436, 'iPhone_Launch1125',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2436, 1125, 'iPhone_Launch2436',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1242, 2688,
            'iPhone_Launch1242x2688', AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2688, 1242,
            'iPhone_Launch2688x1242', AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1668, 2224, 'iPad_Launch1668',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2224, 1668, 'iPad_Launch2224',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(1668, 2388, 'iPad_Launch1668x2388',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2388, 1668, 'iPad_Launch2388x1668',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2048, 2732, 'iPad_Launch2048x2732',
            AXMLNode.ChildNodes[I]);
          SaveProjectPictureToProjectXMLNode(2732, 2048, 'iPad_Launch2732x2048',
            AXMLNode.ChildNodes[I]);

          SaveProjectPictureToProjectXMLNode(1242, 2208, 'iPhone_Launch1242',
            AXMLNode.ChildNodes[I], '1242x2208 - light-2x.png');
          SaveProjectPictureToProjectXMLNode(1242, 2208, 'iPhone_Launch1242',
            AXMLNode.ChildNodes[I], '1242x2208 - dark-2x.png');
          SaveProjectPictureToProjectXMLNode(1242, 2688, 'iPhone_Launch3x',
            AXMLNode.ChildNodes[I], '1242x2688 - light-3x.png');
          SaveProjectPictureToProjectXMLNode(1242, 2688, 'iPhone_LaunchDark3x',
            AXMLNode.ChildNodes[I], '1242x2688 - dark-3x.png');
          SaveProjectPictureToProjectXMLNode(2208, 1242, 'iPad_Launch2x',
            AXMLNode.ChildNodes[I], '2208x1242 - light-2x.png');
          SaveProjectPictureToProjectXMLNode(2208, 1242, 'iPad_LaunchDark2x',
            AXMLNode.ChildNodes[I], '2208x1242 - dark-2x.png');
        end;
      end;
    end;
    AXMLDocument.SaveToFile(AProjectFilePath);
  finally
    AXMLDocument.Free;
  end;

end;

function TProjectConfig.SaveProjectPictureToProjectXMLNode(AIconWidth,
  AIconHeight: Integer; ANodeName: String; AXMLNode: IXMLNode;
  AText: String = ''): Boolean;
var
  APictureNode: IXMLNode;
begin
  Result := False;

  APictureNode := AXMLNode.ChildNodes.FindNode(ANodeName);
  if APictureNode = nil then
  begin
    APictureNode := AXMLNode.AddChild(ANodeName);
  end;

  if AText = '' then
  begin
    APictureNode.Text := 'images\' + IntToStr(AIconWidth) + 'x' + IntToStr(AIconHeight) + '.png';
  end
  else
  begin
    APictureNode.Text := 'images\' + AText;
  end;
end;

procedure TProjectConfig.SaveToINI(AINIFilePath: String);
var
  AIniFile:      TIniFile;
  I:             Integer;
  ASectionName:  String;
  ADeployConfig: TDeployConfig;
begin
  DeleteFile(AINIFilePath);
  AIniFile := TIniFile.Create(AINIFilePath);

  // 上次打开的工程
  AIniFile.WriteString('', 'LastProjectFilePath', FLastProjectFilePath);
  AIniFile.WriteString('', '-', '');
  AIniFile.WriteString('', '--', '');
  AIniFile.WriteString('', '---', '');

  // 保存布署配置
  for I := 0 to FDeployConfigList.Count - 1 do
  begin
    ASectionName := 'DeployConfigList ' + IntToStr(I);

    ADeployConfig := TDeployConfig(FDeployConfigList[I]);

    AIniFile.WriteString(ASectionName, 'Platform', ADeployConfig.Platform_);
    AIniFile.WriteString(ASectionName, 'LocalDir', ADeployConfig.LocalDir);
    AIniFile.WriteString(ASectionName, 'RemoteDir', ADeployConfig.RemoteDir);
    // AIniFile.WriteString(ASectionName,'-','');
    // AIniFile.WriteString(ASectionName,'--','');
    // AIniFile.WriteString(ASectionName,'---','');
  end;

  // 保存Jar配置
  for I := 0 to Self.FAndroidJarList.Count - 1 do
  begin
    AIniFile.WriteString('AndroidJar', IntToStr(I), FAndroidJarList[I]);
  end;
  // AIniFile.WriteBool('AndroidJar','IsDisableSysJars',FIsDisableSysJars);
  // AIniFile.WriteString('AndroidJar','-','');
  // AIniFile.WriteString('AndroidJar','--','');
  // AIniFile.WriteString('AndroidJar','---','');

  // 保存Aar配置
  for I := 0 to Self.FAndroidAarList.Count - 1 do
  begin
    AIniFile.WriteString('AndroidAar', IntToStr(I), FAndroidAarList[I]);
  end;

  // 保存变量
  for I := 0 to Self.FAndroidVariableList.Count - 1 do
  begin
    AIniFile.WriteString('AndroidVariable', 'Name' + IntToStr(I),
      FAndroidVariableList[I].Name);
    AIniFile.WriteString('AndroidVariable', 'Value' + IntToStr(I),
      FAndroidVariableList[I].Value);
    AIniFile.WriteString('AndroidVariable', 'Desc' + IntToStr(I),
      FAndroidVariableList[I].Desc);
  end;
  // AIniFile.WriteString('AndroidVariable','-','');
  // AIniFile.WriteString('AndroidVariable','--','');
  // AIniFile.WriteString('AndroidVariable','---','');

  // 保存AndroidManifest.xml中的Android权限配置
  for I := 0 to Self.FAndroidUsersPermissions.Count - 1 do
  begin
    AIniFile.WriteString('AndroidUsersPermissions', IntToStr(I),
      FAndroidUsersPermissions[I]);
  end;
  // AIniFile.WriteString('AndroidUsersPermissions','-','');
  // AIniFile.WriteString('AndroidUsersPermissions','--','');
  // AIniFile.WriteString('AndroidUsersPermissions','---','');

  // 保存AndroidManifest.xml中的Application子节点
  for I := 0 to Self.FAndroidApplicationChildNodes.Count - 1 do
  begin
    AIniFile.WriteString('AndroidApplicationChildNodes', IntToStr(I),
      FAndroidApplicationChildNodes[I]);
  end;
  // AIniFile.WriteString('AndroidApplicationChildNodes','-','');
  // AIniFile.WriteString('AndroidApplicationChildNodes','--','');
  // AIniFile.WriteString('AndroidApplicationChildNodes','---','');

  // IOSPlistRootNodes
  for I := 0 to Self.FIOSPlistRootNodes.Count - 1 do
  begin
    AIniFile.WriteString('IOSPlistRootNodes', IntToStr(I),
      FIOSPlistRootNodes[I]);
  end;
  // AIniFile.WriteString('IOSPlistRootNodes','-','');
  // AIniFile.WriteString('IOSPlistRootNodes','--','');
  // AIniFile.WriteString('IOSPlistRootNodes','---','');

  // IOS链接参数
  AIniFile.WriteString('', 'IOSLinkerOptions', FIOSLinkerOptions);

  FreeAndNil(AIniFile);

end;

{ TDeployConfigList }

function TDeployConfigList.GetItem(Index: Integer): TDeployConfig;
begin
  Result := TDeployConfig(Inherited Items[Index]);
end;

function TDeployConfigList.GeneratePreviewDeployFileList
  (AProjectPath: String): Boolean;
var
  I: Integer;
  J: Integer;

  AFileName:        String;
  AFileExt:         String;
  AFileNameNoExt:   String;
  ARenamedFileName: String;
  AFileDir:         String;
  ASDKName:         String;
  AAbsolutePath:    String;

  ADelimList:          TStringList;
  ADeployFile:         TDeployFile;
  ADeployFilePlatform: TDeployFilePlatform;

  ADeployConfig: TDeployConfig;
begin
  Result := False;

  Self.FPreviewDeployFileList.Clear(True);

  // MatisseSDK_0_4_3\matisse-0.4.3\res\
  // res\
  for I := 0 to Self.Count - 1 do
  begin

    ADeployConfig := Items[I];
    // 加载此布署项里本地所有文件列表
    // LocalFiles-RemoteFiles配对的
    // 比如:
    // LocalFiles:   .\TwitterKitSDK\tweet-composer-3.0.0\res\values\values.xml
    // RemoteFiles:  res\values\
    ADeployConfig.LoadFileList(ExtractFilePath(AProjectPath));

    // 如果是aar有重名的那种values.xml，那么需要重命名
    if ADeployConfig.RemoteDir = 'res\' then
    begin

      ASDKName                   := '';
      ADelimList                 := TStringList.Create;
      ADelimList.Delimiter       := '\';
      ADelimList.StrictDelimiter := True;
      ADelimList.DelimitedText   := ADeployConfig.LocalDir;
      if ADelimList.IndexOf('res') > 1 then
      begin
        ASDKName := ADelimList[ADelimList.IndexOf('res') - 1];
      end;
      FreeAndNil(ADelimList);

      if ASDKName <> '' then
      begin

        ASDKName := ReplaceStr(ASDKName, '.', '_');
        ASDKName := ReplaceStr(ASDKName, '-', '_');
        for J    := 0 to ADeployConfig.LocalFiles.Count - 1 do
        begin
          AFileName      := ADeployConfig.LocalFiles[J];
          AFileDir       := ExtractFilePath(AFileName);
          AFileName      := ExtractFileName(AFileName);
          AFileExt       := ExtractFileExt(AFileName);
          AFileNameNoExt := Copy(AFileName, 1, Length(AFileName) -
            Length(AFileExt));

          if (Pos(LowerCase(ASDKName), LowerCase(AFileNameNoExt)) = 0)
          // 没有被重命名过
            and (AFileExt = '.xml')
            and ((Copy(AFileNameNoExt, 1, 6) = 'values')
            or (Copy(AFileNameNoExt, 1, 6) = 'colors')
            or (Copy(AFileNameNoExt, 1, 7) = 'strings')
            or (Copy(AFileNameNoExt, 1, 6) = 'styles')) then
          begin
            // 判断是否已经重命名过
            ARenamedFileName := AFileNameNoExt + '_' + ASDKName + AFileExt;
            // 相对目录要转换成绝对目录
            AAbsolutePath := ConvertRelativePathToAbsolutePath
              (ExtractFilePath(AProjectPath), ADeployConfig.LocalFiles[J]);

            ReNameFile(AAbsolutePath,
              ExtractFilePath(AAbsolutePath) + ARenamedFileName);
            ADeployConfig.LocalFiles[J] :=
              ExtractFilePath(ADeployConfig.LocalFiles[J]) + ARenamedFileName;

          end;
        end;
      end;

    end;

    for J := 0 to ADeployConfig.LocalFiles.Count - 1 do
    begin

      // 需要添加
      // 直接添加
      ADeployFile := TDeployFile.Create;
      // 添加
      FPreviewDeployFileList.Add(ADeployFile);

      ADeployFile.LocalName := ADeployConfig.LocalFiles[J];
      ADeployFile.Class_    := 'File';

      // 布署到指定平台
      ADeployFilePlatform           := TDeployFilePlatform.Create;
      ADeployFilePlatform.Platform_ := ADeployConfig.Platform_;

      // 取出文件名
      ADeployFilePlatform.RemoteName :=
        ExtractFileName(ADeployConfig.RemoteFiles[J]);
      // 取出文件路径
      ADeployFilePlatform.RemoteDir :=
        ExtractFilePath(ADeployConfig.RemoteFiles[J]);
      // 避免每次都布署
      ADeployFilePlatform.Overwrite := 'False';

      ADeployFile.Platforms.Add(ADeployFilePlatform);

      if ADeployConfig.Platform_ = 'Android' then
      begin
        // 布署到指定平台
        ADeployFilePlatform           := TDeployFilePlatform.Create;
        ADeployFilePlatform.Platform_ := 'Android64';
        // 取出文件名
        ADeployFilePlatform.RemoteName :=
          ExtractFileName(ADeployConfig.RemoteFiles[J]);
        // 取出文件路径
        ADeployFilePlatform.RemoteDir :=
          ExtractFilePath(ADeployConfig.RemoteFiles[J]);
        // 避免每次都布署
        ADeployFilePlatform.Overwrite := 'False';
        ADeployFilePlatform.Enabled   := 'true';
        ADeployFile.Platforms.Add(ADeployFilePlatform);
      end;
    end;
  end;

  Result := True;
end;

constructor TDeployConfigList.Create(
  const AObjectOwnership: TObjectOwnership;
  const AIsCreateObjectChangeManager: Boolean);
begin
  inherited;

  FPreviewDeployFileList := TDeployFileList.Create;

end;

destructor TDeployConfigList.Destroy;
begin
  FreeAndNil(FPreviewDeployFileList);
  inherited;
end;

{ TDeployConfig }

constructor TDeployConfig.Create;
begin
  LocalFiles  := TStringList.Create;
  RemoteFiles := TStringList.Create;

end;

destructor TDeployConfig.Destroy;
begin
  FreeAndNil(LocalFiles);
  FreeAndNil(RemoteFiles);
  inherited;
end;

procedure TDeployConfig.LoadFileList(AProjectDir: String);
var
  I:                 Integer;
  AAbsolutePath:     String;
  AAbsoluteFileList: TStringList;
begin
  Self.LocalFiles.Clear;
  Self.RemoteFiles.Clear;

  // 相对目录要转换成绝对目录
  AAbsolutePath := ConvertRelativePathToAbsolutePath(AProjectDir, LocalDir);

  if FileExists(AAbsolutePath) then
  begin
    // 是单个文件
    Self.LocalFiles.Add(Self.LocalDir);
    Self.RemoteFiles.Add(Self.RemoteDir + ExtractFileName(Self.LocalDir));
  end
  else if DirectoryExists(AAbsolutePath) then
  begin
    AAbsoluteFileList := TStringList.Create;
    try
      DoGetFileList(AAbsolutePath, AAbsoluteFileList);
      for I := 0 to AAbsoluteFileList.Count - 1 do
      begin
        Self.LocalFiles.Add(
          ConvertAbsolutePathToRelativePath(AProjectDir, AAbsoluteFileList[I])
        );

        Self.RemoteFiles.Add(
          Self.RemoteDir +
          Copy(AAbsoluteFileList[I], Length(AAbsolutePath) + 1, MaxInt)
        );
      end;
    finally
      FreeAndNil(AAbsoluteFileList);
    end;
  end
  else
  begin
    ShowMessage(GetLangString(['布署文件不存在:' + AAbsolutePath,
      'File is not exist:' + AAbsolutePath]));
    // '布署文件不存在:'+AAbsolutePath);
  end;

end;

{ TConfigVariableList }

function TConfigVariableList.FindItemByName(AName: String): TConfigVariable;
var
  I: Integer;
begin
  Result := nil;
  for I  := 0 to Self.Count - 1 do
  begin
    if Items[I].Name = AName then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TConfigVariableList.GetItem(Index: Integer): TConfigVariable;
begin
  Result := TConfigVariable(Inherited Items[Index]);
end;

initialization
  GlobalDeployConfigRemoteDirList := TStringList.Create;
  GlobalDeployConfigRemoteDirList.Add('StartUp\Documents\');

  GlobalDeployConfigRemoteDirList.Add('.\assets\internal\');
  GlobalDeployConfigRemoteDirList.Add('library\lib\armeabi-v7a\');
  GlobalDeployConfigRemoteDirList.Add('res\');
  GlobalDeployConfigRemoteDirList.Add('res\values\');
  GlobalDeployConfigRemoteDirList.Add('res\xml\');
  GlobalDeployConfigRemoteDirList.Add('res\layout\');
  GlobalDeployConfigRemoteDirList.Add('res\drawable\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-hdpi\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-large\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-ldpi\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-mdpi\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-normal\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-small\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-xhdpi\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-xlarge\');
  // GlobalDeployConfigRemoteDirList.Add('res\drawable-xxhdpi\');
  GlobalDeployConfigRemoteDirList.Add('.\assets\');
  GlobalDeployConfigRemoteDirList.Add('.\');

  GlobalIOSFrameworkList := TStringList.Create;
  GlobalIOSFrameworkList.Add('UserNotifications');
  GlobalIOSFrameworkList.Add('CoreAudio');
  GlobalIOSFrameworkList.Add('MediaToolbox');
  GlobalIOSFrameworkList.Add('Metal');
  GlobalIOSFrameworkList.Add('CoreTelephony');
  GlobalIOSFrameworkList.Add('SystemConfiguration');
  GlobalIOSFrameworkList.Add('AdSupport');
  GlobalIOSFrameworkList.Add('AudioToolbox');
  GlobalIOSFrameworkList.Add('CoreMIDI');
  GlobalIOSFrameworkList.Add('CoreBluetooth');
  GlobalIOSFrameworkList.Add('JavaScriptCore');
  GlobalIOSFrameworkList.Add('Photos');
  GlobalIOSFrameworkList.Add('ImageIO');
  GlobalIOSFrameworkList.Add('CoreMotion');
  GlobalIOSFrameworkList.Add('PushKit');
  GlobalIOSFrameworkList.Add('SafariServices');
  GlobalIOSFrameworkList.Add('CoreData');
  GlobalIOSFrameworkList.Add('Accounts');
  GlobalIOSFrameworkList.Add('FileProvider');
  GlobalIOSFrameworkList.Add('IOSurface');
  GlobalIOSFrameworkList.Add('TouchJSON');
  GlobalIOSFrameworkList.Add('AudioToolBox');
  GlobalIOSFrameworkList.Add('Social');
  GlobalIOSFrameworkList.Add('LocalAuthentication');
  GlobalIOSFrameworkList.Add('WebKit');
  GlobalIOSFrameworkList.Add('AuthenticationServices');
  GlobalIOSFrameworkList.Add('ContactsUI');
  GlobalIOSFrameworkList.Add('OpenAL');
  GlobalIOSFrameworkList.Add('VideoToolbox');
  GlobalIOSFrameworkList.Add('ReplayKit');
  GlobalIOSFrameworkList.Add('ModelIO');
  GlobalIOSFrameworkList.Add('AVKit');
  GlobalIOSFrameworkList.Add('AddressBook');
  GlobalIOSFrameworkList.Add('Contacts');
  GlobalIOSFrameworkList.Add('QuickLook');
  GlobalIOSFrameworkList.Add('PhotosUI');

  GlobalIOSDylibList := TStringList.Create;
  GlobalIOSDylibList.Add('libicucore.tbd');
  GlobalIOSDylibList.Add('libresolv.tbd');

finalization
  GlobalDeployConfigRemoteDirList.Free;
  GlobalIOSFrameworkList.Free;
  GlobalIOSDylibList.Free;

end.
