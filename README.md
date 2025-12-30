# Flexitime

![License](https://img.shields.io/badge/license-MIT-green.svg)

Flexitime is a small Rails app for tracking clock-in/clock-out time, lunch
breaks, and weekly hour balances.

It's designed around compressed working weeks (37 hours by default), with
carry-over between weeks so overtime or shortfalls roll forward automatically.

## Features
- Clock in / clock out with optional lunch breaks
- Weekly totals showing required hours and balance
- Carry over of credit/debt between weeks
- Configurable contracted hours and working days per user
- Personal time tracking workflow (not a full HR system)

## Requirements
- Ruby (see `.tool-versions`)
- PostgreSQL

## Setup

```sh
bundle install
bin/rails db:prepare
```

## Run locally

```sh
bin/dev
```

Then visit: http://localhost:3000

## Tests

```sh
bundle exec rspec
```

## Notes
- Weeks start on Monday (Mon-Sun).
- Required hours for the week are adjusted using the previous week's balance.
- Built originally for personal use, so it's pragmatic rather than feature heavy.
