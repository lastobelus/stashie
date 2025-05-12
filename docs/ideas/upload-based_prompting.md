# Upload-Based Prompting

## Overview

Upload-based prompting is a method for interacting with AI assistants by uploading a file that contains both the user’s intent and relevant project material. This technique is particularly useful when paired with a tool that prepares the upload in a consistent structure.

A typical workflow involves:

- Selecting a project file (e.g., a code file, diff, or documentation source)
- Prepending a structured prompt tailored to the desired operation (e.g., generate commit message, refactor code, add documentation)
- Saving the combined prompt and content as a file in an `AI Uploads` directory, with a unique filename to avoid overwrites

This allows AI tools to process the input without additional user instruction, streamlining tasks that follow well-defined templates.

## Example Use Cases

- **Commit message generation:** Tool saves a staged diff with a prompt like “Please generate a commit message…” prepended.
- **Code refactoring:** The code file is prefixed with a description of the refactoring goal and rules for preserving function signatures and comments.
- **Documentation enhancement:** A prompt asks the assistant to add or improve in-code comments without altering logic.

## Multi-File Uploads with prompt.md

In scenarios requiring more complex input, a `.zip` file can be used instead of a single document. The zip should contain:

- A file named `prompt.md` – this contains the full instruction set or query.
- One or more supporting files (e.g., source code, configuration, documentation)

The AI can then interpret `prompt.md` as the root query and use the other files as reference material. This is particularly useful for multi-part refactors or documentation reviews where context from multiple files is necessary.

