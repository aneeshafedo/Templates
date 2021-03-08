import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/googleapis_sheets as sheets;

//salesforce configuration parameter
configurable string ep_url = ?;
configurable string sf_client_id = ?;
configurable string sf_client_secret = ?;
configurable string sf_refresh_token = ?;
configurable string sf_refresh_url = ?;
configurable string sf_username = ?;
configurable string sf_password = ?;
configurable string sf_push_topic = ?;
configurable string sf_object = ?;

//gsheet configuration parameters
configurable string sheets_refresh_token = ?;
configurable string sheets_client_id = ?;
configurable string sheets_client_secret = ?;
configurable string sheets_id = ?;
configurable string sheets_name = ?;
configurable string sheets_refresh_url = ?;

sfdc:SalesforceConfiguration sfConfig = {
    baseUrl: ep_url,
    clientConfig: {
        clientId: sf_client_id,
        clientSecret: sf_client_secret,
        refreshToken: sf_refresh_token,
        refreshUrl: sf_refresh_url
    }
};

sheets:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        clientId: sheets_client_id,
        clientSecret: sheets_client_secret,
        refreshUrl: sheets_refresh_url,
        refreshToken: sheets_refresh_token
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: sf_username,
    password: sf_password
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
sfdc:BaseClient sfdcClient = check new (sfConfig);

sheets:Client gSheetClient = check new (spreadsheetConfig);

@sfdc:ServiceConfig {
    topic: TOPIC_PREFIX + sf_push_topic
}
service on sfdcEventListener {
    remote function onEvent(json sobject) {
        io:StringReader sr = new (sobject.toJsonString());
        json|error sobjectInfo = sr.readJson();
        if (sobjectInfo is json) {
            json|error eventType = sobjectInfo.event.'type;
            if (eventType is json) {
                if (TYPE_CREATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    error|json sobjectId = sobjectInfo.sobject.Id;
                    if (sobjectId is json) {
                        string path = BASE_URL + sf_object + "/" + sobjectId.toString();
                        var sobjectRecord = sfdcClient->getRecord(path);
                        if (sobjectRecord is json) {
                            error? resp = createSheetWithNewsobject(sobjectRecord);
                            if (resp is error) {
                                log:printError(resp.message());
                            } else {
                                log:print(sf_object + " added to Spreadsheet Successfully");
                            }
                        } else {
                            log:printError(sobjectRecord.message());
                        }
                    } else {
                        log:printError(sobjectId.message());
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            io:println(sobjectInfo);
        }
    }
}

function createSheetWithNewsobject(json sobject) returns @tainted error? {
    (int|string|float)[] values = [];
    (string)[] headerValues = [];
    map<json> sobjectMap = <map<json>>sobject;
    foreach var [key, value] in sobjectMap.entries() {
        headerValues.push(key.toString());
        values.push(value.toString());
    }
    var headers = gSheetClient->getRow(sheets_id, sheets_name, 1);
    if(headers == []){
        _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, headerValues);
    }
    _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, values);
}
