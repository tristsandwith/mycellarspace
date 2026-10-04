# My Cellar Space

A wine fridge tracker laid out like the fridge itself: a front view with each bottle in its own space, colour-coded by style and ringed by where it sits in its drinking window.

The whole app is one file: `my-cellar-space.html`.

## Where it runs

The app is published as a claude.ai artifact with two runtime capabilities:

- `db`: the artifact's shared document database, where every cellar is saved.
- `user`: tells the app who's viewing, through their claude.ai sign-in.

Opened anywhere else (as a plain file or on another host), the page loads but can't save anything, because those capabilities only exist inside claude.ai.

## Features

- **Usernames:** each viewer picks a username on their first visit and gets their own cellar. No password is needed, because claude.ai's sign-in identifies them.
- **Menu (top right):**
  - Rename the cellar (the default name is "My Cellar Space").
  - Switch the fridge light on or off.
  - See which bottles are waiting for research.
- **Add a bottle:** tap an empty space and type the name and vintage. Claude researches the rest.
- **Bottle card:** style, blend style, producer, country, appellation, grapes, drinking window (opening up / peak / drink up) and tasting notes.
- **Drink it:** clears the space and moves the bottle to the **Drunk bottles** list, with Undo.
- **Move a bottle:** hold it, then drag it to another space.
- **More fridges:** hold the right-hand edge to add one, and swipe left or right to switch between them. Tap a fridge's name to rename or delete it.

## Data layout (the artifact database)

| Path | Holds |
|---|---|
| `profiles/<userId>` | `{username, cellar, cellarName, ledOff}` |
| `usernames/<lowercase name>` | `{uid, cellar}`: the claim on a username |
| `slots`, `fridges`, `history` | the original (owner's) cellar, `cellar: ""` |
| `cellars/<cellar>/slots` | everyone else's first fridge |
| `cellars/<cellar>/fridges/<fridgeId>` (and `/slots`) | added fridges |
| `cellars/<cellar>/history` | drunk bottles |

Each slot id is `r<rung>-<space>`, or `m-<n>` for the magnum shelf.

## Research

The app can't search the web itself. A Claude Code session fills in the bottles using `.claude/skills/wine-research/SKILL.md`. Say "Research my wines" in a session opened on this repo, with the environment's network access set to Full for the run.

`.claude/skills/wine-research/fetch.sh` is the only way pages are opened during research. It accepts https only, caps downloads at 5 MB, keeps HTML/text/PDF only and strips scripts.

## Publishing changes

Edit `my-cellar-space.html`, then ask Claude to republish it to the artifact URL in the research skill. Leave the capabilities as they are (`db` and `user`).
