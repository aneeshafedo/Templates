## Slack to Google Sheet Intergration
### Intergration Use Case 
Add all messages posted to a given slack channel to a Google Sheets' spreadsheet as rows. For each message a row will be added in the spreadsheet with relavant data related to the message. This template can be useful when recording each message in a private slack channel is needed. 

### Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Google Cloud Platform Account
* Ballerina connectors for Slack and Google Sheets which will be automatically downloaded when building the application for the first time
* Install npm and setup the [ngrok](https://ngrok.com/download).


### configuration
#### Create a Google Google Cloud Platform (GCP) account and log into the [developer console](https://console.cloud.google.com/home/dashboard).
* Setup an OAuth App and get client ID and client secret credentials
* Further obtain Access Token and Refresh Token, and Refresh Token URL
* Create a Google sheet and get its ID and Sheet name.
#### Obtaining slack credentials
* Visit your slack app settings and get the verification token at the `Basic Information` tab.
* Open the slack channel you need to observe and get the channel ID. 

Once you obtained all configurations, Replace "" in the `ballerina.conf` file with your data.

#### ballerina.conf 

#### ballerinax/googleapis_sheet related configurations  

GS_CLIENT_ID = ""  
GS_CLIENT_SECRET = ""  
GS_REFRESH_TOKEN = ""  
GS_REDIRECT_URL = ""  
GS_ACCESS_TOKEN = ""  
SPREADDHEET_ID = ""  
SHEET_NAME = ""</br>

#### ballerinax/slack related configurations 

SLACK_VERIFICATION_TOKEN = ""   
SLACK_PORT = ""  
SLACK_CHANNEL_ID = "" 

#### ballerina/time related configurations
Since slack sends a 16 digit timestamp with each event trigger, it needs to be converted into date-time format to allow users to make decisions on it 

TIME_ZONE_ID = ""

### Executing the template
* Start ngok on the same port provided in the `ballerina.conf` using the command ``` ./ngrok http 9090 ```
* Paste the URL issued by ngrok following with your service path (eg : ```https://365fc542d344.ngrok.io/slack/events``` )
* Build and run the application

For each message posted in he given slack channel, a new row will be added to your google spreadsheet provided. Example snapshot of your spreadsheet is as following

<img src="https://github.com/aneeshafedo/Sample-Connector-Templates/blob/master/template_slack_gsheet/docs/resources/sample_spreadsheet.png" title="Database Schema">


