# render-markdown.nvim health check

Open this file in nvim and confirm each section renders.
Toggle raw vs rendered with `<leader>um` to compare.
Everything below should show virtual text, icons, or highlights - not literal Markdown syntax.

## Headings

The six lines below must each show a per-level circle glyph (`󰲡` `󰲣` `󰲥` `󰲧` `󰲩` `󰲫`) in place of the `#` marks, with a full-width tinted background.
If they render as plain `##` text, `heading.icons` is being blanked again (the `lang.markdown` extra sets it to `{}`; `markdown.lua` restores it).

# H1 sample
## H2 sample
### H3 sample
#### H4 sample
##### H5 sample
###### H6 sample

## Inline styles

**Bold**, *italic*, ***bold italic***, ~~strikethrough~~, and `inline code`.
A [link to the plugin](https://github.com/meanderingprogrammer/render-markdown.nvim) should show a link icon.

## Lists

- First bullet, which should get a `●` / `○` marker
  - Nested bullet
    - Deeper bullet
- Back to top level

1. Ordered item one
2. Ordered item two
   1. Nested ordered item
3. Ordered item three

## Task lists

`[ ]` and `[x]` should render as `󰄱` and `󰱒`; `[-]` becomes a todo clock via the plugin default.
If these stay as literal `[ ]` / `[x]` text, `checkbox.enabled` is being turned off again.

- [ ] Unchecked
- [x] Checked
- [-] Todo
- [~] Custom

## Code block

Language label and a tinted block spanning the full width, no sign column glyph.

```lua
local function greet(name)
  return string.format("hello, %s", name)
end
```

## Block quote and callouts

> A plain block quote should get a colored left border.

> [!NOTE]
> Callout titles like NOTE, TIP, WARNING should render with an icon and colored title.

> [!WARNING]
> Second callout to confirm more than one admonition type resolves.

## Table

Columns should align and the header separator should render as a solid rule.

| Feature      | Expected                        | Status |
| ------------ | ------------------------------- | ------ |
| Headings     | circle glyph + background       | check  |
| Tables       | aligned cells, drawn borders    | check  |
| Code blocks  | language label, full-width fill | check  |
| Callouts     | icon + colored title            | check  |

## Horizontal rule

---

## Footnote

A claim that needs a source.[^1]

[^1]: The footnote body should render below with a back-reference.
