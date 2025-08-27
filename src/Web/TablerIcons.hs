{- |
= Tabler Icons

Haskell bindings for [Tabler Icons](https://tabler.io/icons) - a set of over 5,000 free SVG icons.
Each icon is exported as a 'Data.ByteString.ByteString' containing the raw SVG content.

== Quick Start

Using with [Lucid](https://hackage.haskell.org/package/lucid2):

@
import Web.TablerIcons.Outline qualified as Outline
import Web.TablerIcons.Filled qualified as Filled
import Lucid

myButton = button_ [class_ \"btn\"] $ do
  div_ [class_ \"w-6 h-6 text-blue-500\"] $ toHtmlRaw Outline.home
  \"Home\"

myFilledIcon = div_ [class_ \"w-6 h-6 text-red-500\"] $
  toHtmlRaw Filled.heart
@

== Available Icon Sets

* __"Web.TablerIcons.Outline"__ - 4964 outline style icons (comprehensive set)
* __"Web.TablerIcons.Filled"__ - 981 filled style icons (subset of popular icons)

All 981 filled icons have corresponding outline versions with the same name.

== Icon Naming

Icon names follow Haskell naming conventions:

* Hyphens become underscores: @building-arch@ → @building_arch@
* Names starting with numbers get @icon_@ prefix: @2fa@ → @icon_2fa@
* Haskell keywords get @_@ suffix: @type@ → @type_@
-}
module Web.TablerIcons () where

-- This module provides documentation only.
-- Import Web.TablerIcons.Outline and Web.TablerIcons.Filled directly.
