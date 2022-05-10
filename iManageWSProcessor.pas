unit iManageWSProcessor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, DBAccess, Uni, UniProvider,
  SQLServerUniProvider, IPPeerClient, Vcl.StdCtrls, REST.Client, REST.Types,
  REST.Authenticator.OAuth, Data.Bind.Components, Data.Bind.ObjectScope, MemDS,
  System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  REST.Response.Adapter, Data.Bind.DBScope, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfiManWSProcessor = class(TForm)
    iManageSQLServer: TSQLServerUniProvider;
    iManageSQLConn: TUniConnection;
    iManageTargetDB: TUniConnection;
    qNewWSClients: TUniQuery;
    qNewWSMatters: TUniQuery;
    Button1: TButton;
    BindingsList1: TBindingsList;
    RESTClient3: TRESTClient;
    rRequestLogin: TRESTRequest;
    rResponseLogin: TRESTResponse;
    rRequestCheckWSExists: TRESTRequest;
    rResponseCheckWSExists: TRESTResponse;
    qCheckClientID: TUniQuery;
    qCheckMatterID: TUniQuery;
    qCheckEntity: TUniQuery;
    qCheckDept: TUniQuery;
    qDBList: TUniQuery;
    rRequestCreate: TRESTRequest;
    rResponseCreate: TRESTResponse;
    qUpdateWSID: TUniQuery;
    qCreateCUSTOMAlias: TUniQuery;
    qCreateCustom2Alias: TUniQuery;
    rRequestUpdate: TRESTRequest;
    rResponseUpdate: TRESTResponse;
    rRequestSetWSPerms: TRESTRequest;
    rResponseSetWSPerms: TRESTResponse;
    qCheckWSExists: TUniQuery;
    RESTRequest1test: TRESTRequest;
    RESTResponse1test: TRESTResponse;
    Button2: TButton;
    qtest: TUniQuery;
    qWriteLog: TUniQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    CurrentWSID: string;
    Log_WSID : string;
    Log_Client_ID, Log_Matter_ID : string;
    Log_Custom1, Log_Custom2, Log_Custom3, Log_Custom5, Log_Custom6, Log_Custom8 : string;
    Log_Workspace_ID, Log_WS_MetaData, Log_Permissions : string;
    Log_WSRootFolders, Log_Extra_Data : string;

    Function CheckWSExists(fWSID : string; fDB : string):boolean;
    Function CheckClientID(fClientID : string; fDB : string):boolean;
    Function CheckEntity(fEntityID : string; fDB : string):boolean;
    Function CreateCustomAlias(fCTable : string; fCAlias : string; fDescript : string):boolean;
    Function CreateClientWS():boolean;
    Function UpdateClientWS():boolean;
    Function SetWSPerms(fDBID : string; fPermGroup : string):boolean;
    Function CreateWSRootFolders(fDBID : string):boolean;
    Function test():boolean;
    Procedure WriteLog();

//    function testfoldercreate():boolean;
  public
    { Public declarations }
    AuthToken: string;
//    AuthTokenType: string;
//    AuthTokenExpire: integer;
  end;

var
  fiManWSProcessor: TfiManWSProcessor;

const
  v2APIBase = 'work/api/v2/customers/100/libraries/';

implementation
uses
  system.json;
//  REST.Types,
//  REST.Utils;
{$R *.dfm}

procedure TfiManWSProcessor.Button1Click(Sender: TObject);
//var
//  DBConn : TUniConnection;
//  AuthExpireText : string;
//  obj, data: TJSONObject;
//  response : TclJSONObject;
begin

//  OAuth2Auth1.
//  RESTRQiManWS_Login.Execute;

//  obj := RESTRSWS1.JSONValue as TJSONObject;
//  response := RESTRSWS1.ParseObject(responseBody.DataString);
//  data := obj.Values[''] as TJSONObject;
//  RESTRSWS1.GetSimpleValue('access_token');
//  Edit1.Text := data.ToString;
//RESTRSWS1.JSONText('access_token');
//OAuth2Auth1.AccessToken := Edit1.Text;
{  With RESTRequest1 do
  begin
    AddAuthParameter('grant_type', 'Password', pkGETorPOST);
//    AddAuthParameter(');
  end;
}
{
  RESTRSWS_Login.GetSimpleValue('access_token', AuthToken);
  RESTRSWS_Login.GetSimpleValue('token_type', AuthTokenType);
  RESTRSWS_Login.GetSimpleValue('expires_in', AuthExpireText);
  AuthTokenExpire := AuthExpireText.ToInteger;

  RESTrequest1.AddAuthParameter('x-auth-token',AuthToken, pkHTTPHEADER);
  RESTrequest1.AddAuthParameter('token_type',AuthTokenType, pkHTTPHEADER);
  RESTrequest1.AddAuthParameter('expires_in',AuthExpireText, pkHTTPHEADER);
}
//  qNewWSClients.Open;
  //rRequestLogin.Execute;
  qNewWSClients.Open;
  qNewWSClients.First;
  while not qNewWSClients.Eof do
  begin
    CurrentWSID := '';
    If not CheckWSExists(qNewWSClients.FieldByName('C1Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
    Begin
      If Not CheckClientID(qNewWSClients.FieldByName('C1Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
      begin
        //Create New Custom1
        CreateCustomAlias(qNewWSClients.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM1', qNewWSClients.FieldByName('C1Alias').AsString,
                          qNewWSClients.FieldByName('C1Desc').AsString);
      end;

      If Not CheckEntity(qNewWSClients.FieldByName('C5Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
      begin
        //Create New Custom5
        CreateCustomAlias(qNewWSClients.FieldByName('DBId').AsString + '.MHGROUP.CUSTOM5', qNewWSClients.FieldByName('C5Alias').AsString,
                          qNewWSClients.FieldByName('C5Desc').AsString);
      end;

      //Create new client workspace
      rRequestLogin.Execute;
      If CreateClientWS then
      begin
        UpdateClientWS;
        SetWSPerms(qNewWSClients.FieldByName('DBId').AsString, qNewWSClients.FieldByName('Default_Security_Group').AsString);
        CreateWSRootFolders(qNewWSClients.FieldByName('DBId').AsString);
      end
    End
    else
    begin
      //Record as already existing
    end;;
    qNewWSClients.Next;
  end;

  qNewWSClients.Close;

  rRequestLogin.Execute;
  rResponseLogin.GetSimpleValue('X-Auth-token', AuthToken);

end;

Function TfiManWSProcessor.CheckWSExists(fWSID : string; fDB : string):boolean;
Begin
  Result := False;
  try
  ;
    With qCheckWSExists do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'select top 1 * from ' + fDB + '.MHGROUP.PROJECTS ' +
                  'where CUSTOM1 = ' + QuotedStr(fWSID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_WSID := 'N';
      end
      else
      begin
        Result := True;
        Log_WSID := 'Y';
      end;
      Close;
    end;
  except on E: Exception do
    begin
      Result := False;
      Log_WSID := 'Error';
    end;
  end
End;

procedure TfiManWSProcessor.Button2Click(Sender: TObject);
begin
  test;
end;

Function TfiManWSProcessor.CheckClientID(fClientID : string; fDB : string):boolean;
Begin
  try

    Result := False;
    With qCheckClientID Do
    Begin
      Close;
  {    if fDB = 'AE_OPEN' then
        Connection := conn_AE_OPEN
      else if fDB = 'AP_OPEN' then
        Connection := conn_AP_OPEN
      else if fDB = 'EU_OPEN' then
        Connection := conn_EU_OPEN
      else if fDB = 'EU_GDG_OPEN' then
        Connection := conn_EU_GDG_OPEN;
      ParamByName('C1Alias').AsString := fClientID; }
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM1 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fClientID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Client_ID := 'N';
      end
      else
      begin
        Result := True;
        Log_Client_ID := 'Exists';
      end;
      Close;
    End;

  except on E: Exception do
    begin
      Result := False;
      Log_Client_ID := 'Error';
    end;
  end;
End;

Function TfiManWSProcessor.CheckEntity(fEntityID : string; fDB : string):boolean;
Begin
  try


    Result := False;
    With qCheckEntity Do
    Begin
      Close;
      SQL.Clear;
      SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM5 ' +
                  'where CUSTOM_ALIAS = ' + QuotedStr(fEntityID);
      Open;
      if IsEmpty then
      begin
        Result := False;
        Log_Custom5 := 'N';
      end
      else
      begin
        Result := True;
        Log_Custom5 := 'Exists';
      end;
      Close;

    End;
  except on E: Exception do
    begin
      Result := False;
      Log_Custom5 := 'Error';
    end;
  end;
End;

Function TfiManWSProcessor.CreateCustomAlias(fCTable : string; fCAlias : string; fDescript : string):boolean;
Begin

  try
    Result := False;
    With qCreateCUSTOMAlias do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'INSERT INTO ' + fCTable +'(CUSTOM_ALIAS, C_DESCRIPT, ENABLED, EDITWHEN, IS_HIPAA) ' +
                  'VALUES (' + quotedstr(fCAlias) + ', ' + quotedstr(fDescript) + ', ''Y'', GETDATE(), ''N'')';
      {ParamByName('CUSTOMTABLE').AsString := fCTable;
      ParamByName('CUSTOM_ALIAS').AsString := fCAlias;
      ParamByName('DESCRIPT').AsString := fDescript; }
      Execute;
    end;
    Result := True;
  except on E: Exception do
    begin
    Result := False;
    end;
  end;
End;

Function TfiManWSProcessor.CreateClientWS():boolean;
var
  rBody, rFolderID, rLongDB : string;
  ClientJSONObject : tjsonobject;
Begin
  try
    Result := False;
    rResponseCreate.Content.Empty;

    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces';
    rBody := '{"author": "wsadmin","class": "WEBDOC","default_security": "' +
            LowerCase(qNewWSClients.FieldByName('DefaultVisibility').AsString) +
            '","description": "' + qNewWSClients.FieldByName('Description').AsString +
            '","name": "' + qNewWSClients.FieldByName('Name').AsString +
            '","owner": "wsadmin"}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;

    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      //update staging with folder id
      ClientJSONObject := rResponseCreate.JSONValue as TJSONObject;
      CurrentWSID := ClientJSONObject.GetValue('workspace_id').Value;

      rLongDB := qNewWSClients.FieldByName('DBId').AsString + '!';
      rFolderID := StringReplace(CurrentWSID, rLongDB, '', [rfIgnoreCase]);
      qUpdateWSID.ParamByName('FolderID').AsString := rFolderID;
      qUpdateWSID.ParamByName('UniqueID').AsString := qNewWSClients.FieldByName('C1Alias').AsString;
      qUpdateWSID.Execute;
      result := True;
      Log_Workspace_ID := CurrentWSID;
//    ClientJSONObject.Free;

    end
    else
    begin
      //record failure
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_Workspace_ID := 'Response = ' + IntToStr(rResponseCreate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.UpdateClientWS():boolean;
var
  rBody, rWSID, rFolderID, rProspective: string;
Begin
  try
    Result := False;
    rResponseUpdate.Content.Empty;
    //update workspace with extra metadata
    if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
    rProspective := 'true'
    else
      rProspective := 'false';
    rRequestUpdate.Params.Clear;
    rRequestUpdate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces/' + CurrentWSID;
    ///work/api/v2/customers/{customerId}/libraries/{libraryId}/workspaces/{workspaceId}
    rBody := '{"custom1": "' +  qNewWSClients.FieldByName('C1Alias').AsString +
              '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString +
              '","custom25": "' + rProspective  +
              '","sub_class": "CLIENT' +
              '","project_custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
              '","project_custom2": "' + qNewWSClients.FieldByName('TemplateId').AsString +
              '","project_custom3": "Worksite"}';

    {
    '{"author": "epmsdev","class": "WEBDOC","default_security": "' + qNewWSClients.FieldByName('DefaultVisibility').AsString +
            '","description": "' + qNewWSClients.FieldByName('Description').AsString +
            '","name": "' + qNewWSClients.FieldByName('Name').AsString +
            '","owner": "epmsdev"}
            //';  }

    //{"author": "epmsdev","class": "WEBDOC","default_security": "public","description": "JR Test Workspace",
    //"name": "001 - JR Test Workspace","owner": "epmsdev"}
  //  rRequestUpdate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestUpdate.Execute;
    if rResponseUpdate.StatusCode = 200 then
    begin
      //update staging with folder id
   {   rResponseCreate.GetSimpleValue('workspace_id', rWSID);
      rFolderID := rWSID.Substring(pos(rWSID,'!')+1);
      qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
      qUpdateWSID.Execute;    }
      result := True;
      Log_WS_MetaData := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;

  except on E: Exception do
    begin
      result := False;
      Log_WS_MetaData := 'Status = ' + IntToStr(rResponseUpdate.StatusCode);
    end;
  end;
End;

Function TfiManWSProcessor.SetWSPerms(fDBID : string; fPermGroup : string):boolean;
var
  rBody : string;
Begin
  try
    Result := False;
    rResponseSetWSPerms.Content.Empty;
    rRequestSetWSPerms.Params.Clear;
    rRequestSetWSPerms.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/security';
    rBody := '{"default_security": "private", ' +
              '"include": [{ "id" : "WSADMIN", "access_level" : "full_access", "type": "user" },' +
              '{ "id" : "' + fPermGroup + '", "access_level" : "full_access", "type" : "group" }]}';
  //  rRequestSetWSPerms.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestSetWSPerms.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestSetWSPerms.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestSetWSPerms.Execute;
    if rResponseSetWSPerms.StatusCode = 200 then
    begin
      result := True;
      Log_Permissions := 'Y';
    end
    else
    begin
      //record failure
      result := False;
      Log_Permissions := 'Status = ' + IntToStr(rResponseSetWSPerms.StatusCode);
    end;

    except on E: Exception do
      begin
      result := False;
      Log_Permissions := 'Status = ' + IntToStr(rResponseSetWSPerms.StatusCode);
      end;
  end;
End;

Function TfiManWSProcessor.CreateWSRootFolders(fDBID : string):boolean;
var
  rBody, rProspective : string;
  rClientProfile, rMatterProfile : string;
//  rC1Alias, rC5Alias,  : string;
Begin
  Result := False;

  rClientProfile :=  '';
  rMatterProfile := '';
  if qNewWSClients.FieldByName('Category').AsString = 'MATTER' then
  begin
    rMatterProfile := '';
  end
  else
  begin
    if qNewWSClients.FieldByName('CBool1').AsBoolean = True then
      rProspective := 'true'
    else
      rProspective := 'false';
  //  rC1Alias := qNewWSClients.FieldByName('C1Alias').AsString;
  //  rC5Alias := qNewWSClients.FieldByName('C5Alias').AsString;
    rClientProfile :=  '"profile": { "custom1": "' + qNewWSClients.FieldByName('C1Alias').AsString +
                                  //'","custom1_description": "' + qNewWSClients.FieldByName('C1Desc').AsString +
                                  '","custom5": "' + qNewWSClients.FieldByName('C5Alias').AsString +
                                  //'","custom5_description": "' + qNewWSClients.FieldByName('C5Desc').AsString +
                                  '","custom25": "' + rProspective + '"}';
  end;
  try

    rRequestCreate.ClearBody;

    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Accounts/Compliance", ' +
              '"description" : "Accounts/Compliance",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rClientProfile + rMatterProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;
    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := '[Acc/Comp = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  except on E: Exception do
    begin
      result := False;
      Log_WSRootFolders := 'Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Correspondence", ' +
              '"description" : "Correspondence",' +
              '"default_security": "inherit",' +
              '"view_type": "email",' +
              '"email": "' + qNewWSClients.FieldByName('WSID').AsString + '",' +
              rClientProfile + rMatterProfile +
              '}';

    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
      begin
        result := True;
        Log_WSRootFolders := ' [Correspondence = Y]';
      end
      else
      begin
        //record failure
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    except on E: Exception do
      begin
        result := False;
        Log_WSRootFolders := '[Acc/Comp = ' + IntToStr(rResponseCreate.StatusCode) + ']';
      end;
    end;

  try
    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Documents", ' +
              '"description" : "Documents",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rClientProfile + rMatterProfile +
              '}';

  //  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

    if rResponseCreate.StatusCode = 201 then
    begin
      result := True;
      Log_WSRootFolders := ' [Documents = Y]';
    end
    else
    begin
      //record failure
      result := False;
      Log_WSRootFolders := '[Documents = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;

  except on E: Exception do
    begin
      result := False;
      Log_WSRootFolders := '[Documents = ' + IntToStr(rResponseCreate.StatusCode) + ']';
    end;
  end;
End;

Function TfiManWSProcessor.test():boolean;
var
  rBody, rWSID, rFolderID, rProspective, fDBID, fPermGroup: string;
  rClientProfile, rMatterProfile : string;
Begin
  qtest.open;
  rRequestLogin.Execute;
  //Remember to update this and the test query
  CurrentWSID := 'EU_GDG_OPEN!966334';
  fDBID := 'EU_GDG_OPEN';
  rClientProfile :=  '';
  rMatterProfile := '';
  rprospective := 'true';
{
  rRequestUpdate.Params.Clear;
  rRequestUpdate.Resource := v2APIBase + qtest.FieldByName('DBId').AsString + '/folders/EU_GDG_OPEN!966292';
  rBody := '{"view_type": "email", ' +
           '"email": "' + qtest.FieldByName('WSID').AsString + '"}{';


  rRequestUpdate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
  rRequestUpdate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
  rRequestUpdate.Execute;

end;

function TfiManWSProcessor.testfoldercreate():boolean;                  }

  if qtest.FieldByName('Category').AsString = 'MATTER' then
  begin
    rMatterProfile := '';
  end
  else
  begin
    if qtest.FieldByName('CBool1').AsBoolean = True then
      rProspective := 'true'
    else
      rProspective := 'false';
//    rClientProfile :=  '"profile": { "custom1": "' + qtest.FieldByName('C1Alias').AsString +
//                                  '","custom1_description": "' + qtest.FieldByName('C1Desc').AsString +
//                                  '","custom5": "' + qtest.FieldByName('C5Alias').AsString +
//                                  '","custom5_description": "' + qtest.FieldByName('C5Desc').AsString +
//                                  '","custom25": "' + rProspective + '"}';
    rClientProfile :=  '"profile": { "custom1": "' + qtest.FieldByName('C1Alias').AsString +
                                  //'","custom1_description": "' + qNewWSClients.FieldByName('C1Desc').AsString +
                                  '","custom5": "' + qtest.FieldByName('C5Alias').AsString +
                                  //'","custom5_description": "' + qNewWSClients.FieldByName('C5Desc').AsString +
                                  '","custom25": "' + rProspective + '"}';
  end;

    rResponseCreate.Content.Empty;
    rRequestCreate.Params.Clear;
    rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
    rBody := '{"name": "Accounts/Compliance", ' +
              '"description" : "Accounts/Compliance",' +
              '"default_security": "inherit",' +
              '"view_type": "document",' +
              rClientProfile + rMatterProfile +
              '}';

  //  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
    rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
    rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
    rRequestCreate.Execute;

  rResponseCreate.Content.Empty;
  rRequestCreate.Params.Clear;
  rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
  rBody := '{"name": "Correspondence", ' +
            '"description" : "Correspondence",' +
            '"default_security": "inherit",' +
            '"view_type": "email",' +
            '"email": "' + qtest.FieldByName('WSID').AsString + '",' +
            rClientProfile + rMatterProfile +
            '}';

//  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
  rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
  rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
  rRequestCreate.Execute;

  rResponseCreate.Content.Empty;
  rRequestCreate.Params.Clear;
  rRequestCreate.Resource := v2APIBase + fDBId + '/workspaces/' + CurrentWSID + '/folders';
  rBody := '{"name": "Documents", ' +
            '"description" : "Documents",' +
            '"default_security": "inherit",' +
            '"view_type": "document",' +
            rClientProfile + rMatterProfile +
            '}';

//  rRequestCreate.AddParameter('body', rBody, TRESTRequestParameterKind.pkREQUESTBODY);
  rRequestCreate.Params.AddItem('body', rBody, TRESTRequestPArameterKind.pkREQUESTBODY, [TRESTRequestParameterOption.poDoNotEncode]);
  rRequestCreate.Params.ParameterByName('body').ContentType := ctAPPLICATION_JSON;
  rRequestCreate.Execute;

  if rResponseCreate.StatusCode = 201 then
  begin
    result := True;
  end
  else
  begin
    //record failure
    result := False;
  end;
End;

Procedure TfiManWSProcessor.WriteLog();
Begin
  ///
End;

end.
