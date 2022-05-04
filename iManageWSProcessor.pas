unit iManageWSProcessor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, DBAccess, Uni, UniProvider,
  SQLServerUniProvider, IPPeerClient, Vcl.StdCtrls, REST.Client,
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
    RESTClient1: TRESTClient;
    RESTRQiManWS_Login: TRESTRequest;
    RESTRSWS_Login: TRESTResponse;
    OAuth2Auth1: TOAuth2Authenticator;
    Button1: TButton;
    BindingsList1: TBindingsList;
    MemoContent: TMemo;
    Edit1: TEdit;
    FDMemTable1: TFDMemTable;
    BindSourceDB1: TBindSourceDB;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    LinkControlToField2: TLinkControlToField;
    RESTRQiManWS_CheckExists: TRESTRequest;
    RESTRSWS_CheckExists: TRESTResponse;
    Edittoken_type: TEdit;
    LinkControlToFieldtoken_type: TLinkControlToField;
    MemoContent2: TMemo;
    RESTClient3: TRESTClient;
    rRequestLogin: TRESTRequest;
    rResponseLogin: TRESTResponse;
    RESTClient4: TRESTClient;
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
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    Function CheckClientID(fClientID : string; fDB : string):boolean;
    Function CheckEntity(fEntityID : string; fDB : string):boolean;
    Function CreateClientWS():boolean;
    Function UpdateClientWS():boolean;
  public
    { Public declarations }
    AuthToken: string;
//    AuthTokenType: string;
//    AuthTokenExpire: integer;
  end;

var
  fiManWSProcessor: TfiManWSProcessor;
  CurrentWSID: string;
  
const
  v2APIBase = 'work/api/v2/customers/100/libraries/';

implementation
//uses
//  system.json;
//  REST.Types,
//  REST.Utils;
{$R *.dfm}

procedure TfiManWSProcessor.Button1Click(Sender: TObject);
var
  DBConn : TUniConnection;
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

  qNewWSClients.Open;
  qNewWSClients.First;
  while not qNewWSClients.Eof do
  begin
    CurrentWSID.Empty;
//    DBConn.Name := 'conn_' + qNewWSClients.FieldByName('DBId').AsString;
    If Not CheckClientID(qNewWSClients.FieldByName('C1Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) Then
    begin
      //Create New Custom1
    end;

    if Not CheckEntity(qNewWSClients.FieldByName('C5Alias').AsString, qNewWSClients.FieldByName('DBId').AsString) then
    begin
      //Create New Custom5
    end;

    //Create new client workspace
    CreateClientWS;
    UpdateClientWS;

    qNewWSClients.Next
  end;



  rRequestLogin.Execute;
  rResponseLogin.GetSimpleValue('X-Auth-token', AuthToken);

end;

Function TfiManWSProcessor.CheckClientID(fClientID : string; fDB : string):boolean;
Begin
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
      Result := False
    else
      Result := True;
    Close;

  End;

End;

Function TfiManWSProcessor.CheckEntity(fEntityID : string; fDB : string):boolean;
Begin
  With qCheckEntity Do
  Begin
    Close;
    SQL.Clear;
    SQL.Text := 'select * from ' + fDB + '.MHGROUP.CUSTOM5 ' +
                'where CUSTOM_ALIAS = ' + QuotedStr(fEntityID);
    Open;
    if IsEmpty then
      Result := False
    else
      Result := True;
    Close;

  End;

End;

Function TfiManWSProcessor.CreateClientWS():boolean;
var
  rBody, rFolderID : string;
Begin
  rRequestCreate.Params.Clear;
  rRequestCreate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces';
  rBody := '{"author": "epmsdev","class": "WEBDOC","default_security": "' + qNewWSClients.FieldByName('DefaultVisibility').AsString + 
          '","description": "' + qNewWSClients.FieldByName('Description').AsString + 
          '","name": "' + qNewWSClients.FieldByName('Name').AsString +
          '","owner": "epmsdev"}';

  //{"author": "epmsdev","class": "WEBDOC","default_security": "public","description": "JR Test Workspace",
  //"name": "001 - JR Test Workspace","owner": "epmsdev"} 
  rRequestCreate.Execute;
  if rResponseCreate.StatusCode = 200 then
  begin
    //update staging with folder id
    rResponseCreate.GetSimpleValue('workspace_id', CurrentWSID);
    rFolderID := CurrentWSID.Substring(pos(CurrentWSID,'!')+1);
    qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
    qUpdateWSID.Execute;
    result := True;
  end
  else
  begin
    //record failure
    result := False;
  end;
               
End;

Function TfiManWSProcessor.UpdateClientWS():boolean;
var
  rBody, rWSID, rFolderID : string;
Begin
  //update workspace with extra metadata
  rRequestCreate.Params.Clear;
  rRequestCreate.Resource := v2APIBase + qNewWSClients.FieldByName('DBId').AsString + '/workspaces' + CurrentWSID;
  ///work/api/v2/customers/{customerId}/libraries/{libraryId}/workspaces/{workspaceId}
  rBody := '{"author": "epmsdev","class": "WEBDOC","default_security": "' + qNewWSClients.FieldByName('DefaultVisibility').AsString + 
          '","description": "' + qNewWSClients.FieldByName('Description').AsString + 
          '","name": "' + qNewWSClients.FieldByName('Name').AsString +
          '","owner": "epmsdev"}';

  //{"author": "epmsdev","class": "WEBDOC","default_security": "public","description": "JR Test Workspace",
  //"name": "001 - JR Test Workspace","owner": "epmsdev"} 
  rRequestCreate.Execute;
  if rResponseCreate.StatusCode = 200 then
  begin
    //update staging with folder id
 {   rResponseCreate.GetSimpleValue('workspace_id', rWSID);
    rFolderID := rWSID.Substring(pos(rWSID,'!')+1);
    qUpdateWSID.ParamByName('UniqueID').AsString := rFolderID;
    qUpdateWSID.Execute;    }
    result := True;
  end
  else
  begin
    //record failure
    result := False;
  end;
End;
end.
