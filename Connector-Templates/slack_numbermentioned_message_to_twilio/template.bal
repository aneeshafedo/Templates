import ballerinax/twilio;
import ballerina/config;
import ballerina/lang.'int as ints;
import ballerinax/slack.'listener as SlackListener;
import ballerina/http;
import ballerina/log;
import ballerina/stringutils;

string verification_token = config:getAsString("SLACK_VERIFICATION_TOKEN");
string port = config:getAsString("SLACK_PORT");
int PORT = check ints:fromString(port);

SlackListener:ListenerConfiguration slackListenerConfig = {verificationToken: verification_token};
listener SlackListener:SlackEventListener slackListener = new (PORT, slackListenerConfig);

twilio:TwilioConfiguration twilioConfig = {
    accountSId: config:getAsString("TWILIO_ACCOUNT_SID"),
    authToken: config:getAsString("TWILIO_AUTH_TOKEN")
};

twilio:Client twilioClient = new (twilioConfig);

string? syncToken = ();
string fromMobile = config:getAsString("FROM_MOBILE");

service /slack on slackListener {
    resource function post events(http:Caller caller, http:Request request) returns @untainted error? {
        var event = slackListener.getEventData(caller, request);
        if (event is SlackListener:MessageEvent && event.'type == SlackListener:MESSAGE) {
            string text = <string>event?.text;
            int? numberIndex = text.indexOf("msgto:");
            int? msgIndex = text.indexOf("msg:");
            if (numberIndex is int && msgIndex is int) {
                string numberBlock = text.substring(numberIndex + 6, msgIndex);
                string[] toMobile = stringutils:split((stringutils:replaceAll(numberBlock, "[<>(a-z):]", "")), "\\|");
                string message = text.substring(msgIndex + 4, text.length());
                if (message != "") {
                    var success = twilioClient->sendSms(fromMobile, toMobile[0], message);
                    if (success is error) {
                        log:printError("Error Occured : ", err = success);
                    } else {
                        log:print("Message sent successfully");
                    }
                } else {
                    log:printError("Empty Message");
                }

            }
        }
    }
}
