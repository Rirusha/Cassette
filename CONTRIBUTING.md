## How to contribute

If you don't know what to do, then:
* All scheduled tasks are in the issue section and have the "enhancement" label.
* All known problems are in the same place and have a "bug" label.

Choose tasks from the nearest versions. You can find a list of them [here](https://github.com/Rirusha/Cassette/milestones). This will both speed up the release of the next version and facilitate the review, so you will not need to switch from one global problem to another.

Also, if you decide to fix some bug described in the issue, first make sure that it can still be reproduced in the `main` branch.

Also, if you think that the application is missing something or you have found a bug, then do not hesitate to create an issue.

## Naming commits
The message header should look like:
```
feat: add a play button to the `Widget name`

The button was missing, so it had to be added
```
This is an example. The rules are described in more detail [here](https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional). Also, the message body is optional if the information in the header is exhaustive. Also here is a list of all types of commits with descriptions:

* `build`: Used for changes related to the system build or external dependencies.

* `chore`: Usually includes changes that are not directly related to the code or tests, for example, updating documentation, configuring the development environment, upgrading the version, etc.

* `ci`: Refers to changes related to configuring or improving CI.

* `docs`: Used for changes related only to documentation, such as correcting typos, updating the README, or adding comments to the code.

* `feat`: Indicates the addition of new functionality or features to the project.

* `fix`: Refers to fixing errors in the code or fixing problems in the project.

* `perf`: Used when changes are made to improve performance.

* `refactor`: Refers to changes that do not add new functionality, but only change the structure or organization of existing code.

* `revert`: Used to undo previous commits in the project history.

* `style`: Refers to changes in the formatting of the code, for example, edits of spaces, indents, line breaks, etc.

* `test`: Used to add or modify test code, for example, testing new functionality or correcting existing tests.

* `po`: Used to add or change a translation.

## Creating Pull Requests
All Pull Requests must be made in the `master` branch. If you close an issue, then link to it with the keyword "close" in the commit body, for example:
```
fix: fix incorrect behavior

close #123
```

## Formatting the code
If you are using Visual Studio Code, then there is a task to run the linter. Otherwise, use the configuration in the root of the repository in the linter: vala-lint.conf, CI uses it exactly.

## Development
Check the build using flatpak, as this is the only officially supported version.

## Testing
Writing or supplementing existing tests for the client is highly welcome.
