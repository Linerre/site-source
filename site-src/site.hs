--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Hakyll
import Hakyll.Web.Html (demoteHeaders)
import Skylighting (styleToCss, monochrome)
import Skylighting.Styles
import System.Directory
  ( copyFile,
    getHomeDirectory,
    doesFileExist,
    createDirectoryIfMissing
  )
import Text.Pandoc.Options (ReaderOptions (..),
                            WriterOptions (..),
                            HTMLMathMethod (..))
import Text.Pandoc.Templates (compileTemplate)
import Text.Pandoc.Extensions
import qualified Text.Pandoc.Templates (Template)

--------------------------------------------------------------------------------
pandocCodeStyle = monochrome

main :: IO ()
main = do

  createDirectoryIfMissing True "_site/css"
  writeFile "_site/css/syntax.css" $ styleToCss pandocCodeStyle

  hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $
          pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "pages/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts)
                    <> defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

    create ["css/syntax.css"] $ do
      route idRoute
      compile $ do
        makeItem $ styleToCss pandocCodeStyle

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%Y-%m-%d"
    <> defaultContext
