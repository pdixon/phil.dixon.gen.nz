{-# LANGUAGE OverloadedStrings #-}
module Main where

import Prelude hiding (id)
import Control.Category (id)
import Control.Arrow (arr, (>>>), (***), second)
import Control.Monad (forM_)
import Data.Monoid (mempty, mconcat)

import qualified Data.Map as M

import Hakyll

main :: IO ()
main = hakyllWith config $ do
    ["js/*"] --> copy
    ["images/*"] --> copy

    ["css/*.css"] --> css
    [regex "^css/[^_]+\\.scss$"] --> scss

    match "templates/*" $ do
      compile templateCompiler

    -- Index
    match "index.html" $ route idRoute
    create "index.html" $ constA mempty
               >>> arr (setField "title" "Phillip Dixon")
               >>> arr (setField "section" "Home")
               >>> setFieldPageList (take 3 . recentFirst)
                       "templates/postitem.html" "posts" "posts/*"
               >>> applyTemplateCompiler "templates/index.html"
               >>> applyTemplateCompiler "templates/default.html"
    
    -- Post list
    match  "archive.html" $ route idRoute
    create "archive.html" $ constA mempty
               >>> arr (setField "title" "Archive")
               >>> arr (setField "section" "Archive")
               >>> setFieldPageList recentFirst
                   "templates/archiveitem.html" "posts" "posts/*"
               >>> applyTemplateCompiler "templates/posts.html"
               >>> applyTemplateCompiler "templates/default.html"

    -- Render the posts
    ["posts/*"] --> renderPost

     -- Render the draft posts
    ["drafts/*.markdown"] --> renderPost

    -- Render RSS feed
    match  "rss.xml" $ route idRoute
    create "rss.xml" $
        requireAll_ "posts/*" >>> renderRss feedConfiguration

    where
      xs --> f = mapM_ (\p -> match p $ f) xs

      copy = route idRoute >> compile copyFileCompiler

      css = route (setExtension "css") >> compile compressCssCompiler

      scss = do
        route   $ setExtension "css"
        compile $ getResourceString 
                    >>> unixFilter "sass" ["-C", "-Icss/", "-s", "--scss"]
                    >>> arr compressCss

      topLevel = do
        route $ setExtension "html"
        compile $ pageCompiler
                >>> applyTemplateCompiler "templates/default.html"
                >>> relativizeUrlsCompiler

      renderPost = do
        route $ setExtension ".html"
        compile $ pageCompiler
                    >>> arr (copyBodyToField "content")
                    >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
                    >>> arr (setField "section" "Blog")
                    >>> applyTemplateCompiler "templates/post.html"
                    >>> applyTemplateCompiler "templates/default.html"


config :: HakyllConfiguration
config = defaultHakyllConfiguration
    { deployCommand = "s3cmd sync --delete-removed --exclude 'drafts/*' _site/* s3://phil.dixon.gen.nz"
    }


feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Phillip Dixon"
    , feedDescription = "Personal blog of Phillip Dixon"
    , feedAuthorName  = "Phillip Dixon"
    , feedRoot        = "http://phil.dixon.gen.nz"
    }
