# Send Slack Channel Message when a Salesforce Opportunity is Updated

## Intergration Use Case
At the execution of this template, when an opportunityis updated , Slack notification will be sent to a specidied Slack channel

## Supported Versions

<table>
  <tr>
   <td>Ballerina Language Version
   </td>
   <td>Swan Lake Alpha2
   </td>
  </tr>
  <tr>
   <td>Java Development Kit (JDK) 
   </td>
   <td>11
   </td>
  </tr>
  <tr>
   <td>Salesforce API 
   </td>
   <td>v48.0
   </td>
  </tr>
</table>


## Pre-requisites
* Download and install [Ballerina](https://ballerinalang.org/downloads/).
* Slack workspace with admin priviledges
* Ballerina connectors for Salesforce and Slacks which will be automatically downloaded when building the application for the first time


## configuration
### Setup Salesforce Configurations
* Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
* Salesforce username, password and the security token that will be needed for initializing the listener. 

For more information on the secret token, please visit [Reset Your Security Token](https://help.salesforce.com/articleView?id=user_security_token.htm&type=5).
Once you obtained all configurations, Replace "" in the `Conf.toml` file with your data.

### Create Push Topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on Lead entity.

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Paste following apex code to create topic with <OpportunityUpdate> and execute. You can change the `pushTopic.Query` adding the fields you want to receive when the event triggered. Make sure `pushTopic.NotifyForFields` is set to `All` if you need to listen to the update of any field of an opportunity. Only to listen to the update of the fields specified in the `pushTopic.Query` set `pushTopic.NotifyForFields` to `Referenced`. 
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'OpportunityUpdate';
pushTopic.Query = 'SELECT Id, Name, AccountId, StageName, Amount FROM Opportunity';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForFields = 'All';
insert pushTopic;
```
3. Once the creation is done, specify the topic name in your `Config.toml` file as `sf_push_topic`.

### Setup Slack Configurations
Go to your Slack app and obtain Slack `User OAuth Token` starting with `xoxo-` under `OAuth & Permissions` in App settings. 

Add `User OAuth Token` as `slack_token` and Slack Channel 

### Config.toml 

#### ballerinax/slack related configurations 

ep_url = ""   
sf_client_id = ""   
sf_client_secret = ""  
sf_refresh_token = ""  
sf_refresh_url = ""  
sf_username = ""  
sf_password = ""  
sf_push_topic = ""  


#### ballerinax/slack related configurations  

slack_channel_name = ""  
slack_token = ""  

## Running the Template

1. First you need to build the integration template and create the executable binary. Run the following command from the root directory of the integration template. 
`$ bal build`. 

2. Then you can run the integration binary with the following command. 
`$ bal run /target/bin/sfdc_oppotunity_update_to_slack.jar`. 

Successful listener startup will print following in the console.
```
>>>>
[2020-09-25 11:10:55.552] Success:[/meta/handshake]
{ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=1mc1owacqlmod21gwe8arhpxaxxm, supportedConnectionTypes=[Ljava.lang.Object;@21a089fc, channel=/meta/handshake, id=1, version=1.0, successful=true}
<<<<
>>>>
[2020-09-25 11:10:55.629] Success:[/meta/connect]
{clientId=1mc1owacqlmod21gwe8arhpxaxxm, advice={reconnect=retry, interval=0, timeout=110000}, channel=/meta/connect, id=2, successful=true}
<<<<
```

3. Now you can update the a `Opportunity` in Salesforce and observe that integration template runtime has received the event notification for the opportunity update.

4. You can go to slack channel and verify the message receiving. Following is a sample message 

![Sample Slack Notification](../sfdc_opportunity_update_to_slack/docs/images/opp_update.png?raw=true)
 