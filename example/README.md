# Running `sinatra-slack` example

1. Install gems
``` shell
bundle install
```

2. Launch server
``` shell
shotgun -p 3000
```

3. Launch ngrok
``` shell
./ngrok http 3000
```

4. Add the ngrok URL to the Slack App configurations, in [Slack Api] (https://api.slack.com/)
