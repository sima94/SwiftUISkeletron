# DesignSystem — Agent Guide

## Rules

- Use `Spacing.*` instead of raw CGFloat for all padding and spacing
- Use `AppColor.*` instead of `Color.blue`, `Color.red`, etc.
- Use `Radius.*` instead of raw corner radius values
- When adding new tokens, add them to `Tokens.swift` in the appropriate enum

## Token Reference

| Category | Values |
|---|---|
| Spacing | `xxs(4)` `xs(8)` `sm(12)` `md(16)` `lg(24)` `xl(32)` `xxl(48)` |
| AppColor | `primaryAction` `destructiveAction` `secondaryAction` `background` `secondaryBackground` `overlay` `errorText` |
| Radius | `sm(8)` `md(12)` `lg(16)` |

## Examples

```swift
// Good
.padding(Spacing.md)
.background(AppColor.primaryAction)
.cornerRadius(Radius.md)
Text(error).foregroundColor(AppColor.errorText)

// Bad
.padding(16)
.background(Color.blue)
.cornerRadius(12)
Text(error).foregroundColor(.red)
```
