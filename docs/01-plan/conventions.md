# bloodline — Coding Conventions

> Phase 2 (Convention) 산출물. Plan §8과 Design §10에서 정의된 규칙의 단일 출처.

## 1. Naming

| Target | Rule | Example |
|--------|------|---------|
| File (script) | `snake_case.gd` | `enemy_spawner.gd` |
| File (scene) | `snake_case.tscn` | `level_up.tscn` |
| File (resource) | `PascalCase_id.tres` | `Whip.tres`, `Slime.tres` |
| Node in scene tree | `PascalCase` | `WeaponHolder`, `HealthBar` |
| Class (`class_name`) | `PascalCase` | `WeaponData`, `StatsComponent` |
| Function | `snake_case` | `apply_upgrade()` |
| Variable (instance/local) | `snake_case` | `var move_speed` |
| Private member | `_snake_case` (leading underscore) | `var _stats: StatsComponent` |
| Constant | `UPPER_SNAKE_CASE` | `const MAX_ENEMIES = 800` |
| Signal | `snake_case`, past-tense verb | `enemy_died`, `upgrade_chosen` |
| StringName literal | `&"snake_case"` | `add_to_group(&"enemy")` |

## 2. Folder Structure

```
bloodline/
├── project.godot
├── icon.svg
├── CLAUDE.md                   # AI 협업 컨텍스트
├── .gitignore, .gitattributes, .gutconfig.json
├── addons/                     # 외부 Godot 플러그인 (gut 등)
├── scenes/
│   ├── main/                   # Main, GameWorld
│   ├── player/
│   ├── enemies/
│   ├── weapons/
│   ├── pickups/
│   ├── ui/                     # HUD, LevelUp, MainMenu, GameOver
│   └── maps/                   # M3+
├── scripts/
│   ├── autoload/               # EventBus, GameState, (M3) SaveManager, AudioManager
│   ├── data/                   # *Data resource scripts (class_name)
│   ├── player/
│   ├── enemies/
│   ├── weapons/
│   ├── pickups/
│   ├── systems/                # Pool, AchievementSystem, ...
│   └── ui/
├── resources/                  # .tres data files (1 folder per type)
├── assets/                     # sprites, audio, fonts
├── tests/
│   ├── unit/                   # GUT L1
│   └── scene/                  # GUT L2 (future)
└── docs/                       # PDCA documents
```

## 3. Architecture Patterns

### 3.1 Communication

| Scope | Mechanism | Example |
|-------|-----------|---------|
| Cross-system | `EventBus` signal | `EventBus.enemy_died.emit(enemy, position)` |
| Same scene parent↔child | Local signal | `Button.pressed` |
| Within same actor | Direct method call | `player.weapon_holder.add_weapon(w)` |
| Service location (pools) | Group lookup | `get_tree().get_first_node_in_group(&"projectile_pool")` |

**Adding new EventBus signal**: update Design §4.1 catalog and Decision Record.

### 3.2 Data vs Logic

- Balancing values → `Resource(.tres)` files (auto-completable in editor, type-safe)
- Algorithmic logic → `.gd` files
- **No magic numbers** in `.gd` — use `const`, `@export`, or load from Resource

### 3.3 Object Pool

Pooled scenes MUST implement:
```gdscript
signal released
func on_acquire(args: Dictionary) -> void: ...
func on_release() -> void: ...
```

Emit `released` to return to pool automatically.

### 3.4 Layer Assignment (Godot-adapted Clean Architecture)

| Layer | Folder | Can Depend On |
|-------|--------|---------------|
| Presentation (UI scenes) | `scenes/ui/`, `scripts/ui/` | EventBus, GameState, Systems |
| Behavior | `scripts/player|enemies|weapons|pickups/` | Systems, Data, Infrastructure |
| Systems | `scripts/systems/` | Data, Infrastructure |
| Data | `scripts/data/`, `resources/` | (nothing — pure data) |
| Infrastructure | `scripts/autoload/` | (nothing — providers) |

## 4. Physics Layers

| # | Name | Used By |
|---|------|---------|
| 1 (value 1) | world | StaticBody2D world bounds (M3 maps) |
| 2 (value 2) | player | Player CharacterBody2D |
| 3 (value 4) | enemy | EnemyBase Area2D |
| 4 (value 8) | player_projectile | Projectile Area2D |
| 5 (value 16) | enemy_projectile | (M3) ranged enemies |
| 6 (value 32) | pickup | ExpGem Area2D |

## 5. InputMap Actions

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| `move_up` | W / ↑ | Left stick up |
| `move_down` | S / ↓ | Left stick down |
| `move_left` | A / ← | Left stick left |
| `move_right` | D / → | Left stick right |
| `pause` | ESC | Start button |

**Rule**: Never read raw keys. Use `Input.get_vector(...)` or `Input.is_action_pressed(...)`.

## 6. Script Header

```gdscript
# Design Ref: §X.Y — {decision rationale}
# Plan SC: {success criteria id}   (only on critical scripts)
class_name Foo
extends Bar
```

## 7. Resource Authoring

`.tres` files follow Godot text format. When editing manually:
- `load_steps = ext_count + sub_count + 1`
- `script` always set via `ExtResource("id")`
- StringName: `&"value"`
- Color: `Color(r, g, b, a)` with 0~1 floats

## 8. Test Conventions

| Level | Tool | Location | Naming |
|-------|------|----------|--------|
| L1 Unit | GUT | `tests/unit/` | `test_*.gd` |
| L2 Scene | GUT | `tests/scene/` | `test_*_scene.gd` |
| L3 Manual | Playthrough checklist | Analysis doc | — |
| L4 Performance | Godot Monitor | (manual) | — |

GUT test class: `extends GutTest`. Use `before_each` / `after_each` for setup/teardown.

## 9. Git

| Item | Convention |
|------|------------|
| Commit prefix | `[feat|fix|refactor|docs|test|chore]` |
| Commit body | Bullet list of changes |
| Trailers | None (no Co-Authored-By) |
| Sensitive files | Never commit `.env`, `keys/`, `*.bak` (already in .gitignore) |
| Large binaries | Use Git LFS for `.png` >1MB, `.ogg` >2MB (.gitattributes 후보 주석 처리됨, M3+ enable) |

## 10. Forbidden Patterns

| Don't | Why |
|-------|-----|
| Raw key codes | Breaks rebinding + mobile port (v2.0) |
| `get_node("/root/Main/...")` absolute paths | Brittle. Use groups or @export NodePath |
| Magic numbers in `.gd` | Move to const or Resource |
| Cross-system direct refs | Use EventBus instead |
| `_ready()` order assumptions | Use `call_deferred` if you need post-tree state |
| Tween/animation in `_physics_process` | Use `_process` for visuals, physics for logic |
| Comments explaining WHAT code does | Comments only for WHY (non-obvious decisions) |

## 11. Comment Convention

- **Default: no comments**. Well-named identifiers explain WHAT.
- **DO comment**: non-obvious WHY (workaround, performance trick, design constraint).
- **Module header**: `# Design Ref: §X.Y — {rationale}` for traceability.
- **Decision marker**: `# Plan SC: FR-XX` on critical-path code.
