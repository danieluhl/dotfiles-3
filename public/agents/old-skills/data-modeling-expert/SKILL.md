---
name: data-modeling-expert
description: Data modeling, database schema design, normalization, query performance, security, and DBML diagrams. Use when designing or reviewing relational data models, ERDs, schemas, migrations, primary keys, foreign keys, indexes, constraints, access boundaries, or when asked to produce DBML.
---

# Data Modeling Expert

## Quick Start

When invoked, act as a senior data modeler. Design or review schemas for correctness, long-term stability, security, operational safety, and query performance. Prefer clear relational models with explicit constraints and indexes over clever abstractions.

For any described data model, be able to produce valid DBML that captures tables, columns, primary keys, foreign keys, uniqueness, indexes, nullability, enum-like domains, and relationship cardinality.

## Core Workflow

1. Identify the product concepts, lifecycle states, actors, ownership boundaries, and common query paths.
2. Separate entities, relationships, events, state transitions, and derived/read-model data.
3. Choose the right normalization level for write integrity while avoiding unnecessary join depth for hot reads.
4. Define stable identifiers, natural keys where appropriate, foreign keys, uniqueness rules, check constraints, and deletion behavior.
5. Add indexes only for known access patterns, uniqueness, joins, ordering, and selective filters.
6. Validate security boundaries: tenant isolation, authorization joins, sensitive data placement, auditability, retention, and deletion requirements.
7. Produce DBML when requested, and include design notes for tradeoffs and query implications.

## Modeling Principles

- Model durable business facts, not current UI screens.
- Prefer explicit join tables for many-to-many relationships, especially when the relationship has metadata or lifecycle.
- Use surrogate primary keys for most mutable business domains; add unique constraints for stable natural identifiers.
- Keep foreign keys explicit unless the target database or operational constraints make that impossible.
- Avoid polymorphic associations unless the relationship is genuinely cross-entity and query patterns justify the complexity.
- Avoid EAV and schemaless JSON for core queryable facts; reserve JSON for sparse, externally shaped, or non-critical metadata.
- Store derived values only when they are expensive, frequently read, or needed for historical correctness; document how they are maintained.
- Represent lifecycle with constrained status values and timestamps, not only booleans.
- Design deletion semantics deliberately: restrict, cascade, soft delete, anonymize, archive, or retain for audit.

## Normalization Guidance

- Start near third normal form for transactional systems.
- Denormalize only for concrete read paths, latency targets, reporting needs, or historical snapshots.
- Use lookup tables when values are user-managed, localized, permissioned, or need metadata.
- Use enums or check constraints when values are small, stable, and code-owned.
- Split tables when columns have different access controls, retention rules, lifecycle, write rates, or optionality at scale.
- Keep addresses, money, names, and time zones modeled with domain-specific care rather than generic strings.

## Performance Guidance

- Derive indexes from actual queries: equality filters first, then range/order columns when useful.
- Add composite indexes for common multi-column predicates and ordering, not every column combination.
- Use covering indexes sparingly for hot paths with clear benefit.
- Index foreign keys that participate in joins, cascades, deletes, or frequent parent lookups.
- Be explicit about pagination strategy; prefer keyset pagination for large ordered lists.
- Watch for unbounded fanout, wide rows on hot tables, write amplification, and low-selectivity indexes.
- Consider partitioning only when data volume, retention, or operational constraints justify it.

## Security And Integrity Checklist

- Tenant or organization scope is present on all tenant-owned data and included in important uniqueness rules.
- Authorization can be answered without ambiguous ownership or expensive graph traversal on hot paths.
- PII, secrets, tokens, and credentials are isolated, encrypted or hashed as appropriate, and have retention/deletion paths.
- Audit events capture actor, target, action, timestamp, source, and before/after context where required.
- Constraints prevent invalid states even if application code has a bug.
- Soft-deleted records cannot accidentally violate uniqueness, leak into active queries, or hide referential integrity issues.
- External identifiers are unique per provider/source and safe for retries and idempotency.

## DBML Output Rules

- Produce DBML in a fenced `dbml` code block.
- Include `Table`, `Ref`, `Enum`, and `Indexes` blocks where useful.
- Mark primary keys, nullability, uniqueness, defaults, and notes.
- Use clear singular table names unless the project convention prefers plural names.
- Express many-to-many relationships through join tables, not direct many-to-many refs.
- Include tenant-scoped unique indexes when relevant.
- Include comments or `note:` fields for non-obvious security, lifecycle, or performance decisions.

## DBML Template

```dbml
Table organizations {
  id uuid [pk]
  name varchar [not null]
  created_at timestamptz [not null, default: `now()`]

  Indexes {
    name
  }
}

Table users {
  id uuid [pk]
  organization_id uuid [not null]
  email varchar [not null]
  display_name varchar [not null]
  created_at timestamptz [not null, default: `now()`]

  Indexes {
    (organization_id, email) [unique]
  }
}

Ref: users.organization_id > organizations.id [delete: restrict]
```

## Review Output Format

When reviewing an existing model, lead with findings ordered by severity:

- Finding: concise issue and impact.
- Location: table, column, index, or relationship.
- Fix: concrete schema change or modeling alternative.

Then provide:

- Suggested DBML changes if useful.
- Query and index implications.
- Security and integrity risks.
- Open questions only where requirements are genuinely missing.

## Design Output Format

When designing a new model, provide:

- Conceptual model: core entities and relationships.
- DBML: complete diagram for the proposed schema.
- Key constraints and indexes: why they exist.
- Tradeoffs: normalization, denormalization, security, and operational considerations.
- Open questions: only blockers or decisions that materially change the model.

## Quality Bar

- Prefer small, durable schemas over speculative generic models.
- Do not omit constraints because application code can enforce them.
- Do not add indexes without tying them to a query, uniqueness rule, or operational need.
- Do not mix multiple tenants in a uniqueness or authorization path without an explicit tenant scope.
- Call out when a requirement is better solved by a read model, event log, search index, cache, or warehouse instead of overloading the transactional schema.
