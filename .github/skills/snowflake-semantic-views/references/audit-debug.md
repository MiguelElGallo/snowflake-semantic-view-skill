# Audit And Debug Checklist

Use this file for existing semantic views that need quality review or targeted troubleshooting.

## Audit

Check:

- Missing relationships between fact and dimension tables.
- Duplicate or overlapping dimensions, facts, metrics, filters, or synonyms.
- Inconsistent naming, descriptions, synonyms, or business definitions.
- Metrics without clear aggregation semantics.
- Filters that encode important business concepts but are missing from the model.
- VQRs that no longer compile or no longer match trusted results.

## Debug

1. Reproduce the failing question or semantic-view SQL.
2. Capture generated SQL when Cortex Analyst is involved.
3. Write or obtain trusted SQL for the same question.
4. Compare generated and trusted results exactly.
5. Identify the smallest model gap:
   - Missing or weak descriptions/synonyms.
   - Missing metric/filter.
   - Missing or incorrect relationship.
   - Ambiguous relationship path requiring `USING`.
   - Need for narrow AI SQL generation instruction.
6. Patch one gap at a time.
7. Re-run the original failing test and at least one related regression query.

## Output

Report the failure, root cause, exact change made or proposed, validation result, and any remaining uncertainty.
