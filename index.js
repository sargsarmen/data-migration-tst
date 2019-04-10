const express = require("express");
const bodyParser = require("body-parser");
const app = express();

const actions = require('./actions')
const port = 3000

app.use(bodyParser.json())
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
)

app.get('/statistics', actions.getStatistics)
app.post('/run-job', actions.runJob)

app.listen(port, () => {
  console.log(`App running on port ${port}.`)
})