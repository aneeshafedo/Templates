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

//gsheet configuration parameters
configurable string sheets_refreshToken = ?;
configurable string sheets_clientId = ?;
configurable string sheets_clientSecret = ?;
configurable string sheets_id = ?;
configurable string sheets_name = ?;
configurable string sheets_refreshurl = ?;

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
        clientId: sheets_clientId,
        clientSecret: sheets_clientSecret,
        refreshUrl: sheets_refreshurl,
        refreshToken: sheets_refreshToken
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
    remote function onEvent(json lead) {
        io:StringReader sr = new (lead.toJsonString());
        json|error leadInfo = sr.readJson();
        if (leadInfo is json) {
            json|error eventType = leadInfo.event.'type;
            if (eventType is json) {
                if (TYPE_CREATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    error|json leadId = leadInfo.sobject.Id;
                    if (leadId is json) {
                        var leadRecord = sfdcClient->getLeadById(leadId.toString());
                        if (leadRecord is json) {
                            error? resp = createSheetWithNewLead(leadRecord);
                            if (resp is error) {
                                log:printError(resp.message());
                            } else {
                                log:print("Lead added to Spreadsheet Successfully");
                            }
                        } else {
                            log:printError(leadRecord.message());
                        }
                    } else {
                        log:printError(leadId.message());
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            io:println(leadInfo);
        }
    }
}

function createSheetWithNewLead(json lead) returns @tainted error? {
    (int|string|float)[] values = [];
    (string)[] headerValues = [];
    map<json> leadMap = <map<json>>lead;
    foreach var [key, value] in leadMap.entries() {
        headerValues.push(key.toString());
        values.push(value.toString());
    }
    var headers = gSheetClient->getRow(sheets_id, sheets_name, 1);
    if(headers == []){
        _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, headerValues);
    }
    _ = check gSheetClient->appendRowToSheet(sheets_id, sheets_name, values);
}
