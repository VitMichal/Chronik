# Design: Common Entry form for adding and editing

Date: 2026-08-31

## Context

Chronik currently has separate Entry flows: `AddEntryView` edits fields and
creates an Entry, while `EntryDetailView` loads and displays an Entry as
read-only content. Selecting an existing Entry therefore cannot edit it. The
service layer also supports adding and deleting Entries but not updating them.

## Goals

- Use one editable form for both creating and editing an Entry.
- Open the common form directly when an existing Entry is selected.
- Preserve existing Entry identity and `createdAt` when editing.
- Keep Delete unavailable in add mode and available in edit mode.
- Keep SwiftData confined to `EntryServiceImpl`.
- Preserve the existing validation, navigation, and error behavior where it
  applies.

## Non-goals

- No changes to Entry fields or validation rules.
- No repository layer or dependency-injection redesign.
- No separate read-only detail screen.
- No unrelated visual redesign of the Work log.

## Form model and state

Replace the add-only presentation model with a shared Entry form view model and
state. The view model has an add/edit mode, represented by the presence of an
editing Entry identity or equivalent explicit mode.

- **Add mode** starts with an empty title, empty optional fields, and today’s
  Day.
- **Edit mode** loads the Entry by ID and populates the same editable fields.
- The state exposes whether the form is editing so the view can choose its
  title and whether to show Delete.
- Save remains enabled only for a non-blank title and a blank or valid decimal
  duration.

When saving in add mode, construct a new Entry with a new `id` and current
`createdAt`. When saving in edit mode, construct an Entry with the existing
`id` and `createdAt`, updated Day/title/duration/notes, and pass it to the
service update operation.

## Service and navigation

Add `update(_ entry: Entry) async throws` to `EntryService`. Its implementation
fetches the persisted entity by ID, updates its mutable fields, and saves the
context. If the entity does not exist, it should throw the existing general
state error rather than silently creating a new Entry.

Keep the existing `EntryScreen` routes. The `.addEntry` route creates the form
view model in add mode. The `.entryDetail(UUID)` route creates the same form
view model in edit mode for that ID. The route name may remain for minimal
navigation churn, but it now resolves to the editable form instead of the
read-only detail view.

## View behavior

Create one common form view containing the current title, Day, duration, and
notes controls, plus the existing save error alert.

- Add mode navigation title: `New Entry`.
- Edit mode navigation title: `Edit Entry`.
- Add mode toolbar: Cancel and Save.
- Edit mode toolbar: Cancel, Delete, and Save.
- Successful Save or Delete pops the navigator.
- Failed Save displays the existing save error and does not pop.
- Failed Delete reports the failure and does not pop.
- Edit-mode loading uses the existing loadable loading/error presentation; the
  form controls are shown after the Entry is loaded.

The old read-only `EntryDetailView` and `EntryDetailViewModel` are removed once
their responsibilities are covered by the shared form.

## Testing

- Extend `EntryServiceTests` for updating persisted Entries and the missing-ID
  failure case.
- Extend `EntryServiceStub` with update tracking and behavior.
- Replace add-only view model tests with shared form tests covering:
  - add-mode defaults and creation;
  - edit-mode loading and field population;
  - preservation of `id` and `createdAt` during update;
  - update and delete success navigation;
  - invalid input blocking service calls;
  - save, load, update, and delete failures;
  - add mode not exposing or invoking Delete.
- Remove obsolete read-only detail view model tests and add equivalent shared
  form coverage.

## Risks and mitigations

- Updating a missing persisted Entry could otherwise appear successful. The
  service explicitly throws when no matching entity exists, and tests cover it.
- Form state could reset while navigating or during view updates. The form
  view model owns initialization/loading, and the root creates one instance for
  the route rather than resetting edit state on every body evaluation.
- Existing tests depend on the service protocol. Updating the hand-written
  stub in the same change keeps all test doubles aligned with the production
  contract.
