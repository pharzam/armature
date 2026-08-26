## Linked issue (R1)

Closes #142

## What & why (R7)

- **Action:** add the SQLite datastore behind the store interface.
- **Why:** the in-memory store loses state on restart (F-0007).
- **Tradeoffs:** a file store was rejected as slower to query.
