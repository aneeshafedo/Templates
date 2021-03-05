import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/slack;

//salesforce configuration parameters;
configurable string ep_url = ?;
configurable string sf_client_id = ?;
configurable string sf_client_secret = ?;
configurable string sf_refresh_token = ?;
configurable string sf_refresh_url = ?;
configurable string sf_username = ?;
configurable string sf_password = ?;
configurable string sf_push_topic = ?;

//slack configuration parameters
configurable string slack_token = ?;
configurable string slack_channel_name = ?;

sfdc:SalesforceConfiguration sfConfig = {
    baseUrl: ep_url,
    clientConfig: {
        clientId: sf_client_id,
        clientSecret: sf_client_secret,
        refreshToken: sf_refresh_token,
        refreshUrl: sf_refresh_url
    }
};

sfdc:ListenerConfiguration listenerConfig = {
    username: sf_username,
    password: sf_password
};

slack:Configuration slackConfig = {bearerTokenConfig: {token: slack_token}};

slack:Client slackClient = check new (slackConfig);

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
sfdc:BaseClient sfdcClient = check new (sfConfig);

@sfdc:ServiceConfig {topic: TOPIC_PREFIX + sf_push_topic}
service on sfdcEventListener {
    remote function onEvent(json lead) {
        io:StringReader sr = new (lead.toJsonString());
        json|error leadInfo = sr.readJson();
        if (leadInfo is json) {
            json|error eventType = leadInfo.event.'type;
            if (eventType is json) {
                if (CREATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    error|json leadId = leadInfo.sobject.Id;
                    if (leadId is json) {
                        json|sfdc:Error leadRecord = sfdcClient->getLeadById(leadId.toString());
                        if (leadRecord is json) {
                            json|error rating = leadRecord.Rating;
                            if (rating is json && rating == "Hot") {
                                sendSlackMessage(leadRecord);
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

function sendSlackMessage(json leadRecord) {
    string fullName = "Lead Name : ";
    json|error leadName = leadRecord.Name;
    json|error leadSalutation = leadRecord.Salutation;
    json|error leadCompany = leadRecord.Company;
    json|error leadId = leadRecord.Id;

    if (leadName is json) {
        if (leadSalutation is json) {
            fullName += leadSalutation.toString() + " " + leadName.toString();
        } else {
            fullName += leadName.toString();
        }
    }

    string companyName = leadCompany is json ? " | Company : " + leadCompany.toString() : "";
    string link = leadId is json ? (" | Link : " + "<" + ep_url + "/" + leadId.toString() + ">") : "";

    slack:Message messageParams = {
        channelName: slack_channel_name,
        text: "Hot Lead Added. " + fullName + companyName + link
    };

    var response = slackClient->postMessage(messageParams);
    if response is string {
        log:print("Messege posted in Slack Successfully");
    } else {
        log:printError("Error Occured : " + response.message());
    }

}
                                                                        