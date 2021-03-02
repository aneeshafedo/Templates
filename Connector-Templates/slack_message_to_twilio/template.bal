import ballerinax/twilio;
import ballerina/config;
import ballerina/lang.'int as ints;
import ballerinax/slack.'listener as SlackListener;
import ballerina/http;
import ballerina/log;

string verification_token = config:getAsString("SLACK_VERIFICATION_TOKEN");
string port = config:getAsString("SLACK_PORT");
int PORT = check ints:fromString(port);

SlackListener:ListenerConfiguration slackListenerConfig = {verificationToken: verification_token};
listener SlackListener:SlackEventListener slackListener = new (9090, slackListenerConfig);

twilio:TwilioConfiguration twilioConfig = {
    accountSId: config:getAsString("TWILIO_ACCOUNT_SID"),
    authToken: config:getAsString("TWILIO_AUTH_TOKEN")
};

twilio:Client twilioClient = new (twilioConfig);

string? syncToken = ();
string fromMobile = config:getAsString("SAMPLE_FROM_MOBILE");
string toMobile = config:getAsString("SAMPLE_TO_MOBILE");

service /slack on slackListener {
    resource function post events(http:Caller caller, http:Request request) returns @untainted error? {
        var event = slackListener.getEventData(caller, request);
        if (event is SlackListener:MessageEvent && event.'type == SlackListener:MESSAGE && 
        event?.channel_type == "channel" && event.channel == config:getAsString("SLACK_CHANNEL_ID")) {
            string message = <string>event?.text;
            var success = twilioClient->sendSms(fromMobile, toMobile, message);
            if (success is error) {
                log:printError("Error Occured : ", err = success);
            } else {
                log:print("Message sent successfully");
            }
        }
    }
}
