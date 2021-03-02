## Slack to Twilio Integration
### Intergration Use Case 
This template is written to forward a message posted in a slack channel to a given phone number as a sms using ballerina twilio connector. Users suppose to post their message in following format

`msgto:<space><receiver's number>msg:<space><your message>` (eg: `msgto: +1320123456 msg: Test Message`)

### Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Twilio account with sms capable phone number
* Ballerina connectors for Slack and Twilio which will be automatically downloaded when building the application for the first time
* Install npm and setup the [ngrok](https://ngrok.com/download).

### configuration
* Obtain twilio Account SID and Auth Token from your project dashboard
* Visit your slack app settings and get the verification token at the `Basic Information` tab.
* Open the slack channel you need to observe and get the channel ID.

#### ballerinax/twilio related configurations  

TWILIO_ACCOUNT_SID = ""  
TWILIO_AUTH_TOKEN = ""  

#### ballerinax/slack related configurations 

SLACK_VERIFICATION_TOKEN = ""  
SLACK_PORT = ""  

#### General configurations
In addition to the confih=gurations related to ballerina modules user needs to provide the number obtained from your twilio account as 'FROM_MOBILE'

SAMPLE_FROM_MOBILE = ""  

### Executing the template
* Start ngok on the same port provided in the `ballerina.conf` using the command ``` ./ngrok http 9090 ```
* Paste the URL issued by ngrok following with your service path (eg : ```https://365fc542d344.ngrok.io/slack/events``` )
* Build and run the application

