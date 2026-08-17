# CLAUDE.md

**Read [AGENTS.md](AGENTS.md) first** — architecture, golden rules, code annotation format,
backport rules, docs workflow. It is the shared source of truth for all agents.

This file holds only what AGENTS.md does not cover or gets wrong for *this* fork.
Where they conflict, this file wins.

## What this fork is

AGENTS.md was inherited from the Linux-first [fbraz3/GeneralsX](https://github.com/fbraz3/GeneralsX)
lineage and leads with Docker/Linux. This fork's active targets are **macOS (Apple Silicon) and
iOS/iPadOS** — see [README.md](README.md). iOS does not appear in AGENTS.md at all.

- Primary presets: `macos-vulkan`, `ios-vulkan`. Target: `z_generals` (→ `GeneralsXZH`).
- Renderer chain: DirectX 8 → DXVK → Vulkan → MoltenVK → Metal.
- Linux/Docker paths in AGENTS.md still exist but are not what gets tested here.

## Build, deploy, run (macOS)

```bash
./scripts/build/macos/build-macos-zh.sh      # configure + build (--build-only to skip configure)
./scripts/build/macos/deploy-macos-zh.sh     # → ~/GeneralsX/GeneralsZH + run.sh
```

**Preferred run command** — use this unless a task needs something else:

```bash
cd ~/GeneralsX/GeneralsZH && ./run.sh -win -mod ControlBarPro_BarOnly.big -fps 60
```

The same flags are wrapped in an `/Applications` launcher, regenerated with
`./scripts/build/macos/make-app-shortcut-zh.sh` (edit `GAME_FLAGS` there to change them).

Equivalent manual build: `cmake --preset macos-vulkan && cmake --build build/macos-vulkan --target z_generals`.
First configure takes 5–10 min (DXVK is fetched and built via Meson); later builds under a minute.
Prereqs and troubleshooting: [docs/BUILD/MACOS.md](docs/BUILD/MACOS.md).

**Runtime dir is `~/GeneralsX/GeneralsZH`.** AGENTS.md says `~/GeneralsX/GeneralsMD` — that is now
only a legacy fallback the scripts still detect.

## Build and install (iOS)

```bash
git submodule update --init references/fbraz3-dxvk
./scripts/build/ios/fetch-moltenvk.sh && ./scripts/build/ios/stage-fonts.sh
cmake --preset ios-vulkan && cmake --build build/ios-vulkan --target z_generals
GX_TEAM_ID=<team> GX_BUNDLE_ID=com.you.generalszh ./scripts/build/ios/package-ios-zh.sh --install
```

`--dev` skips the ~2.7 GB asset copy for fast code iteration. DXVK-on-iOS is built from the
submodule plus [`Patches/dxvk-ios.patch`](Patches/dxvk-ios.patch).

## Running with mods

Retail `.big` mods load through the original `-mod` switch (`parseMod` in
[CommandLine.cpp:1060](GeneralsMD/Code/GameEngine/Source/Common/CommandLine.cpp:1060)). Drop the
`.big` in the user data dir and pass its name, or pass an absolute path; `-mod <directory>` loads
every `.big` in a folder.

- macOS user data dir: `~/Library/Application Support/GeneralsX/GeneralsZH/`
- Linux: `~/.local/share/GeneralsX/GeneralsZH/`

```bash
cd ~/GeneralsX/GeneralsZH && ./run.sh -win -mod ControlBarPro_BarOnly.big -fps 60
```

Mod files override the base archives (`Data/INI/...`, `Window/*.wnd`, `Art/Textures/*`). Art-and-layout
mods are client-side; gameplay-INI mods desync against unmodded peers and break retail replays.
Full notes: [docs/HOWTO/INSTALLATION.md](docs/HOWTO/INSTALLATION.md). Other flags:
[docs/ETC/COMMAND_LINE_PARAMETERS.md](docs/ETC/COMMAND_LINE_PARAMETERS.md).

## Verifying a change

There is no unit test suite for engine changes. "It builds" is not verification — build, deploy, and
actually run the affected path. Logs land in `logs/`. `-noshellmap` skips the animated menu and gets
you to a game faster. Replay determinism tests (`GeneralsReplays/`, [TESTING.md](TESTING.md)) need a
VC6 build with `RTS_BUILD_OPTION_DEBUG=OFF` and are not runnable on this machine.

## Working notes

- Commit trailer used throughout this fork's history:
  `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
- Conventional-commit titles (`fix(io):`, `docs:`, `macos:`); code annotations
  `// GeneralsX @keyword author DD/MM/YYYY Description` — see [CONTRIBUTING.md](CONTRIBUTING.md).
- Never edit `build/_deps/...` (DXVK). Fix in the fork repo, or use `-DSAGE_DXVK_USE_LOCAL_FORK=ON`.
- `.github/copilot-instructions.md` has stale script paths (`./scripts/docker-*.sh`,
  `scripts/cpp/fixIncludesCase.sh`); the scripts now live under `scripts/build/<platform>/` and
  `scripts/tooling/`. AGENTS.md has the current ones.
- `CLAUDE.md` and `/.claude/` are gitignored — this file is local, not committed.
</content>
</invoke>
