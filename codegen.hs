#!/usr/bin/env runhaskell
{-# LANGUAGE OverloadedStrings #-}

-- | Simple Tabler Icons Code Generator
--
-- This script generates Haskell modules from Tabler SVG files.
-- Usage: runhaskell codegen.hs <tabler-path> <output-dir>

import Control.Monad (forM_, when)
import Data.ByteString qualified as BS
import Data.ByteString.Char8 qualified as BS8
import Data.Char (toLower)
import Data.List (sort)
import System.Directory (createDirectoryIfMissing, doesDirectoryExist, listDirectory)
import System.Environment (getArgs)
import System.FilePath (takeBaseName, takeExtension, (</>))

main :: IO ()
main = do
  args <- getArgs
  case args of
    [tablerPath, outputDir] -> generateBindings tablerPath outputDir
    _ -> do
      putStrLn "Usage: runhaskell codegen.hs <tabler-path> <output-dir>"
      putStrLn "Example: runhaskell codegen.hs /nix/store/...-tabler-icons src/Web/TablerIcons"

generateBindings :: FilePath -> FilePath -> IO ()
generateBindings tablerPath outputDir = do
  putStrLn $ "Generating Tabler Icons bindings from: " <> tablerPath

  -- Check if tabler path exists
  tablerExists <- doesDirectoryExist tablerPath
  if not tablerExists
    then putStrLn $ "Error: Tabler path does not exist: " <> tablerPath
    else do
      -- Count icons first
      let outlinePath = tablerPath </> "icons" </> "outline"
      let filledPath = tablerPath </> "icons" </> "filled"
      
      outlineCount <- countIcons outlinePath
      filledCount <- countIcons filledPath
      
      -- Generate parent module
      generateParentModule outputDir outlineCount filledCount
      
      -- Generate bindings for outline icons
      generateIconSet outlinePath (outputDir </> "Outline.hs") "Web.TablerIcons.Outline"

      -- Generate bindings for filled icons
      generateIconSet filledPath (outputDir </> "Filled.hs") "Web.TablerIcons.Filled"

generateIconSet :: FilePath -> FilePath -> String -> IO ()
generateIconSet iconsDir outputFile moduleName = do
  exists <- doesDirectoryExist iconsDir
  if not exists
    then putStrLn $ "Warning: Icons directory does not exist: " <> iconsDir
    else do
      putStrLn $ "Processing icons from: " <> iconsDir

      -- Get all SVG files
      files <- listDirectory iconsDir
      let svgFiles = sort $ filter (\f -> takeExtension f == ".svg") files

      putStrLn $ "Found " <> show (length svgFiles) <> " SVG icons"

      -- Create output directory
      createDirectoryIfMissing True (takeDirectory outputFile)

      -- Generate module content
      content <- generateModuleContent moduleName iconsDir svgFiles
      writeFile outputFile content

      putStrLn $ "Generated: " <> outputFile

takeDirectory :: FilePath -> FilePath
takeDirectory = reverse . dropWhile (/= '/') . reverse

-- Strip HTML comments and newlines from SVG content
stripHtmlComments :: BS.ByteString -> BS.ByteString
stripHtmlComments content = 
  case BS8.breakSubstring "<svg" content of
    (_, rest) | BS.null rest -> content  -- No <svg found, return original
    (_, svgPart) -> BS8.filter (/= '\n') svgPart  -- Remove newlines and return content starting from <svg

countIcons :: FilePath -> IO Int
countIcons iconsDir = do
  exists <- doesDirectoryExist iconsDir
  if not exists
    then pure 0
    else do
      files <- listDirectory iconsDir
      let svgFiles = filter (\f -> takeExtension f == ".svg") files
      pure (length svgFiles)

generateParentModule :: FilePath -> Int -> Int -> IO ()
generateParentModule outputDir outlineCount filledCount = do
  let outputFile = (takeDirectory outputDir) </> "TablerIcons.hs"  -- Web/TablerIcons.hs
  
  -- Create output directory
  createDirectoryIfMissing True (takeDirectory outputFile)
  
  let content = unlines
        [ "{- |"
        , "= Tabler Icons"
        , ""
        , "Haskell bindings for [Tabler Icons](https://tabler.io/icons) - a set of over 5,000 free SVG icons."
        , "Each icon is exported as a 'Data.ByteString.ByteString' containing the raw SVG content."
        , ""
        , "== Quick Start"
        , ""
        , "Using with [Lucid](https://hackage.haskell.org/package/lucid2):"
        , ""
        , "@"
        , "import Web.TablerIcons.Outline qualified as Outline"
        , "import Web.TablerIcons.Filled qualified as Filled"
        , "import Lucid"
        , ""
        , "myButton = button_ [class_ \\\"btn\\\"] $ do"
        , "  div_ [class_ \\\"w-6 h-6 text-blue-500\\\"] $ toHtmlRaw Outline.home"
        , "  \\\"Home\\\""
        , ""
        , "myFilledIcon = div_ [class_ \\\"w-6 h-6 text-red-500\\\"] $"
        , "  toHtmlRaw Filled.heart"
        , "@"
        , ""
        , "== Available Icon Sets"
        , ""
        , "* __\"Web.TablerIcons.Outline\"__ - " <> show outlineCount <> " outline style icons (comprehensive set)"
        , "* __\"Web.TablerIcons.Filled\"__ - " <> show filledCount <> " filled style icons (subset of popular icons)"
        , ""
        , "All " <> show filledCount <> " filled icons have corresponding outline versions with the same name."
        , ""
        , "== Icon Naming"
        , ""
        , "Icon names follow Haskell naming conventions:"
        , ""
        , "* Hyphens become underscores: @building-arch@ → @building_arch@"
        , "* Names starting with numbers get @icon_@ prefix: @2fa@ → @icon_2fa@"
        , "* Haskell keywords get @_@ suffix: @type@ → @type_@"
        , "-}"
        , "module Web.TablerIcons () where"
        , ""
        , "-- This module provides documentation only."
        , "-- Import Web.TablerIcons.Outline and Web.TablerIcons.Filled directly."
        ]
  
  writeFile outputFile content
  putStrLn $ "Generated: " <> outputFile

generateModuleContent :: String -> FilePath -> [FilePath] -> IO String
generateModuleContent moduleName iconsDir svgFiles = do
  iconData <- mapM processIcon svgFiles

  let bindings =
        map
          ( \(name, content, original) ->
              "-- | SVG for icon @"
                <> original
                <> "@\n"
                <> "-- \n"
                <> "-- [View on Tabler.io](https://tabler.io/icons/icon/"
                <> original
                <> ")\n"
                <> name
                <> " :: ByteString\n"
                <> name
                <> " = "
                <> show content
                <> "\n"
          )
          iconData

  let iconCount = length svgFiles
      style = extractStyle moduleName
  pure $
    unlines $
      [ "{-# LANGUAGE NoImplicitPrelude #-}"
      , "{-# LANGUAGE OverloadedStrings #-}"
      , ""
      , "{- |"
      , "= Tabler " <> style <> " Icons"
      , ""
      , "This module contains " <> show iconCount <> " " <> map toLower style <> " style icons."
      , "For comprehensive documentation, examples, and usage patterns, see \"Web.TablerIcons\"."
      , ""
      , "Each icon is exported as a 'ByteString' containing the raw SVG content."
      , ""
      , "== Quick Import"
      , ""
      , "@"
      , "import " <> moduleName <> " qualified as " <> style
      , "@"
      , ""
      , "== Usage"
      , ""
      , "See \"Web.TablerIcons\" for detailed examples and CSS framework integration."
      , "-}"
      , "module " <> moduleName <> " where"
      , ""
      , "import Prelude ()"
      , "import Data.ByteString (ByteString)"
      , ""
      ]
        <> bindings
  where
    processIcon svgFile = do
      let iconName = svgFileToHaskellName (takeBaseName svgFile)
      svgContent <- BS.readFile (iconsDir </> svgFile)
      let cleanedSvg = stripHtmlComments svgContent
      pure (iconName, cleanedSvg, takeBaseName svgFile)

    extractStyle = reverse . takeWhile (/= '.') . reverse

-- Convert SVG filename to valid Haskell identifier
svgFileToHaskellName :: String -> String
svgFileToHaskellName name =
  let cleaned = map (\c -> if c == '-' then '_' else c) name
      -- Handle names that start with numbers by prefixing with 'icon_'
      withPrefix = case cleaned of
        [] -> "icon_"
        (c : _) | not (isAlpha c) -> "icon_" <> cleaned
        _ -> cleaned
      -- Only handle Haskell keywords, not Prelude conflicts since we hide Prelude
      final =
        if withPrefix `elem` haskellKeywords
          then withPrefix <> "_"
          else withPrefix
   in final
  where
    isAlpha c = c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z'

-- Haskell reserved keywords to avoid
haskellKeywords :: [String]
haskellKeywords =
  [ "case"
  , "class"
  , "data"
  , "default"
  , "deriving"
  , "do"
  , "else"
  , "if"
  , "import"
  , "in"
  , "infix"
  , "infixl"
  , "infixr"
  , "instance"
  , "let"
  , "module"
  , "newtype"
  , "of"
  , "then"
  , "type"
  , "where"
  , "as"
  , "qualified"
  , "hiding"
  ]
