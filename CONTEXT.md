# Chronik

Chronik is a personal work log — a dated chronicle of what the user did at work. The app is being pivoted from its original form (an Airbnb-style accommodation browsing template) into this log.

## Language

**Entry**:
The atomic unit of the work log. A dated record of one piece of work the user did, with an optional duration and free-text notes.
_Avoid_: LogEntry, WorkEntry, ChronicleEntry, task

**Work log**:
The collection of all Entries, ordered by date, presented grouped by day. The whole app.
_Avoid_: Journal, task tracker, to-do list

**Day**:
A calendar day; the grouping unit of the Work log. Entries belong to a Day, never to a moment.
_Avoid_: Date, timestamp, datetime