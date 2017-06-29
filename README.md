# Team App

A simple app that display details about a Slack team, using Slack API.

<p align="center">
<img width="338" height="600" src="Images/ScreenShot_Team.PNG.png?raw=true">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
<img width="338" height="600" src="Images/ScreenShot_Member.png?raw=true">
</p><br><br>

<h4>Installation</h4>

Create the following Podfile:

```
platform :ios, '10.0'

target 'Team' do
  pod 'AFNetworking', '~> 3.0'
  pod 'ISMessages'
end
```

Then, run the following command:

```
$ pod install
```

Update the API Token in DefaultPreferences.plist with your own token to test with different Teams

```
slackToken = @"YOUR_API_TOKEN"
```
