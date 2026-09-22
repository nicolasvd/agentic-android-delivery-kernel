---
id: room-migrations
consumers: [P4, P5]
version: 1.1.0
triggers: Any change to @Entity, @Database(version=N), or data model affecting local persistence
---

# Skill: Room Database Migrations & Expand/Contract Protocol

> Extracted from `AppDatabase.kt` (versions 1→7, multi-source migrations), `TaskDao.kt`, and the existing `MentalLoadItem` migration chain.

---

## 1. Schema Versioning Protocol

### `@Database` Annotation Contract
```kotlin
@Database(
    entities = [YourEntity::class],
    version = N,                        // Increment monotonically. NEVER skip, NEVER decrement.
    exportSchema = true                 // REQUIRED: exports JSON schema to app/schemas/
)
abstract class AppDatabase : RoomDatabase() { ... }
```

**Schema export path** (`build.gradle.kts`):
```kotlin
ksp { arg("room.schemaLocation", "$projectDir/schemas") }
```
Check `app/schemas/<package>.<DatabaseClass>/<version>.json` into git on every version bump.

---

## 2. Non-Destructive Expand / Contract Protocol

Breaking schema evolutions must NEVER be executed in a single monolithic migration. Decompose into two distinct child issues:

### 🟢 Phase 1 (Expand) — Additive & Backward-Compatible
- **Rule**: Additive changes only. New columns MUST be `nullable` (e.g. `TEXT DEFAULT NULL`) or specify a `defaultValue`.
- **Invariants**: NEVER drop, rename, or restrict nullability of existing columns during Phase 1.
- **Safe DDL Example**:
  ```kotlin
  val MIGRATION_6_7 = object : Migration(6, 7) {
      override fun migrate(db: SupportSQLiteDatabase) {
          db.execSQL("ALTER TABLE `mental_loads` ADD COLUMN `subCategory` TEXT DEFAULT NULL")
      }
  }
  ```
- **Phase 1 Airbag (Mandatory)**: A `MigrationTestHelper` test asserting data retention across `N → N+1` must pass BEFORE any domain or UI logic is wired.

### 🔴 Phase 2 (Contract) — Safe Cleanup
- **Rule**: Executed in a separate child issue ONLY after all consumers (DAOs, Repositories, ViewModels) are updated and verified.
- **Safe Rebuild**: SQLite does not support `DROP COLUMN` before API 35. Use the create-insert-drop-rename pattern:
  ```kotlin
  fun migrateToV8Contract(db: SupportSQLiteDatabase) {
      // 1. Create target table without deprecated column
      db.execSQL("""
          CREATE TABLE IF NOT EXISTS `mental_loads_new` (
              `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              `title` TEXT NOT NULL,
              `subCategory` TEXT
          )
      """)
      // 2. Copy data with explicit column mapping
      db.execSQL("""
          INSERT INTO `mental_loads_new` (`id`, `title`, `subCategory`)
          SELECT `id`, `title`, `subCategory` FROM `mental_loads`
      """)
      // 3. Drop legacy table
      db.execSQL("DROP TABLE `mental_loads`")
      // 4. Rename new table
      db.execSQL("ALTER TABLE `mental_loads_new` RENAME TO `mental_loads`")
  }
  ```

---

## 3. Multi-Source Migration Fan-Out (Versions 1..6 → 7)

Register all historical source versions explicitly — never assume a linear upgrade path:
```kotlin
.addMigrations(
    MIGRATION_1_7, MIGRATION_2_7, MIGRATION_3_7,
    MIGRATION_4_7, MIGRATION_5_7, MIGRATION_6_7
)
.fallbackToDestructiveMigration(dropAllTables = true)   // dev safety net
```

---

## 4. In-Memory Migration Testing (`MigrationTestHelper`)

Every migration MUST have an automated test asserting zero data loss:

```kotlin
@RunWith(AndroidJUnit4::class)
class AppDatabaseMigrationTest {
    @get:Rule
    val helper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        AppDatabase::class.java
    )

    @Test
    fun migrate_6_to_7_retainsExistingData() {
        // 1. Create DB at version 6 and insert seed record
        helper.createDatabase(TEST_DB, 6).apply {
            execSQL("INSERT INTO mental_loads (id, title, area, isCompleted) VALUES (1, 'Seed Task', 'HOME', 0)")
            close()
        }
        // 2. Run migration to version 7 and validate schema
        val db = helper.runMigrationsAndValidate(TEST_DB, 7, true, MIGRATION_6_7)
        
        // 3. Assert existing data retained & new column initialized
        val cursor = db.query("SELECT title, subCategory FROM mental_loads WHERE id = 1")
        cursor.moveToFirst()
        assertThat(cursor.getString(0)).isEqualTo("Seed Task")
        assertThat(cursor.getString(1)).isNull() // default value verified
        db.close()
    }
}
```

---

## 5. DAO Conventions (from `TaskDao.kt`)

- **Reactive Reads**: Return `Flow<List<T>>` for UI-observed queries.
- **One-Shot Reads**: Use `suspend fun` for Use Case invocations.
- **Writes**: Always `suspend` + `OnConflictStrategy.REPLACE`.
- **Deletes**: Always `suspend` by entity or `@Query("DELETE FROM ... WHERE id = :id")`.

---

## 6. Rollback & Fallback Strategy

| Scenario | Strategy |
|---|---|
| Migration fails in production | Forward-only fix. Rollback via Room is unsupported. Guard features with remote feature flags. |
| Dev/Test builds | `fallbackToDestructiveMigration(dropAllTables = true)` resets state cleanly. |
| Production safety net | Backup local state to Firestore before applying schema migration. |

---

## Checklist — Before Incrementing `version`

- [ ] `exportSchema = true` is set in `@Database`.
- [ ] Schema JSON committed to `app/schemas/`.
- [ ] Phase 1 Expand: New columns are nullable or have defaults. Zero drops/renames.
- [ ] `MigrationTestHelper` test added and passing for `N → N+1`.
- [ ] All reachable previous versions covered in `.addMigrations(...)`.
- [ ] Phase 2 Contract isolated to a dedicated subsequent issue.
- [ ] `./gradlew codeSanityCheck` exits 0.
