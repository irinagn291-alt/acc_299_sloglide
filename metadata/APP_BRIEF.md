<!-- gf-brief source=879846751e4d55ea42646ac95c791ee71759e153da3485e9f01762cb737f0872 written=2026-10-28T22:41:45+03:00 -->
# Sloglide

## What it is
Sloglide is a private log for films and series. You keep a queue, mark the one you are watching, and file it when you finish, with a whole grade from 1 to 5. It is for someone who wants that record on this device, without an account.

## Launch and onboarding
A cold launch shows a full-screen splash. VoiceOver calls it "Loading". There is no other text.

When the log is ready and the intro has not been finished, three pages appear. A counter reads "1" "of" "3", then "2" "of" "3", then "3" "of" "3". VoiceOver combines that as "Page".

1. "One title at a time." / "Light it when you start watching."
2. "Dismiss to log the finish." / "The queue does not count as watched."
3. "Grades stay on this device." / "Undo the last finish if the title was wrong."

"Skip" ends the intro from any page. "Next" moves to the next page. On the last page the primary button is "Start", which ends the intro and opens Tonight.

The app is dark. If a grade was left open, the "Grade" sheet returns and starts at 3.

## Screens

### Tonight
The home title is "Tonight". The top bar has three icon buttons. VoiceOver names them "Discover", "Queue", and "Profile". Each opens that screen as a sheet.

A count labeled "Finished" shows how many titles have been filed.

When the queue is empty and nothing is showing, the screen is "Nothing in the queue." with "Add a title, then light it when you start watching." The button is "Stash" plus the next unused shelf title, for example "Stash Rashomon". If every shelf title is already queued, showing, or finished, the button is "Discover titles" and opens Discover.

Otherwise the label is "Nothing showing" or "Now showing".

- Nothing showing and the queue is empty: "Nothing showing. Stash a title to fill the queue." The same stash button appears again as a heading and as the button.
- Nothing showing and the queue has titles: "Light one queued title, then dismiss it when the credits roll." The first queued title is shown with its year or "unknown", then "Movie" or "Series", and "Light". Further titles sit under "Also waiting", each with "Light".
- A title is showing: its name, year or "unknown", "Movie" or "Series", and "Log the film you just watched. Dismiss when the credits roll." "Dismiss" files it, clears the home slot, and opens "Grade". "Dismiss" stays disabled while that sheet is open.

Queued titles while something is showing are listed under "Waiting", each with "Light". "Open queue" opens Queue.

"Recent" lists filed titles, newest first, with the day ("Today", a short date, or "unknown") and the grade, or "unknown" if none was saved. "Finish log" opens Finish log.

If a tap is refused, one of these lines appears: "Light a queued title before you log a finish." or "Dismiss the title already showing before lighting another."

If the log could not be read or saved, the note is shown with "Retry": "The last save was unreadable. Restored the previous copy.", "Saved repertory could not be read. Started from an empty house.", "The log could not be saved.", or "Reset could not remove the saved file."

### Discover
Title "Discover". "Close" dismisses the sheet. The keyboard also has "Close".

The field placeholder is "Search movies" or "Search series". Chips "Movie" and "Series" switch the search. The selected chip is marked selected.

While a search with text is loading and there are no results yet, placeholder rows show "Title", "2000", and "Movie" or "Series". A spinner can also appear under the chips.

Each result shows the title (or "unknown" if the name is blank), the year or "unknown", "Movie" or "Series", and "Stash". Tapping stashes that title into the queue and stays on Discover. VoiceOver says "Stash" plus the title. Rows are disabled while a search is in progress. "More titles" loads another page and is disabled while a search is in progress.

If the search fails, the line is "Search is offline.", "No title matched.", "Search failed.", or "Search could not be read.", plus "Stash from the list or type a title." and "Retry".

An empty search, or a search that has not settled, shows "On this device" and this shelf, each with year, "Movie" or "Series", and "Stash":

- "Rashomon", 1950, Movie
- "Spirited Away", 2001, Movie
- "The Wire", 2002, Series
- "Paris, Texas", 1984, Movie
- "Chungking Express", 1994, Movie
- "Portrait of a Lady on Fire", 2019, Movie

A settled search with no results says "No matches."

"Type a title" has a field whose placeholder is "Title", and "Stash". "Stash" is disabled until the field has text. Stashing clears the field and adds that title as the chosen "Movie" or "Series", with year "unknown".

### Queue
Title "Queue". "Close" dismisses the sheet.

Empty, with a save problem and no queued titles: "Queue unavailable.", the save note, and "Retry".

Empty otherwise: "Nothing in the queue." / "Stash a title, then light the one you start." The button is "Stash" plus the next unused shelf title. That stashes it. If none remain, the button reads "Discover titles" and only closes Queue, returning to Tonight.

Each queued title shows its name, year or "unknown", and "Movie" or "Series". "Light" puts it on Tonight and closes Queue when that succeeds. VoiceOver says "Light" plus the title. "Earlier" moves it up and is disabled on the first title. "Later" moves it down and is disabled on the last title.

The same refusal lines and save note as Tonight can appear here.

### Profile
Title "Profile". "Close" dismisses the sheet.

"Finished" here counts only finishes that have a saved grade from 1 to 5. "Saved grades" is a bar chart for grades 1 through 5, with "Saved grades only." Under it, each grade shows its count and the grade number.

If there is a latest finish: "Latest finish", the title, and "Undo last finish". That asks "Undo the last finish?" with "It returns to the queue. The home slot stays as it is." Confirm with "Undo last finish" or "Cancel". If there is none: "No finishes yet."

"Contact" opens the support page.

These rows open another sheet:

- "Grades"
- "Finished titles" opens Finished
- "Finish log"
- "Day marks"
- "Undo finish" opens Undo
- "Finishing"
- "Settings"

### Grades
Title "Grades". "Close" dismisses it.

Empty of saved grades: "No saved grades yet." / "Dismiss a showing title, then save a whole grade from 1 to 5." The button is "Close" when opened as a sheet, otherwise "Back to tonight".

Otherwise a large count of saved grades, the "Saved grades" chart, "Saved grades only.", and a row of counts above the numbers 1, 2, 3, 4, and 5. Finishes still waiting on a grade are left out of this count.

### Finished
Title "Finished". "Close" dismisses it.

If finishes cannot be read and the list is empty: "Finishes unavailable.", the save note, and "Retry".

If there are none: "No finishes yet." / "Dismiss a showing title to file it here." Button "Back to tonight".

Otherwise the "Finished" count is every filed title, not only graded ones. "Latest" shows the newest title, year or "unknown", "Movie" or "Series", the day, and the grade or "unknown". Older ones are under "Earlier", with the same details.

### Finish log
Title "Finish log". "Close" dismisses it.

If the log cannot be read and is empty: "Log unavailable.", the save note, and "Retry".

If empty: "The log is empty." / "Dismiss a showing title and it lands here with the day." Button "Back to tonight".

Otherwise each finish, newest first, shows the title, the day ("Today", a short date, or "unknown"), the year or "unknown", "Movie" or "Series", and the grade or "unknown".

### Day marks
Title "Day marks". "Close" dismisses it.

Empty: "No day marks yet." / "Dismiss a showing title and the day is filed here." Button "Close" or "Back to tonight".

Otherwise: "The day you finished each film, and the grade you saved." Each row says "Finished", the day ("Today", "unknown", or a full month, day, and year), the title, year or "unknown", "Movie" or "Series", and "Grade 1 of 5" through "Grade 5 of 5", or "Grade not saved". The selected row says "Showing this day". The others say "Show this day". Tapping a row only selects it. The bottom button is "Close" or "Back to tonight".

### Undo
Title "Undo". "Close" dismisses it.

If there is a latest finish: "Latest finish", the title, and "Undo puts it back in the queue. The home slot stays as it is." "Undo last finish" asks "Undo the last finish?" with "It returns to the queue. The home slot stays as it is." Confirm with "Undo last finish" or "Cancel". The title returns to the front of the queue. Whatever is on Tonight stays there.

If there is nothing to undo: "Nothing to undo." / "Dismiss a showing title first." Button "Close" or "Back to tonight".

### Finishing
Title "Finishing". "Close" dismisses it. There are no actions.

"Light, then dismiss."

"Stash only fills the queue. Light puts one title on the home slot. Dismiss files it and clears the slot."

"Dismiss"

"That is the finish. A second light waits until the slot is clear. Undo puts the last finish back in the queue."

### Settings
Title "Settings". "Close" dismisses it.

"On this device"

"Show intro" shows the three intro pages again and closes Settings. The queue and finishes stay.

"Reset all data" asks "Reset all data?" with "Deletes every finish and queued title on this device." Confirm with "Reset all data" or "Cancel". Confirming clears the queue, the showing title, and every finish, then closes Settings.

"Contact" opens the support page.

### Grade
This sheet appears after "Dismiss". Title "Grade". "Close" is in the bar.

"Drag across the line. It snaps to a whole grade." The grade starts at 3 and can be 1, 2, 3, 4, or 5. VoiceOver calls the line "Grade". "Save" stores that grade on the finish just filed. Dragging the sheet closed, or tapping "Close", also stores the grade that is showing.

## Features
- Intro pages "One title at a time.", "Dismiss to log the finish.", and "Grades stay on this device.", with "Skip", "Next", and "Start".
- Tonight as the home slot: "Nothing showing" or "Now showing".
- "Stash" into the queue from search, from the on-device shelf, or by typing a title.
- "Light" one queued title onto Tonight.
- "Dismiss" to file a finish and open "Grade".
- Whole grades 1 to 5, saved with "Save".
- "Queue" order with "Earlier" and "Later".
- "Waiting", "Also waiting", and "Open queue".
- "Recent" and "Finish log", with the day and the grade or "unknown".
- "Finished" lists, "Latest", and "Earlier".
- "Saved grades" chart for 1 through 5.
- "Day marks" with "Show this day" and "Showing this day".
- "Undo last finish", which returns only the latest finish to the queue.
- "Finishing" explains light, then dismiss.
- "Show intro".
- "Reset all data".
- "Contact" on Profile and Settings.
- Search chips "Movie" and "Series", "More titles", and "Retry" when search fails.

## Behaviours that can look like bugs
- "Dismiss" does nothing until a title is showing. The line is "Light a queued title before you log a finish." Light a queued title first.
- A second "Light" does not replace the showing title. The line is "Dismiss the title already showing before lighting another." Tap "Dismiss" first.
- "Dismiss" is disabled while the "Grade" sheet is open. Tap "Save" or "Close".
- "Stash" under "Type a title" stays disabled until the field is not blank.
- "Earlier" is disabled on the first queued title. "Later" is disabled on the last.
- Search rows and "More titles" are disabled while a search is in progress.
- Stashing does not mean watched. The queue stays queued until "Light", then "Dismiss".
- "Light" removes that title from the queue and puts it on Tonight. "Dismiss" clears Tonight and adds it to the finish lists. The queue does not grow from a finish.
- "Undo last finish" puts that title at the front of the queue and does not change the title already showing.
- Only the latest finish can be undone. Older finishes stay filed.
- Closing "Grade" without dragging still saves a grade. The opening value is 3, so "Close" or "Save" with no drag files 3.
- The "Finished" count on Tonight and on Finished includes every filed title. The "Finished" count on Profile and on Grades includes only titles with a saved grade. A finish still on the grade sheet is missing from the chart until "Save".
- A grade that was never stored shows as "unknown" or "Grade not saved", and stays out of "Saved grades".
- An empty queue with every shelf title already used shows "Discover titles" on Queue, and that button only closes Queue.
- The same title can be stashed more than once. Each copy is its own queue row.
- Search can show "Search is offline.", "No title matched.", "Search failed.", or "Search could not be read." "Retry" tries again. "Stash from the list or type a title." still works.
- A settled search with nothing to show says "No matches." Clear the search to see "On this device" again.
- "Show intro" returns to the three pages. "Skip" or "Start" comes back. Nothing in the log is cleared.
- "Reset all data" is the wipe. After it, Tonight is the empty queue again.
- If a save fails, "The log could not be saved." stays until "Retry". "Reset could not remove the saved file." means the wipe did not finish. "The last save was unreadable. Restored the previous copy." and "Saved repertory could not be read. Started from an empty house." appear when an older copy had to be used or the log had to start over. Empty Queue, Finished, and Finish log then show "Queue unavailable.", "Finishes unavailable.", or "Log unavailable." with "Retry".

## Starter content and resume
A new install has an empty queue, nothing showing, and no finishes. Discover always offers the six shelf titles under "On this device": "Rashomon", "Spirited Away", "The Wire", "Paris, Texas", "Chungking Express", and "Portrait of a Lady on Fire". The empty Tonight and Queue buttons offer "Stash" plus the first of those not already queued, showing, or finished.

The queue, its order, the title on Tonight, finishes, grades, and an open grade come back after leaving the app. An open grade sheet returns at 3.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with anyone else, an account deletion flow, and an App Tracking Transparency prompt. "Reset all data" only clears the log on this device. Typed titles stay in that private log.

## Data and support
The queue, the showing title, finishes, and grades stay on this device. Search needs a connection to look up movies and series. If it cannot, the on-device shelf and "Type a title" still work.

"Contact" on Profile and on Settings opens the support page.

## Scanning and health
None.

## Platform
No region-specific screens. Dates follow the device calendar, including "Today". The interface is dark on iPhone and iPad. iPhone uses portrait and both landscapes. iPad also uses upside down. It runs full screen and does not offer a Mac or headset version. Minimum iOS is 17.0.

## Category
Entertainment.


## Optional Game Center
Game Center initializes when the native log opens. Declining sign-in does not block the diary. Profile includes Game Center status and a Connect Game Center button while signed out. Once signed in, View achievements opens Apple's dashboard and Retry sync retries pending progress. If sign-in remains unavailable, use the device's Settings > Game Center. No friends permission is requested.

The six achievements are First credits (1 graded film), Ten films, Fifty films, A hundred films, Series finale (1 graded series), and Ten verdicts (10 graded films or series). Queue entries and an unfinished grade do not count. Existing graded history counts. Progress is sent only after a successful local save, retried on connection/foreground, and kept separately for each Game Center player. Only achievement identifiers and percentages are sent; titles, viewing dates, and individual grades stay local. Undo and Reset all data do not revoke earned achievements. Simulator demo history never earns Game Center achievements.
