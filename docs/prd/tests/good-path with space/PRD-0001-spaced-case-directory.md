# PRD-0001. Spaced case directory (good fixture)

The name of the directory that holds this PRD contains a space. prd-lint held its
file list in a space-joined string and then looped over it unquoted, so awk was
handed three fragments — the directory name carries two spaces, so the one path
became `…/good-path`, `with` and `space/PRD-0001-…`, each treated as a separate
file, and none of them openable.

## 6. Functional requirements

| REQ | Statement | MoSCoW | Phase | Facts |
| --- | --------- | ------ | ----- | ----- |
| REQ-001 | The system accepts an order. | Must | 1 | F-0001 |
| NFR-001 | The system responds within one second. | Should | 2 | F-0001#3 |

## 12. Requirements traceability matrix

| REQ | Facts | Guardrail | ADR | Task | Test |
| --- | ----- | --------- | --- | ---- | ---- |
| REQ-001 | F-0001 | — | — | T-ab12 | REQ-001 |
| NFR-001 | F-0001#3 | — | — | T-ab12 | NFR-001 |
