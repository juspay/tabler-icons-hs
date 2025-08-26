# tabler-icons

Haskell bindings for [Tabler Icons](https://tabler.io/icons) - a set of over 5,000 free SVG icons.

📖 **[View Documentation on Hackage](https://hackage.haskell.org/package/tabler-icons)**

## Quick Example

```haskell
import Web.TablerIcons.Outline qualified as Outline
import Lucid

myIcon = div_ [class_ "w-6 h-6 text-blue-500"] $ 
  toHtmlRaw Outline.home
```

For comprehensive documentation, usage patterns, CSS framework integration, and the complete icon reference, see the [Hackage documentation](https://hackage.haskell.org/package/tabler-icons).