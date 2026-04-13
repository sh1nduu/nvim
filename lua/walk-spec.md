# walk.lua Specification (for LLMs)

Reference for generating `.walk.md` files and invoking the walkthrough plugin.

## Purpose

`walk.lua` is a nvim plugin that renders a Markdown file (`.walk.md`) as an
interactive **source code walkthrough**:

- Top 2/3 of editor: source file with a highlighted line range
- Bottom 1/3: TOC (left) + explanation float (right)
- User navigates step-by-step or jumps via TOC

Use it when you want to **explain code by walking the reader through specific
file ranges** with prose commentary attached to each range.

## When to generate a `.walk.md`

Generate one when the user asks for any of:

- "this file/module を解説して" / "explain this module"
- "コードレビューの walk を作って"
- "オンボーディング資料"
- "バグ原因のトレース"
- "リポジトリの読み方"
- "設計の流れを示して"

Save the file with a `.walk.md` suffix. A reasonable default location is
`~/.config/nvim/walks/` or `/tmp/`.

## File format

```markdown
# Walk Title (also serves as the first chapter implicitly)

Optional preamble text (before any `##` heading).

# Chapter Name

Optional chapter intro text.

## Step heading
@ /absolute/path/to/file.ext:start-end

> **役割**: one-line summary of this step's role in the whole
> **重要度**: ★/★★/★★★ + brief tier label
> **深度**: 30秒/3分/じっくり10分

Markdown body. Code blocks, lists, tables, blockquotes all OK.

## Next step heading
@ /path/to/another.ext:42

Body...

# Another Chapter

## Yet another step
@ /path/to/third.ext:100-150

Body.

## Commentary-only step (no @ line)

When you omit the `@` line, the source is not changed and the float
appears in the screen center (good for transitions, summaries, intros).
```

### Grammar rules (strict)

| Pattern | Meaning |
|---------|---------|
| `# Title` (single `#` + space) | Chapter heading. **First one is also the walk title** (used in TOC header). |
| `## Step` (two `##` + space) | Step heading. Each `##` starts a new step. |
| `@ path:line` | Reference for current step. Path **must be absolute**. Line is 1-indexed. |
| `@ path:start-end` | Range reference (inclusive). |
| `> ...` blockquote | Renders prominently in glow (good for role/importance metadata). |
| Anything else inside a step | Markdown body for that step. |

### Path requirements

- **Absolute paths only** (e.g., `/Users/foo/project/src/bar.ts`).
- The `~` prefix is supported (`~/proj/file.ts`).
- Relative paths are interpreted relative to **nvim's `cwd`** at run time, which is fragile — prefer absolute.

### Line number requirements

- Lines must exist in the target file. Out-of-range lines are clamped to file end (no error, but jumps to wrong place).
- **Line numbers drift when the source file changes.** When generating walks for a file, use `Grep` to find the actual line numbers of functions/sections you reference.

## Authoring guidelines

### Per step: include a role blockquote

This dramatically reduces reader cognitive load. Put it right after the `@` line:

```markdown
## 5. Float positioning
@ /path/walk.lua:196-259

> **役割**: this plugin's centerpiece — bottom-right placement
> **重要度**: ★★★ critical
> **深度**: じっくり10分
```

The reader can scan the role line to decide depth of attention before reading the body.

### Group steps into chapters

Use `# Chapter` to express narrative arc. Naming chapters by **role**
(not just topic) helps:

- ✓ "Setup layer (read first)"
- ✓ "Rendering layer (the heart)"
- ✗ "Functions"

### Step body length

- Aim for 5-15 lines of body per step.
- The float scrolls if longer, but readers prefer compact steps.
- Move detailed code analysis into the source itself (the reader can see it via the highlighted range).

### Multiple files

Each step can reference any file. Cross-file walks are encouraged for tracing flows (caller → callee → return path).

### Commentary-only steps

Use sparingly for:

- Walk introduction (after `# Title`, before first `##`)
- Chapter introductions
- Summaries / wrap-ups

Don't make a wall of commentary-only steps — they break the source-following rhythm.

## Launching

The plugin is loaded automatically via `require("walk")` in `init.lua`.

### Inside nvim

```vim
:WalkStart /path/to/file.walk.md   " start the walkthrough
:WalkToc                           " toggle TOC sidebar
:WalkNext       (or  ]w )          " next step
:WalkPrev       (or  [w )          " previous step
:WalkGoto 5                        " jump to step 5
:WalkFocus      (or <leader>wf)    " move focus to the explanation float
:WalkQuit       (or <leader>wq)    " end the walkthrough
```

### Default keymaps (active only during a walk)

| Key | Action |
|-----|--------|
| `]w` | next step |
| `[w` | previous step |
| `<leader>wt` | toggle TOC |
| `<leader>wf` | focus explanation float |
| `<leader>wq` | quit walkthrough |

### Inside the TOC float

| Key | Action |
|-----|--------|
| `j` / `k` | move cursor |
| `<CR>` | jump to step under cursor (TOC stays focused) |
| `o` | jump and focus the explanation float |
| `<LeftMouse>` | click a step to jump |
| `q` | close TOC |

### Triggering remotely (from a script or another agent)

```bash
nvim --server /path/to/socket --remote-send '<Esc>:WalkStart /tmp/foo.walk.md<CR>'
```

(Requires nvim to be running with `--listen <socket>` or `:lua vim.fn.serverstart('/path/to/socket')`.)

## Common LLM mistakes to avoid

1. **Stale line numbers**: Never reference a range you haven't verified in the current file. Always grep/read the file before writing the `@` line.
2. **Relative paths**: Use absolute paths. The plugin handles `~` and `:edit`-style relative paths but absolute is most reliable.
3. **Single `#` heading without intent**: Remember the first `#` is both walk title and an implicit chapter. Don't put `# Title` then `# Other Title` immediately — the second becomes a chapter.
4. **No `@` line**: Valid (commentary-only step) but signal it explicitly in your prose ("章のまとめ" / "section intro").
5. **Overlong bodies**: Float height is fixed (bottom 1/3 of editor). Long bodies require the user to scroll inside the float. Aim for ~10 lines.
6. **Missing role/depth blockquote**: Reduces walk usability significantly. Always include them unless the user opts out.

## Minimal valid example

```markdown
# Hello walk

## 1. The entry point
@ /tmp/hello.lua:1-5

> **役割**: program entry, sets up logging
> **重要度**: ★★ orientation
> **深度**: 1 minute

`main` is invoked from CLI. It just configures logging and dispatches to `run`.

## 2. The work loop
@ /tmp/hello.lua:7-25

> **役割**: where actual work happens
> **重要度**: ★★★ core
> **深度**: 5 minutes

Polls the queue, processes each item, exits on signal.
```

## Plugin source

`~/.config/nvim/lua/walk.lua` — the implementation. ~575 lines, no
external dependencies beyond nvim 0.10+ (`virt_text_pos = 'overlay'`,
`title`/`footer` on floats, `vim.keymap.set` with `buffer = N`).
