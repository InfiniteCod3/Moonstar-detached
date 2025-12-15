## 2024-05-23 - Quadratic String Concatenation in Unparser
**Learning:** Found O(N^2) string concatenation in `Unparser:unparseExpression` for `FunctionCallExpression` and `TableConstructorExpression`. This caused significant slowdowns for large inputs (e.g. 20000 items -> 2s+).
**Action:** Always use `table.concat` for loops that build strings, especially in code generation where input size can be large.
