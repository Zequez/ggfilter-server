# GGFilter

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.

## GET /games.json

```javascript
{
  "columns": ["list", "of", "columns", "from", "games"],
  "filters": {
    "name": {
      "value": "game name to search for",
      "filter": true,
      "highlight": true
    },
    "steam_id": {
      "value": 123432,
      "filter": true
    },
    "steam_reviews_count": { // reviews between 50 and 5000
      "gt": 50,
      "lt": 5000
    }
  },
  "sort": ["column1", "column2", "column3"], // max length 3
  "limit": 20, // 1-100
  "page": 1 // 1, 2, 3...
}
```

By setting the filter highlight parameter instead of filtering it's going to
add a column called `<filter_name>_hl` with either true or false to signify
if the filter matched.
