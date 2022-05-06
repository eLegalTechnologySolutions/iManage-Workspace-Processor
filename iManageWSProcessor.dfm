object fiManWSProcessor: TfiManWSProcessor
  Left = 0
  Top = 0
  Caption = 'eLegal iManage WorkSpace Processor'
  ClientHeight = 652
  ClientWidth = 999
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 592
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 640
    Top = 144
    Width = 75
    Height = 25
    Caption = 'test'
    TabOrder = 1
    OnClick = Button2Click
  end
  object iManageSQLServer: TSQLServerUniProvider
    Left = 248
    Top = 72
  end
  object iManageSQLConn: TUniConnection
    ProviderName = 'SQL Server'
    Port = 1433
    Database = 'WSC'
    Username = 'sa'
    Server = 'EUIMANSQL01.INCEGD.COM'
    Connected = True
    LoginPrompt = False
    Left = 256
    Top = 24
    EncryptedPassword = 
      '8CFF8BFF90FF8FFF83FFB2FFBEFFA6FFB0FFADFF83FF96FF91FF9BFF96FF9EFF' +
      '83FFBBFFB6FFADFFBAFFBCFFABFF'
  end
  object iManageTargetDB: TUniConnection
    ProviderName = 'SQL Server'
    Port = 1433
    Database = 'WSC_COPY'
    Username = 'sa'
    Server = 'EUIMANSQL01.INCEGD.COM'
    Connected = True
    LoginPrompt = False
    Left = 376
    Top = 72
    EncryptedPassword = 
      '8CFF8BFF90FF8FFF83FFB2FFBEFFA6FFB0FFADFF83FF96FF91FF9BFF96FF9EFF' +
      '83FFBBFFB6FFADFFBAFFBCFFABFF'
  end
  object qNewWSClients: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'CLIENT'#39
      'and Wsid is not null'
      'and C1Alias is not null'
      'and C5Alias is not null'
      'and Default_Security_Group is not null')
    Left = 312
    Top = 128
  end
  object qNewWSMatters: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'MATTER'#39
      'and Wsid is not null'
      'and C1Alias is not null'
      'and C2Alias is not null'
      'and C5Alias is not null'
      'and Default_Security_Group is not null')
    Left = 416
    Top = 128
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 20
    Top = 65525
  end
  object RESTClient3: TRESTClient
    Accept = '*/*'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 'https://imancontrol.incegd.com/'
    ContentType = 'application/json'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 32
    Top = 392
  end
  object rRequestLogin: TRESTRequest
    Accept = '*/*'
    Client = RESTClient3
    Method = rmPUT
    Params = <
      item
        Kind = pkREQUESTBODY
        name = 'body'
        Options = [poDoNotEncode]
        Value = 
          '{'#10'"user_id" : "epmsdev",'#10'"password" : "newyork",'#10'"persona" : "us' +
          'er",'#10'"application_name" : "ePMS"'#10'}'
        ContentType = ctAPPLICATION_JSON
      end>
    Resource = 'api/v1/session/login'
    Response = rResponseLogin
    SynchronizedEvents = False
    Left = 136
    Top = 392
  end
  object rResponseLogin: TRESTResponse
    ContentType = 'application/json'
    RootElement = 'X-Auth-Token'
    Left = 240
    Top = 392
  end
  object rRequestCheckWSExists: TRESTRequest
    Accept = '*/*'
    Client = RESTClient3
    Params = <>
    Response = rResponseCheckWSExists
    SynchronizedEvents = False
    Left = 96
    Top = 472
  end
  object rResponseCheckWSExists: TRESTResponse
    ContentType = 'text/html'
    RootElement = 'X-Auth-Token'
    Left = 240
    Top = 472
  end
  object qCheckClientID: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      ''
      '/*select * '
      'from MHGROUP.CUSTOM1'
      'where CUSTOM_ALIAS = :C1Alias'
      '*/'
      'select * from eu_gdg_open.MHGROUP.CUSTOM1'
      'where CUSTOM_ALIAS = '#39'G.TES.4'#39)
    Left = 312
    Top = 184
  end
  object qCheckMatterID: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'CLIENT'#39)
    Left = 312
    Top = 240
  end
  object qCheckEntity: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'CLIENT'#39)
    Left = 320
    Top = 296
  end
  object qCheckDept: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'CLIENT'#39)
    Left = 312
    Top = 360
  end
  object qDBList: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select Distinct DBID '
      'from Staging'
      'where FolderId is null')
    Left = 400
    Top = 184
  end
  object rRequestCreate: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient3
    Method = rmPOST
    Params = <
      item
        Kind = pkREQUESTBODY
        name = 'body'
        Options = [poDoNotEncode]
        Value = 
          '{"author": "wsadmin","class": "WEBDOC","default_security": "priv' +
          'ate","description": "001.BOD10 - Alan & Patricia Joan Bodill","n' +
          'ame": "001.BOD10 - Alan & Patricia Joan Bodill","owner": "wsadmi' +
          'n"}'
        ContentType = ctAPPLICATION_JSON
      end>
    Resource = 'work/api/v2/customers/100/libraries/EU_GDG_OPEN/workspaces'
    Response = rResponseCreate
    SynchronizedEvents = False
    Left = 400
    Top = 408
  end
  object rResponseCreate: TRESTResponse
    ContentType = 'application/json'
    RootElement = 'data'
    Left = 504
    Top = 408
  end
  object qUpdateWSID: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'update Staging'
      'set FolderId = :FolderID'
      'Where WSID = :UniqueID')
    Left = 504
    Top = 472
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'FolderID'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'UniqueID'
        Value = nil
      end>
  end
  object qCreateCUSTOMAlias: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      
        'INSERT INTO :CUSTOMTABLE(CUSTOM_ALIAS, C_DESCRIPT, ENABLED, EDIT' +
        'WHEN, IS_HIPAA)'
      'VALUES (:CUSTOM_ALIAS, :DESCRIPT, '#39'Y'#39', GETDATE(), '#39'N'#39')  ')
    Left = 600
    Top = 472
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CUSTOMTABLE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CUSTOM_ALIAS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DESCRIPT'
        Value = nil
      end>
  end
  object qCreateCustom2Alias: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      
        'INSERT INTO :CUSTOMTABLE(CPARENT_ALIAS, CUSTOM_ALIAS, C_DESCRIPT' +
        ', ENABLED, EDITWHEN, IS_HIPAA)'
      
        'VALUES (:CPARENT_ALIAS, :CUSTOM_ALIAS, :DESCRIPT, '#39'Y'#39', GETDATE()' +
        ', '#39'N'#39')  ')
    Left = 712
    Top = 472
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'CUSTOMTABLE'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CPARENT_ALIAS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'CUSTOM_ALIAS'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'DESCRIPT'
        Value = nil
      end>
  end
  object rRequestUpdate: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient3
    Method = rmPATCH
    Params = <>
    Response = rResponseUpdate
    SynchronizedEvents = False
    Left = 600
    Top = 408
  end
  object rResponseUpdate: TRESTResponse
    ContentType = 'text/html'
    RootElement = 'data'
    Left = 688
    Top = 408
  end
  object rRequestSetWSPerms: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient3
    Method = rmPOST
    Params = <>
    Response = rResponseSetWSPerms
    SynchronizedEvents = False
    Left = 808
    Top = 408
  end
  object rResponseSetWSPerms: TRESTResponse
    ContentType = 'text/html'
    RootElement = 'data'
    Left = 920
    Top = 416
  end
  object qCheckWSExists: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select top 1 * '
      'from eu_gdg_open.MHGROUP.PROJECTS where CUSTOM1 = '#39'G.TES.4-1'#39)
    Left = 392
    Top = 280
  end
  object RESTRequest1test: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient3
    Method = rmPOST
    Params = <
      item
        Kind = pkREQUESTBODY
        name = 'body'
        Options = [poDoNotEncode]
        Value = 
          '{"author": "wsadmin","class": "WEBDOC","default_security": "priv' +
          'ate","description": "001.BOD10 - Alan & Patricia Joan Bodill","n' +
          'ame": "001.BOD10 - Alan & Patricia Joan Bodill","owner": "wsadmi' +
          'n"}'
        ContentType = ctAPPLICATION_JSON
      end>
    Resource = 'work/api/v2/customers/100/libraries/EU_GDG_OPEN/workspaces'
    Response = RESTResponse1test
    SynchronizedEvents = False
    Left = 352
    Top = 544
  end
  object RESTResponse1test: TRESTResponse
    ContentType = 'application/json'
    RootElement = 'data'
    Left = 448
    Top = 552
  end
  object qtest: TUniQuery
    Connection = iManageSQLConn
    SQL.Strings = (
      'select * '
      'from Staging'
      'where FolderId is null'
      'and Category = '#39'CLIENT'#39
      'and Wsid is not null'
      'and C1Alias is not null'
      'and C5Alias is not null'
      'and Default_Security_Group is not null'
      'and wsid = '#39'001.BOD10'#39)
    Left = 592
    Top = 176
  end
end
