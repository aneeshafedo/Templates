import ballerina/log;
import ballerina/io;
import ballerinax/sfdc;
import ballerinax/slack;

//salesforce configuration parameters;
configurable string ep_url = ?;
configurable string sf_username = ?;
configurable string sf_password = ?;
configurable string sf_push_topic = ?;

//slack configuration parameters
configurable string slack_token = ?;
configurable string slack_channel_name = ?;

sfdc:ListenerConfiguration listenerConfig = {
    username: sf_username,
    password: sf_password
};

slack:Configuration slackConfig = {bearerTokenConfig: {token: slack_token}};

slack:Client slackClient = check new (slackConfig);

listener sfdc:Listener sfdcEventListener = new (listenerConfig);

@sfdc:ServiceConfig {topic: TOPIC_PREFIX + sf_push_topic}
service on sfdcEventListener {
    remote function onEvent(json opportunity) {
        io:StringReader sr = new (opportunity.toJsonString());
        json|error opportunityUpdate = sr.readJson();
        if (opportunityUpdate is json) {
            log:print("record : " + opportunityUpdate.toString());
            json|error eventType = opportunityUpdate.event.'type;
            if (eventType is json) {
                if (UPDATED.equalsIgnoreCaseAscii(eventType.toString())) {
                    json|error stageName = opportunityUpdate.sobject.StageName;
                    if (stageName is json && stageName == "Closed Won") {
                        log:print("Opportunity updated to 'Closed Won'");
                        sendSlackMessage(opportunityUpdate);
                    }
                }
            } else {
                log:printError(eventType.message());
            }
        } else {
            io:println(opportunityUpdate);
        }
    }
}

function sendSlackMessage(json opportunityRecord) {
    string fullName = "opportunity Name : ";
    json|error opportunityName = opportunityRecord.sobject.Name;
    json|error opportunityId = opportunityRecord.sobject.AccountId;

    string companyName = opportunityName is json ? " Name : " + opportunityName.toString() : "";
    string link = opportunityId is json ? (" | Link : " + "<" + ep_url + "/" + opportunityId.toString() + ">") : "";

    slack:Message messageParams = {
        channelName: slack_channel_name,
        text: "Opportunity Won !!! " + companyName + link
    };

    var response = slackClient->postMessage(messageParams);
    if response is string {
        log:print("Messege posted in Slack Successfully");
    } else {
        log:printError("Error Occured : " + response.message());
    }

}
                                                                        