# Plausible

This runs the Plausible Community Edition on your server.

Launch in couple of minutes here: https://dollardeploy.com/r/plausible

## Integration notes:

Add the following script to your website (or in the \_app.tsx for NextJS)

```js
<script
  async
  defer
  data-api="my.hostname.example.com/api/event"
  data-domain="my.website.com"
  src="https://my.hostname.example.com/js/script.js""
/>
```

NOTE: Avoid using "plausible" in the hostname for better analytics results.
