%{
  title: "Timezones",
  description: "A brief rant about how timezones are specified."
}
---
I live in the eastern United States.

It's **Eastern Daylight Time (EDT)** from the *second Sunday in March* to the *first Sunday in November*.

It's **Eastern Standard Time (EST)** from the *first Sunday in November* to the *second Sunday in March*.

Collectively they are **America\New_York**.

Thus if you're saving a DateTime with timezone to a database (perhaps Postgres) you should use **America\New_York**.  

By doing so, you're utilizing the wonderful work done in the [tz database](https://en.wikipedia.org/wiki/Tz_database)!

Cheers.
