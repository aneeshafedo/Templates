import ballerina/http;
import ballerina/log;
import ballerina/config;
import ballerina/lang.'int as ints;
import ballerinax/slack.'listener as SlackListener;
import ballerinax/googleapis_sheets as sheets;
import ballerina/time;

string verification_token = config:getAsString("SLACK_VERIFICATION_TOKEN");
string port = config:getAsString("SLACK_PORT");
int PORT = check ints:fromString(port);

SlackListener:ListenerConfiguration slackListenerConfig = {verificationToken: verification_token};
listener SlackListener:SlackEventListener slackListener = new (PORT, slackListenerConfig);

sheets:SpreadsheetConfiguration spreadsheetConfig = {oauth2Config: {
        accessToken: config:getAsString("GS_ACCESS_TOKEN"),
        refreshConfig: {
            clientId: config:getAsString("GS_CLIENT_ID"),
            clientSecret: config:getAsString("GS_CLIENT_SECRET"),
            refreshUrl: config:getAsString("GS_REDIRECT_URL"),
            refreshToken: config:getAsString("GS_REFRESH_TOKEN")
        }
    }};
sheets:Client spreadsheetClient = new (spreadsheetConfig);

service /slack on slackListener {
    resource function post events(http:Caller caller, http:Request request) returns @untainted error? {
        var event = slackListener.getEventData(caller, request);
        if (event is SlackListener:AppEvent && event.'type == SlackListener:APP_MENTION) {
            int? isAppMentioned = (<string>event?.text).indexOf(config:getAsString("SLACK_APP_ID"));
            if (isAppMentioned is int) {
                string[] messageData = [event.channel, event.user, <string>event?.text, getTime(event.event_ts)];
                sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetById(config:getAsString(
                "SPREADDHEET_ID"));
                if (spreadsheet is sheets:Spreadsheet) {
                    sheets:Sheet|error sheet = spreadsheet.getSheetByName(config:getAsString("SHEET_NAME"));
                    if (sheet is sheets:Sheet) {
                        error? appendResult = sheet->appendRow(messageData);
                        if appendResult is error {
                            log:print("Error : " + appendResult.toString());
                        } else {
                            log:print("Row Added Successfully");
                        }
                    } else {
                        log:printError("Invalid Sheet Name");
                    }
                } else {
                    log:printError("Invalid Spreadsheet ID");
                }
            }

        }
    }
}

function getTime(string timestamp) returns string {
    string balTimeStamp = timestamp.substring(0, 10);
    int|error intTimeStamp = 'int:fromString(balTimeStamp);
    if intTimeStamp is int {
        string zoneId = config:getAsString("TIME_ZONE_ID");
        time:TimeZone zoneValue = {id: zoneId};
        time:Time time = {
            time: intTimeStamp * 1000,
            zone: zoneValue
        };
        time:Time|time:Error formattedTime = time:toTimeZone(time, zoneId);
        if (formattedTime is time:Time) {
            return time:toString(formattedTime);
        }
    }
    return "";
}
