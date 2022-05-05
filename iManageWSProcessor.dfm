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
  object MemoContent: TMemo
    Left = 528
    Top = 32
    Width = 233
    Height = 137
    Lines.Strings = (
      'r67uzN1iTEXBlmcfvbgpe1uWkb9Zbha1Ldxp9is'
      'p3NJUVuccftiHfqzxE0yyzFgV')
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 576
    Top = 240
    Width = 377
    Height = 21
    TabOrder = 2
  end
  object Edittoken_type: TEdit
    Left = 448
    Top = 336
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object MemoContent2: TMemo
    Left = 728
    Top = 256
    Width = 209
    Height = 113
    TabOrder = 4
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
  object RESTClient1: TRESTClient
    Accept = '*/*'
    AcceptCharset = 'UTF-8, *;q=0.8'
    AcceptEncoding = 'gzip, deflate, br'
    BaseURL = 'https://imancontrol.incegd.com/'
    ContentType = 'application/x-www-form-urlencoded'
    Params = <>
    HandleRedirects = True
    Left = 24
    Top = 120
  end
  object RESTRQiManWS_Login: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient1
    Method = rmPOST
    Params = <>
    Resource = 
      'auth/oauth2/token?username=epmsdev&password=newyork&grant_type=p' +
      'assword&client_id=RESTAPISCRIPTS&client_secret= &scope=admin'
    Response = RESTRSWS_Login
    SynchronizedEvents = False
    Left = 112
    Top = 120
  end
  object RESTRSWS_Login: TRESTResponse
    ContentType = 'application/json'
    Left = 208
    Top = 120
  end
  object OAuth2Auth1: TOAuth2Authenticator
    AccessToken = 'm5rbc/UfPRDq18fJz/r081TbvkWuo3X/gjYUCqGUFTSKetlKuBTV+O1dvvMYgqXw'
    AccessTokenEndpoint = 
      'https://imancontrol.incegd.com/auth/oauth2/token?username=epmsde' +
      'v&password=newyork&grant_type=password&client_id=RESTAPISCRIPTS&' +
      'client_secret= &scope=admin'
    AccessTokenParamName = 'X-Auth-Token'
    ClientID = 'RESTAPISCRIPTS'
    ResponseType = rtTOKEN
    Scope = 'admin'
    TokenType = ttBEARER
    Left = 40
    Top = 200
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 20
    Top = 21
    object LinkControlToField2: TLinkControlToField
      Category = 'Quick Bindings'
      DataSource = BindSourceDB1
      FieldName = 'access_token'
      Control = Edit1
      Track = True
    end
    object LinkControlToFieldtoken_type: TLinkControlToField
      Category = 'Quick Bindings'
      DataSource = BindSourceDB1
      FieldName = 'token_type'
      Control = Edittoken_type
      Track = True
    end
  end
  object FDMemTable1: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'access_token'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'expires_in'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'token_type'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'scope'
        DataType = ftWideString
        Size = 255
      end
      item
        Name = 'refresh_token'
        DataType = ftWideString
        Size = 255
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 528
    Top = 184
  end
  object BindSourceDB1: TBindSourceDB
    DataSet = FDMemTable1
    ScopeMappings = <>
    Left = 456
    Top = 200
  end
  object RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter
    Active = True
    Dataset = FDMemTable1
    FieldDefs = <>
    Response = RESTRSWS_Login
    Left = 640
    Top = 192
  end
  object RESTRQiManWS_CheckExists: TRESTRequest
    Accept = '*/*'
    AcceptEncoding = 'gzip, deflate, br'
    Client = RESTClient3
    Params = <
      item
        name = 'custom2'
        Value = 'G.TES.9999'
        ContentType = ctAPPLICATION_JSON
      end>
    Resource = 
      'work/api/v2/customers/100/libraries/eu_gdg_open/workspaces/searc' +
      'h'
    Response = RESTRSWS_CheckExists
    SynchronizedEvents = False
    Left = 96
    Top = 192
  end
  object RESTRSWS_CheckExists: TRESTResponse
    ContentType = 'application/json'
    ContentEncoding = 'gzip'
    Left = 120
    Top = 240
  end
  object RESTClient3: TRESTClient
    Accept = '*/*'
    AcceptCharset = 'UTF-8, *;q=0.8'
    AcceptEncoding = 'gzip, deflate, br'
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
  object RESTClient4: TRESTClient
    Authenticator = OAuth2Auth1
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    BaseURL = 
      'https://euimancontrol.incegd.com/work/api/v2/customers/100/libra' +
      'ries/eu_gdg_open/workspaces/search'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 16
    Top = 256
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
        Kind = pkFILE
        name = 'X-Auth-Token'
        Options = [poDoNotEncode]
        Value = 'cd3q6AaCBPGHRaHc8T/A8MkUVdZmZB/GO3JbOBugS0GjXnGMjd2Co+6nBjHvb1pm'
      end
      item
        name = 'custom2'
        Value = 'G.TES.4-1'
      end>
    Response = rResponseCreate
    SynchronizedEvents = False
    Left = 400
    Top = 408
  end
  object rResponseCreate: TRESTResponse
    ContentType = 'text/html'
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
    Params = <
      item
        Kind = pkFILE
        name = 'X-Auth-Token'
        Options = [poDoNotEncode]
        Value = 'cd3q6AaCBPGHRaHc8T/A8MkUVdZmZB/GO3JbOBugS0GjXnGMjd2Co+6nBjHvb1pm'
      end
      item
        name = 'custom2'
        Value = 'G.TES.4-1'
      end>
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
    Params = <
      item
        Kind = pkFILE
        name = 'X-Auth-Token'
        Options = [poDoNotEncode]
        Value = 'cd3q6AaCBPGHRaHc8T/A8MkUVdZmZB/GO3JbOBugS0GjXnGMjd2Co+6nBjHvb1pm'
      end
      item
        Kind = pkREQUESTBODY
        name = 'body'
        Value = '{"end"}'
      end>
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
end
