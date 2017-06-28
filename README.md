# Team App

A simple app that display details about a Slack team, using Slack API.

<h4>Installation</h4>

Create the following Podfile:

```
platform :ios, '10.0'

target 'SlackTeam' do
  pod 'AFNetworking', '~> 3.0'
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
