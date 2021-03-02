## Slack to Twilio Integration
### Intergration Use Case 
This template can be used in the scenarios you need to send the messages posted to given channel as sms through twilio. Users need to configure their twilio mobile number as the number which sends the sms and an another registered mobile number as the receiver. 

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
SLACK_CHANNEL_ID = ""   

#### General configurations
In addition to the configurations related to ballerina modules user needs to provide the number obtained from your twilio account as 'FROM_MOBILE' and the number you wish to send the sms as 'TO_MOBILE'

SAMPLE_FROM_MOBILE = ""  
SAMPLE_TO_MOBILE = ""  

### Executing the template
* Start ngok on the same port provided in the `ballerina.conf` using the command ``` ./ngrok http 9090 ```
* Paste the URL issued by ngrok following with your service path (eg : ```https://365fc542d344.ngrok.io/slack/events``` )
* Build and run the application
