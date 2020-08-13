# GGFilter

⚠ This project is outdated and unmaintained, the scrapers aren't working and the
database is outdated.

Can browse for demo purposes on [GGFilter.com](http://ggfilter.com/)

Honestly I'm more interested in the decentralized web and JAMStack architecture
nowdays. And I would probably move away from RoR if done again, maybe even
a lambda function would do if a backend was neccesary, it is literally
a single endpoint for all the filters.

## Deployment

After deploying a new client to the Bitbucket repo run the following to update this
project dependencies:

```
bundle update ggfilter_client
```

The same with the scrapers

```
bundle update scrapers
```

Or you can run this task that automatically does a commit too:

```
rake dist:update_deps
```

And to deploy to the server you should run

To deploy to the server just commit the latest changes and:

```
git push heroku master && heroku run rake db:migrate && heroku restart
```

You can just run a Rake task that does everything (it also run `dist:update_deps`):


```
rake dist:deploy
```
