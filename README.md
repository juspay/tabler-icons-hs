# tabler-icons

Haskell bindings for [Tabler Icons](https://tabler.io/icons) - a set of over 5,000 free SVG icons.

## Overview

This package provides access to Tabler SVG icons as `ByteString` values, allowing them to be embedded directly in Haskell web applications. The icons are automatically generated from [the official Tabler Icons repository](https://github.com/tabler/tabler-icons).

## Usage

Here is an example using Lucid & TailwindCSS:

```haskell
import Web.TablerIcons.Outline qualified as Outline
import Web.TablerIcons.Filled qualified as Filled
import Lucid

-- Use outline icons
myIcon :: Html ()
myIcon = div_ [class_ "w-6 h-6 text-blue-500"] $ 
  toHtmlRaw Outline.home

-- Use filled icons  
myFilledIcon :: Html ()
myFilledIcon = div_ [class_ "w-6 h-6 text-red-500"] $ 
  toHtmlRaw Filled.heart
```

## Available Icon Sets

- **Web.TablerIcons.Outline** - [Outline](https://github.com/tabler/tabler-icons/tree/main/icons/outline) style icons
- **Web.TablerIcons.Filled** - [Filled](https://github.com/tabler/tabler-icons/tree/main/icons/filled) style icons

## Source

Icons are sourced from the official [Tabler Icons](https://github.com/tabler/tabler-icons) repository and are licensed under MIT.

## Code Generation

The Haskell bindings are automatically generated using a code generator. To regenerate the bindings:

```bash
nix run .#tabler-codegen
```